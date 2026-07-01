USING: arrays assocs combinators combinators.private effects
generalizations generic.standard help.markup help.syntax kernel
kernel.private quotations sequences sequences.private words ;
IN: zh.core.combinators

ARTICLE: "cleave-combinators" "切割组合子（cleave combinators）"
"切割组合子（cleave combinators）将多个引用（quotation）应用于单个值或一组值。"
$nl
"两个引用："
{ $subsections
    bi
    2bi
    3bi
}
"三个引用："
{ $subsections
    tri
    2tri
    3tri
}
"引用数组："
{ $subsections
    cleave
    2cleave
    3cleave
    4cleave
}
"切割组合子（cleave combinators）比重复使用 " { $link keep } " 组合子提供了更具可读性的替代方案。以下使用 " { $link keep } " 的示例："
{ $code
    "[ 1 + ] keep"
    "[ 1 - ] keep"
    "2 *"
}
"使用 " { $link tri } " 可以更清晰地重写为："
{ $code
    "[ 1 + ]"
    "[ 1 - ]"
    "[ 2 * ] tri"
} ;

ARTICLE: "spread-combinators" "展开组合子（spread combinators）"
"展开组合子（spread combinators）将多个引用（quotation）应用于多个值。这些词名称后缀的星号（" { $snippet "*" } "）表示它们是展开组合子（spread combinators）。"
$nl
"两个引用："
{ $subsections bi* 2bi* }
"三个引用："
{ $subsections tri* 2tri* }
"引用数组："
{ $subsections spread }
"展开组合子（spread combinators）比重复使用 " { $link dip } " 组合子提供了更具可读性的替代方案。以下使用 " { $link dip } " 的示例："
{ $code
    "[ [ 1 + ] dip 1 - ] dip 2 *"
}
"使用 " { $link tri* } " 可以更清晰地重写为："
{ $code
    "[ 1 + ] [ 1 - ] [ 2 * ] tri*"
}
"将上述组合子推广到任意数量引用的泛化版本可以在 " { $link "combinators" } " 中找到。" ;

ARTICLE: "apply-combinators" "应用组合子（apply combinators）"
"应用组合子（apply combinators）将单个引用（quotation）应用于多个值。这些词名称后缀的 at 符号（" { $snippet "@" } "）表示它们是应用组合子（apply combinators）。"
{ $subsections bi@ 2bi@ tri@ 2tri@ }
"基于 " { $link bi@ } " 构建的用于测试两个值的一对条件词："
{ $subsections both? either? }
"所有应用组合子（apply combinators）都等价于使用对应的 " { $link "spread-combinators" } " 并为每个值提供相同的引用（quotation）。" ;

ARTICLE: "dip-keep-combinators" "保留组合子（preserving combinators）"
"有时需要暂时隐藏数据栈上的值。" { $snippet "dip" } " 组合子调用栈顶的引用（quotation），同时隐藏一定数量的值："
{ $subsections dip 2dip 3dip 4dip }
"" { $snippet "keep" } " 组合子调用一个引用（quotation），然后将一定数量的值恢复到栈顶："
{ $subsections keep 2keep 3keep } ;

ARTICLE: "curried-dataflow" "柯里化数据流组合子（curried dataflow combinators）"
"柯里化切割组合子（curried cleave combinators）："
{ $subsections bi-curry tri-curry }
"柯里化展开组合子（curried spread combinators）："
{ $subsections bi-curry* tri-curry* }
"柯里化应用组合子（curried apply combinators）："
{ $subsections bi-curry@ tri-curry@ }
{ $see-also "dataflow-combinators" } ;

