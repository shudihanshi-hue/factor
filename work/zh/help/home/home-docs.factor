USING: help help.markup help.syntax ;
IN: help.home

ARTICLE: "help.home" "Factor handbook (Factor handbook)"
{ $heading "入门 (Getting started)" }
{ $subsections
    "zh-cookbook"
    "zh-tutorial"
    "zh-tour"
}
{ $heading "参考 (Reference)" }
{ $subsections
    "zh-language"
    "zh-io"
    "zh-ui"
    "zh-implementation"
    "zh-devtools"
    "zh-ui-tools"
    "zh-alien"
    "zh-vocabs"
}
{ $heading "索引 (Index)" }
{ $subsections
    "zh-vocab-index"
    "zh-article-index"
    "zh-primitive-index"
    "zh-error-index"
    "zh-class-index"
}
{ $heading "最近 (Recent)" }
{ $table
  { { $strong "单词 (Words)" } { $strong "文章" } { $strong "词汇表 (Vocabs)" } }
  { { $recent recent-words } { $recent recent-articles } { $recent recent-vocabs } }
} ;