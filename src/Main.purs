module Main where

import Prelude
import Math (pow, sqrt, pi, exp)

import Control.Monad.Eff (Eff)

import Data.Maybe (Maybe(..))
import Data.Int (toNumber, round)
import Data.Array ((..), concat)

import DOM (DOM())
import Graphics.Canvas (
  Canvas(), Context2D(), ImageData(),
  getCanvasElementById, getContext2D, putImageData, clearRect
)

width :: Int
width = 1600

height :: Int
height = 900

-- coordinates --
newtype Coord = Coord { x :: Int, y :: Int }

grid :: Int -> Int -> Array Coord
grid w h = coord <$> 0 .. (h - 1) <*> 0 .. (w - 1)
  where coord y x = Coord { x, y }

-- noise --
foreign import noise :: Number -> Number -> Number

noiseAt :: Coord -> Number
noiseAt (Coord { x, y }) = unit $ noise (scaled x) (scaled y)
  where scaled n = (toNumber n) / 100.0
        unit n = (n + 1.0) / 2.0

noiseGrid :: Int -> Int -> Array Number
noiseGrid w h = noiseAt <$> grid w h

-- image --
foreign import createImageData :: Array Int -> Int -> Int -> ImageData

gaussian :: Number -> Number -> Number
gaussian mean n = coefficient * (exp exponent)
  where 
    dev = 0.4
    coefficient = 1.0 / (dev * (sqrt (2.0 * pi)))
    exponent = (-3000.0 * (pow (n - mean) 2.0)) / (2.0 * (pow dev 2.0))

noisePixel :: Number -> Array Int
noisePixel n = [ 190, 186, 209, round (opacity * 255.0) ]
  where
    opacity = gaussian 0.1 n + gaussian 0.3 n + gaussian 0.5 n + gaussian 0.7 n + gaussian 0.9 n

image :: ImageData
image = createImageData imageData width height
  where imageData = concat $ noisePixel <$> noiseGrid width height

renderImage :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Unit
renderImage ctx = do
  clearRect ctx {
    x: 0.0, y: 0.0,
    w: toNumber width, h: toNumber height
  }
  putImageData ctx image 0.0 0.0
  return unit

-- main --
main :: forall eff. Eff (dom :: DOM, canvas :: Canvas | eff) Unit
main = do
  Just canvas <- getCanvasElementById "topological"
  ctx <- getContext2D canvas
  renderImage ctx
