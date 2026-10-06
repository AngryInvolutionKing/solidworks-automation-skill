#!/usr/bin/env bash
# Codex Cloud environment setup (Linux container: no Windows, no COM, no SolidWorks).
#
# Installs only the platform-neutral dependencies. The Windows-only ones (pywin32,
# comtypes) carry `sys_platform == 'win32'` markers in pyproject.toml, so they are
# skipped here on purpose.
#
# Do NOT use `pip install -r requirements.txt`: that file pins pywin32/comtypes
# unconditionally and therefore always fails on Linux.
set -euo pipefail

cd "$(dirname "$0")/.."

python3 -m pip install --quiet --upgrade pip
python3 -m pip install --quiet \
  "mcp>=1.27,<2" \
  "pydantic>=2.0" \
  "jsonschema>=4.20,<5" \
  "pytest>=8"

# Cheap import smoke: mirror the import style of the cross-platform tests, which put
# `scripts/` on sys.path and import `core.*` as top-level packages.
# Do NOT import `scripts.core.execution` here: that executes scripts/__init__.py, which
# eagerly imports the COM modules (sw_connect -> sw_preflight) and always raises
# DependencyInstallDeclined on Linux.
python3 - <<'PY'
import sys
sys.path.insert(0, "scripts")
import core.capability, core.execution, core.recovery, core.state, core.trace, core.verification  # noqa: F401
print("setup ok: execution core importable (COM-free path)")
PY

echo "setup ok: run 'bash cloud/run-tests.sh' for the deterministic cross-platform suite"
