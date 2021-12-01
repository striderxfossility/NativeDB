
public abstract class CombatGadgetTransitions extends DefaultTransition {

  protected final func SetLeftHandAnimationAnimFeature(scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let animFeature: ref<AnimFeature_LeftHandAnimation> = new AnimFeature_LeftHandAnimation();
    animFeature.lockLeftHandAnimation = newState;
    scriptInterface.SetAnimationParameterFeature(n"LeftHandAnimation", animFeature, scriptInterface.executionOwner);
  }

  protected final func SetCombatGadgetAnimFeature(scriptInterface: ref<StateGameScriptInterface>, isQuickthrow: Bool, isChargedThrow: Bool) -> Void {
    let feature: ref<AnimFeature_CombatGadget> = new AnimFeature_CombatGadget();
    feature.isQuickthrow = isQuickthrow;
    feature.isChargedThrow = isChargedThrow;
    scriptInterface.SetAnimationParameterFeature(n"CombatGadget", feature, scriptInterface.executionOwner);
  }

  protected final func SetBlackbordThrowUnequip(scriptInterface: ref<StateGameScriptInterface>, newThrowUnequip: Bool) -> Void {
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().CombatGadget.throwUnequip, newThrowUnequip);
  }

  protected final const func SetThrowableAnimFeatureOnGrenade(scriptInterface: ref<StateGameScriptInterface>, newState: Int32, target: wref<GameObject>) -> Void {
    let feature: ref<AnimFeature_Throwable> = new AnimFeature_Throwable();
    feature.state = newState;
    scriptInterface.SetAnimationParameterFeature(n"CombatGadget", feature, target);
  }

  protected final const func SetThrowableAnimFeatureOnGrenade(scriptInterface: ref<StateGameScriptInterface>, newState: Int32, isQuickthrow: Bool) -> Void {
    let feature: ref<AnimFeature_Throwable> = new AnimFeature_Throwable();
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let slot: String = isQuickthrow ? "AttachmentSlots.WeaponLeft" : "AttachmentSlots.WeaponRight";
    let target: ref<ItemObject> = transactionSystem.GetItemInSlot(scriptInterface.executionOwner as PlayerPuppet, TDBID.Create(slot));
    feature.state = newState;
    scriptInterface.SetAnimationParameterFeature(n"CombatGadget", feature, target);
  }

  protected final const func ClearLastUsedAnimWrapperInfo(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(scriptInterface.executionOwnerEntityID, GetAllBlackboardDefs().PlayerStateMachine);
    let lastUsed: ItemID = FromVariant(blackboard.GetVariant(GetAllBlackboardDefs().PlayerStateMachine.LastCombatGadgetUsed));
    if ItemID.IsValid(lastUsed) {
      this.SendAnimWrapperInfo(scriptInterface, lastUsed, true);
    };
  }

  protected final const func SendAnimWrapperInfo(scriptInterface: ref<StateGameScriptInterface>, item: ItemID, clearWrapperInfo: Bool, opt delay: Float) -> Void {
    let animWrapperEvent: ref<FillAnimWrapperInfoBasedOnEquippedItem> = new FillAnimWrapperInfoBasedOnEquippedItem();
    animWrapperEvent.itemID = item;
    animWrapperEvent.itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().Name();
    animWrapperEvent.itemName = StringToName(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).FriendlyName());
    animWrapperEvent.clearWrapperInfo = clearWrapperInfo;
    if delay > 0.00 {
      scriptInterface.GetDelaySystem().DelayEvent(scriptInterface.executionOwner, animWrapperEvent, delay, true);
    } else {
      scriptInterface.executionOwner.QueueEventForEntityID(scriptInterface.executionOwnerEntityID, animWrapperEvent);
    };
  }

  protected final const func SaveLastUsedCombatGadget(scriptInterface: ref<StateGameScriptInterface>, item: ItemID) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(scriptInterface.executionOwnerEntityID, GetAllBlackboardDefs().PlayerStateMachine);
    blackboard.SetVariant(GetAllBlackboardDefs().PlayerStateMachine.LastCombatGadgetUsed, ToVariant(item));
  }

  protected final const func GetLockHoldCondition(const stateContext: ref<StateContext>) -> Bool {
    let result: StateResultBool = stateContext.GetConditionBoolParameter(n"lockHold");
    return result.valid && result.value;
  }

  protected final const func GetSlotTDBID(const stateContext: ref<StateContext>) -> TweakDBID {
    if stateContext.GetBoolParameter(n"rightHandThrow", true) {
      return t"AttachmentSlots.WeaponRight";
    };
    return t"AttachmentSlots.WeaponLeft";
  }

  protected final const func RemoveGrenadeFromRightHand(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    transactionSystem.RemoveItemFromSlot(scriptInterface.executionOwner as PlayerPuppet, t"AttachmentSlots.WeaponRight", false);
  }

  protected final const func GetRotateAngle(isQuickthrow: Bool) -> Float {
    if isQuickthrow {
      return this.GetStaticFloatParameterDefault("quickThrowAngle", 1.00);
    };
    return this.GetStaticFloatParameterDefault("regularThrowAngle", 1.00);
  }

  protected final const func Throw(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, isQuickthrow: Bool, opt inLocalAimForward: Vector4, opt inLocalAimPosition: Vector4) -> Void {
    let blackboard: ref<IBlackboard>;
    let blackboardSystem: ref<BlackboardSystem>;
    let item: ref<ItemObject>;
    let launchEvent: ref<gameprojectileSetUpAndLaunchEvent>;
    let logicalOrientationProvider: ref<IOrientationProvider>;
    let logicalPositionProvider: ref<IPositionProvider>;
    let orientationEntitySpace: Quaternion;
    let playerPuppet: ref<PlayerPuppet>;
    let targetingSystem: ref<TargetingSystem>;
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    if !this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Gadget) {
      return;
    };
    blackboardSystem = scriptInterface.GetBlackboardSystem();
    blackboard = blackboardSystem.Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    blackboard.SetBool(GetAllBlackboardDefs().UI_QuickSlotsData.dpadHintRefresh, true);
    blackboard.SignalBool(GetAllBlackboardDefs().UI_QuickSlotsData.dpadHintRefresh);
    playerPuppet = scriptInterface.executionOwner as PlayerPuppet;
    item = transactionSystem.GetItemInSlot(playerPuppet, this.GetSlotTDBID(stateContext));
    transactionSystem.RemoveItemFromSlot(playerPuppet, this.GetSlotTDBID(stateContext), item.IsClientSideOnlyGadget(), false, true);
    if IsDefined(item) && !item.IsClientSideOnlyGadget() {
      launchEvent = new gameprojectileSetUpAndLaunchEvent();
      this.SetItemIDWrapperPermanentParameter(stateContext, n"grenade", item.GetItemID());
      Quaternion.SetIdentity(orientationEntitySpace);
      Quaternion.SetXRot(orientationEntitySpace, this.GetRotateAngle(isQuickthrow));
      if Vector4.IsZero(inLocalAimPosition) || Vector4.IsZero(inLocalAimForward) {
        targetingSystem = GameInstance.GetTargetingSystem(playerPuppet.GetGame());
        logicalPositionProvider = targetingSystem.GetDefaultCrosshairPositionProvider(playerPuppet);
        logicalOrientationProvider = targetingSystem.GetDefaultCrosshairOrientationProvider(playerPuppet, orientationEntitySpace);
      } else {
        logicalPositionProvider = IPositionProvider.CreateEntityPositionProvider(playerPuppet, Vector4.Vector4To3(inLocalAimPosition));
        inLocalAimForward = Quaternion.Transform(orientationEntitySpace, inLocalAimForward);
        orientationEntitySpace = Quaternion.BuildFromDirectionVector(inLocalAimForward);
        logicalOrientationProvider = IOrientationProvider.CreateEntityOrientationProvider(null, n"", playerPuppet, orientationEntitySpace);
      };
      launchEvent.launchParams.logicalPositionProvider = logicalPositionProvider;
      launchEvent.launchParams.logicalOrientationProvider = logicalOrientationProvider;
      launchEvent.launchParams.visualPositionProvider = IPositionProvider.CreateEntityPositionProvider(item);
      launchEvent.launchParams.visualOrientationProvider = IOrientationProvider.CreateEntityOrientationProvider(null, n"", item);
      launchEvent.launchParams.ownerVelocityProvider = MoveComponentVelocityProvider.CreateMoveComponentVelocityProvider(playerPuppet);
      launchEvent.lerpMultiplier = 15.00;
      launchEvent.trajectoryParams = this.CreateTrajectoryParams(item, isQuickthrow);
      launchEvent.owner = playerPuppet;
      item.QueueEvent(launchEvent);
    };
  }

  protected final const func NotifyAutocraftSystem(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let autocraftSystem: ref<AutocraftSystem> = scriptInterface.GetScriptableSystem(n"AutocraftSystem") as AutocraftSystem;
    let autocraftItemUsedRequest: ref<RegisterItemUsedRequest> = new RegisterItemUsedRequest();
    autocraftItemUsedRequest.itemUsed = EquipmentSystem.GetData(scriptInterface.executionOwner).GetActiveGadget();
    autocraftSystem.QueueRequest(autocraftItemUsedRequest);
  }

  protected final const func CreateTrajectoryParams(item: ref<ItemObject>, isQuickthrow: Bool) -> ref<gameprojectileTrajectoryParams> {
    let grenadeItem: ref<BaseGrenade> = item as BaseGrenade;
    let initialVelocity: Float = grenadeItem.GetInitialVelocity(isQuickthrow);
    let accelerationZ: Float = grenadeItem.GetAccelerationZ();
    return ParabolicTrajectoryParams.GetAccelVelParabolicParams(new Vector4(0.00, 0.00, accelerationZ, 0.00), initialVelocity, 20.00);
  }

  protected final const func CheckVehicleStatesForUnequipRequest(const stateContext: ref<StateContext>) -> Bool {
    return stateContext.IsStateMachineActive(n"Vehicle") && !stateContext.IsStateActive(n"Vehicle", n"combat");
  }

  protected final func SetItemInLeftHand(scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let animFeature: ref<AnimFeature_LeftHandItem> = new AnimFeature_LeftHandItem();
    animFeature.itemInLeftHand = newState;
    scriptInterface.SetAnimationParameterFeature(n"LeftHandItem", animFeature, scriptInterface.executionOwner);
  }

  protected final func SetLeftHandItemHandlingItemState(scriptInterface: ref<StateGameScriptInterface>, newState: Int32) -> Void {
    let leftHandItemHandling: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    leftHandItemHandling.itemState = newState;
    if newState > 0 {
      leftHandItemHandling.itemType = 5;
    } else {
      leftHandItemHandling.itemType = 0;
    };
    scriptInterface.SetAnimationParameterFeature(n"leftHandItemHandling", leftHandItemHandling, scriptInterface.executionOwner);
  }

  protected final const func ShouldForceUnequipGrenade(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let takedownState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown);
    let isInTakedown: Bool = takedownState == EnumInt(gamePSMTakedown.Grapple) || takedownState == EnumInt(gamePSMTakedown.Leap) || takedownState == EnumInt(gamePSMTakedown.Takedown);
    return isInTakedown || !this.IsUsingLeftHandAllowed(scriptInterface) || scriptInterface.GetWorkspotSystem().IsActorInWorkspot(scriptInterface.executionOwner) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle);
  }

  protected final const func RemoveGrenadeFromInventory(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.GetTransactionSystem().RemoveItem(scriptInterface.executionOwner, EquipmentSystem.GetData(scriptInterface.executionOwner).GetActiveGadget(), 1);
  }

  protected final const func GetCancelGrenadeAction(const stateContext: ref<StateContext>) -> Bool {
    let cancelAction: StateResultBool = stateContext.GetTemporaryBoolParameter(n"CancelGrenadeAction");
    return cancelAction.valid && cancelAction.value;
  }

  protected final const func CheckEquipDurationCondition(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Bool {
    let inStateTime: Float = this.GetInStateTime();
    let unequip: Float = stateContext.GetFloatParameter(n"rhUnequipDuration", true);
    let equip: Float = this.GetStaticFloatParameterDefault("equipDuration", 1.00);
    if unequip < equip {
      unequip = equip;
    };
    unequip += 0.20;
    return inStateTime >= equip && inStateTime >= unequip;
  }
}

