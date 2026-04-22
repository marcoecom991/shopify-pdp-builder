---
name: create-new-pdp
description: Crea una nuova PDP Shopify da zero. Guida l'utente attraverso 7 fasi — scelta store, verifica auth, duplicazione template e sezioni con nuovo prefisso, raccolta materiali di ricerca sul prodotto, popolamento testi sezione-per-sezione mantenendo i layout esistenti, indicazioni sulle immagini da caricare, verifica finale. Da usare ogni volta che un membro del team deve pubblicare una PDP per un nuovo prodotto su uno degli store configurati (Nimea, Glowria, o altri aggiunti a config/stores.json).
---

# /create-new-pdp — Orchestrator

Sei una guida passo-passo per creare una PDP Shopify da zero. Segui le 7 fasi **in sequenza**. Non saltare fasi. Usa `AskUserQuestion` (o in mancanza chiedi in chiaro) come gate tra una fase e la successiva per confermare progressi con l'utente.

## Principio generale

- **Non riscrivere il markup esistente.** Quando duplichi sezioni e poi le popoli con i nuovi contenuti, preservi layout, CSS, JS responsive della sezione di partenza. Modifichi solo testi e URL immagini. Fonte di verità: `references/workflow-faithful-rebuild.md`.
- **Un push per volta, sempre selettivo.** Mai `theme push` senza `--only`. Fonte di verità: `references/selective-push.md`.
- **Conferma con l'utente prima di ogni azione distruttiva o irreversibile** (creazione file, push live, rinomina).

## Lettura dello stato iniziale

All'avvio:
1. Leggi `config/stores.json` (path: `<plugin-root>/config/stores.json`). Se NON esiste, copialo da `config/stores.example.json` e dì all'utente di compilarlo con i suoi path locali e theme IDs prima di ricominciare. Stop.
2. Se esiste, estrai la lista degli store.

---

## Fase 1 — Scelta store

Mostra all'utente la lista degli store configurati. Usa `AskUserQuestion` con un'opzione per store + "Altro" (per aggiungerne uno nuovo on-the-fly).

Se l'utente sceglie "Altro":
- Chiedi nome store, `shopify_domain` (*.myshopify.com), theme ID, path workdir e path env.
- Aggiungi la voce a `stores.json` e procedi.

Salva in memoria i campi dello store scelto:
- `store.name`
- `store.shopify_domain`
- `store.theme_id`
- `store.workdir_path`
- `store.env_path`

---

## Fase 2 — Verifica auth

1. Controlla che `store.env_path` esista. Se NO:
   - Spiega all'utente cosa serve (token Theme Access). Fonte: `references/auth-pattern.md`, sezione "Come generare un nuovo Theme Access token".
   - Guidalo a creare il file: chiedigli di incollare il token, poi scrivi `store.env_path` con:
     ```
     SHOPIFY_CLI_THEME_TOKEN=<token-incollato>
     SHOPIFY_FLAG_STORE=<store.shopify_domain>
     ```
2. Verifica la connessione con un comando di test:
   ```bash
   cd "<store.workdir_path>"
   set -a; source "<store.env_path>"; set +a
   npx @shopify/cli@latest theme list --no-color 2>&1 | tail -20
   ```
3. Se l'output mostra errori di auth (`401`, `Invalid API key`, `Unauthorized`): il token è scaduto. Chiedi all'utente di rigenerarlo e aggiornare il `.env`. Rilancia il test.
4. Se l'output mostra la lista temi: verifica che `store.theme_id` sia presente. Conferma con l'utente quale theme ID usare (di solito il live published).

Se `workdir/` è vuoto o datato, chiedi all'utente se vuole fare un `theme pull` fresco:
```bash
cd "<store.workdir_path>"
set -a; source "<store.env_path>"; set +a
npx @shopify/cli@latest theme pull --theme <store.theme_id> --nodelete
```

---

## Fase 3 — Duplicazione template

### 3.1 Nome nuovo template

Con `AskUserQuestion`: "Che nome vuoi dare al nuovo template PDP?"
- Valida: kebab-case, solo `[a-z0-9-]`, niente spazi.
- Esempi: `crema-borse-occhiaie-pdp`, `siero-vitamina-c-pdp`, `nuovo-prodotto-pdp`.
- Verifica che `<store.workdir_path>/templates/product.<nome>.json` NON esista già. Se esiste: chiedi conferma sovrascrittura o nome diverso.

### 3.2 Scelta template base

Elenca i `product.*.json` presenti in `<store.workdir_path>/templates/`:
```bash
ls "<store.workdir_path>/templates/" | grep '^product\..*\.json$'
```

Con `AskUserQuestion`: "Da quale template vuoi partire?"
- Mostra i nomi leggibili (es. `berberina-pills`, `crema-borse-occhiaie-pdp`).
- Fallback: se c'è un solo `product.*.json` oltre al default `product.json`, assumi quello.

### 3.3 Prefisso nuove sezioni

