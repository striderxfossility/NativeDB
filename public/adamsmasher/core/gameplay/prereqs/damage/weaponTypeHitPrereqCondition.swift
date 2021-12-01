
public class WeaponTypeHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_type: CName;

  public func SetData(recordID: TweakDBID) -> Void {
    this.m_type = TweakDBInterface.GetCName(recordID + t".weaponType", n"");
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    let objectToCheck: wref<WeaponObject> = hitEvent.attackData.GetWeapon();
    if IsDefined(objectToCheck) {
      switch this.m_type {
        case n"Melee":
          result = objectToCheck.IsMelee();
          break;
        case n"Ranged":
          result = objectToCheck.IsRanged();
          break;
        default:
          return false;
      };
      return this.m_invert ? !result : result;
    };
    return false;
  }
}
