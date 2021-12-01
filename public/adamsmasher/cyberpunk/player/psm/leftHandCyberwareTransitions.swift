
public abstract class LeftHandCyberwareHelper extends IScriptable {

  public final static func EvaluateProjectileLauncherCooldown(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft") as WeaponObject;
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(weapon.GetGame());
    if IsDefined(weapon) && WeaponObject.IsOfType(weapon.GetItemID(), gamedataItemType.Cyb_Launcher) {
      if statPoolSystem.HasStatPoolValueReachedMin(Cast(weapon.GetEntityID()), gamedataStatPoolType.WeaponCharge) {
        LeftHandCyberwareHelper.ApplyProjectileLauncherCooldown(scriptInterface);
        return true;
      };
    };
    return false;
  }

  public final static func ApplyProjectileLauncherCooldown(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !LeftHandCyberwareHelper.IsProjectileLauncherInCooldown(scriptInterface) {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.ProjectileLauncherCooldown");
    };
  }

  public final static func IsProjectileLauncherInCooldown(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.ProjectileLauncherCooldown");
  }
}

public abstract class LeftHandCyberwareTransition extends DefaultTransition {

  protected final func SendAnimFeatureData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_LeftHandCyberware> = new AnimFeature_LeftHandCyberware();
    animFeature.actionDuration = stateContext.GetFloatParameter(n"actionDuration", true);
    animFeature.state = stateContext.GetIntParameter(n"state", true);
    animFeature.isQuickAction = stateContext.GetBoolParameter(n"isQuickAction", true);
    animFeature.isChargeAction = stateContext.GetBoolParameter(n"isChargeAction", true);
    animFeature.isLoopAction = stateContext.GetBoolParameter(n"isLoopAction", true);
    animFeature.isCatchAction = stateContext.GetBoolParameter(n"isCatchAction", true);
    animFeature.isSafeAction = stateContext.GetBoolParameter(n"isSafeAction", true);
    scriptInterface.SetAnimationParameterFeature(n"LeftHandCyberware", animFeature, scriptInterface.executionOwner);
  }

  protected final func SetLeftHandItemTypeAndState(scriptInterface: ref<StateGameScriptInterface>, type: Int32, state: Int32) -> Void {
    let itemHandling: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    itemHandling.itemType = type;
    itemHandling.itemState = state;
    scriptInterface.SetAnimationParameterFeature(n"leftHandItemHandling", itemHandling, scriptInterface.executionOwner);
  }

  protected final func LockLeftHandAnimation(scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let animFeature: ref<AnimFeature_LeftHandAnimation> = new AnimFeature_LeftHandAnimation();
    animFeature.lockLeftHandAnimation = newState;
    scriptInterface.SetAnimationParameterFeature(n"LeftHandAnimation", animFeature, scriptInterface.executionOwner);
  }

  protected final func SetAnimEquipState(scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let animFeature: ref<AnimFeature_LeftHandItem> = new AnimFeature_LeftHandItem();
    animFeature.itemInLeftHand = newState;
    scriptInterface.SetAnimationParameterFeature(n"LeftHandItem", animFeature, scriptInterface.executionOwner);
  }

  protected final const func GetProjectileTemplateNameFromWeaponDefinition(weaponTweak: TweakDBID) -> CName {
    return TweakDBInterface.GetCName(weaponTweak + t".projectileTemplateName", n"");
  }

  protected final const func GetEquipDuration(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    return scriptInterface.GetStatsSystem().GetStatValue(Cast(this.GetLeftHandWeaponObject(scriptInterface).GetEntityID()), gamedataStatType.EquipDuration);
  }

  protected final const func GetUnequipDuration(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    return scriptInterface.GetStatsSystem().GetStatValue(Cast(this.GetLeftHandWeaponObject(scriptInterface).GetEntityID()), gamedataStatType.UnequipDuration);
  }

  protected final const func LeftHandCyberwareHasTag(const scriptInterface: ref<StateGameScriptInterface>, tag: CName) -> Bool {
    let leftHandObject: wref<WeaponObject> = this.GetLeftHandWeaponObject(scriptInterface);
    if IsDefined(leftHandObject) {
      if scriptInterface.GetTransactionSystem().HasTag(scriptInterface.executionOwner, tag, leftHandObject.GetItemID()) {
        return true;
      };
    };
    return false;
  }

  protected final const func QuickwheelHasTag(const scriptInterface: ref<StateGameScriptInterface>, tag: CName) -> Bool {
    let itemID: ItemID = EquipmentSystem.GetData(scriptInterface.executionOwner).GetActiveItem(gamedataEquipmentArea.QuickWheel);
    return scriptInterface.GetTransactionSystem().HasTag(scriptInterface.owner, tag, itemID);
  }

  protected final const func GetLeftHandWeaponObject(const scriptInterface: ref<StateGameScriptInterface>) -> wref<WeaponObject> {
    let leftHandWpnObject: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft") as WeaponObject;
    return leftHandWpnObject;
  }

  public final func AttachAndPreviewProjectile(scriptInterface: ref<StateGameScriptInterface>, active: Bool) -> Void {
    let installedProjectile: ItemID;
    let previewEvent: ref<gameprojectileProjectilePreviewEvent>;
    let round: ref<ItemObject>;
    this.GetCurrentlyInstalledProjectile(scriptInterface, installedProjectile);
    if !IsDefined(round) {
      return;
    };
    previewEvent = new gameprojectileProjectilePreviewEvent();
    previewEvent.previewActive = active;
    round.QueueEvent(previewEvent);
  }

  public final func DetachProjectile(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let installedProjectile: ItemID;
    let projectileTemplateName: CName;
    let leftHandItemObj: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, RPGManager.GetAttachmentSlotID("WeaponLeft"));
    if !IsDefined(leftHandItemObj) {
      return;
    };
    this.GetCurrentlyInstalledProjectile(scriptInterface, installedProjectile);
    projectileTemplateName = TweakDBInterface.GetCName(ItemID.GetTDBID(installedProjectile) + t".projectileTemplateName", n"");
    ProjectileLaunchHelper.SpawnProjectileFromScreenCenter(scriptInterface.executionOwner, projectileTemplateName, leftHandItemObj);
  }

  protected final func DrainWeaponCharge(scriptInterface: ref<StateGameScriptInterface>, chargeValue: Float) -> Void {
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetLeftHandWeaponObject(scriptInterface).GetGame());
    if !statPoolSystem.IsStatPoolAdded(Cast(this.GetLeftHandWeaponObject(scriptInterface).GetEntityID()), gamedataStatPoolType.WeaponCharge) {
      return;
    };
    if chargeValue <= 0.00 {
      return;
    };
    statPoolSystem.RequestChangingStatPoolValue(Cast(this.GetLeftHandWeaponObject(scriptInterface).GetEntityID()), gamedataStatPoolType.WeaponCharge, -chargeValue, null, false, true);
  }

  protected final func GetWeaponChargeCost(scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let chargeCost: Float;
    let installedProjectile: ItemID;
    let stateName: CName;
    this.GetCurrentlyInstalledProjectile(scriptInterface, installedProjectile);
    stateName = this.GetStateName();
    switch stateName {
      case n"leftHandCyberwareQuickAction":
        chargeCost = TweakDBInterface.GetFloat(ItemID.GetTDBID(installedProjectile) + t".quickActionChargeCost", 25.00);
        break;
      case n"leftHandCyberwareChargeAction":
        chargeCost = TweakDBInterface.GetFloat(ItemID.GetTDBID(installedProjectile) + t".chargeActionChargeCost", 25.00);
        break;
      default:
        chargeCost = 25.00;
    };
    return chargeCost;
  }

  public final func GetCurrentlyInstalledProjectile(scriptInterface: ref<StateGameScriptInterface>, out installedProjectile: ItemID) -> Bool {
    let i: Int32;
    let partSlots: SPartSlots;
    let projectileLauncherRound: array<SPartSlots> = ItemModificationSystem.GetAllSlots(scriptInterface.executionOwner, this.GetLeftHandWeaponObject(scriptInterface).GetItemID());
    if ArraySize(projectileLauncherRound) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(projectileLauncherRound) {
      partSlots = projectileLauncherRound[i];
      if Equals(partSlots.status, ESlotState.Taken) && partSlots.slotID == t"AttachmentSlots.ProjectileLauncherRound" {
        installedProjectile = partSlots.installedPart;
      };
      i += 1;
    };
    return false;
  }

  protected final func SetAnimFeatureState(stateContext: ref<StateContext>, value: Int32) -> Void {
    stateContext.SetPermanentIntParameter(n"state", value, true);
  }

  protected final func SetActionDuration(stateContext: ref<StateContext>, value: Float) -> Void {
    stateContext.SetPermanentFloatParameter(n"actionDuration", value, true);
  }

  protected final func SetIsQuickAction(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isQuickAction", value, true);
  }

  protected final func SetIsCharging(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isChargeAction", value, true);
  }

  protected final func SetIsLooping(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isLoopAction", value, true);
  }

  protected final func SetIsCatching(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isCatchAction", value, true);
  }

  protected final func SetIsSafeAction(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isSafeAction", value, true);
  }

  protected final func SetIsProjectileCaught(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, value: Bool) -> Void {
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().LeftHandCyberware.ProjectileCaught, value);
  }

  protected final func ResetAnimFeatureParameters(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentFloatParameter(n"actionDuration", -1.00, true);
    stateContext.SetPermanentIntParameter(n"state", 0, true);
    stateContext.SetPermanentBoolParameter(n"isQuickAction", false, true);
    stateContext.SetPermanentBoolParameter(n"isChargeAction", false, true);
    stateContext.SetPermanentBoolParameter(n"isLoopAction", false, true);
    stateContext.SetPermanentBoolParameter(n"isCatchAction", false, true);
    stateContext.SetPermanentBoolParameter(n"isSafeAction", false, true);
  }

  protected final const func GetMaxActiveTime(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let equipmentSystem: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(scriptInterface.owner.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    return CyberwareUtility.GetMaxActiveTimeFromTweak(ItemID.GetTDBID(equipmentSystem.GetPlayerData(scriptInterface.executionOwner).GetActiveItem(gamedataEquipmentArea.QuickWheel)));
  }

  protected final const func ShouldInstantlyUnequipCyberware(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>) -> Bool {
    return !this.IsUsingCyberwareAllowed(stateContext, scriptInterface);
  }

  protected final const func IsUsingCyberwareAllowed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsNoCombatActionsForced(scriptInterface) {
      return false;
    };
    if this.IsUsingFirearmsForced(scriptInterface) {
      return false;
    };
    if this.IsUsingFistsForced(scriptInterface) {
      return false;
    };
    if this.IsUsingMeleeForced(scriptInterface) {
      return false;
    };
    if this.IsInLocomotionState(stateContext, n"superheroFall") {
      return false;
    };
    if this.IsInLocomotionState(stateContext, n"vault") {
      return false;
    };
    if this.IsInLocomotionState(stateContext, n"climb") {
      return false;
    };
    if this.IsInLadderState(stateContext) {
      return false;
    };
    if stateContext.IsStateMachineActive(n"Vehicle") {
      return false;
    };
    if stateContext.IsStateMachineActive(n"CarriedObject") {
      return false;
    };
    if stateContext.IsStateMachineActive(n"LocomotionSwimming") {
      return false;
    };
    if stateContext.IsStateMachineActive(n"LocomotionTakedown") {
      return false;
    };
    return true;
  }

  protected final func AimSnap(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    if IsDefined(targetingSystem) {
      targetingSystem.OnAimStartBegin(scriptInterface.executionOwner);
      targetingSystem.OnAimStartEnd(scriptInterface.executionOwner);
      targetingSystem.AimSnap(scriptInterface.executionOwner);
    };
  }

  protected final func EndAiming(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    if IsDefined(targetingSystem) {
      targetingSystem.OnAimStop(scriptInterface.executionOwner);
    };
  }
}

