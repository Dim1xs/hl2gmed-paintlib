# hl2gmed-paintlib
*Paint library for HL2GMED*🎨

## 🤔What is it?
Library that makes usage of [surface](https://dim1xs.github.io/site-hl2gmedwiki/documentation/libs/surface/basepage.html) library, a bit easier.
- Easier draw of rectangles with rounded corners.
- New custom fonts handling, with easier creation process.

## 📖Documentation
[Here](https://github.com/Dim1xs/hl2gmed-paintlib/wiki/Documentation)

## 🔧Installation
1. Download the *zip* file.
2. Unpack `lua` folder from zip, into `custom/hl2gmed` folder.
3. Launch your game.

## 📜Examples
### Paint a simple rounded box, in the left upper corner of the screen.
<img src="https://i.ibb.co/1G1Yyhg5/image.png">

```lua
hook.add( "HudViewportPaint", "PaintLibTest", function()
    local tab = 
    {
        pos = { 15, 15 },
        width = 300,
        height = 150,
        color = Color(50,87,155,143),
        radius = 50
    }

    paint.RoundedBox( tab ) 
end)
```
### Create a custom font, and render it on screen.
<img src="https://i.ibb.co/qLkrJwDC/image.png">

```lua
paint.CreateFont( "TestFont", {
	font = "Roboto",
	size = 32,
	weight = 500
} )

hook.add( "HudViewportPaint", "ImmersiveHUD", function()
    local tab = {
        text = "Hello World!",
        pos = { 15, 5 },
        font = "TestFont"
    }

    paint.TextShadow( tab, 1 )
end)
```