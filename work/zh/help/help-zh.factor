! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! Factor 帮助系统中文本地化包 — 主入口
! 非侵入式设计：所有命名空间使用 zh.* 前缀，
! 不会覆盖原有 help.* 命名空间中的任何定义。
!
! 使用方法：
!   "zh" load
!   然后原有的 help 系统将可以访问中文翻译的文档。
!
USING: zh.handbook zh.cookbook zh.tour zh.tutorial
zh.home zh.tips zh.topics zh.vocabs
zh.syntax zh.markup zh.stylesheet
zh.lint zh.lint.checks zh.crossref
zh.apropos zh.search zh.definitions
zh.core.syntax zh.core.kernel
zh.core.combinators zh.core.combinators.short-circuit
zh.core.sequences
zh.core.effects zh.core.stack-checker
zh.core.words zh.core.locals
zh.core.namespaces zh.core.fry
zh.core.continuations zh.core.destructors
zh.core.memoize zh.core.parser
zh.core.macros zh.core.alien
zh.core.vocabs
zh.basis.threads zh.basis.ui zh.basis.ui-tools
zh.tools.test
zh.html zh.help zh.home zh.tips zh.topics zh.vocabs
zh.crossref zh.apropos zh.lint zh.lint.checks
zh.markup zh.syntax ;
IN: zh

ARTICLE: "zh" "Factor 帮助系统中文本地化"
"这是 Factor 编程语言官方帮助系统的中文本地化包。"
$nl
"本词汇库（vocabulary）提供了 Factor 帮助系统中核心文档的完整中文翻译，"
"包括手册、食谱、导览、教程以及各类参考文章。"
$nl
"翻译原则："
{ $list
    "保留所有 Factor 代码和数据结构标记（例如 " { $snippet "{ $values ... }" } "、" { $snippet "{ $description ... }" } "）的原样。"
    "仅翻译标签内部的纯文本说明内容。"
    "栈效果声明（Stack Effect）中的变量名原则上不翻译。"
    "高度学术化的术语在翻译后以括号注明英文原文，例如：" { $emphasis "组合子（combinator）" } "。"
    "命名空间约定：所有中文文档使用 " { $snippet "zh.*" } " 层次结构。"
}
{ $heading "当前翻译覆盖范围" }
{ $subsections
    "zh-handbook"
    "zh-cookbook"
    "zh-tour"
    "zh-tutorial"
    "zh-tips"
    "zh-element-types"
}
{ $heading "核心语言参考（中文）" }
{ $subsections
    "zh-core-syntax"
    "zh-core-kernel"
    "zh-core-combinators"
    "zh-core-sequences"
}
{ $heading "系统与工具（中文）" }
{ $subsections
    "zh-basis-threads"
    "zh-tools-test"
}
{ $heading "词汇表索引" }
{ $subsections
    "zh-topics"
    "zh-vocabs"
    "zh-syntax"
    "zh-markup"
    "zh-stylesheet"
    "zh-lint"
    "zh-crossref"
    "zh-apropos"
    "zh-search"
    "zh-definitions"
}
{ $heading "帮助系统核心（中文）" }
{ $subsections
    "zh-help"
    "zh-home"
    "zh-tips"
    "zh-apropos"
    "zh-lint"
    "zh-crossref"
    "zh-markup"
    "zh-syntax"
}
{ $heading "HTML 导出（中文）" }
{ $subsections
    "zh-html"
} ;

ARTICLE: "zh-browsing" "浏览中文文档"
"以下是浏览中文文档的主要入口："
{ $subsections
    "zh-handbook"
    "zh-cookbook"
    "zh-tour"
    "zh-tutorial"
} ;

ARTICLE: "zh-handbook" "Factor 手册 (Factor handbook)"
{ $content "handbook-zh" } ;

ARTICLE: "zh-cookbook" "Factor 食谱 (Factor cookbook)"
{ $content "cookbook-zh" } ;

ARTICLE: "zh-tour" "Factor 导览 (Guided tour of Factor)"
{ $content "tour-zh" } ;

ARTICLE: "zh-tutorial" "你的第一个程序 (Your first program)"
{ $content "first-program-zh" } ;

ARTICLE: "zh-tips" "每日提示 (Tips of the day)"
{ $content "tips-of-the-day-zh" } ;

ARTICLE: "zh-element-types" "标记元素类型 (Element types)"
{ $content "element-types-zh" } ;

ARTICLE: "zh-core-syntax" "语法 (Syntax)"
{ $content "syntax" } ;

ARTICLE: "zh-core-kernel" "栈操作词 (Shuffle words)"
{ $content "shuffle-words" } ;

ARTICLE: "zh-core-combinators" "数据流组合子 (Dataflow combinators)"
{ $content "dataflow-combinators" } ;

ARTICLE: "zh-core-sequences" "序列操作 (Sequence operations)"
{ $content "sequences" } ;

ARTICLE: "zh-basis-threads" "协作线程 (Co-operative threads)"
{ $content "threads" } ;

