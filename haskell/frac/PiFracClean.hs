{-# LANGUAGE TypeOperators, GADTs #-}

module PiFracClean where

import Prelude hiding (curry,uncurry)
import Data.List

-----------------------------------------------------------------------
-- Isomorphisms 

data Recip a = Recip a deriving (Show, Eq)

class Eq a => B a where
  elems :: [a]

instance B () where  
  elems = [()]
  
instance (B a, B b) => B (Either a b) where
  elems = map Left elems ++ map Right elems
  
instance B Bool where
  elems = [False, True]

instance (B a, B b) => B (a,b) where
  elems = [(a,b) | a <- elems, b <- elems]

instance B a => B (Recip a) where
  elems = map Recip elems

data a :<=> b where 
-- Congruence
  Id    :: B a => a :<=> a
  Sym   :: (B a, B b) => (a :<=> b) -> (b :<=> a) 
  (:.:) :: (B a, B b, B c) => (a :<=> b) -> (b :<=> c) -> (a :<=> c)
  (:*:) :: (B a, B b, B c, B d) => (a :<=> b) -> (c :<=> d) -> ((a,c) :<=> (b,d))
  (:+:) :: (B a, B b, B c, B d) => (a :<=> b) -> (c :<=> d) -> (Either a c :<=> Either b d)
-- (+) is associative and commutative
  SwapP :: (B a, B b) => Either a b :<=> Either b a
  AssocLP  :: (B a, B b, B c) => Either a (Either b c) :<=> Either (Either a b) c 
  AssocRP  :: (B a, B b, B c) => Either (Either a b) c :<=> Either a (Either b c) 
-- (*) is associative, commutative, and has a unit
  UnitE    :: B a => ((), a) :<=> a
  UnitI    :: B a => a :<=> ((), a)
  SwapT :: (B a, B b) => (a,b) :<=> (b,a) 
  AssocLT  :: (B a, B b, B c) => (a,(b,c)) :<=> ((a,b),c)
  AssocRT  :: (B a, B b, B c) => ((a,b),c) :<=> (a,(b,c))
-- (*) distributes over (+) 
  Distrib  :: (B a, B b, B c) => (Either b c, a) :<=> Either (b, a) (c, a)
  Factor      :: (B a, B b, B c) => Either (b, a) (c, a) :<=> (Either b c, a)
-- Encoding of booleans
  FoldB   :: Either () () :<=> Bool
  UnfoldB :: Bool :<=> Either () ()
-- Eta/Psi
  EtaT :: (B a) => () :<=> (Recip a, a)
  EpsT :: (B a) => (Recip a, a) :<=> ()

-- Adjoint

adjoint :: (a :<=> b) -> (b :<=> a)
adjoint Id = Id
adjoint (Sym f) = f 
adjoint (f :.: g) = adjoint g :.: adjoint f
adjoint (f :*: g) = adjoint f :*: adjoint g
adjoint (f :+: g) = adjoint f :+: adjoint g
adjoint SwapP = SwapP
adjoint AssocLP = AssocRP
adjoint AssocRP = AssocLP
adjoint UnitE = UnitI
adjoint UnitI = UnitE
adjoint SwapT = SwapT
adjoint AssocLT = AssocRT
adjoint AssocRT = AssocLT
adjoint Distrib = Factor
adjoint Factor = Distrib
adjoint FoldB = UnfoldB
adjoint UnfoldB = FoldB
adjoint EtaT = EpsT
adjoint EpsT = EtaT

-- Semantics
eval :: (a :<=> b) -> a -> [b]
eval Id a = return a
eval (Sym f) b = evalR f b
eval (f :.: g) a = do v <- eval f a
                      eval g v
eval (f :*: g) (a,b) = do v1 <- eval f a
                          v2 <- eval g b
                          return (v1,v2)
eval (f :+: _) (Left a) = do v <- eval f a 
                             return (Left v)
eval (_ :+: g) (Right b) = do v <- eval g b
                              return (Right v)
eval SwapP (Left a) = return (Right a)
eval SwapP (Right b) = return (Left b)
eval AssocLP (Left a) = return (Left (Left a))
eval AssocLP (Right (Left b)) = return (Left (Right b))
eval AssocLP (Right (Right c)) = return (Right c)
eval AssocRP (Left (Left a)) = return (Left a)
eval AssocRP (Left (Right b)) = return (Right (Left b))
eval AssocRP (Right c) = return (Right (Right c))
eval UnitE ((), a) = return a
eval UnitI a = return ((), a)
eval SwapT (a,b) = return (b,a) 
eval AssocLT (a,(b,c)) = return ((a,b),c) 
eval AssocRT ((a,b),c)  = return (a,(b,c))
eval Distrib (Left b, a) = return (Left (b, a))
eval Distrib (Right c, a) = return (Right (c, a))
eval Factor (Left (b, a)) = return (Left b, a) 
eval Factor (Right (c, a)) = return (Right c, a) 
eval FoldB (Left ()) = return True
eval FoldB (Right ()) = return False
eval UnfoldB True = return (Left ())
eval UnfoldB False = return (Right ())
eval EtaT () = [(Recip v, v) | v <- elems]
eval EpsT (Recip v1, v2) | v1 == v2 = [()]
                         | otherwise = []

evalR :: (a :<=> b) -> b -> [a]
evalR Id a = return a
evalR (Sym f) b = eval f b
evalR (f :.: g) a = do v <- evalR g a 
                       evalR f v
evalR (f :*: g) (a,b) = do v1 <- evalR f a 
                           v2 <- evalR g b
                           return (v1,v2)
evalR (f :+: _) (Left a) = do v <- evalR f a 
                              return (Left v)
evalR (_ :+: g) (Right b) = do v <- evalR g b
                               return (Right v)
evalR SwapP (Left a) = return (Right a)
evalR SwapP (Right b) = return (Left b)
evalR AssocLP (Left (Left a)) = return (Left a)
evalR AssocLP (Left (Right b)) = return (Right (Left b))
evalR AssocLP (Right c) = return (Right (Right c))
evalR AssocRP (Left a) = return (Left (Left a))
evalR AssocRP (Right (Left b)) = return (Left (Right b))
evalR AssocRP (Right (Right c)) = return (Right c)
evalR UnitE a = return ((), a)
evalR UnitI ((), a) = return a
evalR SwapT (a,b) = return (b,a) 
evalR AssocLT ((a,b),c)  = return (a,(b,c))
evalR AssocRT (a,(b,c)) = return ((a,b),c) 
evalR Distrib (Left (b, a)) = return (Left b, a) 
evalR Distrib (Right (c, a)) = return (Right c, a) 
evalR Factor (Left b, a) = return (Left (b, a))
evalR Factor (Right c, a) = return (Right (c, a))
evalR FoldB True = return (Left ())
evalR FoldB False = return (Right ())
evalR UnfoldB (Left ()) = return True
evalR UnfoldB (Right ()) = return False
evalR EtaT (Recip v1, v2) | v1 == v2 = [()]
                          | otherwise = []
evalR EpsT () = [(Recip v, v) | v <- elems]

-- using nub; could use exclusive union to get modal QC or nothing to get duplicates

evalL :: (B a, B b) => (a :<=> b) -> [a] -> [b]
evalL c as = nub $ as >>= (eval c)

evalRL :: (B a, B b) => (a :<=> b) -> [b] -> [a]
evalRL c bs = nub $ bs >>= (evalR c)

------------------------------------------------------------------------
-- h.o. relations with fractionals: 

-- turn a relation (i.e., a combinator) into data (more precisely into
-- a combinator () -> data) and then use an explicit "apply"
-- combinator to apply the relation

-- I don't have access to all the choices. I have to program things
-- looking at one choice but this gets implicitly mapped on all 
-- the other hidden choices.

-- the relation {(F,F),(T,T)} is simply eta at Bool
-- to get the relation  {(F,T),(T,F)}, we use eta to get the relation above
-- and then negate the second component (we don't have access to the entire
-- relation to be able to swap the second values for example)

-- encode trace*

dtraceT :: (B a, B b1, B b2) => ((a, b1) :<=> (a, b2)) -> (b1 :<=> b2)
dtraceT f = UnitI -- ((), b1)
  :.: (EtaT :*: Id) -- ((1/a,a),b1)
  :.: AssocRT -- (1/a,(a,b1))
  :.: (Id :*: f) -- (1/a,(a,b2))
  :.: AssocLT -- ((1/a,a),b2)
  :.: (EpsT :*: Id) -- ((),b2)
  :.: UnitE

type a :-* b = (Recip a, b)

name :: (B b1, B b2) => (b1 :<=> b2) -> (() :<=> (b1 :-* b2))
name f = EtaT :.: (Id :*: f) 

coname :: (B b1, B b2) => (b1 :<=> b2) -> ((b1 :-* b2) :<=> ())
coname f = (Id :*: Sym f) :.: EpsT

apply' :: (B b1, B b2) => ((b1, b1 :-* b2) :<=> b2)
apply' =              -- (b1, (1/b1,b2))
  AssocLT :.:        -- ((b1,1/b1),b2)
  (SwapT :*: Id) :.: -- ((1/b1,b1),b2)
  (EpsT :*: Id) :.: UnitE

apply :: (B b1, B b2) => ((b1 :-* b2, b1) :<=> b2)
apply = SwapT :.: apply'

compose :: (B b1, B b2, B b3) => (b1 :-* b2, b2 :-* b3) :<=> (b1 :-* b3)
compose = AssocRT :.: (Id :*: apply')

doubleDiv :: B b => b :<=> Recip (Recip b) 
doubleDiv = -- b 
  UnitI :.:         -- ((),b)
  (EtaT :*: Id) :.: -- ((1/(1/b),1/b),b)
  AssocRT :.:       -- (1/(1/b), ((1/b),b))
  (Id :*: EpsT) :.: SwapT :.: UnitE

recipT :: (B b1, B b2) => Recip (b1,b2) :<=> (Recip b1, Recip b2)
recipT =                       -- 1/(b1,b2)
  UnitI :.:                    -- ((),1/(b1,b2))
  UnitI :.:                    -- ((),((),1/(b1,b2)))
  AssocLT :.:                  -- (((),()), 1/(b1,b2))
  ((EtaT :*: EtaT) :*: Id) :.: -- (((1/b1,b1),(1/b2,b2)),1/(b1,b2))
  (reorder :*: Id) :.:         -- (((1/b1,1/b2),(b1,b2)),1/(b1,b2))
  AssocRT :.:                  -- ((1/b1,1/b2),((b1,b2),1/(b1,b2)))
  (Id :*: SwapT) :.:           -- ((1/b1,1/b2),(1/(b1,b2),(b1,b2)))
  (Id :*: EpsT) :.:            -- ((1/b1,1/b2),())
  SwapT :.: UnitE
  where reorder :: (B a, B b, B c, B d) => ((a,b),(c,d)) :<=> ((a,c),(b,d))
        reorder = AssocLT :.:                 -- (((a,b),c),d)
                  (AssocRT :*: Id) :.:        -- ((a,(b,c)),d)
                  ((Id :*: SwapT) :*: Id) :.: -- ((a,(c,b)),d)
                  (AssocLT :*: Id) :.:        -- (((a,c),b),d)
                  AssocRT 

inv :: (B b1, B b2) => (b1 :<=> b2) -> (Recip b1 :<=> Recip b2)
inv f =                       -- 1/b1
  UnitI :.:                   -- ((),1/b1)
  (EtaT :*: Id) :.:           -- ((1/b2,b2),1/b1)
  AssocRT :.:                 -- (1/b2, (b2,1/b1))
  (Id :*: (Sym f :*: Id)) :.: -- (1/b2, (b1,1/b1))
  SwapT :.: (SwapT :*: Id) :.: (EpsT :*: Id) :.: UnitE

curry :: (B b1, B b2, B b3) => ((b1, b2) :-* b3) :<=> (b1 :-* (b2 :-* b3))
curry = (recipT :*: Id) :.: AssocRT

uncurry :: (B b1, B b2, B b3) => (b1 :-* (b2 :-* b3)) :<=> ((b1,b2) :-* b3)
uncurry = Sym curry

hor0, hor1, hor2, hor3, hor4, hor5, hor6, hor7, hor8, hor9, 
  hor10, hor11, hor12, hor13, hor14, hor15 :: () :<=> (Recip Bool, Bool)

-- empty
hor0 = name r0

-- (F,F)
hor1 = name r1

-- (F,T)
hor2 = name r2

-- (T,F)
hor3 = name r3

-- (T,T)
hor4 = name r4

-- (F,F),(F,T)
hor5 = name r5

-- (F,F),(T,F)
hor6 = name r6

-- (F,F),(T,T)
hor7 = name r7

-- (F,T),(T,F)
hor8 = name r8

-- (F,T),(T,T)
hor9 = name r9

-- (T,F),(T,T)
hor10 = name r10

-- (F,F),(F,T),(T,F)
hor11 = name r11

-- (F,F),(F,T),(T,T)
hor12 = name r12

-- (F,F),(T,F),(T,T)
hor13 = name r13

-- (F,T),(T,F),(T,T)
hor14 = name r14

-- (F,F),(F,T),(T,F),(T,T)
hor15 = name r15

------------------------------------------------------------------------
-- Combinational circuits 

-- do 
inot :: Bool :<=> Bool
inot = UnfoldB :.: SwapP :.: FoldB

cond :: (B a, B b) => (a :<=> b) -> (a :<=> b) -> ((Bool, a) :<=> (Bool, b))
cond f g = -- T,F
  (UnfoldB :*: Id) :.: 
  Distrib :.: 
  ((Id :*: f) :+: (Id :*: g)) :.: 
  Factor :.: 
  (FoldB :*: Id) 

cond2 :: (B a, B b) => (a :<=> b) -> (a :<=> b) -> (a :<=> b) -> (a :<=> b) -> 
         ((Bool,Bool),a) :<=> ((Bool,Bool),b)
cond2 f g h m = -- TT,TF,FT,FF
  AssocRT :.: (cond (cond f g) (cond h m)) :.: AssocLT

controlled :: B a => (a :<=> a) -> ((Bool, a) :<=> (Bool, a))
controlled f = cond f Id

cnot :: (Bool, Bool) :<=> (Bool, Bool)
cnot = controlled inot

elsenot :: (Bool, Bool) :<=> (Bool, Bool)
elsenot = cond Id inot

toffoli :: ((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool)
toffoli = AssocRT :.: (controlled cnot) :.: AssocLT

fredkin :: (Bool,(Bool,Bool)) :<=> (Bool,(Bool,Bool))
fredkin = controlled SwapT

peres :: ((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool)
peres = toffoli :.: (cnot :*: Id) 

if3not :: (Bool,(Bool,(Bool,Bool))) :<=> (Bool,(Bool,(Bool,Bool)))
if3not = controlled (controlled (controlled inot))

-- clone the first 2 if the last 2 are True
clone2 :: (Bool,(Bool,(Bool,Bool))) :<=> (Bool,(Bool,(Bool,Bool)))
clone2 = shuffle :.:
         (elsenot :*: elsenot) :.:
         (Sym shuffle)
  where shuffle =              -- (a,(b,(a',b')))
          (Id :*: SwapT) :.:   -- (a,((a',b'),b))
          (Id :*: AssocRT) :.: -- (a,(a',(b',b)))
          AssocLT :.:          -- ((a,a'),(b',b))
          (Id :*: SwapT)       -- ((a,a'),(b,b'))

-- clone the first 3 if the last 3 are all True
clone3 :: (Bool,(Bool,(Bool,(Bool,(Bool,Bool))))) :<=> (Bool,(Bool,(Bool,(Bool,(Bool,Bool)))))
clone3 = shuffle :.:
         (elsenot :*: (elsenot :*: elsenot)) :.:
         (Sym shuffle)
  where shuffle =                       -- (a,(b,(c,(a',(b',c')))))
          (Id :*: AssocLT) :.:          -- (a,((b,c),(a',(b',c'))))
          (Id :*: SwapT)   :.:          -- (a,((a',(b',c')),(b,c)))
          AssocLT :.:                   -- ((a,(a',(b',c'))),(b,c))
          (AssocLT :*: Id) :.:          -- (((a,a'),(b',c')),(b,c))
          AssocRT :.:                   -- ((a,a'),((b',c'),(b,c)))
          (Id :*: ((AssocLT) :.:        -- ((a,a'),(((b',c'),b),c))
                   (SwapT :*: Id) :.:   -- ((a,a'),((b,(b',c')),c))
                   (AssocLT :*: Id) :.: -- ((a,a'),(((b,b'),c'),c))
                   AssocRT :.:          -- ((a,a'),((b,b'),(c',c)))
                   (Id :*: SwapT)))     -- ((a,a'),((b,b'),(c,c')))

------------------------------------------------------------------------
-- Multiplicative Trace (SAT)

annihilate :: B a => a :<=> a
annihilate = dtraceT c
  where c :: B a => (Bool, a) :<=> (Bool, a)
        c = inot :*: Id
        
-- example input of function to SAT
-- first input is heap; last 2 inputs are the actual inputs        
-- is heap is false, and actual 2 inputs are FF
-- the function outputs two garbage bits and True
-- in all other relevant cases (heap is F) the function outputs False
isof1 :: ((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool)
-- ((heap,input-1),input-2) ==> ((garbage-1,garbage-2),satisfied?)
isof1 = (AssocRT :.: SwapT :.: toffoli :.: SwapT :.: AssocLT) :.: 
        (((inot :*: Id) :*: Id) :.: toffoli :.: ((inot :*: Id) :*: Id)) :.:
        (Id :*: inot) 

isof2 :: ((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool)
isof2 = toffoli

satf :: (((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool)) -> 
        ((((Bool,Bool),Bool),Bool),Bool) :<=> ((((Bool,Bool),Bool),Bool),Bool)
-- takes isof as input; produces
-- ((((heap-control,control),heap),input-1),input-2)
-- if heap=True, negate heap-control;
-- if isof produces False, negate control
satf isof = -- ((((heap-control,control),heap),input-1),input-2)
  ((SwapT :*: Id) :*: Id) :.:         -- (((heap,(heap-control,control)),input-1),input-2)
  ((AssocLT :*: Id) :*: Id) :.:       -- ((((heap,heap-control),control),input-1),input-2)
  (((cnot :*: Id) :*: Id) :*: Id) :.: -- ((((heap,heap-control),control),input-1),input-2)
  AssocRT :.:                         -- (((heap,heap-control),control),(input-1,input-2))
  (AssocRT :*: Id) :.:                -- ((heap,(heap-control,control)),(input-1,input-2))
  (SwapT :*: Id) :.:                  -- (((heap-control,control),heap),(input-1,input-2))
  AssocRT :.:                         -- ((heap-control,control),(heap,(input-1,input-2)))
  (Id :*: AssocLT) :.:                -- ((heap-control,control),((heap,input-1),input-2))
  (Id :*: isof) :.:                   -- ((heap-control,control),((garbage-1,garbage-2),satisfied?))
  SwapT :.:                           -- (((garbage-1,garbage-2),satisfied?),(heap-control,control))
  AssocRT :.:                         -- ((garbage-1,garbage-2),(satisfied?,(heap-control,control)))
  (Id :*: (Id :*: SwapT)) :.:         -- ((garbage-1,garbage-2),(satisfied?,(control,heap-control)))
  (Id :*: AssocLT) :.: -- ((garbage-1,garbage-2),((satisfied?,control),heap-control))
  (Id :*: ((inot :*: Id) :*: Id)) :.:
  (Id :*: (cnot :*: Id)) :.: 
  (Id :*: ((inot :*: Id) :*: Id)) :.:
  (Id :*: AssocRT) :.: 
  (Id :*: (Id :*: SwapT)) :.: 
  AssocLT :.: SwapT :.:
  (Id :*: (Sym isof :.: AssocRT)) :.: -- ((heap-control,control),(heap,(input-1,input-2)))
  AssocLT :.: AssocLT                 -- ((((heap-control,control),heap),input-1),input-2)

solve :: ((((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool))) -> 
         ((Bool,Bool) :<=> (Bool,Bool))
         -- cloning-heap :<=> inputs that satisfy isof
solve isof = dtraceT body 
  where body :: ((((Bool,Bool),Bool),(Bool,Bool)),(Bool,Bool)) :<=> 
                ((((Bool,Bool),Bool),(Bool,Bool)),(Bool,Bool))
        -- ((((input-1,input-2),heap),(control,heap-control)),cloning-heap)
        body = 
          -- take input-1 and input-2 and cloning-heap and pass them to clone2
          -- as (input-1,(input-2,cloning-heap))
          -- first two ouputs of clone2 are fed back to satf; other two 
          -- become overall output
          (AssocRT :*: Id) :.: 
          -- (((input-1,input-2),(heap,(control,heap-control))),cloning-heap)
          AssocRT :.:
          -- ((input-1,input-2),((heap,(control,heap-control)),cloning-heap))
          (Id :*: SwapT) :.:
          -- ((input-1,input-2),(cloning-heap,(heap,(control,heap-control))))
          AssocLT :.:
          -- (((input-1,input-2),cloning-heap),(heap,(control,heap-control)))
          (AssocRT :*: Id) :.:
          -- ((input-1,(input-2,cloning-heap)),(heap,(control,heap-control)))
          (clone2 :*: Id) :.:
          -- ((input-1,(input-2,(input-1,input-2))),(heap,(control,heap-control)))
          SwapT :.:
          -- ((heap,(control,heap-control)),(input-1,(input-2,(input-1,input-2))))
          (SwapT :*: Id) :.:
          -- (((control,heap-control),heap),(input-1,(input-2,(input-1,input-2))))
          ((SwapT :*: Id) :*: Id) :.:
          -- (((heap-control,control),heap),(input-1,(input-2,(input-1,input-2))))
          AssocLT :.:
          -- ((((heap-control,control),heap),input-1),(input-2,(input-1,input-2)))
          AssocLT :.:
          -- (((((heap-control,control),heap),input-1),input-2),(input-1,input-2))
          ((satf isof) :*: Id) :.:
          (AssocRT :*: Id) :.:
          -- ((((heap-control,control),heap),(input-1,input-2)),(input-1,input-2))
          (SwapT :*: Id) :.: 
          -- (((input-1,input-2),((heap-control,control),heap)),(input-1,input-2))
          ((Id :*: SwapT) :*: Id) :.:
          -- (((input-1,input-2),(heap,(heap-control,control))),(input-1,input-2))
          (AssocLT :*: Id) :.:
          -- ((((input-1,input-2),heap),(heap-control,control)),(input-1,input-2))
          ((Id :*: SwapT) :*: Id)
          -- ((((input-1,input-2),heap),(control,heap-control)),(input-1,input-2))


s1,s2 :: [(Bool,Bool)]
s1 = eval (solve isof1) (True,True)
s2 = eval (solve isof2) (True,True)

b2 :: [(Bool,Bool)]
b2 = [(v1,v2) | v1 <- bs, v2 <- bs] where bs = [False,True]

b3 :: [((Bool,Bool),Bool)]
b3 = [((v1,v2),v3) | v1 <- bs, v2 <- bs, v3 <- bs] where bs = [False,True]

tester :: (Show a, Show c, B a, B c) => [a] -> (a :<=> c) -> IO ()
tester l c = mapM_ (\b -> print (b, evalL c [b])) l

test1 :: (Show c, B c) => (Bool :<=> c) -> IO ()
test1 = tester [False,True]
test2 :: (Show c, B c) => ((Bool, Bool) :<=> c) -> IO ()
test2 = tester b2
test3 :: (Show c, B c) => (((Bool, Bool), Bool) :<=> c) -> IO ()
test3 = tester b3

------------------------------------------------------------------------
-- Superdense coding
        
r, s, u, v', rd, sd :: Bool :<=> Bool        
r = Id
s = inot
u = dtraceT cr 
  where cr :: ((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool) 
        cr = Sym (AssocRT :.: (Id :*: cnot) :.: AssocLT :.:
                  SwapT :.: (controlled (inot :*: inot)) :.: SwapT :.: 
                  AssocRT :.: SwapT :.: toffoli :.: SwapT :.: AssocLT :.:
                  SwapT :.: AssocLT :.: (cond2 Id Id inot Id) :.: AssocRT :.: SwapT :.:
                  SwapT :.: AssocLT :.: toffoli :.: AssocRT :.: SwapT)
v' = dtraceT cr 
  where cr :: ((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool)
        cr = Sym (SwapT :.: AssocLT :.: (cnot :*: Id) :.: AssocRT :.: SwapT :.: 
                  toffoli :.: ((SwapT :.: cnot :.: SwapT) :*: Id) :.:
                  toffoli :.: (AssocRT :.: SwapT :.: toffoli :.: SwapT :.: AssocLT) :.:
                  toffoli :.: (cnot :*: Id))
rd = inot :.: v' :.: inot
sd = rd :.: inot

------------------------------------------------------------------------
-- All Relations on Bool X Bool

r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15 :: Bool :<=> Bool

-- empty
r0 = dtraceT (inot :*: Id)

-- (F,F)
r1 = dtraceT (SwapT :.: cnot :.: SwapT)

-- (F,T)
r2 = r1 :.: inot

-- (T,F)
r3 = inot :.: r1

-- (T,T)
r4 = inot :.: r1 :.: inot

-- (F,F),(F,T)
r5 = r1 :.: r15

-- (F,F),(T,F)
r6 = Sym r5

-- (F,F),(T,T)
r7 = Id

-- (F,T),(T,F)
r8 = inot

-- (F,T),(T,T)
r9 = Sym (r4 :.: r14)

-- (T,F),(T,T)
r10 = r4 :.: r14

-- (F,F),(F,T),(T,F)
r11 = v'

-- (F,F),(F,T),(T,T)
r12 = u

-- (F,F),(T,F),(T,T)
r13 = sd

-- (F,T),(T,F),(T,T)
r14 = rd

-- (F,F),(F,T),(T,F),(T,T)
r15 = sd :.: Sym sd

------------------------------------------------------------------------
-- Examples from paper

ex1 :: () :<=> ()
ex1 = dtraceT c        
  where c :: (Bool, ()) :<=> (Bool, ())
        c = Id

ex2 :: () :<=> ()
ex2 = dtraceT c
  where c :: (Bool, ()) :<=> (Bool, ())
        c = inot :*: Id
        
------------------------------------------------------------------------
-- satisfy c @@ () returns () if any row of c is the identity
satisfy :: B a => (a :<=> a) -> () :<=> ()
satisfy c = dtraceT (SwapT :.: UnitE :.: c :.: UnitI :.: SwapT)

sat1,sat2,sat3,sat4,sat5,sat6 :: () :<=> ()

sat1 = satisfy inot
sat2 = satisfy cnot
sat3 = satisfy toffoli
sat4 = satisfy fredkin
sat5 = satisfy peres
sat6 = satisfy (inot :*: inot)

-- 

block :: (Bool,(Bool,(Bool,Bool))) :<=> (Bool,(Bool,(Bool,Bool)))
block =                                          -- (a,(b,(c,y)))
  (Id :*: (AssocLT :.: toffoli :.: AssocRT)) :.: -- (a,(b,(c,y)))
  (Id :*: SwapT) :.:                             -- (a,((c,y),b))
  (Id :*: (SwapT :*: Id)) :.:                    -- (a,((y,c),b))
  AssocLT :.:                                    -- ((a,(y,c)),b)
  ((AssocLT :.: toffoli :.: AssocRT) :*: Id) :.: -- ((a,(y,c)),b)
  AssocRT :.:                                    -- (a,((y,c),b))
  (Id :*: (SwapT :*: Id)) :.:                    -- (a,((c,y),b))
  (Id :*: SwapT)                                 -- (a,(b,(c,y)))

ex :: ((Bool,Bool),Bool) :<=> ((Bool,Bool),Bool)
-- (a,(b,(c,y))) ((a,b),(c,y)) (((a,b),c),y) (y,((a,b),c))
ex = dtraceT (SwapT :.: AssocRT :.: AssocRT :.:
             block :.:
             AssocLT :.: AssocLT :.: SwapT)

{--

ex @@ ((False,False),False) ==> ((False,False),False)
ex @@ ((False,False),True)  ==> ((False,False),True)
ex @@ ((False,True),False)  ==> ((False,True),False)
ex @@ ((False,True),True)   ==> --
ex @@ ((True,False),False)  ==> ((True,False),False)
ex @@ ((True,False),True)   ==> ((True,False),True)
ex @@ ((True,True),False)   ==> ((True,True),False)
ex @@ ((True,True),True)    ==> --

--}

------------------------------------------------------------------------
