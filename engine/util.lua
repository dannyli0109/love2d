local util = {}

function util.generate_uuid(length)
    length = length or 36 -- Default length is 36 characters

    -- UUID template (hexadecimal digits)
    local template = 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'

    -- Generate UUID string based on the specified length
    local uuid = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)

    -- Adjust the length of the UUID by truncating or padding with '0'
    if length > #uuid then
        uuid = uuid .. string.rep('0', length - #uuid)
    elseif length < #uuid then
        uuid = string.sub(uuid, 1, length)
    end

    return uuid
end

return util;
