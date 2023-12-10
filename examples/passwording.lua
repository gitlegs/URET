local uret = require('uret')

local datastore = {}
function datastore.set(value)
    local success, file = pcall(io.open, 'examples/password.txt', 'w')
    if success and file then
        file:write(value)
        file:close()
    else
        print('failed to open file:', file)
    end
end
function datastore.get()
    local success, file = pcall(io.open, 'examples/password.txt', 'r')
    if success and file then
        local value = file:read()
        file:close()
        return value
    else
        print('failed to read file:', file)
    end
end

-- this is just an example, please use proper security when dealing with passwords
-- hashing can be useful when storing passwords since hashes are the same if you use it on the same string
-- also encrypt for added security
-- the datastore thing is also just made up, pretend it works like a normal datastore with a set/get methods

local function askforpassword()
    local password
    while true do
        print('please enter a password')
        password = io.read()
        if password:len() > 3 then
            break
        else
            print('too short, please try again')
        end
    end
    return password
end

local encrypt, decrypt = uret.cypher(1, 16, true)

print('please type a "y" if you wanna signup')
local signup = io.read()

if signup == 'y' then
    print('signup screen')
    local password = askforpassword()
    local hash = uret.hash(password)
    local encrypted = encrypt(hash)
    datastore.set(encrypted)
    print('password: ', password, 'hash: ', hash, 'encrypted:', encrypted)
    print('encrypted hash saved to store')
else
    local encrypted = datastore.get()
    local hashed = decrypt(encrypted)
    print('login screen')
    local password = askforpassword()
    local hash = uret.hash(password)
    if hash == hashed then
        print('success!')
    else
        print('incorrect password')
    end
    print('password entered:', password, 'saved password hash: ', hashed, 'password entered hash:', hash)
end