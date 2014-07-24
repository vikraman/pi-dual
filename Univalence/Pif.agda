{-# OPTIONS --without-K #-}

module Pif where

-- open import Data.Bool
-- open import Relation.Nullary.Core using (yes; no)
-- open import Relation.Nullary.Decidable using (True; toWitness; fromWitness)
-- open import Relation.Unary using (Decidable)
-- open import Data.List as L

open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

open import Data.Empty
open import Data.Unit
open import Data.Sum
open import Data.Product

open import Groupoid

infix  2  _□       
infixr 2  _⟷⟨_⟩_   
-- infix  4  _≃_  
infix  4  _∼_  
infixr 10 _◎_
infix 30 _⟷_

------------------------------------------------------------------------------
-- Level 0: 

-- ZERO is a type with no elements
-- ONE is a type with one element 'tt'
-- PLUS ONE ONE is a type with elements 'false' and 'true'
-- and so on for all finite types built from ZERO, ONE, PLUS, and TIMES
-- 
-- We also have that U is a type with elements ZERO, ONE, PLUS ONE ONE, 
--   TIMES BOOL BOOL, etc.

data U : Set where
  ZERO  : U
  ONE   : U
  PLUS  : U → U → U
  TIMES : U → U → U

⟦_⟧ : U → Set 
⟦ ZERO ⟧ = ⊥ 
⟦ ONE ⟧ = ⊤
⟦ PLUS t₁ t₂ ⟧ = ⟦ t₁ ⟧ ⊎ ⟦ t₂ ⟧
⟦ TIMES t₁ t₂ ⟧ = ⟦ t₁ ⟧ × ⟦ t₂ ⟧

{--
elems : (t : U) → List ⟦ t ⟧
elems ZERO = []
elems ONE = L.[ tt ] 
elems (PLUS t₁ t₂) = L.map inj₁ (elems t₁) ++ L.map inj₂ (elems t₂)
elems (TIMES t₁ t₂) = concat 
                        (L.map 
                          (λ v₂ → L.map (λ v₁ → (v₁ , v₂)) (elems t₁))
                         (elems t₂))
--}

BOOL BOOL² : U
BOOL = PLUS ONE ONE 
BOOL² = TIMES BOOL BOOL

false⟷ true⟷ : ⟦ BOOL ⟧
false⟷ = inj₁ tt
true⟷ = inj₂ tt

-- For any finite type (t : U) there is no non-trivial path structure between
-- the elements of t. All such finite types are discrete groupoids
--
-- For U, there are non-trivial paths between its points. In the conventional
-- HoTT presentation, a path between t₁ and t₂ is postulated by univalence
-- for each equivalence between t₁ and t₂. In the context of finite types, an
-- equivalence is generated by a permutation as each permutation has a unique
-- inverse permutation. Instead of the detour using univalence, we can
-- instead give an inductive definition of all possible permutations between
-- finite types and identify all syntactic definitions that denote the same
-- permutation. A complete set of generators for all possible permutations
-- between finite types is given by the following definition:

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
  _◎_     : {t₁ t₂ t₃ : U} → (t₁ ⟷ t₂) → (t₂ ⟷ t₃) → (t₁ ⟷ t₃)
  _⊕_     : {t₁ t₂ t₃ t₄ : U} → 
            (t₁ ⟷ t₃) → (t₂ ⟷ t₄) → (PLUS t₁ t₂ ⟷ PLUS t₃ t₄)
  _⊗_     : {t₁ t₂ t₃ t₄ : U} → 
            (t₁ ⟷ t₃) → (t₂ ⟷ t₄) → (TIMES t₁ t₂ ⟷ TIMES t₃ t₄)

-- Nicer syntax that shows intermediate values instead of point-free
-- combinators

_⟷⟨_⟩_ : (t₁ : U) {t₂ : U} {t₃ : U} → 
          (t₁ ⟷ t₂) → (t₂ ⟷ t₃) → (t₁ ⟷ t₃) 
_ ⟷⟨ α ⟩ β = α ◎ β

_□ : (t : U) → {t : U} → (t ⟷ t)
_□ t = id⟷

-- Every permutation has an inverse

! : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₂ ⟷ t₁)
! unite₊ = uniti₊
! uniti₊ = unite₊
! swap₊ = swap₊
! assocl₊ = assocr₊
! assocr₊ = assocl₊
! unite⋆ = uniti⋆
! uniti⋆ = unite⋆
! swap⋆ = swap⋆
! assocl⋆ = assocr⋆
! assocr⋆ = assocl⋆
! distz = factorz
! factorz = distz
! dist = factor 
! factor = dist
! id⟷ = id⟷
! (c₁ ◎ c₂) = ! c₂ ◎ ! c₁ 
! (c₁ ⊕ c₂) = (! c₁) ⊕ (! c₂)
! (c₁ ⊗ c₂) = (! c₁) ⊗ (! c₂)

!! : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → ! (! c) ≡ c
!! {c = unite₊} = refl
!! {c = uniti₊} = refl
!! {c = swap₊} = refl
!! {c = assocl₊} = refl
!! {c = assocr₊} = refl
!! {c = unite⋆} = refl
!! {c = uniti⋆} = refl
!! {c = swap⋆} = refl
!! {c = assocl⋆} = refl
!! {c = assocr⋆} = refl
!! {c = distz} = refl
!! {c = factorz} = refl
!! {c = dist} = refl
!! {c = factor} = refl
!! {c = id⟷} = refl
!! {c = c₁ ◎ c₂} = 
  begin (! (! (c₁ ◎ c₂))
           ≡⟨ refl ⟩
         ! (! c₂ ◎ ! c₁)
           ≡⟨ refl ⟩ 
         ! (! c₁) ◎ ! (! c₂)
           ≡⟨ cong₂ _◎_ (!! {c = c₁}) (!! {c = c₂}) ⟩ 
         c₁ ◎ c₂ ∎)
!! {c = c₁ ⊕ c₂} = 
  begin (! (! (c₁ ⊕ c₂))
           ≡⟨ refl ⟩
         ! (! c₁) ⊕ ! (! c₂)
           ≡⟨ cong₂ _⊕_ (!! {c = c₁}) (!! {c = c₂}) ⟩ 
         c₁ ⊕ c₂ ∎)
!! {c = c₁ ⊗ c₂} = 
  begin (! (! (c₁ ⊗ c₂))
           ≡⟨ refl ⟩
         ! (! c₁) ⊗ ! (! c₂)
           ≡⟨ cong₂ _⊗_ (!! {c = c₁}) (!! {c = c₂}) ⟩ 
         c₁ ⊗ c₂ ∎)

-- Functional representation of permutations is used to decide whether two
-- permutations are "the same".

path2fun : {t₁ t₂ : U} → (t₁ ⟷ t₂) → ⟦ t₁ ⟧ → ⟦ t₂ ⟧
path2fun unite₊ (inj₁ ())
path2fun unite₊ (inj₂ v) = v
path2fun uniti₊ v = inj₂ v
path2fun swap₊ (inj₁ v) = inj₂ v
path2fun swap₊ (inj₂ v) = inj₁ v
path2fun assocl₊ (inj₁ v) = inj₁ (inj₁ v)
path2fun assocl₊ (inj₂ (inj₁ v)) = inj₁ (inj₂ v)
path2fun assocl₊ (inj₂ (inj₂ v)) = inj₂ v
path2fun assocr₊ (inj₁ (inj₁ v)) = inj₁ v
path2fun assocr₊ (inj₁ (inj₂ v)) = inj₂ (inj₁ v)
path2fun assocr₊ (inj₂ v) = inj₂ (inj₂ v)
path2fun unite⋆ (tt , v) = v
path2fun uniti⋆ v = (tt , v)
path2fun swap⋆ (v₁ , v₂) = (v₂ , v₁)
path2fun assocl⋆ (v₁ , (v₂ , v₃)) = ((v₁ , v₂) , v₃)
path2fun assocr⋆ ((v₁ , v₂) , v₃) = (v₁ , (v₂ , v₃))
path2fun distz (() , v)
path2fun factorz ()
path2fun dist (inj₁ v₁ , v) = inj₁ (v₁ , v)
path2fun dist (inj₂ v₂ , v) = inj₂ (v₂ , v)
path2fun factor (inj₁ (v₁ , v)) = (inj₁ v₁ , v)
path2fun factor (inj₂ (v₂ , v)) = (inj₂ v₂ , v)
path2fun id⟷ v = v
path2fun (c₁ ◎ c₂) v = path2fun c₂ (path2fun c₁ v)
path2fun (c₁ ⊕ c₂) (inj₁ v) = inj₁ (path2fun c₁ v)
path2fun (c₁ ⊕ c₂) (inj₂ v) = inj₂ (path2fun c₂ v)
path2fun (c₁ ⊗ c₂) (v₁ , v₂) = (path2fun c₁ v₁ , path2fun c₂ v₂)

-- A few lemmas about functional representations of permutations

invl : {t₁ t₂ : U} {c : t₁ ⟷ t₂} {v : ⟦ t₁ ⟧} → 
       path2fun (! c) (path2fun c v) ≡ v
