! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 单词（Words）— 中文翻译
! 原始文件: D:\factor\core\words\words-docs.factor

USING: classes compiler.units definitions effects help.markup
help.syntax kernel parser quotations sequences strings vocabs words ;
IN: zh.core.words

ARTICLE: "interned-words-zh" "查找与创建单词"
"如果一个单词是其词汇槽（vocabulary slot）所命名的词汇的成员，则称该单词是" { $emphasis "已驻留的（interned）" } "。否则，该单词是" { $emphasis "未驻留的（uninterned）" } "。"
$nl
"在解析时名称就已确定的单词——即构成程序的大多数单词——可以在源代码中直接通过名称引用。然而，解析器本身以及你编写的某些代码，有时需要动态地查找单词。"
$nl
"解析词（parsing words）将定义添加到当前词汇中。当源文件被解析时，当前词汇最初设置为 " { $vocab-link "scratchpad" } "。可以使用 " { $link POSTPONE: IN: } " 解析词来更改当前词汇（参见 " { $link "word-search" } "）。"
{ $subsections
    create-word
    create-word-in
    lookup-word
} ;

ARTICLE: "uninterned-words-zh" "未驻留的单词"
"不属于任何词汇的单词被称为" { $emphasis "未驻留的（uninterned）" } "单词。"
$nl
"创建未驻留单词有以下几种方式："
{ $subsections
    <word>
    <uninterned-word>
    gensym
    define-temp
    define-temp-syntax
} ;

ARTICLE: "colon-definition-zh" "冒号定义（Colon Definitions）"
"所有单词都有与之关联的定义" { $link "quotations" } "。单词的定义引用在单词执行时被调用。" { $emphasis "冒号定义（colon definition）" } "是指由用户直接提供该引用的单词。这是最简单也最常见的单词定义类型。"
$nl
"在解析时定义单词："
{ $subsections
    POSTPONE: :
    POSTPONE: ;
}
"在运行时定义单词："
{ $subsections
    define
    define-declared
    define-inline
    define-syntax
}
"单词定义必须声明其栈效果（stack effect）。参见 " { $link "effects" } "。"
$nl
"所有其他类型的单词定义，如 " { $link "words.symbol" } " 和 " { $link "generic" } "，都是上述定义方式的特例。" ;

ARTICLE: "primitives-zh" "原语（Primitives）"
"原语是在 Factor 虚拟机中定义的单词。它们为系统的其余部分提供基本的底层服务。"
{ $subsections
    primitive
    primitive?
} ;

ARTICLE: "deferred-zh" "延迟定义与互递归"
"单词不能在定义之前被引用；也就是说，源文件必须严格按照自底向上的顺序排列定义。这样做是为了简化实现、改善解析时检查以及消除一些奇怪的边界情况；同时也有助于培养更好的编码风格。"
$nl
"有时这种限制会造成不便，例如在定义互递归（mutually-recursive）单词时；绕过此限制的一种方法是使用前向声明（forward definition）。"
{ $subsections POSTPONE: DEFER: }
"延迟定义的单词类："
{ $subsections
    deferred
    deferred?
}
"延迟单词在被调用时会抛出错误："
{ $subsections undefined }
"延迟单词实际上是复合定义的伪装。以下两行是等价的："
{ $code
    "DEFER: foo"
    ": foo ( -- * ) undefined ;"
} ;

ARTICLE: "declarations-zh" "编译器声明"
"编译器声明是解析词，它们在最近定义的单词上设置一个单词属性。它们出现在单词定义的最后一个 " { $link POSTPONE: ; } " 之后："
{ $code ": cubed ( x -- y ) dup dup * * ; foldable" }
"编译器声明断言该单词遵循某种约定（contract），从而启用一般情况下不适用的优化。"
{ $subsections
    POSTPONE: inline
    POSTPONE: foldable
    POSTPONE: flushable
    POSTPONE: recursive
}
"确保单词满足声明的约定完全是程序员的职责。此外，如果一个泛型单词被声明为 " { $link POSTPONE: foldable } " 或 " { $link POSTPONE: flushable } "，则其所有方法都必须满足该约定。如果单词不遵循其声明的约定，可能导致未定义行为。"
{ $see-also "effects" } ;

