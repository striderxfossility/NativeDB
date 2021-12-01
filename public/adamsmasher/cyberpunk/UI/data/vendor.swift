
public class VendorDataManager extends IScriptable {

  private let m_VendorObject: wref<GameObject>;

  private let m_BuyingCart: array<VendorShoppingCartItem>;

  private let m_SellingCart: array<VendorShoppingCartItem>;

  private let m_VendorID: TweakDBID;

  private let m_VendingBlacklist: array<EVendorMode>;

  private let m_TimeToCompletePurchase: Float;

  protected let m_UIBBEquipment: ref<UI_EquipmentDef>;

  private let m_InventoryBBID: ref<CallbackHandle>;

  private let m_EquipmentBBID: ref<CallbackHandle>;

  private let m_openTime: GameTime;

  public final func Initialize(vendor: wref<GameObject>, vendingTerminalSetup: VendingTerminalSetup) -> Void {
    this.m_VendorObject = vendor;
    this.m_VendorID = vendingTerminalSetup.m_vendorTweakID;
    this.m_VendingBlacklist = vendingTerminalSetup.m_vendingBlacklist;
    this.m_TimeToCompletePurchase = vendingTerminalSetup.m_timeToCompletePurchase;
    MarketSystem.OnVendorMenuOpen(this.m_VendorObject);
  }

  public final func Initialize(owner: wref<GameObject>, entityID: EntityID) -> Void {
    this.m_TimeToCompletePurchase = 0.00;
    this.m_VendorObject = GameInstance.FindEntityByID(owner.GetGame(), entityID) as GameObject;
    this.m_VendorID = MarketSystem.GetVendorID(this.m_VendorObject);
    MarketSystem.OnVendorMenuOpen(this.m_VendorObject);
  }

  public final func UpdateOpenTime(gameInstance: GameInstance) -> Void {
    this.m_openTime = GameInstance.GetTimeSystem(gameInstance).GetGameTime();
  }

  public final func GetOpenTime() -> GameTime {
    return this.m_openTime;
  }

  public final func GetVendorInstance() -> wref<GameObject> {
    return this.m_VendorObject;
  }

  public final func GetVendorID() -> TweakDBID {
    return this.m_VendorID;
  }

  public final func GetLocalPlayer() -> wref<PlayerPuppet> {
    return GameInstance.GetPlayerSystem(this.m_VendorObject.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
  }

  public final func GetVendorName() -> String {
    return TweakDBInterface.GetVendorRecord(this.m_VendorID).LocalizedName();
  }

  public final func GetVendorDescription() -> String {
    return TweakDBInterface.GetVendorRecord(this.m_VendorID).LocalizedDescription();
  }

  public final func GetLocalPlayerCurrencyAmount() -> Int32 {
    return GameInstance.GetTransactionSystem(this.GetLocalPlayer().GetGame()).GetItemQuantity(this.GetLocalPlayer(), MarketSystem.Money());
  }

  public final func GetSpecialOffers() -> array<ref<gameItemData>> {
    let inventory: array<ref<gameItemData>>;
    return inventory;
  }

  public final func GetVendorSpecialOffers() -> array<ref<VendorGameItemData>> {
    let inventory: array<ref<VendorGameItemData>>;
    return inventory;
  }

  public final func GetVendorInventoryItems() -> array<ref<VendorGameItemData>> {
    let inventory: array<ref<VendorGameItemData>>;
    let itemData: ref<gameItemData>;
    let vendorItemData: ref<VendorGameItemData>;
    let transactionSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_VendorObject.GetGame());
    let vendorStock: array<SItemStack> = MarketSystem.GetVendorItemsForSale(this.m_VendorObject, true);
    let i: Int32 = 0;
    while i < ArraySize(vendorStock) {
      vendorItemData = new VendorGameItemData();
      itemData = transactionSys.GetItemData(this.m_VendorObject, vendorStock[i].itemID);
      vendorItemData.gameItemData = itemData;
      vendorItemData.itemStack = vendorStock[i];
      ArrayPush(inventory, vendorItemData);
      i += 1;
    };
    return inventory;
  }

