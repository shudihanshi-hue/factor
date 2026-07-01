! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 文章搜索（Article Search）— 中文翻译文档
! 原始实现: D:\factor\basis\help\search\search.factor
!
USING: help.apropos help.markup help.search help.syntax strings
;
IN: zh.search

HELP: search-articles
{ $values { "string" string } }
{ $description "搜索所有帮助文章，查找包含给定搜索字符串的文章。结果按相关性排序并显示。" } ;

ARTICLE: "zh-search" "帮助搜索 (Search)"
"帮助搜索系统提供了对文章和字文档的全文搜索功能。核心字是 " { $link search-articles } " 和 " { $link apropos } "。"
$nl
"搜索系统将文章内容分词，构建字索引（" { $snippet "article-words" } "），并支持通过查询字符串在全部文章中搜索。" ;

ABOUT: "zh-search"
