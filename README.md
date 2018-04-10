# purescript-behaviors-demo

`purescript-behaviors` demo in the REPL

## Guide

First install dependencies:

```
npm install -g purescript pulp bower
bower update
```

Then open the REPL:

```
$ pulp psci -- --port 8080
```

Navigate to http://localhost:8080/.

### Mouse Position

Follow the cursor:

```
> live $ map (\{ x, y } -> dot x y 50.0) mouse
```

### Mouse Clicks

Increase the radius when the mouse is clicked:

```
> withRadius radius = live $ (\{ x, y } r -> dot x y r) <$> mouse <*> radius
> withRadius $ map (if _ then 100.0 else 50.0) click
```

### Functions of Time

Express the radius as an integral over time:

```
> withRadius $ integral' 50.0 seconds (map (if _ then 50.0 else 0.0) click)
```

### Advanced Functions of Time

Express the radius as a solution of a differential equation:

```
> :paste
… withRadius $ 
    fixB 50.0 \x ->  
      integral' 50.0 seconds $  
        integral' 0.0 seconds $  
          (\y dy -> if _ then 100.0 else -5.0 * (y - 50.0) - 2.0 * dy)  
          <$> x  
          <*> derivative' seconds x  
          <*> click 
```
The differential equation is _d<sup>2</sup>x/dt<sup>2</sup> = -5(x - 50) - 2dx/dt_
,  which is rearranged so the right hand side gives an expression whose fixed point solution is a function of time describing an oscillation.

x = ∫ ∫  _-5(x - 50) - 2dx/dt_ dt dt

The differential equation is described in [Damped_harmonic_oscillator](https://en.wikipedia.org/wiki/Harmonic_oscillator#Damped_harmonic_oscillator), whereby these coefficients give a damping ratio ζ < 1. 
