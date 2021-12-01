
public class MarketSystem extends IMarketSystem {

  private persistent let m_vendors: array<ref<Vendor>>;

  private let m_vendingMachinesVendors: array<ref<Vendor>>;

  private func OnDetach() -> Void {
    let i: Int32;
    let vendor: ref<Vendor>;
    this.ClearVendorHashMap();
    i = ArraySize(this.m_vendors) - 1;
    while i >= 0 {
      vendor = this.m_vendors[i];
      if Equals(vendor.GetVendorType(), gamedataVendorType.VendingMachine) {
        ArrayRemove(this.m_vendors, vendor);
      };
      i -= 1;
    };
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    let i: Int32;
    let successfullyMapped: Bool;
    let vendor: ref<Vendor>;
    this.ClearVendorHashMap();
    i = ArraySize(this.m_vendors) - 1;
    while i >= 0 {
      vendor = this.m_vendors[i];
      vendor.OnRestored(this.GetGameInstance());
      if Equals(vendor.GetVendorType(), gamedataVendorType.VendingMachine) {
        ArrayRemove(this.m_vendors, vendor);
      } else {
        successfullyMapped = this.AddVendorHashMap(PersistentID.ExtractEntityID(vendor.GetVendorPersistentID()), vendor.GetVendorTweakID(), vendor);
        if !successfullyMapped {
          ArrayRemove(this.m_vendors, vendor);
        };
      };
      i -= 1;
    };
  }

  private final func GetVendor(vendorObject: ref<GameObject>) -> ref<Vendor> {
    let vendor: ref<IScriptable> = this.GetVendorHashMap(vendorObject.GetEntityID());
    if IsDefined(vendor) {
      return vendor as Vendor;
    };
    return this.AddVendor(vendorObject);
  }

  private final func GetVendorByTDBID(vendorDataID: TweakDBID) -> ref<Vendor> {
    let vendor: ref<IScriptable> = this.GetVendorTBIDHashMap(vendorDataID);
    if IsDefined(vendor) {
      return vendor as Vendor;
    };
    return null;
  }

  private final func AddVendor(vendorObject: ref<GameObject>) -> ref<Vendor> {
    let vendor: ref<Vendor>;
    let vendorID: TweakDBID = MarketSystem.GetVendorID(vendorObject);
    let vendorRecord: wref<Vendor_Record> = TweakDBInterface.GetVendorRecord(vendorID);
    if IsDefined(vendorRecord) {
      vendor = new Vendor();
      vendor.Initialize(this.GetGameInstance(), vendorID, vendorObject);
      vendor.SetPersistentID(vendorObject.GetPersistentID());
      this.AddVendorHashMap(vendorObject.GetEntityID(), vendor.GetVendorTweakID(), vendor);
      if Equals(vendor.GetVendorType(), gamedataVendorType.VendingMachine) {
        ArrayPush(this.m_vendingMachinesVendors, vendor);
      } else {
        ArrayPush(this.m_vendors, vendor);
      };
      return vendor;
    };
    return null;
  }

  public final static func IsAccessible(player: wref<PlayerPuppet>, vendorID: TweakDBID) -> Bool {
    let accessPrereqs: array<wref<IPrereq_Record>>;
    TweakDBInterface.GetVendorRecord(vendorID).AccessPrereqs(accessPrereqs);
    return RPGManager.CheckPrereqs(accessPrereqs, player);
  }

  public final static func IsVisibleOnMap(player: wref<PlayerPuppet>, vendorID: TweakDBID) -> Bool {
    let mapVisibilityPrereqs: array<wref<IPrereq_Record>>;
    TweakDBInterface.GetVendorRecord(vendorID).MapVisibilityPrereqs(mapVisibilityPrereqs);
    return RPGManager.CheckPrereqs(mapVisibilityPrereqs, player);
  }

  public final static func GetBuyPrice(vendorObject: wref<GameObject>, itemID: ItemID) -> Int32 {
    let marketSystem: ref<MarketSystem> = MarketSystem.GetInstance(vendorObject.GetGame());
    let vendor: ref<Vendor> = marketSystem.GetVendor(vendorObject);
    return RPGManager.CalculateBuyPrice(vendorObject.GetGame(), vendorObject, itemID, vendor.GetPriceMultiplier());
  }

  public final static func GetBuyPrice(game: GameInstance, vendorID: EntityID, itemID: ItemID) -> Int32 {
    let vendorObject: wref<GameObject> = GameInstance.FindEntityByID(game, vendorID) as GameObject;
    return MarketSystem.GetBuyPrice(vendorObject, itemID);
  }

