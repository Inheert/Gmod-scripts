AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('vgui/panel.lua')
include('shared.lua')

util.AddNetworkString("OpenPanel")
util.AddNetworkString("PanelSelection")
util.AddNetworkString("BuildModel")
util.AddNetworkString("PlaceBuild")

Build = Build or {}

function ENT:Initialize()
	self:SetModel('models/props_junk/TrashDumpster02.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
    net.Start("OpenPanel")
    net.Send(activator)
end

net.Receive("PanelSelection", function(len, ply)
    local model = net.ReadString()
    net.Start("BuildModel")
    net.WriteString(model)
    net.Send(ply, model)
    ply.GhostModel = model
    ply:Give("bsystem_placement")
end)

net.Receive("PlaceBuild", function(len, ply)
    if (Build[tostring(ply)] != nil) then return end
    Build[ply] = 1
    table.insert(Build, tostring(ply))
    local message = net.ReadTable()
    local myProp = ents.Create("prop_physics")
    if IsValid(myProp) then
        myProp:SetModel(message[5])
        myProp:SetPos(Vector(message[3].x, message[3].y, message[3].z))
        myProp:SetAngles(Angle(message[4].x, message[4].y, message[4].z))
        myProp:PhysicsInit(SOLID_VPHYSICS)
        myProp:SetMoveType(MOVETYPE_NONE)
        myProp:SetSolid(SOLID_VPHYSICS)
        myProp:Spawn()
    else
        print("Erreur lors de la création de l'entité prop.")
    end
    Build[tostring(ply)] = nil
    if ply:IsPlayer() and IsValid(ply:GetWeapon("bsystem_placement")) then
        SafeRemoveEntity(ply:GetWeapon("bsystem_placement"))
    end
end)