AddRooom("Test", {
    colour={r=0,g=0,b=0,a=0},
    value = WORLD_TILES.SAVANNA,
    contents = {
        distributepercent = 0.05,
        distributeprefabs = {
            meatrack = 0.5,
        }
    },
})

AddRooom("bg_Test", {
    colour={r=0,g=0,b=0,a=0},
    value = WORLD_TILES.SAVANNA,
    tags = {"ExitPiece", "Cheaster_Eyebone"},
    contents = {
        distributepercent = 0.25,
        distributeprefabs = {
            meatrack = 0.5,
            flower = 0.9,
            spiderden = 0.01,
        }
    },
})