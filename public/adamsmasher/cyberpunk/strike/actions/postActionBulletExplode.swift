
public class EffectPostAction_BulletExplode extends EffectPostAction_Scripted {

  public final func Process(ctx: EffectScriptContext) -> Bool {
    let attackData: ref<AttackData>;
    let dataVariant: Variant;
    let endPosition: Vector4;
    let explosionAttackRecord: ref<Attack_GameEffect_Record>;
    let range: Float;
    let startPosition: Vector4;
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.attackData, dataVariant);
    attackData = FromVariant(dataVariant);
    if IsDefined(attackData) {
      explosionAttackRecord = ProjectileHelper.FindExplosiveHitAttack(attackData.GetAttackDefinition().GetRecord());
      if IsDefined(explosionAttackRecord) {
        EffectData.GetVector(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.position, startPosition);
        EffectData.GetVector(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.raycastEnd, endPosition);
        EffectData.GetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.range, range);
        if Vector4.Length(endPosition - startPosition) < range - 0.10 {
          ProjectileHelper.SpawnExplosionAttack(explosionAttackRecord, EffectScriptContext.GetWeapon(ctx) as WeaponObject, EffectScriptContext.GetInstigator(ctx) as GameObject, EffectScriptContext.GetInstigator(ctx) as GameObject, endPosition, 0.05);
        };
      };
    };
    return true;
  }
}
