function BuilderPanel(frame)
    if (IsValid(frame)) then
        frame:Remove()
    end
    frame = vgui.Create("DFrame")
    frame:SetSize(300, 250)
    frame:Center()
    frame:MakePopup()

    local DermaButton = vgui.Create("DButton", frame)
    DermaButton:SetText("Tent")
    DermaButton:SetPos(25, 50)
    DermaButton:SetSize(250, 30)
    DermaButton.DoClick = function()
        SendNetworkMessage("models/german tents/ro gertent1open.mdl")
    end

    local DermaButton = vgui.Create("DButton", frame)
    DermaButton:SetText("Workshop bench")
    DermaButton:SetPos(25, 85)
    DermaButton:SetSize(250, 30)
    DermaButton.DoClick = function()
        SendNetworkMessage("models/mosi/fallout4/furniture/workstations/workshopbench.mdl")
    end

end

function SendNetworkMessage(object)
    net.Start("PanelSelection")
    net.WriteString(object)
    net.SendToServer()
end
