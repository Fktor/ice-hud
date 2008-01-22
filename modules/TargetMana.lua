local AceOO = AceLibrary("AceOO-2.0")

local DogTag = nil

local TargetMana = AceOO.Class(IceUnitBar)


-- Constructor --
function TargetMana.prototype:init()
	TargetMana.super.prototype.init(self, "TargetMana", "target")
	
	self:SetDefaultColor("TargetMana", 52, 64, 221)
	self:SetDefaultColor("TargetRage", 235, 44, 26)
	self:SetDefaultColor("TargetEnergy", 228, 242, 31)
	self:SetDefaultColor("TargetFocus", 242, 149, 98)

	if AceLibrary:HasInstance("LibDogTag-2.0") then
		DogTag = AceLibrary("LibDogTag-2.0")
	end
end


function TargetMana.prototype:GetDefaultSettings()
	local settings = TargetMana.super.prototype.GetDefaultSettings(self)

	settings["side"] = IceCore.Side.Right
	settings["offset"] = 2
	settings["upperText"] = "[PercentMP:Round]"
	settings["lowerText"] = "[FractionalMP:PowerColor]"

	return settings
end


function TargetMana.prototype:Enable(core)
	TargetMana.super.prototype.Enable(self, core)
	
	self:RegisterEvent("UNIT_MANA", "Update")
	self:RegisterEvent("UNIT_MAXMANA", "Update")
	self:RegisterEvent("UNIT_RAGE", "Update")
	self:RegisterEvent("UNIT_MAXRAGE", "Update")
	self:RegisterEvent("UNIT_ENERGY", "Update")
	self:RegisterEvent("UNIT_MAXENERGY", "Update")
	self:RegisterEvent("UNIT_FOCUS", "Update")
	self:RegisterEvent("UNIT_MAXFOCUS", "Update")
	self:RegisterEvent("UNIT_AURA", "Update")
	self:RegisterEvent("UNIT_FLAGS", "Update")
	
	self:Update("target")
end



function TargetMana.prototype:Update(unit)
	TargetMana.super.prototype.Update(self)
	if (unit and (unit ~= self.unit)) then
		return
	end
	
	if ((not UnitExists(unit)) or (self.maxMana == 0)) then
		self.frame:Hide()
		return
	else	
		self.frame:Show()
	end
	
	
	local manaType = UnitPowerType(self.unit)
	
	local color = "TargetMana"
	if (self.moduleSettings.scaleManaColor) then
		color = "ScaledManaColor"
	end
	if (manaType == 1) then
		color = "TargetRage"
	elseif (manaType == 2) then
		color = "TargetFocus"
	elseif (manaType == 3) then
		color = "TargetEnergy"
	end
	
	if (self.tapped) then
		color = "Tapped"
	end
	
	self:UpdateBar(self.mana/self.maxMana, color)

	if DogTag ~= nil then
		if self.moduleSettings.upperText ~= nil and self.moduleSettings.upperText ~= '' then
			self:SetBottomText1(DogTag:Evaluate("target", self.moduleSettings.upperText))
		end
		if self.moduleSettings.lowerText ~= nil and self.moduleSettings.lowerText ~= '' then
			self:SetBottomText2(DogTag:Evaluate("target", self.moduleSettings.lowerText))
		end
	else
		self:SetBottomText1(self.manaPercentage)
		self:SetBottomText2(self:GetFormattedText(self.mana, self.maxMana), color)
	end
end


-- OVERRIDE
function TargetMana.prototype:GetOptions()
	local opts = TargetMana.super.prototype.GetOptions(self)

	opts["scaleManaColor"] = {
		type = "toggle",
		name = "Color bar by mana %",
		desc = "Colors the mana bar from MaxManaColor to MinManaColor based on current mana %",
		get = function()
			return self.moduleSettings.scaleManaColor
		end,
		set = function(value)
			self.moduleSettings.scaleManaColor = value
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 51
	}

	return opts
end


-- Load us up
IceHUD.TargetMana = TargetMana:new()
