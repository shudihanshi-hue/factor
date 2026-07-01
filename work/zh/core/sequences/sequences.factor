USING: arrays generic.single help.markup help.syntax kernel
layouts math math.order multiline quotations sequences
sequences.private strings vectors ;
IN: zh.core.sequences

HELP: sequence
{ $class-description "一个混入类，其实例都是序列（sequence）。自定义序列协议实现应声明为此混入类的实例，以便所有序列功能都能正常工作："
    { $code "INSTANCE: my-sequence sequence" }
} ;

HELP: length
{ $values { "seq" sequence } { "n" "一个非负整数" } }
{ $contract "输出序列（sequence）的长度。所有序列都支持此操作。" }
{ $examples
    [=[
        USING: prettyprint sequences ;
        { 1 "a" { 2 3 } f } length .
        4
    ]=]
    [=[
        USING: prettyprint sequences ;
        "Hello, world!" length .
        13
    ]=]
} ;

HELP: set-length
{ $values { "n" "一个非负整数" } { "seq" "一个可调整大小的序列（sequence）" } }
{ $contract "调整序列（sequence）的大小。新增区域的初始内容未定义。" }
{ $errors "如果序列不可调整大小，则抛出 " { $link no-method } " 错误；如果新长度为负数，则抛出 " { $link bounds-error } " 错误。" }
{ $side-effects "seq" }
{ $examples
    [=[
        USING: kernel prettyprint sequences ;
        6 V{ 1 2 3 } [ set-length ] keep .
        V{ 1 2 3 0 0 0 }
    ]=]
    [=[
        USING: kernel prettyprint sequences ;
        3 V{ 1 2 3 4 5 6 } [ set-length ] keep .
        V{ 1 2 3 }
    ]=]
} ;

HELP: lengthen
{ $values { "n" "一个非负整数" } { "seq" "一个可调整大小的序列（sequence）" } }
{ $contract "确保序列（sequence）至少包含 " { $snippet "n" } " 个元素。此词与 " { $link set-length } " 有两个区别："
    { $list
        { "当 " { $snippet "n" } " 小于序列长度时，此词不会缩小序列。" }
        { "此词会将 " { $snippet "seq" } " 的底层存储翻倍，而 " { $link set-length } " 允许将其设置为等于 " { $snippet "n" } " 的大小。这确保了在循环中对此词进行常量递增的重复调用不会导致平方级别的复制量，从而使 " { $link push-all } " 在循环中使用时能够高效运行。" }
    }
}
{ $examples
    { $example
        "USING: kernel prettyprint sequences ;"
        "6 V{ 1 1 1 1 } [ lengthen ] keep ."
        "V{ 1 1 1 1 0 0 }"
    }
    "展示底层存储如何增长："
    { $example
        "USING: accessors kernel prettyprint sequences ;"
        "6 V{ 1 1 1 1 } [ lengthen ] keep underlying>> ."
        "{ 1 1 1 1 0 0 0 0 0 0 0 0 0 0 }"
    }
    "当 " { $snippet "n" } " 小于 " { $snippet "seq" } " 的长度时："
    { $example
        "USING: kernel prettyprint sequences ;"
        "2 V{ 1 2 3 4 5 6 7 8 } [ lengthen ] keep ."
        "V{ 1 2 3 4 5 6 7 8 }"
    }
} ;

HELP: nth
{ $values { "n" "一个非负整数" } { "seq" sequence } { "elt" "第 " { $snippet "n" } " 个索引处的元素" } }
{ $contract "输出序列（sequence）的第 " { $snippet "n" } " 个元素。元素从零开始编号，因此最后一个元素的索引比序列长度小一。所有序列都支持此操作。" }
{ $errors "如果索引为负数，或大于等于序列长度，则抛出 " { $link bounds-error } " 错误。" }
{ $examples
    [=[
        USING: prettyprint sequences ;
        1 { "a" "b" "c" } nth .
        "b"
    ]=]
} ;

HELP: set-nth
{ $values { "elt" object } { "n" "一个非负整数" } { "seq" "一个可变的序列（sequence）" } }
{ $contract "设置序列（sequence）的第 " { $snippet "n" } " 个元素。在可调整大小的序列（如 vector 或字符串缓冲区）末尾之外存储会自动增长序列。" }
{ $errors "如果索引为负数，或序列不可调整大小且索引大于等于序列长度，则抛出错误。"
$nl
"如果序列不能容纳给定类型的元素，则抛出错误。" }
{ $side-effects "seq" }
{ $examples
    [=[
        USING: kernel prettyprint sequences ;
        99 0 { 1 1 1 } [ set-nth ] keep .
        { 99 1 1 }
    ]=]
    [=[
        USING: kernel prettyprint sequences ;
        99 8 V{ 1 1 1 } [ set-nth ] keep .
        V{ 1 1 1 0 0 0 0 0 99 }
    ]=]
} ;

HELP: nths
{ $values
    { "indices" sequence } { "seq" sequence }
    { "seq'" sequence } }
{ $description "从输入序列（sequence）中输出由索引指定的元素组成的序列。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
               "{ 0 2 } { \"a\" \"b\" \"c\" } nths ."
               "{ \"a\" \"c\" }"
    }
} ;

HELP: immutable
{ $values { "seq" sequence } }
{ $description "抛出一个 " { $link immutable } " 错误。" }
{ $error-description "当尝试修改不可变序列（sequence）时抛出。" } ;

HELP: new-sequence
{ $values { "len" "一个非负整数" } { "seq" sequence } { "newseq" "一个可变的序列（sequence）" } }
{ $contract "输出一个长度为 " { $snippet "len" } " 的可变序列（sequence），该序列可以容纳 " { $snippet "seq" } " 的元素。序列的初始内容未定义。" }
{ $examples
    [=[
        USING: prettyprint sequences ;
        6 { 1 2 3 } new-sequence .
        { 0 0 0 0 0 0 }
    ]=]
} ;

HELP: new-resizable
{ $values { "len" "一个非负整数" } { "seq" sequence } { "newseq" "一个可调整大小且可变的序列（sequence）" } }
{ $contract "输出一个可调整大小的可变序列（sequence），初始容量为 " { $snippet "len" } " 个元素且长度为零，可以容纳 " { $snippet "seq" } " 的元素。" }
{ $examples
    { $example "USING: prettyprint sequences ;" "300 V{ } new-resizable ." "V{ }" }
    { $example "USING: prettyprint sequences ;" "300 SBUF\" \" new-resizable ." "SBUF\" \"" }
} ;

HELP: like
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" "一个新序列（sequence）" } }
{ $contract "输出一个与 " { $snippet "seq" } " 具有相同元素的序列（sequence），但" { $emphasis "类似于" } "模板序列，即它要么与模板序列具有相同的类，要么如果模板序列是虚拟序列，则与模板序列的底层序列具有相同的类。"
$nl
"默认实现不做任何操作。" }
{ $notes "与 " { $link clone-like } " 不同，输出序列可能与输入序列共享存储。" }
{ $examples
    { $example
        "USING: prettyprint sequences ;"
        "{ 1 2 3 } V{ } like ."
        "V{ 1 2 3 }"
    }
    "演示共享存储："
    { $example
        "USING: kernel prettyprint sequences ;"
        "{ 1 2 3 } dup V{ } like reverse! [ . ] bi@"
        "{ 3 2 1 }\nV{ 3 2 1 }"
    }
} ;

HELP: empty?
{ $values { "seq" sequence } { "?" boolean } }
{ $description "测试序列（sequence）是否长度为零。" } ;

HELP: if-empty
{ $values { "seq" sequence } { "quot1" quotation } { "quot2" quotation } }
{ $description "对序列（sequence）是否为空进行隐式检查。如果序列为空，则丢弃序列并调用 " { $snippet "quot1" } "。否则，如果序列包含任何元素，则在序列上调用 " { $snippet "quot2" } "。" }
{ $examples
    { $example
        "USING: kernel prettyprint sequences ;"
        "{ 1 2 3 } [ \"empty sequence\" ] [ sum ] if-empty ."
        "6"
    }
} ;

HELP: when-empty
{ $values
    { "seq" sequence } { "quot" "" { $link if-empty } " 的第一个引用" }
    { "seq/obj" object }
}
{ $description "对序列（sequence）是否为空进行隐式检查。如果序列为空，则丢弃序列并调用 " { $snippet "quot" } "。" }
{ $examples "此词等价于带有空第二个引用的 " { $link if-empty } "："
    { $example
    "USING: sequences prettyprint ;"
    "{ } [ { 4 5 6 } ] [ ] if-empty ."
    "{ 4 5 6 }"
    }
    { $example
    "USING: sequences prettyprint ;"
    "{ } [ { 4 5 6 } ] when-empty ."
    "{ 4 5 6 }"
    }
} ;

HELP: unless-empty
{ $values
    { "seq" sequence } { "quot" "" { $link if-empty } " 的第二个引用" } }
{ $description "对序列（sequence）是否为空进行隐式检查。如果序列为空，则丢弃序列。否则，在序列上调用 " { $snippet "quot" } "。" }
{ $examples "此词等价于带有空第一个引用的 " { $link if-empty } "："
    { $example
    "USING: sequences prettyprint ;"
    "{ 4 5 6 } [ ] [ sum . ] if-empty"
    "15"
    }
    { $example
    "USING: sequences prettyprint ;"
    "{ 4 5 6 } [ sum . ] unless-empty"
    "15"
    }
} ;

HELP: delete-all
{ $values { "seq" "一个可调整大小的序列（sequence）" } }
{ $description "将序列（sequence）大小重置为零长度，删除所有元素。并非所有序列都可以调整大小。" }
{ $errors "如果序列不可调整大小，则抛出错误。" }
{ $side-effects "seq" } ;

