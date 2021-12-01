
public class QuestResetPerfomedActionsStorage extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestResetPerfomedActionsStorage";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestResetPerfomedActionsStorage", true, n"QuestResetPerfomedActionsStorage", n"QuestResetPerfomedActionsStorage");
  }
}

public class QuestRemoveQuickHacks extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestRemoveQuickHacks";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestRemoveQuickHacks", true, n"QuestRemoveQuickHacks", n"QuestRemoveQuickHacks");
  }
}

public class QuestBreachAccessPoint extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestBreachAccessPoint";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestBreachAccessPoint", true, n"QuestBreachAccessPoint", n"QuestBreachAccessPoint");
  }
}

public class SpiderbotEnableAccessPoint extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotEnableAccessPoint";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"SpiderbotEnableAccessPoint", n"SpiderbotEnableAccessPoint");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SpiderbotEnableAccessPoint";
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return true;
    };
    return false;
  }
}

public static exec func UploadProgram(gameInstance: GameInstance, programNumber: String) -> Void {
  let program: Int32 = StringToInt(programNumber);
  SetFactValue(gameInstance, n"upload_program", program);
  Log("Program:" + programNumber + " uploaded");
}

public class RevealEnemiesProgram extends ProgramAction {

  public final func SetProperties() -> Void {
    this.actionName = n"RevealEnemiesProgram";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#17840", n"LocKey#17840");
  }
}

public class ResetNetworkBreachState extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ResetNetworkBreachState";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class ToggleNetrunnerDive extends ActionBool {

  public let m_skipMinigame: Bool;

  public let m_attempt: Int32;

  public let m_isRemote: Bool;

  public final func SetProperties(terminateDive: Bool, skipMinigame: Bool, attempt: Int32, isRemote: Bool) -> Void {
    this.actionName = n"ToggleNetrunnerDive";
    this.m_skipMinigame = skipMinigame;
    this.m_attempt = attempt;
    this.m_isRemote = isRemote;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, terminateDive, n"LocKey#17841", n"LocKey#17841");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "ToggleNetrunnerDive";
  }

  public final const func ShouldTerminate() -> Bool {
    return FromVariant(this.prop.first);
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return device.IsPowered();
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Direct) {
      return true;
    };
    return false;
  }
}

public class AccessPointController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class AccessPointControllerPS extends MasterControllerPS {

  private let m_rewardNotificationIcons: array<String>;

  private let m_rewardNotificationString: String;

  private inline let m_accessPointSkillChecks: ref<HackingContainer>;

  private persistent let m_isBreached: Bool;

  private edit let m_isVirtual: Bool;

