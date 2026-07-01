USING: help help.topics help.markup help.syntax io strings ;
IN: help.vocabs

ARTICLE: "vocab-tags" "词汇标签 (Vocabulary tags)"
{ $all-tags } ;

ARTICLE: "vocab-authors" "词汇作者 (Vocabulary authors)"
{ $all-authors } ;

ARTICLE: "vocab-index" "词汇索引 (Vocabulary index)"
{ $subsections
    "vocab-tags"
    "vocab-authors"
}
{ $vocab "" } ;

HELP: words.
{ $values { "vocab" "一个词汇名称 (a vocabulary name)" } }
{ $description "按类型分类打印词汇中所有单词的列表。" } ;

HELP: about
{ $values { "vocab" "一个词汇标识符 (a vocabulary specifier)" } }
{ $description
    "显示该词汇的主帮助文章。主帮助文章通过 " { $link POSTPONE: ABOUT: } " 解析词来设置。"
} ;

ARTICLE: "browsing-help" "浏览文档 (Browsing documentation)"
"帮助主题是混入 (mixin) 的实例："
{ $subsections topic }
"最常见的情况是，主题是文章名字符串或单词。你可以显示特定的帮助主题："
{ $subsections help }
"你也可以显示某个词汇的帮助："
{ $subsections about }
"仅列出某个词汇中的单词："
{ $subsections words. }
{ $examples
  { $code "\"evaluator\" help" }
  { $code "\\ + help" }
  { $code "\"io.files\" about" }
} ;