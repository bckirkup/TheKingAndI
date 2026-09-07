# The Carriers That Could Not Fire — Pricing the Phase C Live Carriers

Date: 2026-09-06 (UTC).
**Superseded in part:** the saturation edge is 10 < edge ≤ 20, see the 2026-09-08 note.
Status: measurement evidence for the ADR 0078 Phase C
carrier magnitudes (D215 pride → refusal threshold, D216 panic → engagement
collapse, D217 loneliness → stay term, awe → affinity, relief → morning
lift). Nothing in this document changes a default. Read
`docs/adr/0078-the-uncarried-emotions.md` (Phase C addendum),
`docs/calibration/2026-09-05-the-recognition-census.md` (Phase A) and
`docs/calibration/2026-09-05-the-carriers-and-the-floor.md` (Phase B) first.

## Question

PR #211 gave every remaining ADR 0078 emotion a live seam behind a zero
knob. Which of the five can be priced on the harnesses we have — does the
trigger fire, does the carrier reach a piece whose behaviour the Judgement
Seat can see, and does the price fall on the right room — and which are
structural zeros in the current world?

## Method

- Telemetry (this PR): append-only own-side per-match counters
  `panic_onsets`, `panic_plies` (own plies moved with `panicPermille > 0`),
  `relief_events`, `heroism_nominations`, `lonely_stay_decisions` (desertion
  evaluations, including cascade evaluations that did not desert, at which
  the loneliness predicate held) on the campaign and sweep CSVs, with sweep
  means. Existing columns are byte-identical; the optional `panicPermille`
  on MOVE events and `lonely: true` on desertion terms are written only
  when nonzero, so default digests do not move.
- Campaign pre-flight (this box): `pnpm exec tsx sim/sweep.ts`, fake
  engine, `--opponent=tyrannical --seed=7 --matches=8`, supportive and
  tyrannical, one campaign per value. Knobs applied through the sweep's
  in-process `ENGINE_CONFIG` patch (confirmed by logging the live value at
  startup; `tsx` runs source, there is no compiled config to go stale).
  Logs `~/phasec/preflight-*.log`, `~/phasec/diagnostic-*.log` (not
  committed).
- Seminar grid (pride): `sim/emotionCensus.ts --seed=41 --engine=fake
  --weeks=8 --matches=4 --commanders=6 --pride-refusal-scale=<v>`,
  `v ∈ {0, 10, 50, 100, 250}`, Phase A shape (six styles, 12 commanders,
  384 records per style), with the per-style outcome summary added in this
  PR. Run as a five-shard AWS Batch array (`deploy/aws/entrypoint-census.sh`,
  job `e6594ad8`, run id `phasec-pride-grid-s41`, image
  `sha256:d7dcc789…`, 1 vCPU / 2 GiB Fargate Spot) with a local lane as a
  hedge. Batch shards 10 / 50 / 250 succeeded in 10.2 / 5.7 / 11.5 h (Spot
  1-vCPU wall time varies widely); shards 0 and 100 hit the 12 h attempt ceiling and were taken from the local lane (5.2–5.5 h
  each on this box). Mixing hosts is sound: the Batch and local payloads for
  scales 10 and 50 are identical in every field but `args.out` (same
  `playDigest`, same `recordDigest`). Artifacts under
  `s3://kingsandi-campaigns-…/campaigns/phasec-pride-grid-s41/census/` and
  `~/phasec/pride2-scale-<v>/` (not committed). A first pass at the census's
  small default shape (4 × 2 × 2, two styles) and at `v ∈ {250, 500, 1000}`
  was discarded: it showed only that the knob saturates, not where.

Fake-engine caveat: relative comparisons only, never chess strength.

## Campaign pre-flight — four carriers, one table

Moderate candidates (panic collapse 500 / decay 50; loneliness penalty 500;
relief 100‰ per event, cap 300; awe shift 20) were **byte-identical to
control in every column, both styles.** The extreme diagnostic below is
what proves the seams are live and says why the moderate ones read nothing.

