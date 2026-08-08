# Advanced Fluid Handling Tweaks

Small companion mod for Factorio 2.0 (tested target: headless server with Space Exploration + Krastorio 2), inert unless the mod it reacts to is active.

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

## Building

Run `release.bat` to produce `build\advanced-fluid-handling-tweaks_<version>.zip`, or `release.bat -Install` to drop it straight into the local `mods` folder. Pushing a tag matching the version in `info.json` builds the same zip in CI and publishes it as a GitHub release.

## Licensing note

This mod contains no code, graphics, locale text or other assets from `underground-pipe-pack` or `configurable-valves`. It only reads and modifies their prototypes at load time through the official Factorio data stage API (`data.raw`, `table.deepcopy`, `data:extend`), which is the standard mechanism for compatibility patches.