ARTICLE: "compositional-examples" "组合式组合子（compositional combinators）用法示例"
"考虑打印同一条消息十次："
{ $code ": print-10 ( -- ) 10 [ \"Hello, world.\" print ] times ;" }
"如果我们想将消息抽象为一个参数，可以在迭代之间将其保留在栈上："
{ $code ": print-10 ( message -- ) 10 [ dup print ] times drop ;" }
"然而，将循环不变量保留在栈上并不总是方便。例如，一个从序列的每个元素中减去一个值的词："
{ $code ": subtract-n ( seq n -- seq' ) swap [ over - ] map nip ;" }
"需要三个洗牌词（shuffle words）来传递该值。相反，可以使用 " { $link curry } " 将循环不变量部分应用到引用（quotation）中，生成一个新的引用（quotation），然后传递给 " { $link map } "："
{ $example
  "USING: sequences prettyprint ;"
  ": subtract-n ( seq n -- seq' ) [ - ] curry map ;"
  "{ 10 20 30 } 5 subtract-n ."
  "{ 5 15 25 }"
}
"现在考虑与上述相对偶的词；它不是从每个栈元素中减去 " { $snippet "n" } "，而是从 " { $snippet "n" } " 中减去每个元素。"
$nl
"一种写法是使用一对 " { $link swap } "："
{ $code ": n-subtract ( n seq -- seq' ) swap [ swap - ] curry map ;" }
"由于这种模式经常出现，" { $link with } " 将其封装了起来："
{ $example
  ": n-subtract ( n seq -- seq' ) [ - ] with map ;"
  "30 { 10 20 30 } n-subtract ."
  "{ 20 10 0 }"
}
{ $see-also "fry.examples" } ;

ARTICLE: "compositional-combinators" "组合式组合子（compositional combinators）"
"某些组合子（combinator）对引用（quotation）进行转换以生成新的引用（quotation）。"
{ $subsections "compositional-examples" }
"基本操作："
{ $subsections curry compose }
"派生操作："
{ $subsections 2curry 3curry with prepose }
"这些操作在常数时间内运行，并且在许多情况下会被 " { $link "compiler" } " 完全优化掉。" { $link "fry" } " 是构建在这些操作之上的抽象，使用该抽象编写的代码通常比直接调用上述词更加清晰。"
$nl
"柯里化数据流组合子（curried dataflow combinators）可以通过各种方式组合切割（cleave）、展开（spread）和应用（apply）模式来构建更复杂的数据流。"
{ $subsections "curried-dataflow" }
"引用（quotation）也实现了序列协议（sequence protocol），可以使用序列词（sequence words）进行操作；参见 " { $link "quotations" } "。然而，此类运行时引用操作不会被优化编译器优化。" ;

ARTICLE: "booleans" "布尔值（booleans）"
"在 Factor 中，任何不是 " { $link f } " 的对象都具有真值，而 " { $link f } " 具有假值。" { $link t } " 对象是规范的真值。"
{ $subsections f t }
"上述类型的联合类（union class）："
{ $subsections boolean }
"布尔值上有一些逻辑运算："
{ $subsections
    >boolean
    not
    and
    or
    xor
}
"布尔值最常用于 " { $link "conditionals" } "。"
{ $heading "f 对象与 f 类" }
"" { $link f } " 对象是 " { $link f } " 类的唯一实例；两者是不同的对象。后者也是一个解析词（parsing word），在解析时将 " { $link f } " 对象添加到解析树中。要引用该类本身，必须使用 " { $link POSTPONE: POSTPONE: } " 或 " { $link POSTPONE: \ } " 来阻止解析词执行。"
$nl
"这是 " { $link f } " 对象："
{ $example "f ." "f" }
"这是 " { $link f } " 类："
{ $example "\\ f ." "POSTPONE: f" }
"它们不相等："
{ $example "f \\ f = ." "f" }
"这是一个包含 " { $link f } " 对象的数组："
{ $example "{ f } ." "{ f }" }
"这是一个包含 " { $link f } " 类的数组："
{ $example "{ POSTPONE: f } ." "{ POSTPONE: f }" }
"" { $link f } " 对象是 " { $link f } " 类的实例："
{ $example "USE: classes" "f class-of ." "POSTPONE: f" }
"" { $link f } " 类是 " { $link word } " 的实例："
{ $example "USE: classes" "\\ f class-of ." "word" }
"另一方面，" { $link t } " 只是一个词（word），没有它是其唯一实例的类。"
{ $example "t \\ t eq? ." "t" }
"许多搜索集合的词会混淆未找到元素的情况与找到等于 " { $link f } " 的元素的情况。如果这种区别很重要，通常可以使用替代词；例如，比较 " { $link at } " 与 " { $link at* } "。" ;

