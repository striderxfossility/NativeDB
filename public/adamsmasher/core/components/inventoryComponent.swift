
public native class InventoryScriptCallback extends IScriptable {

  public native let itemID: ItemID;

  public func OnItemNotification(item: ItemID, itemData: wref<gameItemData>) -> Void;

  public func OnItemAdded(item: ItemID, itemData: wref<gameItemData>, flaggedAsSilent: Bool) -> Void;

  public func OnItemRemoved(item: ItemID, difference: Int32, currentQuantity: Int32) -> Void;

  public func OnItemQuantityChanged(item: ItemID, diff: Int32, total: Uint32, flaggedAsSilent: Bool) -> Void;

  public func OnItemExtracted(item: ItemID) -> Void;

  public func OnPartAdded(item: ItemID, partID: ItemID) -> Void;

  public func OnPartRemoved(partID: ItemID, formerItemID: ItemID) -> Void;
}

public final native class Inventory extends GameComponent {

  public final native func IsAccessible() -> Bool;

  public final native func ReinitializeStatsOnAllItems() -> Bool;

  public final func IsChoiceAvailable(itemActionRecord: ref<ItemAction_Record>, requester: ref<GameObject>, ownerEntID: EntityID, itemID: ItemID) -> gameinteractionsELootChoiceType {
    let emptyContext: GetActionsContext;
    let itemData: wref<gameItemData> = RPGManager.GetItemData(requester.GetGame(), this.GetEntity() as GameObject, itemID);
    let action: ref<BaseItemAction> = ItemActionsHelper.SetupItemAction(requester.GetGame(), requester, itemData, itemActionRecord.GetID(), false);
    if action.IsVisible(emptyContext) {
      return gameinteractionsELootChoiceType.Available;
    };
    return gameinteractionsELootChoiceType.Invisible;
  }

  protected final cb func OnLootAllEvent(evt: ref<OnLootAllEvent>) -> Bool {
    let gameObject: ref<GameObject> = this.GetEntity() as GameObject;
    GameInstance.GetAudioSystem(gameObject.GetGame()).PlayLootAllSound();
  }

  protected final cb func OnInteractionUsed(evt: ref<InteractionChoiceEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let gameObject: ref<GameObject> = this.GetEntity() as GameObject;
    let lootActionWrapper: LootChoiceActionWrapper = LootChoiceActionWrapper.Unwrap(evt);
    if LootChoiceActionWrapper.IsValid(lootActionWrapper) {
      if (evt.activator as PlayerPuppet).IsInCombat() && IsDefined(TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(lootActionWrapper.itemId))) {
        return false;
      };
      if LootChoiceActionWrapper.IsIllegal(lootActionWrapper) {
        broadcaster = evt.activator.GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          broadcaster.TriggerSingleBroadcast(gameObject, gamedataStimType.IllegalInteraction);
        };
      };
      if RPGManager.ConsumeItem(gameObject, evt) {
        GameInstance.GetAudioSystem(gameObject.GetGame()).PlayItemActionSound(lootActionWrapper.action, RPGManager.GetItemData(gameObject.GetGame(), gameObject, lootActionWrapper.itemId));
        return false;
      };
      if Equals(lootActionWrapper.action, n"Learn") {
        ItemActionsHelper.LearnItem(evt.activator, lootActionWrapper.itemId, false);
      };
      if Equals(LootChoiceActionWrapper.IsHandledByCode(lootActionWrapper), false) {
        GameInstance.GetTransactionSystem(gameObject.GetGame()).RemoveItem(gameObject, lootActionWrapper.itemId, 1);
      };
      GameInstance.GetAudioSystem(gameObject.GetGame()).PlayItemActionSound(lootActionWrapper.action, RPGManager.GetItemData(gameObject.GetGame(), gameObject, lootActionWrapper.itemId));
    };
  }
}

