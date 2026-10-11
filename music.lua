local music = {}

local tracks = {}
local currentTrack = nil
local previousTrackIndex = nil
local pauseRemaining = 0
local fadeInElapsed = 0
local pauseDuration = 10
local fadeDuration = 2

local function playNextTrack()
    local trackIndex = love.math.random(#tracks)
    while #tracks > 1 and trackIndex == previousTrackIndex do
        trackIndex = love.math.random(#tracks)
    end

    previousTrackIndex = trackIndex
    currentTrack = tracks[trackIndex]
    currentTrack:setVolume(0)
    currentTrack:play()
    fadeInElapsed = 0
end

function music.load()
    love.math.setRandomSeed(os.time())
    local supportedExtensions = { wav = true, ogg = true, mp3 = true, flac = true }
    for _, filename in ipairs(love.filesystem.getDirectoryItems("music")) do
        local extension = filename:match("%.([^%.]+)$")
        if extension and supportedExtensions[extension:lower()] then
            table.insert(tracks, love.audio.newSource("music/" .. filename, "stream"))
        end
    end
    if #tracks == 0 then
        error("No supported audio tracks found in the music folder")
    end
    playNextTrack()
end

function music.update(dt)
    if not currentTrack then
        pauseRemaining = pauseRemaining - dt
        if pauseRemaining <= 0 then
            playNextTrack()
        end
        return
    end

    if not currentTrack:isPlaying() then
        currentTrack:stop()
        currentTrack = nil
        pauseRemaining = pauseDuration
        return
    end

    fadeInElapsed = fadeInElapsed + dt
    local fadeInVolume = math.min(1, fadeInElapsed / fadeDuration)
    local remaining = currentTrack:getDuration("seconds") - currentTrack:tell("seconds")
    local fadeOutVolume = math.min(1, math.max(0, remaining / fadeDuration))
    currentTrack:setVolume(math.min(fadeInVolume, fadeOutVolume))
end

return music
