{-# OPTIONS --without-K #-}

module SEquivSCPermEquiv where

open import Level        using (Level; zero; _⊔_)
open import Data.Nat     using (ℕ; _+_) 
open import Data.Fin     using (Fin; inject+; raise) 
open import Data.Sum     using (inj₁; inj₂)
open import Data.Product using (_,_; proj₁; proj₂)
open import Data.Vec     using (tabulate) renaming (_++_ to _++V_)
open import Function     using (_∘_; id)

open import Data.Vec.Properties using    (lookup∘tabulate)
open import Relation.Binary     using    (Setoid)
open import Function.Equality   using    (_⇨_; _⟨$⟩_; _⟶_)
                                renaming (_∘_ to _⊚_; id to id⊚)

open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; sym; trans; cong; cong₂; setoid; →-to-⟶;
         module ≡-Reasoning)
     
--

open import Proofs using (finext; _!!_; tabulate-split) 
open import Equiv using (_∼_; module qinv; mkqinv; _≃_)
open import EquivEquiv
open import FinVec using (_∘̂_; 1C)
open import FinVecProperties using (~⇒≡; !!⇒∘̂; 1C!!i≡i; cauchyext)
open import EnumEquiv using (Enum; 0E; _⊕e_; eval-left; eval-right)
open import ConcretePermutation

--

infix 4 _≃S_

------------------------------------------------------------------------------
-- The big (semantic) theorem!

-- On one side we have the setoid of permutations under ≡
-- On the other we have the setoid of equivalences under ≋
-- 
-- The regular equivalence ≃ relates sets. To relate the above two
-- setoids, this regular equivalence is generalized to an equivalence
-- ≃S that relates setoids each with its own equivalence relation.

record _≃S_ {ℓ₁ ℓ₂ ℓ₃ ℓ₄ : Level} (A : Setoid ℓ₁ ℓ₂) (B : Setoid ℓ₃ ℓ₄) : 
  Set (ℓ₁ ⊔ ℓ₂ ⊔ ℓ₃ ⊔ ℓ₄) where
  constructor equiv
  field
    f : A ⟶ B
    g : B ⟶ A
    α : ∀ {x y} → Setoid._≈_ B x y → Setoid._≈_ B ((f ⊚ g) ⟨$⟩ x) y
    β : ∀ {x y} → Setoid._≈_ A x y → Setoid._≈_ A ((g ⊚ f) ⟨$⟩ x) y

-- Big theorem

univalence : ∀ {m n} → (SCPerm m n) ≃S (Fin m S≃ Fin n)
univalence {m} {n} = equiv fwd bwd α β 
  where

    fwd' : (CPerm m n) → (Fin m ≃ Fin n)
    fwd' = {!!} 

    bwd' : (Fin m ≃ Fin n) → (CPerm m n)
    bwd' = {!!} 

    fwd : (SCPerm m n) ⟶ (Fin m S≃ Fin n)
    fwd = record
      { _⟨$⟩_ = fwd'
      ; cong = λ { {π} {.π} refl → {!!} }
      }

    bwd : (Fin m S≃ Fin n) ⟶ (SCPerm m n)
    bwd = record
      { _⟨$⟩_ = bwd'
      ; cong = λ {eq₁} {eq₂} eq₁≋eq₂ → {!!}
      }

    α : {eq₁ eq₂ : Fin m ≃ Fin n} → eq₁ ≋ eq₂ → (fwd ⊚ bwd ⟨$⟩ eq₁) ≋ eq₂
    α {eq₁} {eq₂} eq₁≋eq₂ = {!!} 

    β : {π₁ π₂ : CPerm m n} → π₁ ≡ π₂ → (bwd ⊚ fwd ⟨$⟩ π₁) ≡ π₂
    β {π} {.π} refl = {!!} 

-- Transport lemmas. 