HELP: resize
{ $values { "n" "一个非负整数" } { "seq" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "创建一个与 " { $snippet "seq" } " 相同类型的新序列（sequence），包含 " { $snippet "n" } " 个元素，并将 " { $snippet "seq" } " 的内容复制到新序列中。如果 " { $snippet "n" } " 超过 " { $snippet "seq" } " 的长度，则剩余元素用默认值填充；对于 array 为 " { $link f } "，对于 string 为 0。" }
{ $notes "此泛型词仅为字符串（string）和数组（array）实现。" } ;

HELP: first
{ $values { "seq" sequence } { "first" "序列（sequence）的第一个元素" } }
{ $description "输出序列（sequence）的第一个元素。" }
{ $errors "如果序列为空，则抛出错误。" } ;

HELP: second
{ $values { "seq" sequence } { "second" "序列（sequence）的第二个元素" } }
{ $description "输出序列（sequence）的第二个元素。" }
{ $errors "如果序列包含少于两个元素，则抛出错误。" } ;

HELP: third
{ $values { "seq" sequence } { "third" "序列（sequence）的第三个元素" } }
{ $description "输出序列（sequence）的第三个元素。" }
{ $errors "如果序列包含少于三个元素，则抛出错误。" } ;

HELP: fourth
{ $values { "seq" sequence } { "fourth" "序列（sequence）的第四个元素" } }
{ $description "输出序列（sequence）的第四个元素。" }
{ $errors "如果序列包含少于四个元素，则抛出错误。" } ;

HELP: push
{ $values { "elt" object } { "seq" "一个可调整大小且可变的序列（sequence）" } }
{ $description "在序列（sequence）末尾添加一个元素。序列长度会相应调整。" }
{ $errors "如果 " { $snippet "seq" } " 不可调整大小，或 " { $snippet "elt" } " 的类型不允许放入 " { $snippet "seq" } " 中，则抛出错误。" }
{ $side-effects "seq" } ;

HELP: bounds-check?
{ $values { "n" integer } { "seq" sequence } { "?" boolean } }
{ $description "测试索引是否在序列（sequence）的边界内。" }
{ $examples
    [=[
        USING: prettyprint sequences ;
        5 { 1 2 3 } bounds-check? .
        f
    ]=]
} ;

HELP: bounds-error
{ $values { "n" integer } { "seq" sequence } }
{ $description "抛出一个 " { $link bounds-error } " 错误。" }
{ $error-description "当给定索引超出序列（sequence）边界时，由 " { $link nth } "、" { $link set-nth } " 和 " { $link set-length } " 抛出。" } ;

HELP: bounds-check
{ $values { "n" integer } { "seq" sequence } }
{ $description "如果 " { $snippet "n" } " 为负数或大于等于 " { $snippet "seq" } " 的长度，则抛出错误。否则两个输入保持在栈上。" } ;

HELP: ?nth
{ $values { "n" integer } { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "" { $link nth } " 的宽容版本。如果索引越界，或序列（sequence）为 " { $link f } "，则简单地输出 " { $link f } "。" } ;

{ nth ?nth } related-words

HELP: ?set-nth
{ $values { "elt" object } { "n" integer } { "seq" sequence } }
{ $description "" { $link set-nth } " 的宽容版本。如果索引越界，则不执行任何操作。" } ;

HELP: ?first
{ $values { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "" { $link first } " 的宽容版本。如果序列（sequence）为空，或序列为 " { $link f } "，则简单地输出 " { $link f } "。" }
{ $examples
    "在空序列上："
    { $example "USING: sequences prettyprint ;"
               "{ } ?first ."
               "f"
    }
    "在有元素的序列上行为类似 first："
    { $example "USING: sequences prettyprint ;"
               "{ 1 2 3 } ?first ."
               "1"
    }
} ;


HELP: ?second
{ $values { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "" { $link second } " 的宽容版本。如果序列（sequence）少于两个元素，或序列为 " { $link f } "，则简单地输出 " { $link f } "。" } ;

HELP: ?last
{ $values { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "" { $link last } " 的宽容版本。如果序列（sequence）为空，或序列为 " { $link f } "，则简单地输出 " { $link f } "。" } ;

HELP: nth-unsafe
{ $values { "n" integer } { "seq" sequence } { "elt" object } }
{ $contract "" { $link nth } " 的不安全变体，不执行边界检查。" } ;

HELP: set-nth-unsafe
{ $values { "elt" object } { "n" integer } { "seq" sequence } }
{ $contract "" { $link set-nth } " 的不安全变体，不执行边界检查。" } ;

HELP: exchange-unsafe
{ $values { "m" "一个非负整数" } { "n" "一个非负整数" } { "seq" "一个可变的序列（sequence）" } }
{ $description "" { $link exchange } " 的不安全变体，不执行边界检查。" } ;

HELP: first-unsafe
{ $values { "seq" sequence } { "first" "第一个元素" } }
{ $contract "" { $link first } " 的不安全变体，不执行边界检查。" } ;

HELP: first2-unsafe
{ $values { "seq" sequence } { "first" "第一个元素" } { "second" "第二个元素" } }
{ $contract "" { $link first2 } " 的不安全变体，不执行边界检查。" } ;

HELP: first3-unsafe
{ $values { "seq" sequence } { "first" "第一个元素" } { "second" "第二个元素" } { "third" "第三个元素" } }
{ $contract "" { $link first3 } " 的不安全变体，不执行边界检查。" } ;

HELP: first4-unsafe
{ $values { "seq" sequence } { "first" "第一个元素" } { "second" "第二个元素" } { "third" "第三个元素" } { "fourth" "第四个元素" } }
{ $contract "" { $link first4 } " 的不安全变体，不执行边界检查。" } ;

HELP: 1sequence
{ $values { "obj" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "创建与 " { $snippet "exemplar" } " 同类型的一元素序列（sequence）。" } ;

HELP: 2sequence
{ $values { "obj1" object } { "obj2" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "创建与 " { $snippet "exemplar" } " 同类型的二元素序列（sequence）。" } ;

HELP: 3sequence
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "创建与 " { $snippet "exemplar" } " 同类型的三元素序列（sequence）。" } ;

HELP: 4sequence
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "obj4" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "创建与 " { $snippet "exemplar" } " 同类型的四元素序列（sequence）。" } ;

HELP: first2
{ $values { "seq" sequence } { "first" "第一个元素" } { "second" "第二个元素" } }
{ $description "压入序列（sequence）的前两个元素。" }
{ $errors "如果序列少于两个元素，则抛出错误。" } ;

HELP: first3
{ $values { "seq" sequence } { "first" "第一个元素" } { "second" "第二个元素" } { "third" "第三个元素" } }
{ $description "压入序列（sequence）的前三个元素。" }
{ $errors "如果序列少于三个元素，则抛出错误。" } ;

HELP: first4
{ $values { "seq" sequence } { "first" "第一个元素" } { "second" "第二个元素" } { "third" "第三个元素" } { "fourth" "第四个元素" } }
{ $description "压入序列（sequence）的前四个元素。" }
{ $errors "如果序列少于四个元素，则抛出错误。" } ;

HELP: array-capacity
{ $class-description "一个谓词类，其实例是当前架构下有效数组大小的 fixnum。最小值为零，最大值为 " { $link max-array-capacity } "。" }
{ $description "底层数组长度访问器。" }
{ $warning "此词位于 " { $vocab-link "sequences.private" } " 词汇中，因为它是不安全的。它不检查类型，因此不当使用可能会破坏内存。" }
{ $see-also integer-array-capacity } ;

HELP: integer-array-capacity
{ $class-description "一个谓词类，其实例是当前架构下有效数组大小的整数。最小值为零，最大值为 " { $link max-array-capacity } "。" }
{ $description "底层数组长度访问器。" }
{ $warning "此词位于 " { $vocab-link "sequences.private" } " 词汇中，因为它是不安全的。它不检查类型，因此不当使用可能会破坏内存。" }
{ $see-also array-capacity } ;

HELP: array-nth
{ $values { "n" "一个非负 fixnum" } { "array" array } { "elt" object } }
{ $description "底层数组元素访问器。" }
{ $warning "此词位于 " { $vocab-link "sequences.private" } " 词汇中，因为它是不安全的。它不检查类型或数组边界，不当使用可能会破坏内存。用户代码应使用 " { $link nth } " 代替。" } ;

HELP: set-array-nth
{ $values { "elt" object } { "n" "一个非负 fixnum" } { "array" array } }
{ $description "底层数组元素修改器。" }
{ $warning "此词位于 " { $vocab-link "sequences.private" } " 词汇中，因为它是不安全的。它不检查类型或数组边界，不当使用可能会破坏内存。用户代码应使用 " { $link set-nth } " 代替。" } ;

HELP: collect
{ $values { "n" "一个非负整数" } { "quot" { $quotation ( ... n -- ... value ) } } { "into" "一个长度至少为 " { $snippet "n" } " 的序列（sequence）" } }
{ $description "一个原始的映射操作，将引用应用于从 0 到 " { $snippet "n" } "（不包括 " { $snippet "n" } "）的所有整数，并将结果收集到一个新数组中。用户代码应使用 " { $link map } " 代替。" }
{ $examples
  { $example
    "USING: kernel math.parser prettyprint sequences sequences.private ;"
    "10 [ number>string ] 10 f new-sequence [ collect ] keep ."
    "{ \"0\" \"1\" \"2\" \"3\" \"4\" \"5\" \"6\" \"7\" \"8\" \"9\" }"
  }
} ;

HELP: each
{ $values { "seq" sequence } { "quot" { $quotation ( ... x -- ... ) } } }
{ $description "按顺序将引用应用于序列（sequence）的每个元素。" } ;

HELP: reduce
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "result" "最终结果" } }
{ $description "使用二元操作组合序列（sequence）中连续的元素，并输出最终结果。在第一次迭代中，引用的两个输入是 " { $snippet "identity" } " 和序列的第一个元素。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是序列中对应的元素。" }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 1 5 3 } 0 [ + ] reduce ." "9" }
} ;

HELP: reduce-index
{ $values
    { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt index -- ... next ) } } { "result" object } }
{ $description "使用二元操作组合序列（sequence）中连续的元素及其索引，并输出最终结果。在第一次迭代中，引用的三个输入是 " { $snippet "identity" } "、序列的第一个元素及其索引 0。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是序列中对应的元素，第三个是其索引。" }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 10 50 90 } 0 [ + + ] reduce-index ."
    "153"
} } ;

HELP: accumulate-as
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "exemplar" sequence } { "final" "最终结果" } { "newseq" "一个新序列（sequence）" } }
{ $description "使用二元操作组合序列（sequence）中连续的元素，并输出一个与 " { $snippet "exemplar" } " 相同类型的序列，其中包含中间结果以及最终结果。"
$nl
"输出序列的第一个元素是 " { $snippet "identity" } "。然后，在第一次迭代中，引用的两个输入是 " { $snippet "identity" } " 和输入序列的第一个元素。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是输入序列的下一个元素。"
$nl
"当给定空序列时，输出一个新的空序列以及 " { $snippet "identity" } "。" }
{ $notes "在其他语言中可能被称为 " { $snippet "scan" } " 或 " { $snippet "prefix sum" } "（前缀和）。" } ;

HELP: accumulate
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "final" "最终结果" } { "newseq" "一个新序列（sequence）" } }
{ $description "使用二元操作组合序列（sequence）中连续的元素，并输出一个包含中间结果的序列以及最终结果。"
$nl
"输出序列的第一个元素是 " { $snippet "identity" } "。然后，在第一次迭代中，引用的两个输入是 " { $snippet "identity" } " 和输入序列的第一个元素。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是输入序列的下一个元素。"
$nl
"当给定空序列时，输出一个新的空序列以及 " { $snippet "identity" } "。" }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate . ." "{ 0 2 4 6 8 }\n10" }
}
{ $notes "在其他语言中可能被称为 " { $snippet "scan" } " 或 " { $snippet "prefix sum" } "（前缀和）。" } ;

HELP: accumulate!
{ $values { "seq" "一个可变的序列（sequence）" } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "final" "最终结果" } }
{ $description "使用二元操作组合序列（sequence）中连续的元素，并输出包含中间结果的原始序列以及最终结果。"
$nl
"新序列的第一个元素是 " { $snippet "identity" } "。然后，在第一次迭代中，引用的两个输入是 " { $snippet "identity" } " 和旧序列的第一个元素。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是旧序列中对应的元素。"
$nl
"当给定空序列时，输出同一个空序列以及 " { $snippet "identity" } "。" }
{ $errors "如果序列（sequence）不可变，或序列不能容纳 " { $snippet "quot" } " 输出的类型的元素，则抛出错误。" }
{ $side-effects "seq" }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate! . ." "{ 0 2 4 6 8 }\n10" }
}
{ $notes "在其他语言中可能被称为 " { $snippet "scan" } " 或 " { $snippet "prefix sum" } "（前缀和）。" } ;

HELP: accumulate*-as
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "exemplar" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "使用二元操作组合序列（sequence）中连续的元素，并输出一个与 " { $snippet "exemplar" } " 相同类型且包含所有结果的序列。"
$nl
"在第一次迭代中，引用的两个输入是 " { $snippet "identity" } " 和输入序列的第一个元素。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是输入序列的下一个元素。"
$nl
"当给定空序列时，输出一个新的空序列。" }
{ $notes "在其他语言中可能被称为 " { $snippet "scan" } " 或 " { $snippet "prefix sum" } "（前缀和）。" } ;

HELP: accumulate*
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "newseq" sequence } }
{ $description "使用二元操作组合序列（sequence）中连续的元素，并输出一个包含所有结果的序列。"
$nl
"在第一次迭代中，引用的两个输入是 " { $snippet "identity" } " 和输入序列的第一个元素。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是输入序列的下一个元素。"
$nl
"当给定空序列时，输出一个新的空序列。" }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate* ." "{ 2 4 6 8 10 }" }
}
{ $notes "在其他语言中可能被称为 " { $snippet "scan" } " 或 " { $snippet "prefix sum" } "（前缀和）。" } ;

HELP: accumulate*!
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } }
{ $description "使用二元操作组合序列（sequence）中连续的元素，并输出包含所有结果的原始序列。"
$nl
"在第一次迭代中，引用的两个输入是 " { $snippet "identity" } " 和输入序列的第一个元素。在后续迭代中，第一个输入是前一次迭代的结果，第二个输入是输入序列的下一个元素。"
$nl
"当给定空序列时，输出同一个空序列。" }
{ $errors "如果序列（sequence）不可变，或序列不能容纳 " { $snippet "quot" } " 输出的类型的元素，则抛出错误。" }
{ $side-effects "seq" }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate*! ." "{ 2 4 6 8 10 }" }
}
{ $notes "在其他语言中可能被称为 " { $snippet "scan" } " 或 " { $snippet "prefix sum" } "（前缀和）。" } ;

{ accumulate accumulate! accumulate-as accumulate* accumulate*! accumulate*-as } related-words

HELP: map
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... newelt ) } } { "newseq" "一个新序列（sequence）" } }
{ $description "按顺序将引用应用于序列（sequence）的每个元素。新元素被收集到一个与输入序列相同类型的序列中。" } ;

HELP: map-as
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... newelt ) } } { "exemplar" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "按顺序将引用应用于序列（sequence）的每个元素。新元素被收集到一个与 " { $snippet "exemplar" } " 相同类型的序列中。" }
{ $examples
    "以下示例将字符串转换为单元素字符串的数组："
    { $example "USING: prettyprint strings sequences ;" "\"Hello\" [ 1string ] { } map-as ." "{ \"H\" \"e\" \"l\" \"l\" \"o\" }" }
    "注意这里不能使用 " { $link map } "，因为它会创建另一个字符串来保存结果，而单元素字符串本身不能是字符串的元素。"
} ;

HELP: each-index
{ $values
    { "seq" sequence } { "quot" { $quotation ( ... elt index -- ... ) } } }
{ $description "用序列（sequence）的元素及其索引调用引用，索引位于栈顶。" }
{ $examples { $example "USING: arrays sequences prettyprint ;"
"{ 10 20 30 } [ 2array . ] each-index"
"{ 10 0 }\n{ 20 1 }\n{ 30 2 }"
} } ;

HELP: map-index
{ $values
  { "seq" sequence } { "quot" { $quotation ( ... elt index -- ... newelt ) } } { "newseq" sequence } }
{ $description "用序列（sequence）的元素及其索引调用引用，索引位于栈顶。收集引用的输出并将它们放入一个与输入序列相同类型的序列中。" }
{ $examples
    { $example "USING: arrays sequences prettyprint ;"
        "{ 10 20 30 } [ 2array ] map-index ."
        "{ { 10 0 } { 20 1 } { 30 2 } }"
    }
} ;

HELP: map-index-as
{ $values
  { "seq" sequence } { "quot" { $quotation ( ... elt index -- ... newelt ) } } { "exemplar" sequence } { "newseq" sequence } }
{ $description "用序列（sequence）的元素及其索引调用引用，索引位于栈顶。收集引用的输出并将它们放入一个与 " { $snippet "exemplar" } " 序列相同类型的序列中。" }
{ $examples
    { $example "USING: arrays sequences prettyprint ;"
        "{ 10 20 30 } [ 2array ] V{ } map-index-as ."
        "V{ { 10 0 } { 20 1 } { 30 2 } }"
    }
} ;

{ map map! map-as map-index map-index-as } related-words

HELP: change-nth
{ $values { "i" "一个非负整数" } { "seq" "一个可变的序列（sequence）" } { "quot" { $quotation ( ..a elt -- ..b newelt ) } } }
{ $description "将引用应用于序列（sequence）的第 " { $snippet "i" } " 个元素，将结果存回序列中。" }
{ $errors "如果序列（sequence）不可变，或索引越界，或序列不能容纳 " { $snippet "quot" } " 输出的类型的元素，则抛出错误。" }
{ $side-effects "seq" } ;

HELP: map!
{ $values { "seq" "一个可变的序列（sequence）" } { "quot" { $quotation ( ... elt -- ... newelt ) } } }
{ $description "将引用应用于每个元素，产生新元素，将新元素存回原始序列（sequence）中。返回原始序列。" }
{ $errors "如果序列（sequence）不可变，或序列不能容纳 " { $snippet "quot" } " 输出的类型的元素，则抛出错误。" }
{ $side-effects "seq" } ;

HELP: min-length
{ $values { "seq1" sequence } { "seq2" sequence } { "n" "一个非负整数" } }
{ $description "输出两个序列（sequence）长度的最小值。" } ;

HELP: max-length
{ $values { "seq1" sequence } { "seq2" sequence } { "n" "一个非负整数" } }
{ $description "输出两个序列（sequence）长度的最大值。" } ;