  private let m_pingedSquads: array<CName>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#138";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_accessPointSkillChecks);
  }

  public final const func IsVirtual() -> Bool {
    return this.m_isVirtual;
  }

  public final const func HasNetworkBackdoor() -> Bool {
    if EnumInt(this.GetDeviceState()) <= EnumInt(EDeviceStatus.UNPOWERED) {
      return false;
    };
    return true;
  }

  public const func GetMinigameDefinition() -> TweakDBID {
    return this.m_minigameDefinition;
  }

  public const func GetBackdoorAccessPoint() -> ref<AccessPointControllerPS> {
    let masterAP: ref<AccessPointControllerPS> = this.GetBackdoorAccessPoint();
    if IsDefined(masterAP) {
      return masterAP;
    };
    return this;
  }

  public final const func GetDevicesThatPlayerCanBreach() -> array<ref<ScriptableDeviceComponentPS>> {
    let breachableDevices: array<ref<ScriptableDeviceComponentPS>>;
    let children: array<ref<DeviceComponentPS>>;
    let currentDevice: ref<ScriptableDeviceComponentPS>;
    let i: Int32;
    this.GetChildren(children);
    i = 0;
    while i < ArraySize(children) {
      if IsDefined(children[i] as ScriptableDeviceComponentPS) {
        currentDevice = children[i] as ScriptableDeviceComponentPS;
        if currentDevice.ShouldRevealNetworkGrid() {
          ArrayPush(breachableDevices, currentDevice);
        };
      };
      i += 1;
    };
    return breachableDevices;
  }

  public final const func IsAccessPointOf(slaveToCheck: PersistentID) -> Bool {
    let children: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let k: Int32;
    let singleSlaveChildren: array<ref<DeviceComponentPS>>;
    let slaveAPs: array<ref<DeviceComponentPS>>;
    this.GetChildren(children);
    i = 0;
    while i < ArraySize(children) {
      if Equals(children[i].GetID(), slaveToCheck) {
        return true;
      };
      if IsDefined(children[i] as AccessPointControllerPS) {
        ArrayPush(slaveAPs, children[i]);
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(slaveAPs) {
      slaveAPs[i].GetChildren(singleSlaveChildren);
      k = 0;
      while k < ArraySize(singleSlaveChildren) {
        if Equals(singleSlaveChildren[k].GetID(), slaveToCheck) {
          return true;
        };
        k += 1;
      };
      i += 1;
    };
    return false;
  }

  public const func IsConnectedToBackdoorDevice() -> Bool {
    return true;
  }

  public const func ShouldRevealNetworkGrid() -> Bool {
    if this.m_isVirtual {
      return false;
    };
    return this.HasNetworkBackdoor();
  }

  public const func IsMainframe() -> Bool {
    let children: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    this.GetChildren(children);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as AccessPointControllerPS) {
        return false;
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(children) {
      if IsDefined(children[i] as AccessPointControllerPS) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(1, 9);
  }

  private final func SetIsBreached(isBreached: Bool) -> Void {
    this.m_isBreached = isBreached;
    this.ExposeQuickHacks(isBreached);
  }

  public const func GetNetworkName() -> String {
    let networkName: String = this.GetDeviceName();
    if IsStringValid(networkName) {
      return networkName;
    };
    return "LOCAL NETWORK";
  }

  public const func GetNetworkSizeCount() -> Int32 {
    let slaves: array<ref<DeviceComponentPS>>;
    this.GetChildren(slaves);
    return ArraySize(slaves);
  }

  public final const quest func IsNetworkBreached() -> Bool {
    return this.m_isBreached;
  }

  public const quest func IsBreached() -> Bool {
    return this.m_isBreached || this.WasHackingMinigameSucceeded();
  }

  public final func BreachConnectedDevices() -> Void {
    this.RefreshSlaves_Event();
  }

  protected final func ActionSpiderbotEnableAccessPoint() -> ref<SpiderbotEnableAccessPoint> {
    let action: ref<SpiderbotEnableAccessPoint> = new SpiderbotEnableAccessPoint();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected final func ActionRevealEnemiesProgram() -> ref<RevealEnemiesProgram> {
    let action: ref<RevealEnemiesProgram> = new RevealEnemiesProgram();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnRevealEnemiesProgram(evt: ref<RevealEnemiesProgram>) -> EntityNotificationType {
    this.SendActionToAllSlaves(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func RefreshSlaves(devices: array<ref<DeviceComponentPS>>) -> Void {
    let baseEpicMaterials: Float;
    let baseLegendaryMaterials: Float;
    let baseMoney: Float;
    let baseRareMaterials: Float;
    let baseShardDropChance: Float;
    let baseUncommonMaterials: Float;
    let i: Int32;
    let lootAllAdvancedID: TweakDBID;
    let lootAllID: TweakDBID;
    let lootAllMasterID: TweakDBID;
    let lootQ003: TweakDBID;
    let markForErase: Bool;
    let memoryRegenMult: Float;
    let shouldLoot: Bool;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let minigameBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().HackingMinigame);
    let minigamePrograms: array<TweakDBID> = FromVariant(minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms));
    let completedPrograms: Int32 = ArraySize(minigamePrograms);
    this.CheckMasterRunnerAchievement(ArraySize(minigamePrograms));
    this.FilterRedundantPrograms(minigamePrograms);
    lootQ003 = t"MinigameAction.NetworkLootQ003";
    lootAllID = t"MinigameAction.NetworkDataMineLootAll";
    lootAllAdvancedID = t"MinigameAction.NetworkDataMineLootAllAdvanced";
    lootAllMasterID = t"MinigameAction.NetworkDataMineLootAllMaster";
    baseMoney = 0.00;
    baseUncommonMaterials = 0.00;
    baseRareMaterials = 0.00;
    baseEpicMaterials = 0.00;
    baseLegendaryMaterials = 0.00;
    baseShardDropChance = 0.00;
    memoryRegenMult = GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameMemoryRegenPerk);
    i = 0;
    while i < ArraySize(minigamePrograms) * Cast(memoryRegenMult) {
      StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.ReduceNextHackCostBy1");
      i += 1;
    };
    i = ArraySize(minigamePrograms) - 1;
    while i >= 0 {
      RPGManager.GiveReward(this.GetGameInstance(), t"RPGActionRewards.Hacking", Cast(this.GetMyEntityID()));
      if minigamePrograms[i] == t"minigame_v2.FindAnna" {
        AddFact(this.GetPlayerMainObject().GetGame(), n"Kab08Minigame_program_uploaded");
      } else {
        if minigamePrograms[i] == lootQ003 {
          TS.GiveItemByItemQuery(this.GetPlayerMainObject(), t"Query.Q003CyberdeckProgram");
        } else {
          if minigamePrograms[i] == lootAllID || minigamePrograms[i] == lootAllAdvancedID || minigamePrograms[i] == lootAllMasterID {
            if minigamePrograms[i] == lootAllID {
              baseMoney += 1.00;
              baseUncommonMaterials += 6.00;
              baseRareMaterials += 3.00;
              baseEpicMaterials += 1.00;
              baseLegendaryMaterials += 0.00;
            } else {
              if minigamePrograms[i] == lootAllAdvancedID {
                baseMoney += 2.00;
                baseUncommonMaterials += 9.00;
                baseRareMaterials += 5.00;
                baseEpicMaterials += 2.00;
                baseLegendaryMaterials += 1.00;
                baseShardDropChance += 0.16;
              } else {
                if minigamePrograms[i] == lootAllMasterID {
                  baseMoney += 3.00;
                  baseUncommonMaterials += 12.00;
                  baseRareMaterials += 8.00;
                  baseEpicMaterials += 3.00;
                  baseLegendaryMaterials += 2.00;
                  baseShardDropChance += 0.33;
                };
              };
            };
            shouldLoot = true;
            markForErase = true;
          };
        };
      };
      if markForErase {
        ArrayErase(minigamePrograms, i);
        minigameBB.SetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms, ToVariant(minigamePrograms));
      };
      i -= 1;
    };
    if completedPrograms < 3 {
      if Cast(GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameNextInstanceBufferExtensionPerk)) {
        (this.GetPlayerMainObject() as PlayerPuppet).SetBufferModifier(ArraySize(minigamePrograms));
      };
    } else {
      if completedPrograms >= 3 {
        if GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.ThreeOrMoreProgramsMemoryRegPerk) == 1.00 {
          StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.ThreeOrMoreProgramsMemoryRegPerk1", this.GetPlayerMainObject().GetEntityID());
        };
        if GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.ThreeOrMoreProgramsMemoryRegPerk) == 2.00 {
          StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.ThreeOrMoreProgramsMemoryRegPerk2", this.GetPlayerMainObject().GetEntityID());
        };
        if Cast(GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.ThreeOrMoreProgramsCooldownRedPerk)) {
          StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.ThreeOrMoreProgramsCooldownRedPerk", this.GetPlayerMainObject().GetEntityID());
        };
        if Cast(GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameNextInstanceBufferExtensionPerk)) {
          (this.GetPlayerMainObject() as PlayerPuppet).SetBufferModifier(3);
        };
      };
    };
    if shouldLoot {
      this.ProcessLoot(baseMoney, baseUncommonMaterials, baseRareMaterials, baseEpicMaterials, baseLegendaryMaterials, baseShardDropChance, TS);
    };
    this.ProcessMinigameNetworkActions(this);
    i = 0;
    while i < ArraySize(devices) {
      this.QueuePSEvent(devices[i], this.ActionSetExposeQuickHacks());
      this.ProcessMinigameNetworkActions(devices[i]);
      i += 1;
    };
  }

  private final func FilterRedundantPrograms(out programs: array<TweakDBID>) -> Void {
    if ArrayContains(programs, t"MinigameAction.NetworkTurretShutdown") && ArrayContains(programs, t"MinigameAction.NetworkTurretFriendly") {
      ArrayRemove(programs, t"MinigameAction.NetworkTurretShutdown");
    };
  }

  private final func ProcessLoot(baseMoney: Float, baseUncommonMaterials: Float, baseRareMaterials: Float, baseEpicMaterials: Float, baseLegendaryMaterials: Float, baseShardDropChance: Float, TS: ref<TransactionSystem>) -> Void {
    let dataTrackingEvent: ref<UpdateShardFailedDropsRequest>;
    let dataTrackingSystem: ref<DataTrackingSystem>;
    let dropChance: Float;
    let maxLevel: Float;
    let moneyModifier: Float;
    let powerLevel: Float;
    let queryID: TweakDBID;
    let shardDropChanceModifier: Float;
    this.CleanRewardNotification();
    moneyModifier = GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameMoneyMultiplier);
    shardDropChanceModifier = GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameShardChanceMultiplier);
    dataTrackingSystem = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    powerLevel = GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(this.GetMyEntityID()), gamedataStatType.PowerLevel);
    maxLevel = TweakDBInterface.GetStatRecord(t"BaseStats.PowerLevel").Max();
    if powerLevel <= 0.17 * maxLevel {
      queryID = t"Query.Tier1SoftwareShard";
    } else {
      if powerLevel > 0.17 * maxLevel && powerLevel <= 0.33 * maxLevel {
        queryID = t"Query.Tier2SoftwareShard";
      } else {
        if powerLevel > 0.33 * maxLevel && powerLevel <= 0.67 * maxLevel {
          queryID = t"Query.Tier3SoftwareShard";
        } else {
          queryID = t"Query.Tier4SoftwareShard";
        };
      };
    };
    dropChance = RandRangeF(0.00, 1.00);
    dataTrackingEvent = new UpdateShardFailedDropsRequest();
    dropChance -= dataTrackingSystem.GetFailedShardDrops() * 0.10;
    if dropChance > 0.00 && dropChance < baseShardDropChance * shardDropChanceModifier {
      this.AddReward(TS, queryID, 1u);
      dataTrackingEvent.resetCounter = true;
    } else {
      dataTrackingEvent.newFailedAttempts = 1.00;
    };
    GameInstance.GetScriptableSystemsContainer(this.GetPlayerMainObject().GetGame()).Get(n"DataTrackingSystem").QueueRequest(dataTrackingEvent);
    this.GenerateMaterialDrops(baseUncommonMaterials, baseRareMaterials, baseEpicMaterials, baseLegendaryMaterials, TS);
    if baseMoney >= 1.00 {
      RPGManager.GiveReward(this.GetPlayerMainObject().GetGame(), t"QuestRewards.MinigameMoneyVeryLow", Cast(this.GetMyEntityID()), baseMoney * moneyModifier);
    };
    this.ShowRewardNotification();
  }

  private final func GenerateMaterialDrops(baseUncommonMaterials: Float, baseRareMaterials: Float, baseEpicMaterials: Float, baseLegendaryMaterials: Float, TS: ref<TransactionSystem>) -> Void {
    let dropChanceMaterial: Float;
    let materialsAmmountEpic: Int32;
    let materialsAmmountLeg: Int32;
    let materialsAmmountRare: Int32;
    let materialsMultiplier: Float = GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameMaterialsEarned);
    let materialsAmmountUnc: Int32 = RandRange(Cast(baseUncommonMaterials) / 3, Cast(baseUncommonMaterials) + 1);
    this.AddReward(TS, t"Query.QuickHackUncommonMaterial", Cast(RoundMath(Cast(materialsAmmountUnc) * materialsMultiplier)));
    materialsAmmountRare = RandRange(Cast(baseRareMaterials) / 3, Cast(baseRareMaterials) + 1);
    this.AddReward(TS, t"Query.QuickHackRareMaterial", Cast(RoundMath(Cast(materialsAmmountRare) * materialsMultiplier)));
    materialsAmmountEpic = RandRange(Cast(baseEpicMaterials) / 2, Cast(baseEpicMaterials) + 1);
    this.AddReward(TS, t"Query.QuickHackEpicMaterial", Cast(RoundMath(Cast(materialsAmmountEpic) * materialsMultiplier)));
    dropChanceMaterial = RandF() * materialsMultiplier;
    if dropChanceMaterial > 0.33 - 0.05 * baseLegendaryMaterials {
      materialsAmmountLeg = RandRange(Cast(baseLegendaryMaterials) / 2, Cast(baseLegendaryMaterials) + 1);
      this.AddReward(TS, t"Query.QuickHackLegendaryMaterial", Cast(RoundMath(Cast(materialsAmmountLeg) * materialsMultiplier)));
    };
  }

  private final func AddReward(TS: ref<TransactionSystem>, itemQueryTDBID: TweakDBID, opt amount: Uint32) -> Void {
    let iconName: String;
    let iconsNameResolver: ref<IconsNameResolver>;
    let itemRecord: ref<Item_Record>;
    let itemRecordID: TweakDBID;
    let itemTypeRecordName: CName;
    if amount > 0u {
      itemTypeRecordName = TweakDBInterface.GetItemQueryRecord(itemQueryTDBID).RecordType();
      itemRecordID = TDBID.Create(NameToString(itemTypeRecordName));
      itemRecord = TweakDBInterface.GetItemRecord(itemRecordID);
      iconsNameResolver = IconsNameResolver.GetIconsNameResolver();
      iconName = itemRecord.IconPath();
      if !IsStringValid(iconName) {
        iconName = NameToString(iconsNameResolver.TranslateItemToIconName(itemRecordID, true));
      };
      if NotEquals(iconName, "None") && NotEquals(iconName, "") {
        ArrayPush(this.m_rewardNotificationIcons, iconName);
      };
      this.m_rewardNotificationString += GetLocalizedTextByKey(itemRecord.DisplayName());
      if StrLen(this.m_rewardNotificationString) > 0 {
        this.m_rewardNotificationString += "\\n";
      };
      TS.GiveItemByItemQuery(this.GetPlayerMainObject(), itemQueryTDBID, amount, 18446744073709551615u, "minigame");
    };
  }

  private final func CleanRewardNotification() -> Void {
    this.m_rewardNotificationString = "";
    ArrayClear(this.m_rewardNotificationIcons);
  }

  private final func ShowRewardNotification() -> Void {
    let notificationEvent: ref<HackingRewardNotificationEvent>;
    let uiSystem: ref<UISystem>;
    if StrLen(this.m_rewardNotificationString) > 0 {
      uiSystem = GameInstance.GetUISystem(this.GetGameInstance());
      notificationEvent = new HackingRewardNotificationEvent();
      notificationEvent.m_text = this.m_rewardNotificationString;
      notificationEvent.m_icons = this.m_rewardNotificationIcons;
      uiSystem.QueueEvent(notificationEvent);
    };
  }

  private final func ProcessMinigameNetworkActions(device: ref<DeviceComponentPS>) -> Void {
    let actionName: CName;
    let context: GetActionsContext;
    let i: Int32;
    let networkAction: ref<ScriptableDeviceAction>;
    let setDetectionEvent: ref<SetDetectionMultiplier>;
    let slaveClass: CName;
    let targetClass: CName;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let minigameBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().HackingMinigame);
    let minigamePrograms: array<TweakDBID> = FromVariant(minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms));
    let activeTraps: array<TweakDBID> = FromVariant(minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActiveTraps));
    this.FilterRedundantPrograms(minigamePrograms);
    if IsDefined(minigameBB) {
      context.requestType = gamedeviceRequestType.Remote;
      i = 0;
      while i < ArraySize(activeTraps) {
        if activeTraps[i] == t"MinigameTraps.MaterialBonus" {
          TS.GiveItemByItemQuery(this.GetPlayerMainObject(), t"Query.QuickHackMaterial", 1u);
        } else {
          if activeTraps[i] == t"MinigameTraps.IncreaseAwareness" {
            setDetectionEvent = new SetDetectionMultiplier();
            setDetectionEvent.multiplier = 10.00;
            (GameInstance.FindEntityByID(this.GetGameInstance(), PersistentID.ExtractEntityID(device.GetID())) as SensorDevice).QueueEvent(setDetectionEvent);
          };
        };
        i += 1;
      };
      i = 0;
      while i < ArraySize(minigamePrograms) {
        actionName = TweakDBInterface.GetObjectActionRecord(minigamePrograms[i]).ActionName();
        targetClass = TweakDBInterface.GetCName(minigamePrograms[i] + t".targetClass", n"");
        slaveClass = device.GetClassName();
        if Equals(targetClass, slaveClass) || Equals(targetClass, n"") {
          networkAction = (device as ScriptableDeviceComponentPS).GetMinigameActionByName(actionName, context) as ScriptableDeviceAction;
          if !IsDefined(networkAction) {
            networkAction = new PuppetAction();
            networkAction.SetUp(device);
          };
          networkAction.RegisterAsRequester(PersistentID.ExtractEntityID(device.GetID()));
          networkAction.SetExecutor(GetPlayer(this.GetGameInstance()));
          networkAction.SetObjectActionID(minigamePrograms[i]);
          networkAction.ProcessRPGAction(this.GetGameInstance());
        };
        i += 1;
      };
    };
  }

  private final func ExtractActions() -> array<ref<DeviceAction>> {
    let extractedActions: array<ref<DeviceAction>>;
    ArrayPush(extractedActions, this.GetActionByName(n"ToggleNetrunnerDive"));
    (extractedActions[0] as ScriptableDeviceAction).RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
    return extractedActions;
  }

  protected func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    ArrayPush(outActions, this.ActionQuestBreachAccessPoint());
    ArrayPush(outActions, this.ActionResetNetworkBreachState());
  }

  protected final func ActionResetNetworkBreachState() -> ref<ResetNetworkBreachState> {
    let action: ref<ResetNetworkBreachState> = new ResetNetworkBreachState();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnResetNetworkBreachState(evt: ref<ResetNetworkBreachState>) -> EntityNotificationType {
    this.SetIsBreached(false);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return false;
  }

  protected func CanCreateAnySpiderbotActions() -> Bool {
    return false;
  }

  public func FinalizeNetrunnerDive(state: HackingMinigameState) -> Void {
    this.FinalizeNetrunnerDive(state);
    if Equals(state, HackingMinigameState.Failed) {
      this.SendMinigameFailedToAllNPCs();
    };
  }

  public final func OnNPCBreachEvent(evt: ref<NPCBreachEvent>) -> EntityNotificationType {
    if Equals(evt.state, HackingMinigameState.Succeeded) {
      this.SetIsBreached(true);
      this.RefreshSlaves_Event();
    } else {
      if Equals(evt.state, HackingMinigameState.Failed) {
        this.m_minigameAttempt += 1;
        this.SendMinigameFailedToAllNPCs();
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected const func ResolveDive(isRemote: Bool) -> Void {
    this.ResolveDive(isRemote);
  }

  private final const func SendMinigameFailedToAllNPCs() -> Void {
    let evt: ref<MinigameFailEvent> = new MinigameFailEvent();
    let puppets: array<ref<PuppetDeviceLinkPS>> = this.GetPuppets();
    let i: Int32 = 0;
    while i < ArraySize(puppets) {
      this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(puppets[i].GetID()), evt);
      i += 1;
    };
  }

  public func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> EntityNotificationType {
    if evt.isRemote {
      this.SetIsBreached(true);
    };
    this.RefreshSlaves_Event();
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnValidate(evt: ref<Validate>) -> EntityNotificationType {
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      if !(slaves[i] as ScriptableDeviceComponentPS).IsQuickHacksExposed() {
        return EntityNotificationType.DoNotNotifyEntity;
      };
      i += 1;
    };
    this.SetIsBreached(true);
    this.m_skillCheckContainer.GetHackingSlot().SetIsActive(false);
    this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(true);
    this.m_skillCheckContainer.GetHackingSlot().CheckPerformed();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestRemoveQuickHacks(evt: ref<QuestRemoveQuickHacks>) -> EntityNotificationType {
    this.SetIsBreached(false);
    this.SendActionToAllSlaves(evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public func OnQuestBreachAccessPoint(evt: ref<QuestBreachAccessPoint>) -> EntityNotificationType {
    this.ExecutePSAction(this.ActionSetExposeQuickHacks());
    this.m_skillCheckContainer.GetHackingSlot().SetIsActive(false);
    this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(true);
    this.m_skillCheckContainer.GetHackingSlot().CheckPerformed();
    this.TurnAuthorizationModuleOFF();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, this.GetDeviceStatusAction());
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnSpiderbotEnableAccessPoint(evt: ref<SpiderbotEnableAccessPoint>) -> EntityNotificationType {
    this.m_isBreached = true;
    this.m_hasPersonalLinkSlot = false;
    this.m_skillCheckContainer.GetHackingSlot().SetIsActive(false);
    this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(true);
    this.m_skillCheckContainer.GetHackingSlot().CheckPerformed();
    this.TurnAuthorizationModuleOFF();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, this.GetDeviceStatusAction());
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func DebugBreachConnectedDevices() -> Void {
    this.RefreshSlaves_Event(false, true);
  }

  public final func OnBreachAccessPointEvent(evt: ref<BreachAccessPointEvent>) -> EntityNotificationType {
    this.SetIsBreached(true);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnRefreshSlavesEvent(evt: ref<RefreshSlavesEvent>) -> EntityNotificationType {
    if this.IsON() || evt.force {
      this.RefreshSlaves(evt.devices);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final const func GetCommunityProxies() -> array<ref<CommunityProxyPS>> {
    let proxies: array<ref<CommunityProxyPS>>;
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      if IsDefined(slaves[i] as CommunityProxyPS) {
        ArrayPush(proxies, slaves[i] as CommunityProxyPS);
      };
      i += 1;
    };
    return proxies;
  }

  protected const func GetNetworkArea() -> wref<NetworkAreaControllerPS> {
    let i: Int32;
    let networkArea: wref<NetworkAreaControllerPS>;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as NetworkAreaControllerPS) {
        networkArea = parents[i] as NetworkAreaControllerPS;
        return networkArea;
      };
      i += 1;
    };
    return null;
  }

  protected final func IsSpiderbotHackingConditionFullfilled() -> Bool {
    let checkResult: Bool;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if Cast(statsSystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.HasRemoteBotAccessPointBreach)) {
      checkResult = true;
    } else {
      checkResult = false;
    };
    if !AIActionHelper.CheckFlatheadStatPoolRequirements(this.GetGameInstance(), "DeviceAction") {
      checkResult = false;
    };
    return checkResult;
  }

  public final func UploadProgram(programID: Int32) -> Void {
    let programToExecute: ref<ProgramAction>;
    if !this.m_isBreached {
      return;
    };
    switch programID {
      case 1:
        programToExecute = this.ActionRevealEnemiesProgram();
    };
    if IsDefined(programToExecute) {
      this.ExecutePSAction(programToExecute);
    };
  }

  public func RevealDevicesGrid(shouldDraw: Bool, opt ownerEntityPosition: Vector4, opt fxDefault: FxResource, opt isPing: Bool, opt lifetime: Float, opt revealSlave: Bool, opt revealMaster: Bool, opt ignoreRevealed: Bool) -> Void {
    return;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().BackdoorBlackboard;
  }

  protected final const func CheckMasterRunnerAchievement(minigameProgramsCompleted: Int32) -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.MasterRunner;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) {
      return;
    };
    if minigameProgramsCompleted >= 3 {
      achievementRequest = new AddAchievementRequest();
      achievementRequest.achievement = achievement;
      dataTrackingSystem.QueueRequest(achievementRequest);
    };
  }

  private func PingSquad() -> Void {
    let puppetObject: wref<GameObject>;
    let squadName: CName;
    let puppets: array<ref<PuppetDeviceLinkPS>> = this.GetPuppets();
    let i: Int32 = 0;
    while i < ArraySize(puppets) {
      puppetObject = puppets[i].GetOwnerEntityWeak() as GameObject;
      if IsDefined(puppetObject) {
        squadName = AISquadHelper.GetSquadName(puppetObject as ScriptedPuppet);
        if this.IsSquadMarkedWithPing(squadName) {
        } else {
          this.AddPingedSquad(squadName);
          puppets[i].PingSquadNetwork();
        };
      };
      i += 1;
    };
    this.ClearPingedSquads();
  }

  private final func AddPingedSquad(squadName: CName) -> Void {
    if !ArrayContains(this.m_pingedSquads, squadName) {
      ArrayPush(this.m_pingedSquads, squadName);
    };
  }

  private final func RemovePingedSquad(squadName: CName) -> Void {
    ArrayRemove(this.m_pingedSquads, squadName);
  }

  private final func ClearPingedSquads() -> Void {
    if ArraySize(this.m_pingedSquads) > 0 {
      ArrayClear(this.m_pingedSquads);
    };
  }

  private final func IsSquadMarkedWithPing(squadName: CName) -> Bool {
    return ArrayContains(this.m_pingedSquads, squadName);
  }

  protected func OnFillTakeOverChainBBoardEvent(evt: ref<FillTakeOverChainBBoardEvent>) -> EntityNotificationType {
    this.FillTakeOverChainBB();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func CheckConnectedClassTypes() -> ConnectedClassTypes {
    let data: ConnectedClassTypes;
    let puppet: ref<GameObject>;
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(slaves) {
      if data.surveillanceCamera && data.securityTurret && data.puppet {
      } else {
        if IsDefined(slaves[i] as ScriptableDeviceComponentPS) && (!(slaves[i] as ScriptableDeviceComponentPS).IsON() || (slaves[i] as ScriptableDeviceComponentPS).IsBroken()) {
        } else {
          if !data.surveillanceCamera && IsDefined(slaves[i] as SurveillanceCameraControllerPS) {
            data.surveillanceCamera = true;
          } else {
            if !data.securityTurret && IsDefined(slaves[i] as SecurityTurretControllerPS) {
              data.securityTurret = true;
            } else {
              if !data.puppet && IsDefined(slaves[i] as PuppetDeviceLinkPS) {
                puppet = slaves[i].GetOwnerEntityWeak() as GameObject;
                if IsDefined(puppet) && puppet.IsActive() {
                  data.puppet = true;
                };
              };
            };
          };
        };
        i += 1;
      };
    };
    return data;
  }
}
