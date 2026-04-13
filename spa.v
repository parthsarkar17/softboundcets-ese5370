From Stdlib Require Import Arith. Import Nat.

(** These are the "abstract lattice values" (ALVs) that each variable will be mapped to during/after the analysis, at each program point. *)
Inductive alv : Type :=
  | Top
  | FPOffset(n : nat)
  | Bottom.

(** We need to specify an ordering on the abstract values that each variable `v` can take on during execution. 
  Fundamentally, this ordering represents how specific our analysis can be, without losing correctness.
  In particular, `leq x y` if and only if the abstract value `x` tells us MORE information than `y`.
  As a concrete example, it is better (i.e. the analysis tells us more) if a variable `v` maps to a particular offset
  from the stack, versus if where `v` points to cannot be determined (TOP). Similarly, `v --> BOTTOM` is extremely desirable
  because it means we can assume anything we want about where `v` points to. If the analysis is implemented correctly, however,
  this mapping is sadly unlikely to arise in practice.
*)
Inductive leq : alv -> alv -> Prop :=
  | bot_leq_bot :                     leq Bottom Bottom
  | bot_leq_ofst :  forall n : nat,   leq Top (FPOffset n)
  | bot_leq_top :                     leq Bottom Top
  | ofst_leq_ofst : forall n m : nat, leq (FPOffset n) (FPOffset m)
  | ofst_leq_top :  forall n : nat,   leq (FPOffset n) Top
  | top_leq_top :                     leq Top Top.

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

(** For the purposes of stack points-to analysis, we need only care about instructions that produce pointers. This is the exhaustive list. *)
Inductive llvm_instruction : Type :=
  | alloca (base_fp_offset : nat)
  | bitcast
  | get_element_pointer (base_fp_offset : nat) (offset_into_buffer : nat)
  | other.

(** For each of the pointer-producing instructions, the following propositions specify how the variable being assigned gets its abstract lattice value *)
Inductive flow_rule : llvm_instruction -> alv -> alv -> Prop :=
  | alloca_rule :              forall (a : alv) (ofst : nat),      flow_rule (alloca ofst) a (FPOffset ofst)
  | bitcast_rule :             forall (a : alv),                   flow_rule bitcast a a
  | get_element_pointer_rule : forall (a : alv) (base buf : nat),  flow_rule (get_element_pointer base buf) a (FPOffset (base + buf))
  | other_rule :               forall (a : alv),                   flow_rule (other) a (Top).

Theorem flow_rules_are_monotonic : forall (x y z a b : alv) (insn : llvm_instruction),
    leq x y -> flow_rule insn x a /\ flow_rule insn x b -> leq a b.
Proof.
  intros x y z a b insn L [F1 F2]. 
  destruct insn; inversion L; inversion F1; inversion F2; subst; auto.
Qed.     