HELP: 2each
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ) } } }
{ $description "将引用应用于 " { $snippet "seq1" } " 和 " { $snippet "seq2" } " 中的元素对。" } ;

HELP: 3each
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation ( ... elt1 elt2 elt3 -- ... ) } } }
{ $description "将引用应用于 " { $snippet "seq1" } "、" { $snippet "seq2" } " 和 " { $snippet "seq3" } " 中的元素三元组。" } ;

HELP: 2reduce
{ $values { "seq1" sequence }
          { "seq2" sequence }
          { "identity" object }
          { "quot" { $quotation ( ... prev elt1 elt2 -- ... next ) } }
          { "result" "最终结果" } }
{ $description "使用三元操作组合两个序列（sequence）中连续的元素对。除第一次迭代外，每次迭代的第一个输入值是前一次迭代的结果。第一次迭代的第一个输入值是 " { $snippet "identity" } "。" } ;

HELP: 2map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... newelt ) } } { "newseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每对元素，产生新元素，这些新元素被收集到一个与 " { $snippet "seq1" } " 相同类型的新序列（sequence）中。" } ;

HELP: 3map
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation ( ... elt1 elt2 elt3 -- ... newelt ) } } { "newseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每个三元组元素，产生新元素，这些新元素被收集到一个与 " { $snippet "seq1" } " 相同类型的新序列（sequence）中。" } ;

HELP: 2map-as
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... newelt ) } } { "exemplar" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每对元素，产生新元素，这些新元素被收集到一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence）中。" } ;

HELP: 3map-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation ( ... elt1 elt2 elt3 -- ... newelt ) } } { "exemplar" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每个三元组元素，产生新元素，这些新元素被收集到一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence）中。" } ;

HELP: 2all?
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ? ) } } { "?" boolean } }
{ $description "测试 " { $snippet "seq1" } " 和 " { $snippet "seq2" } " 的所有成对元素是否都满足谓词。如果两个序列（sequence）长度不同，则只比较较短序列的元素。" }
{ $examples
  { $example
    "USING: math prettyprint sequences ;"
    "{ 1 2 3 4 } { 2 4 6 8 } [ <= ] 2all? ."
    "t"
  }
} ;

HELP: 2any?
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ? ) } } { "?" boolean } }
{ $description "测试 " { $snippet "seq1" } " 和 " { $snippet "seq2" } " 的任意成对元素是否满足谓词。如果两个序列（sequence）长度不同，则只比较较短序列的元素。" }
{ $examples
  { $example
    "USING: math prettyprint sequences ;"
    "{ 2 4 5 8 } { 2 4 6 8 } [ < ] 2any? ."
    "t"
  }
} ;

HELP: find
{ $values { "seq" sequence }
          { "quot" { $quotation ( ... elt -- ... ? ) } }
          { "i" "第一个匹配的索引，或 " { $link f } }
          { "elt" "第一个匹配的元素，或 " { $link f } } }
{ $description "" { $link find-from } " 的简化版本，起始索引为 0。" } ;

HELP: find-from
{ $values { "n" "起始索引" }
          { "seq" sequence }
          { "quot" { $quotation ( ... elt -- ... ? ) } }
          { "i" { $maybe "第一个匹配的索引" } }
          { "elt" { $maybe "第一个匹配的元素" } } }
{ $description "依次将引用应用于序列（sequence）的每个元素，直到它输出一个真值或到达序列末尾。如果引用对某个序列元素产生了真值，该词输出元素索引和元素本身。否则，该词输出索引 " { $link f } " 和 " { $link f } " 作为元素。" } ;

HELP: find-last
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "i" { $maybe "第一个匹配的索引" } } { "elt" { $maybe "第一个匹配的元素" } } }
{ $description "" { $link find-last-from } " 的简化版本，起始索引为序列（sequence）长度减一。" } ;

HELP: find-last-from
{ $values { "n" "起始索引" } { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "i" { $maybe "第一个匹配的索引" } } { "elt" { $maybe "第一个匹配的元素" } } }
{ $description "以相反顺序将引用应用于序列（sequence）的每个元素，直到它输出一个真值或到达序列开头。如果引用对某个序列元素产生了真值，该词输出元素索引和元素本身。否则，该词输出索引 " { $link f } " 和 " { $link f } " 作为元素。" } ;

HELP: find-index
{ $values { "seq" sequence }
          { "quot" { $quotation ( ... elt i -- ... ? ) } }
          { "i" { $maybe "第一个匹配的索引" } }
          { "elt" { $maybe "第一个匹配的元素" } } }
{ $description "" { $link find } " 的变体，其中引用同时接受元素及其索引。" } ;

HELP: find-index-from
{ $values { "n" "起始索引" }
          { "seq" sequence }
          { "quot" { $quotation ( ... elt i -- ... ? ) } }
          { "i" { $maybe "第一个匹配的索引" } }
          { "elt" { $maybe "第一个匹配的元素" } } }
{ $description "" { $link find-from } " 的变体，其中引用同时接受元素及其索引。"
  "搜索从列表索引 " { $snippet "n" } " 开始，跳过直到该索引之前的元素。" } ;

HELP: map-find
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... result/f ) } } { "result" "引用的第一个非假结果" } { "elt" { $maybe "第一个匹配的元素" } } }
{ $description "将引用应用于序列（sequence）的每个元素，直到引用输出一个真值。如果引用产生了不是 " { $link f } " 的结果，则输出该值以及产生该值的序列元素。" } ;

HELP: map-find-last
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... result/f ) } } { "result" "引用的最后一个非假结果" } { "elt" { $maybe "最后一个匹配的元素" } } }
{ $description "从尾部开始将引用应用于序列（sequence）的每个元素，直到引用输出一个真值。如果引用产生了不是 " { $link f } " 的结果，则输出该值以及产生该值的序列元素。" } ;

{ map-find map-find-last } related-words

HELP: any?
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "?" boolean } }
{ $description "通过依次将谓词应用于每个元素直到找到真值，来测试序列（sequence）是否包含满足谓词的元素。如果序列为空或到达序列末尾，则输出 " { $link f } "。" } ;

HELP: none?
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "?" boolean } }
{ $description "通过依次将谓词应用于每个元素直到找到真值，来测试序列（sequence）是否不包含任何满足谓词的元素。如果序列为空或到达序列末尾，则输出 " { $link t } "。" } ;

HELP: all?
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "?" boolean } }
{ $description "通过依次检查每个元素来测试序列（sequence）中的所有元素是否都满足谓词。给定空序列，在空真意义上输出 " { $link t } "。" } ;

{ any? all? none? } related-words

HELP: push-when
{ $values { "elt" object } { "quot" { $quotation ( ..a elt -- ..b ? ) } } { "accum" "一个可调整大小且可变的序列（sequence）" } }
{ $description "如果引用产生真值，则在序列（sequence）末尾添加元素。" }
{ $notes "此词是 " { $link filter } " 的一个因子。" } ;

HELP: filter
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "subseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每个元素，并输出一个新序列（sequence），其中包含原始序列中引用输出真值的元素。" } ;

HELP: filter-as
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "exemplar" sequence } { "subseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每个元素，并输出一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence），其中包含原始序列中引用输出真值的元素。" } ;

HELP: filter!
{ $values { "seq" "一个可调整大小且可变的序列（sequence）" } { "quot" { $quotation ( ... elt -- ... ? ) } } }
{ $description "依次将引用应用于每个元素，并删除引用输出假值的元素。" }
{ $notes "序列（sequence）" { $snippet "seq" } " 必须是可增长的。参见 " { $link "growable" } "。" }
{ $side-effects "seq" }
{ $examples
  "删除奇数"
  { $example
    "USING: kernel math prettyprint sequences ;"
    "V{ 1 2 3 4 5 6 7 8 9 0 } [ odd? not ] filter! ."
    "V{ 2 4 6 8 0 }"
  } } ;


HELP: reject
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "subseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每个元素，并输出一个新序列（sequence），其中移除了原始序列中引用输出真值的元素。" } ;

HELP: reject-as
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "exemplar" sequence } { "subseq" "一个新序列（sequence）" } }
{ $description "依次将引用应用于每个元素，并输出一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence），其中移除了原始序列中引用输出真值的元素。" } ;

HELP: reject!
{ $values { "seq" "一个可调整大小且可变的序列（sequence）" } { "quot" { $quotation ( ... elt -- ... ? ) } } }
{ $description "依次将引用应用于每个元素，并删除引用输出真值的元素。" }
{ $notes "序列（sequence）" { $snippet "seq" } " 必须是可增长的。参见 " { $link "growable" } "。" }
{ $side-effects "seq" }
{ $examples
  "删除奇数"
  { $example
    "USING: math prettyprint sequences ;"
    "V{ 1 2 3 4 5 6 7 8 9 0 } [ odd? ] reject! ."
    "V{ 2 4 6 8 0 }"
  } } ;

HELP: interleave
{ $values { "seq" sequence } { "between" quotation } { "quot" { $quotation ( ... elt -- ... ) } } }
{ $description "依次将 " { $snippet "quot" } " 应用于每个元素，同时在每对元素之间调用 " { $snippet "between" } "。" }
{ $examples { $example "USING: io sequences ;" "{ \"a\" \"b\" \"c\" } [ \"X\" write ] [ write ] interleave" "aXbXc" } } ;

HELP: index
{ $values { "obj" object } { "seq" sequence } { "n" "一个索引" } }
{ $description "输出序列（sequence）中第一个等于 " { $snippet "obj" } " 的元素的索引。如果未找到元素，则输出 " { $link f } "。" } ;

HELP: index-from
{ $values { "obj" object } { "i" "起始索引" } { "seq" sequence } { "n" "一个索引" } }
{ $description "输出序列（sequence）中第一个等于 " { $snippet "obj" } " 的元素的索引，从第 " { $snippet "i" } " 个元素开始搜索。如果未找到元素，则输出 " { $link f } "。" } ;

HELP: last-index
{ $values { "obj" object } { "seq" sequence } { "n" "一个索引" } }
{ $description "输出序列（sequence）中最后一个等于 " { $snippet "obj" } " 的元素的索引；序列是从后向前遍历的。如果未找到元素，则输出 " { $link f } "。" } ;

HELP: last-index-from
{ $values { "obj" object } { "i" "起始索引" } { "seq" sequence } { "n" "一个索引" } }
{ $description "输出序列（sequence）中最后一个等于 " { $snippet "obj" } " 的元素的索引，从第 " { $snippet "i" } " 个元素开始向后遍历序列，到第一个元素结束。如果未找到元素，则输出 " { $link f } "。" } ;

HELP: member?
{ $values { "elt" object } { "seq" sequence } { "?" boolean } }
{ $description "测试序列（sequence）是否包含等于该对象的元素。" }
{ $examples
    "检查字母是否在字符串中："
    { $example
        "USING: sequences prettyprint ;"
        "CHAR: a \"abc\" member? ."
        "t"
    } $nl
    "检查数字是否在序列中："
    { $example
        "USING: sequences prettyprint ;"
        "4 { 1 2 3 } member? ."
        "f"
    }
}
{ $notes "此词使用相等比较（" { $link = } "）。" } ;

HELP: member-eq?
{ $values { "elt" object } { "seq" sequence } { "?" boolean } }
{ $description "测试序列（sequence）是否包含该对象。" }
{ $notes "此词使用同一性比较（" { $link eq? } "）。" } ;

