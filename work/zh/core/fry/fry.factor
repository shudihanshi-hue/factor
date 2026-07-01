! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 煎化引用（Fried Quotations / Fry）— 中文翻译
! 原始文件: D:\factor\core\fry\fry-docs.factor

USING: fry help.markup help.syntax quotations kernel ;
IN: zh.core.fry

HELP: _
{ $description "煎化说明符（fry specifier）。将一个字面值插入到煎化引用中。" }
{ $examples "参见 " { $link "fry.examples" } "。" } ;

HELP: @
{ $description "煎化说明符。将一个引用拼接（splice）到煎化引用中。" }
{ $examples "参见 " { $link "fry.examples" } "。" } ;

HELP: fry
{ $values { "object" object } { "quot" quotation } }
{ $description "输出一个引用，当被调用时，通过从栈上取值并替换来煎化（fry）" { $snippet "object" } "。" }
{ $notes "此单词用于实现 " { $link POSTPONE: '[ } "；以下两行是等价的："
    { $code "[ X ] fry call" "'[ X ]" }
}
{ $examples "参见 " { $link "fry.examples" } "。" } ;

HELP: '[
{ $syntax "'[ code... ]" }
{ $description "字面煎化引用。展开为从栈上取值并替换煎化说明符 " { $link POSTPONE: _ } " 和 " { $link POSTPONE: @ } " 所在位置的代码。" }
{ $examples "参见 " { $link "fry.examples" } "。" } ;

HELP: >r/r>-in-fry-error
{ $error-description "当 " { $link POSTPONE: '[ } " 中的煎化引用包含保留栈操作原语的调用时抛出。" } ;

ARTICLE: "fry.examples-zh" "煎化引用示例"
"理解煎化引用最简单的方法是看一些示例。"
$nl
"如果引用中不包含任何煎化说明符，那么 " { $link POSTPONE: '[ } " 的行为与 " { $link POSTPONE: [ } " 完全相同："
{ $code "{ 10 20 30 } '[ . ] each" }
"左侧出现的 " { $link POSTPONE: _ } " 直接映射到 " { $link curry } "。也就是说，以下三行是等价的："
{ $code
    "{ 10 20 30 } 5 '[ _ + ] map"
    "{ 10 20 30 } 5 [ + ] curry map"
    "{ 10 20 30 } [ 5 + ] map"
}
"引用中间出现的 " { $link POSTPONE: _ } " 映射到更复杂的引用组合模式。以下三行是等价的："
{ $code
    "{ 10 20 30 } 5 '[ 3 _ / ] map"
    "{ 10 20 30 } 5 [ 3 ] swap [ / ] curry compose map"
    "{ 10 20 30 } [ 3 5 / ] map"
}
"" { $link POSTPONE: @ } " 的出现只是 " { $snippet "_ call" } " 的语法糖。以下四行是等价的："
{ $code
    "{ 10 20 30 } [ sq ] '[ @ . ] each"
    "{ 10 20 30 } [ sq ] [ call . ] curry each"
    "{ 10 20 30 } [ sq ] [ . ] compose each"
    "{ 10 20 30 } [ sq . ] each"
}
"" { $link POSTPONE: _ } " 和 " { $link POSTPONE: @ } " 说明符可以自由混合，结果比直接使用 " { $link curry } " 和 " { $link compose } " 的版本更加简洁易读："
{ $code
    "{ 8 13 14 27 } [ even? ] 5 '[ @ dup _ ? ] map"
    "{ 8 13 14 27 } [ even? ] 5 [ dup ] swap [ ? ] curry compose compose map"
    "{ 8 13 14 27 } [ even? dup 5 ? ] map"
}
"以下代码是一个空操作："
{ $code "'[ @ ]" }
"以下是一些用煎化引用重写的内建组合子："
{ $table
    { { $link literalize } { $snippet ": literalize '[ _ ] ;" } }
    { { $link curry } { $snippet ": curry '[ _ @ ] ;" } }
    { { $link compose } { $snippet ": compose '[ @ @ ] ;" } }
} ;

ARTICLE: "fry.philosophy-zh" "煎化引用的设计理念"
"煎化引用泛化了诸如 " { $link curry } " 和 " { $link compose } " 等引用构建单词。它们可以清理大量使用咖喱化和组合的代码，特别是当引用嵌套时："
{ $code
    "'[ [ _ key? ] all? ] filter"
    "[ [ key? ] curry all? ] curry filter"
}
"煎化引用与 " { $vocab-link "locals" } " 词汇中定义的词法闭包之间存在映射关系。具体来说，一个煎化引用等价于一个 " { $snippet "[| | ]" } " 形式，其中每个局部绑定只使用一次，且绑定按定义顺序使用。以下两行是等价的："
{ $code
    "'[ 3 _ + 4 _ / ]"
    "[| a b | 3 a + 4 b / ]"
} ;

ARTICLE: "fry-zh" "煎化引用 (Fried Quotations)"
"" { $vocab-link "fry" } " 词汇实现了" { $emphasis "煎化引用（fried quotation）" } "。从概念上讲，煎化引用是带有 " { $snippet "洞" } "（更正式地说，" { $emphasis "煎化说明符" } "）的引用，当煎化引用被压入栈时，洞会被填充。"
$nl
"煎化引用由一个特殊的解析词开始："
{ $subsections POSTPONE: '[ }
"有两种类型的煎化说明符；第一种可以持有一个值，第二种 \"splices\" 一个引用，就像它被插入时没有包围的方括号一样："
{ $subsections
    POSTPONE: _
    POSTPONE: @
}
"洞的填充顺序为：栈顶填充最右边的洞，栈上第二个元素填充右边第二个洞，以此类推。"
{ $subsections
    "fry.examples-zh"
    "fry.philosophy-zh"
}
"Fry 实现为一个解析词，它读取一个引用并扫描 " { $link POSTPONE: _ } " 和 " { $link POSTPONE: @ } " 的出现位置；这些单词实际上不会被执行，执行它们会引发错误（这可能发生在它们被意外用在 fry 外部时）。"
$nl
"煎化引用也可以不使用解析词来构造；这在元编程时很有用："
{ $subsections fry }
"煎化引用是建立在 " { $link "compositional-combinators" } " 之上的抽象；鼓励使用煎化引用而非组合子，因为煎化形式通常比组合子形式更短更清晰。" ;

ABOUT: "fry-zh"
