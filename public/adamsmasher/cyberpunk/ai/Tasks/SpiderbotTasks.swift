
public class FindClosestScavengeTarget extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    let scavengeComponent: ref<ScavengeComponent> = owner.GetScavengeComponent();
    let scavengeTargets: array<wref<GameObject>> = scavengeComponent.GetScavengeTargets();
    let closestTarget: wref<GameObject> = this.GetClosestTarget(context, scavengeTargets);
    ScriptExecutionContext.SetArgumentObject(context, n"ScavengeTarget", closestTarget);
    ScriptExecutionContext.SetArgumentVector(context, n"ScavengeTargetPos", new Vector4(0.00, 0.00, 0.00, 0.00));
  }

  private final func GetClosestTarget(context: ScriptExecutionContext, targets: array<wref<GameObject>>) -> wref<GameObject> {
    let closestTarget: wref<GameObject>;
    let currentTargetDistance: Float;
    let shortestDistance: Float;
    let i: Int32 = 0;
    while i < ArraySize(targets) {
      currentTargetDistance = Vector4.Distance(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), targets[i].GetWorldPosition());
      if currentTargetDistance < shortestDistance || shortestDistance == 0.00 {
        shortestDistance = currentTargetDistance;
        closestTarget = targets[i];
      };
      i += 1;
    };
    return closestTarget;
  }
}

public class MoveToScavengeTarget extends AIbehaviortaskScript {

  @default(MoveToScavengeTarget, -1.f)
  private let m_lastTime: Float;

  private let m_timeout: Float;

  @default(MoveToScavengeTarget, 0.1f)
  private let m_timeoutDuration: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_timeout = this.m_timeoutDuration;
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let actionEvent: ref<ActionEvent>;
    let changeDestinationEvent: ref<gameChangeDestination>;
    let dt: Float;
    let scavengeTarget: wref<GameObject>;
    if this.m_lastTime < 0.00 {
      this.m_lastTime = AIBehaviorScriptBase.GetAITime(context);
    };
    dt = AIBehaviorScriptBase.GetAITime(context) - this.m_lastTime;
    this.m_lastTime = AIBehaviorScriptBase.GetAITime(context);
    this.m_timeout -= dt;
    if this.m_timeout > 0.00 {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    this.m_timeout = this.m_timeoutDuration;
    scavengeTarget = ScriptExecutionContext.GetArgumentObject(context, n"ScavengeTarget");
    ScriptExecutionContext.SetArgumentVector(context, n"ScavengeTargetPos", scavengeTarget.GetWorldPosition());
    changeDestinationEvent = new gameChangeDestination();
    changeDestinationEvent.destination = scavengeTarget.GetWorldPosition();
    actionEvent = new ActionEvent();
    actionEvent.name = n"actionEvent";
    actionEvent.internalEvent = changeDestinationEvent;
    ScriptExecutionContext.GetOwner(context).QueueEvent(actionEvent);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.m_lastTime = -1.00;
    this.m_timeout = this.m_timeoutDuration;
  }
}

public class ScavengeTarget extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let scavengeTarget: wref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"ScavengeTarget");
    let targetDisassembleEvent: ref<DisassembleEvent> = new DisassembleEvent();
    scavengeTarget.QueueEvent(targetDisassembleEvent);
  }
}

public class HaveScavengeTargets extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    let scavengeComponent: ref<ScavengeComponent> = owner.GetScavengeComponent();
    let scavengeTargets: array<wref<GameObject>> = scavengeComponent.GetScavengeTargets();
    return Cast(ArraySize(scavengeTargets) > 0);
  }
}

