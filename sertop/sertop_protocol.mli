(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2016     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(************************************************************************)
(* Coq serialization API/Plugin                                         *)
(* Copyright 2016 MINES ParisTech                                       *)
(************************************************************************)
(* Status: Very Experimental                                            *)
(************************************************************************)

(** We provide the public API here for Ocaml clients  *)
open Sexplib

(******************************************************************************)
(* Basic Protocol Objects                                                     *)
(******************************************************************************)
type coq_object =
    CoqString  of string
  | CoqRichpp  of Richpp.richpp
  | CoqRichXml of Richpp.richpp
  | CoqOption  of Goptions.option_state
  | CoqConstr  of Constr.constr
  | CoqExpr    of Constrexpr.constr_expr
  | CoqGoal    of (Constr.constr * (Names.Id.t list * Constr.constr option * Constr.constr) list) Proof.pre_goals

val coq_object_of_sexp : Sexp.t -> coq_object
val sexp_of_coq_object : coq_object -> Sexp.t

(******************************************************************************)
(* Printing Sub-Protocol                                                      *)
(******************************************************************************)

(* no public interface *)

(******************************************************************************)
(* Parsing Sub-Protocol                                                       *)
(******************************************************************************)

(* no public interface *)

(******************************************************************************)
(* Answer Types                                                               *)
(******************************************************************************)

type answer_kind =
    Ack
  | StmInfo of Stateid.t * [`NewTip | `Unfocus of Stateid.t | `Focus of Stm.focus] option
  | ObjList of coq_object list
  | CoqExn  of exn

val sexp_of_answer_kind : answer_kind -> Sexp.t
val answer_kind_of_sexp : Sexp.t -> answer_kind

(******************************************************************************)
(* Control Sub-Protocol                                                       *)
(******************************************************************************)

type control_cmd =
    StmState
  | StmAdd     of Stateid.t * string
  | StmQuery   of Stateid.t * string
  | StmEditAt  of Stateid.t
  | StmObserve of Stateid.t
  | SetOpt     of unit
  | LibAdd     of string list * string * bool
  | Quit

val sexp_of_control_cmd : control_cmd -> Sexp.t
val control_cmd_of_sexp : Sexp.t -> control_cmd

(******************************************************************************)
(* Query Sub-Protocol                                                         *)
(******************************************************************************)

type pp_opt =
  | PpSexp
  | PpStr

val pp_opt_of_sexp : Sexp.t -> pp_opt
val sexp_of_pp_opt : pp_opt -> Sexp.t

type query_limit = int option
val query_limit_of_sexp : Sexp.t -> query_limit
val sexp_of_query_limit : query_limit -> Sexp.t

type query_opt = query_limit * pp_opt
val query_opt_of_sexp : Sexp.t -> query_opt
val sexp_of_query_opt : query_opt -> Sexp.t

(** We would ideally make both query_cmd and coq_object depend on a
  * tag such that query : 'a query -> 'a coq_object.
  *)
type query_cmd =
  | Option of string
  | Search of string
  | Goals

val query_cmd_of_sexp : Sexp.t -> query_cmd
val sexp_of_query_cmd : query_cmd -> Sexp.t

(******************************************************************************)
(* Help                                                                       *)
(******************************************************************************)

(* no public interface *)

(******************************************************************************)
(* Top-Level Commands                                                         *)
(******************************************************************************)

type cmd =
    Control of control_cmd
  | Print   of coq_object
  | Parse   of string
  | Query   of query_opt * query_cmd
  | Help

val cmd_of_sexp : Sexp.t -> cmd
val sexp_of_cmd : cmd -> Sexp.t

type answer =
    Answer    of int * answer_kind
  | Feedback  of Feedback.feedback
  | SexpError of Sexp.t

val sexp_of_answer : answer -> Sexp.t
val answer_of_sexp : Sexp.t -> answer

(******************************************************************************)
(* Global Protocol Options                                                    *)
(******************************************************************************)

type ser_opts = {
  coqlib   : string option;       (* Whether we should load the prelude, and its location *)
  in_chan  : in_channel;          (* Input/Output channels                                *)
  out_chan : out_channel;
  human    : bool;
  print0   : bool;
  lheader  : bool;
}

(******************************************************************************)
(* Input/Output -- Main Loop                                                  *)
(******************************************************************************)

(** [ser_loop opts] main se(xp)r-protocol loop *)
val ser_loop : ser_opts -> unit