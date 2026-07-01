! 非侵入式修复：Factor 监听器底部状态栏中文本地化
! 重新定义 ui.tools.listener 中的 error-summary. 词
! 原始英文文本: "Press F3 to view errors."
! 注意：此文件通过 run-file 加载，避免侵入原始 listener.factor

USING: accessors assocs help.markup io.styles kernel namespaces
sequences source-files.errors ui.commands ui.tools.common
ui.tools.error-list ;
IN: ui.tools.listener

! 直接替换 error-summary. 的函数体，保留原始逻辑仅改字符串
: error-summary. ( -- )
    error-counts keys [
        H{ { table-gap { 3 3 } } } [
            [ [ [ icon>> write-image ] with-cell ] each ] with-row
        ] tabular-output
        last-element off
        { "按 " { $command tool "common" show-error-list } " 查看错误。" }
        print-element
    ] unless-empty ;