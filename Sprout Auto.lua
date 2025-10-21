-- Bee Swarm Auto Sprout - No UI + On-Screen HUD (by Somsi & Meo)
-- ปลูกอัตโนมัติ / แสดงสถานะกลางจอ / ทำงานต่อหลังตาย

if not game:IsLoaded() then game.Loaded:Wait() end

print("[AutoSprout] กำลังโหลดระบบ...")

-- โหลดค่าจาก Config
local cfg = getgenv().AutoPlantConfig or {}
local set = getgenv().AutoPlantSettings or {}

local EnableAuto = cfg.EnableAutoPlant or true
local Mode = cfg.Mode or "Any" -- Any / Day / Night
local SelectedFields = cfg.SelectedFields or { "Coconut Field" }
local Delay = cfg.Delay or 5
local EnableLog = set.EnableLog or true
local RejoinAfterDeath = set.RejoinAfterDeath or true

-- ตัวแปรหลักในเกม
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerActivesCommand")

-- พิกัดฟิลด์ทั้งหมด
local fieldPositions = {
    ["Sunflower Field"] = Vector3.new(-213.1, 3.9, 172.1),     -- ดอกทานตะวัน
    ["Dandelion Field"] = Vector3.new(-31.5, 3.9, 220.9),      -- ดอกแดนดิไลออน
    ["Mushroom Field"] = Vector3.new(-88.2, 3.9, 108.2),       -- เห็ดแดง
    ["Blue Flower Field"] = Vector3.new(141.5, 3.9, 100.0),    -- ดอกไม้สีน้ำเงิน
    ["Clover Field"] = Vector3.new(154.7, 33.4, 193.3),        -- โคลเวอร์
    ["Strawberry Field"] = Vector3.new(-179.4, 19.9, -13.0),   -- สตรอเบอร์รี่
    ["Spider Field"] = Vector3.new(-45.3, 19.9, -12.9),        -- แมงมุม
    ["Bamboo Field"] = Vector3.new(135.1, 19.9, -28.3),        -- ไผ่
    ["Pineapple Patch"] = Vector3.new(255.2, 67.9, -216.8),    -- สับปะรด
    ["Stump Field"] = Vector3.new(425.5, 95.9, -171.7),        -- ตอไม้
    ["Cactus Field"] = Vector3.new(-190.9, 67.9, -103.4),      -- กระบองเพชร
    ["Pumpkin Patch"] = Vector3.new(-193.0, 67.9, -185.2),     -- ฟักทอง
    ["Pine Tree Forest"] = Vector3.new(-333.2, 67.9, -187.9),  -- ป่าต้นสน
    ["Rose Field"] = Vector3.new(-331.4, 19.9, 129.5),         -- กุหลาบ
    ["Mountain Top Field"] = Vector3.new(79.5, 175.9, -164.0), -- ยอดเขา
    ["Pepper Patch"] = Vector3.new(-489.7, 123.1, 532.4),      -- พริก
    ["Coconut Field"] = Vector3.new(-263.1, 71.4, 464.8)       -- มะพร้าว
}

-- ตัวนับจำนวนที่ปลูก
local SproutCount = 0

-- HUD แสดงสถานะกลางจอ
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local StatusLabel = Instance.new("TextLabel", ScreenGui)
StatusLabel.Size = UDim2.new(0, 480, 0, 40)
StatusLabel.Position = UDim2.new(0.5, -240, 0.1, 0)
StatusLabel.BackgroundTransparency = 0.4
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Text = "เริ่มระบบ Auto Sprout..."
StatusLabel.ZIndex = 9999

-- ฟังก์ชันอัปเดตข้อความสถานะ
local function updateStatus(text, color)
	StatusLabel.Text = text
	if color then StatusLabel.TextColor3 = color end
end

-- เช็กเวลาว่าตรงโหมดมั้ย
local function isTimeForMode()
	local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
	if Mode == "Any" then return true end
	if Mode == "Day" then return hour >= 6 and hour < 18 end
	if Mode == "Night" then return hour < 6 or hour >= 18 end
	return false
end

-- ฟังก์ชันหลัก
local function startAutoSprout()
	if not EnableAuto then
		updateStatus("ระบบปลูกถูกปิดใน Config", Color3.fromRGB(255, 100, 100))
		return
	end

	updateStatus("เริ่มปลูกอัตโนมัติ โหมด: " .. Mode, Color3.fromRGB(0, 255, 100))
	task.spawn(function()
		while EnableAuto do
			for _, fieldName in ipairs(SelectedFields) do
				local pos = fieldPositions[fieldName]
				if pos then
					humanoidRootPart.CFrame = CFrame.new(pos)
					if isTimeForMode() then
						Event:FireServer({ Name = "Sprout" })
						SproutCount += 1
						local msg = string.format("ปลูกที่ %s | ต้นที่ #%d | เวลา %s", fieldName, SproutCount, Lighting.TimeOfDay)
						updateStatus(msg)
						if EnableLog then print("[AutoSprout]", msg) end
					else
						local msg = string.format("รอเวลา (%s) | ตอนนี้: %s", Mode, Lighting.TimeOfDay)
						updateStatus(msg, Color3.fromRGB(255, 255, 0))
						if EnableLog then print("[AutoSprout]", msg) end
					end
					task.wait(Delay)
				else
					updateStatus("ฟิลด์ไม่ถูกต้อง: " .. fieldName, Color3.fromRGB(255, 100, 100))
					warn("[AutoSprout] ไม่พบฟิลด์:", fieldName)
				end
			end
		end
	end)
end

-- เมื่อรีสปอน
player.CharacterAdded:Connect(function(newChar)
	if RejoinAfterDeath then
		character = newChar
		humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
		task.wait(2)
		updateStatus("รีสปอนใหม่ กำลังกลับไปปลูกต่อ...", Color3.fromRGB(100, 200, 255))
		startAutoSprout()
	end
end)

-- เริ่มระบบ
startAutoSprout()
updateStatus("ระบบ Auto Sprout พร้อมทำงาน", Color3.fromRGB(0, 255, 100))
print("[AutoSprout] ระบบทำงานเรียบร้อย (No UI + HUD)")
