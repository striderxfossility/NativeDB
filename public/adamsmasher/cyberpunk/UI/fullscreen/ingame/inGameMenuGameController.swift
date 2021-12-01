
public class SetZoomLevelEvent extends Event {

  public let m_value: Int32;

  public final func SetZoom(zoomValue: Int32) -> Void {
    this.m_value = zoomValue;
  }
}

public native class gameuiInGameMenuGameController extends gameuiBaseMenuGameController {

  private let m_quickSaveInProgress: Bool;

  private let m_showDeathScreenBBID: ref<CallbackHandle>;

  private let m_breachingNetworkBBID: ref<CallbackHandle>;

  private let m_triggerMenuEventBBID: ref<CallbackHandle>;

  private let m_openStorageBBID: ref<CallbackHandle>;

  private let m_bbOnEquipmentChangedID: ref<CallbackHandle>;

  private let m_inventoryListener: ref<AttachmentSlotsScriptListener>;

  private final native func RegisterItemSwitch(sceneName: CName, itemId: ItemID) -> Void;

  protected cb func OnInitialize() -> Bool {
    this.RegisterGlobalBlackboards();
    this.GetSystemRequestsHandler().RegisterToCallback(n"OnSavingComplete", this, n"OnSavingComplete");
  }

  protected cb func OnDelayedRegisterToGlobalInputCallbackEvent(evt: ref<DelayedRegisterToGlobalInputCallbackEvent>) -> Bool {
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleMenuInput");
  }

  protected cb func OnUninitialize() -> Bool {
    this.GetSystemRequestsHandler().UnregisterFromCallback(n"OnSavingComplete", this, n"OnSavingComplete");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleMenuInput");
    this.UnregisterGlobalBlackboards();
  }

  private final func RegisterGlobalBlackboards() -> Void {
    let m_menuEventBlackboard: ref<IBlackboard>;
    let m_networkBlackboard: ref<IBlackboard>;
    let m_storageBlackboard: ref<IBlackboard>;
    let m_equipmentBlackboard: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Equipment);
    if IsDefined(m_equipmentBlackboard) {
      this.m_bbOnEquipmentChangedID = m_equipmentBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_Equipment.lastModifiedArea, this, n"OnEquipmentChanged");
    };
    m_networkBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().NetworkBlackboard);
    if IsDefined(m_networkBlackboard) {
      this.m_breachingNetworkBBID = m_networkBlackboard.RegisterDelayedListenerString(GetAllBlackboardDefs().NetworkBlackboard.NetworkName, this, n"OnBreachingNetwork");
    };
    m_menuEventBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().MenuEventBlackboard);
    if IsDefined(m_menuEventBlackboard) {
      this.m_triggerMenuEventBBID = m_menuEventBlackboard.RegisterDelayedListenerName(GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger, this, n"OnTriggerMenuEvent");
    };
    m_storageBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().StorageBlackboard);
    if IsDefined(m_storageBlackboard) {
      this.m_openStorageBBID = m_storageBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().StorageBlackboard.StorageData, this, n"OnOpenStorage");
    };
  }

  private final func UnregisterGlobalBlackboards() -> Void {
    let m_menuEventBlackboard: ref<IBlackboard>;
    let m_networkBlackboard: ref<IBlackboard>;
    let m_storageBlackboard: ref<IBlackboard>;
    let m_equipmentBlackboard: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Equipment);
    if IsDefined(m_equipmentBlackboard) {
      m_equipmentBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_Equipment.lastModifiedArea, this.m_bbOnEquipmentChangedID);
    };
    m_networkBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().NetworkBlackboard);
    if IsDefined(m_networkBlackboard) {
      m_networkBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().NetworkBlackboard.NetworkName, this.m_breachingNetworkBBID);
    };
    m_menuEventBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().MenuEventBlackboard);
    if IsDefined(m_menuEventBlackboard) {
      m_menuEventBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger, this.m_triggerMenuEventBBID);
    };
    m_storageBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().StorageBlackboard);
    if IsDefined(m_storageBlackboard) {
      m_storageBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().StorageBlackboard.StorageData, this.m_openStorageBBID);
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let delayEvt: ref<DelayedRegisterToGlobalInputCallbackEvent>;
    this.RegisterInputListenersForPlayer(playerPuppet);
    this.RegisterPSMListeners(playerPuppet);
    delayEvt = new DelayedRegisterToGlobalInputCallbackEvent();
    this.QueueEvent(delayEvt);
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.UnregisterInputListenersForPlayer(playerPuppet);
    this.UnregisterPSMListeners(playerPuppet);
    this.UnregisterInventoryListener();
  }

  protected final func RegisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let deathBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      deathBlackboard = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(deathBlackboard) {
        this.m_showDeathScreenBBID = deathBlackboard.RegisterListenerBool(playerSMDef.DisplayDeathMenu, this, n"OnDisplayDeathMenu");
      };
    };
  }

  protected final func UnregisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let deathBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      deathBlackboard = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(deathBlackboard) {
        deathBlackboard.UnregisterDelayedListener(playerSMDef.DisplayDeathMenu, this.m_showDeathScreenBBID);
      };
    };
  }

  private final func RegisterInputListenersForPlayer(playerPuppet: ref<GameObject>) -> Void {
    if playerPuppet.IsControlledByLocalPeer() {
      playerPuppet.RegisterInputListener(this, n"OpenPauseMenu");
      playerPuppet.RegisterInputListener(this, n"OpenMapMenu");
      playerPuppet.RegisterInputListener(this, n"OpenCraftingMenu");
      playerPuppet.RegisterInputListener(this, n"OpenJournalMenu");
      playerPuppet.RegisterInputListener(this, n"OpenPerksMenu");
      playerPuppet.RegisterInputListener(this, n"OpenInventoryMenu");
      playerPuppet.RegisterInputListener(this, n"OpenHubMenu");
      playerPuppet.RegisterInputListener(this, n"QuickSave");
      playerPuppet.RegisterInputListener(this, n"QuickLoad");
      playerPuppet.RegisterInputListener(this, n"FastForward_Hold");
    };
  }

  private final func UnregisterInputListenersForPlayer(playerPuppet: ref<GameObject>) -> Void {
    if playerPuppet.IsControlledByLocalPeer() {
      playerPuppet.UnregisterInputListener(this);
    };
  }

  private final func RegisterInventoryListener() -> Void {
    let puppet: ref<gamePuppet> = this.GetPuppet(n"inventory");
    let puppetListener: ref<ItemInPaperdollSlotCallback> = new ItemInPaperdollSlotCallback();
    puppetListener.SetPuppetRef(puppet);
    this.m_inventoryListener = GameInstance.GetTransactionSystem(puppet.GetGame()).RegisterAttachmentSlotListener(puppet, puppetListener);
  }

  private final func UnregisterInventoryListener() -> Void {
    let puppet: ref<gamePuppet> = this.GetPuppet(n"inventory");
    GameInstance.GetTransactionSystem(puppet.GetGame()).UnregisterAttachmentSlotListener(puppet, this.m_inventoryListener);
    this.m_inventoryListener = null;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let isPlayerLastUsedKBM: Bool;
    if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED) {
      if Equals(ListenerAction.GetName(action), n"QuickSave") {
        this.HandleQuickSave();
      };
    };
    if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
      if Equals(ListenerAction.GetName(action), n"OpenPauseMenu") {
        this.SpawnMenuInstanceEvent(n"OnOpenPauseMenu");
      } else {
        if Equals(ListenerAction.GetName(action), n"OpenHubMenu") {
          this.SpawnMenuInstanceEvent(n"OnOpenHubMenu");
        } else {
          if Equals(ListenerAction.GetName(action), n"QuickLoad") {
            this.HandleQuickLoad();
          };
        };
      };
    };
    if Equals(ListenerAction.GetName(action), n"OpenMapMenu") || Equals(ListenerAction.GetName(action), n"OpenCraftingMenu") || Equals(ListenerAction.GetName(action), n"OpenJournalMenu") || Equals(ListenerAction.GetName(action), n"OpenPerksMenu") || Equals(ListenerAction.GetName(action), n"OpenInventoryMenu") {
      isPlayerLastUsedKBM = this.GetPlayerControlledObject().PlayerLastUsedKBM();
      if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_HOLD_COMPLETE) && !isPlayerLastUsedKBM || Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) && isPlayerLastUsedKBM {
        this.OpenShortcutMenu(ListenerAction.GetName(action));
      };
    };
  }

  protected cb func OnHandleMenuInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"back") {
      this.SpawnMenuInstanceEvent(n"OnBack");
    };
    if evt.IsAction(n"toggle_menu") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.SpawnMenuInstanceEvent(n"OnCloseHubMenuRequest");
    };
  }

  protected cb func OnRequestHubMenu(evt: ref<StartHubMenuEvent>) -> Bool {
    this.SpawnMenuInstanceDataEvent(n"OnOpenHubMenu_InitData", evt.m_initData);
  }

  protected cb func OnForceCloseHubMenuEvent(evt: ref<ForceCloseHubMenuEvent>) -> Bool {
    this.SpawnMenuInstanceEvent(n"OnCloseHubMenuRequest");
  }

  protected cb func OnBreachingNetwork(value: String) -> Bool {
    if IsStringValid(value) {
      this.SpawnMenuInstanceEvent(n"OnNetworkBreachBegin");
    } else {
      this.SpawnMenuInstanceEvent(n"OnNetworkBreachEnd");
    };
  }

  protected cb func OnOpenStorage(value: Variant) -> Bool {
    this.SpawnMenuInstanceEvent(n"OnShowStorageMenu");
  }

  protected cb func OnTriggerMenuEvent(value: CName) -> Bool {
    this.SpawnMenuInstanceEvent(value);
  }

  protected cb func OnDisplayDeathMenu(value: Bool) -> Bool {
    let delay: Float;
    let evt: ref<DeathMenuDelayEvent>;
    let playerControlledObject: ref<GameObject>;
    let wasPlayerForceKilled: Bool;
    if !value {
      return false;
    };
    if IsMultiplayer() {
      return false;
    };
    playerControlledObject = this.GetPlayerControlledObject();
    wasPlayerForceKilled = StatusEffectSystem.ObjectHasStatusEffect(playerControlledObject, t"BaseStatusEffect.ForceKill");
    delay = wasPlayerForceKilled ? TweakDBInterface.GetFloat(t"player.deathMenu.delayToDisplayKillTrigger", 3.00) : TweakDBInterface.GetFloat(t"player.deathMenu.delayToDisplay", 3.00);
    evt = new DeathMenuDelayEvent();
    GameInstance.GetDelaySystem(playerControlledObject.GetGame()).DelayEvent(playerControlledObject, evt, delay);
  }

  protected cb func OnDeathScreenDelayEvent(evt: ref<DeathMenuDelayEvent>) -> Bool {
    this.SpawnMenuInstanceEvent(n"OnShowDeathMenu");
  }

  protected cb func OnPuppetReady(sceneName: CName, puppet: ref<gamePuppet>) -> Bool {
    let equipAreas: array<SEquipArea>;
    let equipData: ref<EquipmentSystemPlayerData>;
    let gender: CName;
    let head: ItemID;
    let i: Int32;
    let item: ItemID;
    let itemData: wref<gameItemData>;
    let placementSlot: TweakDBID;
    let transactionSystem: ref<TransactionSystem>;
    this.RegisterInventoryListener();
    transactionSystem = GameInstance.GetTransactionSystem(puppet.GetGame());
    equipData = EquipmentSystem.GetData(GetPlayer(puppet.GetGame()));
    if IsDefined(equipData) {
      equipAreas = equipData.GetPaperDollEquipAreas();
    };
    i = 0;
    while i < ArraySize(equipAreas) {
      item = equipData.GetActiveItem(equipAreas[i].areaType);
      placementSlot = EquipmentSystem.GetPlacementSlot(item);
      if Equals(equipAreas[i].areaType, gamedataEquipmentArea.RightArm) {
        item = ItemID.FromTDBID(ItemID.GetTDBID(equipData.GetActiveItem(equipAreas[i].areaType)));
        transactionSystem.GiveItem(puppet, item, 1);
        transactionSystem.AddItemToSlot(puppet, EquipmentSystem.GetPlacementSlot(item), item);
      } else {
        if !IsDefined(equipData) || !equipData.IsItemHidden(item) {
          itemData = transactionSystem.GetItemData(this.GetPlayerControlledObject(), item);
          transactionSystem.GivePreviewItemByItemData(puppet, itemData);
          if IsDefined(itemData) {
            transactionSystem.AddItemToSlot(puppet, placementSlot, itemData.GetID());
          };
        };
      };
      i += 1;
    };
    gender = puppet.GetResolvedGenderName();
    if Equals(gender, n"Male") {
      head = ItemID.FromTDBID(t"Items.PlayerMaTppHead");
    } else {
      if Equals(gender, n"Female") {
        head = ItemID.FromTDBID(t"Items.PlayerWaTppHead");
      };
    };
    transactionSystem.GiveItem(puppet, head, 1);
    transactionSystem.AddItemToSlot(puppet, EquipmentSystem.GetPlacementSlot(head), head);
  }

  protected cb func OnEquipmentChanged(value: Variant) -> Bool {
    let affectedItemID: ItemID;
    let appearanceReset: Bool;
    let equipData: ref<EquipmentSystemPlayerData>;
    let i: Int32;
    let itemData: wref<gameItemData>;
    let itemObjectToRemove: ref<ItemObject>;
    let itemToRemove: ItemID;
    let oldFistItems: array<wref<gameItemData>>;
    let paperdollData: SPaperdollEquipData;
    let playerItemObject: ref<ItemObject>;
    let transactionSystem: ref<TransactionSystem>;
    let sceneName: CName = n"inventory";
    let puppet: ref<gamePuppet> = this.GetPuppet(sceneName);
    if IsDefined(puppet) {
      transactionSystem = GameInstance.GetTransactionSystem(puppet.GetGame());
      paperdollData = FromVariant(value);
      if Equals(paperdollData.equipArea.areaType, gamedataEquipmentArea.Weapon) && paperdollData.slotIndex != paperdollData.equipArea.activeIndex {
        return false;
      };
      playerItemObject = transactionSystem.GetItemInSlot(GetPlayer(puppet.GetGame()), paperdollData.placementSlot);
      itemObjectToRemove = transactionSystem.GetItemInSlot(puppet, paperdollData.placementSlot);
      if IsDefined(itemObjectToRemove) {
        itemToRemove = itemObjectToRemove.GetItemID();
      };
      equipData = EquipmentSystem.GetData(GetPlayer(puppet.GetGame()));
      affectedItemID = paperdollData.equipArea.equipSlots[paperdollData.equipArea.activeIndex].itemID;
      if transactionSystem.HasTag(GetPlayer(puppet.GetGame()), n"UnequipHolsteredArms", affectedItemID) {
        return false;
      };
      gameuiInGameMenuGameController.SetAnimWrapperBasedOnItemFriendlyName(puppet, affectedItemID, paperdollData.equipped ? 1.00 : 0.00);
      if paperdollData.equipped {
        paperdollData.placementSlot = EquipmentSystem.GetPlacementSlot(affectedItemID);
        itemData = transactionSystem.GetItemData(this.GetPlayerControlledObject(), affectedItemID);
        if Equals(paperdollData.equipArea.areaType, gamedataEquipmentArea.RightArm) {
          transactionSystem.GetItemListByTag(puppet, n"base_fists", oldFistItems);
          i = 0;
          while i < ArraySize(oldFistItems) {
            transactionSystem.RemoveItem(puppet, oldFistItems[i].GetID(), oldFistItems[i].GetQuantity());
            i = i + 1;
          };
          transactionSystem.GiveItem(puppet, affectedItemID, 1);
          if transactionSystem.AddItemToSlot(puppet, paperdollData.placementSlot, affectedItemID) {
            this.RegisterItemSwitch(sceneName, affectedItemID);
          };
        } else {
          if ItemID.IsValid(itemToRemove) {
            if affectedItemID != itemToRemove {
              if transactionSystem.RemoveItemFromSlot(puppet, paperdollData.placementSlot, true) {
                this.RegisterItemSwitch(sceneName, itemToRemove);
              };
              transactionSystem.RemoveItem(puppet, itemToRemove, 1);
            } else {
              transactionSystem.ResetItemAppearance(puppet, itemToRemove);
              appearanceReset = true;
            };
          };
          if !appearanceReset {
            if IsDefined(itemData) {
              transactionSystem.GivePreviewItemByItemData(puppet, itemData);
              if transactionSystem.AddItemToSlot(puppet, paperdollData.placementSlot, itemData.GetID()) {
                this.RegisterItemSwitch(sceneName, itemData.GetID());
              };
            };
          };
        };
      } else {
        if IsDefined(equipData) && equipData.IsItemHidden(affectedItemID) && IsDefined(playerItemObject) {
          transactionSystem.ChangeItemAppearance(puppet, affectedItemID, n"empty_appearance_default", false);
        } else {
          if affectedItemID == ItemID.undefined() || affectedItemID == itemToRemove {
            if transactionSystem.RemoveItemFromSlot(puppet, paperdollData.placementSlot, true) {
              this.RegisterItemSwitch(sceneName, itemToRemove);
            };
            transactionSystem.RemoveItem(puppet, itemToRemove, 1);
          };
        };
        if Equals(paperdollData.equipArea.areaType, gamedataEquipmentArea.OuterChest) && !transactionSystem.IsSlotEmpty(puppet, t"AttachmentSlots.Chest") {
          affectedItemID = transactionSystem.GetItemInSlot(puppet, t"AttachmentSlots.Chest").GetItemID();
          if IsDefined(equipData) && !equipData.IsItemHidden(affectedItemID) {
            transactionSystem.ResetItemAppearance(puppet, affectedItemID);
          };
        };
      };
    };
  }

  public final static func SetAnimWrapperBasedOnItemFriendlyName(puppet: ref<gamePuppet>, itemID: ItemID, value: Float) -> Void {
    let itemRecord: ref<Item_Record>;
    if !IsDefined(puppet) || !ItemID.IsValid(itemID) {
      return;
    };
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    if !IsDefined(itemRecord) {
      return;
    };
    AnimationControllerComponent.SetAnimWrapperWeight(puppet, StringToName(itemRecord.FriendlyName()), value);
  }

  private final func OpenShortcutMenu(actionName: CName) -> Void {
    let initData: ref<HubMenuInitData> = new HubMenuInitData();
    switch actionName {
      case n"OpenMapMenu":
        initData.m_menuName = n"world_map";
        break;
      case n"OpenJournalMenu":
        initData.m_menuName = n"quest_log";
        break;
      case n"OpenPerksMenu":
        initData.m_menuName = n"perks_main";
        break;
      case n"OpenCraftingMenu":
        initData.m_menuName = n"crafting_main";
        break;
      case n"OpenInventoryMenu":
        initData.m_menuName = n"inventory_screen";
    };
    this.SpawnMenuInstanceDataEvent(n"OnOpenHubMenu_InitData", initData);
  }

  protected cb func OnSavingComplete(success: Bool, locks: array<gameSaveLock>) -> Bool {
    if !success && this.m_quickSaveInProgress {
      GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
      GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(UIInGameNotificationEvent.CreateSavingLockedEvent(locks));
    };
    this.m_quickSaveInProgress = false;
  }

  private final func HandleQuickSave() -> Void {
    let locks: array<gameSaveLock>;
    if this.m_quickSaveInProgress {
      return;
    };
    if GameInstance.IsSavingLocked(this.GetPlayerControlledObject().GetGame(), locks) {
      GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
      GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(UIInGameNotificationEvent.CreateSavingLockedEvent(locks));
      return;
    };
    this.GetSystemRequestsHandler().QuickSave();
    this.m_quickSaveInProgress = true;
  }

  protected cb func OnQuickLoadSavesReady(saves: array<String>) -> Bool {
    let savesCount: Int32 = ArraySize(saves);
    if savesCount > 0 {
      GameInstance.GetTelemetrySystem(this.GetPlayerControlledObject().GetGame()).LogLastCheckpointLoaded();
      this.GetSystemRequestsHandler().LoadLastCheckpoint(true);
    };
  }

  private final func HandleQuickLoad() -> Void {
    let handler: wref<inkISystemRequestsHandler> = this.GetSystemRequestsHandler();
    handler.RegisterToCallback(n"OnSavesReady", this, n"OnQuickLoadSavesReady");
    handler.RequestSavesForLoad();
  }
}

public class ItemInPaperdollSlotCallback extends AttachmentSlotsScriptCallback {

  protected let m_paperdollPuppet: wref<gamePuppet>;

  public final func SetPuppetRef(puppet: ref<gamePuppet>) -> Void {
    this.m_paperdollPuppet = puppet;
  }

  public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void {
    let transactionSystem: ref<TransactionSystem>;
    let equipData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(GetPlayer(this.m_paperdollPuppet.GetGame()));
    if IsDefined(equipData) && equipData.IsItemHidden(ItemID.CreateQuery(ItemID.GetTDBID(item))) {
      transactionSystem = GameInstance.GetTransactionSystem(this.m_paperdollPuppet.GetGame());
      transactionSystem.ChangeItemAppearance(this.m_paperdollPuppet, item, n"empty_appearance_default", false);
    };
  }

  public func OnItemUnequipped(slot: TweakDBID, item: ItemID) -> Void;
}
