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

open Sexplib
open Ser_names

type coq_constr =
  | Rel       of int
  | Var       of id
  | Meta      of int
  | Evar      of int * coq_constr array
  | Sort      of Ser_sorts.sort
  | Cast      of coq_constr *  (* C.cast_kind * *) coq_types
  | Prod      of name * coq_types * coq_types
  | Lambda    of name * coq_types * coq_constr
  | LetIn     of name * coq_constr * coq_types * coq_constr
  | App       of coq_constr * coq_constr array
  | Const     of constant
  | Ind       of mutind
  | Construct of mutind
  | Case      of (* C.case_info *  *) coq_constr * coq_constr * coq_constr array
  | Fix       of string        (* XXX: I'm lazy *)
  | CoFix     of string        (* XXX: I'm lazy *)
  | Proj      of projection * coq_constr
and coq_types = coq_constr

val coq_constr_of_sexp : Sexp.t -> coq_types
val sexp_of_coq_constr : coq_types -> Sexp.t

val coq_types_of_sexp : Sexp.t -> coq_types
val sexp_of_coq_types : coq_types -> Sexp.t

val constr_reify : Constr.constr -> coq_types