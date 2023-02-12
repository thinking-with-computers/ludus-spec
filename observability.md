# On observability, processes, VMs, execution models

It occurs to me that the VM here should include observability in some nontrivial, built-in way. I'm not sure what's possible, or easy. But: take for a moment the idea that the Ludus VM will be inspired by, even modeled on, the BEAM VM. This is to make concurrency dead simple. But it has the added benefit (possibility?) of observing certain things about a process. In particular, the pre-emptive scheduling of the BEAM relies on the idea of reductions: effectively, every time a function or loop returns, that's a reduction; every `n` reductions, the process yields to the scheduler. This way, even infinite loops don't lock. But that also means that you can easily not just increment the reduction counter, but capture information about what the process is doing: what's running, with what values, and report it out to a user. That allows for certain kinds of introspection of something like a call stack.

Since we're not especially worried about security, exposing VM state to the language seems like it may well be an excellent idea.

I'm also thinking about notebooks, too, in which various code blocks might be modeled on processes rather than having something like a separate runtime. This, however, cuts against the idea of namespaces and scripts.

I guess the question, ultimately, is the relation between a script, which runs to completion and returns, and a process, which may run indefinitely.

How do we model returns *from* a process? In other words, what does it look like to think about `import` as a process-based expression, rather than a script-based one? Which raises the question, instead, of how to move data around?

In a BEAM-style VM, each process gets its own memory, including stack and heap allocation. In a script-based execution model, there's a single stack and heap, and the fact that an `import` expression returns the results of executing that scirpt means something like moving ownership of its memory to the original context.

This is where immutability might help: since mutation must be handled carefully and explicitly (with `ref`s), we don't have to worry about shared memory across processes nearly as much. In fact, make `ref`s sugar over processes, and we get no issues at all: we're passing around a pointer to a process! That means that we can also use message-passing/mailbox queueing for state, and not have to deal with atomic updates, etc.

If indeed you want observability of `ref`s (which seems wise, since we're looking at change over time), observability of processes (with reductions), you get that for free if `ref`s are just processes.

