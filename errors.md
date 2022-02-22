# Errors, early returns, and monads

One of the decisions I've made so far is to disallow early returns in Ludus. Every function has a single return point. In addition, there are no exceptions: either returns or panics. This is elegant, allowing for function bodies to be single expressions, using blocks. But when dealing with errors as return values, this can be a pain. You end up with nested conditional forms, since you can't escape early.

That is also the reason for avoiding a Zig-style `try` or a Rust-style `?` operator. These are sugar for early returns, but coupled to conditional forms. 

The solution to this problem that I've been intuitively pursuing is to use Ludus's version of an result type (`(:ok, value)`/`(:error, info)`) as a diet monad, and using a special version of a pipeline (`=>`?, pronounced "bind"). Such an operator produces pipelines that don't just pass the return value to the next function. They expect a result tuple, unpack a success and pass its value to the next function, or short-circuits on an error, and return that. This is what Haskell does: no early return, model it with monads and binds.

But the result tuple is not the only time a user will want early return. For example, you might want instead to short-circuit on a falsy value, or a `nil`.

One possibility here would be somehow to devise the syntax of the bind to take a function that decides when to short-circuit.

Here's one possibility

```
fn result (x) -> x & a synonym for `id`

fn maybe {
	(nil) -> (:error, "Expected a value, but got nil.")
	(value) -> (:ok, value)
}

fn truthy (value) -> if value
	then (:ok, value)
	else (:error, "Expected a truthy value, but got {value}.")

let result_binding = with result do x =>> f =>> g =>> h

let maybe_binding = with maybe do x =>> f =>> g =>> h

let truthy_binding = with truthy do x =>> f =>> g =>> h

let unbound_pipeline = do x => f => g => h

& note that `pipe` and `comp` will likely be variadic special forms
let pipeline = pipe(f, g, h) (x)

let composed = comp(h, g, f) (x)

let bound_result = bind (result, [f, g, h]) (x)

let bound_maybe = bind (maybe, [f, g, h]) (x)

let bound_truthy = bind (truthy, [f, g, h]) (x)

```

A few notes on this scheme:
* This makes parsing easier, if pipelines are introduced with a reserved word like `do`. 
	- The pipeline doesn't have to be an operator in a bare expression.
	- As with `if` forms, we can allow a single newline before each arrow.
	- The word choice matters here but is super simple to change `do`, `send`, &c.
* This makes binding explicit and flexible: a function simply has to convert a return value to a result tuple, easy-peasy. User-defined binding functions, yay!
* This also makes it possible to mix binding arrows and unbound ones, since we know before we construct the pipline whether we're binding or not.

This behaviour, however, is not quite fully monadic. It only specifies the short-circuiting behaviour; the happy path is normal function application. A fully monadic solution would use a function (well, really, a method) for the happy path as well (`bind`... or `chain`, `join`, `flatMap`, &c.) That would allow for futures to work here. I'm reminded of the infamous [Issue #94](https://github.com/promises-aplus/promises-spec/issues/94), whose lesson is: category theory comes for us all in the end. You can decide to depart from it, but it's worth exploring the space before you decide to make that departure.

### Monads, maybe?
Consider an implementation of `bind`:

```
fn bind_apply {
	(x) -> x
	& ensure this is a reducer
	(x, f) -> match x with {
		(:ok, result) -> f (result)
		else -> (:stop, x) & recall that our implementation of `reduce` can short-circuit!
	}
}

fn bind {
	(fs) -> bind (id, fs) & maybe?
	(binder, fs) -> {
		let with_binder = (x) -> do x => binder => bind_apply
		fn bound (x) -> reduce (with_binder, fs, x)
	}
}

let bound = bind ([f, g, h])(x)
```

This is all handled with function application and destructuring. That first `match` clause in `bind_apply` is where something else might go. Instead of `f (value)`, you could instead pass in a different function, that lets you control not just the error path but also the happy path.

Great!

Although two things here:
1. This is all doable with functions! So it could be a totally normal pattern in Ludus to, say, write `do x => bind(maybe, [f, g, h])`. Point being, though, that these patterns perhaps do _not_ need to be built into the syntax yet. Again, it's worth exploring what this feels like. But neither Clojure nor Elixir have early return. Perhaps pattern matching + guards will be enough.
2. This also feels like it's moving into wanting polymorphism, where you'd write `result:join (f)` instead of doing the destructuring & matching. That would be... fine, but less performant, and also only really a good idea with static types.

I suspect there will have to be some kind of short-circuit-on-error solution, but I think building a `bind`ing operator into the language at this point is rather premature.

The one thing I do like is the `do` reserved word before a pipeline.
