
public abstract class MeleeTransition extends DefaultTransition {

  public final static func GetMeleeAttackCooldownName() -> CName {
    return n"MeleeAttackCooldown";
  }

  public final static func GetHoldEnterDuration(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    return scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.HoldEnterDuration);
  }

  protected final const func IsBlockPressed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"MeleeBlock");
  }

  protected final const func IsBlockHeld(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"MeleeBlock") > 0.50;
  }

  public final static func LightMeleeAttackPressed(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"MeleeLightAttack");
  }

  protected final const func LightMeleeAttackReleased(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustReleased(n"MeleeLightAttack");
  }

  public final static func MeleeAttackPressed(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"MeleeAttack");
  }

  public final static func MeleeAttackReleased(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustReleased(n"MeleeAttack");
  }

  protected final const func QuickMeleePressed(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"QuickMelee");
  }

  protected final const func QuickMeleeHeld(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustHeld(n"QuickMelee");
  }

  protected final const func QuickMeleeReleased(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustReleased(n"QuickMelee");
  }

  public final static func StrongMeleeAttackPressed(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"MeleeStrongAttack");
  }

  public final static func StrongMeleeAttackReleased(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustReleased(n"MeleeStrongAttack");
  }

  public final static func AnyMeleeAttack(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"MeleeAttack") > 0.00 {
      return true;
    };
    if scriptInterface.GetActionValue(n"MeleeLightAttack") > 0.00 {
      return true;
    };
    if scriptInterface.GetActionValue(n"MeleeHeavyAttack") > 0.00 {
      return true;
    };
    if scriptInterface.GetActionValue(n"QuickMelee") > 0.00 {
      return true;
    };
    return false;
  }

  public final static func GetAimAssistMeleeRecord(const scriptInterface: ref<StateGameScriptInterface>) -> ref<AimAssistMelee_Record> {
    let aimAssistRecord: ref<AimAssistConfigPreset_Record> = null;
    let record: ref<AimAssistMelee_Record> = null;
    let aimAsisstRecordId: TweakDBID = scriptInterface.GetTargetingSystem().GetAimAssistConfig(scriptInterface.executionOwner);
    aimAssistRecord = TweakDBInterface.GetAimAssistConfigPresetRecord(aimAsisstRecordId);
    if IsDefined(aimAssistRecord) {
      record = aimAssistRecord.MeleeParams();
    };
    return record;
  }

  public final static func AnyMeleeAttackPressed(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return MeleeTransition.MeleeAttackPressed(scriptInterface) || MeleeTransition.LightMeleeAttackPressed(scriptInterface) || MeleeTransition.StrongMeleeAttackPressed(scriptInterface);
  }

  public final static func NoMeleeAttack(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"MeleeAttack") > 0.00 {
      return false;
    };
    if scriptInterface.GetActionValue(n"MeleeLightAttack") > 0.00 {
      return false;
    };
    if scriptInterface.GetActionValue(n"MeleeStrongAttack") > 0.00 {
      return false;
    };
    return true;
  }

  protected final const func NoStrongAttackPressed(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"MeleeAttack") > 0.00 {
      return false;
    };
    if scriptInterface.GetActionValue(n"MeleeStrongAttack") > 0.00 {
      return false;
    };
    return true;
  }

  protected final const func ShouldHold(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, opt skipDurationCheck: Bool, opt skipPressCount: Bool) -> Bool {
    if stateContext.GetConditionBool(n"StrongMeleeAttackPressed") {
      return true;
    };
    if skipPressCount || MeleeTransition.CheckMeleeAttackPressCount(stateContext, scriptInterface) {
      if scriptInterface.GetActionValue(n"MeleeStrongAttack") > 0.00 {
        return true;
      };
      if scriptInterface.GetActionValue(n"MeleeAttack") > 0.50 && (skipDurationCheck || scriptInterface.GetActionStateTime(n"MeleeAttack") >= MeleeTransition.GetHoldEnterDuration(scriptInterface)) {
        return true;
      };
    };
    return false;
  }

  public final static func CheckMeleeAttackPressCount(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let lastChargePressCount: StateResultInt;
    let actionPressCount: Uint32 = scriptInterface.GetActionPressCount(n"MeleeAttack");
    actionPressCount += scriptInterface.GetActionPressCount(n"MeleeLightAttack");
    actionPressCount += scriptInterface.GetActionPressCount(n"MeleeStrongAttack");
    lastChargePressCount = stateContext.GetPermanentIntParameter(n"LastMeleePressCount");
    if lastChargePressCount.valid && lastChargePressCount.value == Cast(actionPressCount) {
      return false;
    };
    return true;
  }

  protected final func SetMeleeAttackPressCount(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let actionPressCount: Uint32 = scriptInterface.GetActionPressCount(n"MeleeAttack");
    actionPressCount += scriptInterface.GetActionPressCount(n"MeleeLightAttack");
    actionPressCount += scriptInterface.GetActionPressCount(n"MeleeStrongAttack");
    stateContext.SetPermanentIntParameter(n"LastMeleePressCount", Cast(actionPressCount), true);
  }

  protected final func ClearMeleePressCount(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentIntParameter(n"LastMeleePressCount", 0, true);
  }

  public final static func WantsToStrongAttack(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      return false;
    };
    if stateContext.GetConditionBool(n"StrongMeleeAttackPressed") {
      return true;
    };
    if MeleeTransition.CheckMeleeAttackPressCount(stateContext, scriptInterface) {
      if MeleeTransition.StrongMeleeAttackReleased(scriptInterface) {
        return true;
      };
      if MeleeTransition.MeleeAttackReleased(scriptInterface) && scriptInterface.GetActionPrevStateTime(n"MeleeAttack") > MeleeTransition.GetHoldEnterDuration(scriptInterface) {
        return true;
      };
    };
    return false;
  }

  public final static func WantsToLightAttack(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      return false;
    };
    if stateContext.GetConditionBool(n"LightMeleeAttackPressed") {
      return true;
    };
    if MeleeTransition.CheckMeleeAttackPressCount(stateContext, scriptInterface) {
      if MeleeTransition.MeleeAttackReleased(scriptInterface) {
        return true;
      };
      if MeleeTransition.LightMeleeAttackPressed(scriptInterface) {
        return true;
      };
    };
    return false;
  }

  protected final const func ShouldInterruptHoldStates(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let interruptEvent: StateResultBool;
    if !this.IsWeaponReady(stateContext, scriptInterface) {
      return true;
    };
    if this.IsAttackParried(stateContext, scriptInterface) {
      return true;
    };
    if this.IsSafeStateForced(stateContext, scriptInterface) {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) && !DefaultTransition.IsInRpgContext(scriptInterface) {
      return true;
    };
    interruptEvent = stateContext.GetPermanentBoolParameter(n"InterruptMelee");
    if interruptEvent.value {
      return true;
    };
    return false;
  }

  public final static func UpdateMeleeInputBuffer(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, opt onlyLightMeleeAttack: Bool) -> Void {
    if MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      MeleeTransition.ClearInputBuffer(stateContext);
      return;
    };
    if onlyLightMeleeAttack {
      if MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) || MeleeTransition.WantsToStrongAttack(stateContext, scriptInterface) {
        stateContext.SetConditionBoolParameter(n"StrongMeleeAttackPressed", false, true);
        stateContext.SetConditionBoolParameter(n"LightMeleeAttackPressed", true, true);
      };
      return;
    };
    if MeleeTransition.WantsToStrongAttack(stateContext, scriptInterface) {
      stateContext.SetConditionBoolParameter(n"StrongMeleeAttackPressed", true, true);
      stateContext.SetConditionBoolParameter(n"LightMeleeAttackPressed", false, true);
    } else {
      if MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) {
        stateContext.SetConditionBoolParameter(n"StrongMeleeAttackPressed", false, true);
        stateContext.SetConditionBoolParameter(n"LightMeleeAttackPressed", true, true);
      };
    };
  }

  public final static func ClearInputBuffer(stateContext: ref<StateContext>) -> Void {
    stateContext.SetConditionBoolParameter(n"LightMeleeAttackPressed", false, true);
    stateContext.SetConditionBoolParameter(n"StrongMeleeAttackPressed", false, true);
  }

  protected final const func EquipAttackCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsRightHandInUnequippingState(stateContext) {
      return false;
    };
    if !this.CheckItemType(scriptInterface, gamedataItemType.Wea_Katana) {
      return false;
    };
    if scriptInterface.IsActionJustHeld(n"MeleeAttack") {
      return true;
    };
    return false;
  }

  protected final const func CheckItemType(const scriptInterface: ref<StateGameScriptInterface>, const itemType: gamedataItemType) -> Bool {
    let currentItemType: gamedataItemType;
    if !DefaultTransition.GetWeaponItemType(scriptInterface, MeleeTransition.GetWeaponObject(scriptInterface), currentItemType) || NotEquals(currentItemType, itemType) {
      return false;
    };
    return true;
  }

  public final static func MeleeSprintStateCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Melee) == EnumInt(gamePSMMelee.Block) {
      return false;
    };
    if !stateContext.GetBoolParameter(n"canSprintWhileCharging", true) && Equals(stateContext.GetStateMachineCurrentState(n"Melee"), n"meleeChargedHold") {
      return false;
    };
    if stateContext.GetBoolParameter(n"isAttacking", true) {
      return false;
    };
    if !DefaultTransition.HasMeleeWeaponEquipped(scriptInterface) {
      return true;
    };
    return true;
  }

  public final static func MeleeUseExplorationCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Melee) == EnumInt(gamePSMMelee.Block) {
      return false;
    };
    if Equals(stateContext.GetStateMachineCurrentState(n"Melee"), n"meleeChargedHold") {
      return false;
    };
    if stateContext.GetBoolParameter(n"isAttacking", true) {
      return false;
    };
    if !DefaultTransition.HasMeleeWeaponEquipped(scriptInterface) {
      return true;
    };
    return true;
  }

  protected final func IncrementAttackNumber(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let attacksNumber: Int32;
    let currentValue: StateResultInt = stateContext.GetPermanentIntParameter(n"meleeAttackNumber");
    let value: Int32 = currentValue.value;
    value += 1;
    attacksNumber = Cast(scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.AttacksNumber));
    if value >= attacksNumber {
      if this.CheckIfInfiniteCombo(stateContext, scriptInterface) {
        value = 1;
      } else {
        value = 0;
      };
    };
    this.SetAttackNumber(stateContext, value);
  }

  protected final func IncrementTotalComboAttackNumber(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let currentValue: StateResultInt = stateContext.GetPermanentIntParameter(n"totalMeleeAttacksInCombo");
    let value: Int32 = currentValue.value;
    value += 1;
    stateContext.SetPermanentIntParameter(n"totalMeleeAttacksInCombo", value, true);
  }

  protected final const func CheckIfFinalAttack(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>) -> Bool {
    let attacksNumber: Int32;
    let currentValue: StateResultInt;
    let value: Int32;
    if this.CheckIfInfiniteCombo(stateContext, scriptInterface) {
      return false;
    };
    currentValue = stateContext.GetPermanentIntParameter(n"meleeAttackNumber");
    value = currentValue.value + 1;
    attacksNumber = Cast(scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.AttacksNumber));
    return value >= attacksNumber;
  }

  protected final const func CheckIfInfiniteCombo(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.HasWeaponStatFlag(scriptInterface, gamedataStatType.CanWeaponInfinitlyCombo) {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanMeleeInfinitelyCombo) {
      return false;
    };
    return true;
  }

  protected final func ResetAttackNumber(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentIntParameter(n"meleeAttackNumber", 0, true);
    stateContext.SetPermanentIntParameter(n"totalMeleeAttacksInCombo", 0, true);
  }

  protected final func SetAttackNumber(stateContext: ref<StateContext>, value: Int32) -> Void {
    stateContext.SetPermanentIntParameter(n"meleeAttackNumber", value, true);
  }

  protected final func SetCanSprintWhileCharging(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"canSprintWhileCharging", value, true);
  }

  protected final func SetIsAttacking(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isAttacking", value, true);
  }

  protected final func SetIsBlocking(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isBlocking", value, true);
  }

  protected final func SetIsParried(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isParried", value, true);
  }

  protected final func SetIsTargeting(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isTargeting", value, true);
  }

  protected final func SetIsHolding(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isHolding", value, true);
  }

  protected final func SetIsSafe(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"isSafe", value, true);
  }

  protected final const func ApplyThrowAttackGameplayRestrictions(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoRadialMenus");
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FirearmsNoUnequipNoSwitch");
  }

  protected final const func RemoveAllMeleeGameplayRestrictions(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveThrowAttackGameplayRestrictions(stateContext, scriptInterface);
  }

  protected final const func RemoveThrowAttackGameplayRestrictions(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoRadialMenus");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.FirearmsNoUnequipNoSwitch");
  }

  protected final const func IsWeaponReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isTakedown: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Grapple) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Leap) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Takedown);
    let isInFocusMode: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
    let isUsingCombatGadget: Bool = stateContext.IsStateMachineActive(n"CombatGadget");
    if this.IsNoCombatActionsForced(scriptInterface) {
      return false;
    };
    if stateContext.IsStateMachineActive(n"Consumable") || stateContext.IsStateMachineActive(n"CombatGadget") {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Stunned) {
      return false;
    };
    if !this.IsRightHandInEquippedState(stateContext) {
      return false;
    };
    if MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      return false;
    };
    if isInFocusMode && !DefaultTransition.IsInRpgContext(scriptInterface) {
      return false;
    };
    if isUsingCombatGadget {
      return false;
    };
    if isTakedown {
      return false;
    };
    return true;
  }

  protected final const func HasWeaponStatFlag(const scriptInterface: ref<StateGameScriptInterface>, flag: gamedataStatType) -> Bool {
    let flagOn: Bool = scriptInterface.GetStatsSystem().GetStatBoolValue(Cast(scriptInterface.ownerEntityID), flag);
    return flagOn;
  }

  protected final func DrawDebugText(scriptInterface: ref<StateGameScriptInterface>, out textLayerId: Uint32, text: String) -> Void {
    textLayerId = GameInstance.GetDebugVisualizerSystem(scriptInterface.GetGame()).DrawText(new Vector4(500.00, 550.00, 0.00, 0.00), text, gameDebugViewETextAlignment.Left, new Color(255u, 255u, 0u, 255u));
    GameInstance.GetDebugVisualizerSystem(scriptInterface.GetGame()).SetScale(textLayerId, new Vector4(1.00, 1.00, 0.00, 0.00));
  }

  protected final func ClearDebugText(scriptInterface: ref<StateGameScriptInterface>, textLayerId: Uint32) -> Void {
    GameInstance.GetDebugVisualizerSystem(scriptInterface.GetGame()).ClearLayer(textLayerId);
  }

  protected final func GetPerfectAimSnapParams() -> AimRequest {
    let aimSnapParams: AimRequest;
    aimSnapParams.duration = 0.33;
    aimSnapParams.adjustPitch = true;
    aimSnapParams.adjustYaw = true;
    aimSnapParams.endOnAimingStopped = true;
    aimSnapParams.precision = 0.10;
    aimSnapParams.easeIn = true;
    aimSnapParams.easeOut = true;
    aimSnapParams.checkRange = true;
    aimSnapParams.processAsInput = true;
    aimSnapParams.bodyPartsTracking = true;
    aimSnapParams.bptMaxDot = 0.50;
    aimSnapParams.bptMaxSwitches = -1.00;
    aimSnapParams.bptMinInputMag = 0.50;
    aimSnapParams.bptMinResetInputMag = 0.10;
    return aimSnapParams;
  }

  protected final func GetBlockLookAtParams() -> AimRequest {
    let aimSnapParams: AimRequest;
    aimSnapParams.duration = 30.00;
    aimSnapParams.adjustPitch = true;
    aimSnapParams.adjustYaw = true;
    aimSnapParams.endOnAimingStopped = false;
    aimSnapParams.precision = 0.10;
    aimSnapParams.easeIn = true;
    aimSnapParams.easeOut = true;
    aimSnapParams.checkRange = true;
    aimSnapParams.processAsInput = true;
    aimSnapParams.bodyPartsTracking = false;
    aimSnapParams.bptMaxDot = 0.50;
    aimSnapParams.bptMaxSwitches = -1.00;
    aimSnapParams.bptMinInputMag = 0.50;
    aimSnapParams.bptMinResetInputMag = 0.10;
    return aimSnapParams;
  }

  protected final func SendAnimFeatureData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_MeleeData> = new AnimFeature_MeleeData();
    animFeature.attackType = stateContext.GetIntParameter(n"attackType", true);
    animFeature.attackNumber = stateContext.GetIntParameter(n"meleeAttackNumber", true);
    animFeature.attackSpeed = stateContext.GetFloatParameter(n"attackSpeed", true);
    animFeature.hasDeflectAnim = stateContext.GetBoolParameter(n"hasDeflectAnim", true);
    animFeature.hasHitAnim = stateContext.GetBoolParameter(n"hasHitAnim", true);
    let weaponObject: ref<WeaponObject> = MeleeTransition.GetWeaponObject(scriptInterface);
    animFeature.isAttacking = stateContext.GetBoolParameter(n"isAttacking", true);
    animFeature.isTargeting = stateContext.GetBoolParameter(n"isTargeting", true);
    animFeature.isBlocking = stateContext.GetBoolParameter(n"isBlocking", true);
    animFeature.isParried = stateContext.GetBoolParameter(n"isParried", true);
    animFeature.isHolding = stateContext.GetBoolParameter(n"isHolding", true);
    animFeature.shouldHandsDisappear = weaponObject.HasTag(n"Cyberware");
    animFeature.keepRenderPlane = weaponObject.HasTag(n"KeepRenderPlane");
    animFeature.isSafe = stateContext.GetBoolParameter(n"isSafe", true);
    animFeature.isMeleeWeaponEquipped = true;
    scriptInterface.SetAnimationParameterFeature(n"MeleeData", animFeature);
  }

  protected final func DisableNanoWireIK(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateNanoWireEndPositionAnimFeature(scriptInterface, n"ikRightNanoWire", false);
    this.UpdateNanoWireEndPositionAnimFeature(scriptInterface, n"ikLeftNanoWire", false);
  }

  protected final func UpdateNanoWireEndPositionAnimFeature(scriptInterface: ref<StateGameScriptInterface>, animFeatureName: CName, enable: Bool, opt setPosition: Bool, opt slotPosition: Vector4) -> Void {
    let animFeature: ref<AnimFeature_SimpleIkSystem> = new AnimFeature_SimpleIkSystem();
    animFeature.isEnable = enable;
    animFeature.setPosition = setPosition;
    animFeature.position = slotPosition;
    scriptInterface.SetAnimationParameterFeature(animFeatureName, animFeature);
  }

  protected final func GetMeleeMovementDirection(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> meleeMoveDirection {
    let direction: meleeMoveDirection;
    let currentYaw: Float = DefaultTransition.GetYawMovementDirection(stateContext, scriptInterface);
    if currentYaw >= -45.00 && currentYaw <= 45.00 {
      direction = meleeMoveDirection.Forward;
    } else {
      if currentYaw > 45.00 && currentYaw < 135.00 {
        direction = meleeMoveDirection.Right;
      } else {
        if currentYaw >= 135.00 && currentYaw <= 180.00 || currentYaw <= -135.00 && currentYaw >= -180.00 {
          direction = meleeMoveDirection.Back;
        } else {
          if currentYaw > -135.00 && currentYaw < -45.00 {
            direction = meleeMoveDirection.Left;
          };
        };
      };
    };
    return direction;
  }

  public final static func GetWeaponObject(const scriptInterface: ref<StateGameScriptInterface>) -> ref<WeaponObject> {
    let owner: ref<GameObject> = scriptInterface.owner;
    let weapon: ref<WeaponObject> = owner as WeaponObject;
    return weapon;
  }

  protected final const func GetAttackDataFromStateName(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, stateName: String, attackNumber: Int32, out outgoingStruct: ref<MeleeAttackData>) -> Bool {
    let attackRecord: wref<Attack_Melee_Record>;
    let attackSpeed: Float;
    let attackSpeedMult: Float;
    let dirRecord: wref<AttackDirection_Record>;
    let effectToPlay: CName;
    let endPos: Vector3;
    let ownerID: EntityID;
    let recordID: TweakDBID;
    let staminaCostMods: array<wref<StatModifier_Record>>;
    let startPos: Vector3;
    let statsSystem: ref<StatsSystem>;
    if !this.GetAttackRecord(scriptInterface, stateName, attackNumber, attackRecord) {
      return false;
    };
    recordID = attackRecord.GetID();
    if !TDBID.IsValid(recordID) {
      return false;
    };
    attackSpeedMult = 1.00;
    outgoingStruct = new MeleeAttackData();
    ownerID = scriptInterface.ownerEntityID;
    statsSystem = scriptInterface.GetStatsSystem();
    if TDB.GetBool(recordID + t".dontScaleWithAttackSpeed") {
      attackSpeed = 1.00;
    } else {
      attackSpeed = statsSystem.GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.AttackSpeed);
      if scriptInterface.HasStatFlag(gamedataStatType.CanMeleeBerserk) {
        attackSpeedMult *= LerpF(Cast(stateContext.GetIntParameter(n"totalMeleeAttacksInCombo", true)) / Cast(this.GetStaticIntParameterDefault("maxBerserkASAttack", 1)), 1.00, this.GetStaticFloatParameterDefault("maxBerserkAS", 1.00), true);
      };
      if this.IsPlayerExhausted(scriptInterface) {
        attackSpeedMult *= this.GetStaticFloatParameterDefault("lowStaminaAttackSpeedMult", 0.60);
      };
      attackSpeed *= attackSpeedMult;
    };
    attackRecord.StaminaCost(staminaCostMods);
    outgoingStruct.staminaCost = RPGManager.CalculateStatModifiers(staminaCostMods, scriptInterface.GetGame(), scriptInterface.owner, Cast(ownerID));
    outgoingStruct.chargeCost = TDB.GetFloat(recordID + t".chargeCost");
    outgoingStruct.attackName = attackRecord.AttackName();
    outgoingStruct.attackSpeed = attackSpeed;
    outgoingStruct.startupDuration = TDB.GetFloat(recordID + t".startupDuration") / attackSpeed;
    outgoingStruct.activeDuration = TDB.GetFloat(recordID + t".activeDuration");
    outgoingStruct.recoverDuration = TDB.GetFloat(recordID + t".recoverDuration") / attackSpeed;
    outgoingStruct.activeHitDuration = TDB.GetFloat(recordID + t".activeHitDuration");
    outgoingStruct.recoverHitDuration = TDB.GetFloat(recordID + t".recoverHitDuration") / attackSpeed;
    outgoingStruct.attackWindowOpen = TDB.GetFloat(recordID + t".attackWindowOpen");
    outgoingStruct.attackWindowClosed = TDB.GetFloat(recordID + t".attackWindowClosed");
    outgoingStruct.idleTransitionTime = TDB.GetFloat(recordID + t".idleTransitionTime") / attackSpeed;
    outgoingStruct.holdTransitionTime = TDB.GetFloat(recordID + t".holdTransitionTime");
    outgoingStruct.blockTransitionTime = TDB.GetFloat(recordID + t".blockTransitionTime");
    outgoingStruct.attackEffectDuration = TDB.GetFloat(recordID + t".attackEffectDuration");
    outgoingStruct.impactFxSlot = TDB.GetCName(recordID + t".impactFxSlot");
    outgoingStruct.attackEffectDelay = TDB.GetFloat(recordID + t".attackEffectDelay");
    if outgoingStruct.startupDuration > 0.00 {
      outgoingStruct.attackEffectDelay -= TDB.GetFloat(recordID + t".startupDuration");
      outgoingStruct.attackEffectDelay += outgoingStruct.startupDuration;
    };
    outgoingStruct.impulseDelay = TDB.GetFloat(recordID + t".impulseDelay");
    outgoingStruct.cameraSpaceImpulse = TDB.GetFloat(recordID + t".cameraSpaceImpulse");
    outgoingStruct.forwardImpulse = TDB.GetFloat(recordID + t".forwardImpulse");
    outgoingStruct.upImpulse = TDB.GetFloat(recordID + t".upImpulse");
    outgoingStruct.useAdjustmentInsteadOfImpulse = TDB.GetBool(recordID + t".useAdjustmentInsteadOfImpulse");
    outgoingStruct.attackWindowOpen = ClampF(outgoingStruct.attackWindowOpen, outgoingStruct.startupDuration, outgoingStruct.activeDuration);
    outgoingStruct.attackWindowClosed = outgoingStruct.attackWindowClosed / attackSpeed;
    outgoingStruct.attackWindowClosed = ClampF(outgoingStruct.attackWindowClosed, outgoingStruct.startupDuration + outgoingStruct.activeDuration, outgoingStruct.idleTransitionTime);
    outgoingStruct.enableAdjustingPlayerPositionToTarget = TDB.GetBool(recordID + t".enableAdjustingPlayerPositionToTarget");
    outgoingStruct.incrementsCombo = TDB.GetBool(recordID + t".incrementsCombo");
    outgoingStruct.standUpDelay = TDB.GetFloat(recordID + t".standUpDelay");
    outgoingStruct.ikOffset = TDB.GetVector3(recordID + t".ikOffset");
    dirRecord = attackRecord.AttackDirection();
    startPos = dirRecord.StartPosition();
    endPos = dirRecord.EndPosition();
    outgoingStruct.startPosition = new Vector4(startPos.X, startPos.Y, startPos.Z, 0.00);
    outgoingStruct.endPosition = new Vector4(endPos.X, endPos.Y, endPos.Z, 0.00);
    outgoingStruct.hasDeflectAnim = TDB.GetBool(recordID + t".hasDeflectAnim");
    outgoingStruct.hasHitAnim = TDB.GetBool(recordID + t".hasHitAnim");
    outgoingStruct.trailStartDelay = TweakDBInterface.GetFloat(recordID + t".trailStartDelay", 0.10);
    outgoingStruct.trailStopDelay = TweakDBInterface.GetFloat(recordID + t".trailStopDelay", 0.50);
    outgoingStruct.trailAttackSide = TDB.GetString(recordID + t".trailAttackSide");
    MeleeTransition.GetWeaponObject(scriptInterface).SetAttack(recordID);
    stateContext.SetPermanentFloatParameter(n"idleTransitionTime", outgoingStruct.idleTransitionTime, true);
    stateContext.SetPermanentFloatParameter(n"attackSpeed", attackSpeed, true);
    effectToPlay = TDB.GetCName(recordID + t".vfxName");
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.owner, effectToPlay, false);
    return true;
  }

  protected final const func HasAttackRecord(const scriptInterface: ref<StateGameScriptInterface>, const stateName: String, const opt attackNumber: Int32) -> Bool {
    let attackRecord: wref<Attack_Melee_Record>;
    if this.GetAttackRecord(scriptInterface, stateName, attackNumber, attackRecord) {
      return true;
    };
    return false;
  }

  protected final const func GetAttackRecord(const scriptInterface: ref<StateGameScriptInterface>, const stateName: String, const attackNumber: Int32, out attackRecord: wref<Attack_Melee_Record>) -> Bool {
    let attackString: String;
    let i: Int32;
    let recordString: String;
    let attacksArray: array<ref<IAttack>> = MeleeTransition.GetWeaponObject(scriptInterface).GetAttacks();
    if ArraySize(attacksArray) == 0 {
      return false;
    };
    attackString = stateName + IntToString(attackNumber);
    DefaultTransition.UppercaseFirstChar(attackString);
    i = 0;
    while i < ArraySize(attacksArray) {
      attackRecord = attacksArray[i].GetRecord() as Attack_Melee_Record;
      if !IsDefined(attackRecord) {
      } else {
        recordString = attackRecord.AttackName();
        if Equals(recordString, attackString) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final func SpawnMeleeWeaponProjectile(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let itemObj: ref<ItemObject> = transactionSystem.GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
    let projectileTemplateName: CName = this.GetProjectileTemplateNameFromWeaponDefinition(this.GetActiveMeleeWeaponItemID(scriptInterface));
    if IsDefined(itemObj) && IsNameValid(projectileTemplateName) {
      ProjectileLaunchHelper.SpawnProjectileFromScreenCenter(scriptInterface.executionOwner, projectileTemplateName, itemObj);
    };
  }

  protected final const func GetActiveMeleeWeaponItemID(scriptInterface: ref<StateGameScriptInterface>) -> TweakDBID {
    let weaponItemID: ItemID = MeleeTransition.GetWeaponObject(scriptInterface).GetItemID();
    return ItemID.GetTDBID(weaponItemID);
  }

  protected final const func GetProjectileTemplateNameFromWeaponDefinition(weaponTweak: TweakDBID) -> CName {
    return TweakDBInterface.GetCName(weaponTweak + t".projectileTemplateName", n"");
  }

  protected final const func GetMeleeWeaponFriendlyName(scriptInterface: ref<StateGameScriptInterface>) -> CName {
    return StringToName(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(MeleeTransition.GetWeaponObject(scriptInterface).GetItemID())).FriendlyName());
  }

  public final static func IsPlayingSyncedAnimation(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetWorkspotSystem().IsActorInWorkspot(scriptInterface.executionOwner) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle) {
      return true;
    };
    return false;
  }

  protected final func AdjustAttackPosition(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, attackData: ref<MeleeAttackData>) -> Bool {
    let adjustPosition: Vector4;
    let impulseVector: Vector4;
    if !attackData.useAdjustmentInsteadOfImpulse {
      return false;
    };
    impulseVector = this.AddCameraSpaceImpulse(scriptInterface, stateContext, attackData);
    impulseVector += this.AddForwardImpulse(scriptInterface, stateContext, attackData);
    impulseVector += this.AddUpImpulse(scriptInterface, stateContext, attackData);
    adjustPosition = scriptInterface.executionOwner.GetWorldPosition() + impulseVector;
    this.RequestPlayerPositionAdjustment(stateContext, scriptInterface, null, attackData.attackEffectDelay, 0.90, -1.00, adjustPosition, false);
    return true;
  }

  protected final func AddAttackImpulse(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, attackData: ref<MeleeAttackData>) -> Void {
    let impulseEvent: ref<PSMImpulse>;
    let impulseVector: Vector4;
    let targetTooCloseRange: Float = 5.00;
    if attackData.forwardImpulse > 0.00 || attackData.cameraSpaceImpulse > 0.00 {
      if IsDefined(DefaultTransition.GetTargetObject(scriptInterface, targetTooCloseRange)) {
        return;
      };
    };
    impulseVector = this.AddCameraSpaceImpulse(scriptInterface, stateContext, attackData);
    impulseVector += this.AddForwardImpulse(scriptInterface, stateContext, attackData);
    impulseVector += this.AddUpImpulse(scriptInterface, stateContext, attackData);
    impulseEvent = new PSMImpulse();
    impulseEvent.id = n"impulse";
    impulseEvent.impulse = impulseVector;
    scriptInterface.executionOwner.QueueEvent(impulseEvent);
  }

  protected final func AddCameraSpaceImpulse(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, attackData: ref<MeleeAttackData>) -> Vector4 {
    let cameraWorldTransform: Transform;
    let impulseValue: Float;
    let impulseVector: Vector4;
    if attackData.cameraSpaceImpulse == 0.00 {
      return Vector4.EmptyVector();
    };
    impulseValue = attackData.cameraSpaceImpulse;
    if !scriptInterface.IsOnGround() {
      impulseValue *= this.GetStaticFloatParameterDefault("inAirImpulseMultiplier", 1.00);
    };
    cameraWorldTransform = scriptInterface.GetCameraWorldTransform();
    impulseVector = Transform.GetForward(cameraWorldTransform);
    impulseVector = impulseVector * impulseValue;
    return impulseVector;
  }

  protected final func AddForwardImpulse(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, attackData: ref<MeleeAttackData>) -> Vector4 {
    let impulseValue: Float;
    let impulseVector: Vector4;
    if attackData.forwardImpulse == 0.00 {
      return Vector4.EmptyVector();
    };
    impulseValue = attackData.forwardImpulse;
    if !scriptInterface.IsOnGround() {
      impulseValue *= this.GetStaticFloatParameterDefault("inAirImpulseMultiplier", 1.00);
    };
    impulseVector = scriptInterface.executionOwner.GetWorldForward();
    impulseVector = impulseVector * impulseValue;
    return impulseVector;
  }

  protected final func AddUpImpulse(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, attackData: ref<MeleeAttackData>) -> Vector4 {
    let impulseValue: Float;
    let impulseVector: Vector4;
    if attackData.upImpulse == 0.00 {
      return Vector4.EmptyVector();
    };
    impulseValue = attackData.upImpulse;
    if !scriptInterface.IsOnGround() {
      impulseValue *= this.GetStaticFloatParameterDefault("inAirImpulseMultiplier", 1.00);
    };
    impulseVector = scriptInterface.executionOwner.GetWorldUp();
    impulseVector = impulseVector * impulseValue;
    return impulseVector;
  }

  protected final func GetMovementInput(scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let x: Float = scriptInterface.GetActionValue(n"MoveX");
    let y: Float = scriptInterface.GetActionValue(n"MoveY");
    let res: Float = SqrtF(SqrF(x) + SqrF(y));
    return res;
  }

  protected final func IsPlayerInputDirectedForward(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if AbsF(scriptInterface.GetInputHeading()) < 45.00 {
      return true;
    };
    return false;
  }

  protected final const func GetNanoWireTargetObject(const scriptInterface: ref<StateGameScriptInterface>) -> ref<GameObject> {
    let angleOut: EulerAngles;
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    let targetObject: ref<GameObject> = targetingSystem.GetObjectClosestToCrosshair(scriptInterface.executionOwner, angleOut, TSQ_NPC());
    let wireAttackRange: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.Range);
    wireAttackRange *= 2.00;
    if targetObject.IsPuppet() && ScriptedPuppet.IsActive(targetObject) && (Equals(GameObject.GetAttitudeTowards(targetObject, scriptInterface.executionOwner), EAIAttitude.AIA_Neutral) || Equals(GameObject.GetAttitudeTowards(targetObject, scriptInterface.executionOwner), EAIAttitude.AIA_Hostile)) {
      if wireAttackRange <= 0.00 || Vector4.Distance(scriptInterface.executionOwner.GetWorldPosition(), targetObject.GetWorldPosition()) <= wireAttackRange {
        return targetObject;
      };
    };
    return null;
  }

  protected final func IsTargetAPuppet(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return DefaultTransition.GetTargetObject(scriptInterface).IsPuppet();
  }

  protected final func IsTargetOfficer(scriptInterface: ref<StateGameScriptInterface>, object: wref<GameObject>) -> Bool {
    let puppet: ref<NPCPuppet> = object as NPCPuppet;
    let isOfficer: Bool = Equals(TweakDBInterface.GetCharacterRecord(puppet.GetRecordID()).Rarity().Type(), gamedataNPCRarity.Officer);
    return isOfficer;
  }

  protected final const func IsAttackParried(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetStatusEffectSystem().HasStatusEffect(scriptInterface.executionOwnerEntityID, t"BaseStatusEffect.Parry");
  }

  protected final const func HasMeleeTargeting(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.HasWeaponStatFlag(scriptInterface, gamedataStatType.HasMeleeTargeting);
  }

  protected final const func CanWeaponBlock(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.HasWeaponStatFlag(scriptInterface, gamedataStatType.CanWeaponBlock);
  }

  protected final const func CanWeaponDeflect(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.HasWeaponStatFlag(scriptInterface, gamedataStatType.CanWeaponDeflect);
  }

  protected final const func CanThrowWeapon(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.HasStatFlag(gamedataStatType.CanThrowWeapon);
  }

  protected final func ResetFlags(stateContext: ref<StateContext>) -> Void {
    this.SetIsBlocking(stateContext, false);
    this.SetIsTargeting(stateContext, false);
    this.SetIsAttacking(stateContext, false);
    this.SetIsHolding(stateContext, false);
    this.SetIsParried(stateContext, false);
    this.SetIsSafe(stateContext, false);
  }

  protected final func SpawnPreAttackGameEffect(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let gameEffect: ref<EffectInstance>;
    let initContext: AttackInitContext;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let worldTransform: Transform = Transform.Create(scriptInterface.executionOwner.GetWorldPosition(), scriptInterface.executionOwner.GetWorldOrientation());
    let recordID: TweakDBID = t"Attacks.MeleePreAttack";
    initContext.record = TweakDBInterface.GetAttack_GameEffectRecord(recordID);
    initContext.source = scriptInterface.owner;
    initContext.instigator = scriptInterface.executionOwner;
    let attack: ref<Attack_GameEffect> = IAttack.Create(initContext) as Attack_GameEffect;
    if IsDefined(attack) {
      gameEffect = attack.PrepareAttack(scriptInterface.executionOwner);
    };
    if IsDefined(gameEffect) {
      EffectData.SetFloat(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, TDB.GetFloat(recordID + t".duration"));
      EffectData.SetVector(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, Transform.GetPosition(cameraWorldTransform) + Transform.GetForward(cameraWorldTransform) * TDB.GetFloat(recordID + t".spawnDistance"));
      EffectData.SetQuat(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Transform.GetOrientation(worldTransform));
      EffectData.SetVector(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, scriptInterface.executionOwner.GetWorldForward());
      EffectData.SetFloat(gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, TDB.GetFloat(recordID + t".radius"));
      attack.StartAttack();
    } else {
      return;
    };
  }
}

