! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: help.topics help.syntax help.markup ;
IN: help.crossref

HELP: article-children
{ $values { "topic" "一个文章名称或单词 (an article name or a word)" } { "seq" "一个新序列 (a new sequence)" } }
{ $description "输出 " { $snippet "topic" } " 所有子部分的序列。" } ;

HELP: article-parent
{ $values { "topic" "一个文章名称或单词 (an article name or a word)" } { "parent/f" "一个文章名称或单词 (an article name or a word)" } }
{ $description "输出将 " { $snippet "topic" } " 作为子部分包含在内的帮助主题，若不存在则输出 " { $link f } "。" } ;

HELP: help-path
{ $values { "topic" "一个文章名称或单词 (an article name or a word)" } { "seq" "一个新序列 (a new sequence)" } }
{ $description "输出所有将 " { $snippet "topic" } " 作为子部分包含在内的帮助文章的序列，一直向上遍历到根。输出一个序列，包含所有将给定主题作为子部分的帮助文章，从该主题向上穿过它们的父文章一直到根。" } ;

HELP: xref-article
{ $values { "topic" "一个文章名称或单词 (an article name or a word)" } }
{ $description "设置此文章每个子节的 " { $link article-parent } "。设置该文章每个子文章的父文章。" }
$low-level-note ;