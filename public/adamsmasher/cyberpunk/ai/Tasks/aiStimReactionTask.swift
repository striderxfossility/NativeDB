
public class ReactionManagerTask extends AIbehaviortaskScript {

  protected let m_reactionData: ref<AIReactionData>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_reactionData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionData();
    if !IsDefined(this.m_reactionData) {
      this.SendBehaviorStatus(ScriptExecutionContext.GetOwner(context), AIbehaviorUpdateOutcome.FAILURE);
    } else {
      this.SendBehaviorStatus(ScriptExecutionContext.GetOwner(context), AIbehaviorUpdateOutcome.IN_PROGRESS);
      this.UpdateArguments(context);
    };
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    if !IsDefined(this.m_reactionData) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if ScriptExecutionContext.GetArgumentObject(context, n"StimTarget") != this.m_reactionData.stimTarget {
      this.m_reactionData.stimTarget = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
      this.m_reactionData.stimSource = ScriptExecutionContext.GetArgumentVector(context, n"StimSource");
      this.SendBehaviorStatus(ScriptExecutionContext.GetOwner(context), AIbehaviorUpdateOutcome.IN_PROGRESS);
    };
    if AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetPuppetReactionBlackboard().GetBool(GetAllBlackboardDefs().PuppetReaction.exitReactionFlag) {
      AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetPuppetReactionBlackboard().SetBool(GetAllBlackboardDefs().PuppetReaction.exitReactionFlag, false);
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.SendBehaviorStatus(ScriptExecutionContext.GetOwner(context), AIbehaviorUpdateOutcome.SUCCESS);
    this.m_reactionData = null;
  }

  protected final func UpdateArguments(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", this.m_reactionData.stimTarget);
    ScriptExecutionContext.SetArgumentVector(context, n"StimSource", this.m_reactionData.stimSource);
  }

  protected final func SendBehaviorStatus(owner: ref<GameObject>, status: AIbehaviorUpdateOutcome) -> Void {
    let behaviorStatus: ref<ReactionBehaviorStatus> = new ReactionBehaviorStatus();
    behaviorStatus.status = status;
    behaviorStatus.reactionData = this.m_reactionData;
    owner.QueueEvent(behaviorStatus);
  }
}

public class UpdateStimSource extends ReactionManagerTask {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.m_reactionData = null;
  }
}

public class SetDesiredReaction extends AIbehaviortaskScript {

  public edit let m_behaviorArgumentNameTag: CName;

  public edit let m_behaviorArgumentFloatPriority: CName;

  public edit let m_behaviorArgumentNameFlag: CName;

  protected let m_reactionData: ref<AIReactionData>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_reactionData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionData();
    if IsDefined(this.m_reactionData) {
      ScriptExecutionContext.SetArgumentName(context, this.m_behaviorArgumentNameTag, EnumValueToName(n"gamedataOutput", Cast(EnumInt(this.m_reactionData.reactionBehaviorName))));
      ScriptExecutionContext.SetArgumentFloat(context, this.m_behaviorArgumentFloatPriority, this.m_reactionData.reactionBehaviorAIPriority);
      ScriptExecutionContext.SetArgumentName(context, this.m_behaviorArgumentNameFlag, n"AIGSF_InterruptsSamePriorityTask");
    };
  }
}

public class SetControllerStimSource extends AIbehaviortaskScript {

  protected let m_investigateData: stimInvestigateData;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_investigateData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData().stimInvestigateData;
    ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", this.m_investigateData.controllerEntity as GameObject);
    ScriptExecutionContext.SetArgumentVector(context, n"StimSource", this.m_investigateData.controllerEntity.GetWorldPosition());
  }
}

public class SetDeviceInvestigationData extends AIbehaviortaskScript {

  public let ownerPuppet: wref<ScriptedPuppet>;

