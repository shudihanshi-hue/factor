! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! Factor 手册（Handbook）— 中文翻译
! 原始文件: D:\factor\basis\help\handbook\handbook.factor
!
USING: accessors arrays assocs byte-arrays classes
classes.builtin classes.intersection classes.predicate
classes.singleton classes.tuple classes.union continuations
definitions generic help help.cookbook help.markup help.syntax
help.topics help.tour help.tutorial help.vocabs io io.buffers
io.encodings.binary io.encodings.utf8 io.files
io.streams.byte-array kernel kernel.private lexer lists math
math.parser namespaces parser prettyprint prettyprint.backend
prettyprint.custom quotations sbufs sequences sets strings
system vectors vocabs words ;
IN: zh.handbook

ARTICLE: "conventions-zh" "约定"
"Factor 文档和源代码中使用了各种约定。"
{ $heading "术语表" }
"Factor 及其文档中使用的常用术语和缩写："
{ $table
    { { $strong "术语（Term）" } { $strong "定义（Definition）" } }
    { "alist" { "关联列表（association list）；参见 " { $link "alists" } } }
    { "assoc" { "关联映射（associative mapping）；参见 " { $link "assocs" } } }
    { "associative mapping" { "其类实现了 " { $link "assocs-protocol" } " 的对象" } }
    { "boolean"               { { $link t } " 或 " { $link f } } }
    { "class"                 { "由 " { $emphasis "类别字（class word）" } " 标识，并带有一个判别谓词（predicate）的一组对象。参见 " { $link "classes" } } }
    { "combinator"            { "以一个引用（quotation）或另一个字（word）为输入的字；高阶函数（higher-order function）。" { $emphasis "组合子（combinator）" } "。参见 " { $link "combinators" } } }
    { "definition specifier"  { "实现了 " { $link "definition-protocol" } " 的 " { $link definition } " 实例" } }
    { "generalized boolean"   { "被解释为布尔值的对象；值 " { $link f } " 表示假，其他任何值表示真" } }
    { "generic word"          { "其行为取决于其中一个输入所属类的字。参见 " { $link "generic" } } }
    { "method"                { "泛型字（generic word）在某个类上的特化行为。参见 " { $link "generic" } } }
    { "object"                { "任何可被标识的数据项" } }
    { "ordering specifier"    { "参见 " { $link "order-specifiers" } } }
    { "pathname string"       { "标识文件的、特定于操作系统的路径名" } }
    { "quotation"             { "匿名函数；" { $link quotation } " 类的实例。更一般地，" { $link callable } " 类的实例也可用于文档中声明期望引用（quotation）的许多位置" } }
    { "sequence" { "序列（sequence）；参见 " { $link "sequence-protocol" } } }
    { "slot"                  { "对象中可存储值的组件（槽）" } }
    { "stack effect"          { "字的输入和输出的图示表示法，例如 " { $snippet "+ ( x y -- z )" } "。参见 " { $link "effects" } } }
    { "true value"            { "不等于 " { $link f } " 的任何对象" } }
    { { "vocabulary " { $strong "或" } " vocab" } { "一组命名的字（words）。参见 " { $link "vocabularies" } } }
    { "vocabulary specifier"  { "一个 " { $link vocab } "、" { $link vocab-link } " 或命名某个词汇表的字符串" } }
    { "word"                  { "代码的基本单元，类似于其他编程语言中的函数或过程。参见 " { $link "words" } } }
}
{ $heading "文档约定" }
"Factor 文档由两个不同的文本体系组成：一个是文章层级体系（如本篇），另一个是字文档（word documentation）。帮助文章可以引用字文档，反之亦然，但并非每个被文档化的字都会在某篇帮助文章中被引用。"
$nl
"浏览器、补全弹出窗口和其他工具使用一套通用的 " { $link "definitions.icons" } "。"
$nl
"每篇文章的顶部都有指向父文章的链接。如果当前文章过于具体，可以通过这些链接向上浏览。"
$nl
"一些泛型字（generic word）有 " { $strong "描述（Description）" } " 标题，另一些则有 " { $strong "契约（Contract）" } " 标题。这一区别用于区分两类字：一类不打算由用户自定义方法扩展，另一类则可以。"
{ $heading "词汇表命名约定" }
"以 " { $snippet ".private" } " 结尾的词汇表名称包含以下性质的词：实现细节、不安全操作，或两者兼有。例如，" { $snippet "sequences.private" } " 词汇表包含无需边界检查即可访问序列元素的字（参见 " { $link "sequences-unsafe" } "）。除非绝对必要，应避免使用 Factor 库中的私有（private）字。同样，您也可以使用 " { $link POSTPONE: <PRIVATE } " 将自己代码中的字放入私有词汇表，以免他人在没有充分理由的情况下使用。"
{ $heading "字命名约定" }
"以下约定并非硬性规则，但通常是理解字行为的有益第一步："
{ $table
    { { $strong "通用形式" } { $strong "描述" } { $strong "示例" } }
    { { $snippet { $emphasis "foo" } "?" } "输出一个布尔值" { { $link empty? } } }
    { { $snippet { $emphasis "foo" } "!" } { "是 " { $snippet "foo" } " 的变体，会修改（mutate）其参数之一" } { { $link append! } } }
    { { $snippet "?" { $emphasis "foo" } } { "有条件地执行 " { $snippet { $emphasis "foo" } } } { { $links ?nth } } }
    { { $snippet "<" { $emphasis "foo" } ">" } { "创建一个新的 " { $snippet "foo" } } { { $link <array> } } }
    { { $snippet ">" { $emphasis "foo" } "<" } { "销毁一个 " { $snippet "foo" } " 类的对象，通常将其数据解包" } { { $link >slice< } } }
    { { $snippet ">" { $emphasis "foo" } } { "将栈顶元素转换为 " { $snippet "foo" } } { { $link >array } } }
    { { $snippet { $emphasis "foo" } ">" { $emphasis "bar" } } { "将 " { $snippet "foo" } " 转换为 " { $snippet "bar" } } { { $link number>string } } }
    { { $snippet "new-" { $emphasis "foo" } } { "创建一个新的 " { $snippet "foo" } "，从栈上取某种参数来决定所要创建对象的类型" } { { $link new-sequence } ", " { $link new-lexer } ", " { $link new } } }
    { { $snippet { $emphasis "foo" } "*" } { { $snippet "foo" } " 的替代形式，或是被 " { $snippet "foo" } " 调用的泛型字" } { { $links at* pprint* } } }
    { { $snippet "(" { $emphasis "foo" } ")" } { "供 " { $snippet "foo" } " 使用的实现细节字" } { { $link (clone) } } }
    { { $snippet "set-" { $emphasis "foo" } } { "将 " { $snippet "foo" } " 设置为新值" } { $links set-length } }
    { { $snippet { $emphasis "foo" } ">>" } { "获取栈顶元组（tuple）的 " { $snippet "foo" } " 槽（slot）；参见 " { $link "accessors" } } { { $link name>> } } }
    { { $snippet ">>" { $emphasis "foo" } } { "设置栈顶元组（tuple）的 " { $snippet "foo" } " 槽（slot）；参见 " { $link "accessors" } } { { $link >>name } } }
    { { $snippet "with-" { $emphasis "foo" } } { "执行某种与 " { $snippet "foo" } " 相关的初始化和清理操作，通常在一个新的动态作用域中进行" } { $links with-scope with-input-stream with-output-stream } }
    { { $snippet "$" { $emphasis "foo" } } { "帮助标记（help markup）" } { $links $heading $emphasis } }
}
{ $heading "栈效果约定" }
"栈效果约定请参见 " { $link "effects" } "。"
;

