pfUI:RegisterModule("player", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.player.pspace

  PlayerFrame:Hide()
  PlayerFrame:UnregisterAllEvents()

  pfUI.uf.player = pfUI.uf:CreateUnitFrame("Player", nil, C.unitframes.player)

  pfUI.uf.player:UpdateFrameSize()
  pfUI.uf.player:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -75, 125)
  UpdateMovable(pfUI.uf.player)

  -- Replace default's RESET_INSTANCES button with an always working one
  UnitPopupButtons["RESET_INSTANCES_FIX"] = { text = RESET_INSTANCES, dist = 0 };
  UnitPopupMenus["SELF"] = { "LOOT_METHOD", "LOOT_THRESHOLD", "LOOT_PROMOTE", "LEAVE", "RESET_INSTANCES_FIX", "RAID_TARGET_ICON", "CANCEL" };

  hooksecurefunc("UnitPopup_OnClick", function()
    local button = this.value
    if button == "RESET_INSTANCES_FIX" then
      StaticPopup_Show("CONFIRM_RESET_INSTANCES")
    end
  end)

  if C.unitframes.player.energy == "1" then
    pfUI.uf.player.power.tick = CreateFrame("Frame", nil, pfUI.uf.player.power.bar)
    pfUI.uf.player.power.tick:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.uf.player.power.tick:RegisterEvent("UNIT_DISPLAYPOWER")

    pfUI.uf.player.power.tick:SetScript("OnShow", function()
      this.spark:Show()
    end)

    pfUI.uf.player.power.tick:SetScript("OnHide", function()
      this.spark:Hide()
    end)

    pfUI.uf.player.power.tick:SetScript("OnEvent", function()
      if event == "PLAYER_ENTERING_WORLD" then this.lastTick = GetTime() end
      if event == "PLAYER_ENTERING_WORLD" or ( event == "UNIT_DISPLAYPOWER" and arg1 == "player" ) then
        if UnitPowerType("player") ~= 3 then
          this:Hide()
        else
          this:Show()
        end
      end
    end)

    pfUI.uf.player.power.tick.spark = pfUI.uf.player.power.bar:CreateTexture(nil, 'OVERLAY')
    pfUI.uf.player.power.tick.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    pfUI.uf.player.power.tick.spark:SetHeight(C.unitframes.player.pheight + 15)
    pfUI.uf.player.power.tick.spark:SetWidth(C.unitframes.player.pheight + 5)
    pfUI.uf.player.power.tick.spark:SetBlendMode('ADD')

    -- update spark size on player frame changes
    local hookUpdateConfig = pfUI.uf.player.UpdateConfig
    function pfUI.uf.player.UpdateConfig()
      -- update spark sizes
      local spark = pfUI.uf.player.power.tick.spark
      spark:SetHeight(C.unitframes.player.pheight + 15)
      spark:SetWidth(C.unitframes.player.pheight + 5)

      -- run default unitframe update function
      hookUpdateConfig(pfUI.uf.player)
    end

    pfUI.uf.player.power.tick:SetScript("OnUpdate", function()
      if UnitPowerType("player") ~= 3 then this:Hide() end
      if not this.energy then this.energy = UnitMana("player") end

      if(UnitMana("player") > this.energy or GetTime() >= this.lastTick + 2) then
        this.lastTick = GetTime()
      end

      this.energy = UnitMana("player")

      local value = round((GetTime() - this.lastTick) * 100)
      local pos = (C.unitframes.player.pwidth ~= "-1" and C.unitframes.player.pwidth or C.unitframes.player.width) / 200 * value
      if not C.unitframes.player.pheight then return end
      this.spark:SetPoint("LEFT", pos-((C.unitframes.player.pheight+5)/2), 0)
    end)
  end
end)
