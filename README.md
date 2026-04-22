# Shopify PDP Builder

Claude Code plugin che automatizza la creazione di nuove PDP Shopify partendo da un template esistente. Distribuibile a tutti i membri del team: ognuno lo installa una volta, configura i propri store, e lancia `/create-new-pdp` per ogni nuova PDP.

## Cosa fa

Il comando `/create-new-pdp` guida end-to-end:

1. **Store selection** — scegli su quale store lavorare (Nimea, Glowria, o altri configurati).
2. **Auth check** — verifica che il tuo Theme Access token sia valido.
3. **Duplicazione template** — sceglie un template PDP esistente, lo duplica con nuovo nome, duplica tutte le sezioni con prefisso derivato.
4. **Push selettivo** — pubblica solo i file nuovi sul tema live.
5. **Raccolta materiali** — ti chiede competitor PDP, transcript, research prodotto, angle, brand assets.
6. **Popolamento testi** — sezione per sezione incolli l'HTML di riferimento, Claude sostituisce SOLO testi (mai markup).
7. **Guida immagini** — per ogni sezione ti dice cosa caricare, in che dimensioni, che tipo di foto.
8. **Verifica finale** — checklist mobile/desktop, console errors, URL live.

## Setup (primo utilizzo, una volta per membro)

### 1. Installa il plugin

```bash
/plugin install https://github.com/<org>/shopify-pdp-builder.git
```

(Se il plugin è distribuito via zip, scompatta in `~/.claude/plugins/shopify-pdp-builder/`.)

### 2. Crea la cartella locale degli store

Fuori dal repo del plugin, in un posto tuo privato (es. `~/Desktop/Shopify-Stores/`):

```
~/Desktop/Shopify-Stores/
├── Nimea/
│   └── workdir/        # ← `shopify theme pull` qui
└── Glowria/
    └── workdir/
```

Per ciascuno store, pull del tema:

```bash
cd ~/Desktop/Shopify-Stores/Nimea/workdir
npx @shopify/cli@latest theme pull --theme <THEME_ID> --store <handle>.myshopify.com
```

### 3. Crea il `.env` per ogni store

Usa lo script helper:

```bash
cd ~/.claude/plugins/shopify-pdp-builder  # o dove hai installato il plugin
./scripts/setup-store.sh
```

Ti chiede interattivamente path workdir, token, handle — scrive `.env` con permessi 600 e testa la connessione.

**Come generare il Theme Access token**:
1. Shopify Admin → Apps → cerca **"Theme Access"** (installala se non c'è, è gratis).
2. Dentro l'app → **Create password** → compila nome + email.
3. Shopify ti manda un'email con un link → aprilo → copi il token (`shptka_...`).
4. Lo incolli quando `setup-store.sh` lo chiede.

**Il token è visibile una sola volta. Se lo perdi, rigeneralo.**

### 4. Compila `config/stores.json`

Copia `config/stores.example.json` → `config/stores.json` e metti i path reali dei tuoi workdir:

```json
{
  "stores": {
    "nimea": {
      "label": "Nimea",
      "workdir": "/Users/<tu>/Desktop/Shopify-Stores/Nimea/workdir",
      "env": "/Users/<tu>/Desktop/Shopify-Stores/Nimea/workdir/.env",
      "theme_id": "195368288591",
      "store_handle": "qncxve-5r.myshopify.com"
    },
    "glowria": {
      "label": "Glowria",
      "workdir": "/Users/<tu>/Desktop/Shopify-Stores/Glowria/workdir",
      "env": "/Users/<tu>/Desktop/Shopify-Stores/Glowria/workdir/.env",
      "theme_id": "196773773653",
      "store_handle": "2hw0d3-wu.myshopify.com"
    }
  }
}
```

`config/stores.json` è nel `.gitignore`, non viene mai committato.

### 5. Testa

In una nuova conversazione Claude Code:

```
/create-new-pdp
```

Dovrebbe partire dal prompt di scelta store.

## Aggiornamenti

```bash
/plugin update shopify-pdp-builder
```

(Oppure, per distribuzione zip: ri-scompatta la versione aggiornata.)

## Separazione secrets

- **Il plugin** (questa cartella) è pubblicabile/condivisibile. Non contiene mai token o path personali.
- **I `.env`** stanno nei workdir degli store, fuori dal plugin. Mai committati.
- **`config/stores.json`** è per-membro, nel `.gitignore`. Solo `stores.example.json` è committato.

Ogni membro genera il **proprio** Theme Access token — audit Shopify traccia ogni modifica all'utente corretto, e se qualcuno lascia il team basta revocare il suo token.

## Struttura repo

```
shopify-pdp-builder/
├── .claude-plugin/plugin.json     # Manifest plugin
├── skills/create-new-pdp/
│   ├── SKILL.md                   # Orchestrator — 7 fasi guidate
│   └── references/
│       ├── workflow-faithful-rebuild.md
│       ├── auth-pattern.md
│       ├── selective-push.md
│       ├── section-naming.md
│       └── image-specs-per-section.md
├── config/
│   ├── stores.example.json        # Template (committato)
│   └── stores.json                # Reale (NON committato)
├── scripts/setup-store.sh         # Helper per creare .env
├── .env.example
├── .gitignore
└── README.md
```

## Troubleshooting

| Problema                                    | Soluzione                                                                            |
| ------------------------------------------- | ------------------------------------------------------------------------------------ |
| `/create-new-pdp` non esiste                | Hai installato il plugin? Apri nuova sessione Claude Code dopo `/plugin install`.    |
| `401 Unauthorized` durante push             | Token scaduto/revocato. Rigenera da Theme Access e rilancia `setup-store.sh`.        |
| "Store non trovato in config/stores.json"   | Crea il file da `stores.example.json` e aggiungi il tuo store.                       |
| Push rifiutato con "Theme is live"          | Aggiungi `--allow-live` (già incluso nei template della skill).                      |
| `command not found: npx`                    | Installa Node.js (≥ 18) da nodejs.org, poi riprova.                                  |
| Sezione sbagliata dopo push                 | La skill ha modificato un file diverso dal prefisso atteso? Controlla `--only`.      |

## Roadmap

- v2: creazione Product/Page via Admin API (ora è manuale in Admin).
- v2: upload immagini via Files API (ora le carichi manualmente).
- v2: logging audit `logs/<timestamp>-<pdp>.md`.

## Licenza

Privato — uso interno team.
