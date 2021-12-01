
public class LocomotionSwimming extends LocomotionTransition {

  protected final const func IsFallingSpeedToEnterDiveAcceptable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let height: Float = this.GetStaticFloatParameterDefault("minFallHeight", 2.00);
    let fallingSpeedThreshold: Float = this.GetFallingSpeedBasedOnHeight(scriptInterface, height);
    let verticalSpeed: Float = this.GetVerticalSpeed(scriptInterface);
    if verticalSpeed <= fallingSpeedThreshold {
      return true;
    };
    return false;
  }

  protected final const func IsDivingBlocked(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"PhoneCall") || stateContext.GetBoolParameter(n"enteredWaterFromSceneTierII", true);
  }

  protected final const func IsDeepEnoughToDive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let depthTreshold: Float = this.GetStaticFloatParameterDefault("depthTreshold", 0.00);
    let tolerance: Float = this.GetStaticFloatParameterDefault("tolerance", 0.00);
    let currentDepth: Float = this.GetCurrentDepth(stateContext, scriptInterface);
    if currentDepth <= depthTreshold + tolerance {
      return true;
    };
    return false;
  }

  protected final const func GetCurrentDepth(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let waterLevel: Float;
    let maxDepth: Float = 100.00;
    let playerFeetPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let depthRaycastDestination: Vector4 = playerFeetPosition;
    depthRaycastDestination.Z = depthRaycastDestination.Z - maxDepth;
    let currentDepth: Float = maxDepth;
    if scriptInterface.GetWaterLevel(playerFeetPosition, depthRaycastDestination, waterLevel) {
      currentDepth = playerFeetPosition.Z - waterLevel;
    };
    return currentDepth;
  }

  protected final const func CanEnterFastSwimming(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isAiming: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
    let isReloading: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload);
    let isFocusMode: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
    let isChargingCyberware: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.Charge);
    let minLinearVelocityThreshold: Float = this.GetStaticFloatParameterDefault("minLinearVelocityThreshold", 0.50);
    let minStickInputThreshold: Float = this.GetStaticFloatParameterDefault("minStickInputThreshold", 0.90);
    let enterAngleThreshold: Float = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if !scriptInterface.IsMoveInputConsiderable() || AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold || DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) <= minStickInputThreshold || scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) < minLinearVelocityThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return false;
    };
    if isAiming {
      return false;
    };
    if isChargingCyberware {
      return false;
    };
    if (isFocusMode || stateContext.GetConditionBool(n"VisionToggled")) && !DefaultTransition.IsInRpgContext(scriptInterface) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) == EnumInt(gamePSMCombatGadget.Charging) {
      return false;
    };
    if isReloading && scriptInterface.GetActionValue(n"Sprint") > 0.00 && !scriptInterface.IsActionJustPressed(n"Sprint") {
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

  protected final const func ShouldExitFastSwimming(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    let minLinearVelocityThreshold: Float;
    let minStickInputThreshold: Float;
    if stateContext.GetBoolParameter(n"InterruptSprint") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    minLinearVelocityThreshold = this.GetStaticFloatParameterDefault("minLinearVelocityThreshold", 0.50);
    if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) < minLinearVelocityThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", 45.00);
    if !scriptInterface.IsMoveInputConsiderable() || !(AbsF(scriptInterface.GetInputHeading()) <= enterAngleThreshold) {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    minStickInputThreshold = this.GetStaticFloatParameterDefault("minStickInputThreshold", 0.90);
    if stateContext.GetConditionBool(n"SprintToggled") && DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) <= minStickInputThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    if scriptInterface.IsActionJustReleased(n"Sprint") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    return false;
  }
}

public class LocomotionSwimmingEvents extends LocomotionEventsTransition {

  protected final func SetSwimmingState(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, value: Int32) -> Void {
    if value > 0 {
      PlayerPuppet.ReevaluateAllBreathingEffects(scriptInterface.owner as PlayerPuppet);
    };
    stateContext.SetPermanentIntParameter(n"swimmingState", value, true);
    this.UpdateSwimmingAnimFeatureData(stateContext, scriptInterface);
  }

  protected final func UpdateSwimmingAnimFeatureData(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_SwimmingData> = new AnimFeature_SwimmingData();
    animFeature.state = stateContext.GetIntParameter(n"swimmingState", true);
    scriptInterface.SetAnimationParameterFeature(n"SwimmingData", animFeature);
  }

