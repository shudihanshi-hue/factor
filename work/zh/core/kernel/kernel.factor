USING: alien arrays assocs boxes classes deques dlists heaps
help.markup help.syntax kernel kernel.private layouts math
namespaces quotations sequences strings system threads vectors
words ;
IN: zh.core.kernel

HELP: OBJ-CURRENT-THREAD
{ $description "包含对正在运行的 " { $link thread } " 实例的引用。" } ;

HELP: JIT-PUSH-LITERAL
{ $description "用于将字面量（literal）推入数据栈的 JIT 代码模板。" } ;

HELP: OBJ-SAMPLE-CALLSTACKS
{ $description "一个 " { $link sequence } "（序列），包含在采样性能分析期间捕获的所有调用帧。参见 " { $vocab-link "tools.profiler.sampling" } " 词汇表。" } ;

HELP: OBJ-SLEEP-QUEUE
{ $description "一个 " { $link min-heap } "（最小堆），包含休眠中的线程。" }
{ $see-also sleep-queue } ;

HELP: OBJ-UNDEFINED
{ $description "未定义单词的默认定义。" } ;

HELP: WIN-EXCEPTION-HANDLER
{ $description "这个特殊对象是一个 " { $link alien } "（外部指针），包含指向进程全局异常处理器的指针。仅适用于 " { $link windows } "。" } ;

HELP: eq?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description "测试两个引用是否指向同一个对象。" } ;

HELP: drop  $shuffle ;
HELP: 2drop $shuffle ;
HELP: 3drop $shuffle ;
HELP: 4drop $shuffle ;
HELP: dup   $shuffle ;
HELP: 2dup  $shuffle ;
HELP: 3dup  $shuffle ;
HELP: 4dup  $shuffle ;
HELP: nip   $shuffle ;
HELP: nipd  $shuffle ;
HELP: 2nip  $shuffle ;
HELP: 2nipd $shuffle ;
HELP: 3nip  $shuffle ;
HELP: 3nipd $shuffle ;
HELP: 4nip  $shuffle ;
HELP: 5nip  $shuffle ;
HELP: over  $shuffle ;
HELP: overd $shuffle ;
HELP: 2over $shuffle ;
HELP: pick  $shuffle ;
HELP: pickd $shuffle ;
HELP: reach $shuffle ;
HELP: swap  $shuffle ;
HELP: spin  $shuffle ;
HELP: 4spin $shuffle ;
HELP: roll  $shuffle ;
HELP: -roll $shuffle ;
HELP: tuck  $shuffle ;
HELP: rot   $shuffle ;
HELP: -rot  $shuffle ;
HELP: rotd  $shuffle ;
HELP: -rotd $shuffle ;
HELP: dupd  $shuffle ;
HELP: swapd $shuffle ;

HELP: callstack>array
{ $values { "callstack" callstack } { "array" array } }
{ $description "将调用栈（callstack）转换为包含三个元素一组的数组（array）。数组以相反顺序排列，使得最内层的帧排在最前面。" } ;

HELP: get-datastack
{ $values { "array" array } }
{ $description "输出一个数组（array），包含调用此单词之前数据栈（data stack）内容的副本，栈顶位于数组末尾。" } ;

HELP: set-datastack
{ $values { "array" array } }
{ $description "用数组（array）的副本替换数据栈（data stack）的内容。数组末尾成为栈顶。" } ;

HELP: get-retainstack
{ $values { "array" array } }
{ $description "输出一个数组（array），包含调用此单词之前保留栈（retain stack）内容的副本，栈顶位于数组末尾。" } ;

HELP: set-retainstack
{ $values { "array" array } }
{ $description "用数组（array）的副本替换保留栈（retain stack）的内容。数组末尾成为栈顶。" } ;

HELP: get-callstack
{ $values { "callstack" callstack } }
{ $description "输出调用栈（call stack）内容的副本，栈顶位于向量的末尾。调用者单词的栈帧" { $emphasis "不" } "包含在内。调用栈中每三个元素构成一个帧："
  { $list
    "第一个元素是正在执行的单词或引用（quotation）。"
    "第二个元素是正在执行的引用（quotation）。"
    "第三个元素是正在执行的引用中的偏移量（offset），如果无法确定则返回 -1。"
  }
} ;

HELP: set-callstack
{ $values { "callstack" callstack } }
{ $description "替换调用栈（call stack）的内容。控制流立即转移到新调用栈的最内层帧。" } ;

HELP: clear
{ $description "清空数据栈（data stack）。" } ;

HELP: build
{ $values { "n" integer } }
{ $description "当前构建编号（build number）。每当创建新的启动映像（boot image）时，Factor 会增加此编号。" } ;

HELP: leaf-signal-handler
{ $description "当虚拟机发生错误时由 VM 调用的单词。" } ;

HELP: hashcode*
{ $values { "depth" integer } { "obj" object } { "code" fixnum } }
{ $contract "输出对象的哈希码（hashcode）。哈希码操作必须满足以下性质："
{ $list
    { "如果两个对象在 " { $link = } " 下相等，则它们必须具有相等的哈希码。" }
    { "哈希码仅允许在两次调用之间发生变化，当且仅当对象或其某个槽值发生了变异（mutation）。" }
}
"如果可变对象（mutable objects）被用作哈希表（hashtable）的键，则不得以改变其哈希码的方式进行变异。否则将违反桶排序（bucket sorting）不变性，导致未定义行为。详见 " { $link "hashtables.keys" } "。" } ;

HELP: hashcode
{ $values { "obj" object } { "code" fixnum } }
{ $description "使用默认哈希深度计算对象的哈希码（hashcode）。有关哈希码契约，请参见 " { $link hashcode* } "。" } ;

HELP: recursive-hashcode
{ $values { "n" integer } { "obj" object } { "quot" { $quotation ( n obj -- code ) } } { "code" integer } }
{ $description "一个组合子（combinator），用于实现 " { $link hashcode* } " 泛型单词的方法。如果 " { $snippet "n" } " 小于或等于零，则输出 0，否则调用该引用（quotation）。" } ;

HELP: identity-hashcode
{ $values { "obj" object } { "code" fixnum } }
{ $description "输出对象的标识哈希码（identity hashcode）。标识哈希码不保证唯一性，但在对象生命周期内不会改变。" } ;

{ hashcode hashcode* identity-hashcode } related-words

HELP: =
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description
    "测试两个对象是否相等。如果 " { $snippet "obj1" } " 和 " { $snippet "obj2" } " 指向同一个对象，则输出 " { $link t } "。否则，调用 " { $link equal? } " 泛型单词。"
}
{ $examples
    { $example "USING: kernel prettyprint ;" "5 5 = ." "t" }
    { $example "USING: kernel prettyprint ;" "5 005 = ." "t" }
    { $example "USING: kernel prettyprint ;" "5 5.0 = ." "f" }
    { $example "USING: arrays kernel prettyprint ;" "{ \"a\" \"b\" } \"a\" \"b\" 2array = ." "t" }
    { $example "USING: arrays kernel prettyprint ;" "{ \"a\" \"b\" } [ \"a\" \"b\" ] = ." "f" }
} ;

HELP: equal?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $contract
    "测试两个对象是否相等。"
    $nl
    "用户代码应该调用 " { $link = } " 代替；该单词首先测试对象是否为 " { $link eq? } " 的情况，因此，定义在 " { $link equal? } " 上的方法可以假定它们永远不会在 " { $link eq? } " 的对象上被调用。"
    $nl
    "方法定义应确保这是一个等价关系（equality relation），前提是假设两个对象不是 " { $link eq? } "。也就是说，对于任意三个非 " { $link eq? } " 的对象 " { $snippet "a" } "、" { $snippet "b" } " 和 " { $snippet "c" } "，必须满足："
    { $list
        { { $snippet "a = b" } " 蕴含 " { $snippet "b = a" } }
        { { $snippet "a = b" } " 且 " { $snippet "b = c" } " 蕴含 " { $snippet "a = c" } }
    }
    "如果某个类定义了自定义的相等比较测试，则还应为 " { $link hashcode* } " 泛型单词定义一个兼容的方法。"
}
{ $examples
    "一个示例说明了为什么此单词只应用于定义方法，而永远不应直接调用："
    { $example "USING: kernel prettyprint ;" "5 5 equal? ." "f" }
    "使用 " { $link = } " 可以得到预期的行为："
    { $example "USING: kernel prettyprint ;" "5 5 = ." "t" }
} ;

