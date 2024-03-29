# ludus-spec
## A draft specification for the Ludus language

Last revised 8 April 2022.

### Overview
Ludus is a contemporary translation of Logo. It is a rather free translation. It draws heavily, also, from Lisps: Scheme and Clojure. As well as Elixir (which itself draws from Clojure, but has a more "modern" syntax). It is designed from the ground up to be as friendly as possible in syntax, error messages, and use. Its particular characteristics are:
* It is expression-based.
* It relies on immutability, including only persistent or immutable data structures.
* It uses pattern-matching extensively.

#### The spirit of Ludus
"Ludus" is Roger Caillois's name for rule-bound play. To Logo, Ludus adds an emphasis on strictness. This is because the stricter the language, the better the errors you can generate. And better errors mean better learning. Also, because Ludus is meant for learners, a complex type system is unnecessary overhead--although a lightweight but strict type system is a boon. Ludus is meant to be as strict as you can plausibly be in a dynamic language.

### Hello, world
Ludus is deeply expression based. The interpreter just evaluates expressions and returns the last one in a script (or block). Scripts thus return their last expression to stdout:

```
& hello.ld
"Hello, world!"

$> ludus hello.ld
"Hello, world!"
```

Or, you can write to stdout, but `print` returns `:ok`:
```
& hello.ld
print ("Hello, world!")

$> ludus hello.ld
Hello, world!
:ok
```

### Syntax & language base

#### Whitespace (status: done)
Ludus has minimally significant whitespace. Newlines are the ends of expressions (with a few exceptions, where Ludus allows a single newline for better readability). Newlines can also be used as separators in collection literals (see below).

Indentation (tabs or spaces) are not, however, significant.

#### Comments (status: done)
Comments are indicated by an ampersand, `&`. The rest of the line is ignored:

```
& this is a comment
& this is also a comment
"This is a string, not a comment" & comments can terminate lines
```

##### Docstring comments (status: to do)
In function expressions (see below), there's a special kind of comment that provides documentation for the function. It begins with three ampersands: `&&& this is a docstring comment`. Docstring comments can contain markdown that will be formatted in automatically generated documentation.

#### Literal atoms (status: done, unless otherwise noted)
Ludus has several builtin literal types: `nil`, Booleans, numbers, keywords, and strings. (More on the type system below.)

##### `nil`
`nil` is a name for nothing.

##### Booleans
`true` and `false`, and that's it.

##### Numbers
Ludus has one number type, 64-bit floating point numbers. You may write numbers either as integers, `7`, `-12`, `4_000_000`; or as decimals, `3.14`, `-12.345`, `0.224`. Underscore separators are optional and ignored, but may not appear at the beginning or end of the number. Integers may not begin with leading `0`s. The negative sign, `-` at the beginning of a number, is part of the number and may not be separated by a space.

This has the upside of not bothering new users with multiple number types (as with everything in computers, numbers are shockingly complicated). It has the downside of all of the IEEE floating-point math hell, which learners won't touch right away but will cause pain down the line (floats come for us all).

###### Wait, but really?
A single number type is sometimes understood to be a major design flaw of JavaScript. Clojure uses its host language number types: Java's `long` and `double` on the JVM, and JS's floats-everywhere in ClojureScript. Ludus may want to differentiate between ints and floats. Maybe? Why? What are the arguments here?

###### Constants (status: to do)
Ludus defines some (which?) constants, with specific names. `Infinity`, `Pi`, and so on. Note that these are capitalized (are they?--traditionally, they would be ALL_CAPS, which, ::sad face emoji::). These aren't defined at the language level, they're just named values in the prelude.

##### Keywords
Keywords evaluate to themselves and only to themselves. They are written as a word preceded by a colon: `:keyword`, `:foo`, `:n00b`. They have the same naming rules as words. They must begin with a colon, and then a letter, and then any character that is not a word-terminator (e.g. whitespace). `:n00b` will be the same value no matter where it's written (and different from every other keyword).

###### Terminators
Characters that terminate words: here's the set of terminator characters (as Clojure characters): `\: \; \newline \space \tab \{ \} \( \) \[ \] \$ \# \- \< \& \, \|`.

TODO: Update this list: no \<, \|, add \>. What else?

##### Strings
UTF8 strings are set off by double quotes: `"this is a string"`. Normally, they may only be one line. But, strings may be split across lines with a `\` before the newline. (Strings are also complicated!)

###### Multi-line strings
Should we allow multi-line strings? There are maybe reasons not to, like avoiding multi-line tokens.

###### String interpolation (status: to do)
* Do we want string interpolation? (We do.) It's useful in string literals: `"string string {interpolation} string string"`. _Temporary decision: yes, interpolation, but deferred until later._ NB: Rust has recently added support for a light duty (safer) version of this, where what's interpolated isn't any arbitrary expression but only bound names. I think this may be a way to go.

#### Literal collections (status: done, unless otherwise noted)
Ludus has several different collections with literal representations in the language: tuples, lists, hashmaps, and sets. All collections are immutable, and are compared by value, not reference. All collections in Ludus can hold values of any type, including other collections. When they are indexed, they are zero-indexed.

##### Tuples
Tuples are the most basic collection type: they group values together. They are written as elements in parentheses, separated by commas, e.g.: `(1, 2, 3)`, `("abc", :foo, 12.4, nil)`. Tuples may be empty, `()`, and they may also have a single value `(:foo)`. Tuples are immutable in a serious way; they are not persistent (they do not have structural sharing but are re-allocated each time). They have a static length.

Tuple literals are also how Ludus represents arguments for function application.

(In fact, function application is a special kind of general pattern matching.)

###### Resolved design decision: Tuples, splats, variadic functions, and the stack
Tuples cannot be splatted into. This means that every tuple has a statically known length at compile time. And that also means that every function call has an explicit arity at compile time. Moreover, while there is an (easy, often-used) way to write variadic functions, every function has a collection of explicit, statically-known arities at compile time. This means we can catch "wrong number of arguments" errors at compile time. It means we can optimize pattern matching. And it also means that tuples, when we get to a VM, can be stored on the stack rather than on the heap (making them fast!).

It's worth tracing the design space here, because the three languages that are sources of inspiration here do things differently:

Logo is the weirdest among these. Logo has no variadic functions; every function has a known arity. In addition, because Logo was set on getting rid of Lisp's parentheses for kids, function calls don't have parentheses: they're just lists of arguments separated by spaces after a function, e.g. `FLOWER 100 50`. But that means the _parser_ has to know the arities of functions to decide what arguments belong to which function call. Among other decisions, this is one that makes Logo extremely weird compared to modern languages. Since the target audience of Ludus isn't young kids, and because there's a widely-culturally-known convention of code to use parentheses for function calls, we don't want to do this.

Clojure, being a Lisp, articulates a profound homology between lists and function arguments. And: lists in Lisps are not only literals but also have variable lengths. That means variadic functions with an indefinite number of arguments are easy. In Clojure, you write it `(defn foo [x y z &more] ... )`, and `more` is bound to a list (well, vector) of any arguments more than 3 you give to `foo`. Call these "rest" arguments. Ludus does not have these. This is for technical reasons (outlined above), but also for aesthetic ones. The idea is that Ludus is meant to be very, very explicit; its design is meant to make explicitness easy.

So Ludus follows Elixir here, it's easy to have variadic functions. Or, to be precise, it's easy to have multiple functions with the same name with different arities (all of which are explicit). In Elixir, the function name includes the arity, e.g. `foo/2` and `foo/3` are different functions. Using the function name without the arity suffix is sugar, since the number of arguments applied to the function is known at compile time. This is the strategy Ludus will take, although Ludus will elevate this from sugar to language. So inside of Ludus, you'll never know that `foo/2` and `foo/3` are implemented as different functions; there will be no way to differentiate between function arities in this way. But! To make Ludus function calls as fast as possible (even with the treewalk interpreter in Clojure), we will use this strategy under the hood. 

And yet, there are more than a few core language features that feel like they want indefinitely-variadic behavior: `string`, `print`, etc. Can we call these "special forms" and be done with it? (Answer: yes. And there are a few more special forms than that, even.)

###### Commas
Commas separate expressions in all collection literals. 

Trailing commas are allowed in all collection literals.

Newlines also serve as separators between items in all collection literals.

Multiple separators (commas, newlines) between items in all collection literals (or multiple trailing commas) are treated as separating a single element: collections are always dense (never sparse). So the following are equivalent:

```
(1, 2, 3) & the below all resolve to this

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

