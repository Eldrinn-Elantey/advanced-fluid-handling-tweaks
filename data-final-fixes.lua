if not mods["underground-pipe-pack"] then return end

local AFH_GROUP = "advanced-underground-piping"
local OUR_SUBGROUP = "aft-fluid-handling"

-- Item names a valve entity refers to, through either mining results or placeable_by.
local function referenced_items(entity)
    local names = {}
    local minable = entity.minable
    if minable then
        names[#names + 1] = minable.result
        for _, result in pairs(minable.results or {}) do
            if result.type == nil or result.type == "item" then
                names[#names + 1] = result.name
            end
        end
    end
    if entity.placeable_by then
        -- Can be a single ItemToPlace or an array of them.
        if entity.placeable_by.item then
            names[#names + 1] = entity.placeable_by.item
        else
            for _, place in pairs(entity.placeable_by) do
                names[#names + 1] = place.item
            end
        end
    end
    return names
end

-- Advanced Fluid Handling ships valve entities whose item prototypes no longer exist
-- (the SE compatibility item folder was removed upstream). A dangling item reference
-- crashes the data stage in assignID, so create whatever is missing.
do
    -- Base to clone: the Configurable Valves item if present, otherwise vanilla pipe.
    local template = data.raw.item["configurable-valve"] or data.raw.item["pipe"]
    if not template then
        log("[aft] No item prototype available as a template, skipping missing item creation.")
    else
        local added, seen = {}, {}
        for _, entity in pairs(data.raw.valve or {}) do
            for _, name in pairs(referenced_items(entity)) do
                if not data.raw.item[name] and not seen[name] then
                    seen[name] = true
                    local item = table.deepcopy(template)
                    item.name = name
                    item.localised_name = {"item-name.aft-generated-valve"}
                    item.localised_description = {"item-description.aft-generated-valve"}
                    -- Several valves can point at the same item (e.g. every threshold of a
                    -- family shares one item). Prefer the entity actually named after it.
                    item.place_result = data.raw.valve[name] and name or entity.name
                    item.hidden = true
                    item.order = "z-" .. name
                    added[#added + 1] = item
                    log("[aft] Creating missing item '" .. name .. "' for valve '" .. entity.name .. "'.")
                end
            end
        end
        if #added > 0 then data:extend(added) end
    end
end

-- Advanced Fluid Handling adds its own item group. Move fluid handling buildings into it,
-- so they stop being split across two tabs. Selection is by the type of the entity an item
-- places: vanilla subgroups are no help here, since they scatter the storage tank into
-- "storage", the offshore pump into "extraction-machine", and mix pipes together with
-- electric poles in "energy-pipe-distribution".
if data.raw["item-group"][AFH_GROUP] then
    local FLUID_ENTITY_TYPES = {
        ["pipe"] = true,
        ["pipe-to-ground"] = true,
        ["storage-tank"] = true,
        ["pump"] = true,
        ["valve"] = true,
        ["offshore-pump"] = true,
    }

    data:extend({
        {
            type = "item-subgroup",
            name = OUR_SUBGROUP,
            group = AFH_GROUP,
            order = "0", -- sorts ahead of the subgroups Advanced Fluid Handling defines
        },
    })

    local function entity_type(name)
        for type in pairs(FLUID_ENTITY_TYPES) do
            if data.raw[type] and data.raw[type][name] then return type end
        end
    end

    for _, category in pairs({data.raw.item, data.raw["item-with-entity-data"]}) do
        for _, item in pairs(category) do
            local subgroup = data.raw["item-subgroup"][item.subgroup or ""]
            -- Leave alone whatever already sits on the Advanced Fluid Handling tab.
            if item.place_result and entity_type(item.place_result)
                and not (subgroup and subgroup.group == AFH_GROUP) then
                item.subgroup = OUR_SUBGROUP

                -- A recipe inherits the subgroup of its product unless it sets its own.
                local recipe = data.raw.recipe[item.name]
                if recipe and recipe.subgroup then recipe.subgroup = OUR_SUBGROUP end
            end
        end
    end
end

-- Configurable Valves replaces what the Advanced Fluid Handling valves do, so hide them
-- rather than offer two parallel sets. Prototypes stay in place: removing them would
-- delete already built valves from existing saves.
if mods["configurable-valves"] then
    local hidden_recipes = {}

    for _, entity in pairs(data.raw.valve or {}) do
        -- ponytail: treats every type="valve" entity as Advanced Fluid Handling's.
        -- Nothing else defines them today; narrow by name prefix if that changes.
        for _, name in pairs(referenced_items(entity)) do
            local item = data.raw.item[name]
            if item then item.hidden = true end

            local recipe = data.raw.recipe[name]
            if recipe and not hidden_recipes[name] then
                hidden_recipes[name] = true
                recipe.enabled = false
                recipe.hidden = true
                log("[aft] Disabling Advanced Fluid Handling valve recipe '" .. name .. "'.")
            end
        end
    end

    -- A technology unlock would switch the recipes back on when researched.
    for _, technology in pairs(data.raw.technology) do
        for index = #(technology.effects or {}), 1, -1 do
            local effect = technology.effects[index]
            if effect.type == "unlock-recipe" and hidden_recipes[effect.recipe] then
                table.remove(technology.effects, index)
            end
        end
    end
end
