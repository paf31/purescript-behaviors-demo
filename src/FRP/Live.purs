module FRP.Live
  ( live
  , seconds
  , mouse
  , click
  , dot
  ) where

import Prelude
import Color.Scheme.MaterialDesign (blueGrey)
import Control.Monad.Eff (Eff)
import Data.Int (toNumber)
import Data.Maybe (maybe)
import Data.Set (isEmpty)
import FRP (FRP)
import FRP.Behavior (Behavior, animate)
import FRP.Behavior.Mouse (buttons, position)
import FRP.Behavior.Time (millisSinceEpoch)
import Graphics.Canvas (CANVAS, CanvasElement, clearRect, getCanvasHeight, getCanvasWidth, getContext2D)
import Graphics.Drawing (Drawing, circle, fillColor, filled, lineWidth, outlined, render)

foreign import createCanvas :: forall eff. Eff (canvas :: CANVAS | eff) CanvasElement

live :: forall eff. Behavior Drawing -> Eff (canvas :: CANVAS, frp :: FRP | eff) Unit
live scene = do
  canvas <- createCanvas
  ctx <- getContext2D canvas
  w <- getCanvasWidth canvas
  h <- getCanvasHeight canvas
  animate scene \frame -> do
    _ <- clearRect ctx { x: 0.0, y: 0.0, w, h }
    render ctx frame

-- Bits and pieces

seconds :: Behavior Number
seconds = ((_ / 1000.0) <<< toNumber <$> millisSinceEpoch)

mouse :: Behavior { x :: Number, y :: Number }
mouse = position <#> maybe { x: 0.0, y: 0.0 } (\{ x, y } -> { x: toNumber x, y: toNumber y })

click :: Behavior Boolean
click = not <<< isEmpty <$> buttons

dot :: Number -> Number -> Number -> Drawing
dot x y r = filled (fillColor blueGrey) (circle x y r) <> outlined (lineWidth (r / 4.0)) (circle x y (r * 1.2))
