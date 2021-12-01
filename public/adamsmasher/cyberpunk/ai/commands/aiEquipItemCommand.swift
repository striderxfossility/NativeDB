
public class EquipItemCommandDelegate extends ScriptBehaviorDelegate {

  public inline edit let equipCommand: wref<AIEquipCommand>;

  public inline edit let unequipCommand: wref<AIUnequipCommand>;

  public inline edit let slotIdName: TweakDBID;

  public inline edit let itemIdName: TweakDBID;

  public final func GetFailIfItemNotFound() -> Bool {
    return this.equipCommand.failIfItemNotFound;
  }

  public final func GetDurationOverride() -> Float {
    return this.equipCommand.durationOverride;
  }

  public final func GetUnequipDurationOverride() -> Float {
    return this.unequipCommand.durationOverride;
  }

  public final func DoSetupEquipCommand() -> Bool {
    this.slotIdName = this.equipCommand.slotId;
    this.itemIdName = this.equipCommand.itemId;
    return true;
  }

  public final func DoSetupUnequipCommand() -> Bool {
    this.slotIdName = this.unequipCommand.slotId;
    return true;
  }

  public final func DoEndCommand() -> Bool {
    this.equipCommand = null;
    this.unequipCommand = null;
    return true;
  }
}
