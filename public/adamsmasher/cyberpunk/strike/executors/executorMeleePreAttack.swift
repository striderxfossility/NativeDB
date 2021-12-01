
public class MeleePreAttackExecutor extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let aiEvent: ref<StimuliEvent>;
    let targetID: EntityID;
    let target: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    if IsDefined(target) {
      targetID = target.GetEntityID();
      aiEvent = new StimuliEvent();
      aiEvent.name = n"MeleeDodgeOpportunity";
      target.QueueEventForEntityID(targetID, aiEvent);
      return true;
    };
    return false;
  }
}