public abstract class LeftHandCyberwareEventsTransition extends LeftHandCyberwareTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.LockLeftHandAnimation(scriptInterface, true);
    this.SendAnimFeatureData(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendAnimFeatureData(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanUpLeftHandCyberwareState(stateContext, scriptInterface);
  }

  protected func CleanUpLeftHandCyberwareState(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.AttachAndPreviewProjectile(scriptInterface, false);
    this.SetLeftHandItemTypeAndState(scriptInterface, 0, 0);
    this.LockLeftHandAnimation(scriptInterface, false);
    this.SetIsCharging(stateContext, false);
    stateContext.RemovePermanentBoolParameter(n"forceTempUnequipWeapon");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.Default));
    this.SetAnimEquipState(scriptInterface, false);
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipLeftHandCyberware, gameEquipAnimationType.Instant);
    this.ResetAnimFeatureParameters(stateContext);
  }
}

public class LeftHandCyberwareSafeDecisions extends LeftHandCyberwareTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsSafeStateForced(stateContext, scriptInterface) {
      return true;
    };
    if (scriptInterface.executionOwner as PlayerPuppet).IsAimingAtFriendly() {
      return true;
    };
    if this.IsInVisionModeActiveState(stateContext, scriptInterface) && this.GetInStateTime() > 0.10 {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Stunned) {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 2.00) {
      return true;
    };
    return this.ShouldInstantlyUnequipCyberware(scriptInterface, stateContext);
  }
}

