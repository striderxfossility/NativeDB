
public class AddStatusEffectToAttackEffector extends ModifyAttackEffector {

  public let m_isRandom: Bool;

  public let m_applicationChance: Float;

  public let m_statusEffect: SHitStatusEffect;

  public let m_stacks: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_isRandom = TweakDBInterface.GetBool(record + t".isRandom", false);
    this.m_applicationChance = TweakDBInterface.GetFloat(record + t".applicationChance", 0.00);
    this.m_statusEffect.id = TweakDBInterface.GetAddStatusEffectToAttackEffectorRecord(record).StatusEffect().GetID();
    this.m_statusEffect.stacks = TweakDBInterface.GetAddStatusEffectToAttackEffectorRecord(record).Stacks();
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let rand: Float;
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Effect) {
      return;
    };
    if this.m_isRandom {
      rand = RandF();
      if rand <= this.m_applicationChance {
        hitEvent.attackData.AddStatusEffect(this.m_statusEffect.id, this.m_statusEffect.stacks);
      };
    } else {
      hitEvent.attackData.AddStatusEffect(this.m_statusEffect.id, this.m_statusEffect.stacks);
    };
  }
}
