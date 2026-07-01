USING: help.markup help.syntax io kernel math parser
prettyprint sequences vocabs.loader namespaces stack-checker
help command-line see ;
IN: help.cookbook

ARTICLE: "cookbook-syntax" "基本语法食谱"
"以下是一段简单的 Factor 代码："
{ $example "10 sq 5 - ." "95" }
"你可以点击它以在监听器中求值，它将打印出与上面所示相同的输出值。"
$nl
"Factor 的语法非常简单。你的程序由" { $emphasis "词" } "和" { $emphasis "字面量" } "组成。在上面的代码片段中，词是 " { $link sq } "、" { $link - } " 和 " { $link . } "。两个整数 10 和 5 是字面量。"
$nl
"Factor 从左到右求值，并将中间值存储在" { $emphasis "栈" } "上。如果你把栈想象成一叠纸，那么" { $emphasis "压栈" } "一个值就相当于在纸叠顶部放置一张纸，而" { $emphasis "出栈" } "一个值则相当于移走最上面的那张纸。"
$nl
"所有词都有一个" { $emphasis "栈效果声明" } "，例如 " { $snippet "( x y -- z )" } " 表示一个词接受两个输入，其中 " { $snippet "y" } " 在栈顶，并返回一个输出。栈效果声明可以通过浏览源代码或使用 " { $link see } " 等工具查看；编译器也会对它们进行检查。参见 " { $link "effects" } "。"
$nl
"回到本文开头那个例子，代码求值时会经历以下一系列步骤："
{ $table
    { { $strong "操作" } { $strong "栈内容" } }
    { "10 被压入栈中。" { $snippet "10" } }
    { { "执行 " { $link sq } " 词。它从栈中弹出一个输入（整数 10），将其平方，并将结果压入栈中。" } { $snippet "100" } }
    { { "5 被压入栈中。" } { $snippet "100 5" } }
    { { "执行 " { $link - } " 词。它从栈中弹出两个输入（整数 100 和 5），从 100 中减去 5，并将结果压入栈中。" } { $snippet "95" } }
    { { "执行 " { $link . } " 词。它从栈中弹出一个输入（整数 95），并将其在监听器的输出区域中打印。" } { } }
}
"Factor 还支持许多其他数据类型："
{ $code
    "10.5"
    "\"character strings\""
    "{ 1 2 3 }"
    "! by the way, this is a comment"
}
{ $references
    { "Factor 的语法可以扩展，解析器可以被反射式调用，而 " { $link . } " 词实际上是一种通用工具，能将几乎所有对象转换为可以再次被解析的形式。如果你对此感兴趣，请参阅以下章节：" }
    "syntax"
    "parser"
    "prettyprint"
} ;

ARTICLE: "cookbook-colon-defs" "重排词与定义食谱"
{ $link dup } " 词复制栈顶的值："
{ $example "5 dup * ." "25" }
{ $link sq } " 词实际上定义如下："
{ $code ": sq ( x -- y ) dup * ;" }
"（你可以通过点击 " { $link sq } " 词本身来查看这个定义。）"
$nl
"注意词定义中的关键元素：冒号 " { $link POSTPONE: : } " 表示词定义的开始。新词的名称和栈效果声明必须紧随其后。词定义随后继续，直到 " { $link POSTPONE: ; } " 标记标志着定义的结束。这种类型的词定义称为" { $emphasis "复合定义" } "。"
$nl
"Factor 的精髓在于通过简短而合乎逻辑的冒号定义来实现代码复用。将问题分解为易于测试的小片段，这种方法称为" { $emphasis "因式分解" } "。"
$nl
"冒号定义的另一个例子："
{ $code ": neg ( x -- -x ) 0 swap - ;" }
"这里使用 " { $link swap } " 重排词来交换栈顶两个元素。注意 " { $link swap } " 在以下两个代码片段中造成的差异："
{ $code
    "5 0 -       ! Computes 5-0"
    "5 0 swap -  ! Computes 0-5"
}
"另外，在上面的例子中，栈效果声明写在 " { $snippet "(" } " 和 " { $snippet ")" } " 之间，用来描述该词对栈执行的操作。详情参见 " { $link "effects" } "。"
{ $curious
  "这种语法对任何使用过 Forth 的人来说都很熟悉。然而，与 Forth 不同的是，Factor 会执行一些额外的静态检查。参见 " { $link "definition-checking" } " 和 " { $link "inference" } "。"
}
{ $references
    { "可以用一大堆重排词来重新排列栈。除了冒号定义之外，还有其他形式的词定义，词可以在运行时完全定义，而且词定义可以被" { $emphasis "注解" } "添加跟踪调用和断点，而无需修改源代码。" }
    "shuffle-words"
    "words"
    "generic"
    "handbook-tools-reference"
} ;

