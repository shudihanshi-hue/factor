! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 标记渲染引擎 — 中文翻译
! 原始文件: D:\factor\basis\help\markup\markup.factor
! 注意：此文件包含完整的标记渲染引擎实现的中文文档翻译。

USING: accessors arrays assocs combinators compiler.units
definitions.icons effects english hashtables help.stylesheet
help.topics io io.styles kernel make math namespaces present
prettyprint prettyprint.stylesheet quotations see sequences
sequences.private sets sorting splitting strings urls vocabs
words words.symbol ;
FROM: prettyprint.sections => with-pprint ;
IN: zh.markup

PREDICATE: simple-element < array
    [ t ] [ first word? not ] if-empty ;

SYMBOL: last-element
SYMBOL: span
SYMBOL: block
SYMBOL: blank-line

: last-span? ( -- ? ) last-element get span eq? ;
: last-block? ( -- ? ) last-element get block eq? ;
: last-blank-line? ( -- ? ) last-element get blank-line eq? ;

: ?nl ( -- )
    last-element get
    last-blank-line? not
    and [ nl ] when ;

: ($blank-line) ( -- )
    nl nl blank-line last-element namespaces:set ;

: ($span) ( quot -- )
    last-block? [ nl ] when
    span last-element namespaces:set
    call ; inline

GENERIC: print-element ( element -- )

M: simple-element print-element [ print-element ] each ;
M: string print-element [ write ] ($span) ;
M: array print-element unclip execute( arg -- ) ;
M: word print-element { } swap execute( arg -- ) ;
M: effect print-element effect>string print-element ;
M: f print-element drop ;

: print-element* ( element style -- )
    [ print-element ] with-style ;

: with-default-style ( quot -- )
    default-style get swap with-nesting ; inline

: print-content ( element -- )
    [ print-element ] with-default-style ;

: ($block) ( quot -- )
    ?nl
    span last-element namespaces:set
    call
    block last-element namespaces:set ; inline

! 一些行内元素

: $snippet ( children -- )
    [ snippet-style get print-element* ] ($span) ;

: $emphasis ( children -- )
    [ emphasis-style get print-element* ] ($span) ;

: $strong ( children -- )
    [ strong-style get print-element* ] ($span) ;

: $url ( children -- )
    [ ?second ] [ first ] bi [ or ] keep >url [
        dup present href associate url-style get assoc-union
        [ write-object ] with-style
    ] ($span) ;

: $nl ( children -- )
    drop nl last-element get [ nl ] when
    blank-line last-element namespaces:set ;

! 一些块元素
: ($heading) ( children quot -- )
    ?nl ($block) ; inline

: $heading ( element -- )
    [ heading-style get print-element* ] ($heading) ;

: $subheading ( element -- )
    [ strong-style get print-element* ] ($heading) ;

: ($code-style) ( presentation -- hash )
    presented associate code-style get assoc-union ;

: ($code) ( presentation quot -- )
    [
        last-element off
        [ ($code-style) ] dip with-nesting
    ] ($block) ; inline

: $code ( element -- )
    join-lines dup <input> [ write ] ($code) ;

: $syntax ( element -- ) "Syntax" $heading $code ;

: $description ( element -- )
    "单词描述" $heading print-element ;

: $class-description ( element -- )
    "类描述" $heading print-element ;

: $error-description ( element -- )
    "错误描述" $heading print-element ;

: $var-description ( element -- )
    "变量描述" $heading print-element ;

: $contract ( element -- )
    "泛型单词契约" $heading print-element ;

: $examples ( element -- )
    "示例" $heading print-element ;

: $example ( element -- )
    unclip-last [ join-lines ] dip over <input> [
        [ print ] [ output-style get format ] bi*
    ] ($code) ;

: $unchecked-example ( element -- )
    ! help-lint 会忽略这些。
    $example ;

: $markup-example ( element -- )
    first dup unparse " print-element" append 1array $code
    print-element ;

: $warning ( element -- )
    [
        warning-style get [
            last-element off
            "警告" $heading print-element
        ] with-nesting
    ] ($heading) ;

: $deprecated ( element -- )
    [
        deprecated-style get [
            last-element off
            "此单词已弃用" $heading print-element
        ] with-nesting
    ] ($heading) ;

! 图像

: $image ( element -- )
    [ first write-image ] ($span) ;

: <$image> ( path -- element )
    1array \ $image prefix ;

! 一些链接

<PRIVATE

: write-link ( string object -- )
    link-style get [ write-object ] with-style ;

: link-icon ( topic -- )
    definition-icon 1array $image ;

: link-text ( topic -- )
    [ article-name ] keep write-link ;

GENERIC: link-long-text ( topic -- )

M: topic link-long-text
    [ article-title ] keep write-link ;

GENERIC: link-effect? ( word -- ? )

M: parsing-word link-effect? drop f ;
M: symbol link-effect? drop f ;
M: word link-effect? drop t ;

