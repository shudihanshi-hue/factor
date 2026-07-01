! Copyright (C) 2026 Factor 中文化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 栈效果声明 (Stack Effect Declarations) - 中文翻译
! 原始文件：D:\factor\core\effects\effects-docs.factor
!          D:\factor\core\effects\parser\parser-docs.factor
!

USING: arrays classes effects effects.parser help.markup help.syntax kernel math
sequences strings words ;
IN: zh.core.effects

ARTICLE: "effects-zh" "栈效果声明 (Stack Effect Declarations)"
"单词定义词（如 " { $link POSTPONE: : } " 和 " { $link POSTPONE: GENERIC: } "）在其语法中包含一个" { $emphasis "栈效果声明" } "。栈效果声明采用以下形式："
{ $code "( input1 input2 ... -- output1 ... )" }
"栈效果中的栈元素按顺序排列，栈顶在右侧。以下是一个示例："
{ $synopsis + }
"引用类型的参数可以通过在参数名后添加 " { $snippet ":" } " 然后编写嵌套栈效果声明来声明。如果输入或输出的数量取决于引用参数的栈效果，可以声明行变量（row variables）："
{ $subsection "effects-variables" }
"一些行多态组合子的示例："
{ $synopsis while }
{ $synopsis if* }
{ $synopsis each }
"对于非 " { $link POSTPONE: inline } " 的单词，只有输入和输出的数量具有语义意义，效果变量会被忽略。但是，内联单词的嵌套引用声明会被强制执行。嵌套引用声明对非递归内联组合子是可选的，仅提供更好的错误消息。但是，" { $link POSTPONE: recursive } " 组合子的引用输入必须声明效果。参见 " { $link "inference-recursive-combinators" } "。"
$nl
"在拼接式（concatenative）代码中，输入和输出名称仅用于文档目的，已经建立了一些约定使它们更具描述性。对于使用 " { $link "locals" } " 编写的代码，栈值会绑定到由栈效果输入参数命名的局部变量。"
$nl
"输入和输出通常以其数据类型的双关语命名，或者在类型非常通用时以其值的用途描述命名。以下是一些值名称的示例："
{ $table
    { { { $snippet "?" } } "布尔值" }
    { { { $snippet "<=>" } } { "排序说明符；参见 " { $link "order-specifiers" } } }
    { { { $snippet "elt" } } "作为序列元素的对象" }
    { { { $snippet "m" } "、" { $snippet "n" } } "整数" }
    { { { $snippet "obj" } } "对象" }
    { { { $snippet "quot" } } "引用" }
    { { { $snippet "seq" } } "序列" }
    { { { $snippet "assoc" } } "关联映射" }
    { { { $snippet "str" } } "字符串" }
    { { { $snippet "x" } "、" { $snippet "y" } "、" { $snippet "z" } } "数值" }
    { { $snippet "loc" } "屏幕位置，由包含 x 和 y 坐标的二元素数组指定" }
    { { $snippet "dim" } "屏幕尺寸，由包含宽度和高度值的二元素数组指定" }
    { { $snippet "*" } "当此符号单独出现在输出列表中时，表示单词无条件抛出错误" }
}
"用于反射和元编程，你可以使用 " { $link "syntax-effects" } " 在代码中包含字面栈效果，或使用以下构造词在运行时构造栈效果对象："
{ $subsections
    <effect>
    <terminated-effect>
    <variable-effect>
}
{ $see-also "inference" } ;

