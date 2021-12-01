
public abstract class AIGenericLookatTask extends AILookatTask {

  protected func GetSoftLimitDegreesType() -> animLookAtLimitDegreesType {
    return IntEnum(3l);
  }

  protected func GetHardLimitDegreesType() -> animLookAtLimitDegreesType {
    return IntEnum(3l);
  }

  protected func GetHardLimitDistanceType() -> animLookAtLimitDistanceType {
    return IntEnum(3l);
  }

  protected func GetBackLimitDegreesType() -> animLookAtLimitDegreesType {
    return animLookAtLimitDegreesType.Normal;
  }

  protected func GetLookatStyle() -> animLookAtStyle {
    return animLookAtStyle.Normal;
  }

  protected func GetHasOutTransition() -> Bool {
    return true;
  }

  protected func GetOutTransitionStyle() -> animLookAtStyle {
    return animLookAtStyle.Slow;
  }

  protected func GetLookAtSlotName() -> CName {
    return n"Chest";
  }

  protected func GetLookActivationDelay() -> Float {
    return -1.00;
  }

  protected func GetLookAtDeactivationDelay() -> Float {
    return -1.00;
  }

  protected func ActivateLookat(context: ScriptExecutionContext) -> Void;

  protected func DeactivateLookat(context: ScriptExecutionContext, opt instant: Bool) -> Void;

  protected func ShouldLookatBeActive(context: ScriptExecutionContext) -> Bool {
    return true;
  }

  protected final func UpdateLookat(context: ScriptExecutionContext) -> Void {
    if this.ShouldLookatBeActive(context) {
      this.ActivateLookat(context);
    } else {
      this.DeactivateLookat(context);
    };
  }

  private func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    this.UpdateLookat(context);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void {
    this.Deactivate(context);
    this.DeactivateLookat(context);
  }

  protected final func DeactivateLookatInternal(context: ScriptExecutionContext, opt instant: Bool) -> Void {
    let lookAtDeactivationDelay: Float;
    if !IsDefined(this.GetLookAtEvent()) {
      return;
    };
    lookAtDeactivationDelay = this.GetLookAtDeactivationDelay();
    if lookAtDeactivationDelay <= 0.00 || instant {
      LookAtRemoveEvent.QueueRemoveLookatEvent(AIBehaviorScriptBase.GetPuppet(context), this.GetLookAtEvent());
      this.SetLookAtEvent(null);
    } else {
      LookAtRemoveEvent.QueueDelayedRemoveLookatEvent(context, this.GetLookAtEvent(), lookAtDeactivationDelay);
    };
  }

  protected func GetLookAtEvent() -> ref<LookAtAddEvent> {
    return null;
  }

  protected func SetLookAtEvent(lookAtEvent: ref<LookAtAddEvent>) -> Void;
}

public abstract class AIGenericEntityLookatTask extends AIGenericLookatTask {

  private let m_lookAtEvent: ref<LookAtAddEvent>;

  private let m_activationTimeStamp: Float;

  private let m_lookatTarget: wref<Entity>;

  protected func GetLookAtEvent() -> ref<LookAtAddEvent> {
    return this.m_lookAtEvent;
  }

  protected func SetLookAtEvent(lookAtEvent: ref<LookAtAddEvent>) -> Void {
    this.m_lookAtEvent = lookAtEvent;
  }

  protected func GetAimingLookatTarget(context: ScriptExecutionContext) -> ref<GameObject> {
    return null;
  }

  private func ActivateLookat(context: ScriptExecutionContext) -> Void {
    if IsDefined(this.m_lookAtEvent) {
      return;
    };
    this.m_lookAtEvent = new LookAtAddEvent();
    this.m_lookAtEvent.SetEntityTarget(this.m_lookatTarget, this.GetLookAtSlotName(), Vector4.EmptyVector());
    this.m_lookAtEvent.SetLimits(this.GetSoftLimitDegreesType(), this.GetHardLimitDegreesType(), this.GetHardLimitDistanceType(), this.GetBackLimitDegreesType());
    this.m_lookAtEvent.SetStyle(this.GetLookatStyle());
    this.m_lookAtEvent.request.hasOutTransition = this.GetHasOutTransition();
    this.m_lookAtEvent.SetOutTransitionStyle(this.GetOutTransitionStyle());
    if !IsFinal() {
      this.m_lookAtEvent.SetDebugInfo("ScriptAIGenericEntityLookatTask");
    };
    AIBehaviorScriptBase.GetPuppet(context).QueueEvent(this.m_lookAtEvent);
  }

