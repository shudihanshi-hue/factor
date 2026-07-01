! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 动态变量（Dynamic Variables / Namespaces）— 中文翻译
! 原始文件: D:\factor\core\namespaces\namespaces-docs.factor

USING: assocs help.markup help.syntax kernel math
namespaces namespaces.private quotations words words.symbol ;
IN: zh.core.namespaces

ARTICLE: "namespaces-combinators-zh" "命名空间组合子"
{ $subsections
    with-scope
    with-variable
    with-variables
} ;

ARTICLE: "namespaces-change-zh" "修改变量值"
{ $subsections
    on
    off
    inc
    dec
    change
    change-global
    toggle
} ;

ARTICLE: "namespaces-global-zh" "全局变量"
{ $subsections
    namespace
    global
    get-global
    set-global
    initialize
    with-global
} ;

ARTICLE: "namespaces.private-zh" "命名空间实现细节"
"名字栈（namestack）持有命名空间。"
{ $subsections
    get-namestack
    set-namestack
    namespace
}
"一对单词在名字栈上压入和弹出命名空间。"
{ $subsections
    >n
    ndrop
} ;

ARTICLE: "namespaces-zh" "动态变量 (Dynamic Variables)"
"" { $vocab-link "namespaces" } " 词汇实现了动态作用域变量。"
$nl
"动态变量是绑定关联映射中的一个条目，其中关联映射是隐式的而非通过栈传递的。这些关联映射被称为" { $emphasis "命名空间（namespaces）" } "。作用域的嵌套通过命名空间上的搜索顺序实现，由" { $emphasis "名字栈（namestack）" } "定义。由于命名空间只是关联映射，任何对象都可以用作变量。按照惯例，变量以 " { $link "words.symbol" } " 作为键。"
$nl
"" { $link get } " 和 " { $link set } " 单词分别读取和写入变量值。" { $link get } " 单词搜索嵌套命名空间链，而 " { $link set } " 总是仅在当前命名空间中设置变量值。命名空间是动态作用域的；当引用从嵌套作用域中被调用时，该引用调用的任何单词也在该作用域中执行。"
{ $subsections
    get
    set
}
"各种工具单词提供常见的变量访问模式："
{ $subsections
    "namespaces-change"
    "namespaces-combinators"
}
"你的代码可能不需要关心的实现细节："
{ $subsections "namespaces.private" }
"动态变量与 " { $link "locals" } " 互补。" ;

ABOUT: "namespaces-zh"

HELP: get
{ $values { "variable" "变量，按惯例为符号（symbol）" } { "value" { $maybe "值" } } }
{ $description "在名字栈中搜索包含该变量的命名空间，并输出关联的值。如果未找到此类命名空间，输出 " { $link f } "。" } ;

HELP: set
{ $values { "value" "新值" } { "variable" "变量，按惯例为符号（symbol）" } }
{ $description "将值赋给名字栈顶命名空间中的变量。" }
{ $side-effects "variable" } ;

HELP: off
{ $values { "variable" "变量，按惯例为符号（symbol）" } }
{ $description "将变量的值赋为 " { $link f } "。" }
{ $side-effects "variable" } ;

HELP: on
{ $values { "variable" "变量，按惯例为符号（symbol）" } }
{ $description "将变量的值赋为 " { $link t } "。" }
{ $side-effects "variable" } ;

HELP: change
{ $values { "variable" "变量，按惯例为符号（symbol）" } { "quot" { $quotation ( old -- new ) } } }
{ $description "将引用应用于变量的旧值，并将结果赋给该变量。" }
{ $side-effects "variable" } ;

HELP: change-global
{ $values { "variable" "变量，按惯例为符号（symbol）" } { "quot" { $quotation ( old -- new ) } } }
{ $description "将引用应用于全局变量的旧值，并将结果赋给该全局变量。" }
{ $side-effects "variable" } ;

HELP: toggle
{ $values
    { "variable" "变量，按惯例为符号（symbol）" }
}
{ $description "将变量的布尔值取反。" } ;

HELP: with-global
{ $values
    { "quot" quotation }
}
{ $description "在全局命名空间中运行引用。" } ;