public class CombatGadgetInactiveDecisions extends CombatGadgetTransitions {

  protected final const func ToCombatGadgetQuickThrow(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"UseCombatGadget") == 0.00 && NotEquals(stateContext.GetStateMachineCurrentState(n"UpperBody"), n"useConsumable") && !this.IsInWeaponReloadState(scriptInterface);
  }

  protected final const func ToCombatGadgetEquip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustHeld(n"UseCombatGadget") || stateContext.GetBoolParameter(n"cgCached", true);
  }
}

public class CombatGadgetInactiveEvents extends CombatGadgetTransitions {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let activeGadget: ItemID;
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.Default));
    this.SetLeftHandItemHandlingItemState(scriptInterface, 2);
    activeGadget = EquipmentSystem.GetData(scriptInterface.executionOwner).GetActiveGadget();
    this.ClearLastUsedAnimWrapperInfo(scriptInterface);
    this.SendAnimWrapperInfo(scriptInterface, activeGadget, false);
    this.SaveLastUsedCombatGadget(scriptInterface, activeGadget);
    this.SetCombatGadgetAnimFeature(scriptInterface, false, false);
    this.SetLeftHandAnimationAnimFeature(scriptInterface, true);
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
  }
}

public class CombatGadgetEquipDecisions extends CombatGadgetTransitions {