| candidate | style | panic onsets | panic plies | relief/match | heroism | lonely evals | win | LI | trust_final | refusal | desertions | quiet-quit | emptied chairs |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| control | supportive | 0 | 0 | 0.38 | 0 | 0.88 | 75.0 | 58.87 | 96.30 | 0.080 | 0.000 | 0.211 | 0.25 |
| control | tyrannical | 0 | 0 | 0.00 | 0 | 0.00 | 50.0 | −0.24 | −33.44 | 0.000 | 0.125 | 0.016 | 1.38 |
| loneliness 1000 (stay weight → 0) | supportive | 0 | 0 | 0.38 | 0 | 0.88 | 75.0 | 58.87 | 96.30 | 0.080 | 0.000 | 0.211 | 0.25 |
| loneliness 1000 | tyrannical | 0 | 0 | 0.00 | 0 | 0.00 | 50.0 | −0.24 | −33.44 | 0.000 | 0.125 | 0.016 | 1.38 |
| panic floor 2, collapse 1000, decay 0 | supportive | 0.25 | 3.88 | 0.38 | 0 | 0.88 | 75.0 | 58.87 | 96.30 | 0.080 | 0.000 | 0.211 | 0.25 |
| panic floor 2, collapse 1000, decay 0 | tyrannical | 0 | 0 | 0.00 | 0 | 0.00 | 50.0 | −0.24 | −33.44 | 0.000 | 0.125 | 0.016 | 1.38 |
| relief 1000, cap 1000, **baseline 100** | supportive | 0 | 0 | 0.38 | 0 | 1.25 | 75.0 | 58.99 | 97.06 | 0.078 | 0.000 | 0.211 | 0.38 |
| relief 1000, cap 1000, **baseline 100** | tyrannical | 0 | 0 | 0.63 | 0 | 0.13 | 68.8 | 10.31 | −20.51 | 0.024 | 0.250 | 0.031 | 1.50 |

### D217 awe → affinity: structural zero (engine)

Zero `HEROISM_NOMINATION` in every cell, as in Phase A (0 in 4,608 seminar
records). Heroism needs the engine audit to show a decisive true gain the
piece privately disagreed with; the fake engine never produces one. Awe is
priceable only on a Lozza run. `AWE_AFFINITY_SHIFT` stays 0 with nothing
measured against it.

### D216 panic → engagement collapse: structural zero at the ruled floor, faint below it

At the ruled `PANIC_ROSTER_FLOOR = 4` no campaign match panicked in either
room (Phase A found onset in 2–11% of *seminar* matches at floor 4). Forced
to floor 2 with total, permanent collapse (depth 1 for the rest of the
match), the kind room panicked in 0.25 of matches and played 3.88 plies per
match at depth 1 — and every outcome column stayed byte-identical. The
carrier works as ruled: collapse changes what a piece *sees*, so it can only
register through a flipped verdict, and the kind room's verdicts (trust ≈ 96)
do not turn on private depth. The cruel room, where a flipped verdict would
cost something, never reaches the onset condition because its pieces leave
or are captured before four of them read danger together. Nothing here can
rank a collapse or decay value; both knobs stay 0.

### D217 loneliness → stay term: structural zero (wrong room)

The Phase B grief finding again. Lonely evaluations happen only in the kind
room (0.88 per match; affinity ≥ 50 is dense there and every loss orphans
someone) and that room never deserts: with the stay attachment weight
driven to **zero** the supportive rows are still byte-identical to control
— the D145 attachment term is not what keeps a trusted piece on the board.
The cruel room, whose pieces do leave, holds no bonds ≥ 50 to lose, so the
predicate never fires there. `LONELINESS_STAY_PENALTY_PERMILLE` stays 0;
the term can only be priced in a room that both bonds and deserts (a
middling style at a gentler opponent tier, or a volatile leader), which no
current sweep cell is.

### D217 relief → morning lift: structural zero at the D207 baseline

Two populations that do not overlap. Relief fires only in the kind room
(0.38 per match; 0 in eight tyrannical matches — a cruel room's pieces do
not come back down from high capture risk, they are captured), and the
morning lift reaches only pieces **below** `MORNING_LIFT_TRUST_BASELINE =
0` — of which the kind room has none at any boundary (boundary minima 40,
60, 80, 90, 94, 94, 90, 100 across the eight matches; the cruel room has
13–16 below zero at every boundary). So at the D207 baseline the relief
term has a trigger with no recipient and a recipient with no trigger, and
`RELIEF_LIFT_*` at 1000/1000 is byte-identical to control.

