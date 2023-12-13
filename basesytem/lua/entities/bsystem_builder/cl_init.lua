include("shared.lua")
include('vgui/panel.lua')

function ENT:Initialize()
end

function ENT:Draw()
	self:DrawModel()
	self:DrawShadow(true)
end

net.Receive("OpenPanel", function()
    PANEL.builder = BuilderPanel(PANEL.builder)
end)

net.Receive("PanelSelection", function(object)
    print(object)
end)
