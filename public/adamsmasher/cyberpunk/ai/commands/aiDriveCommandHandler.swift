
public class AIDriveCommandsDelegate extends ScriptBehaviorDelegate {

  private let useKinematic: Bool;

  private let needDriver: Bool;

  private let splineRef: NodeRef;

  private let secureTimeOut: Float;

  private let forcedStartSpeed: Float;

  private let stopAtPathEnd: Bool;

  private let driveBackwards: Bool;

  private let reverseSpline: Bool;

  private let startFromClosest: Bool;

  private let keepDistanceBool: Bool;

  private let keepDistanceCompanion: wref<GameObject>;

  private let keepDistanceDistance: Float;

  private let rubberBandingBool: Bool;

  private let rubberBandingTargetRef: wref<GameObject>;

  private let rubberBandingMinDistance: Float;

  private let rubberBandingMaxDistance: Float;

  private let rubberBandingStopAndWait: Bool;

  private let rubberBandingTeleportToCatchUp: Bool;

  private let rubberBandingStayInFront: Bool;

  private let allowStubMovement: Bool;

  private let m_driveOnSplineCommand: ref<AIVehicleOnSplineCommand>;

  private let useTraffic: Bool;

  private let speedInTraffic: Float;

  private let target: wref<GameObject>;

  private let distanceMin: Float;

  private let distanceMax: Float;

  private let stopWhenTargetReached: Bool;

  private let trafficTryNeighborsForStart: Bool;

  private let trafficTryNeighborsForEnd: Bool;

  private let m_driveFollowCommand: ref<AIVehicleFollowCommand>;

  private let nodeRef: NodeRef;

  private let isPlayer: Bool;

  private let forceGreenLights: Bool;

  private let portals: ref<vehiclePortalsList>;

  private let m_driveToNodeCommand: ref<AIVehicleToNodeCommand>;

  private let m_driveRacingCommand: ref<AIVehicleRacingCommand>;

  private let m_driveJoinTrafficCommand: ref<AIVehicleJoinTrafficCommand>;

  public final func DoStartDriveOnSpline(context: ScriptExecutionContext) -> Bool {
    let cmd: ref<AIVehicleOnSplineCommand> = this.m_driveOnSplineCommand;
    this.useKinematic = cmd.useKinematic;
    this.needDriver = cmd.needDriver;
    this.splineRef = cmd.splineRef;
    this.secureTimeOut = cmd.secureTimeOut;
    this.forcedStartSpeed = cmd.forcedStartSpeed;
    this.stopAtPathEnd = cmd.stopAtPathEnd;
    this.driveBackwards = cmd.driveBackwards;
    this.reverseSpline = cmd.reverseSpline;
    this.startFromClosest = cmd.startFromClosest;
    this.keepDistanceBool = cmd.keepDistanceBool;
    this.keepDistanceCompanion = cmd.keepDistanceCompanion;
    this.keepDistanceDistance = cmd.keepDistanceDistance;
    this.rubberBandingBool = cmd.rubberBandingBool;
    this.rubberBandingTargetRef = cmd.rubberBandingTargetRef;
    this.rubberBandingMinDistance = cmd.rubberBandingMinDistance;
    this.rubberBandingMaxDistance = cmd.rubberBandingMaxDistance;
    this.rubberBandingStopAndWait = cmd.rubberBandingStopAndWait;
    this.rubberBandingTeleportToCatchUp = cmd.rubberBandingTeleportToCatchUp;
    this.rubberBandingStayInFront = cmd.rubberBandingStayInFront;
    return true;
  }

  public final func DoEndDriveOnSpline() -> Bool {
    return true;
  }

  public final func DoStartDriveFollow(context: ScriptExecutionContext) -> Bool {
    let cmd: ref<AIVehicleFollowCommand> = this.m_driveFollowCommand;
    this.useKinematic = cmd.useKinematic;
    this.needDriver = cmd.needDriver;
    this.target = cmd.target;
    this.secureTimeOut = cmd.secureTimeOut;
    this.distanceMin = cmd.distanceMin;
    this.distanceMax = cmd.distanceMax;
    this.stopWhenTargetReached = cmd.stopWhenTargetReached;
    this.useTraffic = cmd.useTraffic;
    this.trafficTryNeighborsForStart = cmd.trafficTryNeighborsForStart;
    this.trafficTryNeighborsForEnd = cmd.trafficTryNeighborsForEnd;
    this.allowStubMovement = cmd.allowStubMovement;
    return true;
  }

  public final func DoUpdateDriveFollow(context: ScriptExecutionContext) -> Bool {
    if !IsDefined(this.m_driveFollowCommand) || this.m_driveFollowCommand.target != this.target {
      return false;
    };
    return true;
  }

