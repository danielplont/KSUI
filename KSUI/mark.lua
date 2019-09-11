-- BaudMark

local KeyHeld;

function Mark_OnLoad(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");

	BINDING_HEADER_Mark = "Mark";
	BINDING_NAME_Mark = "Mark Targets(Hold)";

	local Button, Angle;
	for Index = 0, 8 do
		Button = CreateFrame("Button", "MarkIconButton"..Index, self);
		Button:SetWidth(30);
		Button:SetHeight(30);
		Button:SetID(Index);
		Button.Texture = Button:CreateTexture(Button:GetName().."NormalTexture", "ARTWORK");
		Button.Texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
		Button.Texture:SetAllPoints();
		SetRaidTargetIconTexture(Button.Texture, Index);
		Button:RegisterForClicks("LeftButtonUp","RightButtonUp");
		Button:SetScript("OnClick", MarkButton_OnClick);
		Button:SetScript("OnEnter", MarkButton_OnEnter);
		Button:SetScript("OnLeave", MarkButton_OnLeave);
		if(Index==0)then
			Button:SetPoint("CENTER");
		else
			Angle = 360 / 8 * Index;
			Button:SetPoint("CENTER", sin(Angle) * 50, cos(Angle) * 50);
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage("Mark: AddOn Loaded.  Version "..GetAddOnMetadata("Mark","Version")..".");
end


function MarkCanMark()
	if IsInRaid()
	and not (UnitIsGroupLeader("player"))
	and not (UnitIsGroupAssistant("player")) 
	then 
		UIErrorsFrame:AddMessage("You don't have permission to mark targets.", 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME);
		return false; 
	else
		return true; 
	end
end


function Mark_HotkeyPressed(keystate)
	KeyHeld = (keystate=="down")
	if KeyHeld
	and MarkCanMark(true)
	then
		MarkShowIcons();
	else
		MarkFrame:Hide();
	end
end


function Mark_OnEvent(self, event)
	if(event=="PLAYER_TARGET_CHANGED")then
		if KeyHeld then
			MarkShowIcons();
		end
	end
end


function MarkShowIcons()
	if not UnitExists("target")or UnitIsDead("target")then
		return;
	end
	local X, Y = GetCursorPosition();
	local Scale = UIParent:GetEffectiveScale();
	MarkFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", X / Scale, Y / Scale);
	MarkFrame:Show();
end


function MarkButton_OnEnter(self)
	self.Texture:ClearAllPoints();
	self.Texture:SetPoint("TOPLEFT", -5, 5);
	self.Texture:SetPoint("BOTTOMRIGHT", 5, -5);
end


function MarkButton_OnLeave(self)
	self.Texture:SetAllPoints();
end


function MarkButton_OnClick(self)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	SetRaidTargetIcon("target", (arg1~="RightButton")and self:GetID()or 0);
	MarkFrame:Hide();
end