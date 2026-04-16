From Stdlib Require Import Arith. Import Nat. Import Bool.
From Stdlib Require Import Lia.

Inductive bit : Type :=
  | zero
  | one.
 
Definition xor (b1 b2 : bit) : bit :=
  match b1 with
    | zero => b2
    | one => match b2 with
        | zero => one
        | one => zero
        end
    end.

Theorem xor_sandwich : forall b1 b2 b3, 
  xor (xor (xor b1 b2) b3) b2 = xor b1 b3.
Proof.
  intros. destruct b1; destruct b2; destruct b3; reflexivity.
Qed.


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
  | bitcast (typ_size : nat) (operand_alv : alv)
  | gep (typ_size : nat) (ofst : nat) (operand_alv : alv)
  | other.
  
  
Definition flow_rule (insn : llvm_instruction) : alv :=
  match insn with
  | static_alloca (typ_size) (fp_ofst) => 
      fpoffset fp_ofst fp_ofst (fp_ofst + typ_size) typ_size
  | bitcast (typ_size) (operand_alv) =>
      match operand_alv with
      | top => top
      | bottom => bottom
      | fpoffset base ptr bound size =>
          fpoffset base ptr bound typ_size
      end
  | gep (typ_size) (ofst) (operand_alv) => 
      match operand_alv with
      | top => top
      | bottom => bottom
      | fpoffset base ptr bound size =>
          fpoffset base (ptr + ofst) bound typ_size
      end
  | other => top
  end.
  
Theorem flow_rules_monotonic : 
  forall insn, leq (flow_rule insn) (flow_rule insn).
Proof.
  destruct insn; simpl; auto; 
  destruct operand_alv; simpl; auto.
Qed.