  public let listener: wref<GameObject>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let investigateData: stimInvestigateData;
    this.ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let communicationEvent: ref<CommunicationEvent> = new CommunicationEvent();
    communicationEvent.name = n"ResetInvestigators";
    communicationEvent.sender = ScriptExecutionContext.GetOwner(context).GetEntityID();
    let activeReactionData: ref<AIReactionData> = this.ownerPuppet.GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(activeReactionData) {
      activeReactionData = this.ownerPuppet.GetStimReactionComponent().GetDesiredReactionData();
    };
    investigateData = activeReactionData.stimInvestigateData;
    if IsDefined(investigateData.mainDeviceEntity) {
      ScriptExecutionContext.SetArgumentObject(context, n"TargetDevice", investigateData.mainDeviceEntity as GameObject);
      this.listener = investigateData.mainDeviceEntity as GameObject;
      this.SetInvestigationStateOnListener(this.listener, true);
      this.listener.QueueEvent(communicationEvent);
    };
    this.listener = activeReactionData.stimTarget;
    this.SetInvestigationStateOnListener(this.listener, true);
    this.listener.QueueEvent(communicationEvent);
    this.ForceVisionAppearance(this.ownerPuppet, this.GetDistractionHighlightData(this.ownerPuppet));
    ScriptExecutionContext.SetArgumentVector(context, n"CustomWorldPosition", investigateData.distrationPoint);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let communicationEvent: ref<CommunicationEvent> = new CommunicationEvent();
    communicationEvent.name = n"TaskDeactivated";
    communicationEvent.sender = ScriptExecutionContext.GetOwner(context).GetEntityID();
    this.listener.QueueEvent(communicationEvent);
    this.ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    this.listener = ScriptExecutionContext.GetArgumentObject(context, n"TargetDevice");
    if IsDefined(this.listener) {
      this.SetInvestigationStateOnListener(this.listener, false);
    };
    this.listener = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    this.SetInvestigationStateOnListener(this.listener, false);
    this.CancelForcedVisionAppearance(this.ownerPuppet, this.GetDistractionHighlightData(this.ownerPuppet));
  }

  private final func SetInvestigationStateOnListener(listenerArg: wref<GameObject>, isInvestigated: Bool) -> Void {
    let device: ref<Device> = listenerArg as Device;
    if device != null {
      device.GetBlackboard().SetBool(device.GetBlackboardDef().IsInvestigated, isInvestigated);
    };
  }

  private final func GetDistractionHighlightData(owner: ref<ScriptedPuppet>) -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlight.sourceID = owner.GetEntityID();
    highlight.sourceName = this.GetClassName();
    highlight.highlightType = EFocusForcedHighlightType.INVALID;
    highlight.outlineType = EFocusOutlineType.DISTRACTION;
    highlight.priority = EPriority.High;
    highlight.isRevealed = true;
    return highlight;
  }

  private final func ForceVisionAppearance(owner: ref<ScriptedPuppet>, data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent>;
    if !IsDefined(owner) {
      return;
    };
    evt = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = true;
    GameInstance.GetPersistencySystem(owner.GetGame()).QueueEntityEvent(owner.GetEntityID(), evt);
  }

  private final func CancelForcedVisionAppearance(owner: ref<ScriptedPuppet>, data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent>;
    if !IsDefined(owner) {
      return;
    };
    evt = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = false;
    GameInstance.GetPersistencySystem(owner.GetGame()).QueueEntityEvent(owner.GetEntityID(), evt);
  }
}

public class SetDeviceControllerInvestigationData extends AIbehaviortaskScript {

  public let ownerPuppet: wref<ScriptedPuppet>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let closestDistance: Float;
    let distance: Float;
    let path: ref<NavigationPath>;
    let position: Vector4;
    this.ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let activeReactionData: ref<AIReactionData> = this.ownerPuppet.GetStimReactionComponent().GetActiveReactionData();
    let investigateData: stimInvestigateData = activeReactionData.stimInvestigateData;
    let controller: ref<Device> = investigateData.controllerEntity as Device;
    let investigationPositions: array<Vector4> = controller.GetNodePosition();
    let i: Int32 = 0;
    while i < ArraySize(investigationPositions) {
      distance = Vector4.Distance(investigationPositions[i], this.ownerPuppet.GetWorldPosition());
      path = GameInstance.GetAINavigationSystem(this.ownerPuppet.GetGame()).CalculatePathForCharacter(this.ownerPuppet.GetWorldPosition(), investigationPositions[i], 0.00, this.ownerPuppet);
      if !IsDefined(path) {
      } else {
        if distance < closestDistance || closestDistance == 0.00 {
          closestDistance = distance;
          position = investigationPositions[i];
        };
      };
      i += 1;
    };
    if !Vector4.IsZero(position) {
      ScriptExecutionContext.SetArgumentVector(context, n"StimSource", position);
    } else {
      ScriptExecutionContext.SetArgumentVector(context, n"StimSource", controller.GetWorldPosition());
    };
    ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", controller);
    ScriptExecutionContext.SetArgumentVector(context, n"CustomWorldPosition", controller.GetDistractionPointPosition(controller));
  }
}

