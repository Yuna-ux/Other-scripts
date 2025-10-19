math.randomseed(os.time())

local chars = {}
for i = 65,90 do chars[#chars+1] = string.char(i) end
for i = 97,122 do chars[#chars+1] = string.char(i) end
for i = 48,57 do chars[#chars+1] = string.char(i) end

local nameCounter = 0

local function RandomVarName(length)
    length = math.floor(tonumber(length) or 8)
    nameCounter = nameCounter + 1
    
    local suffix = "_" .. tostring(nameCounter)
    local baseLength = length - #suffix
    
    if baseLength < 1 then
        baseLength = 1
    end
    
    local t = {}
    for i = 1, baseLength do
        t[#t+1] = chars[math.random(1, #chars)]
    end
   
    if t[1] and t[1]:match("%d") then
        t[1] = chars[math.random(1, 52)]
    end
    
    return table.concat(t) .. suffix
end


local nameCounterIlIlII = 0

local function generateSizeBasedSeed(size)
    local baseSeed = size * 12345 + 67890
    local seed = baseSeed + (nameCounterIlIlII * 111)
   return math.abs(seed) % 2147483647
end

local function randomVarIlIlII(size, useMixedPattern)
    size = math.floor(tonumber(size) or 10)
    nameCounterIlIlII = nameCounterIlIlII + 1
    
   local customSeed = generateSizeBasedSeed(size)
    local originalMathRandom = math.random
    math.randomseed(customSeed)
    
    if useMixedPattern == nil then
        useMixedPattern = false
    end
    local suffix = "_" .. tostring(nameCounterIlIlII)
    local baseLength = math.max(4, size - #suffix)
    
    local standards = {
        function(len)
            local chars = {"I", "l"}
            local t = {}
            for i = 1, len do
                t[i] = chars[math.random(1, #chars)]
            end
            return table.concat(t)
        end,
        
        function(len)
            local chars = {"I", "l", "1", "O", "0"}
            local t = {}
            for i = 1, len do
                t[i] = chars[math.random(1, #chars)]
            end
            return table.concat(t)
        end,
        
        function(len)
            local groups = {"Il", "II", "ll", "lI", "I1", "1I", "O0", "0O", "10", "01"}
            local t = {}
            local pos = 1
            while pos <= len do
                local group = groups[math.random(1, #groups)]
                local rest = len - pos + 1
                if #group <= rest then
                    for j = 1, #group do
                        t[pos] = group:sub(j, j)
                        pos = pos + 1
                    end
                else
                    t[pos] = "I"
                    pos = pos + 1
                end
            end
            return table.concat(t)
        end
    }
    
    local chosenPattern = useMixedPattern and math.random(1, #standards) or 1
    local baseName = standards[chosenPattern](baseLength)
    
    if baseName:sub(1, 1):match("%d") then
        baseName = "I" .. baseName:sub(2)
    end
    
    math.random = originalMathRandom
    
    return baseName .. suffix
end

local base64_lib = {}

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function base64_lib.enc(data)
    return (
        (data:gsub('.', function(x) 
            local r, b='', x:byte()
            for i=8, 1, -1 do
                r = r .. (b % 2^i - b % 2^(i - 1) > 0 and '1' or '0')
            end
            return r;
        end) .. '0000')
        :gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c=0
            for i=1,6 do
                c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0)
            end
            return b:sub(c+1,c+1)
        end)..(
        {'', '==', '='})[#data % 3 + 1])
end

-- decoding
function base64_lib.dec(data)
    data = string.gsub(data, '[^' .. b ..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then
            return ''
        end
        local r, f= '', (b:find(x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then
            return ''
        end
        local c=0
        for i=1,8 do
            c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
        end
        return string.char(c)
    end))
end

local gmatch, sub, gsub, format, char, byte = string.gmatch, string.sub, string.gsub, string.format, string.char, string.byte
local uchar, ucode, upattern = utf8.char, utf8.codepoint, utf8.charpattern

local tostring, tonumber = tostring, tonumber
local tinsert = table.insert

local floor, clamp, random = math.floor, nil, math.random
local bit32_bxor = (bit32 and bit32.bxor) or function(a, b)
    a = a % 256  -- Force to 0-255
    b = b % 256  -- Force to 0-255
    local res = 0
    local bitval = 1
    while a > 0 or b > 0 do
        local abit = a % 2
        local bbit = b % 2
        if abit ~= bbit then
            res = res + bitval
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bitval = bitval * 2
        --if bitval > 256 then break end
    end
    return res % 256
end
    

local function clamp(value, min, max)
    return value < min and min or value > max and max or value
end

local LuaEscapeCodes = {
    ["b"] = "\b",
    ["n"] = "\n",
    ["r"] = "\r",
    ["t"] = "\t",
    ["f"] = "\f",
    ["v"] = "\v",
    ["\""] = "\"",
    ["'"] = "\'",
    ["\\"] = "\\",
}

local Quotes = {
    ['"'] = "'",
    ["'"] = "\""
}

-- Hexadecimal (with \x)
local function encoderHex(s)
    return (s:gsub(".", function(c)
        return string.format("\\x%02X", c:byte())
    end))
end
-- Hexadecimal (with three digits)
local function stringToHexadecimal(str)
    local parts = {}
    for i = 1, #str do
        local char = str:sub(i, i)
        local ascii = string.byte(char)
       
        local asciiStr = string.format("%03d", ascii)
        table.insert(parts, "\\" .. asciiStr)
    end
    return table.concat(parts)
end

local function ParseStrings(File, ByteLength)
    local function ParseString(String) -- Formats the \u{...}, \f, \b, ...
        String = gsub(String, "\\(.)", function(Character)
            return LuaEscapeCodes[Character]
        end)
        String = gsub(String, "\\u{([0-9A-Fa-f]+)}", function(Hex)
            return uchar(tonumber(Hex, 16))
        end)

        return String
    end

    local Crypt = {
        Encoded = {}, -- Dictionary
        Used = {}, -- Array
        CharLen = ByteLength or random(4, 7), -- Byte length
        stringCharName = RandomVarName(5)
    };

    function Crypt:GenerateKey(len)
        len = len or 64

        local key = "";
        local hex = {"a", "b", "c", "d", "e", "f", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}

        for _ = 1, len do
            key = key .. hex[random(1, #hex)]
        end

        return key
    end

    function Crypt:Encode(String, Quote)
        local Encoded = ""

        String = gsub(String, Quote, "\\" .. Quote)
        String = ParseString(String)

        for Char in gmatch(String, upattern) do
            local Generated = Crypt:GenerateKey(Crypt.CharLen) .. Crypt:GenerateKey(Crypt.CharLen)

            Crypt.Encoded[Char] = Crypt.Encoded[Char] or Generated

            Encoded = Encoded .. (Crypt.Encoded[Char])
        end

        return Encoded
    end
    
    function Crypt:GetList()
        local List = Crypt.Encoded;
        local String = "{\n"

        for Char, Value in next, List do
            Value = gsub(Value, "'", "\\'")

            String = String .. format("['%s']=%s(0x%02x);", Value, Crypt.stringCharName, ucode(Char))
        end

        return String .. "\t}"
    end
    
    local randomVarName = RandomVarName(9)
    local randomVarName2= RandomVarName(5)
    
    Crypt.FunctionCode = format([[
local function %%s(%s)local %s=utf8.char or string.char;local %s=%s:gsub("%%s",%%s);return %s;end;
]], randomVarName2, Crypt.stringCharName, randomVarName, randomVarName2, randomVarName)

    Crypt.FunctionName = "_" .. Crypt:GenerateKey(8);

    --& Important Variables

    local Pattern = "%s([^%s]*)%s" -- %s is quote

    for N, Quote in next, Quotes do
        --local QuotePattern = format(Pattern, Opposing, Quote, Quote, Opposing, Quote)
        local QuotePattern = format(Pattern, Quote, Quote, Quote)
        local NQuotePattern = format(Pattern, N, N, N)

        local function Inner(String)
            if String == "" then
                return
            end

            String = gsub(String, NQuotePattern, function(String2)
                return N .. String2 .. N
            end)

            return format("%s([[%s]])", Crypt.FunctionName, Crypt:Encode(String, Quote))
        end

        File = gsub(File, QuotePattern, Inner)
    end

    return format(Crypt.FunctionCode, Crypt.FunctionName, string.rep(".", Crypt.CharLen * 2), Crypt:GetList()) .. File
end

local BytecodeEncoder = {}

local function encodeBytecode(bytecode, offset)
    local encoded = {}
    for i = 1, #bytecode do
        local byte = bytecode:byte(i)
        local shifted_byte = (byte + offset) % 256
        table.insert(encoded, string.format("%02X", shifted_byte))
    end
    return table.concat(encoded)
end

function BytecodeEncoder.process(code)
    local bytecode = string.dump(assert(load(code)))
    local offset = math.random(1, 255)
    local encoded_bytecode = encodeBytecode(bytecode, offset)
    
    local varName1 = RandomVarName(2)  -- main var
    local varName2 = RandomVarName(2)  -- loop var
    local varName3 = RandomVarName(2)  -- 'b' var
    local varName4 = RandomVarName(2)  -- 'o' (offset)
    local varName5 = RandomVarName(2)  -- 'd' (data table)
    local varName6 = RandomVarName(2)  -- 'f' (function)
    local varName7 = RandomVarName(2)

    local alpha = [[
local %s=function()local %s,%s,%s="%s",%d,{}for %s=1,#%s,2 do local %s=tonumber(%s:sub(%s,%s+1),16)%s=(%s-%s+256)%%256 %s[#%s+1]=string.char(%s)end local %s=assert((load or loadstring)(table.concat(%s)))return %s()end local s,r=pcall(%s)if not s then print(r) end
]]
    
    return string.format(alpha, varName7, 
        varName1, varName4, varName5, encoded_bytecode, offset,  -- 1
        varName2, varName1,                                      -- 2  
        varName3, varName1, varName2, varName2,                  -- 3
        varName3, varName3, varName4,                            -- 4
        varName5, varName5, varName3,                            -- 5
        varName6, varName5,                                      -- 6
        varName6, varName7                                                 -- 7
    )
end

local function minifyLua(code)
    code = code:gsub("%-%-%[%[.-%]%]", ""):gsub("%-%-.-\n", "")
    code = code:gsub("[%c\t]+", " "):gsub("%s+", " ")
    code = code:gsub("^%s+", ""):gsub("%s+$", "")
    return code
end

local function dex(n)
    n = tonumber(n)
    if n == 0 then return '0' end
    local neg = false
    if n < 0 then
        neg = true
        n = n * -1
    end
    local hexstr = '0123456789ABCDEF'
    local result = ''
    local int_n = math.floor(n)
    while int_n > 0 do
        local mod = int_n % 16
        result = string.sub(hexstr, mod + 1, mod + 1) .. result
        int_n = math.floor(int_n / 16)
    end
    if result == '' then result = '0' end
    if neg then
        return '-0x' .. result
    end
    return '0x' .. result
end

local function obfuscateNumber(num)
    local addend_count = math.random(3, 6)
    local addend_sum = 0
    local addends = {}
    
    repeat
        addend_sum = 0
        local list_1 = {}
        local list_sum = 0
        for i = 1, addend_count do
            local rand = math.random()
            list_1[i] = rand
            list_sum = list_sum + rand
        end
        for i = 1, addend_count do
            local addend = (list_1[i] / list_sum) * num
            addends[i] = addend
            addend_sum = addend_sum + addend
        end
    until math.abs(addend_sum - num) < 0.0000001
    
    local hex_addend_factors = {}
    
    for i = 1, addend_count do
        local main_factor = addends[i]
        local decimal_str = tostring(main_factor)
        local dot_pos = decimal_str:find("%.")
        local decimal_places = 0
        if dot_pos then
            decimal_places = #decimal_str - dot_pos
        end
        local ten_factor = 10 ^ decimal_places
        local scaled_factor = main_factor * ten_factor
        hex_addend_factors[i] = {dex(scaled_factor), dex(ten_factor)}
    end
    
    local res = ''
    for i = 1, addend_count do
        if i ~= addend_count then
            res = res .. hex_addend_factors[i][1] .. '/' .. hex_addend_factors[i][2] .. '+'
        else
            res = res .. hex_addend_factors[i][1] .. '/' .. hex_addend_factors[i][2]
        end
    end
    
    return '(' .. res .. ')'
end

local function makeBase64Dec()
    local varParam = randomVarIlIlII(6)
    local varParam2 = randomVarIlIlII(7)
    -- {}[1] = base64 decoding function
    local base64Text = [[
return{
function(]] .. varParam2 .. [[)local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/']] .. varParam2 .. [[=string.gsub(]] .. varParam2 .. [[, '[^'..b..'=]', '')return(]] .. varParam2 .. [[:gsub(']] .. stringToHexadecimal(".") .. [[',function(x)if(x == ']] .. stringToHexadecimal("=") .. [[')then return''end local r,f='',(b:find(x)-1)for i=math.floor(]] .. obfuscateNumber(6) .. [[+0.5),1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and'1'or'0')end return r end):gsub(']] .. stringToHexadecimal('%d%d%d?%d?%d?%d?%d?%d?') .. [[',function(x)if(#x~=8)then return''end local c=0 for i=1,8 do c=c+(x:sub(i,i)==tostring(math.floor(]] .. obfuscateNumber(1) .. [[+0.5))and math.floor(]] .. obfuscateNumber(2) .. [[+0.5)^(8-i)or 0)end return string.char(c)end))end
}
]]
    return base64Text
end

local function makeJunkBlock(useJunkBlock)
    local patterns = {
        -- 1
        function()
            return string.format(
                "do local %s=((%d*%d+%d-%d)^0)*0 or('Obf Hard {~~*~~}'..tostring(nil))end",
                RandomVarName(4), math.random(1,9), math.random(1,9), math.random(1,9), math.random(1,9)
            )
        end,
        -- 2
        function()
            local varName = RandomVarName(9)
            return string.format(
                "do local %s={x=%d,y=%d}if false then print(' 999 obfuscator -_- obfuscated dont try deobfuscate')end local _=(%s.x * 0) + (%s.y or 0) end",
                varName, math.random(1,99), math.random(1,99), varName, varName
            )
        end,
        -- 3
        function()
            local varName = RandomVarName(10)
            return string.format(
                "do local %s='%s'..('%s' or '')..tostring(%s)end",
                varName, string.char(math.random(65,90)), string.char(math.random(97,122)),
                math.random(0,1)==1 and "nil" or "false"
            )
        end,
        -- 4
        function()
            local varName = RandomVarName(12)
            return string.format(
                "do local %s={%d,%d,%d}%s[1]=tostring(false)if true then({})[1]='Obfuscator load'end end",
                varName, math.random(1,9), math.random(1,9), math.random(1,9), varName
            )
        end,
        -- 5
        function()
            local varName = RandomVarName(13)
            local varName2 = RandomVarName(11)
            return string.format(
                "do local %s=setmetatable({%d},{});local %s=%s[1]*0;end;",
                varName, math.random(1,9), varName2, varName
            )
        end,
        -- 6
        function()
            local varName = RandomVarName(6)
            return string.format(
                "do local %s=math.random(1,100)^0 if false then error(' Zzzzzzzzzz Obf secret function Zzzzzzzzzzzzzzzzzzzz')end end", varName
            )
        end,
        -- 7
        function()
            local varName = RandomVarName(5)
            local varName2 = RandomVarName(5)
            return string.format(
                "do local %s={a=%d,b=%d}local %s=%s.a*0+%s.b*0 end", 
                varName, math.random(1,50), math.random(1,50), varName2, varName, varName
            )
        end,
        -- 8
        function()
            local varName = RandomVarName(7)
            return string.format(
                "do local %s='%s'..tostring(%s or nil)end", 
                varName, string.char(math.random(65,90)), math.random(0,1)==1 and "false" or "nil"
            )
        end,
        -- 9
        function()
            local varName = RandomVarName(10)
            return string.format(
                "do local %s={}for i=1,%d do %s[i]=i*0 end end", varName, math.random(2,5), varName
            )
        end,
        -- 10
        function()
            local varName = RandomVarName(9)
            return string.format(
                "do local %s=setmetatable({},{});if false then %s[1]=1 end end", varName, varName
            )
        end,
        -- 11
        function()
            local varName = RandomVarName(8)
            return string.format(
                "do local %s=%d local _=%s^0 end", varName, math.random(10,99), varName
            )
        end,
        -- 12
        function()
            local varName = RandomVarName(6)
            return string.format(
                "do local %s='%s'local _='%s'..tostring(%s)end", varName, string.char(math.random(65,90)), string.char(math.random(97,122)), math.random(0,1)==1 and "false" or "nil"
            )
        end,
        -- 13
        function()
            local varName = RandomVarName(7)
            return string.format(
                "do local %s={%d,%d}local _=%s[1]*0+%s[2]*0 end", varName, math.random(1,10), math.random(1,10), varName, varName
            )
        end,
        function()
            local varName = RandomVarName(7)
            return string.format(
                "do local %s={%d,%d}local _=%s[1]*0+%s[2]*0 end", varName, math.random(1,10), math.random(1,10), varName, varName
            )
        end,
        -- 14
        function()
            local varName = RandomVarName(9)
            return string.format(
                "do local %s=('%s'..'%s')if false then print('Real obfuscator OX hard hard hard loader')end end", varName, string.char(math.random(65,90)), string.char(math.random(97,122))
            )
        end,
        -- 15
        function()
            local varName = RandomVarName(10)
            return string.format(
                "do local %s={}for i=1,%d do %s[i]=i*0 end if false then %s[1]=1 end end", varName, math.random(2,8), varName, varName
            )
        end,
        -- 16
        function()
            local varName = RandomVarName(12)
            return string.format(
                "do local %s=%d*0 local _=%s+0 end", varName, math.random(1,50), varName
            )
        end,
        -- 17
        function()
            local varName = RandomVarName(7)
            return string.format(
                "do local %s='%s' local _=%s..tostring(nil)end", varName, string.char(math.random(65,90)), varName
            )
        end,
        -- 18
        function()
            local varName = RandomVarName(8)
            return string.format(
                "do local %s=setmetatable({%d,%d},{})end", varName, math.random(1,9), math.random(1,9)
            )
        end,
        -- 19
        function()
            local varName = RandomVarName(9)
            return string.format(
                "do local %s=%d if false then %s=%d end end", varName, math.random(1,50), varName, math.random(1,50)
            )
        end,
        -- 20
        function()
            local varName = RandomVarName(10)
            return string.format(
                "do local %s={}for i=1,%d do %s[i]=i end end", varName, math.random(2,5), varName
            )
        end,
        -- 21
        function()
            local varName = RandomVarName(11)
            local fakeKey = RandomVarName(8)
            return string.format(
                "do local %s='fake_key_%d'if false then loadstring('print(\"God mode of deobfuscator activated 000000000000000*****  HahAHaha bro\")')()end local %s=('%s'):reverse()end",
                varName, math.random(1000,9999), fakeKey, stringToHexadecimal(varName)
            )
        end,
        
        -- 22
        function()
            local varName1 = RandomVarName(6)
            local varName2 = RandomVarName(7)
            return string.format(
                "do local %s='%s'local %s=0 for i=1,#%s do %s=%s+%s:byte(i) end if false then _G['decrypt']=function()return 'decrypter function loader'end end end",
                varName1, string.rep(string.char(math.random(65,90)), math.random(5,10)), 
                varName2, varName1, varName2, varName2, varName1
            )
        end,
        
        -- 23
        function()
            local varName = RandomVarName(9)
            return string.format(
                "do local %s=function()return false end if %s()then error('Debugger Detected')elseif false then while true do end end end",
                varName, varName
            )
        end,
        
        -- 24
        function()
            local varName = RandomVarName(12)
            local fakeData = {}
            for i=1, math.random(3,6) do
                fakeData[#fakeData+1] = string.format("0x%02X", math.random(0,255))
            end
            return string.format(
                "do local %s={%s}if false then for k,v in pairs(%s)do _G['key'..k]=v end end end",
                varName, table.concat(fakeData, ","), varName
            )
        end,
        
        -- 25
        function()
            local varName = RandomVarName(10)
            local fakeB64 = RandomVarName(5)
            return string.format(
                "do local %s=function(s)return s:reverse()end local %s='%s' if false then (load or loadstring)(%s(%s))()end end",
                varName, fakeB64, string.rep("A", math.random(10,20)), varName, fakeB64
            )
        end,
        -- 26
        function()
            local varName1 = RandomVarName(8)
            local varName2 = RandomVarName(7)
            return string.format(
                "do local %s=os.time()local %s=function()return 'integrity_check_failed'end if false and %s<0 then %s()end end",
                varName1, varName2, varName1, varName2
            )
        end,
        -- 27
        function()
            local deceptiveVars = {"decryptKey", "encodedData", "xorKey", "base64Table", "loaderFunc"}
            local varName = deceptiveVars[math.random(1, #deceptiveVars)] .. RandomVarName(3)
            return string.format(
                "do local %s=%d if false then %s='%s' end end",
                varName, math.random(1,100), varName, string.rep("X", math.random(5,15))
            )
        end,
        -- 28
        function()
            local varName = RandomVarName(9)
            return string.format(
                "do local %s=%d for i=1,%d do if false then break end end end",
                varName, math.random(2,10), math.random(3,8)
            )
        end,
        -- 29
        function()
            local varName = RandomVarName(10)
            return string.format(
                "do local %s=function()return'%s'end if false and %s()=='Roblox'then print('Wrong environment')end end",
                varName, math.random(0,1)==1 and "Windows" or "Linux", varName
            )
        end,
        
        -- 30
        function()
            local varName = RandomVarName(11)
            local hexArray = {}
            for i=1, math.random(4,8) do
                hexArray[#hexArray+1] = string.format("'%02X'", math.random(0,255))
            end
            return string.format(
                "do local %s={%s}if false then _G.encryptedData=%s end end",
                varName, table.concat(hexArray, ","), varName
            )
        end,
        -- 31
        function()
            local varName = RandomVarName(8)
            return string.format(
                "do local %s=function(s)local r=0 for i=1,#s do r=r+s:byte(i)end return r end if false then %s('test')end end",
                varName, varName
            )
        end,
        -- 32
        function()
            local varName1 = RandomVarName(6)
            local varName2 = RandomVarName(7)
            return string.format(
                "do local %s='%s'local %s=%s:gsub('.',function(c)return string.char(c:byte()+1)end)if false then (load or loadstring)(%s)()end end",
                varName1, string.rep("Z", math.random(5,12)), varName2, varName1, varName2
            )
        end,
        function()
            local fakeMessages = {
                "decryption_key_verification_failed",
                "integrity_check_passed", 
                "loading_secure_module",
                "initializing_protection_layer"
            }
            local msg = fakeMessages[math.random(1, #fakeMessages)]
    
            return string.format(
                "do if(\"uo\"):reverse()==\"ou\"..\"o\" then print(\"%s\")end end",
                stringToHexadecimal(msg)
            )
        end
    }
    if useJunkBlock == true then
        return patterns[math.random(1,#patterns)]()
    else
        return ""
    end
end

local function generateDeadCode()
    local deadPatterns = {
        -- Dead functions
        function()
            local funcName = RandomVarName(8)
            local param1 = RandomVarName(4)
            local param2 = RandomVarName(4)
            local tempVar = RandomVarName(5)
            local loopCount = math.random(5,15)

            return string.format([[
                local function %s(%s,%s)local %s=%s+%s if %s>100 then return"%s",math.random(1,100)else for i=1,%d do if i%%2==0 then %s=%s*2 end end return %s*0.5 end end
            ]], funcName, param1, param2, tempVar, param1, param2, tempVar, RandomVarName(6), loopCount, param1, param1, param1)
        end,
        
        -- Dead loops infinites
        function()
            local varName1 = RandomVarName(6)
            return string.format([[
                do local %s=os.time()*0 while %s<0 do %s=%s+1 if false then break end end end
            ]], varName1, varName1, varName1, varName1)
        end,
        
        -- Dead recursion fake
        function()
            local funcName = RandomVarName(7)
            return string.format([[
                local function %s(depth)if depth<=0 then return 0 end local %s=depth-1 if math.random(1,100)>200 then return %s(%s)else return depth*math.pi end end
            ]], funcName, RandomVarName(5), funcName, RandomVarName(5))
        end
    }
    
    return deadPatterns[math.random(1, #deadPatterns)]()
end

local function generateAntiTampering(varName)
    local varNames = {
        infoVar = RandomVarName(6)
    }
    local checks = {
        string.format([[
pcall(function()%s[1]("%s")()end)
]], varName, encoderHex([[
if debug and debug.gethook()~=nil then error("Debugger Detected")end
]])),
        string.format([[
do
    pcall(function()
        local %s = debug.getinfo(1, "S")
        if not %s.source or type(%s.source) ~= "string" then
            error("%s")
        end
        if not %s.source:find("@") and not %s.source:find("=") then
            error("%s")
        end
    end)
end
]],
varNames.infoVar,
varNames.infoVar, varNames.infoVar, stringToHexadecimal("Invalid structure"),
varNames.infoVar, varNames.infoVar, encoderHex("Markers missing"))
    }
    return table.concat(checks, " ")
end

local function bytes_to_hex(code, key)
    key = key or 15
    local bxor = bit32_bxor
    local mt = {
        __index = function(t, k)
            local byte_val = code:byte(k)
            local xored_byte = bxor(byte_val, key)
            return string.format("%02X", xored_byte)
        end
    }
    local t = setmetatable({}, mt)
    local result = {}
    for i = 1, #code do
        result[#result+1] = t[i]
    end
    return table.concat(result)
end

local function makeHexToBytes(funcName, key)
    local varName1 = RandomVarName(7)   -- hex
    local varName2 = RandomVarName(5)   -- bytes decode
    local varName3 = RandomVarName(4)   -- end result
    local varName4 = RandomVarName(2)   -- bitwise table
    local varName5 = RandomVarName(5)   -- XOR function
    local varName6 = RandomVarName(8)  -- res
    local varName7 = RandomVarName(3)   -- bitval
    local varName8 = RandomVarName(4)  -- abit
    local varName9 = RandomVarName(7)   -- bbit
    local varName10 = RandomVarName(9) -- a
    local varName11 = RandomVarName(2)  -- b
    local varName12 = RandomVarName(4) -- mt table
    local varName13 = RandomVarName(5)  -- t table
    local varName14 = RandomVarName(5) -- k parameter
    local varName15 = RandomVarName(7)  -- byte variable
    local varName16 = RandomVarName(8) -- i loop
    local varName17 = RandomVarName(2)
    key = key or 15
    
    local bitwise_code = [[
    local ]]..varName17..[[=(bit32 and bit32.bxor)or function(]] .. varName10 .. [[, ]] .. varName11 .. [[)]] .. varName10 .. [[=]] .. varName10 .. [[%256
        ]] .. varName11 .. [[=]] .. varName11 .. [[%256
        local ]] .. varName6 .. [[=0
        local ]] .. varName7 .. [[=1
        while ]] .. varName10 .. [[>0 or ]] .. varName11 .. [[>0 do
            local ]] .. varName8 .. [[ = ]] .. varName10 .. [[%2
            local ]] .. varName9 .. [[ = ]] .. varName11 .. [[%2
            if ]] .. varName8 .. [[ ~= ]] .. varName9 .. [[ then
                ]] .. varName6 .. [[ = ]] .. varName6 .. [[ + ]] .. varName7 .. [[
            end
            ]] .. varName10 .. [[=math.floor(]] .. varName10 .. [[/2)
            ]] .. varName11 .. [[=math.floor(]] .. varName11 .. [[/2)
            ]] .. varName7 .. [[ = ]] .. varName7 .. [[ * 2
            if ]] .. varName7 .. [[>256 then break end
        end
        return ]] .. varName6 .. [[%256
    end
    ]]
    
    local code = bitwise_code .. [[
    local function ]] .. funcName .. [[(]] .. varName1 .. [[)
        local ]] .. varName2 .. [[ = (]] .. varName1 .. [[:gsub("]].. stringToHexadecimal("(%x%x)") .. [[",function(x)return string.char(tonumber(x, 16))end))
        local ]] .. varName3 .. [[ = {}
        local ]] .. varName12 .. [[ = {
            __index=function(_, ]] .. varName14 .. [[)
                if type(]] .. varName14 .. [[)=="number"and ]] .. varName14 .. [[>=1 and ]] .. varName14 .. [[<=#]] .. varName2 .. [[ then
                    local ]] .. varName15 .. [[ = ]]..varName17..[[(]] .. varName2 .. [[:byte(]] .. varName14 .. [[),]] .. key .. [[)return string.char(]] .. varName15 .. [[)end end,
            __len=function(_)return#]] .. varName2 .. [[ end
        }
        local ]] .. varName13 .. [[=setmetatable({}, ]] .. varName12 .. [[)
        for ]] .. varName16 .. [[ = 1,#]] .. varName2 .. [[ do
            ]] .. varName3 .. [[[#]] .. varName3 .. [[+1]=]] .. varName13 .. [[[]] .. varName16 .. [[]
        end
        return table.concat(]] .. varName3 .. [[)
    end
    ]]
    
    return code
end

local function obfuscateCodeBalanced(code)
    local hexChars = "0123456789ABCDEF"
    local hex_parts = {}
    
    for i = 1, #code do
        local b = string.byte(code, i)
        hex_parts[#hex_parts + 1] = string.format("%02X", b)
    end
    
    local hex_code = table.concat(hex_parts)
    
    local varName1 = RandomVarName(11)
    local varName2 = RandomVarName(10)
    
    return string.format([[
do local %s="%s"local %s = ""for i = 1,#%s,2 do %s = %s .. string.char(tonumber(%s:sub(i, i+1), 16))end(loadstring or load)(%s)()end
]], varName1, hex_code, varName2, varName1, varName2, varName2, varName1, varName2)
end

--[=[
local LibCompress = {}

function LibCompress:CompressLZW(uncompressed)
    if type(uncompressed) ~= "string" then return uncompressed end
    local dict = {}
    local dict_size = 256
    for i = 0, 255 do
        dict[string.char(i)] = i
    end
    local result = {}
    local w = ""
    for i = 1, #uncompressed do
        local c = uncompressed:sub(i, i)
        local wc = w .. c
        if dict[wc] then
            w = wc
        else
            table.insert(result, dict[w])
            dict[wc] = dict_size
            dict_size = dict_size + 1
            w = c
        end
    end
    if w ~= "" then
        table.insert(result, dict[w])
    end

    local compressed_str = ""
    for _, code in ipairs(result) do
        if code < 128 then
            -- 1 byte (0-127)
            compressed_str = compressed_str .. string.char(code)
        elseif code < 16384 then
            -- 2 bytes (128-16383)
            local high = math.floor(code / 128)
            local low = code % 128
            compressed_str = compressed_str .. string.char(128 + high) .. string.char(low)
        else
            -- 3 bytes (16384-2097151) - for very large codes
            local byte1 = math.floor(code / 16384)
            local remainder = code % 16384
            local byte2 = math.floor(remainder / 128)
            local byte3 = remainder % 128
            compressed_str = compressed_str .. string.char(192 + byte1) .. string.char(128 + byte2) .. string.char(byte3)
        end
    end
    return compressed_str
end

function LibCompress:DecompressLZW(compressed)
    if type(compressed) ~= "string" then return compressed end
    local dict = {}
    local dict_size = 256
    for i = 0, 255 do
        dict[i] = string.char(i)
    end
    local result = {}
    local i = 1
    local codes = {}
    
    while i <= #compressed do
        local byte1 = string.byte(compressed, i)
        local code
        
        if byte1 < 128 then
            -- 1 byte
            code = byte1
            i = i + 1
        elseif byte1 < 192 then
            -- 2 bytes
            local high = byte1 - 128
            local low = string.byte(compressed, i + 1)
            code = high * 128 + low
            i = i + 2
        else
            -- 3 bytes
            local high = byte1 - 192
            local mid = string.byte(compressed, i + 1) - 128
            local low = string.byte(compressed, i + 2)
            code = high * 16384 + mid * 128 + low
            i = i + 3
        end
        
        table.insert(codes, code)
    end
    
    if #codes == 0 then return "" end
    local w = dict[codes[1]]
    table.insert(result, w)
    for i = 2, #codes do
        local k = codes[i]
        local entry
        if dict[k] then
            entry = dict[k]
        elseif k == dict_size then
            entry = w .. w:sub(1, 1)
        else
            break
        end
        table.insert(result, entry)
        dict[dict_size] = w .. entry:sub(1, 1)
        dict_size = dict_size + 1
        w = entry
    end
    return table.concat(result)
end

local function compressAndEncode(str)
    local compressed = LibCompress:CompressLZW(str)
    return base64_lib.enc(compressed)
end

local function decodeAndDecompress(encoded)
    local compressed = base64_lib.dec(encoded)
    return LibCompress:DecompressLZW(compressed)
end
]=]

local function splitString(str, chunkSize)
    local parts = {}
    for i = 1, #str, chunkSize do
        table.insert(parts, "'" .. str:sub(i, i + chunkSize - 1) .. "'")
    end
    return parts
end

local function trimAll(str)
    if type(str) ~= "string" then
        return str
    end
    return str:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
end

local function randomVarNameLength()
    return randomVarIlIlII(math.random(9, 13), true)
end

local function obfuscate(code, obfuscateConfig)
    if type(code) ~= "string" then return nil end
    if type(obfuscateConfig) ~= "table" then print("warning: obfuscateConfig must be a table!") end
    if trimAll(code) == "" then print("put an code!") return end
    local loader = load or loadstring
    
    local defaults = {
        UseCustomBytecode = {value = false, type = "boolean"},
        UseCustomKey = {value = true, type = "boolean"},
        UseStringEncoder = {value = true, type = "boolean"},
        StringEncoderKey = {value = 2, type = "number", min = 1, max = 100},
        AddJunkBlockCode = {value = true, type = "boolean"},
        MinifyOutput = {value = true, type = "boolean"}
    }
    
    if not obfuscateConfig or type(obfuscateConfig) ~= "table" then
        obfuscateConfig = {}
    end
    
    local config = {}
    for key, defaultInfo in pairs(defaults) do
        if obfuscateConfig[key] ~= nil then
            local userValue = obfuscateConfig[key]
            local expectedType = defaultInfo.type
            
            if type(userValue) == expectedType then
                if expectedType == "number" and defaultInfo.min and defaultInfo.max then
                    if userValue >= defaultInfo.min and userValue <= defaultInfo.max then
                        config[key] = userValue
                    else
                        print("warning: " .. key .. " must be between " .. defaultInfo.min .. " and " .. defaultInfo.max .. ", using default: " .. defaultInfo.value)
                        config[key] = defaultInfo.value
                    end
                else
                    config[key] = userValue
                end
            else
                print("warning: " .. key .. " must be " .. expectedType .. ", using default: " .. tostring(defaultInfo.value))
                config[key] = defaultInfo.value
            end
        else
            config[key] = defaultInfo.value
        end
    end
    
    local key = (config.UseCustomKey and math.floor(#code % 256)) or 45

    local hex
    if config.UseCustomBytecode then
        if config.UseStringEncoder  then
            hex = bytes_to_hex(minifyLua(ParseStrings(BytecodeEncoder.process(code), config.StringEncoderKey)), key)
        else
            hex = bytes_to_hex(minifyLua(BytecodeEncoder.process(code)), key)
        end
    else
        if config.UseStringEncoder then
            hex = bytes_to_hex(minifyLua(ParseStrings(code, config.StringEncoderKey)), key)
        else
            hex = bytes_to_hex(minifyLua(code), key)
        end
    end
 
    -- Sempre usa base64 apenas (sem LZW)
    local base64_text = base64_lib.enc(hex)
    
    local funcCode = makeBase64Dec()
    local hex2 = bytes_to_hex(funcCode, key)

    local varNameLoad = randomVarNameLength()
    local varNameDecodeFunc = randomVarNameLength()
    local varNameHex = randomVarNameLength()
    local varNameCode = randomVarNameLength()
    local makeBytesToHexFunc = randomVarNameLength()
    local creditTable = randomVarNameLength()
    
    local boolean_table = {
        "true",
        "false",
        "nil",
        "true or false",
        "false or nil",
        "true or nil",
        "false and true",
        "true and true",
        "nil and nil",
        "false and nil or true"
    }
    --[==[
    local decompressFunc = randomVarNameLength()
    local codesTableName = randomVarNameLength()
    local dictVar = RandomVarName(randomVarNameLength())
    local dictSizeVar = randomVarNameLength()
    local resultVar = randomVarNameLength()
    local iVar = randomVarNameLength()
    local byte1Var = randomVarNameLength()
    local codeVar = randomVarNameLength()
    local highVar = randomVarNameLength()
    local lowVar = randomVarNameLength()
    local midVar = randomVarNameLength()
    local wVar = randomVarNameLength()
    local kVar = randomVarNameLength()
    local entryVar = randomVarNameLength()
    local compressedParam = randomVarNameLength()
    
    local decompressCode = [=[
local function ]=] .. decompressFunc .. [=[(]=] .. compressedParam .. [=[)
    local ]=] .. dictVar .. [=[ = {}
    local ]=] .. dictSizeVar .. [=[ = 256 
    for ]=] .. iVar .. [=[ = 0, 255 do 
        ]=] .. dictVar .. [=[[]=] .. iVar .. [=[] = string.char(]=] .. iVar .. [=[)
    end 
    local ]=] .. resultVar .. [=[ = {}
    local ]=] .. iVar .. [=[ = 1 
    local ]=] .. codesTableName .. [=[ = {}
    
    while ]=] .. iVar .. [=[ <= #]=] .. compressedParam .. [=[ do
        local ]=] .. byte1Var .. [=[ = string.byte(]=] .. compressedParam .. [=[, ]=] .. iVar .. [=[)
        local ]=] .. codeVar .. [=[
        
        if ]=] .. byte1Var .. [=[ < 128 then
            ]=] .. codeVar .. [=[ = ]=] .. byte1Var .. [=[
            ]=] .. iVar .. [=[ = ]=] .. iVar .. [=[ + 1
        elseif ]=] .. byte1Var .. [=[ < 192 then
            local ]=] .. highVar .. [=[ = ]=] .. byte1Var .. [=[ - 128
            local ]=] .. lowVar .. [=[ = string.byte(]=] .. compressedParam .. [=[, ]=] .. iVar .. [=[ + 1)
            ]=] .. codeVar .. [=[ = ]=] .. highVar .. [=[ * 128 + ]=] .. lowVar .. [=[
            ]=] .. iVar .. [=[ = ]=] .. iVar .. [=[ + 2
        else
            local ]=] .. highVar .. [=[ = ]=] .. byte1Var .. [=[ - 192
            local ]=] .. midVar .. [=[ = string.byte(]=] .. compressedParam .. [=[, ]=] .. iVar .. [=[ + 1) - 128
            local ]=] .. lowVar .. [=[ = string.byte(]=] .. compressedParam .. [=[, ]=] .. iVar .. [=[ + 2)
            ]=] .. codeVar .. [=[ = ]=] .. highVar .. [=[ * 16384 + ]=] .. midVar .. [=[ * 128 + ]=] .. lowVar .. [=[
            ]=] .. iVar .. [=[ = ]=] .. iVar .. [=[ + 3
        end
        
        table.insert(]=] .. codesTableName .. [=[, ]=] .. codeVar .. [=[)
    end
    
    if #]=] .. codesTableName .. [=[ == 0 then 
        return ""
    end 
    
    local ]=] .. wVar .. [=[ = ]=] .. dictVar .. [=[[]=] .. codesTableName .. [=[[1]]
    table.insert(]=] .. resultVar .. [=[, ]=] .. wVar .. [=[)
    
    for ]=] .. iVar .. [=[ = 2, #]=] .. codesTableName .. [=[ do
        local ]=] .. kVar .. [=[ = ]=] .. codesTableName .. [=[[]=] .. iVar .. [=[]
        local ]=] .. entryVar .. [=[
        
        if ]=] .. dictVar .. [=[[]=] .. kVar .. [=[] then
            ]=] .. entryVar .. [=[ = ]=] .. dictVar .. [=[[]=] .. kVar .. [=[]
        elseif ]=] .. kVar .. [=[ == ]=] .. dictSizeVar .. [=[ then
            ]=] .. entryVar .. [=[ = ]=] .. wVar .. [=[ .. ]=] .. wVar .. [=[:sub(1, 1)
        else
            break
        end
        
        table.insert(]=] .. resultVar .. [=[, ]=] .. entryVar .. [=[)
        ]=] .. dictVar .. [=[[]=] .. dictSizeVar .. [=[] = ]=] .. wVar .. [=[ .. ]=] .. entryVar .. [=[:sub(1, 1)
        ]=] .. dictSizeVar .. [=[ = ]=] .. dictSizeVar .. [=[ + 1 
        ]=] .. wVar .. [=[ = ]=] .. entryVar .. [=[ 
    end
    
    return table.concat(]=] .. resultVar .. [=[)
end
]=]]==]
    
    local hex2Parts = splitString(hex2, 200)
    local base64Parts = splitString(base64_text, 200)
    
    local obfNumber1 = obfuscateNumber(1)
    local obfNumber2 = obfuscateNumber(2)
    
    local randomStringName = randomVarNameLength()
    local usingJunkBlock = config.AddJunkBlockCode == true
    
    local watermark = "Protected by OX 2Fuscator"
    
    local parts = {
        "return(function()",
        "local " .. creditTable .. "={'", watermark,"','hard obfuscate','super ofuscator 0-0','this obfuscator is very hard obfuscator','secretkey123'..tostring(" .. boolean_table[math.random(1, #boolean_table)] .. ")..tostring(" .. boolean_table[math.random(1, #boolean_table)] .. "), 'lol bro', '*-* 1234567890'} ",
        makeJunkBlock(usingJunkBlock), " ",
        makeHexToBytes(makeBytesToHexFunc, key),
        " local ", varNameLoad, "={['", randomStringName,"']=table.concat,[math.floor(",obfNumber1,"+0.5)]=nil,[math.floor(",obfNumber2, "+0.5)]=", creditTable, "}",
        "local ", varNameHex, "=", varNameLoad, "['", randomStringName,"']({", table.concat(hex2Parts, ","), "}) ",
        "local ", varNameDecodeFunc, "=loadstring or load ",
        varNameLoad, "[math.floor(",obfNumber1,"+0.5)]=", varNameDecodeFunc, " ",
        generateDeadCode(), " ",
        varNameDecodeFunc, "=", varNameLoad, "[math.floor(",obfNumber1,"+0.5)](", makeBytesToHexFunc, "(", varNameHex, "))()[1] ",
        "local ", varNameHex, "=", varNameLoad, "['", randomStringName,"']({", table.concat(base64Parts, ","), "}) ",
        "local ", varNameCode, "=", varNameDecodeFunc, "(", varNameHex, ") ",
        "local ", varNameHex, "=", "string.reverse(", makeBytesToHexFunc, "(", varNameCode, ")) ",
        "if ", varNameLoad, "[math.floor(", obfNumber2, "+0.5)][math.floor(", obfNumber1,"+0.5)]~='", encoderHex(watermark), "'then error('", encoderHex("Modified Watermark"), "')end ",
        generateAntiTampering(varNameLoad), " ",
        makeJunkBlock(usingJunkBlock), " ",
        "return ", varNameLoad, "[math.floor(",obfNumber1,"+0.5)](string.reverse(" .. varNameHex .. "))();",
        "end)();"
    }
    
    local obfuscated = table.concat(parts)
    if obfuscateConfig.MinifyOutput == true then
        obfuscated = "--[[ v1.0.0\n obfuscated by OX 2Fuscator ]]\n" .. minifyLua(obfuscated)
        nameCounter = 0
        return obfuscated
    else
        obfuscated = "--[[ v1.0.0\n obfuscated by OX 2Fuscator ]]" .. obfuscated
        nameCounter = 0
        return obfuscated
    end
end

local code = [[
print("Hello, World!")
]]

code = obfuscate(code, {
    UseCustomBytecode = true,
    UseCustomKey = true,
    UseStringEncoder = true,
    StringEncoderKey = 4,
    AddJunkBlockCode = true,
    MinifyOutput = true
})

--[[
if code ~= nil then
    print("=== OBFUSCATED CODE ===")
    print(code)
    load(code)()
    --writefile("obfuscated_code_" .. os.time(), code)
end
]]

return obfuscate