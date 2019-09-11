-- XP and Gold tracker

local frame = CreateFrame("FRAME");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_LEVEL_UP");
local g_xpAtSessionStart = 0;
local g_repGainedThisSession = 0;
local g_cashAtSessionStart = 0;
local g_faction = "";
local g_timeAtSessionStart = nil;
local g_xpTilNextLevel = 0;
local g_xpGainedThisSession = 0;
local g_levelsGained = 0;
local g_currentXp = 0;
local g_isOn = true;
local g_MAX_LEVEL = 60;

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if time() - g_timeAtSessionStart > 5 then
			PrettyPrint();
		end
	elseif event == "PLAYER_LOGIN" then
		InitVariables();
	elseif event == "PLAYER_LEVEL_UP" then
		g_levelsGained = g_levelsGained + 1;
		if g_levelsGained == 1 then 
			g_xpGainedThisSession = UnitXPMax("player") - g_xpAtSessionStart;
		else
			g_xpGainedThisSession = UnitXPMax("player") + g_xpGainedThisSession;
		end
	end
end)

function DisplayToDefaultChat(msg, r, g, b)
	if (g_isOn) then
		local red, green, blue;
		if r ~= nil and g ~= nil and b ~= nil then
			red = r;
			green = g;
			blue = b;
		else 
			red = 1;
			green = 1;
			blue = 0.5;
		end
		DEFAULT_CHAT_FRAME:AddMessage(msg, red,green,blue);
	end
end

function FormatTime(inTimeInSeconds) 
	local ret = "0 Hours 0 Minutes 0 Seconds";
	local seconds = tonumber(inTimeInSeconds);
	if seconds ~= nil then 
		local hours = math.floor(seconds / (60 * 60));
		seconds = seconds - (hours * 60 * 60);
		local minutes = math.floor(seconds / 60);
		seconds = seconds - (minutes * 60);
		ret = tostring(hours) .. " hours " .. tostring(minutes) .. " minutes " .. tostring(seconds) .. " seconds";
	end
	return ret;
end

function ElapsedTimeInSeconds(startTime)
	local ret;
	if g_timeAtSessionStart ~= nil then
		ret = (time() - startTime);
	else 
		ret = 0;
	end
	return ret;
end

function XpTilNextLevelETA(xpGained, timeElapsedInSeconds)
	local ret;
	if timeElapsedInSeconds > 0 and xpGained > 0 then
		local timeInHours = timeElapsedInSeconds / 60 / 60;
		ret = FormatTime(math.floor((UnitXPMax("player") - UnitXP("player")) / (xpGained / timeElapsedInSeconds)));
	elseif xpGained == 0 then
		ret = "Not available.";
	else
		ret = "Not available.";
	end;
	return ret;
end

function InitVariables()
	--init variables
	g_timeAtSessionStart = time();
	g_xpAtSessionStart = UnitXP("player");
	g_cashAtSessionStart = GetMoney();
	g_xpTilNextLevel = XpTilNextLevel();
	g_xpGainedThisSession = 0;
	g_levelsGained = 0;
end

function GoldRate(copperGained, timeElapsedInSeconds)
	local ret = "";
	if (timeElapsedInSeconds > 0) then
		if (copperGained == 0 ) then
			ret = "0 copper."
		else 
			local copperPerSecond = math.floor(copperGained / timeElapsedInSeconds);
			local timeIncrement, timeUnit = GetAppropriateTimeSegment(timeElapsedInSeconds);
			if (copperPerSecond < 0) then
				ret = "-" .. GetCoinText(math.floor((math.abs(copperPerSecond)  * timeIncrement)), " ") .. " per " .. timeUnit;
			else 
				ret = GetCoinText(math.floor((copperPerSecond  * timeIncrement)), " ") .. " per " .. timeUnit;
			end
		end;
	else
		ret = "time hasn't elapsed!";
	end
	return ret;
end

function GetAppropriateTimeSegment(timeElapsedInSeconds)
	local timeIncrement = 60;
	local timeUnit = "minute"
	if (timeElapsedInSeconds > 3600) then
		-- hour+
		timeIncrement = 60 * 60;
		timeUnit = " hour"
	elseif (timeElapsedInSeconds > 600) then
		-- 1/2 hour+
		timeIncrement = 60 * 30;
		timeUnit = " 30 minutes"
	end
	return timeIncrement, timeUnit;
end

function PrettyPrint()
	local timeInSeconds = ElapsedTimeInSeconds(g_timeAtSessionStart);
	PrettyPrintXp(timeInSeconds);
	PrettyPrintCash(timeInSeconds);
end

function PrettyPrintXp(inElapsedTime)
	if (UnitLevel("player") ~= g_MAX_LEVEL) then 
		local xpGained;
		if g_levelsGained > 0 then
			-- Get running level xp, plus whatever the player has right now (new level xp starts at 0)
			xpGained = g_xpGainedThisSession + UnitXP("player");
		else 
			--otherwise, we can just display the current xp minus the xp from the start
			xpGained = UnitXP("player") - g_xpAtSessionStart;
		end;
		
		local elapsedTime = inElapsedTime;
		if (elapsedTime == nil) then
			elapsedTime = ElapsedTimeInSeconds(g_timeAtSessionStart);
		end
		DisplayToDefaultChat("Time Elapsed: " .. FormatTime(elapsedTime));
		DisplayToDefaultChat("Experience gained during session so far: " .. xpGained);
		DisplayToDefaultChat("Levels gained during session so far: " .. g_levelsGained);
		DisplayToDefaultChat("ETA til next level: " .. XpTilNextLevelETA(xpGained, elapsedTime));
	end 
end

function PrettyPrintCash(inElapsedTime)
	local elapsedTime = inElapsedTime;
	if (elapsedTime == nil) then
		elapsedTime = ElapsedTimeInSeconds(g_timeAtSessionStart);
	end
	
	local netCash = GetMoney() - g_cashAtSessionStart;
	local cashMessageBase = "Cash gained during session so far: ";
	local cashMessage = cashMessageBase .. "Nothing!";
	if netCash > 0 then 
		cashMessage = cashMessageBase .. GetCoinText(netCash, " ");
	elseif netCash < 0 then
		cashMessage = cashMessageBase .. " -" .. GetCoinText(math.abs(netCash), " ");
	end
	DisplayToDefaultChat(cashMessage);
	DisplayToDefaultChat("Cash Rate: " .. GoldRate(netCash, elapsedTime));
end

function XpTilNextLevel()
	return (UnitXPMax("player") - UnitXP("player"));
end

SLASH_XP1 = "/xp";
SlashCmdList["XP"] = function(msg, editbox) 
	if msg == nil or msg == "" then
		PrettyPrint();
	elseif msg == "reset" then
		DisplayToDefaultChat("Resetting data.");
		InitVariables();
	end
end
