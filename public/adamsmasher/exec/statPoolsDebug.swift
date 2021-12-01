
public static exec func ModifyPlayerStatPoolValue(gi: GameInstance, statPoolTypeString: String, value: String, opt percentage: String) -> Void {
  let isPercent: Bool;
  let player: ref<PlayerPuppet>;
  let playerID: StatsObjectID;
  let statPoolType: gamedataStatPoolType;
  let statPoolValue: Float;
  let statPoolTypeInt: Int32 = Cast(EnumValueFromString("gamedataStatPoolType", statPoolTypeString));
  if statPoolTypeInt == -1 {
    LogWarning("ModifyPlayerStatPoolValue: provided stat pool type " + statPoolTypeString + " is not a stat pool!");
    return;
  };
  player = GetPlayer(gi);
  playerID = Cast(player.GetEntityID());
  statPoolType = IntEnum(statPoolTypeInt);
  statPoolValue = StringToFloat(value);
  isPercent = StringToBool(percentage);
  if NotEquals(percentage, "") {
    GameInstance.GetStatPoolsSystem(gi).RequestSettingStatPoolValue(playerID, statPoolType, statPoolValue, null, isPercent);
  } else {
    GameInstance.GetStatPoolsSystem(gi).RequestSettingStatPoolValue(playerID, statPoolType, statPoolValue, null);
  };
}

public static exec func ModifyNPCStatPoolValue(gi: GameInstance, statPoolTypeString: String, value: String, opt percentage: String) -> Void {
  let gameEffectInstance: ref<EffectInstance>;
  let isPercent: Bool;
  let player: ref<PlayerPuppet>;
  let statPoolValue: Float;
  let statPool: Int32 = Cast(EnumValueFromString("gamedataStatPoolType", statPoolTypeString));
  if statPool == -1 {
    LogWarning("ModifyNPCStatPoolValue: provided stat pool type " + statPoolTypeString + " is not a stat pool!");
    return;
  };
  player = GetPlayer(gi);
  statPoolValue = StringToFloat(value);
  if NotEquals(percentage, "") {
    isPercent = StringToBool(percentage);
  } else {
    isPercent = true;
  };
  gameEffectInstance = GameInstance.GetGameEffectSystem(gi).CreateEffectStatic(n"debugStrike", n"modStatPoolRay", GetPlayer(gi));
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, player.GetWorldPosition());
  EffectData.SetVector(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, player.GetWorldForward());
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 50.00);
  EffectData.SetInt(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.statType, statPool);
  EffectData.SetFloat(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.value, statPoolValue);
  EffectData.SetBool(gameEffectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.debugBool, isPercent);
  gameEffectInstance.Run();
}

public static exec func AddPlayerStatPoolBonus(gi: GameInstance, statPoolTypeString: String, bonusValueString: String, persistance: String, opt percentage: String) -> Void {
  let bonusValue: Float;
  let isPercent: Bool;
  let isPersistent: Bool;
  let playerID: StatsObjectID;
  let statPoolType: gamedataStatPoolType;
  let statPoolTypeInt: Int32 = Cast(EnumValueFromString("gamedataStatPoolType", statPoolTypeString));
  if statPoolTypeInt == -1 {
    LogWarning("AddStatPoolBonus: provided stat pool type " + statPoolTypeString + " is not a stat pool!");
    return;
  };
  statPoolType = IntEnum(statPoolTypeInt);
  playerID = Cast(GetPlayer(gi).GetEntityID());
  bonusValue = StringToFloat(bonusValueString);
  isPercent = StringToBool(percentage);
  isPersistent = StringToBool(persistance);
  if NotEquals(percentage, "") {
    GameInstance.GetStatPoolsSystem(gi).RequestSettingStatPoolBonus(playerID, statPoolType, bonusValue, null, isPersistent, isPercent);
  } else {
    GameInstance.GetStatPoolsSystem(gi).RequestSettingStatPoolBonus(playerID, statPoolType, bonusValue, null, isPersistent);
  };
}

public static exec func ApplyRegenData(gi: GameInstance, statPoolTypeString: String, rangeBeginString: String, rangeEndString: String, startDelayString: String, valuePerSecString: String, delayOnChangeString: String) -> Void {
  ApplyStatPoolModifier(gi, statPoolTypeString, StringToFloat(rangeBeginString), StringToFloat(rangeEndString), StringToFloat(startDelayString), StringToFloat(valuePerSecString), StringToBool(delayOnChangeString), gameStatPoolModificationTypes.Regeneration);
}

