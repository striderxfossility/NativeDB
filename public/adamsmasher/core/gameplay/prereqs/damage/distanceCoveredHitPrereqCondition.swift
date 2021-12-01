
public class DistanceCoveredHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_distanceRequired: Float;

  public let m_comparisonType: EComparisonType;

  public func SetData(recordID: TweakDBID) -> Void {
    this.m_distanceRequired = TweakDBInterface.GetFloat(recordID + t".distanceRequired", 0.00);
    let str: String = TweakDBInterface.GetString(recordID + t".comparisonType", "");
    this.m_comparisonType = IntEnum(Cast(EnumValueFromString("EComparisonType", str)));
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let distanceCovered: Float;
    let result: Bool;
    if IsDefined(hitEvent) {
      distanceCovered = Vector4.Distance(hitEvent.attackData.GetAttackPosition(), hitEvent.target.GetWorldPosition());
      result = ProcessCompare(this.m_comparisonType, distanceCovered, this.m_distanceRequired);
      return this.m_invert ? !result : result;
    };
    return false;
  }
}
