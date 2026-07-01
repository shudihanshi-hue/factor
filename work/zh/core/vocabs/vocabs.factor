! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 词汇库（Vocabularies）— 中文翻译
! 原始文件: D:\factor\core\vocabs\vocabs-docs.factor

USING: assocs compiler.units help.markup help.syntax strings
vocabs vocabs.loader words ;
IN: zh.core.vocabs

ARTICLE: "vocabularies-zh" "词汇库（Vocabularies）"
"一个 " { $emphasis "词汇库（vocabulary）" } " 是 " { $link "words" } " 的命名集合。词汇库在 " { $vocab-link "vocabs" } " 词汇中定义。"
$nl
"词汇库存储在全局哈希表中："
{ $subsections dictionary }
"词汇库构成一个类。"
{ $subsections
    vocab
    vocab?
}
"各种词汇库词被重载为接受 " { $emphasis "词汇库说明符（vocabulary specifier）" } "，它可以是一个命名词汇库的字符串、" { $link vocab } " 实例本身，或一个 " { $link vocab-link } "："
{ $subsections
    vocab-link
    >vocab-link
}
"按名称查找词汇库："
{ $subsections vocab }
"各种词汇库属性的访问器："
{ $subsections
    vocab-name
    vocab-main
    vocab-help
}
"查找现有词汇库和创建新词汇库："
{ $subsections
    lookup-vocab
    loaded-child-vocab-names
    create-vocab
}
"从词汇库中获取词："
{ $subsections
    vocab-words-assoc
    vocab-words
    all-words
    words-named
}
"移除词汇库："
{ $subsections forget-vocab }
{ $see-also "words" "vocabs.loader" "word-search" } ;

ABOUT: "vocabularies-zh"

HELP: dictionary
{ $var-description "持有一个将词汇库名称映射到词汇库的哈希表。" } ;

HELP: loaded-vocab-names
{ $values { "seq" { $sequence string } } }
{ $description "输出所有已定义词汇库名称的序列。" } ;

HELP: lookup-vocab
{ $values { "vocab-spec" "一个词汇库说明符" } { "vocab" vocab } }
{ $description "输出一个命名词汇库，如果不存在具有此名称的词汇库则返回 " { $link f } "。" } ;

HELP: vocab
{ $class-description "实例代表词汇库。" } ;

HELP: vocab-name
{ $values { "vocab-spec" "一个词汇库说明符" } { "name" string } }
{ $description "输出词汇库的名称。" } ;

HELP: vocab-words-assoc
{ $values { "vocab-spec" "一个词汇库说明符" } { "assoc/f" { $maybe assoc } } }
{ $description "输出词汇库中定义的词。" } ;

HELP: vocab-words
{ $values { "vocab-spec" vocab-spec } { "seq" { $sequence word } } }
{ $description "输出词汇库中定义的词的序列，如果不存在具有此名称的词汇库则返回 " { $link f } "。" } ;

HELP: all-words
{ $values { "seq" { $sequence word } } }
{ $description "输出字典中所有词的序列。" } ;

HELP: forget-vocab
{ $values { "vocab" string } }
{ $description "移除一个词汇库。该词汇库中的所有词都会被遗忘。" }
{ $notes "此词必须在 " { $link with-compilation-unit } " 内部调用。" } ;

HELP: require-hook
{ $var-description { $quotation ( name -- ) } "，用于加载词汇库。此引用由 " { $link require } " 调用。默认值通常不需要更改；此功能通过存储在变量中的钩子实现，以打破从 " { $vocab-link "vocabs" } " 到 " { $vocab-link "vocabs.loader" } " 到 " { $vocab-link "parser" } " 再回到 " { $vocab-link "vocabs" } " 的循环依赖。" } ;

HELP: require
{ $values { "object" "一个词汇库说明符" } }
{ $description "如果词汇库尚未加载，则加载它。如果词汇库在磁盘上或字典中不存在，则抛出错误。" }
{ $notes "要无条件重新加载词汇库，请使用 " { $link reload } "。要仅重新加载已更改的源文件，请使用 " { $link "vocabs.refresh" } " 中的词。" } ;

HELP: words-named
{ $values { "str" string } { "seq" { $sequence word } } }
{ $description "从当前已加载的词汇库集合中输出所有命名为 " { $snippet "str" } " 的词的序列。" } ;

HELP: create-vocab
{ $values { "name" string } { "vocab" vocab } }
{ $description "如果不存在具有给定名称的词汇库，则创建一个新词汇库，否则输出现有词汇库。" } ;

HELP: loaded-child-vocab-names
{ $values { "vocab-spec" "一个词汇库说明符" } { "seq" { $sequence string } } }
{ $description "输出在层次结构中概念上位于 " { $snippet "vocab" } " 之下的所有词汇库。" }
{ $examples
    { $unchecked-example
        "\"io.streams\" loaded-child-vocab-names ."
        "{ \"io.streams.c\" \"io.streams.duplex\" \"io.streams.lines\" \"io.streams.nested\" \"io.streams.plain\" \"io.streams.string\" }"
    }
} ;

HELP: vocab-link
{ $class-description "此类的实例标识可能尚未加载的词汇库。" { $link vocab-name } " 槽是词汇库名称。"
$nl
"词汇库链接通过调用 " { $link >vocab-link } " 来创建。"
} ;

HELP: >vocab-link
{ $values { "name" string } { "vocab" "一个词汇库说明符" } }
{ $description "如果词汇库已加载，则输出相应的 " { $link vocab } " 实例，否则创建一个新的 " { $link vocab-link } "。" } ;

HELP: runnable-vocab
{ $class-description "具有 " { $slot "main" } " 词的词汇库的类。" } ;
