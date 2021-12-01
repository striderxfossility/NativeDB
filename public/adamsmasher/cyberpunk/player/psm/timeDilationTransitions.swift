
public class TimeDilationTransitions extends DefaultTransition {

  protected final const func IsSandevistanActivationRequested(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"requestSandevistanActivation", false);
  }

  protected final const func IsForceDeactivationRequested(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"requestSandevistanDeactivation", false) || stateContext.GetBoolParameter(n"requestKerenzikovDeactivation", false);
  }

  protected final const func IsSandevistanDeactivationRequested(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"requestSandevistanDeactivation", false);
  }

  protected final const func IsKerenzikovActivationRequested(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"requestKerenzikovActivation", false);
  }

  protected final const func IsKerenzikovDeactivationRequested(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"requestKerenzikovDeactivation", false);
  }

  protected final const func IsRequiredStateActive(const stateContext: ref<StateContext>) -> Bool {
    return this.IsInLocomotionState(stateContext, n"dodge") || this.IsInLocomotionState(stateContext, n"dodgeAir") || this.IsInLocomotionState(stateContext, n"slide");
  }

  protected final const func IsInVisionMode(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
  }

  protected final const func IsChangingTarget(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isQuickHackScreenActivated: StateResultBool = stateContext.GetTemporaryBoolParameter(n"quickHackChangeTarget");
    return isQuickHackScreenActivated.valid && isQuickHackScreenActivated.value;
  }

  protected final const func IsTargetChanged(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isQuickHackScreenActivated: StateResultBool = stateContext.GetTemporaryBoolParameter(n"quickHackChangeTarget");
    return isQuickHackScreenActivated.valid && !isQuickHackScreenActivated.value;
  }

  protected final const func IsPlayerMovementDetected(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsMoveInputConsiderable();
  }

  protected final const func IsCameraRotated(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"CameraMouseX") != 0.00 || scriptInterface.GetActionValue(n"CameraX") != 0.00 || scriptInterface.GetActionValue(n"CameraMouseY") != 0.00 || scriptInterface.GetActionValue(n"CameraY") != 0.00 {
      return true;
    };
    if this.IsChangingTarget(stateContext, scriptInterface) {
      return true;
    };
    if this.IsTargetChanged(stateContext, scriptInterface) {
      return false;
    };
    return false;
  }

  protected final const func GetBoolFromTimeSystemTweak(tweakDBPath: String, paramName: String) -> Bool {
    return TweakDBInterface.GetBool(TDBID.Create("timeSystem." + tweakDBPath + "." + paramName), false);
  }

  protected final const func GetFloatFromTimeSystemTweak(tweakDBPath: String, paramName: String) -> Float {
    return TweakDBInterface.GetFloat(TDBID.Create("timeSystem." + tweakDBPath + "." + paramName), 0.00);
  }

  protected final const func GetCNameFromTimeSystemTweak(tweakDBPath: String, paramName: String) -> CName {
    return TweakDBInterface.GetCName(TDBID.Create("timeSystem." + tweakDBPath + "." + paramName), n"");
  }
}

public class TimeDilationEventsTransitions extends TimeDilationTransitions {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  protected final func SetTimeDilationGlobal(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, reason: CName, timeDilation: Float, opt duration: Float, easeInCurve: CName, easeOutCurve: CName, opt listener: ref<TimeDilationListener>) -> Void {
    let timeSystem: ref<TimeSystem> = scriptInterface.GetTimeSystem();
    if Equals(reason, TimeDilationHelper.GetSandevistanKey()) || Equals(reason, TimeDilationHelper.GetFocusModeKey()) && !this.GetBoolFromTimeSystemTweak("focusModeTimeDilation", "applyTimeDilationToPlayer") {
      timeSystem.SetIgnoreTimeDilationOnLocalPlayerZero(true);
    } else {
      timeSystem.SetIgnoreTimeDilationOnLocalPlayerZero(false);
    };
    timeSystem.SetTimeDilation(reason, timeDilation, duration, easeInCurve, easeOutCurve, listener);
  }