  protected final const func ToCombatGadgetQuickThrow(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }

  protected final const func ToCombatGadgetCharge(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isKereznikowActive: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Kereznikov);
    return this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Gadget) && !stateContext.GetBoolParameter(n"CancelAction", true) && !isKereznikowActive;
  }

  protected final const func ToCombatGadgetWaitForUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"Reload") || scriptInterface.IsActionJustPressed(n"SwitchItem") && !this.IsInInputContextState(stateContext, n"aimingContext") {
      return true;
    };
    if stateContext.IsStateActive(n"Locomotion", n"superheroFall") || stateContext.IsStateActive(n"Locomotion", n"vault") || this.IsInLadderState(stateContext) || stateContext.IsStateActive(n"Vehicle", n"exitingCombat") || this.CheckVehicleStatesForUnequipRequest(stateContext) || this.GetCancelGrenadeAction(stateContext) || this.IsInSafeZone(scriptInterface) || this.IsInSafeSceneTier(scriptInterface) || stateContext.GetBoolParameter(n"CancelAction", true) {
      return true;
    };
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) == EnumInt(gamePSMCombatGadget.WaitForUnequip);
  }

  protected final const func ToCombatGadgetUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.IsStateActive(n"Locomotion", n"climb") || stateContext.IsStateActive(n"HighLevel", n"swimming") || this.CheckVehicleStatesForUnequipRequest(stateContext) || StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown) || this.IsPlayerInAnyMenu(scriptInterface);
  }
}