public class TriggerCombatAgainstStimTarget extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let investigateData: stimInvestigateData;
    let mountInfo: MountingInfo;
    let stimTarget: wref<GameObject>;
    let target: wref<GameObject>;
    let targetPuppet: wref<ScriptedPuppet>;
    let activeReactionData: ref<AIReactionData> = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData();
    if IsDefined(activeReactionData) {
      investigateData = activeReactionData.stimInvestigateData;
    };
    stimTarget = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    if IsDefined(investigateData.attackInstigator) {
      target = investigateData.attackInstigator as GameObject;
    } else {
      target = stimTarget;
    };
    if !IsDefined(target) {
      return;
    };
    targetPuppet = target as ScriptedPuppet;
    if IsDefined(targetPuppet) && ScriptedPuppet.IsPlayerCompanion(targetPuppet) {
      return;
    };
    if GameObject.IsVehicle(target) {
      mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(target);
      target = GameInstance.FindEntityByID(ScriptExecutionContext.GetOwner(context).GetGame(), mountInfo.childId) as GameObject;
    };
    if !AIActionHelper.TryChangingAttitudeToHostile(AIBehaviorScriptBase.GetPuppet(context), target) {
      return;
    };
    TargetTrackingExtension.InjectThreat(AIBehaviorScriptBase.GetPuppet(context), target);
  }
}

public class TriggerCombatReaction extends AIbehaviortaskScript {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let triggerAIEvent: ref<AIEvent>;
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if ownerPuppet.GetStimReactionComponent().GetInPendingBehavior() {
      triggerAIEvent = new AIEvent();
      triggerAIEvent.name = n"TriggerCombatReaction";
      ownerPuppet.QueueEvent(triggerAIEvent);
    };
  }
}

public class GenerateHeatAroundLastTriggeredStimuli extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let stimuliCache: array<ref<StimuliEvent>> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetStimReactionComponent().GetStimuliCache();
    let stimSourcePos: Vector4 = stimuliCache[ArraySize(stimuliCache) - 1].sourcePosition;
    GameInstance.GetInfluenceMapSystem(ScriptExecutionContext.GetOwner(context).GetGame()).SetSearchValueLerp(stimSourcePos, 2.00, 0.40, 0.60);
  }
}

public class SetTrafficLaneMovementParams extends AIbehaviortaskScript {

  public edit let m_movementType: String;

  @default(SetTrafficLaneMovementParams, gameFearStage.Relaxed)
  public edit let m_fearStage: gameFearStage;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let crowdMemberComponent: ref<CrowdMemberComponent> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetCrowdMemberComponent();
    ScriptExecutionContext.SetArgumentVector(context, n"CustomWorldPosition", ScriptExecutionContext.GetArgumentVector(context, n"PathDirection"));
    ScriptExecutionContext.SetArgumentVector(context, n"MovementDestination", ScriptExecutionContext.GetArgumentVector(context, n"ClosestPositionOnPath"));
    if StrLen(this.m_movementType) > 0 {
      crowdMemberComponent.ChangeMoveType(StringToName(this.m_movementType));
    };
    switch this.m_fearStage {
      case gameFearStage.Stressed:
        crowdMemberComponent.ChangeFearStage(this.m_fearStage);
        break;
      case gameFearStage.Panic:
        crowdMemberComponent.ChangeFearStage(this.m_fearStage);
        break;
      case gameFearStage.Alarmed:
        crowdMemberComponent.ChangeFearStage(this.m_fearStage);
        break;
      case gameFearStage.Relaxed:
        crowdMemberComponent.ChangeFearStage(this.m_fearStage);
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let crowdMemberComponent: ref<CrowdMemberComponent> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetCrowdMemberComponent();
    crowdMemberComponent.TryStopTrafficMovement();
  }
}

