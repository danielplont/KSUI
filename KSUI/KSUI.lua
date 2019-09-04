-- World Map

local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("PLAYER_LOGIN")

EventFrame:SetScript("OnEvent", function(self,event,...) 
   PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, .3, 3.0, .5) 
end)

WorldMapFrame:SetScale(0.8)
WorldMapFrame.BlackoutFrame.Blackout:SetAlpha(0)
WorldMapFrame.BlackoutFrame:EnableMouse(false)

WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)

   local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f);
   local s = WorldMapFrame:GetScale();
   return x / s, y / s;

end

-- eAlign Grid

SLASH_EA1 = "/align"

local f

SlashCmdList["EA"] = function()

   if f then
      
	   f:Hide()
      f = nil		
      
   else

		f = CreateFrame('Frame', nil, UIParent) 
      f:SetAllPoints(UIParent)
      
		local w = GetScreenWidth() / 64
      local h = GetScreenHeight() / 36

      for i = 0, 64 do
         
         local t = f:CreateTexture(nil, 'BACKGROUND')
         
			if i == 32 then
				t:SetColorTexture(1, 1, 0, 0.5)
			else
				t:SetColorTexture(1, 1, 1, 0.15)
         end
         
			t:SetPoint('TOPLEFT', f, 'TOPLEFT', i * w - 1, 0)
         t:SetPoint('BOTTOMRIGHT', f, 'BOTTOMLEFT', i * w + 1, 0)
         
      end
      
      for i = 0, 36 do
         
         local t = f:CreateTexture(nil, 'BACKGROUND')
         
			if i == 18 then
				t:SetColorTexture(1, 1, 0, 0.5)
			else
				t:SetColorTexture(1, 1, 1, 0.15)
         end
         
			t:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, -i * h + 1)
         t:SetPoint('BOTTOMRIGHT', f, 'TOPRIGHT', 0, -i * h - 1)
         
		end	
	end
end