-- Definition of the Operations on permutations, based on the Vector representation
-- There are 2 sets of definitions here:
-- 1. pure Vector, in which the contents are arbitrary sets
-- 2. specialized to Fin contents.

-- Some notes:
--   - There are operations (such as sequential composition) which 'lift' more
--     awkwardly.
--   - To avoid a proliferation of bad names, we use sub-modules

module VecOps where

open import Data.Nat
open import Data.Vec renaming (map to mapV; _++_ to _++V_; concat to concatV)
open import Data.Fin using (Fin)
open import Function using (_∘_)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Data.Product using (_×_; _,_)

open import TypeEquivalences using (swap₊; swap⋆)
open import VectorLemmas using (_!!_)
open import FinEquiv using (module Plus; module Times)

------------------------------------------------------------------------------
-- Pure vector operations
-- Does not involve Fin at all.
-- Note: not exported!
private
  module V where
    _⊎v_ : ∀ {m n} {A B : Set} → Vec A m → Vec B n → Vec (A ⊎ B) (m + n)
    α ⊎v β = tabulate (inj₁ ∘ _!!_ α) ++V tabulate (inj₂ ∘ _!!_ β)

    swap+ : {m n : ℕ} {A B : Set} → Vec (A ⊎ B) (m + n) → Vec (B ⊎ A) (m + n)
    swap+ v = tabulate (swap₊ ∘ _!!_ v)

    _×v_ : ∀ {m n} {A B : Set} → Vec A m → Vec B n → Vec (A × B) (m * n)
    α ×v β = α >>= (λ b → mapV (_,_ b) β)

    0v : {A : Set} → Vec A 0
    0v = []

------------------------------------------------------------------------------
-- Elementary permutations, Fin version

module F where
  open V

  -- convenient abbreviation
  Cauchy : ℕ → ℕ → Set
  Cauchy m n = Vec (Fin m) n
  
  1C : {n : ℕ} → Cauchy n n
  1C {n} = allFin n

  -- Sequential composition
  _∘̂_ : {n₀ n₁ n₂ : ℕ} → Vec (Fin n₁) n₀ → Vec (Fin n₂) n₁ → Vec (Fin n₂) n₀
  π₁ ∘̂ π₂ = tabulate (_!!_ π₂ ∘ _!!_ π₁)

  -- swap the first m elements with the last n elements
  -- [ v₀ , v₁   , v₂   , ... , vm-1 ,     vm , vm₊₁ , ... , vm+n-1 ]
  -- ==>
  -- [ vm , vm₊₁ , ... , vm+n-1 ,     v₀ , v₁   , v₂   , ... , vm-1 ]

  swap+cauchy : (m n : ℕ) → Cauchy (n + m) (m + n)
  swap+cauchy m n = tabulate (Plus.swapper m n)

  -- Parallel additive composition
  -- append both permutations but adjust the indices in the second
  -- permutation by the size of the first type so that it acts on the
  -- second part of the vector

  _⊎c_ : ∀ {m₁ n₁ m₂ n₂} → Cauchy m₁ m₂ → Cauchy n₁ n₂ → Cauchy (m₁ + n₁) (m₂ + n₂)
  _⊎c_ α β = mapV Plus.fwd (α ⊎v β)

  -- Tensor multiplicative composition
  -- Transpositions in α correspond to swapping entire rows
  -- Transpositions in β correspond to swapping entire columns
  tcompcauchy : ∀ {m₁ n₁ m₂ n₂} → Cauchy m₁ m₂ → Cauchy n₁ n₂ → Cauchy (m₁ * n₁) (m₂ * n₂)
  tcompcauchy {m} {n} α β = mapV Times.fwd (α ×v β)

  -- swap⋆
  -- 
  -- This is essentially the classical problem of in-place matrix transpose:
  -- "http://en.wikipedia.org/wiki/In-place_matrix_transposition"
  -- Given m and n, the desired permutation in Cauchy representation is:
  -- P(i) = m*n-1 if i=m*n-1
  --      = m*i mod m*n-1 otherwise

  -- transposeIndex : {m n : ℕ} → Fin m × Fin n → Fin (n * m)
  -- transposeIndex = Times.fwd ∘ swap
    -- inject≤ (fromℕ (toℕ d * m + toℕ b)) (i*n+k≤m*n d b)

  swap⋆cauchy : (m n : ℕ) → Cauchy (n * m) (m * n)
  swap⋆cauchy m n = tabulate (Times.swapper m n)
    -- mapV transposeIndex (V.tcomp (idcauchy m) (idcauchy n))

