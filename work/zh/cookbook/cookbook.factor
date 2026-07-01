! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! Factor 食谱（Cookbook）— 中文翻译
! 原始文件: D:\factor\basis\help\cookbook\cookbook.factor
!
USING: help.markup help.syntax io kernel math parser
prettyprint sequences vocabs.loader namespaces stack-checker
help command-line see ;
IN: zh.cookbook

ARTICLE: "cookbook-syntax-zh" "基本语法食谱"
"以下是一段简单的 Factor 代码："
{ $example "10 sq 5 - ." "95" }
"你可以点击它，在监听器（listener）中求值，它将打印出与上面相同的输出值。"
$nl
"Factor 有非常简单的语法。你的程序由 " { $emphasis "字（words）" } " 和 " { $emphasis "字面量（literals）" } " 组成。在上面的代码中，字是 " { $link sq } "、" { $link - } " 和 " { $link . } "。两个整数 10 和 5 是字面量。"
$nl
"Factor 从左到右求值程序，并将中间值存储在一个 " { $emphasis "栈（stack）" } " 上。如果你把栈想象成一摞纸，那么 " { $emphasis "压入（pushing）" } " 一个值到栈上相当于将一张纸放在这摞纸的顶部，而 " { $emphasis "弹出（popping）" } " 一个值相当于移除最上面的那张纸。"
$nl
"所有字都有一个 " { $emphasis "栈效果声明（stack effect declaration）" } "，例如 " { $snippet "( x y -- z )" } " 表示一个字接受两个输入（" { $snippet "y" } " 在栈顶），并返回一个输出。栈效果声明可以通过浏览源代码来查看，或使用诸如 " { $link see } " 等工具；它们还会被编译器检查。参见 " { $link "effects" } "。"
$nl
"回到本文开头的例子，以下是代码求值时所发生的一系列步骤："
{ $table
    { { $strong "操作" } { $strong "栈内容" } }
    { "10 被压入栈。" { $snippet "10" } }
    { { "执行 " { $link sq } " 字。它从栈中弹出一个输入（整数 10）并计算其平方，将结果压入。" } { $snippet "100" } }
    { { "5 被压入栈。" } { $snippet "100 5" } }
    { { "执行 " { $link - } " 字。它从栈中弹出两个输入（整数 100 和 5），用 100 减去 5，将结果压入。" } { $snippet "95" } }
    { { "执行 " { $link . } " 字。它从栈中弹出一个输入（整数 95），并在监听器的输出区域打印其值。" } { } }
}
"Factor 支持许多其他数据类型："
{ $code
    "10.5"
    "\"字符串\""
    "{ 1 2 3 }"
    "! 顺便说一句，这是注释"
}
{ $references
    { "Factor 的语法可以扩展，解析器可以反射性地调用，而 " { $link . } " 字实际上是一个通用工具，能将几乎任何对象转换为可被解析回来的形式。如果你对此感兴趣，请参考以下部分：" }
    "syntax"
    "parser"
    "prettyprint"
} ;

ARTICLE: "cookbook-colon-defs-zh" "栈操作与定义食谱"
{ $link dup } " 字将栈顶的值复制一份："
{ $example "5 dup * ." "25" }
{ $link sq } " 字实际上是这样定义的："
{ $code ": sq ( x -- y ) dup * ;" }
"（你可以通过点击 " { $link sq } " 字本身来查找这个定义。）"
$nl
"请注意字定义中的关键元素：冒号 " { $link POSTPONE: : } " 表示字定义的开始。新字的名称和栈效果声明必须紧跟其后。字定义持续进行，直到 " { $link POSTPONE: ; } " 标记表示定义的结束。这种类型的字定义称为 " { $emphasis "复合定义（compound definition）" } "。"
$nl
"Factor 的精髓在于通过简短而合乎逻辑的冒号定义来实现代码复用。将一个问题分解为易于测试的小片段被称为 " { $emphasis "因式分解（factoring）" } "。"
$nl
"另一个冒号定义的例子："
{ $code ": neg ( x -- -x ) 0 swap - ;" }
"这里使用了 " { $link swap } " 栈操作字来交换栈顶两个元素的位置。请注意 " { $link swap } " 在以下两段代码中所产生的差异："
{ $code
    "5 0 -       ! 计算 5-0"
    "5 0 swap -  ! 计算 0-5"
}
"此外，上例中的栈效果声明写在 " { $snippet "(" } " 和 " { $snippet ")" } " 之间，用助记方式描述了字对栈做了什么。详情参见 " { $link "effects" } "。"
{ $curious
  "这种语法对任何以前使用过 Forth 的人来说都很熟悉。然而，与 Forth 不同的是，Factor 还执行了一些额外的静态检查。参见 " { $link "definition-checking" } " 和 " { $link "inference" } "。"
}
{ $references
    { "有一整套栈操作字可用于重排栈。除了冒号定义，还有其他形式的字定义，字可以完全在运行时定义，而且字定义可以通过跟踪调用和断点来" { $emphasis "注解（annotated）" } "，无需修改源代码。" }
    "shuffle-words"
    "words"
    "generic"
    "handbook-tools-reference"
} ;

