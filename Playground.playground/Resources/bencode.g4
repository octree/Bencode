grammar Bencode;

INT : DIGIT | NZ_DIGIT DIGIT*;

fragment DIGIT    : [0-9];
fragment NZ_DIGIT : [1-9];

ANY : .;

bencode : value*;

value : integer
| string
| list
| dictionary
;

list       : 'l' value* 'e';
dictionary : 'd' (string value)* 'e';
integer    : 'i' sign=('+'|'-')? INT 'e';
string     : INT ':' stringData[$INT.int];

stringData[int n]
locals [ int i = 0; ]
: ( { $i < $n }? ANY { $i++; } )*
;
