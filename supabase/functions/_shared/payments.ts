// Paiements en ligne, communs aux fournisseurs (Mobile Money par nyole, carte par Stripe) : session hébergée, statut
// lu chez le fournisseur (jamais celui annoncé par un webhook ou l'app) puis appliqué en base.
import type { SupabaseClient } from '@supabase/supabase-js';

/// Données renvoyées par `begin_online_payment`.
export type Checkout = {
  transaction_id: string;
  provider: string;
  amount: number;
  currency: string;
  order_number: string;
  customer_name: string | null;
  customer_phone: string | null;
  session_id: string | null;
  checkout_url: string | null;
  attempt: number;
};

/// Statut d'une session chez le fournisseur, dans le vocabulaire de `apply_payment_status`.
export type ProviderStatus = {
  status: 'PENDING' | 'SUCCESS' | 'FAILED' | 'CANCELLED' | 'REFUNDED';
  amount: number;
  currency: string;
  reference?: string;
};

export type Provider = {
  configured: () => boolean;
  /// Ouvre une session ; la même tentative rend la même session (clé d'idempotence). [returnTo] : page du site web
  /// où revenir après le paiement (déjà vérifiée) ; sinon la page de retour configurée pour l'app.
  open: (checkout: Checkout, attempt: number, returnTo?: string) => Promise<{ id: string; url: string; reference?: string }>;
  status: (sessionId: string) => Promise<ProviderStatus>;
};

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/// Statut lu chez le fournisseur appliqué à la transaction.
export async function settle(admin: SupabaseClient, provider: Provider, transactionId: string, sessionId: string) {
  const status = await provider.status(sessionId);
  const { data, error } = await admin.rpc('apply_payment_status', {
    p_transaction_id: transactionId,
    p_status: status.status,
    p_amount: status.amount,
    p_currency: status.currency,
    p_reference: status.reference ?? null,
  });
  if (error) throw error;
  return { provider: status.status, result: data as string };
}

/// Webhook dont la signature a été vérifiée : rejoué sans effet ; une erreur rend 500 pour que le fournisseur
/// réessaie. Un événement sans transaction Tchopi (lien de paiement, autre outil) est ignoré.
export async function handleWebhook(
  admin: SupabaseClient,
  provider: Provider,
  event: string | undefined,
  transactionId: string | undefined,
): Promise<Response> {
  if (!transactionId || !UUID.test(transactionId)) return new Response('ok');
  const { data: transaction } = await admin
    .from('transactions')
    .select('id, checkout_session_id')
    .eq('id', transactionId)
    .maybeSingle();
  if (!transaction?.checkout_session_id) return new Response('ok');
  try {
    const { provider: status, result } = await settle(admin, provider, transaction.id, transaction.checkout_session_id);
    console.log(`${event} ${transaction.id} : ${status} → ${result}`);
    return new Response('ok');
  } catch (e) {
    console.error(e);
    return new Response('retry', { status: 500 });
  }
}
