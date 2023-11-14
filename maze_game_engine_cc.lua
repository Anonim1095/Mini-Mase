local w,h = term.getSize()

local map = {} -- 3x3
local sizeX,sizeY = 25,25
local cntX,cntY = 13,13

local range = 2
local stanRange = range
function possibleToMove(direction)
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

function standartActionsOnMove()

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
                local rooms = {"shop",16,{"text",20,{}}}
				local def_room = "room"
				local room = nil
				local roomFormat = {room,top = false,left = false}
				local function checkOn(room)
					local c1 = math.random(1,room[2])
					local c2 = math.random(1,room[2])
					if c1 == c2 then
						room = room[1]
						return
					else
						if #room[3] == 0 then
							room = nil
						else
							checkOn(room[3])
						end
					end
				end
				checkOn(rooms)
				if room == nil then
					roomFormat.room = def_room
				else
					roomFormat.room = room
				end
				local left = math.random(0,1)
				local top = math.random(0,1)
				if left > 0 then
					roomFormat.left = true
				end
				if top > 0 then
					roomFormat.top = true
				end
				map[y][x] = roomFormat
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
    end
    draw()
    local e,a,d,b,c,x = os.pullEvent()
    if e == "key_up" then
        local key = a
        if key == keys.left or key == keys.a then
            if possibleToMove("left") then
                shiftMap("left")
                generateMap()
				standartActionsOnMove()
            end
        end
        if key == keys.up or key == keys.w then
            if possibleToMove("top") then
                shiftMap("top")
                generateMap()
                standartActionsOnMove()
            end
        end
        if key == keys.right or key == keys.d then
            if possibleToMove("right") then
                shiftMap("right")
                generateMap()
                standartActionsOnMove()
            end
        end
        if key == keys.down or key == keys.s then
            if possibleToMove("down") then
                shiftMap("down")
                generateMap()
                standartActionsOnMove()
            end
        end
    end
    if e == "mouse_click" then
        local button,x,y = a,d,b
    end
end