ARTICLE: "cookbook-combinators" "控制流食谱"
{ $emphasis "引用" } " 是一个包含可求值代码的对象。"
{ $code
    "2 2 + .     ! Prints 4"
    "[ 2 2 + . ] ! Pushes a quotation"
}
"第二个例子压入的引用，在被 " { $link call } " 调用时会打印 4。"
$nl
"引用用于实现控制流。例如，条件执行通过 " { $link if } " 来完成："
{ $code
    ": sign-test ( n -- )"
    "    dup 0 < ["
    "        drop \"negative\""
    "    ] ["
    "        zero? [ \"zero\" ] [ \"positive\" ] if"
    "    ] if print ;"
}
{ $link if } " 词接受一个布尔值、一个真引用和一个假引用，并根据布尔值执行两个引用之一。在 Factor 中，任何不等于特殊值 " { $link f } " 的对象都被视为真，而 " { $link f } " 为假。"
$nl
"另一种有用的控制流形式是迭代。你可以多次执行某项操作："
{ $code "10 [ \"Factor rocks!\" print ] times" }
"现在我们来看看一种新的数据类型——数组："
{ $code "{ 1 2 3 }" }
"数组与引用的区别在于数组不能被求值，它只是存储数据。"
$nl
"你可以对数组中的每个元素执行一个操作："
{ $example
    "USING: io sequences prettyprint ;"
    "{ 1 2 3 } [ \"The number is \" write . ] each"
    "The number is 1\nThe number is 2\nThe number is 3"
}
"你可以转换每个元素，将结果收集到一个新数组中："
{ $example "{ 5 12 0 -12 -5 } [ sq ] map ." "{ 25 144 0 144 25 }" }
"你可以创建一个新数组，只包含满足某个条件的元素："
{ $example
    ": negative? ( n -- ? ) 0 < ;"
    "{ -12 10 16 0 -1 -3 -9 } [ negative? ] filter ."
    "{ -12 -1 -3 -9 }"
}
{ $references
    { "由于引用是对象，因此可以随意构造和拆解。你可以编写生成代码的代码。数组只是各种序列类型之一，而诸如 " { $link each } " 和 " { $link map } " 之类的序列操作适用于所有类型的序列。除了上面这些之外，还有更多的序列迭代操作。" }
    "combinators"
    "sequences"
} ;

ARTICLE: "cookbook-variables" "动态变量食谱"
"符号（symbol）是一种在执行时将自身压入栈中的词。试一试："
{ $example "SYMBOL: foo" "foo ." "foo" }
"在使用变量之前，你必须为它定义一个符号："
{ $code "SYMBOL: name" }
"符号可以传递给 " { $link get } " 和 " { $link set } " 词来读取和写入变量值："
{ $unchecked-example "\"Slava\" name set" "name get print" "Slava" }
"如果你在 " { $link with-scope } " 中设置变量，离开作用域后这些值将会丢失："
{ $unchecked-example
    ": print-name ( -- ) name get print ;"
    "\"Slava\" name set"
    "["
    "    \"Diana\" name set"
    "    \"There, the name is \" write  print-name"
    "] with-scope"
    "\"Here, the name is \" write  print-name"
    "There, the name is Diana\nHere, the name is Slava"
}
{ $references
    "关于动态作用域变量和命名空间还有很多内容可讲。"
    "namespaces"
} ;

