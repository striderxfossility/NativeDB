
public class ModifyDamageWithVelocity extends ModifyDamageEffector {

  public let m_percentMult: Float;

  public let m_unitThreshold: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.Initialize(record, game, parentRecord);
    this.m_percentMult = TweakDBInterface.GetFloat(record + t".percentMult", 0.00);
    this.m_unitThreshold = TweakDBInterface.GetFloat(record + t".unitThreshold", 0.00);
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let currentVelocity: Float;
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if !IsDefined(hitEvent) {
      return;
    };
    if this.m_unitThreshold != 0.00 && this.m_percentMult != 0.00 {
      currentVelocity = Vector4.Length2D((hitEvent.attackData.GetInstigator() as gamePuppet).GetVelocity());
      this.m_value = currentVelocity / this.m_unitThreshold * this.m_percentMult;
      this.ModifyDamage(hitEvent, this.m_operationType, 1.00 + this.m_value);
    };
  }
}
