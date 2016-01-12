module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(..))
import Data.Int (toNumber)
import Data.Array ((..), concat)
import Graphics.Canvas (
  Canvas(), Context2D(), ImageData(),
  getCanvasElementById, getContext2D, putImageData
)

width :: Int
width = 1400

height :: Int
height = 800

-- coordinates --
newtype Coord = Coord { x :: Int, y :: Int }

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

-- image --
foreign import createImageData :: Array Int -> Int -> Int -> ImageData

noisePixel :: Number -> Array Int
noisePixel n = [ np 190, np 186, np 209, np 255 ]
  where
    np max | 0.49 < n && n < 0.51 = max
           | otherwise            = 0

image :: ImageData
image = createImageData imageData width height
  where imageData = concat $ noisePixel <$> noiseGrid width height

renderImage :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Unit
renderImage ctx = do
  putImageData ctx image 0.0 0.0
  return unit

-- main --
main :: forall eff. Eff (canvas :: Canvas | eff) Unit
main = do
  Just canvas <- getCanvasElementById "topological"
  ctx <- getContext2D canvas
  renderImage ctx
