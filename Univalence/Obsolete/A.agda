{-# OPTIONS --without-K #-}

module A where

open import Data.Nat
open import Data.Empty
open import Data.Unit
open import Data.Sum
open import Data.Product

infix  4  _≡_   -- propositional equality
infixr 10 _◎_
infixr 30 _⟷_

------------------------------------------------------------------------------
-- Our own version of refl that makes 'a' explicit

data _≡_ {ℓ} {A : Set ℓ} : (a b : A) → Set ℓ where
  refl : (a : A) → (a ≡ a)

sym : ∀ {ℓ} {A : Set ℓ} {a b : A} → (a ≡ b) → (b ≡ a)
sym {a = a} {b = .a} (refl .a) = refl a

{--

Just confirming that the following does not typecheck!

proof-irrelevance : {A : Set} {x y : A} (p q : x ≡ y) →  p ≡ q
proof-irrelevance (refl x) (refl .x) = refl (refl x)

--}

------------------------------------------------------------------------------
{--
Types are higher groupoids:
- 0 is empty
- 1 has one element and one path refl
- sum type is disjoint union; paths are component wise
- product type is cartesian product; paths are pairs of paths
--}

data U : Set where
  ZERO  : U
  ONE   : U
  PLUS  : U → U → U
  TIMES : U → U → U

-- Points 

⟦_⟧ : U → Set
⟦ ZERO ⟧       = ⊥
⟦ ONE ⟧        = ⊤
⟦ PLUS t t' ⟧  = ⟦ t ⟧ ⊎ ⟦ t' ⟧
⟦ TIMES t t' ⟧ = ⟦ t ⟧ × ⟦ t' ⟧

BOOL : U
BOOL = PLUS ONE ONE

BOOL² : U
BOOL² = TIMES BOOL BOOL

TRUE : ⟦ BOOL ⟧
TRUE = inj₁ tt

FALSE : ⟦ BOOL ⟧
FALSE = inj₂ tt

NOT : ⟦ BOOL ⟧ → ⟦ BOOL ⟧
NOT (inj₁ tt) = FALSE
NOT (inj₂ tt) = TRUE

CNOT : ⟦ BOOL ⟧ → ⟦ BOOL ⟧ → ⟦ BOOL ⟧ × ⟦ BOOL ⟧
CNOT (inj₁ tt) b = (TRUE , NOT b)
CNOT (inj₂ tt) b = (FALSE , b)

------------------------------------------------------------------------------
-- Paths connect points in t₁ and t₂ if there is an isomorphism between the
-- types t₁ and t₂. The family ⟷ plays the role of identity types in HoTT

data _⟷_ : U → U → Set where
  unite₊  : {t : U} → PLUS ZERO t ⟷ t
  uniti₊  : {t : U} → t ⟷ PLUS ZERO t
  swap₊   : {t₁ t₂ : U} → PLUS t₁ t₂ ⟷ PLUS t₂ t₁
  assocl₊ : {t₁ t₂ t₃ : U} → PLUS t₁ (PLUS t₂ t₃) ⟷ PLUS (PLUS t₁ t₂) t₃
  assocr₊ : {t₁ t₂ t₃ : U} → PLUS (PLUS t₁ t₂) t₃ ⟷ PLUS t₁ (PLUS t₂ t₃)
  unite⋆  : {t : U} → TIMES ONE t ⟷ t
  uniti⋆  : {t : U} → t ⟷ TIMES ONE t
  swap⋆   : {t₁ t₂ : U} → TIMES t₁ t₂ ⟷ TIMES t₂ t₁
  assocl⋆ : {t₁ t₂ t₃ : U} → TIMES t₁ (TIMES t₂ t₃) ⟷ TIMES (TIMES t₁ t₂) t₃
  assocr⋆ : {t₁ t₂ t₃ : U} → TIMES (TIMES t₁ t₂) t₃ ⟷ TIMES t₁ (TIMES t₂ t₃)
  distz   : {t : U} → TIMES ZERO t ⟷ ZERO
  factorz : {t : U} → ZERO ⟷ TIMES ZERO t
  dist    : {t₁ t₂ t₃ : U} → 
            TIMES (PLUS t₁ t₂) t₃ ⟷ PLUS (TIMES t₁ t₃) (TIMES t₂ t₃) 
  factor  : {t₁ t₂ t₃ : U} → 
            PLUS (TIMES t₁ t₃) (TIMES t₂ t₃) ⟷ TIMES (PLUS t₁ t₂) t₃
  id⟷    : {t : U} → t ⟷ t
  sym⟷   : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₂ ⟷ t₁)
  _◎_     : {t₁ t₂ t₃ : U} → (t₁ ⟷ t₂) → (t₂ ⟷ t₃) → (t₁ ⟷ t₃)
  _⊕_     : {t₁ t₂ t₃ t₄ : U} → 
            (t₁ ⟷ t₃) → (t₂ ⟷ t₄) → (PLUS t₁ t₂ ⟷ PLUS t₃ t₄)
  _⊗_     : {t₁ t₂ t₃ t₄ : U} → 
            (t₁ ⟷ t₃) → (t₂ ⟷ t₄) → (TIMES t₁ t₂ ⟷ TIMES t₃ t₄)

cond : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₁ ⟷ t₂) → 
       ((TIMES BOOL t₁) ⟷ (TIMES BOOL t₂))
cond f g = dist ◎ ((id⟷ ⊗ f) ⊕ (id⟷ ⊗ g)) ◎ factor 

controlled : {t : U} → (t ⟷ t) → ((TIMES BOOL t) ⟷ (TIMES BOOL t))
controlled f = cond f id⟷

cnot : BOOL² ⟷ BOOL²
cnot = controlled swap₊

-- Paths: each combinator defines a space of paths between its end points