  public final func GetRipperDocItems() -> array<ref<VendorGameItemData>> {
    let inventory: array<ref<VendorGameItemData>>;
    let itemData: ref<gameItemData>;
    let vendorItemData: ref<VendorGameItemData>;
    let transactionSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_VendorObject.GetGame());
    let cyberwareStock: array<SItemStack> = MarketSystem.GetVendorCyberwareForSale(this.m_VendorObject, true);
    let i: Int32 = 0;
    while i < ArraySize(cyberwareStock) {
      vendorItemData = new VendorGameItemData();
      itemData = transactionSys.GetItemData(this.m_VendorObject, cyberwareStock[i].itemID);
      vendorItemData.gameItemData = itemData;
      vendorItemData.itemStack = cyberwareStock[i];
      ArrayPush(inventory, vendorItemData);
      i += 1;
    };
    return inventory;
  }

  public final func GetItemsPlayerCanSell() -> array<ref<gameItemData>> {
    let itemData: ref<gameItemData>;
    let sellItemData: array<ref<gameItemData>>;
    let transactionSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_VendorObject.GetGame());
    let playerStock: array<SItemStack> = MarketSystem.GetItemsPlayerCanSell(this.m_VendorObject, true, false);
    let i: Int32 = 0;
    while i < ArraySize(playerStock) {
      itemData = transactionSys.GetItemData(GetPlayer(this.m_VendorObject.GetGame()), playerStock[i].itemID);
      ArrayPush(sellItemData, itemData);
      i += 1;
    };
    return sellItemData;
  }

  public final func CanPlayerSellItem(itemID: ItemID) -> Bool {
    return MarketSystem.CanPlayerSellItem(this.m_VendorObject, itemID, false, false);
  }

  public final func GetStorageItems() -> array<ref<gameItemData>> {
    let gameItemList: array<ref<gameItemData>>;
    let i: Int32;
    let itemList: array<wref<gameItemData>>;
    let transactionSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_VendorObject.GetGame());
    transactionSys.GetItemList(this.m_VendorObject, itemList);
    i = 0;
    while i < ArraySize(itemList) {
      ArrayPush(gameItemList, itemList[i]);
      i += 1;
    };
    return gameItemList;
  }

  public final func BuyItemFromVendor(itemData: wref<gameItemData>, amount: Int32, opt requestId: Int32) -> Void {
    let buyRequest: ref<BuyRequest>;
    let buyRequestData: TransactionRequestData;
    let uiSys: ref<UISystem> = GameInstance.GetUISystem(this.m_VendorObject.GetGame());
    let evt: ref<VendorBoughtItemEvent> = new VendorBoughtItemEvent();
    ArrayPush(evt.items, itemData.GetID());
    uiSys.QueueEvent(evt);
    buyRequestData.itemID = itemData.GetID();
    buyRequestData.quantity = amount;
    buyRequest = new BuyRequest();
    buyRequest.owner = this.m_VendorObject;
    buyRequest.requestID = requestId;
    ArrayPush(buyRequest.items, buyRequestData);
    MarketSystem.GetInstance(this.m_VendorObject.GetGame()).QueueRequest(buyRequest);
  }

  public final func BuybackItemFromVendor(itemData: wref<gameItemData>, amount: Int32, opt requestId: Int32) -> Void {
    let buybackRequest: ref<BuybackRequest>;
    let buybackRequestData: TransactionRequestData;
    let uiSys: ref<UISystem> = GameInstance.GetUISystem(this.m_VendorObject.GetGame());
    let evt: ref<VendorBoughtItemEvent> = new VendorBoughtItemEvent();
    ArrayPush(evt.items, itemData.GetID());
    uiSys.QueueEvent(evt);
    buybackRequestData.itemID = itemData.GetID();
    buybackRequestData.quantity = amount;
    buybackRequest = new BuybackRequest();
    buybackRequest.owner = this.m_VendorObject;
    buybackRequest.requestID = requestId;
    ArrayPush(buybackRequest.items, buybackRequestData);
    MarketSystem.GetInstance(this.m_VendorObject.GetGame()).QueueRequest(buybackRequest);
  }

  public final func SellItemToVendor(itemData: wref<gameItemData>, amount: Int32, opt requestId: Int32) -> Void {
    let amounts: array<Int32>;
    let itemsData: array<wref<gameItemData>>;
    ArrayPush(itemsData, itemData);
    ArrayPush(amounts, amount);
    this.SellItemsToVendor(itemsData, amounts, requestId);
  }

  public final func SellItemsToVendor(itemsData: array<wref<gameItemData>>, amounts: array<Int32>, opt requestId: Int32) -> Void {
    let sellRequestData: TransactionRequestData;
    let sellRequest: ref<SellRequest> = new SellRequest();
    sellRequest.owner = this.m_VendorObject;
    sellRequest.requestID = requestId;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(itemsData);
    while i < limit {
      sellRequestData.itemID = itemsData[i].GetID();
      sellRequestData.quantity = amounts[i];
      sellRequestData.powerLevel = itemsData[i].GetStatValueByType(gamedataStatType.PowerLevel);
      ArrayPush(sellRequest.items, sellRequestData);
      i += 1;
    };
    MarketSystem.GetInstance(this.m_VendorObject.GetGame()).QueueRequest(sellRequest);
  }

  public final func TransferItem(source: wref<GameObject>, target: wref<GameObject>, itemData: wref<gameItemData>, amount: Int32) -> Void {
    let transactionSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_VendorObject.GetGame());
    transactionSys.TransferItem(source, target, itemData.GetID(), amount);
  }

  public final func GetBuyingPrice(itemID: ItemID) -> Int32 {
    return MarketSystem.GetBuyPrice(this.m_VendorObject, itemID);
  }

  public final func GetSellingPrice(itemID: ItemID) -> Int32 {
    return RPGManager.CalculateSellPrice(this.m_VendorObject.GetGame(), this.m_VendorObject, itemID);
  }

  public final func Checkout(andEquip: Bool) -> Bool {
    let itemsToBuy: array<ItemID>;
    let itemsToSell: array<ItemID>;
    this.GetItemIDsFromCart(itemsToBuy, this.m_BuyingCart);
    this.GetItemIDsFromCart(itemsToSell, this.m_SellingCart);
    this.ClearBuyingCart();
    this.ClearSellingCart();
    return false;
  }

  public final func ClearCart() -> Void {
    this.ClearBuyingCart();
    this.ClearSellingCart();
  }

  private final func ClearBuyingCart() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_BuyingCart) {
      this.BuyItemFromVendor(this.m_BuyingCart[i].itemData, this.m_BuyingCart[i].amount);
      i += 1;
    };
    ArrayClear(this.m_BuyingCart);
  }

  private final func ClearSellingCart() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_SellingCart) {
      this.SellItemToVendor(this.m_SellingCart[i].itemData, this.m_SellingCart[i].amount);
      i += 1;
    };
    ArrayClear(this.m_SellingCart);
  }

  public final func NumItemsInBuyingCart() -> Int32 {
    return ArraySize(this.m_BuyingCart);
  }

  public final func NumItemsInSellingCart() -> Int32 {
    return ArraySize(this.m_SellingCart);
  }

  public final func NumItemsInAllCarts() -> Int32 {
    return this.NumItemsInBuyingCart() + this.NumItemsInSellingCart();
  }

  public final func TotalNumItemsInAllCarts() -> Int32 {
    return this.GetTotalAmountInCart(this.m_BuyingCart) + this.GetTotalAmountInCart(this.m_SellingCart);
  }

  public final func AddToBuyingCart(itemToAdd: wref<gameItemData>) -> ECartOperationResult {
    let returnValue: ECartOperationResult = this.CanAddToBuyingCart(itemToAdd);
    if Equals(returnValue, ECartOperationResult.Success) {
      this.AddToCart(itemToAdd, this.m_BuyingCart);
    };
    return returnValue;
  }

  public final func AddToSellingCart(itemToAdd: wref<gameItemData>) -> ECartOperationResult {
    let returnValue: ECartOperationResult = this.CanAddToSellingCart(itemToAdd);
    if Equals(returnValue, ECartOperationResult.Success) {
      this.AddToCart(itemToAdd, this.m_SellingCart);
    };
    return returnValue;
  }

  public final func RemoveFromBuyingCart(itemToRemove: wref<gameItemData>) -> ECartOperationResult {
    if this.RemoveFromCart(itemToRemove, this.m_BuyingCart) {
      return ECartOperationResult.Success;
    };
    return ECartOperationResult.NotInCart;
  }

  public final func RemoveFromSellingCart(itemToRemove: wref<gameItemData>) -> ECartOperationResult {
    if this.RemoveFromCart(itemToRemove, this.m_SellingCart) {
      return ECartOperationResult.Success;
    };
    return ECartOperationResult.NotInCart;
  }

  private final func CanAddToBuyingCart(itemToAdd: wref<gameItemData>) -> ECartOperationResult {
    let itemQuantity: Int32 = itemToAdd.GetQuantity();
    if itemQuantity == 0 {
      return ECartOperationResult.NoItems;
    };
    if this.GetAmountInBuiyngCart(itemToAdd) >= itemQuantity {
      return ECartOperationResult.AllItems;
    };
    return ECartOperationResult.Success;
  }

  private final func CanAddToSellingCart(itemToAdd: wref<gameItemData>) -> ECartOperationResult {
    let itemQuantity: Int32 = itemToAdd.GetQuantity();
    if itemQuantity == 0 {
      return ECartOperationResult.NoItems;
    };
    if this.GetAmountInSellingCart(itemToAdd) >= itemQuantity {
      return ECartOperationResult.AllItems;
    };
    if itemToAdd.HasTag(n"Quest") {
      return ECartOperationResult.QuestItem;
    };
    return ECartOperationResult.Success;
  }

  public final func GetAmountInBuiyngCart(item: wref<gameItemData>) -> Int32 {
    return this.GetAmountInCart(item, this.m_BuyingCart);
  }

  public final func GetAmountInSellingCart(item: wref<gameItemData>) -> Int32 {
    return this.GetAmountInCart(item, this.m_SellingCart);
  }

  public final func GetItemDataFromBuyingCart(out items: array<wref<gameItemData>>) -> Void {
    return this.GetItemDataFromCart(items, this.m_BuyingCart);
  }

  public final func GetItemDataFromSellingCart(out items: array<wref<gameItemData>>) -> Void {
    return this.GetItemDataFromCart(items, this.m_SellingCart);
  }

  public final func GetTimeToCompletePurchase() -> Float {
    return this.m_TimeToCompletePurchase;
  }

  public final func GetPriceInBuyingCart() -> Int32 {
    let price: Int32 = 0;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_BuyingCart);
    while i < limit {
      price += this.m_BuyingCart[i].amount * this.GetBuyingPrice(this.m_BuyingCart[i].itemData.GetID());
      i += 1;
    };
    return price;
  }

  public final func GetPriceInSellingCart() -> Int32 {
    let price: Int32 = 0;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_SellingCart);
    while i < limit {
      price += this.m_BuyingCart[i].amount * this.GetSellingPrice(this.m_SellingCart[i].itemData.GetID());
      i += 1;
    };
    return price;
  }

  private final func AddToCart(itemToAdd: wref<gameItemData>, out cart: array<VendorShoppingCartItem>) -> Void {
    let i: Int32;
    let limit: Int32;
    let quantityToAdd: Int32 = itemToAdd.GetQuantity();
    if quantityToAdd > 0 {
      i = 0;
      limit = ArraySize(cart);
      while i < limit {
        if cart[i].itemData == itemToAdd {
          if cart[i].amount < quantityToAdd {
            cart[i].amount += 1;
            return;
          };
        };
        i += 1;
      };
      ArrayPush(cart, new VendorShoppingCartItem(itemToAdd, 1));
    };
  }

  private final func RemoveFromCart(itemToAdd: wref<gameItemData>, out cart: array<VendorShoppingCartItem>) -> Bool {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(cart);
    while i < limit {
      if cart[i].itemData == itemToAdd {
        if cart[i].amount > 0 {
          cart[i].amount -= 1;
          if cart[i].amount == 0 {
            ArrayErase(cart, i);
          };
          return true;
        };
        return false;
      };
      i += 1;
    };
    return false;
  }

  private final func GetTotalAmountInCart(cart: array<VendorShoppingCartItem>) -> Int32 {
    let outValue: Int32 = 0;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(cart);
    while i < limit {
      outValue += cart[i].amount;
      i += 1;
    };
    return outValue;
  }

  private final func GetAmountInCart(itemToAdd: wref<gameItemData>, cart: array<VendorShoppingCartItem>) -> Int32 {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(cart);
    while i < limit {
      if cart[i].itemData == itemToAdd {
        return cart[i].amount;
      };
      i += 1;
    };
    return 0;
  }

  private final func GetItemDataFromCart(out items: array<wref<gameItemData>>, cart: array<VendorShoppingCartItem>) -> Void {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(cart);
    while i < limit {
      if cart[i].amount > 0 {
        ArrayPush(items, cart[i].itemData);
      };
      i += 1;
    };
  }

  public final func GetItemIDsFromCart(out itemIds: array<ItemID>, cart: array<VendorShoppingCartItem>) -> Void {
    let j: Int32;
    let limitJ: Int32;
    let i: Int32 = 0;
    let limitI: Int32 = ArraySize(cart);
    while i < limitI {
      j = 0;
      limitJ = cart[i].amount;
      while j < limitJ {
        ArrayPush(itemIds, cart[i].itemData.GetID());
        j += 1;
      };
      i += 1;
    };
  }

  public final func ProcessTooltipsData(vendorMode: EVendorMode, tooltipsData: script_ref<array<ref<ATooltipData>>>) -> Void {
    let itemTooltipData: ref<InventoryTooltipData>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(Deref(tooltipsData));
    while i < limit {
      itemTooltipData = Deref(tooltipsData)[i] as InventoryTooltipData;
      if IsDefined(itemTooltipData) {
        if itemTooltipData.isEquipped {
          itemTooltipData.price = 0.00;
        } else {
          if Equals(vendorMode, EVendorMode.BuyItems) {
            itemTooltipData.price = Cast(this.GetBuyingPrice(itemTooltipData.itemID));
          } else {
            if Equals(vendorMode, EVendorMode.SellItems) {
              itemTooltipData.price = Cast(this.GetSellingPrice(itemTooltipData.itemID));
            };
          };
        };
      };
      i += 1;
    };
  }
}
