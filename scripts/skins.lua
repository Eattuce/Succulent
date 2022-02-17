-- 改自myth_skinsapi
GLOBAL.MYSKINS = {}
local skins = {}

local baseimage = {}

local function my_basic_init_fn(inst, name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end
    local data = skins[name]
    if not data then return end
    if data.bank then
        inst.AnimState:SetBank(data.bank)
        print("Bank", data.bank)
    end
    inst.AnimState:SetBuild(data.build or name)
    print("Build", data.build)
    inst.AnimState:PlayAnimation(data.anim)
    print("PlayAnimation", data.anim)
    if data.push then
        inst.AnimState:PushAnimation(data.push, data.loop or false)
        print("PushAnimation", data.push, data.loop)
    end
    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem.atlasname = data.atlas or ("images/inventoryimages/"..name .. ".xml")
        inst.components.inventoryitem:ChangeImageName(data.image or name )
    end

    if data.custom_init_fn then
        data.custom_init_fn(inst, name)
    end
end

local function my_basic_clear_fn(inst, name)
    local prefab = inst.prefab
    local data = skins[name]
    if not data then return end
    if data.base_bank then
        inst.AnimState:SetBank(data.base_bank)
    end
    inst.AnimState:SetBuild(data.base_build or prefab)
    inst.AnimState:PlayAnimation(data.base_anim)
    print("old skin cleared")
    if data.base_push then
        inst.AnimState:PushAnimation(data.base_push)
    end
    if inst.components.inventoryitem ~= nil then
        if data.base_atlas and data.base_image then
            inst.components.inventoryitem.atlasname = data.base_atlas
            local imagename = data.base_image
            imagename = imagename:sub(1,-5)
            inst.components.inventoryitem:ChangeImageName(imagename)
        else
            inst.components.inventoryitem.atlasname = GetInventoryItemAtlas(prefab..".tex")
            inst.components.inventoryitem:ChangeImageName(prefab)
        end
    end

    if skins[name].skinclear_fn then
        skins[name].skinclear_fn(inst, name)
    end
end

local mt = getmetatable(TheInventory)
local oldTheInventoryCheckOwnership = TheInventory.CheckOwnership
mt.__index.CheckOwnership  = function(i,name,...)
    if type(name)=="string" and skins[name] then
        if skins[name] and skins[name].checkfn then
            return skins[name].checkfn(i,name,...)
        else
            return true
        end
    else
        return oldTheInventoryCheckOwnership(i,name,...)
    end
end
local oldTheInventoryCheckOwnershipGetLatest = TheInventory.CheckOwnershipGetLatest
mt.__index.CheckOwnershipGetLatest  = function(i,name,...)
    if type(name)=="string" and skins[name] then
        if skins[name] and skins[name].checkfn then
            return skins[name].checkfn(i,name,...)
        else
            return true,0
        end
    else
        return oldTheInventoryCheckOwnershipGetLatest(i,name,...)
    end
end

local oldTheInventoryCheckClientOwnership = TheInventory.CheckClientOwnership
mt.__index.CheckClientOwnership  = function(i,userid,name,...)
    if type(name)=="string"  and skins[name] then
        if skins[name] and skins[name].checkclientfn then
            return skins[name].checkclientfn(i,userid,name,...)
        else
            return true
        end
    else
        return oldTheInventoryCheckClientOwnership(i,userid,name,...)
    end
end

AddClassPostConstruct("widgets/recipepopup",function(self)
    local oldfn = self.GetSkinOptions
    function self.GetSkinOptions(Recipepopup,...)
    -- 设置皮肤选项栏 第一个默认皮肤的预览图片
        local skin_options = oldfn(Recipepopup,...)
        if skin_options then
            if skin_options[1] and skin_options[1].image then
                if Recipepopup.recipe and Recipepopup.recipe.product and baseimage[Recipepopup.recipe.product] then
                    skin_options[1].image = baseimage[Recipepopup.recipe.product]
                end
            end
    -- 为每个皮肤设置预览图片
            for idx,data in pairs(Recipepopup.skins_list) do
                if skin_options[idx+1] and skin_options[idx+1].image
                    and data and data.item and skins[data.item]
                    and (skins[data.item].atlas or skins[data.item].image)
                then
                    local image = skins[data.item].image or data.item..".tex"
                    if image:sub(-4) ~= ".tex" then
                        image = image..".tex"
                    end
                    local atlas = skins[data.item].atlas or GetInventoryItemAtlas(image)
                    skin_options[idx+1].image = {atlas,image,"default.tex"}
                end
            end
        end
        return skin_options
    end
end)

local oldSpawnPrefab = SpawnPrefab
GLOBAL.SpawnPrefab = function(prefab,skin,skinid,userid,...)
    if skins[skin] then
        skinid = 0
    end
    return oldSpawnPrefab(prefab,skin,skinid,userid,...)
end
local oldReskinEntity = Sim.ReskinEntity
Sim.ReskinEntity = function(sim,guid,oldskin,newskin,skinid,userid,...)
    local inst = Ents[guid]
    if oldskin and skins[oldskin] then
        skins[oldskin].clear_fn(inst)
    end
    local r = oldReskinEntity(sim,guid,oldskin,newskin,skinid,userid,...)
    if newskin and skins[newskin] then
        skins[newskin].init_fn(inst)
        inst.skinname = newskin
        inst.skin_id = PREFAB_SKINS_IDS[inst.prefab][newskin] or 0
    end
    return r
end

AddSimPostInit(function()
    for k,v in pairs(AllRecipes) do
        if v.product ~= v.name and PREFAB_SKINS[v.product] then
            PREFAB_SKINS[v.name]      = PREFAB_SKINS[v.product]
            PREFAB_SKINS_IDS[v.name]  = PREFAB_SKINS_IDS[v.product]
        end
    end
end)

local function AddSkin(name, data)
    local base = data.base_prefab
    baseimage[base] = { "images/inventoryimages/"..base..".xml", base..".tex", "default.tex"}
    data.type = data.type or "item"
    data.rarity = data.rarity or "Loyal"

    data.init_fn = function (inst) my_basic_init_fn(inst, name) end
    data.clear_fn = function (inst) my_basic_clear_fn(inst, name) end

    STRINGS.SKIN_NAMES[name] = data.namestring or name

    if not PREFAB_SKINS[base] then
        PREFAB_SKINS[base] = {}
    end
    table.insert(PREFAB_SKINS[base], name)

    if not PREFAB_SKINS_IDS[base] then
        PREFAB_SKINS_IDS[base] = {}
    end
    PREFAB_SKINS_IDS[base][name] = 1+#PREFAB_SKINS_IDS[base]

    skins[name] = data

    GLOBAL.MYSKINS[name] = data
end

--[[skin_datas
{

}]]
--[[
    GLOBAL.[prefab]_clear_fn = function(inst, skin)
    -- body
end
]]
GLOBAL.succulent_medpot_clear_fn  = function(inst, skin)
	inst.AnimState:SetBank("succulent_medpot")
	inst.AnimState:SetBuild("succulent_medpot")
    inst.AnimState:PlayAnimation("idle")
end

GLOBAL.succulent_largepot_clear_fn = function(inst, skin)
    inst.AnimState:PlayAnimation("plant_4_idle")
end

for skinname, data in pairs(require("skinsettings")) do
    AddSkin(skinname, data)
end
