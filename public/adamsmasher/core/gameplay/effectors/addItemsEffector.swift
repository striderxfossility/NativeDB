
public class AddItemsEffector extends Effector {

  public let m_items: array<wref<InventoryItem_Record>>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    TweakDBInterface.GetAddItemsEffectorRecord(record).ItemsToAdd(this.m_items);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(this.m_items) {
      ts.GiveItem(owner, ItemID.FromTDBID(this.m_items[i].Item().GetID()), this.m_items[i].Quantity());
      i += 1;
    };
  }
}
