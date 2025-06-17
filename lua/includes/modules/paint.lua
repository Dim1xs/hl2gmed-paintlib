/*
    Paint library for HL2GMED
    17.06.25

    by Dim1xs
*/

if SERVER then return end 

local INVALID_FONT = INVALID_FONT
local surface = surface 
local table = table

module( "paint", package.seeall )

// Corner texture instances
local tCorners = 
{
    { "vgui/hud/8x800corner1", surface.CreateNewTextureID() },
    { "vgui/hud/8x800corner2", surface.CreateNewTextureID() },
    { "vgui/hud/8x800corner3", surface.CreateNewTextureID() },
    { "vgui/hud/8x800corner4", surface.CreateNewTextureID() }
}

// Main font part \\
/*
    Since default implementation of fonts for surface library sucks,
    im going to make work with them a bit easier.
    ( attempt to recreate internal work of gmod fonts in surface )

    Basically we are just doing alliases for normal HFont objects.
*/
local tFontHandle = {}

local tFontFlags = 
{
    ['ITALIC'] = 0x001,
    ['UNDERLINE'] = 0x002,
    ['STRIKEOUT'] = 0x004,
    ['SYMBOL'] = 0x008,
    ['ANTIALIAS'] = 0x010,
    ['GAUSSIANBLUR'] = 0x020,
    ['ROTARY'] = 0x040,
    ['SHADOW'] = 0x080,
    ['ADDITIVE'] = 0x100,
    ['OUTLINE'] = 0x200,
    ['CUSTOM'] = 0x400,
    ['BITMAP'] = 0x800,
}

local pFont = {
    Name = nil,
    Instance = nil,

    getName = function( self )
        return self.Name 
    end, 

    getInstance = function( self )
        return self.Instance 
    end, 

    setupData = function( self, windowsfont, size, weight, blursize, scanlines )
        self.data = 
        {
            font = windowsfont or "Arial",
            size = size or 13,
            weight = weight or 500,
            blursize = blursize or 0,
            scanlines = scanlines or 0
        }
    end,

    setupFlags = function( self, antialias, underline, italic, strikeout, symbol, rotary, shadow, additive, outline )
        local flags = 0

        if antialias then 
            flags = bit.bor( flags, tFontFlags['ANTIALIAS'])
        elseif underline then
            flags = bit.bor( flags, tFontFlags['UNDERLINE'])
        elseif italic then
            flags = bit.bor( flags, tFontFlags['ITALIC'])
        elseif strikeout then
            flags = bit.bor( flags, tFontFlags['STRIKEOUT'])
        elseif symbol then
            flags = bit.bor( flags, tFontFlags['SYMBOL'])
        elseif rotary then
            flags = bit.bor( flags, tFontFlags['ROTARY'])
        elseif shadow then
            flags = bit.bor( flags, tFontFlags['SHADOW'])
        elseif additive then
            flags = bit.bor( flags, tFontFlags['ADDITIVE'])
        elseif outline then
            flags = bit.bor( flags, tFontFlags['OUTLINE'])
        end

        self.flags = flags 
    end,
    
    registerFont = function( self )
        local windowsfont = self.data.font
        local tall = self.data.size
        local weight = self.data.weight
        local blur = self.data.blursize
        local scanlines = self.data.scanlines
        local flags = self.flags 

        surface.SetFontGlyphSet( self:getInstance(), windowsfont, tall, weight, blur, scanlines, flags )
    end
}   
pFont.__index = pFont 

function pFont.new( name, hfont )
    local pfont = {
        Name = name,
        Instance = hfont
    }

    setmetatable(pfont, pFont)

    return pfont
end

local function register_font(name, data)
    local hFontInstance = surface.CreateFont()
    local luaFont = pFont.new(name, hFontInstance)
    luaFont:setupData(data.font, data.size, data.weight, data.blursize, data.scanlines)
    luaFont:setupFlags(data.antialias, data.underline, data.italic, data.strikeout, data.symbol, data.rotary, data.shadow, data.additive, data.outline)
    luaFont:registerFont()

    table.insert( tFontHandle, luaFont )
end 

local function getFont( name )
    for _, font in ipairs( tFontHandle ) do 
        if string.lower( font:getName() ) == string.lower( name ) then 
            return font 
        end 
    end

    return INVALID_FONT
end

register_font( "Default", {
    font		= "Tahoma",
    size		= 13,
    weight		= 500
} )

register_font( "DefaultBold", {
    font		= "Tahoma",
    size		= 13,
    weight		= 800
} )