ARTICLE: "tail-call-opt-zh" "尾调用优化"
"如果某操作中最后执行的动作是调用一个字，则当前的引用（quotation）不会保存在调用栈中；这被称为 " { $emphasis "尾调用优化（tail-call optimization）" } "，Factor 实现保证一定会执行此优化。"
$nl
"尾调用优化使得迭代算法可以通过递归高效地实现，语言中无需任何原始循环构造。然而在实践中，大多数迭代通过组合子（combinator）执行，例如 " { $link while } "、" { $link each } "、" { $link map } "、" { $link assoc-each } " 等。不过这些组合子的定义最终确实依赖于递归字。"
;

ARTICLE: "evaluator-zh" "栈机器模型"
{ $link "quotations" } " 从开头到结尾顺序求值。到达结尾时，引用（quotation）返回到其调用者。当引用中的每个对象依次被求值时，根据其类型采取不同的操作："
{ $list
    { "一个 " { $link word } " — 调用该字的定义引用。参见 " { $link "words" } }
    { "一个 " { $link wrapper } " — 包装的对象被推入数据栈。当字对象（word object）本应执行时，包装器（wrapper）用于将它们直接推入栈中。参见 " { $link POSTPONE: \ } " 解析字。" }
    { "其他所有类型的对象均被推入数据栈。" }
}
{ $subsections "tail-call-opt-zh" }
{ $see-also "compiler" } ;