HELP: remove
{ $values { "elt" object } { "seq" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），其中包含输入序列中除给定元素外的所有元素。" }
{ $notes "此词使用相等比较（" { $link = } "）。" } ;

HELP: remove-eq
{ $values { "elt" object } { "seq" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），其中包含输入序列中除与给定元素相同的元素外的所有元素。" }
{ $notes "此词使用同一性比较（" { $link eq? } "）。" } ;

HELP: remove-nth
{ $values
    { "n" integer } { "seq" sequence }
    { "seq'" sequence } }
{ $description "创建一个新序列（sequence），不包含索引 " { $snippet "n" } " 处的元素。" }
{ $examples "注意原始序列保持不变：" { $example "USING: sequences prettyprint kernel ;"
    "{ 1 2 3 } 1 over remove-nth . ."
    "{ 1 3 }\n{ 1 2 3 }"
} } ;

HELP: move
{ $values { "to" "" { $snippet "seq" } " 中的一个索引" } { "from" "" { $snippet "seq" } " 中的一个索引" } { "seq" "一个可变的序列（sequence）" } }
{ $description "将索引 " { $snippet "to" } " 处的元素设置为索引 " { $snippet "from" } " 处的元素。" }
{ $side-effects "seq" } ;

HELP: remove!
{ $values { "elt" object } { "seq" "一个可调整大小且可变的序列（sequence）" } }
{ $description "从 " { $snippet "seq" } " 中删除所有等于 " { $snippet "elt" } " 的元素并返回 " { $snippet "seq" } "。" }
{ $notes "序列（sequence）" { $snippet "seq" } " 必须是可增长的。参见 " { $link "growable" } "。" }
{ $notes "此词使用相等比较（" { $link = } "）。" }
{ $side-effects "seq" } ;

HELP: remove-eq!
{ $values { "elt" object } { "seq" "一个可调整大小且可变的序列（sequence）" } }
{ $description "输出一个新序列（sequence），其中包含输入序列中除给定元素外的所有元素。" }
{ $notes "此词使用同一性比较（" { $link eq? } "）。" }
{ $side-effects "seq" } ;

HELP: remove-nth!
{ $values { "n" "一个非负整数" } { "seq" "一个可调整大小且可变的序列（sequence）" } }
{ $description "从序列（sequence）中删除第 " { $snippet "n" } " 个元素，将所有其他元素向下移动并将序列长度减一。" }
{ $notes "序列（sequence）" { $snippet "seq" } " 必须是可增长的。参见 " { $link "growable" } "。" }
{ $side-effects "seq" } ;

HELP: delete-slice
{ $values { "from" "一个非负整数" } { "to" "一个非负整数" } { "seq" "一个可调整大小且可变的序列（sequence）" } }
{ $description "删除从索引 " { $snippet "from" } " 开始到索引 " { $snippet "to" } "（不含）结束的一段元素。" }
{ $side-effects "seq" } ;

HELP: replace-slice
{ $values { "new" sequence } { "from" "一个非负整数" } { "to" "一个非负整数" } { "seq" sequence } { "seq'" sequence } }
{ $description "用新序列（sequence）替换从索引 " { $snippet "from" } " 开始到索引 " { $snippet "to" } "（不含）结束的一段元素。" }
{ $errors "如果 " { $snippet "new" } " 包含类型不允许放入 " { $snippet "seq" } " 中的元素，则抛出错误。" } ;

{ push push-either push-when pop pop* prefix suffix suffix! } related-words

HELP: suffix
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "输出一个新序列（sequence），通过在 " { $snippet "seq" } " 末尾添加 " { $snippet "elt" } " 获得。" }
{ $errors "如果 " { $snippet "elt" } " 的类型不允许放入与 " { $snippet "seq1" } " 相同类型的序列中，则抛出错误。" }
{ $examples
    { $example "USING: prettyprint sequences ;" "{ 1 2 3 } 4 suffix ." "{ 1 2 3 4 }" }
} ;

HELP: suffix!
{ $values { "seq" "一个可调整大小且可变的序列（sequence）" } { "elt" object } }
{ $description "通过将 " { $snippet "elt" } " 添加到 " { $snippet "seq" } " 末尾来就地修改序列（sequence）。输出 " { $snippet "seq" } "。" }
{ $notes "序列（sequence）" { $snippet "seq" } " 必须是可增长的。参见 " { $link "growable" } "。" }
{ $errors "如果 " { $snippet "elt" } " 的类型不允许放入与 " { $snippet "seq" } " 相同类型的序列中，则抛出错误。" }
{ $examples
    { $example "USING: prettyprint sequences ;" "V{ 1 2 3 } 4 suffix! ." "V{ 1 2 3 4 }" }
} ;

HELP: append!
{ $values { "seq1" "一个可调整大小且可变的序列（sequence）" } { "seq2" sequence } }
{ $description "通过将 " { $snippet "seq2" } " 中的元素添加到末尾来就地修改 " { $snippet "seq1" } "，并输出 " { $snippet "seq1" } "。" }
{ $notes "序列（sequence）" { $snippet "seq1" } " 必须是可增长的。参见 " { $link "growable" } "。" }
{ $examples
    { $example "USING: prettyprint sequences ;" "V{ 1 2 3 } { 4 5 6 } append! ." "V{ 1 2 3 4 5 6 }" }
} ;

HELP: prefix
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "输出一个新序列（sequence），通过在 " { $snippet "seq" } " 开头添加 " { $snippet "elt" } " 获得。" }
{ $errors "如果 " { $snippet "elt" } " 的类型不允许放入与 " { $snippet "seq1" } " 相同类型的序列中，则抛出错误。" }
{ $examples
{ $example "USING: prettyprint sequences ;" "{ 1 2 3 } 0 prefix ." "{ 0 1 2 3 }" }
} ;

HELP: sum-lengths
{ $values { "seq" { $sequence sequence } } { "n" integer } }
{ $description "输出 " { $snippet "seq" } " 中所有序列（sequence）的长度之和。" }
{ $examples
    [=[
        USING: prettyprint sequences ;
        { { 11 43 3.2 } { 1 } { 15 16 } } sum-lengths .
        6
    ]=]
    [=[
        USING: prettyprint sequences ;
        { "hello" f { 1 2 3 } { } } sum-lengths .
        8
    ]=]
} ;

HELP: concat
{ $values { "seq" sequence } { "newseq" sequence } }
{ $description "将序列（sequence）的序列串联成一个序列。如果 " { $snippet "seq" } " 为空，则输出 " { $snippet "{ }" } "，否则结果序列与 " { $snippet "seq" } " 的第一个元素具有相同的类型。" }
{ $errors "如果 " { $snippet "seq" } " 中的某个序列包含不允许放入与 " { $snippet "seq" } " 的第一个元素相同类型的序列中的元素，则抛出错误。" } ;

HELP: concat-as
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "将序列（sequence）的序列串联成一个与 " { $snippet "exemplar" } " 相同类型的序列。" }
{ $errors "如果 " { $snippet "seq" } " 中的某个序列包含不允许放入与 " { $snippet "exemplar" } " 相同类型的序列中的元素，则抛出错误。" } ;

HELP: join
{ $values { "seq" sequence } { "glue" sequence } { "newseq" sequence } }
{ $description "将序列（sequence）的序列串联成一个序列，在每对序列之间放置 " { $snippet "glue" } " 的副本。结果序列与 " { $snippet "glue" } " 具有相同的类型。" }
{ $examples
    "连接字符串列表："
    { $example "USING: sequences prettyprint ;"
        "{ \"cat\" \"dog\" \"ant\" } \" \" join ."
        "\"cat dog ant\""
    }
}
{ $notes "如果 " { $snippet "glue" } " 序列为空，此词调用 " { $link concat-as } "。" }
{ $errors "如果 " { $snippet "seq" } " 中的某个序列包含不允许放入与 " { $snippet "glue" } " 相同类型的序列中的元素，则抛出错误。" } ;

HELP: join-as
{ $values { "seq" sequence } { "glue" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "将序列（sequence）的序列串联成一个序列，在每对序列之间放置 " { $snippet "glue" } " 的副本。结果序列与 " { $snippet "glue" } " 具有相同的类型。" }
{ $notes "如果 " { $snippet "glue" } " 序列为空，此词调用 " { $link concat-as } "。" }
{ $examples
    "将字符串列表连接为字符串缓冲区："
    { $example "USING: sequences prettyprint ;"
        "{ \"a\" \"b\" \"c\" } \"1\" SBUF\" \" join-as ."
        "SBUF\" a1b1c\""
    }
}
{ $errors "如果 " { $snippet "seq" } " 中的某个序列包含不允许放入与 " { $snippet "exemplar" } " 相同类型的序列中的元素，则抛出错误。" } ;

{ join join-as concat concat-as } related-words

HELP: last
{ $values { "seq" sequence } { "elt" object } }
{ $description "输出序列（sequence）的最后一个元素。" }
{ $errors "如果序列为空，则抛出错误。" } ;

HELP: last2
{ $values { "seq" sequence } { "penultimate" object } { "ultimate" object } }
{ $description "输出序列（sequence）的最后两个元素。" }
{ $errors "如果序列少于两个元素，则抛出错误。" } ;

HELP: pop*
{ $values { "seq" "一个可调整大小且可变的序列（sequence）" } }
{ $description "删除最后一个元素并缩短序列（sequence）。" }
{ $side-effects "seq" }
{ $errors "如果序列为空，则抛出错误。" } ;

HELP: pop
{ $values { "seq" "一个可调整大小且可变的序列（sequence）" } { "elt" object } }
{ $description "在删除最后一个元素并缩短序列（sequence）后输出该元素。" }
{ $side-effects "seq" }
{ $errors "如果序列为空，则抛出错误。" } ;

HELP: mismatch
{ $values { "seq1" sequence } { "seq2" sequence } { "i" "一个索引" } }
{ $description "比较元素对，直到两个序列（sequence）中较短的长度，输出两个序列元素不相等的第一个索引，如果所有测试的元素都相等则输出 " { $link f } "。" } ;

HELP: flip
{ $values { "matrix" "一个等长序列（sequence）的序列" } { "newmatrix" "一个等长序列的序列" } }
{ $description "转置矩阵；即行变为列，列变为行。" }
{ $examples { $example "USING: prettyprint sequences ;" "{ { 1 2 3 } { 4 5 6 } } flip ." "{ { 1 4 } { 2 5 } { 3 6 } }" } } ;

HELP: exchange
{ $values { "m" "一个非负整数" } { "n" "一个非负整数" } { "seq" "一个可变的序列（sequence）" } }
{ $description "交换 " { $snippet "seq" } " 的第 " { $snippet "m" } " 个和第 " { $snippet "n" } " 个元素。" } ;

HELP: reverse!
{ $values { "seq" "一个可变的序列（sequence）" } }
{ $description "就地反转序列（sequence）并输出该序列。" }
{ $side-effects "seq" } ;

HELP: padding
{ $values { "seq" sequence } { "n" "一个非负整数" } { "elt" object } { "quot" { $quotation ( ... seq1 seq2 -- ... newseq ) } } { "newseq" "一个新序列（sequence）" } }
{ $description "输出一个由 " { $snippet "elt" } " 重复构成的新字符串序列，当将其追加到 " { $snippet "seq" } " 时，得到长度为 " { $snippet "n" } " 的序列。如果 " { $snippet "seq" } " 的长度大于 " { $snippet "n" } "，此词输出一个空序列。" } ;

HELP: pad-head
{ $values { "seq" sequence } { "n" "一个非负整数" } { "elt" object } { "padded" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由 " { $snippet "seq" } " 在左侧填充足够多的 " { $snippet "elt" } " 重复，使结果长度为 " { $snippet "n" } "。" }
{ $examples { $example "USING: io sequences ;" "{ \"ab\" \"quux\" } [ 5 CHAR: - pad-head print ] each" "---ab\n-quux" } } ;

HELP: pad-tail
{ $values { "seq" sequence } { "n" "一个非负整数" } { "elt" object } { "padded" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由 " { $snippet "seq" } " 在右侧填充足够多的 " { $snippet "elt" } " 重复，使结果长度为 " { $snippet "n" } "。" }
{ $examples { $example "USING: io sequences ;" "{ \"ab\" \"quux\" } [ 5 CHAR: - pad-tail print ] each" "ab---\nquux-" } } ;

HELP: sequence=
{ $values { "seq1" sequence } { "seq2" sequence } { "?" boolean } }
{ $description "测试两个序列（sequence）是否具有相同的长度和元素。这比 " { $link = } " 更弱，因为它不确保序列是同一类的实例。" } ;

HELP: reversed
{ $class-description "一个虚拟序列（sequence），呈现底层序列的反向视图。可以通过调用 " { $link <reversed> } " 创建新实例。" } ;

HELP: reverse
{ $values { "seq" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），其元素与 " { $snippet "seq" } " 相同但顺序相反。" } ;

{ reverse <reversed> reverse! } related-words

HELP: <reversed>
{ $values { "seq" sequence } { "reversed" "一个新序列（sequence）" } }
{ $description "创建 " { $link reversed } " 类的一个实例。" }
{ $see-also "virtual-sequences" } ;

HELP: slice-error
{ $values { "str" "一个原因" } }
{ $description "抛出一个 " { $link slice-error } " 错误。" }
{ $error-description "当以下无效条件之一成立时，由 " { $link <slice> } " 抛出："
    { $list
        "起始索引为负数"
        "结束索引大于序列（sequence）的长度"
        "起始索引大于结束索引"
    }
} ;

HELP: >slice<
{ $values
    { "slice" slice }
    { "from" integer } { "to" integer } { "seq" sequence }
}
{ $description "使用 " { $link slice } " 中的槽位设置栈以进行迭代。用于诸如 " { $link sequence-operator } " 等词的迭代中。" } ;

HELP: >underlying<
{ $values
    { "slice/seq" { $or slice sequence } }
    { "from" integer } { "to" integer }
}
{ $description "使用 " { $link sequence } " 中的槽位设置栈以进行迭代。用于诸如 " { $link sequence-operator } " 等词的迭代中。" } ;

HELP: slice
{ $class-description "一个虚拟序列（sequence），呈现底层序列元素的一个子范围。可以通过调用 " { $link <slice> } " 创建新实例。还提供了便捷词来创建一端为序列开头或结尾的切片（slice）；参见 " { $link "sequences-slices" } " 获取列表。"
$nl
"如果底层序列可变，则切片（slice）也可变，修改切片会改变底层序列。但是，切片（slice）在创建后不能调整大小。" } ;

HELP: check-slice
{ $values { "from" "一个非负整数" } { "to" "一个非负整数" } { "seq" sequence } }
{ $description "确保 " { $snippet "from" } " 小于或等于 " { $snippet "to" } "，且两个索引都在 " { $snippet "seq" } " 的范围内。" }
{ $errors "如果前提条件不满足，则抛出 " { $link slice-error } " 错误。" } ;

HELP: collapse-slice
{ $values { "m" "一个非负整数" } { "n" "一个非负整数" } { "slice" slice } { "m'" "一个非负整数" } { "n'" "一个非负整数" } { "seq" sequence } }
{ $description "通过相应调整起始和结束索引，并用其底层序列替换切片（slice），来准备获取切片的切片。" }
;

HELP: <slice>
{ $values { "from" "一个非负整数" } { "to" "一个非负整数" } { "seq" sequence } { "slice" slice } }
{ $description "输出一个新的虚拟序列（sequence），与 " { $snippet "seq" } " 中索引从 " { $snippet "from" } "（含）开始到 " { $snippet "to" } "（不含）结束的子范围元素共享存储。" }
{ $errors "如果 " { $snippet "from" } " 或 " { $snippet "to" } " 越界，则抛出错误。" }
{ $notes "获取切片（slice）的切片会输出底层序列的切片，而不是切片的切片。这意味着你不能假设结果切片（slice）的 " { $snippet "from" } " 和 " { $snippet "to" } " 槽位等于传递给 " { $link <slice> } " 的值。" } ;

{ <slice> subseq } related-words

HELP: repetition
{ $class-description "一个虚拟序列（sequence），由 " { $snippet "elt" } " 重复 " { $snippet "len" } " 次组成。重复通过调用 " { $link <repetition> } " 创建。" } ;

HELP: <repetition>
{ $values { "len" "一个非负整数" } { "elt" object } { "repetition" repetition } }
{ $description "创建一个新的 " { $link repetition } "。" }
{ $examples
    { $example "USING: arrays prettyprint sequences ;" "10 \"X\" <repetition> >array ." "{ \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" }" }
    { $example "USING: prettyprint sequences ;" "10 \"X\" <repetition> concat ." "\"XXXXXXXXXX\"" }
} ;

HELP: copy
{ $values { "src" sequence } { "i" "" { $snippet "dst" } " 中的一个索引" } { "dst" "一个可变的序列（sequence）" } }
{ $description "将 " { $snippet "src" } " 的所有元素复制到 " { $snippet "dst" } "，目标索引从 " { $snippet "i" } " 开始。如有必要，先增长 " { $snippet "dst" } "。" }
{ $side-effects "dst" }
{ $errors "如果 " { $snippet "dst" } " 不可调整大小，且不够大以容纳复制的元素，则抛出错误。" } ;

HELP: push-all
{ $values { "src" sequence } { "dst" "一个可调整大小且可变的序列（sequence）" } }
{ $description "将 " { $snippet "src" } " 追加到 " { $snippet "dst" } " 的末尾。" }
{ $side-effects "dst" }
{ $errors "如果 " { $snippet "src" } " 包含不允许放入 " { $snippet "dst" } " 中的元素，则抛出错误。" } ;

HELP: append
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "输出一个与 " { $snippet "seq1" } " 相同类型的新序列（sequence），由 " { $snippet "seq1" } " 的元素后跟 " { $snippet "seq2" } " 的元素组成。" }
{ $errors "如果 " { $snippet "seq2" } " 包含不允许放入与 " { $snippet "seq1" } " 相同类型的序列中的元素，则抛出错误。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "{ 1 2 } B{ 3 4 } append ."
        "{ 1 2 3 4 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"go\" \"ing\" append ."
        "\"going\""
    }
} ;

HELP: append-as
{ $values { "seq1" sequence } { "seq2" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "输出一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence），由 " { $snippet "seq1" } " 的元素后跟 " { $snippet "seq2" } " 的元素组成。" }
{ $errors "如果 " { $snippet "seq1" } " 或 " { $snippet "seq2" } " 包含不允许放入与 " { $snippet "exemplar" } " 相同类型的序列中的元素，则抛出错误。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "{ 1 2 } B{ 3 4 } B{ } append-as ."
        "B{ 1 2 3 4 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"go\" \"ing\" SBUF\" \" append-as ."
        "SBUF\" going\""
    }
} ;

{ append append-as append! 3append 3append-as push-all } related-words

HELP: prepend
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "输出一个与 " { $snippet "seq1" } " 相同类型的新序列（sequence），由 " { $snippet "seq2" } " 的元素后跟 " { $snippet "seq1" } " 的元素组成。" }
{ $errors "如果 " { $snippet "seq2" } " 包含不允许放入与 " { $snippet "seq1" } " 相同类型的序列中的元素，则抛出错误。" }
{ $examples { $example "USING: prettyprint sequences ;"
        "{ 1 2 } B{ 3 4 } prepend ."
        "{ 3 4 1 2 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"go\" \"car\" prepend ."
        "\"cargo\""
    }
} ;

HELP: prepend-as
{ $values { "seq1" sequence } { "seq2" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "输出一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence），由 " { $snippet "seq2" } " 的元素后跟 " { $snippet "seq1" } " 的元素组成。" }
{ $errors "如果 " { $snippet "seq1" } " 或 " { $snippet "seq2" } " 包含不允许放入与 " { $snippet "exemplar" } " 相同类型的序列中的元素，则抛出错误。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "{ 3 4 } B{ 1 2 } B{ } prepend-as ."
        "B{ 1 2 3 4 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"ing\" \"go\" SBUF\" \" prepend-as ."
        "SBUF\" going\""
    }
} ;

{ prepend prepend-as } related-words

HELP: 3append
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "输出一个新序列（sequence），依次由 " { $snippet "seq1" } "、" { $snippet "seq2" } " 和 " { $snippet "seq3" } " 的元素组成。" }
{ $errors "如果 " { $snippet "seq2" } " 或 " { $snippet "seq3" } " 包含不允许放入与 " { $snippet "seq1" } " 相同类型的序列中的元素，则抛出错误。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "\"a\" \"b\" \"c\" 3append ."
        "\"abc\""
    }
} ;

HELP: 3append-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "输出一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence），依次由 " { $snippet "seq1" } "、" { $snippet "seq2" } " 和 " { $snippet "seq3" } " 的元素组成。" }
{ $errors "如果 " { $snippet "seq1" } "、" { $snippet "seq2" } " 或 " { $snippet "seq3" } " 包含不允许放入与 " { $snippet "exemplar" } " 相同类型的序列中的元素，则抛出错误。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "\"a\" \"b\" \"c\" SBUF\" \" 3append-as ."
        "SBUF\" abc\""
    }
} ;

HELP: surround
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "输出一个新序列（sequence），将 " { $snippet "seq1" } " 插入在 " { $snippet "seq2" } " 和 " { $snippet "seq3" } " 之间。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"sssssh\" \"(\" \")\" surround ."
               "\"(sssssh)\""
    }
} ;

