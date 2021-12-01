
public class InitialiseNPC extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.StoreScriptExecutionContext(context);
  }

  protected final func StoreScriptExecutionContext(scriptExecutionContext: ScriptExecutionContext) -> Void {
    let context: ref<SetScriptExecutionContextEvent> = new SetScriptExecutionContextEvent();
    context.scriptExecutionContext = scriptExecutionContext;
    ScriptExecutionContext.GetOwner(scriptExecutionContext).QueueEvent(context);
  }
}

public class SelectorRevalutionBreak extends AIbehaviortaskScript {

  @default(SelectorRevalutionBreak, 0.1f)
  private const let m_reevaluationDuration: Float;

  private let m_activationTimeStamp: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_activationTimeStamp = AIBehaviorScriptBase.GetAITime(context);
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    if AIBehaviorScriptBase.GetAITime(context) < this.m_activationTimeStamp + this.m_reevaluationDuration {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public class SetTopThreatToCombatTarget extends AIbehaviortaskScript {

  @default(SetTopThreatToCombatTarget, 0.5)
  public let m_refreshTimer: Float;

  private let m_previousChecktime: Float;

  private let m_targetTrackerComponent: ref<TargetTrackingExtension>;

  private let m_movePoliciesComponent: ref<MovePoliciesComponent>;

  @default(SetTopThreatToCombatTarget, 0.0)
  private let m_targetChangeTime: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_targetTrackerComponent = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent() as TargetTrackingExtension;
    this.m_movePoliciesComponent = AIBehaviorScriptBase.GetPuppet(context).GetMovePolicesComponent();
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.SetCombatTarget(context, null);
    this.m_targetTrackerComponent = null;
    this.m_movePoliciesComponent = null;
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let cssi: ref<CombatSquadScriptInterface>;
    let newTargetObject: wref<GameObject>;
    let targetTrackerComp: ref<TargetTrackerComponent>;
    let time: Float;
    let topThreat: TrackedLocation;
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let currentUpperBodyState: gamedataNPCUpperBodyState = AIBehaviorScriptBase.GetPuppet(context).GetStatesComponent().GetCurrentUpperBodyState();
    if !this.IsCurrentTargetValid(context, currentUpperBodyState) || this.CanSwitchTarget(context, currentUpperBodyState) {
      time = AIBehaviorScriptBase.GetAITime(context);
      this.m_previousChecktime = time;
      if !this.GetCommandCombatTarget(context, newTargetObject) {
        if AIActionHelper.GetActiveTopHostilePuppetThreat(puppet, topThreat) {
          newTargetObject = topThreat.entity as ScriptedPuppet;
        } else {
          if (topThreat.entity as SurveillanceCamera) == null {
            newTargetObject = topThreat.entity as GameObject;
          };
        };
        if IsDefined(newTargetObject) && !this.IsTargetValid(context, newTargetObject) {
          targetTrackerComp = puppet.GetTargetTrackerComponent();
          targetTrackerComp.SetThreatBaseMul(newTargetObject, 0.00);
          targetTrackerComp.RemoveThreat(targetTrackerComp.MapThreat(newTargetObject));
          newTargetObject = null;
          ScriptExecutionContext.DebugLog(context, n"CombatTargetSelection", "NULL Target; NPC tried to choose autonomously non hostile or non active target");
        };
      };
      this.SetCombatTarget(context, newTargetObject);
      AISquadHelper.GetCombatSquadInterface(puppet, cssi);
      if IsDefined(cssi) {
        if IsDefined(newTargetObject) {
          cssi.SetAsEnemyAttacker(puppet, newTargetObject);
        } else {
          cssi.SetAsEnemyAttacker(puppet, null);
        };
      };
      AIActionTarget.UpdateThreatsValue(AIBehaviorScriptBase.GetNPCPuppet(context), newTargetObject, time - this.m_targetChangeTime);
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func CanSwitchTarget(context: ScriptExecutionContext, currentUpperBodyState: gamedataNPCUpperBodyState) -> Bool {
    if AIBehaviorScriptBase.GetAITime(context) < this.m_previousChecktime + this.m_refreshTimer {
      return false;
    };
    if Equals(currentUpperBodyState, gamedataNPCUpperBodyState.Shoot) && !AIBehaviorScriptBase.GetPuppet(context).IsBoss() {
      return true;
    };
    if Equals(currentUpperBodyState, gamedataNPCUpperBodyState.Normal) || Equals(currentUpperBodyState, gamedataNPCUpperBodyState.Reload) || Equals(currentUpperBodyState, gamedataNPCUpperBodyState.Equip) || Equals(currentUpperBodyState, gamedataNPCUpperBodyState.Aim) {
      return true;
    };
    return false;
  }

  private final func GetCommandCombatTarget(context: ScriptExecutionContext, out target: wref<GameObject>) -> Bool {
    target = ScriptExecutionContext.GetArgumentObject(context, n"CommandCombatTarget");
    if IsDefined(target) && target.IsPuppet() {
      if !ScriptedPuppet.IsActive(target) {
        AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent().SetThreatBaseMul(target, 0.00);
        target = null;
        ScriptExecutionContext.DebugLog(context, n"CombatTargetSelection", "NULL Target; CommandCombatTarget is Non-Active Target");
      } else {
        if Equals(GameObject.GetAttitudeBetween(ScriptExecutionContext.GetOwner(context), target), EAIAttitude.AIA_Friendly) {
          AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent().SetThreatBaseMul(target, 0.00);
          target = null;
          ScriptExecutionContext.DebugLog(context, n"CombatTargetSelection", "NULL Target; CommandCombatTarget is Friendly");
        };
      };
    };
    return target != null;
  }

  private final func SetCombatTarget(context: ScriptExecutionContext, target: ref<GameObject>) -> Void {
    if !AICombatTargetHelper.SetNewCombatTarget(context, target) {
      return;
    };
    if IsDefined(target) {
      GameObject.ChangeAttitudeToHostile(ScriptExecutionContext.GetOwner(context), target);
      this.m_targetChangeTime = AIBehaviorScriptBase.GetAITime(context);
    };
  }

  private final func IsCurrentTargetValid(context: ScriptExecutionContext, upperBodyState: gamedataNPCUpperBodyState) -> Bool {
    let target: wref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
    if IsDefined(target) && this.IsSwitchingTargetsBlocked(upperBodyState) {
      return true;
    };
    return this.IsTargetValid(context, target);
  }

  private final func IsSwitchingTargetsBlocked(upperBodyState: gamedataNPCUpperBodyState) -> Bool {
    if Equals(upperBodyState, gamedataNPCUpperBodyState.Attack) {
      return true;
    };
    return false;
  }

  private final func IsTargetValid(context: ScriptExecutionContext, target: wref<GameObject>) -> Bool {
    let isTargetPlayer: Bool;
    let puppetOwner: ref<ScriptedPuppet>;
    let threat: TrackedLocation;
    let owner: ref<gamePuppet> = ScriptExecutionContext.GetOwner(context);
    if !IsDefined(target) || !target.IsAttached() {
      return false;
    };
    isTargetPlayer = target.IsPlayer();
    if !isTargetPlayer && !ScriptedPuppet.IsActive(target) {
      return false;
    };
    if !this.m_targetTrackerComponent.ThreatFromEntity(target, threat) {
      return false;
    };
    if !this.IsTargetHostile(owner, target) {
      this.m_targetTrackerComponent.RemoveThreat(this.m_targetTrackerComponent.MapThreat(target));
      return false;
    };
    puppetOwner = AIBehaviorScriptBase.GetPuppet(context);
    if puppetOwner.IsPrevention() && isTargetPlayer && !PreventionSystem.ShouldReactionBeAgressive(owner.GetGame()) {
      AISquadHelper.RemoveThreatFromSquad(puppetOwner, threat);
      GameObject.ChangeAttitudeToNeutral(owner, target);
      return false;
    };
    return true;
  }

  private final func IsTargetHostile(owner: wref<GameObject>, target: wref<GameObject>) -> Bool {
    let attitudeOwner: ref<AttitudeAgent>;
    let attitudeTarget: ref<AttitudeAgent>;
    if !IsDefined(owner) || !IsDefined(target) {
      return false;
    };
    attitudeOwner = owner.GetAttitudeAgent();
    attitudeTarget = target.GetAttitudeAgent();
    if !IsDefined(attitudeOwner) || !IsDefined(attitudeTarget) {
      return false;
    };
    if NotEquals(attitudeOwner.GetAttitudeTowards(attitudeTarget), EAIAttitude.AIA_Hostile) {
      return false;
    };
    return true;
  }

  private final func IsTargetLost(context: ScriptExecutionContext, trackedLocation: TrackedLocation) -> Bool {
    let distanceSquared: Float;
    let vecToTarget: Vector4;
    if ScriptedPuppet.IsPlayerCompanion(AIBehaviorScriptBase.GetPuppet(context)) {
      return false;
    };
    if trackedLocation.visible || trackedLocation.sharedAccuracy >= 0.33 || !trackedLocation.invalidExpectation {
      return false;
    };
    if IsDefined(this.m_movePoliciesComponent) {
      if !this.m_movePoliciesComponent.IsTopPolicyEvaluated() {
        return false;
      };
      if this.m_movePoliciesComponent.IsPathfindingFailed() {
        ScriptExecutionContext.DebugLog(context, n"CombatTargetSelection", "TARGET LOST, reason: invalidExpectation + path finding failed");
        return true;
      };
      if this.m_movePoliciesComponent.IsConstrainedByRestrictedArea() {
        ScriptExecutionContext.DebugLog(context, n"CombatTargetSelection", "TARGET LOST, reason: invalidExpectation + movement constrained by restricted area");
        return true;
      };
    };
    vecToTarget = trackedLocation.sharedLocation.position - ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    distanceSquared = Vector4.LengthSquared(vecToTarget);
    if distanceSquared <= 4.00 {
      ScriptExecutionContext.DebugLog(context, n"CombatTargetSelection", "TARGET LOST, reason: distance to sharedBelief position is less than < 2 meters");
      return true;
    };
    return false;
  }
}

public class ClearCombatTarget extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AICombatTargetHelper.SetNewCombatTarget(context, null);
  }
}

public class StackClearCombatTarget extends AIbehaviortaskStackScript {