invl {c = unite₊} {inj₁ ()} 
invl {c = unite₊} {inj₂ v} = refl
invl {c = uniti₊} {v} = refl
invl {c = swap₊} {inj₁ v} = refl
invl {c = swap₊} {inj₂ v} = refl
invl {c = assocl₊} {inj₁ v} = refl
invl {c = assocl₊} {inj₂ (inj₁ v)} = refl
invl {c = assocl₊} {inj₂ (inj₂ v)} = refl
invl {c = assocr₊} {inj₁ (inj₁ v)} = refl
invl {c = assocr₊} {inj₁ (inj₂ v)} = refl
invl {c = assocr₊} {inj₂ v} = refl
invl {c = unite⋆} {(tt , v)} = refl
invl {c = uniti⋆} {v} = refl
invl {c = swap⋆} {(v₁ , v₂)} = refl
invl {c = assocl⋆} {(v₁ , (v₂ , v₃))} = refl
invl {c = assocr⋆} {((v₁ , v₂) , v₃)} = refl
invl {c = distz} {(() , v)}
invl {c = factorz} {()}
invl {c = dist} {(inj₁ v₁ , v)} = refl
invl {c = dist} {(inj₂ v₂ , v)} = refl
invl {c = factor} {inj₁ (v₁ , v)} = refl
invl {c = factor} {inj₂ (v₂ , v)} = refl
invl {c = id⟷} {v} = refl
invl {t₁} {t₃} {c = _◎_ {t₂ = t₂} c₁ c₂} {v} = 
  begin (path2fun (! (c₁ ◎ c₂)) (path2fun (c₁ ◎ c₂) v) 
           ≡⟨ refl ⟩
         path2fun (! c₁) (path2fun (! c₂) (path2fun c₂ (path2fun c₁ v)))
           ≡⟨  cong (λ x → path2fun (! c₁) x) 
                   (invl {t₂} {t₃} {c₂} {path2fun c₁ v}) ⟩ 
         path2fun (! c₁) (path2fun c₁ v)
           ≡⟨ invl {t₁} {t₂} {c₁} {v} ⟩
         v ∎)
invl {PLUS t₁ t₂} {PLUS t₃ t₄} {c = c₁ ⊕ c₂} {inj₁ v} = 
  begin (path2fun (! (c₁ ⊕ c₂)) (path2fun (c₁ ⊕ c₂) (inj₁ v))
           ≡⟨ refl ⟩ 
         path2fun (! c₁ ⊕ ! c₂) (inj₁ (path2fun c₁ v))
           ≡⟨ refl ⟩
         inj₁ (path2fun (! c₁) (path2fun c₁ v))
           ≡⟨ cong inj₁ (invl {t₁} {t₃} {c₁} {v}) ⟩ 
         inj₁ v ∎)
invl {PLUS t₁ t₂} {PLUS t₃ t₄} {c = c₁ ⊕ c₂} {inj₂ v} = 
  begin (path2fun (! (c₁ ⊕ c₂)) (path2fun (c₁ ⊕ c₂) (inj₂ v))
           ≡⟨ refl ⟩ 
         path2fun (! c₁ ⊕ ! c₂) (inj₂ (path2fun c₂ v))
           ≡⟨ refl ⟩
         inj₂ (path2fun (! c₂) (path2fun c₂ v))
           ≡⟨ cong inj₂ (invl {t₂} {t₄} {c₂} {v}) ⟩ 
         inj₂ v ∎)
invl {TIMES t₁ t₂} {TIMES t₃ t₄} {c = c₁ ⊗ c₂} {(v₁ , v₂)} = 
  begin (path2fun (! (c₁ ⊗ c₂)) (path2fun (c₁ ⊗ c₂) (v₁ , v₂))
           ≡⟨ refl ⟩ 
         path2fun (! c₁ ⊗ ! c₂) (path2fun c₁ v₁ , path2fun c₂ v₂)
           ≡⟨ refl ⟩ 
         (path2fun (! c₁) (path2fun c₁ v₁) , path2fun (! c₂) (path2fun c₂ v₂))
           ≡⟨ cong₂ _,_ 
               (invl {t₁} {t₃} {c₁} {v₁})
               (invl {t₂} {t₄} {c₂} {v₂}) ⟩ 
         (v₁ , v₂) ∎)

invr : {t₁ t₂ : U} {c : t₁ ⟷ t₂} {v : ⟦ t₂ ⟧} → 
       path2fun c (path2fun (! c) v) ≡ v
invr {c = unite₊} {v} = refl
invr {c = uniti₊} {inj₁ ()} 
invr {c = uniti₊} {inj₂ v} = refl
invr {c = swap₊} {inj₁ v} = refl
invr {c = swap₊} {inj₂ v} = refl
invr {c = assocl₊} {inj₁ (inj₁ v)} = refl
invr {c = assocl₊} {inj₁ (inj₂ v)} = refl
invr {c = assocl₊} {inj₂ v} = refl
invr {c = assocr₊} {inj₁ v} = refl
invr {c = assocr₊} {inj₂ (inj₁ v)} = refl
invr {c = assocr₊} {inj₂ (inj₂ v)} = refl
invr {c = unite⋆} {v} = refl
invr {c = uniti⋆} {(tt , v)} = refl
invr {c = swap⋆} {(v₁ , v₂)} = refl
invr {c = assocl⋆} {((v₁ , v₂) , v₃)} = refl
invr {c = assocr⋆} {(v₁ , (v₂ , v₃))} = refl
invr {c = distz} {()}
invr {c = factorz} {(() , v)}
invr {c = dist} {inj₁ (v₁ , v)} = refl
invr {c = dist} {inj₂ (v₂ , v)} = refl
invr {c = factor} {(inj₁ v₁ , v)} = refl
invr {c = factor} {(inj₂ v₂ , v)} = refl
invr {c = id⟷} {v} = refl
invr {t₁} {t₃} {c = _◎_ {t₂ = t₂} c₁ c₂} {v} = 
  begin (path2fun (c₁ ◎ c₂) (path2fun (! (c₁ ◎ c₂)) v) 
           ≡⟨ refl ⟩
         path2fun c₂ (path2fun c₁ (path2fun (! c₁) (path2fun (! c₂) v)))
           ≡⟨  cong (λ x → path2fun c₂ x)
                   (invr {t₁} {t₂} {c₁} {path2fun (! c₂) v}) ⟩ 
         path2fun c₂ (path2fun (! c₂) v)
           ≡⟨ invr {t₂} {t₃} {c₂} {v} ⟩
         v ∎)
