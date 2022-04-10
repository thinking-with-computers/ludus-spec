# Some thoughts on interactivity

What is the model for interactivity for Ludus? What models for interactivity with code are there? What models for interactivity with computing are there?

The questions telescope, and get very broad very quickly. There are ways to tame them: tracing the historical paths that early technologists like Papert and Engelbart followed; following some intuitions based on our experiences; looking to contemporary models; doing some formal analysis.

We'll do all of those in turn, and a little bit here.

But this isn't a blog post (yet), it's process writing.

So:

One of the lessons of the last 20 years of programming culture is that managing state is not necessarily a hard problem, but it _does_ need to be approached carefully. The proliferation of encapsulated state in OO makes things hard. And, the aesthetic preferences and intuitions about programming that led me to want to write a functional programming language make me want to lean into language constructs that make managing state carefully quite easy--and that require explicitness. Clojure is a model here. And this is Lispish! Scheme is functional-forward; Clojure leans into that. So we're in the same ballpark as _SICP_ and MIT in the 1970s and 80s. So.

But: Logo is emphatically, recklessly, gleefully stateful. It's got dynamic scope. You don't build functions, you build _procedures_. At its REPL, if you give it a value, instead of returning it, it complains: "You didn't tell me what to do with 42." The _command_ is the metaphor, and also the transitional object: kids know about being told what to do, and telling somebody else what to do. _Learning with Logo_ is replete with cartoons about bossing characters around. So even though Logo "is" a "Lisp," it's actually unusually stateful.

More to the point, perhaps, the REPL is a model where interactivity with a system is about changing its state. You type a line, something happens. The state is different. You type another line, the state changes again.

So my intuitions with Ludus and the state model of Logo are completely at odds. I don't think I know _better_ than Papert, et al. There are differences of intent: Ludus is directed at grownups. We also have 50 years of computer culture behind us: people already know how to interact with computers; they have collections of transitional objects.

The _document_ is one of the more visible, obvious, familiar transitional objects. (You know, the whole office metaphor: desktops and folders and whatnot.)

As Matt pointed out, perhaps the Notebook is a better model. Literate programming is nice. We will ultimately be thinking about publishing prose, so building up less to a REPL than to a Notebook-like thing make a lot of sense.

However, Notebooks come with their own problems (viz. https://yihui.org/en/2018/09/notebook-war/). They, uh, actually don't solve problems with state, at least if you're using Jupyter. And let's please (please? please!) not try to write another code editing environment. That seems... ill-advised, to say the least. 

Yihui Xie, in that blog post, points out that R's notebooks are basically just markdown documents. That, to me, seems like the place to start, or _a_ place to start.

So imagine, if you will, the following:
* .ld, for Ludus scripts that are nothing but scripts;
* .ldd, for Ludus data: an equivalent of JSON or EDN, which consists of nothing but Ludus literals (i.e. static data, no arrows, no conditionals), and
* .ldn, for Ludus notebook: a markdown document where the code blocks are interpreted as Ludus, syntax-highlighted that way. They're plain-text documents (unlike Jupyter notebooks, but like R notebooks).

More to the point, it seems plausible to hook into the VSCode language server/plugin ecosystem to make the editing of .ld and .ldn files richly interactive. For example, each block in a Ludus notebook would automagically display its return value. We'd want something like Quokka, or Clojure Sublimed: a "REPL" in the editor, not an actual REPL. (The model would be not so different than Clojure Sublimed or a Jupyter notebook: a server running a Ludus interpreter that would communicate with the editor, and an editor plugin to manage that situation on the editor side.)

However, a code editor is not exactly what we might want, either: no inline images in VSCode. So what do you do with images--or animations?

And here, we're reinventing a coding environment, or more to the point, a _computing_ environment. That may seem desirable, but not something I want to spend my days doing. Writing an interpreter is more than enough getting my hands dirty with hacking. 

And so, the question, I reckon, is going to be: what's the thing we can fork that will give us the version of the thing that's closest to what we want? (And also, that will not require bootstrapping a whole coding environment on a local machine.)

My intuition is that, ultimately, it's going to live in VSCode.

For now, however, learning the lessons of Niko Matsakis's "Responsive Compilers" video seems wise (https://www.youtube.com/watch?v=N6b44kMS6OM). Knowing how the LSP works before I start really digging into writing the interpreter à la Nystrom will be saluatary, I reckon.