ARTICLE: "word-props-zh" "单词属性"
"每个单词都有一个属性哈希表。"
{ $subsections
    word-prop
    set-word-prop
}
"上述两个单词的栈效果设计使得当 " { $snippet "name" } " 是在执行此单词之前直接压入栈的字面量时，使用最为方便。"
$nl
"以下是一些由库使用的属性："
{ $table
  { { $strong "属性" } { $strong "文档" } }
  {
      { $snippet "\"declared-effect\"" } { $link "effects" }
  }
  {
      {
          { $snippet "\"inline\"" } "、"
          { $snippet "\"foldable\"" } "、"
          { $snippet "\"flushable\"" } "、"
          { $snippet "\"recursive\"" }
      }
      { $link "declarations" }
  }
  {
      {
          { $snippet "\"help\"" } "、"
          { $snippet "\"help-loc\"" } "、"
          { $snippet "\"help-parent\"" }
      }
      { "单词帮助信息的存储位置 — " { $link "writing-help" } }
  }
  {
      { $snippet "\"intrinsic\"" }
      { "编译器在 CFG 构建期间运行的引用，用于内联发出该单词。" }
  }
  {
      { $snippet "\"loc\"" }
      { "位置信息 — " { $link where } }
  }
  {
      { { $snippet "\"methods\"" } "、" { $snippet "\"combination\"" } }
      { "设置在泛型单词上 — " { $link "generic" } }
  }
  {
      {
          { $snippet "\"outputs\"" } "、"
          { $snippet "\"input-classes\"" } "、"
          { $snippet "\"default-output-classes\"" }
      }
      { "编译期间值传播步骤使用的一组元数据，用于生成类型优化的代码。" }
  }
  {
      { $snippet "\"parsing\"" }
      { $link "parsing-words" }
  }
  {
      { $snippet "\"predicating\"" }
      "设置在类谓词上，存储对应的类单词。"
  }
  {
      { { $snippet "\"reading\"" } "、" { $snippet "\"writing\"" } }
      { "设置在槽位访问器单词上 — " { $link "slots" } }
  }
  {
      { $snippet "\"specializer\"" }
      { $link "hints" }
  }
  {
      {
          { $snippet "\"dependencies\"" }
      }
      { "优化编译器在遗忘单词时用于快速依赖查找。参见 " { $link "compilation-units" } "。" }
  }
  {
      { $snippet "\"generic-call-sites\"" }
      { "设置在某些泛型单词上。" }
  }
}
"仅用于类的属性："
{ $table
    { { $strong "属性" } { $strong "文档" } }
    { { $snippet "\"class\"" } { "表示此单词是否为类的布尔值 — " { $link "classes" } } }

    { { $snippet "\"coercer\"" } { "用于将栈顶转换为该类实例的引用" } }

    { { $snippet "\"constructor\"" } { $link "tuple-constructors" } }

    { { $snippet "\"type\"" } { $link "builtin-classes" } }

    { { { $snippet "\"superclass\"" } "、" { $snippet "\"predicate-definition\"" } } { $link "predicates" } }

    { { $snippet "\"members\"" } { { $link "unions" } "、" { $link "maybes" } } }
    {
        { $snippet "\"instances\"" }
        { "列出混入类（mixin）的实例及其定义位置 — " { $link "mixins" } }
    }
    {
        { $snippet "\"predicate\"" }
        { "测试栈顶是否为该类实例的引用 — " { $link "class-predicates" } }
    }
    { { $snippet "\"slots\"" } { $link "slots" } }
    {
        {
            { $snippet "\"superclass\"" } "、"
            { $snippet "\"predicate-definition\"" }
        }
        { $link "predicates" }
    }
    { { $snippet "\"type\"" } { $link "builtin-classes" } }
} ;

