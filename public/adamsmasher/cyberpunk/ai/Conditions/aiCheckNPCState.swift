
public abstract class AINPCHighLevelStateCheck extends AINPCStateCheck {

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Relaxed;
  }

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Equals(this.GetStateToCheck(), IntEnum(AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel))));
  }
}

public class IsDead extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasStatPoolValueReachedMin(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.Health));
  }
}

public class IsRagdolling extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    return Cast(owner.IsRagdolling());
  }
}

public class CheckHighLevelState extends AINPCHighLevelStateCheck {

  public edit let m_state: gamedataNPCHighLevelState;

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return this.m_state;
  }
}

public class InRelaxedHighLevelState extends AINPCHighLevelStateCheck {

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Relaxed;
  }
}

public class InAlertedHighLevelState extends AINPCHighLevelStateCheck {

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Alerted;
  }
}

public class InCombatHighLevelState extends AINPCHighLevelStateCheck {

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Combat;
  }
}

public class InStealthHighLevelState extends AINPCHighLevelStateCheck {

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Stealth;
  }
}

public class InUnconsciousHighLevelState extends AINPCHighLevelStateCheck {

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Unconscious;
  }
}

public class InDeadHighLevelState extends AINPCHighLevelStateCheck {

  private func GetStateToCheck() -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Dead;
  }
}

public abstract class AINPCUpperBodyStateCheck extends AINPCStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Normal;
  }

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Equals(this.GetStateToCheck(), IntEnum(AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.UpperBody))));
  }
}

public class CheckUpperBodyState extends AINPCUpperBodyStateCheck {

  public edit let m_state: gamedataNPCUpperBodyState;

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return this.m_state;
  }
}

public class InNormalUpperBodyState extends AINPCUpperBodyStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Normal;
  }
}

public class InShootUpperBodyState extends AINPCUpperBodyStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Shoot;
  }
}

public class InReloadUpperBodyState extends AINPCUpperBodyStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Reload;
  }
}

public class InDefendUpperBodyState extends AINPCUpperBodyStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Defend;
  }
}

public class InAttackUpperBodyState extends AINPCUpperBodyStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Attack;
  }
}

public class InParryUpperBodyState extends AINPCUpperBodyStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Parry;
  }
}

public class InTauntUpperBodyState extends AINPCUpperBodyStateCheck {

  private func GetStateToCheck() -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Taunt;
  }
}

public abstract class AINPCStanceStateCheck extends AINPCStateCheck {

  private func GetStateToCheck() -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Stand;
  }

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(Equals(this.GetStateToCheck(), IntEnum(AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.Stance))));
  }
}

public class CheckStanceState extends AINPCStanceStateCheck {

  public edit let m_state: gamedataNPCStanceState;

  private func GetStateToCheck() -> gamedataNPCStanceState {
    return this.m_state;
  }
}

public class InStandStanceState extends AINPCStanceStateCheck {

  private func GetStateToCheck() -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Stand;
  }
}

public class InCrouchStanceState extends AINPCStanceStateCheck {

  private func GetStateToCheck() -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Crouch;
  }
}

public class InCoverStanceState extends AINPCStanceStateCheck {

  private func GetStateToCheck() -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Cover;
  }
}

public class InSwimStanceState extends AINPCStanceStateCheck {

  private func GetStateToCheck() -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Swim;
  }
}
