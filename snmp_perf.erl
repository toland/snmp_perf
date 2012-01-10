-module(snmp_perf).
-compile(export_all).

-define(ADDRESS, [127,0,0,1]).
-define(COMMUNITY, "public").
-define(USER, "simple_user").


init() ->
    snmp:start(),
    register_agent().

sync(N) ->
    lists:foreach(fun doit/1, lists:seq(1, N)).

async(N) ->
    lists:foreach(fun(X) -> spawn(fun() -> doit(X) end) end, lists:seq(1, N)).

register_agent() ->
    Opts = [{engine_id, "test engine"},
            {address,   ?ADDRESS},
            {community, ?COMMUNITY},
            {version,   v2},
            {sec_model, v2c}],
    snmpm:register_agent(?USER, "test", Opts).

doit(X) ->
    Start = now(),
    case snmpm:sync_get(?USER, "test", [[1,3,6,1,2,1,1,5,0]]) of
        {error, {timeout, _}} ->
            io:fwrite("Request ~B timed out~n", [X]);

        {ok, {noError, _, _}, _} ->
            Diff = timer:now_diff(now(), Start),
            Secs = Diff / 1000000,
            io:fwrite("Finished request ~B in ~p secs~n", [X, Secs]);

        _ ->
            Diff = timer:now_diff(now(), Start),
            Secs = Diff / 1000000,
            io:fwrite("Request ~B failed in ~p secs~n", [X, Secs])
    end.