ARTICLE: "objects-zh" "对象"
"一个 " { $emphasis "对象（object）" } " 是任何可被标识的数据项。在 Factor 中，所有值都是对象。每个对象都携带类型信息，类型在运行时检查；Factor 是动态类型语言。"
{ $subsections
    "equality"
    "math.order"
    "classes"
    "tuples"
    "generic"
}
"高级特性："
{ $subsections
    "delegate"
    "mirrors"
    "slots"
} ;

ARTICLE: "numbers-zh" "数字"
{ $subsections
    "arithmetic"
    "math-constants"
    "math-functions"
    "number-strings"
}
"数字实现："
{ $subsections
    "integers"
    "rationals"
    "floats"
    "complex-numbers"
}
"高级特性："
{ $subsections
    "math-vectors"
    "math.intervals"
} ;

USE: io.buffers

ARTICLE: "collections-zh" "集合"
{ $heading "序列（Sequences）" }
{ $subsections
    "sequences"
    "virtual-sequences"
    "namespaces-make"
}
"定长序列："
{ $subsections
    "arrays"
    "quotations"
    "strings"
    "byte-arrays"
    "specialized-arrays"
}
"可伸缩序列："
{ $subsections
    "vectors"
    "byte-vectors"
    "sbufs"
    "growable"
}
{ $heading "关联映射（Associative mappings）" }
{ $subsections
    "assocs"
    "linked-assocs"
    "biassocs"
    "refs"
}
"实现："
{ $subsections
    "hashtables"
    "alists"
    "enumerateds"
}
{ $heading "双端队列（Deques）" }
{ $subsections "deques" }
"实现："
{ $subsections
    "dlists"
    "search-deques"
}
{ $heading "其他集合" }
{ $subsections
    "sets"
    "lists"
    "disjoint-sets"
    "interval-maps"
    "heaps"
    "boxes"
    "graphs"
    "buffers"
}
"库中还有许多打有 " { $link T{ vocab-tag { name "collections" } } } " 标签的其他词汇表。" ;

USING: io.encodings.utf8 io.encodings.binary io.files ;

ARTICLE: "encodings-introduction-zh" "编码简介"
"为了用二进制表达文本，必须使用某种编码。在现代语境中，这被理解为 Unicode 码位（字符）与一定量二进制数据之间的双向映射。由于英语并非世界上唯一的语言，ASCII 不足以作为二进制到 Unicode 的映射；它甚至无法表示破折号（em-dash）或弯引号（curly quotes）。Unicode 被设计为一种可潜在表示所有字符的通用字符集。" $nl
"并非所有编码都能表示所有 Unicode 码位，但 Unicode 基本可以表示现代编码中存在的所有内容。一些编码是语言特定的，而另一些可以表示 Unicode 中的所有内容。尽管世界正在向 Unicode 和 UTF-8 迈进，但今天仍然存在多种必须考虑的编码。" $nl
"Factor 使用编码描述符（encoding descriptor）系统来表示编码。编码描述符是描述编码的对象。例如 " { $link utf8 } " 和 " { $link binary } "。编码描述符可以独立传递。每个编码描述符都有一些用于构造编码流或解码流的方法，生成的流中存储有一个编码描述符，其中包含用于读取或写入字符的方法。" $nl
"处理字节的流的构造函数通常接受一个编码作为显式参数。例如，要打开一个以 UTF-8 编码的文本文件进行读取，请使用"
{ $code "\"file.txt\" utf8 <file-reader>" }
"如果编码流中出现错误，将插入一个替换字符（0xFFFD）。要在出错时抛出异常，请使用严格编码："
{ $code "USE: io.encodings.strict" "\"file.txt\" utf8 strict <file-reader>" }
"类似地，打开文件进行写入时也可指定编码。"
{ $code "USE: io.encodings.ascii" "\"file.txt\" ascii <file-writer>" }
"对于某些不返回流的字，如 " { $link file-contents } "，同样需要编码，例如："
{ $code "USE: io.encodings.utf16" "\"file.txt\" utf16 file-contents" }
"编码描述符也供 " { $link "io.streams.byte-array" } " 使用，并被处理流的组合子（如 " { $link with-file-writer } " 和 " { $link with-byte-reader } "）所接受。但它 " { $emphasis "不" } " 用于 " { $link "io.streams.string" } "，因为后者处理的是抽象文本。"
$nl
"当使用 " { $link binary } " 编码时，写操作期望 " { $link byte-array } "，读操作返回 " { $link byte-array } "，因为该流处理的是字节。所有其他编码均处理字符串，因为它们用于表示文本。" ;

