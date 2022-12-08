GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

local impath = "images/inventoryimages/"

PrefabFiles =
{
    "dewdrop",
    "succulent_pots",
    "succulentfarm",
    "preparedfoods_succulent",
    "buffs_succulent",
    "emeraldgem",
    "essence",
    "emeraldstaff",
    "succulentflowers",
    "emeraldamulet",
    "succulent_plant_fx",
    "totem",
    "thistle_seed",
    "thistle_bush",
    "python_fountain",
    "tent_oasis",
    "totem_spawner",
    "vegrack",
    "veggie_crisps",

    "skins",

    "whitney",
	"whitney_none",
    "poisonfx",

    "succulent_chest",

    "relic_items",
    "chandeliers",
    "chandelierlights",
    "dug_plants",
    "container_prefab",

    "totem_construction",
    "totem_floatingrock",
}

Assets =
{
    Asset("IMAGE", "minimap/mini.tex" ),
    Asset("ATLAS", "minimap/mini.xml" ),
    Asset("IMAGE", impath.."craft.tex"),
    Asset("ATLAS", impath.."craft.xml"),
    Asset("ATLAS", impath.."dewdrop.xml"),
    Asset("IMAGE", impath.."dewdrop.tex"),
    Asset("IMAGE", impath.."succulent_medpot.tex"),
    Asset("ATLAS", impath.."succulent_medpot.xml"),
    Asset("IMAGE", impath.."vegrack.tex"),
    Asset("ATLAS", impath.."vegrack.xml"),
    Asset("IMAGE", "images/ui/totem_ui.tex"),
    Asset("ATLAS", "images/ui/totem_ui.xml"),
    Asset("IMAGE", impath.."succulent_largepot.tex"),
    Asset("ATLAS", impath.."succulent_largepot.xml"),
    Asset("IMAGE", impath.."treasurechest_succulent.tex"),
    Asset("ATLAS", impath.."treasurechest_succulent.xml"),
    Asset("IMAGE", impath.."treasurechest_succulent_item.tex"),
    Asset("ATLAS", impath.."treasurechest_succulent_item.xml"),
    Asset("IMAGE", "minimap/succulentchest_minimapicon.tex"),
    Asset("ATLAS", "minimap/succulentchest_minimapicon.xml"),

    Asset("ANIM", "anim/emeraldgem.zip"),

    Asset("IMAGE", impath.."medpot_spa.tex"),
    Asset("ATLAS", impath.."medpot_spa.xml"),
    Asset("IMAGE", impath.."medpot_spb.tex"),
    Asset("ATLAS", impath.."medpot_spb.xml"),
    Asset("IMAGE", impath.."medpot_spc.tex"),
    Asset("ATLAS", impath.."medpot_spc.xml"),
    Asset("ANIM", "anim/medpot_sp.zip"),

    Asset("IMAGE", impath.."chandelier_rock.tex"),
    Asset("ATLAS", impath.."chandelier_rock.xml"),

    Asset( "IMAGE", "images/saveslot_portraits/whitney.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/whitney.xml" ),
    Asset( "IMAGE", "images/selectscreen_portraits/whitney.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/whitney.xml" ),
    Asset( "IMAGE", "images/selectscreen_portraits/whitney_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/whitney_silho.xml" ),
    Asset( "IMAGE", "bigportraits/whitney.tex" ),
    Asset( "ATLAS", "bigportraits/whitney.xml" ),
	Asset( "IMAGE", "images/map_icons/whitney.tex" ),
	Asset( "ATLAS", "images/map_icons/whitney.xml" ),
	Asset( "IMAGE", "images/avatars/avatar_whitney.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_whitney.xml" ),
	Asset( "IMAGE", "images/avatars/avatar_ghost_whitney.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_whitney.xml" ),
	Asset( "IMAGE", "images/avatars/self_inspect_whitney.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_whitney.xml" ),
	Asset( "IMAGE", "images/names_gold_whitney.tex" ),
    Asset( "ATLAS", "images/names_gold_whitney.xml" ),
	Asset( "IMAGE", "images/names_gold_cn_whitney.tex" ),
    Asset( "ATLAS", "images/names_gold_cn_whitney.xml" ),

    Asset( "ANIM", "anim/poisonfx.zip" ),
    Asset( "IMAGE", "images/crafting_menu_avatars/avatar_whitney.tex"),
    Asset( "ATLAS", "images/crafting_menu_avatars/avatar_whitney.xml" ),

    Asset( "SOUNDPACKAGE", "sound/succulent_chest.fev"),
    Asset( "SOUND", "sound/succulent_chest.fsb"),

    Asset("IMAGE", impath.."succulentfarm_sp.tex"),
    Asset("ATLAS", impath.."succulentfarm_sp.xml"),
    Asset("IMAGE", impath.."succulent_largepot_sp.tex"),
    Asset("ATLAS", impath.."succulent_largepot_sp.xml"),
    Asset("ANIM", "anim/succulentfarm_sp.zip"),
    Asset("IMAGE", impath.."dug_thistle_bush.tex"),
    Asset("ATLAS", impath.."dug_thistle_bush.xml"),

}

