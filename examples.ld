& Ludus by Example

& this is a comment; anything on a line after an ampersand is not evaluated as Ludus code

& Atoms: values that cannot be decomposed

nil & this represents nothing

1 & this is a number
1.2 & this is also a number, with a decimal point
-2 & negative numbers are cool
- 2 & parsing error! The negative sign is part of the number.

& numbers are surprisingly hard and weird; this is all we'll say about them for now.

:foo & this is a keyword
:bar & this is also a keyword
& keywords begin with a colon, and then a letter

true & Boolean true
false & Boolean false

& these are strings:

"the quick brown fox jumped over the lazy dogs"
"strings can\
break across lines with slashes to escape them"

& these are collections: values that combine other values

&& indexed collections associate a value with a position

&&& tuples

(1, 2) & this is a tuple that holds 1 and 2
(1, 2, :foo) & tuples can have mixed values
() & this is an empty tuple

&&& lists

[1, 2] & this is a list that holds 1 and 2
[1, 2, :foo] & lists can have mixed values
[] & this is an empty list

& the difference between lists and tuples is:
&&& tuples are immutable and explicit in the source code
&&& lists are persistent and do not have to be known in the source code
&&& more on this below.

&& keyed collections associate a value with a symbol, which is they key

&&& structs
@{:x 1, :y 2} & this is a struct that stores 1 at :x and 2 at :y
@{} & this is an empty struct

&&& dictionaries

#{:x 1, :y 2} & this is a dictionary that stores 1 at :x and 2 at :y
#{} & this is an empty dictionary

& the difference between structs and dicts is the same as lists and tuples:
&&& structs are immutable and explicit in the source code
&&& dicts are persistent and do not have to be known in the source code
&&& yet more on this below.

&&& sets
${1, 2, 2, 3, :foo} &=> ${1, 2, 3, :foo}; a set throws away any duplicated members

& `let` expressions & matching

& simple naming / let expressions
let foo = 1 & the name `foo` is now bound to 1
foo & evaluates to 1
let foo = 2 & PANIC! names may not be re-bound

& for the rest of this file, we're going to keep re-using names;
& because of that, this file is NOT a valid Ludus script

& pattern matching
let 1 = 1 & the left-hand side of a `let` expression is not a name but a pattern
& the simplest pattern is literal equality: 1 is 1
& bare names match against anything

& you may use pattern matches as guards
let 1 = foo & ensures that `foo` is bound to 1, as above

& a failure to match causes a panic, exiting the Ludus script with an error
let 2 = 1 & PANIC! cannot match 2 with 1

& the placeholder, written `_`, matches against things and throw the things away
let _ = (1, 2, 3)
let _ = false & the placeholder doesn't bind anything and can be used multiple times

& let expressions return their right-hand side
let foo = let bar = 2 & `foo` and `bar` are now both bound to 2.
let foo = let _ = 2 & `foo` is now bound to 2

& patterns are how you get values out of tuples
let (x, y) = (1, 2) & `x` is now 1; `y` is now 2

& patterns can also get things out of lists, dicts, and structs
let [x, y] = [1, 2] & same as above
let #{:foo x, :bar y} = #{:foo 1, :bar 2} & note names and keys for the dict aren't necessarily the same
let @{:foo x, :bar y} = @{:foo 1, :bar 2} & identical behaviour

& empty collections match against empty collections
let () = ()
let [] = []
let #{} = #{}
let @{} = @{}

&&& but: sets cannot be matched against

& patterns can be nested
let (x, [y, z]) = (1, [2, 3]) & `y` is now 2, `z` is now 3

& there's a shorthand for dicts and structs
let #{x, y} = #{:x 1, :y 2} & `x` is 1, `y` is 2: if the keys and names are the same (less the initial colon), you don't need the keyword
let foo = @{x, y} & the shorthand goes the `other` way, `foo` is now @{:x 1, :y 2}

& control flow

