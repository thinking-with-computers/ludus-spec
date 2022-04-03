# On namespaces, structured data, and types

### Structured data
It occurs to me that namespaces as I was imagining them are actually a kind of structured data. It seems useful to have a data type (a `struct` in many languages) that is fully immutable (not persistent)--and also that causes a panic when accessing a field that doesn't exist. A namespace, then, could be structured data, possibly with additional niceties. But which additional niceties actually can only be figured out once we know what a Ludus struct might look like.

One easy possibility, to make it reasonably clear what's going on semantically (allocated on the stack, not the heap; no persistence) is to call this thing a "named tuple" (cribbing from Python), with syntax like `@(...)`. Another possibility, which I think makes more sense in Ludus, is to use another kind of curly-brace syntax, since tuples and lists (maybe arrays, if we do a linked list thing) are ordered collections; hashmaps and sets--and structured data--are unordered. For now, let's go with `@{}`. Stack/heap semantics should be abstracted away, and order dependence is a user-facing concern.

```
let baz = "quux"

let foo = @{
	:bar 42
	baz & note the bound-name shorthand
}

foo :bar &=> 42
foo :baz &=> "quux"
foo :foo &=> panic!: "No key :foo in named tuple @(:bar 42, :baz "quux")."

```

This seems reasonable to me as a place to start, anyway. (These also resemble Elixir's keyed lists.)

#### Awkward things
How will we destructure a named tuple? Tuples don't have splats. Should named tuples have splats? Because named tuples aren't used for function application, the optimizations around them are perhaps less necessary. One option would be to have a splat _without_ binding a name: `let @{a, b, ...} = @{:a 1, :b 2, :c 3}`. That seems wise, since the idea here is that this data ought to travel together, so much so that it's on the stack. And the idea, ultimately, is that splats are ways of dissecting data. Don't do it? Don't do it.

### Namespaces
So then a namespace could be sugar for a named tuple. The following is equivalent to the above (less capitalization):

```
ns Foo {
	:bar 42
	:baz "quux"
}

Foo :foo &=> panic!: ":foo not found in namespace Foo."

```

It has the added property that a namespace knows what its name is.

Note that a named tuple is as type-agnostic as any other collection type in Ludus.

Ludus will also do a best-guess static check to make sure that users don't access invalid fields in a named tuple, but of course such checks don't go across function boundaries.

#### Awkward things
How will we destructure a namespace? In my initial formulation, I gave namespaces curly braces. So you'd want to destructuring with braces. But a named tuple has `@()`. Maybe we want parens? I've updated it above.

# Datatypes
Another possibly very enriching data structure in Ludus has its dynamic iteration cribbed from Pyret:

```
data Llist {
	Empty
	Cons (first, rest as Llist)
}

& List, Empty, and Cons are now all in scope.
& `List :Empty` and `List :Cons` are also available


let mylist = Cons (1, Cons (2, Cons (3, Empty)))

& toy implementation
fn reduce (list, f, acc) -> match list as Llist {
	Empty -> acc
	Cons (first, rest) -> reduce (rest, f, f (acc, rest))
}

```

This would allow for actual result types instead of result-tuples-by-convention:

```
data Result {
	Ok (value)
	Error (info)
}

fn may_fail () -> if gte (random (), 0.5)
	then Ok (:ok)
	else Error (:failed)

let my_result = may_fail ()

match my_result as Result {
	Ok _ -> print ("Huzzah!")
	Error _ -> print ("oh no")
}

& other things are possible!
data Maybe {
	None
	Some (value)
}

```

These would not be parametric (you don't need parametric datatypes if can be agnostic about what your type holds!). In addition, it would allow for static (again, with limits, but past those limits lie very stinky code smells) exhaustiveness checking on pattern matching--a win for a dynamic language!

What comes after the data constructor (vs. the datatype) is a tuple pattern. The structure of the data is enforced by pattern matching against what you pass the constructor, which is called as a function. Datatypes, like named tuples, like tuples, have a statically-known size.

#### Tuples vs structs
In principle, datatypes need only require values of statically-known sizes, so that means *both* tuples and structs.

If there is some parsing way to distinguish between types and normal values (like Haskell, types are capitalized), then we could have structs after datatypes, not just tuples. That would require syntactical changes, e.g.:

```
data Node {
	Bool {:value as Boolean}
	Num {:value as Number},
	Str {:size as Number, :value as String}
	Tup {:size as Number, :members as List}
	&...
}

let str = Str {:size 3, :value "foo"}
str :size &=> 3
str :value &=> foo
str :foo &=> panic!

fn value (v) -> match v as Node {
	Bool | Num | Str -> v :value & note | as "or", omission of `_`
	Tup -> v :members
	else -> nil
}

```

#### Unresolved design decision 
The very stinky code smells above look like: trying to match against a datatype you don't know: that you get as a return value of a function, that you get as a parameter to a function, &c. That doesn't really make any sense, since if you don't know the type, you also don't know the data constructors for the left hand side of the match clause. This kind of pattern matching is extremely nominal rather than the structural stuff we have everywhere else.

I don't yet have a grasp on the design space here (including how to parse the LHS of a match clause). But my intuition says there should be a way of statically determining if a type & its constructors are correct without resorting to parsing schemes like requiring names of types and constructors to be the only things that are capitalized (which, in any event, would be difficult here), or separating values and types into separate realms, which seems anti-lispish, anti-Ludusish.

So the rule is this: `data` expressions, like `import` expressions, must be made in a script. They are really expressions! But they're only available at a top-level.

### Modules
Combining namespaces and types leads you, naturally, to the idea of a module, where you define a datatype and a bunch of functions that work on that datatype. Thus you get polymorphism. So far I have avoided polymorphism in the design, because that has seemed unncessary in a super dynamic language. But: it actually could be lovely. We'd need a method-access syntax that's different from keywords. Consider:

```

&&& llist.ld

data Llist {
	Empty
	Cons (first, rest as Llist)
}

fn first (list) -> match list as Llist {
	Empty -> nil
	Cons (first, _) -> first
}

fn rest (list) -> match list as Llist {
	Empty -> nil
	Cons (_, rest) -> rest
}

fn conj {
	() -> Empty
	(element) -> Cons (element, Empty)
	(list, element) -> Cons (element, list)
}

fn reduce (list, f, acc) -> match list as Llist {
	Empty -> acc
	Cons (first, rest) -> reduce (rest, f, f (acc, first))
}

& ...

module Llist { & Empty and Cons are already members
	first
	rest
	conj
	reduce
	& ...
}

&&& foo.ld
import "llist.ld" as Llist

let @{Cons, Empty, ...} = Llist & current best guess at namespace destructuring

let iterable = if gte (random (), 0.5)
	then [1, 2, 3]
	else Cons (1, Cons (2, Cons (3, Empty)))

& and now we need method syntax; current preference
::first (iterable) &=> 1
::reduce (iterable, add, 0) &=> 6

fn sum (iterable) -> ::reduce (iterable, add, 0)

```

There are a few awkward things here.

#### Awkward thing: Double-binding names
In `llist.ld`, what is `Llist`? It's a datatype **and** a module. That means one of two things:
* We are binding to the name `Llist` twice, which is a no-no, or
* We are mutating `Llist` by effectively adding properties to it, which is also a no-no.

But, to do anything like polymorphic dispatch, we need a way of associating a type with a namespace. A type that's been promoted into a module seems like a different thing. I think the lesser of two no-nos here is the mutating one. So, in the above, `Llist` is not a member of the module, but in some important way _is now_ the module.

#### Awkward thing: Method syntax
I don't love, but am coming to like the idea of, a special kind of function call. For example (echoing keyword access): `::first (iterable)`. In this scheme, a method would dispatch to the `first` function in the module associated with the type of the first argument.

Part of me wants to say that Elm may have it right here: no modules, no polymorphism. That means that the core namespace functions can't be extended. `first` has a hard-coded set of clauses, never to be extended to other kinds of collections.

It should be possible do something more explicit, like:

```
fn get_method_on (value, method) -> do value => type_of => get_module => method

get_method_on([], :first) &=> List :first

```

Note that unlike in object-oriented languages, methods are not on the values, but on the type of the value, so you have to go through exactly this indirect path on every method call. There are way of making this fast(-enough), I think. That's the real kicker, here.