invr {PLUS t₁ t₂} {PLUS t₃ t₄} {c = c₁ ⊕ c₂} {inj₁ v} = 
  begin (path2fun (c₁ ⊕ c₂) (path2fun (! (c₁ ⊕ c₂)) (inj₁ v))
           ≡⟨ refl ⟩ 
         path2fun (c₁ ⊕ c₂) (inj₁ (path2fun (! c₁) v))
           ≡⟨ refl ⟩
         inj₁ (path2fun c₁ (path2fun (! c₁) v))
           ≡⟨ cong inj₁ (invr {t₁} {t₃} {c₁} {v}) ⟩ 
         inj₁ v ∎)
invr {PLUS t₁ t₂} {PLUS t₃ t₄} {c = c₁ ⊕ c₂} {inj₂ v} = 
  begin (path2fun (c₁ ⊕ c₂) (path2fun (! (c₁ ⊕ c₂)) (inj₂ v))
           ≡⟨ refl ⟩ 
         path2fun (c₁ ⊕ c₂) (inj₂ (path2fun (! c₂) v))
           ≡⟨ refl ⟩
         inj₂ (path2fun c₂ (path2fun (! c₂) v))
           ≡⟨ cong inj₂ (invr {t₂} {t₄} {c₂} {v}) ⟩ 
         inj₂ v ∎)
invr {TIMES t₁ t₂} {TIMES t₃ t₄} {c = c₁ ⊗ c₂} {(v₁ , v₂)} = 
  begin (path2fun (c₁ ⊗ c₂) (path2fun (! (c₁ ⊗ c₂)) (v₁ , v₂))
           ≡⟨ refl ⟩ 
         path2fun (c₁ ⊗ c₂) (path2fun (! c₁) v₁ , path2fun (! c₂) v₂)
           ≡⟨ refl ⟩ 
         (path2fun c₁ (path2fun (! c₁) v₁) , path2fun c₂ (path2fun (! c₂) v₂))
           ≡⟨ cong₂ _,_ 
               (invr {t₁} {t₃} {c₁} {v₁})
               (invr {t₂} {t₄} {c₂} {v₂}) ⟩ 
         (v₁ , v₂) ∎)

------------------------------------------------------------------------------
-- Paths as values

-- We started with two kind of types: 
--   * types t : U which were discrete groupoids
--   * the type U itself which has a non-trivial path structure
--
-- The non-trivial path structure of U induces more types:
--   * for each pair of types t₁ and t₂ there is a new type (or space) 
--       (t₁ ⟷ t₂) whose elements are the paths between t₁ and t₂. This 
--       space has a non-trivial 2path structure. For example, the space 
--       (BOOL ⟷ BOOL) has as its elements id⟷, not, not ◎ id⟷, etc.
--       Of course we expect that there is a 2path between not 
--       and not ◎ id⟷
--   * the collection of all spaces (t₁ ⟷ t₂) closed under sums and products
--       itself constitutes a type ΩU. For example, the space (t₁ ⟷ t₂) × (t₃
--       ⟷ t₄) is related to the space (t₁ × t₃ ⟷ t₂ × t₄).

-- We start with the individual path spaces and show that they are groupoids

data Path (t₁ t₂ : U) : Set where
  path : (c : t₁ ⟷ t₂) → Path t₁ t₂

-- two combinators are the same if they denote the same permutation

_∼_ : {t₁ t₂ : U} → (c₁ c₂ : t₁ ⟷ t₂) → Set
_∼_ {t₁} {t₂} c₁ c₂ = (v : ⟦ t₁ ⟧) → path2fun c₁ v ≡ path2fun c₂ v

-- Lemma 2.4.2

c∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ∼ c 
c∼c _ = refl 

-- Lemma 2.1.4

c∼c◎id : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ∼ (c ◎ id⟷)
c∼c◎id {t₁} {t₂} {c} v = 
  (begin (path2fun c v)
           ≡⟨ refl ⟩
         (path2fun c (path2fun id⟷ v))
           ≡⟨ refl ⟩
         (path2fun (c ◎ id⟷) v) ∎)

c∼id◎c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ∼ (id⟷ ◎ c)
c∼id◎c {t₁} {t₂} {c} v = 
  (begin (path2fun c v)
           ≡⟨ refl ⟩
         (path2fun id⟷ (path2fun c v))
           ≡⟨ refl ⟩
         (path2fun (id⟷ ◎ c) v) ∎)

