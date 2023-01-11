

--  fuel.lua api  --

local fuelLevel = 0

-- set the fuel level(move distance)
function setFuelLevel(level)
	if type(level) == "number" then
		fuelLevel = level
	end
end

-- check all slot space
local function check()
	local total = {}
	for i = 1, 16 do
		total[i] = turtle.getItemSpace(i)
	end
end

-- load fuel with all slot need load
local function loadFuel(nums)
	for i, v in ipairs(nums) do
		turtle.select(i)
		turtle.suck(v)
	end
	turtle.select(1)
end

-- return turtle still have spaces to refuel with fuel level
function refuel()
	for i = 1, 16 do
		turtle.select(i)
		turtle.refuel()
	end
	turtle.select(1)
	return turtle.getFuelLimit() - turtle.getFuelLevel() > fuelLevel
end

-- return if load to full
function checkAndLoad()
	local total = check()
	loadFuel(total)
	total = check()
	local count = 0
	for i, v in ipairs(total) do
		count = count + v
	end
	return count == 0
end




