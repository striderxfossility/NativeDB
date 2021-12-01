
public abstract class AIActionMovePolicy extends IScriptable {

  public final static func GetTargetPositionProvider(owner: ref<ScriptedPuppet>, target: wref<GameObject>, trackingMode: gamedataTrackingMode) -> ref<IPositionProvider> {
    let targetTrackerComponent: ref<TargetTrackerComponent> = owner.GetTargetTrackerComponent();
    let tmpProvider: ref<IPositionProvider> = IPositionProvider.CreateEntityPositionProvider(target);
    switch trackingMode {
      case gamedataTrackingMode.LastKnownPosition:
        tmpProvider = targetTrackerComponent.GetThreatBeliefPositionProvider(target, false, tmpProvider);
        return targetTrackerComponent.GetThreatLastKnownPositionProvider(target, false, tmpProvider);
      case gamedataTrackingMode.BeliefPosition:
        return targetTrackerComponent.GetThreatBeliefPositionProvider(target, false, tmpProvider);
      case gamedataTrackingMode.SharedLastKnownPosition:
        tmpProvider = targetTrackerComponent.GetThreatSharedBeliefPositionProvider(target, false, tmpProvider);
        return targetTrackerComponent.GetThreatSharedLastKnownPositionProvider(target, false, tmpProvider);
      case gamedataTrackingMode.SharedBeliefPosition:
        return targetTrackerComponent.GetThreatSharedBeliefPositionProvider(target, false, tmpProvider);
      default:
        return tmpProvider;
    };
  }