Newlines separate items, as with other collections, but both the keyword and the value must appear on the same line (or else you will get an error):

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

###### Hashmap syntactic sugaring (status: done)
There will be some level of syntactic sugar for dealing with hashmaps. Possibilities include:
* Bound name shorthands (yes): If a name is bound, you can simply write the name and store its value at the symbol corresponding to the name, e.g.: `foo = 42; #{foo} &=> #{:foo 42}`. _This is definite, see also hashmap pattern matching for the inverse of this._
* Colon placement (no): the colon can go after the symbol, giving a syntax substantially similar to JS: `#{foo: 42, bar: 23}`. This may or may not be more intuitive to newbie coders, but it will be more readable to anybody with experience in another language. _This is a maybe nice-to-have._
* Things other than keywords as keys (maybe?): Clojure allows you to use arbitrary values as keys in maps. Do we want that behaviour? Or do we stick with keywords? (Parsing might be an issue if we allow `{expr expr}`).

###### Unresolved not-quite-design-decision: Naming hashmaps
One of the nice points of "20 Things" is that Logo is not just a language, but also (among other things!) a vocabulary for talking about things. A hashmap is a nice, explicit term for what this collection is (it has other names). But it is jargony. Other possibilities for Ludus: object, dictionary, map, hash. We should resolve this. Partly because the syntax here, beginning with `#{`, is meant to be a visual cue to "hash": now that we have hashtags, this looks obviously like a hash-thing.

##### Sets
Sets are unordered, unindexed collections of unique items (of any value). They are written between curly braces, introduced by a dollar sign: `${"foo", :bar, 3.14, "foo"} &=> ${"foo", :bar, 3.14}`. Note that `${1, 2, 3}` and `${3, 2, 1}` are equal. (The dollar sign looks like an S, for set.)

###### Unresolved design decision: Set syntax
Conceptually, I think sets are more like lists than like hashmaps. Perhaps they ought to be written with square brackets instead of braces, e.g. `$[1, 2, 3]`.

##### Structs
Structs are nearly identical to hashmaps in their literal construction, using `@{}` rather than `#{}`. They are identical as to the methods of getting things out of them. However, instead of returning `nil` for members that aren't there, trying to access a member that isn't there will cause a panic. 

