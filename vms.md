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

1. I'm thinking a bit about how not to have to write everything at a really low level---persistent data structures, an actor model, etc. Zig's ecosystem really isn't big enough to give me much; I'd be writing that all from scratch. Whereas Rust's ecosystem *is* big enough. It may not work for my needs? But Rust has [Actix](https://github.com/actix/actix) and [im](https://docs.rs/im/latest/im/).And this scales up: what about graphics? WASM support? Etc.

2. Anything that can keep the code simpler, and keep the execution model closer to an AST, is better. Likewise, anything that can keep the execution closer to Rust, the better. I'm not going to be maintaining this as a full time job, and having the guarantees of the Rust compiler seems like a win.

3. Zig is still a moving target. I feel like being tied to a particular language's development might be bad.

4. While I'm pretty good at copy-pasta and interpreting something out of a book, it's also the case that one of the cases for Rust the ornery compiler actually keeps you thinking well about the actual behaviour of your system---whereas Zig (and C) leaves a lot more up to you. Since I'm a good coder but have not used manual memory management before, it seems wise to use something with guide rails and not YOLO.

5. I was able to worry publicly on /r/programminglanguages about possible difficulties with pointer sizes and NaN boxing. But one of the responses there was intriguing: you don't need that much performance optimization. So maybe the friendly closure-based approach really will be enough for what we need it for!

So, the new strategy: worry less about performance above a particular floor, use crates to do things I don't want to write, use closures-as-compilation, use Rust's Rc to do memory management (since we're not so concerned about cycles), etc. 
