local points = 0
local lifetimeKills = 0
local pointsPerClick = 1
local upgradeCost = 10
local frogCount = 0
local frogCost = 10
local dimondCount = 0
local dimondCost = 2000
local duplicateMelonsCost = 100
local duplicateMelonsPurchased = false
local exponentialUpgradeCost = 100
local exponentialUpgradeCount = 0
local killMultiplier = 1
local frogTimer = 0
local dimondTimer = 0
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
        set = function(value) frogCount = value end
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
    }
}

-- Define button dimensions and positions
local clickBtn = { x = 240, y = 200, w = 200, h = 60, text = "Kill Melons!" }
local upgradeBtn = { x = 240, y = 280, w = 200, h = 70 }
local hirefrogsBtn = { x = 240, y = 380, w = 200, h = 60 }
local duplicateMelonsBtn = { x = 20, y = 200, w = 200, h = 60 }
local exponentialBtn = { x = 20, y = 280, w = 200, h = 60 }
local hireDimondsBtn = { x = 20, y = 360, w = 200, h = 60 }

local titleFont
local scoreFont
local bodyFont
local buttonFont
local greenButtonTexture
local grayButtonTexture
local melonTexture
local melonRotation = 0
local miniMelonAnimationTime = 0
local melonDisplayHeight = 220

function love.load()
    titleFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 18, "mono")
    scoreFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 12, "mono")
    bodyFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 10, "mono")
    buttonFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 9, "mono")

    greenButtonTexture = love.graphics.newImage("assets/greenbutton.png")
    grayButtonTexture = love.graphics.newImage("assets/graybutton.png")
    melonTexture = love.graphics.newImage("melonport_invis.png")
    melonTexture:setFilter("nearest", "nearest")

    local iconData = love.image.newImageData("melonport_invis.png")
    love.window.setIcon(iconData)
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
                commandStatus = "set/add/sub <kills|frogs|dimonds|exponents> <amount>"
            else
                local action, targetName, amountText = input:match("^(%a+)%s+(%a+)%s+(%d+)$")
                local amount = tonumber(amountText)
                local target = targetName and commandTargets[targetName:lower()]
                if action and target and amount and amount < math.huge then
                    action = action:lower()
                    local currentValue = target.get()
                    if action == "set" then
                        target.set(amount)
                        commandStatus = target.label .. " set to " .. amount
                    elseif action == "add" then
                        target.set(currentValue + amount)
                        commandStatus = "Added " .. amount .. " " .. target.label
                    elseif action == "sub" and currentValue >= amount then
                        target.set(currentValue - amount)
                        commandStatus = "Subtracted " .. amount .. " " .. target.label
                    elseif action == "sub" then
                        commandStatus = "Not enough " .. target.label
                    else
                        commandStatus = "Unknown action. Type help"
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
    amount = amount * killMultiplier * (1.1 ^ exponentialUpgradeCount)
    points = points + amount
    lifetimeKills = lifetimeKills + amount
    killsSinceSample = killsSinceSample + amount
end

local function drawButtonTexture(texture, button)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        texture,
        button.x,
        button.y,
        0,
        button.w / texture:getWidth(),
        button.h / texture:getHeight()
    )
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
            if points >= frogCost then
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
    end
end

