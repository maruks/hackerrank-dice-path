-module(dice).

-import(maps,[from_list/1, get/2, to_list/1, put/3, update_with/4, values/1]).
-import(lists,[seq/2, seq/3, foreach/2, map/2, max/1, foldl/3]).

-export([dice/0, merge/2, path/2, main/0, cost/3]).

dice() ->
    #{top=> 1, front=> 2, left=> 3, right=> 4, back=> 5, bottom=> 6}.

right(#{top := Top, left := Left, right := Right, bottom := Bottom} = Dice) ->
    Dice#{top := Left, left := Bottom, bottom := Right, right := Top}.

down(#{top := Top, front := Front, back := Back, bottom := Bottom} = Dice) ->
    Dice#{top := Back, back := Bottom, front := Top, bottom := Front }.

rotate(Fn, D) ->
    Ps = map(fun({K, V}) -> R = Fn(K), {R, V + get(top, R)} end, to_list(D)),
    from_list(Ps).

merge(Left , Top) ->
    L = rotate(fun right/1, Left),
    T = rotate(fun down/1, Top),
    foldl(fun({K, V}, A) -> update_with(K, fun(C) -> max(C,V) end, V, A) end, L, to_list(T)).


% DP state { X, Y } -> { dice -> pts}

init_xs(I, S, N) when I > N ->
    S;
init_xs(I, S, N) ->
    D = get({I - 1, 1}, S),
    init_xs(I + 1, put({I, 1}, rotate(fun right/1, D), S), N).

init_ys(I, S, M) when I > M ->
    S;
init_ys(I, S, M) ->
    D = get({1, I - 1}, S),
    init_ys(I + 1, put({1, I}, rotate(fun down/1, D), S), M).

initial_state(M, N) ->
    S = #{ {1,1} => #{dice() => 1}},
    S1 = init_xs(2, S, N),
    init_ys(2, S1, M).

next_xy(X, Y, M) when Y < M ->
    {X, Y + 1};
next_xy(X, Y, _) ->
    {X + 1, Y}.

find_path(Xp, Yp, S, M, N) when Xp =< N, Yp =< M ->
    Ps = [ {Xp + Yp - Y, Y} || Y <- seq(Yp, 2, -1), Xp + Yp - Y =< N ],
    NS = foldl(fun({X, Y}=K, A) -> put(K, merge(get({X - 1, Y}, A), get({X, Y - 1}, A)) , A) end, S, Ps),
    {X, Y} = next_xy(Xp, Yp, M),
    find_path(X, Y, NS, M, N);
find_path(_, _, S, _, _) ->
    S.

path(M, N) ->
    find_path(2, 2, initial_state(M, N), M, N).

cost(S, N, M) ->
    T = get({N, M}, S),
    max(values(T)).

read(_, 0) ->
    bye;
read(S, T) ->
    {ok, [M]} = io:fread("", "~d"),
    {ok, [N]} = io:fread("", "~d"),
    io:format("~w~n",[ cost(S, N, M) ]),
    read(S, T-1).

main() ->
    {ok,[T]} = io:fread("", "~d"),
    S = path(60, 60),
    read(S,T),
    halt().
