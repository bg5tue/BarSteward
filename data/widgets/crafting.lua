local BS = _G.BarSteward
local researchSlots = {
    [_G.CRAFTING_TYPE_BLACKSMITHING] = {},
    [_G.CRAFTING_TYPE_WOODWORKING] = {},
    [_G.CRAFTING_TYPE_CLOTHIER] = {},
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = {}
}

local fullyUsed = {
    [_G.CRAFTING_TYPE_BLACKSMITHING] = false,
    [_G.CRAFTING_TYPE_WOODWORKING] = false,
    [_G.CRAFTING_TYPE_CLOTHIER] = false,
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = false
}

local function clearSlots(craftType)
    for slot, _ in pairs(researchSlots[craftType]) do
        researchSlots[craftType][slot] = 0
    end
end

-- based on code from AI Research Timer
local function getResearchTimer(craftType)
    local maxTimer = 6000000
    local maxResearch = GetMaxSimultaneousSmithingResearch(craftType)
    local maxLines = GetNumSmithingResearchLines(craftType)
    local maxR = maxResearch
    local inuse = 0

    clearSlots(craftType)

    for i = 1, maxLines do
        local _, _, numTraits = GetSmithingResearchLineInfo(craftType, i)

        for j = 1, numTraits do
            local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, i, j)

            if (duration ~= nil and timeRemaining ~= nil) then
                maxResearch = maxResearch - 1
                inuse = inuse + 1
                maxTimer = math.min(maxTimer, timeRemaining)
                researchSlots[craftType][inuse] = timeRemaining
            end
        end
    end

    if (maxResearch > 0) then
        maxTimer = 0
    end

    return maxTimer, maxR, inuse
end

local function getDisplay(timeRemaining, widgetIndex, inUse, maxResearch)
    local display
    local hours = timeRemaining / 60 / 60
    local days = math.floor((hours / 24) + 0.5)

    if (BS.GetVar("ShowDays", widgetIndex) and days >= 1 and hours > 24) then
        display = zo_strformat(GetString(_G.BARSTEWARD_DAYS), days)
    else
        display =
            BS.SecondsToTime(
            timeRemaining,
            false,
            false,
            BS.GetVar("HideSeconds", widgetIndex),
            BS.GetVar("Format", widgetIndex),
            BS.GetVar("HideDaysWhenZero", widgetIndex)
        )
    end

    if (inUse ~= nil) then
        display = display .. (BS.GetVar("ShowSlots", widgetIndex) and " (" .. inUse .. "/" .. maxResearch .. ")" or "")
    end

    return display
end

local function getSettings(widgetIndex)
    local settings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_SLOTS),
            getFunc = function()
                return BS.Vars.Controls[widgetIndex].ShowSlots
            end,
            setFunc = function(value)
                BS.Vars.Controls[widgetIndex].ShowSlots = value
                BS.RefreshWidget(widgetIndex)
            end,
            width = "full"
        },
        [2] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_DAYS_ONLY),
            tooltip = GetString(_G.BARSTEWARD_DAYS_ONLY_TOOLTIP),
            getFunc = function()
                return BS.Vars.Controls[widgetIndex].ShowDays
            end,
            setFunc = function(value)
                BS.Vars.Controls[widgetIndex].ShowDays = value
                BS.RefreshWidget(widgetIndex)
            end,
            width = "full"
        }
    }

    return settings
end

BS.widgets[BS.W_BLACKSMITHING] = {
    name = "blacksmithing",
    update = function(widget)
        local this = BS.W_BLACKSMITHING
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_BLACKSMITHING)
        local colour = BS.GetColour(this, "Ok")

        colour = BS.GetTimeColour(timeRemaining, this) or colour
        fullyUsed[_G.CRAFTING_TYPE_BLACKSMITHING] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = BS.Format(_G.SI_TRADESKILLTYPE1)

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText
            ttt = ttt .. getDisplay(researchSlots[_G.CRAFTING_TYPE_BLACKSMITHING][slot] or 0, this)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/servicemappins/servicepin_smithy",
    tooltip = BS.Format(_G.SI_TRADESKILLTYPE1),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_BLACKSMITHING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_BLACKSMITHING)
    end,
    customSettings = getSettings(BS.W_BLACKSMITHING)
}