HELP: surround-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "输出一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence），将 " { $snippet "seq1" } " 插入在 " { $snippet "seq2" } " 和 " { $snippet "seq3" } " 之间。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"sssssh\" \"(\" \")\" SBUF\" \" surround-as ."
               "SBUF\" (sssssh)\""
    }
} ;

{ surround surround-as } related-words

HELP: glue
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "输出一个新序列（sequence），将 " { $snippet "seq3" } " 插入在 " { $snippet "seq1" } " 和 " { $snippet "seq2" } " 之间。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"a\" \"b\" \",\" glue ."
               "\"a,b\""
    }
} ;

HELP: glue-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "输出一个与 " { $snippet "exemplar" } " 相同类型的新序列（sequence），将 " { $snippet "seq3" } " 插入在 " { $snippet "seq1" } " 和 " { $snippet "seq2" } " 之间。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"a\" \"b\" \",\" SBUF\" \" glue-as ."
               "SBUF\" a,b\""
    }
} ;

{ glue glue-as } related-words

HELP: subseq
{ $values { "from" "一个非负整数" } { "to" "一个非负整数" } { "seq" sequence } { "subseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由从 " { $snippet "from" } "（含）开始到 " { $snippet "to" } "（不含）结束的所有元素组成。" }
{ $errors "如果 " { $snippet "from" } " 或 " { $snippet "to" } " 越界，则抛出错误。" } ;

HELP: subseq-as
{ $values { "from" "一个非负整数" } { "to" "一个非负整数" } { "seq" sequence } { "exemplar" sequence } { "subseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由从 " { $snippet "from" } "（含）开始到 " { $snippet "to" } "（不含）结束的所有元素组成，类型为 " { $snippet "exemplar" } "。" }
{ $errors "如果 " { $snippet "from" } " 或 " { $snippet "to" } " 越界，则抛出错误。" } ;

HELP: clone-like
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" "一个新序列（sequence）" } }
{ $description "输出一个新分配的序列（sequence），其元素与 " { $snippet "seq" } " 相同，但类型与 " { $snippet "exemplar" } " 相同。" }
{ $notes "与 " { $link like } " 不同，此词总是创建一个新序列，绝不与原始序列共享存储。" }
{ $examples
    { $example
        "USING: prettyprint sequences ;"
        "{ 1 2 3 } V{ } clone-like ."
        "V{ 1 2 3 }"
    }
    "演示没有共享存储："
    { $example
        "USING: kernel prettyprint sequences ;"
        "{ 1 2 3 } dup V{ } clone-like reverse! [ . ] bi@"
        "{ 1 2 3 }\nV{ 3 2 1 }"
    }
} ;

HELP: head-slice
{ $values { "seq" sequence } { "n" "一个非负整数" } { "slice" "一个切片（slice）" } }
{ $description "输出一个虚拟序列（sequence），与输入序列的前 " { $snippet "n" } " 个元素共享存储。" }
{ $errors "如果索引越界，则抛出错误。" } ;

HELP: tail-slice
{ $values { "seq" sequence } { "n" "一个非负整数" } { "slice" "一个切片（slice）" } }
{ $description "输出一个虚拟序列（sequence），与输入序列中从第 " { $snippet "n" } " 个索引到末尾的所有元素共享存储。" }
{ $errors "如果索引越界，则抛出错误。" } ;

HELP: but-last-slice
{ $values { "seq" sequence } { "slice" "一个切片（slice）" } }
{ $description "输出一个虚拟序列（sequence），与输入序列除最后一个元素外的所有元素共享存储。" }
{ $errors "对空序列抛出错误。" } ;

HELP: rest-slice
{ $values { "seq" sequence } { "slice" "一个切片（slice）" } }
{ $description "输出一个虚拟序列（sequence），与输入序列中从第 1 个索引到末尾的所有元素共享存储。" }
{ $notes "等价于 " { $snippet "1 tail" } }
{ $errors "对空序列抛出错误。" } ;

HELP: head-slice*
{ $values { "seq" sequence } { "n" "一个非负整数" } { "slice" "一个切片（slice）" } }
{ $description "输出一个虚拟序列（sequence），与 " { $snippet "seq" } " 中直到从末尾数第 " { $snippet "n" } " 个元素之前的所有元素共享存储。换句话说，它输出输入序列的前 " { $snippet "l-n" } " 个元素，其中 " { $snippet "l" } " 是其长度。" }
{ $errors "如果索引越界，则抛出错误。" } ;

{ head-slice head-slice* } related-words

HELP: tail-slice*
{ $values { "seq" sequence } { "n" "一个非负整数" } { "slice" "一个切片（slice）" } }
{ $description "输出一个虚拟序列（sequence），与输入序列的最后 " { $snippet "n" } " 个元素共享存储。" }
{ $errors "如果索引越界，则抛出错误。" } ;

{ tail-slice tail-slice* } related-words

HELP: head-to-index
{ $values
    { "seq" sequence } { "to" integer }
    { "zero" object }
}
{ $description "为 " { $link head } " 词设置栈。" } ;

HELP: head
{ $values { "seq" sequence } { "n" "一个非负整数" } { "headseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由输入序列的前 " { $snippet "n" } " 个元素组成。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 head ."
        "{ 1 2 }"
    }
    "当序列可能没有足够元素时："
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length head ."
        "{ 1 2 }"
    }
}
{ $errors "如果索引越界，则抛出错误。" } ;

HELP: index-to-tail
{ $values
    { "seq" sequence } { "from" integer }
    { "length" object }
}
{ $description "为 " { $link tail } " 词设置栈。" } ;

HELP: tail
{ $values { "seq" sequence } { "n" "一个非负整数" } { "tailseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由输入序列去掉前 " { $snippet "n" } " 个元素后组成。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 tail ."
        "{ 3 4 5 6 7 }"
    }
    "当序列可能没有足够元素时："
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length tail ."
        "{ }"
    }
}
{ $errors "如果索引越界，则抛出错误。" } ;

HELP: but-last
{ $values { "seq" sequence } { "headseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由输入序列去掉最后一个元素后组成。" }
{ $errors "对空序列抛出错误。" } ;

HELP: rest
{ $values { "seq" sequence } { "tailseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由输入序列去掉第一个元素后组成。" }
{ $errors "对空序列抛出错误。" } ;

HELP: head*
{ $values { "seq" sequence } { "n" "一个非负整数" } { "headseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由 " { $snippet "seq" } " 中直到从末尾数第 " { $snippet "n" } " 个元素之前的所有元素组成。换句话说，它删除最后 " { $snippet "n" } " 个元素。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 head* ."
        "{ 1 2 3 4 5 }"
    }
    "当序列可能没有足够元素时："
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length head* ."
        "{ }"
    }
}
{ $errors "如果索引越界，则抛出错误。" } ;

HELP: tail*
{ $values { "seq" sequence } { "n" "一个非负整数" } { "tailseq" "一个新序列（sequence）" } }
{ $description "输出一个新序列（sequence），由输入序列的最后 " { $snippet "n" } " 个元素组成。" }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 tail* ."
        "{ 6 7 }"
    }
    "当序列可能没有足够元素时："
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length tail* ."
        "{ 1 2 }"
    }
}
{ $errors "如果索引越界，则抛出错误。" } ;

{ tail tail* tail-slice tail-slice* } related-words
{ head head* head-slice head-slice* } related-words
{ cut cut* cut-slice cut-slice* } related-words
{ unclip unclip-slice unclip-last unclip-last-slice } related-words
{ first first2 last last2 but-last but-last-slice rest rest-slice } related-words

HELP: shorter?
{ $values { "seq1" sequence } { "seq2" sequence } { "?" boolean } }
{ $description "测试 " { $snippet "seq1" } " 的长度是否小于 " { $snippet "seq2" } " 的长度。" } ;

HELP: head?
{ $values { "seq" sequence } { "begin" sequence } { "?" boolean } }
{ $description "测试 " { $snippet "seq" } " 是否以 " { $snippet "begin" } " 开头。如果 " { $snippet "begin" } " 比 " { $snippet "seq" } " 长，此词输出 " { $link f } "。" }
{ $examples
  { $example
    "USING: prettyprint sequences ;"
    "{ \"accept\" \"adept\" \"advance\" \"advice\" \"affect\" } [ \"ad\" head? ] filter ."
    "{ \"adept\" \"advance\" \"advice\" }"
  }
} ;

HELP: tail?
{ $values { "seq" sequence } { "end" sequence } { "?" boolean } }
{ $description "测试 " { $snippet "seq" } " 是否以 " { $snippet "end" } " 结尾。如果 " { $snippet "end" } " 比 " { $snippet "seq" } " 长，此词输出 " { $link f } "。" } ;

{ remove remove-nth remove-eq remove-eq! remove! remove-nth! } related-words

HELP: cut-slice
{ $values { "seq" sequence } { "n" "一个非负整数" } { "before-slice" "一个切片（slice）" } { "after-slice" "一个切片（slice）" } }
{ $description "输出一对序列（sequence），其中 " { $snippet "before-slice" } " 是 " { $snippet "seq" } " 前 " { $snippet "n" } " 个元素的切片（slice），而 " { $snippet "after-slice" } " 是剩余元素的切片。" }
{ $notes "与 " { $link cut } " 不同，此词适合在迭代算法中使用，可以逐段切分序列（sequence）。" } ;

HELP: cut-slice*
{ $values { "seq" sequence } { "n" "一个非负整数" } { "before-slice" "一个切片（slice）" } { "after-slice" "一个切片（slice）" } }
{ $description "输出一对序列（sequence），其中 " { $snippet "after" } " 由 " { $snippet "seq" } " 的最后 " { $snippet "n" } " 个元素组成，而 " { $snippet "before-slice" } " 是剩余元素的切片（slice）。" }
{ $notes "与 " { $link cut* } " 不同，此词适合在迭代算法中使用，可以逐段切分序列（sequence）。" } ;

