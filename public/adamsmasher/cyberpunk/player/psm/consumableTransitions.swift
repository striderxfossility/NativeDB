
public abstract class ConsumableTransitions extends DefaultTransition {

  protected final func IsUsingFluffConsumable(stateContext: ref<StateContext>) -> Bool {
    let activeItem: ItemID = this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable");
    let itemType: gamedataItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(activeItem)).ItemType().Type();
    if Equals(itemType, gamedataItemType.Con_Edible) {
      return true;
    };
    return false;
  }

  protected final func ChangeConsumableAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let activeItem: ItemID = this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable");
    let itemType: gamedataItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(activeItem)).ItemType().Type();
    let consumableAnimFeature: ref<AnimFeature_ConsumableAnimation> = new AnimFeature_ConsumableAnimation();
    consumableAnimFeature.useConsumable = newState;
    switch itemType {
      case gamedataItemType.Con_Injector:
        consumableAnimFeature.consumableType = 0;
        break;
      case gamedataItemType.Con_Inhaler:
        consumableAnimFeature.consumableType = 1;
    };
    scriptInterface.SetAnimationParameterFeature(n"ConsumableFeature", consumableAnimFeature, scriptInterface.executionOwner);
  }

  protected final func SetItemInLeftHand(scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let animFeature: ref<AnimFeature_LeftHandItem> = new AnimFeature_LeftHandItem();
    animFeature.itemInLeftHand = newState;
    scriptInterface.SetAnimationParameterFeature(n"LeftHandItem", animFeature, scriptInterface.executionOwner);
  }

  protected final const func GetConsumableCastPoint(consumableItem: ItemID) -> Float {
    return TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(consumableItem)).CastPoint();
  }

  protected final const func GetConsumableCycleDuration(consumableItem: ItemID) -> Float {
    return TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(consumableItem)).CycleDuration();
  }

  protected final const func GetConsumableInitBlendDuration(consumableItem: ItemID) -> Float {
    return TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(consumableItem)).InitBlendDuration();
  }

  protected final const func GetConsumableRemovePoint(consumableItem: ItemID) -> Float {
    return TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(consumableItem)).RemovePoint();
  }

  protected final const func ForceUnequipEvent(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let unequipEndEvent: ref<UnequipEnd> = new UnequipEnd();
    unequipEndEvent.SetSlotID(t"AttachmentSlots.WeaponLeft");
    scriptInterface.executionOwner.QueueEvent(unequipEndEvent);
  }

  protected final func SetLeftHandAnimationAnimFeature(scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let animFeature: ref<AnimFeature_LeftHandAnimation> = new AnimFeature_LeftHandAnimation();
    animFeature.lockLeftHandAnimation = newState;
    scriptInterface.SetAnimationParameterFeature(n"LeftHandAnimation", animFeature, scriptInterface.executionOwner);
  }
}

public class ConsumableStartupDecisions extends ConsumableTransitions {

  protected final const func ToConsumableUse(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetConsumableInitBlendDuration(this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable"));
  }
}

public class ConsumableStartupEvents extends ConsumableTransitions {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let blackboard: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    let containerConsumable: ItemID = FromVariant(blackboard.GetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.containerConsumable));
    if ItemID.IsValid(containerConsumable) {
      this.SetItemIDWrapperPermanentParameter(stateContext, n"consumable", containerConsumable);
      blackboard.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.containerConsumable, ToVariant(ItemID.undefined()));
      blackboard.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.consumableBeingUsed, ToVariant(containerConsumable));
    } else {
      this.SetItemIDWrapperPermanentParameter(stateContext, n"consumable", EquipmentSystem.GetData(scriptInterface.executionOwner).GetActiveConsumable());
      blackboard.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.consumableBeingUsed, ToVariant(EquipmentSystem.GetData(scriptInterface.executionOwner).GetActiveConsumable()));
    };
    if !this.IsUsingFluffConsumable(stateContext) {
      this.ForceDisableVisionMode(stateContext);
      this.ChangeConsumableAnimFeature(stateContext, scriptInterface, true);
      this.SetItemInLeftHand(scriptInterface, true);
      scriptInterface.PushAnimationEvent(n"UseConsumable");
    };
    this.SetLeftHandAnimationAnimFeature(scriptInterface, true);
    stateContext.SetTemporaryBoolParameter(n"CameraContext_ConsumableStartup", true, true);
    this.UpdateCameraContext(stateContext, scriptInterface);
  }
}

public class ConsumableUseDecisions extends ConsumableTransitions {

  protected final const func ToConsumableCleanup(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let hasConsumable: Bool = scriptInterface.GetTransactionSystem().HasItem(scriptInterface.executionOwner, this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable"));
    if this.GetInStateTime() > this.GetConsumableCycleDuration(this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable")) {
      return true;
    };
    if this.IsInLadderState(stateContext) || this.IsInLocomotionState(stateContext, n"climb") || this.IsInHighLevelState(stateContext, n"swimming") || scriptInterface.executionOwner.IsDead() || !hasConsumable {
      stateContext.SetTemporaryBoolParameter(n"forceExit", true, true);
      return true;
    };
    return false;
  }
}

public class ConsumableUseEvents extends ConsumableTransitions {

  public let effectsApplied: Bool;

  public let modelRemoved: Bool;

  public let activeConsumable: ItemID;

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.effectsApplied = false;
    this.modelRemoved = false;
    this.activeConsumable = this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable");
    this.SetLeftHandAnimationAnimFeature(scriptInterface, true);
    this.UpdateCameraContext(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let transactionSystem: ref<TransactionSystem>;
    if !this.effectsApplied && this.GetInStateTime() >= this.GetConsumableCastPoint(this.activeConsumable) {
      transactionSystem = scriptInterface.GetTransactionSystem();
      if transactionSystem.HasItem(scriptInterface.executionOwner, this.activeConsumable) {
        ItemActionsHelper.ConsumeItem(scriptInterface.executionOwner, this.activeConsumable, false);
        this.effectsApplied = true;
      };
    };
    if this.effectsApplied && !this.modelRemoved && this.GetInStateTime() > this.GetConsumableRemovePoint(this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable")) {
      this.ForceUnequipEvent(scriptInterface);
      this.modelRemoved = true;
    };
  }
}

public class ConsumableCleanupEvents extends ConsumableTransitions {

  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmIdent: StateMachineIdentifier;
    let unequipType: gameEquipAnimationType;
    let psmRemove: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    this.SetLeftHandAnimationAnimFeature(scriptInterface, false);
    psmIdent.definitionName = n"Consumable";
    psmRemove.stateMachineIdentifier = psmIdent;
    scriptInterface.executionOwner.QueueEvent(psmRemove);
    if stateContext.GetBoolParameter(n"forceExit") {
      unequipType = gameEquipAnimationType.Instant;
    } else {
      unequipType = gameEquipAnimationType.Default;
    };
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipConsumable, unequipType);
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let blackboard: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    this.SetLeftHandAnimationAnimFeature(scriptInterface, false);
    this.ClearItemIDWrapperPermanentParameter(stateContext, n"consumable");
    this.ChangeConsumableAnimFeature(stateContext, scriptInterface, false);
    this.SetItemInLeftHand(scriptInterface, false);
    blackboardSystem = scriptInterface.GetBlackboardSystem();
    blackboard = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetBool(GetAllBlackboardDefs().UI_QuickSlotsData.dpadHintRefresh, true);
    blackboard.SignalBool(GetAllBlackboardDefs().UI_QuickSlotsData.dpadHintRefresh);
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipConsumable, gameEquipAnimationType.Instant);
  }
}
