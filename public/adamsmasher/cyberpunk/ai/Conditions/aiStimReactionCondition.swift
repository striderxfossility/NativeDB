
public class CheckReaction extends AIbehaviorconditionScript {

  public edit let m_reactionToCompare: gamedataOutput;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Equals(AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionName(), this.m_reactionToCompare));
  }
}

public class CheckReactionValueThreshold extends AIbehaviorconditionScript {

  public edit let m_reactionValue: EReactionValue;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let currentStat: Float;
    let threshold: Float;
    switch this.m_reactionValue {
      case EReactionValue.Fear:
        currentStat = AIBehaviorScriptBase.GetStatPoolValue(context, gamedataStatPoolType.Fear);
        threshold = TweakDBInterface.GetCharacterRecord(AIBehaviorScriptBase.GetPuppet(context).GetRecordID()).ReactionPreset().FearThreshold();
        break;
      default:
        return Cast(false);
    };
    if threshold == 0.00 {
      return Cast(false);
    };
    if currentStat >= threshold - 0.01 {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class InvestigateController extends AIbehaviorconditionScript {

  protected let m_investigateData: stimInvestigateData;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    this.m_investigateData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData().stimInvestigateData;
    return Cast(this.m_investigateData.investigateController);
  }
}

public class CheckReactionStimType extends AIbehaviorconditionScript {

  public edit let m_stimToCompare: gamedataStimType;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Equals(AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData().stimType, this.m_stimToCompare));
  }
}

public class CheckStimTag extends AIbehaviorconditionScript {

  public edit const let m_stimTagToCompare: array<CName>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let i: Int32;
    let tags: array<CName>;
    let activeReactionData: ref<AIReactionData> = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(activeReactionData) {
      activeReactionData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionData();
    };
    tags = activeReactionData.stimRecord.Tags();
    i = 0;
    while i < ArraySize(this.m_stimTagToCompare) {
      if ArrayContains(tags, this.m_stimTagToCompare[i]) {
        return Cast(true);
      };
      i += 1;
    };
    return Cast(false);
  }
}

public class PlayInitFearAnimation extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let ownerPuppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let activeReactionData: ref<AIReactionData> = ownerPuppet.GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(activeReactionData) {
      activeReactionData = ownerPuppet.GetStimReactionComponent().GetDesiredReactionData();
    };
    if activeReactionData.initAnimInWorkspot {
      return Cast(false);
    };
    if Equals(activeReactionData.stimType, gamedataStimType.GrenadeLanded) && RandRangeF(0.00, 1.00) < 0.75 {
      return Cast(false);
    };
    if Equals(activeReactionData.reactionBehaviorName, gamedataOutput.DodgeToSide) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class IsWorkspotReaction extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast((ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetStimReactionComponent().GetWorkSpotReactionFlag());
  }
}

public class IsValidCombatTarget extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let activeReactionData: ref<AIReactionData>;
    if AIBehaviorScriptBase.GetPuppet(context).IsPrevention() {
      return Cast(false);
    };
    activeReactionData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(activeReactionData) {
      activeReactionData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionData();
    };
    if Equals(activeReactionData.stimType, gamedataStimType.Dying) {
      return Cast(false);
    };
    if Equals(activeReactionData.stimType, gamedataStimType.CombatHit) {
      return Cast(false);
    };
    return Cast(true);
  }
}

public class IsPlayerAKiller extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let investigateData: stimInvestigateData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData().stimInvestigateData;
    let killer: ref<GameObject> = investigateData.attackInstigator as GameObject;
    if killer.IsPlayer() {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckStimRevealsInstigatorPosition extends AIbehaviorconditionScript {

  public edit let m_checkStimType: Bool;

  public edit let m_stimType: gamedataStimType;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let investigateData: stimInvestigateData;
    let stimuliCache: array<ref<StimuliEvent>> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetStimReactionComponent().GetStimuliCache();
    if ArraySize(stimuliCache) != 0 {
      investigateData = stimuliCache[ArraySize(stimuliCache) - 1].stimInvestigateData;
      if investigateData.revealsInstigatorPosition {
        if !this.m_checkStimType || Equals(stimuliCache[ArraySize(stimuliCache) - 1].GetStimType(), this.m_stimType) {
          return Cast(true);
        };
      };
    };
    return Cast(false);
  }
}

