! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 第一个程序教程（Your First Program）— 中文翻译
! 原始文件: D:\factor\basis\help\tutorial\tutorial.factor

USING: help.markup help.syntax ui.commands ui.operations
editors vocabs.loader kernel sequences prettyprint tools.test
vocabs.refresh strings unicode ui.tools.browser ui.tools.common ;
IN: zh.tutorial

ARTICLE: "first-program-start-zh" "为你的第一个程序创建词汇库"
"Factor 源代码被组织成 " { $link "vocabularies" } "。在编写第一个程序之前，我们必须为它创建一个词汇库。"
$nl
"首先加载脚手架工具："
{ $code "USE: tools.scaffold" }
"然后，让脚手架工具创建一个名为 " { $snippet "palindrome" } " 的新词汇库："
{ $code "\"palindrome\" scaffold-work" }
"如果你查看输出，你会看到在你的 \"work\" 目录中创建了几个文件，并且新的源文件已被加载。"
$nl
"以下短语将打印你的 work 目录的完整路径："
{ $code "\"work\" resource-path ." }
"work 目录是 Factor 搜索词汇库时使用的几个 " { $link "vocabs.roots" } " 之一。可以定义新的词汇库根目录；参见 " { $link "add-vocab-roots" } "。不过为了在本教程中保持简单，我们将只使用 work 目录。"
$nl
"在你的文件管理器中打开 work 目录，然后打开名为 " { $snippet "palindrome" } " 的子目录。在此子目录中，你会看到一个名为 " { $snippet "palindrome.factor" } " 的文件。用你的文本编辑器打开此文件。"
$nl
"你现在已准备好进入下一节：" { $link "first-program-logic-zh" } "。" ;

ARTICLE: "first-program-logic-zh" "在第一个程序中编写逻辑"
"Factor 的工作流程是编辑磁盘上的源代码，然后刷新实时映像。让我们检查一下刚刚用脚手架工具创建的文件。"
$nl
"在上一节之后，你的 " { $snippet "palindrome.factor" } " 文件应该如下所示："
{ $code
    "! Copyright (C) 2022 Your name."
    "! See https://factorcode.org/license.txt for BSD license."
    "USING: ;"
    "IN: palindrome"
}
"注意，文件以一个 " { $link POSTPONE: IN: } " 形式结束，告诉 Factor 此源文件中的所有定义都应放入 " { $snippet "palindrome" } " 词汇库中，使用 " { $link POSTPONE: IN: } " 词。我们将在 " { $link POSTPONE: IN: } " 形式之后添加新的定义。"
$nl
"为了能够调用在 " { $snippet "palindrome" } " 词汇库中定义的词，你需要在监听器中发出以下命令："
{ $code "USE: palindrome" }
"现在，我们将对文件进行一些添加。由于文件在上一步中被脚手架工具加载，如果文件发生变化，你需要告诉 Factor 重新加载它。Factor 有一个方便的功能；在监听器窗口中按 " { $command tool "common" refresh-all } " 将重新加载任何已更改的源文件。你也可以强制重新加载单个词汇库，以防刷新功能未检测到磁盘上的更改："
{ $code "\"palindrome\" reload" }
"现在我们将使用 " { $link POSTPONE: : } " 编写第一个词。这个词将测试一个字符串是否是回文（palindrome）；它接受一个字符串作为输入，并输出一个布尔值。我们将这个词命名为 " { $snippet "palindrome?" } "，遵循返回布尔值的词以 " { $snippet "?" } " 结尾的命名约定。"
$nl
"回忆一下，如果一个字符串正读反读都一样，即字符串等于其反转，则它是回文。我们可以在 Factor 中表达如下："
{ $code ": palindrome? ( string -- ? ) dup reverse = ;" }
"将这个定义放在源文件的末尾。"
$nl
"现在我们已经更改了源文件，必须将其重新加载到 Factor 中，以便测试新定义。为此，只需转到 Factor 监听器并按 " { $command tool "common" refresh-all } "。这将找到任何在磁盘上已更改的先前加载的源文件，并重新加载它们。"
$nl
"当你这样做时，你会收到一个关于 " { $link dup } " 词未找到的错误。这是因为此词是 " { $vocab-link "kernel" } " 词汇库的一部分，但该词汇库不在源文件的 " { $link "word-search" } " 中。你必须在源文件中显式列出依赖项。这使得 Factor 能够自动加载所需的词汇库，并使大型程序更易于维护。"
$nl
"要将该词添加到搜索路径中，首先确认此词在 " { $vocab-link "kernel" } " 词汇库中。在监听器的输入区域中输入 " { $snippet "dup" } "，然后按 " { $operation com-browse } "。这将打开文档浏览器工具，查看 " { $link dup } " 词的帮助。帮助文章中的一个小标题会提到该词所属的词汇库。"
$nl
"回到源文件的第三行，将其更改为："
{ $code "USING: kernel ;" }
"接下来，找出 " { $link reverse } " 属于哪个词汇库；在监听器的输入区域中输入词名 " { $snippet "reverse" } "，然后按 " { $operation com-browse } "。"
$nl
"它属于 " { $vocab-link "sequences" } " 词汇库，所以我们将其添加到搜索路径："
{ $code "USING: kernel sequences ;" }
"最后，检查 " { $link = } " 属于哪个词汇库，并确认它在 " { $vocab-link "kernel" } " 词汇库中，我们已经将其添加到了搜索路径中。"
$nl
"现在再次按 " { $command tool "common" refresh-all } "，源文件应该能无错误地重新加载。你现在可以继续学习 " { $link "first-program-test-zh" } "。" ;