public static exec func ApplyRegenModifier(gi: GameInstance, statPoolTypeString: String, statPoolModName: String) -> Void {
  let statPoolMod: ref<PoolValueModifier_Record> = TweakDBInterface.GetPoolValueModifierRecord(TDBID.Create("BaseStatPools." + statPoolModName));
  ApplyStatPoolModifier(gi, statPoolTypeString, statPoolMod.RangeBegin(), statPoolMod.RangeEnd(), statPoolMod.StartDelay(), statPoolMod.ValuePerSec(), statPoolMod.DelayOnChange(), gameStatPoolModificationTypes.Regeneration);
}

public static exec func ApplyDecayData(gi: GameInstance, statPoolTypeString: String, rangeBeginString: String, rangeEndString: String, startDelayString: String, valuePerSecString: String, delayOnChangeString: String) -> Void {
  ApplyStatPoolModifier(gi, statPoolTypeString, StringToFloat(rangeBeginString), StringToFloat(rangeEndString), StringToFloat(startDelayString), StringToFloat(valuePerSecString), StringToBool(delayOnChangeString), gameStatPoolModificationTypes.Decay);
}

public static exec func ApplyDecayModifier(gi: GameInstance, statPoolTypeString: String, statPoolModName: String) -> Void {
  let statPoolMod: ref<PoolValueModifier_Record> = TweakDBInterface.GetPoolValueModifierRecord(TDBID.Create("BaseStatPools." + statPoolModName));
  ApplyStatPoolModifier(gi, statPoolTypeString, statPoolMod.RangeBegin(), statPoolMod.RangeEnd(), statPoolMod.StartDelay(), statPoolMod.ValuePerSec(), statPoolMod.DelayOnChange(), gameStatPoolModificationTypes.Decay);
}

public static func ApplyStatPoolModifier(gi: GameInstance, statPoolTypeString: String, rangeBegin: Float, rangeEnd: Float, startDelay: Float, valuePerSec: Float, delayOnChange: Bool, statPoolModType: gameStatPoolModificationTypes) -> Void {
  let playerID: StatsObjectID;
  let statPool: gamedataStatPoolType;
  let statPoolModifier: StatPoolModifier;
  let statPoolInt: Int32 = Cast(EnumValueFromString("gamedataStatPoolType", statPoolTypeString));
  if statPoolInt == -1 {
    LogWarning("ApplyStatPoolModifier: provided stat pool type " + statPoolTypeString + " is not a stat pool!");
    return;
  };
  playerID = Cast(GetPlayer(gi).GetEntityID());
  statPool = IntEnum(statPoolInt);
  statPoolModifier.enabled = true;
  statPoolModifier.rangeBegin = rangeBegin;
  statPoolModifier.rangeEnd = rangeEnd;
  statPoolModifier.startDelay = startDelay;
  statPoolModifier.valuePerSec = valuePerSec;
  statPoolModifier.delayOnChange = delayOnChange;
  GameInstance.GetStatPoolsSystem(gi).RequestSettingModifier(playerID, statPool, statPoolModType, statPoolModifier);
}

public static exec func SetDefaultRegen(gi: GameInstance, statPoolTypeString: String) -> Void {
  SetDefaultStatPoolModifiers(gi, statPoolTypeString, gameStatPoolModificationTypes.Regeneration);
}

public static exec func SetDefaultDecay(gi: GameInstance, statPoolTypeString: String) -> Void {
  SetDefaultStatPoolModifiers(gi, statPoolTypeString, gameStatPoolModificationTypes.Decay);
}

public static func SetDefaultStatPoolModifiers(gi: GameInstance, statPoolTypeString: String, statPoolModType: gameStatPoolModificationTypes) -> Void {
  let playerID: StatsObjectID;
  let statPool: gamedataStatPoolType;
  let statPoolInt: Int32 = Cast(EnumValueFromString("gamedataStatPoolType", statPoolTypeString));
  if statPoolInt == -1 {
    LogWarning("SetDefault(Regen/Decay): provided stat pool type " + statPoolTypeString + " is not a stat pool!");
    return;
  };
  playerID = Cast(GetPlayer(gi).GetEntityID());
  statPool = IntEnum(statPoolInt);
  GameInstance.GetStatPoolsSystem(gi).RequestResetingModifier(playerID, statPool, statPoolModType);
}
