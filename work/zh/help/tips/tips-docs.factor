USING: help help.markup help.syntax ;
IN: help.tips

HELP: TIP:
{ $syntax "TIP: content ;" }
{ $description "定义一个每日提示 (tip of the day)。它们会在启动时随机显示，也可以通过调用 " { $link "tips-of-the-day" } " 来查看。" }
{ $examples
  { $code
    "TIP: \"可以使用 'vocabs' 单词列出所有已加载的词汇表。\" ;"
  }
} ;

ARTICLE: "all-tips-of-the-day" "所有每日提示 (All tips of the day)"
{ $all-tips } ;

ARTICLE: "tips-of-the-day" "每日提示 (Tips of the day)"
"启动时显示的提示是 Factor 环境的一部分。它们在 \"tips\" 词汇表中定义。"
{ $subsections
    POSTPONE: TIP:
    "all-tips-of-the-day"
}
{ $examples
  { $code "\"tips-of-the-day\" help" }
  { $code "\\ TIP: help" }
} ;