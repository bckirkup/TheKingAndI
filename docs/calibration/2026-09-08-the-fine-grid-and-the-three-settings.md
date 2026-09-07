# The Fine Grid and the Three Settings — D215 Pride at a Second Seed

**Date:** 2026-09-08
**Follows:** `2026-09-06-the-carriers-that-could-not-fire.md` (Phase C, one
seed, scales `{0, 10, 50, 100, 250}`), which ruled `PRIDE_REFUSAL_SCALE`
stays 0 pending a second seed and a fine grid inside the graded region.
**Ruling proposed:** `PRIDE_REFUSAL_SCALE` stays **0**. No default changes.

## Question

Inside the graded region the 09-06 grid left unexplored (`1..40`), is there a
scale at which pride separates rooms in a direction the mechanism owns rather
than the seed? Two seeds, four fine points, the saturation edge located.

## Method

- `sim/emotionCensus.ts --engine=fake --weeks=8 --matches=4 --commanders=6
  --pride-refusal-scale=<v>`, Phase A shape (six styles, 12 commanders, 384
  records per style), seeds **41** and **7**, `v ∈ {0, 5, 10, 20, 40}`.
  Seed-41 scales 0 and 10 are the 09-06 artifacts (`bb5e0a…`, `5522b7…`),
  reused unchanged.
- Run as two AWS Batch arrays on the 09-06 image
  (`sha256:d7dcc789…`), job definition `kingsandi-census:3` (identical to
  `:2` with the attempt timeout raised 43 200 → 72 000 s), Fargate Spot,
  1 vCPU / 2 GiB: `401d65c3…` (`phasec-pride-fine-s41`, scales 5/20/40) and
  `e75e7e83…` (`phasec-pride-fine-s7`, scales 0/5/10/20/40). Artifacts under
  `s3://kingsandi-campaigns-…/campaigns/phasec-pride-fine-s{41,7}/`.
- Wall time 10.1–11.7 h per shard. Two seed-7 shards (10, 40) were Spot-
  interrupted (exit 137, "Your Spot Task was interrupted") after 13.6 h and
  10.8 h and retried; 40 completed on retry, 10 was still on its third attempt
  when this note was written and its value comes from a local lane
  (`census.json` written at completion).
- Cross-host check: six `(seed, scale)` pairs exist from both Batch and a
  local lane (41/5, 41/20, 41/40, 7/0, 7/5, 7/20); every pair is identical
  after dropping the host-specific `args.out`. Mixing sources is therefore
  safe, as it was on 09-06.
- Fake engine throughout: every number is a relative comparison across
  scales on the same seed, not a chess-strength estimate (`AGENTS.md`).

## What the grid saw

### The knob has three settings, not a slope

`playDigest` per seed:

| scale | seed 41 | seed 7 |
|---|---|---|
| 0 | `bb5e0a…` | `b29be3…` |
| 5 | `477bff…` | `656101…` |
| 10 | `5522b7…` | `3ff685…` |
| 20 | `90898b…` | `ab16c0…` |
| 40 | `90898b…` | `ab16c0…` |

Scale 20 and 40 are the same play on both seeds, and on seed 41 scale 20 is
byte-identical to the 09-06 scales 50, 100 and 250. The saturation edge is
therefore **between 10 and 20**, not the ≈40 the 09-06 note estimated from
the appraisal arithmetic alone. The reason is the base threshold's range: a
proud piece at 125–253‰ gains `trunc(appraisal × 20 / 1000) = +2..+5` at
scale 20, and +2 is already past every perceived-value difference the
harness ever hands a piece with a positive appraisal — so 20, 40 and 250 all
mean "a proud piece never refuses".

What the four distinct plays are, on this pool's appraisals (125, 135–166,
253‰ and steady's lone 29–42‰ piece):

