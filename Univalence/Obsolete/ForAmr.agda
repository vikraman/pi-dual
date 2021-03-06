{-# OPTIONS --without-K #-}

module ForAmr where

open import Level using (Level)

open import Relation.Nullary.Core
open import Data.Vec
  using (Vec; tabulate; []; _∷_; lookup; allFin)
  renaming (_++_ to _++V_; map to mapV; concat to concatV)
open import  Data.Vec.Properties
  using (lookup-++-≥; lookup∘tabulate; tabulate-∘; tabulate∘lookup; map-cong)
open import Function using (id;_∘_)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; sym; cong; cong₂; subst; proof-irrelevance;
             _≗_; module ≡-Reasoning)
open import Data.Nat using (ℕ; zero; suc; _+_; z≤n; _≟_)
open import Data.Nat.Properties.Simple using (+-comm)
open import Data.Nat.Properties using (m≤m+n)
open import Data.Fin using (Fin; zero; suc; inject+; raise; reduce≥; toℕ; fromℕ≤)
open import Data.Fin.Properties using (toℕ-injective; toℕ-raise; toℕ-fromℕ≤)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Data.Product using (proj₁)
open import Function using (flip)

open import Proofs
open import Equiv
open import FinEquiv
open import Cauchy
open import TypeEquiv using (swap₊; swapswap₊)

----------------------------------------------------

-- and now this is completely obvious.  But not actually needed!
swap+-idemp : {A B : Set} → {m n : ℕ} → (v : Vec (A ⊎ B) (m + n)) →
  swap+ {m} (swap+ {m} v) ≡ v
swap+-idemp v = 
  begin ( 
    tabulate (λ i → swap₊ (tabulate (λ j → swap₊ (v !! j)) !! i))
        ≡⟨ denest-tab-!! swap₊ swap₊ v ⟩
    mapV (swap₊ ∘ swap₊) v
        ≡⟨ map-cong swapswap₊ v ⟩
    mapV id v
        ≡⟨ map-id v ⟩
    v ∎) 
  where open ≡-Reasoning

-- because this is 'pointwise', no need for swap+-idemp.
pointwise-swap+v-idemp : {m n : ℕ} → ∀ i → 
  lookup (lookup i (swap+v m n)) (swap+v n m) ≡ i
pointwise-swap+v-idemp {m} {n} i = 
  let fnm = swapper n m in
  let fmn = swapper m n in
  begin (
    lookup (lookup i (swap+v m n)) (swap+v n m)
      ≡⟨ cong (λ x → lookup x (swap+v n m)) (lookup∘tabulate fmn i) ⟩
    lookup (fmn i) (swap+v n m)
      ≡⟨ lookup∘tabulate fnm (fmn i) ⟩
    fnm (fmn i) -- bingo!
      ≡⟨ cong (fwd ∘ swap₊) (bwd∘fwd~id (swap₊ (bwd {m} i))) ⟩
    fwd (swap₊ (swap₊ (bwd {m} i)))
      ≡⟨ cong fwd (swapswap₊ (bwd {m} i)) ⟩
    fwd (bwd {m} i)
      ≡⟨ fwd∘bwd~id {m} i ⟩
    i ∎ )
  where open ≡-Reasoning

-- this is true, but the above is what is used in practice.
swap+v-idemp : {m n : ℕ} →
  tabulate (λ i → lookup (lookup i (swap+v m n)) (swap+v n m)) ≡ tabulate id
swap+v-idemp {m} = finext (pointwise-swap+v-idemp {m})

---------------------------------------------------------------
-- Everything below here is based on Cauchy as Vec (Fin n) n
-- and might get tossed.  Comment it out for now.

