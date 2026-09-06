#!/bin/sh
set -eu

entrypoint="${KINGSANDI_ENTRYPOINT:-spot-entrypoint.sh}"
case "$entrypoint" in
  spot-entrypoint.sh|seminar-entrypoint.sh|census-entrypoint.sh) ;;
  *)
    echo "KINGSANDI_ENTRYPOINT must be spot-entrypoint.sh, seminar-entrypoint.sh, or census-entrypoint.sh." >&2
    exit 2
    ;;
esac

exec "/usr/local/bin/$entrypoint" "$@"