  public func SetLocomotionParameters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<LocomotionParameters> {
    let locomotionParameters: ref<LocomotionSwimmingParameters>;
    this.SetModifierGroupForState(scriptInterface);
    locomotionParameters = new LocomotionSwimmingParameters();
    this.GetStateDefaultLocomotionParameters(locomotionParameters);
    locomotionParameters.SetBuoyancyLineFraction(this.GetStaticFloatParameterDefault("buoyancyLineFraction", 0.50));
    locomotionParameters.SetDragCoefficient(this.GetStaticFloatParameterDefault("dragCoefficient", 0.47));
    stateContext.SetTemporaryScriptableParameter(n"locomotionParameters", locomotionParameters, true);
    return locomotionParameters;
  }

  protected final func IsSwimmingForward(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let minLinearVelocityThreshold: Float = this.GetStaticFloatParameterDefault("minLinearVelocityThreshold", 0.50);
    let enterAngleThreshold: Float = this.GetStaticFloatParameterDefault("enterAngleThreshold", 45.00);
    let minStickInputThreshold: Float = this.GetStaticFloatParameterDefault("minStickInputThreshold", 0.90);
    if !scriptInterface.IsMoveInputConsiderable() || AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold || DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) <= minStickInputThreshold || scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) < minLinearVelocityThreshold {
      return false;
    };
    return true;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    ScriptedPuppet.ReevaluateOxygenConsumption(scriptInterface.owner as ScriptedPuppet);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetSwimmingState(stateContext, scriptInterface, 0);
    ScriptedPuppet.ReevaluateOxygenConsumption(scriptInterface.owner as ScriptedPuppet);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Swimming, EnumInt(gamePSMSwimming.Default));
    PlayerPuppet.ReevaluateAllBreathingEffects(scriptInterface.owner as PlayerPuppet);
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, n"swimming_surface");
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, n"swimming_diving");
  }
}

public class SwimmingSurfaceDecisions extends LocomotionSwimming {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.CanEnterFastSwimming(stateContext, scriptInterface) && !this.IsDeepEnoughToDive(stateContext, scriptInterface);
  }
}

public class SwimmingSurfaceEvents extends LocomotionSwimmingEvents {

  @default(SwimmingSurfaceEvents, 0.f)
  public let m_lapsedTime: Float;

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.UpdateSwimmingStroke(timeDelta, stateContext, scriptInterface);
  }

  private final func UpdateSwimmingStroke(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let timeBetweenSwimmingStroke: Float;
    this.m_lapsedTime += timeDelta;
    timeBetweenSwimmingStroke = this.GetStaticFloatParameterDefault("timeBetweenSurfaceSwimmingStroke", 1.00);
    if this.m_lapsedTime >= timeBetweenSwimmingStroke && this.IsSwimmingForward(stateContext, scriptInterface) {
      this.m_lapsedTime = 0.00;
      this.AddImpulseInMovingDirection(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("surfaceSwimmingStrokeImpulseForce", 1.00));
      GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"swimming_surface_stroke", false);
    };
  }

  public final func OnEnterFromDiving(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlaySound(n"surface_from_dive", scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_lapsedTime = 0.00;
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.WaterCollision");
    this.SetSwimmingState(stateContext, scriptInterface, 1);
    scriptInterface.PushAnimationEvent(n"Swim");
    this.SetLocomotionParameters(stateContext, scriptInterface);
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, n"falling");
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"swimming_surface", false);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Swimming, EnumInt(gamePSMSwimming.Surface));
    this.TutorialSetFact(scriptInterface, n"swimming_tutorial");
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, n"swimming_surface");
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SwimmingSurfaceFastDecisions extends LocomotionSwimming {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.CanEnterFastSwimming(stateContext, scriptInterface) && !this.IsDeepEnoughToDive(stateContext, scriptInterface);
  }
}

public class SwimmingSurfaceFastEvents extends LocomotionSwimmingEvents {

