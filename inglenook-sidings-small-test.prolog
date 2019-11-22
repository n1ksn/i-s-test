%%%------------------------------------------------------------------------
%%% inglenook-sidings-small-test.prolog
%%%
%%% Find solutions to the small version of the classic shunting (switching)
%%% puzzle using Prolog.
%%% This set of predicates has been tested using SWI Prolog and gprolog on
%%% Linux and using SWI Prolog on Windows 10.
%%%
%%% Andrew Palm
%%% 2019-11-22
%%%
%%%
%%%------------------------------------------------------------------------
%%% These are for use in yap.  They can be commented out when using
%%% swi prolog or gprolog
:- use_module(library(lists)).
append(File) :-
  open(File, 'append', Stream),
  set_output(Stream).
%%%
%%% Predicates to find solutions
%%% ----------------------------
%% Allowed moves
%% The variable E in the move predicate arguments represents the engine.
% Pull or drop two cars
move([[E],[A,B|T1],T2,T3], [[E,A,B],T1,T2,T3]) :- length(T1,N), N<2.
move([[E],T1,[A,B],T3], [[E,A,B],T1,[],T3]).
move([[E],T1,T2,[A,B]], [[E,A,B],T1,T2,[]]).
move([[E,A,B],T1,T2,T3], [[E],[A,B|T1],T2,T3]) :- length(T1,N), N<2.
move([[E,A,B],T1,[],T3], [[E],T1,[A,B],T3]).
move([[E,A,B],T1,T2,[]], [[E],T1,T2,[A,B]]).

% Pull or drop one car
move([[E],[A|T1],T2,T3], [[E,A],T1,T2,T3]) :- length(T1,N), N<3.
move([[E],T1,[A|T2],T3], [[E,A],T1,T2,T3]) :- length(T2,N), N<2.
move([[E],T1,T2,[A|T3]], [[E,A],T1,T2,T3]) :- length(T3,N), N<2.
move([[E,A],T1,T2,T3], [[E],[A|T1],T2,T3]) :- length(T1,N), N<3.
move([[E,A],T1,T2,T3], [[E],T1,[A|T2],T3]) :- length(T2,N), N<2.
move([[E,A],T1,T2,T3], [[E],T1,T2,[A|T3]]) :- length(T3,N), N<2.

move([[E,A],[B|T1],T2,T3], [[E,A,B],T1,T2,T3]) :- length(T1,N), N<3.
move([[E,A],T1,[B|T2],T3], [[E,A,B],T1,T2,T3]) :- length(T2,N), N<2.
move([[E,A],T1,T2,[B|T3]], [[E,A,B],T1,T2,T3]) :- length(T3,N), N<2.
move([[E,A,B],T1,T2,T3], [[E,A],[B|T1],T2,T3]) :- length(T1,N), N<3.
move([[E,A,B],T1,T2,T3], [[E,A],T1,[B|T2],T3]) :- length(T2,N), N<2.
move([[E,A,B],T1,T2,T3], [[E,A],T1,T2,[B|T3]]) :- length(T3,N), N<2.

%% path(StartState, LastState, Path) succeeds if Path is a list of
%% states from StartState to LastState (in reverse order) using legal
%% moves
path(State, State, [State]).
path(StartState, LastState, [LastState|Path]) :-
  path(StartState, OneButLast, Path),
  move(OneButLast, LastState),
  \+ member(LastState, Path).

%% solve(StartState, EndState) succeeds if there is a path of
%% moves from StartState to EndState.
solve(StartState, EndState) :-
  path(StartState, EndState, Path), !,
  write_solution(Path).

write_solution(Path) :-
  length(Path, N),
  Nsteps is N-1,
  %write(Nsteps), nl.   % This line is for writing number of moves only
  write('     '), write('Moves: '), write(Nsteps),
  nl, write('Solution: (read from top down)'),
  reverse(Path, RevPath),
  nl, write_states(RevPath).

%% Write the solution path with track 0 re-reversed for output
write_states([]) :- nl.
write_states([H|T]) :-
  write(H), nl, write_states(T).

%%% Utilities
%%% ---------
%% first_n(N, L1, L2, L3) succeeds if L2 is a list of the first N
%% elements of L1 and L3 is what remains from L1
first_n(N, L1, L2, L3) :-
  append(L2, L3, L1), length(L2, N).

%% last_n(N, L1, L2, L3) succeeds if L2 is a list of the last N
%% elements of L1 and L3 is what remains from L1
last_n(N, L1, L2, L3) :-
  append(L3, L2, L1), length(L2, N).

%% Generate all problem starting conditions and solve them.
%generate_all_problems :-
%	append('solutions-small-all.txt'), !,
%  permutation([1, 2, 3, 4, 5], StartList),
%	first_n(3, StartList, StartTrk1, StartTrk2),
% 	StartState = [[e], StartTrk1, StartTrk2, []],
% 	EndState = [[e], [1, 2, 3], [4, 5], []],
%  write('Start state: '), write(StartState), nl,
% 	solve(StartState, EndState),
% 	fail.

generate_all_permutations :-
  append('all-small-perms.txt'), !,
  permutation([1, 2, 3, 4, 5], L),
  write(L), write('.'), nl,
  fail.

read_permutations(InFile, OutFile) :-
  append(OutFile),
  see(InFile),
  repeat,
    read(Term),
    (  Term == end_of_file
    -> (  current_output(OutStream),
          close(OutStream),
          current_input(InStream),
          close(InStream),
          tell(user),
          write('Done!'), nl, !)
    ;  process(Term),
       fail
    ).

process(StartList) :-
	first_n(3, StartList, StartTrk1, StartTrk2),
 	StartState = [[e], StartTrk1, StartTrk2, []],
 	EndState = [[e], [1, 2, 3], [4, 5], []],
  write('Start state: '), write(StartState),
 	solve(StartState, EndState).
