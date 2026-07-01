! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 续延与异常处理（Continuations & Errors）— 中文翻译
! 原始文件: D:\factor\core\continuations\continuations-docs.factor

USING: continuations continuations.private help.markup help.syntax kernel
kernel.private lexer namespaces quotations sequences vectors ;
IN: zh.core.continuations

ARTICLE: "errors-restartable-zh" "可恢复错误"
"可恢复错误的支持建立在基本错误处理机制之上。以下单词发出可恢复错误："
{ $subsections
    throw-restarts
    rethrow-restarts
}
"使用上述单词的工具词："
{ $subsections
    throw-continue
}
"最近抛出错误的恢复选项列表存储在全局变量中："
{ $subsections restarts }
"要调用恢复选项，请使用 " { $link "debugger" } "。" ;

ARTICLE: "errors-post-mortem-zh" "事后错误检查"
"最近抛出的错误及其时的续延存储在一对全局变量中："
{ $subsections
    error
    error-continuation
}
"用于检查这些值的开发者工具见 " { $link "debugger" } "。" ;

ARTICLE: "errors-anti-examples-zh" "常见错误处理陷阱"
"正确使用异常处理可以使代码更健壮，减少错误处理逻辑的重复。但是，有一些陷阱需要注意。"
{ $heading "反模式 #1：忽略错误" }
"" { $link ignore-errors } " 单词几乎不应该被使用。忽略错误并不会使代码更健壮，事实上，当代码在之前未预见的情况下运行时出现间歇性错误，会使得调试变得困难得多。永远不要忽略意外错误；始终向用户报告。"
{ $heading "反模式 #2：过早捕获错误" }
"前一个反模式的一种较温和形式是过度热衷于使用 " { $link recover } " 的代码。捕获错误、记录消息然后继续运行几乎总是一个错误。唯一的例外是网络服务器和其他必须持续运行的长运行进程，即使单个任务失败也不应停止。在这些情况下，将 " { $link recover } " 放在调用栈中尽可能高的位置。"
$nl
"在大多数其他情况下，应该使用 " { $link cleanup } " 来处理错误并自动重新抛出。"
{ $heading "反模式 #3：丢弃并重新抛出" }
"不要使用 " { $link recover } " 通过丢弃错误并抛出新错误来处理错误。丢失原始错误数据和执行上下文意味着你向用户表明某件事失败了，但没有留下任何关于实际上出了什么问题的线索。要么将错误包装在包含额外信息的新错误中，要么重新抛出原始错误。更微妙的一种形式是使用 " { $link throw } " 而不是 " { $link rethrow } "。" { $link throw } " 单词只应在抛出新错误时使用，绝不应在重新抛出已捕获的错误时使用。"
{ $heading "反模式 #4：记录日志并重新抛出" }
"如果你打算重新抛出错误，不要记录日志消息。如果这样做，用户会看到同一错误的两条日志消息，这会混乱日志而不增加任何有用信息。" ;

ARTICLE: "errors-zh" "异常处理 (Exception Handling)"
"处理异常情况（如错误的用户输入、实现缺陷和输入/输出错误）的支持由一组基于续延构建的单词提供。"
$nl
"两个单词在当前动态范围的最近错误处理器中引发错误："
{ $subsections
    throw
    rethrow
}
"建立错误处理器的单词："
{ $subsections
    cleanup
    recover
    ignore-errors
}
"定义错误的语法糖："
{ $subsections POSTPONE: ERROR: }
"未处理的错误会在监听器中报告，可以使用各种工具进行调试。参见 " { $link "debugger" } "。"
{ $subsections
    "errors-restartable"
    "debugger"
    "errors-post-mortem"
    "errors-anti-examples"
}
"当 Factor 遇到关键错误时，会调用以下单词："
{ $subsections die } ;

ARTICLE: "continuations.private-zh" "续延实现细节"
"续延（continuation）只是一个持有五个栈内容的元组："
{ $subsections
    continuation
    >continuation<
}
"五个栈可以读取和写入："
{ $subsections
    get-datastack
    set-datastack
    get-retainstack
    set-retainstack
    get-callstack
    set-callstack
    get-namestack
    set-namestack
    get-catchstack
    set-catchstack
} ;

