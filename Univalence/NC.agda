-- {-# OPTIONS --without-K #-}
{-# OPTIONS --no-termination-check #-}
-- XXX: rewrite evalcomb in a way that agda can check

module NC where

open import Data.Empty
open import Data.Unit
open import Data.Nat renaming (_⊔_ to _⊔ℕ_)
open import Data.Sum renaming (map to _⊎→_)
open import Data.Product
import Data.Fin as F
open import Data.Vec
import Data.List as L
open import Function renaming (_∘_ to _○_)


open import FT
open import FT-Nat
open import HoTT using (refl; pathInd; _≡_; ap)
open import Equivalences
open import TypeEquivalences using (path⊎)
open import Path2Equiv
open import LeftCancellation
open import Simplify

fromNormalNat : (n : ℕ) → ⟦ n ⟧ℕ → F.Fin n
fromNormalNat zero ()
fromNormalNat (suc n) (inj₁ tt) = F.zero
fromNormalNat (suc n) (inj₂ x) = F.suc (fromNormalNat n x)

toNormalNat : (n : ℕ) → F.Fin n → ⟦ n ⟧ℕ
toNormalNat zero ()
toNormalNat (suc n) F.zero = inj₁ tt
toNormalNat (suc n) (F.suc f) = inj₂ (toNormalNat n f)

equivToVec : {n : ℕ} → ⟦ n ⟧ℕ ≃ ⟦ n ⟧ℕ → Vec (F.Fin n) n
equivToVec {n} (f , _) = tabulate ((fromNormalNat n) ○ f ○ (toNormalNat n))

-- TODO: vecToEquiv needs an extra proof that the vector is in fact "normal" in order
-- to define it correctly
-- Or we could just only use indices i such that vec[i] > i, like in vecToComb...should work
--
--vecToEquiv : {n : ℕ} → Vec (F.Fin n) n → ⟦ n ⟧ℕ ≃ ⟦ n ⟧ℕ
--vecToEquiv = {!!}

swapi : {n : ℕ} → F.Fin n → (fromℕ (suc n)) ⇛ (fromℕ (suc n))
swapi {zero} ()
swapi {suc n} F.zero = assocl₊⇛ ◎ swap₊⇛ ⊕ id⇛ ◎ assocr₊⇛
swapi {suc n} (F.suc i) = id⇛ ⊕ swapi {n} i

-- swapUpTo i permutes the combinator left by one up to i
-- if possible values are X a b c Y d e, swapUpTo 3's possible outputs are a b c X Y d e
swapUpTo : {n : ℕ} → F.Fin n → (fromℕ (suc n)) ⇛ (fromℕ (suc n))
swapUpTo F.zero = id⇛
swapUpTo (F.suc i) = swapi F.zero ◎ id⇛ ⊕ swapUpTo i

-- swapDownFrom i permutes the combinator right by one up to i (the reverse of swapUpTo)
swapDownFrom : {n : ℕ} → F.Fin n → (fromℕ (suc n)) ⇛ (fromℕ (suc n))
swapDownFrom F.zero = id⇛
swapDownFrom (F.suc i) = id⇛ ⊕ swapUpTo i ◎ swapi F.zero  

-- TODO: verify that this is actually correct
-- Idea: To swap n < m with each other, swap n, n + 1, ... , m - 1, m, then go back down, so that m and n are swapped and everything else is in the same spot
swapmn : {lim : ℕ} → (m : F.Fin lim) → F.Fin′ m → (fromℕ lim) ⇛ (fromℕ lim)
swapmn F.zero ()
swapmn (F.suc m) (F.zero) = swapUpTo m ◎ swapi m ◎ swapDownFrom m
swapmn (F.suc m) (F.suc n) = id⇛ ⊕ swapmn m n

-- makeSingleComb {combinator size} (arrayElement) (arrayIndex)
makeSingleComb : {n : ℕ} → F.Fin n → F.Fin n → (fromℕ n) ⇛ (fromℕ n)
makeSingleComb j i with F.compare i j
makeSingleComb .j .(F.inject i) | F.less j i = swapmn j i
makeSingleComb j i | _ = id⇛

-- upTo n returns [0, 1, ..., n-1] as Fins
upTo : (n : ℕ) → Vec (F.Fin n) n
upTo n = tabulate {n} id

vecToComb : {n : ℕ} → Vec (F.Fin n) n → (fromℕ n) ⇛ (fromℕ n)
vecToComb {n} vec = foldr (λ i → fromℕ n ⇛ fromℕ n) _◎_ id⇛ (zipWith makeSingleComb vec (upTo n))

evalComb : {a b : FT} → a ⇛ b → ⟦ a ⟧ → ⟦ b ⟧
evalComb unite₊⇛ (inj₁ ())
evalComb unite₊⇛ (inj₂ y) = y
evalComb uniti₊⇛ v = inj₂ v
evalComb swap₊⇛ (inj₁ x) = inj₂ x
evalComb swap₊⇛ (inj₂ y) = inj₁ y
evalComb assocl₊⇛ (inj₁ x) = inj₁ (inj₁ x)
evalComb assocl₊⇛ (inj₂ (inj₁ x)) = inj₁ (inj₂ x)
evalComb assocl₊⇛ (inj₂ (inj₂ y)) = inj₂ y
evalComb assocr₊⇛ (inj₁ (inj₁ x)) = inj₁ x
evalComb assocr₊⇛ (inj₁ (inj₂ y)) = inj₂ (inj₁ y)
evalComb assocr₊⇛ (inj₂ y) = inj₂ (inj₂ y)
evalComb unite⋆⇛ (tt , proj₂) = proj₂
evalComb uniti⋆⇛ v = tt , v
evalComb swap⋆⇛ (proj₁ , proj₂) = proj₂ , proj₁
evalComb assocl⋆⇛ (proj₁ , proj₂ , proj₃) = (proj₁ , proj₂) , proj₃
evalComb assocr⋆⇛ ((proj₁ , proj₂) , proj₃) = proj₁ , proj₂ , proj₃
evalComb distz⇛ (() , proj₂)
evalComb factorz⇛ ()
evalComb dist⇛ (inj₁ x , proj₂) = inj₁ (x , proj₂)
evalComb dist⇛ (inj₂ y , proj₂) = inj₂ (y , proj₂)
evalComb factor⇛ (inj₁ (proj₁ , proj₂)) = inj₁ proj₁ , proj₂
evalComb factor⇛ (inj₂ (proj₁ , proj₂)) = inj₂ proj₁ , proj₂
evalComb id⇛ v = v
evalComb (sym⇛ c) v = evalComb (Simplify.flip c) v -- TODO: use a backwards interpreter
evalComb (c ◎ c₁) v = evalComb c₁ (evalComb c v)
evalComb (c ⊕ c₁) (inj₁ x) = inj₁ (evalComb c x)
evalComb (c ⊕ c₁) (inj₂ y) = inj₂ (evalComb c₁ y)
evalComb (c ⊗ c₁) (proj₁ , proj₂) = evalComb c proj₁ , evalComb c₁ proj₂

finToVal : {n : ℕ} → F.Fin n → ⟦ fromℕ n ⟧
finToVal F.zero = inj₁ tt
finToVal (F.suc n) = inj₂ (finToVal n)

valToFin : {n : ℕ} → ⟦ fromℕ n ⟧ → F.Fin n
valToFin {zero} ()
valToFin {suc n} (inj₁ tt) = F.zero
valToFin {suc n} (inj₂ v) = F.suc (valToFin v)

combToVec : {n : ℕ} → (fromℕ n) ⇛ (fromℕ n) → Vec (F.Fin n) n
combToVec c = tabulate (valToFin ○ (evalComb c) ○ finToVal)

evalVec : {n : ℕ} → Vec (F.Fin n) n → F.Fin n → ⟦ fromℕ n ⟧
evalVec vec i = finToVal (lookup i vec)



-- Testing

z : ∀ {n} → F.Fin (suc n)
z = F.zero

o : ∀ {n} → F.Fin (suc (suc n))
o = F.suc z

t : ∀ {n} → F.Fin (suc (suc (suc n)))
t = F.suc o

test = simplify (vecToComb {3} (o ∷ t ∷ z ∷ []))

{--
-- show that all combinators 1 -> 1 simplify to id
lemma : (c : ONE ⇛ ONE) → simplify c ≡ id⇛
lemma id⇛ = refl id⇛
lemma (sym⇛ c) = ap Simplify.flip (lemma c)
lemma (uniti₊⇛ ◎ unite₊⇛) = refl id⇛
lemma (uniti₊⇛ ◎ sym⇛ uniti₊⇛) = refl id⇛
lemma (uniti₊⇛ ◎ sym⇛ (sym⇛ c₂)) = {!lemma (uniti₊⇛ ◎ c₂)!}
lemma (uniti₊⇛ ◎ sym⇛ (c₂ ◎ c₃)) = {!!}
lemma (uniti₊⇛ ◎ (c₂ ◎ c₃)) = {!!}
lemma (uniti⋆⇛ ◎ unite⋆⇛) = refl id⇛
lemma (uniti⋆⇛ ◎ sym⇛ uniti⋆⇛) = refl id⇛
lemma (uniti⋆⇛ ◎ sym⇛ (sym⇛ c₂)) = {!!}
lemma (uniti⋆⇛ ◎ sym⇛ (c₂ ◎ c₃)) = {!!}
lemma (uniti⋆⇛ ◎ (c₂ ◎ c₃)) = {!!}
lemma (id⇛ ◎ c₂) = lemma c₂
lemma (sym⇛ c₁ ◎ c₂) = {!!}
lemma (c₁ ◎ c₂ ◎ c₃) = {!!}
--}
