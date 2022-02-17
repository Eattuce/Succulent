local require = GLOBAL.require
require("map/tasks")
-- 加入我的Rooms,tasks
require("map/rooms/forest/succulent_mod_rooms")
require("map/tasks/succulent_mod_tasks")
-----------------------------------------
-----------------------------------------

local LAYOUTS = require("map/layouts").Layouts
local STATICLAYOUT = require("map/static_layout")
--引入我的Static_layout,可以作为Task_set, 也可以作为Room里包含的Static_layout
LAYOUTS["totem_tech"] = STATICLAYOUT.Get("map/static_layouts/totemstuff")
LAYOUTS["Pig_guard_bush"] = STATICLAYOUT.Get("map/static_layouts/pigguarding")
--------------------------T E S T--------------------------
LAYOUTS["ttt"] = STATICLAYOUT.Get("map/static_layouts/ttt")


-----------------------------------------------------------
---------------------------RELIC---------------------------
-----------------------------------------------------------
AddTaskPreInit("Lightning Bluff", function(task) -- 绿洲沙漠 DLCtasks
    task.room_choices["TechandBush"] = 1  -- 科技是一个Static layout 放在了这个room里
end)

AddTaskSetPreInit("default", function(taskset)
    local tasks_all = {"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"--[[, "Badlands"]]}

    taskset.set_pieces["Pig_guard_bush"] = {count = 1, tasks = tasks_all}
end)

AddTaskSetPreInit("classic", function(taskset)
    taskset.set_pieces["Pig_guard_bush"] = {count = 1, tasks = taskset.tasks}
end)



-----------------------------------------------------------
--------------------------ISLAND---------------------------
-----------------------------------------------------------
-- AddTaskPreInit("Lightning Bluff",function(task)
--     task.room_choices["WormholeToRelic"] = 1
-- end)


-- AddTaskSetPreInit("default", function(taskset)
--     table.insert( taskset.tasks,"IslandRelic" )
-- end)

