
public static exec func WorkspotEnableVisualLog(instance: GameInstance, entId: String) -> Void {
  let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(instance);
  workspotSystem.SendDebugCommand(workWorkspotDebugMode.VisualLogOn, entId);
}

public static exec func WorkspotDisableVisualLog(instance: GameInstance, entId: String) -> Void {
  let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(instance);
  workspotSystem.SendDebugCommand(workWorkspotDebugMode.VisualLogOff, entId);
}

public static exec func WorkspotEnableStateView(instance: GameInstance, entId: String) -> Void {
  let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(instance);
  workspotSystem.SendDebugCommand(workWorkspotDebugMode.VisualStateOn, entId);
}

public static exec func WorkspotDisableStateView(instance: GameInstance, entId: String) -> Void {
  let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(instance);
  workspotSystem.SendDebugCommand(workWorkspotDebugMode.VisualStateOff, entId);
}

public native class WorkspotCondition extends IScriptable {

  public const func CheckCondition(ent: ref<Entity>) -> Bool {
    return true;
  }
}

public class TestConditon extends WorkspotCondition {

  protected const func CheckCondition(const ent: ref<Entity>) -> Bool {
    return true;
  }
}

public class TestFalseConditon extends WorkspotCondition {

  protected const func CheckCondition(const ent: ref<Entity>) -> Bool {
    return false;
  }
}

public class IsUnarmedCondition extends WorkspotCondition {

  protected const func CheckCondition(ent: ref<Entity>) -> Bool {
    let items: array<wref<ItemObject>>;
    let obj: ref<GameObject> = ent as GameObject;
    if !IsDefined(obj) {
      return true;
    };
    if !obj.IsNPC() {
      return false;
    };
    return !AIActionHelper.GetItemsFromWeaponSlots(obj, items);
  }
}

public class HasMeleeWeaponEquippedCondition extends WorkspotCondition {

  protected const func CheckCondition(ent: ref<Entity>) -> Bool {
    let i: Int32;
    let items: array<wref<ItemObject>>;
    let transactionSystem: ref<TransactionSystem>;
    let obj: ref<GameObject> = ent as GameObject;
    if !IsDefined(obj) {
      return true;
    };
    if !obj.IsNPC() {
      return false;
    };
    if !AIActionHelper.GetItemsFromWeaponSlots(obj, items) {
      return false;
    };
    transactionSystem = GameInstance.GetTransactionSystem(obj.GetGame());
    i = 0;
    while i < ArraySize(items) {
      if transactionSystem.HasTag(obj, WeaponObject.GetMeleeWeaponTag(), items[i].GetItemID()) {
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class HasRangedWeaponEquippedCondition extends WorkspotCondition {

  protected const func CheckCondition(ent: ref<Entity>) -> Bool {
    let i: Int32;
    let items: array<wref<ItemObject>>;
    let transactionSystem: ref<TransactionSystem>;
    let obj: ref<GameObject> = ent as GameObject;
    if !IsDefined(obj) {
      return true;
    };
    if !obj.IsNPC() {
      return false;
    };
    if !AIActionHelper.GetItemsFromWeaponSlots(obj, items) {
      return false;
    };
    transactionSystem = GameInstance.GetTransactionSystem(obj.GetGame());
    i = 0;
    while i < ArraySize(items) {
      if transactionSystem.HasTag(obj, WeaponObject.GetRangedWeaponTag(), items[i].GetItemID()) {
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class PrimaryWeaponTypeCondition extends WorkspotCondition {

  protected edit let weaponType: WorkspotWeaponConditionEnum;

  protected const func CheckCondition(ent: ref<Entity>) -> Bool {
    let i: Int32;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let npc: ref<NPCPuppet>;
    let weaponTag: CName;
    let obj: ref<GameObject> = ent as GameObject;
    if !IsDefined(obj) {
      return true;
    };
    if !obj.IsNPC() {
      return false;
    };
    switch this.weaponType {
      case WorkspotWeaponConditionEnum.Ranged:
        weaponTag = WeaponObject.GetRangedWeaponTag();
        break;
      case WorkspotWeaponConditionEnum.OneHandedRanged:
        weaponTag = WeaponObject.GetOneHandedRangedWeaponTag();
        break;
      case WorkspotWeaponConditionEnum.Melee:
        weaponTag = WeaponObject.GetMeleeWeaponTag();
        break;
      case WorkspotWeaponConditionEnum.MeleeCyberware:
        weaponTag = n"Meleeware";
        break;
      case WorkspotWeaponConditionEnum.LMG:
        weaponTag = n"LMG";
        break;
      default:
        return true;
    };
    npc = obj as NPCPuppet;
    AIActionTransactionSystem.CalculateEquipmentItems(npc, n"PrimaryEquipment", items);
    i = 0;
    while i < ArraySize(items) {
      if items[i].Item().TagsContains(weaponTag) {
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class EquippedWeaponTypeCondition extends WorkspotCondition {

  protected edit let weaponType: WorkspotWeaponConditionEnum;

  protected const func CheckCondition(ent: ref<Entity>) -> Bool {
    let hasAnyWeaponEquipped: Bool;
    let i: Int32;
    let items: array<wref<ItemObject>>;
    let transactionSystem: ref<TransactionSystem>;
    let weaponTag: CName;
    let obj: ref<GameObject> = ent as GameObject;
    if !IsDefined(obj) {
      return true;
    };
    if !obj.IsNPC() {
      return false;
    };
    hasAnyWeaponEquipped = AIActionHelper.GetItemsFromWeaponSlots(obj, items);
    if Equals(this.weaponType, IntEnum(0l)) {
      return !hasAnyWeaponEquipped;
    };
    switch this.weaponType {
      case WorkspotWeaponConditionEnum.Ranged:
        weaponTag = WeaponObject.GetRangedWeaponTag();
        break;
      case WorkspotWeaponConditionEnum.OneHandedRanged:
        weaponTag = WeaponObject.GetOneHandedRangedWeaponTag();
        break;
      case WorkspotWeaponConditionEnum.Melee:
        weaponTag = WeaponObject.GetMeleeWeaponTag();
        break;
      case WorkspotWeaponConditionEnum.MeleeCyberware:
        weaponTag = n"Meleeware";
        break;
      case WorkspotWeaponConditionEnum.LMG:
        weaponTag = n"LMG";
        break;
      default:
        return true;
    };
    transactionSystem = GameInstance.GetTransactionSystem(obj.GetGame());
    i = 0;
    while i < ArraySize(items) {
      if transactionSystem.HasTag(obj, weaponTag, items[i].GetItemID()) {
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class LogicalCondition extends WorkspotCondition {

  protected edit let operation: WorkspotConditionOperators;

  protected inline edit const let conditions: array<ref<WorkspotCondition>>;

  public const func CheckCondition(ent: ref<Entity>) -> Bool {
    let i: Int32;
    if Equals(this.operation, WorkspotConditionOperators.OR) {
      i = 0;
      while i < ArraySize(this.conditions) {
        if this.conditions[i].CheckCondition(ent) {
          return true;
        };
        i += 1;
      };
      return false;
    };
    if Equals(this.operation, WorkspotConditionOperators.AND) {
      i = 0;
      while i < ArraySize(this.conditions) {
        if !this.conditions[i].CheckCondition(ent) {
          return false;
        };
        i += 1;
      };
      return true;
    };
    return false;
  }
}
