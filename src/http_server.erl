-module(http_server).
-define(PORT, 8081).
-export([start/0]).

start() ->
    {ok, ListenSocket} = gen_tcp:listen(?PORT, [binary, {packet, 0}, {active, false}]),
    io:format("Server started on port ~p~n", [?PORT]),
    accept_loop(ListenSocket).

accept_loop(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() -> handle_request(Socket) end),
    accept_loop(ListenSocket).

handle_request(Socket) ->
    {ok, Request} = read_request(Socket),
    Response = process_request(Request),
    send_response(Socket, Response),
    gen_tcp:close(Socket).

read_request(Socket) ->
    {ok, Data} = gen_tcp:recv(Socket, 0),
    {ok, Data}.

process_request(Request) ->
    Parsed = parser_service:parse(Request),
    io:format("Received request: ~p~n", [Request]),
    io:format("Parsed request: ~p~n", [Parsed]),
    % #{method := M, path := P} = Parsed,
    Result = waf_analyzer:analyze(Parsed),

    % В данном примере просто возвращаем статический ответ
    case Result of 
        {false} -> <<"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nGood request!">>;
        {true} -> <<"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nBad request :(">>
    end.

send_response(Socket, Response) ->
    gen_tcp:send(Socket, Response).
