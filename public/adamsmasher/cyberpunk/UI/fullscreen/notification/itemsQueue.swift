
public class ItemsNotificationQueue extends gameuiGenericNotificationGameController {

  @default(ItemsNotificationQueue, 6.0f)
  private let m_showDuration: Float;

  private let m_transactionSystem: wref<TransactionSystem>;

  @default(ItemsNotificationQueue, notification_currency)
  private let m_currencyNotification: CName;

  @default(ItemsNotificationQueue, Item_Received_SMALL)
  private let m_itemNotification: CName;

  @default(ItemsNotificationQueue, progression)
  private let m_xpNotification: CName;

  private let m_playerPuppet: wref<GameObject>;

  private let m_inventoryListener: wref<InventoryScriptListener>;

  private let m_currencyInventoryListener: wref<InventoryScriptListener>;

  private let m_playerDevelopmentSystem: ref<PlayerDevelopmentSystem>;

  private let m_combatModeListener: ref<CallbackHandle>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_comparisonResolver: ref<ItemPreferredComparisonResolver>;

  private let m_combatModePSM: gamePSMCombat;

  public func GetShouldSaveState() -> Bool {
    return true;
  }

  public func GetID() -> Int32 {
    return EnumInt(GenericNotificationType.ProgressionNotification);
  }

  protected cb func OnCombatStateChanged(value: Int32) -> Bool {
    this.m_combatModePSM = IntEnum(value);
    if Equals(this.m_combatModePSM, gamePSMCombat.InCombat) {
      this.SetNotificationPause(true);
      this.GetRootWidget().SetVisible(false);
    } else {
      this.SetNotificationPause(false);
      this.GetRootWidget().SetVisible(true);
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let itemCallback: ref<ItemAddedInventoryCallback> = new ItemAddedInventoryCallback();
    itemCallback.m_notificationQueue = this;
    this.m_playerPuppet = playerPuppet;
    this.m_transactionSystem = GameInstance.GetTransactionSystem(playerPuppet.GetGame());
    this.m_inventoryListener = this.m_transactionSystem.RegisterInventoryListener(playerPuppet, itemCallback);
    let currencyCallback: ref<CurrencyChangeInventoryCallback> = new CurrencyChangeInventoryCallback();
    currencyCallback.m_notificationQueue = this;
    this.m_currencyInventoryListener = this.m_transactionSystem.RegisterInventoryListener(playerPuppet, currencyCallback);
    this.m_playerDevelopmentSystem = GameInstance.GetScriptableSystemsContainer(this.m_playerPuppet.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    this.RegisterPSMListeners(this.m_playerPuppet);
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_playerPuppet as PlayerPuppet);
    this.m_comparisonResolver = ItemPreferredComparisonResolver.Make(this.m_InventoryManager);
    this.SetNotificationPauseWhenHidden(true);
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_transactionSystem.UnregisterInventoryListener(playerPuppet, this.m_inventoryListener);
    this.m_inventoryListener = null;
    this.m_transactionSystem.UnregisterInventoryListener(playerPuppet, this.m_currencyInventoryListener);
    this.m_currencyInventoryListener = null;
    this.UnregisterPSMListeners(this.m_playerPuppet);
  }

  protected cb func OnUILootedItemEvent(evt: ref<UILootedItemEvent>) -> Bool {
    let inventoryItem: InventoryItemData = this.m_InventoryManager.GetItemFromRecord(ItemID.GetTDBID(evt.itemID));
    if this.NeedsNotification(inventoryItem) {
      this.PushItemNotification(evt.itemID, InventoryItemData.GetQuality(inventoryItem));
    };
  }

  private final func NeedsNotification(newItem: InventoryItemData) -> Bool {
    if this.EquipmentAreaNeedsNotification(InventoryItemData.GetEquipmentArea(newItem)) {
      if this.ShouldRarityForceNotification(newItem) || Equals(InventoryItemData.GetLootItemType(newItem), LootItemType.Quest) {
        return true;
      };
    };
    return false;
  }

  private final func EquipmentAreaNeedsNotification(area: gamedataEquipmentArea) -> Bool {
    return Equals(area, gamedataEquipmentArea.Weapon) || Equals(area, gamedataEquipmentArea.WeaponHeavy) || Equals(area, gamedataEquipmentArea.WeaponWheel) || Equals(area, gamedataEquipmentArea.WeaponLeft) || Equals(area, gamedataEquipmentArea.Face) || Equals(area, gamedataEquipmentArea.Feet) || Equals(area, gamedataEquipmentArea.Head) || Equals(area, gamedataEquipmentArea.InnerChest) || Equals(area, gamedataEquipmentArea.OuterChest) || Equals(area, gamedataEquipmentArea.Legs) || Equals(area, gamedataEquipmentArea.Outfit) || Equals(area, gamedataEquipmentArea.Quest);
  }

  private final func ShouldRarityForceNotification(newItem: InventoryItemData) -> Bool {
    return Equals(InventoryItemData.GetQuality(newItem), n"Legendary") || RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(newItem));
  }

