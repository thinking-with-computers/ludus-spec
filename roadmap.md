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

### Minor projects
* Syntax highlighting
* Quality of life improvements

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
	- [ ] Base types
* [ ] Construction
* [ ] Pattern matching

#### Modules & methods

#### Actors/processes

#### Excellent error messages

#### Static analysis

#### Documentation

#### Stdlib