
public class StandLowGravityEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"transitionFromCrouch", false, true);
  }
}

public class PreCrouchLowGravityDecisions extends LocomotionGroundDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let superResult: Bool = this.EnterCondition(stateContext, scriptInterface);
    return this.CrouchEnterCondition(stateContext, scriptInterface, GameplaySettingsSystem.GetGameplaySettingsSystemInstance(scriptInterface.executionOwner).GetIsFastForwardByLine()) && superResult;
  }

  protected const func ToStandLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return stateContext.GetBoolParameter(n"transitionFromCrouch", true) && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("timeToEnterCrouch", 0.20);
  }

  protected const func ToCrouchLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !stateContext.GetBoolParameter(n"transitionFromCrouch", true) && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("timeToEnterCrouch", 0.20);
  }

  protected const func ToDodgeLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() <= 0.06 {
      return false;
    };
    return scriptInterface.IsActionJustPressed(n"Dodge") && scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) >= 0.10 && !stateContext.GetBoolParameter(n"transitionFromCrouch", true);
  }

  protected const func ToDodgeCrouchLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() <= 0.06 {
      return false;
    };
    return scriptInterface.IsActionJustPressed(n"Dodge") && scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) >= 0.10 && stateContext.GetBoolParameter(n"transitionFromCrouch", true);
  }
}

public class PreCrouchLowGravityEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 0.00);
  }

  public final func OnExitToDodgeCrouchLowGravity(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if this.GetInStateTime() > 0.06 {
      scriptInterface.SetAnimationParameterFloat(n"crouch", 0.60);
    };
  }
}

public class CrouchLowGravityDecisions extends LocomotionGroundDecisions {

  protected const func ToCrouchLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected const func ToPreCrouchLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.CrouchExitCondition(stateContext, scriptInterface, false);
  }
}

public class CrouchLowGravityEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetConditionBoolParameter(n"CrouchToggled", true, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Crouch));
    stateContext.SetPermanentBoolParameter(n"transitionFromCrouch", true, true);
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 0.00);
  }

  public final func OnExitToSnapToCover(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Crouch));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
  }

  public final func OnExitToPreCrouchLowGravity(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Crouch));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
  }
}

public class DodgeLowGravityDecisions extends LocomotionGroundDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"Dodge") && scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) >= 0.50;
  }

  protected final const func ToStandLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let maxDuration: Float = this.GetStaticFloatParameterDefault("maxDuration", 0.00);
    return this.GetInStateTime() >= maxDuration;
  }
}

public class DodgeLowGravityEvents extends LocomotionGroundEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    scriptInterface.PushAnimationEvent(n"Dodge");
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class DodgeCrouchLowGravityDecisions extends LocomotionGroundDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"Dodge") && scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) >= 0.50;
  }

  protected final const func ToCrouchLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let maxDuration: Float = this.GetStaticFloatParameterDefault("maxDuration", 0.00);
    return this.GetInStateTime() >= maxDuration;
  }
}

public class DodgeCrouchLowGravityEvents extends LocomotionGroundEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    scriptInterface.PushAnimationEvent(n"Dodge");
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= TweakDBInterface.GetFloat(t"cyberware.kereznikovDodge.timeStampToEnter", 0.00) {
      stateContext.SetTemporaryBoolParameter(n"extendKerenzikovDuration", true, true);
    };
  }
}

public class SprintWindupLowGravityDecisions extends SprintLowGravityDecisions {

  protected const func ToSprintLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) >= this.GetStaticFloatParameterDefault("speedToEnterSprint", 4.00) {
      return true;
    };
    return false;
  }
}

public class SprintWindupLowGravityEvents extends SprintLowGravityEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
  }
}