  private final func IsBestInBackpack(newItem: InventoryItemData) -> Bool {
    let itemToCompare: InventoryItemData;
    let items: array<InventoryItemData> = this.m_InventoryManager.GetPlayerInventoryData(InventoryItemData.GetEquipmentArea(newItem), true);
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      itemToCompare = items[i];
      if ItemID.GetTDBID(InventoryItemData.GetID(newItem)) == ItemID.GetTDBID(InventoryItemData.GetID(itemToCompare)) {
        if Equals(this.m_comparisonResolver.CompareItems(itemToCompare, newItem), ItemComparisonState.Better) {
          return false;
        };
      };
      i += 1;
    };
    return true;
  }

  protected cb func OnVendorBoughtItemEvent(evt: ref<VendorBoughtItemEvent>) -> Bool {
    let inventoryItem: InventoryItemData;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(evt.items);
    while i < limit {
      inventoryItem = this.m_InventoryManager.GetItemFromRecord(ItemID.GetTDBID(evt.items[i]));
      this.PushItemNotification(evt.items[i], UIItemsHelper.QualityEnumToName(RPGManager.GetItemDataQuality(InventoryItemData.GetGameItemData(inventoryItem))));
      i += 1;
    };
  }

  protected cb func OnCharacterProficiencyUpdated(evt: ref<ProficiencyProgressEvent>) -> Bool {
    switch evt.type {
      case gamedataProficiencyType.Level:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"XP", "LocKey#40364", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.StreetCred:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"StreetCred", "LocKey#1210", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Assault:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22315", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Athletics:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22299", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Brawling:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22306", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.ColdBlood:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22302", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.CombatHacking:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22332", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Engineering:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22326", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Gunslinger:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22311", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Kenjutsu:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22318", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Stealth:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22324", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Demolition:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22320", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Crafting:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22328", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Hacking:
        this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22330", evt.type, evt.currentLevel, evt.isLevelMaxed);
    };
  }

  protected cb func OnNewTarotCardAdded(evt: ref<TarotCardAdded>) -> Bool {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<TarotCardAddedNotificationViewData> = new TarotCardAddedNotificationViewData();
    userData.cardName = evt.cardName;
    userData.imagePart = evt.imagePart;
    userData.animation = n"tarot_card";
    let action: ref<OpenTarotCollectionNotificationAction> = new OpenTarotCollectionNotificationAction();
    action.m_eventDispatcher = this;
    userData.action = action;
    userData.soundEvent = n"TarotCollectedPopup";
    userData.soundAction = n"OnCollect";
    notificationData.widgetLibraryItemName = n"tarot_card";
    notificationData.notificationData = userData;
    notificationData.time = this.m_showDuration;
    this.AddNewNotificationData(notificationData);
  }

  public final func PushXPNotification(value: Int32, remainingPointsToLevelUp: Int32, delta: Int32, notificationColorTheme: CName, notificationName: String, type: gamedataProficiencyType, currentLevel: Int32, isLevelMaxed: Bool) -> Void {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<ProgressionViewData>;
    let sum: Int32 = remainingPointsToLevelUp + value;
    let progress: Float = Cast(value) / Cast(sum);
    if progress == 0.00 {
      progress = Cast(sum);
    };
    notificationData.widgetLibraryItemName = this.m_xpNotification;
    userData = new ProgressionViewData();
    userData.expProgress = progress;
    userData.expValue = value;
    userData.notificationColorTheme = notificationColorTheme;
    userData.title = notificationName;
    userData.delta = delta;
    userData.type = type;
    userData.currentLevel = currentLevel;
    userData.isLevelMaxed = isLevelMaxed;
    notificationData.time = 3.00;
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }

  public final func PushCurrencyNotification(diff: Int32, total: Uint32) -> Void {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<CurrencyUpdateNotificationViewData>;
    if diff == 0 {
      return;
    };
    userData = new CurrencyUpdateNotificationViewData();
    userData.diff = diff;
    userData.total = total;
    userData.soundEvent = n"QuestUpdatePopup";
    userData.soundAction = n"OnOpen";
    notificationData.time = 6.10;
    notificationData.widgetLibraryItemName = this.m_currencyNotification;
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }

  public final func PushItemNotification(itemID: ItemID, itemRarity: CName) -> Void {
    let currentItemRecordTags: array<CName>;
    let data: ref<ItemAddedNotificationViewData>;
    let isShard: Bool;
    let notificationData: gameuiGenericNotificationData;
    let currentItemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    if IsDefined(currentItemRecord) {
      currentItemRecordTags = currentItemRecord.Tags();
    };
    isShard = ArrayContains(currentItemRecordTags, n"Shard");
    if itemID != MarketSystem.Money() && !isShard {
      data = new ItemAddedNotificationViewData();
      data.animation = this.m_itemNotification;
      data.itemRarity = itemRarity;
      data.itemID = itemID;
      data.title = GetLocalizedText("Story-base-gameplay-gui-widgets-notifications-quest_update-_localizationString19");
      notificationData.time = 7.50;
      notificationData.widgetLibraryItemName = this.m_itemNotification;
      notificationData.notificationData = data;
      this.AddNewNotificationData(notificationData);
    };
  }

  protected final func RegisterPSMListeners(playerObject: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerObject);
      if IsDefined(playerStateMachineBlackboard) {
        this.m_combatModeListener = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.Combat, this, n"OnCombatStateChanged");
      };
    };
  }

  protected final func UnregisterPSMListeners(playerObject: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerObject);
      if IsDefined(playerStateMachineBlackboard) {
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.Combat, this.m_combatModeListener);
      };
    };
  }

  private final func GetComparisonState(item: InventoryItemData) -> ItemComparisonState {
    if this.m_comparisonResolver.IsComparable(item) {
      return this.m_comparisonResolver.GetItemComparisonState(item);
    };
    return ItemComparisonState.Default;
  }
}