  protected final func OnActivate(context: ScriptExecutionContext) -> Void {
    AICombatTargetHelper.SetNewCombatTarget(context, null);
  }
}

public class TempClearForcedCombatTarget extends AIbehaviortaskScript {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AICombatTargetHelper.SetNewCombatTarget(context, null);
    AIActionHelper.ClearCommandCombatTarget(context, EnumInt(PersistenceSource.SetNewCombatTarget));
  }
}

public abstract class AICombatTargetHelper extends IScriptable {

  public final static func SetNewCombatTarget(context: ScriptExecutionContext, target: ref<GameObject>) -> Bool {
    let evt: ref<OnBeingTarget>;
    let prevTarget: ref<GameObject>;
    let tte: ref<TargetTrackingExtension>;
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if target == owner || IsDefined(target as SurveillanceCamera) {
      return false;
    };
    prevTarget = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
    if target == prevTarget {
      return false;
    };
    if IsDefined(target) && (target.IsPlayer() || ScriptedPuppet.IsPlayerCompanion(target)) {
      TargetTrackingExtension.InjectThreat(target as ScriptedPuppet, owner, 1.00);
      TargetTrackingExtension.SetThreatPersistence(target as ScriptedPuppet, owner, true, EnumInt(PersistenceSource.SetNewCombatTarget));
    };
    if IsDefined(prevTarget) {
      if prevTarget.IsPlayer() || ScriptedPuppet.IsPlayerCompanion(prevTarget) {
        tte = (prevTarget as ScriptedPuppet).GetTargetTrackerComponent() as TargetTrackingExtension;
        if IsDefined(tte) {
          if !tte.WasThreatPersistent(prevTarget) {
            TargetTrackingExtension.SetThreatPersistence(prevTarget as ScriptedPuppet, owner, false, EnumInt(PersistenceSource.SetNewCombatTarget));
          } else {
            LogAI("Threat Persistency of player/companion attacker not disabled from SetNewCombatTarget because it was previously set from quest");
          };
        };
      };
      if IsDefined(owner) {
        owner.GetSensesComponent().SetDetectionMultiplier(prevTarget.GetEntityID(), 1.00);
      };
      if prevTarget.IsPlayer() {
        evt = new OnBeingTarget();
        evt.objectThatTargets = ScriptExecutionContext.GetOwner(context);
        evt.noLongerTarget = true;
        prevTarget.QueueEvent(evt);
      };
    };
    ScriptExecutionContext.SetArgumentObject(context, n"CombatTarget", target);
    if IsDefined(target) {
      if target.IsPlayer() {
        evt = new OnBeingTarget();
        evt.objectThatTargets = owner;
        target.QueueEvent(evt);
        if PreventionSystem.ShouldPreventionSystemReactToCombat(owner) {
          PreventionSystem.CombatStartedRequestToPreventionSystem(owner.GetGame(), owner);
        };
      };
    };
    if IsDefined(owner) {
      owner.SetMainTrackedObject(target);
    };
    AIActionHelper.CombatQueriesInit(owner);
    AICombatTargetHelper.SetCombatTargetChangeSignal(context);
    return true;
  }

