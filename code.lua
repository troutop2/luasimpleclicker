local points = 0
local lifetimeKills = 0
local pointsPerClick = 1
local upgradeCost = 10
local frogCount = 0
local frogCost = 10
local frogCap = 50
local dimondCount = 0
local dimondCost = 2000
local duplicateMelonsCost = 100
local duplicateMelonsPurchased = false
local exponentialUpgradeCost = 100
local exponentialUpgradeCount = 0
local drugFrogsCost = 50000
local drugFrogsCount = 0
local drugFrogsCap = 5
local research = 0
local researchHeadStartRanks = 0
local researchMultiplyRanks = 0
local researchExponentRanks = 0
local doubleProductionResearchPurchased = false
local killMultiplier = 1
local frogTimer = 0
local dimondTimer = 0
local headStartTimer = 0
local killsPerSecond = 0
local killsSinceSample = 0
local sampleTimer = 0
local commandInput = ""
local commandStatus = "Type help for commands"
local commandFocused = false
local commandTargets = {
    kills = {
        label = "kills",
        get = function() return points end,
        set = function(value) points = value end
    },
    frogs = {
        label = "frogs",
        get = function() return frogCount end,
        set = function(value) frogCount = value end,
        max = frogCap
    },
    dimonds = {
        label = "dimonds",
        get = function() return dimondCount end,
        set = function(value) dimondCount = value end
    },
    exponents = {
        label = "exponents",
        get = function() return exponentialUpgradeCount end,
        set = function(value) exponentialUpgradeCount = value end
    },
    research = {
        label = "research",
        get = function() return research end,
        set = function(value) research = value end
    },
    drug = {
        label = "drug upgrades",
        get = function() return drugFrogsCount end,
        set = function(value) drugFrogsCount = value end,
        max = drugFrogsCap
    }
}

-- Define button dimensions and positions
local clickBtn = { x = 240, y = 200, w = 200, h = 60, text = "Kill Melons!" }
local upgradeBtn = { x = 240, y = 280, w = 200, h = 70 }
local hirefrogsBtn = { x = 240, y = 380, w = 200, h = 60 }
local duplicateMelonsBtn = { x = 20, y = 200, w = 200, h = 60 }
local exponentialBtn = { x = 20, y = 280, w = 200, h = 60 }
local hireDimondsBtn = { x = 20, y = 360, w = 200, h = 60 }
local drugFrogsBtn = { x = 20, y = 440, w = 200, h = 60 }
local rebirthBtn = { x = 240, y = 460, w = 200, h = 60 }
local headStartMenuBtn = { x = 480, y = 400, w = 105, h = 50 }
local multiplyMenuBtn = { x = 595, y = 400, w = 105, h = 50 }
local exponentMenuBtn = { x = 480, y = 460, w = 105, h = 50 }
local productionMenuBtn = { x = 595, y = 460, w = 105, h = 50 }
local researchTreeOpen = false
local researchTreeSection = "headstart"
local researchTreeCloseBtn = { x = 380, y = 65, w = 40, h = 40 }
local researchHeadStartButtons = {}
for rank = 1, 5 do
    researchHeadStartButtons[rank] = { x = 110, y = 190 + (rank - 1) * 47, w = 270, h = 42 }
end
local researchMultiplyButtons = {}
for rank = 1, 10 do
    researchMultiplyButtons[rank] = { x = 110, y = 180 + (rank - 1) * 32, w = 270, h = 27 }
end
local researchExponentButtons = {}
for rank = 1, 10 do
    researchExponentButtons[rank] = { x = 110, y = 180 + (rank - 1) * 32, w = 270, h = 27 }
end
local doubleProductionResearchButton = { x = 110, y = 190, w = 270, h = 42 }
local buttons = {
    clickBtn,
    upgradeBtn,
    hirefrogsBtn,
    duplicateMelonsBtn,
    exponentialBtn,
    hireDimondsBtn,
    drugFrogsBtn,
    rebirthBtn,
    headStartMenuBtn,
    multiplyMenuBtn,
    exponentMenuBtn,
    productionMenuBtn
}
local buttonPressDuration = 0.24
local buttonPressAmount = 0.08
local melonPressTime = 0

local titleFont
local scoreFont
local bodyFont
local buttonFont
local greenButtonTexture
local grayButtonTexture
local blueButtonTexture
local melonTexture
local backgroundTexture
local backgroundQuad
local backgroundOffsetX = 0
local backgroundOffsetY = 0
local melonRotation = 0
local miniMelonAnimationTime = 0
local melonDisplayHeight = 220
local orbitingMelons = {}

