--[[ 🌱 Bee Swarm Auto Sprout System - Smart Load v3 (by Somsi & Meo, 2025 Final Fix) ]]
if not game:IsLoaded() then game.Loaded:Wait() end

-- ✅ โหลด config จาก Loader
local cfg = getgenv().AutoPlantConfig or {}
local set = getgenv().AutoPlantSettings or {}

local selectedFields = cfg.SelectedFields or { "Sunflower Field" }
local autoMode = cfg.Mode or "Any"
local autoPlantEnabled = cfg.EnableAutoPlant or false
local delayTime = cfg.Delay or 5
local enableLog = set.EnableLog or false
local rejoinAfterDeath = set.RejoinAfterDeath or true

-- 🧩 โหลด WindUI Framework
local Version = "1.6.41"
local WindUILoader = "https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet(WindUILoader))()
end)
if not success then
    warn("[AutoSprout] ❌ โหลด WindUI ไม่สำเร็จ:", WindUI)
    return
end

-- 🪟 สร้างหน้าต่างหลัก (เพิ่ม Folder เพื่อป้องกัน config error)
local Window = WindUI:CreateWindow({
    Title = "🌱 Bee Swarm Simulator - Auto Sprout",
    Size = UDim2.fromOffset(340, 310),
    Theme = "Dark",
    SideBarWidth = 200,
    Transparent = true,
    Folder = "SproutAutoConfig", -- ✅ Fix: WindUI ต้องการ Folder
    HideSearchBar = true,
    ScrollBarEnabled = false
})

-- 🧭 แท็บ
local Tabs = {
    Any = Window:Tab({ Title = "🌱 ใช้ Sprout ทุกเวลา" }),
    Day = Window:Tab({ Title = "☀️ ใช้เฉพาะกลางวัน" }),
    Night = Window:Tab({ Title = "🌙 ใช้เฉพาะกลางคืน" })
}

-- 🔧 ตัวแปรหลักในเกม
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

local fields = {}
for name, _ in pairs(fieldPositions) do table.insert(fields, name) end

-- 🌱 ฟังก์ชันปลูก Sprout
local function startAutoSprout(mode)
    task.spawn(function()
        while autoPlantEnabled do
            for _, fieldName in ipairs(selectedFields) do
                local pos = fieldPositions[fieldName]
                if pos and humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(pos)
                    local time = Lighting.TimeOfDay
                    local canUse = (
                        mode == "Any" or
                        (mode == "Day" and string.sub(time, 1, 2) >= "06" and string.sub(time, 1, 2) < "18") or
                        (mode == "Night" and (string.sub(time, 1, 2) < "06" or string.sub(time, 1, 2) >= "18"))
                    )

                    if canUse then
                        Event:FireServer({ Name = "Sprout" })
                        if enableLog then
                            print(string.format("🌾 ใช้ Sprout ที่ฟิลด์: %s | โหมด: %s", fieldName, mode))
                        end
                    end
                    task.wait(delayTime)
                end
            end
        end
    end)
end

-- ♻️ ใช้งานต่อหลังตาย
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    if rejoinAfterDeath and autoPlantEnabled then
        task.wait(2)
        startAutoSprout(autoMode)
        if enableLog then print("♻️ ตัวละครรีสปอน — ใช้งานต่ออัตโนมัติ") end
    end
end)

-- 🧭 สร้าง UI Tab
local function setupTab(tab, modeName)
    tab:Dropdown({
        Title = "เลือกฟิลด์สำหรับ Sprout",
        Values = fields,
        Value = selectedFields,
        Multi = true,
        AllowNone = true,
        Callback = function(options)
            selectedFields = options
        end
    })

    tab:Toggle({
        Title = "เปิด/ปิด Auto Sprout",
        Default = (autoPlantEnabled and autoMode == modeName),
        Callback = function(state)
            autoPlantEnabled = state
            autoMode = modeName
            if state then
                startAutoSprout(modeName)
                if enableLog then print("🚀 เปิด Auto Sprout โหมด:", modeName) end
            else
                if enableLog then print("🛑 ปิด Auto Sprout โหมด:", modeName) end
            end
        end
    })
end

setupTab(Tabs.Any, "Any")
setupTab(Tabs.Day, "Day")
setupTab(Tabs.Night, "Night")

-- ✅ Smart Load v3: ปลอดภัยต่อ WindUI ทุกเวอร์ชัน
task.spawn(function()
    repeat task.wait(0.3) until Tabs.Any and Tabs.Day and Tabs.Night
    task.wait(1) -- รอให้ UI สร้างเสร็จจริง

    if autoPlantEnabled then
        startAutoSprout(autoMode)
        if enableLog then
            print("🌱 [SmartLoad] UI โหลดครบ → เริ่ม Auto Sprout อัตโนมัติ | โหมด:", autoMode)
        end
    else
        if enableLog then
            print("🕓 [SmartLoad] UI โหลดครบแล้ว แต่ EnableAutoPlant = false")
        end
    end
end)

print("✅ ระบบ Auto Sprout โหลดสำเร็จ! พร้อมทำงาน (Smart Load v3)")
