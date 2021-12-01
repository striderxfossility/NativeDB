
public static exec func BuyItem(inst: GameInstance, item: String) -> Void {
  let buyRequestData: TransactionRequestData;
  buyRequestData.itemID = ItemID.FromTDBID(TDBID.Create(item));
  buyRequestData.quantity = 1;
  let buyRequest: ref<BuyRequest> = new BuyRequest();
  ArrayPush(buyRequest.items, buyRequestData);
  buyRequest.owner = GameInstance.GetTargetingSystem(inst).GetLookAtObject(GetPlayer(inst));
  MarketSystem.GetInstance(inst).QueueRequest(buyRequest);
}

public static exec func SellItem(inst: GameInstance, item: String) -> Void {
  let sellRequestData: TransactionRequestData;
  sellRequestData.itemID = ItemID.FromTDBID(TDBID.Create(item));
  sellRequestData.quantity = 1;
  let sellRequest: ref<SellRequest> = new SellRequest();
  ArrayPush(sellRequest.items, sellRequestData);
  sellRequest.owner = GameInstance.GetTargetingSystem(inst).GetLookAtObject(GetPlayer(inst));
  MarketSystem.GetInstance(inst).QueueRequest(sellRequest);
}