  public final func DoEndDriveFollow(context: ScriptExecutionContext) -> Bool {
    return true;
  }

  public final func DoStopDriveFollow(context: ScriptExecutionContext) -> Bool {
    if IsDefined(this.m_driveFollowCommand) {
      this.m_driveFollowCommand = null;
    };
    return true;
  }

  public final func DoStartDriveToNode(context: ScriptExecutionContext) -> Bool {
    let cmd: ref<AIVehicleToNodeCommand> = this.m_driveToNodeCommand;
    this.useKinematic = cmd.useKinematic;
    this.needDriver = cmd.needDriver;
    this.nodeRef = cmd.nodeRef;
    this.stopAtPathEnd = cmd.stopAtPathEnd;
    this.secureTimeOut = cmd.secureTimeOut;
    this.isPlayer = cmd.isPlayer;
    this.useTraffic = cmd.useTraffic;
    this.speedInTraffic = cmd.speedInTraffic;
    this.forceGreenLights = cmd.forceGreenLights;
    this.portals = cmd.portals;
    this.trafficTryNeighborsForStart = cmd.trafficTryNeighborsForStart;
    this.trafficTryNeighborsForEnd = cmd.trafficTryNeighborsForEnd;
    return true;
  }

  public final func DoEndDriveToNode() -> Bool {
    return true;
  }

  public final func DoStartDriveRacing(context: ScriptExecutionContext) -> Bool {
    let cmd: ref<AIVehicleRacingCommand> = this.m_driveRacingCommand;
    this.useKinematic = cmd.useKinematic;
    this.needDriver = cmd.needDriver;
    this.splineRef = cmd.splineRef;
    this.secureTimeOut = cmd.secureTimeOut;
    this.driveBackwards = cmd.driveBackwards;
    this.reverseSpline = cmd.reverseSpline;
    this.startFromClosest = cmd.startFromClosest;
    this.rubberBandingBool = cmd.rubberBandingBool;
    this.rubberBandingTargetRef = cmd.rubberBandingTargetRef;
    this.rubberBandingMinDistance = cmd.rubberBandingMinDistance;
    this.rubberBandingMaxDistance = cmd.rubberBandingMaxDistance;
    this.rubberBandingStopAndWait = cmd.rubberBandingStopAndWait;
    this.rubberBandingTeleportToCatchUp = cmd.rubberBandingTeleportToCatchUp;
    this.rubberBandingStayInFront = cmd.rubberBandingStayInFront;
    return true;
  }

  public final func DoEndDriveRacing() -> Bool {
    return true;
  }

  public final func DoStartDriveJoinTraffic(context: ScriptExecutionContext) -> Bool {
    let cmd: ref<AIVehicleJoinTrafficCommand> = this.m_driveJoinTrafficCommand;
    this.useKinematic = cmd.useKinematic;
    this.needDriver = cmd.needDriver;
    return true;
  }

  public final func DoEndDriveJoinTraffic() -> Bool {
    return true;
  }
}

