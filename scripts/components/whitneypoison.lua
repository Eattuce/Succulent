--Binary state problematic for non-players? should have a timer that gets set to infinite for players and some discrete time for non-players
local MaxPoisonDamage = 300

local Whitneypoison = Class(function(self, inst)
	self.inst = inst

	self.poisoned = false
-------------------------------------
	self.poison_level = 0
	self.maxlevel = TUNING.PLANTVEX_MAXLEVEL
	self.confinetime = 5
	self.offset = {x=0,y=0,z=0}
	self.xscale = 1
	self.yscale = 1
	self.zscale = 1
-------------------------------------
	self.fxdata = {}
	-- self.fxlevel = 1
	self.fxchildren = {}

	self.onpoisoned = nil
	self.oncured = nil

	self.onpoisonfull = nil

	self.show_fx = true

	self.duration = TUNING.PLANTVEX_DURATION
	self.damage_per_interval = TUNING.PLANTVEX_DAMAGE_PER_INTERVAL
	self.interval = TUNING.PLANTVEX_INTERVAL

	self.transfer_poison_on_attack = false

	self.start_time = nil

	self.inst:AddTag("whitneypoison")

	self.blockall = nil
-------------------------------------
	self.vulnerabletopoisondamage = true
	self.poison_damage_scale = 1
end)


function Whitneypoison:ApplyLevel(level, load)
	if level >= self.poison_level then
		self:RefreshDuriation()
	end

	self.poison_level = level

	self:ApplyFX(load)

	if self.poison_level == self.maxlevel then
		self:PoisonFull()
	end
end

function Whitneypoison:ApplyFX(load)
	self:SpawnFX(self:GetFXName(), load)
end

function Whitneypoison:LevelDelta(layer, load, curer, give_immunity, immunity_duration)
	local level = self.poison_level
	local next_level = level + layer
	if next_level >= self.maxlevel then
		level = self.maxlevel
	elseif next_level <= 0 then
		level = 0
		self:Cure(curer, give_immunity, immunity_duration)
	else
		level = next_level
	end
	self:ApplyLevel(level, load)
end

function Whitneypoison:GetPoisonLevel()
	return self.poison_level
end

function Whitneypoison:RefreshDuriation()
	self.start_time = GetTime()
end

local function OnCon(inst, data)
	print("heared")
	if next(data.amulet) then
		for _,v in pairs(data.amulet) do
			if v.components.finiteuses:GetUses() > 0 then
				v.components.finiteuses:Use(1)
			end
		end
	end
end

function Whitneypoison:Confine()
	local time = self.confinetime
	self.inst.brain:Stop()
	self.inst.components.locomotor:Stop()
	self.inst.confinetask = self.inst:DoTaskInTime(time,
	function ()
		self.inst.brain:Start()
		self.inst.confinetask = nil
	end)
	-- self.inst:ListenForEvent("whitney_poison", OnCon)
end

function Whitneypoison:PoisonFull()
	if self.onpoisonfull then
		self.onpoisonfull(self.inst)
	end

	self:Confine()
	-- self:DoPoisonFullDamage(200)
	self:Cure(nil,true,8,true)
end

-- Unused
--[[ 
function Whitneypoison:DoPoisonFullDamage(damage)
	if not self.inst.components.health.invincible and self.vulnerabletopoisondamage then
		if damage > 0 then
			self.inst.components.health:DoDelta(-damage, false, "poison_full",nil,nil,true)
											-- amount,overtime,cause,ignore_invincible,afflicter,ignore_absorb
		end
	end
end
 ]]

function Whitneypoison:ClearPoison()
	self.poison_level = 0
end

function Whitneypoison:SetOnPoisonFullFn(fn)
	self.onpoisonfull = fn
end

function Whitneypoison:CanBePoisoned(gas)
	if self.blockall then
		-- already poisoned
		return false
	end

	if self.immune then
		return false
	end

	return true
end

function Whitneypoison:SetOnPoisonedFn(fn)
	self.onpoisoned = fn
end

function Whitneypoison:SetOnPoisonDoneFn(fn)
	self.onpoisondone = fn
end

