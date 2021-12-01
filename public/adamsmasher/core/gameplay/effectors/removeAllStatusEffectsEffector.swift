
public class RemoveAllStatusEffectsEffector extends Effector {

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let effects: array<ref<StatusEffect>>;
    let i: Int32;
    let seSys: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(owner.GetGame());
    seSys.GetAppliedEffects(owner.GetEntityID(), effects);
    i = 0;
    while i < ArraySize(effects) {
      seSys.RemoveStatusEffect(owner.GetEntityID(), effects[i].GetRecord().GetID());
      i += 1;
    };
  }
}
