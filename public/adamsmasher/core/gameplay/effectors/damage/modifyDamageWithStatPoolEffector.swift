
public class ModifyDamageWithStatPoolEffector extends ModifyDamageEffector {

  public let m_statPool: gamedataStatPoolType;

  public let m_poolStatus: String;

  public let m_maxDmg: Float;

  public let m_refObj: String;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let str: String;
    this.Initialize(record, game, parentRecord);
    str = TweakDBInterface.GetString(record + t".operationType", "");
    this.m_operationType = IntEnum(Cast(EnumValueFromString("EMathOperator", str)));
    str = TweakDBInterface.GetString(record + t".statPool", "");
    this.m_statPool = IntEnum(Cast(EnumValueFromString("gamedataStatPoolType", str)));
    this.m_poolStatus = TweakDBInterface.GetString(record + t".poolStatus", "");
    this.m_refObj = TweakDBInterface.GetString(record + t".refObj", "");
    this.m_maxDmg = TweakDBInterface.GetFloat(record + t".maxDmg", 1.00);
  }

  protected func Uninitialize(game: GameInstance) -> Void;

  private final func GetRefObject(hitEvent: ref<gameHitEvent>) -> wref<GameObject> {
    switch this.m_refObj {
      case "Instigator":
        return hitEvent.attackData.GetInstigator();
      case "Target":
        return hitEvent.target;
      default:
        return null;
    };
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    let obj: wref<GameObject>;
    let statPoolVal: Float;
    let hitEvent: ref<gameHitEvent> = this.GetHitEvent();
    if !IsDefined(hitEvent) {
      return;
    };
    obj = this.GetRefObject(hitEvent);
    if !IsDefined(obj) {
      return;
    };
    statPoolVal = GameInstance.GetStatPoolsSystem(owner.GetGame()).GetStatPoolValue(Cast(obj.GetEntityID()), this.m_statPool) / 100.00;
    if Equals(this.m_poolStatus, "Missing") {
      statPoolVal = 1.00 - statPoolVal;
    };
    if this.m_maxDmg != 0.00 {
      this.m_value = (this.m_maxDmg - 1.00) * statPoolVal + 1.00;
      this.ModifyDamage(hitEvent, this.m_operationType, this.m_value);
    };
  }
}