- **0** — off.
- **5** — only pieces at ≥ 200‰ gain +1 (on seed 41 that is volatile's two
  at 253‰; the tables report per-style means, so which seed-7 pieces clear
  200‰ is not readable from them). The play diverges from 0 on both seeds.
- **10** — every piece at 100–199‰ gains +1, a 200‰+ piece +2.
- **≥ 20** — proud pieces never refuse.

### The table

Refusals are own-side refusal events over 384 records; rates, desertions,
trust, win and LI are per-commander-match means; "priced"/"positive" are
pool pieces with `selfAppraisal` written / written `> 0`.

**Seed 41**

| style | scale | priced | positive | mean appraisal ‰ | refusals | refusal rate | desertions | quiet-quit | trust_final | win | LI |
|---|---|---|---|---|---|---|---|---|---|---|---|
| servant | 0 | 0 | 0 | — | 70273 | 0.5192 | 0.659 | 0.093 | −19.98 | 54.30 | 6.22 |
| servant | 5 | 9 | 0 | −114 | 67949 | 0.5147 | 0.617 | 0.094 | −18.62 | 53.52 | 6.55 |
| servant | 10 | 9 | 0 | −117 | 68193 | 0.5036 | 0.578 | 0.094 | −18.49 | 56.12 | 7.42 |
| servant | 20 = 40 | 9 | 0 | −114 | 66678 | 0.5192 | 0.557 | 0.098 | −17.53 | 54.17 | 7.18 |
| supportive | 0 | 0 | 0 | — | 31171 | 0.2524 | 0.120 | 0.120 | 47.40 | 57.68 | 34.66 |
| supportive | 5 | 4 | 1 | 125 | 35726 | 0.2754 | 0.148 | 0.119 | 47.30 | 56.12 | 34.16 |
| supportive | 10 | 4 | 1 | 125 | 34927 | 0.2696 | 0.133 | 0.118 | 47.98 | 54.43 | 33.88 |
| supportive | 20 = 40 | 4 | 1 | 125 | 28071 | 0.2158 | 0.104 | 0.113 | 49.94 | 58.59 | 36.01 |
| tyrannical | 0 | 0 | 0 | — | 23273 | 0.0028 | 0.219 | 0.044 | −22.63 | 58.59 | 7.32 |
| tyrannical | 5 | 4 | 4 | 166 | 22949 | 0.0028 | 0.234 | 0.045 | −22.08 | 60.29 | 8.06 |
| tyrannical | 10 | 4 | 4 | 166 | 21817 | 0.0030 | 0.177 | 0.044 | −23.11 | 60.55 | 7.76 |
| tyrannical | 20 = 40 | 4 | 4 | 166 | 23156 | 0.0022 | 0.161 | 0.044 | −22.17 | 58.07 | 7.39 |
| volatile | 0 | 0 | 0 | — | 45179 | 0.3533 | 0.326 | 0.059 | −20.11 | 44.27 | 3.87 |
| volatile | 5 | 2 | 2 | 253 | 46175 | 0.3502 | 0.289 | 0.062 | −20.04 | 43.49 | 3.70 |
| volatile | 10 | 2 | 2 | 253 | 44874 | 0.3517 | 0.357 | 0.060 | −20.18 | 42.84 | 3.45 |
| volatile | 20 = 40 | 2 | 2 | 253 | 41750 | 0.3490 | 0.349 | 0.060 | −20.60 | 44.27 | 3.71 |
| random | 0 | 0 | 0 | — | 45808 | 0.3975 | 0.456 | 0.067 | −20.33 | 42.45 | 3.06 |
| random | 5 | 5 | 0 | 0 | 46677 | 0.4036 | 0.477 | 0.067 | −20.75 | 43.49 | 3.19 |
| random | 10 | 5 | 0 | 0 | 45488 | 0.3867 | 0.435 | 0.066 | −20.36 | 43.62 | 3.46 |
| random | 20 = 40 | 5 | 0 | 0 | 43636 | 0.3942 | 0.461 | 0.066 | −20.44 | 42.97 | 3.22 |
| steady | 0 | 0 | 0 | — | 45882 | 0.3581 | 0.326 | 0.060 | −21.06 | 42.71 | 3.03 |
| steady | 5 | 6 | 1 | 42 | 43306 | 0.3545 | 0.276 | 0.063 | −20.64 | 43.10 | 3.32 |
| steady | 10 | 6 | 1 | 42 | 40163 | 0.3654 | 0.289 | 0.064 | −20.94 | 42.45 | 3.09 |
| steady | 20 = 40 | 6 | 1 | 42 | 42505 | 0.3609 | 0.268 | 0.064 | −21.32 | 41.93 | 2.79 |

