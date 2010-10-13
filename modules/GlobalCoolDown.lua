local L = LibStub("AceLocale-3.0"):GetLocale("IceHUD", false)
local GlobalCoolDown = IceCore_CreateClass(IceBarElement)

-- Constructor --
function GlobalCoolDown.prototype:init()
	GlobalCoolDown.super.prototype.init(self, "GlobalCoolDown")

	self.unit = "player"
	self.startTime = nil
	self.duration = nil

	self:SetDefaultColor("GlobalCoolDown", 0.1, 0.1, 0.1)
end

-- OVERRIDE
function GlobalCoolDown.prototype:Enable(core)
	GlobalCoolDown.super.prototype.Enable(self, core)

	--self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", "CooldownStateChanged")
	self:RegisterEvent("UNIT_SPELLCAST_START","CooldownStateChanged")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED","CooldownStateChanged")

	self:Show(false)

	self.frame:SetFrameStrata("TOOLTIP")
end

-- OVERRIDE
function GlobalCoolDown.prototype:GetDefaultSettings()
	local settings = GlobalCoolDown.super.prototype.GetDefaultSettings(self)

	settings["enabled"] = false
	settings["side"] = IceCore.Side.Left
	settings["offset"] = 6
	settings["shouldAnimate"] = true
	settings["hideAnimationSettings"] = true
	settings["desiredLerpTime"] = 1
	settings["lowThreshold"] = 0
	settings["barVisible"]["bg"] = false
	settings["usesDogTagStrings"] = false
	settings["bHideMarkerSettings"] = true

	return settings
end

-- OVERRIDE
function GlobalCoolDown.prototype:GetOptions()
	local opts = GlobalCoolDown.super.prototype.GetOptions(self)

	opts["lowThreshold"] = nil
	opts["textSettings"] = nil
	opts.alwaysFullAlpha = nil

	return opts
end

function GlobalCoolDown.prototype:CooldownStateChanged(event, unit, spell)
	if unit ~= "player" then
		return
	end

	local start, dur = GetSpellCooldown(spell)

	if start and dur ~= nil and dur > 0 and dur <= 1.5 then
		--local bRestart = not self.startTime or start > self.startTime + dur
		self.startTime = start
		self.duration = dur

		--if bRestart then
			self:SetScale(1, true)
			self.LastScale = 1
			self.DesiredScale = 0
			self.CurrLerpTime = 0
			self.moduleSettings.desiredLerpTime = dur or 1
		--end
		self.barFrame.bar:SetVertexColor(self:GetColor("GlobalCoolDown", 0.8))
		self:Show(true)
	end
end

function GlobalCoolDown.prototype:MyOnUpdate()
	GlobalCoolDown.super.prototype.MyOnUpdate(self)

	if self:IsVisible() and self.startTime ~= nil and self.duration ~= nil
		and self.startTime + self.duration <= GetTime() then
		self:Show(false)
	end
end

function GlobalCoolDown.prototype:CreateFrame()
	GlobalCoolDown.super.prototype.CreateFrame(self)

	self.barFrame.bar:SetVertexColor(self:GetColor("GlobalCoolDown", 0.8))
	local r, g, b = self.settings.backgroundColor.r, self.settings.backgroundColor.g, self.settings.backgroundColor.b
	self.frame.bg:SetVertexColor(r, g, b, 0.6)
end

-- Load us up
IceHUD.GlobalCoolDown = GlobalCoolDown:new()