ARTICLE: "first-program-test-zh" "测试你的第一个程序"
"在上一节之后，你的 " { $snippet "palindrome.factor" } " 文件应该如下所示："
{ $code
    "! Copyright (C) 2012 Your name."
    "! See https://factorcode.org/license.txt for BSD license."
    "USING: kernel sequences ;"
    "IN: palindrome"
    ""
    ": palindrome? ( string -- ? ) dup reverse = ;"
}
"我们现在将在监听器中测试我们的新词。如果还没有，请将 palindrome 词汇库添加到监听器的词汇搜索路径中："
{ $code "USE: palindrome" }
"接下来，将一个字符串压入栈（在监听器中用引号包围文本，然后按 " { $snippet "ENTER" } "）："
{ $code "\"hello\"" }
"注意，监听器中的栈显示现在显示了此字符串。提供输入后，我们调用我们的词："
{ $code "palindrome?" }
"栈显示现在应该有一个布尔值 false——" { $link f } "——即该词的输出。由于 \"hello\" 不是回文，这是我们预期的结果。我们可以通过调用 " { $link drop } " 来移除这个布尔值。操作完成后，栈应为空。"
$nl
"现在，让我们用回文试一下；我们将同一行代码中压入字符串并调用该词："
{ $code "\"racecar\" palindrome?" }
"栈现在应该包含一个布尔值 true——" { $link t } "。我们可以使用 " { $link . } " 词来打印并丢弃它："
{ $code "." }
"我们刚刚所做的被称为 " { $emphasis "交互式测试（interactive testing）" } "。在大型程序中，一个更高级的技术是 " { $link "tools.test" } "。"
$nl
"使用脚手架工具创建测试框架文件："
{ $code "\"palindrome\" scaffold-tests" }
"现在，打开名为 " { $snippet "palindrome-tests.factor" } " 的文件；它位于与 " { $snippet "palindrome.factor" } " 相同的目录中，由脚手架工具创建。"
$nl
"我们将添加一些单元测试，这些测试类似于我们上面所做的交互式测试。单元测试使用 " { $link POSTPONE: unit-test } " 词定义，它接受一个预期输出序列和一段代码。它运行该代码，并断言其输出了预期的值。"
$nl
"将以下两行添加到 " { $snippet "palindrome-tests.factor" } " 中："
{ $code
    "{ f } [ \"hello\" palindrome? ] unit-test"
    "{ t } [ \"racecar\" palindrome? ] unit-test"
}
"现在，你可以运行单元测试："
{ $code "\"palindrome\" test" }
"它应该报告所有测试都已运行且没有测试失败，显示以下输出："
$nl
{ $snippet "\
Unit Test: { { f } [ \"hello\" palindrome? ] }

Unit Test: { { t } [ \"racecar\" palindrome? ] }" }
$nl
"现在你可以阅读 " { $link "first-program-extend-zh" } "。" ;

ARTICLE: "first-program-extend-zh" "扩展你的第一个程序"
"我们的回文程序运行良好，但我们希望扩展它以忽略输入中的空格和非字母字符。"
$nl
"例如，我们希望它能识别以下内容为回文："
{ $code "\"A man, a plan, a canal: Panama.\"" }
"然而，目前我们使用的简单算法却说这不是回文："
{ $unchecked-example "\"A man, a plan, a canal: Panama.\" palindrome? ." "f" }
$nl
"我们希望它那里输出 " { $link t } "。我们可以用添加到 " { $snippet "palindrome-tests.factor" } " 的单元测试来编码这一需求："
{ $code "{ t } [ \"A man, a plan, a canal: Panama.\" palindrome? ] unit-test" }
"如果你现在运行单元测试，你会看到一个单元测试失败："
{ $code "\"palindrome\" test" }
"下一步当然是修复我们的代码，使单元测试能够通过。"
$nl
"我们首先编写一个词，它从字符串中移除空格和非字母字符，然后将字符串转换为小写。我们将这个词命名为 " { $snippet "normalize" } "。要弄清楚如何编写这个词，我们从监听器中的一些交互式实验开始。"
$nl
"首先将一个字符压入栈；注意字符实际上只是整数："
{ $code "CHAR: a" }
"现在，使用 " { $link Letter? } " 词来测试它是否是一个字母字符（大写或小写）："
{ $unchecked-example "Letter? ." "t" }
"注意：你可能会收到一条错误消息，询问你是否要使用 " { $link Letter? } " 词的 " { $link "ascii" } " 或 " { $link "unicode" } " 版本。选择 Unicode 版本将使 Factor 继续运行你的代码。"
$nl
"这给出了预期的结果。"
$nl
"现在用一个非字母字符试试："
{ $code "CHAR: #" }
{ $unchecked-example "Letter? ." "f" }
"我们想要做的是，给定一个字符串，移除所有不匹配 " { $link Letter? } " 谓词的字符。让我们将一个字符串压入栈："
{ $code "\"A man, a plan, a canal: Panama.\"" }
"现在，将一个包含 " { $link Letter? } " 的引用放在栈上；引用代码会将其放在栈上而不是立即执行："
{ $code "[ Letter? ]" }
"注意：" { $link "quotations" } " 类似于尚未执行的匿名函数或代码块。"
$nl
"最后，我们将字符串和引用传递给 " { $link filter } " 词，它将运行你的引用并返回一个新字符串，其中只包含 " { $link Letter? } " 返回 \"true\" 的字符："
{ $code "filter" }
"栈现在应该包含以下字符串："
{ $snippet "AmanaplanacanalPanama" } "。"
"这几乎是我们想要的；我们现在只需要将字符串转换为小写。这可以通过调用 " { $link >lower } " 来完成；" { $snippet ">" } " 前缀是转换操作的命名约定，应读作 \"to\"："
{ $code ">lower" }
"最后，让我们打印栈顶并丢弃它："
{ $code "." }
"这将输出 " { $snippet "amanaplanacanalpanama" } "。此字符串是我们想要的形式，我们评估了以下代码将其转换为这种形式："
{ $code "[ Letter? ] filter >lower" }
"此代码从栈上的一个字符串开始，移除非字母字符，并将结果转换为小写，在栈上留下一个新字符串。我们将此代码放入一个新词中，并将该新词添加到 " { $snippet "palindrome.factor" } "："
{ $code ": normalize ( string -- string' ) [ Letter? ] filter >lower ;" }
"你需要将 " { $vocab-link "unicode" } " 添加到词汇搜索路径中，以便在源文件中使用 " { $link >lower } " 和 " { $link Letter? } "。"
$nl
"我们修改 " { $snippet "palindrome?" } " 以首先对其输入应用 " { $snippet "normalize" } "："
{ $code ": palindrome? ( string -- ? ) normalize dup reverse = ;" }
"Factor 从上到下编译文件。因此，请务必将 " { $snippet "normalize" } " 的定义放在 " { $snippet "palindrome?" } " 的定义之上。"
$nl
"现在如果你按 " { $command tool "common" refresh-all } "，源文件应该能无错误地重新加载。你可以再次运行单元测试，这次它们将全部通过："
{ $code "\"palindrome\" test" }
"恭喜，你现在已经完成了 " { $link "first-program-zh" } "！" ;

ARTICLE: "first-program-zh" "你的第一个程序"
"在本教程中，我们将编写一个简单的 Factor 程序，提示用户输入一个词，并测试它是否是回文（palindrome）（即该词正读反读都一样）。"
$nl
"在本教程中，你将学习基本的 Factor 开发工具。"
$nl
"注意：当你遇到包含 Factor 代码示例的方框时，你可以点击它们将代码复制粘贴到你的监听器中，然后按 " { $snippet "ENTER" } " 运行。"
$nl
{ $subsections
    "first-program-start-zh"
    "first-program-logic-zh"
    "first-program-test-zh"
    "first-program-extend-zh"
} ;

ABOUT: "first-program-zh"
