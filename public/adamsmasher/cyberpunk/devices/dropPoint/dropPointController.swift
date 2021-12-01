
public class DepositQuestItems extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"DepositQuestItems";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#6449", n"LocKey#6449");
  }
}

public class OpenVendorUI extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"OpenVendorUI";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#6760", n"LocKey#6760");
  }
}

public class CollectDropPointRewards extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"CollectDropPointRewards";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#6760", n"LocKey#6760");
  }
}

public class AddItemForPlayerToPickUp extends ScriptableDeviceAction {

  @attrib(customEditor, "TweakDBGroupInheritance;LootTables.Base_sts_reward")
  @attrib(tooltip, "Items from this loot table will be generated and as long as they are not collected player will have an additionl choice when interacting with Drop Point")
  public edit let lootTable: TweakDBID;

  @default(AddItemForPlayerToPickUp, true)
  public edit let shouldAdd: Bool;

  public final func GetFriendlyDescription() -> String {
    return "ADD QUEST REWARD TO DROP POINT";
  }
}

public class ReserveItemToThisDropPoint extends ScriptableDeviceAction {

  @attrib(customEditor, "TweakDBGroupInheritance;Items.STSItem")
  @attrib(tooltip, "Force player to deliver this item to this specific drop point")
  public edit let item: TweakDBID;

  public final func GetFriendlyDescription() -> String {
    return "RESERVE ITEM FOR THIS DROP POINT ONLY";
  }
}

public class DropPointController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class DropPointControllerPS extends BasicDistractionDeviceControllerPS {

  @attrib(customEditor, "TweakDBGroupInheritance;Vendors.DropPoint")
  private edit let m_vendorRecord: String;

  private persistent let m_rewardsLootTable: array<TweakDBID>;

  private persistent let m_hasPlayerCollectedReward: Bool;

  public final const quest func IsRewardCollected() -> Bool {
    return this.m_hasPlayerCollectedReward;
  }

  public final const func GetVendorRecordPath() -> String {
    return this.m_vendorRecord;
  }

  protected final func ActionDepositQuestItems(executor: ref<GameObject>) -> ref<DepositQuestItems> {
    let action: ref<DepositQuestItems> = new DepositQuestItems();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.SetExecutor(executor);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected final func OnDepositQuestItems(evt: ref<DepositQuestItems>) -> EntityNotificationType {
    let i: Int32;
    let items: array<wref<gameItemData>>;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let dps: ref<DropPointSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"DropPointSystem") as DropPointSystem;
    if !IsDefined(ts) || !IsDefined(dps) || !IsDefined(evt.GetExecutor()) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    ts.GetItemList(evt.GetExecutor(), items);
    i = 0;
    while i < ArraySize(items) {
      if dps.CanDeposit(ItemID.GetTDBID(items[i].GetID()), this.GetID()) {
        items[i].RemoveDynamicTag(n"Quest");
        AddFact(this.GetGameInstance(), items[i].GetName(), 1);
        ts.RemoveItem(evt.GetExecutor(), items[i].GetID(), 99999);
      };
      i += 1;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionOpenVendorUI(executor: ref<GameObject>) -> ref<OpenVendorUI> {
    let action: ref<OpenVendorUI> = new OpenVendorUI();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.SetExecutor(executor);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  protected final func OnOpenVendorUI(evt: ref<OpenVendorUI>) -> EntityNotificationType {
    let vendorData: ref<VendorPanelData>;
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    if IsDefined(uiSystem) {
      vendorData = new VendorPanelData();
      vendorData.data.vendorId = this.m_vendorRecord;
      vendorData.data.entityID = this.GetMyEntityID();
      vendorData.data.isActive = true;
      uiSystem.RequestVendorMenu(vendorData);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final const func ActionCollectDropPointRewards(executor: ref<GameObject>) -> ref<CollectDropPointRewards> {
    let action: ref<CollectDropPointRewards> = new CollectDropPointRewards();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.SetExecutor(executor);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  private final func OnCollectDropPointRewards(evt: ref<CollectDropPointRewards>) -> EntityNotificationType {
    let i: Int32;
    let itemData: wref<gameItemData>;
    let itemID: ItemID;
    let itemList: array<ItemModParams>;
    let scalingMod: ref<gameStatModifierData>;
    let statsSystem: ref<StatsSystem>;
    let lootManager: ref<LootManager> = GameInstance.GetLootManager(this.GetGameInstance());
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    if IsDefined(lootManager) && IsDefined(ts) {
      i = 0;
      while i < ArraySize(this.m_rewardsLootTable) {
        lootManager.GenerateLoot(this.m_rewardsLootTable[i], itemList);
        i += 1;
      };
      statsSystem = GameInstance.GetStatsSystem(this.GetGameInstance());
      scalingMod = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gameStatModifierType.Additive, statsSystem.GetStatValue(Cast(evt.GetExecutor().GetEntityID()), gamedataStatType.PowerLevel));
      i = 0;
      while i < ArraySize(itemList) {
        itemID = itemList[i].itemID;
        ts.GiveItem(evt.GetExecutor(), itemID, itemList[i].quantity);
        if !TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).IsSingleInstance() {
          itemData = ts.GetItemData(evt.GetExecutor(), itemID);
          statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel, true);
          statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), scalingMod);
        };
        i += 1;
      };
      ArrayClear(this.m_rewardsLootTable);
      this.m_hasPlayerCollectedReward = true;
    };
    this.UseNotifier(evt);
    GameInstance.GetAutoSaveSystem(this.GetGameInstance()).RequestCheckpoint();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnReserveItemToThisDropPoint(evt: ref<ReserveItemToThisDropPoint>) -> EntityNotificationType {
    let request: ref<DropPointRequest>;
    let dps: ref<DropPointSystem> = this.GetDropPointSystem();
    if IsDefined(dps) {
      request = new DropPointRequest();
      request.CreateRequest(evt.item, DropPointPackageStatus.ACTIVE, this.GetID());
      dps.QueueRequest(request);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnAddItemForPlayerToPickUp(evt: ref<AddItemForPlayerToPickUp>) -> EntityNotificationType {
    let i: Int32;
    if evt.shouldAdd {
      ArrayPush(this.m_rewardsLootTable, evt.lootTable);
      this.m_hasPlayerCollectedReward = false;
    } else {
      i = 0;
      while i < ArraySize(this.m_rewardsLootTable) {
        if this.m_rewardsLootTable[i] == evt.lootTable {
          ArrayErase(this.m_rewardsLootTable, i);
        };
        i += 1;
      };
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let dps: ref<DropPointSystem>;
    if !this.GetActions(outActions, context) {
      return false;
    };
    dps = this.GetDropPointSystem();
    if !dps.IsEnabled() {
      return false;
    };
    if ArraySize(this.m_rewardsLootTable) > 0 {
      ArrayPush(outActions, this.ActionCollectDropPointRewards(context.processInitiatorObject));
    };
    ArrayPush(outActions, this.ActionOpenVendorUI(context.processInitiatorObject));
    dps = this.GetDropPointSystem();
    if IsDefined(dps) && dps.HasItemsThatCanBeDeposited(context.processInitiatorObject, this.GetID()) {
      ArrayPush(outActions, this.ActionDepositQuestItems(context.processInitiatorObject));
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceBackground";
  }
}
