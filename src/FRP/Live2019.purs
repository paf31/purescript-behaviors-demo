module FRP.Live2019
  (module FRP.Live2019) where

import Prelude( bind, pure
              , Unit, unit
              , ($), (<$>), (<>), flip, (<<<), (<*>), liftA1
              , not, (*), (/), (-), negate)
import Control.Apply(lift2)
import Effect (Effect)
import Data.Int (toNumber)
import Data.Newtype (unwrap)
import Data.Time.Duration(Seconds(..)) as Duration
import Data.Maybe (fromJust, maybe)
import Data.Set (isEmpty)
import FRP.Behavior (Behavior, animate, integral', fixB, derivative')
import FRP.Behavior.Mouse (buttons, position)
import FRP.Event.Mouse (Mouse, getMouse)
import FRP.Behavior.Time (seconds) as Time
import Graphics.Canvas ( getCanvasElementById, getContext2D
                       , getCanvasHeight, getCanvasWidth, clearRect)
import Graphics.Drawing (Drawing, render
                        , fillColor, filled, outlined, lineWidth
                        , circle, rectangle)
import Color.Scheme.MaterialDesign (blueGrey, yellow)
import Web.HTML (window) as HTML
import Web.HTML.Window (document) as HTML
import Web.HTML.HTMLDocument (body, toDocument) as HTML
import Web.DOM.Document (createElement) as DOM
import Web.DOM.Element (setAttribute, setId, toNode) as DOM
import Web.HTML.HTMLElement (toNode) as HTML
import Web.DOM.Node (appendChild, setTextContent) as DOM
import Partial.Unsafe (unsafePartial)

init = do 
  window        <- HTML.window
  htmlDocument  <- HTML.document window
  let document  =  HTML.toDocument htmlDocument
  maybeBody     <- HTML.body htmlDocument
  let body = unsafePartial $ fromJust maybeBody
  let bodyNode = HTML.toNode body
  
  elem <- DOM.createElement "p" document
  let elemNode = DOM.toNode elem
  _ <- DOM.setTextContent "You can start the Live Session now!" elemNode
  _ <- DOM.appendChild elemNode bodyNode

  canvas' <- DOM.createElement "canvas" document
  _ <- DOM.setId "canvas" canvas'
  _ <- DOM.setAttribute "width" "800" canvas'
  _ <- DOM.setAttribute "height" "800" canvas'
  _ <- DOM.appendChild (DOM.toNode canvas') bodyNode
  pure unit
 
live :: Effect(Behavior Drawing) -> Effect Unit
live eScene = do
  mcanvas <- getCanvasElementById "canvas"
  let canvas = unsafePartial $ fromJust mcanvas
  ctx <- getContext2D canvas
  w <- getCanvasWidth canvas
  h <- getCanvasHeight canvas
  let background = filled (fillColor blueGrey) (rectangle 0.0 0.0 w h)
  scene <- eScene
  _ <- animate (pure background <> scene) (\frame -> do
    _ <- clearRect ctx { x: 0.0, y: 0.0, width: w, height: h }
    render ctx frame)
  pure unit

by :: forall a b. Effect (Behavior a) -> (a->b) 
                -> Effect (Behavior b)
by = flip $ liftA1 <<< liftA1

-- Bits and pieces

mouse :: Effect (Behavior { x :: Number, y :: Number })
mouse = (position <$> getMouse) `by` (maybe { x: 0.0, y: 0.0 } 
                                            (\{ x, y } -> { x: toNumber x
                                                          , y: toNumber y }))
click :: Effect (Behavior Boolean)
click = (buttons <$> getMouse) `by` (not <<< isEmpty) 

fromSeconds :: Behavior Number
fromSeconds = unwrap <$> Time.seconds

dot :: Number -> Number -> Number -> Drawing
dot x y r = filled   (fillColor yellow)    (circle x y r) 
         <> outlined (lineWidth (r / 4.0)) (circle x y (r * 1.2))

withRadius :: Effect (Behavior Number) -> Effect Unit
withRadius radius = live $ (lift2 $ \{x, y} r -> dot x y r) <$> mouse <*> radius

-- LIVE SESSION

live0 = init
live1 = withRadius $ click `by` (if _ then 100.0 else 50.0)
live2 = withRadius $ (integral' 50.0) <$> pure fromSeconds 
                                      <*> (click `by` (if _ then 50.0 else 0.0))
live3 = withRadius $ do
   bclick <- click
   pure $ fixB 50.0 \x ->  
      integral' 50.0 fromSeconds $ 
        integral' 0.0 fromSeconds $
          (\y dy -> if _ then 100.0 else -5.0 * (y - 50.0) - 2.0 * dy)  
           <$> x  
           <*> derivative' fromSeconds x
           <*> bclick 