register_font( "DefaultLarge", {
	font		= "Roboto",
	size		= 32,
	weight		= 500
} )


local function unpackColor(col)
    return col:r() or 255, col:g() or 255, col:b() or 255, col:a() or 255
end

/*
    paint.CreateFont( string: fontName, table: fontData )
    Create a font, and insert it into custom fonts handle.
*/
function CreateFont(fontName, fontData)
    if type(fontName) != "string" then 
        error("excepted string on 1 argument", 2)
        return 
    elseif type(fontData) != "table" then 
        error("excepted table on 2 argument", 2)
        return
    end

    register_font( fontName, fontData )
end

/*
    HFont: paint.GetFont( string: fontName )
    Find a HFont instance from custom fonts handle.
*/
function GetFont( fontName )
    return getFont( fontName ):getInstance()
end

/*
    paint.RoundedBox( table: data, boolean: outline )
    Draw a simple rectangle on the screen, with outline or without.
*/
function Box( data, outline )
    local x = data.pos[1] or 0
    local y = data.pos[2] or 0
    local width = data.width or 100
    local height = data.height or 100
    local bOutline = outline or false 
    local first_color = data.color or Color(255,255,255,255)
    local second_color = data.outline_color or Color(0,0,0,255)

    // Primary box
    surface.DrawSetColor( unpackColor(first_color) )
    surface.DrawFilledRect( x, y, x+width, y+height )

    // Outline 
    if bOutline then 
        surface.DrawSetColor( unpackColor(second_color) )
        surface.DrawOutlinedRect( x, y, x+width, y+height )
    end
end

/*
    paint.RoundedBox( table: data )
    Draw a box on the screen, with rounded corners.
*/
function RoundedBox( data )
    local x = data.pos[1] or 0
    local y = data.pos[2] or 0
    local width = data.width or 100 
    local height = data.height or 100
    local color = data.color or Color(255,255,255,255)
    local radius = data.radius or 32

    surface.DrawSetColor( unpackColor(color) )
    surface.DrawFilledRect( x + radius, y, x + width - radius, y + radius );
    surface.DrawFilledRect( x, y + radius, x + width, y + height - radius );
    surface.DrawFilledRect( x + radius, y + height - radius, x + width - radius, y + height );  

    // Corners
    local curCorner = tCorners[1]
    surface.DrawSetTextureFile( curCorner[2], curCorner[1], 0, true );
    surface.DrawTexturedRect( x, y, x + radius, y + radius );
    curCorner = tCorners[2]
    surface.DrawSetTextureFile( curCorner[2], curCorner[1], 0, true );
    surface.DrawTexturedRect( x + width - radius, y, x + width, y + radius );
    curCorner = tCorners[3]
    surface.DrawSetTextureFile( curCorner[2], curCorner[1], 0, true );
    surface.DrawTexturedRect( x + width - radius, y + height - radius, x + width, y + height );
    curCorner = tCorners[4]
    surface.DrawSetTextureFile( curCorner[2], curCorner[1], 0, true );
    surface.DrawTexturedRect( x + 0, y + height - radius, x + radius, y + height );
end

// Welp, we cant do any kind of align due to broken implementation of surface.GetTextSize
/*
    paint.Text( table: data )
    Draw a text on the screen from specified data.
*/
function Text( data )
    local text = data.text or "Label"
    local x = data.pos[1] or 0
    local y = data.pos[2] or 0 
    local font = data.font or "Default"
    local color = data.color or Color(255,255,255,255)

    surface.DrawSetTextColor( unpackColor(color) )
    surface.DrawSetTextFont( getFont(font):getInstance() )
    surface.DrawSetTextPos( x, y )
    surface.DrawPrintText( text )
end

/*
    paint.TextShadow( table: data, number: distance )
    Draw a text on the screen with a small shadow in distance.
*/
function TextShadow( data, distance )
    local text = data.text or "Label"
    local x = data.pos[1] or 0
    local y = data.pos[2] or 0 
    local font = data.font or "Default"
    local color = data.color or Color(255,255,255,255)

    surface.DrawSetTextColor( unpackColor( Color(0,0,0, color:a())) )
    surface.DrawSetTextFont( getFont(font):getInstance() )
    surface.DrawSetTextPos( x + distance, y + distance )
    surface.DrawPrintText( text )

    surface.DrawSetTextColor( unpackColor(color) )
    surface.DrawSetTextFont( getFont(font):getInstance() )
    surface.DrawSetTextPos( x, y )
    surface.DrawPrintText( text )
end