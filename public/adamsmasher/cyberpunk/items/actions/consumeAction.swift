
public class ConsumeAction extends BaseItemAction {

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let removeConsumableEvent: ref<RemoveConsumableDelayedEvent>;
    let removePoint: Float;
    this.CompleteAction(gameInstance);
    if this.ShouldRemoveAfterUse() {
      this.RemoveConsumableItem(gameInstance);
    } else {
      removePoint = TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(this.GetItemData().GetID())).RemovePoint();
      removeConsumableEvent = new RemoveConsumableDelayedEvent();
      removeConsumableEvent.consumeAction = this;
      GameInstance.GetDelaySystem(gameInstance).DelayEvent(this.GetExecutor(), removeConsumableEvent, removePoint);
    };
    this.NotifyAutocraftSystem(gameInstance);
  }

  public final func RemoveConsumableItem(gameInstance: GameInstance) -> Void {
    let blackboard: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    let eqs: ref<EquipmentSystem>;
    GameInstance.GetTransactionSystem(gameInstance).RemoveItem(this.GetExecutor(), this.GetItemData().GetID(), 1);
    eqs = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"EquipmentSystem") as EquipmentSystem;
    if IsDefined(eqs) {
    };
    if this.ShouldEquipAnotherConsumable() {
      this.TryToEquipSameTypeConsumable();
    };
    blackboardSystem = GameInstance.GetBlackboardSystem(gameInstance);
    blackboard = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.consumableBeingUsed, ToVariant(ItemID.undefined()));
  }

  private final func ShouldEquipAnotherConsumable() -> Bool {
    if this.GetItemData().GetQuantity() > 0 || this.ShouldRemoveAfterUse() {
      return false;
    };
    return true;
  }

  private final func TryToEquipSameTypeConsumable() -> Void {
    let bestQuality: Int32;
    let consumableQuality: Int32;
    let consumableRecord: ref<ConsumableItem_Record>;
    let consumableToEquip: InventoryItemData;
    let consumableType: gamedataConsumableType;
    let currentConsumable: InventoryItemData;
    let i: Int32;
    let inventoryItems: array<InventoryItemData>;
    let inventoryManager: ref<InventoryDataManagerV2> = new InventoryDataManagerV2();
    inventoryManager.Initialize(this.GetExecutor() as PlayerPuppet);
    currentConsumable = inventoryManager.GetInventoryItemData(this.GetItemData());
    consumableType = TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(this.GetItemData().GetID())).ConsumableType().Type();
    inventoryItems = inventoryManager.GetPlayerInventoryData(InventoryItemData.GetEquipmentArea(currentConsumable), true);
    if ArraySize(inventoryItems) == 0 {
      return;
    };
    i = 0;
    while i < ArraySize(inventoryItems) {
      consumableRecord = TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(inventoryItems[i])));
      consumableQuality = consumableRecord.Quality().Value();
      if Equals(consumableRecord.ConsumableType().Type(), consumableType) && consumableQuality >= bestQuality {
        bestQuality = consumableQuality;
        consumableToEquip = inventoryItems[i];
      };
      i += 1;
    };
    if !InventoryItemData.IsEmpty(consumableToEquip) {
      inventoryManager.EquipItem(InventoryItemData.GetID(consumableToEquip), InventoryItemData.GetSlotIndex(currentConsumable));
    };
  }

  protected func ProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
    let effectInstigator: TweakDBID;
    let usedConsumableName: gamedataConsumableBaseName;
    let appliedEffects: array<ref<StatusEffect>> = StatusEffectHelper.GetAppliedEffects(this.GetExecutor());
    let newConsumableTDBID: TweakDBID = ItemID.GetTDBID(this.GetItemData().GetID());
    let newConsumableName: gamedataConsumableBaseName = TweakDBInterface.GetConsumableItemRecord(newConsumableTDBID).ConsumableBaseName().Type();
    let i: Int32 = 0;
    while i < ArraySize(appliedEffects) {
      effectInstigator = appliedEffects[i].GetInstigatorStaticDataID();
      usedConsumableName = TweakDBInterface.GetConsumableItemRecord(effectInstigator).ConsumableBaseName().Type();
      if Equals(newConsumableName, usedConsumableName) && Cast(appliedEffects[i].GetMaxStacks()) == 1 {
        StatusEffectHelper.RemoveStatusEffect(this.GetExecutor(), appliedEffects[i]);
      } else {
        i += 1;
      };
    };
    i = 0;
    while i < ArraySize(actionEffects) {
      StatusEffectHelper.ApplyStatusEffect(this.GetExecutor(), actionEffects[i].StatusEffect().GetID(), ItemID.GetTDBID(this.GetItemData().GetID()));
      i += 1;
    };
  }

  protected final func NotifyAutocraftSystem(gameInstance: GameInstance) -> Void {
    let autocraftSystem: ref<AutocraftSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"AutocraftSystem") as AutocraftSystem;
    let autocraftItemUsedRequest: ref<RegisterItemUsedRequest> = new RegisterItemUsedRequest();
    autocraftItemUsedRequest.itemUsed = this.GetItemData().GetID();
    autocraftSystem.QueueRequest(autocraftItemUsedRequest);
  }

  public func IsVisible(context: GetActionsContext, objectActionsCallbackController: wref<gameObjectActionsCallbackController>) -> Bool {
    if (this.GetExecutor() as PlayerPuppet).IsInCombat() {
      return false;
    };
    return true;
  }
}
