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
                local r = 0
                if (isNotDoors() and canSolve("158005")) or
                  (Tracker:ProviderCountForCode("Outside Tutorial Optional Door")>0)
                  then r =  regions["overworld"].value end
                if r < 2 and (Tracker:ProviderCountForCode("Outside Tutorial Outpost Entry Door")>0)
                  then r = math.max(r, regions["tutorialOutpostPathInterior"].value) end
                return r
            end
    },
    ["tutorialOutpostInterior"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (isNotDoors() and hasPanel("Tutorial Outpost Entry (Panel)") and canSolve("158011")) or
                  (Tracker:ProviderCountForCode("Outside Tutorial Outpost Entry Door")>0)
                  then r = regions["tutorialOutpostPath"].value end
                if r < 2 and (Tracker:ProviderCountForCode("Outside Tutorial Outpost Exit Door")>0)
                  then r = math.max(r, regions["overworld"].value) end
                return r
            end
    },
    ["orchardInner"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (Tracker:ProviderCountForCode("unrandomized")>0 and isNotDoors()) or
                   (Tracker:ProviderCountForCode("Orchard Middle Gate")>0) then r = regions["overworld"].value end
                if r < 2 and (Tracker:ProviderCountForCode("showSnipes")>0 and unrandomizedDisabledButSolvable() and regions["overworld"].value > 0) then r = 1 end
                return r
            end
    },
    ["orchardHeart"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (Tracker:ProviderCountForCode("unrandomized")>0 and isNotDoors()) or
                   (Tracker:ProviderCountForCode("Orchard Final Gate")>0) then r = regions["orchardInner"].value end
                if r < 2 and(Tracker:ProviderCountForCode("showSnipes")>0 and unrandomizedDisabledButSolvable() and regions["orchardInner"].value > 0) then r = 1 end
                return r
            end
    },
    ["glassFactory"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (isNotDoors() and hasPanel("Glass Factory Entry (Panel)") and canSolve("158027")) or
                   (Tracker:ProviderCountForCode("Glass Factory Entry Door")>0) then r = regions["overworld"].value end
                if r < 2 and (Tracker:ProviderCountForCode("Glass Factory Back Wall")>0) then r = math.max(r, regions["ocean"].value) end
                return r
            end
    },
    ["symmetryOuter"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (Tracker:ProviderCountForCode("DoorsNo")>0 and canSolve("158040") and canSolve("158036-158038") and regions["glassFactory"].value == 2) or
                (isNotDoors() and Tracker:ProviderCountForCode("Door to Symmetry Island Lower (Panel)")>0 and canSolve("158040")) or
                (Tracker:ProviderCountForCode("Symmetry Island Lower Door")>0) then r =  regions["overworld"].value end
                if r < 2 and (Tracker:ProviderCountForCode("DoorsNo")>0 and canSolve("158040") and canSolve("158036-158038") and regions["overworld"].value > 0) then r = 1 end
                return r
            end
    },
    ["symmetryInner"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (isNotDoors() and isNotPanelsOnlyOrHasPanel("Door to Symmetry Island Lower (Panel)") and canSolve("158041-158058") and canSolve("158064")) or
                (Tracker:ProviderCountForCode("Symmetry Island Upper Door")>0) then r = regions["symmetryOuter"].value end
                return r
            end
    },
    ["desertFloodLight"] = {
        value = 0,
        connections =
            function() 
                if (isNotDoors() and hasPanel("Desert Light Room Entry (Panel)")) or
                (Tracker:ProviderCountForCode("Desert Door to Light Room")>0) then r = regions["overworld"].value end
                if r < 2 and (Tracker:ProviderCountForCode("Desert Door to Pond Room")>0) then r = math.max(r, regions["desertPond"].value) end
                return r
            end
    },
    ["desertPond"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (isNotDoors() and hasPanel("Desert Light Room Light Control (Panel)")) or
                (Tracker:ProviderCountForCode("Desert Door to Pond Room")>0) then r =  regions["desertFloodLight"].value end
                if r < 2 and (Tracker:ProviderCountForCode("Desert Door to Flood Room")>0) then r =  math.max(r, regions["desertFlood"].value) end
                return r
            end
    },
    ["desertFlood"] = {
        value = 0,
        connections =
            function() 
                if (isNotDoors() and hasPanel("Desert Flood Room Entry (Panel)")) or
                (Tracker:ProviderCountForCode("Desert Door to Flood Room")>0) then r = regions["desertPond"].value end
                if r < 2 and (Tracker:ProviderCountForCode("Desert Door to Elevator Room")>0) then r = math.max(r, regions["desertLaser"].value) end
                return r
            end
    },
    ["desertLaser"] = {
        value = 0,
        connections =
            function() 
                local r = 0
                if (isNotDoors() and hasPanel("Desert Flood Room Flood Controls (Panel)")) or
                  (Tracker:ProviderCountForCode("Desert Door to Elevator Room")>0) then r = regions["desertFlood"].value end
                if r < 2 and (isNotDoors() and Tracker:ProviderCountForCode("Desert Elevator Door")>0) or
                  (Tracker:ProviderCountForCode("Desert Elevator Door")>0 and Tracker:ProviderCountForCode("Theater Walkway Door to Desert Elevator Room")>0) then r = math.max(r, regions["tunnels"].value) end
                if r < 2 and (isNotDoors() and regions["desertFlood"].value>0) then r = 1 end
                return r
            end
    },
    ["tunnels"] = {
        value = 0,
        connections = function() return 0 end
    }

}

regions[startLocation].value = 2

function reset()
    for k, v in pairs(regions) do
        regions[k].value = 0
    end
    regions[startLocation].value = 2
end

function region(regionName, v)
    print(regionName, v, regions[regionName].value)
    return regions[regionName].value >= tonumber(v)
end

function check()
    reset()
    sweep()
    return true
end

function sweep()
    local madeChanges = false

    for place, v in pairs(regions) do
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
