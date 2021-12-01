
public static exec func SetLevel(inst: GameInstance, stringType: String, stringVal: String) -> Void {
  PlayerPuppet.SetLevel(inst, stringType, stringVal, telemetryLevelGainReason.IsDebug);
}

public static exec func AddExp(inst: GameInstance, stringType: String, stringVal: String) -> Void {
  let expType: gamedataProficiencyType = IntEnum(Cast(EnumValueFromString("gamedataProficiencyType", stringType)));
  let expAmount: Int32 = StringToInt(stringVal);
  let expRequest: ref<AddExperience> = new AddExperience();
  expRequest.Set(GetPlayer(inst), expAmount, expType, true);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(expRequest);
}

public static exec func BuyPerk(inst: GameInstance, pString: String) -> Void {
  let pType: gamedataPerkType = IntEnum(Cast(EnumValueFromString("gamedataPerkType", pString)));
  let request: ref<BuyPerk> = new BuyPerk();
  request.Set(GetPlayer(inst), pType);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
}

public static exec func RemovePerk(inst: GameInstance, pString: String) -> Void {
  let pType: gamedataPerkType = IntEnum(Cast(EnumValueFromString("gamedataPerkType", pString)));
  let request: ref<RemovePerk> = new RemovePerk();
  request.Set(GetPlayer(inst), pType);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
}

public static exec func GiveDevPoints(inst: GameInstance, stringType: String, stringVal: String) -> Void {
  let devPtsType: gamedataDevelopmentPointType = IntEnum(Cast(EnumValueFromString("gamedataDevelopmentPointType", stringType)));
  let devPtsAmount: Int32 = StringToInt(stringVal);
  let request: ref<AddDevelopmentPoints> = new AddDevelopmentPoints();
  request.Set(GetPlayer(inst), devPtsAmount, devPtsType);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
}

public static exec func BuyAtt(inst: GameInstance, stringType: String) -> Void {
  let attType: gamedataStatType = IntEnum(Cast(EnumValueFromString("gamedataStatType", stringType)));
  let request: ref<BuyAttribute> = new BuyAttribute();
  request.Set(GetPlayer(inst), attType);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
}

public static exec func SetAtt(inst: GameInstance, stringType: String, stringVal: String) -> Void {
  let attType: gamedataStatType = IntEnum(Cast(EnumValueFromString("gamedataStatType", stringType)));
  let attValue: Float = StringToFloat(stringVal);
  let request: ref<SetAttribute> = new SetAttribute();
  request.Set(GetPlayer(inst), attValue, attType);
  GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
}

public static exec func PrintAttributes(inst: GameInstance) -> Void {
  let val: Int32;
  let player: ref<PlayerPuppet> = GetPlayer(inst);
  let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
  let playerID: StatsObjectID = Cast(player.GetEntityID());
  let i: Int32 = 0;
  while i <= EnumInt(gamedataStatType.Count) {
    val = Cast(statSys.GetStatValue(playerID, IntEnum(i)));
    Log(EnumValueToString("gamedataStatType", Cast(i)) + ": " + IntToString(val));
    i += 1;
  };
}

public static exec func SetBuild(inst: GameInstance, stringType: String) -> Void {
  PlayerPuppet.SetBuild(inst, stringType);
}

public static exec func PrintProfs(inst: GameInstance) -> Void {
  let i: Int32 = 0;
  while i < EnumInt(gamedataProficiencyType.Count) {
    LogDM("Proficiency: " + EnumValueToString("gamedataProficiencyType", Cast(i)) + " current level is - " + (GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem).GetProficiencyLevel(GetPlayer(inst), IntEnum(i)));
    i += 1;
  };
}

public static exec func PrintPerks(gi: GameInstance) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  let PDS: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
  let perks: array<SPerk> = PDS.GetPerks(player);
  let i: Int32 = 0;
  while i < ArraySize(perks) {
    LogDM(" ========================== ");
    LogDM("Perk type: " + EnumValueToString("gamedataPerkType", Cast(EnumInt(perks[i].type))));
    LogDM("Perk current level: " + perks[i].currLevel);
    LogDM("Perk max level: " + PDS.GetPerkMaxLevel(player, perks[i].type));
    i += 1;
  };
}

public static exec func PrintProfExpToNextLevel(inst: GameInstance, stringProfType: String) -> Void {
  let enumProfType: gamedataProficiencyType = IntEnum(Cast(EnumValueFromString("gamedataProficiencyType", stringProfType)));
  let playerDevSystem: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
  let currentProfExp: Int32 = playerDevSystem.GetCurrentLevelProficiencyExp(GetPlayer(inst), enumProfType);
  let profExpToNextLevel: Int32 = playerDevSystem.GetRemainingExpForLevelUp(GetPlayer(inst), enumProfType);
  LogDM("Proficiency: " + stringProfType + " current level experience is - " + currentProfExp + ", experience to next level is - " + profExpToNextLevel);
}

public static exec func ModifyDifficulty(inst: GameInstance, stringDifficultyLevel: String) -> Void {
  let player: ref<GameObject> = GameInstance.GetPlayerSystem(inst).GetLocalPlayerMainGameObject();
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(inst);
  let statMod: ref<gameConstantStatModifierData> = new gameConstantStatModifierData();
  statMod.modifierType = gameStatModifierType.Additive;
  statMod.statType = gamedataStatType.PowerLevel;
  if Equals(stringDifficultyLevel, "Increase") {
    statMod.value = 0.50;
    statsSystem.AddModifier(Cast(player.GetEntityID()), statMod);
  } else {
    if Equals(stringDifficultyLevel, "Decrease") {
      statMod.value = -0.50;
      statsSystem.AddModifier(Cast(player.GetEntityID()), statMod);
    };
  };
}

public static exec func APE(gi: GameInstance, perk: String, level: String) -> Void {
  let data: array<wref<PerkLevelData_Record>>;
  let packageID: TweakDBID;
  let lvl: Int32 = StringToInt(level);
  TweakDBInterface.GetPerkRecord(TDBID.Create("Perks." + perk)).Levels(data);
  packageID = data[lvl - 1].DataPackage().GetID();
  GameInstance.GetGameplayLogicPackageSystem(gi).ApplyPackage(GetPlayer(gi), GetPlayer(gi), packageID);
}

public static exec func CGLP(gi: GameInstance) -> Void {
  let i: Int32;
  let packages: array<TweakDBID>;
  let glps: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(gi);
  glps.GetAppliedPackages(GetPlayer(gi), packages);
  i = 0;
  while i < ArraySize(packages) {
    glps.RemovePackage(GetPlayer(gi), packages[i]);
    i += 1;
  };
}
