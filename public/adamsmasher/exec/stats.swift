
public static exec func DebugNPC(gi: GameInstance, opt durationStr: String) -> Void {
  let gameEffectInstance: ref<EffectInstance>;
  let infiniteDuration: Bool;
  let durationFloat: Float = StringToFloat(durationStr);
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  if durationFloat < 0.00 {
    GetPlayer(gi).DEBUG_Visualizer.ClearPuppetVisualization();
  } else {
    infiniteDuration = FloatIsEqual(durationFloat, 0.00);
    gameEffectInstance = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"debugStrike", n"vdb_ray", GetPlayer(gi));
    EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, durationFloat);
    EffectData.SetBool(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.infiniteDuration, infiniteDuration);
    EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
    EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
    EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 20.00);
    gameEffectInstance.Run();
  };
}

public static exec func DebugNPCs(gi: GameInstance, opt durationStr: String, opt radiusStr: String, opt moveWithPlayerStr: String) -> Void {
  DebugNPCs_NonExec(gi, durationStr, radiusStr, moveWithPlayerStr);
}

public static func DebugNPCs_NonExec(const gi: GameInstance, opt durationStr: String, opt radiusStr: String, opt moveWithPlayerStr: String) -> Void {
  let gameEffectInstance: ref<EffectInstance>;
  let infiniteDuration: Bool;
  let durationFloat: Float = StringToFloat(durationStr);
  let radius: Float = StringToFloat(radiusStr);
  let moveWithPlayer: Bool = StringToBool(moveWithPlayerStr);
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  if FloatIsEqual(radius, 0.00) {
    radius = 20.00;
  };
  if durationFloat < 0.00 {
    SetFactValue(gi, n"cheat_vdb_const", 0);
    GetPlayer(gi).DEBUG_Visualizer.ClearPuppetVisualization();
  } else {
    if moveWithPlayer {
      SetFactValue(gi, n"cheat_vdb_const", 1);
      gameEffectInstance = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"debugStrike", n"vdb_sphere_constant", GetPlayer(gi));
      EffectData.SetBool(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.infiniteDuration, true);
      EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
      EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
      gameEffectInstance.Run();
    } else {
      infiniteDuration = FloatIsEqual(durationFloat, 0.00);
      gameEffectInstance = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"debugStrike", n"vdb_sphere", GetPlayer(gi));
      EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, durationFloat);
      EffectData.SetBool(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.infiniteDuration, infiniteDuration);
      EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
      EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
      gameEffectInstance.Run();
    };
  };
}

public static exec func PrintStatsPlayer(gi: GameInstance) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let gameEffectInstance: ref<EffectInstance> = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"debugStrike", n"printStatsPlayer", GetPlayer(gi));
  EffectData.SetEntity(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, player);
  gameEffectInstance.Run();
}

public static exec func PrintStatsTarget(gi: GameInstance) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let gameEffectInstance: ref<EffectInstance> = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"debugStrike", n"printStatsRay", GetPlayer(gi));
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 50.00);
  gameEffectInstance.Run();
}

public static exec func PrintStatTarget(gi: GameInstance, statType: String) -> Void {
  let gameEffectInstance: ref<EffectInstance>;
  let player: ref<PlayerPuppet>;
  let stat: Int32 = Cast(EnumValueFromString("gamedataStatType", statType));
  if stat == -1 {
    LogWarning("PrintStatTarget: provided stat type " + statType + " is not a stat!");
    return;
  };
  player = GetPlayer(gi);
  gameEffectInstance = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"debugStrike", n"printStatRay", GetPlayer(gi));
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 50.00);
  EffectData.SetInt(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.statType, stat);
  gameEffectInstance.Run();
}

public static exec func ModStatPlayer(gi: GameInstance, TEMP_stat: String, TEMP_val: String) -> Void {
  let stat: gamedataStatType = IntEnum(Cast(EnumValueFromString("gamedataStatType", TEMP_stat)));
  let val: Float = StringToFloat(TEMP_val);
  let hack: ref<StrikeExecutor_ModifyStat> = new StrikeExecutor_ModifyStat();
  hack.ModStatPuppet(GetPlayer(gi), stat, val, GetPlayer(gi));
}

