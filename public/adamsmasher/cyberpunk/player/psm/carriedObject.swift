
public abstract class OldUpperBodyTransition extends DefaultTransition {

  protected final func CanEquipFirearm(owner: ref<GameObject>, stateContext: ref<StateContext>) -> Bool {
    let playerData: ref<EquipmentSystemPlayerData>;
    let weaponID: ItemID;
    let itemType: gamedataItemType = gamedataItemType.Invalid;
    let equipmentSystem: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    if !IsDefined(equipmentSystem) {
      return false;
    };
    if this.IsInEmptyHandsState(stateContext) {
      return false;
    };
    playerData = equipmentSystem.GetPlayerData(owner);
    weaponID = playerData.GetLastUsedOrFirstAvailableOneHandedRangedWeapon();
    if ItemID.IsValid(weaponID) {
      itemType = RPGManager.GetItemType(weaponID);
      if Equals(itemType, gamedataItemType.Wea_Handgun) || Equals(itemType, gamedataItemType.Wea_Revolver) {
        return true;
      };
    };
    return false;
  }

  public final static func HasRightHandWeaponActiveInSlot(owner: ref<GameObject>) -> Bool {
    let weaponItem: ItemID;
    if IsDefined(owner) {
      weaponItem = GameInstance.GetTransactionSystem(owner.GetGame()).GetActiveItemInSlot(owner, t"AttachmentSlots.WeaponRight");
      if ItemID.IsValid(weaponItem) {
        return true;
      };
    };
    return false;
  }
}

public abstract class OldUpperBodyEventsTransition extends OldUpperBodyTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;
}

public abstract class CarriedObjectEvents extends OldUpperBodyEventsTransition {

  public let m_animFeature: ref<AnimFeature_Mounting>;

  public let m_animCarryFeature: ref<AnimFeature_Carry>;

  public let m_leftHandFeature: ref<AnimFeature_LeftHandAnimation>;

  public let m_AnimWrapperWeightSetterStrong: ref<AnimWrapperWeightSetter>;

  public let m_AnimWrapperWeightSetterFriendly: ref<AnimWrapperWeightSetter>;

  @default(CarriedObjectEvents, CarriedObject.Style)
  public let m_styleName: CName;

  @default(CarriedObjectEvents, CarriedObject.ForcedStyle)
  public let m_forceStyleName: CName;

  public let m_isFriendlyCarry: Bool;

