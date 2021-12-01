
public class CheckLastHitReaction extends HitConditions {

  public edit let m_hitReactionToCheck: animHitReactionType;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let hitReactionBehaviorData: ref<HitReactionBehaviorData> = AIBehaviorScriptBase.GetHitReactionComponent(context).GetLastHitReactionBehaviorData();
    if !IsDefined(hitReactionBehaviorData) {
      return Cast(false);
    };
    if Equals(hitReactionBehaviorData.m_hitReactionType, this.m_hitReactionToCheck) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckCurrentHitReaction extends HitConditions {

  public edit let m_HitReactionTypeToCompare: animHitReactionType;

  public edit let m_CustomStimNameToCompare: CName;

  @default(CheckCurrentHitReaction, false)
  public edit let m_shouldCheckDeathStimName: Bool;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if !ScriptedPuppet.IsAlive(ScriptExecutionContext.GetOwner(context)) && this.m_shouldCheckDeathStimName {
      if Equals(this.m_CustomStimNameToCompare, n"") {
        return Cast(Equals((AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet).GetHitReactionComponent().GetDeathStimName(), EnumValueToName(n"animHitReactionType", Cast(EnumInt(this.m_HitReactionTypeToCompare)))));
      };
      return Cast(Equals((AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet).GetHitReactionComponent().GetDeathStimName(), this.m_CustomStimNameToCompare));
    };
    if Equals(this.m_CustomStimNameToCompare, n"") {
      return Cast(Equals((AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet).GetHitReactionComponent().GetLastStimName(), EnumValueToName(n"animHitReactionType", Cast(EnumInt(this.m_HitReactionTypeToCompare)))));
    };
    return Cast(Equals((AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet).GetHitReactionComponent().GetLastStimName(), this.m_CustomStimNameToCompare));
  }
}

public class CheckHitReactionStimID extends CheckStimID {

  protected func CheckOnEvent(context: ScriptExecutionContext, behaviorEvent: ref<AIEvent>) -> AIbehaviorConditionOutcomes {
    let se: ref<StimuliEvent> = behaviorEvent as StimuliEvent;
    if se.id == AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetLastStimID() {
      return Cast(true);
    };
    return Cast(false);
  }
}
