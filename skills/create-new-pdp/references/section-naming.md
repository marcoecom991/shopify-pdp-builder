# Section naming — convenzioni per prefissi e nomi

Quando si crea un nuovo template PDP, **ogni sezione referenziata va duplicata con un prefisso nuovo** per evitare di modificare le sezioni del template di partenza (che è già live su un altro prodotto).

## Regola del prefisso

Derivazione automatica dal nome template:

| Nome template               | Prefisso sezioni | Esempio file sezione              |
| --------------------------- | ---------------- | --------------------------------- |
| `crema-borse-occhiaie-pdp`  | `cboe-`          | `sections/cboe-pdp-05.liquid`     |
| `autoabbronzante-listicle`  | `alist-` o `listicle-` | `sections/listicle-02-hero.liquid` |
| `nuovo-prodotto-pdp`        | `npp-`           | `sections/npp-pdp-05.liquid`      |
| `siero-vitamina-c-pdp`      | `svc-`           | `sections/svc-pdp-05.liquid`      |

**Come generare il prefisso di default**: prendere le iniziali di ogni parola del nome template (separate da `-`), lowercase, più `-`.

Esempio: `crema-borse-occhiaie-pdp` → `c` + `b` + `o` + `e` → `cboe-`.

L'utente può comunque scegliere un prefisso diverso se preferisce (es. per leggibilità).

## Struttura del suffix dopo il prefisso

Mantieni la parte identificativa della sezione originale dopo il prefisso:

| Sezione originale                         | Duplicato (con prefisso `npp-`)       |
| ----------------------------------------- | ------------------------------------- |
| `sections/cboe-hero-badge.liquid`         | `sections/npp-hero-badge.liquid`      |
| `sections/cboe-pdp-05.liquid`             | `sections/npp-pdp-05.liquid`          |
| `sections/cboe-pdp-06a-video.liquid`      | `sections/npp-pdp-06a-video.liquid`   |

**Sostituisci solo la prima occorrenza del prefisso**, il resto del nome resta identico. Questo preserva la leggibilità dell'elenco sezioni nel theme editor.

## Aggiornamento del template JSON

Nel nuovo `templates/product.<nome>.json`, sostituisci ogni riferimento al vecchio prefisso con il nuovo:

```diff
- "type": "cboe-pdp-05",
+ "type": "npp-pdp-05",
```

Questo va fatto per ogni blocco `"type"` del JSON, inclusi i blocchi dentro `blocks` nidificati se presenti.

## Aggiornamento dello schema dentro il file `.liquid`

In ogni sezione duplicata, aggiorna `schema.name` e `presets[0].name` per distinguerla nel theme editor:

```diff
  {% schema %}
  {
-   "name": "CBOE PDP 05",
+   "name": "NPP PDP 05",
    ...
    "presets": [
      {
-       "name": "CBOE PDP 05"
+       "name": "NPP PDP 05"
      }
    ]
  }
  {% endschema %}
```

Questo evita che il theme editor mostri due sezioni con lo stesso nome (l'originale e la duplicata), confusionario per chi usa l'editor.

## Esempi storici (riusabili)

### Nimea — crema borse occhiaie (PDP)
Sezioni `cboe-*` duplicate da `product.berberina-pills.json` (12 file):
- `cboe-hero-badge`
- `cboe-pdp-03`, `cboe-pdp-05`, `cboe-pdp-06a-video`, `cboe-pdp-06b-doctors`, `cboe-pdp-07`
- `cboe-pdp-10`, `cboe-pdp-11`, `cboe-pdp-12`, `cboe-pdp-13`, `cboe-pdp-18`, `cboe-pdp-21`

### Glowria — autoabbronzante listicle (pre-PDP funnel)
Sezioni `listicle-*` (11 file, pagina chromeless, non PDP):
- `listicle-01-announcement` fino a `listicle-11-footer`
- Layout: `theme.gempages.blank` (nessun header/footer)

## Naming sui nomi che contengono numeri sequenziali

Per template PDP, la numerazione interna (`-05`, `-06a`, `-06b`, `-18`, `-21`) è **ereditata dal template originale**. Non rinumerarla per il nuovo template — lasciala identica. Questo rende più semplice mappare 1:1 sezione originale ↔ sezione duplicata nella fase di popolamento testi.