public class CombatGadgetEquipEvents extends CombatGadgetTransitions {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackbordThrowUnequip(scriptInterface, false);
    scriptInterface.TEMP_WeaponStopFiring();
    scriptInterface.PushAnimationEvent(n"CombatGadgetEquip");
    stateContext.RemovePermanentBoolParameter(n"cgCached");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.Equipped));
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= 0.10 {
      this.SetItemInLeftHand(scriptInterface, true);
    };
  }
}

public class CombatGadgetQuickThrowDecisions extends CombatGadgetTransitions {

  protected final const func ToCombatGadgetUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("postThrowDelay", 0.50);
  }
}

public class CombatGadgetQuickThrowEvents extends CombatGadgetTransitions {

  public let m_grenadeThrown: Bool;

  public let m_event: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.IllegalAction);
    };
    this.SetCombatGadgetAnimFeature(scriptInterface, true, false);
    this.SetBlackbordThrowUnequip(scriptInterface, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.QuickThrow));
    DefaultTransition.PlayRumble(scriptInterface, "medium_pulse");
    stateContext.SetTemporaryBoolParameter(n"InterruptAiming", true, true);
    if stateContext.IsStateActive(n"UpperBody", n"aimingState") && stateContext.IsStateActive(n"CoverAction", n"activateCover") {
      stateContext.SetPermanentBoolParameter(n"QuickthrowHoldPeek", true, true);
    };
    this.m_grenadeThrown = false;
    this.m_event = false;
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= 0.05 && !this.m_event {
      scriptInterface.PushAnimationEvent(n"CombatGadgetQuickThrow");
      this.SetThrowableAnimFeatureOnGrenade(scriptInterface, 2, true);
      this.m_event = true;
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("releaseTime", 0.20) && !this.m_grenadeThrown {
      this.m_grenadeThrown = true;
      this.Throw(scriptInterface, stateContext, true);
      this.RemoveGrenadeFromInventory(scriptInterface);
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public class CombatGadgetChargedThrowDecisions extends CombatGadgetTransitions {

  protected final const func ToCombatGadgetWaitForUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("releaseTime", 0.20);
  }
}

public class CombatGadgetChargedThrowEvents extends CombatGadgetTransitions {

  public let m_grenadeThrown: Bool;

  public let m_localAimForward: Vector4;

  public let m_localAimPosition: Vector4;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let aimForward: Vector4;
    let aimPosition: Vector4;
    let ownerWorldTransform: WorldTransform;
    let targetingSystem: ref<TargetingSystem>;
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.Throwing));
    this.SetBlackbordThrowUnequip(scriptInterface, true);
    this.SetItemInLeftHand(scriptInterface, false);
    this.SetCombatGadgetAnimFeature(scriptInterface, false, true);
    scriptInterface.PushAnimationEvent(n"CombatGadgetChargedThrow");
    this.SetThrowableAnimFeatureOnGrenade(scriptInterface, 2, false);
    this.m_grenadeThrown = false;
    DefaultTransition.PlayRumble(scriptInterface, "heavy_pulse");
    targetingSystem = scriptInterface.GetTargetingSystem();
    targetingSystem.GetDefaultCrosshairData(scriptInterface.executionOwner, aimPosition, aimForward);
    ownerWorldTransform = scriptInterface.executionOwner.GetWorldTransform();
    this.m_localAimForward = WorldTransform.TransformInvPoint(ownerWorldTransform, scriptInterface.executionOwner.GetWorldPosition() + aimForward);
    this.m_localAimPosition = WorldTransform.TransformInvPoint(ownerWorldTransform, aimPosition);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("releaseTime", 0.20) && !this.m_grenadeThrown {
      this.m_grenadeThrown = true;
      this.Throw(scriptInterface, stateContext, false, this.m_localAimForward, this.m_localAimPosition);
      this.RemoveGrenadeFromInventory(scriptInterface);
    };
  }
}