HELP: cut
{ $values { "seq" sequence } { "n" "一个非负整数" } { "before" sequence } { "after" sequence } }
{ $description "输出一对序列（sequence），其中 " { $snippet "before" } " 由 " { $snippet "seq" } " 的前 " { $snippet "n" } " 个元素组成，而 " { $snippet "after" } " 保存剩余元素。两个输出序列与 " { $snippet "seq" } " 具有相同的类型。" }
{ $notes "由于此词会复制序列的整个尾部，因此不应在循环中使用。如果这一点很重要，请考虑使用 " { $link cut-slice } " 代替，因为它为尾部返回一个切片（slice）而不是复制。" } ;

HELP: cut*
{ $values { "seq" sequence } { "n" "一个非负整数" } { "before" sequence } { "after" sequence } }
{ $description "输出一对序列（sequence），其中 " { $snippet "after" } " 由 " { $snippet "seq" } " 的最后 " { $snippet "n" } " 个元素组成，而 " { $snippet "before" } " 保存剩余元素。两个输出序列与 " { $snippet "seq" } " 具有相同的类型。" } ;

HELP: subseq-starts-at?
{ $values { "i" "起始索引" } { "seq" sequence } { "subseq" sequence } { "?" boolean } }
{ $description "如果子序列（subsequence）从第 " { $snippet "i" } " 个元素开始则输出 " { $snippet "t" } "，如果序列不在该位置则输出 " { $link f } "。" } ;

HELP: subseq-index
{ $values { "seq" sequence } { "subseq" sequence } { "i/f" "起始索引或 " { $snippet "f" } } }
{ $description "输出第一个等于 " { $snippet "subseq" } " 的连续子序列（subsequence）的起始索引。如果未找到匹配的子序列，则输出 " { $link f } "。" } ;

HELP: subseq-index-from
{ $values { "n" "起始索引" } { "seq" sequence } { "subseq" sequence } { "i/f" "起始索引或 " { $snippet "f" } } }
{ $description "输出第一个等于 " { $snippet "subseq" } " 的连续子序列（subsequence）的起始索引，从第 " { $snippet "n" } " 个元素开始搜索。如果未找到匹配的子序列，则输出 " { $link f } "。" } ;

HELP: subseq-start-from
{ $values
    { "subseq" object } { "seq" sequence } { "n" integer }
    { "i/f" { $maybe integer } }
}
{ $description "输出第一个等于 " { $snippet "subseq" } " 的连续子序列（subsequence）的起始索引，从第 " { $snippet "n" } " 个元素开始搜索。如果未找到匹配的子序列，则输出 " { $link f } "。" } ;

HELP: subseq-start
{ $values { "subseq" sequence } { "seq" sequence } { "i/f" "起始索引或 " { $snippet "f" } } }
{ $description "输出第一个等于 " { $snippet "subseq" } " 的连续子序列（subsequence）的起始索引。如果未找到匹配的子序列，则输出 " { $link f } "。" } ;

HELP: subseq?
{ $values { "subseq" sequence } { "seq" sequence } { "?" boolean } }
{ $description "测试 " { $snippet "seq" } " 是否包含 " { $snippet "subseq" } " 的元素作为一个连续子序列（subsequence）。" } ;

HELP: subseq-of?
{ $values { "seq" sequence } { "subseq" sequence } { "?" boolean } }
{ $description "测试 " { $snippet "seq" } " 是否包含 " { $snippet "subseq" } " 的元素作为一个连续子序列（subsequence）。" } ;

HELP: drop-prefix
{ $values { "seq1" sequence } { "seq2" sequence } { "slice1" "一个切片（slice）" } { "slice2" "一个切片（slice）" } }
{ $description "输出一对虚拟序列（sequence），去掉 " { $snippet "seq1" } " 和 " { $snippet "seq2" } " 的公共前缀。" } ;

HELP: unclip
{ $values { "seq" sequence } { "rest" sequence } { "first" object } }
{ $description "输出 " { $snippet "seq" } " 的尾部序列（sequence）和第一个元素；尾部序列由 " { $snippet "seq" } " 除第一个元素外的所有元素组成。" }
{ $examples
    { $example "USING: prettyprint sequences ;" "{ 1 2 3 } unclip suffix ." "{ 2 3 1 }" }
} ;

HELP: unclip-slice
{ $values { "seq" sequence } { "rest-slice" slice } { "first" object } }
{ $description "输出 " { $snippet "seq" } " 的尾部序列（sequence）和第一个元素；尾部序列由 " { $snippet "seq" } " 除第一个元素外的所有元素组成。与 " { $link unclip } " 不同，此词不复制输入序列，且以常数时间运行。" }
{ $examples { $example "USING: math.order prettyprint sequences ;" "{ 3 -1 -10 5 7 } unclip-slice [ min ] reduce ." "-10" } } ;

HELP: unclip-last
{ $values { "seq" sequence } { "butlast" sequence } { "last" object } }
{ $description "输出 " { $snippet "seq" } " 的头部序列（sequence）和最后一个元素；头部序列由 " { $snippet "seq" } " 除最后一个元素外的所有元素组成。" }
{ $examples
    { $example "USING: prettyprint sequences ;" "{ 1 2 3 } unclip-last prefix ." "{ 3 1 2 }" }
} ;

HELP: unclip-last-slice
{ $values { "seq" sequence } { "butlast-slice" slice } { "last" object } }
{ $description "输出 " { $snippet "seq" } " 的头部序列（sequence）和最后一个元素；头部序列由 " { $snippet "seq" } " 除最后一个元素外的所有元素组成。与 " { $link unclip-last } " 不同，此词不复制输入序列，且以常数时间运行。" } ;

HELP: sum
{ $values { "seq" { $sequence number } } { "n" number } }
{ $description "输出 " { $snippet "seq" } " 所有元素的和。给定空序列时输出零。" }
{ $examples
    [=[
        USING: prettyprint sequences ;
        { 3 1 5 } sum .
        9
    ]=]
    [=[
        USING: prettyprint sequences ;
        { } sum .
        0
    ]=]
} ;

HELP: product
{ $values { "seq" { $sequence number } } { "n" number } }
{ $description "输出 " { $snippet "seq" } " 所有元素的乘积。给定空序列时输出一。" } ;

HELP: minimum
{ $values { "seq" sequence } { "elt" object } }
{ $description "输出 " { $snippet "seq" } " 的最小元素。" }
{ $examples
    "示例："
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 } minimum ."
        "1"
    }
    "示例："
    { $example "USING: sequences prettyprint ;"
        "{ \"c\" \"b\" \"a\" } minimum ."
        "\"a\""
    }
}
{ $errors "如果序列为空，则抛出错误。" } ;

HELP: minimum-by
{ $values
    { "seq" sequence } { "quot" quotation }
    { "elt" object }
}
{ $description "根据 " { $snippet "quot" } " 输出 " { $snippet "seq" } " 的最小元素。" }
{ $examples
    "示例："
    { $example "USING: sequences prettyprint ;"
        "{ { 1 2 } { 1 2 3 } { 1 2 3 4 } } [ length ] minimum-by ."
        "{ 1 2 }"
    }
}
{ $errors "如果序列为空，则抛出错误。" } ;

HELP: maximum
{ $values { "seq" sequence } { "elt" object } }
{ $description "输出 " { $snippet "seq" } " 的最大元素。" }
{ $examples
    "示例："
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 } maximum ."
        "5"
    }
    "示例："
    { $example "USING: sequences prettyprint ;"
        "{ \"c\" \"b\" \"a\" } maximum ."
        "\"c\""
    }
}
{ $errors "如果序列为空，则抛出错误。" } ;

HELP: maximum-by
{ $values
    { "seq" sequence } { "quot" quotation }
    { "elt" object }
}
{ $description "根据 " { $snippet "quot" } " 输出 " { $snippet "seq" } " 的最大元素。" }
{ $examples
    "示例："
    { $example "USING: sequences prettyprint ;"
        "{ { 1 2 } { 1 2 3 } { 1 2 3 4 } } [ length ] maximum-by ."
        "{ 1 2 3 4 }"
    }
}
{ $errors "如果序列为空，则抛出错误。" } ;

{ min max minimum minimum-by maximum maximum-by } related-words

HELP: shortest
{ $values { "seqs" sequence } { "elt" object } }
{ $description "输出 " { $snippet "seqs" } " 中最短的序列（sequence）。" } ;

HELP: longest
{ $values { "seqs" sequence } { "elt" object } }
{ $description "输出 " { $snippet "seqs" } " 中最长的序列（sequence）。" } ;

{ shortest longest } related-words

HELP: produce
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "quot" { $quotation ( ..b -- ..a obj ) } } { "seq" sequence } }
{ $description "重复调用 " { $snippet "pred" } "。如果谓词产生 " { $link f } "，则停止，否则调用 " { $snippet "quot" } " 产生一个值。值被累积并在最后返回为一个序列（sequence）。" }
{ $examples
    "以下示例将一个数字反复除以 2 直到达到零，并累积中间结果："
    { $example "USING: kernel math prettyprint sequences ;" "1337 [ dup 0 > ] [ 2/ dup ] produce nip ." "{ 668 334 167 83 41 20 10 5 2 1 0 }" }
    "以下示例在随机数大于 1 时收集它们："
    { $unchecked-example "USING: kernel prettyprint random sequences ;" "[ 10 random dup 1 > ] [ ] produce nip ." "{ 8 2 2 9 }" }
} ;

HELP: produce-as
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "quot" { $quotation ( ..b -- ..a obj ) } } { "exemplar" sequence } { "seq" sequence } }
{ $description "重复调用 " { $snippet "pred" } "。如果谓词产生 " { $link f } "，则停止，否则调用 " { $snippet "quot" } " 产生一个值。值被累积并在最后返回为一个类型为 " { $snippet "exemplar" } " 的序列（sequence）。" }
{ $examples "参见 " { $link produce } " 的示例。" } ;

HELP: map-sum
{ $values { "seq" sequence } { "quot" quotation } { "n" number } }
{ $description "类似于 " { $snippet "map sum" } "，但不创建中间序列（sequence）。" }
{ $examples
    { $example
        "USING: math ranges sequences prettyprint ;"
        "100 [1..b] [ sq ] map-sum ."
        "338350"
    }
} ;

HELP: count
{ $values { "seq" sequence } { "quot" quotation } { "n" integer } }
{ $description "高效地返回谓词引用匹配的元素数量。" }
{ $examples
    { $example
        "USING: math ranges sequences prettyprint ;"
        "100 [1..b] [ even? ] count ."
        "50"
    }
} ;

HELP: selector
{ $values
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "selector" { $quotation ( ... elt -- ... ) } } { "accum" vector } }
{ $description "创建一个新的 vector 来累积对谓词返回真值的值。返回一个新的引用，该引用接受一个要测试的对象，如果测试结果为真则将其存储在收集器中。为了方便，收集器被保留在栈上。" }
{ $examples
    { $example "! 查找所有偶数：" "USING: prettyprint sequences math kernel ;"
               "10 <iota> [ even? ] selector [ each ] dip ."
               "V{ 0 2 4 6 8 }"
    }
}
{ $notes "用于实现 " { $link filter } " 词。将此词与 " { $link collector } " 比较，后者是一个不进行过滤的版本。" } ;

HELP: trim-head
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence } }
{ $description "从序列（sequence）左侧开始删除与谓词匹配的元素。一旦某个元素不匹配，测试即停止，序列的其余部分作为新序列保留在栈上。" }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-head ."
               "{ 1 2 3 0 0 }"
    }
} ;

HELP: trim-head-slice
{ $values
    { "seq" sequence } { "quot" quotation }
    { "slice" slice } }
{ $description "从序列（sequence）左侧开始删除与谓词匹配的元素。一旦某个元素不匹配，测试即停止，序列的其余部分作为切片（slice）保留在栈上。" }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-head-slice ."
               "T{ slice { from 2 } { to 7 } { seq { 0 0 1 2 3 0 0 } } }"
    }
} ;

HELP: trim-tail
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence } }
{ $description "从序列（sequence）右侧开始删除与谓词匹配的元素。一旦某个元素不匹配，测试即停止，序列的其余部分作为新序列保留在栈上。" }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-tail ."
               "{ 0 0 1 2 3 }"
    }
} ;

HELP: trim-tail-slice
{ $values
    { "seq" sequence } { "quot" quotation }
    { "slice" slice } }
{ $description "从序列（sequence）右侧开始删除与谓词匹配的元素。一旦某个元素不匹配，测试即停止，序列的其余部分作为切片（slice）保留在栈上。" }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-tail-slice ."
               "T{ slice { to 5 } { seq { 0 0 1 2 3 0 0 } } }"
    }
} ;

HELP: trim
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence } }
{ $description "从序列（sequence）的左右两侧开始删除与谓词匹配的元素。一旦某个元素不匹配，测试即停止，序列的其余部分作为新序列保留在栈上。" }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim ."
               "{ 1 2 3 }"
    }
} ;

HELP: trim-slice
{ $values
    { "seq" sequence } { "quot" quotation }
    { "slice" slice } }
{ $description "从序列（sequence）的左右两侧开始删除与谓词匹配的元素。一旦某个元素不匹配，测试即停止，序列的其余部分作为切片（slice）保留在栈上。" }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-slice ."
               "T{ slice { from 2 } { to 5 } { seq { 0 0 1 2 3 0 0 } } }"
    }
} ;

{ trim trim-slice trim-head trim-head-slice trim-tail trim-tail-slice } related-words

HELP: sift
{ $values
    { "seq" sequence }
    { "newseq" sequence } }
{ $description "输出一个新序列（sequence），移除了所有 " { $link f } " 的实例。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "{ \"a\" 3 { } f } sift ."
        "{ \"a\" 3 { } }"
    }
} ;

HELP: harvest
{ $values
    { "seq" sequence }
    { "newseq" sequence } }
{ $description "输出一个新序列（sequence），移除了所有空序列。" }
{ $examples
    { $example "USING: prettyprint sequences ;"
               "{ { } { 2 3 } { 5 } { } } harvest ."
               "{ { 2 3 } { 5 } }"
    }
} ;

{ filter filter-as filter! reject reject-as reject! sift harvest } related-words

HELP: set-first
{ $values
    { "first" object } { "seq" sequence } }
{ $description "设置序列（sequence）的第一个元素。" }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-first ."
        "{ 5 2 3 4 }"
    }
} ;