public class ItemAddedInventoryCallback extends InventoryScriptCallback {

  public let m_notificationQueue: wref<ItemsNotificationQueue>;

  public func OnItemNotification(item: ItemID, itemData: wref<gameItemData>) -> Void {
    this.m_notificationQueue.PushItemNotification(item, this.GetItemRarity(itemData));
  }

  private final func GetItemRarity(data: wref<gameItemData>) -> CName {
    let qual: gamedataQuality = RPGManager.GetItemDataQuality(data);
    let quality: CName = UIItemsHelper.QualityEnumToName(qual);
    return quality;
  }
}

public class ItemAddedNotification extends GenericNotificationController {

  protected edit let m_itemImage: inkImageRef;

  protected edit let m_rarityBar: inkWidgetRef;

  protected let m_itemIconGender: ItemIconGender;

  protected let m_animationName: CName;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    let data: ref<ItemAddedNotificationViewData> = notificationData as ItemAddedNotificationViewData;
    this.m_animationName = data.animation;
    this.SetIcon(ItemID.GetTDBID(data.itemID), data.itemRarity);
    this.SetNotificationData(notificationData);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_itemIconGender = UIGenderHelper.GetIconGender(playerPuppet as PlayerPuppet);
  }

  private final func SetIcon(itemID: TweakDBID, rarity: CName) -> Void {
    let iconName: String;
    let iconPath: String;
    let iconsNameResolver: ref<IconsNameResolver>;
    let itemRecord: wref<Item_Record>;
    let recipeRecord: wref<ItemRecipe_Record> = TweakDBInterface.GetItemRecipeRecord(itemID);
    if IsDefined(recipeRecord) {
      itemRecord = TweakDBInterface.GetItemRecipeRecord(itemID).CraftingResult().Item();
    } else {
      itemRecord = TweakDBInterface.GetItemRecord(itemID);
    };
    iconsNameResolver = IconsNameResolver.GetIconsNameResolver();
    iconPath = itemRecord.IconPath();
    inkWidgetRef.SetVisible(this.m_itemImage, false);
    if IsStringValid(iconPath) {
      iconName = iconPath;
    } else {
      iconName = NameToString(iconsNameResolver.TranslateItemToIconName(itemID, Equals(this.m_itemIconGender, ItemIconGender.Male)));
    };
    if NotEquals(iconName, "None") && NotEquals(iconName, "") {
      inkWidgetRef.SetScale(this.m_itemImage, Equals(itemRecord.EquipArea().Type(), gamedataEquipmentArea.Outfit) ? new Vector2(0.50, 0.50) : new Vector2(1.00, 1.00));
      InkImageUtils.RequestSetImage(this, this.m_itemImage, "UIIcon." + iconName, n"OnIconCallback");
    };
    this.UpdateRarity(rarity);
  }

  protected cb func OnIconCallback(e: ref<iconAtlasCallbackData>) -> Bool {
    inkWidgetRef.SetVisible(this.m_itemImage, Equals(e.loadResult, inkIconResult.Success));
    this.PlayLibraryAnimation(this.m_animationName);
  }

  protected func UpdateRarity(rarity: CName) -> Void {
    let visible: Bool = NotEquals(rarity, n"");
    visible = false;
    inkWidgetRef.SetVisible(this.m_rarityBar, visible);
    inkWidgetRef.SetState(this.m_rarityBar, rarity);
  }
}

public native class ItemAddedNotificationViewData extends GenericNotificationViewData {

  public native let itemID: ItemID;

  public native let animation: CName;

  public native let itemRarity: CName;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    let compareTo: ref<ItemAddedNotificationViewData> = data as ItemAddedNotificationViewData;
    return IsDefined(compareTo) && compareTo.itemID == this.itemID;
  }
}

public class TarotCardAddedNotification extends GenericNotificationController {

  protected edit let m_cardImage: inkImageRef;

  protected edit let m_cardNameLabel: inkTextRef;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    let data: ref<TarotCardAddedNotificationViewData> = notificationData as TarotCardAddedNotificationViewData;
    inkTextRef.SetText(this.m_cardNameLabel, data.cardName);
    InkImageUtils.RequestSetImage(this, this.m_cardImage, "UIIcon." + NameToString(data.imagePart));
    this.PlayLibraryAnimation(data.animation);
    this.SetNotificationData(notificationData);
  }
}
