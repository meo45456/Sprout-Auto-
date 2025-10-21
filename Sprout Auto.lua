-- 🌻 Bee Swarm Auto Magic Bean (Real Count Classic by Somsi & Meo)
-- ปลูกอัตโนมัติ ตรวจเวลาแบบคลาสสิก + นับจำนวน Magic Bean ที่ใช้จริง

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerActivesCommand")

-- 🗺️ พิกัดฟิลด์ทั้งหมด
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

-- 🌱 ฟังก์ชันหลัก
local function startAutoPlant()
    if not getgenv().AutoPlantConfig or not getgenv().AutoPlantConfig.EnableAutoPlant then return end

    local delay = getgenv().AutoPlantConfig.Delay
    local fields = getgenv().AutoPlantConfig.SelectedFields
    local mode = getgenv().AutoPlantConfig.Mode
    local startCount = getMagicBeanCount()
    local planted = 0

    showStatus(("✅ เริ่มปลูก Magic Bean | คงเหลือ: %d"):format(startCount), Color3.fromRGB(0,255,0))

    while getgenv().AutoPlantConfig.EnableAutoPlant do
        for _, fieldName in ipairs(fields) do
            local pos = fieldPositions[fieldName]
            if pos then
                humanoidRootPart.CFrame = CFrame.new(pos)

                if mode == "Any" then
                    Event:FireServer({ Name = "Magic Bean" })
                elseif mode == "Day" and Lighting.TimeOfDay == "13:39:00" then
                    Event:FireServer({ Name = "Magic Bean" })
                elseif mode == "Night" and Lighting.TimeOfDay == "00:20:59" then
                    Event:FireServer({ Name = "Magic Bean" })
                end

                task.wait(1)
                local nowCount = getMagicBeanCount()
                planted = math.max(startCount - nowCount, 0)
                showStatus(("🌱 ปลูกที่: %s | ปลูกไปแล้ว: %d | เหลือ: %d"):format(fieldName, planted, nowCount))
                task.wait(delay)
            end
        end
    end
end

-- 💀 ปลูกต่อหลังตาย
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    task.wait(2)
    if getgenv().AutoPlantSettings.RejoinAfterDeath then
        showStatus("🔁 กลับมาปลูกต่อ...", Color3.fromRGB(0, 200, 255))
        startAutoPlant()
    end
end)

-- ▶️ เริ่มทำงาน
startAutoPlant()
print("✅ Loaded: Bee Swarm Auto Magic Bean (Classic Real Count Version)")
