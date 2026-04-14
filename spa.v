From Stdlib Require Import Arith. Import Nat. Import Bool.
From Stdlib Require Import Lia.

(** These are the "abstract lattice values" (ALVs) that each variable will be mapped to during/after the analysis, at each program point. *)
Inductive alv : Type :=
  | top
  | fpoffset (base ptr bound size: nat)
  | bottom.


Inductive leq : alv -> alv -> Prop :=
  | bot_leq_all    :   forall a : alv,   leq bottom a
  | all_leq_top    :   forall a : alv,   leq a top
  | ofst_leq_ofst  :   forall ba p bo s1 s2 : nat, s1 <= s2 -> leq (fpoffset ba p bo s1) (fpoffset ba p bo s2).
  
  
Definition join (a1 a2 : alv) : alv :=
  match a1 with
  | top => top
  | bottom => a2
  | fpoffset ba1 p1 bo1 s1 => match a2 with
    | top => top
    | bottom => a1
    | fpoffset ba2 p2 bo2 s2 => 
        if (ba1 =? ba2) && (p1 =? p2) && (bo1 =? bo2) then
          fpoffset ba1 p1 bo1 (Nat.max s1 s2)
        else top
    end
  end.

Theorem join_commutative : forall a b : alv, join a b = join b a.
Proof.
  intros. destruct a; destruct b; try reflexivity. simpl.
  replace (base =? base0) with (base0 =? base).
  replace (ptr =? ptr0) with (ptr0 =? ptr).
  replace (bound =? bound0) with (bound0 =? bound).
  destruct ((base0 =? base) && (ptr0 =? ptr) && (bound0 =? bound)) eqn:B.
  - destruct (base0 =? base) eqn:B1;
    destruct (ptr0 =? ptr) eqn:B2;
    destruct (bound0 =? bound) eqn:B3; try discriminate.
    + apply Nat.eqb_eq in B1.
      apply Nat.eqb_eq in B2.
      apply Nat.eqb_eq in B3.
      rewrite B1. rewrite B2. rewrite B3.
      replace (max size size0) with (max size0 size).
      { reflexivity. }
      { apply Nat.max_comm. }
  - reflexivity.
  - apply eqb_sym.
  - apply eqb_sym.
  - apply eqb_sym.
Qed.
  
Hint Constructors leq : core.


Theorem join_is_monotonic : forall x y z: alv, 
    (leq x y -> leq (join x z) (join y z))
 /\ (leq y z -> leq (join x y) (join x z)).
Proof.
  intros. split; intros L; inversion L; subst.
  - destruct z; destruct y; simpl; auto.
    destruct ((base0 =? base) && (ptr0 =? ptr) && (bound0 =? bound)) eqn:B; auto.
    destruct (base0 =? base) eqn:B1;
    destruct (ptr0 =? ptr) eqn:B2;
    destruct (bound0 =? bound) eqn:B3; try discriminate.
    apply Nat.eqb_eq in B1.
    apply Nat.eqb_eq in B2.
    apply Nat.eqb_eq in B3.
    rewrite B1. rewrite B2. rewrite B3.
    apply ofst_leq_ofst.
    lia.
   - simpl. auto.
   - destruct z; simpl; auto.
     destruct ((ba =? base) && (p =? ptr) && (bo =? bound)) eqn:B.
     destruct (ba =? base) eqn:B1;
     destruct (p =? ptr) eqn:B2;
     destruct (bo =? bound) eqn:B3; try discriminate.
     + apply ofst_leq_ofst. lia.
     + apply all_leq_top.
   - destruct x; destruct z; simpl; auto.
     destruct ((base =? base0) && (ptr =? ptr0) && (bound =? bound0)) eqn:B; auto.
     apply ofst_leq_ofst. lia.
   - replace (join x top) with (join top x).
     + simpl. auto.
     + destruct x; auto.
   - destruct x; simpl; auto.
     destruct ((base =? ba) && (ptr =? p) && (bound =? bo)) eqn:B; auto.
     apply ofst_leq_ofst. lia.
Qed.
  

