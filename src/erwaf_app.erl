%%%-------------------------------------------------------------------
%% @doc erwaf public API
%% @end
%%%-------------------------------------------------------------------

-module(erwaf_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    add_persistent_terms(),
    erwaf_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
add_persistent_terms() ->
    io:format("erwaf_app:add_persistent_terms~n"),
    SqliPattern = ~B"(?i)(SELECT\W|UNION\W|INSERT\W|DELETE\W|UPDATE\W|DROP\W|--|;|')",
    {ok, SqliPatternCompiled} = re:compile(SqliPattern, [caseless, multiline]),
    persistent_term:put({erwaf, sqli_mp}, SqliPatternCompiled),
    
    XssPattern = ~B"(?i)(script|javascript)",
    {ok, XssPatternCompiled} = re:compile(XssPattern, [caseless, multiline]),
    persistent_term:put({erwaf, xss_mp}, XssPatternCompiled).
