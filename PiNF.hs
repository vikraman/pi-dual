{-# OPTIONS_GHC -XGADTs -XTypeOperators -XEmptyDataDecls #-}

-- Pi with negative and fractional types

module PiNF where

-----------------------------------------------------------------------
-- Morphisms for symmetric monoidal structure extended with trace

data Zero 
data Minus a = Minus a
data Recip a = Recip a

absurd :: Zero -> a
absurd _ = undefined

data a :<=> b where 
-- (+) is associative, commutative, and has a unit
  PlusZeroL   :: Either Zero a :<=> a
  PlusZeroR   :: a :<=> Either Zero a
  CommutePlus :: Either a b :<=> Either b a
  AssocPlusL  :: Either a (Either b c) :<=> Either (Either a b) c 
  AssocPlusR  :: Either (Either a b) c :<=> Either a (Either b c) 
-- (*) is associative, commutative, and has a unit
  TimesOneL    :: ((), a) :<=> a
  TimesOneR    :: a :<=> ((), a)
  CommuteTimes :: (a,b) :<=> (b,a) 
  AssocTimesL  :: (a,(b,c)) :<=> ((a,b),c)
  AssocTimesR  :: ((a,b),c) :<=> (a,(b,c))
-- (*) distributes over (+) 
  TimesZeroL  :: (Zero, a) :<=> Zero
  TimesZeroR  :: Zero :<=> (Zero, a)
  Distribute  :: (Either b c, a) :<=> Either (b, a) (c, a)
  Factor      :: Either (b, a) (c, a) :<=> (Either b c, a)
-- Congruence
  Id    :: a :<=> a
  Sym   :: (a :<=> b) -> (b :<=> a) 
  (:.:) :: (b :<=> c) -> (a :<=> b) -> (a :<=> c)
  (:+:) :: (a :<=> b) -> (c :<=> d) -> (Either a c :<=> Either b d)
  (:*:) :: (a :<=> b) -> (c :<=> d) -> ((a,c) :<=> (b,d))
-- Trace
  Trace :: (Either c a :<=> Either c b) -> (a :<=> b) 
-- Bools
  FoldB   :: Either () () :<=> Bool
  UnfoldB :: Bool :<=> Either () ()
-- Ints
  FoldI :: Either () Int :<=> Int
  UnfoldI :: Int :<=> Either () Int
-- Lists
  FoldL :: Either () (a,[a]) :<=> [a]
  UnfoldL :: [a] :<=> Either () (a,[a])
-- Negative types
  EtaPlus :: Zero :<=> Either a (Minus a)
  EpsilonPlus :: Either a (Minus a) :<=> Zero
-- Fractional types
  EtaTimes :: () :<=> (a, Recip a) 
  EpsilonTimes :: (a, Recip a) :<=> ()

instance Show (a :<=> b) where
  show PlusZeroL = "PlusZeroL"
  show PlusZeroR = "PlusZeroR"
  show CommutePlus = "CommutePlus"
  show AssocPlusL = "AssocPlusL"
  show AssocPlusR = "AssocPlusR"
  show TimesOneL = "TimesOneL"
  show TimesOneR = "TimesOneR"
  show CommuteTimes = "CommuteTimes"
  show AssocTimesL = "AssocTimesL"
  show AssocTimesR = "AssocTimesR"
  show TimesZeroL = "TimesZeroL"
  show TimesZeroR = "TimesZeroR"
  show Distribute = "Distribute"
  show Factor = "Factor"
  show Id = "Id"
  show (Sym c) = "(Sym " ++ show c ++ ")" 
  show (c1 :.: c2) = "(" ++ show c1 ++ " . " ++ show c2 ++ ")"
  show (c1 :+: c2) = "(" ++ show c1 ++ " + " ++ show c2 ++ ")"
  show (c1 :*: c2) = "(" ++ show c1 ++ " * " ++ show c2 ++ ")"
  show (Trace c) = "(Trace " ++ show c ++ ")"
  show FoldB = "FoldB"
  show UnfoldB = "UnfoldB"
  show FoldI = "FoldI"
  show UnfoldI = "UnfoldI"
  show FoldL = "FoldL"
  show UnfoldL = "UnfoldL"
  show EtaPlus = "eta+"
  show EpsilonPlus = "epsilon+"
  show EtaTimes = "eta*"
  show EpsilonTimes = "epsilon*"

-- Adjoint

adjoint :: (a :<=> b) -> (b :<=> a)
adjoint PlusZeroL = PlusZeroR
adjoint PlusZeroR = PlusZeroL
adjoint CommutePlus = CommutePlus
adjoint AssocPlusL = AssocPlusR
adjoint AssocPlusR = AssocPlusL
adjoint TimesOneL = TimesOneR
adjoint TimesOneR = TimesOneL
adjoint CommuteTimes = CommuteTimes
adjoint AssocTimesL = AssocTimesR
adjoint AssocTimesR = AssocTimesL
adjoint TimesZeroL = TimesZeroR
adjoint TimesZeroR = TimesZeroL
adjoint Distribute = Factor
adjoint Factor = Distribute
adjoint Id = Id
adjoint (Sym f) = f 
adjoint (f :.: g) = adjoint g :.: adjoint f
adjoint (f :+: g) = adjoint f :+: adjoint g
adjoint (f :*: g) = adjoint f :*: adjoint g
adjoint (Trace f) = Trace (adjoint f) 
adjoint FoldB = UnfoldB
adjoint UnfoldB = FoldB
adjoint FoldI = UnfoldI
adjoint UnfoldI = FoldI
adjoint FoldL = UnfoldL
adjoint UnfoldL = FoldL
adjoint EtaPlus = EpsilonPlus
adjoint EpsilonPlus = EtaPlus
adjoint EtaTimes = EpsilonTimes
adjoint EpsilonTimes = EtaTimes

-- Semantics
-- forward

(@@>) :: (a :<=> b) -> a -> b
PlusZeroL @@> (Left z) = absurd z
PlusZeroL @@> (Right a) = a
PlusZeroR @@> a = Right a
CommutePlus @@> (Left a) = Right a
CommutePlus @@> (Right b) = Left b 
AssocPlusL @@> (Left a) = Left (Left a) 
AssocPlusL @@> (Right (Left b)) = Left (Right b) 
AssocPlusL @@> (Right (Right c)) = Right c
AssocPlusR @@> (Left (Left a)) = Left a
AssocPlusR @@> (Left (Right b)) = Right (Left b)
AssocPlusR @@> (Right c) = Right (Right c)
TimesOneL @@> ((), a) = a
TimesOneR @@> a = ((), a)
CommuteTimes @@> (a,b) = (b,a) 
AssocTimesL @@> (a,(b,c)) = ((a,b),c) 
AssocTimesR @@> ((a,b),c)  = (a,(b,c))
Distribute @@> (Left b, a) = Left (b, a) 
Distribute @@> (Right c, a) = Right (c, a) 
Factor @@> (Left (b, a)) = (Left b, a) 
Factor @@> (Right (c, a)) = (Right c, a) 
Id @@> a = a
(Sym f) @@> b = (adjoint f) @@> b
(f :.: g) @@> a = f @@> (g @@> a)
(f :+: g) @@> (Left a) = Left (f @@> a) 
(f :+: g) @@> (Right b) = Right (g @@> b) 
(f :*: g) @@> (a,b) = (f @@> a, g @@> b) 
(Trace f) @@> a = loop (f @@> (Right a))
  where loop (Right a) = a
        loop (Left c) = loop (f @@> (Left c))
FoldB @@> (Left ()) = True
FoldB @@> (Right ()) = False
UnfoldB @@> True = Left ()
UnfoldB @@> False = Right () 
FoldI @@> (Left ()) = 0
FoldI @@> (Right n) = n+1
UnfoldI @@> 0 = Left ()
UnfoldI @@> n = Right (n-1) 
FoldL @@> (Left ()) = []
FoldL @@> (Right (x,xs)) = x : xs
UnfoldL @@> [] = Left ()
UnfoldL @@> (x:xs) = Right (x,xs)
-- EtaPlus @@> _ = case something of Right (Minus a) -> Left a
--  EtaPlus :: Zero :<=> Either a (Minus a)
--  EpsilonPlus :: Either a (Minus a) :<=> Zero
--  EtaTimes :: () :<=> (a, Recip a) 
--  EpsilonTimes :: (a, Recip a) :<=> ()

-- backwards

(<@@) :: (a :<=> b) -> b -> a
PlusZeroL <@@ (Left z) = absurd z
PlusZeroL <@@ (Right a) = a
PlusZeroR <@@ a = Right a
CommutePlus <@@ (Left a) = Right a
CommutePlus <@@ (Right b) = Left b 
AssocPlusL <@@ (Left a) = Left (Left a) 
AssocPlusL <@@ (Right (Left b)) = Left (Right b) 
AssocPlusL <@@ (Right (Right c)) = Right c
AssocPlusR <@@ (Left (Left a)) = Left a
AssocPlusR <@@ (Left (Right b)) = Right (Left b)
AssocPlusR <@@ (Right c) = Right (Right c)
TimesOneL <@@ ((), a) = a
TimesOneR <@@ a = ((), a)
CommuteTimes <@@ (a,b) = (b,a) 
AssocTimesL <@@ (a,(b,c)) = ((a,b),c) 
AssocTimesR <@@ ((a,b),c)  = (a,(b,c))
Distribute <@@ (Left b, a) = Left (b, a) 
Distribute <@@ (Right c, a) = Right (c, a) 
Factor <@@ (Left (b, a)) = (Left b, a) 
Factor <@@ (Right (c, a)) = (Right c, a) 
Id <@@ a = a
(Sym f) <@@ b = (adjoint f) <@@ b
(f :.: g) <@@ a = f <@@ (g <@@ a)
(f :+: g) <@@ (Left a) = Left (f <@@ a) 
(f :+: g) <@@ (Right b) = Right (g <@@ b) 
(f :*: g) <@@ (a,b) = (f <@@ a, g <@@ b) 
(Trace f) <@@ a = loop (f <@@ (Right a))
  where loop (Right a) = a
        loop (Left c) = loop (f <@@ (Left c))
FoldB <@@ (Left ()) = True
FoldB <@@ (Right ()) = False
UnfoldB <@@ True = Left ()
UnfoldB <@@ False = Right () 
FoldI <@@ (Left ()) = 0
FoldI <@@ (Right n) = n+1
UnfoldI <@@ 0 = Left ()
UnfoldI <@@ n = Right (n-1) 
FoldL <@@ (Left ()) = []
FoldL <@@ (Right (x,xs)) = x : xs
UnfoldL <@@ [] = Left ()
UnfoldL <@@ (x:xs) = Right (x,xs)
--  EtaPlus :: Zero :<=> Either a (Minus a)
--  EpsilonPlus :: Either a (Minus a) :<=> Zero
--  EtaTimes :: () :<=> (a, Recip a) 
--  EpsilonTimes :: (a, Recip a) :<=> ()

------------------------------------------------------------------------
-- Other names

swapPlus = CommutePlus
unitElim = TimesOneL
unitIntro = TimesOneR
swapTimes = CommuteTimes
f >>> g = g :.: f

-- Basic abstractions

notB :: Bool :<=> Bool
notB = UnfoldB >>> swapPlus >>> FoldB

factorB :: Either a a :<=> (Bool,a) 
factorB =  (unitIntro :+: unitIntro) >>>
           Factor >>>
           (FoldB :*: Id)

distributeB :: (Bool,a) :<=> (Either a a)
distributeB = adjoint factorB

if_c :: (a :<=> a) -> (Bool,a) :<=> (Bool,a)
if_c c = distributeB >>> (c :+: Id) >>> factorB

cnot :: (Bool,Bool) :<=> (Bool,Bool)
cnot = if_c notB

toffoli :: (Bool,(Bool,Bool)) :<=> (Bool,(Bool,Bool))
toffoli = if_c cnot

-- Abstractions using trace

just :: a :<=> Either () a
just = Trace body where
  body :: Either Int a :<=> Either Int (Either () a)
  body = (UnfoldI :+: Id) >>>     -- (1+Int) + a
         (CommutePlus :+: Id) >>> -- (Int+1) + a
         AssocPlusR               -- Int + (1+a)
         
add1,sub1 :: Int :<=> Int
add1 = just >>> FoldI
sub1 = adjoint add1

introF,introT :: () :<=> Bool
introF = just >>> FoldB
introT = introF >>> notB

injectL,injectR :: a :<=> Either a a
injectL = unitIntro >>>       -- ((),a)
          (introT :*: Id) >>> -- (Bool,a)
          distributeB         -- Either a a
injectR = unitIntro >>>       -- ((),a)
          (introF :*: Id) >>> -- (Bool,a)
          distributeB         -- Either a a

introZ :: () :<=> Int
introZ = Trace body where
  body :: Either Int () :<=> Either Int Int
  body = swapPlus >>> -- 1+Int
         FoldI >>>    -- Int
         injectR      -- Int+Int 

introNil :: (() :<=> a) -> () :<=> [a]
introNil c = Trace body where
  -- body :: Either [a] () :<=> Either [a] [a]
  body = swapPlus >>>            -- 1+[a]
         (Id :+: unitIntro) >>>  -- 1+(1,[a])
         (Id :+: (c :*: Id)) >>> -- 1+(a,[a])
         FoldL >>>               -- [a]
         injectR                 -- [a] + [a]

cons :: (a,[a]) :<=> [a]
cons = just >>> FoldL

hdtl :: [a] :<=> (a,[a])
hdtl = adjoint cons

------------------------------------------------------------------------

