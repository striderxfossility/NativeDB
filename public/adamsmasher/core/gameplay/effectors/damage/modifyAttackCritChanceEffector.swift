
public class ModifyAttackCritChanceEffector extends ModifyAttackEffector {

  public let m_value: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_value = TweakDBInterface.GetFloat(record + t".value", 0.00);
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if !IsDefined(hitEvent) {
      return;
    };
    hitEvent.attackData.SetAdditionalCritChance(this.m_value);
  }
}
