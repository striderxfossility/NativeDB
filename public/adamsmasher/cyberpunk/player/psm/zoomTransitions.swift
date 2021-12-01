
public abstract class ZoomTransitionHelper extends IScriptable {

  public final static func GetReevaluateZoomName() -> CName {
    return n"ReevaluateZoom";
  }
}

public abstract class ZoomTransition extends DefaultTransition {

  public final const func IsControllingDevice(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice);
  }

  public final const func IsDeviceOrFocusActive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsControllingDevice(stateContext, scriptInterface) || this.IsInVisionModeActiveState(stateContext, scriptInterface);
  }

  public final const func IsDeviceAndFocusInactive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsControllingDevice(stateContext, scriptInterface) && !this.IsInVisionModeActiveState(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  public const func ShouldPlayZoomExitSound() -> Bool {
    return true;
  }

  public const func ShouldPlayZoomStepSound() -> Bool {
    return true;
  }

  protected final func ShouldPlayZoomFX(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let stateName: CName = this.GetStateName();
    if scriptInterface.owner.IsControlledByAnotherClient() || IsServer() {
      return false;
    };
    if stateContext.GetBoolParameter(n"ReevaluateAiming", false) {
      return false;
    };
    if this.IsControllingDevice(stateContext, scriptInterface) || this.IsInVisionModeActiveState(stateContext, scriptInterface) {
      return true;
    };
    if Equals(stateName, n"zoomLevelBase") || Equals(stateName, n"zoomLevelAim") {
      return false;
    };
    return true;
  }

  protected final func StartZoomEffect(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let blackboard: ref<worldEffectBlackboard>;
    let clampedValue: Float;
    if !this.ShouldPlayZoomFX(stateContext, scriptInterface) {
      return;
    };
    clampedValue = this.GetCurrentZoomLevel(stateContext) / 8.00;
    blackboard = new worldEffectBlackboard();
    blackboard.SetValue(n"zoomLevel", clampedValue);
    this.StartEffect(scriptInterface, n"zoom", blackboard);
  }

  protected final func PlayFocusModeZoomEnterSound(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.ShouldPlayZoomFX(stateContext, scriptInterface) {
      return;
    };
    if !IsDefined(DefaultTransition.GetActiveWeapon(scriptInterface)) {
      this.PlaySound(n"ui_focus_mode_zooming_in_enter", scriptInterface);
      this.StartZoomEffect(stateContext, scriptInterface);
    };
  }

  protected final func PlayZoomEndVisualEffect(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.ShouldPlayZoomFX(stateContext, scriptInterface) {
      return;
    };
    this.StartEffect(scriptInterface, n"zoom_end");
  }

  protected final func SetCurrentZoomLevel(stateContext: ref<StateContext>, zoomLevel: Int32) -> Void {
    let value: Float = this.GetZoomValueFromLevel(stateContext, zoomLevel);
    stateContext.SetPermanentFloatParameter(n"zoomLevel", value, true);
  }

  protected final func SetPreviousZoomLevel(stateContext: ref<StateContext>, value: Float) -> Void {
    stateContext.SetPermanentFloatParameter(n"previousZoomLevel", value, true);
  }

  protected final func SetBlendTime(stateContext: ref<StateContext>, value: Float) -> Void {
    stateContext.SetPermanentFloatParameter(n"blendTime", value, true);
  }

  protected final func SetZoomLevelNumber(stateContext: ref<StateContext>, value: Int32) -> Void {
    stateContext.SetPermanentIntParameter(n"zoomLvlNumber", value, true);
  }

  protected final func SetShouldUseWeaponZoomData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let flag: Bool;
    if IsDefined(DefaultTransition.GetActiveWeapon(scriptInterface)) && !this.IsInVisionModeActiveState(stateContext, scriptInterface) && !stateContext.IsStateActive(n"Weapon", n"safe") {
      flag = true;
    } else {
      flag = false;
    };
    stateContext.SetPermanentBoolParameter(n"shouldUseWeaponZoomStats", flag, true);
  }

  protected final func ResetShouldUseWeaponZoomData(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"shouldUseWeaponZoomStats", false, true);
  }

  public const func GetActualZoomValue(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    return this.GetCurrentZoomLevel(stateContext);
  }

  protected final const func GetCurrentZoomLevel(const stateContext: ref<StateContext>) -> Float {
    return stateContext.GetFloatParameter(n"zoomLevel", true);
  }

  protected final func GetPreviousZoomLevel(stateContext: ref<StateContext>) -> Float {
    return stateContext.GetFloatParameter(n"previousZoomLevel", true);
  }

  protected final const func GetNextZoomLevel(const stateContext: ref<StateContext>) -> Float {
    let zoomLevelNumber: Int32 = this.GetZoomLevelNumber(stateContext);
    return this.GetZoomValueFromLevel(stateContext, zoomLevelNumber + 1);
  }

  protected final func GetBlendTime(stateContext: ref<StateContext>) -> Float {
    return stateContext.GetFloatParameter(n"blendTime", true);
  }

  protected final const func GetZoomLevelNumber(const stateContext: ref<StateContext>) -> Int32 {
    return stateContext.GetIntParameter(n"zoomLvlNumber", true);
  }

  protected final func ResetAimType(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentIntParameter(n"AimType", EnumInt(aimTypeEnum.Invalid), true);
  }

  protected final func GetShouldUseWeaponZoomData(stateContext: ref<StateContext>) -> Bool {
    return stateContext.GetBoolParameter(n"shouldUseWeaponZoomStats", true);
  }

  protected final const func GetZoomValueFromLevel(stateContext: ref<StateContext>, index: Int32) -> Float {
    let zoomLevels: array<Float> = this.GetZoomLevelsArray(stateContext);
    if index < 0 || index >= ArraySize(zoomLevels) {
      return -1.00;
    };
    return zoomLevels[index];
  }

  protected final const func GetZoomLevelsArray(stateContext: ref<StateContext>) -> array<Float> {
    if Equals(stateContext.GetStateMachineCurrentState(n"LeftHandCyberware"), n"leftHandCyberwareCharge") {
      return this.GetStaticFloatArrayParameter("zoomLevelsCw");
    };
    return this.GetStaticFloatArrayParameter("zoomLevels");
  }

  protected final func SendZoomAnimFeatureData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    let stats: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let animFeatureData: ref<AnimFeature_Zoom> = new AnimFeature_Zoom();
    animFeatureData.finalZoomLevel = this.GetCurrentZoomLevel(stateContext);
    if IsDefined(weapon) {
      animFeatureData.weaponZoomLevel = stats.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ZoomLevel);
      animFeatureData.weaponScopeFov = stats.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ScopeFOV);
      animFeatureData.weaponAimFOV = stats.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.AimFOV);
    };
    animFeatureData.worldFOV = GameInstance.GetCameraSystem(scriptInterface.owner.GetGame()).GetActiveCameraFOV();
    animFeatureData.zoomLevelNum = this.GetZoomLevelNumber(stateContext);
    animFeatureData.noWeaponAimInTime = this.GetStaticFloatParameterDefault("noWeaponAimInTime", 0.20);
    animFeatureData.noWeaponAimOutTime = this.GetStaticFloatParameterDefault("noWeaponAimOutTime", 0.20);
    animFeatureData.shouldUseWeaponZoomStats = this.GetShouldUseWeaponZoomData(stateContext);
    animFeatureData.focusModeActive = this.IsInVisionModeActiveState(stateContext, scriptInterface) || stateContext.IsStateActive(n"UpperBody", n"temporaryUnequip");
    scriptInterface.SetAnimationParameterFeature(n"ZoomAnimData", animFeatureData);
  }
}

