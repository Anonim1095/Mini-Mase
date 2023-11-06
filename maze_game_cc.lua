local w,h = term.getSize()

local map = {} -- 3x3
local inventory = {
    food = 0,
    water = 0,
    poison = 0,
}

local keybinds = {
    drink = keys.t,
    eat = keys.y,
    poison = keys.u
}

local sizeX,sizeY = 25,25

local cntX,cntY = 13,13

local upgrades = {
    {name = "Range+", price=90, level=0, max_level = 2},
    {name = "Coins+", price=40, level=0, max_level = 2},
    {name = "", price=1000000000, level=2, max_level = 1}
}
local range = 2
local stanRange = range
local coins_range = {1,6}

local once_upgrades = {
    {name = "No Lava", price=100,has=false},
    {name = "Noclip", price=250,has=false},
    {name = "Second life", price=50,has=false}
}

local shop_items = { -- {name = name, price = price}
    {name = "Food", price = 10, id = "food"},
    {name = "Water", price = 25, id = "water"},
    {name = "Alcohol", price = 500, id = "poison"}
}

local coins = 25
local food = 100 --100% = 100 units
local water = 10 --100% = 10 units.

local rarity = { --1 in rarity^rarity room. (it's random to it's more like a chance)
    food = 3,
    water = 2,
    coins = 5
}

local plrS = string.char(182) -- Player icon
local shpS = string.char(241) -- Shop icon
local prtS = string.char(167) -- Portal icon
local lavS = string.char(127) -- Lava icon
local oshS = shpS             -- Once shop
local ushS = shpS             -- Upgrades shop

local gameOver = false
local reason = "Something went wrong"

print("Choose difficulity(0-any number)")
local difficulity
local endless = false
while true do
    difficulity = read()
    if difficulity == "D" then
        once_upgrades[1].has = true
        once_upgrades[2].has = true
        difficulity = 0
        coins = 20000
        break
    end
    if tonumber(difficulity) ~= nil then
        break
    end
end
print("Endless or not? (Y/n)")
while true do
    endless = read()
    if string.lower(endless) == "n" then
        endless = false
        break
    elseif string.lower(endless) == "y" then
        endless = true
        break
    end
end

local wwpt = 0.4*difficulity --Water waste per Turn
local fwpt = 6*difficulity --Water waste per Turn

function possibleToMove(direction)
    if once_upgrades[2].has == true then
        return true
    end
    if direction == "top" then
        return map[cntY][cntX].top
    elseif direction == "right" then
        return map[cntY][cntX+1].left
    elseif direction == "down" then
        return map[cntY+1][cntX].top
    elseif direction == "left" then
        return map[cntY][cntX].left
    end
end

function init()
    for i=1,sizeY,1 do
        table.insert(map, {})
        for y=1,sizeX,1 do
            table.insert(map[i], nil)
        end
    end
end

function clearMap()
    for y=1,sizeY,1 do
        for x=1,sizeX,1 do
            map[y][x] = nil
        end
    end
end

function generateMap()
    for y=1,sizeY,1 do
        for x=1,sizeX,1 do
            if map[y][x] == nil then
                map[y][x] = {}
                local variant = math.random(1,3)
                local type = math.random(1,90)
                local inventory = {}
                if type == math.random(1,90) then
                    type = "shop"
                else
                    type = math.random(1,90)
                    if type == math.random(1,60) then
                        type = "portal"
                    else
                        type = math.random(1,50)
                        if type == math.random(1,50) then
                            type = "lava"
                        else
                            type = math.random(1,300)
                            if type == math.random(1,300) then
                                type = "ushop"
                            else
                                type = math.random(1,250)
                                if type == math.random(1,250) then
                                    type = "oshop"
                                else
                                    type = "room"
                                end
                            end
                        end
                        type = math.random(1,300)
                        if type == math.random(1,300) then
                            type = "ushop"
                        else
                            type = math.random(1,250)
                            if type == math.random(1,250) then
                                type = "oshop"
                            else
                                type = "room"
                            end
                        end
                    end
                end
                local wC1,wC2 = math.random(1,rarity.water),math.random(1,rarity.water)
                local fC1,fC2 = math.random(1,rarity.food),math.random(1,rarity.food)
                local cC1,cC2 = math.random(1,rarity.coins),math.random(1,rarity.coins)
                if wC1 == wC2 then
                    table.insert(inventory,"water")
                end
                if fC1 == fC2 then
                    table.insert(inventory,"food")
                end
                if cC1 == cC2 then
                    table.insert(inventory,"coin")
                end
                local dark = false
                if type ~= "lava" or tonumber(difficulity) > 1 then
                    local t = math.random(1,3)
                    if t == math.random(1,2) then
                        dark = true
                    end
                end
                local form = {top = false, left = false, inventory = inventory, type = type, dark = dark}
                if variant == 1 then
                    form.top = true
                    map[y][x] = form
                elseif variant == 2 then
                    form.left = true
                    map[y][x] = form
                elseif variant == 3 then
                    form.left = true
                    form.top = true
                    map[y][x] = form
                end
            end
        end
    end
