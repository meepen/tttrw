# tttrw
## A Garry's Mod TTT Rewrite with focus on performance and role customization.
##### **Technically just a round-based gamemode with TTT roles by default

---
### Objective

Create a Garry's Mod TTT Rewrite with focus on clientside customization, extendability and ease of modding.

### Purpose

The base TTT gamemode has long been overdue for a complete overhaul, with the lack of customization and lack of proper features such as prediction on weapons (properly and done right) as well as the growing demand for customizing roles.

### Advantages over original TTT

- This gamemode is completely written from the ground up with a small amount of developers, making it easy to read and section off code properly.
- Having a role system allows developers to add their own roles with own logic and new teams and have role selection be all overwritten easily and maintainably.
- Clientside customization.
- Built for performance around x64 branch of Garry's Mod.

--- 

## Shared Hooks
### These are hooks that allow developers to extend the gamemode or change behaviors.

---

#### `TTTPrepareRoles`(`Team`, `Role`) -> `no value`
**use this to set up custom teams and roles.**
**see: [sh_roles.lua](https://github.com/meepen/tttrw/blob/960496a/gamemode/sh_roles.lua#L156)**

#### `TTTUpdatePlayerSpeed`(`ply`, `data`) -> `no value`
**adds a multiplier to player speed**
add a entry to `data` with a value of a multiplier to change the speed of the player.
```lua
hook.Add("TTTUpdatePlayerSpeed", "slow_down", function(ply, data)
	local sloweduntil = ply:GetSlowedUntil()

	if (sloweduntil > CurTime() and ply:GetSlowedStart() < CurTime()) then
		data.SlowMultiplier = 0.5
	end
end)
```


### `TTTGetHiddenPlayerVariables`(`variable_list`) -> `no value`
**adds hidden variables for players that are predicted, adds accessors Player.Get<Name> and Set<Name>**
**calls hook `OnPlayer<Name>Change`(`ply`, `old value`, `new value`)**
```lua
hook.Add("TTTGetHiddenPlayerVariables", "slowed_value", function(vars)
	table.insert(vars, {
		Name = "SlowedUntil",
		Type = "Float",
		Default = -math.huge
	})
	table.insert(vars, {
		Name = "SlowedStart",
		Type = "Float",
		Default = -math.huge
	})
end)
```

#### `InitializeBodyData`(`variables`, `info`) -> `no value`
todo: document (variables = tabs in the body menu)

#### `BodyDataInitialized`(`body_info_container`) -> `no value`
todo

#### `OnBodyInfoInitialized`(`ttt_body_info`) -> `no value`
todo

#### `InitializeNetworking`() -> `table`
**see: `TTTPrepareNetworkingVariables`**
internal, do not use

#### `TTTPrepareNetworkingVariables`(`variable_list`) -> `no value`
todo
```lua
hook.Add("TTTPrepareNetworkingVariables", "RoundState", function(vars)
	table.insert(vars, {
		Name = "RoundState",
		Type = "Int",
		Enums = {
			Ended = 0,
			Preparing = 1,
			Active = 2,
			Waiting = 3
		},
		Default = 3
	})
end)
```

#### `TTTInitWeaponNetVars`(`ent`) -> `no value`
**called in SWEP:SetupDatatables**
```lua
hook.Add("TTTInitWeaponNetVars", "example", function(e)
	e:NetVar("HowCool", "Int", 0)
end)
```

#### `TTTWeaponInitialize`(`wep`) -> `no value`
**called in SWEP:Initialize**

#### `SetupPlayerNetworking`(`fake entity`) -> `no value`
todo
```lua
	fake:NetworkVar("Karma", "Int")
```

#### `TTTRWPlayerInspectBody`(`ply`, `body`, `pos`, `hidden`)

#### `PlayerTargetChanged`(`ply`, `target`)
**called when player looks at a different player**

#### `FormatPlayerText`(`sender`, `str`) -> `string or no value`

#### `TTTPrepareRound`() -> `no value`

#### `TTTBeginRound`() -> `no value`

#### `TTTEndRound`() -> `no value`

#### `TTTAddPermanentEntities`(`list of classes`) -> `no value`
**passed to second argument of game.CleanupMap**

#### `TTTGetRankPrintName`(`usergroup`) -> `string`

## Clientside hooks

#### `TTTGetScoreboardLogoPanel`() -> `Panel`

#### `TTTRWPopulateScoreboardOptions`(`DermaMenu`, `ply`) -> `no value`

#### `TTTGetPlayerColor`(`ply`) -> `color`

#### `TTTPopulateSettingsMenu`(`ttt_settings panel`) -> `no value`

#### `ShowEndRoundScreen`() -> `no value`

#### `TTTDrawHitmarkers`() -> `no value`
**called in HUDPaint**

#### `TTTRWDrawSpectatorHUD`() -> `no value`
**called in HUDPaint**

#### `TTTDrawDamagePosition`()
**called in HUDPaintBackground**

#### `TTTGetFOV`(`fov`) -> `number`

#### `PlayerHit`(`shooter`, `damage`, `damage type`, `hitgroup`) -> `no value`

#### `PlayerDisconnected`(`ply`) -> `no value`
**just adds it via game_event to client for ease**

#### `PlayerSpawn`(`ply`) -> `no value`
**just adds it via game_event to client for ease**

#### `PlayerConnected`(`ply`) -> `no value`
**just adds it via game_event to client for ease**

#### `PlayerConnected`(`ply`) -> `no value`
**just adds it via game_event to client for ease**

#### `PlayerConnected`(`ply`) -> `no value`
**just adds it via game_event to client for ease**

#### `CloseRadialBuyMenu`(`forced`) -> `no value`

#### `ShowQuickChat`(`ply`, `pressed`) -> `no value`

#### `ShowHelp`(`ply`, `pressed`) -> `no value`
**just adds it via game_event to client for ease**

#### `ShowSpare1`(`ply`, `pressed`) -> `no value`
**just adds it via game_event to client for ease**

#### `ShowSpare2`(`ply`, `pressed`) -> `no value`
**just adds it via game_event to client for ease**

#### `PlayerSetHandsModel`(`ply`, `hands entity`) -> `no value`

## Serverside hooks

#### `TTTGrenadeStuck`(`grenade entity`)

#### `PlayerTakeDamage`(`victim`, `attacker`, `damage`, `damageinfo`) -> `no value`
**listener hook only**

#### `TTTShouldPlayerScream`(`victim`, `attacker`, `damageinfo`) -> `bool`

#### `TTTPlayerScream`(`victim`) -> `no value`

#### `TTTPlayerGiveWeapons`(`ply`) -> `no value`

#### `PlayerPostLoadout`(`ply`) -> `no value`
**listener hook only**

#### `TTTBodyIdentified`(`victim`, `ply`) -> `no value`

#### `TTTOrderedEquipment`(`ply`, `class`, `true?`, `cost`) -> `no value`

#### `TTTTraitorButtonActivated`(`button`, `ply) -> `no value`

#### `TTTCanUseTraitorButton`(`button`, `ply`) -> `boolean`

#### `AllowPlayerRTV`(`ply`) -> `boolean`

#### `PlayerRTVFailed`(`ply`, `reason`) -> `no value`

#### `MapHasBeenRTVed`() -> `no value`

#### `DoPlayerRTV`(`ply`, `votes left`) -> `no value`

#### `TTTRWUpdateVoiceState`(`hear`, `tbl`) -> `no value`
**todo: document**

#### `TTTKarmaGivePenalty`(`ply`, `penalty`, `victim`) -> `boolean`

#### `ShouldChangeMap`() -> `boolean`

#### `ChangeMap`(`reason`) -> `value if overridden`

#### `TTTRemoveIneligiblePlayers`(`player list`) -> `no value`

#### `TTTCreatePlayerRagdoll`(`ply`, `attacker`, `damageinfo`) -> `entity`

#### `PlayerRagdollCreated`(`ply`, `rag`, `attacker`, `damageinfo`) -> `no value`

#### `TTTPlayerRemoved`(`ply`) -> `no value`

#### `TTTRolesSelected`() -> `no value`

#### `TTTSelectRoles`(`players`) -> `no value`

#### `TTTRoundStart`(`players`) -> `boolean`
**returns if round should start**

#### `TTTOverrideWin`(`winning team`, `winners`, `why`) -> `winning team`, `winners`, `why`

#### `TTTRoundEnd`(`winning team`, `winners`, `why`) -> `no value`

#### `TTTActivePlayerDisconnected`(`ply`)

#### `TTTHasRoundBeenWon`(`players`, `roles`) -> `has won`, `winning team`, `time ran out:boolean`

#### `PlayerLoadout`(`ply`) -> `no value`

#### `PlayerSetModel`(`ply`) -> `no value`

#### `PlayerSetSpeed`(`ply`, `speed`, `runspeed`) -> `no value`

#### `PlayerSelectSpawnPosition`(`ply`) -> `vector

