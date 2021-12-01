
public class CombatGadgetHelper extends IScriptable {

  public final static func SpawnAttack(source: ref<GameObject>, radius: Float, attackRecord: ref<Attack_Record>, instigator: wref<GameObject>) -> Void {
    let attackContext: AttackInitContext;
    let statMods: array<ref<gameStatModifierData>>;
    attackContext.record = attackRecord;
    attackContext.instigator = instigator;
    attackContext.source = source;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    let attackEffect: ref<EffectInstance> = attack.PrepareAttack(instigator);
    attack.GetStatModList(statMods);
    EffectData.SetFloat(attackEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
    EffectData.SetVector(attackEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, source.GetWorldPosition());
    EffectData.SetVariant(attackEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    EffectData.SetVariant(attackEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    attack.StartAttack();
  }

  public final static func SpawnPhysicalImpulse(source: ref<GameObject>, radius: Float) -> Void {
    let effect: ref<EffectInstance> = GameInstance.GetGameEffectSystem(source.GetGame()).CreateEffectStatic(n"physicalImpulseSphere", n"", source);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, source.GetWorldPosition());
    effect.Run();
  }
}
