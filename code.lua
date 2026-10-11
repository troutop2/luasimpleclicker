local points = 0
local pointsPerClick = 1
local upgradeCost = 10
local frogCount = 0
local frogCost = 10
local frogTimer = 0
local killsPerSecond = 0
local killsSinceSample = 0
local sampleTimer = 0

-- Define button dimensions and positions
local clickBtn = { x = 200, y = 200, w = 200, h = 60, text = "Kill Melons!" }
local upgradeBtn = { x = 200, y = 280, w = 200, h = 70 }
local hirefrogsBtn = { x = 200, y = 380, w = 200, h = 60 }

local titleFont
local scoreFont
local bodyFont
local buttonFont

function love.load()
    titleFont = love.graphics.newFont(32)
    scoreFont = love.graphics.newFont(24)
    bodyFont = love.graphics.newFont(18)
    buttonFont = love.graphics.newFont(20)

    local iconData = love.image.newImageData("melonport_invis.png")
    love.window.setIcon(iconData)
end

-- Helper function: checks if a point (x, y) is inside a rectangle
local function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function killMelons(amount)
    points = points + amount
    killsSinceSample = killsSinceSample + amount
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse click
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
    end
end

function love.update(dt)
    frogTimer = frogTimer + dt
    while frogTimer >= 1 do
        frogTimer = frogTimer - 1
        if frogCount > 0 then
            killMelons(frogCount)
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
    love.graphics.setFont(titleFont)
    love.graphics.print("Game where you kill melons", 200, 40)

    love.graphics.setFont(scoreFont)
    love.graphics.print("Dead Melonports: " .. points, 200, 100)

    love.graphics.setFont(bodyFont)
    love.graphics.print("Per Kill: " .. pointsPerClick, 200, 140)
    love.graphics.print(string.format("K/S: %.1f", killsPerSecond), 200, 170)

    love.graphics.setColor(0.2, 0.6, 1) -- Blue background
    love.graphics.rectangle("fill", clickBtn.x, clickBtn.y, clickBtn.w, clickBtn.h, 20)

    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.setFont(buttonFont)
    love.graphics.printf(clickBtn.text, clickBtn.x, clickBtn.y + 18, clickBtn.w, "center")

    -- 3. Draw "Upgrade" Button
    if points >= upgradeCost then
        love.graphics.setColor(0.2, 0.8, 0.2)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("fill", upgradeBtn.x, upgradeBtn.y, upgradeBtn.w, upgradeBtn.h, 20)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Kidnap a melon (" .. upgradeCost .. " kills)", upgradeBtn.x, upgradeBtn.y + 18, upgradeBtn.w, "center")

    if points >= frogCost then
        love.graphics.setColor(0.2, 0.8, 0.2)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("fill", hirefrogsBtn.x, hirefrogsBtn.y, hirefrogsBtn.w, hirefrogsBtn.h, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Hire Frog (" .. frogCost .. " kills)", hirefrogsBtn.x, hirefrogsBtn.y + 18, hirefrogsBtn.w, "center")

    love.graphics.setFont(bodyFont)
    love.graphics.print("Frogs: " .. frogCount, 200, 460)
end