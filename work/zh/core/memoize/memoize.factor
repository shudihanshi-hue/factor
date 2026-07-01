! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 记忆化函数（Memoization）— 中文翻译
! 原始文件: D:\factor\core\memoize\memoize-docs.factor

USING: help.syntax help.markup memoize words quotations effects ;
IN: zh.core.memoize

ARTICLE: "memoize-zh" "记忆化函数 (Memoization)"
"" { $vocab-link "memoize" } " 词汇实现了一种简单的记忆化（memoization）形式，即单词为提供的每组唯一输入缓存结果。使用相同输入多次调用记忆化单词不会重新计算任何东西。"
$nl
"记忆化适用于可能输入集合较小，但结果计算开销大且应被缓存的情况。记忆化单词不应有任何副作用。"
$nl
"在解析时定义记忆化单词："
{ $subsections POSTPONE: MEMO: }
"在运行时定义记忆化单词："
{ $subsections define-memoized }
"清除记忆化结果："
{ $subsections reset-memoized } ;

ABOUT: "memoize-zh"

HELP: define-memoized
{ $values { "word" word } { "quot" quotation } { "effect" effect } }
{ $description "在运行时将给定单词定义为记忆化单词，即给定特定输入时记忆化其输出。" } ;

HELP: MEMO:
{ $syntax "MEMO: word ( stack -- effect ) definition... ;" }
{ $values { "word" "要定义的新单词" } { "definition" "单词定义" } }
{ $description "在解析时将给定单词定义为记忆化单词，即给定特定输入时记忆化其输出。栈效果声明是必需的。" } ;

{ define-memoized POSTPONE: MEMO: } related-words
