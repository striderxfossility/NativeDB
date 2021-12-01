
public abstract class AIActionHelperTask extends AIbehaviortaskScript {

  public inline edit let m_actionTweakIDMapping: ref<AIArgumentMapping>;

  private let m_actionStringName: String;

  private let m_initialized: Bool;

  private let m_actionName: CName;

  private let m_actionID: TweakDBID;

  private final func GetActionStringName(context: ScriptExecutionContext) -> String {
    let actionTweakID: String;
    if IsDefined(this.m_actionTweakIDMapping) {
      actionTweakID = NameToString(FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_actionTweakIDMapping)));
    };
    return actionTweakID;
  }

  private final func GetActionPackageType() -> AIactionParamsPackageTypes {
    return AIactionParamsPackageTypes.Default;
  }

  protected final func Initialize(context: ScriptExecutionContext) -> Void {
    let actionName: CName;
    if this.m_initialized {
      return;
    };
    this.m_actionID = AIActionParams.CreateActionID(context, AIBehaviorScriptBase.GetPuppet(context), this.GetActionStringName(context), this.GetActionPackageType(), actionName);
    this.m_initialized = true;
  }

  protected final func GetActionID() -> TweakDBID {
    return this.m_actionID;
  }
}

public class DestroyWeakspot extends AIActionHelperTask {

  public inline edit let m_weakspotIndex: Int32;

  public let m_weakspotComponent: ref<WeakspotComponent>;

  public let m_weakspotArray: array<wref<WeakspotObject>>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_weakspotComponent = (ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetWeakspotComponent();
    this.m_weakspotComponent.GetWeakspots(this.m_weakspotArray);
    this.DestroyWeakspot(context, this.m_weakspotArray, this.m_weakspotIndex);
  }

  protected final func DestroyWeakspot(context: ScriptExecutionContext, weakspots: array<wref<WeakspotObject>>, index: Int32) -> Void {
    GameInstance.GetStatPoolsSystem(AIBehaviorScriptBase.GetGame(context)).RequestChangingStatPoolValue(Cast(weakspots[index].GetEntityID()), gamedataStatPoolType.WeakspotHealth, 0.00, null, true);
  }
}

public class SetAppearance extends AIActionHelperTask {

  public inline edit let m_appearance: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.ApplyAppearance(context, this.m_appearance);
  }

  protected final func ApplyAppearance(context: ScriptExecutionContext, appearance: CName) -> Void {
    if !IsNameValid(appearance) {
      return;
    };
    ScriptExecutionContext.GetOwner(context).ScheduleAppearanceChange(this.m_appearance);
  }
}

public class MonitorMeleeCombo extends AIActionHelperTask {

  public edit let ExitComboBoolArgumentRef: CName;

  public edit let PreviousReactionIntArgumentRef: CName;

  public edit let CurrentAttackIntArgumentRef: CName;

  public edit let ComboCountIntArgumentRef: CName;

  public edit let ComboToIdleBoolArgumentRef: CName;

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentBool(context, this.ExitComboBoolArgumentRef, false);
    ScriptExecutionContext.SetArgumentInt(context, this.PreviousReactionIntArgumentRef, 0);
    ScriptExecutionContext.SetArgumentInt(context, this.CurrentAttackIntArgumentRef, 0);
    ScriptExecutionContext.SetArgumentInt(context, this.ComboCountIntArgumentRef, 0);
    ScriptExecutionContext.SetArgumentBool(context, this.ComboToIdleBoolArgumentRef, false);
  }
}

public class SetDestinationWaypoint extends AIActionHelperTask {

  public edit let m_refTargetType: EAITargetType;

  public inline edit let m_findClosest: Bool;

  public inline edit let m_waypointsName: CName;

  private let m_destinations: array<Vector4>;

