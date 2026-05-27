# Languages record

Each theater website has it's own rules for specifying the language. In most of thems we only have VOSE (original version with spanish subtitles) or no label. So, we cannot differ from Original Language (Spanish movie) or Dubbed movie.

Here is a list with the info gathered:

- m2k: Only VOSE. Dubbed means dubbed or VO, we can't distinguish.
- Cinesa has `original language` movies and `dubbed` movies, but they have no tag for it. However, in their attributes they have Vose, Vosi (original audio + english subtitles), CATALAN, Es Nuestro Cine (local Spanish production program). We use the `Es Nuestro Cine` for the `:vo` language label.
- Renoir has many possibilities, right now we only track two (vose, and vo), we'll have to keep an eye on it.
- Golem: only `:vose` or `:vo`, no dubbed (this theater doesn't have dubbed movies). VOSE is detected by the `(V.O.S.E.)` suffix in the movie title; no suffix means `:vo`.
- Verdi Madrid and Cinemes Girona (admit_one): labels found in showtime row span.
  - `V.O. SUB. CASTELLANO`, `VOSE`, `VOSC` → `:vose`
  - `CASTELLANO`, `CASTELLÀ`, `CATALÀ`, `DIG` → `:vo`
  - `CONCIERTO` → skip whole movie (concerts/opera/ballet broadcasts, not films).
  - TODO: schema cannot distinguish Spanish vs Catalan subtitles, nor flag Catalan-language films.
- Zumzeig: always original audio.
  - `VOSE`, `VOSCAT`, `VOSC` → `:vose`
  - `Doblada` / `Doblado` → `:dubbed`
  - bare `VO` (no subs) → `:vo`
  - TODO: Per-session variation (e.g. "VOSCAT Sá 19:30, el resto VOSE").
- Zoco (Cines Zoco Majadahonda): detected from the "Idioma" field on the single-movie page.
  - `/con subt[ií]tulos/i` → `:vose`
  - `/\Adoblada/i` → `:dubbed`
  - `/\Aoriginal/i` → `:vo`
  - TODO: site labelling is unreliable (e.g. a "V.O.S." URL may declare "Doblada en castellano"); we trust the Idioma field even when it contradicts the title.
- Cines ABC (El Saler, Park, Gran Turia, Elx, Gandía): per-showtime tag inside `.linea-sesion`/`.etiq-hora`.
  - `(VOSE)` → `:vose`
  - empty / no tag → `:dubbed`
  - TODO: site does not distinguish `:vo` (Spanish original) from `:dubbed`; both fall under `:dubbed`.
- Verdi Barcelona: no dubbed films.
  - `V.O. SUB. CASTELLANO` → `:vose`
  - `CASTELLANO`, `CATALÁN`, `VARIOS` (multilingual original version) → `:vo`
  - TODO: we need to differ between Castellano and Catalán — the schema maps both to `:vo`.
- Maldà (Cinema Maldà): per-session tag. No dubbed films.
  - `(VOE)` (original audio, no subtitles) → `:vo`
  - `(VOSE)` (original audio + Spanish subtitles) → `:vose`
- Mooby Cinemas:
  - `VOSE`, `VOSE ATMOS` → `:vose`
  - `DOBLADA ESP`, `DOBLADA ESP ATMOS`, `DOBLADA CAT` → `:dubbed`
  - `ESP`, `CAT` (original audio, no subtitles) → `:vo`
  - blank `version` → inferred from subtitles: `subtitles_lang` present → `:vose`, else `:vo`.
  - `keywords` containing `Eventos` → skip whole event (concerts/live broadcasts, e.g. BTS world tour).
  - `VOSI` raises `UnknownLanguageError`; re-add a `:vosi` enum + mapping if that happens.