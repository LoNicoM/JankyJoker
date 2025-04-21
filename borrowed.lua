-- The following functions were "borrowed" from the original source code without modifications.

-- BEGIN Stolen functions --

function STR_UNPACK(str)
    return assert(load(str))()
end

function STR_PACK(data, recursive)
    local ret_str = (recursive and "" or "return ") .. "{"

    for i, v in pairs(data) do
        local type_i, type_v = type(i), type(v)
        assert((type_i ~= "table"), "Data table cannot have an table as a key reference")
        if type_i == "string" then
            i = '[' .. string.format("%q", i) .. ']'
        else
            i = "[" .. i .. "]"
        end
        if type_v == "table" then
            if v.is and v:is(Object) then
                v = [["]] .. "MANUAL_REPLACE" .. [["]]
            else
                v = STR_PACK(v, true)
            end
        else
            if type_v == "string" then
                v = string.format("%q", v)
            end
            if type_v == "boolean" then
                v = v and "true" or "false"
            end
        end
        ret_str = ret_str .. i .. "=" .. v .. ","
    end

    return ret_str .. "}"
end

function get_compressed(_file)
    local file_data = love.filesystem.getInfo(_file)
    if file_data ~= nil then
        local file_string = love.filesystem.read(_file)
        if file_string ~= '' then
            if string.sub(file_string, 1, 6) ~= 'return' then
                local success = nil
                success, file_string = pcall(love.data.decompress, 'string', 'deflate', file_string)
                if not success then
                    return nil
                end
            end
            return file_string
        end
    end
end

function compress_and_save(_file, _data)
    local save_string = type(_data) == 'table' and STR_PACK(_data) or _data
    save_string = love.data.compress('string', 'deflate', save_string, 1)
    love.filesystem.write(_file, save_string)
end

function HEX(hex)
    if #hex <= 6 then
        hex = hex .. "FF"
    end
    local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255}
    return color
end

function copy_table(O)
    local O_type = type(O)
    local copy
    if O_type == 'table' then
        copy = {}
        for k, v in next, O, nil do
            copy[copy_table(k)] = copy_table(v)
        end
        setmetatable(copy, copy_table(getmetatable(O)))
    else
        copy = O
    end
    return copy
end

-- END Stolen functions --