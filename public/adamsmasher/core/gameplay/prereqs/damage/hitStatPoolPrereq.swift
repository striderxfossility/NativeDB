
public class HitStatPoolPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitStatPoolPrereq> = this.GetPrereq() as HitStatPoolPrereq;
    let checkPassed: Bool = this.ComparePoolValues(hitEvent, prereq);
    return checkPassed;
  }

  private final func ComparePoolValues(hitEvent: ref<gameHitEvent>, const prereq: ref<HitStatPoolPrereq>) -> Bool {
    let poolValue: Float;
    let sps: ref<StatPoolsSystem>;
    let obj: wref<GameObject> = this.GetObjectToCheck(prereq.m_objectToCheck, hitEvent);
    if !IsDefined(obj) {
      return false;
    };
    sps = GameInstance.GetStatPoolsSystem(obj.GetGame());
    poolValue = sps.GetStatPoolValue(Cast(obj.GetEntityID()), prereq.m_statPoolToCompare);
    return ProcessCompare(prereq.m_comparisonType, prereq.m_valueToCheck, poolValue);
  }
}

public class HitStatPoolPrereq extends GenericHitPrereq {

  public let m_valueToCheck: Float;

  public let m_objectToCheck: String;

  public let m_comparisonType: EComparisonType;

  public let m_statPoolToCompare: gamedataStatPoolType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_objectToCheck = TweakDBInterface.GetString(recordID + t".objectToCheck", "");
    this.m_valueToCheck = TweakDBInterface.GetFloat(recordID + t".valueToCheck", 0.00);
    let str: String = TweakDBInterface.GetString(recordID + t".statPoolToCompare", "");
    this.m_statPoolToCompare = IntEnum(Cast(EnumValueFromString("gamedataStatPoolType", str)));
    str = TweakDBInterface.GetString(recordID + t".comparisonType", "");
    this.m_comparisonType = IntEnum(Cast(EnumValueFromString("EComparisonType", str)));
  }
}
