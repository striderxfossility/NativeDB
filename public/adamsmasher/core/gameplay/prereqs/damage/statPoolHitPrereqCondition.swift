
public class StatPoolHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_valueToCheck: Float;

  public let m_objectToCheck: CName;

  public let m_comparisonType: EComparisonType;

  public let m_statPoolToCompare: gamedataStatPoolType;

  protected func SetData(recordID: TweakDBID) -> Void {
    this.m_objectToCheck = TweakDBInterface.GetCName(recordID + t".objectToCheck", n"");
    this.m_valueToCheck = TweakDBInterface.GetFloat(recordID + t".valueToCheck", 0.00);
    let str: String = TweakDBInterface.GetString(recordID + t".statPoolToCompare", "");
    this.m_statPoolToCompare = IntEnum(Cast(EnumValueFromString("gamedataStatPoolType", str)));
    str = TweakDBInterface.GetString(recordID + t".comparisonType", "");
    this.m_comparisonType = IntEnum(Cast(EnumValueFromString("EComparisonType", str)));
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool = this.ComparePoolValues(hitEvent);
    return this.m_invert ? !result : result;
  }

  private final func ComparePoolValues(hitEvent: ref<gameHitEvent>) -> Bool {
    let poolValue: Float;
    let sps: ref<StatPoolsSystem>;
    let obj: wref<GameObject> = this.GetObjectToCheck(this.m_objectToCheck, hitEvent);
    if !IsDefined(obj) {
      return false;
    };
    sps = GameInstance.GetStatPoolsSystem(obj.GetGame());
    poolValue = sps.GetStatPoolValue(Cast(obj.GetEntityID()), this.m_statPoolToCompare);
    return ProcessCompare(this.m_comparisonType, poolValue, this.m_valueToCheck);
  }
}
