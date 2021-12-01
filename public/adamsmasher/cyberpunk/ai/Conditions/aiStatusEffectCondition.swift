
public class AIStatusEffectCondition extends AIbehaviorconditionScript {

  protected final func GetShootingBlackboard(context: ScriptExecutionContext) -> ref<IBlackboard> {
    return AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetShootingBlackboard();
  }
}

public class CheckCurrentStatusEffect extends AIStatusEffectCondition {

  public edit let m_statusEffectTypeToCompare: gamedataStatusEffectType;

  public edit let m_statusEffectTagToCompare: CName;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let gameplayTags: array<CName>;
    let topPriorityEffect: ref<StatusEffect> = StatusEffectHelper.GetTopPriorityEffect(AIBehaviorScriptBase.GetPuppet(context));
    if IsDefined(topPriorityEffect) && Equals(topPriorityEffect.GetRecord().StatusEffectType().Type(), this.m_statusEffectTypeToCompare) {
      if NotEquals(this.m_statusEffectTagToCompare, n"") {
        gameplayTags = topPriorityEffect.GetRecord().GameplayTags();
        return Cast(ArrayContains(gameplayTags, this.m_statusEffectTagToCompare));
      };
      return Cast(true);
    };
    return Cast(false);
  }
}

public class CheckStatusEffect extends AIStatusEffectCondition {

  @attrib(customEditor, "TweakDBGroupInheritance;StatusEffect")
  public edit let m_statusEffectID: TweakDBID;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), this.m_statusEffectID));
  }
}

public class CheckAllStatusEffect extends AIStatusEffectCondition {

  public edit let m_behaviorArgumentNameTag: CName;

  public edit let m_behaviorArgumentFloatPriority: CName;

  public edit let m_behaviorArgumentNameFlag: CName;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let topPriorityEffect: ref<StatusEffect> = StatusEffectHelper.GetTopPriorityEffect(ScriptExecutionContext.GetOwner(context));
    if IsDefined(topPriorityEffect) {
      if topPriorityEffect.GetRecord().AIData().Priority() > 0.00 {
        return Cast(true);
      };
      return Cast(false);
    };
    return Cast(false);
  }

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let topPriorityEffect: ref<StatusEffect> = StatusEffectHelper.GetTopPriorityEffect(ScriptExecutionContext.GetOwner(context));
    let flagName: CName = StringToName("AIGSF_" + EnumValueToString("gamedataStatusEffectAIBehaviorFlag", Cast(EnumInt(topPriorityEffect.GetRecord().AIData().BehaviorEventFlag().Type()))));
    ScriptExecutionContext.SetArgumentName(context, this.m_behaviorArgumentNameTag, EnumValueToName(n"gamedataStatusEffectType", Cast(EnumInt(topPriorityEffect.GetRecord().StatusEffectType().Type()))));
    ScriptExecutionContext.SetArgumentFloat(context, this.m_behaviorArgumentFloatPriority, topPriorityEffect.GetRecord().AIData().Priority());
    ScriptExecutionContext.SetArgumentName(context, this.m_behaviorArgumentNameFlag, flagName);
  }
}

public class CheckStatusEffectState extends AIStatusEffectCondition {

  public edit let m_statusEffectType: gamedataStatusEffectType;

  @default(CheckStatusEffectState, EstatusEffectsState.Activating)
  public edit let m_stateToCheck: EstatusEffectsState;

  public let topPrioStatusEffect: ref<StatusEffect>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    switch this.m_stateToCheck {
      case EstatusEffectsState.Deactivated:
        return Cast(!StatusEffectSystem.ObjectHasStatusEffectOfType(AIBehaviorScriptBase.GetPuppet(context), this.m_statusEffectType));
      case EstatusEffectsState.Activating:
        this.topPrioStatusEffect = StatusEffectHelper.GetTopPriorityEffect(AIBehaviorScriptBase.GetPuppet(context), this.m_statusEffectType);
        return Cast(!IsDefined(this.topPrioStatusEffect) || GameInstance.GetSimTime(AIBehaviorScriptBase.GetPuppet(context).GetGame()) - this.topPrioStatusEffect.GetInitialApplicationSimTimestamp() < 1.00);
      case EstatusEffectsState.Activated:
        return Cast(StatusEffectSystem.ObjectHasStatusEffectOfType(AIBehaviorScriptBase.GetPuppet(context), this.m_statusEffectType));
    };
  }
}

public class CheckWoundedStatusEffectState extends AIStatusEffectCondition {

  @default(CheckWoundedStatusEffectState, EstatusEffectsState.Activating)
  public edit let m_stateToCheck: EstatusEffectsState;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    switch this.m_stateToCheck {
      case EstatusEffectsState.Deactivated:
        return Cast(!StatusEffectSystem.ObjectHasStatusEffectOfType(AIBehaviorScriptBase.GetPuppet(context), gamedataStatusEffectType.Wounded));
      case EstatusEffectsState.Activating:
        return Cast(GameInstance.GetSimTime(AIBehaviorScriptBase.GetPuppet(context).GetGame()) - StatusEffectHelper.GetTopPriorityEffect(AIBehaviorScriptBase.GetPuppet(context), gamedataStatusEffectType.Wounded).GetInitialApplicationSimTimestamp() < 10.00);
      case EstatusEffectsState.Activated:
        return Cast(StatusEffectSystem.ObjectHasStatusEffectOfType(AIBehaviorScriptBase.GetPuppet(context), gamedataStatusEffectType.Wounded));
    };
  }
}

public class CheckCurrentWoundedState extends AIStatusEffectCondition {

  public edit let m_woundedTypeToCompare: EWoundedBodyPart;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    switch this.m_woundedTypeToCompare {
      case EWoundedBodyPart.WoundedLeftArm:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.CrippledArmLeft") || StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.CrippledHandLeft"));
      case EWoundedBodyPart.WoundedRightArm:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.CrippledArmRight") || StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.CrippledHandRight"));
      case EWoundedBodyPart.WoundedLeftLeg:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.CrippledLegLeft"));
      case EWoundedBodyPart.WoundedRightLeg:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.CrippledLegRight"));
      case EWoundedBodyPart.DismemberedLeftArm:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedArmLeft") || StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedHandLeft"));
      case EWoundedBodyPart.DismemberedRightArm:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedArmRight") || StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedHandRight"));
      case EWoundedBodyPart.DismemberedLeftLeg:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedLegLeft"));
      case EWoundedBodyPart.DismemberedRightLeg:
        return Cast(StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedLegRight"));
      case EWoundedBodyPart.DismemberedBothLegs:
        return Cast(false);
      default:
        return Cast(false);
    };
  }
}
