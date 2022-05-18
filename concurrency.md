# Concurrency in Ludus
## Or, Ludus gets actors (maybe)

Ludus does, for as much as it tries to be as simple as possible, require a concurrency story. Anything that's got some kind of animation requires it. Perhaps more to the point, the idea is that drawing anything to the screen will require scheduling something for later. This isn't necessarily concurrency, but it's close to it.

The models I'm most familiar with are, of course, Javascript's single-threaded event-loop model, with callbacks (and promises, and `async`/`await`). I'd love to avoid the "what colour is your function" problem, and I'd also love to avoid callback hell.

To my mind, that means monadic futures or the actor model.

And I want to avoid monads.

That suggests the actor model.

### What is the actor model?

The actor model comes, approximately, from Erlang; I'm familiar with it from Elixir. (This keeps my inspirations--Logo; Clojure; Elixir--coherent.) An actor (called a process in Erlang/Elixir world) gets its own execution/interpretation context: a call stack and a message queue. It can respond to messages from the outside world, and send messages back out to the outside world. Message passing is, to a first approximation, always asynchronous.

One of the things about the actor model is that it's not only a form of concurrency (and, with immutable data structures, safe parallelism), it's also a method of managing state. (Which, ultimately, is what concurrency is really about anyway.)

In Elixir, you can write a very basic mutable data structure using an actor. From the [Elixir docs](https://elixir-lang.org/getting-started/processes.html#state)

```elixir
defmodule KV do
  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, Map.get(map, key)
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end
```

Translated to Ludus, we'd get something like:

```
fn start () -> spawn loop (#{})

fn loop (hash) -> match receive with {
	(:get, key, caller) -> {
		send key (hash) to caller
		loop (hash)
	}
	(:put, key, value) -> loop (assoc (hash, key, value))
}

let kv = start () & kv is now some process ID

send (:put, :hello, "world") to kv &=> (:put, :hello, "world")

send (:get, :hello, self) to kv &=> (:get, :hello, <PID>)

receive &=> "world"

```

In place of a ref here, interestingly, we get an immutable hashmap, passed as an argument to a recursive function.

There are several special forms/reserved words here. `spawn` creates a new actor in its own separate process, returning its process ID. `receive` blocks until there's a message in the message queue. Note that `loop` is recursive; the idea here is that the expression to match here, `receive`, is blocking. This process is suspended, awaiting a message. `send` is a non-blocking (asynchronous) message to an actor. `self` is a reserved word that resolves to the current process.

Note that `send` is non-blocking; `receive` is blocking. The former, because it is non-blocking, is not a suspend point: the code keeps humming along. The latter is where the actor cedes its execution to the scheduler. (There may well be other "blocking" keywords, like `sleep` or `suspend`.) From these concurrency forms, we can get really complex behaviour.

(NB: to use this specific sort of recursion, you need tail-call optimization; if we don't have that, you can use `loop`/`recur`.)

The trick, from an implementation standpoint, is to make sure that actors/processes are extremely lightweight. That shouldn't be very hard.

The actor model is very close to the ways that Smalltalk works (which, cool); and thus also to the ways that Scheme/SICP and Logo handled object-orientation. 

I think it will also be useful in single-threaded environments, even as a conceptual model--rather than an event-loop model. (In fact, it can be made easily into an event-loop model; and also the Redux-style everything-is-a-reducer model that I also like.)

Finally, it plays very nice with the "crash early & often" approach to error handling.

There are obviously a few sticky details:

* What can you send in messages? Right now, I think _everything_, because _everything_ is immutable (except refs). What about closures?

* What about Elixir's "selective receive"? In Elixir, `receive` is a macro, and that means that the pattern match in a `receive` block behaves a little bit differently than in a normal `match`. I want to avoid special casing, so I'm wondering if we want another reserved word to move a message back into its position in the queue, like `skip`, so you could have your last match clause be `else -> skip` to achieve selective `receive`.

* What other base concurrency forms do we need to make this work? (What can be built with just these basic forms?)

* Should these look like reserved words or functions. Elixir uses function calls, but I think reserved words (like in Go) make sense.