module FPf where
  open import FiniteFunctions
  open import VecHelpers using (map!!)
  open import VectorLemmas using (lookupassoc; map-++-commute)
  open import Proofs using (congD!)
  open import Data.Vec.Properties using (lookup-allFin; tabulate∘lookup; lookup∘tabulate; tabulate-∘)
  open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; trans; cong; cong₂; module ≡-Reasoning)
  open F
  open ≡-Reasoning

  -- properties of sequential composition
  ∘̂-assoc : {n : ℕ} → (a b c : Vec (Fin n) n) → a ∘̂ (b ∘̂ c) ≡ (a ∘̂ b) ∘̂ c
  ∘̂-assoc a b c = finext (lookupassoc a b c)

  ∘̂-rid : {n : ℕ} → (π : Vec (Fin n) n) → π ∘̂ F.1C ≡ π
  ∘̂-rid π = trans (finext (λ i → lookup-allFin (π !! i))) (tabulate∘lookup π)

  ∘̂-lid : {n : ℕ} → (π : Vec (Fin n) n) → F.1C ∘̂ π ≡ π
  ∘̂-lid π = trans (finext (λ i → cong (_!!_ π) (lookup-allFin i))) (tabulate∘lookup π)

  !!⇒∘̂ : {n₁ n₂ n₃ : ℕ} → (π₁ : Vec (Fin n₁) n₂) → (π₂ : Vec (Fin n₂) n₃) → (i : Fin n₃) → π₁ !! (π₂ !! i) ≡ (π₂ ∘̂ π₁) !! i
  !!⇒∘̂ π₁ π₂ i = 
    begin (
      π₁ !! (π₂ !! i)
            ≡⟨ sym (lookup∘tabulate (λ j → (π₁ !! (π₂ !! j))) i) ⟩
      tabulate (λ i → π₁ !! (π₂ !! i)) !! i
            ≡⟨ refl ⟩
      (π₂ ∘̂ π₁) !! i ∎)
    where open ≡-Reasoning

{-
  ⊎c-distrib : ∀ {m₁ m₂ m₃ m₄ n₁ n₂} → {p₁ : Cauchy m₁ n₁} → {p₂ : Cauchy m₂ n₂}
    → {p₃ : Cauchy m₃ m₁} → {p₄ : Cauchy m₄ m₂} →
      (p₁ ⊎c p₂) ∘̂ (p₃ ⊎c p₄) ≡ (p₁ ∘̂ p₃) ⊎c (p₂ ∘̂ p₄)
  ⊎c-distrib {m₁} {m₂} {m₃} {m₄} {n₁} {n₂} {p₁} {p₂} {p₃} {p₄} = 
    begin (
      tabulate (λ i → (p₃ ⊎c p₄) !! ((p₁ ⊎c p₂) !! i))
        ≡⟨ {!!} ⟩
      mapV Plus.fwd (tabulate (λ i → inj₁ ((p₁ ∘̂ p₃) !! i))) ++V mapV (Plus.fwd {m₃}) (tabulate (λ i → inj₂ ((p₂ ∘̂ p₄) !! i)))
        ≡⟨ sym (map-++-commute Plus.fwd (tabulate (λ i → inj₁ ((p₁ ∘̂ p₃) !! i)))) ⟩
      mapV Plus.fwd (tabulate (λ i → inj₁ ((p₁ ∘̂ p₃) !! i)) ++V tabulate (λ i → inj₂ ((p₂ ∘̂ p₄) !! i)))
        ≡⟨ refl ⟩
      (p₁ ∘̂ p₃) ⊎c (p₂ ∘̂ p₄) ∎)
-}