!c◎c∼id : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (! c) ◎ c ∼ id⟷
!c◎c∼id {t₁} {t₂} {c} v = 
  (begin (path2fun ((! c) ◎ c) v)
           ≡⟨ refl ⟩
         (path2fun c (path2fun (! c) v))
           ≡⟨ invr {t₁} {t₂} {c} {v} ⟩
         (path2fun id⟷ v) ∎)

c◎!c∼id : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ◎ (! c) ∼ id⟷
c◎!c∼id {t₁} {t₂} {c} v = 
  (begin (path2fun (c ◎ (! c)) v)
           ≡⟨ refl ⟩
         (path2fun (! c) (path2fun c v))
           ≡⟨ invl {t₁} {t₂} {c} {v} ⟩
         (path2fun id⟷ v) ∎)


!!c∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → ! (! c) ∼ c
!!c∼c {t₁} {t₂} {c} v = 
  begin (path2fun (! (! c)) v
           ≡⟨ cong (λ x → path2fun x v) (!! {c = c}) ⟩ 
         path2fun c v ∎)

assoc◎ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
         c₁ ◎ (c₂ ◎ c₃) ∼ (c₁ ◎ c₂) ◎ c₃
assoc◎ {t₁} {t₂} {t₃} {t₄} {c₁} {c₂} {c₃} v = 
  begin (path2fun (c₁ ◎ (c₂ ◎ c₃)) v 
           ≡⟨ refl ⟩
         path2fun (c₂ ◎ c₃) (path2fun c₁ v)
           ≡⟨ refl ⟩
         path2fun c₃ (path2fun c₂ (path2fun c₁ v))
           ≡⟨ refl ⟩
         path2fun c₃ (path2fun (c₁ ◎ c₂) v)
           ≡⟨ refl ⟩
         path2fun ((c₁ ◎ c₂) ◎ c₃) v ∎)

-- and in that case there is a 2path between them in the relevant path space

data _⇔_ {t₁ t₂ : U} : Path t₁ t₂ → Path t₁ t₂ → Set where
  2path : {c₁ c₂ : t₁ ⟷ t₂} → (α : c₁ ∼ c₂) → path c₁ ⇔ path c₂

-- Examples

p q r : Path BOOL BOOL
p = path id⟷
q = path swap₊
r = path (swap₊ ◎ id⟷)

α : q ⇔ r
α = 2path (c∼c◎id {c = swap₊})

-- Each path space is a groupoid; we show that it is a 1groupoid using ≡ at
-- higher levels

G : (t₁ t₂ : U) → 1Groupoid
G t₁ t₂ = record
        { set = Path t₁ t₂
        ; _↝_ = _⇔_
        ; _≈_ = _≡_ 
        ; id = λ { {path c} → 2path (c∼c {c = c}) } 
        ; _∘_ = {!!} 
        ; _⁻¹ = {!!} 
        ; lneutr = {!!} 
        ; rneutr = {!!} 
        ; assoc = {!!} 
        ; equiv = record { refl = {!!} 
                         ; sym = {!!} 
                         ; trans = {!!} 
                         }
        ; linv = {!!} 
        ; rinv = {!!} 
        ; ∘-resp-≈ = {!!} 
        }