HELP: identity-tuple
{ $class-description "一个定义了 " { $link equal? } " 方法的类，该方法始终返回 f。" }
{ $examples
    "要定义一个元组类（tuple class），使得两个实例仅在它们为同一个实例时才相等，可以从 " { $link identity-tuple } " 类继承。该类定义了一个 " { $link equal? } " 方法，始终返回 " { $link f } "。由于 " { $link = } " 已经处理了两个对象为 " { $link eq? } " 的情况，此方法永远不会在两个 " { $link eq? } " 的对象上被调用，因此这样的定义是有效的："
    { $code "TUPLE: foo < identity-tuple ;" }
    "通过对 " { $snippet "foo" } " 的实例调用 " { $link = } "，我们得到预期的结果："
    { $unchecked-example "T{ foo } dup = ." "t" }
    { $unchecked-example "T{ foo } dup clone = ." "f" }
} ;

HELP: clone
{ $values { "obj" object } { "cloned" "一个与原对象相等的新对象" } }
{ $contract "输出一个与给定对象相等的新对象。这并不保证实际复制该对象；对于不可变对象（immutable objects）它不做任何操作，对单词（words）也不复制。然而，序列（sequences）和元组（tuples）可以被克隆以获得原对象的浅复制（shallow copy）。" } ;

HELP: ?
{ $values { "?" boolean } { "true" object } { "false" object } { "true/false" object } }
{ $description "根据 " { $snippet "?" } " 的布尔值在两个值之间进行选择。" }
{ $examples
    { $example
        "USING: io kernel math ;"
        "3 4 < \"3 小于 4\" \"3 不小于 4\" ? print"
        "3 小于 4"
    }
    { $example
        "USING: io kernel math ;"
        "4 3 < \"4 小于 3\" \"4 不小于 3\" ? print"
        "4 不小于 3"
    }
} ;

HELP: boolean
{ $class-description "" { $link POSTPONE: t } " 和 " { $link POSTPONE: f } " 类的联合类型（union）。" } ;

HELP: >boolean
{ $values { "obj" "一个广义布尔值（generalized boolean）" } { "?" boolean } }
{ $description "将广义布尔值（generalized boolean）转换为布尔值（boolean）。即，" { $link f } " 保持其值，而其他任何值都变为 " { $link t } "。" } ;

HELP: not
{ $values { "obj" "一个广义布尔值（generalized boolean）" } { "?" boolean } }
{ $description "对于 " { $link f } " 输出 " { $link t } "，对于其他任何值输出 " { $link f } "。" }
{ $notes "此单词实现布尔非（boolean not），因此将其应用于整数不会产生有用的结果（所有整数都具有真值）。按位非（bitwise not）是 " { $link bitnot } " 单词。" } ;

HELP: and
{ $values { "obj1" "一个广义布尔值（generalized boolean）" } { "obj2" "一个广义布尔值（generalized boolean）" } { "obj2/f" "一个广义布尔值（generalized boolean）" } }
{ $description "如果两个输入都为真，则输出 " { $snippet "obj2" } "。否则输出 " { $link f } "。" }
{ $notes "此单词实现布尔与（boolean and），因此将其应用于整数不会产生有用的结果（所有整数都具有真值）。按位与（bitwise and）是 " { $link bitand } " 单词。" }
{ $examples
    "通常只使用结果的布尔值，但你也可以显式地依赖以下行为：如果两个输入都为真，则输出第二个输入："
    { $example "USING: kernel prettyprint ;" "t f and ." "f" }
    { $example "USING: kernel prettyprint ;" "t 7 and ." "7" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 and ." "12.0" }
} ;

HELP: and*
{ $values { "obj1" "一个广义布尔值（generalized boolean）" } { "obj2" "一个广义布尔值（generalized boolean）" } { "obj1/f" "一个广义布尔值（generalized boolean）" } }
{ $description "如果两个输入都为真，则输出 " { $snippet "obj1" } "。否则输出 " { $link f } "。" }
{ $notes "此单词实现布尔与（boolean and），因此将其应用于整数不会产生有用的结果（所有整数都具有真值）。按位与（bitwise and）是 " { $link bitand } " 单词。" }
{ $examples
    "通常只使用结果的布尔值，但你也可以显式地依赖以下行为：如果两个输入都为真，则输出第一个输入："
    { $example "USING: kernel prettyprint ;" "t f and* ." "f" }
    { $example "USING: kernel prettyprint ;" "t 7 and* ." "t" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 and* ." "\"hi\"" }
} ;

{ and and* } related-words

HELP: or
{ $values { "obj1" "一个广义布尔值（generalized boolean）" } { "obj2" "一个广义布尔值（generalized boolean）" } { "obj1/obj2" "一个广义布尔值（generalized boolean）" } }
{ $description "如果两个输入都为假，则输出 " { $link f } "。否则输出 " { $snippet "obj1" } " 和 " { $snippet "obj2" } " 中第一个为真的值。" }
{ $notes "此单词实现布尔或（boolean inclusive or），因此将其应用于整数不会产生有用的结果（所有整数都具有真值）。按位或（bitwise inclusive or）是 " { $link bitor } " 单词。" }
{ $examples
    "通常只使用结果的布尔值，但你也可以显式地依赖以下行为：结果将是第一个为真的输入："
    { $example "USING: kernel prettyprint ;" "t f or ." "t" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 or ." "\"hi\"" }
} ;

HELP: or*
{ $values { "obj1" "一个广义布尔值（generalized boolean）" } { "obj2" "一个广义布尔值（generalized boolean）" } { "obj2/obj1" "一个广义布尔值（generalized boolean）" } }
{ $description "如果两个输入都为假，则输出 " { $link f } "。否则输出 " { $snippet "obj2" } " 和 " { $snippet "obj1" } " 中第一个为真的值。" }
{ $notes "此单词实现布尔或（boolean inclusive or），因此将其应用于整数不会产生有用的结果（所有整数都具有真值）。按位或（bitwise inclusive or）是 " { $link bitor } " 单词。" }
{ $examples
    "通常只使用结果的布尔值，但你也可以显式地依赖以下行为：结果将是最后一个为真的输入："
    { $example "USING: kernel prettyprint ;" "t f or* ." "t" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 or* ." "12.0" }
} ;

HELP: or?
{ $values
    { "obj1" "一个广义布尔值（generalized boolean）" }
    { "obj2" "一个广义布尔值（generalized boolean）" }
    { "obj2/obj1" "一个广义布尔值（generalized boolean）" }
    { "second?" "boolean" }
}
{ $description "" { $link or } " 的一个版本，优先返回第二个参数而不是第一个。输出 " { $snippet "second?" } " 告诉你返回了哪个对象。" }
{ $examples
    "优先返回第二个参数："
    { $example "USING: arrays kernel prettyprint ;"
        "f 3 or? 2array ."
        "{ 3 t }"
    }
    "也会返回第一个参数："
    { $example "USING: arrays kernel prettyprint ;"
        "3 f or? 2array ."
        "{ 3 f }"
    }
    "可以返回 false："
    { $example "USING: arrays kernel prettyprint ;"
        "f f or? 2array ."
        "{ f f }"
    }
} ;

{ or or* or? } related-words

HELP: xor
{ $values { "obj1" "一个广义布尔值（generalized boolean）" } { "obj2" "一个广义布尔值（generalized boolean）" } { "obj1/obj2/f" "一个广义布尔值（generalized boolean）" } }
{ $description "如果恰好有一个输入为假，则输出另一个输入。否则输出 " { $link f } "。" }
{ $notes "此单词实现布尔异或（boolean exclusive or），因此将其应用于整数不会产生有用的结果（所有整数都具有真值）。按位异或（bitwise exclusive or）是 " { $link bitxor } " 单词。" } ;

HELP: both?
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ... obj -- ... ? ) } } { "?" boolean } }
{ $description "测试当引用（quotation）应用于 " { $snippet "x" } " 和 " { $snippet "y" } " 两者时是否都产生真值。" }
{ $examples
    { $example "USING: kernel math prettyprint ;" "3 5 [ odd? ] both? ." "t" }
    { $example "USING: kernel math prettyprint ;" "12 7 [ even? ] both? ." "f" }
} ;