ARTICLE: "word.private-zh" "单词实现细节"
"单词的 " { $snippet "def" } " 槽持有一个 " { $link quotation } " 实例，在单词执行时被调用。"
$nl
"获取存储单词机器码的内存范围的原语："
{ $subsections word-code } ;

ARTICLE: "words.introspection-zh" "单词内省"
"单词内省工具和实现细节可在 " { $vocab-link "words" } " 词汇中找到。"
$nl
"单词对象包含以下槽位："
{ $table
    { { $snippet "name" } "单词名称" }
    { { $snippet "vocabulary" } "单词所属词汇名称" }
    { { $snippet "def" } "定义引用" }
    { { $snippet "props" } "单词属性的关联映射，包括文档和其他元数据" }
}
"单词是一个类的实例。"
{ $subsections
    word
    word?
}
"单词实现了定义协议（definition protocol）；参见 " { $link "definitions" } "。"
{ $subsections
    "interned-words"
    "uninterned-words"
    "word-props"
    "word.private"
} ;

ARTICLE: "words-zh" "单词与词汇 (Words)"
"单词（Words）是 Factor 中相当于其他语言中函数或过程的概念。单词本质上是命名的" { $link "quotations" } "。"
$nl
"创建单词定义有两种方式："
{ $list
    "在解析时使用解析词。"
    "在运行时使用定义词。"
}
"后者是一种更动态的特性，可用于实现代码生成等功能；事实上，解析时的定义词就是在运行时定义词的基础上实现的。"
$nl
"单词类型："
{ $subsections
    "colon-definition"
    "words.symbol"
    "words.alias"
    "words.constant"
    "primitives"
}
"高级主题："
{ $subsections
    "deferred"
    "declarations"
    "words.introspection"
    "word-props"
}
{ $see-also "vocabularies" "vocabs.loader" "definitions" "see" } ;

ABOUT: "words-zh"

HELP: changed-effect
{ $values { "word" word } }
{ $description "向编译单元发出信号，表明该单词的栈效果已发生改变。这会导致所有依赖于它的单词被重新编译。" }
{ $see-also changed-effects } ;

HELP: deferred
{ $class-description "由 " { $link POSTPONE: DEFER: } " 创建的延迟单词的类。" } ;

{ deferred POSTPONE: DEFER: } related-words

HELP: undefined
{ $error-description "此错误在两种情况下抛出，调试器的摘要消息会反映原因："
    { $list
        { "单词在编译完成之前被执行。例如，当一个宏在与使用它的同一编译单元中定义时可能会发生这种情况。参见 " { $link "compilation-units" } "的讨论。" }
        { "使用 " { $link POSTPONE: DEFER: } " 定义的单词被执行。由于此语法通常用于互递归单词定义，执行延迟单词通常表示程序员的错误。" }
    }
} ;

HELP: primitive
{ $class-description "原语单词的类。" } ;

HELP: word-prop
{ $values { "word" word } { "name" "属性名称" } { "value" "属性值" } }
{ $description "获取单词属性。单词属性名称按惯例使用字符串。" } ;

HELP: set-word-prop
{ $values { "word" word } { "value" "属性值" } { "name" "属性名称" } }
{ $description "存储单词属性。单词属性名称按惯例使用字符串。" }
{ $side-effects "word" } ;

HELP: remove-word-prop
{ $values { "word" word } { "name" "属性名称" } }
{ $description "移除单词属性，使后续查找输出 " { $link f } "，直到再次设置。单词属性名称按惯例使用字符串。" }
{ $side-effects "word" } ;

HELP: remove-word-props
{ $values { "word" word } { "seq" { $sequence "单词属性名称" } } }
{ $description "从单词中移除所有列出的属性。" }
{ $side-effects "word" } ;

