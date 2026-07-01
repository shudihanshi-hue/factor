! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! Factor 帮助系统核心文档 — 中文翻译
! 原始文件: D:\factor\basis\help\help-docs.factor
!
! 本文件包含帮助系统中所有标记元素（markup element）的中文文档。
!
USING: arrays help help.crossref help.lint help.markup
help.stylesheet help.syntax help.topics io kernel math
prettyprint quotations see sequences strings summary vocabs
words ;
IN: zh

ARTICLE: "printing-elements-zh" "打印标记元素"
"在编写文档时，能够打印标记元素以进行测试是很有用的。字符串或元素数组形式的标记元素以明显的方式打印。形如 " { $snippet "{ $directive content... }" } " 的标记元素通过执行 " { $snippet "$directive" } " 字来打印，其内容位于栈上。"
{ $subsections
    print-element
    print-content
} ;

ARTICLE: "span-elements-zh" "行内元素（Span elements）"
{ $subsections
    $emphasis
    $strong
    $link
    $vocab-link
    $snippet
    $slot
    $url
} ;

ARTICLE: "block-elements-zh" "块元素（Block elements）"
"段落分隔："
{ $subsections $nl }
"字文档的标准标题："
{ $subsections
    $values
    $description
    $class-description
    $error-description
    $var-description
    $contract
    $examples
    $warning
    $notes
    $side-effects
    $errors
    $see-also
}
"在 " { $link $values } " 形式中使用的元素："
{ $subsections
    $instance
    $maybe
    $or
    $quotation
    $sequence
}
"样板段落："
{ $subsections
    $low-level-note
    $io-error
}
"一些附加元素："
{ $subsections
    $code
    $curious
    $example
    $heading
    $links
    $list
    $markup-example
    $references
    $see
    $subsection
    $table
} ;

ARTICLE: "markup-utils-zh" "标记元素工具"
"用于辅助定义新元素的实用字："
{ $subsections
    simple-element
    ($span)
    ($block)
} ;

ARTICLE: "element-types-zh" "元素类型"
"标记元素可以分为两大类：块元素（block elements）和行内元素（span elements）。块元素前后都有换行缩进，而行内元素则随段落文本流动。"
{ $subsections
    "span-elements-zh"
    "block-elements-zh"
    "markup-utils-zh"
} ;

ARTICLE: "writing-help-zh" "编写文档"
"按照约定，文档写在名称以 " { $snippet "-docs.factor" } " 结尾的文件中。词汇表文档应该放在与词汇表源代码相同的目录中；参见 " { $link "vocabs.loader" } "。"
$nl
"使用一对解析字来定义独立文章以及将文档与字关联起来："
{ $subsections
    POSTPONE: ARTICLE:
    POSTPONE: HELP:
}
"还有一个解析字用于定义词汇表的主帮助文章："
{ $subsections POSTPONE: ABOUT: }
"在这两种情况下，" { $emphasis "内容（content）" } " 都是一个 " { $emphasis "标记元素（markup element）" } "，它是一个递归结构，取以下形式之一："
{ $list
    { "一个字符串，" }
    { "一个标记元素数组，" }
    { "或一个形如 " { $snippet "{ $directive content... }" } " 的数组，其中 " { $snippet "$directive" } " 是一个名称以 " { $snippet "$" } " 开头的标记字，" { $snippet "content..." } " 则是一系列标记元素" }
}
"以下是帮助标记语言的更正式的模式："
{ $code
"<element> ::== <string> | <simple-element> | <fancy-element>"
"<simple-element> ::== { <element>* }"
"<fancy-element> ::== { <type> <element> }"
}
{ $subsections
    "element-types-zh"
    "printing-elements-zh"
}
"相关字可以交叉引用："
{ $subsections related-words }
{ $see-also "help.lint" } ;

ARTICLE: "help-impl-zh" "帮助系统实现"
"帮助主题协议（help topic protocol）："
{ $subsections
    article-name
    article-title
    article-content
    article-parent
    set-article-parent
}
"可以自动生成样板字帮助（例如，槽访问器帮助）："
{ $subsections
    word-help
    word-help*
}
"帮助文章实现："
{ $subsections
    lookup-article
    articles
}
"链接（links）："
{ $subsections
    link
    >link
}
"遍历标记元素树的工具："
{ $subsections
    elements
    collect-elements
}
"链接和 " { $link article } " 实例实现了定义协议；参见 " { $link "definitions" } "。" ;

ARTICLE: "help-zh" "帮助系统"
"帮助系统维护以简单标记语言编写的文档，以及交叉引用和搜索功能。文档可以以独立的 " { $emphasis "文章（articles）" } " 形式存在，也可以与字关联。"
{ $subsections
    "browsing-help-zh"
    "writing-help-zh"
    "help-zh-lint"
    "tips-of-the-day-zh"
    "help-impl-zh"
} ;

ABOUT: "help-zh"

! ===== 标记元素 HELP: 文档 =====

HELP: $title
{ $values { "topic" "一个帮助文章名称或一个字（word）" } }
{ $description "根据 " { $snippet "topic" } " 的类型，打印帮助文章的标题或字的 " { $link summary } "。" } ;