  protected final func SetTimeDilationOnLocalPlayer(reason: CName, timeDilation: Float, opt duration: Float, easeInCurve: CName, easeOutCurve: CName, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let timeSystem: ref<TimeSystem> = scriptInterface.GetTimeSystem();
    timeSystem.SetTimeDilationOnLocalPlayerZero(reason, timeDilation, duration, easeInCurve, easeOutCurve, true);
  }

  protected final func SetCameraTimeDilationCurve(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, curveName: CName) -> Void {
    scriptInterface.SetCameraTimeDilationCurve(curveName);
  }

  protected final func UnsetTimeDilation(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, reason: CName, opt easeOutCurve: CName) -> Void {
    let cleanUpTimeDilationEvt: ref<CleanUpTimeDilationEvent>;
    let timeSystem: ref<TimeSystem> = scriptInterface.GetTimeSystem();
    if !IsNameValid(easeOutCurve) || this.IsForceDeactivationRequested(stateContext, scriptInterface) {
      timeSystem.UnsetTimeDilation(reason, n"");
      timeSystem.UnsetTimeDilationOnLocalPlayerZero(n"");
    } else {
      timeSystem.UnsetTimeDilation(reason, easeOutCurve);
      timeSystem.UnsetTimeDilationOnLocalPlayerZero(easeOutCurve);
    };
    if !IsDefined(cleanUpTimeDilationEvt) {
      cleanUpTimeDilationEvt = new CleanUpTimeDilationEvent();
      cleanUpTimeDilationEvt.reason = reason;
      GameInstance.GetDelaySystem(scriptInterface.executionOwner.GetGame()).DelayEvent(scriptInterface.executionOwner, cleanUpTimeDilationEvt, 1.00, false);
    };
  }
}

public class SandevistanDecisions extends TimeDilationTransitions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if DefaultTransition.IsInWorkspot(scriptInterface) {
      return false;
    };
    if IsMultiplayer() {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.HasSandevistan) {
      return false;
    };
    if this.IsTimeDilationActive(stateContext, scriptInterface, n"") {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Grapple) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Takedown) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) != EnumInt(gamePSMHighLevel.SceneTier1) {
      return false;
    };
    if !this.EnterSandevistan(stateContext, scriptInterface) {
      return false;
    };
    return true;
  }

  private final const func EnterSandevistan(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsSandevistanActivationRequested(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToTimeDilationReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if DefaultTransition.IsInWorkspot(scriptInterface) {
      return true;
    };
    if this.IsSandevistanDeactivationRequested(stateContext, scriptInterface) {
      return true;
    };
    if !this.IsTimeDilationActive(stateContext, scriptInterface, TimeDilationHelper.GetSandevistanKey()) {
      return true;
    };
    if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.SandevistanPlayerBuff") {
      return true;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.HasSandevistan) {
      return false;
    };
    return false;
  }
}

public class SandevistanEvents extends TimeDilationEventsTransitions {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let easeInCurve: CName;
    let easeOutCurve: CName;
    let timeDilation: Float;
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.TimeDilation, EnumInt(gamePSMTimeDilation.Sandevistan));
    timeDilation = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.executionOwnerEntityID), gamedataStatType.TimeDilationSandevistanTimeScale);
    easeInCurve = TweakDBInterface.GetCName(t"cyberware.sandevistan.easeInCurve", n"SandevistanEaseIn");
    easeOutCurve = TweakDBInterface.GetCName(t"cyberware.sandevistan.easeOutCurve", n"SandevistanEaseOut");
    this.SetCameraTimeDilationCurve(stateContext, scriptInterface, n"Sandevistan");
    this.SetTimeDilationGlobal(stateContext, scriptInterface, TimeDilationHelper.GetSandevistanKey(), timeDilation, 999.00, easeInCurve, easeOutCurve);
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UnsetTimeDilation(stateContext, scriptInterface, TimeDilationHelper.GetSandevistanKey(), n"SandevistanEaseOut");
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.TimeDilation, EnumInt(gamePSMTimeDilation.Default));
    stateContext.SetPermanentFloatParameter(n"SandevistanDeactivationTimeStamp", scriptInterface.GetNow(), true);
    this.UnsetTimeDilation(stateContext, scriptInterface, TimeDilationHelper.GetSandevistanKey(), n"SandevistanEaseOut");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.SandevistanPlayerBuff");
  }
}