public class SetAvoidThreatDestination extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let movePoliciesComponent: ref<MovePoliciesComponent> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetMovePolicesComponent();
    if IsDefined(movePoliciesComponent) {
      ScriptExecutionContext.SetArgumentVector(context, n"MovementDestination", movePoliciesComponent.GetDestination());
    };
  }
}

public class AddActiveStimuli extends AIbehaviortaskScript {

  public edit let stimType: gamedataStimType;

  public edit let lifetime: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if IsDefined(owner) {
      owner.GetStimBroadcasterComponent().AddActiveStimuli(owner, this.stimType, this.lifetime);
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if IsDefined(owner) && this.lifetime < 0.00 {
      owner.GetStimBroadcasterComponent().RemoveActiveStimuliByName(owner, this.stimType);
    };
  }
}

public class UnregisterCommunityRunner extends AIbehaviortaskScript {

  public edit let m_onDeactivation: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && !this.m_onDeactivation {
      reactionSystem.UnregisterCommunityRunner(ScriptExecutionContext.GetOwner(context));
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && this.m_onDeactivation {
      reactionSystem.UnregisterCommunityRunner(ScriptExecutionContext.GetOwner(context));
    };
  }
}

public class UnregisterTrafficRunner extends AIbehaviortaskScript {

  public edit let m_onDeactivation: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && !this.m_onDeactivation {
      reactionSystem.UnregisterTrafficRunner(ScriptExecutionContext.GetOwner(context));
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && this.m_onDeactivation {
      reactionSystem.UnregisterTrafficRunner(ScriptExecutionContext.GetOwner(context));
    };
  }
}

public class SetExplosionInstigatorPositionAsStimSource extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let investigateData: stimInvestigateData;
    let stimuliCache: array<ref<StimuliEvent>> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetStimReactionComponent().GetStimuliCache();
    if ArraySize(stimuliCache) != 0 {
      investigateData = stimuliCache[ArraySize(stimuliCache) - 1].stimInvestigateData;
      if Equals(stimuliCache[ArraySize(stimuliCache) - 1].GetStimType(), gamedataStimType.Explosion) && investigateData.revealsInstigatorPosition {
        ScriptExecutionContext.SetArgumentVector(context, n"StimSource", investigateData.attackInstigatorPosition);
      };
    };
  }
}

public class InjectAttackInstigatorAsThreat extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let attackInstigatorPuppet: ref<ScriptedPuppet>;
    let investigateData: stimInvestigateData;
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let stimuliCache: array<ref<StimuliEvent>> = ownerPuppet.GetStimReactionComponent().GetStimuliCache();
    if ArraySize(stimuliCache) != 0 {
      investigateData = stimuliCache[ArraySize(stimuliCache) - 1].stimInvestigateData;
      if Equals(stimuliCache[ArraySize(stimuliCache) - 1].GetStimType(), gamedataStimType.Explosion) && investigateData.revealsInstigatorPosition {
        attackInstigatorPuppet = investigateData.attackInstigator as ScriptedPuppet;
        if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, attackInstigatorPuppet) {
          TargetTrackingExtension.InjectThreat(ownerPuppet, attackInstigatorPuppet);
        };
      };
    };
  }
}

public class AdjustAnimWrappersForEscalatingFearPhase extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"panic", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"fear", 1.00);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"panic", 1.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"fear", 0.00);
  }
}

public class AdjustAnimWrappersForDeescalatingFearPhase extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let reactionComponent: ref<ReactionManagerComponent> = ownerPuppet.GetStimReactionComponent();
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"disturbed", 1.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"panic", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"fear", 0.00);
    if !reactionComponent.IsFearLocomotionWrapperSet() {
      AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), reactionComponent.GetRandomFearLocomotionAnimWrapper(1), 1.00);
    };
  }
}

