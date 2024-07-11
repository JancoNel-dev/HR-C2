local base64 = {}

local base64_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local base64_reverse_chars = {}

-- Generating reverse lookup table
for i = 1, #base64_chars do
    local char = base64_chars:sub(i, i)
    base64_reverse_chars[char] = i - 1
end

-- Function to encode a string to Base64
function base64.encode(data)
    local result = {}
    local len = #data
    local i = 1

    while i <= len do
        local char1, char2, char3 = data:byte(i, i + 2)
        local chunk = (char1 or 0) << 16 | (char2 or 0) << 8 | (char3 or 0)

        for j = 1, 4 do
            local index = (chunk >> (18 - j * 6)) & 0x3F + 1
            table.insert(result, base64_chars:sub(index, index))
        end

        i = i + 3
    end

    -- Add padding if necessary
    local padding = len % 3
    if padding > 0 then
        result[#result - padding + 1] = '='
        if padding == 1 then
            result[#result] = '='
        end
    end

    return table.concat(result)
end

-- Function to decode a Base64 string
function base64.decode(data)
    local result = {}
    local len = #data
    local i = 1

    while i <= len do
        local char1, char2, char3, char4 = data:byte(i, i + 3)
        local chunk = (base64_reverse_chars[char1] or 0) << 18 | (base64_reverse_chars[char2] or 0) << 12 |
                      (base64_reverse_chars[char3] or 0) << 6 | (base64_reverse_chars[char4] or 0)

        for j = 1, 3 do
            if char2 ~= '=' then
                local byte = (chunk >> (8 - j * 8)) & 0xFF
                table.insert(result, string.char(byte))
            end
        end

        i = i + 4
    end

    return table.concat(result)
end

-- Test the functions
local original_data = "Hello, world!"
local encoded_data = base64.encode(original_data)
print("Encoded:", encoded_data)
local decoded_data = base64.decode(encoded_data)
print("Decoded:", decoded_data)

return base64
