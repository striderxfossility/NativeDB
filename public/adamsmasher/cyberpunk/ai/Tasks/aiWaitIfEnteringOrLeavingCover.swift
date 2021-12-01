
public class WaitIfEnteringOrLeavingCover extends AIbehaviortaskScript {

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let cm: ref<CoverManager> = GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame());
    if !IsDefined(cm) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if cm.IsEnteringOrLeavingCover(ScriptExecutionContext.GetOwner(context)) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}
