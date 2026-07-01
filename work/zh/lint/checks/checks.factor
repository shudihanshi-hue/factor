! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 帮助检查实现（Lint Checks）— 中文翻译
! 原始文件: D:\factor\basis\help\lint\checks\checks.factor
! 注意：此文件包含检查实现的中文文档翻译。

USING: accessors arrays assocs classes classes.struct
classes.tuple combinators combinators.short-circuit debugger
definitions effects eval formatting grouping help help.markup
help.topics io io.streams.string kernel macros math
math.statistics namespaces prettyprint sequences sequences.deep
sets splitting strings summary tools.destructors unicode vocabs
vocabs.loader words words.constant words.symbol ;
IN: zh.lint.checks

ERROR: simple-lint-error message ;

M: simple-lint-error summary message>> ;

M: simple-lint-error error. summary print ;

SYMBOL: vocabs-quot
SYMBOL: vocab-articles

: no-ui-disposables ( seq -- seq' )
    [
        class-of name>> {
            "single-texture" "multi-texture" ! opengl.textures
            "line" ! core-text
            "layout" ! ui.text.pango
            "script-string" ! windows.uniscribe
            "linux-monitor" ! github issue #2014, race condition in disposing of child monitors
            "event-stream"
            "macos-monitor"
            "recursive-monitor"
            "input-port"
            "malloc-ptr"
            "fd"
            "win32-file"
            "win32-monitor"
            "win32-monitor-port"
        } member?
    ] reject ;

: check-example ( element -- )
    [
        '[
            _ rest [
                but-last join-lines
                (eval-with-stack>string)
                "\n" ?tail drop
            ] keep
            last assert=
        ] vocabs-quot get call( quot -- )
    ] leaks members no-ui-disposables
    dup length 0 > [
        dup [ class-of ] histogram-by
        [ "泄漏的资源: " write ... ] with-string-writer simple-lint-error
    ] [
        drop
    ] if ;

: check-examples ( element -- )
    \ $example swap elements [ check-example ] each ;

: extract-values ( element -- seq )
    \ $values swap elements
    [ f ] [ first rest keys ] if-empty ;

: extract-value-effects ( element -- seq )
    \ $values swap elements [ f ] [
        first rest [
            \ $quotation swap elements [ f ] [
                first second dup effect? [ effect>string ] when
            ] if-empty
        ] map
    ] if-empty ;

: effect-values ( word -- seq )
    stack-effect
    [ in>> ] [ out>> ] bi append
    [ dup pair? [ first ] when effect>string ] map members ;

: effect-effects ( word -- seq )
    stack-effect in>> [
        dup pair?
        [ second dup effect? [ effect>string ] [ drop f ] if ]
        [ drop f ] if
    ] map ;

: contains-funky-elements? ( element -- ? )
    {
        $shuffle
        $values-x/y
        $predicate
        $class-description
        $error-description
    } swap '[ _ elements empty? not ] any? ;

: don't-check-word? ( word -- ? )
    {
        [ macro? ]
        [ symbol? ]
        [ parsing-word? ]
        [ "declared-effect" word-prop not ]
        [ constant? ]
        [ "help" word-prop not ]
    } 1|| ;

: skip-check-values? ( word element -- ? )
    [ don't-check-word? ] [ contains-funky-elements? ] bi* or ;

: check-values ( word element -- )
    2dup skip-check-values? [ 2drop ] [
        [ effect-values ] [ extract-values ] bi* 2dup
        sequence= [ 2drop ] [
            "$values 与栈效果不匹配；期望 %u ，得到 %u" sprintf
            simple-lint-error
        ] if
    ] if ;

: check-value-effects ( word element -- )
    [ effect-effects ] [ extract-value-effects ] bi*
    [ 2dup and [ = ] [ 2drop t ] if ] 2all? [
        "$quotation 中的栈效果在 $values 中不匹配"
        simple-lint-error
    ] unless ;

: check-see-also ( element -- )
    \ $see-also swap elements [ rest all-unique? ] all?
    [ "$see-also 包含重复条目" simple-lint-error ] unless ;

: check-modules ( element -- )
    \ $vocab-link swap elements [
        second
        dup vocab-exists? [ drop ] [
            "$vocab-link 指向不存在的词汇表 '" "'" surround
            simple-lint-error
        ] if
    ] each ;

: check-slots-tables ( element -- )
    \ $slots swap elements [ rest [ length 2 = ] all?  ] all?
    [ "$slots 至少有一行包含过多的值" simple-lint-error ] unless ;

: check-rendering ( element -- )
    [ print-content ] with-string-writer drop ;

: check-strings ( str -- )
    [
        "\n\t" intersects? [
            "段落文本不应包含 \\n 或 \\t"
            simple-lint-error
        ] when
    ] [
        "  " subseq-of? [
            "段落文本不应包含双空格"
            simple-lint-error
        ] when
    ] bi ;

: check-whitespace ( str1 str2 -- )
    2dup [ ?last " (" member? ] [ ?first " ).,;:" member? ] bi* or
    [ 2drop ] [
        "字符串 ``%s'' 和 ``%s'' 之间缺少空白字符"
        sprintf simple-lint-error
    ] if ;

: check-bogus-nl ( element -- )
    { { $nl } { { $nl } } } [ head? ] with any? [
        "简单元素不应以段落分隔开始"
        simple-lint-error
    ] when ;

: extract-slots ( elements -- seq )
    [ dup pair? [ first \ $slot = ] [ drop f ] if ] deep-filter
    [ second ] map ;

: check-class-description ( word element -- )
    \ $class-description swap elements over class? [
        [
            dup struct-class? [ struct-slots ] [ all-slots ] if
            [ name>> ] map
        ] [ extract-slots ] bi*
        [ swap member? ] with reject [
            ", " join "描述的 $slot 不存在: " prepend
            simple-lint-error
        ] unless-empty
    ] [
        nip empty? not [
            "非类单词具有 $class-description"
            simple-lint-error
        ] when
    ] if ;

: check-article-title ( article -- )
    article-title first LETTER?
    [ "文章标题必须以大写字母开头" simple-lint-error ] unless ;

: check-elements ( element -- )
    {
        [ check-bogus-nl ]
        [ [ string? ] filter [ check-strings ] each ]
        [ [ simple-element? ] filter [ check-elements ] each ]
        [ 2 <clumps> [ [ string? ] all? ] filter [ first2 check-whitespace ] each ]
    } cleave ;

: check-descriptions ( element -- )
    { $description $class-description $var-description }
    swap '[
        _ elements [
            rest { { } { "" } } member?
            [ "空的 $description" simple-lint-error ] when
        ] each
    ] each ;

: check-markup ( element -- )
    {
        [ check-elements ]
        [ check-rendering ]
        [ check-examples ]
        [ check-modules ]
        [ check-descriptions ]
        [ check-slots-tables ]
    } cleave ;

: files>vocabs ( -- assoc )
    loaded-vocab-names
    [ [ [ vocab-docs-path ] keep ] H{ } map>assoc ]
    [ [ [ vocab-source-path ] keep ] H{ } map>assoc ]
    bi assoc-union ;

: group-articles ( -- assoc )
    articles get keys
    files>vocabs
    H{ } clone [
        '[
            dup >link where dup
            [ first _ at _ push-at ] [ 2drop ] if
        ] each
    ] keep ;

: all-word-help ( words -- seq )
    [ word-help ] filter ;