  public let m_forcedCarryStyle: gamePSMBodyCarryingStyle;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let attitude: EAIAttitude;
    let mountEvent: ref<MountingRequest>;
    let puppet: ref<gamePuppet>;
    let slotId: MountingSlotId;
    let workspotSystem: ref<WorkspotGameSystem>;
    let mountingInfo: MountingInfo = scriptInterface.GetMountingFacility().GetMountingInfoSingleWithObjects(scriptInterface.owner);
    let isNPCMounted: Bool = EntityID.IsDefined(mountingInfo.childId);
    if !isNPCMounted && !this.IsBodyDisposalOngoing(stateContext, scriptInterface) {
      mountEvent = new MountingRequest();
      slotId.id = n"leftShoulder";
      mountingInfo.childId = scriptInterface.ownerEntityID;
      mountingInfo.parentId = scriptInterface.executionOwnerEntityID;
      mountingInfo.slotId = slotId;
      mountEvent.lowLevelMountingInfo = mountingInfo;
      scriptInterface.GetMountingFacility().Mount(mountEvent);
      (scriptInterface.owner as NPCPuppet).MountingStartDisableComponents();
    };
    workspotSystem = scriptInterface.GetWorkspotSystem();
    this.m_animFeature = new AnimFeature_Mounting();
    this.m_animFeature.mountingState = 2;
    this.UpdateCarryStylePickUpAndDropParams(stateContext, scriptInterface, false);
    this.m_isFriendlyCarry = false;
    this.m_forcedCarryStyle = gamePSMBodyCarryingStyle.Any;
    puppet = scriptInterface.owner as gamePuppet;
    if IsDefined(puppet) {
      if IsDefined(workspotSystem) && !this.IsBodyDisposalOngoing(stateContext, scriptInterface) {
        workspotSystem.StopNpcInWorkspot(puppet);
      };
      attitude = GameObject.GetAttitudeBetween(scriptInterface.owner, scriptInterface.executionOwner);
      this.m_forcedCarryStyle = IntEnum(puppet.GetBlackboard().GetInt(GetAllBlackboardDefs().Puppet.ForcedCarryStyle));
      if Equals(this.m_forcedCarryStyle, gamePSMBodyCarryingStyle.Friendly) || Equals(attitude, EAIAttitude.AIA_Friendly) && Equals(this.m_forcedCarryStyle, gamePSMBodyCarryingStyle.Any) {
        this.m_isFriendlyCarry = true;
      };
      this.UpdateCarryStylePickUpAndDropParams(stateContext, scriptInterface, this.m_isFriendlyCarry);
    };
    scriptInterface.SetAnimationParameterFeature(n"Mounting", this.m_animFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"Mounting", this.m_animFeature);
    (scriptInterface.owner as NPCPuppet).MountingStartDisableComponents();
  }

  protected func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanUpCarryState(IntEnum(0l), stateContext, scriptInterface);
  }

  protected final func IsBodyDisposalOngoing(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.CarryingDisposal);
  }

  protected final func UpdateCarryStylePickUpAndDropParams(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isFriendly: Bool) -> Void {
    this.UpdateGameplayRestrictions(stateContext, scriptInterface);
    if isFriendly {
      stateContext.SetConditionBoolParameter(n"CarriedObjectPlayPickUp", false, true);
      this.SetBodyCarryFriendlyCameraContext(stateContext, scriptInterface, true);
      this.ApplyFriendlyCarryGameplayRestrictions(stateContext, scriptInterface);
    } else {
      stateContext.SetConditionBoolParameter(n"CarriedObjectPlayPickUp", true, true);
    };
  }

  protected final func SetCarryState(state: ECarryState, opt pickupAnimation: Int32, instant: Bool, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isMultiplayer: Bool;
    let lockLeftHand: Bool;
    this.m_animCarryFeature = new AnimFeature_Carry();
    this.m_animCarryFeature.state = EnumInt(state);
    this.m_animCarryFeature.pickupAnimation = pickupAnimation;
    this.m_animCarryFeature.useBothHands = false;
    this.m_animCarryFeature.instant = instant;
    if NotEquals(state, IntEnum(0l)) && NotEquals(state, ECarryState.Release) {
      if Equals(this.GetStyle(stateContext), gamePSMBodyCarryingStyle.Strong) && Equals(state, ECarryState.Carry) {
        isMultiplayer = GameInstance.GetRuntimeInfo(scriptInterface.executionOwner.GetGame()).IsMultiplayer();
        if isMultiplayer {
          this.m_animCarryFeature.useBothHands = !OldUpperBodyTransition.HasRightHandWeaponActiveInSlot(scriptInterface.executionOwner);
        } else {
          if !isMultiplayer && scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileCarryingBody) {
            this.m_animCarryFeature.useBothHands = !this.CanEquipFirearm(scriptInterface.executionOwner, stateContext);
          } else {
            this.m_animCarryFeature.useBothHands = true;
          };
        };
      } else {
        this.m_animCarryFeature.useBothHands = true;
      };
    };
    scriptInterface.SetAnimationParameterFeature(n"Carry", this.m_animCarryFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"Carry", this.m_animCarryFeature, scriptInterface.owner);
    lockLeftHand = !this.m_animCarryFeature.useBothHands;
    this.LockLeftHandAnimation(scriptInterface, lockLeftHand);
  }

  protected final func SetBodyPickUpCameraContext(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, value: Bool, opt skipCameraContextUpdate: Bool) -> Void {
    this.SetCameraContext(stateContext, scriptInterface, n"setBodyPickUpContext", value, skipCameraContextUpdate);
  }

  protected final func SetBodyCarryCameraContext(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, value: Bool, opt skipCameraContextUpdate: Bool) -> Void {
    this.SetCameraContext(stateContext, scriptInterface, n"setBodyCarryContext", value, skipCameraContextUpdate);
  }

  protected final func SetBodyCarryFriendlyCameraContext(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, value: Bool, opt skipCameraContextUpdate: Bool) -> Void {
    this.SetCameraContext(stateContext, scriptInterface, n"setBodyCarryFriendlyContext ", value, skipCameraContextUpdate);
  }

  protected final func SetCameraContext(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, varName: CName, value: Bool, skipCameraContextUpdate: Bool) -> Void {
    let oldValue: Bool;
    if skipCameraContextUpdate {
      stateContext.SetPermanentBoolParameter(varName, value, true);
    } else {
      oldValue = stateContext.GetBoolParameter(varName, true);
      stateContext.SetPermanentBoolParameter(varName, value, true);
      if NotEquals(oldValue, value) {
        this.UpdateCameraContext(stateContext, scriptInterface);
      };
    };
  }

  protected final func SetStyle(style: gamePSMBodyCarryingStyle, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentIntParameter(this.m_styleName, EnumInt(style), true);
    this.EnableAnimSet(Equals(style, gamePSMBodyCarryingStyle.Strong), n"carry_strong", scriptInterface);
    this.EnableAnimSet(Equals(style, gamePSMBodyCarryingStyle.Friendly), n"carry_friendly", scriptInterface);
  }

  protected final func SetForcedStyle(style: gamePSMBodyCarryingStyle, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentIntParameter(this.m_forceStyleName, EnumInt(style), true);
    this.SetStyle(style, stateContext, scriptInterface);
  }

  protected final func ClearForcedStyle(stateContext: ref<StateContext>) -> Void {
    stateContext.RemovePermanentIntParameter(this.m_forceStyleName);
  }

  protected final func LockLeftHandAnimation(scriptInterface: ref<StateGameScriptInterface>, lockLeftHand: Bool) -> Void {
    this.m_leftHandFeature = new AnimFeature_LeftHandAnimation();
    this.m_leftHandFeature.lockLeftHandAnimation = lockLeftHand;
    scriptInterface.SetAnimationParameterFeature(n"LeftHandAnimation", this.m_leftHandFeature, scriptInterface.executionOwner);
  }

  protected final const func GetStyle(const stateContext: ref<StateContext>) -> gamePSMBodyCarryingStyle {
    return IntEnum(stateContext.GetIntParameter(this.m_styleName, true));
  }

  private final func EnableAnimSet(enable: Bool, animSet: CName, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ev: ref<AnimWrapperWeightSetter> = new AnimWrapperWeightSetter();
    ev.key = animSet;
    ev.value = enable ? 1.00 : 0.00;
    scriptInterface.owner.QueueEvent(ev);
    scriptInterface.executionOwner.QueueEvent(ev);
  }

  protected final func SetCarriedObjectInvulnerable(enable: Bool, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if enable && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.owner, t"BaseStatusEffect.Invulnerable") {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.owner, t"BaseStatusEffect.Invulnerable");
    } else {
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.owner, t"BaseStatusEffect.Invulnerable");
    };
  }

  protected final func CleanUpCarryState(state: ECarryState, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let mountingInfo: MountingInfo;
    let setPositionEvent: ref<SetBodyPositionEvent>;
    let unmountEvent: ref<UnmountingRequest> = new UnmountingRequest();
    mountingInfo.childId = scriptInterface.ownerEntityID;
    mountingInfo.parentId = scriptInterface.executionOwnerEntityID;
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    scriptInterface.GetMountingFacility().Unmount(unmountEvent);
    this.SetCarryState(state, 0, false, stateContext, scriptInterface);
    stateContext.RemovePermanentBoolParameter(n"checkCanShootWhileCarryingBodyStatFlag");
    stateContext.SetPermanentCNameParameter(n"ETakedownActionType", n"", true);
    this.LockLeftHandAnimation(scriptInterface, false);
    this.ResetMountingAnimFeature(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", false, true);
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Carrying, false);
    GetPlayer(scriptInterface.owner.GetGame()).QueueEvent(new DropBodyBreathingEvent());
    (scriptInterface.owner as NPCPuppet).MountingEndEnableComponents();
    (scriptInterface.owner as NPCPuppet).SetDisableRagdoll(false);
    this.RemoveGameplayRestrictions(scriptInterface);
    this.SetBodyPickUpCameraContext(stateContext, scriptInterface, false, true);
    this.SetBodyCarryCameraContext(stateContext, scriptInterface, false, true);
    this.SetBodyCarryFriendlyCameraContext(stateContext, scriptInterface, false, true);
    this.UpdateCameraContext(stateContext, scriptInterface);
    this.SetCarriedObjectInvulnerable(false, scriptInterface);
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.RemoveActiveStimuliByName(scriptInterface.executionOwner, gamedataStimType.CarryBody);
    };
    (scriptInterface.owner as NPCPuppet).GetVisibleObjectComponent().Toggle(true);
    setPositionEvent = new SetBodyPositionEvent();
    setPositionEvent.bodyPosition = scriptInterface.owner.GetWorldPosition();
    scriptInterface.owner.QueueEvent(setPositionEvent);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, EnumInt(gamePSMBodyCarrying.Default));
  }

  protected final func ResetMountingAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_animFeature = new AnimFeature_Mounting();
    this.m_animFeature.mountingState = 0;
    scriptInterface.SetAnimationParameterFeature(n"Mounting", this.m_animFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"Mounting", this.m_animFeature);
  }

  protected final func ApplyInitGameplayRestrictions(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoJump");
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingActionRestriction");
  }

  protected final func EvaluateAutomaticLootPickupFromMountedPuppet(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if (scriptInterface.owner as NPCPuppet).HasQuestItems() && !RPGManager.IsInventoryEmpty(scriptInterface.owner) {
      scriptInterface.GetTransactionSystem().TransferAllItems(scriptInterface.owner as NPCPuppet, scriptInterface.executionOwner);
    };
  }

  protected final func ApplyFriendlyCarryGameplayRestrictions(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingFriendly");
  }

  protected final func UpdateGameplayRestrictions(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.HasStatFlag(gamedataStatType.CanSprintWhileCarryingBody) && !this.m_isFriendlyCarry {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingCanSprint");
    } else {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingGeneric");
    };
  }

  protected final func RemoveGameplayRestrictions(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingFriendly");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingNoDrop");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingGeneric");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingCanSprint");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.BodyCarryingActionRestriction");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoJump");
  }

  protected final func DisableAndResetRagdoll(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.owner.QueueEvent(CreateDisableRagdollEvent());
    (scriptInterface.owner as NPCPuppet).SetDisableRagdoll(true);
  }

  protected final func EvaluateWeaponUnequipping(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if DefaultTransition.IsHeavyWeaponEquipped(scriptInterface) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipWeapon);
    } else {
      if UpperBodyTransition.HasAnyWeaponEquipped(scriptInterface) {
        stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", true, true);
      };
    };
  }

  protected final func EnableRagdoll(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    (scriptInterface.owner as NPCPuppet).SetDisableRagdoll(false, true);
    scriptInterface.owner.QueueEvent(CreateForceRagdollNoPowerPoseEvent(n"CarriedObject"));
  }

  protected final func EnableRagdollUncontrolledMovement(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<UncontrolledMovementStartEvent>;
    (scriptInterface.owner as NPCPuppet).SetDisableRagdoll(false, true);
    evt = new UncontrolledMovementStartEvent();
    evt.ragdollNoGroundThreshold = -1.00;
    evt.ragdollOnCollision = true;
    evt.DebugSetSourceName(n"CarriedObjectUncontrolledMovement");
    scriptInterface.owner.QueueEvent(evt);
  }
}