& if/then/else: a conditional expression
if true then :true else :false & :true; `if {condition expression} then {if truthy} else {if falsy}`
if true then :true & PANIC! expected else---if expressions must have both a `then` and an `else` branch*
if false then :something else :nothing & :nothing
if nil then :something else :nothing & also nothing
if () then :something else :nothing & :something

& only two values are falsy in Ludus: `nil` and false``; everything else is truthy
& * this is a consequence of Ludus's expression-based nature: every expression has to evaluate to something
& without an `else` there'd be nothing to evaluate to

&&& the `if let` pattern: consider the following
let pt2d = (1, 2)
let pt3d = (1, 2, 3)

if let (x, y) = pt2d & line breaks are okay after the condition expression
   then :two_dee
   else :three_dee &=> :two_dee

if let (x, y) = pt3d then :two_dee else :three_dee &=> :three_dee

& match errors in an `if`'s condition expression cause it to evaluate as falsy, rather than raising a panic
& the names from a `let` in a condition expression are bound in the `then` branch, but not the `else` branch

& cond: escape nested if/then/else
let maybe_1 = false
let maybe_2 = nil
let maybe_3 = true
cond {
     & {test expression} -> {result}; this is a `cond clause`
     maybe_1 -> :one & test expression/left hand side is evaluated; if truthy, the expression returns the right hand side
     maybe_2 -> :two & same truthy/falsy rules as `if`
     maybe_3 -> :three
     & if none of the LHS's evaluate to truthy, `cond` raises a panic
     & possible fallthroughs
     true -> :oops & any truthy value, could be :whatever or 12 or "foo"
     else -> :oops & else works here
     _ -> :oops & so does a placeholder
} &=> :three

& match: the best conditional form ever
let might_fail_fail = (:error, "message")

match might_fail_fail with { & match {test expression} with { {clauses} }
      & {pattern} -> {result}; this is a `match clause`
      (:ok, value) -> value & if the pattern/LHS matches, bind the names and evaluate the result
      (:error, msg) -> :oops
      & like cond, we get a panic of nothing matches
      & we have similar fallthroughs
      else -> :something_else & `else`
      _ -> :something else & a placeholder
} &=> :oops

let might_fail_pass = (:ok, 42)
match might_fail_pass with {
      (:ok, value) -> value & note `value` is bound in the RHS of this clause
      (:error, msg) -> :oops
} &=> 42

& `match` expressions are extremely powerful, and therefore also complicated. More below.

& conditional forms are all expressions
let my_result_if = if might_fail
    then :error
    else :ok
let my_result_match = match might_fail with {
    (:ok, value) -> value
    (:error, _) -> :default
}

& functions

& function application: calling functions
add (2, 3) &=> 5
add (2, 3, 4) &=> 9
first ([1, 2, 3]) &=> 1
first ("string") &=> "s"

& functions are called by writing their name, followed by a tuple with the arguments
& some functions (like `add` and `first`) are built-in

& functions are successfully called when argument tuple has a match in the function declaration
add (:one, :two) & PANIC! could not match (:one, two) with ...; you can only `add` numbers

&&& partial application: defer function application
let add_1 = add (1, _) & fn add <partially applied>
add_1 (2) &=> 3

& a placeholder in the calling tuple defers that argument till later
& you may use only one placeholder in a calling tuple
let add_3 = add (_, _, 3) & PANIC! too many placeholders

& function declaration: writing functions

&&& simplest form anonymous function
let add_1 = fn (x) -> add (1, x) & anonymous function; not very helpful
& fn {function clause}
& function clause = {argument tuple pattern} -> expression
& argument tuple pattern = a pattern to match the argument tuple used when calling
add_1 (2) &=> 3 & same application

let only_foo = fn (:foo) -> :foo & the LHS of a function clause is a normal pattern
only_foo (:foo) &=> :foo
only_foo (:bar) & PANIC! could not match (:foo) with (:bar) in `only_foo`

& function calls can be nested, of course
& the evaluation starts on the inside and works outward,
& in other words, the tuple following the function name is evaluated, and then sent to the function
only_foo (only_foo (only_foo (:foo))) &=> :foo

