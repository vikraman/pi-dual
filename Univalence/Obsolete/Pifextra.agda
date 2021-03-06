
{--
-- normalize a finite type to (1 + (1 + (1 + ... + (1 + 0) ... )))
-- a bunch of ones ending with zero with left biased + in between

toℕ : U → ℕ
toℕ ZERO          = 0
toℕ ONE           = 1
toℕ (PLUS t₁ t₂)  = toℕ t₁ + toℕ t₂
toℕ (TIMES t₁ t₂) = toℕ t₁ * toℕ t₂

fromℕ : ℕ → U
fromℕ 0       = ZERO
fromℕ (suc n) = PLUS ONE (fromℕ n)

normalℕ : U → U
normalℕ = fromℕ ∘ toℕ

-- invert toℕ: give t and n such that toℕ t = n, return constraints on components of t

reflectPlusZero : {m n : ℕ} → (m + n ≡ 0) → m ≡ 0 × n ≡ 0
reflectPlusZero {0} {0} refl = (refl , refl)
reflectPlusZero {0} {suc n} ()
reflectPlusZero {suc m} {0} ()
reflectPlusZero {suc m} {suc n} ()

-- nbe

nbe : {t₁ t₂ : U} → (p : toℕ t₁ ≡ toℕ t₂) → (⟦ t₁ ⟧ → ⟦ t₂ ⟧) → (t₁ ⟷ t₂)
nbe {ZERO} {ZERO} refl f = id⟷
nbe {ZERO} {ONE} ()
nbe {ZERO} {PLUS t₁ t₂} p f = {!!} 
nbe {ZERO} {TIMES t₂ t₃} p f = {!!}
nbe {ONE} {ZERO} ()
nbe {ONE} {ONE} p f = id⟷
nbe {ONE} {PLUS t₂ t₃} p f = {!!}
nbe {ONE} {TIMES t₂ t₃} p f = {!!}
nbe {PLUS t₁ t₂} {ZERO} p f = {!!}
nbe {PLUS t₁ t₂} {ONE} p f = {!!}
nbe {PLUS t₁ t₂} {PLUS t₃ t₄} p f = {!!}
nbe {PLUS t₁ t₂} {TIMES t₃ t₄} p f = {!!}
nbe {TIMES t₁ t₂} {ZERO} p f = {!!}
nbe {TIMES t₁ t₂} {ONE} p f = {!!}
nbe {TIMES t₁ t₂} {PLUS t₃ t₄} p f = {!!}
nbe {TIMES t₁ t₂} {TIMES t₃ t₄} p f = {!!} 

-- build a combinator that does the normalization

assocrU : {m : ℕ} (n : ℕ) → (PLUS (fromℕ n) (fromℕ m)) ⟷ fromℕ (n + m)
assocrU 0       = unite₊
assocrU (suc n) = assocr₊ ◎ (id⟷ ⊕ assocrU n)

distrU : (m : ℕ) {n : ℕ} → TIMES (fromℕ m) (fromℕ n) ⟷ fromℕ (m * n)
distrU 0           = distz
distrU (suc n) {m} = dist ◎ (unite⋆ ⊕ distrU n) ◎ assocrU m

normalU : (t : U) → t ⟷ normalℕ t
normalU ZERO          = id⟷
normalU ONE           = uniti₊ ◎ swap₊
normalU (PLUS t₁ t₂)  = (normalU t₁ ⊕ normalU t₂) ◎ assocrU (toℕ t₁)
normalU (TIMES t₁ t₂) = (normalU t₁ ⊗ normalU t₂) ◎ distrU (toℕ t₁)

-- a few lemmas

fromℕplus : {m n : ℕ} → fromℕ (m + n) ⟷ PLUS (fromℕ m) (fromℕ n)
fromℕplus {0} {n} = 
  fromℕ n
    ⟷⟨ uniti₊ ⟩
  PLUS ZERO (fromℕ n) □
fromℕplus {suc m} {n} = 
  fromℕ (suc (m + n))
    ⟷⟨ id⟷ ⟩ 
  PLUS ONE (fromℕ (m + n))
    ⟷⟨ id⟷ ⊕ fromℕplus {m} {n} ⟩ 
  PLUS ONE (PLUS (fromℕ m) (fromℕ n))
    ⟷⟨ assocl₊ ⟩ 
  PLUS (PLUS ONE (fromℕ m)) (fromℕ n)
    ⟷⟨ id⟷ ⟩ 
  PLUS (fromℕ (suc m)) (fromℕ n) □

normalℕswap : {t₁ t₂ : U} → normalℕ (PLUS t₁ t₂) ⟷ normalℕ (PLUS t₂ t₁)
normalℕswap {t₁} {t₂} = 
  fromℕ (toℕ t₁ + toℕ t₂) 
    ⟷⟨ fromℕplus {toℕ t₁} {toℕ t₂} ⟩
  PLUS (normalℕ t₁) (normalℕ t₂)
    ⟷⟨ swap₊ ⟩
  PLUS (normalℕ t₂) (normalℕ t₁)
    ⟷⟨ ! (fromℕplus {toℕ t₂} {toℕ t₁}) ⟩
  fromℕ (toℕ t₂ + toℕ t₁) □

assocrUS : {m : ℕ} {t : U} → PLUS t (fromℕ m) ⟷ fromℕ (toℕ t + m)
assocrUS {m} {ZERO} = unite₊
assocrUS {m} {ONE}  = id⟷
assocrUS {m} {t}    = 
  PLUS t (fromℕ m)
    ⟷⟨ normalU t ⊕ id⟷ ⟩
  PLUS (normalℕ t) (fromℕ m)
    ⟷⟨ ! fromℕplus ⟩
  fromℕ (toℕ t + m) □

-- convert each combinator to a normal form

normal⟷ : {t₁ t₂ : U} → (c₁ : t₁ ⟷ t₂) → 
           Σ[ c₂ ∈ normalℕ t₁ ⟷ normalℕ t₂ ] (c₁ ⇔ (normalU t₁ ◎ c₂ ◎ (! (normalU t₂))))
normal⟷ {PLUS ZERO t} {.t} unite₊ = 
  (id⟷ , 
   (unite₊
      ⇔⟨ idr◎r ⟩
    unite₊ ◎ id⟷
      ⇔⟨ resp◎⇔ id⇔ linv◎r ⟩
    unite₊ ◎ (normalU t ◎ (! (normalU t)))
      ⇔⟨ assoc◎l ⟩
    (unite₊ ◎ normalU t) ◎ (! (normalU t))
      ⇔⟨ resp◎⇔ unitel₊⇔ id⇔ ⟩
    ((id⟷ ⊕ normalU t) ◎ unite₊) ◎ (! (normalU t))
      ⇔⟨ resp◎⇔ id⇔ idl◎r ⟩
    ((id⟷ ⊕ normalU t) ◎ unite₊) ◎ (id⟷ ◎ (! (normalU t)))
      ⇔⟨ id⇔ ⟩
    normalU (PLUS ZERO t) ◎ (id⟷ ◎ (! (normalU t))) ▤))
normal⟷ {t} {PLUS ZERO .t} uniti₊ = 
  (id⟷ , 
   (uniti₊ 
      ⇔⟨ idl◎r ⟩ 
    id⟷ ◎ uniti₊
      ⇔⟨ resp◎⇔ linv◎r id⇔ ⟩ 
    (normalU t ◎ (! (normalU t))) ◎ uniti₊
      ⇔⟨ assoc◎r ⟩ 
    normalU t ◎ ((! (normalU t)) ◎ uniti₊)
      ⇔⟨ resp◎⇔ id⇔ unitir₊⇔ ⟩ 
    normalU t ◎ (uniti₊ ◎ (id⟷ ⊕ (! (normalU t))))
      ⇔⟨ resp◎⇔ id⇔ idl◎r ⟩ 
    normalU t ◎ (id⟷ ◎ (uniti₊ ◎ (id⟷ ⊕ (! (normalU t)))))
      ⇔⟨ id⇔ ⟩ 
    normalU t ◎ (id⟷ ◎ (! ((id⟷ ⊕ (normalU t)) ◎ unite₊)))
      ⇔⟨ id⇔ ⟩ 
    normalU t ◎ (id⟷ ◎ (! (normalU (PLUS ZERO t)))) ▤))
normal⟷ {PLUS ZERO t₂} {PLUS .t₂ ZERO} swap₊ = 
  (normalℕswap {ZERO} {t₂} , 
  (swap₊ 
     ⇔⟨ {!!} ⟩
   (unite₊ ◎ normalU t₂) ◎ 
     (normalℕswap {ZERO} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ id⟷)))
     ⇔⟨ resp◎⇔ unitel₊⇔ id⇔ ⟩
   ((id⟷ ⊕ normalU t₂) ◎ unite₊) ◎ 
     (normalℕswap {ZERO} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ id⟷)))
     ⇔⟨ id⇔ ⟩
   normalU (PLUS ZERO t₂) ◎ (normalℕswap {ZERO} {t₂} ◎ (! (normalU (PLUS t₂ ZERO)))) ▤))
normal⟷ {PLUS ONE t₂} {PLUS .t₂ ONE} swap₊ = 
  (normalℕswap {ONE} {t₂} , 
  (swap₊ 
     ⇔⟨ {!!} ⟩
   ((normalU ONE ⊕ normalU t₂) ◎ assocrU (toℕ ONE)) ◎ 
     (normalℕswap {ONE} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ ! (normalU ONE))))
     ⇔⟨ id⇔ ⟩
   normalU (PLUS ONE t₂) ◎ (normalℕswap {ONE} {t₂} ◎ (! (normalU (PLUS t₂ ONE)))) ▤))
normal⟷ {PLUS t₁ t₂} {PLUS .t₂ .t₁} swap₊ = 
  (normalℕswap {t₁} {t₂} , 
  (swap₊ 
     ⇔⟨ {!!} ⟩
   ((normalU t₁ ⊕ normalU t₂) ◎ assocrU (toℕ t₁)) ◎ 
     (normalℕswap {t₁} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ ! (normalU t₁))))
     ⇔⟨ id⇔ ⟩
   normalU (PLUS t₁ t₂) ◎ (normalℕswap {t₁} {t₂} ◎ (! (normalU (PLUS t₂ t₁)))) ▤))
normal⟷ {PLUS t₁ (PLUS t₂ t₃)} {PLUS (PLUS .t₁ .t₂) .t₃} assocl₊ = {!!}
normal⟷ {PLUS (PLUS t₁ t₂) t₃} {PLUS .t₁ (PLUS .t₂ .t₃)} assocr₊ = {!!}
normal⟷ {TIMES ONE t} {.t} unite⋆ = {!!} 
normal⟷ {t} {TIMES ONE .t} uniti⋆ = {!!}
normal⟷ {TIMES t₁ t₂} {TIMES .t₂ .t₁} swap⋆ = {!!}
normal⟷ {TIMES t₁ (TIMES t₂ t₃)} {TIMES (TIMES .t₁ .t₂) .t₃} assocl⋆ = {!!}
normal⟷ {TIMES (TIMES t₁ t₂) t₃} {TIMES .t₁ (TIMES .t₂ .t₃)} assocr⋆ = {!!}
normal⟷ {TIMES ZERO t} {ZERO} distz = {!!}
normal⟷ {ZERO} {TIMES ZERO t} factorz = {!!}
normal⟷ {TIMES (PLUS t₁ t₂) t₃} {PLUS (TIMES .t₁ .t₃) (TIMES .t₂ .t₃)} dist = {!!}
normal⟷ {PLUS (TIMES .t₁ .t₃) (TIMES .t₂ .t₃)} {TIMES (PLUS t₁ t₂) t₃} factor = {!!}
normal⟷ {t} {.t} id⟷ = 
  (id⟷ , 
   (id⟷ 
     ⇔⟨ linv◎r ⟩
   normalU t ◎ (! (normalU t))
     ⇔⟨ resp◎⇔ id⇔ idl◎r ⟩
   normalU t ◎ (id⟷ ◎ (! (normalU t))) ▤))
normal⟷ {t₁} {t₃} (_◎_ {t₂ = t₂} c₁ c₂) = {!!}
normal⟷ {PLUS t₁ t₂} {PLUS t₃ t₄} (c₁ ⊕ c₂) = {!!}
normal⟷ {TIMES t₁ t₂} {TIMES t₃ t₄} (c₁ ⊗ c₂) = {!!}

-- if c₁ c₂ : t₁ ⟷ t₂ and c₁ ∼ c₂ then we want a canonical combinator
-- normalℕ t₁ ⟷ normalℕ t₂. If we have that then we should be able to
-- decide whether c₁ ∼ c₂ by normalizing and looking at the canonical
-- combinator.

-- Use ⇔ to normalize a path