public class CombatGadgetChargeDecisions extends CombatGadgetTransitions {

  protected final const func ToCombatGadgetChargedThrow(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"UseCombatGadget") == 0.00 && scriptInterface.GetActionValue(n"VisionHold") == 0.00 && !this.IsRightHandInUnequippingState(stateContext) && this.IsLeftHandInEquippedState(stateContext) && this.CheckEquipDurationCondition(scriptInterface, stateContext) && !this.IsInFocusMode(scriptInterface) && !this.IsPlayerInAnyMenu(scriptInterface);
  }

  protected final const func ToCombatGadgetWaitForUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let locomotionState: CName = stateContext.GetStateMachineCurrentState(n"Locomotion");
    if Equals(locomotionState, n"superheroFall") || Equals(locomotionState, n"ladder") || Equals(locomotionState, n"ladderSprint") || Equals(locomotionState, n"ladderSlide") || this.CheckVehicleStatesForUnequipRequest(stateContext) || this.GetCancelGrenadeAction(stateContext) || this.IsInSafeZone(scriptInterface) || this.IsSafeStateForced(stateContext, scriptInterface) || scriptInterface.GetActionValue(n"VisionHold") != 0.00 || this.IsInFocusMode(scriptInterface) || this.ShouldForceUnequipGrenade(scriptInterface) || this.IsInSafeSceneTier(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToCombatGadgetUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let locomotionState: CName = stateContext.GetStateMachineCurrentState(n"Locomotion");
    if Equals(locomotionState, n"climb") || stateContext.IsStateActive(n"HighLevel", n"swimming") || this.CheckVehicleStatesForUnequipRequest(stateContext) || StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown) || this.IsPlayerInAnyMenu(scriptInterface) || scriptInterface.IsActionJustReleased(n"OpenPauseMenu") || scriptInterface.executionOwner.GetTakeOverControlSystem().IsDeviceControlled() || Equals(locomotionState, n"vehicleKnockdown") {
      return true;
    };
    return false;
  }

  protected final const func ToCombatGadgetEquip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetCancelChargeButtonInput(scriptInterface);
  }
}