  @default(SwimmingSurfaceFastEvents, 0.f)
  public let m_lapsedTime: Float;

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.UpdateSwimmingStroke(timeDelta, stateContext, scriptInterface);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
  }

  private final func UpdateSwimmingStroke(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let timeBetweenSwimmingStroke: Float;
    this.m_lapsedTime += timeDelta;
    timeBetweenSwimmingStroke = this.GetStaticFloatParameterDefault("timeBetweenSwimmingStroke", 1.00);
    if this.m_lapsedTime >= timeBetweenSwimmingStroke {
      this.m_lapsedTime = 0.00;
      this.AddImpulseInMovingDirection(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("swimmingStrokeImpulseForce", 1.00));
      GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"swimming_surface_stroke_fast", false);
    };
  }

  public final func OnEnterFromFastDiving(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.PlaySound(n"surface_from_fast_dive", scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_lapsedTime = 0.00;
    scriptInterface.PushAnimationEvent(n"SwimFast");
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.AddImpulseInMovingDirection(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("swimmingStrokeImpulseForce", 1.00));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SwimmingTransitionDecisions extends LocomotionSwimming {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsDivingBlocked(stateContext, scriptInterface) {
      return false;
    };
    if !this.IsDeepEnoughToDive(stateContext, scriptInterface) {
      return false;
    };
    if this.IsCameraPitchAcceptable(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("cameraPitchThreshold", -30.00)) && scriptInterface.GetActionValue(n"Jump") == 0.00 && !scriptInterface.IsActionJustPressed(n"Jump") {
      return true;
    };
    if this.IsFallingSpeedToEnterDiveAcceptable(stateContext, scriptInterface) {
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"ToggleCrouch") || scriptInterface.GetActionValue(n"Crouch") > 0.00 {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 0.20);
  }
}

public class SwimmingTransitionEvents extends LocomotionSwimmingEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetSwimmingState(stateContext, scriptInterface, 2);
    this.AddVerticalImpulse(stateContext, this.GetStaticFloatParameterDefault("downwardsImpulseStrength", 1.00));
    this.PlaySound(n"hold_breath", scriptInterface);
    DefaultTransition.PlayRumble(scriptInterface, "light_slow");
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"swimming_enter_dive", false);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SwimmingDivingDecisions extends LocomotionSwimming {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsDeepEnoughToDive(stateContext, scriptInterface) && !this.CanEnterFastSwimming(stateContext, scriptInterface);
  }
}

public class SwimmingDivingEvents extends LocomotionSwimmingEvents {

  @default(SwimmingDivingEvents, 0.f)
  public let m_lapsedTime: Float;

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.UpdateDivingStroke(timeDelta, stateContext, scriptInterface);
    this.UpdateAscendingDescending(timeDelta, stateContext, scriptInterface);
    ScriptedPuppet.ReevaluateOxygenConsumption(scriptInterface.owner as ScriptedPuppet);
  }

  private final func UpdateAscendingDescending(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.GetActionValue(n"Jump") > 0.00 {
      this.AddVerticalImpulse(stateContext, this.GetStaticFloatParameterDefault("divingUpwardsImpulseStrength", 1.00));
    };
    if scriptInterface.GetActionValue(n"ToggleCrouch") > 0.00 || scriptInterface.GetActionValue(n"Crouch") > 0.00 {
      this.AddVerticalImpulse(stateContext, this.GetStaticFloatParameterDefault("divingDownwardsImpulseStrength", 1.00));
    };
  }

  private final func UpdateDivingStroke(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let timeBetweenSwimmingStroke: Float;
    this.m_lapsedTime += timeDelta;
    timeBetweenSwimmingStroke = this.GetStaticFloatParameterDefault("timeBetweenDivingStroke", 1.00);
    if this.m_lapsedTime >= timeBetweenSwimmingStroke && this.IsSwimmingForward(stateContext, scriptInterface) {
      this.m_lapsedTime = 0.00;
      this.AddImpulseInMovingDirection(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("divingStrokeImpulseForce", 1.00));
      GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"swimming_diving_stroke", false);
    };
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_lapsedTime = 0.00;
    this.SetSwimmingState(stateContext, scriptInterface, 3);
    scriptInterface.PushAnimationEvent(n"Swim");
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"swimming_diving", false);
    this.AddImpulseInMovingDirection(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("divingStrokeImpulseForce", 1.00));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Swimming, EnumInt(gamePSMSwimming.Diving));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, n"swimming_diving");
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SwimmingFastDivingDecisions extends LocomotionSwimming {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsDeepEnoughToDive(stateContext, scriptInterface) && this.CanEnterFastSwimming(stateContext, scriptInterface);
  }
}

public class SwimmingFastDivingEvents extends LocomotionSwimmingEvents {

