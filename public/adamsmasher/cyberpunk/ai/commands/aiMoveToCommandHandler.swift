
public class AIMoveToCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outIsDynamicMove: ref<AIArgumentMapping>;

  protected inline edit let m_outMovementTarget: ref<AIArgumentMapping>;

  protected inline edit let m_outMovementTargetPos: ref<AIArgumentMapping>;

  protected inline edit let m_outRotateEntityTowardsFacingTarget: ref<AIArgumentMapping>;

  protected inline edit let m_outFacingTarget: ref<AIArgumentMapping>;

  protected inline edit let m_outMovementType: ref<AIArgumentMapping>;

  protected inline edit let m_outIgnoreNavigation: ref<AIArgumentMapping>;

  protected inline edit let m_outUseStart: ref<AIArgumentMapping>;

  protected inline edit let m_outUseStop: ref<AIArgumentMapping>;

  protected inline edit let m_outDesiredDistanceFromTarget: ref<AIArgumentMapping>;

  protected inline edit let m_outFinishWhenDestinationReached: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let currentHighLevelState: gamedataNPCHighLevelState;
    let isDynamicMove: Bool;
    let typedCommand: ref<AIMoveToCommand> = command as AIMoveToCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIMoveToCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    isDynamicMove = AIPositionSpec.IsEntity(typedCommand.movementTarget);
    ScriptExecutionContext.SetMappingValue(context, this.m_outIsDynamicMove, ToVariant(isDynamicMove));
    if isDynamicMove {
      ScriptExecutionContext.SetMappingValue(context, this.m_outMovementTarget, ToVariant(AIPositionSpec.GetEntity(typedCommand.movementTarget) as GameObject));
    } else {
      if AIPositionSpec.IsEmpty(typedCommand.movementTarget) {
        ScriptExecutionContext.SetMappingValue(context, this.m_outMovementTargetPos, ToVariant(MovePolicies.GetInvalidPos()));
      } else {
        ScriptExecutionContext.SetMappingValue(context, this.m_outMovementTargetPos, ToVariant(AIPositionSpec.GetWorldPosition(typedCommand.movementTarget)));
      };
    };
    if !ScriptExecutionContext.SetMappingValue(context, this.m_outRotateEntityTowardsFacingTarget, ToVariant(typedCommand.rotateEntityTowardsFacingTarget)) {
      LogAIError("Failed to set \'Out Rotate Entity Towards Facing Target\' argument mapping.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if AIPositionSpec.IsEntity(typedCommand.facingTarget) {
      if !ScriptExecutionContext.SetMappingValue(context, this.m_outFacingTarget, ToVariant(AIPositionSpec.GetEntity(typedCommand.facingTarget) as GameObject)) {
        LogAIError("Failed to set \'Out Facing Target\' argument mapping.");
        return AIbehaviorUpdateOutcome.FAILURE;
      };
    };
    if Equals((ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetNPCType(), gamedataNPCType.Drone) {
      ScriptExecutionContext.SetEnumMappingValue(context, this.m_outMovementType, EnumInt(moveMovementType.Walk));
      DroneComponent.SetLocomotionWrappers(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, EnumValueToName(n"moveMovementType", EnumInt(typedCommand.movementType)));
    } else {
      if Equals(typedCommand.movementType, moveMovementType.Run) {
        currentHighLevelState = IntEnum((ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
        if Equals(currentHighLevelState, gamedataNPCHighLevelState.Combat) && !ScriptExecutionContext.SetEnumMappingValue(context, this.m_outMovementType, EnumInt(moveMovementType.Sprint)) {
          LogAIError("Failed to set \'Out Movement Type\' argument mapping.");
          return AIbehaviorUpdateOutcome.FAILURE;
        };
        if !ScriptExecutionContext.SetEnumMappingValue(context, this.m_outMovementType, EnumInt(typedCommand.movementType)) {
          LogAIError("Failed to set \'Out Movement Type\' argument mapping.");
          return AIbehaviorUpdateOutcome.FAILURE;
        };
      } else {
        if !ScriptExecutionContext.SetEnumMappingValue(context, this.m_outMovementType, EnumInt(typedCommand.movementType)) {
          LogAIError("Failed to set \'Out Movement Type\' argument mapping.");
          return AIbehaviorUpdateOutcome.FAILURE;
        };
      };
    };
    if !ScriptExecutionContext.SetMappingValue(context, this.m_outIgnoreNavigation, ToVariant(typedCommand.ignoreNavigation)) {
      LogAIError("Failed to set \'Out Ignore Navigation\' argument mapping.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !ScriptExecutionContext.SetMappingValue(context, this.m_outUseStart, ToVariant(typedCommand.useStart)) {
      LogAIError("Failed to set \'Out Use Start\' argument mapping.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !ScriptExecutionContext.SetMappingValue(context, this.m_outUseStop, ToVariant(typedCommand.useStop)) {
      LogAIError("Failed to set \'Out Use Stop\' argument mapping.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !ScriptExecutionContext.SetMappingValue(context, this.m_outDesiredDistanceFromTarget, ToVariant(typedCommand.desiredDistanceFromTarget)) {
      LogAIError("Failed to set \'Out Desired Distance From Target\' argument mapping.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !ScriptExecutionContext.SetMappingValue(context, this.m_outFinishWhenDestinationReached, ToVariant(typedCommand.finishWhenDestinationReached)) {
      LogAIError("Failed to set \'Out Finish When Destination Reached\' argument mapping.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if typedCommand.alwaysUseStealth {
      NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Stealth);
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AIMoveOnSplineCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outSpline: ref<AIArgumentMapping>;

  protected inline edit let m_outMovementType: ref<AIArgumentMapping>;

  protected inline edit let m_outRotateTowardsFacingTarget: ref<AIArgumentMapping>;

  protected inline edit let m_outFacingTarget: ref<AIArgumentMapping>;

  protected inline edit let m_outSnapToTerrain: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let currentHighLevelState: gamedataNPCHighLevelState;
    let typedCommand: ref<AIMoveOnSplineCommand> = command as AIMoveOnSplineCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIMoveOnSplineCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if Equals(AIBehaviorScriptBase.GetPuppet(context).GetNPCType(), gamedataNPCType.Drone) {
      DroneComponent.SetLocomotionWrappers(AIBehaviorScriptBase.GetPuppet(context), EnumValueToName(n"moveMovementType", EnumInt(typedCommand.movementType.movementType)));
      typedCommand.movementType.movementType = moveMovementType.Walk;
    } else {
      if Equals(typedCommand.movementType.movementType, moveMovementType.Run) {
        currentHighLevelState = IntEnum((ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
        if Equals(currentHighLevelState, gamedataNPCHighLevelState.Combat) {
          typedCommand.movementType.movementType = moveMovementType.Sprint;
        } else {
          typedCommand.movementType.movementType = moveMovementType.Walk;
        };
      };
    };
    if typedCommand.alwaysUseStealth {
      NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Stealth);
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outSpline, ToVariant(typedCommand.spline));
    ScriptExecutionContext.SetMappingValue(context, this.m_outMovementType, ToVariant(typedCommand.movementType));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRotateTowardsFacingTarget, ToVariant(typedCommand.rotateEntityTowardsFacingTarget));
    ScriptExecutionContext.SetMappingValue(context, this.m_outFacingTarget, ToVariant(null));
    ScriptExecutionContext.SetMappingValue(context, this.m_outSnapToTerrain, ToVariant(typedCommand.snapToTerrain));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AIMoveRotateToCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_target: ref<AIArgumentMapping>;

  protected inline edit let m_angleTolerance: ref<AIArgumentMapping>;

  protected inline edit let m_angleOffset: ref<AIArgumentMapping>;

  protected inline edit let m_speed: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIRotateToCommand> = command as AIRotateToCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIMoveRotateToCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_target, ToVariant(AIPositionSpec.GetWorldPosition(typedCommand.target)));
    ScriptExecutionContext.SetMappingValue(context, this.m_angleTolerance, ToVariant(typedCommand.angleTolerance));
    ScriptExecutionContext.SetMappingValue(context, this.m_angleOffset, ToVariant(typedCommand.angleOffset));
    ScriptExecutionContext.SetMappingValue(context, this.m_speed, ToVariant(typedCommand.speed));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AIMoveCommandsDelegate extends ScriptBehaviorDelegate {

  protected inline edit let m_animMoveOnSplineCommand: wref<AIAnimMoveOnSplineCommand>;

  private let spline: NodeRef;

  private let useStart: Bool;

  private let useStop: Bool;

  private let reverse: Bool;

  private let controllerSetupName: CName;

  private let blendTime: Float;

  private let globalInBlendTime: Float;

  private let globalOutBlendTime: Float;

  private let turnCharacterToMatchVelocity: Bool;

  private let customStartAnimationName: CName;

  private let customMainAnimationName: CName;

  private let customStopAnimationName: CName;

  private let startSnapToTerrain: Bool;

  private let mainSnapToTerrain: Bool;

  private let stopSnapToTerrain: Bool;

  private let startSnapToTerrainBlendTime: Float;

  private let stopSnapToTerrainBlendTime: Float;

  private let m_moveOnSplineCommand: ref<AIMoveOnSplineCommand>;

  private let strafingTarget: wref<GameObject>;

  private let movementType: moveMovementType;

  private let ignoreNavigation: Bool;

  private let startFromClosestPoint: Bool;

  private let useCombatState: Bool;

  private let useAlertedState: Bool;

  private let noWaitToEndDistance: Float;

  private let noWaitToEndCompanionDistance: Float;

  @default(AIMoveCommandsDelegate, 9999999.0f)
  private let lowestCompanionDistanceToEnd: Float;

  @default(AIMoveCommandsDelegate, 9999999.0f)
  private let previousCompanionDistanceToEnd: Float;

  private let maxCompanionDistanceOnSpline: Float;

  private let companion: wref<GameObject>;

  private let ignoreLineOfSightCheck: Bool;

  private let shootingTarget: wref<GameObject>;

  private let minSearchAngle: Float;

  private let maxSearchAngle: Float;

  private let desiredDistance: Float;

  private let deadZoneRadius: Float;

  private let shouldBeInFrontOfCompanion: Bool;

  private let useMatchForSpeedForPlayer: Bool;

  private let lookAtTarget: wref<GameObject>;

  private let distanceToCompanion: Float;

  private let splineEndPoint: Vector4;

  private let hasSplineEndPoint: Bool;

  private let m_playerCompanion: wref<PlayerPuppet>;

  private let m_firstWaitingDemandTimestamp: Float;

  private let useOffMeshLinkReservation: Bool;

  private let sprint: Bool;

  private let run: Bool;

  private let waitForCompanion: Bool;

  private let m_followTargetCommand: ref<AIFollowTargetCommand>;

  private let stopWhenDestinationReached: Bool;

  private let teleportToTarget: Bool;

  private let shouldTeleportNow: Bool;

  private let teleportDestination: Vector4;

  private let matchTargetSpeed: Bool;

  public final func DoStartAnimMoveOnSpline() -> Bool {
    let c: ref<AIAnimMoveOnSplineCommand> = this.m_animMoveOnSplineCommand;
    this.spline = c.spline;
    this.useStart = c.useStart;
    this.useStop = c.useStop;
    this.controllerSetupName = c.controllerSetupName;
    this.blendTime = c.blendTime;
    this.globalInBlendTime = c.globalInBlendTime;
    this.globalOutBlendTime = c.globalOutBlendTime;
    this.turnCharacterToMatchVelocity = c.turnCharacterToMatchVelocity;
    this.customStartAnimationName = c.customStartAnimationName;
    this.customMainAnimationName = c.customMainAnimationName;
    this.customStopAnimationName = c.customStopAnimationName;
    this.startSnapToTerrain = c.startSnapToTerrain;
    this.mainSnapToTerrain = c.mainSnapToTerrain;
    this.stopSnapToTerrain = c.stopSnapToTerrain;
    this.startSnapToTerrainBlendTime = c.startSnapToTerrainBlendTime;
    this.stopSnapToTerrainBlendTime = c.stopSnapToTerrainBlendTime;
    return true;
  }

  public final func DoEndAnimMoveOnSpline() -> Bool {
    this.m_animMoveOnSplineCommand = null;
    return true;
  }

  public final func GetRotateEntity(context: ScriptExecutionContext) -> Bool {
    return this.m_moveOnSplineCommand.rotateEntityTowardsFacingTarget;
  }

  public final func DoStartMoveOnSpline(context: ScriptExecutionContext) -> Bool {
    let currentHighLevelState: gamedataNPCHighLevelState;
    let cmd: ref<AIMoveOnSplineCommand> = this.m_moveOnSplineCommand;
    this.spline = cmd.spline;
    this.strafingTarget = cmd.facingTarget;
    let puppetOwner: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppetOwner) {
      return false;
    };
    ScriptedPuppet.ResetActionSignal(puppetOwner, n"WaitForCompanion");
    if Equals(puppetOwner.GetNPCType(), gamedataNPCType.Drone) {
      DroneComponent.SetLocomotionWrappers(puppetOwner, EnumValueToName(n"moveMovementType", EnumInt(cmd.movementType.movementType)));
      cmd.movementType.movementType = moveMovementType.Walk;
    } else {
      if Equals(cmd.movementType.movementType, moveMovementType.Run) {
        currentHighLevelState = IntEnum(puppetOwner.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
        if Equals(currentHighLevelState, gamedataNPCHighLevelState.Combat) {
          cmd.movementType.movementType = moveMovementType.Sprint;
        } else {
          cmd.movementType.movementType = moveMovementType.Walk;
        };
      };
    };
    if cmd.alwaysUseStealth {
      NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Stealth);
    };
    this.movementType = AIMovementTypeSpec.Resolve(cmd.movementType, puppetOwner);
    this.ignoreNavigation = cmd.ignoreNavigation;
    this.startFromClosestPoint = cmd.startFromClosestPoint;
    this.mainSnapToTerrain = cmd.snapToTerrain;
    this.useCombatState = cmd.useCombatState;
    this.useAlertedState = cmd.useAlertedState;
    this.noWaitToEndDistance = cmd.noWaitToEndDistance;
    this.noWaitToEndCompanionDistance = cmd.noWaitToEndCompanionDistance;
    this.useStart = cmd.useStart;
    this.useStop = cmd.useStop;
    this.reverse = cmd.reverse;
    this.useOffMeshLinkReservation = cmd.useOMLReservation;
    this.companion = cmd.companion;
    this.desiredDistance = cmd.desiredDistance;
    this.deadZoneRadius = cmd.deadZoneRadius;
    this.matchTargetSpeed = cmd.catchUpWithCompanion;
    this.teleportToTarget = cmd.teleportToCompanion;
    this.maxCompanionDistanceOnSpline = cmd.maxCompanionDistanceOnSpline;
    this.ignoreLineOfSightCheck = cmd.ignoreLineOfSightCheck;
    this.minSearchAngle = cmd.minSearchAngle;
    this.maxSearchAngle = cmd.maxSearchAngle;
    if this.companion != cmd.shootingTarget {
      this.shootingTarget = cmd.shootingTarget;
    } else {
      this.shootingTarget = null;
    };
    this.lookAtTarget = cmd.lookAtTarget;
    this.hasSplineEndPoint = false;
    if IsDefined(this.companion) {
      this.hasSplineEndPoint = AIScriptUtils.GetEndPointOfSpline(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, this.splineEndPoint);
    };
    this.m_playerCompanion = this.companion as PlayerPuppet;
    if IsDefined(this.m_playerCompanion) && cmd.useMatchForSpeedForPlayer && this.desiredDistance < 0.00 {
      this.useMatchForSpeedForPlayer = true;
    } else {
      this.useMatchForSpeedForPlayer = false;
    };
    if this.desiredDistance < 0.00 {
      this.shouldBeInFrontOfCompanion = true;
    } else {
      this.shouldBeInFrontOfCompanion = false;
    };
    return true;
  }

  public final func DoEndMoveOnSpline() -> Bool {
    return true;
  }

  public final func DoFindClosestPointOnSpline(context: ScriptExecutionContext) -> Bool {
    if !AIScriptUtils.GetClosestPointOnSpline(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), this.teleportDestination) {
      return false;
    };
    return true;
  }

  public final func DoFindStartOfTheSpline(context: ScriptExecutionContext) -> Bool {
    if !AIScriptUtils.GetStartPointOfSpline(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, this.teleportDestination) {
      return false;
    };
    return true;
  }

  public final func DoFindEndOfTheSpline(context: ScriptExecutionContext) -> Bool {
    return false;
  }

  public final func GetIsMoveToSplineNeeded(context: ScriptExecutionContext) -> Bool {
    if AIScriptUtils.IsSplineStartRecalculated(context, this.spline) {
      return false;
    };
    if AIScriptUtils.ArePositionsEqual(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), this.teleportDestination) {
      return false;
    };
    return true;
  }

  private final func OnWalkingOnSpline(context: ScriptExecutionContext, success: Bool, isCompanionProgressing: Bool) -> Void {
    if success || !isCompanionProgressing {
      this.m_firstWaitingDemandTimestamp = -1.00;
    } else {
      if this.m_firstWaitingDemandTimestamp < 0.00 {
        this.m_firstWaitingDemandTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame()));
      };
    };
  }

  private final func ShouldBeWaitingDelayed(context: ScriptExecutionContext) -> Bool {
    return this.m_firstWaitingDemandTimestamp > 0.00 && EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) - this.m_firstWaitingDemandTimestamp < 4.00;
  }

  public final func DoUpdateDistanceToCompanionOnSpline(context: ScriptExecutionContext) -> Bool {
    let closestPointOnSpline: Vector4;
    let companionDistance: Float;
    let distanceToDestination: Float;
    let distanceToSpline: Float;
    let incline: Float;
    let isCompanionProgressingOnSpline: Bool;
    let companionHandle: ref<GameObject> = this.companion;
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let movePoliciesComponent: ref<MovePoliciesComponent> = owner.GetMovePolicesComponent();
    if !IsDefined(companionHandle) || !IsDefined(owner) {
      this.distanceToCompanion = 0.00;
      this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
      return true;
    };
    if !this.IsOnTheSpline(owner, 0.50) {
      this.distanceToCompanion = 0.00;
      this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
      return true;
    };
    if !IsDefined(companionHandle) || !IsDefined(owner) || !AIScriptUtils.GetClosestPointOnSpline(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, companionHandle.GetWorldPosition(), closestPointOnSpline) {
      this.distanceToCompanion = 0.00;
      this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
      return true;
    };
    if movePoliciesComponent.IsOnStairs() {
      this.OnWalkingOnSpline(context, true, true);
      return true;
    };
    if this.maxCompanionDistanceOnSpline > 0.00 && !this.IsOnTheSpline(companionHandle as ScriptedPuppet, 3.00) && this.lowestCompanionDistanceToEnd > 5.00 {
      this.OnWalkingOnSpline(context, false, isCompanionProgressingOnSpline);
      if !this.ShouldBeWaitingDelayed(context) {
        this.SetWaitForCompanion(owner, true);
      };
      return true;
    };
    if !AIScriptUtils.CalculateDistanceToEndFrom(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), distanceToDestination) {
      this.distanceToCompanion = 0.00;
      this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
      return true;
    };
    if !AIScriptUtils.CalculateDistanceToEndFrom(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, companionHandle.GetWorldPosition(), companionDistance) {
      this.distanceToCompanion = 0.00;
      this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
      return true;
    };
    if companionDistance < 0.10 {
      this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
      return true;
    };
    incline = owner.GetMovePolicesComponent().GetInclineAngle();
    distanceToSpline = Vector4.Distance(closestPointOnSpline, this.companion.GetWorldPosition());
    if distanceToSpline > AbsF(this.desiredDistance) {
      companionDistance += distanceToSpline;
    };
    this.distanceToCompanion = distanceToDestination - companionDistance;
    isCompanionProgressingOnSpline = this.previousCompanionDistanceToEnd > companionDistance;
    this.previousCompanionDistanceToEnd = companionDistance;
    this.lowestCompanionDistanceToEnd = MinF(this.lowestCompanionDistanceToEnd, companionDistance);
    if this.matchTargetSpeed {
      this.DoUpdateSpeed(context);
    };
    if GameObject.IsCooldownActive(owner, n"WaitForCompanion") {
      this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
      return true;
    };
    if this.desiredDistance < 0.00 {
      if AbsF(incline) > 5.00 {
        this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
        return true;
      };
      if this.DontWaitToCompanionNearEnd(owner, distanceToDestination, companionDistance) {
        this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
        return true;
      };
    };
    if this.distanceToCompanion <= this.desiredDistance {
      this.OnWalkingOnSpline(context, false, isCompanionProgressingOnSpline);
      if !this.ShouldBeWaitingDelayed(context) {
        this.SetWaitForCompanion(owner, true);
      };
      return true;
    };
    this.OnWalkingOnSpline(context, true, isCompanionProgressingOnSpline);
    return true;
  }

  private final func DoUpdateSpeed(context: ScriptExecutionContext) -> Void {
    if IsDefined(this.m_playerCompanion) {
      if Equals(PlayerPuppet.GetCurrentLocomotionState(this.m_playerCompanion), gamePSMLocomotionStates.Sprint) {
        this.sprint = true;
        this.run = false;
        return;
      };
    };
    if this.distanceToCompanion >= this.GetSprintSpeedDistance(context) {
      this.sprint = true;
      this.run = false;
    } else {
      this.sprint = false;
      this.run = false;
    };
  }

  public final func DoUpdateWaitForCompanionOnSpline(context: ScriptExecutionContext) -> Bool {
    let absoluteDistToCompanion: Float;
    let closestPointOnSplineCompanion: Vector4;
    let companionDistance: Float;
    let distanceToDestination: Float;
    let distanceToSpline: Float;
    let tolerance: Float;
    let companionHandle: ref<GameObject> = this.companion;
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let movePoliciesComponent: ref<MovePoliciesComponent> = owner.GetMovePolicesComponent();
    if !IsDefined(companionHandle) || !IsDefined(owner) || !AIScriptUtils.GetClosestPointOnSpline(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, companionHandle.GetWorldPosition(), closestPointOnSplineCompanion) {
      this.distanceToCompanion = 0.00;
      return true;
    };
    if this.maxCompanionDistanceOnSpline > 0.00 && !this.IsOnTheSpline(companionHandle as ScriptedPuppet, 3.00) && this.lowestCompanionDistanceToEnd > 5.00 {
      this.distanceToCompanion = 0.00;
      return true;
    };
    if !AIScriptUtils.CalculateDistanceToEndFrom(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), distanceToDestination) {
      this.distanceToCompanion = 0.00;
      return true;
    };
    if !AIScriptUtils.CalculateDistanceToEndFrom(ScriptExecutionContext.GetOwner(context).GetGame(), this.spline, companionHandle.GetWorldPosition(), companionDistance) {
      this.distanceToCompanion = 0.00;
      return true;
    };
    if companionDistance < 0.10 {
      this.SetWaitForCompanion(owner, false);
      return true;
    };
    distanceToSpline = Vector4.Distance(closestPointOnSplineCompanion, companionHandle.GetWorldPosition());
    if distanceToSpline > AbsF(this.desiredDistance) {
      companionDistance += distanceToSpline;
    };
    absoluteDistToCompanion = Vector4.Length(owner.GetWorldPosition() - companionHandle.GetWorldPosition());
    this.distanceToCompanion = distanceToDestination - companionDistance;
    this.lowestCompanionDistanceToEnd = MinF(this.lowestCompanionDistanceToEnd, companionDistance);
    if movePoliciesComponent.IsOnStairs() {
      this.SetWaitForCompanion(owner, false);
      return true;
    };
    if GameObject.IsCooldownActive(owner, n"WaitForCompanion") {
      return true;
    };
    if this.DontWaitToCompanionNearEnd(owner, distanceToDestination, companionDistance) {
      return true;
    };
    if distanceToDestination >= companionDistance {
      if absoluteDistToCompanion <= 2.00 {
        return true;
      };
    };
    if this.shouldBeInFrontOfCompanion {
      tolerance = this.deadZoneRadius;
    } else {
      tolerance = -this.deadZoneRadius;
    };
    if this.distanceToCompanion > this.desiredDistance + tolerance {
      this.SetWaitForCompanion(owner, false);
      return true;
    };
    return true;
  }

  private final func DontWaitToCompanionNearEnd(owner: ref<ScriptedPuppet>, distanceToDestination: Float, companionDistance: Float) -> Bool {
    if this.noWaitToEndDistance > 0.00 {
      if distanceToDestination < this.noWaitToEndDistance {
        if this.noWaitToEndCompanionDistance > 0.00 {
          if companionDistance < this.noWaitToEndCompanionDistance {
            this.SetWaitForCompanion(owner, false);
            return true;
          };
        } else {
          this.SetWaitForCompanion(owner, false);
          return true;
        };
      };
    };
    return false;
  }

  private final func IsOnTheSpline(target: ref<ScriptedPuppet>, tolerance: Float) -> Bool {
    let closestPointOnSpline: Vector4;
    let distanceToSpline: Float;
    if !IsDefined(target) || !AIScriptUtils.GetClosestPointOnSpline(target.GetGame(), this.spline, target.GetWorldPosition(), closestPointOnSpline) {
      return false;
    };
    distanceToSpline = Vector4.Length(target.GetWorldPosition() - closestPointOnSpline);
    if distanceToSpline >= tolerance {
      return false;
    };
    return true;
  }

  private final func SetWaitForCompanion(owner: ref<ScriptedPuppet>, value: Bool) -> Void {
    if GameObject.IsCooldownActive(owner, n"WaitForCompanion") {
      return;
    };
    if NotEquals(this.waitForCompanion, value) {
      if value {
        ScriptedPuppet.SendActionSignal(owner, n"WaitForCompanion", -1.00);
      } else {
        ScriptedPuppet.ResetActionSignal(owner, n"WaitForCompanion");
      };
      this.waitForCompanion = value;
      GameObject.StartCooldown(owner, n"WaitForCompanion", 2.00);
    };
  }

  public final func DoEndTeleportToCompanionOnSpline() -> Bool {
    this.startFromClosestPoint = true;
    return true;
  }

  public final func DoStartWaitForCompanion() -> Bool {
    this.useStart = false;
    return true;
  }

  public final func DoEndWaitForCompanion() -> Bool {
    this.startFromClosestPoint = true;
    return true;
  }

  public final func SelectSplineTeleportTarget(context: ScriptExecutionContext) -> Bool {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let radius: Float = this.desiredDistance;
    let center: Vector4 = this.companion.GetWorldPosition() - this.companion.GetWorldForward() * radius * 1.10;
    let adjustedCenter: Vector4 = owner.GetMovePolicesComponent().GetClosestPointToPath(center);
    let findResult: NavigationFindPointResult = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame()).FindPointInSphereForCharacter(adjustedCenter, radius, ScriptExecutionContext.GetOwner(context));
    if NotEquals(findResult.status, worldNavigationRequestStatus.OK) {
      return false;
    };
    this.teleportDestination = findResult.point;
    return true;
  }

  public final func GetSprintSpeedDistance(context: ScriptExecutionContext) -> Float {
    let actionId: TweakDBID;
    let result: Float;
    let tolerance: Float;
    if EnumInt(this.movementType) == EnumInt(moveMovementType.Sprint) {
      return -99999.00;
    };
    if this.shouldBeInFrontOfCompanion {
      actionId = t"IdleActions.MoveOnSplineWithCompanionParams.moveToFrontSprintSpeedDistance";
      tolerance = -6.00;
    } else {
      actionId = t"IdleActions.MoveOnSplineWithCompanionParams.catchUpSprintSpeedDistance";
      tolerance = 6.00;
    };
    result = TweakDBInterface.GetFloat(actionId, 12.00);
    if this.sprint {
      result += tolerance;
    };
    return result;
  }

  public final func GetRunSpeedDistance(context: ScriptExecutionContext) -> Float {
    let actionId: TweakDBID;
    let result: Float;
    let tolerance: Float;
    if EnumInt(this.movementType) == EnumInt(moveMovementType.Run) {
      return -99999.00;
    };
    if this.shouldBeInFrontOfCompanion {
      actionId = t"IdleActions.MoveOnSplineWithCompanionParams.moveToFrontRunSpeedDistance";
      tolerance = -3.00;
    } else {
      actionId = t"IdleActions.MoveOnSplineWithCompanionParams.catchUpRunSpeedDistance";
      tolerance = 3.00;
    };
    result = TweakDBInterface.GetFloat(actionId, 6.50);
    if this.run && this.shouldBeInFrontOfCompanion {
      result += tolerance;
    };
    return result;
  }

  public final func GetTeleportDistance(context: ScriptExecutionContext) -> Float {
    let actionId: TweakDBID = t"IdleActions.MoveOnSplineWithCompanionParams.catchUpTeleportDistance";
    return TweakDBInterface.GetFloat(actionId, 20.00);
  }

  public final func DoStartFollowTarget(context: ScriptExecutionContext) -> Bool {
    let cmd: ref<AIFollowTargetCommand> = this.m_followTargetCommand;
    if !IsDefined(cmd) {
      return false;
    };
    this.companion = cmd.target;
    this.desiredDistance = cmd.desiredDistance;
    this.deadZoneRadius = cmd.tolerance;
    this.stopWhenDestinationReached = cmd.stopWhenDestinationReached;
    this.movementType = cmd.movementType;
    this.lookAtTarget = cmd.lookAtTarget;
    this.matchTargetSpeed = cmd.matchSpeed;
    this.teleportToTarget = cmd.teleport;
    this.shouldTeleportNow = false;
    return true;
  }

  public final func SelectFollowTeleportTarget(context: ScriptExecutionContext) -> Bool {
    if !GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetFurthestNavmeshPointBehind(this.companion, 3.00, 3, this.teleportDestination, true) {
      return false;
    };
    return true;
  }
}