function love.load()
    titleFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 18, "mono")
    scoreFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 12, "mono")
    bodyFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 10, "mono")
    buttonFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 9, "mono")

    greenButtonTexture = love.graphics.newImage("assets/greenbutton.png")
    grayButtonTexture = love.graphics.newImage("assets/graybutton.png")
    blueButtonTexture = love.graphics.newImage("assets/bluebutton.png")
    backgroundTexture = love.graphics.newImage("assets/brickwall.png")
    backgroundTexture:setFilter("nearest", "nearest")
    backgroundTexture:setWrap("repeat", "repeat")
    backgroundQuad = love.graphics.newQuad(
        backgroundOffsetX,
        backgroundOffsetY,
        love.graphics.getWidth(),
        love.graphics.getHeight(),
        backgroundTexture:getDimensions()
    )
    melonTexture = love.graphics.newImage("melonport_invis.png")
    melonTexture:setFilter("nearest", "nearest")

    local iconData = love.image.newImageData("melonport_invis.png")
    love.window.setIcon(iconData)

end

local function getRebirthResearchReward()
    local reward = math.floor(math.sqrt(points / 1000))
    if points >= 1e6 then
        reward = reward + 10
    end
    if points >= 1e9 then
        reward = reward + 100
    end
    if points >= 1e12 then
        reward = reward + 1000
    end
    return reward
end

local function rebirth()
    local reward = getRebirthResearchReward()
    if reward <= 0 then
        return
    end

    research = research + reward
    points = 0
    lifetimeKills = 0
    pointsPerClick = 1
    upgradeCost = 10
    frogCount = 0
    frogCost = 10
    dimondCount = 0
    dimondCost = 2000
    duplicateMelonsPurchased = false
    exponentialUpgradeCost = 100
    exponentialUpgradeCount = 0
    drugFrogsCost = 50000
    drugFrogsCount = 0
    killMultiplier = 1
    frogTimer = 0
    dimondTimer = 0
    killsPerSecond = 0
    killsSinceSample = 0
    sampleTimer = 0
    orbitingMelons = {}
end

function love.resize(width, height)
    if backgroundTexture then
        backgroundQuad = love.graphics.newQuad(
            backgroundOffsetX,
            backgroundOffsetY,
            width,
            height,
            backgroundTexture:getDimensions()
        )
    end
end

function love.keypressed(key)
    if key == "f11" then
        local success, message = love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
        if not success then
            error(message)
        end
    elseif commandFocused then
        if key == "return" or key == "kpenter" then
            local input = commandInput:match("^%s*(.-)%s*$")
            if input:lower() == "help" then
                commandStatus = "set/add/sub <kills|frogs|dimonds|exponents|drug|research> <amount>"
            else
                local action, targetName, amountText = input:match("^(%a+)%s+(%a+)%s+(%d+)$")
                local amount = tonumber(amountText)
                local target = targetName and commandTargets[targetName:lower()]
                if action and target and amount and amount < math.huge then
                    action = action:lower()
                    local currentValue = target.get()
                    local newValue
                    if action == "set" then
                        newValue = amount
                    elseif action == "add" then
                        newValue = currentValue + amount
                    elseif action == "sub" then
                        newValue = currentValue - amount
                    else
                        commandStatus = "Unknown action. Type help"
                    end
                    if newValue then
                        if newValue < 0 then
                            commandStatus = "Not enough " .. target.label
                        elseif target.max and newValue > target.max then
                            commandStatus = "Drug upgrades are capped at " .. target.max
                        else
                            target.set(newValue)
                            commandStatus = target.label .. " set to " .. newValue
                        end
                    end
                else
                    commandStatus = "Invalid command. Type help"
                end
            end
            commandInput = ""
        elseif key == "backspace" then
            commandInput = commandInput:sub(1, -2)
        elseif key == "escape" then
            commandFocused = false
        end
    end
end

function love.textinput(text)
    if commandFocused and #commandInput < 48 then
        commandInput = commandInput .. text
    end
end