public static exec func ModStatTarget(gi: GameInstance, TEMP_stat: String, TEMP_val: String) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let stat: Int32 = Cast(EnumValueFromString("gamedataStatType", TEMP_stat));
  let val: Float = StringToFloat(TEMP_val);
  let gameEffectInstance: ref<EffectInstance> = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"stats", n"modStatRay", GetPlayer(gi));
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 50.00);
  EffectData.SetInt(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.statType, stat);
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.value, val);
  gameEffectInstance.Run();
}

public static exec func PlayerSD(gameInstance: GameInstance) -> Void {
  PrintStatsDetails(gameInstance, GetPlayer(gameInstance));
}

public static exec func WeaponSD(gi: GameInstance) -> Void {
  let obj: ref<WeaponObject> = ScriptedPuppet.GetActiveWeapon(GetPlayer(gi));
  PrintStatsDetails(gi, obj);
}

public static func PrintStatsDetails(gameInstance: GameInstance, obj: ref<GameObject>) -> Void {
  let detailedList: array<gameStatDetailedData> = GameInstance.GetStatsSystem(gameInstance).GetStatDetails(Cast(obj.GetEntityID()));
  let i: Int32 = 0;
  while i < ArraySize(detailedList) {
    PrintStatDetails(gameInstance, detailedList[i]);
    i += 1;
  };
  LogStats("__________________________END__________________________");
}

public static func PrintStatDetails(gameInstance: GameInstance, statDetails: gameStatDetailedData) -> Void {
  let boolValue: Bool;
  let j: Int32;
  let modifierType: String;
  let statModifierDetails: gameStatModifierDetailedData;
  LogStats("Stat: " + statDetails.statType);
  LogStats("IsBool: " + statDetails.boolStatType);
  if statDetails.boolStatType {
    if statDetails.value > 0.00 {
      boolValue = true;
    };
    LogStats("        Value: " + boolValue);
  } else {
    LogStats("        Value: " + statDetails.value);
  };
  LogStats("        Limits: " + NoTrailZeros(statDetails.limitMin) + " - " + NoTrailZeros(statDetails.limitMax));
  if ArraySize(statDetails.modifiers) > 0 {
    LogStats("        Modifiers:");
    j = 0;
    while j < ArraySize(statDetails.modifiers) {
      statModifierDetails = statDetails.modifiers[j];
      modifierType = ModifierTypeToString(statModifierDetails.modifierType);
      LogStats("                {");
      LogStats("                    Type: " + modifierType);
      LogStats("                    Value: " + NoTrailZeros(statModifierDetails.value));
      LogStats("                }");
      j += 1;
    };
  };
  LogStats("--------");
}

public static func ModifierTypeToString(type: gameStatModifierType) -> String {
  let modifierType: String;
  if EnumInt(type) == 0 {
    modifierType = "Additive";
  } else {
    if EnumInt(type) == 1 {
      modifierType = "AdditiveMultiplier";
    } else {
      if EnumInt(type) == 2 {
        modifierType = "Multiplier";
      } else {
        modifierType = "Invalid";
      };
    };
  };
  return modifierType;
}

public static exec func PrintGodModeSources(gameInstance: GameInstance) -> Void {
  let i: Int32;
  let immortalCount: Int32;
  let immortalSources: array<CName>;
  let invulnerableCount: Int32;
  let invulnerableSources: array<CName>;
  let godModeSystem: ref<GodModeSystem> = GameInstance.GetGodModeSystem(gameInstance);
  let player: ref<PlayerPuppet> = GetPlayer(gameInstance);
  let playerID: EntityID = player.GetEntityID();
  LogStats("Printing God Modes:");
  invulnerableCount = Cast(godModeSystem.GetGodModeCount(playerID, gameGodModeType.Invulnerable));
  if invulnerableCount > 0 {
    LogStats("Invulnerable: " + IntToString(invulnerableCount));
    invulnerableSources = godModeSystem.GetGodModeSources(playerID, gameGodModeType.Invulnerable);
    i = 0;
    while i < invulnerableCount {
      LogStats("    " + NameToString(invulnerableSources[i]));
      i += 1;
    };
  };
  immortalCount = Cast(godModeSystem.GetGodModeCount(playerID, gameGodModeType.Immortal));
  if immortalCount > 0 {
    LogStats("Immortal: " + IntToString(immortalCount));
    immortalSources = godModeSystem.GetGodModeSources(playerID, gameGodModeType.Immortal);
    i = 0;
    while i < immortalCount {
      LogStats("    " + NameToString(immortalSources[i]));
      i += 1;
    };
  };
  if invulnerableCount == 0 && immortalCount == 0 {
    LogStats("    No god modes");
  };
  LogStats("------");
}

