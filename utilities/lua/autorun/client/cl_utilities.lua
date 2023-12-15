include('autorun/sh_utilities.lua')

local height = 0;
/*
*   HUDPaint refresh every frame, more details about it: https://wiki.facepunch.com/gmod/GM:HUDPaint
*   EyeTrace return a table with information of what the player is looking at, more details about it: https://wiki.facepunch.com/gmod/Player:GetEyeTrace
*/
hook.Add("HUDPaint", "DrawData", function()
    local ply = LocalPlayer()
    if IsValid(ply) then
        local pos = ply:GetPos()
        local eyeTrace = ply:GetEyeTrace()
        
        local title1 = "Position:"
        local text1_1 = "- X: " .. tostring(pos.x)
        local text1_2 = "- Y: " .. tostring(pos.y)
        local text1_3 = "- Z: " .. tostring(pos.z)
        local title2 = "Eye trace:"
        local text2_1 = "- Entity hit: " .. tostring(eyeTrace.Entity)
        local text2_2 = "- Entity hitbox hit: " .. tostring(eyeTrace.HitBox)
        local text2_3 = "- Hit pos: " .. tostring(eyeTrace.HitPos)
        draw.RoundedBox(5, 5, 5, 350, 200, Color(0, 0, 0, 175))
        height = 0
        draw.SimpleText(title1, "Default", 10, UTILITIES:TextHeight(true), Color(255, 255, 255), 0, 0)
        draw.SimpleText(text1_1, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0)
        draw.SimpleText(text1_2, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0)
        draw.SimpleText(text1_3, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0)
        draw.SimpleText(title2, "Default", 10, UTILITIES:TextHeight(true), Color(255, 255, 255), 0, 0)
        draw.SimpleText(text2_1, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0)
        draw.SimpleText(text2_2, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0)
        draw.SimpleText(text2_3, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0)
    end
end)

surface.CreateFont( "NewFont-60", {
	font = "Louis George Cafe", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 60,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "side-15", {
	font = "Louis George Cafe Bold", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 15,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "NewFont-15", {
	font = "Louis George Cafe", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 15,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

--PARAM TYPE:
--  isTitle: bool
function UTILITIES:TextHeight(isTitle)
    if (isTitle == true) then
        height = height + 15
        return (height)
    end
    height = height + 10
    return (height)
end

// Width of the main panel
local boxMainWidth = 450
// Top offset of the main panel
local boxTopOffset = 10
// Right offset of the main panel
local boxRightOffset = 10
// Original height of black panels
local boxBaseHeight = 150
// Variable height to update panels size
local boxHeight = boxBaseHeight
// Textbox start point
local textBoxStartWidth = ScrW() - 445
// Height of the line for a message
local lineHeight = 15
// Width of the line for a message
local lineWidth = 40
// Size of the line break between to message
local messagesep = 10
hook.Add('HUDPaint', 'DrawConsol', function()
    local ply = LocalPlayer()
    if (not IsValid(ply)) then return end
    draw.RoundedBox(5, ScrW() - boxMainWidth - boxRightOffset, boxTopOffset, boxMainWidth, boxHeight - boxTopOffset, Color(0, 0, 0, 200))
    draw.RoundedBox(5, textBoxStartWidth, 80 + boxTopOffset, 420, boxHeight - 135, Color(0, 0, 0, 200))
    draw.SimpleText("Console", "NewFont-60", ScrW() - 230, boxTopOffset + 10, Color(255, 255, 255), 1, 0)
    local textOffset = 10 + boxTopOffset
    local linecount = 0
    local color = Color(255, 255, 255)
    for i = 1, #UTILITIES.Messages do
        local line = ""
        if (UTILITIES.Messages[i][2] == 'client') then
            color = Color(164, 172, 28)
        elseif(UTILITIES.Messages[i][2] == 'server') then
            color = Color(94, 139, 207)
        end
        draw.SimpleText("[" ..string.upper(UTILITIES.Messages[i][2]) .. "]", "side-15", textBoxStartWidth + 5, 80 + textOffset + (linecount * lineHeight), color, 0, 0)
        local j = 0
        for _j = 1, #UTILITIES.Messages[i][1] do
            line = line .. UTILITIES.Messages[i][1][_j]
            if (_j % lineWidth == 0) then
                draw.SimpleText(line, "NewFont-15", textBoxStartWidth + 75, 80 + textOffset + (linecount * lineHeight), color, 0, 0)
                line = ""
                linecount = linecount + 1
            end
            j = _j
        end
        if (j > 0) then
            draw.SimpleText(line, "NewFont-15", textBoxStartWidth + 75, 80 + textOffset + (linecount * lineHeight), color, 0, 0)
            linecount = linecount + 1
        end
        if (i >= 20 or 80 + textOffset + (linecount) * lineHeight >= ScrH() - boxTopOffset) then
            table.remove(UTILITIES.Messages, 1)
            textOffset = textOffset - messagesep
        else
            textOffset = textOffset + messagesep
        end
        boxHeight = boxBaseHeight + textOffset + (linecount * lineHeight)
    end
    if (#UTILITIES.Messages == 0) then
        boxHeight = boxBaseHeight
    end
end)

net.Receive("DisplayMessage", function()
    local message = net.ReadTable()
    if (message == nil and message[0] != nil and message[1] != nil) then return end
    table.insert(UTILITIES.Messages, message)
end)

function UTILITIES:PrintConsole(isServer)

end