ARTICLE: "cookbook-combinators-zh" "控制流食谱"
"一个 " { $emphasis "引用（quotation）" } " 是一个包含可求值代码的对象。"
{ $code
    "2 2 + .     ! 打印 4"
    "[ 2 2 + . ] ! 压入一个引用"
}
"第二个例子压入的引用在被 " { $link call } " 调用时将打印 4。"
$nl
"引用用于实现控制流。例如，条件执行通过 " { $link if } " 实现："
{ $code
    ": sign-test ( n -- )"
    "    dup 0 < ["
    "        drop \"负数\""
    "    ] ["
    "        zero? [ \"零\" ] [ \"正数\" ] if"
    "    ] if print ;"
}
{ $link if } " 字接受一个布尔值、一个真引用和一个假引用，根据布尔值的真假执行两个引用之一。在 Factor 中，任何不等于特殊值 " { $link f } " 的对象都被视为真，而 " { $link f } " 为假。"
$nl
"另一种有用的控制流形式是迭代。你可以多次执行某操作："
{ $code "10 [ \"Factor 太棒了！\" print ] times" }
"现在我们来看一种新的数据类型——数组："
{ $code "{ 1 2 3 }" }
"数组与引用的区别在于数组不能被执行；它只存储数据。"
$nl
"你可以对数组的每个元素执行操作："
{ $example
    "USING: io sequences prettyprint ;"
    "{ 1 2 3 } [ \"数字是 \" write . ] each"
    "数字是 1\n数字是 2\n数字是 3"
}
"你可以变换每个元素，将结果收集到一个新数组中："
{ $example "{ 5 12 0 -12 -5 } [ sq ] map ." "{ 25 144 0 144 25 }" }
"你可以创建一个新数组，只包含满足某个条件的元素："
{ $example
    ": negative? ( n -- ? ) 0 < ;"
    "{ -12 10 16 0 -1 -3 -9 } [ negative? ] filter ."
    "{ -12 -1 -3 -9 }"
}
{ $references
    { "因为引用是对象，所以它们可以被随意构造和拆解。你可以编写生成代码的代码。数组只是各种类型的序列中的一种，像 " { $link each } " 和 " { $link map } " 这样的序列操作适用于所有类型的序列。此外还有比上述例子多得多的序列迭代操作。" }
    "combinators"
    "sequences"
} ;

ARTICLE: "cookbook-variables-zh" "动态变量食谱"
"符号（symbol）是一种在执行时将自身压入栈的字。试试看："
{ $example "SYMBOL: foo" "foo ." "foo" }
"在使用变量之前，必须为它定义一个符号："
{ $code "SYMBOL: name" }
"符号可以被传递给 " { $link get } " 和 " { $link set } " 字以读取和写入变量值："
{ $unchecked-example "\"Slava\" name set" "name get print" "Slava" }
"如果在 " { $link with-scope } " 内部设置变量，它们的值在离开作用域后会丢失："
{ $unchecked-example
    ": print-name ( -- ) name get print ;"
    "\"张三\" name set"
    "["
    "    \"李四\" name set"
    "    \"在里面，名字是 \" write  print-name"
    "] with-scope"
    "\"在这里，名字是 \" write  print-name"
    "在里面，名字是 李四\n在这里，名字是 张三"
}
{ $references
    "关于动态作用域变量和命名空间还有很多内容可以讲。"
    "namespaces"
} ;

