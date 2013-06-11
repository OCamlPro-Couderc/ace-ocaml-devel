module Words = Set.Make(String)

let words = ref Words.empty


type env =
    { mutable actual : Words.t;
      parent : env }

let completions = ref (Array.make 0 "")
let actual_index = ref 0

let rec glob_env = 
  { actual = Words.empty;
    parent = glob_env }

let actual_env = ref glob_env

let new_block env = 
  { actual = Words.empty; parent = env }

let end_block env =
  env.parent
  
let begin_block () =
  actual_env := new_block !actual_env

let close_block () =
  actual_env := end_block !actual_env

let new_word w =
  !actual_env.actual <- Words.add w !actual_env.actual