public class LeftHandCyberwareSafeEvents extends LeftHandCyberwareEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareReady");
    this.SetAnimFeatureState(stateContext, 1);
    this.SetIsSafeAction(stateContext, true);
    this.LockLeftHandAnimation(scriptInterface, true);
    this.SetActionDuration(stateContext, this.GetStaticFloatParameterDefault("stateDuration", 2.00));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.Safe));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsSafeAction(stateContext, false);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareEquipDecisions extends LeftHandCyberwareTransition {

  protected final const func ToLeftHandCyberwareCharge(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustHeld(n"UseCombatGadget") && this.LeftHandCyberwareHasTag(scriptInterface, n"ChargeAction") {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ShouldInstantlyUnequipCyberware(scriptInterface, stateContext);
  }
}

public class LeftHandCyberwareEquipEvents extends LeftHandCyberwareEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<LeftHandCyberwareEquippedEvent>;
    let dpadAction: ref<DPADActionPerformed> = new DPADActionPerformed();
    dpadAction.ownerID = scriptInterface.executionOwnerEntityID;
    dpadAction.action = EHotkey.RB;
    dpadAction.state = EUIActionState.STARTED;
    dpadAction.stateInt = EnumInt(dpadAction.state);
    dpadAction.successful = true;
    scriptInterface.GetUISystem().QueueEvent(dpadAction);
    evt = new LeftHandCyberwareEquippedEvent();
    scriptInterface.owner.QueueEvent(evt);
    this.ResetAnimFeatureParameters(stateContext);
    this.SetLeftHandItemTypeAndState(scriptInterface, 2, 2);
    this.ForceDisableVisionMode(stateContext);
    stateContext.SetTemporaryBoolParameter(n"InterruptAiming", true, true);
    if this.IsRightHandInEquippedState(stateContext) {
      stateContext.SetPermanentBoolParameter(n"forceTempUnequipWeapon", true, true);
    };
    this.SetAnimFeatureState(stateContext, 1);
    this.SetAnimEquipState(scriptInterface, true);
    this.LockLeftHandAnimation(scriptInterface, true);
    this.SetActionDuration(stateContext, this.GetEquipDuration(scriptInterface));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.Equipped));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareReady");
    this.OnExit(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareChargeDecisions extends LeftHandCyberwareTransition {

  protected final const func ToLeftHandCyberwareChargeAction(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustReleased(n"UseCombatGadget") || scriptInterface.IsActionJustPressed(n"RangedAttack") {
      return !(scriptInterface.executionOwner as PlayerPuppet).IsAimingAtFriendly();
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareWaitForUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustReleased(n"UseCombatGadget") || scriptInterface.IsActionJustPressed(n"RangedAttack") && (scriptInterface.executionOwner as PlayerPuppet).IsAimingAtFriendly() {
      return true;
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 1.00) && (this.GetCancelChargeButtonInput(scriptInterface) || scriptInterface.IsActionJustPressed(n"SwitchItem")) {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown) {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ShouldInstantlyUnequipCyberware(scriptInterface, stateContext);
  }
}

public class LeftHandCyberwareChargeEvents extends LeftHandCyberwareEventsTransition {

  private let m_chargeModeAim: ref<AnimFeature_AimPlayer>;

  private let m_leftHandObject: wref<WeaponObject>;

  protected final func UpdateChargeModeCameraAimAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !IsDefined(this.m_chargeModeAim) {
      this.m_chargeModeAim = new AnimFeature_AimPlayer();
    };
    this.m_chargeModeAim.SetAimState(animAimState.Aimed);
    this.m_chargeModeAim.SetZoomState(animAimState.Aimed);
    this.m_chargeModeAim.SetAimInTime(scriptInterface.GetStatsSystem().GetStatValue(Cast(this.m_leftHandObject.GetEntityID()), gamedataStatType.AimInTime));
    this.m_chargeModeAim.SetAimOutTime(scriptInterface.GetStatsSystem().GetStatValue(Cast(this.m_leftHandObject.GetEntityID()), gamedataStatType.AimOutTime));
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_chargeModeAim);
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_chargeModeAim, this.m_leftHandObject);
  }

  protected final func ResetChargeModeCameraAimAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_chargeModeAim.SetAimState(animAimState.Unaimed);
    this.m_chargeModeAim.SetZoomState(animAimState.Unaimed);
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_chargeModeAim);
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_chargeModeAim, this.m_leftHandObject);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateChargeModeCameraAimAnimFeature(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let chargeEvt: ref<ChargeStartedEvent> = new ChargeStartedEvent();
    scriptInterface.owner.QueueEvent(chargeEvt);
    this.m_leftHandObject = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft") as WeaponObject;
    this.AimSnap(scriptInterface);
    this.SetZoomStateAnimFeature(scriptInterface, true);
    this.SetActionDuration(stateContext, this.GetStaticFloatParameterDefault("stateDuration", 1.00));
    this.SetIsCharging(stateContext, true);
    this.SetAnimFeatureState(stateContext, 2);
    this.AttachAndPreviewProjectile(scriptInterface, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.Charge));
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let chargeEvt: ref<ChargeEndedEvent> = new ChargeEndedEvent();
    scriptInterface.owner.QueueEvent(chargeEvt);
    this.ResetChargeModeCameraAimAnimFeature(stateContext, scriptInterface);
    this.SetZoomStateAnimFeature(scriptInterface, false);
    this.AttachAndPreviewProjectile(scriptInterface, false);
    this.EndAiming(scriptInterface);
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetChargeModeCameraAimAnimFeature(stateContext, scriptInterface);
    this.SetZoomStateAnimFeature(scriptInterface, false);
    this.AttachAndPreviewProjectile(scriptInterface, false);
    this.EndAiming(scriptInterface);
    this.OnForcedExit(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareLoopDecisions extends LeftHandCyberwareTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"UseCombatGadget") == 0.00 && this.LeftHandCyberwareHasTag(scriptInterface, n"LoopAction") {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareWaitForUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"UseCombatGadget") {
      return true;
    };
    if stateContext.GetBoolParameter(n"InterruptLeftHandAction") {
      return true;
    };
    if this.GetMaxActiveTime(scriptInterface) > 0.00 && this.GetInStateTime() > this.GetMaxActiveTime(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ShouldInstantlyUnequipCyberware(scriptInterface, stateContext);
  }
}