  public final static func Money() -> ItemID {
    return ItemID.FromTDBID(t"Items.money");
  }

  public final static func OnVendorMenuOpen(vendorObject: ref<GameObject>) -> Void {
    let marketSystem: ref<MarketSystem> = MarketSystem.GetInstance(vendorObject.GetGame());
    let vendor: ref<Vendor> = marketSystem.GetVendor(vendorObject);
    vendor.OnVendorMenuOpen();
  }

  public final static func GetVendorMoney(vendorObject: wref<GameObject>) -> Int32 {
    let gameInstance: GameInstance = vendorObject.GetGame();
    let marketSystem: ref<MarketSystem> = MarketSystem.GetInstance(gameInstance);
    let vendor: ref<Vendor> = marketSystem.GetVendor(vendorObject);
    return vendor.GetMoney();
  }

  public final static func GetVendorItemsForSale(vendorObject: wref<GameObject>, checkPlayerCanBuy: Bool) -> array<SItemStack> {
    let gameInstance: GameInstance = vendorObject.GetGame();
    let marketSystem: ref<MarketSystem> = MarketSystem.GetInstance(gameInstance);
    let vendor: ref<Vendor> = marketSystem.GetVendor(vendorObject);
    return vendor.GetItemsForSale(checkPlayerCanBuy);
  }

  public final static func GetVendorCyberwareForSale(vendorObject: wref<GameObject>, checkPlayerCanBuy: Bool) -> array<SItemStack> {
    let gameInstance: GameInstance = vendorObject.GetGame();
    let marketSystem: ref<MarketSystem> = MarketSystem.GetInstance(gameInstance);
    let vendor: ref<Vendor> = marketSystem.GetVendor(vendorObject);
    return vendor.GetCyberwareForSale(checkPlayerCanBuy);
  }

  public final static func GetItemsPlayerCanSell(vendorObject: wref<GameObject>, allowQuestItems: Bool, excludeEquipped: Bool) -> array<SItemStack> {
    let gameInstance: GameInstance = vendorObject.GetGame();
    let marketSystem: ref<MarketSystem> = MarketSystem.GetInstance(gameInstance);
    let vendor: ref<Vendor> = marketSystem.GetVendor(vendorObject);
    return vendor.GetItemsPlayerCanSell(allowQuestItems, excludeEquipped);
  }

  public final static func CanPlayerSellItem(vendorObject: wref<GameObject>, itemID: ItemID, allowQuestItems: Bool, excludeEquipped: Bool) -> Bool {
    return MarketSystem.GetInstance(vendorObject.GetGame()).GetVendor(vendorObject).PlayerCanSell(itemID, allowQuestItems, excludeEquipped);
  }

  public final static func GetVendorID(vendor: wref<GameObject>) -> TweakDBID {
    let dropPoint: ref<DropPoint>;
    let puppet: wref<ScriptedPuppet>;
    let tweakDBId: TweakDBID;
    let vendorRecord: ref<Character_Record>;
    let vendingMachine: ref<VendingMachine> = vendor as VendingMachine;
    if IsDefined(vendingMachine) {
      return vendingMachine.GetVendorID();
    };
    dropPoint = vendor as DropPoint;
    if IsDefined(dropPoint) {
      return TDBID.Create((dropPoint.GetDevicePS() as DropPointControllerPS).GetVendorRecordPath());
    };
    puppet = vendor as ScriptedPuppet;
    if IsDefined(puppet) {
      vendorRecord = TweakDBInterface.GetCharacterRecord(puppet.GetRecordID());
      if IsDefined(vendorRecord) && IsDefined(vendorRecord.VendorID()) {
        return vendorRecord.VendorID().GetID();
      };
    };
    return tweakDBId;
  }

