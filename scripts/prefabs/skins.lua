local prefabs = {}

for NAME,DATA in pairs(SUCCULENT_SKINS) do
    table.insert(prefabs, CreatePrefabSkin(NAME,DATA))
end
return unpack(prefabs)