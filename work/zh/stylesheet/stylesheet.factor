! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 样式表（Stylesheet）— 中文翻译文档
! 原始实现: D:\factor\basis\help\stylesheet\stylesheet.factor
!
USING: help.markup help.stylesheet help.syntax ;
IN: zh.stylesheet

ARTICLE: "stylesheet-zh" "帮助样式表"
"帮助样式表定义了帮助标记渲染引擎使用的样式。"
$nl
"样式包括："
{ $list
    { { $link heading-style } " — 用于标题" }
    { { $link strong-style } " — 用于粗体文本" }
    { { $link code-style } " — 用于代码块" }
    { { $link link-style } " — 用于超链接" }
    { { $link table-style } " — 用于表格" }
}
"这些样式由帮助标记渲染引擎在内部使用，但也可由自定义渲染器进行定制。" ;

ABOUT: "stylesheet-zh"
