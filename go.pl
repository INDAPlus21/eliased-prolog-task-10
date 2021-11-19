/*
% Get an element from a 2-dimensional list at (Row,Column)
using 1-based indexing.
alive(5, 5, 'alive_example.txt').
check_alive(5,5,'alive_example.txt').
alive(4,5,'dead_example.txt').
; = or, , = and 
swipl 
[template].
Variables are immutable! 
*/

nth1_2d(Row, Column, List, Element) :-
    nth1(Row, List, SubList),
    nth1(Column, SubList, Element).

sum(X, Y) :-
    S is X+Y,
    write(S).

% Top-level predicate
alive(Row, Column, BoardFileName) :-
    see(BoardFileName),     % Loads the input-file
    read(Board),            % Reads the first Prolog-term from the file
    seen,                   % Closes the io-stream
    Adjancent_white=[],
    nth1_2d(Row, Column, Board, Stone),
    (Stone = w; Stone = b),
    Stone_color = Stone,
    real_adjancent_of_color(Row, Column, Board, Stone_color, Adjancent_white).

stop(X) :-
    (   X=:=0
    ->  halt
    ).

is_e(Row, Column, Board) :-
    nth1_2d(Row, Column, Board, Stone),
    Stone=e.

is_w(Row, Column, Board) :-
    nth1_2d(Row, Column, Board, Stone),
    Stone=w.

is_b(Row, Column, Board) :-
    nth1_2d(Row, Column, Board, Stone),
    Stone=b.

is_color(Row, Column, Board, Stone_color) :-
    nth1_2d(Row, Column, Board, Stone),
    Stone=Stone_color.


member(X, [X|_]).
member(X, [_|T]):-
    member(X, T).


is_adjacent_e(Row, Column, Board) :-
    (   write("in adjacent e\n"),
        R is Row+1, % one "right"
    /* Prolog checks if Row === Row +1, which it isn't*/
        (   R<9,
            Column<9
        ->  is_e(R, Column, Board)
        ;   false
        )
    ;   C is Column+1, % One "down"
        (   Row<9,
            C<9
        ->  is_e(Row, C, Board)
        ;   false
        )
    ;   Ro is Row-1, % One "left"
        (   Ro<9,
            Column<9
        ->  is_e(Ro, Column, Board)
        ;   false
        )
    ;   Co is Column-1, % One "up" 
        (   Row<9,
            Co<9
        ->  is_e(Row, Co, Board)
        ;   false
        )
    ).

supportive_adjacent(Row, Column, Board, Stone_color, Adjancent_white) :-
    write("in supportive adjancent\n"),
    write(Adjancent_white),
    write([Row, Column]),
    (   Row<9,
        Column<9
    ->  (   is_color(Row, Column, Board, Stone_color)
        ->  (   is_adjacent_e(Row, Column, Board)
            ->  write("Found an e! It´s alive!\n"),
                write([Row, Column]),
                stop(0)
            ;   (\+ member([Row, Column], Adjancent_white) 
            ->  write("going recursive!\n"),
                append(Adjancent_white, [[Row, Column]], New_list),
                real_adjancent_of_color(Row,
                                        Column,
                                        Board,
                                        Stone_color,
                                        New_list)
            ))
        )
    ).

real_adjancent_of_color(Row, Column, Board, Stone_color, Adjancent_white) :-
    (   write("in real adjacent same color\n"),
        supportive_adjacent(Row, Column, Board, Stone_color, Adjancent_white)
    ;   R is Row+1, % one "right"
        supportive_adjacent(R, Column, Board, Stone_color, Adjancent_white)
    ;   C is Column+1, % One "down"
        supportive_adjacent(Row, C, Board, Stone_color, Adjancent_white)
    ;   Ro is Row-1, % One "left"
        supportive_adjacent(Ro, Column, Board, Stone_color, Adjancent_white)
    ;   Co is Column-1, % One "up"
        supportive_adjacent(Row, Co, Board, Stone_color, Adjancent_white)
    ).