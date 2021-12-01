
public class IdleTier3Events extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }
}

public class IdleTier4Events extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }
}

public class IdleTier5Events extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }
}
