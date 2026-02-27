local goty2_keys = { 
    { LEFT,  DOWN_LEFT, CENTER,  DOWN_RIGHT, RIGHT }, -- Player 1
    { LEFT,  DOWN_LEFT, CENTER,  DOWN_RIGHT, RIGHT }, -- Player 2
}

local goty2_stream_dirs = { 90, 45, 0, -45, -90 }
local goty2_stream_axs = { -128, -64, 0, 64, 128 }

local function InputHandler(player, button)
    if player == 1 then
        -- Handle input for Player 1
        if button == goty2_keys[1][1] then
            -- Handle Left
        elseif button == goty2_keys[1][2] then
            -- Handle Down Left
        elseif button == goty2_keys[1][3] then
            -- Handle Center
        elseif button == goty2_keys[1][4] then
            -- Handle Down Right
        elseif button == goty2_keys[1][5] then
            -- Handle Right
        end
    elseif player == 2 then
        -- Handle input for Player 2
        if button == goty2_keys[2][1] then
            -- Handle Left
        elseif button == goty2_keys[2][2] then
            -- Handle Down Left
        elseif button == goty2_keys[2][3] then
            -- Handle Center
        elseif button == goty2_keys[2][4] then
            -- Handle Down Right
        elseif button == goty2_keys[2][5] then
            -- Handle Right
        end
    end
end

-- Patterns adapted to values 1-5

function gameLogic()
    while true do
        -- Update game logic for 5 buttons per player
        local input1 = getPlayerInput(1)
        local input2 = getPlayerInput(2)
        InputHandler(1, input1)
        InputHandler(2, input2)
    end
end