HELP: print-topic
{ $values { "topic" "一个文章名称或一个字（word）" } }
{ $description
    "在 " { $link output-stream } " 上显示一个帮助主题。"
} ;

HELP: help
{ $values { "topic" "一个文章名称或一个字（word）" } }
{ $description
    "显示一个帮助主题。"
} ;

HELP: :help
{ $description "显示最近一次错误的文档。" } ;

HELP: $subsection
{ $values { "element" "一个形如 " { $snippet "{ topic }" } " 的标记元素" } }
{ $description "打印一个大型可点击链接，指向由 " { $snippet "element" } " 中第一项命名的帮助主题。链接会连同其关联的定义图标一起打印。" }
{ $examples
    { $markup-example { $subsection "sequences" } }
    { $markup-example { $subsection nth } }
    { $markup-example { $subsection each } }
} ;

HELP: $subsections
{ $values { "children" "一个包含一个或多个 " { $link topic } " 的 " { $link sequence } "，对于帮助文章则为其字符串名称。" } }
{ $description "为 " { $snippet "children" } " 中列出的每个帮助主题打印一个大型可点击链接。链接会连同其关联的定义图标一起打印。" }
{ $examples
    { $markup-example { $subsections "sequences" nth each } }
} ;

HELP: $heading
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "将一个标记元素（通常是一个字符串）以 " { $link heading-style } " 样式作为块元素打印。" }
{ $examples
    { $markup-example { $heading "尚待发现之物" } }
} ;

HELP: $code
{ $values { "element" "一个形如 " { $snippet "{ string... }" } " 的标记元素" } }
{ $description "打印代码示例，如许多帮助文章中所示。标记元素必须是字符串数组。" }
{ $notes
    "如果输出流支持，代码将变为可点击的，点击它会打开一个监听器窗口，在输入提示符处插入该文本。"
    $nl
    "如果你想同时显示代码和示例输出，请使用 " { $link $example } " 元素。"
}
{ $examples
    { $markup-example { $code "2 2 + ." } }
} ;

HELP: $nl
{ $values { "children" "未使用的参数" } }
{ $description "打印一个段落分隔。参数未被使用。" } ;

HELP: $snippet
{ $values { "children" "标记元素（markup elements）" } }
{ $description "打印一个关键字或其他值得注意的文本片段，例如类型或字的输入参数。要记录槽（slot）名称，请使用 " { $link $slot } "。" } ;

HELP: $slot
{ $values { "children" "标记元素（markup elements）" } }
{ $description "以与片段（snippet）相同的方式打印一个元组槽（tuple slot）名称。帮助工具可以检查是否存在同名的访问器（accessor）。" } ;

HELP: $description
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "打印大多数字的帮助页面上出现的\"描述\"子标题。" } ;

HELP: $contract
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "打印一个标题及其后的契约（contract），该契约出现在泛型字（generic word）的帮助页面上。每个泛型字都应该记录一个契约，规定调用者可以依赖的方法行为，而实现必须遵守。" }
{ $examples
    { $markup-example { $contract "此泛型字的方法必须始终崩溃。" } }
} ;

HELP: $examples
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "打印一个标题及其后的一些示例。字文档应包含示例，至少在字的用法并非完全显而易见时应如此。" }
{ $examples
    { $markup-example { $examples { $example "USING: math prettyprint ;" "2 2 + ." "4" } } }
} ;

HELP: $example
{ $values { "element" "一个形如 " { $snippet "{ inputs... output }" } " 的标记元素" } }
{ $description "打印一个带有示例输出的可点击示例。标记元素必须是字符串数组。除最后一个字符串外的所有字符串用换行符连接作为输入文本，最后一个字符串是输出。如果输出流支持，示例将变为可点击的，点击它会打开一个监听器窗口，在输入提示符处插入该输入文本。" }
{ $examples
    "输入文本必须包含正确的 " { $link POSTPONE: USING: } " 声明，而输出文本应该是输入文本执行时打印内容的字符串，而不是最终的栈内容或类似信息。因此以下是一个错误的示例："
    { $markup-example { $unchecked-example "2 2 +" "4" } }
    "然而以下是正确的："
    { $markup-example { $example "USING: math prettyprint ;" "2 2 + ." "4" } }
    "示例可以包含对 " { $link .s } " 的调用来显示多个输出值；约定是你可以假设在示例求值之前栈为空。"
}
{ $see-also $unchecked-example } ;

HELP: $warning
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "将元素打印在一个具有醒目样式的块中，以引起读者的注意。" }
{ $examples
    { $markup-example { $warning "不当使用本产品可能导致严重伤害或死亡。" } }
} ;

HELP: $link
{ $values { "element" "一个形如 " { $snippet "{ topic }" } " 的标记元素" } }
{ $description "打印一个指向帮助文章或字的链接。指向文章的链接应当是一个 " { $link string } "，否则链接必须指向一个 " { $link word } "。" }
{ $examples
    { $markup-example { $link "dlists" } }
    { $markup-example { $link + } }
} ;

