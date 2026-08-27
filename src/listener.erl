-module(listener).
-define(PORT, 8081).
-export([start/0]).

start() ->
    {ok, ListenSocket} = gen_tcp:listen(?PORT, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
    io:format("Server started on port ~p~n", [?PORT]),
    accept_loop(ListenSocket).

accept_loop(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() -> handle_request(Socket) end),
    accept_loop(ListenSocket).

handle_request(Socket) ->
    {ok, Packet} = read_request(Socket),
    Response = process_request(Packet),
    send_response(Socket, Response),
    gen_tcp:close(Socket).

read_request(Socket) ->
    {ok, Packet} = gen_tcp:recv(Socket, 0),
    {ok, Packet}.

-spec process_request(Packet :: binary()) -> binary().
process_request(Packet) ->
    io:format("Received Packet: ~p~n", [Packet]),
    
    ParseResult = parser_service:parse(Packet),
    case ParseResult of
        {ok, ParsedPacket} ->
            AnomalyScore = waf_analyzer:analyze(ParsedPacket);
        {error, Reason} -> 
            logger:alert("Oversized Packet = " ++ Reason),
            AnomalyScore = {score, 10}
    end,

    case AnomalyScore of 
        {score, Value} when Value =:= 0 -> <<"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nGood request!">>;
        {score, Value} when Value > 0 -> 
            logger:alert("AnomalyScore = " ++ integer_to_list(Value)),
            <<"HTTP/1.1 403 Forbidden\r\nContent-Type: text/plain\r\n\r\nBad request :(">>
    end.

send_response(Socket, Response) ->
    gen_tcp:send(Socket, Response).
