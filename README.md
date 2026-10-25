# Advanced Fluid Handling Tweaks

Small companion mod for Factorio 2.1 (tested target: headless server with Space Exploration + Krastorio 2), inert unless the mod it reacts to is active.

## Restores the missing space valve items

Advanced Fluid Handling (internal name `underground-pipe-pack`) used to ship a Space Exploration compatibility folder that defined item prototypes such as `80-overflow-space-valve`. That folder was removed upstream
(https://github.com/TheStaplergun/pipemod/commit/fb065ae8854d41ca7cc0e3dfaeffbc73ebac282f), while valve entities still reference those items through `minable.result` / `placeable_by`. A dangling item reference aborts the data stage:

```
Error in assignID: item with name '80-overflow-space-valve' does not exist.
Source: 10-overflow-space-valve (valve).
```

Every prototype in `data.raw.valve` is walked, the item names it references are collected, and each name without an item prototype gets one: a `table.deepcopy` of an existing runtime prototype (`configurable-valve` from Configurable Valves if active, otherwise the vanilla `pipe` item), renamed, marked hidden, and pointed back at the valve entity. Each created item is logged.

## One tab for fluid handling

Advanced Fluid Handling adds its own item group, which leaves vanilla pipes, pumps and tanks on a separate tab. Items are moved into that group when they place an entity of type `pipe`, `pipe-to-ground`, `storage-tank`, `pump`, `valve` or `offshore-pump`, whichever mod they come from, so both sets sit together.

Subgroups are not usable as the criterion here: vanilla puts the storage tank in `storage`, the offshore pump in `extraction-machine`, and mixes pipes together with electric poles in `energy-pipe-distribution`. Items already sitting on the Advanced Fluid Handling tab are left where their own mod placed them.

## Hides the Advanced Fluid Handling valves under Configurable Valves

With Configurable Valves installed the two valve sets overlap, so the Advanced Fluid Handling ones are switched off: their recipes get `enabled = false` and `hidden = true`, their items get `hidden = true`, and matching `unlock-recipe` technology effects are dropped so research cannot switch them back on.

Prototypes are deliberately not removed. Deleting them would erase already built valves from existing saves; hiding is reversible and safe to add to a running server.

## Simpler underground pipe recipes

The startup setting "Simplify Advanced Fluid Handling recipes" is off by default. Turned on, it rewrites the recipes of the underground pipes, the 4-to-4 pipe and the mini pumps of all three tiers so they take regular pipes instead of tiered segments and couplers:

| Value | Ingredients that replace segments and couplers |
|---|---|
| Off | none, recipes stay as Advanced Fluid Handling defines them |
| Fewer intermediates | pipes, swivel joints and small pipe couplers |
| Pipes only | pipes |

A segment turns into one, two or three pipes depending on its tier. In Pipes only, each swivel joint adds two pipes and each coupler one. Engines, plates and any ingredient another mod has added stay in the recipe. The mod then hides the recipes of intermediates that nothing consumes any more; their items remain.

The rewrite runs in the data stage, so recipe changes other mods make in `data-updates.lua` apply on top of it.

## Licensing note

This mod contains no code, graphics, locale text or other assets from `underground-pipe-pack` or `configurable-valves`. It only reads and modifies their prototypes at load time through the official Factorio data stage API (`data.raw`, `table.deepcopy`, `data:extend`), which is the standard mechanism for compatibility patches.

The recipe simplification in `data.lua` adapts [Less Advanced Fluid Handling](https://mods.factorio.com/mod/underground-pipe-pack-simplified) 0.2.1 by Harag, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Changes: a three-value setting replaces its `lafh_only_pipes` toggle, the leftovers of the commented-out space tier are gone, and repeated coupler entries add up instead of overwriting each other.