Structs are also fixed in size, and use full copy-on-write semantics for any modification (as opposed to the hashmap's persistence). They are the data structure behind namespaces and, if we add them, data types.

#### Operators (status: still in design)
Ludus has very small set of operators: assignment (`=`), splat (`...`), pipeline (TBD), and match (`->`). The use of these is described below.

#### Function application (status: basic functionality done)
Ludus has a great many built-in functions (especially since there are no basic operators for things like addition!). Functions can be variadic (take different numbers of arguments, with different behaviours based on those numbers). Functions are written by writing the name of the function as a word with the arguments following in a tuple literal: `foo (bar, baz)`. (Note that the space the function name and arguments tuple is idiomatic, but optional: `foo(bar, baz)` is valid Ludus.) To invoke a function with zero arguments, use the empty tuple: `quux ()`.

A function name without a tuple following is treated as a reference to that function.

An attempt to invoke a function (putting a tuple after an expression) with something that is not a function will raise an error. (Hopefully with a message that is more helpful than the traditional JavaScript headdesk of `undefined (read: nil) is not a function`.)

##### Where functions may be called (status: explanation)
Functions may only be called directly in a "synthetic" expression: an expressiont that starts with a word or a keyword. Arbitrary expressions may not be called. For example, the following is allowed:

```
let foo = fn () -> :foo
foo ()
```

But the following is illegal:
```
{fn () -> :foo} () &=> Error: expected end of expression

```


##### Partial application (status: complete)
Ludus allows for partial application of functions by use of a placeholder: `add (1, _)` returns a function that adds 1 to whatever you give it. So: `add (1, _) (2) &=> 3`. You may only use one placeholder in a tuple applied to a function. As a consequence, all partially applied functions are unary.

##### Pipeline application (status: implemented, but in design review)
Ludus also allows for function pipelines. Function piplines are, for now, introduced by the keyword `do`. The pipeline operator is (for now) `>`:

```
do 2 > add (1, _) &=> 3

do 2 > add (1, _) > mult (2, _) > pow (_, 2) &=> 36

do fn (_) -> :foo > nil &=> :foo
```

The pipeline operator takes the left-hand side and applies it as a single argument to the expression on its right-hand side (which must therefore be a unary function). Note that pipelined functions are unary; this pairs nicely (and intentionally) with partially-applied unary functions. (See below, re: a bind operator.)

#### Patterns and assignment (status: in progress, basic functionality complete)
Ludus uses pattern matching from the ground up: all assignments are actually patterns. Patterns, generally, do two things: they match (against a value), and they bind names (in a scope).

##### Basic matching & assignment (status: done)
The most basic pattern match is assignment, which is introduced by the keyword `let` and uses the assignment operator: `=`. If the right hand value matches the pattern on the left hand, it binds any names on the left-hand side for the balance of the scope (more on scope later). The most basic match is equality: `let true = true`, `let 42 = 42`, `let "foo" = "foo"`, `let [1, 2, 3] = [1, 2, 3]`. Note that these patterns match, but they do not bind any names. If an assignment pattern does not match, Ludus will raise an error (more on errors below). (NB: List patterns are not yet complete.)

###### New design decision: `let` (status: solid)
I had an idea like it might be possible and desirable to do without `let` (as Elixir does), but I can tell as I embark on the parser that parsing will be made much easier if we include `let` as a keyword that preceds assignment. (That way, the parser doesn't have to do nearly indefinite lookahead to determine whether you're dealing with a collection literal or a collection pattern.)

That said, it actually improves code readability to have all assignments set off by `let`s. So.

##### Words (status: done)
To bind a name, the left hand side of an assignment can be a word: `let foo = true`. The name `foo` is now bound to the value `true`, and anywhere `foo` is used, it will evaluate to `true`. (Note that names may not be re-bound in the same scope; see below.) Words always match against any value. So `let names = ${"Pat", "Chris", "Gabe"}` matches, and binds `names` to the set with names in them (so that `contains? ("Pat", names) &=> true`).

##### Placeholder (status: done)
The placeholder also always matches, but does not bind a name: `let _ = :whatever` matches, but binds no names. The placeholder is used in conditional forms, as well as in partial function application.

##### Collections
Ludus also allows you to match against collection literals. This is extremely useful and powerful. They are fairly intuitive. Patterns may be nested.

###### Tuples (status: done)
Tuples will match if the left and right hand sides are the same length, and that the values at each position match. `let (x, y) = (1, 2)` matches, and binds `x` to `1` and `y` to `2`. `let (_, y) = (1, 2)` matches, ignores the first member of the right-hand tuple, and binds `y` to `2`. `let (x, y, z) = (1, 2)` will not match and raise an error. 

Tuple literals also match against themselves: `let (1, 2) = (1, 2)` matches and binds no names.

The empty tuple matches against the empty tuple: `let () = ()`.

###### Lists (status: not yet done)
Lists match in similar ways to tuples. The difference is that they allow matching with a splat, which matches any remaining members that aren't explicitly in the pattern:

```
let [] = []
let [x] = [1] & x is 1
let [x, y] = [1, 2] & x is 1; y is 2
let [x] = [1, 2] & panic! no match; lengths must match
& to match remaining members, use a splat
let [head, ...tail] = [1, 2, 3, 4] & head is 1, tail is [2, 3, 4]
let [head, ..] = [1, 2, 3, 4] & head is 1; .. is shorthand for ..._
```

###### Hashmaps (status: not yet done)
Hashmaps match in a slightly unusual, but highly useful, way. Keywords on the right bind to words on the left. So: `let #{foo} = #{:foo 42}` matches, and binds `foo` to `42`. Hashmap patterns can also include rest patterns, which will bind any key/value pairs that aren't explicitly invoked on the left hand side: `let #{foo, ...rest} = #{:foo 42, :bar 23, :baz 3.14}` binds `rest` to `#{:bar 23, :baz 3.14}`. Placeholders may be used as the value in a key/value pair to match any value held at a key (i.e. if they key is defined on the hashmap).

###### Other collections? (status: not yet decided)
Do we want matches on sets? Would that even make sense? They're both unordered and un-keyed.

Do we want matches on strcuts? Yes. (Not yet done.)

#### Splats in expressions (status: not yet done)
**See above for a discussion of tuple splats.**

We've already seen the "rest" pattern. A similar technique can be used to insert all values from a collection into another collection. Consider:

```
let numbers = [1, 2, 3]
let new_numbers = [0, ...numbers]
& new_numbers is [0, 1, 2, 3]

let users = #{
  :Pat "pat@gmail.com"
  :Chris "chris@yahoo.com"
}
let new_users = #{:Ashley "ashley@outlook.com", ...users}
& new_users has entries for :Pat, :Chris, and :Ashley

& however, this creates a new hashmap, more idiomatic (and faster) would be:
let new_users_update = update (users, :Ashley, "ashley@outlook.com")

& either way, `users` is untouched
users &=> #{:Pat "pat@gmail.com", :Chris "chris@yahoo.com"}
```

Splats work for persistent (variable-size) Ludus collections. Splats may only be used within collection types: sets may be splatted only into sets; lists may be splatted only into lists; etc. (This is for a number of reasons; the semantics of different collection types are different enough that splats-as-type-casts tempt the elder gods.) Conversions between collection types are handled by functions, and not all conversions are possible.

#### Expressions, blocks, scope, and scripts (status: done)
Ludus is, exclusively, an expression-based language: everything returns a value. (Even assignment!; more on this below.) Expressions are separated by newlines or by semicolons.

```
12
"foo"
:bar
false; true & there are two expressions on this line
add (2, 4)
```

Each line is evaluated on its own, and returns the value to which it evaluates. Literals (naturally) evaluate to themselves. Function calls are invoked and return their return value. Bound names return the value that is bound to them. Unbound names raise errors (they cannot be evaluated).

##### Blocks
A block is a group of expressions that are evaluated in order, together, which returns the value of the last expression. Blocks are wrapped in curly braces: `{1; 2; 3} &=> 3`. A block is treated as a single expression by code outside it. So, you could write:

```
let foo = {
  "I"
  "am"
  :a
  "block"; "."
  sum ([1, 2, 3])
}
```

...and `foo` would be bound to `6`.

##### Scope
Each block also introduces its own (lexical) scope. So any bindings introduced in a block are freed once the block is closed. Consider:

```
let my_uncool_number = 4
let my_cool_number = {
  let sum = add (2, my_uncool_number) &=>6; has access to the encolsing scope
  let product = mult (sum, 2)
  let third = div (product, 3)
  third
} &=> 4
my_cool_number &=> 4
sum &=> error! unbound name
```

`my_cool_number` will now be bound to `4`; `sum`, `product`, and `third` will not be bound below (or above) that block. (Note this contrived example would more concisely and idiomatically be written as a pipeline: `let my_cool_number = do my_uncool_number > add (_, 2) > mult (_, 2) > div (_, 3)`).

Each block has access to any enclosing scope(s), up to the script level, and then to the prelude.

##### Scripts (status: done)
Ludus is, at its heart, a scripting language. Each file, called a script, is its own scope. The script is like a block: it returns its last value, and cannot touch anything outside it. So, when you write `let foo = import ("foo.ld")`, `foo` is bound to the return value (last expression) of the script in `foo.ld`. Each script, of course, has access to Ludus's core set of functions, the prelude (whatever is in that!). Scripts do not have access to each other except through what they return.

###### Unresolved design decisions: assignments and bindings
* _What do assignments return?_ One version is that, if there's a match, they simply return the right-hand side. The other version is that they return a special `Nothing` value that never matches against anything in any pattern, ever (and thus will throw an error if one puts a binding as the last line in a block). I'm inclined to say the former, but had originally considered the latter. _Answer: return RHS. Confidence: high._
* _Can bindings be shadowed?_ Can a name be bound in an enclosing scope, and then bound in an included scope? Clearly, the interior binding would not affect the binding in its enclosing scope. I am very ambivalent about this. _Answer: yes, shadowing. Confidence: high._
* _REPL vs. script._ The REPL will be largely useless if you cannot re-bind a name in a session. But: that then means that scripts and REPLs have different rules, and you can't copy between them. This is rather a conundrum. So, a few possibilities:
  - Just embrace the different rules. This is what OCaml does.
  - Allow name-rebinding, to make scripts follow REPL rules. I don't like this, as it brings mutation into the picture unmanaged. And part of the Ludus way is to embrace as much strictness and explicitness as you can get in a dynamic language.
  - Use a different model of interactivity: no Ludus REPL. We have a version of this: the notebook. This, right now, is my preferred suggestion. (You could use something like Quokka [for JS] or ClojureSublimed in a code editor.) That said, a notebook is *substantially* more complex as a piece of software (even with plugins for a code editor) than a REPL.
  - Current answer: For now, Ludus is just a script, not a REPL. Punt on this design decision.

#### Conditional forms
Ludus has three main control flow constructs, called "conditional forms": `if`, `cond`, and `match`. All three are expressions, not statements.

##### `if` (status: done)
`if` comes with two additional reserved words, `then` and `else`. `if` is binary: it decides which expression to evaluate based on a condition expression. Note that `if` requires both a `then` branch and an `else` branch. (Because it's an expression, it must return something, and that something must be made explicit; no implicit `nil`s.) `if <test_expr> then <then_expr> else <else_expr>`. Note that any of these expressions may be a block, and not a single expression.

Single newlines may come after the test and then expressions, e.g.:

```
if condition
  then do_a_thing ()
  else {
    add (1, 2)
    frobulate (foo, bar)
  }
```

(Indentations are not significant in Ludus, but are considered good practice for code readability.)

###### Truthy and falsy (status: done)
`if` evaluates `else_expr` if the value of `test_expr` is `nil` or `false`. Otherwise, it evaluates `then_expr`. (Do we want any other values to be falsy? E.g., `()`. Note that in any event, `0` and `""` are truthy, unlike in JS/PHP.)

###### `if let` patterns: bindings, scopes, and missed matches (status: not yet done)
The `test_expr` in an `if` expression creates a new scope that the result expressions inherit. In addition, any `let` bindings in a `test_expr`, if there is no match, do not panic, but instead evaluate to falsy.

Thus:

```
if let nil = optional
  then handle_nil ()
  else {
    something_with_something (optional)
  }

if let (:ok, result) = might_fail
  then do_something ()
  else handle_failure ()
```

Using a block as `test_expr` allows for multiple `let` expressions whose mismatches are swallowed:

```
if { let foo = bar (); let baz = quux (foo) }
  then do_something (foo, baz)
  else handle_failure ()
```

##### `cond` (status: done)
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

`cond` is followed by curly braces, but instead of a block of expressions, it is a block of one or more _clauses_. For `cond`, the clause is written `<test_expr> -> <result_expr>`. If `test_expr` evaluates to truthy, `result_expr` is evaluated, and its value returned. No other clauses are evaluated (there is no fallthrough). If no clause's `test_expr` evaluates to truthy, no code is evaluated--and an error is raised. To write a default case, you have a few options. Any literal truthy value will do the trick. But there are two syntactically-supported best practices: use the reserved word `else`, or the placeholder (`_`, as above).

As with all expressions, you may use a block in either side of a clause (although it's ugly and not recommended to use one on the left-hand side).

`cond` is useful when the conditions involve multiple values, or testing across various domains. But it is rather less useful than `match`, which is the real conditional workhorse of Ludus.

##### `match` (status: done; but the still-limited patterns affect this)
`match` is much the same as `cond`, but uses pattern matching (as assignment, above) to determine which clause to evalute. This collection of pattern matching clauses is called a "`with` block," which comes after `match` and other constructs with identical semantics: `loop`, named functions, etc. Consider the example:

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
  & should this be a parser error?
  2 -> :never_matches
}
```

The formal description here is fairly straightforward: `match <value_expr> with { <clauses> }`. As with `cond`, there must be one or more clauses, which are written `<pattern> -> <result_expr>`. If the pattern matches, the `result_expr` is evaluated--with any names in the pattern bound during evaluation (as in the tuple example clauses above). As with assignment matching, patterns can match against tuples, lists, and hashmaps.

As with `cond`, if no clause matches, an error is raised. Also, as with `cond`, there are multiple ways of writing the default case, to wit: idiomatically, the placeholder (`_`) will match and not bind a name. You may also use the reserved word `else`. 

###### Use `else` and `_` (Status: done.)
Best practice is to use `else` or `_` for default cases in both `cond` and `match`, since they behave similarly in all conditional forms. If you use a literal truthy value to form your default clause in `cond`, that is substantially different behaviour than using a literal value in `match` (which will only match on equality).

###### Unresolved design decisions
* _Unused bound names?_ Do we want to raise an error for unused bound names in the right-hand expression of a `match` clause? A name will always match, and so swallow any clauses below it. Probably binding a name without using it is unintended. _Temporary answer: ???._
    - _Descriptive placeholders?_ You can use a placeholder in multiple places in a pattern, but they all look equivalent. Do we want to allow `_foo` names, which aren't bound but _do_ offer the possibility of a descriptive name. _Answer: yes descriptive placeholders. Status: done._
* _Unreachable clauses?_ Do we want to raise an error for unreachable clauses, as the last clause above? Again, probably it's unintentional to write unreachable code. _Answer: it's complicated. See the document nses, structs, and types._
* _`with`?_ The `with` here is actually not necessary. It gives the syntax some ventilation. But in particular, the idea is that we'd like to distinguish between a normal expression block and a set of pattern-matching clauses. So putting `with` before a block could in principle always mean it's pattern-matching. That means we'd want, for consistency's sake, to have `with` in function definitions with multiple clauses, as well as `loop` and `gen` forms. `cond` is... its own thing. I reckon consistency isn't actually in reach. _Answer: in fact, it is necessary, for parsing (to separate the expression and the clause in a simple match expression)._
* Allowing multiple patterns in the LHS of a match clause?, e.g. `0 | 1 -> ... & matches on 0 or 1`. _Temporary answer: this is desirable, I think, but for a later iteration._

#### Functions
Ludus is a deeply functional language. Functions are first-class values. They also have a few different syntactical forms. All are introduced with the reserved word, `fn`. Functions have a deep affinity with `match`, using an identical clause syntax, with one additional restriction: the left-hand side _must_ be a tuple pattern.

##### Anonymous functions (status: done)
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

Anonymous functions can be bound to names using a normal assignment operator: `let inc = fn (x) -> add (x, 1)`. That said, in this example, `inc` is still an anonymous function: it has no name.

Anonymous functions may have only one clause.

##### Named functions (status: done)
You can create a named function by putting its name as a word after `fn` and before the clause:

```
fn foo (bar) -> baz
fn inc (x) -> add (1, x) & increments its argument
```

Named functions bind the name to the function, and also attach that name as metadata for happier debugging. Note that named functions are expressions like anything else, and can be used (for example) in functions passed as arguments to higher-order functions.

Named functions also bind their name inside the body of the function clause, so they can be called recursively. (More on recursion below.)

##### Variadic and documented functions (status: variadic functions are done; documented functions are not)
Functions can also contain multiple clauses, identically to a `match` expression. At the top of the clause block, you may also include docstring comments, which will be used in generated documentation.

Also, in all function clauses, patterns must have a left-hand side that is a tuple pattern. Anything else will raise a syntax error.

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

(Design query: Perhaps instead of a special comment, a docstring is just a string?)

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
  (n) -> add (
    fib (sub (n, 1)) 
    fib (sub (n, 2)))
}

fn add {
  &&& Adds numbers together.
  () -> 0
  (x as Number) -> x
  (x as List) -> reduce (add, x)
  (x, y) -> {...native code...}
}
```

`div` returns `0` if the divisor is `0` (this is Ludus's behaviour, rather than raising an error or returning `Infinity`). Otherwise, it passes the division operation along to the host language.

`frobulate` will raise an error if you pass it anything other than a 2-tuple whose first member is either `:ok` or `:error`.

`fib` is a bog-standard, slow, recursive Fibonacci function.

`add` is a recursive variadic function: it behaves differently depending on how many arguments you give it, and what type they are. With 0 arguments, you get the addition identity: `0`. With 1 that is a number, you get back the number unchanged. With 1 that is a list, you get back the sum of numbers in that list. With 2, you add two numbers together in native code.

###### Clauses and documentation (status: not yet done)
The left-hand side of all function clauses is given in generated documentation. Using good, descriptive names for arguments is a useful practice for future-you, but also for users of your code.

##### Recursion (status: recursion works)
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

###### Tail-call optimization (status: not yet done)
To be fast (optimized!), recursion must be managed in a particular way: no recursive call should be made except in tail position: in the last line of the function body, as the lefthand-most call. None of the recursive calls we have yet seen is in tail position. `sum` can be more efficiently written as:

```
fn sum {
  &&& Returns the sum of a list of numbers.
  ([]) -> 0
  ([x]) -> x
  ([first, ...rest], n) -> {
    let running_total = add (first, n) & broken out for pedagogical purposes
    sum (rest, running_total) & sum appears only as leftmost call on last line
  }
}
```

Note that the third clause contains `sum` in the leftmost position of its return expression. The Ludus interpreter will understand it to be a recursive tail-call and ensure that it runs quickly.

That said, Ludus makes extensive use of higher-order functions to work on collections. Consider a naive (but tail-call recursive) implementation of the `map` function:

```
fn map {
  &&& Takes a list and a unary function, and returns a list whose elements are the result of applying the function to the members of the original list.
  &&& e.g. `map (add (1, _), [0, 1, 2]) &=> [1, 2, 3]`
  (f, source) -> map (f, source, []) & tail-recursive call, but not optimized--note different arities
  (f, [], result) -> result
  (f, [head, ...tail], result) -> map (f, tail, conj (result, f (tail)))
}
```

This is tail recursive, and thus can be optimized by Ludus to run quickly. Note that getting something into tail-recursive form often involves introducing a "helper" argument.

###### Unresolved design decisions
* _Looping forms._ Is it worth building in looping forms, e.g. Clojure's `loop`/`recur`? Or Logo's `repeat`? Part of this is a pedagogical decision about managing early turtle graphics, e.g. `repeat 4 { forward (50); right (90) }` vs `repeat (4, fn () -> { forward (50); right (90) })`. I think my preference is for the functional version of `repeat`, but I can see an argument for special syntax here. (Or rather, I flip-flop a lot on this.)

As for direct looping, one nice thing about a `loop`/`recur` construct may be that it can enforce tail recursion (which we should not do for functions). That said, we can introduce `recur` as a reserved word which will raise an error if it is not in tail position in a function expression. Nevertheless, consider the following:
```
fn map {
  (f, source) -> loop (source, []) with {
    ([], result) -> result
    ([first, ...rest], result) -> recur (rest, conj (result, f (first)))
  }
}
```
It has a lovely 1-to-1 correspondence with `match`, and also closely resembles functions. Also, it avoids both creating a function (does it?, or is this just sugar for an anonymous function?) and polluting the function signature with helper arguments. _Answer: yes `loop` and `repeat`. `recur` is a reserved word that can only belong in a `loop`._

Simplified loops may be written like `match` expressions: `loop (foo) with (bar) -> baz`.

* _Early return._ Do we want a `return` reserved word that will allow for early returns from functions? I believe the `cond` and `match` forms, along with multiple function clauses, actually gets you whatever behaviour you want. But Rust has a `return`, and that may well be helpful for some imperative-style code. _Temporary decision: for now, no early return._

#### Variables and mutations (status: still in design--see memory.md)
So far, everything described here is completely stateless: all literals are immutable, and names cannot even be re-bound. Eventually, something has to change its state. Enter variables and mutations. A variable is name that is bound to something mutable, using the `var` reserved word. Mutations allow that name to have its value changed, using the `mut` reserved word.

```
var a_number = 12
& a_number is 12

mut a_number = inc (a_number)
& a_number is now 13
```

References can only be re-bound after the `mut` reserved word. Also, once a reference passes out of scope, it is no longer mutable. So for example:

```
let count_up = {
  var a_counter = 0
  fn increment_counter () -> mut a_counter = inc (a_counter)
}

count_up () &=> 1
count_up () &=> 2
count_up () &=> 3

& but nota bene
let cant_count = {
  var another_counter = 0
  another_counter
}

cant_count &=> 0
mut cant_count = inc (cant_count) &=> error!
```

Note: the `count_up` example here may well be illegal: to avoid reference cycles and to get on with a reference-counting system, mutable variables may only be mutated in the scope in which they are defined, not in child scopes. This may render them fully obsolete in the language. Closures allow for reference cycles. The alternative I've imagined is a ref/swap/deref system where refs may not hold functions or other refs.

##### `var`s must be simple names
The left hand side of a `var` match must be a simple name, not a destructuring pattern match.

#### Closures (status: in design, see memory.md)
Note that in the `count_up` example, `increment_counter` is able to access `a_counter`, which is _not_ accessible outside that block. `increment_counter` _closes over_ its lexical scope, and can continue to access it. (It can also close over things all the way up to the script level. Nothing in the prelude is mutable, so it doesn't matter.) This allows for the very careful and explicit management of mutable state.

#### Keywords and accessing hashmaps & structs (status: almost done)
How do you get values out of hashmaps or structs? The keys are keywords. There are two syntactical options, _functional keywords_ and _keyword accessors_:
* Functional keywords. `:foo (bar)` evaluates to the value stored at `:foo` on `bar`. In all of the ways that matter, a keyword at the beginning of an expression can be treated like a function. This is useful in function pipelines or as an argument to a higher-order function, e.g., `do bar > :foo` is equivalent to the above, and `map(:foo, [bar, baz])` will create a new list with the values stored at `:foo` on each list member. (Status: done, with one corner case: when passed a placeholder, they return `nil`: `:foo (_) &=> nil`. This should not be the case; but `(_)` is probably not kosher.)
* Keyword accessors. Keywords that are _not_ at the beginning of an expression access the value at that keyword, and these can be chained: `foo :bar :baz` (or, without spaces, `foo:bar:baz`). This pulls `baz` off `bar`, which is itself pulled off `foo`. (Status: done.)

In each case, accessing a key that is not defined in a hashmap returns `nil`, and accessing a key that it not defined in a struct will cause a panic. There will be function equivalents to key access which will raise errors with undefined key access. The equivalents to the previous examples: `get(bar, :foo)` gets `:foo` on `bar`; or `get(foo, [:bar, :baz])` gets `foo:bar:baz`.

Property access on any value that is not a hashmap or a struct returns `nil`.

##### Unresolved design decision: namespaces
Unstated here but completely anticipated is that a module/namespace/whatever is just a script which returns a hashmap. Suppose `foo.ld` consists of `@{:inc add(1, _), :dec sub(_, 1)}`. So in `bar.ld` we write `foo = import ("foo.ld)`. `foo:inc (1) &=> 2`, yay! But you fatfinger a thing, and write `foo :inx (1)`, and you get `nil is not a function`. That's not any better than JavaScript! So perhaps we have a special kind of hashmap, a namespace (`ns`), that has usefully different behaviour: it's exactly like a hashmap, except that if you try to access something on it that doesn't exist, you get an error. In our little example: `inx is not defined in namespace Foo`.

That would give us a syntactical form something like:

```
let inc = add(1, _)

let dec = sub(_, 1)

ns Foo {
  &&& a docstring could go here
  inc
  dec
}
```
One additional nicety, here. Namespaces will be statically known at compile-time: they may only have bound names as their members. What's the one-line delimiter: , or ;?

#### Types and patterns
**Status: early design days. See nses_structs_types.md.**

##### Using types in patterns
Patterns can match on type, using the `as` reserved word. After any pattern, simply use `as :type`. For example:

```
fn inc (x as Number) -> add(1, x)
inc (4) &=> 5
inc ("foo") &=> error!

fn add_strings_or_numbers {
  (x as Number, y as Number) -> add (x, y)
  (x as String, y as String) -> concat (x, y)
}
add_strings_or_numbers (4, 5) &=> 9
add_strings_or_numbers ("foo", "bar") &=> "foobar"
add_strings_or_numbers ("foo", 4) &=> error!
```

This is a simple but quite robust form of type-checking that allows for polymorphic behaviours. It is somewhat verbose, but that discourages overly-ambitious typechecking. The prelude/standard library will be typechecked in this way.

##### Guards in patterns (status: in design)
Elixir has a `when` reserved word that allows for refinement in the left-hand side of a pattern. For example, `(x) when is_odd (x) -> {...do something...}` will only match when `x` is odd (when the guard expression evaluates to truthy). (Note that the names have to be bound in the guard expression.) _Answer: add this, but in a later iteration._ 

On Elixir's guards: https://hexdocs.pm/elixir/patterns-and-guards.html#guards. Note that Elixir's strategy ensures that guards never have side effects.

#### Unresolved design decision: polymorphism
**Status: see nses_structs_types.md.**
 
#### Equality (status: done, `eq` is already in the prelude.)
All equality in Ludus is value-equality--with one exception. Functions are reference-equal (testing for function equality is probably... not a thing you should be doing very often). All atomic and collection values are compared based on value using the `eq` function. So, e.g., `eq (${1, 2, 3}, ${3, 2, 1}, ${2, 3, 1}) &=> true`.

#### Events and asynchronicity
**Status: This section needs much more research.**

~~Asynchronicity is hard no matter how you do it. But the single-threaded JavaScript event loop is likely a good model. (Also, look to inspiration from Pyret.) I believe it's easy enough to implement with a single reserved word, `defer <expr>`, which bumps a computation to the next tick, and perhaps `wait <time> <expr>`.~~

This is superseded by [the actor model](./concurrency.md).

#### Errors (status: in progress)
**This section is uneven.** 

As a learner-oriented language, Ludus must have excellent and informative error messages. One lesson from static languages is that it's best to get errors as early as possible in the process, bringing as many runtime errors forward as possible to earlier stages in compilation/interpretation. (Status: writing a good parser is hard, but I'm trying.)

In addition, it's worth holding onto a basic distinction between errors in business logic and errors in code. Calling a function with the wrong number or type of arguments is not an error a system tolerates; whereas division by zero or not getting the right input from a user should not bring down a system. A result type is our friend for the latter (either result tuples or a dedicated type). The former should, in fact, halt the world.

Pattern matching will be driving most of the runtime errors we'll get (call a function with the wrong number of arguments is actually a failure to match the arguments tuple against any of the patterns in the function clauses). Because of that, errors around pattern matching will have to be stellar.

The thought for now: there should be no user-facing error system other than returning error types/tuples, and `panic!`. Let's see how far we can get before we need something more sophisticated. (Status: `panic!` exists and does indeed halt the world; yet to add: any information at all along with a panic. Also, result tuples are not the thing; data types are.)

This is "crash only" error semantics. Which is *very* far away from Scheme (with resumable errors), but I've never myself grokked resumable errors. This is close to Rust/Go: you have results and panics, and that's more or less it. It's also not far from the Beam (Elixir/Erlang) model, where if something bad happens, you just crash (and get restarted by a supervisor, but we're not there).

#### Static analysis (status: a nice fantasy)
Following from commitments to good & early errors, Ludus should do aggressive static analysis to discover errors early. We do it when we can, for the most common use cases. It will be possible to frustrate static analysis by doing things in obscurantist ways (which effectively involve crossing the function boundary), but if you stay on the static-analysis happy path, you'll get something pretty robust. So, for example, I think we can get (for things that might normally be dynamic):
* Function arity checking.
* Namespace member access.
* Mutation out-of-scope.
* Unbound names.
* Attempted mutation of non-`var` bindings.
* Re-binding a bound name.

#### Reserved words (status: done-ish; they're trivial to add but other design elements touch this)
In this document so far, here is the complete list of Ludus reserved words.

Here are the reserved words that will definitely be in the language:
`as`, `cond`, `else`, `false`, `fn`, `if`, `import`, `match`, `mut`, `nil`, `then`, `true`, `var`, `with`, `loop`, `ns`, `recur`, `repeat`, `when`, `yield`.

Here are those that are tentative or possibly proposed in this document or related documents: 
`defer`, `data`, `module`.

Others that are possible are:
`assert`, `async`, `await`, `catch`, `data`, `enum`, `finally`, `mod`, `try`, `type`, `wait`, `pattern`, `raise`, `return`, `gen`, `yield`.

#### Some nice-to-haves
* Matching multiple clauses at once, as in Elixir's `with` construct (this is syntactic sugar for nested `match` expressions). (Status: superseded by a proposed `if`/`let`) pattern, in which any names bound in the test expression of an `if` are available in the `then` expression, and any errors dump you to the `else` expression (with no names bound).
* Should there be a function composition/piping operator? My sense is that it's better to simply use the pipeline operator and be explicit rather than using pointfree anything. So: `fn myfn (x) -> do x > f > g > h` is better than `let myfn = f | g | h` or `let myfn = h . g . f`. Pointfree style is not, generally, idiomatic in Ludus. But: consider transducers, which we'll use extensively. Transducers want function composition.
  - F#, in addition to the pipeline operator, has forward and backward function composition: `f >> g >> h` and `h << g << f`, respectively. Since Ludus doesn't have `<` and `>` as comparison operators, it could simply use these, instead of the doubled ones.
  - Consider the pipeline operator. F# and Elixir use `|>`.
  - Ludus may want to have syntax sugar for binding its result type. Haskell uses `>>=`, but that's super obscure. I'm thinking `|>`. Alternately, we could use `>` as pipeline and `>>` as bind, using F#'s function composition operators.
  - Effectively, we need to get this right, but also, this is (or can be) ultimately sugar for `let myfn = comp ([h, g, f])`. So.
* Generators & iterators (this could be syntactic sugar!, but will hopefully eventually be optimized), e.g. [not actually legal with new scoping rules]:
```
let counter_to_3 = {
  var current = 0

  fn next () -> {
    let out = current
    mut current = inc (current)
    if gt (current, 3)
      then (:done, nil)
      else (:value, out)
  }

  #{next}
} &=> #{:next fn<next>}

counter_to_3:next () &=> (:value, 0)
counter_to_3:next () &=> (:value, 1)
counter_to_3:next () &=> (:value, 2)
counter_to_3:next () &=> (:value, 3)
counter_to_3:next () &=> (:done, nil)
counter_to_3:next () &=> (:done, nil)

```

This could be rewritten as:

```
let conter_to_3 = gen (0) with { 
  (current) -> {
    yield current
    if gt (current, 3)
      then :done
      else recur (inc (current))
  }
}
```

This introduces the `yield` reserved word, to be used in a `gen` expression that evaluates to a generator (or iterator, or sequence). So you could get fairly concise/elegant versions of some other things:

```
fn seq with {
  (h as Hashmap) -> seq (list (h))
  (s as Set) -> seq (list (s))
  (s as String) -> seq (list (s))
  (l as List) -> gen (l) with {
    ([]) -> nil
    ([first, ...rest]) -> {
      yield first
      recur (rest)
    }
  }
}

fn range with {
  (end as Number) -> range (0, end, 1)
  (start as Number, end as Number) -> range (start, end, 1) 
  (start as Number 
    end as Number 
    step as Number) -> gen (start) with (current) -> {
      yield current
      if gte (current, end)
        then nil
        else recur (add (current, step))
    }
}
```

Generators may well be a later nice-to-have, but I suspect the protocol (dead simple, cribbed largely from JS) will be pretty core, and need to be established pretty early. (Status: not yet begun, for a later iteration.)

##### Protocols & conventions in the language (Status: likely superseded by real types)
Following on the convention here of `(:value, x)`/`(:done, y)`, I am thinking about the conventions that ought to be baked into the language at a syntactic level. So, this is not about introducing a "protocol" construct. Following Elixir's lead, keywords and tuples (which can be usefully matched against) are great ways of doing this. So:

* Iterator/generator tuples: `(:value, value)` and `(:done, value)`
* Result types: `(:ok, result)` and `(:error, info)`. Perhaps the way to do this is to introduce a `=>` or `|>` operator (pronounced bind?--see above on the pipeline operators), which is like `>`, but automagically unpacks an `:ok` and short-circuits when an error is returned. Or an `expect` reserved word, like in Rust, where `expect (:ok, result)` evaluates to `result`, and `expect (:error, info)` panics, printing `info`. (But this could also just be a function, and if it can be just a function, make it just a function. But also, it should be called `expect!` or `unwrap!`) Anyway, you could also have `unwrap_or`, which takes a default value instead of panicking. But: the short-circuiting of monadic bind is deeply useful. (Status: avoiding monads.)
* Maybe types are probably not actually necessary, and certainly not worth including syntactic sugar for. That said, probably the bind operator should short-circuit on `nil` as well as an error result?
* Stopping reduction is done by convention with a tuple: `(:stop, result)` stops the reduction and returns the result.

#### Special forms
There are functions that will very likely want to have special behaviour: truly variadic, and also short-circuiting, to wit:
* Core conditional functions: `eq`, `and`, `or`. These are important because we want these both to be indefinitely-variadic as well as short-circuit on the first relevant argument. This means their execution model is fundamentally different.
* Some mathematical functions, e.g. `add`, `mult`, etc., which are usefully truly variadic.
* Status: `eq` and mathematical functions will be variadic from the get-go, and the basics are already in the prelude. `and` and `or`, to do their short-circuiting, must actually be special forms, hard-written into the interpreter.

#### Errors and error handling
Error handling is so, so very important to Ludus. I'm mostly cribbing from other sources here (see especially https://github.com/apple/swift/blob/swift-5.5-RELEASE/docs/ErrorHandlingRationale.rst). But there are a few types of errors, and it's worth being cognizant of them:
* Lexical & syntax errors: when a programmer types something that's nonsense. These can be detected statically and should be raised during the scanning phase. Execution doesn't even start and should be reported.
  * Lexical & syntax errors include everything that can be deduced statically: nonsense input of all kinds, function invocations with incorrect arity, unbound name access, `recur` outside of `loop` or `gen` or not in tail position, attempts to access undefined members of namespaces.
  * This set should be gradually increased to cover as much as possible. For example, incorrect namespace access can be detected statically at compile-time, but will require some fancy-footing to do so. That fancy-footing is a high-priority usability goal.
* Logic errors: when a programmer types syntactically correct nonsense, for example invoking a function with incorrect arity or incorrect types. Some of these can be statically checked (function arity), some of them not (argument types). Also, every fallthrough error--`cond` and `match` and so on--is also a logic error. As is an assignment that does not match. If these can be detected statically, don't start and report. If they can't (e.g. argument types) then the program crashes.
  * Logic errors include: match failures, attempts to invoke things that aren't functions as functions.
* Domain errors: when the program does something that may fail, but should not crash the program, e.g. reading from a file that isn't there. These should be modeled using a result type, e.g. either `(:ok, value)` or `(:error, message)`. Pattern matching makes these easy to work with `match may_fail () with ...`. But sometimes you want error propagation. The question, from a design perspective, is how to handle that.
* With result tuples and unrecoverable crashes, we're close to Rust's error model. Rust bakes the result model into the language, and offers two useful models for constructs that are worth considering for Ludus:
  * `try <expr>`, or error propagation: The expression after `try` must return an error tuple (if not, panic!). If it gets an `:ok`, it unwraps that value and returns it. If it gets an `:error`, it immediately returns that error tuple, short-circuiting evaluation of the rest of the block. This allows for propagation, but it would be the only early return/control flow magic in the entirety of Ludus (except `yield`?--but that is a different matter, since it's sugar). For that reason, I don't love it. (And yet, it may well prove very, very useful.)
  * `expect <expr>`, or crash-on-error: The expression after `expect` must return an error tuple. If it gets an `:ok`, it unwraps the value and returns it. If it gets an `:error`, it panics with the second member of the tuple. This promotes a result tuple into a runtime error. (But this could be a function!)
  * Consider also a convention, which is that functions come in two versions, safe and dangerous: `read_file` and `read_file!`. The former returns a result tuple; the latter returns a bare value and panics on failure. (And is written `fn read_file! (path) -> expect read_file (path)`.)
    * This convention should be imposed by static analysis with a linter, but with a dynamic language, might not want to be a syntax error.
* Should it be possible to "demote" a lexical, syntax, or logic error to something like a result? In practice, this may be useful (if only very rarely used). Consider:
  * `handle <expr>`: The expression after `handle` may panic. If it doesn't, just return the value of the expression, `value`, in a result tuple: `(:ok, value)`. If it does, return `(:error, message)` (with `nil` as the message for a bare panic).
  * I suspect that `handle`ing panics will mostly be useful for things like writing a REPL, but should be avoided if not omitted from the language.
* A deep thought, related to error handling and also name binding behavior: perhaps a REPL really is the wrong model. The notebook/script model may well be more interesting. Particularly to the extent that non-recoverable panics and statically bound names both really militate against the REPL, but work perfectly well with the notebook version. (And, since we're thinking transitional objects here: a notebook/file in an editor is something learners will be comfortable with, where an interactive REPL prompt is actually *not* something most will be comfortable with.)
* A note regarding the above: `if let` also helps tame some error handling. The test expression in an `if` doesn't swallow all panics, only those that come from a `let` expression failing to match. This way, `match` expressions don't proliferate. Especially when you're trying to match on multiple values and stuffing them into a tuple feels unnatural, this lets you avoid nested `match` expressions.

#### Imports (status: basic functionality.)
Originally, I had been thinking of imports as being on the model of Node's `require`: a function that took a string (path to a file), and returned the value of evaluating the script in the file. That's dead simple! But also makes a number of things we want to do much, much more complicated. For example, we want imports to be statically available at compile time, so that we can, say, blow up very early on accessing missing members of namespaces (instead of a runtime error).

That suggests we want a special import construct: `import "foo.ld" as Foo`. This looks like a statement, but like a `let`, this simply evaluates to the return value of `foo.ld`. But also--and here's the thing we like--the way the parser is coming together, this lets us allow an `import` only in the script context. It cannot be in a block or in a function. (Shall we enforce ordering? Or is that too precious?)

In addition, since Ludus has no provision for shared global state, there's execution of scripts that can be conditional on anything. (A script, of course, can contain conditional logic that might make its evaluation indeterminate--say, branching on a random number or the date--but it will _not_ take a different path depending on _what any other script does_. This isn't quite referential transparency, but it should be enough to allow for robust caching and static analysis, even in a dynamic language.

Finally, as a possible nice shortcut, if a script, `quux.ld`, returns a namespace, `ns Quux { foo, bar, baz }`, then you can `import "quux.ld"` and if automagically binds that namespace to `Quux` in your script. This may or may not be advisable; it's not so much extra typing to write `as Quux`. Binding names should probably always be explicit?

#### Testing (status: a nice fantasy)
From Rust and Zig, a good idea: put tests in the same file. `test {label} expr`. Doesn't run during execution (is totally ignored), but there'll be a test mode of some kind (`ludus test script.ld`). Tests won't be added to the AST during execution and so can go after an expression that's the return value of a script.

### TODO
Things to clean up in this document:

* As it goes on, this gets far away from the descriptive tone I was hoping for. Rework this further to show less of my work and get far more declarative.
* Add a moment on forms that must go in the script vs. other contexts: `import`, `data`, `ns`, etc. must all go in the script context to allow static analysis.
* Remove `var`s, replace them with `ref`s. (See memory.md, but that doesn't actually spell out `ref` syntax or semantics, really.)

