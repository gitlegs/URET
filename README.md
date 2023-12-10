# URET
Useless Random Encryption Thing, a hashing and encryption module for vanilla lua.
Feel free to use/edit I would prefer to be creditted but the module is very simple as of right now anyway.

# Little guide
Hello this is a little guide so you know how to use the URET module. Credits to luvit for allowing me to create this.

The `test.lua` file gives an example usage of the different methods. The `uret.lua` file is the actual module and the `examples` folder I will fill with use cases.

```
local uret = require('uret')
```

## Cypher
The main part of the URET module and allows for simple cypher type encryption. The function takes a `mode` parameter depending on what needs to encrypted.
|parameter|description|required|
|-|-|-|
|mode|A number that indicates what datatype is to be encrypted.|`true`|
|key| !Important! The key used to encrypt and decrypt the data, can be any interger.|`true`|
|nosecret| Secret allows for only the returned `encrypt` and `decrypt` methods to work only on each other, set to `true` if you do not want this (default: `false`) | `false` |

### Mode 1
Allows to encrypt strings, the main backbone of encrypting is so malicious users cannot spy on your sensitive data which is usually stored in strings.

**Example**
```lua
local key = 67^3
local encrypt, decrypt = uret.cypher(1, key)

local raw = 'some string here!'
local encrypted = encrypt(raw)

print('raw: ', raw) -- 'raw:  some string here!'
print('encrypted: ', encrypted) -- 'encrypted:  (encrypted string)'
print('decrypted: ', decrypt(encrypted)) -- 'decrypted:  some string here!'
```

### Mode 2
Used to encrypt tables/arrays. Returns a table with encrypted indexes and values. Also has an extra parameter; `meta` that tells the function to include the table's metatable and attach it. Default is `false`

**Attention:** Only encrypts strings and numbers, other datatypes are left as raw.

**Example:**
```lua
local key = 67^3
local encrypt, decrypt = uret.cypher(2, key, false, true)

local t = {
  first = 'hello!',
  second = false,
  third = 34,
}

local et = encrypt(t)

print('raw: ', dump(t)) -- raw:  {['first']='hello!', ['second']=false, ['third']=34}
print('encrypted: ', dump(et)) -- encrypted:  {['ENCRYPTED']='ENCRYPTED', ['ENCRYPTED']=false, ['ENCRYPTED']=BIGNUMBER}
print('decrypted: ', dump(decrypt(et)) -- decrypted:  {['first']='hello!', ['second']=false, ['third']=34}
```

### Mode 3
Encrypts(??) numbers.

## Hash
The module also has my own hashing algorithm (`uret.hash`), which works but has a lot of flaws due to its simplicity. Hashing is one way and cannot be reversed.

|parameter|description|required|
|-|-|-|
|raw|A string you want to be hashed|`true`|

```lua
local raw = 'hello!'
local hash = uret.hash(raw)

print(hash) -- '6!1e1h1l2o1'
print(hash==uret.hash('hello!')) -- true
```
## Byting
This module also turns strings into a format showing the characters bytecodes. This can be useful since roblox allows you to index globals using this format, for reasons I do not know. Can be useful for obfuscating local scripts.

**Attention:** I would not use this for saving/transferring data since it normally makes the string 3-4x bigger in size which isn't performant. Also very little reason since its not hard to reverse.

|parameter|description|required|
|-|-|-|
|raw| A string that you want to be turned into a byted| `true`|

**Example**
```lua
local raw = 'a simple string'
local byted = uret.tobyte(raw)

print(raw) -- '97\32\115\105\109\112\108\101\32\115\116\114\105\110\103'
print(uret.frombyte(raw)) -- 'a simple string'
```

--- 

Thanks for looking at my module