  private func DeactivateLookat(context: ScriptExecutionContext, opt instant: Bool) -> Void {
    this.DeactivateLookatInternal(context, instant);
  }

  protected func ShouldLookatBeActive(context: ScriptExecutionContext) -> Bool {
    if AIBehaviorScriptBase.GetPuppet(context).GetBoolFromCharacterTweak("lookat_disabled", false) {
      return false;
    };
    this.m_lookatTarget = this.GetAimingLookatTarget(context);
    if !IsDefined(this.m_lookatTarget) {
      return false;
    };
    if AIBehaviorScriptBase.GetAITime(context) < this.m_activationTimeStamp + this.GetLookActivationDelay() {
      return false;
    };
    return true;
  }

  private func Activate(context: ScriptExecutionContext) -> Void {
    this.Activate(context);
    this.m_activationTimeStamp = AIBehaviorScriptBase.GetAITime(context);
    if IsDefined(this.m_lookAtEvent) {
      this.DeactivateLookat(context, true);
    };
    this.UpdateLookat(context);
  }
}

public abstract class AIGenericAdvancedLookatTask extends AIGenericLookatTask {

  private let m_lookAtEvent: ref<LookAtAddEvent>;

  private let m_activationTimeStamp: Float;

  private let m_lookatTarget: wref<Entity>;

  protected func GetAimingLookatTarget(context: ScriptExecutionContext) -> ref<GameObject> {
    return null;
  }

  private func ActivateLookat(context: ScriptExecutionContext) -> Void {
    if IsDefined(this.m_lookAtEvent) {
      return;
    };
    this.m_lookAtEvent = new LookAtAddEvent();
    this.m_lookAtEvent.SetEntityTarget(this.m_lookatTarget, this.GetLookAtSlotName(), Vector4.EmptyVector());
    this.m_lookAtEvent.SetLimits(this.GetSoftLimitDegreesType(), this.GetHardLimitDegreesType(), this.GetHardLimitDistanceType(), this.GetBackLimitDegreesType());
    this.m_lookAtEvent.SetStyle(this.GetLookatStyle());
    if !IsFinal() {
      this.m_lookAtEvent.SetDebugInfo("ScriptAIGenericAdvancedLookatTask");
    };
    AIBehaviorScriptBase.GetPuppet(context).QueueEvent(this.m_lookAtEvent);
  }

  private func DeactivateLookat(context: ScriptExecutionContext, opt instant: Bool) -> Void {
    this.DeactivateLookatInternal(context, instant);
  }

  protected func ShouldLookatBeActive(context: ScriptExecutionContext) -> Bool {
    if AIBehaviorScriptBase.GetPuppet(context).GetBoolFromCharacterTweak("lookat_disabled", false) {
      return false;
    };
    this.m_lookatTarget = this.GetAimingLookatTarget(context);
    if !IsDefined(this.m_lookatTarget) {
      return false;
    };
    if AIBehaviorScriptBase.GetAITime(context) < this.m_activationTimeStamp + this.GetLookActivationDelay() {
      return false;
    };
    return true;
  }

  private func Activate(context: ScriptExecutionContext) -> Void {
    this.Activate(context);
    this.m_activationTimeStamp = AIBehaviorScriptBase.GetAITime(context);
    if IsDefined(this.m_lookAtEvent) {
      this.DeactivateLookat(context, true);
    };
    this.UpdateLookat(context);
  }
}

public abstract class AIGenericStaticLookatTask extends AIGenericLookatTask {

  private let m_lookAtEvent: ref<LookAtAddEvent>;

  private let m_activationTimeStamp: Float;

  private let m_lookatTarget: Vector4;

  private let m_currentLookatTarget: Vector4;

  protected func GetAimingLookatTarget(context: ScriptExecutionContext) -> Vector4 {
    return new Vector4(0.00, 0.00, 0.00, 0.00);
  }

