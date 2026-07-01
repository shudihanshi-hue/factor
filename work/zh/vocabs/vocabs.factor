! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 词汇表浏览核心实现 — 中文翻译
! 原始文件: D:\factor\basis\help\vocabs\vocabs.factor
! 注意：此文件包含词汇表浏览核心实现的中文文档翻译。

USING: accessors arrays assocs classes classes.builtin
classes.error classes.intersection classes.mixin
classes.predicate classes.singleton classes.tuple classes.union
combinators effects generic help help.markup help.stylesheet
help.topics io io.pathnames io.styles kernel macros make
namespaces sequences sorting splitting summary vocabs
vocabs.files vocabs.hierarchy vocabs.loader vocabs.metadata
words words.symbol ;
IN: zh.vocabs

: about ( vocab -- )
    [ require ] [ lookup-vocab help ] bi ;

: vocab-row ( vocab -- row )
    [ <$pretty-link> ] [ vocab-summary ] bi 2array ;

: vocab-headings ( -- headings )
    {
        { $strong "词汇表" }
        { $strong "摘要" }
    } ;

: root-heading ( root -- )
    [ "Children from " prepend ] [ "Children" ] if*
    $heading ;

<PRIVATE
: convert-prefixes ( seq -- seq' )
    [ dup vocab-prefix? [ name>> <vocab-link> ] when ] map ;
PRIVATE>

: $vocabs ( seq -- )
    convert-prefixes [ vocab-row ] map vocab-headings prefix $table ;

: $vocab-roots ( assoc -- )
    [
        [ drop ] [ [ root-heading ] [ $vocabs ] bi* ] if-empty
    ] assoc-each ;

TUPLE: vocab-tag name ;

INSTANCE: vocab-tag topic

C: <vocab-tag> vocab-tag

: $tags ( seq -- ) [ <vocab-tag> ] map $links ;

TUPLE: vocab-author name ;

INSTANCE: vocab-author topic

C: <vocab-author> vocab-author

: $authors ( seq -- ) [ <vocab-author> ] map $links ;

: describe-help ( vocab -- )
    [
        [ vocab-help ]
        [ "文档" $heading ($link) ]
        [ "摘要" $heading vocab-summary print-element ]
        ?if
    ] unless-empty ;

: describe-children ( vocab -- )
    vocab-name disk-vocabs-for-prefix
    $vocab-roots ;

: files. ( seq -- )
    code-style get [
        [ nl ] [ [ string>> ] keep write-object ] interleave
    ] with-nesting ;

: describe-files ( vocab -- )
    vocab-files [ <pathname> ] map [
        "文件" $heading
        [
            files.
        ] ($block)
    ] unless-empty ;

: describe-metadata-files ( vocab -- )
    vocab-metadata-files [ <pathname> ] map [
        "元数据文件" $heading
        [
            files.
        ] ($block)
    ] unless-empty ;

: (describe-tuple-classes) ( classes heading -- )
    '[
        _ $subheading [
            [ <$pretty-link> ]
            [ superclass-of <$pretty-link> ]
            [ "slots" word-prop [ name>> ] map join-words <$snippet> ]
            tri 3array
        ] map
        { { $strong "类" } { $strong "父类" } { $strong "槽" } } prefix
        $table
    ] unless-empty ;

: describe-tuple-classes ( classes -- )
    [ error-class? ] partition
    [ "错误类" (describe-tuple-classes) ]
    [ "元组类" (describe-tuple-classes) ] bi* ;

: describe-predicate-classes ( classes -- )
    [
        "谓词类" $subheading
        [
            [ <$pretty-link> ]
            [ superclass-of <$pretty-link> ]
            bi 2array
        ] map
        { { $strong "类" } { $strong "父类" } } prefix
        $table
    ] unless-empty ;

: (describe-classes) ( classes heading -- )
    '[
        _ $subheading
        [ <$pretty-link> 1array ] map $table
    ] unless-empty ;

: describe-builtin-classes ( classes -- )
    "内建类" (describe-classes) ;

: describe-singleton-classes ( classes -- )
    "单例类" (describe-classes) ;

: describe-mixin-classes ( classes -- )
    "混入类" (describe-classes) ;

: describe-union-classes ( classes -- )
    "联合类" (describe-classes) ;

: describe-intersection-classes ( classes -- )
    "交集类" (describe-classes) ;

: describe-other-classes ( classes -- )
    [
        "其他类" $subheading
        [
            [ <$pretty-link> ]
            [ "metaclass" word-prop <$pretty-link> ]
            bi 2array
        ] map
        { { $strong "类" } { $strong "类类型" } } prefix
        $table
    ] unless-empty ;

: describe-classes ( classes -- )
    [ builtin-class? ] partition
    [ tuple-class? ] partition
    [ singleton-class? ] partition
    [ predicate-class? ] partition
    [ mixin-class? ] partition
    [ union-class? ] partition
    [ intersection-class? ] partition
    {
        [ describe-builtin-classes ]
        [ describe-tuple-classes ]
        [ describe-singleton-classes ]
        [ describe-predicate-classes ]
        [ describe-mixin-classes ]
        [ describe-union-classes ]
        [ describe-intersection-classes ]
        [ describe-other-classes ]
    } spread ;