public class AITakedownHandler extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let rawCommand: ref<IScriptable>;
    let takedownCommand: ref<AIFollowerTakedownCommand>;
    if !IsDefined(this.m_inCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    takedownCommand = rawCommand as AIFollowerTakedownCommand;
    if !IsDefined(takedownCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(takedownCommand.target) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if ScriptExecutionContext.GetArgumentObject(context, n"TakedownTarget") != takedownCommand.target {
      ScriptExecutionContext.SetArgumentObject(context, n"TakedownTarget", takedownCommand.target);
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func Deactivate(context: ScriptExecutionContext) -> Void {
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let takedownCommand: ref<AIFollowerTakedownCommand> = rawCommand as AIFollowerTakedownCommand;
    let aiComponent: ref<AIHumanComponent> = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent();
    if IsDefined(takedownCommand) {
      aiComponent.StopExecutingCommand(takedownCommand, true);
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
  }
}

public class AICommandDeviceHandler extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let deviceCommand: ref<AIFollowerDeviceCommand>;
    let rawCommand: ref<IScriptable>;
    if !IsDefined(this.m_inCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    deviceCommand = rawCommand as AIFollowerDeviceCommand;
    if !IsDefined(deviceCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(deviceCommand.target) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if ScriptExecutionContext.GetArgumentObject(context, n"Target") != deviceCommand.target {
      ScriptExecutionContext.SetArgumentObject(context, n"Target", deviceCommand.target);
    };
    if deviceCommand.overrideMovementTarget != null && ScriptExecutionContext.GetArgumentObject(context, n"MovementTarget") != deviceCommand.overrideMovementTarget {
      ScriptExecutionContext.SetArgumentObject(context, n"MovementTarget", deviceCommand.overrideMovementTarget);
    } else {
      if deviceCommand.overrideMovementTarget == null {
        ScriptExecutionContext.SetArgumentObject(context, n"MovementTarget", deviceCommand.target);
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class AISetSoloModeHandler extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let rawCommand: ref<IScriptable>;
    let soloModeCommand: ref<AIFlatheadSetSoloModeCommand>;
    if !IsDefined(this.m_inCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    soloModeCommand = rawCommand as AIFlatheadSetSoloModeCommand;
    if !IsDefined(soloModeCommand) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetArgumentBool(context, n"SoloMode", soloModeCommand.soloModeState);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
  }
}

public class IsCombatModuleEquipped extends AIAutonomousConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    return Cast(GameInstance.GetStatsSystem(owner.GetGame()).GetStatBoolValue(Cast(owner.GetEntityID()), gamedataStatType.CanPickUpWeapon));
  }
}

public class AIPrepareTakedownData extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    TakedownGameEffectHelper.FillTakedownData(AIBehaviorScriptBase.GetPuppet(context), AIBehaviorScriptBase.GetPuppet(context), ScriptExecutionContext.GetArgumentObject(context, n"TakedownTarget"), n"takedowns", n"kill");
  }
}

public class AIDeviceFeedbackData extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.GetArgumentObject(context, n"Target").QueueEvent(new SpiderbotOrderCompletedEvent());
  }
}

