pfUI:RegisterModule("actionbar", function ()
  -- override defaultUI functions to always show grid
  function ActionButton_ShowGrid(button) return end
  function ActionButton_HideGrid(button) return end

  if not Hook_ShowBonusActionBar then
    Hook_ShowBonusActionBar = ShowBonusActionBar
  end

  function ShowBonusActionBar()
    for i=1, 12 do getglobal("ActionButton" .. i):SetAlpha(0) end
    Hook_ShowBonusActionBar()
  end

  if not Hook_HideBonusActionBar then
    Hook_HideBonusActionBar = HideBonusActionBar
  end

  function HideBonusActionBar()
    for i=1, 12 do getglobal("ActionButton" .. i):SetAlpha(1) end
    Hook_HideBonusActionBar()
  end

  function ActionButton_GetPagedID(button)
    if ( button.isBonus and CURRENT_ACTIONBAR_PAGE == 1 ) then
      local offset = GetBonusBarOffset()
      if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
        offset = BonusActionBarFrame.lastBonusBar
      end
      return (button:GetID() + ((NUM_ACTIONBAR_PAGES + offset - 1) * NUM_ACTIONBAR_BUTTONS))
    end

    local parentName = button:GetParent():GetName()
    if ( parentName == "pfMultiBarBottomLeft" or parentName == "MultiBarBottomLeft" )  then
      return (button:GetID() + ((BOTTOMLEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    elseif ( parentName == "pfMultiBarBottomRight" or parentName == "MultiBarBottomRight" ) then
      return (button:GetID() + ((BOTTOMRIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    elseif ( parentName == "pfMultiBarLeft" or parentName == "MultiBarLeft" ) then
      return (button:GetID() + ((LEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    elseif ( parentName == "pfMultiBarRight" or parentName == "MultiBarRight" ) then
      return (button:GetID() + ((RIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    else
      return (button:GetID() + ((CURRENT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
    end
  end

  -- hide default blizz
  MainMenuBar:Hide()
  BonusActionBarTexture0:Hide()
  BonusActionBarTexture1:Hide()

  -- hide background texture of petactionbar
  SlidingActionBarTexture0:Hide()
  SlidingActionBarTexture0.Show = function () return end

  SlidingActionBarTexture1:Hide()
  SlidingActionBarTexture1.Show = function () return end

  -- create action bar frame
  pfUI.bars = CreateFrame("Frame",nil,UIParent)
  pfUI.bars:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.bars:RegisterEvent("CVAR_UPDATE")
  pfUI.bars:RegisterEvent("UNIT_FLAGS")
  pfUI.bars:RegisterEvent("UNIT_PET")
  pfUI.bars:RegisterEvent("PET_BAR_UPDATE")
  pfUI.bars:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
  pfUI.bars:RegisterEvent("PLAYER_CONTROL_GAINED")
  pfUI.bars:RegisterEvent("PLAYER_CONTROL_LOST")
  pfUI.bars:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
  pfUI.bars:RegisterEvent("UNIT_AURA")
  pfUI.bars:RegisterEvent("PET_BAR_SHOWGRID")
  pfUI.bars:RegisterEvent("PET_BAR_HIDEGRID")

  pfUI.bars.shapeshift = CreateFrame("Frame", "pfBarShapeshift", UIParent)
  pfUI.bars.bottomleft = CreateFrame("Frame", "pfBarBottomLeft", UIParent)
  pfUI.bars.bottomright = CreateFrame("Frame", "pfBarBottomRight", UIParent)
  pfUI.bars.vertical = CreateFrame("Frame", "pfBarVertical", UIParent)
  pfUI.bars.pet = CreateFrame("Frame", "pfBarPet", UIParent)

  PetActionBarFrame:SetParent(pfUI.bars.pet)

  pfUI.bars:SetScript("OnEvent", function()
      local bpc = 1; if MultiBarBottomLeft:IsShown() then bpc = bpc + 1 end -- bottom panel count
      pfUI.bars.bottom:SetWidth(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 12 + pfUI_config.bars.border * 12)
      pfUI.bars.bottom:SetHeight(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * bpc + pfUI_config.bars.border * bpc)

      if (PetHasActionBar()) then
        PetActionBar_Update()
        pfUI.bars.pet:Show()
        pfUI.bars.pet:SetFrameStrata("LOW")
        pfUI.bars.pet:SetPoint("BOTTOM", pfUI.bars.bottom, "TOP", 0, 5)
        pfUI.utils:loadPosition(pfUI.bars.pet)
        pfUI.bars.pet:SetBackdrop(pfUI.backdrop)
        pfUI.bars.pet:SetWidth(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 10 + pfUI_config.bars.border * 10)
        pfUI.bars.pet:SetHeight(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 1 + pfUI_config.bars.border)

        PetActionBarFrame:ClearAllPoints()
        PetActionBarFrame:Hide()

        for i=1, 10 do
          local b = getglobal("PetActionButton"..i)
          local b2 = getglobal("PetActionButton"..i-1) or b
          b:ClearAllPoints()
          b:SetParent(pfUI.bars.pet)
          if i == 1 then
            b:SetPoint("BOTTOMLEFT", pfUI_config.bars.border*2, pfUI_config.bars.border*2)
          else
            b:SetPoint("LEFT", b2, "RIGHT", pfUI_config.bars.border, 0)
          end
        end
      else
        pfUI.bars.pet:Hide()
      end

      local shapeshiftbuttons = 0
      if ShapeshiftButton1:IsShown() then
        pfUI.bars.shapeshift:Show()
      else
        pfUI.bars.shapeshift:Hide()
      end

      ShapeshiftBarFrame:ClearAllPoints()
      ShapeshiftBarFrame:SetAllPoints(pfUI.bars.shapeshift)

      for i=1, 10 do
        local b = getglobal("ShapeshiftButton"..i)
        local b2 = getglobal("ShapeshiftButton"..i-1) or b
        b:ClearAllPoints()
        b:SetParent(pfUI.bars.shapeshift)
        if i == 1 then
          b:SetPoint("BOTTOMLEFT", pfUI_config.bars.border*2, pfUI_config.bars.border*2)
        else
          b:SetPoint("LEFT", b2, "RIGHT", pfUI_config.bars.border, 0)
        end
        if b:IsShown() then shapeshiftbuttons = shapeshiftbuttons + 1 end
      end

      pfUI.bars.shapeshift:SetFrameStrata("LOW")
      pfUI.bars.shapeshift:SetPoint("BOTTOM", pfUI.bars.bottom, "TOP", 0, 5)
      pfUI.utils:loadPosition(pfUI.bars.shapeshift)
      pfUI.bars.shapeshift:SetBackdrop(pfUI.backdrop)
      pfUI.bars.shapeshift:SetWidth(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * shapeshiftbuttons + pfUI_config.bars.border * shapeshiftbuttons)
      pfUI.bars.shapeshift:SetHeight(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 1 + pfUI_config.bars.border)

      if SHOW_MULTI_ACTIONBAR_1 then
        MultiBarBottomLeft:SetParent(pfUI.bars.bottom)
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetAllPoints(pfUI.bars.bottom)

        -- create temp frame to give a named parent to the buttons
        local tf = CreateFrame("Frame", "pfMultiBarBottomLeft", UIParent )
        tf:SetParent(pfUI.bars.bottom)
        tf:SetAllPoints(pfUI.bars.bottom)

        for i=1, 12 do
          local b = getglobal("MultiBarBottomLeftButton"..i)
          local b2 = getglobal("MultiBarBottomLeftButton"..i-1) or b
          b:ClearAllPoints()
          b:SetParent(tf)

          if i == 1 then
            b:SetPoint("BOTTOM", ActionButton1, "TOP", 0, pfUI_config.bars.border)
          else
            b:SetPoint("LEFT", b2, "RIGHT", pfUI_config.bars.border, 0)
          end
        end
      end

      if SHOW_MULTI_ACTIONBAR_2 then
        pfUI.bars.bottomleft:Show()
        pfUI.bars.bottomleft:SetFrameStrata("LOW")
        pfUI.bars.bottomleft:SetPoint("BOTTOMRIGHT", pfUI.bars.bottom, "BOTTOMLEFT", -5, 0)
        pfUI.utils:loadPosition(pfUI.bars.bottomleft)
        pfUI.bars.bottomleft:SetBackdrop(pfUI.backdrop)
        pfUI.bars.bottomleft:SetWidth(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 6 + pfUI_config.bars.border * 6)
        pfUI.bars.bottomleft:SetHeight(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 2 + pfUI_config.bars.border * 2)

        MultiBarBottomRight:SetParent(pfUI.bars.bottomleft)
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetAllPoints(pfUI.bars.bottomleft)

        -- create temp frame to give a named parent to the buttons
        local tf = CreateFrame("Frame", "pfMultiBarBottomRight", UIParent )
        tf:SetParent(pfUI.bars.bottomleft)
        tf:SetAllPoints(pfUI.bars.bottomleft)

        for i=1, 6 do
          local b = getglobal("MultiBarBottomRightButton"..i)
          local b2 = getglobal("MultiBarBottomRightButton"..i-1) or b
          b:ClearAllPoints()
          b:SetParent(tf)

          if i == 1 then
            b:SetPoint("BOTTOMLEFT", pfUI_config.bars.border*2, pfUI_config.bars.border*2)
          else
            b:SetPoint("LEFT", b2, "RIGHT", pfUI_config.bars.border, 0)
          end
        end
        for i=7, 12 do
          local b = getglobal("MultiBarBottomRightButton"..i)
          local b2 = getglobal("MultiBarBottomRightButton"..i-6)
          b:ClearAllPoints()
          b:SetParent(tf)

          b:SetPoint("LEFT", b2, "RIGHT", -pfUI_config.bars.icon_size, pfUI_config.bars.icon_size + pfUI_config.bars.border)
        end
      else
        pfUI.bars.bottomleft:Hide()
      end

      if SHOW_MULTI_ACTIONBAR_3 then
        pfUI.bars.bottomright:Show()
        pfUI.bars.bottomright:SetFrameStrata("LOW")
        pfUI.bars.bottomright:SetPoint("BOTTOMLEFT", pfUI.bars.bottom, "BOTTOMRIGHT", 5, 0)
        pfUI.utils:loadPosition(pfUI.bars.bottomright)
        pfUI.bars.bottomright:SetBackdrop(pfUI.backdrop)
        pfUI.bars.bottomright:SetWidth(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 6 + pfUI_config.bars.border * 6)
        pfUI.bars.bottomright:SetHeight(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 2 + pfUI_config.bars.border * 2)

        MultiBarRight:SetParent(pfUI.bars.bottomright)
        MultiBarRight:ClearAllPoints()
        MultiBarRight:SetAllPoints(pfUI.bars.bottomright)

        -- create temp frame to give a named parent to the buttons
        local tf = CreateFrame("Frame", "pfMultiBarRight", UIParent )
        tf:SetParent(pfUI.bars.bottomright)
        tf:SetAllPoints(pfUI.bars.bottomright)

        for i=1, 6 do
          local b = getglobal("MultiBarRightButton"..i)
          local b2 = getglobal("MultiBarRightButton"..i-1) or b
          b:ClearAllPoints()
          b:SetParent(tf)

          if i == 1 then
            b:SetPoint("BOTTOMLEFT", pfUI_config.bars.border*2, pfUI_config.bars.border*2)
          else
            b:SetPoint("LEFT", b2, "RIGHT", pfUI_config.bars.border, 0)
          end
        end
        for i=7, 12 do
          local b = getglobal("MultiBarRightButton"..i)
          local b2 = getglobal("MultiBarRightButton"..i-6)
          b:ClearAllPoints()
          b:SetParent(tf)

          b:SetPoint("LEFT", b2, "RIGHT", -pfUI_config.bars.icon_size, pfUI_config.bars.icon_size + pfUI_config.bars.border)
        end
      else
        pfUI.bars.bottomright:Hide()
      end

      if SHOW_MULTI_ACTIONBAR_4 and SHOW_MULTI_ACTIONBAR_3 then
        pfUI.bars.vertical:Show()
        pfUI.bars.vertical:SetFrameStrata("LOW")
        pfUI.bars.vertical:SetPoint("RIGHT", -5, 0)
        pfUI.utils:loadPosition(pfUI.bars.vertical)
        pfUI.bars.vertical:SetBackdrop(pfUI.backdrop)
        pfUI.bars.vertical:SetWidth(pfUI_config.bars.border*4 + pfUI_config.bars.icon_size)
        pfUI.bars.vertical:SetHeight(pfUI_config.bars.border*3 + pfUI_config.bars.icon_size * 12 + pfUI_config.bars.border * 12)

        MultiBarLeft:SetParent(pfUI.bars.vertical)
        MultiBarLeft:ClearAllPoints()
        MultiBarLeft:SetAllPoints(pfUI.bars.vertical)

        -- create temp frame to give a named parent to the buttons
        local tf = CreateFrame("Frame", "pfMultiBarLeft", UIParent )
        tf:SetParent(pfUI.bars.vertical)
        tf:SetAllPoints(pfUI.bars.vertical)

        for i=1, 12 do
          local b = getglobal("MultiBarLeftButton"..i)
          local b2 = getglobal("MultiBarLeftButton"..i-1) or b
          b:ClearAllPoints()
          b:SetParent(tf)

          if i == 1 then
            b:SetPoint("TOPLEFT", pfUI_config.bars.border*2, -pfUI_config.bars.border*2)
          else
            b:SetPoint("TOP", b2, "BOTTOM", 0, -pfUI_config.bars.border)
          end
        end
      else
        pfUI.bars.vertical:Hide()
      end
    end)

  -- create bottom bar frame
  pfUI.bars.bottom = CreateFrame("Frame", "pfBarBottom", UIParent)
  pfUI.bars.bottom:SetFrameStrata("LOW")
  pfUI.bars.bottom:SetPoint("BOTTOM", 0, 5)
  pfUI.utils:loadPosition(pfUI.bars.bottom)
  pfUI.bars.bottom:SetBackdrop(pfUI.backdrop)

  for i=1, 12 do
    local b = getglobal("ActionButton"..i)
    local b2 = getglobal("ActionButton"..i-1) or b
    b:ClearAllPoints()
    b:SetParent(pfUI.bars.bottom)
    if i == 1 then
      b:SetPoint("BOTTOMLEFT", pfUI_config.bars.border*2, pfUI_config.bars.border*2)
    else
      b:SetPoint("LEFT", b2, "RIGHT", pfUI_config.bars.border, 0)
    end
  end

  BonusActionBarFrame:ClearAllPoints()
  BonusActionBarFrame:SetParent(pfUI.bars.bottom)
  BonusActionBarFrame:SetAllPoints(pfUI.bars.bottom)
  BonusActionBarFrame:EnableMouse(0)

  for i=1, 12 do
    local b = getglobal("BonusActionButton"..i)
    local b2 = getglobal("BonusActionButton"..i-1) or b
    b:ClearAllPoints()
    b:SetParent(BonusActionBarFrame)
    if i == 1 then
      b:SetPoint("BOTTOMLEFT", pfUI_config.bars.border*2 - 4, pfUI_config.bars.border*2)
    else
      b:SetPoint("LEFT", b2, "RIGHT", pfUI_config.bars.border, 0)
    end
  end

  for i = 1, 10 do
    getglobal("ShapeshiftButton"..i):SetBackdrop(pfUI.backdrop)
    getglobal("ShapeshiftButton"..i):SetBackdropColor(0,0,0,0)
    getglobal("ShapeshiftButton"..i):SetWidth(pfUI_config.bars.icon_size)
    getglobal("ShapeshiftButton"..i):SetHeight(pfUI_config.bars.icon_size)
    getglobal("ShapeshiftButton"..i):Show()
    getglobal("ShapeshiftButton"..i).showgrid = 1
    getglobal("ShapeshiftButton"..i..'Icon'):SetAllPoints(getglobal("ShapeshiftButton"..i))
    getglobal("ShapeshiftButton"..i..'Border'):SetTexture(1,1,0,1)
    getglobal("ShapeshiftButton"..i..'NormalTexture'):SetAlpha(0)
    getglobal("ShapeshiftButton"..i..'NormalTexture'):SetPoint("TOPLEFT", getglobal("ShapeshiftButton"..i) ,"TOPLEFT", -5, 5)
    getglobal("ShapeshiftButton"..i..'NormalTexture'):SetPoint("BOTTOMRIGHT", getglobal("ShapeshiftButton"..i) ,"BOTTOMRIGHT", 5, -5)
    getglobal("ShapeshiftButton"..i..'Border'):SetPoint("TOPLEFT", getglobal("ShapeshiftButton"..i) ,"TOPLEFT", 1, -1)
    getglobal("ShapeshiftButton"..i..'Border'):SetPoint("BOTTOMRIGHT", getglobal("ShapeshiftButton"..i) ,"BOTTOMRIGHT", -1, 1)
    getglobal("ShapeshiftButton"..i..'HotKey'):SetPoint("TOPLEFT", getglobal("ShapeshiftButton"..i) ,"TOPLEFT", 1, -1)
    getglobal("ShapeshiftButton"..i..'HotKey'):SetPoint("BOTTOMRIGHT", getglobal("ShapeshiftButton"..i) ,"BOTTOMRIGHT", -1, 1)
    getglobal("ShapeshiftButton"..i..'HotKey'):SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size - 2, "OUTLINE")
    getglobal("ShapeshiftButton"..i..'HotKey'):SetJustifyH("RIGHT")
    getglobal("ShapeshiftButton"..i..'HotKey'):SetJustifyV("TOP")
    getglobal("ShapeshiftButton"..i..'Name'):SetPoint("TOPLEFT", getglobal("ShapeshiftButton"..i) ,"TOPLEFT", 1, -1)
    getglobal("ShapeshiftButton"..i..'Name'):SetPoint("BOTTOMRIGHT", getglobal("ShapeshiftButton"..i) ,"BOTTOMRIGHT", -1, 1)
    getglobal("ShapeshiftButton"..i..'Name'):SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size - 2, "OUTLINE")
    getglobal("ShapeshiftButton"..i..'Name'):SetJustifyH("CENTER")
    getglobal("ShapeshiftButton"..i..'Name'):SetJustifyV("BOTTOM")
  end

  for i = 1, 10 do
    getglobal("PetActionButton"..i):SetBackdrop(pfUI.backdrop)
    getglobal("PetActionButton"..i):SetBackdropColor(0,0,0,0)
    getglobal("PetActionButton"..i):SetWidth(pfUI_config.bars.icon_size)
    getglobal("PetActionButton"..i):SetHeight(pfUI_config.bars.icon_size)
    getglobal("PetActionButton"..i):Show()
    getglobal("PetActionButton"..i).showgrid = 1
    getglobal("PetActionButton"..i..'AutoCast'):SetScale(.75)
    getglobal("PetActionButton"..i..'AutoCast'):SetAlpha(.50)
    getglobal("PetActionButton"..i..'AutoCastable'):SetAlpha(0)
    getglobal("PetActionButton"..i..'Icon'):SetAllPoints(getglobal("PetActionButton"..i))
    getglobal("PetActionButton"..i..'Border'):SetTexture(1,1,0,1)
    getglobal("PetActionButton"..i..'NormalTexture2'):SetAlpha(0)
    getglobal("PetActionButton"..i..'NormalTexture2'):SetPoint("TOPLEFT", getglobal("PetActionButton"..i) ,"TOPLEFT", -5, 5)
    getglobal("PetActionButton"..i..'NormalTexture2'):SetPoint("BOTTOMRIGHT", getglobal("PetActionButton"..i) ,"BOTTOMRIGHT", 5, -5)
    getglobal("PetActionButton"..i..'Border'):SetPoint("TOPLEFT", getglobal("PetActionButton"..i) ,"TOPLEFT", 1, -1)
    getglobal("PetActionButton"..i..'Border'):SetPoint("BOTTOMRIGHT", getglobal("PetActionButton"..i) ,"BOTTOMRIGHT", -1, 1)
    getglobal("PetActionButton"..i..'HotKey'):SetPoint("TOPLEFT", getglobal("PetActionButton"..i) ,"TOPLEFT", 1, -1)
    getglobal("PetActionButton"..i..'HotKey'):SetPoint("BOTTOMRIGHT", getglobal("PetActionButton"..i) ,"BOTTOMRIGHT", -1, 1)
    getglobal("PetActionButton"..i..'HotKey'):SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size - 2, "OUTLINE")
    getglobal("PetActionButton"..i..'HotKey'):SetJustifyH("RIGHT")
    getglobal("PetActionButton"..i..'HotKey'):SetJustifyV("TOP")
    getglobal("PetActionButton"..i..'Name'):SetPoint("TOPLEFT", getglobal("PetActionButton"..i) ,"TOPLEFT", 1, -1)
    getglobal("PetActionButton"..i..'Name'):SetPoint("BOTTOMRIGHT", getglobal("PetActionButton"..i) ,"BOTTOMRIGHT", -1, 1)
    getglobal("PetActionButton"..i..'Name'):SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size - 2, "OUTLINE")
    getglobal("PetActionButton"..i..'Name'):SetJustifyH("CENTER")
    getglobal("PetActionButton"..i..'Name'):SetJustifyV("BOTTOM")
  end

  -- theme all actionbars (spacing, size, border, text position and style)
  local actionbars = { "ActionButton", "MultiBarLeftButton", "MultiBarRightButton",
    "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "BonusActionButton", }

  for i = 1, 12 do
    for _, button in pairs(actionbars) do
      getglobal(button..i..'NormalTexture'):SetAlpha(0)
      getglobal(button..i):SetBackdrop(pfUI.backdrop)
      getglobal(button..i):SetBackdropColor(0,0,0,0)

      getglobal(button..i):SetWidth(pfUI_config.bars.icon_size)
      getglobal(button..i):SetHeight(pfUI_config.bars.icon_size)
      getglobal(button..i):Show()
      getglobal(button..i).showgrid = 1

      getglobal(button..i..'Icon'):SetAllPoints(getglobal(button..i))
      getglobal(button..i..'Border'):SetTexture(1,1,0,1)
      getglobal(button..i..'NormalTexture'):SetPoint("TOPLEFT", getglobal(button..i) ,"TOPLEFT", -5, 5)
      getglobal(button..i..'NormalTexture'):SetPoint("BOTTOMRIGHT", getglobal(button..i) ,"BOTTOMRIGHT", 5, -5)
      getglobal(button..i..'Border'):SetPoint("TOPLEFT", getglobal(button..i) ,"TOPLEFT", 1, -1)
      getglobal(button..i..'Border'):SetPoint("BOTTOMRIGHT", getglobal(button..i) ,"BOTTOMRIGHT", -1, 1)
      getglobal(button..i..'HotKey'):SetPoint("TOPLEFT", getglobal(button..i) ,"TOPLEFT", 1, -1)
      getglobal(button..i..'HotKey'):SetPoint("BOTTOMRIGHT", getglobal(button..i) ,"BOTTOMRIGHT", -1, 1)
      getglobal(button..i..'HotKey'):SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size - 2, "OUTLINE")
      getglobal(button..i..'HotKey'):SetJustifyH("RIGHT")
      getglobal(button..i..'HotKey'):SetJustifyV("TOP")
      getglobal(button..i..'Name'):SetPoint("TOPLEFT", getglobal(button..i) ,"TOPLEFT", 1, -1)
      getglobal(button..i..'Name'):SetPoint("BOTTOMRIGHT", getglobal(button..i) ,"BOTTOMRIGHT", -1, 1)
      getglobal(button..i..'Name'):SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size - 2, "OUTLINE")
      getglobal(button..i..'Name'):SetJustifyH("CENTER")
      getglobal(button..i..'Name'):SetJustifyV("BOTTOM")
    end
  end
end)