  private func ActivateLookat(context: ScriptExecutionContext) -> Void {
    if IsDefined(this.m_lookAtEvent) {
      if Equals(this.m_currentLookatTarget, this.m_lookatTarget) {
        return;
      };
      this.DeactivateLookat(context, true);
    };
    this.m_lookAtEvent = new LookAtAddEvent();
    this.m_lookAtEvent.SetStaticTarget(this.m_lookatTarget);
    this.m_currentLookatTarget = this.m_lookatTarget;
    this.m_lookAtEvent.SetLimits(this.GetSoftLimitDegreesType(), this.GetHardLimitDegreesType(), this.GetHardLimitDistanceType(), this.GetBackLimitDegreesType());
    this.m_lookAtEvent.SetStyle(this.GetLookatStyle());
    if !IsFinal() {
      this.m_lookAtEvent.SetDebugInfo("ScriptAIGenericStaticLookatTask");
    };
    AIBehaviorScriptBase.GetPuppet(context).QueueEvent(this.m_lookAtEvent);
  }

  private func DeactivateLookat(context: ScriptExecutionContext, opt instant: Bool) -> Void {
    this.DeactivateLookatInternal(context, instant);
  }

  protected func ShouldLookatBeActive(context: ScriptExecutionContext) -> Bool {
    if AIBehaviorScriptBase.GetPuppet(context).GetBoolFromCharacterTweak("lookat_disabled", false) {
      return false;
    };
    this.m_lookatTarget = this.GetAimingLookatTarget(context);
    if Vector4.IsZero(this.m_lookatTarget) {
      return false;
    };
    if AIBehaviorScriptBase.GetAITime(context) < this.m_activationTimeStamp + this.GetLookActivationDelay() {
      return false;
    };
    return true;
  }

  private func Activate(context: ScriptExecutionContext) -> Void {
    this.Activate(context);
    this.m_activationTimeStamp = AIBehaviorScriptBase.GetAITime(context);
    if IsDefined(this.m_lookAtEvent) {
      this.DeactivateLookat(context, true);
    };
    this.UpdateLookat(context);
  }
}

public abstract class AISearchingLookat extends AIGenericStaticLookatTask {

  public inline edit let m_minAngleDifferenceMapping: ref<AIArgumentMapping>;

  protected let m_minAngleDifference: Float;

  public inline edit let m_maxLookAroundAngleMapping: ref<AIArgumentMapping>;

  protected let m_maxLookAroundAngle: Float;

  private let m_currentTarget: Vector4;

  private let m_lastTarget: Vector4;

  private let m_targetSwitchTimeStamp: Float;

  private let m_targetSwitchCooldown: Float;

  @default(AISearchingLookat, 1)
  private let m_sideHorizontal: Int32;

  @default(AISearchingLookat, 1)
  private let m_sideVertical: Int32;

  private func InitializeMemberVariables(context: ScriptExecutionContext) -> Bool {
    return false;
  }

  private func GetLookatTargetPosition(context: ScriptExecutionContext) -> Vector4 {
    return new Vector4(0.00, 0.00, 0.00, 0.00);
  }

  private func GetHardLimitDegreesType() -> animLookAtLimitDegreesType {
    return IntEnum(3l);
  }

  private func GetHardLimitDistanceType() -> animLookAtLimitDistanceType {
    return IntEnum(3l);
  }

  private func GetSoftLimitDegreesType() -> animLookAtLimitDegreesType {
    return IntEnum(3l);
  }

  private func GetBackLimitDegreesType() -> animLookAtLimitDegreesType {
    return animLookAtLimitDegreesType.Normal;
  }

  private func GetLookatStyle() -> animLookAtStyle {
    return animLookAtStyle.Fast;
  }

  private func GetAimingLookatTarget(context: ScriptExecutionContext) -> Vector4 {
    if AIBehaviorScriptBase.GetAITime(context) < this.m_targetSwitchTimeStamp + this.m_targetSwitchCooldown && this.GetAbsAngleToTarget(context) < this.GetSoftLookatLimitDegrees() * 0.50 {
      return this.m_currentTarget;
    };
    this.m_targetSwitchCooldown = RandRangeF(1.50, 3.00);
    this.m_targetSwitchTimeStamp = AIBehaviorScriptBase.GetAITime(context);
    return this.SelectNewAimingLookatTarget(context);
  }

