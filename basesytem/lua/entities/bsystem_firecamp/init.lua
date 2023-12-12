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

function ENT:CreateLight()
    local light = ents.Create("light")
	print(light);
    if IsValid(light) then
        light:SetKeyValue("brightness", 5)  -- Ajustez la luminosité selon vos besoins
        light:SetKeyValue("_light", "255 255 255")  -- Ajustez la couleur selon vos besoins
        light:SetPos(self:GetPos())
        light:Spawn()
        light:Activate()

        self:DeleteOnRemove(light)  -- Supprimer la lumière lorsque l'entité est supprimée
    end
end

function ENT:Touch(ent)
	if ent:IsPlayer() then return end
	print(tostring(ent:GetModel()))
	if (ent:GetModel() == "models/gibs/wood_gib01b.mdl" and self:IsOnFire() == false) then
		self:Ignite(10)
		ent:Remove()
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then return end
end