public class LeftHandCyberwareLoopEvents extends LeftHandCyberwareEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<LoopStartedEvent> = new LoopStartedEvent();
    scriptInterface.owner.QueueEvent(evt);
    this.SetActionDuration(stateContext, this.GetStaticFloatParameterDefault("stateDuration", 1.00));
    this.SetAnimFeatureState(stateContext, 2);
    this.SetIsLooping(stateContext, true);
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareLoopAction");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.Loop));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<LoopEndedEvent> = new LoopEndedEvent();
    scriptInterface.owner.QueueEvent(evt);
    this.SetIsLooping(stateContext, false);
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareLoopActionEnd");
    this.OnExit(stateContext, scriptInterface);
  }
}

public abstract class LeftHandCyberwareActionAbstractDecisions extends LeftHandCyberwareTransition {

  protected final const func ToLeftHandCyberwareWaitForUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"InterruptLeftHandAction") {
      return true;
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 1.00) {
      return true;
    };
    return false;
  }
}

public abstract class LeftHandCyberwareActionAbstractEvents extends LeftHandCyberwareEventsTransition {

  @default(LeftHandCyberwareActionAbstractEvents, false)
  public let m_projectileReleased: Bool;

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("projectileDetachDelay", 0.00) && !this.m_projectileReleased {
      this.DetachProjectile(scriptInterface);
      this.m_projectileReleased = true;
    };
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dpadAction: ref<DPADActionPerformed> = new DPADActionPerformed();
    dpadAction.ownerID = scriptInterface.executionOwnerEntityID;
    dpadAction.action = EHotkey.RB;
    dpadAction.state = EUIActionState.COMPLETED;
    dpadAction.stateInt = EnumInt(dpadAction.state);
    dpadAction.successful = true;
    scriptInterface.GetUISystem().QueueEvent(dpadAction);
    this.m_projectileReleased = false;
    this.SetActionDuration(stateContext, this.GetStaticFloatParameterDefault("stateDuration", 1.00));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareQuickActionDecisions extends LeftHandCyberwareActionAbstractDecisions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"UseCombatGadget") == 0.00 && this.LeftHandCyberwareHasTag(scriptInterface, n"QuickAction") {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"InterruptLeftHandAction") {
      return true;
    };
    if this.GetInStateTime() >= this.GetEquipDuration(scriptInterface) {
      return true;
    };
    return this.ShouldInstantlyUnequipCyberware(scriptInterface, stateContext);
  }
}