BS.widgets[BS.W_WOODWORKING] = {
    name = "woodworking",
    update = function(widget)
        local this = BS.W_WOODWORKING
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_WOODWORKING)
        local colour = BS.GetColour(this, "Ok")

        colour = BS.GetTimeColour(timeRemaining, this) or colour
        fullyUsed[_G.CRAFTING_TYPE_WOODWORKING] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = BS.Format(_G.SI_TRADESKILLTYPE6)

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText
            ttt = ttt .. getDisplay(researchSlots[_G.CRAFTING_TYPE_WOODWORKING][slot] or 0, this)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/servicemappins/servicepin_woodworking",
    tooltip = BS.Format(_G.SI_TRADESKILLTYPE6),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_WOODWORKING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_WOODWORKING)
    end,
    customSettings = getSettings(BS.W_WOODWORKING)
}

BS.widgets[BS.W_CLOTHING] = {
    name = "clothing",
    update = function(widget)
        local this = BS.W_CLOTHING
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_CLOTHIER)
        local colour = BS.GetColour(this, "Ok")

        colour = BS.GetTimeColour(timeRemaining, this) or colour
        fullyUsed[_G.CRAFTING_TYPE_CLOTHIER] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = BS.Format(_G.SI_TRADESKILLTYPE2)

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText .. getDisplay(researchSlots[_G.CRAFTING_TYPE_CLOTHIER][slot] or 0, this)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/servicemappins/servicepin_outfitter",
    tooltip = BS.Format(_G.SI_TRADESKILLTYPE2),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_CLOTHIER]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_CLOTHIER)
    end,
    customSettings = getSettings(BS.W_CLOTHING)
}

BS.widgets[BS.W_JEWELCRAFTING] = {
    name = "jewelcrafting",
    update = function(widget)
        local this = BS.W_JEWELCRAFTING
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
        local colour = BS.GetColour(this, "Ok")

        colour = BS.GetTimeColour(timeRemaining, this) or colour
        fullyUsed[_G.CRAFTING_TYPE_JEWELRYCRAFTING] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = BS.Format(_G.SI_TRADESKILLTYPE7)

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText
            ttt = ttt .. getDisplay(researchSlots[_G.CRAFTING_TYPE_JEWELRYCRAFTING][slot] or 0, this)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/icon_jewelrycrafting_symbol",
    tooltip = BS.Format(_G.SI_TRADESKILLTYPE7),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_JEWELRYCRAFTING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
    end,
    customSettings = getSettings(BS.W_JEWELCRAFTING)
}

local qualifiedQuestNames = {}
local qualifiedCount = 0

local function updateQualifications()
    qualifiedCount = 0

    for craftType, _ in pairs(BS.CRAFTING_DAILY) do
        local achievementData = BS.CRAFTING_ACHIEVEMENT[craftType]
        local _, numCompleted = GetAchievementCriterion(achievementData.achievementId, achievementData.criterionIndex)

        if (numCompleted > 0) then
            qualifiedQuestNames[BS.CRAFTING_DAILY[craftType]] = true
            qualifiedCount = qualifiedCount + 1
        end
    end

    return qualifiedCount
end

BS.RegisterForEvent(
    _G.EVENT_ACHIEVEMENT_UPDATED,
    function(_, achievementId)
        if (BS.CRAFTING_ACHIEVEMENT_IDS[achievementId]) then
            updateQualifications()
        end
    end
)

local function countState(state, character)
    local count = 0

    for _, s in pairs(BS.Vars.dailyQuests[character]) do
        if (s == state) then
            count = count + 1
        end
    end

    return count
end

local function checkReset()
    local timeRemaining =
        TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(_G.TIMED_ACTIVITY_TYPE_DAILY)
    local secondsInADay = 86400
    local lastResetTime = os.time() - (secondsInADay - timeRemaining)

    BS.Vars.lastDailyReset = BS.Vars.lastDailyReset or lastResetTime

    if ((BS.Vars.lastDailyReset + secondsInADay) < os.time()) then
        BS.Vars.dailyQuests = {}
        BS.Vars.lastDailyReset = lastResetTime
    end
end

