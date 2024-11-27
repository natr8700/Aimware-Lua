local jitterDirection = true
local previous_positions = {}
-- 트레이서 
local function Tracer ()
    local local_player = entities.GetLocalPlayer()

    if local_player and local_player:IsAlive() then
        local position = local_player:GetAbsOrigin()
        local r = math.abs(math.sin(globals.CurTime())) * 255
        local g = math.abs(math.sin(globals.CurTime() + 2)) * 255
        local b = math.abs(math.sin(globals.CurTime() + 4)) * 255
        local start_screen = {client.WorldToScreen(position)}

        if start_screen[1] then
            for i = 1, #previous_positions do
                local prev_position = previous_positions[i]
                local finish_screen = {client.WorldToScreen(prev_position)}

                if finish_screen[1] then
                    draw.Color(r, g, b, 255)
                    draw.Line(start_screen[1], start_screen[2], finish_screen[1], finish_screen[2])
                end
            end

            table.insert(previous_positions, 1, position)
            if #previous_positions > 30 then
                table.remove(previous_positions)
            end
        end
    end
end

-- 워터마크
local DEV = 'DEV: samka8700'
local LOCAL_WATERMARK = draw.CreateFont("Verdana", 13, 900)
local font = draw.CreateFont("Tahoma", 14, 500)

local padding = 10
local corner_radius = 8
local watermark_height = 40

local function watermark()
    local size_x, size_y = draw.GetScreenSize()
    local watermarktext = "EMIWARE"
    local mapname = engine.GetMapName()
    local nickname = DEV
    watermarktext = watermarktext .. " | " .. nickname
    local ipserver = engine.GetServerIP()
    if ipserver == "loopback:1" then
        ipserver = "local server"
    end
    watermarktext = watermarktext .. " | " .. ipserver
    watermarktext = watermarktext .. " | Map: " .. mapname
    draw.SetFont(font)
    local text_width, text_height = draw.GetTextSize(watermarktext)
    local watermark_width = text_width + padding * 2
    local x, y = size_x - watermark_width - padding, padding
    local time = globals.RealTime()
    local r = math.abs(math.sin(time * 0.2)) * 255
    local g = math.abs(math.sin(time * 0.2 + 2)) * 255
    local b = math.abs(math.sin(time * 0.2 + 4)) * 255
    local bg_color = {0, 0, 0, 200}
    draw.Color(bg_color[1], bg_color[2], bg_color[3], bg_color[4])

    draw.RoundedRectFill(x, y, x + watermark_width, y + watermark_height, corner_radius)

    local glow_color = {r, g, b, 80}
    draw.Color(glow_color[1], glow_color[2], glow_color[3], glow_color[4])
    for i = 1, 5 do
        draw.RoundedRect(x - i, y - i, x + watermark_width + i, y + watermark_height + i, corner_radius + i)
    end

    draw.Color(r, g, b, 255) 
    draw.Text(x + padding, y + (watermark_height - text_height) / 2, watermarktext)
end

callbacks.Register("Draw", watermark)

-- 안티에임
local ANTIAIM_set = gui.Window("Anti Aim", "Anti Aim", 600, 100, 550, 500)
local MASTER_CHECKBOX = gui.Checkbox(ANTIAIM_set, "enable", "Enable", false)
local ANTI_AIM_SETTINGS_BOX = gui.Groupbox(ANTIAIM_set, "Settings", 10, 60, 520, 550)
local ANTI_AIM_STYLE = gui.Combobox(ANTI_AIM_SETTINGS_BOX, "Style", "Style", "Standard", "Jitter")
local YAW_JITTER_CONTROL_BOX = gui.Groupbox(ANTI_AIM_SETTINGS_BOX, "Yaw Jitter", 0, 70, 500, 300)
local YAW_JITTER_ENABLE_CHECKBOX = gui.Checkbox(YAW_JITTER_CONTROL_BOX, "yaw jitter enable", "Enable", false)
local YAW_JITTER_LEFT_SLIDER = gui.Slider(YAW_JITTER_CONTROL_BOX, "yaw jitter left", "Yaw Jitter Left", 40, 0, 90)
local YAW_JITTER_RIGHT_SLIDER = gui.Slider(YAW_JITTER_CONTROL_BOX, "yaw jitter right", "Yaw Jitter Right", 45, 0, 90)
local YAW_JITTER_BACKWARD_CHECKBOX = gui.Checkbox(YAW_JITTER_CONTROL_BOX, "yaw_jitter_backward", "Yaw Jitter Backward", false)
local YAW_JITTER_SPEED_SLIDER = gui.Slider(YAW_JITTER_CONTROL_BOX, "yaw jitter speed", "Yaw Jitter Speed", 1, 1, 32)


