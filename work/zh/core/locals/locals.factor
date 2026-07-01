! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 词法局部变量（Lexical Variables）— 中文翻译
! 原始文件: D:\factor\core\locals\locals-docs.factor

USING: help.syntax help.markup kernel
combinators arrays generalizations sequences ;
IN: zh.core.locals

HELP: [|
{ $syntax "[| bindings... | body... ]" }
{ $description "带有命名变量绑定的字面引用。当该引用被 " { $link call } " 时，它将从数据栈上取值并从左到右依次放入绑定中。函数体随后可以引用这些绑定。该引用还可以绑定到外围作用域中的命名变量以创建闭包（closure）。" }
{ $examples "参见 " { $link "locals-examples-zh" } "。" } ;

HELP: [let
{ $syntax "[let code :> var code :> var code... ]" }
{ $description "为词法变量绑定建立新的作用域。在 " { $snippet "[let" } " 体内使用 " { $link POSTPONE: :> } " 绑定的变量将在 " { $snippet "[let" } " 形式的函数体范围内具有词法作用域。" }
{ $examples "参见 " { $link "locals-examples-zh" } "。" } ;

HELP: :>
{ $syntax ":> var\n:> var!\n:> ( var-1 var-2 ... )" }
{ $description "绑定一个或多个新的词法变量。在 " { $snippet ":> var" } " 形式中，数据栈顶的值被绑定到一个名为 " { $snippet "var" } " 的新词法变量，其作用域为包围它的引用、" { $link POSTPONE: [let } " 形式或 " { $link POSTPONE: :: } " 定义。"
$nl
"在 " { $snippet ":> ( var-1 ... )" } " 形式中，多个变量按从右到左的顺序绑定到数据栈顶的值，最后一个变量绑定到数据栈顶。以下两段代码效果相同："
{ $code ":> c :> b :> a" }
{ $code ":> ( a b c )" }
$nl
"如果任何 " { $snippet "var" } " 名称后跟叹号（" { $snippet "!" } "），则该新变量是可变的。参见 " { $link "locals-mutable-zh" } " 获取更多信息。" }
{ $notes
    "此语法只能在由 " { $link POSTPONE: :: } " 定义、" { $link POSTPONE: [let } " 形式或 " { $link POSTPONE: [| } " 引用建立的词法作用域内使用。普通引用只有在外部作用域内时才有自己的词法作用域。像 " { $link POSTPONE: : } " 这样的定义形式本身不会建立词法作用域（除非另有说明），源文件顶层或监听器中也没有可用的词法作用域。可以使用 " { $link POSTPONE: [let } " 在没有其他方式提供的地方创建词法作用域。" }
{ $examples "参见 " { $link "locals-examples-zh" } "。" } ;

{ POSTPONE: [let POSTPONE: :> } related-words

HELP: ::
{ $syntax ":: word ( vars... -- outputs... ) body... ;" }
{ $description "定义一个带有命名输入的单词。该单词将其输入值从左到右绑定到词法变量，然后在这些绑定的作用域内执行函数体。"
$nl
"如果任何 " { $snippet "var" } " 名称后跟叹号（" { $snippet "!" } "），则对应的新变量将被设为可变的。参见 " { $link "locals-mutable-zh" } " 获取更多信息。" }
{ $notes "" { $snippet "outputs" } " 的名称不影响单词的行为。但是，编译器会像验证 " { $link POSTPONE: : } " 定义一样验证栈效果是否准确表示了输出的数量。" }
{ $examples "参见 " { $link "locals-examples-zh" } "。" } ;

{ POSTPONE: : POSTPONE: :: } related-words

HELP: MACRO::
{ $syntax "MACRO:: word ( vars... -- outputs... ) body... ;" }
{ $description "定义一个带有命名输入的宏。该宏将其输入变量从左到右绑定到词法变量，然后在这些绑定的作用域内执行函数体。"
$nl
"如果任何 " { $snippet "var" } " 名称后跟叹号（" { $snippet "!" } "），则对应的新变量将被设为可变的。参见 " { $link "locals-mutable-zh" } " 获取更多信息。" }
{ $notes "宏的展开不能引用在外部作用域中绑定的词法变量。将涉及词法变量的参数传递给宏也有一些限制。详见 " { $link "locals-limitations-zh" } "。" }
{ $examples "参见 " { $link "locals-examples-zh" } "。" } ;

{ POSTPONE: MACRO: POSTPONE: MACRO:: } related-words

HELP: MEMO::
{ $syntax "MEMO:: word ( vars... -- outputs... ) body... ;" }
{ $description "定义一个带有命名输入的记忆化（memoized）单词。该单词将其输入值从左到右绑定到词法变量，然后在这些绑定的作用域内执行函数体。"
$nl
"如果任何 " { $snippet "var" } " 名称后跟叹号（" { $snippet "!" } "），则对应的新变量将被设为可变的。参见 " { $link "locals-mutable-zh" } " 获取更多信息。" }
{ $examples "参见 " { $link "locals-examples-zh" } "。" } ;

{ POSTPONE: MEMO: POSTPONE: MEMO:: } related-words

HELP: M::
{ $syntax "M:: class generic ( vars... -- outputs... ) body... ;" }
{ $description "为 " { $snippet "generic" } " 在 " { $snippet "class" } " 上定义一个带有命名输入的新方法。该方法将其输入值从左到右绑定到词法变量，然后在这些绑定的作用域内执行函数体。"
$nl
"如果任何 " { $snippet "var" } " 名称后跟叹号（" { $snippet "!" } "），则对应的新变量将被设为可变的。参见 " { $link "locals-mutable-zh" } " 获取更多信息。" }
{ $notes "" { $snippet "outputs" } " 的名称不影响方法的行为。但是，编译器会像验证 " { $link POSTPONE: M: } " 定义一样验证栈效果是否准确表示了输出的数量。" }
{ $examples "参见 " { $link "locals-examples-zh" } "。" } ;

{ POSTPONE: M: POSTPONE: M:: } related-words

ARTICLE: "locals-examples-zh" "词法变量示例"
{ $heading "带词法变量的定义" }
"以下示例演示了单词定义中的词法变量绑定。" { $snippet "quadratic-roots" } " 单词使用 " { $link POSTPONE: :: } " 定义，因此它从数据栈顶部的三个元素获取输入并将它们分别绑定到变量 " { $snippet "a" } "、" { $snippet "b" } " 和 " { $snippet "c" } "。在函数体中，" { $snippet "disc" } " 变量使用 " { $link POSTPONE: :> } " 绑定，然后在下一行代码中使用。"
{ $example "USING: locals math math.functions kernel ;
IN: scratchpad
:: quadratic-roots ( a b c -- x y )
    b sq 4 a c * * - sqrt :> disc
    b neg disc [ + ] [ - ] 2bi [ 2 a * / ] bi@ ;
1.0 1.0 -6.0 quadratic-roots"
"\n--- Data stack:\n2.0\n-3.0"
}
"如果你想从监听器交互式地执行二次公式计算，可以使用 " { $link POSTPONE: [let } " 来提供变量的作用域："
{ $example "USING: locals math math.functions kernel ;
IN: scratchpad
[let 1.0 :> a 1.0 :> b -6.0 :> c
    b sq 4 a c * * - sqrt :> disc
    b neg disc [ + ] [ - ] 2bi [ 2 a * / ] bi@
]"
"\n--- Data stack:\n2.0\n-3.0"
}

$nl

{ $heading "带词法变量的引用与闭包" }
"接下来的两个示例演示了使用 " { $link POSTPONE: [| } " 定义的引用中的词法变量绑定。在这个示例中，值 " { $snippet "5" } " 和 " { $snippet "3" } " 被放在数据栈上。当引用被调用时，它将这些值作为输入分别绑定到 " { $snippet "m" } " 和 " { $snippet "n" } "，然后执行引用："
{ $example
    "USING: kernel locals math ;"
    "IN: scratchpad"
    "5 3 [| m n | m n - ] call( x x -- x )"
    "\n--- Data stack:\n2"
}
$nl

"在这个示例中，" { $snippet "adder" } " 单词创建了一个闭包（closure）捕获其参数 " { $snippet "n" } " 的引用。调用时，" { $snippet "5 adder" } " 的结果引用从数据栈取出 " { $snippet "3" } " 并绑定到 " { $snippet "m" } "，然后将其与 " { $snippet "adder" } " 外部作用域中绑定的值 " { $snippet "5" } " 相加："
{ $example
    "USING: kernel locals math ;"
    "IN: scratchpad"
    ":: adder ( n -- quot ) [| m | m n + ] ;"
    "3 5 adder call( x -- x )"
    "\n--- Data stack:\n8"
}
$nl

{ $heading "可变绑定" }
"下一个示例演示了闭包和可变变量绑定。" { $snippet "<counter>" } " 单词输出一个包含一对引用的元组，这两个引用分别对内部可变变量 " { $snippet "value" } " 进行递增和递减操作，然后返回新值。这些引用闭包捕获了计数器，因此每次调用该单词都会产生具有新内部计数器的新引用。"
{ $example
"USING: accessors locals kernel math ;
IN: scratchpad

TUPLE: counter adder subtractor ;

:: <counter> ( -- counter )
    0 :> value!
    counter new
    [ value 1 + dup value! ] >>adder
    [ value 1 - dup value! ] >>subtractor ;
<counter>
[ adder>>      call( -- x ) ]
[ adder>>      call( -- x ) ]
[ subtractor>> call( -- x ) ] tri"
"\n--- Data stack:\n1\n2\n1"
}
    $nl
    "同一个变量名可以在同一作用域中多次绑定。这与重新赋值可变变量不同。变量名的最新绑定会遮蔽（mask）之前的同名绑定。但是，引用先前值的旧绑定仍然可以在闭包中存在。以下刻意构造的示例演示了这一点："
    { $example
"USING: kernel locals ;
IN: scratchpad
:: rebinding-example ( -- quot1 quot2 )
    5 :> a [ a ]
    6 :> a [ a ] ;
:: mutable-example ( -- quot1 quot2 )
    5 :> a! [ a ]
    6 a! [ a ] ;
rebinding-example [ call( -- x ) ] bi@
mutable-example [ call( -- x ) ] bi@"
"\n--- Data stack:\n5\n6\n6\n6"
}
    "在 " { $snippet "rebinding-example" } " 中，" { $snippet "a" } " 绑定到 " { $snippet "5" } " 被第一个引用闭包捕获，" { $snippet "a" } " 绑定到 " { $snippet "6" } " 被第二个引用闭包捕获，因此调用两个引用分别得到 " { $snippet "5" } " 和 " { $snippet "6" } "。相比之下，在 " { $snippet "mutable-example" } " 中，两个引用闭包捕获的是 " { $snippet "a" } " 的同一个绑定。即使 " { $snippet "a" } " 在第一个引用创建后被赋值为 " { $snippet "6" } "，调用任一引用都会输出 " { $snippet "a" } " 的新值。"
{ $heading "字面量中的词法变量" }
"某些类型的字面量可以包含对词法变量的引用，如 " { $link "locals-literals-zh" } " 中所述。例如，" { $link 3array } " 单词可以实现如下："
{ $example
"USING: locals ;
IN: scratchpad

:: my-3array ( x y z -- array ) { x y z } ;
1 \"two\" 3.0 my-3array"
"\n--- Data stack:\n{ 1 \"two\" 3.0 }"
} ;

ARTICLE: "locals-literals-zh" "字面量中的词法变量"
"某些数据类型字面量允许包含词法变量。任何此类字面量都会被重写为构造该类型实例的代码，其中变量的值被拼接进去。从概念上讲，这与对包含自由变量的引用所做的转换类似。"
$nl
"接受此特殊处理的数据类型如下："
{ $list
    { $link "arrays" }
    { $link "hashtables" }
    { $link "vectors" }
    { $link "tuples" }
    { $link "wrappers" }
}
{ $heading "对象同一性" }
"此特性改变了字面量对象同一性（object identity）的语义。包含字面量的普通单词每次被调用时都会将相同的字面量压入栈："
{ $example
    "USING: kernel ;"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ": ordinary-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "ordinary-word-test ordinary-word-test eq?"
    "\n--- Data stack:\nt"
}
"在词法作用域内部，不包含词法变量的字面量行为仍然相同："
{ $example
    "USING: kernel locals ;"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ":: locals-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "locals-word-test locals-word-test eq?"
    "\n--- Data stack:\nt"
}
"然而，包含词法变量的字面量实际上会构造一个新对象："
{ $example
    "USING: locals kernel splitting ;"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ":: constructor-test ( -- tuple )"
    "    \"Jane Smith\" \" \" split1 :> last :> first"
    "    T{ person { first-name first } { last-name last } } ;"
    "constructor-test constructor-test eq?"
    "\n--- Data stack:\nf"
}
"上述规则的一个例外是：包含自由词法变量（即不在闭包中引用的不可变词法变量）的数组实例确实保持同一性。这使得像 " { $link cond } " 这样的宏即使在其参数引用变量时也能在编译时展开。" ;


ARTICLE: "locals-mutable-zh" "可变词法变量"
"当使用 " { $link POSTPONE: :> } "、" { $link POSTPONE: :: } " 或 " { $link POSTPONE: [| } " 绑定词法变量时，可以通过在变量名后添加叹号（" { $snippet "!" } "）使变量变为可变的。"
$nl
"可变词法变量在其作用域中创建两个新单词。假设我们使用 " { $snippet "data :> var!" } " 定义一个可变变量，则："
$nl
{ $snippet "var" } " 将把变量的值 " { $snippet "data" } " 压入栈，"
$nl
{ $snippet "var!" } " 将从栈上消费一个值，并将变量设置为该值。"
$nl
"注意，使用 " { $link POSTPONE: :> } " 总是创建一个新的局部变量，而不会改变已有变量。创建同名的新局部变量可能导致混淆，产生不良效果。"
$nl
"任何变量的值都可以被修改其参数的单词（例如 " { $link push } "）所修改。这些单词不区分可变和不可变绑定。"
$nl
"可变绑定的实现方式类似于 ML 语言的做法。每个可变绑定实际上是一个可变单元（mutable cell）的不可变绑定。读取绑定时会自动从单元中拆箱（unbox）值，写入绑定时则会存储到单元中。"
$nl
"从外部词法作用域写入可变变量是完全支持的，并且具有完整的闭包语义。参见 " { $link "locals-examples-zh" } " 中可变词法变量的示例。" ;

ARTICLE: "locals-fry-zh" "词法变量与 fry"
"词法变量与 " { $link "fry" } " 集成，因此混合变量与煎化引用（fried quotation）会产生直观的结果。"
$nl
"以下两段代码是等价的："
{ $code "'[ sq _ + ]" }
{ $code "[ [ sq ] dip + ] curry" }
"" { $link dip } " 和 " { $link curry } " 的语义使得第一个示例的行为就像栈顶的值被 \"inserted\" 到引用第二个元素的 \"hole\" 中一样。"
$nl
"从概念上讲，" { $link curry } " 的定义使得以下两段代码是等价的："
{ $code "3 [ - ] curry" }
{ $code "[ 3 - ]" }
"当引用使用 " { $link POSTPONE: [| } " 接受命名参数时，" { $link curry } " 从右到左填充变量绑定。以下两段代码是等价的："
{ $code "3 [| a b | a b - ] curry" }
{ $code "[| a | a 3 - ]" }
"因此，当 " { $snippet "fry" } " 应用于此类引用时，其行为会改变，以确保 fry 在概念上与普通引用的行为一致，将煎化的值放在变量绑定的 \"underneath\" 。因此，以下代码片段不再等价："
{ $code "'[ [| a | _ a - ] ]" }
{ $code "'[ [| a | a - ] curry ] call" }
"相反，上面的第一行会展开为类似以下的形式："
{ $code "[ [ swap [| a | a - ] ] curry call ]" }
$nl
"具体行为如下。当煎化一个 " { $link POSTPONE: [| } " 引用时，会前置一个栈重排操作（" { $link mnswap } "），使得 " { $snippet "m" } " 个咖喱值（初始位于栈顶）与引用的 " { $snippet "n" } " 个命名输入绑定进行转置。" ;

ARTICLE: "locals-limitations-zh" "词法变量的限制"
"当前实现有两个主要限制，两者都与宏有关。"
{ $heading "带自由变量的宏展开" }
"宏的展开不能引用在外部作用域中绑定的词法变量。例如，以下宏是无效的："
{ $code "MACRO:: twice ( quot -- ) [ quot call quot call ] ;" }
"但以下是正确的："
{ $code "MACRO:: twice ( quot -- ) quot quot '[ @ @ ] ;" }
{ $heading "静态栈效果推导与宏" }
"宏只有在所有输入都是字面量时才会在编译时展开。同样，包含该宏的单词只有在宏的输入是字面量时才会具有静态栈效果并成功编译。当词法变量用于宏的字面量参数时，有一个额外的限制：字面量必须在词法上紧接在宏调用之前。"
$nl
"例如，以下三段代码表面上等价，但只有第一段能编译："
{ $code
    ":: good-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } cond ;"
}
"接下来的两段代码不会编译，因为 " { $link cond } " 的参数没有紧接在调用之前："
{ $code
    ": my-cond ( alist -- ) cond ; inline"
    ""
    ":: bad-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } my-cond ;"
}
{ $code
    ":: bad-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } swap swap cond ;"
}
"原因是词法变量引用在解析时被重写为栈代码，而宏展开在稍后的编译时执行。为解决此问题，使用 " { $vocab-link "macros.expander" } " 词汇在词法变量转换之前重写简单的宏用法。然而，" { $vocab-link "macros.expander" } " 无法处理宏的字面量输入不在源代码中紧接在宏调用之前的更复杂情况。" ;

ARTICLE: "locals-zh" "词法局部变量 (Lexical Variables)"
"" { $vocab-link "locals" } " 词汇提供了具有词法作用域的局部变量。完全支持向下和向上的闭包语义。还提供了可变变量绑定，支持对当前作用域或外部作用域中的绑定进行赋值。"
{ $subsections
    "locals-examples"
}
"输入绑定到词法变量的单词定义："
{ $subsections
    POSTPONE: ::
    POSTPONE: M::
    POSTPONE: MEMO::
    POSTPONE: MACRO::
}
"词法作用域和绑定形式："
{ $subsections
    POSTPONE: [let
    POSTPONE: :>
}
"输入绑定到词法变量的引用字面量："
{ $subsections POSTPONE: [| }
"附加主题："
{ $subsections
    "locals-literals-zh"
    "locals-mutable-zh"
    "locals-fry-zh"
    "locals-limitations-zh"
}
"词法变量与 " { $link "namespaces" } " 互补。" ;

ABOUT: "locals-zh"
