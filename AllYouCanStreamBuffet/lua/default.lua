-- 5K pump adaptation - Step 1 Input System

local InputSystem = {}

function InputSystem:new()
    local obj = {
        input = {},
        lastInputTime = os.time(),
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function InputSystem:processInput(input)
    local currentTime = os.time()
    if currentTime - self.lastInputTime > 1 then
        self.input = input
        self.lastInputTime = currentTime
    end
end

function InputSystem:getInput()
    return self.input
end

return InputSystem;
