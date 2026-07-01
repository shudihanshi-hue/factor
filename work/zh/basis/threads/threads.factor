USING: assocs boxes deques dlists heaps help.markup help.syntax
init kernel kernel.private namespaces quotations strings system
threads threads.private ;
IN: zh.basis.threads

ARTICLE: "threads-start/stop" "启动和停止线程"
"创建新线程："
{ $subsections
    spawn
    spawn-server
}
"创建和启动线程可以分解为两个独立的步骤："
{ $subsections
    <thread>
    (spawn)
}
"线程在传递给 " { $link spawn } " 的引用返回时停止，或者在调用以下词时停止："
{ $subsections stop }
"如果映像被保存并重新启动，所有可运行线程都将被停止。希望始终运行后台线程的词汇表应该使用 " { $link add-startup-hook } "。" ;

ARTICLE: "threads-yield" "让出和挂起线程"
"将执行权让给其他线程："
{ $subsections yield }
"休眠一段时间："
{ $subsections sleep }
"中断休眠："
{ $subsections interrupt }
"线程可以被挂起，并在将来某个条件满足时被唤醒："
{ $subsections
    suspend
    resume
    resume-with
} ;

ARTICLE: "thread-state" "线程局部状态和变量"
"线程构成一类对象："
{ $subsections thread }
"当前线程："
{ $subsections self }
"线程局部变量："
{ $subsections
    tnamespace
    tget
    tset
    tchange
}
"每个线程都有自己独立的一组线程局部变量，新创建的线程以空集合开始。"
$nl
"所有线程的全局哈希表，以 " { $snippet "id" } " 为键："
{ $subsections threads }
"线程拥有独立于延续的标识。如果一个延续在一个线程中被具体化，然后在另一个线程中被反映，则运行在该延续中的代码将观察到 " { $link self } " 输出值的变化。" ;

ARTICLE: "thread-impl" "线程实现"
"线程实现："
{ $subsections
    run-queue
    sleep-queue
} ;

ARTICLE: "threads" "协作线程（Co-operative threads）"
"Factor 支持协作线程。线程在等待输入/输出操作完成时会自动让出，或者当显式请求让出时也会让出。"
$nl
"用于操作线程的词位于 " { $vocab-link "threads" } " 词汇表中。"
{ $subsections
    "threads-start/stop"
    "threads-yield"
    "thread-state"
    "thread-impl"
} ;

ABOUT: "threads"

HELP: thread
{ $class-description "一个线程。其槽位如下："
    { $slots
      {
          "id"
          "分配给每个线程的唯一标识符。"
      }
      {
          "exit-handler"
          { "线程被停止时运行的 " { $link quotation } "。" }
      }
      {
          "name"
          { "传递给 " { $link spawn } " 的名称。" }
      }
      {
          "quot"
          { "传递给 " { $link spawn } " 的初始引用。" }
      }
      {
          "runnable"
          { "线程是否可运行。初始值为 " { $link t } "。" }
      }
      {
          "state"
          { "一个 " { $link string } "，指示线程正在等待什么，或者为 " { $link f } "。此槽位用于调试目的。" }
      }
      {
          "context"
          { "一个 " { $link box } "，持有指向线程 " { $link context } " 对象的外来指针。" }
      }
    }
} ;

HELP: self
{ $values { "thread" thread } }
{ $description "将当前正在运行的线程入栈。" } ;

HELP: <thread>
{ $values { "quot" quotation } { "name" string } { "thread" thread } }
{ $description "底层线程构造器。线程在启动时运行该引用。"
$nl
"名称用于调试时标识线程；参见 " { $link "tools.threads" } "。" }
{ $notes "在大多数情况下，用户代码应该调用 " { $link spawn } "，但为了控制错误处理引用，可以使用 " { $link <thread> } " 创建线程，然后将其传递给 " { $link (spawn) } "。" } ;

HELP: run-queue
{ $values { "dlist" dlist } }
{ $var-description "保存可运行线程队列的全局变量。调用 " { $link yield } " 会切换到在队列中等待时间最长的线程。"
$nl
"按照惯例，线程使用 " { $link push-front } " 入队，使用 " { $link pop-back } " 出队。" } ;

HELP: resume
{ $values { "thread" thread } }
{ $description "将线程添加到运行队列的末尾。该线程必须之前已通过对 " { $link suspend } " 的调用被挂起。" } ;

