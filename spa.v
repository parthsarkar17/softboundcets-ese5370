From Stdlib Require Import Arith. Import Nat.

Inductive alv : Type :=
  | Top
  | FPOffset(n : nat)
  | Bottom.

Inductive leq : alv -> alv -> Prop :=
  | bot_leq_bot : leq Bottom Bottom
  | bot_leq_ofst : forall n : nat, leq Top (FPOffset n)
  | bot_leq_top : leq Bottom Top
  | ofst_leq_ofst : forall n m : nat, leq (FPOffset n) (FPOffset m)
  | ofst_leq_top : forall n : nat, leq (FPOffset n) Top
  | top_leq_top : leq Top Top.

Inductive join : alv -> alv -> alv -> Prop :=
  | join_bot_bot : join Bottom Bottom Bottom
  | join_bot_ofst : forall n : nat, join Bottom (FPOffset n) (FPOffset n)
  | join_bot_top : join Bottom Top Top
  | join_ofst_bot : forall n : nat, join (FPOffset n) Bottom (FPOffset n)
  | join_ofst_ofst_eq : forall n m : nat, n = m -> join (FPOffset n) (FPOffset m) (FPOffset m)
  | join_ofst_ofst_neq : forall n m : nat, n <> m -> join (FPOffset n) (FPOffset m) Top
  | join_ofst_top : forall n : nat, join (FPOffset n) Top Top
  | join_top_bot : join Top Bottom Top
  | join_top_ofst : forall n : nat, join Top (FPOffset n) Top
  | join_top_top : join Top Top Top.


Theorem join_monotonic : forall x y z a b: alv, 
    (leq x y -> join x z a /\ join y z b -> leq a b)
 /\ (leq y z -> join x y a /\ join x z b -> leq a b).
Proof.
Admitted.

