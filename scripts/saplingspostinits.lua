
local r = 4*4
local maxradius = 2*r

local function IsInSandstormArea(pt)
    -- local pt = inst:GetPosition()
    return TheWorld.Map:FindVisualNodeAtPoint(pt.x,0,pt.z, "sandstorm") ~= nil and true or false -- pt or nil
end

local function SpawnManager(inst, pt)
    -- print("1")
    if #TheSim:FindEntities(pt.x, pt.y, pt.z, maxradius, {"OASISMANAGER"}) == 0 then
        -- print("2")
        local manager = SpawnPrefab("oasismanager")
        -- local x,y,z = inst.Transform:GetWorldPosition()
        manager.seedpoint = pt--inst:GetPosition()
        manager.Transform:SetPosition(pt:Get())
        manager.treeamt = #TheSim:FindEntities(pt.x,pt.y,pt.z, maxradius, {"plant"},{"burnt","stump","NOCLICK","FX"})
        -- manager:_ApplyRadius(manager, manager.treeamt)
    end
end

local function onplanted(inst, pt)
    -- local pt = IsInSandstormArea(inst)
    if IsInSandstormArea(pt) then
        SpawnManager(inst, pt)
    end
end

local function SaplingPostInit(seed)
    if not TheWorld.ismastersim then return end
    local oldondeploy = seed.components.deployable.ondeploy
    seed.components.deployable.ondeploy = function(inst, pt)
        onplanted(inst, pt)
        return oldondeploy(inst, pt)
    end
end

local saplings =
{
    -- "pinecone_sapling",
    -- "lumpy_sapling",
    -- "acorn_sapling",
    -- -- "twiggy_nut_sapling",
    -- "moonbutterfly_sapling",
    "pinecone",
    "twiggy_nut",
    "acorn",
    "moonbutterfly",
}

for _,v in pairs(saplings) do
    AddPrefabPostInit(v, SaplingPostInit)
end