public class ZoomDecisionsTransition extends ZoomTransition {

  public const func ToNextZoomLevel(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"ZoomIn") {
      if !this.IsControllingDevice(stateContext, scriptInterface) {
        if !scriptInterface.HasStatFlag(gamedataStatType.CanUseZoom) {
          return false;
        };
        if this.IsAimingBlockedForTime(stateContext, scriptInterface) {
          return false;
        };
        if this.IsWeaponStateBlockingAiming(scriptInterface) {
          return false;
        };
        if this.GetCurrentZoomLevel(stateContext) != 1.00 && StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoZooming") {
          return false;
        };
      };
      return true;
    };
    return false;
  }

  public const func ToPreviousZoomLevel(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"ZoomOut") {
      if !this.IsControllingDevice(stateContext, scriptInterface) {
        if !scriptInterface.HasStatFlag(gamedataStatType.CanUseZoom) {
          return false;
        };
      };
      return true;
    };
    return false;
  }

  public const func ToBaseZoom(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let cycleBlock: StateResultBool;
    if this.IsAimingBlockedForTime(stateContext, scriptInterface) && NotEquals(stateContext.GetStateMachineCurrentState(n"LeftHandCyberware"), n"leftHandCyberwareCharge") {
      return true;
    };
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced) {
      return false;
    };
    if this.GetCurrentZoomLevel(stateContext) > 1.50 && StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoZooming") {
      return true;
    };
    if this.IsWeaponStateBlockingAiming(scriptInterface) {
      return true;
    };
    if this.IsRightHandInUnequippingState(stateContext) || this.IsLeftHandInUnequippingState(stateContext) {
      return true;
    };
    cycleBlock = stateContext.GetConditionBoolParameter(n"cycleRoundBlockZoom");
    if cycleBlock.valid && cycleBlock.value {
      return true;
    };
    if !this.IsInUpperBodyState(stateContext, n"aimingState") && this.IsDeviceAndFocusInactive(stateContext, scriptInterface) && NotEquals(stateContext.GetStateMachineCurrentState(n"LeftHandCyberware"), n"leftHandCyberwareCharge") {
      return true;
    };
    if this.IsDeviceAndFocusInactive(stateContext, scriptInterface) {
      if scriptInterface.GetActionValue(n"CameraAim") == 0.00 && NotEquals(stateContext.GetStateMachineCurrentState(n"LeftHandCyberware"), n"leftHandCyberwareCharge") {
        return true;
      };
    };
    if stateContext.GetBoolParameter(n"ReevaluateAiming", false) {
      return true;
    };
    return false;
  }

  public const func ToScanWithLhCyberware(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }
}