: $effect ( effect -- )
    effect>string base-effect-style get format ;

M: word link-long-text
    dup presented associate [
        [ article-name link-style get format ]
        [
            dup link-effect? [
                bl stack-effect $effect
            ] [ drop ] if
        ] bi
    ] with-nesting ;

: >topic ( obj -- topic ) dup topic? [ >link ] unless ;

: topic-span ( topic quot -- ) [ >topic ] dip ($span) ; inline

! 将 "foo.bar" 转换为 { { "foo" } { "foo" "bar" } }
: vocab-breadcrumbs ( vocab -- vocab-list )
    "." split { } [ suffix ] accumulate* ;

ERROR: number-of-arguments found required ;

: check-first ( seq -- first )
    dup length 1 = [ length 1 number-of-arguments ] unless
    first-unsafe ;

: check-first2 ( seq -- first second )
    dup length 2 = [ length 2 number-of-arguments ] unless
    first2-unsafe ;

PRIVATE>

: ($link) ( topic -- ) [ link-text ] topic-span ;

: $link ( element -- ) check-first ($link) ;

: ($long-link) ( topic -- ) [ link-long-text ] topic-span ;

: $long-link ( element -- ) check-first ($long-link) ;

: ($pretty-link) ( topic -- )
    [ [ link-icon ] [ drop bl ] [ link-text ] tri ] topic-span ;

: $pretty-link ( element -- ) check-first ($pretty-link) ;

: ($long-pretty-link) ( topic -- )
    [ [ link-icon ] [ drop bl ] [ link-long-text ] tri ] topic-span ;

: <$pretty-link> ( definition -- element )
    1array \ $pretty-link prefix ;

: ($subsection) ( element quot -- )
    [
        subsection-style get [ call ] with-style
    ] ($block) ; inline

: $subsection* ( topic -- )
    [
        [ ($long-pretty-link) ] with-scope
    ] ($subsection) ;

: $subsections ( children -- )
    [ $subsection* ] each ($blank-line) ;

: $subsection ( element -- )
    check-first $subsection* ;

: ($vocab-breadcrumb-links) ( vocab -- )
    vocab-breadcrumbs
    [ "." write ] [ [ last ] [ "." join ] bi >vocab-link write-link ]
    interleave ;

: ($vocab-link) ( text vocab -- )
    ! 如果链接文本只是词汇表名称，则将其拆分为
    ! 每个父词汇表的单独链接。
    2dup = [ drop ($vocab-breadcrumb-links) ] [ >vocab-link write-link ] if ;

: $vocab-subsection ( element -- )
    [
        check-first2 dup vocab-help
        [ 2nip ($long-pretty-link) ]
        [ [ >vocab-link link-icon bl ] [ ($vocab-link) ] bi ]
        if*
    ] ($subsection) ;

: $vocab-subsections ( element -- )
    [ $vocab-subsection ] each ($blank-line) ;

: $vocab-link ( element -- )
    check-first [ vocab-name ] keep ($vocab-link) ;

: $vocabulary ( element -- )
    check-first vocabulary>> [
        "Vocabulary" $heading nl dup ($vocab-link)
    ] when* ;

: (textual-list) ( seq quot sep -- )
    '[ _ print-element ] swap interleave ; inline

: textual-list ( seq quot -- )
    ", " (textual-list) ; inline

: $links ( topics -- )
    [ [ ($link) ] textual-list ] ($span) ;

: $vocab-links ( vocabs -- )
    [ lookup-vocab ] map $links ;

: $breadcrumbs ( topics -- )
    [ [ ($link) ] " » " (textual-list) ] ($span) ;

: $see-also ( topics -- )
    "另请参阅" $heading $links ;

<PRIVATE
:: update-related-words ( words -- affected-words )
    words words [| affected word |
        word "related" [ affected union words ] change-word-prop
    ] reduce ;

:: clear-unrelated-words ( words affected-words -- )
    affected-words words diff
    [ "related" [ words diff ] change-word-prop ] each ;

: notify-related-words ( affected-words -- )
    fast-set notify-definition-observers ;

PRIVATE>

: related-words ( seq -- )
    dup update-related-words
    [ clear-unrelated-words ] [ notify-related-words ] bi ;

: $related ( element -- )
    check-first dup "related" word-prop remove
    [ $see-also ] unless-empty ;

: ($grid) ( style content-style quot -- )
    '[
        _ [ last-element off _ tabular-output ] with-style
    ] ($block) ; inline

: $list ( element -- )
    list-style get list-content-style get [
        [
            [
                bullet get write-cell
                [ print-element ] with-cell
            ] with-row
        ] each
    ] ($grid) ;

: $table ( element -- )
    table-style get table-content-style get [
        [
            [
                [ [ print-element ] with-cell ] each
            ] with-row
        ] each
    ] ($grid) ;