public abstract class MeleeEventsTransition extends MeleeTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendAnimFeatureData(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendAnimFeatureData(stateContext, scriptInterface);
    this.ToggleWireVisualEffect(stateContext, scriptInterface, n"monowire_idle", false);
  }

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_MeleeData> = new AnimFeature_MeleeData();
    scriptInterface.SetAnimationParameterFeature(n"MeleeData", animFeature);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Melee, EnumInt(gamePSMMelee.Default));
    this.ResetFlags(stateContext);
    this.ToggleWireVisualEffect(stateContext, scriptInterface, n"monowire_idle", false);
    this.RemoveAllMeleeGameplayRestrictions(stateContext, scriptInterface);
  }

  protected final func ToggleWireVisualEffect(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, effectName: CName, b: Bool) -> Void {
    if Equals(this.GetMeleeWeaponFriendlyName(scriptInterface), n"mono_wires") {
      if Equals(b, true) {
        GameObjectEffectHelper.StartEffectEvent(scriptInterface.owner, effectName);
      } else {
        GameObjectEffectHelper.StopEffectEvent(scriptInterface.owner, effectName);
      };
    };
  }
}

public class MeleeNotReadyDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsWeaponReady(stateContext, scriptInterface);
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.EquipAttackCondition(stateContext, scriptInterface) {
      return true;
    };
    return this.IsWeaponReady(stateContext, scriptInterface);
  }
}

