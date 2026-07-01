! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 栈效果检查（Stack Effect Checking / Inference）— 中文翻译
! 原始文件: D:\factor\basis\stack-checker\stack-checker-docs.factor

USING: classes continuations effects help.markup help.syntax io
kernel quotations sequences stack-checker stack-checker.backend
stack-checker.errors stack-checker.inlining stack-checker.known-words
stack-checker.state stack-checker.transforms
stack-checker.visitor.dummy vocabs vocabs.loader words ;
IN: zh.core.stack-checker

ARTICLE: "inference-simple-zh" "直线式栈效果"
"最简单的情况是代码没有任何分支或递归，只是压入字面量并调用单词。"
$nl
"压入字面量的栈效果为 " { $snippet "( -- x )" } "。大多数单词的栈效果始终可以从声明中静态获知。" { $link POSTPONE: inline } " 单词和 " { $link "macros" } " 的栈效果可能取决于调用前压入栈的字面量，这种情况在 " { $link "inference-combinators" } " 中讨论。"
$nl
"代码片段中每个元素的栈效果被组合。结果就是该片段的栈效果。"
$nl
"示例："
{ $example "[ 1 2 3 ] infer." "( -- x x x )" }
"另一个示例："
{ $example "[ 2 + ] infer." "( x -- x )" } ;

