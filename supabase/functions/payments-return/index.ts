// Page affichée après un paiement en ligne (retour depuis Stripe) : le client revient dans l'app, qui suit le statut
// en direct. Rien n'est lu ni écrit ici.
const page = `<!doctype html>
<html lang="fr">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tchopi</title>
<body style="margin:0;padding:64px 24px;font-family:system-ui,sans-serif;text-align:center;color:#0F1412;background:#F5F6F3">
  <p style="font-size:32px;font-weight:800;margin:0 0 24px">tchopi<span style="color:#16A34A">.</span></p>
  <p style="font-size:18px;line-height:1.5;margin:0">Vous pouvez revenir dans l'application Tchopi :<br>
  votre commande s'y met à jour toute seule.</p>
</body>
</html>`;

Deno.serve(() => new Response(page, { headers: { 'Content-Type': 'text/html; charset=utf-8' } }));
