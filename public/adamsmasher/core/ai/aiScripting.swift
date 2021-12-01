
public abstract class AIBehaviorScript extends IScriptable {

  protected final func GetPuppet(context: ScriptExecutionContext) -> ref<ScriptedPuppet> {
    return ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
  }

  protected final func GetGame(context: ScriptExecutionContext) -> GameInstance {
    return ScriptExecutionContext.GetOwner(context).GetGame();
  }
}

public native class AIBehaviorScriptBase extends IScriptable {

  public final native func ToString() -> String;

  public func GetDescription(context: ScriptExecutionContext) -> String {
    return this.ToString();
  }

  public final static func GetPuppet(context: ScriptExecutionContext) -> ref<ScriptedPuppet> {
    return ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
  }

  public final static func GetNPCPuppet(context: ScriptExecutionContext) -> ref<NPCPuppet> {
    return ScriptExecutionContext.GetOwner(context) as NPCPuppet;
  }

  public final static func GetGame(context: ScriptExecutionContext) -> GameInstance {
    return ScriptExecutionContext.GetOwner(context).GetGame();
  }

  public final static func GetAITime(context: ScriptExecutionContext) -> Float {
    return EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context));
  }

  public final static func GetHitReactionComponent(context: ScriptExecutionContext) -> ref<HitReactionComponent> {
    return AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent();
  }

  public final static func GetAIComponent(context: ScriptExecutionContext) -> ref<AIHumanComponent> {
    return AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent();
  }

  public final static func GetStatPoolValue(context: ScriptExecutionContext, statPoolType: gamedataStatPoolType) -> Float {
    let ownerID: StatsObjectID = Cast(ScriptExecutionContext.GetOwner(context).GetEntityID());
    return GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetStatPoolValue(ownerID, statPoolType, false);
  }

  public final static func GetStatPoolPercentage(context: ScriptExecutionContext, statPoolType: gamedataStatPoolType) -> Float {
    let ownerID: StatsObjectID = Cast(ScriptExecutionContext.GetOwner(context).GetEntityID());
    return GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetStatPoolValue(ownerID, statPoolType, true);
  }

  public final static func GetCombatTarget(context: ScriptExecutionContext) -> ref<GameObject> {
    return ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
  }

  public final static func GetCompanion(context: ScriptExecutionContext) -> ref<GameObject> {
    return ScriptExecutionContext.GetArgumentObject(context, n"Companion");
  }

  public final static func GetUpperBodyState(context: ScriptExecutionContext) -> gamedataNPCUpperBodyState {
    return IntEnum(AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.UpperBody));
  }
}

public native class AIbehaviorconditionScript extends AIBehaviorScriptBase {

  protected func Activate(context: ScriptExecutionContext) -> Void;

  protected func Deactivate(context: ScriptExecutionContext) -> Void;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(false);
  }

  protected func CheckOnEvent(context: ScriptExecutionContext, behaviorEvent: ref<AIEvent>) -> AIbehaviorConditionOutcomes {
    return this.Check(context);
  }

  public final native func ListenToSignal(context: ScriptExecutionContext, signalName: CName) -> Uint16;

  public final native func StopListeningToSignal(context: ScriptExecutionContext, signalName: CName, callbackId: Uint16) -> Void;

  public final static native func SetUpdateInterval(context: ScriptExecutionContext, interval: Float) -> Bool;
}

public static func Cast(value: Bool) -> AIbehaviorConditionOutcomes {
  if value {
    return AIbehaviorConditionOutcomes.True;
  };
  return AIbehaviorConditionOutcomes.False;
}

public static func Cast(value: AIbehaviorConditionOutcomes) -> Bool {
  return Equals(value, AIbehaviorConditionOutcomes.True);
}

public native class AIbehaviortaskScript extends AIBehaviorScriptBase {

  protected func Activate(context: ScriptExecutionContext) -> Void;

  protected func Deactivate(context: ScriptExecutionContext) -> Void;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func ChildCompleted(context: ScriptExecutionContext, status: AIbehaviorCompletionStatus) -> Void;

  public final static native func CutSelector(context: ScriptExecutionContext) -> Void;

  public final static native func SetUpdateInterval(context: ScriptExecutionContext, interval: Float) -> Bool;
}

public native class AIbehaviorexpressionScript extends AIBehaviorScriptBase {

  public final native func MarkDirty(context: script_ref<ScriptExecutionContext>) -> Void;

  protected func OnBehaviorCallback(cbName: CName, context: ScriptExecutionContext) -> Bool {
    this.MarkDirty(context);
    return true;
  }
}
