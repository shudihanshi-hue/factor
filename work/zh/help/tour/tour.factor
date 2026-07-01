! Copyright (C) 2022 Raghu Ranganathan and Andrea Ferreti.
! See https://factorcode.org/license.txt for BSD license.
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
IN: help.tour

ARTICLE: "tour-concatenative" "连接性语言 (Concatenative Languages)"
Factor 是一门 { $emphasis 连接性 } (concatenative) 编程语言,秉承 Forth 的精神。什么是连接性语言呢?

要理解连接性编程,请想象这样一个世界:每个值都是一个函数,而唯一允许的操作就是函数复合。由于函数复合无处不在,因此它是隐式的,函数可以并排放置以进行复合。所以如果 { $snippet "f" } 和 { $snippet "g" } 是两个函数,它们的复合就是 { $snippet "f g" } (与数学记号不同,函数从左到右读取,所以这意味着先执行 { $snippet "f" } ,再执行 { $snippet "g" } )。

这一点需要解释,因为我们知道函数通常有多个输入和输出,而且 { $snippet "f" } 的输出并不总是与 { $snippet "g" } 的输入相匹配。例如,{ $snippet "g" } 可能需要访问由先前函数计算的值。但 { $snippet "g" } 所能看到的只有 { $snippet "f" } 的输出,所以对 { $snippet "g" } 而言,{ $snippet "f" } 的输出就是整个世界的状态。为了使这一机制可行,函数必须贯穿全局状态,将其彼此传递。

这种全局状态可以用多种方式编码。最简单的办法是使用一个将变量名映射到其值的哈希表。但这种方式过于灵活:如果每个函数都能访问任何全局状态,那么对函数能做什么就缺乏控制,封装性很差,最终程序会变成一堆无组织地修改全局变量的例程的混乱集合。

将世界状态表示为一个栈 (stack) 在实践中效果很好。函数只能引用栈顶元素,因此栈顶以下的元素实际上超出了作用域。如果提供一些基本操作来操纵栈上的少数几个元素(例如 { $link swap } ,交换栈顶的两个元素),那么就可以引用栈中更深处的值,但值在栈中越深,引用它就越困难。

因此,鼓励函数保持小巧,只引用栈顶的两三个元素。从某种意义上说,局部变量和全局变量之间没有区别,但根据值距栈顶的距离,值可以更加局部化或更加全局化。

注意,如果每个函数都接收整个世界的状态并返回下一个状态,那么它的输入就再也不会被使用了。所以,尽管将纯函数视为接收一个栈作为输入并输出一个栈很方便,但可以通过修改单个栈来更高效地实现语言的语义。
;

ARTICLE: "tour-stack" "玩转栈 (Playing with the stack)"

让我们开始看看 Factor 实际上是什么感觉。我们的第一个词 (word) 将是字面量,比如 { $snippet "3" } 、 { $snippet "12.58" } 或 { $snippet "\"Chuck Norris\"" } 。字面量可以看作是将自身压入栈中的函数。尝试在监听器 (listener) 中输入 { $snippet "5" } ,然后按回车键确认。你会看到,初始为空的栈现在变成了

{ $code "5" }

你可以输入多个数字,用空格分隔,比如 { $snippet "7 3 1" } ,得到

{ $code "5
7
3
1"
}

(界面将栈顶显示在底部)。那运算呢?如果你输入 { $snippet "+" } ,你将运行 { $snippet "+" } 函数,该函数弹出栈顶的两个元素并压入它们的和,留下
{ $code "5
7
4"
}
你可以在一行中放入额外的输入,例如 { $snippet "- *" } 将在栈上留下单个数字 { $snippet "15" } (你知道为什么吗?)。

你可能最终会向栈中压入很多值,或者得到不正确的结果。这时你可以用快捷键 { $snippet "Alt+Shift+K" } (Linux/Windows) 或 { $snippet "Cmd+Shift+K" } (macOS) 来清空栈。

函数 { $snippet "." } (一个句点或点)打印栈顶的项,同时将其从栈中弹出,使栈变空。

如果我们将所有内容写在一行上,我们目前的程序看起来是这样的

{ $code "5 7 3 1 + - * ." }

这展示了 Factor 独特的算术运算方式——将参数放在前面,运算符放在最后——这种约定称为逆波兰表示法 (Reverse Polish Notation, RPN)。注意,RPN 不需要括号,不像 Lisp 中运算符在前的波兰表示法;RPN 也不需要优先级规则,不像大多数编程语言和日常算术中使用的中缀表示法。例如,在任何 Lisp 中,相同的计算会写成

{ $code "(* 5 (- 7 (+ 3 1)))" }

而在熟悉的中缀表示法中

{ $code "(7 - (3 + 1)) * 5" }

还要注意,我们能够将计算拆分到多行,或者相当随意地合并到更少的行上,而且每一行本身都是有意义的。
;

ARTICLE: "tour-first-word" "定义我们的第一个词 (Defining our first word)"

我们现在将定义第一个函数。Factor 对函数的命名略有特殊:由于函数从左到右读取,它们只是被称为 { $strong "词" } (words),这也是我们今后对它们的称呼。Factor 中的模块基于已有的词来定义新词,这些词的集合随后被称为 { $strong "词表" } (vocabularies)。

假设我们想计算阶乘。从一个具体的例子开始,我们将计算 { $snippet "10" } 的阶乘,所以我们先将 { $snippet "10" } 写到栈上。现在,阶乘是从 { $snippet "1" } 到 { $snippet "10" } 的数字的乘积,所以我们应先生成这样一个数字列表。

用来生成区间的词叫做 { $link [a..b] } (Factor 中的词法分析非常简单,因为词总是用空格分隔的,所以你可以使用任何非空白字符的组合作为词的名字;{ $link [a..b] } 中的 { $snippet "[" } 、 { $snippet ".." } 和 { $snippet "]" } 没有任何语义含义,它只是一个像 { $snippet "foo" } 或 { $snippet "bar" } 一样的记号)。

我们想要的区间以 { $snippet "1" } 开头,所以我们可以使用更简单的词 { $link [1..b] } ,它假设区间从 { $snippet "1" } 开始,只期望栈顶有区间的上限值。如果你收到 { $snippet "Data stack underflow" } 错误,这意味着你忘了先在栈上放一个数字作为上限 { $snippet "b" } 。

现在你的栈上应该有一个相当不透明的结构,看起来像

{ $code "T{ range f 1 10 1 }" }

这是因为我们的区间函数是惰性的,只在我们尝试使用它时才创建区间。为了确认我们确实创建了从 { $snippet "1" } 到 { $snippet "10" } 的数字列表,我们使用词 { $link >array } 将栈上的惰性响应转换为数组。输入该词,你的栈现在应该看起来像

{ $code "{ 1 2 3 4 5 6 7 8 9 10 }" }

这很有希望!

接下来,我们想取这些数字的乘积。在许多函数式语言中,这可以用一个叫做 reduce 或 fold 的函数来完成。让我们找找看。在监听器中按 { $snippet "F1" } 会打开一个上下文帮助系统,你可以在其中搜索 { $link reduce } 。事实证明 { $link reduce } 确实就是我们要找的词,但在这一点上如何使用它可能并不明显。

尝试输入 { $snippet "1 [ * ] reduce" } 并查看输出:它确实是 { $snippet "10" } 的阶乘。现在,{ $link reduce } 通常接受三个参数:一个序列(我们栈上已经有一个了)、一个起始值 (这里是我们接下来放到栈上的 { $snippet "1" } ) 和一个二元运算。这当然必须是 { $link * } ,但 { $link * } 周围的那些方括号是怎么回事呢?

如果我们只写 { $link * } ,Factor 会尝试将乘法应用到栈顶的两个元素上,这不是我们想要的。我们需要的是一种将词放到栈上而不应用它的方法。延续我们的文本比喻,这种机制叫做 { $strong "引用" } (quotation)。要引用一个或多个词,你只需用 { $link POSTPONE: [ } 和 { $link POSTPONE: ] } 将它们包围起来(留出空格!)。你得到的是一个匿名函数,可以被移动、操纵和调用。

让我们在监听器中输入词 { $link drop } 来清空栈,然后尝试将我们到目前为止所做的工作写在一行中: { $snippet "10 [1..b] 1 [ * ] reduce" } 。这将如预期的那样在栈上留下 { $snippet "3628800" } 。

我们现在想定义一个阶乘词,可以在我们需要阶乘的任何时候使用。我们将我们的词命名为 { $snippet "fact" } "(" 虽然 { $snippet "!" } 通常用作阶乘的符号,但在 Factor 中 { $snippet "!" } 是用作注释的词 ")" 。要定义它,我们首先需要使用词 { $link POSTPONE: : } 。然后是正在定义的词的名字,接着是 { $strong "栈效果" } (stack effects),最后是词体,以 { $link POSTPONE: ; } 词结束:

