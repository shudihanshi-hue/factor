! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 第一个程序教程（Your First Program）— 中文翻译
! 原始文件: D:\factor\basis\help\tutorial\tutorial.factor
!
USING: help.markup help.syntax ui.commands ui.operations
editors vocabs.loader kernel sequences prettyprint tools.test
vocabs.refresh strings unicode ui.tools.browser ui.tools.common ;
IN: zh.tutorial

ARTICLE: "first-program-start-zh" "为第一个程序创建词汇表"
"Factor 源代码被组织为 " { $link "vocabularies" } "。在编写第一个程序之前，我们必须为其创建一个词汇表。"
$nl
"首先加载脚手架（scaffold）工具："
{ $code "USE: tools.scaffold" }
"然后，让脚手架工具创建一个名为 " { $snippet "palindrome" } " 的新词汇表："
{ $code "\"palindrome\" scaffold-work" }
"如果查看输出，你会看到在 \"work\" 目录下创建了几个文件，并且新源文件已被加载。"
$nl
"以下命令将打印你的工作目录的完整路径："
{ $code "\"work\" resource-path ." }
"工作目录是 Factor 搜索词汇表的多个 " { $link "vocabs.roots" } " 之一。可以定义新的词汇表根目录；参见 " { $link "add-vocab-roots" } "。不过，为了本教程的简洁性，我们将仅使用工作目录。"
$nl
"在文件管理器中打开工作目录，并打开名为 " { $snippet "palindrome" } " 的子目录。在该子目录中，你将看到一个名为 " { $snippet "palindrome.factor" } " 的文件。在文本编辑器中打开此文件。"
$nl
"你现在可以继续下一节了：" { $link "first-program-logic-zh" } "。" ;

ARTICLE: "first-program-logic-zh" "在第一个程序中编写逻辑"
"Factor 的工作流程是在磁盘上编辑源代码，然后刷新活动映像。让我们检查一下刚才用脚手架工具创建的文件。"
$nl
"在上一节之后，你的 " { $snippet "palindrome.factor" } " 文件应该如以下所示："
{ $code
    "! Copyright (C) 2026 您的名字."
    "! See https://factorcode.org/license.txt for BSD license."
    "USING: ;"
    "IN: palindrome"
}
"注意，文件以 " { $link POSTPONE: IN: } " 形式结束，使用 " { $link POSTPONE: IN: } " 字告诉 Factor，该源文件中的所有定义应放入 " { $snippet "palindrome" } " 词汇表。我们将在 " { $link POSTPONE: IN: } " 形式之后添加新的定义。"
$nl
"为了能够调用 " { $snippet "palindrome" } " 词汇表中定义的字，你需要在监听器中发出以下命令："
{ $code "USE: palindrome" }
"现在，我们将对文件做一些添加。由于文件在之前步骤中已被脚手架工具加载，你需要告诉 Factor 在文件更改后重新加载它。Factor 提供了一个便捷的功能；在监听器窗口中按 " { $command tool "common" refresh-all } " 将重新加载任何已更改的源文件。你也可以强制刷新单个词汇表，以防刷新功能未检测到磁盘上的更改："
{ $code "\"palindrome\" reload" }
"我们现在将使用 " { $link POSTPONE: : } " 编写我们的第一个字。这个字将测试一个字符串是否是回文（palindrome）；它接受一个字符串作为输入，返回一个布尔值作为输出。我们将这个字命名为 " { $snippet "palindrome?" } "，遵循返回布尔值的字名称以 " { $snippet "?" } " 结尾的命名约定。"
$nl
"回想一下，如果一个字符串正着读和反着读完全一样，那么它就是回文；也就是说，该字符串与其反转相等。我们可以用 Factor 表达如下："
{ $code ": palindrome? ( string -- ? ) dup reverse = ;" }
"将此定义放在源文件的末尾。"
$nl
"现在我们已经更改了源文件，必须将其重新加载到 Factor 中，以便测试新定义。只需转到 Factor 监听器并按 " { $command tool "common" refresh-all } "。这将找到任何之前已加载但在磁盘上已更改的源文件，并重新加载它们。"
$nl
"执行此操作时，你将收到一个错误，提示未找到 " { $link dup } " 字。这是因为该字是 " { $vocab-link "kernel" } " 词汇表的一部分，但该词汇表不在源文件的 " { $link "word-search" } " 中。你必须在源文件中显式列出依赖项。这允许 Factor 自动加载所需的词汇表，并使大型程序更易于维护。"
$nl
"要将该字添加到搜索路径，首先确认该字在 " { $vocab-link "kernel" } " 词汇表中。在监听器的输入区域输入 " { $snippet "dup" } "，然后按 " { $operation com-browse } "。这将打开文档浏览器工具，查看 " { $link dup } " 字的帮助。帮助文章中的一个子标题将提到该字所属的词汇表。"
$nl
"回到源文件的第三行，将其改为："
{ $code "USING: kernel ;" }
"接下来，找出 " { $link reverse } " 属于哪个词汇表；在监听器的输入区域输入字名 " { $snippet "reverse" } "，然后按 " { $operation com-browse } "。"
$nl
"它在 " { $vocab-link "sequences" } " 词汇表中，因此我们将其添加到搜索路径："
{ $code "USING: kernel sequences ;" }
"最后，检查 " { $link = } " 属于哪个词汇表，确认它在 " { $vocab-link "kernel" } " 词汇表中，这已经添加到我们的搜索路径中了。"
$nl
"现在再次按 " { $command tool "common" refresh-all } "，源文件应该能无错误地重新加载。你现在可以继续学习 " { $link "first-program-test-zh" } " 了。" ;

