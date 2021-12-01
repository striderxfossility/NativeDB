
public native class gameEffectObjectFilter_OnlyNearest_Pierce extends gameEffectObjectFilter_OnlyNearest {

  public final func CanPierceEntity(ctx: EffectScriptContext, target: ref<Entity>, hitPosition: Vector4, hitDirection: Vector4) -> Bool {
    let attackData: ref<AttackData>;
    let dataVariant: Variant;
    let explosionAttackRecord: ref<Attack_GameEffect_Record>;
    let allowPierce: Bool = true;
    if IsDefined(target as ScriptedPuppet) || IsDefined(target as Device) {
      EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.attackData, dataVariant);
      attackData = FromVariant(dataVariant);
      if IsDefined(attackData) {
        explosionAttackRecord = ProjectileHelper.FindExplosiveHitAttack(attackData.GetAttackDefinition().GetRecord());
        if IsDefined(explosionAttackRecord) {
          allowPierce = false;
        };
      };
    };
    return allowPierce;
  }
}
