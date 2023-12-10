--[[
    URET - useless random encryption thing
    made by gitlegs
    version: 0.5
]]
math.randomseed(os.time()) -- vanilla lua sucks

local uret = {}

local __charrange = {min=0,max=255} -- this may be useless

local charlist = {} do
    for i=__charrange.min, __charrange.max, 1 do -- ez charlist
        table.insert(charlist, string.char(i))
    end
end

local function convertchar(key, char) -- the main thingy that changes everything
    local num = char:byte()+key
    local range = __charrange.max - __charrange.min
    local code = num%range -- i use mod so like if the number is 6328 it will be in the range for string.char 
    return string.char(code) -- string.char doesnt work with numbers over 255 for obvious reasons
end

local function cypherstring(key, secret)
    local function encrypt(raw)
        local encrypted = ''
        for char in raw:gmatch('.') do -- this at least looks clean
            local replacement = convertchar(key*secret, char)
            encrypted = encrypted..replacement
        end
        return encrypted
    end
    local function decrypt(encrypted)
        local raw = ''
        for char in encrypted:gmatch('.') do -- this is basically the main part
            local origin = convertchar(-(key*secret), char)
            raw = raw..origin
        end
        return raw
    end
    return encrypt, decrypt
end

local function cyphernumber(key, secret)
    local function encrypt(rawnumber)
        return rawnumber*key*secret -- this is pathetically stupid
    end
    local function decrypt(bignumber)
        return bignumber/(key*secret) -- idk, might change it
    end
    return encrypt, decrypt
end

local function cyphertable(key, secret, meta)
    -- dont use this if you have any deep cyclic tables, can cause infinite callback and crash your sessions
    -- for example will work : {index = thisTable} and {index = differentTable} 
    -- will not work: {index = {deepindex = topTable}} (this will crash your session)
    local encryptstring, decryptstring = cypherstring(key, secret) -- ewwwww
    local encryptnumber, decryptnumber = cyphernumber(key, secret)
    local function encrypt(rawtable)
        local encryptedtable = {}
        for i, v in pairs(rawtable) do
            -- this is ugly
            if type(i) == 'string' then i = encryptstring(i)
            elseif type(i) == 'number' then i = encryptnumber(i)
            elseif type(i) == 'table' and i ~= rawtable then i = encrypt(i) end

            if type(v) == 'string' then v = encryptstring(v)
            elseif type(v) == 'number' then v = encryptnumber(v)
            elseif type(v) == 'table' and v ~= rawtable then v = encrypt(v) end
            -- tries and prevents cyclic tables, however it isnt guaranteed

            encryptedtable[i] = v
        end
        local rawmeta = meta and getmetatable(rawtable) 
        if meta and rawmeta then -- would this have a purpose? lol
            setmetatable(encryptedtable, encrypt(rawmeta))
        end
        return encryptedtable
    end
    local function decrypt(encryptedtable)
        local rawtable = {}
        for i, v in pairs(encryptedtable) do
            -- this is ugly 2.0
            if type(i) == 'string' then i = decryptstring(i)
            elseif type(i) == 'number' then i = decryptnumber(i)
            elseif type(i) == 'table' and i ~= encryptedtable then i = decrypt(i) end
            
            if type(v) == 'string' then v = decryptstring(v)
            elseif type(v) == 'number' then v = decryptnumber(v)
            elseif type(v) == 'table' and v ~= encryptedtable then v = decrypt(v) end
            -- tries and prevents cyclic tables, however it isnt guaranteed
            rawtable[i] = v
        end
        local encryptedmeta = meta and getmetatable(encryptedtable)
        if meta and encryptedmeta then -- its a thing anyway
            setmetatable(rawtable, decrypt(encryptedmeta))            
        end
        return rawtable
    end
    return encrypt, decrypt -- this entire function is an ick
end

function uret.cypher(mode, key, nosecret, ...)
    local secret = (nosecret and 8) or math.random(1, 255) 
    -- makes it so only the returned decrypt function can decrypt what the encrypt function encrypts
    -- useless if in different sessions/environments since functions cannot be saved/transferred, use nosecret if so 
    if mode==1 then
        return cypherstring(key, secret)
    elseif mode==2 then
        return cyphertable(key, secret, ...) -- kinda ugly but works
    elseif mode==3 then
        return cyphernumber(key, secret) -- i could do seperate functions but no
    end
end

function uret.tobyte(raw) -- wouldnt use this unless obfuscating scripts, makes strings 3-4x times longer which affects performance
    local byted = ''
    for char in raw:gmatch('.') do
        byted = byted..[[\]]..char:byte() -- in roblox you can index with these strings??? (i.e math[uret.tobyte('floor')] works for some reason)
    end
    return byted:sub(2) -- basically math['102\108\111\111\114'](1.2) is the same as math.floor(1.2) in roblox, idk why
end

function uret.frombyte(byted) -- reversability
    local raw = ''
    for num in byted:gmatch('%d+') do
        local works, char = pcall(string.char, tonumber(num))
        if works and char then
            raw = raw..char
        else
            raw = raw..('?') -- shouldnt happen tbf
        end
    end
    return raw
end

function uret.hash(raw) -- custom hashing algorithm, not too complex and idk if its any use
    local hash = tostring(raw:len()) -- first number is the length of the string
    local jar = {}
    
    for char in raw:gmatch('.') do -- counting how many of each character there is
        if jar[char] then
            jar[char] = jar[char]+1
        else
            jar[char] = 1
        end
    end
    for _, char in pairs(charlist) do -- i use charlist so the hashing has an order
        local count = jar[char]
        if count then
            hash = hash..char..tostring(count)
        end
    end
    return hash:gsub('%s+', '')
end

return uret