--------------------------------------------------------------------------
-- 定义常量
local seg_time = 30
local total_day_time = seg_time*16

TUNING.THISTLE_BUSH_GROW =
{
    WITHER_ONE = total_day_time ,
    ONE_TWO = 3*total_day_time ,
    TWO_THREE = 5*total_day_time ,
    VAR = 2*seg_time,
}

--------------------------------------------------------------------------
-- 注册小地图标
local minimapatlas = {"mini", "fountain_minimapicon", "totem_minimap_icon", "succulentchest_minimapicon", "bushmapicon"}

for _,name in pairs(minimapatlas) do
    AddMinimapAtlas("minimap/"..name..".xml")
end
AddMinimapAtlas("images/map_icons/whitney.xml")

--------------------------------------------------------------------------
-- 根据语言设置选择STRINGS文件
local language = GetModConfigData("Language")
local chinese = "scripts/languages/strings_chinese.lua"
local english = "scripts/languages/strings_english.lua"
if language == "chinese" then
    modimport(chinese) --中文
elseif language == "english" then
    modimport(english) --英语
end
TUNING.EMERALDSTAFF_USEDAY = GetModConfigData("staff")
--------------------------------------------------------------------------
-- 注册物品图标
local items =
{
    "succulent_largepot",
    "emeraldamulet",
    "emeraldstaff",
    "emeraldgem",
    "thistle_seed",
    "python_fountain_item",
    "totem_item",
    "tent_leaves_item",
    "veggie_crisps",
    "vegrack",
    "vegrack_item",
    "treasurechest_succulent",
    "treasurechest_succulent_item",
    -- skins
    "medpot_spa",
    "medpot_spc",
    "medpot_spb",
    "succulentfarm_sp",
    "succulent_largepot_sp",
    "dug_thistle_bush"

}
for _,item in pairs(items) do
    RegisterInventoryItemAtlas(impath..item..".xml", item..".tex")
end

--------------------------------------------------------------------------
-- import
local mainfiles =
{
    "modtownportal",
    -- "modtownportaltalisman", -- in townportal
    "modantlion",
    "modmushroomfarm",
    "emeraldmooneye",
    "modcrabking",
    "oasistech",
    -- "growmoretrees",
    "vegrack",
    -- "saplingspostinits",

    "skins",
    "addsg",
    -- "addactions",
    "addcontainers",
    "addrecipes",
    -- "brains",
    "downgradesandstorm"
}
for _,file in pairs(mainfiles) do
    modimport("scripts/"..file..".lua")
end
modimport("scripts/whitneysettings")

------------------------------------------------------------------------


local function gemtorecipe()
    AddRecipe2("emeraldgem", { Ingredient("bluegem", 1), Ingredient("redgem", 1), Ingredient("dewdrop", 1, impath.."dewdrop.xml") },TECH.MAGIC_THREE,{atlas = impath.."emeraldgem.xml",image = "emeraldgem.tex"})
    AddRecipeToFilter("emeraldgem", "REFINE")