HELP: word-code
{ $values { "word" word } { "start" "单词的起始地址" } { "end" "单词的结束地址" } }
{ $description "输出包含单词机器码的内存范围。" } ;

HELP: define
{ $values { "word" word } { "def" quotation } }
{ $description "定义单词使其在执行时调用一个引用。这是 " { $link POSTPONE: : } " 的运行时等价物。" }
{ $notes "此单词必须在 " { $link with-compilation-unit } " 内部调用。" }
{ $side-effects "word" } ;

HELP: reset-word
{ $values { "word" word } }
{ $description "重置单词声明。" }
$low-level-note
{ $side-effects "word" } ;

HELP: reset-generic
{ $values { "word" word } }
{ $description "重置单词声明和泛型单词属性。" }
$low-level-note
{ $side-effects "word" } ;

HELP: <word>
{ $values { "name" string } { "vocab" string } { "word" word } }
{ $description "分配一个具有指定名称和词汇的单词。用户代码应调用 " { $link <uninterned-word> } " 来创建未驻留单词，调用 " { $link create-word } " 来创建已驻留单词，而不是直接调用此构造器。" }
{ $notes "此单词必须在 " { $link with-compilation-unit } " 内部调用。" } ;

HELP: <uninterned-word>
{ $values { "name" string } { "word" word } }
{ $description "创建一个具有指定名称的未驻留单词，该单词不等于系统中的任何其他单词。" }
{ $notes "与 " { $link create-word } " 不同，此单词不必在 " { $link with-compilation-unit } " 内部调用。" } ;

HELP: gensym
{ $values { "word" word } }
{ $description "创建一个不等于系统中任何其他单词的未驻留单词。" }
{ $examples { $example "USING: prettyprint words ;"
    "gensym ."
    "( gensym )"
    }
}
{ $notes "与 " { $link create-word } " 不同，此单词不必在 " { $link with-compilation-unit } " 内部调用。" } ;

HELP: bootstrapping?
{ $var-description "由库在引导（bootstrap）过程中设置。某些解析词在引导期间需要表现不同的行为。" } ;

HELP: last-word
{ $values { "word" word } }
{ $description "输出最近定义的单词。" } ;

HELP: word
{ $class-description "单词的类。一个值得注意的子类是 " { $link class } "，即类单词的类。" } ;

{ last-word set-last-word save-location } related-words

HELP: set-last-word
{ $values { "word" word } }
{ $description "设置最近定义的单词。" } ;

HELP: lookup-word
{ $values { "name" string } { "vocab" string } { "word" { $maybe word } } }
{ $description "在字典中查找单词。如果词汇或单词未定义，输出 " { $link f } "。" } ;

HELP: reveal
{ $values { "word" word } }
{ $description "将新创建的单词添加到字典中。通常不需要直接调用此单词，它仅作为 " { $link create-word } " 的一部分被调用。" } ;

HELP: check-create
{ $values { "name" string } { "vocab" string } }
{ $description "如果 " { $snippet "name" } " 或 " { $snippet "vocab" } " 不是字符串，则抛出 " { $link check-create } " 错误。" }
{ $error-description "当 " { $link create-word } " 被无效参数调用时抛出。" } ;

HELP: create-word
{ $values { "name" string } { "vocab" string } { "word" word } }
{ $description "创建一个新单词。如果词汇中已包含具有请求名称的单词，则输出已有单词。词汇必须事先存在；如果不存在，必须先调用 " { $link create-vocab } "。" }
{ $notes "此单词必须在 " { $link with-compilation-unit } " 内部调用。解析词应调用 " { $link create-word-in } " 而不是此单词。" } ;

{ POSTPONE: FORGET: forget forget* forget-vocab } related-words

HELP: target-word
{ $values { "word" word } { "target" word } }
{ $description "查找与给定单词具有相同名称和词汇的单词。在引导期间用于将宿主单词转移到目标字典。" } ;

