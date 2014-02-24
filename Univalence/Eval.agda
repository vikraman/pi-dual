module Eval where

open import Data.Empty
open import Data.Unit
open import Data.Unit.Core
open import Data.Nat renaming (_⊔_ to _⊔ℕ_)
open import Data.Sum renaming (map to _⊎→_)
open import Data.Product renaming (map to _×→_)
open import Data.Vec
open import Relation.Binary.PropositionalEquality

open import FT -- Finite Types

_∘_ = trans

mutual
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
  evalComb (sym⇛ c) v = evalBComb c v 
  evalComb (c₁ ◎ c₂) v = evalComb c₂ (evalComb c₁ v)
  evalComb (c ⊕ c₁) (inj₁ x) = inj₁ (evalComb c x)
  evalComb (c ⊕ c₁) (inj₂ y) = inj₂ (evalComb c₁ y)
  evalComb (c ⊗ c₁) (proj₁ , proj₂) = evalComb c proj₁ , evalComb c₁ proj₂

  evalBComb : {a b : FT} → a ⇛ b → ⟦ b ⟧ → ⟦ a ⟧
  evalBComb unite₊⇛ v = inj₂ v
  evalBComb uniti₊⇛ (inj₁ ())
  evalBComb uniti₊⇛ (inj₂ y) = y
  evalBComb swap₊⇛ (inj₁ x) = inj₂ x
  evalBComb swap₊⇛ (inj₂ y) = inj₁ y
  evalBComb assocl₊⇛ (inj₁ (inj₁ x)) = inj₁ x
  evalBComb assocl₊⇛ (inj₁ (inj₂ y)) = inj₂ (inj₁ y)
  evalBComb assocl₊⇛ (inj₂ y) = inj₂ (inj₂ y)
  evalBComb assocr₊⇛ (inj₁ x) = inj₁ (inj₁ x)
  evalBComb assocr₊⇛ (inj₂ (inj₁ x)) = inj₁ (inj₂ x)
  evalBComb assocr₊⇛ (inj₂ (inj₂ y)) = inj₂ y
  evalBComb unite⋆⇛ x = tt , x
  evalBComb uniti⋆⇛ (tt , x) = x
  evalBComb swap⋆⇛ (x , y) = y , x
  evalBComb assocl⋆⇛ ((x , y) , z) = x , y , z
  evalBComb assocr⋆⇛ (x , y , z) = (x , y) , z
  evalBComb distz⇛ ()
  evalBComb factorz⇛ (() , _)
  evalBComb dist⇛ (inj₁ (proj₁ , proj₂)) = inj₁ proj₁ , proj₂
  evalBComb dist⇛ (inj₂ (proj₁ , proj₂)) = inj₂ proj₁ , proj₂
  evalBComb factor⇛ (inj₁ x , proj₂) = inj₁ (x , proj₂)
  evalBComb factor⇛ (inj₂ y , proj₂) = inj₂ (y , proj₂)
  evalBComb id⇛ x = x
  evalBComb (sym⇛ c) x = evalComb c x
  evalBComb (c ◎ c₁) x = evalBComb c (evalBComb c₁ x)
  evalBComb (c ⊕ c₁) (inj₁ x) = inj₁ (evalBComb c x)
  evalBComb (c ⊕ c₁) (inj₂ y) = inj₂ (evalBComb c₁ y)
  evalBComb (c ⊗ c₁) (proj₁ , proj₂) = evalBComb c proj₁ , evalBComb c₁ proj₂