ARTICLE: "cookbook-vocabs-zh" "词汇表食谱"
"字并不在一个扁平列表中，而是属于词汇表（vocabularies）；每个字恰好包含在一个词汇表中。解析字名时，解析器会在词汇表中搜索。在监听器（listener）中工作时，已经有一组有用的词汇表可用。在源文件中，所有要使用的词汇表都必须被导入。"
$nl
"例如，包含以下代码的源文件在尝试加载时将打印解析错误："
{ $code "\"你好，世界\" print" }
{ $link print } " 字包含在 " { $vocab-link "io" } " 词汇表中，该词汇表在监听器中可用，但在源文件中必须显式添加到搜索路径中："
{ $code
    "USE: io"
    "\"你好，世界\" print"
}
"通常一个源文件会引用多个词汇表中的字，它们可以一次性添加到搜索路径中："
{ $code "USING: arrays kernel math ;" }
"新字默认进入 " { $vocab-link "scratchpad" } " 词汇表。你可以用 " { $link POSTPONE: IN: } " 改变这一点："
{ $code
    "IN: time-machine"
    ": time-travel ( when what -- ) frob fizz flap ;"
}
"请注意，字必须先定义才能被引用。以下写法通常是无效的："
{ $code
    ": frob ( what -- ) accelerate particles ;"
    ": accelerate ( -- ) accelerator on ;"
    ": particles ( what -- ) [ (particles) ] each ;"
}
"你必须将第一个定义放在另外两个之后，解析器才能接受该文件。如果你有一组相互递归的字，可以使用 " { $link POSTPONE: DEFER: } "。"
{ $references
    { }
    "word-search"
    "words"
    "parser"
} ;

ARTICLE: "cookbook-application-zh" "应用程序食谱"
"词汇表可以定义一个主入口点："
{ $code "IN: game-of-life"
"..."
": play-life ( -- ) ... ;"
""
"MAIN: play-life"
}
"详情参见 " { $link POSTPONE: MAIN: } "。" { $link run } " 字在必要时加载词汇表，并调用其主入口点；试试以下命令，很有趣："
{ $code "\"tetris\" run" }
"Factor 可以部署独立的可执行文件；它们没有任何外部依赖，完全由编译后的本地机器码组成："
{ $code "\"tetris\" deploy-tool" }
{ $references
    { }
    "vocabs.loader"
    "tools.deploy"
    "ui.tools.deploy"
    "cookbook-scripts-zh"
} ;