Genera un prefisso di default dalle iniziali del nome template (vedi `references/section-naming.md`):
- `crema-borse-occhiaie-pdp` → `cboe`
- `siero-vitamina-c-pdp` → `svc`

Con `AskUserQuestion`: "Prefisso sezioni: `<default>`? (conferma o proponi alternativo)"

### 3.4 Duplicazione effettiva

1. Leggi il template base JSON con `Read`.
2. Estrai la lista delle sezioni referenziate: ogni blocco `"type": "<nome-sezione>"` che corrisponde a un file `sections/<nome-sezione>.liquid`.
3. Identifica il prefisso corrente del template base (tipicamente l'inizio del nome di molte sezioni, es. `cboe-` se vengono da `cboe-pdp-05`, `cboe-pdp-06a-video`, ecc.).
4. Per ogni sezione referenziata che inizia col prefisso base:
   - Leggi il file originale `sections/<old-prefisso>-<suffix>.liquid` con `Read`.
   - Calcola nuovo path: `sections/<nuovo-prefisso>-<suffix>.liquid`.
   - Scrivi il nuovo file con `Write`, applicando queste sostituzioni:
     - In `{% schema %}`: `"name": "<OLD NAME>"` → `"name": "<NEW NAME>"` (uppercase del prefisso).
     - In `presets[0].name`: stessa cosa.
     - Nelle `class=` del markup: se c'è una classe tipo `cboe-` specifica nello scoping CSS, lasciala (è classe CSS, non identifica la sezione). Tocca SOLO il nome schema.
5. Scrivi il nuovo template JSON:
   - Copia il contenuto del base.
   - Sostituisci ogni `"type": "<old-prefisso>-<suffix>"` con `"type": "<nuovo-prefisso>-<suffix>"`.
   - Salva in `templates/product.<nome-nuovo>.json`.
6. Mostra all'utente un riepilogo:
   ```
   Creati:
   - templates/product.<nome>.json
   - sections/<nuovo-prefisso>-01.liquid (da <old>-01)
   - sections/<nuovo-prefisso>-05.liquid (da <old>-05)
   ...
   ```
7. Chiedi conferma prima del push.

### 3.5 Push iniziale

Push selettivo di TUTTI i file appena creati (template + sezioni):
```bash
cd "<store.workdir_path>"
set -a; source "<store.env_path>"; set +a
npx @shopify/cli@latest theme push \
  --theme <store.theme_id> \
  --nodelete \
  --allow-live \
  --only "templates/product.<nome>.json" \
  --only "sections/<nuovo-prefisso>-01.liquid" \
  --only "sections/<nuovo-prefisso>-05.liquid" \
  # ... tutte le sezioni duplicate
```

### 3.6 Istruzioni per il Product Shopify

Mostra all'utente istruzioni per creare il Product in Shopify Admin:
```
Ora crea il prodotto in Shopify:
1. Admin → Products → Add product.
2. Title: "<nome del nuovo prodotto>".
3. Scrivi una descrizione base (può essere placeholder, la personalizzeremo dopo via template).
4. In "Theme template" (sidebar destra, sezione Online store), seleziona: <nome> (il nostro nuovo template).
5. Save.
6. Torna qui e dimmi lo slug del prodotto (es. `crema-borse-occhiaie-ufficiale`), così posso riferirmi alla URL live per i check successivi.
```

Salva lo slug in memoria: `product.slug`. URL live: `https://<store.shopify_domain>/products/<product.slug>`.

---

## Fase 4 — Raccolta materiali

Chiedi all'utente di fornire (puoi presentare come checklist):

1. **PDP competitor**: 1-3 URL o screenshot di PDP di competitor dello stesso angolo/categoria. Servono per capire il linguaggio, i claim, la struttura.
2. **Transcript video**: 1-3 video (competitor o interni) trascritti in testo. Servono per capire tono di voce, punti di dolore menzionati, frasi ad alta conversione.
3. **Research prodotto**:
   - Ingredienti chiave (nome + cosa fa + dosaggio se rilevante).
   - Claim principali (effetto #1, #2, #3 del prodotto).
   - Target audience (chi compra, cosa risolve).
   - Differenziazione (perché noi vs competitor).
   - Proof points (certificazioni, test clinici, numeri di vendita, recensioni).
4. **Angolo marketing corrente**: 1-3 esempi di ad che l'utente sta girando su questo prodotto (copy + headline + immagine/video). Serve per allineare il tono della PDP.
5. **Brand assets**: palette colori (HEX), font (famiglie web), logo URL CDN.

Dopo che l'utente ha fornito tutto: fai un riepilogo sintetico (nome prodotto, 3 claim principali, 3 proof points, palette) e chiedi conferma "Materiali completi, procedo con la scrittura testi sezione-per-sezione?"

---

## Fase 5 — Popolamento testi sezione-per-sezione

Per ogni sezione nel template nuovo, in ordine di apparizione nel JSON (top → bottom):

1. Mostra all'utente: "Prossima sezione: `<nuovo-prefisso>-<suffix>.liquid` — tipo <hero | carousel | video | dottori | comparison | FAQ | reviews | ...>."
2. Chiedi: "Incolla l'HTML di riferimento per questa sezione (dalla PDP esistente del template base, dalla preview GemPages, o da tua creazione), così riproduco i testi."
3. Attendi incolla.
4. Applica la regola di `references/workflow-faithful-rebuild.md`:
   - Identifica nell'HTML incollato **solo i testi** (titoli, paragrafi, bullet, label) e **solo gli URL immagini**.
   - Apri `sections/<nuovo-prefisso>-<suffix>.liquid` con `Read`.
   - Sostituisci i testi/URL corrispondenti mantenendo markup/CSS/JS identici.
   - Per sostituzioni semplici: `Edit`. Per molte sostituzioni: `Bash` con `python3 <<'PY' ... PY` e heredoc + list di replace con `assert n == 1`.
5. Push selettivo:
   ```bash
   cd "<store.workdir_path>"
   set -a; source "<store.env_path>"; set +a
   npx @shopify/cli@latest theme push \
     --theme <store.theme_id> --nodelete --allow-live \
     --only "sections/<nuovo-prefisso>-<suffix>.liquid"
   ```
6. Chiedi all'utente di aprire l'URL live (`https://<store.shopify_domain>/products/<product.slug>`) e confermare che testi e layout siano corretti su mobile e desktop.
7. Gestisci eventuali aggiustamenti (font-size, white-space, nowrap) come modifiche minime — NON rifare la sezione.
8. Quando l'utente conferma, passa alla sezione successiva.

Continua fino all'ultima sezione del template.

---

## Fase 6 — Guida immagini

Una volta che tutti i testi sono validati, passa alla fase immagini. Fonte: `references/image-specs-per-section.md`.

Per ogni sezione che contiene immagini:
1. Identifica il numero e ruolo delle immagini richieste.
2. Mostra all'utente il brief (vedi template a fine `image-specs-per-section.md`):
   - Ruolo dell'immagine (cosa deve mostrare).
   - Ratio consigliato.
   - Dimensioni target.
   - Peso max.
   - URL placeholder attuale da sostituire.
3. L'utente prepara l'immagine offline, la carica su Shopify Admin → Settings → Files, copia l'URL CDN.
4. L'utente incolla nella chat l'URL o gli URL (uno per immagine richiesta).
5. Fai il replace nel file `.liquid` (Edit mirato o Python heredoc), poi push selettivo.
6. Chiedi conferma visiva.

---

## Fase 7 — Verifica finale

1. Mostra la checklist finale:
   - [ ] Tutte le sezioni popolate con testi validati
   - [ ] Tutte le immagini caricate e renderizzate correttamente
   - [ ] Mobile (viewport 375px) ok
   - [ ] Desktop (viewport 1440px) ok
   - [ ] DevTools console pulita (no errori Liquid, no 404 su immagini)
   - [ ] URL diretta funzionante: `https://<store.shopify_domain>/products/<product.slug>`
   - [ ] Custom domain (se presente): `https://<store.custom_domain>/products/<product.slug>`
2. Chiedi all'utente di confermare ogni check o segnalare problemi.
3. Per ogni problema segnalato: torna alla fase corrispondente (5 per testi, 6 per immagini) e fai le modifiche.
4. Quando tutto è ✅: dichiara la PDP pronta. Suggerisci:
   - Aggiungere il prodotto al catalogo/collezione giusta.
   - Impostare pricing, inventory, variants.
   - Collegare il sistema bundling (se usato) — se il prodotto usa Katching o simili, consulta `references/workflow-faithful-rebuild.md` per pattern form nativo.

## Troubleshooting rapido

| Sintomo                                         | Possibile causa                                       | Fix                                                                 |
| ----------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------- |
| `theme list` ritorna 401                        | Token scaduto/revocato                                | Rigenera Theme Access token, aggiorna `.env`                        |
| Push fallisce con "Liquid syntax error"         | Sostituzione ha rotto Liquid                          | Leggi il file, localizza errore, `Edit` per riparare                |
| Sezione non appare su PDP live                  | Template JSON non aggiornato o sezione non pushata   | Verifica `templates/product.<nome>.json` + push sezione             |
| Stile CSS diverso dall'originale                | Hash GemPages toccato per errore                      | Ripristina il file originale e rifai solo la sostituzione testi     |
| Product non usa il nuovo template                | Template suffix non selezionato in Admin              | Admin → Product → sidebar → Theme template → seleziona nuovo nome   |

## File correlati (references)

- `references/workflow-faithful-rebuild.md` — regola d'oro + tecniche di sostituzione.
- `references/auth-pattern.md` — `.env`, Theme Access token, verifica connessione.
- `references/selective-push.md` — comando push standard + flag.
- `references/section-naming.md` — convenzioni prefissi + aggiornamento schema.
- `references/image-specs-per-section.md` — dimensioni/ratio per tipo sezione.
