
public class LootingGameController extends inkGameController {

  private let m_dataManager: ref<InventoryDataManagerV2>;

  private let m_bbInteractions: wref<IBlackboard>;

  private let m_bbEquipmentData: wref<IBlackboard>;

  private let m_bbEquipment: wref<IBlackboard>;

  private let m_bbInteractionsDefinition: ref<UIInteractionsDef>;

  private let m_bbEquipmentDataDefinition: ref<UI_EquipmentDataDef>;

  private let m_bbEquipmentDefinition: ref<UI_EquipmentDef>;

  private let m_dataListenerId: ref<CallbackHandle>;

  private let m_activeListenerId: ref<CallbackHandle>;

  private let m_activeHubListenerId: ref<CallbackHandle>;

  private let m_weaponDataListenerId: ref<CallbackHandle>;

  private let m_itemEquippedListenerId: ref<CallbackHandle>;

  private let m_controller: wref<LootingController>;

  private let m_player: wref<PlayerPuppet>;

  private let m_introAnim: ref<inkAnimProxy>;

  private let m_outroAnim: ref<inkAnimProxy>;

  private let m_lastActiveWeapon: SlotWeaponData;

  private let m_lastActiveWeaponData: InventoryItemData;

  private let m_previousData: LootData;

  public let m_lastActiveOwnerId: EntityID;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToBB();
    this.m_player = this.GetOwnerEntity() as PlayerPuppet;
    this.m_dataManager = new InventoryDataManagerV2();
    this.m_dataManager.Initialize(this.m_player);
    this.m_controller = this.GetController() as LootingController;
    this.m_controller.SetDataManager(this.m_dataManager);
    if IsDefined(this.m_player) {
      this.m_controller.SetGameInstance(this.m_player.GetGame());
    };
    this.m_controller.Hide();
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_dataManager.UnInitialize();
    this.UnregisterFromBB();
  }

  private final func RegisterToBB() -> Void {
    this.m_bbInteractionsDefinition = GetAllBlackboardDefs().UIInteractions;
    this.m_bbEquipmentDataDefinition = GetAllBlackboardDefs().UI_EquipmentData;
    this.m_bbEquipmentDefinition = GetAllBlackboardDefs().UI_Equipment;
    this.m_bbEquipmentData = this.GetBlackboardSystem().Get(this.m_bbEquipmentDataDefinition);
    this.m_bbEquipment = this.GetBlackboardSystem().Get(this.m_bbEquipmentDefinition);
    this.m_bbInteractions = this.GetBlackboardSystem().Get(this.m_bbInteractionsDefinition);
    this.m_dataListenerId = this.m_bbInteractions.RegisterDelayedListenerVariant(this.m_bbInteractionsDefinition.LootData, this, n"OnUpdateData");
    this.m_activeHubListenerId = this.m_bbInteractions.RegisterDelayedListenerInt(this.m_bbInteractionsDefinition.ActiveChoiceHubID, this, n"OnActivateHub");
    this.m_weaponDataListenerId = this.m_bbEquipmentData.RegisterListenerVariant(this.m_bbEquipmentDataDefinition.EquipmentData, this, n"OnWeaponDataChanged");
    this.m_itemEquippedListenerId = this.m_bbEquipment.RegisterListenerVariant(this.m_bbEquipmentDefinition.itemEquipped, this, n"OnItemEquipped");
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_bbInteractions) {
      this.m_bbInteractions.UnregisterDelayedListener(this.m_bbInteractionsDefinition.LootData, this.m_dataListenerId);
      this.m_bbInteractions.UnregisterDelayedListener(this.m_bbInteractionsDefinition.ActiveChoiceHubID, this.m_activeHubListenerId);
    };
    if IsDefined(this.m_bbEquipmentData) {
      this.m_bbEquipmentData.UnregisterDelayedListener(this.m_bbEquipmentDataDefinition.EquipmentData, this.m_weaponDataListenerId);
    };
    if IsDefined(this.m_bbEquipment) {
      this.m_bbEquipment.UnregisterDelayedListener(this.m_bbEquipmentDefinition.itemEquipped, this.m_itemEquippedListenerId);
    };
    this.m_bbEquipmentData = null;
    this.m_bbInteractions = null;
    this.m_bbEquipment = null;
  }

  private final func SetShouldHideClampedMappins(flag: Bool) -> Void {
    if IsDefined(this.m_bbInteractions) {
      this.m_bbInteractions.SetBool(this.m_bbInteractionsDefinition.ShouldHideClampedMappins, flag);
    };
  }

  protected cb func OnWeaponDataChanged(value: Variant) -> Bool {
    let item: ref<gameItemData>;
    let data: ref<SlotDataHolder> = FromVariant(value);
    let currentData: SlotWeaponData = data.weapon;
    if ItemID.IsValid(currentData.weaponID) {
      if this.m_lastActiveWeapon.weaponID != currentData.weaponID {
        item = this.m_dataManager.GetPlayerItemData(currentData.weaponID);
        this.m_lastActiveWeaponData = this.m_dataManager.GetInventoryItemData(item);
        this.m_controller.SetActiveWeapon(this.m_lastActiveWeaponData);
      };
      this.m_lastActiveWeapon = currentData;
    };
  }

  protected cb func OnItemEquipped(value: Variant) -> Bool {
    let equipmentAreaRecord: wref<EquipmentArea_Record>;
    let itemRecord: wref<Item_Record>;
    let itemID: ItemID = FromVariant(value);
    if ItemID.IsValid(itemID) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
      equipmentAreaRecord = itemRecord.EquipArea();
      if IsDefined(equipmentAreaRecord) {
        this.m_controller.UpdateEquipmentArea(equipmentAreaRecord.Type());
      };
    };
  }

  private final func IsUpdateRequired(newData: LootData) -> Bool {
    let choicesSize: Int32;
    let i: Int32;
    let itemIDsSize: Int32;
    if NotEquals(newData.isActive, this.m_previousData.isActive) || NotEquals(newData.isListOpen, this.m_previousData.isListOpen) || NotEquals(newData.e3hack_isWeapon, this.m_previousData.e3hack_isWeapon) || NotEquals(newData.isLocked, this.m_previousData.isLocked) || newData.ownerId != this.m_previousData.ownerId || newData.currentIndex != this.m_previousData.currentIndex || NotEquals(newData.title, this.m_previousData.title) {
      return true;
    };
    choicesSize = ArraySize(newData.choices);
    if choicesSize != ArraySize(this.m_previousData.choices) {
      return true;
    };
    itemIDsSize = ArraySize(newData.itemIDs);
    if itemIDsSize != ArraySize(this.m_previousData.itemIDs) {
      return true;
    };
    i = 0;
    while i < choicesSize {
      if NotEquals(newData.choices[i], this.m_previousData.choices[i]) {
        return true;
      };
      i += 1;
    };
    i = 0;
    while i < itemIDsSize {
      if newData.itemIDs[i] != this.m_previousData.itemIDs[i] {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected cb func OnInvalidateTooltipOwnerEvent(e: ref<InvalidateTooltipOwnerEvent>) -> Bool {
    if this.m_controller.IsTooltipVisible() && this.m_controller.GetTooltipOwner(0) != this.m_controller.GetCurrentItemOwnerId() {
      this.m_controller.SetTooltipVisible(this.m_previousData.isActive && this.m_controller.GetTooltipOwner(0) == this.m_controller.GetCurrentItemOwnerId());
    };
  }

  protected cb func OnUpdateData(value: Variant) -> Bool {
    let container: ref<gameLootContainerBase>;
    let lootEntity: ref<Entity>;
    let lootObject: ref<gameLootObject>;
    let data: LootData = FromVariant(value);
    this.m_controller.SetTooltipVisible(data.isActive && ArraySize(data.itemIDs) > 0);
    if this.IsUpdateRequired(data) {
      this.m_previousData = data;
      if this.m_previousData.isActive {
        if !this.m_controller.IsShown() {
          if IsDefined(this.m_outroAnim) && this.m_outroAnim.IsPlaying() {
            this.m_outroAnim.Stop();
          };
          if IsDefined(this.m_introAnim) && this.m_introAnim.IsPlaying() {
            this.m_introAnim.Stop();
          };
          this.m_introAnim = this.PlayLibraryAnimation(n"actions_intro");
        };
        this.m_controller.Show();
        this.m_controller.ShowLockedStatus(this.m_previousData.isLocked);
        if IsDefined(this.m_player) {
          lootEntity = GameInstance.FindEntityByID(this.m_player.GetGame(), this.m_previousData.ownerId);
          container = GameInstance.FindEntityByID(this.m_player.GetGame(), this.m_previousData.ownerId) as gameLootContainerBase;
        };
        if !IsDefined(container) {
          lootObject = lootEntity as gameLootObject;
          if IsDefined(lootObject) {
            container = lootObject.GetOwner() as gameLootContainerBase;
          };
        };
        this.m_controller.SetLootData(this.m_previousData);
        this.SetShouldHideClampedMappins(true);
      } else {
        this.m_controller.Hide();
        this.SetShouldHideClampedMappins(false);
      };
    };
    if data.isActive {
      this.m_lastActiveOwnerId = data.ownerId;
    };
  }

  protected cb func OnActivateHub(activeHubId: Int32) -> Bool {
    let isDialogOpen: Bool = activeHubId > -1;
    this.m_controller.SetDialogOpen(isDialogOpen);
  }
}

public class LootingController extends inkLogicController {

  private let m_root: wref<inkWidget>;

  private edit let m_itemsListContainer: inkCompoundRef;

  private edit let m_titleContainer: inkCompoundRef;

  private edit let m_upArrow: inkWidgetRef;

  private edit let m_downArrow: inkWidgetRef;

  private edit let m_listWrapper: inkWidgetRef;

  private edit let m_actionsListV: inkCompoundRef;

  private edit let m_lockedStatusContainer: inkWidgetRef;

  private let m_widgetsPoolList: array<wref<inkWidget>>;

  private let m_requestedWidgetsPoolItems: Int32;

  private let m_lootList: array<wref<inkWidget>>;

  private let m_requestedItemsPoolItems: Int32;

  private let m_dataManager: wref<InventoryDataManagerV2>;

  private let m_gameInstance: GameInstance;

  @default(LootingController, 3)
  private edit let m_maxItemsNum: Int32;

  private let m_tooltipProvider: wref<TooltipProvider>;

  private let m_cachedTooltipData: ref<ATooltipData>;

  private let m_startIndex: Int32;

  private let m_selectedItemIndex: Int32;

  private let m_itemsToCompare: Int32;

  private let m_isShown: Bool;

  private let m_currentComparisonItemId: ItemID;

  private let m_lastTooltipItemId: ItemID;

  private let m_currentTooltipItemId: ItemID;

  private let m_currentTooltipLootingData: ref<TooltipLootingCachedData>;

  private let m_lastItemOwnerId: EntityID;

  private let m_currentItemOwnerId: EntityID;

  private let m_currentComparisonEquipmentArea: gamedataEquipmentArea;

  private let m_lastListOpenedState: Bool;

  private let m_isComaprisonDirty: Bool;

  private let bufferedOwnerId: EntityID;

  private let introAnimProxy: ref<inkAnimProxy>;

  private let m_currendData: LootData;

  private let m_activeWeapon: InventoryItemData;

  private let m_isLocked: Bool;

  private let m_currentWidgetRequestVersion: Int32;

  private let m_currentItemRequestVersion: Int32;

  private let m_requestsCounter: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.m_tooltipProvider = this.GetControllerByType(n"TooltipProvider") as TooltipProvider;
  }

  public final func SetTooltipVisible(visible: Bool) -> Void {
    this.m_tooltipProvider.SetVisible(visible);
    this.m_tooltipProvider.InvalidateHidden();
  }

  public final func SetDataManager(dataManager: ref<InventoryDataManagerV2>) -> Void {
    this.m_dataManager = dataManager;
  }

  public final func SetGameInstance(gameInstance: GameInstance) -> Void {
    this.m_gameInstance = gameInstance;
  }

  public final func SetActiveWeapon(weapon: InventoryItemData) -> Void {
    this.m_activeWeapon = weapon;
    if this.m_isShown {
      this.SetLootData(this.m_currendData);
    };
  }

  public final func CycleSelectedItem() -> Void {
    if this.m_itemsToCompare > 1 {
      this.m_selectedItemIndex = (this.m_selectedItemIndex + 1) % this.m_itemsToCompare;
      this.RefreshTooltips();
    };
  }

  public final func Show() -> Void {
    this.m_root.SetVisible(true);
    this.m_selectedItemIndex = -1;
    this.RefreshTooltips();
    this.RefreshComparisonData();
    this.m_isShown = true;
  }

  public final func Hide() -> Void {
    this.m_tooltipProvider.ClearTooltipData();
    this.m_tooltipProvider.RefreshTooltips();
    this.m_selectedItemIndex = -1;
    this.m_root.SetVisible(false);
    this.m_isShown = false;
  }

  public final func ShowLockedStatus(islokced: Bool) -> Void {
    this.m_isLocked = islokced;
    inkWidgetRef.SetVisible(this.m_lockedStatusContainer, islokced);
    inkWidgetRef.SetVisible(this.m_listWrapper, !islokced);
  }

  public final func IsShown() -> Bool {
    return this.m_isShown;
  }

  private final func RefreshComparisonData() -> Void {
    let comparisonTooltipData: ref<InventoryTooltipData>;
    let controller: ref<LootingListItemController>;
    let equippedItem: InventoryItemData;
    let itemData: InventoryItemData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_lootList) {
      controller = this.m_lootList[i].GetController() as LootingListItemController;
      itemData = controller.GetTooltipData().inventoryItemData;
      equippedItem = this.GetPureItemForComparison(itemData);
      comparisonTooltipData = this.m_dataManager.GetComparisonTooltipsData(equippedItem, itemData);
      controller.SetData(comparisonTooltipData);
      i += 1;
    };
  }

  private final func RefreshChoicesPool(choices: script_ref<array<InteractionChoiceData>>) -> Void {
    let currentItem: wref<inkWidget>;
    let currentItemController: wref<interactionItemLogicController>;
    let spawnData: ref<WidgetsPoolItemSpawnData>;
    let count: Int32 = ArraySize(Deref(choices));
    this.m_currentWidgetRequestVersion = (this.m_currentWidgetRequestVersion + 1) % 255;
    let i: Int32 = 0;
    while i < ArraySize(this.m_widgetsPoolList) {
      if !IsDefined(this.m_widgetsPoolList[i]) {
        this.m_requestedWidgetsPoolItems -= 1;
        ArrayErase(this.m_widgetsPoolList, i);
      } else {
        i += 1;
      };
    };
    if ArraySize(this.m_widgetsPoolList) > count {
      while ArraySize(this.m_widgetsPoolList) > count {
        currentItem = ArrayPop(this.m_widgetsPoolList);
        inkCompoundRef.RemoveChild(this.m_actionsListV, currentItem);
      };
      this.m_requestedWidgetsPoolItems = count;
    };
    ArrayResize(this.m_widgetsPoolList, count);
    if count > this.m_requestedWidgetsPoolItems {
      i = this.m_requestedWidgetsPoolItems;
      while i < count {
        spawnData = new WidgetsPoolItemSpawnData();
        spawnData.index = i;
        spawnData.requestVersion = this.m_currentWidgetRequestVersion;
        this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_actionsListV), r"base\\gameplay\\gui\\widgets\\interactions\\interaction.inkwidget", n"choice", this, n"OnWidgetsPoolItemSpawned", spawnData);
        this.m_requestsCounter += 1;
        this.m_requestedWidgetsPoolItems += 1;
        i += 1;
      };
    };
    i = 0;
    while i < count {
      if IsDefined(this.m_widgetsPoolList[i]) {
        currentItemController = this.m_widgetsPoolList[i].GetController() as interactionItemLogicController;
        currentItemController.SetData(Deref(choices)[i]);
      };
      i += 1;
    };
  }

  protected cb func OnWidgetsPoolItemSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let data: ref<WidgetsPoolItemSpawnData> = userData as WidgetsPoolItemSpawnData;
    this.m_requestsCounter -= 1;
    if Cast(this.m_requestsCounter = 0) {
      this.QueueEvent(new InvalidateTooltipOwnerEvent());
    };
    if this.m_currentWidgetRequestVersion != data.requestVersion {
      inkCompoundRef.RemoveChild(this.m_actionsListV, widget);
      return false;
    };
    widget.SetVAlign(inkEVerticalAlign.Top);
    widget.SetHAlign(inkEHorizontalAlign.Left);
    this.m_widgetsPoolList[data.index] = widget;
    if IsDefined(data) {
      (widget.GetController() as interactionItemLogicController).SetData(this.m_currendData.choices[data.index]);
    };
  }

  private final func RefreshItemsPool(totalItems: Int32, visibleItems: Int32) -> Void {
    let currentItem: wref<inkWidget>;
    let spawnData: ref<ItemsPoolItemSpawnData>;
    this.m_currentItemRequestVersion = (this.m_currentItemRequestVersion + 1) % 255;
    let i: Int32 = 0;
    while i < ArraySize(this.m_lootList) {
      if !IsDefined(this.m_lootList[i]) {
        this.m_requestedItemsPoolItems -= 1;
        ArrayErase(this.m_lootList, i);
      } else {
        i += 1;
      };
    };
    while ArraySize(this.m_lootList) > visibleItems {
      currentItem = ArrayPop(this.m_lootList);
      inkCompoundRef.RemoveChild(this.m_itemsListContainer, currentItem);
      this.m_requestedItemsPoolItems = visibleItems;
    };
    ArrayResize(this.m_lootList, visibleItems);
    if visibleItems > this.m_requestedItemsPoolItems {
      i = this.m_requestedItemsPoolItems;
      while i < visibleItems {
        spawnData = new ItemsPoolItemSpawnData();
        spawnData.index = i;
        spawnData.requestVersion = this.m_currentItemRequestVersion;
        ItemDisplayUtils.SpawnCommonSlotAsync(this, this.m_itemsListContainer, n"lootSlot", n"OnItemsPoolItemSpawned", spawnData);
        this.m_requestedItemsPoolItems += 1;
        i += 1;
      };
    };
    i = 0;
    while i < visibleItems {
      this.UpdateIndexedWidgetData(i);
      i += 1;
    };
  }

  protected cb func OnItemsPoolItemSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let data: ref<ItemsPoolItemSpawnData> = userData as ItemsPoolItemSpawnData;
    if IsDefined(data) {
      if data.requestVersion != this.m_currentItemRequestVersion {
        inkCompoundRef.RemoveChild(this.m_itemsListContainer, widget);
        return false;
      };
      this.m_lootList[data.index] = widget;
      this.UpdateIndexedWidgetData(data.index);
    };
  }

  private final func RefreshItemsData(data: script_ref<LootData>, visibleItems: Int32, totalItems: Int32, out lastIndex: Int32) -> Void {
    this.m_startIndex = Clamp(Deref(data).currentIndex - this.m_maxItemsNum / 2, 0, totalItems - visibleItems);
    lastIndex = this.m_startIndex + visibleItems - 1;
  }

  private final func UpdateIndexedWidgetData(index: Int32) -> Void {
    let comparisionItemData: wref<gameItemData>;
    let comparisonItemID: ItemID;
    let currentIndex: Int32;
    let currentLootCtrl: wref<LootingListItemController>;
    let equipRecord: wref<EquipmentArea_Record>;
    let equipmentArea: gamedataEquipmentArea;
    let isSelected: Bool;
    let itemData: wref<gameItemData>;
    let itemRecord: wref<Item_Record>;
    let lootingData: ref<MinimalLootingListItemData>;
    let lootListWidget: wref<inkWidget> = this.m_lootList[index];
    if !IsDefined(lootListWidget) {
      return;
    };
    currentLootCtrl = lootListWidget.GetController() as LootingListItemController;
    if IsDefined(currentLootCtrl) {
      currentIndex = this.m_startIndex + index;
      isSelected = this.m_currendData.isListOpen && currentIndex == this.m_currendData.currentIndex;
      itemData = this.m_dataManager.GetExternalGameItemData(this.m_currendData.ownerId, this.m_currendData.itemIDs[currentIndex]);
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemData.GetID()));
      equipRecord = itemRecord.EquipArea();
      if IsDefined(equipRecord) {
        equipmentArea = equipRecord.Type();
      } else {
        equipmentArea = gamedataEquipmentArea.Invalid;
      };
      comparisonItemID = this.GetItemIDForComparison(itemData, itemRecord, equipmentArea);
      if ItemID.IsValid(comparisonItemID) {
        comparisionItemData = this.m_dataManager.GetPlayerItemData(comparisonItemID);
      };
      lootingData = this.GetMinimalLootingData(itemData, itemRecord, equipmentArea, comparisionItemData);
      currentLootCtrl.SetData(lootingData, isSelected);
      if isSelected {
        this.m_currentTooltipItemId = this.m_currendData.itemIDs[currentIndex];
        this.m_currentTooltipLootingData = new TooltipLootingCachedData();
        this.m_currentTooltipLootingData.externalItemData = itemData;
        this.m_currentTooltipLootingData.itemRecord = itemRecord;
        this.m_currentTooltipLootingData.comparisonItemData = comparisionItemData;
        this.m_currentTooltipLootingData.comparisonItemId = comparisonItemID;
        this.m_currentTooltipLootingData.lootingData = lootingData;
        this.RefreshTooltips();
      };
    };
  }

  private final func GetMinimalLootingData(itemData: wref<gameItemData>, itemRecord: wref<Item_Record>, equipmentArea: gamedataEquipmentArea, comparisionItemData: wref<gameItemData>) -> ref<MinimalLootingListItemData> {
    let comparisionArmor: Float;
    let comparisionDPS: Float;
    let localArmor: Float;
    let localDPS: Float;
    let shardData: wref<JournalOnscreen>;
    let lootingData: ref<MinimalLootingListItemData> = new MinimalLootingListItemData();
    lootingData.gameItemData = itemData;
    lootingData.lootItemType = LootItemType.Default;
    if IsDefined(itemRecord) {
      shardData = this.GetShardData(itemRecord);
      if IsDefined(shardData) {
        lootingData.lootItemType = LootItemType.Shard;
      } else {
        if itemRecord.TagsContains(n"Quest") {
          lootingData.lootItemType = LootItemType.Quest;
        };
      };
    };
    lootingData.itemName = IsDefined(shardData) ? GetLocalizedText(shardData.GetTitle()) : UIItemsHelper.GetItemName(itemRecord, itemData);
    lootingData.itemType = itemData.GetItemType();
    lootingData.quality = RPGManager.GetItemDataQuality(itemData);
    lootingData.isIconic = RPGManager.IsItemIconic(itemData);
    lootingData.quantity = itemData.GetQuantity();
    lootingData.equipmentArea = equipmentArea;
    if IsDefined(comparisionItemData) {
      localDPS = itemData.GetStatValueByType(gamedataStatType.EffectiveDPS);
      comparisionDPS = comparisionItemData.GetStatValueByType(gamedataStatType.EffectiveDPS);
      lootingData.dpsDiff = localDPS - comparisionDPS;
      localArmor = itemData.GetStatValueByType(gamedataStatType.Armor);
      comparisionArmor = comparisionItemData.GetStatValueByType(gamedataStatType.Armor);
      lootingData.armorDiff = localArmor - comparisionArmor;
    };
    return lootingData;
  }

  public final func SetLootData(data: LootData) -> Void {
    let lastIndex: Int32;
    let totalItems: Int32;
    let visibleItems: Int32;
    this.m_currendData = data;
    if this.bufferedOwnerId != data.ownerId {
      if IsDefined(this.introAnimProxy) {
        this.introAnimProxy.Stop();
      };
      this.introAnimProxy = this.PlayLibraryAnimation(n"looting_list_intro");
    };
    this.bufferedOwnerId = data.ownerId;
    totalItems = ArraySize(data.itemIDs);
    visibleItems = Min(this.m_maxItemsNum, totalItems);
    this.RefreshChoicesPool(data.choices);
    this.RefreshItemsData(data, visibleItems, totalItems, lastIndex);
    this.RefreshItemsPool(totalItems, visibleItems);
    if totalItems == 0 {
      this.m_cachedTooltipData = null;
    };
    if totalItems == 1 {
      inkWidgetRef.SetVisible(this.m_upArrow, false);
      inkWidgetRef.SetVisible(this.m_downArrow, false);
    } else {
      if data.currentIndex > 0 && data.currentIndex < lastIndex {
        inkWidgetRef.SetVisible(this.m_upArrow, true);
        inkWidgetRef.SetVisible(this.m_downArrow, true);
      } else {
        if data.currentIndex > 0 {
          inkWidgetRef.SetVisible(this.m_upArrow, true);
          inkWidgetRef.SetVisible(this.m_downArrow, false);
        } else {
          inkWidgetRef.SetVisible(this.m_upArrow, false);
          inkWidgetRef.SetVisible(this.m_downArrow, true);
        };
      };
    };
    inkWidgetRef.SetVisible(this.m_titleContainer, totalItems > 0);
    this.m_lastListOpenedState = data.isListOpen;
    this.m_currentItemOwnerId = data.ownerId;
    this.RefreshTooltips();
  }

  public final func GetCurrentItemOwnerId() -> EntityID {
    return this.m_currentItemOwnerId;
  }

  public final func IsTooltipVisible() -> Bool {
    return this.m_tooltipProvider.IsVisible();
  }

  public final func GetTooltipOwner(index: Int32) -> EntityID {
    return this.m_tooltipProvider.GetIdentifiedTooltipOwner(index);
  }

  public final func UpdateEquipmentArea(equipmentArea: gamedataEquipmentArea) -> Void {
    let comparisonItemID: ItemID;
    if Equals(this.m_currentComparisonEquipmentArea, equipmentArea) {
      this.m_isComaprisonDirty = true;
      comparisonItemID = this.GetItemIDForComparison(this.m_currentTooltipLootingData.externalItemData, this.m_currentTooltipLootingData.itemRecord, equipmentArea);
      if ItemID.IsValid(comparisonItemID) {
        this.m_currentTooltipLootingData.comparisonItemId = comparisonItemID;
        this.m_currentTooltipLootingData.comparisonItemData = this.m_dataManager.GetPlayerItemData(comparisonItemID);
      };
      this.RefreshTooltips();
    };
  }

  private final func GetShardData(itemTDBID: TweakDBID) -> wref<JournalOnscreen> {
    if !GameInstance.IsValid(this.m_gameInstance) {
      return null;
    };
    return this.GetShardData(TweakDBInterface.GetItemRecord(itemTDBID));
  }

  private final func GetShardData(itemRecord: wref<Item_Record>) -> wref<JournalOnscreen> {
    let isShard: Bool;
    let journalPath: String;
    if !IsDefined(itemRecord) {
      return null;
    };
    isShard = itemRecord.TagsContains(n"Shard");
    if isShard {
      journalPath = TweakDBInterface.GetString(itemRecord.ItemSecondaryAction().GetID() + t".journalEntry", "");
      return GameInstance.GetJournalManager(this.m_gameInstance).GetEntryByString(journalPath, "gameJournalOnscreen") as JournalOnscreen;
    };
    return null;
  }

  private final func FilterOutEmptyItems(items: array<InventoryItemData>) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if !InventoryItemData.IsEmpty(items[i]) {
        ArrayPush(result, items[i]);
      };
      i += 1;
    };
    return result;
  }

  private final func FilterComparableItems(itemToCompare: ItemID, items: array<InventoryItemData>) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if this.m_dataManager.CanCompareItems(itemToCompare, InventoryItemData.GetID(items[i])) {
        ArrayPush(result, items[i]);
      };
      i += 1;
    };
    return result;
  }

  private final func GetPrefferedComparisonItem(item: InventoryItemData) -> InventoryItemData {
    let inventoryItems: array<InventoryItemData> = this.FilterOutEmptyItems(this.m_dataManager.GetItemsToCompare(item));
    let comparableItems: array<InventoryItemData> = this.FilterComparableItems(InventoryItemData.GetID(item), inventoryItems);
    let prefferedItemIndex: Int32 = this.m_dataManager.GetPrefferedEquipedItemToCompare(item, comparableItems);
    return comparableItems[prefferedItemIndex];
  }

  private final func GetCurrentlyEquippedComparisonItem(equipmentArea: gamedataEquipmentArea) -> InventoryItemData {
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
      return this.m_activeWeapon;
    };
    return this.m_dataManager.GetItemToCompare(equipmentArea);
  }

  private final func GetCurrentlyEquippedComparisonItemID(equipmentArea: gamedataEquipmentArea) -> ItemID {
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
      return InventoryItemData.GetID(this.m_activeWeapon);
    };
    return this.m_dataManager.GetItemIDToCompare(equipmentArea);
  }

  private final func GetComparisonTooltipData(inspectedItem: InventoryItemData, itemToCompareWith: InventoryItemData) -> ref<InventoryTooltipData> {
    let inspectedTooltip: ref<InventoryTooltipData> = this.m_dataManager.GetComparisonTooltipsData(itemToCompareWith, inspectedItem);
    inspectedTooltip.ToCollapsedVersion();
    return inspectedTooltip;
  }

  private final func GetPrefferedComparisonTooltipData(item: InventoryItemData) -> ref<InventoryTooltipData> {
    return this.GetComparisonTooltipData(item, this.GetPrefferedComparisonItem(item));
  }

  private final func GetCurrentlyUsedComparisonTooltipData(item: InventoryItemData) -> ref<InventoryTooltipData> {
    return this.GetComparisonTooltipData(item, this.GetCurrentlyEquippedComparisonItem(InventoryItemData.GetEquipmentArea(item)));
  }

  public final func GetItemForComparison(inspectedItem: InventoryItemData) -> InventoryItemData {
    let equippedItem: InventoryItemData = this.GetCurrentlyEquippedComparisonItem(InventoryItemData.GetEquipmentArea(inspectedItem));
    if this.m_dataManager.CanCompareItems(InventoryItemData.GetID(inspectedItem), InventoryItemData.GetID(equippedItem)) {
      return equippedItem;
    };
    return this.m_dataManager.GetPrefferedComparisonItem(inspectedItem, this.m_dataManager.GetComparisonItems(inspectedItem));
  }

  public final func GetItemIDForComparison(item: wref<gameItemData>, itemRecord: wref<Item_Record>, equipmentArea: gamedataEquipmentArea) -> ItemID {
    let itemID: ItemID = item.GetID();
    let equippedItem: ItemID = this.GetCurrentlyEquippedComparisonItemID(equipmentArea);
    if this.m_dataManager.CanCompareItems(itemID, equippedItem) {
      return equippedItem;
    };
    return this.m_dataManager.GetPrefferedComparisonItemID(item, itemRecord, equipmentArea, this.m_dataManager.GetComparisonItemsIDs(itemID, equipmentArea));
  }

  public final func GetPureItemForComparison(inspectedItem: InventoryItemData) -> InventoryItemData {
    let itemData: InventoryItemData = this.GetItemForComparison(inspectedItem);
    if InventoryItemData.IsEmpty(itemData) {
      return itemData;
    };
    return this.m_dataManager.GetItemDataFromIDInLoadout(InventoryItemData.GetID(itemData));
  }

  public final func GetPureItemForComparison(item: wref<gameItemData>, itemRecord: wref<Item_Record>, equipmentArea: gamedataEquipmentArea) -> InventoryItemData {
    let itemData: InventoryItemData;
    let comparisonItemID: ItemID = this.GetItemIDForComparison(item, itemRecord, equipmentArea);
    if !ItemID.IsValid(comparisonItemID) {
      return itemData;
    };
    return this.m_dataManager.GetItemDataFromIDInLoadout(comparisonItemID);
  }

  private final func RefreshTooltips() -> Void {
    let equippedItem: InventoryItemData;
    let identifiedTooltipData: ref<IdentifiedWrappedTooltipData>;
    let inspectedTooltip: ref<InventoryTooltipData>;
    let isCyberdeck: Bool;
    let isPart: Bool;
    let shardData: wref<JournalOnscreen>;
    if this.m_isLocked {
      this.m_tooltipProvider.ClearTooltipData();
      return;
    };
    if !this.m_isComaprisonDirty {
      this.m_isComaprisonDirty = this.m_currentTooltipLootingData.comparisonItemId != this.m_currentComparisonItemId;
    };
    if this.m_lastTooltipItemId != this.m_currentTooltipItemId || this.m_lastItemOwnerId != this.m_currentItemOwnerId || this.m_isComaprisonDirty {
      this.m_tooltipProvider.ClearTooltipData();
      if ItemID.IsValid(this.m_currentTooltipItemId) {
        if IsDefined(this.m_currentTooltipLootingData.externalItemData) {
          isPart = Equals(this.m_currentTooltipLootingData.lootingData.itemType, gamedataItemType.Prt_Program);
          isCyberdeck = Equals(this.m_currentTooltipLootingData.lootingData.equipmentArea, gamedataEquipmentArea.SystemReplacementCW);
          if !isPart && !isCyberdeck {
            identifiedTooltipData = new IdentifiedWrappedTooltipData();
            identifiedTooltipData.m_identifier = n"itemTooltip";
            identifiedTooltipData.m_tooltipOwner = this.m_currentItemOwnerId;
            identifiedTooltipData.m_data = this.GetTooltipMinimalData(this.m_dataManager.GetExternalGameObject(this.m_currentItemOwnerId));
            this.m_lastTooltipItemId = this.m_currentTooltipItemId;
            this.m_lastItemOwnerId = this.m_currentItemOwnerId;
            this.m_isComaprisonDirty = false;
            this.m_currentComparisonEquipmentArea = this.m_currentTooltipLootingData.lootingData.equipmentArea;
            this.m_cachedTooltipData = identifiedTooltipData;
            this.m_tooltipProvider.PushData(identifiedTooltipData);
          } else {
            equippedItem = this.GetPureItemForComparison(this.m_currentTooltipLootingData.externalItemData, this.m_currentTooltipLootingData.itemRecord, this.m_currentTooltipLootingData.lootingData.equipmentArea);
            inspectedTooltip = this.m_dataManager.GetComparisonTooltipsData(equippedItem, this.m_dataManager.GetExternalItemData(this.m_currentItemOwnerId, this.m_currentTooltipLootingData.externalItemData, true));
            inspectedTooltip.ToCollapsedVersion();
            shardData = this.GetShardData(ItemID.GetTDBID(inspectedTooltip.itemID));
            if IsDefined(shardData) {
              inspectedTooltip.itemName = shardData.GetTitle();
            };
            inspectedTooltip.showIcon = true;
            inspectedTooltip.displayContext = InventoryTooltipDisplayContext.HUD;
            identifiedTooltipData = new IdentifiedWrappedTooltipData();
            if isPart {
              identifiedTooltipData.m_identifier = n"programTooltip";
            } else {
              if isCyberdeck {
                identifiedTooltipData.m_identifier = n"cyberdeckTooltip";
              };
            };
            identifiedTooltipData.m_tooltipOwner = this.m_currentItemOwnerId;
            identifiedTooltipData.m_data = inspectedTooltip;
            this.m_lastTooltipItemId = this.m_currentTooltipItemId;
            this.m_cachedTooltipData = identifiedTooltipData;
            this.m_tooltipProvider.PushData(identifiedTooltipData);
          };
        } else {
          this.m_cachedTooltipData = null;
        };
      } else {
        this.m_cachedTooltipData = null;
      };
    } else {
      if !this.m_tooltipProvider.HasAnyTooltipData() && this.m_cachedTooltipData != null {
        this.m_tooltipProvider.PushData(this.m_cachedTooltipData);
      } else {
        if this.m_cachedTooltipData == null {
          this.m_tooltipProvider.ClearTooltipData();
        };
      };
    };
    this.m_tooltipProvider.RefreshTooltips();
  }

  private final func GetTooltipMinimalData(lootingOwner: wref<GameObject>) -> ref<MinimalItemTooltipData> {
    let emptySlots: array<TweakDBID>;
    let transactionSystem: ref<TransactionSystem>;
    let usedSlots: array<TweakDBID>;
    let data: ref<MinimalItemTooltipData> = new MinimalItemTooltipData();
    let hasComparisionItem: Bool = this.m_currentTooltipLootingData.comparisonItemData != null;
    data.itemData = this.m_currentTooltipLootingData.externalItemData;
    data.itemID = data.itemData.GetID();
    data.itemTweakID = ItemID.GetTDBID(data.itemID);
    data.itemCategory = this.m_currentTooltipLootingData.itemRecord.ItemCategory().Type();
    data.itemType = this.m_currentTooltipLootingData.lootingData.itemType;
    data.equipmentArea = this.m_currentTooltipLootingData.lootingData.equipmentArea;
    if Equals(data.equipmentArea, gamedataEquipmentArea.Weapon) {
      data.itemEvolution = RPGManager.GetWeaponEvolution(data.itemID);
    };
    data.itemName = UIItemsHelper.GetTooltipItemName(data.itemTweakID, data.itemData, this.m_currentTooltipLootingData.lootingData.itemName);
    data.isIconic = RPGManager.IsItemIconic(data.itemData);
    data.isCrafted = RPGManager.IsItemCrafted(data.itemData);
    data.quality = this.m_currentTooltipLootingData.lootingData.quality;
    data.useMaleIcon = Equals(this.m_dataManager.GetIconGender(), ItemIconGender.Male);
    data.iconPath = this.m_currentTooltipLootingData.itemRecord.IconPath();
    transactionSystem = this.m_dataManager.GetTransactionSystem();
    transactionSystem.GetEmptySlotsOnItem(lootingOwner, data.itemID, emptySlots);
    transactionSystem.GetUsedSlotsOnItem(lootingOwner, data.itemID, usedSlots);
    if Equals(data.equipmentArea, gamedataEquipmentArea.Weapon) || Equals(data.equipmentArea, gamedataEquipmentArea.WeaponHeavy) {
      data.dpsValue = data.itemData.GetStatValueByType(gamedataStatType.EffectiveDPS);
      if hasComparisionItem {
        data.dpsDiff = data.dpsValue - this.m_currentTooltipLootingData.comparisonItemData.GetStatValueByType(gamedataStatType.EffectiveDPS);
      };
      data.ammoCount = this.m_dataManager.GetPlayerAmmoCount(this.m_currentTooltipLootingData.itemRecord);
      data.isSilencerInstalled = ArrayContains(usedSlots, t"AttachmentSlots.PowerModule");
      data.isScopeInstalled = ArrayContains(usedSlots, t"AttachmentSlots.Scope");
      if data.isSilencerInstalled {
        data.hasSilencer = true;
      } else {
        data.hasSilencer = ArrayContains(emptySlots, t"AttachmentSlots.PowerModule");
      };
      if data.isScopeInstalled {
        data.hasScope = true;
      } else {
        data.hasScope = ArrayContains(emptySlots, t"AttachmentSlots.Scope");
      };
    } else {
      data.stats = MinimalItemTooltipData.GetSecondaryStatsForStatMap(data.itemData, data.itemType, data.itemCategory);
    };
    if Equals(data.itemCategory, gamedataItemCategory.Clothing) {
      data.armorValue = data.itemData.GetStatValueByType(gamedataStatType.Armor);
      if hasComparisionItem {
        data.armorDiff = data.armorValue - this.m_currentTooltipLootingData.comparisonItemData.GetStatValueByType(gamedataStatType.Armor);
        if AbsF(data.armorDiff) < 0.10 {
          data.armorDiff = 0.00;
        };
      };
    } else {
      if Equals(data.itemType, gamedataItemType.Gad_Grenade) {
        data.grenadeData = this.m_dataManager.GetGrenadeTooltipData(data.itemTweakID, data.itemData);
      };
    };
    MinimalItemTooltipData.GetModsDataPackages(data.itemData, this.m_currentTooltipLootingData.itemRecord, InventoryTooltipDisplayContext.HUD, data.mods);
    if !this.m_currentTooltipLootingData.itemRecord.IsPart() {
      this.m_dataManager.GetAttachements(lootingOwner, data.itemData, usedSlots, emptySlots, data.mods, data.dedicatedMods);
    };
    data.displayContext = InventoryTooltipDisplayContext.HUD;
    data.description = this.m_currentTooltipLootingData.itemRecord.LocalizedDescription();
    data.weight = data.itemData.GetStatValueByType(gamedataStatType.Weight);
    data.price = this.m_dataManager.GetSellPrice(lootingOwner, data.itemData);
    data.requirements = MinimalItemTooltipData.GetMinimalTooltipDataRequirements(data.itemData, this.m_dataManager);
    return data;
  }

  public final func SetDialogOpen(isDialogOpen: Bool) -> Void {
    let currWidget: wref<inkCompoundWidget>;
    let i: Int32;
    this.GetRootWidget().SetOpacity(isDialogOpen ? 0.00 : 1.00);
    i = 0;
    while i < ArraySize(this.m_widgetsPoolList) {
      currWidget = this.m_widgetsPoolList[i] as inkCompoundWidget;
      currWidget.GetWidget(n"inputDisplay").SetVisible(!isDialogOpen);
      i += 1;
    };
  }
}