! for help-lint
ALIAS: $slot $snippet

: $slots ( children -- )
    [ unclip \ $slot swap 2array prefix ] map $table ;

: a/an ( str -- str )
    [ first ] [ length ] bi 1 =
    "afhilmnorsx" vowels ? member? "an" "a" ? ;

GENERIC: ($instance) ( element -- )

M: word ($instance) dup name>> a/an write bl ($link) ;

M: string ($instance) write ;

M: array ($instance) print-element ;

M: f ($instance) ($link) ;

: $instance ( element -- ) first ($instance) ;

: $or ( element -- )
    dup length {
        { 1 [ first ($instance) ] }
        { 2 [ first2 [ ($instance) " 或 " print-element ] [ ($instance) ] bi* ] }
        [
            drop
            unclip-last
            [ [ ($instance) ", " print-element ] each ]
            [ "或 " print-element ($instance) ]
            bi*
        ]
    } case ;

: $maybe ( element -- )
    f suffix $or ;

: $quotation ( element -- )
    check-first
    { "一个 " { $link quotation } " 具有栈效果 " }
    print-element $snippet ;

: ($instances) ( element -- )
    dup word? [ ($link) "s" print-element ] [ print-element ] if ;

: $sequence ( element -- )
    { "一个 " { $link sequence } " 的 " } print-element
    dup length {
        { 1 [ first ($instances) ] }
        { 2 [ first2 [ ($instances) " 或 " print-element ] [ ($instances) ] bi* ] }
        [
            drop
            unclip-last
            [ [ ($instances) ", " print-element ] each ]
            [ "或 " print-element ($instances) ]
            bi*
        ]
    } case ;

: values-row ( seq -- seq )
    unclip \ $snippet swap present 2array
    swap dup first word? [ \ $instance prefix ] when 2array ;

: ($values) ( element -- )
    [ [ "None" write ] ($block) ]
    [ [ values-row ] map $table ] if-empty ;

: $inputs ( element -- )
    "输入" $heading ($values) ;

: $outputs ( element -- )
    "输出" $heading ($values) ;

: $values ( element -- )
    "输入和输出" $heading ($values) ;

: $side-effects ( element -- )
    "副作用" $heading "修改 " print-element
    [ $snippet ] textual-list ;

: $errors ( element -- )
    "错误" $heading print-element ;

: $notes ( element -- )
    "注释" $heading print-element ;

: ($see) ( word quot -- )
    [ code-style get swap with-nesting ] ($block) ; inline

: $see ( element -- ) check-first [ see* ] ($see) ;

: $synopsis ( element -- ) check-first [ synopsis write ] ($see) ;

: $definition ( element -- )
    "定义" $heading $see ;

: $methods ( element -- )
    check-first methods [
        "方法" $heading
        [ see-all ] ($see)
    ] unless-empty ;

: $value ( object -- )
    "变量值" $heading
    "全局命名空间中的当前值:" print-element
    check-first dup [ pprint-short ] ($code) ;

: $curious ( element -- )
    "好奇者自行探索..." $heading print-element ;

: $references ( element -- )
    "参考" $heading
    unclip print-element [ \ $link swap ] map>alist $list ;

: $shuffle ( element -- )
    "这是一个栈操作单词，按其栈效果所示重新排列数据栈顶部的元素" swap
    ?first [ ": " swap "." 4array ] [ "." append ] if*
    $description ;

: $low-level-note ( children -- )
    drop
    "在大多数情况下直接调用此单词不是必需的。高层单词会自动调用它。" $notes ;

: $values-x/y ( children -- )
    drop { { "x" number } { "y" number } } $values ;

: $parsing-note ( children -- )
    drop
    "此单词仅应从解析单词中调用。"
    $notes ;

: $io-error ( children -- )
    drop
    "如果 I/O 操作失败则抛出错误。" $errors ;

: $prettyprinting-note ( children -- )
    drop {
        "此单词仅应从 "
        { $link with-pprint } " 组合子内部调用。"
    } $notes ;

: $content ( element -- )
    first article-content print-content nl ;

GENERIC: elements* ( elt-type element -- )

M: simple-element elements*
    [ elements* ] with each ;

M: object elements* 2drop ;

M: array elements*
    [ dup first \ $markup-example eq? [ 2drop ] [ [ elements* ] with each ] if ]
    [ [ first eq? ] 1check [ , ] [ drop ] if ] 2bi ;

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- elements )
    swap '[ [ _ elements* ] each ] { } make [ rest ] map concat ;

: <$link> ( topic -- element )
    1array \ $link prefix ;

: <$snippet> ( str -- element )
    1array \ $snippet prefix ;

: $definition-icons ( element -- )
    drop
    icons get sort-keys
    [ [ <$link> ] [ definition-icon-path <$image> ] bi* swap ] assoc-map
    { f { $strong "定义类" } } prefix
    $table ;