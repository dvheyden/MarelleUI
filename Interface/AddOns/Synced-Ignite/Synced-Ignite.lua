function Ignition_Onload()
	TickedStacks = 0;
	DEFAULT_CHAT_FRAME:AddMessage("Marelle's Synced Ignite Tracker loaded. Type /ig to toggle the frame.");
	--ChatFrame2:AddMessage("Synced Ignite Tracker loaded // by Marelle from Kronos");
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_HEALTH");
	-- when player leaves combat
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_LEAVE_COMBAT");

	this:RegisterForDrag();
	IgnitionFrame:Hide();
end

function Ignition_StartDragging()
	if ( ( ( not this.isLocked ) or ( this.isLocked == 0 ) ) and ( arg1 == "RightButton" ) ) then
		this:StartMoving();
		this.isMoving = true;
	end
end

function Ignition_StopDragging()
	if ( this.isMoving ) then
		this:StopMovingOrSizing();
		this.isMoving = false;
	end
end

function Ignition_OnEvent()
	-- Event triggered when the mob gets dot damage
	if(event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE") then
		for mob, tick, igniter in string.gfind(arg1, "(.+) suffers (.+) Fire damage from (.+) Ignite.") do
			if(mob == UnitName("target")) then
				TickedStacks = Ignition_GetIgniteStacksOnTarget();
				if(igniter == "your") then
					igniter = UnitName("player");
				end
				IgniteStarter = igniter;
				IgnitionFrameText2:SetText(string.gsub(igniter, "'s", "") .. " : " .. tick .. " (" .. Ignition_GetIgniteStacksOnTarget() .. ")");
			end
		end


	-- The next two events check when player leaves combat
	elseif(event == "PLAYER_REGEN_ENABLED") then
		IgnitionFrame:Hide();
	elseif(event == "PLAYER_LEAVE_COMBAT") then
		IgnitionFrame:Hide();
	
		
		
	--Triggered when the player changes targets
	elseif(event == "PLAYER_TARGET_CHANGED") then
		-- Set the first line of the ignition frame to the target's name
		IgnitionFrameText1:SetText(UnitName("target"));
		IgnitionFrameText1:SetVertexColor(1 , 1 , 1);
		-- Clear the second line till we get an ignite tick in the combat log
		if(UnitName("target") ~= nil) then
			IgnitionFrameText2:SetText("");
		else
			IgnitionFrameText2:SetText("");
		end
		
	-- Triggered when the debuffs on the target change
	elseif(event == "UNIT_AURA" and arg1 == "target") then
		if(Ignition_GetIgniteStacksOnTarget() == 0) then
			IgniteStarter = nil;
			IgnitionFrameText2:SetText("");
		elseif(Ignition_GetIgniteStacksOnTarget() > TickedStacks) then
			if(IgniteStarter ~= nil) then
				IgnitionFrameText2:SetText(IgniteStarter .. " : ?? (" .. Ignition_GetIgniteStacksOnTarget() .. ")");
			else
				IgnitionFrameText2:SetText("?? : ?? (" .. Ignition_GetIgniteStacksOnTarget() .. ")");
			end
			
		end
		
	-- Triggered when the target dies
	elseif(event == "UNIT_HEALTH" and arg1 == "target" and UnitHealth("target") == 0) then
		IgnitionFrameText1:SetText("");
		IgnitionFrameText2:SetText("");
	end
	
end

function Ignition_GetIgniteStacksOnTarget()
	local DebuffID = 1;
	while (UnitDebuff("target", DebuffID)) do
		if (string.find(UnitDebuff("target", DebuffID), "Spell_Fire_Incinerate")) then
			_, IgniteStacks = UnitDebuff("target", DebuffID);
			IgnitionFrame:Show();
			return IgniteStacks;
		end
		DebuffID = DebuffID + 1;
	end
	return 0;
end

function IG_Command()
	if IgnitionFrame:IsShown() then
		IgnitionFrame:Hide()
	else
		IgnitionFrame:Show()
	end
end
	

SlashCmdList["IG"] = function(_msg)
	IG_Command()
end

SLASH_IG1 = "/ig";