# Technical notes

How Advanced Fluid Handling Tweaks patches the prototypes of Advanced Fluid Handling (internal name `underground-pipe-pack`). The player-facing description is in the [README](https://github.com/Eldrinn-Elantey/advanced-fluid-handling-tweaks/blob/master/README.md).

## Missing space valve items

Advanced Fluid Handling used to ship a Space Exploration compatibility folder that defined item prototypes such as `80-overflow-space-valve`. Upstream removed that folder in [fb065ae](https://github.com/TheStaplergun/pipemod/commit/fb065ae8854d41ca7cc0e3dfaeffbc73ebac282f), but the valve entities still reference those items through `minable.result` and `placeable_by`. A dangling item reference aborts the data stage:

```
Error in assignID: item with name '80-overflow-space-valve' does not exist.
Source: 10-overflow-space-valve (valve).
```

`data-final-fixes.lua` walks every prototype in `data.raw.valve`, collects the item names it references, and creates an item for each name that has no prototype. Each new item is a `table.deepcopy` of an existing runtime prototype (`configurable-valve` from Configurable Valves if active, otherwise the vanilla `pipe` item), renamed, marked hidden, and pointed back at the valve entity. The mod logs each item it creates.

## Fluid handling tab

Advanced Fluid Handling adds its own item group, which leaves vanilla pipes, pumps and tanks on a separate tab. The mod moves an item into that group when it places an entity of type `pipe`, `pipe-to-ground`, `storage-tank`, `pump`, `valve` or `offshore-pump`, whichever mod it comes from.

Subgroups do not work as the criterion: vanilla puts the storage tank in `storage`, the offshore pump in `extraction-machine`, and mixes pipes with electric poles in `energy-pipe-distribution`. Each source subgroup gets a mirror subgroup on the tab, so items keep their rows and relative order. Items already on the Advanced Fluid Handling tab stay where their own mod placed them.

## Valves hidden under Configurable Valves

With Configurable Valves active, the mod sets `enabled = false` and `hidden = true` on the Advanced Fluid Handling valve recipes and `hidden = true` on their items. It also drops the matching `unlock-recipe` technology effects, since research would otherwise switch the recipes back on.

The mod hides these prototypes instead of removing them. Removing them would erase already built valves from existing saves, while hiding is reversible and safe to add to a running server.

## Underground tiers

Advanced Fluid Handling marks each tiered prototype with `npt_compat = {mod = "afh", tier = N}`. With the "Underground pipes connect within their own tier only" setting on, the mod gives every underground pipe connection of such a prototype the connection category `afh-t<N>`, so only connections of the same tier link up.

## Recipe simplification

`data.lua` rewrites the recipes of the underground pipe variants, the 4-to-4 pipe and the mini pumps for all three tiers. For each recipe it sums regular pipes, tier segments, couplers and swivel joints, keeps every other ingredient as is, and writes the sums back:

- A segment counts as one, two or three pipes for tiers 1, 2 and 3.
- Fewer intermediates keeps swivel joints and replaces medium and large couplers with small ones.
- Pipes only turns each swivel joint into two pipes and each coupler into one.

Afterwards the mod hides the recipes of intermediates that no rewritten recipe consumes. Their items stay. The rewrite runs in the data stage, as the original Less Advanced Fluid Handling does, so recipe changes other mods make in `data-updates.lua` apply on top of it.