**Seed 7**

| style | scale | priced | positive | mean appraisal ‰ | refusals | refusal rate | desertions | quiet-quit | trust_final | win | LI |
|---|---|---|---|---|---|---|---|---|---|---|---|
| servant | 0 | 0 | 0 | — | 65915 | 0.5031 | 0.596 | 0.081 | −20.44 | 53.78 | 6.01 |
| servant | 5 | 4 | 1 | −46 | 63390 | 0.4920 | 0.589 | 0.097 | −17.80 | 53.39 | 6.78 |
| servant | 10 | 5 | 1 | −85 | 63100 | 0.4900 | 0.620 | 0.086 | −18.86 | 53.12 | 6.37 |
| servant | 20 = 40 | 4 | 1 | −46 | 63024 | 0.4972 | 0.633 | 0.093 | −19.34 | 52.47 | 5.89 |
| supportive | 0 | 0 | 0 | — | 34058 | 0.2752 | 0.151 | 0.117 | 47.11 | 58.20 | 34.59 |
| supportive | 5 | 4 | 1 | 125 | 33067 | 0.2735 | 0.156 | 0.122 | 47.35 | 57.94 | 34.61 |
| supportive | 10 | 4 | 1 | 125 | 33511 | 0.2843 | 0.141 | 0.122 | 47.24 | 56.64 | 34.20 |
| supportive | 20 = 40 | 4 | 1 | 125 | 35021 | 0.2816 | 0.143 | 0.124 | 47.82 | 56.12 | 34.25 |
| tyrannical | 0 | 0 | 0 | — | 21863 | 0.0034 | 0.195 | 0.043 | −22.55 | 58.33 | 7.33 |
| tyrannical | 5 | 5 | 5 | 135 | 23049 | 0.0028 | 0.177 | 0.042 | −21.82 | 59.11 | 7.85 |
| tyrannical | 10 | 4 | 4 | 166 | 22892 | 0.0037 | 0.216 | 0.046 | −22.24 | 58.07 | 7.35 |
| tyrannical | 20 = 40 | 4 | 4 | 166 | 25740 | 0.0030 | 0.208 | 0.044 | −22.21 | 59.90 | 7.88 |
| volatile | 0 | 0 | 0 | — | 48517 | 0.3676 | 0.336 | 0.065 | −22.36 | 42.45 | 2.38 |
| volatile | 5 | 3 | 3 | 120 | 41628 | 0.3668 | 0.320 | 0.067 | −22.40 | 42.84 | 2.51 |
| volatile | 10 | 3 | 3 | 120 | 41571 | 0.3640 | 0.255 | 0.066 | −22.46 | 43.10 | 2.67 |
| volatile | 20 = 40 | 3 | 3 | 120 | 48259 | 0.3664 | 0.312 | 0.066 | −22.46 | 44.01 | 2.78 |
| random | 0 | 0 | 0 | — | 46742 | 0.3879 | 0.479 | 0.063 | −19.69 | 42.84 | 3.49 |
| random | 5 | 7 | 0 | 0 | 46796 | 0.4058 | 0.451 | 0.071 | −20.10 | 42.45 | 3.18 |
| random | 10 | 7 | 0 | 0 | 41994 | 0.3979 | 0.422 | 0.067 | −19.47 | 44.79 | 4.20 |
| random | 20 = 40 | 7 | 0 | 0 | 44734 | 0.3965 | 0.422 | 0.072 | −19.47 | 42.71 | 3.50 |
| steady | 0 | 0 | 0 | — | 50127 | 0.3572 | 0.305 | 0.064 | −21.28 | 44.40 | 3.42 |
| steady | 5 | 7 | 1 | 29 | 48100 | 0.3600 | 0.315 | 0.060 | −20.66 | 44.27 | 3.68 |
| steady | 10 | 7 | 1 | 29 | 42682 | 0.3479 | 0.346 | 0.056 | −21.68 | 44.27 | 3.34 |
| steady | 20 = 40 | 7 | 1 | 29 | 43256 | 0.3525 | 0.398 | 0.063 | −21.52 | 44.79 | 3.38 |