public class CombatGadgetChargeEvents extends CombatGadgetTransitions {

  public let initiated: Bool;

  public let itemSwitched: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.AddActiveStimuli(scriptInterface.executionOwner, gamedataStimType.IllegalInteraction, -1.00);
    };
    this.DisableCameraBobbing(stateContext, scriptInterface, true);
    this.ShowInputHint(scriptInterface, n"CancelChargingCG", n"Locomotion", "LocKey#49906");
    this.initiated = false;
    this.itemSwitched = false;
    stateContext.SetPermanentBoolParameter(n"rightHandThrow", true, true);
    this.SetCombatGadgetAnimFeature(scriptInterface, false, true);
    if this.IsRightHandInEquippedState(stateContext) {
      stateContext.SetPermanentBoolParameter(n"forceTempUnequipWeapon", true, true);
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let itemObject: ref<ItemObject>;
    let puppet: ref<PlayerPuppet>;
    let setupEvent: ref<gameprojectileSetUpEvent>;
    let transactionSystem: ref<TransactionSystem>;
    if !this.initiated && this.IsRightHandInUnequippedState(stateContext) && !this.itemSwitched {
      this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.Charging));
      scriptInterface.PushAnimationEvent(n"CombatGadgetCharge");
      scriptInterface.TEMP_WeaponStopFiring();
      puppet = scriptInterface.executionOwner as PlayerPuppet;
      transactionSystem = scriptInterface.GetTransactionSystem();
      itemObject = transactionSystem.GetItemInSlot(puppet, t"AttachmentSlots.WeaponLeft");
      if IsDefined(itemObject) {
        transactionSystem.ChangeItemToSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight", itemObject.GetItemID());
        this.initiated = true;
      };
    };
    if this.initiated && !this.itemSwitched {
      itemObject = transactionSystem.GetItemInSlot(puppet, t"AttachmentSlots.WeaponRight");
      if IsDefined(itemObject) {
        setupEvent = new gameprojectileSetUpEvent();
        setupEvent.owner = puppet;
        setupEvent.trajectoryParams = this.CreateTrajectoryParams(itemObject, false);
        itemObject.QueueEvent(setupEvent);
        this.SetThrowableAnimFeatureOnGrenade(scriptInterface, 1, itemObject);
        this.itemSwitched = true;
      };
    };
    if this.CheckEquipDurationCondition(scriptInterface, stateContext) {
      this.TogglePreview(true, scriptInterface, stateContext);
    };
  }

  protected final func OnExitToCombatGadgetChargedThrow(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.TEMP_WeaponStopFiring();
    this.TogglePreview(false, scriptInterface, stateContext);
    this.RemoveActiveStimuli(scriptInterface.executionOwner);
    this.DisableCameraBobbing(stateContext, scriptInterface, false);
    this.RemoveInputHint(scriptInterface, n"CancelChargingCG", n"Locomotion");
  }

  protected final func OnExitToCombatGadgetWaitForUnequip(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.TEMP_WeaponStopFiring();
    this.TogglePreview(false, scriptInterface, stateContext);
    this.RemoveActiveStimuli(scriptInterface.executionOwner);
    this.DisableCameraBobbing(stateContext, scriptInterface, false);
    this.RemoveInputHint(scriptInterface, n"CancelChargingCG", n"Locomotion");
  }

  protected final func OnExitToCombatGadgetUnequip(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.TEMP_WeaponStopFiring();
    this.TogglePreview(false, scriptInterface, stateContext);
    this.RemoveActiveStimuli(scriptInterface.executionOwner);
    this.DisableCameraBobbing(stateContext, scriptInterface, false);
    this.RemoveInputHint(scriptInterface, n"CancelChargingCG", n"Locomotion");
  }

  protected final func OnExitToCombatGadgetEquip(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.TEMP_WeaponStopFiring();
    scriptInterface.PushAnimationEvent(n"CombatGadgetStopCharge");
    stateContext.SetPermanentBoolParameter(n"CancelAction", true, true);
    this.TogglePreview(false, scriptInterface, stateContext);
    this.RemoveActiveStimuli(scriptInterface.executionOwner);
    this.DisableCameraBobbing(stateContext, scriptInterface, false);
    this.RemoveInputHint(scriptInterface, n"CancelChargingCG", n"Locomotion");
  }

  protected final func TogglePreview(on: Bool, scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let itemObject: ref<ItemObject>;
    let showPreviewEvent: ref<gameprojectileProjectilePreviewEvent>;
    let transactionSystem: ref<TransactionSystem>;
    if !scriptInterface.executionOwner.IsControlledByLocalPeer() {
      return;
    };
    transactionSystem = scriptInterface.GetTransactionSystem();
    itemObject = transactionSystem.GetItemInSlot(scriptInterface.executionOwner as PlayerPuppet, this.GetSlotTDBID(stateContext));
    if IsDefined(itemObject) {
      showPreviewEvent = new gameprojectileProjectilePreviewEvent();
      showPreviewEvent.previewActive = on;
      itemObject.QueueEvent(showPreviewEvent);
    };
  }

  private final func RemoveActiveStimuli(owner: ref<GameObject>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = owner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.RemoveActiveStimuliByName(owner, gamedataStimType.IllegalInteraction);
    };
  }
}

