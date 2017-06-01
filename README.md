# purescript-behaviors-demo

purescript-behaviors in PSCi

## Guide

Start PSCi:

```
$ pulp psci -- --port 8080
```

Open http://localhost:8080/.

### Mouse Position

Follow the cursor:

```
> live $ mouse <#> \{ x, y } -> dot x y 50.0
```

### Mouse Clicks

Increase the radius when the mouse is clicked:

```
> withRadius radius = live $ (\{ x, y } r -> dot x y r) <$> mouse <*> radius
> withRadius $ (if _ then 100.0 else 50.0) <$> click
```

### Functions of Time

Express the radius as an integral over time:

```
> withRadius $ integral' 50.0 seconds ((if _ then 50.0 else 0.0) <$> click)
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