HELP: either?
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ... obj -- ... ? ) } } { "?" "一个广义布尔值（generalized boolean）" } }
{ $description "将引用（quotation）应用于 " { $snippet "x" } " 和 " { $snippet "y" } "，然后返回第一个不为 " { $link f } " 的结果。" }
{ $examples
    { $example "USING: kernel math prettyprint ;" "3 6 [ odd? ] either? ." "t" }
    { $example "USING: kernel math prettyprint ;" "5 7 [ even? ] either? ." "f" }
} ;

HELP: same?
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ... obj -- ... obj' ) } } { "?" boolean } }
{ $description "将引用（quotation）应用于 " { $snippet "x" } " 和 " { $snippet "y" } "，然后检查结果是否相等。" }
{ $examples
    { $example "USING: kernel math prettyprint ;" "4 5 [ 2/ ] same? ." "t" }
    { $example "USING: kernel math prettyprint ;" "3 7 [ sq ] same? ." "f" }
} ;

HELP: execute
{ $values { "word" word } }
{ $description "执行一个单词（word）。" { $link execute } " 一个输入参数的单词必须声明为 " { $link POSTPONE: inline } "（内联），以便传入字面量单词的调用者可以具有静态栈效果（stack effect）。" }
{ $notes "要执行一个非字面量的单词，你可以使用 " { $link POSTPONE: execute( } " 在运行时调用之前检查栈效果。" }
{ $examples
    { $example "USING: kernel io words ;" "IN: scratchpad" ": twice ( word -- ) dup execute execute ; inline\n: hello ( -- ) \"Hello\" print ;\n\\ hello twice" "Hello\nHello" }
} ;

{ execute POSTPONE: execute( } related-words

HELP: (execute)
{ $values { "word" word } }
{ $description "执行一个单词（word），不先检查其是否为单词。" }
{ $warning "此单词位于 " { $vocab-link "kernel.private" } " 词汇表中，因为它是不安全的。使用非单词的参数调用将导致 Factor 崩溃。请改用 " { $link execute } "。" } ;

HELP: call
{ $values { "callable" callable } }
{ $description "调用一个引用（quotation）。" { $link call } " 一个输入参数的单词必须声明为 " { $link POSTPONE: inline } "（内联），以便传入字面量引用的调用者可以具有静态栈效果（stack effect）。" }
{ $notes "要调用一个非字面量的引用，你可以使用 " { $link POSTPONE: call( } " 在运行时调用之前检查栈效果。" }
{ $examples
    "以下两行是等价的："
    { $code "2 [ 2 + 3 * ] call" "2 2 + 3 *" }
} ;

{ call POSTPONE: call( } related-words

HELP: keep
{ $values { "x" object } { "quot" { $quotation ( ..a x -- ..b ) } } }
{ $description "使用栈上的一个值调用引用（quotation），当引用返回时恢复该值。" }
{ $examples
    { $example "USING: arrays kernel prettyprint ;" "2 \"greetings\" [ <array> ] keep 2array ." "{ { \"greetings\" \"greetings\" } \"greetings\" }" }
} ;

HELP: 2keep
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ..a x y -- ..b ) } } }
{ $description "使用栈上的两个值调用引用（quotation），当引用返回时恢复这些值。" } ;

HELP: 3keep
{ $values { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( ..a x y z -- ..b ) } } }
{ $description "使用栈上的三个值调用引用（quotation），当引用返回时恢复这些值。" } ;

HELP: bi
{ $values { "x" object } { "p" { $quotation ( ..a x -- ..b ) } } { "q" { $quotation ( ..c x -- ..d ) } } }
{ $description "将 " { $snippet "p" } " 应用于 " { $snippet "x" } "，然后将 " { $snippet "q" } " 应用于 " { $snippet "x" } "。" }
{ $examples
    "如果 " { $snippet "[ p ]" } " 和 " { $snippet "[ q ]" } " 的栈效果（stack effect）为 " { $snippet "( x -- )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] bi"
        "dup p q"
    }
    "如果 " { $snippet "[ p ]" } " 和 " { $snippet "[ q ]" } " 的栈效果为 " { $snippet "( x -- y )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] bi"
        "dup p swap q"
    }
    "一般来说，以下两行是等价的："
    { $code
        "[ p ] [ q ] bi"
        "[ p ] keep q"
    }

} ;

HELP: 2bi
{ $values { "x" object } { "y" object } { "p" { $quotation ( x y -- ... ) } } { "q" { $quotation ( x y -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于两个输入值，然后将 " { $snippet "q" } " 应用于两个输入值。" }
{ $examples
    "如果 " { $snippet "[ p ]" } " 和 " { $snippet "[ q ]" } " 的栈效果（stack effect）为 " { $snippet "( x y -- )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] 2bi"
        "2dup p q"
    }
    "如果 " { $snippet "[ p ]" } " 和 " { $snippet "[ q ]" } " 的栈效果为 " { $snippet "( x y -- z )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] 2bi"
        "2dup p -rot q"
    }
    "一般来说，以下两行是等价的："
    { $code
        "[ p ] [ q ] 2bi"
        "[ p ] 2keep q"
    }
} ;

HELP: 3bi
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x y z -- ... ) } } { "q" { $quotation ( x y z -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于三个输入值，然后将 " { $snippet "q" } " 应用于三个输入值。" }
{ $examples
    "如果 " { $snippet "[ p ]" } " 和 " { $snippet "[ q ]" } " 的栈效果（stack effect）为 " { $snippet "( x y z -- )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] 3bi"
        "3dup p q"
    }
    "一般来说，以下两行是等价的："
    { $code
        "[ p ] [ q ] 3bi"
        "[ p ] 3keep q"
    }
} ;

HELP: tri
{ $values { "x" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "r" { $quotation ( x -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于 " { $snippet "x" } "，然后将 " { $snippet "q" } " 应用于 " { $snippet "x" } "，最后将 " { $snippet "r" } " 应用于 " { $snippet "x" } "。" }
{ $examples
    "如果 " { $snippet "[ p ]" } "、" { $snippet "[ q ]" } " 和 " { $snippet "[ r ]" } " 的栈效果（stack effect）为 " { $snippet "( x -- )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] tri"
        "dup p dup q r"
    }
    "如果 " { $snippet "[ p ]" } "、" { $snippet "[ q ]" } " 和 " { $snippet "[ r ]" } " 的栈效果为 " { $snippet "( x -- y )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] tri"
        "dup p over q rot r"
    }
    "一般来说，以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] tri"
        "[ p ] keep [ q ] keep r"
    }
} ;

HELP: 2tri
{ $values { "x" object } { "y" object } { "p" { $quotation ( x y -- ... ) } } { "q" { $quotation ( x y -- ... ) } } { "r" { $quotation ( x y -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于两个输入值，然后将 " { $snippet "q" } " 应用于两个输入值，最后将 " { $snippet "r" } " 应用于两个输入值。" }
{ $examples
    "如果 " { $snippet "[ p ]" } "、" { $snippet "[ q ]" } " 和 " { $snippet "[ r ]" } " 的栈效果（stack effect）为 " { $snippet "( x y -- )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] 2tri"
        "2dup p 2dup q r"
    }
    "一般来说，以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] 2tri"
        "[ p ] 2keep [ q ] 2keep r"
    }
} ;

HELP: 3tri
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x y z -- ... ) } } { "q" { $quotation ( x y z -- ... ) } } { "r" { $quotation ( x y z -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于三个输入值，然后将 " { $snippet "q" } " 应用于三个输入值，最后将 " { $snippet "r" } " 应用于三个输入值。" }
{ $examples
    "如果 " { $snippet "[ p ]" } "、" { $snippet "[ q ]" } " 和 " { $snippet "[ r ]" } " 的栈效果（stack effect）为 " { $snippet "( x y z -- )" } "，则以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] 3tri"
        "3dup p 3dup q r"
    }
    "一般来说，以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] 3tri"
        "[ p ] 3keep [ q ] 3keep r"
    }
} ;


HELP: bi*
{ $values { "x" object } { "y" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( y -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于 " { $snippet "x" } "，然后将 " { $snippet "q" } " 应用于 " { $snippet "y" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] [ q ] bi*"
        "[ p ] dip q"
    }
} ;

HELP: 2bi*
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( w x -- ... ) } } { "q" { $quotation ( y z -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于 " { $snippet "w" } " 和 " { $snippet "x" } "，然后将 " { $snippet "q" } " 应用于 " { $snippet "y" } " 和 " { $snippet "z" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] [ q ] 2bi*"
        "[ p ] 2dip q"
    }
} ;

HELP: 2tri*
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( u v -- ... ) } } { "q" { $quotation ( w x -- ... ) } } { "r" { $quotation ( y z -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于 " { $snippet "u" } " 和 " { $snippet "v" } "，然后将 " { $snippet "q" } " 应用于 " { $snippet "w" } " 和 " { $snippet "x" } "，最后将 " { $snippet "r" } " 应用于 " { $snippet "y" } " 和 " { $snippet "z" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] 2tri*"
        "[ [ p ] 2dip q ] 2dip r"
    }
} ;

HELP: tri*
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( y -- ... ) } } { "r" { $quotation ( z -- ... ) } } }
{ $description "将 " { $snippet "p" } " 应用于 " { $snippet "x" } "，然后将 " { $snippet "q" } " 应用于 " { $snippet "y" } "，最后将 " { $snippet "r" } " 应用于 " { $snippet "z" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] [ q ] [ r ] tri*"
        "[ [ p ] dip q ] dip r"
    }
} ;

HELP: bi@
{ $values { "x" object } { "y" object } { "quot" { $quotation ( obj -- ... ) } } }
{ $description "将引用（quotation）应用于 " { $snippet "x" } "，然后应用于 " { $snippet "y" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] bi@"
        "[ p ] dip p"
    }
    "以下两行也是等价的："
    { $code
        "[ p ] bi@"
        "[ p ] [ p ] bi*"
    }
} ;

HELP: 2bi@
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 -- ... ) } } }
{ $description "将引用（quotation）应用于 " { $snippet "w" } " 和 " { $snippet "x" } "，然后应用于 " { $snippet "y" } " 和 " { $snippet "z" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] 2bi@"
        "[ p ] 2dip p"
    }
    "以下两行也是等价的："
    { $code
        "[ p ] 2bi@"
        "[ p ] [ p ] 2bi*"
    }
} ;

