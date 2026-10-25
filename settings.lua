data:extend({
    {
        type = "bool-setting",
        name = "aft-separate-underground-tiers",
        setting_type = "startup",
        default_value = false,
    },
    {
        type = "string-setting",
        name = "aft-recipe-simplification",
        setting_type = "startup",
        default_value = "off",
        allowed_values = {"off", "fewer-intermediates", "pipes-only"},
    },
})
