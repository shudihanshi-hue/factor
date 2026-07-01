! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! Factor 导览（A Guided Tour）— 中文翻译
! 原始文件: D:\factor\basis\help\tour\tour.factor
!
USING: alien.c-types arrays assocs command-line continuations
editors help help.markup help.syntax help.vocabs inspector io
io.directories io.files io.files.types kernel lexer math
math.factorials math.functions math.primes memory namespaces
parser prettyprint ranges see sequences stack-checker strings
threads tools.crossref tools.test tools.time ui.gadgets.panes
ui.tools.deploy vocabs vocabs.loader vocabs.refresh words
io.servers http io.sockets io.launcher channels
concurrency.distributed channels.remote help.cookbook
splitting.private ;
IN: zh.tour

ARTICLE: "tour-concatenative-zh" "连接性语言（Concatenative Languages）"
Factor 是一种秉承 Forth 精神的 { $emphasis "连接性（concatenative）" } 编程语言。什么是连接性语言呢？

要理解连接性编程，请想象一个世界，其中每个值都是一个函数，唯一允许的操作就是函数复合（function composition）。由于函数复合如此普遍，它是隐式的，函数可以并列在一起来复合它们。因此，如果 { $snippet "f" } 和 { $snippet "g" } 是两个函数，它们的复合就只是 { $snippet "f g" } （与数学符号不同，函数从左到右阅读，所以这意味着先执行 { $snippet "f" } ，再执行 { $snippet "g" } ）。

这需要一些解释，因为我们知道函数常常有多个输入和输出，而 { $snippet "f" } 的输出不一定匹配 { $snippet "g" } 的输入。例如，{ $snippet "g" } 可能需要访问由更早的函数计算出的值。但是 { $snippet "g" } 唯一能看到的就是 { $snippet "f" } 的输出，所以 { $snippet "f" } 的输出就是 { $snippet "g" } 所能感知的整个世界状态。为了使这成为可能，函数必须传递全局状态，把它依次交给彼此。

有各种方式可以编码这种全局状态。最原始的方法是使用一个将变量名映射到其值的哈希表。然而这太灵活了：如果每个函数都可以访问任意全局状态，对函数能做什么就没有多少控制，封装性很差，最终程序会变成一堆杂乱的例程（routine）互相修改全局变量。

在实践中，将世界状态表示为一个栈（stack）效果很好。函数只能引用栈的最顶层元素，其下的元素实际上超出了作用域。如果给出少量原语（primitive）来操作栈上的几个元素（例如 { $link swap } 交换栈顶两个元素），则可以引用栈中更深处的值，但值在栈中越深，引用它就越困难。

因此，函数被鼓励保持短小，只引用栈顶两到三个元素。从某种意义上说，局部变量和全局变量之间没有区别，但值可以根据其距离栈顶的远近而具有不同程度的局部性。

请注意，如果每个函数接受整个世界的状态并返回下一个状态，它的输入就再也不会被使用了。因此，尽管将纯函数视为接收一个栈作为输入并输出一个栈是很方便的，但语言的语义可以通过修改单个栈来更高效地实现。
;

ARTICLE: "tour-stack-zh" "玩转栈"

让我们开始感受 Factor 实际是什么样子的。我们最初的几个字将是字面量（literal），如 { $snippet "3" } 、{ $snippet "12.58" } 或
{ $snippet "\"Chuck Norris\"" } 。字面量可以视为将自身压入栈的函数。尝试在监听器中输入 { $snippet "5" } 然后按回车确认。你会看到栈（初始为空）现在看起来像是

{ $code "5" }

你可以输入多个数字，用空格分隔，如 { $snippet "7 3 1" } ，得到

{ $code "5
7
3
1"
}

（界面在底部显示栈顶）。那么操作呢？如果你写 { $snippet "+" } ，你将运行
{ $snippet "+" } 函数，它弹出栈顶两个元素并压入它们的和，留下
{ $code "5
7
4"
}
你可以在一行中放入额外的输入，例如 { $snippet "- *" } 将在栈上留下单个数字 { $snippet "15" } （你明白为什么吗？）。

你可能最终会在栈上压入许多值，或得到不正确的结果。这时你可以使用
组合键 { $snippet "Alt+Shift+K" } （Linux/Windows）或 { $snippet "Cmd+Shift+K" } （macOS）来清空栈。

函数 { $snippet "." } （一个句点或点号）打印栈顶的项，并将其从栈中弹出，使栈为空。

如果我们把所有内容写在一行上，到目前为止我们的程序看起来像

{ $code "5 7 3 1 + - * ." }

这展示了 Factor 做算术的特殊方式——先放参数后放运算符——这种约定被称为逆波兰表示法（Reverse Polish Notation，RPN）。请注意
RPN 不需要括号，不像 Lisp 的波兰表示法（运算符在前），也不像大多数编程语言和日常算术中使用的中缀表示法需要优先级规则。例如在任何 Lisp 中，同样的
计算将写成

{ $code "(* 5 (- 7 (+ 3 1)))" }

而在熟悉的中缀表示法中

{ $code "(7 - (3 + 1)) * 5" }

还要注意，我们可以相当任意地将计算拆分到多行或合并到更少的行，而且每一行本身都有意义。
;

ARTICLE: "tour-first-word-zh" "定义我们的第一个字"

现在我们将定义我们的第一个函数。Factor 对函数的命名有点特别：由于函数从左到右阅读，它们被简单地称为 { $strong "字（words）" } ，从现在开始我们将这样称呼它们。Factor 中的模块根据先前的字来定义字，这些字的集合则被称为 { $strong "词汇表（vocabularies）" } 。

假设我们想计算阶乘。先用一个具体例子，计算 { $snippet "10" } 的阶乘，我们从写 { $snippet "10" } 入栈开始。现在，阶乘是 { $snippet "1" } 到 { $snippet "10" } 的乘积，所以我们应该首先生成这样一组数字。

产生范围的字叫 { $link [a..b] } （Factor 中词法分析很简单，因为字总是由空格分隔，所以你可以使用任何非空白字符的组合作为字名；{ $snippet "[" } 、{ $snippet ".." } 和 { $snippet "]" } 在 { $link [a..b] } 中没有任何语义，因为它只是一个像 { $snippet "foo" } 或 { $snippet "bar" } 一样的记号）。

我们需要的范围从 { $snippet "1" } 开始，所以我们可以使用更简单的字 { $link [1..b] } ，它假定范围从 { $snippet "1" } 开始，只需要栈上有范围的上限值。如果你得到一个
{ $snippet "数据栈下溢（Data stack underflow）" } 错误，这意味着你忘了先在栈上放一个数字作为上限 { $snippet "b" } 。

现在你的栈上应该有一个相当不透明的结构，看起来像

{ $code "T{ range f 1 10 1 }" }

这是因为我们的范围函数是惰性的，只有当我们尝试使用它时才会创建范围。为了确认我们实际创建了从 { $snippet "1" } 到 { $snippet "10" } 的数字列表，我们使用字 { $link >array } 将栈上的惰性响应转换为数组。输入该字，你的栈现在应该看起来像

{ $code "{ 1 2 3 4 5 6 7 8 9 10 }" }

这很有希望！

接下来，我们要计算这些数字的乘积。在许多函数式语言中，这可以通过一个叫做 reduce 或 fold 的函数完成。让我们找一个这样的字。在监听器中按 { $snippet "F1" } 将打开一个上下文帮助系统，你可以在其中搜索 { $link reduce } 。结果发现 { $link reduce } 确实是我们需要的字，但在这一点上，如何使用它可能并不明显。

尝试写 { $snippet "1 [ * ] reduce" } 并查看输出：它确实是 { $snippet "10" } 的阶乘。
现在，{ $link reduce } 通常接受三个参数：一个序列（我们栈上有一个），一个起始值（这是我们接下来放在栈上的 { $snippet "1" } ）和一个二元操作。这肯定是 { $link * } ，但 { $link * } 周围的那些方括号又是什么意思呢？

如果我们只写了 { $link * } ，Factor 会尝试对栈顶两个元素应用乘法，这不是我们想要的。我们需要一种方式将字放到栈上而不应用它。回到我们的文本隐喻，这种机制被称为 { $strong "引用（quotation）" } 。要引用一个或多个字，你只需用
{ $link POSTPONE: [ } 和 { $link POSTPONE: ] } 包围它们（保留空格！）。你得到的是一个匿名函数，可以被传递、操作和调用。

让我们在监听器中输入字 { $link drop } 清空栈，并尝试在一行中写下我们到目前为止所做的一切：{ $snippet "10 [1..b] 1 [ * ] reduce" } 。这将在栈上留下 { $snippet "3628800" } ，正如预期。

我们现在想为阶乘定义一个字，以便在需要阶乘时随时使用。我们称这个字为 { $snippet "fact" }
（虽然 { $snippet "!" } 习惯上用作阶乘符号，但在 Factor 中 { $snippet "!" } 是用于注释的字）。要定义它，我们首先需要使用字 { $link POSTPONE: : } 。然后我们放入被定义字的名称，接着是 { $strong "栈效果（stack effects）" } ，最后是函数体，以 { $link POSTPONE: ; } 字结尾：

{ $code ": fact ( n -- n! ) [1..b] 1 [ * ] reduce ;" }

