& A first set of Ludus examples
& Using the proposed syntax as of Jan. 1, 2022
& One small revision: clause blocks use `with`/`end`
& (`cond` just gets an `end` without `with`)

& Another small revision: `ns`es are explicitly hashes.

& turtle graphics

& * draw a square
& ** first iteration
forward (50)
right (90)
forward (50)
right (90)
forward (50)
right (90)
forward (50)
right (90)

& ** second iteration: repeat block
repeat 4 { forward (50); right (90) }
& or
repeat (4, fn () -> { forward (50); right (90) })

& Thoughts: the syntactic construct allows for the introduction of the idea of a block before functions, which use blocks. And since we can use blocks in assignments, this may be quite useful.

& The function-forward version of this I used in dirty turtle of "a function is how you group code together" isn't actually what you do in Ludus.

& ** third iteration: named function
fn square () -> repeat 4 { forward (50); right (90) }

& ** fourth iteration: size argument
fn square (size) -> repeat 4 { forward (size); right (90) }

& ** fifth iteration: `ngon` plus partial application
fn ngon (sides, size) -> repeat sides {
  forward (size)
  right (div (360, sides))
}

square <- ngon (4, _)

& ** sixth iteration: recursion
fn square (size) -> {
  forward (size)
  right (90)
  if eq (0, heading ())
    then :ok
    else square (size)
}

& * draw a flower
fn arc (angle) -> repeat angle {
  forward (1)
  right (1)
}

fn petal () -> {
  arc (90)
  right (90)
  arc (90)
  right (90)
}

fn flower (petals) -> repeat petals {
  petal ()
  right (div (360, petals))
}

& core libraries
& basic vector math

& we represent a 2D vector as (x as :number, y as :number)

fn add_2d (v1, v2) -> {
  (x1 as :number, y1 as :number) <- v1
  (x2 as :number, y2 as :number) <- v2
  (add (x1, x2), add (y1, y2))
}

fn mult_2d (scalar as :number, vector) -> {
  (x as :number, y as :number) <- vector
  (mult (scalar, x), mult (scalar, y))
}

ns Vector #{
  :add add_2d
  :mult mult_2d
}

& algorithms
& * reduce

fn reduce with
  (f, []) -> f ()
  (f, [first]) -> f (head)
  (f, [first, second, ...rest]) -> {
    & we can't just pass this along since we may get a :stop from the first application of the reducing function
    result <- f (first, second)
    match result with
      (:stop, value) -> value
      else -> reduce (f, rest, result)
    end
  }
  (f, [], acc) -> acc
  (f, [first, ...rest], acc) -> {
    result <- f (acc, first)
    & we want to be able to stop a reduction
    match result with
      (:stop, value) -> value
      else -> reduce (f, rest, result)
    end
  }
end

& lisp list operations

& we represent a list as nested tuples

fn cons with
  (item) -> (item, nil)
  (item, llist) -> (item, llist)
end

fn car with
  (nil) -> nil
  ((item, _)) -> item
end

fn cdr with
  (nil) -> nil
  ((_, llist)) -> llist
end

& a list
cons (1, cons (2, cons (3))) &=> (1, (2, (3, nil)))

fn each with
  (nil) -> :ok
  ((item, llist)) -> {
    f (item)
    each (f, llist)
  }
end

fn map with
  (f, nil) -> nil
  (f, (item, llist)) -> cons (f (item), map (llist))
end

fn reduce with
  (f, nil, acc) -> acc
  (f, (head, tail), acc) -> reduce (f, tail, f (acc, head))
end