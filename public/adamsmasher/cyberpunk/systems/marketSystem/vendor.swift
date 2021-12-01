
public class Vendor extends IScriptable {

  public let m_gameInstance: GameInstance;

  public let m_vendorObject: wref<GameObject>;

  private persistent let m_tweakID: TweakDBID;

  private persistent let m_lastInteractionTime: Float;

  private persistent let m_stock: array<SItemStack>;

  @default(Vendor, 1)
  private persistent let m_priceMultiplier: Float;

  private persistent let m_vendorPersistentID: PersistentID;

  @default(Vendor, false)
  private let m_stockInit: Bool;

  @default(Vendor, false)
  private let m_inventoryInit: Bool;

  @default(Vendor, false)
  private let m_inventoryReinitWithPlayerStats: Bool;

  private let m_vendorRecord: wref<Vendor_Record>;

  public final func Initialize(gameInstance: GameInstance, vendorID: TweakDBID, vendorObject: ref<GameObject>) -> Void {
    this.m_gameInstance = gameInstance;
    this.m_tweakID = vendorID;
    this.m_vendorObject = vendorObject;
    this.m_vendorRecord = TweakDBInterface.GetVendorRecord(this.m_tweakID);
  }

  public final func OnAttach(owner: wref<GameObject>) -> Void {
    this.m_vendorObject = owner;
    this.m_vendorPersistentID = owner.GetPersistentID();
    this.m_vendorRecord = TweakDBInterface.GetVendorRecord(this.m_tweakID);
    this.m_inventoryInit = false;
    this.m_inventoryReinitWithPlayerStats = false;
  }

  public final func OnRestored(gameInstance: GameInstance) -> Void {
    this.m_gameInstance = gameInstance;
    this.m_stockInit = ArraySize(this.m_stock) > 0;
    this.m_vendorRecord = TweakDBInterface.GetVendorRecord(this.m_tweakID);
  }

  public final func GetStock() -> array<SItemStack> {
    this.LazyInitStock();
    return this.m_stock;
  }

  private final func LazyInitStock() -> Void {
    if !this.m_stockInit {
      this.InitializeStock();
    };
  }

  public final func GetMaxItemStacksPerVendor() -> Int32 {
    return 40;
  }

  public final func GetVendorPersistentID() -> PersistentID {
    return this.m_vendorPersistentID;
  }

  public final func GetVendorTweakID() -> TweakDBID {
    return this.m_tweakID;
  }

  public final const func GetVendorType() -> gamedataVendorType {
    if !IsDefined(this.m_vendorRecord) || !IsDefined(this.m_vendorRecord.VendorType()) {
      return gamedataVendorType.Invalid;
    };
    return this.m_vendorRecord.VendorType().Type();
  }

  public final func GetVendorRecord() -> ref<Vendor_Record> {
    return this.m_vendorRecord;
  }

  public final func GetVendorObject() -> wref<GameObject> {
    return this.m_vendorObject;
  }

  public final const func GetPriceMultiplier() -> Float {
    return this.m_priceMultiplier;
  }

  public final func GetItemsForSale(checkPlayerCanBuy: Bool) -> array<SItemStack> {
    let availableItems: array<SItemStack>;
    let canBuy: Bool;
    let i: Int32;
    let tags: array<CName>;
    this.LazyInitStock();
    this.FillVendorInventory(true);
    i = 0;
    while i < ArraySize(this.m_stock) {
      tags = RPGManager.GetItemRecord(this.m_stock[i].itemID).Tags();
      if !ArrayContains(tags, n"Cyberware") {
        canBuy = !checkPlayerCanBuy || this.PlayerCanBuy(this.m_stock[i]);
        if canBuy {
          ArrayPush(availableItems, this.m_stock[i]);
        };
      };
      i += 1;
    };
    return availableItems;
  }

  public final func GetMoney() -> Int32 {
    let transactionSystem: ref<TransactionSystem>;
    this.LazyInitStock();
    this.FillVendorInventory(true);
    transactionSystem = GameInstance.GetTransactionSystem(this.m_gameInstance);
    return transactionSystem.GetItemQuantity(this.m_vendorObject, MarketSystem.Money());
  }

