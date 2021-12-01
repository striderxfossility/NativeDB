
public static exec func DamagePlayer(gameInstance: GameInstance, TEMP_dmg: String, dmgType: String, percentage: String) -> Void {
  let attackData: ref<AttackData>;
  let hitEvent: ref<gameHitEvent>;
  let valuesLost: array<SDamageDealt>;
  let dmgVal: Float = StringToFloat(TEMP_dmg);
  let type: gamedataDamageType = IntEnum(Cast(EnumValueFromString("gamedataDamageType", dmgType)));
  let attackComputed: ref<gameAttackComputed> = new gameAttackComputed();
  attackComputed.SetAttackValue(dmgVal, type);
  attackData = new AttackData();
  attackData.SetAttackType(gamedataAttackType.Ranged);
  hitEvent = new gameHitEvent();
  hitEvent.attackData = attackData;
  hitEvent.attackComputed = attackComputed;
  StatPoolsManager.ApplyDamage(hitEvent, true, valuesLost);
}

public static exec func PrintHealth(gameInst: GameInstance) -> Void {
  let player: ref<GameObject> = GetPlayer(gameInst);
  let playerID: StatsObjectID = Cast(player.GetEntityID());
  let valPerc: Float = GameInstance.GetStatPoolsSystem(gameInst).GetStatPoolValue(playerID, gamedataStatPoolType.Health);
  let val: Float = GameInstance.GetStatPoolsSystem(gameInst).ToPoints(playerID, gamedataStatPoolType.Health, valPerc);
  Log("StatPool: " + EnumValueToString("gamedataStatPoolType", EnumInt(gamedataStatPoolType.Health)));
  Log("Stat %: " + FloatToString(valPerc));
  Log("Stat value: " + FloatToString(val));
}

public static exec func ChangeStatPoolVal(inst: GameInstance, type: String, value: String, opt subtract: String, opt percentage: String) -> Void {
  let factor: Float;
  let player: ref<GameObject>;
  let playerID: StatsObjectID;
  let statPoolSystem: ref<StatPoolsSystem>;
  let statType: gamedataStatPoolType;
  let statVal: Float;
  if StringToBool(subtract) {
    factor = -1.00;
  } else {
    factor = 1.00;
  };
  player = GetPlayer(inst);
  playerID = Cast(player.GetEntityID());
  statVal = StringToFloat(value);
  statType = IntEnum(Cast(EnumValueFromString("gamedataStatPoolType", type)));
  statPoolSystem = GameInstance.GetStatPoolsSystem(inst);
  statPoolSystem.RequestChangingStatPoolValue(playerID, statType, statVal * factor, null, false, StringToBool(percentage));
}

public static exec func Heal(gi: GameInstance, opt valStr: String, opt isScalarStr: String) -> Void {
  let isScalar: Bool;
  let playerID: StatsObjectID = Cast(GetPlayer(gi).GetEntityID());
  let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(gi);
  let val: Float = StringToFloat(valStr);
  if FloatIsEqual(val, 0.00) {
    statPoolsSystem.RequestSettingStatPoolMaxValue(playerID, gamedataStatPoolType.Health, null);
    return;
  };
  if val <= 0.00 {
    return;
  };
  isScalar = StringToBool(isScalarStr);
  if isScalar {
    val = statPoolsSystem.ToPercentage(playerID, gamedataStatPoolType.Health, val);
  };
  statPoolsSystem.RequestSettingStatPoolValue(playerID, gamedataStatPoolType.Health, val, null);
}

public static exec func God1(gi: GameInstance) -> Void {
  SwitchPlayerImmortalityMode(gi, gamecheatsystemFlag.God_Immortal);
}

public static exec func God2(gi: GameInstance) -> Void {
  SwitchPlayerImmortalityMode(gi, gamecheatsystemFlag.God_Invulnerable);
}

public static exec func ToggleShowWeaponsStreaming(gi: GameInstance) -> Void {
  let player: ref<PlayerPuppet> = GetPlayerObject(gi) as PlayerPuppet;
  if IsDefined(player) && IsDefined(player.DEBUG_Visualizer) {
    player.DEBUG_Visualizer.ToggleShowWeaponsStreaming();
  };
}

public static exec func GodClearAll(gi: GameInstance) -> Void {
  let cheatSystem: ref<DebugCheatsSystem> = GameInstance.GetDebugCheatsSystem(gi);
  let player: ref<GameObject> = GetPlayerObject(gi);
  cheatSystem.EnableCheat(player, gamecheatsystemFlag.God_Immortal, false);
  cheatSystem.EnableCheat(player, gamecheatsystemFlag.God_Invulnerable, false);
}