public class LootingItemController extends inkLogicController {

  private let m_itemNameText: wref<inkText>;

  private let m_isCurrentlySelected: Bool;

  protected edit let m_itemName: inkTextRef;

  protected edit let m_itemType: inkTextRef;

  protected edit let m_itemWeight: inkTextRef;

  protected edit let m_itemQuantity: inkTextRef;

  protected edit let m_itemQualityBar: inkWidgetRef;

  protected edit let m_itemSelection: inkWidgetRef;

  protected edit let m_itemIcon: inkImageRef;

  public final func SetIcon(itemData: InventoryItemData) -> Void {
    let iconName: CName;
    if InventoryItemData.IsEmpty(itemData) {
      return;
    };
    iconName = StringToName(InventoryItemData.GetIconPath(itemData));
    if !(!IsStringValid(InventoryItemData.GetIconPath(itemData)) || !inkImageRef.IsTexturePartExist(this.m_itemIcon, iconName)) {
      inkImageRef.SetTexturePart(this.m_itemIcon, StringToName(InventoryItemData.GetIconPath(itemData)));
    };
  }

  public final func SetData(itemData: ItemViewData, isCurrentlySelected: Bool) -> Void {
    this.m_isCurrentlySelected = isCurrentlySelected;
    inkTextRef.SetText(this.m_itemName, itemData.itemName);
    inkWidgetRef.SetState(this.m_itemName, StringToName(itemData.quality));
    inkWidgetRef.SetState(this.m_itemQualityBar, StringToName(itemData.quality));
    inkTextRef.SetText(this.m_itemType, itemData.categoryName);
    inkTextRef.SetText(this.m_itemWeight, "");
    inkTextRef.SetText(this.m_itemQuantity, "");
    this.PlayLibraryAnimation(n"intro");
    if isCurrentlySelected {
      inkWidgetRef.SetVisible(this.m_itemSelection, true);
      inkWidgetRef.SetVisible(this.m_itemQualityBar, true);
      this.PlayLibraryAnimation(n"select");
    } else {
      inkWidgetRef.SetVisible(this.m_itemSelection, false);
      inkWidgetRef.SetVisible(this.m_itemQualityBar, false);
    };
  }

  public final func SetText(text: String) -> Void {
    inkTextRef.SetText(this.m_itemName, text);
    inkWidgetRef.SetTintColor(this.m_itemName, new Color(235u, 42u, 65u, 255u));
  }
}