HELP: tri@
{ $values { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj -- ... ) } } }
{ $description "将引用（quotation）应用于 " { $snippet "x" } "，然后应用于 " { $snippet "y" } "，最后应用于 " { $snippet "z" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] tri@"
        "[ [ p ] dip p ] dip p"
    }
    "以下两行也是等价的："
    { $code
        "[ p ] tri@"
        "[ p ] [ p ] [ p ] tri*"
    }
} ;

HELP: 2tri@
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 -- ... ) } } }
{ $description "将引用（quotation）应用于 " { $snippet "u" } " 和 " { $snippet "v" } "，然后应用于 " { $snippet "w" } " 和 " { $snippet "x" } "，最后应用于 " { $snippet "y" } " 和 " { $snippet "z" } "。" }
{ $examples
    "以下两行是等价的："
    { $code
        "[ p ] 2tri@"
        "[ [ p ] 2dip p ] 2dip p"
    }
    "以下两行也是等价的："
    { $code
        "[ p ] 2tri@"
        "[ p ] [ p ] [ p ] 2tri*"
    }
} ;

HELP: bi-curry
{ $values { "x" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "p'" { $snippet "[ x p ]" } } { "q'" { $snippet "[ x q ]" } } }
{ $description "将 " { $snippet "p" } " 和 " { $snippet "q" } " 部分应用（partially apply）到 " { $snippet "x" } "。" }
{ $notes
  "以下两行是等价的："
  { $code
    "[ p ] [ q ] bi-curry [ call ] bi@"
    "[ p ] [ q ] bi"
  }
  "" { $link bi } " 的更高元数（higher-arity）变体可以从 " { $link bi-curry } " 构建："
  { $code
    "[ p ] [ q ] bi-curry bi == [ p ] [ q ] 2bi"
    "[ p ] [ q ] bi-curry bi-curry bi == [ p ] [ q ] 3bi"
  }
  "组合 " { $snippet "bi-curry bi*" } " 无法仅用非柯里化（non-currying）的数据流组合子（dataflow combinators）表达；它等价于在 " { $link 2bi* } " 之前进行栈重排（stack shuffle）："
  { $code
    "[ p ] [ q ] bi-curry bi*"
    "[ swap ] keep [ p ] [ q ] 2bi*"
  }
  "换句话说，" { $snippet "bi-curry bi*" } " 处理这样的情况：栈上有三个值 " { $snippet "a b c" } "，你希望将 " { $snippet "p" } " 应用于 " { $snippet "a c" } "，将 " { $snippet "q" } " 应用于 " { $snippet "b c" } "。"
} ;

HELP: tri-curry
{ $values
  { "x" object }
  { "p" { $quotation ( x -- ... ) } }
  { "q" { $quotation ( x -- ... ) } }
  { "r" { $quotation ( x -- ... ) } }
  { "p'" { $snippet "[ x p ]" } }
  { "q'" { $snippet "[ x q ]" } }
  { "r'" { $snippet "[ x r ]" } }
}
{ $description "将 " { $snippet "p" } "、" { $snippet "q" } " 和 " { $snippet "r" } " 部分应用（partially apply）到 " { $snippet "x" } "。" }
{ $notes
  "以下两行是等价的："
  { $code
    "[ p ] [ q ] [ r ] tri-curry [ call ] tri@"
    "[ p ] [ q ] [ r ] tri"
  }
  "" { $link tri } " 的更高元数（higher-arity）变体可以从 " { $link tri-curry } " 构建："
  { $code
    "[ p ] [ q ] [ r ] tri-curry tri == [ p ] [ q ] [ r ] 2tri"
    "[ p ] [ q ] [ r ] tri-curry tri-curry bi == [ p ] [ q ] [ r ] 3tri"
  }
  "组合 " { $snippet "tri-curry tri*" } " 无法仅用非柯里化（non-currying）的数据流组合子（dataflow combinators）表达；它处理这样的情况：栈上有四个值 " { $snippet "a b c d" } "，你希望将 " { $snippet "p" } " 应用于 " { $snippet "a d" } "，将 " { $snippet "q" } " 应用于 " { $snippet "b d" } "，将 " { $snippet "r" } " 应用于 " { $snippet "c d" } "。" } ;

HELP: bi-curry*
{ $values { "x" object } { "y" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( y -- ... ) } } { "p'" { $snippet "[ x p ]" } } { "q'" { $snippet "[ y q ]" } } }
{ $description "将 " { $snippet "p" } " 部分应用（partially apply）到 " { $snippet "x" } "，将 " { $snippet "q" } " 部分应用到 " { $snippet "y" } "。" }
{ $notes
  "以下两行是等价的："
  { $code
    "[ p ] [ q ] bi-curry* [ call ] bi@"
    "[ p ] [ q ] bi*"
  }
  "组合 " { $snippet "bi-curry* bi" } " 等价于在 " { $link 2bi* } " 之前进行栈重排（stack shuffle）："
  { $code
    "[ p ] [ q ] bi-curry* bi"
    "[ over ] dip [ p ] [ q ] 2bi*"
  }
  "换句话说，" { $snippet "bi-curry* bi" } " 处理这样的情况：栈上有三个值 " { $snippet "a b c" } "，你希望将 " { $snippet "p" } " 应用于 " { $snippet "a b" } "，将 " { $snippet "q" } " 应用于 " { $snippet "a c" } "。"
  $nl
  "组合 " { $snippet "bi-curry* bi*" } " 等价于在 " { $link 2bi* } " 之前进行栈重排（stack shuffle）："
  { $code
    "[ p ] [ q ] bi-curry* bi*"
    "[ swap ] dip [ p ] [ q ] 2bi*"
  }
  "换句话说，" { $snippet "bi-curry* bi*" } " 处理这样的情况：栈上有四个值 " { $snippet "a b c d" } "，你希望将 " { $snippet "p" } " 应用于 " { $snippet "a c" } "，将 " { $snippet "q" } " 应用于 " { $snippet "b d" } "。"

} ;

