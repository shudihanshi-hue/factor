USING: help help.markup help.syntax help.definitions help.topics
namespaces words sequences classes assocs vocabs kernel arrays
prettyprint.backend prettyprint.custom kernel.private io generic
math system strings sbufs vectors byte-arrays quotations
io.streams.byte-array classes.builtin parser lexer
classes.predicate classes.union classes.intersection
classes.singleton classes.tuple help.vocabs math.parser
accessors definitions sets lists help.tour prettyprint
continuations ;
IN: help.handbook

ARTICLE: "conventions" "约定 (Conventions)"
"Factor 文档和源代码中使用了各种约定。"
{ $heading "术语表 (Glossary of terms)" }
"Factor 及其文档中使用的常见术语和缩写："
{ $table
    { { $strong "术语 (Term)" } { $strong "定义" } }
    { "alist" { "association list（关联列表）；见 " { $link "alists" } } }
    { "assoc" { "associative mapping（关联映射）；见 " { $link "assocs" } } }
    { "associative mapping" { "一个其类实现了 " { $link "assocs-protocol" } " 的对象" } }
    { "boolean"               { { $link t } " 或 " { $link f } } }
    { "class"                 { "由一个 " { $emphasis "类词 (class word)" } " 和一个判别谓词共同标识的对象集合。见 " { $link "classes" } } }
    { "combinator"            { "接受一个 quotation 或另一个词作为输入的词；即高阶函数 (higher-order function)。见 " { $link "combinators" } } }
    { "definition specifier"  { "一个 " { $link definition } " 实例，它实现了 " { $link "definition-protocol" } } }
    { "generalized boolean"   { "一个被解释为布尔值的对象；值为 " { $link f } " 表示假，其他任何值表示真" } }
    { "generic word"          { "一个其行为取决于某个输入的类的词。见 " { $link "generic" } } }
    { "method"                { "泛型词 (generic word) 在某个类上的特化行为。见 " { $link "generic" } } }
    { "object"                { "任何可被识别的数据" } }
    { "ordering specifier"    { "见 " { $link "order-specifiers" } } }
    { "pathname string"       { "一个标识文件的、依赖于操作系统的路径名" } }
    { "quotation"             { "一个匿名函数；是 " { $link quotation } " 类的实例。更一般地，" { $link callable } " 类的实例可在许多文档说明期望传入 quotation 的地方使用" } }
    { "sequence" { "一个序列 (sequence)；见 " { $link "sequence-protocol" } } }
    { "slot"                  { "可存储一个值的对象组成部分" } }
    { "stack effect"          { "对词的输入和输出的图示表示，例如 " { $snippet "+ ( x y -- z )" } "。见 " { $link "effects" } } }
    { "true value"            { "任何不等于 " { $link f } " 的对象" } }
    { { "vocabulary " { $strong "或 (or)" } " vocab" } { "一个有名称的词集合。见 " { $link "vocabularies" } } }
    { "vocabulary specifier"  { "一个 " { $link vocab } "、" { $link vocab-link } " 或命名某个词汇表的字符串" } }
    { "word"                  { "代码的基本单元，类似于其他编程语言中的函数或过程。见 " { $link "words" } } }
}
{ $heading "文档约定 (Documentation conventions)" }
"Factor 文档由两类不同的文本构成。一类是文章的层次结构（本文档即属此类），另一类是词的文档。帮助文章会引用词文档，反之亦然，但并非每个有文档的词都会被某个帮助文章引用。"
$nl
"浏览器、补全弹窗和其他工具使用一组通用的 " { $link "definitions.icons" } "。"
$nl
"每篇文章顶部都有指向父文章的链接。如果你正在阅读的文章过于具体，可循这些链接向上浏览。"
$nl
"某些泛型词带有 " { $strong "Description（描述）" } " 标题，另一些则带有 " { $strong "Contract（契约）" } " 标题。这种区分用于说明哪些词并不打算让用户自定义方法来扩展，而哪些词则允许这样做。"
{ $heading "词汇表命名约定 (Vocabulary naming conventions)" }
"名称以 " { $snippet ".private" } " 结尾的词汇表包含实现细节、不安全或二者兼有的词。例如，" { $snippet "sequences.private" } " 词汇表包含访问序列元素但不做越界检查的词（" { $link "sequences-unsafe" } "）。除非绝对必要，应避免使用 Factor 库中的私有词。类似地，如果你不希望他人随意使用你的某些词，可使用 " { $link POSTPONE: <PRIVATE } " 将其放入私有词汇表。"
{ $heading "词命名约定 (Word naming conventions)" }
"以下约定并非硬性规定，但通常是理解词行为的一个良好起点："
{ $table
    { { $strong "一般形式" } { $strong "说明" } { $strong "示例" } }
    { { $snippet { $emphasis "foo" } "?" } "输出一个布尔值" { { $link empty? } } }
    { { $snippet { $emphasis "foo" } "!" } { { $snippet "foo" } " 的一个变体，会修改其参数之一" } { { $link append! } } }
    { { $snippet "?" { $emphasis "foo" } } { "有条件地执行 " { $snippet { $emphasis "foo" } } } { { $links ?nth } } }
    { { $snippet "<" { $emphasis "foo" } ">" } { "创建一个新的 " { $snippet "foo" } } { { $link <array> } } }
    { { $snippet ">" { $emphasis "foo" } "<" } { "销毁一个 " { $snippet "foo" } " 类的对象，通常用于解包其中的数据" } { { $link >slice< } } }
    { { $snippet ">" { $emphasis "foo" } } { "将栈顶转换为 " { $snippet "foo" } } { { $link >array } } }
    { { $snippet { $emphasis "foo" } ">" { $emphasis "bar" } } { "将一个 " { $snippet "foo" } " 转换为 " { $snippet "bar" } } { { $link number>string } } }
    { { $snippet "new-" { $emphasis "foo" } } { "创建一个新的 " { $snippet "foo" } "，从栈上取某种参数来确定要创建的对象类型" } { { $link new-sequence } ", " { $link new-lexer } ", " { $link new } } }
    { { $snippet { $emphasis "foo" } "*" } { { $snippet "foo" } " 的替代形式，或由 " { $snippet "foo" } " 调用的泛型词" } { { $links at* pprint* } } }
    { { $snippet "(" { $emphasis "foo" } ")" } { { $snippet "foo" } " 使用的实现细节词" } { { $link (clone) } } }
    { { $snippet "set-" { $emphasis "foo" } } { "将 " { $snippet "foo" } " 设为新值" } { $links set-length } }
    { { $snippet { $emphasis "foo" } ">>" } { "获取栈顶元组 (tuple) 的 " { $snippet "foo" } " 槽 (slot)；见 " { $link "accessors" } } { { $link name>> } } }
    { { $snippet ">>" { $emphasis "foo" } } { "设置栈顶元组的 " { $snippet "foo" } " 槽；见 " { $link "accessors" } } { { $link >>name } } }
    { { $snippet "with-" { $emphasis "foo" } } { "执行与 " { $snippet "foo" } " 相关的某种初始化和清理，通常在一个新的动态作用域中" } { $links with-scope with-input-stream with-output-stream } }
    { { $snippet "$" { $emphasis "foo" } } { "帮助标记 (help markup)" } { $links $heading $emphasis } }
}
{ $heading "栈效果约定 (Stack effect conventions)" }
"栈效果约定记录在 " { $link "effects" } " 中。"
;