ARTICLE: "conditionals-boolean-equivalence" "使用布尔逻辑表达条件语句"
"某些简单的条件形式可以用布尔逻辑以更简单的方式表达。"
$nl
"以下三行是等价的："
{ $code "[ drop f ] unless" "swap and" "and*" }
"以下三行是等价的："
{ $code "or? [ ] [ ] ?if" "swap or" "or*" }
"以下两行是等价的，其中 " { $snippet "L" } " 是一个字面量（literal）："
{ $code "[ L ] unless*" "L or" } ;

ARTICLE: "conditionals" "条件组合子（conditional combinators）"
"基本条件语句："
{ $subsections if when unless }
"抽象常见栈洗牌（stack shuffle）模式的形式："
{ $subsections if* when* unless* }
"另一种抽象常见栈洗牌（stack shuffle）模式的形式："
{ $subsections ?if ?when ?unless }
"带有三个引用的 " { $snippet "if" } " 形式："
{ $subsections 1if 2if 3if }
"测试或守卫条件的词："
{ $subsections 1check 2check 3check 1guard 2guard 3guard }
"有时不需要分支，只需从两个值中挑选一个："
{ $subsections ? }
"两个抽象出嵌套 " { $link if } " 链的组合子（combinator）："
{ $subsections cond case }
{ $subsections "conditionals-boolean-equivalence" }
{ $see-also "booleans" "bitwise-arithmetic" both? either? } ;

ARTICLE: "dataflow-combinators" "数据流组合子（dataflow combinators）"
"数据流组合子（dataflow combinators）表达了常见的数据流模式，例如在执行操作时保留其输入、将多个操作应用于单个值、将一组操作应用于一组值，或将单个操作应用于多个值。"
{ $subsections
    "dip-keep-combinators"
    "cleave-combinators"
    "spread-combinators"
    "apply-combinators"
}
"通过组合 " { $link "curried-dataflow" } " 可以构建更复杂的数据流。" ;

ARTICLE: "combinators-quot" "引用构建工具（quotation construction utilities）"
"一些用于创建引用（quotation）的词，可用于实现方法组合（method combinations）和编译器变换（compiler transforms）："
{ $subsections cond>quot case>quot alist>quot } ;

ARTICLE: "call-unsafe" "不安全组合子（unsafe combinators）"
"不安全的调用（unsafe calls）在没有任何运行时检查的情况下静态声明效果（effect）："
{ $subsections call-effect-unsafe execute-effect-unsafe } ;