public class AIFindForwardPositionAround extends AIbehaviortaskScript {

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let angleRad: Float;
    let findWallEndPos: Vector4;
    let fw: ref<NavigationFindWallResult>;
    let quat: Quaternion;
    let angleStep: Float = 30.00;
    let orientation: Quaternion = ScriptExecutionContext.GetOwner(context).GetWorldOrientation();
    let angle: Float = 0.00;
    while angle < 360.00 {
      Quaternion.SetIdentity(quat);
      angleRad = Deg2Rad(angle);
      Quaternion.SetZRot(quat, angleRad);
      quat = orientation * quat;
      findWallEndPos = ScriptExecutionContext.GetOwner(context).GetWorldPosition() + Quaternion.GetForward(quat) * 1.00;
      fw = GameInstance.GetAINavigationSystem(AIBehaviorScriptBase.GetGame(context)).FindWallInLineForCharacter(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), findWallEndPos, 0.20, ScriptExecutionContext.GetOwner(context));
      if Equals(fw.status, worldNavigationRequestStatus.OK) && !fw.isHit {
        ScriptExecutionContext.SetArgumentVector(context, n"ForwardPosition", findWallEndPos);
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
      angle += angleStep;
    };
    if NotEquals(fw.status, worldNavigationRequestStatus.OK) {
      ScriptExecutionContext.SetArgumentVector(context, n"ForwardPosition", ScriptExecutionContext.GetOwner(context).GetWorldPosition());
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class AIFindPositionAroundSelf extends AIbehaviortaskScript {

  public inline edit let m_distanceMin: ref<AIArgumentMapping>;

  public inline edit let m_distanceMax: ref<AIArgumentMapping>;

  public inline edit let m_angle: Float;

  public inline edit let m_angleOffset: Float;

  public inline edit let m_outPositionArgument: ref<AIArgumentMapping>;

  protected let m_finalPosition: Vector4;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let angleRad: Float;
    let currentAngle: Float;
    let distance: Float;
    let fw: ref<NavigationFindWallResult>;
    let quat: Quaternion;
    let orientation: Quaternion = ScriptExecutionContext.GetOwner(context).GetWorldOrientation();
    let initialAngle: Float = this.m_angleOffset - this.m_angle / 2.00;
    let i: Int32 = 0;
    while i < 5 {
      currentAngle = RandRangeF(initialAngle, initialAngle + this.m_angle);
      Quaternion.SetIdentity(quat);
      angleRad = Deg2Rad(currentAngle);
      Quaternion.SetZRot(quat, angleRad);
      quat = orientation * quat;
      distance = RandRangeF(FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_distanceMin)), FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_distanceMax)));
      this.m_finalPosition = ScriptExecutionContext.GetOwner(context).GetWorldPosition() + Quaternion.GetForward(quat) * distance;
      fw = GameInstance.GetAINavigationSystem(AIBehaviorScriptBase.GetGame(context)).FindWallInLineForCharacter(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), this.m_finalPosition, 0.20, ScriptExecutionContext.GetOwner(context));
      if Equals(fw.status, worldNavigationRequestStatus.OK) && !fw.isHit && this.AdditionalOutcomeVerification(context) {
        ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(this.m_finalPosition));
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
      i += 1;
    };
    return AIbehaviorUpdateOutcome.FAILURE;
  }

  protected func AdditionalOutcomeVerification(context: ScriptExecutionContext) -> Bool {
    return true;
  }
}

public class AISpiderbotFindBoredMovePosition extends AIFindPositionAroundSelf {

  public inline edit let m_maxWanderDistance: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_angle = 330.00;
    this.m_angleOffset = 180.00;
  }

  protected func AdditionalOutcomeVerification(context: ScriptExecutionContext) -> Bool {
    if Vector4.Distance(ScriptExecutionContext.GetArgumentObject(context, n"FriendlyTarget").GetWorldPosition(), this.m_finalPosition) > FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_maxWanderDistance)) {
      return false;
    };
    return true;
  }
}

public class AISpiderbotCheckIfFriendlyMoved extends AIAutonomousConditions {

  public inline edit let m_maxAllowedDelta: ref<AIArgumentMapping>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Vector4.Distance(ScriptExecutionContext.GetArgumentObject(context, n"FriendlyTarget").GetWorldPosition(), ScriptExecutionContext.GetArgumentVector(context, n"FriendlyTargetLastPosition")) > FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_maxAllowedDelta)));
  }
}

public class AIFindPositionAroundTarget extends AIbehaviortaskScript {

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let angle: Float;
    let bestPosition: Vector4;
    let currentPosition: Vector4;
    let fw: ref<NavigationFindWallResult>;
    let navigationPath: ref<NavigationPath>;
    let orientation: Quaternion;
    let potentialPosition: Vector4;
    let quat: Quaternion;
    let angleStep: Float = 15.00;
    let target: wref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
    let friendlyTarget: wref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"FriendlyTarget");
    if !IsDefined(target) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    orientation = target.GetWorldOrientation();
    currentPosition = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    angle = 90.00;
    while angle < 270.00 {
      Quaternion.SetIdentity(quat);
      Quaternion.SetZRot(quat, Deg2Rad(angle));
      quat = orientation * quat;
      potentialPosition = target.GetWorldPosition() + Quaternion.GetForward(quat) * RandRangeF(2.50, 3.50);
      navigationPath = GameInstance.GetAINavigationSystem(AIBehaviorScriptBase.GetGame(context)).CalculatePathForCharacter(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), potentialPosition, 0.20, ScriptExecutionContext.GetOwner(context));
      fw = GameInstance.GetAINavigationSystem(AIBehaviorScriptBase.GetGame(context)).FindWallInLineForCharacter(target.GetWorldPosition(), potentialPosition, 0.20, ScriptExecutionContext.GetOwner(context));
      if navigationPath != null && Equals(fw.status, worldNavigationRequestStatus.OK) && !fw.isHit && Vector4.Distance(currentPosition, friendlyTarget.GetWorldPosition()) < 25.00 {
        if Vector4.IsZero(bestPosition) || Vector4.Distance(currentPosition, potentialPosition) < Vector4.Distance(currentPosition, bestPosition) {
          bestPosition = potentialPosition;
        };
      };
      angle += angleStep;
    };
    if !Vector4.IsZero(bestPosition) {
      ScriptExecutionContext.SetArgumentVector(context, n"ForwardPosition", bestPosition);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.FAILURE;
  }
}

