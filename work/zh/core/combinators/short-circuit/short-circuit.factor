! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 短路组合子 — 中文翻译
! 原始文件: D:\factor\core\combinators\short-circuit\short-circuit-docs.factor

USING: combinators.short-circuit help.markup help.syntax kernel
math quotations ;
IN: zh.core.combinators.short-circuit

HELP: 0&&
{ $values { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( -- ? )" } } { "?" "最后一个引用（quotation）的结果，或 " { $link f } } }
{ $description "如果序列中的每个引用（quotation）都输出一个真值，则输出最后一个引用（quotation）的结果，否则输出 " { $link f } "。" } ;

HELP: 0||
{ $values { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( -- ? )" } } { "?" "第一个真值结果，或 " { $link f } } }
{ $description "如果序列中的每个引用（quotation）都输出 " { $link f } "，则输出 " { $link f } "，否则输出第一个不产生 " { $link f } " 的引用（quotation）的结果。" } ;

HELP: 1&&
{ $values { "obj" object } { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( obj -- ? )" } } { "?" "最后一个引用（quotation）的结果，或 " { $link f } } }
{ $description "如果序列中的每个引用（quotation）都输出一个真值，则输出最后一个引用（quotation）的结果，否则输出 " { $link f } "。" } ;

HELP: 1||
{ $values { "obj" object } { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( obj -- ? )" } } { "?" "第一个真值结果，或 " { $link f } } }
{ $description "如果序列中的任何引用（quotation）返回真值，则返回真值。每个引用（quotation）从数据栈中获取相同的元素，并且必须返回一个布尔值（boolean）。" } ;

HELP: 2&&
{ $values { "obj1" object } { "obj2" object } { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( obj1 obj2 -- ? )" } } { "?" "最后一个引用（quotation）的结果，或 " { $link f } } }
{ $description "如果序列中的每个引用（quotation）都输出一个真值，则输出最后一个引用（quotation）的结果，否则输出 " { $link f } "。" } ;

HELP: 2||
{ $values { "obj1" object } { "obj2" object } { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( obj1 obj2 -- ? )" } } { "?" "第一个真值结果，或 " { $link f } } }
{ $description "如果序列中的任何引用（quotation）返回真值，则返回真值。每个引用（quotation）从数据栈中获取相同的两个元素，并且必须返回一个布尔值（boolean）。" } ;

HELP: 3&&
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( obj1 obj2 obj3 -- ? )" } } { "?" "最后一个引用（quotation）的结果，或 " { $link f } } }
{ $description "如果序列中的每个引用（quotation）都输出一个真值，则输出最后一个引用（quotation）的结果，否则输出 " { $link f } "。" } ;

HELP: 3||
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quots" "一个引用（quotation）序列，其栈效果（stack effect）为 " { $snippet "( obj1 obj2 obj3 -- ? )" } } { "?" "第一个真值结果，或 " { $link f } } }
{ $description "如果序列中的任何引用（quotation）返回真值，则返回真值。每个引用（quotation）从数据栈中获取相同的三个元素，并且必须返回一个布尔值（boolean）。" } ;

HELP: n&&
{ $values
    { "quots" "一个引用（quotation）序列" } { "n" integer }
    { "quot" quotation } }
{ $description "一个宏（macro），将代码重写为从栈中传递 " { $snippet "n" } " 个参数给每个引用（quotation），以与 " { $link 0&& } " 相同的方式评估结果。" } ;

HELP: n||
{ $values
    { "quots" "一个引用（quotation）序列" } { "n" integer }
    { "quot" quotation } }
{ $description "一个宏（macro），将代码重写为从栈中传递 " { $snippet "n" } " 个参数给每个 OR 引用（quotation）。" } ;

ARTICLE: "combinators.short-circuit" "短路组合子（short-circuit combinators）"
"" { $vocab-link "combinators.short-circuit" } " 词汇表一旦满足某个条件就提前停止计算。" $nl
"AND 组合子（AND combinators）："
{ $subsections
    0&&
    1&&
    2&&
    3&&
}
"OR 组合子（OR combinators）："
{ $subsections
    0||
    1||
    2||
    3||
}
"泛化组合子（generalized combinators）："
{ $subsections
    n&&
    n||
}
;

ABOUT: "combinators.short-circuit"