HELP: <effect>
{ $values
    { "in" "字符串或字符串-类型对的序列" }
    { "out" "字符串或字符串-类型对的序列" }
    { "effect" effect }
}
{ $description "构造一个 " { $link effect } " 对象。" { $snippet "in" } " 和 " { $snippet "out" } " 的每个元素必须是字符串（等价于字面栈效果语法中的 " { $snippet "name" } "）或 " { $link pair } "（其第一个元素为字符串，第二个元素为 " { $link class } " 或效果，等价于字面语法中的 " { $snippet "name: class" } " 或 " { $snippet "name: ( nested -- effect )" } "）。如果 " { $snippet "out" } " 数组由单个字符串元素 " { $snippet "\"*\"" } " 组成，则构造终止栈效果。" }
{ $notes "此单词不能构造带有 " { $link "effects-variables" } " 的效果。请使用 " { $link <variable-effect> } " 来构造可变栈效果。" }
{ $examples
{ $example "USING: effects prettyprint ;
{ \"a\" \"b\" } { \"c\" } <effect> ." "( a b -- c )" }
{ $example "USING: arrays effects prettyprint ;
{ \"a\" { \"b\" array } } { \"c\" } <effect> ." "( a b: array -- c )" }
{ $example "USING: effects prettyprint ;
{ \"a\" { \"b\" ( x y -- z ) } } { \"c\" } <effect> ." "( a b: ( x y -- z ) -- c )" }
{ $example "USING: effects prettyprint ;
{ \"a\" { \"b\" ( x y -- z ) } } { \"*\" } <effect> ." "( a b: ( x y -- z ) -- * )" }
} ;

HELP: <terminated-effect>
{ $values
    { "in" "字符串或字符串-类型对的序列" }
    { "out" "字符串或字符串-类型对的序列" }
    { "terminated?" boolean }
    { "effect" effect }
}
{ $description "类似于 " { $link <effect> } " 构造 " { $link effect } " 对象。如果 " { $snippet "terminated?" } " 为真，则忽略 " { $snippet "out" } " 的值，构造终止栈效果。" }
{ $notes "此单词不能构造带有 " { $link "effects-variables" } " 的效果。请使用 " { $link <variable-effect> } " 来构造可变栈效果。" }
{ $examples
{ $example "USING: effects prettyprint ;
{ \"a\" { \"b\" ( x y -- z ) } } { \"c\" } f <terminated-effect> ." "( a b: ( x y -- z ) -- c )" }
{ $example "USING: effects prettyprint ;
{ \"a\" { \"b\" ( x y -- z ) } } { } t <terminated-effect> ." "( a b: ( x y -- z ) -- * )" }
} ;

HELP: <variable-effect>
{ $values
    { "in-var" { $maybe string } }
    { "in" "字符串或字符串-类型对的序列" }
    { "out-var" { $maybe string } }
    { "out" "字符串或字符串-类型对的序列" }
    { "effect" effect }
}
{ $description "类似于 " { $link <effect> } " 构造 " { $link effect } " 对象。如果 " { $snippet "in-var" } " 或 " { $snippet "out-var" } " 不为 " { $link f } "，则它们将用作效果对象输入和输出的 " { $link "effects-variables" } " 名称。" }
{ $examples
{ $example "USING: effects prettyprint ;
f { \"a\" \"b\" } f { \"c\" } <variable-effect> ." "( a b -- c )" }
{ $example "USING: effects prettyprint ;
\"x\" { \"a\" \"b\" } \"y\" { \"c\" } <variable-effect> ." "( ..x a b -- ..y c )" }
{ $example "USING: arrays effects prettyprint ;
\"y\" { \"a\" { \"b\" ( ..x -- ..y ) } } \"x\" { \"c\" } <variable-effect> ." "( ..y a b: ( ..x -- ..y ) -- ..x c )" }
{ $example "USING: effects prettyprint ;
\".\" { \"a\" \"b\" } f { \"*\" } <variable-effect> ." "( ... a b -- * )" }
} ;


{ <effect> <terminated-effect> <variable-effect> } related-words

ARTICLE: "effects-variables-zh" "栈效果行变量"
"许多 " { $link POSTPONE: inline } " 组合子的栈效果可以是可变的，取决于它们调用的引用的效果。例如，" { $link each } " 的引用参数每次被调用时从输入序列接收一个元素，但它也可以操作栈上元素下方的值，只要它在栈上留下相同数量的元素。（这就是 " { $link reduce } " 如何基于 " { $snippet "each" } " 实现的。）因此，" { $snippet "each" } " 表达式的栈效果取决于其输入引用的栈效果："
{ $example
 "USING: io sequences stack-checker ;
[ [ write ] each ] infer."
"( x -- )" }
{ $example
"USING: sequences stack-checker ;
[ [ append ] each ] infer."
"( x x -- x )" }
"此特性被称为行多态（row polymorphism）。行多态组合子通过在其栈效果中包含行变量来声明，行变量以 " { $snippet ".." } " 开头的名称表示："
{ $synopsis each }
"在输入和输出中使用相同的变量名（在上面的 " { $snippet "each" } " 示例中为 " { $snippet "..." } "）表示额外输入和输出的数量必须相同。使用不同的变量名表示它们可以独立。在有多个引用输入的组合子中，特定 " { $snippet ".." } " 名称所代表的输入或输出数量在所有引用中必须匹配。例如，" { $link if* } " 的分支可以接受与输出不同数量的输入，只要它们具有相同的栈高度。真分支接收测试值作为额外输入。声明如下："
{ $synopsis if* }
"栈效果变量只能出现在栈效果的第一个输入或第一个输出位置；以 " { $snippet ".." } " 开头的名称如果出现在效果的其他位置会导致语法错误。对于非 " { $link POSTPONE: inline } " 的单词，效果变量目前被栈检查器忽略。" ;

ABOUT: "effects-zh"

HELP: effect
{ $class-description "表示栈效果的对象。持有输入序列、输出序列和一个指示是否无条件抛出错误的标志。" } ;

HELP: effect-height
{ $values { "effect" effect } { "n" integer } }
{ $description "输出栈效果向数据栈添加的对象数量。如果栈效果仅从栈中移除对象，则此值为负数。" } ;

HELP: effect<=
{ $values { "effect1" effect } { "effect2" effect } { "?" boolean } }
{ $description "测试 " { $snippet "effect1" } " 是否可替换 " { $snippet "effect2" } "。这意味着两个栈效果以相同数量改变栈高度，第一个接受等于或小于第二个的输入数量，且两者要么都终止执行（抛出错误），要么都不终止。" } ;

HELP: effect=
{ $values { "effect1" effect } { "effect2" effect } { "?" boolean } }
{ $description "测试 " { $snippet "effect1" } " 和 " { $snippet "effect2" } " 是否表示相同的栈变换，不考虑参数名称。" }
{ $examples
  { $example "USING: effects prettyprint ;" "( a -- b ) ( x -- y ) effect= ." "t" }
} ;

HELP: effect>string
{ $values { "obj" object } { "str" string } }
{ $description "将栈效果对象转换为字符串助记符。" }
{ $examples
    { $example "USING: effects io ;" "{ \"x\" } { \"y\" \"z\" } <effect> effect>string print" "( x -- y z )" }
} ;

HELP: stack-effect
{ $values { "word" word } { "effect/f" { $maybe effect } } }
{ $description "输出单词的栈效果；即由 " { $link POSTPONE: ( } " 声明的栈效果，或推导出的栈效果（参见 " { $link "inference" } "）。" } ;

! 来自 effects/parser/parser-docs.factor
HELP: parse-effect
{ $values { "end" string } { "effect" "" { $link effect } " 的实例" } }
{ $description "从当前输入行解析栈效果。" }
{ $examples "此单词被 " { $link POSTPONE: ( } " 用于解析栈效果声明。" }
$parsing-note ;
