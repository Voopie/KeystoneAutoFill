local KeystoneButton, ToggleButton;

local mapIdToActivity = {
    [375] = 703, -- MISTS
    [376] = 713, -- NW
    [377] = 695, -- DOS
    [378] = 699, -- HOA
    [379] = 691, -- PF
    [380] = 705, -- SD
    [381] = 709, -- SOA
    [382] = 717, -- TOP
};

local keystoneLink = '|cffa335ee|Hkeystone:%s:%s:%s:%s:%s:%s:%s|h' .. _G.CHALLENGE_MODE_KEYSTONE_HYPERLINK .. '|h|r';
local GetKeystoneLink = function(mapID, level)
	if not mapID or mapID == 0 or not level or level == 0 then
		return;
	end

	local affixes = C_MythicPlus.GetCurrentAffixes();
	if affixes then
		return string.format(keystoneLink, 180653, mapID, level, affixes[1].id, affixes[2].id, affixes[3].id, affixes[4] and affixes[4].id or 0, C_ChallengeMode.GetMapUIInfo(mapID), level);
	end
end

local function UpdateState(self, filters, categoryID, groupID, activityID, fromUs)
    if fromUs then
        return;
    end

    if LFGListFrame.EntryCreation.selectedCategory == 2 then
        KeystoneButton.mapId   = C_MythicPlus.GetOwnedKeystoneChallengeMapID();
        KeystoneButton.level   = C_MythicPlus.GetOwnedKeystoneLevel();
        KeystoneButton.keylink = GetKeystoneLink(KeystoneButton.mapId, KeystoneButton.level);

        ToggleButton:SetShown(true);
        KeystoneButton:SetShown(true);

        if KeystoneAutoFillDB.auto then
            ToggleButton:SetText('|cff66ff6eON|r');

            LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, mapIdToActivity[KeystoneButton.mapId], true);
            LFGListFrame.EntryCreation.Name:SetFocus();
            KeystoneButton.LevelText:SetText(KeystoneButton.level);
        else
            ToggleButton:SetText('|cffff6666OFF|r');
        end
    else
        KeystoneButton.LevelText:SetText('');

        ToggleButton:SetShown(false);
        KeystoneButton:SetShown(false);
    end
end

KeystoneButton = CreateFrame('Button', 'KeystoneAutoFillButton', LFGListFrame.EntryCreation);
KeystoneButton:SetPoint('TOPRIGHT', LFGListFrame.EntryCreation, 'TOPRIGHT', -5, -27);
KeystoneButton:SetSize(32, 32);
KeystoneButton.texture = KeystoneButton:CreateTexture(nil, 'BORDER');
KeystoneButton.texture:SetAllPoints();
KeystoneButton.texture:SetTexture(525134);
KeystoneButton:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress');
KeystoneButton:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square');

KeystoneButton.LevelText = KeystoneButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
KeystoneButton.LevelText:SetPoint('RIGHT', LFGListFrame.EntryCreation.Name, 'LEFT', -4, 0);

KeystoneButton:SetShown(false);

KeystoneButton:SetScript('OnClick', function(self)
    if not self.mapId then
        return;
    end

    LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, mapIdToActivity[self.mapId]);
    LFGListFrame.EntryCreation.Name:SetFocus();
    self.LevelText:SetText(KeystoneButton.level);
end);

KeystoneButton:SetScript('OnEnter', function(self)
    if not self.keylink then
        return;
    end

    GameTooltip:SetOwner(self, 'ANCHOR_NONE');
    GameTooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', 1, 0);
    GameTooltip:SetHyperlink(self.keylink);
    GameTooltip:Show();
end);

KeystoneButton:SetScript('OnLeave', GameTooltip_Hide);

ToggleButton = CreateFrame('Button', 'KeystoneAutoFillToggleButton', LFGListFrame.EntryCreation, 'SharedButtonSmallTemplate');
ToggleButton:SetPoint('RIGHT', PVEFrameCloseButton, 'LEFT', 0, 0);
ToggleButton:SetSize(54, 18);
ToggleButton:SetScript('OnClick', function(self)
    KeystoneAutoFillDB.auto = not KeystoneAutoFillDB.auto;

    if KeystoneAutoFillDB.auto then
        self:SetText('|cff66ff6eON|r');

        LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, mapIdToActivity[KeystoneButton.mapId]);
        LFGListFrame.EntryCreation.Name:SetFocus();
        KeystoneButton.LevelText:SetText(KeystoneButton.level);
    else
        self:SetText('|cffff6666OFF|r');
    end
end);

KeystoneButton:RegisterEvent('ADDON_LOADED');
KeystoneButton:SetScript('OnEvent', function(self, event, ...)
    if event == 'ADDON_LOADED' and ... == 'KeystoneAutoFill' then
        KeystoneAutoFillDB = KeystoneAutoFillDB or { auto = false };

        hooksecurefunc('LFGListEntryCreation_Select', UpdateState);

        _G['SLASH_KEYSTONEAUTOFILL1'] = '/kaf';
        SlashCmdList['KEYSTONEAUTOFILL'] = function(input)
            if input and string.find(input, 'auto') then
                local _, mode = strsplit(' ', input);

                KeystoneAutoFillDB.auto = mode == 'on' and true or false;
            end
        end

        self:UnregisterEvent('ADDON_LOADED');
    end
end);