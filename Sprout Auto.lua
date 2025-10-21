-- 📦 โหลดบริการหลัก
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local ItemEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPackageEvent")

-- 🗺️ ฟิลด์ทั้งหมด (พร้อมชื่อสำหรับ config)
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

-- ⏰ ฟังก์ชันตรวจเวลา
local function isDayTime()
    local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
    return hour >= 6 and hour < 18
end

local function isNightTime()
    local hour = tonumber(string.sub(Lighting.TimeOfDay, 1, 2))
    return hour < 6 or hour >= 18
end

-- 🌾 HUD แสดงสถานะกลางหน้าจอ
local function createHUD()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "AutoPlantHUD"

    local Label = Instance.new("TextLabel", ScreenGui)
    Label.Size = UDim2.new(0.5, 0, 0.06, 0)
    Label.Position = UDim2.new(0.25, 0, 0.05, 0)
    Label.BackgroundTransparency = 0.3
    Label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Label.TextColor3 = Color3.fromRGB(0, 255, 0)
    Label.TextScaled = true
    Label.Font = Enum.Font.SourceSansBold
    Label.Text = "🌱 ระบบ AutoPlant พร้อมทำงาน"

    return Label
end

local HUD = createHUD()

-- 🪴 ฟังก์ชันปลูก Magic Bean
local plantedCount = 0
local function plantMagicBean(fieldName)
    local success, err = pcall(function()
        ItemEvent:InvokeServer("Consume", {["Name"] = "Magic Bean"})
    end)

    if success then
        plantedCount += 1
        local msg = string.format("🌱 ปลูก Magic Bean #%d ที่ฟิลด์: %s", plantedCount, fieldName)
        if getgenv().AutoPlantSettings["EnableLog"] then print(msg) end
        HUD.Text = msg
    else
        warn("[AutoPlant] ❌ ปลูกไม่สำเร็จ:", err)
        HUD.Text = "❌ ปลูกไม่สำเร็จ (" .. tostring(err) .. ")"
    end
end

-- ⚙️ ฟังก์ชันหลัก (ลูปทำงาน)
task.spawn(function()
    if not getgenv().AutoPlantConfig["EnableAutoPlant"] then
        HUD.Text = "🛑 ระบบปลูกอัตโนมัติถูกปิดอยู่"
        return
    end

    while task.wait(getgenv().AutoPlantConfig["Delay"]) do
        for _, fieldName in ipairs(getgenv().AutoPlantConfig["SelectedFields"]) do
            local pos = fieldPositions[fieldName]
            if pos then
                humanoidRootPart.CFrame = CFrame.new(pos)

                local mode = getgenv().AutoPlantConfig["Mode"]
                local time = Lighting.TimeOfDay

                if mode == "Any"
                or (mode == "Day" and isDayTime())
                or (mode == "Night" and isNightTime()) then
                    plantMagicBean(fieldName)
                else
                    HUD.Text = string.format("⏳ รอเวลา (%s) | เวลาในเกม: %s", mode, time)
                end
            end
        end
    end
end)

-- 🔁 รีสปอนแล้วกลับไปปลูกต่อ
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    task.wait(2)
    if getgenv().AutoPlantSettings["RejoinAfterDeath"] then
        HUD.Text = "🔁 โหลดตัวละครใหม่ กำลังกลับไปปลูกต่อ..."
    end
end)

print("✅ [AutoPlant] ระบบปลูก Magic Bean โหลดสำเร็จ พร้อมทำงานแล้ว!")
HUD.Text = "✅ ระบบ Auto Magic Bean ทำงานเรียบร้อย!"
