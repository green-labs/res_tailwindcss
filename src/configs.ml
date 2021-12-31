open Core

(* default tailwindcss path *)
let tailwindcss_path = ref "./tailwind.css"
let set_tailwindcss_path path = tailwindcss_path := path
let get_tailwindcss_path () = tailwindcss_path
