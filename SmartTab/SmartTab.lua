-- SmartTab v2.0 by @Nelkel
-- Automatically swaps the 'Target Nearest Enemy' keybind to 'Target Nearest Enemy Player' in PvP zones.

local originalTabKey = nil;
local isInPvPZone = false;

-- Function to check PvP status using the reliable GetInstanceInfo
function SmartTab_CheckPvPStatus()
    local _, instanceType = GetInstanceInfo();
    local inPvP = (instanceType == "pvp" or instanceType == "arena");

    if inPvP and not isInPvPZone then
        -- We just entered a PvP zone
        SmartTab_EnablePvPMode();
    elseif not inPvP and isInPvPZone then
        -- We just left a PvP zone
        SmartTab_DisablePvPMode();
    end
end

-- Function to enable PvP targeting by changing the keybind
function SmartTab_EnablePvPMode()
    -- Get the key currently bound to the "Target Nearest Enemy" action
    originalTabKey = GetBindingKey("TARGETNEARESTENEMY");

    if originalTabKey then
        -- If a key is bound, rebind it to the "Target Nearest Enemy Player" action
        SetBinding(originalTabKey, "TARGETNEARESTENEMYPLAYER");
        -- Save the change for the current character's binding set
        SaveBindings(GetCurrentBindingSet());
        
        isInPvPZone = true;
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700SmartTab: |rPvP mode enabled. '" .. originalTabKey .. "' now targets enemy players only.", 1, 1, 0);
    else
        isInPvPZone = true;
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700SmartTab: |rPvP mode enabled, but no key was bound to 'Target Nearest Enemy' to modify.", 1, 1, 0);
    end
end

-- Function to disable PvP targeting by restoring the original keybind
function SmartTab_DisablePvPMode()
    if originalTabKey then
        -- If we had stored a key, restore its original binding
        SetBinding(originalTabKey, "TARGETNEARESTENEMY");
        SaveBindings(GetCurrentBindingSet());
        
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700SmartTab: |rNormal mode restored. '" .. originalTabKey .. "' targets all enemies again.", 1, 1, 0);
    else
        -- No key was originally bound, so nothing to restore.
        DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700SmartTab: |rNormal mode restored.", 1, 1, 0);
    end
    
    originalTabKey = nil; -- Clear the stored key for the next time
    isInPvPZone = false;
end

local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD"); -- Fires on login, reload, zone change
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA"); -- Fires when moving between major zones

frame:SetScript("OnEvent", function(self, event, ...)
    SmartTab_CheckPvPStatus();
end);

SmartTab_CheckPvPStatus();