public class AdjustAnimWrappersForEscalatingPanicPhase extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"disturbed", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"panic", 1.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"fear", 0.00);
  }
}

public class SetStressOnTrafficLane extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let stimTarget: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"disturbed", 1.00);
    ownerPuppet.GetCrowdMemberComponent().ChangeMoveType(n"stop");
    if IsDefined(ownerPuppet) && IsDefined(stimTarget) && ownerPuppet.GetStimReactionComponent().IsTargetInMovementDirection(stimTarget) {
      ownerPuppet.GetCrowdMemberComponent().TryChangeMovementDirection();
    };
    ownerPuppet.GetCrowdMemberComponent().ChangeMoveType(n"walk");
  }
}

public class SetPanicOnTrafficLane extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let stimTarget: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    let vehicle: ref<VehicleObject> = stimTarget as VehicleObject;
    if VehicleComponent.IsMountedToVehicle(ScriptExecutionContext.GetOwner(context).GetGame(), stimTarget) || IsDefined(vehicle) {
      GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"pedestrian_hit", n"Script:SetPanicOnTrafficLane/pedestrian");
    } else {
      GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"fear_run", n"Script:SetPanicOnTrafficLane");
    };
    if IsDefined(ownerPuppet) && IsDefined(stimTarget) && ownerPuppet.GetStimReactionComponent().IsTargetInMovementDirection(stimTarget) {
      ownerPuppet.GetCrowdMemberComponent().TryChangeMovementDirection();
    };
    ownerPuppet.GetCrowdMemberComponent().ChangeMoveType(n"run");
  }
}

public class TriggerFearRunningVO extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let stimTarget: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    let vehicle: ref<VehicleObject> = stimTarget as VehicleObject;
    if VehicleComponent.IsMountedToVehicle(ScriptExecutionContext.GetOwner(context).GetGame(), stimTarget) || IsDefined(vehicle) {
      GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"pedestrian_hit", n"Script:TriggerFearRunningVO/pedestrian");
    } else {
      GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"fear_run", n"Script:TriggerFearRunningVO");
    };
  }
}

public class ResetAllFearWrappers extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"disturbed", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"fear", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"panic", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"FearLocomotion1", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"FearLocomotion2", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"FearLocomotion3", 0.00);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(ScriptExecutionContext.GetOwner(context), n"FearLocomotion4", 0.00);
  }
}

public class ReprimandEscalation extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    let reprimandEscalationEvent: ref<ReprimandEscalationEvent> = new ReprimandEscalationEvent();
    if !statPoolsSystem.IsStatPoolAdded(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.ReprimandEscalation) {
      reprimandEscalationEvent.startReprimand = true;
    };
    ScriptExecutionContext.GetOwner(context).QueueEvent(reprimandEscalationEvent);
  }
}

public class ReprimandDeescalation extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let reprimandEscalationEvent: ref<ReprimandEscalationEvent> = new ReprimandEscalationEvent();
    reprimandEscalationEvent.startDeescalate = true;
    ScriptExecutionContext.GetOwner(context).QueueEvent(reprimandEscalationEvent);
  }
}

public class ResetReprimandEscalation extends AIbehaviortaskScript {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let m_AnimFeature_Reprimand: ref<AnimFeature_Reprimand>;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    statPoolsSystem.RequestRemovingStatPool(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.ReprimandEscalation);
    m_AnimFeature_Reprimand = new AnimFeature_Reprimand();
    m_AnimFeature_Reprimand.isActive = false;
    m_AnimFeature_Reprimand.state = 0;
    m_AnimFeature_Reprimand.isLocomotion = false;
    m_AnimFeature_Reprimand.weaponType = GetItemTypeFromContext(context);
    AnimationControllerComponent.ApplyFeature(ScriptExecutionContext.GetOwner(context), n"ReprimandAnim", m_AnimFeature_Reprimand, 5.00);
  }
}

