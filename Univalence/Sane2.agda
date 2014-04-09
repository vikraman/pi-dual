{- This is a copy of Sane, but building upon a rather different notion of permutation -}
module Sane2 where

import Data.Fin as F
--
open import Data.Unit
open import Data.Nat using (ℕ ; zero ; suc ; _+_ ; _>_ )
open import Data.Sum using (inj₁ ; inj₂ ; _⊎_)
open import Data.Vec
open import Function using ( id ) renaming (_∘_ to _○_) 
open import Relation.Binary  -- to make certain goals look nicer
open import Relation.Binary.PropositionalEquality using ( _≡_ ; refl ; sym ; cong ; trans ; subst ; module ≡-Reasoning )
open ≡-Reasoning

-- start re-splitting things up, as this is getting out of hand
open import FT -- Finite Types
open import VecHelpers
open import NatSimple
open import Eval
open import Permutations

open import CombPerm
 
-- Suppose we have some combinator c, its output vector v, and the corresponding
-- permutation p. We construct p by looking at how many places each element is
-- displaced from its index in v *to the right* (if it's where it "should" be or
-- to the left, just return 0).

-- In other words, if v[i] = j, then p[j] = j - i. That is, if j is in location
-- i, j - i is how many spaces to the right (if any) j appears from its own
-- index. Note that if v[i] = j, then c(i) = j, and inv(c)(j) = i. This suggests
-- that if I can write a tabulate function for permutations, the permutation for
-- a combinator c will be "tabulate (∩ -> i - (evalCombB c i))", modulo type
-- coercions.
--
-- JC: I think an even easier way is to use LeftCancellation and build it
--    recursively!  By this I mean something which gives a
--    (fromℕ n ⇛ fromℕ n) given a (fromℕ (suc n) ⇛ fromℕ (suc n))
combToPerm : {n : ℕ} → (fromℕ n ⇛ fromℕ n) → Permutation n
combToPerm {zero} c = []
combToPerm {suc n} c = valToFin (evalComb c (inj₁ tt)) ∷ {!!}

swapUpCorrect : {n : ℕ} → (i : F.Fin n) → (j : F.Fin (1 + n)) →
                evalComb (swapUpTo i) (finToVal j) ≡ finToVal (evalPerm (swapUpToPerm i) j)
swapUpCorrect {zero} () j
swapUpCorrect {suc zero} F.zero F.zero = refl
swapUpCorrect {suc zero} F.zero (F.suc F.zero) = refl
swapUpCorrect {suc zero} F.zero (F.suc (F.suc ()))
swapUpCorrect {suc zero} (F.suc ()) j
swapUpCorrect {suc (suc n)} F.zero j = cong finToVal (
  begin
    j                            ≡⟨ sym (lookupTab {f = id} j) ⟩
    lookup j (tabulate id)       ≡⟨ cong (λ x → lookup j (F.zero ∷ F.suc F.zero ∷ F.suc (F.suc F.zero) ∷ x)) (sym (idP-id (tabulate (F.suc ○ F.suc ○ F.suc)))) ⟩
    evalPerm (swapUpToPerm F.zero) j ∎ )