{-
-- the Cauchy version.
swap+c : (m n : ℕ) → Cauchy (m + n)
swap+c m n = subst (λ x → Vec (Fin x) (m + n)) (+-comm n m) (swap+v m n)

-- the action of subst on swap+, pointwise
switch-swap+ : {m n : ℕ} → (i : Fin (m + n)) →
  subst Fin (+-comm n m) (swapper m n i) ≡ 
  swapper n m (subst Fin (+-comm m n) i)
switch-swap+ {m} {n} i with m ≟ n
switch-swap+ i | yes p = {!!}
switch-swap+ i | no ¬p = {!!}
{-
switch-swap+ {m} {n} i with (toℕ i <? m) | (toℕ (subst Fin (+-comm m n) i) <? n) 
switch-swap+ {m} {n} i | yes p | yes q = {!!} {- toℕ-injective (
  begin (
    toℕ (subst Fin (+-comm n m) (raise n (fromℕ≤ p)))
      ≡⟨ toℕ-invariance (raise n (fromℕ≤ p)) (+-comm n m) ⟩
    toℕ (raise n (fromℕ≤ p))
      ≡⟨ toℕ-raise n (fromℕ≤ p) ⟩
    n + toℕ (fromℕ≤ p)
      ≡⟨ cong (_+_ n) (toℕ-fromℕ≤ p) ⟩
    n + toℕ i
      ≡⟨ {!!} ⟩
    m + toℕ (subst Fin (+-comm m n) i)
      ≡⟨ sym (cong (_+_ m) (toℕ-fromℕ≤ q)) ⟩
    m + toℕ (fromℕ≤ q)
      ≡⟨ sym (toℕ-raise m (fromℕ≤ q)) ⟩
    toℕ (raise m (fromℕ≤ q)) ∎))
  where open ≡-Reasoning -}
switch-swap+ i | yes p | no ¬q = {!!}
switch-swap+ i | no ¬p | yes q = {!!}
switch-swap+ i | no ¬p | no ¬q = {!!}
-}

-- the Cauchy version:
pcomp' : ∀ {m n} → Cauchy m → Cauchy n → Cauchy (m + n)
pcomp' α β = mapV fwd (pcomp α β)

-- the action of subst on swap+v
switch-swap : {m n : ℕ} → (i : Fin (m + n)) →
  subst Fin (+-comm n m) ((swap+v m n) !! i) ≡
  (swap+v n m) !! subst Fin (+-comm m n) i
switch-swap {m} {n} i = 
  let fnm = swapper n m in
  let fmn = swapper m n in
  begin (
    subst Fin (+-comm n m) ((tabulate fmn) !! i)
      ≡⟨ cong (subst Fin (+-comm n m)) (lookup∘tabulate fmn i) ⟩
    subst Fin (+-comm n m) (fmn i)
      ≡⟨ switch-swap+ {m} i ⟩
    fnm (subst Fin (+-comm m n) i)
      ≡⟨ sym (lookup∘tabulate fnm (subst Fin (+-comm m n) i)) ⟩
    tabulate (fnm) !! subst Fin (+-comm m n) i ∎)
  where open ≡-Reasoning

-- the crucial part for the next theorem:
swap+-idemp' : {m n : ℕ} → ∀ (i : Fin (m + n)) → lookup
      (subst (λ x → Vec (Fin x) (m + n)) (+-comm n m) (swap+v m n) !! i)
      (subst (λ x → Vec (Fin x) (m + n)) (+-comm n m) (swap+v m n))
      ≡ i
swap+-idemp' {m} {n} i = 
  let j = subst (λ x → Vec (Fin x) (m + n)) (+-comm n m) (swap+v m n) !! i in
  begin (
    lookup j (subst (λ x → Vec (Fin x) (m + n)) (+-comm n m) (swap+v m n))
      ≡⟨ lookup-subst j (swap+v m n) (+-comm n m) ⟩
    subst Fin (+-comm n m) ((swap+v m n) !! j)
      ≡⟨ cong (λ x → subst Fin (+-comm n m) ((swap+v m n) !! x)) 
                   (lookup-subst i (swap+v m n) (+-comm n m)) ⟩
    subst Fin (+-comm n m) ((swap+v m n) !! subst Fin (+-comm n m) (swap+v m n !! i))
      ≡⟨ cong (λ x → subst Fin (+-comm n m) ((swap+v m n) !! x))
                   (switch-swap {m} i) ⟩
    subst Fin (+-comm n m) ((swap+v m n) !! (swap+v n m !! subst Fin (+-comm m n) i))
      ≡⟨ cong (subst Fin (+-comm n m)) (pointwise-swap+v-idemp {n} (subst Fin (+-comm m n) i)) ⟩
    subst Fin (+-comm n m) (subst Fin (+-comm m n) i)
      ≡⟨ subst-subst (+-comm n m) (+-comm m n) 
                              (proof-irrelevance (sym (+-comm n m)) (+-comm m n)) i ⟩
    i ∎)
  where open ≡-Reasoning

-- and let's see what that does to the Cauchy version:
swap+c-idemp : {m n : ℕ} → scompcauchy (swap+c m n) (swap+c m n) ≡ allFin (m + n)
swap+c-idemp  {m} {n} = finext (swap+-idemp' {m} {n})
-}
