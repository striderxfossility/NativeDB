
public class MuteArmDurationModifier extends EffectDurationModifier_Scripted {

  public edit let initialDuration: Float;

  public final func Init(ctx: EffectScriptContext) -> Float {
    return this.initialDuration;
  }

  public final func Process(ctx: EffectScriptContext, durationCtx: EffectDurationModifierScriptContext) -> Float {
    if EffectDurationModifierScriptContext.GetRemainingTime(durationCtx) - EffectDurationModifierScriptContext.GetTimeDelta(durationCtx) <= 0.00 {
      this.ResetMuteArmBlackboard(ctx);
    };
    return EffectDurationModifierScriptContext.GetRemainingTime(durationCtx) - EffectDurationModifierScriptContext.GetTimeDelta(durationCtx);
  }

  protected final func ResetMuteArmBlackboard(ctx: EffectScriptContext) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(EffectScriptContext.GetGameInstance(ctx));
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().CW_MuteArm);
    blackboard.SetBool(GetAllBlackboardDefs().CW_MuteArm.MuteArmActive, false, true);
    blackboard.SetFloat(GetAllBlackboardDefs().CW_MuteArm.MuteArmRadius, 0.00, true);
  }
}
