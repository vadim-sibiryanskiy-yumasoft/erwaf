-module(parser_service).
-export([parse/1]).

-define(MAX_PACKET_SIZE, 1048576). %% 1048576=1MB limit of the maximum allowed size of the packet body

% -spec parser_service:parse(Raw :: binary) -> {ok, map()} | {error, Reason :: string()}.
parse(Raw) 
    when is_binary(Raw) andalso 
         byte_size(Raw) =< ?MAX_PACKET_SIZE 
         ->
    {request_line, {{abs_path, AbsPath}, {method, HttpMethod}}, Rest0} = request_line(Raw),
    {ok, Headers, Rest1} = headers(Rest0, []), % Rest1 == Body
    {ok, #{ 
        method  => HttpMethod,
        path    => AbsPath,
        headers => Headers,
        body    => Rest1
    }};
parse(Raw)
    when is_binary(Raw) andalso 
         byte_size(Raw) > ?MAX_PACKET_SIZE 
         ->
    {error, <<"Packet size exceeds MAX_PACKET_SIZE=1048576">>}.

request_line(Bin) ->
    case erlang:decode_packet(http_bin, Bin, []) of
        {ok, {'http_request', HttpMethod, {abs_path, AbsPath}, _HttpVersion}, Rest} -> {request_line, {{abs_path, AbsPath}, {method, HttpMethod}}, Rest}
    end.

%% Pull headers recursively, until decode_packet returns http_eoh
headers(Bin, Acc) ->
    case erlang:decode_packet(httph_bin, Bin, []) of
        {ok, {http_header, _, HttpField, _UnmodifiedField, Value}, Rest} -> headers(Rest, [{HttpField, Value} | Acc]);
        {ok, http_eoh, Rest} -> {ok, lists:reverse(Acc), Rest}
    end.
