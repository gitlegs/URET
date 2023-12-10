local uret = require('uret')

local function testtable()
    local t = {
        'penis',
        'hii',
        someindex = 'somevalue',
        boolean = false,
        afunction = function() end,
        anothertable = {
            deepvalue = 'hii'
        },
        auserdata = newproxy()

    }

    local function dump(o)
        if type(o) == 'table' then
            local s = '{ '
            for k, v in pairs(o) do
                if type(k) ~= 'number' then k = '"' .. k .. '"' end
                s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
            end
            return s .. '} '
        else
            return tostring(o)
        end
    end

    setmetatable(t, { metatablevalue = 'no way!' })

    local key = 34
    local tencrypt, tdecrypt = uret.cypher(2, key, false, true)

    local encrypted = tencrypt(t)
    local decrypted = tdecrypt(encrypted)

    print('raw: ', dump(t), 'meta: ', dump(getmetatable(t)))
    print('encrypted: ', dump(encrypted), 'meta: ', dump(getmetatable(encrypted)))
    print('decrypted: ', dump(decrypted), 'meta: ', dump(getmetatable(decrypted)))
end

local function teststring()
    print('please enter what string you want tested')
    local input = io.read()
    print('please submit a key or leave blank for a random one to be generated')
    local key
    do
        local inputtedKey = tonumber(io.read())
        if inputtedKey then
            key = inputtedKey
        else
            key = math.random(1, 255)
            print('random key generated: ', key)
            print()
        end
    end
    local encr, decr = uret.cypher(1, key)
    local hash = uret.hash(input)

    local encrypted = encr(input)
    local byted = uret.tobyte(input)

    local function attemptBruteforce(max)
        local i = 0
        while i < max do
            i = i + 1
            local _, malDecr = uret.cypher(1, math.random(1, 255))
            local attempt = malDecr(encrypted)
            if attempt == input then
                return true, i
            end
        end
    end

    print('raw: ', input)
    print('hash: ', hash)
    print('encrypted hash: ', uret.cypher(1, 16, true)(hash))
    print('encrypted: ', encrypted)
    print('decrypted:', decr(encrypted))
    print('tobyte: ', byted)
    print('frombyte: ', uret.frombyte(byted))
    print('attempting bruteforce..')
    local t = os.clock()
    local success, tries = attemptBruteforce(1024)
    if success then
        local timetaken = os.clock() - t
        print('successfully bruteforced after try: ', tries, 'time taken: ', timetaken)
    else
        print('was unable to bruteforce')
    end
end

--teststring()
--testtable()