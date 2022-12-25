

AddStategraphPostInit("wilson", function(self)
    local catchfish = self.states["catchfish"]
    local _onenter = catchfish.onenter
    catchfish.onenter = function (inst, build)
        if build == nil then
            inst.AnimState:PlayAnimation("fish_catch")
            inst.AnimState:OverrideSymbol("fish01", "fish01", "fish01")
            return
        end
        return _onenter(inst, build)
    end
end)
