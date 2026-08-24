-module(waf_analyzer_rule).

-callback analyze(Request :: map()) ->
    {ok, Reason :: atom()} | {block, Reason :: atom()}.
