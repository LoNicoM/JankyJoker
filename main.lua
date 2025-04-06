local open = io.open
local prints = io.write

-- Direct read file function, not currently used.
local function read_file(path)
    local file = open(path, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

-- The following functions were "borrowed" from the original source code without modifications.

-- BEGIN Stolen functions --

function STR_UNPACK(str)
    return assert(load(str))()
end

function STR_PACK(data, recursive)
	local ret_str = (recursive and "" or "return ").."{"
	
      for i, v in pairs(data) do
		local type_i, type_v = type(i), type(v)
        assert((type_i ~= "table"), "Data table cannot have an table as a key reference")
        if type_i == "string" then
			i = '['..string.format("%q",i)..']'
        else
          	i = "["..i.."]"
        end
        if type_v == "table" then
			if v.is and v:is(Object) then
				v = [["]].."MANUAL_REPLACE"..[["]]
			else
				v = STR_PACK(v, true)
			end
        else
          if type_v == "string" then v = string.format("%q", v) end
		  if type_v == "boolean" then v = v and "true" or "false" end
        end
		ret_str = ret_str..i.."="..v..","
      end

	  return ret_str.."}"
end

function get_compressed(_file)
    local file_data = love.filesystem.getInfo(_file)
    if file_data ~= nil then
        local file_string = love.filesystem.read(_file)
        if file_string ~= '' then
            if string.sub(file_string, 1, 6) ~= 'return' then 
                local success = nil
                success, file_string = pcall(love.data.decompress, 'string', 'deflate', file_string)
                if not success then return nil end
            end
            return file_string
        end
    end
end

function compress_and_save(_file, _data)
    local save_string = type(_data) == 'table' and STR_PACK(_data) or _data
    save_string = love.data.compress('string', 'deflate', save_string, 1)
    love.filesystem.write(_file,save_string)
end

-- END Stolen functions --

-- Produces a somewhat valid and indented lua table as console output. Mainly for research.
function printTable(tableData, indentLevel)
    if indentLevel == 0 then
        prints("{\n")
    end
    for k, v in pairs(tableData) do
        prints(string.rep("    ",indentLevel)..'["'..k..'"]')
        if type(v) == 'table' then
            prints(" = {\n")
            printTable(v, indentLevel + 1)
            prints(string.rep("    ",indentLevel).."},\n")
        elseif type(v) == 'string' then
            prints(' = "'..v..'",\n')
        elseif type(v) == 'number' then
            prints(" = "..v..",\n")
        elseif type(v) == 'boolean' then
            prints(" = "..tostring(v)..",\n")
        -- Edge case, Not implemented
        else
            prints(type(v).."\n")
        end
    end
    if indentLevel == 0 then
        prints("}")
    end
end


function listJokers()
    printTable(unpacked["cardAreas"]["jokers"]["cards"], 0)
end

function changeEnhancement(_card, enhancement)
    if enhancement == "lucky" then
        _card["ability"]["set"] = "Enhanced"
        _card["ability"]["name"] = "Lucky Card"
        _card["ability"]["mult"] = 20
        _card["ability"]["effect"] = "Lucky Card"
        _card["ability"]["p_dollars"] = 20
        _card["save_fields"]["center"] = "m_lucky"
    end
end

function addSeal(_card, seal)
    _card["seal"] = seal
end

function changeEdition(_card, edition)
    if edition == "polychrome" then
        _card["edition"] = {
            ["mult"] = 1.5,
            ["polychrome"] = true,
            ["type"] = "polychrome",
        }
    elseif edition == "foil" then
        _card["edition"] = {
            ["type"] = "foil",
            ["foil"] = true,
            ["chips"] = 50,
        }
    elseif edition == 'base' then
        _card["edition"] = nil
    else
        prints("Not Implemented")
    end
end

function modifyDeckCard(_card, suit, value)

    local cardTable = {
        Ace = { id = 14, val = 11 },
        King = { id= 13, val = 10 },
        Queen = { id= 12, val = 10 },
        Jack = { id= 11, val = 10 },
    }

    _card["base"]["value"] = value
    _card["base"]["suit"] = suit
    _card["base"]["nominal"] = cardTable[value].val or tonumber(value)
    _card["base"]["original_value"] = cardTable[value].val or tonumber(value)
    _card["base"]["id"] = cardTable[value].id or tonumber(value)
    _card["base"]["name"] = value.." of "..suit
    _card["save_fields"]["card"] = string.sub(suit, 1, 1).."_"..string.gsub(string.sub(value, 1, 1), "1", "T")
end

function fixDeck(_saveData)
    prints("Fixing Deck")
    for _, card in pairs(_saveData["cardAreas"]["deck"]["cards"]) do

        modifyDeckCard(card, "Spades", "King")
        changeEdition(card, "polychrome")
        changeEnhancement(card, "lucky")
        addSeal(card, "Red")
    end
end

function removeSeededFlag(_saveData)
    _saveData['GAME']['seeded'] = nil
end

function modifyDollars(_saveData, ammount)
    _saveData.GAME.dollars = ammount
end

function changeBossBlind(_saveData, boss)
    _saveData.GAME.last_blind = "The Head"
end

local fileContent = get_compressed("save2.jkr")
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
    
    -- if arg[1] == "--fix" then

    --     fixDeck(saveData)
    -- end
    
    -- listJokers()
    -- removeSeededFlag(saveData)
    -- modifyDollars(saveData, 1000000)
    printTable(saveData, 0)
    compress_and_save('save.mod.jkr', saveData)
end

love.event.quit()