: word-syntax ( word -- string/f )
    \ $syntax swap word-help elements dup length 1 =
    [ first second ] [ drop f ] if ;

: describe-parsing ( words -- )
    [
        "解析字" $subheading
        [
            [ <$pretty-link> ]
            [ word-syntax dup [ <$snippet> ] when ]
            bi 2array
        ] map
        { { $strong "字" } { $strong "语法" } } prefix
        $table
    ] unless-empty ;

: word-row ( word -- element )
    [ <$pretty-link> ]
    [ stack-effect dup [ effect>string <$snippet> ] when ]
    bi 2array ;

: word-headings ( -- element )
    { { $strong "字" } { $strong "栈效果" } } ;

: words-table ( words -- )
    [ word-row ] map word-headings prefix $table ;

: (describe-words) ( words heading -- )
    '[ _ $subheading words-table ] unless-empty ;

: describe-generics ( words -- )
    "泛型字" (describe-words) ;

: describe-macros ( words -- )
    "宏字" (describe-words) ;

: describe-primitives ( words -- )
    "原语" (describe-words) ;

: describe-compounds ( words -- )
    "普通字" (describe-words) ;

: describe-predicates ( words -- )
    "类谓词字" (describe-words) ;

: describe-symbols ( words -- )
    [
        "符号字" $subheading
        [ <$pretty-link> 1array ] map $table
    ] unless-empty ;

: $words ( words -- )
    [
        "字" $heading

        sort
        [ [ class? ] filter describe-classes ]
        [
            [ [ class? ] [ symbol? ] bi and ] reject
            [ parsing-word? ] partition
            [ generic? ] partition
            [ macro? ] partition
            [ symbol? ] partition
            [ primitive? ] partition
            [ predicate? ] partition swap
            {
                [ describe-parsing ]
                [ describe-generics ]
                [ describe-macros ]
                [ describe-symbols ]
                [ describe-primitives ]
                [ describe-compounds ]
                [ describe-predicates ]
            } spread
        ] bi
    ] unless-empty ;

: vocab-is-not-loaded ( vocab -- )
    "未加载" $heading
    "您必须先加载此词汇表以浏览其文档和字。"
    print-element vocab-name "USE: " prepend 1array $code ;

: describe-words ( vocab -- )
    {
        { [ dup lookup-vocab ] [ vocab-words $words ] }
        { [ dup find-vocab-root ] [ vocab-is-not-loaded ] }
        [ drop ]
    } cond ;

: words. ( vocab -- )
    last-element off
    [ require ] [ vocab-words $words ] bi nl ;

: describe-metadata ( vocab -- )
    [
        {
            [ "." split1-last [ '[ { "父词汇表:" { $vocab-link _ } } ] call , ] [ drop ] if ]
            [ vocab-tags [ "标签:" swap \ $tags prefix 2array , ] unless-empty ]
            [ vocab-authors [ "作者:" swap \ $authors prefix 2array , ] unless-empty ]
            [ vocab-platforms [ "平台:" swap \ $links prefix 2array , ] unless-empty ]
        } cleave
    ] { } make
    [ "元数据" $heading $table ] unless-empty ;

: $vocab ( element -- )
    first {
        [ describe-help ]
        [ describe-metadata ]
        [ describe-words ]
        [ describe-files ]
        [ describe-metadata-files ]
        [ describe-children ]
    } cleave ;

: keyed-vocabs ( str quot -- seq )
    [ all-disk-vocabs-recursive ] 2dip '[
        [ _ swap @ member? ] filter no-prefixes
        [ name>> ] sort-by
    ] assoc-map ; inline

: tagged ( tag -- assoc )
    [ vocab-tags ] keyed-vocabs ;

: authored ( author -- assoc )
    [ vocab-authors ] keyed-vocabs ;

: $tagged-vocabs ( element -- )
    first tagged $vocab-roots ;

: $authored-vocabs ( element -- )
    first authored $vocab-roots ;

: $all-tags ( element -- )
    drop "标签" $heading all-tags $tags ;

: $all-authors ( element -- )
    drop "作者" $heading all-authors $authors ;

INSTANCE: vocab topic

INSTANCE: vocab-link topic

M: vocab-spec valid-article? drop t ;

M: vocab-spec article-title vocab-name " vocabulary" append ;

M: vocab-spec article-name vocab-name ;

M: vocab-spec article-content
    vocab-name \ $vocab swap 2array ;

M: vocab-spec article-parent drop "vocab-index" ;

M: vocab-tag >link ;

M: vocab-tag valid-article? drop t ;

M: vocab-tag article-title
    name>> "Vocabularies tagged \"" "\"" surround ;

M: vocab-tag article-name name>> ;

M: vocab-tag article-content
    \ $tagged-vocabs swap name>> 2array ;

M: vocab-tag article-parent drop "vocab-tags" ;

M: vocab-tag summary article-title ;

M: vocab-author >link ;

M: vocab-author valid-article? drop t ;

M: vocab-author article-title
    name>> "Vocabularies by " prepend ;

M: vocab-author article-name name>> ;

M: vocab-author article-content
    \ $authored-vocabs swap name>> 2array ;

M: vocab-author article-parent drop "vocab-authors" ;

M: vocab-author summary article-title ;