swapUpCorrect {suc (suc n)} (F.suc i) F.zero = refl
swapUpCorrect {suc (suc n)} (F.suc i) (F.suc j) = 
  begin
    evalComb (assocl₊⇛ ◎ (swap₊⇛ ⊕ id⇛) ◎ assocr₊⇛) (inj₂ (evalComb (swapUpTo i) (finToVal j)))
         ≡⟨ cong (λ x → evalComb (assocl₊⇛ ◎ (swap₊⇛ ⊕ id⇛) ◎ assocr₊⇛) (inj₂ x)) (swapUpCorrect i j) ⟩
    evalComb (assocl₊⇛ ◎ (swap₊⇛ ⊕ id⇛) ◎ assocr₊⇛) (inj₂ (finToVal (evalPerm (swapUpToPerm i) j)))
         ≡⟨ swapi≡swap01 (F.suc (evalPerm (swapUpToPerm i) j)) ⟩
    finToVal (evalPerm (swap01 (suc (suc (suc n)))) (F.suc (evalPerm (swapUpToPerm i) j)))
         ≡⟨ cong finToVal ( begin
             evalPerm (swap01 (suc (suc (suc n)))) (F.suc (evalPerm (swapUpToPerm i) j))
                 ≡⟨ cong (λ x → evalPerm (swap01 (suc (suc (suc n)))) (F.suc (lookup j x))) (swapUpToAct i (tabulate id)) ⟩
             lookup
                (F.suc (lookup j (insert (tabulate (λ z → F.suc z)) (F.inject₁ i) F.zero)))
                (F.suc F.zero ∷ F.zero ∷ F.suc (F.suc F.zero) ∷ permute idP (tabulate (λ z → F.suc (F.suc (F.suc z)))))
                  ≡⟨ cong (λ x → (lookup
                    (F.suc
                     (lookup j
                      (insert (tabulate F.suc) (F.inject₁ i) F.zero)))
                      (F.suc F.zero ∷ F.zero ∷ F.suc (F.suc F.zero) ∷ x)))
                    (idP-id _) ⟩
             (swap01vec !! 
                 (F.suc ((insert (tabulate F.suc) (F.inject₁ i) F.zero) !! j)))
                  ≡⟨ cong (λ x → swap01vec !! x) (sym (map!! F.suc _ j)) ⟩
             (swap01vec !! 
                 (vmap F.suc (insert (tabulate F.suc) (F.inject₁ i) F.zero) !! j))
                  ≡⟨ sym (lookupTab {f = (λ j → 
                       (swap01vec !! 
                          (vmap F.suc (insert (tabulate F.suc) (F.inject₁ i) F.zero) !! j)))} j) ⟩
             (tabulate (λ k → (swap01vec !! 
                 (vmap F.suc (insert (tabulate F.suc) (F.inject₁ i) F.zero) !! k))) !! j)
                  ≡⟨ refl ⟩
             (((vmap F.suc (insert (tabulate F.suc) (F.inject₁ i) F.zero)) ∘̬ swap01vec) !! j)
                  ≡⟨ cong (λ x → x !! j) (∘̬≡∘̬′ _ _) ⟩
             (((vmap F.suc (insert (tabulate F.suc) (F.inject₁ i) F.zero)) ∘̬′ swap01vec) !! j)
                  ≡⟨ cong (λ x →
                       ((vmap F.suc (insert x (F.inject₁ i) F.zero) ∘̬′ swap01vec) !! j))
                       (sym (mapTab F.suc id)) ⟩ 
{-- For reference:
newlemma6 : {m n : ℕ} → (i : F.Fin n) → (v : Vec (F.Fin m) n) →
            (vmap F.suc (insert (vmap F.suc v) (F.inject₁ i) F.zero)) ∘̬′ swap01vec
          ≡ insert (vmap F.suc (vmap F.suc v)) (F.inject₁ i) F.zero
--}          
             (((vmap F.suc (insert (vmap F.suc (tabulate id)) (F.inject₁ i) F.zero)) ∘̬′ swap01vec) !! j)
                 ≡⟨ cong (λ x → x !! j) (newlemma6 i (tabulate id)) ⟩
             (insert (vmap F.suc (vmap F.suc (tabulate id))) (F.inject₁ i) F.zero !! j)
                 ≡⟨ cong (λ x → insert (vmap F.suc x) (F.inject₁ i) F.zero !! j)
                         (mapTab F.suc id) ⟩
             (insert (vmap F.suc (tabulate F.suc)) (F.inject₁ i) F.zero !! j)
                 ≡⟨ cong (λ x → insert x (F.inject₁ i) F.zero !! j)
                         (mapTab F.suc F.suc) ⟩
             (insert (tabulate (λ x → F.suc (F.suc x))) (F.inject₁ i) F.zero !! j)
                 ≡⟨ cong (λ x → lookup j (insert x (F.inject₁ i) F.zero))
                        (sym (idP-id _)) ⟩
             (lookup j
                 (insert (permute idP (tabulate (λ x → F.suc (F.suc x)))) (F.inject₁ i) F.zero))
                 ≡⟨ refl ⟩
             evalPerm (swapUpToPerm (F.suc i)) (F.suc j)
           ∎ ) ⟩
    finToVal (evalPerm (swapUpToPerm (F.suc i)) (F.suc j))
  ∎ 

swapDownCorrect : {n : ℕ} → (i : F.Fin n) → (j : F.Fin (1 + n)) →
                  evalComb (swapDownFrom i) (finToVal j) ≡
                  finToVal (evalPerm (swapDownFromPerm i) j)