public static func GetItemTypeFromContext(context: ScriptExecutionContext) -> Int32 {
  let itemEnumNumber: Int32;
  let itemObject: ref<ItemObject>;
  let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
  let itemsToEquip: array<NPCItemToEquip> = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip));
  let itemRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemsToEquip[0].itemID));
  if !IsDefined(itemRecord) {
    itemObject = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponRight");
    if IsDefined(itemObject) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemObject.GetItemID()));
    };
  };
  itemEnumNumber = itemRecord.ItemType().AnimFeatureIndex();
  switch itemRecord.ItemType().Type() {
    case gamedataItemType.Wea_LightMachineGun:
      itemEnumNumber = 2;
      break;
    case gamedataItemType.Wea_HeavyMachineGun:
      itemEnumNumber = 2;
      break;
    case gamedataItemType.Wea_SubmachineGun:
      itemEnumNumber = 3;
      break;
    case gamedataItemType.Wea_Rifle:
      itemEnumNumber = 4;
      break;
    case gamedataItemType.Wea_PrecisionRifle:
      itemEnumNumber = 4;
      break;
    case gamedataItemType.Wea_SniperRifle:
      itemEnumNumber = 4;
      break;
    case gamedataItemType.Wea_AssaultRifle:
      itemEnumNumber = 4;
      break;
    case gamedataItemType.Wea_Shotgun:
      itemEnumNumber = 4;
      break;
    case gamedataItemType.Wea_ShotgunDual:
      itemEnumNumber = 4;
      break;
    case gamedataItemType.Wea_Handgun:
      itemEnumNumber = 6;
      break;
    case gamedataItemType.Wea_Revolver:
      itemEnumNumber = 6;
      break;
    case gamedataItemType.Wea_Katana:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_Knife:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_LongBlade:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_Melee:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_OneHandedClub:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_ShortBlade:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_Hammer:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_Fists:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Wea_TwoHandedClub:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Cyb_MantisBlades:
      itemEnumNumber = 5;
      break;
    case gamedataItemType.Cyb_StrongArms:
      itemEnumNumber = 5;
      break;
    default:
      itemEnumNumber = 7;
  };
  return itemEnumNumber;
}

public class ReprimandStartAnimFeature extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let m_AnimFeature_Reprimand: ref<AnimFeature_Reprimand> = new AnimFeature_Reprimand();
    m_AnimFeature_Reprimand.isActive = true;
    m_AnimFeature_Reprimand.state = 2;
    m_AnimFeature_Reprimand.isLocomotion = false;
    m_AnimFeature_Reprimand.weaponType = GetItemTypeFromContext(context);
    AnimationControllerComponent.ApplyFeature(ScriptExecutionContext.GetOwner(context), n"ReprimandAnim", m_AnimFeature_Reprimand);
  }
}

public class ReprimandResetAnimFeature extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let m_AnimFeature_Reprimand: ref<AnimFeature_Reprimand> = new AnimFeature_Reprimand();
    m_AnimFeature_Reprimand.isActive = false;
    m_AnimFeature_Reprimand.state = 0;
    m_AnimFeature_Reprimand.isLocomotion = false;
    m_AnimFeature_Reprimand.weaponType = GetItemTypeFromContext(context);
    AnimationControllerComponent.ApplyFeature(ScriptExecutionContext.GetOwner(context), n"ReprimandAnim", m_AnimFeature_Reprimand, 5.00);
  }
}

public class ReprimandEscalateAnimFeature extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let m_AnimFeature_Reprimand: ref<AnimFeature_Reprimand> = new AnimFeature_Reprimand();
    m_AnimFeature_Reprimand.isActive = true;
    m_AnimFeature_Reprimand.state = 3;
    m_AnimFeature_Reprimand.isLocomotion = false;
    m_AnimFeature_Reprimand.weaponType = GetItemTypeFromContext(context);
    AnimationControllerComponent.ApplyFeature(ScriptExecutionContext.GetOwner(context), n"ReprimandAnim", m_AnimFeature_Reprimand);
  }
}

