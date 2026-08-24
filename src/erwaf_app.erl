%%%-------------------------------------------------------------------
%% @doc erwaf public API
%% @end
%%%-------------------------------------------------------------------

-module(erwaf_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    erwaf_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
