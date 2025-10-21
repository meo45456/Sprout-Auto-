-- 🌱 Bee Swarm Simulator - Auto Magic Bean System (UI 3 Tabs)
-- By Somsi & Meo | 2025 | ปรับใหม่ทั้งหมด (แก้เวลา, delay, auto-respawn)

if not game:IsLoaded() then game.Loaded:Wait() end

local Version = "1.6.41"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

-- UI Window
local Window = WindUI:CreateWindow({
    Title = "Bee Swarm Simulator - Auto Magic Bean",
    Icon = "",
    Author = "Somsi & Meo",
    Size = UDim2.fromOffset(320, 320),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "",
    BackgroundImageTransparency = 0.95,
    HideSearchBar = true,
    ScrollBarEnabled = false,
})

-- Tabs
local Tabs = {
    Main = Window:Tab({ Title = "🌾 ปลูกไม่สนเวลา" }),
    Day = Window:Tab({ Title = "☀️ ปลูกเฉพาะกลางวัน" }),
    Night = Window:Tab({ Title = "🌙 ปลูกเฉพาะกลางคืน" }),
}

-- 🧩 ตัวแปรหลัก
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerActivesCommand")

-- 🗺️ พิกัดฟิลด์ทั้งหมด
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

local fields = {}
for name, _ in pairs(fieldPositions) do
    table.insert(fields, name)
end

-- ฟังก์ชันตรวจเวลา
local function isDayTime()
	local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
	return hour >= 6 and hour < 18
end

local function isNightTime()
	local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
	return hour < 6 or hour >= 18
end

-- ฟังก์ชันหลัก
local function startAutoPlant(selectedFields, mode)
	task.spawn(function()
		while true do
			for _, fieldName in ipairs(selectedFields) do
				local pos = fieldPositions[fieldName]
				if pos then
					humanoidRootPart.CFrame = CFrame.new(pos)

					if mode == "Any" then
						Event:FireServer({ Name = "Magic Bean" })
					elseif mode == "Day" and isDayTime() then
						Event:FireServer({ Name = "Magic Bean" })
					elseif mode == "Night" and isNightTime() then
						Event:FireServer({ Name = "Magic Bean" })
					end

					task.wait(8) -- หน่วงให้เซิร์ฟเวอร์รับทัน
				end
			end
		end
	end)
end

-- ฟังก์ชันสร้าง UI แต่ละแท็บ
local function createTab(tab, mode)
	local selected = { "Sunflower Field" }
	local active = false

	tab:Dropdown({
		Title = "เลือกฟิลด์",
		Values = fields,
		Value = selected,
		Multi = true,
		AllowNone = true,
		Callback = function(v)
			selected = v
		end
	})

	tab:Toggle({
		Title = "Auto Plant",
		Default = false,
		Callback = function(state)
			active = state
			if state then
				startAutoPlant(selected, mode)
			end
		end
	})
end

createTab(Tabs.Main, "Any")
createTab(Tabs.Day, "Day")
createTab(Tabs.Night, "Night")

-- รีสปอนแล้วกลับไปปลูกต่อ
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
	task.wait(2)
end)

print("✅ ระบบ Auto Magic Bean โหลดสำเร็จ (WindUI + Fixed Delay & Time)")