public class ReprimandDeescalateAnimFeature extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let m_AnimFeature_Reprimand: ref<AnimFeature_Reprimand> = new AnimFeature_Reprimand();
    m_AnimFeature_Reprimand.isActive = true;
    m_AnimFeature_Reprimand.state = 1;
    m_AnimFeature_Reprimand.isLocomotion = false;
    m_AnimFeature_Reprimand.weaponType = GetItemTypeFromContext(context);
    AnimationControllerComponent.ApplyFeature(ScriptExecutionContext.GetOwner(context), n"ReprimandAnim", m_AnimFeature_Reprimand);
  }
}

public class ReprimandToAlertedAnimFeature extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let m_AnimFeature_Reprimand: ref<AnimFeature_Reprimand> = new AnimFeature_Reprimand();
    m_AnimFeature_Reprimand.isActive = false;
    m_AnimFeature_Reprimand.state = 0;
    m_AnimFeature_Reprimand.isLocomotion = false;
    m_AnimFeature_Reprimand.weaponType = GetItemTypeFromContext(context);
    AnimationControllerComponent.ApplyFeature(ScriptExecutionContext.GetOwner(context), n"ReprimandAnim", m_AnimFeature_Reprimand);
  }
}

public class ReprimandToCombatAnimFeature extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let m_AnimFeature_Reprimand: ref<AnimFeature_Reprimand> = new AnimFeature_Reprimand();
    m_AnimFeature_Reprimand.isActive = false;
    m_AnimFeature_Reprimand.state = 0;
    m_AnimFeature_Reprimand.isLocomotion = true;
    m_AnimFeature_Reprimand.weaponType = GetItemTypeFromContext(context);
    AnimationControllerComponent.ApplyFeature(ScriptExecutionContext.GetOwner(context), n"ReprimandAnim", m_AnimFeature_Reprimand);
  }
}

public class CallPolice extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    PreventionSystem.CrimeWitnessRequestToPreventionSystem(ScriptExecutionContext.GetOwner(context).GetGame(), GameInstance.GetPlayerSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetLocalPlayerMainGameObject().GetWorldPosition());
  }
}

public class IncrimentStimThreshold extends AIbehaviortaskScript {

  public edit let m_thresholdTimeout: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let thresholdEvent: ref<StimThresholdEvent> = new StimThresholdEvent();
    thresholdEvent.timeThreshold = this.m_thresholdTimeout;
    ScriptExecutionContext.GetOwner(context).QueueEvent(thresholdEvent);
  }
}

public class IncrimentStealthStimThreshold extends AIbehaviortaskScript {

  public edit let m_thresholdTimeout: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let thresholdEvent: ref<StealthStimThresholdEvent> = new StealthStimThresholdEvent();
    thresholdEvent.timeThreshold = this.m_thresholdTimeout;
    ScriptExecutionContext.GetOwner(context).QueueEvent(thresholdEvent);
  }
}

public class SetTimestampToBehaviorAgrument extends AIbehaviortaskScript {

  public edit let m_timestampArgument: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentFloat(context, this.m_timestampArgument, EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())));
  }
}

public class UnregisterReactionAction extends AIbehaviortaskScript {

  public edit let m_reactionName: CName;

  public edit let m_onDeactivation: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && !this.m_onDeactivation {
      reactionSystem.UnregisterReaction(this.m_reactionName);
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && this.m_onDeactivation {
      reactionSystem.UnregisterReaction(this.m_reactionName);
    };
  }
}

public class SetBackOffAnimFeature extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = 1;
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"BackOffReaction", animFeature);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = 0;
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"BackOffReaction", animFeature);
  }
}

public class SetBooleanArgumentWhenActive extends AIbehaviortaskScript {

  public edit let m_booleanArgument: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentBool(context, this.m_booleanArgument, true);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentBool(context, this.m_booleanArgument, false);
  }
}

public class BodyInvestigated extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ReactionManagerComponent.BodyInvestigated(AIBehaviorScriptBase.GetPuppet(context));
  }
}

public class TryStopMovingOnTrafficLane extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    ownerPuppet.GetCrowdMemberComponent().TryStopTrafficMovement();
  }
}