  public final static func Add(const context: ScriptExecutionContext, record: wref<MovementPolicy_Record>, out policy: ref<MovePolicies>) -> Void {
    let avoidThreatRange: Float;
    let costModCircle: ref<NavigationCostModCircle>;
    let count: Int32;
    let coverID: Uint64;
    let currentTopThreat: TrackedLocation;
    let destinationOrientation: Quaternion;
    let destinationOrientationPosition: Vector4;
    let destinationOrientationTarget: wref<GameObject>;
    let distance: Float;
    let i: Int32;
    let ringRecord: wref<AIRingType_Record>;
    let squadMembers: array<wref<Entity>>;
    let stimTarget: wref<GameObject>;
    let strafingPosition: Vector4;
    let strafingTarget: wref<GameObject>;
    let tagCondition: ref<AIActionCondition_Record>;
    let tagCount: Int32;
    let tagIndex: Int32;
    let tagList: ref<MovementPolicyTagList_Record>;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let targetTrackerComponent: ref<TargetTrackerComponent>;
    let threatPos: Vector4;
    let tolerance: Float;
    let movingExactlyToTarget: Bool = false;
    let hintDistanceMult: Float = 1.00;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) || !IsDefined(record.Target()) && !IsDefined(record.StrafingTarget()) {
      return;
    };
    if IsDefined(record.Target()) && !AIActionTarget.Get(context, record.Target(), false, target, targetPosition, coverID) {
      return;
    };
    if IsDefined(record.StrafingTarget()) && !AIActionTarget.Get(context, record.StrafingTarget(), false, strafingTarget, strafingPosition) {
      return;
    };
    hintDistanceMult = CombatSpaceHelper.GetDistanceMultiplier(puppet, record.SpatialHintMults());
    policy = new MovePolicies();
    policy.SetTweakDBID(record.GetID());
    policy.SetMaxPathLengthToDirectDistanceRatioCurve(record.MaxPathLengthToDirectDistanceRatioCurve());
    policy.SetMaxPathLength(record.MaxPathLength() * hintDistanceMult);
    if record.UseFollowSlots() {
      policy.SetUseFollowSlots(true);
      policy.SetUseSymmetricAnglesScores(record.SymmetricAnglesScores());
      policy.SetSquadInfo(0u, 1u);
      if AISquadHelper.GetSquadmates(target, squadMembers, false) {
        i = 0;
        while i < ArraySize(squadMembers) {
          if ScriptExecutionContext.GetOwner(context) == squadMembers[i] {
            policy.SetSquadInfo(Cast(i), Cast(ArraySize(squadMembers)));
          };
          i += 1;
        };
      };
    };
    if IsDefined(target) {
      policy.SetDestinationObject(target);
      if Equals(record.Ring().Type(), gamedataAIRingType.LatestActive) {
        ringRecord = AIActionHelper.GetLatestActiveRingTypeRecord(puppet);
        distance = ringRecord.Distance();
        tolerance = ringRecord.Tolerance();
      } else {
        if Equals(record.Ring().Type(), gamedataAIRingType.Undefined) || !AIActionHelper.GetDistanceAndToleranceFromRingType(record, distance, tolerance) {
          distance = record.Distance();
          tolerance = record.Tolerance();
        };
      };
      if distance == 0.00 && tolerance == 0.00 {
        movingExactlyToTarget = true;
      };
    } else {
      if Cast(coverID) {
        policy.SetDestinationCover(coverID);
      } else {
        if !Vector4.IsZero(targetPosition) {
          policy.SetDestinationPosition(targetPosition);
        };
      };
    };
    targetTrackerComponent = puppet.GetTargetTrackerComponent();
    avoidThreatRange = record.AvoidThreatRange();
    if avoidThreatRange > 0.00 {
      if IsDefined(targetTrackerComponent) && targetTrackerComponent.GetTopHostileThreat(false, currentTopThreat) {
        if IsDefined(currentTopThreat.entity) {
          threatPos = currentTopThreat.entity.GetWorldPosition();
          if !movingExactlyToTarget || Vector4.Distance(threatPos, target.GetWorldPosition()) > 0.10 {
            costModCircle = new NavigationCostModCircle();
            costModCircle.pos = threatPos;
            costModCircle.range = avoidThreatRange;
            costModCircle.cost = record.AvoidThreatCost();
            policy.SetCostModCircle(costModCircle);
          };
        };
      } else {
        if Equals(puppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Fear) {
          stimTarget = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
          if IsDefined(stimTarget) {
            costModCircle = new NavigationCostModCircle();
            costModCircle.pos = stimTarget.GetWorldPosition();
            costModCircle.range = avoidThreatRange;
            costModCircle.cost = record.AvoidThreatCost();
            policy.SetCostModCircle(costModCircle);
          };
        };
      };
    };
    if IsDefined(strafingTarget) {
      policy.SetStrafingTarget(strafingTarget);
    } else {
      if !Vector4.IsZero(strafingPosition) {
        policy.SetStrafingPosition(strafingPosition);
      };
    };
    if Equals(puppet.GetNPCType(), gamedataNPCType.Drone) {
      policy.SetMovementType(moveMovementType.Walk);
      DroneComponent.SetLocomotionWrappers(puppet, record.MovementType());
    } else {
      policy.SetMovementType(IntEnum(Cast(EnumValueFromName(n"moveMovementType", record.MovementType()))));
    };
    if IsDefined(record.DestinationOrientationPosition()) {
      if AIActionTarget.Get(context, record.DestinationOrientationPosition(), false, destinationOrientationTarget, destinationOrientationPosition) {
        destinationOrientation = Quaternion.BuildFromDirectionVector(Vector4.Normalize(destinationOrientationPosition - targetPosition));
        policy.SetDestinationOrientation(destinationOrientation);
      };
    };
    if hintDistanceMult != 1.00 {
      if !record.UseFollowSlots() {
        distance *= hintDistanceMult;
      };
      tolerance *= hintDistanceMult;
    };
    policy.SetDistancePolicy(distance, tolerance);
    policy.SetMinDistancePolicy(record.MinDistance());
    policy.SetStrafingPredictionTime(record.StrafingPredictionTime(), record.StrafingPredictionVelocityMax());
    policy.SetDynamicTargetUpdateTimer(record.DynamicTargetUpdateTimer(), record.DynamicTargetUpdateDistance());
    policy.SetCirclingPolicy(IntEnum(Cast(EnumValueFromName(n"moveCirclingDirection", record.CirclingDirection()))));
    policy.SetKeepLineOfSight(IntEnum(Cast(EnumValueFromName(n"moveLineOfSight", record.KeepLineOfSight()))));
    policy.SetGetOutOfWay(record.GetOutOfWay());
    policy.SetCollisionAvoidancePolicy(!record.IgnoreCollisionAvoidance(), !record.IgnoreSpotReservation());
    policy.SetInRestrictedArea(!record.IgnoreRestrictedMovementArea());
    policy.SetAvoidSafeArea(record.AvoidSafeArea());
    policy.SetUseStartStop(!record.DontUseStart(), !record.DontUseStop());
    policy.SetAvoidThreat(record.AvoidThreat());
    policy.SetIgnoreNavigation(record.IgnoreNavigation());
    policy.SetStrafingRotationOffset(record.StrafingRotationOffset());
    policy.SetUseLineOfSitePrecheck(!record.IgnoreLoSPrecheck());
    policy.SetStopOnObstacle(record.StopOnObstacle());
    policy.SetAvoidObstacleWithinTolerance(record.AvoidObstacleWithinTolerance());
    policy.SetIdleTurnsDeadZoneAngle(record.DeadAngle());
    policy.SetCalculateStartTangent(record.CalculateStartTangent());
    if record.ZDiff() >= 0.00 {
      policy.SetMaxZDiff(record.ZDiff());
    };
    if NotEquals(record.DebugName(), n"Script") {
      policy.SetDebugName(record.DebugName());
    } else {
      policy.SetDebugName(StringToName(TDBID.ToStringDEBUG(record.GetID())));
    };
    if IsDefined(target) && IsDefined(record.Target()) && NotEquals(record.Target().TrackingMode().Type(), gamedataTrackingMode.RealPosition) {
      policy.SetPositionProvider(AIActionMovePolicy.GetTargetPositionProvider(puppet, target, record.Target().TrackingMode().Type()));
    };
    if IsDefined(strafingTarget) && IsDefined(record.StrafingTarget()) && NotEquals(record.StrafingTarget().TrackingMode().Type(), gamedataTrackingMode.RealPosition) {
      policy.SetStrafingPositionProvider(AIActionMovePolicy.GetTargetPositionProvider(puppet, strafingTarget, record.StrafingTarget().TrackingMode().Type()));
    };
    if record.UseOffMeshAllowedTags() {
      policy.SetUseOffMeshAllowedTags(true);
      count = record.GetAllowedTagsCount();
      i = 0;
      while i < count {
        tagList = record.GetAllowedTagsItem(i);
        tagCondition = tagList.Condition();
        if AIActionMovePolicy.CheckCondition(context, tagCondition) {
          tagCount = tagList.GetTagsCount();
          tagIndex = 0;
          while tagIndex < tagCount {
            policy.AddAllowedTag(tagList.GetTagsItem(tagIndex));
            tagIndex += 1;
          };
        };
        i += 1;
      };
    };
    if record.UseOffMeshBlockedTags() {
      policy.SetUseOffMeshBlockedTags(true);
      count = record.GetBlockedTagsCount();
      i = 0;
      while i < count {
        tagList = record.GetBlockedTagsItem(i);
        tagCondition = tagList.Condition();
        if AIActionMovePolicy.CheckCondition(context, tagCondition) {
          tagCount = tagList.GetTagsCount();
          tagIndex = 0;
          while tagIndex < tagCount {
            policy.AddBlockedTag(tagList.GetTagsItem(tagIndex));
            tagIndex += 1;
          };
        };
        i += 1;
      };
    };
    puppet.GetMovePolicesComponent().AddPolicies(policy);
  }

  private final static func CheckCondition(const context: ScriptExecutionContext, condition: ref<AIActionCondition_Record>) -> Bool {
    if !IsDefined(condition) {
      return true;
    };
    return AICondition.CheckActionCondition(context, condition);
  }

  public final static func Pop(const context: ScriptExecutionContext, out policy: ref<MovePolicies>) -> Void {
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    puppet.GetMovePolicesComponent().PopPolicies(policy);
    policy = null;
  }
}
