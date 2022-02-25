& A first set of Ludus examples
& Using a revised syntax as of Jan. 1, 2022
& Replace {} for blocks with `do`/`end`
& This has the nice effect of distinguishing between blocks of clauses vs. blocks of expressions
& Also this allows for hashmaps to be {}, not #{}
& Multiple expressions on a single line are kludgy

& Replace = with =

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
repeat 4 do forward (50); right (90) end
& or
repeat (4, fn () -> do forward (50); right (90) end)

& Thoughts: the syntactic construct allows for the introduction of the idea of a block before functions, which use blocks. And since we can use blocks in assignments, this may be quite useful.

& The function-forward version of this I used in dirty turtle of "a function is how you group code together" isn't actually what you do in Ludus.

& ** third iteration: named function
fn square () -> repeat 4 do forward (50); right (90) end

& ** fourth iteration: size argument
fn square (size) -> repeat 4 do forward (size); right (90) end

& ** fifth iteration: `ngon` plus partial application
fn ngon (sides, size) -> repeat sides do
  forward (size)
  right (div (360, sides))
end

fn square (size) -> ngon (4, size)
& or
square = ngon (4, _)

& ** sixth iteration: recursion
fn square (size) -> do
  forward (size)
  right (90)
  if eq (0, heading ())
    then :ok
    else square (size)
end

& * draw a flower
fn arc (angle) -> repeat angle do
  forward (1)
  right (1)
end

fn petal () -> do
  arc (90)
  right (90)
  arc (90)
  right (90)
end

fn flower (petals) -> repeat petals do
  petal ()
  right (div (360, petals))
end

& core libraries
& basic vector math

& we represent a 2D vector as (x as :number, y as :number)

fn add_2d (v1, v2) -> do
  let (x1 as :number, y1 as :number) = v1
  let (x2 as :number, y2 as :number) = v2
  (add (x1, x2), add (y1, y2))
end

fn mult_2d (scalar as :number, vector) -> do
  let (x as :number, y as :number) = vector
  (mult (scalar, x), mult (scalar, y))
end

ns Vector
  :add add_2d
  :mult mult_2d
end

& algorithms
& * reduce

fn reduce with
  (f, []) -> f ()
  (f, [first]) -> f (head)
  (f, [first, second, ...rest]) -> do
    & we can't just pass this along since we may get a :stop from the first application of the reducing function
    let result = f (first, second)
    match result with
      (:stop, value) -> value
      else -> reduce (f, rest, result)
    end
  end
  (f, [], acc) -> acc
  (f, [first, ...rest], acc) -> do
    let result = f (acc, first)
    & we want to be able to stop a reduction
    match result with
      (:stop, value) -> value
      else -> reduce (f, rest, result)
    end
  end
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

& list conj; assumes no conflict
fn conj with
  (llist) -> llist
  (llist, item) -> cons (llist, item)
end

fn list_to_llist with
  ([]) -> nil
  ([head, ...tail]) -> reduce (conj, tail, cons (head))
end

fn each with
  (nil) -> :ok
  ((item, llist)) -> do
    f (item)
    each (f, llist)
  end
end

fn map with
  (f, nil) -> nil
  (f, (item, llist)) -> cons (f (item), map (llist))
end

fn reduce with
  (f, nil, acc) -> acc
  (f, (head, tail), acc) -> reduce (f, tail, f (acc, head))
end

let count_to_3 = gen (0) into 
  (current) -> do
    yield current
    recur (inc (current))
  end

fn seq with
  (h as :hashmap) -> seq (list (h))
  (s as :set) -> seq (list (s))
  (s as :string) -> seq (list (s))
  (l as :list) -> gen (l) with
    ([]) -> nil
    ([first, ...rest]) -> do
      yield first
      recur (rest)
    end
  end
end

loop (0) into (n) -> do
  print (n)
  recur (inc (n))
end
