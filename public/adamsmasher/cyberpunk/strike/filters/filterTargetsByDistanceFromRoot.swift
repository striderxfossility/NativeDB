
public class FilterTargetsByDistanceFromRoot extends EffectObjectSingleFilter_Scripted {

  @default(FilterTargetsByDistanceFromRoot, 1.0f)
  private edit let m_rootOffset_Z: Float;

  @default(FilterTargetsByDistanceFromRoot, 0.5f)
  private edit let m_tollerance: Float;

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let distance: Float;
    let effectRange: Float;
    let sourcePos: Vector4;
    let targetPos: Vector4;
    let target: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    let source: ref<Entity> = EffectScriptContext.GetSource(ctx);
    if target == null || source == null {
      return true;
    };
    targetPos = target.GetWorldPosition();
    targetPos.Z += this.m_rootOffset_Z;
    EffectData.GetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.radius, effectRange);
    effectRange += this.m_tollerance;
    EffectData.GetVector(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.position, sourcePos);
    distance = Vector4.Distance(sourcePos, targetPos);
    if distance <= effectRange {
      return true;
    };
    return false;
  }
}