function Whitneypoison:SetOnCuredFn(fn)
	self.oncured = fn
end

--- Add an effect to be spawned when poisoning
-- @param prefab The prefab to spawn as the effect
-- @param offset The offset from the poisoning entity/symbol that the effect should appear at
-- @param followsymbol Optional symbol for the effect to follow
function Whitneypoison:SetFXOffset(offset)
	self.offset.x = offset.x
	self.offset.y = offset.y
	self.offset.z = offset.z
end

function Whitneypoison:SetFXScale(x,y,z)
	self.xscale = x
	self.yscale = y
	self.zscale = z
end

function Whitneypoison:IsPoisoned()
	return self.poisoned
end

function Whitneypoison:OnRemoveEntity()
	self:KillFX()
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

function Whitneypoison:Poison(isGas, loadTime, level, load)
	if loadTime or self:CanBePoisoned(isGas) then

		local lv = level or 1
		self:LevelDelta(lv, load)

		self.inst:AddTag("whitneypoisoned")
		self.poisoned = true
		self.start_time = loadTime or GetTime()

		if self.onpoisoned then
			self.onpoisoned(self.inst)
		end

		if self.task then
			self.task:Cancel()
			self.task = nil
		end

		self:DoPoison()
	end
end

function Whitneypoison:GetDamageRampScale()
	if not self.start_time then
		return 0
	else
		local scale = 1
		for i,v in pairs(TUNING.PLANTVEX_DAMAGE_RAMP) do
			if self.poison_level == v.level then
				scale = v.damage_scale
			end
		end

		return scale
	end
end

function Whitneypoison:GetIntervalRampScale()
if not self.start_time then
		return 0
	else
		local scale = 1
		for i,v in pairs(TUNING.PLANTVEX_DAMAGE_RAMP) do
			if self.poison_level == v.level then
				scale = v.interval_scale
			end
		end

		return scale
	end
end

function Whitneypoison:GetFXName()
	local plv = self:GetPoisonLevel()
	-- print(plv)
	if plv == 0 then
		return "attached"
	elseif plv == 1 then
		return "attached"
	elseif plv == 2 then
		return "center"
	elseif plv == 3 then
		return "center_idle"
	elseif plv == 4 then
		return "left"
	elseif plv == 5 then
		return "left_idle"
	elseif plv == 6 then
		return "right"
	elseif plv == 7 then
		return "right_idle"
	elseif plv == 8 then
		return "confine"
	end
	return "attached"
end

function Whitneypoison:SpawnFX(name, load)
	if string.sub(name, -5, -1) ~= "_idle" or load then
		self:KillFX()

		local fx = SpawnPrefab("poisonfx_"..name)
		-- print(fx.prefab)
		if fx then
			fx.Transform:SetScale(self.xscale,self.yscale,self.zscale)
			self.inst:AddChild(fx)
			fx.Transform:SetPosition(self.offset.x, self.offset.y, self.offset.z)
			table.insert(self.fxchildren, fx)
		end

		self.fxspawnedalready = true
	end
end

function Whitneypoison:DoPoisonDamage(damage)
	if not self.inst.components.health.invincible and self.vulnerabletopoisondamage and self.poison_damage_scale > 0 then
		if damage > 0 then
			-- self.inst.components.health:DoDelta(-damage*self.poison_damage_scale, false, "plantvex",nil,nil,true)
												-- amount,overtime,cause,ignore_invincible,afflicter,ignore_absorb
			self.inst.components.health:DoDelta(-math.min(self.inst.components.health.currenthealth*self.poison_damage_scale*0.02, MaxPoisonDamage), false, "plantvex",nil,nil,true)
		end
	end
end

