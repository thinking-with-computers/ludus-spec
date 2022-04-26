# What we're doing

As of Apr 6, 2022.

### Things already done
* Atomic values
	- `nil`
	- Boolean
	- String
	- Number
* Base data structures/literals
	- Tuple
	- List
	- Set
	- Hashmap
	- Struct
* Functions
* Patterns
	- Literal
	- Words
	- Placeholder
* `let` expressions
* `match` expressions
* `if` expressions
* a framework for calling Clojure functions

### Core language features
* [x] `cond` expressions
* [ ] add location information to panics
	- [ ] add location information to AST nodes
* [x] `import` expressions
	- [ ] add static validation to paths
* [x] `ns` expressions (structs + names?)
* [x] up a pretty-printer for Ludus values
* [x] parse error reporting
	- [ ] with line numbers
	- [ ] with nice text
* [x] wire up Ludus CLI
* [ ] `ref`s
* [x] function pipelines / `do` expressions
* [x] partial function application
	- [ ] fix bug: partial application of called keywords. Right now it's `nil`, but it should be something else.
	- [ ] design decision: is `(_)` even legal partial application? (`foo (_)` vs. `:foo (_)`)
* [ ] additional patterns
	- [ ] hashmap
	- [ ] struct
	- [ ] list
	- [ ] set?
	- [x] ignored words
	- [x] `else`
	- [ ] `as` in patterns
	- [ ] splats in patterns
		* [ ] list
		* [ ] hashmap
* [ ] iteration expressions
	- [ ] `loop`
	- [ ] `repeat`
	- [ ] `gen`
* [ ] splats for:
	- [ ] hashmap
	- [ ] list
	- [ ] set
* [ ] `if let` scoping/errors

### Core language design features
* [ ] should numbers be a single type or two? (floats, or floats + ints)
* [ ] should sets look like lists instead of hashes?
* [ ] how to spell builtin types? (before/without datatypes, e.g. `:string` or `String`)
* [ ] should `ref` swapping be a keyword or a function?
* [ ] what is the pipeline operator?

### Core language improvements
* [ ] string interpolation w/ names only
* [ ] tail call optimization
* [ ] design/develop a framework for static analysis
* [ ] syntax highlighting (this first, this is much easier than a full language server)
	- [ ] SublimeText
	- [ ] VSCode
* [ ] LSP language server
* [ ] `when` clauses in patterns
	- [ ] which functions are allowed in `when` clauses?
* [ ] `|` in match patterns as "or" (e.g., `0 | 1 -> ...` will match zero or one)
* [ ] improve `import`
	- [ ] don't allow access further up than CWD (no `..`s in path?)
	- [ ] how to allow `import` in cljs (not just clj)?

#### Core language prelude
A language is more than syntax. Make some determinations about what needs to call out to the host language (Clojure; Zig?), and what can be implemented in Ludus.

#### Core language static analysis
* [ ] no unbound names
* [ ] no re-binding of names
* [ ] `recur` is in tail position in `loop`
* [ ] proper function arity
* [ ] no invalid namespace access
* [ ] detect some illegal struct field access
* [ ] enforce `when` clause function restrictions

### Language additions/extensions
These may or may not land in Ludus, and aren't necessary to start playing around with Ludus.

#### Datatypes + polymorphism
One possibility with Ludus is to develop a set of extensions to the core language that will enable additional kinds of strictness, as well as more ergonomic use of the language.

The biggest design decision is whether to add them at all.

The next biggest design decision is whether/how to distinguish between data constructors and regular functions. (This is not necessary if data constructors only take tuples, but will be necessary if they also take structs.)

Taken together, we have three things that are useful:
* [ ] datatypes
	- [ ] bare (`data Unique`)
	- [ ] with tuples (`data Tagged (value)`)
	- [ ] with structs (`data Color {:red as Number; :green as Number; :blue as Number}`)
	- [ ] sum types/enums
		* [ ] bare (`data Status { Loading; Loaded; Error }`)
		* [ ] with tuples (`data Result { Ok (value) ; Error (info)`)
		* [ ] with structs (...)
* [ ] modules
* [ ] methods
	- [ ] design syntax (e.g., `::method`)
* [ ] `as` in `match` expressions (e.g. `match r as Result`)
* [ ] static analysis: exhaustiveness checking