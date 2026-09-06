#!/bin/sh
set -eu

: "${RUN_ID:?RUN_ID is required}"
: "${SEED:?SEED is required}"
: "${WEEKS:?WEEKS is required}"
: "${MATCHES_PER_WEEK:?MATCHES_PER_WEEK is required}"
: "${COMMANDERS:?COMMANDERS is required}"
: "${PRIDE_SCALES:?PRIDE_SCALES is required}"
: "${GIT_COMMIT_SHA:?GIT_COMMIT_SHA is required}"
: "${IMAGE_DIGEST:?IMAGE_DIGEST is required}"

shard_index="${AWS_BATCH_JOB_ARRAY_INDEX:-0}"
engine="${ENGINE:-fake}"
output_root="${OUTPUT_DIR:-/work/output}"

validate_positive_integer() {
  name="$1"
  value="$2"
  case "$value" in
    ''|*[!0-9]*|0) echo "$name must be a positive integer." >&2; exit 2 ;;
    *) ;;
  esac
}

validate_non_negative_integer() {
  name="$1"
  value="$2"
  case "$value" in
    ''|*[!0-9]*) echo "$name must be a non-negative integer." >&2; exit 2 ;;
    *) ;;
  esac
}

validate_integer() {
  name="$1"
  value="$2"
  case "$value" in
    ''|-) echo "$name must be an integer." >&2; exit 2 ;;
    -*)
      digits="${value#-}"
      case "$digits" in
        ''|*[!0-9]*) echo "$name must be an integer." >&2; exit 2 ;;
        *) ;;
      esac
      ;;
    *[!0-9]*) echo "$name must be an integer." >&2; exit 2 ;;
    *) ;;
  esac
}

validate_positive_integer WEEKS "$WEEKS"
validate_positive_integer MATCHES_PER_WEEK "$MATCHES_PER_WEEK"
validate_positive_integer COMMANDERS "$COMMANDERS"
validate_integer SEED "$SEED"

case "$shard_index" in
  ''|*[!0-9]*) echo 'AWS_BATCH_JOB_ARRAY_INDEX must be a non-negative integer.' >&2; exit 2 ;;
  *) ;;
esac

case "$engine" in
  fake|lozza|stockfish) ;;
  *) echo 'ENGINE must be fake, lozza, or stockfish.' >&2; exit 2 ;;
esac

scale_count=0
selected_scale=''
for scale in $PRIDE_SCALES; do
  validate_non_negative_integer PRIDE_SCALES "$scale"
  if [ "$scale_count" -eq "$shard_index" ]; then
    selected_scale="$scale"
  fi
  scale_count=$((scale_count + 1))
done

if [ "$scale_count" -eq 0 ] || [ "$shard_index" -ge "$scale_count" ]; then
  echo 'AWS_BATCH_JOB_ARRAY_INDEX is outside PRIDE_SCALES.' >&2
  exit 2
fi

run_dir="$output_root/campaigns/$RUN_ID"
census_dir="$run_dir/census"
census_path="$census_dir/census-scale-$selected_scale.json"
log_path="$census_dir/census-scale-$selected_scale.log"
manifest_path="$run_dir/manifest.json"
mkdir -p "$census_dir"
cd /app

pnpm exec tsx sim/emotionCensus.ts \
  "--seed=$SEED" \
  "--engine=$engine" \
  "--weeks=$WEEKS" \
  "--matches=$MATCHES_PER_WEEK" \
  "--commanders=$COMMANDERS" \
  "--pride-refusal-scale=$selected_scale" \
  "--out=$census_path" >"$log_path" 2>&1

write_manifest() {
  node >"$manifest_path.tmp" <<'NODE'
const required = [
  'RUN_ID',
  'SEED',
  'WEEKS',
  'MATCHES_PER_WEEK',
  'COMMANDERS',
  'PRIDE_SCALES',
  'GIT_COMMIT_SHA',
  'IMAGE_DIGEST',
];
for (const name of required) {
  if (!process.env[name]) {
    throw new Error(`Missing manifest provenance: ${name}`);
  }
}
const prideScales = process.env.PRIDE_SCALES.trim().split(/\s+/).map(Number);
const manifest = {
  runId: process.env.RUN_ID,
  seed: Number(process.env.SEED),
  weeks: Number(process.env.WEEKS),
  matchesPerWeek: Number(process.env.MATCHES_PER_WEEK),
  commanders: Number(process.env.COMMANDERS),
  engine: process.env.ENGINE || 'fake',
  prideScales,
  gitCommitSha: process.env.GIT_COMMIT_SHA,
  imageDigest: process.env.IMAGE_DIGEST,
};
process.stdout.write(`${JSON.stringify(manifest)}\n`);
NODE
  mv "$manifest_path.tmp" "$manifest_path"
}

if [ "$shard_index" -eq 0 ]; then
  write_manifest
fi

if [ -n "${S3_BUCKET:-}" ]; then
  : "${AWS_REGION:?AWS_REGION is required when S3_BUCKET is set}"
  export AWS_DEFAULT_REGION="$AWS_REGION"
  s3_root="s3://$S3_BUCKET/campaigns/$RUN_ID/census"
  aws s3 cp "$census_path" "$s3_root/census-scale-$selected_scale.json"
  aws s3 cp "$log_path" "$s3_root/census-scale-$selected_scale.log"
  if [ "$shard_index" -eq 0 ]; then
    aws s3 cp "$manifest_path" "s3://$S3_BUCKET/campaigns/$RUN_ID/manifest.json"
  fi
fi

echo "Census shard $shard_index for pride scale $selected_scale completed successfully."
