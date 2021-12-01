
public class GlobalDeathCondition extends AIDeathConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if IsDefined(AIBehaviorScriptBase.GetPuppet(context)) {
      if Equals(AIBehaviorScriptBase.GetPuppet(context).GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Dead) {
        return Cast(false);
      };
      return Cast(GameInstance.GetStatPoolsSystem(AIBehaviorScriptBase.GetGame(context)).HasStatPoolValueReachedMin(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.Health));
    };
    return Cast(false);
  }
}

public class PassiveGlobalDeathCondition extends AIbehaviorexpressionScript {

  protected let m_onDeathCbId: Uint32;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_onDeathCbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnDeath", this);
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_onDeathCbId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return ToVariant(false);
    };
    if Equals(puppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Dead) {
      return ToVariant(false);
    };
    return ToVariant(GameInstance.GetStatPoolsSystem(AIBehaviorScriptBase.GetGame(context)).HasStatPoolValueReachedMin(Cast(puppet.GetEntityID()), gamedataStatPoolType.Health));
  }
}

public class DeathWithoutRagdollCondition extends AIDeathConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if Equals(IntEnum(AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.Stance)), gamedataNPCStanceState.Vehicle) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class DeathWithoutAnimationCondition extends AIDeathConditions {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let npc: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    if IsDefined(npc) && npc.ShouldSkipDeathAnimation() {
      return Cast(true);
    };
    return Cast(false);
  }
}
