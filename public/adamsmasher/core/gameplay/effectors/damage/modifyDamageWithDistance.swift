
public class ModifyDamageWithDistance extends ModifyDamageEffector {

  public let m_increaseWithDistance: Bool;

  public let m_percentMult: Float;

  public let m_unitThreshold: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.Initialize(record, game, parentRecord);
    this.m_percentMult = TweakDBInterface.GetFloat(record + t".percentMult", 0.00);
    this.m_unitThreshold = TweakDBInterface.GetFloat(record + t".unitThreshold", 0.00);
    this.m_increaseWithDistance = TweakDBInterface.GetBool(record + t".increaseWithDistance", false);
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let coveredDistance: Float;
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if !IsDefined(hitEvent) {
      return;
    };
    if this.m_unitThreshold != 0.00 && this.m_percentMult != 0.00 {
      coveredDistance = Vector4.Distance(hitEvent.attackData.GetAttackPosition(), hitEvent.target.GetWorldPosition());
      if this.m_increaseWithDistance {
        this.m_value = coveredDistance / this.m_unitThreshold * this.m_percentMult;
      } else {
        this.m_value = this.m_unitThreshold / coveredDistance * this.m_percentMult;
      };
      this.ModifyDamage(hitEvent, this.m_operationType, 1.00 + this.m_value);
    };
  }
}