ARTICLE: "cookbook-vocabs" "词汇表食谱"
"词并不在一个扁平的列表中，而是属于词汇表（vocabularies）；每个词恰好属于一个词汇表。解析词名时，解析器会搜索各词汇表。在监听器中工作时，一组有用的词汇表已经可用。但在源文件中，所有使用的词汇表都必须被导入。"
$nl
"例如，包含以下代码的源文件在加载时会打印一个解析错误："
{ $code "\"Hello world\" print" }
{ $link print } " 词包含在 " { $vocab-link "io" } " 词汇表中，该词汇表在监听器中可用，但在源文件中必须显式添加到搜索路径中："
{ $code
    "USE: io"
    "\"Hello world\" print"
}
"通常一个源文件会引用多个词汇表中的词，它们可以一次性全部添加到搜索路径中："
{ $code "USING: arrays kernel math ;" }
"新词默认放入 " { $vocab-link "scratchpad" } " 词汇表。你可以用 " { $link POSTPONE: IN: } " 来更改："
{ $code
    "IN: time-machine"
    ": time-travel ( when what -- ) frob fizz flap ;"
}
"注意，词在被引用之前必须先定义。以下代码通常是无效的："
{ $code
    ": frob ( what -- ) accelerate particles ;"
    ": accelerate ( -- ) accelerator on ;"
    ": particles ( what -- ) [ (particles) ] each ;"
}
"你必须将第一个定义放在其他两个之后，解析器才能接受该文件。如果你有一组相互递归的词，可以使用 " { $link POSTPONE: DEFER: } "。"
{ $references
    { }
    "word-search"
    "words"
    "parser"
} ;

ARTICLE: "cookbook-application" "应用程序食谱"
"词汇表可以定义一个主入口点："
{ $code "IN: game-of-life"
"..."
": play-life ( -- ) ... ;"
""
"MAIN: play-life"
}
"详情参见 " { $link POSTPONE: MAIN: } "。" { $link run } " 词会在必要时加载词汇表，并调用其主入口点；试试下面的命令，很有趣："
{ $code "\"tetris\" run" }
"Factor 可以部署独立的可执行文件；它们没有任何外部依赖，完全由编译后的本机机器码组成："
{ $code "\"tetris\" deploy-tool" }
{ $references
    { }
    "vocabs.loader"
    "tools.deploy"
    "ui.tools.deploy"
    "cookbook-scripts"
} ;

ARTICLE: "cookbook-scripts" "脚本编写食谱"
"Factor 可以在类 Unix 系统上用于命令行脚本编写。"
$nl
"要运行脚本，只需将其作为参数传递给 Factor 可执行文件："
{ $code "./factor cleanup.factor" }
"要在监听器中测试脚本，可以使用 " { $link run-file } "。"
$nl
"脚本可以通过检查 " { $link command-line } " 变量的值来访问命令行参数。它还可以通过 " { $link script } " 变量获取自身的路径。"
{ $heading "示例：ls" }
"以下是一个用 Factor 实现简化版 Unix " { $snippet "ls" } " 命令的示例："
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
"你可以把它放在一个名为 " { $snippet "ls.factor" } " 的文件中，然后运行它，例如列出 " { $snippet "/usr/bin" } " 目录："
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
    \"Usage: factor grep.factor <pattern> [<file>...]\" print ;

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
{ $code "./factor grep.factor '.*hello.*' myfile.txt" }
"你会发现这个脚本启动需要一些时间。这是因为它每次都要加载并编译 " { $vocab-link "regexp" } " 词汇表。为了加快启动速度，可以将该词汇表加载到你的镜像中，并保存镜像："
{ $code "USE: regexp" "save" }
"现在，" { $snippet "grep.factor" } " 脚本的启动会快得多。详情参见 " { $link "images" } "。"
{ $heading "可执行脚本" }
"也可以制作可执行脚本。一个 Factor 文件可以以如下所示的"shebang"开头："
{ $code "#!/usr/bin/env factor" }
"如果该文本文件被设为可执行，那么只要 " { $snippet "factor" } " 二进制文件在你的 " { $snippet "$PATH" } " 中，就可以直接运行它。"
{ $references
    { }
    "command-line"
    "cookbook-application"
    "images"
} ;