  public final func GetCyberwareForSale(checkPlayerCanBuy: Bool) -> array<SItemStack> {
    let availableItems: array<SItemStack>;
    let canBuy: Bool;
    let i: Int32;
    let tags: array<CName>;
    this.LazyInitStock();
    this.FillVendorInventory(true);
    i = 0;
    while i < ArraySize(this.m_stock) {
      tags = RPGManager.GetItemRecord(this.m_stock[i].itemID).Tags();
      if ArrayContains(tags, n"Cyberware") && !GameInstance.GetTransactionSystem(this.m_gameInstance).HasItem(GetPlayer(this.m_gameInstance), ItemID.CreateQuery(ItemID.GetTDBID(this.m_stock[i].itemID))) {
        canBuy = !checkPlayerCanBuy || this.PlayerCanBuy(this.m_stock[i]);
        if canBuy {
          ArrayPush(availableItems, this.m_stock[i]);
        };
      };
      i += 1;
    };
    return availableItems;
  }

  public final func GetItemsPlayerCanSell(allowQuestItems: Bool, excludeEquipped: Bool) -> array<SItemStack> {
    let availableItems: array<SItemStack>;
    let i: Int32;
    let itemStack: SItemStack;
    let playerItems: array<wref<gameItemData>>;
    GameInstance.GetTransactionSystem(this.m_gameInstance).GetItemList(GetPlayer(this.m_gameInstance), playerItems);
    i = 0;
    while i < ArraySize(playerItems) {
      if this.PlayerCanSell(playerItems[i].GetID(), allowQuestItems, excludeEquipped) {
        itemStack.itemID = playerItems[i].GetID();
        itemStack.quantity = playerItems[i].GetQuantity();
        ArrayPush(availableItems, itemStack);
      };
      i += 1;
    };
    return availableItems;
  }

  public final func OnVendorMenuOpen() -> Void {
    this.LazyInitStock();
    this.FillVendorInventory(true);
    if !this.m_inventoryReinitWithPlayerStats {
      GameInstance.GetTransactionSystem(this.m_gameInstance).ReinitializeStatsOnEntityItems(this.m_vendorObject);
      this.m_inventoryReinitWithPlayerStats = true;
    };
    this.m_lastInteractionTime = GameInstance.GetTimeSystem(this.m_gameInstance).GetGameTimeStamp();
  }

  public final func SetPriceMultiplier(value: Float) -> Void {
    this.m_priceMultiplier = value;
  }

  public final func SetPersistentID(persistentID: PersistentID) -> Void {
    this.m_vendorPersistentID = persistentID;
  }

