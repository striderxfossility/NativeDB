
public abstract class ChangeHighLevelStateAbstract extends AIbehaviortaskScript {

  private func Activate(context: ScriptExecutionContext) -> Void {
    if Equals(this.GetDesiredHighLevelState(context), gamedataNPCHighLevelState.Invalid) {
      return;
    };
    NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), this.GetDesiredHighLevelState(context));
    this.OnActivate(context);
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void {
    this.OnDeactivate(context);
  }

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Relaxed;
  }

  private func OnActivate(context: ScriptExecutionContext) -> Void;

  private func OnDeactivate(context: ScriptExecutionContext) -> Void;
}

public class RelaxedState extends ChangeHighLevelStateAbstract {

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Relaxed;
  }
}

public class AlertedState extends ChangeHighLevelStateAbstract {

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Alerted;
  }
}

public class CombatState extends ChangeHighLevelStateAbstract {

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Combat;
  }
}

public class StealthState extends ChangeHighLevelStateAbstract {

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Stealth;
  }
}

public class UnconsciousState extends ChangeHighLevelStateAbstract {

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Unconscious;
  }
}

public class DeadState extends ChangeHighLevelStateAbstract {

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Dead;
  }
}

public class HighLevelStateMapping extends ChangeHighLevelStateAbstract {

  public inline edit let stateNameMapping: ref<AIArgumentMapping>;

  private func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    if IsDefined(this.stateNameMapping) {
      switch FromVariant(ScriptExecutionContext.GetMappingValue(context, this.stateNameMapping)) {
        case n"Relaxed":
          return gamedataNPCHighLevelState.Relaxed;
        case n"Alerted":
          return gamedataNPCHighLevelState.Alerted;
        case n"Combat":
          return gamedataNPCHighLevelState.Combat;
        case n"Unconscious":
          return gamedataNPCHighLevelState.Unconscious;
        case n"Dead":
          return gamedataNPCHighLevelState.Dead;
        default:
      };
    };
    return gamedataNPCHighLevelState.Invalid;
  }
}

public abstract class StackChangeHighLevelStateAbstract extends AIbehaviortaskStackScript {

  public final func OnActivate(context: ScriptExecutionContext) -> Void {
    let desiredState: gamedataNPCHighLevelState = this.GetDesiredHighLevelState(context);
    if Equals(desiredState, gamedataNPCHighLevelState.Invalid) {
      return;
    };
    NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), desiredState);
  }

  public func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Relaxed;
  }
}

public class StackRelaxedState extends StackChangeHighLevelStateAbstract {

  public func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Relaxed;
  }
}

public class StackAlertedState extends StackChangeHighLevelStateAbstract {

  public func GetDesiredHighLevelState(context: ScriptExecutionContext) -> gamedataNPCHighLevelState {
    return gamedataNPCHighLevelState.Alerted;
  }
}

public abstract class ChangeUpperBodyStateAbstract extends AIbehaviortaskScript {

  private func Activate(context: ScriptExecutionContext) -> Void {
    NPCPuppet.ChangeUpperBodyState(ScriptExecutionContext.GetOwner(context), this.GetDesiredUpperBodyState(context));
    this.OnActivate(context);
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void {
    this.OnDeactivate(context);
  }

  private func GetDesiredUpperBodyState(context: ScriptExecutionContext) -> gamedataNPCUpperBodyState {
    return gamedataNPCUpperBodyState.Normal;
  }

  private func OnActivate(context: ScriptExecutionContext) -> Void;

  private func OnDeactivate(context: ScriptExecutionContext) -> Void;
}

public class ChangeUpperBodyState extends ChangeUpperBodyStateAbstract {

  public edit let m_newState: gamedataNPCUpperBodyState;

  private func GetDesiredUpperBodyState(context: ScriptExecutionContext) -> gamedataNPCUpperBodyState {
    return this.m_newState;
  }
}

public abstract class ChangeStanceStateAbstract extends AIbehaviortaskScript {

  @default(ChangeStanceStateAbstract, false)
  public edit let changeStateOnDeactivate: Bool;

  private func Activate(context: ScriptExecutionContext) -> Void {
    if !this.changeStateOnDeactivate {
      NPCPuppet.ChangeStanceState(ScriptExecutionContext.GetOwner(context), this.GetDesiredStanceState(context));
    };
    this.OnActivate(context);
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void {
    if this.changeStateOnDeactivate {
      NPCPuppet.ChangeStanceState(ScriptExecutionContext.GetOwner(context), this.GetDesiredStanceState(context));
    };
    this.OnDeactivate(context);
  }

  private func GetDesiredStanceState(context: ScriptExecutionContext) -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Stand;
  }

  private func OnActivate(context: ScriptExecutionContext) -> Void;

  private func OnDeactivate(context: ScriptExecutionContext) -> Void;
}

public class ChangeStanceState extends ChangeStanceStateAbstract {

  public edit let m_newState: gamedataNPCStanceState;

  private func GetDesiredStanceState(context: ScriptExecutionContext) -> gamedataNPCStanceState {
    return this.m_newState;
  }
}

public class StandState extends ChangeStanceStateAbstract {

  private func GetDesiredStanceState(context: ScriptExecutionContext) -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Stand;
  }
}

public class VehicleState extends ChangeStanceStateAbstract {

  private func GetDesiredStanceState(context: ScriptExecutionContext) -> gamedataNPCStanceState {
    return gamedataNPCStanceState.Vehicle;
  }
}

public class VehicleWindowState extends ChangeStanceStateAbstract {

  private func GetDesiredStanceState(context: ScriptExecutionContext) -> gamedataNPCStanceState {
    return gamedataNPCStanceState.VehicleWindow;
  }
}