  private final func SelectNewAimingLookatTarget(context: ScriptExecutionContext) -> Vector4 {
    let distanceToTarget: Float;
    let leftOffsetAngleCap: Float;
    let offsetVector: Vector4;
    let rightOffsetAngleCap: Float;
    let sideOffset: Float;
    let sideOffsetAngle: Float;
    if !this.InitializeMemberVariables(context) {
      return new Vector4(0.00, 0.00, 0.00, 0.00);
    };
    distanceToTarget = Vector4.Distance(AIBehaviorScriptBase.GetPuppet(context).GetWorldPosition(), this.GetLookatTargetPosition(context));
    if RandRange(0, 2) > 0 {
      this.m_sideHorizontal *= -1;
    };
    if RandRange(0, 2) > 0 {
      this.m_sideVertical *= -1;
    };
    this.LookatOffsetAngleLimit(context, this.m_lastTarget, leftOffsetAngleCap, rightOffsetAngleCap);
    if this.m_sideHorizontal > 0 {
      sideOffsetAngle = ClampF(this.m_maxLookAroundAngle, 0.00, rightOffsetAngleCap);
      if sideOffsetAngle < this.m_minAngleDifference {
        sideOffsetAngle = ClampF(this.m_maxLookAroundAngle, 0.00, leftOffsetAngleCap);
        this.m_sideHorizontal *= -1;
      };
    } else {
      sideOffsetAngle = ClampF(this.m_maxLookAroundAngle, 0.00, leftOffsetAngleCap);
    };
    sideOffsetAngle = RandRangeF(0.00, sideOffsetAngle);
    sideOffset = distanceToTarget * TanF(Deg2Rad(sideOffsetAngle));
    offsetVector = Vector4.FromHeading(Vector4.Heading(AIBehaviorScriptBase.GetPuppet(context).GetWorldPosition() - this.GetLookatTargetPosition(context)) + 90.00 * Cast(this.m_sideHorizontal));
    offsetVector.X *= sideOffset;
    offsetVector.Y *= sideOffset;
    if this.m_sideVertical > 0 {
      offsetVector.Z *= sideOffset * 0.50;
    } else {
      offsetVector.Z *= sideOffset * -0.25;
    };
    this.m_currentTarget = this.GetLookatTargetPosition(context) + offsetVector;
    this.m_currentTarget.W = 1.00;
    this.m_lastTarget = this.m_currentTarget;
    return this.m_currentTarget;
  }

  protected final func LookatOffsetAngleLimit(context: ScriptExecutionContext, lastTargetPosition: Vector4, out leftAngleCap: Float, out rightAngleCap: Float) -> Void {
    let angleToCheck: Float;
    let angleToTarget: Float;
    let lastDirection: Vector4;
    let originalDirection: Vector4;
    if Vector4.IsZero(lastTargetPosition) {
      lastTargetPosition = this.GetLookatTargetPosition(context);
    };
    lastDirection = lastTargetPosition - AIBehaviorScriptBase.GetPuppet(context).GetWorldPosition();
    originalDirection = this.GetLookatTargetPosition(context) - AIBehaviorScriptBase.GetPuppet(context).GetWorldPosition();
    angleToCheck = GetLookAtLimitDegreesValue(this.GetSoftLimitDegreesType()) * 0.50;
    angleToTarget = Vector4.GetAngleBetween(lastDirection, originalDirection);
    leftAngleCap = AbsF(-angleToCheck - angleToTarget);
    rightAngleCap = angleToCheck - angleToTarget;
  }

  protected final func GetSoftLookatLimitDegrees() -> Float {
    return GetLookAtLimitDegreesValue(this.GetSoftLimitDegreesType());
  }

  protected final func GetAbsAngleToTarget(context: ScriptExecutionContext) -> Float {
    let vecToTarget: Vector4 = this.GetLookatTargetPosition(context) - ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    let absAngleToTarget: Float = AbsF(Vector4.GetAngleDegAroundAxis(vecToTarget, ScriptExecutionContext.GetOwner(context).GetWorldForward(), ScriptExecutionContext.GetOwner(context).GetWorldUp()));
    return absAngleToTarget;
  }
}

