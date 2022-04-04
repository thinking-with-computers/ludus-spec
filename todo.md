# What we're doing

As of Apr 3, 2022.

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
* [ ] `cond` expressions
* [ ] add location information to panics
* [ ] `import` expressions
* [ ] `ns` expressions (structs + names?)
* [ ] wire up a pretty-printer for Ludus values
* [ ] parse error reporting
	- [ ] with line numbers
	- [ ] with nice text
* [ ] wire up Ludus CLI
* [ ] `ref`s
* [ ] function pipelines / `do` expressions
* [ ] partial function application
* [ ] additional patterns
	- [ ] hashmap
	- [ ] struct
	- [ ] list
	- [ ] set?
	- [ ] ignored words
	- [ ] `else`
	- [ ] `as` in patterns
* [ ] iteration expressions
	- [ ] `loop`
	- [ ] `repeat`
	- [ ] `gen`
* [ ] splats for:
	- [ ] hashmap
	- [ ] list
	- [ ] set

### Core language design features
* [ ] should numbers be a single type or two?
* [ ] should sets look like lists instead of hashes?
* [ ] how to spell builtin types? (before/without datatypes, e.g. `:string` or `String`)
* [ ] should `ref` swapping be a keyword or a function?

### Core language improvements
* [ ] string interpolation w/ names only
* [ ] tail call optimization
* [ ] design/develop a framework for static analysis
* [ ] syntax highlighting
	- [ ] SublimeText (this first, it's much easier)
	- [ ] VSCode
* [ ] LSP language server
* [ ] `when` clauses in patterns
	- [ ] which functions are allowed in `when` clauses?

#### Core language prelude
A language is more than syntax. Make some determinations about what needs to call out to the host language (Clojure; Zig?), and what can be implemented in Ludus.

#### Core language static analysis
* [ ] no unbound names
* [ ] no re-binding of names
* [ ] `recur` is in tail position in `loop`
* [ ] propery function arity
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