public class MeleeNotReadyEvents extends MeleeEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetFlags(stateContext);
    this.ResetAttackNumber(stateContext);
    scriptInterface.PushAnimationEvent(n"MeleeNotReady");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.NotReady));
    stateContext.RemovePermanentFloatParameter(n"meleeRecoveryDuration");
    this.TutorialSetFact(scriptInterface, n"melee_combat_tutorial");
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeParriedDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsAttackParried(stateContext, scriptInterface);
  }

  protected final const func ToMeleeIdle(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsAttackParried(stateContext, scriptInterface);
  }

  protected final const func ToMeleeDeflect(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsBlockPressed(stateContext, scriptInterface);
  }
}

public class MeleeParriedEvents extends MeleeEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    MeleeTransition.ClearInputBuffer(stateContext);
    this.ResetFlags(stateContext);
    this.ResetAttackNumber(stateContext);
    scriptInterface.PushAnimationEvent(n"MeleeParried");
    this.SetIsParried(stateContext, true);
    DefaultTransition.PlayRumble(scriptInterface, "heavy_fast");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.Parried));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    stateContext.RemovePermanentFloatParameter(n"meleeRecoveryDuration");
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsParried(stateContext, false);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeRecoveryDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let paramResult: StateResultFloat = stateContext.GetPermanentFloatParameter(n"meleeRecoveryDuration");
    if paramResult.valid {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let paramResult: StateResultFloat = stateContext.GetPermanentFloatParameter(n"meleeRecoveryDuration");
    return this.GetInStateTime() >= paramResult.value;
  }
}

