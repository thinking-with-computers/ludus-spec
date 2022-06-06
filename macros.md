# Macros.
## Well, shit.

One thing I had been planning to avoid was macros. But now I see some real utility in them, and a way to make them happen in a very straightforward way.

Macros are like functions, except for instead of getting their arguments evaluated before the macro is called, they get ASTs passed, which can then be manipulated and interpreted.

This will be very, very straightforward for the macros I want to start with: `and`, `or`, `eq`, which short-circuit.

```
macro or {
	() -> false
	(x) -> #x & possible syntax for "interpret x"
	(x, ...xs) -> {
		let exprs = [x, ...xs]
		loop (exprs) with {
			([x]) -> #x
			([x, ...xs]) -> {
				let x_ = #x
				if x_ then x_
					else recur (xs)
			}
		}
	}
}

macro and {
	() -> true
	(x) -> #x
	(x, ...xs) -> {
		let exprs = [x, ...xs]
		loop (exprs) with {
			([x]) -> #x
			([x, ...xs]) -> {
				let x_ = #x
				if x_ then recur (xs)
					else x_
			}
		}
	}
}
```

A few issues arise:

* What syntax to use for interpretation? I like the hash, and it can *only* be used in a macro, enforced in the parser.

* Perhaps this minimal version will be just fine (and with mitigated-enough powers that it won't/can't be abused). But: it's likely we'll want to actually be able to inspect and manipulate the ASTs that are passed in, which suggests we need a Ludus-compatible representation of an AST. At current, that's not possible, since the Clojure representations of Ludus ASTs, tokens, and data use fully-qualified keywords, e.g. `::ast/type`. The quick and dirty way to switch this would be to use Ludus dicts. Each language supports slashes in keywords, so it would be a quick search-and-replace in the Clojure codebase to allow for clean & usable representations of ASTs in Ludus. That said, there may well be something to trying to implement and use datatypes to represent the AST.

* And finally, there's a question about whether the context should be present, or manipulable. I think it should not be.