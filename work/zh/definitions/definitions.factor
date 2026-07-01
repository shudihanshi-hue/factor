! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 定义协议（Definition Protocol）— 中文翻译文档
! 原始实现: D:\factor\basis\help\definitions\definitions.factor
!
USING: definitions editors help.markup help.syntax help.topics
kernel see ;
IN: zh.definitions

ARTICLE: "zh-definitions" "定义 (Definitions)"
"帮助系统的类型（" { $link link } " 和 " { $link word-link } "）实现了 Factor 的 " { $link "definitions" } " 协议。"
$nl
"这意味着帮助文章和字文档可以通过标准开发工具进行操作："
{ $list
    { { $link edit } " — 编辑某帮助主题的源文件" }
    { { $link see } " — 查看某帮助主题的定义" }
    { { $link forget } " — 移除某帮助主题" }
}
{ $subsections
    link
    word-link
} ;

ABOUT: "zh-definitions"