public class MeleeRecoveryEvents extends MeleeNotReadyEvents {

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.RemovePermanentFloatParameter(n"meleeRecoveryDuration");
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.RemovePermanentFloatParameter(n"meleeRecoveryDuration");
  }
}

public class MeleeIdleDecisions extends MeleeTransition {

  protected final const func ToMeleePublicSafe(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones) == EnumInt(gamePSMZones.Dangerous) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") {
      return false;
    };
    if stateContext.GetBoolParameter(n"InPublicZone", true) {
      if this.GetInStateTime() > this.GetStaticFloatParameterDefault("safeTransition", 1.00) {
        return true;
      };
      return false;
    };
    return false;
  }

  protected final const func ToMeleeHold(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldHold(stateContext, scriptInterface, true) {
      return true;
    };
    return false;
  }
}

public class MeleeIdleEvents extends MeleeEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetFlags(stateContext);
    this.ResetAttackNumber(stateContext);
    this.ClearMeleePressCount(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Melee, EnumInt(gamePSMMelee.Default));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.Idle));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"isSafe", false, true);
    this.SetFlags(stateContext);
    this.ToggleWireVisualEffect(stateContext, scriptInterface, n"monowire_idle", true);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func SetFlags(stateContext: ref<StateContext>) -> Void;
}

public class MeleePublicSafeDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones) == EnumInt(gamePSMZones.Dangerous) {
      return false;
    };
    if stateContext.IsStateActive(n"Locomotion", n"sprint") {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") {
      return false;
    };
    return false;
  }

  protected final const func ToMeleeIdle(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.IsStateActive(n"Locomotion", n"sprint") {
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"Reload") {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") {
      return true;
    };
    return false;
  }
}

public class MeleePublicSafeEvents extends MeleeEventsTransition {

  public let m_unequipTime: Float;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetFlags(stateContext);
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Melee, EnumInt(gamePSMMelee.Default));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.PublicSafe));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.SetIsSafe(stateContext, true);
    if this.GetWeaponItemTag(stateContext, scriptInterface, n"Meleeware") {
      this.m_unequipTime = this.GetStaticFloatParameterDefault("timeToUnequipMeleeware", 15.00);
    } else {
      if stateContext.GetBoolParameter(n"InPublicZone", true) {
        this.m_unequipTime = this.GetStaticFloatParameterDefault("timeToAutoUnequipWeapon", 15.00);
      } else {
        this.m_unequipTime = -1.00;
      };
    };
    this.OnEnter(stateContext, scriptInterface);
  }

  protected final func OnTick(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_unequipTime > 0.00 && this.GetInStateTime() >= this.m_unequipTime {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipWeapon);
    };
  }
}

public class MeleeSafeDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if (scriptInterface.executionOwner as PlayerPuppet).IsAimingAtFriendly() || this.ShouldEnterSafe(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.EnterCondition(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }
}

public class MeleeSafeEvents extends MeleePublicSafeEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.Safe));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
  }
}

public class MeleeHoldDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldHold(stateContext, scriptInterface) && !MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isThrowableWeapon: Bool;
    if this.ShouldInterruptHoldStates(stateContext, scriptInterface) {
      return true;
    };
    if this.ToMeleeChargedHold(stateContext, scriptInterface) && !MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      return true;
    };
    if scriptInterface.GetActionValue(n"MeleeStrongAttack") <= 0.00 && scriptInterface.GetActionValue(n"MeleeAttack") <= 0.00 {
      return true;
    };
    if this.IsBlockHeld(stateContext, scriptInterface) {
      isThrowableWeapon = MeleeTransition.GetWeaponObject(scriptInterface).WeaponHasTag(n"Throwable");
      if !isThrowableWeapon || this.CanThrowWeapon(stateContext, scriptInterface) {
        return true;
      };
    };
    return false;
  }

  protected final const func ToMeleeChargedHold(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if MeleeTransition.WantsToStrongAttack(stateContext, scriptInterface) {
      return true;
    };
    if scriptInterface.GetActionValue(n"MeleeStrongAttack") > 0.00 {
      return true;
    };
    if this.GetInStateTime() > MeleeTransition.GetHoldEnterDuration(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToMeleeFinalAttack(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.CheckIfFinalAttack(scriptInterface, stateContext) && MeleeTransition.WantsToLightAttack(stateContext, scriptInterface);
  }
}

public class MeleeHoldEvents extends MeleeEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsHolding(stateContext, true);
    this.SetIsBlocking(stateContext, false);
    this.SetIsAttacking(stateContext, false);
    this.SetIsTargeting(stateContext, false);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.Hold));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsHolding(stateContext, false);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeChargedHoldDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldHold(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldInterruptHoldStates(stateContext, scriptInterface) {
      return true;
    };
    if !this.ShouldHold(stateContext, scriptInterface) {
      return true;
    };
    if this.ToMeleeStrongAttack(stateContext, scriptInterface) && !MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      return true;
    };
    if this.IsBlockHeld(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToMeleeStrongAttack(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let timeoutDuration: Float;
    if this.NoStrongAttackPressed(scriptInterface) {
      return true;
    };
    timeoutDuration = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.HoldTimeoutDuration);
    if timeoutDuration > 0.00 && this.GetInStateTime() >= timeoutDuration {
      return true;
    };
    return false;
  }

  protected final const func ToMeleeFinalAttack(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }
}

public class MeleeChargedHoldEvents extends MeleeEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let chargeRegen: Float;
    DefaultTransition.PlayRumble(scriptInterface, "light_fast");
    this.SetIsHolding(stateContext, true);
    this.SetIsBlocking(stateContext, false);
    this.SetIsAttacking(stateContext, false);
    this.SetIsTargeting(stateContext, false);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.ChargedHold));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"VisionToggled", false, true);
    this.ForceDisableVisionMode(stateContext);
    if !this.CheckItemType(scriptInterface, gamedataItemType.Cyb_MantisBlades) {
      stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
      this.SetCanSprintWhileCharging(stateContext, false);
    } else {
      this.SetCanSprintWhileCharging(stateContext, true);
    };
    chargeRegen = this.GetChargeValuePerSec(scriptInterface);
    if chargeRegen > 0.00 {
      this.StartPool(scriptInterface.GetStatPoolsSystem(), MeleeTransition.GetWeaponObject(scriptInterface).GetEntityID(), gamedataStatPoolType.WeaponCharge, 100.00, this.GetChargeValuePerSec(scriptInterface));
    };
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetIsHolding(stateContext, false);
    this.StopPool(scriptInterface.GetStatPoolsSystem(), MeleeTransition.GetWeaponObject(scriptInterface).GetEntityID(), gamedataStatPoolType.WeaponCharge, false);
    this.OnExit(stateContext, scriptInterface);
  }

  protected final func GetChargeValuePerSec(scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let chargeDuration: Float;
    let weapon: ref<WeaponObject>;
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    if !IsDefined(statsSystem) {
      return -1.00;
    };
    weapon = MeleeTransition.GetWeaponObject(scriptInterface);
    if !IsDefined(weapon) {
      return -1.00;
    };
    chargeDuration = statsSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime);
    if chargeDuration <= 0.00 {
      return -1.00;
    };
    return 100.00 / chargeDuration;
  }
}

public abstract class MeleeAttackGenericDecisions extends MeleeTransition {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName()), stateContext.GetIntParameter(n"meleeAttackNumber", true)) {
      return false;
    };
    if GameObject.IsCooldownActive(scriptInterface.owner, MeleeTransition.GetMeleeAttackCooldownName()) {
      return false;
    };
    return true;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let interruptEvent: StateResultBool = stateContext.GetPermanentBoolParameter(n"InterruptMelee");
    let attackData: ref<MeleeAttackData> = this.GetAttackData(stateContext);
    let inStateTime: Float = this.GetInStateTime();
    if interruptEvent.value {
      if inStateTime >= attackData.attackWindowClosed {
        return true;
      };
      return false;
    };
    if this.IsBlockHeld(stateContext, scriptInterface) {
      if attackData.blockTransitionTime > 0.00 && inStateTime >= attackData.blockTransitionTime {
        return true;
      };
      if inStateTime >= attackData.attackWindowClosed {
        if !this.HasMeleeTargeting(stateContext, scriptInterface) && this.IsBlockPressed(stateContext, scriptInterface) {
          return true;
        };
      };
    };
    if inStateTime >= attackData.attackWindowClosed && !MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      if stateContext.GetConditionBool(n"LightMeleeAttackPressed") {
        return true;
      };
      if stateContext.GetConditionBool(n"StrongMeleeAttackPressed") {
        return true;
      };
      if this.ShouldHold(stateContext, scriptInterface, false, true) {
        return true;
      };
    };
    if inStateTime >= attackData.idleTransitionTime {
      return true;
    };
    if this.IsAttackParried(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func GetAttackData(const stateContext: ref<StateContext>) -> ref<MeleeAttackData> {
    return stateContext.GetConditionScriptableParameter(n"MeleeAttackData") as MeleeAttackData;
  }
}