-- Helper function: checks if a point (x, y) is inside a rectangle
local function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function killMelons(amount)
    amount = amount * (killMultiplier + researchMultiplyRanks * 0.5)
        * (1.1 ^ (exponentialUpgradeCount + researchExponentRanks * 0.1))
    points = points + amount
    lifetimeKills = lifetimeKills + amount
    killsSinceSample = killsSinceSample + amount

    local nextMilestone = 10 ^ (#orbitingMelons + 1)
    while lifetimeKills >= nextMilestone do
        table.insert(orbitingMelons, {
            height = love.math.random(-55, 55),
            bobPhase = love.math.random() * 2 * math.pi,
            bobSpeed = 0.8 + love.math.random() * 1.2
        })
        nextMilestone = 10 ^ (#orbitingMelons + 1)
    end
end

local function getPassiveProductionMultiplier()
    return doubleProductionResearchPurchased and 2 or 1
end

local function isMultiplyResearchUnlocked()
    return researchHeadStartRanks == #researchHeadStartButtons
end

local function isExponentResearchUnlocked()
    return isMultiplyResearchUnlocked()
        and researchMultiplyRanks == #researchMultiplyButtons
end

local function isDoubleProductionResearchUnlocked()
    return isExponentResearchUnlocked()
        and researchExponentRanks == #researchExponentButtons
end

local function getPressScale(pressTime)
    local progress = math.min(1, math.max(0, 1 - pressTime / buttonPressDuration))
    local scale
    if progress < 0.35 then
        local t = progress / 0.35
        scale = 1 - buttonPressAmount * t * t * (3 - 2 * t)
    elseif progress < 0.7 then
        local t = (progress - 0.35) / 0.35
        scale = 1 - buttonPressAmount + 0.105 * t * t * (3 - 2 * t)
    else
        local t = (progress - 0.7) / 0.3
        scale = 1.025 - 0.025 * t * t * (3 - 2 * t)
    end
    return scale
end

local function drawButtonTexture(texture, button)
    local scale = getPressScale(button.pressTime or 0)
    love.graphics.push()
    love.graphics.translate(button.x + button.w / 2, button.y + button.h / 2)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-button.x - button.w / 2, -button.y - button.h / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        texture,
        button.x,
        button.y,
        0,
        button.w / texture:getWidth(),
        button.h / texture:getHeight()
    )
    love.graphics.pop()
end

local function printfButton(text, button, yOffset)
    local scale = getPressScale(button.pressTime or 0)
    love.graphics.push()
    love.graphics.translate(button.x + button.w / 2, button.y + button.h / 2)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-button.x - button.w / 2, -button.y - button.h / 2)
    love.graphics.printf(text, button.x, button.y + yOffset, button.w, "center")
    love.graphics.pop()
end

local function drawResearchMenuButtons()
    love.graphics.setFont(bodyFont)
    love.graphics.setColor(0, 0.4, 1)
    love.graphics.print("Research: " .. research, rebirthBtn.x + rebirthBtn.w + 90, 80)

    local multiplyUnlocked = isMultiplyResearchUnlocked()
    local exponentUnlocked = isExponentResearchUnlocked()
    local productionUnlocked = isDoubleProductionResearchUnlocked()
    local headStartAvailable = researchHeadStartRanks == #researchHeadStartButtons
        or research >= 2 ^ researchHeadStartRanks
    local multiplyAvailable = multiplyUnlocked and (researchMultiplyRanks == #researchMultiplyButtons
        or research >= 2 ^ researchMultiplyRanks)
    local exponentAvailable = exponentUnlocked and (researchExponentRanks == #researchExponentButtons
        or research >= 2 ^ researchExponentRanks)
    local productionAvailable = productionUnlocked
        and not doubleProductionResearchPurchased and research >= 1
    love.graphics.setColor(0.65, 0.65, 0.65, 1)
    love.graphics.line(headStartMenuBtn.x + headStartMenuBtn.w,
        headStartMenuBtn.y + headStartMenuBtn.h / 2,
        multiplyMenuBtn.x, multiplyMenuBtn.y + multiplyMenuBtn.h / 2)
    love.graphics.line(multiplyMenuBtn.x + multiplyMenuBtn.w / 2,
        multiplyMenuBtn.y + multiplyMenuBtn.h,
        exponentMenuBtn.x + exponentMenuBtn.w / 2, exponentMenuBtn.y)
    love.graphics.line(exponentMenuBtn.x + exponentMenuBtn.w,
        exponentMenuBtn.y + exponentMenuBtn.h / 2,
        productionMenuBtn.x, productionMenuBtn.y + productionMenuBtn.h / 2)
    drawButtonTexture(headStartAvailable and blueButtonTexture or grayButtonTexture, headStartMenuBtn)
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(1, 1, 1)
    printfButton("Headstart", headStartMenuBtn, 18)
    drawButtonTexture(multiplyAvailable and blueButtonTexture or grayButtonTexture, multiplyMenuBtn)
    love.graphics.setColor(1, 1, 1)
    printfButton("Multiply", multiplyMenuBtn, 18)
    drawButtonTexture(exponentAvailable and blueButtonTexture or grayButtonTexture, exponentMenuBtn)
    love.graphics.setColor(1, 1, 1)
    printfButton("Exponent", exponentMenuBtn, 18)
    drawButtonTexture(productionAvailable and blueButtonTexture or grayButtonTexture, productionMenuBtn)
    love.graphics.setColor(1, 1, 1)
    printfButton("Double Prod.", productionMenuBtn, 18)