public class AISetHealthRegenerationState extends AIbehaviortaskScript {

  public edit let healthRegeneration: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let emptyModifier: StatPoolModifier;
    if this.healthRegeneration {
      GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RequestResetingModifier(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration);
    } else {
      GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RequestSettingModifier(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration, emptyModifier);
    };
  }
}

public class AISetAutocraftingState extends AIbehaviortaskScript {

  public edit let newState: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let autocraftActivateRequest: ref<AutocraftActivateRequest>;
    let autocraftDeactivateRequest: ref<AutocraftDeactivateRequest>;
    let autocraftSystem: ref<AutocraftSystem> = GameInstance.GetScriptableSystemsContainer(ScriptExecutionContext.GetOwner(context).GetGame()).Get(n"AutocraftSystem") as AutocraftSystem;
    if this.newState {
      autocraftActivateRequest = new AutocraftActivateRequest();
      autocraftSystem.QueueRequest(autocraftActivateRequest);
    } else {
      autocraftDeactivateRequest = new AutocraftDeactivateRequest();
      autocraftDeactivateRequest.resetMemory = false;
      autocraftSystem.QueueRequest(autocraftDeactivateRequest);
    };
  }
}

public class SelectClosestPlayerThreat extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let closestDistance: Float;
    let closestThreat: ref<Entity>;
    let tempDistance: Float;
    let trackerComponent: ref<TargetTrackerComponent> = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent();
    let threats: array<TrackedLocation> = trackerComponent.GetHostileThreats(false);
    let playerPosition: Vector4 = GameInstance.GetPlayerSystem(AIBehaviorScriptBase.GetGame(context)).GetLocalPlayerMainGameObject().GetWorldPosition();
    let i: Int32 = 0;
    while i < ArraySize(threats) {
      tempDistance = Vector4.Distance(playerPosition, threats[i].location.position);
      if tempDistance <= closestDistance || closestDistance == 0.00 {
        closestDistance = tempDistance;
        closestThreat = threats[i].entity;
      };
      i += 1;
    };
    ScriptExecutionContext.SetArgumentObject(context, n"ClosestThreat", closestThreat as GameObject);
  }
}

public class SetManouverPosition extends AIbehaviortaskScript {

  public edit let m_distance: Float;

  public edit let m_angle: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let manouverDestination: Vector4 = ScriptExecutionContext.GetOwner(context).GetWorldPosition() + Vector4.RotByAngleXY(ScriptExecutionContext.GetOwner(context).GetWorldForward(), this.m_angle) * this.m_distance;
    ScriptExecutionContext.SetArgumentVector(context, n"ManouverPosition", manouverDestination);
  }
}

public class IsAnyThreatClose extends AIAutonomousConditions {

  public edit let m_distance: Float;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let distance: Float;
    let trackerComponent: ref<TargetTrackerComponent> = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent();
    let threats: array<TrackedLocation> = trackerComponent.GetThreats(false);
    let puppetPosition: Vector4 = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    let i: Int32 = 0;
    while i < ArraySize(threats) {
      distance = Vector4.Distance(puppetPosition, threats[i].location.position);
      if distance <= this.m_distance {
        ScriptExecutionContext.SetArgumentObject(context, n"ClosestThreat", threats[i].entity as GameObject);
        return Cast(true);
      };
      i += 1;
    };
    return Cast(false);
  }
}

public class RemoveCommand extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
  }
}
