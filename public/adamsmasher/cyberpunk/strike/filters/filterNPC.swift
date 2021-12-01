
public class StrikeFilterSingle_NPC extends EffectObjectSingleFilter_Scripted {

  public edit let onlyAlive: Bool;

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    let puppet: ref<NPCPuppet> = entity as NPCPuppet;
    if IsDefined(puppet) {
      if this.onlyAlive {
        return ScriptedPuppet.IsAlive(puppet);
      };
      return true;
    };
    return false;
  }
}

public class FilterNPCsByType extends EffectObjectSingleFilter_Scripted {

  public edit const let m_allowedTypes: array<gamedataNPCType>;

  public edit let m_invert: Bool;

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let isTypeInList: Bool;
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    let puppet: ref<NPCPuppet> = entity as NPCPuppet;
    if IsDefined(puppet) {
      isTypeInList = ArrayContains(this.m_allowedTypes, puppet.GetNPCType());
      return this.m_invert ? !isTypeInList : isTypeInList;
    };
    return true;
  }
}
