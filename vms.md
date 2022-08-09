# A quick thought or two about VMs
Reading and research, as always.

Following the Bob Nystrom (tm) model, we do a slow tree-walk interpreter in a high-level language (Ludus-in-Clojure). 
And then we do a fast bytecode interpreter in a low level language (TBD, the object of much fantasizing and thinking on my behalf). 
I've been mostly thinking about Zig as the language for that, because it's similar enough to C that mostly translating Nystrom's clox code to Zig seems pretty surmountable.

But today's reading and research has suggested a different approach, and one that makes a lot of sense to me, which is a layer over an AST-based approach where you use closures to effectively "compile" the the AST-nodes into Rust code. 
Examples: https://blog.cloudflare.com/building-fast-interpreters-in-rust/, https://www.reddit.com/r/rust/comments/opj1pa/comment/h67mt3z/?utm_source=share&utm_medium=web2x&context=3, https://ndmitchell.com/downloads/slides-cheaply_writing_a_fast_interpreter-23_feb_2021.pdf.
Also relevant here is: https://ceronman.com/2021/07/22/my-experience-crafting-an-interpreter-with-rust/.

This seems intriguing, indeed.

A few notes:

1. I'm thinking a bit about how not to have to write everything at a really low level---persistent data structures, an actor model, etc. Zig's ecosystem really isn't big enough to give me much; I'd be writing that all from scratch. Whereas Rust's ecosystem *is* big enough. It may not work for my needs? But Rust has [Actix](https://github.com/actix/actix) and [im](https://docs.rs/im/latest/im/).

2. Anything that can keep the code simpler, and keep the execution model closer to an AST, is better. Likewise, anything that can keep the execution closer to Rust, the better. I'm not going to be maintaining this as a full time job, 


