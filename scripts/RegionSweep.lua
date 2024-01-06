require("logic")

local regions

local startLocation = "overworld"
regions = {
    ["overworld"] = {
        value = 0,
        connections = function() return 2 end
    },
    ["tutorial"] = {
        value = 0,
        connections = function() return 2 end
    },
    ["ocean"] = {
        value = 0,
        connections =
            function() 
                if Tracker:ProviderCountForCode("boat") > 0 then return 2 else return 0 end
            end
    },
    ["tutorialOutpostPath"] = {
        value = 0,
        connections =
            function() 
                if (isNotDoors() and canSolve("158005")) or
                  (Tracker:ProviderCountForCode("Outside Tutorial Optional Door")>0)
                  then return regions["overworld"].value 
                elseif (Tracker:ProviderCountForCode("Outside Tutorial Outpost Entry Door")>0)
                  then return regions["tutorialOutpostPathInterior"].value
                else return 0 end
            end
    },
    ["tutorialOutpostInterior"] = {
        value = 0,
        connections =
            function() 
                if (isNotDoors() and hasPanel("Tutorial Outpost Entry (Panel)") and canSolve("158011")) or
                  (Tracker:ProviderCountForCode("Outside Tutorial Outpost Entry Door")>0)
                  then return regions["tutorialOutpostPath"].value 
                elseif (Tracker:ProviderCountForCode("Outside Tutorial Outpost Exit Door")>0)
                  then return regions["overworld"].value
                else return 0 end
            end
    },
    ["orchardInner"] = {
        value = 0,
        connections =
            function() 
                if (Tracker:ProviderCountForCode("unrandomized")>0 and isNotDoors()) or
                   (Tracker:ProviderCountForCode("Orchard Middle Gate")>0) then return regions["overworld"].value
                elseif (Tracker:ProviderCountForCode("showSnipes")>0 and unrandomizedDisabledButSolvable() and regions["overworld"].value > 0) then return 1
                else return 0 end
            end
    },
    ["orchardHeart"] = {
        value = 0,
        connections =
            function() 
                if (Tracker:ProviderCountForCode("unrandomized")>0 and isNotDoors()) or
                   (Tracker:ProviderCountForCode("Orchard Final Gate")>0) then return regions["orchardInner"].value
                elseif (Tracker:ProviderCountForCode("showSnipes")>0 and unrandomizedDisabledButSolvable() and regions["orchardInner"].value > 0) then return 1
                else return 0 end
            end
    },
    ["glassFactory"] = {
        value = 0,
        connections =
            function() 
                if (isNotDoors() and hasPanel("Glass Factory Entry (Panel)") and canSolve("158027")) or
                   (Tracker:ProviderCountForCode("Glass Factory Entry Door")>0) then return regions["overworld"].value
                elseif (Tracker:ProviderCountForCode("Glass Factory Back Wall")>0) then return regions["ocean"].value
                else return 0 end
            end
    },
}

regions[startLocation].value = 2

function reset()
    for k, v in pairs(regions) do
        regions[k].value = 0
    end
    regions[startLocation].value = 2
end

function region(regionName, v)
    return regions[regionName].value == v
end

function check()
    reset()
    sweep()
    return true
end

function sweep()
    local madeChanges = false

    for place, v in pairs(regions) do
        print(place, v.value)
        local newValue = v.connections()
        if v.value ~= newValue then
            v.value = newValue
            madeChanges = true
        end
    end
    
    if madeChanges then
        sweep()
    end

    return true
end
