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