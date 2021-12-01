
public class HitStatPoolComparisonPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitStatPoolComparisonPrereq> = this.GetPrereq() as HitStatPoolComparisonPrereq;
    let checkPassed: Bool = this.ComparePoolValues(hitEvent, prereq);
    return checkPassed;
  }

  private final func ComparePoolValues(hitEvent: ref<gameHitEvent>, const prereq: ref<HitStatPoolComparisonPrereq>) -> Bool {
    let sourcePoolValue: Float;
    let sps: ref<StatPoolsSystem>;
    let targetPoolValue: Float;
    let source: wref<GameObject> = this.GetObjectToCheck(prereq.m_comparisonSource, hitEvent);
    let target: wref<GameObject> = this.GetObjectToCheck(prereq.m_comparisonTarget, hitEvent);
    if !IsDefined(source) || !IsDefined(target) {
      return false;
    };
    sps = GameInstance.GetStatPoolsSystem(source.GetGame());
    sourcePoolValue = sps.GetStatPoolValue(Cast(source.GetEntityID()), prereq.m_statPoolToCompare);
    targetPoolValue = sps.GetStatPoolValue(Cast(target.GetEntityID()), prereq.m_statPoolToCompare);
    return ProcessCompare(prereq.m_comparisonType, sourcePoolValue, targetPoolValue);
  }
}

public class HitStatPoolComparisonPrereq extends GenericHitPrereq {

  public let m_comparisonSource: String;

  public let m_comparisonTarget: String;

  public let m_comparisonType: EComparisonType;

  public let m_statPoolToCompare: gamedataStatPoolType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_comparisonSource = TweakDBInterface.GetString(recordID + t".comparisonSource", "");
    this.m_comparisonTarget = TweakDBInterface.GetString(recordID + t".comparisonTarget", "");
    let str: String = TweakDBInterface.GetString(recordID + t".statPoolToCompare", "");
    this.m_statPoolToCompare = IntEnum(Cast(EnumValueFromString("gamedataStatPoolType", str)));
    str = TweakDBInterface.GetString(recordID + t".comparisonType", "");
    this.m_comparisonType = IntEnum(Cast(EnumValueFromString("EComparisonType", str)));
  }
}