swapDownCorrect F.zero j =
  begin
    evalComb (swapDownFrom F.zero) (finToVal j)
      ≡⟨ refl ⟩
    finToVal j
      ≡⟨ cong finToVal (sym (lookupTab {f = id} j)) ⟩
    finToVal ((tabulate id) !! j)
      ≡⟨ cong (λ x → finToVal (x !! j)) (sym (idP-id (tabulate id))) ⟩
    finToVal (permute idP (tabulate id) !! j)
      ≡⟨ refl ⟩
    finToVal (evalPerm (swapDownFromPerm F.zero) j) ∎
swapDownCorrect (F.suc i) F.zero =
  begin
    evalComb (swapDownFrom (F.suc i)) (finToVal F.zero)
      ≡⟨ refl ⟩
    evalComb (swapi F.zero ◎ (id⇛ ⊕ swapDownFrom i)) (finToVal F.zero)
      ≡⟨ refl ⟩
    evalComb (id⇛ ⊕ swapDownFrom i) (evalComb (swapi F.zero) (finToVal F.zero))
      ≡⟨ refl ⟩
    evalComb (id⇛ ⊕ swapDownFrom i) (finToVal (F.suc F.zero))
      ≡⟨ refl ⟩
    inj₂ (evalComb (swapDownFrom i) (finToVal F.zero))
      ≡⟨ cong inj₂ (swapDownCorrect i F.zero) ⟩
    inj₂ (finToVal (evalPerm (swapDownFromPerm i) F.zero))
      ≡⟨ refl ⟩
    finToVal (F.suc (evalPerm (swapDownFromPerm i) F.zero))
      ≡⟨ refl ⟩ -- beta
    finToVal (F.suc (permute (swapDownFromPerm i) (tabulate id) !! F.zero))
      ≡⟨ cong finToVal (push-f-through F.suc F.zero (swapDownFromPerm i) id ) ⟩
    finToVal (lookup F.zero (permute (swapDownFromPerm i) (tabulate F.suc)))
      ≡⟨ cong finToVal (sym (lookup-insert (permute (swapDownFromPerm i) (tabulate F.suc))))  ⟩
    finToVal (evalPerm (swapDownFromPerm (F.suc i)) F.zero) ∎
swapDownCorrect (F.suc i) (F.suc F.zero) =
  begin
    evalComb (swapDownFrom (F.suc i)) (finToVal (F.suc F.zero))
      ≡⟨ refl ⟩
    evalComb (swapi F.zero ◎ (id⇛ ⊕ swapDownFrom i)) (finToVal (F.suc F.zero))
      ≡⟨ refl ⟩
    evalComb (id⇛ ⊕ swapDownFrom i) (evalComb (swapi F.zero) (finToVal (F.suc F.zero)))
      ≡⟨ refl ⟩
    evalComb (id⇛ ⊕ swapDownFrom i) (inj₁ tt)
      ≡⟨ refl ⟩
    inj₁ tt
      ≡⟨ refl ⟩
    finToVal (F.zero)
      ≡⟨ cong finToVal (sym (lookup-insert′ (F.suc F.zero) (permute (swapDownFromPerm i) (tabulate F.suc)))) ⟩
    finToVal (evalPerm (swapDownFromPerm (F.suc i)) (F.suc F.zero)) ∎
swapDownCorrect (F.suc i) (F.suc (F.suc j)) =
  begin
    evalComb (swapDownFrom (F.suc i)) (finToVal (F.suc (F.suc j)))
      ≡⟨ refl ⟩
    evalComb (swapi F.zero ◎ (id⇛ ⊕ swapDownFrom i)) (finToVal (F.suc (F.suc j)))
      ≡⟨ refl ⟩
    evalComb (id⇛ ⊕ swapDownFrom i) (evalComb (swapi F.zero) (finToVal (F.suc (F.suc j))))
      ≡⟨ refl ⟩
    evalComb (id⇛ ⊕ swapDownFrom i) (finToVal (F.suc (F.suc j)))
      ≡⟨ refl ⟩
    evalComb (id⇛ ⊕ swapDownFrom i) (inj₂ (finToVal (F.suc j)))
      ≡⟨ refl ⟩
    inj₂ (evalComb (swapDownFrom i) (finToVal (F.suc j)))
      ≡⟨ cong inj₂ (swapDownCorrect i (F.suc j)) ⟩
    inj₂ (finToVal (evalPerm (swapDownFromPerm i) (F.suc j)))
      ≡⟨ refl ⟩
    finToVal (F.suc (evalPerm (swapDownFromPerm i) (F.suc j)))
      ≡⟨ cong finToVal (push-f-through F.suc (F.suc j) (swapDownFromPerm i) id) ⟩
      -- need to do a little β-expansion to see this
    finToVal (lookup (F.suc j) (permute (1iP i) (tabulate F.suc)))
      ≡⟨ cong finToVal (lookup-insert′′ j (permute (1iP i) (tabulate F.suc))) ⟩
    finToVal (evalPerm (swapDownFromPerm (F.suc i)) (F.suc (F.suc j))) ∎    
  
