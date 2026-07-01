USING: help help.markup help.syntax help.topics help.lint.checks
kernel sequences words ;
IN: help.lint

HELP: help-lint-all
{ $values { "prefix" "一个词汇前缀 (a vocabulary prefix)" } }
{ $description "对带有给定前缀的所有词汇中的每个帮助文章和单词运行帮助检查工具。" } ;

HELP: help-lint
{ $values { "topic" "一个帮助主题 (a help topic)" } }
{ $description "在单个帮助主题上运行帮助检查工具。检查包括验证 { $link POSTPONE: HELP: } 声明中的 { $link $values } 元素数量是否与单词的栈效应匹配、验证帮助代码块能否成功运行、以及验证帮助文章中使用的所有单词是否都有文档。" }
{ $examples
  { $example "USING: help.lint ; \"help.lint\" help-lint-all" "" }
  { $example "USING: help.lint ; \\ help-lint help-lint" "" }
} ;

ARTICLE: "help.lint" "帮助检查工具 (Help lint tool)"
"帮助检查工具可以检查文档中的如下问题："
{ $list
    { "位于 " { $link $values } " 元素中的栈效应声明是否与单词本身的栈效应匹配" }
    { "代码片段中的 " { $link $example } " 和 " { $link $unchecked-example } " 是否能成功运行" }
    { "帮助文章中提到的 " { $link $link } " 是否指向未定义的文章" }
    { "帮助文章是否缺少关键部分，如 " { $link $values } "、" { $link $description } "、" { $link $error-description } " 或 " { $link $class-description } " 元素" }
    { "代码片段是否使用了未在该词汇 " { $link POSTPONE: USING: } " 列表中列出的词汇" }
    { "单词是否缺少 " { $link POSTPONE: HELP: } " 帮助声明（如果有文档存在）" }
}
{ $subsections
    help-lint
    help-lint-all
} ;