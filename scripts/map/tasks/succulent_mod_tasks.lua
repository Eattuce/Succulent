
AddTask("IslandRelic", {
	locks={LOCKS.NONE},
	keys_given={},
	region_id = "island2",
	level_set_piece_blocker = true,
	room_tags = {"RoadPoison", "not_mainland"},
    room_choices =
    {
        ["TechandBush"] = 1,
        -- ["WormholeToRelic"] = 1,
    },
    room_bg = GROUND.DIRT,
    background_room = "BGBadlands",
	cove_room_name = "Blank",
    make_loop = true,
	crosslink_factor = 2,
	cove_room_chance = 1,
	cove_room_max_edges = 2,
    colour={r=0.6,g=0.6,b=0.0,a=1},
})



-------------------------T E S T---------------------------
AddTask("SecondDragon", {
    locks={LOCKS.ARCHIVE},
    keys_given={},--{KEYS.PICKAXE, KEYS.TIER2},
    room_choices={
        ["DragonflyArena"] = 1,
    },
    room_bg=GROUND.DIRT,
    background_room="BGBadlands",
    colour={r=.05,g=.5,b=.05,a=1},
})
