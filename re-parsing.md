# Re-imagining the parser
## How to get better error messages
### And still make the parser reasonable to change

2023-05-02

Refers to ludus.ebnf, after my experience building an Instaparse library

### Terminals, or tokens
Ludus has some terminals: everything that's a string or regex in ludus.ebnf: atoms, literals, braces, newlines, commas, etc.