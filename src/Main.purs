module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(..))
import Data.Int (toNumber)
import Data.Array ((..))
import Graphics.Canvas (
  Canvas(), Context2D(), ImageData(),
  getCanvasElementById, getContext2D, putImageData, createImageData
)

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
foreign import updateImageData :: ImageData -> Array Int -> ImageData

image :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) ImageData
image ctx = do
  img <- createImageData ctx 2.0 2.0
  return $ updateImageData img [
    255, 0, 255, 255,
    255, 0, 255, 255,
    255, 0, 255, 255,
    255, 0, 255, 255
  ]

renderImage :: forall eff. Context2D -> Eff (canvas :: Canvas | eff) Unit
renderImage ctx = do
  img <- image ctx
  putImageData ctx img 0.0 0.0
  return unit

-- main --
main :: forall eff. Eff (canvas :: Canvas | eff) Unit
main = do
  Just canvas <- getCanvasElementById "topological"
  ctx <- getContext2D canvas
  renderImage ctx
