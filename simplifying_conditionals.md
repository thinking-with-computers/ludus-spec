# Simplyfying Conditionals

After: https://www.reddit.com/r/ProgrammingLanguages/comments/wmmeu5/general_purpose_matchswitchbranch/

What we might do in Ludus:

* replace `when` keyword with `if` in patterns, e.g., `let (x if gte (x, 0), y if is_even (y)) = (1, 14)`.
* consider replacing `match` with `when` and `with` with `is`:

```
when x is {
	0 -> :zero
	1 -> :one
	y if gte (y, 1000) -> :big
	_ -> :other
}

data Foo is {
	Bar
	Baz
}

when foo is Foo {
	Bar -> :bar
	Baz -> :baz
}
```

* consider replacing `cond` with a bare `when`:

```
let x = 12

when {
	eq (x, 12) -> :twelve
	lt (x, 0) -> :negative
	else -> :pos_not_twelve
}
```
This last would require lookahead, since you don't know if it's a block expression or the equivalent of a `cond` until you got to the arrow. 
In addition, I don't love the idea of simply changing the semantics of what's in the block by adding a `<expr> is` before the brace.

### Provisional conclusion
So `if`, `cond`, and `when <expr> is <?type>`, with `if` in patterns.

### On if-let chaining
See https://github.com/rust-lang/rfcs/pull/2497.

One thought I have around the `and` and `or` special forms is to ensure that they pass through what they need to allow if-lets, and thus to ensure chaining, e.g. `if and (let x = 1, let y = 2) then :yes else :no`. In addition, I need to ensure that any and all bindings in the condition expression in an `if` only binds in the `then` and `else` expressions.

That suggests that `and` and `or` really do need to be true special forms.