public native class gameLootObject extends GameObject {

  protected let m_isInIconForcedVisibilityRange: Bool;

  protected let m_activeQualityRangeInteraction: CName;

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    if Equals(evt.layerData.tag, n"auto") {
      GameObject.PlaySoundEvent(evt.activator, n"ui_loot_ammo");
    };
  }

  protected final func IsQualityRangeInteractionLayer(layerTag: CName) -> Bool {
    return Equals(layerTag, n"QualityRange_Short") || Equals(layerTag, n"QualityRange_Medium") || Equals(layerTag, n"QualityRange_Max");
  }

  protected final func SetQualityRangeInteractionLayerState(enable: Bool) -> Void {
    let evt: ref<InteractionSetEnableEvent>;
    if IsNameValid(this.m_activeQualityRangeInteraction) {
      evt = new InteractionSetEnableEvent();
      evt.enable = enable;
      evt.layer = this.m_activeQualityRangeInteraction;
      this.QueueEvent(evt);
    };
  }

  protected final func ResolveQualityRangeInteractionLayer(opt itemData: wref<gameItemData>) -> Void {
    let currentLayer: CName;
    let isQuest: Bool;
    let lootQuality: gamedataQuality;
    if IsNameValid(this.m_activeQualityRangeInteraction) {
      this.SetQualityRangeInteractionLayerState(false);
    };
    if itemData == null {
      return;
    };
    lootQuality = RPGManager.GetItemDataQuality(itemData);
    isQuest = itemData.HasTag(n"Quest");
    if NotEquals(lootQuality, gamedataQuality.Invalid) && NotEquals(lootQuality, gamedataQuality.Random) {
      if isQuest {
        currentLayer = n"QualityRange_Max";
      } else {
        if Equals(lootQuality, gamedataQuality.Common) {
          currentLayer = n"QualityRange_Short";
        } else {
          if Equals(lootQuality, gamedataQuality.Uncommon) {
            currentLayer = n"QualityRange_Medium";
          } else {
            if Equals(lootQuality, gamedataQuality.Rare) {
              currentLayer = n"QualityRange_Medium";
            } else {
              if Equals(lootQuality, gamedataQuality.Epic) {
                currentLayer = n"QualityRange_Max";
              } else {
                if Equals(lootQuality, gamedataQuality.Legendary) {
                  currentLayer = n"QualityRange_Max";
                } else {
                  if Equals(lootQuality, gamedataQuality.Iconic) {
                    currentLayer = n"QualityRange_Max";
                  };
                };
              };
            };
          };
        };
      };
    } else {
      currentLayer = n"";
    };
    this.m_activeQualityRangeInteraction = currentLayer;
    this.SetQualityRangeInteractionLayerState(true);
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Collider", n"entColliderComponent", false);
  }

  public const func IsInIconForcedVisibilityRange() -> Bool {
    return this.m_isInIconForcedVisibilityRange;
  }
}

public final native class gameItemDropObject extends gameLootObject {

  protected let m_wasItemInitialized: Bool;

  public final native const func GetItemEntityID() -> EntityID;

  public final native const func GetItemObject() -> wref<ItemObject>;

  protected final func OnItemEntitySpawned(entID: EntityID) -> Void {
    this.SetQualityRangeInteractionLayerState(true);
    this.EvaluateLootQualityEvent(entID);
    this.RequestHUDRefresh();
  }

  protected final cb func OnGameAttached() -> Bool;

  protected final cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    let actorUpdateData: ref<HUDActorUpdateData>;
    super.OnInteractionActivated(evt);
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      if evt.activator.IsPlayer() {
        if this.IsQualityRangeInteractionLayer(evt.layerData.tag) {
          this.m_isInIconForcedVisibilityRange = true;
          actorUpdateData = new HUDActorUpdateData();
          actorUpdateData.updateIsInIconForcedVisibilityRange = true;
          actorUpdateData.isInIconForcedVisibilityRangeValue = true;
          this.RequestHUDRefresh(actorUpdateData);
        };
      };
    } else {
      if this.IsQualityRangeInteractionLayer(evt.layerData.tag) && evt.activator.IsPlayer() {
        this.m_isInIconForcedVisibilityRange = false;
        actorUpdateData = new HUDActorUpdateData();
        actorUpdateData.updateIsInIconForcedVisibilityRange = true;
        actorUpdateData.isInIconForcedVisibilityRangeValue = false;
        this.RequestHUDRefresh(actorUpdateData);
      };
    };
  }

  public final const func IsEmpty() -> Bool {
    return !EntityID.IsDefined(this.GetItemEntityID());
  }

  public final const func ShouldRegisterToHUD() -> Bool {
    return true;
  }

  protected final cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    if this.m_wasItemInitialized || !this.IsEmpty() {
      this.QueueEventForEntityID(this.GetItemEntityID(), evt);
    };
  }

  protected final cb func OnItemRemovedEvent(evt: ref<ItemBeingRemovedEvent>) -> Bool {
    let evtToSend: ref<ItemLootedEvent>;
    this.RegisterToHUDManagerByTask(false);
    if !this.IsEmpty() {
      evtToSend = new ItemLootedEvent();
      this.QueueEventForEntityID(this.GetItemEntityID(), evtToSend);
    };
    this.SetQualityRangeInteractionLayerState(false);
  }

  protected final cb func OnItemAddedEvent(evt: ref<ItemAddedEvent>) -> Bool {
    this.m_wasItemInitialized = true;
    let itemData: wref<gameItemData> = GameInstance.GetTransactionSystem(this.GetGame()).GetItemData(this, evt.itemID);
    this.ResolveQualityRangeInteractionLayer(itemData);
  }

  private final func EvaluateLootQualityEvent(target: EntityID) -> Void {
    let evt: ref<EvaluateLootQualityEvent>;
    if EntityID.IsDefined(target) {
      evt = new EvaluateLootQualityEvent();
      GameInstance.GetPersistencySystem(this.GetGame()).QueueEntityEvent(target, evt);
    };
  }
}