public class CheckLastTriggeredStimuli extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let stimSourcePos: Vector4;
    let stimuliCache: array<ref<StimuliEvent>> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetStimReactionComponent().GetStimuliCache();
    if ArraySize(stimuliCache) != 0 {
      stimSourcePos = stimuliCache[ArraySize(stimuliCache) - 1].sourcePosition;
      if !Vector4.IsZero(stimSourcePos) {
        ScriptExecutionContext.SetArgumentVector(context, n"StimSource", stimSourcePos);
        return Cast(true);
      };
    };
    return Cast(false);
  }
}

public class CheckAnimSetTags extends AIbehaviorconditionScript {

  public edit const let m_animsetTagToCompare: array<CName>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).HasRuntimeAnimsetTags(this.m_animsetTagToCompare) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class HasPositionFarFromThreat extends AIbehaviorconditionScript {

  public edit let desiredDistance: Float;

  public edit let minDistance: Float;

  public edit let minPathLength: Float;

  public edit let distanceFromTraffic: Float;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let currentPosition: Vector4;
    let destination: Vector4;
    let pathLength: Float;
    let pathResult: ref<NavigationPath>;
    let threatPosition: Vector4;
    let trafficIntersection: Vector4;
    let threat: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    if threat == null {
      return Cast(false);
    };
    currentPosition = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    threatPosition = threat.GetWorldPosition();
    if !GameInstance.GetNavigationSystem(AIBehaviorScriptBase.GetGame(context)).FindNavmeshPointAwayFromReferencePoint(currentPosition, threatPosition, this.desiredDistance, NavGenAgentSize.Human, destination, 5.00, 90.00) {
      return Cast(false);
    };
    if Vector4.LengthSquared(threatPosition - destination) < this.minDistance * this.minDistance {
      return Cast(false);
    };
    pathResult = GameInstance.GetAINavigationSystem(AIBehaviorScriptBase.GetGame(context)).CalculatePathForCharacter(currentPosition, destination, 1.00, ScriptExecutionContext.GetOwner(context));
    if IsDefined(pathResult) {
      pathLength = pathResult.CalculateLength();
    };
    if pathLength < this.minPathLength {
      return Cast(false);
    };
    if GameInstance.GetTrafficSystem(AIBehaviorScriptBase.GetGame(context)).IsPathIntersectingWithTraffic(pathResult.path, this.distanceFromTraffic, trafficIntersection) {
      destination = trafficIntersection;
      if Vector4.LengthSquared(destination - threatPosition) <= this.minDistance * this.minDistance {
        return Cast(false);
      };
      if Vector4.LengthSquared(destination - currentPosition) <= this.minPathLength * this.minPathLength {
        return Cast(false);
      };
    };
    ScriptExecutionContext.SetArgumentFloat(context, n"PathLength", pathLength);
    ScriptExecutionContext.SetArgumentVector(context, n"MovementDestination", destination);
    return Cast(true);
  }
}

public class CanNPCRun extends AIbehaviorconditionScript {

  public edit let m_maxRunners: Int32;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let reactionSystem: ref<ScriptedReactionSystem> = GameInstance.GetScriptableSystemsContainer(ScriptExecutionContext.GetOwner(context).GetGame()).Get(n"ScriptedReactionSystem") as ScriptedReactionSystem;
    let runners: Int32 = reactionSystem.GetFleeingNPCsCount();
    let reactionData: ref<AIReactionData> = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(reactionData) {
      reactionData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionData();
    };
    if runners >= this.m_maxRunners && NotEquals(reactionData.stimType, gamedataStimType.HijackVehicle) {
      if reactionSystem.GetRegisterTimeout() > EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) {
        runners = reactionSystem.GetFleeingNPCsCountInDistance(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), 10.00);
        if runners >= this.m_maxRunners {
          return Cast(false);
        };
      };
    };
    return Cast(true);
  }
}

