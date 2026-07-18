local library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local tab = library:CreateWindow("Throw a coin")

local autoThrowEnabled = false
local autoSellAllEnabled = false
local autoUpgradeLuckEnabled = false
local autoUpgradeValueEnabled = false
local coinLandedEvent = game:GetService("ReplicatedStorage").Assets.Events.CoinLanded
local sellAllEvent = game:GetService("ReplicatedStorage").Assets.Events.SellAll
local requestUpgradeEvent = game:GetService("ReplicatedStorage").Assets.Events.RequestUpgrade

local function getEquippedCoin()
    local player = game:GetService("Players").LocalPlayer
    local coinNameLabel =
        player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("UiFolder") and
        player.PlayerGui.UiFolder:FindFirstChild("Main") and
        player.PlayerGui.UiFolder.Main:FindFirstChild("HUD") and
        player.PlayerGui.UiFolder.Main.HUD:FindFirstChild("Coin") and
        player.PlayerGui.UiFolder.Main.HUD.Coin:FindFirstChild("Main") and
        player.PlayerGui.UiFolder.Main.HUD.Coin.Main:FindFirstChild("CoinName")
    if coinNameLabel then
        return coinNameLabel.Text
    end
    return nil
end

local function startLoop(condition, callback)
    local connection
    connection =
        game:GetService("RunService").Heartbeat:Connect(
        function()
            if condition() then
                callback()
            end
        end
    )
    return connection
end

tab:AddToggle(
    {
        text = "Throw Max Luck",
        flag = "autoThrow",
        callback = function(v)
            autoThrowEnabled = v
            if v then
                local connection =
                    startLoop(
                    function()
                        return autoThrowEnabled
                    end,
                    function()
                        local coinName = getEquippedCoin()
                        if coinName then
                            coinLandedEvent:FireServer(
                                3,
                                Vector3.new(-1162.3363037109, 0.72600001096725, -176.80444335938),
                                coinName,
                                nil,
                                nil
                            )
                        end
                    end
                )
                _G.autoThrowConnection = connection
            else
                if _G.autoThrowConnection then
                    _G.autoThrowConnection:Disconnect()
                    _G.autoThrowConnection = nil
                end
            end
        end
    }
)

tab:AddToggle(
    {
        text = "Sell All",
        flag = "autoSellAll",
        callback = function(v)
            autoSellAllEnabled = v
            if v then
                local connection =
                    startLoop(
                    function()
                        return autoSellAllEnabled
                    end,
                    function()
                        sellAllEvent:FireServer()
                    end
                )
                _G.autoSellAllConnection = connection
            else
                if _G.autoSellAllConnection then
                    _G.autoSellAllConnection:Disconnect()
                    _G.autoSellAllConnection = nil
                end
            end
        end
    }
)

tab:AddToggle(
    {
        text = "Upgrade Luck",
        flag = "autoLuck",
        callback = function(v)
            autoUpgradeLuckEnabled = v
            if v then
                local connection =
                    startLoop(
                    function()
                        return autoUpgradeLuckEnabled
                    end,
                    function()
                        requestUpgradeEvent:FireServer("Luck Multiplier")
                    end
                )
                _G.autoLuckConnection = connection
            else
                if _G.autoLuckConnection then
                    _G.autoLuckConnection:Disconnect()
                    _G.autoLuckConnection = nil
                end
            end
        end
    }
)

tab:AddToggle(
    {
        text = "Upgrade Value",
        flag = "autoValue",
        callback = function(v)
            autoUpgradeValueEnabled = v
            if v then
                local connection =
                    startLoop(
                    function()
                        return autoUpgradeValueEnabled
                    end,
                    function()
                        requestUpgradeEvent:FireServer("Value Multiplier")
                    end
                )
                _G.autoValueConnection = connection
            else
                if _G.autoValueConnection then
                    _G.autoValueConnection:Disconnect()
                    _G.autoValueConnection = nil
                end
            end
        end
    }
)

tab:AddLabel(
    {
        text = "YT: Elvis Fofo",
        type = "label"
    }
)

library:Init()