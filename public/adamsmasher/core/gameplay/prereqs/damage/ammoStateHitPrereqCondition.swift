
public class AmmoStateHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_valueToListen: EMagazineAmmoState;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".ammoState", "");
    this.m_valueToListen = IntEnum(Cast(EnumValueFromString("EMagazineAmmoState", str)));
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let currentAmmo: Uint32;
    let maxAmmo: Uint32;
    let result: Bool;
    let weapon: wref<WeaponObject> = hitEvent.attackData.GetWeapon();
    if IsDefined(weapon) {
      currentAmmo = WeaponObject.GetMagazineAmmoCount(weapon);
    };
    switch this.m_valueToListen {
      case EMagazineAmmoState.FirstBullet:
        maxAmmo = GameInstance.GetBlackboardSystem(hitEvent.target.GetGame()).Get(GetAllBlackboardDefs().Weapon).GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCapacity);
        result = currentAmmo >= maxAmmo;
        break;
      case EMagazineAmmoState.LastBullet:
        result = currentAmmo <= 0u;
        break;
      default:
        return false;
    };
    return this.m_invert ? !result : result;
  }
}
