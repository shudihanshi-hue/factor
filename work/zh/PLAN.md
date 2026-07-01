# zh 汉化包 — 翻译规划与待办表单（2026-07-01）

## 一、当前架构诊断结论

### 1.1 两套目录结构的真相
| 结构 | 是否「活」 | 加载方式 | 说明 |
|---|---|---|---|
| **平铺目录** `work/zh/{core,basis,handbook,...}/*.factor` | ✅ **活的**（真正生效） | `zh.factor` 用 `require` 加载 `zh.*` vocab | 这是中文文档的实际来源。所有 `IN: zh.*`，article id 带 `-zh` 后缀。 |
| **`help/` 镜像目录** `work/zh/help/**/*.factor` | ⚠️ **大部分是死的** | 仅 4 个被 `zh.factor` 用 `run-file` 显式加载 | 见下表 |

### 1.2 `zh.factor` 实际 `run-file` 的 help/ 文件（仅这 4 个是活的）
- `help/help.factor`（`IN: zh`，help 系统核心实现副本，UI 串已译）
- `help/help-zh.factor`（`IN: zh`，约 40 个中文 ARTICLE 编排入口）✅ 完整
- `help/help-zh-docs.factor`（`IN: zh`，标记元素 HELP 文档）✅ 完整
- `help/home/home-docs.factor`（`IN: help.home`，首页 ARTICLE）✅ 完整

### 1.3 `work/zh/help/` 下**未被加载的死文件**（覆盖式镜像，原始英文 id）
> 经运行时验证：`"handbook"`→`Factor handbook`（英文）、`"tour"`→`Guided tour of Factor`（英文）。
> 这些文件**从未生效**，是冗余遗留。其对应的中文已在平铺 `zh.*` 包中实现。
- `help/handbook/handbook.factor`（死）
- `help/tour/tour.factor`（死，且第73行混入俄语残留词「просто」）
- `help/cookbook/cookbook.factor`（死）
- `help/topics/topics.factor` + `topics-docs.factor`（死）
- `help/vocabs/vocabs.factor` + `vocabs-docs.factor`（死）
- `help/syntax/syntax.factor`（死）
- `help/markup/markup.factor`（死）
- `help/stylesheet/stylesheet.factor`（死）
- `help/lint/lint.factor` + `lint-docs.factor`（死）
- `help/crossref/crossref.factor` + `crossref-docs.factor`（死）
- `help/search/search.factor`（死）
- `help/definitions/definitions.factor`（死）
- `help/html/html.factor`（死）
- 各 `*-tests.factor`（死，测试副本）

## 二、待汉化 / 补全文件表单

### A 类：真实缺口（活文件，必须补全）— 高优先级
| # | 文件 | 问题 | 原版对照 |
|---|---|---|---|
| A1 | `help/apropos/apropos-docs.factor` | **空占位**（仅 1 行 USING），缺少 `HELP: apropos` + `TIP:` | `basis/help/apropos/apropos-docs.factor` |

### B 类：死文件中的真实翻译成果（可回收利用）— 中优先级
> 这些文件虽当前未被加载，但里面已有高质量中文翻译。若希望「左侧目录」对 `handbook`/`tour`/`cookbook`/`topics`/`vocabs`/`markup`/`lint`/`crossref` 等原始英文 id 也显示中文标题，需要让 `zh.factor` 加载它们（或修正一处 bug 让其生效）。需要用户决策。

| # | 文件 | 现状 | 建议 |
|---|---|---|---|
| B1 | `help/handbook/handbook.factor` | 完整中文覆盖式（原始 id） | 决策：是否启用覆盖式（让 Factor 官方帮助浏览器左侧目录全中文） |
| B2 | `help/tour/tour.factor` | 完整中文，**第73行俄语残留词需修正** | 启用前必须修掉俄语词 |
| B3 | `help/cookbook/cookbook.factor` | 完整中文覆盖式 | 同 B1 决策 |
| B4 | `help/topics/topics-docs.factor` | 完整中文 | 同 B1 决策 |
| B5 | `help/vocabs/vocabs-docs.factor` | 完整中文 | 同 B1 决策 |
| B6 | `help/markup/`、`lint/lint-docs`、`crossref/crossref-docs` | 完整中文 | 同 B1 决策 |

### C 类：排除名单（用户明确要求不动）
- ❌ `basis/ui/ui.factor`、`basis/ui-tools/ui-tools.factor`（UI 框架/工具）
- ❌ `core/alien/alien.factor`（FFI）—— 注：此文件当前为空壳/排除，保持不动
- ❌ `cookbook/cookbook.factor`（烹饪书）—— 注：平铺 `zh.cookbook` 已翻译，排除名单指 `help/cookbook` 覆盖式副本，按规则不动
- ❌ 任何 I/O 临时文档

### D 类：完成度验证（无需翻译，仅记录）
- ✅ `core/` 全部 17 个文件：fry, memoize, syntax, kernel, sequences, combinators, short-circuit, effects, continuuations, destructors, locals, macros, namespaces, parser, stack-checker, vocabs, words —— **全部完整**
- ✅ 平铺入门文档：handbook, tour, tutorial, cookbook（`zh.*` 版）—— **全部完整**
- ✅ `basis/threads`、`tools/test`、`ui/tools/browser` —— **完整**

## 三、关键决策点（需用户确认）

1. **A1 必做**：补全 `help/apropos/apropos-docs.factor` 的空占位。
2. **B 类死文件如何处理？** 有两个方案：
   - **方案 1（保守·推荐）**：不启用覆盖式，保持现有「`zh.*` 平铺包 + `{ $content }` 映射」架构。B 类死文件保持原样（仅修掉 B2 的俄语 bug 防污染）。→ 改动最小，零风险。
   - **方案 2（激进）**：在 `zh.factor` 末尾 `run-file` 这批死文件，让原始英文 id（`handbook`/`tour`/`cookbook`...）的左侧目录也变中文。→ 目录全中文，但可能与官方定义产生覆盖冲突风险，需逐个测试 reload。
3. **是否清理冗余死文件？** `help/` 下未被加载的纯英文实现副本（`markup/markup.factor`、`html/html.factor` 等）是否删除以减少混乱？