public class PickUpDecisions extends CarriedObject {

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !stateContext.GetConditionBool(n"CarriedObjectPlayPickUp") || this.GetInStateTime() > this.GetStaticFloatParameterDefault("durationTime", 1.00);
  }

  public final const func ToRelease(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !scriptInterface.owner.IsAttached();
  }
}

public class PickUpEvents extends CarriedObjectEvents {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let canUseFireArms: Bool;
    let setPositionEvent: ref<SetBodyPositionEvent>;
    let carriedObjectData: ref<CarriedObjectData> = this.stateMachineInstanceData.initData as CarriedObjectData;
    let body: EntityID = scriptInterface.ownerEntityID;
    let pickupAnimation: Int32 = 0;
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Carrying, true);
    switch this.GetTakedownAction(stateContext) {
      case ETakedownActionType.Takedown:
        pickupAnimation = 1;
        break;
      case ETakedownActionType.TakedownNonLethal:
        pickupAnimation = 2;
        break;
      case ETakedownActionType.AerialTakedown:
        pickupAnimation = 3;
        break;
      default:
        pickupAnimation = 0;
    };
    if this.IsPickUpFromVehicleTrunk(scriptInterface) {
      pickupAnimation = 4;
    };
    this.SetCarryState(ECarryState.Pickup, pickupAnimation, carriedObjectData.instant, stateContext, scriptInterface);
    canUseFireArms = scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileCarryingBody);
    if GameInstance.GetRuntimeInfo(scriptInterface.executionOwner.GetGame()).IsMultiplayer() {
      canUseFireArms = true;
    };
    this.ClearForcedStyle(stateContext);
    if NotEquals(this.m_forcedCarryStyle, gamePSMBodyCarryingStyle.Any) {
      this.SetForcedStyle(this.m_forcedCarryStyle, stateContext, scriptInterface);
    } else {
      if this.m_isFriendlyCarry {
        this.SetStyle(gamePSMBodyCarryingStyle.Friendly, stateContext, scriptInterface);
      } else {
        if canUseFireArms {
          this.SetStyle(gamePSMBodyCarryingStyle.Strong, stateContext, scriptInterface);
        } else {
          this.SetStyle(gamePSMBodyCarryingStyle.Default, stateContext, scriptInterface);
        };
      };
    };
    if NotEquals(this.GetStyle(stateContext), gamePSMBodyCarryingStyle.Friendly) {
      this.SetBodyPickUpCameraContext(stateContext, scriptInterface, true);
    };
    this.DisableAndResetRagdoll(stateContext, scriptInterface);
    this.EvaluateWeaponUnequipping(stateContext, scriptInterface);
    GetPlayer(scriptInterface.owner.GetGame()).QueueEvent(new PickUpBodyBreathingEvent());
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.AddActiveStimuli(scriptInterface.executionOwner, gamedataStimType.CarryBody, -1.00);
    };
    (scriptInterface.owner as NPCPuppet).GetVisibleObjectComponent().Toggle(false);
    setPositionEvent = new SetBodyPositionEvent();
    setPositionEvent.bodyPosition = scriptInterface.owner.GetWorldPosition();
    setPositionEvent.pickedUp = true;
    setPositionEvent.bodyPositionID = body;
    scriptInterface.owner.QueueEvent(setPositionEvent);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, EnumInt(gamePSMBodyCarrying.PickUp));
    this.ApplyInitGameplayRestrictions(scriptInterface);
    ScriptedPuppet.EvaluateApplyingStatusEffectsFromMountedObjectToPlayer(scriptInterface.owner, scriptInterface.executionOwner);
    this.EvaluateAutomaticLootPickupFromMountedPuppet(scriptInterface);
    this.SetCarriedObjectInvulnerable(true, scriptInterface);
  }

  private final func IsPickUpFromVehicleTrunk(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.owner, t"BaseStatusEffect.VehicleTrunkBodyPickup") {
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.owner, t"BaseStatusEffect.VehicleTrunkBodyPickup");
      return true;
    };
    return false;
  }
}

