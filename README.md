# ludus-spec
## A draft specification for the Ludus language

### Overview
Ludus is a contemporary translation of Logo. It draws heavily, also, from Lisps: Scheme and Clojure. It is designed from the ground up to be as friendly as possible in syntax, error messages, and use. Its particular characteristics are:
* It is expression-based (mostly).
* It is immutable by default, including persistent data structures.
* It uses pattern-matching extensively.

### Syntax & language base

#### Whitespace
Ludus has minimally significant whitespace. Newlines are the ends of expressions (unless preceded by `\`). The default separator in (nearly) all cases is a space.

#### Comments
Comments are indicated by an ampersand, `&`. The rest of the line is ignored:

```
& this is a comment
& this is also a comment
"This is a string, not a comment"
```

#### Literal atoms
Ludus has several builtin literal types: `nil`, Booleans, numbers, keywords, and strings.

##### `nil`
`nil` is a name for nothing. (There is also `Nothing`, but more on that later.)

##### Booleans
`true` and `false`, and that's it.

##### Numbers
Ludus has one number type, 64-bit floating point numbers. You may write numbers either as integers, `7`, `-12`, `4_000_000`; or as decimals, `3.14`, `-12.345`, `0.224`. Underscore separators are optional, but may not appear at the beginning or end of the number. Integers may not begin with leading `0`s. The negative sign, `-` at the beginning of a number, is part of the number and may not be separated by a space.

##### Keywords
Keywords evaluate to themselves and only themselves. They are written as a word preceded by a colon: `:keyword`, `:foo`, `:n00b`. They have the same rules as words. They must begin with a colon, and then a letter, and then any character that is not a word-terminator (e.g. whitespace). `:n00b` will be the same value no matter where it's written (and different from every other keyword).

##### Strings
UTF8 strings are set off by double quotes: `"this is a string"`. Strings may be split across lines with a `\` before the newline.

#### Literal collections
Ludus has several different collections with literal representations in the language: tuples, lists, hashmaps, and sets. All collections are immutable, and are compared by value, not reference. All collections in Ludus can hold values of any type, including other collections. When they are indexed, they are zero-indexed.

##### Tuples
Tuples are the most basic collection type: they group values together. They are written as elements in parentheses, e.g.: `(1 2 3)`, `("abc" :foo 12.4 nil)`. Tuples may be empty, `()`, and they may also have a single value `(:foo)`. Tuples are immutable in a serious way; they are not persistent. They have a set length. Tuple literals are also how Ludus represents arguments for function application. They are not iterable.

##### Lists
Lists are ordered, indexed, variable-length, persistent collections. They are written between square brackets: `[1 2 3]`, `["abc" :foo 12.4 nil]`. Lists are iterable. For the time being, they share identical semantics to Clojure's persistent vectors.

##### Hashmaps
Hashmaps are key-value pairs: they store values associated with particular keys. Keys must be Ludus keywords; values can be any type. They are written between curly braces, introduced by a hash: `#{:foo 23 :bar 23}`. They have substantially similar semantics to Clojure's persistent maps.

##### Sets
Sets are unordered, unindexed collections of unique items (of any value). They are written between curly braces, introduced by a dollar sign: `${"foo" "bar" "baz"}`.

#### Operators
Ludus has a bare minimum of operators: assignment (`<-`), pipeline (`|>`), and matching (`->`). The use of these is described below.

#### Function application
Ludus has a great many built-in functions (especially since there are no basic operators for things like addition!). Functions can be variadic (take different numbers of arguments, with different behaviours based on those numbers). Functions are written by writing the name of the function with the arguments following in a tuple literal: `foo (bar baz)`. (Note that the space the function name and arguments tuple is idiomatic, but optional: `foo(bar baz)` is valid Ludus.) To invoke a function with zero arguments, use the empty tuple: `quux ()`.

##### Partial application
Ludus allows for partial application of functions by use of a the placeholder: `add (1 _)` returns a function that adds 1 to whatever you give it. So: `add (1 _) (2) => 3`.

##### Pipeline application
Ludus also allows for function pipelines. The last example above could be written `2 |> add (1 _) => 3`. Pipelines may be chained: `2 |> add (1 _) |> mult (2 _) |> pow (_ 2) => 36`. The pipeline operator takes the left-hand side and applies it as a single argument to the expression on its right-hand side (which must therefore be a unary function). Note that the single argument on the left-hand side of the pipline operator is aligned with the single-argument placeholder.

#### Patterns and assignment
Ludus uses pattern matching from the ground up: all assignments are actually patterns. Patterns, generally, do two things: they match (against a value), and they bind names (in a scope).

##### Basic matching
The most basic pattern match is assignment, which uses the assignment operator, or left-pointing arrow: `<-`. If the right hand value matches the pattern on the left hand, it binds any names on the left-hand side for the balance of the scope (more on scope later). The most basic match is equality: `true <- true`, `42 <- 42`, `"foo" <- "foo"`. Note that these patterns match, but they do not bind any names. If an assignment pattern does not match, Ludus will raise an error (see Errors, below).

##### Words
To bind a name, the left hand side of an assignment can be a word: `foo <- true`. The name `foo` is now bound to the value `true`, and anywhere `foo` is used, it will evaluate to `true`. (Note that names may not be re-bound in the same scope; see below.) Words always match against any value. So `names <- ${"Pat" "Chris" "Gabe"}` matches, and binds `names` to the set with names in them (so that `contains? ("Pat" names) => true`).

##### Placeholder
The placeholder also always matches, but does not bind a name: `_ <- :whatever` matches, but binds no names.

##### Collections
Ludus also allows you to match against collection literals. This is extremely useful and powerful. They are fairly intuitive.

###### Tuples
Tuples will match if the left and right hand sides are the same length, and that the values at each position match. `(x y) <- (1 2)` matches, and binds `x` to `1` and `y` to `2`. `(_ y) <- (1 2)` matches, ignores the first member of the right-hand tuple, and binds `y` to `2`. `(x y z) <- (1 2)` will not match and raise an error. 

There is one exception to the length-match requirement: a tuple pattern may also have a "rest pattern," which matches any remaining members, e.g.: `(x y ...more) <- (1 2 3 4)` binds `x` to `1`, `y` to `2`, and `more` to `(3 4)`. Meanwhile, `(1 _ ...more) <- (1 2)` matches, and binds `more` to `()` (the empty tuple).

###### Lists
Lists match nearly identically to tuples, with the exception being that length matching is not a requirement. The right hand side must be of the same length or longer to match, but does not need (but can take) a rest pattern on the left hand side to bind extra members. For example, `[] <- [1 2 3]` matches. `[x y] <- [1 2 3]` matches, and binds `x` to `1` and `y` to `2`. `[x y ...more] <- [1 2 3 4]` binds `x` to `1`, `y` to 2, and `more` to `[3 4]`. Getting all but the first element of a list is easy: `[_ ...rest] <- [1 2 3 4]`. That said, `[_ ...more]` will only match against lists that are one item or longer; the empty list, `[]` will fail to match even against `[_]`, which is a pattern for a single element of any value--but it must exist.

###### Hashmaps
Hashmaps match in a slightly unusual, but highly useful, way. Keywords on the right bind to words on the left. So: `#{foo} <- {:foo 42}` matches, and binds `foo` to `42`.Hashmap patterns can also include rest patterns, which will bind any key/value pairs that aren't explicitly invoked on the left hand side: `#{foo ...rest} <- #{:foo 42 :bar 23 :baz 3.14}` binds `rest` to `#{:bar 23 :baz 3.14}`. Keywords and values on the left hand side match for equality but do not bind names, `#{:bar 23 foo} <- #{:foo 42 :bar 23}` matches and binds `foo` to `42`, and does not bind `bar` to anything. Placeholders may be used as the value in a key/value pair to match any value held at a key (i.e. if they key is defined on the hashmap).

#### Expressions, blocks, scope, and scripts
Ludus is, exclusively, an expression-based language: everything returns a value. (Even assignment!; more on this below.) Expressions are separated by newlines or by semicolons.

```
12
"foo"
:bar
false; true
add (1 2 3)
```

Eech line is evaluated on its own, and returns the value to which it evaluates. Literals (naturally) evaluate to themselves. Functions are invoked and return their return value. Bound names return the value that is bound to them. Unbound names raise errors (they cannot be evaluated).

##### Blocks
A block is a group of expressions that are evaluated in order, together, which returns the value of the last expression. Blocks are wrapped in curly braces: `{1; 2; 3} => 3`. A block is treated as a single expression by code outside it. So, you could write:

```
foo <- {
  "I"
  "am"
  :a
  "block"
  add (1 2 3)
}
```

...and `foo` would be bound to `6`.

##### Scope
Each block also introduces its own (lexical) scope. So any bindings introduced in a block are freed once the block is closed. Consider

```
my_cool_number <- {
  sum <- add (1 2 3)
  product <- mult (sum 2)
  third <- div (product 3)
  third
}
```

`my_cool_number` will now be bound to `4`; `sum`, `product`, and `third` will not be bound below (or above) that block. (Note this contrived example would more concisely be written as a pipeline: `my_cool_number <- add (1 2 3) |> mult (_ 2) |> div (_ 3)`).

Each block has access to its enclosing scope.

##### Scripts
Ludus is, at its heart, a scripting language. Each file, called a script, is its own scope. The script is like a block: it returns its last value, and cannot touch anything outside it. So, when you write `foo <- import ("foo.ld")`, `foo` is bound to the return value (last expression) of the script in `foo.ld`. Each script, of course, has access to Ludus's core set of functions, the prelude (whatever is in that!).

###### Unresolved design decisions
* _What do assignments return?_ One version is that, if there's a match, they simply return the right-hand side. The other version is that they return a special `Nothing` value that never matches against anything in any pattern, ever (and thus will throw an error if one puts a binding as the last line in a block). I'm inclined to say the former, but had originally considered the latter.
* _Can bindings be shadowed?_ Can a name be bound in an enclosing scope, and then bound in an included scope? Clearly, the interior binding would not affect the binding in its enclosing scope. I am very ambivalent about this.

#### Control flow
Ludus has three main control flow constructs: `if`, `cond`, and `match`.

#### Function definition
`fn (bar) -> baz`
`fn foo (bar) -> baz`
```
fn foo {
  "A docstring (with markdown!)"
  (bar) -> baz
  (bar, quux) -> frobulate
}
```

#### References and mutations
So far, everything described here is completely stateless: all literals are immutable, and names cannot even be re-bound. Eventually, something has to change. Enter references and mutations. A reference is name that is bound to something mutable. Mutations allow that name to have its value changed.

```
ref a_number <- 12
& a number is 12
mut a_number <- inc (a_number)
& a_number now 13
```

References can only be re-bound after the `mut` reserved word.