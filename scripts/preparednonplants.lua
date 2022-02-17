
local items_plants =
{
    dewdrop =
    {
        test = function(cooker, names, tags)
            return (names.succulent_picked and names.succulent_picked >=1)
                    and (names.saltrock and names.saltrock >= 1) and names.nightmarefuel
                    and not tags.meat and not tags.egg
        end,
		priority = 100,
		foodtype = FOODTYPE.ELEMENTAL,
		perishtime = nil,
		cooktime = 2,
		floater = {"small", 0.05, 1},
        oneat_desc = STRINGS.UI.COOKBOOK.DEWDROP,

        health = 0,
        hunger = 0,
        sanity = 0,
    },
}

for k, v in pairs(items_plants) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

    v.cookbook_category = "cookpot"
end

return items_plants