  private let m_finalDestinations: array<Vector4>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    GameInstance.FindWaypointsByTag(ScriptExecutionContext.GetOwner(context).GetGame(), this.m_waypointsName, this.m_destinations);
    AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().SetBehaviorArgument(n"MovementTarget", ToVariant(this.GetFinalDestination(context)));
  }

  protected final func GetFinalDestination(context: ScriptExecutionContext) -> Vector4 {
    let randomInt: Int32;
    let value: Vector4;
    this.m_finalDestinations = this.m_destinations;
    let closestWPToOwner: Int32 = this.GetLowestDistanceIndex(this.GetDistances(ScriptExecutionContext.GetOwner(context).GetWorldPosition()));
    let closestWPToTarget: Int32 = this.GetLowestDistanceIndex(this.GetDistances(AIBehaviorScriptBase.GetCombatTarget(context).GetWorldPosition()));
    if !this.m_findClosest {
      if Equals(this.m_refTargetType, EAITargetType.AITT_Owner) {
        if closestWPToOwner == closestWPToTarget {
          ArrayErase(this.m_finalDestinations, this.GetLowestDistanceIndex(this.GetDistances(ScriptExecutionContext.GetOwner(context).GetWorldPosition())));
        } else {
          ArrayErase(this.m_finalDestinations, this.GetLowestDistanceIndex(this.GetDistances(ScriptExecutionContext.GetOwner(context).GetWorldPosition())));
          ArrayErase(this.m_destinations, this.GetLowestDistanceIndex(this.GetDistances(ScriptExecutionContext.GetOwner(context).GetWorldPosition())));
          ArrayErase(this.m_finalDestinations, this.GetLowestDistanceIndex(this.GetDistances(AIBehaviorScriptBase.GetCombatTarget(context).GetWorldPosition())));
        };
      } else {
        if Equals(this.m_refTargetType, EAITargetType.AITT_CombatTarget) {
          ArrayErase(this.m_finalDestinations, this.GetLowestDistanceIndex(this.GetDistances(AIBehaviorScriptBase.GetCombatTarget(context).GetWorldPosition())));
        };
      };
      randomInt = RandRange(0, ArraySize(this.m_finalDestinations));
      value = this.m_finalDestinations[randomInt];
    } else {
      if this.m_findClosest {
        if Equals(this.m_refTargetType, EAITargetType.AITT_Owner) {
          value = this.m_finalDestinations[this.GetLowestDistanceIndex(this.GetDistances(ScriptExecutionContext.GetOwner(context).GetWorldPosition()))];
        } else {
          if Equals(this.m_refTargetType, EAITargetType.AITT_CombatTarget) {
            value = this.m_finalDestinations[this.GetLowestDistanceIndex(this.GetDistances(AIBehaviorScriptBase.GetCombatTarget(context).GetWorldPosition()))];
          };
        };
      };
    };
    return value;
  }

  protected final func GetLowestDistanceIndex(distances: array<Float>) -> Int32 {
    let k: Int32;
    let lowestValue: Float;
    let j: Int32 = 0;
    while j < ArraySize(distances) {
      if distances[j] < lowestValue || lowestValue == 0.00 {
        lowestValue = distances[j];
        k = j;
      };
      j += 1;
    };
    return k;
  }

  protected final func GetDistances(refVector: Vector4) -> array<Float> {
    let distances: array<Float>;
    let i: Int32;
    ArrayClear(distances);
    ArrayResize(distances, ArraySize(this.m_destinations));
    i = 0;
    while i < ArraySize(this.m_destinations) {
      distances[i] = Vector4.Distance(refVector, this.m_destinations[i]);
      i += 1;
    };
    return distances;
  }
}

public class KillEntity extends AIActionHelperTask {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let forcedDeathEvent: ref<ForcedDeathEvent> = new ForcedDeathEvent();
    forcedDeathEvent.hitIntensity = 1;
    forcedDeathEvent.hitSource = 1;
    forcedDeathEvent.hitType = 7;
    forcedDeathEvent.hitBodyPart = 1;
    forcedDeathEvent.hitNpcMovementSpeed = 0;
    forcedDeathEvent.hitDirection = 4;
    forcedDeathEvent.hitNpcMovementDirection = 0;
    ScriptExecutionContext.GetOwner(context).QueueEvent(forcedDeathEvent);
  }
}

public class SetPhaseState extends AIActionHelperTask {

  public edit let m_phaseStateValue: ENPCPhaseState;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.GetOwner(context).GetBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.PhaseState, EnumInt(this.m_phaseStateValue));
  }
}

