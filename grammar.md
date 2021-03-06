# An EBNF grammar for Ludus
First draft (0.0.1)

Last revised Feb 7, 2022

In modified/haphazard EBNF.

There's a proliferation of terminators here that might mean this doesn't quite compile.

```
word -> letter { letter | digit | "*" | "?" | "/" | "_" | "!" };

ignored -> "_", word;

keyword -> ":", word;

string -> ", ? any char (UTF-8) but ", except escaped by \ ?, ";

number -> ["-", digit, {digit}, [ ".", digit, {digit} ];

atom -> "nil" | "true" | "false" | string | number | keyword;

(* above here is chunked by the scanner *)

tuple terminator -> newline | ",";

tuple -> "(", {tuple terminator}, {expression, {tuple terminator, {tuple terminator}, expression}, tuple terminator}), ")";

list terminator -> newline | ",";

list -> "[", {list terminator}, {expression, {list terminator, {list terminator}, expression}, {list terminator}}, "]";

hashmap terminator -> newline | ",";

hashmap entry -> ((keyword, expression) | word | "...", word), hashmap terminator, {hashmap terminator};

hashmap -> "#{", {hashmap terminator}, {hashmap entry}, "}";

set entry terminator -> newline | ",";

set -> "${", {set entry terminator}, {expression, {set entry terminator, {set entry terminator}, expression} {set entry terminator}}, "}";

collection -> list | hashmap | set;

block terminator -> newline | ";";

block -> "{", {block terminator}, {expression, {block terminator, expression} {block terminator}}, "}";

callable -> word | keyword | called | property;

(* TODO: include a placeholder here *)
called -> callable, tuple;

propertied -> word | hashmap | called | property;

property -> propertied, keyword;

synthetic -> called | property;

if -> "if", expression, "then", expression, "else", expression;

placeholder -> "_";

cond terminator -> newline;

cond clause -> expression, "->", expression;

(* TODO: final cond clause, with `else` or `_` *)
(* Should a case after an `else`/`_` be a parse error? *)

cond -> "cond", "{", {cond terminator}, cond clause, {cond terminator, {cond terminator}, cond clause}, {cond terminator}, "}";

simple pattern -> atom | word | "_" | ignored;

tuple pattern -> (* TODO *)

list pattern -> (* TODO *)

hashmap pattern -> (* TODO *)

set pattern -> (* TODO *)

collection pattern -> tuple pattern | list pattern | hashmap pattern | set pattern;

pattern -> simple pattern | collection pattern;

(* How do we restrict guard patterns? *)
guard expression -> (* TODO *)

complex pattern -> pattern, "when", guard expression;

atom let -> "let", literal, "<-", expression;

simple let -> "let", word, "<-", expression;

pattern let -> "let", pattern, "<-", expression;

complext let -> "let", complex pattern, "<-", expression;

let -> atom let | simple let | pattern let | complex let;

match terminator -> newline;

match clause -> pattern, "->", expression;

match -> "match", expression, "with", "{", {match terminator}, match clause, {match terminator, {match terminator}, match clause}, {match terminator}, "}";

conditional -> if | cond | match;

fn terminator -> newline;

fn clause -> tuple pattern, "->", expression;

simple fn -> "fn", {word}, fn clause;

complex fn -> "fn", {word}, "with", "{", {fn terminator}, fn clause, {fn terminator, {fn terminator}, fn clause}, {fn terminator}, "}";

fn -> simple fn | complex fn;

(* built-in "statements" *)
panic -> "panic!", expression;

test -> "test", string, expression;

defer -> "defer", expression;

repeat -> "repeat", number, expression;

simple loop -> "loop", tuple, "into", fn clause;

complex loop -> "loop", tuple, "with", "{", {fn terminator}, fn clause, {fn terminator, {fn terminator}, fn clause}, {fn terminator}, "}";

(*  *)
yield -> "yield", expression;

gen expr -> expression | yield;

gen clause -> tuple pattern, "->", gen expr;

simple gen -> "gen", tuple, "into", gen clause;

complex gen -> "gen", tuple, "with", "{", {fn terminator}, gen clause, {fn terminator, {fn terminator}}, gen clause}, {fn terminator}, "}";

generator -> simple gen | complex gen;

(* varibales and mutation *)
variable -> "var", word, "<-", expression;

mutation -> "mut", word, "<-", expression;

expression terminator -> newline | ";" | eof;

(* namespaces *)
ns terminator -> newline | ",";

namespace -> "ns", word, "{", {ns terminator}, {word, {ns terminator, {ns terminator}, word}}, "}";

expression -> {expression terminator}, (atom | collection | block | synthetic | let | conditional | fn | panic), expression terminator, {expression terminator};

```

What isn't yet in this grammar?
* Splats for collections
	- in expressions
	- in patterns
* Function pipelines (ugh, that's gonna be a doozie?)
* Partial application with placeholder
* Continue expression on next line with `\`
* Complex patterns
	- collection patterns
	- `as` patterns
	- `when` guards