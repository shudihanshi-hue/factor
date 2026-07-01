! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! UI 浏览器工具 — 中文翻译
! 原始文件: D:\factor\ui\tools\browser\browser.factor
!
! 注意：此文件仅提供中文帮助文章翻译
! 核心实现（包括命令映射、HELP 词条）保留在原始词汇库 ui.tools.browser 中

USING: help help.markup help.syntax kernel namespaces sequences ;
IN: zh.ui.tools.browser

! ===== 浏览器工具主文章 =====

ARTICLE: "ui-tools-browser-zh" "UI 浏览器工具"
"UI 浏览器工具提供了一个图形化的帮助浏览器窗口，支持完整的导航、搜索和交互功能。"
$nl
"主要特性："
{ $list
    "多标签浏览器窗口，支持历史记录前进/后退"
    "文章层级导航（父/上一篇/下一篇/首页）"
    "全文搜索和近似搜索集成"
    "可调节字体大小"
    "键盘快捷键完整支持"
    "多点触控和 Touch Bar 支持"
    "出站/入站链接查看"
}
$nl
"默认快捷键（Windows/Linux）："
{ $table
    { { $strong "快捷键" } { $strong "功能" } }
    { "Alt+Left / Alt+[" { "后退" } }
    { "Alt+Right / Alt+]" { "前进" } }
    { "Alt+Up" { "父文章" } }
    { "Alt+Home" { "帮助首页" } }
    { "F1" { "浏览器帮助" } }
    { "Ctrl+Alt+Plus" { "放大字体" } }
    { "Ctrl+Alt+Minus" { "缩小字体" } }
    { "Ctrl+Alt+0" { "恢复默认字体" } }
    { "F / Alt+F" { "聚焦搜索框" } }
    { "Page Up/Down" { "翻页滚动" } }
}
$nl
"macOS 快捷键："
{ $table
    { { $strong "快捷键" } { $strong "功能" } }
    { "Cmd+Opt+Left / Cmd+Opt+[" { "后退" } }
    { "Cmd+Opt+Right / Cmd+Opt+]" { "前进" } }
    { "Cmd+Opt+Up" { "父文章" } }
    { "Cmd+Opt+Home" { "帮助首页" } }
    { "F1" { "浏览器帮助" } }
    { "Cmd+Ctrl+Plus" { "放大字体" } }
    { "Cmd+Ctrl+Minus" { "缩小字体" } }
    { "Cmd+Ctrl+0" { "恢复默认字体" } }
}
$nl
"要打开浏览器，请在监听器中执行："
{ $code "browser-window" }
"或使用菜单栏的 Help > Browser 选项。" ;

ABOUT: "ui-tools-browser-zh"