public class ZoomEventsTransition extends ZoomTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let zoomLevelNumber: Int32 = this.GetStaticIntParameterDefault("zoomLevelNumber", 1);
    this.SetPreviousZoomLevel(stateContext, this.GetCurrentZoomLevel(stateContext));
    this.SetCurrentZoomLevel(stateContext, zoomLevelNumber);
    this.SetZoomLevelNumber(stateContext, zoomLevelNumber);
    this.SetBlackboardFloatVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.GetCurrentZoomLevel(stateContext));
    this.SendZoomAnimFeatureData(stateContext, scriptInterface);
    if !this.IsInVisionModeActiveState(stateContext, scriptInterface) {
      if zoomLevelNumber > 1 {
        this.PlaySound(n"ST_Focus_Mode_On_Set_State", scriptInterface);
      } else {
        this.PlaySound(n"ST_Focus_Mode_Off_Set_State", scriptInterface);
      };
    };
  }

  public func OnExitToZoomLevelBase(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.ShouldPlayZoomExitSound() && scriptInterface.HasStatFlag(gamedataStatType.CanUseZoom) {
      this.PlaySound(n"ui_focus_mode_zooming_in_exit", scriptInterface);
    };
    this.BreakEffectLoop(scriptInterface, n"zoom");
    this.PlayZoomEndVisualEffect(stateContext, scriptInterface);
    stateContext.SetPermanentIntParameter(n"AimType", EnumInt(aimTypeEnum.AimOut), true);
    this.SendZoomAnimFeatureData(stateContext, scriptInterface);
  }

  public func OnExitToNextZoomLevel(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.ShouldPlayZoomStepSound() {
      this.PlaySound(n"ui_focus_mode_zooming_in_step_change", scriptInterface);
    };
    this.BreakEffectLoop(scriptInterface, n"zoom");
  }

  public func OnExitToPreviousZoomLevel(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.ShouldPlayZoomStepSound() {
      this.PlaySound(n"ui_focus_mode_zooming_in_step_change", scriptInterface);
    };
    this.BreakEffectLoop(scriptInterface, n"zoom");
  }
}

public class ZoomBlockedDecisions extends ZoomDecisionsTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.IsStateMachineActive(n"Vehicle") && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) != EnumInt(gamePSMHighLevel.SceneTier3) {
      if !this.IsDeviceOrFocusActive(stateContext, scriptInterface) && !this.IsInUpperBodyState(stateContext, n"aimingState") {
        return true;
      };
      if Equals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"exiting") {
        return true;
      };
    };
    return false;
  }

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.EnterCondition(stateContext, scriptInterface);
  }
}

public class ZoomBlockedEvents extends ZoomEventsTransition {

  public let previousCameraPerspective: vehicleCameraPerspective;

