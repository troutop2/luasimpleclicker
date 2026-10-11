require("code")

local music = require("music")
local gameLoad = love.load
local gameUpdate = love.update

function love.load(...)
    gameLoad(...)
    music.load()
end

function love.update(dt)
    music.update(dt)
    gameUpdate(dt)
end
