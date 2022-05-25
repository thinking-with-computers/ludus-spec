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

### Minor projects
* Syntax highlighting
* Quality of life improvements

#### Quality of life improvements
Or, the rough edges that need to be sanded down, and bugfixes:
* [ ] Splats in patterns
	- [ ] List
	- [ ] Dict
	- [ ] Tuple? (Gather remaining members into a list? This would allow robustly variadic functions.)
* [ ] `if`/`let` error handling: the test expression in an `if` will swallow 
* [ ] Line number in error reporting is always `nil`
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
