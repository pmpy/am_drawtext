local Keys, displayData, displayCallback = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACK"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LCTRL"] = 36, ["LALT"] = 19, ["SPACE"] = 22, ["RCTRL"] = 70,
	["HOME"] = 213, ["PGUP"] = 10, ["PGDOWN"] = 11, ["DEL"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}, nil, nil

displayExistingText = function()
    SendNUIMessage({
        id = "drawtext",
        func = "show",
        radarOn = IsRadarEnabled(),
        displayData = displayData
    })
end

displayText = function(title, description, key, secondKey, cb)
	if not Keys[key] or (secondKey and not Keys[secondKey]) then return end
	local alreadyDisplaying = displayData ~= nil
	local displayHidden = false

    displayData = {
        title = title,
        description = description,
        key = key,
        secondKey = secondKey
    }
    displayCallback = cb

    SendNUIMessage({
        id = "drawtext",
        func = alreadyDisplaying and "update" or "show",
        radarOn = IsRadarEnabled(),
        displayData = displayData
    })

    if not alreadyDisplaying then
        CreateThread(function()
            local previousRadarState = IsRadarEnabled()

            while displayData do
                if not displayHidden and IsPauseMenuActive() then
                    hideText(true)
                    displayHidden = true
                elseif displayHidden and not IsPauseMenuActive() then
                    CreateThread(function()
                        Wait(1)
                        displayExistingText()
                        displayHidden = false
                    end)
                end

                if IsRadarEnabled() ~= previousRadarState then
                    previousRadarState = IsRadarEnabled()

                    SendNUIMessage({
                        id = "drawtext",
                        func = "checkLocation",
                        radarOn = IsRadarEnabled()
                    })
                end

                Wait(250)
            end
        end)

        CreateThread(function()
            function pressed(keyPress, pressing)
                return (not IsPauseMenuActive()) and (IsControlJustPressed(0, Keys[keyPress]) or IsDisabledControlJustPressed(0, Keys[keyPress])) or (pressing and (IsControlPressed(0, Keys[keyPress]) or IsDisabledControlPressed(0, Keys[keyPress])))
            end

            while displayData do
                if pressed(displayData.key) and not displayData.secondKey then
                    displayCallback()
                elseif pressed(displayData.key, true) and (displayData.secondKey and pressed(displayData.secondKey)) then
                    displayCallback()
                end

                Wait(0)
            end
        end)
    end
end

hideText = function(dontKeepData)
	SendNUIMessage({
        id = "drawtext",
        func = "hide"
    })

	if not dontKeepData then displayData = nil end
end

exports("displayText", displayText)
exports("hideText", hideText)