{--

data ΩU : Set where
  ΩZERO  : ΩU              -- empty set of paths
  ΩONE   : ΩU              -- a trivial path
  ΩPLUS  : ΩU → ΩU → ΩU      -- disjoint union of paths
  ΩTIMES : ΩU → ΩU → ΩU      -- pairs of paths
  PATH  : (t₁ t₂ : U) → ΩU -- level 0 paths between values

-- values

Ω⟦_⟧ : ΩU → Set
Ω⟦ ΩZERO ⟧             = ⊥
Ω⟦ ΩONE ⟧              = ⊤
Ω⟦ ΩPLUS t₁ t₂ ⟧       = Ω⟦ t₁ ⟧ ⊎ Ω⟦ t₂ ⟧
Ω⟦ ΩTIMES t₁ t₂ ⟧      = Ω⟦ t₁ ⟧ × Ω⟦ t₂ ⟧
Ω⟦ PATH t₁ t₂ ⟧ = Path t₁ t₂

-- two combinators are the same if they denote the same permutation


-- 2paths

data _⇔_ : ΩU → ΩU → Set where
  unite₊  : {t : ΩU} → ΩPLUS ΩZERO t ⇔ t
  uniti₊  : {t : ΩU} → t ⇔ ΩPLUS ΩZERO t
  swap₊   : {t₁ t₂ : ΩU} → ΩPLUS t₁ t₂ ⇔ ΩPLUS t₂ t₁
  assocl₊ : {t₁ t₂ t₃ : ΩU} → ΩPLUS t₁ (ΩPLUS t₂ t₃) ⇔ ΩPLUS (ΩPLUS t₁ t₂) t₃
  assocr₊ : {t₁ t₂ t₃ : ΩU} → ΩPLUS (ΩPLUS t₁ t₂) t₃ ⇔ ΩPLUS t₁ (ΩPLUS t₂ t₃)
  unite⋆  : {t : ΩU} → ΩTIMES ΩONE t ⇔ t
  uniti⋆  : {t : ΩU} → t ⇔ ΩTIMES ΩONE t
  swap⋆   : {t₁ t₂ : ΩU} → ΩTIMES t₁ t₂ ⇔ ΩTIMES t₂ t₁
  assocl⋆ : {t₁ t₂ t₃ : ΩU} → ΩTIMES t₁ (ΩTIMES t₂ t₃) ⇔ ΩTIMES (ΩTIMES t₁ t₂) t₃
  assocr⋆ : {t₁ t₂ t₃ : ΩU} → ΩTIMES (ΩTIMES t₁ t₂) t₃ ⇔ ΩTIMES t₁ (ΩTIMES t₂ t₃)
  distz   : {t : ΩU} → ΩTIMES ΩZERO t ⇔ ΩZERO
  factorz : {t : ΩU} → ΩZERO ⇔ ΩTIMES ΩZERO t
  dist    : {t₁ t₂ t₃ : ΩU} → 
            ΩTIMES (ΩPLUS t₁ t₂) t₃ ⇔ ΩPLUS (ΩTIMES t₁ t₃) (ΩTIMES t₂ t₃) 
  factor  : {t₁ t₂ t₃ : ΩU} → 
            ΩPLUS (ΩTIMES t₁ t₃) (ΩTIMES t₂ t₃) ⇔ ΩTIMES (ΩPLUS t₁ t₂) t₃
  id⇔  : {t : ΩU} → t ⇔ t
  _◎_  : {t₁ t₂ t₃ : ΩU} → (t₁ ⇔ t₂) → (t₂ ⇔ t₃) → (t₁ ⇔ t₃)
  _⊕_  : {t₁ t₂ t₃ t₄ : ΩU} → 
         (t₁ ⇔ t₃) → (t₂ ⇔ t₄) → (ΩPLUS t₁ t₂ ⇔ ΩPLUS t₃ t₄)
  _⊗_  : {t₁ t₂ t₃ t₄ : ΩU} → 
         (t₁ ⇔ t₃) → (t₂ ⇔ t₄) → (ΩTIMES t₁ t₂ ⇔ ΩTIMES t₃ t₄)
  _∼⇔_ : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → 
         PATH t₁ t₂ ⇔ PATH t₁ t₂

-- two spaces are equivalent if there is a path between them; this path
-- automatically has an inverse which is an equivalence. It is a
-- quasi-equivalence but for finite types that's the same as an equivalence.

_≃_ : (t₁ t₂ : U) → Set
t₁ ≃ t₂ = (t₁ ⟷ t₂)

-- Univalence says (t₁ ≃ t₂) ≃ (t₁ ⟷ t₂) but as shown above, we actually have
-- this by definition instead of up to ≃

--}

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

{--
another idea is to look at c and massage it as follows: rewrite every 
swap+ ; c
to 
c' ; swaps ; c''

general start with 
 id || id || c
examine c and move anything that's not swap to left. If we get to
 c' || id || id
we are done
if we get to:
 c' || id || swap+;c
then we rewrite
 c';c1 || swaps || c2;c
and we keep going
--}

