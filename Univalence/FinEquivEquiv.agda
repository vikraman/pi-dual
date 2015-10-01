{-# OPTIONS --without-K #-}

module FinEquivEquiv where

open import Data.Product using (_×_; proj₁; proj₂)

open import Equiv using (sym∼; sym≃; _⊎≃_; id≃; _≃_; _●_; _×≃_; qinv)

open import FinEquivPlusTimes using (F0≃⊥; module Plus)
open Plus using (⊎≃+; +≃⊎)

open import FinEquivTypeEquiv
  using (_fin≃_; module PlusE; module TimesE; module PlusTimesE)
open PlusE using (_+F_; unite+; uniti+)
open import EquivEquiv
open import TypeEquiv
  using (unite₊equiv)

open import Data.Empty using (⊥)
open import Data.Unit using (⊤)
open import Data.Nat using (ℕ; _+_)
open import Data.Fin using (Fin)
open import Data.Sum using (_⊎_)
open import Data.Product using (_,_)

import TypeEquivEquiv as T
  using ([id,id]≋id; ⊎●≋●⊎; ⊎≃-respects-≋; unite₊-nat)

------------------------------------------------------------------------------
-- equivalences for the ⊎ structure

[id+id]≋id : ∀ {p : ℕ × ℕ} →
    let m = proj₁ p in let n = proj₂ p in
    id≃ {A = Fin m} +F id≃ {A = Fin n} ≋ id≃
[id+id]≋id {(m , n)} =
  let em = id≃ {A = Fin m} in 
  let en = id≃ {A = Fin n} in 
  let em⊎en = id≃ {A = Fin m ⊎ Fin n} in 
  let em+n = id≃ {A = Fin (m + n)} in
  let f≋ = id≋ {x = ⊎≃+ {m} {n}} in
  let g≋ = id≋ {x = +≃⊎ {m} {n}} in
  begin (
  em +F en
    ≋⟨ id≋ ⟩
  ⊎≃+ ● (em ⊎≃ en) ● +≃⊎
    ≋⟨ f≋ ◎ (T.[id,id]≋id ◎ g≋) ⟩
  ⊎≃+ ● id≃ {A = Fin m ⊎ Fin n} ● +≃⊎
    ≋⟨ f≋ ◎ lid≋ {f = +≃⊎} ⟩
  ⊎≃+ {m} ● +≃⊎ 
    ≋⟨ rinv≋ (⊎≃+ {m}) ⟩
  em+n ∎)
  where open ≋-Reasoning

intro-inv-r : {m n : ℕ} {B : Set} (f : (Fin m ⊎ Fin n) ≃ B) → f ≋ (f ● +≃⊎) ● ⊎≃+
intro-inv-r f = 
  begin (
    f
      ≋⟨ sym≋ rid≋ ⟩
    f ● id≃
      ≋⟨ id≋ {x = f} ◎ sym≋ (linv≋ ⊎≃+) ⟩
    f ● (+≃⊎ ● ⊎≃+)
      ≋⟨ ●-assocl {f = ⊎≃+} {+≃⊎} {f} ⟩
    (f ● +≃⊎) ● ⊎≃+ ∎)
  where open ≋-Reasoning

+●≋●+ : {A B C D E F : ℕ} →
  {f : A fin≃ C} {g : B fin≃ D} {h : C fin≃ E} {i : D fin≃ F} →
  (h ● f) +F (i ● g) ≋ (h +F i) ● (f +F g)
+●≋●+ {f = f} {g} {h} {i} =
  let f≋ = id≋ {x = ⊎≃+} in
  let g≋ = id≋ {x = +≃⊎} in
  let id≋fg = id≋ {x = f ⊎≃ g} in
  begin (
    (h ● f) +F (i ● g)
      ≋⟨ id≋ ⟩
    ⊎≃+ ● ((h ● f) ⊎≃ (i ● g)) ● +≃⊎
      ≋⟨ f≋ ◎ (T.⊎●≋●⊎ ◎ g≋) ⟩ -- the real work, rest is shuffling
    ⊎≃+ ● ((h ⊎≃ i) ● (f ⊎≃ g)) ● +≃⊎
      ≋⟨ ●-assocl {f = +≃⊎} { (h ⊎≃ i) ● (f ⊎≃ g) } {⊎≃+} ⟩
    (⊎≃+ ● ((h ⊎≃ i) ● (f ⊎≃ g))) ● +≃⊎
      ≋⟨ ●-assocl {f = f ⊎≃ g} {h ⊎≃ i} {⊎≃+} ◎ g≋ ⟩
    ((⊎≃+ ● h ⊎≃ i) ● f ⊎≃ g) ● +≃⊎
      ≋⟨ ((f≋ ◎ intro-inv-r (h ⊎≃ i)) ◎ id≋fg) ◎ g≋ ⟩
    ((⊎≃+ ● (h ⊎≃ i ● +≃⊎) ● ⊎≃+) ● f ⊎≃ g) ● +≃⊎
      ≋⟨ (●-assocl {f = ⊎≃+} {h ⊎≃ i ● +≃⊎} {⊎≃+} ◎ id≋fg) ◎ g≋ ⟩
    (((⊎≃+ ● (h ⊎≃ i ● +≃⊎)) ● ⊎≃+) ● f ⊎≃ g) ● +≃⊎
      ≋⟨ id≋ ⟩ -- the left part is done, show it
    ((h +F i ● ⊎≃+) ● f ⊎≃ g) ● +≃⊎
      ≋⟨ ●-assoc {f = f ⊎≃ g} {⊎≃+} {h +F i} ◎ g≋ ⟩
    (h +F i ● (⊎≃+ ● f ⊎≃ g)) ● +≃⊎
      ≋⟨ ●-assoc {f = +≃⊎} {⊎≃+ ● f ⊎≃ g} {h +F i}⟩
    (h +F i) ● ((⊎≃+ ● f ⊎≃ g) ● +≃⊎)
      ≋⟨ id≋ {x = h +F i} ◎ ●-assoc {f = +≃⊎} {f ⊎≃ g} {⊎≃+}⟩
    (h +F i) ● (f +F g) ∎)
  where open ≋-Reasoning

_◎F_ : {A B C D : ℕ} {f₁ g₁ : A fin≃ B} {f₂ g₂ : C fin≃ D} →
  (f₁ ≋ g₁) → (f₂ ≋ g₂) → (f₁ +F f₂ ≋ g₁ +F g₂)
_◎F_ {A} {B} {C} {D} {f₁} {g₁} {f₂} {g₂} f₁≋g₁ f₂≋g₂ =
  let f≋ = id≋ {x = ⊎≃+} in
  let g≋ = id≋ {x = +≃⊎} in
  begin (
    f₁ +F f₂
      ≋⟨ id≋ ⟩ 
    ⊎≃+ ● (f₁ ⊎≃ f₂) ● +≃⊎
      ≋⟨ f≋ ◎ (T.⊎≃-respects-≋ f₁≋g₁ f₂≋g₂ ◎ g≋) ⟩
    ⊎≃+ ● (g₁ ⊎≃ g₂) ● +≃⊎
      ≋⟨ id≋ ⟩ 
    g₁ +F g₂ ∎)
  where open ≋-Reasoning

id0≃ : Fin 0 ≃ Fin 0
id0≃ = id≃ {A = Fin 0}

unite₊-nat : ∀ {A B} {f : A fin≃ B} →
  unite+ ● (id0≃ +F f) ≋ f ● unite+
unite₊-nat {A} {B} {f} =
  let rhs≋ = id≋ {x = (id≃ ⊎≃ f) ● +≃⊎} in
  let f≋ = id≋ {x = ⊎≃+} in
  begin (
    unite+ ● (id0≃ +F f) 
      ≋⟨ id≋ ⟩ 
    (unite₊equiv ● (F0≃⊥ ⊎≃ id≃) ● +≃⊎) ● ⊎≃+ ● ((id≃ ⊎≃ f) ● +≃⊎)
      ≋⟨ ●-assocl {f = (id≃ ⊎≃ f) ● +≃⊎} {⊎≃+} {unite₊equiv ● (F0≃⊥ ⊎≃ id≃) ● +≃⊎} ⟩
    ((unite₊equiv ● ((F0≃⊥ ⊎≃ id≃) ● +≃⊎)) ● ⊎≃+) ● (id≃ ⊎≃ f) ● +≃⊎
      ≋⟨ (●-assocl {f = +≃⊎} {F0≃⊥ ⊎≃ id≃} {unite₊equiv} ◎ f≋ ) ◎ rhs≋ ⟩
    (((unite₊equiv ● (F0≃⊥ ⊎≃ id≃)) ● +≃⊎) ● ⊎≃+) ● (id≃ ⊎≃ f) ● +≃⊎
      ≋⟨ sym≋ (intro-inv-r (unite₊equiv ● (F0≃⊥ ⊎≃ id≃))) ◎ rhs≋ ⟩
    (unite₊equiv ● (F0≃⊥ ⊎≃ id≃)) ● (id≃ ⊎≃ f) ● +≃⊎
      ≋⟨ {!!} ⟩ -- need a lemma that allows to exchange
    (unite₊equiv ● (id≃ ⊎≃ f)) ● (F0≃⊥ ⊎≃ id≃) ● +≃⊎ 
      ≋⟨ T.unite₊-nat ◎ id≋ {x = (F0≃⊥ ⊎≃ id≃) ● +≃⊎} ⟩
    (f ● unite₊equiv) ● (F0≃⊥ ⊎≃ id≃) ● +≃⊎
      ≋⟨ ●-assoc {f = (F0≃⊥ ⊎≃ id≃) ● +≃⊎} {unite₊equiv} {f} ⟩
    f ● unite₊equiv ● (F0≃⊥ ⊎≃ id≃) ● +≃⊎
      ≋⟨ id≋ ⟩
    f ● unite+ ∎)
  where open ≋-Reasoning
-- (h ● f) +F (i ● g) ≋ (h +F i) ● (f +F g)
-- Fin (0 + m) ≃ Fin m 
-- Fin (0 + m) ≃ Fin (0 + n)

-- Fin m ≃ Fin (0 + n)

uniti₊-nat : ∀ {A B} {f : A fin≃ B} →
  uniti+ ● f ≋ (id0≃ +F f) ● uniti+
uniti₊-nat {A} {B} {f} = 
  begin (
    uniti+ ● f 
      ≋⟨ {!!} ⟩ 
    (id0≃ +F f) ● uniti+ ∎)
  where open ≋-Reasoning
-- I believe the above is just flip-sym≋ unite₊-nat !
------------------------------------------------------------------------------