public class LeftHandCyberwareQuickActionEvents extends LeftHandCyberwareActionAbstractEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<QuickActionEvent> = new QuickActionEvent();
    this.SetActionDuration(stateContext, this.GetEquipDuration(scriptInterface));
    this.AttachAndPreviewProjectile(scriptInterface, true);
    this.AimSnap(scriptInterface);
    this.SetIsQuickAction(stateContext, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.QuickAction));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.DrainWeaponCharge(scriptInterface, this.GetWeaponChargeCost(scriptInterface));
    scriptInterface.owner.QueueEvent(evt);
    DefaultTransition.PlayRumble(scriptInterface, "light_fast");
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.EndAiming(scriptInterface);
    this.AttachAndPreviewProjectile(scriptInterface, false);
    this.SetIsQuickAction(stateContext, false);
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.EndAiming(scriptInterface);
    this.OnForcedExit(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareChargeActionDecisions extends LeftHandCyberwareActionAbstractDecisions {

  protected final const func ToLeftHandCyberwareUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"InterruptLeftHandAction") {
      return true;
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 0.30) {
      return true;
    };
    return this.ShouldInstantlyUnequipCyberware(scriptInterface, stateContext);
  }
}

public class LeftHandCyberwareChargeActionEvents extends LeftHandCyberwareActionAbstractEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.ChargeAction));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.DrainWeaponCharge(scriptInterface, this.GetWeaponChargeCost(scriptInterface));
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareChargeAction");
    DefaultTransition.PlayRumble(scriptInterface, "heavy_pulse");
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareCatchActionEvents extends LeftHandCyberwareActionAbstractEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.CatchAction));
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareCatchAction");
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareCatchDecisions extends LeftHandCyberwareTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"CatchMonodisc", true) {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareWaitForUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"InterruptLeftHandAction") {
      return true;
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 1.20) {
      return true;
    };
    return false;
  }

  protected final const func ToLeftHandCyberwareCatchAction(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetConditionBool(n"LeftHandCyberwareCatchButtonPressed") && !stateContext.GetConditionBool(n"LeftHandCyberwareCatchWindowMissed");
  }
}

