
public class EffectExecutor_SlashEffect extends EffectExecutor_Scripted {

  private edit const let m_entries: array<EffectExecutor_SlashEffect_Entry>;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let attackNumber: Int32;
    let i: Int32;
    let j: Int32;
    let puppet: ref<ScriptedPuppet>;
    EffectData.GetInt(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.attackNumber, attackNumber);
    puppet = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    if IsDefined(puppet) {
      i = 0;
      while i < ArraySize(this.m_entries) {
        if this.m_entries[i].m_attackNumber == attackNumber {
          j = 0;
          while j < ArraySize(this.m_entries[i].m_effectNames) {
            GameObjectEffectHelper.StartEffectEvent(EffectScriptContext.GetWeapon(ctx) as GameObject, this.m_entries[i].m_effectNames[j]);
            j += 1;
          };
        } else {
          i += 1;
        };
      };
    };
    return true;
  }
}
