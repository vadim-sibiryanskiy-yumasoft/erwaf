-module(sec_rules).
-export([get_patterns/0]).

-spec get_patterns() -> map().
get_patterns() ->
    SqliPattern = ~B/(?i)(SELECT\W|UNION\W|INSERT\W|DELETE\W|UPDATE\W|DROP\W|--|;|['`])/,
    XssPattern = ~B/(?i)(script|javascript)/,
    #{
        sqliPattern => SqliPattern,
        xssPattern => XssPattern
    }.