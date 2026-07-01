USING: io help.topics help.home vocab vocabs.loader ;
IN: test-verify

: show-all ( -- )
    "zh" reload
    "help.home" article-title .
    "help.home" article-content .
    "zh-handbook" article-title .
    "zh-tour" article-title .
    "zh-tutorial" article-title .
    "zh-language" article-title .
    "zh-evaluator" article-title .
    "zh-effects" article-title .
    "zh-effects" article-content .
    "OK" print ;

MAIN: show-all