ARTICLE: "cookbook-philosophy" "Factor 哲学"
"学习栈语言就像学骑自行车：需要一点练习，你可能还会擦破几次膝盖，但一旦掌握了诀窍，它就会变得像第二天性一样自然。"
$nl
"初学者最常遇到的困难是难以读写代码，这是由于一次在栈上放置了太多值导致的。"
$nl
"请记住以下准则，以免失去平衡感："
{ $list
    "简化，简化，再简化。将你的程序分解成一次只处理少数几个值的小词。大多数词定义应该能放在一行里；很少会超过两三行。"
    "除了保持词简短外，还要让它们有意义。给它们起一个好名字，确保每个词只做一件事。尝试为你的词编写文档；如果某个词的文档不清楚或很复杂，那么这个词的定义很可能也是如此。不要害怕重构你的代码。"
    "如果你的代码看起来有重复，就进一步因式分解。"
    "如果因式分解后，你的代码仍然看起来有重复，就引入组合子（combinators）。"
    "如果引入组合子后，你的代码仍然看起来有重复，就考虑使用元编程技术。"
    "尽量按照所需的顺序将项放置在栈上。如果一切顺序正确，就不需要执行任何重排操作。"
    "如果你发现自己在一个词的中间写栈注释，就把这个词拆分开。"
    { "使用 " { $link "cleave-combinators" } " 和 " { $link "spread-combinators" } " 代替 " { $link "shuffle-words" } "，让你的代码更有结构。" }
    { "并非所有东西都必须放在栈上。" { $vocab-link "namespaces" } " 词汇表提供了动态作用域变量，" { $vocab-link "locals" } " 词汇表提供了词法作用域变量。学习两者并在合适的地方使用它们，但请记住，过度使用变量会使代码更难进行因式分解。" }
    "每次你定义了一个仅仅以抽象方式操作序列、哈希表或对象，且与你的程序领域无关的词时，请检查库中是否已有现成的定义可以复用。"
    { "编写单元测试。Factor 对单元测试有很好的支持；参见 " { $link "tools.test" } "。一旦你的程序有了良好的测试套件，你就可以放心地重构并及早发现回归。" }
    "不要像写 C 那样写 Factor。命令式编程和索引循环几乎总是不是最地道的解决方案。"
    { "使用序列、关联表和对象来组织相关数据。对象分配非常廉价。不要害怕创建元组、对和三元组。也不要害怕那些分配新对象的操作，比如 " { $link append } "。" }
    { "如果你发现自己正在写一个带序列和索引的循环，几乎总有更好的方法。把 " { $link "sequences-combinators" } " 记在心里。" }
    { "如果你发现自己正在写一个深度嵌套的循环，每次迭代执行多个步骤，几乎总有更好的方法。相反，将问题分解为对数据的一系列遍历，通过一系列简单的循环逐步将其转换为所需的结果。将循环提取出来并复用。如果你在做任何与数学相关的工作，把 " { $link "math-vectors" } " 记在心里。" }
    { "如果你发现自己是想遍历数据栈，或将数据栈的内容捕获到一个序列中，或将序列的每个元素压入数据栈，几乎总有更好的方法。请使用 " { $link "sequences" } "。" }
    "如果有更简单的方法，就不要使用元编程。"
    "除非你的程序太慢，否则不要担心效率。不要仅仅因为觉得会更高效，就偏好复杂代码而不是简单代码。Factor 编译器旨在让地道代码运行得很快。"
    { "以上都不是硬性规则：它们都有例外。但有一条规则无条件成立：" { $emphasis "总有更简单的方法" } "。" }
}
"Factor 尽可能地用自身来实现自身，因为这能提高简洁性和性能。其结果之一是 Factor 暴露了其内部实现以供扩展和研究。你甚至可以使用高级语言中通常没有的低级特性，如手动内存管理、指针算术和内联汇编代码。"
$nl
"不安全的特性被妥善隐藏，这样你就不会意外调用它们，也不必用它们来解决常规编程问题。然而当需要时，不安全的特性是无价的，例如你在直接与 C 库交互时可能需要做一些指针算术。" ;