local function getReadyForHandIn(character)
    local update = false
    local questList = QUEST_JOURNAL_MANAGER:GetQuestListData()

    for _, quest in ipairs(questList) do
        if (quest.questType == _G.QUEST_TYPE_CRAFTING and quest.repeatableType == _G.QUEST_REPEAT_DAILY) then
            local conditionInfo = {}
            local numConditions = GetJournalQuestNumConditions(quest.questIndex)

            QUEST_JOURNAL_MANAGER:BuildTextForConditions(
                quest.questIndex,
                _G.QUEST_MAIN_STEP_INDEX,
                numConditions,
                conditionInfo
            )

            for info = 1, #conditionInfo do
                local conditionText = zo_strformat("<<z:1>>", conditionInfo[info].name)

                if (string.find(conditionText, GetString(_G.BARSTEWARD_DELIVER))) then
                    if (BS.Vars.dailyQuests[character][quest.name] ~= "ready") then
                        BS.Vars.dailyQuests[character][quest.name] = "ready"
                        update = true
                        break
                    end
                end
            end
        end
    end

    return update
end

-- check once a minute for daily reset
BS.RegisterForUpdate(60000, checkReset)

local DAILY_COLOURS = {
    ["done"] = BS.COLOURS.GREEN,
    ["ready"] = BS.COLOURS.BLUE,
    ["added"] = BS.COLOURS.YELLOW
}