ARTICLE: "io-zh" "输入与输出"
{ $heading "流（Streams）" }
{ $subsections
    "streams"
    "io.files"
}
{ $heading "文件系统" }
{ $subsections
    "io.pathnames"
    "io.files.info"
    "io.files.links"
    "io.directories"
}
{ $heading "编码（Encodings）" }
{ $subsections
    "encodings-introduction-zh"
    "io.encodings"
}
{ $heading "包装流" }
{ $subsections
    "io.streams.duplex"
    "io.streams.plain"
    "io.streams.string"
    "io.streams.byte-array"
}
{ $heading "实用工具" }
{ $subsections
    "io.styles"
    "checksums"
}
{ $heading "实现" }
{ $subsections
    "io.streams.c"
    "io.ports"
}
{ $see-also "destructors" } ;

ARTICLE: "article-index-zh" "文章索引"
{ $index [ articles get keys ] } ;

ARTICLE: "primitive-index-zh" "原语索引"
{ $index [ all-words [ primitive? ] filter ] } ;

ARTICLE: "error-index-zh" "错误索引"
{ $index [ all-errors ] } ;

ARTICLE: "class-index-zh" "类索引"
{ $heading "内建类（Built-in classes）" }
{ $index [ classes [ builtin-class? ] filter ] }
{ $heading "元组类（Tuple classes）" }
{ $index [ classes [ tuple-class? ] filter ] }
{ $heading "单例类（Singleton classes）" }
{ $index [ classes [ singleton-class? ] filter ] }
{ $heading "联合类（Union classes）" }
{ $index [ classes [ union-class? ] filter ] }
{ $heading "交集类（Intersection classes）" }
{ $index [ classes [ intersection-class? ] filter ] }
{ $heading "谓词类（Predicate classes）" }
{ $index [ classes [ predicate-class? ] filter ] } ;

USING: help.cookbook help.tutorial ;

ARTICLE: "handbook-language-reference-zh" "语言参考"
{ $heading "基础" }
{ $subsections
    "conventions-zh"
    "syntax"
}
{ $heading "栈" }
{ $subsections
    "evaluator-zh"
    "effects-zh"
    "inference-zh"
}
{ $heading "基本数据类型" }
{ $subsections
    "booleans"
    "numbers-zh"
    "collections-zh"
}
{ $heading "求值" }
{ $subsections
    "words-zh"
    "shuffle-words"
    "combinators"
    "threads"
}
{ $heading "命名值" }
{ $subsections
    "locals-zh"
    "namespaces-zh"
    "namespaces-global-zh"
}
{ $heading "抽象" }
{ $subsections
    "fry-zh"
    "objects-zh"
    "errors-zh"
    "destructors-zh"
    "memoize-zh"
    "parsing-words-zh"
    "macros-zh"
    "continuations-zh"
}
{ $heading "程序组织" }
{ $subsections "vocabs.loader-zh" }
"标记为 " { $link T{ vocab-tag { name "extensions" } } } " 的词汇表实现了各种额外的语言抽象。" ;

