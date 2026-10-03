#!/usr/bin/env bash
# Run every Jarvis dyalogscript test suite in turn and report a summary.
# Exits 0 only if every suite passed, non-zero otherwise.
#
# Usage:
#   Tests/run-all.sh                 # run all suites
#   JARVIS_SOURCE=/path/Jarvis.dyalog Tests/run-all.sh   # test a specific source copy
# Each suite's run.apls loads Source/Jarvis.dyalog relative to itself (or $JARVIS_SOURCE),
# uses its own base port, and exits non-zero on failure.
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# locate dyalogscript: PATH, then $DYALOG/scriptbin, then a Dyalog install
DS="$(command -v dyalogscript || true)"
if [ -z "$DS" ]; then
  for d in "${DYALOG:-}/scriptbin" /opt/mdyalog/*/*/*/scriptbin /opt/dyalog*/scriptbin; do
    if [ -x "$d/dyalogscript" ]; then DS="$d/dyalogscript"; break; fi
  done
fi
if [ -z "$DS" ]; then
  echo "ERROR: dyalogscript not found (set PATH or \$DYALOG)" >&2
  exit 2
fi
echo "Using dyalogscript: $DS"

# suites to run, in order
suites="Core sessions Secure SSE WebSockets"

fail=0
failed_suites=""
for s in $suites; do
  if [ ! -f "$here/$s/run.apls" ]; then
    echo "SKIP $s (no run.apls)"
    continue
  fi
  echo ""
  echo "=================== $s ==================="
  if "$DS" "$here/$s/run.apls"; then
    echo "--- $s: PASSED"
  else
    echo "--- $s: FAILED"
    fail=1
    failed_suites="$failed_suites $s"
  fi
done

echo ""
echo "=========================================="
if [ "$fail" -eq 0 ]; then
  echo "All test suites passed."
else
  echo "FAILED suites:$failed_suites"
fi
exit "$fail"