ARTICLE: "first-program-test-zh" "测试第一个程序"
"在上一节之后，你的 " { $snippet "palindrome.factor" } " 文件应如下所示："
{ $code
    "! Copyright (C) 2012 您的名字."
    "! See https://factorcode.org/license.txt for BSD license."
    "USING: kernel sequences ;"
    "IN: palindrome"
    ""
    ": palindrome? ( string -- ? ) dup reverse = ;"
}
"现在我们将在监听器中测试我们的新字。如果还没有做，请将 palindrome 词汇表添加到监听器的词汇表搜索路径："
{ $code "USE: palindrome" }
"接下来，在栈上压入一个字符串（在监听器中用引号括住文本，然后按 " { $snippet "ENTER" } "）："
{ $code "\"hello\"" }
"注意，监听器中的栈显示现在表现出了这个字符串。提供了输入后，我们调用我们的字："
{ $code "palindrome?" }
"栈显示现在应该有一个布尔值 false —— " { $link f } " —— 这是字的输出。由于 \"hello\" 不是回文，这正是我们期望的。我们可以通过调用 " { $link drop } " 来清除这个布尔值。之后栈应为空。"
$nl
"现在，让我们用一个回文试试；我们将在一行代码中压入字符串并调用字："
{ $code "\"racecar\" palindrome?" }
"栈现在应该包含一个布尔值 true —— " { $link t } "。我们可以使用 " { $link . } " 字打印并丢弃它："
{ $code "." }
"我们刚刚做的被称为 " { $emphasis "交互式测试（interactive testing）" } "。随着程序规模增大，更高级的技术是 " { $link "tools.test" } "。"
$nl
"使用脚手架工具创建一个测试框架文件："
{ $code "\"palindrome\" scaffold-tests" }
"现在，打开名为 " { $snippet "palindrome-tests.factor" } " 的文件；它位于与 " { $snippet "palindrome.factor" } " 相同的目录中，是由脚手架工具创建的。"
$nl
"我们将添加一些单元测试，这些与我们在上面所做的交互式测试类似。单元测试用 " { $link POSTPONE: unit-test } " 字定义，它接受一个期望输出序列和一段代码。它运行代码，并断言代码输出期望的值。"
$nl
"将以下两行添加到 " { $snippet "palindrome-tests.factor" } "："
{ $code
    "{ f } [ \"hello\" palindrome? ] unit-test"
    "{ t } [ \"racecar\" palindrome? ] unit-test"
}
"现在，你可以运行单元测试："
{ $code "\"palindrome\" test" }
"它应该报告所有测试都已运行且没有测试失败，显示以下输出："
$nl
{ $snippet "\
单元测试: { { f } [ \"hello\" palindrome? ] }

单元测试: { { t } [ \"racecar\" palindrome? ] }" }
$nl
"现在你可以阅读 " { $link "first-program-extend-zh" } " 了。" ;

ARTICLE: "first-program-extend-zh" "扩展第一个程序"
"我们的回文程序运行得很好，然而我们想扩展它，使其忽略输入中的空格和非字母字符。"
$nl
"例如，我们希望它能识别以下字符串为回文："
{ $code "\"A man, a plan, a canal: Panama.\"" }
"然而，目前我们使用的简单算法认为这不是回文："
{ $unchecked-example "\"A man, a plan, a canal: Panama.\" palindrome? ." "f" }
$nl
"我们希望它在那里输出 " { $link t } "。我们可以通过在 " { $snippet "palindrome-tests.factor" } " 中添加一个单元测试来编码这个需求："
{ $code "{ t } [ \"A man, a plan, a canal: Panama.\" palindrome? ] unit-test" }
"如果现在运行单元测试，你会看到一个单元测试失败："
{ $code "\"palindrome\" test" }
"下一步当然是修复我们的代码，使得单元测试能够通过。"
$nl
"我们首先编写一个字，从字符串中移除空白和非字母字符，然后将字符串转换为小写。我们称这个字为 " { $snippet "normalize" } "。为了弄清楚如何编写这个字，我们从监听器中的交互式实验开始。"
$nl
"首先在栈上压入一个字符；注意字符实际上只是整数："
{ $code "CHAR: a" }
"现在，使用 " { $link Letter? } " 字来测试它是否是一个字母字符（大写或小写）："
{ $unchecked-example "Letter? ." "t" }
"注意：你可能会收到一条错误消息，询问你是否要使用 " { $link "ascii" } " 版本还是 " { $link "unicode" } " 版本的 " { $link Letter? } " 字。选择 Unicode 版本将允许 Factor 继续运行你的代码。"
$nl
"这给出了预期的结果。"
$nl
"现在用一个非字母字符试试："
{ $code "CHAR: #" }
{ $unchecked-example "Letter? ." "f" }
"我们想要做的是：给定一个字符串，移除所有不匹配 " { $link Letter? } " 谓词的字符。让我们在栈上压入一个字符串："
{ $code "\"A man, a plan, a canal: Panama.\"" }
"现在，将一个包含 " { $link Letter? } " 的引用（quotation）放在栈上；引用代码会将其放在栈上而不是立即执行："
{ $code "[ Letter? ]" }
"注意：" { $link "quotations" } " 类似于匿名函数或尚未执行的代码块。"
$nl
"最后，我们将字符串和引用传递给 " { $link filter } " 字，它将运行你的引用并返回一个新字符串，其中只包含 " { $link Letter? } " 返回 \"true\" 的字符："
{ $code "filter" }
"栈现在应该包含以下字符串："
{ $snippet "AmanaplanacanalPanama" } "。"
"这几乎是我们想要的；现在我们只需要将字符串转换为小写。这可以通过调用 " { $link >lower } " 来完成；" { $snippet ">" } " 前缀是转换操作的命名约定，应读作\"转为（to）\"："
{ $code ">lower" }
"最后，让我们打印栈顶并丢弃它："
{ $code "." }
"这将输出 " { $snippet "amanaplanacanalpanama" } "。这个字符串正是我们想要的形式，我们求值了以下代码来将其变成这种形式："
{ $code "[ Letter? ] filter >lower" }
"这段代码从栈上的一个字符串开始，移除非字母字符，并将结果转换为小写，在栈上留下一个新字符串。我们将这段代码放入一个新字，并将新字添加到 " { $snippet "palindrome.factor" } " 中："
{ $code ": normalize ( string -- string' ) [ Letter? ] filter >lower ;" }
"你需要将 " { $vocab-link "unicode" } " 添加到词汇表搜索路径中，以便 " { $link >lower } " 和 " { $link Letter? } " 可以在源文件中使用。"
$nl
"我们修改 " { $snippet "palindrome?" } "，使其首先对其输入应用 " { $snippet "normalize" } "："
{ $code ": palindrome? ( string -- ? ) normalize dup reverse = ;" }
"Factor 从文件顶端向下编译。所以，请确保将 " { $snippet "normalize" } " 的定义放在 " { $snippet "palindrome?" } " 的定义之上。"
$nl
"现在如果你按 " { $command tool "common" refresh-all } "，源文件应该能无错误地重新加载。你可以再次运行单元测试，这次它们将全部通过："
{ $code "\"palindrome\" test" }
"恭喜，你现在已经完成了 " { $link "first-program-zh" } "！" ;

ARTICLE: "first-program-zh" "你的第一个程序"
"在本教程中，我们将编写一个简单的 Factor 程序，提示用户输入一个单词，并测试它是否是回文（palindrome，即该单词正着拼和倒着拼完全一样）。"
$nl
"在本教程中，你将学习基本的 Factor 开发工具。"
$nl
"注意：当你遇到带有 Factor 代码示例的框时，可以点击它们将代码复制并粘贴到你的监听器中，然后按 " { $snippet "ENTER" } " 运行。"
$nl
{ $subsections
    "first-program-start-zh"
    "first-program-logic-zh"
    "first-program-test-zh"
    "first-program-extend-zh"
} ;

ABOUT: "first-program-zh"