public class KerenzikovDecisions extends TimeDilationTransitions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if DefaultTransition.IsInWorkspot(scriptInterface) {
      return false;
    };
    if IsMultiplayer() {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.HasKerenzikov) {
      return false;
    };
    if this.IsTimeDilationActive(stateContext, scriptInterface, n"") {
      return false;
    };
    if this.IsKerenzikovActivationRequested(stateContext, scriptInterface) {
      return true;
    };
    if this.IsRequiredStateActive(stateContext) && this.IsRequiredAction(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  private final const func IsRequiredAction(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetStaticBoolParameterDefault("activateOnAim", true) && scriptInterface.GetActionValue(n"CameraAim") > 0.00 {
      return !this.IsInWeaponReloadState(scriptInterface);
    };
    if this.GetStaticBoolParameterDefault("activateOnShoot", true) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Shoot) {
      return !this.IsInWeaponReloadState(scriptInterface);
    };
    if this.GetStaticBoolParameterDefault("activateOnMeleeAttack", true) && this.IsMeleeAttackWindowOpen(stateContext, scriptInterface) {
      return true;
    };
    if this.GetStaticBoolParameterDefault("activateOnCyberware", true) && (Equals(stateContext.GetStateMachineCurrentState(n"LeftHandCyberware"), n"leftHandCyberwareCharge") || Equals(stateContext.GetStateMachineCurrentState(n"LeftHandCyberware"), n"leftHandCyberwareQuickAction")) {
      return true;
    };
    return false;
  }

  private final const func IsMeleeAttackWindowOpen(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"isAttacking", true) {
      return true;
    };
    return false;
  }

  protected final const func ToTimeDilationReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if DefaultTransition.IsInWorkspot(scriptInterface) {
      return true;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.HasKerenzikov) {
      return true;
    };
    if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.KerenzikovPlayerBuff") {
      return true;
    };
    if scriptInterface.IsActionJustReleased(n"CameraAim") {
      return true;
    };
    if this.IsKerenzikovDeactivationRequested(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }
}

public class KerenzikovEvents extends TimeDilationEventsTransitions {

  public let m_allowMovementModifier: ref<gameStatModifierData>;

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearKerenzikov(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ClearKerenzikov(stateContext, scriptInterface);
  }

  private final func ClearKerenzikov(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    this.UnsetTimeDilation(stateContext, scriptInterface, TimeDilationHelper.GetKerenzikovKey(), n"KerenzikovEaseOut");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.KerenzikovPlayerBuff");
    this.EnableAllowMovementInputStatModifier(stateContext, scriptInterface, false);
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let easeInCurve: CName;
    let easeOutCurve: CName;
    let playerDilation: Float;
    let timeDilation: Float;
    let timeDilationReason: CName;
    let isSliding: Bool = this.IsInSlidingState(stateContext);
    this.GetPlayerTimeDilation(stateContext, scriptInterface, isSliding, playerDilation);
    timeDilation = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.executionOwnerEntityID), gamedataStatType.TimeDilationKerenzikovTimeScale);
    easeInCurve = isSliding ? n"KerenzikovEaseIn" : n"DodgeEaseIn";
    easeOutCurve = n"KerenzikovEaseOut";
    timeDilationReason = TimeDilationHelper.GetKerenzikovKey();
    if !isSliding {
      this.EnableAllowMovementInputStatModifier(stateContext, scriptInterface, true);
    };
    if !UpperBodyTransition.HasAnyWeaponEquipped(scriptInterface) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Kereznikov));
    this.SetCameraTimeDilationCurve(stateContext, scriptInterface, n"Kerenzikov");
    this.SetTimeDilationGlobal(stateContext, scriptInterface, timeDilationReason, timeDilation, 999.00, easeInCurve, easeOutCurve);
    this.SetTimeDilationOnLocalPlayer(timeDilationReason, playerDilation, 999.00, easeInCurve, easeOutCurve, stateContext, scriptInterface);
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.KerenzikovPlayerBuff");
  }

  protected func GetPlayerTimeDilation(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isSliding: Bool, out playerDilation: Float) -> Void {
    let playerTimeScaleTarget: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.executionOwnerEntityID), gamedataStatType.TimeDilationKerenzikovPlayerTimeScale);
    playerDilation = isSliding ? playerDilation = playerTimeScaleTarget * 2.00 : playerTimeScaleTarget;
  }

  protected func EnableAllowMovementInputStatModifier(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, enable: Bool) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    if enable && !IsDefined(this.m_allowMovementModifier) {
      this.m_allowMovementModifier = RPGManager.CreateStatModifier(gamedataStatType.AllowMovementInput, gameStatModifierType.Additive, 1.00);
      scriptInterface.GetStatsSystem().AddModifier(ownerID, this.m_allowMovementModifier);
    } else {
      if !enable && IsDefined(this.m_allowMovementModifier) {
        scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.m_allowMovementModifier);
        this.m_allowMovementModifier = null;
      };
    };
  }
}

