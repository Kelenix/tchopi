# SPEC — pub UGC Tchopi

GOAL:    on retient « j'ai faim → Tchopi → c'est livré », avec la vraie app et le paiement Mobile Money.
OUTPUT:  HyperFrames, 1080 x 1920, 30 fps.
TIME:    24,4 s x 30 = 732 images ; musique 108 BPM (16,7 images par temps, 66,7 par mesure).
LOOK:    médium = enregistrement d'écran TikTok : vrais écrans de l'app (1170 px de large, réduits à 0,855),
         coins 48 px, ombre 0 30 80 rgba(0,0,0,.35) ; encadrés de texte natifs (fond #FFFFFF, encre #0F1412,
         rayon 22 px, Plus Jakarta Sans ExtraBold 64 px, interlettrage -1 %) ; mot prononcé surligné vert
         #16A34A, texte blanc. Fond des scènes « app » : vert Tchopi #0B5D3B uni ; fin : #F5F6F3.
         Photo d'ouverture : `welcome-hero.jpg` de l'app. Accent #16A34A : mot surligné, point de « tchopi. ».
OBJECTS: le téléphone (écran réel, cadre encre 16 px, rayon 72 px), la carte réelle avec la moto de Yao, la carte
         « Code de livraison 3 5 1 1 », le statut « Livrée » et sa chronologie (captures de l'app).
MOTION:  arrivées expo.out 0,5 s ; caméra power2.inOut 0,6 s ; sorties power3.in 0,3 s ; flou de mouvement 12 px
         pic sur les déplacements plein cadre ; appui = point de toucher blanc 64 px à 45 %, 0,25 s, pas d'anneau.
SHOTS:   0,0–4,0   photo d'ouverture, encadré « POV : il est 20 h et t'as faim » dès l'image 0 ; punch-in 1,0→1,12
                   sur « faim » (1,6 s) ; sortie en fouetté vers le haut 3,6–4,0.
         4,0–6,0   fond vert ; le téléphone monte du bas (accueil réel) ; « J'ouvre Tchopi ».
         6,0–9,6   le téléphone grandit jusqu'à plein cadre (l'écran devient le monde) : fiche Maquis Chez Tante,
                   défilement vers les plats, appui sur Garba (6,8) puis Alloco (7,9) → barre « 2 articles 4 000 F ».
         9,6–12,6  panier réel ; appui sur Mobile Money (10,4), punch-in sur la ligne des opérateurs ; appui sur
                   « Commander » (12,1) → ouverture en iris vers la carte.
         12,6–17,4 carte réelle plein cadre, la moto approche (3 positions réelles, fondu flou) ; carte « Yao · Moto »
                   en haut, « Arrivée estimée : environ 6 min » en bas ; pastille « EN DIRECT ».
         17,4–20,4 carte « Code de livraison 3 5 1 1 » grossie ; sur « livré » (18,7) le fond passe au vert et le
                   statut « Livrée » + chronologie réels arrivent.
         20,4–24,4 fond clair ; « tchopi. » tapé lettre à lettre, point vert qui tombe ; « Vos plats et vos colis,
                   livrés partout dans votre ville. » (texte de l'app) ; « Bientôt sur Google Play ». Tenu 2,5 s.
BANNED:  vide sombre, lueurs, dégradés violets, cartes en verre, trois cartes en ligne, logo dans un coin, anneaux
         de clic, titres qui flottent, faux écrans, icône d'app inventée (l'icône actuelle est celle de Flutter).
QA:      0,0 (accroche lisible) ; 1,8 ; 5,0 ; 7,2 ; 8,4 ; 10,8 ; 14,0 ; 16,0 ; 18,0 ; 19,5 ; 22,5 ; 24,2.