HELP: tri-curry*
{ $values
  { "x" object }
  { "y" object }
  { "z" object }
  { "p" { $quotation ( x -- ... ) } }
  { "q" { $quotation ( y -- ... ) } }
  { "r" { $quotation ( z -- ... ) } }
  { "p'" { $snippet "[ x p ]" } }
  { "q'" { $snippet "[ y q ]" } }
  { "r'" { $snippet "[ z r ]" } }
}
{ $description "将 " { $snippet "p" } " 部分应用（partially apply）到 " { $snippet "x" } "，将 " { $snippet "q" } " 部分应用到 " { $snippet "y" } "，将 " { $snippet "r" } " 部分应用到 " { $snippet "z" } "。" }
{ $notes
  "以下两行是等价的："
  { $code
    "[ p ] [ q ] [ r ] tri-curry* [ call ] tri@"
    "[ p ] [ q ] [ r ] tri*"
  }
  "组合 " { $snippet "tri-curry* tri" } " 等价于在 " { $link 2tri* } " 之前进行栈重排（stack shuffle）："
  { $code
    "[ p ] [ q ] [ r ] tri-curry* tri"
    "[ [ over ] dip over ] dip [ p ] [ q ] [ r ] 2tri*"
  }
} ;

HELP: bi-curry@
{ $values { "x" object } { "y" object } { "q" { $quotation ( obj -- ... ) } } { "p'" { $snippet "[ x q ]" } } { "q'" { $snippet "[ y q ]" } } }
{ $description "将 " { $snippet "q" } " 部分应用（partially apply）到 " { $snippet "x" } " 和 " { $snippet "y" } "。" }
{ $notes
  "以下两行是等价的："
  { $code
    "[ q ] bi-curry@"
    "[ q ] [ q ] bi-curry*"
  }
} ;

HELP: tri-curry@
{ $values
  { "x" object }
  { "y" object }
  { "z" object }
  { "q" { $quotation ( obj -- ... ) } }
  { "p'" { $snippet "[ x q ]" } }
  { "q'" { $snippet "[ y q ]" } }
  { "r'" { $snippet "[ z q ]" } }
}
{ $description "将 " { $snippet "q" } " 部分应用（partially apply）到 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } "。" }
{ $notes
  "以下两行是等价的："
  { $code
    "[ q ] tri-curry@"
    "[ q ] [ q ] [ q ] tri-curry*"
  }
} ;

HELP: if
{ $values { "?" "一个广义布尔值（generalized boolean）" } { "true" quotation } { "false" quotation } }
{ $description "如果 " { $snippet "cond" } " 是 " { $link f } "，则调用 " { $snippet "false" } " 引用（quotation）。否则调用 " { $snippet "true" } " 引用。"
$nl
"在调用任一引用之前，" { $snippet "cond" } " 值会从栈上移除。" }
{ $examples
    { $example
        "USING: io kernel math ;"
        "10 3 < [ \"数学出错了\" print ] [ \"数学是正确的\" print ] if"
        "数学是正确的"
    }
}
{ $notes { $snippet "if" } " 当前面有两个字面量引用（literal quotations）时会作为原语（primitive）执行。除非其参数之一是非字面量引用，例如使用 " { $link curry } " 或 " { $link compose } " 构造的引用，或用于 " { $link "fry" } " 或包含 " { $link "locals" } " 的引用，否则下面的定义不会被执行。" } ;

HELP: when
{ $values { "?" "一个广义布尔值（generalized boolean）" } { "true" quotation } }
{ $description "如果 " { $snippet "cond" } " 不是 " { $link f } "，则调用 " { $snippet "true" } " 引用（quotation）。"
$nl
"在调用引用之前，" { $snippet "cond" } " 值会从栈上移除。" }
{ $examples
    { $example
        "USING: kernel math prettyprint ;"
        "-5 dup 0 < [ 3 + ] when ."
        "-2"
    }
} ;

HELP: unless
{ $values { "?" "一个广义布尔值（generalized boolean）" } { "false" quotation } }
{ $description "如果 " { $snippet "cond" } " 是 " { $link f } "，则调用 " { $snippet "false" } " 引用（quotation）。"
$nl
"在调用引用之前，" { $snippet "cond" } " 值会从栈上移除。" }
{ $examples
    { $example
        "USING: kernel math prettyprint sequences ;"
        "IN: scratchpad"
        ""
        "CONSTANT: american-cities {"
        "    \"San Francisco\""
        "    \"Los Angeles\""
        "    \"New York\""
        "}"
        ""
        ": add-tax ( price city -- price' )"
        "    american-cities member? [ 1.1 * ] unless ;"
        ""
        "123 \"Ottawa\" add-tax ."
        "135.3"
    }
} ;

HELP: if*
{ $values { "?" "一个广义布尔值（generalized boolean）" } { "true" { $quotation ( ..a ? -- ..b ) } } { "false" { $quotation ( ..a -- ..b ) } } }
{ $description "备选条件形式，如果条件为真则保留 " { $snippet "cond" } " 值。"
$nl
"如果条件为真，则在调用 " { $snippet "true" } " 引用（quotation）之前将其保留在栈上。否则，条件值从栈上移除，并调用 " { $snippet "false" } " 引用。"
$nl
"以下两行是等价的："
{ $code "X [ Y ] [ Z ] if*" "X dup [ Y ] [ drop Z ] if" } }
{ $examples
    "注意在此示例中，同一个值被条件测试，然后在真分支中使用；假分支不需要丢弃该值，因为 " { $link if* } " 的工作方式就是这样："
    { $example
        "USING: assocs io kernel math.parser ;"
        "IN: scratchpad"
        ""
        ": curry-price ( meat -- price )
    {
        { \"Beef\" 10 }
        { \"Chicken\" 12 }
        { \"Lamb\" 13 }
    } at ;

: order-curry ( meat -- )
    curry-price [
        \"您的订单将是 \" write
        number>string write
        \" 美元。\" write
    ] [ \"无效订单。\" print ] if* ;"
        ""
        "\"Deer\" order-curry"
        "无效订单。"
    }
} ;

HELP: when*
{ $values { "?" "一个广义布尔值（generalized boolean）" } { "true" { $quotation ( ..a ? -- ..a ) } } }
{ $description "" { $link if* } " 的变体，没有假引用（false quotation）。"
$nl
"以下两行是等价的："
{ $code "X [ Y ] when*" "X dup [ Y ] [ drop ] if" } } ;

HELP: unless*
{ $values { "?" "一个广义布尔值（generalized boolean）" } { "false" { $quotation ( ..a -- ..a x ) } } { "x" object } }
{ $description "" { $link if* } " 的变体，没有真引用（true quotation）。" }
{ $notes
"以下两行是等价的："
{ $code "X [ Y ] unless*" "X dup [ ] [ drop Y ] if" } } ;

HELP: ?call
{ $values
    { "obj/f" { $maybe object } } { "quot" quotation }
    { "obj'/f" { $maybe object } }
}
{ $description "如果 " { $snippet "obj" } " 不是 " { $snippet "f" } "，则调用引用（quotation）。" }
{ $examples
    "示例："
    { $example "USING: kernel math prettyprint ;"
        "5 [ sq ] ?call ."
        "25"
    }
    "示例："
    { $example "USING: kernel math prettyprint ;"
        "f [ sq ] ?call ."
        "f"
    }
} ;

HELP: ?if
{ $values
    { "default" object } { "cond" object } { "true" object } { "false" object }
}
{ $warning "旧的 " { $snippet "?if" } " 单词可以重构为：" { $code "[ .. ] [ .. ] ?if\n\nor? [ .. ] [ .. ] if" } }
{ $description "在 " { $snippet "default" } " 对象上调用 " { $snippet "cond" } "，如果 " { $snippet "cond" } " 输出了新对象，则用该新对象调用 " { $snippet "true" } " 引用（quotation）。否则，用旧对象调用 " { $snippet "false" } "。" }
{ $examples
    "查找一个已有单词或产生一个错误对："
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+\" [ search ] [ where first ] [ \"未找到\" 2array ] ?if ."
        "\"resource:core/math/math.factor\""
    }
    "尝试查找一个不存在的单词："
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+++++\" [ search ] [ where first ] [ \"未找到\" 2array ] ?if ."
        "{ \"+++++\" \"未找到\" }"
    }
} ;

HELP: ?when
{ $values
    { "default" object } { "cond" { $quotation ( ..a default -- ..a new/f ) } } { "true" { $quotation ( ..a new -- ..a x ) } } { "default/x" { $or { $snippet "default" } { $snippet "x" } } }
}
{ $description "在 " { $snippet "default" } " 对象上调用 " { $snippet "cond" } "，如果 " { $snippet "cond" } " 输出了新对象，则用该新对象调用 " { $snippet "true" } " 引用（quotation）。否则，将旧对象留在栈上。" }
{ $examples
    "查找一个已有单词或产生一个错误对："
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+\" [ search ] [ where first ] ?when ."
        "\"resource:core/math/math.factor\""
    }
    "尝试查找一个不存在的单词："
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+++++\" [ search ] [ where first ] ?when ."
        "\"+++++\""
    }
} ;

HELP: ?unless
{ $values
    { "default" object } { "cond" { $quotation ( ..a default -- ..a new/f ) } } { "false" { $quotation ( ..a default -- ..a x ) } } { "default/x" { $or { $snippet "default" } { $snippet "x" } } }
}
{ $description "在 " { $snippet "default" } " 对象上调用 " { $snippet "cond" } "，如果 " { $snippet "cond" } " 输出了新对象则什么也不做。否则，用旧对象调用 " { $snippet "false" } "。" }
{ $examples
    "查找一个已有单词或产生一个错误对："
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+\" [ search ] [ \"未找到\" 2array ] ?unless ."
        "+"
    }
    "尝试查找一个不存在的单词："
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+++++\" [ search ] [ \"未找到\" 2array ] ?unless ."
        "{ \"+++++\" \"未找到\" }"
    }
} ;

