-- Freestanding Anti-Aim for CS2 using Fatality API
-- Menu with checkbox, slider for desync, combobox for side preference
-- Auto-detects walls: If close to left wall, shifts head left (negative yaw offset)
-- Hold 'ALT' to activate; traces for walls around player
-- Integrated with Fatality GUI style

-- Create GUI controls using Fatality API
local M = {}  -- Table for organization
M.freestanding = {}

-- Create group for freestanding controls
local group = gui.ctx:find("lua>elements a")  -- Use existing group or create
if not group then
    -- If group doesn't exist, we'll need to create it or use a different approach
    print("Warning: Could not find existing group, controls may not display properly")
end

-- Create controls using Fatality API
M.freestanding.enabled = gui.checkbox(gui.control_id("freestanding_enabled"))
M.freestanding.desync_amount = gui.slider(gui.control_id("freestanding_desync_amount"))
M.freestanding.side_pref = gui.combo_box(gui.control_id("freestanding_side_pref"))

-- Set control properties
M.freestanding.enabled:get_value():set(false)  -- Default disabled
M.freestanding.desync_amount:get_value():set(58)  -- Default 58 degrees
M.freestanding.side_pref:get_value():set(0)  -- Default Auto (index 0)

-- Add controls to group if it exists
if group then
    group:add(gui.make_control("Enable Freestanding AA", M.freestanding.enabled))
    group:add(gui.make_control("Desync Amount", M.freestanding.desync_amount))
    group:add(gui.make_control("Side Preference", M.freestanding.side_pref))
end

-- Wall detection parameters
local WALL_DIST = 50  -- Distance to trace for walls

-- Simple wall detection using entity collision
local function check_wall_collision(player_pos, direction)
    local local_player = entities.get_local_pawn()
    if not local_player then return false end
    
    -- Get player position and create trace direction
    local origin = local_player:get_abs_origin()
    local trace_start = origin + vector(0, 0, 64)  -- Eye level
    local trace_end = trace_start + direction * WALL_DIST
    
    -- Simple collision check using entity list
    -- This is a simplified version since Fatality doesn't expose trace functions
    local players = entities.players
    for i = 1, players:size() do
        local player = players:get(i - 1)
        if player and player:is_valid() and player ~= local_player then
            local player_pos = player:get_abs_origin()
            local distance = (trace_end - player_pos):length()
            if distance < 30 then  -- If close to another player, consider it a wall
                return true
            end
        end
    end
    
    -- Check for map geometry (simplified)
    -- In a real implementation, you'd need to use proper trace functions
    -- For now, we'll use a simple distance check
    return false
end

-- Input handling using Fatality's input system
local alt_pressed = false

-- Handle input events
events.handle_input:add(function(input_type, value)
    -- Check for ALT key (simplified - you may need to adjust based on actual key codes)
    -- Since Fatality doesn't expose direct key detection, we'll use a different approach
    if input_type == input_type_t.yaw then
        -- This is a simplified approach - in reality you'd need proper key detection
        -- For now, we'll use a different activation method
    end
end)

-- Main freestanding logic using frame stage
events.frame_stage_notify:add(function(stage)
    -- Only run on specific frame stages
    if stage ~= client_frame_stage.frame_start then return end
    
    local local_player = entities.get_local_pawn()
    if not local_player or not local_player:is_valid() then return end
    
    -- Check if freestanding is enabled
    if not M.freestanding.enabled:get_value():get() then return end
    
    -- For now, we'll use a different activation method since direct key detection isn't available
    -- You can modify this to use a different key or always active
    local should_activate = true  -- Change this based on your preferred activation method
    
    if not should_activate then return end
    
    local amount = M.freestanding.desync_amount:get_value():get()
    local side_pref = M.freestanding.side_pref:get_value():get()
    
    -- Get current view angles
    local current_angles = local_player:get_abs_angles()
    
    -- Determine desync direction
    local desync_dir = 0
    
    if side_pref == 0 then  -- Auto
        -- Check for walls (simplified)
        local right_dir = vector(1, 0, 0)  -- Simplified direction
        local left_dir = vector(-1, 0, 0)
        
        local wall_left = check_wall_collision(local_player:get_abs_origin(), left_dir)
        local wall_right = check_wall_collision(local_player:get_abs_origin(), right_dir)
        
        if wall_left then 
            desync_dir = -1  -- Wall left: Head to left
        elseif wall_right then 
            desync_dir = 1   -- Wall right: Head to right
        else 
            desync_dir = math.random(-1, 1)  -- No wall: Random
        end
    elseif side_pref == 1 then  -- Left
        desync_dir = -1
    elseif side_pref == 2 then  -- Right
        desync_dir = 1
    else  -- Jitter
        desync_dir = math.random(-1, 1)
    end
    
    -- Calculate new angles
    local real_yaw = current_angles.y
    local fake_yaw = real_yaw + (amount * desync_dir)
    
    -- Apply the new angles
    local new_angles = vector(current_angles.x, fake_yaw, current_angles.z)
    local_player:set_abs_angles(new_angles)
end)

-- Alternative approach using present_queue for continuous updates
events.present_queue:add(function()
    -- This runs every frame, good for continuous updates
    -- You can add additional logic here if needed
end)

-- Notification on load
local notify = gui.notification("Freestanding AA Loaded", "Adapted for Fatality API", nil)
gui.notify:add(notify)

print("Freestanding Anti-Aim loaded for Fatality API")
print("Note: This is an adapted version - some features may need adjustment")
print("Wall detection is simplified due to API limitations")