public class SprintLowGravityDecisions extends LocomotionGroundDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    let isAiming: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
    let isReloading: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload);
    let superResult: Bool = this.EnterCondition(stateContext, scriptInterface);
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    if isAiming {
      return false;
    };
    if isReloading && !scriptInterface.IsActionJustPressed(n"ToggleSprint") && !scriptInterface.IsActionJustPressed(n"Sprint") {
      return false;
    };
    if scriptInterface.GetActionValue(n"AttackA") > 0.00 {
      return false;
    };
    if scriptInterface.IsActionJustPressed(n"ToggleSprint") || stateContext.GetConditionBool(n"SprintToggled") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
      return superResult;
    };
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if !scriptInterface.IsMoveInputConsiderable() || AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold {
      return false;
    };
    if scriptInterface.GetActionValue(n"Sprint") > 0.00 {
      return superResult;
    };
    return false;
  }

  protected const func ToStandLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) <= 0.50 {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    if stateContext.GetBoolParameter(n"InterruptSprint") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if !scriptInterface.IsMoveInputConsiderable() || AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    if !stateContext.GetConditionBool(n"SprintToggled") && scriptInterface.GetActionValue(n"Sprint") == 0.00 {
      return true;
    };
    if scriptInterface.IsActionJustReleased(n"Sprint") || scriptInterface.IsActionJustPressed(n"AttackA") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    return false;
  }

  protected const func ToSprintJumpLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("timeBetweenJumps", 0.20) {
      return true;
    };
    return false;
  }
}

public class SprintLowGravityEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) > 2.50 {
      this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Sprint));
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      scriptInterface.PushAnimationEvent(n"Jump");
      scriptInterface.SetAnimationParameterFloat(n"sprint", 0.10);
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetPermanentFloatParameter(n"SprintingStoppedTimeStamp", scriptInterface.GetNow(), true);
  }
}

public class SprintJumpLowGravityDecisions extends LocomotionAirLowGravityDecisions {

  protected const func ToSprintLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() >= 0.30 {
      return scriptInterface.IsOnGround();
    };
    return false;
  }

  protected const func ToJumpLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() <= this.GetStaticFloatParameterDefault("maxTimeToEnterJump", 0.90) {
      return scriptInterface.IsActionJustPressed(n"Jump");
    };
    return false;
  }
}

public class SprintJumpLowGravityEvents extends LocomotionAirLowGravityEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetTemporaryBoolParameter(n"InterruptReload", true, true);
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SlideLowGravityDecisions extends CrouchLowGravityDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let superResult: Bool;
    return false;
  }

  protected const func ToCrouchLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetConditionBool(n"CrouchToggled") || scriptInterface.GetActionValue(n"Crouch") > 0.00 {
      return this.ShouldExit(stateContext, scriptInterface);
    };
    return false;
  }

  protected const func ShouldExit(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) <= this.GetStaticFloatParameterDefault("minSpeedToExit", 2.00);
  }
}

public class SlideLowGravityEvents extends CrouchLowGravityEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    if this.GetStaticBoolParameterDefault("pushAnimEventOnEnter", false) {
      scriptInterface.PushAnimationEvent(n"Slide");
    };
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= TweakDBInterface.GetFloat(t"cyberware.kereznikovSlide.minThresholdToEnter", 0.00) {
      stateContext.SetTemporaryBoolParameter(n"canEnterKerenzikovSlide", true, true);
    };
    if this.GetInStateTime() >= 0.10 {
      this.UpdateCrouch(stateContext, scriptInterface);
      this.UpdateSprint(stateContext, scriptInterface);
    };
  }

  private final func UpdateSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.IsActionJustPressed(n"ToggleSprint") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    };
  }

  private final func UpdateCrouch(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let crouchToggled: Bool = stateContext.GetConditionBool(n"CrouchToggled");
    if crouchToggled && scriptInterface.IsActionJustReleased(n"Crouch") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    } else {
      if scriptInterface.IsActionJustPressed(n"ToggleCrouch") {
        stateContext.SetConditionBoolParameter(n"CrouchToggled", !crouchToggled, true);
        if crouchToggled {
          stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
        };
      };
    };
  }

  public final func OnExitToCrouch(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Crouch));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
  }
}

public class LocomotionAirLowGravityDecisions extends LocomotionAirDecisions {

  protected final const func ToRegularLandLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let landingType: Int32 = this.GetLandingType(stateContext);
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    return landingType <= EnumInt(LandingType.Regular);
  }
}

public class JumpLowGravityDecisions extends LocomotionAirLowGravityDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"Jump");
  }

  protected final const func ToFallLowGravity(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.GetActionValue(n"Jump") < 0.10 {
      return true;
    };
    return false;
  }
}

