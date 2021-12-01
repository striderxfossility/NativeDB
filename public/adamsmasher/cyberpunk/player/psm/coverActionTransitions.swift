
public abstract class CoverActionTransition extends LocomotionTransition {

  protected final const func IsMeleeLeaningInputCorrect(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let meleeWeaponState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon);
    return meleeWeaponState == EnumInt(gamePSMMeleeWeapon.Block) || meleeWeaponState == EnumInt(gamePSMMeleeWeapon.Targeting);
  }

  protected final func IsPlayerInCorrectStateToPeek(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Bool {
    let leftHandCyberwareState: Int32;
    if this.IsInSafeSceneTier(scriptInterface) {
      return false;
    };
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) {
      return true;
    };
    leftHandCyberwareState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware);
    if leftHandCyberwareState == EnumInt(gamePSMLeftHandCyberware.Charge) || leftHandCyberwareState == EnumInt(gamePSMLeftHandCyberware.QuickAction) {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) == EnumInt(gamePSMCombatGadget.Charging) {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) {
      stateContext.RemovePermanentBoolParameter(n"QuickthrowHoldPeek");
      return true;
    };
    if scriptInterface.GetActionValue(n"CameraAim") == 0.00 {
      stateContext.RemovePermanentBoolParameter(n"QuickthrowHoldPeek");
    };
    if stateContext.GetBoolParameter(n"QuickthrowHoldPeek", true) {
      return true;
    };
    if stateContext.IsStateActive(n"UpperBody", n"aimingState") {
      stateContext.RemovePermanentBoolParameter(n"QuickthrowHoldPeek");
      return true;
    };
    return false;
  }

  protected final const func GetManualLeanIdleTime(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>) -> Float {
    let parameter: StateResultFloat = stateContext.GetPermanentFloatParameter(n"ManualLeanIdleStartTime");
    if !parameter.valid {
      return 0.00;
    };
    return EngineTime.ToFloat(scriptInterface.GetTimeSystem().GetSimTime()) - parameter.value;
  }

  protected final const func IsManualLeanInputPressed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const actionName: CName) -> Bool {
    return scriptInterface.IsActionJustPressed(actionName) || scriptInterface.GetActionValue(actionName) > 0.00 && this.GetManualLeanIdleTime(scriptInterface, stateContext) > 0.20;
  }

  protected final const func IsManualLeanLeftInputPressed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }

  protected final const func IsManualLeanRightInputPressed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }
}

public abstract class CoverActionEventsTransition extends CoverActionTransition {

  protected final func SetCoverStateAnimFeature(scriptInterface: ref<StateGameScriptInterface>, newState: Int32) -> Void {
    let animFeature: ref<AnimFeature_PlayerCoverActionState> = new AnimFeature_PlayerCoverActionState();
    animFeature.state = newState;
    scriptInterface.SetAnimationParameterFeature(n"PlayerCoverActionState", animFeature);
    this.SetCoverActionStateBlacboardVal(scriptInterface, newState);
  }

  protected final func SetCoverActionStateBlacboardVal(scriptInterface: ref<StateGameScriptInterface>, newVal: Int32) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().CoverAction.coverActionStateId, newVal);
  }
}

public class InactiveCoverDecisions extends CoverActionTransition {

  protected final func EnterCondition(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsPlayerInCorrectStateToPeek(scriptInterface, stateContext) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) != EnumInt(gamePSMCombatGadget.Throwing);
  }
}

public class InactiveCoverEvents extends CoverActionEventsTransition {

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetCoverStateAnimFeature(scriptInterface, EnumInt(IntEnum(0l)));
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().OnCoverDeactivation(scriptInterface.owner);
    stateContext.RemovePermanentBoolParameter(n"QuickthrowHoldPeek");
  }
}

public class ActivateCoverDecisions extends CoverActionTransition {

  protected final func EnterCondition(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsPlayerInCorrectStateToPeek(scriptInterface, stateContext);
  }
}

public class ActivateCoverEvents extends CoverActionEventsTransition {

  public let m_usingCover: Bool;

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().OnAutoCoverActivation(scriptInterface.owner);
    this.SetCoverStateAnimFeature(scriptInterface, EnumInt(gamePlayerCoverMode.Auto));
    this.m_usingCover = false;
  }

  public final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UsingCover, false);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UsingCover, false);
  }

  public final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let usingCover: Bool = NotEquals(scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCoverDirection(scriptInterface.executionOwner), IntEnum(0l));
    if NotEquals(usingCover, this.m_usingCover) {
      this.m_usingCover = usingCover;
      this.SetBlackboardBoolVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UsingCover, this.m_usingCover);
    };
  }
}
