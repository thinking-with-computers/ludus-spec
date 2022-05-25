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
Executing on these is the path out of pre-alpha into alpha, and the prerequisite to asking others to engage in the language. Not necessarily completely worked out, but 