什么是栈效果？在我们的例子中是 { $snippet "( n -- n! )" } 。栈效果是你用来记录字的栈输入和栈输出的方式。你可以使用任何标识符来命名栈元素，这里我们使用 { $snippet "n" } 。Factor 将执行一致性检查，确保你指定的输入输出数量与函数体所做的一致。

如果你尝试写

{ $code ": fact ( m n -- ..b ) [1..b] 1 [ * ] reduce ;" }

Factor 会报错，指出 2 个输入 { $snippet "m" } 和 { $snippet "n" } 与函数体不一致。要恢复之前正确的定义，按 { $snippet "Ctrl+P" } 两次回到之前的输入，然后输入它。

定义中的栈效果既充当文档工具，也充当非常简单的类型系统，有助于捕获一些错误。

无论如何，你已经成功定义了你的第一个字：如果你在监听器中写 { $snippet "10 fact" } ，你可以验证它。

注意定义中的 { $snippet "1 [ * ] reduce" } 部分本身就有点合理——它是一个序列的乘积。连接性语言的好处是我们可以直接将这部分提取出来，写成

{ $code ": prod ( {x1,...,xn} -- x1*...*xn ) 1 [ * ] reduce ;

: fact ( n -- n! ) [1..b] prod ;" }

我们的定义变得更简单了，而且无需传递参数、重命名局部变量，或做任何在大多数语言中重构函数时需要做的其他事情。

当然，Factor 已经有一个计算阶乘的字（有一整个 { $vocab-link "math.factorials" } 词汇表，包含通常阶乘的许多变体）和一个计算乘积的字（{ $link product } 在 { $vocab-link "sequences" } 词汇表中），但正如常见的情况，入门示例与标准库有重叠。
;

ARTICLE: "tour-parsing-words-zh" "解析字（Parsing Words）"
如果你一直很仔细，你会意识到你被骗了。{ $emphasis "大多数" } 字按顺序在栈上操作，但有一些字如 { $link POSTPONE: [ } 、{ $link POSTPONE: ] } 、{ $link POSTPONE: : } 和 { $link POSTPONE: ; } 似乎不遵循这个规则。

这些是 { $strong "解析字（parsing words）" } ，它们的行为与像 { $snippet "5" } 、{ $link [1..b] } 或 { $link drop } 这样的普通字不同。当我们讨论元编程（metaprogramming）时会更详细地介绍这些，但现在只需要知道解析字是特殊的就够了。

它们不是用 { $link POSTPONE: : } 字定义的，而是用 { $link POSTPONE: SYNTAX: } 字。当遇到一个解析字时，它可以使用一个定义良好的 API 与解析器交互，影响后续字的解析方式。例如，{ $link POSTPONE: : } 向解析器请求后续的记号（token），直到找到 { $link POSTPONE: ; } ，并尝试将该记号流编译为一个字定义。

解析字的一个常见用途是定义字面量。例如，{ $link POSTPONE: { } 是一个开始数组定义的解析字，由 { $link POSTPONE: } } 终止。两者之间的所有内容都是数组的一部分。我们之前看到的一个数组例子是 { $snippet "{ 1 2 3 4 5 6 7 8 9 10 } " } 。

还有哈希表的字面量，{ $snippet "H{ { \"Perl\" \"Larry Wall\" } { \"Factor\" \"Slava Pestov\" } { \"Scala\" \"Martin Odersky\" } } " } ，和字节数组的字面量，{ $snippet "B{ 1 14 18 23 } " } 。

解析字的其他用途包括模块系统、Factor 的面向对象特性、枚举、记忆化函数、隐私修饰符等。理论上，甚至 { $link POSTPONE: SYNTAX: } 也可以用自身来定义，但系统必须以某种方式引导（bootstrap）。

;

ARTICLE: "tour-stack-shuffling-zh" "栈操作（Stack Shuffling）"
现在你知道了 Factor 的基础知识，你可能想要开始组装更复杂的字。这有时可能需要你使用不在栈顶的变量，或多次使用变量。有一些字可以帮助解决这个问题。我现在提到它们，因为你需要知道它们的存在，但我警告你：过多使用这些字来操作栈会导致你的代码很快变得更难读和更难写。栈操作在心里模拟在栈上移动值需要不是一种自然的编程方式。在下一节中，我们将看到一种更有效的方式来处理大多数需求。

以下是最常见的栈操作字及其对栈的效果列表。在监听器中试试它们，感受它们如何操作栈。

{ $subsections
  dup
  drop
  swap
  over
  dupd
  swapd
  nip
  rot
  -rot
  2dup
}

要更深入地了解栈操作，参见 { $link "cookbook-colon-defs-zh" } 。
;

ARTICLE: "tour-combinators-zh" "组合子（Combinators）"

虽然上一节提到的字偶尔有用（尤其是较简单的 { $link dup } 、{ $link drop } 和 { $link swap } ），你应该编写尽可能少做栈操作的代码。这需要练习才能将函数参数放在正确的顺序。然而，有某些常见的需要栈操作的模式，最好将其抽象为专门的词。

假设我们想定义一个字来判断给定数字 { $snippet "n" } 是否是素数。一个简单的算法是测试从 { $snippet "2" } 到 { $snippet "n" } 的平方根之间的每个数字，看它是否是 { $snippet "n" } 的除数。在这种情况下，{ $snippet "n" } 在两个地方被使用：作为序列的上限，以及作为测试可整除性的数字。

字 { $link bi } 将两个不同的引用应用于位于其上方的单个栈元素，这正是我们需要的。例如，{ $snippet "5 [ 2 * ] [ 3 + ] bi" } 产出
{ $code "
10
8
" }

{ $link bi } 将引用 { $snippet "[ 2 * ]" } 应用于值 { $snippet "5" } ，然后将引用 { $snippet "[ 3 + ]" } 应用于值 { $snippet "5" } ，在栈上留下 { $snippet "10" } 然后是 { $snippet "8" } 。如果没有 { $link bi } ，我们将不得不先 { $link dup } { $snippet "5" } ，然后做乘法，然后 { $link swap } 乘法的结果与第二个 { $snippet "5" } ，以便做加法

{ $code "
5 dup 2 * swap 3 +
" }

你可以看到 { $link bi } 取代了一个常见的模式：{ $link dup } ，然后计算，然后 { $link swap } ，再次计算。

继续我们的素数示例，我们需要一种方法来生成从 { $snippet "2" } 开始的范围。我们可以使用 { $link [a..b] } 字为此定义我们自己的字 { $snippet "[2..b]" } ：

{ $code "
: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline
" }

那个 { $snippet "inline" } 字是什么意思？这是我们在定义字之后可以使用的修饰符之一，另一个是 { $snippet "recursive" } 。这将允许短字的定义在使用处被内联（inline），而不是产生函数调用。

试试我们的新字 { $snippet "[2..b]" } ，看看它是否有效：

{ $code "
6 [2..b] >array .
" }

使用 { $snippet "[2..b]" } 产生从 { $snippet "2" } 到已经在栈上的 { $snippet "n" } 的平方根的数字范围很容易：{ $snippet "sqrt floor [2..b]" } （技术上这里不需要 { $link floor } ，因为 { $link [a..b] } 对非整数边界也有效）。让我们试试：

{ $code "
16 sqrt [2..b] >array .
" }

现在，我们需要一个测试可整除性的字。在在线帮助中快速搜索显示 { $link divisor? } 正是我们需要的字。这样让可整除性测试的参数按另一个方向排列会更方便，所以我们定义 { $snippet "multiple?" } ：

{ $code "
: multiple? ( a b -- ? ) swap divisor? ; inline
" }

我们可以验证这两个字都返回 { $link t } 。

{ $code "
9 3 divisor? .
3 9 multiple? .
" }

由于我们将在 { $snippet "prime?" } 定义中使用 { $link bi } ，我们需要第二个引用。我们的第二个引用需要测试范围中的值是否是 { $snippet "n" } 的除数——换句话说，我们需要部分应用（partially apply）字 { $snippet "multiple?" } 。这可以用字 { $link curry } 完成，像这样：{ $snippet "[ multiple? ] curry" } 。

最后，一旦我们有了潜在除数的范围和栈上的测试函数，我们就可以用 { $link any? } 测试是否有任何元素满足可整除条件，然后用 { $link not } 取反。我们 { $snippet "prime" } 的完整定义看起来像

{ $code "
: prime? ( n -- ? )
    [ sqrt [2..b] ] [ [ multiple? ] curry ] bi any? not ;
" }

尽管 { $snippet "prime" } 的定义很复杂，但栈操作是最少的，只在小的辅助函数中使用，这些函数比 { $snippet "prime?" } 更容易推理。

注意 { $snippet "prime?" } 使用了两个层级的引用嵌套，因为 { $link bi } 在两个引用上操作，而我们的第二个引用包含字 { $link curry } ，它也在一个引用上操作。一般来说，Factor 的字趋向于相当浅，对每个高阶函数使用一层嵌套，不像 Lisp 或更一般地基于 lambda 演算的语言，它们对每个函数（无论高阶与否）都使用一层嵌套。

{ $link bi } 及其亲戚 { $link tri } 是你在 Factor 中会使用的栈操作字的一小部分。你还应该熟悉 { $link bi } 、{ $link tri } 和 { $link bi@ } ，通过在线帮助阅读它们并在监听器中试用。

;

ARTICLE: "tour-vocabularies-zh" "词汇表（Vocabularies）"

现在是将你的函数写入文件并学习如何在监听器中导入它们的时候了。Factor 将字组织成称为 { $strong "词汇表（vocabularies）" } 的嵌套命名空间。你可以用字 { $link POSTPONE: USE: } 导入一个词汇表中的所有名称。实际上，你可能已经看到过类似

{ $code "USE: ranges" }

的东西，当你要求监听器为你导入字 { $link [1..b] } 时。你也可以使用字 { $link  POSTPONE: USING: } 一次使用多个词汇表，它后面跟着一个词汇表列表，由 { $link POSTPONE: ; } 终止，像这样

{ $code "USING: ranges sequences ;" }

最后，你使用字 { $link POSTPONE: IN: } 定义你的定义所在的词汇表。如果你在在线帮助中搜索你到目前为止定义的某个字，如 { $link prime? } ，你会看到你的定义已被归入默认的 { $vocab-link "scratchpad" } 词汇表之下。顺便说一句，这表明在线帮助会自动收集关于你自已的字的 信息，这是一个非常有用的特性。

还有几个字，如 { $link POSTPONE: QUALIFIED: } 、{ $link POSTPONE: FROM: } 、{ $link POSTPONE: EXCLUDE: } 和 { $link POSTPONE: RENAME: } ，允许对导入进行更细粒度的控制，但 { $link POSTPONE: USING: } 是最常见的。

在磁盘上，词汇表存储在一些根目录下，很像 JVM 语言中的类路径（classpath）。默认情况下，系统在 Factor 主目录下的 { $snippet "basis" } 、{ $snippet "core" } 、{ $snippet "extra" } 、{ $snippet "work" } 目录中开始搜索。你可以添加更多，既可以运行时用字 { $link add-vocab-root } ，也可以通过创建配置文件 { $snippet ".factor-rc" } ，但现在我们将词汇表存储在 { $snippet "work" } 目录下，该目录是保留给用户的。

写以下命令生成一个词汇表模板

{ $code "USE: tools.scaffold
\"github.tutorial\" scaffold-work" }

你会发现一个文件 { $snippet "work/github/tutorial/tutorial.factor" } 包含一个空的词汇表。Factor 集成了许多编辑器，所以你可以尝试 { $snippet "\"github.tutorial\" edit" } ：这将提示你选择喜欢的编辑器，并使用该编辑器打开新创建的词汇表。

你可以添加上一节的各定义，使其如下所示

{ $code "
! Copyright (C) 2026 您的名字.
! See https://factorcode.org/license.txt for BSD license.
USING: ;
IN: github.tutorial

: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline

: multiple? ( a b -- ? ) swap divisor? ; inline

: prime? ( n -- ? )
    [ sqrt [2..b] ] [ [ multiple? ] curry ] bi any? not ;
" }

由于在你使用脚手架创建词汇表时它已经被加载了，我们需要一种方法从磁盘刷新它。你可以用 { $snippet "\"github.tutorial\" refresh" } 做到这一点。还有一个 { $link refresh-all } 字，快捷键 { $snippet "F2" } 。

系统会提示你几次要使用哪些词汇表，因为你的 { $link POSTPONE: USING: } 语句是空的。接受所有这些后，Factor 会建议你一个新的带有所有所需导入的头：

{ $code "
USING: kernel math.functions ranges sequences ;
IN: github.tutorial
" }

现在你的词汇表中有了些字，你可以编辑（比如）{ $snippet "multiple?" } 字，使用 { $snippet "\\ multiple? edit" } 。你会发现编辑器在你打开的正确文件的对应行。这也适用于 Factor 发行版中的字，不过修改它们可能是个坏主意。

这个 { $link POSTPONE: \ } 字需要一点解释。它的工作方式类似一种转义（escape），允许我们将下一个字的引用放到栈上，而不执行它。这正是我们需要的，因为 { $link edit } 是一个接受字本身作为参数的字。这种机制类似于引用（quotation），但引用会创建一个新的匿名函数，而这里我们是直接引用字 { $snippet "multiple?" } 。

回到我们的任务，你可能注意到字 { $snippet "[2..b]" } 和 { $snippet "multiple?" } 只是你不想直接暴露的辅助函数。要隐藏它们，你可以将它们包裹在一个私有块中，像这样

{ $code "
<PRIVATE

: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline

: multiple? ( a b -- ? ) swap divisor? ; inline

PRIVATE>
" }

做出此更改并刷新词汇表后，你会看到监听器不再能引用像 { $snippet "[2..b]" } 这样的字了。{ $link POSTPONE: <PRIVATE } 字的工作原理是将私有块中的所有定义放在一个不同的词汇表下，在我们的例子中是 { $snippet "github.tutorial.private" } 。

你可以在一个词汇表中使用多个 { $link POSTPONE: <PRIVATE } 块，可以根据需要自由组织它们。

仍然可以通过在浏览器中搜索 { $snippet "[2..b]" } 来引用私有词汇表中的字，但这当然是不鼓励的，因为人们不对私有字的 API 稳定性做出任何保证。{ $snippet "github.tutorial" } 下的字可以直接引用 { $snippet "github.tutorial.private" } 中的字，就像 { $link prime? } 所做的那样。

;

ARTICLE: "tour-tests-docs-zh" "测试与文档"

现在是开始编写单元测试的好时机。你可以用以下命令创建一个骨架：
{ $code "
\"github.tutorial\" scaffold-tests
" }
你会在 { $snippet "work/github/tutorial/tutorial-tests.factor" } 下找到一个生成的文件，可以用 { $snippet "\"github.tutorial\" edit-tests" } 打开它。注意这一行

{ $code "
USING: tools.test github.tutorial ;
" }
它导入了单元测试模块以及你自己的模块。我们将只测试公共的 { $snippet "prime?" } 函数。

测试使用 { $link POSTPONE: unit-test } 字编写，它期望两个引用（quotation）：第一个包含期望的输出，第二个包含为获得该输出而需要运行的字。将这些行添加到 { $snippet "github.tutorial-tests" } 中：

{ $code "
{ t } [ 2 prime? ] unit-test
{ t } [ 13 prime? ] unit-test
{ t } [ 29 prime? ] unit-test
{ f } [ 15 prime? ] unit-test
{ f } [ 377 prime? ] unit-test
{ f } [ 1 prime? ] unit-test
{ t } [ 20750750228539 prime? ] unit-test
" }

你现在可以用 { $snippet "\"github.tutorial\" test" } 运行测试。你会看到我们实际上犯了一个错误，按 { $snippet "F3" } 将显示更多细节。看起来我们的断言对 { $snippet "2" } 失败了。

事实上，如果你手动尝试对 { $snippet "2" } 运行我们的函数，你会看到我们对 { $snippet "2 sqrt" } 定义的 { $snippet "[2..b]" } 返回 { $snippet "{ 2 }" } ，因为 2 的平方根小于 2，所以我们得到了一个递减区间。尝试修复它，使测试通过。

还有一些其他的字可以用于测试错误和栈效果的推断。现在使用 { $link POSTPONE: unit-test } 就足够了，但以后你可能想查看 { $link "tools.test" } 的主要文档。

我们还可以为词汇表添加一些文档。自动生成的文档对于用户定义的字始终可用（即使在监听器中也是如此），但我们也可以手动编写一些有用的注释，甚至添加将出现在在线帮助中的自定义文章。不出所料，我们从 { $snippet "\"github.tutorial\" scaffold-docs" } 和 { $snippet "\"github.tutorial\" edit-docs" } 开始。

生成的文件 { $snippet "work/github/tutorial-docs.factor" } 导入了 { $vocab-link "help.markup" } 和 { $vocab-link "help.syntax" } 。这两个词汇表定义了生成文档的字。实际的帮助页面由 { $link POSTPONE: HELP: } 解析字生成。

{ $link POSTPONE: HELP: } 的参数是形如 { $snippet "{ $directive content... }" } 的嵌套数组。特别是，你在这里看到了指令 { $link $values } 和 { $link $description } ，但还有更多，如 { $link $errors } 、{ $link $examples } 和 { $link $see-also } 。

注意输出 { $snippet "?" } 的类型已被推断为 boolean。将前几行改为如下所示

{ $code "
USING: help.markup help.syntax kernel math ;
IN: github.tutorial

HELP: prime?
{ $values
    { \"n\" fixnum }
    { \"?\" boolean }
}
{ $description \"测试 n 是否为素数。n 假定为正整数。\" } ;
" }

并刷新 { $snippet "github.tutorial" } 词汇表。如果你现在查看 { $snippet "prime?" } 的帮助，例如用 { $snippet "\\ prime? help" } ，你将看到更新后的文档。

你也可以在监听器中渲染指令以获得更快的反馈。例如，尝试写

{ $code "
{ $values
    { \"n\" integer }
    { \"?\" boolean }
} print-content
" }

帮助标记包含很多可能的指令，你可以使用它们来在帮助系统中编写独立的文章。通过 { $snippet "\"element-types\" help" } 查看更多。
;

ARTICLE: "tour-objects-zh" "对象系统"

虽然从我们目前为止所说的来看并不明显，但 Factor 有面向对象的特性，许多核心字实际上是方法调用。为了更好地理解对象在 Factor 中的行为，下面引用一句话：
$nl
{ $emphasis "\"我发明了'面向对象'这个术语，我可以告诉你，我当时想到的不是 C++。\"
  — Alan Kay" }
$nl
面向对象这个术语有多少人使用，就有多少种不同的含义。一种观点——实际上是 Alan Kay 工作的核心——是关于函数名的晚期绑定（late binding）。在 Smalltalk——这个概念诞生的语言中，人们不谈"调用方法"，而是谈"向对象发送消息"。由对象决定如何响应这个消息，调用者不应该知道实现细节。例如，可以既向数组也向向量发送 { $link map } 消息，但内部处理方式会不同。

消息名到方法实现的绑定是动态的，这被视为对象的核心优势。因此，相当复杂的系统可以从彼此不干涉内部实现的独立对象的协作中演化而来。

公平地说，Factor 与 Smalltalk 非常不同，但仍然有类的概念，泛型字（generic words）可以定义为在不同类上有不同的实现。

有些类是 Factor 内建的，如 { $link string } 、{ $link boolean } 、{ $link fixnum } 或 { $link word } 。接下来，定义类的最常见方式是作为一个 { $strong "元组（tuple）" } 。元组使用 { $link POSTPONE: TUPLE: } 解析字定义，后面跟着元组名称和我们想要定义的类的字段，在 Factor 用语中称为 { $strong "槽（slots）" } 。

让我们为电影定义一个类：

{ $code "
TUPLE: movie title director actors ;
" }

这还会生成设置器（setter） { $snippet ">>title" } 、{ $snippet ">>director" } 和 { $snippet ">>actors" } ，以及获取器（getter） { $snippet "title>>" } 、{ $snippet "director>>" } 和 { $snippet "actors>>" } 。例如，我们可以用以下方式创建一个新电影

{ $code "
movie new
    \"The prestige\" >>title
    \"Christopher Nolan\" >>director
    { \"Hugh Jackman\" \"Christian Bale\" \"Scarlett Johansson\" } >>actors
" }

我们也可以将其缩短为

{ $code "
\"The prestige\" \"Christopher Nolan\"
{ \"Hugh Jackman\" \"Christian Bale\" \"Scarlett Johansson\" }
movie boa
" }

字 { $link boa } 代表"按参数顺序构造（by-order-of-arguments）"。这是一个构造器，按顺序用栈上的项目填充元组的槽。{ $snippet "movie boa" } 被称为 { $strong "boa 构造器" } ，这是对蟒蛇（Boa Constrictor）的双关语。习惯上定义一个最常用的构造器叫 { $snippet "<movie>" } ，在我们的例子中可以是简单的

{ $code "
: <movie> ( title director actors -- movie ) movie boa ;
" }
实际上，boa 构造器非常常见，上面这行可以缩短为

{ $code "
C: <movie> movie
" }

在其他情况下，你可能想要使用一些默认值，或计算一些字段。

函数式思维的人会担心元组的可变性。实际上，槽可以被声明为"只读"，使用 { $snippet "{ slot-name read-only } " } 。在这种情况下，字段设置器将不会被生成，值必须在开始时用 boa 构造器设置。其他有效的槽修饰符是 { $link POSTPONE: initial: } ——声明一个默认值——以及一个类字如 { $snippet "integer" } ，用于限制可以插入的值。

作为一个例子，我们为摇滚乐队定义另一个元组类

{ $code "
TUPLE: band
    { keyboards string read-only }
    { guitar string read-only }
    { bass string read-only }
    { drums string read-only } ;

: <band> ( keyboards guitar bass drums -- band ) band boa ;
" }

以及一个实例

{ $code "
\"Richard Wright\" \"David Gilmour\" \"Roger Waters\" \"Nick Mason\" <band>
" }

现在，当然每个人都知道电影中的明星是第一演员，而在摇滚乐队中是贝斯手。为了编码这一点，我们首先定义一个 { $strong "泛型字（generic word）" }

{ $code "
GENERIC: star ( item -- star )
" }

如你所见，它用解析字 { $link POSTPONE: GENERIC: } 声明，并声明其栈效果，但目前没有实现，因此不需要结束的 { $link POSTPONE: ; } 。泛型字用于执行动态分派。我们可以使用字 { $link POSTPONE: M: } 为各种类定义实现

{ $code "
M: movie star actors>> first ;

M: band star bass>> ;
" }

如果你写两次 { $snippet "star ." } ，你可以看到在调用泛型字时对不同类的实例产生的不同效果。

内建类和元组类并不是对象系统的全部：更多类可以通过集合操作定义，如 { $link POSTPONE: UNION: } 和 { $link POSTPONE: INTERSECTION: } 。另一种定义类的方式是作为 { $strong "混入（mixin）" } 。

混入使用 { $link POSTPONE: MIXIN: } 字定义，已有类可以被添加到混入中，如下所示：

{ $code "
INSTANCE: class mixin
" }

定义在混入上的方法将可用于属于该混入的所有类。如果你熟悉 Haskell 的类型类（typeclass），你会认识到相似之处，尽管 Haskell 在编译时强制类型类的实例实现某些函数，而在 Factor 中，这在文档中非正式地规定。

混入的两个重要例子是 { $link sequence } 和 { $link assoc } 。前者定义了可用于所有具体序列的协议，如字符串、链表或数组，而后者定义了可用于关联数组的协议，如哈希表或关联列表。

这使得 Factor 中的所有序列都可以用一组通用的字来操作，同时在实现上有所不同并最小化代码重复（因为只需要几个原语，其他操作都是为 { $link sequence } 类定义的）。你将在序列上使用的最常见操作是 { $link map } 、{ $link filter } 和 { $link reduce } ，但还有许多更多——正如你可以通过 { $snippet "\"sequences\" help" } 看到的。
;

ARTICLE: "tour-tools-zh" "学习工具"

Factor 生产力的很大一部分来自语言和库与围绕它们的工具的深度集成，这些工具体现在监听器（listener）中。监听器的许多功能可以通过编程方式使用，反之亦然。你已经看到了一些例子：

{ $list
  { "帮助系统可以在线导航，但你也可以用 " { $link help } " 调用它，并用 " { $link print-content } " 打印帮助项目；" }
  { "快捷键 " { $snippet "F2" } " 或字 " { $link refresh } " 和 " { $link refresh-all } " 可以用于从磁盘刷新词汇表，同时继续在监听器中工作；" }
  { "" { $link edit } " 字为你提供编辑器集成，但你也可以点击帮助页面中词汇表的文件名来打开它们。" }
}

刷新是一种高效的机制。每当一个字被重新定义，依赖它的字都会根据新定义重新编译。你可以自己检查，执行

{ $code "
: inc ( x -- y ) 1 + ;
: inc-print ( x -- ) inc . ;

5 inc-print
" }

然后

{ $code "
: inc ( x -- y ) 2 + ;

5 inc-print
" }

这允许你保持监听器打开，改进你的定义，定期将定义保存到文件并刷新以查看更改，而无需重新加载 Factor。

你也可以用 { $link save-image } 字保存当前会话的状态，稍后通过用以下命令启动 Factor 来恢复它

{ $code "
./factor -i=path-to-image
" }

实际上，Factor 是基于映像（image）的，仅在加载和刷新词汇表时使用文件。

监听器的能力不止于此。栈上的元素可以通过点击它们来检查，或通过调用 { $link inspector } 字来检查。例如尝试写

{ $code "
TUPLE: trilogy first second third ;

: <trilogy> ( first second third -- trilogy ) trilogy boa ;

\"A new hope\" \"The Empire strikes back\" \"Return of the Jedi\" <trilogy>
\"George Lucas\" 2array
" }

你将在栈上得到一个看起来像

{ $code "
{ ~trilogy~ \"George Lucas\" }
" }

的项目。尝试点击它：你将能够看到数组的槽（slot）。你可以通过双击检查器中显示的某个槽来检查它。这在交互式原型设计中非常有用。特殊对象可以通过实现 { $link content-gadget } 方法来自定义检查器。

还有一个用于错误的检查器。每当错误出现时，可以用 { $snippet "F3" } 检查它。这允许你调查异常、错误的栈效果声明等等。调试器允许你单步执行代码，既可以向前也可以向后，你应该花些时间熟悉它。你也可以通过手动触发调试器，在监听器中输入一些代码然后按 { $snippet "Ctrl+w" } 。

监听器提供了用于基准测试代码的功能。作为一个例子，这里是一个故意低效的斐波那契实现：

{ $code "
DEFER: fib-rec
: fib ( n -- f(n) ) dup 2 < [ ] [ fib-rec ] if ;
: fib-rec ( n -- f(n) ) [ 1 - fib ] [ 2 - fib ] bi + ;
" }

（注意使用 { $link POSTPONE: DEFER: } 来定义两个相互"递归"的字）。你可以通过写 { $snippet "40 fib" } 然后按 Ctrl+t（而不是 Enter）来对运行时间进行基准测试。你将获得计时信息以及其他统计信息。编程方式下，你可以在引用上使用 { $link time } 字来达到同样的效果。

你也可以在字上添加观察器，在进入和退出时打印输入和输出。尝试写

{ $code "
\\ fib watch
" }

然后运行 { $snippet "10 fib" } 看看会发生什么。然后你可以用 { $snippet "\\ fib reset" } 移除观察器。

另一个有用的工具是 { $vocab-link "lint" } 词汇表。它扫描字定义以找出可以提取的重复代码。作为例子，让我们定义一个检查字符串是否以另一个字符串开头的字。创建一个测试词汇表

{ $code "
\"lintme\" scaffold-work
" }

并添加以下定义：

{ $code "
USING: kernel sequences ;
IN: lintme

: startswith? ( str sub -- ? ) dup length swapd head = ;
" }

用 { $snippet "USE: lint" } 加载 lint 工具，然后写 { $snippet "\"lintme\" lint-vocab" } 。你将得到一个报告，提到字序列 { $snippet "length swapd" } 已经在 { $vocab-link "splitting.private" } 的字 { $link (split) } 中使用了，因此它可以被提取出来。

修改标准库中字的源代码是不可取的——更不用说是私有的——但在更复杂的情况下，lint 工具可以帮助你防止代码重复。Factor 拥有一个恰好做你想要的事情的字并不罕见，这要归功于其庞大的标准库。定期对你的词汇表进行 lint 处理是个好主意，以避免代码重复，同时也是发现你可能意外重新定义的库字的好方法。

最后，还有一些用于检查字的实用工具。你可以在帮助工具中查看字的定义，但更快的方式可以是 { $link see } 。或者相反，你可以使用 { $link usage. } 来检查给定字的调用者。尝试 { $snippet "\\ reverse see" } 和 { $snippet "\\ reverse usage." } 。
;

ARTICLE: "tour-metaprogramming-zh" "元编程"

我们现在进入元编程的世界，编写我们的第一个解析字（parsing word）。到目前为止，你已经看到很多解析字，如 { $link POSTPONE: [ } 、{ $link POSTPONE: { } 、{ $link POSTPONE: H{ } 、{ $link POSTPONE: USE: } 、{ $link POSTPONE: IN: } 、{ $link POSTPONE: <PRIVATE } 、{ $link POSTPONE: GENERIC: } 等等。它们中的每一个都是用解析字 { $link POSTPONE: SYNTAX: } 定义的，并与 Factor 的解析器交互。

解析器将记号（token）累积到一个累加器向量中，除非它遇到一个解析字，解析字会被立即执行。由于解析字在编译时执行，它们不能与栈交互，但它们可以访问累加器向量。它们的栈效果必须是 { $snippet "( accum -- accum )" } 。通常它们所做的是向解析器请求更多记号，对它们做一些处理，最后用 { $snippet "suffix!" } 字将一个结果压入累加器向量。

作为一个例子，我们将为 DNA 序列定义一个字面量。DNA 序列是四种碱基——胞嘧啶（cytosine）、鸟嘌呤（guanine）、腺嘌呤（adenine）和胸腺嘧啶（thymine）——的序列，我们将用字母 c、g、a、t 表示。因为有四种可能的碱基，我们可以用两个比特编码每个碱基。让我们定义一个操作字符的字：

{ $code "
: dna>bits ( token -- bits ) {
    { CHAR: a [ { f f } ] }
    { CHAR: c [ { t t } ] }
    { CHAR: g [ { f t } ] }
    { CHAR: t [ { t f } ] }
} case ;
" }

其中第一个比特表示该碱基是否为嘌呤（purine）或嘧啶（pyrimidine），第二个比特标识配对在一起的碱基。

我们的目标是读取一个由字母 a、c、g、t 组成的序列——可能包含空格——并将它们转换为位数组。Factor 支持位数组，字面量位数组看起来像 { $snippet "?{ f f t }" } 。

我们的 DNA 语法将以 { $snippet "DNA{" } 开始，并获取所有记号直到找到闭合记号 { $snippet "}" } 。中间的记号将被放入一个字符串中，使用我们的函数 { $snippet "dna>bits" } 我们将这个字符串映射为位数组。为了读取记号，我们将使用字 { $link parse-tokens } 。有一些更高层的字可以与解析器交互，如 { $link parse-until } 和 { $link parse-literal } ，但在我们的情况下不能应用它们，因为我们找到的记号只是 a、c、g、t 的序列，而不是有效的 Factor 字。让我们从一个简单的近似开始，它只读取分隔符之间的记号并输出由连接得到的字符串

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat suffix! ;
" }

你可以通过执行 { $snippet "DNA{ a ccg t a g }" } 来测试效果，它应该输出 { $snippet "\"accgtag\"" } 。作为第二个近似，我们将每个字母转换为一个布尔对：

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat
    [ dna>bits ] { } map-as suffix! ;
" }

注意使用 { $link map-as } 而不是 { $link map } 。由于目标集合不是字符串，我们没有使用 { $link map } （它保留类型），而是使用 { $link map-as } ，它接受目标集合的示例作为附加参数——这里是 { $snippet "{ }" } 。我们的"最终"版本用 { $link concat } 展平对数组，最后做成位数组：

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat
    [ dna>bits ] { } map-as
    concat >bit-array suffix! ;
" }

如果你用 { $snippet "DNA{ a ccg t a g }" } 尝试，你应该得到

{ $code "
{ $snippet \"?{ f f t t t t f t t f f f f t }\" }
" }

让我们尝试一个来自 { $url "https://re.factorcode.org/2014/06/swift-ranges.html" "Re: Factor" } 博客的例子，它为范围添加了中缀语法。到目前为止，我们使用 { $link [a..b] } 来创建范围。我们可以使用 { $snippet "..." } 作为中缀字，为来自其他语言的人提供更友好的语法。

我们可以使用 { $link scan-object } 向解析器请求下一个已解析的对象，以及 { $link unclip-last } 从累加器向量中获取顶部元素。这样，我们可以简单地用以下方式定义 { $snippet "..." }

{ $code "
SYNTAX: ... unclip-last scan-object [a..b] suffix! ;
" }

你可以用 { $snippet "12 ... 18 >array" } 来尝试它。

我们只是触及了解析字的表面；一般来说，它们允许你在编译时执行任意计算，实现强大的元编程形式。

从某种意义上说，Factor 的语法是完全扁平的，解析字允许你引入比记号流更复杂的语法，以供局部使用。这让任何程序员都可以通过在库中添加这些语法特性来扩展语言。原则上，甚至可以让一个外部语言编译成 Factor——比如 JavaScript——并将其作为一种领域特定语言嵌入在 { $snippet "<JS ... JS>" } 解析字的边界内。需要一些品味，不要过度滥用这一点来引入在连接性世界（concatenative world）中过于格格不入的风格。
;

ARTICLE: "tour-stack-ne-zh" "当栈不够用时"

直到现在我们有点作弊了，尽量避免写那些在连接性风格（concatenative style）中过于复杂的例子。事实是，你 { $emphasis "会" } 发现有些场合这种限制太强了。解析字（parsing words）可以缓解其中一些限制，Factor 提供了一些解析字来处理最常见的烦恼。

你可能想做的一件事是实际命名局部变量。{ $link POSTPONE: :: } 字的工作方式类似于 { $link POSTPONE: : } ，但允许你将栈参数的名称实际绑定到变量上，这样你就可以多次使用它们，按你想要的顺序。例如，让我们定义一个解二次方程的字。我将省去纯基于栈的版本，呈现一个使用局部变量（locals）的版本（这将需要 { $vocab-link "locals" } 词汇表）：

{ $code "
:: solveq ( a b c -- x )
    b neg
    b b * 4 a c * * - sqrt
    +
    2 a * / ;" }

在这个例子中我们选择了 + 符号，但我们可以做得更好，输出两个解：

{ $code "
:: solveq ( a b c -- x1 x2 )
    b neg
    b b * 4 a c * * - sqrt
    [ + ] [ - ] 2bi
    [ 2 a * / ] bi@ ;" }

你可以用类似 { $snippet "2 -16 30 solveq" } 的输入来检查这个定义是否有效，它应该同时输出 { $snippet "3.0" } 和 { $snippet "5.0" } 。除了以 RPN 风格书写之外，我们的第一个版本的 { $snippet "solveq" } 看起来与具有局部变量的语言中的写法完全一样。对于第二个定义，我们使用组合子 { $link 2bi } 将 { $link + } 和 { $link - } 操作同时应用于 -b 和 delta，然后使用 { $link bi@ } 将两个结果都除以 2a。

引用中也有局部变量的支持——使用 { $link POSTPONE: [| } ——以及方法中——使用 { $link POSTPONE: M:: } ——而且还可以使用 { $link POSTPONE: [let } 在定义之外创建一个绑定局部变量的作用域。当然，所有这些实际都会被编译为带有栈操作的连接性代码。我鼓励你浏览这些字的示例，但要记住，它们在实践中的使用实际上远不如人们想象的那么突出——约占 Factor 自身代码库的 1%。

另一种常见情况是当你需要将值添加到引用的特定位置时。你可以使用 { $link curry } 部分应用一个引用。这假设你应用的值应该出现在引用的最左端；在其他情况下你需要一些栈操作。字 { $link with } 是一种带有"洞"的部分应用。它也柯里化（curry）一个引用，但使用栈上第三个元素而不是第二个。而且，生成的被柯里化的引用将被应用于一个元素，将其插入到第二个位置。

文档中的例子可能比上面的句子更具说明力——尝试写：

{ $code "1 { 1 2 3 } [ / ] with map" }

让我再次以 { $snippet "prime?" } 为例，但这次不使用辅助字来写：

{ $code "
: prime? ( n -- ? )
    [ sqrt 2 swap [a,b] ] [ [ swap divisor? ] curry ] bi any? not ;" }

使用 { $link with } 而不是 { $link curry } ，这简化为

{ $code "
: prime? ( n -- ? )
    2 over sqrt [a,b] [ divisor? ] with any? not ;" }

如果你无法想象发生了什么，你可能想考虑 { $vocab-link "fry" } 词汇表。它定义了 { $strong "油炸引用（fried quotations）" } ；这些是有"洞"的引用——由 { $snippet "_" } 标记——用栈上的值填充。

第一个引用更简单地重写为

{ $code "
[ '[ 2 _ sqrt [a,b] ] call ]
" }

这里我们使用一个油炸引用——以 { $link POSTPONE: '[ } 开头——将栈顶元素注入到第二个位置，然后使用 { $link call } 求值生成的引用。第二个引用可以如下重写：

{ $code "
[ '[ _ swap divisor? ] ]
" }

所以 { $snippet "prime?" } 的另一种定义是

{ $code "
: prime? ( n -- ? )
    [ '[ 2 _ sqrt [a,b] ] call ] [ '[ _ swap divisor? ] ] bi any? not ;
" }

根据你的品味，你可能会觉得这个版本更可读。在这种情况下，由于油炸引用本身就在引用内部，增加的清晰度可能会丧失，但偶尔使用它们可以大大简化流程。

最后，有些时候人们只想给在某个作用域内可用的变量起个名字，并在需要的地方使用它们。这些变量可以保存全局的值，或者至少不是局限于单个字的值。一个典型的例子可能是输入和输出流，或数据库连接。

为此，Factor 允许你创建 { $strong "动态变量（dynamic variables）" } 并在作用域中绑定它们。第一件事是为变量创建一个 { $strong "符号（symbol）" } ，比如

{ $code "SYMBOL: favorite-language" }
然后可以使用字 { $link set } 绑定变量和 { $link get } 获取其值，如

{ $code "\"Factor\" favorite-language set
favorite-language get" }

作用域是嵌套的，新的作用域可以用 { $link with-scope } 字创建。例如尝试

{ $code "
: on-the-jvm ( -- )
    [
        \"Scala\" favorite-language set
        favorite-language get .
    ] with-scope ;" }

如果你运行 { $snippet "on-the-jvm" } ，将打印 { $snippet "\"Scala\"" } ，但在执行之后，{ $snippet "favorite-language get" } 将保留 { $snippet "\"Factor\"" } 作为其值。

我们在本节中看到的所有工具只应在绝对必要时使用，因为它们破坏了连接性（concatenativity），使字更难分解（factor）。然而，在需要时它们可以大大增加清晰度。Factor 有一种非常务实的方法，不羞于提供不那么纯粹但仍然经常有用的特性。
;

ARTICLE: "tour-io-zh" "输入/输出"

我们现在将离开语言之旅，开始研究如何用 Factor 探索外部世界。本节将从基本的输入和输出开始，然后转向异步、并行和分布式 I/O。

Factor 实现了高效的异步输入/输出设施，类似于 JVM 上的 NIO 或 Node.js 的 I/O 系统。这意味着输入和输出操作在后台执行，让前台任务在磁盘旋转或网络缓冲数据包时自由地执行工作。Factor 目前是单线程的，但异步性使其对于 I/O 密集型应用程序相当高性能。

Factor 所有的输入/输出字都围绕 { $strong "流（streams）" } 展开。流是可以被读取或写入的惰性序列，典型的例子是文件、网络端口或标准输入和输出。Factor 持有几个称为 { $link input-stream } 和 { $link output-stream } 的动态变量，它们被大多数 I/O 字使用。这些变量可以使用 { $link with-input-stream } 、{ $link with-output-stream } 和 { $link with-streams } 在局部重新绑定。当你在监听器中时，默认的流在监听器中写入和读取，但一旦你将应用程序部署为可执行文件，它们通常绑定到控制台的标准输入和输出。

字 { $link <file-reader> } 和 { $link <file-writer> } （或 { $link <file-appender> } ）可以用于创建文件读写流，给定其路径和编码。将一切结合起来，我们制作一个简单的例子，一个字读取 UTF8 编码文件的每一行，并将该行的第一个字母写入监听器。

首先，我们需要一个 { $snippet "safe-head" } 字，它的工作方式类似于 { $link head } ，但如果序列太短则返回其输入。为此，我们将使用字 { $link recover } ，它允许我们声明一个 try-catch 块。它需要两个引用：第一个被执行，在失败时，第二个以错误为输入被执行。因此我们可以定义

{ $code "
: safe-head ( seq n -- seq' ) [ head ] [ 2drop ] recover ;" }

这是一个不切实际的异常示例，因为 Factor 定义了 { $link index-or-length } 字，它接受一个序列和一个数字，并返回序列长度与数字之间的最小值。这允许我们简单地写

{ $code "
: safe-head ( seq n -- seq' ) index-or-length head ;" }

有了这个定义，我们可以创建一个读取第一行第一个字符的字：

{ $code "
: read-first-letters ( path -- )
    utf8 <file-reader> [
        readln 1 safe-head print
    ] with-input-stream ;" }

使用辅助字 { $link with-file-reader } ，我们也可以将其缩短为

{ $code "
: read-first-letters ( path -- )
    utf8 [
        readln 1 safe-head print
    ] with-file-reader ;" }

不幸的是，我们局限在一行。要读取更多行，我们应该链接对 { $link readln } 的调用，直到一个调用返回 { $link f } 。Factor 以 { $link file-lines } 帮助我们，它惰性地迭代行。我们的"最终"定义变为

{ $code "
: read-first-letters ( path -- )
    utf8 file-lines [ 1 safe-head print ] each ;" }

当文件很小时，也可以使用 { $link file-contents } 将文件的全部内容读入单个字符串中。Factor 为输入/输出定义了更多的字，涵盖了更多的场景，如二进制文件或套接字。

我们将以调查一些遍历文件系统的字来结束本节。我们的目标是 { $snippet "ls" } 命令的一个非常简化的实现。

字 { $link directory-entries } 列出一个目录的内容，给出一个元组元素的列表，每个元素有槽 { $snippet "name" } 和 { $snippet "type" } 。你可以通过尝试以下内容看到这一点

{ $code "\"/home\" directory-entries [ name>> ] map" }
如果你检查目录条目，你会看到类型要么是 { $link +directory+ } 要么是 { $link +regular-file+ } （嗯，还有符号链接，但为了简单我们将忽略它们）。因此我们可以定义一个列出文件和目录的字，用

{ $code "
: list-files-and-dirs ( path -- files dirs )
    directory-entries [ type>> +regular-file+ = ] partition ;" }

有了这个，我们可以定义一个 { $snippet "ls" } 字，它将按如下方式打印目录内容：

{ $code "
: ls ( path -- )
    list-files-and-dirs
    \"DIRECTORIES:\" print
    \"------------\" print
    [ name>> print ] each
    \"FILES:\" print
    \"------\" print
    [ name>> print ] each ;" }

在你的主目录上尝试这个字以查看效果。在下一节中，我们将看看如何为我们的简单程序创建一个可执行文件。
;

ARTICLE: "tour-deploy-zh" "部署程序"

有两种方式在监听器之外运行 Factor 程序：作为脚本（由 Factor 解释执行），或作为为你的平台编译的独立可执行文件。两者都要求你定义一个带有入口点的词汇表（尽管对于脚本还有一种更简单的方式），所以我们先做这件事。

首先用 { $snippet "\"ls\" scaffold-work" } 创建我们的 { $snippet "ls" } 词汇表，并使其如下所示：

{ $code "\
! Copyright (C) 2026 您的名字.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors command-line io io.directories io.files.types
  kernel namespaces sequences ;
IN: ls

<PRIVATE

: list-files-and-dirs ( path -- files dirs )
    directory-entries [ type>> +regular-file+ = ] partition ;

PRIVATE>

: ls ( path -- )
    list-files-and-dirs
    \"DIRECTORIES:\" print
    \"------------\" print
    [ name>> print ] each
    \"FILES:\" print
    \"------\" print
    [ name>> print ] each ;" }

当我们运行词汇表时，需要从命令行读取参数。命令行参数存储在 { $link command-line } 动态变量下，它包含一个字符串数组。因此——忽略任何错误检查——我们可以定义一个字，用第一个命令行参数运行 { $snippet "ls" }

{ $code ": ls-run ( -- ) command-line get first ls ;" }

最后，我们使用 { $link POSTPONE: MAIN: } 字来声明我们词汇表的主字：

{ $code "MAIN: ls-run" }

将这两行添加到你的词汇表后，你现在可以运行它了。最简单的方式是使用传递给 Factor 的 { $snippet "-run" } 标志将词汇表作为脚本运行。例如，要列出我的主目录的内容，我可以执行

{ $code "$ ./factor -run=ls /home/andrea" }

为了生成一个可执行文件，我们必须设置一些选项并调用 { $snippet "deploy" } 字。最简单的方式是通过图形界面调用 { $link deploy-tool } 字。如果你写 { $snippet "\"ls\" deploy-tool" } ，你将看到一个窗口，用于选择部署选项。对于我们的简单情况，我们将保留默认选项并选择 Deploy。

稍等片刻后，你应该会得到一个可执行文件，你可以像下面这样运行

{ $code "$ cd ls

$ ./ls /home/andrea" }

尝试通过处理缺失的命令行参数以及不存在或非目录参数，使 { $snippet "ls" } 程序更加健壮。
;

ARTICLE: "tour-multithreading-zh" "多线程"

正如我们所说，Factor 运行时是单线程的，就像 Node 一样。尽管如此，可以通过使用 { $strong "协程（coroutines）" } 在单线程环境中模拟并发。这些本质上是协作线程（cooperative threads），通过 { $link yield } 字定期释放控制，以便调度器可以决定接下来运行哪个协程。

尽管协作线程不允许利用多核，但它们仍然有一些好处：
{ $list
  "输入/输出操作可以避免阻塞整个运行时，因此如果 I/O 是瓶颈的话，可以实现相当高性能的应用程序；"
  "用户界面天然是一个多线程结构，它们可以在此模型中实现，正如监听器本身所展示的那样；"
  "最后，有些问题可能天然就更容易利用多线程结构来编写。"
}

对于想要利用多核的情况，Factor 提供了生成其他进程并通过使用 { $strong "通道（channels）" } 在它们之间通信的可能性，我们将在后面的章节中看到。

Factor 中的线程使用引用（quotation）和名称，通过 { $link spawn } 字创建。让我们使用它来打印星球大战的前几行，每秒一行，每行在其自己的线程中打印。首先，我们将它们分配给一个动态变量：

{ $code "\
SYMBOL: star-wars

\"A long time ago, in a galaxy far, far away....

It is a period of civil war. Rebel
spaceships, striking from a hidden
base, have won their first victory
against the evil Galactic Empire.

During the battle, rebel spies managed
to steal secret plans to the Empire's
ultimate weapon, the DEATH STAR, an
armored space station with enough
power to destroy an entire planet.

Pursued by the Empire's sinister agents,
Princess Leia races home aboard her
starship, custodian of the stolen plans
that can save her people and restore
freedom to the galaxy....\"
\"\n\" split star-wars set
" }

我们将生成 18 个线程，每个线程打印一行。每个线程必须运行的操作等价于

{ $code "star-wars get ?nth print" }

注意动态变量在线程之间是共享的，所以每个线程都可以访问 star-wars。这没问题，因为它是只读的，但关于多线程环境中共享内存的通常注意事项仍然适用。

让我们为线程的工作负载定义一个词

{ $code "
: print-a-line ( i -- )
    star-wars get ?nth print ;" }

如果我们给第 i 个线程取名为 { $snippet "i" } ，我们的例子等价于

{ $code "
18 [0..b) [
    [ [ print-a-line ] curry ]
    [ number>string ]
    bi spawn
] each" }

注意使用 { $link curry } 将 i 传递给打印第 i 行的引用。这几乎是我们想要的，但它运行得太快了。我们需要让线程睡眠一段时间。所以我们 { $link clear } 现在包含大量线程对象的栈，并在帮助中查找 { $link sleep } 字。

结果发现 { $link sleep } 正是我们需要的，但它接受一个 { $strong "时长（duration）" } 对象作为输入。我们可以用...嗯 { $snippet "i seconds" } 创建 i 秒的时长。所以我们定义

{ $code "
: wait-and-print ( i -- )
    dup seconds sleep print-a-line ;" }

让我们尝试

{ $code "
18 [0..b) [
    [ [ wait-and-print ] curry ]
    [ number>string ]
    bi spawn
] each" }

除了 { $link spawn } ，我们还可以使用 { $link in-thread } ，它使用一个虚拟线程名并丢弃返回的线程，将上述简化为

{ $code "
18 [0..b) [
    [ wait-and-print ] curry in-thread
] each" }

在严肃的应用程序中，线程将是长期运行的。为了使它们协作，可以使用 { $link yield } 字来发出信号，表示线程已完成一个工作单元，其他线程可以获得控制。你还可能想看看其他用于 { $link stop } 、{ $link suspend } 或 { $link resume } 线程的字。
;

ARTICLE: "tour-servers-zh" "服务器与 Furnace"

服务器应用程序通常使用多个线程。在编写网络应用程序时，为每个传入连接启动一个线程是常见的做法（请记住，这些是绿色线程，比操作系统线程轻量得多）。

为了简化这一点，Factor 有 { $link spawn-server } 字，它的工作方式类似于 { $link spawn } ，但另外会重复生成引用（quotation），直到它返回 { $link f } 。这仍然是一个非常底层的字：实际上你需要做更多的工作：在给定端口上监听 TCP 连接、处理连接限制等等。

词汇表 { $vocab-link "io.servers" } 允许编写和配置 TCP 服务器。服务器使用 { $link <threaded-server> } 字创建，它需要一个编码作为参数。然后可以设置其槽来配置日志、连接限制、端口等。最重要的槽是 { $snippet "handler" } ，它包含一个为每个传入连接执行的引用。你可以通过以下方式查看一个简单的服务器示例：
{ $code "
\"resource:extra/time-server/time-server.factor\" edit-file
" }

我们将进一步提高抽象层次，展示如何运行一个简单的 HTTP 服务器。首先，{ $snippet "USE: http.server" } 。

一个 HTTP 应用程序是由一个 { $strong "响应器（responder）" } 构建的。响应器本质上是一个从路径和 HTTP 请求到 HTTP 响应的函数，但更具体地说，它是任何实现了 { $snippet "call-responder*" } 方法的东西。响应是元组 { $link response } 的实例，所以通常通过调用 { $link <response> } 并自定义一些槽来生成。让我们编写一个简单的回显响应器：

{ $code "TUPLE: echo-responder ;

: <echo-responder> ( -- responder ) echo-responder new ;

M: echo-responder call-responder*
    drop
    <response>
        200 >>code
        \"Document follows\" >>message
        \"text/plain\" >>content-type
        swap concat >>body ;" }

响应器通常组合起来形成更复杂的响应器，以实现路由和其他功能。在我们的简单示例中，我们将只使用这一个响应器，并全局设置它：

{ $code "<echo-responder> main-responder set-global" }

完成此操作后，你可以用 { $snippet "8080 httpd" } 启动服务器。然后你可以在浏览器中访问 { $url "https://localhost:8080/hello/%20/from/%20/factor" } 来查看你的第一个响应器的效果。你可以用 { $link stop-server } 停止服务器。

现在，如果这就是 Factor 为编写 Web 应用程序提供的全部功能，那仍然相当底层。实际上，Web 应用程序通常使用一个名为 { $strong "Furnace" } 的 Web 框架编写。

Furnace 允许我们——除其他功能外——使用模板语言编写更复杂的操作。实际上，默认附带两种模板语言，我们将使用 { $strong "Chloe" } 。Furnace 允许我们从 Chloe 模板创建 { $strong "页面操作（page actions）" } ，为了创建响应器，我们需要添加路由。

让我们先研究一个简单的路由示例。为此，我们创建一种特殊类型的响应器，称为 { $strong "分发器（dispatcher）" } ，它根据路径参数分发请求。让我们创建一个简单的分发器，它将在我们的回显响应器和一个用于提供静态文件的默认响应器之间选择。

{ $code "
dispatcher new-dispatcher
    <echo-responder> \"echo\" add-responder
    \"/home/andrea\" <static> \"home\" add-responder
    main-responder set-global" }

当然，将路径 { $snippet "/home/andrea" } 替换为任何你喜欢的文件夹。如果你用 { $snippet "8080 httpd" } 再次启动服务器，你应该能够看到我们简单的回显响应器（在 { $snippet "/echo" } 下）和你的文件内容（在 { $snippet "/home" } 下）。注意默认情况下目录列表是禁用的，你只能访问文件的内容。

现在你知道如何做路由了，我们可以在 Chloe 中编写页面操作。事情开始变得复杂，所以我们用 { $snippet "\"hello-furnace\" scaffold-work" } 搭建一个词汇表。使其如下所示：

{ $code "\
! Copyright (C) 2026 您的名字.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http http.server
  http.server.dispatchers http.server.static kernel sequences ;
IN: hello-furnace


TUPLE: echo-responder ;

: <echo-responder> ( -- responder ) echo-responder new ;

M: echo-responder call-responder*
    drop
    <response>
        200 >>code
        \"Document follows\" >>message
        \"text/plain\" >>content-type
        swap concat >>body ;

TUPLE: hello-dispatcher < dispatcher ;

: <example-responder> ( -- responder )
    hello-dispatcher new-dispatcher
        <echo-responder> \"echo\" add-responder
        \"/home/andrea\" <static> \"home\" add-responder
        <page-action>
            { hello-dispatcher \"greetings\" } >>template
        \"chloe\" add-responder ;" }

大多数事情与我们在监听器中做的相同。唯一的区别是我们在分发器中添加了第三个响应器，在 { $snippet "chloe" } 下。这个响应器是通过页面操作创建的。页面操作有许多槽——例如，声明接收表单结果的行为——但我们只设置其模板。这是分发器类和模板文件相对路径的对。

为了使这一切工作，创建一个文件 { $snippet "work/hello-furnace/greetings.xml" } ，内容如下：

{ $code "<?xml version='1.0' ?>

<t:chloe xmlns:t=\"http://factorcode.org/chloe/1.0\">
    <p>Hello from Chloe</p>
</t:chloe>" }

重新加载 { $snippet "hello-furnace" } 词汇表并 { $snippet "<example-responder> main-responder set-global" } 。你应该能够在 { $url "https://localhost:8080/chloe" } 下看到你的工作成果。注意无需重启服务器，我们可以动态更改主响应器。

这结束了我们对 Furnace 的非常简短的导览。Furnace 比这里展示的例子要丰富得多，因为它允许许多通用的 Web 任务。你可以在 { $vocab-link "furnace" } 文档中了解更多。
;

ARTICLE: "tour-processes-zh" "进程与通道"

如前所述，从操作系统的角度看，Factor 是单线程的。如果我们想利用多核，我们需要一种方法来生成 Factor 进程并在它们之间通信。Factor 实现了两种不同的消息传递并发模型：Actor 模型，基于在线程之间异步发送消息的思想，以及 CSP 模型，基于 { $strong "通道（channels）" } 的使用。

作为热身，我们将在同一进程中的线程之间制作一个简单的通信示例。

{ $code "FROM: concurrency.messaging => send receive ;" }

我们可以启动一个线程，它将接收消息并重复打印它：

{ $code ": print-repeatedly ( -- ) receive . print-repeatedly ;

[ print-repeatedly ] \"printer\" spawn" }

其引用以 { $link receive } 开头并递归调用自身的线程的行为类似于 Erlang 或 Akka 中的 actor。然后我们可以使用 { $link send } 向它发送消息。尝试 { $snippet "\"hello\" over send" } ，然后 { $snippet "\"threading\" over send" } 。

通道是一种略有不同的抽象，例如在 Go 和 Clojure core.async 中使用。它们解耦发送者和接收者，通常是同步使用的。例如，一方可以在另一方发送某些内容之前从通道接收。这只是意味着接收端放弃控制给调度器，调度器等待消息被发送，然后再将控制交还给接收者。这个特性有时使得同步多线程应用程序更容易。

再次，我们首先使用通道在同一进程中的线程之间通信。如预期，{ $snippet "USE: channels" } 。你可以用 { $link <channel> } 创建通道，用 { $link to } 向其写入，用 { $link from } 从中读取。注意这两个操作都是阻塞的：{ $link to } 将阻塞直到值在不同的线程中被读取，而 { $link from } 将阻塞直到有值可用。

我们创建一个通道并给它起个名字：

{ $code "SYMBOL: ch

<channel> ch set" }

然后我们在一个单独的线程中向其写入，以免阻塞 UI：

{ $code "[ \"hello\" ch get to ] in-thread" }

然后我们可以在 UI 中使用以下内容读取值：

{ $code "ch get from" }

我们也可以反转顺序：

{ $code "[ ch get from . ] in-thread

\"hello\" ch get to" }

这工作正常，因为我们先设置了读取者。

现在，有趣的部分：我们将启动第二个 Factor 实例并通过消息发送进行通信。Factor 透明地支持通过网络发送消息，使用 { $vocab-link "serialize" } 词汇表序列化值。

启动另一个 Factor 实例，并在其上运行一个节点服务器。我们将使用字 { $link <inet4> } 从主机和端口创建一个 IPv4 地址，以及 { $link <node-server> } 构造器

{ $code "USE: concurrency.distributed

f 9000 <inet4> <node-server> start-server" }

这里我们使用 { $link f } 作为主机，它代表 localhost。我们还将启动一个线程，保持已接收数字的运行计数。

{ $code "FROM: concurrency.messaging => send receive ;

: add ( x -- y ) receive + dup . add ;

[ 0 add ] \"adder\" spawn" }

一旦我们启动了服务器，我们可以用 { $link register-remote-thread } 使一个线程可用：

{ $code "dup name>> register-remote-thread" }

现在我们切换到另一个 Factor 实例。在这里，我们将接收一个对远程线程的引用并开始向其发送数字。线程的地址只是其服务器的地址和我们注册线程所用的名称，所以我们用以下方式获得对 adder 线程的引用

{ $code "f 9000 <inet4> \"adder\" <remote-thread>" }

现在，我们重新导入 { $link send } 以确保（与我们已导入的 { $vocab-link "io.sockets" } 中同名字存在重叠）

{ $code "FROM: concurrency.messaging => send receive ;" }

我们可以开始向其发送数字。尝试 { $snippet "3 over send" } ，然后 { $snippet "8 over send" } ——你应该在另一个 Factor 实例中看到打印的运行总数。

通道呢？我们回到服务器，在那里启动一个通道，就像上面一样。不过这次，我们 { $link publish } 它以使其可远程使用：

{ $code "USING: channels channels.remote ;

<channel> dup publish" }

作为返回，你得到一个可以远程用于通信的 ID。例如，我刚刚得到了 { $snippet "326546621698456955263335657082068225943" } （是的，他们确实想确保它是唯一的！）。

我们将在此通道上等待，从而阻塞 UI：

{ $code "swap from ." }

在另一个 Factor 实例中，我们使用 ID 获取对远程通道的引用并向其写入

{ $code "\
f 9000 <inet4> 326546621698456955263335657082068225943 <remote-channel>
\"Hello, channels\" over to" }

在服务器实例中，消息应该被打印出来。

远程通道和线程都可用于实现分布式应用程序并充分利用多核服务器。当然，剩下的问题是如何首先启动工作节点。在这里我们是手动完成的——如果节点集是固定的，这确实是一个选项。

否则，可以使用 { $vocab-link "io.launcher" } 词汇表以编程方式启动其他 Factor 实例。
;

ARTICLE: "tour-where-zh" "下一步去哪里？"

我们在这里涵盖了大量内容，我们希望这让你感受到了你用 Factor 能做的大事。你现在可以从容浏览文档，并希望自己也能为 Factor 做出贡献。

让我以一些提示结束：

{ $list
{ "开始编写 Factor 时，" { $emphasis "非常" } " 容易沉迷于栈操作（stack shuffling）。好好学" { $vocab-link "combinators" } "，不要害怕丢弃你的第一批示例。" }
"没有太短的定义：以单行为目标。"
"帮助系统和检查器是你最好的朋友。"
}
公平地说，我们必须提到 Factor 的一些缺点：

{ $list
"社区较小。在互联网上很难找到关于 Factor 的信息。但是，你可以通过在 Stack Overflow 上发布问题（[factor] 标签）来帮助改善这种情况。"
"连接性模型（concatenative model）非常强大，但也很难精通。"
"Factor 缺乏原生线程：虽然分布式进程弥补了这一点，但它们在序列化方面产生了一些成本。"
"Factor 目前没有包管理器。大多数知名包都是 Factor 主发行版的一部分。"
}

Factor 源代码树非常庞大，所以这里给出几个供你入门的词汇表：

{ $list
  { "我们还没有太多谈论错误和异常。在 " { $vocab-link "debugger" } " 词汇表中了解更多。" }
  { "" { $vocab-link "macros" } " 词汇表实现了一种编译时元编程的形式，比解析字不那么通用。" }
  { "" { $vocab-link "models" } " 词汇表让你使用具有可观察槽的对象实现一种数据流编程。" }
  { "" { $vocab-link "match" } " 词汇表实现了 ML 风格的模式匹配。" }
  { "" { $vocab-link "monads" } " 词汇表实现了 Haskell 风格的 monad。" }
}

这些词汇表是 Factor 的力量和表达力的证明，我们希望它们能帮助你做出你喜欢的东西。祝你编程愉快！

{ $code "\
USE: images.http

\"https://factorcode.org/logo.png\" http-image." }
;

ARTICLE: "tour-zh" "Factor 导览（中文）"
"Factor 是一种成熟的、动态类型的、基于连接性范式（concatenative paradigm）的编程语言。由于其连接性范式与大多数主流语言不同，入门 Factor 可能令人望而生畏。"
$nl
"本导览将："
{ $list
  "引导你学习 Factor 的基础知识，让你领略其简洁与强大。"
  "向你展示只需一些练习即可掌握 Factor。"
  "假设你已有一定的编程基础。"
}
$nl
"尽管 Factor 是小众语言，但它很成熟，拥有涵盖从 JSON 序列化到套接字编程和 HTML 模板等领域的全面标准库。它运行在经过优化的自有虚拟机中，作为动态类型语言具有非常高的性能。它还拥有灵活的对象系统、与 C 的 Foreign Function Interface（外部函数接口），以及类似于 Node.js 但具有更简单的协作多线程模型的异步 I/O。"
$nl
{ $heading "导览路线" }
{ $subsections
  "tour-concatenative-zh"
  "tour-stack-zh"
  "tour-first-word-zh"
  "tour-parsing-words-zh"
  "tour-stack-shuffling-zh"
  "tour-combinators-zh"
  "tour-vocabularies-zh"
  "tour-tests-docs-zh"
  "tour-objects-zh"
  "tour-tools-zh"
  "tour-metaprogramming-zh"
  "tour-stack-ne-zh"
  "tour-io-zh"
  "tour-deploy-zh"
  "tour-multithreading-zh"
  "tour-servers-zh"
  "tour-processes-zh"
  "tour-where-zh"
}
;

ABOUT: "tour-zh"
