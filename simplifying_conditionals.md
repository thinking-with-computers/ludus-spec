# Simplyfying Conditionals

After: https://www.reddit.com/r/ProgrammingLanguages/comments/wmmeu5/general_purpose_matchswitchbranch/

What we might do in Ludus:

* replace `when` keyword with `if` in patterns, e.g., `let (x if gte (x, 0), y if is_even (y)) = (1, 14)`.
* consider replacing `match` with `when` and `with` with `is`:

```
when x is {
	0 -> :zero
	1 -> :one
	_ -> :other
}

data Foo is {
	Bar
	Baz
}

when foo as Foo is {
	Bar -> :bar
	Baz -> :baz
}
```
