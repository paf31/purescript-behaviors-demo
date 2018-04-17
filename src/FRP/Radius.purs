module FRP.Radius where
import Prelude
import FRP.Live
import FRP (FRP)
import FRP.Behavior (Behavior, animate, fixB, integral', derivative')
import FRP.Behavior.Mouse (buttons, position)
import FRP.Behavior.Time (millisSinceEpoch)

dotFollow = live $ map (\{ x, y } -> dot x y 50.0) mouse

withRadius radius = live $ (\{ x, y } r -> dot x y r) <$> mouse <*> radius
dotGrow = withRadius $ map (if _ then 100.0 else 50.0) click

dotSwell = withRadius $ 
    fixB 50.0 \x ->  
      integral' 50.0 seconds $  
        integral' 0.0 seconds $  
          (\y dy -> if _ then 100.0 else -5.0 * (y - 50.0) - 3.1 * dy)  
          <$> x  
          <*> derivative' seconds x  
          <*> click
          
exp = fixB 1.0 \x -> integral' 1.0 seconds ((-2.0 * _) <$> x)
dotExp = withRadius $
    fixB 50.0 \x ->
      integral' 50.0 seconds $
        (\y -> if _ then 100.0 else (-2.0 * y)) <$> x
          <*> click
