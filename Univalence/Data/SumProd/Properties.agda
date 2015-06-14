{-# OPTIONS --without-K #-}

-- Note that this is properly named, but it does depend on our version of
-- Equiv and TypeEquiv for a number of things.

module Data.SumProd.Properties where

open import Level using (zero; suc)
import Relation.Binary.PropositionalEquality as P
open import Relation.Binary using (Rel)
open import Data.Sum using (_⊎_; inj₁; inj₂) renaming (map to map⊎)
open import Data.Product using (_×_; _,_; proj₁; proj₂) renaming (map to map×)
open import Data.Empty
import Function as F

open import Equiv
open import TypeEquiv

-- Note that all these lemmas are "simple" in the sense that they
-- are all about map⊎ rather than [_,_]

distl-commute : {A B C D E F : Set} → {f : A → D} {g : B → E} {h : C → F} →
  (x : A × (B ⊎ C)) → distl (map× f (map⊎ g h) x) P.≡ (map⊎ (map× f g) (map× f h) (distl x))
distl-commute (a , inj₁ x) = P.refl
distl-commute (a , inj₂ y) = P.refl

factorl-commute : {A B C D E F : Set} → {f : A → D} {g : B → E} {h : C → F} →
  (x : (A × B) ⊎ (A × C)) → factorl (map⊎ (map× f g) (map× f h) x) P.≡
                            (map× f (map⊎ g h) (factorl x))
factorl-commute (inj₁ (a , b)) = P.refl
factorl-commute (inj₂ (a , c)) = P.refl

dist-commute : {A B C D E F : Set} → {f : A → D} {g : B → E} {h : C → F} →
  (x : (A ⊎ B) × C) → dist (map× (map⊎ f g) h x) P.≡ (map⊎ (map× f h) (map× g h) (dist x))
dist-commute (inj₁ x , c) = P.refl
dist-commute (inj₂ y , c) = P.refl

factor-commute : {A B C D E F : Set} → {f : A → D} {g : B → E} {h : C → F} →
  (x : (A × C) ⊎ (B × C)) → factor (map⊎ (map× f h) (map× g h) x) P.≡
                           (map× (map⊎ f g) h (factor x))
factor-commute (inj₁ x) = P.refl
factor-commute (inj₂ y) = P.refl

distl-swap₊-lemma : {A B C : Set} → (x : (A × (B ⊎ C))) →
  (distl (proj₁ x , swap₊ (proj₂ x))) P.≡ (swap₊ (distl x))
distl-swap₊-lemma (x , inj₁ y) = P.refl
distl-swap₊-lemma (x , inj₂ y) = P.refl

factorl-swap₊-lemma : {A B C : Set} → (x : (A × C) ⊎ (A × B)) →
  (proj₁ (factorl x) , swap₊ (proj₂ (factorl x))) P.≡ factorl (swap₊ x)
factorl-swap₊-lemma (inj₁ x) = P.refl
factorl-swap₊-lemma (inj₂ y) = P.refl

dist-swap⋆-lemma : {A B C : Set} → (x : (A ⊎ B) × C) →
  map⊎ swap⋆ swap⋆ (dist x) P.≡ distl (swap⋆ x)
dist-swap⋆-lemma (inj₁ x , z) = P.refl
dist-swap⋆-lemma (inj₂ y , z) = P.refl

factor-swap⋆-lemma : {A B C : Set} → (x : (C × A) ⊎ (C × B)) →
  factor (map⊎ swap⋆ swap⋆ x) P.≡ swap⋆ (factorl x)
factor-swap⋆-lemma (inj₁ x) = P.refl
factor-swap⋆-lemma (inj₂ y) = P.refl