public class LeftHandCyberwareCatchEvents extends LeftHandCyberwareEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetConditionBoolParameter(n"LeftHandCyberwareCatchButtonPressed", false, true);
    stateContext.SetConditionBoolParameter(n"LeftHandCyberwareCatchWindowMissed", false, true);
    this.SetIsCatching(stateContext, true);
    this.SetAnimFeatureState(stateContext, 3);
    this.LockLeftHandAnimation(scriptInterface, true);
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareReady");
    stateContext.SetPermanentBoolParameter(n"CatchMonodisc", false, true);
    stateContext.SetTemporaryBoolParameter(n"DisableWeaponUI", true, true);
    this.SetIsProjectileCaught(stateContext, scriptInterface, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.Catch));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsCatching(stateContext, false);
    this.SetIsProjectileCaught(stateContext, scriptInterface, false);
    this.OnExit(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let inStateTime: Float = this.GetInStateTime();
    let throwWindowStart: Float = this.GetStaticFloatParameterDefault("throwWindowStart", 0.35);
    let throwWindowEnd: Float = this.GetStaticFloatParameterDefault("throwWindowEnd", -1.00);
    if scriptInterface.IsActionJustPressed(n"UseCombatGadget") {
      if !stateContext.GetConditionBool(n"LeftHandCyberwareCatchButtonPressed") || !this.GetStaticBoolParameterDefault("preventButtonSpamming", false) {
        stateContext.SetConditionBoolParameter(n"LeftHandCyberwareCatchButtonPressed", true, true);
      };
    };
    if throwWindowStart >= 0.00 && inStateTime < throwWindowStart {
      if stateContext.GetConditionBool(n"LeftHandCyberwareCatchButtonPressed") {
        stateContext.SetConditionBoolParameter(n"LeftHandCyberwareCatchWindowMissed", true, true);
      };
    };
    if throwWindowEnd >= 0.00 && inStateTime > throwWindowEnd {
      if stateContext.GetConditionBool(n"LeftHandCyberwareCatchButtonPressed") {
        stateContext.SetConditionBoolParameter(n"LeftHandCyberwareCatchWindowMissed", true, true);
      };
    };
  }
}

