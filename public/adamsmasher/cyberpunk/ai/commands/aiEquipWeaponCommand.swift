
public class EquipPrimaryWeaponCommandDelegate extends ScriptBehaviorDelegate {

  public inline edit let command: wref<AISwitchToPrimaryWeaponCommand>;

  public inline edit let unEquip: Bool;

  public final func DoSetupCommand() -> Bool {
    this.unEquip = this.command.unEquip;
    return true;
  }

  public final func DoEndCommand() -> Bool {
    this.unEquip = false;
    return true;
  }
}

public class EquipSecondaryWeaponCommandDelegate extends ScriptBehaviorDelegate {

  public inline edit let command: wref<AISwitchToSecondaryWeaponCommand>;

  public inline edit let unEquip: Bool;

  public final func DoSetupCommand() -> Bool {
    this.unEquip = this.command.unEquip;
    return true;
  }

  public final func DoEndCommand() -> Bool {
    this.unEquip = false;
    return true;
  }
}
