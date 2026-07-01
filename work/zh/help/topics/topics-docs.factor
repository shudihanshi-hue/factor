USING: help help.crossref help.markup help.syntax io.styles
sequences strings words ;
IN: help.topics

HELP: articles
{ $var-description "哈希表，将文章名称映射到 " { $link article } " 实例 (Hashtable mapping article names to article instances)。" } ;

HELP: no-article
{ $values { "name" "一个文章名称 (an article name)" } }
{ $description "抛出一个 " { $link no-article } " 错误。" }
{ $error-description "当给定的帮助主题不存在，或者当前显示的帮助主题链接到了一个不存在的帮助主题时，由 " { $link help } " 抛出。" } ;

HELP: lookup-article
{ $values { "name" "一个文章名称 (an article name)" } { "article" "一个 " { $link article } " 对象 (an article object)" } }
{ $description "输出指定名称的 " { $link article } " 对象。" } ;

HELP: article-title
{ $values { "topic" "一个文章名称或单词 (an article name or a word)" } { "string" string } }
{ $description "输出特定帮助文章的标题。" } ;

HELP: article-content
{ $values { "topic" "一个文章名称或单词 (an article name or a word)" } { "content" "一个标记元素 (a markup element)" } }
{ $description "输出特定帮助文章的内容。" } ;

HELP: all-articles
{ $values { "seq" sequence } }
{ $description "输出所有帮助文章名称以及所有带文档的单词的序列 (Outputs a sequence of all help article names, and all words with documentation)。" } ;

HELP: elements
{ $values { "elt-type" word } { "element" "一个标记元素 (a markup element)" } { "seq" "一个新序列 (a new sequence)" } }
{ $description "输出通过遍历 " { $snippet "element" } " 找到的所有类型为 " { $snippet "elt-type" } " 的元素的序列。" } ;

HELP: collect-elements
{ $values { "element" "一个标记元素 (a markup element)" } { "seq" "一个单词序列 (a sequence of words)" } { "elements" "一个新序列 (a new sequence)" } }
{ $description "收集 " { $snippet "element" } " 中所有其标记元素类型出现在 " { $snippet "seq" } " 中的子元素的参数。" }
{ $notes "用于实现 " { $link article-children } "。" } ;

HELP: link
{ $class-description "帮助文章展现的类 (Class of help article presentations)。其实例可以传递给 " { $link write-object } " 来输出一个可点击的超链接。此外，此类的实例也是有效的定义标识符；参见 " { $link "definitions" } "。" } ;

HELP: related-words
{ $values { "seq" "一个单词序列 (a sequence of words)" } }
{ $description "定义一组相关单词。每个单词的文档将包含指向该集合中所有其他单词的链接。" } ;