  @default(SwimmingFastDivingEvents, 0.f)
  public let m_lapsedTime: Float;

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if scriptInterface.GetActionValue(n"Jump") > 0.00 {
      this.AddVerticalImpulse(stateContext, this.GetStaticFloatParameterDefault("divingUpwardsImpulseStrength", 1.00));
    };
    if scriptInterface.IsActionJustPressed(n"ToggleCrouch") || scriptInterface.GetActionValue(n"Crouch") > 0.00 {
      this.AddVerticalImpulse(stateContext, this.GetStaticFloatParameterDefault("divingDownwardsImpulseStrength", 1.00));
    };
    this.UpdateFastDivingStroke(timeDelta, stateContext, scriptInterface);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
  }

  private final func UpdateFastDivingStroke(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let timeBetweenSwimmingStroke: Float;
    this.m_lapsedTime += timeDelta;
    timeBetweenSwimmingStroke = this.GetStaticFloatParameterDefault("timeBetweenFastDivingStroke", 1.00);
    if this.m_lapsedTime >= timeBetweenSwimmingStroke {
      this.m_lapsedTime = 0.00;
      this.AddImpulseInMovingDirection(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("fastDivingStrokeImpulseForce", 1.00));
      GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"swimming_diving_stroke_fast", false);
    };
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.PushAnimationEvent(n"DiveFast");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Swimming, EnumInt(gamePSMSwimming.Diving));
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SwimmingClimbDecisions extends LocomotionGroundDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    let climbInfo: ref<PlayerClimbInfo> = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    let isObstacleSuitable: Bool = climbInfo.climbValid && this.OverlapFitTest(scriptInterface, climbInfo);
    let preClimbAnimFeature: ref<AnimFeature_PreClimbing> = new AnimFeature_PreClimbing();
    preClimbAnimFeature.valid = 0.00;
    if isObstacleSuitable {
      preClimbAnimFeature.edgePositionLS = scriptInterface.TransformInvPointFromObject(climbInfo.descResult.topPoint);
      preClimbAnimFeature.valid = 1.00;
    };
    stateContext.SetConditionScriptableParameter(n"PreClimbAnimFeature", preClimbAnimFeature, true);
    if this.GetStaticBoolParameterDefault("requireForwardEnterAngleToClimb", false) && !this.ForwardAngleTest(stateContext, scriptInterface, climbInfo) {
      return false;
    };
    if !this.GetStaticBoolParameterDefault("requireDirectionalInputToClimb", false) && (AbsF(scriptInterface.GetInputHeading()) > 45.00 || this.IsPlayerMovingBackwards(stateContext, scriptInterface)) {
      return false;
    };
    if this.GetStaticBoolParameterDefault("requireMinCameraPitchAngleToClimb", false) && this.IsCameraPitchAcceptable(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("cameraPitchThreshold", -30.00)) {
      return false;
    };
    enterAngleThreshold = this.GetStaticFloatParameterDefault("inputAngleThreshold", -180.00);
    if !(AbsF(scriptInterface.GetInputHeading()) <= enterAngleThreshold) {
      return false;
    };
    return isObstacleSuitable && scriptInterface.IsActionJustPressed(n"Jump");
  }

  private final const func ForwardAngleTest(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, climbInfo: ref<PlayerClimbInfo>) -> Bool {
    let playerForward: Vector4 = scriptInterface.GetOwnerForward();
    let obstaclePosition: Vector4 = climbInfo.descResult.collisionNormal;
    let forwardAngleDifference: Float = Vector4.GetAngleBetween(-obstaclePosition, playerForward);
    let enterAngleThreshold: Float = this.GetStaticFloatParameterDefault("obstacleEnterAngleThreshold", -180.00);
    if forwardAngleDifference < enterAngleThreshold && forwardAngleDifference - 180.00 < enterAngleThreshold {
      return true;
    };
    return false;
  }

  private final const func OverlapFitTest(const scriptInterface: ref<StateGameScriptInterface>, climbInfo: ref<PlayerClimbInfo>) -> Bool {
    let fitTestOvelap: TraceResult;
    let playerCapsuleDimensions: Vector4;
    let rotation: EulerAngles;
    let tolerance: Float = 0.15;
    playerCapsuleDimensions.X = this.GetStaticFloatParameterDefault("capsuleRadius", 0.40);
    playerCapsuleDimensions.Y = -1.00;
    playerCapsuleDimensions.Z = -1.00;
    let queryPosition: Vector4 = climbInfo.descResult.topPoint + DefaultTransition.GetUpVector() * (playerCapsuleDimensions.X + tolerance);
    let crouchOverlap: Bool = scriptInterface.Overlap(playerCapsuleDimensions, queryPosition, rotation, n"Player Blocker", fitTestOvelap);
    return !crouchOverlap;
  }
}