{--
module Phase₁ where

  -- no occurrences of (TIMES (TIMES t₁ t₂) t₃)

{-- approach that maintains the invariants in proofs

  invariant : (t : U) → Bool
  invariant ZERO = true
  invariant ONE = true
  invariant (PLUS t₁ t₂) = invariant t₁ ∧ invariant t₂ 
  invariant (TIMES ZERO t₂) = invariant t₂
  invariant (TIMES ONE t₂) = invariant t₂
  invariant (TIMES (PLUS t₁ t₂) t₃) = (invariant t₁ ∧ invariant t₂) ∧ invariant t₃
  invariant (TIMES (TIMES t₁ t₂) t₃) = false

  Invariant : (t : U) → Set
  Invariant t = invariant t ≡ true

  invariant? : Decidable Invariant
  invariant? t with invariant t 
  ... | true = yes refl
  ... | false = no (λ ())

  conj : ∀ {b₁ b₂} → (b₁ ≡ true) → (b₂ ≡ true) → (b₁ ∧ b₂ ≡ true)
  conj {true} {true} p q = refl
  conj {true} {false} p ()
  conj {false} {true} ()
  conj {false} {false} ()

  phase₁ : (t₁ : U) → Σ[ t₂ ∈ U ] (True (invariant? t₂) × t₁ ⟷ t₂)
  phase₁ ZERO = (ZERO , (fromWitness {Q = invariant? ZERO} refl , id⟷))
  phase₁ ONE = (ONE , (fromWitness {Q = invariant? ONE} refl , id⟷))
  phase₁ (PLUS t₁ t₂) with phase₁ t₁ | phase₁ t₂
  ... | (t₁' , (p₁ , c₁)) | (t₂' , (p₂ , c₂)) with toWitness p₁ | toWitness p₂
  ... | t₁'ok | t₂'ok = 
    (PLUS t₁' t₂' , 
      (fromWitness {Q = invariant? (PLUS t₁' t₂')} (conj t₁'ok t₂'ok) , 
      c₁ ⊕ c₂))
  phase₁ (TIMES ZERO t) with phase₁ t
  ... | (t' , (p , c)) with toWitness p 
  ... | t'ok = 
    (TIMES ZERO t' , 
      (fromWitness {Q = invariant? (TIMES ZERO t')} t'ok , 
      id⟷ ⊗ c))
  phase₁ (TIMES ONE t) with phase₁ t 
  ... | (t' , (p , c)) with toWitness p
  ... | t'ok = 
    (TIMES ONE t' , 
      (fromWitness {Q = invariant? (TIMES ONE t')} t'ok , 
      id⟷ ⊗ c))
  phase₁ (TIMES (PLUS t₁ t₂) t₃) with phase₁ t₁ | phase₁ t₂ | phase₁ t₃
  ... | (t₁' , (p₁ , c₁)) | (t₂' , (p₂ , c₂)) | (t₃' , (p₃ , c₃)) 
    with toWitness p₁ | toWitness p₂ | toWitness p₃ 
  ... | t₁'ok | t₂'ok | t₃'ok = 
    (TIMES (PLUS t₁' t₂') t₃' , 
      (fromWitness {Q = invariant? (TIMES (PLUS t₁' t₂') t₃')}
        (conj (conj t₁'ok t₂'ok) t₃'ok) , 
      (c₁ ⊕ c₂) ⊗ c₃))
  phase₁ (TIMES (TIMES t₁ t₂) t₃) = {!!} 
--}

  -- invariants are informal
  -- rewrite (TIMES (TIMES t₁ t₂) t₃) to TIMES t₁ (TIMES t₂ t₃)
  invariant : (t : U) → Bool
  invariant ZERO = true
  invariant ONE = true
  invariant (PLUS t₁ t₂) = invariant t₁ ∧ invariant t₂ 
  invariant (TIMES ZERO t₂) = invariant t₂
  invariant (TIMES ONE t₂) = invariant t₂
  invariant (TIMES (PLUS t₁ t₂) t₃) = invariant t₁ ∧ invariant t₂ ∧ invariant t₃
  invariant (TIMES (TIMES t₁ t₂) t₃) = false

  step₁ : (t₁ : U) → Σ[ t₂ ∈ U ] (t₁ ⟷ t₂)
  step₁ ZERO = (ZERO , id⟷)
  step₁ ONE = (ONE , id⟷)
  step₁ (PLUS t₁ t₂) with step₁ t₁ | step₁ t₂
  ... | (t₁' , c₁) | (t₂' , c₂) = (PLUS t₁' t₂' , c₁ ⊕ c₂)
  step₁ (TIMES (TIMES t₁ t₂) t₃) with step₁ t₁ | step₁ t₂ | step₁ t₃
  ... | (t₁' , c₁) | (t₂' , c₂) | (t₃' , c₃) = 
    (TIMES t₁' (TIMES t₂' t₃') , ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆)
  step₁ (TIMES ZERO t₂) with step₁ t₂ 
  ... | (t₂' , c₂) = (TIMES ZERO t₂' , id⟷ ⊗ c₂)
  step₁ (TIMES ONE t₂) with step₁ t₂ 
  ... | (t₂' , c₂) = (TIMES ONE t₂' , id⟷ ⊗ c₂)
  step₁ (TIMES (PLUS t₁ t₂) t₃) with step₁ t₁ | step₁ t₂ | step₁ t₃
  ... | (t₁' , c₁) | (t₂' , c₂) | (t₃' , c₃) = 
    (TIMES (PLUS t₁' t₂') t₃' , (c₁ ⊕ c₂) ⊗ c₃)

  {-# NO_TERMINATION_CHECK #-}
  phase₁ : (t₁ : U) → Σ[ t₂ ∈ U ] (t₁ ⟷ t₂)
  phase₁ t with invariant t
  ... | true = (t , id⟷)
  ... | false with step₁ t
  ... | (t' , c) with phase₁ t'
  ... | (t'' , c') = (t'' , c ◎ c')

  test₁ = phase₁ (TIMES (TIMES (TIMES ONE ONE) (TIMES ONE ONE)) ONE)
  {--
  TIMES ONE (TIMES ONE (TIMES ONE (TIMES ONE ONE))) ,
  (((id⟷ ⊗ id⟷) ⊗ (id⟷ ⊗ id⟷)) ⊗ id⟷ ◎ assocr⋆) ◎
  ((id⟷ ⊗ id⟷) ⊗ ((id⟷ ⊗ id⟷) ⊗ id⟷ ◎ assocr⋆) ◎ assocr⋆) ◎ id⟷
  --}

  -- Now any combinator (t₁ ⟷ t₂) can be transformed to a canonical
  -- representation in which we first associate all the TIMES to the right
  -- and then do the rest of the combinator

  normalize₁ : {t₁ t₂ : U} → (t₁ ⟷ t₂) → 
               (Σ[ t₁' ∈ U ] (t₁ ⟷ t₁' × t₁' ⟷ t₂))
  normalize₁ {ZERO} {t} c = ZERO , id⟷ , c
  normalize₁ {ONE} c = ONE , id⟷ , c
  normalize₁ {PLUS .ZERO t₂} unite₊ with phase₁ t₂
  ... | (t₂n , cn) = PLUS ZERO t₂n , id⟷ ⊕ cn , unite₊ ◎ ! cn
  normalize₁ {PLUS t₁ t₂} uniti₊ = {!!}
  normalize₁ {PLUS t₁ t₂} swap₊ = {!!}
  normalize₁ {PLUS t₁ ._} assocl₊ = {!!}
  normalize₁ {PLUS ._ t₂} assocr₊ = {!!}
  normalize₁ {PLUS t₁ t₂} uniti⋆ = {!!}
  normalize₁ {PLUS ._ ._} factor = {!!}
  normalize₁ {PLUS t₁ t₂} id⟷ = {!!}
  normalize₁ {PLUS t₁ t₂} (c ◎ c₁) = {!!}
  normalize₁ {PLUS t₁ t₂} (c ⊕ c₁) = {!!} 
  normalize₁ {TIMES t₁ t₂} c = {!!}
--}

{--

record Permutation (t t' : U) : Set where
  field
    t₀ : U -- no occurrences of TIMES .. (TIMES .. ..)
    phase₀ : t ⟷ t₀    
    t₁ : U   -- no occurrences of TIMES (PLUS .. ..)
    phase₁ : t₀ ⟷ t₁
    t₂ : U   -- no occurrences of TIMES
    phase₂ : t₁ ⟷ t₂
    t₃ : U   -- no nested left PLUS, all PLUS of form PLUS simple (PLUS ...)
    phase₃ : t₂ ⟷ t₃
    t₄ : U   -- no occurrences PLUS ZERO
    phase₄ : t₃ ⟷ t₄
    t₅ : U   -- do actual permutation using swapij
    phase₅ : t₄ ⟷ t₅
    rest : t₅ ⟷ t' -- blah blah

canonical : {t₁ t₂ : U} → (t₁ ⟷ t₂) → Permutation t₁ t₂
canonical c = {!!}

------------------------------------------------------------------------------
-- These paths do NOT reach "inside" the finite sets. For example, there is
-- NO PATH between false and true in BOOL even though there is a path between
-- BOOL and BOOL that "twists the space around."
-- 
-- In more detail how do these paths between types relate to the whole
-- discussion about higher groupoid structure of type formers (Sec. 2.5 and
-- on).

-- Then revisit the early parts of Ch. 2 about higher groupoid structure for
-- U, how functions from U to U respect the paths in U, type families and
-- dependent functions, homotopies and equivalences, and then Sec. 2.5 and
-- beyond again.


{--
should this be on the code as done now or on their interpreation
i.e. data _⟷_ : ⟦ U ⟧ → ⟦ U ⟧ → Set where

can add recursive types 
rec : U
⟦_⟧ takes an additional argument X that is passed around
⟦ rec ⟧ X = X
fixpoitn
data μ (t : U) : Set where
 ⟨_⟩ : ⟦ t ⟧ (μ t) → μ t
--}

-- We identify functions with the paths above. Since every function is
-- reversible, every function corresponds to a path and there is no
-- separation between functions and paths and no need to mediate between them
-- using univalence.
--
-- Note that none of the above functions are dependent functions.

------------------------------------------------------------------------------
-- Now we consider homotopies, i.e., paths between functions. Since our
-- functions are identified with the paths ⟷, the homotopies are paths
-- between elements of ⟷

-- First, a sanity check. Our notion of paths matches the notion of
-- equivalences in the conventional HoTT presentation

-- Homotopy between two functions (paths)

-- That makes id ∼ not which is bad. The def. of ∼ should be parametric...

_∼_ : {t₁ t₂ t₃ : U} → (f : t₁ ⟷ t₂) → (g : t₁ ⟷ t₃) → Set
_∼_ {t₁} {t₂} {t₃} f g = t₂ ⟷ t₃

-- Every f and g of the right type are related by ∼

homotopy : {t₁ t₂ t₃ : U} → (f : t₁ ⟷ t₂) → (g : t₁ ⟷ t₃) → (f ∼ g)
homotopy f g = (! f) ◎ g

-- Equivalences 
-- 
-- If f : t₁ ⟷ t₂ has two inverses g₁ g₂ : t₂ ⟷ t₁ then g₁ ∼ g₂. More
-- generally, any two paths of the same type are related by ∼.

equiv : {t₁ t₂ : U} → (f g : t₁ ⟷ t₂) → (f ∼ g) 
equiv f g = id⟷ 

-- It follows that any two types in U are equivalent if there is a path
-- between them

_≃_ : (t₁ t₂ : U) → Set
t₁ ≃ t₂ = t₁ ⟷ t₂ 

-- Now we want to understand the type of paths between paths

------------------------------------------------------------------------------

--}