end
if GetModConfigData("mythpot") then
    AddSimPostInit(function()
        if TUNING.MYTH_PILL_RECIPES then
            TUNING.MYTH_PILL_RECIPES.emeraldgem = {
                time = 60,
                recipe = {dewdrop = 1, redgem = 1, bluegem = 1, nightmarefuel = 1},
                overridebuild = "emeraldgem",
                overridesymbolname = "emeraldgem"
            }
        else
            gemtorecipe()
        end
    end)
else
    gemtorecipe()
end

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, 25 }
    },
}
AddModCharacter("whitney", "FEMALE", skin_modes)




------------------------------------------------------------------------


local ingredients = {"glommerfuel", "slurtleslime", "phlegm"}
AddIngredientValues(ingredients, {special=1}, false, false)--格罗姆黏液 蜗牛黏液 钢羊浓鼻涕
AddIngredientValues({"succulent_picked"}, {decoration=.5}, false, false)    --多肉植物 --cancook --candry
AddIngredientValues({"townportaltalisman"},{inedible=1}, false, false)  --沙之石
AddIngredientValues({"saltrock"},{inedible=1}, false, false)  --盐晶





--正常食谱
for k, recipe in pairs(require("preparedfoods_plants")) do
    table.insert(Assets, Asset("ATLAS", "images/cookbookimages/"..recipe.name..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/cookbookimages/"..recipe.name..".tex"))

    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)
    RegisterInventoryItemAtlas("images/cookbookimages/"..recipe.name..".xml", recipe.name..".tex")
end
--加料
for k, recipe in pairs(require("preparedfoods_spiced")) do
    AddCookerRecipe("portablespicer", recipe)
end
--物品食谱
for k, recipe in pairs(require("preparednonplants")) do
    table.insert(Assets, Asset("ATLAS", "images/cookbookimages/"..recipe.name..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/cookbookimages/"..recipe.name..".tex"))
    RegisterInventoryItemAtlas("images/cookbookimages/"..recipe.name..".xml", recipe.name..".tex")
    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)
end


-- 潮湿的玉露反而可以增加耐久
AddComponentPostInit("fueled", function (self)
    local _TakeFuelItem = self.TakeFuelItem
    function self:TakeFuelItem(item, doer)
        local fuel_obj = item or doer
        if fuel_obj:HasTag("fuel_wet_bonus") then
            if self:CanAcceptFuelItem(fuel_obj) then
                local oldsection = self:GetCurrentSection()
                local wetmult = fuel_obj:GetIsWet() and 1.2 or 1
                local masterymult = doer ~= nil and doer.components.fuelmaster ~= nil and doer.components.fuelmaster:GetBonusMult(fuel_obj, self.inst) or 1
                local fuel = fuel_obj.components.fuel or fuel_obj.components.fueler
                local fuelvalue = fuel.fuelvalue * self.bonusmult * wetmult * masterymult
                self:DoDelta(fuelvalue, doer)
                fuel:Taken(self.inst)
                if item ~= nil then
                    item:Remove()
                end
                if self.ontakefuelfn ~= nil then
                    self.ontakefuelfn(self.inst, fuelvalue)
                end
                self.inst:PushEvent("takefuel", { fuelvalue = fuelvalue })
                return true
            end
        else
            return _TakeFuelItem(self, item, doer)
        end
    end
end)

------------------------------------------------------------------------

-- 防止灯和其他树上的东西碰撞
for _,v in pairs({"oceanvine", "oceanvine_cocoon", "oceanvine_cocoon_burnt"}) do
    AddPrefabPostInit(v, function (inst)
        inst:AddTag("hangingobject")
    end)
end
------------------------------------------------------------------------

-- RPCs
local function Chandelier_FadeIn(inst)
    if inst.components and inst.components.gradualfader then
        inst.components.gradualfader:FadeIn()
        -- TheNet:Announce("In")
    end
end
local function Chandelier_FadeOut(inst)
    if inst.components and inst.components.gradualfader then
        inst.components.gradualfader:FadeOut()
        -- TheNet:Announce("Out")
    end
end


AddClientModRPCHandler("Succulent_RPC", "Chandelier_FadeIn", Chandelier_FadeIn)
AddClientModRPCHandler("Succulent_RPC", "Chandelier_FadeOut", Chandelier_FadeOut)


-- ShowMe(Origin) Workshop ID - 666155465
TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
TUNING.MONITOR_CHESTS.treasurechest_succulent = 1



------------------------------------------------------------------------
------------------------------[[测试功能]]------------------------------
------------------------------------------------------------------------
local function OnConstructed(inst, doer)
    local concluded = true
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            concluded = false
            break
        end
    end

    if concluded then
        local new_throne = ReplacePrefab(inst, "researchlab2")
        -- TheWorld:PushEvent("onthronebuilt", {throne = new_throne})
        new_throne.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/throne/build")
    end
end


AddPrefabPostInit("meatrack", function (inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("constructionsite")
    inst.components.constructionsite:SetConstructionPrefab("totem_construction_container")
    inst.components.constructionsite:SetOnConstructedFn(OnConstructed)

end)

--[[
    -- 给果冻加上额外提示

AddSimPostInit(function ()
    local _GetDescription_AddSpecialCases = GetDescription_AddSpecialCases
    function GetDescription_AddSpecialCases(ret, charactertable, inst, item, modifier)
        local post = {}
        print(2)

        if item.prefab == "ppf_succulentjelly" and type(inst) == "table" then
            local hunger = inst.components.hunger and inst.components.hunger:GetPercent() or 1
            local sanity = inst.components.sanity and inst.components.sanity:GetPercent() or 1
            local health = inst.components.oldager ~= nil and 1 or (inst.components.health and inst.components.health:GetPercent() or 1)

            table.insert(post, "ANNOUNCE_JELLYHELP")
            print(1)
        end

        if #post > 0 then
            ret = (ret or "") .. table.concat(post, "")
        end

        return _GetDescription_AddSpecialCases(ret, charactertable, inst, item, modifier)
    end
end)

]]


--[[ local function SetPercent(self, percent)
    require("mathutil")
    if percent < .51 and percent > .49 then
        self.spoilage:GetAnimState():OverrideSymbol("meter", "spoiled_meter", "meter_green")
        self.spoilage:GetAnimState():OverrideSymbol("frame", "spoiled_meter", "frame_green")
    elseif percent < .21 and percent > .19 then
        self.spoilage:GetAnimState():OverrideSymbol("meter", "spoiled_meter", "meter_yellow")
        self.spoilage:GetAnimState():OverrideSymbol("frame", "spoiled_meter", "frame_yellow")
    else
        self.spoilage:GetAnimState():ClearAllOverrideSymbols()
    end

    self.spoilage:GetAnimState():SetPercent("anim", math.clamp(1 - percent, 0, .99))
end

AddClassPostConstruct("widgets/itemtile", function (self)
    local _Refesh = self.Refesh

    function self:Refesh()
        _Refesh(self)
        if self.ismastersim then
            if self.item:HasTag("AlawysShowSpoilage") and self.item.always_spoilage_colour then
                SetPercent(self, self.item.always_spoilage_colour)
            end
        end
    end
end)
 ]]


-- AddComponentPostInit("shadowsubmissive", function (self)
--     local _TargetHasDominance = self.TargetHasDominance
--     function self:TargetHasDominance(target)
--         return _TargetHasDominance(self, target) or (target ~= nil and target:HasTag("shadowdominance"))
--     end
-- end)


--[[
-- modimport("scripts/pondtiles")

modimport("scripts/brains")

-- 揭示图腾
AddPrefabPostInit("messagebottle", function (bottle)
    if not TheWorld.ismastersim then
        return bottle
    end

    local _prereveal = bottle.components.mapspotrevealer.prerevealfn
    bottle.components.mapspotrevealer:SetPreRevealFn(function (inst, doer)
        local totem_revealed = false

        if TheWorld.components.messagebottlemanager ~= nil then
            if (TheWorld.components.messagebottlemanager:GetPlayerHasUsedABottle(doer) or TheWorld.components.messagebottlemanager:GetPlayerHasFoundTotem(doer)) then
                totem_revealed = true
            end

            -- TheWorld.components.messagebottlemanager:SetPlayerHasUsedABottle(doer)
        end

        if totem_revealed then
            return _prereveal(inst, doer)
        else
            return true
        end

    end)
end)

AddComponentPostInit("messagebottlemanager", function (self)
    self.totem = nil
    self.totem_has_been_found_by = {}

    function self:GetTotem()
        return self.totem ~= nil and self.totem:IsValid() and self.totem or nil
    end

    local _UseMessageBottle = self.UseMessageBottle
    function self:UseMessageBottle(bottle, doer)
        local totem = self:GetTotem()

        if totem ~= nil and not self:GetPlayerHasFoundTotem(doer) then
            return totem:GetPosition()--, reason=nil
        end
        return _UseMessageBottle(self, bottle, doer)
    end

    function self:SetPlayerHasFoundTotem(player)
        self.totem_has_been_found_by[player.userid] = true
    end

    function self:GetPlayerHasFoundTotem(player)
        return self.totem_has_been_found_by[player.userid]
    end

    local _OnSave = self.OnSave
    function self:OnSave()
        local data = _OnSave(self)

        if next(self.totem_has_been_found_by) ~= nil then
            data.totem_has_been_found_by = self.totem_has_been_found_by
        end
        return data
    end

    local _OnLoad = self.OnLoad
    function self:OnLoad(data)
        if data ~= nil then
            if data.totem_has_been_found_by ~= nil and next(data.totem_has_been_found_by) ~= nil then
                for k, v in pairs(data.totem_has_been_found_by) do
                    self.totem_has_been_found_by[k] = true
                end
            end
        end
        return _OnLoad(self, data)
    end
end)
]]

--[[
-- 小房子相关
AddSimPostInit(function ()
    -- 在地图外的地皮是 WORLD_TILES.INVALID 他们不属于陆地和海洋, 这些地皮上的物品会直接掉到虚空消失, 比如洞穴
    -- IsAboveGroundAtPoint 在这里笼统地判断一下, 起到的作用是让物品不会直接消失
    -- 这样做会导致周围出现鸟类
    -- TODO: Make a Walkable-platform ?
    local _IsAboveGroundAtPoint = Map.IsAboveGroundAtPoint
    Map.IsAboveGroundAtPoint = function(self, x, y, z, allow_water, ...)
        if math.abs(x) > 1800 or math.abs(z) > 1800 then
            return true
        end
        return _IsAboveGroundAtPoint(self, x, y, z, allow_water, ...)
    end

    -- 一方面是几何mod报错问题? placer.lua -- line--58 GetPosition()
    local _GetTileCenterPoint =	Map.GetTileCenterPoint
    Map.GetTileCenterPoint = function(self, x, y, z)
        if math.abs(x) > 1800 or math.abs(z or y) > 1800 then
            return math.floor(x/4)*4+ 2,0,math.floor(z/4)*4 + 2
        end
        if z then
            return _GetTileCenterPoint(self, x,y,z)
        else
            return _GetTileCenterPoint(self, x,y)
        end
    end

end)

-- 解决由于修改 IsAboveGroundAtPoint 带来的鸟问题
AddComponentPostInit("birdspawner", function(self)
	local _GetSpawnPoint = self.GetSpawnPoint
	function self:GetSpawnPoint(pt)
        local x,y,z = pt:Get()
        if math.abs(x) > 1800 or math.abs(z) > 1800 then
			return nil
		else
			return _GetSpawnPoint(self,pt)
		end
	end
end)
]]