{ ?if ?when ?unless } related-words

HELP: 1if
{ $values
    { "x" object } { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "" { $link if } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 1check } " 以返回一个布尔值，并为 " { $snippet "true" } " 或 " { $snippet "false" } " 分支保留 " { $snippet "x" } "，两者之一会被调用。" }
{ $examples
    "考拉兹猜想（Collatz Conjecture）计算："
    { $example "USING: kernel math prettyprint ;"
        "6 [ even? ] [ 2 / ] [ 3 * 1 + ] 1if ."
        "3"
    }
} ;

HELP: 1when
{ $values
    { "x" object } { "pred" quotation } { "true" quotation }
}
{ $description "" { $link when } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 1check } " 以返回一个布尔值，并为两个分支保留 " { $snippet "x" } "。" { $snippet "true" } " 分支被有条件地调用。" } ;

HELP: 1unless
{ $values
    { "x" object } { "pred" quotation } { "false" quotation }
}
{ $description "" { $link when } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 1check } " 以返回一个布尔值，并为两个分支保留 " { $snippet "x" } "。" { $snippet "false" } " 分支被有条件地调用。" } ;

HELP: 2if
{ $values
    { "x" object } { "y" object } { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "" { $link if } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 2check } " 以返回一个布尔值，并为 " { $snippet "true" } " 或 " { $snippet "false" } " 分支保留 " { $snippet "x" } " 和 " { $snippet "y" } "，两者之一会被调用。" } ;

HELP: 2when
{ $values
    { "x" object } { "y" object } { "pred" quotation } { "true" quotation }
}
{ $description "" { $link when } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 2check } " 以返回一个布尔值，并为两个分支保留 " { $snippet "x" } " 和 " { $snippet "y" } "。" { $snippet "true" } " 分支被有条件地调用。" } ;

HELP: 2unless
{ $values
    { "x" object } { "y" object } { "pred" quotation } { "false" quotation }
}
{ $description "" { $link unless } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 2check } " 以返回一个布尔值，并为两个分支保留 " { $snippet "x" } " 和 " { $snippet "y" } "。" { $snippet "false" } " 分支被有条件地调用。" } ;

HELP: 3if
{ $values
    { "x" object } { "y" object } { "z" object } { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "" { $link if } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 3check } " 以返回一个布尔值，并为 " { $snippet "true" } " 或 " { $snippet "false" } " 分支保留 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } "，两者之一会被调用。" } ;

HELP: 3when
{ $values
    { "x" object } { "y" object } { "z" object } { "pred" quotation } { "true" quotation }
}
{ $description "" { $link when } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 3check } " 以返回一个布尔值，并为两个分支保留 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } "。" { $snippet "true" } " 分支被有条件地调用。" } ;

HELP: 3unless
{ $values
    { "x" object } { "y" object } { "z" object } { "pred" quotation } { "false" quotation }
}
{ $description "" { $link unless } " 的一个变体，接受一个 " { $snippet "pred" } " 引用（quotation）。在 " { $snippet "pred" } " 引用上调用 " { $link 3check } " 以返回一个布尔值，并为两个分支保留 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } "。" { $snippet "false" } " 分支被有条件地调用。" } ;

{ 1if 1when 1unless 2if 2when 2unless 3if 3when 3unless } related-words

HELP: 1check
{ $values
    { "x" object } { "quot" quotation }
    { "?" boolean }
}
{ $description "在 " { $snippet "x" } " 上调用 " { $snippet "quot" } "，并将 " { $snippet "x" } " 保留在来自 " { $snippet "quot" } " 的布尔结果之下。"  }
{ $examples
    "真值情况："
    { $example "USING: kernel math prettyprint ;"
        "6 [ even? ] 1check [ . ] bi@"
        "6\nt"
    }
    "假值情况："
    { $example "USING: kernel math prettyprint ;"
        "6 [ odd? ] 1check [ . ] bi@"
        "6\nf"
    }
} ;

HELP: 1guard
{ $values
    { "x" object } { "quot" quotation }
    { "x/f" object }
}
{ $description "在 " { $snippet "x" } " 上调用 " { $snippet "quot" } "，并要么保留 " { $snippet "x" } "，要么将其替换为 " { $snippet "f" } "。" }
{ $examples
    "真值情况："
    { $example "USING: kernel math prettyprint ;"
        "6 [ even? ] 1guard ."
        "6"
    }
    "假值情况："
    { $example "USING: kernel math prettyprint ;"
        "5 [ even? ] 1guard ."
        "f"
    }
} ;

HELP: 2check
{ $values
    { "x" object } { "y" object } { "quot" quotation }
    { "?" boolean }
}
{ $description "在 " { $snippet "x" } " 和 " { $snippet "y" } " 上调用 " { $snippet "quot" } "，并将这两个值保留在来自 " { $snippet "quot" } " 的布尔结果之下。"  }
{ $examples
    "真值情况："
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + odd? ] 2check [ . ] tri@"
        "3\n4\nt"
    }
    "假值情况："
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + even? ] 2check [ . ] tri@"
        "3\n4\nf"
    }
} ;

HELP: 2guard
{ $values
    { "x" object } { "y" object } { "quot" quotation }
    { "x/f" object } { "y/f" object }
}
{ $description "在 " { $snippet "x" } " 和 " { $snippet "y" } " 上调用 " { $snippet "quot" } "，并要么保留 " { $snippet "x" } " 和 " { $snippet "y" } "，要么将它们替换为 " { $snippet "f" } "。"  }
{ $examples
    "真值情况："
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + odd? ] 2guard [ . ] bi@"
        "3\n4"
    }
    "假值情况："
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + even? ] 2guard [ . ] bi@"
        "f\nf"
    }
} ;

HELP: 3check
{ $values
    { "x" object } { "y" object } { "z" object } { "quot" quotation }
    { "?" boolean }
}
{ $description "在 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } " 上调用 " { $snippet "quot" } "，并将这三个值保留在来自 " { $snippet "quot" } " 的布尔结果之下。" }
{ $examples
    "真值情况："
    { $example "USING: arrays kernel math prettyprint ;"
        "3 4 5 [ + + even? ] 3check 4array ."
        "{ 3 4 5 t }"
    }
    "假值情况："
    { $example "USING: arrays kernel math prettyprint ;"
        "3 4 5 [ + + odd? ] 3check 4array ."
        "{ 3 4 5 f }"
    }
} ;

HELP: 3guard
{ $values
    { "x" object } { "y" object } { "z" object } { "quot" quotation }
    { "x/f" object } { "y/f" object } { "z/f" object }
}
{ $description "在 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } " 上调用 " { $snippet "quot" } "，并要么保留 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } "，要么将它们替换为 " { $snippet "f" } "。" }
{ $examples
    "真值情况："
    { $example "USING: kernel math prettyprint ;"
        "3 4 5 [ + + even? ] 3guard [ . ] tri@"
        "3\n4\n5"
    }
    "假值情况："
    { $example "USING: kernel math prettyprint ;"
        "3 4 5 [ + + odd? ] 3guard [ . ] tri@"
        "f\nf\nf"
    }
} ;