ARTICLE: "stacks-zh" "栈"
"虽然用户代码操作的数据栈是我们通常想到的主要栈（以至于常被直接称为\"栈\"），但 Factor 的实现实际上在内部使用了多个栈。"
{ $heading "数据栈（Data stack）" }
"数据栈是字通过弹出输入和推入输出来与之交互的主要栈。" { $link "inference" } " 作为数据栈的类型系统，确保字始终具有源码中声明的输入和输出数量。" $nl
{ $link .s } " 打印当前数据栈。"
{ $heading "调用栈（Call stack）" }
"虚拟机管理一个调用栈，其中的栈帧遵循从当前正在执行的字一直到程序启动的调用层级。某些字被 " { $link "compiler" } " 内联，因此任何此类字的调用栈帧可能被省略。" $nl
{ $link .c } " 打印当前调用栈。"
{ $heading "保留栈（Retain stack）" }
"保留栈在内部用作一种临时持有栈。像 " { $link dip } " 这样的字（它暂时从数据栈中移除值，调用某个引用（quotation），然后将这些值恢复到数据栈上）是通过将值移动到保留栈来实现的。" { $link "locals" } " 也利用保留栈来高效存储其值。" $nl
"Forth 和其他一些连接性语言（concatenative languages）将相关的\"返回栈（return stack）\"暴露给用户代码。Factor 的保留栈扮演着类似的角色，但它是内部语言实现细节，不应由用户代码操作。" $nl
{ $link .r } " 打印当前保留栈。"
{ $heading "名称栈（Name stack）" }
"名称栈用于实现 " { $link "namespaces" } "。每个动态变量都是命名空间（namespace）的一部分。命名空间作用域可以嵌套，因此名称栈跟踪访问这些变量时所使用的嵌套顺序。"
{ $heading "捕获栈（Catch stack）" }
"捕获栈包含一个 " { $link "continuations" } " 的向量，用于多种抽象，如 " { $link "errors" } " 和 " { $link "threads" } "。例如，使用 " { $link recover } " 进行异常处理会捕获一个续延（continuation），并利用捕获栈在发生错误时恢复程序状态。" $nl
"在一些编程语言实现中，续延（continuation）是一个非常复杂的特性。在 Factor 中，续延很简单：它们只是捕获此处所述所有栈的状态。"
{ $see-also "continuations.private" } ;

ARTICLE: "handbook-system-reference-zh" "实现参考"
{ $heading "解析时与编译时" }
{ $subsections
    "parser"
    "definitions"
    "vocabularies"
    "source-files"
    "compiler"
    "tools.errors"
}
{ $heading "虚拟机" }
{ $subsections
    "stacks-zh"
    "images"
    "command-line"
    "rc-files"
    "init"
    "system"
    "layouts"
} ;

ARTICLE: "handbook-tools-reference-zh" "开发者工具"
"以下工具是基于文本的。" { $link "ui-tools" } " 有单独的文档。"
{ $heading "工作流" }
{ $subsections
    "listener"
    "editor"
    "vocabs.refresh"
    "tools.test"
    "help"
}
{ $heading "调试" }
{ $subsections
    "prettyprint"
    "inspector"
    "tools.inference"
    "tools.annotations"
    "tools.deprecation"
}
{ $heading "浏览" }
{ $subsections
    "see"
    "tools.crossref"
    "vocabs.hierarchy"
}
{ $heading "性能" }
{ $subsections
    "timing"
    "tools.profiler.sampling"
    "tools.memory"
    "tools.threads"
    "tools.destructors"
    "tools.disassembler"
}
{ $heading "部署" }
{ $subsections "tools.deploy" } ;

ARTICLE: "handbook-library-reference-zh" "库参考"
"本索引列出了来自已加载词汇表中、不是任何其他文章子节的条目。要探索更多词汇表，请参见 " { $link "vocab-index" } "。"
{ $index [ orphan-articles ] } ;

ARTICLE: "handbook-zh" "Factor 手册"
{ $heading "入门" }
{ $subsections
    "cookbook-zh"
    "first-program-zh"
    "tour-zh"
}
{ $heading "参考" }
{ $subsections
    "handbook-language-reference-zh"
    "io-zh"
    "ui-zh"
    "handbook-system-reference-zh"
    "handbook-tools-reference-zh"
    "ui-tools-zh"
    "alien-zh"
    "handbook-library-reference-zh"
}
{ $heading "索引" }
{ $subsections
  "vocab-index-zh"
  "article-index-zh"
  "primitive-index-zh"
  "error-index-zh"
  "class-index-zh"
} ;

ABOUT: "handbook-zh"
