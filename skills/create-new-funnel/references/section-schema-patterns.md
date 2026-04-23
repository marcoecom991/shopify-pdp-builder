# Section schema patterns — rendere editabile ogni sezione

Tutte le sezioni prodotte dalle skill (PDP + funnel) devono essere **editabili dal theme editor**: testi, immagini, link modificabili da Admin senza toccare i file. Questa è la fonte di verità per lo schema.

## Regola fondamentale

- **Per la PDP**: durante la duplicazione (Fase 3.5), se la sezione copiata è hardcoded la skill la **liquidifica** automaticamente. Il file sorgente (template base) NON viene mai toccato — la liquidify opera solo sul duplicato.
- **Per il funnel**: le sezioni nascono già editabili in costruzione (Fase 8). Regola fissa, sempre.

## Tipi di setting — quando usarli

| Tipo            | Quando usarlo                                                                 | Default esempio                         |
|-----------------|-------------------------------------------------------------------------------|-----------------------------------------|
| `text`          | Headline, label bottone, badge, nome card (singola riga, no formatting)       | `"Scopri la soluzione"`                 |
| `textarea`      | Paragrafo semplice multi-riga, disclaimer, subtitle lungo                     | `"Testo breve descrittivo."`            |
| `richtext`      | Paragrafo con inline `<strong>`, `<em>`, `<a>`, liste — WYSIWYG nell'editor   | `"<p>Testo <strong>ricco</strong>.</p>"`|
| `image_picker`  | Qualsiasi immagine (hero, packshot, icon, avatar testimonial)                 | *(vuoto, render condizionale)*          |
| `url`           | href di CTA, link sociali                                                     | `"https://.../products/slug"`           |
| `color`         | Override colore ad-hoc (raro, preferisci `brand.*`)                           | `"#1A3A5C"`                             |
| `select`        | Scelta chiusa (es. layout left/right, size S/M/L)                             | `"left"`                                |
| `checkbox`      | Toggle booleano (mostra/nascondi badge, enable dark mode)                     | `true`                                  |
| `range`         | Valore numerico con min/max (padding, font-size base, spacing)                | `40`                                    |
| `product`       | Picker di un prodotto Shopify                                                 | *(dal theme editor)*                    |
| `collection`    | Picker di una collezione                                                      | *(idem)*                                |

## Convenzione naming degli `id`

- Sempre **snake_case**: `hero_heading`, non `heroHeading` né `hero-heading`.
- Prefisso semantico per ruolo quando utile: `hero_*`, `cta_primary_*`, `benefit_1_*`.
- Per le liste ripetibili → `blocks` (vedi sotto), non `benefit_1_title`, `benefit_2_title`, `benefit_3_title` separati.

## Blocks — pattern per liste ripetibili

Quando nella sezione ci sono **N elementi fratelli con stessa struttura** (FAQ, benefit cards, testimonial, reason cards di un listicle, domande quiz), diventano `blocks` invece di N settings numerati.

```liquid
<section class="aa-benefits">
  <h2>{{ section.settings.heading }}</h2>
  <ul>
    {% for block in section.blocks %}
      <li {{ block.shopify_attributes }}>
        {% if block.settings.icon %}
          <img src="{{ block.settings.icon | image_url: width: 80 }}" alt="{{ block.settings.title }}">
        {% endif %}
        <h3>{{ block.settings.title }}</h3>
        <p>{{ block.settings.body }}</p>
      </li>
    {% endfor %}
  </ul>
</section>

{% schema %}
{
  "name": "Benefits",
  "tag": "section",
  "class": "aa-benefits",
  "settings": [
    { "type": "text", "id": "heading", "label": "Titolo sezione", "default": "I benefici" }
  ],
  "blocks": [
    {
      "type": "benefit",
      "name": "Benefit",
      "settings": [
        { "type": "image_picker", "id": "icon", "label": "Icona" },
        { "type": "text", "id": "title", "label": "Titolo", "default": "Benefit 1" },
        { "type": "textarea", "id": "body", "label": "Descrizione", "default": "Testo breve." }
      ]
    }
  ],
  "max_blocks": 12,
  "presets": [
    {
      "name": "Benefits",
      "blocks": [
        { "type": "benefit" },
        { "type": "benefit" },
        { "type": "benefit" }
      ]
    }
  ]
}
{% endschema %}
```

Dall'editor: "+ Add block" → Benefit → nuovo item nella lista. Drag & drop per riordinare.

## Pattern liquidify — recipe before/after

### Prima (legacy hardcoded — file duplicato da PDP tipo berberina)

```liquid
<section class="cboe-hero">
  <div class="cboe-hero__inner">
    <h1>Abbassa il colesterolo naturalmente con la berberina</h1>
    <p>30 capsule al giorno per <strong>risultati in 4 settimane</strong>.</p>
    <img src="https://cdn.shopify.com/s/files/1/0/.../berberina-hero.webp"
         alt="Flacone berberina" width="1600" height="900">
    <a href="#add" class="cboe-hero__cta">Acquista ora</a>
  </div>
</section>

{% schema %}
{ "name": "CBOE Hero", "tag": "section", "class": "cboe-hero" }
{% endschema %}
```

