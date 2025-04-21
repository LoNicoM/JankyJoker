-- Direct read file function, not currently used.
local function read_file(path)
    local open = io.open
    local file = open(path, "rb")
    if not file then
        return nil
    end
    local content = file:read "*a"
    file:close()
    return content
end

-- Produces a somewhat valid and indented lua table as console output. Mainly for research.

local prints = io.write

function printTable(tableData, indentLevel)
    if indentLevel == 0 then
        prints("{\n")
    end
    for k, v in pairs(tableData) do
        prints(string.rep("    ", indentLevel) .. '["' .. k .. '"]')
        if type(v) == 'table' then
            prints(" = {\n")
            printTable(v, indentLevel + 1)
            prints(string.rep("    ", indentLevel) .. "},\n")
        elseif type(v) == 'string' then
            prints(' = "' .. v .. '",\n')
        elseif type(v) == 'number' then
            prints(" = " .. v .. ",\n")
        elseif type(v) == 'boolean' then
            prints(" = " .. tostring(v) .. ",\n")
            -- Edge case, Not implemented
        else
            prints(type(v) .. "\n")
        end
    end
    if indentLevel == 0 then
        prints("}")
    end
end
