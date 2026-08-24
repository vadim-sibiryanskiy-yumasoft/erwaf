-module(waf_analyzer).
-export([analyze/1]).

analyze(ParsedRequest) ->
    io:format("Body: ~p~n", [ParsedRequest]),
    SqliScore = looks_like_sqli(maps:get(body, ParsedRequest)),
    {score, SqliScore}.
    % #{score => SqliScore}.

looks_like_sqli(_Body) ->
    1.