(*
(** Assume the following CFG:

            A   B
             \ /
              C
              
  Then, if [[A]](v) = X and [[B]](v) = Y, we need to "merge" X and Y into the least upper bound of the two,
  in order to conduct a conservative analysis, which will then be used as the input to block C. 
  This is what the following join function does.
*) 
Inductive join : alv -> alv -> alv -> Prop :=
  | join_bot_bot :                                    join Bottom Bottom Bottom
  | join_bot_ofst :       forall n : nat,             join Bottom (FPOffset n) (FPOffset n)
  | join_bot_top :                                    join Bottom Top Top
  | join_ofst_bot :       forall n : nat,             join (FPOffset n) Bottom (FPOffset n)
  | join_ofst_ofst_eq :   forall n m : nat, n = m ->  join (FPOffset n) (FPOffset m) (FPOffset m)
  | join_ofst_ofst_neq :  forall n m : nat, n <> m -> join (FPOffset n) (FPOffset m) Top
  | join_ofst_top :       forall n : nat,             join (FPOffset n) Top Top
  | join_top_bot :                                    join Top Bottom Top
  | join_top_ofst :       forall n : nat,             join Top (FPOffset n) Top
  | join_top_top :                                    join Top Top Top.


Hint Constructors leq : core.

Theorem join_func_is_monotonic : forall x y z a b: alv, 
    (leq x y -> join x z a /\ join y z b -> leq a b)
 /\ (leq y z -> join x y a /\ join x z b -> leq a b).
Proof.
  intros. split; intros L J; destruct J as [J1 J2].
    - inversion L; destruct z; subst; inversion J1; inversion J2; subst; auto.  
    - inversion L; destruct x; subst; inversion J1; inversion J2; subst; auto. 
Qed.

(** For the purposes of stack points-to analysis, we need only care about instructions that may produce pointers. Each such instruction falls into one of the following categories. *)
Inductive llvm_instruction : Type :=
  | static_alloca (base_fp_offset : nat)                    (* static alloca insns always have an offset from frame pointer *)
  | bitcast (a : alv)                                       (* the ALV here refers to the ALV mapped to the bitcast's operand variable *)
  | get_element_pointer (base : alv) (base_offset : alv)    (* the ALVs here refer to those mapped to the base and offset variables for the GEP instruction *)
  | other.                                                  (* represents every other instruction that assigns a variable *)
  
(** For each of the pointer-producing instructions, the following propositions specify how the variable being assigned gets its abstract lattice value.

  We can read a proposition of the form `flow_rule insn a b` as: 
    " after performing instruction `v = insn`, the initial mapping v-->a will now be v-->b " 
 *)
Inductive flow_rule : llvm_instruction -> alv -> alv -> Prop :=
  | alloca_rule :             forall (prev : alv) (ofst : nat),               flow_rule (static_alloca ofst) prev (FPOffset ofst)
  | bitcast_rule :            forall (prev bc_operand : alv)   ,              flow_rule (bitcast bc_operand) prev bc_operand
  | gep_rule_both_eq_ofst  :  forall (prev : alv) (base_ofst buf_ofst : nat), 
                                                                              flow_rule (get_element_pointer (FPOffset base_ofst) (FPOffset buf_ofst)) prev (FPOffset (base_ofst + buf_ofst))
  | gep_rule_one_neq_ofst :   forall (prev base_operand buf_operand : alv) (base_ofst buf_ofst : nat), 
                                base_operand <> FPOffset(base_ofst) \/ buf_operand <> FPOffset(buf_ofst) 
                                                                          ->  flow_rule (get_element_pointer base_operand buf_operand) prev Top                                                                  
  | other_rule :              forall (prev : alv),                            flow_rule (other) prev (Top).


Theorem flow_rules_are_monotonic : forall (x y z a b : alv) (insn : llvm_instruction),
    leq x y -> flow_rule insn x a /\ flow_rule insn x b -> leq a b.
Proof.
  intros x y z a b insn L [F1 F2]. destruct insn;
  try (inversion L; inversion F1; inversion F2; subst; auto); 
  destruct b; auto.
Qed.     *)

