--[[ 🌱 Bee Swarm Auto Sprout - Direct Mode Logger Pro (by Somsi & Meo, 2025) ]]
if not game:IsLoaded() then game.Loaded:Wait() end

print("🐝 [AutoSprout] เริ่มโหลดระบบอัตโนมัติ...")

-- โหลด config
local cfg = getgenv().AutoPlantConfig or {}
local set = getgenv().AutoPlantSettings or {}

local EnableAuto = cfg.EnableAutoPlant or true
local Mode = cfg.Mode or "Any" -- "Any" | "Day" | "Night"
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
    ["Sunflower Field"] = Vector3.new(-213.106, 3.998, 172.139),
    ["Dandelion Field"] = Vector3.new(-31.570, 3.998, 220.934),
    ["Mushroom Field"] = Vector3.new(-88.229, 3.998, 108.274),
    ["Blue Flower Field"] = Vector3.new(141.501, 3.998, 100.013),
    ["Clover Field"] = Vector3.new(154.784, 33.498, 193.350),
    ["Strawberry Field"] = Vector3.new(-179.478, 19.998, -13.090),
    ["Spider Field"] = Vector3.new(-45.358, 19.998, -12.973),
    ["Bamboo Field"] = Vector3.new(135.128, 19.998, -28.362),
    ["Pineapple Patch"] = Vector3.new(255.263, 67.998, -216.829),
    ["Stump Field"] = Vector3.new(425.564, 95.977, -171.742),
    ["Cactus Field"] = Vector3.new(-190.955, 67.998, -103.479),
    ["Pumpkin Patch"] = Vector3.new(-193.054, 67.998, -185.247),
    ["Pine Tree Forest"] = Vector3.new(-333.224, 67.998, -187.910),
    ["Rose Field"] = Vector3.new(-331.457, 19.948, 129.509),
    ["Mountain Top Field"] = Vector3.new(79.509, 175.998, -164.065),
    ["Pepper Patch"] = Vector3.new(-489.727, 123.172, 532.463),
    ["Coconut Field"] = Vector3.new(-263.197, 71.421, 464.853)
}

-- ตัวนับจำนวนที่ปลูก
local SproutCount = 0

-- ฟังก์ชันเช็กเวลา
local function isTimeForMode()
    local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
    if Mode == "Any" then
        return true
    elseif Mode == "Day" then
        return hour >= 6 and hour < 18
    elseif Mode == "Night" then
        return hour < 6 or hour >= 18
    end
    return false
end

-- ฟังก์ชันหลัก
local function startAutoSprout()
    if not EnableAuto then
        warn("🛑 [AutoSprout] ระบบปลูกถูกปิดไว้ใน config")
        return
    end

    print("✅ [AutoSprout] เริ่มทำงานในโหมด:", Mode)
    task.spawn(function()
        while EnableAuto do
            for _, fieldName in ipairs(SelectedFields) do
                local pos = fieldPositions[fieldName]
                if pos then
                    humanoidRootPart.CFrame = CFrame.new(pos)
                    if isTimeForMode() then
                        Event:FireServer({ Name = "Sprout" })
                        SproutCount += 1

                        print(string.format("🌾 ปลูก Sprout #%d | ฟิลด์: %s | เวลา: %s", SproutCount, fieldName, Lighting.TimeOfDay))
                    else
                        if EnableLog then
                            print(string.format("🕓 เวลานี้ไม่ตรงโหมด (%s) ข้ามการปลูก | เวลา: %s", Mode, Lighting.TimeOfDay))
                        end
                    end
                    task.wait(Delay)
                else
                    warn("⚠️ [AutoSprout] ไม่พบฟิลด์:", fieldName)
                end
            end
        end
    end)
end

-- กรณีตัวละครตาย
player.CharacterAdded:Connect(function(newChar)
    if RejoinAfterDeath then
        character = newChar
        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
        task.wait(2)
        print("♻️ [AutoSprout] ตัวละครรีสปอนแล้ว กำลังกลับไปปลูกต่อ...")
        startAutoSprout()
    end
end)

-- เริ่มทำงาน
startAutoSprout()

print("✅ [AutoSprout] ระบบโหลดสำเร็จ พร้อมทำงานโดยตรง (No UI Mode)")