public static func SwitchPlayerImmortalityMode(const gi: GameInstance, cheat: gamecheatsystemFlag) -> Void {
  let cheatSystem: ref<DebugCheatsSystem> = GameInstance.GetDebugCheatsSystem(gi);
  let player: ref<GameObject> = GetPlayerObject(gi);
  if !IsDefined(cheatSystem) {
    return;
  };
  if cheatSystem.ToggleCheat(player, cheat) {
    LogStats(cheat + " cheat changed on PLAYER");
  } else {
    LogStats("Failed to change " + cheat + " cheat on PLAYER");
  };
}

public static exec func Weak(gameInstance: GameInstance, modeStr: String) -> Void {
  let mode: Int32 = StringToInt(modeStr);
  SetFactValue(gameInstance, n"cheat_weak", mode);
  LogStats("Weak cheat mode changed to " + IntToString(mode));
}

public static exec func OP(gameInstance: GameInstance, modeStr: String) -> Void {
  let mode: Int32 = StringToInt(modeStr);
  SetFactValue(gameInstance, n"cheat_op", mode);
  LogStats("OP cheat mode changed to " + IntToString(mode));
}

public static exec func IDDQD(gi: GameInstance, opt iamstiffcorpoguy: String) -> Void {
  if StringToBool(iamstiffcorpoguy) {
    SetFactValue(gi, n"legacy_mode_is_on", 0);
    SetFactValue(gi, n"legacy_hits_on", 0);
    SetFactValue(gi, n"legacy_mode_is_disabled", 1);
  } else {
    SetFactValue(gi, n"legacy_mode_is_on", 1);
    SetFactValue(gi, n"legacy_hits_on", 1);
    SetFactValue(gi, n"legacy_mode_is_disabled", 0);
  };
}

public static exec func Kill(gameInstance: GameInstance) -> Void {
  if GameInstance.GetRuntimeInfo(gameInstance).IsMultiplayer() {
    LogError("exec(Kill) does not work in multiplayer, use \'K\' key instead");
    return;
  };
  Kill_NonExec(gameInstance, GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject() as PlayerPuppet);
}

public static func Kill_NonExec(const gi: GameInstance, player: ref<PlayerPuppet>) -> Void {
  let gameEffectInstance: ref<EffectInstance> = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"killAll", n"kill", player);
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 50.00);
  gameEffectInstance.Run();
}

public static exec func KillAll(gameInstance: GameInstance, radiusStr: String) -> Void {
  if GameInstance.GetRuntimeInfo(gameInstance).IsMultiplayer() {
    LogError("exec(Kill) does not work in multiplayer, use \'L\' key instead");
    return;
  };
  KillAll_NonExec(gameInstance, GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject() as PlayerPuppet, radiusStr);
}

public static func KillAll_NonExec(const gameInstance: GameInstance, player: ref<PlayerPuppet>, opt radiusStr: String) -> Void {
  let gameEffectInstance: ref<EffectInstance>;
  let radius: Float = StringToFloat(radiusStr);
  if FloatIsEqual(radius, 0.00) {
    radius = 20.00;
  };
  gameEffectInstance = GameInstance.GetGameEffectSystem(gameInstance).CreateEffectStatic(n"killAll", n"killAll", player);
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
  gameEffectInstance.Run();
}

public static exec func HealAll(gameInstance: GameInstance, opt radiusStr: String) -> Void {
  let gameEffectInstance: ref<EffectInstance>;
  let player: ref<PlayerPuppet>;
  let radius: Float = StringToFloat(radiusStr);
  if FloatIsEqual(radius, 0.00) {
    radius = 20.00;
  };
  player = GetPlayer(gameInstance);
  gameEffectInstance = GameInstance.GetGameEffectSystem(gameInstance).CreateEffectStatic(n"healAll", n"healAll", player);
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
  gameEffectInstance.Run();
}

public static exec func PrintNPCItemBySlot(gi: GameInstance, slotName: String) -> Void {
  let item: ref<ItemObject>;
  let itemID: ItemID;
  let itemName: String;
  let slotID: TweakDBID;
  let localPlayer: ref<GameObject> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject();
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gi).GetLookAtObject(localPlayer);
  if !IsDefined(target) {
    Log("PrintNPCItemBySlot(): No valid target found!");
    return;
  };
  slotID = TDBID.Create("AttachmentSlots." + slotName);
  item = GameInstance.GetTransactionSystem(gi).GetItemInSlot(target, slotID);
  if !IsDefined(item) {
    return;
  };
  itemID = item.GetItemID();
  itemName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).FriendlyName();
  Log("PrintNPCItemBySlot(): Item in slot: " + slotName + " : " + itemName);
}