function Whitneypoison:DoPoison(dt)
	if self.poisoned then
		local ramp_scale = self:GetDamageRampScale()

		if self.duration > 0 then
			if self.start_time and GetTime() - self.start_time >= self.duration then
				if dt and self.inst.components.health and self.vulnerabletopoisondamage then
					local intervals = math.floor(dt / self.interval)
					local damage = self.damage_per_interval*intervals --Ignore ramp scale here since we're doing a bunch of catch up
					self:DoPoisonDamage(damage)
					-- self.inst:PushEvent("poisondamage", {damage=damage})
				end
				-- self:DonePoisoning()
				self:Cure(nil,true,nil)
			else
				if not self.inst:IsInLimbo() then
					if self.inst.components.health and self.vulnerabletopoisondamage then
						if not dt then dt = 1 end
						local damage = self.damage_per_interval*dt*ramp_scale
						self:DoPoisonDamage(damage)
						-- self.inst:PushEvent("poisondamage", {damage=damage})
					end
				end
			end
		else
			if self.inst.components.health and self.vulnerabletopoisondamage then
				local damage = self.damage_per_interval*ramp_scale
				self:DoPoisonDamage(damage)
				-- self.inst:PushEvent("poisondamage", {damage=damage})
			end
			-- self:SpawnFX()
		end
	end

	if self.poisoned then
		local interval_scale = self:GetIntervalRampScale()
		self.task = self.inst:DoTaskInTime(self.interval*interval_scale, function() self:DoPoison() end)
	end
end

function Whitneypoison:DonePoisoning(full)
	self:ClearPoison()

	self:KillFX(full)
	self.poisoned = false
	self.start_time = nil
	self.inst:RemoveTag("whitneypoisoned")

	if self.task then
		self.task:Cancel()
		self.task = nil
	end

	if self.onpoisondone then
		self.onpoisondone(self.inst)
	end
end

local function ImmunityOver(inst)
	local whitneypoison = inst.components.whitneypoison
	if whitneypoison then
		whitneypoison.immune = false
		whitneypoison:KillFX()
	end
end

function Whitneypoison:Cure(curer, give_immunity, immunity_duration, full)
	self:DonePoisoning(full)

	-- if curer and curer.components.finiteuses then
	-- 	curer.components.finiteuses:Use()
	-- elseif curer and curer.components.stackable then
	-- 	curer.components.stackable:Get(1):Remove()
	-- end

	if self.oncured then
		self.oncured()
	end

	if give_immunity then
		if self.immunetask then
			self.immunetask:Cancel()
		end
		self.immune = true
		self.immunetask = self.inst:DoTaskInTime(immunity_duration or TUNING.PLANTVEX_IMMUNE_DURATION, ImmunityOver)
	end
end

function Whitneypoison:SetBlockAll(blockall)
	if not self.blockall then
		self:Cure()
	end

	self.blockall = blockall
end

function Whitneypoison:KillFX(full)
	self.fxspawnedalready = false
	for k,v in pairs(self.fxchildren) do
		if full then
			v:DoTaskInTime(self.confinetime, function () v:Kill() end)
		else
			v:Kill()
		end
		self.fxchildren[k] = nil
	end
end

function Whitneypoison:OnRemoveFromEntity()
	self:Cure()
	self.inst:RemoveTag("whitneypoison")
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

--#srosen need to save/load immune data too
function Whitneypoison:OnSave()
	return
	{
		poisonlevel = self.poison_level,
		poisoned = self.poisoned,
		poisontimeleft = self.start_time and self.duration - (GetTime() - self.start_time) or nil,
	}
end

function Whitneypoison:OnLoad(data)
	if data.poisoned and data.poisontimeleft then
		self.poison_level = data.poisonlevel or 1
		self:Poison(false, data.poisontimeleft, self.poison_level, true)
	end
end
--[[
function Whitneypoison:IsPoisonBlockerEquiped()
	if self.blockall then
		return true
	end

	-- check armour
	if self.inst.components.inventory then
		for k,v in pairs (self.inst.components.inventory.equipslots) do
			if v.components.equippable and v.components.equippable:IsPoisonBlocker() then
				return true
			end
		end
	end

	return false
end

function Whitneypoison:IsPoisonGasBlockerEquiped()
	if self.blockall then
		return true
	end

	-- check armour
	if self.inst.components.inventory then
		for k,v in pairs (self.inst.components.inventory.equipslots) do
			if v.components.equippable and v.components.equippable:IsPoisonGasBlocker() then
				return true
			end
		end
	end

	return false
end
]]--


return Whitneypoison