public class JumpLowGravityEvents extends LocomotionAirLowGravityEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Jump));
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }
}

public class FallLowGravityDecisions extends LocomotionAirLowGravityDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() <= 0.10 {
      return false;
    };
    return this.ShouldFall(stateContext, scriptInterface);
  }
}

public class FallLowGravityEvents extends LocomotionAirLowGravityEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.PlaySound(n"Player_falling_wind_loop", scriptInterface);
    scriptInterface.PushAnimationEvent(n"Fall");
  }
}

public class RegularLandLowGravityEvents extends AbstractLandEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class DodgeAirLowGravityDecisions extends LocomotionAirLowGravityDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let currentNumberOfAirDodges: Int32;
    if this.GetStaticBoolParameterDefault("disable", false) {
      return false;
    };
    currentNumberOfAirDodges = stateContext.GetIntParameter(n"currentNumberOfAirDodges", true);
    if currentNumberOfAirDodges >= this.GetStaticIntParameterDefault("numberOfAirDodges", 1) {
      return false;
    };
    return scriptInterface.IsActionJustPressed(n"Dodge") && scriptInterface.IsMoveInputConsiderable();
  }
}

public class DodgeAirLowGravityEvents extends LocomotionAirLowGravityEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let currentNumberOfAirDodges: Int32;
    this.OnEnter(stateContext, scriptInterface);
    currentNumberOfAirDodges = stateContext.GetIntParameter(n"currentNumberOfAirDodges", true);
    currentNumberOfAirDodges += 1;
    stateContext.SetPermanentIntParameter(n"currentNumberOfAirDodges", currentNumberOfAirDodges, true);
    scriptInterface.PushAnimationEvent(n"Dodge");
  }
}

public class ClimbLowGravityDecisions extends LocomotionGroundDecisions {

  private final const func OverlapFitTest(const scriptInterface: ref<StateGameScriptInterface>, climbInfo: ref<PlayerClimbInfo>) -> Bool {
    let Z: Vector4;
    let fitTestOvelap: TraceResult;
    let playerCapsuleDimensions: Vector4;
    let rotation: EulerAngles;
    Z.Z = 1.00;
    playerCapsuleDimensions.X = this.GetStaticFloatParameterDefault("capsuleRadius", 0.40);
    playerCapsuleDimensions.Y = -1.00;
    playerCapsuleDimensions.Z = -1.00;
    let queryPosition: Vector4 = climbInfo.descResult.topPoint + Z * playerCapsuleDimensions.X;
    let crouchOverlap: Bool = scriptInterface.Overlap(playerCapsuleDimensions, queryPosition, rotation, n"Static", fitTestOvelap);
    return !crouchOverlap;
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let climbInfo: ref<PlayerClimbInfo>;
    let enterAngleThreshold: Float;
    if this.GetStaticBoolParameterDefault("allowClimbOnlyWhenMovingDown", false) && this.GetVerticalSpeed(scriptInterface) > 0.00 {
      return false;
    };
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if !scriptInterface.IsMoveInputConsiderable() || !(AbsF(scriptInterface.GetInputHeading()) <= enterAngleThreshold) {
      return false;
    };
    climbInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    return climbInfo.climbValid && this.OverlapFitTest(scriptInterface, climbInfo);
  }
}

public class ClimbLowGravityEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let climbInfo: ref<PlayerClimbInfo>;
    let direction: Vector4;
    this.OnEnter(stateContext, scriptInterface);
    climbInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    direction = scriptInterface.GetOwnerForward();
    direction = Vector4.RotByAngleXY(direction, -scriptInterface.GetInputHeading());
    stateContext.SetTemporaryVectorParameter(n"obstacleVerticalDestination", climbInfo.descResult.topPoint - direction * this.GetStaticFloatParameterDefault("capsuleRadius", 0.00), true);
    stateContext.SetTemporaryVectorParameter(n"obstacleHorizontalDestination", climbInfo.descResult.topPoint, true);
    stateContext.SetTemporaryVectorParameter(n"obstacleSurfaceNormal", climbInfo.descResult.topNormal, true);
  }
}
