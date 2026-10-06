# AGENTS.md

SolidWorks / CAD 自动化 skill + 本地 MCP server（Python）。**真机能力依赖 Windows + SolidWorks COM。**

## 云端（Linux 沙箱）与本地（Windows）的分工

| | 云端 Linux 容器 | 本地 Windows 主机 |
|---|---|---|
| Windows / COM | ❌ 没有 | ✅ 有 |
| SolidWorks / AutoCAD | ❌ 没装 | ✅ 装了 |
| 能做什么 | 纯逻辑代码、文档、写测试、审代码 | 真实建模、出图、测量、导出 |

Codex Cloud 环境跑在 Linux 容器里（默认 `universal` 镜像）：没有 Windows、没有 GUI、没有 SolidWorks。

## 云端环境里必须遵守的三条

1. **依赖用 `bash cloud/setup.sh` 装**。平台相关依赖（`pywin32` / `comtypes`）只在 `pyproject.toml` 里带
   `sys_platform == 'win32'` 标记；`requirements.txt` 把它们写成了无条件依赖，**`pip install -r requirements.txt` 在 Linux 上必然失败**。
2. **不要直接跑 `pytest`**。约 26 个测试模块在 Linux 上会在 collection 阶段报错（COM 预检会交互式提问、
   或依赖 AutoCAD / OCP / Windows 路径）。
3. **跨平台测试用 `bash cloud/run-tests.sh`**，它显式列出与平台无关的 6 个 core + 3 个 eval 测试文件
   （预期 `125 passed`）。
4. **不要 `import scripts.*`**。`scripts/__init__.py` 无条件导入 COM 模块（`sw_connect` → `sw_preflight`），
   在 Linux 上必然抛 `DependencyInstallDeclined`。core/eval 测试之所以能跑，是因为它们把 `scripts/`
   加进 `sys.path` 后以顶层包形式 `import core.*` / `evals.*`，绕开了包 `__init__`。云端冒烟测试也照此写。

## 只能在本地验的部分

- `tests/test_sw_*.py`、`tests/live_smoke_new_tools.py`、`tests/*_regression.py`
- `scripts/sw_*.py`（SolidWorks COM）、`scripts/acad_*.py`、`scripts/sw_addin_host*`
- 所有真机产物：本机 SolidWorks 是 **2025**，而 `references/capabilities.yaml` 声明的已验证版本是
  **2024 / 2026**。按该 skill 自己的规矩，未验证版本的能力**必须人工复核**，不能把"脚本没报错"当交付成功。

## 目录速览

- `scripts/core/` — 执行核心：`state` / `capability` / `verification` / `recovery` / `trace` / `execution`
- `scripts/design_spec.py`、`scripts/build_from_spec.py` — 规格建模与校验
- `scripts/sw_*.py` — SolidWorks COM；`scripts/headless_*` — 无 GUI 后端；`scripts/cad_*` — CAD Studio
- `tests/` — pytest 套件；`references/` — 规格与能力清单；`docs/` — 架构、审计、评测文档
- `cloud/setup.sh`、`cloud/run-tests.sh` — 云端环境初始化与可跑的测试子集

## 约定

- 别为了让测试变绿去改 `scripts/sw_preflight.py` 的交互式预检行为，也别在 `conftest.py` 里全局屏蔽它。
  平台不支持的测试就显式排除（见 `cloud/run-tests.sh`）。
- 改 `pyproject.toml` 的依赖时保留 `sys_platform == 'win32'` 标记，否则云端构建会挂。