end

function shiftMap(direction)
    local newMap = {}
    for y = 1, sizeY do
        newMap[y] = {}
        for x = 1, sizeX do
            newMap[y][x] = nil
        end
    end
    if direction == "down" then
        for x = 1, sizeX do
            for y=2,sizeY,1 do
                newMap[y-1][x] = map[y][x]
            end
        end
        for x=1,sizeY,1 do
            newMap[sizeY][x] = nil
        end
    elseif direction == "right" then
        for y=1,sizeY,1 do
            for x=2,sizeX,1 do
                newMap[y][x] = map[y][x+1]
            end
        end
        for y=1,sizeY,1 do
            newMap[y][sizeX] = nil
        end
    elseif direction == "top" then
        for x=1,sizeX,1 do
            for y=2,sizeY,1 do
                newMap[y][x] = map[y-1][x]
            end
        end
        for x=1,sizeX,1 do
            newMap[1][x] = nil
        end
    elseif direction == "left" then
        for y=1,sizeY,1 do
            for x=sizeX-1,1,-1 do
                newMap[y][x] = map[y][x-1]
            end
        end
        for y=1,sizeY,1 do
            newMap[y][1] = nil
        end
    end
    map = newMap
end

init()
generateMap()

while true do
    local panelWidth = 10

    local function draw()
        local width = panelWidth
        term.setBackgroundColor(colors.black)
        term.clear()
        --Map draw logic
        local offset = 2
        for y=cntY-range,cntY+range,1 do
            for x=cntX-range,cntX+range,1 do
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                term.setCursorPos(x*2+offset-(cntX-range)*2,y*2+offset-(cntY-range)*2)
                if map[y][x].top == true then
                    term.write("# ")
                else
                    term.write("##")
                end
                term.setCursorPos(x*2+offset-(cntX-range)*2,y*2+1+offset-(cntY-range)*2)
                local s = ""
                local sC = colors.white
                if y == cntY and x == cntX then
                    s = plrS
                    sC = colors.yellow
                elseif map[y][x].dark == true then
                    s = "#"
                    sC = colors.gray
                end
                if map[y][x].dark == false  or (y == cntY and x == cntX) then
                    if map[y][x].type == "shop" then
                        s = shpS
                        sC = colors.lime
                    elseif map[y][x].type == "portal" then
                        s = prtS
                        sC = colors.cyan
                    elseif map[y][x].type == "lava" then
                        s = lavS
                        sC = colors.red
                    elseif map[y][x].type == "ushop" then
                        s = ushS
                        sC = colors.blue
                    elseif map[y][x].type == "oshop" then
                        s = oshS
                        sC = colors.yellow
                    end
                end
                if map[y][x].left == true then
                    term.write(" ")
                    term.setTextColor(sC)
                    term.write(s)
                else
                    term.write("#")
                    term.setTextColor(sC)
                    term.write(s)
                end
            end
        end
        -- Coins, Food, Water level
        --FOOD
        term.setBackgroundColor(colors.brown)
        term.setCursorPos(1,h)
        term.clearLine()
        term.setTextColor(colors.white)
        term.write(string.char(249).."Food level: "..food)
        --Water
        term.setBackgroundColor(colors.cyan)
        term.setCursorPos(1,h-1)
        term.clearLine()
        term.setTextColor(colors.white)
        term.write(string.char(117).."Water level: "..water*10)
        --Coins
        term.setBackgroundColor(colors.orange)
        term.setCursorPos(1,h-2)
        term.clearLine()
        term.setTextColor(colors.white)
        term.write(string.char(162).."Coins: "..coins)
        --Shop menu display
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        if map[cntY][cntX].type == "shop" then
            term.setCursorPos(w-width-1,1)
            term.setTextColor(colors.lime)
            term.write(string.char(241))
            term.setTextColor(colors.white)
            term.write("Shop menu")
            for i=1,#shop_items,1 do
                term.setTextColor(colors.white)
                term.setCursorPos(w-width,i*2)
                term.write(shop_items[i].name)
                if coins < shop_items[i].price then
                    term.setTextColor(colors.red)
                end
                term.setCursorPos(w-width,i*2+1)
                term.write(shop_items[i].price)
            end
        end
        if map[cntY][cntX].type == "ushop" then
            term.setCursorPos(w-width-1,1)
            term.setTextColor(colors.blue)
            term.write(string.char(241))
            term.setTextColor(colors.white)
            term.write("Upgrades")
            for i=1,#upgrades,1 do
                term.setTextColor(colors.white)
                term.setCursorPos(w-width,i*2)
                term.write(upgrades[i].name)
                term.write(":"..upgrades[i].level)
                if coins < upgrades[i].price then
                    term.setTextColor(colors.red)
                end
                term.setCursorPos(w-width,i*2+1)
                if upgrades[i].level >= upgrades[i].max_level then
                    term.setTextColor(colors.yellow)
                    term.write("Max LVL") 
                else
                    term.write(upgrades[i].price)
                end
            end
        end
        if map[cntY][cntX].type == "oshop" then
            term.setCursorPos(w-width-1,1)
            term.setTextColor(colors.yellow)
            term.write(string.char(241))
            term.setTextColor(colors.white)
            term.write("Upgrades")
            for i=1,#once_upgrades,1 do
                term.setTextColor(colors.white)
                term.setCursorPos(w-width,i*2)
                term.write(once_upgrades[i].name)
                if coins < once_upgrades[i].price then
                    term.setTextColor(colors.red)
                end
                term.setCursorPos(w-width,i*2+1)
                if once_upgrades[i].has then
                    term.setTextColor(colors.yellow)
                    term.write("Already")
                else
                    term.write(once_upgrades[i].price)
                end
            end
        end
        if map[cntY][cntX].type == "portal" then
            term.setCursorPos(w-width,2)
            term.write("Portal")
            term.setCursorPos(w-width,4)
            term.setTextColor(colors.cyan)
            term.write("TELEPORT")
        end
        --Inventory menu display
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.setCursorPos(w-width-1,8)
        term.setTextColor(colors.brown)
        term.write(string.char(198))
        term.setTextColor(colors.white)
        term.write("Backpack")
        term.setCursorPos(w-width,9)
        term.setTextColor(colors.orange)
        term.write("Food")
        term.setCursorPos(w-width,10)
        term.write(inventory.food.."x")
        term.setCursorPos(w-width,11)
        term.setTextColor(colors.blue)
        term.write("Water")
        term.setCursorPos(w-width,12)
        term.write(inventory.water.."x")
        term.setCursorPos(w-width,13)
        term.setTextColor(colors.brown)
        term.write("Alcohol")
        term.setCursorPos(w-width,14)
        term.write(inventory.poison.."x")
        --Room inventory display
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        if #map[cntY][cntX].inventory > 0 then
            term.setCursorPos(w-width-1,15)
            term.setTextColor(colors.lightGray)
            term.write(string.char(127))
            term.write("Room")
            for i = 1,#map[cntY][cntX].inventory,1 do
                term.setTextColor(colors.white)
                term.setCursorPos(w-width,15+i)
                term.write(map[cntY][cntX].inventory[i])
            end
        end
    end
    draw()
    local e,a,d,b,c,x = os.pullEvent()
    if e == "key_up" then
        local key = a
        if key == keys.left or key == keys.a then
            if possibleToMove("left") then
                shiftMap("left")
                generateMap()
                water = water - wwpt
                food = food - fwpt
                coins = coins + 1
            end
        end
        if key == keys.up or key == keys.w then
            if possibleToMove("top") then
                shiftMap("top")
                generateMap()
                water = water - wwpt
                food = food - fwpt
                coins = coins + 1
            end
        end
        if key == keys.right or key == keys.d then
            if possibleToMove("right") then
                shiftMap("right")
                generateMap()
                water = water - wwpt
                food = food - fwpt
                coins = coins + 1
            end
        end
        if key == keys.down or key == keys.s then
            if possibleToMove("down") then
                shiftMap("down")
                generateMap()
                water = water - wwpt
                food = food - fwpt
                coins = coins + 1
            end
        end
        
        if key == keybinds.eat then
            if inventory.food > 0 then
                inventory.food = inventory.food - 1
                food = food + 15
                if food > 110 then
                    food = 110
                end
            end
        end
        if key == keybinds.drink then
            if inventory.water > 0 then
                inventory.water = inventory.water - 1
                water = water + 1
                if water > 15 then
                    water = 15
                end
            end
        end
        if key == keybinds.poison then
            if inventory.poison > 0 then
                inventory.poison = inventory.poison - 1
                reason = "You drinked alcohol!"
                gameOver = true
            end
        end
    end
    if e == "mouse_click" then
        local button,x,y = a,d,b
        if x >= w-panelWidth then
            --Shop logic
            y = y - 1
            if map[cntY][cntX].type == "shop" then
                if y >= 1 and y <= 6 then
                    local item = math.ceil(y/2)
                    if coins >= shop_items[item].price then
                        inventory[shop_items[item].id] = inventory[shop_items[item].id] + 1
                        coins = coins - shop_items[item].price 
                    end
                end
            end
            if map[cntY][cntX].type == "ushop" then
                if y >= 1 and y <= 6 then
                    local item = math.ceil(y/2)
                    if coins >= upgrades[item].price then
                        if upgrades[item].level < upgrades[item].max_level then
                            upgrades[item].level = upgrades[item].level + 1
                            coins = coins - upgrades[item].price
                        end
                    end
                end
            end
            if map[cntY][cntX].type == "oshop" then
                if y >= 1 and y <= 6 then
                    local item = math.ceil(y/2)
                    if coins >= once_upgrades[item].price then
                        if not once_upgrades[item].has then
                            once_upgrades[item].has = true
                            coins = coins - once_upgrades[item].price
                        end
                    end
                end
            end
            if map[cntY][cntX].type == "portal" then
                if y == 3 then
                    clearMap()
                    generateMap()
                end
            end
            -- Inventory logic
            if y >= 8 and y <= 9 then
                if inventory.food > 0 then
                    inventory.food = inventory.food - 1
                    food = food + 15
                    if food > 110 then
                        food = 110
                    end
                end
            end
            if y >= 10 and y <= 11 then
                if inventory.water > 0 then
                    inventory.water = inventory.water - 1
                    water = water + 1
                    if water > 15 then
                        water = 15
                    end
                end
            end
            if y >= 12 and y <= 13 then
                if inventory.poison > 0 then
                    inventory.poison = inventory.poison - 1
                    reason = "You drinked alcohol!"
                    gameOver = true
                end
            end
            --Room inventory logic
            if y > 14 and y <= 17 then
                local item = y-14
                if #map[cntY][cntX].inventory >= item then
                    if map[cntY][cntX].inventory[item] ~= "coin" then
                        inventory[map[cntY][cntX].inventory[item]] = inventory[map[cntY][cntX].inventory[item]] + 1
                    else
                        if upgrades[2].level > 0 then
                            coins = coins + math.random(coins_range[1]*upgrades[2].level,coins_range[2]*upgrades[2].level)*5
                        else
                            coins = coins + math.random(coins_range[1],coins_range[2])*5
                        end
                    end
                    table.remove(map[cntY][cntX].inventory,item) 

                end
            end
        end
    end
    if food < 0 or water < 0 then
        reason = "You ran out of food/water"
        gameOver = true
        if once_upgrades[3].has == true then
            once_upgrades[3].has = false
            food = 20
            water = 20
        else
            break
        end
    end
    if gameOver then
        break
    end
    if not endless and coins > 666 then
        reason = "You reached 666 coins!"
        break
    end
    if map[cntY][cntX].type == "lava" and once_upgrades[1].has == false then
        reason = "You stepped on lava!"
        gameOver = true
        if once_upgrades[3].has == true then
            once_upgrades[3].has = false
            clearMap()
            generateMap()
        else
            break
        end
    end
    if upgrades[1].level > 0 then
        range = stanRange+upgrades[1].level
    end
    map[cntY][cntX].dark = false
end
if gameOver then
    term.setBackgroundColor(colors.red)
    term.clear()
    term.setTextColor(colors.white)
    term.setCursorPos((w-string.len("GAME OVER!"))/2,h/2)
    term.write("GAME OVER!")
    term.setTextColor(colors.lightGray)
    term.setCursorPos((w-string.len(reason))/2,h/2+1)
    term.write(reason)
    sleep(3)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
else
    term.setBackgroundColor(colors.green)
    term.clear()
    term.setTextColor(colors.white)
    term.setCursorPos((w-string.len("YOU WON!"))/2,h/2)
    term.write("YOU WON!")
    term.setTextColor(colors.lightGray)
    term.setCursorPos((w-string.len(reason))/2,h/2+1)
    term.write(reason)
    sleep(3)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
end