ARTICLE: "inference-combinators-zh" "组合子栈效果"
"如果单词调用组合子，栈检查器必须满足以下两个条件之一才能成功："
{ $list
  { "组合子必须使用字面引用或由字面引用、" { $link curry } " 和 " { $link compose } " 构建的引用来调用。（注意，使用 " { $vocab-link "fry" } " 或 " { $vocab-link "locals" } " 的引用，从栈检查器的角度来看，使用了 " { $link curry } " 和 " { $link compose } "。）" }
  { "如果单词被声明为 " { $link POSTPONE: inline } "，则组合子还可以在单词的输入参数上调用，或使用由单词的输入参数、字面引用、" { $link curry } " 和 " { $link compose } " 构建的引用调用。当内联时，单词本身被视为组合子，其调用者反过来也必须满足这些条件。" }
}
"如果两个条件都不满足，栈检查器会抛出 " { $link unknown-macro-input } " 或 " { $link bad-macro-input } " 错误。要使代码能够编译，必须改用运行时检查组合子，如 " { $link POSTPONE: call( } "。参见 " { $link "inference-escape" } " 获取详情。内联组合子可以通过 " { $link curry } " 将未知引用咖喱化到使用 " { $link POSTPONE: call( } " 的字面引用上来调用。"
{ $heading "输入栈效果" }
"内联组合子如果在其栈效果中声明了输入引用的效果，则会验证其输入引用的栈效果。详见 " { $link "effects-variables" } "。"
{ $heading "示例" }
{ $subheading "调用组合子" }
"以下 " { $link map } " 的用法通过了栈检查器，因为引用是 " { $link curry } " 的结果："
{ $example "USING: math sequences ;" "[ [ + ] curry map ] infer." "( x x -- x )" }
"使用 " { $vocab-link "fry" } " 和 " { $vocab-link "locals" } " 的等价代码同样通过栈检查器："
{ $example "USING: fry math sequences ;" "[ '[ _ + ] map ] infer." "( x x -- x )" }
{ $example "USING: locals math sequences ;" "[| a | [ a + ] map ] infer." "( x x -- x )" }
{ $subheading "定义内联组合子" }
"以下单词调用引用两次；该单词被声明为 " { $link POSTPONE: inline } "，因为它在输入参数的 " { $link compose } " 结果上调用 " { $link call } "："
{ $code ": twice ( value quot -- result ) dup compose call ; inline" }
"以下代码现在通过了栈检查器；如果 " { $snippet "twice" } " 未声明为 " { $link POSTPONE: inline } "，则会失败："
{ $unchecked-example "USE: math.functions" "[ [ sqrt ] twice ] infer." "( x -- x )" }
{ $subheading "为未知引用定义组合子" }
"在下一个示例中，必须使用 " { $link POSTPONE: call( } "，因为引用是调用运行时访问器的结果，编译器完全无法对此引用做出任何静态假设："
{ $code
  "TUPLE: action name quot ;"
  ": perform ( value action -- result ) quot>> call( value -- result ) ;"
}
{ $subheading "将未知引用传递给内联组合子" }
"假设我们想写："
{ $code ": perform ( values action -- results ) quot>> map ;" }
"然而这无法通过栈检查器，因为无法保证引用具有 " { $link map } " 所需的正确栈效果。可以用带声明的引用包装："
{ $code ": perform ( values action -- results )" "    quot>> [ call( value -- result ) ] curry map ;" }
{ $heading "解释" }
"此限制的存在是因为在没有进一步信息的情况下，无法确定 " { $link call } " 的栈效果；它取决于给定的引用。如果栈检查器遇到没有进一步信息的 " { $link call } "，会抛出 " { $link unknown-macro-input } " 或 " { $link bad-macro-input } " 错误。"
$nl
"另一方面，将 " { $link call } " 应用于字面引用或字面引用的 " { $link curry } " 的栈效果很容易计算；其行为就像引用被替换到那个位置一样。"
{ $heading "限制" }
"栈检查器无法保证字面引用在通过数据栈传递给内联递归组合子（如 " { $link each } " 或 " { $link map } "）时仍然是字面的。例如，以下代码无法推导："
{ $example
  "[ [ reverse ] swap [ reverse ] map swap call ] infer." "Cannot apply 'call' to a run-time computed value\nmacro call"
}
"要使其工作，请使用 " { $link dip } " 来传递引用："
{ $example
  "[ [ reverse ] [ [ reverse ] map ] dip call ] infer." "( x -- x )"
} ;

ARTICLE: "inference-branches-zh" "分支栈效果"
"条件语句（如 " { $link if } "）以及建立在其上的组合子具有与 " { $link POSTPONE: inline } " 组合子相同的限制（参见 " { $link "inference-combinators" } "），额外要求所有分支将栈保持在相同高度。如果不是这样，栈检查器会抛出 " { $link unbalanced-branches-error } " 错误。"
$nl
"如果所有分支将栈保持在相同高度，则条件语句的栈效果就是各分支栈效果的最大值。例如，"
{ $example "[ [ + ] [ drop ] if ] infer." "( x x x -- x )" }
"对 " { $link if } " 的调用从栈上取一个值，一个广义布尔值。第一个分支 " { $snippet "[ + ]" } " 的栈效果为 " { $snippet "( x x -- x )" } "，第二个为 " { $snippet "( x -- )" } "。由于两个分支都将栈高度减少一，我们说两个分支的栈效果为 " { $snippet "( x x -- x )" } "，加上 " { $link if } " 弹出的布尔值，总栈效果为 " { $snippet "( x x x -- x )" } "。" ;

ARTICLE: "inference-recursive-combinators-zh" "递归组合子栈效果"
"大多数组合子不直接递归调用自身；而是基于现有组合子实现，例如 " { $link while } "、" { $link map } " 和 " { $link "compositional-combinators" } "。在这些情况下，适用 " { $link "inference-combinators" } " 中概述的规则。"
$nl
"递归组合子需要额外注意。除了声明为 " { $link POSTPONE: inline } " 外，还必须声明为 " { $link POSTPONE: recursive } "。有以下三个限制仅适用于具有此声明的组合子："
{ $heading "输入引用声明" }
"引用类型的输入参数必须在栈效果中标注。例如，以下代码无法推导："
{ $unchecked-example ": bad ( quot -- ) [ call ] keep bad ; inline recursive" "[ [ ] bad ] infer." "Cannot apply 'call' to a run-time computed value\nmacro call" }
"以下是正确的："
{ $example ": good ( quot: ( -- ) -- ) [ call ] keep good ; inline recursive" "[ [ ] good ] infer." "( -- )" }
"嵌套引用本身的效果仅用于文档目的；嵌套效果的存在本身足以将该值标记为引用参数。"
{ $heading "数据流限制" }
"栈检查器在两种情况下不追踪数据流。"
$nl
"内联递归单词不能通过数据栈在递归调用中传递引用。例如，以下代码无法推导："
{ $unchecked-example ": bad ( ? quot: ( ? -- ) -- ) 2dup [ not ] dip bad call ; inline recursive" "[ [ drop ] bad ] infer." "Cannot apply 'call' to a run-time computed value\nmacro call" }
"但稍作修改即可："
{ $example ": good ( ? quot: ( ? -- ) -- ) [ good ] 2keep [ not ] dip call ; inline recursive" "[ [ drop ] good ] infer." "( x -- )" }
"内联递归单词在其基本情况中必须具有固定的栈效果。以下代码无法推导："
{ $unchecked-example
    ": foo ( quot ? -- ) [ f foo ] [ call ] if ; inline"
    "[ [ 5 ] t foo ] infer."
    "The inline recursive word 'foo' must be declared recursive\nword foo"
} ;

ARTICLE: "tools.inference-zh" "栈效果工具"
"" { $link "inference" } " 可以交互式使用，在不运行引用的情况下打印其栈效果。它也可以从 " { $link "combinators.smart" } " 使用。"
{ $subsections "tools.inference-zh" }
"还有一些用于操作 " { $link effect } " 实例的单词。获取单词的声明栈效果："
{ $subsections stack-effect }
"将栈效果转换为字符串形式："
{ $subsections effect>string }
"比较效果："
{ $subsections
    effect-height
    effect<=
    effect=
}
"栈效果的类："
{ $subsections
    effect
    effect?
} ;

ARTICLE: "inference-escape-zh" "栈效果检查逃逸机制"
"在静态检查机制中，有时需要突破边界运行一些无法静态检查的代码；可能是此代码在运行时构造的。有两种方法可以绕过静态栈检查器。"
$nl
"如果单词或引用的栈效果已知，但单词或引用本身未知，可以使用 " { $link POSTPONE: execute( } " 或 " { $link POSTPONE: call( } "。详见 " { $link "call" } "。"
$nl
"如果栈效果未知，被调用的代码不能直接操作数据栈。相反，它必须将数据栈反射为数组："
{ $subsections with-datastack }
"周围的代码具有静态栈效果，因为 " { $link with-datastack } " 具有一个。但是，作为输入传入的数组可以通过调用此组合子进行任意变换。" ;

ARTICLE: "inference-zh" "栈效果检查 (Stack Effect Checking)"
"" { $link "compiler" } " 在单词运行之前检查其 " { $link "effects" } "。这确保单词精确地接受程序员在源代码中声明的输入和输出数量。"
$nl
"未通过栈检查器的单词会被拒绝且无法运行，因此这实质上定义了一个非常简单且宽松的类型系统，但它仍然能捕获一些无效程序并启用编译器优化。"
$nl
"如果单词的栈效果无法推导，会报告编译错误。参见 " { $link "compiler-errors" } "。"
$nl
"以下文章描述了栈检查器如何处理不同的控制结构。"
{ $subsections
    "inference-simple"
    "inference-combinators"
    "inference-recursive-combinators"
    "inference-branches"
}
"栈检查能捕获几类错误。"
{ $subsections "inference-errors" }
"有时必须运行动态栈效果的代码。"
{ $subsections "inference-escape" }
{ $see-also "effects" "tools.inference" "tools.errors" } ;

ABOUT: "inference-zh"

HELP: infer
{ $values { "quot" quotation } { "effect" "" { $link effect } " 的实例" } }
{ $description "尝试推导引用的栈效果。对于交互式测试，应改用 " { $link infer. } " 单词，因为它以格式良好的方式呈现输出。" }
{ $errors "如果栈效果推导失败，抛出 " { $link inference-error } "。" } ;

HELP: infer.
{ $values { "quot" quotation } }
{ $description "尝试推导引用的栈效果，并将数据打印到 " { $link output-stream } "。" }
{ $errors "如果栈效果推导失败，抛出 " { $link inference-error } "。" } ;

{ infer infer. } related-words

HELP: inference-error
{ $values { "class" class } }
{ $description "创建 " { $snippet "class" } " 的实例，将其包装在 " { $link inference-error } " 中并抛出结果。" }
{ $error-description
    "当引用的栈效果无法推导时，由 " { $link infer } " 抛出。"
    $nl
    "" { $snippet "error" } " 槽包含几种可能的 " { $link "inference-errors" } " 之一。"
} ;
