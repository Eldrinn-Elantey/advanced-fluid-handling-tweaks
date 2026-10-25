-- Recipe simplification follows Less Advanced Fluid Handling 0.2.1 by Harag, licensed under
-- CC BY 4.0: https://mods.factorio.com/mod/underground-pipe-pack-simplified
-- Changed here: a three-value setting replaces lafh_only_pipes, the space tier remnants are dropped,
-- and repeated coupler entries add up.
-- It runs in the data stage, as the original does, so data-updates edits from other mods land on top.
if not mods["underground-pipe-pack"] then return end

local mode = settings.startup["aft-recipe-simplification"].value
if mode == "off" then return end
local pipes_only = mode == "pipes-only"

-- Advanced Fluid Handling builds each of these once per tier. Pipe recipes are named
-- <variant><suffix>-pipe, the mini pumps <variant><suffix>.
local VARIANTS = {
    "one-to-one-forward",
    "one-to-two-perpendicular",
    "one-to-three-forward",
    "one-to-four",
    "underground-i",
    "underground-L",
    "underground-t",
    "underground-cross",
    "4-to-4",
    "underground-mini-pump",
}

-- segment_pipes is how many regular pipes one segment of that tier turns into.
local TIERS = {
    {suffix = "", coupler = "small-pipe-coupler", segment = "underground-pipe-segment-t1", segment_pipes = 1},
    {suffix = "-t2", coupler = "medium-pipe-coupler", segment = "underground-pipe-segment-t2", segment_pipes = 2},
    {suffix = "-t3", coupler = "large-pipe-coupler", segment = "underground-pipe-segment-t3", segment_pipes = 3},
}

local recipes = data.raw.recipe

for _, tier in pairs(TIERS) do
    for _, variant in pairs(VARIANTS) do
        local recipe = recipes[variant .. tier.suffix .. "-pipe"] or recipes[variant .. tier.suffix]
        if recipe then
            local pipes, couplers, swivels = 0, 0, 0
            local ingredients = {}

            for _, ingredient in ipairs(recipe.ingredients or {}) do
                if ingredient.name == "pipe" then
                    pipes = pipes + ingredient.amount
                elseif ingredient.name == tier.segment then
                    pipes = pipes + ingredient.amount * tier.segment_pipes
                elseif ingredient.name == tier.coupler then
                    couplers = couplers + ingredient.amount
                elseif ingredient.name == "swivel-joint" then
                    swivels = swivels + ingredient.amount
                else
                    -- Engines and plates of the mini pumps, or whatever another mod has added.
                    ingredients[#ingredients + 1] = ingredient
                end
            end

            if pipes_only then
                -- A swivel joint costs two pipes and a coupler of any tier costs one.
                local total = pipes + swivels * 2 + couplers
                if total > 0 then ingredients[#ingredients + 1] = {type = "item", name = "pipe", amount = total} end
            else
                -- Every tier takes the small coupler, so the medium and large ones drop out.
                if swivels > 0 then ingredients[#ingredients + 1] = {type = "item", name = "swivel-joint", amount = swivels} end
                if couplers > 0 then ingredients[#ingredients + 1] = {type = "item", name = "small-pipe-coupler", amount = couplers} end
                if pipes > 0 then ingredients[#ingredients + 1] = {type = "item", name = "pipe", amount = pipes} end
            end

            recipe.ingredients = ingredients
        end
    end
end

-- No recipe consumes these after the rewrite above.
local unused = {
    "medium-pipe-coupler",
    "large-pipe-coupler",
    "underground-pipe-segment-t1",
    "underground-pipe-segment-t2",
    "underground-pipe-segment-t3",
}
if pipes_only then
    unused[#unused + 1] = "swivel-joint"
    unused[#unused + 1] = "small-pipe-coupler"
end

for _, name in pairs(unused) do
    if recipes[name] then recipes[name].hidden = true end
end
