module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Int (toNumber)
import Data.Array ((..))

-- coordinates --
newtype Coord = Coord { x :: Int, y :: Int }

instance showCoord :: Show Coord where
  show (Coord { x, y }) = "(" ++ show x ++ ", " ++ show y ++ ")"

grid :: Int -> Int -> Array Coord
grid w h = coord <$> 0 .. (h - 1) <*> 0 .. (w - 1)
  where coord y x = Coord { x, y }

-- noise --
foreign import noise :: Number -> Number -> Number -> Number

noiseAt :: Coord -> Number
noiseAt (Coord { x, y }) = unit $ noise (scaled x) (scaled y) 0.0
  where scaled n = (toNumber n) / 100.0
        unit n = (n + 1.0) / 2.0

noiseGrid :: Int -> Int -> Array Number
noiseGrid w h = noiseAt <$> grid w h

-- main --
main :: forall eff. Eff (console :: CONSOLE | eff) Unit
main = do
  log $ show $ noiseGrid 10 1