ARTICLE: "cookbook-scripts-zh" "脚本食谱"
"Factor 可用于类 Unix 系统上的命令行脚本。"
$nl
"要运行一个脚本，只需将其作为参数传递给 Factor 可执行文件："
{ $code "./factor cleanup.factor" }
"要在监听器中测试脚本，可以使用 " { $link run-file } "。"
$nl
"脚本可以通过检查 " { $link command-line } " 变量的值来访问命令行参数。它还可以从 " { $link script } " 变量获取自身的路径。"
{ $heading "示例：ls" }
"以下是一个用 Factor 实现 Unix " { $snippet "ls" } " 命令简化版的例子："
{ $code
    "USING: command-line namespaces io io.files
io.pathnames tools.files sequences kernel ;

command-line get [
    \".\" directory.
] [
    dup length 1 = [ first directory. ] [
        [ [ nl write \":\" print ] [ directory. ] bi ] each
    ] if
] if-empty"
}
"你可以将其放入名为 " { $snippet "ls.factor" } " 的文件中，然后运行它，例如列出 " { $snippet "/usr/bin" } " 目录："
{ $code "./factor ls.factor /usr/bin" }
{ $heading "示例：grep" }
"以下是一个更复杂的示例，实现了类似 Unix " { $snippet "grep" } " 命令的功能："
{ $code "USING: kernel fry io io.files io.encodings.ascii sequences
regexp command-line namespaces ;
IN: grep

: grep-lines ( pattern -- )
    '[ dup _ matches? [ print ] [ drop ] if ] each-line ;

: grep-file ( pattern filename -- )
    ascii [ grep-lines ] with-file-reader ;

: grep-usage ( -- )
    \"用法: factor grep.factor <模式> [<文件>...]\" print ;

command-line get [
    grep-usage
] [
    unclip <regexp> swap [
        grep-lines
    ] [
        [ grep-file ] with each
    ] if-empty
] if-empty" }
"你可以这样运行它："
{ $code "./factor grep.factor '.*你好.*' myfile.txt" }
"你会注意到这个脚本启动需要一段时间。这是因为它每次都会加载并编译 " { $vocab-link "regexp" } " 词汇表。要加速启动，请将词汇表加载到你的映像（image）中，并保存映像："
{ $code "USE: regexp" "save" }
"现在，" { $snippet "grep.factor" } " 脚本的启动速度会快得多。详情参见 " { $link "images" } "。"
{ $heading "可执行脚本" }
"也可以制作可执行脚本。Factor 文件可以以如下 'shebang' 开头："
{ $code "#!/usr/bin/env factor" }
"如果将该文本文件设为可执行，则可以运行它，前提是 " { $snippet "factor" } " 二进制文件在你的 " { $snippet "$PATH" } " 中。"
{ $references
    { }
    "command-line"
    "cookbook-application-zh"
    "images"
} ;

ARTICLE: "cookbook-philosophy-zh" "Factor 哲学"
"学习栈语言就像骑自行车：需要一点练习，可能会磕破几次膝盖，但一旦掌握了窍门，就会变得驾轻就熟。"
$nl
"初学者最常见的困难是，尝试一次性在栈上放置太多值，导致难以阅读和编写代码。"
$nl
"牢记以下指南，避免失去平衡感："
{ $list
    "简化、简化、再简化。将程序分解为每次只操作少量值的小字（small words）。大多数字定义应能放在一行内；极少应超过两到三行。"
    "除了保持字的短小以外，还要保持其有意义。给它们起好名字，确保每个字只做一件事。尝试为你的字写文档；如果某字的文档含糊不清或复杂冗长，很可能该字的定义也有问题。不要害怕重构你的代码。"
    "如果你的代码看起来重复了，就再分解（factor）一下。"
    "如果分解之后代码仍然重复，就引入组合子（combinators）。"
    "如果引入组合子之后代码还重复，就考虑使用元编程技术。"
    { "尽量按需要的顺序将项目放在栈上。如果一切都在正确的顺序中，就不需要任何栈操作（shuffling）。" }
    { "如果你发现自己在某个字定义的中间写栈注释（stack comment），就该把这个字拆开。" }
    { "使用 " { $link "cleave-combinators" } " 和 " { $link "spread-combinators" } "，而不是 " { $link "shuffle-words" } "，以赋予代码更多结构。" }
    { "并非所有东西都要放在栈上。" { $vocab-link "namespaces" } " 词汇表提供了动态作用域变量，" { $vocab-link "locals" } " 词汇表提供了词法作用域变量。学习这两者，并在合适的场合使用它们，但要记住，过度使用变量会使代码更难分解（factor）。" }
    "每次定义一个仅以抽象方式（与程序领域无关）操作序列、哈希表或对象的字时，请检查库中是否已有可以复用的现有定义。"
    { "编写单元测试。Factor 为单元测试提供了良好的支持；参见 " { $link "tools.test" } "。一旦你的程序有了良好的测试套件，就可以自信地重构并及时捕获回归。" }
    "不要像写 C 那样写 Factor。命令式编程和索引循环几乎从来不是最惯用的解决方案。"
    { "使用序列（sequences）、关联映射（assocs）和对象来分组相关数据。对象分配非常廉价。不要害怕创建元组（tuples）、对（pairs）和三对（triples）。也不要害怕分配新对象的操作，如 " { $link append } "。" }
    { "如果你发现自己正在用序列和索引写循环，几乎总有更好的方法。把 " { $link "sequences-combinators" } " 牢记于心。" }
    { "如果你发现自己正在写一个深度嵌套的、每次迭代执行多个步骤的循环，几乎总有更好的方法。将问题分解为一系列对数据的传递，通过一系列简单的循环逐步将其转换为期望的结果。将循环分解出来并复用它们。如果你的工作涉及数学相关内容，请把 " { $link "math-vectors" } " 牢记于心。" }
    { "如果你发现自己希望能在数据栈上迭代，或将数据栈的内容捕获到序列中，或将序列的每个元素推入数据栈，几乎总有更好的方法。改用 " { $link "sequences" } "。" }
    "如果有更简单的方式，就不要使用元编程。"
    "除非你的程序确实太慢，否则不要担心效率。不要因为你认为复杂的代码更高效就选择它而不是简单代码。Factor 编译器旨在让惯用代码运行得更快。"
    { "以上都不是硬性规则：每一项都有例外。但有一条规则无条件成立：" { $emphasis "总有更简单的方法" } "。" }
}
"Factor 尽可能多地实现自身，因为这样可以提高简洁性和性能。其后果之一是 Factor 将其内部实现暴露出来供扩展和研究。你甚至可以选择使用高级语言中通常不具备的底层特性，如手动内存管理、指针运算和内联汇编代码。"
$nl
"不安全的特性被隐藏起来，因此你不会意外调用它们，也不必为解决常规编程问题而使用它们。然而当需要出现时，不安全特性是无价之宝，例如在直接与 C 库交互时可能需要进行指针运算。" ;

ARTICLE: "cookbook-pitfalls-zh" "应避免的陷阱"
"Factor 是一种非常干净且一致的语言。但它有一些局限和抽象泄漏需要牢记，以及与您可能习惯的其他语言不同的行为。"
{ $list
    "Factor 仅使用一个原生线程，Factor 线程是合作式调度的。C 库调用会阻塞整个虚拟机。"
    "Factor 不对程序员隐藏任何东西，所有内部实现都是暴露的。你有责任避免编写过于依赖实现细节的脆弱代码。"
    { "如果字面量（literal）对象出现在字定义中，当该字执行时，对象本身（而非其副本）会被压入栈。如果你打算修改此对象，必须先 " { $link clone } " 它。参见 " { $link "syntax-literals" } "。" }
    { "同样，" { $link dup } " 及相关的栈操作字不会复制整个对象或数组；它们只复制对它们的引用。如果你想保护对象免受修改，请使用 " { $link clone } "。" }
    { "关于 " { $link f } " 对象可能引发的问题的讨论，参见 " { $link "booleans" } "。" }
    { "Factor 的对象系统相当灵活。不当使用联合（union）、混入（mixin）和谓词类（predicate class）可能导致与其他语言中\"多重继承\"类似的问题。特别是，可以有两个类，它们的交集非空，但彼此之间不是子类关系。如果一个泛型字（generic word）在这两个类上定义了方法，会有各种消歧规则确保方法分派保持确定性，但它们可能并非你所期望的结果。详情参见 " { $link "method-order" } "。" }
    { "如果 " { $link run-file } " 抛出一个栈深度断言，这意味着文件中的顶层形式在栈上留下了值。Factor 会在加载源文件前后比较栈深度，因为这种情况几乎总是一个错误。如果你有正当理由需要加载一个以某种方式返回数据的源文件，请在源文件中定义一个产生这些数据的字，并在加载文件后调用该字。" }
} ;

ARTICLE: "cookbook-next-zh" "下一步"
"通读了 " { $link "first-program" } " 和 " { $link "cookbook" } " 之后，继续学习 Factor 的最佳方式是开始看一些简单的示例程序。以下是一些特别好的词汇表，可以让你忙上一阵："
{ $list
    { $vocab-link "base64" }
    { $vocab-link "roman" }
    { $vocab-link "rot13" }
    { $vocab-link "smtp" }
    { $vocab-link "time-server" }
    { $vocab-link "tools.hexdump" }
    { $vocab-link "webapps.counter" }
}
"如果你看到其中有不明白的代码，请使用 " { $link see } " 和 " { $link help } " 来探索。" ;

ARTICLE: "cookbook-zh" "Factor 食谱"
"Factor 食谱是对 Factor 编程所需最重要概念的高层概览。"
{ $subsections
    "cookbook-syntax-zh"
    "cookbook-colon-defs-zh"
    "cookbook-combinators-zh"
    "cookbook-variables-zh"
    "cookbook-vocabs-zh"
    "cookbook-application-zh"
    "cookbook-scripts-zh"
    "cookbook-philosophy-zh"
    "cookbook-pitfalls-zh"
    "cookbook-next-zh"
} ;

ABOUT: "cookbook-zh"
