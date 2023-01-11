-- load api
os.loadAPI("fuel.lua")
os.loadAPI("location.lua")

-- define var
local currentFacing = location.f_north
local fuelLevel = 80
local modemSide = "right"
local chatSide = "left"
local modemRCnl = 60000
local modemSCnl = 60001
local cor
local actionWaitTime = 0.5

-- peripheral
local modem = peripheral.wrap(modemSide)
modem.open(modemRCnl)
local chat = peripheral.wrap(chatSide)

-- init location
location.init(currentFacing)

-- set uses fuel level
fuel.setFuelLevel(fuelLevel)

function randomMoveType()
	local d = {empty = 15, forward = 10, up = 1,
	down = 1, turnL = 2, turnR = 2}
	local total = 0
	for i, v in pairs(d) do
		total = total + v
	end
	local rand = math.random(0, total - 1)
	local pair = pairs(d)
	local n = pair[1]
	for i, v in pair do
		if rand < 0 then
			return n
		end
		rand = rand - v
	end
	return nil
end

function randomMove()
	local t = randomMoveType()
	if t == "forward" then
		location.move(location.m_forward, 1)
	end
	if t == "up" then
		location.move(location.m_up, 1)
	end
	if t == "down" then
		location.move(location.m_down, 1)
	end
	if t == "turnL" then
		location.turn(location.t_left)
	end
	if t == "turnR" then
		location.turn(location.t_right)
	end
end

local function waitEvent()
	while true do
		local evt, side, sCnl,
		rCnl, msg, dst = os.pullEvent("modem_message")
		if rCnl == modemSCnl then
			if msg == "stop" then
				shell.exit()
				return
			end
		end
	end
end

cor = coroutine.create(waitEvent)
while true do
	-- resume coroutine
	coroutine.resume(cor)
	-- wait a second
	local timer = os.startTimer(actionWaitTime)
	while true do
		local evt, tid = os.pullEvent("timer")
		if tid == timer then
			break
		end
	end
	-- do action
	randomMove()
end