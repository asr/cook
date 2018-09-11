{-# LANGUAGE CPP #-}

-- 2.1 Lambda
-- The Lambda module implements a simple abstract syntax for the λ-calculus together
-- with a parser and a printer for it.  It also exports a simple type of identifiers
-- that parse and print in a nice way.

module Lambda (LC(..), freeVars, allVars, Id(..)) where
  
import Data.List (span, union, (\\))
import Data.Char (isAlphaNum)
import Text.PrettyPrint.HughesPJ (Doc, renderStyle, style, text, (<>), (<+>), parens)
import Text.ParserCombinators.ReadP

#if MIN_VERSION_base(4,11,0)
import Prelude hiding ((<>))
#endif

-- The LC type of λ-terms is parametrised over the type of the variables.  It has
-- constructors for variables, λ-abstraction, and application.

data LC v = Var v | Lam v (LC v) | App (LC v) (LC v)
  deriving (Eq)

-- Compute the free variables of an expression.

freeVars :: (Eq v) => LC v -> [v]
freeVars (Var v)   = [v]
freeVars (Lam v e) = freeVars e \\ [v]
freeVars (App f a) = freeVars f `union` freeVars a

-- Compute all variables in an expression.

allVars :: (Eq v) => LC v -> [v]
allVars (Var v)   = [v]
allVars (Lam _ e) = allVars e
allVars (App f a) = allVars f `union` allVars a

-- The Read instance for the LC type reads a λ-term with the normal syntax

instance (Read v) => Read (LC v) where
  readsPrec _ = readP_to_S pLC

-- A ReadP parser for λ-expressions.

pLC :: (Read v) => ReadP (LC v)
pLC = pLCLam +++ pLCApp +++ pLCLet

pLCVar :: (Read v) => ReadP (LC v)
pLCVar = do
    v <- pVar
    return $ Var v
  
pLCLam :: (Read v) => ReadP (LC v)
pLCLam = do
    _ <- schar '\\'
    v <- pVar
    _ <- schar '.'
    e <- pLC
    return $ Lam v e
  
pLCApp :: (Read v) => ReadP (LC v)
pLCApp = do
    es <- many1 pLCAtom
    return $ foldl1 App es
  
pLCAtom :: (Read v) => ReadP (LC v)
pLCAtom = pLCVar +++ lcAtom
  where
    lcAtom = do
      _ <- schar '('
      e <- pLC
      _ <- schar ')'
      return e

-- To make expressions a little easier to read we also allow let expressions as a
-- syntactic sugar for λ-abstraction and application.

pLCLet :: (Read v) => ReadP (LC v)
pLCLet = do
    _ <- sstring "let"
    bs <- sepBy pDef (schar ';')
    _ <- sstring "in"
    e <- pLC
    return $ foldr lcLet e bs
  where
    lcLet (x , e) b = App (Lam x b) e
    pDef = do
      v <- pVar
      _ <- schar '='
      e <- pLC
      return (v , e)

schar :: Char -> ReadP Char
schar c = do
  skipSpaces
  char c
  
sstring :: String -> ReadP String
sstring s = do
  skipSpaces
  string s
  
pVar :: (Read v) => ReadP v
pVar = do
  skipSpaces
  readS_to_P (readsPrec 9)

-- Pretty-print λ-expressions when shown.

instance (Show v) => Show (LC v) where
  show = renderStyle style . ppLC 0
  
ppLC :: (Show v) => Int -> LC v -> Doc
ppLC _ (Var v)   = text $ show v
ppLC p (Lam v e) = pparens (p > 0) $ text ("\\" ++ show v ++ ". ") <> ppLC 0 e
ppLC p (App f a) = pparens (p > 1) $ ppLC 1 f <+> ppLC 2 a

pparens :: Bool -> Doc -> Doc
pparens True d  = parens d
pparens False d = d

-- The Id type of identifiers.

newtype Id = Id String
  deriving (Eq, Ord)
  
-- Identifiers print and parse without any adornment.

instance Show Id where
  show (Id i) = i
  
instance Read Id where
  readsPrec _ s =
      case span isAlphaNum s of
        ("", _) -> []
        (i, s') -> [(Id i, s')]
