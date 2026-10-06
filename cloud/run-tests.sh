#!/usr/bin/env bash
# Deterministic, platform-neutral test subset.
#
# Runs on Linux (Codex Cloud) and on a plain local Python: no SolidWorks, no COM,
# no AutoCAD, no OCP. Expected result: 125 passed.
#
# A bare `pytest` does NOT work on Linux: ~26 modules fail during collection
# because they probe COM/AutoCAD via scripts/sw_preflight.py interactively.
set -euo pipefail

cd "$(dirname "$0")/.."

python3 -m pytest -q --no-header -p no:cacheprovider \
  tests/test_core_capability.py \
  tests/test_core_execution.py \
  tests/test_core_recovery.py \
  tests/test_core_state.py \
  tests/test_core_trace.py \
  tests/test_core_verification.py \
  tests/test_eval_baseline.py \
  tests/test_eval_metrics.py \
  tests/test_eval_runner.py
