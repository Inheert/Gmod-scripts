include('shared.lua')

function ENT:Initialize()
	self:CreateDynamicLight()
	self.TargetBrightness = 5
end

function ENT:Draw()
	self:DrawModel()
	self:DrawShadow(true)
end

function ENT:CreateDynamicLight()
    if CLIENT then
        local light = DynamicLight(self:EntIndex())

        if light then
			self.brightness = 2
			self.r = 255
			self.g = 150
			self.b = 50
            light.r = self.r  -- Composante rouge de la couleur (0-255)
            light.g = self.g  -- Composante verte de la couleur (0-255)
            light.b = self.b   -- Composante bleue de la couleur (0-255)
			light.Pos = self:GetPos() + Vector(0, 0, 10)  -- Ajustez la position de la lumière
            light.Brightness = self.brightness  -- Ajustez la luminosité selon vos besoins
            light.Size = 300  -- Ajustez la taille de la lumière
            light.DieTime = CurTime() + 99999999999999999999999999  -- Ajustez la durée de vie de la lumière
			self.LightEffect = light
		end
    end
end

function ENT:OnRemove()
    if self.LightEffect then
        self.LightEffect.decay = 2000
    end
end

function ENT:Think()
    self:RandomizeColor()
    self:UpdateColor()
end

function ENT:RandomizeColor()
	if (self:IsOnFire()) then
		self.TargetColor = Color(
			math.random(92, 255),
			math.random(45, 150),
			math.random(0, 50)
		)
	else
		self.TargetColor = Color(
			math.random(0, 31),
			math.random(0, 15),
			math.random(0, 0)
		)
	end
end

function ENT:UpdateColor()
    local light = self.LightEffect
    if light then
        local speed = 5
        local smoothingFactor = 0.2
        self.r = Lerp(smoothingFactor, self.r, self.TargetColor.r)
        self.g = Lerp(smoothingFactor, self.g, self.TargetColor.g)
        self.b = Lerp(smoothingFactor, self.b, self.TargetColor.b)
        light.r = self.r
        light.g = self.g
        light.b = self.b
    end
end