public class CarryDecisions extends CarriedObject {

  protected final const func IsPlayerAllowedToDropBody(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"BodyCarryingNoDrop") && !this.IsBodyDropForced(stateContext, scriptInterface) {
      return false;
    };
    if this.IsInInputContextState(stateContext, n"interactionContext") || this.IsInInputContextState(stateContext, n"uiRadialContext") {
      return false;
    };
    return true;
  }

  protected final const func IsBodyDropForced(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"BodyCarryingForceDrop") {
      return true;
    };
    return false;
  }

  protected final const func ToDrop(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isArmed: Bool = DefaultTransition.HasRightWeaponEquipped(scriptInterface);
    if !this.IsDoorInteractionActive(scriptInterface) {
      if !isArmed && this.GetActionHoldTime(stateContext, scriptInterface, n"DropCarriedObject") < 0.30 && stateContext.GetConditionFloat(n"InputHoldTime") < 0.30 && scriptInterface.IsActionJustReleased(n"DropCarriedObject") {
        return this.IsPlayerAllowedToDropBody(stateContext, scriptInterface);
      };
      if isArmed && scriptInterface.IsActionJustHeld(n"DropCarriedObject") {
        return this.IsPlayerAllowedToDropBody(stateContext, scriptInterface);
      };
    };
    if this.IsBodyDropForced(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToDispose(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.CarryingDisposal);
  }

  public final const func ToForceDropBody(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let player: ref<PlayerPuppet>;
    let shouldDropBody: StateResultBool = stateContext.GetTemporaryBoolParameter(n"bodyCarryInteractionForceDrop");
    if shouldDropBody.valid {
      return shouldDropBody.value;
    };
    player = DefaultTransition.GetPlayerPuppet(scriptInterface);
    if player.IsDead() {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Fall) == EnumInt(gamePSMFallStates.FastFall) {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown) {
      return true;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileCarryingBody) && !this.IsInUpperBodyState(stateContext, n"forceEmptyHands") && scriptInterface.GetActionValue(n"RangedAttack") > 0.00 {
      return this.IsPlayerAllowedToDropBody(stateContext, scriptInterface);
    };
    if this.IsInHighLevelState(stateContext, n"swimming") {
      return true;
    };
    if this.IsForceBodyDropRequested(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func IsForceBodyDropRequested(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isForceDropBody: StateResultBool = stateContext.GetTemporaryBoolParameter(n"forceDropBody");
    if isForceDropBody.valid && isForceDropBody.value {
      return true;
    };
    return false;
  }

  public final const func ToRelease(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !scriptInterface.owner.IsAttached();
  }
}

public class CarryEvents extends CarriedObjectEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetBodyPickUpCameraContext(stateContext, scriptInterface, false);
    if GameInstance.GetRuntimeInfo(scriptInterface.executionOwner.GetGame()).IsMultiplayer() || this.CanEquipFirearm(scriptInterface.executionOwner, stateContext) && Equals(this.GetStyle(stateContext), gamePSMBodyCarryingStyle.Strong) {
      stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", false, true);
    };
    if !this.m_isFriendlyCarry {
      this.SetBodyCarryCameraContext(stateContext, scriptInterface, true);
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoJump");
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, EnumInt(gamePSMBodyCarrying.Carry));
    this.SetCarryState(ECarryState.Carry, false, stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SyncJump(stateContext, scriptInterface);
    this.m_animFeature.parentSpeed = Vector4.Length(DefaultTransition.GetLinearVelocity(scriptInterface));
    scriptInterface.SetAnimationParameterFeature(n"Mounting", this.m_animFeature);
    this.RefreshCarryState(stateContext, scriptInterface);
  }

  private final func RefreshCarryState(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.m_isFriendlyCarry && scriptInterface.HasStatFlag(gamedataStatType.CanShootWhileCarryingBody) && !stateContext.GetBoolParameter(n"checkCanShootWhileCarryingBodyStatFlag", true) {
      this.UpdateGameplayRestrictions(stateContext, scriptInterface);
      if this.CanEquipFirearm(scriptInterface.executionOwner, stateContext) {
        stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", false, true);
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon);
        this.SetCarryState(ECarryState.Carry, false, stateContext, scriptInterface);
        stateContext.SetPermanentBoolParameter(n"checkCanShootWhileCarryingBodyStatFlag", true, true);
      };
    };
  }

  private final func SyncJump(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.IsInLocomotionState(stateContext, n"jump") && !stateContext.GetBoolParameter(n"playerJumped", true) {
      stateContext.SetPermanentBoolParameter(n"playerJumped", true, true);
      this.UpdatePuppetCarryState(ECarryState.Jump, stateContext, scriptInterface);
    } else {
      if scriptInterface.IsOnGround() && stateContext.GetBoolParameter(n"playerJumped", true) {
        this.UpdatePuppetCarryState(ECarryState.Carry, stateContext, scriptInterface);
        stateContext.RemovePermanentBoolParameter(n"playerJumped");
      };
    };
  }

  private final func UpdatePuppetCarryState(state: ECarryState, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_animCarryFeature = new AnimFeature_Carry();
    this.m_animCarryFeature.state = EnumInt(state);
    scriptInterface.SetAnimationParameterFeature(n"Carry", this.m_animCarryFeature, scriptInterface.owner);
  }
}

