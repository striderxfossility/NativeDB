
public class ModifyDamageEffector extends ModifyAttackEffector {

  public let m_operationType: EMathOperator;

  public let m_value: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(record + t".operationType", "");
    this.m_operationType = IntEnum(Cast(EnumValueFromString("EMathOperator", str)));
    this.m_value = TweakDBInterface.GetFloat(record + t".value", 0.00);
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if !IsDefined(hitEvent) {
      return;
    };
    this.ModifyDamage(hitEvent, this.m_operationType, this.m_value);
  }

  protected final func ModifyDamage(hitEvent: ref<gameHitEvent>, operationType: EMathOperator, value: Float) -> Void {
    switch operationType {
      case EMathOperator.Add:
        hitEvent.attackComputed.AddAttackValue(value);
        break;
      case EMathOperator.Subtract:
        hitEvent.attackComputed.AddAttackValue(-value);
        break;
      case EMathOperator.Multiply:
        hitEvent.attackComputed.MultAttackValue(value);
        break;
      case EMathOperator.Divide:
        hitEvent.attackComputed.MultAttackValue(1.00 / value);
        break;
      default:
        return;
    };
  }
}