  public final static func GetInstance(gameInstance: GameInstance) -> ref<MarketSystem> {
    return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"MarketSystem") as MarketSystem;
  }

  private final func OnAttachVendorRequest(request: ref<AttachVendorRequest>) -> Void {
    let vendor: ref<Vendor> = this.GetVendor(request.owner);
    vendor.OnAttach(request.owner);
  }

  private final func OnBuyRequest(request: ref<BuyRequest>) -> Void {
    let itemStack: SItemStack;
    let itemsStack: array<SItemStack>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(request.items);
    while i < limit {
      itemStack.itemID = request.items[i].itemID;
      itemStack.quantity = request.items[i].quantity;
      ArrayPush(itemsStack, itemStack);
      i += 1;
    };
    this.GetVendor(request.owner).BuyItemsFromVendor(itemsStack, request.requestID);
  }

  private final func OnBuybackRequest(request: ref<BuybackRequest>) -> Void {
    let itemStack: SItemStack;
    let itemsStack: array<SItemStack>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(request.items);
    while i < limit {
      itemStack.itemID = request.items[i].itemID;
      itemStack.quantity = request.items[i].quantity;
      ArrayPush(itemsStack, itemStack);
      i += 1;
    };
    this.GetVendor(request.owner).BuybackItemsFromVendor(itemsStack, request.requestID);
  }

  private final func OnSellRequest(request: ref<SellRequest>) -> Void {
    let itemStack: SItemStack;
    let itemsStack: array<SItemStack>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(request.items);
    while i < limit {
      itemStack.itemID = request.items[i].itemID;
      itemStack.quantity = request.items[i].quantity;
      itemStack.powerLevel = RoundMath(request.items[i].powerLevel * 100.00);
      ArrayPush(itemsStack, itemStack);
      i += 1;
    };
    this.GetVendor(request.owner).SellItemsToVendor(itemsStack, request.requestID);
  }

  private final func OnDispenseRequest(request: ref<DispenseRequest>) -> Void {
    let buyPrice: Int32;
    let playerMoney: Int32;
    let tSystem: ref<TransactionSystem>;
    if request.shouldPay {
      tSystem = GameInstance.GetTransactionSystem(this.GetGameInstance());
      playerMoney = tSystem.GetItemQuantity(GetPlayer(this.GetGameInstance()), MarketSystem.Money());
      buyPrice = MarketSystem.GetBuyPrice(request.owner, request.itemID);
      if playerMoney < buyPrice {
        return;
      };
      tSystem.RemoveItem(GetPlayer(this.GetGameInstance()), MarketSystem.Money(), buyPrice);
    };
    this.GetVendor(request.owner).DispenseItemFromVendor(request.position, request.itemID);
  }

  private final func OnAddItemToStockRequest(request: ref<AddItemToVendorRequest>) -> Void {
    let i: Int32;
    let itemStack: SItemStack;
    let transactionSys: ref<TransactionSystem>;
    let vendor: ref<Vendor> = this.GetVendorByTDBID(request.vendorID);
    if TweakDBInterface.GetItemRecord(request.itemToAddID).IsSingleInstance() {
      itemStack.itemID = ItemID.FromTDBID(request.itemToAddID);
      itemStack.quantity = request.quantity;
      vendor.AddItemsToStock(itemStack);
      transactionSys.GiveItem(vendor.GetVendorObject(), itemStack.itemID, itemStack.quantity);
    } else {
      i = 0;
      while i < request.quantity {
        itemStack.itemID = ItemID.FromTDBID(request.itemToAddID);
        itemStack.quantity = 1;
        vendor.AddItemsToStock(itemStack);
        transactionSys.GiveItem(vendor.GetVendorObject(), itemStack.itemID, 1);
        i += 1;
      };
    };
  }

  private final func OnSetPriceModifierRequest(request: ref<SetVendorPriceMultiplierRequest>) -> Void {
    let vendor: ref<Vendor> = this.GetVendorByTDBID(request.vendorID);
    vendor.SetPriceMultiplier(request.multiplier);
  }
}

public class AddItemToVendorRequest extends ScriptableSystemRequest {

  @attrib(customEditor, "TweakDBGroupInheritance;Vendor")
  public edit let vendorID: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;Item")
  public edit let itemToAddID: TweakDBID;

  @attrib(rangeMax, "99999")
  @attrib(rangeMin, "1")
  @default(AddItemToVendorRequest, 1)
  public edit let quantity: Int32;

  public final func GetFriendlyDescription() -> String {
    return "Add Item To Vendor";
  }
}

public class SetVendorPriceMultiplierRequest extends ScriptableSystemRequest {

  @attrib(customEditor, "TweakDBGroupInheritance;Vendor")
  public edit let vendorID: TweakDBID;

  @attrib(rangeMax, "10")
  @attrib(rangeMin, "0")
  @default(SetVendorPriceMultiplierRequest, 1)
  public edit let multiplier: Float;

  public final func GetFriendlyDescription() -> String {
    return "Set Vendor Price Modifier";
  }
}
