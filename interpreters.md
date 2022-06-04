# On the difference between interpreter implementations
## Or, the differences between threads and processes

Developing the high-level implementation of Ludus in Clojure made a great deal of sense, given the semantic similarity between my vision for Ludus and Clojure. Until, that is, I started having to think about concurrency. Clojure's story is complicated.

A good deal of this complication lies in the fact that Clojure is a doubly-hosted language. One of there reasons I was excited about Clojure is that it runs pretty effortlessly both natively and in the browser. However, the difference between a multi-threaded JVM implementation and a single-threaded Javascript runtime means that Clojure's concurrency does not work across CLJ and CLJS.

The abstraction that cuts across the two, `core.async`, is difficult Ludus to really take advantage of. To start, mapping channels to actors isn't as straightforward as it may sound. In particular, the fact that channels only really work in `go` blocks means that `core.async` effectively "colors" channels (as in Bob Nystrom's "what color is your function?" blog post). In particular, this makes `receive` expressions very difficult to implement, since you're not just dealing with function returns, but passing things through channels. You'd need a channel-equivalent of continuation-passing style.

Which, to be sure, is possible! But also more advanced/complex than what I want to be implementing in the reference interpreter, which is mostly about semantics and syntax and correctness, not performance.

But, this does nevertheless impact a set of factors I will need to be consider as I work out the higher-performance interpreter in Zig (or Rust). To wit:

(1) Processes (concurrency in general) is a fundamental part of a language, actually. So it can't be tacked on at the end. If we are in fact going to have something like Erlang-style processes, then that needs to be an early architectural decision, and I have to consider [the design of the BEAM](https://blog.stenmans.org/theBeamBook/) and also its equivalents in other scenarios (including, for exmaple, [Lunatic's WASM-based actor platform](https://github.com/lunatic-solutions/lunatic)).

(1a) The BEAM, for example, introduces the idea of a "reduction," which names the calling of a function. Processes yield to the scheduler after a certain number of reductions. That means that no process can lock the others. But that will mean that the stack machine will have to include reductions as a factor.

(2) I think I've more or less worked out [memory management](./memory.md), at least at a very high level. But the actor model raises new questions. Each process in the BEAM has its own stack *and heap*, and messages that are passed between them must be serialized atomics. But Ludus is not looking for truly distributed computing, and the memory is largely read-only. So it should be possible to have a single reference-counted heap, and to pass reference types by reference instead of by value.

(3) There will need to be opcodes for the VM that relate to the process model, including incrementing a reduction and also parking the process awaiting a message.

(4) We're in the realm of empirical testing of scheduling algorithms, and I can tell that's already going to give me heartburn. Keep in mind that we're only looking for fast-enough. (The reference implementation doesn't try to do 
anything other than simply looping through all processes.)

(5) We're already pretty far off-piste from the Bob Nystrom way. In particular, I'm already thinking of static analysis, and the streaming compiler Bob uses in his stack-based VM example won't cut it. So I'm already going to be building an AST and analyzing it before compiling it into bytecode.

(6) And, naturally (and I knew this was coming) I have to write persistent data structures for Ludus, especially if heap sharing (see (2)) is going to be a thing. I've already written a persistent vector in JS; it's fiddly but not difficult. This will of course be fiddlier in whatever low level language I end up using. But also the mechanics of persistent collections will likely require knowing about our garbage collection procedures. In particular, 