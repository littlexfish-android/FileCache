
-- action flag
a_moveForward = 0
a_moveUp = 1
a_moveDown = 2
a_turnRight = 3
a_turnLeft = 4

-- move flag
m_forward = 0
m_up = 1
m_down = 2

-- turn flag
t_right = 0
t_left = 1

-- facing flag
f_north = 0
f_east = 1
f_south = 2
f_west = 3

-- use locally to mapping facing
local f_xp = f_east
local f_xn = f_west
local f_zp = f_south
local f_zn = f_north

local v_zero = vector.new(0, 0, 0)
local v_xp = vector.new(1, 0, 0)
local v_xn = vector.new(-1, 0, 0)
local v_zp = vector.new(0, 0, 1)
local v_zn = vector.new(0, 0, -1)
local v_yp = vector.new(0, 1, 0)
local v_yn = vector.new(0, -1, 0)

-- turtle current location
local currentLocation
-- turtle current facing
local facing

-- fuel pos
local fuelPos

-- the block pos
local memory = {}

local function turnLeft()
	turtle.turnLeft()
	facing = facing - 1
	if facing < 0 then
		facing = 3
	end
	detect()
end

local function turnRight()
	turtle.turnRight()
	facing = facing + 1
	if facing > 3 then
		facing = 0
	end
	detect()
end

-- get forward block position from with facing
local function getForwardPos(from, face)
	local forwardPos = nil
	if face == f_xp then
		forwardPos = from + v_xp
	end
	if face == f_xn then
		forwardPos = from + v_xn
	end
	if face == f_zp then
		forwardPos = from + v_zp
	end
	if face == f_zn then
		forwardPos = from + v_zn
	end
	return forwardPos
end

-- insert the vector
-- return x and z to facing
local function vecToFacing(vec)
	local x = f_xp
	local z = f_zp
	if x < 0 then
		x = f_xn
	end
	if z < 0 then
		z = f_zn
	end
	return x, z
end

local function detect()
	local forwardPos = getForwardPos(currentLocation, facing)
	if forwardPos then
		memory[tostring(forwardPos)] = turtle.detect()
	end
	local downPos = currentLocation + v_yn
	memory[tostring(downPos)] = turtle.detectDown()
	local upPos = currentLocation + v_yp
	memory[tostring(upPos)] = turtle.detectUp()
end

function init(f_type)
	facing = f_type
	local x, y, z = gps.locate(5)
	if x ~= nil then
		currentLocation = vector.new(x, y, z)
	end
end

function setFuelPos(pos) -- vector
	if type(pos) == "table" then
		fuel = pos
	end
end

function move(m_type, times)
	for i = 1, times do
		if m_type == m_forward then
			if not turtle.forward() then
				detect()
			end
		end
		if m_type == m_up then
			if not turtle.up() then
				detect()
			end
		end
		if m_type == m_down then
			if not turtle.down() then
				detect()
			end
		end
	end
end

function turn(t_type)
	if t_type == t_right then
		turnLeft()
	end
	if t_type == t_left then
		turnRight()
	end
end

local function get3DirVec(ori)
	local x = v_xp
	local y = v_yp
	local z = v_zp
	if ori.x <= 0 then
		if ori.x == 0 then
			x = v_zero
		else
			x = v_xn
		end
	end
	if ori.y <= 0 then
		if ori.y == 0 then
			y = v_zero
		else
			y = v_yn
		end
	end
	if ori.z <= 0 then
		if ori.z == 0 then
			z = v_zero
		else
			z = v_zn
		end
	end
	return x, y, z
end

-- insert the pos to go
-- return array of vectors
function createPath(pos, dest)
	-- define the current location
	local tmpLocation = pos
	-- get vector from current to destination
	local moveVec = dest - tmpLocation
	-- get coordinate vectors
	local v_x, v_y, v_z = get3DirVec(moveVec)

	local move_priority = {v_x, v_z, v_y, -v_y, -v_x, -v_z}
	local vecs = {}
	vecs[1] = tmpLocation
	local move_index = 1
	-- move location
	while true do
		local n_block = tmpLocation + move_vec
		-- has block
		if memory[tostring(n_block)] == true then
			move_index = move_index + 1
			if move_index > #move_priority then
				move_index = 1
			end
		else
			tmpLocation = n_block
			vecs[#vecs + 1] = tmpLocation
			move_index = 1
		end
	end
	-- optimize path
	while true do
		local hasChange = false
		for i, v in ipairs(vecs) do
			if i == #vecs then
				break
			end
			for j=i + 1, #vecs do
				-- block duplicate
				if vecs[j] == vecs[i] then
					local interval = j - i
					for k = 1, interval do
						vecs.remove(i)
					end
					hasChange = true
					break
				end
			end
			-- prevent modify
			if hasChange then
				break
			end
		end
		if not hasChange then
			break
		end
	end
	-- TODO: check the path algorithm is ok
	return vecs
end

local function vecEquals(v1, v2)
	return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z
end

local function setActs(f1, f2, acts)
	local f = f2 - f1
	if f < 0 then
		f = f + 4
	end
	if f == 0 then
		acts[#acts + 1] = a_moveForward
	end
	if f == 1 then
		acts[#acts + 1] = a_turnRight
		acts[#acts + 1] = a_moveForward
	end
	if f == 2 then
		acts[#acts + 1] = a_turnRight
		acts[#acts + 1] = a_turnRight
		acts[#acts + 1] = a_moveForward
	end
	if f == 3 then
		acts[#acts + 1] = a_turnLeft
		acts[#acts + 1] = a_moveForward
	end
end

local function appendAction(p1, p2, face, acts)
	local v = p2 - p1
	if vecEquals(v, v_xp) then
		setActs(face, f_xp, acts)
		return f_xp
	end
	if vecEquals(v, v_xn) then
		setActs(face, f_xn, acts)
		return f_xn
	end
	if vecEquals(v, v_zp) then
		setActs(face, v_zp, acts)
		return f_zp
	end
	if vecEquals(v, v_zn) then
		setActs(face, v_zn, acts)
		return f_zn
	end
	if vecEquals(v, v_yp) then
		acts[#acts + 1] = a_moveUp
		return face
	end
	if vecEquals(v, v_yn) then
		acts[#acts + 1] = a_moveDown
		return face
	end
end

-- insert path from location:createPath() created
-- return array of action type to do
function createActionFromPath(path, initFacing)
	-- define the current facing when action
	local tmpFacing = initFacing
	local acts = {}
	local nowIndex = 1
	-- find action
	while true do
		if nowIndex == #path then
			break
		end
		local curPos = path[nowIndex]
		local nPos = path[nowIndex + 1]
		tmpFacing = appendAction(curPos, nPos, tmpFacing, acts)
	end
	return acts
end