public abstract class MeleeAttackGenericEvents extends MeleeEventsTransition {

  public let m_effect: ref<EffectInstance>;

  public let m_attackCreated: Bool;

  public let m_blockImpulseCreation: Bool;

  public let m_standUpSend: Bool;

  public let m_trailCreated: Bool;

  public let m_textLayer: Uint32;

  public let m_rumblePlayed: Bool;

  public let m_shouldBlockImpulseUpdate: Bool;

  protected func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Combo;
  }

  protected func IsMoveToTargetEnabled(attackData: ref<MeleeAttackData>, assistRecord: ref<AimAssistMelee_Record>) -> Bool {
    let assistLevel: EMoveAssistLevel;
    let attackType: EMeleeAttackType;
    if !attackData.enableAdjustingPlayerPositionToTarget {
      return false;
    };
    if IsDefined(assistRecord) {
      assistLevel = IntEnum(assistRecord.MoveToTargetEnabledAttacks());
      if Equals(assistLevel, EMoveAssistLevel.AllAttacks) {
        return true;
      };
      if Equals(assistLevel, EMoveAssistLevel.Off) {
        return false;
      };
      if Equals(assistLevel, EMoveAssistLevel.SpecialAttacks) {
        attackType = this.GetAttackType();
        return Equals(attackType, EMeleeAttackType.Strong);
      };
    };
    return false;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let adjustRadius: Float;
    let adjustRadiusParam: Float;
    let adjustmentDistParam: Float;
    let adjustmentTargetRadius: Float;
    let attackData: ref<MeleeAttackData>;
    let attackRange: Float;
    let aimAssistRecord: ref<AimAssistMelee_Record> = MeleeTransition.GetAimAssistMeleeRecord(scriptInterface);
    this.m_attackCreated = false;
    this.m_blockImpulseCreation = false;
    this.m_standUpSend = false;
    this.m_effect = null;
    this.m_trailCreated = false;
    this.m_rumblePlayed = false;
    this.m_shouldBlockImpulseUpdate = false;
    let broadcaster: ref<StimBroadcasterComponent> = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.MeleeAttack);
    };
    this.SetMeleeAttackPressCount(stateContext, scriptInterface);
    MeleeTransition.ClearInputBuffer(stateContext);
    stateContext.SetPermanentBoolParameter(n"InterruptMelee", false, true);
    this.SetIsAttacking(stateContext, true);
    this.SetIsBlocking(stateContext, false);
    if IsDefined(aimAssistRecord) && aimAssistRecord.AimSnapOnAttack() {
      scriptInterface.GetTargetingSystem().AimSnap(scriptInterface.executionOwner);
    };
    GameObject.PlayVoiceOver(scriptInterface.executionOwner, n"meleeAttack", n"Scripts:MeleeAttackGenericEvents");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Melee, EnumInt(gamePSMMelee.Attack));
    this.SpawnPreAttackGameEffect(stateContext, scriptInterface);
    this.GetAttackDataFromStateName(stateContext, scriptInterface, NameToString(this.GetStateName()), stateContext.GetIntParameter(n"meleeAttackNumber", true), attackData);
    stateContext.SetPermanentBoolParameter(n"hasDeflectAnim", attackData.hasDeflectAnim, true);
    stateContext.SetPermanentBoolParameter(n"hasHitAnim", attackData.hasHitAnim, true);
    stateContext.SetConditionScriptableParameter(n"MeleeAttackData", attackData, true);
    stateContext.SetPermanentBoolParameter(n"VisionToggled", false, true);
    this.ForceDisableVisionMode(stateContext);
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    this.ClearDebugText(scriptInterface, this.m_textLayer);
    this.DrawDebugText(scriptInterface, this.m_textLayer, attackData.attackName + "  as:" + attackData.attackSpeed);
    if this.IsMoveToTargetEnabled(attackData, aimAssistRecord) {
      if !this.IsPlayerExhausted(scriptInterface) {
        attackRange = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.Range);
        adjustmentDistParam = aimAssistRecord.MoveToTargetSearchDistance();
        adjustmentTargetRadius = attackRange + adjustmentDistParam;
        adjustRadiusParam = aimAssistRecord.MoveToTargetDistanceIntoAttackRange();
        adjustRadius = MaxF(attackRange - adjustRadiusParam, 1.50);
        if this.AdjustPlayerPosition(stateContext, scriptInterface, DefaultTransition.GetTargetObject(scriptInterface, adjustmentTargetRadius), attackData.attackEffectDelay, adjustRadius, n"") {
          this.m_blockImpulseCreation = true;
        };
      };
    };
    this.SendAnimationSlotData(stateContext, scriptInterface, attackData);
    scriptInterface.PushAnimationEvent(n"Attack");
    stateContext.SetPermanentIntParameter(n"attackType", EnumInt(this.GetAttackType()), true);
    this.OnEnter(stateContext, scriptInterface);
    if attackData.standUpDelay == 0.00 {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      this.m_standUpSend = true;
    };
    if attackData.incrementsCombo {
      this.IncrementAttackNumber(scriptInterface, stateContext);
    };
    this.SetIsSafe(stateContext, false);
    this.SendDataTrackingRequest(scriptInterface, ETelemetryData.MeleeAttacksMade, 1);
  }

  protected final func SendAnimationSlotData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const attackData: ref<MeleeAttackData>) -> Bool {
    let slotData: ref<AnimFeature_MeleeSlotData> = new AnimFeature_MeleeSlotData();
    slotData.attackType = EnumInt(this.GetAttackType());
    slotData.comboNumber = stateContext.GetIntParameter(n"meleeAttackNumber", true);
    slotData.startupDuration = attackData.startupDuration;
    slotData.activeDuration = attackData.activeDuration;
    slotData.recoverDuration = attackData.recoverDuration;
    slotData.activeHitDuration = attackData.activeHitDuration;
    slotData.recoverHitDuration = attackData.recoverHitDuration;
    scriptInterface.SetAnimationParameterFeature(n"MeleeSlotData", slotData);
    return true;
  }

  protected final func ConsumeStamina(scriptInterface: ref<StateGameScriptInterface>, attackData: ref<MeleeAttackData>) -> Void {
    if attackData.staminaCost > 0.00 {
      PlayerStaminaHelpers.ModifyStamina(scriptInterface.executionOwner as PlayerPuppet, -attackData.staminaCost);
    };
  }

  protected final func ConsumeWeaponCharge(scriptInterface: ref<StateGameScriptInterface>, attackData: ref<MeleeAttackData>) -> Void {
    if !scriptInterface.GetStatPoolsSystem().IsStatPoolAdded(Cast(scriptInterface.ownerEntityID), gamedataStatPoolType.WeaponCharge) {
      return;
    };
    if attackData.chargeCost > 0.00 {
      this.ChangeStatPoolValue(scriptInterface, scriptInterface.ownerEntityID, gamedataStatPoolType.WeaponCharge, -attackData.chargeCost);
    };
  }

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let attackData: ref<MeleeAttackData>;
    let duration: Float;
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    attackData = this.GetAttackData(stateContext);
    duration = this.GetInStateTime();
    if !this.m_standUpSend && attackData.standUpDelay > 0.00 && duration > attackData.standUpDelay {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      this.m_standUpSend = true;
    };
    this.UpdateIKData(scriptInterface, attackData);
    if duration >= attackData.attackEffectDelay && !this.m_attackCreated && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon) != EnumInt(gamePSMMeleeWeapon.ThrowAttack) {
      this.CreateMeleeAttack(stateContext, scriptInterface, attackData);
      this.m_attackCreated = true;
      this.ConsumeStamina(scriptInterface, attackData);
    };
    if IsDefined(this.m_effect) {
      this.UpdateEffectPosition(stateContext, scriptInterface, attackData);
      if duration >= attackData.attackEffectDelay + attackData.attackEffectDuration + 0.10 {
        this.m_effect = null;
        this.ConsumeWeaponCharge(scriptInterface, attackData);
      };
    };
    if this.m_trailCreated && duration >= attackData.trailStopDelay {
      MeleeTransition.GetWeaponObject(scriptInterface).StopCurrentMeleeTrailEffect(attackData.trailAttackSide);
    } else {
      if duration >= attackData.trailStartDelay && !this.m_trailCreated {
        MeleeTransition.GetWeaponObject(scriptInterface).StartCurrentMeleeTrailEffect(attackData.trailAttackSide);
        this.m_trailCreated = true;
      };
    };
    if this.ShouldBlockMovementImpulseUpdate(timeDelta, attackData, stateContext, scriptInterface) {
      this.m_shouldBlockImpulseUpdate = true;
    };
    if this.UpdateMovementImpulse(timeDelta, attackData, stateContext, scriptInterface) {
      this.m_blockImpulseCreation = true;
    };
    if duration >= attackData.attackEffectDelay {
      if !this.m_rumblePlayed {
        DefaultTransition.PlayRumble(scriptInterface, this.GetStaticStringParameterDefault("rumbleStrength", "light_fast"));
        this.m_rumblePlayed = true;
      };
    };
    if Equals(this.GetAttackType(), EMeleeAttackType.Final) {
      MeleeTransition.ClearInputBuffer(stateContext);
    } else {
      if this.IsAttackWindowOpen(stateContext, scriptInterface) {
        MeleeTransition.UpdateMeleeInputBuffer(stateContext, scriptInterface);
      };
    };
    if duration >= attackData.attackWindowClosed {
      this.SetIsAttacking(stateContext, false);
    };
  }

  protected final func UpdateIKData(scriptInterface: ref<StateGameScriptInterface>, const attackData: ref<MeleeAttackData>) -> Void {
    let slotPosition: Vector4;
    let animFeature: ref<AnimFeature_MeleeIKData> = new AnimFeature_MeleeIKData();
    let target: ref<GameObject> = DefaultTransition.GetTargetObject(scriptInterface);
    if IsDefined(target) {
      if AIActionHelper.GetTargetSlotPosition(target, n"Head", slotPosition) {
        animFeature.headPosition = slotPosition;
        animFeature.isValid = true;
      };
      if AIActionHelper.GetTargetSlotPosition(target, n"Chest", slotPosition) {
        animFeature.chestPosition = slotPosition;
        animFeature.isValid = true;
      };
      animFeature.ikOffset.X = attackData.ikOffset.X;
      animFeature.ikOffset.Y = attackData.ikOffset.Y;
      animFeature.ikOffset.Z = attackData.ikOffset.Z;
    };
    scriptInterface.SetAnimationParameterFeature(n"MeleeIKData", animFeature);
  }

  protected final func ShouldBlockMovementImpulseUpdate(timeDelta: Float, attackData: ref<MeleeAttackData>, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.IsOnGround() && (attackData.forwardImpulse < 0.00 || attackData.forwardImpulse > 0.00) {
      return true;
    };
    if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) >= 10.00 {
      return true;
    };
    return false;
  }

  protected final func UpdateMovementImpulse(timeDelta: Float, attackData: ref<MeleeAttackData>, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.m_blockImpulseCreation {
      return true;
    };
    if this.IsPlayerExhausted(scriptInterface) {
      return true;
    };
    if this.m_shouldBlockImpulseUpdate {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed) == EnumInt(gamePSMDetailedLocomotionStates.Slide) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed) == EnumInt(gamePSMDetailedLocomotionStates.SlideFall) {
      return false;
    };
    if this.GetInStateTime() < attackData.impulseDelay {
      return false;
    };
    if !this.CheckItemType(scriptInterface, gamedataItemType.Cyb_MantisBlades) {
      if (attackData.cameraSpaceImpulse > 0.00 || attackData.forwardImpulse > 0.00) && !this.IsPlayerInputDirectedForward(scriptInterface) {
        return true;
      };
      if this.IsCameraPitchAcceptable(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("cameraPitchThreshold", -30.00)) {
        return true;
      };
    };
    if !this.AdjustAttackPosition(scriptInterface, stateContext, attackData) {
      this.AddAttackImpulse(scriptInterface, stateContext, attackData);
    };
    return true;
  }

  protected final func UpdateEffectPosition(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, attackData: ref<MeleeAttackData>) -> Void {
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let startPosition: Vector4 = attackData.startPosition;
    let endPosition: Vector4 = attackData.endPosition;
    let dir: Vector4 = startPosition - endPosition;
    let attackRange: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.Range);
    startPosition = attackData.startPosition;
    if dir.Y == 0.00 {
      startPosition.Y += attackRange * 0.50;
    };
    EffectData.SetVector(this.m_effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, Transform.TransformPoint(cameraWorldTransform, startPosition));
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let attackData: ref<MeleeAttackData> = this.GetAttackData(stateContext);
    let interruptEvent: StateResultBool = stateContext.GetPermanentBoolParameter(n"InterruptMelee");
    scriptInterface.SetAnimationParameterFloat(n"safe", 0.00);
    stateContext.SetPermanentBoolParameter(n"safe", false, true);
    if interruptEvent.value {
      this.GetAttackDataFromStateName(stateContext, scriptInterface, NameToString(this.GetStateName()), stateContext.GetIntParameter(n"meleeAttackNumber", true), attackData);
      stateContext.SetPermanentFloatParameter(n"meleeRecoveryDuration", attackData.idleTransitionTime - this.GetInStateTime(), true);
    };
    stateContext.SetPermanentBoolParameter(n"InterruptMelee", false, true);
    this.OnExit(stateContext, scriptInterface);
    this.ClearDebugText(scriptInterface, this.m_textLayer);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearDebugText(scriptInterface, this.m_textLayer);
    this.OnForcedExit(stateContext, scriptInterface);
  }

  protected final func CreateMeleeAttack(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, attackData: ref<MeleeAttackData>) -> Void {
    let colliderBox: Vector4;
    let time: Float;
    let sweepBoxColliderSize: Float = 0.25;
    let startPosition: Vector4 = attackData.startPosition;
    let endPosition: Vector4 = attackData.endPosition;
    let attackRange: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.Range);
    let dir: Vector4 = endPosition - startPosition;
    colliderBox.X = sweepBoxColliderSize;
    colliderBox.Y = sweepBoxColliderSize;
    colliderBox.Z = sweepBoxColliderSize;
    if dir.Y != 0.00 {
      endPosition.Y = attackRange;
    } else {
      startPosition.Y += attackRange * 0.50;
      endPosition.Y += attackRange * 0.50;
      colliderBox.Y = attackRange;
    };
    time = attackData.attackEffectDuration;
    this.SpawnAttackGameEffect(stateContext, scriptInterface, startPosition, endPosition, time, colliderBox, attackData);
    GameObject.StartCooldown(scriptInterface.owner, MeleeTransition.GetMeleeAttackCooldownName(), attackData.attackWindowClosed - attackData.attackEffectDelay);
  }

  protected final func SpawnAttackGameEffect(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, startPosition: Vector4, endPosition: Vector4, time: Float, colliderBox: Vector4, attackData: ref<MeleeAttackData>) -> Bool {
    let effect: ref<EffectInstance>;
    let meleeAttack: ref<Attack_GameEffect>;
    let success: Bool = false;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let attackStartPositionWorld: Vector4 = Transform.TransformPoint(cameraWorldTransform, startPosition);
    attackStartPositionWorld.W = 0.00;
    let attackEndPositionWorld: Vector4 = Transform.TransformPoint(cameraWorldTransform, endPosition);
    attackEndPositionWorld.W = 0.00;
    let attackDirectionWorld: Vector4 = attackEndPositionWorld - attackStartPositionWorld;
    let weapon: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
    if IsDefined(weapon) {
      meleeAttack = weapon.GetCurrentAttack() as Attack_GameEffect;
      if IsDefined(meleeAttack) {
        effect = meleeAttack.PrepareAttack(scriptInterface.executionOwner);
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.box, colliderBox);
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, time);
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, attackStartPositionWorld);
        EffectData.SetQuat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Transform.GetOrientation(cameraWorldTransform));
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, Vector4.Normalize(attackDirectionWorld));
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, Vector4.Length(attackDirectionWorld));
        EffectData.SetInt(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackNumber, stateContext.GetIntParameter(n"meleeAttackNumber", true));
        EffectData.SetName(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.impactOrientationSlot, attackData.impactFxSlot);
        if Equals(this.GetAttackType(), EMeleeAttackType.Strong) {
          EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.meleeCleave, true);
        };
        EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.fxPackage, ToVariant((scriptInterface.owner as WeaponObject).GetFxPackage()));
        EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.playerOwnedWeapon, true);
        this.m_effect = effect;
        success = meleeAttack.StartAttack();
      };
    };
    return success;
  }

  protected final func BroadcastStimuli(scriptInterface: ref<StateGameScriptInterface>, radius: Float) -> Void {
    let position: Vector4 = scriptInterface.executionOwner.GetWorldPosition();
    let stimuliEvent: ref<StimuliEvent> = new StimuliEvent();
    stimuliEvent.sourcePosition = position;
    stimuliEvent.name = n"run";
    let effect: ref<EffectInstance> = GameInstance.GetGameEffectSystem(scriptInterface.GetGame()).CreateEffectStatic(n"stimuli", n"stimuli_range", scriptInterface.executionOwner, scriptInterface.owner);
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.stimuliEvent, ToVariant(stimuliEvent));
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
    EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.stimuliRaycastTest, true);
    GameInstance.GetStimuliSystem(scriptInterface.owner.GetGame()).BroadcastStimuli(effect);
  }

  protected final const func GetAttackData(const stateContext: ref<StateContext>) -> ref<MeleeAttackData> {
    return stateContext.GetConditionScriptableParameter(n"MeleeAttackData") as MeleeAttackData;
  }

  protected final const func IsAttackWindowOpen(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let attackData: ref<MeleeAttackData> = this.GetAttackData(stateContext);
    let inStateTime: Float = this.GetInStateTime();
    if inStateTime >= attackData.attackWindowOpen {
      return true;
    };
    return false;
  }
}