mutual

  Paths : {t₁ t₂ : U} → (t₁ ⟷ t₂) → ⟦ t₁ ⟧ → ⟦ t₂ ⟧ → Set
  Paths unite₊ (inj₁ ()) 
  Paths unite₊ (inj₂ v) v' = (v ≡ v')
  Paths uniti₊ v (inj₁ ())
  Paths uniti₊ v (inj₂ v') = (v ≡ v')
  Paths swap₊ (inj₁ v) (inj₁ v') = ⊥
  Paths swap₊ (inj₁ v) (inj₂ v') = (v ≡ v')
  Paths swap₊ (inj₂ v) (inj₁ v') = (v ≡ v')
  Paths swap₊ (inj₂ v) (inj₂ v') = ⊥
  Paths assocl₊ (inj₁ v) (inj₁ (inj₁ v')) = (v ≡ v')
  Paths assocl₊ (inj₁ v) (inj₁ (inj₂ v')) = ⊥
  Paths assocl₊ (inj₁ v) (inj₂ v') = ⊥
  Paths assocl₊ (inj₂ (inj₁ v)) (inj₁ (inj₁ v')) = ⊥
  Paths assocl₊ (inj₂ (inj₁ v)) (inj₁ (inj₂ v')) = (v ≡ v')
  Paths assocl₊ (inj₂ (inj₁ v)) (inj₂ v') = ⊥
  Paths assocl₊ (inj₂ (inj₂ v)) (inj₁ v') = ⊥
  Paths assocl₊ (inj₂ (inj₂ v)) (inj₂ v') = (v ≡ v')
  Paths assocr₊ (inj₁ (inj₁ v)) (inj₁ v') = (v ≡ v')
  Paths assocr₊ (inj₁ (inj₁ v)) (inj₂ v') = ⊥
  Paths assocr₊ (inj₁ (inj₂ v)) (inj₁ v') = ⊥
  Paths assocr₊ (inj₁ (inj₂ v)) (inj₂ (inj₁ v')) = (v ≡ v')
  Paths assocr₊ (inj₁ (inj₂ v)) (inj₂ (inj₂ v')) = ⊥
  Paths assocr₊ (inj₂ v) (inj₁ v') = ⊥
  Paths assocr₊ (inj₂ v) (inj₂ (inj₁ v')) = ⊥
  Paths assocr₊ (inj₂ v) (inj₂ (inj₂ v')) = (v ≡ v')
  Paths unite⋆ (tt , v) v' = (v ≡ v')
  Paths uniti⋆ v (tt , v') = (v ≡ v')
  Paths swap⋆ (v₁ , v₂) (v₂' , v₁') = (v₁ ≡ v₁') × (v₂ ≡ v₂')
  Paths assocl⋆ (v₁ , (v₂ , v₃)) ((v₁' , v₂') , v₃') = 
    (v₁ ≡ v₁') × (v₂ ≡ v₂') × (v₃ ≡ v₃')
  Paths assocr⋆ ((v₁ , v₂) , v₃) (v₁' , (v₂' , v₃')) = 
    (v₁ ≡ v₁') × (v₂ ≡ v₂') × (v₃ ≡ v₃')
  Paths distz (() , v)
  Paths factorz ()
  Paths dist (inj₁ v₁ , v₃) (inj₁ (v₁' , v₃')) = (v₁ ≡ v₁') × (v₃ ≡ v₃')
  Paths dist (inj₁ v₁ , v₃) (inj₂ (v₂' , v₃')) = ⊥
  Paths dist (inj₂ v₂ , v₃) (inj₁ (v₁' , v₃')) = ⊥
  Paths dist (inj₂ v₂ , v₃) (inj₂ (v₂' , v₃')) = (v₂ ≡ v₂') × (v₃ ≡ v₃')
  Paths factor (inj₁ (v₁ , v₃)) (inj₁ v₁' , v₃') = 
    (v₁ ≡ v₁') × (v₃ ≡ v₃')
  Paths factor (inj₁ (v₁ , v₃)) (inj₂ v₂' , v₃') = ⊥
  Paths factor (inj₂ (v₂ , v₃)) (inj₁ v₁' , v₃') = ⊥
  Paths factor (inj₂ (v₂ , v₃)) (inj₂ v₂' , v₃') = 
    (v₂ ≡ v₂') × (v₃ ≡ v₃')
  Paths {t} id⟷ v v' = (v ≡ v')
  Paths (sym⟷ c) v v' = PathsB c v v'
  Paths (_◎_ {t₁} {t₂} {t₃} c₁ c₂) v v' = 
    Σ[ u ∈ ⟦ t₂ ⟧ ] (Paths c₁ v u × Paths c₂ u v')
  Paths (c₁ ⊕ c₂) (inj₁ v) (inj₁ v') = Paths c₁ v v'
  Paths (c₁ ⊕ c₂) (inj₁ v) (inj₂ v') = ⊥
  Paths (c₁ ⊕ c₂) (inj₂ v) (inj₁ v') = ⊥
  Paths (c₁ ⊕ c₂) (inj₂ v) (inj₂ v') = Paths c₂ v v'
  Paths (c₁ ⊗ c₂) (v₁ , v₂) (v₁' , v₂') = 
    Paths c₁ v₁ v₁' × Paths c₂ v₂ v₂'

  PathsB : {t₁ t₂ : U} → (t₁ ⟷ t₂) → ⟦ t₂ ⟧ → ⟦ t₁ ⟧ → Set
  PathsB unite₊ v (inj₁ ())
  PathsB unite₊ v (inj₂ v') = (v ≡ v')
  PathsB uniti₊ (inj₁ ()) 
  PathsB uniti₊ (inj₂ v) v' = (v ≡ v')
  PathsB swap₊ (inj₁ v) (inj₁ v') = ⊥
  PathsB swap₊ (inj₁ v) (inj₂ v') = (v ≡ v')
  PathsB swap₊ (inj₂ v) (inj₁ v') = (v ≡ v')
  PathsB swap₊ (inj₂ v) (inj₂ v') = ⊥
  PathsB assocl₊ (inj₁ (inj₁ v)) (inj₁ v') = (v ≡ v')
  PathsB assocl₊ (inj₁ (inj₁ v)) (inj₂ v') = ⊥
  PathsB assocl₊ (inj₁ (inj₂ v)) (inj₁ v') = ⊥
  PathsB assocl₊ (inj₁ (inj₂ v)) (inj₂ (inj₁ v')) = (v ≡ v')
  PathsB assocl₊ (inj₁ (inj₂ v)) (inj₂ (inj₂ v')) = ⊥
  PathsB assocl₊ (inj₂ v) (inj₁ v') = ⊥
  PathsB assocl₊ (inj₂ v) (inj₂ (inj₁ v')) = ⊥
  PathsB assocl₊ (inj₂ v) (inj₂ (inj₂ v')) = (v ≡ v')
  PathsB assocr₊ (inj₁ v) (inj₁ (inj₁ v')) = (v ≡ v')
  PathsB assocr₊ (inj₁ v) (inj₁ (inj₂ v')) = ⊥
  PathsB assocr₊ (inj₁ v) (inj₂ v') = ⊥
  PathsB assocr₊ (inj₂ (inj₁ v)) (inj₁ (inj₁ v')) = ⊥
  PathsB assocr₊ (inj₂ (inj₁ v)) (inj₁ (inj₂ v')) = (v ≡ v')
  PathsB assocr₊ (inj₂ (inj₁ v)) (inj₂ v') = ⊥
  PathsB assocr₊ (inj₂ (inj₂ v)) (inj₁ v') = ⊥
  PathsB assocr₊ (inj₂ (inj₂ v)) (inj₂ v') = (v ≡ v')
  PathsB unite⋆ v (tt , v') = (v ≡ v')
  PathsB uniti⋆ (tt , v) v' = (v ≡ v')
  PathsB swap⋆ (v₁ , v₂) (v₂' , v₁') = (v₁ ≡ v₁') × (v₂ ≡ v₂')
  PathsB assocl⋆ ((v₁ , v₂) , v₃) (v₁' , (v₂' , v₃')) = 
    (v₁ ≡ v₁') × (v₂ ≡ v₂') × (v₃ ≡ v₃')
  PathsB assocr⋆ (v₁ , (v₂ , v₃)) ((v₁' , v₂') , v₃') = 
    (v₁ ≡ v₁') × (v₂ ≡ v₂') × (v₃ ≡ v₃')
  PathsB distz ()
  PathsB factorz (() , v)
  PathsB dist (inj₁ (v₁ , v₃)) (inj₁ v₁' , v₃') = 
    (v₁ ≡ v₁') × (v₃ ≡ v₃')
  PathsB dist (inj₁ (v₁ , v₃)) (inj₂ v₂' , v₃') = ⊥
  PathsB dist (inj₂ (v₂ , v₃)) (inj₁ v₁' , v₃') = ⊥
  PathsB dist (inj₂ (v₂ , v₃)) (inj₂ v₂' , v₃') = 
    (v₂ ≡ v₂') × (v₃ ≡ v₃')
  PathsB factor (inj₁ v₁ , v₃) (inj₁ (v₁' , v₃')) = 
    (v₁ ≡ v₁') × (v₃ ≡ v₃')
  PathsB factor (inj₁ v₁ , v₃) (inj₂ (v₂' , v₃')) = ⊥
  PathsB factor (inj₂ v₂ , v₃) (inj₁ (v₁' , v₃')) = ⊥
  PathsB factor (inj₂ v₂ , v₃) (inj₂ (v₂' , v₃')) = 
    (v₂ ≡ v₂') × (v₃ ≡ v₃')
  PathsB {t} id⟷ v v' = (v ≡ v')
  PathsB (sym⟷ c) v v' = Paths c v v'
  PathsB (_◎_ {t₁} {t₂} {t₃} c₁ c₂) v v' = 
    Σ[ u ∈ ⟦ t₂ ⟧ ] (PathsB c₂ v u × PathsB c₁ u v')
  PathsB (c₁ ⊕ c₂) (inj₁ v) (inj₁ v') = PathsB c₁ v v'
  PathsB (c₁ ⊕ c₂) (inj₁ v) (inj₂ v') = ⊥
  PathsB (c₁ ⊕ c₂) (inj₂ v) (inj₁ v') = ⊥
  PathsB (c₁ ⊕ c₂) (inj₂ v) (inj₂ v') = PathsB c₂ v v'
  PathsB (c₁ ⊗ c₂) (v₁ , v₂) (v₁' , v₂') = 
    PathsB c₁ v₁ v₁' × PathsB c₂ v₂ v₂'

-- Given a combinator c : t₁ ⟷ t₂ and values v₁ : ⟦ t₁ ⟧ and v₂ : ⟦ t₂ ⟧,
-- Paths c v₁ v₂ gives us the space of paths that could connect v₁ and v₂
-- Examples:

pathIdtt : Paths id⟷ tt tt
pathIdtt = refl tt

-- four different ways of relating F to F:

pathIdFF : Paths id⟷ FALSE FALSE
pathIdFF = refl FALSE

pathIdIdFF : Paths (id⟷ ◎ id⟷) FALSE FALSE
pathIdIdFF = (FALSE , refl FALSE , refl FALSE)

pathNotNotFF : Paths (swap₊ ◎ swap₊) FALSE FALSE
pathNotNotFF = TRUE , refl tt , refl tt

pathPlusFF : Paths (id⟷ ⊕ id⟷) FALSE FALSE
pathPlusFF = refl tt

-- are there 2-paths between the above 3 paths???

-- space of paths is empty; cannot produce any path; can 
-- use pattern matching to confirm that the space is empty
pathIdFT : Paths id⟷ FALSE TRUE → ⊤
pathIdFT ()

-- three different ways of relating (F,F) to (F,F)

pathIdFFFF : Paths id⟷ (FALSE , FALSE) (FALSE , FALSE) 
pathIdFFFF = refl (FALSE , FALSE) 

pathTimesFFFF : Paths (id⟷ ⊗ id⟷) (FALSE , FALSE) (FALSE , FALSE) 
pathTimesFFFF = (refl FALSE , refl FALSE) 

pathTimesPlusFFFF : Paths 
                      ((id⟷ ⊕ id⟷) ⊗ (id⟷ ⊕ id⟷)) 
                      (FALSE , FALSE) (FALSE , FALSE) 
pathTimesPlusFFFF = (refl tt , refl tt)

pathSwap₊FT : Paths swap₊ FALSE TRUE
pathSwap₊FT = refl tt

pathSwap₊TF : Paths swap₊ TRUE FALSE
pathSwap₊TF = refl tt

-- no path
pathSwap₊FF : Paths swap₊ FALSE FALSE → ⊤
pathSwap₊FF ()

-- intuitively the two paths below should not be related by a 2-path because
-- pathCnotTF is "essentially" cnot which would map (F,F) to (F,F) but
-- pathIdNotTF would map (F,F) to (F,T).

pathIdNotFF : Paths (id⟷ ⊗ swap₊) (FALSE , FALSE) (FALSE , TRUE)
pathIdNotFF = refl FALSE , refl tt

pathIdNotFT : Paths (id⟷ ⊗ swap₊) (FALSE , TRUE) (FALSE , FALSE)
pathIdNotFT = refl FALSE , refl tt

pathIdNotTF : Paths (id⟷ ⊗ swap₊) (TRUE , FALSE) (TRUE , TRUE)
pathIdNotTF = refl TRUE , refl tt

pathIdNotTT : Paths (id⟷ ⊗ swap₊) (TRUE , TRUE) (TRUE , FALSE)
pathIdNotTT = refl TRUE , refl tt

pathIdNotb : {b₁ b₂ : ⟦ BOOL ⟧} → Paths (id⟷ ⊗ swap₊) (b₁ , b₂) (b₁ , NOT b₂)
pathIdNotb {b₁} {inj₁ tt} = refl b₁ , refl tt
pathIdNotb {b₁} {inj₂ tt} = refl b₁ , refl tt

pathCnotbb : {b₁ b₂ : ⟦ BOOL ⟧} → Paths cnot (b₁ , b₂) (CNOT b₁ b₂)
pathCnotbb {inj₁ tt} {inj₁ tt} = inj₁ (tt , TRUE) ,
                                 (refl tt , refl TRUE) , 
                                 (inj₁ (tt , FALSE) ,
                                 (refl tt , refl tt) , 
                                 (refl tt , refl FALSE))
pathCnotbb {inj₁ tt} {inj₂ tt} = inj₁ (tt , FALSE) ,
                                 (refl tt , refl FALSE) , 
                                 (inj₁ (tt , TRUE) ,
                                 (refl tt , refl tt) , 
                                 (refl tt , refl TRUE))
pathCnotbb {inj₂ tt} {b₂} = inj₂ (tt , b₂) , 
                            (refl tt , refl b₂) , 
                            (inj₂ (tt , b₂) , 
                            (refl tt , refl b₂) , 
                            (refl tt , refl b₂))

pathCnotFF : Paths cnot (FALSE , FALSE) (FALSE , FALSE)
pathCnotFF = inj₂ (tt , FALSE) , 
             (refl tt , refl FALSE) , 
             (inj₂ (tt , FALSE) , 
             (refl tt , refl FALSE) , 
             (refl tt , refl FALSE))

pathCnotFT : Paths cnot (FALSE , TRUE) (FALSE , TRUE)
pathCnotFT = inj₂ (tt , TRUE) ,
             (refl tt , refl TRUE) , 
             (inj₂ (tt , TRUE) ,
             (refl tt , refl TRUE) , 
             (refl tt , refl TRUE))

pathCnotTF : Paths cnot (TRUE , FALSE) (TRUE , TRUE)
pathCnotTF = inj₁ (tt , FALSE) , -- first intermediate value
             -- path using dist from (T,F) to (inj₁ (tt , F)) 
             (refl tt , refl FALSE) , 
             -- path from (inj₁ (tt , F)) to (T,T)
             (inj₁ (tt , TRUE) , -- next intermediate value
             (refl tt , refl tt) , 
             (refl tt , refl TRUE))

pathCnotTT : Paths cnot (TRUE , TRUE) (TRUE , FALSE)
pathCnotTT = inj₁ (tt , TRUE) ,
             (refl tt , refl TRUE) , 
             (inj₁ (tt , FALSE) ,
             (refl tt , refl tt) , 
             (refl tt , refl FALSE))

pathUnite₊ : {t : U} {v v' : ⟦ t ⟧} → (v ≡ v') → Paths unite₊ (inj₂ v) v'
pathUnite₊ p = p

-- Higher groupoid structure

-- For every path between v₁ and v₂ there is a path between v₂ and v₁

mutual 

  pathInv : {t₁ t₂ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧} {c : t₁ ⟷ t₂} → 
            Paths c v₁ v₂ → Paths (sym⟷ c) v₂ v₁
  pathInv {v₁ = inj₁ ()} {v₂ = v} {unite₊}
  pathInv {v₁ = inj₂ v} {v₂ = v'} {unite₊} p = sym p
  pathInv {v₁ = v} {v₂ = inj₁ ()} {uniti₊} 
  pathInv {v₁ = v} {v₂ = inj₂ v'} {uniti₊} p = sym p 
  pathInv {v₁ = inj₁ v} {v₂ = inj₁ v'} {swap₊} ()
  pathInv {v₁ = inj₁ v} {v₂ = inj₂ v'} {swap₊} p = sym p
  pathInv {v₁ = inj₂ v} {v₂ = inj₁ v'} {swap₊} p = sym p
  pathInv {v₁ = inj₂ v} {v₂ = inj₂ v'} {swap₊} ()
  pathInv {v₁ = inj₁ v} {v₂ = inj₁ (inj₁ v')} {assocl₊} p = sym p
  pathInv {v₁ = inj₁ v} {v₂ = inj₁ (inj₂ v')} {assocl₊} ()
  pathInv {v₁ = inj₁ v} {v₂ = inj₂ v'} {assocl₊} ()
  pathInv {v₁ = inj₂ (inj₁ v)} {v₂ = inj₁ (inj₁ v')} {assocl₊} ()
  pathInv {v₁ = inj₂ (inj₁ v)} {v₂ = inj₁ (inj₂ v')} {assocl₊} p = sym p
  pathInv {v₁ = inj₂ (inj₁ v)} {v₂ = inj₂ v'} {assocl₊} ()
  pathInv {v₁ = inj₂ (inj₂ v)} {v₂ = inj₁ v'} {assocl₊} ()
  pathInv {v₁ = inj₂ (inj₂ v)} {v₂ = inj₂ v'} {assocl₊} p = sym p
  pathInv {v₁ = inj₁ (inj₁ v)} {v₂ = inj₁ v'} {assocr₊} p = sym p
  pathInv {v₁ = inj₁ (inj₁ v)} {v₂ = inj₂ v'} {assocr₊} ()
  pathInv {v₁ = inj₁ (inj₂ v)} {v₂ = inj₁ v'} {assocr₊} ()
  pathInv {v₁ = inj₁ (inj₂ v)} {v₂ = inj₂ (inj₁ v')} {assocr₊} p = sym p
  pathInv {v₁ = inj₁ (inj₂ v)} {v₂ = inj₂ (inj₂ v')} {assocr₊} ()
  pathInv {v₁ = inj₂ v} {v₂ = inj₁ v'} {assocr₊} ()
  pathInv {v₁ = inj₂ v} {v₂ = inj₂ (inj₁ v')} {assocr₊} ()
  pathInv {v₁ = inj₂ v} {v₂ = inj₂ (inj₂ v')} {assocr₊} p = sym p
  pathInv {v₁ = (tt , v)} {v₂ = v'} {unite⋆} p = sym p
  pathInv {v₁ = v} {v₂ = (tt , v')} {uniti⋆} p = sym p
  pathInv {v₁ = (u , v)} {v₂ = (v' , u')} {swap⋆} (p₁ , p₂) = (sym p₂ , sym p₁)
  pathInv {v₁ = (u , (v , w))} {v₂ = ((u' , v') , w')} {assocl⋆} (p₁ , p₂ , p₃) 
    = (sym p₁ , sym p₂ , sym p₃)
  pathInv {v₁ = ((u , v) , w)} {v₂ = (u' , (v' , w'))} {assocr⋆} (p₁ , p₂ , p₃) 
    = (sym p₁ , sym p₂ , sym p₃)
  pathInv {v₁ = _} {v₂ = ()} {distz}
  pathInv {v₁ = ()} {v₂ = _} {factorz} 
  pathInv {v₁ = (inj₁ v₁ , v₃)} {v₂ = inj₁ (v₁' , v₃')} {dist} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathInv {v₁ = (inj₁ v₁ , v₃)} {v₂ = inj₂ (v₂' , v₃')} {dist} ()
  pathInv {v₁ = (inj₂ v₂ , v₃)} {v₂ = inj₁ (v₁' , v₃')} {dist} ()
  pathInv {v₁ = (inj₂ v₂ , v₃)} {v₂ = inj₂ (v₂' , v₃')} {dist} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathInv {v₁ = inj₁ (v₁ , v₃)} {v₂ = (inj₁ v₁' , v₃')} {factor} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathInv {v₁ = inj₁ (v₁ , v₃)} {v₂ = (inj₂ v₂' , v₃')} {factor} ()
  pathInv {v₁ = inj₂ (v₂ , v₃)} {v₂ = (inj₁ v₁' , v₃')} {factor} ()
  pathInv {v₁ = inj₂ (v₂ , v₃)} {v₂ = (inj₂ v₂' , v₃')} {factor} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathInv {v₁ = v} {v₂ = v'} {id⟷} p = sym p
  pathInv {v₁ = v} {v₂ = v'} {sym⟷ c} p = pathBInv {v₁ = v'} {v₂ = v} {c} p
  pathInv {v₁ = v} {v₂ = v'} {c₁ ◎ c₂} (u , (p₁ , p₂)) = 
    (u , (pathInv {c = c₂} p₂  , pathInv {c = c₁} p₁))
  pathInv {v₁ = inj₁ v} {v₂ = inj₁ v'} {c₁ ⊕ c₂} p = pathInv {c = c₁} p
  pathInv {v₁ = inj₁ v} {v₂ = inj₂ v'} {c₁ ⊕ c₂} ()
  pathInv {v₁ = inj₂ v} {v₂ = inj₁ v'} {c₁ ⊕ c₂} ()
  pathInv {v₁ = inj₂ v} {v₂ = inj₂ v'} {c₁ ⊕ c₂} p = pathInv {c = c₂} p 
  pathInv {v₁ = (u , v)} {v₂ = (u' , v')} {c₁ ⊗ c₂} (p₁ , p₂) = 
    (pathInv {c = c₁} p₁ , pathInv {c = c₂} p₂)

  pathBInv : {t₁ t₂ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧} {c : t₁ ⟷ t₂} → 
             PathsB c v₂ v₁ → PathsB (sym⟷ c) v₁ v₂
  pathBInv {v₁ = inj₁ ()} {v₂ = v} {unite₊}
  pathBInv {v₁ = inj₂ v} {v₂ = v'} {unite₊} p = sym p
  pathBInv {v₁ = v} {v₂ = inj₁ ()} {uniti₊} 
  pathBInv {v₁ = v} {v₂ = inj₂ v'} {uniti₊} p = sym p 
  pathBInv {v₁ = inj₁ v} {v₂ = inj₁ v'} {swap₊} ()
  pathBInv {v₁ = inj₁ v} {v₂ = inj₂ v'} {swap₊} p = sym p
  pathBInv {v₁ = inj₂ v} {v₂ = inj₁ v'} {swap₊} p = sym p
  pathBInv {v₁ = inj₂ v} {v₂ = inj₂ v'} {swap₊} ()

  pathBInv {v₁ = inj₁ v} {v₂ = inj₁ (inj₁ v')} {assocl₊} p = sym p
  pathBInv {v₁ = inj₂ v} {v₂ = inj₁ (inj₁ v')} {assocl₊} ()
  pathBInv {v₁ = inj₁ v} {v₂ = inj₁ (inj₂ v')} {assocl₊} ()
  pathBInv {v₁ = inj₂ (inj₁ v)} {v₂ = inj₁ (inj₂ v')} {assocl₊} p = sym p
  pathBInv {v₁ = inj₂ (inj₂ v)} {v₂ = inj₁ (inj₂ v')} {assocl₊} ()
  pathBInv {v₁ = inj₁ v} {v₂ = inj₂ v'} {assocl₊} ()
  pathBInv {v₁ = inj₂ (inj₁ v)} {v₂ = inj₂ v'} {assocl₊} ()
  pathBInv {v₁ = inj₂ (inj₂ v)} {v₂ = inj₂ v'} {assocl₊} p = sym p
  pathBInv {v₁ = inj₁ (inj₁ v)} {v₂ = inj₁ v'} {assocr₊} p = sym p
  pathBInv {v₁ = inj₁ (inj₂ v)} {v₂ = inj₁ v'} {assocr₊} ()
  pathBInv {v₁ = inj₂ v} {v₂ = inj₁ v'} {assocr₊} ()
  pathBInv {v₁ = inj₁ (inj₁ v)} {v₂ = inj₂ (inj₁ v')} {assocr₊} ()
  pathBInv {v₁ = inj₁ (inj₂ v)} {v₂ = inj₂ (inj₁ v')} {assocr₊} p = sym p
  pathBInv {v₁ = inj₂ v} {v₂ = inj₂ (inj₁ v')} {assocr₊} ()
  pathBInv {v₁ = inj₁ v} {v₂ = inj₂ (inj₂ v')} {assocr₊} ()
  pathBInv {v₁ = inj₂ v} {v₂ = inj₂ (inj₂ v')} {assocr₊} p = sym p
  pathBInv {v₁ = (tt , v)} {v₂ = v'} {unite⋆} p = sym p
  pathBInv {v₁ = v} {v₂ = (tt , v')} {uniti⋆} p = sym p
  pathBInv {v₁ = (u , v)} {v₂ = (v' , u')} {swap⋆} (p₁ , p₂) = (sym p₂ , sym p₁)
  pathBInv {v₁ = (u , (v , w))} {v₂ = ((u' , v') , w')} {assocl⋆} (p₁ , p₂ , p₃) 
    = (sym p₁ , sym p₂ , sym p₃)
  pathBInv {v₁ = ((u , v) , w)} {v₂ = (u' , (v' , w'))} {assocr⋆} (p₁ , p₂ , p₃) 
    = (sym p₁ , sym p₂ , sym p₃)
  pathBInv {v₁ = _} {v₂ = ()} {distz}
  pathBInv {v₁ = ()} {v₂ = _} {factorz} 
  pathBInv {v₁ = (inj₁ v₁ , v₃)} {v₂ = inj₁ (v₁' , v₃')} {dist} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathBInv {v₁ = (inj₁ v₁ , v₃)} {v₂ = inj₂ (v₂' , v₃')} {dist} ()
  pathBInv {v₁ = (inj₂ v₂ , v₃)} {v₂ = inj₁ (v₁' , v₃')} {dist} ()
  pathBInv {v₁ = (inj₂ v₂ , v₃)} {v₂ = inj₂ (v₂' , v₃')} {dist} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathBInv {v₁ = inj₁ (v₁ , v₃)} {v₂ = (inj₁ v₁' , v₃')} {factor} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathBInv {v₁ = inj₁ (v₁ , v₃)} {v₂ = (inj₂ v₂' , v₃')} {factor} ()
  pathBInv {v₁ = inj₂ (v₂ , v₃)} {v₂ = (inj₁ v₁' , v₃')} {factor} ()
  pathBInv {v₁ = inj₂ (v₂ , v₃)} {v₂ = (inj₂ v₂' , v₃')} {factor} (p₁ , p₂) = 
    (sym p₁ , sym p₂)
  pathBInv {v₁ = v} {v₂ = v'} {id⟷} p = sym p
  pathBInv {v₁ = v} {v₂ = v'} {sym⟷ c} p = pathInv {v₁ = v'} {v₂ = v} {c} p
  pathBInv {t₁} {t₂} {v₁} {v₂} {c₁ ◎ c₂} (u , (p₂ , p₁)) = 
    (u , (pathBInv {v₁ = v₁} {v₂ = u} {c = c₁} p₁ , 
          pathBInv {v₁ = u} {v₂ = v₂} {c = c₂} p₂))
  pathBInv {v₁ = inj₁ v} {v₂ = inj₁ v'} {c₁ ⊕ c₂} p = pathBInv {c = c₁} p
  pathBInv {v₁ = inj₁ v} {v₂ = inj₂ v'} {c₁ ⊕ c₂} ()
  pathBInv {v₁ = inj₂ v} {v₂ = inj₁ v'} {c₁ ⊕ c₂} ()
  pathBInv {v₁ = inj₂ v} {v₂ = inj₂ v'} {c₁ ⊕ c₂} p = pathBInv {c = c₂} p 
  pathBInv {v₁ = (u , v)} {v₂ = (u' , v')} {c₁ ⊗ c₂} (p₁ , p₂) = 
    (pathBInv {c = c₁} p₁ , pathBInv {c = c₂} p₂)

-- for every paths from v1 to v2 and from v2 to v3, there is a path from v1
-- to v3 that (obviously) goes through v2

pathTrans : {t₁ t₂ t₃ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧} {v₃ : ⟦ t₃ ⟧} 
            {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} → 
            Paths c₁ v₁ v₂ → Paths c₂ v₂ v₃ → Paths (c₁ ◎ c₂) v₁ v₃
pathTrans {v₂ = v₂} p q = (v₂ , p , q)

pathBTrans : {t₁ t₂ t₃ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧} {v₃ : ⟦ t₃ ⟧} 
             {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} → 
             PathsB c₁ v₂ v₁ → PathsB c₂ v₃ v₂ → PathsB (c₁ ◎ c₂) v₃ v₁
pathBTrans {v₂ = v₂} p q = (v₂ , q , p)

-- we always have a canonical path from v to v
pathId : {t : U} {v : ⟦ t ⟧} → Paths id⟷ v v
pathId {v = v} = refl v

------------------------------------------------------------------------------
-- Int construction
-- this will allow us to represents paths as values and then define 2paths
-- between them

data DU : Set where
  diff : U → U → DU

pos : DU → U
pos (diff t₁ t₂) = t₁

neg : DU → U
neg (diff t₁ t₂) = t₂

zeroD : DU
zeroD = diff ZERO ZERO

oneD : DU
oneD = diff ONE ZERO

plusD : DU → DU → DU
plusD (diff t₁ t₂) (diff t₁' t₂') = diff (PLUS t₁ t₁') (PLUS t₂ t₂')

timesD : DU → DU → DU
timesD (diff t₁ t₂) (diff t₁' t₂') = 
  diff (PLUS (TIMES t₁ t₁') (TIMES t₂ t₂'))
       (PLUS (TIMES t₂ t₁') (TIMES t₁ t₂'))

dualD : DU → DU
dualD (diff t₁ t₂) = diff t₂ t₁

lolliD : DU → DU → DU
lolliD (diff t₁ t₂) (diff t₁' t₂') = diff (PLUS t₂ t₁') (PLUS t₁ t₂')

_≤=>_ : DU → DU → Set
d₁ ≤=> d₂ = PLUS (pos d₁) (neg d₂) ⟷ PLUS (neg d₁) (pos d₂)
  
idD : {d : DU} → d ≤=> d
idD = swap₊

--curryD : {d₁ d₂ d₃ : DU} → (plusD d₁ d₂ ≤=> d₃) → (d₁ ≤=> lolliD d₂ d₃)
--curryD f = assocl₊ ◎ f ◎ assocr₊
-- take a path and represent it as a value of type lolli and then use
-- ≤=> between these values as the definition of 2paths???

------------------------------------------------------------------------------
-- Can we show:
-- p : Paths c v₁ v₂ == pathTrans p (refl v₂) 

-- Groupoid structure (i.e. laws), for 2Paths.  Some of the rest of
-- the structure is given above already
-- If the following is right, we can come up with syntax (like _[_]⟺[_]_ ) for  p₁ [c₁]⟺[c₂] p₂ .  We really do
-- need to index the ⟺ by the combinators 'explicitly' as Agda can never infer them.
data 2P {t₁ t₂ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧ } : {c₁ c₂ : t₁ ⟷ t₂} → Paths c₁ v₁ v₂ → Paths c₂ v₁ v₂ → Set where
  id2 : {c : t₁ ⟷ t₂} {p : Paths c v₁ v₂} → 2P {c₁ = c} {c} p p
  inv2  : {c₁ c₂ : t₁ ⟷ t₂} {p₁ : Paths c₁ v₁ v₂} {p₂ : Paths c₂ v₁ v₂} → 2P {c₁ = c₁} {c₂} p₁ p₂ → 2P {c₁ = c₂} {c₁} p₂ p₁
  comp2 : {c₁ c₂ c₃ : t₁ ⟷ t₂} {p₁ : Paths c₁ v₁ v₂} {p₂ : Paths c₂ v₁ v₂} {p₃ : Paths c₃ v₁ v₂} →
    2P {c₁ = c₁} {c₂} p₁ p₂ → 2P {c₁ = c₂} {c₃} p₂ p₃ → 2P {c₁ = c₁} {c₃} p₁ p₃
  -- should define composition which effectively does as below??
  lid : {c : t₁ ⟷ t₂} {p : Paths c v₁ v₂} → 2P {c₁ = id⟷ ◎ c} {c} (pathTrans {c₁ = id⟷} {c} pathId p) p
  rid : {c : t₁ ⟷ t₂} {p : Paths c v₁ v₂} → 2P {c₁ = c ◎ id⟷} {c} (pathTrans {c₁ = c} {id⟷} p pathId) p
-- also need:
-- assoc
--  linv : {c : t₁ ⟷ t₂} {p : Paths c v₁ v₂} → 2P {c₁ = c} 
-- linv
-- rinv
-- and perhaps cong, i.e. ◎-resp-2P

mutual 
  2Paths :  {t₁ t₂ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧ } {c₁ c₂ : t₁ ⟷ t₂} {p₁ : Paths c₁ v₁ v₂} {p₂ : Paths c₂ v₁ v₂} → 2P {c₁ = c₁} {c₂} p₁ p₂ → Paths c₁ v₁ v₂ → Paths c₂ v₁ v₂ → Set
  2Paths id2 p₁ p₂ = p₁ ≡ p₂
  2Paths (inv2 p) p₁ p₂ = 2PathsB p p₁ p₂
  2Paths {t₁} {t₂} {v₁} {v₂} (comp2 {c₁ = c₁} {c₂} {c₃} {p₁} {p₂} {p₃} p q) α₁ α₂ = 
      Σ[ r ∈ Paths c₂ v₁ v₂ ] (2P {c₁ = c₁} {c₂} α₁ r × 2P {c₁ = c₂} {c₃} r α₂) 
  2Paths lid (a , refl .a , p₂) p₃ = p₂ ≡ p₃
  2Paths rid (a , p₂ , refl .a) p₃ = p₂ ≡ p₃

  2PathsB : {t₁ t₂ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧ } {c₁ c₂ : t₁ ⟷ t₂} {p₁ : Paths c₁ v₁ v₂} {p₂ : Paths c₂ v₁ v₂} → 2P {c₁ = c₁} {c₂} p₁ p₂ → Paths c₂ v₁ v₂ → Paths c₁ v₁ v₂ → Set
  2PathsB id2 p q = q ≡ p
  2PathsB (inv2 p) p₁ p₂ = 2PathsB p p₂ p₁
  2PathsB (comp2 p q) p₁ p₂ = {!!}
  2PathsB lid p (a , refl .a , p₃) = p ≡ p₃
  2PathsB rid p (a , p₂ , refl .a) = p ≡ p₂

example : 2Paths {t₁ = BOOL} {t₂ = BOOL} {v₁ = FALSE} {v₂ = FALSE} 
          {c₁ = id⟷ ◎ id⟷} {c₂ = id⟷} {p₁ = pathIdIdFF}
          lid pathIdIdFF pathIdFF
example = refl (refl FALSE) 

{--
2Paths : {t₁ t₂ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧} {c₁ c₂ : t₁ ⟷ t₂} → 
         Paths c₁ v₁ v₂ → Paths c₂ v₁ v₂ → Set
2Paths p q = {!!} 

reflR : {t₁ t₂ : U} {v₁ : ⟦ t₁ ⟧} {v₂ : ⟦ t₂ ⟧} {c : t₁ ⟷ t₂} 
        {p : Paths c v₁ v₂} → {q : Paths (c ◎ id⟷) v₁ v₂} → 
        2Paths {t₁} {t₂} {v₁} {v₂} {c} {c ◎ id⟷} p q
reflR {c = unite₊} = {!!}
-- p : Paths unite₊ .v₁ .v₂
-- q : Paths (unite₊ ◎ id⟷) .v₁ .v₂
-- 2Paths p q
reflR {c = uniti₊} = {!!}
reflR {c = swap₊} = {!!}
reflR {c = assocl₊} = {!!}
reflR {c = assocr₊} = {!!}
reflR {c = unite⋆} = {!!}
reflR {c = uniti⋆} = {!!}
reflR {c = swap⋆} = {!!}
reflR {c = assocl⋆} = {!!}
reflR {c = assocr⋆} = {!!}
reflR {c = distz} = {!!}
reflR {c = factorz} = {!!}
reflR {c = dist} = {!!}
reflR {c = factor} = {!!}
reflR {c = id⟷} = {!!}
reflR {c = sym⟷ c} = {!!}
reflR {c = c₁ ◎ c₂} = {!!}
reflR {c = c₁ ⊕ c₂} = {!!}
reflR {c = c₁ ⊗ c₂} = {!!} 
--}

{--
-- If we have a path between v₁ and v₁' and a combinator that connects v₁ to
-- v₂, then the combinator also connects v₁' to some v₂' such that there is
-- path between v₂ and v₂'

pathFunctor : {t₁ t₂ : U} {v₁ v₁' : ⟦ t₁ ⟧} {v₂ v₂' : ⟦ t₂ ⟧} {c : t₁ ⟷ t₂} →
  (v₁ ≡ v₁') → Paths c v₁ v₂ → (v₂ ≡ v₂') → Paths c v₁' v₂'
pathFunctor = {!!} 

All kind of structure to investigate in the HoTT book. Let's push forward
with cubical types though...
--}
  
------------------------------------------------------------------------------
-- N dimensional version

{-
data C : ℕ → Set where
  ZD   : U → C 0
  Node : {n : ℕ} → C n → C n → C (suc n) 

⟦_⟧N : {n : ℕ} → C n → Set
⟦ ZD t ⟧N = ⟦ t ⟧ 
⟦ Node c₁ c₂ ⟧N = ⟦ c₁ ⟧N ⊎ ⟦ c₂ ⟧N

liftN : (n : ℕ) → (t : U) → C n
liftN 0 t = ZD t
liftN (suc n) t = Node (liftN n t) (liftN n ZERO)

zeroN : (n : ℕ) → C n
zeroN n = liftN n ZERO

oneN : (n : ℕ) → C n
oneN n = liftN n ONE

plus : {n : ℕ} → C n → C n → C n
plus (ZD t₁) (ZD t₂) = ZD (PLUS t₁ t₂)
plus (Node c₁ c₂) (Node c₁' c₂') = Node (plus c₁ c₁') (plus c₂ c₂')

times : {m n : ℕ} → C m → C n → C (m + n)
times (ZD t₁) (ZD t₂) = ZD (TIMES t₁ t₂)
times (ZD t) (Node c₁ c₂) = Node (times (ZD t) c₁) (times (ZD t) c₂)
times (Node c₁ c₂) c = Node (times c₁ c) (times c₂ c) 

-- N-dimensional paths connect points in c₁ and c₂ if there is an isomorphism
-- between the types c₁ and c₂. 
  
data _⟺_ : {n : ℕ} → C n → C n → Set where
  baseC : {t₁ t₂ : U} → (t₁ ⟷ t₂) → ((ZD t₁) ⟺ (ZD t₂))
  nodeC : {n : ℕ} {c₁ : C n} {c₂ : C n} {c₃ : C n} {c₄ : C n} → 
          (c₁ ⟺ c₂) → (c₃ ⟺ c₄) → ((Node c₁ c₃) ⟺ (Node c₂ c₄))
--  zerolC : {n : ℕ} {c : C n} → ((Node c c) ⟺ (zeroN (suc n)))
--  zerorC : {n : ℕ} {c : C n} → ((zeroN (suc n)) ⟺ (Node c c))

NPaths : {n : ℕ} {c₁ c₂ : C n} → (c₁ ⟺ c₂) → ⟦ c₁ ⟧N → ⟦ c₂ ⟧N → Set
NPaths (baseC c) v₁ v₂ = Paths c v₁ v₂
NPaths (nodeC α₁ α₂) (inj₁ v₁) (inj₁ v₂) = NPaths α₁ v₁ v₂
NPaths (nodeC α₁ α₂) (inj₁ v₁) (inj₂ v₂) = ⊥ 
NPaths (nodeC α₁ α₂) (inj₂ v₁) (inj₁ v₂) = ⊥ 
NPaths (nodeC α₁ α₂) (inj₂ v₁) (inj₂ v₂) = NPaths α₂ v₁ v₂
--NPaths zerolC v₁ v₂ = {!!}
--NPaths zerorC v₁ v₂ = {!!}

-}
------------------------------------------------------------------------------