end

local function drawResearchPanel()
    if not researchTreeOpen then
        return
    end

    local panelX, panelY, panelWidth, panelHeight = 90, 55, 340, 490
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)
    love.graphics.setFont(buttonFont)
    local sectionTitle = researchTreeSection == "headstart" and "Headstart"
        or researchTreeSection == "multiply" and "Multiply"
        or researchTreeSection == "exponent" and "Exponent" or "Double Production"
    love.graphics.printf(sectionTitle, panelX, panelY + 18, panelWidth, "center")

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", researchTreeCloseBtn.x, researchTreeCloseBtn.y,
        researchTreeCloseBtn.w, researchTreeCloseBtn.h)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf("X", researchTreeCloseBtn.x, researchTreeCloseBtn.y + 10,
        researchTreeCloseBtn.w, "center")

    love.graphics.setFont(bodyFont)
    love.graphics.setColor(1, 1, 1, 1)
    if researchTreeSection == "headstart" then
        for rank = 1, #researchHeadStartButtons - 1 do
            local currentButton = researchHeadStartButtons[rank]
            local dependentButton = researchHeadStartButtons[rank + 1]
            love.graphics.setColor(0.65, 0.65, 0.65, 1)
            love.graphics.line(
                currentButton.x + currentButton.w / 2,
                currentButton.y + currentButton.h,
                dependentButton.x + dependentButton.w / 2,
                dependentButton.y
            )
        end
        for rank = 1, #researchHeadStartButtons do
            local researchButton = researchHeadStartButtons[rank]
            local isPurchased = rank <= researchHeadStartRanks
            local cost = 2 ^ (rank - 1)
            local isAvailable = rank == researchHeadStartRanks + 1
            local canPurchase = not isPurchased and isAvailable and research >= cost
            local texture = isPurchased and blueButtonTexture
                or (canPurchase and blueButtonTexture or grayButtonTexture)
            drawButtonTexture(texture, researchButton)
            love.graphics.setFont(bodyFont)
            love.graphics.setColor(1, 1, 1, 1)
            local label = isPurchased
                and ("Rank " .. rank .. ": +5 kills/sec (Bought)")
                or ("Rank " .. rank .. ": +5 kills/sec (" .. cost .. " research)")
            love.graphics.printf(label, researchButton.x + 8, researchButton.y + 16,
                researchButton.w - 16, "center")
        end
    elseif researchTreeSection == "multiply" then
        local multiplyUnlocked = isMultiplyResearchUnlocked()
        for rank = 1, #researchMultiplyButtons - 1 do
            local currentButton = researchMultiplyButtons[rank]
            local dependentButton = researchMultiplyButtons[rank + 1]
            love.graphics.setColor(0.65, 0.65, 0.65, 1)
            love.graphics.line(
                currentButton.x + currentButton.w / 2,
                currentButton.y + currentButton.h,
                dependentButton.x + dependentButton.w / 2,
                dependentButton.y
            )
        end
        for rank = 1, #researchMultiplyButtons do
            local researchButton = researchMultiplyButtons[rank]
            local isPurchased = rank <= researchMultiplyRanks
            local cost = 2 ^ (rank - 1)
            local isAvailable = multiplyUnlocked and rank == researchMultiplyRanks + 1
            local canPurchase = not isPurchased and isAvailable and research >= cost
            local texture = isPurchased and blueButtonTexture
                or (canPurchase and blueButtonTexture or grayButtonTexture)
            drawButtonTexture(texture, researchButton)
            love.graphics.setFont(bodyFont)
            love.graphics.setColor(1, 1, 1, 1)
            local label = isPurchased
                and ("Rank " .. rank .. ": +0.5 multiplier (Bought)")
                or ("Rank " .. rank .. ": +0.5 multiplier (" .. cost .. " research)")
            love.graphics.printf(label, researchButton.x + 6, researchButton.y + 8,
                researchButton.w - 12, "center")
        end
    elseif researchTreeSection == "exponent" then
        local exponentUnlocked = isExponentResearchUnlocked()
        for rank = 1, #researchExponentButtons - 1 do
            local currentButton = researchExponentButtons[rank]
            local dependentButton = researchExponentButtons[rank + 1]
            love.graphics.setColor(0.65, 0.65, 0.65, 1)
            love.graphics.line(
                currentButton.x + currentButton.w / 2,
                currentButton.y + currentButton.h,
                dependentButton.x + dependentButton.w / 2,
                dependentButton.y
            )
        end
        for rank = 1, #researchExponentButtons do
            local researchButton = researchExponentButtons[rank]
            local isPurchased = rank <= researchExponentRanks
            local cost = 2 ^ (rank - 1)
            local isAvailable = exponentUnlocked and rank == researchExponentRanks + 1
            local canPurchase = not isPurchased and isAvailable and research >= cost
            local texture = isPurchased and blueButtonTexture
                or (canPurchase and blueButtonTexture or grayButtonTexture)
            drawButtonTexture(texture, researchButton)
            love.graphics.setFont(bodyFont)
            love.graphics.setColor(1, 1, 1, 1)
            local label = isPurchased
                and ("Rank " .. rank .. ": +0.1 exponent (Bought)")
                or ("Rank " .. rank .. ": +0.1 exponent (" .. cost .. " research)")
            love.graphics.printf(label, researchButton.x + 6, researchButton.y + 8,
                researchButton.w - 12, "center")
        end
    else
        local isPurchased = doubleProductionResearchPurchased
        local canPurchase = isDoubleProductionResearchUnlocked()
            and not isPurchased and research >= 1
        local texture = isPurchased and blueButtonTexture
            or (canPurchase and blueButtonTexture or grayButtonTexture)
        drawButtonTexture(texture, doubleProductionResearchButton)
        love.graphics.setFont(bodyFont)
        love.graphics.setColor(1, 1, 1, 1)
        local label = isPurchased
            and "Double passive production (Bought)"
            or "Double passive production (1 research)"
        love.graphics.printf(label, doubleProductionResearchButton.x + 8,
            doubleProductionResearchButton.y + 16, doubleProductionResearchButton.w - 16,
            "center")
    end

    love.graphics.setFont(bodyFont)
    love.graphics.setColor(1, 1, 1, 1)
    if researchTreeSection == "headstart" then
        love.graphics.print("Unlocked: +" .. researchHeadStartRanks * 5 .. " kills/sec",
            panelX + 20, panelY + panelHeight - 34)
    elseif researchTreeSection == "multiply" then
        if isMultiplyResearchUnlocked() then
            love.graphics.print("Multiplier bonus: +" .. researchMultiplyRanks * 0.5,
                panelX + 20, panelY + panelHeight - 34)
        else
            love.graphics.print("Locked: complete Headstart first",
                panelX + 20, panelY + panelHeight - 34)
        end
    elseif researchTreeSection == "exponent" then
        if isExponentResearchUnlocked() then
            love.graphics.print("Exponent research: +" .. researchExponentRanks * 0.1,
                panelX + 20, panelY + panelHeight - 34)
        else
            love.graphics.print("Locked: complete Multiply first",
                panelX + 20, panelY + panelHeight - 34)
        end
    else
        local status = isDoubleProductionResearchUnlocked()
            and (doubleProductionResearchPurchased and "Passive production doubled"
                or "Passive production unchanged")
            or "Locked: complete Exponent first"
        love.graphics.print(status, panelX + 20, panelY + panelHeight - 34)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse click
        local commandY = love.graphics.getHeight() - 48
        local commandWidth = math.max(200, love.graphics.getWidth() - 40)
        if pointInRect(x, y, 20, commandY, commandWidth, 36) then
            commandFocused = true
            return
        end
        commandFocused = false

        if researchTreeOpen then
            if pointInRect(x, y, researchTreeCloseBtn.x, researchTreeCloseBtn.y,
                researchTreeCloseBtn.w, researchTreeCloseBtn.h) then
                researchTreeOpen = false
                return
            end

            if researchTreeSection == "headstart" then
                local visibleRank = researchHeadStartRanks + 1
                if visibleRank <= #researchHeadStartButtons then
                    local researchButton = researchHeadStartButtons[visibleRank]
                    local cost = 2 ^ (visibleRank - 1)
                    if pointInRect(x, y, researchButton.x, researchButton.y,
                        researchButton.w, researchButton.h) and research >= cost then
                        research = research - cost
                        researchHeadStartRanks = visibleRank
                    end
                end
            elseif researchTreeSection == "multiply"
                and isMultiplyResearchUnlocked() then
                local visibleRank = researchMultiplyRanks + 1
                if visibleRank <= #researchMultiplyButtons then
                    local researchButton = researchMultiplyButtons[visibleRank]
                    local cost = 2 ^ (visibleRank - 1)
                    if pointInRect(x, y, researchButton.x, researchButton.y,
                        researchButton.w, researchButton.h) and research >= cost then
                        research = research - cost
                        researchMultiplyRanks = visibleRank
                    end
                end
            elseif researchTreeSection == "exponent" then
                local visibleRank = researchExponentRanks + 1
                if visibleRank <= #researchExponentButtons then
                    local researchButton = researchExponentButtons[visibleRank]
                    local cost = 2 ^ (visibleRank - 1)
                    if pointInRect(x, y, researchButton.x, researchButton.y,
                        researchButton.w, researchButton.h) and research >= cost then
                        research = research - cost
                        researchExponentRanks = visibleRank
                    end
                end
            elseif researchTreeSection == "production"
                and isDoubleProductionResearchUnlocked()
                and not doubleProductionResearchPurchased then
                local cost = 1
                if pointInRect(x, y, doubleProductionResearchButton.x,
                    doubleProductionResearchButton.y, doubleProductionResearchButton.w,
                    doubleProductionResearchButton.h) and research >= cost then
                    research = research - cost
                    doubleProductionResearchPurchased = true
                end
            end
            return
        end

        for _, clickableButton in ipairs(buttons) do
            if pointInRect(x, y, clickableButton.x, clickableButton.y, clickableButton.w, clickableButton.h) then
                clickableButton.pressTime = buttonPressDuration
            end
        end

        local melonScale = melonDisplayHeight / melonTexture:getHeight()
        local melonWidth = melonTexture:getWidth() * melonScale
        local melonCenterX = love.graphics.getWidth() - melonWidth / 2 - 105
        local melonCenterY = love.graphics.getHeight() / 2
        if pointInRect(
            x, y,
            melonCenterX - melonWidth / 2,
            melonCenterY - melonDisplayHeight / 2,
            melonWidth,
            melonDisplayHeight
        ) then
            melonPressTime = buttonPressDuration
        end

        -- Check click on "Click Me!" button
        if pointInRect(x, y, clickBtn.x, clickBtn.y, clickBtn.w, clickBtn.h) then
            killMelons(pointsPerClick)
        end

        -- Check click on "Upgrade" button
        if pointInRect(x, y, upgradeBtn.x, upgradeBtn.y, upgradeBtn.w, upgradeBtn.h) then
            if points >= upgradeCost then
                points = points - upgradeCost
                pointsPerClick = pointsPerClick + 1
                upgradeCost = math.floor(upgradeCost * 1.5)
            end
        end

        if pointInRect(x, y, hirefrogsBtn.x, hirefrogsBtn.y, hirefrogsBtn.w, hirefrogsBtn.h) then
            if frogCount < frogCap and points >= frogCost then
                points = points - frogCost
                frogCount = frogCount + 1
                frogCost = math.floor(frogCost * 1.3)
            end
        end

        if pointInRect(x, y, hireDimondsBtn.x, hireDimondsBtn.y, hireDimondsBtn.w, hireDimondsBtn.h) then
            if points >= dimondCost then
                points = points - dimondCost
                dimondCount = dimondCount + 1
                dimondCost = math.floor(dimondCost * 1.7)
            end
        end

        if pointInRect(x, y, duplicateMelonsBtn.x, duplicateMelonsBtn.y, duplicateMelonsBtn.w, duplicateMelonsBtn.h) then
            if not duplicateMelonsPurchased and points >= duplicateMelonsCost then
                points = points - duplicateMelonsCost
                duplicateMelonsPurchased = true
                killMultiplier = killMultiplier * 2
            end
        end

        if pointInRect(x, y, exponentialBtn.x, exponentialBtn.y, exponentialBtn.w, exponentialBtn.h) then
            if points >= exponentialUpgradeCost then
                points = points - exponentialUpgradeCost
                exponentialUpgradeCount = exponentialUpgradeCount + 1
                exponentialUpgradeCost = math.floor(exponentialUpgradeCost * 3)
            end
        end

        if pointInRect(x, y, drugFrogsBtn.x, drugFrogsBtn.y, drugFrogsBtn.w, drugFrogsBtn.h) then
            if drugFrogsCount < drugFrogsCap and points >= drugFrogsCost then
                points = points - drugFrogsCost
                drugFrogsCount = drugFrogsCount + 1
                drugFrogsCost = drugFrogsCost * 4
            end
        end

        if pointInRect(x, y, rebirthBtn.x, rebirthBtn.y, rebirthBtn.w, rebirthBtn.h) then
            rebirth()
        end

        if pointInRect(x, y, headStartMenuBtn.x, headStartMenuBtn.y,
            headStartMenuBtn.w, headStartMenuBtn.h) then
            researchTreeOpen = true
            researchTreeSection = "headstart"
        elseif pointInRect(x, y, multiplyMenuBtn.x, multiplyMenuBtn.y,
            multiplyMenuBtn.w, multiplyMenuBtn.h) then
            researchTreeOpen = true
            researchTreeSection = "multiply"
        elseif pointInRect(x, y, exponentMenuBtn.x, exponentMenuBtn.y,
            exponentMenuBtn.w, exponentMenuBtn.h) then
            researchTreeOpen = true
            researchTreeSection = "exponent"
        elseif pointInRect(x, y, productionMenuBtn.x, productionMenuBtn.y,
            productionMenuBtn.w, productionMenuBtn.h) then
            researchTreeOpen = true
            researchTreeSection = "production"
        end
    end