public class MeleeComboAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) {
      return false;
    };
    if !this.EnterCondition(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }
}

public class MeleeComboAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Combo;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.ComboAttack));
    this.OnEnter(stateContext, scriptInterface);
    this.IncrementTotalComboAttackNumber(scriptInterface, stateContext);
  }
}

public class MeleeFinalAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.CheckIfFinalAttack(scriptInterface, stateContext) {
      return false;
    };
    if MeleeTransition.WantsToStrongAttack(stateContext, scriptInterface) {
      return false;
    };
    if !MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) {
      return false;
    };
    if !this.EnterCondition(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }
}

public class MeleeFinalAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Final;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentBoolParameter(n"finalAttack", true, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.FinalAttack));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentBoolParameter(n"finalAttack", false, true);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeSafeAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) {
      return false;
    };
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName())) {
      return false;
    };
    return true;
  }
}

public class MeleeSafeAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Safe;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.SafeAttack));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeStrongAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !stateContext.GetConditionBool(n"StrongMeleeAttackPressed") {
      return false;
    };
    return true;
  }
}

public class MeleeStrongAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Strong;
  }

  public final func OnEnterFromMeleeLeap(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.m_blockImpulseCreation = true;
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap, true);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentBoolParameter(n"strongAttack", true, true);
    this.SetAttackNumber(stateContext, stateContext.GetIntParameter(n"meleeAttackNumber", true) % 2);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.StrongAttack));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentBoolParameter(n"strongAttack", false, true);
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap, false);
    this.OnExit(stateContext, scriptInterface);
  }

  protected final func OnExitToMeleeComboAttack(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeDeflectDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsBlockPressed(stateContext, scriptInterface) {
      if !this.CanWeaponDeflect(stateContext, scriptInterface) {
        return false;
      };
      if this.HasMeleeTargeting(stateContext, scriptInterface) {
        return false;
      };
      if this.GetStaticBoolParameterDefault("disabled", false) {
        return false;
      };
      if GameObject.IsCooldownActive(scriptInterface.owner, n"Deflect") {
        return false;
      };
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsDeflectSuccessful(stateContext, scriptInterface) {
      return true;
    };
    if this.ShouldInterruptHoldStates(stateContext, scriptInterface) {
      return true;
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("duration", 0.40) {
      return true;
    };
    if this.IsBlockHeld(stateContext, scriptInterface) {
      return MeleeTransition.AnyMeleeAttackPressed(scriptInterface) || stateContext.GetConditionBool(n"LightMeleeAttackPressed");
    };
    return false;
  }

  public final func ToMeleeHold(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldHold(stateContext, scriptInterface) && this.ToMeleeComboAttack(stateContext, scriptInterface) && !MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToMeleeComboAttack(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsBlockHeld(stateContext, scriptInterface) {
      if stateContext.GetConditionBool(n"LightMeleeAttackPressed") && !MeleeTransition.IsPlayingSyncedAnimation(scriptInterface) {
        return true;
      };
    };
    return false;
  }

  public final func ToMeleeBlock(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected final func ToMeleeDeflectAttack(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsDeflectSuccessful(stateContext, scriptInterface);
  }

  protected final const func IsDeflectSuccessful(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let deflectEvent: StateResultBool = stateContext.GetTemporaryBoolParameter(n"successfulDeflect");
    return deflectEvent.valid;
  }
}

public class MeleeDeflectEvents extends MeleeEventsTransition {

  public let deflectStatFlag: ref<gameStatModifierData>;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    this.SetIsBlocking(stateContext, true);
    scriptInterface.PushAnimationEvent(n"Deflect");
    scriptInterface.GetTargetingSystem().AimSnap(scriptInterface.executionOwner);
    this.deflectStatFlag = RPGManager.CreateStatModifier(gamedataStatType.IsDeflecting, gameStatModifierType.Additive, 1.00);
    scriptInterface.GetStatsSystem().AddModifier(ownerID, this.deflectStatFlag);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Melee, EnumInt(gamePSMMelee.Block));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.Deflect));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    MeleeTransition.ClearInputBuffer(stateContext);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.deflectStatFlag);
    GameObject.StartCooldown(scriptInterface.owner, n"Deflect", this.GetStaticFloatParameterDefault("cooldown", -1.00));
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeDeflectAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName())) {
      return false;
    };
    return true;
  }
}

public class MeleeDeflectAttackEvents extends MeleeAttackGenericEvents {

  public let m_slowMoSet: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.DeflectAttack));
    this.TutorialAddFact(scriptInterface, n"melee_deflect_tutorial", 1);
    DefaultTransition.PlayRumble(scriptInterface, this.GetStaticStringParameterDefault("rumbleOnStartStrength", "light_fast"));
    GameObject.PlaySound(scriptInterface.executionOwner, this.GetStaticCNameParameterDefault("slowMoStartSound", n""));
    this.m_slowMoSet = false;
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let slowMoStart: Float = this.GetStaticFloatParameterDefault("slowMoStart", 0.10);
    if !this.m_slowMoSet && this.GetInStateTime() > slowMoStart && !this.IsTimeDilationActive(stateContext, scriptInterface, n"") {
      scriptInterface.GetTimeSystem().SetTimeDilation(n"deflect", this.GetStaticFloatParameterDefault("slowMoAmount", 0.10), this.GetStaticFloatParameterDefault("slowDuration", 0.10), this.GetStaticCNameParameterDefault("slowMoEaseIn", n"Linear"), this.GetStaticCNameParameterDefault("slowMoEaseOut", n"Linear"));
      this.m_slowMoSet = true;
    };
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }
}