HELP: $emphasis
{ $values { "children" "一个标记元素（markup element）" } }
{ $description "打印 " { $emphasis "强调" } " 文本。也称为斜体文本。" } ;

HELP: $strong
{ $values { "children" "一个标记元素（markup element）" } }
{ $description "打印 " { $strong "粗体" } " 文本。" } ;

HELP: $values
{ $values { "element" "一个标记元素对（pairs）的数组" } }
{ $description "打印每个字帮助页面上都会出现的参数和值的描述。对中的第一个元素是参数名，使用 " { $link $snippet } " 输出。其余部分可以是单个类字（class word）或一个元素。如果是类字 " { $snippet "class" } "，则被插入，如同它是 " { $snippet "{ $instance class }" } " 的简写一样。" }
{ $see-also $maybe $instance $quotation } ;

HELP: $instance
{ $values { "element" "一个形如 " { $snippet "{ class }" } " 的数组" } }
{ $description
    "产生文本 \"一个 " { $emphasis "class" } "\"或 \"某个 " { $emphasis "class" } "\"，取决于 " { $emphasis "class" } " 的第一个字母。"
}
{ $examples
    { $markup-example { $instance string } }
    { $markup-example { $instance integer } }
    { $markup-example { $instance f } }
} ;

HELP: $maybe
{ $values { "element" "一个形如 " { $snippet "{ class }" } " 的数组" } }
{ $description
    "产生文本 \"一个 " { $emphasis "class" } " 或 f\" 或 \"某个 " { $emphasis "class" } " 或 f\"，取决于 " { $emphasis "class" } " 的第一个字母。"
}
{ $examples
    { $markup-example { $maybe string } }
} ;

HELP: $quotation
{ $values { "element" "一个形如 " { $snippet "{ effect }" } " 的数组" } }
{ $description
    "产生文本 \"一个具有栈效果 " { $emphasis "effect" } " 的引用（quotation）\"。"
}
{ $examples
    { $markup-example { $quotation ( obj -- ) } }
} ;

HELP: $list
{ $values { "element" "一个标记元素（markup elements）数组" } }
{ $description "打印一个标记元素的带符号列表。" }
{ $notes
    "一个常见错误是，如果一个项由多个字符串组成，它会被拆分为多个项："
    { $markup-example
        { $list
            "第一项"
            "第二项 " { $emphasis "带有强调" }
        }
    }
    "修复方法很简单；只需将组成第二项的两个标记元素组合成一个标记元素："
    { $markup-example
        { $list
            "第一项"
            { "第二项 " { $emphasis "带有强调" } }
        }
    }
} ;

HELP: $errors
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "打印一些字的帮助页面上出现的\"错误\"子标题。本节应记录该字可能抛出的任何错误。" } ;

HELP: $side-effects
{ $values { "element" "一个形如 " { $snippet "{ string... }" } " 的标记元素" } }
{ $description "打印一个标题及其后的一个列表，列出被文档化的字所修改的输入值或变量。" } ;

HELP: $notes
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "打印一些字的帮助页面上出现的\"注释\"子标题。本节应记录使用技巧和陷阱。" } ;

HELP: $see
{ $values { "element" "一个形如 " { $snippet "{ word }" } " 的标记元素" } }
{ $description "通过调用 " { $link see } " 打印 " { $snippet "word" } " 的定义。" }
{ $examples
    { $markup-example { "这是一个字定义：" { $see reverse } } }
} ;

HELP: $curious
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "打印一个标题及其后的一个标记元素。" }
{ $notes "此元素类型用于 " { $link "handbook" } " 中类似于食谱风格的入门文章。" } ;

HELP: $references
{ $values { "element" "一个形如 " { $snippet "{ topic... }" } " 的标记元素" } }
{ $description "打印一个标题及其后的一系列链接。" }
{ $notes "此元素类型用于 " { $link "handbook" } " 中类似于食谱风格的入门文章。" } ;

HELP: $see-also
{ $values { "topics" "一个文章名称或字的序列" } }
{ $description "打印一个标题及其后的一系列链接。" }
{ $examples
    { $markup-example { $see-also "graphs" "dlists" } }
} ;

HELP: $table
{ $values { "element" "一个由标记元素数组组成的数组" } }
{ $description "打印一个表格，其中每行必须具有相同数量的列。" }
{ $examples
    { $markup-example
        { $table
            { "a" "b" "c" }
            { "d" "e" "f" }
        }
    }
} ;

HELP: $vocab-link
{ $values { "element" "一个字符串" } }
{ $description "打印一个指向词汇表文章的链接。" } ;

HELP: $markup-example
{ $values { "element" "一个标记元素（markup element）" } }
{ $description "打印一个可点击示例，展示 " { $snippet "element" } " 的美化打印源文本及其渲染后的输出。如果输出流支持，该示例将变为可点击的。" }
{ $examples
    { $markup-example { $markup-example { $emphasis "你好" } } }
} ;

HELP: $unchecked-example
{ $values { "element" object } }
{ $description "与 " { $link $example } " 相同，但 " { $link help-lint } " 会忽略其内容，不尝试运行代码或验证其输出。" } ;
