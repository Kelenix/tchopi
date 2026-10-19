// Test de charge du backend Supabase sur les appels les plus fréquents de l'app (docs/qa/load-report.md).
//   node tests/load/backend.mjs                  profils smoke, charge, stress contre Supabase local
//   SUPABASE_URL=… SUPABASE_ANON_KEY=… node tests/load/backend.mjs
// Prérequis : .\dev-accounts.ps1 (client 07 00 00 00 04, livreur 07 00 00 00 05).
// Node intégré plutôt que k6 : aucun outil à installer (ADR-030). Seuils : p95 < 500 ms, échecs < 1 %.
import { readFileSync } from 'node:fs';

const env = process.env.SUPABASE_URL
  ? process.env
  : JSON.parse(readFileSync(new URL('../../env/local.json', import.meta.url)));
const url = env.SUPABASE_URL;
const key = env.SUPABASE_ANON_KEY;
const password = 'Tchopi2026';
const grill = '22222222-0000-0000-0000-000000000002';
const thresholds = { p95Ms: 500, failRate: 0.01 };

async function call(method, path, token, body) {
  const response = await fetch(`${url}${path}`, {
    method,
    headers: {
      apikey: key,
      Authorization: `Bearer ${token ?? key}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation',
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await response.text();
  if (!response.ok) throw new Error(`${method} ${path} → ${response.status} ${text.slice(0, 120)}`);
  return text ? JSON.parse(text) : null;
}

const signIn = async (phone) =>
  (await call('POST', '/auth/v1/token?grant_type=password', null, { phone, password })).access_token;

// Préparation : comptes, adresse du client au Plateau, produits du menu, livreur en ligne.
const client = await signIn('+2250700000004');
const courier = await signIn('+2250700000005');
let [address] = await call('GET', '/rest/v1/addresses?select=id&limit=1', client);
address ??= (
  await call('POST', '/rest/v1/addresses?select=id', client, {
    label: 'Bureau',
    district: 'Plateau',
    landmark: 'Test de charge',
    latitude: 5.3236,
    longitude: -4.0197,
  })
)[0];
const products = await call(
  'GET',
  `/rest/v1/products?select=id&restaurant_id=eq.${grill}&archived_at=is.null&is_available=eq.true&limit=2`,
  client,
);
await call('POST', '/rest/v1/rpc/set_courier_online', courier, { p_online: true });

// Un parcours client (accueil → menu → devis → historique) et la position d'un livreur.
const steps = {
  'Accueil : restaurants': () =>
    call('GET', '/rest/v1/restaurants?select=*,is_open&is_active=eq.true&order=name.asc', client),
  'Menu : catégories': () =>
    call('GET', `/rest/v1/categories?select=id,name,position&restaurant_id=eq.${grill}&order=position.asc`, client),
  'Menu : produits': () =>
    call('GET', `/rest/v1/products?select=*&restaurant_id=eq.${grill}&archived_at=is.null&order=name.asc`, client),
  'Devis de commande': () =>
    call('POST', '/rest/v1/rpc/quote_food_order', client, {
      p_restaurant_id: grill,
      p_address_id: address.id,
      p_items: products.map((p) => ({ product_id: p.id, quantity: 1 })),
    }),
  'Mes commandes': () =>
    call('GET', '/rest/v1/orders?select=*,order_items(*)&order=created_at.desc&limit=50', client),
  'Position du livreur': () =>
    call('POST', '/rest/v1/rpc/report_location', courier, {
      p_lat: 5.32 + Math.random() / 100,
      p_lng: -4.02 + Math.random() / 100,
      p_accuracy_m: 12,
    }),
};

async function run(name, users, seconds) {
  const timings = Object.fromEntries(Object.keys(steps).map((s) => [s, []]));
  const failures = Object.fromEntries(Object.keys(steps).map((s) => [s, 0]));
  const errors = new Set();
  const end = Date.now() + seconds * 1000;
  const user = async () => {
    while (Date.now() < end) {
      for (const [step, request] of Object.entries(steps)) {
        const start = performance.now();
        try {
          await request();
          timings[step].push(performance.now() - start);
        } catch (error) {
          failures[step]++;
          errors.add(error.message);
        }
      }
    }
  };
  await Promise.all(Array.from({ length: users }, user));

  const pct = (list, p) => list.sort((a, b) => a - b)[Math.max(0, Math.ceil(list.length * p) - 1)] ?? 0;
  console.log(`\n### ${name} — ${users} utilisateurs simultanés, ${seconds} s\n`);
  console.log('| Appel | Requêtes | Échecs | p50 (ms) | p95 (ms) | Max (ms) | Seuils |');
  console.log('|-------|---------:|-------:|---------:|---------:|---------:|--------|');
  let ok = true;
  for (const step of Object.keys(steps)) {
    const list = timings[step];
    const total = list.length + failures[step];
    const p95 = pct(list, 0.95);
    const pass = p95 < thresholds.p95Ms && failures[step] / Math.max(total, 1) < thresholds.failRate;
    ok &&= pass;
    console.log(
      `| ${step} | ${total} | ${failures[step]} | ${pct(list, 0.5).toFixed(0)} | ${p95.toFixed(0)} | ` +
        `${Math.max(0, ...list).toFixed(0)} | ${pass ? '✅' : '❌'} |`,
    );
  }
  for (const message of errors) console.log(`\nErreur : ${message}`);
  return ok;
}

const results = [
  await run('Smoke', 1, 10),
  await run('Charge', 20, 30),
  await run('Stress', 50, 20),
];
await call('POST', '/rest/v1/rpc/set_courier_online', courier, { p_online: false });
process.exitCode = results.every(Boolean) ? 0 : 1;