ARTICLE: "tail-call-opt" "尾调用优化 (Tail-call optimization)"
"如果最后执行的动作是一个词的执行，当前 quotation 就不会被保存在调用栈上；这被称为 " { $emphasis "尾调用优化 (tail-call optimization)" } "，Factor 实现保证一定会执行此优化。"
$nl
"尾调用优化允许以递归方式高效地实现迭代算法，而无需在语言中引入任何原始的循环构造。但实际上，大多数迭代是通过组合子 (combinator) 完成的，例如 " { $link while } "、" { $link each } "、" { $link map } "、" { $link assoc-each } " 等。不过，这些组合子的定义最终都会归结到递归词上。" ;

ARTICLE: "evaluator" "栈机模型 (Stack machine model)"
{ $link "quotations" } " 从头到尾依次求值。到达末尾时，该 quotation 返回到其调用者。当 quotation 中的每个对象依次被求值时，会根据其类型采取相应动作："
{ $list
    { "一个 " { $link word } " - 调用该词的定义 quotation。见 " { $link "words" } }
    { "一个 " { $link wrapper } " - 被包装的对象被压入数据栈。当词对象本应执行而我们想直接将其压栈时，使用包装器 (wrapper)。参见 " { $link POSTPONE: \ } " 解析词。" }
    { "所有其他类型的对象都被压入数据栈。" }
}
{ $subsections "tail-call-opt" }
{ $see-also "compiler" } ;