ARTICLE: "cookbook-pitfalls" "需要避免的陷阱"
"Factor 是一种非常简洁和一致的语言。然而，它有一些你应当牢记的限制和泄漏抽象，以及一些可能与你熟悉的其他语言不同的行为。"
{ $list
    "Factor 只使用一个本机线程，Factor 线程是协作式调度的。C 库调用会阻塞整个虚拟机。"
    "Factor 不会向程序员隐藏任何东西，所有内部实现都是暴露的。避免编写过于依赖实现细节的脆弱代码是你的责任。"
    { "如果字面量对象出现在词定义中，当该词执行时压入栈的是对象本身，而非副本。如果你打算修改此对象，必须先用 " { $link clone } " 复制它。参见 " { $link "syntax-literals" } "。" }
    { "此外，" { $link dup } " 及相关重排词不会复制整个对象或数组；它们只复制对它们的引用。如果你想保护一个对象不被修改，请使用 " { $link clone } "。" }
    { "关于 " { $link f } " 对象潜在问题的讨论，参见 " { $link "booleans" } "。" }
    { "Factor 的对象系统非常灵活。粗心地使用联合（union）、混入（mixin）和谓词（predicate）类可能导致与其他语言中"多重继承"类似的问题。特别是，可能存在两个类，它们的交集非空，但互不为对方的子类。如果泛型词在两个这样的类上定义了方法，将应用各种消歧规则以确保方法分派仍是确定性的，但结果可能不是你所期望的。详情参见 " { $link "method-order" } "。" }
    { "如果 " { $link run-file } " 抛出栈深度断言错误，这意味着文件中的顶层形式在栈上留下了值。加载源文件前后会比较栈深度，因为这种情况几乎总是一个错误。如果你确实需要加载一个以某种方式返回数据的源文件，请在源文件中定义一个在栈上产生该数据的词，并在加载文件后调用该词。" }
} ;

ARTICLE: "cookbook-next" "后续步骤"
"一旦你通读了 " { $link "first-program" } " 和 " { $link "cookbook" } "，继续学习 Factor 的最佳方式是开始查看一些简单的示例程序。以下是一些特别好的词汇表，可以让你忙上一阵子："
{ $list
    { $vocab-link "base64" }
    { $vocab-link "roman" }
    { $vocab-link "rot13" }
    { $vocab-link "smtp" }
    { $vocab-link "time-server" }
    { $vocab-link "tools.hexdump" }
    { $vocab-link "webapps.counter" }
}
"如果你看到其中有你不懂的代码，使用 " { $link see } " 和 " { $link help } " 来探索。" ;

ARTICLE: "cookbook" "Factor 食谱"
"Factor 食谱是对用 Factor 编程所需的最重要概念的高层次概述。"
{ $subsections
    "cookbook-syntax"
    "cookbook-colon-defs"
    "cookbook-combinators"
    "cookbook-variables"
    "cookbook-vocabs"
    "cookbook-application"
    "cookbook-scripts"
    "cookbook-philosophy"
    "cookbook-pitfalls"
    "cookbook-next"
} ;

ABOUT: "cookbook"
