--[[ 🌱 Bee Swarm Auto Magic Bean System - by Somsi & Meo ]]
if not game:IsLoaded() then game.Loaded:Wait() end

-- ✅ อ่านค่าจาก Loader ถ้ามี
local cfg = getgenv().AutoPlantConfig or {}
local set = getgenv().AutoPlantSettings or {}

-- ค่าพื้นฐาน (ถ้าไม่มีใน getgenv)
local selectedFields = cfg.SelectedFields or { "Sunflower Field" }
local autoMode = cfg.Mode or "Any"
local autoPlantEnabled = cfg.EnableAutoPlant or false
local delayTime = cfg.Delay or 5
local enableLog = set.EnableLog or false
local rejoinAfterDeath = set.RejoinAfterDeath or true

-- โหลด UI Framework
local Version = "1.6.41"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

-- สร้างหน้าต่างหลัก
local Window = WindUI:CreateWindow({
    Title = "Bee Swarm Simulator - Auto Plant",
    Size = UDim2.fromOffset(320, 300),
    Theme = "Dark",
    SideBarWidth = 200,
    Transparent = true
})

-- Tabs
local Tabs = {
    Any = Window:Tab({ Title = "🌱 ปลูกไม่สนเวลา" }),
    Day = Window:Tab({ Title = "☀️ ปลูกตอนเช้า" }),
    Night = Window:Tab({ Title = "🌙 ปลูกตอนกลางคืน" })
}

-- ตัวแปรหลัก
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerActivesCommand")

-- รายชื่อฟิลด์ทั้งหมด
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

local fields = {}
for name, _ in pairs(fieldPositions) do table.insert(fields, name) end

-- 🌱 ฟังก์ชันปลูกอัตโนมัติ
local function startAutoPlant(mode)
    task.spawn(function()
        while autoPlantEnabled do
            for _, fieldName in ipairs(selectedFields) do
                local pos = fieldPositions[fieldName]
                if pos and humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(pos)
                    local time = Lighting.TimeOfDay

                    local canPlant = (
                        mode == "Any" or
                        (mode == "Day" and string.sub(time, 1, 2) >= "06" and string.sub(time, 1, 2) < "18") or
                        (mode == "Night" and (string.sub(time, 1, 2) < "06" or string.sub(time, 1, 2) >= "18"))
                    )

                    if canPlant then
                        Event:FireServer({ Name = "Magic Bean" })
                        if enableLog then
                            print(string.format("🌱 ปลูก Magic Bean ที่ฟิลด์: %s | โหมด: %s", fieldName, mode))
                        end
                    end

                    task.wait(delayTime)
                end
            end
        end
    end)
end

-- 🔁 เมื่อผู้เล่นตายหรือรีสปอน
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    if rejoinAfterDeath and autoPlantEnabled then
        task.wait(2)
        startAutoPlant(autoMode)
    end
end)

-- 🧭 ฟังก์ชันสร้าง UI สำหรับแต่ละแท็บ
local function setupTab(tab, modeName)
    tab:Dropdown({
        Title = "เลือกฟิลด์ที่จะปลูก",
        Values = fields,
        Value = selectedFields,
        Multi = true,
        AllowNone = true,
        Callback = function(options)
            selectedFields = options
        end
    })

    tab:Toggle({
        Title = "เปิด/ปิด Auto Plant",
        Default = (autoPlantEnabled and autoMode == modeName),
        Callback = function(state)
            autoPlantEnabled = state
            autoMode = modeName
            if state then
                startAutoPlant(modeName)
                if enableLog then
                    print("🚀 เริ่ม Auto Plant โหมด:", modeName)
                end
            else
                if enableLog then
                    print("🛑 ปิด Auto Plant โหมด:", modeName)
                end
            end
        end
    })
end

-- 🪴 สร้าง UI ทั้งสามโหมด
setupTab(Tabs.Any, "Any")
setupTab(Tabs.Day, "Day")
setupTab(Tabs.Night, "Night")

print("✅ ระบบ Auto Plant โหลดสำเร็จ! พร้อมทำงาน")