{ $code ": fact ( n -- n! ) [1..b] 1 [ * ] reduce ;" }

什么是栈效果?在我们的例子中,它是 { $snippet "( n -- n! )" } 。栈效果是你为你的词记录从栈上的输入和到栈上的输出的方式。你可以使用任何标识符来命名栈元素,这里我们用 { $snippet "n" } 。Factor 会执行一致性检查,确保你指定的输入和输出数量与词体所做的保持一致。

如果你尝试写

{ $code ": fact ( m n -- ..b ) [1..b] 1 [ * ] reduce ;" }

Factor 会发出错误,指出 2 个输入 { $snippet "m" } 和 { $snippet "n" } 与词体不一致。要恢复之前的正确定义,按 { $snippet "Ctrl+P" } 两次回到之前的输入,然后按回车。

定义中的栈效果既充当文档工具,又充当一个非常简单的类型系统,有助于捕获一些错误。

无论如何,你已经成功定义了你的第一个词:如果你在监听器中输入 { $snippet "10 fact" } 就可以证明这一点。

注意,定义中的 { $snippet "1 [ * ] reduce" } 部分本身就有一定意义,因为它是序列的乘积。连接性语言的好处是我们可以直接将这部分提取出来,写成

{ $code ": prod ( {x1,...,xn} -- x1*...*xn ) 1 [ * ] reduce ;

: fact ( n -- n! ) [1..b] prod ;" }

我们的定义变得更简单了,而且不需要传递参数、重命名局部变量,也不需要做在大多数语言中重构函数时所必需的其他事情。

当然,Factor 已经有一个计算阶乘的词(有一整个 { $vocab-link "math.factorials" } 词表,包括通常阶乘的许多变体)和一个计算乘积的词( { $link product } ,在 { $vocab-link "sequences" } 词表中),但正如经常发生的那样,入门示例与标准库有所重叠。
;

ARTICLE: "tour-parsing-words" "解析词 (Parsing Words)"
如果你到目前为止一直密切注意,你会发现你被欺骗了。 { $emphasis "大多数" } 词按照顺序在栈上操作,但有一些词如 { $link POSTPONE: [ } 、 { $link POSTPONE: ] } 、 { $link POSTPONE: : } 和 { $link POSTPONE: ; } 似乎不遵循这个规则。

这些是 { $strong "解析词" } (parsing words),它们的行为与 { $snippet "5" } 、 { $link [1..b] } 或 { $link drop } 等普通词不同。当我们讨论元编程时会更详细地介绍它们,但现在知道解析词是特殊的就够了。

它们不是用 { $link POSTPONE: : } 定义的,而是用 { $link POSTPONE: SYNTAX: } 定义的。当遇到解析词时,它可以使用定义良好的 API 与解析器交互,以影响后续词的解析方式。例如 { $link POSTPONE: : } 向解析器请求下一个记号,直到找到 { $link POSTPONE: ; } ,并尝试将该记号流编译为词定义。

解析词的一个常见用途是定义字面量。例如 { $link POSTPONE: { } 是一个解析词,它开始一个数组定义,并由 { $link POSTPONE: } } 终止。中间的所有内容都是数组的一部分。我们之前见过的数组例子是 { $snippet "{ 1 2 3 4 5 6 7 8 9 10 } " } 。

还有哈希表的字面量, { $snippet "H{ { \"Perl\" \"Larry Wall\" } { \"Factor\" \"Slava Pestov\" } { \"Scala\" \"Martin Odersky\" } } " } ,以及字节数组的字面量, { $snippet "B{ 1 14 18 23 } " } 。

解析词的其他用途包括模块系统、Factor 的面向对象特性、枚举、记忆化函数、私有性修饰符等。理论上,连 { $link POSTPONE: SYNTAX: } 本身都可以用自身来定义,但系统总得以某种方式被引导启动。

;

ARTICLE: "tour-stack-shuffling" "栈重排 (Stack Shuffling)"
现在你已经了解了 Factor 的基础知识,可能想要开始组装更复杂的词。这有时可能需要你使用不在栈顶的变量,或者多次使用某个变量。有一些词可以帮助你完成这些操作。我现在提到它们是因为你需要了解它们,但我警告你,使用太多这类词来操纵栈会使你的代码很快变得难以读写。栈重排需要在脑海中模拟栈上值的移动,这不是一种自然的编程方式。在下一节中,我们将看到一种更有效的方法来处理大多数需求。

以下是最常见的重排词及其对栈的影响列表。在监听器中尝试它们,以感受它们如何操纵栈。

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

要更深入地了解栈重排,请参阅 { $link "cookbook-colon-defs" } 。
;

ARTICLE: "tour-combinators" "组合子 (Combinators)"

虽然上一段提到的词偶尔有用(尤其是更简单的 { $link dup } 、 { $link drop } 和 { $link swap } ),你应该编写尽可能少做栈重排的代码。这需要练习,以便将函数参数按正确的顺序排列。尽管如此,有一些常见的所需栈操纵模式,最好将它们抽象为各自的词。

假设我们想定义一个词来判断给定数字 { $snippet "n" } 是否为素数。一个简单的算法是测试从 { $snippet "2" } 到 { $snippet "n" } 的平方根的每个数字,看它是否是 { $snippet "n" } 的因数。在这种情况下,{ $snippet "n" } 在两处被使用:作为序列的上限,以及作为测试可除性的数字。

词 { $link bi } 将两个不同的引用应用到它们上方栈上的单个元素,这正是我们需要的。例如 { $snippet "5 [ 2 * ] [ 3 + ] bi" } 得到
{ $code "
10
8
" }

{ $link bi } 将引用 { $snippet "[ 2 * ]" } 应用到值 { $snippet "5" } ,然后将引用 { $snippet "[ 3 + ]" } 应用到值 { $snippet "5" } ,在栈上先留下 { $snippet "10" } ,然后留下 { $snippet "8" } 。如果没有 { $link bi } ,我们必须先 { $link dup } { $snippet "5" } ,然后相乘,再 { $link swap } 乘法结果与第二个 { $snippet "5" } ,这样我们才能做加法

{ $code "
5 dup 2 * swap 3 +
" }

你可以看到 { $link bi } 替代了 { $link dup } 、然后计算、然后 { $link swap } 再计算的常见模式。

继续我们的素数例子,我们需要一种方法来创建从 { $snippet "2" } 开始的区间。我们可以用 { $link [a..b] } 词定义自己的词 { $snippet "[2..b]" } :

{ $code "
: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline
" }

那个 { $snippet "inline" } 词是怎么回事?这是我们定义一个词后可以使用的修饰符之一,另一个是 { $snippet "recursive" } 。这将允许我们在使用短词的地方内联其定义,而不是产生函数调用。

试试我们的新词 { $snippet "[2..b]" } ,看看它是否有效:

{ $code "
6 [2..b] >array .
" }

使用 { $snippet "[2..b]" } 来生成从 { $snippet "2" } 到已经在栈上的 { $snippet "n" } 的平方根的数字区间很简单: { $snippet "sqrt floor [2..b]" } (严格来说 { $link floor } 在这里不是必需的,因为 { $link [a..b] } 对非整数边界也有效)。让我们试试

{ $code "
16 sqrt [2..b] >array .
" }

现在,我们需要一个词来测试可除性。在在线帮助中快速搜索显示 { $link divisor? } 就是我们想要的词。将测试可除性的参数顺序反过来会更方便,所以我们定义 { $snippet "multiple?" } ":"

{ $code "
: multiple? ( a b -- ? ) swap divisor? ; inline
" }

我们可以验证这两个都返回 { $link t } 。

{ $code "
9 3 divisor? .
3 9 multiple? .
" }

由于我们将在 { $snippet "prime?" } 定义中使用 { $link bi } ,我们需要第二个引用。我们的第二个引用需要测试区间中的某个值是否是 { $snippet "n" } 的因数——换句话说,我们需要部分应用词 { $snippet "multiple?" } 。这可以用词 { $link curry } 来完成,像这样: { $snippet "[ multiple? ] curry" } 。

最后,一旦我们有了潜在因数的区间和栈上的测试函数,我们就可以用 { $link any? } 测试是否有任何元素满足可除性,然后用 { $link not } 取反该答案。我们对 { $snippet "prime" } 的完整定义看起来是

{ $code "
: prime? ( n -- ? )
    [ sqrt [2..b] ] [ [ multiple? ] curry ] bi any? not ;
" }

虽然 { $snippet "prime" } 的定义很复杂,但栈重排是最少的,而且只用在小的辅助函数中,这些函数比 { $snippet "prime?" } 更容易推理。

注意 { $snippet "prime?" } 使用了两层引用嵌套,因为 { $link bi } 对两个引用进行操作,而我们的第二个引用包含词 { $link curry } ,它也对引用进行操作。总的来说,Factor 的词往往相当浅,每个高阶函数使用一层嵌套,不像 Lisp 或更一般的基于 lambda 演算的语言,每个函数(无论是否高阶)都使用一层嵌套。

{ $link bi } 及其相关的 { $link tri } 是你在 Factor 中将使用的重排词的一小部分。你还应该通过在在线帮助中阅读并在监听器中尝试来熟悉 { $link bi } 、 { $link tri } 和 { $link bi@ } 。

;

ARTICLE: "tour-vocabularies" "词表 (Vocabularies)"

现在是时候开始在文件中编写你的函数并学习如何将它们导入到监听器中了。Factor 将词组织到嵌套的命名空间中,称为 { $strong "词表" } (vocabularies)。你可以用词 { $link POSTPONE: USE: } 导入一个词表中的所有名称。事实上,你可能见过类似这样的内容

{ $code "USE: ranges" }

当你让监听器为你导入词 { $link [1..b] } 时。你也可以用词 { $link  POSTPONE: USING: } 同时使用多个词表,它后面跟着一系列词表,以 { $link POSTPONE: ; } 结束,如

{ $code "USING: ranges sequences ;" }

最后,你用词 { $link POSTPONE: IN: } 定义存储你的定义的词表。如果你在在线帮助中搜索你到目前为止定义的某个词,比如 { $link prime? } ,你会看到你的定义已经被分组在默认的 { $vocab-link "scratchpad" } 词表下。顺便说一下,这表明在线帮助会自动收集你自己词的信息,这是一个非常有用的功能。

还有几个词,如 { $link POSTPONE: QUALIFIED: } 、 { $link POSTPONE: FROM: } 、 { $link POSTPONE: EXCLUDE: } 和 { $link POSTPONE: RENAME: } ,允许对导入进行更细粒度的控制,但 { $link POSTPONE: USING: } 是最常见的。

在磁盘上,词表存储在几个根目录下,很像 JVM 语言中的 classpath。默认情况下,系统会在 Factor 主目录下的 { $snippet "basis" } 、 { $snippet "core" } 、 { $snippet "extra" } 、 { $snippet "work" } 目录中查找。你可以添加更多,既可以在运行时用词 { $link add-vocab-root } ,也可以通过创建配置文件 { $snippet ".factor-rc" } ,但目前我们将词表存储在 { $snippet "work" } 目录下,该目录是为用户保留的。

生成一个词表模板,输入

{ $code "USE: tools.scaffold
\"github.tutorial\" scaffold-work" }

你会找到一个文件 { $snippet "work/github/tutorial/tutorial.factor" } ,其中包含一个空的词表。Factor 与许多编辑器集成,所以你可以尝试 { $snippet "\"github.tutorial\" edit" } ": " 这会提示你选择你最喜欢的编辑器,并使用该编辑器打开新创建的词表。

你可以添加上一段的定义,使其看起来像

{ $code "
! Copyright (C) 2014 Andrea Ferretti.
! See https://factorcode.org/license.txt for BSD license.
USING: ;
IN: github.tutorial

: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline

: multiple? ( a b -- ? ) swap divisor? ; inline

: prime? ( n -- ? )
    [ sqrt [2..b] ] [ [ multiple? ] curry ] bi any? not ;
" }

由于词表在你搭建时已经加载,我们需要一种从磁盘刷新它的方法。你可以用 { $snippet "\"github.tutorial\" refresh" } 。还有一个 { $link refresh-all } 词,快捷键是 { $snippet "F2" } 。

你会被提示几次使用词表,因为你的 { $link POSTPONE: USING: } 语句是空的。接受所有这些之后,Factor 会建议一个包含所有所需导入的新头部:

{ $code "
USING: kernel math.functions ranges sequences ;
IN: github.tutorial
" }

现在你的词表中有了一些词,你可以用 { $snippet "\\ multiple? edit" } 来编辑 { $snippet "multiple?" } 词。你会看到你的编辑器在正确文件的相关行上打开。这也适用于 Factor 发行版中的词,尽管修改它们可能不是个好主意。

这个 { $link POSTPONE: \ } 词需要一点解释。它的工作方式类似于一种转义,允许我们将下一个词的引用放到栈上,而不执行它。这正是我们需要的,因为 { $link edit } 是一个接受词本身作为参数的词。这种机制类似于引用,但引用创建一个新的匿名函数,而这里我们直接引用词 { $snippet "multiple?" } 。

回到我们的任务,你可能注意到 { $snippet "[2..b]" } 和 { $snippet "multiple?" } 只是你可能不想直接暴露的辅助函数。要将它们隐藏起来,你可以将它们包装在私有块中,如下所示

{ $code "
<PRIVATE

: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline

: multiple? ( a b -- ? ) swap divisor? ; inline

PRIVATE>
" }

进行此更改并刷新词表后,你会发现监听器不再能够引用 { $snippet "[2..b]" } 等词。 { $link POSTPONE: <PRIVATE } 词的工作方式是将私有块中的所有定义放在不同的词表下,在我们的例子中是 { $snippet "github.tutorial.private" } 。

你可以在一个词表中有多个 { $link POSTPONE: <PRIVATE } 块,所以可以根据需要自由组织它们。

仍然可以引用私有词表中的词,你可以通过在浏览器中搜索 { $snippet "[2..b]" } 来确认,但当然这不鼓励,因为人们不保证私有词的任何 API 稳定性。 { $snippet "github.tutorial" } 下的词可以直接引用 { $snippet "github.tutorial.private" } 中的词,就像 { $link prime? } 那样。

;

ARTICLE: "tour-tests-docs" "测试与文档 (Tests and Documentation)"

现在是个开始编写一些单元测试的好时机。你可以用以下命令创建一个骨架
{ $code "
\"github.tutorial\" scaffold-tests
" }
你会在 { $snippet "work/github/tutorial/tutorial-tests.factor" } 下找到一个生成的文件,你可以用 { $snippet "\"github.tutorial\" edit-tests" } 打开它。注意这一行

{ $code "
USING: tools.test github.tutorial ;
" }
它导入了单元测试模块以及你自己的模块。我们只测试公共的 { $snippet "prime?" } 函数。

测试使用 { $link POSTPONE: unit-test } 词编写,它期望两个引用:第一个包含预期输出,第二个包含为获得该输出而要运行的词。将这些行添加到 { $snippet "github.tutorial-tests" } ":"

{ $code "
{ t } [ 2 prime? ] unit-test
{ t } [ 13 prime? ] unit-test
{ t } [ 29 prime? ] unit-test
{ f } [ 15 prime? ] unit-test
{ f } [ 377 prime? ] unit-test
{ f } [ 1 prime? ] unit-test
{ t } [ 20750750228539 prime? ] unit-test
" }

你现在可以用 { $snippet "\"github.tutorial\" test" } 运行测试。你会看到我们实际上犯了一个错误,按 { $snippet "F3" } 会显示更多细节。似乎我们的断言在 { $snippet "2" } 上失败了。

事实上,如果你手动尝试对 { $snippet "2" } 运行我们的函数,你会看到我们的 { $snippet "[2..b]" } 定义对 { $snippet "2 sqrt" } 返回 { $snippet "{ 2 }" } ,因为 2 的平方根小于 2,所以我们得到了一个递减的区间。尝试做一个修复,使测试现在通过。

还有一些词用于测试错误和栈效果推断。目前使用 { $link POSTPONE: unit-test } 就够了,但之后你可能想查看 { $link "tools.test" } 的主要文档。

我们还可以为我们的词表添加一些文档。用户定义的词总是可以使用自动生成的文档(即使在监听器中),但我们可以手动编写一些有用的注释,甚至添加自定义文章,它们将出现在在线帮助中。可以预见,我们从 { $snippet "\"github.tutorial\" scaffold-docs" } 和 { $snippet "\"github.tutorial\" edit-docs" } 开始。

生成的文件 { $snippet "work/github/tutorial-docs.factor" } 导入了 { $vocab-link "help.markup" } 和 { $vocab-link "help.syntax" } 。这两个词表定义了生成文档的词。实际的帮助页面由 { $link POSTPONE: HELP: } 解析词生成。

{ $link POSTPONE: HELP: } 的参数是 { $snippet "{ $directive content... }" } 形式的嵌套数组。特别地,你在这里看到了指令 { $link $values } 和 { $link $description } ,但还存在更多,如 { $link $errors } 、 { $link $examples } 和 { $link $see-also } 。

注意输出 { $snippet "?" } 的类型已被推断为布尔值。将前几行改为

{ $code "
USING: help.markup help.syntax kernel math ;
IN: github.tutorial

HELP: prime?
{ $values
    { \"n\" fixnum }
    { \"?\" boolean }
}
{ $description \"测试 n 是否为质数。假定 n 是一个正整数。(Tests if n is prime. n is assumed to be a positive integer.)\" } ;
" }

并刷新 { $snippet "github.tutorial" } 词表。如果你现在查看 { $snippet "prime?" } 的帮助,例如用 { $snippet "\\ prime? help" } ,你会看到更新的文档。

你还可以在监听器中渲染指令以获得更快的反馈。例如,尝试输入

{ $code "
{ $values
    { \"n\" integer }
    { \"?\" boolean }
} print-content
" }

帮助标记包含许多可能的指令,你可以用它们在帮助系统中编写独立文章。用 { $snippet "\"element-types\" help" } 查看更多。
;

ARTICLE: "tour-objects" "对象系统 (The Object System)"

虽然从我们到目前为止所说的并不明显,但 Factor 具有面向对象的特性,许多核心词实际上是方法调用。为了更好地理解对象在 Factor 中的行为,引用一段话是恰当的:
$nl
{ $emphasis "\"I invented the term Object-Oriented and I can tell you I did not have C++ in mind.\"
  -Alan Kay" }
$nl
面向对象这个术语与使用它的人一样多,有不同的含义。一种观点——实际上是 Alan Kay 工作的核心——是关于函数名的后期绑定 (late binding)。在这个概念诞生的语言 Smalltalk 中,人们不谈论调用方法,而是向对象发送消息。由对象决定如何响应此消息,而调用者不应知道实现。例如,可以向数组和向量都发送消息 { $link map } ,但内部操作的处理方式不同。

消息名到方法实现的绑定是动态的,这被视为对象的核心优势。因此,相当复杂的系统可以从独立对象的协作中演化而来,这些对象不会干扰彼此的内部。

公平地说,Factor 与 Smalltalk 非常不同,但仍然有类的概念,可以定义泛型词 (generic words),在不同的类上有不同的实现。

一些类在 Factor 中是内建的,如 { $link string } 、 { $link boolean } 、 { $link fixnum } 或 { $link word } 。接下来,定义类的最常见方式是作为 { $strong "元组" } (tuple)。元组用 { $link POSTPONE: TUPLE: } 解析词定义,后跟元组名和我们要定义的类的字段,在 Factor 的术语中称为 { $strong "槽" } (slots)。

让我们为电影定义一个类:

{ $code "
TUPLE: movie title director actors ;
" }

这还会生成设置器 { $snippet ">>title" } 、 { $snippet ">>director" } 和 { $snippet ">>actors" } 以及获取器 { $snippet "title>>" } 、 { $snippet "director>>" } 和 { $snippet "actors>>" } 。例如,我们可以用以下方式创建一部新电影

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

词 { $link boa } 代表 'by-order-of-arguments'(按参数顺序)。它是一个构造器,按顺序用栈上的项填充元组的槽。 { $snippet "movie boa" } 被称为 { $strong "boa 构造器" } (boa constructor),是关于蟒蛇 (Boa Constrictor) 的双关语。惯常的做法是定义一个最常用的构造器,叫做 { $snippet "<movie>" } ,在我们的例子中可以简单地是

{ $code "
: <movie> ( title director actors -- movie ) movie boa ;
" }
事实上,boa 构造器非常常见,上述行可以缩短为

{ $code "
C: <movie> movie
" }

在其他情况下,你可能想使用一些默认值,或计算某些字段。

函数式思维的人会担心元组的可变性。实际上,槽可以被声明为只读的,用 { $snippet "{ slot-name read-only } " } 。在这种情况下,不会生成字段设置器,值必须在开始时用 boa 构造器设置。其他有效的槽修饰符有 { $link POSTPONE: initial: } ——用于声明默认值——以及一个类词,如 { $snippet "integer" } ,用于限制可以插入的值。

作为示例,我们为摇滚乐队定义另一个元组类

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

现在,当然每个人都知道电影中的明星是第一位演员,而在摇滚乐队中是贝斯手。为了编码这一点,我们首先定义一个 { $strong "泛型词" } (generic word)

{ $code "
GENERIC: star ( item -- star )
" }

如你所见,它用解析词 { $link POSTPONE: GENERIC: } 声明,并声明其栈效果,但目前没有实现,因此不需要结束的 { $link POSTPONE: ; } 。泛型词用于执行动态分派。我们可以用词 { $link POSTPONE: M: } 为各种类定义实现

{ $code "
M: movie star actors>> first ;

M: band star bass>> ;
" }

如果你写 { $snippet "star ." } 两次,你可以看到在不同类的实例上调用泛型词的不同效果。

内建类和元组类并不是对象系统的全部:可以用 { $link POSTPONE: UNION: } 和 { $link POSTPONE: INTERSECTION: } 等集合操作定义更多类。定义类的另一种方式是作为 { $strong "混入" } (mixin)。

混入用 { $link POSTPONE: MIXIN: } 词定义,现有的类可以像这样添加到混入中:

{ $code "
INSTANCE: class mixin
" }

在混入上定义的方法将对属于该混入的所有类可用。如果你熟悉 Haskell 的类型类,你会认出相似之处,尽管 Haskell 在编译时强制要求类型类的实例实现某些函数,而在 Factor 中这是在文档中非正式地指定的。

混入的两个重要例子是 { $link sequence } 和 { $link assoc } 。前者定义了一个对所有具体序列都可用的协议,如字符串、链表或数组,而后者定义了关联数组的协议,如哈希表或关联列表。

这使 Factor 中的所有序列都可以用一组通用的词来操作,同时在实现上有所不同,并最大限度地减少代码重复(因为只需要少数基本操作,其他操作是为 { $link sequence } 类定义的)。你将在序列上使用的最常见的操作是 { $link map } 、 { $link filter } 和 { $link reduce } ,但还有很多——如你所见,用 { $snippet "\"sequences\" help" } 。
;

ARTICLE: "tour-tools" "学习工具 (Learning the Tools)"

Factor 的很大一部分生产力来自于语言和库与周围工具的深度集成,这些工具体现在监听器中。监听器的许多功能可以以编程方式使用,反之亦然。你已经看到过一些这样的例子:

{ $list
  { "帮助可以在线浏览,但你也可以用 " { $link help } " 调用它,用 " { $link print-content } " 打印帮助项; " }
  { "快捷键 " { $snippet "F2" } " 或词 " { $link refresh } " 和 " { $link refresh-all } " 可用于在继续在监听器中工作的同时从磁盘刷新词表;" }
  { "词 " { $link edit } " 提供编辑器集成,但你也可以点击词表帮助页面中的文件名来打开它们。" }
}

刷新是一种高效的机制。每当一个词被重新定义,依赖它的词会根据新定义重新编译。你可以自己验证,执行

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

这允许你保持监听器打开,改进你的定义,定期将定义保存到文件并刷新以查看更改,而无需重新加载 Factor。

你还可以用词 { $link save-image } 保存当前会话的状态,之后通过以下方式启动 Factor 来恢复

{ $code "
./factor -i=path-to-image
" }

事实上,Factor 是基于镜像的,仅在加载和刷新词表时使用文件。

监听器的功能不止于此。栈中的元素可以通过点击它们或调用词 { $link inspector } 来检查。例如,尝试输入

{ $code "
TUPLE: trilogy first second third ;

: <trilogy> ( first second third -- trilogy ) trilogy boa ;

\"A new hope\" \"The Empire strikes back\" \"Return of the Jedi\" <trilogy>
\"George Lucas\" 2array
" }

你会得到一个看起来像这样的项

{ $code "
{ ~trilogy~ \"George Lucas\" }
" }

在栈上。尝试点击它:你将能够看到数组的槽。你可以通过双击检查器中显示的槽来检查它。这对于交互式原型设计极其有用。特殊对象可以通过实现 { $link content-gadget } 方法来自定义检查器。

还有另一个用于错误的检查器。每当出现错误时,可以用 { $snippet "F3" } 检查它。这允许你调查异常、错误的栈效果声明等。调试器允许你前后步入代码,你应该花点时间熟悉它。你还可以手动触发调试器,方法是在监听器中输入一些代码并按 { $snippet "Ctrl+w" } 。

监听器提供了代码基准测试的功能。作为一个例子,这里有一个故意低效的斐波那契:

{ $code "
DEFER: fib-rec
: fib ( n -- f(n) ) dup 2 < [ ] [ fib-rec ] if ;
: fib-rec ( n -- f(n) ) [ 1 - fib ] [ 2 - fib ] bi + ;
" }

(注意使用 { $link POSTPONE: DEFER: } 来定义两个相互递归的词)。你可以通过输入 { $snippet "40 fib" } 然后按 Ctrl+t 而不是回车来基准测试运行时间。你会得到计时信息以及其他统计信息。以编程方式,你可以在引用上使用 { $link time } 词来做同样的事情。

你还可以在词上添加监视,以在进入和退出时打印输入和输出。尝试输入

{ $code "
\\ fib watch
" }

然后运行 { $snippet "10 fib" } 看看会发生什么。然后你可以用 { $snippet "\\ fib reset" } 移除监视。

另一个有用的工具是 { $vocab-link "lint" } 词表。它扫描词定义以查找可以提取出来的重复代码。作为一个例子,让我们定义一个词来检查一个字符串是否以另一个字符串开头。创建一个测试词表

{ $code "
\"lintme\" scaffold-work
" }

并添加以下定义:

{ $code "
USING: kernel sequences ;
IN: lintme

: startswith? ( str sub -- ? ) dup length swapd head = ;
" }

用 { $snippet "USE: lint" } 加载 lint 工具,然后输入 { $snippet "\"lintme\" lint-vocab" } 。你会得到一份报告,提到词序列 { $snippet "length swapd" } 已经在 { $vocab-link "splitting.private" } 的词 { $link (split) } 中使用,因此可以提取出来。

修改标准库中词的源代码是不可取的——更不用说私有词了——但在更复杂的情况下,lint 工具可以帮助你防止代码重复。由于 Factor 拥有庞大的标准库,它有一个恰好做你想要的词并不罕见。定期对你的词表进行 lint 是个好主意,以避免代码重复,同时也是发现你可能意外重新定义的库词的好方法。

最后,还有一些实用工具来检查词。你可以在帮助工具中看到词的定义,但更快的方法可以是 { $link see } 。或者反过来,你可以使用 { $link usage. } 来检查给定词的调用者。尝试 { $snippet "\\ reverse see" } 和 { $snippet "\\ reverse usage." } 。
;

ARTICLE: "tour-metaprogramming" "元编程 (Metaprogramming)"

我们现在冒险进入元编程的世界,编写我们的第一个解析词。到目前为止,你已经看到了很多解析词,如 { $link POSTPONE: [ } 。 { $link POSTPONE: { } 、 { $link POSTPONE: H{ } 、 { $link POSTPONE: USE: } 、 { $link POSTPONE: IN: } 、 { $link POSTPONE: <PRIVATE } 、 { $link POSTPONE: GENERIC: } 等等。它们中的每一个都是用解析词 { $link POSTPONE: SYNTAX: } 定义的,并与 Factor 的解析器交互。

解析器将记号累积到一个累加器向量中,除非它找到解析词,解析词会立即执行。由于解析词在编译时执行,它们不能与栈交互,但它们可以访问累加器向量。它们的栈效果必须是 { $snippet "( accum -- accum )" } 。通常它们做的是向解析器请求更多记号,对它们做一些处理,最后用词 { $snippet "suffix!" } 将结果推到累加器向量上。

作为示例,我们将定义一个 DNA 序列的字面量。DNA 序列是胞嘧啶 (cytosine)、鸟嘌呤 (guanine)、腺嘌呤 (adenine) 和胸腺嘧啶 (thymine) 这四种碱基之一的序列,我们用字母 c、g、a、t 表示。由于有四种可能的碱基,我们可以每个用两位编码。让我们定义一个对字符进行操作的词:

{ $code "
: dna>bits ( token -- bits ) {
    { CHAR: a [ { f f } ] }
    { CHAR: c [ { t t } ] }
    { CHAR: g [ { f t } ] }
    { CHAR: t [ { t f } ] }
} case ;
" }

其中第一位表示碱基是嘌呤还是嘧啶,第二位标识配对的碱基。

我们的目标是读取一系列字母 a、c、g、t ——可能有空格——并将它们转换为位数组。Factor 支持位数组,字面位数组看起来像 { $snippet "?{ f f t }" } 。

我们的 DNA 语法将以 { $snippet "DNA{" } 开始,并获取所有记号直到找到结束记号 { $snippet "}" } 。中间的记号将被放入一个字符串中,使用我们的函数 { $snippet "dna>bits" } 将此字符串映射到位数组。为了读取记号,我们将使用词 { $link parse-tokens } 。还有一些更高级的词与解析器交互,如 { $link parse-until } 和 { $link parse-literal } ,但我们不能在它们的情况下应用它们,因为我们将找到的记号只是 a c g t 的序列,而不是有效的 Factor 词。让我们从一个简单的近似开始,只是读取分隔符之间的记号并输出通过连接获得的字符串

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat suffix! ;
" }

你可以通过执行 { $snippet "DNA{ a ccg t a g }" } 来测试效果,它应该输出 { $snippet "\"accgtag\"" } 。作为第二步近似,我们将每个字母转换为一个布尔对:

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat
    [ dna>bits ] { } map-as suffix! ;
" }

注意使用 { $link map-as } 而不是 { $link map } 。由于目标集合不是字符串,我们没有使用保持类型的 { $link map } ,而是使用 { $link map-as } ,它额外接受一个目标集合的样本——这里是 { $snippet "{ }" } 。我们的最终版本用 { $link concat } 展平对的数组,最后将其变为位数组:

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat
    [ dna>bits ] { } map-as
    concat >bit-array suffix! ;
" }

如果你用 { $snippet "DNA{ a ccg t a g }" } 尝试,你应该得到

{ $code "
{ $snippet \"?{ f f t t t t f t t f f f f t }\"
" }

让我们尝试来自 { $url
"https://re.factorcode.org/2014/06/swift-ranges.html" "Re: Factor" } 博客的一个例子,它为区间添加中缀语法。到目前为止,我们使用 { $link [a..b] } 来创建区间。我们可以使用 { $snippet "..." } 作为中缀词,创建一个对来自其他语言的人更友好的语法。

我们可以使用 { $link scan-object } 向解析器请求下一个解析的对象,使用 { $link unclip-last } 从累加器向量中获取顶部元素。这样,我们可以简单地用以下方式定义 { $snippet "..." }

{ $code "
SYNTAX: ... unclip-last scan-object [a..b] suffix! ;
" }

你可以用 { $snippet "12 ... 18 >array" } 尝试。

我们只是触及了解析词的表面;总的来说,它们允许你在编译时执行任意计算,实现强大的元编程形式。

从某种意义上说,Factor 的语法是完全扁平的,解析词允许你引入比本地使用的记号流更复杂的语法。这让任何程序员都可以通过在库中添加这些语法特性来扩展语言。原则上,甚至可以让一种外部语言编译为 Factor——比如 JavaScript——并将其作为领域特定语言嵌入到 { $snippet "<JS ... JS>" } 解析词的边界内。需要一些品味,不要过度使用以引入在连接性世界中过于异类的风格。
;

ARTICLE: "tour-stack-ne" "当栈不够用时 (When the stack is not enough)"

到目前为止我们有点作弊,试图避免编写在连接性风格中过于复杂的示例。事实是,你 { $emphasis "确实会" } 发现这种限制过于严格的情况。解析词可以缓解其中一些限制,Factor 自带了一些来处理最常见的烦恼。

你可能想做的一件事是真正命名局部变量。 { $link POSTPONE: :: } 词的工作方式类似于 { $link POSTPONE: : } ,但允许你真正将栈参数的名字绑定到变量,这样你就可以多次使用它们,按你想要的顺序。例如,让我们定义一个词来解二次方程。我将省略纯基于栈的版本,给你一个带局部变量的版本(这需要 { $vocab-link "locals" } 词表):

{ $code "
:: solveq ( a b c -- x )
    b neg
    b b * 4 a c * * - sqrt
    +
    2 a * / ;" }

在这种情况下我们选择了 + 号,但我们可以做得更好,输出两个解:

{ $code "
:: solveq ( a b c -- x1 x2 )
    b neg
    b b * 4 a c * * - sqrt
    [ + ] [ - ] 2bi
    [ 2 a * / ] bi@ ;" }

你可以用类似 { $snippet "2 -16 30 solveq" } 的内容检查这个定义是否有效,它应该输出 { $snippet "3.0" } 和 { $snippet "5.0" } 。除了以 RPN 风格编写外,我们第一个版本的 { $snippet "solveq" } 看起来与在有局部变量的语言中完全一样。对于第二个定义,我们使用组合子 { $link 2bi } 将 { $link + } 和 { $link - } 操作都应用到 -b 和 delta 上,然后使用 { $link bi@ } 将两个结果都除以 2a。

引用中也支持局部变量——使用 { $link POSTPONE: [| } ——方法中也支持——使用 { $link POSTPONE: M:: } ——还可以使用 { $link POSTPONE: [let } 创建一个在定义之外绑定局部变量的作用域。当然,所有这些实际上都被编译成带有一些栈重排的连接性代码。我鼓励你浏览这些词的示例,但请记住,它们在实践中使用的频率实际上比人们预期的要少得多——约占 Factor 自身代码库的 1%。

另一种常见的情况是,你需要在引用的特定位置添加值。你可以使用 { $link curry } 部分应用一个引用。这假设你要应用的值应该出现在引用的最左边;在其他情况下,你需要一些栈重排。词 { $link with } 是一种带洞的部分应用。它也柯里化一个引用,但使用栈上的第三个元素而不是第二个。而且,得到的柯里化引用将被应用到一个元素上,将其插入到第二个位置。

文档中的例子可能比上面的句子说得更多——尝试输入:

{ $code "1 { 1 2 3 } [ / ] with map" }

让我再次以 { $snippet "prime?" } 为例,但这次不使用辅助词来编写它:

{ $code "
: prime? ( n -- ? )
    [ sqrt 2 swap [a,b] ] [ [ swap divisor? ] curry ] bi any? not ;" }

使用 { $link with } 代替 { $link curry } ,这简化为

{ $code "
: prime? ( n -- ? )
    2 over sqrt [a,b] [ divisor? ] with any? not ;" }

如果你无法可视化正在发生的事情,你可能想考虑 { $vocab-link "fry" } 词表。它定义了 { $strong "炸引用" } (fried quotations);这些是其中有洞的引用——用 { $snippet "_" } 标记——由栈上的值填充。

第一个引用被更简单地重写为

{ $code "
[ '[ 2 _ sqrt [a,b] ] call ]
" }

这里我们使用炸引用——以 { $link POSTPONE: '[ } 开始——将栈顶的元素注入到第二个位置,然后使用 { $link call } 来评估得到的引用。第二个引用可以重写如下:

{ $code "
[ '[ _ swap divisor? ] ]
" }

所以 { $snippet "prime?" } 的另一种定义是

{ $code "
: prime? ( n -- ? )
    [ '[ 2 _ sqrt [a,b] ] call ] [ '[ _ swap divisor? ] ] bi any? not ;
" }

根据你的口味,你可能会觉得这个版本更易读。在这种情况下,增加的清晰度可能由于炸引用本身在引用内部而丧失,但偶尔它们的使用可以在很大程度上简化流程。

最后,有时候人们只是想给某个作用域内可用的变量命名,并在需要时使用它们。这些变量可以保存全局值,或至少不是单个词局部的值。一个典型的例子可能是输入和输出流,或数据库连接。

为此,Factor 允许你创建 { $strong "动态变量" } (dynamic variables) 并在作用域中绑定它们。第一件事是为变量创建一个 { $strong "符号" } (symbol),比如

{ $code "SYMBOL: favorite-language" }
然后可以使用词 { $link set } 来绑定变量,使用 { $link get } 来检索其值,如

{ $code "\"Factor\" favorite-language set
favorite-language get" }

作用域是嵌套的,可以用词 { $link with-scope } 创建新作用域。例如尝试

{ $code "
: on-the-jvm ( -- )
    [
        \"Scala\" favorite-language set
        favorite-language get .
    ] with-scope ;" }

如果你运行 { $snippet "on-the-jvm" } ,将打印 { $snippet "\"Scala\"" } ,但执行后, { $snippet "favorite-language get" } 将保持 { $snippet "\"Factor\"" } 作为其值。

我们在本节中看到的所有工具都应仅在绝对必要时使用,因为它们破坏了连接性并使词更难分解。然而,当需要时,它们可以大大提高清晰度。Factor 采取非常实用的方法,不羞于提供不那么纯粹但仍然经常有用的特性。
;

ARTICLE: "tour-io" "输入/输出 (Input/Output)"

我们现在将离开语言的导览,开始研究如何用 Factor 探索外部世界。本节将从基本输入和输出开始,然后转到异步、并行和分布式 I/O。

Factor 实现了高效的异步输入/输出设施,类似于 JVM 上的 NIO 或 Node.js I/O 系统。这意味着输入和输出操作在后台执行,让前台任务在磁盘旋转或网络缓冲数据包时自由地执行工作。Factor 目前是单线程的,但异步性使其在 I/O 密集型应用中相当高性能。

Factor 的所有输入/输出词都以 { $strong "流" } (streams) 为中心。流是可以从中读取或向其写入的惰性序列,典型的例子是文件、网络端口或标准输入和输出。Factor 持有几个动态变量,称为 { $link input-stream } 和 { $link output-stream } ,被大多数 I/O 词使用。这些变量可以使用 { $link with-input-stream } 、 { $link with-output-stream } 和 { $link with-streams } 在本地重新绑定。当你在监听器中时,默认流在监听器中写入和读取,但一旦你将应用程序部署为可执行文件,它们通常绑定到控制台的标准输入和输出。

词 { $link <file-reader> } 和 { $link <file-writer> } (或 { $link <file-appender> } )可用于创建到文件的读或写流,给定其路径和编码。将所有内容整合在一起,我们做一个简单的例子,一个词读取 UTF8 编码文件的每一行,并将该行的第一个字母写入监听器。

首先,我们想要一个 { $snippet "safe-head" } 词,它的工作方式类似于 { $link head } ,但如果序列太短则返回其输入。为此,我们将使用词 { $link recover } ,它允许我们声明一个 try-catch 块。它需要两个引用:第一个被执行,失败时,第二个以错误作为输入被执行。因此我们可以定义

{ $code "
: safe-head ( seq n -- seq' ) [ head ] [ 2drop ] recover ;" }

这是一个不切实际的异常例子,因为 Factor 定义了 { $link index-or-length } 词,它接受一个序列和一个数字,并返回序列长度和该数字之间的最小值。这使我们简单地写成

{ $code "
: safe-head ( seq n -- seq' ) index-or-length head ;" }

有了这个定义,我们可以制作一个词来读取第一行的第一个字符:

{ $code "
: read-first-letters ( path -- )
    utf8 <file-reader> [
        readln 1 safe-head print
    ] with-input-stream ;" }

使用辅助词 { $link with-file-reader } ,我们还可以将其缩短为

{ $code "
: read-first-letters ( path -- )
    utf8 [
        readln 1 safe-head print
    ] with-file-reader ;" }

不幸的是,我们被限制为一行。要读取更多行,我们应该链式调用 { $link readln } 直到其中一个返回 { $link f } 。Factor 用 { $link file-lines } 帮助我们,它惰性地迭代行。我们的最终定义变为

{ $code "
: read-first-letters ( path -- )
    utf8 file-lines [ 1 safe-head print ] each ;" }

当文件较小时,还可以使用 { $link file-contents } 将文件的全部内容读取到单个字符串中。Factor 定义了更多用于输入/输出的词,涵盖了更多情况,如二进制文件或套接字。

我们将通过研究一些遍历文件系统的词来结束本节。我们的目标是 { $snippet "ls" } 命令的一个非常小的实现。

词 { $link directory-entries } 列出目录的内容,给出一个元组元素列表,每个元素都有槽 { $snippet "name" } 和 { $snippet "type" } 。你可以通过尝试来看到这一点

{ $code "\"/home\" directory-entries [ name>> ] map" }
如果你检查目录条目,你会看到类型要么是 { $link +directory+ } 要么是 { $link +regular-file+ } (好吧,也有符号链接,但为简单起见我们将忽略它们)。因此我们可以定义一个词,用以下方式列出文件和目录

{ $code "
: list-files-and-dirs ( path -- files dirs )
    directory-entries [ type>> +regular-file+ = ] partition ;" }

有了这个,我们可以定义一个词 { $snippet "ls" } ,它将打印目录内容如下:

{ $code "
: ls ( path -- )
    list-files-and-dirs
    \"DIRECTORIES:\" print
    \"------------\" print
    [ name>> print ] each
    \"FILES:\" print
    \"------\" print
    [ name>> print ] each ;" }

在你的主目录上尝试这个词以查看效果。在下一节中,我们将看看如何为我们的简单程序创建一个可执行文件。
;

ARTICLE: "tour-deploy" "部署程序 (Deploying programs)"


在监听器之外运行 Factor 程序有两种方式:作为由 Factor 解释的脚本,或作为为你的平台编译的独立可执行文件。两者都要求你定义一个带有入口点的词表(虽然脚本有更简单的方式),所以让我们先做这个。

首先用 { $snippet "\"ls\" scaffold-work" } 创建我们的 { $snippet "ls" } 词表,使其看起来像这样:


{ $code "\
! Copyright (C) 2014 Andrea Ferretti.
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

当我们运行我们的词表时,我们需要从命令行读取参数。命令行参数存储在 { $link command-line } 动态变量下,它持有一个字符串数组。因此——忽略任何错误检查——我们可以定义一个词,用以下方式在第一个命令行参数上运行 { $snippet "ls" }

{ $code ": ls-run ( -- ) command-line get first ls ;" }

最后,我们使用词 { $link POSTPONE: MAIN: } 来声明我们词表的主词:

{ $code "MAIN: ls-run" }

将这两行添加到你的词表后,你现在可以运行它了。最简单的方法是使用传递给 Factor 的 { $snippet "-run" } 标志将词表作为脚本运行。例如,要列出我的主目录的内容,我可以这样做

{ $code "$ ./factor -run=ls /home/andrea" }

为了生成可执行文件,我们必须设置一些选项并调用 { $snippet "deploy" } 词。以图形方式执行此操作的最简单方法是调用 { $link deploy-tool } 词。如果你输入 { $snippet "\"ls\" deploy-tool" } ,你将看到一个窗口来选择部署选项。对于我们的简单情况,我们将保留默认选项并选择部署 (Deploy)。

过一会儿,你应该得到一个可以像这样运行的可执行文件

{ $code "$ cd ls

$ ./ls /home/andrea" }

尝试通过处理缺失的命令行参数以及不存在或非目录的参数,使 { $snippet "ls" } 程序更健壮。
;

ARTICLE: "tour-multithreading" "多线程 (Multithreading)"

如我们所说,Factor 运行时是单线程的,就像 Node 一样。尽管如此,可以通过使用 { $strong "协程" } (coroutines) 在单线程环境中模拟并发。这些本质上是协作式线程,它们用 { $link yield } 词定期释放控制权,以便调度器可以决定接下来运行哪个协程。

虽然协作式线程不允许利用多个核心,但它们仍然有一些好处:
{ $list
  "输入/输出操作可以避免阻塞整个运行时,因此如果 I/O 是瓶颈,可以实现相当高性能的应用;"
  "用户界面天然是一种多线程构造,可以在此模型中实现,正如监听器本身所示;"
  "最后,一些问题可能天然就更容易使用多线程构造来编写。"
}

对于想要利用多个核心的情况,Factor 提供了生成其他进程并使用 { $strong "通道" } (channels) 在它们之间通信的能力,我们将在后面的章节中看到。

Factor 中的线程使用一个引用和一个名称通过 { $link spawn } 词创建。让我们用这个来打印《星球大战》的前几行,每秒一行,每行在其自己的线程中打印。首先,我们将它们分配给一个动态变量:

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

我们将生成 18 个线程,每个打印一行。一个线程必须运行的操作相当于

{ $code "star-wars get ?nth print" }

注意动态变量在线程之间共享,因此每个线程都可以访问 star-wars。这没问题,因为它是只读的,但多线程环境中关于共享内存的通常警告适用。

让我们为线程工作负载定义一个词

{ $code "
: print-a-line ( i -- )
    star-wars get ?nth print ;" }

如果我们给第 i 个线程命名为 { $snippet "i" } ,我们的例子相当于

{ $code "
18 [0..b) [
    [ [ print-a-line ] curry ]
    [ number>string ]
    bi spawn
] each" }

注意使用 { $link curry } 将 i 发送到打印第 i 行的引用。这几乎是我们想要的,但它运行得太快了。我们需要让线程休眠一会儿。所以我们 { $link clear } 现在包含很多线程对象的栈,并在帮助中查找 { $link sleep } 词。

事实证明 { $link sleep } 正是我们需要的,但它接受一个 { $strong "持续时间" } (duration) 对象作为输入。我们可以用……好吧, { $snippet "i seconds" } 来创建 i 秒的持续时间。所以我们定义

{ $code "
: wait-and-print ( i -- )
    dup seconds sleep print-a-line ;" }

让我们试试

{ $code "
18 [0..b) [
    [ [ wait-and-print ] curry ]
    [ number>string ]
    bi spawn
] each" }

代替 { $link spawn } ,我们还可以使用 { $link in-thread } ,它使用一个虚拟的线程名并丢弃返回的线程,将上述简化为

{ $code "
18 [0..b) [
    [ wait-and-print ] curry in-thread
] each" }

在严肃的应用中,线程将是长时间运行的。为了使它们协作,可以使用 { $link yield } 词来表示线程已完成一个工作单元,其他线程可以获得控制权。你可能还想查看其他词来 { $link stop } 、 { $link suspend } 或 { $link resume } 线程。
;

ARTICLE: "tour-servers" "服务器与 Furnace (Servers and Furnace)"

服务器应用通常使用多个线程。在编写网络应用时,通常为每个传入连接启动一个线程(记住这些是绿色线程,因此比操作系统线程轻量得多)。

为了简化这一点,Factor 有词 { $link spawn-server } ,它的工作方式类似于 { $link spawn } ,但额外地重复生成引用直到它返回 { $link f } 。这仍然是一个非常低层的词:实际上还必须做更多事情:在给定端口上监听 TCP 连接、处理连接限制等。

词表 { $vocab-link "io.servers" } 允许编写和配置 TCP 服务器。服务器用词 { $link <threaded-server> } 创建,它需要一个编码作为参数。然后可以设置其槽来配置日志、连接限制、端口等。最重要的要填充的槽是 { $snippet "handler" } ,它包含对每个传入连接执行的引用。你可以用一个简单的服务器例子看到
{ $code "
\"resource:extra/time-server/time-server.factor\" edit-file
" }

我们将进一步提高抽象级别,展示如何运行一个简单的 HTTP 服务器。首先, { $snippet "USE: http.server" } 。

HTTP 应用由一个 { $strong "响应器" } (responder) 构建。响应器本质上是一个从路径和 HTTP 请求到 HTTP 响应的函数,但更具体地说,它是任何实现了方法 { $snippet "call-responder*" } 的东西。响应是元组 { $link response } 的实例,因此通常通过调用 { $link <response> } 并自定义几个槽来生成。让我们写一个简单的回显响应器:

{ $code "TUPLE: echo-responder ;

: <echo-responder> ( -- responder ) echo-responder new ;

M: echo-responder call-responder*
    drop
    <response>
        200 >>code
        \"Document follows\" >>message
        \"text/plain\" >>content-type
        swap concat >>body ;" }

响应器通常组合起来形成更复杂的响应器,以实现路由和其他功能。在我们简化的例子中,我们将只使用这一个响应器,并用以下方式全局设置它

{ $code "<echo-responder> main-responder set-global" }

完成此操作后,你可以用 { $snippet "8080 httpd" } 启动服务器。然后你可以在浏览器中访问 { $url "https://localhost:8080/hello/%20/from/%20/factor" } 来查看你的第一个响应器在运行。然后你可以用 { $link stop-server } 停止服务器。

现在,如果这就是 Factor 提供的用于编写 Web 应用的全部,它仍然相当低级。实际上,Web 应用通常使用一个叫做 { $strong "Furnace" } 的 Web 框架来编写。

Furnace 允许我们——除其他外——使用模板语言编写更复杂的动作。实际上,默认附带了两种模板语言,我们将使用 { $strong "Chloe" } 。Furnace 允许我们从 Chloe 模板创建 { $strong "页面动作" } (page actions),为了创建响应器,我们需要添加路由。

让我们先研究一个简单的路由例子。为此,我们创建一种特殊类型的响应器,叫做 { $strong "分派器" } (dispatcher),它根据路径参数分派请求。让我们创建一个简单的分派器,它将在我们的回显响应器和用于提供静态文件的默认响应器之间进行选择。

{ $code "
dispatcher new-dispatcher
    <echo-responder> \"echo\" add-responder
    \"/home/andrea\" <static> \"home\" add-responder
    main-responder set-global" }

当然,将路径 { $snippet "/home/andrea" } 替换为你喜欢的任何文件夹。如果你再次用 { $snippet "8080 httpd" } 启动服务器,你应该能够看到我们简单的回显响应器(在 { $snippet "/echo" } 下)和你的文件内容(在 { $snippet "/home" } 下)。请注意,目录列表默认是禁用的,你只能访问文件的内容。

现在你知道如何做路由了,我们可以用 Chloe 编写页面动作。事情开始变得复杂了,所以我们用 { $snippet "\"hello-furnace\" scaffold-work" } 搭建一个词表。使其看起来像这样:

{ $code "\
! Copyright (C) 2014 Andrea Ferretti.
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

大多数内容与我们在监听器中所做的一样。唯一的区别是我们在分派器中添加了第三个响应器,在 { $snippet "chloe" } 下。这个响应器是用页面动作创建的。页面动作有很多槽——比如声明接收表单结果的行为——但我们只设置了它的模板。这是分派器类和模板文件相对路径的对。

为了使所有这些工作,创建一个文件 { $snippet "work/hello-furnace/greetings.xml" } ,内容如

{ $code "<?xml version='1.0' ?>

<t:chloe xmlns:t=\"http://factorcode.org/chloe/1.0\">
    <p>Hello from Chloe</p>
</t:chloe>" }

重新加载 { $snippet "hello-furnace" } 词表并执行 { $snippet "<example-responder> main-responder set-global" } 。你应该能在 { $url "https://localhost:8080/chloe" } 下看到你的努力成果。注意不需要重启服务器,我们可以动态更改主响应器。

这结束了我们对 Furnace 的非常简短的导览。Furnace 比这里展示的例子要广阔得多,因为它允许许多通用的 Web 任务。你可以在 { $vocab-link "furnace" } 文档中了解更多。
;

ARTICLE: "tour-processes" "进程与通道 (Processes and Channels)"


如前所述,从操作系统的角度看,Factor 是单线程的。如果我们想利用多个核心,我们需要一种方法来生成 Factor 进程并在它们之间通信。Factor 实现了两种不同的消息传递并发模型:参与者模型 (actor model),基于在线程之间异步发送消息的思想,以及 CSP 模型,基于 { $strong "通道" } (channels) 的使用。

作为热身,我们将做一个在同一进程中的线程之间通信的简单例子。

{ $code "FROM: concurrency.messaging => send receive ;" }

我们可以启动一个线程,它将接收消息并重复打印它:

{ $code ": print-repeatedly ( -- ) receive . print-repeatedly ;

[ print-repeatedly ] \"printer\" spawn" }

一个引用以 { $link receive } 开始并递归调用自身的线程行为类似于 Erlang 或 Akka 中的参与者。然后我们可以使用 { $link send } 向它发送消息。尝试 { $snippet "\"hello\" over send" } ,然后 { $snippet "\"threading\" over send" } 。

通道是略有不同的抽象,例如在 Go 和 Clojure core.async 中使用。它们将发送者和接收者解耦,通常同步使用。例如,一方可以在其他方发送内容之前从通道接收。这只是意味着接收端将控制权交给调度器,调度器等待消息发送后再将控制权交回接收端。这个特性有时使同步多线程应用变得更容易。

同样,我们首先使用通道在同一进程中的线程之间通信。如预期的那样, { $snippet "USE: channels" } 。你可以用 { $link <channel> } 创建一个通道,用 { $link to } 写入,用 { $link from } 读取。注意两个操作都是阻塞的: { $link to } 将阻塞直到值在不同线程中被读取, { $link from } 将阻塞直到有可用值。

我们创建一个通道并用以下方式命名

{ $code "SYMBOL: ch

<channel> ch set" }

然后我们在一个单独的线程中写入它,以免阻塞 UI

{ $code "[ \"hello\" ch get to ] in-thread" }

然后我们可以在 UI 中读取值

{ $code "ch get from" }

我们还可以颠倒顺序:

{ $code "[ ch get from . ] in-thread

\"hello\" ch get to" }

这工作正常,因为我们先设置了读取者。

现在,有趣的部分:我们将启动第二个 Factor 实例并通过消息发送进行通信。Factor 透明地支持通过网络发送消息,使用 { $vocab-link "serialize" } 词表序列化值。

启动另一个 Factor 实例,并在其上运行一个节点服务器。我们将使用词 { $link <inet4> } ,它从主机和端口创建一个 IPv4 地址,以及 { $link <node-server> } 构造器

{ $code "USE: concurrency.distributed

f 9000 <inet4> <node-server> start-server" }

这里我们使用 { $link f } 作为主机,它只代表 localhost。我们还将启动一个线程,保持接收到的数字的运行计数。

{ $code "FROM: concurrency.messaging => send receive ;

: add ( x -- y ) receive + dup . add ;

[ 0 add ] \"adder\" spawn" }

一旦我们启动了服务器,我们就可以用 { $link register-remote-thread } 使一个线程可用 ":"

{ $code "dup name>> register-remote-thread" }

现在我们切换到另一个 Factor 实例。这里我们将接收对远程线程的引用并开始向它发送数字。线程的地址就是其服务器的地址和我们注册线程时使用的名称,因此我们用以下方式获得对加法器线程的引用

{ $code "f 9000 <inet4> \"adder\" <remote-thread>" }

现在,我们重新导入 { $link send } 以确保(与我们导入的 { $vocab-link "io.sockets" } 中具有相同名称的词有重叠)

{ $code "FROM: concurrency.messaging => send receive ;" }

然后我们可以开始向它发送数字。尝试 { $snippet "3 over send" } ,然后 { $snippet "8 over send" } ——你应该看到运行中的总数打印在另一个 Factor 实例中。

通道呢?我们回到我们的服务器,在那里启动一个通道,就像上面一样。但这次,我们 { $link publish } 它以使其远程可用:

{ $code "USING: channels channels.remote ;

<channel> dup publish" }

你得到的是一个 id,你可以远程使用它来通信。例如,我刚得到 { $snippet "326546621698456955263335657082068225943" } (是的,他们确实想确保它是唯一的!)。

我们将在此通道上等待,从而阻塞 UI:

{ $code "swap from ." }

在另一个 Factor 实例中,我们使用 id 获得对远程通道的引用并写入

{ $code "\
f 9000 <inet4> 326546621698456955263335657082068225943 <remote-channel>
\"Hello, channels\" over to" }

在服务器实例中,应该会打印出消息。

远程通道和线程对于实现分布式应用和充分利用多核服务器都很有用。当然,问题仍然是如何启动工作节点。这里我们手动完成了——如果节点集是固定的,这实际上是一个选项。

否则,可以使用 { $vocab-link "io.launcher" } 词表以编程方式启动其他 Factor 实例。
;

ARTICLE: "tour-where" "接下来去哪里? (Where to go from here?)"

我们在这里涵盖了很多内容,我们希望这让你体验到了用 Factor 可以做的伟大事情。你现在可以通读文档,并希望为 Factor 自己做出贡献。

最后让我提几个提示:

{ $list
{ "在开始编写 Factor 时,处理大量栈重排非常容易。好好学习 "
{ $vocab-link "combinators" } " ,不要害怕丢弃你的第一个例子。" }
"没有定义太短的:以一行为目标。"
"帮助系统和检查器是你最好的朋友。"
}
公平地说,我们必须提到 Factor 的一些缺点:

{ $list
"社区很小。在互联网上很难找到关于 Factor 的信息。但是,你可以通过在 Stack Overflow 上以 [factor] 标签发布问题来帮助解决这个问题。"
"连接性模型非常强大,但也很难以精通。"
"Factor 缺少原生线程:虽然分布式进程可以弥补这一点,但它们在序列化方面会产生一些开销。"
"Factor 目前没有包管理器。最突出的包是 Factor 主发行版的一部分。"
}

Factor 的源代码树非常庞大,所以这里有一些词表让你开始:

{ $list
  { "我们还没有太多地讨论错误和异常。在 " { $vocab-link "debugger" } " 词表中了解更多。" }
  { "词表 " { $vocab-link "macros" } " 实现了一种编译时元编程形式,不如解析词通用。" }
  { "词表 " { $vocab-link "models" } " 让你使用具有可观察槽的对象实现一种数据流编程。" }
  { "词表 " { $vocab-link "match" } " 实现了 ML 风格的模式匹配。" }
  { "词表 " { $vocab-link "monads" } " 实现了 Haskell 风格的单子。" }
}

这些词表证明了 Factor 的强大和表现力,我们希望它们能帮助你做出你喜欢的东西。快乐编程!

{ $code "\
USE: images.http

\"https://factorcode.org/logo.png\" http-image." }
;

ARTICLE: "tour" "Factor 导览 (Guided tour of Factor)"
Factor 是一门成熟的、基于连接性范式的动态类型语言。开始使用 Factor 可能会令人望而生畏,因为连接性范式与大多数主流语言不同。
本教程将:

{ $list
  "引导你了解 Factor 的基础知识,以便你欣赏它的简洁和强大。"
  "向你展示 Factor 通过一点练习就可以掌握。"
  "假设你对编程有一定了解。"
}

尽管 Factor 是一门小众语言,但它是成熟的,拥有一个全面的标准库,涵盖从 JSON 序列化到套接字编程和 HTML 模板等任务。它在自己的优化 VM 中运行,对于动态类型语言来说性能非常高。它还有一个灵活的对象系统、一个 C 的外部函数接口 (Foreign Function Interface),以及异步 I/O,其工作方式有点像 Node.js,但具有更简单的协作式多线程模型。

Factor 相比其他语言有一些显著优势,其中大多数源于它本质上没有语法:

{ $list
  "重构非常容易,从而产生简短而有意义的函数定义"
  "它极其简洁,让程序员专注于重要的事情而不是样板代码"
  "它拥有强大的元编程能力,甚至超过 Lisp"
  "它非常适合创建 DSL"
  "它易于与强大的工具集成"
}

示例中的一些文件路径可能需要根据你的系统进行调整。

第一节给出了连接性语言独特计算模型的一些动机,但如果你想亲自动手实践,可以随意跳过它,在 Factor 的实际操作练习之后再回来。

{ $heading "导览 (The Tour)" }
{ $subsections
  "tour-concatenative"
  "tour-stack"
  "tour-first-word"
  "tour-parsing-words"
  "tour-stack-shuffling"
  "tour-combinators"
  "tour-vocabularies"
  "tour-tests-docs"
  "tour-objects"
  "tour-tools"
  "tour-metaprogramming"
  "tour-stack-ne"
  "tour-io"
  "tour-deploy"
  "tour-multithreading"
  "tour-servers"
  "tour-processes"
  "tour-where"
}
;

ABOUT: "tour"
