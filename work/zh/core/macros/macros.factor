! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 宏（Macros）— 中文翻译
! 原始文件: D:\factor\core\macros\macros-docs.factor

USING: help.markup help.syntax kernel
stack-checker.transforms combinators macros ;
IN: zh.core.macros

HELP: MACRO:
{ $syntax "MACRO: word ( inputs... -- quot ) definition... ;" }
{ $description "定义一个宏单词。定义必须具有栈效果 " { $snippet "( inputs... -- quot )" } "。" }
{ $notes
  "单词定义中对宏的调用会在编译时被替换为引用展开。必须满足以下两个条件："
  { $list
    { "宏调用的所有输入必须是字面量" }
    { "宏产生的展开引用具有静态栈效果" }
  }
  "宏允许将计算从运行时移至编译时，将计算结果拼接进生成的引用中。"
}
{ $examples
  "一个宏，调用引用但保留它从栈上消费的任何值："
  { $code
    "USING: fry generalizations kernel macros stack-checker ;"
    "MACRO: preserving ( quot -- quot' )"
    "    [ inputs ] keep '[ _ ndup @ ] ;"
  }
  "使用此宏，我们可以定义 " { $link if } " 的一个变体，它接受谓词引用而非布尔值；谓词引用消费的任何值在之后立即恢复："
  { $code
    ": ifte ( pred true false -- ) [ preserving ] 2dip if ; inline"
  }
  "注意 " { $snippet "ifte" } " 是一个普通单词，它将其中一个输入传递给宏。如果另一个单词以全部三个输入引用为字面量的方式调用 " { $snippet "ifte" } "，则 " { $snippet "ifte" } " 将被内联，" { $snippet "preserving" } " 将在编译时展开，生成的机器代码将与手动复制谓词消费的输入完全相同。"
  $nl
  "这里展示的 " { $snippet "ifte" } " 组合子具有与 Joy 编程语言的 " { $snippet "ifte" } " 组合子类似的语义。"
} ;

HELP: macro
{ $class-description "由 " { $link POSTPONE: MACRO: } " 定义的单词的类。" } ;

ARTICLE: "macros-zh" "宏 (Macros)"
"" { $vocab-link "macros" } " 词汇实现了" { $emphasis "宏" } "，即在适当情况下可在编译时运行的代码变换。"
$nl
"宏可用于实现栈效果取决于输入参数的组合子。由于宏在编译时展开，这允许编译器为调用宏的单词推导出静态栈效果。"
$nl
"宏还可用于在编译时计算查找表和生成代码，这可以提高性能、提升抽象层次并简化代码。"
$nl
"Factor 宏类似于 Lisp 宏；而非 C 预处理器宏。"
$nl
"定义新宏："
{ $subsections POSTPONE: MACRO: }
"一个稍底层的机制——" { $emphasis "编译器变换（compiler transforms）" } "，允许普通单词定义与执行编译时展开的版本共存。普通定义仅在使用非优化编译器编译的代码中使用。在正常情况下，应使用宏而非编译器变换；编译器变换仅用于像 " { $link cond } " 这样在引导过程中频繁调用的单词，对于这些单词，拥有一个不即时生成代码的高性能非优化定义很重要。"
{ $subsections define-transform }
{ $see-also "generalizations" "fry" } ;

ABOUT: "macros-zh"