swapmCorrect : {n : ℕ} → (i j : F.Fin n) → evalComb (swapm i) (finToVal j) ≡ finToVal (evalPerm (swapmPerm i) j)
swapmCorrect {zero} () _
swapmCorrect {suc n} F.zero j = 
 begin
    finToVal j
      ≡⟨ cong finToVal (sym (lookupTab {f = id} j)) ⟩
    finToVal (lookup j (tabulate id))
      ≡⟨ cong (λ x → finToVal (lookup j x)) (sym (idP-id (tabulate id))) ⟩
    finToVal (lookup j (permute idP (tabulate id)))  ∎
swapmCorrect {suc zero} (F.suc ()) _
swapmCorrect {suc (suc n)} (F.suc i) j = -- requires the breakdown of swapm ?
  begin
    evalComb (swapm (F.suc i)) (finToVal j)
      ≡⟨ refl ⟩
    evalComb (swapDownFrom i ◎ swapi i ◎ swapUpTo i) (finToVal j)
      ≡⟨ refl ⟩
    evalComb (swapUpTo i)
      (evalComb (swapi i)
        (evalComb (swapDownFrom i) (finToVal j)))
      ≡⟨ cong (λ x → evalComb (swapUpTo i) (evalComb (swapi i) x))
           (swapDownCorrect i j) ⟩
    evalComb (swapUpTo i)
      (evalComb (swapi i)
        (finToVal (permute (swapDownFromPerm i) (tabulate id) !! j)))
      ≡⟨ cong (λ x → evalComb (swapUpTo i) x)
           (swapiCorrect i (permute (swapDownFromPerm i) (tabulate id) !! j)) ⟩
    evalComb (swapUpTo i)
      (finToVal
        (permute (swapiPerm i) (tabulate id) !!
          (permute (swapDownFromPerm i) (tabulate id) !! j)))
      ≡⟨ (swapUpCorrect i )
           (permute (swapiPerm i) (tabulate id) !!
             (permute (swapDownFromPerm i) (tabulate id) !! j))⟩
    finToVal
      (permute (swapUpToPerm i) (tabulate id) !!
        (permute (swapiPerm i) (tabulate id) !!
          (permute (swapDownFromPerm i) (tabulate id) !! j)))
      ≡⟨ cong (λ x → finToVal (x !! (permute (swapiPerm i) (tabulate id) !! (permute (swapDownFromPerm i) (tabulate id) !! j)))) (swapUpToAct i (tabulate id)) ⟩
    finToVal
       (insert (tabulate F.suc) (F.inject₁ i) F.zero !!
         (permute (swapiPerm i) (tabulate id) !!
           (permute (swapDownFromPerm i) (tabulate id) !! j)))
      ≡⟨ cong (λ z → finToVal (insert (tabulate F.suc) (F.inject₁ i) F.zero !! (z !! (permute (swapDownFromPerm i) (tabulate id) !! j)))) (swapiAct i (tabulate id)) ⟩
    finToVal
       (insert (tabulate F.suc) (F.inject₁ i) F.zero !!
         (insert (remove (F.inject₁ i) (tabulate id)) (F.suc i) ((tabulate id) !! (F.inject₁ i)) !!
           (permute (swapDownFromPerm i) (tabulate id) !! j)))
      ≡⟨ cong (λ z → finToVal (insert (tabulate F.suc) (F.inject₁ i) F.zero !!
         (insert (remove (F.inject₁ i) (tabulate id)) (F.suc i) ((tabulate id) !! (F.inject₁ i)) !!
           (z !! j)))) (swapDownFromAct i (tabulate id)) ⟩
    finToVal
       (insert (tabulate F.suc) (F.inject₁ i) F.zero !!
         (insert (remove (F.inject₁ i) (tabulate id)) (F.suc i) ((tabulate id) !! (F.inject₁ i)) !!
           ( swapDownFromVec (F.inject₁ i) (tabulate id) !! j)))
      ≡⟨ cong (λ z →  finToVal
       (insert (tabulate F.suc) (F.inject₁ i) F.zero !!
         (insert (remove (F.inject₁ i) (tabulate id)) (F.suc i) z !!
           ( swapDownFromVec (F.inject₁ i) (tabulate id) !! j)))) (lookupTab {f = id} (F.inject₁ i)) ⟩
     finToVal
       (insert (tabulate F.suc) (F.inject₁ i) F.zero !!
         (insert (remove (F.inject₁ i) (tabulate id)) (F.suc i) (F.inject₁ i) !!
           ( swapDownFromVec (F.inject₁ i) (tabulate id) !! j)))
      ≡⟨ refl ⟩
    finToVal
       (insert (tabulate F.suc) (F.inject₁ i) F.zero !!
         (insert (remove (F.inject₁ i) (tabulate id)) (F.suc i) (F.inject₁ i) !!
           ( (((tabulate id) !! (F.inject₁ i)) ∷ (remove (F.inject₁ i) (tabulate id))) !! j)))
      ≡⟨ {!!} ⟩
    finToVal (evalPerm (swapmPerm (F.suc i)) j) ∎

