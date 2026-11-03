--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Map = require(script.Map)
local Game = require(script.Game)
local remotes = Instance.new("Folder")
remotes.Name, remotes.Parent = "HouseRemotes", ReplicatedStorage
local action = Instance.new("RemoteEvent")
action.Name, action.Parent = "Action", remotes
local event = Instance.new("RemoteEvent")
event.Name, event.Parent = "Update", remotes
Game.new(Map.build(), action, event)
print("Don't Wake the House: server ready")
