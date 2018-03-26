-module(dice_test).

-include_lib("eunit/include/eunit.hrl").

-import(dice,[dice/0, merge/2, path/2, cost/3]).

merge_test() ->
    M = merge(#{dice() => 1}, #{dice() => 3}),
    ?assertEqual(M, #{#{back => 5,bottom => 4,front => 2,left => 6,right => 1,
    top => 3} =>
      4, #{back => 6,bottom => 2,front => 1,left => 3,right => 4,
    top => 5} =>
      8}).

path_test() ->
    S = path(60,60),
    ?assertEqual(9, cost(S, 2, 2)),
    ?assertEqual(4, cost(S, 2, 1)),
    ?assertEqual(6, cost(S, 1, 2)),
    ?assertEqual(19, cost(S, 3, 3)),
    ?assertEqual(316, cost(S, 60, 31)),
    ?assertEqual(418, cost(S, 60, 60)).
