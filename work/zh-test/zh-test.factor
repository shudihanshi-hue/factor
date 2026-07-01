USING: io help.topics help.home prettyprint vocabs vocabs.loader ;
IN: zh-test

: show-all ( -- )
    "zh" reload
    "sequences" article-title print
    "sequences" article-content .
    "zh-core-kernel" article-title print
    "zh-core-kernel" article-content .
    "help.home" article-title print
    "help.home" article-content .
    "OK" print ;

MAIN: show-all
