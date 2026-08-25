-module(waf_analyzer).
-export([analyze/1]).

-spec analyze(ParsedRequest :: map()) -> {score, integer()}.
analyze(ParsedRequest) ->
    io:format("Body: ~p~n", [ParsedRequest]),
    
    SqliPatternCompiled = persistent_term:get({erwaf, sqli_mp}),
    SqliScoreBody = sqli_score(maps:get(body, ParsedRequest), SqliPatternCompiled),
    SqliScorePath = sqli_score(maps:get(path, ParsedRequest), SqliPatternCompiled),

    XssPatternCompiled = persistent_term:get({erwaf, xss_mp}),
    XssScoreBody = xss_score(maps:get(body, ParsedRequest), XssPatternCompiled),
    XssScorePath = xss_score(maps:get(path, ParsedRequest), XssPatternCompiled),
    
    {score, SqliScoreBody + SqliScorePath + XssScoreBody + XssScorePath}.

-spec sqli_score(Arg1 :: binary(), SqliPatternCompiled :: re:mp()) -> integer().
sqli_score(Body, SqliPatternCompiled) ->
    Match = re:run(Body, SqliPatternCompiled),
    case Match of
        {match, _Captured} -> 1;
        nomatch -> 0;
        {error, _ErrType} -> logger:error("RegEx error")
    end.

-spec xss_score(Body :: binary(), XssPatternCompiled :: re:mp()) -> integer().
xss_score(Body, XssPatternCompiled) ->
    Match = re:run(Body, XssPatternCompiled),
    case Match of
        {match, _Captured} -> 1;
        nomatch -> 0;
        {error, _ErrType} -> logger:error("RegEx error")
    end.
