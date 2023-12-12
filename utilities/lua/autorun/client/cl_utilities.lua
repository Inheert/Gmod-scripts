include('autorun/sh_utilities.lua')

local height = 0;
/*
*   HUDPaint refresh every frame, more details about it: https://wiki.facepunch.com/gmod/GM:HUDPaint
*   EyeTrace return a table with information of what the player is looking at, more details about it: https://wiki.facepunch.com/gmod/Player:GetEyeTrace
*/
hook.Add("HUDPaint", "DrawData", function()
    local ply = LocalPlayer();
    if IsValid(ply) then
        local pos = ply:GetPos();
        local eyeTrace = ply:GetEyeTrace();
        
        local title1 = "Position:";
        local text1_1 = "- X: " .. tostring(pos.x);
        local text1_2 = "- Y: " .. tostring(pos.y);
        local text1_3 = "- Z: " .. tostring(pos.z);
        local title2 = "Eye trace:";
        local text2_1 = "- Entity hit: " .. tostring(eyeTrace.Entity);
        local text2_2 = "- Fraction: " .. tostring(eyeTrace.Fraction);
        height = 0;
        draw.RoundedBox(1, 5, 5, 300, 150, Color(0, 0, 0, 125));
        draw.SimpleText(title1, "Default", 10, UTILITIES:TextHeight(true), Color(255, 255, 255), 0, 0);
        draw.SimpleText(text1_1, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0);
        draw.SimpleText(text1_2, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0);
        draw.SimpleText(text1_3, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0);
        draw.SimpleText(title2, "Default", 10, UTILITIES:TextHeight(true), Color(255, 255, 255), 0, 0);
        draw.SimpleText(text2_1, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0);
        draw.SimpleText(text2_2, "Default", 65, UTILITIES:TextHeight(false), Color(255, 255, 255), 0, 0);
    end
end)

--PARAM TYPE:
--  isTitle: bool
function UTILITIES:TextHeight(isTitle)
    if (isTitle == true) then
        height = height + 15;
        return (height);
    end
    height = height + 10;
    return (height);
end