function love.update(dt)
    melonRotation = (melonRotation + dt * math.pi / 4) % (2 * math.pi)
    miniMelonAnimationTime = miniMelonAnimationTime + dt

    frogTimer = frogTimer + dt
    while frogTimer >= 1 do
        frogTimer = frogTimer - 1
        if frogCount > 0 then
            killMelons(frogCount)
        end
    end

    dimondTimer = dimondTimer + dt
    while dimondTimer >= 0.25 do
        dimondTimer = dimondTimer - 0.25
        if dimondCount > 0 then
            killMelons(dimondCount * 50)
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
    points = math.ceil(points)
    love.graphics.setFont(titleFont)
    love.graphics.print("Game where you kill melons", 200, 40)

    love.graphics.setFont(scoreFont)
    love.graphics.print("Dead Melonports: " .. points, 200, 100)

    love.graphics.setFont(bodyFont)
    love.graphics.print("Per Kill: " .. pointsPerClick, 200, 140)
    love.graphics.print(string.format("K/S: %.1f", killsPerSecond), 200, 170)

    drawButtonTexture(greenButtonTexture, clickBtn)

    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.setFont(buttonFont)
    love.graphics.printf(clickBtn.text, clickBtn.x, clickBtn.y + 18, clickBtn.w, "center")

    -- 3. Draw "Upgrade" Button
    local upgradeTexture = points >= upgradeCost and greenButtonTexture or grayButtonTexture
    drawButtonTexture(upgradeTexture, upgradeBtn)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Kidnap a melon (" .. upgradeCost .. " kills)", upgradeBtn.x, upgradeBtn.y + 18, upgradeBtn.w, "center")

    local frogTexture = points >= frogCost and greenButtonTexture or grayButtonTexture
    drawButtonTexture(frogTexture, hirefrogsBtn)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(buttonFont)
    love.graphics.printf("Hire Frog", hirefrogsBtn.x, hirefrogsBtn.y + 6, hirefrogsBtn.w, "center")
    love.graphics.printf("(" .. frogCost .. " kills)", hirefrogsBtn.x, hirefrogsBtn.y + 34, hirefrogsBtn.w, "center")

    local dimondTexture = points >= dimondCost and greenButtonTexture or grayButtonTexture
    drawButtonTexture(dimondTexture, hireDimondsBtn)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(buttonFont)
    love.graphics.printf("Hire Dimond", hireDimondsBtn.x, hireDimondsBtn.y + 6, hireDimondsBtn.w, "center")
    love.graphics.printf("(" .. dimondCost .. " kills)", hireDimondsBtn.x, hireDimondsBtn.y + 34, hireDimondsBtn.w, "center")

    love.graphics.setFont(bodyFont)
    love.graphics.print("Frogs: " .. frogCount, hirefrogsBtn.x, hirefrogsBtn.y + hirefrogsBtn.h + 10)
    love.graphics.print("Dimonds: " .. dimondCount, hireDimondsBtn.x, hireDimondsBtn.y + hireDimondsBtn.h + 10)

    local duplicateTexture = not duplicateMelonsPurchased and points >= duplicateMelonsCost
        and greenButtonTexture or grayButtonTexture
    drawButtonTexture(duplicateTexture, duplicateMelonsBtn)
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(1, 1, 1)
    if duplicateMelonsPurchased then
        love.graphics.printf("Bought", duplicateMelonsBtn.x, duplicateMelonsBtn.y + 18, duplicateMelonsBtn.w, "center")
    else
        love.graphics.printf("Duplicate Melons", duplicateMelonsBtn.x, duplicateMelonsBtn.y + 6, duplicateMelonsBtn.w, "center")
        love.graphics.printf("(100 kills)", duplicateMelonsBtn.x, duplicateMelonsBtn.y + 34, duplicateMelonsBtn.w, "center")
    end

    local exponentialTexture = points >= exponentialUpgradeCost and greenButtonTexture or grayButtonTexture
    drawButtonTexture(exponentialTexture, exponentialBtn)
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Exponential x1.1", exponentialBtn.x, exponentialBtn.y + 6, exponentialBtn.w, "center")
    love.graphics.printf("(" .. exponentialUpgradeCost .. " kills)", exponentialBtn.x, exponentialBtn.y + 34, exponentialBtn.w, "center")

    local melonScale = melonDisplayHeight / melonTexture:getHeight()
    local melonWidth = melonTexture:getWidth() * melonScale
    local melonCenterX = love.graphics.getWidth() - melonWidth / 2 - 105
    local melonCenterY = love.graphics.getHeight() / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        melonTexture,
        melonCenterX,
        melonCenterY,
        melonRotation,
        melonScale,
        melonScale,
        melonTexture:getWidth() / 2,
        melonTexture:getHeight() / 2
    )

    local orbitingMelonCount = 0
    local nextKillMilestone = 10
    while lifetimeKills >= nextKillMilestone do
        orbitingMelonCount = orbitingMelonCount + 1
        nextKillMilestone = nextKillMilestone * 10
    end

    local smallMelonScale = 36 / melonTexture:getHeight()
    for i = 1, orbitingMelonCount do
        local phase = 2 * math.pi * (i - 1) / orbitingMelonCount
        local angle = phase + miniMelonAnimationTime * (0.8 + i * 0.12)
        local orbitRadius = 135 + math.sin(miniMelonAnimationTime * 1.5 + phase) * 12
        local spriteRotation = miniMelonAnimationTime * (1.2 + i * 0.2)
        love.graphics.draw(
            melonTexture,
            melonCenterX + math.cos(angle) * orbitRadius,
            melonCenterY + math.sin(angle) * orbitRadius,
            spriteRotation,
            smallMelonScale,
            smallMelonScale,
            melonTexture:getWidth() / 2,
            melonTexture:getHeight() / 2
        )
    end

    local commandY = love.graphics.getHeight() - 48
    local commandWidth = math.max(200, love.graphics.getWidth() - 40)
    love.graphics.setColor(commandFocused and 0.3 or 0.6, commandFocused and 0.9 or 0.6, commandFocused and 1 or 0.6)
    love.graphics.rectangle("line", 20, commandY, commandWidth, 36)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(bodyFont)
    local displayedCommand = commandInput
    if displayedCommand == "" and not commandFocused then
        displayedCommand = "Click to focus"
    end
    love.graphics.print(displayedCommand, 28, commandY + 10)
    love.graphics.print(commandStatus, 20, commandY - bodyFont:getHeight() - 4)
end