&&& named function
fn add_1 (x) -> add (1, x) & fn add_1; `add_1` is now
& fn {name} {function clause}
add_1 (2)

&&& complex functions: named functions can have multiple function clauses
fn funny_add {
   (0) -> 1
   (1) -> 2
   (2) -> 3
   (3) -> 5
   (4) -> 8
   (n) -> add (n, 23)
   (x, y) -> add (x, y) & argument tuples do not need to be the same length
} &=> fn funny_add

funny_add (1) &=> 2
funny_add (-2) &=> 21
funny_add (:oops) & PANIC! no match--note that this panic is raised by `add` in the last clause
funny_add (1, 2) &=> 3

& Getting things into and out of collections, redux

&&& lists
let my_list = [1, 2, 3]

first (my_list) &=> 1
rest (my_list) &=? [2, 3]
second (my_list) & => 2
nth (0, my_list) &=> 1; nth is 0-indexed
nth (6, my_list) &=> nil; with any index beyond the size of the list, `nth` returns `nil`

let longer_list = conj (my_list, 4) &=> [1, 2, 3, 4]; `conj` is short for conjoin
my_list &=> [1, 2, 3]; `conj` does NOT alter the original list

let silly_list = assoc (my_list, 0, :one) &=> [:one, 2, 3]
my_list &=> [1, 2, 3]; like `conj`, `assoc` does not alter a list
& `assoc` is short for associate

&&& splats
[4, ...my_list] &=> [4, 1, 2, 3]; an ellipsis "unfolds" a list into a new list
[...my_list, 4] &=> [1, 2, 3, 4]; splats can be anywhere inside a list

&&& tuples
& tuples have far less freedom than lists
let my_tup = (1, 2, 3)
first (my_tup) &=> 1
rest (my_tup) & PANIC! functions that return lists when used on lists panic when you use them on tuples
nth (0, my_tup) &=> 1
nth (6, my_tup) & PANIC! no element at index 6 in (1, 2, 3); nth/tuple access ALWAYS returns a value

conj ((1, 2, 3), 4) & PANIC! same deal as `rest`
& in particular, tuples must have known lengths and values in the source code

(1, 2, ...my_tup) & PANIC! you cannot splat into a tuple; you need to spell everything out, however:

[...my_tup, 4] &=> [1, 2, 3, 4]; you can splat a tuple INTO a list if you want to do anything list-y with it

&&& dicts
let my_dict = #{:foo 42, :bar 23, :baz "wowee"}

:foo (my_dict) &=> 42; keywords can be called like functions, with a single dict or struct argument
my_dict :foo &=> 42; keywords after a name pull the value out of the dict/struct
my_dict :quux &=> nil; if a dict has nothing stored at a particular key, accessing that key returns nil

assoc (my_dict, :quux, "nonsense!") &=> #{:foo 42, :bar 23, :baz "wowee", :quux "nonsense!"}
my_dict &=> #{:foo 42, :bar 23, :baz "wowee"}; assoc also does not modify dicts

#{:a 1, ...my_dict} &=> #{:a 1, :foo 42, :bar 23, :baz "wowee"}; dicts can also splat

&&& structs
& structs are to dicts as tuples are to lists: stricter, and static

let my_struct = @{:foo 42, :bar 23, :baz "wowee"}
:foo (my_struct) &=> 42 & same access patterns as a dict
my_struct :foo &=> 42
my_struct :quux & PANIC! no member :quux on @{...}

assoc (my_struct, :quux, "nonsense!") & PANIC! cannot assoc onto a struct

#{...my_struct, :foo 22} &=> #{:bar 23, :baz "wowee", :foo 22}; but splats work into dicts

&&& a note on persistent vs. immutable data structures
& All data in Ludus is immutable in the sense that no function lets you change any data, ever.
& However, lists and dicts are "persistent" in the sense that they let you create new data, based on old data.
& They have magic that makes this fast, so you're not copying all the data around.
& Simply immutable data structures don't have this property.
& Also, immutable data structures will cause panics if you try to get something out of them that isn't there.