Raising the baseline to 100 (a D207 change, not a Phase C knob) makes the
seam plainly live: tyrannical trust_final −33.4 → −20.5, win 50 → 68.8, LI
−0.2 → 10.3, and relief then fires 0.63 per cruel-room match because the
changed trust trajectory changes the play. That is the ADR 0075 warning in
numbers — the lift is leader-reachable and, once it reaches the cruel room,
it pays the cruel room. Both relief knobs stay 0; the baseline question is
D207's, and any nonzero relief default must be measured against the
exploit tier at whatever baseline D207 rules.

## D215 pride → refusal threshold — the seminar grid

The carrier is `refusalThreshold += trunc(max(0, selfAppraisal) × scale /
1000)`, where the base threshold is `−3 + (100 − T_i) × 0.03` — about
`−3..+3` in perceived-value (pawn) units — and `selfAppraisal` is a permille
difference from the role expectation, `−1000..1000`. So the scale is not a
percentage of anything: appraisal 125 at scale 10 adds `+1`; at scale 50 it
adds `+6`, already past the top of the range the base threshold can reach.

### What the grid saw

Three distinct plays, not five. `playDigest` is `bb5e0a…` at scale 0,
`5522b7…` at 10, and `90898b…` at 50, 100 **and** 250 — the last three are
the same run, byte for byte. Every priced piece with a positive appraisal
sits at 125–253‰ (supportive 125, tyrannical 166 mean, volatile 253, steady
42 mean with one positive), so at scale 50 each already clears the threshold
by +2 to +12 pawns and refuses nothing it would not also refuse at 250. The
knob's whole graded region on this pool is roughly `1..40`; the Phase C
design's nominal ballpark (250) is pure saturation.

Who is priced: 2–9 pieces per style out of ~380 records — the draft
settlements are rare (Phase A found pride naming at floor 100‰ in 1–9 pieces
per style) — and of those, 0–4 carry a positive appraisal. Servant and
random price 9 and 5 pieces respectively and **none** positive, yet their
play still moves, because the seminar pool is shared: a proud piece on one
roster changes the matches every other commander plays afterwards. That
cross-contamination is the seminar harness's divergence noise, and it is the
same order as the effect.

| style | scale | priced | positive | mean appraisal ‰ | refusals | refusal rate | override rate | desertions | quiet-quit | trust_final | win | LI |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| servant | 0 | 0 | 0 | — | 70273 | 0.5192 | 0.0035 | 0.659 | 0.0930 | −19.98 | 54.30 | 6.22 |
| servant | 10 | 9 | 0 | −117 | 68193 | 0.5036 | 0.0035 | 0.578 | 0.0939 | −18.49 | 56.12 | 7.42 |
| servant | 50 = 100 = 250 | 9 | 0 | −114 | 66678 | 0.5192 | 0.0040 | 0.557 | 0.0979 | −17.53 | 54.17 | 7.18 |
| supportive | 0 | 0 | 0 | — | 31171 | 0.2524 | 0.0001 | 0.120 | 0.1196 | 47.40 | 57.68 | 34.66 |
| supportive | 10 | 4 | 1 | 125 | 34927 | 0.2696 | 0.0002 | 0.133 | 0.1184 | 47.98 | 54.43 | 33.88 |
| supportive | 50 = 100 = 250 | 4 | 1 | 125 | 28071 | 0.2158 | 0.0001 | 0.104 | 0.1132 | 49.94 | 58.59 | 36.01 |
| tyrannical | 0 | 0 | 0 | — | 23273 | 0.0028 | 0.0075 | 0.219 | 0.0440 | −22.63 | 58.59 | 7.32 |
| tyrannical | 10 | 4 | 4 | 166 | 21817 | 0.0030 | 0.0069 | 0.177 | 0.0437 | −23.11 | 60.55 | 7.76 |
| tyrannical | 50 = 100 = 250 | 4 | 4 | 166 | 23156 | 0.0022 | 0.0070 | 0.161 | 0.0439 | −22.17 | 58.07 | 7.39 |
| volatile | 0 | 0 | 0 | — | 45179 | 0.3533 | 0.0071 | 0.326 | 0.0592 | −20.11 | 44.27 | 3.87 |
| volatile | 10 | 2 | 2 | 253 | 44874 | 0.3517 | 0.0073 | 0.357 | 0.0602 | −20.18 | 42.84 | 3.45 |
| volatile | 50 = 100 = 250 | 2 | 2 | 253 | 41750 | 0.3490 | 0.0074 | 0.349 | 0.0600 | −20.60 | 44.27 | 3.71 |
| random | 0 | 0 | 0 | — | 45808 | 0.3975 | 0.0053 | 0.456 | 0.0671 | −20.33 | 42.45 | 3.06 |
| random | 10 | 5 | 0 | 0 | 45488 | 0.3867 | 0.0055 | 0.435 | 0.0663 | −20.36 | 43.62 | 3.46 |
| random | 50 = 100 = 250 | 5 | 0 | 0 | 43636 | 0.3942 | 0.0052 | 0.461 | 0.0663 | −20.44 | 42.97 | 3.22 |
| steady | 0 | 0 | 0 | — | 45882 | 0.3581 | 0.0071 | 0.326 | 0.0597 | −21.06 | 42.71 | 3.03 |
| steady | 10 | 6 | 1 | 42 | 40163 | 0.3654 | 0.0079 | 0.289 | 0.0637 | −20.94 | 42.45 | 3.09 |
| steady | 50 = 100 = 250 | 6 | 1 | 42 | 42505 | 0.3609 | 0.0077 | 0.268 | 0.0638 | −21.32 | 41.93 | 2.79 |

