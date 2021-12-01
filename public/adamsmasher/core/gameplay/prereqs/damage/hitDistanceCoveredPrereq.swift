
public class HitDistanceCoveredPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let distanceCovered: Float;
    let prereq: ref<HitDistanceCoveredPrereq> = this.GetPrereq() as HitDistanceCoveredPrereq;
    if IsDefined(hitEvent) {
      distanceCovered = Vector4.Distance(hitEvent.attackData.GetAttackPosition(), hitEvent.target.GetWorldPosition());
      return ProcessCompare(prereq.m_comparisonType, distanceCovered, prereq.m_distanceRequired);
    };
    return false;
  }
}

public class HitDistanceCoveredPrereq extends GenericHitPrereq {

  public let m_distanceRequired: Float;

  public let m_comparisonType: EComparisonType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_distanceRequired = TweakDBInterface.GetFloat(recordID + t".distanceRequired", 0.00);
    let str: String = TweakDBInterface.GetString(recordID + t".comparisonType", "");
    this.m_comparisonType = IntEnum(Cast(EnumValueFromString("EComparisonType", str)));
  }
}