public static exec func PrintDPS(gi: GameInstance) -> Void {
  let obj: ref<GameObject> = GameInstance.GetTransactionSystem(gi).GetItemInSlot(GetPlayer(gi), t"AttachmentSlots.WeaponRight");
  let dps: DPSPackage = StatsManager.GetObjectDPS(obj);
  LogStats(EnumValueToString("gamedataDamageType", EnumInt(dps.type)));
  LogStats(FloatToString(dps.value));
}

public static exec func GetAllPerks(gi: GameInstance) -> Void {
  let playerDevData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject());
  let i: Int32 = 0;
  while i < EnumInt(gamedataPerkType.Count) {
    playerDevData.BuyPerk(IntEnum(i));
    i += 1;
  };
}

public static exec func GetQuickhacks(gi: GameInstance) -> Void {
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SuicideLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SuicideLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.GrenadeExplodeLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.GrenadeExplodeLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BrainMeltProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BrainMetlLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BrainMeltLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BrainMeltLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MadnessLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MadnessLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.DisableCyberwareProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.DisableCyberwareLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SystemCollapseLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SystemCollapseLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WhistleProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WhistleLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WhistleLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MemoryWipeLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MemoryWipeLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionLvl4Program", 1);
}

public static exec func EnableFinishers(gi: GameInstance, enable: String) -> Void {
  let val: Bool = StringToBool(enable);
  if val {
    GameInstance.GetQuestsSystem(gi).SetFact(n"DEBUG_FINISHERS_ENABLED", 1);
  } else {
    GameInstance.GetQuestsSystem(gi).SetFact(n"DEBUG_FINISHERS_ENABLED", 0);
  };
}

public static exec func InfiniteStamina(gi: GameInstance, opt enable: String) -> Void {
  let mod: StatPoolModifier;
  let playerID: StatsObjectID;
  let statPoolSys: ref<StatPoolsSystem>;
  let toEnable: Bool = true;
  if NotEquals(enable, "") {
    toEnable = StringToBool(enable);
  };
  playerID = Cast(GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject().GetEntityID());
  statPoolSys = GameInstance.GetStatPoolsSystem(gi);
  if toEnable {
    mod.enabled = true;
    mod.rangeBegin = 0.00;
    mod.rangeEnd = 100.00;
    mod.delayOnChange = false;
    mod.valuePerSec = 1000000000.00;
    statPoolSys.RequestSettingModifier(playerID, gamedataStatPoolType.Stamina, gameStatPoolModificationTypes.Regeneration, mod);
  } else {
    statPoolSys.RequestResetingModifier(playerID, gamedataStatPoolType.Stamina, gameStatPoolModificationTypes.Regeneration);
  };
}

public static exec func NetrunnerTesting(gi: GameInstance) -> Void {
  let equipRequest: ref<EquipRequest>;
  let equipSys: ref<EquipmentSystem>;
  let itemID: ItemID;
  let itemTDBID: TweakDBID;
  let playerID: EntityID;
  let statusEffectSystem: ref<StatusEffectSystem>;
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SuicideProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SuicideLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BlindLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.GrenadeExplodeProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.GrenadeExplodeLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.EMPOverloadLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MadnessProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MadnessLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsNoiseLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.CommsCallInLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WhistleProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WhistleLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WhistleLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.DisableCyberwareProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.DisableCyberwareLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.DisableCyberwareLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.DisableCyberwareLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.OverheatLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SystemCollapseProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.SystemCollapseLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.WeaponMalfunctionLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.LocomotionMalfunctionProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.PingLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MemoryWipeLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.MemoryWipeLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BrainMeltLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BrainMeltLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.BrainMeltLvl4Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionProgram", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionLvl2Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionLvl3Program", 1);
  ts.GiveItemByTDBID(GetPlayer(gi), t"Items.ContagionLvl4Program", 1);
  playerID = GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject().GetEntityID();
  itemTDBID = t"TEST.CyberdeckHybridMid";
  itemID = ItemID.FromTDBID(itemTDBID);
  equipRequest = new EquipRequest();
  equipRequest.itemID = itemID;
  equipRequest.owner = GetPlayer(gi);
  equipRequest.addToInventory = true;
  equipSys = GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem") as EquipmentSystem;
  equipSys.QueueRequest(equipRequest);
  statusEffectSystem = GameInstance.GetStatusEffectSystem(gi);
  if statusEffectSystem.HasStatusEffect(playerID, t"TEST.UltimateNetrunner") {
    GameInstance.GetStatusEffectSystem(gi).RemoveStatusEffect(playerID, t"TEST.UltimateNetrunner");
  } else {
    GameInstance.GetStatusEffectSystem(gi).ApplyStatusEffect(playerID, t"TEST.UltimateNetrunner");
  };
}
