{-# OPTIONS --without-K #-}

module Pi1Cat where

-- Proving that Pi with one level of interesting 2 path structure is a
-- symmetric rig groupoid
--
-- U is a collection of types
--
-- Between any two types, there could be zero, one, or many
-- identifications. If there is more than one idenfication, any two
-- idenfications can themselves have no identifications between them
-- (id and not at BOOL ⟷ BOOL) or they can have exactly one
-- identification between them (id and id∘id). Effectively, two types
-- may be identified by several permutations. These permutations can
-- be expressed in different ways but permutations that have the same
-- extensional behavior are identified and permutations that have
-- different extensional behavior are not identified. Interesting the
-- identifications between permutations are essentially the coherent
-- conditions of monoidal categories. The following quote is
-- enlightening:
--
-- What Mac Lane does can be described in logical terms in the
-- following manner. On the one hand, he has an axiomatization, and,
-- on the other hand, he has a model category where arrows are
-- permutations; then he shows that his axiomatization is complete
-- with respect to this model. It is no wonder that his coherence
-- problem reduces to the completeness problem for the usual
-- axiomatization of symmetric groups. (p.3 of
-- http://www.mi.sanu.ac.rs/~kosta/coh.pdf)
-- 
-- Definition 3.1.7. A type A is a 1-type if for all x, y : A and p, q
-- : x = y and r, s : p = q, we have r = s.

open import Level using () renaming (zero to lzero)
open import Relation.Binary.Core using (IsEquivalence)
open import Data.Product using (_,_)
open import Data.Fin using (Fin; zero; suc)

open import Categories.Category
open import Categories.Groupoid
open import Categories.Monoidal
open import Categories.Monoidal.Helpers
open import Categories.Bifunctor
open import Categories.NaturalIsomorphism
open import Categories.Monoidal.Braided
open import Categories.Monoidal.Symmetric
open import Categories.RigCategory

open import PiLevel0
  using (U; _⟷_; id⟷; _◎_;
        !; !!;
        PLUS; _⊕_; ZERO;
        unite₊; uniti₊;
        swap₊;
        assocr₊; assocl₊;
        TIMES; _⊗_; ONE;
        unite⋆; uniti⋆;
        swap⋆;
        assocr⋆; assocl⋆;
        absorbl; absorbr; factorzl; factorzr;
        dist; factor)

open import PiLevel1
  using (
        _⇔_; assoc◎l; idr◎l; idl◎l; id⇔; 2!; trans⇔; _⊡_;
        linv◎l; rinv◎l;
        id⟷⊕id⟷⇔; hom⊕◎⇔; resp⊕⇔;
        uniter₊⇔; unitir₊⇔; unitel₊⇔;
        _⇔⟨_⟩_; _▤;
        swapr₊⇔; assoc◎r;
        assocr⊕r; assocl⊕l;
        id⟷⊗id⟷⇔; hom⊗◎⇔; resp⊗⇔;
        triangle⊕l; pentagon⊕l;
        uniter⋆⇔; unitir⋆⇔;
        swapr⋆⇔;
        assocr⊗r; assocl⊗l;
        triangle⊗l; pentagon⊗l;
        hexagonr⊕l; hexagonl⊕l; hexagonr⊗l; hexagonl⊗l;
        absorbl⇔l; absorbr⇔l; factorzl⇔l; factorzr⇔l;
        dist⇔; factor⇔; dist′⇔; idl◎r; linv◎r;
        hom◎⊕⇔; factor′⇔;
        swap⋆dist⇔l; swap⋆dist⇔r; assocl₊-dist-dist⇔l)

------------------------------------------------------------------------------
-- The equality of morphisms is derived from the coherence conditions
-- of the appropriate categories

⇔Equiv : {t₁ t₂ : U} → IsEquivalence (_⇔_ {t₁} {t₂})
⇔Equiv = record 
  { refl = id⇔
  ; sym = 2!
  ; trans = trans⇔ 
  }

PiCat : Category lzero lzero lzero
PiCat = record
  { Obj = U
  ; _⇒_ = _⟷_
  ; _≡_ = _⇔_
  ; id = id⟷
  ; _∘_ = λ y⟷z x⟷y → x⟷y ◎ y⟷z 
  ; assoc = assoc◎l 
  ; identityˡ = idr◎l 
  ; identityʳ = idl◎l 
  ; equiv = ⇔Equiv 
  ; ∘-resp-≡ = λ f g → g ⊡ f 
  }

PiGroupoid : Groupoid PiCat
PiGroupoid = record 
  { _⁻¹ = ! 
  ; iso = record { isoˡ = linv◎l ; isoʳ = rinv◎l } 
  }

-- additive bifunctor and monoidal structure
⊕-bifunctor : Bifunctor PiCat PiCat PiCat
⊕-bifunctor = record
  { F₀ = λ {(u , v) → PLUS u v}
  ; F₁ = λ {(x⟷y , z⟷w) → x⟷y ⊕ z⟷w }
  ; identity = id⟷⊕id⟷⇔
  ; homomorphism = hom⊕◎⇔
  ; F-resp-≡ = λ {(x , y) → resp⊕⇔ x y}
  }

module ⊎h = MonoidalHelperFunctors PiCat ⊕-bifunctor ZERO

-- note how powerful linv◎l/rinv◎l are in iso below
0⊕x≡x : NaturalIsomorphism ⊎h.id⊗x ⊎h.x
0⊕x≡x = record 
  { F⇒G = record
    { η = λ X → unite₊
    ; commute = λ f → uniter₊⇔ } 
  ; F⇐G = record
    { η = λ X → uniti₊
    ; commute = λ f → unitir₊⇔ } 
  ; iso = λ X → record { isoˡ = linv◎l; isoʳ = rinv◎l }
  }

x⊕0≡x : NaturalIsomorphism ⊎h.x⊗id ⊎h.x
x⊕0≡x = record
  { F⇒G = record
    { η = λ X → swap₊ ◎ unite₊  -- !!!
    ; commute = λ f →
       (f zero ⊕ id⟷) ◎ swap₊ ◎ unite₊ 
           ⇔⟨ assoc◎l ⟩
       ( (f zero ⊕ id⟷) ◎ swap₊ ) ◎ unite₊ 
           ⇔⟨ swapr₊⇔ ⊡ id⇔ ⟩
      (swap₊ ◎ (id⟷ ⊕ f zero)) ◎ unite₊
          ⇔⟨  assoc◎r ⟩
      swap₊ ◎ (id⟷ ⊕ f zero) ◎ unite₊
          ⇔⟨ id⇔ ⊡ uniter₊⇔ ⟩
      swap₊ ◎ unite₊ ◎ f zero
          ⇔⟨ assoc◎l ⟩
      (swap₊ ◎ unite₊) ◎ f zero ▤ 
    }
  ; F⇐G = record
    { η = λ X → uniti₊ ◎ swap₊
    ; commute = λ f → 
      let x = f zero in
      x ◎ uniti₊ ◎ swap₊ 
          ⇔⟨ assoc◎l ⟩
      (x ◎ uniti₊) ◎ swap₊
          ⇔⟨ unitir₊⇔ ⊡ id⇔ ⟩
      (uniti₊ ◎ (id⟷ ⊕ x)) ◎ swap₊
          ⇔⟨ assoc◎r ⟩
      uniti₊ ◎ (id⟷ ⊕ x) ◎ swap₊
          ⇔⟨ id⇔ ⊡ swapr₊⇔ ⟩
      uniti₊ ◎ swap₊ ◎ (f zero ⊕ id⟷)
          ⇔⟨ assoc◎l ⟩
       (uniti₊ ◎ swap₊) ◎ (x ⊕ id⟷) ▤
    }
  ; iso = λ X → record 
    { isoˡ = 
       (swap₊ ◎ unite₊) ◎ uniti₊ ◎ swap₊
           ⇔⟨ assoc◎l ⟩
      ((swap₊ ◎ unite₊) ◎ uniti₊) ◎ swap₊
          ⇔⟨ assoc◎r ⊡ id⇔ ⟩
      (swap₊ ◎ unite₊ ◎ uniti₊) ◎ swap₊
          ⇔⟨ (id⇔ ⊡ linv◎l) ⊡ id⇔ ⟩
      (swap₊ ◎ id⟷) ◎ swap₊
          ⇔⟨ idr◎l ⊡ id⇔ ⟩
      swap₊ ◎ swap₊
          ⇔⟨ linv◎l ⟩
      id⟷ ▤
    ; isoʳ = 
      (uniti₊ ◎ swap₊) ◎ swap₊ ◎ unite₊
          ⇔⟨ assoc◎l ⟩
      ((uniti₊ ◎ swap₊) ◎ swap₊) ◎ unite₊
          ⇔⟨ assoc◎r ⊡ id⇔ ⟩
      (uniti₊ ◎ swap₊ ◎ swap₊) ◎ unite₊
          ⇔⟨ (id⇔ ⊡ linv◎l) ⊡ id⇔ ⟩
      (uniti₊ ◎ id⟷) ◎ unite₊
          ⇔⟨ idr◎l ⊡ id⇔ ⟩
      uniti₊ ◎ unite₊
          ⇔⟨ linv◎l ⟩
       id⟷ ▤
    }
  }

[x⊕y]⊕z≡x⊕[y⊕z] : NaturalIsomorphism ⊎h.[x⊗y]⊗z ⊎h.x⊗[y⊗z]
[x⊕y]⊕z≡x⊕[y⊕z] = record
  { F⇒G = record
    { η = λ X → assocr₊
    ; commute = λ f → assocr⊕r
    }
  ; F⇐G = record
    { η = λ X → assocl₊
    ; commute = λ f → assocl⊕l
    }
  ; iso = λ X → record { isoˡ = linv◎l ; isoʳ = rinv◎l }
  }

M⊕ : Monoidal PiCat
M⊕ = record
  { ⊗ = ⊕-bifunctor
  ; id = ZERO
  ; identityˡ = 0⊕x≡x
  ; identityʳ = x⊕0≡x
  ; assoc = [x⊕y]⊕z≡x⊕[y⊕z]
  ; triangle = triangle⊕l
  ; pentagon = pentagon⊕l
  }

------------------------------------------------------------------------------

-- multiplicative bifunctor and monoidal structure
⊗-bifunctor : Bifunctor PiCat PiCat PiCat
⊗-bifunctor = record
  { F₀ = λ {(u , v) → TIMES u v}
  ; F₁ = λ {(x⟷y , z⟷w) → x⟷y ⊗ z⟷w }
  ; identity = id⟷⊗id⟷⇔
  ; homomorphism = hom⊗◎⇔
  ; F-resp-≡ = λ {(x , y) → resp⊗⇔ x y}
  }

module ×h = MonoidalHelperFunctors PiCat ⊗-bifunctor ONE

1⊗x≡x : NaturalIsomorphism ×h.id⊗x ×h.x
1⊗x≡x = record 
  { F⇒G = record
    { η = λ X → unite⋆
    ; commute = λ f → uniter⋆⇔ } 
  ; F⇐G = record
    { η = λ X → uniti⋆
    ; commute = λ f → unitir⋆⇔ } 
  ; iso = λ X → record { isoˡ = linv◎l; isoʳ = rinv◎l }
  }

x⊗1≡x : NaturalIsomorphism ×h.x⊗id ×h.x
x⊗1≡x = record
  { F⇒G = record
    { η = λ X → swap⋆ ◎ unite⋆  -- !!!
    ; commute = λ f →
       (f zero ⊗ id⟷) ◎ swap⋆ ◎ unite⋆ 
           ⇔⟨ assoc◎l ⟩
       ( (f zero ⊗ id⟷) ◎ swap⋆ ) ◎ unite⋆ 
           ⇔⟨ swapr⋆⇔ ⊡ id⇔ ⟩
      (swap⋆ ◎ (id⟷ ⊗ f zero)) ◎ unite⋆
          ⇔⟨  assoc◎r ⟩
      swap⋆ ◎ (id⟷ ⊗ f zero) ◎ unite⋆
          ⇔⟨ id⇔ ⊡ uniter⋆⇔ ⟩
      swap⋆ ◎ unite⋆ ◎ f zero
          ⇔⟨ assoc◎l ⟩
      (swap⋆ ◎ unite⋆) ◎ f zero ▤ 
    }
  ; F⇐G = record
    { η = λ X → uniti⋆ ◎ swap⋆
    ; commute = λ f → 
      let x = f zero in
      x ◎ uniti⋆ ◎ swap⋆
          ⇔⟨ assoc◎l ⟩
      (x ◎ uniti⋆) ◎ swap⋆
          ⇔⟨ unitir⋆⇔ ⊡ id⇔ ⟩
      (uniti⋆ ◎ (id⟷ ⊗ x)) ◎ swap⋆
          ⇔⟨ assoc◎r ⟩
      uniti⋆ ◎ (id⟷ ⊗ x) ◎ swap⋆
          ⇔⟨ id⇔ ⊡ swapr⋆⇔ ⟩
      uniti⋆ ◎ swap⋆ ◎ (f zero ⊗ id⟷)
          ⇔⟨ assoc◎l ⟩
       (uniti⋆ ◎ swap⋆) ◎ (x ⊗ id⟷) ▤
    }
  ; iso = λ X → record 
    { isoˡ = 
       (swap⋆ ◎ unite⋆) ◎ uniti⋆ ◎ swap⋆
           ⇔⟨ assoc◎l ⟩
      ((swap⋆ ◎ unite⋆) ◎ uniti⋆) ◎ swap⋆
          ⇔⟨ assoc◎r ⊡ id⇔ ⟩
      (swap⋆ ◎ unite⋆ ◎ uniti⋆) ◎ swap⋆
          ⇔⟨ (id⇔ ⊡ linv◎l) ⊡ id⇔ ⟩
      (swap⋆ ◎ id⟷) ◎ swap⋆
          ⇔⟨ idr◎l ⊡ id⇔ ⟩
      swap⋆ ◎ swap⋆
          ⇔⟨ linv◎l ⟩
      id⟷ ▤
    ; isoʳ = 
      (uniti⋆ ◎ swap⋆) ◎ swap⋆ ◎ unite⋆
          ⇔⟨ assoc◎l ⟩
      ((uniti⋆ ◎ swap⋆) ◎ swap⋆) ◎ unite⋆
          ⇔⟨ assoc◎r ⊡ id⇔ ⟩
      (uniti⋆ ◎ swap⋆ ◎ swap⋆) ◎ unite⋆
          ⇔⟨ (id⇔ ⊡ linv◎l) ⊡ id⇔ ⟩
      (uniti⋆ ◎ id⟷) ◎ unite⋆
          ⇔⟨ idr◎l ⊡ id⇔ ⟩
      uniti⋆ ◎ unite⋆
          ⇔⟨ linv◎l ⟩
       id⟷ ▤
    }
  }

[x⊗y]⊗z≡x⊗[y⊗z] : NaturalIsomorphism ×h.[x⊗y]⊗z ×h.x⊗[y⊗z]
[x⊗y]⊗z≡x⊗[y⊗z] = record
  { F⇒G = record
    { η = λ X → assocr⋆
    ; commute = λ f → assocr⊗r
    }
  ; F⇐G = record
    { η = λ X → assocl⋆
    ; commute = λ f → assocl⊗l
    }
  ; iso = λ X → record { isoˡ = linv◎l ; isoʳ = rinv◎l }
  }

M⊗ : Monoidal PiCat
M⊗ = record
  { ⊗ = ⊗-bifunctor
  ; id = ONE
  ; identityˡ = 1⊗x≡x
  ; identityʳ = x⊗1≡x
  ; assoc = [x⊗y]⊗z≡x⊗[y⊗z]
  ; triangle = triangle⊗l
  ; pentagon = pentagon⊗l
  }

x⊕y≡y⊕x : NaturalIsomorphism ⊎h.x⊗y ⊎h.y⊗x
x⊕y≡y⊕x = record 
  { F⇒G = record { η = λ X → swap₊ ; commute = λ f → swapr₊⇔ } 
  ; F⇐G = record { η = λ X → swap₊ ; commute = λ f → swapr₊⇔ } 
  ; iso = λ X → record { isoˡ = linv◎l ; isoʳ = rinv◎l } }

BM⊕ : Braided M⊕
BM⊕ = record
  { braid = x⊕y≡y⊕x
  ; hexagon₁ = hexagonr⊕l
  ; hexagon₂ = hexagonl⊕l
  }

x⊗y≡y⊗x : NaturalIsomorphism ×h.x⊗y ×h.y⊗x
x⊗y≡y⊗x = record 
  { F⇒G = record { η = λ X → swap⋆ ; commute = λ f → swapr⋆⇔ } 
  ; F⇐G = record { η = λ X → swap⋆ ; commute = λ f → swapr⋆⇔ } 
  ; iso = λ X → record { isoˡ = linv◎l ; isoʳ = rinv◎l } }

BM⊗ : Braided M⊗
BM⊗ = record
  { braid = x⊗y≡y⊗x
  ; hexagon₁ = hexagonr⊗l
  ; hexagon₂ = hexagonl⊗l
  }

SBM⊕ : Symmetric BM⊕
SBM⊕ = record { symmetry = linv◎l }

SBM⊗ : Symmetric BM⊗
SBM⊗ = record { symmetry = rinv◎l }

module r = BimonoidalHelperFunctors BM⊕ BM⊗

x⊗0≡0 : NaturalIsomorphism r.x⊗0 r.0↑
x⊗0≡0 = record 
  { F⇒G = record
    { η = λ X → absorbl
    ; commute = λ f → absorbl⇔l
    } 
  ; F⇐G = record
    { η = λ X → factorzr
    ; commute = λ f → factorzr⇔l
    } 
  ; iso = λ X → record { isoˡ = linv◎l ; isoʳ = rinv◎l } 
  }

0⊗x≡0 : NaturalIsomorphism r.0⊗x r.0↑
0⊗x≡0 = record
  { F⇒G = record { η = λ X → absorbr ; commute = λ f → absorbr⇔l }
  ; F⇐G = record { η = λ X → factorzl ; commute = λ f → factorzl⇔l }
  ; iso = λ X → record { isoˡ = linv◎l ; isoʳ = rinv◎l }
  }

x⊗[y⊕z]≡[x⊗y]⊕[x⊗z] : NaturalIsomorphism r.x⊗[y⊕z] r.[x⊗y]⊕[x⊗z]
x⊗[y⊕z]≡[x⊗y]⊕[x⊗z] = record
  { F⇒G = record
    { η = λ X → swap⋆ ◎ dist ◎ (swap⋆ ⊕ swap⋆)
    ; commute = λ f → 
    let a = f zero in let b = f (suc zero) in let c = f (suc (suc zero)) in
    (a ⊗ (b ⊕ c)) ◎ swap⋆ ◎ (dist ◎ (swap⋆ ⊕ swap⋆))
      ⇔⟨ assoc◎l ⟩
    ((a ⊗ (b ⊕ c)) ◎ swap⋆) ◎ (dist ◎ (swap⋆ ⊕ swap⋆))
      ⇔⟨ swapr⋆⇔ ⊡ id⇔ ⟩
    (swap⋆ ◎ ((b ⊕ c) ⊗ a)) ◎ (dist ◎ (swap⋆ ⊕ swap⋆))
      ⇔⟨ assoc◎r ⟩
    swap⋆ ◎ ((b ⊕ c) ⊗ a) ◎ (dist ◎ (swap⋆ ⊕ swap⋆))
      ⇔⟨ id⇔ ⊡ assoc◎l ⟩
    swap⋆ ◎ (((b ⊕ c) ⊗ a) ◎ dist) ◎ (swap⋆ ⊕ swap⋆)
      ⇔⟨ id⇔ ⊡ (dist′⇔ ⊡ id⇔) ⟩
    swap⋆ ◎ ((dist ◎ ((b ⊗ a) ⊕ (c ⊗ a))) ◎ (swap⋆ ⊕ swap⋆))
      ⇔⟨ id⇔ ⊡ assoc◎r ⟩
    swap⋆ ◎ (dist ◎ (((b ⊗ a) ⊕ (c ⊗ a)) ◎ (swap⋆ ⊕ swap⋆)))
      ⇔⟨ id⇔ ⊡ (id⇔ ⊡ hom◎⊕⇔) ⟩
    swap⋆ ◎ (dist ◎ (((b ⊗ a) ◎ swap⋆) ⊕ ((c ⊗ a) ◎ swap⋆)))
      ⇔⟨ id⇔ ⊡ (id⇔ ⊡ (resp⊕⇔ swapr⋆⇔ swapr⋆⇔)) ⟩
    swap⋆ ◎ (dist ◎ ((swap⋆ ◎ (a ⊗ b)) ⊕ (swap⋆ ◎ (a ⊗ c))))
      ⇔⟨ id⇔ ⊡ (id⇔ ⊡ hom⊕◎⇔) ⟩
    swap⋆ ◎ (dist ◎ ((swap⋆ ⊕ swap⋆) ◎ ((a ⊗ b) ⊕ (a ⊗ c))))
      ⇔⟨ id⇔ ⊡ assoc◎l ⟩
    swap⋆ ◎ ((dist ◎ (swap⋆ ⊕ swap⋆)) ◎ _)
      ⇔⟨ assoc◎l ⟩
    (swap⋆ ◎ dist ◎ (swap⋆ ⊕ swap⋆)) ◎ ((a ⊗ b) ⊕ (a ⊗ c)) ▤
    }
  ; F⇐G = record
    { η = λ X → (swap⋆ ⊕ swap⋆) ◎ factor ◎ swap⋆
    ; commute = λ f → 
      let a = f zero in let b = f (suc zero) in let c = f (suc (suc zero)) in
      let x = (a ⊗ b) ⊕ (a ⊗ c) in let y = a ⊗ (b ⊕ c) in
      x ◎ (swap⋆ ⊕ swap⋆) ◎ factor ◎ swap⋆
        ⇔⟨ assoc◎l ⟩
      (x ◎ (swap⋆ ⊕ swap⋆)) ◎ factor ◎ swap⋆
        ⇔⟨ hom◎⊕⇔ ⊡ id⇔ ⟩
      (((a ⊗ b) ◎ swap⋆) ⊕ ((a ⊗ c) ◎ swap⋆)) ◎ factor ◎ swap⋆
        ⇔⟨ (resp⊕⇔ swapr⋆⇔ swapr⋆⇔) ⊡ id⇔ ⟩
      ((swap⋆ ◎ (b ⊗ a)) ⊕ (swap⋆ ◎ (c ⊗ a))) ◎ factor ◎ swap⋆
        ⇔⟨ hom⊕◎⇔ ⊡ id⇔ ⟩
      ((swap⋆ ⊕ swap⋆) ◎ ((b ⊗ a) ⊕ (c ⊗ a))) ◎ factor ◎ swap⋆
        ⇔⟨ assoc◎l ⟩
      (((swap⋆ ⊕ swap⋆) ◎ ((b ⊗ a) ⊕ (c ⊗ a))) ◎ factor) ◎ swap⋆
        ⇔⟨ assoc◎r ⊡ id⇔ ⟩
      ((swap⋆ ⊕ swap⋆) ◎ ((b ⊗ a) ⊕ (c ⊗ a)) ◎ factor) ◎ swap⋆
        ⇔⟨ (id⇔ ⊡ factor′⇔) ⊡ id⇔ ⟩
      ((swap⋆ ⊕ swap⋆) ◎ (factor ◎ ((b ⊕ c) ⊗ a))) ◎ swap⋆
        ⇔⟨ assoc◎r ⟩
      (swap⋆ ⊕ swap⋆) ◎ (factor ◎ ((b ⊕ c) ⊗ a)) ◎ swap⋆
        ⇔⟨ id⇔ ⊡ assoc◎r ⟩
       (swap⋆ ⊕ swap⋆) ◎ (factor ◎ ((b ⊕ c) ⊗ a) ◎ swap⋆)
        ⇔⟨ id⇔ ⊡ (id⇔ ⊡ swapr⋆⇔) ⟩
      (swap⋆ ⊕ swap⋆) ◎ (factor ◎ (swap⋆ ◎ (a ⊗ (b ⊕ c))))
        ⇔⟨ trans⇔ (id⇔ ⊡ assoc◎l) assoc◎l ⟩
      ((swap⋆ ⊕ swap⋆) ◎ factor ◎ swap⋆) ◎ y ▤
    }
  ; iso = λ X → record
    { isoˡ = 
      (swap⋆ ◎ (dist ◎ (swap⋆ ⊕ swap⋆))) ◎ ((swap⋆ ⊕ swap⋆) ◎ (factor ◎ swap⋆))
        ⇔⟨ assoc◎l ⊡ id⇔ ⟩
      ((swap⋆ ◎ dist) ◎ (swap⋆ ⊕ swap⋆)) ◎ ((swap⋆ ⊕ swap⋆) ◎ (factor ◎ swap⋆))
        ⇔⟨ assoc◎r ⟩
      (swap⋆ ◎ dist) ◎ (swap⋆ ⊕ swap⋆) ◎ (swap⋆ ⊕ swap⋆) ◎ factor ◎ swap⋆
        ⇔⟨ id⇔ ⊡ assoc◎l ⟩
      (swap⋆ ◎ dist) ◎ ((swap⋆ ⊕ swap⋆) ◎ (swap⋆ ⊕ swap⋆)) ◎ factor ◎ swap⋆
        ⇔⟨ id⇔ ⊡ (hom◎⊕⇔ ⊡ id⇔) ⟩
      (swap⋆ ◎ dist) ◎ (swap⋆ ◎ swap⋆ ⊕ swap⋆ ◎ swap⋆) ◎ factor ◎ swap⋆
        ⇔⟨ id⇔ ⊡ ((resp⊕⇔ linv◎l rinv◎l) ⊡ id⇔) ⟩
      (swap⋆ ◎ dist) ◎ ((id⟷ ⊕ id⟷) ◎ factor ◎ swap⋆)
        ⇔⟨ id⇔ ⊡ (id⟷⊕id⟷⇔ ⊡ id⇔) ⟩
      (swap⋆ ◎ dist) ◎ id⟷ ◎ factor ◎ swap⋆
        ⇔⟨ id⇔ ⊡ idl◎l ⟩
      (swap⋆ ◎ dist) ◎ factor ◎ swap⋆
        ⇔⟨ assoc◎l ⟩
      ((swap⋆ ◎ dist) ◎ factor) ◎ swap⋆
        ⇔⟨ assoc◎r ⊡ id⇔ ⟩
      (swap⋆ ◎ (dist ◎ factor)) ◎ swap⋆
        ⇔⟨ (id⇔ ⊡ linv◎l) ⊡ id⇔ ⟩
      (swap⋆ ◎ id⟷) ◎ swap⋆
        ⇔⟨ idr◎l ⊡ id⇔ ⟩
      swap⋆ ◎ swap⋆
        ⇔⟨ linv◎l ⟩
      id⟷ ▤
    ; isoʳ = 
      ((swap⋆ ⊕ swap⋆) ◎ (factor ◎ swap⋆)) ◎ (swap⋆ ◎ dist ◎ (swap⋆ ⊕ swap⋆))
        ⇔⟨ assoc◎l ⊡ id⇔ ⟩
      (((swap⋆ ⊕ swap⋆) ◎ factor) ◎ swap⋆) ◎ (swap⋆ ◎ dist ◎ (swap⋆ ⊕ swap⋆))
        ⇔⟨ assoc◎r ⟩
      ((swap⋆ ⊕ swap⋆) ◎ factor) ◎ swap⋆ ◎ swap⋆ ◎ dist ◎ (swap⋆ ⊕ swap⋆)
        ⇔⟨ id⇔ ⊡ assoc◎l ⟩
      ((swap⋆ ⊕ swap⋆) ◎ factor) ◎ (swap⋆ ◎ swap⋆) ◎ dist ◎ (swap⋆ ⊕ swap⋆)
        ⇔⟨ id⇔ ⊡ (linv◎l ⊡ id⇔) ⟩
      ((swap⋆ ⊕ swap⋆) ◎ factor) ◎ id⟷ ◎ dist ◎ (swap⋆ ⊕ swap⋆)
        ⇔⟨ id⇔ ⊡ idl◎l ⟩
      ((swap⋆ ⊕ swap⋆) ◎ factor) ◎ (dist ◎ (swap⋆ ⊕ swap⋆))
        ⇔⟨ trans⇔ assoc◎r (id⇔ ⊡ assoc◎l) ⟩
      (swap⋆ ⊕ swap⋆) ◎ (factor ◎ dist) ◎ (swap⋆ ⊕ swap⋆)
        ⇔⟨ id⇔ ⊡ (linv◎l ⊡ id⇔) ⟩
      (swap⋆ ⊕ swap⋆) ◎ id⟷ ◎ (swap⋆ ⊕ swap⋆)
        ⇔⟨ id⇔ ⊡ idl◎l ⟩
      (swap⋆ ⊕ swap⋆) ◎ (swap⋆ ⊕ swap⋆)
        ⇔⟨ hom◎⊕⇔ ⟩
      (swap⋆ ◎ swap⋆) ⊕ (swap⋆ ◎ swap⋆)
        ⇔⟨ resp⊕⇔ linv◎l linv◎l ⟩
      id⟷ ⊕ id⟷
        ⇔⟨ id⟷⊕id⟷⇔ ⟩
      id⟷ ▤
    }
  }

[x⊕y]⊗z≡[x⊗z]⊕[y⊗z] : NaturalIsomorphism r.[x⊕y]⊗z r.[x⊗z]⊕[y⊗z]
[x⊕y]⊗z≡[x⊗z]⊕[y⊗z] = record
  { F⇒G = record
    { η = λ X → dist
    ; commute = λ f → dist′⇔
    }
  ; F⇐G = record
    { η = λ X → factor
    ; commute = λ f → 
      let a = f zero in let b = f (suc zero) in let c = f (suc (suc zero)) in
      ((a ⊗ c) ⊕ (b ⊗ c)) ◎ factor
        ⇔⟨ idl◎r ⟩
      id⟷ ◎ (((a ⊗ c) ⊕ (b ⊗ c)) ◎ factor)
        ⇔⟨ linv◎r ⊡ id⇔ ⟩
      (factor ◎ dist) ◎ (((a ⊗ c) ⊕ (b ⊗ c)) ◎ factor)
        ⇔⟨ assoc◎r ⟩
      factor ◎ (dist ◎ (((a ⊗ c) ⊕ (b ⊗ c)) ◎ factor))
        ⇔⟨ id⇔ ⊡ factor⇔ ⟩
      factor ◎ ((a ⊕ b) ⊗ c) ▤
    }
  ; iso = λ X → record { isoˡ = linv◎l ; isoʳ = rinv◎l }
  }

Pi0Rig : RigCategory SBM⊕ SBM⊗
Pi0Rig = record 
  { distribₗ = x⊗[y⊕z]≡[x⊗y]⊕[x⊗z]
  ; distribᵣ = [x⊕y]⊗z≡[x⊗z]⊕[y⊗z] 
  ; annₗ = x⊗0≡0 
  ; annᵣ = 0⊗x≡0
  ; laplazaI = swap⋆dist⇔l
    -- this next one is provable because of the definition of
    -- the inverse distribution law
  ; laplazaII = trans⇔
    (idl◎r {c = dist ◎ (swap⋆ ⊕ swap⋆)})
    (trans⇔ (linv◎r ⊡ id⇔) assoc◎r)
  ; laplazaIV = assocl₊-dist-dist⇔l
  }