Who is priced does not depend on the scale (the carrier does not feed back
into the draft); seed 7's servant and tyrannical rosters differ slightly
between scale 5 and the rest because a different piece survived to be drafted,
which is the shared pool diverging, not a pricing change.

## Reading

- **The sign does not survive the second seed.** Take the one room where
  pride is a clean single-piece experiment, supportive (one proud piece at
  125‰ on both seeds). Seed 41 says pride *lowers* refusals at saturation
  (0.2524 → 0.2158, LI +1.4); seed 7 says it *raises* them (0.2752 → 0.2816,
  LI −0.3). Tyrannical win score: seed 41 falls at saturation (58.6 → 58.1),
  seed 7 rises (58.3 → 59.9). Every column that moved on 09-06 moves the other
  way, or not at all, on seed 7. This is the pool-divergence band the 09-06
  note flagged, now measured: with 1–5 proud pieces per style among ~380
  records, the mechanism's own contribution is below the noise of the
  seminar pool re-drawing every subsequent match.
- **One consistent reading, and it is small.** Volatile — the only room whose
  proud pieces number more than one on both seeds (2 at 253‰; 3 at 120‰) —
  shows a lower refusal rate at every nonzero scale on both seeds (0.3533 →
  0.3490–0.3517; 0.3676 → 0.3640–0.3668). That is the designed sign (a proud
  piece raises its bar and refuses less), at −0.3% to −1.2% of the rate, and
  it is not graded: 5, 10 and ≥20 are indistinguishable within it.
- **The graded region is two points wide.** With the edge at 10–20, the only
  values that do anything other than "off" or "proud pieces never refuse"
  are 5 (the proudest piece gains +1) and 10 (all proud pieces gain +1). A
  recognition-grade default would be one of those two integers, chosen on a
  two-seed reading whose sign flips between seeds. That is not a pricing;
  it is a coin.
- **What would make it priceable.** The carrier is starved, not wrong. Pride
  is written at draft settlements (30 per run here, `prideEvents.draft`;
  ransom 0 on every run), and only the 125‰-and-up tail of those is positive.
  A pool with more clearing prices — more weeks, a ransom round that settles
  (none did in any of these ten runs), or a Lozza run
  whose pieces are worth pricing — would put tens of proud pieces per style
  in play and let the two seeds agree or disagree on the mechanism rather
  than on the draw.

## Ruling proposed

`PRIDE_REFUSAL_SCALE` **stays 0.** The 09-06 pre-conditions for a nonzero
value were a second seed and a fine grid; both exist now and they do not
supply a value. The saturation edge is recorded as **10 < edge ≤ 20** on
this pool's appraisals (superseding 09-06's ≈40), and the knob is recorded as
effectively three-valued (`0`, `5`, `10`) below it. The ADR 0075 exploit-tier
rerun is not owed until a nonzero value is proposed.

Reopen when the seminar pool prices more pieces (ransom settlement live,
longer runs, or a Lozza census); the fine grid to rerun is `{0, 5, 10}` at
two seeds, ≈10 shard-hours each at this shape.