lemma1 : {n : ℕ} (p : Permutation n) → (i : F.Fin n) → 
    evalComb (permToComb p) (finToVal i) ≡ finToVal (evalPerm p i)
lemma1 {zero} [] ()
lemma1 {suc n} (F.zero ∷ p) F.zero = refl
lemma1 {suc zero} (F.zero ∷ p) (F.suc ())
lemma1 {suc (suc n)} (F.zero ∷ p) (F.suc i) = begin
    inj₂ (evalComb (permToComb p) (finToVal i))
         ≡⟨ cong inj₂ (lemma1 p i) ⟩
     inj₂ (finToVal (evalPerm p i)) 
         ≡⟨ refl ⟩
      finToVal (F.suc (evalPerm p i))
         ≡⟨ cong finToVal (push-f-through F.suc i p id) ⟩ 
      finToVal (evalPerm (F.zero ∷ p) (F.suc i)) ∎
lemma1 {suc n} (F.suc j ∷ p) i = {!!} -- needs all the previous ones first.

swapmCorrect2 : {n : ℕ} → (i j : F.Fin n) → evalComb (swapm i) (finToVal j) ≡ finToVal (evalPerm (swapmPerm i) j)
swapmCorrect2 {zero} () _
swapmCorrect2 {suc zero} F.zero F.zero = refl
swapmCorrect2 {suc zero} F.zero (F.suc ())
swapmCorrect2 {suc zero} (F.suc ()) _
swapmCorrect2 {suc (suc n)} F.zero j = sym (
    trans (cong (λ x → finToVal (lookup j (F.zero ∷ F.suc F.zero ∷ x))) (idP-id (tabulate (F.suc ○ F.suc))))
          (cong finToVal (lookupTab {f = id} j)))
