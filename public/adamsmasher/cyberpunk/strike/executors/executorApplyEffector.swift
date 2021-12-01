
public class EffectExecutor_ApplyEffector extends EffectExecutor_Scripted {

  @attrib(customEditor, "TweakDBGroupInheritance;Effector")
  public edit let m_effector: TweakDBID;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let target: wref<GameObject> = EffectExecutionScriptContext.GetTarget(applierCtx) as GameObject;
    if !IsDefined(target) || !TDBID.IsValid(this.m_effector) {
      return false;
    };
    GameInstance.GetEffectorSystem(target.GetGame()).ApplyEffector(target.GetEntityID(), target, this.m_effector);
    return true;
  }
}