### Dopo (liquidified — stesso rendering, ora editabile)

```liquid
<section class="cboe-hero">
  <div class="cboe-hero__inner">
    <h1>{{ section.settings.heading }}</h1>
    <div class="cboe-hero__body">{{ section.settings.body }}</div>
    {% if section.settings.hero_image %}
      <img src="{{ section.settings.hero_image | image_url: width: 1600 }}"
           alt="{{ section.settings.hero_image.alt | default: section.settings.heading }}"
           width="1600" height="900" loading="lazy">
    {% endif %}
    <a href="{{ section.settings.cta_url }}" class="cboe-hero__cta">{{ section.settings.cta_label }}</a>
  </div>
</section>

{% schema %}
{
  "name": "CBOE Hero",
  "tag": "section",
  "class": "cboe-hero",
  "settings": [
    { "type": "text",         "id": "heading",    "label": "Titolo",   "default": "Abbassa il colesterolo naturalmente con la berberina" },
    { "type": "richtext",     "id": "body",       "label": "Testo",    "default": "<p>30 capsule al giorno per <strong>risultati in 4 settimane</strong>.</p>" },
    { "type": "image_picker", "id": "hero_image", "label": "Immagine hero" },
    { "type": "url",          "id": "cta_url",    "label": "Link CTA", "default": "/products/berberina" },
    { "type": "text",         "id": "cta_label",  "label": "Testo CTA","default": "Acquista ora" }
  ],
  "presets": [ { "name": "CBOE Hero" } ]
}
{% endschema %}
```

Osservazioni:

- Il markup strutturale è **identico**: stessi tag, stesse classi, stesso wrapper, stesso CSS.
- I testi visibili sono diventati `{{ section.settings.* }}`; i loro valori originali sono spostati nei `default` dello schema.
- L'immagine passa da URL CDN hardcoded a `image_picker` con render via `image_url: width: 1600` (Shopify serve webp + srcset responsive automatico).
- Il link CTA è ora un `url` setting (l'utente può cambiarlo dall'editor senza toccare il file).

## Edge case e regole di skip

1. **`<script>` inline** → skip. Il JS resta hardcoded, non estraibile in setting.
2. **JSON-LD structured data** (`<script type="application/ld+json">`) → skip, è tecnico.
3. **`<style>` inline** → skip per il CSS vero; se contiene `content: "…"` con testo visibile raro, valutare caso per caso (tipicamente skip).
4. **Background inline CSS** (`style="background-image: url(...)"`) → estraibile come `image_picker`, poi render:
   ```liquid
   <div class="hero" {% if section.settings.bg %}style="background-image: url({{ section.settings.bg | image_url: width: 2000 }});"{% endif %}>
   ```
5. **srcset / `<picture>`** → un solo `image_picker` + ricostruisci il responsive via filter `image_url: width: X` per ogni breakpoint. Shopify gestisce il resto.
6. **Testi dentro attributi** (`aria-label`, `title`, `placeholder`) → possono diventare setting `text` se l'utente vorrebbe modificarli; altrimenti skip.
7. **Liquid logic esistente** (`{% if %}`, `{% for %}`, `{% assign %}`) → non toccare. La liquidify aggiunge settings, non riscrive la logica.
8. **Classi CSS con nomi semantici** (es. `.cboe-hero__headline`) → **non rinominare**. Lasciare intatte, il CSS scoped deve continuare a funzionare.
9. **Ripetizioni con stessa classe** (es. 4 `<div class="benefit-card">` fratelli) → convertire in `blocks`, non in 4 set di settings separati.
10. **Se la liquidify rischia di rompere la sezione** (JS che manipola testi hardcoded via selector di contenuto, integrazioni tipo Katching che referenziano DOM specifico) → segnala all'utente, chiedi conferma prima di procedere su quella specifica sezione. Fallback accettabile: lasciare hardcoded solo quella sezione con nota.

## Default sensati

- Ogni `text` / `textarea` / `richtext` ha `default` = valore estratto (liquidify) o valore dal research/angle (funnel).
- Gli `image_picker` restano senza default ma con render condizionale (`{% if section.settings.<id> %}`) per evitare immagine rotta.
- `url` per CTA ha default = URL PDP prodotto (Fase 5.1 funnel, `product.slug` PDP).
- `color` evita default hardcoded — usa CSS variables da `brand.*` quando possibile.

## Checklist post-liquidify / post-build

Prima di pushare una sezione:

- [ ] Tutti i testi visibili nel markup sono `{{ section.settings.* }}` o `{{ block.settings.* }}`.
- [ ] Nessun `<img src="https://cdn.shopify.com/...">` hardcoded — tutti passano da `image_picker`.
- [ ] Nessun `href="https://.../products/..."` hardcoded nei bottoni — tutti da setting `url`.
- [ ] Schema valida come JSON (nessuna virgola extra, bracket matched).
- [ ] `presets` presente con almeno un entry (senza `presets` la sezione non è aggiungibile da UI).
- [ ] Per sezioni con blocks: `max_blocks` definito, `presets` include blocks di default.
- [ ] Il render condizionale protegge dai settings vuoti (immagini, url opzionali).
- [ ] Il file sorgente originale (PDP base) non è stato modificato.