BS.widgets[BS.W_CRAFTING_DAILIES] = {
    name = "craftingDailies",
    update = function(widget, event, completeName, addedName, removedName)
        local this = BS.W_CRAFTING_DAILIES
        local update = true
        local added, done, ready
        local character = GetUnitName("player")
        local iconString = "icons/mapkey/mapkey_%s"

        checkReset()

        if (#qualifiedQuestNames == 0) then
            updateQualifications()
        end

        BS.Vars.dailyQuests = BS.Vars.dailyQuests or {}
        BS.Vars.dailyQuests[character] = BS.Vars.dailyQuests[character] or {}

        if (event == _G.EVENT_QUEST_CONDITION_COUNTER_CHANGED) then
            addedName = 1
        end

        completeName = (type(completeName) == "string") and completeName or "null"
        addedName = (type(addedName) == "string") and addedName or "null"
        removedName = (type(removedName) == "string") and removedName or "null"

        if (qualifiedQuestNames[completeName]) then
            BS.Vars.dailyQuests[character][completeName] = "done"
        elseif (qualifiedQuestNames[addedName]) then
            BS.Vars.dailyQuests[character][addedName] = "added"
        elseif (qualifiedQuestNames[removedName]) then
            -- addedName is actually 'completed' in this case
            if (tostring(addedName) ~= "true") then
                BS.Vars.dailyQuests[character][removedName] = nil
            end
        else
            update = false
        end

        update = update or getReadyForHandIn(character)

        if (completeName == "null" and addedName == "null" and removedName == "null") then
            -- initial load
            update = true
        end

        added = countState("added", character)
        done = countState("done", character)
        ready = countState("ready", character)

        local colour = BS.GetVar("DefaultColour")

        if (done == qualifiedCount) then
            colour = BS.GetVar("DefaultOkColour")
            BS.Vars.dailyQuests[character].complete = true
        elseif (ready == qualifiedCount) then
            colour = {(255 / 52), (255 / 164), (255 / 2350), 1}
        elseif (added == qualifiedCount) then
            colour = BS.GetVar("DefaultWarningColour")
            BS.Vars.dailyQuests[character].pickedup = true
        end

        if (update) then
            local tName
            if (BS.GetVar("UseIcons", this)) then
                local output = ""

                for craftingType, info in pairs(BS.CRAFTING_ACHIEVEMENT) do
                    if (qualifiedQuestNames[BS.CRAFTING_DAILY[craftingType]]) then
                        local cname = BS.CRAFTING_DAILY[craftingType]
                        local cvar = BS.Vars.dailyQuests[character][cname]
                        local ciconName = iconString:format(info.icon)
                        colour = cvar and DAILY_COLOURS[cvar] or BS.COLOURS.GREY

                        tName = BS.Icon(ciconName, colour, 20, 20)
                        output = string.format("%s %s", output, tName)
                    end
                end

                widget:SetValue(output)
            else
                widget:SetValue(added .. "/" .. ready .. "/" .. done .. "/" .. qualifiedCount)
                widget:SetColour(unpack(colour))
            end

            local ttt = GetString(_G.BARSTEWARD_DAILY_CRAFTING) .. BS.LF

            for name, _ in pairs(qualifiedQuestNames) do
                local tdone = BS.Vars.dailyQuests[character][name] == "done"
                local tadded = BS.Vars.dailyQuests[character][name] == "added"
                local tready = BS.Vars.dailyQuests[character][name] == "ready"
                local tcolour = BS.ARGBConvert(BS.GetVar("DefaultColour"))

                if (tready) then
                    ttt = string.format("%s%s|c%s", ttt, BS.LF, BS.COLOURS.BLUE)
                    ttt = string.format("%s%s - %s|r", ttt, name, GetString(_G.BARSTEWARD_READY))
                elseif (tdone) then
                    ttt = string.format("%s%s%s", ttt, BS.LF, BS.ARGBConvert(BS.GetVar("DefaultOkColour")))
                    ttt = string.format("%s%s - %s|r", ttt, name, GetString(_G.BARSTEWARD_COMPLETED))
                elseif (tadded) then
                    ttt = string.format("%s%s%s", ttt, BS.LF, BS.ARGBConvert(BS.GetVar("DefaultWarningColour")))
                    ttt = string.format("%s%s - %s|r", ttt, name, GetString(_G.BARSTEWARD_PICKED_UP))
                else
                    ttt =
                        string.format(
                        "%s%s%s%s - %s|r",
                        ttt,
                        BS.LF,
                        tcolour,
                        name,
                        GetString(_G.BARSTEWARD_NOT_PICKED_UP)
                    )
                end
            end

            if (BS.Vars.CharacterList) then
                local ccolour = BS.ARGBConvert(BS.Vars.DefaultColour)
                local chars = BS.Vars.CharacterList

                ttt = ttt .. BS.LF

                for char, _ in pairs(chars) do
                    if (char ~= character) then
                        if (BS.Vars.dailyQuests[char]) then
                            local dccolour = ccolour

                            if (BS.Vars.dailyQuests[char].complete) then
                                dccolour = BS.ARGBConvert(BS.GetVar("DefaultOkColour"))
                            elseif (BS.Vars.dailyQuests[char].pickedup) then
                                dccolour = BS.ARGBConvert(BS.GetVar("DefaultWarningColour"))
                            end

                            ttt = string.format("%s%s%s%s|r", ttt, BS.LF, dccolour, char)
                        else
                            ttt = string.format("%s%s%s%s|r", ttt, BS.LF, ccolour, char)
                        end
                    end
                end
            end

            widget.tooltip = ttt
        end

        return done == qualifiedCount
    end,
    event = {
        _G.EVENT_QUEST_ADDED,
        _G.EVENT_QUEST_REMOVED,
        _G.EVENT_QUEST_COMPLETE,
        _G.EVENT_QUEST_CONDITION_COUNTER_CHANGED
    },
    icon = "floatingmarkers/repeatablequest_available_icon",
    tooltip = GetString(_G.BARSTEWARD_DAILY_CRAFTING),
    hideWhenEqual = true,
    customSettings = {
        [1] = {
            name = GetString(_G.BARSTEWARD_USE_ICONS),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.Controls[BS.W_CRAFTING_DAILIES].UseIcons
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CRAFTING_DAILIES].UseIcons = value
                BS.RefreshWidget(BS.W_CRAFTING_DAILIES)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_CRAFTING_DAILY_TIME] = {
    -- v1.3.11
    -- same time as any other daily activity
    name = "craftingDailyTime",
    update = function(widget)
        return BS.GetTimedActivityTimeRemaining(_G.TIMED_ACTIVITY_TYPE_DAILY, BS.W_CRAFTING_DAILY_TIME, widget)
    end,
    timer = 1000,
    icon = "icons/crafting_outfitter_logo",
    tooltip = GetString(_G.BARSTEWARD_DAILY_WRITS_TIME)
}

local function getRecipeList()
    BS.recipeList = {
        food = {known = 0, unknown = 0.},
        drink = {known = 0, unknown = 0},
        furnishing = {known = 0, unknown = 0}
    }

    BS.unknownRecipeLinks = {[_G.ITEMTYPE_FOOD] = {}, [_G.ITEMTYPE_DRINK] = {}, [_G.ITEMTYPE_FURNISHING] = {}}

    for recipeListIndex = 1, GetNumRecipeLists() do
        local name, numRecipes = GetRecipeListInfo(recipeListIndex)

        for recipeIndex = 1, numRecipes do
            local known, _, _, _, _, _, _, resultItemId = GetRecipeInfo(recipeListIndex, recipeIndex)

            if (not BS.IGNORE_RECIPE[resultItemId]) then
                local link = BS.MakeItemLink(resultItemId)
                local itemType, sit = GetItemLinkItemType(link)

                if (itemType + sit ~= 0) then
                    if (itemType == _G.ITEMTYPE_FOOD) then
                        if (known == true) then
                            BS.recipeList.food.known = BS.recipeList.food.known + 1
                        else
                            BS.recipeList.food.unknown = BS.recipeList.food.unknown + 1
                            table.insert(BS.unknownRecipeLinks[_G.ITEMTYPE_FOOD], link)
                        end
                    elseif (itemType == _G.ITEMTYPE_DRINK) then
                        if (known == true) then
                            BS.recipeList.drink.known = BS.recipeList.drink.known + 1
                        else
                            BS.recipeList.drink.unknown = BS.recipeList.drink.unknown + 1
                            table.insert(BS.unknownRecipeLinks[_G.ITEMTYPE_DRINK], link)
                        end
                    elseif (itemType == _G.ITEMTYPE_FURNISHING) then
                        if (name ~= "") then
                            if (known) then
                                BS.recipeList.furnishing.known = BS.recipeList.furnishing.known + 1
                            else
                                BS.recipeList.furnishing.unknown = BS.recipeList.furnishing.unknown + 1
                                table.insert(BS.unknownRecipeLinks[_G.ITEMTYPE_FURNISHING], link)
                            end
                        end
                    end
                end
            end
        end
    end
end

local food = BS.Format(_G.SI_ITEMTYPE4)
local drink = BS.Format(_G.SI_ITEMTYPE12)
local foodAndDrink = food .. " + " .. drink
local furnishing = BS.Format(_G.SI_ITEMTYPE61)
local recipes = BS.Format(_G.SI_ITEMTYPEDISPLAYCATEGORY21)

BS.widgets[BS.W_RECIPES] = {
    -- v1.4.6
    name = "recipes",
    update = function(widget, event)
        if ((BS.recipeList == nil) or (event ~= _G.EVENT_PLAYER_ACTIVATED)) then
            getRecipeList()
        end

        local allFood = BS.recipeList.food.known + BS.recipeList.food.unknown
        local allDrink = BS.recipeList.drink.known + BS.recipeList.drink.unknown
        local allFoodAndDrink = allFood + allDrink
        local allFurnishing = BS.recipeList.furnishing.known + BS.recipeList.furnishing.unknown
        local tt = recipes
        local this = BS.W_RECIPES

        tt = tt .. BS.LF .. "|cffd700"
        tt = tt .. BS.recipeList.food.known .. "/" .. allFood .. "|r |cf9f9f9"
        tt = tt .. food .. BS.LF .. "|cffd700"
        tt = tt .. BS.recipeList.drink.known .. "/" .. allDrink .. "|r |cf9f9f9"
        tt = tt .. drink .. BS.LF .. "|cffd700"
        tt = tt .. (BS.recipeList.drink.known + BS.recipeList.food.known) .. "/" .. allFoodAndDrink .. "|r |cf9f9f9"
        tt = tt .. foodAndDrink .. BS.LF .. "|cffd700"
        tt = tt .. BS.recipeList.furnishing.known .. "/" .. allFurnishing .. "|r |cf9f9f9"
        tt = tt .. furnishing

        local value = BS.recipeList.food.known .. "/" .. allFood
        local colour = BS.GetColour(this)
        local display = BS.GetVar("Display", this)

        if (display == drink) then
            value = BS.recipeList.drink.known .. "/" .. allDrink
        elseif (display == foodAndDrink) then
            value = (BS.recipeList.drink.known + BS.recipeList.food.known) .. "/" .. allFoodAndDrink
        elseif (display == furnishing) then
            value = BS.recipeList.furnishing.known .. "/" .. allFurnishing
        end

        widget:SetValue(value)
        widget:SetColour(unpack(colour))

        widget.tooltip = tt

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_RECIPE_LEARNED, _G.EVENT_MULTIPLE_RECIPES_LEARNED},
    icon = "tradinghouse/tradinghouse_trophy_recipe_fragment_up",
    tooltip = recipes,
    onClick = function()
        local vars = BS.Vars.Controls[BS.W_RECIPES]
        local display = BS.unknownRecipeLinks[_G.ITEMTYPE_FOOD]

        if (vars.Display == drink) then
            display = BS.unknownRecipeLinks[_G.ITEMTYPE_DRINK]
        elseif (vars.Display == foodAndDrink) then
            display = BS.MergeTables(display, BS.unknownRecipeLinks[_G.ITEMTYPE_DRINK])
        elseif (vars.Display == furnishing) then
            display = BS.unknownRecipeLinks[_G.ITEMTYPE_FURNISHING]
        end

        for _, link in ipairs(display) do
            -- chat router insists on having the name, even though the link works in game
            local itemName = GetItemLinkName(link)
            local itemId = GetItemLinkItemId(link)
            local newLink = BS.MakeItemLink(itemId, itemName)

            CHAT_ROUTER:AddSystemMessage(newLink)
        end
    end,
    customOptions = {
        name = GetString(_G.BARSTEWARD_RECIPES_DISPLAY),
        choices = {food, drink, foodAndDrink, furnishing},
        varName = "Display",
        refresh = true,
        default = food
    }
}

BS.widgets[BS.W_UNKNOWN_WRIT_MOTIFS] = {
    -- v1.4.30
    name = "unknownWritMotifs",
    update = function(widget, event)
        local this = BS.W_UNKNOWN_WRIT_MOTIFS

        if (event == "initial") then
            widget:SetColour(unpack(BS.GetColour(this)))
            return
        end

        local writs = 0
        local bags = {_G.BAG_BACKPACK, _G.BAG_BANK}
        local unknown = {}

        if (IsESOPlusSubscriber()) then
            table.insert(bags, _G.BAG_SUBSCRIBER_BANK)
        end

        for _, bag in pairs(bags) do
            for _, data in pairs(_G.SHARED_INVENTORY.bagCache[bag]) do
                if (data.specializedItemType == _G.SPECIALIZED_ITEMTYPE_MASTER_WRIT) then
                    writs = writs + 1
                    local itemLink = GetItemLink(bag, data.slotIndex)
                    local writData = BS.ToWritFields(itemLink)

                    -- only interested in crafting types that use motifs
                    if
                        (writData.writType == _G.CRAFTING_TYPE_BLACKSMITHING or
                            writData.writType == _G.CRAFTING_TYPE_CLOTHIER or
                            writData.writType == _G.CRAFTING_TYPE_WOODWORKING)
                     then
                        local knowsMotif =
                            BS.LibCK.GetMotifKnowledgeForCharacter(
                            tonumber(writData.motifNumber),
                            tonumber(writData.itemType)
                        )

                        if (knowsMotif ~= BS.LibCK.KNOWLEDGE_KNOWN) then
                            local styleName = GetItemStyleName(writData.motifNumber)
                            local chapterName = GetString("SI_ITEMSTYLECHAPTER", writData.itemType)
                            local motifName = zo_strformat("<<C:1>> <<m:2>>", styleName, chapterName)
                            local colour = GetItemQualityColor(writData.itemQuality)
                            local name = colour:Colorize(motifName)
                            local motifId =
                                _G.LibCharacterKnowledgeInternal.GetStyleMotifItems(writData.motifNumber).number

                            name = motifId .. ". " .. name
                            unknown[name] = true
                        end
                    end
                end
            end
        end

        local display = {}

        for motif, _ in pairs(unknown) do
            table.insert(display, motif)
        end

        table.sort(display)

        widget:SetColour(unpack(BS.GetColour(this)))
        widget:SetValue(#display)

        if (#display > 0) then
            local tt = GetString(_G.BARSTEWARD_UNKNOWN_WRIT_MOTIFS)

            for _, motif in ipairs(display) do
                tt = tt .. BS.LF .. motif
            end

            widget.tooltip = tt
        end

        return widget:GetValue()
    end,
    event = {_G.EVENT_LORE_BOOK_LEARNED},
    callbackLCK = true,
    callback = {[SHARED_INVENTORY] = {"SingleSlotInventoryUpdate"}},
    icon = "icons/crafting_motif_binding_welkynar",
    tooltip = GetString(_G.BARSTEWARD_UNKNOWN_WRIT_MOTIFS)
}
