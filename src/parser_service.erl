%% TODO: Rewrite
-module(parser_service).
-export([parse/1]).

% -spec parser_service:parse(Raw :: binary) -> map().
parse(Raw) when is_binary(Raw) ->
    {ok, {http_request, Method, Uri, _Version}, Rest0} =
        erlang:decode_packet(http_bin, Raw, []),
    {Path, Params}  = split_uri(Uri),
    {Headers, Body} = headers(Rest0, []),
    #{method  => Method,          %% 'GET' (atom for known method)
      path    => Path,            %% <<"/">>
      params  => Params,          %% #{<<"k">> => <<"v">>}
      headers => Headers,         %% [{<<"host">>, <<"localhost:8081">>}, ...]
      cookies => cookies(Headers),
      body    => Body}.           %% <<>> for GET

%% Pull headers recursively, until decode_packet returns http_eoh
headers(Bin, Acc) ->
    case erlang:decode_packet(httph_bin, Bin, []) of
        {ok, {http_header, _, Field, _, Value}, Rest} ->
            headers(Rest, [{normalize(Field), Value} | Acc]);
        {ok, http_eoh, Rest} ->
            {lists:reverse(Acc), Rest}
    end.

normalize(F) when is_atom(F) -> string:lowercase(atom_to_binary(F, utf8));
normalize(F)                 -> string:lowercase(F).

split_uri({abs_path, PathQs}) ->
    case binary:split(PathQs, <<"?">>) of
        [Path]        -> {Path, #{}};
        [Path, Query] -> {Path, parse_query(Query)}
    end.

parse_query(Query) ->
    Pairs = binary:split(Query, <<"&">>, [global]),
    maps:from_list([kv(P) || P <- Pairs, P =/= <<>>]).

kv(Pair) ->
    case binary:split(Pair, <<"=">>) of
        [K, V] -> {K, V};
        [K]    -> {K, <<>>}
    end.

cookies(Headers) ->
    case lists:keyfind(<<"cookie">>, 1, Headers) of
        false        -> #{};
        {_, RawCookie} ->
            Parts = binary:split(RawCookie, <<"; ">>, [global]),
            maps:from_list([kv(P) || P <- Parts, P =/= <<>>])
    end.
