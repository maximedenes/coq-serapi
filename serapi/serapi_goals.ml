(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *   INRIA, CNRS and contributors - Copyright 1999-2018       *)
(* <O___,, *       (see CREDITS file for the list of authors)           *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(************************************************************************)
(* Coq serialization API/Plugin                                         *)
(* Copyright 2016-2018 MINES ParisTech -- Dual License LGPL 2.1 / GPL3+ *)
(* Written by: Emilio J. Gallego Arias                                  *)
(************************************************************************)
(* Status: Very Experimental                                            *)
(************************************************************************)

type 'a hyp = (Names.Id.t list * 'a option * 'a)
type info =
  { evar : Evar.t
  ; name : Names.Id.t option
  }
type 'a reified_goal =
  { info : info
  ; ty   : 'a
  ; hyp  : 'a hyp list
  }

type 'a ser_goals =
  { goals : 'a list
  ; stack : ('a list * 'a list) list
  ; bullet : Pp.t option
  ; shelf : 'a list
  ; given_up : 'a list
  }

(** XXX: Do we need to perform evar normalization? *)

module CDC = Context.Compacted.Declaration
type cdcl = Constr.compacted_declaration

let to_tuple ppx : cdcl -> (Names.Id.t list * 'pc option * 'pc) =
  let open CDC in function
    | LocalAssum(idl, tm)   -> (List.map Context.binder_name idl, None, ppx tm)
    | LocalDef(idl,tdef,tm) -> (List.map Context.binder_name idl, Some (ppx tdef), ppx tm)

(** gets a hypothesis *)
let get_hyp (ppx : Constr.t -> 'pc)
    (_sigma : Evd.evar_map)
    (hdecl : cdcl) : (Names.Id.t list * 'pc option * 'pc) =
  to_tuple ppx hdecl

(** gets the constr associated to the type of the current goal *)
let get_goal_type (ppx : Constr.t -> 'pc)
    (sigma : Evd.evar_map)
    (g : Evar.t) : _ =
  ppx @@ EConstr.to_constr ~abort_on_undefined_evars:false sigma Evd.(evar_concl (find sigma g))

let build_info sigma g =
  { evar = g
  ; name = Evd.evar_ident g sigma
  }

(** Generic processor  *)
let process_goal_gen ppx sigma g : 'a reified_goal =
  (* XXX This looks cumbersome *)
  let env = Global.env () in
  let evi = Evd.find sigma g in
  let env = Evd.evar_filtered_env env evi in
  (* why is compaction neccesary... ? [eg for better display] *)
  let ctx       = Termops.compact_named_context (Environ.named_context env) in
  let ppx       = ppx env sigma                                             in
  let hyp       = List.map (get_hyp ppx sigma) ctx                          in
  let info      = build_info sigma g                                        in
  { info; ty = get_goal_type ppx sigma g; hyp }

let if_not_empty (pp : Pp.t) = if Pp.(repr pp = Ppcmd_empty) then None else Some pp

let get_goals_gen (ppx : Environ.env -> Evd.evar_map -> Constr.t -> 'a) ~doc sid
  : 'a reified_goal ser_goals option =
  match Stm.state_of_id ~doc sid with
  | Valid (Some { Vernacstate.lemmas = Some lemmas ; _ } ) ->
    let proof = Vernacstate.LemmaStack.with_top lemmas
        ~f:(fun pstate -> Declare.Proof.get pstate) in
    let { Proof.goals; stack; sigma; _ } = Proof.data proof in
    let ppx = List.map (process_goal_gen ppx sigma) in
    Some
      { goals = ppx goals
      ; stack = List.map (fun (g1,g2) -> ppx g1, ppx g2) stack
      ; bullet = if_not_empty @@ Proof_bullet.suggest proof
      ; shelf = Evd.shelf sigma |> ppx
      ; given_up = Evd.given_up sigma |> Evar.Set.elements |> ppx
      }
  | Expired | Error _ | Valid _ -> None

let get_goals  = get_goals_gen (fun _ _ x -> x)
let get_egoals = get_goals_gen (fun env evd ec -> Constrextern.extern_constr ~inctx:true env evd EConstr.(of_constr ec))
