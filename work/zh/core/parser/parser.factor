! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 解析器（Parser）— 中文翻译
! 原始文件: D:\factor\core\parser\parser-docs.factor

USING: arrays compiler.units definitions help.markup help.syntax
kernel lexer math namespaces parser quotations sequences
source-files strings vectors vocabs vocabs.parser words
words.symbol ;
IN: zh.core.parser

ARTICLE: "reading-ahead-zh" "预读（Reading ahead）"
"解析词可以从输入流中消费输入。解析词分为两类：遇到文件末尾时抛出错误的词，以及遇到文件末尾时返回 " { $link f } " 的词。" $nl
"遇到文件末尾时抛出错误的解析词："
{ $subsections
    scan-token
    scan-word-name
    scan-word
    scan-datum
    scan-number
    scan-object
}
"遇到文件末尾时返回 " { $link f } " 的解析词："
{ $subsections
    ?scan-token
    ?scan-datum
}
"一个简单的例子是 " { $link POSTPONE: \ } " 词："
{ $see POSTPONE: \ } ;

ARTICLE: "parsing-word-nest-zh" "嵌套结构（Nested structure）"
"回顾一下，解析器循环调用解析词时会在栈上带有一个累加器向量。解析器循环可以被递归调用，使用一个新的空累加器；然后结果可以被添加到原始累加器中。这就是对象字面量的解析词的实现方式；对象字面量可以任意深度嵌套。"
$nl
"一个简单的例子是读取引用的解析词："
{ $see POSTPONE: [ }
"这个词使用了一个工具词，该词递归调用解析器，将对象读入新的累加器，直到遇到 " { $link POSTPONE: ] } "："
{ $subsections parse-literal }
"还有另一个更低层的用于读取嵌套结构的词，直接调用它也很有用："
{ $subsections parse-until }
"像 " { $link POSTPONE: ] } " 这样的词使用了一种声明，当遇到未配对的出现时会抛出错误："
{ $subsections POSTPONE: delimiter }
{ $see-also POSTPONE: { POSTPONE: H{ POSTPONE: V{ POSTPONE: W{ POSTPONE: T{ POSTPONE: } } ;

ARTICLE: "defining-words-zh" "定义词（Defining words）"
"定义词向字典中添加定义，而不修改解析树。最简单的例子是 " { $link POSTPONE: SYMBOL: } " 词。"
{ $see POSTPONE: SYMBOL: }
"" { $link POSTPONE: SYMBOL: } " 定义的关键因素是 " { $link scan-new } "，它从输入中读取一个标记并创建一个具有该名称的词。然后将该词传递给 " { $link define-symbol } "。"
{ $subsections
    scan-new
    scan-new-word
}
"冒号定义以更复杂的方式实现："
{ $subsections POSTPONE: : }
"" { $link POSTPONE: : } " 词首先调用 " { $link scan-new } "，然后使用一个工具词读取输入直到遇到 " { $link POSTPONE: ; } "："
{ $subsections parse-definition }
"" { $link POSTPONE: ; } " 词只是一个分隔符；未配对的出现会抛出解析错误："
{ $see POSTPONE: ; }
"还有其他语法由 " { $link POSTPONE: ; } " 分隔的解析词，它们都是通过调用 " { $link parse-definition } " 或 " { $link parse-array-def } " 来实现的。" ;

ARTICLE: "parsing-tokens-zh" "解析原始标记（Parsing raw tokens）"
"到目前为止，我们已经看到了如何读取单个标记，或者读取一系列已解析的对象直到分隔符。也可以从输入中读取原始标记并执行自定义处理。"
$nl
"一个例子是 " { $link POSTPONE: USING: } " 解析词。"
{ $see POSTPONE: USING: }
"它读取一个由 " { $link POSTPONE: ; } " 终止的词汇列表。然而，词汇名称并不命名词（除非巧合），所以这里不能使用 " { $link parse-until } "。相反，可以使用一组更低层的组合子："
{ $subsections
    each-token
    map-tokens
    parse-tokens
} ;

ARTICLE: "parsing-words-zh" "解析词（Parsing words）"
"Factor 解析器遵循简单的递归下降设计。解析器从输入中读取连续的标记；如果标记标识一个数字或普通词，则将其添加到累加器向量中。否则，如果标记标识一个解析词，则立即执行该解析词。"
$nl
"解析词使用以下定义词来定义："
{ $subsections POSTPONE: SYNTAX: }
"按照惯例，解析词使用大写名称。以下是最简单的解析词示例；它在解析时打印问候语："
{ $code "SYNTAX: HELLO \"Hello world\" print ;" }
"解析词不得从栈上弹出或压入项目；但是，它们可以访问由解析器在栈顶提供的累加器向量。也就是说，解析词必须具有栈效果 " { $snippet "( accum -- accum )" } "，其中 " { $snippet "accum" } " 是解析器提供的累加器向量。"
$nl
"解析词可以读取输入、向字典中添加词定义，以及执行普通词可以执行的任何操作。"
$nl
"由于栈限制，解析词不能通过将值留在栈上来向其他词传递数据；应使用 " { $link suffix! } " 将数据添加到解析树中，以便稍后求值。"
$nl
"解析词不能从其定义的同一个源文件中调用，因为新定义只在源文件末尾编译。尝试在自己的源文件中使用解析词会引发错误："
{ $subsections staging-violation }
"实现解析词的工具："
{ $subsections
    "reading-ahead-zh"
    "parsing-word-nest-zh"
    "defining-words-zh"
    "parsing-tokens-zh"
    "word-search-parsing"
} ;

ARTICLE: "top-level-forms-zh" "顶层形式（Top level forms）"
"定义之外的任何代码称为 " { $emphasis "顶层形式（top-level form）" } "；顶层形式在整个源文件解析完成后运行，无论它们在文件中的位置如何。"
$nl
"顶层形式不能访问解析时清单（" { $link "word-search-parsing" } "），也不在 " { $link with-compilation-unit } " 内部运行；因此，与解析词相比，元编程在顶层形式中可能需要额外的工作。"
$nl
"此外，顶层形式在新的动态作用域中运行，因此使用 " { $link set } " 来存储值几乎总是错误的，因为这些值在顶层形式完成后会丢失。要保存由顶层形式计算的值，可以使用 " { $link set-global } " 或定义一个带有该值的新词。" ;

ARTICLE: "parser-zh" "解析器（The parser）"
"Factor 解析器读取对象和定义的文本表示，所有语法由 " { $link "parsing-words-zh" } " 确定。解析器在 " { $vocab-link "parser" } " 词汇中实现，标准语法在 " { $vocab-link "syntax" } " 词汇中。参见 " { $link "syntax" } " 了解标准语法的描述。"
$nl
"解析器交叉引用 " { $link "source-files" } " 和 " { $link "definitions" } "。此功能用于改进错误检查，以及诸如 " { $link "tools.crossref" } " 和 " { $link "editor" } " 等工具。"
$nl
"解析器可以被反射式地调用，以运行字符串和源文件。"
{ $subsections
    "eval"
    run-file
    parse-file
}
"如果 Factor 从命令行运行，并将脚本文件作为参数提供，则该脚本使用 " { $link run-file } " 运行。参见 " { $link "command-line" } "。"
$nl
"虽然 " { $link run-file } " 可以在监听器中交互式地用于将用户代码加载到会话中，但这只应用于快速的一次性脚本，真正的程序应改为依赖自动的 " { $link "vocabs.loader" } "。"
{ $see-also "parsing-words-zh" "definitions" "definition-checking" } ;

ABOUT: "parser-zh"

HELP: location
{ $values { "loc/f" "一个 " { $snippet "{ path line# }" } " 对或 " { $link f } } }
{ $description "输出当前解析器位置。此值可以传递给 " { $link set-where } " 或 " { $link remember-definition } "。" } ;

HELP: save-location
{ $values { "definition" "一个定义说明符" } }
{ $description "保存定义的位置，并将此定义与当前源文件关联。" } ;

HELP: bad-number
{ $error-description "表示解析器遇到了无效的数字字面量。" } ;

HELP: create-word-in
{ $values { "str" "一个词名" } { "word" "一个新词" } }
{ $description "在当前词汇中创建一个词。在被重新定义之前，该词在调用时会抛出错误。" }
$parsing-note ;

HELP: scan-new
{ $values { "word" word } }
{ $description "从解析器输入中读取下一个标记，并在当前词汇中创建一个具有该名称的词。" }
{ $errors "如果到达文件末尾则抛出错误。" }
$parsing-note ;

HELP: scan-new-word
{ $values { "word" word } }
{ $description "从解析器输入中读取下一个标记，在当前词汇中创建一个具有该名称的词，并重置该词的泛型词属性。" }
{ $errors "如果到达文件末尾则抛出错误。" }
$parsing-note ;

HELP: no-word-error
{ $error-description "如果解析器遇到一个在当前词汇搜索路径中不命名任何词的标记，则抛出此错误。如果具有此名称的词存在于不属于搜索路径的词汇中，则会提供一些重启选项，允许将这些词汇添加到搜索路径并使用所选的词。" }
{ $notes "除了缺少 " { $link POSTPONE: USE: } " 之外，此错误还可能表示排序问题。在 Factor 中，词必须先定义然后才能调用。相互递归可以通过 " { $link POSTPONE: DEFER: } " 实现。" } ;

HELP: no-word
{ $values { "name" string } { "newword" word } }
{ $description "抛出一个 " { $link no-word-error } " 错误。" } ;

HELP: parse-word
{ $values { "string" string } { "word" word } }
{ $description "在词汇搜索路径中搜索所有由 " { $snippet "string" } " 命名的词。如果没有匹配的词，则抛出错误；如果有一个词匹配且已加载，则返回该词。否则抛出一个可重启的错误，让用户选择要使用的词。" }
{ $errors "如果字符串未命名任何词，则抛出 " { $link no-word-error } "。" }
{ $notes "此词用于实现 " { $link scan-word } "。" } ;

HELP: parse-datum
{ $values { "string" string } { "word/number" { $or word number } } }
{ $description "如果 " { $snippet "string" } " 是有效的数字字面量，则将其转换为数字，否则在词汇搜索路径中搜索由该字符串命名的词。" }
{ $errors "如果标记未命名任何词，且未解析为数字，则抛出错误。" }
{ $notes "此词用于实现 " { $link ?scan-datum } " 和 " { $link scan-datum } "。" } ;

HELP: scan-word
{ $values { "word" word } }
{ $description "从解析器输入中读取下一个标记。在词汇搜索路径中搜索由该标记命名的词。" }
{ $errors "如果标记未命名任何词或到达文件末尾，则抛出错误。" }
$parsing-note ;

{ scan-word parse-word } related-words

HELP: scan-word-name
{ $values { "string" string } }
{ $description "从解析器输入中读取下一个标记，并确保它不解析为数字。" }
{ $errors "如果扫描的标记是数字或遇到文件末尾，则抛出错误。" }
$parsing-note ;

HELP: ?scan-datum
{ $values { "word/number/f" { $maybe word number } } }
{ $description "从解析器输入中读取下一个标记。如果在词汇搜索路径中找到该标记，则返回由该标记命名的词。如果该标记未找到词，则接下来将其转换为数字。如果此转换也失败，则此词返回 " { $link f } "。" }
$parsing-note ;

HELP: scan-datum
{ $values { "word/number" { $or word number } } }
{ $description "从解析器输入中读取下一个标记。如果在词汇搜索路径中找到该标记，则返回由该标记命名的词。如果在词汇搜索路径中未找到该标记，则将其转换为数字。如果此转换失败，则抛出错误。" }
{ $errors "如果标记不是数字或到达文件末尾，则抛出错误。" }
$parsing-note ;

HELP: scan-number
{ $values { "number" number } }
{ $description "从解析器输入中读取下一个标记。如果标记是数字字面量，则将其转换为数字。否则，抛出错误。" }
{ $errors "如果标记不是数字或到达文件末尾，则抛出错误。" }
$parsing-note ;

HELP: (parse-until)
{ $values { "accum" vector } { "end" word } }
{ $description "从解析器输入中解析对象直到遇到 " { $snippet "end" } "，将它们添加到累加器中。" }
$parsing-note ;

HELP: parse-until
{ $values { "end" word } { "vec" "一个新的向量" } }
{ $description "从解析器输入中解析对象直到遇到 " { $snippet "end" } "。输出一个包含结果的新向量。" }
{ $examples "此词用于实现 " { $link POSTPONE: ARTICLE: } "。" }
$parsing-note ;

{ parse-tokens each-token map-tokens parse-until (parse-until) } related-words

HELP: (parse-lines)
{ $values { "lexer" lexer } { "quot" "一个新的 " { $link quotation } } }
{ $description "使用自定义词法分析器解析 Factor 源代码。词汇搜索路径从当前作用域中获取。" }
{ $errors "如果输入格式错误，则抛出 " { $link lexer-error } "。" } ;

HELP: parse-lines
{ $values { "lines" { $sequence string } } { "quot" "一个新的 " { $link quotation } } }
{ $description "解析已按行分词（tokenized）的 Factor 源代码。词汇搜索路径从当前作用域中获取。" }
{ $errors "如果输入格式错误，则抛出 " { $link lexer-error } "。" } ;

HELP: parse-literal
{ $values { "accum" vector } { "end" word } { "quot" { $quotation ( seq -- obj ) } } }
{ $description "从解析器输入中解析对象直到遇到 " { $snippet "end" } "，将引用应用于结果序列，并将输出值添加到累加器中。" }
{ $examples "此词用于实现 " { $link POSTPONE: [ } "。" }
$parsing-note ;

HELP: parse-definition
{ $values { "quot" "一个新的 " { $link quotation } } }
{ $description "从解析器输入中解析对象直到遇到 " { $link POSTPONE: ; } "，并输出一个包含结果的引用。" }
{ $examples "此词用于实现 " { $link POSTPONE: : } "。" }
$parsing-note ;

HELP: parse-array-def
{ $values { "array" "一个新的 " { $link array } } }
{ $description "类似于 " { $link parse-definition } "，但解析后的序列以数组形式输出。" }
$parsing-note ;

HELP: bootstrap-syntax
{ $var-description "仅在引导（bootstrap）期间设置。存储宿主语法词汇的 " { $link vocab-words-assoc } " 的副本；这允许在引导源代码解析期间使用宿主的解析词，而不是目标的解析词。" } ;

HELP: with-file-vocabs
{ $values { "quot" quotation } }
{ $description "在一个仅包含 " { $snippet "syntax" } " 词汇的初始词汇搜索路径的作用域中调用引用。" } ;

HELP: parse-fresh
{ $values { "lines" { $sequence string } } { "quot" quotation } }
{ $description "解析一系列行中的 Factor 源代码。使用初始词汇搜索路径（参见 " { $link with-file-vocabs } "）。" }
{ $errors "如果输入格式错误，则抛出解析错误。" } ;

HELP: filter-moved
{ $values { "set1" set } { "set2" set } { "seq" { $sequence "definitions" } } }
{ $description "从 " { $snippet "set2" } " 中移除所有在 " { $snippet "set1" } " 中或不再存在于 " { $link current-source-file } " 中的定义。" } ;

HELP: forget-smudged
{ $description "遗忘已移除的定义。" } ;

HELP: finish-parsing
{ $values { "lines" "刚刚解析的文本行" } { "quot" "刚刚解析的引用" } }
{ $description "向 " { $link current-source-file } " 记录信息。" }
{ $notes "这是 " { $link parse-stream } " 的组成因素之一。" } ;

HELP: parse-stream
{ $values { "stream" "一个输入流" } { "name" "用于错误报告和交叉引用的文件名" } { "quot" quotation } }
{ $description "解析从流中读取的 Factor 源代码。使用初始词汇搜索路径。" }
{ $errors "如果从流中读取时发生 I/O 错误则抛出。如果输入格式错误，则抛出解析错误。" } ;

HELP: parse-file
{ $values { "path" "一个路径名字符串" } { "quot" quotation } }
{ $description "解析存储在文件中的 Factor 源代码。使用初始词汇搜索路径。" }
{ $errors "如果从文件中读取时发生 I/O 错误则抛出。如果输入格式错误，则抛出解析错误。" } ;

HELP: run-file
{ $values { "path" "一个路径名字符串" } }
{ $description "解析存储在文件中的 Factor 源代码并运行它。使用初始词汇搜索路径。" }
{ $errors "如果加载文件失败、输入格式错误或在调用解析后的引用时发生运行时错误，则抛出错误。" } ;

HELP: ?run-file
{ $values { "path" "一个路径名字符串" } }
{ $description "如果文件存在，则使用 " { $link run-file } " 运行它，否则什么也不做。" } ;

HELP: staging-violation
{ $values { "word" word } }
{ $description "抛出一个 " { $link staging-violation } " 错误。" }
{ $error-description "如果解析词在其定义的同一编译单元中被使用，则由解析器抛出；参见 " { $link "compilation-units" } "。" }
{ $notes "一种可能的解决方法是使用 " { $link POSTPONE: << } " 词在解析时执行代码。但是，仍然禁止在解析时执行同一源文件中定义的词。" } ;

HELP: auto-use?
{ $var-description "如果设置为真值，则解析器在遇到未知词名时的行为会发生改变。如果只有一个已加载的词汇具有此名称的词，则解析器不会抛出错误，而是将该词汇添加到搜索路径并打印一条解析注释。默认关闭。" }
{ $notes "此功能旨在帮助开发过程中使用。要自动生成 " { $link POSTPONE: USING: } " 形式，请启用 " { $link auto-use? } "，加载源文件，然后将解析器打印的 " { $link POSTPONE: USING: } " 形式复制粘贴回文件中，再禁用 " { $link auto-use? } "。参见 " { $link "word-search-errors" } "。" } ;

HELP: use-first-word?
{ $values { "words" sequence } { "?" boolean } }
{ $description "检查是否可以在不首先抛出可重启的 " { $link no-word-error } " 的情况下自动使用第一个词。" } ;

HELP: scan-object
{ $values { "object" object } }
{ $description "解析一个对象的字面表示。" }
$parsing-note ;