  public final const func PlayerCanSell(itemID: ItemID, allowQuestItems: Bool, excludeEquipped: Bool) -> Bool {
    let hasInverseTag: Bool;
    let i: Int32;
    let inverseFilterTags: array<CName>;
    let itemData: wref<gameItemData>;
    let player: wref<GameObject>;
    let filterTags: array<CName> = this.m_vendorRecord.CustomerFilterTags();
    if allowQuestItems {
      ArrayRemove(filterTags, n"Quest");
    };
    inverseFilterTags = TDB.GetCNameArray(this.m_vendorRecord.GetID() + t".customerInverseFilterTags");
    player = GetPlayer(this.m_gameInstance);
    itemData = GameInstance.GetTransactionSystem(this.m_gameInstance).GetItemData(player, itemID);
    if excludeEquipped && EquipmentSystem.GetInstance(player).IsEquipped(player, itemID) {
      return false;
    };
    if ArraySize(inverseFilterTags) > 0 {
      i = 0;
      while i < ArraySize(inverseFilterTags) {
        if itemData.HasTag(inverseFilterTags[i]) {
          hasInverseTag = true;
        } else {
          i += 1;
        };
      };
      if !hasInverseTag {
        return false;
      };
    };
    i = 0;
    while i < ArraySize(filterTags) {
      if itemData.HasTag(filterTags[i]) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  private final const func PlayerCanBuy(itemStack: script_ref<SItemStack>) -> Bool {
    let availablePrereq: wref<IPrereq_Record>;
    let filterTags: array<CName>;
    let i: Int32;
    let itemData: wref<gameItemData>;
    let viewPrereqs: array<wref<IPrereq_Record>>;
    let vendorItem: wref<VendorItem_Record> = TweakDBInterface.GetVendorItemRecord(Deref(itemStack).vendorItemID);
    vendorItem.GenerationPrereqs(viewPrereqs);
    if RPGManager.CheckPrereqs(viewPrereqs, GetPlayer(this.m_gameInstance)) {
      filterTags = this.m_vendorRecord.VendorFilterTags();
      itemData = GameInstance.GetTransactionSystem(this.m_gameInstance).GetItemData(this.m_vendorObject, Deref(itemStack).itemID);
      availablePrereq = vendorItem.AvailabilityPrereq();
      Deref(itemStack).requirement = RPGManager.GetStockItemRequirement(vendorItem);
      if IsDefined(availablePrereq) {
        Deref(itemStack).isAvailable = RPGManager.CheckPrereq(availablePrereq, GetPlayer(this.m_gameInstance));
      };
      i = 0;
      while i < ArraySize(filterTags) {
        if IsDefined(itemData) && itemData.HasTag(filterTags[i]) {
          return false;
        };
        i += 1;
      };
      return true;
    };
    return false;
  }

  private final func FillVendorInventory(allowRegeneration: Bool) -> Void {
    let forceQuality: CName;
    let i: Int32;
    let itemData: wref<gameItemData>;
    let itemRecord: wref<Item_Record>;
    let ownerNPC: ref<NPCPuppet>;
    let powerLevelMod: ref<gameStatModifierData>;
    let qualityMod: ref<gameStatModifierData>;
    let statsSystem: ref<StatsSystem>;
    let transactionSystem: ref<TransactionSystem>;
    if allowRegeneration && this.ShouldRegenerateStock() {
      this.RegenerateStock();
    } else {
      if this.m_inventoryInit {
        return;
      };
    };
    ownerNPC = this.m_vendorObject as NPCPuppet;
    if IsDefined(ownerNPC) {
      if !ScriptedPuppet.IsActive(ownerNPC) {
        return;
      };
    };
    this.m_inventoryInit = true;
    this.m_inventoryReinitWithPlayerStats = false;
    GameInstance.GetTransactionSystem(this.m_gameInstance).RemoveAllItems(this.m_vendorObject);
    if IsDefined(this.m_vendorObject) && IsDefined(this.m_vendorRecord) && IsDefined(this.m_vendorRecord.VendorType()) && NotEquals(this.m_vendorRecord.VendorType().Type(), gamedataVendorType.VendingMachine) {
      transactionSystem = GameInstance.GetTransactionSystem(this.m_vendorObject.GetGame());
      statsSystem = GameInstance.GetStatsSystem(this.m_vendorObject.GetGame());
      i = 0;
      while i < ArraySize(this.m_stock) {
        transactionSystem.GiveItem(this.m_vendorObject, this.m_stock[i].itemID, this.m_stock[i].quantity);
        itemData = transactionSystem.GetItemData(this.m_vendorObject, this.m_stock[i].itemID);
        itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.m_stock[i].itemID));
        if !itemRecord.IsSingleInstance() && !itemData.HasTag(n"Cyberware") {
          statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel, true);
          powerLevelMod = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gameStatModifierType.Additive, Cast(this.m_stock[i].powerLevel) / 100.00);
          statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), powerLevelMod);
          forceQuality = TweakDBInterface.GetCName(this.m_stock[i].vendorItemID + t".forceQuality", n"");
          if IsNameValid(forceQuality) {
            RPGManager.ForceItemQuality(this.m_vendorObject, itemData, forceQuality);
          } else {
            if Equals(RPGManager.GetItemRecord(this.m_stock[i].itemID).Quality().Type(), gamedataQuality.Random) && itemData.GetStatValueByType(gamedataStatType.Quality) == 0.00 {
              statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.Quality, true);
              qualityMod = RPGManager.CreateStatModifier(gamedataStatType.Quality, gameStatModifierType.Additive, 1.00);
              statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), qualityMod);
            };
          };
        };
        i += 1;
      };
    };
  }

  private final func InitializeStock() -> Void {
    let i: Int32;
    let itemPool: array<wref<VendorItem_Record>>;
    let itemStacks: array<SItemStack>;
    let j: Int32;
    let player: ref<PlayerPuppet> = GetPlayer(this.m_gameInstance);
    this.m_stockInit = true;
    this.m_vendorRecord.ItemStock(itemPool);
    i = 0;
    while i < ArraySize(itemPool) {
      itemStacks = this.CreateStacksFromVendorItem(itemPool[i], player);
      j = 0;
      while j < ArraySize(itemStacks) {
        ArrayPush(this.m_stock, itemStacks[j]);
        j += 1;
      };
      i += 1;
    };
  }

  private final func RegenerateStock() -> Void {
    let circularIndex: Int32;
    let continueLoop: Bool;
    let dynamicStock: array<SItemStack>;
    let i: Int32;
    let itemPool: array<wref<VendorItem_Record>>;
    let itemPoolIndex: Int32;
    let itemPoolSize: Int32;
    let itemStacks: array<SItemStack>;
    let j: Int32;
    let newStock: array<SItemStack>;
    let player: ref<PlayerPuppet> = GetPlayer(this.m_gameInstance);
    this.LazyInitStock();
    i = 0;
    while i < ArraySize(this.m_stock) {
      if !this.ShouldRegenerateItem(ItemID.GetTDBID(this.m_stock[i].itemID)) {
        ArrayPush(newStock, this.m_stock[i]);
      };
      i += 1;
    };
    dynamicStock = this.CreateDynamicStockFromPlayerProgression(GetPlayer(this.m_gameInstance));
    i = 0;
    while i < ArraySize(dynamicStock) && ArraySize(newStock) < this.GetMaxItemStacksPerVendor() {
      ArrayPush(newStock, dynamicStock[i]);
      i += 1;
    };
    this.m_vendorRecord.ItemStock(itemPool);
    itemPoolSize = ArraySize(itemPool);
    continueLoop = ArraySize(newStock) < this.GetMaxItemStacksPerVendor();
    circularIndex = RandRange(0, itemPoolSize);
    i = 0;
    while i < itemPoolSize && continueLoop {
      itemPoolIndex = circularIndex % itemPoolSize;
      if this.ShouldRegenerateItem(itemPool[itemPoolIndex].Item().GetID()) {
        itemStacks = this.CreateStacksFromVendorItem(itemPool[itemPoolIndex], player);
        j = 0;
        while j < ArraySize(itemStacks) && continueLoop {
          ArrayPush(newStock, itemStacks[j]);
          continueLoop = ArraySize(newStock) < this.GetMaxItemStacksPerVendor();
          j += 1;
        };
      };
      circularIndex += 1;
      i += 1;
    };
    this.m_stock = newStock;
  }

  private final func CreateStacksFromVendorItem(vendorItem: wref<VendorItem_Record>, player: ref<PlayerPuppet>) -> array<SItemStack> {
    let i: Int32;
    let isQuest: Bool;
    let itemStack: SItemStack;
    let outputStacks: array<SItemStack>;
    let quantity: Int32;
    let quantityMods: array<wref<StatModifier_Record>>;
    let randomPowerLevel: Float;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(vendorItem.Item().GetID());
    let itemID: ItemID = ItemID.FromTDBID(vendorItem.Item().GetID());
    vendorItem.Quantity(quantityMods);
    quantity = 1;
    if ArraySize(quantityMods) > 0 && IsDefined(this.m_vendorObject) {
      quantity = RoundF(RPGManager.CalculateStatModifiers(quantityMods, this.m_gameInstance, player, Cast(this.m_vendorObject.GetEntityID())));
    };
    if quantity > 0 {
      if !itemRecord.IsSingleInstance() {
        isQuest = itemRecord.TagsContains(n"Quest");
        i = 0;
        while i < quantity {
          itemStack.vendorItemID = vendorItem.GetID();
          if !isQuest {
            randomPowerLevel = MathHelper.RandFromNormalDist(GameInstance.GetStatsSystem(this.m_gameInstance).GetStatValue(Cast(GetPlayer(this.m_gameInstance).GetEntityID()), gamedataStatType.PowerLevel), 1.00);
            itemStack.powerLevel = RoundF(randomPowerLevel * 100.00);
          };
          itemStack.itemID = itemID;
          ArrayPush(outputStacks, itemStack);
          i += 1;
        };
      } else {
        itemStack.vendorItemID = vendorItem.GetID();
        itemStack.quantity = quantity;
        itemStack.itemID = itemID;
        ArrayPush(outputStacks, itemStack);
      };
    };
    ArrayClear(quantityMods);
    return outputStacks;
  }

  private final func CreateDynamicStockFromPlayerProgression(player: wref<GameObject>) -> array<SItemStack> {
    let i: Int32;
    let items: array<SItemStack>;
    let j: Int32;
    let returnTable: array<SItemStack>;
    let vendorItems: array<wref<VendorItem_Record>>;
    let PDS: ref<PlayerDevelopmentSystem> = PlayerDevelopmentSystem.GetInstance(player);
    let dominatingProficiency: gamedataProficiencyType = PDS.GetDominatingCombatProficiency(player);
    let vendorType: gamedataVendorType = this.GetVendorType();
    let recordID: TweakDBID = TDBID.Create("Vendors." + EnumValueToString("gamedataProficiencyType", Cast(EnumInt(dominatingProficiency))) + EnumValueToString("gamedataVendorType", Cast(EnumInt(vendorType))));
    if IsDefined(TweakDBInterface.GetVendorProgressionBasedStockRecord(recordID)) {
      TweakDBInterface.GetVendorProgressionBasedStockRecord(recordID).Items(vendorItems);
    };
    i = 0;
    while i < ArraySize(vendorItems) {
      items = this.CreateStacksFromVendorItem(vendorItems[i], player as PlayerPuppet);
      j = 0;
      while j < ArraySize(items) {
        ArrayPush(returnTable, items[j]);
        j += 1;
      };
      i += 1;
    };
    return returnTable;
  }

  protected func ShouldRegenerateStock() -> Bool {
    let currentTime: Float;
    let regenTime: Float = this.m_vendorRecord.InGameTimeToRestock();
    if regenTime <= 0.00 {
      regenTime = 259200.00;
    };
    if this.m_lastInteractionTime != 0.00 {
      currentTime = GameInstance.GetTimeSystem(this.m_gameInstance).GetGameTimeStamp();
      return currentTime - this.m_lastInteractionTime > regenTime;
    };
    return false;
  }

  private final func ShouldRegenerateItem(itemTDBID: TweakDBID) -> Bool {
    let tags: array<CName> = TweakDBInterface.GetItemRecord(itemTDBID).Tags();
    return !ArrayContains(tags, n"Quest");
  }

  public final func SellItemToVendor(itemStack: SItemStack, requestId: Int32) -> Void {
    let itemsStack: array<SItemStack>;
    ArrayPush(itemsStack, itemStack);
    this.SellItemsToVendor(itemsStack, requestId);
  }

  public final func SellItemsToVendor(itemsStack: array<SItemStack>, requestId: Int32) -> Void {
    let itemTransaction: SItemTransaction;
    let moneyStack: SItemStack;
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.m_gameInstance);
    let playerPuppet: ref<PlayerPuppet> = GetPlayer(this.m_gameInstance);
    let itemsSoldEvent: ref<UIVendorItemsSoldEvent> = new UIVendorItemsSoldEvent();
    itemsSoldEvent.requestID = requestId;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(itemsStack);
    while i < limit {
      itemTransaction.itemStack = itemsStack[i];
      itemTransaction.pricePerItem = RPGManager.CalculateSellPrice(this.m_vendorObject.GetGame(), this.m_vendorObject, itemsStack[i].itemID);
      if this.PerformItemTransfer(this.m_vendorObject, playerPuppet, itemTransaction) {
        this.AddItemsToStock(itemTransaction.itemStack);
        moneyStack.itemID = MarketSystem.Money();
        moneyStack.quantity = itemTransaction.pricePerItem * itemTransaction.itemStack.quantity;
        this.RemoveItemsFromStock(moneyStack);
        ArrayPush(itemsSoldEvent.itemsID, itemsStack[i].itemID);
        ArrayPush(itemsSoldEvent.quantity, itemsStack[i].quantity);
      };
      i += 1;
    };
    uiSystem.QueueEvent(itemsSoldEvent);
  }

  public final func BuyItemFromVendor(itemStack: SItemStack, requestId: Int32) -> Void {
    let itemsStack: array<SItemStack>;
    ArrayPush(itemsStack, itemStack);
    this.BuyItemsFromVendor(itemsStack, requestId);
  }

  public final func BuyItemsFromVendor(itemsStack: array<SItemStack>, requestId: Int32) -> Void {
    let itemTransaction: SItemTransaction;
    let moneyStack: SItemStack;
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.m_gameInstance);
    let playerPuppet: ref<PlayerPuppet> = GetPlayer(this.m_gameInstance);
    let itemsBoughtEvent: ref<UIVendorItemsBoughtEvent> = new UIVendorItemsBoughtEvent();
    itemsBoughtEvent.requestID = requestId;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(itemsStack);
    while i < limit {
      if !itemsStack[i].isAvailable {
      } else {
        itemTransaction.itemStack = itemsStack[i];
        itemTransaction.pricePerItem = MarketSystem.GetBuyPrice(this.m_vendorObject, itemsStack[i].itemID);
        if this.PerformItemTransfer(playerPuppet, this.m_vendorObject, itemTransaction) {
          this.RemoveItemsFromStock(itemTransaction.itemStack);
          moneyStack.itemID = MarketSystem.Money();
          moneyStack.quantity = itemTransaction.pricePerItem * itemTransaction.itemStack.quantity;
          this.AddItemsToStock(moneyStack);
          ArrayPush(itemsBoughtEvent.itemsID, itemsStack[i].itemID);
          ArrayPush(itemsBoughtEvent.quantity, itemsStack[i].quantity);
        };
      };
      i += 1;
    };
    uiSystem.QueueEvent(itemsBoughtEvent);
  }

  public final func BuybackItemFromVendor(itemStack: SItemStack, requestId: Int32) -> Void {
    let itemsStack: array<SItemStack>;
    ArrayPush(itemsStack, itemStack);
    this.BuybackItemsFromVendor(itemsStack, requestId);
  }

  public final func BuybackItemsFromVendor(itemsStack: array<SItemStack>, requestId: Int32) -> Void {
    let itemTransaction: SItemTransaction;
    let moneyStack: SItemStack;
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.m_gameInstance);
    let playerPuppet: ref<PlayerPuppet> = GetPlayer(this.m_gameInstance);
    let itemsBoughtEvent: ref<UIVendorItemsBoughtEvent> = new UIVendorItemsBoughtEvent();
    itemsBoughtEvent.requestID = requestId;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(itemsStack);
    while i < limit {
      if !itemsStack[i].isAvailable {
      } else {
        itemTransaction.itemStack = itemsStack[i];
        itemTransaction.pricePerItem = RPGManager.CalculateSellPrice(this.m_vendorObject.GetGame(), this.m_vendorObject, itemsStack[i].itemID);
        if this.PerformItemTransfer(playerPuppet, this.m_vendorObject, itemTransaction) {
          this.RemoveItemsFromStock(itemTransaction.itemStack);
          moneyStack.itemID = MarketSystem.Money();
          moneyStack.quantity = itemTransaction.pricePerItem * itemTransaction.itemStack.quantity;
          this.AddItemsToStock(moneyStack);
          ArrayPush(itemsBoughtEvent.itemsID, itemsStack[i].itemID);
          ArrayPush(itemsBoughtEvent.quantity, itemsStack[i].quantity);
        };
      };
      i += 1;
    };
    uiSystem.QueueEvent(itemsBoughtEvent);
  }

  public final func DispenseItemFromVendor(position: Vector4, opt itemID: ItemID) -> Void {
    let itemStack: SItemStack;
    this.LazyInitStock();
    if ArraySize(this.m_stock) > 0 {
      if !ItemID.IsValid(itemID) {
        itemID = this.GetRandomStockItem();
      };
      itemStack.itemID = itemID;
      if this.RemoveItemsFromStock(itemStack) {
        GameInstance.GetTransactionSystem(this.m_gameInstance).GiveItem(this.m_vendorObject, itemID, 1);
        GameInstance.GetLootManager(this.m_gameInstance).SpawnItemDrop(this.m_vendorObject, itemID, position);
      };
    };
  }

  private final func GetRandomStockItem() -> ItemID {
    let i: Int32;
    let j: Int32;
    let weightedList: array<ItemID>;
    this.LazyInitStock();
    i = 0;
    while i < ArraySize(this.m_stock) {
      j = 0;
      while j < this.m_stock[i].quantity {
        ArrayPush(weightedList, this.m_stock[i].itemID);
        j += 1;
      };
      i += 1;
    };
    return weightedList[RandRange(0, ArraySize(weightedList))];
  }

  private final func PerformItemTransfer(buyer: wref<GameObject>, seller: wref<GameObject>, itemTransaction: SItemTransaction) -> Bool {
    let blackBoard: ref<IBlackboard>;
    let buyerHasEnoughMoney: Bool;
    let buyerMoney: Int32;
    let eqs: ref<EquipmentSystem>;
    let sellerHasEnoughItems: Bool;
    let sellerItemQuantity: Int32;
    let totalPrice: Int32;
    let transactionSystem: ref<TransactionSystem>;
    let uiSystem: ref<UISystem>;
    let vendorNotification: ref<UIMenuNotificationEvent>;
    this.FillVendorInventory(false);
    this.m_lastInteractionTime = GameInstance.GetTimeSystem(this.m_gameInstance).GetGameTimeStamp();
    blackBoard = GameInstance.GetBlackboardSystem(buyer.GetGame()).Get(GetAllBlackboardDefs().UI_Vendor);
    transactionSystem = GameInstance.GetTransactionSystem(this.m_gameInstance);
    totalPrice = itemTransaction.pricePerItem * itemTransaction.itemStack.quantity;
    buyerMoney = transactionSystem.GetItemQuantity(buyer, MarketSystem.Money());
    sellerItemQuantity = transactionSystem.GetItemQuantity(seller, itemTransaction.itemStack.itemID);
    buyerHasEnoughMoney = buyerMoney >= totalPrice;
    sellerHasEnoughItems = sellerItemQuantity >= itemTransaction.itemStack.quantity;
    if sellerItemQuantity == 0 {
      LogError("[Vendor] Trying to sell item: " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemTransaction.itemStack.itemID)) + " with quantity 0");
      return false;
    };
    if !buyerHasEnoughMoney {
      vendorNotification = new UIMenuNotificationEvent();
      if buyer.IsPlayer() {
        vendorNotification.m_notificationType = UIMenuNotificationType.VNotEnoughMoney;
      } else {
        vendorNotification.m_notificationType = UIMenuNotificationType.VendorNotEnoughMoney;
      };
      uiSystem = GameInstance.GetUISystem(this.m_gameInstance);
      uiSystem.QueueEvent(vendorNotification);
      return false;
    };
    GameInstance.GetTelemetrySystem(buyer.GetGame()).LogItemTransaction(buyer, seller, ToTelemetryInventoryItem(seller, itemTransaction.itemStack.itemID), Cast(itemTransaction.pricePerItem), Cast(itemTransaction.itemStack.quantity), Cast(totalPrice));
    if !sellerHasEnoughItems {
      transactionSystem.GiveItem(seller, itemTransaction.itemStack.itemID, itemTransaction.itemStack.quantity - sellerItemQuantity);
    };
    transactionSystem.TransferItem(seller, buyer, itemTransaction.itemStack.itemID, itemTransaction.itemStack.quantity);
    transactionSystem.TransferItem(buyer, seller, MarketSystem.Money(), totalPrice);
    eqs = GameInstance.GetScriptableSystemsContainer(this.m_gameInstance).Get(n"EquipmentSystem") as EquipmentSystem;
    if IsDefined(eqs) {
    };
    blackBoard.SignalVariant(GetAllBlackboardDefs().UI_Vendor.VendorData);
    return true;
  }

  public final func AddItemsToStock(itemStack: SItemStack) -> Void {
    let itemIndex: Int32 = this.GetItemIndex(itemStack.itemID);
    if itemIndex != -1 {
      this.m_stock[itemIndex].quantity += itemStack.quantity;
    } else {
      ArrayPush(this.m_stock, itemStack);
    };
  }

  private final func RemoveItemsFromStock(itemStack: SItemStack) -> Bool {
    let currentQuantity: Int32;
    let newQuantity: Int32;
    let itemIndex: Int32 = this.GetItemIndex(itemStack.itemID);
    if itemIndex == -1 {
      return false;
    };
    currentQuantity = this.m_stock[itemIndex].quantity;
    newQuantity = currentQuantity - itemStack.quantity;
    if newQuantity <= 0 {
      ArrayErase(this.m_stock, itemIndex);
    } else {
      this.m_stock[itemIndex].quantity = newQuantity;
    };
    return true;
  }

  private final func GetItemIndex(itemID: ItemID) -> Int32 {
    let i: Int32;
    this.LazyInitStock();
    i = 0;
    while i < ArraySize(this.m_stock) {
      if this.m_stock[i].itemID == itemID {
        return i;
      };
      i += 1;
    };
    return -1;
  }
}