{-# NO_TERMINATION_CHECK #-}
normalize : {t₁ t₂ : U} → (c₁ : t₁ ⟷ t₂) → Σ[ c₂ ∈ t₁ ⟷ t₂ ] (c₁ ⇔ c₂)
normalize unite₊     = (unite₊  , id⇔)
normalize uniti₊     = (uniti₊  , id⇔)
normalize swap₊      = (swap₊   , id⇔)
normalize assocl₊    = (assocl₊ , id⇔)
normalize assocr₊    = (assocr₊ , id⇔)
normalize unite⋆     = (unite⋆  , id⇔)
normalize uniti⋆     = (uniti⋆  , id⇔)
normalize swap⋆      = (swap⋆   , id⇔)
normalize assocl⋆    = (assocl⋆ , id⇔)
normalize assocr⋆    = (assocr⋆ , id⇔)
normalize distz      = (distz   , id⇔)
normalize factorz    = (factorz , id⇔)
normalize dist       = (dist    , id⇔)
normalize factor     = (factor  , id⇔)
normalize id⟷        = (id⟷   , id⇔)
normalize (c₁ ◎ c₂)  with normalize c₁ | normalize c₂
... | (c₁' , α) | (c₂' , β) = {!!} 
normalize (c₁ ⊕ c₂)  with normalize c₁ | normalize c₂
... | (c₁' , α) | (c₂₁ ⊕ c₂₂ , β) = 
  (assocl₊ ◎ ((c₁' ⊕ c₂₁) ⊕ c₂₂) ◎ assocr₊ , trans⇔ (resp⊕⇔ α β) assoc⊕l)
... | (c₁' , α) | (c₂' , β)       = (c₁' ⊕ c₂' , resp⊕⇔ α β)
normalize (c₁ ⊗ c₂)  with normalize c₁ | normalize c₂
... | (c₁₁ ⊕ c₁₂ , α) | (c₂' , β) = 
  (dist ◎ ((c₁₁ ⊗ c₂') ⊕ (c₁₂ ⊗ c₂')) ◎ factor , 
   trans⇔ (resp⊗⇔ α β) dist⇔)
... | (c₁' , α) | (c₂₁ ⊗ c₂₂ , β) = 
  (assocl⋆ ◎ ((c₁' ⊗ c₂₁) ⊗ c₂₂) ◎ assocr⋆ , trans⇔ (resp⊗⇔ α β) assoc⊗l)
... | (c₁' , α) | (c₂' , β) = (c₁' ⊗ c₂' , resp⊗⇔ α β)



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

p◎id∼p : ∀ {t₁ t₂} {c : t₁ ⟷ t₂} → (c ◎ id⟷ ∼ c)
p◎id∼p {t₁} {t₂} {c} v = 
  (begin (proj₁ (perm2path (c ◎ id⟷) v))
           ≡⟨ {!!} ⟩
         (proj₁ (perm2path id⟷ (proj₁ (perm2path c v))))
           ≡⟨ {!!} ⟩
         (proj₁ (perm2path c v)) ∎)

-- perm2path {t} id⟷ v = (v , edge •[ t , v ] •[ t , v ])

--perm2path (_◎_ {t₁} {t₂} {t₃} c₁ c₂) v₁ with perm2path c₁ v₁
--... | (v₂ , p) with perm2path c₂ v₂
--... | (v₃ , q) = (v₃ , seq p q) 


-- Equivalences between paths leading to 2path structure
-- Two paths are the same if they go through the same points

_∼_ : ∀ {t₁ t₂ v₁ v₂} → 
      (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂  ]) → 
      (q : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → 
      Set
(edge ._ ._) ∼ (edge ._ ._) = ⊤ 
(edge ._ ._) ∼ (seq p q) = {!!}
(edge ._ ._) ∼ (left p) = {!!}
(edge ._ ._) ∼ (right p) = {!!}
(edge ._ ._) ∼ (par p q) = {!!}
seq p p₁ ∼ edge ._ ._ = {!!}
seq p₁ p ∼ seq q q₁ = {!!}
seq p p₁ ∼ left q = {!!}
seq p p₁ ∼ right q = {!!}
seq p p₁ ∼ par q q₁ = {!!}
left p ∼ edge ._ ._ = {!!}
left p ∼ seq q q₁ = {!!}
left p ∼ left q = {!!}
right p ∼ edge ._ ._ = {!!}
right p ∼ seq q q₁ = {!!}
right p ∼ right q = {!!}
par p p₁ ∼ edge ._ ._ = {!!}
par p p₁ ∼ seq q q₁ = {!!}
par p p₁ ∼ par q q₁ = {!!} 

-- Equivalences between paths leading to 2path structure
-- Following the HoTT approach two paths are considered the same if they
-- map the same points to equal points

infix  4  _∼_  

_∼_ : ∀ {t₁ t₂ v₁ v₂ v₂'} → 
      (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂  ]) → 
      (q : Path •[ t₁ , v₁ ] •[ t₂ , v₂' ]) → 
      Set
_∼_ {t₁} {t₂} {v₁} {v₂} {v₂'} p q = (v₂ ≡ v₂')


-- Lemma 2.4.2

p∼p : {t₁ t₂ : U} {p : Path t₁ t₂} → p ∼ p
p∼p {p = path c} _ = refl

p∼q→q∼p : {t₁ t₂ : U} {p q : Path t₁ t₂} → (p ∼ q) → (q ∼ p)
p∼q→q∼p {p = path c₁} {q = path c₂} α v = sym (α v) 

p∼q∼r→p∼r : {t₁ t₂ : U} {p q r : Path t₁ t₂} → 
                 (p ∼ q) → (q ∼ r) → (p ∼ r) 
p∼q∼r→p∼r {p = path c₁} {q = path c₂} {r = path c₃} α β v = trans (α v) (β v) 

-- lift inverses and compositions to paths

inv : {t₁ t₂ : U} → Path t₁ t₂ → Path t₂ t₁
inv (path c) = path (! c)

infixr 10 _●_

_●_ : {t₁ t₂ t₃ : U} → Path t₁ t₂ → Path t₂ t₃ → Path t₁ t₃
path c₁ ● path c₂ = path (c₁ ◎ c₂)

-- Lemma 2.1.4

p∼p◎id : {t₁ t₂ : U} {p : Path t₁ t₂} → p ∼ p ● path id⟷
p∼p◎id {t₁} {t₂} {path c} v = 
  (begin (perm2path c v)
           ≡⟨ refl ⟩
         (perm2path c (perm2path id⟷ v))
           ≡⟨ refl ⟩
         (perm2path (c ◎ id⟷) v) ∎)

p∼id◎p : {t₁ t₂ : U} {p : Path t₁ t₂} → p ∼ path id⟷ ● p
p∼id◎p {t₁} {t₂} {path c} v = 
  (begin (perm2path c v)
           ≡⟨ refl ⟩
         (perm2path id⟷ (perm2path c v))
           ≡⟨ refl ⟩
         (perm2path (id⟷ ◎ c) v) ∎)

!p◎p∼id : {t₁ t₂ : U} {p : Path t₁ t₂} → (inv p) ● p ∼ path id⟷
!p◎p∼id {t₁} {t₂} {path c} v = 
  (begin (perm2path ((! c) ◎ c) v)
           ≡⟨ refl ⟩
         (perm2path c (perm2path (! c) v))
           ≡⟨ invr {t₁} {t₂} {c} {v} ⟩
         (perm2path id⟷ v) ∎)

p◎!p∼id : {t₁ t₂ : U} {p : Path t₁ t₂} → p ● (inv p) ∼ path id⟷
p◎!p∼id {t₁} {t₂} {path c} v = 
  (begin (perm2path (c ◎ (! c)) v)
           ≡⟨ refl ⟩
         (perm2path (! c) (perm2path c v))
           ≡⟨ invl {t₁} {t₂} {c} {v} ⟩
         (perm2path id⟷ v) ∎)


!!p∼p : {t₁ t₂ : U} {p : Path t₁ t₂} → inv (inv p) ∼ p
!!p∼p {t₁} {t₂} {path c} v = 
  begin (perm2path (! (! c)) v
           ≡⟨ cong (λ x → perm2path x v) (!! {c = c}) ⟩ 
         perm2path c v ∎)

assoc◎ : {t₁ t₂ t₃ t₄ : U} {p : Path t₁ t₂} {q : Path t₂ t₃} {r : Path t₃ t₄} → 
         p ● (q ● r) ∼ (p ● q) ● r
assoc◎ {t₁} {t₂} {t₃} {t₄} {path c₁} {path c₂} {path c₃} v = 
  begin (perm2path (c₁ ◎ (c₂ ◎ c₃)) v 
           ≡⟨ refl ⟩
         perm2path (c₂ ◎ c₃) (perm2path c₁ v)
           ≡⟨ refl ⟩
         perm2path c₃ (perm2path c₂ (perm2path c₁ v))
           ≡⟨ refl ⟩
         perm2path c₃ (perm2path (c₁ ◎ c₂) v)
           ≡⟨ refl ⟩
         perm2path ((c₁ ◎ c₂) ◎ c₃) v ∎)

resp◎ : {t₁ t₂ t₃ : U} {p q : Path t₁ t₂} {r s : Path t₂ t₃} → 
        p ∼ q → r ∼ s → (p ● r) ∼ (q ● s)
resp◎ {t₁} {t₂} {t₃} {path c₁} {path c₂} {path c₃} {path c₄} α β v = 
  begin (perm2path (c₁ ◎ c₃) v 
           ≡⟨ refl ⟩
         perm2path c₃ (perm2path c₁ v)
           ≡⟨ cong (λ x → perm2path c₃ x) (α  v) ⟩
         perm2path c₃ (perm2path c₂ v)
           ≡⟨ β (perm2path c₂ v) ⟩ 
         perm2path c₄ (perm2path c₂ v)
           ≡⟨ refl ⟩ 
         perm2path (c₂ ◎ c₄) v ∎)

-- Recall that two perminators are the same if they denote the same
-- permutation; in that case there is a 2path between them in the relevant
-- path space

data _⇔_ {t₁ t₂ : U} : Path t₁ t₂ → Path t₁ t₂ → Set where
  2path : {p q : Path t₁ t₂} → (p ∼ q) → (p ⇔ q)

-- Examples

p q r : Path BOOL BOOL
p = path id⟷
q = path swap₊
r = path (swap₊ ◎ id⟷)

α : q ⇔ r
α = 2path (p∼p◎id {p = path swap₊})

-- The equivalence of paths makes U a 1groupoid: the points are types t : U;
-- the 1paths are ⟷; and the 2paths between them are ⇔

G : 1Groupoid
G = record
        { set = U
        ; _↝_ = Path
        ; _≈_ = _⇔_ 
        ; id  = path id⟷
        ; _∘_ = λ q p → p ● q
        ; _⁻¹ = inv
        ; lneutr = λ p → 2path (p∼q→q∼p p∼p◎id) 
        ; rneutr = λ p → 2path (p∼q→q∼p p∼id◎p)
        ; assoc  = λ r q p → 2path assoc◎
        ; equiv = record { 
            refl  = 2path p∼p
          ; sym   = λ { (2path α) → 2path (p∼q→q∼p α) }
          ; trans = λ { (2path α) (2path β) → 2path (p∼q∼r→p∼r α β) }
          }
        ; linv = λ p → 2path p◎!p∼id
        ; rinv = λ p → 2path !p◎p∼id
        ; ∘-resp-≈ = λ { (2path β) (2path α) → 2path (resp◎ α β) }
        }

------------------------------------------------------------------------------

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

-- two perminators are the same if they denote the same permutation


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

infix  4  _≃_  

_≃_ : (t₁ t₂ : U) → Set
t₁ ≃ t₂ = (t₁ ⟷ t₂)

-- Univalence says (t₁ ≃ t₂) ≃ (t₁ ⟷ t₂) but as shown above, we actually have
-- this by definition instead of up to ≃

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

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

module Phase₁ where

  -- no occurrences of (TIMES (TIMES t₁ t₂) t₃)

approach that maintains the invariants in proofs

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
  TIMES ONE (TIMES ONE (TIMES ONE (TIMES ONE ONE))) ,
  (((id⟷ ⊗ id⟷) ⊗ (id⟷ ⊗ id⟷)) ⊗ id⟷ ◎ assocr⋆) ◎
  ((id⟷ ⊗ id⟷) ⊗ ((id⟷ ⊗ id⟷) ⊗ id⟷ ◎ assocr⋆) ◎ assocr⋆) ◎ id⟷

  -- Now any perminator (t₁ ⟷ t₂) can be transformed to a canonical
  -- representation in which we first associate all the TIMES to the right
  -- and then do the rest of the perminator

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


should this be on the code as done now or on their interpreation
i.e. data _⟷_ : ⟦ U ⟧ → ⟦ U ⟧ → Set where

can add recursive types 
rec : U
⟦_⟧ takes an additional argument X that is passed around
⟦ rec ⟧ X = X
fixpoitn
data μ (t : U) : Set where
 ⟨_⟩ : ⟦ t ⟧ (μ t) → μ t

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

elems : (t : U) → List ⟦ t ⟧
elems ZERO = []
elems ONE = [ tt ] 
elems (PLUS t₁ t₂) = map inj₁ (elems t₁) ++ map inj₂ (elems t₂)
elems (TIMES t₁ t₂) = concat 
                        (map 
                          (λ v₂ → map (λ v₁ → (v₁ , v₂)) (elems t₁))
                         (elems t₂))

_≟_ : {t : U} → ⟦ t ⟧ → ⟦ t ⟧ → Bool
_≟_ {ZERO} ()
_≟_ {ONE} tt tt = true
_≟_ {PLUS t₁ t₂} (inj₁ v) (inj₁ w) = v ≟ w
_≟_ {PLUS t₁ t₂} (inj₁ v) (inj₂ w) = false
_≟_ {PLUS t₁ t₂} (inj₂ v) (inj₁ w) = false
_≟_ {PLUS t₁ t₂} (inj₂ v) (inj₂ w) = v ≟ w
_≟_ {TIMES t₁ t₂} (v₁ , w₁) (v₂ , w₂) = v₁ ≟ v₂ ∧ w₁ ≟ w₂

  findLoops : {t t₁ t₂ : U} → (PLUS t t₁ ⟷ PLUS t t₂) → List ⟦ t ⟧ → 
               List (Σ[ t ∈ U ] ⟦ t ⟧)
  findLoops c [] = []
  findLoops {t} c (v ∷ vs) = ? with perm2path c (inj₁ v)
  ... | (inj₂ _ , loops) = loops ++ findLoops c vs
  ... | (inj₁ v' , loops) with v ≟ v' 
  ... | true = (t , v) ∷ loops ++ findLoops c vs
  ... | false = loops ++ findLoops c vs

traceLoopsEx : {t : U} → List (Σ[ t ∈ U ] ⟦ t ⟧)
traceLoopsEx {t} = findLoops traceBodyEx (elems (PLUS t (PLUS t t)))
-- traceLoopsEx {ONE} ==> (PLUS ONE (PLUS ONE ONE) , inj₂ (inj₁ tt)) ∷ []

-- Each permutation is a "path" between types. We can think of this path as
-- being indexed by "time" where "time" here is in discrete units
-- corresponding to the sequencing of combinators. A homotopy between paths p
-- and q is a map that, for each "time unit", maps the specified type along p
-- to a corresponding type along q. At each such time unit, the mapping
-- between types is itself a path. So a homotopy is essentially a collection
-- of paths. As an example, given two paths starting at t₁ and ending at t₂
-- and going through different intermediate points:
--   p = t₁ -> t -> t' -> t₂
--   q = t₁ -> u -> u' -> t₂
-- A possible homotopy between these two paths is a path from t to u and 
-- another path from t' to u'. Things get slightly more complicated if the
-- number of intermediate points is not the same etc. but that's the basic idea.
-- The vertical paths must commute with the horizontal ones.
-- 
-- Postulate the groupoid laws and use them to prove commutativity etc.
-- 
-- Bool -id-- Bool -id-- Bool -id-- Bool
--   |          |          |          |
--   |         not        id          | the last square does not commute
--   |          |          |          |
-- Bool -not- Bool -not- Bool -not- Bool
--
-- If the large rectangle commutes then the smaller squares commute. For a
-- proof, let p o q o r o s be the left-bottom path and p' o q' o r' o s' be
-- the top-right path. Let's focus on the square:
--  
--  A-- r'--C
--   |      |
--   ?      s'
--   |      |
--  B-- s --D
-- 
-- We have a path from A to B that is: !q' o !p' o p o q o r. 
-- Now let's see if r' o s' is equivalent to 
-- !q' o !p' o p o q o r o s
-- We know p o q o r o s ⇔ p' o q' o r' o s' 
-- If we know that ⇔ is preserved by composition then:
-- !q' o !p' o p o q o r o s ⇔ !q' o !p' o p' o q' o r' o s' 
-- and of course by inverses and id being unit of composition:
-- !q' o !p' o p o q o r o s ⇔ r' o s' 
-- and we are done.

{-# NO_TERMINATION_CHECK #-}
Path∼ : ∀ {t₁ t₂ t₁' t₂' v₁ v₂ v₁' v₂'} → 
        (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → 
        (q : Path •[ t₁' , v₁' ] •[ t₂' , v₂' ]) → 
        Set
-- sequential composition
Path∼ {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p₁ p₂) (_●_ {t₂ = t₂'} {v₂ = v₂'} q₁ q₂) = 
 (Path∼ p₁ q₁ × Path∼ p₂ q₂) ⊎
 (Path∼ {t₁} {t₂} {t₁'} {t₁'} {v₁} {v₂} {v₁'} {v₁'} p₁ id⟷• × Path∼ p₂ (q₁ ● q₂)) ⊎ 
 (Path∼ p₁ (q₁ ● q₂) × Path∼ {t₂} {t₃} {t₃'} {t₃'} {v₂} {v₃} {v₃'} {v₃'} p₂ id⟷•) ⊎  
 (Path∼ {t₁} {t₁} {t₁'} {t₂'} {v₁} {v₁} {v₁'} {v₂'} id⟷• q₁ × Path∼ (p₁ ● p₂) q₂) ⊎
 (Path∼ (p₁ ● p₂) q₁ × Path∼ {t₃} {t₃} {t₂'} {t₃'} {v₃} {v₃} {v₂'} {v₃'} id⟷• q₂)
Path∼ {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p q) c = 
    (Path∼ {t₁} {t₂} {t₁'} {t₁'} {v₁} {v₂} {v₁'} {v₁'} p id⟷• × Path∼ q c)
  ⊎ (Path∼ p c × Path∼ {t₂} {t₃} {t₃'} {t₃'} {v₂} {v₃} {v₃'} {v₃'} q id⟷•)
Path∼ {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  c (_●_ {t₂ = t₂'} {v₂ = v₂'} p q) = 
    (Path∼ {t₁} {t₁} {t₁'} {t₂'} {v₁} {v₁} {v₁'} {v₂'} id⟷• p × Path∼ c q)
  ⊎ (Path∼ c p × Path∼ {t₃} {t₃} {t₂'} {t₃'} {v₃} {v₃} {v₂'} {v₃'} id⟷• q)
-- choices
Path∼ (⊕1• p) (⊕1• q) = Path∼ p q
Path∼ (⊕1• p) _       = ⊥
Path∼ _       (⊕1• p) = ⊥
Path∼ (⊕2• p) (⊕2• q) = Path∼ p q
Path∼ (⊕2• p) _       = ⊥
Path∼ _       (⊕2• p) = ⊥
-- parallel paths
Path∼ (p₁ ⊗• p₂) (q₁ ⊗• q₂) = Path∼ p₁ q₁ × Path∼ p₂ q₂
Path∼ (p₁ ⊗• p₂) _          = ⊥
Path∼ _          (q₁ ⊗• q₂) = ⊥
-- simple edges connecting two points
Path∼ {t₁} {t₂} {t₁'} {t₂'} {v₁} {v₂} {v₁'} {v₂'} c₁ c₂ = 
  Path •[ t₁ , v₁ ] •[ t₁' , v₁' ] × Path •[ t₂ , v₂ ] •[ t₂' , v₂' ] 

-- In the setting of finite types (in particular with no loops) every pair of
-- paths with related start and end points is equivalent. In other words, we
-- really have no interesting 2-path structure.

allequiv : ∀ {t₁ t₂ t₁' t₂' v₁ v₂ v₁' v₂'} → 
       (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → 
       (q : Path •[ t₁' , v₁' ] •[ t₂' , v₂' ]) → 
       (start : Path •[ t₁ , v₁ ] •[ t₁' , v₁' ]) → 
       (end : Path •[ t₂ , v₂ ] •[ t₂' , v₂' ]) → 
       Path∼ p q
allequiv {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p₁ p₂) (_●_ {t₂ = t₂'} {v₂ = v₂'} q₁ q₂) 
  start end = {!!}
allequiv {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p q) c start end = {!!}
allequiv {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  c (_●_ {t₂ = t₂'} {v₂ = v₂'} p q) start end = {!!}
allequiv (⊕1• p) (⊕1• q) start end = {!!}
allequiv (⊕1• p) _       start end = {!!}
allequiv _       (⊕1• p) start end = {!!}
allequiv (⊕2• p) (⊕2• q) start end = {!!}
allequiv (⊕2• p) _       start end = {!!}
allequiv _       (⊕2• p) start end = {!!}
-- parallel paths
allequiv (p₁ ⊗• p₂) (q₁ ⊗• q₂) start end = {!!}
allequiv (p₁ ⊗• p₂) _          start end = {!!}
allequiv _          (q₁ ⊗• q₂) start end = {!!}
-- simple edges connecting two points
allequiv {t₁} {t₂} {t₁'} {t₂'} {v₁} {v₂} {v₁'} {v₂'} c₁ c₂ start end = {!!}





refl∼ : ∀ {t₁ t₂ v₁ v₂} → (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → Path∼ p p 
refl∼ unite•₊   = id⟷• , id⟷• 
refl∼ uniti•₊   = id⟷• , id⟷• 
refl∼ swap1•₊   = id⟷• , id⟷• 
refl∼ swap2•₊   = id⟷• , id⟷• 
refl∼ assocl1•₊ = id⟷• , id⟷• 
refl∼ assocl2•₊ = id⟷• , id⟷• 
refl∼ assocl3•₊ = id⟷• , id⟷• 
refl∼ assocr1•₊ = id⟷• , id⟷• 
refl∼ assocr2•₊ = id⟷• , id⟷• 
refl∼ assocr3•₊ = id⟷• , id⟷• 
refl∼ unite•⋆   = id⟷• , id⟷• 
refl∼ uniti•⋆   = id⟷• , id⟷• 
refl∼ swap•⋆    = id⟷• , id⟷• 
refl∼ assocl•⋆  = id⟷• , id⟷• 
refl∼ assocr•⋆  = id⟷• , id⟷• 
refl∼ distz•    = id⟷• , id⟷• 
refl∼ factorz•  = id⟷• , id⟷• 
refl∼ dist1•    = id⟷• , id⟷• 
refl∼ dist2•    = id⟷• , id⟷• 
refl∼ factor1•  = id⟷• , id⟷• 
refl∼ factor2•  = id⟷• , id⟷• 
refl∼ id⟷•      = id⟷• , id⟷• 
refl∼ (p ● q)   = inj₁ (refl∼ p , refl∼ q)
refl∼ (⊕1• p)   = refl∼ p
refl∼ (⊕2• q)   = refl∼ q
refl∼ (p ⊗• q)  = refl∼ p , refl∼ q 

-- Extensional view

-- First we enumerate all the values of a given finite type

size : U → ℕ
size ZERO          = 0
size ONE           = 1
size (PLUS t₁ t₂)  = size  t₁ + size t₂
size (TIMES t₁ t₂) = size t₁ * size  t₂

enum : (t : U) → ⟦ t ⟧ → Fin (size t)
enum ZERO ()                  -- absurd
enum ONE tt                   = zero
enum (PLUS t₁ t₂) (inj₁ v₁)   = inject+ (size t₂) (enum t₁ v₁)
enum (PLUS t₁ t₂) (inj₂ v₂)   = raise (size t₁) (enum t₂ v₂)
enum (TIMES t₁ t₂) (v₁ , v₂)  = fromℕ≤ (pr {s₁} {s₂} {n₁} {n₂})
  where n₁ = enum t₁ v₁
        n₂ = enum t₂ v₂
        s₁ = size t₁ 
        s₂ = size t₂
        pr : {s₁ s₂ : ℕ} → {n₁ : Fin s₁} {n₂ : Fin s₂} → 
             ((toℕ n₁ * s₂) + toℕ n₂) < (s₁ * s₂)
        pr {0} {_} {()} 
        pr {_} {0} {_} {()}
        pr {suc s₁} {suc s₂} {zero} {zero} = {!z≤n!}
        pr {suc s₁} {suc s₂} {zero} {Fsuc n₂} = {!!}
        pr {suc s₁} {suc s₂} {Fsuc n₁} {zero} = {!!}
        pr {suc s₁} {suc s₂} {Fsuc n₁} {Fsuc n₂} = {!!}

vals3 : Fin 3 × Fin 3 × Fin 3
vals3 = (enum THREE LL , enum THREE LR , enum THREE R)
  where THREE = PLUS (PLUS ONE ONE) ONE
        LL = inj₁ (inj₁ tt)
        LR = inj₁ (inj₂ tt)
        R  = inj₂ tt

--}


xxx : {s₁ s₂ : ℕ} → (i : Fin s₁) → (j : Fin s₂) → 
      suc (toℕ i * s₂ + toℕ j) ≤ s₁ * s₂
xxx {0} {_} ()
xxx {suc s₁} {s₂} i j = {!!} 

-- i  : Fin (suc s₁)
-- j  : Fin s₂
-- ?0 : suc (toℕ i * s₂ + toℕ j)  ≤ suc s₁ * s₂
--      (suc (toℕ i) * s₂ + toℕ j ≤ s₂ + s₁ * s₂
--      (suc (toℕ i) * s₂ + toℕ j ≤ s₁ * s₂ + s₂



utoVecℕ : (t : U) → Vec (Fin (utoℕ t)) (utoℕ t)
utoVecℕ ZERO          = []
utoVecℕ ONE           = [ zero ]
utoVecℕ (PLUS t₁ t₂)  = 
  map (inject+ (utoℕ t₂)) (utoVecℕ t₁) ++ 
  map (raise (utoℕ t₁)) (utoVecℕ t₂)
utoVecℕ (TIMES t₁ t₂) = 
  concat (map (λ i → map (λ j → inject≤ (fromℕ (toℕ i * utoℕ t₂ + toℕ j)) 
                                (xxx i j))
                     (utoVecℕ t₂))
         (utoVecℕ t₁))

-- Vector representation of types so that we can test permutations

utoVec : (t : U) → Vec ⟦ t ⟧ (utoℕ t)
utoVec ZERO          = []
utoVec ONE           = [ tt ]
utoVec (PLUS t₁ t₂)  = map inj₁ (utoVec t₁) ++ map inj₂ (utoVec t₂)
utoVec (TIMES t₁ t₂) = 
  concat (map (λ v₁ → map (λ v₂ → (v₁ , v₂)) (utoVec t₂)) (utoVec t₁))

-- Examples permutations and their actions on a simple ordered vector

module PermExamples where

  -- ordered vector: position i has value i
  ordered : ∀ {n} → Vec (Fin n) n
  ordered = tabulate id

  -- empty permutation p₀ { }

  p₀ : Perm 0
  p₀ = []

  v₀ = permute p₀ ordered

  -- permutation p₁ { 0 -> 0 }

  p₁ : Perm 1
  p₁ = 0F ∷ p₀
    where 0F = fromℕ 0

  v₁ = permute p₁ ordered

  -- permutations p₂ { 0 -> 0, 1 -> 1 }
  --              q₂ { 0 -> 1, 1 -> 0 }

  p₂ q₂ : Perm 2
  p₂ = 0F ∷ p₁ 
    where 0F = inject+ 1 (fromℕ 0)
  q₂ = 1F ∷ p₁
    where 1F = fromℕ 1

  v₂ = permute p₂ ordered
  w₂ = permute q₂ ordered

  -- permutations p₃ { 0 -> 0, 1 -> 1, 2 -> 2 }
  --              s₃ { 0 -> 0, 1 -> 2, 2 -> 1 }
  --              q₃ { 0 -> 1, 1 -> 0, 2 -> 2 }
  --              r₃ { 0 -> 1, 1 -> 2, 2 -> 0 }
  --              t₃ { 0 -> 2, 1 -> 0, 2 -> 1 }
  --              u₃ { 0 -> 2, 1 -> 1, 2 -> 0 }

  p₃ q₃ r₃ s₃ t₃ u₃ : Perm 3
  p₃ = 0F ∷ p₂
    where 0F = inject+ 2 (fromℕ 0)
  s₃ = 0F ∷ q₂
    where 0F = inject+ 2 (fromℕ 0)
  q₃ = 1F ∷ p₂
    where 1F = inject+ 1 (fromℕ 1)
  r₃ = 2F ∷ p₂
    where 2F = fromℕ 2
  t₃ = 1F ∷ q₂
    where 1F = inject+ 1 (fromℕ 1)
  u₃ = 2F ∷ q₂
    where 2F = fromℕ 2

  v₃ = permute p₃ ordered
  y₃ = permute s₃ ordered
  w₃ = permute q₃ ordered
  x₃ = permute r₃ ordered
  z₃ = permute t₃ ordered
  α₃ = permute u₃ ordered

  -- end module PermExamples

------------------------------------------------------------------------------
-- Testing

t₁  = PLUS ZERO BOOL
t₂  = BOOL
m₁ = matchP {t₁} {t₂} unite₊
-- (inj₂ (inj₁ tt) , inj₁ tt) ∷ (inj₂ (inj₂ tt) , inj₂ tt) ∷ []
m₂ = matchP {t₂} {t₁} uniti₊
-- (inj₁ tt , inj₂ (inj₁ tt)) ∷ (inj₂ tt , inj₂ (inj₂ tt)) ∷ []

t₃ = PLUS BOOL ONE
t₄ = PLUS ONE BOOL
m₃ = matchP {t₃} {t₄} swap₊
-- (inj₂ tt , inj₁ tt) ∷
-- (inj₁ (inj₁ tt) , inj₂ (inj₁ tt)) ∷
-- (inj₁ (inj₂ tt) , inj₂ (inj₂ tt)) ∷ []
m₄ = matchP {t₄} {t₃} swap₊
-- (inj₂ (inj₁ tt) , inj₁ (inj₁ tt)) ∷
-- (inj₂ (inj₂ tt) , inj₁ (inj₂ tt)) ∷ 
-- (inj₁ tt , inj₂ tt) ∷ []

t₅  = PLUS ONE (PLUS BOOL ONE)
t₆  = PLUS (PLUS ONE BOOL) ONE
m₅ = matchP {t₅} {t₆} assocl₊
-- (inj₁ tt , inj₁ (inj₁ tt)) ∷
-- (inj₂ (inj₁ (inj₁ tt)) , inj₁ (inj₂ (inj₁ tt))) ∷
-- (inj₂ (inj₁ (inj₂ tt)) , inj₁ (inj₂ (inj₂ tt))) ∷
-- (inj₂ (inj₂ tt) , inj₂ tt) ∷ []
m₆ = matchP {t₆} {t₅} assocr₊
-- (inj₁ (inj₁ tt) , inj₁ tt) ∷
-- (inj₁ (inj₂ (inj₁ tt)) , inj₂ (inj₁ (inj₁ tt))) ∷
-- (inj₁ (inj₂ (inj₂ tt)) , inj₂ (inj₁ (inj₂ tt))) ∷
-- (inj₂ tt , inj₂ (inj₂ tt)) ∷ []

t₇ = TIMES ONE BOOL
t₈ = BOOL
m₇ = matchP {t₇} {t₈} unite⋆
-- ((tt , inj₁ tt) , inj₁ tt) ∷ ((tt , inj₂ tt) , inj₂ tt) ∷ []
m₈ = matchP {t₈} {t₇} uniti⋆
-- (inj₁ tt , (tt , inj₁ tt)) ∷ (inj₂ tt , (tt , inj₂ tt)) ∷ []

t₉  = TIMES BOOL ONE
t₁₀ = TIMES ONE BOOL
m₉  = matchP {t₉} {t₁₀} swap⋆
-- ((inj₁ tt , tt) , (tt , inj₁ tt)) ∷
-- ((inj₂ tt , tt) , (tt , inj₂ tt)) ∷ []
m₁₀ = matchP {t₁₀} {t₉} swap⋆
-- ((tt , inj₁ tt) , (inj₁ tt , tt)) ∷
-- ((tt , inj₂ tt) , (inj₂ tt , tt)) ∷ []

t₁₁ = TIMES BOOL (TIMES ONE BOOL)
t₁₂ = TIMES (TIMES BOOL ONE) BOOL
m₁₁ = matchP {t₁₁} {t₁₂} assocl⋆
-- ((inj₁ tt , (tt , inj₁ tt)) , ((inj₁ tt , tt) , inj₁ tt)) ∷
-- ((inj₁ tt , (tt , inj₂ tt)) , ((inj₁ tt , tt) , inj₂ tt)) ∷
-- ((inj₂ tt , (tt , inj₁ tt)) , ((inj₂ tt , tt) , inj₁ tt)) ∷
-- ((inj₂ tt , (tt , inj₂ tt)) , ((inj₂ tt , tt) , inj₂ tt)) ∷ []
m₁₂ = matchP {t₁₂} {t₁₁} assocr⋆
-- (((inj₁ tt , tt) , inj₁ tt) , (inj₁ tt , (tt , inj₁ tt)) ∷
-- (((inj₁ tt , tt) , inj₂ tt) , (inj₁ tt , (tt , inj₂ tt)) ∷
-- (((inj₂ tt , tt) , inj₁ tt) , (inj₂ tt , (tt , inj₁ tt)) ∷
-- (((inj₂ tt , tt) , inj₂ tt) , (inj₂ tt , (tt , inj₂ tt)) ∷ []

t₁₃ = TIMES ZERO BOOL
t₁₄ = ZERO
m₁₃ = matchP {t₁₃} {t₁₄} distz
-- []
m₁₄ = matchP {t₁₄} {t₁₃} factorz
-- []

t₁₅ = TIMES (PLUS BOOL ONE) BOOL
t₁₆ = PLUS (TIMES BOOL BOOL) (TIMES ONE BOOL)
m₁₅ = matchP {t₁₅} {t₁₆} dist
-- ((inj₁ (inj₁ tt) , inj₁ tt) , inj₁ (inj₁ tt , inj₁ tt)) ∷
-- ((inj₁ (inj₁ tt) , inj₂ tt) , inj₁ (inj₁ tt , inj₂ tt)) ∷
-- ((inj₁ (inj₂ tt) , inj₁ tt) , inj₁ (inj₂ tt , inj₁ tt)) ∷
-- ((inj₁ (inj₂ tt) , inj₂ tt) , inj₁ (inj₂ tt , inj₂ tt)) ∷
-- ((inj₂ tt , inj₁ tt) , inj₂ (tt , inj₁ tt)) ∷
-- ((inj₂ tt , inj₂ tt) , inj₂ (tt , inj₂ tt)) ∷ []
m₁₆ = matchP {t₁₆} {t₁₅} factor
-- (inj₁ (inj₁ tt , inj₁ tt) , (inj₁ (inj₁ tt) , inj₁ tt)) ∷
-- (inj₁ (inj₁ tt , inj₂ tt) , (inj₁ (inj₁ tt) , inj₂ tt)) ∷
-- (inj₁ (inj₂ tt , inj₁ tt) , (inj₁ (inj₂ tt) , inj₁ tt)) ∷
-- (inj₁ (inj₂ tt , inj₂ tt) , (inj₁ (inj₂ tt) , inj₂ tt)) ∷
-- (inj₂ (tt , inj₁ tt) , (inj₂ tt , inj₁ tt)) ∷
-- (inj₂ (tt , inj₂ tt) , (inj₂ tt , inj₂ tt)) ∷ []

t₁₇ = BOOL 
t₁₈ = BOOL
m₁₇ = matchP {t₁₇} {t₁₈} id⟷
-- (inj₁ tt , inj₁ tt) ∷ (inj₂ tt , inj₂ tt) ∷ []

--◎
--⊕
--⊗

------------------------------------------------------------------------------

mergeS :: SubPerm → SubPerm (suc m * n) (m * n) → SubPerm (suc m * suc n) (m * suc n) 
mergeS = ? 

subP : ∀ {m n} → Fin (suc m) → Perm n → SubPerm (suc m * n) (m * n)
subP {m} {0} i β = {!!}
subP {m} {suc n} i (j ∷ β) = mergeS ? (subP {m} {n} i β)


-- injectP (Perm n) (m * n) 
-- ...
-- SP (suc m * n) (m * n)
-- SP (n + m * n) (m * n)

--SP (suc m * n) (m * n) 
--
--
--==> 
--
--(suc m * suc n) (m * suc n)

--m : ℕ
--n : ℕ
--i : Fin (suc m)
--j : Fin (suc n)
--β : Perm n
--?1 : SubPerm (suc m * suc n) (m * suc n)


tcompperm : ∀ {m n} → Perm m → Perm n → Perm (m * n)
tcompperm []      β = []
tcompperm (i ∷ α) β = merge (subP i β) (tcompperm α β)

-- shift m=3 n=4 i=ax:F3 β=[ay:F4,by:F3,cy:F2,dy:F1] γ=[r4,...,r11]:P8
-- ==> [F12,F11,F10,F9...γ]

-- m = 3
-- n = 4
-- 3 * 4
-- x = [ ax, bx, cx ] : P 3, y : [ay, by, cy, dy] : P 4
-- (shift ax 4 y) || 
--     ( (shift bx 4 y) ||
--          ( (shift cx 4 y) ||
--               [])))
-- 
-- ax : F3, bx : F2, cx : F1
-- ay : F4, by : F3, cy : F2, dy : F1
--
-- suc m = 3, m = 2
--  F12 F11  F10 F9  F8  F7  F6  F5  F4  F3  F2   F1
-- [ r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11 ]
--   ---------------
--  ax : F3 with y=[F4,F3,F2,F1]
--                   --------------
--                       bx : F2
--                                  ------------------
--                                          cx : F1

  -- β should be something like i * n + entry in β

{--
0 * n = 0
(suc m) * n = n + (m * n)

comb2perm (c₁ ⊗ c₂) = tcompperm (comb2perm c₁) (comb2perm c₂) 

c1 = swap+ (f->t,t->f)  [1,0]
c2 = id    (f->f,t->t)  [0,0]

c1xc2 (f,f)->(t,f), (f,t)->(t,t), (t,f)->(f,f), (t,t)->(f,t)
[

ff ft tf tt
 2   2  0  0

index in α * n + index in β

--}

pex qex pqex qpex : Perm 3
pex = inject+ 1 (fromℕ 1) ∷ fromℕ 1 ∷ zero ∷ []
qex = zero ∷ fromℕ 1 ∷ zero ∷ []
pqex = fromℕ 2 ∷ fromℕ 1 ∷ zero ∷ []
qpex = inject+ 1 (fromℕ 1) ∷ zero ∷ zero ∷ []

pqexv  = (permute qex ∘ permute pex) (tabulate id)
pqexv' = permute pqex (tabulate id) 

qpexv  = (permute pex ∘ permute qex) (tabulate id)
qpexv' = permute qpex (tabulate id)

-- [1,1,0]
-- [z] => [z]
-- [y,z] => [z,y]
-- [x,y,z] => [z,x,y] 

-- [0,1,0]
-- [w] => [w]
-- [v,w] => [w,v]
-- [u,v,w] => [u,w,v]

-- R,R,_ ◌ _,R,_
-- R in p1 takes you to middle which also goes R, so first goes RR
-- [a,b,c] ◌ [d,e,f]
-- [a+p2[a], ...]

-- [1,1,0] ◌ [0,1,0] one step [2,1,0]
-- [z] => [z]
-- [y,z] => [z,y]
-- [x,y,z] => [z,y,x]

-- [1,1,0] ◌ [0,1,0]
-- [z] => [z] => [z]
-- [y,z] => 
-- [x,y,z] => 

-- so [1,1,0] ◌ [0,1,0] ==> [2,1,0]
-- so [0,1,0] ◌ [1,1,0] ==> [1,0,0]

-- pex takes [0,1,2] to [2,0,1]
-- qex takes [0,1,2] to [0,2,1]
-- pex ◌ qex takes [0,1,2] to [2,1,0]
-- qex ◌ pex takes [0,1,2] to [1,0,2]

-- seq : ∀ {m n} → (m ≤ n) → Perm m → Perm n → Perm m
-- seq lp [] _ = []
-- seq lp (i ∷ p) q = (lookupP i q) ∷ (seq lp p q)

-- i F+ ...

-- lookupP : ∀ {n} → Fin n → Perm n → Fin n
-- i   : Fin (suc m)
-- p   : Perm m
-- q   : Perm n


-- 
-- (zero ∷ p₁) ◌ (q ∷ q₁) = q ∷ (p₁ ◌ q₁)
-- (suc p ∷ p₁) ◌ (zero ∷ q₁) = {!!}
-- (suc p ∷ p₁) ◌ (suc q ∷ q₁) = {!!}
-- 
-- data Perm : ℕ → Set where
--   []  : Perm 0
--   _∷_ : {n : ℕ} → Fin (suc n) → Perm n → Perm (suc n)

-- Given a vector of (suc n) elements, return one of the elements and
-- the rest. Example: pick (inject+ 1 (fromℕ 1)) (10 ∷ 20 ∷ 30 ∷ 40 ∷ [])

pick : ∀ {ℓ} {n : ℕ} {A : Set ℓ} → Fin n → Vec A (suc n) → (A × Vec A n)
pick {ℓ} {0} {A} ()
pick {ℓ} {suc n} {A} zero (v ∷ vs) = (v , vs)
pick {ℓ} {suc n} {A} (suc i) (v ∷ vs) = 
  let (w , ws) = pick {ℓ} {n} {A} i vs 
  in (w , v ∷ ws)

insertV : ∀ {ℓ} {n : ℕ} {A : Set ℓ} → 
          A → Fin (suc n) → Vec A n → Vec A (suc n) 
insertV {n = 0} v zero [] = [ v ]
insertV {n = 0} v (suc ()) 
insertV {n = suc n} v zero vs = v ∷ vs
insertV {n = suc n} v (suc i) (w ∷ ws) = w ∷ insertV v i ws

-- A permutation takes two vectors of the same size, matches one
-- element from each and returns another permutation

data P {ℓ ℓ'} (A : Set ℓ) (B : Set ℓ') : 
  (m n : ℕ) → (m ≡ n) → Vec A m → Vec B n → Set (ℓ ⊔ ℓ') where
  nil : P A B 0 0 refl [] []
  cons : {m n : ℕ} {i : Fin (suc m)} {j : Fin (suc n)} → (p : m ≡ n) → 
         (v : A) → (w : B) → (vs : Vec A m) → (ws : Vec B n) →
         P A B m n p vs ws → 
         P A B (suc m) (suc n) (cong suc p) (insertV v i vs) (insertV w j ws)

-- A permutation is a sequence of "insertions".

infixr 5 _∷_

data Perm : ℕ → Set where
  []  : Perm 0
  _∷_ : {n : ℕ} → Fin (suc n) → Perm n → Perm (suc n)

lookupP : ∀ {n} → Fin n → Perm n → Fin n
lookupP () [] 
lookupP zero (j ∷ _) = j
lookupP {suc n} (suc i) (j ∷ q) = inject₁ (lookupP i q)

insert : ∀ {ℓ n} {A : Set ℓ} → Vec A n → Fin (suc n) → A → Vec A (suc n)
insert vs zero w          = w ∷ vs
insert [] (suc ())        -- absurd
insert (v ∷ vs) (suc i) w = v ∷ insert vs i w

-- A permutation acts on a vector by inserting each element in its new
-- position.

permute : ∀ {ℓ n} {A : Set ℓ} → Perm n → Vec A n → Vec A n
permute []       []       = []
permute (p ∷ ps) (v ∷ vs) = insert (permute ps vs) p v

-- Use a permutation to match up the elements in two vectors. See more
-- convenient function matchP below.

match : ∀ {t t'} → (size t ≡ size t') → Perm (size t) → 
        Vec ⟦ t ⟧ (size t) → Vec ⟦ t' ⟧ (size t) → 
        Vec (⟦ t ⟧ × ⟦ t' ⟧) (size t)
match {t} {t'} sp α vs vs' = 
  let js = permute α (tabulate id)
  in zip (tabulate (λ j → lookup (lookup j js) vs)) vs'

-- swap
-- 
-- swapperm produces the permutations that maps:
-- [ a , b || x , y , z ] 
-- to 
-- [ x , y , z || a , b ]
-- Ex. 
-- permute (swapperm {5} (inject+ 2 (fromℕ 2))) ordered=[0,1,2,3,4]
-- produces [2,3,4,0,1]
-- Explicitly:
-- swapex : Perm 5
-- swapex =   inject+ 1 (fromℕ 3) -- :: Fin 5
--          ∷ inject+ 0 (fromℕ 3) -- :: Fin 4
--          ∷ zero
--          ∷ zero
--          ∷ zero
--          ∷ []

swapperm : ∀ {n} → Fin n → Perm n
swapperm {0} ()          -- absurd
swapperm {suc n} zero    = idperm
swapperm {suc n} (suc i) = 
  subst Fin (-+-id n i) 
    (inject+ (toℕ i) (fromℕ (n ∸ toℕ i))) ∷ swapperm {n} i

-- compositions

-- Sequential composition

scompperm : ∀ {n} → Perm n → Perm n → Perm n
scompperm α β = {!!} 

-- Sub-permutations
-- useful for parallel and multiplicative compositions

-- Perm 4 has elements [Fin 4, Fin 3, Fin 2, Fin 1]
-- SubPerm 11 7 has elements [Fin 11, Fin 10, Fin 9, Fin 8]
-- So Perm 4 is a special case SubPerm 4 0

data SubPerm : ℕ → ℕ → Set where
  []s  : {n : ℕ} → SubPerm n n
  _∷s_ : {n m : ℕ} → Fin (suc n) → SubPerm n m → SubPerm (suc n) m

merge : ∀ {m n} → SubPerm m n → Perm n → Perm m
merge []s      β = β
merge (i ∷s α) β = i ∷ merge α β

injectP : ∀ {m} → Perm m → (n : ℕ) → SubPerm (m + n) n
injectP []      n = []s 
injectP (i ∷ α) n = inject+ n i ∷s injectP α n
  
-- Parallel + composition

pcompperm : ∀ {m n} → Perm m → Perm n → Perm (m + n)
pcompperm {m} {n} α β = merge (injectP α n) β

-- Multiplicative * composition

tcompperm : ∀ {m n} → Perm m → Perm n → Perm (m * n)
tcompperm []      β = []
tcompperm (i ∷ α) β = {!!} 

------------------------------------------------------------------------------
-- A combinator t₁ ⟷ t₂ denotes a permutation.

comb2perm : {t₁ t₂ : U} → (c : t₁ ⟷ t₂) → Perm (size t₁)
comb2perm {PLUS ZERO t} {.t} unite₊ = idperm
comb2perm {t} {PLUS ZERO .t} uniti₊ = idperm
comb2perm {PLUS t₁ t₂} {PLUS .t₂ .t₁} swap₊ with size t₂
... | 0     = idperm 
... | suc j = swapperm {size t₁ + suc j} 
               (inject≤ (fromℕ (size t₁)) (suc≤ (size t₁) j))
comb2perm {PLUS t₁ (PLUS t₂ t₃)} {PLUS (PLUS .t₁ .t₂) .t₃} assocl₊ = idperm
comb2perm {PLUS (PLUS t₁ t₂) t₃} {PLUS .t₁ (PLUS .t₂ .t₃)} assocr₊ = idperm
comb2perm {TIMES ONE t} {.t} unite⋆ = idperm
comb2perm {t} {TIMES ONE .t} uniti⋆ = idperm
comb2perm {TIMES t₁ t₂} {TIMES .t₂ .t₁} swap⋆ = idperm 
comb2perm assocl⋆   = idperm  
comb2perm assocr⋆   = idperm  
comb2perm distz     = idperm  
comb2perm factorz   = idperm  
comb2perm dist      = idperm  
comb2perm factor    = idperm  
comb2perm id⟷      = idperm  
comb2perm (c₁ ◎ c₂) = scompperm 
                        (comb2perm c₁) 
                        (subst Perm (sym (size≡ c₁)) (comb2perm c₂))
comb2perm (c₁ ⊕ c₂) = pcompperm (comb2perm c₁) (comb2perm c₂) 
comb2perm (c₁ ⊗ c₂) = tcompperm (comb2perm c₁) (comb2perm c₂) 

-- Convenient way of "seeing" what the permutation does for each combinator

matchP : ∀ {t t'} → (t ⟷ t') → Vec (⟦ t ⟧ × ⟦ t' ⟧) (size t)
matchP {t} {t'} c = 
  match sp (comb2perm c) (utoVec t) 
    (subst (λ n → Vec ⟦ t' ⟧ n) (sym sp) (utoVec t'))
  where sp = size≡ c

------------------------------------------------------------------------------
-- Extensional equivalence of combinators: two combinators are
-- equivalent if they denote the same permutation. Generally we would
-- require that the two permutations map the same value x to values y
-- and z that have a path between them, but because the internals of each
-- type are discrete groupoids, this reduces to saying that y and z
-- are identical, and hence that the permutations are identical.

infix  10  _∼_  

_∼_ : ∀ {t₁ t₂} → (c₁ c₂ : t₁ ⟷ t₂) → Set
c₁ ∼ c₂ = (comb2perm c₁ ≡ comb2perm c₂)

-- The relation ~ is an equivalence relation

refl∼ : ∀ {t₁ t₂} {c : t₁ ⟷ t₂} → (c ∼ c)
refl∼ = refl 

sym∼ : ∀ {t₁ t₂} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₂ ∼ c₁)
sym∼ = sym

trans∼ : ∀ {t₁ t₂} {c₁ c₂ c₃ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₂ ∼ c₃) → (c₁ ∼ c₃)
trans∼ = trans

-- The relation ~ validates the groupoid laws

c◎id∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ◎ id⟷ ∼ c
c◎id∼c = {!!} 

id◎c∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ◎ c ∼ c
id◎c∼c = {!!} 

assoc∼ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
         c₁ ◎ (c₂ ◎ c₃) ∼ (c₁ ◎ c₂) ◎ c₃
assoc∼ = {!!} 

linv∼ : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ◎ ! c ∼ id⟷
linv∼ = {!!} 

rinv∼ : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → ! c ◎ c ∼ id⟷
rinv∼ = {!!} 

resp∼ : {t₁ t₂ t₃ : U} {c₁ c₂ : t₁ ⟷ t₂} {c₃ c₄ : t₂ ⟷ t₃} → 
        (c₁ ∼ c₂) → (c₃ ∼ c₄) → (c₁ ◎ c₃ ∼ c₂ ◎ c₄)
resp∼ = {!!} 

-- The equivalence ∼ of paths makes U a 1groupoid: the points are
-- types (t : U); the 1paths are ⟷; and the 2paths between them are
-- based on extensional equivalence ∼

G : 1Groupoid
G = record
        { set = U
        ; _↝_ = _⟷_
        ; _≈_ = _∼_
        ; id  = id⟷
        ; _∘_ = λ p q → q ◎ p
        ; _⁻¹ = !
        ; lneutr = λ c → c◎id∼c {c = c}
        ; rneutr = λ c → id◎c∼c {c = c}
        ; assoc  = λ c₃ c₂ c₁ → assoc∼ {c₁ = c₁} {c₂ = c₂} {c₃ = c₃}  
        ; equiv = record { 
            refl  = λ {c} → refl∼ {c = c}
          ; sym   = λ {c₁} {c₂} → sym∼ {c₁ = c₁} {c₂ = c₂}
          ; trans = λ {c₁} {c₂} {c₃} → trans∼ {c₁ = c₁} {c₂ = c₂} {c₃ = c₃} 
          }
        ; linv = λ c → linv∼ {c = c} 
        ; rinv = λ c → rinv∼ {c = c} 
        ; ∘-resp-≈ = λ α β → resp∼ β α 
        }

-- And there are additional laws

assoc⊕∼ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          c₁ ⊕ (c₂ ⊕ c₃) ∼ assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊
assoc⊕∼ = {!!} 

assoc⊗∼ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          c₁ ⊗ (c₂ ⊗ c₃) ∼ assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆
assoc⊗∼ = {!!} 

------------------------------------------------------------------------------
-- Picture so far:
--
--           path p
--   =====================
--  ||   ||             ||
--  ||   ||2path        ||
--  ||   ||             ||
--  ||   ||  path q     ||
--  t₁ =================t₂
--  ||   ...            ||
--   =====================
--
-- The types t₁, t₂, etc are discrete groupoids. The paths between
-- them correspond to permutations. Each syntactically different
-- permutation corresponds to a path but equivalent permutations are
-- connected by 2paths.  But now we want an alternative definition of
-- 2paths that is structural, i.e., that looks at the actual
-- construction of the path t₁ ⟷ t₂ in terms of combinators... The
-- theorem we want is that α ∼ β iff we can rewrite α to β using
-- various syntactic structural rules. We start with a collection of
-- simplication rules and then try to show they are complete.

-- Simplification rules

infix  30 _⇔_

data _⇔_ : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₁ ⟷ t₂) → Set where
  assoc◎l : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
          (c₁ ◎ (c₂ ◎ c₃)) ⇔ ((c₁ ◎ c₂) ◎ c₃)
  assoc◎r : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
          ((c₁ ◎ c₂) ◎ c₃) ⇔ (c₁ ◎ (c₂ ◎ c₃))
  assoc⊕l : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (c₁ ⊕ (c₂ ⊕ c₃)) ⇔ (assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊)
  assoc⊕r : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊) ⇔ (c₁ ⊕ (c₂ ⊕ c₃))
  assoc⊗l : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (c₁ ⊗ (c₂ ⊗ c₃)) ⇔ (assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆)
  assoc⊗r : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆) ⇔ (c₁ ⊗ (c₂ ⊗ c₃))
  dist⇔ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          ((c₁ ⊕ c₂) ⊗ c₃) ⇔ (dist ◎ ((c₁ ⊗ c₃) ⊕ (c₂ ⊗ c₃)) ◎ factor)
  factor⇔ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (dist ◎ ((c₁ ⊗ c₃) ⊕ (c₂ ⊗ c₃)) ◎ factor) ⇔ ((c₁ ⊕ c₂) ⊗ c₃)
  idl◎l   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (id⟷ ◎ c) ⇔ c
  idl◎r   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ id⟷ ◎ c
  idr◎l   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (c ◎ id⟷) ⇔ c
  idr◎r   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ (c ◎ id⟷) 
  linv◎l  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (c ◎ ! c) ⇔ id⟷
  linv◎r  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ⇔ (c ◎ ! c) 
  rinv◎l  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (! c ◎ c) ⇔ id⟷
  rinv◎r  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ⇔ (! c ◎ c) 
  unitel₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (unite₊ ◎ c₂) ⇔ ((c₁ ⊕ c₂) ◎ unite₊)
  uniter₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          ((c₁ ⊕ c₂) ◎ unite₊) ⇔ (unite₊ ◎ c₂)
  unitil₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (uniti₊ ◎ (c₁ ⊕ c₂)) ⇔ (c₂ ◎ uniti₊)
  unitir₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (c₂ ◎ uniti₊) ⇔ (uniti₊ ◎ (c₁ ⊕ c₂))
  unitial₊⇔ : {t₁ t₂ : U} → (uniti₊ {PLUS t₁ t₂} ◎ assocl₊) ⇔ (uniti₊ ⊕ id⟷)
  unitiar₊⇔ : {t₁ t₂ : U} → (uniti₊ {t₁} ⊕ id⟷ {t₂}) ⇔ (uniti₊ ◎ assocl₊)
  swapl₊⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          (swap₊ ◎ (c₁ ⊕ c₂)) ⇔ ((c₂ ⊕ c₁) ◎ swap₊)
  swapr₊⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          ((c₂ ⊕ c₁) ◎ swap₊) ⇔ (swap₊ ◎ (c₁ ⊕ c₂))
  unitel⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (unite⋆ ◎ c₂) ⇔ ((c₁ ⊗ c₂) ◎ unite⋆)
  uniter⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          ((c₁ ⊗ c₂) ◎ unite⋆) ⇔ (unite⋆ ◎ c₂)
  unitil⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (uniti⋆ ◎ (c₁ ⊗ c₂)) ⇔ (c₂ ◎ uniti⋆)
  unitir⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (c₂ ◎ uniti⋆) ⇔ (uniti⋆ ◎ (c₁ ⊗ c₂))
  unitial⋆⇔ : {t₁ t₂ : U} → (uniti⋆ {TIMES t₁ t₂} ◎ assocl⋆) ⇔ (uniti⋆ ⊗ id⟷)
  unitiar⋆⇔ : {t₁ t₂ : U} → (uniti⋆ {t₁} ⊗ id⟷ {t₂}) ⇔ (uniti⋆ ◎ assocl⋆)
  swapl⋆⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          (swap⋆ ◎ (c₁ ⊗ c₂)) ⇔ ((c₂ ⊗ c₁) ◎ swap⋆)
  swapr⋆⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          ((c₂ ⊗ c₁) ◎ swap⋆) ⇔ (swap⋆ ◎ (c₁ ⊗ c₂))
  swapfl⋆⇔ : {t₁ t₂ t₃ : U} → 
          (swap₊ {TIMES t₂ t₃} {TIMES t₁ t₃} ◎ factor) ⇔ 
          (factor ◎ (swap₊ {t₂} {t₁} ⊗ id⟷))
  swapfr⋆⇔ : {t₁ t₂ t₃ : U} → 
          (factor ◎ (swap₊ {t₂} {t₁} ⊗ id⟷)) ⇔ 
         (swap₊ {TIMES t₂ t₃} {TIMES t₁ t₃} ◎ factor)
  id⇔     : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ c
  trans⇔  : {t₁ t₂ : U} {c₁ c₂ c₃ : t₁ ⟷ t₂} → 
         (c₁ ⇔ c₂) → (c₂ ⇔ c₃) → (c₁ ⇔ c₃)
  resp◎⇔  : {t₁ t₂ t₃ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₁ ⟷ t₂} {c₄ : t₂ ⟷ t₃} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ◎ c₂) ⇔ (c₃ ◎ c₄)
  resp⊕⇔  : {t₁ t₂ t₃ t₄ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₁ ⟷ t₂} {c₄ : t₃ ⟷ t₄} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ⊕ c₂) ⇔ (c₃ ⊕ c₄)
  resp⊗⇔  : {t₁ t₂ t₃ t₄ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₁ ⟷ t₂} {c₄ : t₃ ⟷ t₄} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ⊗ c₂) ⇔ (c₃ ⊗ c₄)

-- better syntax for writing 2paths

infix  2  _▤       
infixr 2  _⇔⟨_⟩_   

_⇔⟨_⟩_ : {t₁ t₂ : U} (c₁ : t₁ ⟷ t₂) {c₂ : t₁ ⟷ t₂} {c₃ : t₁ ⟷ t₂} → 
         (c₁ ⇔ c₂) → (c₂ ⇔ c₃) → (c₁ ⇔ c₃)
_ ⇔⟨ α ⟩ β = trans⇔ α β 

_▤ : {t₁ t₂ : U} → (c : t₁ ⟷ t₂) → (c ⇔ c)
_▤ c = id⇔ 

-- Inverses for 2paths

2! : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ⇔ c₂) → (c₂ ⇔ c₁)
2! assoc◎l = assoc◎r
2! assoc◎r = assoc◎l
2! assoc⊕l = assoc⊕r
2! assoc⊕r = assoc⊕l
2! assoc⊗l = assoc⊗r
2! assoc⊗r = assoc⊗l
2! dist⇔ = factor⇔ 
2! factor⇔ = dist⇔
2! idl◎l = idl◎r
2! idl◎r = idl◎l
2! idr◎l = idr◎r
2! idr◎r = idr◎l
2! linv◎l = linv◎r
2! linv◎r = linv◎l
2! rinv◎l = rinv◎r
2! rinv◎r = rinv◎l
2! unitel₊⇔ = uniter₊⇔
2! uniter₊⇔ = unitel₊⇔
2! unitil₊⇔ = unitir₊⇔
2! unitir₊⇔ = unitil₊⇔
2! swapl₊⇔ = swapr₊⇔
2! swapr₊⇔ = swapl₊⇔
2! unitial₊⇔ = unitiar₊⇔ 
2! unitiar₊⇔ = unitial₊⇔ 
2! unitel⋆⇔ = uniter⋆⇔
2! uniter⋆⇔ = unitel⋆⇔
2! unitil⋆⇔ = unitir⋆⇔
2! unitir⋆⇔ = unitil⋆⇔
2! unitial⋆⇔ = unitiar⋆⇔ 
2! unitiar⋆⇔ = unitial⋆⇔ 
2! swapl⋆⇔ = swapr⋆⇔
2! swapr⋆⇔ = swapl⋆⇔
2! swapfl⋆⇔ = swapfr⋆⇔
2! swapfr⋆⇔ = swapfl⋆⇔
2! id⇔ = id⇔
2! (trans⇔ α β) = trans⇔ (2! β) (2! α)
2! (resp◎⇔ α β) = resp◎⇔ (2! α) (2! β)
2! (resp⊕⇔ α β) = resp⊕⇔ (2! α) (2! β)
2! (resp⊗⇔ α β) = resp⊗⇔ (2! α) (2! β) 

-- a nice example of 2 paths

negEx : neg₅ ⇔ neg₁
negEx = uniti⋆ ◎ (swap⋆ ◎ ((swap₊ ⊗ id⟷) ◎ (swap⋆ ◎ unite⋆)))
          ⇔⟨ resp◎⇔ id⇔ assoc◎l ⟩
        uniti⋆ ◎ ((swap⋆ ◎ (swap₊ ⊗ id⟷)) ◎ (swap⋆ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ swapl⋆⇔ id⇔) ⟩
        uniti⋆ ◎ (((id⟷ ⊗ swap₊) ◎ swap⋆) ◎ (swap⋆ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ assoc◎r ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ (swap⋆ ◎ (swap⋆ ◎ unite⋆)))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ assoc◎l) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ ((swap⋆ ◎ swap⋆) ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ (resp◎⇔ linv◎l id⇔)) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ (id⟷ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ idl◎l) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ unite⋆)
          ⇔⟨ assoc◎l ⟩
        (uniti⋆ ◎ (id⟷ ⊗ swap₊)) ◎ unite⋆
          ⇔⟨ resp◎⇔ unitil⋆⇔ id⇔ ⟩
        (swap₊ ◎ uniti⋆) ◎ unite⋆
          ⇔⟨ assoc◎r ⟩
        swap₊ ◎ (uniti⋆ ◎ unite⋆)
          ⇔⟨ resp◎⇔ id⇔ linv◎l ⟩
        swap₊ ◎ id⟷
          ⇔⟨ idr◎l ⟩
        swap₊ ▤

-- The equivalence ⇔ of paths is rich enough to make U a 1groupoid:
-- the points are types (t : U); the 1paths are ⟷; and the 2paths
-- between them are based on the simplification rules ⇔ 

G' : 1Groupoid
G' = record
        { set = U
        ; _↝_ = _⟷_
        ; _≈_ = _⇔_
        ; id  = id⟷
        ; _∘_ = λ p q → q ◎ p
        ; _⁻¹ = !
        ; lneutr = λ _ → idr◎l
        ; rneutr = λ _ → idl◎l
        ; assoc  = λ _ _ _ → assoc◎l
        ; equiv = record { 
            refl  = id⇔
          ; sym   = 2!
          ; trans = trans⇔
          }
        ; linv = λ {t₁} {t₂} α → linv◎l
        ; rinv = λ {t₁} {t₂} α → rinv◎l
        ; ∘-resp-≈ = λ p∼q r∼s → resp◎⇔ r∼s p∼q 
        }

------------------------------------------------------------------------------
-- Inverting permutations to syntactic combinators

perm2comb : {t₁ t₂ : U} → (size t₁ ≡ size t₂) → Perm (size t₁) → (t₁ ⟷ t₂)
perm2comb {ZERO} {t₂} sp [] = {!!} 
perm2comb {ONE} {t₂} sp p = {!!} 
perm2comb {PLUS t₁ t₂} {t₃} sp p = {!!} 
perm2comb {TIMES t₁ t₂} {t₃} sp p = {!!} 

------------------------------------------------------------------------------
-- Soundness and completeness
-- 
-- Proof of soundness and completeness: now we want to verify that ⇔
-- is sound and complete with respect to ∼. The statement to prove is
-- that for all c₁ and c₂, we have c₁ ∼ c₂ iff c₁ ⇔ c₂

soundness : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ⇔ c₂) → (c₁ ∼ c₂)
soundness assoc◎l      = assoc∼
soundness assoc◎r      = sym∼ assoc∼
soundness assoc⊕l      = assoc⊕∼
soundness assoc⊕r      = sym∼ assoc⊕∼
soundness assoc⊗l      = assoc⊗∼
soundness assoc⊗r      = sym∼ assoc⊗∼
soundness dist⇔        = {!!}
soundness factor⇔      = {!!}
soundness idl◎l        = id◎c∼c
soundness idl◎r        = sym∼ id◎c∼c
soundness idr◎l        = c◎id∼c
soundness idr◎r        = sym∼ c◎id∼c
soundness linv◎l       = linv∼
soundness linv◎r       = sym∼ linv∼
soundness rinv◎l       = rinv∼
soundness rinv◎r       = sym∼ rinv∼
soundness unitel₊⇔     = {!!}
soundness uniter₊⇔     = {!!}
soundness unitil₊⇔     = {!!}
soundness unitir₊⇔     = {!!}
soundness unitial₊⇔    = {!!}
soundness unitiar₊⇔    = {!!}
soundness swapl₊⇔      = {!!}
soundness swapr₊⇔      = {!!}
soundness unitel⋆⇔     = {!!}
soundness uniter⋆⇔     = {!!}
soundness unitil⋆⇔     = {!!}
soundness unitir⋆⇔     = {!!}
soundness unitial⋆⇔    = {!!}
soundness unitiar⋆⇔    = {!!}
soundness swapl⋆⇔      = {!!}
soundness swapr⋆⇔      = {!!}
soundness swapfl⋆⇔     = {!!}
soundness swapfr⋆⇔     = {!!}
soundness id⇔          = refl∼
soundness (trans⇔ α β) = trans∼ (soundness α) (soundness β)
soundness (resp◎⇔ α β) = resp∼ (soundness α) (soundness β)
soundness (resp⊕⇔ α β) = {!!}
soundness (resp⊗⇔ α β) = {!!} 

-- The idea is to invert evaluation and use that to extract from each
-- extensional representation of a combinator, a canonical syntactic
-- representative

canonical : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₁ ⟷ t₂)
canonical c = perm2comb (size≡ c) (comb2perm c)

-- Note that if c₁ ⇔ c₂, then by soundness c₁ ∼ c₂ and hence their
-- canonical representatives are identical. 

canonicalWellDefined : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → 
  (c₁ ⇔ c₂) → (canonical c₁ ≡ canonical c₂)
canonicalWellDefined {t₁} {t₂} {c₁} {c₂} α = 
  cong₂ perm2comb (size∼ c₁ c₂) (soundness α) 

-- If we can prove that every combinator is equal to its normal form
-- then we can prove completeness.

inversion : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ canonical c
inversion = {!!} 

resp≡⇔ : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ≡ c₂) → (c₁ ⇔ c₂)
resp≡⇔ {t₁} {t₂} {c₁} {c₂} p rewrite p = id⇔ 

completeness : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₁ ⇔ c₂)
completeness {t₁} {t₂} {c₁} {c₂} c₁∼c₂ = 
  c₁
    ⇔⟨ inversion ⟩
  canonical c₁
    ⇔⟨  resp≡⇔ (cong₂ perm2comb (size∼ c₁ c₂) c₁∼c₂) ⟩ 
  canonical c₂
    ⇔⟨ 2! inversion ⟩ 
  c₂ ▤

------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Nat and Fin lemmas

suc≤ : (m n : ℕ) → suc m ≤ m + suc n
suc≤ 0 n       = s≤s z≤n
suc≤ (suc m) n = s≤s (suc≤ m n)

-+-id : (n : ℕ) → (i : Fin n) → suc (n ∸ toℕ i) + toℕ i ≡ suc n
-+-id 0 ()            -- absurd
-+-id (suc n) zero    = +-right-identity (suc (suc n))
-+-id (suc n) (suc i) = begin
  suc (suc n ∸ toℕ (suc i)) + toℕ (suc i) 
    ≡⟨ refl ⟩
  suc (n ∸ toℕ i) + suc (toℕ i) 
    ≡⟨ +-suc (suc (n ∸ toℕ i)) (toℕ i) ⟩
  suc (suc (n ∸ toℕ i) + toℕ i)
    ≡⟨ cong suc (-+-id n i) ⟩
  suc (suc n) ∎

p0 p1 : Perm 4
p0 = idπ
p1 = swap (inject+ 1 (fromℕ 2)) (inject+ 3 (fromℕ 0))
     (swap (fromℕ 3) zero
     (swap zero (inject+ 1 (fromℕ 2))
     idπ))


xx = action p1 (10 ∷ 20 ∷ 30 ∷ 40 ∷ [])

n≤sn : ∀ {x} → x ≤ suc x
n≤sn {0}     = z≤n
n≤sn {suc n} = s≤s (n≤sn {n})

<implies≤ : ∀ {x y} → (x < y) → (x ≤ y)
<implies≤ (s≤s z≤n) = z≤n 
<implies≤ {suc x} {suc y} (s≤s p) = 
  begin (suc x 
           ≤⟨ p ⟩
         y
            ≤⟨ n≤sn {y} ⟩
         suc y ∎)
  where open ≤-Reasoning

bounded≤ : ∀ {n} (i : Fin n) → toℕ i ≤ n
bounded≤ i = <implies≤ (bounded i)
                 
n≤n : (n : ℕ) → n ≤ n
n≤n 0 = z≤n
n≤n (suc n) = s≤s (n≤n n)

-- Convenient way of "seeing" what the permutation does for each combinator

matchP : ∀ {t t'} → (t ⟷ t') → Vec (⟦ t ⟧ × ⟦ t' ⟧) (size t)
matchP {t} {t'} c = 
  match sp (comb2perm c) (utoVec t) 
    (subst (λ n → Vec ⟦ t' ⟧ n) (sym sp) (utoVec t'))
  where sp = size≡ c

infix 90 _X_

data Swap (n : ℕ) : Set where
  _X_ : Fin n → Fin n → Swap n

Perm : ℕ → Set
Perm n = List (Swap n)

showSwap : ∀ {n} → Swap n → String
showSwap (i X j) = show (toℕ i) ++S " X " ++S show (toℕ j)

actionπ : ∀ {ℓ} {A : Set ℓ} {n : ℕ} → Perm n → Vec A n → Vec A n
actionπ π vs = foldl swapX vs π
  where 
    swapX : ∀ {ℓ} {A : Set ℓ} {n : ℕ} → Vec A n → Swap n → Vec A n  
    swapX vs (i X j) = (vs [ i ]≔ lookup j vs) [ j ]≔ lookup i vs

swapπ : ∀ {m n} → Perm (m + n)
swapπ {0}     {n}     = []
swapπ {suc m} {n}     = 
  concatL 
    (replicate (suc m)
      (toList 
        (zipWith _X_ 
          (mapV inject₁ (allFin (m + n))) 
          (tail (allFin (suc m + n))))))

scompπ : ∀ {n} → Perm n → Perm n → Perm n
scompπ = _++L_

injectπ : ∀ {m} → Perm m → (n : ℕ) → Perm (m + n)
injectπ π n = mapL (λ { (i X j) → (inject+ n i) X (inject+ n j) }) π 

raiseπ : ∀ {n} → Perm n → (m : ℕ) → Perm (m + n)
raiseπ π m = mapL (λ { (i X j) → (raise m i) X (raise m j) }) π 

pcompπ : ∀ {m n} → Perm m → Perm n → Perm (m + n)
pcompπ {m} {n} α β = (injectπ α n) ++L (raiseπ β m)

idπ : ∀ {n} → Perm n
idπ {n} = toList (zipWith _X_ (allFin n) (allFin n))

tcompπ : ∀ {m n} → Perm m → Perm n → Perm (m * n)
tcompπ {m} {n} α β = 
  concatL (mapL 
            (λ { (i X j) → 
                 mapL (λ { (k X l) → 
                        (inject≤ (fromℕ (toℕ i * n + toℕ k)) 
                                 (i*n+k≤m*n i k))
                        X 
                        (inject≤ (fromℕ (toℕ j * n + toℕ l)) 
                                 (i*n+k≤m*n j l))})
                      (β ++L idπ {n})})
            (α ++L idπ {m}))

module Sort (A : Set) {_<_ : Rel A lzero} ( _<?_ : Decidable _<_) where
  insert : (A × A → A × A) → A → List A → List A
  insert shift x [] = x ∷ []
  insert shift x (y ∷ ys) with x <? y
  ... | yes _ = x ∷ y ∷ ys
  ... | no _ = let (y' , x') = shift (x , y) 
               in y' ∷ insert shift x' ys

  sort : (A × A → A × A) → List A → List A
  sort shift [] = []
  sort shift (x ∷ xs) = insert shift x (sort shift xs)

data _<S_ {n : ℕ} : Rel (Transposition< n) lzero where
   <1 : ∀ {i j k l : Fin n} {p₁ : toℕ i < toℕ j} {p₂ : toℕ k < toℕ l} → 
       (toℕ i < toℕ k) → (_X_ i j {p₁}) <S (_X_ k l {p₂})
   <2 : ∀ {i j k l : Fin n} {p₁ : toℕ i < toℕ j} {p₂ : toℕ k < toℕ l} →  
       (toℕ i ≡ toℕ k) → (toℕ j < toℕ l) → 
       (_X_ i j {p₁}) <S (_X_ k l {p₂})

d<S : {n : ℕ} → Decidable (_<S_ {n})
d<S (_X_ i j {p₁}) (_X_ k l {p₂}) with suc (toℕ i) ≤? toℕ k 
d<S (_X_ i j {p₁}) (_X_ k l {p₂}) | yes p = yes (<1 p)
d<S (_X_ i j {p₁}) (_X_ k l {p₂}) | no p with toℕ i ≟ toℕ k
d<S (_X_ i j {p₁}) (_X_ k l {p₂}) | no p | yes p= with suc (toℕ j) ≤? toℕ l
d<S (_X_ i j {p₁}) (_X_ k l {p₂}) | no p | yes p= | yes p' = yes (<2 p= p')
d<S (_X_ i j {p₁}) (_X_ k l {p₂}) | no p | yes p= | no p' = 
  no (λ { (<1 i<k) → p i<k ;
          (<2 i≡k j<l) → p' j<l})
d<S (_X_ i j {p₁}) (_X_ k l {p₂}) | no p | no p≠ = 
  no (λ { (<1 i<k) → p i<k ;
          (<2 i≡k j<l) → p≠ i≡k })

module TSort (n : ℕ) = Sort (Transposition< n) {_<S_} d<S 

-- If we shift a transposition past another, there is nothing to do if
-- the four indices are different. If however there is a common index,
-- we have to adjust the transpositions.

shift : {n : ℕ} → Transposition< n × Transposition< n → 
                  Transposition< n × Transposition< n
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  with toℕ i ≟ toℕ k | toℕ i ≟ toℕ l | toℕ j ≟ toℕ k | toℕ j ≟ toℕ l
--
-- a bunch of impossible cases given that i < j and k < l
--
shift {n} (_X_ i j {i<j} , _X_ k l {k<l})  
  | _ | _ | yes j≡k | yes j≡l 
  with trans (sym j≡k) (j≡l) | i<j→i≠j {toℕ k} {toℕ l} k<l
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | _ | yes j≡k | yes j≡l
  | k≡l | ¬k≡l with ¬k≡l k≡l
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | _ | yes j≡k | yes j≡l
  | k≡l | ¬k≡l | ()
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | yes i≡l | _ | yes j≡l 
  with trans i≡l (sym j≡l) | i<j→i≠j {toℕ i} {toℕ j} i<j
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | yes i≡l | _ | yes j≡l 
  | i≡j | ¬i≡j with ¬i≡j i≡j
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | yes i≡l | _ | yes j≡l 
  | i≡j | ¬i≡j | ()
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | _ | yes j≡k | _
  with trans i≡k (sym j≡k) | i<j→i≠j {toℕ i} {toℕ j} i<j 
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | _ | yes j≡k | _
  | i≡j | ¬i≡j with ¬i≡j i≡j
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | _ | yes j≡k | _
  | i≡j | ¬i≡j | ()
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | yes i≡l | _ | _
  with trans (sym i≡k) i≡l | i<j→i≠j {toℕ k} {toℕ l} k<l 
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | yes i≡l | _ | _
  | k≡l | ¬k≡l with ¬k≡l k≡l
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | yes i≡l | _ | _
  | k≡l | ¬k≡l | ()
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | yes i≡l | yes j≡k | _
  with subst₂ _<_ (sym j≡k) (sym i≡l) k<l | i<j→j≮i {toℕ i} {toℕ j} i<j
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | yes i≡l | yes j≡k | _
  | j<i | j≮i with j≮i j<i
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | _ | yes i≡l | yes j≡k | _
  | j<i | j≮i | ()
--
-- end of impossible cases
--
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l = 
    -- no interference
    (_X_ k l {k<l} , _X_ i j {i<j})  
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | no ¬i≡l | no ¬j≡k | yes j≡l = 
  -- Ex: 2 X 5 , 2 X 5
  (_X_ k l {k<l} , _X_ i j {i<j})   
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | yes j≡l 
  with toℕ i <? toℕ k 
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | yes j≡l 
  | yes i<k = 
  (_X_ i k {i<k} , _X_ i j {i<j})
  -- Ex: 2 X 5 , 3 X 5 
  -- becomes 2 X 3 , 2 X 5
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | yes j≡l 
  | no i≮k = 
  (_X_ k i 
    {i≰j∧j≠i→j<i (toℕ i) (toℕ k) (i≮j∧i≠j→i≰j (toℕ i) (toℕ k) i≮k ¬i≡k) 
       (i≠j→j≠i (toℕ i) (toℕ k) ¬i≡k)} , 
  _X_ i j {i<j}) 
  -- Ex: 2 X 5 , 1 X 5 
  -- becomes 1 X 2 , 2 X 5
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | no ¬i≡k | no ¬i≡l | yes j≡k | no ¬j≡l = 
  -- Ex: 2 X 5 , 5 X 6 
  -- becomes 2 x 6 , 2 X 5 
  (_X_ i l {trans< (subst ((λ j → toℕ i < j)) j≡k i<j) k<l} , _X_ i j {i<j})
shift {n} (_X_ i j {i<j} , _X_ k l {k<l})  
  | no ¬i≡k | yes i≡l | no ¬j≡k | no ¬j≡l = 
  -- Ex: 2 X 5 , 1 X 2 
  -- becomes 1 X 5 , 2 X 5
  (_X_ k j {trans< (subst ((λ l → toℕ k < l)) (sym i≡l) k<l) i<j} , 
   _X_ i j {i<j})
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l 
  with toℕ j <? toℕ l
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l 
  | yes j<l = 
  -- Ex: 2 X 3 , 2 X 4
  -- becomes 3 X 4 , 2 X 3
  (_X_ j l {j<l} , _X_ i j {i<j}) 
shift {n} (_X_ i j {i<j} , _X_ k l {k<l}) 
  | yes i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l 
  | no j≮l = 
  -- Ex: 2 X 5 , 2 X 4
  -- becomes 4 X 5 , 2 X 5
  (_X_ l j {i≰j∧j≠i→j<i (toℕ j) (toℕ l) (i≮j∧i≠j→i≰j (toℕ j) (toℕ l) j≮l ¬j≡l) 
       (i≠j→j≠i (toℕ j) (toℕ l) ¬j≡l)} , 
   _X_ i j {i<j}) 

-- Coalesce permutations i X j followed by i X k

-- Do termination proof...
{-# NO_TERMINATION_CHECK #-}
coalesce : {n : ℕ} → Perm< n → Perm< n
coalesce [] = []
coalesce (x ∷ []) = x ∷ []
coalesce (_X_ i j {i<j} ∷ _X_ k l {k<l} ∷ π) with toℕ i ≟ toℕ k
coalesce (_X_ i j {i<j} ∷ _X_ k l {k<l} ∷ π) 
  | no ¬i≡k = _X_ i j {i<j} ∷ coalesce (_X_ k l {k<l} ∷ π)
coalesce (_X_ i j {i<j} ∷ _X_ k l {k<l} ∷ π) 
  | yes i≡k with toℕ j <? toℕ l 
coalesce {n} (_X_ i j {i<j} ∷ _X_ k l {k<l} ∷ π) 
  | yes i≡k | yes j<l = 
  -- Ex: 2 X 5 , 2 X 6
  -- becomes 2 X 6 , 5 X 6
  coalesce {n} (sort (shift {n}) (_X_ k l {k<l} ∷ _X_ j l {j<l} ∷ π))
  where open TSort n
coalesce {n} (_X_ i j {i<j} ∷ _X_ k l {k<l} ∷ π) 
  | yes i≡k | no j≮l with toℕ j ≟ toℕ l
coalesce {n} (_X_ i j {i<j} ∷ _X_ k l {k<l} ∷ π) 
  | yes i≡k | no j≮l | yes j≡l = 
  -- Ex: 2 X 5 , 2 X 5
  -- disappears
  coalesce {n} π
coalesce {n} (_X_ i j {i<j} ∷ _X_ k l {k<l} ∷ π) 
  | yes i≡k | no j≮l | no ¬j≡l = 
  -- Ex: 2 X 5 , 2 X 3
  -- becomes 2 X 3 , 3 X 5 
  -- should never happen if input is sorted but the type Perm< 
  -- does not capture this
  coalesce {n} 
    (sort 
      (shift {n}) 
        (_X_ k l {k<l} ∷ 
         _X_ l j {i≰j∧j≠i→j<i (toℕ j) (toℕ l) 
                    (i≮j∧i≠j→i≰j (toℕ j) (toℕ l) j≮l ¬j≡l)
                    (i≠j→j≠i (toℕ j) (toℕ l) ¬j≡l)} ∷ 
         π))
  where open TSort n
  
-- Normalized permutations have exactly one entry for each position

infixr 5 _∷_

data NPerm : ℕ → Set where
  []  : NPerm 0
  _∷_ : {n : ℕ} → Fin (suc n) → NPerm n → NPerm (suc n)

lookupP : ∀ {n} → Fin n → NPerm n → Fin n
lookupP () [] 
lookupP zero (j ∷ _) = j
lookupP {suc n} (suc i) (j ∷ q) = inject₁ (lookupP i q)

insert : ∀ {ℓ n} {A : Set ℓ} → Vec A n → Fin (suc n) → A → Vec A (suc n)
insert vs zero w          = w ∷ vs
insert [] (suc ())        -- absurd
insert (v ∷ vs) (suc i) w = v ∷ insert vs i w

-- A normalized permutation acts on a vector by inserting each element in its
-- new position.

permute : ∀ {ℓ n} {A : Set ℓ} → NPerm n → Vec A n → Vec A n
permute []       []       = []
permute (p ∷ ps) (v ∷ vs) = insert (permute ps vs) p v

-- Convert normalized permutation to a sequence of transpositions

nperm2list : ∀ {n} → NPerm n → Perm< n
nperm2list {0} [] = []
nperm2list {suc n} (p ∷ ps) = {!!} 

-- Aggregate a sequence of transpositions to one insertion in the right
-- position

aggregate : ∀ {n} → Perm< n → NPerm n
aggregate = {!!} 

{--
aggregate [] = []
aggregate (_X_ i j {p₁} ∷ []) = _X_ i j {p₁} ∷ []
aggregate (_X_ i j {p₁} ∷ _X_ k l {p₂} ∷ π) with toℕ i ≟ toℕ k | toℕ j ≟ toℕ l 
aggregate (_X_ i j {p₁} ∷ _X_ k l {p₂} ∷ π) | yes _ | yes _ = 
  aggregate (_X_ k l {p₂} ∷ π)
aggregate (_X_ i j {p₁} ∷ _X_ k l {p₂} ∷ π) | _ | _ = 
  (_X_ i j {p₁}) ∷ aggregate (_X_ k l {p₂} ∷ π)
--}

normalize : ∀ {n} → Perm n → NPerm n
normalize {n} = aggregate ∘ sort ∘ normalize< 
  where open TSort n

-- Examples

nsnn₁ nsnn₂ nsnn₃ nsnn₄ nsnn₅ : List String
nsnn₁ = mapL showTransposition< (nperm2list (normalize (c2π neg₁)))
  where open TSort 2
   -- 0 X 1 ∷ []
nsnn₂ = mapL showTransposition< (nperm2list (normalize (c2π neg₂)))
  where open TSort 2
   -- 0 X 1 ∷ []
nsnn₃ = mapL showTransposition< (nperm2list (normalize (c2π neg₃)))
  where open TSort 2
   -- 0 X 1 ∷ []
nsnn₄ = mapL showTransposition< (nperm2list (normalize (c2π neg₄)))
  where open TSort 2
   -- 0 X 1 ∷ []
nsnn₅ = mapL showTransposition< (nperm2list (normalize (c2π neg₅)))
  where open TSort 2
   -- 0 X 1 ∷ []

nswap₁₂ nswap₂₃ nswap₁₃ : List String
nswap₁₂ = mapL showTransposition< (nperm2list (normalize (c2π SWAP12)))
nswap₂₃ = mapL showTransposition< (nperm2list (normalize (c2π SWAP23)))
nswap₁₃ = mapL showTransposition< (nperm2list (normalize (c2π SWAP13)))

xxx : Perm 5
xxx = (_X_ (inject+ 1 (fromℕ 3)) (fromℕ 4) {s≤s (s≤s (s≤s z≤n))}) ∷
      (_X_ (inject+ 3 (fromℕ 1)) (inject+ 1 (fromℕ 3)) {s≤s z≤n}) ∷
      (_X_ zero (inject+ 1 (fromℕ 3)) {z≤n}) ∷
      (_X_ (inject+ 3 (fromℕ 1)) (inject+ 2 (fromℕ 2)) {s≤s z≤n}) ∷ []
 
yyy : ∀ {ℓ m n} {A B : Set ℓ} → Vec A m → Vec B n → Vec (A ⊎ B) (m + n)
yyy vs ws = mapV inj₁ vs ++V mapV inj₂ ws

xxx : ∀ {ℓ m n} {A B : Set ℓ} → Vec A m → Vec B n → Vec (A × B) (m * n)
xxx vs ws = concatV (mapV (λ v₁ → mapV (λ v₂ → (v₁ , v₂)) ws) vs)

vs : Vec ℕ 7
vs = 0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ 5 ∷ 6 ∷ []

ws : Vec ℕ 5
ws = 10 ∷ 11 ∷ 12 ∷ 13 ∷ 14 ∷ []

us : Vec ℕ 3
us = 100 ∷ 101 ∷ 102 ∷ []

os : Vec ℕ 1
os = 1000 ∷ []


-- xxx vs ws 
-- (0 , 10) ∷ (0 , 11) ∷ (0 , 12) ∷ (0 , 13) ∷ (0 , 14) ∷ 
-- (1 , 10) ∷ (1 , 11) ∷ (1 , 12) ∷ (1 , 13) ∷ (1 , 14) ∷
-- (2 , 10) ∷ (2 , 11) ∷ (2 , 12) ∷ (2 , 13) ∷ (2 , 14) ∷
-- (3 , 10) ∷ (3 , 11) ∷ (3 , 12) ∷ (3 , 13) ∷ (3 , 14) ∷
-- (4 , 10) ∷ (4 , 11) ∷ (4 , 12) ∷ (4 , 13) ∷ (4 , 14) ∷
-- (5 , 10) ∷ (5 , 11) ∷ (5 , 12) ∷ (5 , 13) ∷ (5 , 14) ∷
-- (6 , 10) ∷ (6 , 11) ∷ (6 , 12) ∷ (6 , 13) ∷ (6 , 14) ∷ 
-- []

-- xxx ws vs
-- (10 , 0) ∷ (10 , 1) ∷ (10 , 2) ∷ (10 , 3) ∷ (10 , 4) ∷ (10 , 5) ∷ (10 , 6) ∷
-- (11 , 0) ∷ (11 , 1) ∷ (11 , 2) ∷ (11 , 3) ∷ (11 , 4) ∷ (11 , 5) ∷ (11 , 6) ∷
-- (12 , 0) ∷ (12 , 1) ∷ (12 , 2) ∷ (12 , 3) ∷ (12 , 4) ∷ (12 , 5) ∷ (12 , 6) ∷
-- (13 , 0) ∷ (13 , 1) ∷ (13 , 2) ∷ (13 , 3) ∷ (13 , 4) ∷ (13 , 5) ∷ (13 , 6) ∷
-- (14 , 0) ∷ (14 , 1) ∷ (14 , 2) ∷ (14 , 3) ∷ (14 , 4) ∷ (14 , 5) ∷ (14 , 6) ∷ 
-- []

xxx : Perm 5
xxx = cycle→Perm
        (inject+ 3 (fromℕ 1) ∷
         inject+ 1 (fromℕ 3) ∷
         inject+ 2 (fromℕ 2) ∷
         inject+ 0 (fromℕ 4) ∷ [])

-- cycle (1 3 2 4) 
-- 1 X 4 ∷ 1 X 2 ∷ 1 X 3 ∷ []

a : Vec ℕ 5
a = 0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ []
-- actionπ xxx a 
-- 0 ∷ 3 ∷ 4 ∷ 2 ∷ 1 ∷ []

bbb = transpose {3} {4} -- 3 * 2 => 2 * 3
-- (zero , zero) ∷
-- (suc zero , suc (suc (suc zero))) ∷
-- (suc (suc zero) , suc zero) ∷
-- (suc (suc (suc zero)) , suc (suc (suc (suc zero)))) ∷
-- (suc (suc (suc (suc zero))) , suc (suc zero)) ∷ []

{--
------------------------------------------------------------------------------
-- Extensional equivalence of combinators: two combinators are
-- equivalent if they denote the same permutation. Generally we would
-- require that the two permutations map the same value x to values y
-- and z that have a path between them, but because the internals of each
-- type are discrete groupoids, this reduces to saying that y and z
-- are identical, and hence that the permutations are identical.

normalize : ∀ {n} → Perm n → Perm< n
normalize = sort ∘ filter=

infix  10  _∼_ 

_∼_ : ∀ {t₁ t₂} → (c₁ c₂ : t₁ ⟷ t₂) → Set
c₁ ∼ c₂ = (normalize (c2π c₁) ≡ normalize (c2π c₂))

-- The relation ~ is an equivalence relation

refl∼ : ∀ {t₁ t₂} {c : t₁ ⟷ t₂} → (c ∼ c)
refl∼ = refl 

sym∼ : ∀ {t₁ t₂} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₂ ∼ c₁)
sym∼ = sym

trans∼ : ∀ {t₁ t₂} {c₁ c₂ c₃ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₂ ∼ c₃) → (c₁ ∼ c₃)
trans∼ = trans

-- The relation ~ validates the groupoid laws

c◎id∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ◎ id⟷ ∼ c
c◎id∼c = {!!} 

id◎c∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ◎ c ∼ c
id◎c∼c = {!!} 

assoc∼ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
         c₁ ◎ (c₂ ◎ c₃) ∼ (c₁ ◎ c₂) ◎ c₃
assoc∼ = {!!} 

linv∼ : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ◎ ! c ∼ id⟷
linv∼ = {!!} 

rinv∼ : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → ! c ◎ c ∼ id⟷
rinv∼ = {!!} 

resp∼ : {t₁ t₂ t₃ : U} {c₁ c₂ : t₁ ⟷ t₂} {c₃ c₄ : t₂ ⟷ t₃} → 
        (c₁ ∼ c₂) → (c₃ ∼ c₄) → (c₁ ◎ c₃ ∼ c₂ ◎ c₄)
resp∼ = {!!} 

-- The equivalence ∼ of paths makes U a 1groupoid: the points are
-- types (t : U); the 1paths are ⟷; and the 2paths between them are
-- based on extensional equivalence ∼

G : 1Groupoid
G = record
        { set = U
        ; _↝_ = _⟷_
        ; _≈_ = _∼_
        ; id  = id⟷
        ; _∘_ = λ p q → q ◎ p
        ; _⁻¹ = !
        ; lneutr = λ c → c◎id∼c {c = c}
        ; rneutr = λ c → id◎c∼c {c = c}
        ; assoc  = λ c₃ c₂ c₁ → assoc∼ {c₁ = c₁} {c₂ = c₂} {c₃ = c₃}  
        ; equiv = record { 
            refl  = λ {c} → refl∼ {c = c}
          ; sym   = λ {c₁} {c₂} → sym∼ {c₁ = c₁} {c₂ = c₂}
          ; trans = λ {c₁} {c₂} {c₃} → trans∼ {c₁ = c₁} {c₂ = c₂} {c₃ = c₃} 
          }
        ; linv = λ c → linv∼ {c = c} 
        ; rinv = λ c → rinv∼ {c = c} 
        ; ∘-resp-≈ = {!!} -- λ α β → resp∼ β α 
        }

-- And there are additional laws

assoc⊕∼ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          c₁ ⊕ (c₂ ⊕ c₃) ∼ assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊
assoc⊕∼ = {!!} 

assoc⊗∼ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          c₁ ⊗ (c₂ ⊗ c₃) ∼ assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆
assoc⊗∼ = {!!} 

------------------------------------------------------------------------------
-- Picture so far:
--
--           path p
--   =====================
--  ||   ||             ||
--  ||   ||2path        ||
--  ||   ||             ||
--  ||   ||  path q     ||
--  t₁ =================t₂
--  ||   ...            ||
--   =====================
--
-- The types t₁, t₂, etc are discrete groupoids. The paths between
-- them correspond to permutations. Each syntactically different
-- permutation corresponds to a path but equivalent permutations are
-- connected by 2paths.  But now we want an alternative definition of
-- 2paths that is structural, i.e., that looks at the actual
-- construction of the path t₁ ⟷ t₂ in terms of combinators... The
-- theorem we want is that α ∼ β iff we can rewrite α to β using
-- various syntactic structural rules. We start with a collection of
-- simplication rules and then try to show they are complete.

-- Simplification rules

infix  30 _⇔_

data _⇔_ : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₁ ⟷ t₂) → Set where
  assoc◎l : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
          (c₁ ◎ (c₂ ◎ c₃)) ⇔ ((c₁ ◎ c₂) ◎ c₃)
  assoc◎r : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
          ((c₁ ◎ c₂) ◎ c₃) ⇔ (c₁ ◎ (c₂ ◎ c₃))
  assoc⊕l : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (c₁ ⊕ (c₂ ⊕ c₃)) ⇔ (assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊)
  assoc⊕r : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊) ⇔ (c₁ ⊕ (c₂ ⊕ c₃))
  assoc⊗l : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (c₁ ⊗ (c₂ ⊗ c₃)) ⇔ (assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆)
  assoc⊗r : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆) ⇔ (c₁ ⊗ (c₂ ⊗ c₃))
  dist⇔ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          ((c₁ ⊕ c₂) ⊗ c₃) ⇔ (dist ◎ ((c₁ ⊗ c₃) ⊕ (c₂ ⊗ c₃)) ◎ factor)
  factor⇔ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (dist ◎ ((c₁ ⊗ c₃) ⊕ (c₂ ⊗ c₃)) ◎ factor) ⇔ ((c₁ ⊕ c₂) ⊗ c₃)
  idl◎l   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (id⟷ ◎ c) ⇔ c
  idl◎r   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ id⟷ ◎ c
  idr◎l   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (c ◎ id⟷) ⇔ c
  idr◎r   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ (c ◎ id⟷) 
  linv◎l  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (c ◎ ! c) ⇔ id⟷
  linv◎r  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ⇔ (c ◎ ! c) 
  rinv◎l  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (! c ◎ c) ⇔ id⟷
  rinv◎r  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ⇔ (! c ◎ c) 
  unitel₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (unite₊ ◎ c₂) ⇔ ((c₁ ⊕ c₂) ◎ unite₊)
  uniter₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          ((c₁ ⊕ c₂) ◎ unite₊) ⇔ (unite₊ ◎ c₂)
  unitil₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (uniti₊ ◎ (c₁ ⊕ c₂)) ⇔ (c₂ ◎ uniti₊)
  unitir₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (c₂ ◎ uniti₊) ⇔ (uniti₊ ◎ (c₁ ⊕ c₂))
  unitial₊⇔ : {t₁ t₂ : U} → (uniti₊ {PLUS t₁ t₂} ◎ assocl₊) ⇔ (uniti₊ ⊕ id⟷)
  unitiar₊⇔ : {t₁ t₂ : U} → (uniti₊ {t₁} ⊕ id⟷ {t₂}) ⇔ (uniti₊ ◎ assocl₊)
  swapl₊⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          (swap₊ ◎ (c₁ ⊕ c₂)) ⇔ ((c₂ ⊕ c₁) ◎ swap₊)
  swapr₊⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          ((c₂ ⊕ c₁) ◎ swap₊) ⇔ (swap₊ ◎ (c₁ ⊕ c₂))
  unitel⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (unite⋆ ◎ c₂) ⇔ ((c₁ ⊗ c₂) ◎ unite⋆)
  uniter⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          ((c₁ ⊗ c₂) ◎ unite⋆) ⇔ (unite⋆ ◎ c₂)
  unitil⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (uniti⋆ ◎ (c₁ ⊗ c₂)) ⇔ (c₂ ◎ uniti⋆)
  unitir⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (c₂ ◎ uniti⋆) ⇔ (uniti⋆ ◎ (c₁ ⊗ c₂))
  unitial⋆⇔ : {t₁ t₂ : U} → (uniti⋆ {TIMES t₁ t₂} ◎ assocl⋆) ⇔ (uniti⋆ ⊗ id⟷)
  unitiar⋆⇔ : {t₁ t₂ : U} → (uniti⋆ {t₁} ⊗ id⟷ {t₂}) ⇔ (uniti⋆ ◎ assocl⋆)
  swapl⋆⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          (swap⋆ ◎ (c₁ ⊗ c₂)) ⇔ ((c₂ ⊗ c₁) ◎ swap⋆)
  swapr⋆⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          ((c₂ ⊗ c₁) ◎ swap⋆) ⇔ (swap⋆ ◎ (c₁ ⊗ c₂))
  swapfl⋆⇔ : {t₁ t₂ t₃ : U} → 
          (swap₊ {TIMES t₂ t₃} {TIMES t₁ t₃} ◎ factor) ⇔ 
          (factor ◎ (swap₊ {t₂} {t₁} ⊗ id⟷))
  swapfr⋆⇔ : {t₁ t₂ t₃ : U} → 
          (factor ◎ (swap₊ {t₂} {t₁} ⊗ id⟷)) ⇔ 
         (swap₊ {TIMES t₂ t₃} {TIMES t₁ t₃} ◎ factor)
  id⇔     : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ c
  trans⇔  : {t₁ t₂ : U} {c₁ c₂ c₃ : t₁ ⟷ t₂} → 
         (c₁ ⇔ c₂) → (c₂ ⇔ c₃) → (c₁ ⇔ c₃)
  resp◎⇔  : {t₁ t₂ t₃ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₁ ⟷ t₂} {c₄ : t₂ ⟷ t₃} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ◎ c₂) ⇔ (c₃ ◎ c₄)
  resp⊕⇔  : {t₁ t₂ t₃ t₄ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₁ ⟷ t₂} {c₄ : t₃ ⟷ t₄} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ⊕ c₂) ⇔ (c₃ ⊕ c₄)
  resp⊗⇔  : {t₁ t₂ t₃ t₄ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₁ ⟷ t₂} {c₄ : t₃ ⟷ t₄} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ⊗ c₂) ⇔ (c₃ ⊗ c₄)

-- better syntax for writing 2paths

infix  2  _▤       
infixr 2  _⇔⟨_⟩_   

_⇔⟨_⟩_ : {t₁ t₂ : U} (c₁ : t₁ ⟷ t₂) {c₂ : t₁ ⟷ t₂} {c₃ : t₁ ⟷ t₂} → 
         (c₁ ⇔ c₂) → (c₂ ⇔ c₃) → (c₁ ⇔ c₃)
_ ⇔⟨ α ⟩ β = trans⇔ α β 

_▤ : {t₁ t₂ : U} → (c : t₁ ⟷ t₂) → (c ⇔ c)
_▤ c = id⇔ 

-- Inverses for 2paths

2! : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ⇔ c₂) → (c₂ ⇔ c₁)
2! assoc◎l = assoc◎r
2! assoc◎r = assoc◎l
2! assoc⊕l = assoc⊕r
2! assoc⊕r = assoc⊕l
2! assoc⊗l = assoc⊗r
2! assoc⊗r = assoc⊗l
2! dist⇔ = factor⇔ 
2! factor⇔ = dist⇔
2! idl◎l = idl◎r
2! idl◎r = idl◎l
2! idr◎l = idr◎r
2! idr◎r = idr◎l
2! linv◎l = linv◎r
2! linv◎r = linv◎l
2! rinv◎l = rinv◎r
2! rinv◎r = rinv◎l
2! unitel₊⇔ = uniter₊⇔
2! uniter₊⇔ = unitel₊⇔
2! unitil₊⇔ = unitir₊⇔
2! unitir₊⇔ = unitil₊⇔
2! swapl₊⇔ = swapr₊⇔
2! swapr₊⇔ = swapl₊⇔
2! unitial₊⇔ = unitiar₊⇔ 
2! unitiar₊⇔ = unitial₊⇔ 
2! unitel⋆⇔ = uniter⋆⇔
2! uniter⋆⇔ = unitel⋆⇔
2! unitil⋆⇔ = unitir⋆⇔
2! unitir⋆⇔ = unitil⋆⇔
2! unitial⋆⇔ = unitiar⋆⇔ 
2! unitiar⋆⇔ = unitial⋆⇔ 
2! swapl⋆⇔ = swapr⋆⇔
2! swapr⋆⇔ = swapl⋆⇔
2! swapfl⋆⇔ = swapfr⋆⇔
2! swapfr⋆⇔ = swapfl⋆⇔
2! id⇔ = id⇔
2! (trans⇔ α β) = trans⇔ (2! β) (2! α)
2! (resp◎⇔ α β) = resp◎⇔ (2! α) (2! β)
2! (resp⊕⇔ α β) = resp⊕⇔ (2! α) (2! β)
2! (resp⊗⇔ α β) = resp⊗⇔ (2! α) (2! β) 

-- a nice example of 2 paths

negEx : neg₅ ⇔ neg₁
negEx = uniti⋆ ◎ (swap⋆ ◎ ((swap₊ ⊗ id⟷) ◎ (swap⋆ ◎ unite⋆)))
          ⇔⟨ resp◎⇔ id⇔ assoc◎l ⟩
        uniti⋆ ◎ ((swap⋆ ◎ (swap₊ ⊗ id⟷)) ◎ (swap⋆ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ swapl⋆⇔ id⇔) ⟩
        uniti⋆ ◎ (((id⟷ ⊗ swap₊) ◎ swap⋆) ◎ (swap⋆ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ assoc◎r ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ (swap⋆ ◎ (swap⋆ ◎ unite⋆)))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ assoc◎l) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ ((swap⋆ ◎ swap⋆) ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ (resp◎⇔ linv◎l id⇔)) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ (id⟷ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ idl◎l) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ unite⋆)
          ⇔⟨ assoc◎l ⟩
        (uniti⋆ ◎ (id⟷ ⊗ swap₊)) ◎ unite⋆
          ⇔⟨ resp◎⇔ unitil⋆⇔ id⇔ ⟩
        (swap₊ ◎ uniti⋆) ◎ unite⋆
          ⇔⟨ assoc◎r ⟩
        swap₊ ◎ (uniti⋆ ◎ unite⋆)
          ⇔⟨ resp◎⇔ id⇔ linv◎l ⟩
        swap₊ ◎ id⟷
          ⇔⟨ idr◎l ⟩
        swap₊ ▤

-- The equivalence ⇔ of paths is rich enough to make U a 1groupoid:
-- the points are types (t : U); the 1paths are ⟷; and the 2paths
-- between them are based on the simplification rules ⇔ 

G' : 1Groupoid
G' = record
        { set = U
        ; _↝_ = _⟷_
        ; _≈_ = _⇔_
        ; id  = id⟷
        ; _∘_ = λ p q → q ◎ p
        ; _⁻¹ = !
        ; lneutr = λ _ → idr◎l
        ; rneutr = λ _ → idl◎l
        ; assoc  = λ _ _ _ → assoc◎l
        ; equiv = record { 
            refl  = id⇔
          ; sym   = 2!
          ; trans = trans⇔
          }
        ; linv = λ {t₁} {t₂} α → linv◎l
        ; rinv = λ {t₁} {t₂} α → rinv◎l
        ; ∘-resp-≈ = λ p∼q r∼s → resp◎⇔ r∼s p∼q 
        }

------------------------------------------------------------------------------
-- Inverting permutations to syntactic combinators

π2c : {t₁ t₂ : U} → (size t₁ ≡ size t₂) → NPerm (size t₁) → (t₁ ⟷ t₂)
π2c = {!!}

------------------------------------------------------------------------------
-- Soundness and completeness
-- 
-- Proof of soundness and completeness: now we want to verify that ⇔
-- is sound and complete with respect to ∼. The statement to prove is
-- that for all c₁ and c₂, we have c₁ ∼ c₂ iff c₁ ⇔ c₂

soundness : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ⇔ c₂) → (c₁ ∼ c₂)
soundness assoc◎l      = {!!} -- assoc∼
soundness assoc◎r      = {!!} -- sym∼ assoc∼
soundness assoc⊕l      = {!!} -- assoc⊕∼
soundness assoc⊕r      = {!!} -- sym∼ assoc⊕∼
soundness assoc⊗l      = {!!} -- assoc⊗∼
soundness assoc⊗r      = {!!} -- sym∼ assoc⊗∼
soundness dist⇔        = {!!}
soundness factor⇔      = {!!}
soundness idl◎l        = {!!} -- id◎c∼c
soundness idl◎r        = {!!} -- sym∼ id◎c∼c
soundness idr◎l        = {!!} -- c◎id∼c
soundness idr◎r        = {!!} -- sym∼ c◎id∼c
soundness linv◎l       = {!!} -- linv∼
soundness linv◎r       = {!!} -- sym∼ linv∼
soundness rinv◎l       = {!!} -- rinv∼
soundness rinv◎r       = {!!} -- sym∼ rinv∼
soundness unitel₊⇔     = {!!}
soundness uniter₊⇔     = {!!}
soundness unitil₊⇔     = {!!}
soundness unitir₊⇔     = {!!}
soundness unitial₊⇔    = {!!}
soundness unitiar₊⇔    = {!!}
soundness swapl₊⇔      = {!!}
soundness swapr₊⇔      = {!!}
soundness unitel⋆⇔     = {!!}
soundness uniter⋆⇔     = {!!}
soundness unitil⋆⇔     = {!!}
soundness unitir⋆⇔     = {!!}
soundness unitial⋆⇔    = {!!}
soundness unitiar⋆⇔    = {!!}
soundness swapl⋆⇔      = {!!}
soundness swapr⋆⇔      = {!!}
soundness swapfl⋆⇔     = {!!}
soundness swapfr⋆⇔     = {!!}
soundness id⇔          = {!!} -- refl∼
soundness (trans⇔ α β) = {!!} -- trans∼ (soundness α) (soundness β)
soundness (resp◎⇔ α β) = {!!} -- resp∼ (soundness α) (soundness β)
soundness (resp⊕⇔ α β) = {!!}
soundness (resp⊗⇔ α β) = {!!} 

-- The idea is to invert evaluation and use that to extract from each
-- extensional representation of a combinator, a canonical syntactic
-- representative

canonical : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₁ ⟷ t₂)
canonical c = π2c (size≡ c) (normalize (c2π c))

-- Note that if c₁ ⇔ c₂, then by soundness c₁ ∼ c₂ and hence their
-- canonical representatives are identical. 

canonicalWellDefined : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → 
  (c₁ ⇔ c₂) → (canonical c₁ ≡ canonical c₂)
canonicalWellDefined {t₁} {t₂} {c₁} {c₂} α = 
  cong₂ π2c (size∼ c₁ c₂) (soundness α) 

-- If we can prove that every combinator is equal to its normal form
-- then we can prove completeness.

inversion : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ canonical c
inversion = {!!} 

resp≡⇔ : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ≡ c₂) → (c₁ ⇔ c₂)
resp≡⇔ {t₁} {t₂} {c₁} {c₂} p rewrite p = id⇔ 

completeness : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₁ ⇔ c₂)
completeness {t₁} {t₂} {c₁} {c₂} c₁∼c₂ = 
  c₁
    ⇔⟨ inversion ⟩
  canonical c₁
    ⇔⟨  resp≡⇔ (cong₂ π2c (size∼ c₁ c₂) c₁∼c₂) ⟩ 
  canonical c₂
    ⇔⟨ 2! inversion ⟩ 
  c₂ ▤

------------------------------------------------------------------------------

-- normalize a finite type to (1 + (1 + (1 + ... + (1 + 0) ... )))
-- a bunch of ones ending with zero with left biased + in between

toℕ : U → ℕ
toℕ ZERO          = 0
toℕ ONE           = 1
toℕ (PLUS t₁ t₂)  = toℕ t₁ + toℕ t₂
toℕ (TIMES t₁ t₂) = toℕ t₁ * toℕ t₂

fromℕ : ℕ → U
fromℕ 0       = ZERO
fromℕ (suc n) = PLUS ONE (fromℕ n)

normalℕ : U → U
normalℕ = fromℕ ∘ toℕ

-- invert toℕ: give t and n such that toℕ t = n, return constraints on components of t

reflectPlusZero : {m n : ℕ} → (m + n ≡ 0) → m ≡ 0 × n ≡ 0
reflectPlusZero {0} {0} refl = (refl , refl)
reflectPlusZero {0} {suc n} ()
reflectPlusZero {suc m} {0} ()
reflectPlusZero {suc m} {suc n} ()

-- nbe

nbe : {t₁ t₂ : U} → (p : toℕ t₁ ≡ toℕ t₂) → (⟦ t₁ ⟧ → ⟦ t₂ ⟧) → (t₁ ⟷ t₂)
nbe {ZERO} {ZERO} refl f = id⟷
nbe {ZERO} {ONE} ()
nbe {ZERO} {PLUS t₁ t₂} p f = {!!} 
nbe {ZERO} {TIMES t₂ t₃} p f = {!!}
nbe {ONE} {ZERO} ()
nbe {ONE} {ONE} p f = id⟷
nbe {ONE} {PLUS t₂ t₃} p f = {!!}
nbe {ONE} {TIMES t₂ t₃} p f = {!!}
nbe {PLUS t₁ t₂} {ZERO} p f = {!!}
nbe {PLUS t₁ t₂} {ONE} p f = {!!}
nbe {PLUS t₁ t₂} {PLUS t₃ t₄} p f = {!!}
nbe {PLUS t₁ t₂} {TIMES t₃ t₄} p f = {!!}
nbe {TIMES t₁ t₂} {ZERO} p f = {!!}
nbe {TIMES t₁ t₂} {ONE} p f = {!!}
nbe {TIMES t₁ t₂} {PLUS t₃ t₄} p f = {!!}
nbe {TIMES t₁ t₂} {TIMES t₃ t₄} p f = {!!} 

-- build a combinator that does the normalization

assocrU : {m : ℕ} (n : ℕ) → (PLUS (fromℕ n) (fromℕ m)) ⟷ fromℕ (n + m)
assocrU 0       = unite₊
assocrU (suc n) = assocr₊ ◎ (id⟷ ⊕ assocrU n)

distrU : (m : ℕ) {n : ℕ} → TIMES (fromℕ m) (fromℕ n) ⟷ fromℕ (m * n)
distrU 0           = distz
distrU (suc n) {m} = dist ◎ (unite⋆ ⊕ distrU n) ◎ assocrU m

normalU : (t : U) → t ⟷ normalℕ t
normalU ZERO          = id⟷
normalU ONE           = uniti₊ ◎ swap₊
normalU (PLUS t₁ t₂)  = (normalU t₁ ⊕ normalU t₂) ◎ assocrU (toℕ t₁)
normalU (TIMES t₁ t₂) = (normalU t₁ ⊗ normalU t₂) ◎ distrU (toℕ t₁)

-- a few lemmas

fromℕplus : {m n : ℕ} → fromℕ (m + n) ⟷ PLUS (fromℕ m) (fromℕ n)
fromℕplus {0} {n} = 
  fromℕ n
    ⟷⟨ uniti₊ ⟩
  PLUS ZERO (fromℕ n) □
fromℕplus {suc m} {n} = 
  fromℕ (suc (m + n))
    ⟷⟨ id⟷ ⟩ 
  PLUS ONE (fromℕ (m + n))
    ⟷⟨ id⟷ ⊕ fromℕplus {m} {n} ⟩ 
  PLUS ONE (PLUS (fromℕ m) (fromℕ n))
    ⟷⟨ assocl₊ ⟩ 
  PLUS (PLUS ONE (fromℕ m)) (fromℕ n)
    ⟷⟨ id⟷ ⟩ 
  PLUS (fromℕ (suc m)) (fromℕ n) □

normalℕswap : {t₁ t₂ : U} → normalℕ (PLUS t₁ t₂) ⟷ normalℕ (PLUS t₂ t₁)
normalℕswap {t₁} {t₂} = 
  fromℕ (toℕ t₁ + toℕ t₂) 
    ⟷⟨ fromℕplus {toℕ t₁} {toℕ t₂} ⟩
  PLUS (normalℕ t₁) (normalℕ t₂)
    ⟷⟨ swap₊ ⟩
  PLUS (normalℕ t₂) (normalℕ t₁)
    ⟷⟨ ! (fromℕplus {toℕ t₂} {toℕ t₁}) ⟩
  fromℕ (toℕ t₂ + toℕ t₁) □

assocrUS : {m : ℕ} {t : U} → PLUS t (fromℕ m) ⟷ fromℕ (toℕ t + m)
assocrUS {m} {ZERO} = unite₊
assocrUS {m} {ONE}  = id⟷
assocrUS {m} {t}    = 
  PLUS t (fromℕ m)
    ⟷⟨ normalU t ⊕ id⟷ ⟩
  PLUS (normalℕ t) (fromℕ m)
    ⟷⟨ ! fromℕplus ⟩
  fromℕ (toℕ t + m) □

-- convert each combinator to a normal form

normal⟷ : {t₁ t₂ : U} → (c₁ : t₁ ⟷ t₂) → 
           Σ[ c₂ ∈ normalℕ t₁ ⟷ normalℕ t₂ ] (c₁ ⇔ (normalU t₁ ◎ c₂ ◎ (! (normalU t₂))))
normal⟷ {PLUS ZERO t} {.t} unite₊ = 
  (id⟷ , 
   (unite₊
      ⇔⟨ idr◎r ⟩
    unite₊ ◎ id⟷
      ⇔⟨ resp◎⇔ id⇔ linv◎r ⟩
    unite₊ ◎ (normalU t ◎ (! (normalU t)))
      ⇔⟨ assoc◎l ⟩
    (unite₊ ◎ normalU t) ◎ (! (normalU t))
      ⇔⟨ resp◎⇔ unitel₊⇔ id⇔ ⟩
    ((id⟷ ⊕ normalU t) ◎ unite₊) ◎ (! (normalU t))
      ⇔⟨ resp◎⇔ id⇔ idl◎r ⟩
    ((id⟷ ⊕ normalU t) ◎ unite₊) ◎ (id⟷ ◎ (! (normalU t)))
      ⇔⟨ id⇔ ⟩
    normalU (PLUS ZERO t) ◎ (id⟷ ◎ (! (normalU t))) ▤))
normal⟷ {t} {PLUS ZERO .t} uniti₊ = 
  (id⟷ , 
   (uniti₊ 
      ⇔⟨ idl◎r ⟩ 
    id⟷ ◎ uniti₊
      ⇔⟨ resp◎⇔ linv◎r id⇔ ⟩ 
    (normalU t ◎ (! (normalU t))) ◎ uniti₊
      ⇔⟨ assoc◎r ⟩ 
    normalU t ◎ ((! (normalU t)) ◎ uniti₊)
      ⇔⟨ resp◎⇔ id⇔ unitir₊⇔ ⟩ 
    normalU t ◎ (uniti₊ ◎ (id⟷ ⊕ (! (normalU t))))
      ⇔⟨ resp◎⇔ id⇔ idl◎r ⟩ 
    normalU t ◎ (id⟷ ◎ (uniti₊ ◎ (id⟷ ⊕ (! (normalU t)))))
      ⇔⟨ id⇔ ⟩ 
    normalU t ◎ (id⟷ ◎ (! ((id⟷ ⊕ (normalU t)) ◎ unite₊)))
      ⇔⟨ id⇔ ⟩ 
    normalU t ◎ (id⟷ ◎ (! (normalU (PLUS ZERO t)))) ▤))
normal⟷ {PLUS ZERO t₂} {PLUS .t₂ ZERO} swap₊ = 
  (normalℕswap {ZERO} {t₂} , 
  (swap₊ 
     ⇔⟨ {!!} ⟩
   (unite₊ ◎ normalU t₂) ◎ 
     (normalℕswap {ZERO} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ id⟷)))
     ⇔⟨ resp◎⇔ unitel₊⇔ id⇔ ⟩
   ((id⟷ ⊕ normalU t₂) ◎ unite₊) ◎ 
     (normalℕswap {ZERO} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ id⟷)))
     ⇔⟨ id⇔ ⟩
   normalU (PLUS ZERO t₂) ◎ (normalℕswap {ZERO} {t₂} ◎ (! (normalU (PLUS t₂ ZERO)))) ▤))
normal⟷ {PLUS ONE t₂} {PLUS .t₂ ONE} swap₊ = 
  (normalℕswap {ONE} {t₂} , 
  (swap₊ 
     ⇔⟨ {!!} ⟩
   ((normalU ONE ⊕ normalU t₂) ◎ assocrU (toℕ ONE)) ◎ 
     (normalℕswap {ONE} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ ! (normalU ONE))))
     ⇔⟨ id⇔ ⟩
   normalU (PLUS ONE t₂) ◎ (normalℕswap {ONE} {t₂} ◎ (! (normalU (PLUS t₂ ONE)))) ▤))
normal⟷ {PLUS t₁ t₂} {PLUS .t₂ .t₁} swap₊ = 
  (normalℕswap {t₁} {t₂} , 
  (swap₊ 
     ⇔⟨ {!!} ⟩
   ((normalU t₁ ⊕ normalU t₂) ◎ assocrU (toℕ t₁)) ◎ 
     (normalℕswap {t₁} {t₂} ◎ ((! (assocrU (toℕ t₂))) ◎ (! (normalU t₂) ⊕ ! (normalU t₁))))
     ⇔⟨ id⇔ ⟩
   normalU (PLUS t₁ t₂) ◎ (normalℕswap {t₁} {t₂} ◎ (! (normalU (PLUS t₂ t₁)))) ▤))
normal⟷ {PLUS t₁ (PLUS t₂ t₃)} {PLUS (PLUS .t₁ .t₂) .t₃} assocl₊ = {!!}
normal⟷ {PLUS (PLUS t₁ t₂) t₃} {PLUS .t₁ (PLUS .t₂ .t₃)} assocr₊ = {!!}
normal⟷ {TIMES ONE t} {.t} unite⋆ = {!!} 
normal⟷ {t} {TIMES ONE .t} uniti⋆ = {!!}
normal⟷ {TIMES t₁ t₂} {TIMES .t₂ .t₁} swap⋆ = {!!}
normal⟷ {TIMES t₁ (TIMES t₂ t₃)} {TIMES (TIMES .t₁ .t₂) .t₃} assocl⋆ = {!!}
normal⟷ {TIMES (TIMES t₁ t₂) t₃} {TIMES .t₁ (TIMES .t₂ .t₃)} assocr⋆ = {!!}
normal⟷ {TIMES ZERO t} {ZERO} distz = {!!}
normal⟷ {ZERO} {TIMES ZERO t} factorz = {!!}
normal⟷ {TIMES (PLUS t₁ t₂) t₃} {PLUS (TIMES .t₁ .t₃) (TIMES .t₂ .t₃)} dist = {!!}
normal⟷ {PLUS (TIMES .t₁ .t₃) (TIMES .t₂ .t₃)} {TIMES (PLUS t₁ t₂) t₃} factor = {!!}
normal⟷ {t} {.t} id⟷ = 
  (id⟷ , 
   (id⟷ 
     ⇔⟨ linv◎r ⟩
   normalU t ◎ (! (normalU t))
     ⇔⟨ resp◎⇔ id⇔ idl◎r ⟩
   normalU t ◎ (id⟷ ◎ (! (normalU t))) ▤))
normal⟷ {t₁} {t₃} (_◎_ {t₂ = t₂} c₁ c₂) = {!!}
normal⟷ {PLUS t₁ t₂} {PLUS t₃ t₄} (c₁ ⊕ c₂) = {!!}
normal⟷ {TIMES t₁ t₂} {TIMES t₃ t₄} (c₁ ⊗ c₂) = {!!}

-- if c₁ c₂ : t₁ ⟷ t₂ and c₁ ∼ c₂ then we want a canonical combinator
-- normalℕ t₁ ⟷ normalℕ t₂. If we have that then we should be able to
-- decide whether c₁ ∼ c₂ by normalizing and looking at the canonical
-- combinator.

-- Use ⇔ to normalize a path

{-# NO_TERMINATION_CHECK #-}
normalize : {t₁ t₂ : U} → (c₁ : t₁ ⟷ t₂) → Σ[ c₂ ∈ t₁ ⟷ t₂ ] (c₁ ⇔ c₂)
normalize unite₊     = (unite₊  , id⇔)
normalize uniti₊     = (uniti₊  , id⇔)
normalize swap₊      = (swap₊   , id⇔)
normalize assocl₊    = (assocl₊ , id⇔)
normalize assocr₊    = (assocr₊ , id⇔)
normalize unite⋆     = (unite⋆  , id⇔)
normalize uniti⋆     = (uniti⋆  , id⇔)
normalize swap⋆      = (swap⋆   , id⇔)
normalize assocl⋆    = (assocl⋆ , id⇔)
normalize assocr⋆    = (assocr⋆ , id⇔)
normalize distz      = (distz   , id⇔)
normalize factorz    = (factorz , id⇔)
normalize dist       = (dist    , id⇔)
normalize factor     = (factor  , id⇔)
normalize id⟷        = (id⟷   , id⇔)
normalize (c₁ ◎ c₂)  with normalize c₁ | normalize c₂
... | (c₁' , α) | (c₂' , β) = {!!} 
normalize (c₁ ⊕ c₂)  with normalize c₁ | normalize c₂
... | (c₁' , α) | (c₂₁ ⊕ c₂₂ , β) = 
  (assocl₊ ◎ ((c₁' ⊕ c₂₁) ⊕ c₂₂) ◎ assocr₊ , trans⇔ (resp⊕⇔ α β) assoc⊕l)
... | (c₁' , α) | (c₂' , β)       = (c₁' ⊕ c₂' , resp⊕⇔ α β)
normalize (c₁ ⊗ c₂)  with normalize c₁ | normalize c₂
... | (c₁₁ ⊕ c₁₂ , α) | (c₂' , β) = 
  (dist ◎ ((c₁₁ ⊗ c₂') ⊕ (c₁₂ ⊗ c₂')) ◎ factor , 
   trans⇔ (resp⊗⇔ α β) dist⇔)
... | (c₁' , α) | (c₂₁ ⊗ c₂₂ , β) = 
  (assocl⋆ ◎ ((c₁' ⊗ c₂₁) ⊗ c₂₂) ◎ assocr⋆ , trans⇔ (resp⊗⇔ α β) assoc⊗l)
... | (c₁' , α) | (c₂' , β) = (c₁' ⊗ c₂' , resp⊗⇔ α β)



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

p◎id∼p : ∀ {t₁ t₂} {c : t₁ ⟷ t₂} → (c ◎ id⟷ ∼ c)
p◎id∼p {t₁} {t₂} {c} v = 
  (begin (proj₁ (perm2path (c ◎ id⟷) v))
           ≡⟨ {!!} ⟩
         (proj₁ (perm2path id⟷ (proj₁ (perm2path c v))))
           ≡⟨ {!!} ⟩
         (proj₁ (perm2path c v)) ∎)

-- perm2path {t} id⟷ v = (v , edge •[ t , v ] •[ t , v ])

--perm2path (_◎_ {t₁} {t₂} {t₃} c₁ c₂) v₁ with perm2path c₁ v₁
--... | (v₂ , p) with perm2path c₂ v₂
--... | (v₃ , q) = (v₃ , seq p q) 


-- Equivalences between paths leading to 2path structure
-- Two paths are the same if they go through the same points

_∼_ : ∀ {t₁ t₂ v₁ v₂} → 
      (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂  ]) → 
      (q : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → 
      Set
(edge ._ ._) ∼ (edge ._ ._) = ⊤ 
(edge ._ ._) ∼ (seq p q) = {!!}
(edge ._ ._) ∼ (left p) = {!!}
(edge ._ ._) ∼ (right p) = {!!}
(edge ._ ._) ∼ (par p q) = {!!}
seq p p₁ ∼ edge ._ ._ = {!!}
seq p₁ p ∼ seq q q₁ = {!!}
seq p p₁ ∼ left q = {!!}
seq p p₁ ∼ right q = {!!}
seq p p₁ ∼ par q q₁ = {!!}
left p ∼ edge ._ ._ = {!!}
left p ∼ seq q q₁ = {!!}
left p ∼ left q = {!!}
right p ∼ edge ._ ._ = {!!}
right p ∼ seq q q₁ = {!!}
right p ∼ right q = {!!}
par p p₁ ∼ edge ._ ._ = {!!}
par p p₁ ∼ seq q q₁ = {!!}
par p p₁ ∼ par q q₁ = {!!} 

-- Equivalences between paths leading to 2path structure
-- Following the HoTT approach two paths are considered the same if they
-- map the same points to equal points

infix  4  _∼_  

_∼_ : ∀ {t₁ t₂ v₁ v₂ v₂'} → 
      (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂  ]) → 
      (q : Path •[ t₁ , v₁ ] •[ t₂ , v₂' ]) → 
      Set
_∼_ {t₁} {t₂} {v₁} {v₂} {v₂'} p q = (v₂ ≡ v₂')


-- Lemma 2.4.2

p∼p : {t₁ t₂ : U} {p : Path t₁ t₂} → p ∼ p
p∼p {p = path c} _ = refl

p∼q→q∼p : {t₁ t₂ : U} {p q : Path t₁ t₂} → (p ∼ q) → (q ∼ p)
p∼q→q∼p {p = path c₁} {q = path c₂} α v = sym (α v) 

p∼q∼r→p∼r : {t₁ t₂ : U} {p q r : Path t₁ t₂} → 
                 (p ∼ q) → (q ∼ r) → (p ∼ r) 
p∼q∼r→p∼r {p = path c₁} {q = path c₂} {r = path c₃} α β v = trans (α v) (β v) 

-- lift inverses and compositions to paths

inv : {t₁ t₂ : U} → Path t₁ t₂ → Path t₂ t₁
inv (path c) = path (! c)

infixr 10 _●_

_●_ : {t₁ t₂ t₃ : U} → Path t₁ t₂ → Path t₂ t₃ → Path t₁ t₃
path c₁ ● path c₂ = path (c₁ ◎ c₂)

-- Lemma 2.1.4

p∼p◎id : {t₁ t₂ : U} {p : Path t₁ t₂} → p ∼ p ● path id⟷
p∼p◎id {t₁} {t₂} {path c} v = 
  (begin (perm2path c v)
           ≡⟨ refl ⟩
         (perm2path c (perm2path id⟷ v))
           ≡⟨ refl ⟩
         (perm2path (c ◎ id⟷) v) ∎)

p∼id◎p : {t₁ t₂ : U} {p : Path t₁ t₂} → p ∼ path id⟷ ● p
p∼id◎p {t₁} {t₂} {path c} v = 
  (begin (perm2path c v)
           ≡⟨ refl ⟩
         (perm2path id⟷ (perm2path c v))
           ≡⟨ refl ⟩
         (perm2path (id⟷ ◎ c) v) ∎)

!p◎p∼id : {t₁ t₂ : U} {p : Path t₁ t₂} → (inv p) ● p ∼ path id⟷
!p◎p∼id {t₁} {t₂} {path c} v = 
  (begin (perm2path ((! c) ◎ c) v)
           ≡⟨ refl ⟩
         (perm2path c (perm2path (! c) v))
           ≡⟨ invr {t₁} {t₂} {c} {v} ⟩
         (perm2path id⟷ v) ∎)

p◎!p∼id : {t₁ t₂ : U} {p : Path t₁ t₂} → p ● (inv p) ∼ path id⟷
p◎!p∼id {t₁} {t₂} {path c} v = 
  (begin (perm2path (c ◎ (! c)) v)
           ≡⟨ refl ⟩
         (perm2path (! c) (perm2path c v))
           ≡⟨ invl {t₁} {t₂} {c} {v} ⟩
         (perm2path id⟷ v) ∎)


!!p∼p : {t₁ t₂ : U} {p : Path t₁ t₂} → inv (inv p) ∼ p
!!p∼p {t₁} {t₂} {path c} v = 
  begin (perm2path (! (! c)) v
           ≡⟨ cong (λ x → perm2path x v) (!! {c = c}) ⟩ 
         perm2path c v ∎)

assoc◎ : {t₁ t₂ t₃ t₄ : U} {p : Path t₁ t₂} {q : Path t₂ t₃} {r : Path t₃ t₄} → 
         p ● (q ● r) ∼ (p ● q) ● r
assoc◎ {t₁} {t₂} {t₃} {t₄} {path c₁} {path c₂} {path c₃} v = 
  begin (perm2path (c₁ ◎ (c₂ ◎ c₃)) v 
           ≡⟨ refl ⟩
         perm2path (c₂ ◎ c₃) (perm2path c₁ v)
           ≡⟨ refl ⟩
         perm2path c₃ (perm2path c₂ (perm2path c₁ v))
           ≡⟨ refl ⟩
         perm2path c₃ (perm2path (c₁ ◎ c₂) v)
           ≡⟨ refl ⟩
         perm2path ((c₁ ◎ c₂) ◎ c₃) v ∎)

resp◎ : {t₁ t₂ t₃ : U} {p q : Path t₁ t₂} {r s : Path t₂ t₃} → 
        p ∼ q → r ∼ s → (p ● r) ∼ (q ● s)
resp◎ {t₁} {t₂} {t₃} {path c₁} {path c₂} {path c₃} {path c₄} α β v = 
  begin (perm2path (c₁ ◎ c₃) v 
           ≡⟨ refl ⟩
         perm2path c₃ (perm2path c₁ v)
           ≡⟨ cong (λ x → perm2path c₃ x) (α  v) ⟩
         perm2path c₃ (perm2path c₂ v)
           ≡⟨ β (perm2path c₂ v) ⟩ 
         perm2path c₄ (perm2path c₂ v)
           ≡⟨ refl ⟩ 
         perm2path (c₂ ◎ c₄) v ∎)

-- Recall that two perminators are the same if they denote the same
-- permutation; in that case there is a 2path between them in the relevant
-- path space

data _⇔_ {t₁ t₂ : U} : Path t₁ t₂ → Path t₁ t₂ → Set where
  2path : {p q : Path t₁ t₂} → (p ∼ q) → (p ⇔ q)

-- Examples

p q r : Path BOOL BOOL
p = path id⟷
q = path swap₊
r = path (swap₊ ◎ id⟷)

α : q ⇔ r
α = 2path (p∼p◎id {p = path swap₊})

-- The equivalence of paths makes U a 1groupoid: the points are types t : U;
-- the 1paths are ⟷; and the 2paths between them are ⇔

G : 1Groupoid
G = record
        { set = U
        ; _↝_ = Path
        ; _≈_ = _⇔_ 
        ; id  = path id⟷
        ; _∘_ = λ q p → p ● q
        ; _⁻¹ = inv
        ; lneutr = λ p → 2path (p∼q→q∼p p∼p◎id) 
        ; rneutr = λ p → 2path (p∼q→q∼p p∼id◎p)
        ; assoc  = λ r q p → 2path assoc◎
        ; equiv = record { 
            refl  = 2path p∼p
          ; sym   = λ { (2path α) → 2path (p∼q→q∼p α) }
          ; trans = λ { (2path α) (2path β) → 2path (p∼q∼r→p∼r α β) }
          }
        ; linv = λ p → 2path p◎!p∼id
        ; rinv = λ p → 2path !p◎p∼id
        ; ∘-resp-≈ = λ { (2path β) (2path α) → 2path (resp◎ α β) }
        }

------------------------------------------------------------------------------

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

-- two perminators are the same if they denote the same permutation


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

infix  4  _≃_  

_≃_ : (t₁ t₂ : U) → Set
t₁ ≃ t₂ = (t₁ ⟷ t₂)

-- Univalence says (t₁ ≃ t₂) ≃ (t₁ ⟷ t₂) but as shown above, we actually have
-- this by definition instead of up to ≃

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

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

module Phase₁ where

  -- no occurrences of (TIMES (TIMES t₁ t₂) t₃)

approach that maintains the invariants in proofs

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
  TIMES ONE (TIMES ONE (TIMES ONE (TIMES ONE ONE))) ,
  (((id⟷ ⊗ id⟷) ⊗ (id⟷ ⊗ id⟷)) ⊗ id⟷ ◎ assocr⋆) ◎
  ((id⟷ ⊗ id⟷) ⊗ ((id⟷ ⊗ id⟷) ⊗ id⟷ ◎ assocr⋆) ◎ assocr⋆) ◎ id⟷

  -- Now any perminator (t₁ ⟷ t₂) can be transformed to a canonical
  -- representation in which we first associate all the TIMES to the right
  -- and then do the rest of the perminator

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


should this be on the code as done now or on their interpreation
i.e. data _⟷_ : ⟦ U ⟧ → ⟦ U ⟧ → Set where

can add recursive types 
rec : U
⟦_⟧ takes an additional argument X that is passed around
⟦ rec ⟧ X = X
fixpoitn
data μ (t : U) : Set where
 ⟨_⟩ : ⟦ t ⟧ (μ t) → μ t

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

elems : (t : U) → List ⟦ t ⟧
elems ZERO = []
elems ONE = [ tt ] 
elems (PLUS t₁ t₂) = map inj₁ (elems t₁) ++ map inj₂ (elems t₂)
elems (TIMES t₁ t₂) = concat 
                        (map 
                          (λ v₂ → map (λ v₁ → (v₁ , v₂)) (elems t₁))
                         (elems t₂))

_≟_ : {t : U} → ⟦ t ⟧ → ⟦ t ⟧ → Bool
_≟_ {ZERO} ()
_≟_ {ONE} tt tt = true
_≟_ {PLUS t₁ t₂} (inj₁ v) (inj₁ w) = v ≟ w
_≟_ {PLUS t₁ t₂} (inj₁ v) (inj₂ w) = false
_≟_ {PLUS t₁ t₂} (inj₂ v) (inj₁ w) = false
_≟_ {PLUS t₁ t₂} (inj₂ v) (inj₂ w) = v ≟ w
_≟_ {TIMES t₁ t₂} (v₁ , w₁) (v₂ , w₂) = v₁ ≟ v₂ ∧ w₁ ≟ w₂

  findLoops : {t t₁ t₂ : U} → (PLUS t t₁ ⟷ PLUS t t₂) → List ⟦ t ⟧ → 
               List (Σ[ t ∈ U ] ⟦ t ⟧)
  findLoops c [] = []
  findLoops {t} c (v ∷ vs) = ? with perm2path c (inj₁ v)
  ... | (inj₂ _ , loops) = loops ++ findLoops c vs
  ... | (inj₁ v' , loops) with v ≟ v' 
  ... | true = (t , v) ∷ loops ++ findLoops c vs
  ... | false = loops ++ findLoops c vs

traceLoopsEx : {t : U} → List (Σ[ t ∈ U ] ⟦ t ⟧)
traceLoopsEx {t} = findLoops traceBodyEx (elems (PLUS t (PLUS t t)))
-- traceLoopsEx {ONE} ==> (PLUS ONE (PLUS ONE ONE) , inj₂ (inj₁ tt)) ∷ []

-- Each permutation is a "path" between types. We can think of this path as
-- being indexed by "time" where "time" here is in discrete units
-- corresponding to the sequencing of combinators. A homotopy between paths p
-- and q is a map that, for each "time unit", maps the specified type along p
-- to a corresponding type along q. At each such time unit, the mapping
-- between types is itself a path. So a homotopy is essentially a collection
-- of paths. As an example, given two paths starting at t₁ and ending at t₂
-- and going through different intermediate points:
--   p = t₁ -> t -> t' -> t₂
--   q = t₁ -> u -> u' -> t₂
-- A possible homotopy between these two paths is a path from t to u and 
-- another path from t' to u'. Things get slightly more complicated if the
-- number of intermediate points is not the same etc. but that's the basic idea.
-- The vertical paths must commute with the horizontal ones.
-- 
-- Postulate the groupoid laws and use them to prove commutativity etc.
-- 
-- Bool -id-- Bool -id-- Bool -id-- Bool
--   |          |          |          |
--   |         not        id          | the last square does not commute
--   |          |          |          |
-- Bool -not- Bool -not- Bool -not- Bool
--
-- If the large rectangle commutes then the smaller squares commute. For a
-- proof, let p o q o r o s be the left-bottom path and p' o q' o r' o s' be
-- the top-right path. Let's focus on the square:
--  
--  A-- r'--C
--   |      |
--   ?      s'
--   |      |
--  B-- s --D
-- 
-- We have a path from A to B that is: !q' o !p' o p o q o r. 
-- Now let's see if r' o s' is equivalent to 
-- !q' o !p' o p o q o r o s
-- We know p o q o r o s ⇔ p' o q' o r' o s' 
-- If we know that ⇔ is preserved by composition then:
-- !q' o !p' o p o q o r o s ⇔ !q' o !p' o p' o q' o r' o s' 
-- and of course by inverses and id being unit of composition:
-- !q' o !p' o p o q o r o s ⇔ r' o s' 
-- and we are done.

{-# NO_TERMINATION_CHECK #-}
Path∼ : ∀ {t₁ t₂ t₁' t₂' v₁ v₂ v₁' v₂'} → 
        (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → 
        (q : Path •[ t₁' , v₁' ] •[ t₂' , v₂' ]) → 
        Set
-- sequential composition
Path∼ {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p₁ p₂) (_●_ {t₂ = t₂'} {v₂ = v₂'} q₁ q₂) = 
 (Path∼ p₁ q₁ × Path∼ p₂ q₂) ⊎
 (Path∼ {t₁} {t₂} {t₁'} {t₁'} {v₁} {v₂} {v₁'} {v₁'} p₁ id⟷• × Path∼ p₂ (q₁ ● q₂)) ⊎ 
 (Path∼ p₁ (q₁ ● q₂) × Path∼ {t₂} {t₃} {t₃'} {t₃'} {v₂} {v₃} {v₃'} {v₃'} p₂ id⟷•) ⊎  
 (Path∼ {t₁} {t₁} {t₁'} {t₂'} {v₁} {v₁} {v₁'} {v₂'} id⟷• q₁ × Path∼ (p₁ ● p₂) q₂) ⊎
 (Path∼ (p₁ ● p₂) q₁ × Path∼ {t₃} {t₃} {t₂'} {t₃'} {v₃} {v₃} {v₂'} {v₃'} id⟷• q₂)
Path∼ {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p q) c = 
    (Path∼ {t₁} {t₂} {t₁'} {t₁'} {v₁} {v₂} {v₁'} {v₁'} p id⟷• × Path∼ q c)
  ⊎ (Path∼ p c × Path∼ {t₂} {t₃} {t₃'} {t₃'} {v₂} {v₃} {v₃'} {v₃'} q id⟷•)
Path∼ {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  c (_●_ {t₂ = t₂'} {v₂ = v₂'} p q) = 
    (Path∼ {t₁} {t₁} {t₁'} {t₂'} {v₁} {v₁} {v₁'} {v₂'} id⟷• p × Path∼ c q)
  ⊎ (Path∼ c p × Path∼ {t₃} {t₃} {t₂'} {t₃'} {v₃} {v₃} {v₂'} {v₃'} id⟷• q)
-- choices
Path∼ (⊕1• p) (⊕1• q) = Path∼ p q
Path∼ (⊕1• p) _       = ⊥
Path∼ _       (⊕1• p) = ⊥
Path∼ (⊕2• p) (⊕2• q) = Path∼ p q
Path∼ (⊕2• p) _       = ⊥
Path∼ _       (⊕2• p) = ⊥
-- parallel paths
Path∼ (p₁ ⊗• p₂) (q₁ ⊗• q₂) = Path∼ p₁ q₁ × Path∼ p₂ q₂
Path∼ (p₁ ⊗• p₂) _          = ⊥
Path∼ _          (q₁ ⊗• q₂) = ⊥
-- simple edges connecting two points
Path∼ {t₁} {t₂} {t₁'} {t₂'} {v₁} {v₂} {v₁'} {v₂'} c₁ c₂ = 
  Path •[ t₁ , v₁ ] •[ t₁' , v₁' ] × Path •[ t₂ , v₂ ] •[ t₂' , v₂' ] 

-- In the setting of finite types (in particular with no loops) every pair of
-- paths with related start and end points is equivalent. In other words, we
-- really have no interesting 2-path structure.

allequiv : ∀ {t₁ t₂ t₁' t₂' v₁ v₂ v₁' v₂'} → 
       (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → 
       (q : Path •[ t₁' , v₁' ] •[ t₂' , v₂' ]) → 
       (start : Path •[ t₁ , v₁ ] •[ t₁' , v₁' ]) → 
       (end : Path •[ t₂ , v₂ ] •[ t₂' , v₂' ]) → 
       Path∼ p q
allequiv {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p₁ p₂) (_●_ {t₂ = t₂'} {v₂ = v₂'} q₁ q₂) 
  start end = {!!}
allequiv {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  (_●_ {t₂ = t₂} {v₂ = v₂} p q) c start end = {!!}
allequiv {t₁} {t₃} {t₁'} {t₃'} {v₁} {v₃} {v₁'} {v₃'} 
  c (_●_ {t₂ = t₂'} {v₂ = v₂'} p q) start end = {!!}
allequiv (⊕1• p) (⊕1• q) start end = {!!}
allequiv (⊕1• p) _       start end = {!!}
allequiv _       (⊕1• p) start end = {!!}
allequiv (⊕2• p) (⊕2• q) start end = {!!}
allequiv (⊕2• p) _       start end = {!!}
allequiv _       (⊕2• p) start end = {!!}
-- parallel paths
allequiv (p₁ ⊗• p₂) (q₁ ⊗• q₂) start end = {!!}
allequiv (p₁ ⊗• p₂) _          start end = {!!}
allequiv _          (q₁ ⊗• q₂) start end = {!!}
-- simple edges connecting two points
allequiv {t₁} {t₂} {t₁'} {t₂'} {v₁} {v₂} {v₁'} {v₂'} c₁ c₂ start end = {!!}





refl∼ : ∀ {t₁ t₂ v₁ v₂} → (p : Path •[ t₁ , v₁ ] •[ t₂ , v₂ ]) → Path∼ p p 
refl∼ unite•₊   = id⟷• , id⟷• 
refl∼ uniti•₊   = id⟷• , id⟷• 
refl∼ swap1•₊   = id⟷• , id⟷• 
refl∼ swap2•₊   = id⟷• , id⟷• 
refl∼ assocl1•₊ = id⟷• , id⟷• 
refl∼ assocl2•₊ = id⟷• , id⟷• 
refl∼ assocl3•₊ = id⟷• , id⟷• 
refl∼ assocr1•₊ = id⟷• , id⟷• 
refl∼ assocr2•₊ = id⟷• , id⟷• 
refl∼ assocr3•₊ = id⟷• , id⟷• 
refl∼ unite•⋆   = id⟷• , id⟷• 
refl∼ uniti•⋆   = id⟷• , id⟷• 
refl∼ swap•⋆    = id⟷• , id⟷• 
refl∼ assocl•⋆  = id⟷• , id⟷• 
refl∼ assocr•⋆  = id⟷• , id⟷• 
refl∼ distz•    = id⟷• , id⟷• 
refl∼ factorz•  = id⟷• , id⟷• 
refl∼ dist1•    = id⟷• , id⟷• 
refl∼ dist2•    = id⟷• , id⟷• 
refl∼ factor1•  = id⟷• , id⟷• 
refl∼ factor2•  = id⟷• , id⟷• 
refl∼ id⟷•      = id⟷• , id⟷• 
refl∼ (p ● q)   = inj₁ (refl∼ p , refl∼ q)
refl∼ (⊕1• p)   = refl∼ p
refl∼ (⊕2• q)   = refl∼ q
refl∼ (p ⊗• q)  = refl∼ p , refl∼ q 

-- Extensional view

-- First we enumerate all the values of a given finite type

size : U → ℕ
size ZERO          = 0
size ONE           = 1
size (PLUS t₁ t₂)  = size  t₁ + size t₂
size (TIMES t₁ t₂) = size t₁ * size  t₂

enum : (t : U) → ⟦ t ⟧ → Fin (size t)
enum ZERO ()                  -- absurd
enum ONE tt                   = zero
enum (PLUS t₁ t₂) (inj₁ v₁)   = inject+ (size t₂) (enum t₁ v₁)
enum (PLUS t₁ t₂) (inj₂ v₂)   = raise (size t₁) (enum t₂ v₂)
enum (TIMES t₁ t₂) (v₁ , v₂)  = fromℕ≤ (pr {s₁} {s₂} {n₁} {n₂})
  where n₁ = enum t₁ v₁
        n₂ = enum t₂ v₂
        s₁ = size t₁ 
        s₂ = size t₂
        pr : {s₁ s₂ : ℕ} → {n₁ : Fin s₁} {n₂ : Fin s₂} → 
             ((toℕ n₁ * s₂) + toℕ n₂) < (s₁ * s₂)
        pr {0} {_} {()} 
        pr {_} {0} {_} {()}
        pr {suc s₁} {suc s₂} {zero} {zero} = {!z≤n!}
        pr {suc s₁} {suc s₂} {zero} {Fsuc n₂} = {!!}
        pr {suc s₁} {suc s₂} {Fsuc n₁} {zero} = {!!}
        pr {suc s₁} {suc s₂} {Fsuc n₁} {Fsuc n₂} = {!!}

vals3 : Fin 3 × Fin 3 × Fin 3
vals3 = (enum THREE LL , enum THREE LR , enum THREE R)
  where THREE = PLUS (PLUS ONE ONE) ONE
        LL = inj₁ (inj₁ tt)
        LR = inj₁ (inj₂ tt)
        R  = inj₂ tt

xxx : {s₁ s₂ : ℕ} → (i : Fin s₁) → (j : Fin s₂) → 
      suc (toℕ i * s₂ + toℕ j) ≤ s₁ * s₂
xxx {0} {_} ()
xxx {suc s₁} {s₂} i j = {!!} 

-- i  : Fin (suc s₁)
-- j  : Fin s₂
-- ?0 : suc (toℕ i * s₂ + toℕ j)  ≤ suc s₁ * s₂
--      (suc (toℕ i) * s₂ + toℕ j ≤ s₂ + s₁ * s₂
--      (suc (toℕ i) * s₂ + toℕ j ≤ s₁ * s₂ + s₂



utoVecℕ : (t : U) → Vec (Fin (utoℕ t)) (utoℕ t)
utoVecℕ ZERO          = []
utoVecℕ ONE           = [ zero ]
utoVecℕ (PLUS t₁ t₂)  = 
  map (inject+ (utoℕ t₂)) (utoVecℕ t₁) ++ 
  map (raise (utoℕ t₁)) (utoVecℕ t₂)
utoVecℕ (TIMES t₁ t₂) = 
  concat (map (λ i → map (λ j → inject≤ (fromℕ (toℕ i * utoℕ t₂ + toℕ j)) 
                                (xxx i j))
                     (utoVecℕ t₂))
         (utoVecℕ t₁))

-- Vector representation of types so that we can test permutations

utoVec : (t : U) → Vec ⟦ t ⟧ (utoℕ t)
utoVec ZERO          = []
utoVec ONE           = [ tt ]
utoVec (PLUS t₁ t₂)  = map inj₁ (utoVec t₁) ++ map inj₂ (utoVec t₂)
utoVec (TIMES t₁ t₂) = 
  concat (map (λ v₁ → map (λ v₂ → (v₁ , v₂)) (utoVec t₂)) (utoVec t₁))

-- Examples permutations and their actions on a simple ordered vector

module PermExamples where

  -- ordered vector: position i has value i
  ordered : ∀ {n} → Vec (Fin n) n
  ordered = tabulate id

  -- empty permutation p₀ { }

  p₀ : Perm 0
  p₀ = []

  v₀ = permute p₀ ordered

  -- permutation p₁ { 0 -> 0 }

  p₁ : Perm 1
  p₁ = 0F ∷ p₀
    where 0F = fromℕ 0

  v₁ = permute p₁ ordered

  -- permutations p₂ { 0 -> 0, 1 -> 1 }
  --              q₂ { 0 -> 1, 1 -> 0 }

  p₂ q₂ : Perm 2
  p₂ = 0F ∷ p₁ 
    where 0F = inject+ 1 (fromℕ 0)
  q₂ = 1F ∷ p₁
    where 1F = fromℕ 1

  v₂ = permute p₂ ordered
  w₂ = permute q₂ ordered

  -- permutations p₃ { 0 -> 0, 1 -> 1, 2 -> 2 }
  --              s₃ { 0 -> 0, 1 -> 2, 2 -> 1 }
  --              q₃ { 0 -> 1, 1 -> 0, 2 -> 2 }
  --              r₃ { 0 -> 1, 1 -> 2, 2 -> 0 }
  --              t₃ { 0 -> 2, 1 -> 0, 2 -> 1 }
  --              u₃ { 0 -> 2, 1 -> 1, 2 -> 0 }

  p₃ q₃ r₃ s₃ t₃ u₃ : Perm 3
  p₃ = 0F ∷ p₂
    where 0F = inject+ 2 (fromℕ 0)
  s₃ = 0F ∷ q₂
    where 0F = inject+ 2 (fromℕ 0)
  q₃ = 1F ∷ p₂
    where 1F = inject+ 1 (fromℕ 1)
  r₃ = 2F ∷ p₂
    where 2F = fromℕ 2
  t₃ = 1F ∷ q₂
    where 1F = inject+ 1 (fromℕ 1)
  u₃ = 2F ∷ q₂
    where 2F = fromℕ 2

  v₃ = permute p₃ ordered
  y₃ = permute s₃ ordered
  w₃ = permute q₃ ordered
  x₃ = permute r₃ ordered
  z₃ = permute t₃ ordered
  α₃ = permute u₃ ordered

  -- end module PermExamples

------------------------------------------------------------------------------
-- Testing

t₁  = PLUS ZERO BOOL
t₂  = BOOL
m₁ = matchP {t₁} {t₂} unite₊
-- (inj₂ (inj₁ tt) , inj₁ tt) ∷ (inj₂ (inj₂ tt) , inj₂ tt) ∷ []
m₂ = matchP {t₂} {t₁} uniti₊
-- (inj₁ tt , inj₂ (inj₁ tt)) ∷ (inj₂ tt , inj₂ (inj₂ tt)) ∷ []

t₃ = PLUS BOOL ONE
t₄ = PLUS ONE BOOL
m₃ = matchP {t₃} {t₄} swap₊
-- (inj₂ tt , inj₁ tt) ∷
-- (inj₁ (inj₁ tt) , inj₂ (inj₁ tt)) ∷
-- (inj₁ (inj₂ tt) , inj₂ (inj₂ tt)) ∷ []
m₄ = matchP {t₄} {t₃} swap₊
-- (inj₂ (inj₁ tt) , inj₁ (inj₁ tt)) ∷
-- (inj₂ (inj₂ tt) , inj₁ (inj₂ tt)) ∷ 
-- (inj₁ tt , inj₂ tt) ∷ []

t₅  = PLUS ONE (PLUS BOOL ONE)
t₆  = PLUS (PLUS ONE BOOL) ONE
m₅ = matchP {t₅} {t₆} assocl₊
-- (inj₁ tt , inj₁ (inj₁ tt)) ∷
-- (inj₂ (inj₁ (inj₁ tt)) , inj₁ (inj₂ (inj₁ tt))) ∷
-- (inj₂ (inj₁ (inj₂ tt)) , inj₁ (inj₂ (inj₂ tt))) ∷
-- (inj₂ (inj₂ tt) , inj₂ tt) ∷ []
m₆ = matchP {t₆} {t₅} assocr₊
-- (inj₁ (inj₁ tt) , inj₁ tt) ∷
-- (inj₁ (inj₂ (inj₁ tt)) , inj₂ (inj₁ (inj₁ tt))) ∷
-- (inj₁ (inj₂ (inj₂ tt)) , inj₂ (inj₁ (inj₂ tt))) ∷
-- (inj₂ tt , inj₂ (inj₂ tt)) ∷ []

t₇ = TIMES ONE BOOL
t₈ = BOOL
m₇ = matchP {t₇} {t₈} unite⋆
-- ((tt , inj₁ tt) , inj₁ tt) ∷ ((tt , inj₂ tt) , inj₂ tt) ∷ []
m₈ = matchP {t₈} {t₇} uniti⋆
-- (inj₁ tt , (tt , inj₁ tt)) ∷ (inj₂ tt , (tt , inj₂ tt)) ∷ []

t₉  = TIMES BOOL ONE
t₁₀ = TIMES ONE BOOL
m₉  = matchP {t₉} {t₁₀} swap⋆
-- ((inj₁ tt , tt) , (tt , inj₁ tt)) ∷
-- ((inj₂ tt , tt) , (tt , inj₂ tt)) ∷ []
m₁₀ = matchP {t₁₀} {t₉} swap⋆
-- ((tt , inj₁ tt) , (inj₁ tt , tt)) ∷
-- ((tt , inj₂ tt) , (inj₂ tt , tt)) ∷ []

t₁₁ = TIMES BOOL (TIMES ONE BOOL)
t₁₂ = TIMES (TIMES BOOL ONE) BOOL
m₁₁ = matchP {t₁₁} {t₁₂} assocl⋆
-- ((inj₁ tt , (tt , inj₁ tt)) , ((inj₁ tt , tt) , inj₁ tt)) ∷
-- ((inj₁ tt , (tt , inj₂ tt)) , ((inj₁ tt , tt) , inj₂ tt)) ∷
-- ((inj₂ tt , (tt , inj₁ tt)) , ((inj₂ tt , tt) , inj₁ tt)) ∷
-- ((inj₂ tt , (tt , inj₂ tt)) , ((inj₂ tt , tt) , inj₂ tt)) ∷ []
m₁₂ = matchP {t₁₂} {t₁₁} assocr⋆
-- (((inj₁ tt , tt) , inj₁ tt) , (inj₁ tt , (tt , inj₁ tt)) ∷
-- (((inj₁ tt , tt) , inj₂ tt) , (inj₁ tt , (tt , inj₂ tt)) ∷
-- (((inj₂ tt , tt) , inj₁ tt) , (inj₂ tt , (tt , inj₁ tt)) ∷
-- (((inj₂ tt , tt) , inj₂ tt) , (inj₂ tt , (tt , inj₂ tt)) ∷ []

t₁₃ = TIMES ZERO BOOL
t₁₄ = ZERO
m₁₃ = matchP {t₁₃} {t₁₄} distz
-- []
m₁₄ = matchP {t₁₄} {t₁₃} factorz
-- []

t₁₅ = TIMES (PLUS BOOL ONE) BOOL
t₁₆ = PLUS (TIMES BOOL BOOL) (TIMES ONE BOOL)
m₁₅ = matchP {t₁₅} {t₁₆} dist
-- ((inj₁ (inj₁ tt) , inj₁ tt) , inj₁ (inj₁ tt , inj₁ tt)) ∷
-- ((inj₁ (inj₁ tt) , inj₂ tt) , inj₁ (inj₁ tt , inj₂ tt)) ∷
-- ((inj₁ (inj₂ tt) , inj₁ tt) , inj₁ (inj₂ tt , inj₁ tt)) ∷
-- ((inj₁ (inj₂ tt) , inj₂ tt) , inj₁ (inj₂ tt , inj₂ tt)) ∷
-- ((inj₂ tt , inj₁ tt) , inj₂ (tt , inj₁ tt)) ∷
-- ((inj₂ tt , inj₂ tt) , inj₂ (tt , inj₂ tt)) ∷ []
m₁₆ = matchP {t₁₆} {t₁₅} factor
-- (inj₁ (inj₁ tt , inj₁ tt) , (inj₁ (inj₁ tt) , inj₁ tt)) ∷
-- (inj₁ (inj₁ tt , inj₂ tt) , (inj₁ (inj₁ tt) , inj₂ tt)) ∷
-- (inj₁ (inj₂ tt , inj₁ tt) , (inj₁ (inj₂ tt) , inj₁ tt)) ∷
-- (inj₁ (inj₂ tt , inj₂ tt) , (inj₁ (inj₂ tt) , inj₂ tt)) ∷
-- (inj₂ (tt , inj₁ tt) , (inj₂ tt , inj₁ tt)) ∷
-- (inj₂ (tt , inj₂ tt) , (inj₂ tt , inj₂ tt)) ∷ []

t₁₇ = BOOL 
t₁₈ = BOOL
m₁₇ = matchP {t₁₇} {t₁₈} id⟷
-- (inj₁ tt , inj₁ tt) ∷ (inj₂ tt , inj₂ tt) ∷ []

--◎
--⊕
--⊗

------------------------------------------------------------------------------

mergeS :: SubPerm → SubPerm (suc m * n) (m * n) → SubPerm (suc m * suc n) (m * suc n) 
mergeS = ? 

subP : ∀ {m n} → Fin (suc m) → Perm n → SubPerm (suc m * n) (m * n)
subP {m} {0} i β = {!!}
subP {m} {suc n} i (j ∷ β) = mergeS ? (subP {m} {n} i β)


-- injectP (Perm n) (m * n) 
-- ...
-- SP (suc m * n) (m * n)
-- SP (n + m * n) (m * n)

--SP (suc m * n) (m * n) 
--
--
--==> 
--
--(suc m * suc n) (m * suc n)

--m : ℕ
--n : ℕ
--i : Fin (suc m)
--j : Fin (suc n)
--β : Perm n
--?1 : SubPerm (suc m * suc n) (m * suc n)


tcompperm : ∀ {m n} → Perm m → Perm n → Perm (m * n)
tcompperm []      β = []
tcompperm (i ∷ α) β = merge (subP i β) (tcompperm α β)

-- shift m=3 n=4 i=ax:F3 β=[ay:F4,by:F3,cy:F2,dy:F1] γ=[r4,...,r11]:P8
-- ==> [F12,F11,F10,F9...γ]

-- m = 3
-- n = 4
-- 3 * 4
-- x = [ ax, bx, cx ] : P 3, y : [ay, by, cy, dy] : P 4
-- (shift ax 4 y) || 
--     ( (shift bx 4 y) ||
--          ( (shift cx 4 y) ||
--               [])))
-- 
-- ax : F3, bx : F2, cx : F1
-- ay : F4, by : F3, cy : F2, dy : F1
--
-- suc m = 3, m = 2
--  F12 F11  F10 F9  F8  F7  F6  F5  F4  F3  F2   F1
-- [ r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11 ]
--   ---------------
--  ax : F3 with y=[F4,F3,F2,F1]
--                   --------------
--                       bx : F2
--                                  ------------------
--                                          cx : F1

  -- β should be something like i * n + entry in β

0 * n = 0
(suc m) * n = n + (m * n)

comb2perm (c₁ ⊗ c₂) = tcompperm (comb2perm c₁) (comb2perm c₂) 

c1 = swap+ (f->t,t->f)  [1,0]
c2 = id    (f->f,t->t)  [0,0]

c1xc2 (f,f)->(t,f), (f,t)->(t,t), (t,f)->(f,f), (t,t)->(f,t)
[

ff ft tf tt
 2   2  0  0

index in α * n + index in β

pex qex pqex qpex : Perm 3
pex = inject+ 1 (fromℕ 1) ∷ fromℕ 1 ∷ zero ∷ []
qex = zero ∷ fromℕ 1 ∷ zero ∷ []
pqex = fromℕ 2 ∷ fromℕ 1 ∷ zero ∷ []
qpex = inject+ 1 (fromℕ 1) ∷ zero ∷ zero ∷ []

pqexv  = (permute qex ∘ permute pex) (tabulate id)
pqexv' = permute pqex (tabulate id) 

qpexv  = (permute pex ∘ permute qex) (tabulate id)
qpexv' = permute qpex (tabulate id)

-- [1,1,0]
-- [z] => [z]
-- [y,z] => [z,y]
-- [x,y,z] => [z,x,y] 

-- [0,1,0]
-- [w] => [w]
-- [v,w] => [w,v]
-- [u,v,w] => [u,w,v]

-- R,R,_ ◌ _,R,_
-- R in p1 takes you to middle which also goes R, so first goes RR
-- [a,b,c] ◌ [d,e,f]
-- [a+p2[a], ...]

-- [1,1,0] ◌ [0,1,0] one step [2,1,0]
-- [z] => [z]
-- [y,z] => [z,y]
-- [x,y,z] => [z,y,x]

-- [1,1,0] ◌ [0,1,0]
-- [z] => [z] => [z]
-- [y,z] => 
-- [x,y,z] => 

-- so [1,1,0] ◌ [0,1,0] ==> [2,1,0]
-- so [0,1,0] ◌ [1,1,0] ==> [1,0,0]

-- pex takes [0,1,2] to [2,0,1]
-- qex takes [0,1,2] to [0,2,1]
-- pex ◌ qex takes [0,1,2] to [2,1,0]
-- qex ◌ pex takes [0,1,2] to [1,0,2]

-- seq : ∀ {m n} → (m ≤ n) → Perm m → Perm n → Perm m
-- seq lp [] _ = []
-- seq lp (i ∷ p) q = (lookupP i q) ∷ (seq lp p q)

-- i F+ ...

-- lookupP : ∀ {n} → Fin n → Perm n → Fin n
-- i   : Fin (suc m)
-- p   : Perm m
-- q   : Perm n


-- 
-- (zero ∷ p₁) ◌ (q ∷ q₁) = q ∷ (p₁ ◌ q₁)
-- (suc p ∷ p₁) ◌ (zero ∷ q₁) = {!!}
-- (suc p ∷ p₁) ◌ (suc q ∷ q₁) = {!!}
-- 
-- data Perm : ℕ → Set where
--   []  : Perm 0
--   _∷_ : {n : ℕ} → Fin (suc n) → Perm n → Perm (suc n)

-- Given a vector of (suc n) elements, return one of the elements and
-- the rest. Example: pick (inject+ 1 (fromℕ 1)) (10 ∷ 20 ∷ 30 ∷ 40 ∷ [])

pick : ∀ {ℓ} {n : ℕ} {A : Set ℓ} → Fin n → Vec A (suc n) → (A × Vec A n)
pick {ℓ} {0} {A} ()
pick {ℓ} {suc n} {A} zero (v ∷ vs) = (v , vs)
pick {ℓ} {suc n} {A} (suc i) (v ∷ vs) = 
  let (w , ws) = pick {ℓ} {n} {A} i vs 
  in (w , v ∷ ws)

insertV : ∀ {ℓ} {n : ℕ} {A : Set ℓ} → 
          A → Fin (suc n) → Vec A n → Vec A (suc n) 
insertV {n = 0} v zero [] = [ v ]
insertV {n = 0} v (suc ()) 
insertV {n = suc n} v zero vs = v ∷ vs
insertV {n = suc n} v (suc i) (w ∷ ws) = w ∷ insertV v i ws

-- A permutation takes two vectors of the same size, matches one
-- element from each and returns another permutation

data P {ℓ ℓ'} (A : Set ℓ) (B : Set ℓ') : 
  (m n : ℕ) → (m ≡ n) → Vec A m → Vec B n → Set (ℓ ⊔ ℓ') where
  nil : P A B 0 0 refl [] []
  cons : {m n : ℕ} {i : Fin (suc m)} {j : Fin (suc n)} → (p : m ≡ n) → 
         (v : A) → (w : B) → (vs : Vec A m) → (ws : Vec B n) →
         P A B m n p vs ws → 
         P A B (suc m) (suc n) (cong suc p) (insertV v i vs) (insertV w j ws)

-- A permutation is a sequence of "insertions".

infixr 5 _∷_

data Perm : ℕ → Set where
  []  : Perm 0
  _∷_ : {n : ℕ} → Fin (suc n) → Perm n → Perm (suc n)

lookupP : ∀ {n} → Fin n → Perm n → Fin n
lookupP () [] 
lookupP zero (j ∷ _) = j
lookupP {suc n} (suc i) (j ∷ q) = inject₁ (lookupP i q)

insert : ∀ {ℓ n} {A : Set ℓ} → Vec A n → Fin (suc n) → A → Vec A (suc n)
insert vs zero w          = w ∷ vs
insert [] (suc ())        -- absurd
insert (v ∷ vs) (suc i) w = v ∷ insert vs i w

-- A permutation acts on a vector by inserting each element in its new
-- position.

permute : ∀ {ℓ n} {A : Set ℓ} → Perm n → Vec A n → Vec A n
permute []       []       = []
permute (p ∷ ps) (v ∷ vs) = insert (permute ps vs) p v

-- Use a permutation to match up the elements in two vectors. See more
-- convenient function matchP below.

match : ∀ {t t'} → (size t ≡ size t') → Perm (size t) → 
        Vec ⟦ t ⟧ (size t) → Vec ⟦ t' ⟧ (size t) → 
        Vec (⟦ t ⟧ × ⟦ t' ⟧) (size t)
match {t} {t'} sp α vs vs' = 
  let js = permute α (tabulate id)
  in zip (tabulate (λ j → lookup (lookup j js) vs)) vs'

-- swap
-- 
-- swapperm produces the permutations that maps:
-- [ a , b || x , y , z ] 
-- to 
-- [ x , y , z || a , b ]
-- Ex. 
-- permute (swapperm {5} (inject+ 2 (fromℕ 2))) ordered=[0,1,2,3,4]
-- produces [2,3,4,0,1]
-- Explicitly:
-- swapex : Perm 5
-- swapex =   inject+ 1 (fromℕ 3) -- :: Fin 5
--          ∷ inject+ 0 (fromℕ 3) -- :: Fin 4
--          ∷ zero
--          ∷ zero
--          ∷ zero
--          ∷ []

swapperm : ∀ {n} → Fin n → Perm n
swapperm {0} ()          -- absurd
swapperm {suc n} zero    = idperm
swapperm {suc n} (suc i) = 
  subst Fin (-+-id n i) 
    (inject+ (toℕ i) (fromℕ (n ∸ toℕ i))) ∷ swapperm {n} i

-- compositions

-- Sequential composition

scompperm : ∀ {n} → Perm n → Perm n → Perm n
scompperm α β = {!!} 

-- Sub-permutations
-- useful for parallel and multiplicative compositions

-- Perm 4 has elements [Fin 4, Fin 3, Fin 2, Fin 1]
-- SubPerm 11 7 has elements [Fin 11, Fin 10, Fin 9, Fin 8]
-- So Perm 4 is a special case SubPerm 4 0

data SubPerm : ℕ → ℕ → Set where
  []s  : {n : ℕ} → SubPerm n n
  _∷s_ : {n m : ℕ} → Fin (suc n) → SubPerm n m → SubPerm (suc n) m

merge : ∀ {m n} → SubPerm m n → Perm n → Perm m
merge []s      β = β
merge (i ∷s α) β = i ∷ merge α β

injectP : ∀ {m} → Perm m → (n : ℕ) → SubPerm (m + n) n
injectP []      n = []s 
injectP (i ∷ α) n = inject+ n i ∷s injectP α n
  
-- Parallel + composition

pcompperm : ∀ {m n} → Perm m → Perm n → Perm (m + n)
pcompperm {m} {n} α β = merge (injectP α n) β

-- Multiplicative * composition

tcompperm : ∀ {m n} → Perm m → Perm n → Perm (m * n)
tcompperm []      β = []
tcompperm (i ∷ α) β = {!!} 

------------------------------------------------------------------------------
-- A combinator t₁ ⟷ t₂ denotes a permutation.

comb2perm : {t₁ t₂ : U} → (c : t₁ ⟷ t₂) → Perm (size t₁)
comb2perm {PLUS ZERO t} {.t} unite₊ = idperm
comb2perm {t} {PLUS ZERO .t} uniti₊ = idperm
comb2perm {PLUS t₁ t₂} {PLUS .t₂ .t₁} swap₊ with size t₂
... | 0     = idperm 
... | suc j = swapperm {size t₁ + suc j} 
               (inject≤ (fromℕ (size t₁)) (suc≤ (size t₁) j))
comb2perm {PLUS t₁ (PLUS t₂ t₃)} {PLUS (PLUS .t₁ .t₂) .t₃} assocl₊ = idperm
comb2perm {PLUS (PLUS t₁ t₂) t₃} {PLUS .t₁ (PLUS .t₂ .t₃)} assocr₊ = idperm
comb2perm {TIMES ONE t} {.t} unite⋆ = idperm
comb2perm {t} {TIMES ONE .t} uniti⋆ = idperm
comb2perm {TIMES t₁ t₂} {TIMES .t₂ .t₁} swap⋆ = idperm 
comb2perm assocl⋆   = idperm  
comb2perm assocr⋆   = idperm  
comb2perm distz     = idperm  
comb2perm factorz   = idperm  
comb2perm dist      = idperm  
comb2perm factor    = idperm  
comb2perm id⟷      = idperm  
comb2perm (c₁ ◎ c₂) = scompperm 
                        (comb2perm c₁) 
                        (subst Perm (sym (size≡ c₁)) (comb2perm c₂))
comb2perm (c₁ ⊕ c₂) = pcompperm (comb2perm c₁) (comb2perm c₂) 
comb2perm (c₁ ⊗ c₂) = tcompperm (comb2perm c₁) (comb2perm c₂) 

-- Convenient way of "seeing" what the permutation does for each combinator

matchP : ∀ {t t'} → (t ⟷ t') → Vec (⟦ t ⟧ × ⟦ t' ⟧) (size t)
matchP {t} {t'} c = 
  match sp (comb2perm c) (utoVec t) 
    (subst (λ n → Vec ⟦ t' ⟧ n) (sym sp) (utoVec t'))
  where sp = size≡ c

------------------------------------------------------------------------------
-- Extensional equivalence of combinators: two combinators are
-- equivalent if they denote the same permutation. Generally we would
-- require that the two permutations map the same value x to values y
-- and z that have a path between them, but because the internals of each
-- type are discrete groupoids, this reduces to saying that y and z
-- are identical, and hence that the permutations are identical.

infix  10  _∼_  

_∼_ : ∀ {t₁ t₂} → (c₁ c₂ : t₁ ⟷ t₂) → Set
c₁ ∼ c₂ = (comb2perm c₁ ≡ comb2perm c₂)

-- The relation ~ is an equivalence relation

refl∼ : ∀ {t₁ t₂} {c : t₁ ⟷ t₂} → (c ∼ c)
refl∼ = refl 

sym∼ : ∀ {t₁ t₂} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₂ ∼ c₁)
sym∼ = sym

trans∼ : ∀ {t₁ t₂} {c₁ c₂ c₃ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₂ ∼ c₃) → (c₁ ∼ c₃)
trans∼ = trans

-- The relation ~ validates the groupoid laws

c◎id∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ◎ id⟷ ∼ c
c◎id∼c = {!!} 

id◎c∼c : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ◎ c ∼ c
id◎c∼c = {!!} 

assoc∼ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
         c₁ ◎ (c₂ ◎ c₃) ∼ (c₁ ◎ c₂) ◎ c₃
assoc∼ = {!!} 

linv∼ : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ◎ ! c ∼ id⟷
linv∼ = {!!} 

rinv∼ : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → ! c ◎ c ∼ id⟷
rinv∼ = {!!} 

resp∼ : {t₁ t₂ t₃ : U} {c₁ c₂ : t₁ ⟷ t₂} {c₃ c₄ : t₂ ⟷ t₃} → 
        (c₁ ∼ c₂) → (c₃ ∼ c₄) → (c₁ ◎ c₃ ∼ c₂ ◎ c₄)
resp∼ = {!!} 

-- The equivalence ∼ of paths makes U a 1groupoid: the points are
-- types (t : U); the 1paths are ⟷; and the 2paths between them are
-- based on extensional equivalence ∼

G : 1Groupoid
G = record
        { set = U
        ; _↝_ = _⟷_
        ; _≈_ = _∼_
        ; id  = id⟷
        ; _∘_ = λ p q → q ◎ p
        ; _⁻¹ = !
        ; lneutr = λ c → c◎id∼c {c = c}
        ; rneutr = λ c → id◎c∼c {c = c}
        ; assoc  = λ c₃ c₂ c₁ → assoc∼ {c₁ = c₁} {c₂ = c₂} {c₃ = c₃}  
        ; equiv = record { 
            refl  = λ {c} → refl∼ {c = c}
          ; sym   = λ {c₁} {c₂} → sym∼ {c₁ = c₁} {c₂ = c₂}
          ; trans = λ {c₁} {c₂} {c₃} → trans∼ {c₁ = c₁} {c₂ = c₂} {c₃ = c₃} 
          }
        ; linv = λ c → linv∼ {c = c} 
        ; rinv = λ c → rinv∼ {c = c} 
        ; ∘-resp-≈ = λ α β → resp∼ β α 
        }

-- And there are additional laws

assoc⊕∼ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          c₁ ⊕ (c₂ ⊕ c₃) ∼ assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊
assoc⊕∼ = {!!} 

assoc⊗∼ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          c₁ ⊗ (c₂ ⊗ c₃) ∼ assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆
assoc⊗∼ = {!!} 

------------------------------------------------------------------------------
-- Picture so far:
--
--           path p
--   =====================
--  ||   ||             ||
--  ||   ||2path        ||
--  ||   ||             ||
--  ||   ||  path q     ||
--  t₁ =================t₂
--  ||   ...            ||
--   =====================
--
-- The types t₁, t₂, etc are discrete groupoids. The paths between
-- them correspond to permutations. Each syntactically different
-- permutation corresponds to a path but equivalent permutations are
-- connected by 2paths.  But now we want an alternative definition of
-- 2paths that is structural, i.e., that looks at the actual
-- construction of the path t₁ ⟷ t₂ in terms of combinators... The
-- theorem we want is that α ∼ β iff we can rewrite α to β using
-- various syntactic structural rules. We start with a collection of
-- simplication rules and then try to show they are complete.

-- Simplification rules

infix  30 _⇔_

data _⇔_ : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₁ ⟷ t₂) → Set where
  assoc◎l : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
          (c₁ ◎ (c₂ ◎ c₃)) ⇔ ((c₁ ◎ c₂) ◎ c₃)
  assoc◎r : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₃ ⟷ t₄} → 
          ((c₁ ◎ c₂) ◎ c₃) ⇔ (c₁ ◎ (c₂ ◎ c₃))
  assoc⊕l : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (c₁ ⊕ (c₂ ⊕ c₃)) ⇔ (assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊)
  assoc⊕r : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (assocl₊ ◎ ((c₁ ⊕ c₂) ⊕ c₃) ◎ assocr₊) ⇔ (c₁ ⊕ (c₂ ⊕ c₃))
  assoc⊗l : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (c₁ ⊗ (c₂ ⊗ c₃)) ⇔ (assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆)
  assoc⊗r : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (assocl⋆ ◎ ((c₁ ⊗ c₂) ⊗ c₃) ◎ assocr⋆) ⇔ (c₁ ⊗ (c₂ ⊗ c₃))
  dist⇔ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          ((c₁ ⊕ c₂) ⊗ c₃) ⇔ (dist ◎ ((c₁ ⊗ c₃) ⊕ (c₂ ⊗ c₃)) ◎ factor)
  factor⇔ : {t₁ t₂ t₃ t₄ t₅ t₆ : U} 
          {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₅ ⟷ t₆} → 
          (dist ◎ ((c₁ ⊗ c₃) ⊕ (c₂ ⊗ c₃)) ◎ factor) ⇔ ((c₁ ⊕ c₂) ⊗ c₃)
  idl◎l   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (id⟷ ◎ c) ⇔ c
  idl◎r   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ id⟷ ◎ c
  idr◎l   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (c ◎ id⟷) ⇔ c
  idr◎r   : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ (c ◎ id⟷) 
  linv◎l  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (c ◎ ! c) ⇔ id⟷
  linv◎r  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ⇔ (c ◎ ! c) 
  rinv◎l  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → (! c ◎ c) ⇔ id⟷
  rinv◎r  : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → id⟷ ⇔ (! c ◎ c) 
  unitel₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (unite₊ ◎ c₂) ⇔ ((c₁ ⊕ c₂) ◎ unite₊)
  uniter₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          ((c₁ ⊕ c₂) ◎ unite₊) ⇔ (unite₊ ◎ c₂)
  unitil₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (uniti₊ ◎ (c₁ ⊕ c₂)) ⇔ (c₂ ◎ uniti₊)
  unitir₊⇔ : {t₁ t₂ : U} {c₁ : ZERO ⟷ ZERO} {c₂ : t₁ ⟷ t₂} → 
          (c₂ ◎ uniti₊) ⇔ (uniti₊ ◎ (c₁ ⊕ c₂))
  unitial₊⇔ : {t₁ t₂ : U} → (uniti₊ {PLUS t₁ t₂} ◎ assocl₊) ⇔ (uniti₊ ⊕ id⟷)
  unitiar₊⇔ : {t₁ t₂ : U} → (uniti₊ {t₁} ⊕ id⟷ {t₂}) ⇔ (uniti₊ ◎ assocl₊)
  swapl₊⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          (swap₊ ◎ (c₁ ⊕ c₂)) ⇔ ((c₂ ⊕ c₁) ◎ swap₊)
  swapr₊⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          ((c₂ ⊕ c₁) ◎ swap₊) ⇔ (swap₊ ◎ (c₁ ⊕ c₂))
  unitel⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (unite⋆ ◎ c₂) ⇔ ((c₁ ⊗ c₂) ◎ unite⋆)
  uniter⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          ((c₁ ⊗ c₂) ◎ unite⋆) ⇔ (unite⋆ ◎ c₂)
  unitil⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (uniti⋆ ◎ (c₁ ⊗ c₂)) ⇔ (c₂ ◎ uniti⋆)
  unitir⋆⇔ : {t₁ t₂ : U} {c₁ : ONE ⟷ ONE} {c₂ : t₁ ⟷ t₂} → 
          (c₂ ◎ uniti⋆) ⇔ (uniti⋆ ◎ (c₁ ⊗ c₂))
  unitial⋆⇔ : {t₁ t₂ : U} → (uniti⋆ {TIMES t₁ t₂} ◎ assocl⋆) ⇔ (uniti⋆ ⊗ id⟷)
  unitiar⋆⇔ : {t₁ t₂ : U} → (uniti⋆ {t₁} ⊗ id⟷ {t₂}) ⇔ (uniti⋆ ◎ assocl⋆)
  swapl⋆⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          (swap⋆ ◎ (c₁ ⊗ c₂)) ⇔ ((c₂ ⊗ c₁) ◎ swap⋆)
  swapr⋆⇔ : {t₁ t₂ t₃ t₄ : U} {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} → 
          ((c₂ ⊗ c₁) ◎ swap⋆) ⇔ (swap⋆ ◎ (c₁ ⊗ c₂))
  swapfl⋆⇔ : {t₁ t₂ t₃ : U} → 
          (swap₊ {TIMES t₂ t₃} {TIMES t₁ t₃} ◎ factor) ⇔ 
          (factor ◎ (swap₊ {t₂} {t₁} ⊗ id⟷))
  swapfr⋆⇔ : {t₁ t₂ t₃ : U} → 
          (factor ◎ (swap₊ {t₂} {t₁} ⊗ id⟷)) ⇔ 
         (swap₊ {TIMES t₂ t₃} {TIMES t₁ t₃} ◎ factor)
  id⇔     : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ c
  trans⇔  : {t₁ t₂ : U} {c₁ c₂ c₃ : t₁ ⟷ t₂} → 
         (c₁ ⇔ c₂) → (c₂ ⇔ c₃) → (c₁ ⇔ c₃)
  resp◎⇔  : {t₁ t₂ t₃ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₂ ⟷ t₃} {c₃ : t₁ ⟷ t₂} {c₄ : t₂ ⟷ t₃} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ◎ c₂) ⇔ (c₃ ◎ c₄)
  resp⊕⇔  : {t₁ t₂ t₃ t₄ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₁ ⟷ t₂} {c₄ : t₃ ⟷ t₄} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ⊕ c₂) ⇔ (c₃ ⊕ c₄)
  resp⊗⇔  : {t₁ t₂ t₃ t₄ : U} 
         {c₁ : t₁ ⟷ t₂} {c₂ : t₃ ⟷ t₄} {c₃ : t₁ ⟷ t₂} {c₄ : t₃ ⟷ t₄} → 
         (c₁ ⇔ c₃) → (c₂ ⇔ c₄) → (c₁ ⊗ c₂) ⇔ (c₃ ⊗ c₄)

-- better syntax for writing 2paths

infix  2  _▤       
infixr 2  _⇔⟨_⟩_   

_⇔⟨_⟩_ : {t₁ t₂ : U} (c₁ : t₁ ⟷ t₂) {c₂ : t₁ ⟷ t₂} {c₃ : t₁ ⟷ t₂} → 
         (c₁ ⇔ c₂) → (c₂ ⇔ c₃) → (c₁ ⇔ c₃)
_ ⇔⟨ α ⟩ β = trans⇔ α β 

_▤ : {t₁ t₂ : U} → (c : t₁ ⟷ t₂) → (c ⇔ c)
_▤ c = id⇔ 

-- Inverses for 2paths

2! : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ⇔ c₂) → (c₂ ⇔ c₁)
2! assoc◎l = assoc◎r
2! assoc◎r = assoc◎l
2! assoc⊕l = assoc⊕r
2! assoc⊕r = assoc⊕l
2! assoc⊗l = assoc⊗r
2! assoc⊗r = assoc⊗l
2! dist⇔ = factor⇔ 
2! factor⇔ = dist⇔
2! idl◎l = idl◎r
2! idl◎r = idl◎l
2! idr◎l = idr◎r
2! idr◎r = idr◎l
2! linv◎l = linv◎r
2! linv◎r = linv◎l
2! rinv◎l = rinv◎r
2! rinv◎r = rinv◎l
2! unitel₊⇔ = uniter₊⇔
2! uniter₊⇔ = unitel₊⇔
2! unitil₊⇔ = unitir₊⇔
2! unitir₊⇔ = unitil₊⇔
2! swapl₊⇔ = swapr₊⇔
2! swapr₊⇔ = swapl₊⇔
2! unitial₊⇔ = unitiar₊⇔ 
2! unitiar₊⇔ = unitial₊⇔ 
2! unitel⋆⇔ = uniter⋆⇔
2! uniter⋆⇔ = unitel⋆⇔
2! unitil⋆⇔ = unitir⋆⇔
2! unitir⋆⇔ = unitil⋆⇔
2! unitial⋆⇔ = unitiar⋆⇔ 
2! unitiar⋆⇔ = unitial⋆⇔ 
2! swapl⋆⇔ = swapr⋆⇔
2! swapr⋆⇔ = swapl⋆⇔
2! swapfl⋆⇔ = swapfr⋆⇔
2! swapfr⋆⇔ = swapfl⋆⇔
2! id⇔ = id⇔
2! (trans⇔ α β) = trans⇔ (2! β) (2! α)
2! (resp◎⇔ α β) = resp◎⇔ (2! α) (2! β)
2! (resp⊕⇔ α β) = resp⊕⇔ (2! α) (2! β)
2! (resp⊗⇔ α β) = resp⊗⇔ (2! α) (2! β) 

-- a nice example of 2 paths

negEx : neg₅ ⇔ neg₁
negEx = uniti⋆ ◎ (swap⋆ ◎ ((swap₊ ⊗ id⟷) ◎ (swap⋆ ◎ unite⋆)))
          ⇔⟨ resp◎⇔ id⇔ assoc◎l ⟩
        uniti⋆ ◎ ((swap⋆ ◎ (swap₊ ⊗ id⟷)) ◎ (swap⋆ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ swapl⋆⇔ id⇔) ⟩
        uniti⋆ ◎ (((id⟷ ⊗ swap₊) ◎ swap⋆) ◎ (swap⋆ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ assoc◎r ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ (swap⋆ ◎ (swap⋆ ◎ unite⋆)))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ assoc◎l) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ ((swap⋆ ◎ swap⋆) ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ (resp◎⇔ linv◎l id⇔)) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ (id⟷ ◎ unite⋆))
          ⇔⟨ resp◎⇔ id⇔ (resp◎⇔ id⇔ idl◎l) ⟩
        uniti⋆ ◎ ((id⟷ ⊗ swap₊) ◎ unite⋆)
          ⇔⟨ assoc◎l ⟩
        (uniti⋆ ◎ (id⟷ ⊗ swap₊)) ◎ unite⋆
          ⇔⟨ resp◎⇔ unitil⋆⇔ id⇔ ⟩
        (swap₊ ◎ uniti⋆) ◎ unite⋆
          ⇔⟨ assoc◎r ⟩
        swap₊ ◎ (uniti⋆ ◎ unite⋆)
          ⇔⟨ resp◎⇔ id⇔ linv◎l ⟩
        swap₊ ◎ id⟷
          ⇔⟨ idr◎l ⟩
        swap₊ ▤

-- The equivalence ⇔ of paths is rich enough to make U a 1groupoid:
-- the points are types (t : U); the 1paths are ⟷; and the 2paths
-- between them are based on the simplification rules ⇔ 

G' : 1Groupoid
G' = record
        { set = U
        ; _↝_ = _⟷_
        ; _≈_ = _⇔_
        ; id  = id⟷
        ; _∘_ = λ p q → q ◎ p
        ; _⁻¹ = !
        ; lneutr = λ _ → idr◎l
        ; rneutr = λ _ → idl◎l
        ; assoc  = λ _ _ _ → assoc◎l
        ; equiv = record { 
            refl  = id⇔
          ; sym   = 2!
          ; trans = trans⇔
          }
        ; linv = λ {t₁} {t₂} α → linv◎l
        ; rinv = λ {t₁} {t₂} α → rinv◎l
        ; ∘-resp-≈ = λ p∼q r∼s → resp◎⇔ r∼s p∼q 
        }

------------------------------------------------------------------------------
-- Inverting permutations to syntactic combinators

perm2comb : {t₁ t₂ : U} → (size t₁ ≡ size t₂) → Perm (size t₁) → (t₁ ⟷ t₂)
perm2comb {ZERO} {t₂} sp [] = {!!} 
perm2comb {ONE} {t₂} sp p = {!!} 
perm2comb {PLUS t₁ t₂} {t₃} sp p = {!!} 
perm2comb {TIMES t₁ t₂} {t₃} sp p = {!!} 

------------------------------------------------------------------------------
-- Soundness and completeness
-- 
-- Proof of soundness and completeness: now we want to verify that ⇔
-- is sound and complete with respect to ∼. The statement to prove is
-- that for all c₁ and c₂, we have c₁ ∼ c₂ iff c₁ ⇔ c₂

soundness : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ⇔ c₂) → (c₁ ∼ c₂)
soundness assoc◎l      = assoc∼
soundness assoc◎r      = sym∼ assoc∼
soundness assoc⊕l      = assoc⊕∼
soundness assoc⊕r      = sym∼ assoc⊕∼
soundness assoc⊗l      = assoc⊗∼
soundness assoc⊗r      = sym∼ assoc⊗∼
soundness dist⇔        = {!!}
soundness factor⇔      = {!!}
soundness idl◎l        = id◎c∼c
soundness idl◎r        = sym∼ id◎c∼c
soundness idr◎l        = c◎id∼c
soundness idr◎r        = sym∼ c◎id∼c
soundness linv◎l       = linv∼
soundness linv◎r       = sym∼ linv∼
soundness rinv◎l       = rinv∼
soundness rinv◎r       = sym∼ rinv∼
soundness unitel₊⇔     = {!!}
soundness uniter₊⇔     = {!!}
soundness unitil₊⇔     = {!!}
soundness unitir₊⇔     = {!!}
soundness unitial₊⇔    = {!!}
soundness unitiar₊⇔    = {!!}
soundness swapl₊⇔      = {!!}
soundness swapr₊⇔      = {!!}
soundness unitel⋆⇔     = {!!}
soundness uniter⋆⇔     = {!!}
soundness unitil⋆⇔     = {!!}
soundness unitir⋆⇔     = {!!}
soundness unitial⋆⇔    = {!!}
soundness unitiar⋆⇔    = {!!}
soundness swapl⋆⇔      = {!!}
soundness swapr⋆⇔      = {!!}
soundness swapfl⋆⇔     = {!!}
soundness swapfr⋆⇔     = {!!}
soundness id⇔          = refl∼
soundness (trans⇔ α β) = trans∼ (soundness α) (soundness β)
soundness (resp◎⇔ α β) = resp∼ (soundness α) (soundness β)
soundness (resp⊕⇔ α β) = {!!}
soundness (resp⊗⇔ α β) = {!!} 

-- The idea is to invert evaluation and use that to extract from each
-- extensional representation of a combinator, a canonical syntactic
-- representative

canonical : {t₁ t₂ : U} → (t₁ ⟷ t₂) → (t₁ ⟷ t₂)
canonical c = perm2comb (size≡ c) (comb2perm c)

-- Note that if c₁ ⇔ c₂, then by soundness c₁ ∼ c₂ and hence their
-- canonical representatives are identical. 

canonicalWellDefined : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → 
  (c₁ ⇔ c₂) → (canonical c₁ ≡ canonical c₂)
canonicalWellDefined {t₁} {t₂} {c₁} {c₂} α = 
  cong₂ perm2comb (size∼ c₁ c₂) (soundness α) 

-- If we can prove that every combinator is equal to its normal form
-- then we can prove completeness.

inversion : {t₁ t₂ : U} {c : t₁ ⟷ t₂} → c ⇔ canonical c
inversion = {!!} 

resp≡⇔ : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ≡ c₂) → (c₁ ⇔ c₂)
resp≡⇔ {t₁} {t₂} {c₁} {c₂} p rewrite p = id⇔ 

completeness : {t₁ t₂ : U} {c₁ c₂ : t₁ ⟷ t₂} → (c₁ ∼ c₂) → (c₁ ⇔ c₂)
completeness {t₁} {t₂} {c₁} {c₂} c₁∼c₂ = 
  c₁
    ⇔⟨ inversion ⟩
  canonical c₁
    ⇔⟨  resp≡⇔ (cong₂ perm2comb (size∼ c₁ c₂) c₁∼c₂) ⟩ 
  canonical c₂
    ⇔⟨ 2! inversion ⟩ 
  c₂ ▤

------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Nat and Fin lemmas

suc≤ : (m n : ℕ) → suc m ≤ m + suc n
suc≤ 0 n       = s≤s z≤n
suc≤ (suc m) n = s≤s (suc≤ m n)

-+-id : (n : ℕ) → (i : Fin n) → suc (n ∸ toℕ i) + toℕ i ≡ suc n
-+-id 0 ()            -- absurd
-+-id (suc n) zero    = +-right-identity (suc (suc n))
-+-id (suc n) (suc i) = begin
  suc (suc n ∸ toℕ (suc i)) + toℕ (suc i) 
    ≡⟨ refl ⟩
  suc (n ∸ toℕ i) + suc (toℕ i) 
    ≡⟨ +-suc (suc (n ∸ toℕ i)) (toℕ i) ⟩
  suc (suc (n ∸ toℕ i) + toℕ i)
    ≡⟨ cong suc (-+-id n i) ⟩
  suc (suc n) ∎

p0 p1 : Perm 4
p0 = idπ
p1 = swap (inject+ 1 (fromℕ 2)) (inject+ 3 (fromℕ 0))
     (swap (fromℕ 3) zero
     (swap zero (inject+ 1 (fromℕ 2))
     idπ))


xx = action p1 (10 ∷ 20 ∷ 30 ∷ 40 ∷ [])

n≤sn : ∀ {x} → x ≤ suc x
n≤sn {0}     = z≤n
n≤sn {suc n} = s≤s (n≤sn {n})

<implies≤ : ∀ {x y} → (x < y) → (x ≤ y)
<implies≤ (s≤s z≤n) = z≤n 
<implies≤ {suc x} {suc y} (s≤s p) = 
  begin (suc x 
           ≤⟨ p ⟩
         y
            ≤⟨ n≤sn {y} ⟩
         suc y ∎)
  where open ≤-Reasoning

bounded≤ : ∀ {n} (i : Fin n) → toℕ i ≤ n
bounded≤ i = <implies≤ (bounded i)
                 
n≤n : (n : ℕ) → n ≤ n
n≤n 0 = z≤n
n≤n (suc n) = s≤s (n≤n n)

-- Convenient way of "seeing" what the permutation does for each combinator

matchP : ∀ {t t'} → (t ⟷ t') → Vec (⟦ t ⟧ × ⟦ t' ⟧) (size t)
matchP {t} {t'} c = 
  match sp (comb2perm c) (utoVec t) 
    (subst (λ n → Vec ⟦ t' ⟧ n) (sym sp) (utoVec t'))
  where sp = size≡ c

infix 90 _X_

data Swap (n : ℕ) : Set where
  _X_ : Fin n → Fin n → Swap n

Perm : ℕ → Set
Perm n = List (Swap n)

showSwap : ∀ {n} → Swap n → String
showSwap (i X j) = show (toℕ i) ++S " X " ++S show (toℕ j)

actionπ : ∀ {ℓ} {A : Set ℓ} {n : ℕ} → Perm n → Vec A n → Vec A n
actionπ π vs = foldl swapX vs π
  where 
    swapX : ∀ {ℓ} {A : Set ℓ} {n : ℕ} → Vec A n → Swap n → Vec A n  
    swapX vs (i X j) = (vs [ i ]≔ lookup j vs) [ j ]≔ lookup i vs

swapπ : ∀ {m n} → Perm (m + n)
swapπ {0}     {n}     = []
swapπ {suc m} {n}     = 
  concatL 
    (replicate (suc m)
      (toList 
        (zipWith _X_ 
          (mapV inject₁ (allFin (m + n))) 
          (tail (allFin (suc m + n))))))

scompπ : ∀ {n} → Perm n → Perm n → Perm n
scompπ = _++L_

injectπ : ∀ {m} → Perm m → (n : ℕ) → Perm (m + n)
injectπ π n = mapL (λ { (i X j) → (inject+ n i) X (inject+ n j) }) π 

raiseπ : ∀ {n} → Perm n → (m : ℕ) → Perm (m + n)
raiseπ π m = mapL (λ { (i X j) → (raise m i) X (raise m j) }) π 

pcompπ : ∀ {m n} → Perm m → Perm n → Perm (m + n)
pcompπ {m} {n} α β = (injectπ α n) ++L (raiseπ β m)

idπ : ∀ {n} → Perm n
idπ {n} = toList (zipWith _X_ (allFin n) (allFin n))

tcompπ : ∀ {m n} → Perm m → Perm n → Perm (m * n)
tcompπ {m} {n} α β = 
  concatL (mapL 
            (λ { (i X j) → 
                 mapL (λ { (k X l) → 
                        (inject≤ (fromℕ (toℕ i * n + toℕ k)) 
                                 (i*n+k≤m*n i k))
                        X 
                        (inject≤ (fromℕ (toℕ j * n + toℕ l)) 
                                 (i*n+k≤m*n j l))})
                      (β ++L idπ {n})})
            (α ++L idπ {m}))
--}

swap+π : (m n : ℕ) → Transposition* (m + n)
swap+π 0 n = []
swap+π (suc m) n = 
  concatL 
    (replicate (suc m)
      (toList 
        (zipWith mkTransposition
          (mapV inject₁ (allFin (m + n))) 
          (tail (allFin (suc m + n))))))

-- Ex:

swap11 swap21 swap32 : List String
swap11 = showTransposition* (swap+π 1 1)
-- 0 X 1 ∷ []
-- actionπ (swap+π 1 1) ("a" ∷ "b" ∷ [])
-- "b" ∷ "a" ∷ []
swap21 = showTransposition* (swap+π 2 1)
-- 0 X 1 ∷ 1 X 2 ∷ 0 X 1 ∷ 1 X 2 ∷ []
-- actionπ (swap+π 2 1) ("a" ∷ "b" ∷ "c" ∷ [])
-- "c" ∷ "a" ∷ "b" ∷ []
swap32 = showTransposition* (swap+π 3 2)
-- 0 X 1 ∷ 1 X 2 ∷ 2 X 3 ∷ 3 X 4 ∷
-- 0 X 1 ∷ 1 X 2 ∷ 2 X 3 ∷ 3 X 4 ∷ 
-- 0 X 1 ∷ 1 X 2 ∷ 2 X 3 ∷ 3 X 4 ∷ []
-- actionπ (swap+π 3 2) ("a" ∷ "b" ∷ "c" ∷ "d" ∷ "e" ∷ [])
-- "d" ∷ "e" ∷ "a" ∷ "b" ∷ "c" ∷ []

delete : ∀ {n} → List (Fin n) → Fin n → List (Fin n)
delete [] _ = []
delete (j ∷ js) i with toℕ i ≟ toℕ j 
delete (j ∷ js) i | yes _ = js
delete (j ∷ js) i | no _ = j ∷ delete js i

extendπ : ∀ {n} → Transposition* n → Transposition* n
extendπ {n} π = 
  let existing = mapL (λ { (i X j) → i }) π
      all = toList (allFin n)
      diff = foldl delete all existing
  in π ++L mapL (λ i → _X_ i i {i≤i (toℕ i)}) diff

tcompπ : ∀ {m n} → Transposition* m → Transposition* n → Transposition* (m * n)
tcompπ {m} {n} α β = 
  concatMap
    (λ { (i X j) → 
      mapL (λ { (k X l) → 
             mkTransposition
               (inject≤ (fromℕ (toℕ i * n + toℕ k)) (i*n+k≤m*n i k))
               (inject≤ (fromℕ (toℕ j * n + toℕ l)) (i*n+k≤m*n j l))})
           (extendπ β)})
    (extendπ α)

{--
pcompπ : ∀ {m n} → Transposition* m → Transposition* n → Transposition* (m + n)
pcompπ {m} {n} α β = injectπ n α ++L raiseπ m β
  where injectπ : ∀ {m} → (n : ℕ) → Transposition* m → Transposition* (m + n)
        injectπ n = mapL (λ { (i X j) → 
                           mkTransposition (inject+ n i) (inject+ n j) })
        raiseπ : ∀ {n} → (m : ℕ) → Transposition* n → Transposition* (m + n)
        raiseπ m = mapL (λ { (i X j) → 
                          mkTransposition (raise m i) (raise m j)})
--}

-- Identity permutation as explicit product of transpositions

idπ : (n : ℕ) → Transposition* n
idπ n = toList (zipWith mkTransposition (allFin n) (allFin n))

-- Ex:

idπ5 = showTransposition* (idπ 5)
-- 0 X 0 ∷ 1 X 1 ∷ 2 X 2 ∷ 3 X 3 ∷ 4 X 4 ∷ []
-- actionπ (idπ 5) ("1" ∷ "2" ∷ "3" ∷ "4" ∷ "5" ∷ [])
-- "1" ∷ "2" ∷ "3" ∷ "4" ∷ "5" ∷ []

  concatMap
    (λ { (i X j) → 
      mapL (λ { (k X l) → 
             mkTransposition
               (inject≤ (fromℕ (toℕ i * n + toℕ k)) (i*n+k≤m*n i k))
               (inject≤ (fromℕ (toℕ j * n + toℕ l)) (i*n+k≤m*n j l))})
           (extendπ β)})
    (extendπ α)

-----

{--
-- Representation I:
-- Our first representation of a permutation is as a product of
-- "transpositions." This product is not commutative; we apply it from
-- left to right. Because we eventually want to normalize permutations
-- to some canonical representation, we insist that the first
-- component of a transposition is always ≤ than the second

infix 90 _X_

data Transposition (n : ℕ) : Set where
  _X_ : (i j : Fin n) → {p : toℕ i ≤ toℕ j} → Transposition n

mkTransposition : {n : ℕ} → (i j : Fin n) → Transposition n
mkTransposition {n} i j with toℕ i ≤? toℕ j 
... | yes p = _X_ i j {p}
... | no p  = _X_ j i {i≰j→j≤i (toℕ i) (toℕ j) p}

Transposition* : ℕ → Set
Transposition* n = List (Transposition n) 

showTransposition* : ∀ {n} → Transposition* n → List String
showTransposition* = 
  mapL (λ { (i X j) → show (toℕ i) ++S " X " ++S show (toℕ j) })

actionπ : ∀ {ℓ} {A : Set ℓ} {n : ℕ} → Transposition* n → Vec A n → Vec A n
actionπ π vs = foldl swapX vs π
  where 
    swapX : ∀ {ℓ} {A : Set ℓ} {n : ℕ} → Vec A n → Transposition n → Vec A n  
    swapX vs (i X j) = (vs [ i ]≔ lookup j vs) [ j ]≔ lookup i vs

-- Representation II:
-- This is also a product of transpositions but the transpositions are such
-- that the first component is always < the second, i.e., we got rid of trivial
-- transpositions that swap an element with itself

data Transposition< (n : ℕ) : Set where
  _X!_ : (i j : Fin n) → {p : toℕ i < toℕ j} → Transposition< n

Transposition<* : ℕ → Set
Transposition<* n = List (Transposition< n) 

showTransposition<* : ∀ {n} → Transposition<* n → List String
showTransposition<* = 
  mapL (λ { (i X! j) → show (toℕ i) ++S " X! " ++S show (toℕ j) })

filter= : {n : ℕ} → Transposition* n → Transposition<* n
filter= [] = []
filter= (_X_ i j {p≤} ∷ π) with toℕ i ≟ toℕ j
... | yes p= = filter= π 
... | no p≠ = _X!_ i j {i≠j∧i≤j→i<j (toℕ i) (toℕ j) p≠ p≤}  ∷ filter= π 

-- Representation IV
-- A product of cycles where each cycle is a non-empty sequence of indices

Cycle : ℕ → Set
Cycle n = List⁺ (Fin n)

Cycle* : ℕ → Set
Cycle* n = List (Cycle n)

-- convert a cycle to a product of transpositions

cycle→transposition* : ∀ {n} → Cycle n → Transposition* n
cycle→transposition* (i , []) = []
cycle→transposition* (i , (j ∷ ns)) = 
  mkTransposition i j ∷ cycle→transposition* (i , ns)

cycle*→transposition* : ∀ {n} → Cycle* n → Transposition* n
cycle*→transposition* cs = concatMap cycle→transposition* cs

-- Ex:

cycleEx1 cycleEx2 : Cycle 5
-- cycleEx1 (0 1 2 3 4) which rotates right
cycleEx1 = inject+ 4 (fromℕ 0) , 
           inject+ 3 (fromℕ 1) ∷
           inject+ 2 (fromℕ 2) ∷
           inject+ 1 (fromℕ 3) ∷
           inject+ 0 (fromℕ 4) ∷ []
-- cycleEx1 (0 4 3 2 1) which rotates left
cycleEx2 = inject+ 4 (fromℕ 0) , 
           inject+ 0 (fromℕ 4) ∷
           inject+ 1 (fromℕ 3) ∷
           inject+ 2 (fromℕ 2) ∷
           inject+ 3 (fromℕ 1) ∷ []
cycleEx1→transposition* cycleEx2→transposition* : List String
cycleEx1→transposition* = showTransposition* (cycle→transposition* cycleEx1)
-- 0 X 1 ∷ 0 X 2 ∷ 0 X 3 ∷ 0 X 4 ∷ []
-- actionπ (cycle→transposition* cycleEx1) (0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ [])
-- 4 ∷ 0 ∷ 1 ∷ 2 ∷ 3 ∷ []
cycleEx2→transposition* = showTransposition* (cycle→transposition* cycleEx2)
-- 0 X 4 ∷ 0 X 3 ∷ 0 X 2 ∷ 0 X 1 ∷ []
-- actionπ (cycle→transposition* cycleEx2) (0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ [])
-- 1 ∷ 2 ∷ 3 ∷ 4 ∷ 0 ∷ []

-- Convert from Cauchy 2 line representation to product of cycles

-- Helper that checks if there is a cycle that starts at i
-- Returns the cycle containing i and the rest of the permutation
-- without that cycle

findCycle : ∀ {n} → Fin n → Cycle* n →  Maybe (Cycle n × Cycle* n)
findCycle i [] = nothing
findCycle i (c ∷ cs) with toℕ i ≟ toℕ (head c)
findCycle i (c ∷ cs) | yes _ = just (c , cs)
findCycle i (c ∷ cs) | no _ = 
  maybe′ (λ { (c' , cs') → just (c' , c ∷ cs') }) nothing (findCycle i cs)

-- Another helper that repeatedly tries to merge smaller cycles

{-# NO_TERMINATION_CHECK #-}
mergeCycles : ∀ {n} → Cycle* n → Cycle* n
mergeCycles [] = []
mergeCycles (c ∷ cs) with findCycle (last c) cs
mergeCycles (c ∷ cs) | nothing = c ∷ mergeCycles cs
mergeCycles (c ∷ cs) | just (c' , cs') = mergeCycles ((c ⁺++ ntail c') ∷ cs')

-- To convert a Cauchy representation to a product of cycles, just create 
-- a cycle of size 2 for each entry and then merge the cycles

cauchy→cycle* : ∀ {n} → Cauchy n → Cycle* n
cauchy→cycle* {n} perm = 
  mergeCycles (toList (zipWith (λ i j → i ∷⁺ [ j ]) (allFin n) perm))

cauchyEx1→transposition* cauchyEx2→transposition* : List String
cauchyEx1→transposition* = 
  showTransposition* (cycle*→transposition* (cauchy→cycle* cauchyEx1))
-- 0 X 2 ∷ 0 X 4 ∷ 0 X 1 ∷ 0 X 0 ∷ 3 X 3 ∷ 5 X 5 ∷ []
-- actionπ (cycle*→transposition* (cauchy→cycle* cauchyEx1)) 
--   (0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ 5 ∷ [])
-- 1 ∷ 4 ∷ 0 ∷ 3 ∷ 2 ∷ 5 ∷ []
cauchyEx2→transposition* = 
  showTransposition* (cycle*→transposition* (cauchy→cycle* cauchyEx2))
-- 0 X 3 ∷ 0 X 0 ∷ 1 X 2 ∷ 1 X 1 ∷ 4 X 5 ∷ 4 X 4 ∷ []
-- actionπ (cycle*→transposition* (cauchy→cycle* cauchyEx2)) 
--   (0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ 5 ∷ [])
-- 3 ∷ 2 ∷ 1 ∷ 0 ∷ 5 ∷ 4 ∷ []

-- Cauchy to product of transpostions

cauchy→transposition* : ∀ {n} → Cauchy n → Transposition* n
cauchy→transposition* = cycle*→transposition* ∘ cauchy→cycle*

-- Ex: 

swap+π : (m n : ℕ) → Transposition* (m + n)
swap+π m n = cauchy→transposition* (swap+cauchy m n)
swap11 swap21 swap32 : List String
swap11 = showTransposition* (swap+π 1 1)
-- 0 X 1 ∷ 0 X 0 ∷ []
-- actionπ (swap+π 1 1) ("a" ∷ "b" ∷ [])
-- "b" ∷ "a" ∷ []
swap21 = showTransposition* (swap+π 2 1)
-- 0 X 1 ∷ 0 X 2 ∷ 0 X 0 ∷ []
-- actionπ (swap+π 2 1) ("a" ∷ "b" ∷ "c" ∷ [])
-- "c" ∷ "a" ∷ "b" ∷ []
swap32 = showTransposition* (swap+π 3 2)
-- 0 X 2 ∷ 0 X 4 ∷ 0 X 1 ∷ 0 X 3 ∷ 0 X 0 ∷ []
-- actionπ (swap+π 3 2) ("a" ∷ "b" ∷ "c" ∷ "d" ∷ "e" ∷ [])
-- "d" ∷ "e" ∷ "a" ∷ "b" ∷ "c" ∷ []

-- Ex: 

pcompπ : ∀ {m n} → Cauchy m → Cauchy n → Transposition* (m + n)
pcompπ α β = cauchy→transposition* (pcompcauchy α β)
swap11+21 swap21+11 : List String
swap11+21 = showTransposition* (pcompπ (swap+cauchy 1 1) (swap+cauchy 2 1))
-- 0 X 1 ∷ 0 X 0 ∷ 2 X 3 ∷ 2 X 4 ∷ 2 X 2 ∷ []
-- actionπ (pcompπ (swap+cauchy 1 1) (swap+cauchy 2 1)) 
--   ("a" ∷ "b" ∷ "1" ∷ "2" ∷ "3" ∷ [])
-- "b" ∷ "a" ∷ "3" ∷ "1" ∷ "2" ∷ []
swap21+11 = showTransposition* (pcompπ (swap+cauchy 2 1) (swap+cauchy 1 1))
-- 0 X 1 ∷ 0 X 2 ∷ 0 X 0 ∷ 3 X 4 ∷ 3 X 3 ∷ []
-- actionπ (pcompπ (swap+cauchy 2 1) (swap+cauchy 1 1)) 
--   ("1" ∷ "2" ∷ "3" ∷ "a" ∷ "b" ∷ [])
-- "3" ∷ "1" ∷ "2" ∷ "b" ∷ "a" ∷ []

-- Ex:

tcompπ : ∀ {m n} → Cauchy m → Cauchy n → Transposition* (m * n)
tcompπ α β = cauchy→transposition* (tcompcauchy α β)
swap21*swap11 : List String
swap21*swap11 = showTransposition* (tcompπ (swap+cauchy 2 1) (swap+cauchy 1 1))
-- 0 X 3 ∷ 0 X 4 ∷ 0 X 1 ∷ 0 X 2 ∷ 0 X 5 ∷ 0 X 0 ∷ []
-- Recall (swap+π 2 1)
-- 0 X 1 ∷ 0 X 2 ∷ 0 X 0 ∷ []                                                   
-- actionπ (swap+π 2 1) ("a" ∷ "b" ∷ "c" ∷ [])
-- "c" ∷ "a" ∷ "b" ∷ []
-- Recall (swap+π 1 1)
-- 0 X 1 ∷ 0 X 0 ∷ []
-- actionπ (swap+π 1 1) ("1" ∷ "2" ∷ [])
-- "2" ∷ "1" ∷ []
-- Tensor tensorvs 
-- ("a" , "1") ∷ ("a" , "2") ∷
-- ("b" , "1") ∷ ("b" , "2") ∷ 
-- ("c" , "1") ∷ ("c" , "2") ∷ []
-- actionπ (tcompπ (swap+cauchy 2 1) (swap+cauchy 1 1)) tensorvs
-- ("c" , "2") ∷ ("c" , "1") ∷
-- ("a" , "2") ∷ ("a" , "1") ∷ 
-- ("b" , "2") ∷ ("b" , "1") ∷ []

-- Ex:

swap⋆π : (m n : ℕ) → Transposition* (m * n) 
swap⋆π m n = cauchy→transposition* (swap⋆cauchy m n)
swap3x2→2x3 : List String
swap3x2→2x3 = showTransposition* (swap⋆π 3 2)
-- 0 X 0 ∷ 1 X 3 ∷ 1 X 4 ∷ 1 X 2 ∷ 1 X 1 ∷ 5 X 5 ∷ []
-- Let vs3x2 = 
-- ("a" , 1) ∷ ("a" , 2) ∷ 
-- ("b" , 1) ∷ ("b" , 2) ∷ 
-- ("c" , 1) ∷ ("c" , 2) ∷ []
-- actionπ (swap⋆π 3 2) vs3x2
-- ("a" , 1) ∷ ("b" , 1) ∷ ("c" , 1) ∷ 
-- ("a" , 2) ∷ ("b" , 2) ∷ ("c" , 2) ∷ []

c2π : {t₁ t₂ : U} → (c : t₁ ⟷ t₂) → Transposition* (size t₁)
c2π = cauchy→transposition* ∘ c2cauchy

-- Convenient way of seeing c : t₁ ⟷ t₂ as a permutation

showπ : {t₁ t₂ : U} → (c : t₁ ⟷ t₂) → Vec (⟦ t₁ ⟧ × ⟦ t₂ ⟧) (size t₁) 
showπ {t₁} {t₂} c = 
  let vs₁ = utoVec t₁
      vs₂ = utoVec t₂
  in zip (actionπ (c2π c) vs₁) (subst (Vec ⟦ t₂ ⟧) (sym (size≡ c)) vs₂)

-- Examples

NEG1π NEG2π NEG3π NEG4π NEG5π : Vec (⟦ BOOL ⟧ × ⟦ BOOL ⟧) 2
NEG1π = showπ NEG1
-- (true , false) ∷ (false , true) ∷ []
NEG2π = showπ NEG2  
-- (true , false) ∷ (false , true) ∷ []
NEG3π = showπ NEG3  
-- (true , false) ∷ (false , true) ∷ []
NEG4π = showπ NEG4
-- (true , false) ∷ (false , true) ∷ []
NEG5π = showπ NEG5 
-- (true , false) ∷ (false , true) ∷ []

cnotπ : Vec (⟦ BOOL² ⟧ × ⟦ BOOL² ⟧) 4 
cnotπ = showπ {BOOL²} {BOOL²} CNOT
-- ((false , false) , (false , false)) ∷
-- ((false , true)  , (false , true))  ∷
-- ((true  , true)  , (true  , false)) ∷
-- ((true  , false) , (true  , true))  ∷ []

toffoliπ : Vec (⟦ TIMES BOOL BOOL² ⟧ × ⟦ TIMES BOOL BOOL² ⟧) 8  
toffoliπ = showπ {TIMES BOOL BOOL²} {TIMES BOOL BOOL²} TOFFOLI
-- ((false , false , false) , (false , false , false)) ∷
-- ((false , false , true)  , (false , false , true))  ∷
-- ((false , true  , false) , (false , true  , false)) ∷
-- ((false , true  , true)  , (false , true  , true))  ∷
-- ((true  , false , false) , (true  , false , false)  ∷
-- ((true  , false , true)  , (true  , false , true))  ∷
-- ((true  , true  , true)  , (true  , true  , false)) ∷
-- ((true  , true  , false) , (true  , true  , true))  ∷ []

-- The elements of PLUS ONE (PLUS ONE ONE) in canonical order are:
-- inj₁ tt
-- inj₂ (inj₁ tt)
-- inj₂ (inj₂ tt)

id3π swap12π swap23π swap13π rotlπ rotrπ : 
  Vec (⟦ PLUS ONE (PLUS ONE ONE) ⟧ × ⟦ PLUS ONE (PLUS ONE ONE) ⟧) 3
id3π    = showπ {PLUS ONE (PLUS ONE ONE)} {PLUS ONE (PLUS ONE ONE)} id⟷
-- (inj₁ tt , inj₁ tt) ∷
-- (inj₂ (inj₁ tt) , inj₂ (inj₁ tt)) ∷
-- (inj₂ (inj₂ tt) , inj₂ (inj₂ tt)) ∷ []
swap12π = showπ {PLUS ONE (PLUS ONE ONE)} {PLUS ONE (PLUS ONE ONE)} SWAP12
-- (inj₂ (inj₁ tt) , inj₁ tt) ∷
-- (inj₁ tt , inj₂ (inj₁ tt)) ∷ 
-- (inj₂ (inj₂ tt) , inj₂ (inj₂ tt)) ∷ []
swap23π = showπ {PLUS ONE (PLUS ONE ONE)} {PLUS ONE (PLUS ONE ONE)} SWAP23
-- (inj₁ tt , inj₁ tt) ∷
-- (inj₂ (inj₂ tt) , inj₂ (inj₁ tt)) ∷
-- (inj₂ (inj₁ tt) , inj₂ (inj₂ tt)) ∷ []
swap13π = showπ {PLUS ONE (PLUS ONE ONE)} {PLUS ONE (PLUS ONE ONE)} SWAP13
-- (inj₂ (inj₂ tt) , inj₁ tt) ∷
-- (inj₂ (inj₁ tt) , inj₂ (inj₁ tt)) ∷ 
-- (inj₁ tt , inj₂ (inj₂ tt)) ∷ []
rotrπ   = showπ {PLUS ONE (PLUS ONE ONE)} {PLUS ONE (PLUS ONE ONE)} ROTR
-- (inj₂ (inj₁ tt) , inj₁ tt) ∷
-- (inj₂ (inj₂ tt) , inj₂ (inj₁ tt)) ∷ 
-- (inj₁ tt , inj₂ (inj₂ tt)) ∷ []
rotlπ   = showπ {PLUS ONE (PLUS ONE ONE)} {PLUS ONE (PLUS ONE ONE)} ROTL
-- (inj₂ (inj₂ tt) , inj₁ tt) ∷
-- (inj₁ tt , inj₂ (inj₁ tt)) ∷ 
-- (inj₂ (inj₁ tt) , inj₂ (inj₂ tt)) ∷ []

peresπ : Vec (((Bool × Bool) × Bool) × ((Bool × Bool) × Bool)) 8
peresπ = showπ PERES
-- (((false , false) , false) , (false , false) , false) ∷
-- (((false , false) , true)  , (false , false) , true)  ∷
-- (((false , true)  , false) , (false , true)  , false) ∷
-- (((false , true)  , true)  , (false , true)  , true)  ∷
-- (((true  , true)  , true)  , (true  , false) , false) ∷
-- (((true  , true)  , false) , (true  , false) , true)  ∷
-- (((true  , false) , false) , (true  , true)  , false) ∷
-- (((true  , false) , true)  , (true  , true)  , true)  ∷ []

fulladderπ : 
  Vec ((Bool × ((Bool × Bool) × Bool)) × (Bool × (Bool × (Bool × Bool)))) 16
fulladderπ = showπ FULLADDER
-- ((false , (false , false) , false) , false , false , false , false) ∷
-- ((true  , (false , false) , false) , false , false , false , true)  ∷
-- ((false , (false , false) , true)  , false , false , true  , false) ∷
-- ((true  , (false , false) , true)  , false , false , true  , true)  ∷
-- ((false , (false , true)  , false) , false , true  , true  , false) ∷
-- ((false , (false , true)  , true)  , false , true  , false , true)  ∷
-- ((true  , (false , true)  , true)  , false , true  , false , false) ∷
-- ((true  , (false , true)  , false) , false , true  , true  , true)  ∷
-- ((true  , (true  , true)  , false) , true  , false , false , false) ∷
-- ((false , (true  , true)  , false) , true  , false , false , true)  ∷
-- ((true  , (true  , true)  , true)  , true  , false , true  , false) ∷ 
-- ((false , (true  , true)  , true)  , true  , false , true  , true)  ∷
-- ((true  , (true  , false) , true)  , true  , true  , false , false) ∷
-- ((false , (true  , false) , true)  , true  , true  , false , true)  ∷
-- ((false , (true  , false) , false) , true  , true  , true  , false) ∷
-- ((true  , (true  , false) , false) , true  , true  , true  , true)  ∷ []
-- which agrees with spec.

------------------------------------------------------------------------------
-- Normalization

-- We sort the list of transpositions using a variation of bubble
-- sort. Like in the conventional bubble sort we look at pairs of
-- transpositions and swap them if they are out of order but if we
-- encounter (i X j) followed by (i X j) we remove both. 

-- one pass of bubble sort
-- goal is to reach a sorted sequene with no repeats in the first position
-- Ex: (0 X 2) ∷ (3 X 4) ∷ (4 X 6) ∷ (5 X 6)

-- There is probably lots of room for improvement. Here is the idea.
-- We take a list of transpositions (a_i X b_i) where a_i < b_i and keep
-- looking at adjacent pairs doing the following transformations:
-- 
-- A.  (a X b) (a X b) => id
-- B.  (a X b) (c X d) => (c X d) (a X b) if c < a
-- C.  (a X b) (c X b) => (c X a) (a X b) if c < a
-- D.  (a X b) (c X a) => (c X b) (a X b) 
-- E.  (a X b) (a X d) => (a X d) (b X d) if b < d
-- F.  (a X b) (a X d) => (a X d) (d X b) if d < b
-- 
-- The point is that we get closer and closer to the following
-- invariant. For any two adjacent transpositions (a X b) (c X d) we have
-- that a < c. Transformations B, C, and D rewrite anything in which a > c.
-- Transformations A, E, and F rewrite anything in which a = c. Termination 
-- is subtle clearly.
-- 
-- New strategy to implement: So could we index things so that a first set of
-- (up to) n passes 'bubble down' (0 X a) until there is only one left at the
-- root, then recurse on the tail to 'bubble down' (1 X b)'s [if any]? That
-- would certainly ensure termination.

{-# NO_TERMINATION_CHECK #-}
bubble : ∀ {n} → Transposition<* n → Transposition<* n
bubble [] = []
bubble (x ∷ []) = x ∷ []
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π) 
--
-- check every possible equality between the indices
--
  with toℕ i ≟ toℕ k | toℕ i ≟ toℕ l | toℕ j ≟ toℕ k | toℕ j ≟ toℕ l
--
-- get rid of a bunch of impossible cases given that i < j and k < l
--
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | _ | yes j≡k | yes j≡l 
  with trans (sym j≡k) (j≡l) | i<j→i≠j {toℕ k} {toℕ l} k<l
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | _ | yes j≡k | yes j≡l
  | k≡l | ¬k≡l with ¬k≡l k≡l
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | _ | yes j≡k | yes j≡l
  | k≡l | ¬k≡l | ()
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | yes i≡l | _ | yes j≡l 
  with trans i≡l (sym j≡l) | i<j→i≠j {toℕ i} {toℕ j} i<j
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | yes i≡l | _ | yes j≡l 
  | i≡j | ¬i≡j with ¬i≡j i≡j
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | yes i≡l | _ | yes j≡l 
  | i≡j | ¬i≡j | ()
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | _ | yes j≡k | _
  with trans i≡k (sym j≡k) | i<j→i≠j {toℕ i} {toℕ j} i<j 
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | _ | yes j≡k | _
  | i≡j | ¬i≡j with ¬i≡j i≡j
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | _ | yes j≡k | _
  | i≡j | ¬i≡j | ()
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | yes i≡l | _ | _
  with trans (sym i≡k) i≡l | i<j→i≠j {toℕ k} {toℕ l} k<l 
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | yes i≡l | _ | _
  | k≡l | ¬k≡l with ¬k≡l k≡l
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | yes i≡l | _ | _
  | k≡l | ¬k≡l | ()
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | yes i≡l | yes j≡k | _
  with subst₂ _<_ (sym j≡k) (sym i≡l) k<l | i<j→j≮i {toℕ i} {toℕ j} i<j
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | yes i≡l | yes j≡k | _
  | j<i | j≮i with j≮i j<i
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | _ | yes i≡l | yes j≡k | _
  | j<i | j≮i | ()
--
-- end of impossible cases
--
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l with toℕ i <? toℕ k
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l | yes i<k = 
  -- already sorted; no repeat in first position; skip and recur
  -- Ex: 2 X! 5 , 3 X! 4
    _X!_ i j {i<j} ∷ bubble (_X!_ k l {k<l} ∷ π)
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l | no i≮k = 
  -- Case B. 
  -- not sorted; no repeat in first position; no interference
  -- just slide one transposition past the other
  -- Ex: 2 X! 5 , 1 X! 4
  -- becomes 1 X! 4 , 2 X! 5
    _X!_ k l {k<l} ∷  bubble (_X!_ i j {i<j} ∷ π)
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | no ¬i≡l | no ¬j≡k | yes j≡l = 
  -- Case A. 
  -- transposition followed by its inverse; simplify by removing both
  -- Ex: 2 X! 5 , 2 X! 5
  -- becomes id and is deleted
  bubble π 
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | yes j≡l with toℕ i <? toℕ k 
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | yes j≡l | yes i<k = 
  -- already sorted; no repeat in first position; skip and recur
  -- Ex: 2 X! 5 , 3 X! 5 
    _X!_ i j {i<j} ∷ bubble (_X!_ k l {k<l} ∷ π)
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | no ¬i≡l | no ¬j≡k | yes j≡l | no i≮k = 
  _X!_ k i 
    {i≰j∧j≠i→j<i (toℕ i) (toℕ k) (i≮j∧i≠j→i≰j (toℕ i) (toℕ k) i≮k ¬i≡k) 
       (i≠j→j≠i (toℕ i) (toℕ k) ¬i≡k)} ∷
  bubble (_X!_ i j {i<j} ∷ π)
  -- Case C. 
  -- Ex: 2 X! 5 , 1 X! 5 
  -- becomes 1 X! 2 , 2 X! 5
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | no ¬i≡l | yes j≡k | no ¬j≡l = 
  -- already sorted; no repeat in first position; skip and recur
  -- Ex: 2 X! 5 , 5 X! 6 
   _X!_ i j {i<j} ∷ bubble (_X!_ k l {k<l} ∷ π)
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | no ¬i≡k | yes i≡l | no ¬j≡k | no ¬j≡l = 
  -- Case D. 
  -- Ex: 2 X! 5 , 1 X! 2 
  -- becomes 1 X! 5 , 2 X! 5
  _X!_ k j {trans< (subst ((λ l → toℕ k < l)) (sym i≡l) k<l) i<j} ∷
  bubble (_X!_ i j {i<j} ∷ π)
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l with toℕ j <? toℕ l
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l | yes j<l =
  -- Case E. 
  -- Ex: 2 X! 5 , 2 X! 6
  -- becomes 2 X! 6 , 5 X! 6
  _X!_ k l {k<l} ∷ bubble (_X!_ j l {j<l} ∷ π)
bubble (_X!_ i j {i<j} ∷ _X!_ k l {k<l} ∷ π)
  | yes i≡k | no ¬i≡l | no ¬j≡k | no ¬j≡l | no j≮l = 
  -- Case F. 
  -- Ex: 2 X! 5 , 2 X! 3
  -- becomes 2 X! 3 , 3 X! 5 
  _X!_ k l {k<l} ∷ 
  bubble (_X!_ l j {i≰j∧j≠i→j<i (toℕ j) (toℕ l) 
                    (i≮j∧i≠j→i≰j (toℕ j) (toℕ l) j≮l ¬j≡l)
                    (i≠j→j≠i (toℕ j) (toℕ l) ¬j≡l)} ∷ π)

-- sorted and no repeats in first position

{-# NO_TERMINATION_CHECK #-}
canonical? : ∀ {n} → Transposition<* n → Bool
canonical? [] = true
canonical? (x ∷ []) = true
canonical? (i X! j ∷ k X! l ∷ π) with toℕ i <? toℕ k
canonical? (i X! j ∷ _X!_ k l {k<l}  ∷ π) | yes i<k = 
  canonical? (_X!_ k l {k<l} ∷ π)
canonical? (i X! j ∷ _X!_ k l {k<l} ∷ π) | no i≮k = false

{-# NO_TERMINATION_CHECK #-}
sort : ∀ {n} → Transposition<* n → Transposition<* n
sort π with canonical? π 
sort π | true = π 
sort π | false = sort (bubble π)

-- Examples

snn₁ snn₂ snn₃ snn₄ snn₅ : List String
snn₁ = showTransposition<* (sort (filter= (c2π NEG1)))
   -- 0 X! 1 ∷ []
snn₂ = showTransposition<* (sort (filter= (c2π NEG2)))
   -- 0 X! 1 ∷ []
snn₃ = showTransposition<* (sort (filter= (c2π NEG3)))
   -- 0 X! 1 ∷ []
snn₄ = showTransposition<* (sort (filter= (c2π NEG4)))
   -- 0 X! 1 ∷ []
snn₅ = showTransposition<* (sort (filter= (c2π NEG5)))
   -- 0 X! 1 ∷ []

sncnot sntoffoli : List String
sncnot = showTransposition<* (sort (filter= (c2π CNOT)))
   -- 2 X! 3 ∷ []
sntoffoli = showTransposition<* (sort (filter= (c2π TOFFOLI)))
   -- 6 X! 7 ∷ []

snswap12 snswap23 snswap13 snrotl snrotr : List String
snswap12 = showTransposition<* (sort (filter= (c2π SWAP12)))
   -- 0 X! 1 ∷ []
snswap23 = showTransposition<* (sort (filter= (c2π SWAP23)))
   -- 1 X! 2 ∷ []
snswap13 = showTransposition<* (sort (filter= (c2π SWAP13)))
   -- 0 X! 2 ∷ []
snrotl   = showTransposition<* (sort (filter= (c2π ROTL)))
   -- 0 X! 2 ∷ 1 X! 2 ∷ []
snrotr   = showTransposition<* (sort (filter= (c2π ROTR)))
   -- 0 X! 1 ∷ 1 X! 2 ∷ []

snperes snfulladder : List String
snperes = showTransposition<* (sort (filter= (c2π PERES)))
   -- 4 X! 7 ∷ 5 X! 6 ∷ 6 X! 7 ∷ []

snfulladder = showTransposition<* (sort (filter= (c2π FULLADDER)))
   -- ? 

-- Normalization

normalizeπ : {t₁ t₂ : U} → (c : t₁ ⟷  t₂) → Transposition<* (size t₁)
normalizeπ = sort ∘ filter= ∘ c2π
--}

-- Courtesy of Wolfram Kahl, a dependent cong₂                                  
cong₂D : {a b c : Level} {A : Set a} {B : A → Set b} {C : Set c} 
         (f : (x : A) → B x → C)
       → {x₁ x₂ : A} {y₁ : B x₁} {y₂ : B x₂}
       → (x₁≡x₂ : x₁ ≡ x₂) → y₁ ≡ subst B (sym x₁≡x₂) y₂ → f x₁ y₁ ≡ f x₂ y₂
cong₂D f refl refl = refl

congD : {a b : Level} {A : Set a} {B : A → Set b}
         (f : (x : A) → B x) → {x₁ x₂ : A} → (x₁≡x₂ : x₁ ≡ x₂) → 
         subst B (sym x₁≡x₂) (f x₂) ≡ f x₁
congD f refl = refl

{--
-- even more useful is something which captures the equalities
-- inherent in a combinator
-- note that the code below "hand inlines" most of size≡,
-- mainly for greater convenience
adjustBy : {t₁ t₂ : U} {P : ℕ → Set} → (c : t₁ ⟷ t₂) → (P (size t₁) → P (size t₂))
adjustBy {P = P} (c₀ ◎ c₁) p = subst P (size≡ c₁) (subst P (size≡ c₀) p)
adjustBy {PLUS t₁ t₂} {PLUS t₃ t₄} {P} (c₀ ⊕ c₁) p =
     subst P (cong₂ _+_ (size≡ c₀) (refl)) (subst P (cong₂ _+_ {size t₁} (refl) (size≡ c₁)) p)
adjustBy (c₀ ⊗ c₁) p = {!!}
adjustBy unite₊ p = p
adjustBy uniti₊ p = p
adjustBy {PLUS t₁ t₂} {PLUS .t₂ .t₁} {P} swap₊ p = 
    subst P (+-comm (size t₁) (size t₂) ) p
adjustBy assocl₊ p = {!!}
adjustBy assocr₊ p = {!!}
adjustBy unite⋆ p = {!!}
adjustBy uniti⋆ p = {!!}
adjustBy swap⋆ p = {!!}
adjustBy assocl⋆ p = {!!}
adjustBy assocr⋆ p = {!!}
adjustBy distz p = {!!}
adjustBy factorz p = {!!}
adjustBy dist p = {!!}
adjustBy factor p = {!!}
adjustBy id⟷ p = p
adjustBy foldBool p = p
adjustBy unfoldBool p = p
--}

{--
OLD definition
swap+cauchy' : (m n : ℕ) → Cauchy (m + n)
swap+cauchy' m n with splitAt n (allFin (n + m))
... | (zeron , (nsum , _)) = 
    (subst (λ s → Vec (Fin s) m) (+-comm n m) nsum) ++V 
    (subst (λ s → Vec (Fin s) n) (+-comm n m) zeron)
--}

{--

-- Proofs about proofs.  Should be elsewhere

sym-sym : {A : Set} {x y : A} → (p : x ≡ y) → sym (sym p) ≡ p
sym-sym refl = refl

trans-refl : {A : Set} {x y : A} → (p : x ≡ y) → trans p refl ≡ p
trans-refl refl = refl

-- Proof about natural numbers proof

sym-comm : ∀ (m n : ℕ) → sym (+-comm m n) ≡ +-comm n m
sym-comm 0 0 = refl
sym-comm 0 (suc n) = 
  begin (sym (sym (cong suc $ +-right-identity n))
           ≡⟨ sym-sym (cong suc (+-right-identity n)) ⟩
         cong suc (+-right-identity n)
           ≡⟨ cong
                (cong suc)
                (trans (sym (sym-sym (+-right-identity n))) (sym-comm 0 n)) ⟩
         cong suc (+-comm n 0)
           ≡⟨ sym (trans-refl (cong suc (+-comm n 0))) ⟩
         trans (cong suc (+-comm n 0)) (sym (+-suc 0 n)) ∎)
  where open ≡-Reasoning
sym-comm (suc m) 0 = {!!}
sym-comm (suc m) (suc n) = {!!}

--}

{-- 

these are all true, but not actually used!  And they cause termination
issues in my older Agda, so I'll just comment them out for now.  JC

i≰j→j≤i : (i j : ℕ) → (i ≰ j) → (j ≤ i) 
i≰j→j≤i i 0 p = z≤n 
i≰j→j≤i 0 (suc j) p with p z≤n
i≰j→j≤i 0 (suc j) p | ()
i≰j→j≤i (suc i) (suc j) p with i ≤? j
i≰j→j≤i (suc i) (suc j) p | yes p' with p (s≤s p')
i≰j→j≤i (suc i) (suc j) p | yes p' | ()
i≰j→j≤i (suc i) (suc j) p | no p' = s≤s (i≰j→j≤i i j p')

i≠j∧i≤j→i<j : (i j : ℕ) → (¬ i ≡ j) → (i ≤ j) → (i < j)
i≠j∧i≤j→i<j 0 0 p≠ p≤ with p≠ refl
i≠j∧i≤j→i<j 0 0 p≠ p≤ | ()
i≠j∧i≤j→i<j 0 (suc j) p≠ p≤ = s≤s z≤n
i≠j∧i≤j→i<j (suc i) 0 p≠ ()
i≠j∧i≤j→i<j (suc i) (suc j) p≠ (s≤s p≤) with i ≟ j
i≠j∧i≤j→i<j (suc i) (suc j) p≠ (s≤s p≤) | yes p' with p≠ (cong suc p')
i≠j∧i≤j→i<j (suc i) (suc j) p≠ (s≤s p≤) | yes p' | ()
i≠j∧i≤j→i<j (suc i) (suc j) p≠ (s≤s p≤) | no p' = s≤s (i≠j∧i≤j→i<j i j p' p≤)
     
i<j→i≠j : {i j : ℕ} → (i < j) → (¬ i ≡ j)
i<j→i≠j {0} (s≤s p) ()
i<j→i≠j {suc i} (s≤s p) refl = i<j→i≠j {i} p refl

i<j→j≮i : {i j : ℕ} → (i < j) → (j ≮ i) 
i<j→j≮i {0} (s≤s p) ()
i<j→j≮i {suc i} (s≤s p) (s≤s q) = i<j→j≮i {i} p q

i≰j∧j≠i→j<i : (i j : ℕ) → (i ≰ j) → (¬ j ≡ i) → j < i
i≰j∧j≠i→j<i i j i≰j ¬j≡i = i≠j∧i≤j→i<j j i ¬j≡i (i≰j→j≤i i j i≰j)

i≠j→j≠i : (i j : ℕ) → (¬ i ≡ j) → (¬ j ≡ i)
i≠j→j≠i i j i≠j j≡i = i≠j (sym j≡i)

si≠sj→i≠j : (i j : ℕ) → (¬ Data.Nat.suc i ≡ Data.Nat.suc j) → (¬ i ≡ j)
si≠sj→i≠j i j ¬si≡sj i≡j = ¬si≡sj (cong suc i≡j)

si≮sj→i≮j : (i j : ℕ) → (¬ Data.Nat.suc i < Data.Nat.suc j) → (¬ i < j)
si≮sj→i≮j i j si≮sj i<j = si≮sj (s≤s i<j)

i≮j∧i≠j→i≰j : (i j : ℕ) → (i ≮ j) → (¬ i ≡ j) → (i ≰ j)
i≮j∧i≠j→i≰j 0 0 i≮j ¬i≡j i≤j = ¬i≡j refl
i≮j∧i≠j→i≰j 0 (suc j) i≮j ¬i≡j i≤j = i≮j (s≤s z≤n)
i≮j∧i≠j→i≰j (suc i) 0 i≮j ¬i≡j () 
i≮j∧i≠j→i≰j (suc i) (suc j) si≮sj ¬si≡sj (s≤s i≤j) = 
  i≮j∧i≠j→i≰j i j (si≮sj→i≮j i j si≮sj) (si≠sj→i≠j i j ¬si≡sj) i≤j
-}

-- this is a non-dependently typed version of tensor product of vectors.

tensorvec : ∀ {m n} {A B C : Set} →
            (A → B → C) → Vec A m → Vec B n → Vec C (m * n)
tensorvec {0} _ [] _ = []
tensorvec {suc m} {n} {C = C} f (x ∷ α) β =
  subst
    (λ i → Vec C (n + m * n))
    (+-*-suc m n)
    (mapV (f x) β ++V tensorvec f α β)

-- this is a better template

tensorvec' : ∀ {A B C : ℕ → Set} → (∀ {m n} → A m → B n → C (m * n)) →
    (∀ {m} → (n : ℕ) → C m → C (n + m)) → 
    ∀ {m n j} →  Vec (A m) j → Vec (B n) n → Vec (C (m * n)) (j * n)
tensorvec' _ _ {j = 0} [] _ = []
tensorvec' {A} {B} {C} f shift {m} {n} {suc j} (x ∷ α) β =
  subst
    (λ i → Vec (C (m * n)) (n + j * n))
    (+-*-suc j n) 
    (mapV (f x) β ++V (tensorvec' {A} {B} {C} f shift α β))

-- raise d by b*n and inject in m*n

raise∘inject : ∀ {m n} → (b : Fin m) (d : Fin n) → Fin (m * n)
raise∘inject {0} {n} () d
raise∘inject {suc m} {n} b d =
  inject≤ (raise (toℕ b * n) d) (i*n+n≤sucm*n {m} {n} b)

tcompcauchy' : ∀ {i m n} → Vec (Fin m) i → Cauchy n → Vec (Fin (m * n)) (i * n)
tcompcauchy' {0} {m} {n} [] β = []
tcompcauchy' {suc i} {m} {n} (b ∷ α) β = 
  mapV (raise∘inject {m} {n} b) β ++V tcompcauchy' {i} {m} {n} α β
    
tcompcauchy2 : ∀ {m n} → Cauchy m → Cauchy n → Cauchy (m * n)
tcompcauchy2 = tcompcauchy'

leq-lem-0 : (m n : ℕ) → suc n ≤ n + suc m
leq-lem-0 m n =
  begin (suc n
           ≤⟨ m≤m+n (suc n) m ⟩ 
         suc (n + m)
           ≡⟨ cong suc (+-comm n m) ⟩ 
         suc m + n
           ≡⟨ +-comm (suc m) n ⟩ 
         n + suc m ∎)
  where open ≤-Reasoning

leq-lem-1 : (n : ℕ) → suc ((n + 0) + 0) ≤ n + suc (suc (n + 0))
leq-lem-1 n =
  begin (suc ((n + 0) + 0)
           ≡⟨ cong suc (+-right-identity (n + 0)) ⟩
         suc (n + 0)
           ≡⟨ cong suc (+-right-identity n) ⟩
         suc n
           ≤⟨ n≤1+n (suc n) ⟩ 
         suc (suc n)
           ≤⟨ n≤m+n n (suc (suc n)) ⟩ 
         n + suc (suc n)
           ≡⟨ cong (λ x → n + suc (suc x)) (sym (+-right-identity n)) ⟩ 
         n + suc (suc (n + 0)) ∎)
  where open ≤-Reasoning

simplify-≤ : {m n m' n' : ℕ} → 
             (m ≤ n) → (m ≡ m') → (n ≡ n') → (m' ≤ n') 
simplify-≤ leq refl refl = leq

raise-lem-0 : (m n : ℕ) → (leq : suc n ≤ n + suc m) →
              raise n zero ≡ inject≤ (fromℕ n) leq
raise-lem-0 m 0 (s≤s leq) = refl
raise-lem-0 m (suc n) (s≤s leq) = cong suc (raise-lem-0 m n leq)

simplify-≤ : {m n m' n' : ℕ} → 
             (m ≤ n) → (m ≡ m') → (n ≡ n') → (m' ≤ n') 
simplify-≤ leq refl refl = leq

inject≤-≡ : ∀ {m m' n : ℕ} → (i : Fin m) → (leq : m ≤ n) → (eqm : m ≡ m') → 
  inject≤ {m} {n} i leq ≡ 
  inject≤ {m'} {n} (subst Fin eqm i) (subst (λ x → x ≤ n) eqm leq)
inject≤-≡ i leq refl = refl

leq-Fin : (n m : ℕ) → (j : Fin (suc n)) → toℕ j ≤ n + m
leq-Fin 0 m zero = z≤n
leq-Fin 0 m (suc ())
leq-Fin (suc n) m zero = z≤n
leq-Fin (suc n) m (suc j) = s≤s (leq-Fin n m j)

leq-lem-1 : (m n : ℕ) → (j : Fin (suc m)) → (d : Fin (suc n)) → 
  suc (toℕ j * suc n + toℕ d) ≤ suc m * suc n
leq-lem-1 0 0 zero zero = s≤s z≤n
leq-lem-1 0 0 zero (suc ())
leq-lem-1 0 0 (suc ()) zero
leq-lem-1 0 0 (suc () ) _
leq-lem-1 0 (suc n) zero zero = s≤s z≤n
leq-lem-1 0 (suc n) zero (suc d) = s≤s (s≤s (leq-Fin n 0 d))
leq-lem-1 0 (suc n) (suc ()) _
leq-lem-1 (suc m) 0 zero zero = s≤s z≤n
leq-lem-1 (suc m) 0 zero (suc ())
leq-lem-1 (suc m) 0 (suc j) zero = s≤s (leq-lem-1 m 0 j zero)
leq-lem-1 (suc m) 0 (suc j) (suc ())
leq-lem-1 (suc m) (suc n) zero zero = s≤s z≤n
leq-lem-1 (suc m) (suc n) zero (suc d) =
  s≤s (s≤s (leq-Fin n (suc m * suc (suc n)) d))
leq-lem-1 (suc m) (suc n) (suc j) d = s≤s (s≤s pr)
  where
    pr = begin (suc ((n + toℕ j * suc (suc n)) + toℕ d)
                  ≡⟨ sym (+-suc (n + toℕ j * suc (suc n)) (toℕ d)) ⟩
                (n + toℕ j * suc (suc n)) + suc (toℕ d)
                  ≤⟨ cong+l≤
                      (bounded d)
                      (n + toℕ j * suc (suc n)) ⟩ 
                (n + toℕ j * suc (suc n)) + suc (suc n)
                  ≤⟨ cong+r≤
                      (cong+l≤
                        (cong*r≤ (bounded' m j) (suc (suc n)))
                        n)
                      (suc (suc n)) ⟩
                (n + m * suc (suc n)) + suc (suc n)
                  ≡⟨ +-assoc n (m * suc (suc n)) (suc (suc n)) ⟩ 
                n + (m * suc (suc n) + suc (suc n))
                  ≡⟨ cong
                       (λ x → n + x)
                       (+-comm (m * suc (suc n)) (suc (suc n))) ⟩
                n + (suc (suc n) + m * suc (suc n))
                  ≡⟨ refl ⟩
                n + suc m * suc (suc n) ∎)
         where open ≤-Reasoning

leq-lem-2 : (m n : ℕ) → (j : Fin (suc m)) → (d : Fin (suc n)) → 
  suc (suc (toℕ j) * suc n + toℕ d) ≤ suc (suc m) * suc n
leq-lem-2 m n j d =
  begin (suc (suc (toℕ j) * suc n + toℕ d)
           ≤⟨ s≤s (cong+l≤ (bounded' n d) (suc (toℕ j) * suc n)) ⟩
         suc (suc (toℕ j) * suc n + n)
           ≡⟨ sym (+-suc (suc (toℕ j) * suc n) n)  ⟩
         suc (toℕ j) * suc n + suc n
           ≡⟨ +-comm (suc (toℕ j) * suc n) (suc n) ⟩
         suc n + suc (toℕ j) * suc n 
           ≡⟨ refl ⟩
         suc (suc (toℕ j)) * suc n
           ≤⟨ cong*r≤
                (s≤s (s≤s (bounded' m j)))
                (suc n) ⟩
         suc (suc m) * suc n ∎)
  where open ≤-Reasoning

leq-lem-0 : (m n : ℕ) → suc n ≤ n + suc m
leq-lem-0 m n =
  begin (suc n
           ≤⟨ m≤m+n (suc n) m ⟩ 
         suc (n + m)
           ≡⟨ cong suc (+-comm n m) ⟩ 
         suc m + n
           ≡⟨ +-comm (suc m) n ⟩ 
         n + suc m ∎)
  where open ≤-Reasoning

-- the extra 'm' is really handy

inject-id : (m : ℕ) (j : Fin (suc m)) (leq : toℕ j ≤ m) → 
  j ≡ inject≤ (fromℕ (toℕ j)) (s≤s leq)
inject-id 0 zero z≤n = refl
inject-id 0 (suc j) ()
inject-id (suc m) zero z≤n = refl
inject-id (suc m) (suc j) (s≤s leq) = cong suc (inject-id m j leq) 

raise-lem-0 : (m n : ℕ) → (leq : suc n ≤ n + suc m) →
              raise n zero ≡ inject≤ (fromℕ n) leq
raise-lem-0 m 0 (s≤s leq) = refl
raise-lem-0 m (suc n) (s≤s leq) = cong suc (raise-lem-0 m n leq)

raise-lem-0' : (m n : ℕ) (j : Fin (suc m)) →
  (leq : suc (n + toℕ j) ≤ n + (suc m)) →
  raise n j ≡ inject≤ (fromℕ (n + toℕ j)) leq
raise-lem-0' m 0 j (s≤s leq) = inject-id m j leq
raise-lem-0' m (suc n) j (s≤s leq) = cong suc (raise-lem-0' m n j leq)

raise-lem-1 : (n : ℕ) → (d : Fin (suc n)) → 
  (leq : toℕ d ≤ n) → 
  (leq' : suc (n + suc (toℕ d)) ≤ n + suc (suc n)) → 
  raise n (inject≤ (fromℕ (toℕ (suc d))) (s≤s (s≤s leq)))
  ≡ inject≤ (fromℕ (n + toℕ (suc d))) leq'
raise-lem-1 0 zero z≤n (s≤s (s≤s z≤n)) = refl
raise-lem-1 0 (suc d) () leq'
raise-lem-1 (suc n) zero z≤n (s≤s leq') =
  begin (suc (raise n (suc zero))
           ≡⟨ cong suc (raise-lem-0' (suc (suc n)) n (suc zero) leq') ⟩
         suc (inject≤ (fromℕ (n + 1)) leq') ∎)
  where open ≡-Reasoning
raise-lem-1 (suc n) (suc d) (s≤s leq) (s≤s leq') = cong suc (
  begin (raise n (suc (suc _)))
               ≡⟨ cong (λ x → raise n (suc (suc x))) (sym (inject-id n d leq)) ⟩
            raise n (suc (suc d))
               ≡⟨ raise-lem-0' (suc (suc n)) n (suc (suc d)) leq' ⟩
            inject≤ (fromℕ (n + suc (suc (toℕ d)))) leq' ∎)
  where open ≡-Reasoning

cancel+l : (r k n : ℕ) → r + k ≤ n → k ≤ n
cancel+l 0 k n x = x
cancel+l (suc r) k 0 ()
cancel+l (suc r) k (suc n) (s≤s x) = trans≤ (cancel+l r k n x) (i≤si _)

lastV : {ℓ : Level} {A : Set ℓ} {n : ℕ} → Vec A (suc n) → A
lastV (x ∷ []) = x
lastV (_ ∷ x ∷ xs) = lastV (x ∷ xs)

last-map : {A B : Set} → (n : ℕ) → (xs : Vec A (suc n)) → (f : A → B) → 
         lastV (mapV f xs) ≡ f (lastV xs)
last-map 0 (x ∷ []) f = refl
last-map (suc n) (_ ∷ x ∷ xs) f = last-map n (x ∷ xs) f 

{--
transposeIndex : (m n : ℕ) → 
                 (b : Fin (suc (suc m))) → (d : Fin (suc (suc n))) → 
                 Fin (suc (suc m) * suc (suc n))
transposeIndex m n b d with toℕ b * suc (suc n) + toℕ d
transposeIndex m n b d | i with suc i ≟ suc (suc m) * suc (suc n)
transposeIndex m n b d | i | yes _ = 
  fromℕ (suc (n + suc (suc (n + m * suc (suc n))))) 
transposeIndex m n b d | i | no _ = 
  inject≤ 
    ((i * (suc (suc m))) mod (suc (n + suc (suc (n + m * suc (suc n))))))
    (i≤si (suc (n + suc (suc (n + m * suc (suc n))))))
--}

transposeIndex : (m n : ℕ) →
                 (b : Fin (suc (suc m))) → (d : Fin (suc (suc n))) → 
                 Fin (suc (suc m) * suc (suc n))
transposeIndex m n b d =
  inject≤
    (fromℕ (toℕ d * suc (suc m) + toℕ b))
    (trans≤ (i*n+k≤m*n d b) (refl′ (*-comm (suc (suc n)) (suc (suc m)))))

swap⋆cauchy : (m n : ℕ) → Cauchy (m * n)
swap⋆cauchy 0 n = []
swap⋆cauchy 1 n = subst Cauchy (sym (+-right-identity n)) (idcauchy n)
swap⋆cauchy (suc (suc m)) 0 = 
  subst Cauchy (sym (*-right-zero (suc (suc m)))) []
swap⋆cauchy (suc (suc m)) 1 = 
  subst Cauchy (sym (i*1≡i (suc (suc m)))) (idcauchy (suc (suc m)))
swap⋆cauchy (suc (suc m)) (suc (suc n)) = 
  concatV 
    (mapV 
      (λ b → mapV (λ d → transposeIndex m n b d) (allFin (suc (suc n))))
      (allFin (suc (suc m))))

transposeIndex0 : (m n : ℕ) →
       (b : Fin m) → (d : Fin n) → Fin (m * n)
transposeIndex0 m n b d =
  inject≤
    (fromℕ (toℕ d * m + toℕ b))
    (trans≤ (i*n+k≤m*n d b) (refl′ (*-comm n m)))

-- another way to check injectivity

isElement : ∀ {m n} → Fin m → Vec (Fin m) n → Maybe (Fin n)
isElement _ [] = nothing
isElement x (y ∷ ys) with toℕ x ≟ toℕ y | isElement x ys
... | yes _ | _ = just zero
... | no _ | nothing = nothing
... | no _ | just i = just (suc i)

injective : ∀ {m n} → Pred (Vec (Fin m) n) lzero
injective {m} {n} π = ∀ {i j} → lookup i π ≡ lookup j π → i ≡ j

{--
isInjective : ∀ {m n} → UnaryDecidable (injective {m} {n})
isInjective {m} {0} [] = yes f
  where f : {i j : Fin 0} → (lookup i [] ≡ lookup j []) → (i ≡ j)
        f {()}
isInjective {m} {suc n} (b ∷ π) with isElement b π | isInjective {m} {n} π
... | just i | _ = no {!!} 
... | nothing | no ¬inj = no {!!}
... | nothing | yes inj = yes {!!} 
--}

{--
transpose≡ : (m n : ℕ) (i j : Fin (suc (suc m) * suc (suc n)))
             (bi bj : Fin (suc (suc m))) (di dj : Fin (suc (suc n)))
             (deci : toℕ i ≡ toℕ di + toℕ bi * suc (suc n))
             (decj : toℕ j ≡ toℕ dj + toℕ bj * suc (suc n))
             (tpr : transposeIndex m n bi di ≡ transposeIndex m n bj dj) → (i ≡ j)
transpose≡ m n i j bi bj di dj deci decj tpr =
  let (d≡ , b≡) = fin-addMul-lemma (suc (suc n)) (suc (suc m)) di dj bi bj stpr
      d+bn≡ = cong₂ (λ x y → toℕ x + toℕ y * suc (suc n)) d≡ b≡
  in toℕ-injective (trans deci (trans d+bn≡ (sym decj))) 
  where stpr = begin (toℕ di * suc (suc m) + toℕ bi
                      ≡⟨ sym (to-from _) ⟩ 
                      toℕ (fromℕ (toℕ di * suc (suc m) + toℕ bi))
                      ≡⟨ sym (inject≤-lemma _ _) ⟩ 
                      toℕ (inject≤
                        (fromℕ (toℕ di * suc (suc m) + toℕ bi))
                        (trans≤
                          (i*n+k≤m*n di bi)
                          (refl′ (*-comm (suc (suc n)) (suc (suc m))))))
                      ≡⟨ cong toℕ tpr ⟩ 
                      toℕ (inject≤
                        (fromℕ (toℕ dj * suc (suc m) + toℕ bj))
                        (trans≤
                          (i*n+k≤m*n dj bj)
                          (refl′ (*-comm (suc (suc n)) (suc (suc m))))))
                      ≡⟨ inject≤-lemma _ _ ⟩ 
                      toℕ (fromℕ (toℕ dj * suc (suc m) + toℕ bj))
                      ≡⟨ to-from _ ⟩ 
                      toℕ dj * suc (suc m) + toℕ bj ∎)
               where open ≡-Reasoning

swap⋆perm' : (m n : ℕ) (i j : Fin (m * n))
             (p : lookup i (swap⋆cauchy m n) ≡ lookup j (swap⋆cauchy m n)) → (i ≡ j)
swap⋆perm' 0 n () j p
swap⋆perm' 1 n i j p = toℕ-injective pr
  where pr = begin (toℕ i
                   ≡⟨ cong toℕ (sym (lookup-allFin i)) ⟩
                   toℕ (lookup i (idcauchy (n + 0)))
                   ≡⟨ cong
                        (λ x → toℕ (lookup i x))
                        (sym (subst-allFin (sym (+-right-identity n)))) ⟩
                   toℕ (lookup i (subst Cauchy (sym (+-right-identity n)) (idcauchy n)))
                   ≡⟨ cong toℕ p ⟩
                   toℕ (lookup j (subst Cauchy (sym (+-right-identity n)) (idcauchy n)))
                   ≡⟨ cong
                        (λ x → toℕ (lookup j x))
i                        (subst-allFin (sym (+-right-identity n))) ⟩
                   toℕ (lookup j (idcauchy (n + 0)))
                   ≡⟨ cong toℕ (lookup-allFin j) ⟩
                   toℕ j ∎)
             where open ≡-Reasoning
swap⋆perm' (suc (suc m)) 0 i j p rewrite (*-right-zero m) = ⊥-elim (Fin0-⊥ i)
swap⋆perm' (suc (suc m)) 1 i j p = toℕ-injective pr
  where pr = begin (toℕ i
                    ≡⟨ cong toℕ (sym (lookup-allFin i)) ⟩
                   toℕ (lookup i (idcauchy (suc (suc m) * 1)))
                    ≡⟨ cong
                         (λ x → toℕ (lookup i x))
                         (sym (subst-allFin (sym (i*1≡i (suc (suc m)))))) ⟩
                   toℕ (lookup i
                      (subst Cauchy (sym (i*1≡i (suc (suc m))))
                      (idcauchy (suc (suc m)))))
                    ≡⟨ cong toℕ p ⟩
                   toℕ (lookup j
                      (subst Cauchy (sym (i*1≡i (suc (suc m))))
                      (idcauchy (suc (suc m)))))
                    ≡⟨ cong
                         (λ x → toℕ (lookup j x))
                         (subst-allFin (sym (i*1≡i (suc (suc m))))) ⟩
                    toℕ (lookup j (idcauchy (suc (suc m) * 1)))
                    ≡⟨ cong toℕ (lookup-allFin j) ⟩
                    toℕ j ∎)
             where open ≡-Reasoning
swap⋆perm' (suc (suc m)) (suc (suc n)) i j p =
  let fin-result bi di deci deci' = fin-divMod (suc (suc m)) (suc (suc n)) i
      fin-result bj dj decj decj' = fin-divMod (suc (suc m)) (suc (suc n)) j
  in transpose≡ m n i j bi bj di dj deci decj pr
  where pr = let fin-result bi di deci deci' = fin-divMod (suc (suc m)) (suc (suc n)) i
                 fin-result bj dj decj decj' = fin-divMod (suc (suc m)) (suc (suc n)) j
             in
             begin (transposeIndex m n bi di 
                   ≡⟨ cong₂ (λ x y → transposeIndex m n x y)
                        (sym (lookup-allFin bi)) (sym (lookup-allFin di)) ⟩ 
                    transposeIndex m n
                      (lookup bi (allFin (suc (suc m))))
                      (lookup di (allFin (suc (suc n))))
                    ≡⟨ sym (lookup-2d (suc (suc m)) (suc (suc n)) i
                         (allFin (suc (suc m))) (allFin (suc (suc n)))
                         (λ {(b , d) → transposeIndex m n b d})) ⟩ 
                   lookup i
                      (concatV 
                        (mapV 
                          (λ b →
                            mapV
                              (λ d → transposeIndex m n b d)
                              (allFin (suc (suc n))))
                          (allFin (suc (suc m)))))
                    ≡⟨ p ⟩
                   lookup j 
                      (concatV 
                        (mapV 
                          (λ b →
                            mapV
                              (λ d → transposeIndex m n b d)
                              (allFin (suc (suc n))))
                          (allFin (suc (suc m)))))
                    ≡⟨ lookup-2d (suc (suc m)) (suc (suc n)) j
                         (allFin (suc (suc m))) (allFin (suc (suc n)))
                         (λ {(b , d) → transposeIndex m n b d}) ⟩
                    transposeIndex m n
                      (lookup bj (allFin (suc (suc m))))
                      (lookup dj (allFin (suc (suc n))))
                    ≡⟨ cong₂ (λ x y → transposeIndex m n x y)
                         (lookup-allFin bj) (lookup-allFin dj) ⟩ 
                    transposeIndex m n bj dj ∎)
             where open ≡-Reasoning

swap⋆perm : (m n : ℕ) → Permutation (m * n)
swap⋆perm m n = (swap⋆cauchy m n , λ {i} {j} p → swap⋆perm' m n i j p)
--}

subst-allFin : ∀ {m n} → (eq : m ≡ n) → subst Cauchy eq (allFin m) ≡ allFin n
subst-allFin refl = refl

{--
transposeIndex' : (m n : ℕ) → (b : Fin (suc (suc m))) (d : Fin (suc (suc n))) →
  (toℕ b ≡ suc m × toℕ d ≡ suc n) →
  transposeIndex m n b d ≡ fromℕ (suc n + suc m * suc (suc n))
transposeIndex' m n b d (b≡ , d≡)
  with suc (toℕ b * suc (suc n) + toℕ d) ≟ suc (suc m) * suc (suc n)
transposeIndex' m n b d (b≡ , d≡) | yes i= = refl
transposeIndex' m n b d (b≡ , d≡) | no i≠ = ⊥-elim (i≠ contra)
  where contra = begin (suc (toℕ b * suc (suc n) + toℕ d)
                       ≡⟨ cong₂ (λ x y → suc (x * suc (suc n) + y)) b≡ d≡ ⟩ 
                        suc (suc m * suc (suc n) + suc n)
                       ≡⟨ sym (+-suc (suc m * suc (suc n)) (suc n)) ⟩ 
                        suc m * suc (suc n) + suc (suc n)
                       ≡⟨ +-comm (suc m * suc (suc n)) (suc (suc n)) ⟩ 
                        suc (suc n) + suc m * suc (suc n) 
                       ≡⟨ refl ⟩ 
                        suc (suc m) * suc (suc n) ∎)
                 where open ≡-Reasoning
--}

{--
transposeIndex'' : (m n : ℕ) (b : Fin (suc (suc m))) (d : Fin (suc (suc n))) 
  (p≠  : ¬ suc (toℕ b * suc (suc n) + toℕ d) ≡ suc (suc m) * suc (suc n)) → 
  transposeIndex m n b d ≡
  inject≤
    (((toℕ b * suc (suc n) + toℕ d) * (suc (suc m))) mod (suc n + suc m * suc (suc n)))
    (i≤si (suc n + suc m * suc (suc n)))
transposeIndex'' m n b d p≠ with
  suc (toℕ b * suc (suc n) + toℕ d) ≟ suc (suc m) * suc (suc n)
... | yes w = ⊥-elim (p≠ w)
... | no ¬w = refl
--}

{--
subst-lookup-transpose : (m n : ℕ) (b : Fin (suc (suc m))) (d : Fin (suc (suc n))) → 
  subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
    (lookup
      (subst Fin (*-comm (suc (suc m)) (suc (suc n)))
        (transposeIndex m n b d))
      (concatV
        (mapV
          (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
          (allFin (suc (suc n))))))
  ≡ inject≤
      (fromℕ (toℕ b * suc (suc n) + toℕ d))
      (i*n+k≤m*n b d)
subst-lookup-transpose m n b d
  with suc (toℕ b * suc (suc n) + toℕ d) ≟ suc (suc m) * suc (suc n)
subst-lookup-transpose m n b d | yes p= =
  let (b= , d=) = max-b-d m n b d p= in 
  begin (subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
          (lookup
            (subst Fin (*-comm (suc (suc m)) (suc (suc n)))
              (fromℕ (suc n + suc m * suc (suc n))))
            (concatV
              (mapV
                (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
                (allFin (suc (suc n))))))
        ≡⟨ cong (λ x → subst Fin (*-comm (suc (suc n)) (suc (suc m)))
                          (lookup x
                             (concatV
                               (mapV
                                 (λ b →
                                   mapV
                                     (λ d → transposeIndex n m b d)
                                     (allFin (suc (suc m))))
                                 (allFin (suc (suc n)))))))
                 (subst-fin
                   (suc n + suc m * suc (suc n))
                   (suc m + suc n * suc (suc m))
                   (*-comm (suc (suc m)) (suc (suc n)))) ⟩ 
        subst Fin (*-comm (suc (suc n)) (suc (suc m)))
          (lookup
            (fromℕ (suc m + suc n * suc (suc m)))
            (concatV
              (mapV
                (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
                (allFin (suc (suc n))))))
        ≡⟨ cong
             (λ x → subst Fin (*-comm (suc (suc n)) (suc (suc m)))
               (lookup (fromℕ (suc m + suc n * suc (suc m))) x))
             (concat-map-map-tabulate (suc (suc n)) (suc (suc m))
               (λ {(b , d) → transposeIndex n m b d})) ⟩
        subst Fin (*-comm (suc (suc n)) (suc (suc m)))
          (lookup
            (fromℕ (suc m + suc n * suc (suc m)))
            (tabulate (λ k →
              let (b , d) = fin-project (suc (suc n)) (suc (suc m)) k in
              transposeIndex n m b d)))
        ≡⟨ cong (subst Fin (*-comm (suc (suc n)) (suc (suc m))))
             (lookup-fromℕ-allFin
               (suc m + suc n * suc (suc m))
               (λ k →
                  let (b , d) = fin-project (suc (suc n)) (suc (suc m)) k in
                  transposeIndex n m b d)) ⟩
        subst Fin (*-comm (suc (suc n)) (suc (suc m)))
          (let (b , d) = fin-project (suc (suc n)) (suc (suc m))
                           (fromℕ (suc m + suc n * suc (suc m)))
           in transposeIndex n m b d)
        ≡⟨ cong
             (λ x →
               subst Fin (*-comm (suc (suc n)) (suc (suc m)))
                 (let (b , d) = x in transposeIndex n m b d))
             (fin-project-2 n m) ⟩ 
        subst Fin (*-comm (suc (suc n)) (suc (suc m)))
          (transposeIndex n m (fromℕ (suc n)) (fromℕ (suc m)))
        ≡⟨ cong (subst Fin (*-comm (suc (suc n)) (suc (suc m))))
             (transposeIndex' n m (fromℕ (suc n)) (fromℕ (suc m))
               (to-from (suc n) , to-from (suc m))) ⟩
        subst Fin (*-comm (suc (suc n)) (suc (suc m)))
          (fromℕ (suc m + suc n * suc (suc m)))
        ≡⟨ subst-fin
             (suc (m + suc (suc (m + n * suc (suc m)))))
             (suc (n + suc (suc (n + m * suc (suc n)))))
             (*-comm (suc (suc n)) (suc (suc m))) ⟩
        fromℕ (suc (n + suc (suc (n + m * suc (suc n)))))
        ≡⟨ sym (fin=1 n m) ⟩ 
        fromℕ (suc n + suc m * suc (suc n))
        ≡⟨ toℕ-injective
            (trans (to-from (suc n + suc m * suc (suc n)))
            (trans (+-comm (suc n) (suc m * suc (suc n)))
            (trans (sym (to-from (suc m * suc (suc n) + suc n)))
            (sym (inject≤-lemma
              (fromℕ (suc m * suc (suc n) + suc n))
              (refl′
                (trans (sym (+-suc (suc m * suc (suc n)) (suc n)))
                (+-comm (suc m * suc (suc n)) (suc (suc n)))))))))) ⟩
        inject≤
          (fromℕ (suc m * suc (suc n) + suc n))
          (refl′ (trans
                   (sym (+-suc (suc m * suc (suc n)) (suc n)))
                   (+-comm (suc m * suc (suc n)) (suc (suc n)))))
       ≡⟨ cong₂D!
            (λ x y → inject≤ (fromℕ x) y)
            (cong₂ (λ x y → x * suc (suc n) + y) b= d=)
            (≤-proof-irrelevance
              (subst (λ z → suc z ≤ suc (suc n) + suc m * suc (suc n))
                (cong₂ (λ x y → x * suc (suc n) + y) b= d=)
                (i*n+k≤m*n b d))
              (refl′
                (trans
                  (sym (cong suc (cong suc (+-suc (n + m * suc (suc n)) (suc n)))))
                  (+-comm (suc m * suc (suc n)) (suc (suc n)))))) ⟩ 
        inject≤
          (fromℕ (toℕ b * suc (suc n) + toℕ d))
          (i*n+k≤m*n b d) ∎)
  where open ≡-Reasoning
subst-lookup-transpose m n b d | no p≠ =
  let leq : suc (toℕ b * suc (suc n) + toℕ d) ≤ suc n + suc m * suc (suc n)
      leq = not-max-b-d m n b d p≠
      p'≠ : ¬ suc (toℕ d * suc (suc m) + toℕ b) ≡ suc (suc n) * suc (suc m)
      p'≠ = not-max-b-d' m n b d p≠ in
  begin (subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
          (lookup
            (subst Fin (*-comm (suc (suc m)) (suc (suc n)))
              (inject≤
                ((((toℕ b * suc (suc n)) + toℕ d) * (suc (suc m))) mod
                 (suc n + suc m * suc (suc n)))
                (i≤si (suc n + suc m * suc (suc n)))))
            (concatV
              (mapV
                (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
                (allFin (suc (suc n))))))
        ≡⟨ cong₂
             (λ x y → subst Fin (*-comm (suc (suc n)) (suc (suc m))) (lookup x y))
             (subst-inject-mod
               {((toℕ b * suc (suc n)) + toℕ d) * (suc (suc m))}
               (*-comm (suc (suc m)) (suc (suc n))))
             (concat-map-map-tabulate (suc (suc n)) (suc (suc m))
               (λ {(b , d) → transposeIndex n m b d})) ⟩
        subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
          (lookup
            (inject≤
                ((((toℕ b * suc (suc n)) + toℕ d) * (suc (suc m))) mod
                 (suc m + suc n * suc (suc m)))
                (i≤si (suc m + suc n * suc (suc m))))
            (tabulate (λ k →
              let (b , d) = fin-project (suc (suc n)) (suc (suc m)) k in 
              transposeIndex n m b d)))
        ≡⟨ cong (subst Fin (*-comm (suc (suc n)) (suc (suc m))))
             (lookup∘tabulate
               (λ k →
                let (b , d) = fin-project (suc (suc n)) (suc (suc m)) k in 
                transposeIndex n m b d)
              (inject≤
                ((((toℕ b * suc (suc n)) + toℕ d) * (suc (suc m))) mod
                 (suc m + suc n * suc (suc m)))
                (i≤si (suc m + suc n * suc (suc m))))) ⟩
        subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
          (let (d' , b') = fin-project
                             (suc (suc n)) (suc (suc m))
                             (inject≤
                               ((((toℕ b * suc (suc n)) + toℕ d) * (suc (suc m))) mod
                                 (suc m + suc n * suc (suc m)))
                               (i≤si (suc m + suc n * suc (suc m))))
           in transposeIndex n m d' b')
        ≡⟨ cong
             (λ x →
               subst Fin (*-comm (suc (suc n)) (suc (suc m)))
                 let (d' , b') = x in transposeIndex n m d' b')
             (fin-project-3 m n b d p'≠) ⟩ 
        subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
          (transposeIndex n m d b)
        ≡⟨ cong (subst Fin (*-comm (suc (suc n)) (suc (suc m))))
             (transposeIndex'' n m d b p'≠) ⟩ 
        subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
          (inject≤
            (((toℕ d * suc (suc m) + toℕ b) * suc (suc n)) mod
             (suc m + suc n * suc (suc m)))
            (i≤si (suc m + suc n * suc (suc m))))
        ≡⟨ subst-inject-mod
             {(toℕ d * suc (suc m) + toℕ b) * suc (suc n)}
             (*-comm (suc (suc n)) (suc (suc m))) ⟩
        inject≤
            (((toℕ d * suc (suc m) + toℕ b) * suc (suc n)) mod
             (suc n + suc m * suc (suc n)))
            (i≤si (suc n + suc m * suc (suc n)))
        ≡⟨ inject-mod m n b d leq ⟩ 
        inject≤
          (fromℕ (toℕ b * suc (suc n) + toℕ d))
          (i*n+k≤m*n b d) ∎)
  where open ≡-Reasoning
--}

{--
lookup-swap-2 :
  (m n : ℕ) (b : Fin (suc (suc m))) (d : Fin (suc (suc n))) → 
  lookup
    (transposeIndex m n b d)
    (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
      (concatV
        (mapV
          (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
          (allFin (suc (suc n)))))) ≡
  inject≤
    (fromℕ (toℕ b * suc (suc n) + toℕ d))
    (i*n+k≤m*n b d)
lookup-swap-2 m n b d = 
  begin (lookup
           (transposeIndex m n b d)
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (concatV
               (mapV
                 (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
                 (allFin (suc (suc n))))))
         ≡⟨ lookup-subst-1
              (transposeIndex m n b d)
              (concatV
                (mapV
                  (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
                  (allFin (suc (suc n)))))
              (*-comm (suc (suc n)) (suc (suc m)))
              (*-comm (suc (suc m)) (suc (suc n)))
              (proof-irrelevance
                (sym (*-comm (suc (suc n)) (suc (suc m))))
                (*-comm (suc (suc m)) (suc (suc n)))) ⟩ 
         subst Fin (*-comm (suc (suc n)) (suc (suc m))) 
           (lookup
             (subst Fin (*-comm (suc (suc m)) (suc (suc n)))
               (transposeIndex m n b d))
             (concatV
               (mapV
                 (λ b → mapV (λ d → transposeIndex n m b d) (allFin (suc (suc m))))
                 (allFin (suc (suc n))))))
         ≡⟨ subst-lookup-transpose m n b d ⟩ 
         inject≤
           (fromℕ (toℕ b * suc (suc n) + toℕ d))
           (i*n+k≤m*n b d) ∎)
  where open ≡-Reasoning
--}

{--
lookup-swap-1 :
  (m n : ℕ) → (b  : Fin (suc (suc m))) → (d  : Fin (suc (suc n))) → 
  lookup
    (lookup
      (inject≤
        (fromℕ (toℕ b * suc (suc n) + toℕ d))
        (i*n+k≤m*n b d))
      (concatV
        (mapV (λ b₁ → mapV (transposeIndex m n b₁) (allFin (suc (suc n))))
        (allFin (suc (suc m))))))
    (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
      (concatV
        (mapV (λ b₁ → mapV (transposeIndex n m b₁) (allFin (suc (suc m))))
        (allFin (suc (suc n)))))) ≡
  lookup
    (inject≤
      (fromℕ (toℕ b * suc (suc n) + toℕ d))
      (i*n+k≤m*n b d))
    (concatV
      (mapV
        (λ b₁ →
          mapV
            (λ d₁ → inject≤ (fromℕ (toℕ b₁ * suc (suc n) + toℕ d₁)) (i*n+k≤m*n b₁ d₁))
            (allFin (suc (suc n))))
        (allFin (suc (suc m)))))
lookup-swap-1 m n b d =
  begin (lookup
           (lookup
             (inject≤
               (fromℕ (toℕ b * suc (suc n) + toℕ d))
               (i*n+k≤m*n b d))
             (concatV
               (mapV (λ b₁ → mapV (transposeIndex m n b₁) (allFin (suc (suc n))))
               (allFin (suc (suc m))))))
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (concatV
               (mapV (λ b₁ → mapV (transposeIndex n m b₁) (allFin (suc (suc m))))
               (allFin (suc (suc n))))))
         ≡⟨ cong
               (λ x → lookup x
                 (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
                   (concatV
                   (mapV (λ b₁ → mapV (transposeIndex n m b₁) (allFin (suc (suc m))))
                         (allFin (suc (suc n)))))))
               (lookup-concat' (suc (suc m)) (suc (suc n)) b d (i*n+k≤m*n b d)
                  (λ {(b , d) → transposeIndex m n b d})
                  (allFin (suc (suc m))) (allFin (suc (suc n)))) ⟩ 
         lookup
           (transposeIndex m n
             (lookup b (allFin (suc (suc m))))
             (lookup d (allFin (suc (suc n)))))
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (concatV
               (mapV (λ b₁ → mapV (transposeIndex n m b₁) (allFin (suc (suc m))))
               (allFin (suc (suc n))))))
         ≡⟨ cong₂
              (λ x y → lookup (transposeIndex m n x y)
                         (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
                           (concatV
                             (mapV
                               (λ b₁ →
                                 mapV (transposeIndex n m b₁) (allFin (suc (suc m))))
                               (allFin (suc (suc n)))))))
              (lookup-allFin b)
              (lookup-allFin d) ⟩ 
         lookup
           (transposeIndex m n b d)
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (concatV
               (mapV (λ b₁ → mapV (transposeIndex n m b₁) (allFin (suc (suc m))))
               (allFin (suc (suc n))))))
         ≡⟨ lookup-swap-2 m n b d ⟩ 
           inject≤
             (fromℕ (toℕ b * suc (suc n) + toℕ d))
             (i*n+k≤m*n b d)
         ≡⟨ sym (cong₂
                   (λ x y → let b' = x
                                d' = y in 
                            inject≤
                              (fromℕ (toℕ b' * suc (suc n) + toℕ d'))
                              (i*n+k≤m*n b' d'))
                   (lookup-allFin b)
                   (lookup-allFin d)) ⟩
           let b' = lookup b (allFin (suc (suc m)))
               d' = lookup d (allFin (suc (suc n))) in 
           inject≤
             (fromℕ (toℕ b' * suc (suc n) + toℕ d'))
             (i*n+k≤m*n b' d')
         ≡⟨ sym (lookup-concat' (suc (suc m)) (suc (suc n)) b d (i*n+k≤m*n b d)
                   (λ {(b , d) →
                     inject≤
                        (fromℕ (toℕ b * suc (suc n) + toℕ d))
                        (i*n+k≤m*n b d)})
                   (allFin (suc (suc m))) (allFin (suc (suc n)))) ⟩ 
         lookup
           (inject≤
             (fromℕ (toℕ b * suc (suc n) + toℕ d))
             (i*n+k≤m*n b d))
           (concatV
             (mapV
               (λ b₁ →
                 mapV
                   (λ d₁ →
                     inject≤ (fromℕ (toℕ b₁ * suc (suc n) + toℕ d₁)) (i*n+k≤m*n b₁ d₁))
                   (allFin (suc (suc n))))
               (allFin (suc (suc m))))) ∎)
  where open ≡-Reasoning
--}

{--
lookup-swap : (m n : ℕ) (i : Fin (suc (suc m) * suc (suc n))) →
  let vs = allFin (suc (suc m))
      ws = allFin (suc (suc n)) in 
  lookup
    (lookup i (concatV (mapV (λ b → mapV (transposeIndex m n b) ws) vs)))
    (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
      (concatV (mapV (λ b → mapV (transposeIndex n m b) vs) ws)))
  ≡ lookup i
      (concatV
         (mapV
           (λ b → mapV
                    (λ d → inject≤
                             (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                             (i*n+k≤m*n b d))
                    ws)
           vs))
lookup-swap m n i =
  let vs = allFin (suc (suc m))
      ws = allFin (suc (suc n)) in 
  begin (lookup
           (lookup i (concatV (mapV (λ b → mapV (transposeIndex m n b) ws) vs)))
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (concatV (mapV (λ b → mapV (transposeIndex n m b) vs) ws)))
         ≡⟨ cong
              (λ x →
                lookup
                  (lookup x (concatV (mapV (λ b → mapV (transposeIndex m n b) ws) vs)))
                  (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
                    (concatV (mapV (λ b → mapV (transposeIndex n m b) vs) ws))))
              (fin-proj-lem (suc (suc m)) (suc (suc n)) i) ⟩
         let (b , d) = fin-project (suc (suc m)) (suc (suc n)) i in
         lookup
           (lookup
             (inject≤
                (fromℕ (toℕ b * suc (suc n) + toℕ d))
                (i*n+k≤m*n b d))
             (concatV (mapV (λ b → mapV (transposeIndex m n b) ws) vs)))
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (concatV (mapV (λ b → mapV (transposeIndex n m b) vs) ws)))
         ≡⟨ cong
               (λ x → let (b , d) = fin-project (suc (suc m)) (suc (suc n)) i in x)
               (lookup-swap-1 m n b d) ⟩ 
         let (b , d) = fin-project (suc (suc m)) (suc (suc n)) i in
         lookup
          (inject≤
            (fromℕ (toℕ b * suc (suc n) + toℕ d))
            (i*n+k≤m*n b d))
           (concatV
             (mapV
               (λ b → mapV
                        (λ d → inject≤
                                 (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                                 (i*n+k≤m*n b d))
                        ws)
               vs))
         ≡⟨ cong
              (λ x →
                lookup x
                  (concatV
                    (mapV
                      (λ b → mapV
                               (λ d → inject≤
                                        (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                                        (i*n+k≤m*n b d))
                               ws)
                      vs)))
              (sym (fin-proj-lem (suc (suc m)) (suc (suc n)) i)) ⟩
         lookup i
           (concatV
             (mapV
               (λ b → mapV
                        (λ d → inject≤
                                 (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                                 (i*n+k≤m*n b d))
                        ws)
               vs)) ∎)
  where open ≡-Reasoning
--}

{--
tabulate-lookup-concat : (m n : ℕ) →
  let vec = (λ m n f → 
                concatV
                  (mapV
                    (λ b → mapV (f m n b) (allFin (suc (suc n))))
                    (allFin (suc (suc m))))) in 
  tabulate {suc (suc m) * suc (suc n)} (λ i →
    lookup
      (lookup i (vec m n transposeIndex))
      (subst Cauchy (*-comm (suc (suc n)) (suc (suc m))) (vec n m transposeIndex)))
  ≡
  vec m n (λ m n b d → inject≤
                         (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                         (i*n+k≤m*n b d))
tabulate-lookup-concat m n = 
  let vec = (λ m n f → 
                concatV
                  (mapV
                    (λ b → mapV (f m n b) (allFin (suc (suc n))))
                    (allFin (suc (suc m))))) in 
  begin (tabulate {suc (suc m) * suc (suc n)} (λ i →
           lookup
             (lookup i (vec m n transposeIndex))
             (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
               (vec n m transposeIndex)))
         ≡⟨ finext _ _ (λ i → lookup-swap m n i) ⟩ 
         tabulate {suc (suc m) * suc (suc n)} (λ i →
           lookup i (vec m n (λ m n b d →
                               inject≤
                                 (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                                 (i*n+k≤m*n b d))))
         ≡⟨ tabulate∘lookup (vec m n (λ m n b d →
                                       inject≤
                                         (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                                         (i*n+k≤m*n b d)))  ⟩
         vec m n (λ m n b d → inject≤
                                (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                                (i*n+k≤m*n b d)) ∎)
  where open ≡-Reasoning
--}

{--
swap⋆idemp : (m n : ℕ) → 
  scompcauchy 
    (swap⋆cauchy m n) 
    (subst Cauchy (*-comm n m) (swap⋆cauchy n m))
  ≡ 
  allFin (m * n)
swap⋆idemp 0 n = refl
swap⋆idemp 1 0 = refl
swap⋆idemp 1 1 = refl
swap⋆idemp 1 (suc (suc n)) =
  begin (scompcauchy
           (subst Cauchy (sym (+-right-identity (suc (suc n))))
             (allFin (suc (suc n))))
           (subst Cauchy (*-comm (suc (suc n)) 1)
             (subst Cauchy (sym (i*1≡i (suc (suc n)))) (allFin (suc (suc n)))))
         ≡⟨ cong₂ (λ x y → scompcauchy x (subst Cauchy (*-comm (suc (suc n)) 1) y))
              (subst-allFin (sym (+-right-identity (suc (suc n)))))
              (subst-allFin (sym (i*1≡i (suc (suc n))))) ⟩ 
         scompcauchy
           (allFin (suc (suc n) + 0))
           (subst Cauchy (*-comm (suc (suc n)) 1) (allFin (suc (suc n) * 1)))
         ≡⟨ cong (scompcauchy (allFin (suc (suc n) + 0)))
              (subst-allFin (*-comm (suc (suc n)) 1)) ⟩ 
         scompcauchy
           (allFin (suc (suc n) + 0))
           (allFin (1 * suc (suc n)))
         ≡⟨ scomplid (allFin (suc (suc n) + 0)) ⟩
         allFin (1 * suc (suc n)) ∎)
  where open ≡-Reasoning
swap⋆idemp (suc (suc m)) 0 =
  begin (scompcauchy
           (subst Cauchy (sym (*-right-zero (suc (suc m)))) (allFin 0))
           (subst Cauchy (*-comm 0 (suc (suc m))) (allFin 0))
         ≡⟨ cong₂ scompcauchy
              (subst-allFin (sym (*-right-zero (suc (suc m)))))
              (subst-allFin (*-comm 0 (suc (suc m)))) ⟩ 
         scompcauchy
           (allFin (suc (suc m) * 0))
           (allFin (suc (suc m) * 0))
         ≡⟨ scomplid (allFin (suc (suc m) * 0)) ⟩ 
         allFin (suc (suc m) * 0) ∎)
  where open ≡-Reasoning
swap⋆idemp (suc (suc m)) 1 =
  begin (scompcauchy
         (subst Cauchy (sym (i*1≡i (suc (suc m)))) (idcauchy (suc (suc m))))
         (subst Cauchy (*-comm 1 (suc (suc m)))
           (subst Cauchy (sym (+-right-identity (suc (suc m))))
             (idcauchy (suc (suc m)))))
           ≡⟨ cong₂ 
                (λ x y → scompcauchy x (subst Cauchy (*-comm 1 (suc (suc m))) y))
                (subst-allFin (sym (i*1≡i (suc (suc m)))))
                (subst-allFin (sym (+-right-identity (suc (suc m))))) ⟩ 
         scompcauchy
           (allFin (suc (suc m) * 1))
           (subst Cauchy (*-comm 1 (suc (suc m))) (allFin (suc (suc m) + 0)))
           ≡⟨ cong (scompcauchy (allFin (suc (suc m) * 1)))
                 (subst-allFin (*-comm 1 (suc (suc m)))) ⟩ 
         scompcauchy
           (allFin (suc (suc m) * 1))
           (allFin (suc (suc m) * 1))
           ≡⟨ scomplid (allFin (suc (suc m) * 1)) ⟩ 
         allFin (suc (suc m) * 1) ∎)
  where open ≡-Reasoning
swap⋆idemp (suc (suc m)) (suc (suc n)) =
  begin (scompcauchy
           (swap⋆cauchy (suc (suc m)) (suc (suc n)))
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (swap⋆cauchy (suc (suc n)) (suc (suc m))))
         ≡⟨ refl ⟩
         scompcauchy
           (concatV 
             (mapV 
               (λ b → mapV (λ d → transposeIndex m n b d) (allFin (suc (suc n))))
               (allFin (suc (suc m)))))
           (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
             (concatV 
               (mapV 
                 (λ d → mapV (λ b → transposeIndex n m d b) (allFin (suc (suc m))))
                 (allFin (suc (suc n))))))
         ≡⟨ refl ⟩ 
           tabulate {suc (suc m) * suc (suc n)} (λ i →
             lookup
               (lookup i
                 (concatV 
                   (mapV 
                     (λ b →
                       mapV
                         (λ d → transposeIndex m n b d)
                         (allFin (suc (suc n))))
                     (allFin (suc (suc m))))))
               (subst Cauchy (*-comm (suc (suc n)) (suc (suc m)))
                 (concatV 
                   (mapV 
                     (λ d →
                       mapV
                         (λ b → transposeIndex n m d b)
                         (allFin (suc (suc m))))
                     (allFin (suc (suc n)))))))
         ≡⟨ tabulate-lookup-concat m n ⟩ 
          concatV 
            (mapV 
              (λ b → 
                mapV
                  (λ d → inject≤
                           (fromℕ (toℕ b * (suc (suc n)) + toℕ d))
                           (i*n+k≤m*n b d))
                  (allFin (suc (suc n))))
              (allFin (suc (suc m))))
         ≡⟨ sym (allFin* (suc (suc m)) (suc (suc n))) ⟩
         allFin (suc (suc m) * suc (suc n)) ∎)
  where open ≡-Reasoning
--}

{--
-- The type Cauchy is too weak to allow us to invert it to combinators

cauchy2c : {t₁ t₂ : U} → (size t₁ ≡ size t₂) → Cauchy (size t₁) → (t₁ ⟷ t₂)
cauchy2c {ZERO} {ONE} () π
cauchy2c {ZERO} {BOOL} () π
cauchy2c {ONE} {ZERO} () π
cauchy2c {ONE} {BOOL} () π
cauchy2c {BOOL} {ZERO} () π
cauchy2c {BOOL} {ONE} () π
cauchy2c {ZERO} {ZERO} refl [] = id⟷
cauchy2c {ONE} {ONE} sp π = id⟷
cauchy2c {ZERO} {PLUS t₂ t₃} sp π = {!!}
cauchy2c {ZERO} {TIMES t₂ t₃} sp π = {!!}
cauchy2c {ONE} {PLUS t₂ t₃} sp π = {!!}
cauchy2c {ONE} {TIMES t₂ t₃} sp π = {!!}
cauchy2c {PLUS t₁ t₂} {ZERO} sp π = {!!}
cauchy2c {PLUS t₁ t₂} {ONE} sp π = {!!}
cauchy2c {PLUS t₁ t₂} {PLUS t₃ t₄} sp π = {!!}
cauchy2c {PLUS t₁ t₂} {TIMES t₃ t₄} sp π = {!!}
cauchy2c {PLUS t₁ t₂} {BOOL} sp π = {!!}
cauchy2c {TIMES t₁ t₂} {ZERO} sp π = {!!}
cauchy2c {TIMES t₁ t₂} {ONE} sp π = {!!}
cauchy2c {TIMES t₁ t₂} {PLUS t₃ t₄} sp π = {!!}
cauchy2c {TIMES t₁ t₂} {TIMES t₃ t₄} sp π = {!!}
cauchy2c {TIMES t₁ t₂} {BOOL} sp π = {!!}
cauchy2c {BOOL} {PLUS t₂ t₃} sp π = {!!}
cauchy2c {BOOL} {TIMES t₂ t₃} sp π = {!!}
-- LOOK HERE 
cauchy2c {BOOL} {BOOL} refl (zero ∷ zero ∷ []) = {!!} -- ILLEGAL
cauchy2c {BOOL} {BOOL} refl (zero ∷ suc zero ∷ []) = id⟷
cauchy2c {BOOL} {BOOL} refl (zero ∷ suc (suc ()) ∷ [])
cauchy2c {BOOL} {BOOL} refl (suc zero ∷ zero ∷ []) = NOT
cauchy2c {BOOL} {BOOL} refl (suc zero ∷ suc zero ∷ []) = {!!} --ILLEGAL
cauchy2c {BOOL} {BOOL} refl (suc zero ∷ suc (suc ()) ∷ [])
cauchy2c {BOOL} {BOOL} refl (suc (suc ()) ∷ b ∷ []) 
--}

-- A view of (t : U) as normalized types
-- Normalized types are (1 + (1 + (1 + (1 + ... 0))))

data NormalU : Set where
  NZERO : NormalU
  NSUC  : NormalU → NormalU

fromNormalU : NormalU → U
fromNormalU NZERO = ZERO
fromNormalU (NSUC n) = PLUS ONE (fromNormalU n)

normalU+ : NormalU → NormalU → NormalU
normalU+ NZERO n₂ = n₂
normalU+ (NSUC n₁) n₂ = NSUC (normalU+ n₁ n₂)

normalU⋆ : NormalU → NormalU → NormalU
normalU⋆ NZERO n₂ = NZERO
normalU⋆ (NSUC n₁) n₂ = normalU+ n₂ (normalU⋆ n₁ n₂)

normalU : U → NormalU
normalU ZERO = NZERO
normalU ONE = NSUC NZERO
normalU BOOL = NSUC (NSUC NZERO)
normalU (PLUS t₁ t₂) = normalU+ (normalU t₁) (normalU t₂)
normalU (TIMES t₁ t₂) = normalU⋆ (normalU t₁) (normalU t₂)

data Normalized : (t : NormalU) → Set where
  nzero : Normalized NZERO
  nsuc  : {t : NormalU} → Normalized t → Normalized (NSUC t)

normalized+ : (n₁ n₂ : NormalU) →
  Normalized n₁ → Normalized n₂ → Normalized (normalU+ n₁ n₂)
normalized+ NZERO n₂ nd₁ nd₂ = nd₂
normalized+ (NSUC n₁) n₂ (nsuc nd₁) nd₂ = nsuc (normalized+ n₁ n₂ nd₁ nd₂)

normalized⋆ : (n₁ n₂ : NormalU) →
  Normalized n₁ → Normalized n₂ → Normalized (normalU⋆ n₁ n₂)
normalized⋆ NZERO n₂ nzero nd₂ = nzero
normalized⋆ (NSUC n₁) n₂ (nsuc nd₁) nd₂ =
  normalized+ n₂ (normalU⋆ n₁ n₂) nd₂ (normalized⋆ n₁ n₂ nd₁ nd₂)

normalized : (t : U) → Normalized (normalU t)
normalized ZERO = nzero
normalized ONE = nsuc nzero
normalized BOOL = nsuc (nsuc nzero) 
normalized (PLUS t₁ t₂) =
  normalized+ (normalU t₁) (normalU t₂) (normalized t₁) (normalized t₂)
normalized (TIMES t₁ t₂) =
  normalized⋆ (normalU t₁) (normalU t₂) (normalized t₁) (normalized t₂)

assocr : (n₁ n₂ : NormalU) → 
  PLUS (fromNormalU n₁) (fromNormalU n₂) ⟷ fromNormalU (normalU+ n₁ n₂)
assocr NZERO n₂ = unite₊
assocr (NSUC n₁) n₂ = assocr₊ ◎ (id⟷ ⊕ assocr n₁ n₂)

distr : (n₁ n₂ : NormalU) →
  TIMES (fromNormalU n₁) (fromNormalU n₂) ⟷ fromNormalU (normalU⋆ n₁ n₂)
distr NZERO n₂ = distz
distr (NSUC n₁) n₂ = dist ◎ (unite⋆ ⊕ distr n₁ n₂) ◎ assocr n₂ (normalU⋆ n₁ n₂)

canonicalU : U → U
canonicalU = fromNormalU ∘ normalU

normalizeC : (t : U) → t ⟷ canonicalU t
normalizeC ZERO = id⟷
normalizeC ONE = uniti₊ ◎ swap₊
normalizeC BOOL = unfoldBool ◎
                 ((uniti₊ ◎ swap₊) ⊕ (uniti₊ ◎ swap₊)) ◎
                 (assocr₊ ◎ (id⟷ ⊕ unite₊))
normalizeC (PLUS t₀ t₁) =
  (normalizeC t₀ ⊕ normalizeC t₁) ◎ assocr (normalU t₀) (normalU t₁) 
normalizeC (TIMES t₀ t₁) =
  (normalizeC t₀ ⊗ normalizeC t₁) ◎ distr (normalU t₀) (normalU t₁) 

fin+ : {m n : ℕ} → Fin m → Fin n → Fin (m + n)
fin+ {0} {n} () _
fin+ {suc m} {n} zero b = inject≤ b (n≤m+n (suc m) n)
fin+ {suc m} {n} (suc a) b = suc (fin+ {m} {n} a b)

fin* : {m n : ℕ} → Fin m → Fin n → Fin (m * n)
fin* {0} {n} () _
fin* {suc m} {0} zero ()
fin* {suc m} {suc n} zero b = zero  
fin* {suc m} {n} (suc a) b = fin+ b (fin* a b) 

