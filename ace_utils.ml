
open Dom_html

(* Bindings des fonctions JS utiles *)

let alert str =
  Dom_html.window##alert(Js.string str)

let console_log str =
  Firebug.console##log(Js.string str)

let console_debug o =
  Firebug.console##debug(o)

let get_element_by_id id =
  Js.Opt.get (document##getElementById (Js.string id))
    (fun () -> assert false)



(* Bindings des fonctions Ace *)

let load_range = ref false

type editSession
type range
type acetoken

let create_edit_session (content: string) : editSession =
  let text = Js.Unsafe.inject (Js.string content) in
  let mode = Js.Unsafe.inject (Js.string "ace/mode/ocaml_ocp") in
  Js.Unsafe.fun_call (Js.Unsafe.variable "ace.createEditSession")
    [| text;mode |]

let change_edit_session (es : editSession) =
  ignore (Js.Unsafe.fun_call (Js.Unsafe.variable "editor.setSession")
	    [| Js.Unsafe.inject es |])

let get_editor_value () =
  let res = Js.Unsafe.fun_call
    (Js.Unsafe.variable
       "editor.getSession().getDocument().getValue")
    [| Js.Unsafe.inject () |] in 
  Js.to_string res

let set_editor_value str =
  ignore (Js.Unsafe.fun_call
	    (Js.Unsafe.variable
	       "editor.getSession().getDocument().setValue")
	    [| Js.Unsafe.inject str |])

let get_line (row: int) : string =
  Js.to_string (Js.Unsafe.fun_call
		  (Js.Unsafe.variable
		     "editor.getSession().getDocument().getLine")
		  [| Js.Unsafe.inject row |])

let get_lines row_start row_end : string =
  let res = Js.to_array (Js.Unsafe.fun_call
			   (Js.Unsafe.variable
			      "editor.getSession().getDocument().getLines")
			   [| Js.Unsafe.inject row_start;
			      Js.Unsafe.inject row_end |]) in
  let res = List.fold_right (fun str acc ->
    let str = Js.to_string str in
    str::acc
  ) (Array.to_list res) [] in
  String.concat "\n" res

let get_tab_size () =
  Js.Unsafe.fun_call
    (Js.Unsafe.variable "editor.getSession().getTabSize") [||]

let make_range startRow startColumn endRow endColumn : range =
  Js.Unsafe.fun_call
    (Js.Unsafe.variable "new Range")
    [| Js.Unsafe.inject startRow ;
       Js.Unsafe.inject startColumn ;
       Js.Unsafe.inject endRow ;
       Js.Unsafe.inject endColumn |]


let replace (range: range) (text: string) : unit =
  ignore (Js.Unsafe.fun_call
	    (Js.Unsafe.variable 
	       "editor.getSession().getDocument().replace")
	    [| Js.Unsafe.inject range ;
	       Js.Unsafe.inject (Js.string text) |])

let get_tokens row : acetoken array =
  Js.to_array (Js.Unsafe.fun_call
		 (Js.Unsafe.variable
		    "editor.getSession().getTokens")
		 [| Js.Unsafe.inject row |])

module AceToken = struct
  type t = acetoken

  let get_value (token: t) : string = 
    Js.to_string (Js.Unsafe.get token "value")

  let get_type (token: t) : string =
    Js.to_string (Js.Unsafe.get token "type")
end