{ 1check 1guard 2check 2guard 3check 3guard } related-words

HELP: die
{ $description "启动前端处理器（FEP, Front-End Processor），这是一个低级调试器，可以检查内存地址等。当发生严重错误时也会进入 FEP。" }
{ $notes
    "术语 FEP 源自早期的 Lisp 机器。根据 Jargon File 的说法，"
    $nl
    { $strong "fepped out" } " /fept owt/ " { $emphasis "adj." } " Symbolics 3600 LISP 机器有一个称为 'FEP' 的前端处理器（比较 box 的第 2 义项）。当主处理器卡死时，FEP 接管键盘和屏幕。这样的机器被称为 'fepped out' 或 'dropped into the fep'。"
    $nl
    { $url "http://www.jargon.net/jargonfile/f/feppedout.html" }
} ;

HELP: (clone)
{ $values { "obj" object } { "newobj" "一个浅复制（shallow copy）" } }
{ $description "输出给定对象的逐字节副本。用户代码应改为调用 " { $link clone } "。" } ;

HELP: declare
{ $values { "spec" "一个类单词（class words）的数组（array）" } }
{ $description "声明栈顶的元素是 " { $snippet "spec" } " 中类的实例。" }
{ $warning "编译器盲目信任声明，错误的声明可能导致崩溃、内存损坏和其他不良行为。" }
{ $examples
    "优化器无法对以下代码做任何优化："
    { $code "2 + 10 *" }
    "然而，如果我们声明栈顶是一个 " { $link float } "（浮点数），那么类型检查和泛型分发（generic dispatch）将被消除，编译器可以使用不安全的内建函数（unsafe intrinsics）："
    { $code "{ float } declare 2 + 10 *" }
} ;

HELP: tag
{ $values { "object" object } { "n" "一个标签编号（tag number）" } }
{ $description "输出对象的标签编号（tag number），介于 0 到 " { $link num-types } " 减 1 之间。这是实现细节，用户代码应改为调用 " { $link class-of } "。" } ;

HELP: special-object
{ $values { "n" "一个非负整数（non-negative integer）" } { "obj" object } }
{ $description "从 Factor 虚拟机的特殊对象表（special object table）中读取一个对象。用户代码永远不需要直接读取特殊对象表；而应使用此单词的调用者之一。" } ;

HELP: set-special-object
{ $values { "obj" object } { "n" "一个非负整数（non-negative integer）" } }
{ $description "向 Factor 虚拟机的特殊对象表（special object table）写入一个对象。用户代码永远不需要直接写入特殊对象表；而应使用此单词的调用者之一。" } ;

HELP: object
{ $class-description
    "所有对象的类。如果一个泛型单词（generic word）定义了一个特化（specializing）在该类上的方法，该方法将作为回退（fallback）方法，如果没有找到其他适用方法时使用。例如："
    { $code "GENERIC: enclose ( number -- array )" "M: number enclose 1array ;" "M: object enclose ;" }
} ;

HELP: null
{ $class-description
    "规范的空类，没有实例。"
}
{ $notes
    "与 Java 中的 " { $snippet "null" } " 或 C++ 中的 " { $snippet "NULL" } " 不同，这不是一个表示空或无的值。请使用 " { $link f } " 来达到此目的。"
} ;

HELP: most
{ $values { "x" object } { "y" object } { "quot" { $quotation ( x y -- ? ) } } { "z" "要么是 " { $snippet "x" } " 要么是 " { $snippet "y" } } }
{ $description "如果引用（quotation）应用于 " { $snippet "x" } " 和 " { $snippet "y" } " 时产生真值，则输出 " { $snippet "x" } "，否则输出 " { $snippet "y" } "。" } ;

HELP: curry
{ $values { "obj" object } { "quot" callable } { "curry" curried } }
{ $description "部分应用（partial application）。输出一个 " { $link callable } "（可调用对象），它首先推入 " { $snippet "obj" } "，然后调用 " { $snippet "quot" } "。" }
{ $notes "即使 " { $snippet "obj" } " 是一个单词（word），它也会作为字面量（literal）被推入。"
$nl
"此操作是高效的，不会复制引用（quotation）。" }
{ $examples
    { $example "USING: kernel prettyprint ;" "5 [ . ] curry ." "[ 5 . ]" }
    { $example "USING: kernel prettyprint see ;" "\\ = [ see ] curry ." "[ \\ = see ]" }
    { $example "USING: kernel math prettyprint sequences ;" "{ 1 2 3 } 2 [ - ] curry map ." "{ -1 0 1 }" }
} ;

HELP: curried
{ $class-description "由 " { $link curry } " 创建的对象所属的类。这些对象的打印形式与引用（quotations）相同，并实现了序列协议（sequence protocol），但它们只使用两个存储单元（cells）；一个是对对象的引用，一个是对底层引用的引用。" } ;

{ curry curried compose prepose composed } related-words

HELP: 2curry
{ $values { "obj1" object } { "obj2" object } { "quot" callable } { "curried" curried } }
{ $description "输出一个 " { $link callable } "（可调用对象），它推入 " { $snippet "obj1" } " 和 " { $snippet "obj2" } "，然后调用 " { $snippet "quot" } "。" }
{ $notes "此操作是高效的，不会复制引用（quotation）。" }
{ $examples
    { $example "USING: kernel math prettyprint ;" "5 4 [ + ] 2curry ." "[ 5 4 + ]" }
} ;

HELP: 3curry
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quot" callable } { "curried" curried } }
{ $description "输出一个 " { $link callable } "（可调用对象），它推入 " { $snippet "obj1" } "、" { $snippet "obj2" } " 和 " { $snippet "obj3" } "，然后调用 " { $snippet "quot" } "。" }
{ $notes "此操作是高效的，不会复制引用（quotation）。" } ;

HELP: with
{ $values { "param" object } { "obj" object } { "quot" { $quotation ( param elt -- ... ) } } { "curried" curried } }
{ $description "类似于 " { $link curry } " 将其引用下方的元素绑定为其第一个参数，" { $link with } " 将 " { $snippet "quot" } " 下方的第二个元素绑定为 " { $snippet "quot" } " 的第二个参数。"
$nl
"换句话说，是左侧的部分应用（partial application on the left）。以下两行是等价的："
    { $code "swap [ swap A ] curry B" }
    { $code "[ A ] with B" }
}
{ $notes "此操作是高效的，不会复制引用（quotation）。" }
{ $examples
    { $example "USING: kernel math prettyprint sequences ;" "1 { 1 2 3 } [ / ] with map ." "{ 1 1/2 1/3 }" }
    { $example "USING: kernel math prettyprint sequences ;" "1000 100 5 <iota> [ sq + + ] 2with map ." "{ 1100 1101 1104 1109 1116 }" }
} ;

HELP: 2with
{ $values
  { "param1" object }
  { "param2" object }
  { "obj" object }
  { "quot" { $quotation ( param1 param2 elt -- ... ) } }
  { "curried" curried }
}
{ $description "左侧两个参数的部分应用（partial application on the left of two parameters）。" } ;

HELP: compose
{ $values { "quot1" callable } { "quot2" callable } { "compose" composed } }
{ $description "引用组合（quotation composition）。输出一个 " { $link callable } "（可调用对象），它先调用 " { $snippet "quot1" } "，然后调用 " { $snippet "quot2" } "。" }
{ $notes
    "以下两行是等价的："
    { $code
        "compose call"
        "append call"
    }
    "然而，" { $link compose } " 在常数时间内运行，并且优化编译器能够编译调用组合引用（composed quotations）的代码。"
} ;

HELP: prepose
{ $values { "quot1" callable } { "quot2" callable } { "composed" composed } }
{ $description "引用组合（quotation composition）。输出一个 " { $link callable } "（可调用对象），它先调用 " { $snippet "quot2" } "，然后调用 " { $snippet "quot1" } "。" }
{ $notes "详见 " { $link compose } "。" } ;