public static exec func TEST_TargetImmortal(gameInstance: GameInstance, shouldSetStr: String) -> Void {
  let angleDist: EulerAngles;
  let shouldSet: Bool = StringToBool(shouldSetStr);
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gameInstance).GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
  let targetID: EntityID = target.GetEntityID();
  if IsDefined(target) {
    if shouldSet {
      GameInstance.GetGodModeSystem(gameInstance).AddGodMode(targetID, gameGodModeType.Immortal, n"TEST_TargetImmortal");
    } else {
      GameInstance.GetGodModeSystem(gameInstance).RemoveGodMode(targetID, gameGodModeType.Immortal, n"TEST_TargetImmortal");
    };
  };
}

public static exec func TEST_TargetInvulnerable(gameInstance: GameInstance, shouldSetStr: String) -> Void {
  let angleDist: EulerAngles;
  let shouldSet: Bool = StringToBool(shouldSetStr);
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gameInstance).GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
  let targetID: EntityID = target.GetEntityID();
  if IsDefined(target) {
    if shouldSet {
      GameInstance.GetGodModeSystem(gameInstance).AddGodMode(targetID, gameGodModeType.Invulnerable, n"TEST_TargetInvulnerable");
    } else {
      GameInstance.GetGodModeSystem(gameInstance).RemoveGodMode(targetID, gameGodModeType.Invulnerable, n"TEST_TargetInvulnerable");
    };
  };
}

public static func Debug_WeaponSpread_Set(gameInstance: GameInstance, useCircularDistribution: Bool, useEvenDistribution: Bool, rowCount: Int32, projectilesPerShot: Int32) -> Void {
  let bbSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(gameInstance);
  let debugBB: ref<IBlackboard> = bbSystem.Get(GetAllBlackboardDefs().DebugData);
  debugBB.SetBool(GetAllBlackboardDefs().DebugData.WeaponSpread_UseEvenDistribution, useEvenDistribution);
  debugBB.SetBool(GetAllBlackboardDefs().DebugData.WeaponSpread_UseCircularSpread, useCircularDistribution);
  debugBB.SetInt(GetAllBlackboardDefs().DebugData.WeaponSpread_EvenDistributionRowCount, rowCount);
  debugBB.SetInt(GetAllBlackboardDefs().DebugData.WeaponSpread_ProjectilesPerShot, projectilesPerShot);
}

public static exec func Debug_WeaponSpread(gameInstance: GameInstance, useCircularDistribution: String, useEvenDistribution: String, rowCount: String, projectilesPerShot: String) -> Void {
  let _projectilesPerShot: Int32;
  let _rowCount: Int32;
  let _useCircularDistribution: Bool;
  let _useEvenDistribution: Bool;
  if Equals(useEvenDistribution, "true") {
    _useEvenDistribution = true;
  };
  if Equals(useEvenDistribution, "false") {
    _useEvenDistribution = false;
  };
  if Equals(useCircularDistribution, "true") {
    _useCircularDistribution = true;
  };
  if Equals(useCircularDistribution, "false") {
    _useCircularDistribution = false;
  };
  _rowCount = StringToInt(rowCount, 1);
  _projectilesPerShot = StringToInt(projectilesPerShot, 1);
  Debug_WeaponSpread_Set(gameInstance, _useCircularDistribution, _useEvenDistribution, _rowCount, _projectilesPerShot);
}

public static exec func Debug_WeaponSpread_RandomGrid(gameInstance: GameInstance) -> Void {
  Debug_WeaponSpread_Set(gameInstance, false, true, RandRange(1, 10), RandRange(1, 40));
}

public static exec func Debug_WeaponSpread_RandomCircular(gameInstance: GameInstance) -> Void {
  Debug_WeaponSpread_Set(gameInstance, true, true, RandRange(1, 10), RandRange(1, 40));
}

