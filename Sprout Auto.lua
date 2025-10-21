-- 🌱 Bee Swarm Simulator - Auto Magic Bean (Fixed True Event)
-- By Somsi & Meo 2025 | เวอร์ชันที่ปลูกได้จริงแน่นอน

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local ItemEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPackageEvent")

-- 🗺️ ฟิลด์ทั้งหมด
local fieldPositions = {
	["Sunflower Field"] = Vector3.new(-213.1, 3.9, 172.1),
	["Dandelion Field"] = Vector3.new(-31.5, 3.9, 220.9),
	["Mushroom Field"] = Vector3.new(-88.2, 3.9, 108.2),
	["Blue Flower Field"] = Vector3.new(141.5, 3.9, 100.0),
	["Clover Field"] = Vector3.new(154.7, 33.4, 193.3),
	["Strawberry Field"] = Vector3.new(-179.4, 19.9, -13.0),
	["Spider Field"] = Vector3.new(-45.3, 19.9, -12.9),
	["Bamboo Field"] = Vector3.new(135.1, 19.9, -28.3),
	["Pineapple Patch"] = Vector3.new(255.2, 67.9, -216.8),
	["Stump Field"] = Vector3.new(425.5, 95.9, -171.7),
	["Cactus Field"] = Vector3.new(-190.9, 67.9, -103.4),
	["Pumpkin Patch"] = Vector3.new(-193.0, 67.9, -185.2),
	["Pine Tree Forest"] = Vector3.new(-333.2, 67.9, -187.9),
	["Rose Field"] = Vector3.new(-331.4, 19.9, 129.5),
	["Mountain Top Field"] = Vector3.new(79.5, 175.9, -164.0),
	["Pepper Patch"] = Vector3.new(-489.7, 123.1, 532.4),
	["Coconut Field"] = Vector3.new(-263.1, 71.4, 464.8)
}

-- ⚙️ การตั้งค่า
local Mode = "Any"
local Delay = 8
local SelectedFields = { "Coconut Field", "Pine Tree Forest" }

-- ฟังก์ชันเวลา
local function isDayTime()
	local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
	return hour >= 6 and hour < 18
end

local function isNightTime()
	local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
	return hour < 6 or hour >= 18
end

-- ฟังก์ชันปลูก
local function plantMagicBean()
	local success, err = pcall(function()
		ItemEvent:InvokeServer("Consume", {["Name"] = "Magic Bean"})
	end)
	if success then
		print("[AutoPlant] 🌱 ปลูก Magic Bean สำเร็จ!")
	else
		warn("[AutoPlant] ❌ ปลูกไม่สำเร็จ:", err)
	end
end

-- ฟังก์ชันหลัก
task.spawn(function()
	while task.wait(Delay) do
		for _, fieldName in ipairs(SelectedFields) do
			local pos = fieldPositions[fieldName]
			if pos then
				humanoidRootPart.CFrame = CFrame.new(pos)
				local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
				
				if Mode == "Any"
				or (Mode == "Day" and isDayTime())
				or (Mode == "Night" and isNightTime()) then
					plantMagicBean()
				else
					print(string.format("[AutoPlant] ⏳ รอเวลา (%s) | ตอนนี้: %s", Mode, Lighting.TimeOfDay))
				end
			end
		end
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
	task.wait(2)
	print("[AutoPlant] 🔁 ตัวละครโหลดใหม่ เริ่มปลูกต่ออัตโนมัติ")
end)

print("✅ Auto Magic Bean System Loaded Successfully (True Event)")