HELP: resume-with
{ $values { "obj" object } { "thread" thread } }
{ $description "将线程添加到运行队列的末尾，同时传递一个对象给该线程。该线程必须之前已通过对 " { $link suspend } " 的调用被挂起；该对象将从 " { $link suspend } " 调用中返回。" } ;

HELP: sleep-queue
{ $values { "heap" min-heap } }
{ $var-description "一个 " { $link min-heap } "，存储休眠线程队列。" } ;

HELP: sleep-time
{ $values { "nanos/f" { $maybe "一个非负整数" } } }
{ $description "返回到下一个休眠线程被调度唤醒的时间，如果有线程在运行队列中或线程需要立即唤醒，则可能为零。如果没有可运行或休眠的线程，则返回 " { $link f } "。" } ;

HELP: stop
{ $description "停止当前线程。该线程可以从另一个线程使用 " { $link (spawn) } " 重新启动。" } ;

HELP: yield
{ $description "将当前线程添加到运行队列末尾，并切换到下一个可运行线程。" } ;

HELP: sleep-until
{ $values { "n/f" { $maybe "一个非负整数" } } }
{ $description "挂起当前线程，直到达到由 " { $link nano-count } " 返回的指定纳秒计数值，或者如果传入 " { $link f } " 值则无限期挂起。"
$nl
"其他线程可以通过调用 " { $link interrupt } " 来中断休眠。" } ;

HELP: sleep
{ $values { "dt" "一个 duration（时长）" } }
{ $description "将当前线程挂起指定的时长。"
$nl
"其他线程可以通过调用 " { $link interrupt } " 来中断休眠。" }
{ $examples
    { $code "USING: threads calendar ;" "10 seconds sleep" }
} ;

HELP: interrupt
{ $values { "thread" thread } }
{ $description "中断一个正在休眠的线程。" } ;

HELP: suspend
{ $values { "state" string } { "obj" object } }
{ $description "挂起当前线程。控制权让给下一个可运行线程，当前线程在被恢复之前不再执行，因此此词的调用者必须安排另一个线程稍后通过调用 " { $link resume } " 或 " { $link resume-with } " 来恢复被挂起的线程。"
$nl
"状态字符串用于调试目的；参见 " { $link "tools.threads" } "。" } ;

HELP: spawn
{ $values { "quot" quotation } { "name" string } { "thread" thread } }
{ $description "创建一个新线程。该线程开始执行给定的引用；名称用于调试目的。新线程立即开始运行，当前线程被添加到运行队列的末尾。"
$nl
"新线程以空数据栈、空保留栈和空捕获栈开始。名称栈从父线程继承，但可以使用 " { $link init-namestack } " 清除。" }
{ $notes
    "向新线程传递数据的推荐方式是显式构造一个包含数据的引用，例如使用 " { $link curry } " 或 " { $link compose } "。"
}
{ $examples
    "一个简单的线程，将两个数字相加："
    { $code "1 2 [ + . ] 2curry \"加法线程\" spawn" }
    "一个计数到 10 的线程："
    ! 下面不要使用 $example：它无法通过 help-lint 检查。
    { $code
      "USING: math.parser threads ;"
      "[ 10 <iota> [ number>string print yield ] each ] \"test\" spawn drop"
      "10 [ yield ] times"
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
    }
} ;

HELP: spawn-server
{ $values { "quot" { $quotation ( -- ? ) } } { "name" string } { "thread" thread } }
{ $description "对 " { $link spawn } " 的便捷封装，在一个新线程中反复调用引用，直到其输出 " { $link f } " 。" }
{ $examples
    "一个永远运行的线程："
    { $code "[ do-foo-bar t ] \"Foo bar 服务器\" spawn-server" }
} ;

HELP: init-threads
{ $description "在启动期间调用以初始化线程系统。此词永远不应被直接调用。" } ;

HELP: tnamespace
{ $values { "assoc" assoc } }
{ $description "输出当前线程的线程局部变量集合。" } ;

HELP: tget
{ $values { "key" object } { "value" object } }
{ $description "输出一个线程局部变量的值。" } ;

HELP: tset
{ $values { "value" object } { "key" object } }
{ $description "设置一个线程局部变量的值。" } ;

HELP: tchange
{ $values { "key" object } { "quot" { $quotation ( ..a value -- ..b newvalue ) } } }
{ $description "将引用应用于线程局部变量的当前值，并将结果存回同一个变量。" } ;