HELP: bootstrap-word
{ $values { "word" word } { "target" word } }
{ $description "查找与给定单词具有相同名称和词汇的单词，并执行转换以处理目标字典中的解析词。在引导期间用于将宿主单词转移到目标字典。" } ;

HELP: parsing-word?
{ $values { "object" object } { "?" boolean } }
{ $description "测试对象是否为由 " { $link POSTPONE: SYNTAX: } " 声明的解析词。" }
{ $notes "如果对象不是单词，则输出 " { $link f } "。" } ;

HELP: define-declared
{ $values { "word" word } { "def" quotation } { "effect" effect } }
{ $description "定义单词并声明其栈效果。" }
{ $notes "此单词必须在 " { $link with-compilation-unit } " 内部调用。" }
{ $side-effects "word" } ;

HELP: define-temp
{ $values { "quot" quotation } { "effect" effect } { "word" word } }
{ $description "创建一个在执行时将调用 " { $snippet "quot" } " 的未驻留单词。" }
{ $notes
    "以下两种写法是等价的："
    { $code "[ 2 2 + . ] call" }
    { $code "[ 2 2 + . ] ( -- ) define-temp execute" }
    "此单词必须在 " { $link with-compilation-unit } " 内部调用。"
} ;

HELP: define-syntax
{ $values { "word" word } { "quot" quotation } }
{ $description "定义一个解析词。" }
{ $notes
    "此单词必须在 " { $link with-compilation-unit } " 内部调用。"
} ;

HELP: define-temp-syntax
{ $values { "quot" quotation } { "word" word } }
{ $description "创建一个在执行时将调用 " { $snippet "quot" } " 的未驻留解析词。" }
{ $notes
    "此单词必须在 " { $link with-compilation-unit } " 内部调用。"
} ;

HELP: delimiter?
{ $values { "obj" object } { "?" boolean } }
{ $description "测试对象是否为由 " { $link POSTPONE: delimiter } " 声明的定界符单词。" }
{ $notes "如果对象不是单词，则输出 " { $link f } "。" } ;

HELP: deprecated?
{ $values { "obj" object } { "?" boolean } }
{ $description "测试对象是否被标记为 " { $link POSTPONE: deprecated } "。" }
{ $notes "如果对象不是单词，则输出 " { $link f } "。" } ;

HELP: inline?
{ $values { "obj" object } { "?" boolean } }
{ $description "测试对象是否被标记为 " { $link POSTPONE: inline } "。" }
{ $notes "如果对象不是单词，则输出 " { $link f } "。" } ;

HELP: subwords
{ $values { "word" word } { "seq" sequence } }
{ $description "列出给定单词的所有特化（specialization）。" }
{ $examples
  { $example
    "USING: math.functions prettyprint words ;"
    "\\ sin subwords ."
    "{ M\\ object sin M\\ complex sin M\\ real sin M\\ float sin }"
  }
}
{ $notes "如果单词不是泛型单词，则输出 " { $link f } "。" } ;

HELP: make-deprecated
{ $values { "word" word } }
{ $description "将单词声明为 " { $link POSTPONE: deprecated } "。" }
{ $side-effects "word" } ;

HELP: make-flushable
{ $values { "word" word } }
{ $description "将单词声明为 " { $link POSTPONE: flushable } "。" }
{ $side-effects "word" } ;

HELP: make-foldable
{ $values { "word" word } }
{ $description "将单词声明为 " { $link POSTPONE: foldable } "。" }
{ $side-effects "word" } ;

HELP: make-inline
{ $values { "word" word } }
{ $description "将单词声明为 " { $link POSTPONE: inline } "。" }
{ $side-effects "word" } ;

HELP: define-inline
{ $values { "word" word } { "def" quotation } { "effect" effect } }
{ $description "定义单词并将其标记为 " { $link POSTPONE: inline } "。" }
{ $notes "此单词必须在 " { $link with-compilation-unit } " 内部调用。" }
{ $side-effects "word" } ;