public class ShouldNPCContinueInAlerted extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let timestamp: Float;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let reactionComponent: ref<ReactionManagerComponent> = puppet.GetStimReactionComponent();
    let NPCIgnoreList: array<EntityID> = reactionComponent.GetIgnoreList();
    if puppet.IsConnectedToSecuritySystem() {
      if reactionComponent.IsAlertedByDeadBody() {
        return Cast(true);
      };
      if puppet.GetSecuritySystem().IsReprimandOngoing() {
        return Cast(true);
      };
      if ArraySize(NPCIgnoreList) != 0 {
        return Cast(true);
      };
    };
    timestamp = ScriptExecutionContext.GetArgumentFloat(context, n"SearchingStarted");
    if timestamp + 15.00 > EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class IsInTrafficLane extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().IsInTrafficLane());
  }
}

public class PreviousFearPhaseCheck extends AIbehaviorconditionScript {

  public edit let m_fearPhase: Int32;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetPreviousFearPhase() == this.m_fearPhase);
  }
}

public class RegisterCommunityRunner extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && reactionSystem.RegisterCommunityRunner(ScriptExecutionContext.GetOwner(context)) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class RegisterTrafficRunner extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && reactionSystem.RegisterTrafficRunner(ScriptExecutionContext.GetOwner(context)) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class HearStimThreshold extends AIbehaviorconditionScript {

  public edit let m_thresholdNumber: Int32;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let curThresholdNumber: Int32;
    let stimTime: Float;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let reactionComponent: ref<ReactionManagerComponent> = puppet.GetStimReactionComponent();
    if !IsDefined(reactionComponent) {
      return Cast(false);
    };
    stimTime = reactionComponent.GetCurrentStimTimeStamp();
    curThresholdNumber = reactionComponent.GetCurrentStimThresholdValue();
    if stimTime >= EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) {
      if curThresholdNumber >= this.m_thresholdNumber {
        return Cast(true);
      };
    };
    return Cast(false);
  }
}

public class StealthStimThreshold extends AIbehaviorconditionScript {

  public edit let m_stealthThresholdNumber: Int32;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let curThresholdNumber: Int32;
    let stimTime: Float;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let reactionComponent: ref<ReactionManagerComponent> = puppet.GetStimReactionComponent();
    if !IsDefined(reactionComponent) {
      return Cast(false);
    };
    stimTime = reactionComponent.GetCurrentStealthStimTimeStamp();
    curThresholdNumber = reactionComponent.GetCurrentStealthStimThresholdValue();
    if stimTime >= EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) {
      if curThresholdNumber >= this.m_stealthThresholdNumber {
        return Cast(true);
      };
    };
    return Cast(false);
  }
}

public class CanDoReactionAction extends AIbehaviorconditionScript {

  public edit let m_reactionName: CName;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(reactionSystem) && Equals(reactionSystem.RegisterReaction(this.m_reactionName), AIReactionCountOutcome.Succeded) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckTimestamp extends AIbehaviorconditionScript {

  public edit let m_validationTime: Float;

  public edit let m_timestampArgument: CName;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let timestamp: Float = ScriptExecutionContext.GetArgumentFloat(context, this.m_timestampArgument);
    if timestamp + this.m_validationTime > EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class EscalateProvoke extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let reactionData: ref<AIReactionData> = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(reactionData) {
      reactionData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionData();
    };
    if IsDefined(reactionData) && reactionData.escalateProvoke {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckAttitudeAgainstStimTarget extends AIbehaviorconditionScript {

  public edit let m_attitude: EAIAttitude;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let mountInfo: MountingInfo;
    let target: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"StimTarget");
    if GameObject.IsVehicle(target) {
      mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(target);
      target = GameInstance.FindEntityByID(ScriptExecutionContext.GetOwner(context).GetGame(), mountInfo.childId) as GameObject;
    };
    if IsDefined(target) && Equals(GameObject.GetAttitudeBetween(ScriptExecutionContext.GetOwner(context), target), this.m_attitude) {
      return Cast(true);
    };
    return Cast(false);
  }
}
