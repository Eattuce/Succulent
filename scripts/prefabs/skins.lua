local prefabs = {}

for NAME,DATA in pairs(MYSKINS) do
    table.insert(prefabs, CreatePrefabSkin(NAME,DATA))
end
return unpack(prefabs)