-- World Map

local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("PLAYER_LOGIN")

WorldMapFrame:SetScale(0.8)
WorldMapFrame.BlackoutFrame.Blackout:SetAlpha(0)
WorldMapFrame.BlackoutFrame:EnableMouse(false)

WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)

   local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f);
   local s = WorldMapFrame:GetScale();
   return x / s, y / s;

end