public class DropDecisions extends CarriedObject {

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("stateDuration", 1.50);
  }
}

public class DropEvents extends CarriedObjectEvents {

  public let m_ragdollReenabled: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.m_ragdollReenabled = false;
    stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", true, true);
    this.SetCarryState(ECarryState.Drop, false, stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, EnumInt(gamePSMBodyCarrying.Drop));
    scriptInterface.owner.QueueEvent(new RagdollRequestCollectAnimPoseEvent());
    this.EnableRagdollUncontrolledMovement(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.m_ragdollReenabled {
      if this.GetInStateTime() > this.GetStaticFloatParameterDefault("ragdollActivateTime", 1.00) {
        this.EnableRagdoll(stateContext, scriptInterface);
        this.m_ragdollReenabled = true;
      } else {
        if this.IsInLocomotionState(stateContext, n"crouch") && this.GetInStateTime() > this.GetStaticFloatParameterDefault("ragdollActivateTimeCrouch", 1.00) {
          this.EnableRagdoll(stateContext, scriptInterface);
          this.m_ragdollReenabled = true;
        };
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.m_ragdollReenabled {
      this.EnableRagdoll(stateContext, scriptInterface);
      this.m_ragdollReenabled = true;
    };
  }
}

public class DisposeDecisions extends CarriedObject {

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class DisposeEvents extends CarriedObjectEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, EnumInt(gamePSMBodyCarrying.Dispose));
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    (scriptInterface.owner as NPCPuppet).GetVisibleObjectComponent().Toggle(false);
  }
}

public class ForceDropBodyEvents extends CarriedObjectEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.EnableRagdoll(stateContext, scriptInterface);
    this.CleanUpCarryState(ECarryState.Release, stateContext, scriptInterface);
  }
}

public class ReleaseEvents extends CarriedObjectEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanUpCarryState(ECarryState.Release, stateContext, scriptInterface);
  }
}
