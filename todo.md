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
* [ ] wire up a pretty-printer for values
* [ ] error reporting
* [ ] wire up Ludus CLI
* [ ] `ref`s
* [ ] function pipelines
* [ ] partial function application

### Core language design features
* [ ] should numbers be a single type or two?
* [ ] should sets look like lists instead of hashes?

### Core language improvements
* [ ] design/develop a framework for static analysis
* [ ] string interpolation w/ names only
* [ ] splats for:
	- [ ] hashmaps
	- [ ] lists
	- [ ] sets

### 