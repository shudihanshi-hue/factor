USING: help.markup help.syntax kernel quotations strings
tools.test vocabs.refresh ;
IN: zh.tools.test

ARTICLE: "tools.test-zh" "单元测试（unit test）"
"单元测试（unit test）是一段代码，它从已知的输入值开始，然后将一个词的输出与预期的输出进行比较，其中预期的输出由该词的约定定义。"
$nl
"例如，如果你正在开发一个用于计算符号导数的词，你的单元测试将把该词应用于某些输入函数，并将结果与正确的值进行比较。虽然这些测试的通过并不能保证算法是正确的，但它至少可以确保曾经正常工作的东西继续正常工作，一旦由于程序其他部分的更改而导致某些东西损坏，失败的测试会让你知道。"
$nl
"一个词汇表的单元测试被放置在与此词汇表源文件相同目录下的测试文件中（参见 " { $link "vocabs.loader" } "）。支持两种方式："
{ $list
    { "测试可以放在名为 " { $snippet { $emphasis "vocab" } "-tests.factor" } " 的文件中。" }
    { "测试可以放在 " { $snippet "tests" } " 子目录下的文件中。" }
}
"后者用于具有更广泛测试套件的词汇表。"
$nl
"如果测试框架需要定义词汇，它们应该放置在一个名为 " { $snippet { $emphasis "vocab" } ".tests" } " 的词汇表中，其中 " { $emphasis "vocab" } " 是被测试的词汇表。"
{ $heading "编写单元测试" }
"有几个词用于编写不同类型的单元测试。最通用的一个断言某个引用输出一组特定的值："
{ $subsections POSTPONE: unit-test }
"断言一个引用抛出错误："
{ $subsections
    POSTPONE: must-fail
    POSTPONE: must-fail-with
}
"断言一个引用或词具有特定的静态栈效果（参见 " { $link "inference" } "）："
{ $subsections
    POSTPONE: must-infer
    POSTPONE: must-infer-as
}
"以上所有词都像普通词一样使用，但实际上是解析词。这确保了分析时的状态（即行号）可以与相关的测试关联起来，并在测试失败时报告。"
$nl
"一些词帮助测试编写者使用临时文件："
{ $subsections
  with-test-directory
  with-test-file
}
{ $heading "运行单元测试" }
"以下词运行测试框架文件；任何测试失败都会被收集并在最后打印："
{ $subsections
    test
    test-all
}
"以下词打印失败："
{ $subsections :test-failures }
"测试失败通过 " { $link "tools.errors" } " 机制报告，并显示在 " { $link "ui.tools.error-list" } " 中。"
$nl
"单元测试失败是一个类的实例，并存储在一个全局变量中："
{ $subsections
    test-failure
    test-failures
} ;

HELP: must-fail
{ $syntax "[ quot ] must-fail" }
{ $values { "quot" "一个使用空栈运行的引用" } }
{ $description "使用空栈运行一个引用，预期它会抛出错误。如果该引用抛出错误，此词正常返回。如果该引用没有抛出错误，此词 " { $emphasis "会" } " 引发错误。" }
{ $notes "此词用于测试边界条件和快速失败行为。" } ;

HELP: must-fail-with
{ $syntax "[ quot ] [ pred ] must-fail-with" }
{ $values { "quot" "一个使用空栈运行的引用" } { "pred" { $quotation ( error -- ? ) } } }
{ $description "使用空栈运行一个引用，预期它抛出一个必须满足 " { $snippet "pred" } " 的错误。如果该引用没有抛出错误，或者错误不匹配谓词，则单元测试失败。" }
{ $notes "此词用于测试错误处理代码，确保代码抛出的错误包含相关的调试信息。" } ;

HELP: must-infer
{ $syntax "[ quot ] must-infer" }
{ $values { "quot" quotation } }
{ $description "确保该引用具有静态栈效果，而不运行它。" }
{ $notes "此词用于测试代码是否能够通过优化编译器编译以获得最佳性能。参见 " { $link "compiler" } "。" } ;

HELP: must-infer-as
{ $syntax "{ effect } [ quot ] must-infer-as" }
{ $values { "effect" "一个具有 " { $snippet "{ inputs outputs }" } " 形式的对" } { "quot" quotation } }
{ $description "确保该引用具有指定的栈效果，而不运行它。" }
{ $notes "此词用于测试代码是否能够通过优化编译器编译以获得最佳性能。参见 " { $link "compiler" } "。" } ;

HELP: test
{ $values { "prefix" "一个词汇表名称" } }
{ $description "运行名为 " { $snippet "prefix" } " 的词汇表及其所有子词汇表的单元测试。" } ;

HELP: test-all
{ $description "运行所有已加载词汇表的单元测试。" } ;

HELP: refresh-and-test
{ $values { "prefix" string } }
{ $description "类似于 " { $link refresh } "，但之后会运行所有重新加载的词汇表的单元测试。" } ;

HELP: refresh-and-test-all
{ $description "类似于 " { $link refresh-all } "，但之后会运行所有重新加载的词汇表的单元测试。" } ;

{ refresh-and-test refresh-and-test-all } related-words

HELP: :test-failures
{ $description "打印所有待处理的单元测试失败。" } ;

HELP: unit-test
{ $syntax "{ output } [ input ] unit-test" }
{ $values { "output" "一个预期的栈元素序列" } { "input" "一个使用空栈运行的引用" } }
{ $description "使用空栈运行一个引用，将结果栈与 " { $snippet "output" } " 进行比较。元素使用 " { $link = } " 进行比较。如果预期的栈与结果栈不匹配，则抛出错误。" } ;

HELP: with-test-file
{ $values { "quot" quotation } }
{ $description "创建一个空的临时文件并将引用应用于它。文件在此词返回后被删除。" } ;

ABOUT: "tools.test-zh"
