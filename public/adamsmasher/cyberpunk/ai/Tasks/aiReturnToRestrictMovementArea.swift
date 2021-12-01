
public abstract class RestrictedMovementAreaCondition extends AIbehaviorconditionScript {

  protected final func GetRestrictMovementAreaManager(context: ScriptExecutionContext) -> ref<RestrictMovementAreaManager> {
    return GameInstance.GetRestrictMovementAreaManager(AIBehaviorScriptBase.GetGame(context));
  }

  protected final func IsOwnerConnectedToRestirctMovementArea(areaManager: ref<RestrictMovementAreaManager>, owner: ref<GameObject>) -> Bool {
    if !IsDefined(areaManager) {
      return false;
    };
    if !areaManager.HasAssignedRestrictMovementArea(owner.GetEntityID()) {
      return false;
    };
    return true;
  }

  protected final func IsOwnerInRestirctMovementArea(areaManager: ref<RestrictMovementAreaManager>, owner: ref<GameObject>) -> Bool {
    if !IsDefined(areaManager) || !IsDefined(owner) {
      return false;
    };
    return areaManager.IsPointInRestrictMovementArea(owner.GetEntityID(), owner.GetWorldPosition());
  }
}

public class AIReturnToRestrictMovementAreaCondition extends RestrictedMovementAreaCondition {

  private final func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let point: Vector4;
    let areaManager: ref<RestrictMovementAreaManager> = this.GetRestrictMovementAreaManager(context);
    if !IsDefined(areaManager) {
      return Cast(true);
    };
    if !this.IsOwnerConnectedToRestirctMovementArea(areaManager, ScriptExecutionContext.GetOwner(context)) {
      return Cast(false);
    };
    if areaManager.IsPointInRestrictMovementArea(ScriptExecutionContext.GetOwner(context).GetEntityID(), ScriptExecutionContext.GetOwner(context).GetWorldPosition()) {
      return Cast(false);
    };
    if areaManager.FindPointInRestrictMovementArea(AIBehaviorScriptBase.GetPuppet(context).GetEntityID(), AIBehaviorScriptBase.GetPuppet(context).GetWorldPosition(), point) {
      if !Vector4.IsZero(point) {
        ScriptExecutionContext.SetArgumentVector(context, n"MovementTarget", point);
        return Cast(true);
      };
    };
    return Cast(false);
  }
}

public class IsStimSourceInRestrictMovementArea extends RestrictedMovementAreaCondition {

  private final func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let stimSource: Vector4;
    let areaManager: ref<RestrictMovementAreaManager> = this.GetRestrictMovementAreaManager(context);
    if !IsDefined(areaManager) {
      return Cast(true);
    };
    if !this.IsOwnerConnectedToRestirctMovementArea(areaManager, ScriptExecutionContext.GetOwner(context)) {
      return Cast(true);
    };
    stimSource = ScriptExecutionContext.GetArgumentVector(context, n"StimSource");
    if areaManager.IsPointInRestrictMovementArea(ScriptExecutionContext.GetOwner(context).GetEntityID(), stimSource) {
      return Cast(true);
    };
    return Cast(false);
  }
}

public class AIReturnToRestrictMovementArea extends AIbehaviortaskScript {

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let point: Vector4;
    let gam: ref<RestrictMovementAreaManager> = GameInstance.GetRestrictMovementAreaManager(AIBehaviorScriptBase.GetGame(context));
    if !IsDefined(gam) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !gam.HasAssignedRestrictMovementArea(AIBehaviorScriptBase.GetPuppet(context).GetEntityID()) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if gam.FindPointInRestrictMovementArea(AIBehaviorScriptBase.GetPuppet(context).GetEntityID(), AIBehaviorScriptBase.GetPuppet(context).GetWorldPosition(), point) {
      if !Vector4.IsZero(point) {
        ScriptExecutionContext.SetArgumentVector(context, n"MovementTarget", point);
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}