public class CheckPhaseState extends AIbehaviorconditionScript {

  public edit let m_phaseStateValue: ENPCPhaseState;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if ScriptExecutionContext.GetOwner(context).GetBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.PhaseState) == EnumInt(this.m_phaseStateValue) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckPathToCombatTarget extends AIbehaviorconditionScript {

  public let path: ref<NavigationPath>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    this.path = GameInstance.GetAINavigationSystem(AIBehaviorScriptBase.GetGame(context)).CalculatePathForCharacter(ScriptExecutionContext.GetOwner(context).GetWorldPosition(), AIBehaviorScriptBase.GetCombatTarget(context).GetWorldPosition(), 0.50, ScriptExecutionContext.GetOwner(context));
    if this.path != null {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckFloatIsValid extends AIbehaviorconditionScript {

  public inline edit let actionTweakIDMapping: ref<AIArgumentMapping>;

  public let value: Float;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if IsDefined(this.actionTweakIDMapping) {
      this.value = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.actionTweakIDMapping));
      if this.value <= 0.00 {
        return Cast(false);
      };
    };
    return Cast(true);
  }
}

public class CheckBoolisValid extends AIbehaviorconditionScript {

  public inline edit let actionTweakIDMapping: ref<AIArgumentMapping>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let value: Bool;
    if IsDefined(this.actionTweakIDMapping) {
      value = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.actionTweakIDMapping));
      if Equals(value, false) {
        return Cast(false);
      };
    };
    return Cast(true);
  }
}

public class CheckVectorIsValid extends AIbehaviorconditionScript {

  public inline edit let actionTweakIDMapping: ref<AIArgumentMapping>;

  public let value: Vector4;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if IsDefined(this.actionTweakIDMapping) {
      this.value = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.actionTweakIDMapping));
      if Vector4.IsZero(this.value) {
        return Cast(false);
      };
    };
    return Cast(true);
  }
}

public class CheckGameDifficulty extends AIbehaviorconditionScript {

  public edit let m_comparedDifficulty: gameDifficulty;

  public edit let m_comparisonOperator: EComparisonOperator;

  public let currentDifficulty: gameDifficulty;

  public let currentDifficultyValue: Int32;

  public let comparedDifficultyValue: Int32;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    this.currentDifficulty = GameInstance.GetStatsDataSystem(AIBehaviorScriptBase.GetGame(context)).GetDifficulty();
    this.currentDifficultyValue = this.GetDifficultyValue(this.currentDifficulty);
    this.comparedDifficultyValue = this.GetDifficultyValue(this.m_comparedDifficulty);
    if this.currentDifficultyValue > 0 && this.comparedDifficultyValue > 0 {
      switch this.m_comparisonOperator {
        case EComparisonOperator.Equal:
          if this.currentDifficultyValue == this.comparedDifficultyValue {
            return Cast(true);
          };
          break;
        case EComparisonOperator.NotEqual:
          if this.currentDifficultyValue != this.comparedDifficultyValue {
            return Cast(true);
          };
          break;
        case EComparisonOperator.More:
          if this.currentDifficultyValue > this.comparedDifficultyValue {
            return Cast(true);
          };
          break;
        case EComparisonOperator.MoreOrEqual:
          if this.currentDifficultyValue >= this.comparedDifficultyValue {
            return Cast(true);
          };
          break;
        case EComparisonOperator.Less:
          if this.currentDifficultyValue < this.comparedDifficultyValue {
            return Cast(true);
          };
          break;
        case EComparisonOperator.LessOrEqual:
          if this.currentDifficultyValue <= this.comparedDifficultyValue {
            return Cast(true);
          };
          break;
        default:
          return Cast(false);
      };
      return Cast(false);
    };
    return Cast(false);
  }

  private final func GetDifficultyValue(difficulty: gameDifficulty) -> Int32 {
    switch difficulty {
      case gameDifficulty.Story:
        return 1;
      case gameDifficulty.Easy:
        return 2;
      case gameDifficulty.Hard:
        return 3;
      case gameDifficulty.VeryHard:
        return 4;
      default:
        return 0;
    };
  }
}
