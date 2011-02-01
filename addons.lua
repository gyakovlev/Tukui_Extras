---------------------------------------------------
-- Author: Fernir, credit: Ext
---------------------------------------------------
local T, C, L = unpack(Tukui) -- Import Functions/Constants, Config, Locales

local function SetModifiedBackdrop(self)
	local color = RAID_CLASS_COLORS[T.myclass]
	self:SetBackdropColor(color.r, color.g, color.b, 0.15)
	self:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function SetOriginalBackdrop(self)
	self:SetBackdropColor(unpack(C["media"].backdropcolor))
	self:SetBackdropBorderColor(unpack(C["media"].bordercolor))
end

local function SkinButton(f)
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")
	f:SetTemplate("Default")
	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end



local loadf = CreateFrame("frame", "aLoadFrame", UIParent)
loadf:Size(480, 640)
loadf:Point("CENTER")
loadf:SetFrameStrata("DIALOG")
tinsert(UISpecialFrames, "aLoadFrame")

local RLButton = function(text,parent)
	local result = CreateFrame("Button", "btn_"..parent:GetName(), parent, "UIPanelButtonTemplate")
	result:SetText(text)
	return result
end

local CloseButton = function(text,parent)
	local result = CreateFrame("Button", "btn2_"..parent:GetName(), parent, "UIPanelButtonTemplate")
	result:SetText(text)
	return result
end

T.SetTemplate(loadf)
T.CreateShadow(loadf)
loadf:Hide()
loadf:SetScript("OnHide", function() ShowUIPanel(GameMenuFrame); PlaySound("gsTitleOptionExit") end)

local title = loadf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, (T.Scale(-8)))
title:SetText(ADDONS)

local scrollf = CreateFrame("ScrollFrame", "aload_Scroll", loadf, "UIPanelScrollFrameTemplate")
local mainf = CreateFrame("frame", "aloadmainf", scrollf)

scrollf:SetPoint("TOPLEFT", loadf, "TOPLEFT", T.Scale(10), T.Scale(-30))
scrollf:SetPoint("BOTTOMRIGHT", loadf, "BOTTOMRIGHT", T.Scale(-28), T.Scale(40))
scrollf:SetScrollChild(mainf)

local reloadb = RLButton(ACCEPT, loadf)
reloadb:SetWidth(120)
reloadb:SetHeight(22)
reloadb:SetPoint("BOTTOMRIGHT", loadf, "BOTTOM", -2, 9)
reloadb:SetScript("OnClick", function() ReloadUI() end)
SkinButton(reloadb)

local closeb = CloseButton(CLOSE, loadf)
closeb:SetWidth(120)
closeb:SetHeight(22)
closeb:SetPoint("TOPLEFT" , reloadb, "TOPRIGHT", 4, 0)
closeb:SetScript("OnClick", function() loadf:Hide() end)
SkinButton(closeb)

local makeList = function()
	local self = mainf
	T.SetTemplate(scrollf)
  	self:SetPoint("TOPLEFT")
  	self:SetWidth(scrollf:GetWidth())
  	self:SetHeight(scrollf:GetHeight())
	self.addons = {}
	for i=1, GetNumAddOns() do
		self.addons[i] = select(1, GetAddOnInfo(i))
	end
	table.sort(self.addons)

	local oldb

	for i,v in pairs(self.addons) do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(v)
		print(name)

		if name then
			local bf = _G[v.."_cbf"] or CreateFrame("CheckButton", v.."_cbf", self, "OptionsCheckButtonTemplate")
			bf:EnableMouse(true)
			bf.title = title.."|n"
			if notes then bf.title = bf.title.."|cffffffff"..notes.."|r|n" end
			if (GetAddOnDependencies(v)) then
				bf.title = "Depends on: "
				for i=1, select("#", GetAddOnDependencies(v)) do
					bf.title = bf.title..select(i,GetAddOnDependencies(v))
					if (i>1) then bf.title=bf.title..", " end
				end
				bf.title = bf.title.."|r"
			end
				
			if i==1 then
				bf:SetPoint("TOPLEFT",self, "TOPLEFT", T.Scale(6), T.Scale(-4))
			else
				bf:SetPoint("TOP", oldb, "BOTTOM", 0, 6)
			end
			
			bf:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", })
			bf:SetBackdropColor(0,0,0,0)
	
			bf:SetScript("OnEnter", function(self)
				GameTooltip:ClearLines()
				GameTooltip:SetOwner(self, ANCHOR_TOPRIGHT)
				GameTooltip:AddLine(self.title)
				GameTooltip:Show()
			end)
			
			bf:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
			
			bf:SetScript("OnClick", function()
				local _, _, _, enabled = GetAddOnInfo(name)
				if enabled then
					DisableAddOn(name)
					PlaySound("igMainMenuOptionCheckBoxOff")
				else
					EnableAddOn(name)
					PlaySound("igMainMenuOptionCheckBoxOn")
				end
			end)
			bf:SetChecked(enabled)
			
			_G[v.."_cbfText"]:SetText(title) 

			oldb = bf
		end
	end
end

makeList()

local showb = CreateFrame("Button", "GameMenuButtonAddonManager", GameMenuFrame, "GameMenuButtonTemplate")
SkinButton(GameMenuButtonAddonManager)
_G["GameMenuButtonAddonManagerLeft"]:SetAlpha(0)
_G["GameMenuButtonAddonManagerMiddle"]:SetAlpha(0)
_G["GameMenuButtonAddonManagerRight"]:SetAlpha(0)
showb:SetText(ADDONS)
showb:SetPoint("TOP", "GameMenuButtonOptions", "BOTTOM", 0, -1)

GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + showb:GetHeight())
GameMenuButtonSoundOptions:SetPoint("TOP", showb, "BOTTOM", 0, -1)

showb:SetScript("OnClick", function()
	PlaySound("igMainMenuOption")
	HideUIPanel(GameMenuFrame)
	loadf:Show()
end)

