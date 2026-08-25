-module(waf_analyzer).
-export([analyze/1]).

-spec analyze(ParsedRequest :: map()) -> {score, integer()}.
analyze(ParsedRequest) ->
    io:format("Body: ~p~n", [ParsedRequest]),
    
    SqliPattern = ~B"(?i)(SELECT\W|UNION\W|INSERT\W|DELETE\W|UPDATE\W|DROP\W|--|;|')",
    {ok, SqliPatternCompiled} = re:compile(SqliPattern, [caseless, multiline, unicode]),
    
    SqliScoreBody = sqli_score(maps:get(body, ParsedRequest), SqliPatternCompiled),
    SqliScorePath = sqli_score(maps:get(path, ParsedRequest), SqliPatternCompiled),

    XssPattern = ~B"(?i)(script|javascript)",
    % XssPattern = ~B"(?i)(<([A-Za-z_{}()/]+(\s|=)*)+>(.*<[A-Za-z/>]+)*)",
    {ok, XssPatternCompiled} = re:compile(XssPattern, [caseless, multiline, unicode]),
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
