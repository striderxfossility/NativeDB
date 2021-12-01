
public class FirstEquipSystem extends ScriptableSystem {

  protected persistent let m_equipDataArray: array<EFirstEquipData>;

  public final static func GetInstance(owner: ref<GameObject>) -> ref<FirstEquipSystem> {
    let FES: ref<FirstEquipSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"FirstEquipSystem") as FirstEquipSystem;
    return FES;
  }

  public final const func HasPlayedFirstEquip(weaponID: TweakDBID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipDataArray) {
      if this.m_equipDataArray[i].weaponID == weaponID {
        return this.m_equipDataArray[i].hasPlayedFirstEquip;
      };
      i += 1;
    };
    return false;
  }

  private final func OnCompletionOfFirstEquip(request: ref<CompletionOfFirstEquipRequest>) -> Void {
    let receivedWeaponData: EFirstEquipData;
    receivedWeaponData.weaponID = request.weaponID;
    receivedWeaponData.hasPlayedFirstEquip = true;
    ArrayPush(this.m_equipDataArray, receivedWeaponData);
  }
}
