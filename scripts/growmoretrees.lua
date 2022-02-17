local TREES = require("validtrees")
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local IV = 5

local function IsInSandstormArea(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    return TheWorld.Map:FindVisualNodeAtPoint(x, y, z, "sandstorm") ~= nil
end

local trees_in_sandstorm = {}

local function UpdateTreeNum()
    for i,v in pairs(trees_in_sandstorm) do
        if v:HasTag("stump") or v:HasTag("burnt") or not v.entity:IsVisible() then
            table.remove( trees_in_sandstorm,i )
        end
    end
    -- print("有"..#trees_in_sandstorm.."棵树在沙尘暴内")
    return #trees_in_sandstorm
end

local function Cal(amt)
    local times = 1
    if amt >= 0 and amt < 12 then
        times = 0
    elseif amt >= 12 and amt < 25 then
        times = 1
    elseif amt >= 25 and amt < 92 then
        times = math.floor(amt ^ 0.43) + 1
    else
        times = math.floor( (amt-92)/5 ) + 8
    end

    return times * times
end

--------,----------
--------,----------
local function SetRadius(inst)
    local amt = UpdateTreeNum()
    local times = Cal(amt)
    -- local old_times = inst.components.oasis.radius
    -- if times ~= old_times then
    if inst.components.oasis ~= nil then
        inst.components.oasis.radius = TUNING.SANDSTORM_OASIS_RADIUS * times
        -- print("3.湖改变绿洲范围"..inst.components.oasis.radius)
    end

    if not TheWorld.state.issummer then
        if inst._dynamicradius ~= nil then
            inst._dynamicradius:Cancel()
            inst._dynamicradius = nil
            -- print("2.1 end 确保任务停止")
        end
    end
end

local function dynamicRadius(inst, active)
    if active then
        -- print("2.湖确认沙尘暴已发生")
        if inst._dynamicradius == nil then
            inst._dynamicradius = inst:DoPeriodicTask(IV, SetRadius, 0)
        end
    else
        if inst._dynamicradius ~= nil then
            inst._dynamicradius:Cancel()
            inst._dynamicradius = nil
            -- print("2.end 沙尘暴结束，任务停止")
        end
        trees_in_sandstorm = {}
    end
end

local function lake_stormchange(inst, data)
    if data.stormtype == STORM_TYPES.SANDSTORM then
        -- print("1.湖监听到沙尘暴变化")
        dynamicRadius(inst, data.setting)
    end
end

local function On_init_new(inst)
    inst.newinittask = nil
    -- print("0.湖开始监听沙尘暴")
    inst:ListenForEvent("ms_stormchanged", lake_stormchange, TheWorld)
    dynamicRadius(inst, TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive())
end


------'------'
------'------'
local function AddTreeForLaterCalculating(inst)
    table.insert( trees_in_sandstorm,inst )
end

local function OnSandstormChanged(inst, active)
    if active then
        if IsInSandstormArea(inst) then -- 在沙漠
            -- print("c.树：在沙漠")
            AddTreeForLaterCalculating(inst)
        else
            inst:RemoveEventCallback("ms_stormchanged", inst._stormchanged, TheWorld) -- 移除监听器
            -- print("b.out.树：不在沙尘暴中，移除监听器")
            inst._INSTORM = false
        end
    end
end

local function OnInit_CustomModify(inst)
    inst.custominittask = nil

    if TheWorld.components.sandstorms == nil then
        return
    end

    if inst._INSTORM ~= nil then
        return
    end

    if inst._stormchanged == nil then
        inst._stormchanged = function(_inst, data)
            if data.stormtype == STORM_TYPES.SANDSTORM then
                if data.setting then
                    if IsInSandstormArea(inst) then
                        -- print("b.树：在沙尘暴中")
                        OnSandstormChanged(inst, data.setting)
                    end
                end
            end
        end

        inst:ListenForEvent("ms_stormchanged", inst._stormchanged, TheWorld)
        -- print("a.树：开始监听沙尘暴")

        OnSandstormChanged(inst, TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive())
    end

end

for _,v in ipairs(TREES) do
    AddPrefabPostInit( v , function(inst)
        if IsServer then
            inst.custominittask = inst:DoTaskInTime(0, OnInit_CustomModify)
        end
    end)
end


AddPrefabPostInit( "oasislake" , function(inst)
    if IsServer then
        inst.newinittask = inst:DoTaskInTime(0, On_init_new)
    end
end)