ARTICLE: "objects" "对象 (Objects)"
"一个 " { $emphasis "对象 (object)" } " 是任何可被识别的数据。在 Factor 中所有值都是对象。每个对象都携带类型信息，且类型在运行时检查；Factor 是动态类型的。"
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

ARTICLE: "numbers" "数字 (Numbers)"
{ $subsections
    "arithmetic"
    "math-constants"
    "math-functions"
    "number-strings"
}
"数字的实现："
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

ARTICLE: "collections" "集合 (Collections)"
{ $heading "序列 (Sequences)" }
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
"可变长序列："
{ $subsections
    "vectors"
    "byte-vectors"
    "sbufs"
    "growable"
}
{ $heading "关联映射 (Associative mappings)" }
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
{ $heading "双端队列 (Double-ended queues)" }
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
"库中还有许多其他被标记为 " { $link T{ vocab-tag { name "collections" } } } " 的词汇表。" ;

USING: io.encodings.utf8 io.encodings.binary io.files ;

ARTICLE: "encodings-introduction" "编码简介 (An introduction to encodings)"
"为了用二进制表达文本，必须使用某种编码。在现代语境下，这被理解为 Unicode 码点（字符）与若干二进制数据之间的双向映射。由于世界上并非只有英语一种语言，ASCII 作为从二进制到 Unicode 的映射并不够用；它甚至连破折号和弯引号都无法表示。Unicode 被设计为一种通用字符集，原则上能够表示一切字符。" $nl
"并非所有编码都能表示全部 Unicode 码点，但 Unicode 基本上能表示现代编码中存在的所有内容。有些编码是特定于某种语言的，有些则能表示 Unicode 中的所有内容。尽管世界正向着 Unicode 和 UTF-8 发展，但现实是仍需考虑多种编码。" $nl
"Factor 使用一套编码描述符系统来表示编码。编码描述符是描述编码的对象。例如 " { $link utf8 } " 和 " { $link binary } "。编码描述符可以独立传递。每个编码描述符都有某种构造已编码或已解码流的方法，所得流中存储的编码描述符具有读取或写入字符的方法。" $nl
"处理字节的流的构造函数通常将编码作为显式参数。例如，要打开一个 UTF-8 编码的文本文件进行读取，使用如下代码"
{ $code "\"file.txt\" utf8 <file-reader>" }
"如果已编码流中存在错误，将插入一个替换字符 (0xFFFD)。若想在出错时抛出异常，使用严格编码 (strict encoding) 如下"
{ $code "USE: io.encodings.strict" "\"file.txt\" utf8 strict <file-reader>" }
"类似地，打开文件进行写入时也可指定编码。"
{ $code "USE: io.encodings.ascii" "\"file.txt\" ascii <file-writer>" }
"某些不返回流的词也需要编码，例如 " { $link file-contents } "，例如"
{ $code "USE: io.encodings.utf16" "\"file.txt\" utf16 file-contents" }
"编码描述符也被 " { $link "io.streams.byte-array" } " 使用，并被处理流的组合子如 " { $link with-file-writer } " 和 " { $link with-byte-reader } " 所接受。它 " { $emphasis "不" } " 用于 " { $link "io.streams.string" } "，因为后者处理的是抽象文本。" $nl
"当使用 " { $link binary } " 编码时，写入时期望一个 " { $link byte-array } "，读取时也返回它，因为该流处理的是字节。所有其他编码处理的都是字符串，因为它们用于表示文本。" ;