public static exec func PrintPlayerStat(gi: GameInstance, TEMP_Type: String) -> Void {
  let stat: gamedataStatType = IntEnum(Cast(EnumValueFromString("gamedataStatType", TEMP_Type)));
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let playerID: StatsObjectID = Cast(player.GetEntityID());
  let statValue: Float = GameInstance.GetStatsSystem(gi).GetStatValue(playerID, stat);
  LogStats("Stat: " + TEMP_Type + " Value: " + statValue);
}

public static func PPS(gi: GameInstance) -> Void {
  let playerStat: gamedataStatType;
  let statValue: Float;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let playerID: StatsObjectID = Cast(player.GetEntityID());
  let i: Int32 = 0;
  while i < EnumInt(gamedataStatType.Count) {
    playerStat = IntEnum(i);
    statValue = GameInstance.GetStatsSystem(gi).GetStatValue(playerID, playerStat);
    if statValue != 0.00 {
      LogStats("Stat: " + EnumValueToString("gamedataStatType", Cast(i)) + " Value: " + statValue);
    };
    i += 1;
  };
}

public static exec func PrintPlayerStats(gi: GameInstance) -> Void {
  let playerStat: gamedataStatType;
  let statValue: Float;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let playerID: StatsObjectID = Cast(player.GetEntityID());
  let i: Int32 = 0;
  while i < EnumInt(gamedataStatType.Count) {
    playerStat = IntEnum(i);
    statValue = GameInstance.GetStatsSystem(gi).GetStatValue(playerID, playerStat);
    if statValue != 0.00 {
      LogStats("Stat: " + EnumValueToString("gamedataStatType", Cast(i)) + " Value: " + statValue);
    };
    i += 1;
  };
}

public static exec func PrintTargetStats(gi: GameInstance) -> Void {
  let statValue: Float;
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gi).GetLookAtObject(GetPlayer(gi));
  let i: Int32 = 0;
  while i < EnumInt(gamedataStatType.Count) {
    statValue = GameInstance.GetStatsSystem(gi).GetStatValue(Cast(target.GetEntityID()), IntEnum(i));
    if statValue != 0.00 {
      LogStats("Stat: " + EnumValueToString("gamedataStatType", Cast(i)) + " Value: " + statValue);
    };
    i += 1;
  };
}

public static exec func PrintPlayerStatModifiers(gi: GameInstance, type: String) -> Void {
  let i: Int32;
  let playerID: StatsObjectID;
  let statDetails: array<gameStatDetailedData>;
  let statMods: array<gameStatModifierDetailedData>;
  let statSystem: ref<StatsSystem>;
  let statType: gamedataStatType;
  let statVal: Float;
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  if !IsDefined(player) {
    return;
  };
  playerID = Cast(player.GetEntityID());
  statSystem = GameInstance.GetStatsSystem(gi);
  statType = IntEnum(Cast(EnumValueFromString("gamedataStatType", type)));
  statDetails = statSystem.GetStatDetails(playerID);
  i = 0;
  while i < ArraySize(statDetails) {
    if Equals(statDetails[i].statType, statType) {
      statVal = statDetails[i].value;
      statMods = statDetails[i].modifiers;
    } else {
      i += 1;
    };
  };
  if ArraySize(statMods) != 0 {
    LogStats("================================");
    LogStats("========= STAT: " + type + " =========");
    LogStats("========= Value: " + FloatToString(statVal) + " ==========");
    LogStats("================================");
    LogStats("Modifiers: ");
  };
  i = 0;
  while i < ArraySize(statMods) {
    LogStats("Mod #" + IntToString(i) + " ; Value: " + FloatToString(statMods[i].value));
    i += 1;
  };
}

public static exec func AddStatModifier(gi: GameInstance, type: String, value: String, modType: String) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let playerID: StatsObjectID = Cast(player.GetEntityID());
  let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gi);
  let statType: gamedataStatType = IntEnum(Cast(EnumValueFromString("gamedataStatType", type)));
  let statModType: gameStatModifierType = IntEnum(Cast(EnumValueFromString("gameStatModifierType", modType)));
  let statVal: Float = StringToFloat(value);
  statSystem.AddModifier(playerID, RPGManager.CreateStatModifier(statType, statModType, statVal));
}
