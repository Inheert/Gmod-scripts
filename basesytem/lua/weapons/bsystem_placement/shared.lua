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
SWEP.actualAngle = 0
SWEP.defaultModel = "models/hunter/blocks/cube025x025x025.mdl"

local rotation = 0

if (CLIENT) then
	LocalPlayer().GhostModel = "models/hunter/blocks/cube025x025x025.mdl"
	LocalPlayer().GhostModelBaseAngle = Angle(90, 0, 0)
	LocalPlayer().TraceBaseAngle = Angle(270, 0, 0)
	LocalPlayer().GhostModelAngle = LocalPlayer().GhostModelBaseAngle

	net.Receive("BuildModel", function(len, ply)
		local model = net.ReadString()
		LocalPlayer().GhostModel = model
	end)
end

function SWEP:OnRemove()
	self:ReleaseGhostEntity()
	hook.Remove('KeyPress', 'left_click')
	hook.Remove('CreateMove', 'CheckKeyDown')
	hook.Remove('CalcView', 'BlockViewWhenRightClick')
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
            hook.Remove('KeyPress', 'left_click')
        end
    end)
end

local blockedViewAngle = nil
local lastMouseX = 0
function SWEP:Think()
	local mdl = 'models/hunter/blocks/cube025x025x025.mdl'
	if (CLIENT) then
		mdl = self:GetOwner().GhostModel
		if (mdl == nil) then
			mdl = self.defaultModel
		end
	end
	if not IsValid(self.GhostEntity) then
		self:MakeGhostEntity(mdl, vector_origin, angle_zero)
	end
	self:UpdateGhostStructure(self.GhostEntity, self:GetOwner())
	if CLIENT and self.GhostEntity then 
		self.GhostEntity:SetColor(Color(255, 255, 255))
	end

	hook.Add('CreateMove', 'CheckKeyDown', function(cmd)
		local ply = LocalPlayer()
		if (cmd:KeyDown(IN_ATTACK2)) then
			if (blockedViewAngle == nil) then
				blockedViewAngle = cmd:GetViewAngles()
			end
			cmd:SetViewAngles(blockedViewAngle)
			if (cmd:GetMouseX() < lastMouseX) then
				rotation = rotation - 1
			elseif (cmd:GetMouseX() > lastMouseX) then
				rotation = rotation + 1
			end
			if (rotation == 360 or rotation == -360) then
				rotation = 0
			end
		else
			blockedViewAngle = nil
		end
	end)
end

function math.round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

function SWEP:UpdateGhostStructure(ent, ply)

	if not IsValid(ent) then return end

	local trace = ply:GetEyeTrace()
	if (trace.Hit or IsValid(trace.Entity)) and (trace.Entity:IsPlayer()) then
		ent:SetNoDraw(true)
	end

	local traceAngle = trace.HitNormal:Angle()
	local modelAngle = LocalPlayer().GhostModelAngle
	modelAngle.y = rotation

	local inclinaisonAngle = Angle(0, 0, 0)
	local ratio = rotation / 360
	if (ratio == 0) then
		ratio = 1
	end
	print(traceAngle.x, ratio, traceAngle.x * ratio)
	local xRot = traceAngle.x - traceAngle.x * ratio
	local yRot = traceAngle.y - traceAngle.y * ratio
	local zRot = traceAngle.z - traceAngle.z * ratio
	print(xRot, yRot, zRot)
	if (traceAngle.x == 0 and traceAngle.z == 0) then
		inclinaisonAngle = Angle(modelAngle.y - xRot, 90, 90)
	elseif (traceAngle.y == 0 and traceAngle.z == 0) then
		inclinaisonAngle:Add(Angle(90, xRot, 0 + xRot))
	end
	/*
	if (traceAngle.x == 0 and traceAngle.z == 0) then
		inclinaisonAngle = Angle(modelAngle.y - 48.33, 96.66, 96.66)

	elseif (traceAngle.y == 0 and traceAngle.z == 0) then
		local ratio = rotation / 360
		local result = 270 - 270 * ratio
		inclinaisonAngle = modelAngle
		inclinaisonAngle = Angle(90 + result, modelAngle.y, 0 + result)

	elseif (traceAngle.x != 0 and traceAngle.y != 0 and traceAngle.z == 0) then
		inclinaisonAngle = Angle(90, 0, 90)
	end
	*/
	local ang = traceAngle + inclinaisonAngle
	print(traceAngle, modelAngle)
	ent:SetAngles(ang)

	local curPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint(curPos - (trace.HitNormal * 0.8))
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