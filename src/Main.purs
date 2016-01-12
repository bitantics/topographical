module Main where

import Prelude
import Math ((%))

import Control.Monad.Eff (Eff)
import Control.Timer (Timer())

import Data.Maybe (Maybe(..))
import Data.Int (toNumber)
import Data.Array ((..), concat)

import Signal ((~>), Signal(), runSignal)
import Signal.DOM (animationFrame)

import DOM (DOM())
import Graphics.Canvas (
  Canvas(), Context2D(), ImageData(),
  getCanvasElementById, getContext2D, putImageData, clearRect
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

noisePixel :: Number -> Number -> Array Int
noisePixel t n = [ np 190, np 186, np 209, np 255 ]
  where
    offset = t % 1.0
    np max | (-0.01 + offset) < n && n < (0.01 + offset) = max
           | otherwise            = 0

image :: Number -> ImageData
image t = createImageData imageData width height
  where imageData = concat $ noisePixel t <$> noiseGrid width height

renderImage :: forall eff. Context2D -> Number -> Eff (canvas :: Canvas | eff) Unit
renderImage ctx t = do
  clearRect ctx {
    x: 0.0, y: 0.0,
    w: toNumber width, h: toNumber height
  }
  putImageData ctx (image t) 0.0 0.0
  return unit

seconds :: forall eff. Eff (dom :: DOM, timer :: Timer | eff) (Signal Number)
seconds = do
  nowMs <- animationFrame
  return $ nowMs ~> secs
    where secs ms = ms / 1000.0

-- main --
main :: forall eff. Eff (timer :: Timer, dom :: DOM, canvas :: Canvas | eff) Unit
main = do
  Just canvas <- getCanvasElementById "topological"
  ctx <- getContext2D canvas
  s <- seconds
  runSignal $ s ~> (renderImage ctx)