ARTICLE: "call" "基本组合子（fundamental combinators）"
"最基本的组合子（combinator）是那些接受引用（quotation）或词（word）并立即调用它的组合子。这些基本组合子（fundamental combinators）有两组。它们的区别在于编译器是在编译时确定表达式的栈效果（stack effect），还是在运行时声明并验证栈效果（stack effect）。"
$nl
{ $heading "编译时检查的组合子（compile-time checked combinators）" }
"使用这些组合子（combinator）时，编译器尝试在编译时确定表达式的栈效果（stack effect），如果无法确定效果（effect）则拒绝该程序。参见 " { $link "inference-combinators" } "。"
{ $subsections call execute }
{ $heading "运行时检查的组合子（run-time checked combinators）" }
"使用这些组合子（combinator）时，表达式的栈效果（stack effect）在运行时被检查。"
{ $subsections POSTPONE: call( POSTPONE: execute( }
"请注意，左括号实际上是 " { $snippet "call(" } " 和 " { $snippet "execute(" } " 词名的一部分；它们是解析词（parsing words），会读取栈效果（stack effect）直到对应的右括号。底层词稍微冗长一些，但可以接受非常量的栈效果（stack effect）："
{ $subsections call-effect execute-effect }
{ $heading "不检查的组合子（unchecked combinators）" }
{ $subsections "call-unsafe" }
{ $see-also "effects" "inference" } ;

ARTICLE: "combinators-connection" "组合子关联（combinator connections）"
"Factor 提供了多种便捷的组合子（combinator）实现，特别是针对栈参数较少的简单情况。"
"本文档将记录那些在应用上相似但效果（effect）可能不同的组合子（combinator）。"
{ $list
  { { $link map } " 将 " { $link call } " 泛化到对象 " { $link sequence } " 上。" }
  { { $link napply } " 将 " { $link bi@ } " 和 " { $link tri@ }
    " 泛化到栈上任意数量的对象。" }
  { { $link cleave } " 将 " { $link bi } " 和 " { $link tri }
    " 泛化到相等数量的引用（quotation）和栈上对象。" }
  { { $link spread } " 将 " { $link bi* } " 和 "  { $link tri* } " "
    "泛化到执行一组忽略栈顶 n 个值并保持它们不变的操作。" }
}
;

ARTICLE: "combinators" "组合子（combinators）"
"Factor 中的一个核心概念是 " { $emphasis "组合子（combinator）" } "，即接受代码作为输入的词（word）。"
{ $subsections
    "call"
    "dataflow-combinators"
    "conditionals"
    "looping-combinators"
    "compositional-combinators"
    "combinators.short-circuit"
    "combinators.smart"
    "combinators-quot"
    "generalizations"
    "combinators-connection"
}
"更多组合子（combinator）是为处理数据结构而定义的，例如 " { $link "sequences-combinators" } " 和 " { $link "assocs-combinators" } "。"
{ $see-also "quotations" } ;

ABOUT: "combinators"

HELP: call-effect
{ $values { "quot" quotation } { "effect" effect } }
{ $description "给定一个引用（quotation）和一个栈效果（stack effect），调用该引用（quotation），并在运行时断言其具有给定的栈效果（stack effect）。这是一个宏（macro），在给定字面效果（literal effect）参数时会展开，同时接受一个编译时不需要的任意引用（quotation）。" }
{ $examples
  "以下两行是等价的："
  { $code
    "call( a b -- c )"
    "( a b -- c ) call-effect"
  }
} ;

HELP: execute-effect
{ $values { "word" word } { "effect" effect } }
{ $description "给定一个词（word）和一个栈效果（stack effect），执行该词（word），并在运行时断言其具有给定的栈效果（stack effect）。这是一个宏（macro），在给定字面效果（literal effect）参数时会展开，同时接受一个编译时不需要的任意词（word）。" }
{ $examples
  "以下两行是等价的："
  { $code
    "execute( a b -- c )"
    "( a b -- c ) execute-effect"
  }
} ;

HELP: execute-effect-unsafe
{ $values { "word" word } { "effect" effect } }
{ $description "给定一个词（word）和一个栈效果（stack effect），执行该词（word），在运行时盲目声明其具有给定的栈效果（stack effect）。这是一个宏（macro），在给定字面效果（literal effect）参数时会展开，同时接受一个编译时不需要的任意词（word）。" }
{ $warning "如果正在执行的词（word）具有不正确的栈效果（stack effect），将导致未定义行为。用户代码应使用 " { $link POSTPONE: execute( } " 替代。" } ;

{ call-effect call-effect-unsafe execute-effect execute-effect-unsafe } related-words

HELP: cleave
{ $values { "x" object } { "seq" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( x -- ... )" } } }
{ $description "依次将每个引用（quotation）应用于该对象。" }
{ $examples
    "" { $link bi } " 组合子（combinator）接受一个值和两个引用（quotation）；" { $link tri } " 组合子（combinator）接受一个值和三个引用（quotation）。" { $link cleave } " 组合子（combinator）接受一个值和任意数量的引用（quotation），本质上等价于 " { $link keep } " 形式的链："
    { $code
        "! 等价"
        "{ [ p ] [ q ] [ r ] [ s ] } cleave"
        "[ p ] keep [ q ] keep [ r ] keep s"
    }
} ;

HELP: 2cleave
{ $values { "x" object } { "y" object }
          { "seq" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( x y -- ... )" } } }
{ $description "依次将每个引用（quotation）应用于这两个对象。" } ;

HELP: 3cleave
{ $values { "x" object } { "y" object } { "z" object }
          { "seq" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( x y z -- ... )" } } }
{ $description "依次将每个引用（quotation）应用于这三个对象。" } ;

{ bi tri cleave } related-words

HELP: spread
{ $values { "objs..." "对象" } { "seq" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( x -- ... )" } } }
{ $description "依次将每个引用（quotation）应用于这些对象。" }
{ $examples
    "" { $link bi* } " 组合子（combinator）接受两个值和两个引用（quotation）；" { $link tri* } " 组合子（combinator）接受三个值和三个引用（quotation）。" { $link spread } " 组合子（combinator）接受 " { $snippet "n" } " 个值和 " { $snippet "n" } " 个引用（quotation），其中 " { $snippet "n" } " 是输入序列的长度，本质上等价于一系列嵌套的 " { $link dip } "："
    { $code
        "! 等价"
        "{ [ p ] [ q ] [ r ] [ s ] } spread"
        "[ [ [ p ] dip q ] dip r ] dip s"
    }
} ;

{ bi* tri* spread } related-words

HELP: to-fixed-point
{ $values { "object" object } { "quot" { $quotation ( ... object(n) -- ... object(n+1) ) } } { "object(n)" object } }
{ $description "以 " { $snippet "object" } " 作为初始输入重复应用引用（quotation），直到引用（quotation）的输出等于输入。" }
{ $examples
    { $example
        "USING: combinators kernel math prettyprint sequences ;"
        "IN: scratchpad"
        ": flatten ( sequence -- sequence' )"
        "    \"flatten\" over index"
        "    [ [ 1 + swap nth ] [ nip dup 2 + ] [ drop ] 2tri replace-slice ] when* ;"
        ""
        "{ \"flatten\" { 1 { 2 3 } \"flatten\" { 4 5 } { 6 } } } [ flatten ] to-fixed-point ."
        "{ 1 { 2 3 } 4 5 { 6 } }"
    }
} ;

HELP: alist>quot
{ $values { "default" quotation } { "assoc" "一个引用（quotation）对序列" } { "quot" "一个新的引用（quotation）" } }
{ $description "构造一个引用（quotation），它依次调用 " { $snippet "assoc" } " 中每对的第一个引用（quotation），直到其中一个输出真值，然后调用对应对中的第二个引用（quotation）。引用（quotation）按相反顺序调用，如果没有任何引用（quotation）输出真值，则调用 " { $snippet "default" } "。" }
{ $notes "这个词（word）用于实现 " { $link cond } " 的编译时行为，也被泛型词系统（generic word system）使用。注意与 " { $link cond } " 不同，构造的引用（quotation）从末尾开始而不是从开头开始执行测试。" } ;

HELP: cond
{ $values { "assoc" "一个引用（quotation）对序列和一个可选的引用（quotation）" } }
{ $description
    "调用第一个其第一个引用（quotation）产生真值的对中的第二个引用（quotation）。单个引用（quotation）总是产生真值。"
    $nl
    "以下两种写法是等价的："
    { $code "{ { [ X ] [ Y ] } { [ Z ] [ T ] } } cond" }
    { $code "X [ Y ] [ Z [ T ] [ no-cond ] if ] if" }
}
{ $errors "如果所有测试引用（quotation）都没有产生真值，则抛出 " { $link no-cond } " 错误。" }
{ $examples
    { $example
        "USING: combinators io kernel math ;"
        "0 {"
        "    { [ dup 0 > ] [ drop \"positive\" ] }"
        "    { [ dup 0 < ] [ drop \"negative\" ] }"
        "    [ drop \"zero\" ]"
        "} cond print"
        "zero"
    }
} ;

HELP: no-cond
{ $description "抛出一个 " { $link no-cond } " 错误。" }
{ $error-description "当所有测试引用（quotation）都没有产生真值时，由 " { $link cond } " 抛出。某些 " { $link cond } " 的使用形式包含一个测试引用为 " { $snippet "[ t ]" } " 的默认情况；这种 " { $link cond } " 形式永远不会抛出此错误。" } ;

HELP: case
{ $values { "obj" object } { "assoc" "一个对象/引用（quotation）对序列，末尾有一个可选的引用（quotation）" } }
{ $description
    "将 " { $snippet "obj" } " 与每个 " { $link pair } " 的第一个元素进行比较，如果第一个元素是 " { $link callable } " 则先求值。如果匹配，则从栈中移除 " { $snippet "obj" } "，并 " { $link call } " 该对的第二个元素（必须是一个 " { $link quotation } "）。"
    $nl
    "如果 " { $snippet assoc } " 的最后一个元素是一个引用（quotation），则该引用是默认情况。如果没有其他情况匹配 " { $snippet obj } "，则调用默认情况并将其留在栈上。"
    $nl
    "如果所有情况都失败且没有默认情况可执行，则引发 " { $link no-case } " 错误。"
    $nl
    "以下两种写法是等价的："
    { $code "{ { X [ Y ] } { Z [ T ] } } case" }
    { $code "dup X = [ drop Y ] [ dup Z = [ drop T ] [ no-case ] if ] if" }
}
{ $errors { $link no-case } " 如果输入不匹配任何选项且没有尾随引用（quotation）。" }
{ $examples
    { $example
        "USING: combinators io kernel ;"
        "IN: scratchpad"
        "SYMBOLS: yes no maybe ;"
        "maybe {"
        "    { yes [ ] } ! 什么也不做"
        "    { no [ \"No way!\" throw ] }"
        "    { maybe [ \"Make up your mind!\" print ] }"
        "    [ drop \"Invalid input; try again.\" print ]"
        "} case"
        "Make up your mind!"
    }
} ;

HELP: no-case
{ $description "抛出一个 " { $link no-case } " 错误。" }
{ $error-description "当栈顶对象不匹配任何情况且未给出默认情况时，由 " { $link case } " 抛出。" } ;

HELP: deep-spread>quot
{ $values { "seq" sequence } { "quot" quotation } }
{ $description "从一个引用（quotation）序列创建一个新的引用（quotation），该引用依次将每个引用（quotation）应用于一个栈元素。" }
{ $see-also spread } ;

HELP: cond>quot
{ $values { "assoc" "一个引用（quotation）对序列" } { "quot" quotation } }
{ $description "创建一个引用（quotation），当调用时，其效果与对 " { $snippet "assoc" } " 应用 " { $link cond } " 相同。"
$nl
"然而，生成的引用（quotation）比 " { $link cond } " 的朴素实现更高效，因为它展开为一系列条件语句，不需要遍历 " { $snippet "assoc" } "。" }
{ $notes "这个词（word）在幕后用于高效编译 " { $link cond } " 形式；也可以直接调用，这对于元编程（meta-programming）很有用。" } ;

HELP: case>quot
{ $values { "default" quotation } { "assoc" "一个引用（quotation）对序列" } { "quot" quotation } }
{ $description "创建一个引用（quotation），当调用时，其效果与对 " { $snippet "assoc" } " 应用 " { $link case } " 相同。"
$nl
"这个词（word）使用三种策略："
{ $list
    "如果关联列表（assoc）只有少量键，则生成线性搜索。"
    { "如果关联列表（assoc）有大量构成连续整数范围的键，则使用 " { $snippet "dispatch" } " 词（word）配合边界检查直接派发。" }
    "否则，生成开放编码的哈希表（hashtable）派发。"
} } ;

HELP: distribute-buckets
{ $values { "alist" "一个关联列表（alist）" } { "initial" object } { "quot" { $quotation ( obj -- assoc ) } } { "buckets" "一个新数组" } }
{ $description "将 " { $snippet "assoc" } " 的条目（entry）分入桶（bucket）中，使用引用（quotation）为每个条目产生一组键。计算每个键的哈希码（hashcode），并将条目放入所有对应的桶中。每个桶最初从 " { $snippet "initial" } " 克隆；这应该是一个空向量（vector）或包含一对（pair）的单元素向量。" }
{ $notes "这个词（word）用于 " { $link hash-case-quot } " 和 " { $link standard-combination } " 的实现中。" } ;

HELP: dispatch
{ $values { "n" "一个 fixnum" } { "array" "一个引用（quotation）数组" } }
{ $description "调用数组中的第 " { $snippet "n" } " 个引用（quotation）。" }
{ $warning "此词是泛型词系统用于加速方法派发的实现细节。它不执行类型或边界检查，用户代码不应直接调用它。" } ;

