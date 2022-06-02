# On the difference between interpreter implementations
## Or, the differences between threads and processes

Developing the high-level implementation of Ludus in Clojure made a great deal of sense, given the semantic similarity between my vision for Ludus and Clojure. Until, that is, I started having to think about concurrency. Clojure's story is complicated.

A good deal of this complication lies in the fact that Clojure is a doubly-hosted language. One of there reasons I was excited about Clojure is that it runs pretty effortlessly both natively and in the browser. However, the difference between a multi-threaded JVM implementation and a single-threaded Javascript runtime means that Clojure's concurrency does not work across CLJ and CLJS.

The abstraction that cuts across the two, `core.async`, is 