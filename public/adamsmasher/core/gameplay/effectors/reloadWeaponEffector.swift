
public class ReloadWeaponEffector extends Effector {

  private let m_owner: wref<GameObject>;

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let reloadEvent: ref<ForceResetAmmoEvent>;
    this.m_owner = owner;
    let weapon: wref<WeaponObject> = ScriptedPuppet.GetWeaponRight(this.m_owner);
    if IsDefined(weapon) {
      reloadEvent = new ForceResetAmmoEvent();
      reloadEvent.SetTargetValue(Cast(WeaponObject.GetMagazineCapacity(weapon)));
      this.m_owner.QueueEvent(reloadEvent);
    };
  }
}