ARTICLE: "continuations-zh" "续延 (Continuations)"
"在程序执行的任何时刻，" { $emphasis "当前续延（current continuation）" } " 代表该执行上下文计算的未来。"
$nl
"用于操作续延的单词位于 " { $vocab-link "continuations" } " 词汇中；实现细节在 " { $vocab-link "continuations.private" } " 中。"
$nl
"具体化（reify）续延并处理恢复的一般形式是："
{ $subsections
    ifcc
}
"当恢复不需要特殊处理时，可以根据计算的未来是否期望数据，使用以下两个更简单的单词来具体化续延："
{ $subsections
    callcc0
    callcc1
}
"以下两个对应的单词恢复这些具体化的续延："
{ $subsections
    continue
    continue-with
}
"恢复的续延最多只能传递一个值，因此传递的数据必须打包在单个对象中。实际上这不是很大的限制。此外，不带数据操作续延的单词实际上只是为了方便的快捷方式，它们确实传递了一个空值并在恢复时自动丢弃。"
$nl
"具体化的续延可以在任何时间恢复：在捕获引用返回之前或之后。而且具体化的续延可以恢复任意次数：零次、一次或任意多次。"
$nl
"在最简单的情况下，具体化的续延不会逃逸出初始捕获引用的执行。这足以实现错误的非局部异常行为处理，其中正常路径完全不恢复续延，但任何错误立即通过传入该错误来恢复续延，有效地跳转到捕获引用中从它将被处理的地方继续执行。另一个例子是提前返回（包括从捕获引用中的嵌套调用返回）的短路特性。"
$nl
"因此作为更高级的抽象，续延也可以用作控制流："
{ $subsections
    attempt-all
    with-return
}
"续延是许多更高级抽象的构建基础，如 " { $link "errors" } " 和 " { $link "threads" } "。"
{ $subsections "continuations.private" }
"当续延被恢复许多次时达到其表达力的顶峰，而要实现这一点，恢复必须在初始捕获引用返回之后进行。"
$nl
"由于在初始捕获引用返回后恢复具体化的续延只有在程序仍在运行时才能工作，程序的其余部分必须相应地设计。例如，程序的其余部分可以是某种长运行进程，恢复续延的工作方式类似于重启该进程。或者程序的其余部分知道它必须等待恢复，因此其行为类似于从初始捕获引用接收命令。或者程序的其余部分本身恢复续延，表现得像非确定性回溯系统，可以通过返回到较早的执行点、以不同的分支决策重新启动计算来探索搜索空间（这种模式被称为 " { $emphasis "amb" } "）。"
;

ABOUT: "continuations-zh"

HELP: (get-catchstack)
{ $values { "catchstack" "续延的向量" } }
{ $description "输出当前的捕获栈。" } ;

HELP: get-catchstack
{ $values { "catchstack" "续延的向量" } }
{ $description "输出当前捕获栈的副本。" } ;

HELP: current-continuation
{ $values { "continuation" continuation } }
{ $description "将代表计算未来的当前执行上下文具体化为续延对象。" } ;

HELP: set-catchstack
{ $values { "catchstack" "续延的向量" } }
{ $description "用给定向量的副本替换捕获栈。" } ;

HELP: continuation
{ $class-description "具体化续延对象的类。" } ;

HELP: >continuation<
{ $values { "continuation" continuation } { "data" vector } { "call" vector } { "retain" vector } { "name" vector } { "catch" vector } }
{ $description "将续延分解为其组成部分。" } ;

