----------------------------------------
--- Below this point is nothing good ---

require "borrowed"
require "constants"
require "file"
require "cardGame"

local fileContent = get_compressed("save.jkr")
if fileContent == nil then
    prints("Couldn't load save file")
    love.event.quit()
end

local saveData = STR_UNPACK(fileContent);
if saveData == nil then
    prints("Couldn't load save file")
    love.event.quit()
end

function love.load(arg)


    loopCardAreas(saveData, "jokers")
    -- listCardAreas(saveData, "jokers")
    -- removeSeededFlag(saveData)
    -- modifyDollars(saveData, 1000000)
    -- changeBossBlind(saveData, 'bl_serpent')
    alterJoker(saveData.cardAreas.jokers.cards[5], 'j_blueprint')
    alterJoker(saveData.cardAreas.jokers.cards[6], 'j_hanging_chad')
    changeEdition(saveData.cardAreas.jokers.cards[6], 'polychrome')

    printTable(saveData, 0)

    compress_and_save('save.mod.jkr', saveData)
end

love.event.quit()
