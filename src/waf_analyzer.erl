-module(waf_analyzer).
-export([analyze/1]).

analyze(#{body := Body}) ->
    io:format("Body: ~p~n", [Body]),
    looks_like_sqli(Body).

looks_like_sqli(_Body) ->
    false.