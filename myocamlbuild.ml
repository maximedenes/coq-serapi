open Ocamlbuild_plugin

let p s = "/home/egallego/external/coq-git/" ^ s

let () =
  dispatch begin function
    | After_rules ->
      ocaml_lib ~extern:true ~dir:(p "lib")     "clib";
      ocaml_lib ~extern:true ~dir:(p "lib")     "lib";
      ocaml_lib ~extern:true ~dir:(p "library") "library";
      ocaml_lib ~extern:true ~dir:(p "kernel")  "kernel";
      ocaml_lib ~extern:true ~dir:(p "intf")    "intf";
      ocaml_lib ~extern:true ~dir:(p "parsing") "parsing";
    | _ -> ()
  end


