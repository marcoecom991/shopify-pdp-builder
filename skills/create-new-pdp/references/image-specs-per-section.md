# Image specs per tipo di sezione

Durante la fase 6 (guida immagini), per ogni sezione che contiene immagini la skill genera un brief per l'utente: cosa mostrare, dimensioni/ratio consigliate, placeholder da sostituire. Questa è la fonte di verità.

## Principi generali

- **Tutte le immagini** sono caricate manualmente dall'utente in Shopify Admin → **Settings → Files** → Upload. L'utente copia l'URL CDN `https://cdn.shopify.com/s/files/1/...` e lo incolla.
- **Formato**: preferire `.webp` per foto (qualità/peso migliore), `.png` per grafica con trasparenza o testo, `.svg` per loghi vettoriali.
- **Peso max per immagine**: 300 KB, ideale < 150 KB. Usa `squoosh.app` o equivalenti per comprimere.
- **Alt text**: sempre presente, descrittivo (es. `"Crema contorno occhi Nimea — borse e occhiaie"`).

## Specs per tipo sezione (mappatura da nome)

Il matching è basato su keyword nel nome sezione (case-insensitive). Se una sezione ha più keyword, vince il match più specifico (es. `06a-video` → video, non hero).

### `hero` / `hero-badge`
- **1 immagine** hero shot prodotto.
- Ratio: 4:5 (ritratto) o 1:1 (quadrato) per mobile; 16:9 per desktop se full-width.
- Dimensioni: 1200×1500 (4:5) o 1600×900 (16:9).
- Contenuto: packshot prodotto su background pulito + mood lifestyle.

### `pdp-03` / pills / badges
- Spesso **nessuna immagine** (solo testo + badge colorati). Skip se non presenti `<img>` nel file.
- Se presenti icon-badge: SVG o PNG 64×64.

### `pdp-05` / carousel testimonial / 3-card
- **3-5 immagini** card (una per card).
- Ratio: 4:5 ritratto.
- Dimensioni: 800×1000.
- Contenuto: foto cliente reale (primo piano viso o zona prodotto prima/dopo) + 1 banner prodotto sotto le card.
- **Banner**: 1200×400 orizzontale, mostra il prodotto + claim breve.

### `pdp-06a-video`
- **1 video** hero (non img).
- Formato: `.mp4`, max 5 MB, 8-15 secondi, loop seamless.
- Ratio: 16:9 o 9:16 a seconda che sia desktop o mobile-first.
- Dimensioni: 1280×720 (16:9) o 720×1280 (9:16).
- Deve andare in autoplay muted loop inline (attributi già presenti nel markup, solo sostituire `src`).

### `pdp-06b-doctors`
- **2-3 immagini** ritratto medico/esperto.
- Ratio: 1:1 quadrato.
- Dimensioni: 600×600.
- Contenuto: foto professionale, camice bianco o background neutro, espressione affidabile.

### `pdp-07` / "perché funziona" / 3-step
- **1 immagine** di supporto (prodotto in uso o ingredienti).
- Ratio: 1:1 o 4:5.
- Dimensioni: 1000×1000 o 1000×1250.

### `pdp-10` / interactive hotspot + marquee
- **1 immagine** prodotto centrale con punti interattivi sovrapposti.
- Ratio: 1:1.
- Dimensioni: 1200×1200.
- Contenuto: packshot flat, background neutro, spazio per label hotspot.

### `pdp-11` / garanzia / collage polaroid
- **3 immagini** stile polaroid/screenshot (feedback clienti reali, pack shot lifestyle).
- Ratio: vario (3:4, 1:1, 4:3).
- Dimensioni: 600×800 o 800×800.
- Contenuto: un mix di prodotto in mano, testo recensione screenshottato, close-up risultato.

### `pdp-12` / comparison table / "vs altri"
- **1 logo/immagine brand** piccola (top del table).
- Dimensioni: 256×256 (viene renderizzata a 48-68px).
- Può essere un SVG logo o un packshot quadrato del prodotto.

### `pdp-13` / FAQ
- **Nessuna immagine** (solo accordion testo + ondina SVG inline).

### `pdp-18` / reviews wall
- **10 immagini** per le prime 10 recensioni (le successive senza foto).
- Ratio: 1:1 o 4:5.
- Dimensioni: 400×400 o 600×800.
- Contenuto: screenshot chat cliente, selfie cliente con prodotto, before/after.

### `pdp-21` / sezione finale / closing CTA
- Opzionale **1 banner** CTA con prodotto + garanzia.
- Ratio: 16:9 o 21:9.
- Dimensioni: 1600×900 o 1600×686.

### `listicle-*` (listicle/advertorial)

Pattern simile ma orientato storytelling article:

- `listicle-02-hero`: 1 immagine full-width mood/lifestyle (1600×900).
- `listicle-03-reason-XX`: 1 immagine per ogni "reason point" (600×750, ratio 4:5).
- `listicle-04` comparison: 2 immagini before/after (600×750 ciascuna).
- `listicle-09-offer`: packshot prodotto + badge offerta (1000×1000).
- `listicle-11-footer`: logo brand + mini-icon social (SVG).

## Placeholder patterns da riconoscere

Quando la sezione è stata duplicata ma l'immagine non è ancora stata sostituita, riconoscere i placeholder di questo tipo nei file `.liquid`:
- URL CDN di un altro prodotto (es. `cdn.shopify.com/.../berberina_xxx.png`) → va sostituito.
- Placeholder Shopify `{{ "image.png" | asset_url }}` senza asset reale.
- URL `https://via.placeholder.com/...` → mai committato in live, va sostituito.

## Output brief per l'utente (template)

Per ogni sezione, la skill mostra all'utente:

```
Sezione: <nome-sezione>
Tipo: <hero | carousel | video | ...>
Immagini richieste: <N>

Per ogni immagine:
  - Ruolo: <es. "foto cliente primo piano per card 1">
  - Ratio: <4:5>
  - Dimensioni consigliate: <800×1000>
  - Peso max: 150 KB (.webp)
  - URL attuale (placeholder da sostituire): <url>

Passi:
  1. Prepara l'immagine con le specifiche sopra.
  2. Caricala su Shopify Admin → Settings → Files.
  3. Copia l'URL CDN generato.
  4. Incollalo qui, così la skill fa il replace e push.
```
