
table.insert(Assets, Asset("ANIM", "anim/crabkinggem.zip"))
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
if IsServer then

local MAX_SOCKETS = 9

local function clearsocketart(inst)
    inst.AnimState:ClearOverrideSymbol("gems_blue")
    for i=1,9 do
        inst.AnimState:ClearOverrideSymbol("gem"..i)
    end
end

local function AddDecor(inst, data)
    if data == nil or data.slot == nil or data.itemprefab == nil then
        return
    end
    local symbol = "gems_blue"
    if data.itemprefab == "redgem" then
        symbol = "gems_red"
    elseif data.itemprefab == "purplegem" then
        symbol = "gems_purple"
    elseif data.itemprefab == "orangegem" then
        symbol = "gems_orange"
    elseif data.itemprefab == "yellowgem" then
        symbol = "gems_yellow"
    elseif data.itemprefab == "greengem" then
        symbol = "gems_green"
    elseif data.itemprefab == "opalpreciousgem" then
        symbol = "gems_opal"
    elseif data.itemprefab == "hermit_pearl" then
        symbol = "hermit_pearl"
    elseif data.itemprefab == "emeraldgem" then
        symbol = "gems_emerald"
    end

    if symbol == "gems_emerald" then
        inst.AnimState:OverrideSymbol("gem"..data.slot, "crabkinggem", symbol)
    else
        inst.AnimState:OverrideSymbol("gem"..data.slot, "crab_king_build", symbol)
    end
    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/gem_place")
    inst.shinefx = SpawnPrefab("crab_king_shine")
    inst.shinefx.entity:AddFollower()
    --inst.shinefx.entity:SetParent(inst)
    inst.shinefx.Follower:FollowSymbol(inst.GUID, "gem"..data.slot, 0, 0, 0)
    inst:PushEvent("socket")
end

local function socketitem(inst,item,socketnum)
    -- find open slot
    if socketnum then
        for i = #inst.socketlist, 1, -1 do
            if inst.socketlist[i] == socketnum then
                table.remove(inst.socketlist, i)
                break
            end
        end
    else
        if #inst.socketlist <=0 or item.prefab == "hermit_pearl" then
            socketnum = 5
        else
            local idx = math.random(1,#inst.socketlist)
            socketnum = inst.socketlist[idx]
            table.remove(inst.socketlist,idx)
        end
    end
    local data = {slot = socketnum, itemprefab = item.prefab}
    table.insert(inst.socketed,data)
    AddDecor(inst, data)
    item:RemoveTag("irreplaceable")
    item:Remove()

    if #inst.socketed >= MAX_SOCKETS then
        inst.components.health:SetMaxHealth(TUNING.CRABKING_HEALTH + (math.floor(inst.countgems(inst).red/2) * math.floor(inst.countgems(inst).red/2) *TUNING.CRABKING_HEALTH_BONUS ))
        inst.components.health.currenthealth = inst.components.health.maxhealth

        MakeLargeBurnableCharacter(inst, "body")
        MakeHugeFreezableCharacter(inst, "body")

        inst.components.freezable:SetResistance(3 + inst.countgems(inst).blue)

        inst:AddTag("epic")
        inst:AddTag("animal")
        inst:AddTag("scarytoprey")
        inst:AddTag("hostile")

        inst:PushEvent("activate")
    end
end

AddPrefabPostInit("crabking", function(inst)
    local ori_ongetitemfromplayer = inst.components.trader.onaccept
    inst.components.trader.onaccept = function(inst, giver, item)
        socketitem(inst,item)
    end
    local ori_onloadpostpass = inst.OnLodaPostPass
    inst.OnLodaPostPass = function(inst, newents, data)
        clearsocketart(inst)
        -- reset sockets
        if data then
            inst.socketlist = data.socketlist
            if data.socketed then
                for k,v in ipairs(data.socketed) do
                    local gem = SpawnPrefab(v)
                    socketitem(inst,gem,data.socketedslot[k])
                end
            end
            if data.arms and #data.arms > 0 then
                inst.arms = {}
                for i,arm in pairs(data.arms) do
                    if newents[arm] then
                        inst.arms[i] = newents[arm].entity
                        inst.arms[i].armpos = i
                    end
                end
            end
            if data.healthpercent then
                inst.components.health:SetPercent(data.healthpercent)
            end
        end
    end
end)
end