public class CombatGadgetWaitForUnequipDecisions extends CombatGadgetTransitions {

  protected final const func ToCombatGadgetUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("UnequipDuration", 0.20);
  }
}

public class CombatGadgetWaitForUnequipEvents extends CombatGadgetTransitions {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.WaitForUnequip));
    scriptInterface.PushAnimationEvent(n"CombatGadgetUnequip");
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipGadget);
    if !stateContext.GetBoolParameter(n"rightHandThrow", true) {
      this.SetLeftHandAnimationAnimFeature(scriptInterface, false);
    };
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetLeftHandAnimationAnimFeature(scriptInterface, false);
    this.SetItemInLeftHand(scriptInterface, false);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.Default));
    this.SetLeftHandItemHandlingItemState(scriptInterface, 0);
    stateContext.RemovePermanentBoolParameter(n"CancelAction");
    stateContext.RemovePermanentBoolParameter(n"forceTempUnequipWeapon");
    stateContext.RemovePermanentBoolParameter(n"rightHandThrow");
    stateContext.RemovePermanentBoolParameter(n"lockHold");
    this.ClearItemIDWrapperPermanentParameter(stateContext, n"grenade");
  }
}

public class CombatGadgetUnequipEvents extends CombatGadgetTransitions {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmIdent: StateMachineIdentifier;
    let psmRemove: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.CombatGadget, EnumInt(gamePSMCombatGadget.Default));
    this.SetLeftHandAnimationAnimFeature(scriptInterface, false);
    this.SetCombatGadgetAnimFeature(scriptInterface, false, false);
    this.SetItemInLeftHand(scriptInterface, false);
    this.SetLeftHandItemHandlingItemState(scriptInterface, 0);
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipGadget);
    if stateContext.GetBoolParameter(n"rightHandThrow", true) {
      this.RemoveGrenadeFromRightHand(scriptInterface);
    };
    stateContext.RemoveConditionBoolParameter(n"lockHold");
    stateContext.RemovePermanentBoolParameter(n"CancelAction");
    stateContext.RemovePermanentBoolParameter(n"forceTempUnequipWeapon");
    stateContext.RemovePermanentBoolParameter(n"rightHandThrow");
    psmIdent.definitionName = n"CombatGadget";
    psmRemove.stateMachineIdentifier = psmIdent;
    scriptInterface.executionOwner.QueueEvent(psmRemove);
    this.ClearItemIDWrapperPermanentParameter(stateContext, n"grenade");
  }
}
