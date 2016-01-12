module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(..))
import Data.Int (toNumber, round)
import Data.Array ((..), concat)
import Graphics.Canvas (
  Canvas(), Context2D(), ImageData(),
  getCanvasElementById, getContext2D, putImageData
)

width = 1400
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
noisePixel n = [ np, np, np, 255 ]
  where np = round (n * 255.0)

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
