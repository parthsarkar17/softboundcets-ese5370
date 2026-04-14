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


Inductive llvm_instruction : Type :=
  | static_alloca (typ_size fp_ofst : nat)
  | bitcast (typ_size : nat)
  | gep (typ_size : nat) (ofst : nat)
  | other.
  
  
Definition flow_rule (insn : llvm_instruction) (operand_alv : alv) : alv :=
  match insn with
  | static_alloca (typ_size) (fp_ofst) => 
      fpoffset fp_ofst fp_ofst (fp_ofst + typ_size) typ_size
  | bitcast (typ_size) =>
      match operand_alv with
      | top => top
      | bottom => bottom
      | fpoffset base ptr bound size =>
          fpoffset base ptr bound typ_size
      end
  | gep (typ_size) (ofst) => 
      match operand_alv with
      | top => top
      | bottom => bottom
      | fpoffset base ptr bound size =>
          fpoffset base (ptr + ofst) bound typ_size
      end
  | other => top
  end.
  
Theorem flow_rules_monotonic : forall insn op1 op2, 
  leq op1 op2 -> leq (flow_rule insn op1) (flow_rule insn op2).
Proof.
  intros insn op1 op2 L.
  destruct insn; inversion L; subst; simpl; auto.
Qed.
