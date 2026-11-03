-- Install as a local Studio plugin. Not a normal runtime Script.
local tests = game:GetService("StudioTestService")
local HttpService = game:GetService("HttpService")
local toolbar = plugin:CreateToolbar("Workflow QA")
local button = toolbar:CreateButton("Spawn test", "Run isolated spawn smoke", "")
local busy = false
button.Click:Connect(function()
    if busy then warn("Workflow test already running") return end
    busy = true
    task.spawn(function()
        local ok, result = pcall(function()
            return tests:ExecutePlayModeAsync({scenario = "spawn-smoke"})
        end)
        busy = false
        if not ok then
            warn("WORKFLOW_RESULT " .. HttpService:JSONEncode({ok = false, error = tostring(result)}))
        elseif type(result) ~= "table" or result.ok ~= true then
            warn("WORKFLOW_RESULT " .. HttpService:JSONEncode({ok = false, result = result}))
        else
            print("WORKFLOW_RESULT " .. HttpService:JSONEncode(result))
        end
    end)
end)
