-- l1.5

return (function()
    local self
    self = { }
    
    function self.Init()
        self.showInv = false
        self.topbar = CreateSprite("topbar", "AboveBulletDark")
        self.invShown = false
        self.menuShown = false
        self.actionPerformed = false
        self.hideButtons = false
        self.moneyDisplay = {}
        
        -- Items menu
        self.itemMenuLabels = {}
        self.itemLabels = {}
        self.itemDesc = {}
        self.itemDesc.isactive = false
        
        -- Equip and Power menus
        self.charSelected = 0
        self.charPortraits = {}
        self.charNameLabel = {}
        
        -- Power
        self.attrIcons = {}
        self.attrLabels = {}
        self.attrValues = {}
        
        -- Configs menu
        self.configLabel = {}
        self.configOptionLabels = {}
        self.configOptionValues = {}
        self.configSelected = 0
        self.configs = self.MakeConfigs()
        
        -- Menu select
        self.selected = 0
        self.selectDisplay = self.CreateScaled("inventory/captions/0")
        self.options = {}
        self.frames = {}
        for i=0,3 do
            self.options[i] = CreateSprite("inventory/options/"..i.."_noSelect", "AboveBulletDark")
            self.frames[i] = CreateSprite("inventory/frames/"..i, "AboveBulletDark")
            self.frames[i].alpha = 0
            OWCamera.Attach(self.frames[i], 640 / 2, 440 / 2)
        end
        self.UpdateSelection()
        
        -- The layer that darkens the gameplay
        self.darkenedlayer = CreateSprite("black", "BulletDark")
        self.darkenedlayer.alpha = 0
        self.darkenedlayer.Scale(2, 2)
        self.darkenedlayer.MoveTo(320, 240)
        OWCamera.Attach(self.darkenedlayer, 320, 240)
        
        -- The heart used to select options
        self.uisoul = CreateSprite("inventory/select_heart", "AboveBulletDark")
        self.uisoul.alpha = 0
        self.uisoul.color = {1, 0, 0}
        self.uisoul.absx = -10
        self.uisoul.absy = -10
        
        -- The heart used to select characters
        self.charSelectHeart = CreateSprite("inventory/select_heart_arrows/0", "AboveBulletDark")
        self.charSelectHeart.SetAnimation({"0", "1", "2", "3"}, 2/3, "inventory/select_heart_arrows")
        self.charSelectHeart.alpha = 0
        self.charSelectHeart.absx = -20
        self.charSelectHeart.absy = -20
        
        -- Your money, items, key items, and other stats
        self.money = 100
        self.lv = 1
        -- an item has
        --   a type: "consumable", "key", "weapon", "armor"
        --   a weaponType for weapons: "sword", "axe", "cloth", "ring" normally
        --   if its single-use
        --   if you can select a party member
        --   a consume action: Consume()
        --   a description
        --   a name
        local ClubSandwich = {}
        ClubSandwich.name = "Club Sandwich"
        ClubSandwich.desc = "A sandwich that can be split in 3. Heals 30 HP to the team."
        function ClubSandwich.Consume()
            -- healing goes here!
            Player.hp = Player.hp + 30
        end
        ClubSandwich.type = "consumable"
        ClubSandwich.singleUse = true
        
        -- max 12 items?
        self.items = {ClubSandwich, ClubSandwich, ClubSandwich, ClubSandwich, ClubSandwich, ClubSandwich, ClubSandwich}
        self.keyItems = {ClubSandwich}
        
        self.AutoRun = false
    end
    
    function self.Update()
        if (Input.Confirm == 1) and self.showInv then
            if (not self.showMenu) then
                self.showMenu = true
                self.UpdateSelection()
                self.OpenMenu()
                self.actionPerformed = true
            end
        end
        if Input.Menu == 1 then
            if (not self.showMenu) then
                self.showInv = not self.showInv
            end
            if self.showInv then
                self.UpdateSelection()
            end
        end
        if (self.showInv) then
            if not self.invShown then
                self.SetupUi()
            end
            self.UpdateUi()
        elseif (self.invShown) then
            Overworld.movingguidown = true
            Overworld.playerFrozen = false
            self.moneyDisplay.Remove()
            self.moneyDisplay = {}
            self.moneyDisplay.isactive = false
            self.darkenedlayer.alpha = 0
            self.uisoul.alpha = 0
            self.charSelectHeart.alpha = 0
            
            self.invShown = false
        end
        if (Input.Cancel == 1) and (not self.actionPerformed) then
            if self.showMenu then
                self.showMenu = false
                self.UpdateSelection()
                self.CloseMenu()
            else
                self.showInv = false
            end
        end
        
        local buttonAlpha = self.hideButtons and 0 or 1
        self.topbar.y = math.floor(OWCamera.y) + 480 - (63 * (1 / 2)) - math.floor(Overworld.GUIVertOffset) * 1.5
        self.topbar.x = math.floor(OWCamera.x) + 320
        self.moneyDisplay.y = math.floor(OWCamera.y) + 420 - math.floor(Overworld.GUIVertOffset) * 1.5
        self.moneyDisplay.x = math.floor(OWCamera.x) + 630 - ((self.moneyDisplay.isactive) and self.moneyDisplay.GetTextWidth() or 0)
        self.moneyDisplay.alpha = buttonAlpha
        self.selectDisplay.y = math.floor(OWCamera.y) + 430 - math.floor(Overworld.GUIVertOffset) * 1.5
        self.selectDisplay.x = math.floor(OWCamera.x) + 50
        self.selectDisplay.alpha = buttonAlpha
        for i=0,3 do
            self.options[i].y = math.floor(OWCamera.y) + 430 - math.floor(Overworld.GUIVertOffset) * 1.5
            self.options[i].x = math.floor(OWCamera.x) + 170 + 100 * i
            self.options[i].alpha = buttonAlpha
        end
        self.actionPerformed = false
    end
    
    function self.SetupUi()
        Overworld.movinggui = true
        Overworld.playerFrozen = true
        self.moneyDisplay = CreateText("[instant][font:uidialog2]D$"..self.money, {0,0}, 999, "text", -1)
        self.moneyDisplay.HideBubble()
        self.moneyDisplay.progressmode = "none"
        self.moneyDisplay.color = {1,1,1}
        self.UpdateSelection()
        self.uisoul.alpha = 0
        self.charSelectHeart.alpha = 0
        
        self.invShown = true
    end
    
    function self.OpenMenu()
        if self.selected == 0 then
            self.uisoul.alpha = 1
            self.itemLabelSelected = 0
            self.itemSelected = 0
            self.itemPicker = false
            self.itemMenuLabels[0] = CreateText("[instant][font:uidialog2]USE", {0,0}, 999, "text", -1)
            self.itemMenuLabels[1] = CreateText("[instant][font:uidialog2]TOSS", {0,0}, 999, "text", -1)
            self.itemMenuLabels[2] = CreateText("[instant][font:uidialog2]KEY", {0,0}, 999, "text", -1)
            for i=0,2 do
                self.itemMenuLabels[i].HideBubble()
                self.itemMenuLabels[i].progressmode = "none"
                self.itemMenuLabels[i].color = {1,1,1}
                OWCamera.Attach(self.itemMenuLabels[i], 640 / 2 + (i - 1) * 180 - self.itemMenuLabels[i].GetTextWidth() / 2, 320)
            end
            self.SetupItemList()
        elseif self.selected == 2 then
            self.charSelectHeart.alpha = 1
            -- all 25x20 (scaled to 50x40)
            local count = #Overworld.party
            for i=1,count do
                local sprite = Overworld.party[i].folder .. "/" .. Overworld.party[i].equipPortrait
                self.charPortraits[i] = self.CreateScaled(sprite)
                self.charPortraits[i].color = {0.5, 0.5, 0.5}
                OWCamera.Attach(self.charPortraits[i], 165 - ((count + 1) * 25) + (i * 50), 295)
            end
            self.charPortraits[self.charSelected + 1].color = {1, 1, 1}
            
            local chara = Overworld.party[self.charSelected + 1]
            
            self.charNameLabel = self.CreateLabel(chara.name)
            OWCamera.Attach(self.charNameLabel, 165 - 0.5 * self.charNameLabel.GetTextWidth(), 340)
            
            self.charDesc = self.CreateLabel("[instant][font:uidialog2]" .. "LV" .. self.lv .. " " .. chara.title .. "\n" .. chara.desc, 320)
            OWCamera.Attach(self.charDesc, 275, 340)
            
            -- TODO: add other attributes
            self.attrIcons[1] = self.CreateScaled("inventory/attack")
            self.attrIcons[2] = self.CreateScaled("inventory/defense")
            self.attrIcons[3] = self.CreateScaled("inventory/magic")
            self.attrLabels[1] = self.CreateLabel("Attack:")
            self.attrLabels[2] = self.CreateLabel("Defense:")
            self.attrLabels[3] = self.CreateLabel("Magic:")
            self.attrValues[1] = self.CreateLabel(chara.attack)
            self.attrValues[2] = self.CreateLabel(chara.defense)
            self.attrValues[3] = self.CreateLabel(chara.magic)
            
            for i=1,#self.attrIcons do
                OWCamera.Attach(self.attrIcons[i], 135 - 50, 250 - i * 25)
                OWCamera.Attach(self.attrLabels[i], 135 - 30, 240 - i * 25)
                OWCamera.Attach(self.attrValues[i], 235, 240 - i * 25)
            end
        elseif self.selected == 3 then
            self.uisoul.alpha = 1
            self.configSelected = 0
            self.configLabel = self.CreateLabel("CONFIG")
            OWCamera.Attach(self.configLabel, 640 / 2  - self.configLabel.GetTextWidth() / 2, 320)
            for i=0,(#self.configs - 1) do
                self.configOptionLabels[i] = self.CreateLabel(self.configs[i + 1].name)
                OWCamera.Attach(self.configOptionLabels[i], 640 / 2 - 170, 280 - i * 30)
                
                self.configOptionValues[i] = self.CreateLabel(self.configs[i + 1].Get())
                OWCamera.Attach(self.configOptionValues[i], 640 / 2 + 130, 280 - i * 30)
            end
        end
    end
    
    function self.SetupItemList()
        for i=0,#self.itemLabels do
            if self.itemLabels[i] and self.itemLabels[i].isactive then
                self.itemLabels[i].Remove()
                self.itemLabels[i] = {}
                self.itemLabels[i].isactive = false
            end
        end
        local list = self.itemLabelSelected == 2 and self.keyItems or self.items
        for x=0,1 do
            for y=0,5 do
                local i = x + y * 2
                if i < #list then
                    self.itemLabels[i] = self.CreateLabel(list[i + 1].name)
                    self.itemLabels[i].color = {0.7, 0.7, 0.7}
                else
                    self.itemLabels[i] = self.CreateLabel("")
                    self.itemLabels[i].color = {0.7, 0.7, 0.7}
                end
                OWCamera.Attach(self.itemLabels[i], 640 / 2 - 240 + (x * 300), 275 - (y * 30))
            end
        end
    end
    
    function self.CloseMenu()
        for i=0,2 do
            if self.itemMenuLabels[i] and self.itemMenuLabels[i].isactive then
                self.itemMenuLabels[i].Remove()
            end
        end
        for i=0,#self.itemLabels do
            if self.itemLabels[i] and self.itemLabels[i].isactive then
                self.itemLabels[i].Remove()
            end
        end
        for i=0,#self.configOptionLabels do
            if self.configOptionLabels[i] and self.configOptionLabels[i].isactive then
                self.configOptionLabels[i].Remove()
            end
        end
        for i=0,#self.configOptionValues do
            if self.configOptionValues[i] and self.configOptionValues[i].isactive then
                self.configOptionValues[i].Remove()
            end
        end
        for i=0,#self.charPortraits do
            if self.charPortraits[i] and self.charPortraits[i].isactive then
                self.charPortraits[i].Remove()
            end
        end
        for i=1,#self.attrIcons do
            if self.attrIcons[i] then
                self.attrIcons[i].Remove()
            end
        end
        for i=1,#self.attrLabels do
            if self.attrLabels[i] then
                self.attrLabels[i].Remove()
            end
        end
        for i=1,#self.attrValues do
            if self.attrValues[i] then
                self.attrValues[i].Remove()
            end
        end
        if self.configLabel and self.configLabel.isactive then
            self.configLabel.Remove()
        end
        if self.charNameLabel and self.charNameLabel.isactive then
            self.charNameLabel.Remove()
        end
        if self.charDesc and self.charDesc.isactive then
            self.charDesc.Remove()
        end
        self.uisoul.alpha = 0
        self.charSelectHeart.alpha = 0
    end
    
    function self.UpdateUi()
        if self.darkenedlayer.alpha < 0.4 then
            self.darkenedlayer.alpha = self.darkenedlayer.alpha + 0.02
        end
        
        if (not self.showMenu) then
            if Input.Right == 1 then
                self.selected = self.selected + 1
                self.selected = self.selected % 4
                self.UpdateSelection()
            elseif Input.Left == 1 then
                self.selected = self.selected - 1
                self.selected = self.selected % 4
                self.UpdateSelection()
            end
        else
            self.UpdateMenu()
        end
    end
    
    function self.UpdateMenu()
        if self.selected == 0 then
            local list = self.itemLabelSelected == 2 and self.keyItems or self.items
            if (#list == 0) then
                 self.itemPicker = false
            end
            if not self.itemPicker then
                if Input.Right == 1 then
                    self.itemLabelSelected = self.itemLabelSelected + 1
                    self.itemLabelSelected = self.itemLabelSelected % 3
                    self.SetupItemList()
                elseif Input.Left == 1 then
                    self.itemLabelSelected = self.itemLabelSelected - 1
                    self.itemLabelSelected = self.itemLabelSelected % 3
                    self.SetupItemList()
                end
                if (Input.Confirm == 1) and (not self.actionPerformed) and ((self.itemLabelSelected == 2) and (#self.keyItems > 0) or (#self.items > 0)) then
                    self.itemPicker = true
                    self.actionPerformed = true
                end
                
                self.uisoul.absx = self.itemMenuLabels[self.itemLabelSelected].absx - 20
                self.uisoul.absy = self.itemMenuLabels[self.itemLabelSelected].absy + 10
                for i=0,2 do
                    self.itemMenuLabels[i].color = {1, 1, 1}
                end
                --self.itemMenuLabels[self.itemLabelSelected].color = {1, 1, 0}
                for i=0,#list do
                    self.itemLabels[i].color = {0.7, 0.7, 0.7}
                end
                
                self.hideButtons = false
                if self.itemDesc.isactive then
                    OWCamera.Detach(self.itemDesc)
                    self.itemDesc.Remove()
                    self.itemDesc = {}
                    self.itemDesc.isactive = false
                end
                if self.itemPicker then
                    self.itemSelected = 0
                    self.itemDesc = CreateText("[instant][font:uidialog2]"..list[self.itemSelected + 1].desc, {0,0}, 600, "text", -1)
                    self.itemDesc.HideBubble()
                    self.itemDesc.progressmode = "none"
                    self.itemDesc.color = {1, 1, 1}
                    OWCamera.Attach(self.itemDesc, 20, 440)
                end
            else
                local max = #list
                local changed = false
                if Input.Right == 1 then
                    self.itemSelected = self.itemSelected + 1
                    self.itemSelected = self.itemSelected % max
                    changed = true
                elseif Input.Left == 1 then
                    self.itemSelected = self.itemSelected - 1
                    self.itemSelected = self.itemSelected % max
                    changed = true
                elseif Input.Up == 1 then
                    self.itemSelected = self.itemSelected - 2
                    self.itemSelected = self.itemSelected % max
                    changed = true
                elseif Input.Down == 1 then
                    self.itemSelected = self.itemSelected + 2
                    self.itemSelected = self.itemSelected % max
                    changed = true
                end
                
                if changed then
                    if self.itemDesc.isactive then
                        OWCamera.Detach(self.itemDesc)
                        self.itemDesc.Remove()
                    end
                    self.itemDesc = CreateText("[instant][font:uidialog2]"..list[self.itemSelected + 1].desc, {0,0}, 600, "text", -1)
                    self.itemDesc.HideBubble()
                    self.itemDesc.progressmode = "none"
                    self.itemDesc.color = {1, 1, 1}
                    OWCamera.Attach(self.itemDesc, 20, 440)
                end
                
                self.itemMenuLabels[self.itemLabelSelected].color = {1, 0.5, 0}
                
                if Input.Cancel == 1 then
                    self.itemPicker = false
                    self.actionPerformed = true
                elseif Input.Confirm == 1 then
                    if self.itemLabelSelected == 0 then
                        item = self.items[self.itemSelected + 1]
                        item.Consume()
                        if item.singleUse then
                            table.remove(self.items, self.itemSelected + 1)
                        end
                        self.itemSelected = self.itemSelected % #self.items
                    elseif self.itemLabelSelected == 1 then
                        table.remove(self.items, self.itemSelected + 1)
                        self.itemSelected = self.itemSelected % #self.items
                    end
                    self.SetupItemList()
                    self.actionPerformed = true
                end
                
                if #list > 0 then
                    self.uisoul.absx = self.itemLabels[self.itemSelected].absx - 20
                    self.uisoul.absy = self.itemLabels[self.itemSelected].absy + 10
                end
                
                for i=0,#list do
                    self.itemLabels[i].color = {1, 1, 1}
                end
                
                self.hideButtons = true
            end
        elseif self.selected == 2 then
            local changed = false
            if Input.Right == 1 then
                self.charSelected = (self.charSelected + 1) % (#self.charPortraits)
                changed = true
            elseif Input.Left == 1 then
                self.charSelected = (self.charSelected - 1) % (#self.charPortraits)
                changed = true
            end
            
            if changed then
                for i=1,#self.charPortraits do
                    self.charPortraits[i].color = {0.5, 0.5, 0.5}
                end
                self.charPortraits[self.charSelected + 1].color = {1, 1, 1}
                
                local chara = Overworld.party[self.charSelected + 1]
                
                self.charNameLabel.SetText("[instant][font:uidialog2]" .. chara.name)
                OWCamera.Detach(self.charNameLabel)
                OWCamera.Attach(self.charNameLabel, 165 - 0.5 * self.charNameLabel.GetTextWidth(), 340)
                
                self.charDesc.SetText("[instant][font:uidialog2]" .. "LV" .. self.lv .. " " .. chara.title .. "\n" .. chara.desc)
                
                self.attrValues[1].SetText("[instant][font:uidialog2]" .. tostring(chara.attack))
                self.attrValues[2].SetText("[instant][font:uidialog2]" .. tostring(chara.defense))
                self.attrValues[3].SetText("[instant][font:uidialog2]" .. tostring(chara.magic))
            end
            
            self.charSelectHeart.absx = self.charPortraits[self.charSelected + 1].absx
            self.charSelectHeart.absy = self.charPortraits[self.charSelected + 1].absy + 30
        elseif self.selected == 3 then
            if Input.Up == 1 then
                self.configSelected = (self.configSelected - 1) % #self.configs
            elseif Input.Down == 1 then
                self.configSelected = (self.configSelected + 1) % #self.configs
            end
            if (Input.Confirm == 1) and (not self.actionPerformed) then
                self.configs[self.configSelected + 1].Run()
                
                OWCamera.Detach(self.configOptionValues[self.configSelected])
                self.configOptionValues[self.configSelected].Remove()
                self.configOptionValues[self.configSelected] = self.CreateLabel(self.configs[self.configSelected + 1].Get())
                OWCamera.Attach(self.configOptionValues[self.configSelected], 640 / 2 + 130, 280 - self.configSelected * 30)
                
                self.actionPerformed = true
            end
            
            self.uisoul.absx = self.configOptionLabels[self.configSelected].absx - 20
            self.uisoul.absy = self.configOptionLabels[self.configSelected].absy + 10
        end
    end
    
    function self.UpdateSelection()
        self.selectDisplay.SetAnimation({"inventory/captions/"..self.selected})
        for i=0,3 do
            self.options[i].SetAnimation({"inventory/options/"..i..(self.selected == i and (self.showMenu and "_selected" or "_hover") or "_noSelect")})
            self.frames[i].alpha = (self.showMenu and self.selected == i) and 1 or 0
        end
    end
    
    function self.GetSelectText()
        if self.selected == 0 then return "ITEM"
        elseif self.selected == 1 then return "EQUIP"
        elseif self.selected == 2 then return "POWER"
        else return "CONFIG" end
    end
    
    function self.CreateScaled(path)
        local spr = CreateSprite(path, "AboveBulletDark")
        spr.Scale(2, 2)
        return spr
    end
    
    function self.CreateLabel(text, maxWidth)
        maxWidth = maxWidth or 999
        local label = CreateText("[instant][font:uidialog2]"..text, {0,0}, maxWidth, "text", -1)
        label.HideBubble()
        label.progressmode = "none"
        label.color = {1, 1, 1}
        return label
    end
    
    function self.MakeConfigs()
        local fullscreen = {}
        fullscreen.name = "Fullscreen"
        function fullscreen.Get()
            return Misc.FullScreen and "ON" or "OFF"
        end
        function fullscreen.Run()
            Misc.FullScreen = not Misc.FullScreen
        end
        
        local autorun = {}
        autorun.name = "Auto-run"
        function autorun.Get()
            return self.AutoRun and "ON" or "OFF"
        end
        function autorun.Run()
            self.AutoRun = not self.AutoRun
        end
        
        return {fullscreen, autorun}
    end
    
    return self 
end)()