HELP: composed
{ $class-description "由 " { $link compose } " 创建的对象所属的类。这些对象的打印形式与引用（quotations）相同，并实现了序列协议（sequence protocol），但它们只使用两个存储单元（cells）；分别是对第一个和第二个底层引用的引用。" } ;

HELP: dip
{ $values { "x" object } { "quot" quotation } }
{ $description "从数据栈（datastack）中移除 " { $snippet "x" } "，调用 " { $snippet "quot" } "，并在 " { $snippet "quot" } " 完成后将 " { $snippet "x" } " 恢复到数据栈的顶部。" }
{ $examples
    { $example "USING: arrays kernel math prettyprint ;" "10 20 30 [ / ] dip 2array ." "{ 1/2 30 }" }
}
{ $notes { $snippet "dip" } " 当前面有一个字面量引用（literal quotation）时会作为原语（primitive）执行。除非其参数是非字面量引用，例如使用 " { $link curry } " 或 " { $link compose } " 构造的引用，或用于 " { $link "fry" } " 或包含 " { $link "locals" } " 的引用，否则下面的定义不会被执行。" } ;

HELP: 2dip
{ $values { "x" object } { "y" object } { "quot" quotation } }
{ $description "从数据栈（datastack）中移除 " { $snippet "x" } " 和 " { $snippet "y" } "，调用 " { $snippet "quot" } "，并在 " { $snippet "quot" } " 完成后将移除的对象恢复到数据栈的顶部。" }
{ $notes "以下是等价的："
    { $code "[ [ foo bar ] dip ] dip" }
    { $code "[ foo bar ] 2dip" }
} ;

HELP: 3dip
{ $values { "x" object } { "y" object } { "z" object } { "quot" quotation } }
{ $description "从数据栈（datastack）中移除 " { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } "，调用 " { $snippet "quot" } "，并在 " { $snippet "quot" } " 完成后将移除的对象恢复到数据栈的顶部。" }
{ $notes "以下是等价的："
    { $code "[ [ [ foo bar ] dip ] dip ] dip" }
    { $code "[ foo bar ] 3dip" }
} ;

HELP: 4dip
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "quot" quotation } }
{ $description "从数据栈（datastack）中移除 " { $snippet "w" } "、" { $snippet "x" } "、" { $snippet "y" } " 和 " { $snippet "z" } "，调用 " { $snippet "quot" } "，并在 " { $snippet "quot" } " 完成后将移除的对象恢复到数据栈的顶部。" }
{ $notes "以下是等价的："
    { $code "[ [ [ [ foo bar ] dip ] dip ] dip ] dip" }
    { $code "[ foo bar ] 4dip" }
} ;

HELP: while
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } }
{ $description "调用 " { $snippet "body" } " 直到 " { $snippet "pred" } " 返回 " { $link f } " 为止。" } ;

HELP: while*
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b ? -- ..a ) } } }
{ $description "调用 " { $snippet "body" } " 直到 " { $snippet "pred" }
  " 返回 " { $link f } " 为止。" { $snippet "pred" } " 的返回值被保留在栈上。" } ;

HELP: until
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } }
{ $description "调用 " { $snippet "body" } " 直到 " { $snippet "pred" } " 返回 " { $link t } " 为止。" } ;

HELP: until*
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } { "?" boolean } }
{ $description "调用 " { $snippet "body" } " 直到 " { $snippet "pred" }
  " 返回 " { $link t } " 为止。" { $snippet "pred" } " 的返回值被保留在栈上。" } ;

HELP: do
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } }
{ $description "执行一个 " { $link while } " 或 " { $link until } " 循环的一次迭代。" } ;

HELP: loop
{ $values
    { "pred" quotation } }
    { $description "反复调用该引用（quotation），直到它输出 " { $link f } " 为止。" }
{ $examples "循环直到遇到零："
    { $unchecked-example "USING: kernel random math io ; "
    " [ \"hi\" write bl 10 random zero? not ] loop"
    "hi hi hi" }
    "一个有趣的循环："
    { $example "USING: kernel prettyprint math ; "
    "3 [ dup . 7 + 11 mod dup 3 = not ] loop drop"
    "3\n10\n6\n2\n9\n5\n1\n8\n4\n0\n7" }
} ;

ARTICLE: "looping-combinators" "循环组合子（Looping combinators）"
"在大多数情况下，循环应该使用高级组合子（如 " { $link "sequences-combinators" } "（序列组合子））或尾递归（tail recursion）来编写。然而，有时表达意图的最佳方式是使用循环。"
{ $subsections
    while
    until
}
"要执行循环的一次迭代，请使用以下单词："
{ $subsections do }
"此单词用作修饰符。正常的 " { $link while } " 循环在第一次迭代中如果谓词（predicate）返回 false，则从不执行循环体。要确保循环体至少执行一次，请使用 " { $link do } "："
{ $code
    "[ P ] [ Q ] do while"
}
"一个更简单的循环组合子，执行单个引用（quotation）直到它返回 " { $link f } "："
{ $subsections loop } ;

HELP: assert
{ $values { "got" "获得的值" } { "expect" "期望的值" } }
{ $description "抛出一个 " { $link assert } " 错误。" }
{ $error-description "当单元测试或其他断言（assertion）失败时抛出。" } ;

HELP: assert=
{ $values { "a" object } { "b" object } }
{ $description "如果 " { $snippet "a" } " 不等于 " { $snippet "b" } "，则抛出一个 " { $link assert } " 错误。" } ;

HELP: become
{ $values { "old" array } { "new" array } }
{ $description "将 " { $snippet "old" } " 中所有对象的引用替换为 " { $snippet "new" } " 中对应的对象。此单词用于实现元组重塑（tuple reshaping）。参见 " { $link "tuple-redefinition" } "。" } ;

ARTICLE: "callables" "可调用对象（Callables）"
"除了 " { $link "quotations" } "（引用）之外，还有两种其他可调用对象（callables）可以高效地组合计算。"
$nl
"将一个对象柯里化（currying）到一个引用上："
{ $subsections
    curry
    curried
}
"组合两个引用："
{ $subsections
    compose
    composed
} ;

ARTICLE: "shuffle-words" "栈操作单词（Shuffle words）"
"栈操作单词（shuffle words）如其栈效果（stack effects）所示，重新排列数据栈（data stack）顶部的元素。它们提供了单词之间简单的数据流控制。更复杂的数据流控制可通过 " { $link "dataflow-combinators" } "（数据流组合子）和 " { $link "locals" } "（局部变量）实现。"
$nl
"移除栈元素："
{ $subsections
    drop
    2drop
    3drop
    4drop
    5drop
    nip
    2nip
    3nip
    4nip
    5nip
}
"复制栈元素："
{ $subsections
    dup
    2dup
    3dup
    over
    2over
    pick
}
"排列栈元素："
{ $subsections
    swap
}
"复制栈中较深处的元素："
{ $subsections
    dupd
}
"排列栈中较深处的元素："
{ $subsections
    swapd
    overd
    rot
    -rot
    spin
    4spin
    rotd
    -rotd
    nipd
    2nipd
    3nipd
} ;

ARTICLE: "equality" "相等性（Equality）"
"关于对象有两种不同的\"相同性\"概念。"
$nl
"你可以测试两个引用是否指向同一个对象（" { $emphasis "标识比较（identity comparison）" } "）。这很少使用；它主要用于大型可变对象（mutable objects），其中对象标识很重要但值是瞬态的："
{ $subsections eq? }
"你可以测试两个对象在领域特定意义上是否相等，通常是通过属于同一个类并且具有相等的槽值（slot values）（" { $emphasis "值比较（value comparison）" } "）："
{ $subsections = }
"第三种相等形式由 " { $link number= } " 提供。它比较数值而不考虑类型。"
$nl
"可以在以下泛型单词（generic word）上定义用于 " { $link = } " 的自定义值比较方法："
{ $subsections equal? }
"实用类："
{ $subsections identity-tuple }
"对象可以被克隆（cloned）；克隆体具有不同的标识但相等的值："
{ $subsections clone } ;

ARTICLE: "assertions" "断言（Assertions）"
"一些使断言更容易执行的单词："
{ $subsections
    assert
    assert=
} ;
