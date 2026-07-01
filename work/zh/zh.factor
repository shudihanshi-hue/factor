! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! D:\factor\work\zh\zh.factor
! 本文件是中文汉化包的主入口文件，负责协调并一键加载所有的汉化模块。

USING: io.files parser vocabs
       namespaces words quotations
       stack-checker stack-checker.backend stack-checker.errors
       words compiler.units definitions
       help.markup help.syntax continuations effects
       assocs math namespaces.private words.symbol
       fry continuations.private kernel.private lexer vectors
       memoize macros stack-checker.transforms
       ;
IN: zh

! 1. 自动编译并加载平铺在根目录下的核心实现文件 help.factor
! （注意：因为 help.factor 的命名空间也是 IN: zh，所以它属于同一个词汇库，需要用 run-file 来加载）
"D:/factor/work/zh/help/help.factor" run-file

! 加载中文帮助索引文章（zh-handbook, zh-cookbook, zh-tour 等条目定义）
"D:/factor/work/zh/help/help-zh.factor" run-file

! 加载中文帮助文档（help-zh, zh-browsing, zh-home 等条目定义）
"D:/factor/work/zh/help/help-zh-docs.factor" run-file

"zh.core.macros" require
"zh.core.vocabs" require

! 加载中文帮助首页（覆写英文 help.home ARTICLE，使首页链接指向中文文章）
! 注意：必须在所有 -zh 文章被加载后加载，否则会找不到中文文章 ID
"D:/factor/work/zh/help/home/home-docs.factor" run-file

! 2. 依次一键加载分散在各个子目录下的汉化子模块
"zh.handbook" require
"zh.cookbook" require
"zh.tour" require
"zh.tutorial" require

"zh.core.syntax" require
"zh.core.kernel" require
"zh.core.sequences" require
"zh.core.alien" require
"zh.core.combinators" require
"zh.core.combinators.short-circuit" require
"zh.core.effects" require
"zh.core.stack-checker" require
"zh.core.words" require
"zh.core.locals" require
"zh.core.namespaces" require
"zh.core.fry" require
"zh.core.continuations" require
"zh.core.destructors" require
"zh.core.memoize" require
"zh.core.parser" require
"zh.core.macros" require
"zh.core.vocabs" require

"zh.basis.ui" require
"zh.basis.ui-tools" require
"zh.basis.threads" require
"zh.ui.tools.browser" require

! ---------------------------------------------------------------
! 3. 非侵入式 UI 修复（状态栏中文本地化等）
! ---------------------------------------------------------------
"D:/factor/work/zh/fix/status-bar.factor" run-file

! ---------------------------------------------------------------
! 4. 其他汉化模块
! ---------------------------------------------------------------
"zh.html" require
"zh.lint" require
"zh.lint.checks" require
"zh.crossref" require
"zh.apropos" require
"zh.search" require
"zh.definitions" require
"zh.markup" require
"zh.syntax" require
"zh.stylesheet" require
"zh.tips" require
"zh.topics" require
"zh.vocabs" require
"zh.tools.test" require

! ... 今后您每汉化完并新建一个核心词汇库，都可以按照上面 require 的格式在这里追加一行
! 以上是gemini写的，可能有误，后来的agent需检查是否正确