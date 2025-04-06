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

function HEX(hex)
    if #hex <= 6 then hex = hex.."FF" end
    local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
    return color
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

function removeCardDebuff(_card)
    _card["debuff"] = false
end

function fixDeck(_saveData)
    prints("Fixing Deck")
    for _, card in pairs(_saveData["cardAreas"]["deck"]["cards"]) do

        -- modifyDeckCard(card, "Spades", "King")
        -- changeEdition(card, "polychrome")
        -- changeEnhancement(card, "lucky")
        -- addSeal(card, "Red")
        removeCardDebuff(card)
    end
    for _, card in pairs(_saveData["cardAreas"]["hand"]["cards"]) do

        -- modifyDeckCard(card, "Spades", "King")
        -- changeEdition(card, "polychrome")
        -- changeEnhancement(card, "lucky")
        -- addSeal(card, "Red")
        removeCardDebuff(card)
    end
end

function removeSeededFlag(_saveData)
    _saveData['GAME']['seeded'] = nil
end

function modifyDollars(_saveData, ammount)
    _saveData.GAME.dollars = ammount
end

function changeBossBlind(_saveData, boss)

    local most_played = _saveData.GAME.current_round.most_played_poker_hand
   
    local BLINDS = {
        bl_small =           {name = 'Small Blind',  defeated = false, order = 1, dollars = 3, mult = 1,  vars = {}, debuff_text = '', debuff = {}, pos = {x=0, y=0}},
        bl_big =             {name = 'Big Blind',    defeated = false, order = 2, dollars = 4, mult = 1.5,vars = {}, debuff_text = '', debuff = {}, pos = {x=0, y=1}},
        -- bl_ox =              {name = 'The Ox',       defeated = false, order = 4, dollars = 5, mult = 2,  vars = {localize('ph_most_played')}, debuff = {}, pos = {x=0, y=2}, boss = {min = 6, max = 10}, boss_colour = HEX('b95b08')},
        bl_hook =            {name = 'The Hook',     defeated = false, order = 3, dollars = 5, mult = 2,  vars = {}, debuff = {}, pos = {x=0, y=7}, boss = {min = 1, max = 10}, boss_colour = HEX('a84024')},
        bl_mouth =           {name = 'The Mouth',    defeated = false, order = 17, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=18}, boss = {min = 2, max = 10}, boss_colour = HEX('ae718e')},
        bl_fish =            {name = 'The Fish',     defeated = false, order = 10, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=5}, boss = {min = 2, max = 10}, boss_colour = HEX('3e85bd')},
        bl_club =            {name = 'The Club',     defeated = false, order = 9, dollars = 5, mult = 2,  vars = {}, debuff = {suit = 'Clubs'}, pos = {x=0, y=4}, boss = {min = 1, max = 10}, boss_colour = HEX('b9cb92')},
        bl_manacle =         {name = 'The Manacle',  defeated = false, order = 15, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=8}, boss = {min = 1, max = 10}, boss_colour = HEX('575757')},
        bl_tooth =           {name = 'The Tooth',    defeated = false, order = 23, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=22}, boss = {min = 3, max = 10}, boss_colour = HEX('b52d2d')},
        bl_wall =            {name = 'The Wall',     defeated = false, order = 6, dollars = 5, mult = 4,  vars = {}, debuff = {}, pos = {x=0, y=9}, boss = {min = 2, max = 10}, boss_colour = HEX('8a59a5')},
        bl_house =           {name = 'The House',    defeated = false, order = 5, dollars = 5, mult = 2,  vars = {}, debuff = {}, pos = {x=0, y=3}, boss ={min = 2, max = 10}, boss_colour = HEX('5186a8')},
        bl_mark =            {name = 'The Mark',     defeated = false, order = 25, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=23}, boss = {min = 2, max = 10}, boss_colour = HEX('6a3847')},

        bl_final_bell =      {name = 'Cerulean Bell',defeated = false, order = 30, dollars = 8, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=26}, boss = {showdown = true, min = 10, max = 10}, boss_colour = HEX('009cfd')},
        bl_wheel =           {name = 'The Wheel',    defeated = false, order = 7, dollars = 5, mult = 2,  vars = {}, debuff = {}, pos = {x=0, y=10}, boss = {min = 2, max = 10}, boss_colour = HEX('50bf7c')},
        bl_arm =             {name = 'The Arm',      defeated = false, order = 8, dollars = 5, mult = 2,  vars = {}, debuff = {}, pos = {x=0, y=11}, boss = {min = 2, max = 10}, boss_colour = HEX('6865f3')},
        bl_psychic =         {name = 'The Psychic',  defeated = false, order = 11, dollars = 5, mult = 2, vars = {}, debuff = {h_size_ge = 5}, pos = {x=0, y=12}, boss = {min = 1, max = 10}, boss_colour = HEX('efc03c')},
        bl_goad =            {name = 'The Goad',     defeated = false, order = 12, dollars = 5, mult = 2, vars = {}, debuff = {suit = 'Spades'}, pos = {x=0, y=13}, boss = {min = 1, max = 10}, boss_colour = HEX('b95c96')},
        bl_water =           {name = 'The Water',    defeated = false, order = 13, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=14}, boss = {min = 2, max = 10}, boss_colour = HEX('c6e0eb')},
        bl_eye =             {name = 'The Eye',      defeated = false, order = 16, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=17}, boss = {min = 3, max = 10}, boss_colour = HEX('4b71e4')},
        bl_plant =           {name = 'The Plant',    defeated = false, order = 18, dollars = 5, mult = 2, vars = {}, debuff = {is_face = 'face'}, pos = {x=0, y=19}, boss = {min = 4, max = 10}, boss_colour = HEX('709284')},
        bl_needle =          {name = 'The Needle',   defeated = false, order = 21, dollars = 5, mult = 1, vars = {}, debuff = {}, pos = {x=0, y=20}, boss = {min = 2, max = 10}, boss_colour = HEX('5c6e31')},
        bl_head =            {name = 'The Head',     defeated = false, order = 22, dollars = 5, mult = 2, vars = {}, debuff = {suit = 'Hearts'}, pos = {x=0, y=21}, boss = {min = 1, max = 10}, boss_colour = HEX('ac9db4')},
        bl_final_leaf =      {name = 'Verdant Leaf', defeated = false, order = 27, dollars = 8, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=28}, boss = {showdown = true, min = 10, max = 10}, boss_colour = HEX('56a786')},
        bl_final_vessel =    {name = 'Violet Vessel',defeated = false, order = 28, dollars = 8, mult = 6, vars = {}, debuff = {}, pos = {x=0, y=29}, boss = {showdown = true, min = 10, max = 10}, boss_colour = HEX('8a71e1')},
        bl_window =          {name = 'The Window',   defeated = false, order = 14, dollars = 5, mult = 2, vars = {}, debuff = {suit = 'Diamonds'}, pos = {x=0, y=6}, boss = {min = 1, max = 10}, boss_colour = HEX('a9a295')},
        bl_serpent =         {name = 'The Serpent',  defeated = false, order = 19, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=15}, boss = {min = 5, max = 10}, boss_colour = HEX('439a4f')},
        bl_pillar =          {name = 'The Pillar',   defeated = false, order = 20, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=16}, boss = {min = 1, max = 10}, boss_colour = HEX('7e6752')},
        bl_flint =           {name = 'The Flint',    defeated = false, order = 24, dollars = 5, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=24}, boss = {min = 2, max = 10}, boss_colour = HEX('e56a2f')},
        bl_final_acorn =     {name = 'Amber Acorn',  defeated = false, order = 26, dollars = 8, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=27}, boss = {showdown = true, min = 10, max = 10}, boss_colour = HEX('fda200')},
        bl_final_heart =     {name = 'Crimson Heart',defeated = false, order = 29, dollars = 8, mult = 2, vars = {}, debuff = {}, pos = {x=0, y=25}, boss = {showdown = true, min = 10, max = 10}, boss_colour = HEX('ac3232')},
        
    }

    _saveData.BLIND.config_blind = boss
    _saveData.BLIND.name = BLINDS[boss].name
    _saveData.BLIND.debuff = BLINDS[boss].debuff
    _saveData.BLIND.mult = BLINDS[boss].mult
    _saveData.BLIND.pos = BLINDS[boss].pos
    _saveData.BLIND.dollars = BLINDS[boss].dollars
    _saveData.GAME.round_resets.blind = BLINDS[boss]
end

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
    
    fixDeck(saveData)
    -- listJokers()
    -- removeSeededFlag(saveData)
    -- modifyDollars(saveData, 1000000)
    changeBossBlind(saveData, 'bl_serpent')
    printTable(saveData, 0)
    compress_and_save('save.mod.jkr', saveData)
end

love.event.quit()
