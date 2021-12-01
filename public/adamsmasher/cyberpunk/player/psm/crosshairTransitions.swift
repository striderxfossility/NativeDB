
public class BaseCrosshairState extends DefaultTransition {

  protected final func GetCrosshairStateEnumValue() -> gamePSMCrosshairStates {
    let stateName: CName = this.GetStateName();
    switch stateName {
      case n"safe":
        return gamePSMCrosshairStates.Safe;
      case n"scanning":
        return gamePSMCrosshairStates.Scanning;
      case n"grenadeCharging":
        return gamePSMCrosshairStates.GrenadeCharging;
      case n"aim":
        return gamePSMCrosshairStates.Aim;
      case n"reload":
        return gamePSMCrosshairStates.Reload;
      case n"sprint":
        return gamePSMCrosshairStates.HipFire;
      case n"hipfire":
        return gamePSMCrosshairStates.HipFire;
      case n"leftHandCyberware":
        return gamePSMCrosshairStates.LeftHandCyberware;
      case n"quickHack":
        return gamePSMCrosshairStates.QuickHack;
    };
    return gamePSMCrosshairStates.Default;
  }
}

public class BaseCrosshairStateEvents extends BaseCrosshairState {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Crosshair, EnumInt(this.GetCrosshairStateEnumValue()));
  }
}

public class SafeCrosshairStateDecisions extends BaseCrosshairState {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsInSafeZone(scriptInterface) {
      return true;
    };
    if this.IsInSafeSceneTier(scriptInterface) {
      return true;
    };
    if (scriptInterface.executionOwner as PlayerPuppet).IsAimingAtFriendly() && stateContext.IsStateActive(n"UpperBody", n"singleWield") {
      return true;
    };
    if this.GetHudManager(scriptInterface).IsQuickHackPanelOpened() {
      return true;
    };
    return false;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.EnterCondition(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }
}

public class QuickHackCrosshairStateDecisions extends BaseCrosshairState {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetHudManager(scriptInterface).IsQuickHackPanelOpened();
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.EnterCondition(stateContext, scriptInterface);
  }
}
