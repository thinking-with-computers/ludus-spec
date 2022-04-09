# On Memory Management
## Or, data-oriented design comes for Ludus
### Or, even, thinking with Roc

See:
* https://roc-lang.org
* https://media.handmade-seattle.com/practical-data-oriented-design/

I've been looking forward to a low-level interpreter for Ludus. And one of the things I've been anticipating (perhaps brimming over with fantasy) is the ways that Ludus's strictness will allow for certain kinds of ease and optimization in the interpreter.

In particular, two things are worth thinking through as we're designing the syntax and semantics of the language:

* If we can avoid cyclical references, then we can use automatic reference counting instead of a whole tracing garbage collector. (This would allow for Roc's "opportunistic in-place mutation"; but this can also be done statically? Morphic Solver.)

* If we can avoid heap allocations for almost all types, that makes things a lot faster: allocate all the things on the stack.

#### Avoiding cycles
Let's see if we can create a reference cycle, assuming that Lists, Hashmaps, and Sets are the heap-allocated data types.

```
var hash = #{:self nil}

mut hash = #{:self mutable}

var list = []

mut list = [list]

```

The question here is whether these are references or values. And since we deal with even heap-allocated data as _values_, what we get is `hash` being `#{:self #{:self mutable}}` and `list` being `[[]]`.

There's the possibility of references, but those aren't yet in the langauge. You can model them with closures, however:

```
fn ref (value) -> {
	var data = value

	fn get () -> data

	fn set (value) -> mut data = value

	@{get, set}
}

{
	let circular = ref (nil) & ref count = 1

	circular :set (circular) & ref count = 2

	circular :get () &=> circular
} 

& circular falls out of reference now that the block is closed, but the ref count is now 1, and it won't get deleted


& we can also have arbirarily complex circular references:

{
	let indirect_1 = ref (nil)

	let indirect_2 = ref (indirect_1)

	indirect_1 :set (indirect_2)
}

```

Thus we have a circular reference cycle: all you need is a closure plus a mutation.

That suggests that to avoid a full tracing GC we either need to _detect_ cycles in `var`s (which I'll have to research--it's trivial in the trivial case, but my intuition is that we end up implementing a full tracing GC in the indirect case). Alternately, we'd need a different memory management strategy for `var`s.

One possible solution would be to disallow the mutation of closed-over `var`s. This pushes the language much further into functional purity. I'm not even sure I know how I'd implement something as simple as `forward` in turtle graphics without closed-over `var`s.

To solve that problem, we might then have a special language feature, a `ref`, which is like a `var`, but must be dereferenced to be used. (Essentially, like the closure above.) Semantically, however, a `ref` may never hold a `ref`. (But can it hold a thunk to a `ref`? But as soon as you try to execute that thunk in a `swap!`, the cycle becomes direct.) To be worth anything, a `ref` must be returnable as a reference, which can be swapped. But if you try to give it a reference (and thus introduce a cycle), you get a panic.

(If we have a heap-allocated references that are a specific type, do we actually need `var`s? See below.)

#### Avoiding heap allocations
The basic idea is to use the stack as much as possible: we don't need reference counting if it's on the stack, and it's way faster. For now, my thought is the following scheme:

On the stack:
* `nil`, `true`, and `false`
* numbers (32-bit floating point)
* tuples
* structs (?)
* closures (they have a static size known at compile time, and, as of _now_, are immutable; thank you Roc... maybe?)

In the "data" portion of the program:
* static strings
* structs (?): they're static

On the heap:
* strings
* lists (persistent vectors)
* hashes (CHAMPs)
* sets (also CHAMPs?)
* refs

One thing about the stack here is that, with tuples, structs, and closures, not everything on the stack is the same size. That means we'll need to do additional bookkeeping around how big the thing is we're popping of the stack. I admit that I don't yet know what that will look like in practice.

One thing that I do know is that heap-allocated types will require that tuples, structs, and closures be moved to the heap and have a pointer to them. This is because, even though they have a known size at compile time, the size actually varies. But the payoff is that, with persistent vectors (lists) and CHAMPs (hashes; Steindorfer & Vinju, 2015) we get really good cache locality.

I suspect that this will all take quite a while to figure out in all the details. One thought is that we'll end up wasting a bunch of memory by setting the alignment of the stack at 64 bits (with tuples and structs and closures taking up the number of members + 1).

We don't need the kind of performance Roc is after (although I wouldn't be mad if we got there!), but it would be nice to use Ludus's user-facing strengths to make it a faster language when we get to the fast implementaiton phase; and, while we're still hammering out the semantics, it makes sense to be able to anticipate the performance concerns now (even if we make some decisions that depart from the perf happy path).

##### Some further thoughts
We need an additional restriction to get out of reference cycles: `ref`s cannot hold other `ref`s, nor may they hold _functions_. That is to say, a reference may only hold entities Ludus understands as values. And since Ludus treats all its collections as values, such collections cannot hold references. (Is that right? That is 100% _not_ what Clojure does. But it's perfectly happy to use Java's [tracing, heavily optimized beyond my ken] GC.)

I think this actually gets us to no reference cycles and ref counting.

##### Another set of thoughts
Consider the following:

```
{
	ref myref = nil & myref count = 1

	fn close_over () -> deref (myref) & myref count = 2

	let myhash = #{:circular close_over} & myhash count = 1

	swap! (myref, (_) -> myhash) & myref and myhash now have coount of 2
} & count for both is now = 1

& myref is now out of scope, unreachable, and has a ref count of 1
& myhash is now out of scope, unreachable, and has a ref count of 1
```

This follows my rules, above. I think there's no way to avoid the mark-and-sweep garbage collection with these language semantics.