ARTICLE: "io" "输入与输出 (Input and output)"
{ $heading "流 (Streams)" }
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
{ $heading "编码 (Encodings)" }
{ $subsections
    "encodings-introduction"
    "io.encodings"
}
{ $heading "包装流 (Wrapper streams)" }
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

ARTICLE: "article-index" "文章索引 (Article index)"
{ $index [ articles get keys ] } ;

ARTICLE: "primitive-index" "原语索引 (Primitive index)"
{ $index [ all-words [ primitive? ] filter ] } ;

ARTICLE: "error-index" "错误索引 (Error index)"
{ $index [ all-errors ] } ;

ARTICLE: "class-index" "类索引 (Class index)"
{ $heading "内建类 (Built-in classes)" }
{ $index [ classes [ builtin-class? ] filter ] }
{ $heading "元组类 (Tuple classes)" }
{ $index [ classes [ tuple-class? ] filter ] }
{ $heading "单例类 (Singleton classes)" }
{ $index [ classes [ singleton-class? ] filter ] }
{ $heading "联合类 (Union classes)" }
{ $index [ classes [ union-class? ] filter ] }
{ $heading "交集类 (Intersection classes)" }
{ $index [ classes [ intersection-class? ] filter ] }
{ $heading "谓词类 (Predicate classes)" }
{ $index [ classes [ predicate-class? ] filter ] } ;

USING: help.cookbook help.tutorial ;

ARTICLE: "handbook-language-reference" "语言 (The language)"
{ $heading "基础 (Fundamentals)" }
{ $subsections
    "conventions"
    "syntax"
}
{ $heading "栈 (The stack)" }
{ $subsections
    "evaluator"
    "effects"
    "inference"
}
{ $heading "基本数据类型" }
{ $subsections
    "booleans"
    "numbers"
    "collections"
}
{ $heading "求值 (Evaluation)" }
{ $subsections
    "words"
    "shuffle-words"
    "combinators"
    "threads"
}
{ $heading "命名值 (Named values)" }
{ $subsections
    "locals"
    "namespaces"
    "namespaces-global"
}
{ $heading "抽象 (Abstractions)" }
{ $subsections
    "fry"
    "objects"
    "errors"
    "destructors"
    "memoize"
    "parsing-words"
    "macros"
    "continuations"
}
{ $heading "程序组织" }
{ $subsections "vocabs.loader" }
"被标记为 " { $link T{ vocab-tag { name "extensions" } } } " 的词汇表实现了各种额外的语言抽象。" ;