public class MeleeBlockDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsBlockHeld(stateContext, scriptInterface) {
      if this.IsAttackParried(stateContext, scriptInterface) {
        return false;
      };
      if !this.CanWeaponBlock(stateContext, scriptInterface) {
        return false;
      };
      if this.HasMeleeTargeting(stateContext, scriptInterface) && this.CanThrowWeapon(stateContext, scriptInterface) {
        return false;
      };
      if GameObject.IsCooldownActive(scriptInterface.owner, n"Block") {
        return false;
      };
      if GameObject.IsCooldownActive(scriptInterface.owner, n"Deflect") {
        return false;
      };
      if !this.IsBlockHeld(stateContext, scriptInterface) {
        return false;
      };
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldEnterSafe(stateContext, scriptInterface) {
      return true;
    };
    if this.ShouldInterruptHoldStates(stateContext, scriptInterface) {
      return true;
    };
    if MeleeTransition.AnyMeleeAttackPressed(scriptInterface) {
      return true;
    };
    if this.IsBlockHeld(stateContext, scriptInterface) {
      return false;
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("minDuration", -1.00) {
      return true;
    };
    return false;
  }
}

public class MeleeBlockEvents extends MeleeEventsTransition {

  public let blockStatFlag: ref<gameStatModifierData>;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    MeleeTransition.ClearInputBuffer(stateContext);
    this.SetMeleeAttackPressCount(stateContext, scriptInterface);
    this.SetIsBlocking(stateContext, true);
    scriptInterface.PushAnimationEvent(n"Block");
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    this.blockStatFlag = RPGManager.CreateStatModifier(gamedataStatType.IsBlocking, gameStatModifierType.Additive, 1.00);
    scriptInterface.GetStatsSystem().AddModifier(ownerID, this.blockStatFlag);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Melee, EnumInt(gamePSMMelee.Block));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.Block));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.blockStatFlag);
    GameObject.StartCooldown(scriptInterface.owner, n"Block", this.GetStaticFloatParameterDefault("cooldown", -1.00));
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeTargetingDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.HasMeleeTargeting(stateContext, scriptInterface) {
      return false;
    };
    if MeleeTransition.GetWeaponObject(scriptInterface).WeaponHasTag(n"Throwable") && !this.CanThrowWeapon(stateContext, scriptInterface) {
      return false;
    };
    if !this.IsBlockHeld(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ShouldInterruptHoldStates(stateContext, scriptInterface) {
      return true;
    };
    if !this.EnterCondition(stateContext, scriptInterface) {
      return true;
    };
    if MeleeTransition.MeleeAttackReleased(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class MeleeTargetingEvents extends MeleeEventsTransition {

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let aimAssistRecord: ref<AimAssistMelee_Record> = MeleeTransition.GetAimAssistMeleeRecord(scriptInterface);
    this.SetIsTargeting(stateContext, true);
    scriptInterface.PushAnimationEvent(n"Targeting");
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    if IsDefined(aimAssistRecord) && aimAssistRecord.AimSnapOnAim() {
      scriptInterface.GetTargetingSystem().AimSnap(scriptInterface.executionOwner);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Melee, EnumInt(gamePSMMelee.Block));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.Targeting));
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class MeleeThrowAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName())) {
      return false;
    };
    if !this.IsBlockHeld(stateContext, scriptInterface) {
      return false;
    };
    if !MeleeTransition.MeleeAttackReleased(scriptInterface) {
      return false;
    };
    if MeleeTransition.GetWeaponObject(scriptInterface).WeaponHasTag(n"Throwable") && !this.CanThrowWeapon(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let attackData: ref<MeleeAttackData> = this.GetAttackData(stateContext);
    let inStateTime: Float = this.GetInStateTime();
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let itemObj: wref<ItemObject> = transactionSystem.GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
    if this.IsBlockHeld(stateContext, scriptInterface) {
      if attackData.blockTransitionTime > 0.00 && inStateTime >= attackData.blockTransitionTime {
        return true;
      };
    };
    if !itemObj.GetItemData().HasTag(n"Cyberware") {
      if stateContext.GetConditionBool(n"LightMeleeAttackPressed") && inStateTime >= attackData.attackWindowClosed {
        return true;
      };
      if inStateTime >= attackData.idleTransitionTime {
        return true;
      };
    };
    if itemObj.GetItemData().HasTag(n"Cyberware") {
      if inStateTime >= attackData.idleTransitionTime {
        return true;
      };
    };
    return false;
  }
}

public class MeleeThrowAttackEvents extends MeleeAttackGenericEvents {

  @default(MeleeThrowAttackEvents, false)
  public let m_projectileThrown: Bool;

  public let m_targetObject: wref<GameObject>;

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Throw;
  }

  protected final func EnableLockOnTarget(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let aimRequestData: AimRequest = this.GetBlockLookAtParams();
    scriptInterface.GetTargetingSystem().LookAt(scriptInterface.executionOwner, aimRequestData);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let aimAssistRecord: ref<AimAssistMelee_Record> = MeleeTransition.GetAimAssistMeleeRecord(scriptInterface);
    this.m_projectileThrown = false;
    if this.CheckItemType(scriptInterface, gamedataItemType.Cyb_NanoWires) {
      this.m_targetObject = this.GetNanoWireTargetObject(scriptInterface);
    };
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.ThrowAttack));
    this.EnableLockOnTarget(stateContext, scriptInterface);
    if IsDefined(aimAssistRecord) && aimAssistRecord.AimSnapOnThrow() {
      scriptInterface.GetTargetingSystem().AimSnap(scriptInterface.executionOwner);
    };
    this.ApplyThrowAttackGameplayRestrictions(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let attackData: ref<MeleeAttackData>;
    let isItemKnife: Bool;
    let isItemNanowire: Bool;
    let isValidNanowireAttack: Bool;
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    attackData = this.GetAttackData(stateContext);
    isItemKnife = this.CheckItemType(scriptInterface, gamedataItemType.Wea_Knife);
    isItemNanowire = this.CheckItemType(scriptInterface, gamedataItemType.Cyb_NanoWires);
    isValidNanowireAttack = isItemNanowire && IsDefined(this.m_targetObject);
    if this.GetInStateTime() > attackData.attackEffectDelay && !this.m_projectileThrown && (isValidNanowireAttack || isItemKnife) {
      this.SpawnMeleeWeaponProjectile(scriptInterface);
      this.m_projectileThrown = true;
    };
    if isItemNanowire {
      this.UpdateNanoWireIKState(stateContext, scriptInterface);
    };
  }

  protected final func UpdateNanoWireIKState(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("timeToEnableWireIK", 0.54) {
      this.EnableNanoWireIK(scriptInterface, true);
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("timeToDisableWireIK", 1.20) {
      this.DisableNanoWireIK(scriptInterface);
    };
  }

  protected final func EnableNanoWireIK(scriptInterface: ref<StateGameScriptInterface>, enable: Bool, opt setPosition: Bool) -> Void {
    let slotPosition: Vector4;
    let targetPosition: Vector4;
    let wireTargetSlot: CName;
    if IsDefined(this.m_targetObject) {
      wireTargetSlot = this.GetStaticCNameParameterDefault("wireTargetSlot", n"wireTargetSlot");
      AIActionHelper.GetTargetSlotPosition(this.m_targetObject, wireTargetSlot, slotPosition);
      targetPosition = slotPosition;
    } else {
      targetPosition = new Vector4(0.00, 0.00, 0.00, 1.00);
    };
    this.UpdateNanoWireEndPositionAnimFeature(scriptInterface, this.GetStaticCNameParameterDefault("ikAnimFeatureName", n"ikLeftNanoWire"), enable, setPosition, targetPosition);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let itemObj: wref<ItemObject>;
    let quantity: Int32;
    let throwEquipmentRequest: ref<ThrowEquipmentRequest>;
    let transactionSystem: ref<TransactionSystem>;
    this.RemoveThrowAttackGameplayRestrictions(stateContext, scriptInterface);
    this.DisableNanoWireIK(scriptInterface);
    this.OnExit(stateContext, scriptInterface);
    transactionSystem = scriptInterface.GetTransactionSystem();
    itemObj = transactionSystem.GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
    if this.m_projectileThrown && !itemObj.GetItemData().HasTag(n"Cyberware") {
      quantity = transactionSystem.GetItemQuantity(scriptInterface.executionOwner, itemObj.GetItemID());
      if quantity <= 1 {
        throwEquipmentRequest = new ThrowEquipmentRequest();
        throwEquipmentRequest.owner = scriptInterface.executionOwner;
        throwEquipmentRequest.itemObject = itemObj;
        scriptInterface.GetScriptableSystem(n"EquipmentSystem").QueueRequest(throwEquipmentRequest);
        this.OnForcedExit(stateContext, scriptInterface);
      };
      transactionSystem.RemoveItem(scriptInterface.executionOwner, itemObj.GetItemID(), 1);
    };
  }
}

public class MeleeLeapDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let performCheck: Bool;
    if !scriptInterface.IsOnGround() {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanMeleeLeap) {
      return false;
    };
    if !this.GetStaticBoolParameterDefault("canLeapWithoutTarget", false) && !IsDefined(DefaultTransition.GetTargetObject(scriptInterface, this.GetStaticFloatParameterDefault("maxDistToTarget", 5.00))) {
      return false;
    };
    if IsDefined(DefaultTransition.GetTargetObject(scriptInterface, this.GetStaticFloatParameterDefault("minDistToTarget", 2.00))) {
      return false;
    };
    if !this.CheckLeapCollision(stateContext, scriptInterface) {
      return false;
    };
    if this.IsInMeleeState(stateContext, n"meleeChargedHold") && MeleeTransition.MeleeAttackReleased(scriptInterface) {
      performCheck = true;
    };
    if stateContext.IsStateActive(n"Locomotion", n"sprint") || scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) > 5.00 {
      if MeleeTransition.AnyMeleeAttackPressed(scriptInterface) {
        performCheck = true;
      };
    };
    if !performCheck {
      return false;
    };
    return true;
  }

  protected final const func CheckLeapCollision(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let queryFilter: QueryFilter;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    QueryFilter.AddGroup(queryFilter, n"Static");
    QueryFilter.AddGroup(queryFilter, n"PlayerBlocker");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.refPosition = Transform.GetPosition(cameraWorldTransform);
    geometryDescription.refDirection = Transform.GetForward(cameraWorldTransform);
    geometryDescription.filter = queryFilter;
    geometryDescription.primitiveDimension = new Vector4(0.10, 0.10, 0.10, 0.00);
    geometryDescription.maxDistance = 5.00;
    geometryDescription.maxExtent = 5.00;
    geometryDescription.probingPrecision = 0.05;
    geometryDescription.probingMaxDistanceDiff = 5.00;
    geometryDescription.AddFlag(worldgeometryDescriptionQueryFlags.DistanceVector);
    geometryDescriptionResult = scriptInterface.GetSpatialQueriesSystem().GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    if Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.NoGeometry) {
      return true;
    };
    return false;
  }

  protected final const func ToMeleeStrongAttack(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let result: StateResultFloat = stateContext.GetConditionFloatParameter(n"LeapExitTime");
    if result.valid {
      return this.GetInStateTime() >= result.value;
    };
    return false;
  }

  protected final const func ToMeleeIdle(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let result: StateResultFloat = stateContext.GetConditionFloatParameter(n"LeapExitTime");
    if result.valid {
      return this.GetInStateTime() >= result.value;
    };
    return false;
  }
}

public class MeleeLeapEvents extends MeleeEventsTransition {