  public let previousCameraPerspectiveValid: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if stateContext.IsStateMachineActive(n"Vehicle") {
      if this.previousCameraPerspectiveValid && NotEquals(this.previousCameraPerspective, vehicleCameraPerspective.FPP) {
        this.RequestVehicleCameraPerspective(scriptInterface, this.previousCameraPerspective);
        this.SetZoomStateAnimFeature(scriptInterface, false);
      };
    };
    this.SetBlendTime(stateContext, this.GetStaticFloatParameterDefault("blendTime", 0.20));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MaxZoomLevel, this.GetZoomLevelNumber(stateContext));
    this.OnEnter(stateContext, scriptInterface);
    this.StopEffect(scriptInterface, n"zoom");
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if stateContext.IsStateMachineActive(n"Vehicle") {
      this.previousCameraPerspective = GetMountedVehicle(scriptInterface.executionOwner).GetCameraManager().GetActivePerspective();
      this.previousCameraPerspectiveValid = true;
    };
  }

  public func OnExitToZoomLevelBase(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class ZoomLevelBaseDecisions extends ZoomDecisionsTransition {

  protected final const func ToZoomLevelAim(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ToNextZoomLevel(stateContext, scriptInterface) && this.IsDeviceOrFocusActive(stateContext, scriptInterface) {
      return true;
    };
    if this.IsControllingDevice(stateContext, scriptInterface) {
      return false;
    };
    if this.IsInVisionModeActiveState(stateContext, scriptInterface) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) {
      return true;
    };
    if Equals(stateContext.GetStateMachineCurrentState(n"LeftHandCyberware"), n"leftHandCyberwareCharge") {
      return true;
    };
    return false;
  }
}

public class ZoomLevelBaseEvents extends ZoomEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlendTime(stateContext, this.GetStaticFloatParameterDefault("blendTime", 0.20));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.MaxZoomLevel, this.GetZoomLevelNumber(stateContext));
    this.OnEnter(stateContext, scriptInterface);
    this.StopEffect(scriptInterface, n"zoom");
  }

  protected final func OnExitToZoomLevelAim(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentIntParameter(n"AimType", EnumInt(aimTypeEnum.AimIn), true);
  }
}

public class ZoomLevelAimDecisions extends ZoomDecisionsTransition {

  public const func ToBaseZoom(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.ToBaseZoom(stateContext, scriptInterface) {
      return true;
    };
    if this.IsDeviceOrFocusActive(stateContext, scriptInterface) && this.ToPreviousZoomLevel(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  public final const func ToScanZoomLevel(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let adsZoomIndex: StateResultInt = stateContext.GetConditionIntParameter(n"adsZoomIndex");
    if !adsZoomIndex.valid {
      return this.ToNextZoomLevel(stateContext, scriptInterface);
    };
    if adsZoomIndex.value == 2 || adsZoomIndex.value == 1 {
      return this.ToNextZoomLevel(stateContext, scriptInterface);
    };
    return false;
  }

  public final const func ToZoomLevel3(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let adsZoomIndex: StateResultInt = stateContext.GetConditionIntParameter(n"adsZoomIndex");
    if !adsZoomIndex.valid {
      return false;
    };
    if adsZoomIndex.value == 3 {
      return this.ToNextZoomLevel(stateContext, scriptInterface);
    };
    if adsZoomIndex.value == 4 {
      return this.ToPreviousZoomLevel(stateContext, scriptInterface);
    };
    return false;
  }

  public final const func ToZoomLevel4(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let adsZoomIndex: StateResultInt = stateContext.GetConditionIntParameter(n"adsZoomIndex");
    if !adsZoomIndex.valid {
      return false;
    };
    if adsZoomIndex.value == 4 {
      return this.ToNextZoomLevel(stateContext, scriptInterface);
    };
    if adsZoomIndex.value > 4 {
      return this.ToPreviousZoomLevel(stateContext, scriptInterface);
    };
    return false;
  }

  public const func GetActualZoomValue(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let stats: ref<StatsSystem>;
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    if IsDefined(weapon) {
      stats = scriptInterface.GetStatsSystem();
      if IsDefined(stats) {
        return stats.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ZoomLevel);
      };
    };
    return this.GetCurrentZoomLevel(stateContext);
  }
}

public class ZoomLevelAimEvents extends ZoomEventsTransition {

