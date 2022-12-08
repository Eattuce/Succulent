local assets =
{
	Asset( "ANIM", "anim/whitney.zip" ),
	Asset( "ANIM", "anim/ghost_whitney_build.zip" ),
}

local skins =
{
	normal_skin = "whitney",
	ghost_skin = "ghost_whitney_build",
}

return CreatePrefabSkin("whitney_none",
{
	base_prefab = "whitney",
	type = "base",
	assets = assets,
	skins = skins,
	skin_tags = {"WHITNEY", "CHARACTER", "BASE"},
	build_name_override = "whitney",
	rarity = "Character",
})