swapmCorrect2 {suc (suc n)} (F.suc F.zero) F.zero = refl
swapmCorrect2 {suc (suc n)} (F.suc (F.suc i)) F.zero = 
  let up = λ x → evalComb (swapUpTo (F.suc i)) x
      swap = λ x → evalComb (swapi (F.suc i)) x
      down = λ x → evalComb (swapDownFrom (F.suc i)) x in
  begin
    evalComb (swapm (F.suc (F.suc i))) (inj₁ tt)
        ≡⟨ refl ⟩
    evalComb (swapDownFrom (F.suc i) ◎ swapi (F.suc i) ◎ swapUpTo (F.suc i)) (inj₁ tt)
        ≡⟨ refl ⟩
    up (swap (down (inj₁ tt)))
        ≡⟨ cong (up ○ swap) (swapDownCorrect (F.suc i) F.zero) ⟩
    up (swap ( finToVal (evalPerm (swapDownFromPerm (F.suc i)) F.zero) ))
        ≡⟨ refl ⟩
    up (swap (finToVal (permute (swapDownFromPerm (F.suc i)) (tabulate id) !! F.zero)))
        ≡⟨ cong (λ x → up (swap (finToVal (x !! F.zero )))) (swapDownFromAct (F.suc i) (tabulate id)) ⟩
    up (swap (finToVal (swapDownFromVec (F.inject₁ (F.suc i)) (tabulate id) !! F.zero)))
        ≡⟨ refl ⟩
    up (swap (finToVal ( (((tabulate id) !! (F.inject₁ (F.suc i))) ∷ remove (F.inject₁ (F.suc i)) (tabulate id)) !! F.zero )))
        ≡⟨ refl ⟩
    up (swap (finToVal ((tabulate id) !! (F.inject₁ (F.suc i)))))
        ≡⟨ cong (up ○ swap ○ finToVal) (lookupTab {f = id} (F.inject₁ (F.suc i))) ⟩
    up (swap (finToVal (F.inject₁ (F.suc i))))
        ≡⟨ {!!} ⟩
    finToVal (evalPerm (swapmPerm (F.suc (F.suc i))) F.zero)
  ∎
swapmCorrect2 {suc (suc n)} (F.suc F.zero) (F.suc j) = 
  begin
    evalComb (swapi F.zero) (inj₂ (finToVal j))
      ≡⟨ swapi≡swap01 (F.suc j) ⟩
    finToVal
      (lookup j
       (F.zero ∷ permute idP (tabulate (λ z → F.suc (F.suc z)))))
      ≡⟨ refl ⟩
    finToVal (permute (F.suc F.zero ∷ idP) (tabulate id) !! (F.suc j))
  ∎
swapmCorrect2 {suc (suc n)} (F.suc (F.suc i)) (F.suc j) = {!!}

{-
-- this alternate version of lemma1 might, in the long term, but a better
-- way to go?
lemma1′ : {n : ℕ} → (i : F.Fin n) → vmap (evalComb (swapm i)) (tabulate finToVal) ≡ vmap finToVal (permute (swapmPerm i) (tabulate id))
lemma1′ {zero} ()
lemma1′ {suc n} F.zero = cong (_∷_ (inj₁ tt)) (
  begin
    vmap id (tabulate (inj₂ ○ finToVal))
               ≡⟨ mapTab id (inj₂ ○ finToVal) ⟩
    tabulate (inj₂ ○ finToVal)
               ≡⟨ cong tabulate refl ⟩
    tabulate (finToVal ○ F.suc)
               ≡⟨ sym (mapTab finToVal F.suc) ⟩
    vmap finToVal (tabulate F.suc)
               ≡⟨ cong (vmap finToVal) (sym (idP-id _)) ⟩
    vmap finToVal (permute idP (tabulate F.suc))
  ∎ )
lemma1′ {suc n} (F.suc i) = 
  begin
    vmap (evalComb (swapm (F.suc i))) (tabulate finToVal)
        ≡⟨ refl ⟩
    evalComb (swapm (F.suc i)) (inj₁ tt) ∷ vmap (evalComb (swapm (F.suc i))) (tabulate (inj₂ ○ finToVal))
       ≡⟨ cong (λ x → x ∷ vmap (evalComb (swapm (F.suc i))) (tabulate (inj₂ ○ finToVal))) (swapmCorrect {suc n} (F.suc i) F.zero) ⟩
    (finToVal (evalPerm (swapmPerm (F.suc i)) F.zero)) ∷ vmap (evalComb (swapm (F.suc i))) (tabulate (inj₂ ○ finToVal))
       ≡⟨ cong (λ x → (finToVal (evalPerm (swapmPerm (F.suc i)) F.zero)) ∷ x ) {!!} ⟩ -- need to generalize the inductive hyp. for this to work
    {!!}
       ≡⟨ {!!} ⟩
    vmap finToVal (insert (permute (swapOne i) (tabulate F.suc)) (F.suc i) F.zero)
  ∎
 
lemma2 : {n : ℕ} (c : (fromℕ n) ⇛ (fromℕ n)) → (i : F.Fin n) → 
    (evalComb c (finToVal i)) ≡ finToVal (evalPerm (combToPerm c) i)
lemma2 c i = {!!}
-}
