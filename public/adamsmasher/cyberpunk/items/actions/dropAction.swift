
public class DropAction extends BaseItemAction {

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let instructions: array<DropInstruction>;
    let itemID: ItemID;
    let orientation: Quaternion;
    let position: Vector4;
    let upAxisAddition: Vector4;
    if this.GetItemData().HasTag(n"UnequipBlocked") || this.GetItemData().HasTag(n"Quest") {
      return;
    };
    itemID = this.GetItemData().GetID();
    GameInstance.GetTelemetrySystem(this.m_executor.GetGame()).LogItemDrop(this.m_executor, itemID);
    this.CompleteAction(gameInstance);
    upAxisAddition = new Vector4(0.00, 0.00, 0.40, 0.00);
    position = this.GetExecutor().GetWorldPosition() + upAxisAddition;
    orientation = this.GetExecutor().GetWorldOrientation() * Quaternion.Rand(0.00, 360.00);
    if Equals(RPGManager.GetItemCategory(itemID), gamedataItemCategory.Clothing) || !IsNameValid(RPGManager.GetItemRecord(itemID).EntityName()) || Equals(RPGManager.GetItemCategory(itemID), gamedataItemCategory.General) || Equals(RPGManager.GetItemCategory(itemID), gamedataItemCategory.Consumable) {
      ArrayPush(instructions, DropInstruction.Create(itemID, 1));
      GameInstance.GetLootManager(gameInstance).SpawnItemDropOfManyItems(this.GetExecutor(), instructions, n"playerDropBag", position);
    } else {
      GameInstance.GetLootManager(gameInstance).SpawnItemDrop(this.GetExecutor(), itemID, position + Quaternion.GetForward(this.GetExecutor().GetWorldOrientation()), orientation);
    };
  }
}
