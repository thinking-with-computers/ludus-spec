# Ludus Roadmap

Last revised 2022-05-25.

As of now, the major parts of Ludus are largely worked out.

### Major Projects
* REPL
* Datatypes
* Modules + methods
* Actors/processes
* Error messages
* Static analysis
* Documentation
* Stdlib
* `test` blocks
* Testing

### Minor projects
* Syntax highlighting
* Quality of life improvements
* `when` guards in patterns

#### Quality of life improvements
Or, the rough edges that need to be sanded down, and bugfixes:
* [ ] Rename hashmaps to dicts
* [ ] Splats in patterns
	- [ ] List
	- [ ] Dict
	- [ ] Tuple? (Gather remaining members into a list? This would allow robustly variadic functions.)
* [ ] `if`/`let` coding pattern/error handling: the test expression in an `if` will swallow panics caused by failures to match, and dump out to the `else` branch.
* [ ] Line number in error reporting is always `nil`: should, like, be the actual line number
* [ ] Fail gracefully when files not found
* [ ] Add pretty-printing for patterns

#### Syntax highlighting
* [ ] SublimeText
	- [ ] research format
	- [ ] execute
* [ ] VSCode
	- [ ] research format
	- [ ] execute

#### `when` guards
* [ ] Add to pattern syntax
* [ ] Add to pattern semantics
* [ ] How to restrict guard expressions to pure functions?
	- Elixir just has a list of acceptable functions.

### Major projects
Executing on these is the path out of pre-alpha into alpha, and the prerequisite to asking others to engage in the language. Not necessarily completely worked out, but worked out *enough*. (What's enough?)

#### REPL
The strict immutability of Ludus brushes up against the interactivity of a REPL. You can't re-bind names! But Matt gave us our model for dealing with this friction, at least to start: REPL sessions. See the end of my notes on [interactivity](interactivity.md).

* [ ] Basic interactivity
	- [ ] Clj read/write from stdio
	- [ ] Research Clj CLI/TUI packages to help
* [ ] Session management
	- [ ] API design, e.g. `Repl {:flush, :switch, :dump, :new, ...}`
	- [ ] Implementation
	- [ ] Handle inclusion of `Repl` access in scripts
* [ ] Panic handling
* [ ] Multi-line expression management
* [ ] Tab completion
* [ ] Colors!
	- [ ] If not already in place, research Clj CLI/TUI packages
	- [ ] Syntax highlighting
	- [ ] Colored output

#### Datatypes
Ludus will have datatypes, including sum types (enums). This will allow for static checking of pattern match exhaustiveness.

* [ ] Full design/spec (see [notes on datatypes](nses_structs_types.md))
	- [ ] Internal representation
	- [ ] Syntactical representation
		* Are capital letters enough?
	- [ ] Base types
* [ ] Construction
	- [ ] Nullary
	- [ ] Tuple
	- [ ] Struct
* [ ] Pattern matching
	- [ ] Add `as` to match expression
	- [ ] Add patterns for constructed datatypes

#### Modules & methods
With datatypes, we have the possibility of robust single-dispatch polymorphism. This will affect the standard library substantially, making it substantially simpler and more interesting.

* [ ] Full design/spec (more in [notes on datatypes](nses_structs_types.md))
	- [ ] Module syntax
		* [ ] How to handle repeated naming of module/type/namespace?
	- [ ] Method syntax (proposal, `::method`)
	- [ ] Dispatch semantics
		* [ ] For base datatypes
		* [ ] For constructed datatypes
* [ ] Implementation

#### Actors/processes
For a start on the actor-model see [the Elixir documentation on processes](https://elixir-lang.org/getting-started/processes.html) (its name for actors). This is Ludus's message-passing concurrency model.

* [ ] Research how to model actor semantics in Clojure
* [ ] Implement tail-call elimination (see Static analysis, below)
* [ ] Full design/spec
	- [ ] Syntax
		* [ ] Function-like or keyword-like? (e.g. `self ()` vs `self`, `receive` vs `receive ()`)
* [ ] Implementation
	- [ ] `spawn` w/o message passing (simple returning-function)
	- [ ] message passing

#### Excellent error messages


#### Static analysis
The sooner we surface errors, the better. Also, 

* [ ] Research basic techniques for static analysis
	- [ ] Play with Ludus ASTs
	- [ ] Read into the literature
* [ ] Create a laundry list of wish-list static analysis items
	- [ ] Tail-call elimination
	- [ ] No use of unbound names
	- [ ] No binding of unused names
	- [ ] Exhaustive pattern-matching
	- [ ] No improper ns member access
	- [ ] `recur` is in tail position in `loop`
	- [ ] enforce `when` guard restrictions
	- [ ] static closures
	- [ ] validation of `import` paths

#### Documentation

#### Stdlib