HELP: +@
{ $values { "n" number } { "variable" "变量，按惯例为符号（symbol）" } }
{ $description "将 " { $snippet "n" } " 加到变量的值上。变量值为 " { $link f } " 时被视为零。" }
{ $side-effects "variable" }
{ $examples
    { $example "USING: namespaces prettyprint ;" "IN: scratchpad" "SYMBOL: foo\n1 foo +@\n10 foo +@\nfoo get ." "11" }
} ;

HELP: inc
{ $values { "variable" "变量，按惯例为符号（symbol）" } }
{ $description "将变量的值加 1。变量值为 " { $link f } " 时被视为零。" }
{ $side-effects "variable" } ;

HELP: dec
{ $values { "variable" "变量，按惯例为符号（symbol）" } }
{ $description "将变量的值减 1。变量值为 " { $link f } " 时被视为零。" }
{ $side-effects "variable" } ;

HELP: counter
{ $values { "variable" "变量，按惯例为符号（symbol）" } { "n" integer } }
{ $description "将变量的值加 1，并返回其新值。" }
{ $notes "此单词可用于生成（某种程度上）唯一的标识符。例如，" { $link gensym } " 单词就使用了它。" }
{ $side-effects "variable" } ;

HELP: with-scope
{ $values { "quot" quotation } }
{ $description "在新的命名空间中调用引用。引用设置的任何变量在返回时都会被丢弃。" }
{ $examples
    { $example "USING: math namespaces prettyprint ;" "IN: scratchpad" "SYMBOL: x" "0 x set" "[ x [ 5 + ] change x get . ] with-scope x get ." "5\n0" }
} ;

HELP: with-variable
{ $values { "value" object } { "key" "变量，按惯例为符号（symbol）" } { "quot" quotation } }
{ $description "在 " { $snippet "key" } " 被设置为 " { $snippet "value" } " 的新命名空间中调用引用。" }
{ $examples "以下两种写法是等价的："
    { $code "[ 3 x set foo ] with-scope" }
    { $code "3 x [ foo ] with-variable" }
} ;

HELP: with-variables
{ $values { "ns" assoc } { "quot" quotation } }
{ $description "在 " { $snippet "ns" } " 的动态作用域中调用引用。当引用查找变量时，首先检查 " { $snippet "ns" } "，引用中设置的变量也会存储在 " { $snippet "ns" } " 中。" } ;

HELP: namespace
{ $values { "namespace" assoc } }
{ $description "输出当前命名空间。对 " { $link set } " 的调用会修改此命名空间。" } ;

HELP: global
{ $values { "g" assoc } }
{ $description "输出全局命名空间。全局命名空间在查找变量值时总是最后被检查。" } ;

HELP: get-global
{ $values { "variable" "变量，按惯例为符号（symbol）" } { "value" "值" } }
{ $description "输出全局命名空间中变量的值。" } ;

HELP: set-global
{ $values { "value" "新值" } { "variable" "变量，按惯例为符号（symbol）" } }
{ $description "在全局命名空间中将值赋给变量。" }
{ $side-effects "variable" } ;

HELP: (get-namestack)
{ $values { "namestack" "关联映射的向量" } }
{ $description "输出当前名字栈。" } ;

HELP: get-namestack
{ $values { "namestack" "关联映射的向量" } }
{ $description "输出当前名字栈的副本。" } ;

HELP: set-namestack
{ $values { "namestack" "关联映射的向量" } }
{ $description "用给定向量的副本替换名字栈。" } ;

HELP: >n
{ $values { "namespace" assoc } }
{ $description "将命名空间压入名字栈。" } ;

HELP: ndrop
{ $description "从名字栈弹出命名空间。" } ;

HELP: init-namestack
{ $description "将名字栈重置为初始状态，仅持有全局命名空间的一个副本。" }
$low-level-note ;

HELP: initialize
{ $values { "variable" symbol } { "quot" quotation } }
{ $description "如果 " { $snippet "variable" } " 在全局命名空间中没有值，则调用 " { $snippet "quot" } " 并将结果赋给全局命名空间中的 " { $snippet "variable" } "。" } ;
