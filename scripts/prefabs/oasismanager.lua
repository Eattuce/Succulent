
local r = 4*4
local maxradius = 2*r

local function ApplyRadius(inst, amt)
    if type(amt) ~= "number" then
        local x,y,z = inst.Transform:GetWorldPosition()
        inst.treeamt = #TheSim:FindEntities(x,y,z, maxradius, {"plant"}, {"burnt","stump","NOCLICK","FX"})
        amt = inst.treeamt
    end
    if amt < 10 then
        if inst.components.oasis then
            inst:RemoveComponent("oasis")
        end
    else
        if not inst.components.oasis then
            inst:AddComponent("oasis")
            TheWorld:PushEvent("ms_registeroasis", inst)
        end
        inst.components.oasis.radius = math.floor(maxradius*(amt/200))
    end
    if inst.loadtask then
        inst.loadtask = nil
    end
end

local function UpdateTreeAmt(inst, pt)
    inst.treeamt = inst.treeamt + 1
    local amt = inst.treeamt
    ApplyRadius(inst, amt)

    local p = inst.seedpoint
    local x,y,z = inst.Transform:GetWorldPosition()
    local midx = (pt.x+x)/2
    local midz = (pt.z+z)/2
    local displacement = math.sqrt((p.x-midx)^2+(p.z-midz)^2)
    if displacement > r/2 then
        return
    end
    inst.Transform:SetPosition(midx,y,midz)
end

local function DowngradeTreeAmt(inst, pos)
    inst.treeamt = inst.treeamt - 1
    local amt = inst.treeamt
    if amt <= 0 then
        inst:Remove()
    else
        ApplyRadius(inst, amt)
    end
end

local function onsave(inst, data)
    data.seedpoint = inst.seedpoint or inst:GetPosition()
    data.treeamt = inst.treeamt
end

local function onload(inst, data)
    if data then
        if data.seedpoint then
            inst.seedpoint = data.seedpoint
        end
        -- if data.treeamt then
        --     inst.treeamt = data.treeamt

        -- end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    -- inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("OASISMANAGER")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._onitemplanted = function (src, data)
        if data and data.pos then
            print("planted")
            local distsq = inst:GetDistanceSqToPoint(data.pos)
            if distsq < maxradius^2 then
                UpdateTreeAmt(inst, data.pos)
            end
        end
    end
    inst._onplantkilled = function (src, data)
        if data and data.pos then
            print("killed")
            local distsq = inst:GetDistanceSqToPoint(data.pos)
            if distsq < maxradius^2 then
                DowngradeTreeAmt(inst, data.pos)
            end
        end
    end

    inst._ApplyRadius = ApplyRadius

    inst.loadtask = inst:DoTaskInTime(1, ApplyRadius, inst, inst.treeamt)

    -- inst:AddComponent("talker")
    -- inst.task = inst:DoPeriodicTask(5,function ()
    --     inst.components.talker:Say(tostring(inst.treeamt))
    --     print(inst.components.oasis and inst.components.oasis.radius or "no")
    -- end)

    -- inst.seedpoint = inst:GetPosition()

    inst:ListenForEvent("itemplanted", inst._onitemplanted, TheWorld)
    inst:ListenForEvent("plantkilled", inst._onplantkilled, TheWorld)


    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("oasismanager", fn)