public class TimeDilationProgressWithInputDecisions extends TimeDilationTransitions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.executionOwner.GetHudManager().IsQuickHackPanelOpened() && this.CanActivate(stateContext, scriptInterface) && this.GetBoolFromTimeSystemTweak("quickHackScreen", "enableTimeDilation") {
      return true;
    };
    return false;
  }

  protected final const func ToTimeDilationReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.executionOwner.GetHudManager().IsQuickHackPanelOpened() || !this.CanActivate(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  private final const func CanActivate(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.IsOnGround() || this.IsInLocomotionState(stateContext, n"veryHardLand") || scriptInterface.executionOwner.IsDead() {
      return false;
    };
    return false;
  }
}

public class TimeDilationProgressWithInputEvents extends TimeDilationEventsTransitions {

  @default(TimeDilationProgressWithInputEvents, 0.f)
  public let m_targetTimeScale: Float;

  @default(TimeDilationProgressWithInputEvents, 0.f)
  public let m_lerpMultiplier: Float;

  @default(TimeDilationProgressWithInputEvents, 0.f)
  public let m_duration: Float;

  @default(TimeDilationProgressWithInputEvents, 0.f)
  public let m_previousTimeStamp: Float;

  public let m_easeInCurve: CName;

  public let m_easeOutCurve: CName;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_targetTimeScale = 0.00;
    this.m_lerpMultiplier = 0.00;
    this.m_duration = 0.00;
    this.m_previousTimeStamp = 0.00;
    this.m_easeInCurve = n"";
    this.m_easeOutCurve = n"";
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateTimeScaleBasedOnInput(stateContext, scriptInterface, timeDelta);
  }

  private final func UpdateTimeScaleBasedOnInput(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, timeDelta: Float) -> Void {
    let currentTweak: String;
    let isPlayerMoving: Bool = this.IsPlayerMovementDetected(stateContext, scriptInterface);
    let isCameraRotating: Bool = this.IsCameraRotated(stateContext, scriptInterface);
    if !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.OverrideQuickHackPanelDilation) {
      currentTweak = "quickHackScreen";
    } else {
      currentTweak = "quickHackScreenTutorial";
    };
    if isPlayerMoving && this.GetBoolFromTimeSystemTweak(currentTweak, "enableOnCharMovement") {
      this.m_targetTimeScale = this.GetFloatFromTimeSystemTweak(currentTweak, "timeScaleCharMovement");
      this.m_lerpMultiplier = this.GetFloatFromTimeSystemTweak(currentTweak, "lerpMultiplierCharMovement");
    } else {
      if isCameraRotating && this.GetBoolFromTimeSystemTweak(currentTweak, "enableOnCamMovement") {
        this.m_targetTimeScale = this.GetFloatFromTimeSystemTweak(currentTweak, "timeScaleCamMovement");
        this.m_lerpMultiplier = this.GetFloatFromTimeSystemTweak(currentTweak, "lerpMultiplierCamMovement");
        this.m_duration = this.GetFloatFromTimeSystemTweak(currentTweak, "duration");
        this.m_easeInCurve = TweakDBInterface.GetCName(t"timeSystem.quickHackScreen.easeInCurve", n"DiveEaseIn");
        this.m_easeOutCurve = TweakDBInterface.GetCName(t"timeSystem.quickHackScreen.easeInCurve", n"DiveEaseOut");
      } else {
        if !isCameraRotating && this.GetInStateTime() >= this.m_previousTimeStamp + this.m_duration {
          this.m_targetTimeScale = this.GetFloatFromTimeSystemTweak(currentTweak, "timeScale");
          this.m_lerpMultiplier = this.GetFloatFromTimeSystemTweak(currentTweak, "lerpMultiplier");
          this.m_previousTimeStamp = this.GetInStateTime();
          this.m_duration = 0.00;
        };
      };
    };
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UnsetTimeDilation(stateContext, scriptInterface, n"progressWithInput", n"");
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UnsetTimeDilation(stateContext, scriptInterface, n"progressWithInput", n"");
  }
}