HELP: ifcc
{ $values { "capture" { $quotation ( continuation -- initial ) } } { "restore" { $quotation ( obj -- obj' ) } } { "obj" "恢复续延时提供的对象或 initial" } }
{ $description "从此单词返回之后的位置具体化一个续延，并将其传递给 " { $snippet "capture" } "。每次使用 " { $link continue-with } " 和新的 " { $snippet "obj" } " 恢复续延时，首先以栈上的 " { $snippet "obj" } " 调用 " { $snippet "restore" } "，然后继续执行。如果 " { $snippet "capture" } " 返回，则栈上为 " { $snippet "initial" } " 继续执行。" } ;

{ callcc0 continue callcc1 continue-with ifcc } related-words

HELP: callcc0
{ $values { "quot" { $quotation ( continuation -- ) } } }
{ $description "将引用应用于当前续延，该续延从此单词返回之后的位置具体化。每次续延被恢复时，继续执行。通常使用 " { $link continue } " 单词来恢复续延，因为任何新值实际上只是被丢弃。如果 " { $snippet "quot" } " 返回，也会继续执行。" } ;

HELP: callcc1
{ $values { "quot" { $quotation ( continuation -- initial ) } } { "obj" "恢复续延时提供的对象或 initial" } }
{ $description "将引用应用于当前续延，该续延从此单词返回之后的位置具体化。每次使用 " { $link continue-with } " 和新的 " { $snippet "obj" } " 恢复续延时，栈上为 " { $snippet "obj" } " 继续执行。如果 " { $snippet "quot" } " 返回，栈上为 " { $snippet "initial" } " 继续执行。" } ;

HELP: continue
{ $values { "continuation" continuation } }
{ $description "恢复一个通常由 " { $link callcc0 } " 具体化的续延。" }
{ $notes "这实际上是在数据栈上放置 " { $snippet "f" } " 来恢复续延。" } ;

HELP: continue-with
{ $values { "obj" "传递给恢复续延执行上下文的对象" } { "continuation" continuation } }
{ $description "恢复一个通常由 " { $link callcc1 } " 具体化的续延。续延恢复时，对象 " { $snippet "obj" } " 将被放置在数据栈上。" } ;

HELP: error
{ $description "持有最近抛出错误的全局变量。" }
{ $notes "仅由 " { $link throw } " 更新，不由 " { $link rethrow } " 更新。" } ;

HELP: error-continuation
{ $description "持有最近抛出错误的当前续延的全局变量。" }
{ $notes "仅由 " { $link throw } " 更新，不由 " { $link rethrow } " 更新。" } ;

HELP: restarts
{ $var-description "持有最近抛出错误的可能恢复选项集合的全局变量。" }
{ $notes "仅由 " { $link throw } " 更新，不由 " { $link rethrow } " 更新。" } ;

HELP: throw
{ $values { "error" object } }
{ $description "具体化并将当前续延保存在 " { $link error-continuation } " 全局变量中，然后抛出错误。执行不会在 " { $link throw } " 调用之后继续。而是调用最近的捕获块，执行从该点继续。" } ;

{ cleanup recover finally } related-words

HELP: cleanup
{ $values { "try" { $quotation ( ..a -- ..a ) } } { "cleanup-always" { $quotation ( ..a -- ..b ) } } { "cleanup-error" { $quotation ( ..b -- ..b ) } } }
{ $description "调用 " { $snippet "try" } " 引用。如果没有抛出错误，则调用 " { $snippet "cleanup-always" } " 而不恢复数据栈。如果抛出错误，则恢复数据栈，依次调用 " { $snippet "cleanup-always" } " 和 " { $snippet "cleanup-error" } "，然后重新抛出错误。" } ;

HELP: finally
{ $values { "try" { $quotation ( ..a -- ..a ) } } { "cleanup-always" { $quotation ( ..a -- ..b ) } } }
{ $description "与 " { $link cleanup } " 相同，但 " { $snippet "cleanup-error" } " 引用为空。适用于 " { $snippet "try" } " 引用之后需要运行某些清理代码（无论是否抛出错误），但不需要对任何错误做特定处理的情况。" } ;

HELP: recover
{ $values { "try" { $quotation ( ..a -- ..b ) } } { "recovery" { $quotation ( ..a error -- ..b ) } } }
{ $description "调用 " { $snippet "try" } " 引用。如果在 " { $snippet "try" } " 引用的动态范围内抛出异常，则恢复数据栈并调用 " { $snippet "recovery" } " 引用来处理错误。" } ;

HELP: ignore-error
{ $values { "quot" quotation } { "check" quotation } }
{ $description "调用引用。如果抛出的异常被 'check' 引用匹配，则忽略该异常。否则重新抛出错误。" } ;

HELP: ignore-error/f
{ $values { "quot" quotation } { "check" quotation } { "x/f" { $maybe object } } }
{ $description "类似于 " { $link ignore-error } "，但如果抛出了匹配的异常，则将 " { $link f } " 压入栈。" } ;

HELP: ignore-errors
{ $values { "quot" quotation } }
{ $description "调用引用。如果在引用的动态范围内抛出异常，则恢复数据栈并返回。" }
{ $notes "更安全的替代方案见 " { $link ignore-error } " 和 " { $link ignore-error/f } "。" } ;

HELP: in-callback?
{ $values { "?" boolean } }
{ $description "如果 Factor 当前正在执行回调，则为 t。" } ;

HELP: rethrow
{ $values { "error" object } }
{ $description "抛出错误但不将当前续延保存在 " { $link error-continuation } " 全局变量中。这样做是为了使检查错误栈能揭示异常的原始原因，而不是重新抛出的位置。" }
{ $notes
    "此单词旨在与 " { $link recover } " 结合使用，以实现执行操作后将错误传递给下一个最近错误处理器的错误处理器。"
}
{ $examples
    "" { $link with-lexer } " 单词捕获错误，用当前行号和列号进行标注，然后重新抛出："
    { $see with-lexer }
} ;

HELP: throw-restarts
{ $values { "error" object } { "restarts" { $sequence { { $snippet "{ string object }" } " 对" } } } { "restart" object } }
{ $description "使用 " { $link throw } " 抛出可恢复错误。" { $snippet "restarts" } " 参数是一个由对组成的序列，每对的第一个元素是人类可读的描述，第二个元素是任意对象。如果错误到达顶层错误处理器，用户将看到可能恢复选项的列表，选择一个后，执行将在 " { $link throw-restarts } " 调用之后继续，栈上为所选恢复选项关联的对象。" }
{ $examples
    "尝试调用以下代码抛出错误后提供的两个恢复选项之一："
    { $code
        ": restart-test ( -- )"
        "    \"Oops!\" { { \"One\" 1 } { \"Two\" 2 } } throw-restarts"
        "    \"You restarted: \" write . ;"
        "restart-test"
    }
} ;

HELP: rethrow-restarts
{ $values { "error" object } { "restarts" { $sequence { { $snippet "{ string object }" } " 对" } } } { "restart" object } }
{ $description "使用 " { $link rethrow } " 抛出可恢复错误。除此之外，此单词与 " { $link throw-restarts } " 完全相同。" } ;

{ throw rethrow throw-restarts rethrow-restarts throw-continue } related-words

HELP: throw-continue
{ $values { "error" object } }
{ $description "抛出可继续错误。如果用户选择继续执行，此单词正常返回。" } ;

HELP: compute-restarts
{ $values { "error" object } { "seq" sequence } }
{ $description "输出一个三元组序列，每个三元组由人类可读字符串、对象和续延组成。用对应对象恢复续延将立即在对应的 " { $link condition } " 调用之后继续执行。"
$nl
"此单词沿委托链递归向上遍历，以整理嵌套和包装条件的恢复选项。" } ;

HELP: save-error
{ $values { "error" "错误" } }
{ $description "由错误处理器在抛出错误后调用，以设置 " { $link error } " 和 " { $link restarts } " 全局变量。" }
$low-level-note ;

HELP: with-datastack
{ $values { "stack" sequence } { "quot" quotation } { "new-stack" sequence } }
{ $description "使用给定的数据栈内容执行引用，并在单词返回后输出新的数据栈。输入序列不会被修改；会生成一个新序列。不影响周围代码中的数据栈，只是消费两个输入并压入输出。" }
{ $examples
    { $example "USING: continuations math prettyprint ;" "{ 3 7 } [ + ] with-datastack ." "{ 10 }" }
} ;

HELP: attempt-all
{ $values
    { "seq" sequence } { "quot" quotation }
    { "obj" object } }
{ $description "将引用应用于序列中的元素，返回第一个不抛出错误的引用的值。如果所有引用都抛出错误，则返回最后抛出的错误。" }
{ $examples "前两个数字抛出错误，最后一个不会："
    { $example
    "USING: prettyprint continuations kernel math ;"
    "{ 1 3 6 } [ dup odd? [ \"Odd\" throw ] when ] attempt-all ."
    "6" }
    "所有引用都抛出错误，最后一个异常被重新抛出："
    { $example
    "USING: prettyprint continuations kernel math ;"
    "[ { 1 3 5 } [ dup odd? [ throw ] when ] attempt-all ] [ ] recover ."
    "5"
    }
} ;

HELP: return
{ $description "通过恢复由 " { $link with-return } " 具体化的续延来提前返回引用；执行从 " { $link with-return } " 之后立即继续。" } ;

HELP: with-return
{ $values
    { "quot" { $quotation ( obj -- obj' ) } } }
{ $description "从此单词返回之后的位置具体化续延，并允许在 " { $snippet "quot" } " 中调用 " { $link return } " 来轻松恢复续延并继续执行。如果未调用 " { $link return } " 且 " { $snippet "quot" } " 正常返回，则执行继续（就像此单词只是 " { $link call } " 一样）。" }
{ $examples
    "只有 \"Hi\" 会被打印："
    { $example
    "USING: prettyprint continuations io ;"
    "[ \"Hi\" print return \"Bye\" print ] with-return"
    "Hi"
} } ;

{ return with-return } related-words

HELP: restart
{ $values { "restart" restart } }
{ $description "调用一个恢复选项。" }
{ $class-description "恢复选项的类。" } ;
