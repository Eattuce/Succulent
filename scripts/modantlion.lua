local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

if IsServer then
    local function launchitem(item, angle)
        local speed = math.random() * 4 + 2
        angle = (angle + math.random() * 60 - 30) * DEGREES
        item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
    end

    AddPrefabPostInit("antlion", function(inst)

        local ori_ongiveitem = inst.components.trader.onaccept
        inst.components.trader.onaccept = function (inst, giver, item)
            local x, y, z = inst.Transform:GetWorldPosition()
            y = 1

            local angle
            if giver ~= nil and giver:IsValid() then
                angle = 360 - giver:GetAngleToPoint(x, 0, z)
            else
                local down = TheCamera:GetDownVec()
                angle = math.atan2(down.z, down.x) / DEGREES
                giver = nil
            end

            local function delay()
                for k = 1, item.components.tradable.rocktribute-1 do
                    local rock = SpawnPrefab("townportaltalisman")
                    rock.Transform:SetPosition(x, y, z)
                    launchitem(rock, angle)
                end
            end
            inst:DoTaskInTime(3, delay)
            return ori_ongiveitem(inst, giver, item)
        end
    end)
end