public class TimeDilationFocusModeDecisions extends TimeDilationTransitions {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsPlayerInBraindance(scriptInterface) {
      return false;
    };
    if this.IsPlayerInFocusMode(stateContext, scriptInterface) && this.ShouldActivate(stateContext, scriptInterface) {
      return this.GetBoolFromTimeSystemTweak("focusModeTimeDilation", "enableTimeDilation");
    };
    return false;
  }

  protected final const func ToTimeDilationReady(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsPlayerInFocusMode(stateContext, scriptInterface) || !this.ShouldActivate(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  private final const func IsPlayerInFocusMode(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsInVisionModeActiveState(stateContext, scriptInterface);
  }

  private final const func IsPlayerInCombatState(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return (scriptInterface.executionOwner as PlayerPuppet).IsInCombat();
  }

  protected final const func IsPlayerLookingAtQuickHackTarget(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner).GetBool(GetAllBlackboardDefs().UI_Scanner.ScannerLookAt);
  }

  private final const func ShouldActivate(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) == EnumInt(gamePSMVehicle.Driving) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) == EnumInt(gamePSMVehicle.Transition) {
      return false;
    };
    if this.IsInTakedownState(stateContext) {
      return false;
    };
    if this.IsEnemyOrSensoryDeviceVisible(scriptInterface) && this.GetBoolFromTimeSystemTweak("focusModeTimeDilation", "enableTimeDilationOnlyEnemyOrSensorVisible") {
      return true;
    };
    return false;
  }
}

public class TimeDilationFocusModeEvents extends TimeDilationEventsTransitions {

  public let m_timeDilation: Float;

  public let m_playerDilation: Float;

  public let m_easeInCurve: CName;

  public let m_easeOutCurve: CName;

  public let m_applyTimeDilationToPlayer: Bool;

  public let m_timeDilationReason: CName;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_timeDilation = TweakDBInterface.GetFloat(t"timeSystem.focusModeTimeDilation.timeDilation", 0.00);
    this.m_playerDilation = TweakDBInterface.GetFloat(t"timeSystem.focusModeTimeDilation.playerTimeDilation", 0.00);
    this.m_easeInCurve = TweakDBInterface.GetCName(t"timeSystem.focusModeTimeDilation.easeInCurve", n"");
    this.m_easeOutCurve = TweakDBInterface.GetCName(t"timeSystem.focusModeTimeDilation.easeOutCurve", n"");
    this.m_applyTimeDilationToPlayer = TweakDBInterface.GetBool(t"timeSystem.focusModeTimeDilation.applyTimeDilationToPlayer", false);
    this.m_timeDilationReason = n"focusMode";
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.IsTimeDilationActive(stateContext, scriptInterface, n"") {
      this.SetTimeDilationGlobal(stateContext, scriptInterface, this.m_timeDilationReason, this.m_timeDilation, 999.00, this.m_easeInCurve, this.m_easeOutCurve);
      if this.m_applyTimeDilationToPlayer {
        this.SetTimeDilationOnLocalPlayer(this.m_timeDilationReason, this.m_playerDilation, 999.00, this.m_easeInCurve, this.m_easeOutCurve, stateContext, scriptInterface);
      };
    };
  }

  protected final func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UnsetTimeDilation(stateContext, scriptInterface, this.m_timeDilationReason, this.m_easeOutCurve);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UnsetTimeDilation(stateContext, scriptInterface, this.m_timeDilationReason, this.m_easeOutCurve);
  }
}
