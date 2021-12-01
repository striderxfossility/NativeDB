
public abstract class ItemActionsHelper extends IScriptable {

  public final static func ConsumeItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetConsumeAction(itemID).GetID(), fromInventory);
  }

  public final static func EatItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetEatAction(itemID).GetID(), fromInventory);
  }

  public final static func DrinkItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetDrinkAction(itemID).GetID(), fromInventory);
  }

  public final static func LearnItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetLearnAction(itemID).GetID(), fromInventory);
  }

  public final static func DropItem(executor: wref<GameObject>, itemID: ItemID) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetDropAction(itemID).GetID(), true);
  }

  public final static func DisassembleItem(executor: wref<GameObject>, itemID: ItemID) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetDisassembleAction(itemID).GetID(), true);
  }

  public final static func DisassembleItem(executor: wref<GameObject>, itemID: ItemID, quantity: Int32) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetDisassembleAction(itemID).GetID(), true, quantity);
  }

  public final static func ReadItem(executor: wref<GameObject>, itemID: ItemID) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetReadAction(itemID).GetID(), true);
  }

  public final static func CrackItem(executor: wref<GameObject>, itemID: ItemID) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetCrackAction(itemID).GetID(), true);
  }

  public final static func DownloadFunds(executor: wref<GameObject>, itemID: ItemID) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetDownloadFunds(itemID).GetID(), true);
  }

  public final static func UseItem(executor: wref<GameObject>, itemID: ItemID) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetUseAction(itemID).GetID(), true);
  }

  public final static func EquipItem(executor: wref<GameObject>, itemID: ItemID) -> Void {
    ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), ItemActionsHelper.GetEquipAction(itemID).GetID(), true);
  }

  public final static func PerformItemAction(executor: wref<GameObject>, itemID: ItemID) -> Void {
    let record: wref<ObjectAction_Record> = ItemActionsHelper.GetItemCustomAction(itemID);
    if IsDefined(record) {
      ItemActionsHelper.ProcessItemAction(executor.GetGame(), executor, RPGManager.GetItemData(executor.GetGame(), executor, itemID), record.GetID(), true);
    };
  }

  public final static func GetConsumeAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Consume");
  }

  public final static func GetEatAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Eat");
  }

  public final static func GetDrinkAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Drink");
  }

  public final static func GetLearnAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Learn");
  }

  public final static func GetDownloadFunds(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"DownloadFunds");
  }

  public final static func GetReadAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Read");
  }

  public final static func GetDisassembleAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Disassemble");
  }

  public final static func GetDropAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Drop");
  }

  public final static func GetUseAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Use");
  }

  public final static func GetCrackAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Crack");
  }

  public final static func GetEquipAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    return ItemActionsHelper.GetItemActionByType(itemID, n"Equip");
  }

  public final static func GetItemCustomAction(itemID: ItemID) -> wref<ObjectAction_Record> {
    let actions: array<wref<ObjectAction_Record>>;
    let emptyAction: wref<ObjectAction_Record>;
    let i: Int32;
    TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ObjectActions(actions);
    i = 0;
    while i < ArraySize(actions) {
      if NotEquals(actions[i].ActionName(), n"Drop") && NotEquals(actions[i].ActionName(), n"Disassemble") {
        return actions[i];
      };
      i += 1;
    };
    return emptyAction;
  }

  public final static func GetItemActionByType(itemID: ItemID, type: CName) -> wref<ObjectAction_Record> {
    let actions: array<wref<ObjectAction_Record>>;
    let emptyAction: wref<ObjectAction_Record>;
    let i: Int32;
    TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ObjectActions(actions);
    ArrayPush(actions, TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ItemSecondaryAction());
    i = 0;
    while i < ArraySize(actions) {
      if Equals(actions[i].ActionName(), type) {
        return actions[i];
      };
      i += 1;
    };
    return emptyAction;
  }

  public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Void {
    let action: ref<BaseItemAction> = ItemActionsHelper.SetupItemAction(gi, executor, itemData, actionID, fromInventory);
    if action.IsPossible(executor, TweakDBInterface.GetObjectActionRecord(actionID)) {
      action.ProcessRPGAction(gi);
    };
  }

  public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool, quantity: Int32) -> Void {
    let action: ref<BaseItemAction> = ItemActionsHelper.SetupItemAction(gi, executor, itemData, actionID, fromInventory);
    action.SetRequestQuantity(quantity);
    if action.IsPossible(executor, TweakDBInterface.GetObjectActionRecord(actionID)) {
      action.ProcessRPGAction(gi);
    };
  }

  public final static func SetupItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> ref<BaseItemAction> {
    let action: ref<BaseItemAction>;
    let actionType: CName = TweakDBInterface.GetObjectActionRecord(actionID).ActionName();
    switch actionType {
      case n"Use":
        action = new UseAction();
        break;
      case n"Consume":
      case n"Eat":
      case n"Drink":
        action = new ConsumeAction();
        break;
      case n"Learn":
        action = new LearnAction();
        break;
      case n"Disassemble":
        action = new DisassembleAction();
        break;
      case n"Drop":
        action = new DropAction();
        break;
      case n"Read":
        action = new ReadAction();
        break;
      case n"Crack":
        action = new CrackAction();
        break;
      case n"EquipItem":
        action = new EquipAction();
        break;
      case n"DownloadFunds":
        action = new DownloadFundsAction();
        break;
      default:
        return null;
    };
    action.SetItemData(itemData);
    action.RegisterAsRequester(StatsObjectID.ExtractEntityID(itemData.GetStatsObjectID()));
    action.SetExecutor(executor);
    action.SetObjectActionID(actionID);
    if fromInventory {
      action.SetRemoveAfterUse();
    };
    return action;
  }
}

public static exec func ItemActionsHelper_ConsumeItem(executor: wref<GameObject>, itemID: ItemID, fromInventory: Bool) -> Void {
  ItemActionsHelper.ConsumeItem(executor, itemID, fromInventory);
}