public class LookatCompanion extends AIGenericAdvancedLookatTask {

  private func GetAimingLookatTarget(context: ScriptExecutionContext) -> ref<GameObject> {
    return AIBehaviorScriptBase.GetCompanion(context);
  }

  private func GetHardLimitDegreesType() -> animLookAtLimitDegreesType {
    return IntEnum(3l);
  }

  private func GetHardLimitDistanceType() -> animLookAtLimitDistanceType {
    return IntEnum(3l);
  }

  private func GetSoftLimitDegreesType() -> animLookAtLimitDegreesType {
    return IntEnum(3l);
  }

  private func GetBackLimitDegreesType() -> animLookAtLimitDegreesType {
    return animLookAtLimitDegreesType.Normal;
  }

  private func GetLookatStyle() -> animLookAtStyle {
    return animLookAtStyle.Normal;
  }

  private func GetLookActivationDelay() -> Float {
    return 0.50;
  }

  private func GetLookAtDeactivationDelay() -> Float {
    return 1.00;
  }
}

public class LookatCombatTarget extends AIGenericEntityLookatTask {

  private func GetAimingLookatTarget(context: ScriptExecutionContext) -> ref<GameObject> {
    return AIBehaviorScriptBase.GetCombatTarget(context);
  }

  private func GetLookatStyle() -> animLookAtStyle {
    return animLookAtStyle.Fast;
  }
}

public class HeadLookatCombatTarget extends LookatCombatTarget {

  private func GetLookAtSlotName() -> CName {
    return n"Head";
  }
}

public class LookatCombatTarget_WithoutArms extends AIGenericEntityLookatTask {

  private func GetAimingLookatTarget(context: ScriptExecutionContext) -> ref<GameObject> {
    return AIBehaviorScriptBase.GetCombatTarget(context);
  }
}

public class WoundedLookatController extends AIGenericEntityLookatTask {

  private func Activate(context: ScriptExecutionContext) -> Void {
    let m_aimingLookatEvent: ref<LookAtAddEvent> = new LookAtAddEvent();
    m_aimingLookatEvent.SetEntityTarget(AIBehaviorScriptBase.GetCombatTarget(context), n"Head", Vector4.EmptyVector());
    m_aimingLookatEvent.SetLimits(IntEnum(3l), IntEnum(3l), IntEnum(3l), IntEnum(3l));
    if !IsFinal() {
      m_aimingLookatEvent.SetDebugInfo("ScriptWoundedLookatController");
    };
    AIBehaviorScriptBase.GetPuppet(context).QueueEvent(m_aimingLookatEvent);
  }

  private func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void;
}

public class SearchPatternMappingLookat extends AISearchingLookat {

  public inline edit let m_targetObjectMapping: ref<AIArgumentMapping>;

  protected let m_lookatTargetObject: wref<GameObject>;

  private func GetLookatTargetPosition(context: ScriptExecutionContext) -> Vector4 {
    return this.m_lookatTargetObject.GetWorldPosition();
  }

  private func InitializeMemberVariables(context: ScriptExecutionContext) -> Bool {
    if IsDefined(this.m_targetObjectMapping) && !IsDefined(this.m_lookatTargetObject) {
      this.m_lookatTargetObject = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_targetObjectMapping));
    };
    if !IsDefined(this.m_lookatTargetObject) {
      return false;
    };
    if IsDefined(this.m_minAngleDifferenceMapping) && this.m_minAngleDifference == 0.00 {
      this.m_minAngleDifference = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_minAngleDifferenceMapping));
    };
    if IsDefined(this.m_maxLookAroundAngleMapping) && this.m_maxLookAroundAngle == 0.00 {
      this.m_maxLookAroundAngle = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_maxLookAroundAngleMapping));
    };
    return true;
  }
}

public class SearchInFrontPatternLookat extends AISearchingLookat {

  private func GetLookatTargetPosition(context: ScriptExecutionContext) -> Vector4 {
    return AIBehaviorScriptBase.GetPuppet(context).GetWorldPosition() + 10.00 * Vector4.Normalize(AIBehaviorScriptBase.GetPuppet(context).GetWorldForward());
  }

