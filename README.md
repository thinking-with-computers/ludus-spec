# ludus-spec
## A draft specification for the Ludus language

### Overview
Ludus is a contemporary translation of Logo. It draws heavily, also, from Lisps: Scheme and Clojure. It is designed from the ground up to be as friendly as possible in syntax, error messages, and use. Its particular characteristics are:
* It is expression-based.
* It is immutable by default, including persistent data structures.
* It uses pattern-matching extensively.

### Syntax & language base

#### Whitespace
Ludus has minimally significant whitespace. Newlines are the ends of expressions (unless preceded by `\`). Newlines can also be used as separators in collection literals (see below).

Indentation (tabs or spaces) are not, however, significant.

#### Comments
Comments are indicated by an ampersand, `&`. The rest of the line is ignored:

```
& this is a comment
& this is also a comment
"This is a string, not a comment"
```

##### Docstring comments
In function expressions (see below), there's a special kind of comment that provides documentation for the function. It begins with three ampersands: `&&& this is a docstring comment`. Docstring comments can contain markdown that will be formatted in automatically generated documentation.

#### Literal atoms
Ludus has several builtin literal types: `nil`, Booleans, numbers, keywords, and strings. (More on the type system below.)

##### `nil`
`nil` is a name for nothing.

##### Booleans
`true` and `false`, and that's it.

##### Numbers
Ludus has one number type, 64-bit floating point numbers. You may write numbers either as integers, `7`, `-12`, `4_000_000`; or as decimals, `3.14`, `-12.345`, `0.224`. Underscore separators are optional and ignored, but may not appear at the beginning or end of the number. Integers may not begin with leading `0`s. The negative sign, `-` at the beginning of a number, is part of the number and may not be separated by a space.

This has the upside of not bothering new users with multiple number types (as with everything in computers, numbers are shockingly complicated). It has the downside of all of the IEEE floating-point math hell, which learners won't touch right away but will cause pain down the line.

###### Constants
Ludus defines some (which?) constants, with specific names. `Infinity`, `Pi`, and so on. Note that these are capitalized (are they?--traditionally, they would be ALL_CAPS, which, ::sad face emoji::).

##### Keywords
Keywords evaluate to themselves and only to themselves. They are written as a word preceded by a colon: `:keyword`, `:foo`, `:n00b`. They have the same naming rules as words. They must begin with a colon, and then a letter, and then any character that is not a word-terminator (e.g. whitespace). `:n00b` will be the same value no matter where it's written (and different from every other keyword).

##### Strings
UTF8 strings are set off by double quotes: `"this is a string"`. Strings may be split across lines with a `\` before the newline. (Strings are also complicated!)

###### Unresolved design decision: string inerpolation
* Do we want string interpolation? It's useful in string literals: `"string string {interpolation} string string"`. _Temporary decision: yes, interpolation, but deferred until later._

#### Literal collections
Ludus has several different collections with literal representations in the language: tuples, lists, hashmaps, and sets. All collections are immutable, and are compared by value, not reference. All collections in Ludus can hold values of any type, including other collections. When they are indexed, they are zero-indexed.

##### Tuples
Tuples are the most basic collection type: they group values together. They are written as elements in parentheses, separated by commas, e.g.: `(1, 2, 3)`, `("abc", :foo, 12.4, nil)`. Tuples may be empty, `()`, and they may also have a single value `(:foo)`. Tuples are immutable in a serious way; they are not persistent (they do not have structural sharing but are re-allocated each time). They have a static length.

Tuple literals are also how Ludus represents arguments for function application.

###### Commas
Trailing commas are allowed in all collection literals.

Newlines also serve as separators between items in all collection literals.

Multiple separators (commas, newlines) between items in all collection literals (or multiple trailing commas) are treated as separating a single element: collections are always dense (never sparse). So the following are equivalent:

```
(1, 2, 3)

(1
2
3)

(,,,

1,,
,2



,3
,,
,,)
```

##### Lists
Lists are ordered, indexed, variable-length, persistent collections. They are written between square brackets: `[1, 2, 3]`, `["abc", :foo, 12.4, nil]`. Lists are iterable. For the time being, they share identical semantics to Clojure's persistent vectors.

##### Hashmaps
Hashmaps are unordered key-value pairs: they store values associated with particular keys. Keys must be Ludus keywords; values can be any type. They are written between curly braces, introduced by a hash: `#{:foo 23, :bar 23}`. They have substantially similar semantics to Clojure's persistent maps.

Newlines separate tiems, as with other collections, but both the keyword and the value must appear on the same line (or else you will get an error):

```
#{
  :foo 42
  :bar 23
  :baz 12
}

& but not
#{
  :foo
  42
} &=> error!

& nor
#{:foo, 42} &=> error!

```

###### Hashmap syntatic sugaring
There will be some level of syntactic sugar for dealing with hashmaps. Possibilities include:
* Bound name shorthands: If a name is bound, you can simply write the name and store its value at the symbol corresponding to the name, e.g.: `foo <- 42; #{foo} &=> #{:foo 42}`. _This is definite, see also hashmap pattern matching for the inverse of this._
* Colon placement: the colon can go after the symbol, giving a syntax substantially similar to JS: `#{foo: 42, bar: 23}`. This may or may not be more intuitive to newbie coders, but it will be more readable to anybody with experience in another language. _This is a maybe nice-to-have._

##### Sets
Sets are unordered, unindexed collections of unique items (of any value). They are written between curly braces, introduced by a dollar sign: `${"foo", :bar, 3.14, "foo"} &=> ${"foo", :bar, 3.14}`. Note that `${1, 2, 3}` and `${3, 2, 1}` are equal.

#### Operators
Ludus has very small set of operators: assignment (`<-`), splat (`...`), pipeline (`|>`), and match (`->`). The use of these is described below.

#### Function application
Ludus has a great many built-in functions (especially since there are no basic operators for things like addition!). Functions can be variadic (take different numbers of arguments, with different behaviours based on those numbers). Functions are written by writing the name of the function as a word with the arguments following in a tuple literal: `foo (bar, baz)`. (Note that the space the function name and arguments tuple is idiomatic, but optional: `foo(bar, baz)` is valid Ludus.) To invoke a function with zero arguments, use the empty tuple: `quux ()`.

An attempt to invoke a function (putting a tuple after an expression) with something that is not a function will raise an error. (Hopefully more helpful than the traditional JavaScript headdesk of `undefined (read: nil) is not a function`.)

##### Partial application
Ludus allows for partial application of functions by use of a placeholder: `add (1, _)` returns a function that adds 1 to whatever you give it. So: `add (1, _) (2) &=> 3`. You may only use one placeholder, and all partially applied functions are unary.

##### Pipeline application
Ludus also allows for function pipelines. The last example above could be written `2 |> add (1, _) &=> 3`. Pipelines may be chained: `2 |> add (1, _) |> mult (2, _) |> pow (_, 2) &=> 36`. The pipeline operator takes the left-hand side and applies it as a single argument to the expression on its right-hand side (which must therefore be a unary function). Note that the single argument on the left-hand side of the pipline operator is aligned with single-placeholder partial application.

#### Patterns and assignment
Ludus uses pattern matching from the ground up: all assignments are actually patterns. Patterns, generally, do two things: they match (against a value), and they bind names (in a scope).

##### Basic matching & assignment
The most basic pattern match is assignment, which uses the assignment operator, or left-pointing arrow: `<-`. If the right hand value matches the pattern on the left hand, it binds any names on the left-hand side for the balance of the scope (more on scope later). The most basic match is equality: `true <- true`, `42 <- 42`, `"foo" <- "foo"`, `[1, 2, 3] <- [1, 2, 3]`. Note that these patterns match, but they do not bind any names. If an assignment pattern does not match, Ludus will raise an error (more on errors below).

##### Words
To bind a name, the left hand side of an assignment can be a word: `foo <- true`. The name `foo` is now bound to the value `true`, and anywhere `foo` is used, it will evaluate to `true`. (Note that names may not be re-bound in the same scope; see below.) Words always match against any value. So `names <- ${"Pat", "Chris", "Gabe"}` matches, and binds `names` to the set with names in them (so that `contains? ("Pat", names) &=> true`).

##### Placeholder
The placeholder also always matches, but does not bind a name: `_ <- :whatever` matches, but binds no names. The placeholder is used in conditional forms, as well as in partrial function application.

##### Collections
Ludus also allows you to match against collection literals. This is extremely useful and powerful. They are fairly intuitive.

###### Tuples
Tuples will match if the left and right hand sides are the same length, and that the values at each position match. `(x, y) <- (1, 2)` matches, and binds `x` to `1` and `y` to `2`. `(_, y) <- (1, 2)` matches, ignores the first member of the right-hand tuple, and binds `y` to `2`. `(x, y, z) <- (1, 2)` will not match and raise an error. 

Tuple literals also match against themselves `(1, 2) <- (1, 2)` matches and binds no names.

The empty tuple matches against the empty tuple: `() <- ()`.

###### Unresolved design decision: tuple splats
**This appears as resolved throuhgout, but it, in fact, not.**

_The original text here:_ There is one exception to the length-match requirement: a tuple pattern may also have a "rest pattern" (or splat), which matches any remaining members in the tuple, e.g.: `(x, y, ...more) <- (1, 2, 3, 4)` binds `x` to `1`, `y` to `2`, and `more` to `(3, 4)`. Meanwhile, `(1, _, ...more) <- (1, 2)` matches, and binds `more` to `()` (the empty tuple).

_Deep thoughts:_ Tuples have to be *fast* (for fast function application and pattern matching), and one way to help make them fast is to ensure that they have lengths that are statically known at compile time. Clojure (as a Lisp) has a deep structural homology between lists and arguments. But Elixir, whose pattern matching I'm cribbing from, does not: functions have their arity in their name, e.g. `add/0`, `add/1` and `add/2` are not different arities of the same function, but different functions.

Ludus should have "variadic" functions, where `add () &=> 0`, `add (1) &=> 1`, and `add (1, 2) &=> 3`. But if tuples must have a statically known length (and function application must use a tuple literal!), then we can compile different arities to different functions under the hood: and that makes things much faster.

###### Lists
Lists match identically to tuples, but with square brackets, including splats.

###### Hashmaps
Hashmaps match in a slightly unusual, but highly useful, way. Keywords on the right bind to words on the left. So: `#{foo} <- #{:foo 42}` matches, and binds `foo` to `42`.Hashmap patterns can also include rest patterns, which will bind any key/value pairs that aren't explicitly invoked on the left hand side: `#{foo, ...rest} <- #{:foo 42, :bar 23, :baz 3.14}` binds `rest` to `#{:bar 23, :baz 3.14}`. Keywords and values on the left hand side match for equality but do not bind names, `#{:bar 23, foo} <- #{:foo 42, :bar 23}` matches and binds `foo` to `42`, and does not bind `bar` to anything. Placeholders may be used as the value in a key/value pair to match any value held at a key (i.e. if they key is defined on the hashmap).

#### Splats
**See above for a discussion of tuple splats.**

We've already seen the "rest" pattern. A similar technique can be used to insert all values from a collection into another collection. Consider:

```
numbers <- [1, 2, 3]
new_numbers <- [0, ...numbers]
& new_numbers is [0, 1, 2, 3]

users <- #{
  :Pat "pat@gmail.com"
  :Chris "chris@yahoo.com"
}
new_users <- #{:Ashley "ashley@outlook.com", ...users}
& new_users has entries for :Pat, :Chris, and :Ashley
```

Splats work for all Ludus collections. Splats may only be used within collection types: tuples may be splatted only into tuples; lists may be splatted only into lists; etc. (This is for a number of reasons; the semantics of different collection types are different enough that splats-as-conversions tempt the elder gods.) Conversions between collection types are handled by functions, and not all conversions are possible.

#### Expressions, blocks, scope, and scripts
Ludus is, exclusively, an expression-based language: everything returns a value. (Even assignment!; more on this below.) Expressions are separated by newlines or by semicolons.

```
12
"foo"
:bar
false; true & there are two expressions on this line
add (1, 2, 3)
```

Eech line is evaluated on its own, and returns the value to which it evaluates. Literals (naturally) evaluate to themselves. Function calls are invoked and return their return value. Bound names return the value that is bound to them. Unbound names raise errors (they cannot be evaluated).

##### Blocks
A block is a group of expressions that are evaluated in order, together, which returns the value of the last expression. Blocks are wrapped in curly braces: `{1; 2; 3} &=> 3`. A block is treated as a single expression by code outside it. So, you could write:

```
foo <- {
  "I"
  "am"
  :a
  "block"; "."
  add (1, 2, 3)
}
```

...and `foo` would be bound to `6`.

##### Scope
Each block also introduces its own (lexical) scope. So any bindings introduced in a block are freed once the block is closed. Consider:

```
my_cool_number <- {
  sum <- add (1, 2, 3)
  product <- mult (sum, 2)
  third <- div (product, 3)
  third
} &=> 4
my_cool_number &=> 4
sum &=> error! unbound name
```

`my_cool_number` will now be bound to `4`; `sum`, `product`, and `third` will not be bound below (or above) that block. (Note this contrived example would more concisely be written as a pipeline: `my_cool_number <- add (1, 2, 3) |> mult (_, 2) |> div (_, 3)`).

Each block has access to any enclosing scope(s), up to the script level, and to the prelude.

##### Scripts
Ludus is, at its heart, a scripting language. Each file, called a script, is its own scope. The script is like a block: it returns its last value, and cannot touch anything outside it. So, when you write `foo <- import ("foo.ld")`, `foo` is bound to the return value (last expression) of the script in `foo.ld`. Each script, of course, has access to Ludus's core set of functions, the prelude (whatever is in that!). Scripts do not have access to each other except through what they return.

###### Unresolved design decisions: assignments and bindings
* _What do assignments return?_ One version is that, if there's a match, they simply return the right-hand side. The other version is that they return a special `Nothing` value that never matches against anything in any pattern, ever (and thus will throw an error if one puts a binding as the last line in a block). I'm inclined to say the former, but had originally considered the latter. _Temporary answer: return RHS._
* _Can bindings be shadowed?_ Can a name be bound in an enclosing scope, and then bound in an included scope? Clearly, the interior binding would not affect the binding in its enclosing scope. I am very ambivalent about this. _Temporary answer: yes, shadowing_.

#### Conditional forms
Ludus has three main control flow constructs, called "conditional forms": `if`, `cond`, and `match`. All three are expressions, not statements.

##### `if`
`if` is fairly unique in Ludus, in that it comes with two additional reserved words, `then` and `else`. Also, note that `if` requires both a `then` branch and an `else` branch. (Because it's an expression, it must return something, and that something must be made explicit; no implicit `nil`s.) `if <test_expr> then <then_expr> else <else_expr>`. Note that any of these expressions may be a block, and not a single expression.

Newlines may come after the various expressions, e.g.:

```
if condition
  then do_a_thing ()
  else {
    add (1 2)
    frobulate (foo bar)
  }
```

(Indentations are not significant in Ludus, but are considered good practice for code readability.)

###### Truthy and falsy
`if` evaluates `else_expr` if the value of `test_expr` is `nil` or `false`. Otherwise, it evaluates `then_expr`.

##### `cond`
`cond` is a way of testing multiple conditions without nesting `if` expressions. It is the first example of a clause-based expression (`match` and function bodies are also clause-based.) Consider the example:

```
cond {
  eq (x, 0) -> do_zero_thing () & runs if x is 0
  eq (x, 1) -> do_one_thing () & runs if x is 1
  _ -> { & runs if x is neither 0 nor 1
    report_something ()
    add (1, 2)
    do_default_thing ()
  }
}
```

`cond` is followed by curly braces, but instead of a block of expressions, it is a block of one or more _clauses_. For `cond`, the clause is written `<test_expr> -> <result_expr>`. If `test_expr` evaluates to truthy, `result_expr` is evaluated, and its value returned. No other clauses are evaluated (there is no fallthrough). If no clause's `test_expr` evaluates to truthy, no code is evaluated--and an error is raised. To write a default case, you have a few options. Any literal truthy value will do the trick. Best practice here would be to use either `true` or a descriptive keyword, like `:else` or `:default`. You may also use the reserved word `else`, or the placeholder (`_`, as above).

As with all expressions, you may use a block in either side of a clause (although it's ugly and not recommended to use one on the left-hand side).

`cond` is useful when the conditions involve multiple values, or testing across various domains. But it is rather less useful than `match`, which is the real conditional workhorse of Ludus.

##### `match`
`match` is much the same as `cond`, but uses pattern matching (as assignment, above) to determine which clause to evalute. Consider the example:

```
match do_something () with {
  & matches if `do_something ()` evaluates to 0
  0 -> do_zero_thing ()
  
  & matches on 1
  1 -> do_one_thing ()

  & matches on a 2-tuple whose first member is :ok
  (:ok, value) -> value

  & matches on a 2-tuple whose first member is :error
  (:error, msg) -> {
    print ("I got an error")
    print ("Here's the message", msg)
  }

  & always matches
  _ -> {
    print ("I got neither 0, nor 1, nor a result tuple")
    do_default_thing ()
  }

  & because the previous clause always matches, we will never get here
  2 -> :never_matches
}
```

The formal description here is fairly straightforward: `match <value_expr> with { <clauses> }`. As with `cond`, there must be one or more clauses, which are written `<pattern> -> <result_expr>`. If the pattern matches, the `result_expr` is evaluated--with any names in the pattern bound during evaluation (as in the tuple example clauses above). As with assignment matching, patterns can match against tuples, lists, and hashmaps.

As with `cond`, if no clause matches, an error is raised. Also, as with `cond`, there are multiple ways of writing the default case, to wit: idiomatically, the placeholder (`_`) will match and not bind a name. You may also use the reserved word `else`.

###### Use `else` and `_`
Best practice is to use `else` or `_` for default cases in both `cond` and `match`, since they behave similarly. If you use a literal truthy value to form your default clause in `cond`, that is substantially different behaviour than using a literal value in `match` (which will only match on equality).

###### Unresolved design decisions
* _Unused bound names?_ Do we want to raise an error for unused bound names in the right-hand expression of a `match` clause? A name will always match, and so swallow any clauses below it. Probably binding a name without using it is unintended. _Temporary answer: errors on unused bound names._
    - _Descriptive placeholders?_ You can use a placeholder in multiple places in a pattern, but they all look equivalent. Do we want to allow `_foo` names, which aren't bound but _do_ offer the possibility of a descriptive name. _Temporary answer: yes descriptive placeholders._
* _Unreachable clauses?_ Do we want to raise an error for unreachable clauses, as the last clause above? Again, probably it's unintentional to write unreachable code. _Temporary answer: errors on definitely unreachable clauses._ That said, this is the stupid version of this: we don't do exhaustiveness checking, so you'll only get an error after a clause that always matches.

#### Functions
Ludus is a deeply functional language. Functions are first-class values. They also have a few different syntaxes. All are introduced with the reserved word, `fn`. Functions have a deep affinity with `match`, using an identical clause syntax, with one additional restriction: the left-hand side _must_ be a tuple pattern.

##### Anonymous functions
Anonymous functions are the syntactically simplest form, and can be used inline as arguments to higher-order functions. They consist of the reserved word, `fn`, and then a function clause. A stub and examples:

```
fn (args) -> body
fn (x) -> add (x, 1) & increments x
fn (x, y, z) -> {
  print (x, y, z)
  & sum-of-squares
  add (square (x), square (y), square (z))
}
```

Anonymous functions can be bound to names using a normal assignment operator: `inc <- fn (x) -> add (x, 1)`. That said, in this example, `inc` is still an anonymous function: it has no name.

##### Named functions
You can create a named function by putting its name as a word after `fn` and before the clause:

```
fn foo (bar) -> baz
fn inc (x) -> add (1, x) & increments its argument
```

Named functions bind the name to the function, and also attach that name as metadata for happier debugging. Note that named functions are expressions like anything else, and can be used (for example) in functions passed as arguments to higher-order functions.

Named functions also bind their name inside the body of the function clause, so they can be called recursively. (More on recursion below.)

##### Variadic and documented functions
Functions can contain multiple clauses between braces, like a `match` expression. At the top of the clause block, you may also include docstring comments, which will be used in generated documentation.

```
fn foo {
  &&& A docstring (with _markdown_!).
  &&& Docstrings are optional.
  & a normal comment
  (bar) -> baz
  (bar, quux) -> frobulate ()
}

fn inc {
  &&& Increments a number by 1.
  (x) -> add (1, x)
}
```

In addition, note that the multiple clauses are pattern-matched in precisely the same way as `match` expressions. This has a few consequences:
* If there is no match between the passed argument tuple and the clauses in the function body, an error will be raised.
* A function can have different behaviour not only based on the number of arguments, but also on the literal values in patterns.

Consider:

```
fn div {
  &&& Divides one number by another.
  (_, 0) -> 0
  (x, y) -> {...native code...}
}

fn frobulate {
  &&& Frobulates a bandersnatch.
  ((:ok, value)) -> {...do something with value...}
  ((:error, message)) -> print ("Error! ", message)
}

fn fib {
  &&& Returns the nth Fibonacci number.
  (0) -> 1
  (1) -> 1
  (n) -> add (fib (sub (n, 1)), fib (sub (n, 2)))
}

fn add {
  &&& Adds numbers together.
  () -> 0
  (x) -> x
  (x, y) -> {...native code...}
  & NB: this example may be obsolete (see note on tuple splats)
  (x, y, ...more) -> {
    sum <- add (x, y)
    add (sum, ...more)
  }
}
```

`div` returns `0` if the divisor is `0` (this is Ludus's behaviour, rather than raising an error or returning `Infinity`). Otherwise, it passes the division operation along to the host language.

`frobulate` will raise an error if you pass it anything other than a 2-tuple whose first member is either `:ok` or `:error`.

`fib` is a bog-standard, slow, recursive Fibonacci function.

`add` is a recursive variadic function: it behaves differently depending on how many arguments you give it. With 0 arguments, you get the addition identity: `0`. With 1, you get back the number unchanged. With 2, you add two numbers together in native code. And with three or more, you get a recursive call that sums all the arguments together. (This is not especially efficient, but it's nicely illustrative.)

###### Clauses and documentation
The left-hand side of all function clauses is given in generated documentation. Using good, descriptive names for arguments is a useful practice for future-you, but also for users of your code.

##### Recursion
Following Logo and Scheme's lead, to get looping behaviour, we use recursion. Ludus is optimized such that recursion is fast (lol, that's WIP like whoa). 

Consider a function that calculates the sum of a list of numbers:

```
fn sum {
  &&& Returns the sum of a list of numbers.
  ([]) -> 0
  ([x]) -> x
  ([head, ...tail]) -> add (head, sum (tail))
}
```

Note that pattern matching (in `sum`, and in the `add` example above) makes for a concise and declarative way to handle base cases.

###### Tail-call optimization
To be fast (optimized!), recursion must be managed in a particular way: no recursive call should be made except in tail position: in the last line of the function body, as the lefthand-most call. None of the recursive calls we have yet seen is in tail position. `sum` can be more efficiently written as:

```
fn sum {
  &&& Returns the sum of a list of numbers.
  ([]) -> 0
  ([x]) -> sum (x, 0)
  ([first, ...rest], n) -> {
    running_total <- add (first, n) & broken out for pedagogical purposes
    sum (rest, running_total) & sum appears only as leftmost call on last line
  }
}
```

Note that both the second and third clauses only contain `sum` in the leftmost position of their return expressions. The Ludus interpreter will understand these to be recursive tail-calls and ensure that this runs quickly.

That said, Ludus makes extensive use of higher-order functions to work on collections. Consider a naive (but tail-call recursive) implementation of the `map` function:

```
fn map {
  &&& Takes a list and a unary function, and returns a list whose elements are the result of applying the function to the members of the original list.
  &&& e.g. `map (add (1, _), [0, 1, 2]) &=> [1, 2, 3]`
  (f, source) -> map (f, source, []) & tail-recursive call
  (f, [], result) -> result
  (f, [head, ...tail], result) -> map (f, tail, conj (result, f (tail)))
}
```

This is tail recursive, and thus can be optimized by Ludus to run quickly. Note that getting something into tail-recursive form often involves introducing a "helper" argument.

###### Unresolved design decisions
* _Looping forms._ Is it worth building in looping forms, e.g. Clojure's `loop`/`recur`? Or Logo's `repeat`? Part of this is a pedagogical decision about managing early turtle graphics, e.g. `repeat 4 { forward (50); right (90) }` vs `repeat (4, fn () -> { forward (50); right (90) })`. I think my preference is for the functional version of `repeat`, but I can see an argument for special syntax here. 

As for direct looping, one nice thing about a `loop`/`recur` construct may be that it can enforce tail recursion (which we should not do for functions). That said, we can introduce `recur` as a reserved word which will raise an error if it is not in tail position in a function expression. Nevertheless, consider the following:
```
fn map {
  (f, source) -> loop (source, []) with {
    ([], result) -> result
    ([first, ...rest], result) -> recur (rest, conj (result, f (first)))
  }
}
```
It has a lovely 1-to-1 correspondence with `match`, and need not use a tuple (is that right?--we want this to be homologous to function application). Also, it avoids both creating a fucntion (does it?, or is this just sugar for an anonymous function?) and polluting the function signature with helper arguments. _Temporary decision: yes, `recur` as reserved word in functions; yes, `loop`; no, `repeat`._

Consider also a simplified syntax, on the model of an anonymous function: `loop (<args>) -> <expr>`.

* _Early return._ Do we want a `return` reserved word that will allow for early returns from functions? I believe the `cond` and `match` forms, along with multiple function clauses, actually gets you whatever behaviour you want. But Rust has a `return`, and that may well be helpful for some imperative code. _Temporary decision: for now, no early return._

#### Variables and mutations
So far, everything described here is completely stateless: all literals are immutable, and names cannot even be re-bound. Eventually, something has to change its state. Enter variables and mutations. A variable is name that is bound to something mutable, using the `var` reserved word. Mutations allow that name to have its value changed, using the `mut` reserved word.

```
var a_number <- 12
& a_number is 12

mut a_number <- inc (a_number)
& a_number is now 13
```

References can only be re-bound after the `mut` reserved word. Also, once a reference passes out of scope, it is no longer mutable. So for example:

```
count_up <- {
  var a_counter <- 0
  fn increment_counter () -> mut a_counter <- inc (a_counter)
}

count_up () &=> 1
count_up () &=> 2
count_up () &=> 3

& but nota bene
cant_count <- {
  var another_counter <- 0
}

cant_count &=> 0
mut cant_count <- inc (cant_count) &=> error!
```

#### Closures
Note that in the `count_up` example, `increment_counter` is able to access `a_counter`, which is _not_ accessible outside that block. `increment_counter` _closes over_ its lexical scope, and can continue to access it. (It can also close over things all the way up to the script level. Nothing in the prelude is mutable, so it doesn't matter.) This allows for the very careful and explicit management of mutable state.

#### Keywords and accessing hashmaps
How do you get values out of hashmaps? The keys are keywords. There are two syntactical options, _functional keywords_ and _keyword accessors_:
* Functional keywords. `:foo (bar)` evaluates to the value stored at `:foo` on `bar`. In all of the ways that matter, a keyword at the beginning of an expression can be treated like a function. This is useful in function pipelines or as an argument to a higher-order function, e.g., `bar |> :foo` is equivalent to the above, and `map(:foo, [bar, baz])` will create a new list with the values stored at `:foo` on each list member.
* Keyword accessors. Keywords that are _not_ at the beginning of an expression access the value at that keyword, and these can be chained: `foo :bar :baz` (or, without spaces, `foo:bar:baz`). This pulls `baz` off `bar`, which is itself pulled off `foo`.

In each case, accessing a key that is not defined in a hashmap returns `nil`. There will be function equivalents to key access which will raise errors with undefined key access. The equivalents to the previous examples: `get(bar, :foo)` gets `:foo` on `bar`; or `get(foo, [:bar, :baz])` gets `foo:bar:baz`.

Hashmaps are used extensively to create packages of functions.

Property access on any value that is not a hashmap returns `nil`.

##### Unresolved design decision: namespaces
Unstated here but completely anticipated is that a module/namespace/whatever is just a script which returns a hashmap. Suppose `foo.ld` consists of `#{:inc add(1, _), :dec sub(_, 1)}`. So in `bar.ld` we write `foo <- import ("foo.ld)`. `foo:inc (1) &=> 2`, yay! But you fatfinger a thing, and write `foo:inx (1)`, and you get `nil is not a function`. That's not any better than JavaScript! So perhaps we have a special kind of hashmap, a namespace (`ns`), that has usefully different behaviour: it's exactly like a hashmap, except that if you try to access something on it that doesn't exist, you get an error. In our little example: `inx is not defined in namespace foo`.

That would give us a syntactical form something like:

```
inc <- add(1, x)

dec <- sub(x, 1)

ns Foo {
  &&& a docstring could go here
  inc
  dec
}
```

#### Types and patterns
**This section is very tenative.**

Ludus has a strictly limited number of types, which correspond to the literal values and collections:
* `nil`
* Boolean
* Keyword
* String
* Number
* Tuple
* List
* Hashmap
* Set
* Function

There are no user-defined types. (Really?) None of these types are parametric. So a list is a list is a list.

##### Getting types
There is a core function, `type_of` that returns the type of any Ludus value. The information is returned as a simple keyword: `:nil`, `:boolean`, `:keyword`, `:string`, and so on. So, `type_of (4) &=> :number`, `type_of (nil) &=> :nil`, etc.

##### Using types in patterns
Patterns can match on type, using the `as` reserved word. After any pattern, simply use `as :type`. For example:

```
fn inc (x as :number) -> add(1, x)
inc (4) &=> 5
inc ("foo") &=> error!

fn add_strings_or_numbers {
  (x as :number, y as :number) -> add (x, y)
  (x as :string, y as :string) -> concat (x, y)
}
add_strings_or_numbers (4, 5) &=> 9
add_strings_or_numbers ("foo", "bar") &=> "foobar"
add_strings_or_numbers ("foo", 4) &=> error!
```

This is a simple but quite robust form of type-checking that allows for polymorphic behaviours. It is somewhat verbose, but that discourages overly-ambitious typechecking. The prelude/standard library will be typechecked in this way.

##### Unresolved design decision: named patterns
This one is... interesting. I haven't quite seen it elsewhere (maybe in one of Bob Nystrom's languages?); I believe it's semanticaly very iteresting but may have terrible performance characteristics (especially to the extent that it encourages deeply-nested patterns). But you could use named patterns to describe the shapes of various collections. Perhaps something like `pattern NumberOk <- (:ok, value as :number)`, and then use `NumberOk` as the name for a positive result tuple that can only hold a number, which would come after `as` in a pattern. These would not bind names (although they can have names in their description), but would match or not. This could function like a sort of ad-hoc user-facing type system. _Temporary decision: wait and see; don't add this yet._ In particular, this will 

One possible restriction to avoid deeply-nested patterns is to avoid named patterns at all! No named patterns in the definition of named patterns.

##### Unresolved design decision: guards in patterns
Elixir has a `when` reserved word that allows for refinement in the left-hand side of a pattern. For example, `(x) when is_odd (x) -> {...do something...}` will only match when `x` is odd (when the guard expression evaluates to truthy). (Note that the names have to be bound in the guard expression.) _Temporary decision: wait and see; don't add this yet._

###### Thought: finer-grained "types"
Putting these two together, you could write, for example, `pattern OddNumber <- x as :number when is_odd (x)`. These could get you sophisticated runtime type checking as pattern matching guards. But: this could also go off the rails really quickly and devolve into titchy pattern munging. _Temporary decision: determined by the two previous decisions._ But also: see the next unresolved design decision: guards and named patterns are a robust predicate DSL, where you can tell if a value conforms to a shape that you've named. But it's not a type, in the sense that you can't climb back up from the value to some more general category.

#### Unresolved design decision: polymorphism
I don't believe this is deeply urgent, since if we get some well-designed abstractions (which I think these are!; I am standing on the shoulders of Rich Hickey), polymorphism isn't actually much of a problem. There aren't user-defined types, so there is no need to require user-facing extensions. But we can use the same basic foundation for polymorphism I used in the original JavaScript-hosted Ludus, which allows for user-defined types that can be associated with namespaces to produce module. Again, I want to see how far we can get without module-based (or other) polymorphism. Convention (result tuples) over polymorphism, to abuse the Rails mantra.
 
#### Equality
All equality in Ludus is value-equality--with one exception. Functions are reference-equal (testing for function equality is probably... not a thing you should be doing very often). All atomic and collection values are compared based on value using the `eq` function. So, e.g., `eq (${1, 2, 3}, ${3, 2, 1}, ${2, 3, 1}) &=> true`

#### Events and asynchronicity
**This section needs much more research.**

Asynchronicity is hard no matter how you do it. But the single-threaded JavaScript event loop is likely a good model. (Look to inspiration from Pyret.) I believe it's easy enough to implement with a single reserved word, `defer <time> <expr>`, which bumps a computation to the next tick.

#### Errors
**This section is very tentative.** And involves lots of thinking-through. 
 
As a learner-oriented language, Ludus must have excellent and informative error messages.One lesson from static languages is that it's best to get errors as early as possible in the process, bringing as many runtime errors forward as possible to earlier stages in interpretation.

In addition, it's worth holding onto a basic distinction between errors in business logic and errors in code. Calling a function with the wrong number or type of arguments is not an error a system tolerates; whereas division by zero or not getting the right input from a user should not bring down a system. Result tuples are our friends for the latter (in the absence of parametric static types). The former should, in fact, halt the world.

Pattern matching will driving most of the runtime errors we'll get (call a function with the wrong number of arguments is actually a failure to match the arguments tuple against any of the patterns in the function clauses). Because of that, errors around pattern matching will have to be stellar.

The thought for now: there should be no user-facing error system other than returning error tuples, and maybe `panic!`. Let's see how far we can get before we need to `raise` anything (although obviously that will be a reserved word).

#### Reserved words
In this document so far, here is the complete list of Ludus reserved words.

Here are the reserved words that will definitely be in the language:
`as`, `cond`, `else`, `false`, `fn`, `if`, `match`, `mut`, `nil`, `panic!` or (`panic`), `then`, `true`, `var`, `with`.

Here are those that are tentative or possibly proposed in this document:
`defer`, `loop`, `ns`, `pattern`, `raise`, `recur`, `repeat`, `return`, `when`.

Others that are possible are:
`assert`, `async`, `await`, `catch`, `enum`, `finally`, `mod`, `module`, `try`, `type`, `wait`.