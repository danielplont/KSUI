-- Player castbar

CastingBarFrame:SetScale(1.2)
CastingBarFrame:SetSize(150, 10)
CastingBarFrame:ClearAllPoints()
CastingBarFrame:SetPoint("TOP", WorldFrame, "BOTTOM", 0, 150)
CastingBarFrame.SetPoint = function()
end
CastingBarFrame.Border:Hide()
CastingBarFrame.Border:SetSize(240, 40)
CastingBarFrame.Border:SetPoint("TOP", CastingBarFrame, 0, 15)
CastingBarFrame.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")

CastingBarFrame.Flash:SetSize(240, 40)
CastingBarFrame.Flash:SetPoint("TOP", CastingBarFrame, 0, 15)
CastingBarFrame.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")

CastingBarFrame.Text:SetPoint("TOP", CastingBarFrame, 0, 4)

-- Castbar timer
CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
CastingBarFrame.timer:SetFont("Fonts\\ARIALN.ttf", 13, "THINOUTLINE")
CastingBarFrame.timer:SetPoint("RIGHT", CastingBarFrame, "RIGHT", 24, 0)
CastingBarFrame.update = 0.1

local function CastingBarFrame_OnUpdate_Hook(self, elapsed)
	if not self.timer then
		return
	end
	if self.update and self.update < elapsed then
		if self.casting then
			self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
		elseif self.channeling then
			self.timer:SetText(format("%.1f", max(self.value, 0)))
		else
			self.timer:SetText("")
		end
		self.update = .1
	else
		self.update = self.update - elapsed
	end
end

CastingBarFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)