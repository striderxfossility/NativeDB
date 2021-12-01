
public class LocomotionBraindance extends LocomotionTransition {

  protected final const func CanEnterFastFlying(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let minLinearVelocityThreshold: Float = this.GetStaticFloatParameterDefault("minLinearVelocityThreshold", 0.50);
    let minStickInputThreshold: Float = this.GetStaticFloatParameterDefault("minStickInputThreshold", 0.90);
    let enterAngleThreshold: Float = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if !scriptInterface.HasStatFlag(gamedataStatType.CanSprint) {
      return false;
    };
    if !scriptInterface.IsMoveInputConsiderable() || AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold || DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) <= minStickInputThreshold || scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) < minLinearVelocityThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return false;
    };
    if stateContext.GetConditionBool(n"SprintToggled") {
      return true;
    };
    if scriptInterface.GetActionValue(n"ToggleSprint") > 0.00 {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
    };
    if scriptInterface.GetActionValue(n"Sprint") > 0.00 {
      return true;
    };
    return false;
  }
}

public class LocomotionBraindanceEvents extends LocomotionEventsTransition {

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  public func SetLocomotionParameters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<LocomotionParameters> {
    let locomotionParameters: ref<LocomotionBraindanceParameters>;
    let transform: Transform;
    this.SetModifierGroupForState(scriptInterface);
    locomotionParameters = new LocomotionBraindanceParameters();
    this.GetStateDefaultLocomotionParameters(locomotionParameters);
    transform = scriptInterface.GetOwnerTransform();
    locomotionParameters.SetUpperMovementLimit(transform.position.Z + this.GetStaticFloatParameterDefault("upperMovementLimit", 2.00));
    locomotionParameters.SetLowerMovementLimit(transform.position.Z + this.GetStaticFloatParameterDefault("lowerMovementLimit", -2.00));
    stateContext.SetTemporaryScriptableParameter(n"locomotionParameters", locomotionParameters, true);
    return locomotionParameters;
  }

  public final func EnableBraindanceCollisionFilter(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let simulationFilter: SimulationFilter;
    SimulationFilter.SimulationFilter_BuildFromPreset(simulationFilter, n"NPC Collision");
    scriptInterface.SetStateVectorParameter(physicsStateValue.SimulationFilter, ToVariant(simulationFilter));
  }
}

public class BraindanceFlyDecisions extends LocomotionBraindance {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.CanEnterFastFlying(stateContext, scriptInterface);
  }
}

public class BraindanceFlyEvents extends LocomotionBraindanceEvents {

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.EnableBraindanceCollisionFilter(scriptInterface);
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.SetAnimationParameterFloat(n"crouch", 0.00);
    this.SetCollisionFilter(scriptInterface);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class BraindanceFastFlyDecisions extends LocomotionBraindance {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.CanEnterFastFlying(stateContext, scriptInterface);
  }
}

public class BraindanceFastFlyEvents extends LocomotionBraindanceEvents {

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.EnableBraindanceCollisionFilter(scriptInterface);
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.SetAnimationParameterFloat(n"crouch", 0.00);
    this.SetCollisionFilter(scriptInterface);
    this.OnExit(stateContext, scriptInterface);
  }
}