Refusals are own-side refusal events over 384 records; rates, desertions,
trust, win and LI are per-commander-match means; "priced" and "positive" are
pieces in the style's pool with a `selfAppraisal` written / written `> 0`.
Pride naming at the ruled floor (`ema=250, floor=100`) is unchanged across
the grid (servant 8→9, others identical): the carrier does not feed back
into who gets priced.

### Reading

- **Live and play-sensitive**, as designed: one to four proud pieces per
  style move every outcome column, and the effect is not monotone in the
  scale for any style (supportive refusals 31171 → 34927 → 28071; tyrannical
  win 58.6 → 60.5 → 58.1). With a single seed and this few carriers, the
  sign of each column is the seed's, not the mechanism's.
- **The direction is right where it can be read.** The cruel room is the one
  whose priced pieces are all proud (4 of 4 at 166‰: the tyrant's survivors
  clear high), and its refusal rate does not rise with pride — 0.0028 →
  0.0030 → 0.0022 — because a piece at trust −100 has a base threshold of
  +3 already and pride can only lift it further out of reach of anything the
  leader asks. Pride does not make the cruel room *more* obedient by the
  numbers either; it changes which pieces desert (0.219 → 0.161). In the
  kind room the one proud piece moves LI −0.8 to +1.4 and refusals −10% to
  +12% depending on the scale, which is the pool-divergence band, not a
  pride reading.
- **The grid bracket was wrong and the correction is documented.** Anything
  ≥ 50 is a single saturated regime; a recognition-grade default would have
  to live in `1..40`, where one grid point (10) exists. That is not enough to
  rank a value.

**Ruling proposed: `PRIDE_REFUSAL_SCALE` stays 0.** The carrier is proven
live and its saturation edge is measured (≈ 40 on this pool's appraisals);
what is not measured is a value inside the graded region that separates
rooms in a direction the mechanism owns rather than the seed. Pricing it
needs (a) a second seed and (b) a fine grid `{5, 10, 20, 40}` — about 10
Batch shard-hours each at this shape — and, because it is a play change,
the ADR 0075 exploit-tier rerun (the seminar fisher/farmer/tanker) at the
chosen value before it can go live. Nothing here argues for a nonzero
default ahead of that.

## Reading for the rulings

- Awe, panic, loneliness, relief: **structural zeros on the campaign
  harness in the current world**, each for a stated reason (no heroism
  under the fake engine; no cruel-room onset at floor 4; bonds only where
  nobody deserts; recipients only where nobody is relieved). Their knobs
  stay 0 as measured zeros, not as unpriced ones. Each names the world change
  that would make it priceable: a Lozza run (awe), a room that bonds *and*
  deserts (loneliness), a D207 baseline ruling (relief), and either a lower
  onset floor or a longer-lived cruel room (panic).
- Pride: **live, play-sensitive, non-monotone at one seed, saturated at
  scale ≥ 50.** Stays 0 pending a second seed, a fine grid inside `1..40`,
  and the exploit-tier rerun. The design's nominal 250 is withdrawn as a
  ballpark: on this pool's appraisals (125–253‰) it is a +30 to +60 pawn
  threshold, i.e. "a proud piece never refuses".