mutual
  Comb∘BComb : {a b : FT} → (c : a ⇛ b) → ∀ x → evalBComb c (evalComb c x) ≡ x
  Comb∘BComb unite₊⇛ (inj₁ ())
  Comb∘BComb unite₊⇛ (inj₂ y) = refl 
  Comb∘BComb uniti₊⇛ x = refl 
  Comb∘BComb swap₊⇛ (inj₁ x) = refl
  Comb∘BComb swap₊⇛ (inj₂ y) = refl
  Comb∘BComb assocl₊⇛ (inj₁ x) = refl 
  Comb∘BComb assocl₊⇛ (inj₂ (inj₁ x)) = refl 
  Comb∘BComb assocl₊⇛ (inj₂ (inj₂ y)) = refl 
  Comb∘BComb assocr₊⇛ (inj₁ (inj₁ x)) = refl 
  Comb∘BComb assocr₊⇛ (inj₁ (inj₂ y)) = refl 
  Comb∘BComb assocr₊⇛ (inj₂ y) = refl
  Comb∘BComb unite⋆⇛ (tt , y) = refl
  Comb∘BComb uniti⋆⇛ x = refl
  Comb∘BComb swap⋆⇛ (x , y) = refl
  Comb∘BComb assocl⋆⇛ (x , y , z) = refl
  Comb∘BComb assocr⋆⇛ ((x , y) , z) = refl
  Comb∘BComb distz⇛ (() , _)
  Comb∘BComb factorz⇛ ()
  Comb∘BComb dist⇛ (inj₁ x , y) = refl
  Comb∘BComb dist⇛ (inj₂ x , y) = refl
  Comb∘BComb factor⇛ (inj₁ (x , y)) = refl
  Comb∘BComb factor⇛ (inj₂ (x , y)) = refl
  Comb∘BComb id⇛ x = refl 
  Comb∘BComb (sym⇛ c) x = BComb∘Comb c x
  Comb∘BComb (c₀ ◎ c₁) x = 
    cong (evalBComb c₀)  (Comb∘BComb c₁ (evalComb c₀ x)) ∘ Comb∘BComb c₀ x
  Comb∘BComb (c₀ ⊕ c₁) (inj₁ x) = cong inj₁ (Comb∘BComb c₀ x)
  Comb∘BComb (c₀ ⊕ c₁) (inj₂ y) = cong inj₂ (Comb∘BComb c₁ y)
  Comb∘BComb (c₀ ⊗ c₁) (x , y) = cong₂ _,_ (Comb∘BComb c₀ x) (Comb∘BComb c₁ y)

  BComb∘Comb : {a b : FT} → (c : a ⇛ b) → ∀ x → evalComb c (evalBComb c x) ≡ x
  BComb∘Comb unite₊⇛ x = refl 
  BComb∘Comb uniti₊⇛ (inj₁ ())
  BComb∘Comb uniti₊⇛ (inj₂ y) = refl 
  BComb∘Comb swap₊⇛ (inj₁ x) = refl 
  BComb∘Comb swap₊⇛ (inj₂ y) = refl 
  BComb∘Comb assocl₊⇛ (inj₁ (inj₁ x)) = refl 
  BComb∘Comb assocl₊⇛ (inj₁ (inj₂ y)) = refl 
  BComb∘Comb assocl₊⇛ (inj₂ y) = refl 
  BComb∘Comb assocr₊⇛ (inj₁ x) = refl 
  BComb∘Comb assocr₊⇛ (inj₂ (inj₁ x)) = refl 
  BComb∘Comb assocr₊⇛ (inj₂ (inj₂ y)) = refl
  BComb∘Comb unite⋆⇛ x = refl 
  BComb∘Comb uniti⋆⇛ (tt , proj₂) = refl 
  BComb∘Comb swap⋆⇛ (proj₁ , proj₂) = refl 
  BComb∘Comb assocl⋆⇛ ((proj₁ , proj₂) , proj₃) = refl 
  BComb∘Comb assocr⋆⇛ (proj₁ , proj₂ , proj₃) = refl 
  BComb∘Comb distz⇛ ()
  BComb∘Comb factorz⇛ (() , _)
  BComb∘Comb dist⇛ (inj₁ (proj₁ , proj₂)) = refl 
  BComb∘Comb dist⇛ (inj₂ (proj₁ , proj₂)) = refl 
  BComb∘Comb factor⇛ (inj₁ x , proj₂) = refl 
  BComb∘Comb factor⇛ (inj₂ y , proj₂) = refl 
  BComb∘Comb id⇛ x = refl 
  BComb∘Comb (sym⇛ c) x = Comb∘BComb c x
  BComb∘Comb (c₀ ◎ c₁) x = 
    cong (evalComb c₁) (BComb∘Comb c₀ (evalBComb c₁ x)) ∘ BComb∘Comb c₁ x
  BComb∘Comb (c ⊕ c₁) (inj₁ x) = cong inj₁ (BComb∘Comb c x)
  BComb∘Comb (c ⊕ c₁) (inj₂ y) = cong inj₂ (BComb∘Comb c₁ y)
  BComb∘Comb (c ⊗ c₁) (x , y) = cong₂ _,_ (BComb∘Comb c x) (BComb∘Comb c₁ y)
