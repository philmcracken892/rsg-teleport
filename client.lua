
local RSGCore = exports['rsg-core']:GetCoreObject()

local prompts = {}
local createdBlips = {}


local function CreateBlip(blipData)
    local blip = N_0x554d9d53f696d002(1664425300, blipData.x, blipData.y, blipData.z)
    SetBlipSprite(blip, blipData.sprite, 1)
    SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipData.name)
    if blipData.color then 
        BlipAddModifier(blip, joaat(blipData.color)) 
    end
    return blip
end


local function CreateTeleportPrompt(text)
    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, Config.PromptKey)
    PromptSetText(prompt, Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", text, Citizen.ResultAsLong()))
    PromptSetEnabled(prompt, false)
    PromptSetVisible(prompt, false)
    
    if Config.UseHoldMode then
        PromptSetHoldMode(prompt, true)
    else
        PromptSetStandardMode(prompt, true)
    end
    
    PromptRegisterEnd(prompt)
    return prompt
end


local function TeleportPlayer(coords, heading)
    local ped = PlayerPedId()
    
    if Config.UseFadeEffect then
        DoScreenFadeOut(Config.FadeDuration)
        Citizen.Wait(Config.FadeDuration)
    end
    
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    
    if heading then
        SetEntityHeading(ped, heading)
    end
    
    if Config.UseFadeEffect then
        Citizen.Wait(Config.FadeDuration)
        DoScreenFadeIn(Config.FadeDuration)
    end
end


Citizen.CreateThread(function()
    Citizen.Wait(1000)
    
    for _, location in ipairs(Config.Locations) do
        
        local enterPrompt = CreateTeleportPrompt(location.enterPrompt)
        table.insert(prompts, {
            prompt = enterPrompt,
            coords = location.enterPos,
            targetCoords = location.exitPos,
            targetHeading = location.enterHeading,
            name = location.name .. "_enter"
        })
        
       
        local exitPrompt = CreateTeleportPrompt(location.exitPrompt)
        table.insert(prompts, {
            prompt = exitPrompt,
            coords = location.exitPos,
            targetCoords = location.enterPos,
            targetHeading = location.exitHeading,
            name = location.name .. "_exit"
        })
        
        
        if location.showBlip and location.blip then
            local blip = CreateBlip(location.blip)
            table.insert(createdBlips, blip)
        end
    end
    
    
end)


Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, entry in ipairs(prompts) do
            if entry.prompt then
                local dist = #(playerCoords - entry.coords)
                
                if dist <= Config.InteractionDistance then
                    sleep = 0
                    PromptSetEnabled(entry.prompt, true)
                    PromptSetVisible(entry.prompt, true)
                    
                    local completed = false
                    if Config.UseHoldMode then
                        completed = PromptHasHoldModeCompleted(entry.prompt)
                    else
                        completed = PromptHasStandardModeCompleted(entry.prompt)
                    end
                    
                    if completed then
                        TeleportPlayer(entry.targetCoords, entry.targetHeading)
                        Citizen.Wait(500)
                    end
                else
                    PromptSetEnabled(entry.prompt, false)
                    PromptSetVisible(entry.prompt, false)
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)


AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, entry in ipairs(prompts) do
            if entry.prompt then
                PromptSetEnabled(entry.prompt, false)
                PromptSetVisible(entry.prompt, false)
            end
        end
        
        for _, blip in ipairs(createdBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        
        
    end
end)