public class SwimmingClimbEvents extends ClimbEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Swimming, EnumInt(gamePSMSwimming.Default));
  }
}

public class SwimmingLadderDecisions extends LocomotionGroundDecisions {

  protected final const func TestParameters(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, out ladderParameter: ref<LadderDescription>) -> Bool {
    let ladderFinishedParameter: StateResultBool;
    ladderParameter = stateContext.GetTemporaryScriptableParameter(n"usingLadder") as LadderDescription;
    if !IsDefined(ladderParameter) {
      ladderParameter = stateContext.GetConditionScriptableParameter(n"usingLadder") as LadderDescription;
      ladderFinishedParameter = stateContext.GetTemporaryBoolParameter(n"exitLadder");
      if ladderFinishedParameter.valid && ladderFinishedParameter.value {
        stateContext.RemoveConditionScriptableParameter(n"usingLadder");
        return false;
      };
      if !IsDefined(ladderParameter) {
        return false;
      };
    } else {
      stateContext.SetConditionScriptableParameter(n"usingLadder", ladderParameter, true);
    };
    return true;
  }

  protected final const func TestMath(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, ladderParameter: ref<LadderDescription>) -> Bool {
    let playerPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let playerForward: Vector4 = scriptInterface.GetOwnerForward();
    let playerVelocity: Vector4 = Vector4.Normalize2D(Vector4.RotByAngleXY(playerForward, scriptInterface.GetInputHeading()));
    let ladderPosition: Vector4 = ladderParameter.position - ladderParameter.normal + ladderParameter.up * ladderParameter.verticalStepBottom;
    let directionToLadder: Vector4 = ladderPosition - playerPosition;
    directionToLadder = Vector4.Normalize2D(directionToLadder);
    let ladderEntityAngle: Float = Rad2Deg(AcosF(Vector4.Dot(playerForward, directionToLadder)));
    let playerMoveDirection: Float = Rad2Deg(AcosF(Vector4.Dot(playerVelocity, -ladderParameter.normal)));
    let enterAngleThreshold: Float = this.GetStaticFloatParameterDefault("enterAngleThreshold", 35.00);
    let fromBottomFactor: Float = SgnF(Vector4.Dot(ladderParameter.up, directionToLadder));
    let onGround: Bool = this.IsTouchingGround(scriptInterface);
    if !onGround {
      if fromBottomFactor > 0.00 && AbsF(ladderEntityAngle) < enterAngleThreshold || fromBottomFactor < 0.00 && AbsF(ladderEntityAngle) < enterAngleThreshold || AbsF(ladderEntityAngle - 180.00) < enterAngleThreshold {
        return true;
      };
    } else {
      if scriptInterface.IsMoveInputConsiderable() && (fromBottomFactor > 0.00 && AbsF(ladderEntityAngle) < enterAngleThreshold && AbsF(playerMoveDirection) < enterAngleThreshold || fromBottomFactor < 0.00 && (AbsF(ladderEntityAngle) < enterAngleThreshold || AbsF(ladderEntityAngle - 180.00) < enterAngleThreshold) && AbsF(playerMoveDirection - 180.00) < enterAngleThreshold) {
        return true;
      };
    };
    return false;
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let ladderParameter: ref<LadderDescription>;
    let testMath: Bool;
    let testParameters: Bool = this.TestParameters(stateContext, scriptInterface, ladderParameter);
    if ladderParameter == null {
      return false;
    };
    if !MeleeTransition.MeleeUseExplorationCondition(stateContext, scriptInterface) {
      return false;
    };
    testMath = this.TestMath(stateContext, scriptInterface, ladderParameter);
    return testParameters && testMath;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let finishedLadder: StateResultBool = stateContext.GetTemporaryBoolParameter(n"finishedLadderAction");
    return finishedLadder.valid && finishedLadder.value;
  }
}

public class SwimmingLadderEvents extends LadderEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Swimming, EnumInt(gamePSMSwimming.Default));
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    stateContext.RemoveConditionScriptableParameter(n"enterLadder");
  }
}

public class SwimmingForceFreezeDecisions extends LocomotionSwimming {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsFreezeForced(stateContext);
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsFreezeForced(stateContext);
  }
}