  public let m_textLayerId: Uint32;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.LeapToTarget(stateContext, scriptInterface) {
      this.Leap(stateContext, scriptInterface);
    };
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearDebugText(scriptInterface, this.m_textLayerId);
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearDebugText(scriptInterface, this.m_textLayerId);
    this.OnForcedExit(stateContext, scriptInterface);
  }

  private final func LeapToTarget(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let additionalHorizontalDistance: Float;
    let adjustPosition: Vector4;
    let exitTime: Float;
    let horizontalDistanceFromTarget: Float;
    let leapAngle: EulerAngles;
    let playerPuppetOrientation: Quaternion;
    let safetyDisplacement: Vector4;
    let scaledSafetyDisplacement: Vector4;
    let slideDuration: Float;
    let vecToTarget: Vector4;
    let target: ref<GameObject> = DefaultTransition.GetTargetObject(scriptInterface, this.GetStaticFloatParameterDefault("maxDistToTarget", 5.00));
    if !IsDefined(target) {
      return false;
    };
    vecToTarget = target.GetWorldPosition() - scriptInterface.executionOwner.GetWorldPosition();
    playerPuppetOrientation = scriptInterface.executionOwner.GetWorldOrientation();
    leapAngle = Vector4.ToRotation(vecToTarget);
    if -leapAngle.Pitch > this.GetStaticFloatParameterDefault("leapMaxPitch", 45.00) {
      return false;
    };
    if this.GetStaticBoolParameterDefault("useSafetyDisplacement", false) {
      safetyDisplacement.Y = this.GetStaticFloatParameterDefault("safetyDisplacement", 2.00);
      if vecToTarget.Z > 0.00 {
        safetyDisplacement.Y = safetyDisplacement.Y * -1.00;
      };
      horizontalDistanceFromTarget = Vector4.Length2D(vecToTarget);
      additionalHorizontalDistance = MaxF(safetyDisplacement.Y - horizontalDistanceFromTarget, 0.00);
      scaledSafetyDisplacement = safetyDisplacement * additionalHorizontalDistance;
      adjustPosition = Quaternion.Transform(playerPuppetOrientation, scaledSafetyDisplacement);
    };
    slideDuration = this.CalculateAdjustmentDuration(Vector4.Length(vecToTarget));
    exitTime = slideDuration - this.GetStaticFloatParameterDefault("attackStartupDuration", 0.00);
    stateContext.SetConditionFloatParameter(n"LeapExitTime", exitTime, true);
    this.RequestPlayerPositionAdjustment(stateContext, scriptInterface, target, slideDuration, 0.90, -1.00, adjustPosition, true);
    return true;
  }

  private final func Leap(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let adjustPosition: Vector4;
    let exitTime: Float;
    let slideDuration: Float;
    let vecToTarget: Vector4;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let leapAngle: EulerAngles = Transform.ToEulerAngles(cameraWorldTransform);
    if leapAngle.Pitch > this.GetStaticFloatParameterDefault("noTargetMaxPitch", 45.00) {
      leapAngle.Pitch = this.GetStaticFloatParameterDefault("noTargetMaxPitch", 45.00);
      Transform.SetOrientationEuler(cameraWorldTransform, leapAngle);
    };
    vecToTarget = Transform.GetForward(cameraWorldTransform) * this.GetStaticFloatParameterDefault("noTargetLeapDistance", 5.00);
    adjustPosition = scriptInterface.executionOwner.GetWorldPosition() + vecToTarget;
    slideDuration = this.CalculateAdjustmentDuration(this.GetStaticFloatParameterDefault("noTargetLeapDistance", 5.00));
    exitTime = slideDuration - this.GetStaticFloatParameterDefault("attackStartupDuration", 0.00);
    stateContext.SetConditionFloatParameter(n"LeapExitTime", exitTime, true);
    this.RequestPlayerPositionAdjustment(stateContext, scriptInterface, null, slideDuration, 0.00, -1.00, adjustPosition, true);
  }

  private final func CalculateAdjustmentDuration(distance: Float) -> Float {
    let duration: Float;
    let minDist: Float = this.GetStaticFloatParameterDefault("minDistToTarget", 1.00);
    let maxDist: Float = this.GetStaticFloatParameterDefault("maxDistToTarget", 1.00);
    let minDur: Float = this.GetStaticFloatParameterDefault("minAdjustmentDuration", 1.00);
    let maxDur: Float = this.GetStaticFloatParameterDefault("maxAdjustmentDuration", 1.00);
    distance -= minDist;
    maxDist -= minDist;
    duration = LerpF(distance / maxDist, minDur, maxDur, true);
    return duration;
  }
}

public class MeleeDashDecisions extends MeleeTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let performCheck: Bool;
    if stateContext.IsStateActive(n"Locomotion", n"sprint") {
      performCheck = true;
    };
    if !scriptInterface.IsOnGround() && DefaultTransition.Get2DLinearSpeed(scriptInterface) > 5.00 {
      performCheck = true;
    };
    if !MeleeTransition.AnyMeleeAttackPressed(scriptInterface) {
      performCheck = false;
    };
    if !performCheck {
      return false;
    };
    if !scriptInterface.IsOnGround() {
      return false;
    };
    if !this.HasWeaponStatFlag(scriptInterface, gamedataStatType.CanWeaponDash) {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanMeleeDash) {
      return false;
    };
    if !this.HasAttackRecord(scriptInterface, "meleeSprintAttack") {
      return false;
    };
    if IsDefined(DefaultTransition.GetTargetObject(scriptInterface, this.GetStaticFloatParameterDefault("minTargetDistanceToDash", 2.00))) {
      return false;
    };
    if !this.CheckDashCollision(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }

  protected final const func CheckDashCollision(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let staticQueryFilter: QueryFilter;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    QueryFilter.AddGroup(staticQueryFilter, n"Static");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.refPosition = Transform.GetPosition(cameraWorldTransform);
    geometryDescription.refDirection = Transform.GetForward(cameraWorldTransform);
    geometryDescription.filter = staticQueryFilter;
    geometryDescription.primitiveDimension = new Vector4(0.10, 0.10, 0.10, 0.00);
    geometryDescription.maxDistance = 5.00;
    geometryDescription.maxExtent = 5.00;
    geometryDescription.probingPrecision = 0.05;
    geometryDescription.probingMaxDistanceDiff = 5.00;
    geometryDescription.AddFlag(worldgeometryDescriptionQueryFlags.DistanceVector);
    geometryDescriptionResult = scriptInterface.GetSpatialQueriesSystem().GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    if Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.NoGeometry) {
      return true;
    };
    return false;
  }

  protected final const func ToMeleeSprintAttack(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let attackData: ref<MeleeAttackData>;
    let duration: Float;
    if this.GetAttackDataFromStateName(stateContext, scriptInterface, "meleeSprintAttack", 0, attackData) {
      duration = this.GetStaticFloatParameterDefault("slideDuration", 1.00) - attackData.attackEffectDelay;
    } else {
      duration = this.GetStaticFloatParameterDefault("timeToStartAttack", 1.00);
    };
    if this.GetInStateTime() >= duration {
      return true;
    };
    return false;
  }

  protected final const func ToMeleeIdle(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("timeout", 1.00);
  }
}

public class MeleeDashEvents extends MeleeEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.DashToTarget(stateContext, scriptInterface) {
      this.Dash(stateContext, scriptInterface);
    };
    this.OnEnter(stateContext, scriptInterface);
  }

  private final func DashToTarget(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let additionalHorizontalDistance: Float;
    let adjustPosition: Vector4;
    let horizontalDistanceFromTarget: Float;
    let leapAngle: EulerAngles;
    let playerPuppetOrientation: Quaternion;
    let safetyDisplacement: Vector4;
    let scaledSafetyDisplacement: Vector4;
    let slideDuration: Float;
    let vecToTarget: Vector4;
    let target: ref<GameObject> = DefaultTransition.GetTargetObject(scriptInterface, this.GetStaticFloatParameterDefault("maxDistToAquireTarget", 5.00));
    if !IsDefined(target) {
      return false;
    };
    vecToTarget = target.GetWorldPosition() - scriptInterface.executionOwner.GetWorldPosition();
    playerPuppetOrientation = scriptInterface.executionOwner.GetWorldOrientation();
    leapAngle = Vector4.ToRotation(vecToTarget);
    if -leapAngle.Pitch > this.GetStaticFloatParameterDefault("dashMaxPitch", 45.00) {
      return false;
    };
    safetyDisplacement.Y = 2.00;
    if vecToTarget.Z > 0.00 {
      safetyDisplacement.Y = safetyDisplacement.Y * -1.00;
    };
    horizontalDistanceFromTarget = Vector4.Length2D(vecToTarget);
    additionalHorizontalDistance = MaxF(safetyDisplacement.Y - horizontalDistanceFromTarget, 0.00);
    scaledSafetyDisplacement = safetyDisplacement * additionalHorizontalDistance;
    adjustPosition = Quaternion.Transform(playerPuppetOrientation, scaledSafetyDisplacement);
    slideDuration = this.GetStaticFloatParameterDefault("slideDuration", 0.30);
    this.RequestPlayerPositionAdjustment(stateContext, scriptInterface, target, slideDuration, 0.90, -1.00, adjustPosition);
    return true;
  }

  private final func Dash(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let adjustPosition: Vector4;
    let slideDuration: Float;
    let vecToTarget: Vector4;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let leapAngle: EulerAngles = Transform.ToEulerAngles(cameraWorldTransform);
    if leapAngle.Pitch > this.GetStaticFloatParameterDefault("noTargetMaxPitch", 45.00) {
      leapAngle.Pitch = this.GetStaticFloatParameterDefault("noTargetMaxPitch", 45.00);
      Transform.SetOrientationEuler(cameraWorldTransform, leapAngle);
    };
    vecToTarget = Transform.GetForward(cameraWorldTransform) * this.GetStaticFloatParameterDefault("noTargetDashDistance", 5.00);
    adjustPosition = scriptInterface.executionOwner.GetWorldPosition() + vecToTarget;
    slideDuration = this.GetStaticFloatParameterDefault("slideDuration", 0.30);
    this.RequestPlayerPositionAdjustment(stateContext, scriptInterface, null, slideDuration, 0.00, -1.00, adjustPosition);
  }
}

public class MeleeBlockAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsBlockHeld(stateContext, scriptInterface) {
      return false;
    };
    if !(MeleeTransition.AnyMeleeAttackPressed(scriptInterface) || stateContext.GetConditionBool(n"LightMeleeAttackPressed")) {
      return false;
    };
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName())) {
      return false;
    };
    return true;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let attackData: ref<MeleeAttackData> = this.GetAttackData(stateContext);
    let inStateTime: Float = this.GetInStateTime();
    if this.IsBlockHeld(stateContext, scriptInterface) {
      if attackData.blockTransitionTime > 0.00 && inStateTime >= attackData.blockTransitionTime {
        return true;
      };
    };
    if stateContext.GetConditionBool(n"LightMeleeAttackPressed") && inStateTime >= attackData.attackWindowClosed {
      return true;
    };
    if inStateTime >= attackData.idleTransitionTime {
      return true;
    };
    return false;
  }
}

public class MeleeBlockAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Block;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.BlockAttack));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeCrouchAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !(stateContext.IsStateActive(n"Locomotion", n"crouch") || stateContext.IsStateActive(n"Locomotion", n"slide")) {
      return false;
    };
    if !MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) {
      return false;
    };
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName())) {
      return false;
    };
    return true;
  }
}

public class MeleeCrouchAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Crouch;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.CrouchAttack));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeJumpAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !(scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Jump) || stateContext.IsStateActive(n"Locomotion", n"fall")) {
      return false;
    };
    if !MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) {
      return false;
    };
    if !this.EnterCondition(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }
}

public class MeleeJumpAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Jump;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.JumpAttack));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeSprintAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let performCheck: Bool;
    if stateContext.IsStateActive(n"Locomotion", n"sprint") {
      performCheck = true;
    };
    if !scriptInterface.IsOnGround() && DefaultTransition.Get2DLinearSpeed(scriptInterface) > 5.00 {
      performCheck = true;
    };
    if !performCheck {
      return false;
    };
    if !MeleeTransition.WantsToLightAttack(stateContext, scriptInterface) {
      return false;
    };
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName())) {
      return false;
    };
    return true;
  }
}

public class MeleeSprintAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Sprint;
  }

  public final func OnEnterFromMeleeDash(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.m_blockImpulseCreation = true;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.SprintAttack));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class MeleeEquipAttackDecisions extends MeleeAttackGenericDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.EquipAttackCondition(stateContext, scriptInterface) {
      return false;
    };
    if !this.HasAttackRecord(scriptInterface, NameToString(this.GetStateName())) {
      return false;
    };
    return true;
  }
}

public class MeleeEquipAttackEvents extends MeleeAttackGenericEvents {

  protected final func GetAttackType() -> EMeleeAttackType {
    return EMeleeAttackType.Equip;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetAttackNumber(stateContext);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon, EnumInt(gamePSMMeleeWeapon.EquipAttack));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}