public class AIDriveOnSplineCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outUseKinematic: ref<AIArgumentMapping>;

  protected inline edit let m_outNeedDriver: ref<AIArgumentMapping>;

  protected inline edit let m_outSpline: ref<AIArgumentMapping>;

  protected inline edit let m_outSecureTimeOut: ref<AIArgumentMapping>;

  protected inline edit let m_outDriveBackwards: ref<AIArgumentMapping>;

  protected inline edit let m_outReverseSpline: ref<AIArgumentMapping>;

  protected inline edit let m_outStartFromClosest: ref<AIArgumentMapping>;

  protected inline edit let m_outForcedStartSpeed: ref<AIArgumentMapping>;

  protected inline edit let m_outStopAtPathEnd: ref<AIArgumentMapping>;

  protected inline edit let m_outKeepDistanceBool: ref<AIArgumentMapping>;

  protected inline edit let m_outKeepDistanceCompanion: ref<AIArgumentMapping>;

  protected inline edit let m_outKeepDistanceDistance: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingBool: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingTargetRef: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingMinDistance: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingMaxDistance: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingStopAndWait: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingTeleportToCatchUp: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingStayInFront: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIVehicleOnSplineCommand> = command as AIVehicleOnSplineCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIVehicleOnSplineCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outUseKinematic, ToVariant(typedCommand.useKinematic));
    ScriptExecutionContext.SetMappingValue(context, this.m_outNeedDriver, ToVariant(typedCommand.needDriver));
    ScriptExecutionContext.SetMappingValue(context, this.m_outSpline, ToVariant(typedCommand.splineRef));
    ScriptExecutionContext.SetMappingValue(context, this.m_outSecureTimeOut, ToVariant(typedCommand.secureTimeOut));
    ScriptExecutionContext.SetMappingValue(context, this.m_outDriveBackwards, ToVariant(typedCommand.driveBackwards));
    ScriptExecutionContext.SetMappingValue(context, this.m_outReverseSpline, ToVariant(typedCommand.reverseSpline));
    ScriptExecutionContext.SetMappingValue(context, this.m_outStartFromClosest, ToVariant(typedCommand.startFromClosest));
    ScriptExecutionContext.SetMappingValue(context, this.m_outForcedStartSpeed, ToVariant(typedCommand.forcedStartSpeed));
    ScriptExecutionContext.SetMappingValue(context, this.m_outStopAtPathEnd, ToVariant(typedCommand.stopAtPathEnd));
    ScriptExecutionContext.SetMappingValue(context, this.m_outKeepDistanceBool, ToVariant(typedCommand.keepDistanceBool));
    ScriptExecutionContext.SetMappingValue(context, this.m_outKeepDistanceCompanion, ToVariant(typedCommand.keepDistanceCompanion));
    ScriptExecutionContext.SetMappingValue(context, this.m_outKeepDistanceDistance, ToVariant(typedCommand.keepDistanceDistance));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingBool, ToVariant(typedCommand.rubberBandingBool));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingTargetRef, ToVariant(typedCommand.rubberBandingTargetRef));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingMinDistance, ToVariant(typedCommand.rubberBandingMinDistance));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingMaxDistance, ToVariant(typedCommand.rubberBandingMaxDistance));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingStopAndWait, ToVariant(typedCommand.rubberBandingStopAndWait));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingTeleportToCatchUp, ToVariant(typedCommand.rubberBandingTeleportToCatchUp));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingStayInFront, ToVariant(typedCommand.rubberBandingStayInFront));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AIDriveFollowCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outUseKinematic: ref<AIArgumentMapping>;

  protected inline edit let m_outNeedDriver: ref<AIArgumentMapping>;

  protected inline edit let m_outTarget: ref<AIArgumentMapping>;

  protected inline edit let m_outSecureTimeOut: ref<AIArgumentMapping>;

  protected inline edit let m_outDistanceMin: ref<AIArgumentMapping>;

  protected inline edit let m_outDistanceMax: ref<AIArgumentMapping>;

  protected inline edit let m_outStopWhenTargetReached: ref<AIArgumentMapping>;

  protected inline edit let m_outUseTraffic: ref<AIArgumentMapping>;

  protected inline edit let m_outTrafficTryNeighborsForStart: ref<AIArgumentMapping>;

  protected inline edit let m_outTrafficTryNeighborsForEnd: ref<AIArgumentMapping>;

  protected inline edit let m_outAllowStubMovement: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIVehicleFollowCommand> = command as AIVehicleFollowCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIVehicleFollowCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outUseKinematic, ToVariant(typedCommand.useKinematic));
    ScriptExecutionContext.SetMappingValue(context, this.m_outNeedDriver, ToVariant(typedCommand.needDriver));
    ScriptExecutionContext.SetMappingValue(context, this.m_outTarget, ToVariant(typedCommand.target));
    ScriptExecutionContext.SetMappingValue(context, this.m_outSecureTimeOut, ToVariant(typedCommand.secureTimeOut));
    ScriptExecutionContext.SetMappingValue(context, this.m_outDistanceMin, ToVariant(typedCommand.distanceMin));
    ScriptExecutionContext.SetMappingValue(context, this.m_outDistanceMax, ToVariant(typedCommand.distanceMax));
    ScriptExecutionContext.SetMappingValue(context, this.m_outStopWhenTargetReached, ToVariant(typedCommand.stopWhenTargetReached));
    ScriptExecutionContext.SetMappingValue(context, this.m_outUseTraffic, ToVariant(typedCommand.useTraffic));
    ScriptExecutionContext.SetMappingValue(context, this.m_outTrafficTryNeighborsForStart, ToVariant(typedCommand.trafficTryNeighborsForStart));
    ScriptExecutionContext.SetMappingValue(context, this.m_outTrafficTryNeighborsForEnd, ToVariant(typedCommand.trafficTryNeighborsForEnd));
    ScriptExecutionContext.SetMappingValue(context, this.m_outAllowStubMovement, ToVariant(typedCommand.allowStubMovement));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AIDriveToNodeCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outUseKinematic: ref<AIArgumentMapping>;

  protected inline edit let m_outNeedDriver: ref<AIArgumentMapping>;

  protected inline edit let m_outNodeRef: ref<AIArgumentMapping>;

  protected inline edit let m_outSecureTimeOut: ref<AIArgumentMapping>;

  protected inline edit let m_outIsPlayer: ref<AIArgumentMapping>;

  protected inline edit let m_outUseTraffic: ref<AIArgumentMapping>;

  protected inline edit let m_forceGreenLights: ref<AIArgumentMapping>;

  protected inline edit let m_portals: ref<AIArgumentMapping>;

  protected inline edit let m_outTrafficTryNeighborsForStart: ref<AIArgumentMapping>;

  protected inline edit let m_outTrafficTryNeighborsForEnd: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIVehicleToNodeCommand> = command as AIVehicleToNodeCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIVehicleToNodeCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outUseKinematic, ToVariant(typedCommand.useKinematic));
    ScriptExecutionContext.SetMappingValue(context, this.m_outNeedDriver, ToVariant(typedCommand.needDriver));
    ScriptExecutionContext.SetMappingValue(context, this.m_outNodeRef, ToVariant(typedCommand.nodeRef));
    ScriptExecutionContext.SetMappingValue(context, this.m_outSecureTimeOut, ToVariant(typedCommand.secureTimeOut));
    ScriptExecutionContext.SetMappingValue(context, this.m_outIsPlayer, ToVariant(typedCommand.isPlayer));
    ScriptExecutionContext.SetMappingValue(context, this.m_outUseTraffic, ToVariant(typedCommand.useTraffic));
    ScriptExecutionContext.SetMappingValue(context, this.m_forceGreenLights, ToVariant(typedCommand.forceGreenLights));
    ScriptExecutionContext.SetMappingValue(context, this.m_portals, ToVariant(typedCommand.portals));
    ScriptExecutionContext.SetMappingValue(context, this.m_outTrafficTryNeighborsForStart, ToVariant(typedCommand.trafficTryNeighborsForStart));
    ScriptExecutionContext.SetMappingValue(context, this.m_outTrafficTryNeighborsForEnd, ToVariant(typedCommand.trafficTryNeighborsForEnd));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AIDriveRacingCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outUseKinematic: ref<AIArgumentMapping>;

  protected inline edit let m_outNeedDriver: ref<AIArgumentMapping>;

  protected inline edit let m_outSpline: ref<AIArgumentMapping>;

  protected inline edit let m_outSecureTimeOut: ref<AIArgumentMapping>;

  protected inline edit let m_outDriveBackwards: ref<AIArgumentMapping>;

  protected inline edit let m_outReverseSpline: ref<AIArgumentMapping>;

  protected inline edit let m_outStartFromClosest: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingBool: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingTargetRef: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingMinDistance: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingMaxDistance: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingStopAndWait: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingTeleportToCatchUp: ref<AIArgumentMapping>;

  protected inline edit let m_outRubberBandingStayInFront: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIVehicleRacingCommand> = command as AIVehicleRacingCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIVehicleRacingCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outUseKinematic, ToVariant(typedCommand.useKinematic));
    ScriptExecutionContext.SetMappingValue(context, this.m_outNeedDriver, ToVariant(typedCommand.needDriver));
    ScriptExecutionContext.SetMappingValue(context, this.m_outSpline, ToVariant(typedCommand.splineRef));
    ScriptExecutionContext.SetMappingValue(context, this.m_outSecureTimeOut, ToVariant(typedCommand.secureTimeOut));
    ScriptExecutionContext.SetMappingValue(context, this.m_outDriveBackwards, ToVariant(typedCommand.driveBackwards));
    ScriptExecutionContext.SetMappingValue(context, this.m_outReverseSpline, ToVariant(typedCommand.reverseSpline));
    ScriptExecutionContext.SetMappingValue(context, this.m_outStartFromClosest, ToVariant(typedCommand.startFromClosest));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingBool, ToVariant(typedCommand.rubberBandingBool));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingTargetRef, ToVariant(typedCommand.rubberBandingTargetRef));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingMinDistance, ToVariant(typedCommand.rubberBandingMinDistance));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingMaxDistance, ToVariant(typedCommand.rubberBandingMaxDistance));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingStopAndWait, ToVariant(typedCommand.rubberBandingStopAndWait));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingTeleportToCatchUp, ToVariant(typedCommand.rubberBandingTeleportToCatchUp));
    ScriptExecutionContext.SetMappingValue(context, this.m_outRubberBandingStayInFront, ToVariant(typedCommand.rubberBandingStayInFront));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class AIDriveJoinTrafficCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outUseKinematic: ref<AIArgumentMapping>;

  protected inline edit let m_outNeedDriver: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIVehicleJoinTrafficCommand> = command as AIVehicleJoinTrafficCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIVehicleJoinTrafficCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outUseKinematic, ToVariant(typedCommand.useKinematic));
    ScriptExecutionContext.SetMappingValue(context, this.m_outNeedDriver, ToVariant(typedCommand.needDriver));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}