end

function love.update(dt)
    for _, animatedButton in ipairs(buttons) do
        animatedButton.pressTime = math.max(0, (animatedButton.pressTime or 0) - dt)
    end
    melonPressTime = math.max(0, melonPressTime - dt)

    backgroundOffsetX = (backgroundOffsetX + dt * 60) % backgroundTexture:getWidth()
    backgroundOffsetY = (backgroundOffsetY + dt * 24) % backgroundTexture:getHeight()
    backgroundQuad:setViewport(
        backgroundOffsetX,
        backgroundOffsetY,
        love.graphics.getWidth(),
        love.graphics.getHeight(),
        backgroundTexture:getDimensions()
    )

    melonRotation = (melonRotation + dt * math.pi / 4) % (2 * math.pi)
    miniMelonAnimationTime = miniMelonAnimationTime + dt

    frogTimer = frogTimer + dt
    while frogTimer >= 1 do
        frogTimer = frogTimer - 1
        if frogCount > 0 then
            local frogKills = frogCount
            if drugFrogsCount > 0 then
                frogKills = frogKills * frogCount ^ ((frogCount/10) * 0.2 * drugFrogsCount)
            end
            killMelons(frogKills * getPassiveProductionMultiplier())
        end
    end

    dimondTimer = dimondTimer + dt
    while dimondTimer >= 0.25 do
        dimondTimer = dimondTimer - 0.25
        if dimondCount > 0 then
            killMelons(dimondCount * 50 * getPassiveProductionMultiplier())
        end
    end

    headStartTimer = headStartTimer + dt
    while headStartTimer >= 1 do
        headStartTimer = headStartTimer - 1
        if researchHeadStartRanks > 0 then
            killMelons(researchHeadStartRanks * 5 * getPassiveProductionMultiplier())
        end
    end

    sampleTimer = sampleTimer + dt
    if sampleTimer >= 1 then
        killsPerSecond = killsSinceSample / sampleTimer
        killsSinceSample = 0
        sampleTimer = 0
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(backgroundTexture, backgroundQuad, 0, 0)

    points = math.ceil(points)
    love.graphics.setFont(titleFont)
    love.graphics.print("Game where you kill melons ---------- (Please Full screen)", 40, 40)

    love.graphics.setFont(scoreFont)
    love.graphics.print("Dead Melonports: " .. points, 40, 100)

    love.graphics.setFont(bodyFont)
    love.graphics.print("Per Kill: " .. pointsPerClick, 40, 140)
    love.graphics.print(string.format("K/S: %.1f", killsPerSecond), 40, 170)

    drawButtonTexture(greenButtonTexture, clickBtn)

    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.setFont(buttonFont)
    printfButton(clickBtn.text, clickBtn, 18)

    -- 3. Draw "Upgrade" Button
    local upgradeTexture = points >= upgradeCost and greenButtonTexture or grayButtonTexture
    drawButtonTexture(upgradeTexture, upgradeBtn)

    love.graphics.setColor(1, 1, 1)
    printfButton("Kidnap a melon (" .. upgradeCost .. " kills)", upgradeBtn, 18)

    local frogTexture = frogCount < frogCap and points >= frogCost
        and greenButtonTexture or grayButtonTexture
    drawButtonTexture(frogTexture, hirefrogsBtn)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(buttonFont)
    if frogCount >= frogCap then
        printfButton("Max Frogs", hirefrogsBtn, 18)
    else
        printfButton("Hire Frog", hirefrogsBtn, 6)
        printfButton("(" .. frogCost .. " kills)", hirefrogsBtn, 34)
    end

    local dimondTexture = points >= dimondCost and greenButtonTexture or grayButtonTexture
    drawButtonTexture(dimondTexture, hireDimondsBtn)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(buttonFont)
    printfButton("Hire Dimond", hireDimondsBtn, 6)
    printfButton("(" .. dimondCost .. " kills)", hireDimondsBtn, 34)

    love.graphics.setFont(bodyFont)
    love.graphics.print("Frogs: " .. frogCount, hirefrogsBtn.x, hirefrogsBtn.y + hirefrogsBtn.h + 10)
    love.graphics.print("Dimonds: " .. dimondCount, hireDimondsBtn.x, hireDimondsBtn.y + hireDimondsBtn.h + 10)

    local rebirthReward = getRebirthResearchReward()
    local rebirthTexture = rebirthReward > 0 and greenButtonTexture or grayButtonTexture
    drawButtonTexture(rebirthTexture, rebirthBtn)
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(1, 1, 1)
    printfButton("Rebirth", rebirthBtn, 6)
    printfButton("+" .. rebirthReward .. " research", rebirthBtn, 34)
    drawResearchMenuButtons()

    local drugFrogsTexture = drugFrogsCount < drugFrogsCap and points >= drugFrogsCost
        and greenButtonTexture or grayButtonTexture
    drawButtonTexture(drugFrogsTexture, drugFrogsBtn)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(buttonFont)
    if drugFrogsCount >= drugFrogsCap then
        printfButton("Max Drug Frogs", drugFrogsBtn, 18)
    else
        printfButton("Drug Frogs", drugFrogsBtn, 6)
        printfButton("(" .. drugFrogsCost .. " kills)", drugFrogsBtn, 34)
    end
    love.graphics.setFont(bodyFont)
    love.graphics.print("Drug upgrades: " .. drugFrogsCount, drugFrogsBtn.x, drugFrogsBtn.y + drugFrogsBtn.h + 10)

    local duplicateTexture = not duplicateMelonsPurchased and points >= duplicateMelonsCost
        and greenButtonTexture or grayButtonTexture
    drawButtonTexture(duplicateTexture, duplicateMelonsBtn)
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(1, 1, 1)
    if duplicateMelonsPurchased then
        printfButton("Bought", duplicateMelonsBtn, 18)
    else
        printfButton("Duplicate Melons", duplicateMelonsBtn, 6)
        printfButton("(100 kills)", duplicateMelonsBtn, 34)
    end

    local exponentialTexture = points >= exponentialUpgradeCost and greenButtonTexture or grayButtonTexture
    drawButtonTexture(exponentialTexture, exponentialBtn)
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(1, 1, 1)
    printfButton("Exponential x1.1", exponentialBtn, 6)
    printfButton("(" .. exponentialUpgradeCost .. " kills)", exponentialBtn, 34)

    local melonScale = melonDisplayHeight / melonTexture:getHeight()
    local melonWidth = melonTexture:getWidth() * melonScale
    local melonCenterX = love.graphics.getWidth() - melonWidth / 2 - 105
    local melonCenterY = love.graphics.getHeight() / 2
    love.graphics.setColor(1, 1, 1, 1)
    local melonPressScale = getPressScale(melonPressTime)
    love.graphics.draw(
        melonTexture,
        melonCenterX,
        melonCenterY,
        melonRotation,
        melonScale * melonPressScale,
        melonScale * melonPressScale,
        melonTexture:getWidth() / 2,
        melonTexture:getHeight() / 2
    )

    local smallMelonScale = 36 / melonTexture:getHeight()
    for i, miniMelon in ipairs(orbitingMelons) do
        local phase = 2 * math.pi * (i - 1) / #orbitingMelons
        local angle = phase + miniMelonAnimationTime * (0.8 + i * 0.12)
        local orbitRadius = 135 + math.sin(miniMelonAnimationTime * 1.5 + phase) * 12
        local spriteRotation = miniMelonAnimationTime * (1.2 + i * 0.2)
        local verticalOffset = miniMelon.height
            + math.sin(miniMelonAnimationTime * miniMelon.bobSpeed + miniMelon.bobPhase) * 18
        love.graphics.draw(
            melonTexture,
            melonCenterX + math.cos(angle) * orbitRadius,
            melonCenterY + math.sin(angle) * orbitRadius + verticalOffset,
            spriteRotation,
            smallMelonScale,
            smallMelonScale,
            melonTexture:getWidth() / 2,
            melonTexture:getHeight() / 2
        )
    end

    local commandY = love.graphics.getHeight() - 48
    local commandWidth = math.max(200, love.graphics.getWidth() - 40)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 20, commandY, commandWidth, 36)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 20, commandY, commandWidth, 36)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(bodyFont)
    local displayedCommand = commandInput
    if displayedCommand == "" and not commandFocused then
        displayedCommand = "Click to focus"
    end
    love.graphics.print(displayedCommand, 28, commandY + 10)
    love.graphics.print(commandStatus, 20, commandY - bodyFont:getHeight() - 4)

    drawResearchPanel()
end