  public let isAmingWithWeapon: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let prevZoomLevel: Float;
    this.isAmingWithWeapon = IsDefined(DefaultTransition.GetActiveWeapon(scriptInterface));
    if !this.IsControllingDevice(stateContext, scriptInterface) && stateContext.IsStateMachineActive(n"Vehicle") {
      this.RequestVehicleCameraPerspective(scriptInterface, vehicleCameraPerspective.FPP);
      this.SetZoomStateAnimFeature(scriptInterface, true);
    };
    this.SetShouldUseWeaponZoomData(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
    prevZoomLevel = this.GetPreviousZoomLevel(stateContext);
    if prevZoomLevel > 1.00 {
      this.PlaySound(n"ui_focus_mode_zooming_in_step_change", scriptInterface);
    } else {
      this.PlayFocusModeZoomEnterSound(stateContext, scriptInterface);
    };
    this.ReevaluateADSZoomIndex(stateContext, scriptInterface);
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ResetShouldUseWeaponZoomData(stateContext);
    this.SendZoomAnimFeatureData(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if stateContext.GetBoolParameter(ZoomTransitionHelper.GetReevaluateZoomName(), false) {
      stateContext.SetTemporaryBoolParameter(n"ReevaluateZoom", false, true);
      this.SetShouldUseWeaponZoomData(stateContext, scriptInterface);
      this.SendZoomAnimFeatureData(stateContext, scriptInterface);
    };
  }

  public func OnExitToZoomLevelBase(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExitToZoomLevelBase(stateContext, scriptInterface);
  }

  public const func ShouldPlayZoomExitSound() -> Bool {
    return !this.isAmingWithWeapon;
  }

  public const func ShouldPlayZoomStepSound() -> Bool {
    return false;
  }

  private final func ReevaluateADSZoomIndex(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let adsZoomIndex: Int32;
    let actualZoom: Float = this.GetActualZoomValue(stateContext, scriptInterface);
    let zoomLevels: array<Float> = this.GetZoomLevelsArray(stateContext);
    let i: Int32 = 0;
    while i < ArraySize(zoomLevels) {
      if zoomLevels[i] > actualZoom {
      } else {
        i += 1;
      };
    };
    adsZoomIndex = i;
    stateContext.SetConditionIntParameter(n"adsZoomIndex", adsZoomIndex, true);
  }

  public const func GetActualZoomValue(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let stats: ref<StatsSystem>;
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    if IsDefined(weapon) {
      stats = scriptInterface.GetStatsSystem();
      if IsDefined(stats) {
        return stats.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ZoomLevel);
      };
    };
    return this.GetCurrentZoomLevel(stateContext);
  }
}

public class ZoomLevelScanDecisions extends ZoomDecisionsTransition {

  public const func ToBaseZoom(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"RangedAttack") {
      return true;
    };
    if this.ToBaseZoom(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToZoomLevelAim(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let adsZoomIndex: StateResultInt = stateContext.GetConditionIntParameter(n"adsZoomIndex");
    if !adsZoomIndex.valid {
      return false;
    };
    if adsZoomIndex.value == 2 || adsZoomIndex.value == 1 {
      return this.ToPreviousZoomLevel(stateContext, scriptInterface);
    };
    if adsZoomIndex.value == 3 {
      return this.ToNextZoomLevel(stateContext, scriptInterface);
    };
    return false;
  }
}

public class ZoomLevelScanEvents extends ZoomEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlaySound(n"ui_focus_mode_zooming_in_step_change", scriptInterface);
    this.StartZoomEffect(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected final func OnExitToZoomLevelAim(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlayZoomEndVisualEffect(stateContext, scriptInterface);
  }
}

public class ZoomLevel3Decisions extends ZoomDecisionsTransition {

  public const func ToBaseZoom(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"RangedAttack") {
      return true;
    };
    if this.ToBaseZoom(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToZoomLevelAim(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let adsZoomIndex: StateResultInt = stateContext.GetConditionIntParameter(n"adsZoomIndex");
    if !adsZoomIndex.valid {
      return false;
    };
    if adsZoomIndex.value == 3 {
      return this.ToPreviousZoomLevel(stateContext, scriptInterface);
    };
    if adsZoomIndex.value == 4 {
      return this.ToNextZoomLevel(stateContext, scriptInterface);
    };
    return false;
  }
}

public class ZoomLevel3Events extends ZoomEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlaySound(n"ui_focus_mode_zooming_in_step_change", scriptInterface);
    this.StartZoomEffect(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class ZoomLevel4Decisions extends ZoomDecisionsTransition {

  protected final const func ToZoomLevelAim(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let adsZoomIndex: StateResultInt = stateContext.GetConditionIntParameter(n"adsZoomIndex");
    if !adsZoomIndex.valid {
      return false;
    };
    if adsZoomIndex.value == 4 {
      return this.ToPreviousZoomLevel(stateContext, scriptInterface);
    };
    if adsZoomIndex.value > 4 {
      return this.ToNextZoomLevel(stateContext, scriptInterface);
    };
    return false;
  }

  public const func ToBaseZoom(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"RangedAttack") {
      return true;
    };
    if this.ToBaseZoom(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }
}

public class ZoomLevel4Events extends ZoomEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlaySound(n"ui_focus_mode_zooming_in_step_change", scriptInterface);
    this.StartZoomEffect(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public final func OnExitToZoomLevelAim(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlaySound(n"ui_focus_mode_zooming_in_exit", scriptInterface);
    this.StartZoomEffect(stateContext, scriptInterface);
  }

  public final func OnExitToBaseZoom(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlaySound(n"ui_focus_mode_zooming_in_exit", scriptInterface);
  }
}
