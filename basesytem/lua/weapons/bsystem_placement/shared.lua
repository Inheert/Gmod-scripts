SWEP.Category = "BaseSystem"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Structure placment"
SWEP.Spawnable = true

SWEP.yAngle = 0

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

SWEP.parentid = nil
SWEP.structureAngle = Angle(90, 0, 0)
SWEP.actualAngle = 0

if (CLIENT) then
	LocalPlayer().GhostModel = "models/props_c17/FurnitureCouch001a.mdl"

	net.Receive("BuildModel", function(len, ply)
		local model = net.ReadString()
		LocalPlayer().GhostModel = model
	end)
end

function SWEP:OnRemove()
	self:ReleaseGhostEntity()
end

hook.Add("PlayerSwitchWeapon", "MonPlayerSwitchWeaponHook", function(ply, oldWeapon, newWeapon)
    if IsValid(oldWeapon) and oldWeapon:IsScripted() and oldWeapon:GetClass() == "bsystem_placement" then
        oldWeapon:ReleaseGhostEntity()
        if (CLIENT) then return end 
        SafeRemoveEntity(oldWeapon)
    end
end)

function SWEP:Initialize()
    hook.Add('KeyPress', 'left_click', function(ply, key)
        if SERVER then return end
        if not IsValid(ply:GetWeapon('bsystem_placement')) then return end
        if not ply:Alive() then return end
        if key == IN_ATTACK then
            local data = {self:GetOwner().parentid, self:GetOwner():GetEyeTrace(), self.GhostEntity:GetPos(), self.GhostEntity:GetAngles(), self.GhostEntity:GetModel()}
            net.Start('PlaceBuild')
            net.WriteTable(data)
            net.SendToServer()

            -- Retirez le hook après avoir effectué l'action.
            hook.Remove('KeyPress', 'left_click')
        end
    end)
end

function SWEP:Think()
	local mdl = 'models/hunter/blocks/cube025x025x025.mdl'
	if CLIENT then
		mdl = self:GetOwner().GhostModel
	end
	if not IsValid(self.GhostEntity) then
		self:MakeGhostEntity(mdl, vector_origin, angle_zero)

	end
	self:UpdateGhostStructure(self.GhostEntity, self:GetOwner())

	if CLIENT and self.GhostEntity then 
		self.GhostEntity:SetColor(Color(255, 255, 255))
	end

end

function SWEP:UpdateGhostStructure(ent, ply)

	if not IsValid(ent) then return end

	local trace = ply:GetEyeTrace()
	if (trace.Hit or IsValid(trace.Entity)) and (trace.Entity:IsPlayer()) then

		ent:SetNoDraw(true)

	end


	local ang = trace.HitNormal:Angle() + self.structureAngle
	ent:SetAngles(ang)

	local curPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint(curPos - (trace.HitNormal * 512))
	local structurOffset = curPos - NearestPoint
	ent:SetPos(trace.HitPos + structurOffset)
	ent:SetNoDraw(false)

end

--[[---------------------------------------------------------
	Starts up the ghost entity
	The most important part of this is making sure it gets deleted properly
-----------------------------------------------------------]]
function SWEP:MakeGhostEntity( model, pos, angle )

	util.PrecacheModel( model )

	-- We do ghosting serverside in single player
	-- It's done clientside in multiplayer
	if ( SERVER && not game.SinglePlayer() ) then return end
	if ( CLIENT && game.SinglePlayer() ) then return end

	-- The reason we need this is because in multiplayer, when you holster a tool serverside,
	-- either by using the spawnnmenu's Weapons tab or by simply entering a vehicle,
	-- the Think hook is called once after Holster is called on the client, recreating the ghost entity right after it was removed.

	if ( not IsFirstTimePredicted() ) then return end

	-- Release the old ghost entity
	self:ReleaseGhostEntity()

	if ( CLIENT ) then
		self.GhostEntity = ents.CreateClientProp( model )
	else
		self.GhostEntity = ents.Create( "prop_physics" )
	end

	-- If there's too many entities we might not spawn..
	if ( not IsValid( self.GhostEntity ) ) then
		self.GhostEntity = nil
		return
	end

	self.GhostEntity:SetModel( model )
	self.GhostEntity:SetPos( pos )
	self.GhostEntity:SetAngles( angle )
	self.GhostEntity:Spawn()

	-- We do not want physics at all
	self.GhostEntity:PhysicsDestroy()

	-- SOLID_NONE causes issues with Entity.NearestPoint used by Wheel tool
	--self.GhostEntity:SetSolid( SOLID_NONE )
	self.GhostEntity:SetMoveType( MOVETYPE_NONE )
	self.GhostEntity:SetNotSolid( true )
	self.GhostEntity:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self.GhostEntity:SetColor( Color( 255, 255, 255, 150 ) )

end

--[[---------------------------------------------------------
	Starts up the ghost entity
	The most important part of this is making sure it gets deleted properly
-----------------------------------------------------------]]
function SWEP:StartGhostEntity( ent )

	-- We do ghosting serverside in single player
	-- It's done clientside in multiplayer
	if ( SERVER && not game.SinglePlayer() ) then return end
	if ( CLIENT && game.SinglePlayer() ) then return end

	self:MakeGhostEntity( ent:GetModel(), ent:GetPos(), ent:GetAngles() )

end

--[[---------------------------------------------------------
	Releases up the ghost entity
-----------------------------------------------------------]]
function SWEP:ReleaseGhostEntity()
	if ( self.GhostEntity ) then
		if ( not IsValid( self.GhostEntity ) ) then self.GhostEntity = nil return end
		
		self.GhostEntity:Remove()
		self.GhostEntity = nil

	end

end

--[[---------------------------------------------------------
	Update the ghost entity
-----------------------------------------------------------]]
function SWEP:UpdateGhostEntity()

	if ( self.GhostEntity == nil ) then return end
	if ( not IsValid( self.GhostEntity ) ) then self.GhostEntity = nil return end

	local trace = self:GetOwner():GetEyeTrace()
	if ( not trace.Hit ) then return end

	local Ang1, Ang2 = self:GetNormal( 1 ):Angle(), ( trace.HitNormal * -1 ):Angle()
	local TargetAngle = self:GetEnt( 1 ):AlignAngles( Ang1, Ang2 )

	self.GhostEntity:SetPos( self:GetEnt( 1 ):GetPos() )
	self.GhostEntity:SetAngles( TargetAngle )

	local TranslatedPos = self.GhostEntity:LocalToWorld( self:GetLocalPos( 1 ) )
	local TargetPos = trace.HitPos + ( self:GetEnt( 1 ):GetPos() - TranslatedPos ) + trace.HitNormal

	self.GhostEntity:SetPos( TargetPos )

end