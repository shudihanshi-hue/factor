! Copyright (C) 2026 Factor 中文汉化社区.
! See https://factorcode.org/license.txt for BSD license.
!
! 确定性资源释放 — 中文翻译
! 原始文件: D:\factor\core\destructors\destructors-docs.factor

USING: classes destructors help.markup help.syntax io quotations sequences ;
IN: zh.core.destructors

HELP: debug-leaks?
{ $var-description "当此变量开启时，" { $link new-disposable } " 会在 " { $link disposable } " 的 " { $slot "continuation" } " 槽中存储当前续延。" }
{ $see-also "tools.destructors" } ;

HELP: disposable
{ $class-description "可释放资源的父类。此类有两个槽："
    { $slots
        { "disposed" { "一个布尔值，由 " { $link dispose } " 设置为 true。使用 " { $link check-disposed } " 断言其为 false。" } }
        { "continuation" { "构造时的当前续延，用于调试。如果 " { $link debug-leaks? } " 开启，由 " { $link new-disposable } " 设置。" } }
    }
"新实例必须使用 " { $link new-disposable } " 构造，子类必须实现 " { $link dispose* } " 方法。" } ;

HELP: new-disposable
{ $values { "class" class } { "disposable" disposable } }
{ $description "构造 " { $link disposable } " 子类的新实例。这会设置 " { $slot "id" } " 槽，向全局 " { $link disposables } " 集合注册新对象，如果 " { $link debug-leaks? } " 开启，则在 " { $slot "continuation" } " 槽中存储当前续延。" } ;

HELP: dispose
{ $values { "disposable" "一个可释放对象" } }
{ $contract "释放与可释放对象关联的操作系统资源。可释放对象包括流、内存映射文件等。"
$nl
"此调用后，无法对可释放对象执行进一步操作。"
$nl
"释放一个已释放的对象不应有任何效果，特别是不应抛出错误。为了帮助实现此模式，请继承 " { $link disposable } " 类并实现 " { $link dispose* } " 方法。" }
{ $notes "使用完可释放对象后必须释放它们，以避免泄漏操作系统资源。自动化此过程的便捷方法是使用 " { $link with-disposal } " 单词。"
$nl
"默认实现假设对象有一个 " { $snippet "disposed" } " 槽。如果该槽为 " { $link f } "，则调用 " { $link dispose* } " 并将槽设置为 " { $link t } "。" } ;

HELP: dispose*
{ $values { "disposable" "一个可释放对象" } }
{ $contract "释放与可释放对象关联的操作系统资源。可释放对象包括流、内存映射文件等。" }
{ $notes
    "此单词不应直接调用。可在具有 " { $slot "disposed" } " 槽的对象上实现，以确保对象仅被释放一次。"
} ;

HELP: with-disposal
{ $values { "object" "一个可释放对象" } { "quot" { $quotation ( object -- ) } } }
{ $description "调用引用，在引用返回或抛出错误后用 " { $link dispose } " 释放对象。" } ;

HELP: with-destructors
{ $values { "quot" quotation } }
{ $description "在一个新的动态作用域中调用引用。此引用可使用 " { $link &dispose } " 或 " { $link |dispose } " 注册析构器。前者注册一个总是会运行的析构器（无论引用是否抛出错误），后者注册一个仅在引用抛出错误时运行的析构器。析构器按注册顺序的反序运行。" }
{ $notes
    "析构器泛化了 " { $link with-disposal } "。以下两行等价，除了第二行建立了一个新的动态作用域："
    { $code
        "[ X ] with-disposal"
        "[ &dispose X ] with-destructors"
    }
}
{ $examples
    { $code "[ 10 malloc &free ] with-destructors" }
} ;

HELP: &dispose
{ $values { "disposable" "一个可释放对象" } }
{ $description "标记对象在当前 " { $link with-destructors } " 作用域结束时无条件释放。" } ;

HELP: |dispose
{ $values { "disposable" "一个可释放对象" } }
{ $description "标记对象在当前 " { $link with-destructors } " 作用域结束时若发生错误则释放。" } ;

HELP: dispose-each
{ $values
    { "seq" sequence } }
{ $description "尝试释放序列中的每个元素，并将所有错误收集到一个序列中。如果释放过程中抛出任何错误，在所有对象都被释放后重新抛出最后一个错误。" } ;

HELP: disposables
{ $var-description "保存所有尚未释放的可释放对象的全局变量。" { $link new-disposable } " 单词在此添加对象，可释放对象上的 " { $link dispose } " 方法将它们移除。" { $link "tools.destructors" } " 词汇提供了一些处理此数据的单词。" }
{ $see-also "tools.destructors" } ;

ARTICLE: "destructors-anti-patterns" "资源释放反模式"
"创建对应外部资源对象的单词应始终与 " { $link with-disposal } " 一起使用。以下代码是错误的："
{ $code
    "<external-resource> ... do stuff ... dispose"
}
"原因是如果 " { $snippet "do stuff" } " 抛出错误，资源将不会被释放。最重要的情况是 I/O 流，正确的解决方案是始终使用 " { $link with-input-stream } " 和 " { $link with-output-stream } "；详见 " { $link "stdio" } "。" ;

ARTICLE: "destructors-using" "使用析构器"
"释放对象："
{ $subsections dispose }
"作用域释放的实用单词："
{ $subsections with-disposal }
"释放多个对象的实用单词："
{ $subsections dispose-each }
"更复杂释放模式的实用单词："
{ $subsections
    with-destructors
    &dispose
    |dispose
} ;

ARTICLE: "destructors-extending" "编写新的析构器"
"可释放对象的超类："
{ $subsections disposable }
"可释放对象的参数化构造器："
{ $subsections new-disposable }
"通用释放单词："
{ $subsections dispose* }
"全局可释放对象集合："
{ $subsections disposables } ;

ARTICLE: "destructors" "确定性资源释放"
"操作系统资源（如流、内存映射文件等）不由 Factor 的垃圾回收器管理，使用完毕时必须释放。未释放资源会导致性能下降和不稳定。"
{ $subsections
    "destructors-using"
    "destructors-extending"
    "destructors-anti-patterns"
}
{ $see-also "tools.destructors" } ;

ABOUT: "destructors-zh"