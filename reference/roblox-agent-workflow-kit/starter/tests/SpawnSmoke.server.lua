-- Test-only fixture. Exclude this script from production project mappings.
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end
local tests = game:GetService("StudioTestService")
local args = tests:GetTestArgs()
if type(args) ~= "table" or args.scenario ~= "spawn-smoke" then return end
local Players = game:GetService("Players")
local completed = false
local function finish(result)
    if completed then return end
    completed = true
    tests:EndTest(result)
end
task.delay(40, function()
    finish({ok = false, scenario = "spawn-smoke", error = "overall timeout"})
end)
local ok, problem = pcall(function()
    local deadline = os.clock() + 30
    local ready = false
    repeat
        for _, player in Players:GetPlayers() do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and root then
                ready = true
                break
            end
        end
        if not ready then task.wait(0.1) end
    until ready or os.clock() >= deadline
    assert(ready, "No live player character with HumanoidRootPart within 30 seconds")
end)
finish({ok = ok, scenario = "spawn-smoke", error = if ok then "" else tostring(problem)})