HELP: set-second
{ $values
    { "second" object } { "seq" sequence } }
{ $description "设置序列（sequence）的第二个元素。" }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-second ."
        "{ 1 5 3 4 }"
    }
} ;

HELP: set-third
{ $values
    { "third" object } { "seq" sequence } }
{ $description "设置序列（sequence）的第三个元素。" }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-third ."
        "{ 1 2 5 4 }"
    }
} ;

HELP: set-fourth
{ $values
    { "fourth" object } { "seq" sequence } }
{ $description "设置序列（sequence）的第四个元素。" }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-fourth ."
        "{ 1 2 3 5 }"
    }
} ;

{ set-first set-second set-third set-fourth } related-words

HELP: replicate
{ $values
    { "len" integer } { "quot" { $quotation ( ... -- ... newelt ) } }
    { "newseq" sequence } }
    { $description "调用引用 " { $snippet "len" } " 次，将结果收集到一个新的 array 中。" }
{ $examples
    { $unchecked-example "USING: kernel prettyprint random sequences ;"
        "5 [ 100 random ] replicate ."
        "{ 52 10 45 81 30 }"
    }
} ;

HELP: replicate-as
{ $values
    { "len" integer } { "quot" { $quotation ( ... -- ... newelt ) } } { "exemplar" sequence }
    { "newseq" sequence } }
{ $description "调用引用 " { $snippet "len" } " 次，将结果收集到一个与示例序列（sequence）相同类型的新序列中。" }
{ $examples
    { $unchecked-example "USING: prettyprint kernel sequences ;"
        "5 [ 100 random ] B{ } replicate-as ."
        "B{ 44 8 2 33 18 }"
    }
} ;

{ replicate replicate-as } related-words

HELP: partition
{ $values
    { "seq" sequence } { "quot" quotation }
    { "trueseq" sequence } { "falseseq" sequence } }
    { $description "对输入序列（sequence）的每个元素调用谓词引用。如果测试结果为真，元素被添加到 " { $snippet "trueseq" } "；如果为假，则添加到 " { $snippet "falseseq" } "。" }
{ $examples
    { $example "USING: prettyprint kernel math sequences ;"
        "{ 1 2 3 4 5 } [ even? ] partition [ . ] bi@"
        "{ 2 4 }\n{ 1 3 5 }"
    }
} ;

HELP: virtual-exemplar
{ $values
    { "seq" sequence }
    { "seq'" sequence } }
{ $description "作为虚拟序列（sequence）协议的一部分，此词用于返回底层存储的一个示例。用于诸如 " { $link new-sequence } " 等词中。" }
{ $examples
    [=[
        USING: prettyprint sequences ;
        1 3 { 14 15 16 17 } <slice> virtual-exemplar .
        { 14 15 16 17 }
    ]=]
} ;

HELP: virtual@
{ $values
    { "n" integer } { "seq" sequence }
    { "n'" integer } { "seq'" sequence } }
{ $description "作为序列（sequence）协议的一部分，此词将输入索引 " { $snippet "n" } " 转换为一个索引以及该索引指向的底层存储。" }
{ $examples
    { $example
        "USING: kernel prettyprint sequences ;"
        "0 { 1 2 3 4 5 6 } <reversed> virtual@ [ . ] bi@"
        "5\n{ 1 2 3 4 5 6 }"
    }
} ;

HELP: 2map-reduce
{ $values
    { "seq1" sequence } { "seq2" sequence } { "map-quot" { $quotation ( ..a elt1 elt2 -- ..a intermediate ) } } { "reduce-quot" { $quotation ( ..a prev intermediate -- ..a next ) } }
    { "result" object } }
{ $description "对 " { $snippet "seq1" } " 和 " { $snippet "seq2" } " 中的每对元素调用 " { $snippet "map-quot" } "，并使用 " { $snippet "reduce-quot" } " 以与 " { $link reduce } " 相同的方式组合结果，但没有标识元素，且序列（sequence）的长度必须至少为 1。" }
{ $errors "如果序列为空，则抛出错误。" }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 10 30 50 } { 200 400 600 } [ + ] [ + ] 2map-reduce ."
    "1290"
} } ;

HELP: 2selector
{ $values
    { "quot" quotation }
    { "selector" quotation } { "accum1" vector } { "accum2" vector } }
{ $description "创建两个新的 vector 来基于谓词累积值。第一个 vector 累积谓词产生真值的值；第二个累积产生假值的值。" } ;

HELP: collector
{ $values
    { "quot" quotation }
    { "quot'" quotation } { "vec" vector } }
{ $description "创建一个新的引用，将其结果压入一个 vector 并在栈上输出该 vector。" }
{ $examples { $example "USING: sequences prettyprint kernel math ;"
    "{ 1 2 } [ 30 + ] collector [ each ] dip ."
    "V{ 31 32 }"
} } ;

HELP: binary-reduce
{ $values
    { "seq" sequence } { "start" integer } { "quot" { $quotation ( elt1 elt2 -- newelt ) } }
    { "value" object } }
{ $description "类似于 " { $link reduce } "，但递归地将序列（sequence）分成两半，直到每个序列足够小，然后在这些较小的序列上调用引用。如果引用计算的值取决于其输入的大小，比如大数运算，那么此算法比使用 " { $link reduce } " 更高效。" }
{ $examples "计算阶乘："
    { $example "USING: prettyprint sequences math ;"
    "40 <iota> rest-slice 1 [ * ] binary-reduce ."
    "20397882081197443358640281739902897356800000000" }
} ;

HELP: follow
{ $values
    { "obj" object } { "quot" { $quotation ( ... prev -- ... result/f ) } }
    { "seq" sequence } }
{ $description "输出一个序列（sequence），其中包含输入对象以及通过将递归地在输入对象上调用引用所产生的结果依次馈送给引用而生成的所有对象。引用产生的对象被添加到输出序列中，直到引用产生 " { $link f } "，此时递归终止。" }
{ $examples "获取随机数直到达到零："
    { $unchecked-example
    "USING: random sequences prettyprint math ;"
    "100 [ random [ f ] when-zero ] follow ."
    "{ 100 86 34 32 24 11 7 2 }"
} } ;

HELP: halves
{ $values
    { "seq" sequence }
    { "first-slice" slice } { "second-slice" slice } }
{ $description "在中点将序列（sequence）分成两个切片（slice）。如果序列有奇数个元素，多余的元素返回在第二个切片中。" }
{ $examples { $example "USING: arrays sequences prettyprint kernel ;"
    "{ 1 2 3 4 5 } halves [ >array . ] bi@"
    "{ 1 2 }\n{ 3 4 5 }"
} } ;

HELP: indices
{ $values
    { "obj" object } { "seq" sequence }
    { "indices" sequence } }
{ $description "将输入对象与序列（sequence）中的每个元素进行比较，并返回一个 vector，包含找到该元素的每个位置的索引。" }
{ $examples { $example "USING: sequences prettyprint ;"
    "2 { 2 4 2 6 2 8 2 10 } indices ."
    "V{ 0 2 4 6 }"
} } ;

HELP: insert-nth
{ $values
    { "elt" object } { "n" integer } { "seq" sequence }
    { "seq'" sequence } }
{ $description "创建一个新序列（sequence），其中第 " { $snippet "n" } " 个索引被设置为输入对象。" }
{ $examples { $example "USING: prettyprint sequences ;"
    "40 3 { 10 20 30 50 } insert-nth ."
    "{ 10 20 30 40 50 }"
} } ;

HELP: map-reduce
{ $values
    { "seq" sequence } { "map-quot" { $quotation ( ..a elt -- ..a intermediate ) } } { "reduce-quot" { $quotation ( ..a prev intermediate -- ..a next ) } }
    { "result" object } }
{ $description "对每个元素调用 " { $snippet "map-quot" } "，并使用 " { $snippet "reduce-quot" } " 以与 " { $link reduce } " 相同的方式组合结果，但没有标识元素，且序列（sequence）的长度必须至少为 1。" }
{ $errors "如果序列为空，则抛出错误。" }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 1 3 5 } [ sq ] [ + ] map-reduce ."
    "35"
} } ;

HELP: new-like
{ $values
    { "len" integer } { "exemplar" "一个示例序列（sequence）" } { "quot" quotation }
    { "seq" sequence } }
{ $description "创建一个长度为 " { $snippet "len" } " 的新序列（sequence），并在栈上有此序列的情况下调用引用。引用的输出和原始示例随后传递给 " { $link like } "，使输出序列成为示例的类型。" } ;

HELP: push-either
{ $values
    { "elt" object } { "quot" quotation } { "accum1" vector } { "accum2" vector } }
{ $description "将输入对象压入其中一个累加器；如果引用产生真值则压入第一个，否则压入第二个。" } ;

HELP: sequence-hashcode
{ $values
    { "depth" integer } { "seq" sequence }
    { "x" integer } }
{ $description "迭代序列（sequence），使用 " { $link hashcode* } " 为每个元素计算哈希码，并将它们组合起来。" } ;

HELP: index-or-length
{ $values
    { "seq" sequence } { "n" integer } { "n'" integer } }
{ $description "返回输入序列（sequence）和其长度与 " { $snippet "n" } " 中较小的那个。" }
{ $examples { $example "USING: sequences kernel prettyprint ;"
    "\"abcd\" 3 index-or-length [ . ] bi@"
    "\"abcd\"\n3"
} } ;

HELP: shorten
{ $values
    { "n" integer } { "seq" sequence } }
{ $description "将 " { $link "growable" } " 序列（sequence）缩短为 " { $snippet "n" } " 个元素长。" }
{ $examples { $example "USING: sequences prettyprint kernel ;"
    "V{ 1 2 3 4 5 } 3 over shorten ."
    "V{ 1 2 3 }"
} } ;

HELP: <iota>
{ $values { "n" integer } { "iota" iota } }
{ $description "创建一个不可变的虚拟序列（sequence），包含从 0 到 " { $snippet "n-1" } " 的整数。" }
{ $examples
  { $example
    "USING: math sequences prettyprint ;"
    "3 <iota> [ sq ] map ."
    "{ 0 1 4 }"
  }
} ;

HELP: assert-sequence=
{ $values
    { "a" sequence } { "b" sequence }
}
{ $description "如果两个序列（sequence）的所有元素成对比较不相等，则抛出错误。" }
{ $notes "序列不需要是相同类型。" }
{ $examples
  { $code
    "USING: prettyprint sequences ;"
    "{ 1 2 3 } V{ 1 2 3 } assert-sequence="
  }
} ;

HELP: cartesian-find
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ? ) } } { "elt1" object } { "elt2" object } }
{ $description "将引用应用于两个序列（sequence）元素的每种可能配对，返回引用返回真值的第一对元素。" } ;

HELP: cartesian-each
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ) } } }
{ $description "将引用应用于两个序列（sequence）元素的每种可能配对。" } ;

HELP: cartesian-map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... newelt ) } } { "newseq" "一个新的序列的序列（sequence）" } }
{ $description "将引用应用于两个序列（sequence）元素的每种可能配对，将结果收集到一个新的序列的序列中。" } ;

HELP: cartesian-product-as
{ $values { "seq1" sequence } { "seq2" sequence } { "exemplar" sequence } { "newseq" "一个新的成对序列的序列（sequence）" } }
{ $description "输出两个序列（sequence）元素所有可能配对的序列，使输出序列成为示例的类型。" }
{ $examples
    { $example
        "USING: bit-arrays prettyprint sequences ;"
        "\"ab\" ?{ t f } { } cartesian-product-as ."
        "{ { { 97 t } { 97 f } } { { 98 t } { 98 f } } }"
    }
} ;

HELP: cartesian-product
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" "一个新的成对序列的序列（sequence）" } }
{ $description "输出两个序列（sequence）元素所有可能配对的序列，使用 " { $snippet "seq2" } " 的类型。" }
{ $examples
    { $example
        "USING: prettyprint sequences ;"
        "{ 1 2 } { 3 4 } cartesian-product ."
        "{ { { 1 3 } { 1 4 } } { { 2 3 } { 2 4 } } }"
    }
    { $example
        "USING: prettyprint sequences ;"
        "\"abc\" \"def\" cartesian-product ."
        "{ { \"ad\" \"ae\" \"af\" } { \"bd\" \"be\" \"bf\" } { \"cd\" \"ce\" \"cf\" } }"
    }
} ;

{ cartesian-find cartesian-each cartesian-map cartesian-product cartesian-product-as } related-words

ARTICLE: "sequences-unsafe" "不安全的序列操作"
"" { $link nth-unsafe } " 和 " { $link set-nth-unsafe } " 序列（sequence）协议绕过边界检查以提高性能。"
$nl
"这些词假设给定的序列索引在边界内；如果不在，可能导致内存损坏。使用这些词时必须格外小心。首先，确保相关代码确实是一个瓶颈；接下来，尝试先改进算法。如果所有方法都失败了，那么可以使用不安全的序列词。"
$nl
"这些词必须保持一个非常重要的不变量：如果在某个时间点，序列（sequence）的长度为 " { $snippet "n" } "，那么任何对低于 " { $snippet "n" } " 的索引处元素的未来查找都不能导致 VM 崩溃，即使序列长度现在小于 " { $snippet "n" } "。例如，vector 通过从不缩小底层存储、只在必要时增长来保持这个不变量。"
$nl
"这样做的理由是，如果在迭代组合子的执行过程中调整了可调整大小序列（sequence）的大小，VM 不应该崩溃。"
$nl
"事实上，迭代组合子是这些词的主要用例；如果迭代索引已经由确保其在边界内的循环测试保护，那么额外的边界检查是多余的。例如，参见 " { $link each } " 的实现。" ;

