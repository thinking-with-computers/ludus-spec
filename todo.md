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
* [ ] iteration expressions
	- [ ] `loop`
	- [ ] `repeat`
	- [ ] `gen`
* [ ] splats for:
	- [ ] hashmaps
	- [ ] lists
	- [ ] sets

### Core language design features
* [ ] should numbers be a single type or two?
* [ ] should sets look like lists instead of hashes?

### Core language improvements
* [ ] string interpolation w/ names only
* [ ] tail call optimization
* [ ] design/develop a framework for static analysis
* [ ] LSP

#### Core language static analysis
* [ ] no unbound names
* [ ] no re-binding of names
* [ ] `recur` is in tail position of loop

### Language additions

#### 