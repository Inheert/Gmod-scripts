AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/ro campfire.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:PhysgunPickup(ply, weapon)
    return false
end

function ENT:Touch(ent)
	if ent:IsPlayer() then return end
	print(tostring(ent:GetModel()))
	if (ent:GetModel() == "models/gibs/wood_gib01b.mdl" and self:IsOnFire() == false) then
		self:Ignite(120)
		ent:Remove()
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then return end
end