# Advanced Fluid Handling Tweaks

[![FACTORIO](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https://mods.factorio.com/api/mods/advanced-fluid-handling-tweaks&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAACGVBMVEUAAAABAAAAAQAAAAEBAQEAAQEBAQDYhDvehje8eDmAgYDShj+ZZjPfhTfDdTiPUyvrkDynZTDafTTSeziCTSqeZzK2dTXWgT2NUzSAgQCMWjhtRjTVfTZ3QyJBQEDefzRrLA1gLQdwLASFOQtPLinkjELLeDZtLwxJJBKWPQ+cSxtkMiJdOiP1kz1XIgawYy2STyZlPi63dDpxRCVeIQbFjlVXOSmcbDusbjZ4Mgx2OhS/YCHTpW5GIhRnOhtDLCW2czeEOg+FNA2oYy7KllwnGhbNZjK/dTYpHxh9UTFOKhiAAQFIMCY3IhcdEg4oHBkpGxUZEBFbNhsvIh95RSFpOhsbDQ0AAQAyIxkAAABJMyQqIh4oHBq2bCzgijunZTSfViqtYy2yfU2udT6xay2zaiu3aii1aC2gXCynWiiuYiuYWS2qc0e5eD25bCqjYSmcWiSdVyO1aCulYyqZVCaXSR24dT2yaCmXVCWlXSevZiqFRSDEgEivaS2YXyyvZCqnYCq2bzGseUWpZSqJVSexajKyZyh/Ox2SYDaiZSqVVSaybje2aCmCPBiqYSacYSqlZCzBayurYSmdXy2vaSmfWia6dz66ayZyPh6NUyekXCamZiqrZSyoYSu3bTO7aCvFbiehVyNNJxdvSCuaXClLKRd/SSOiYSm6bSu5aii0YiaHQxxxPBySVidHJxlzOx1YLRdTOCGeXii5isPXAAAAXXRSTlMAAAAAAAAAcN1nAlUFF8mflsS//v64O12UAmBUPcEEv9t6e9+7aKHaDhHf/RbeeH7Cb27Hd3zjGv7YDRDd/ppnxNp4edy2BcYzWFQClFg2ufy6vo6gwBQDUQFp32wXrE9IAAAAvElEQVQYGQXBPyuEAQAH4N/zXlJKdimTstxCBouRSOjcnzK4T6ZEce+dk7AwGQ0m020WMSulnLvzPJIkJtP8JDKRzPA9a//2K0XGFTG3d8eue/Apmd8C4OZDsnAAoONdstiigyblWyxpUhpY1tAzUK2j+1qMi2qTkhUNui9JsdpER7GmpfScdQ09pNg45Ao1+k9D2VQDcPEwke0jAE4e/9iBNqe0z64jpn4ro/rxuX6dy4hiVIyPKIcmSf4BuN02xRLLCCIAAAAASUVORK5CYII=)](https://mods.factorio.com/mod/advanced-fluid-handling-tweaks) [![COMMUNITY](https://img.shields.io/badge/Discord-Community-blue?logo=discord)](https://discord.gg/FcFEu36QBc) [![GitHub](https://img.shields.io/badge/Github-Source-white?logo=github)](https://github.com/Eldrinn-Elantey/advanced-fluid-handling-tweaks)

A companion mod for [Advanced Fluid Handling](https://mods.factorio.com/mod/underground-pipe-pack) in Factorio 2.1. It fixes a load crash, gathers all fluid handling buildings on one tab, and adds two optional settings for underground pipes.

Without Advanced Fluid Handling the mod does nothing.

## What it does

- Fixes the `Error in assignID: item with name '80-overflow-space-valve' does not exist` crash by creating the valve items Advanced Fluid Handling no longer ships
- Moves pipes, pumps, tanks, valves and offshore pumps from vanilla and other mods onto the Advanced Fluid Handling tab
- Hides the Advanced Fluid Handling valves when Configurable Valves is installed, so you get one valve set instead of two. Valves you already built stay in your save
- Optional startup setting: underground pipes connect only within their own tier, the way vanilla underground belts do. On an existing save this splits fluid networks wherever two tiers meet
- Optional startup setting: underground pipe and mini pump recipes take regular pipes instead of tiered segments and couplers. Fewer intermediates keeps swivel joints and small couplers, Pipes only replaces those too

Both settings are off by default. Implementation details are in the [technical notes](https://github.com/Eldrinn-Elantey/advanced-fluid-handling-tweaks/blob/master/docs/technical-notes.md).

## Compatibility

Works with [Configurable Valves](https://mods.factorio.com/mod/configurable-valves) 1.0.0 or newer. Tested on a headless server with Space Exploration and Krastorio 2.

## Licensing

The recipe simplification adapts [Less Advanced Fluid Handling](https://mods.factorio.com/mod/underground-pipe-pack-simplified) 0.2.1 by Harag, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Changes: a three-value setting replaces its `lafh_only_pipes` toggle, the leftovers of the commented-out space tier are gone, and repeated coupler entries add up instead of overwriting each other.

The mod contains no code, graphics, locale text or other assets from `underground-pipe-pack` or `configurable-valves`. It reads and modifies their prototypes at load time through the Factorio data stage API.
