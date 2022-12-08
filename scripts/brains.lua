
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

local HEIGHT = 8

local function GoHome(inst)
    if not inst.home then
        return
    end

    local x,y,z = inst.Transform:GetWorldPosition() -- 得是Transform
    if inst:GetDistanceSqToPoint(x,y,z) < 4 then
        if y >= 4 then
            if inst.home.components.chandelier:CanGoHome() then
                -- 非常奇怪, 我也不想这样
                local newent = SpawnPrefab(inst.prefab)
                if inst.components.perishable then
                    newent.components.perishable:SetPercent(inst.components.perishable:GetPercent())
                end
                inst.home.components.chandelier:GoHome(newent)
                inst:Remove()
            end
        end
    end
end

local function LiftUp(inst, force)
    local shelter = inst.home
    local t = force or 1
    if shelter then
        local _,y,_ = inst.Transform:GetWorldPosition()
        if y < HEIGHT then
            inst.Physics:SetMotorVel(0, 1 * t + 2*math.random(), 0)
        else
            inst.Physics:Stop()
        end
    end
end


------------------------------------------------------------------------
-- 月蛾

-- 寻找吊灯
AddBrainPostInit("moonbutterflybrain", function (self)
    require "behaviours/findclosestchandelier"
    local findchandelier = FindClosestChandelier(self.inst, 10, 0, nil, {"isfull_chandelier"})
    local children = self.bt.root.children
    table.insert(children, #children, findchandelier)
end)

-- 在sg里供向上的力, 在达到高度后进入吊灯
AddStategraphPostInit("butterfly", function (self)
    local idle = self.states["idle"]
    -- 向上飞直到高度达到
    local _onupdate = idle.onupdate
    idle.onupdate = function (inst)
        if not inst.prefab == "moonbutterfly" then
            return
        end
        LiftUp(inst)
        if _onupdate ~= nil then
            return _onupdate(inst)
        end
    end

    -- 动画播放完时, 月蛾动画在向上飞, 刚好判断是否到达高度
    local _ontimeout = idle.ontimeout
    idle.ontimeout = function(inst)
        if not inst.prefab == "moonbutterfly" then
            return
        end
        GoHome(inst)
        return _ontimeout(inst)
    end

    -- 以防万一, 停止Physics
    idle.onexit = function (inst)
        if not inst.prefab == "moonbutterfly" then
            return
        end
        inst.Physics:Stop()
    end
end)

-- 确定要进入的灯
AddPrefabPostInit("moonbutterfly", function (inst)
    if not TheWorld.ismastersim then return end
    inst:ListenForEvent("linkchandelier", function (instance, data)                         -- Event "linkchandelier" Pushed in behaviours/findclosestchandelier.lua
        inst.home = data.home
    end)
end)


------------------------------------------------------------------------
-- 发光飞虫
AddBrainPostInit("lightflierbrain", function (self)
    require "behaviours/findclosestchandelier"
    local findchandelier = FindClosestChandelier(self.inst, 10, 0, nil, {"isfull_chandelier"})
    local parallel_node_children = self.bt.root.children[1].children
    local priority_node_children = parallel_node_children[2].children
    local while_node_children = priority_node_children[4].children -- [1]condition
    local nodes = while_node_children[2].children
    table.insert(nodes, 3, findchandelier)
end)

AddStategraphPostInit("lightflier", function (self)
    local idle = self.states["idle"]
    local _onupdate = idle.onupdate
    idle.onupdate = function (inst)
        LiftUp(inst, 2)
        if _onupdate ~= nil then
            return _onupdate(inst)
        end
    end

    local _onexit = idle.onexit
    idle.onexit = function (inst)
        GoHome(inst)
        if _onexit ~= nil then
            return _onexit(inst)
        end
    end
end)

AddPrefabPostInit("lightflier", function (inst)
    if not TheWorld.ismastersim then return end
    inst:ListenForEvent("linkchandelier", function (instance, data)
        inst.home = data.home
    end)
end)

------------------------------------------------------------------------
-- 发光蟹
AddBrainPostInit("lightcrabbrain", function (self)
    require "behaviours/findclosestchandelier"
    local findchandelier = FindClosestChandelier(self.inst, 10, 0, nil, {"isfull_chandelier"})
    local children = self.bt.root.children
    table.insert(children, 5, findchandelier)
end)

AddStategraphPostInit("lightcrab", function (self)
    local idle = self.states["idle"]

    local _onupdate = idle.onupdate
    idle.onupdate = function (inst)
        if inst.home and inst:GetDistanceSqToPoint(inst.home:GetPosition()) <= 4 then
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:SetMotorVel(0, 20, 0)
        end
        GoHome(inst)
        if _onupdate ~= nil then
            return _onupdate(inst)
        end
    end

    -- local _onexit = idle.onexit
    -- idle.onexit = function (inst)
    --     if inst.home and inst:GetDistanceSqToPoint(inst.home:GetPosition()) <= 1 then
    --         inst.AnimState:PlayAnimation("hit")
    --         inst.Physics:SetMotorVel(0, 15, 0)
    --     end
    --     if _onexit then
    --         return _onexit(inst)
    --     end
    -- end

end)

AddPrefabPostInit("lightcrab", function (inst)
    if not TheWorld.ismastersim then return end
    inst:ListenForEvent("linkchandelier", function (instance, data)
        inst.home = data.home
    end)
end)