  public final static func SetCombatTargetChangeSignal(context: ScriptExecutionContext) -> Void {
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    ScriptedPuppet.SendActionSignal(puppet, n"CombatTargetChanged", 0.50);
  }
}

public class SetDroppedThreatLastKnowPosition extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let threatData: DroppedThreatData;
    let tte: ref<TargetTrackingExtension> = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent() as TargetTrackingExtension;
    if IsDefined(tte) && tte.GetDroppedThreat(ScriptExecutionContext.GetOwner(context).GetGame(), threatData) {
      ScriptExecutionContext.SetArgumentVector(context, n"StimSource", threatData.position);
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentVector(context, n"StimSource", new Vector4(0.00, 0.00, 0.00, 0.00));
  }
}

public class StopCallReinforcements extends AIbehaviortaskScript {

  protected let m_puppet: wref<ScriptedPuppet>;

  protected let m_pauseResumePhoneCallEvent: ref<PauseResumePhoneCallEvent>;

  @default(StopCallReinforcements, gamedataStatPoolType.CallReinforcementProgress)
  protected let m_statPoolType: gamedataStatPoolType;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_puppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    this.m_pauseResumePhoneCallEvent = new PauseResumePhoneCallEvent();
    this.m_pauseResumePhoneCallEvent.pauseCall = true;
    this.m_pauseResumePhoneCallEvent.statPoolType = this.m_statPoolType;
    this.m_puppet.QueueEvent(this.m_pauseResumePhoneCallEvent);
  }
}

public class UpdateDyingStimSource extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let investigateData: stimInvestigateData = AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetDesiredReactionData().stimInvestigateData;
    if IsDefined(investigateData.attackInstigator) {
      ScriptExecutionContext.SetArgumentVector(context, n"StimSource", investigateData.attackInstigatorPosition);
    };
  }
}

public class AddWeapon extends AIbehaviortaskScript {

  @default(AddWeapon, EquipmentPriority.All)
  public edit let m_weapon: EquipmentPriority;

  public final static func ExecuteForAllWeapons(puppet: ref<ScriptedPuppet>) -> Void {
    AddWeapon.Execute(puppet, EquipmentPriority.All);
  }

  private final static func Execute(puppet: ref<ScriptedPuppet>, weapon: EquipmentPriority) -> Void {
    let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(puppet.GetGame());
    let powerLevel: Int32 = Cast(statSys.GetStatValue(Cast(puppet.GetEntityID()), gamedataStatType.PowerLevel));
    if !puppet.HasEquipment(weapon) {
      puppet.AddRecordEquipment(weapon, powerLevel);
    };
  }

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AddWeapon.Execute(AIBehaviorScriptBase.GetPuppet(context), this.m_weapon);
  }
}