ARTICLE: "stacks" "栈 (Stacks)"
"虽然用户代码操作的数据栈 (data stack) 是我们主要考虑的栈（甚至常常直接简称为“栈”），但 Factor 的实现在内部实际上使用了多个栈。"
{ $heading "数据栈 (Data stack)" }
"数据栈是词与之交互的主要栈，通过弹出输入和压入输出来工作。" { $link "inference" } " 充当数据栈的类型系统，以确保词始终具有源码中所声明的输入和输出数量。" $nl
{ $link .s } " 打印当前数据栈。"
{ $heading "调用栈 (Call stack)" }
"VM 管理着一个调用栈，其栈帧沿调用层次从当前正在执行的词一直追溯到程序启动处。某些词会被 " { $link "compiler" } " 内联，因此这类词的调用栈帧可能被省略。" $nl
{ $link .c } " 打印当前调用栈。"
{ $heading "保留栈 (Retain stack)" }
"保留栈在内部用作一种临时存放栈。像 " { $link dip } " 这样的词（临时将值从数据栈移出、调用某个 quotation、再将值恢复回数据栈）是通过将值移动到保留栈来实现的。" { $link "locals" } " 也利用保留栈来高效地存储其值。" $nl
"Forth 和其他一些串接式语言 (concatenative language) 向用户代码暴露了一个相关的“返回栈 (return stack)”。Factor 的保留栈起着类似作用，但它是语言实现的内部细节，不打算由用户代码直接操作。" $nl
{ $link .r } " 打印当前保留栈。"
{ $heading "名称栈 (Name stack)" }
"名称栈用作实现 " { $link "namespaces" } " 的一部分。每个动态变量都是某个命名空间的一部分。命名空间作用域可以嵌套，因此名称栈会记录这种嵌套顺序，以便在访问这些变量时使用。"
{ $heading "捕获栈 (Catch stack)" }
"捕获栈包含一个 " { $link "continuations" } " 向量，用于 " { $link "errors" } " 和 " { $link "threads" } " 等若干抽象。例如，使用 " { $link recover } " 进行的异常处理会捕获一个延续 (continuation)，并利用捕获栈在出错时恢复程序状态。" $nl
"在某些编程语言实现中，延续是一项相当复杂的特性。而在 Factor 中，延续十分直接：它们只是捕获此处提到的所有栈的状态。"
{ $see-also "continuations.private" } ;

ARTICLE: "handbook-system-reference" "实现 (The implementation)"
{ $heading "解析时与编译时 (Parse time and compile time)" }
{ $subsections
    "parser"
    "definitions"
    "vocabularies"
    "source-files"
    "compiler"
    "tools.errors"
}
{ $heading "虚拟机 (Virtual machine)" }
{ $subsections
    "stacks"
    "images"
    "command-line"
    "rc-files"
    "init"
    "system"
    "layouts"
} ;

ARTICLE: "handbook-tools-reference" "开发者工具 (Developer tools)"
"以下工具是基于文本的。" { $link "ui-tools" } " 另有单独文档。"
{ $heading "工作流 (Workflow)" }
{ $subsections
    "listener"
    "editor"
    "vocabs.refresh"
    "tools.test"
    "help"
}
{ $heading "调试 (Debugging)" }
{ $subsections
    "prettyprint"
    "inspector"
    "tools.inference"
    "tools.annotations"
    "tools.deprecation"
}
{ $heading "浏览 (Browsing)" }
{ $subsections
    "see"
    "tools.crossref"
    "vocabs.hierarchy"
}
{ $heading "性能 (Performance)" }
{ $subsections
    "timing"
    "tools.profiler.sampling"
    "tools.memory"
    "tools.threads"
    "tools.destructors"
    "tools.disassembler"
}
{ $heading "部署 (Deployment)" }
{ $subsections "tools.deploy" } ;

ARTICLE: "handbook-library-reference" "库 (Libraries)"
"本索引列出已加载词汇表中、不属于任何其他文章子节的文章。要浏览更多词汇表，见 " { $link "vocab-index" } "。"
{ $index [ orphan-articles ] } ;

ARTICLE: "handbook" "Factor 手册 (Factor handbook)"
{ $heading "入门 (Getting started)" }
{ $subsections
    "cookbook"
    "first-program"
    "tour"
}
{ $heading "参考 (Reference)" }
{ $subsections
    "handbook-language-reference"
    "io"
    "ui"
    "handbook-system-reference"
    "handbook-tools-reference"
    "ui-tools"
    "alien"
    "handbook-library-reference"
}
{ $heading "索引 (Index)" }
{ $subsections
  "vocab-index"
  "article-index"
  "primitive-index"
  "error-index"
  "class-index"
} ;

ABOUT: "handbook"