  private func InitializeMemberVariables(context: ScriptExecutionContext) -> Bool {
    if IsDefined(this.m_minAngleDifferenceMapping) && this.m_minAngleDifference == 0.00 {
      this.m_minAngleDifference = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_minAngleDifferenceMapping));
    };
    if IsDefined(this.m_maxLookAroundAngleMapping) && this.m_maxLookAroundAngle == 0.00 {
      this.m_maxLookAroundAngle = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_maxLookAroundAngleMapping));
    };
    return true;
  }
}

public class CentaurShieldLookatController extends AILookatTask {

  private let m_mainShieldLookat: ref<LookAtAddEvent>;

  private let m_mainShieldlookatActive: Bool;

  private let m_currentLookatTarget: wref<GameObject>;

  private let m_shieldTarget: wref<GameObject>;

  private let m_centaurBlackboard: wref<IBlackboard>;

  @default(CentaurShieldLookatController, -1.f)
  private let m_shieldTargetTimeStamp: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.Activate(context);
    if !IsDefined(this.m_centaurBlackboard) {
      this.m_centaurBlackboard = AIBehaviorScriptBase.GetPuppet(context).GetCustomBlackboard();
    };
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    switch this.GetShieldState(context) {
      case ECentaurShieldState.Active:
        this.UpdateActiveShield(context);
        break;
      case ECentaurShieldState.Destroyed:
        this.DeactivateMainShieldLookat(context);
        break;
      default:
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.Deactivate(context);
    if Equals(this.GetShieldState(context), ECentaurShieldState.Active) && IsDefined(AIBehaviorScriptBase.GetCombatTarget(context)) && !AIBehaviorScriptBase.GetPuppet(context).GetBoolFromCharacterTweak("lookat_shield_disabled", false) {
      this.ActivateMainShieldLookat(context, AIBehaviorScriptBase.GetCombatTarget(context));
    } else {
      this.DeactivateMainShieldLookat(context);
    };
  }

  private final func GetShieldState(context: ScriptExecutionContext) -> ECentaurShieldState {
    if IsDefined(AIBehaviorScriptBase.GetPuppet(context).GetCustomBlackboard()) {
      return IntEnum(AIBehaviorScriptBase.GetPuppet(context).GetCustomBlackboard().GetInt(GetAllBlackboardDefs().CustomCentaurBlackboard.ShieldState));
    };
    return ECentaurShieldState.Inactive;
  }

  private final func UpdateActiveShield(context: ScriptExecutionContext) -> Void {
    this.ReevaluateDesiredLookatTarget(context);
    if this.ShouldLookatAtShieldTarget(context) {
      this.ActivateMainShieldLookat(context, this.m_shieldTarget);
    } else {
      if this.ShouldLookatAtCombatTarget(context) {
        this.ActivateMainShieldLookat(context, AIBehaviorScriptBase.GetCombatTarget(context));
      } else {
        this.DeactivateMainShieldLookat(context);
      };
    };
  }

  private final func ShouldLookatAtShieldTarget(context: ScriptExecutionContext) -> Bool {
    let upperBodyState: gamedataNPCUpperBodyState;
    if AIBehaviorScriptBase.GetPuppet(context).GetBoolFromCharacterTweak("lookat_shield_disabled", false) {
      return false;
    };
    upperBodyState = AIBehaviorScriptBase.GetUpperBodyState(context);
    if Equals(upperBodyState, gamedataNPCUpperBodyState.Defend) {
      return false;
    };
    if IsDefined(this.m_shieldTarget) {
      return true;
    };
    return false;
  }

  private final func ShouldLookatAtCombatTarget(context: ScriptExecutionContext) -> Bool {
    let upperBodyState: gamedataNPCUpperBodyState;
    if AIBehaviorScriptBase.GetPuppet(context).GetBoolFromCharacterTweak("lookat_shield_disabled", false) {
      return false;
    };
    if !IsDefined(AIBehaviorScriptBase.GetCombatTarget(context)) {
      return false;
    };
    upperBodyState = AIBehaviorScriptBase.GetUpperBodyState(context);
    if Equals(upperBodyState, gamedataNPCUpperBodyState.Attack) {
      return false;
    };
    if Equals(upperBodyState, gamedataNPCUpperBodyState.Defend) {
      return false;
    };
    if AIBehaviorScriptBase.GetPuppet(context).GetBoolFromCharacterTweak("lookat_shield_enableOnCumulatedDamage", false) && AIBehaviorScriptBase.GetHitReactionComponent(context).GetCumulatedDamage() <= 0.00 {
      return false;
    };
    return true;
  }