public class LeftHandCyberwareWaitForUnequipDecisions extends LeftHandCyberwareTransition {

  protected final const func ToLeftHandCyberwareUnequip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= this.GetUnequipDuration(scriptInterface) {
      return true;
    };
    return this.ShouldInstantlyUnequipCyberware(scriptInterface, stateContext);
  }
}

public class LeftHandCyberwareWaitForUnequipEvents extends LeftHandCyberwareEventsTransition {

  public final func OnEnterFromLeftHandCyberwareCharge(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dpadAction: ref<DPADActionPerformed> = new DPADActionPerformed();
    dpadAction.ownerID = scriptInterface.executionOwnerEntityID;
    dpadAction.action = EHotkey.RB;
    dpadAction.state = EUIActionState.ABORTED;
    dpadAction.stateInt = EnumInt(dpadAction.state);
    dpadAction.successful = false;
    scriptInterface.GetUISystem().QueueEvent(dpadAction);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetActionDuration(stateContext, this.GetUnequipDuration(scriptInterface));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.StartUnequip));
    scriptInterface.PushAnimationEvent(n"LeftHandCyberwareWaitForUnequip");
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
  }
}

public class LeftHandCyberwareUnequipEvents extends LeftHandCyberwareEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let evt: ref<LeftHandCyberwareUnequippedEvent> = new LeftHandCyberwareUnequippedEvent();
    scriptInterface.owner.QueueEvent(evt);
    this.CleanUpLeftHandCyberwareState(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware, EnumInt(gamePSMLeftHandCyberware.Unequip));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    LeftHandCyberwareHelper.EvaluateProjectileLauncherCooldown(scriptInterface);
  }
}