ARTICLE: "sequence-protocol" "序列协议"
"所有序列（sequence）必须是混入类的实例："
{ $subsections sequence sequence? }
"所有序列必须知道其长度："
{ $subsections length }
"以下两个泛型词中至少有一个必须具有访问元素的方法；" { $link sequence } " 混入类具有默认定义，它们是相互递归的："
{ $subsections nth nth-unsafe ?nth }
"注意，序列（sequence）总是从零开始索引。"
$nl
"以下两个泛型词中至少有一个必须具有存储元素的方法；" { $link sequence } " 混入类具有默认定义，它们是相互递归的："
{ $subsections set-nth set-nth-unsafe ?set-nth }
"如果你的序列（sequence）是不可变的，那么你必须实现 " { $link set-nth } " 或 " { $link set-nth-unsafe } " 来简单地调用 " { $link immutable } " 以发出错误信号。"
$nl
"以下两个泛型词是可选的，因为并非所有序列都可以调整大小："
{ $subsections set-length lengthen }
"一个可选的泛型词，用于创建与给定序列（sequence）相同类的序列："
{ $subsections like }
"可选的泛型词，用于优化目的："
{ $subsections new-sequence new-resizable }
{ $see-also "sequences-unsafe" } ;

ARTICLE: "virtual-sequences-protocol" "虚拟序列协议"
"虚拟序列（sequence）必须知道其长度："
{ $subsections length }
"底层存储的示例："
{ $subsections virtual-exemplar }
"值所在的索引和底层存储："
{ $subsections virtual@ } ;

ARTICLE: "virtual-sequences" "虚拟序列"
"虚拟序列（sequence）是 " { $link "sequence-protocol" } " 的一种实现，它不存储自己的元素，而是计算它们，可以从头开始计算或从另一个序列中检索。"
$nl
"实现包括以下内容："
{ $subsections reversed slice }
"虚拟序列（sequence）可以通过 " { $link "virtual-sequences-protocol" } " 来实现，将虚拟序列中的索引转换为另一个序列中的索引。"
{ $see-also "sequences-integers" } ;

ARTICLE: "sequences-integers" "计数循环"
"为从零开始的整数迭代定义了一个虚拟序列（sequence）。"
{ $subsection <iota> }
"例如，对整数 3 调用 " { $link <iota> } " 产生一个包含元素 0、1 和 2 的序列（sequence）。这对于使用诸如 " { $link each } " 等词执行计数循环非常有用："
{ $example "USING: sequences prettyprint ; 3 <iota> [ . ] each" "0\n1\n2" }
"一个常见的用法是在迭代序列（sequence）的同时维护一个循环计数器。可以使用 " { $link each-index } "、" { $link map-index } " 和 " { $link reduce-index } " 来实现。"
$nl
"产生新序列（sequence）的组合子，如 " { $link map } "，如果输入是 " { $link <iota> } " 的实例，将输出一个 array。"
$nl
"可以使用 " { $link "ranges" } " 执行更复杂的计数循环。" ;

ARTICLE: "sequences-if" "序列的控制流"
"为了减少检查序列（sequence）是否为空的样板代码，提供了几个组合子。"
$nl
"检查序列是否为空："
{ $subsections if-empty when-empty unless-empty } ;

ARTICLE: "sequences-access" "访问序列元素"
"通过索引访问元素，不抛出异常："
{ $subsections ?nth }
"提取前四个元素之一的简洁方式："
{ $subsections first second third fourth ?first ?second }
"提取最后一个元素："
{ $subsections last ?last }
"解包序列（sequence）："
{ $subsections first2 first3 first4 last2 }
{ $see-also nth } ;

ARTICLE: "sequences-add-remove" "添加和删除序列元素"
"添加元素："
{ $subsections prefix suffix insert-nth }
"删除元素："
{ $subsections remove remove-eq remove-nth } ;

ARTICLE: "sequences-reshape" "重塑序列"
"一个 " { $emphasis "重复" } " 是一个虚拟序列（sequence），由单个元素重复多次组成："
{ $subsections repetition <repetition> }
"反转序列（sequence）："
{ $subsections reverse }
"一个 " { $emphasis "反转" } " 是一个虚拟序列（sequence），呈现底层序列的反向视图："
{ $subsections reversed <reversed> }
"转置矩阵："
{ $subsections flip } ;

ARTICLE: "sequences-appending" "追加序列"
"基本追加操作："
{ $subsections
    append
    append-as
    prepend
    3append
    3append-as
    surround
    surround-as
    glue
    glue-as
}
"将序列（sequence）折叠到自身："
{ $subsections concat concat-as join join-as }
"一对用于对齐字符串的词："
{ $subsections pad-head pad-tail } ;

ARTICLE: "sequences-slices" "子序列和切片"
"有两种方式从序列（sequence）中提取元素的子范围。第一种方法创建一个与输入相同类型的新序列，不与底层序列共享存储。这需要的时间与要提取的元素数量成正比。第二种方法创建一个" { $emphasis "切片（slice）" } "，它是一种虚拟序列（参见 " { $link "virtual-sequences" } "），与原始序列共享存储。切片（slice）以常数时间构造。"
$nl
"在两种方法之间选择的一些通用指导原则："
{ $list
  "如果使用可变状态，由于语义原因必须以某种方式做出选择；修改切片将改变底层序列（sequence）。"
  { "使用切片（slice）可以改善算法复杂度。例如，如果循环的每次迭代使用 " { $link first } " 和 " { $link rest } " 分解一个序列（sequence），那么循环将以相对于序列长度的二次时间运行。使用 " { $link rest-slice } " 将循环改为线性时间运行，因为 " { $link rest-slice } " 不复制任何元素。获取切片的切片会\"折叠\"切片以避免双重间接引用，因此在递归代码中使用切片是安全的。" }
  "从具体序列（sequence）（如 string 或 array）访问元素通常比从切片访问元素更快，因为切片访问需要额外的间接引用。但是，在某些情况下，如果切片立即被迭代组合子消费，编译器可以完全消除切片分配和间接引用。"
  "如果切片（slice）比原始序列（sequence）存活时间更长，原始序列仍然保留在内存中，因为切片会引用它。这可能不必要地增加内存消耗。"
}
{ $heading "子序列（subsequence）操作" }
"提取子序列（subsequence）："
{ $subsections
    subseq
    subseq-as
    head
    tail
    head*
    tail*
}
"删除第一个或最后一个元素："
{ $subsections rest but-last }
"将序列（sequence）分解为头部和尾部："
{ $subsections
    unclip
    unclip-last
    cut
    cut*
}
{ $heading "切片（slice）操作" }
"切片（slice）数据类型："
{ $subsections slice slice? }
"提取切片（slice）："
{ $subsections
    <slice>
    head-slice
    tail-slice
    head-slice*
    tail-slice*
}
"删除第一个或最后一个元素："
{ $subsections rest-slice but-last-slice }
"将序列（sequence）分解为头部和尾部："
{ $subsections unclip-slice unclip-last-slice cut-slice }
"用新元素替换切片（slice）："
{ $subsections replace-slice } ;

ARTICLE: "sequences-combinators" "序列组合子"
"迭代："
{ $subsections
    each
    each-index
    reduce
    interleave
}
"映射："
{ $subsections
    map
    map-as
    map-index
    map-index-as
    map-reduce
    accumulate
    accumulate-as
    accumulate*
    accumulate*-as
}
"过滤："
{ $subsections
    filter
    filter-as
    partition
}
"计数："
{ $subsections
    count
}
"带有 " { $link min } " 和 " { $link max } " 的最值："
{ $subsections
    minimum
    minimum-by
    maximum
    maximum-by
    shorter
    longer
    shorter?
    longer?
    shortest
    longest
}
"生成："
{ $subsections
    replicate
    replicate-as
    produce
    produce-as
}
"数学："
{ $subsections
    sum
    product
}
"测试序列（sequence）是否包含满足谓词的元素："
{ $subsections
    any?
    all?
    none?
}
{ $heading "相关文章" }
{ $subsections
    "sequence-2combinators"
    "sequence-3combinators"
} ;

ARTICLE: "sequence-2combinators" "成对序列组合子"
"有一组组合子成对地遍历两个序列（sequence）。如果一个序列比另一个短，则只检查等于两者最小长度的前缀。"
{ $subsections
    2each
    2reduce
    2map
    2map-as
    2map-reduce
    2all?
} ;

ARTICLE: "sequence-3combinators" "三元组序列组合子"
"有一组组合子以三元组方式遍历三个序列（sequence）。如果一个序列比其他序列短，则只检查等于三者最小长度的前缀。"
{ $subsections 3each 3map 3map-as } ;

ARTICLE: "sequences-tests" "测试序列"
"测试空序列（sequence）："
{ $subsections empty? }
"测试索引："
{ $subsections bounds-check? }
"测试序列（sequence）是否包含对象："
{ $subsections member? member-eq? }
"测试序列（sequence）是否包含子序列（subsequence）："
{ $subsections head? tail? subseq? subseq-of? } ;

ARTICLE: "sequences-search" "搜索序列"
"查找元素的索引："
{ $subsections
    index
    index-from
    last-index
    last-index-from
}
"查找子序列（subsequence）的起始位置："
{ $subsections
    subseq-start
    subseq-start-from
    subseq-index
    subseq-index-from
    subseq-starts-at?
}
"查找满足谓词的元素的索引："
{ $subsections
    find
    find-from
    find-last
    find-last-from
    map-find
    map-find-last
} ;

ARTICLE: "sequences-trimming" "修剪序列"
"修剪词："
{ $subsections trim trim-head trim-tail }
"可能更高效的修剪："
{ $subsections trim-slice trim-head-slice trim-tail-slice } ;

ARTICLE: "sequences-destructive-discussion" "何时使用破坏性操作"
"应优先选择构造性（非破坏性）操作，因为没有副作用的代码通常更可重用且更易于推理。使用破坏性操作有两个主要原因："
{ $list
    "为了副作用。有些代码用破坏性操作表达更简单；构造性操作返回新对象，有时在程序中手动\"传递\"对象会使栈操作复杂化。"
    { "作为优化。一些使用构造性操作的代码性能较差。一个例子是在每次迭代中向序列（sequence）添加元素的循环。可以使用 " { $link suffix } " 或 " { $link suffix! } "；但是，前者每次都会复制整个序列，这将导致循环以二次时间运行。" }
}
"第二个原因比第一个弱得多。特别地，许多组合子（参见 " { $link map } "、" { $link produce } " 和 " { $link "namespaces-make" } "）以及更高级的数据结构（如 " { $vocab-link "persistent.vectors" } "）减少了对显式使用副作用的需求。" ;

ARTICLE: "sequences-destructive" "破坏性序列操作"
"许多操作都有破坏性变体，会对输入序列（sequence）产生副作用，而不是创建新序列："
{ $table
    { { $strong "构造性" } { $strong "破坏性" } }
    { { $link suffix } { $link suffix! } }
    { { $link remove } { $link remove! } }
    { { $link remove-eq } { $link remove-eq! } }
    { { $link remove-nth } { $link remove-nth! } }
    { { $link reverse } { $link reverse! } }
    { { $link append } { $link append! } }
    { { $link map } { $link map! } }
    { { $link accumulate } { $link accumulate! } }
    { { $link accumulate* } { $link accumulate*! } }
    { { $link filter } { $link filter! } }
}
"更改元素："
{ $subsections map! accumulate! accumulate*! change-nth }
"删除元素："
{ $subsections
    remove!
    remove-eq!
    remove-nth!
    delete-slice
    delete-all
    filter!
}
"添加元素："
{ $subsections
    suffix!
    append!
}
"其他破坏性词："
{ $subsections
    reverse!
    move
    exchange
    copy
}
{ $heading "相关文章" }
{ $subsections
    "sequences-destructive-discussion"
    "sequences-stacks"
}
{ $see-also set-nth push push-all pop pop* } ;

ARTICLE: "sequences-stacks" "将序列作为栈使用"
"经典的栈操作，就地修改序列（sequence）："
{ $subsections push push-all pop pop* }
{ $see-also empty? } ;

ARTICLE: "sequences-comparing" "比较序列"
"元素相等性测试："
{ $subsections
    sequence=
    mismatch
    drop-prefix
    assert-sequence=
}
"" { $link <=> } " 泛型词在应用于序列（sequence）时执行字典序比较。" ;

ARTICLE: "sequences-f" "将 f 对象作为序列"
"" { $link f } " 对象以平凡的方式支持序列（sequence）协议。它以零长度响应，并在尝试访问元素时抛出越界错误。" ;

ARTICLE: "sequences-combinator-implementation" "实现序列组合子"
"无条件创建新序列（sequence）："
{ $subsections
    collector
    collector-as
}
"有条件创建新序列（sequence）："
{ $subsections
    selector
    selector-as
    2selector
} ;

ARTICLE: "sequences-cartesian" "笛卡尔积操作"
"两个序列（sequence）的笛卡尔积是一个包含所有对的序列，其中每对的第一个元素来自第一个序列，每对的第二个元素来自第二个序列。笛卡尔积中元素的数量是两个序列长度的乘积。"
$nl
"将第一个序列（sequence）的每个元素与第二个序列的每个元素配对的组合子："
{ $subsections
    cartesian-each
    cartesian-map
    cartesian-find
}
"计算两个序列（sequence）的笛卡尔积："
{ $subsections
    cartesian-product
    cartesian-product-as
} ;

ARTICLE: "sequences" "序列操作"
"一个 " { $emphasis "序列（sequence）" } " 是一个有限的、线性有序的元素集合。用于处理序列（sequence）的词位于 " { $vocab-link "sequences" } " 词汇中。"
$nl
"序列（sequence）实现了一个协议："
{ $subsections
    "sequence-protocol"
    "sequences-f"
}
"序列（sequence）实用词可以操作任何类实现了序列协议的对象。大多数实现由存储支持。一些实现从底层序列获取元素，或即时计算它们。这些被称为 " { $link "virtual-sequences" } "。"
{ $subsections
    "sequences-access"
    "sequences-combinators"
    "sequences-add-remove"
    "sequences-appending"
    "sequences-slices"
    "sequences-reshape"
    "sequences-tests"
    "sequences-search"
    "sequences-comparing"
    "sequences-split"
    "grouping"
    "sequences-destructive"
    "sequences-stacks"
    "sequences-sorting"
    "binary-search"
    "sets"
    "sequences-trimming"
    "sequences-cartesian"
    "sequences.deep"
}
"使用序列（sequence）进行循环："
{ $subsections
    "sequences-integers"
    "ranges"
}
"使用序列（sequence）进行控制流："
{ $subsections "sequences-if" }
"用于内部循环："
{ $subsections "sequences-unsafe" }
"实现序列（sequence）组合子："
{ $subsections "sequences-combinator-implementation" } ;

ABOUT: "sequences"