local function HandStyle()
    local style = ANTI_AIM_STYLE:GetValue()
    if MASTER_CHECKBOX:GetValue() then
        if style == 0 then
            gui.SetValue("rbot.antiaim.base", 180)
            gui.SetValue("rbot.antiaim.advanced.pitch", 0)
            gui.SetValue("rbot.antiaim.advanced.yaw", 0) 

        elseif style == 1 then
            gui.SetValue("rbot.antiaim.base.rotation", (globals.TickCount() % 360))
            gui.SetValue("rbot.antiaim.advanced.pitch", 0)
            gui.SetValue("rbot.antiaim.advanced.yaw", 0)

        elseif style == 2 then
            if YAW_JITTER_ENABLE_CHECKBOX:GetValue() then
                local yawValue = jitterDirection and YAW_JITTER_LEFT_SLIDER:GetValue() or -YAW_JITTER_RIGHT_SLIDER:GetValue()
                gui.SetValue("rbot.antiaim.base", yawValue)
                jitterDirection = not jitterDirection
            else
                gui.SetValue("rbot.antiaim.base", 180)
            end
            gui.SetValue("rbot.antiaim.advanced.pitch", 0) 
            gui.SetValue("rbot.antiaim.advanced.yaw", 0)
        end
    else
        gui.SetValue("rbot.antiaim.base", 0)
        gui.SetValue("rbot.antiaim.base.rotation", 0)
        gui.SetValue("rbot.antiaim.advanced.pitch", 0)
        gui.SetValue("rbot.antiaim.advanced.yaw", 0)
    end
end

-- 자동구매봇
local BuyBot = gui.Window("buybot", "Buybot", 300, 100, 550, 320) 
local AUTO_BUY_SETTINGS_BOX = gui.Groupbox(BuyBot, "Settings", 10, 10, 520, 100)
local AUTO_BUY_ENABLE = gui.Checkbox(AUTO_BUY_SETTINGS_BOX, "enable", "Enable", false)
local AUTO_BUY_PRIMARY = gui.Combobox(AUTO_BUY_SETTINGS_BOX, "primary", "Primary Weapon", "None", "AK-47/M4", "AWP", "Scout")
local AUTO_BUY_SECONDARY = gui.Combobox(AUTO_BUY_SETTINGS_BOX, "secondary", "Secondary Weapon", "None", "Deagle", "P250", "Tec-9")
local AUTO_BUY_ARMOR = gui.Checkbox(AUTO_BUY_SETTINGS_BOX, "armor", "Buy Armor", true)
local AUTO_BUY_KIT = gui.Checkbox(AUTO_BUY_SETTINGS_BOX, "kit", "Buy Defuse Kit", true)
local function buybot()
    if AUTO_BUY_ENABLE:GetValue() then
        local buy_commands = {}

        if AUTO_BUY_PRIMARY:GetValue() == 1 then
            table.insert(buy_commands, "buy ak47")
        elseif AUTO_BUY_PRIMARY:GetValue() == 2 then
            table.insert(buy_commands, "buy awp")
        elseif AUTO_BUY_PRIMARY:GetValue() == 3 then
            table.insert(buy_commands, "buy ssg08")
        end

        if AUTO_BUY_SECONDARY:GetValue() == 1 then
            table.insert(buy_commands, "buy deagle")
        elseif AUTO_BUY_SECONDARY:GetValue() == 2 then
            table.insert(buy_commands, "buy p250")
        elseif AUTO_BUY_SECONDARY:GetValue() == 3 then
            table.insert(buy_commands, "buy tec9")
        end

        if AUTO_BUY_ARMOR:GetValue() then
            table.insert(buy_commands, "buy vesthelm")
        end

        if AUTO_BUY_KIT:GetValue() then
            table.insert(buy_commands, "buy defuser")
        end

        for _, command in ipairs(buy_commands) do
            client.Command(command, true)
        end
    end
end


local function toggle_window()
    if input.IsButtonPressed(45) then  -- F9
        local is_antiaim_open = not ANTIAIM_set:IsActive()
        ANTIAIM_set:SetActive(is_antiaim_open)

        local is_buybot_open = not BuyBot:IsActive()
        BuyBot:SetActive(is_buybot_open)
    end
end

callbacks.Register("Draw", Tracer)
callbacks.Register("Draw", HandStyle)
callbacks.Register("Draw", toggle_window)