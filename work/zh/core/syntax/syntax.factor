USING: arrays assocs classes.algebra.private classes.maybe
classes.tuple combinators command-line effects generic
generic.math generic.single help.markup help.syntax io.pathnames
kernel lexer math math.parser multiline parser sequences sets
slots strings vocabs.loader vocabs.parser words words.alias
words.constant words.symbol ;
IN: zh.core.syntax

ARTICLE: "parser-algorithm" "解析器算法（Parser algorithm）"
"在最抽象的层面上，Factor 语法由空格分隔的词法单元（token）组成。解析器（parser）在空格边界处将输入切分为词法单元。解析器区分大小写，且词法单元之间的空格是有意义的，因此以下三个表达式的词法解析结果不同："
{ $code "2X+\n2 X +\n2 x +" }
"当解析器读取词法单元时，它会区分数字、普通词（ordinary word）和解析字（parsing word）。词法单元被追加到解析树（parse tree）中，解析树的顶层是由原始解析器调用返回的引用（quotation）。解析树的嵌套层级由解析字创建。"
$nl
"解析器遍历输入文本，依次检查每个字符。以下是解析器算法的详细描述——其中的一些概念将在后续定义："
{ $list
    { "如果当前字符是双引号（\"），则执行 " { $link POSTPONE: " } " 解析字，读取一个字符串（string）。" }
    {
        "否则，从输入中取出下一个词法单元。解析器在当前使用的词汇表（vocabulary）集合中搜索由该词法单元命名的词。如果找到了该词，则采取以下两种操作之一："
        { $list
            "如果该词是普通词，则将其追加到解析树中。"
            "如果该词是解析字（parsing word），则执行它。"
        }
    }
    "此外，如果词法单元不表示一个已知的词，解析器会尝试将其解析为数字。如果该词法单元是一个数字，则将数字对象添加到解析树中。否则，引发错误并停止解析。"
}
"解析字在解析过程中扮演关键角色；普通词和数字被简单地添加到解析树中，而解析字在解析器的上下文中执行，可以进行自己的解析，并在解析树中创建嵌套数据结构。解析字还能够定义新词。"
$nl
"虽然可以定义支持任意语法的解析字，但默认的解析字集合位于 " { $vocab-link "syntax" } " 词汇表中，为 Factor 的所有后续语法交互提供了基础。" ;

ARTICLE: "syntax-immediate" "解析时求值（Parse time evaluation）"
"代码可以在解析时求值。这是一个很少使用的功能；一个用例是 " { $link "loading-libs" } "，在源文件中的词被编译之前需要执行一些代码。"
{ $subsections
    POSTPONE: <<
    POSTPONE: >>
} ;

ARTICLE: "syntax-integers" "整数语法（Integer syntax）"
"整数（integer）的打印表示由一系列数字组成，可以选择性地加上符号前缀，并可以任意地用逗号或下划线分隔。"
{ $code
    "123456"
    "-10"
    "2,432,902,008,176,640,000"
    "1_000_000"
}
"整数以十进制输入，除非加上基数变更前缀。" { $snippet "0x" } " 开始一个十六进制字面量（literal），" { $snippet "0o" } " 开始一个八进制字面量，" { $snippet "0b" } " 开始一个二进制字面量。如果有符号，符号放在基数前缀之前。"
{ $example
    "USE: prettyprint"
    "10 ."
    "0b10 ."
    "-0o10 ."
    "0x10 ."
    "10\n2\n-8\n16"
}
"有关整数的更多信息可以在 " { $link "integers" } " 中找到。" ;

ARTICLE: "syntax-ratios" "分数语法（Ratio syntax）"
"分数（ratio）的打印表示是由斜杠（" { $snippet "/" } "）分隔的一对整数。分数也可以通过在一个整数部分后跟 " { $snippet "+" } " 或 " { $snippet "-" } "（与整数的符号匹配）再加一个分数来写成带分数形式。在分数字面量中不允许有中间空格。以下是一些示例："
{ $code
    "75/33"
    "1/10"
    "1+1/3"
    "-10-1/7"
}
"有关分数的更多信息可以在 " { $link "rationals" } " 中找到。" ;

ARTICLE: "syntax-floats" "浮点数语法（Float syntax）"
"当字面量数字包含小数点或指数时，指定为浮点数（float）字面量。指数由 " { $snippet "e" } " 或 " { $snippet "E" } " 标记："
{ $code
    "10.5"
    "-3.1456"
    "7e13"
    "1.0e-5"
    "1.0E+5"
}
"没有小数点或指数的字面量数字始终解析为整数："
{ $example
    "1 float? ."
    "f"
}
{ $example
    "1. float? ."
    "t"
}
{ $example
    "1e0 float? ."
    "t"
}
"分数的浮点近似字面量也可以通过在小数点分母中放置小数点来输入："
{ $example
    "1/2. ."
    "0.5"
}
{ $example
    "1/3. ."
    "0.3333333333333333"
}
{ $example
    "1+1/2. ."
    "1.5"
}
"特殊的浮点数值有自己的语法："
{ $table
{ "正无穷大（Positive infinity）" { $snippet "1/0." } }
{ "负无穷大（Negative infinity）" { $snippet "-1/0." } }
{ "非数-正（Not-a-number (positive)）" { $snippet "0/0." } }
{ "非数-负（Not-a-number (negative)）" { $snippet "-0/0." } }
}
"也可以输入带有任意载荷的非数字面量："
{ $subsections POSTPONE: NAN: }
"要查看您平台上 " { $snippet "0/0." } " 的 64 位值，请执行以下代码："
{ $code
    "USING: io math math.parser ;"
    "\"NAN: \" write 0/0. double>bits >hex print"
}
"也支持十六进制、八进制和二进制浮点数字面量。这些由带有小数点的十六进制、八进制或二进制字面量以及一个强制的基数为二的指数组成，指数以 " { $snippet "p" } " 或 " { $snippet "P" } " 后面的十进制数表示："
{ $example
    "8.0 0x1.0p3 = ."
    "t"
}
{ $example
    "-1024.0 -0x1.0P10 = ."
    "t"
}
{ $example
    "10.125 0x1.44p3 = ."
    "t"
}
{ $example
    "10.125 0b1.010001p3 = ."
    "t"
}
{ $example
    "10.125 0o1.21p3 = ."
    "t"
}
"规范化十六进制形式 " { $snippet "±0x1.MMMMMMMMMMMMMp±EEEE" } " 允许精确指定任何浮点数。MMMMMMMMMMMMM 和 EEEE 的值直接映射到二进制 IEEE 754 表示的尾数和指数字段。"
$nl
"有关浮点数的更多信息可以在 " { $link "floats" } " 中找到。" ;

ARTICLE: "syntax-complex-numbers" "复数语法（Complex number syntax）"
"复数（complex number）由两个分量给出，一个\"实部\"和一个\"虚部\"。分量必须是整数、分数或浮点数。"
{ $code
    "C{ 1/2 1/3 }   ! 复数 1/2+1/3i"
    "C{ 0 1 }       ! 虚数单位"
}
{ $subsections POSTPONE: C{ }
"有关复数的更多信息可以在 " { $link "complex-numbers" } " 中找到。" ;

ARTICLE: "syntax-numbers" "数字语法（Number syntax）"
"如果词法单元的词汇表查找失败，解析器会尝试将其解析为数字。"
{ $subsections
    "syntax-integers"
    "syntax-ratios"
    "syntax-floats"
    "syntax-complex-numbers"
} ;

ARTICLE: "syntax-words" "词语法（Word syntax）"
"出现在引用（quotation）中的词在引用被调用时执行。有时需要将词本身推送到数据栈上。这一操作的典型用例是将词传递给 " { $link execute } " 组合子（combinator），或者通过反射访问词属性（" { $link "word-props" } "）。"
{ $subsections
    POSTPONE: \
    POSTPONE: POSTPONE:
}
"" { $link POSTPONE: \ } " 词的实现在 " { $link "reading-ahead" } " 中详细讨论。词的相关文档在 " { $link "words" } " 中。" ;

ARTICLE: "escape" "字符转义码（Character escape codes）"
{ $table
    { { $strong "转义码（Escape code）" } { $strong "含义" } }
    { { $snippet "\\\\" } { $snippet "\\" } }
    { { $snippet "\\s" } "一个空格" }
    { { $snippet "\\t" } "一个制表符" }
    { { $snippet "\\n" } "一个换行符" }
    { { $snippet "\\r" } "一个回车符" }
    { { $snippet "\\b" } "一个退格符（ASCII 8）" }
    { { $snippet "\\v" } "一个垂直制表符（ASCII 11）" }
    { { $snippet "\\f" } "一个换页符（ASCII 12）" }
    { { $snippet "\\0" } "一个空字节（ASCII 0）" }
    { { $snippet "\\e" } "转义（ASCII 27）" }
    { { $snippet "\\\"" } { $snippet "\"" } }
    { { $snippet "\\x" { $emphasis "xx" } } { "十六进制编号为 " { $snippet { $emphasis "xx" } } " 的 Unicode 码点" } }
    { { $snippet "\\u" { $emphasis "xxxxxx" } } { "十六进制编号为 " { $snippet { $emphasis "xxxxxx" } } " 的 Unicode 码点" } }
    { { $snippet "\\u{" { $emphasis "xx" } "}" } { "十六进制编号为 " { $snippet { $emphasis "xx" } } " 的 Unicode 码点" } }
    { { $snippet "\\u{" { $emphasis "name" } "}" } { "名称为 " { $snippet { $emphasis "name" } } " 的 Unicode 码点" } }
    { { $snippet "\\xxx" } "由一个、两个或三个八进制数字指定的八进制转义" }
} ;

ARTICLE: "syntax-strings" "字符和字符串语法（Character and string syntax）"
"Factor 没有独立的字符类型。表示 Unicode 码点的整数可以通过指定字面量字符或其转义表示来读取。"
{ $subsections
    POSTPONE: CHAR:
    POSTPONE: "
    "escape"
}
"字符串（string）的相关文档在 " { $link "strings" } " 中。" ;

ARTICLE: "syntax-sbufs" "字符串缓冲区语法（String buffer syntax）"
{ $subsections POSTPONE: SBUF" }
"字符串缓冲区的相关文档在 " { $link "sbufs" } " 中。" ;

ARTICLE: "syntax-arrays" "数组语法（Array syntax）"
{ $subsections
    POSTPONE: {
    POSTPONE: }
}
"数组（array）的相关文档在 " { $link "arrays" } " 中。" ;

ARTICLE: "syntax-vectors" "向量语法（Vector syntax）"
{ $subsections POSTPONE: V{ }
"向量（vector）的相关文档在 " { $link "vectors" } " 中。" ;

ARTICLE: "syntax-hashtables" "哈希表语法（Hashtable syntax）"
{ $subsections POSTPONE: H{ }
{ $subsections POSTPONE: IH{ }
"哈希表（hashtable）的相关文档在 " { $link "hashtables" } " 和 " { $vocab-link "hashtables.identity" } " 中。" ;

ARTICLE: "syntax-hash-sets" "哈希集语法（Hash set syntax）"
{ $subsections POSTPONE: HS{ }
"哈希集的相关文档在 " { $link "hash-sets" } " 和 " { $vocab-link "hash-sets.identity" } " 中。" ;

ARTICLE: "syntax-tuples" "元组语法（Tuple syntax）"
{ $subsections POSTPONE: T{ }
"元组（tuple）的相关文档在 " { $link "tuples" } " 中。" ;

ARTICLE: "syntax-quots" "引用语法（Quotation syntax）"
{ $subsections
    POSTPONE: [
    POSTPONE: ]
}
"引用（quotation）的相关文档在 " { $link "quotations" } " 中。" ;

ARTICLE: "syntax-byte-arrays" "字节数组语法（Byte array syntax）"
{ $subsections POSTPONE: B{ }
"字节数组（byte array）的相关文档在 " { $link "byte-arrays" } " 中。" ;

ARTICLE: "syntax-pathnames" "路径名语法（Pathname syntax）"
{ $subsections POSTPONE: P" }
"路径名（pathname）的相关文档在 " { $link "io.pathnames" } " 中。" ;

ARTICLE: "syntax-effects" "栈效应语法（Stack effect syntax）"
"请注意，这 " { $emphasis "不是" } " 声明词的栈效应（stack effect）的语法。这会将一个 " { $link effect } " 实例推送到栈上供反射使用，用于诸如 " { $link define-declared } "、" { $link call-effect } " 和 " { $link execute-effect } " 等词。"
{ $subsections POSTPONE: ( }
{ $see-also "effects" "inference" "tools.inference" } ;

ARTICLE: "syntax-literals" "字面量（Literals）"
"许多不同类型的对象可以在解析时通过字面量语法构造。数字是一个特例，因为对数字的读取支持内置于解析器中。所有其他字面量都通过解析字（parsing word）构造。"
$nl
"如果引用（quotation）包含一个字面量对象，则每次执行该引用时都使用相同的字面量对象实例；也就是说，字面量是\"活的\"。"
$nl
"在词定义中使用可变对象字面量需要小心，因为如果这些对象被修改，实际的词定义也会被改变，这在大多数情况下不是您所期望的。字面量在传递给可能会修改它们的词之前应该先进行 " { $link clone } "。"
{ $subsections
    "syntax-numbers"
    "syntax-words"
    "syntax-quots"
    "syntax-arrays"
    "syntax-strings"
    "syntax-byte-arrays"
    "syntax-vectors"
    "syntax-sbufs"
    "syntax-hashtables"
    "syntax-hash-sets"
    "syntax-tuples"
    "syntax-pathnames"
    "syntax-effects"
} ;

ARTICLE: "syntax" "语法（Syntax）"
"Factor 有两种主要的语法形式：" { $emphasis "定义（definition）" } " 语法和 " { $emphasis "字面量（literal）" } " 语法。代码即数据，因此代码的语法是对象字面量语法的一种特例。本节记录字面量语法。定义语法的相关内容在 " { $link "words" } " 中。扩展解析器的内容主要在 " { $link "parser" } " 中。"
{ $subsections
    "parser-algorithm"
    "word-search"
    "top-level-forms"
    "syntax-literals"
    "syntax-immediate"
} ;

ABOUT: "syntax"

HELP: delimiter
{ $syntax ": foo ... ; delimiter" }
{ $description "将最近定义的词声明为分隔符（delimiter）。分隔符是那些仅作为嵌套块结尾才有效的词，由 " { $link parse-until } " 读取。分隔符不成对出现会导致解析错误。" } ;

HELP: deprecated
{ $syntax ": foo ... ; deprecated" }
{ $description "将最近定义的词声明为已弃用（deprecated）。如果加载了 " { $vocab-link "tools.deprecation" } " 词汇表，已弃用词的使用将被 " { $link "tools.errors" } " 系统记录。" }
{ $notes "使用已弃用词的代码仍然可以正常运行；这些错误纯粹是信息性的。但是，使用已弃用词的代码应当更新，因为已弃用词预计很快会被移除。" } ;

HELP: SYNTAX:
{ $syntax "SYNTAX: foo ... ;" }
{ $description "定义一个解析字（parsing word）。" }
{ $examples "在下面的示例中，" { $snippet "world" } " 词从未被调用，但其主体引用了一个会立即执行的解析字：" { $example "USE: io" "IN: scratchpad" "<< SYNTAX: HELLO \"Hello parser!\" print ; >>\n: world ( -- ) HELLO ;" "Hello parser!" } } ;

HELP: inline
{ $syntax ": foo ... ; inline" }
{ $description
    "将最近定义的词声明为内联词（inline word）。优化编译器（optimizing compiler）在编译对内联词的调用时会复制其定义。"
    $nl
    "组合子（combinator）必须被内联才能通过优化编译器编译——参见 " { $link "inference-combinators" } "。对于其他词来说，内联仅仅是一种优化。注意，那些本身可以独立编译的内联词也会被优化编译器编译。"
    $nl
    "非优化的引用编译器会忽略内联声明。"
} ;

HELP: recursive
{ $syntax ": foo ... ; recursive" }
{ $description "将最近定义的词声明为递归词（recursive word）。" }
{ $notes "此声明仅对于调用自身的 " { $link POSTPONE: inline } " 词是必需的。参见 " { $link "inference-recursive-combinators" } "。" } ;

HELP: foldable
{ $syntax ": foo ... ; foldable" }
{ $description
    "声明最近定义的词可以在编译时求值（compile-time evaluation），前提是所有输入都是字面量（literal）。可折叠词（foldable word）必须满足非常严格的约定："
    { $list
        "可折叠词不得有任何可观察的副作用，"
        "可折叠词必须终止——例如，一个计算数列直到收敛的词不应该是可折叠的，因为如果数列不收敛，编译将不会停止。"
        "可折叠词的输入和输出都必须是不可变的（immutable）。"
    }
    "最后一条限制确保像 " { $link clone } " 这样的词不满足可折叠词的约定。实际上，" { $link clone } " 如果输入是可变的，就会输出可变对象，因此在编译时对其求值是不合适的，因为这样做会导致对可变对象进行克隆然后修改的代码产生不正确的语义。"
}
{ $notes
    "如果一个词的调用点与词定义位于同一源文件中，则不会应用折叠优化。这是编译单元系统的副作用；参见 " { $link "compilation-units" } "。"
}
{ $examples "大多数数字操作都是可折叠的。例如，" { $snippet "2 2 +" } " 会编译成字面量 4，因为 " { $link + } " 被声明为可折叠的。" } ;

HELP: flushable
{ $syntax ": foo ... ; flushable" }
{ $description
    "声明最近定义的词没有副作用，因此编译器可以在输出未被使用时删除对该词的调用。"
    $nl
    "注意，许多词是可清除（flushable）但不可折叠的，例如 " { $link clone } " 和 " { $link <array> } "。"
} ;

HELP: t
{ $syntax "t" }
{ $values { "t" "规范的（canonical）真值" } }
{ $class-description "规范的真值，它是自身的一个实例。" } ;

HELP: f
{ $syntax "f" }
{ $values { "f" "唯一的假值" } }
{ $description "" { $link f } " 解析字将 " { $link f } " 对象添加到解析树中，同时也是其唯一实例为 " { $link f } " 对象的类。" { $link f } " 对象是唯一的假值，是唯一不为真的对象。" { $link f } " 对象不等于 " { $link f } " 类词，后者可以通过词包装器（word wrapper）语法压入栈中："
{ $code "f    ! 表示假值的唯一 f 对象\n\\ f  ! f 类词" } } ;

HELP: [
{ $syntax "[ elements... ]" }
{ $description "标记字面量引用（quotation）的开始。" }
{ $examples { $code "[ 1 2 3 ]" } } ;

{ POSTPONE: [ POSTPONE: ] } related-words

HELP: ]
{ $syntax "]" }
{ $description "标记字面量引用的结束。"
$nl
"解析字可以将此词用作通用的结束分隔符。" } ;

HELP: }
{ $syntax "}" }
{ $description "标记数组、向量、哈希表、复数、元组（tuple）或包装器（wrapper）的结束。"
$nl
"解析字可以将此词用作通用的结束分隔符。" } ;

{ POSTPONE: { POSTPONE: V{ POSTPONE: H{ POSTPONE: HS{ POSTPONE: C{ POSTPONE: T{ POSTPONE: W{ POSTPONE: } } related-words

HELP: {
{ $syntax "{ elements... }" }
{ $values { "elements" "对象列表" } }
{ $description "标记字面量数组（array）的开始。字面量数组由 " { $link POSTPONE: } } " 终止。" }
{ $examples { $code "{ 1 2 3 }" } } ;

HELP: V{
{ $syntax "V{ elements... }" }
{ $values { "elements" "对象列表" } }
{ $description "标记字面量向量（vector）的开始。字面量向量由 " { $link POSTPONE: } } " 终止。" }
{ $examples { $code "V{ 1 2 3 }" } } ;

HELP: B{
{ $syntax "B{ elements... }" }
{ $values { "elements" "整数列表" } }
{ $description "标记字面量字节数组（byte array）的开始。字面量字节数组由 " { $link POSTPONE: } } " 终止。" }
{ $examples { $code "B{ 1 2 3 }" } } ;

HELP: intersection{
{ $syntax "intersection{ elements... }" }
{ $values { "elements" "类群（classoid）列表" } }
{ $description "标记字面量 " { $link anonymous-intersection } " 类的开始。" } ;

HELP: maybe{
{ $syntax "maybe{ elements... }" }
{ $values { "elements" "类群（classoid）列表" } }
{ $description "标记字面量 " { $link maybe } " 类的开始。" } ;

HELP: not{
{ $syntax "not{ elements... }" }
{ $values { "elements" "类群（classoid）列表" } }
{ $description "标记字面量 " { $link anonymous-complement } " 类的开始。" } ;

HELP: union{
{ $syntax "union{ elements... }" }
{ $values { "elements" "类群（classoid）列表" } }
{ $description "标记字面量 " { $link anonymous-union } " 类的开始。" } ;

{ POSTPONE: intersection{ POSTPONE: union{ POSTPONE: not{ POSTPONE: maybe{ } related-words

HELP: H{
{ $syntax "H{ { key value }... }" }
{ $values { "key" object } { "value" object } }
{ $description "标记字面量哈希表（hashtable）的开始，以包含键/值对的二元数组列表形式给出。字面量哈希表由 " { $link POSTPONE: } } " 终止。" }
{ $examples { $code "H{ { \"tuna\" \"fish\" } { \"jalapeno\" \"vegetable\" } }" } } ;

HELP: HS{
{ $syntax "HS{ members ... }" }
{ $values { "members" "对象列表" } }
{ $description "标记字面量哈希集合（hash set）的开始，以其成员列表形式给出。字面量哈希集合由 " { $link POSTPONE: } } " 终止。" }
{ $examples { $code "HS{ 3 \"foo\" }" } } ;

HELP: IH{
{ $syntax "IH{ { key value }... }" }
{ $values { "key" object } { "value" object } }
{ $description "标记字面量标识哈希表（identity hashtable）的开始，以包含键/值对的二元数组列表形式给出。字面量标识哈希表由 " { $link POSTPONE: } } " 终止。" }
{ $examples { $code "IH{ { \"tuna\" \"fish\" } { \"jalapeno\" \"vegetable\" } }" } } ;

HELP: C{
{ $syntax "C{ real-part imaginary-part }" }
{ $values { "real-part" "一个实数" } { "imaginary-part" "一个实数" } }
{ $description "解析一个以直角坐标形式给出的复数（complex number），即一对实数。字面量复数由 " { $link POSTPONE: } } " 终止。" } ;

HELP: T{
{ $syntax "T{ class }" "T{ class f slot-values... }" "T{ class { slot-name slot-value } ... }" }
{ $values { "class" "一个元组类词（tuple class word）" } { "slots" "槽值（slot value）" } }
{ $description "标记字面量元组（tuple）的开始。"
$nl
"支持三种字面量语法形式："
{ $list
    { "空元组形式：如果未指定槽值，则字面量元组的所有槽将设置为其初始值（参见 " { $link "slot-initial-values" } "）。" }
    { "BOA 形式：如果 " { $snippet "slots" } " 的第一个元素是 " { $snippet "f" } "，则其余元素是按照 " { $link POSTPONE: TUPLE: } " 形式中定义顺序对应的槽值。" }
    { "关联形式：否则，" { $snippet "slots" } " 被解释为一系列 " { $snippet "{ slot-name value }" } " 对。" { $snippet "slot-name" } " 不应加引号。" }
}
"BOA 形式更简洁，而关联形式对于具有许多槽的大型元组或只需指定少数槽的情况更易读。"
$nl
"使用 BOA 形式时，如果在类词之后指定的值数量不足，元组的剩余槽将设置为其初始值（参见 " { $link "slot-initial-values" } "）。如果给定的值过多，将引发错误。" }
{ $examples
"一个空元组；由于向量有自己的字面量语法，上述等价于 " { $snippet "V{ }" } ""
{ $code "T{ vector }" }
"一个 BOA 形式元组："
{ $code
    "USE: colors"
    "T{ rgba f 1.0 0.0 0.5 }"
}
"一个与上述等价的关联形式元组："
{ $code
    "USE: colors"
    "T{ rgba { red 1.0 } { green 0.0 } { blue 0.5 } }"
} } ;

HELP: W{
{ $syntax "W{ object }" }
{ $values { "object" object } }
{ $description "标记字面量包装器（wrapper）的开始。字面量包装器由 " { $link POSTPONE: } } " 终止。" } ;

HELP: POSTPONE:
{ $syntax "POSTPONE: word" }
{ $values { "word" word } }
{ $description "从输入字符串中读取下一个词，并将该词追加到解析树中，即使它是一个解析字。" }
{ $examples "对于普通词 " { $snippet "foo" } "，" { $snippet "foo" } " 与 " { $snippet "POSTPONE: foo" } " 是等价的；然而，如果 " { $snippet "foo" } " 是一个解析字，前者会在解析时执行它，而后者会在运行时执行它。" }
{ $notes "此词在解析字内部用于将后续操作委托给另一个解析字，也用于在字面量数组等中按字面引用解析字。" } ;

HELP: :
{ $syntax ": word ( stack -- effect ) definition... ;" }
{ $values { "word" "要定义的新词" } { "definition" "一个词定义" } }
{ $description "在当前词汇表中定义一个具有给定栈效果（stack effect）的词。" }
{ $examples { $code ": ask-name ( -- name )\n    \"What is your name? \" write readln ;\n: greet ( name -- )\n    \"Greetings, \" write print ;\n: friend ( -- )\n    ask-name greet ;" } } ;

{ POSTPONE: : POSTPONE: ; define } related-words

HELP: ;
{ $syntax ";" }
{ $description
    "标记定义的结束。"
    $nl
    "解析字可以将此词用作通用的结束分隔符。"
} ;

HELP: SYMBOL:
{ $syntax "SYMBOL: word" }
{ $values { "word" "要定义的新词" } }
{ $description "在当前词汇表中定义一个新的符号词（symbol word）。符号在执行时将自己压入栈中，用于标识变量（参见 " { $link "namespaces" } "）以及在词属性中存储附加数据（参见 " { $link "word-props" } "）。" }
{ $examples { $example "USE: prettyprint" "IN: scratchpad" "SYMBOL: foo\nfoo ." "foo" } } ;

{ define-symbol POSTPONE: SYMBOL: POSTPONE: SYMBOLS: } related-words

HELP: SYMBOLS:
{ $syntax "SYMBOLS: words... ;" }
{ $values { "words" { $sequence "要定义的新词" } } }
{ $description "为直到 " { $snippet ";" } " 之前的每个词法单元（token）创建一个新符号。" }
{ $examples { $example "USING: prettyprint ;" "IN: scratchpad" "SYMBOLS: foo bar baz ;\nfoo . bar . baz ." "foo\nbar\nbaz" } } ;

HELP: INITIALIZED-SYMBOL:
{ $syntax "INITIALIZED-SYMBOL: word [ ... ]"  }
{ $description "定义一个新符号 " { $snippet "word" } " 并在全局命名空间（global namespace）中设置其值。" }
{ $examples
    { $unchecked-example
        "USING: math namespaces prettyprint ;"
        "INITIALIZED-SYMBOL: foo [ 15 sq ]"
        "foo get-global ."
        "225"
    }
} ;

HELP: SINGLETON:
{ $syntax "SINGLETON: class" }
{ $values
    { "class" "要定义的新单例（singleton）" }
}
{ $description
    "定义一个新的单例类（singleton class）。类词本身是该单例类的唯一实例。"
}
{ $examples
    { $example "USING: classes.singleton kernel io ;" "IN: singleton-demo" "USE: prettyprint\nSINGLETON: foo\nGENERIC: bar ( obj -- )\nM: foo bar drop \"a foo!\" print ;\nfoo bar" "a foo!" }
} ;

HELP: SINGLETONS:
{ $syntax "SINGLETONS: words... ;" }
{ $values { "words" { $sequence "要定义的新词" } } }
{ $description "为直到 " { $snippet ";" } " 之前的每个词法单元创建一个新单例。" } ;

HELP: ALIAS:
{ $syntax "ALIAS: new-word existing-word" }
{ $values { "new-word" word } { "existing-word" word } }
{ $description "创建一个新的内联词，该词调用已有的词。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
               "IN: alias.test"
               "ALIAS: sequence-nth nth"
               "0 { 10 20 30 } sequence-nth ."
               "10"
    }
} ;

{ define-alias POSTPONE: ALIAS: } related-words

HELP: CONSTANT:
{ $syntax "CONSTANT: word value" }
{ $values { "word" word } { "value" object } }
{ $description "创建一个将值压入栈中的词。" }
{ $examples { $code "CONSTANT: magic 1" "CONSTANT: science 0xff0f" } } ;

{ define-constant POSTPONE: CONSTANT: } related-words

HELP: \
{ $syntax "\\ word" }
{ $values { "word" word } }
{ $description "从输入中读取下一个词，并将一个包含该词的包装器追加到解析树中。当求值器遇到包装器时，它将被包装的词原样压入数据栈上。" }
{ $examples "以下两行是等价的：" { $code "0 \\ <vector> execute\n0 <vector>" } "如果 " { $snippet "foo" } " 是一个符号，以下两行是等价的：" { $code "foo" "\\ foo" } } ;

HELP: DEFER:
{ $syntax "DEFER: word" }
{ $values { "word" "要定义的新词" } }
{ $description "在当前词汇表中创建一个词，该词在执行时仅引发错误。通常，该词将稍后被真正的定义替换。" }
{ $notes "由于解析器的工作方式，词在被定义之前不能被引用；也就是说，源文件必须按严格自底向上的顺序排列定义。相互递归的词对可以通过 " { $emphasis "延迟定义（deferring）" } " 其中一个词来实现，使得该词对中的第二个词能够解析，然后再定义第一个词。" }
{ $examples { $code "DEFER: foe\n: fie ... foe ... ;\n: foe ... fie ... ;" } } ;

HELP: FORGET:
{ $syntax "FORGET: word" }
{ $values { "word" word } }
{ $description "从其词汇表中移除该词，如果不存在这样的词则不做任何操作。引用已遗忘词（forgotten word）的现有定义将继续工作，但该词的新出现将无法解析。" } ;

HELP: USE:
{ $syntax "USE: vocabulary" }
{ $values { "vocabulary" "词汇表名称" } }
{ $description "将一个新的词汇表（vocabulary）添加到搜索路径（search path）中，如有必要会先加载它。" }
{ $notes "如果添加词汇表引入了歧义（ambiguous），引用歧义名称时将抛出 " { $link ambiguous-use-error } " 错误。你可以通过在名称前加上词汇表名称和冒号来消除歧义：" { $snippet "vocabulary:word" } "。" }
{ $errors "如果词汇表不存在或无法加载，则抛出错误。" }
{ $examples "以下两个代码片段是等价的。"
    { $example
    "USE: math USE: prettyprint"
    "1 2 + ."
    "3" }
    { $example
    "USE: math USE: prettyprint"
    "1 2 math:+ prettyprint:."
    "3" }
}
{ $see-also \ USING: \ QUALIFIED: } ;

HELP: UNUSE:
{ $syntax "UNUSE: vocabulary" }
{ $values { "vocabulary" "词汇表名称" } }
{ $description "从搜索路径（search path）中移除一个词汇表（vocabulary）。" } ;

HELP: USING:
{ $syntax "USING: vocabularies... ;" }
{ $values { "vocabularies" "词汇表名称列表" } }
{ $description "将一组词汇表（vocabulary）添加到搜索路径（search path）中。" }
{ $notes "如果添加词汇表引入了歧义（ambiguous），引用歧义名称时将抛出 " { $link ambiguous-use-error } " 错误。你可以通过在名称前加上词汇表名称和冒号来消除歧义：" { $snippet "vocabulary:word" } "。" }
{ $errors "如果某个词汇表不存在，则抛出错误。" }
{ $examples "以下两个代码片段是等价的。"
    { $example
    "USING: math prettyprint ;"
    "1 2 + ."
    "3" }
    { $example
    "USING: math prettyprint ;"
    "1 2 math:+ prettyprint:."
    "3" }
}
{ $see-also \ USE: \ QUALIFIED: } ;

HELP: QUALIFIED:
{ $syntax "QUALIFIED: vocab" }
{ $description "将词汇表（vocabulary）中的词（word），以词汇表名称为前缀，添加到搜索路径（search path）中。" }
{ $deprecated "此词已被弃用，因为 Factor 词现在默认就可以作为限定词使用。" { $link POSTPONE: QUALIFIED-WITH: } " 可用于更改限定前缀。" }
{ $notes "如果添加词汇表引入了歧义（ambiguous），在解析任何歧义名称时该词汇表将优先。这是一种罕见的情况；例如，假设词汇表 " { $snippet "fish" } " 定义了一个名为 " { $snippet "go:fishing" } " 的词（word），而词汇表 " { $snippet "go" } " 定义了一个名为 " { $snippet "fishing" } " 的词。那么，以下代码将调用后一个词："
  { $code
  "USE: fish"
  "QUALIFIED: go"
  "go:fishing"
  }
}
{ $examples { $example
    "USING: prettyprint ;"
    "QUALIFIED: math"
    "1 2 math:+ ."
    "3"
} } ;

HELP: QUALIFIED-WITH:
{ $syntax "QUALIFIED-WITH: vocab word-prefix" }
{ $description "类似于 " { $link POSTPONE: QUALIFIED: } "，但使用 " { $snippet "word-prefix" } " 作为前缀。" }
{ $examples { $example
    "USING: prettyprint ;"
    "QUALIFIED-WITH: math m"
    "1 2 m:+ ."
    "3"
} } ;

HELP: FROM:
{ $syntax "FROM: vocab => words ... ;" }
{ $description "将 " { $snippet "vocab" } " 中的 " { $snippet "words" } " 添加到搜索路径（search path）中。" }
{ $notes "如果添加这些词（word）引入了歧义（ambiguous），在解析任何歧义名称时这些词将优先。" }
{ $examples
  "词汇表 " { $vocab-link "vocabs.parser" } " 和 " { $vocab-link "binary-search" } " 都定义了一个名为 " { $snippet "search" } " 的词。以下代码将抛出 " { $link ambiguous-use-error } " 错误："
  { $code "USING: vocabs.parser binary-search ;" "... search ..." }
  "由于 " { $link POSTPONE: FROM: } " 优先于 " { $link POSTPONE: USING: } "，可以显式解决歧义。假设你想要 " { $vocab-link "binary-search" } " 词汇表中的 " { $snippet "search" } " 词："
  { $code "USING: vocabs.parser binary-search ;" "FROM: binary-search => search ;" "... search ..." }
} ;

HELP: EXCLUDE:
{ $syntax "EXCLUDE: vocab => words ... ;" }
{ $description "将 " { $snippet "vocab" } " 中除 " { $snippet "words" } " 之外的所有词（word）添加到搜索路径（search path）中。" }
{ $examples { $code
    "EXCLUDE: math.parser => bin> hex> ;" "! imports everything but bin> and hex>" } } ;

HELP: RENAME:
{ $syntax "RENAME: word vocab => new-name" }
{ $description "从 " { $snippet "vocab" } " 导入 " { $snippet "word" } "，但重命名为 " { $snippet "new-name" } "。" }
{ $notes "如果添加这些词（word）引入了歧义（ambiguous），在解析任何歧义名称时这些词将优先。" }
{ $examples { $example
    "USING: prettyprint ;"
    "RENAME: + math => -"
    "2 3 - ."
    "5"
} } ;

HELP: IN:
{ $syntax "IN: vocabulary" }
{ $values { "vocabulary" "新词汇表名称" } }
{ $description "设置当前词汇表（vocabulary），新词（word）将定义在其中。如果词汇表不存在则先创建它。词汇表创建后，可以列在 " { $link POSTPONE: USE: } " 和 " { $link POSTPONE: USING: } " 声明中使用。" } ;

HELP: CHAR:
{ $syntax "CHAR: token" }
{ $values { "token" "一个字面字符、转义码（escape code）或 Unicode 码点名称" } }
{ $description "将一个 Unicode 码点（Unicode code point）添加到解析树（parse tree）中。" }
{ $examples
    { $code
        "CHAR: x"
        "CHAR: \\x32"
        "CHAR: \\u000032"
        "CHAR: \\u{32}"
        "CHAR: \\u{exclamation-mark}"
        "CHAR: exclamation-mark"
        "CHAR: ugaritic-letter-samka"
    }
} ;

HELP: "
{ $syntax "\"string...\"" }
{ $values { "string" "字面字符和转义字符" } }
{ $description "从输入字符串中读取，直到遇到下一个 " { $snippet "\"" } " 为止，并将生成的字符串（string）追加到解析树（parse tree）中。字符串字面量可以跨越多行。可以通过插入 " { $link "escape" } " 来读取各种特殊字符。" }
{ $examples
    "包含转义换行符的字符串："
    { $example "USE: io" "\"Hello\\nworld\" print" "Hello\nworld" }
    "包含实际换行符的字符串："
    { $example "USE: io" "\"Hello\nworld\" print" "Hello\nworld" }
    "包含命名的 Unicode 码点的字符串："
    { $example "USE: io" "\"\\u{greek-capital-letter-sigma}\" print" "\u{greek-capital-letter-sigma}" }
} ;

HELP: SBUF"
{ $syntax "SBUF\" string... \"" }
{ $values { "string" "字面字符和转义字符" } }
{ $description "从输入字符串中读取，直到遇到下一个 " { $link POSTPONE: " } " 为止，将字符串转换为字符串缓冲区（string buffer），然后追加到解析树（parse tree）中。" }
{ $examples { $example "USING: io strings ;" "SBUF\" Hello world\" >string print" "Hello world" } } ;

HELP: P"
{ $syntax "P\" pathname\"" }
{ $values { "pathname" "路径名字符串" } }
{ $description "从输入字符串中读取，直到遇到下一个 " { $link POSTPONE: " } " 为止，创建一个新的 " { $link pathname } "，然后追加到解析树（parse tree）中。在 UI 中呈现的路径名（pathname）是可点击的，点击后会使用 " { $link "editor" } " 配置的文本编辑器打开它。" }
{ $examples { $example "USING: accessors io io.files ;" "P\" foo.txt\" string>> print" "foo.txt" } } ;

HELP: (
{ $syntax "( inputs -- outputs )" }
{ $values { "inputs" "标记列表" } { "outputs" "标记列表" } }
{ $description "字面的栈效应（stack effect）语法。也用于语法词（parsing word）（如 " { $link POSTPONE: : } "），通常用于声明其后词定义的栈效应。" }
{ $notes "在使用 " { $link define-declared } " 进行元编程（meta-programming）时很有用。" }
{ $examples
    { $example
        "USING: compiler.units kernel math prettyprint random words ;"
        "IN: scratchpad"
        ""
        "SYMBOL: my-dynamic-word"
        ""
        "["
        "    my-dynamic-word 2 { [ + ] [ * ] } random curry"
        "    ( x -- y ) define-declared"
        "] with-compilation-unit"
        ""
        "2 my-dynamic-word ."
        "4"
    }
}
{ $see-also "effects" }
;

HELP: NAN:
{ $syntax "NAN: payload" }
{ $values { "payload" "64位十六进制整数（64-bit hexadecimal integer）" } }
{ $description "向解析树中添加一个浮点数非数值（Not-a-Number）字面量。" }
{ $examples
    { $example
        "USE: prettyprint"
        "NAN: 80000deadbeef ."
        "NAN: 80000deadbeef"
    }
} ;

HELP: GENERIC:
{ $syntax "GENERIC: word ( stack -- effect )" }
{ $values { "word" "要定义的新词（a new word to define）" } }
{ $description "在当前词汇表中定义一个新的泛型词（generic word）。该词根据栈顶元素进行分发（dispatch）。初始时不包含任何方法（method），因此调用时会抛出一个 " { $link no-method } " 错误。" } ;

HELP: GENERIC#:
{ $syntax "GENERIC#: word n ( stack -- effect )" }
{ $values { "word" "要定义的新词" } { "n" "要据此进行分发的栈位置" } }
{ $description "在当前词汇表中定义一个新的泛型词（generic word）。该词根据从栈顶算起的第 " { $snippet "n" } " 个元素进行分发（dispatch）。初始时不包含任何方法（method），因此调用时会抛出一个 " { $link no-method } " 错误。" }
{ $notes
    "以下两种定义是等价的："
    { $code "GENERIC: foo ( x y z obj -- )" }
    { $code "GENERIC#: foo 0 ( x y z obj -- )" }
} ;

HELP: MATH:
{ $syntax "MATH: word" }
{ $values { "word" "要定义的新词" } }
{ $description "定义一个新的泛型词（generic word），该词使用 " { $link math-combination } " 方法组合（method combination）。" } ;

HELP: HOOK:
{ $syntax "HOOK: word variable ( stack -- effect )" }
{ $values { "word" "要定义的新词" } { "variable" word } }
{ $description "在当前词汇表中定义一个新的钩子词（hook word）。钩子词是泛型词（generic word），它们根据某个变量的值进行分发（dispatch），因此其方法（method）使用 " { $link POSTPONE: M: } " 定义。钩子词与其他泛型词的不同之处在于，分发值会在调用所选方法之前从栈中移除。" }
{ $examples
    { $example
        "USING: io namespaces ;"
        "IN: scratchpad"
        "SYMBOL: transport"
        "TUPLE: land-transport ;"
        "TUPLE: air-transport ;"
        "HOOK: deliver transport ( destination -- )"
        "M: land-transport deliver \"Land delivery to \" write print ;"
        "M: air-transport deliver \"Air delivery to \" write print ;"
        "T{ air-transport } transport set"
        "\"New York City\" deliver"
        "Air delivery to New York City"
    }
}
{ $notes
    "钩子词本质上就是带有自定义方法组合（method combination）的泛型词（参见 " { $link "method-combination" } "）。"
} ;

HELP: M:
{ $syntax "M: class generic definition... ;" }
{ $values { "class" "一个类词（a class word）" } { "generic" "一个泛型词（a generic word）" } { "definition" "一个方法定义（a method definition）" } }
{ $description "定义一个方法（method），即为泛型词（generic word）指定一个针对该类实例的专门行为。" } ;

HELP: UNION:
{ $syntax "UNION: class members... ;" }
{ $values { "class" "要定义的新类词" } { "members" "由空格分隔的类词列表" } }
{ $description "定义一个并集类（union class）。如果一个对象是其中任何一个成员类的实例，那么它就是该并集类的实例。" } ;

HELP: INTERSECTION:
{ $syntax "INTERSECTION: class participants... ;" }
{ $values { "class" "要定义的新类词" } { "participants" "由空格分隔的类词列表" } }
{ $description "定义一个交集类（intersection class）。如果一个对象是所有参与类的实例，那么它就是该交集类的实例。" } ;

HELP: MIXIN:
{ $syntax "MIXIN: class" }
{ $values { "class" "要定义的新类词" } }
{ $description "定义一个混入类（mixin class）。混入类类似于并集类（union class），不同之处在于它初始时没有成员，新成员可以通过 " { $link POSTPONE: INSTANCE: } " 词添加。" }
{ $examples "" { $link sequence } " 和 " { $link assoc } " 混入类。" } ;

HELP: INSTANCE:
{ $syntax "INSTANCE: instance mixin" }
{ $values { "instance" "一个类词（a class word）" } { "mixin" "一个混入类词（a mixin class word）" } }
{ $description "使 " { $snippet "instance" } " 成为 " { $snippet "mixin" } " 的一个实例。" } ;

HELP: PREDICATE:
{ $syntax "PREDICATE: class < superclass predicate... ;" }
{ $values { "class" "要定义的新类词" } { "superclass" "一个已有的类词" } { "predicate" "成员资格测试，其栈效果为 " { $snippet "( superclass -- ? )" } } }
{ $description
    "定义一个派生自 " { $snippet "superclass" } " 的谓词类（predicate class）。"
    $nl
    "一个对象是谓词类的实例，当且仅当同时满足以下两个条件："
    { $list
        "它是该谓词超类（superclass）的一个实例，"
        "它满足该谓词条件"
    }
    "每个谓词类必须定义为某个其他类的子类。这确保了继承自互不相交的类的谓词，在方法分发（method dispatch）期间不需要被穷举测试。"
}
{ $examples
    { $code "USING: math ;" "PREDICATE: positive < integer 0 > ;" }
} ;

HELP: TUPLE:
{ $syntax "TUPLE: class slots... ;" "TUPLE: class < superclass slots ... ;" }
{ $values { "class" "要定义的新元组类（tuple class）" } { "slots" "槽（slot）说明符的列表" } }
{ $description "定义一个新的元组类（tuple class）。"
$nl
"超类（superclass）是可选的；如果未指定，则默认为 " { $link tuple } "。"
$nl
"槽说明符（slot specifier）可采用以下三种形式之一："
{ $list
    { { $snippet "name" } " - 一个可容纳任何对象的槽（slot），无属性" }
    { { $snippet "{ name attributes... }" } " - 一个可容纳任何对象的槽，可带有可选属性" }
    { { $snippet "{ name class attributes... }" } " - 一个特定于某一类的槽，可带有可选属性" }
}
"槽属性（slot attribute）是由槽属性说明符及其值组成的列表；槽属性说明符可以是 " { $link initial: } " 或 " { $link read-only } " 之一。详细信息参见 " { $link "tuple-declarations" } "。" }
{ $examples
    "一个简单的元组类："
    { $code "TUPLE: color red green blue ;" }
    "将槽声明为整数值类型："
    { $code "TUPLE: color" "{ red integer }" "{ green integer }" "{ blue integer } ;" }
    "一个混合使用简短和完整槽说明符的示例："
    { $code "TUPLE: person" "{ age integer initial: 0 }" "{ department string initial: \"Marketing\" }" "manager ;" }
} ;

HELP: final
{ $syntax "TUPLE: ... ; final" }
{ $description "将最近定义的词声明为一个最终元组类（final tuple class），该类不能被继承。尝试继承一个最终类会引发一个 " { $link bad-superclass } " 错误。" } ;

HELP: initial:
{ $syntax "TUPLE: ... { slot initial: value } ... ;" }
{ $values { "slot" "一个槽名称" } { "value" "任意字面量" } }
{ $description "为元组槽（tuple slot）指定一个初始值（initial value）。" } ;

HELP: read-only
{ $syntax "TUPLE: ... { slot read-only } ... ;" }
{ $values { "slot" "一个槽名称" } }
{ $description "将元组槽定义为只读（read-only）。如果元组具有只读槽，则元组实例只能通过调用 " { $link boa } " 来创建，而不能使用 " { $link new } "。使用 " { $link boa } " 是设置只读槽值的唯一方式。" } ;

{ initial: read-only } related-words

HELP: SLOT:
{ $syntax "SLOT: name" }
{ $values { "name" "一个槽名称" } }
{ $description "定义一个协议槽（protocol slot）；即为名为 " { $snippet "slot" } " 的槽定义存取器词（accessor word），而不将其与任何特定的元组关联。" } ;

HELP: ERROR:
{ $syntax "ERROR: class slots... ;" }
{ $values { "class" "要定义的新元组类" } { "slots" "槽名称列表" } }
{ $description "定义一个新的元组类以及一个词 " { $snippet "classname" } "，该词会抛出一个新的错误实例。" }
{ $notes
    "以下两段代码是等价的："
    { $code
        "ERROR: invalid-values x y ;"
    }
    $nl
    { $code
        "TUPLE: invalid-values x y ;"
        ": invalid-values ( x y -- * )"
        "    \\ invalid-values boa throw ;"
    }
} ;

HELP: C:
{ $syntax "C: constructor class" }
{ $values { "constructor" "要定义的新词" } { "class" tuple-class } }
{ $description "为元组类定义一个构造器词（constructor word），该词使用 " { $link boa } " 来执行 BOA（按参数顺序）构造。" }
{ $examples
    "假设已定义以下元组："
    { $code "TUPLE: color red green blue ;" }
    "以下两行是等价的："
    { $code
        "C: <color> color"
        ": <color> ( red green blue -- color ) color boa ;"
    }
    "在这两种情况下，都会定义一个词 " { $snippet "<color>" } "，它从栈中读取三个值，并创建一个 " { $snippet "color" } " 实例，这些值分别被放入 " { $snippet "red" } "、" { $snippet "green" } " 和 " { $snippet "blue" } " 槽中。"
} ;

HELP: MAIN:
{ $syntax "MAIN: word" }
{ $values { "word" word } }
{ $description "为当前词汇表和源文件定义主入口点（entry point）。当该词汇表被传递给 " { $link run } " 或将源文件作为脚本运行时，将执行这个词。"
    $nl
    "如果传入的是一个引用（quotation）而不是一个词，则它将以同样的方式作为主入口点运行。"
} ;

HELP: <PRIVATE
{ $syntax "<PRIVATE ... PRIVATE>" }
{ $description "开始一个私有（private）词定义块。私有词定义被放置在当前词汇表名称后添加 " { $snippet ".private" } " 后缀的词汇表中。" }
{ $notes
    "以下是一个使用示例："
    { $code
        "IN: factorial"
        ""
        "<PRIVATE"
        ""
        ": (fac) ( accum n -- n! )"
        "    dup 1 <= [ drop ] [ [ * ] keep 1 - (fac) ] if ;"
        ""
        "PRIVATE>"
        ""
        ": fac ( n -- n! ) 1 swap (fac) ;"
    }
    "上述代码等价于："
    { $code
        "IN: factorial.private"
        ""
        ": (fac) ( accum n -- n! )"
        "    dup 1 <= [ drop ] [ [ * ] keep 1 - (fac) ] if ;"
        ""
        "IN: factorial"
        ""
        ": fac ( n -- n! ) 1 swap (fac) ;"
    }
} ;

HELP: PRIVATE>
{ $syntax "<PRIVATE ... PRIVATE>" }
{ $description "结束一个私有（private）词定义块。" } ;

{ POSTPONE: <PRIVATE POSTPONE: PRIVATE> } related-words

HELP: <<
{ $syntax "<< ... >>" }
{ $description "在解析时（parse time）求值一段代码。" }
{ $notes "禁止在解析时调用同一源文件中定义的词；请参见编译单元及其定义所在的位置；请参见 " { $link "compilation-units" } "。" } ;

HELP: >>
{ $syntax ">>" }
{ $description "标记解析时代码块的结束。" } ;

HELP: call-next-method
{ $syntax "call-next-method" }
{ $description "调用下一个可用的方法（method）。仅在方法定义内部有效。栈顶的值会被传递给下一个方法，这些值必须与该方法的类特化器（class specializer）兼容。" }
{ $notes "这个词看起来像一个普通的词，但它是一个解析词（parsing word）。它不能被提取出方法定义，因为其代码展开直接引用了当前的方法对象。" }
{ $errors
    "如果这是最不具体的方法，则抛出 " { $link no-next-method } " 错误；如果栈顶的值与当前方法的特化器不兼容，则抛出 " { $link inconsistent-next-method } " 错误。"
} ;

{ POSTPONE: call-next-method (call-next-method) next-method } related-words

{ POSTPONE: << POSTPONE: >> } related-words

HELP: call(
{ $syntax "call( stack -- effect )" }
{ $description "调用栈顶的引用（quotation），并断言（assert）它具有指定的栈效果。该引用不需要在编译时已知。" }
{ $examples
  { $code
    "TUPLE: action name quot ;"
    ": perform-action ( action -- )"
    "    [ name>> print ] [ quot>> call( -- ) ] bi ;"
  }
} ;

HELP: execute(
{ $syntax "execute( stack -- effect )" }
{ $description "调用栈顶的词，并断言（assert）它具有指定的栈效果。该词不需要在编译时已知。" }
{ $examples
  { $code
    "IN: scratchpad"
    ""
    ": eat ( -- ) ; : sleep ( -- ) ; : hack ( -- ) ;"
    "{ eat sleep hack } [ execute( -- ) ] each"
  }
} ;

{ POSTPONE: call( POSTPONE: execute( } related-words

HELP: BUILTIN:
{ $syntax "BUILTIN: class slots ... ;" }
{ $values { "class" "一个内置类（builtin class）" } { "definition" "一个词定义" } }
{ $description "表示来自虚拟机（VM）的一个内置类（builtin class）。这个词不能定义新的内置类型，而是用于提供一条书面记录，指明哪些词汇表定义了这些内置类型。要定义新的内置类型，需要将其添加到虚拟机中。" } ;

HELP: PRIMITIVE:
{ $syntax "PRIMITIVE: word ( stack -- effect )" }
{ $description "引用虚拟机（VM）的一个原语词（primitive word）。这个词不能定义新的原语，而是用于提供一条书面记录，指明哪些词汇表定义了这些原语。要定义新的原语，需要将其添加到虚拟机中。" } ;

HELP: MEMO:
{ $syntax "MEMO: word ( stack -- effect ) definition... ;" }
{ $values { "word" "要定义的新词" } { "definition" "一个词定义" } }
{ $description "在解析时将给定词定义为将针对特定输入对其输出进行记忆化（memoize）的词。栈效果是必需的。" } ;

HELP: IDENTITY-MEMO:
{ $syntax "IDENTITY-MEMO: word ( stack -- effect ) definition... ;" }
{ $values { "word" "要定义的新词" } { "definition" "一个词定义" } }
{ $description "在解析时将给定词定义为将针对特定输入对其输出进行记忆化（memoize）的词，其中输入通过标识相等性（identity）与另一输入进行比较。栈效果是必需的。" } ;

HELP: IDENTITY-MEMO::
{ $syntax "IDENTITY-MEMO:: word ( stack -- effect ) definition... ;" }
{ $values { "word" "要定义的新词" } { "definition" "一个词定义" } }
{ $description "在解析时将给定词定义为将针对特定输入对其输出进行记忆化（memoize）的词，其中输入带有本地变量（locals），并通过标识相等性（identity）与另一输入进行比较。栈效果是必需的。" } ;

HELP: STARTUP-HOOK:
{ $syntax "STARTUP-HOOK: word/quotation" }
{ $description "解析一个词或引用（quotation），并将其设置为当前词汇表的启动钩子（startup hook）。" } ;

HELP: SHUTDOWN-HOOK:
{ $syntax "SHUTDOWN-HOOK: word/quotation" }
{ $description "解析一个词或引用（quotation），并将其设置为当前词汇表的关闭钩子（shutdown hook）。" } ;