ARTICLE: "zh-tools-test" "单元测试 (Unit testing)"
{ $content "tools.test" } ;

ARTICLE: "zh-help" "帮助系统核心 (Help system)"
{ $content "help" } ;

ARTICLE: "zh-home" "帮助首页 (Factor documentation)"
{ $content "home" } ;

ARTICLE: "zh-apropos" "近似搜索 (Apropos)"
{ $content "apropos" } ;

ARTICLE: "zh-search" "帮助搜索 (Search)"
{ $content "search" } ;

ARTICLE: "zh-lint" "帮助检查工具 (Help lint tool)"
{ $content "lint" } ;

ARTICLE: "zh-crossref" "帮助文章交叉引用 (Cross-referencing)"
{ $content "crossref" } ;

ARTICLE: "zh-markup" "帮助标记语言 (Help markup language)"
{ $content "markup" } ;

ARTICLE: "zh-syntax" "解析器 (The parser)"
{ $content "syntax" } ;

ARTICLE: "zh-html" "转换为 HTML (Converting help to HTML)"
{ $content "html" } ;

ARTICLE: "zh-io" "输入与输出 (Input and output)"
{ $content "io" } ;

ARTICLE: "zh-ui" "UI 框架 (UI framework)"
{ $content "ui" } ;

ARTICLE: "zh-implementation" "实现 (The implementation)"
{ $content "handbook-system-reference" } ;

ARTICLE: "zh-devtools" "开发者工具 (Developer tools)"
{ $content "handbook-tools-reference" } ;

ARTICLE: "zh-ui-tools" "UI 开发者工具 (UI developer tools)"
{ $content "ui-tools" } ;

ARTICLE: "zh-alien" "C 语言库接口 (C library interface)"
{ $content "alien" } ;

ARTICLE: "zh-vocabs" "库 (Libraries)"
{ $content "handbook-library-reference" } ;

ARTICLE: "zh-language" "语言 (The language)"
{ $content "handbook-language-reference" } ;

ARTICLE: "zh-vocab-index" "词汇索引 (Vocabulary index)"
{ $content "vocab-index" } ;

ARTICLE: "zh-article-index" "文章索引 (Article index)"
{ $content "article-index" } ;

ARTICLE: "zh-primitive-index" "原语索引 (Primitive index)"
{ $content "primitive-index" } ;

ARTICLE: "zh-error-index" "错误索引 (Error index)"
{ $content "error-index" } ;

ARTICLE: "zh-class-index" "类索引 (Class index)"
{ $content "class-index" } ;

! ===== 语言参考章节映射 =====

ARTICLE: "zh-evaluator" "栈机器模型 (Stack machine model)"
{ $content "evaluator-zh" } ;

ARTICLE: "zh-effects" "栈效果声明 (Stack Effect Declarations)"
{ $content "effects-zh" } ;

ARTICLE: "zh-inference" "栈效果检查 (Stack Effect Checking)"
{ $content "inference-zh" } ;

ARTICLE: "zh-shuffle-words" "栈操作词 (Shuffle words)"
{ $content "shuffle-words" } ;

ARTICLE: "zh-combinators" "组合子 (Combinators)"
{ $content "combinators" } ;

ARTICLE: "zh-threads" "协作线程 (Co-operative threads)"
{ $content "threads" } ;

ARTICLE: "zh-locals" "词法局部变量 (Lexical Variables)"
{ $content "locals-zh" } ;

ARTICLE: "zh-namespaces" "动态变量 (Dynamic Variables)"
{ $content "namespaces-zh" } ;

ARTICLE: "zh-namespaces-global" "全局变量 (Global variables)"
{ $content "namespaces-global-zh" } ;

ARTICLE: "zh-fry" "煎化引用 (Fried Quotations)"
{ $content "fry-zh" } ;

ARTICLE: "zh-objects" "对象 (Objects)"
{ $content "objects-zh" } ;

ARTICLE: "zh-errors" "异常处理 (Exception Handling)"
{ $content "errors-zh" } ;

ARTICLE: "zh-destructors" "确定性资源释放 (Deterministic Resource Disposal)"
{ $content "destructors-zh" } ;

ARTICLE: "zh-memoize" "记忆化 (Memoization)"
{ $content "memoize-zh" } ;

ARTICLE: "zh-parsing-words" "解析词 (Parsing words)"
{ $content "parsing-words-zh" } ;

ARTICLE: "zh-macros" "宏 (Macros)"
{ $content "macros-zh" } ;

ARTICLE: "zh-continuations" "续延 (Continuations)"
{ $content "continuations-zh" } ;

ARTICLE: "zh-booleans" "布尔值 (Booleans)"
{ $content "booleans" } ;

ARTICLE: "zh-numbers" "数字 (Numbers)"
{ $content "numbers-zh" } ;

ARTICLE: "zh-collections" "集合 (Collections)"
{ $content "collections-zh" } ;

ARTICLE: "zh-words" "单词与词汇 (Words)"
{ $content "words-zh" } ;

! ===== 结束语言参考章节映射 =====

ABOUT: "zh"
