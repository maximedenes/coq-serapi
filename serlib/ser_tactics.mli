(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2016     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(************************************************************************)
(* Coq serialization API/Plugin                                         *)
(* Copyright 2016-2018 MINES ParisTech                                  *)
(************************************************************************)
(* Status: Very Experimental                                            *)
(************************************************************************)

type clear_flag = Tactics.clear_flag

type 'a core_destruction_arg = 'a Tactics.core_destruction_arg
  [@@deriving sexp,yojson,hash,compare]

type 'a destruction_arg = clear_flag * 'a core_destruction_arg
  [@@deriving sexp,yojson,hash,compare]