  private final func ActivateMainShieldLookat(context: ScriptExecutionContext, lookatTarget: wref<GameObject>) -> Void {
    if lookatTarget != this.m_currentLookatTarget {
      this.DeactivateMainShieldLookat(context);
    };
    if this.m_mainShieldlookatActive {
      return;
    };
    this.m_currentLookatTarget = lookatTarget;
    this.m_mainShieldLookat = new LookAtAddEvent();
    this.m_mainShieldLookat.SetEntityTarget(this.m_currentLookatTarget, n"Head", Vector4.EmptyVector());
    this.m_mainShieldLookat.bodyPart = n"LeftHand";
    this.m_mainShieldLookat.SetLimits(IntEnum(3l), IntEnum(3l), IntEnum(3l), IntEnum(3l));
    if !IsFinal() {
      this.m_mainShieldLookat.SetDebugInfo("ScriptActivateMainShieldLookat");
    };
    AIBehaviorScriptBase.GetPuppet(context).QueueEvent(this.m_mainShieldLookat);
    AnimationControllerComponent.SetInputBoolToReplicate(ScriptExecutionContext.GetOwner(context), n"shield_lookat_active", true);
    this.m_mainShieldlookatActive = true;
  }

  protected final func DeactivateMainShieldLookat(context: ScriptExecutionContext) -> Void {
    if !this.m_mainShieldlookatActive {
      return;
    };
    LookAtRemoveEvent.QueueRemoveLookatEvent(AIBehaviorScriptBase.GetPuppet(context), this.m_mainShieldLookat);
    AnimationControllerComponent.SetInputBoolToReplicate(ScriptExecutionContext.GetOwner(context), n"shield_lookat_active", false);
    this.m_mainShieldlookatActive = false;
  }

  private final func ReevaluateDesiredLookatTarget(context: ScriptExecutionContext) -> Void {
    let emptyID: EntityID;
    let shieldTargetID: EntityID = this.m_centaurBlackboard.GetEntityID(GetAllBlackboardDefs().CustomCentaurBlackboard.ShieldTarget);
    if EntityID.IsDefined(shieldTargetID) {
      this.m_shieldTarget = GameInstance.FindEntityByID(AIBehaviorScriptBase.GetGame(context), shieldTargetID) as GameObject;
    };
    if this.m_shieldTarget != null {
      if this.m_shieldTargetTimeStamp < 0.00 {
        this.m_shieldTargetTimeStamp = AIBehaviorScriptBase.GetAITime(context);
      };
      if this.IsShieldTargetValid(context) {
        return;
      };
    };
    this.m_shieldTarget = null;
    this.m_centaurBlackboard.SetEntityID(GetAllBlackboardDefs().CustomCentaurBlackboard.ShieldTarget, emptyID);
    this.m_shieldTargetTimeStamp = -1.00;
  }

  private final func IsShieldTargetValid(context: ScriptExecutionContext) -> Bool {
    let shieldTargetTimeout: Float = AIBehaviorScriptBase.GetPuppet(context).GetFloatFromCharacterTweak("lookat_shield_targetTimeout", -1.00);
    let maxDistance: Float = AIBehaviorScriptBase.GetPuppet(context).GetFloatFromCharacterTweak("lookat_shield_targetMaxDistance", -1.00);
    if maxDistance > 0.00 && this.GetDistanceToShieldTarget(context) > maxDistance {
      return false;
    };
    if shieldTargetTimeout > 0.00 && AIBehaviorScriptBase.GetAITime(context) >= this.m_shieldTargetTimeStamp + shieldTargetTimeout {
      return false;
    };
    return true;
  }

  private final func GetDistanceToShieldTarget(context: ScriptExecutionContext) -> Float {
    if !IsDefined(this.m_shieldTarget) {
      return -1.00;
    };
    return Vector4.Distance(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), this.m_shieldTarget.GetWorldPosition());
  }
}
