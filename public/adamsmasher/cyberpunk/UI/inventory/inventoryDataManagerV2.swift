
public class InventoryDataManagerV2 extends IScriptable {

  private let m_owner: wref<inkHUDGameController>;

  private let m_Player: wref<PlayerPuppet>;

  private let m_TransactionSystem: wref<TransactionSystem>;

  private let m_EquipmentSystem: wref<EquipmentSystem>;

  private let m_StatsSystem: wref<StatsSystem>;

  private let m_ItemModificationSystem: wref<ItemModificationSystem>;

  private let m_LocMgr: ref<UILocalizationMap>;

  private let m_InventoryItemsData: array<InventoryItemData>;

  private let m_InventoryItemsDataWithoutEquipment: array<InventoryItemData>;

  private let m_EquipmentItemsData: array<InventoryItemData>;

  private let m_WeaponItemsData: array<InventoryItemData>;

  private let m_QuickSlotsData: array<InventoryItemData>;

  private let m_ConsumablesSlotsData: array<InventoryItemData>;

  @default(InventoryDataManagerV2, true)
  private let m_ToRebuild: Bool;

  @default(InventoryDataManagerV2, true)
  private let m_ToRebuildItemsWithEquipped: Bool;

  @default(InventoryDataManagerV2, true)
  private let m_ToRebuildWeapons: Bool;

  @default(InventoryDataManagerV2, true)
  private let m_ToRebuildEquipment: Bool;

  @default(InventoryDataManagerV2, true)
  private let m_ToRebuildQuickSlots: Bool;

  @default(InventoryDataManagerV2, true)
  private let m_ToRebuildConsumables: Bool;

  private let m_ActiveWeapon: ItemID;

  private let m_EquipRecords: array<ref<EquipmentArea_Record>>;

  private let m_ItemIconGender: ItemIconGender;

  private let m_WeaponUIBlackboard: wref<IBlackboard>;

  private let m_UIBBEquipmentBlackboard: wref<IBlackboard>;

  private let m_UIBBItemModBlackbord: wref<IBlackboard>;

  private let m_UIBBEquipment: ref<UI_EquipmentDef>;

  private let m_UIBBItemMod: ref<UI_ItemModSystemDef>;

  private let m_InventoryBBID: ref<CallbackHandle>;

  private let m_EquipmentBBID: ref<CallbackHandle>;

  private let m_SubEquipmentBBID: ref<CallbackHandle>;

  private let m_ItemModBBID: ref<CallbackHandle>;

  private let m_BBWeaponList: ref<CallbackHandle>;

  private let m_InventoryItemDataWrappers: array<ref<InventoryItemDataWrapper>>;

  private let m_HashMapCache: ref<inkWeakHashMap>;

  public final func Initialize(player: ref<PlayerPuppet>, opt owner: ref<inkHUDGameController>) -> Void {
    let gameInstance: GameInstance;
    if IsDefined(player) {
      this.m_Player = GameInstance.GetPlayerSystem(player.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
      this.m_ItemIconGender = UIGenderHelper.GetIconGender(this.m_Player);
      gameInstance = this.m_Player.GetGame();
      this.m_TransactionSystem = GameInstance.GetTransactionSystem(gameInstance);
      this.m_StatsSystem = GameInstance.GetStatsSystem(gameInstance);
      this.m_EquipmentSystem = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"EquipmentSystem") as EquipmentSystem;
      this.m_ItemModificationSystem = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"ItemModificationSystem") as ItemModificationSystem;
    };
    this.m_HashMapCache = new inkWeakHashMap();
    this.m_LocMgr = new UILocalizationMap();
    this.m_LocMgr.Init();
    this.RegisterToBB();
    if IsDefined(owner) {
      this.m_owner = owner;
    };
  }

  public final func UnInitialize() -> Void {
    this.UnregisterFromBB();
  }

  private final func RegisterToBB() -> Void {
    if IsDefined(this.m_Player) {
      this.m_WeaponUIBlackboard = GameInstance.GetBlackboardSystem(this.m_Player.GetGame()).Get(GetAllBlackboardDefs().UI_EquipmentData);
      if IsDefined(this.m_WeaponUIBlackboard) {
        this.m_BBWeaponList = this.m_WeaponUIBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this, n"OnWeaponDataChanged");
        this.m_WeaponUIBlackboard.Signal(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData);
      };
      this.m_UIBBEquipment = GetAllBlackboardDefs().UI_Equipment;
      this.m_UIBBEquipmentBlackboard = GameInstance.GetBlackboardSystem(this.m_Player.GetGame()).Get(this.m_UIBBEquipment);
      this.m_UIBBItemMod = GetAllBlackboardDefs().UI_ItemModSystem;
      this.m_UIBBItemModBlackbord = GameInstance.GetBlackboardSystem(this.m_Player.GetGame()).Get(this.m_UIBBItemMod);
      if IsDefined(this.m_UIBBEquipmentBlackboard) {
        this.m_EquipmentBBID = this.m_UIBBEquipmentBlackboard.RegisterListenerVariant(this.m_UIBBEquipment.itemEquipped, this, n"OnMarkForRebuild");
      };
      if IsDefined(this.m_UIBBItemModBlackbord) {
        this.m_ItemModBBID = this.m_UIBBItemModBlackbord.RegisterListenerVariant(this.m_UIBBItemMod.ItemModSystemUpdated, this, n"OnMarkForRebuild");
      };
    };
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_WeaponUIBlackboard) {
      this.m_WeaponUIBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this.m_BBWeaponList);
    };
    if IsDefined(this.m_UIBBEquipmentBlackboard) {
      this.m_UIBBEquipmentBlackboard.UnregisterListenerVariant(this.m_UIBBEquipment.itemEquipped, this.m_EquipmentBBID);
    };
    if IsDefined(this.m_UIBBItemModBlackbord) {
      this.m_UIBBItemModBlackbord.UnregisterListenerVariant(this.m_UIBBItemMod.ItemModSystemUpdated, this.m_ItemModBBID);
    };
    this.m_UIBBEquipmentBlackboard = null;
    this.m_WeaponUIBlackboard = null;
    this.m_UIBBItemModBlackbord = null;
  }

  protected cb func OnMarkForRebuild(value: Variant) -> Bool {
    this.MarkToRebuild();
  }

  protected cb func OnWeaponDataChanged(value: Variant) -> Bool {
    let currentData: ref<SlotDataHolder> = FromVariant(value);
    this.SetActiveWeapon(currentData.weapon.weaponID);
    this.MarkToRebuild();
    if IsDefined(this.m_owner) {
      this.m_owner.UpdateRequired();
    };
  }

  private final func GetPlayerItems() -> array<wref<gameItemData>> {
    let items: array<wref<gameItemData>>;
    this.m_TransactionSystem.GetItemList(this.m_Player, items);
    return items;
  }

  public final func GetTransactionSystem() -> wref<TransactionSystem> {
    return this.m_TransactionSystem;
  }

  public final func GetPlayerItemData(itemId: ItemID) -> wref<gameItemData> {
    let itemData: wref<gameItemData>;
    let localPlayer: ref<GameObject>;
    if !IsDefined(this.m_Player) {
      return null;
    };
    localPlayer = GameInstance.GetPlayerSystem(this.m_Player.GetGame()).GetLocalPlayerControlledGameObject();
    if ItemID.IsValid(itemId) {
      if IsDefined(localPlayer) {
        itemData = this.m_TransactionSystem.GetItemData(localPlayer, itemId);
      } else {
        itemData = this.m_TransactionSystem.GetItemData(this.m_Player, itemId);
      };
    };
    return itemData;
  }

  public final func GetIconGender() -> ItemIconGender {
    return this.m_ItemIconGender;
  }

  private final func GetPlayerInventoryItems(opt additionalTagFilters: array<CName>) -> array<wref<gameItemData>> {
    let inventoryItems: array<wref<gameItemData>>;
    let items: array<wref<gameItemData>> = this.GetPlayerItems();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      if !InventoryDataManagerV2.IsItemBlacklisted(items[i], additionalTagFilters) {
        ArrayPush(inventoryItems, items[i]);
      };
      i += 1;
    };
    return inventoryItems;
  }

  private final func GetPlayerInventoryItemsExcludingLoadout() -> array<wref<gameItemData>> {
    let inventoryItems: array<wref<gameItemData>>;
    let items: array<wref<gameItemData>> = this.GetPlayerItems();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      if !this.m_EquipmentSystem.IsEquipped(this.m_Player, items[i].GetID()) && !InventoryDataManagerV2.IsItemBlacklisted(items[i]) {
        ArrayPush(inventoryItems, items[i]);
      };
      i += 1;
    };
    return inventoryItems;
  }

  private final func GetPlayerInventoryItemsExcludingCraftingMaterials() -> array<InventoryItemData> {
    let inventoryItems: array<InventoryItemData>;
    let items: array<wref<gameItemData>> = this.GetPlayerInventoryItems();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      if IsDefined(items[i]) && !InventoryDataManagerV2.IsItemCraftingMaterial(items[i]) {
        ArrayPush(inventoryItems, this.GetInventoryItemData(items[i]));
      };
      i += 1;
    };
    return inventoryItems;
  }

  public final func GetPlayerInventoryDataExcludingLoadout() -> array<InventoryItemData> {
    let i: Int32;
    let inventoryItems: array<InventoryItemData>;
    let items: array<wref<gameItemData>>;
    let limit: Int32;
    if this.m_ToRebuildItemsWithEquipped {
      this.m_ToRebuildItemsWithEquipped = false;
      items = this.GetPlayerInventoryItemsExcludingLoadout();
      i = 0;
      limit = ArraySize(items);
      while i < limit {
        if IsDefined(items[i]) {
          ArrayPush(inventoryItems, this.GetInventoryItemData(items[i]));
        };
        i += 1;
      };
      ArrayClear(this.m_InventoryItemsDataWithoutEquipment);
      this.m_InventoryItemsDataWithoutEquipment = inventoryItems;
    };
    return this.m_InventoryItemsDataWithoutEquipment;
  }

  private final func GetPlayerInventoryData(opt additionalTagFilters: array<CName>) -> array<InventoryItemData> {
    let i: Int32;
    let inventoryItems: array<InventoryItemData>;
    let items: array<wref<gameItemData>>;
    let limit: Int32;
    if this.m_ToRebuild {
      this.m_ToRebuild = false;
      items = this.GetPlayerInventoryItems(additionalTagFilters);
      i = 0;
      limit = ArraySize(items);
      while i < limit {
        if IsDefined(items[i]) {
          ArrayPush(inventoryItems, this.GetCachedInventoryItemData(items[i]));
        };
        i += 1;
      };
      ArrayClear(this.m_InventoryItemsData);
      this.m_InventoryItemsData = inventoryItems;
    };
    return this.m_InventoryItemsData;
  }

  public final func GetPlayerInventoryData(equipArea: gamedataEquipmentArea, opt skipEquipped: Bool, opt filteredItems: array<ItemModParams>) -> array<InventoryItemData> {
    let currentItemData: InventoryItemData;
    let inventoryItems: array<InventoryItemData>;
    let quantity: Int32;
    let quantityToFilterOut: Int32;
    let items: array<InventoryItemData> = this.GetPlayerInventoryData();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      currentItemData = items[i];
      if !InventoryItemData.IsEmpty(currentItemData) && Equals(InventoryItemData.GetEquipmentArea(currentItemData), equipArea) {
        if skipEquipped && InventoryItemData.IsEquipped(currentItemData) || InventoryItemData.IsBroken(currentItemData) {
        } else {
          quantityToFilterOut = this.GetQunatityToFilterOut(InventoryItemData.GetID(currentItemData), filteredItems);
          quantity = InventoryItemData.GetQuantity(currentItemData) - quantityToFilterOut;
          InventoryItemData.SetQuantity(currentItemData, quantity);
          if quantity > 0 {
            ArrayPush(inventoryItems, currentItemData);
          };
        };
      };
      i += 1;
    };
    return inventoryItems;
  }

  public final func GetPlayerInventoryData(equipAreas: array<gamedataEquipmentArea>, opt skipEquipped: Bool, opt filteredItems: array<ItemModParams>) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    this.GetPlayerInventoryDataRef(equipAreas, skipEquipped, filteredItems, result);
    return result;
  }

  public final func GetEquippedItemIDs(owner: wref<GameObject>) -> array<ItemID> {
    let ids: array<ItemID>;
    let equipmentSystem: ref<EquipmentSystem> = EquipmentSystem.GetInstance(owner);
    let playerData: ref<EquipmentSystemPlayerData> = equipmentSystem.GetPlayerData(owner);
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Head, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Face, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.OuterChest, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.InnerChest, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Legs, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Feet, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Outfit, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Weapon, 0));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Weapon, 1));
    ArrayPush(ids, playerData.GetItemInEquipSlot(gamedataEquipmentArea.Weapon, 2));
    return ids;
  }

  public final func GetPlayerInventoryDataRef(equipAreas: array<gamedataEquipmentArea>, opt skipEquipped: Bool, opt filteredItems: array<ItemModParams>, outputItems: script_ref<array<InventoryItemData>>) -> Void {
    let currentItemData: InventoryItemData;
    let j: Int32;
    let quantity: Int32;
    let quantityToFilterOut: Int32;
    let validArea: Bool;
    let items: array<InventoryItemData> = this.GetPlayerInventoryData();
    let equippedItems: array<ItemID> = this.GetEquippedItemIDs(this.m_Player);
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      validArea = false;
      currentItemData = items[i];
      if !InventoryItemData.IsEmpty(currentItemData) {
        j = 0;
        while j < ArraySize(equipAreas) {
          if !validArea {
            if Equals(InventoryItemData.GetEquipmentArea(currentItemData), equipAreas[j]) {
              validArea = true;
            };
          };
          j += 1;
        };
        if skipEquipped && ArrayContains(equippedItems, InventoryItemData.GetID(currentItemData)) || InventoryItemData.IsBroken(currentItemData) {
        } else {
          if validArea {
            quantityToFilterOut = this.GetQunatityToFilterOut(InventoryItemData.GetID(currentItemData), filteredItems);
            quantity = InventoryItemData.GetQuantity(currentItemData) - quantityToFilterOut;
            InventoryItemData.SetQuantity(currentItemData, quantity);
            if quantity > 0 {
              ArrayPush(Deref(outputItems), currentItemData);
            };
          };
        };
      };
      i += 1;
    };
  }

  public final func GetPlayerInventoryParts(slotId: TweakDBID) -> array<InventoryItemData> {
    let currentItemData: InventoryItemData;
    let inventoryItems: array<InventoryItemData>;
    let items: array<InventoryItemData> = this.GetPlayerInventoryData();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      currentItemData = items[i];
      if !InventoryItemData.IsEmpty(currentItemData) && InventoryItemData.IsPart(currentItemData) && InventoryItemData.PlacementSlotsContains(currentItemData, slotId) {
        ArrayPush(inventoryItems, currentItemData);
      };
      i += 1;
    };
    return inventoryItems;
  }

  public final func GetPlayerInventoryPartsForItem(item: ItemID, slotID: TweakDBID) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    this.GetPlayerInventoryPartsForItemRef(item, slotID, result);
    return result;
  }

  public final func GetPlayerInventoryPartsForItem(item: ItemID, slotIDs: array<TweakDBID>) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    this.GetPlayerInventoryPartsForItemRef(item, slotIDs, result);
    return result;
  }

  public final func GetPlayerInventoryPartsForItemRef(item: ItemID, slotID: TweakDBID, outputItems: script_ref<array<InventoryItemData>>) -> Void {
    let slotIDs: array<TweakDBID>;
    ArrayPush(slotIDs, slotID);
    this.GetPlayerInventoryPartsForItemRef(item, slotIDs, outputItems);
  }

  public final func GetItemSlotsIDs(gameObject: ref<GameObject>, itemID: ItemID) -> array<TweakDBID> {
    let i: Int32;
    let parts: array<InnerItemData>;
    let result: array<TweakDBID>;
    let itemData: wref<gameItemData> = GameInstance.GetTransactionSystem(gameObject.GetGame()).GetItemData(gameObject, itemID);
    itemData.GetItemParts(parts);
    i = 0;
    while i < ArraySize(parts) {
      ArrayPush(result, InnerItemData.GetSlotID(parts[i]));
      i += 1;
    };
    return result;
  }

  public final func GetPlayerInventoryPartsForItemRef(item: ItemID, slotIDs: array<TweakDBID>, outputItems: script_ref<array<InventoryItemData>>) -> Void {
    let availableMuzzles: array<wref<ItemPartListElement_Record>>;
    let availableScopes: array<wref<ItemPartListElement_Record>>;
    let canBeInstalled: Bool;
    let currentItemData: InventoryItemData;
    let inventoryItems: array<InventoryItemData>;
    let j: Int32;
    let matchAnySlot: Bool;
    let shardData: array<InventoryItemData>;
    let shardType: CName;
    let shouldAdd: Bool;
    let slotID: TweakDBID;
    let slotPartList: array<wref<SlotItemPartListElement_Record>>;
    let tempItems: array<InventoryItemData> = this.GetPlayerInventoryData();
    let i: Int32 = 0;
    while i < ArraySize(tempItems) {
      currentItemData = tempItems[i];
      matchAnySlot = false;
      j = 0;
      while j < ArraySize(slotIDs) {
        if InventoryItemData.PlacementSlotsContains(currentItemData, slotIDs[j]) {
          matchAnySlot = true;
        };
        j += 1;
      };
      if !InventoryItemData.IsEmpty(currentItemData) && InventoryItemData.IsPart(currentItemData) && matchAnySlot {
        ArrayPush(inventoryItems, currentItemData);
      };
      i += 1;
    };
    if Equals(RPGManager.GetItemCategory(item), gamedataItemCategory.Weapon) {
      TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item)).SlotPartList(slotPartList);
      i = 0;
      while i < ArraySize(slotPartList) {
        slotID = slotPartList[i].Slot().GetID();
        if slotID == t"AttachmentSlots.PowerModule" {
          slotPartList[i].ItemPartList(availableMuzzles);
        } else {
          if slotID == t"AttachmentSlots.Scope" {
            slotPartList[i].ItemPartList(availableScopes);
          };
        };
        i += 1;
      };
      i = ArraySize(inventoryItems) - 1;
      while i >= 0 {
        if Equals(InventoryItemData.GetItemType(inventoryItems[i]), gamedataItemType.Prt_Scope) || Equals(InventoryItemData.GetItemType(inventoryItems[i]), gamedataItemType.Prt_Muzzle) {
          canBeInstalled = false;
          j = 0;
          while j < ArraySize(availableMuzzles) {
            if ItemID.GetTDBID(InventoryItemData.GetID(inventoryItems[i])) == availableMuzzles[j].Item().GetID() {
              canBeInstalled = true;
            };
            j += 1;
          };
          j = 0;
          while j < ArraySize(availableScopes) {
            if ItemID.GetTDBID(InventoryItemData.GetID(inventoryItems[i])) == availableScopes[j].Item().GetID() {
              canBeInstalled = true;
            };
            j += 1;
          };
          if !canBeInstalled {
            ArrayRemove(inventoryItems, inventoryItems[i]);
          };
        };
        i -= 1;
      };
    };
    if GameInstance.GetTransactionSystem(this.m_Player.GetGame()).HasTag(this.m_Player, n"Cyberdeck", item) {
      i = 0;
      while i < ArraySize(inventoryItems) {
        shouldAdd = true;
        shardType = TweakDBInterface.GetCName(ItemID.GetTDBID(InventoryItemData.GetID(inventoryItems[i])) + t".shardType", n"");
        if NotEquals(shardType, n"") {
          if ItemModificationSystem.HasBetterShardInstalled(this.m_Player, item, InventoryItemData.GetID(inventoryItems[i])) {
          } else {
            j = 0;
            while j < ArraySize(shardData) {
              if Equals(shardType, TweakDBInterface.GetCName(ItemID.GetTDBID(InventoryItemData.GetID(shardData[j])) + t".shardType", n"")) {
                if InventoryItemData.GetComparedQuality(shardData[j]) < InventoryItemData.GetComparedQuality(inventoryItems[i]) {
                  shardData[j] = inventoryItems[i];
                };
                shouldAdd = false;
              } else {
                j += 1;
              };
            };
            if shouldAdd {
              ArrayPush(shardData, inventoryItems[i]);
            };
          };
        };
        if shouldAdd {
          ArrayPush(shardData, inventoryItems[i]);
        };
        i += 1;
      };
      inventoryItems = shardData;
    };
    i = 0;
    while i < ArraySize(inventoryItems) {
      ArrayPush(Deref(outputItems), inventoryItems[i]);
      i += 1;
    };
  }

  private final func PlacementSlotsContains(staticData: wref<Item_Record>, slotID: TweakDBID) -> Bool {
    let i: Int32;
    let placementSlots: array<wref<AttachmentSlot_Record>>;
    staticData.PlacementSlots(placementSlots);
    i = 0;
    while i < ArraySize(placementSlots) {
      if placementSlots[i].GetID() == slotID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func GetPlayerInventoryPartsDataForItem(item: ItemID, slotIDs: array<TweakDBID>) -> array<wref<gameItemData>> {
    let availableMuzzles: array<wref<ItemPartListElement_Record>>;
    let availableScopes: array<wref<ItemPartListElement_Record>>;
    let canBeInstalled: Bool;
    let currentItemRecord: wref<Item_Record>;
    let currentPartStaticData: wref<Item_Record>;
    let currentShardQuality: gamedataQuality;
    let innerItemData: InnerItemData;
    let inventoryItems: array<wref<gameItemData>>;
    let itemQuality: gamedataQuality;
    let itemType: gamedataItemType;
    let j: Int32;
    let matchAnySlot: Bool;
    let outputItems: array<wref<gameItemData>>;
    let parts: array<InnerItemData>;
    let shardData: array<wref<gameItemData>>;
    let shardType: CName;
    let shouldAdd: Bool;
    let slotID: TweakDBID;
    let slotPartList: array<wref<SlotItemPartListElement_Record>>;
    let tempItems: array<wref<gameItemData>> = this.GetPlayerInventoryItems();
    let i: Int32 = 0;
    while i < ArraySize(tempItems) {
      currentItemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(tempItems[i].GetID()));
      if IsDefined(currentItemRecord) && currentItemRecord.IsPart() {
        matchAnySlot = false;
        ArrayClear(parts);
        tempItems[i].GetItemParts(parts);
        if ArraySize(parts) > 0 {
          parts;
        };
        innerItemData = parts[0];
        currentPartStaticData = InnerItemData.GetStaticData(innerItemData);
        j = 0;
        while j < ArraySize(slotIDs) {
          if this.PlacementSlotsContains(currentPartStaticData, slotIDs[j]) {
            matchAnySlot = true;
          } else {
            j += 1;
          };
        };
        if matchAnySlot {
          ArrayPush(inventoryItems, tempItems[i]);
        };
      };
      i += 1;
    };
    if Equals(RPGManager.GetItemCategory(item), gamedataItemCategory.Weapon) {
      TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item)).SlotPartList(slotPartList);
      i = 0;
      while i < ArraySize(slotPartList) {
        slotID = slotPartList[i].Slot().GetID();
        if slotID == t"AttachmentSlots.PowerModule" {
          slotPartList[i].ItemPartList(availableMuzzles);
        } else {
          if slotID == t"AttachmentSlots.Scope" {
            slotPartList[i].ItemPartList(availableScopes);
          };
        };
        i += 1;
      };
      i = ArraySize(inventoryItems) - 1;
      while i >= 0 {
        itemType = inventoryItems[i].GetItemType();
        if Equals(itemType, gamedataItemType.Prt_Scope) || Equals(itemType, gamedataItemType.Prt_Muzzle) {
          canBeInstalled = false;
          j = 0;
          while j < ArraySize(availableMuzzles) {
            if inventoryItems[i].GetID() == availableMuzzles[j].Item().GetID() {
              canBeInstalled = true;
            };
            j += 1;
          };
          j = 0;
          while j < ArraySize(availableScopes) {
            if inventoryItems[i].GetID() == availableScopes[j].Item().GetID() {
              canBeInstalled = true;
            };
            j += 1;
          };
          if !canBeInstalled {
            ArrayRemove(inventoryItems, inventoryItems[i]);
          };
        };
        i -= 1;
      };
    };
    if GameInstance.GetTransactionSystem(this.m_Player.GetGame()).HasTag(this.m_Player, n"Cyberdeck", item) {
      i = 0;
      while i < ArraySize(inventoryItems) {
        shouldAdd = true;
        itemQuality = RPGManager.GetItemDataQuality(inventoryItems[i]);
        shardType = TweakDBInterface.GetCName(ItemID.GetTDBID(inventoryItems[i].GetID()) + t".shardType", n"");
        if NotEquals(shardType, n"") {
          if ItemModificationSystem.HasBetterShardInstalled(this.m_Player, item, inventoryItems[i].GetID()) {
          } else {
            j = 0;
            while j < ArraySize(shardData) {
              if Equals(shardType, TweakDBInterface.GetCName(ItemID.GetTDBID(shardData[j].GetID()) + t".shardType", n"")) {
                currentShardQuality = RPGManager.GetItemDataQuality(shardData[j]);
                if currentShardQuality < itemQuality {
                  shardData[j] = inventoryItems[i];
                };
                shouldAdd = false;
              } else {
                j += 1;
              };
            };
            if shouldAdd {
              ArrayPush(shardData, inventoryItems[i]);
            };
          };
        };
        if shouldAdd {
          ArrayPush(shardData, inventoryItems[i]);
        };
        i += 1;
      };
      inventoryItems = shardData;
    };
    i = 0;
    while i < ArraySize(inventoryItems) {
      ArrayPush(outputItems, inventoryItems[i]);
      i += 1;
    };
    return outputItems;
  }

  public final func GetEquippedItemIdInArea(equipArea: gamedataEquipmentArea, opt slot: Int32) -> ItemID {
    let localPlayer: ref<GameObject> = GameInstance.GetPlayerSystem(this.m_Player.GetGame()).GetLocalPlayerControlledGameObject();
    if IsDefined(localPlayer) {
      if Equals(equipArea, gamedataEquipmentArea.Consumable) {
        return this.m_EquipmentSystem.GetItemIDFromHotkey(localPlayer, EHotkey.DPAD_UP);
      };
      if Equals(equipArea, gamedataEquipmentArea.QuickSlot) {
        return this.m_EquipmentSystem.GetItemIDFromHotkey(localPlayer, EHotkey.RB);
      };
    };
    return this.m_EquipmentSystem.GetItemInEquipSlot(this.m_Player, equipArea, slot);
  }

  public final func GetItemDataFromIDInLoadout(id: ItemID) -> InventoryItemData {
    let inventoryItemData: InventoryItemData;
    if ItemID.IsValid(id) {
      inventoryItemData = this.GetInventoryItemData(this.GetPlayerItemData(id));
    };
    return inventoryItemData;
  }

  public final func GetItemDataEquippedInArea(equipArea: gamedataEquipmentArea, opt slot: Int32) -> InventoryItemData {
    let id: ItemID = this.GetEquippedItemIdInArea(equipArea, slot);
    return this.GetItemDataFromIDInLoadout(id);
  }

  private final func GetEquipment() -> array<InventoryItemData> {
    let currentItem: InventoryItemData;
    let equipAreas: array<gamedataEquipmentArea>;
    let i: Int32;
    let items: array<InventoryItemData>;
    let limit: Int32;
    if this.m_ToRebuildEquipment {
      this.m_ToRebuildEquipment = false;
      equipAreas = InventoryDataManagerV2.GetInventoryEquipmentAreas();
      i = 0;
      limit = ArraySize(equipAreas);
      while i < limit {
        currentItem = this.GetItemDataEquippedInArea(equipAreas[i]);
        if !InventoryItemData.IsEmpty(currentItem) {
          ArrayPush(items, currentItem);
        };
        i += 1;
      };
      ArrayClear(this.m_EquipmentItemsData);
      this.m_EquipmentItemsData = items;
    };
    return this.m_EquipmentItemsData;
  }

  public final func GetInventoryCyberware() -> array<InventoryItemData> {
    let currentItem: InventoryItemData;
    let items: array<InventoryItemData>;
    let cyberAreas: array<gamedataEquipmentArea> = InventoryDataManagerV2.GetInventoryCyberwareAreas();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(cyberAreas);
    while i < limit {
      currentItem = this.GetItemDataEquippedInArea(cyberAreas[i]);
      if !InventoryItemData.IsEmpty(currentItem) {
        ArrayPush(items, currentItem);
      };
      i += 1;
    };
    return items;
  }

  public final func GetInventoryCyberwareSize() -> Int32 {
    let currentItem: InventoryItemData;
    let result: Int32;
    let cyberAreas: array<gamedataEquipmentArea> = InventoryDataManagerV2.GetInventoryCyberwareAreas();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(cyberAreas);
    while i < limit {
      currentItem = this.GetItemDataEquippedInArea(cyberAreas[i]);
      if !InventoryItemData.IsEmpty(currentItem) {
        result += 1;
      };
      i += 1;
    };
    return result;
  }

  public final func GetWeaponEquippedInSlot(slot: Int32) -> InventoryItemData {
    return this.GetItemDataEquippedInArea(gamedataEquipmentArea.Weapon, slot);
  }

  public final func GetEquippedWeapons() -> array<InventoryItemData> {
    let i: Int32;
    let items: array<InventoryItemData>;
    let limit: Int32;
    if this.m_ToRebuildWeapons {
      this.m_ToRebuildWeapons = false;
      limit = InventoryDataManagerV2.GetWeaponSlotsNum();
      i = 0;
      while i < limit {
        ArrayPush(items, this.GetWeaponEquippedInSlot(i));
        i += 1;
      };
      ArrayClear(this.m_WeaponItemsData);
      this.m_WeaponItemsData = items;
    };
    return this.m_WeaponItemsData;
  }

  public final func GetEquippedWeaponsIDs() -> array<ItemID> {
    let items: array<ItemID>;
    let limit: Int32 = InventoryDataManagerV2.GetWeaponSlotsNum();
    let i: Int32 = 0;
    while i < limit {
      ArrayPush(items, this.GetEquippedItemIdInArea(gamedataEquipmentArea.Weapon, i));
      i += 1;
    };
    return items;
  }

  public final func GetEquippedQuickSlots() -> array<InventoryItemData> {
    let i: Int32;
    let items: array<InventoryItemData>;
    let limit: Int32;
    let tempItemData: InventoryItemData;
    if this.m_ToRebuildQuickSlots {
      this.m_ToRebuildQuickSlots = false;
      limit = InventoryDataManagerV2.GetQuickSlotsNum();
      i = 0;
      while i < limit {
        tempItemData = this.GetItemDataEquippedInArea(gamedataEquipmentArea.QuickSlot, i);
        ArrayPush(items, tempItemData);
        i += 1;
      };
      ArrayClear(this.m_QuickSlotsData);
      this.m_QuickSlotsData = items;
    };
    return this.m_QuickSlotsData;
  }

  public final func GetEquippedConsumables() -> array<InventoryItemData> {
    let i: Int32;
    let items: array<InventoryItemData>;
    let limit: Int32;
    if this.m_ToRebuildConsumables {
      this.m_ToRebuildConsumables = false;
      limit = InventoryDataManagerV2.GetConsumablesNum();
      i = 0;
      while i < limit {
        ArrayPush(items, this.GetItemDataEquippedInArea(gamedataEquipmentArea.Consumable, i));
        i += 1;
      };
      ArrayClear(this.m_ConsumablesSlotsData);
      this.m_ConsumablesSlotsData = items;
    };
    return this.m_ConsumablesSlotsData;
  }

  private final func GetPlayerCraftingMaterials() -> array<InventoryItemData> {
    let currentItemData: InventoryItemData;
    let inventoryItems: array<InventoryItemData>;
    let items: array<InventoryItemData> = this.GetPlayerInventoryData();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      currentItemData = items[i];
      if !InventoryItemData.IsEmpty(currentItemData) && InventoryItemData.IsCraftingMaterial(currentItemData) {
        ArrayPush(inventoryItems, currentItemData);
      };
      i += 1;
    };
    return inventoryItems;
  }

  public final func GetPlayerItemsByType(type: gamedataItemType, opt skipEquippedItems: Bool, opt additionalTagFilters: array<CName>, opt filteredItems: array<ItemModParams>) -> array<InventoryItemData> {
    let currentItemData: InventoryItemData;
    let inventoryItems: array<InventoryItemData>;
    let quantity: Int32;
    let quantityToFilterOut: Int32;
    let items: array<InventoryItemData> = this.GetPlayerInventoryData(additionalTagFilters);
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      currentItemData = items[i];
      quantityToFilterOut = this.GetQunatityToFilterOut(InventoryItemData.GetID(currentItemData), filteredItems);
      if !InventoryItemData.IsEmpty(currentItemData) && Equals(InventoryItemData.GetItemType(currentItemData), type) {
        if skipEquippedItems {
          if !InventoryItemData.IsEquipped(currentItemData) {
            quantity = InventoryItemData.GetQuantity(currentItemData) - quantityToFilterOut;
            InventoryItemData.SetQuantity(currentItemData, quantity);
            if quantity > 0 {
              ArrayPush(inventoryItems, currentItemData);
            };
          };
        } else {
          quantity = InventoryItemData.GetQuantity(currentItemData) - quantityToFilterOut;
          InventoryItemData.SetQuantity(currentItemData, quantity);
          if quantity > 0 {
            ArrayPush(inventoryItems, currentItemData);
          };
        };
      };
      i += 1;
    };
    return inventoryItems;
  }

  public final func GetPlayerItemsIDsByType(type: gamedataItemType, out items: array<ItemID>) -> Void {
    let unfilteredItems: array<wref<gameItemData>> = this.GetPlayerInventoryItems();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(unfilteredItems);
    while i < limit {
      if Equals(unfilteredItems[i].GetItemType(), type) {
        ArrayPush(items, unfilteredItems[i].GetID());
      };
      i += 1;
    };
  }

  public final func GetPlayerInventory(opt additionalTagFilters: array<CName>) -> array<wref<gameItemData>> {
    let inventoryItems: array<wref<gameItemData>>;
    let items: array<wref<gameItemData>> = this.GetPlayerItems();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      if !InventoryDataManagerV2.IsItemBlacklisted(items[i], additionalTagFilters) {
        ArrayPush(inventoryItems, items[i]);
      };
      i += 1;
    };
    return inventoryItems;
  }

  public final func EquipmentAreaToItemTypes(area: gamedataEquipmentArea) -> array<gamedataItemType> {
    let result: array<gamedataItemType>;
    switch area {
      case gamedataEquipmentArea.Face:
        ArrayPush(result, gamedataItemType.Clo_Face);
        break;
      case gamedataEquipmentArea.Feet:
        ArrayPush(result, gamedataItemType.Clo_Feet);
        break;
      case gamedataEquipmentArea.Head:
        ArrayPush(result, gamedataItemType.Clo_Head);
        break;
      case gamedataEquipmentArea.InnerChest:
        ArrayPush(result, gamedataItemType.Clo_InnerChest);
        break;
      case gamedataEquipmentArea.Legs:
        ArrayPush(result, gamedataItemType.Clo_Legs);
        break;
      case gamedataEquipmentArea.OuterChest:
        ArrayPush(result, gamedataItemType.Clo_OuterChest);
        break;
      case gamedataEquipmentArea.Consumable:
        ArrayPush(result, gamedataItemType.Con_Edible);
        ArrayPush(result, gamedataItemType.Con_Inhaler);
        ArrayPush(result, gamedataItemType.Con_Injector);
        ArrayPush(result, gamedataItemType.Con_LongLasting);
        break;
      case gamedataEquipmentArea.Gadget:
        ArrayPush(result, gamedataItemType.Gad_Grenade);
        break;
      case gamedataEquipmentArea.Weapon:
        ArrayPush(result, gamedataItemType.Wea_AssaultRifle);
        ArrayPush(result, gamedataItemType.Wea_Fists);
        ArrayPush(result, gamedataItemType.Wea_Hammer);
        ArrayPush(result, gamedataItemType.Wea_Handgun);
        ArrayPush(result, gamedataItemType.Wea_HeavyMachineGun);
        ArrayPush(result, gamedataItemType.Wea_Katana);
        ArrayPush(result, gamedataItemType.Wea_Knife);
        ArrayPush(result, gamedataItemType.Wea_LightMachineGun);
        ArrayPush(result, gamedataItemType.Wea_LongBlade);
        ArrayPush(result, gamedataItemType.Wea_Melee);
        ArrayPush(result, gamedataItemType.Wea_OneHandedClub);
        ArrayPush(result, gamedataItemType.Wea_PrecisionRifle);
        ArrayPush(result, gamedataItemType.Wea_Revolver);
        ArrayPush(result, gamedataItemType.Wea_Rifle);
        ArrayPush(result, gamedataItemType.Wea_ShortBlade);
        ArrayPush(result, gamedataItemType.Wea_Shotgun);
        ArrayPush(result, gamedataItemType.Wea_ShotgunDual);
        ArrayPush(result, gamedataItemType.Wea_SniperRifle);
        ArrayPush(result, gamedataItemType.Wea_SubmachineGun);
        ArrayPush(result, gamedataItemType.Wea_TwoHandedClub);
    };
    return result;
  }

  public final func GetPlayerItemsIDsByTypes(types: array<gamedataItemType>, out items: array<ItemID>) -> Void {
    let unfilteredItems: array<wref<gameItemData>> = this.GetPlayerInventoryItems();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(unfilteredItems);
    while i < limit {
      if ArrayContains(types, unfilteredItems[i].GetItemType()) {
        ArrayPush(items, unfilteredItems[i].GetID());
      };
      i += 1;
    };
  }

  public final func GetPlayerItemsIDs(opt item: InventoryItemData, opt slotID: TweakDBID, opt itemType: gamedataItemType, opt equipmentArea: gamedataEquipmentArea, opt skipEquipped: Bool, out items: array<ItemID>) -> Void {
    let i: Int32;
    let inventoryItems: array<InventoryItemData>;
    let itemID: ItemID;
    let limit: Int32;
    let localEquipmentArea: gamedataEquipmentArea;
    let unfilteredItems: array<wref<gameItemData>> = this.GetPlayerInventoryItems();
    if TDBID.IsValid(slotID) {
      inventoryItems = this.GetPlayerInventoryPartsForItem(InventoryItemData.GetID(item), slotID);
      i = 0;
      limit = ArraySize(inventoryItems);
      while i < limit {
        if skipEquipped {
          if InventoryItemData.IsEquipped(inventoryItems[i]) {
          } else {
            ArrayPush(items, InventoryItemData.GetID(inventoryItems[i]));
          };
        };
        ArrayPush(items, InventoryItemData.GetID(inventoryItems[i]));
        i += 1;
      };
    } else {
      if NotEquals(itemType, gamedataItemType.Invalid) {
        i = 0;
        limit = ArraySize(unfilteredItems);
        while i < limit {
          itemID = unfilteredItems[i].GetID();
          localEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
          if Equals(unfilteredItems[i].GetItemType(), itemType) {
            if skipEquipped {
              if this.m_EquipmentSystem.IsEquipped(this.m_Player, itemID, localEquipmentArea) {
              } else {
                ArrayPush(items, itemID);
              };
            };
            ArrayPush(items, itemID);
          };
          i += 1;
        };
      } else {
        if NotEquals(equipmentArea, gamedataEquipmentArea.Invalid) {
          i = 0;
          limit = ArraySize(unfilteredItems);
          while i < limit {
            itemID = unfilteredItems[i].GetID();
            localEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
            if Equals(localEquipmentArea, equipmentArea) {
              if skipEquipped {
                if this.m_EquipmentSystem.IsEquipped(this.m_Player, itemID, localEquipmentArea) {
                } else {
                  ArrayPush(items, itemID);
                };
              };
              ArrayPush(items, itemID);
            };
            i += 1;
          };
        };
      };
    };
  }

  public final func GetPlayerItemsIDsFast(opt item: ItemID, opt slotID: TweakDBID, opt itemType: gamedataItemType, opt equipmentArea: gamedataEquipmentArea, opt skipEquipped: Bool, out items: array<ItemID>) -> Void {
    let i: Int32;
    let inventoryItems: array<wref<gameItemData>>;
    let itemID: ItemID;
    let limit: Int32;
    let localEquipmentArea: gamedataEquipmentArea;
    let slots: array<TweakDBID>;
    let unfilteredItems: array<wref<gameItemData>>;
    if TDBID.IsValid(slotID) {
      ArrayPush(slots, slotID);
      inventoryItems = this.GetPlayerInventoryPartsDataForItem(item, slots);
      i = 0;
      limit = ArraySize(inventoryItems);
      while i < limit {
        if skipEquipped {
          if this.m_EquipmentSystem.IsEquipped(this.m_Player, inventoryItems[i].GetID()) {
          } else {
            ArrayPush(items, inventoryItems[i].GetID());
          };
        };
        ArrayPush(items, inventoryItems[i].GetID());
        i += 1;
      };
      return;
    };
    unfilteredItems = this.GetPlayerInventoryItems();
    if NotEquals(itemType, gamedataItemType.Invalid) {
      i = 0;
      limit = ArraySize(unfilteredItems);
      while i < limit {
        itemID = unfilteredItems[i].GetID();
        localEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
        if Equals(unfilteredItems[i].GetItemType(), itemType) {
          if skipEquipped {
            if this.m_EquipmentSystem.IsEquipped(this.m_Player, itemID, localEquipmentArea) {
            } else {
              ArrayPush(items, itemID);
            };
          };
          ArrayPush(items, itemID);
        };
        i += 1;
      };
    } else {
      if NotEquals(equipmentArea, gamedataEquipmentArea.Invalid) {
        i = 0;
        limit = ArraySize(unfilteredItems);
        while i < limit {
          itemID = unfilteredItems[i].GetID();
          localEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
          if Equals(localEquipmentArea, equipmentArea) {
            if skipEquipped {
              if this.m_EquipmentSystem.IsEquipped(this.m_Player, itemID, localEquipmentArea) {
              } else {
                ArrayPush(items, itemID);
              };
            };
            ArrayPush(items, itemID);
          };
          i += 1;
        };
      };
    };
  }

  public final func GetCachedInventoryItemData(itemData: wref<gameItemData>) -> InventoryItemData {
    let inventoryItemData: InventoryItemData;
    this.GetCachedInventoryItemData(itemData, inventoryItemData);
    return inventoryItemData;
  }

  public final func GetCachedInventoryItemData(itemData: wref<gameItemData>, out inventoryItemData: InventoryItemData, opt forceShowCurrencyOnHUDTooltip: Bool, opt isRadialQuerying: Bool) -> Void {
    let ID: ItemID;
    let isEquipped: Bool;
    let itemCategoryRecord: wref<ItemCategory_Record>;
    let itemRecord: wref<Item_Record>;
    let key: Uint64;
    let wrapper: ref<InventoryItemDataWrapper>;
    if IsDefined(itemData) && !InventoryDataManagerV2.IsItemBlacklisted(itemData, forceShowCurrencyOnHUDTooltip, isRadialQuerying) {
      ID = itemData.GetID();
      key = ItemID.GetCombinedHash(ID);
      if this.m_HashMapCache.KeyExist(key) {
        wrapper = this.m_HashMapCache.Get(key) as InventoryItemDataWrapper;
        if wrapper != null {
          inventoryItemData = wrapper.ItemData;
          InventoryItemData.SetQuantity(inventoryItemData, itemData.GetQuantity());
          InventoryItemData.SetAmmo(inventoryItemData, this.GetPlayerAmmoCount(ItemID.GetTDBID(itemData.GetID())));
          itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(inventoryItemData)));
          itemCategoryRecord = itemRecord.ItemCategory();
          if Equals(itemCategoryRecord.Type(), gamedataItemCategory.Gadget) || Equals(itemCategoryRecord.Type(), gamedataItemCategory.Consumable) {
            isEquipped = itemData.GetID() == this.m_EquipmentSystem.GetItemIDFromHotkey(this.m_Player, EHotkey.DPAD_UP) || itemData.GetID() == this.m_EquipmentSystem.GetItemIDFromHotkey(this.m_Player, EHotkey.RB);
          } else {
            isEquipped = this.m_EquipmentSystem.IsEquipped(this.m_Player, InventoryItemData.GetID(inventoryItemData));
          };
          InventoryItemData.SetIsEquipped(inventoryItemData, isEquipped);
          wrapper.ItemData = inventoryItemData;
          return;
        };
        this.m_HashMapCache.Remove(key);
      };
      inventoryItemData = this.GetInventoryItemDataInternal(this.m_Player, itemData);
      wrapper = new InventoryItemDataWrapper();
      wrapper.ItemData = inventoryItemData;
      this.m_HashMapCache.Insert(key, wrapper);
      ArrayPush(this.m_InventoryItemDataWrappers, wrapper);
    };
  }

  public final func GetOrCreateInventoryItemSortData(out inventoryItemData: InventoryItemData, scriptableSystem: wref<UIScriptableSystem>, opt rebuild: Bool) -> Void {
    let wrapper: ref<InventoryItemDataWrapper>;
    let ID: ItemID = InventoryItemData.GetID(inventoryItemData);
    let key: Uint64 = ItemID.GetCombinedHash(ID);
    if this.m_HashMapCache.KeyExist(key) {
      wrapper = this.m_HashMapCache.Get(key) as InventoryItemDataWrapper;
      if rebuild {
        wrapper = new InventoryItemDataWrapper();
        wrapper.ItemData = inventoryItemData;
        wrapper.SortData = ItemCompareBuilder.BuildInventoryItemSortData(wrapper.ItemData, scriptableSystem);
        wrapper.HasSortDataBuilt = true;
        this.m_HashMapCache.Set(key, wrapper);
      };
      if !wrapper.HasSortDataBuilt {
        wrapper.SortData = ItemCompareBuilder.BuildInventoryItemSortData(wrapper.ItemData, scriptableSystem);
        wrapper.HasSortDataBuilt = true;
      };
    } else {
      wrapper = new InventoryItemDataWrapper();
      wrapper.ItemData = inventoryItemData;
      wrapper.SortData = ItemCompareBuilder.BuildInventoryItemSortData(wrapper.ItemData, scriptableSystem);
      wrapper.HasSortDataBuilt = true;
      this.m_HashMapCache.Insert(key, wrapper);
    };
    InventoryItemData.SetSortData(inventoryItemData, wrapper.SortData);
  }

  public final func ClearInventoryItemDataCache() -> Void {
    this.m_HashMapCache.Clear();
  }

  public final func GetHotkeyItemData(hotkey: EHotkey) -> InventoryItemData {
    let localPlayer: ref<GameObject> = GameInstance.GetPlayerSystem(this.m_Player.GetGame()).GetLocalPlayerControlledGameObject();
    return this.GetItemDataFromIDInLoadout(this.m_EquipmentSystem.GetItemIDFromHotkey(localPlayer, hotkey));
  }

  public final func GetHotkeyTypeForItemID(itemID: ItemID, out hotkey: EHotkey) -> Bool {
    let localPlayer: ref<GameObject> = GameInstance.GetPlayerSystem(this.m_Player.GetGame()).GetLocalPlayerControlledGameObject();
    hotkey = this.m_EquipmentSystem.GetHotkeyTypeForItemID(localPlayer, itemID);
    return NotEquals(hotkey, EHotkey.INVALID);
  }

  public final func GetHotkeyTypeFromItemID(itemID: ItemID, out hotkey: EHotkey) -> Bool {
    let localPlayer: ref<GameObject> = GameInstance.GetPlayerSystem(this.m_Player.GetGame()).GetLocalPlayerControlledGameObject();
    hotkey = this.m_EquipmentSystem.GetHotkeyTypeFromItemID(localPlayer, itemID);
    return NotEquals(hotkey, EHotkey.INVALID);
  }

  public final func GetInventoryItemData(itemData: wref<gameItemData>) -> InventoryItemData {
    return this.GetInventoryItemData(this.m_Player, itemData);
  }

  public final func GetInventoryItemDataForDryItem(itemData: wref<gameItemData>) -> InventoryItemData {
    let abilities: array<InventoryItemAbility>;
    let attachments: array<InventoryItemAttachments>;
    let innerItemData: InnerItemData;
    let itemRecord: wref<Item_Record>;
    let parts: array<InnerItemData>;
    let inventoryItemData: InventoryItemData = this.GetInventoryItemData(this.m_Player, itemData);
    InventoryItemData.SetPrice(inventoryItemData, Cast(RPGManager.CalculateSellPriceItemData(this.m_Player.GetGame(), this.m_Player, itemData)));
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemData.GetID()));
    if itemRecord.IsPart() {
      itemData.GetItemParts(parts);
      innerItemData = parts[0];
      return this.GetPartInventoryItemData(this.m_Player, itemData.GetID(), innerItemData, itemData, itemRecord);
    };
    this.FillSpecialAbilities(itemRecord, abilities, itemData);
    this.GetAttachements(this.m_Player, itemData, attachments, abilities);
    InventoryItemData.SetAttachments(inventoryItemData, attachments);
    InventoryItemData.SetAbilities(inventoryItemData, abilities);
    return inventoryItemData;
  }

  public final func ShouldItemBeFiltered(item: ItemID, filteredItems: array<ItemModParams>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(filteredItems) {
      if filteredItems[i].itemID == item {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func GetQunatityToFilterOut(item: ItemID, filteredItems: array<ItemModParams>) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(filteredItems) {
      if filteredItems[i].itemID == item {
        return filteredItems[i].quantity;
      };
      i += 1;
    };
    return 0;
  }

  public final func GetInventoryItemData(owner: wref<GameObject>, itemData: wref<gameItemData>, opt forceShowCurrencyOnHUDTooltip: Bool, opt isRadialQuerying: Bool) -> InventoryItemData {
    let inventoryItemData: InventoryItemData = this.GetInventoryItemDataInternal(owner, itemData, forceShowCurrencyOnHUDTooltip, isRadialQuerying);
    return inventoryItemData;
  }

  private final func GetInventoryItemDataInternal(owner: wref<GameObject>, itemData: wref<gameItemData>, opt forceShowCurrencyOnHUDTooltip: Bool, opt isRadialQuerying: Bool) -> InventoryItemData {
    let abilities: array<InventoryItemAbility>;
    let attachments: array<InventoryItemAttachments>;
    let equipRecord: wref<EquipmentArea_Record>;
    let inventoryItemData: InventoryItemData;
    let isEquipped: Bool;
    let itemCategoryRecord: wref<ItemCategory_Record>;
    let itemRecord: wref<Item_Record>;
    let primaryStats: array<StatViewData>;
    let qualityName: CName;
    let secondaryStats: array<StatViewData>;
    let statsMapName: String;
    let tempItemType: wref<ItemType_Record>;
    if IsDefined(itemData) && !InventoryDataManagerV2.IsItemBlacklisted(itemData, forceShowCurrencyOnHUDTooltip, isRadialQuerying) {
      InventoryItemData.SetEmpty(inventoryItemData, false);
      InventoryItemData.SetGameItemData(inventoryItemData, itemData);
      InventoryItemData.SetID(inventoryItemData, itemData.GetID());
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(inventoryItemData)));
      if itemRecord.IsPart() {
        return this.GetPartInventoryItemData(owner, itemData);
      };
      tempItemType = itemRecord.ItemType();
      if IsDefined(tempItemType) {
        InventoryItemData.SetItemType(inventoryItemData, tempItemType.Type());
        InventoryItemData.SetLocalizedItemType(inventoryItemData, LocKeyToString(tempItemType.LocalizedType()));
      };
      InventoryItemData.SetIsCraftingMaterial(inventoryItemData, InventoryDataManagerV2.IsItemCraftingMaterial(itemData));
      itemCategoryRecord = itemRecord.ItemCategory();
      if IsDefined(itemCategoryRecord) {
        InventoryItemData.SetCategoryName(inventoryItemData, this.m_LocMgr.Localize(itemCategoryRecord.Name()));
      };
      if Equals(itemCategoryRecord.Type(), gamedataItemCategory.Gadget) || Equals(itemCategoryRecord.Type(), gamedataItemCategory.Consumable) {
        isEquipped = itemData.GetID() == this.m_EquipmentSystem.GetItemIDFromHotkey(this.m_Player, EHotkey.DPAD_UP) || itemData.GetID() == this.m_EquipmentSystem.GetItemIDFromHotkey(this.m_Player, EHotkey.RB);
      } else {
        isEquipped = this.m_EquipmentSystem.IsEquipped(this.m_Player, InventoryItemData.GetID(inventoryItemData));
      };
      InventoryItemData.SetIsEquipped(inventoryItemData, isEquipped);
      InventoryItemData.SetDescription(inventoryItemData, LocKeyToString(itemRecord.LocalizedDescription()));
      InventoryItemData.SetName(inventoryItemData, LocKeyToString(itemRecord.DisplayName()));
      InventoryItemData.SetQuantity(inventoryItemData, itemData.GetQuantity());
      InventoryItemData.SetAmmo(inventoryItemData, this.GetPlayerAmmoCount(ItemID.GetTDBID(itemData.GetID())));
      qualityName = UIItemsHelper.QualityEnumToName(RPGManager.GetItemDataQuality(itemData));
      InventoryItemData.SetQuality(inventoryItemData, qualityName);
      InventoryItemData.SetComparedQuality(inventoryItemData, RPGManager.GetItemDataQuality(itemData));
      InventoryItemData.SetShape(inventoryItemData, itemData.HasTag(n"inventoryDoubleSlot") ? EInventoryItemShape.DoubleSlot : EInventoryItemShape.SingleSlot);
      if itemData.HasStatData(gamedataStatType.Level) {
        InventoryItemData.SetRequiredLevel(inventoryItemData, FloorF(itemData.GetStatValueByType(gamedataStatType.Level)));
      } else {
        InventoryItemData.SetRequiredLevel(inventoryItemData, 0);
      };
      if itemData.HasStatData(gamedataStatType.ItemLevel) {
        InventoryItemData.SetItemLevel(inventoryItemData, FloorF(itemData.GetStatValueByType(gamedataStatType.ItemLevel)));
      } else {
        InventoryItemData.SetItemLevel(inventoryItemData, 0);
      };
      InventoryItemData.SetIconPath(inventoryItemData, itemRecord.IconPath());
      InventoryItemData.SetIconGender(inventoryItemData, this.m_ItemIconGender);
      equipRecord = itemRecord.EquipArea();
      if IsDefined(equipRecord) {
        InventoryItemData.SetEquipmentArea(inventoryItemData, equipRecord.Type());
      };
      this.FillSpecialAbilities(itemRecord, abilities, itemData);
      this.GetAttachements(owner, InventoryItemData.GetID(inventoryItemData), itemData, attachments, abilities);
      InventoryItemData.SetAttachments(inventoryItemData, attachments);
      InventoryItemData.SetAbilities(inventoryItemData, abilities);
      statsMapName = this.GetStatsUIMapName(InventoryItemData.GetID(inventoryItemData));
      if IsStringValid(statsMapName) {
        this.GetStatsList(TDBID.Create(statsMapName), itemData, primaryStats, secondaryStats);
        InventoryItemData.SetPrimaryStats(inventoryItemData, primaryStats);
        InventoryItemData.SetSecondaryStats(inventoryItemData, secondaryStats);
      };
      InventoryItemData.SetDamageType(inventoryItemData, InventoryDataManagerV2.GetWeaponDamageType(InventoryItemData.GetSecondaryStats(inventoryItemData)));
      InventoryItemData.SetPrice(inventoryItemData, Cast(RPGManager.CalculateSellPrice(owner.GetGame(), owner, itemData.GetID())));
      InventoryItemData.SetBuyPrice(inventoryItemData, Cast(MarketSystem.GetBuyPrice(owner, itemData.GetID())));
      InventoryItemData.SetIsBroken(inventoryItemData, RPGManager.IsItemBroken(itemData));
      InventoryItemData.SetSlotIndex(inventoryItemData, this.m_EquipmentSystem.GetItemSlotIndex(owner, itemData.GetID()));
      this.SetPlayerStats(inventoryItemData);
    };
    return inventoryItemData;
  }

  public final func GetInventoryItemDataFromItemRecord(itemRecord: ref<Item_Record>) -> InventoryItemData {
    let inventoryItemData: InventoryItemData = this.GetInventoryItemDataFromItemRecordInternal(itemRecord);
    let wrapper: ref<InventoryItemDataWrapper> = new InventoryItemDataWrapper();
    wrapper.ItemData = inventoryItemData;
    ArrayPush(this.m_InventoryItemDataWrappers, wrapper);
    return inventoryItemData;
  }

  private final func GetInventoryItemDataFromItemRecordInternal(itemRecord: ref<Item_Record>) -> InventoryItemData {
    let equipRecord: wref<EquipmentArea_Record>;
    let i: Int32;
    let inventoryItemData: InventoryItemData;
    let itemCategoryRecord: wref<ItemCategory_Record>;
    let itemRecordTags: array<CName>;
    let tempItemType: wref<ItemType_Record>;
    InventoryItemData.SetEmpty(inventoryItemData, false);
    tempItemType = itemRecord.ItemType();
    if IsDefined(tempItemType) {
      InventoryItemData.SetItemType(inventoryItemData, tempItemType.Type());
      InventoryItemData.SetLocalizedItemType(inventoryItemData, LocKeyToString(tempItemType.LocalizedType()));
    };
    InventoryItemData.SetDescription(inventoryItemData, LocKeyToString(itemRecord.LocalizedDescription()));
    InventoryItemData.SetName(inventoryItemData, LocKeyToString(itemRecord.DisplayName()));
    InventoryItemData.SetIconPath(inventoryItemData, itemRecord.IconPath());
    InventoryItemData.SetIconGender(inventoryItemData, this.m_ItemIconGender);
    equipRecord = itemRecord.EquipArea();
    if IsDefined(equipRecord) {
      InventoryItemData.SetEquipmentArea(inventoryItemData, equipRecord.Type());
    };
    InventoryItemData.SetID(inventoryItemData, ItemID.CreateQuery(itemRecord.GetID()));
    InventoryItemData.SetQuality(inventoryItemData, StringToName(itemRecord.Quality().Name()));
    InventoryItemData.SetQuantity(inventoryItemData, this.m_TransactionSystem.GetItemQuantity(this.m_Player, InventoryItemData.GetID(inventoryItemData)));
    InventoryItemData.SetAmmo(inventoryItemData, this.GetPlayerAmmoCount(ItemID.GetTDBID(InventoryItemData.GetID(inventoryItemData))));
    InventoryItemData.SetShape(inventoryItemData, EInventoryItemShape.SingleSlot);
    InventoryItemData.SetGameItemData(inventoryItemData, RPGManager.GetItemData(this.m_Player.GetGame(), this.m_Player, InventoryItemData.GetID(inventoryItemData)));
    itemCategoryRecord = itemRecord.ItemCategory();
    if IsDefined(itemCategoryRecord) {
      InventoryItemData.SetCategoryName(inventoryItemData, this.m_LocMgr.Localize(itemCategoryRecord.Name()));
    };
    itemRecordTags = itemRecord.Tags();
    i = 0;
    while i < ArraySize(itemRecordTags) {
      if Equals(itemRecordTags[i], n"inventoryDoubleSlot") {
        InventoryItemData.SetShape(inventoryItemData, EInventoryItemShape.DoubleSlot);
      } else {
        i += 1;
      };
    };
    this.SetPlayerStats(inventoryItemData);
    return inventoryItemData;
  }

  private final func GetPartInventoryItemData(owner: wref<GameObject>, itemData: wref<gameItemData>) -> InventoryItemData {
    let innerItemData: InnerItemData;
    let parts: array<InnerItemData>;
    itemData.GetItemParts(parts);
    innerItemData = parts[0];
    return this.GetPartInventoryItemData(owner, InnerItemData.GetItemID(innerItemData), innerItemData, itemData);
  }

  private final func GetPartInventoryItemData(owner: wref<GameObject>, slotData: SPartSlots, itemData: wref<gameItemData>) -> InventoryItemData {
    return this.GetPartInventoryItemData(owner, slotData.installedPart, slotData.innerItemData, itemData);
  }

  public final func GetPlayerAmmoCount(targetItem: TweakDBID) -> Int32 {
    let ammoQuery: ItemID;
    let category: gamedataItemCategory;
    let itemRecord: ref<Item_Record>;
    let weaponRecord: ref<WeaponItem_Record>;
    if this.m_Player != null {
      itemRecord = TweakDBInterface.GetItemRecord(targetItem);
      category = itemRecord.ItemCategory().Type();
      if Equals(category, gamedataItemCategory.Weapon) {
        weaponRecord = itemRecord as WeaponItem_Record;
        ammoQuery = ItemID.CreateQuery(weaponRecord.Ammo().GetID());
        return this.m_TransactionSystem.GetItemQuantity(this.m_Player, ammoQuery);
      };
    };
    return -1;
  }

  public final func GetPlayerAmmoCount(itemRecord: wref<Item_Record>) -> Int32 {
    let ammoQuery: ItemID;
    let category: gamedataItemCategory;
    let weaponRecord: ref<WeaponItem_Record>;
    if this.m_Player != null {
      category = itemRecord.ItemCategory().Type();
      if Equals(category, gamedataItemCategory.Weapon) {
        weaponRecord = itemRecord as WeaponItem_Record;
        ammoQuery = ItemID.CreateQuery(weaponRecord.Ammo().GetID());
        return this.m_TransactionSystem.GetItemQuantity(this.m_Player, ammoQuery);
      };
    };
    return -1;
  }

  public final func GetAmmoTypeForWeapon(targetItem: TweakDBID) -> TweakDBID {
    let category: gamedataItemCategory;
    let itemRecord: ref<Item_Record>;
    let weaponRecord: ref<WeaponItem_Record>;
    if this.m_Player != null {
      itemRecord = TweakDBInterface.GetItemRecord(targetItem);
      category = itemRecord.ItemCategory().Type();
      if Equals(category, gamedataItemCategory.Weapon) {
        weaponRecord = itemRecord as WeaponItem_Record;
        return weaponRecord.Ammo().GetID();
      };
    };
    return TDBID.undefined();
  }

  private final func GetPartInventoryItemData(owner: wref<GameObject>, itemId: ItemID, innerItemData: InnerItemData, opt itemData: wref<gameItemData>, opt record: wref<Item_Record>) -> InventoryItemData {
    let abilities: array<InventoryItemAbility>;
    let i: Int32;
    let inventoryItemData: InventoryItemData;
    let itemCategoryRecord: wref<ItemCategory_Record>;
    let itemRecord: wref<Item_Record>;
    let placementSlots: array<wref<AttachmentSlot_Record>>;
    let primaryStats: array<StatViewData>;
    let qualityName: CName;
    let secondaryStats: array<StatViewData>;
    let statsMapName: String;
    let tempItemType: wref<ItemType_Record>;
    if ItemID.IsValid(itemId) {
      InventoryItemData.SetEmpty(inventoryItemData, false);
      InventoryItemData.SetGameItemData(inventoryItemData, itemData);
      InventoryItemData.SetID(inventoryItemData, itemId);
      InventoryItemData.SetSlotID(inventoryItemData, InnerItemData.GetSlotID(innerItemData));
      itemRecord = InnerItemData.GetStaticData(innerItemData);
      if !IsDefined(itemRecord) {
        if IsDefined(record) {
          itemRecord = record;
        } else {
          itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemId));
        };
      };
      itemCategoryRecord = itemRecord.ItemCategory();
      if IsDefined(itemCategoryRecord) {
        InventoryItemData.SetCategoryName(inventoryItemData, this.m_LocMgr.Localize(itemCategoryRecord.Name()));
      };
      tempItemType = itemRecord.ItemType();
      if IsDefined(tempItemType) {
        InventoryItemData.SetItemType(inventoryItemData, tempItemType.Type());
        InventoryItemData.SetLocalizedItemType(inventoryItemData, LocKeyToString(tempItemType.LocalizedType()));
      };
      InventoryItemData.SetDescription(inventoryItemData, LocKeyToString(itemRecord.LocalizedDescription()));
      InventoryItemData.SetName(inventoryItemData, LocKeyToString(itemRecord.DisplayName()));
      InventoryItemData.SetQuantity(inventoryItemData, 1);
      if InnerItemData.HasStatData(innerItemData, gamedataStatType.Quality) {
        qualityName = UIItemsHelper.QualityEnumToName(RPGManager.GetInnerItemDataQuality(innerItemData));
        InventoryItemData.SetQuality(inventoryItemData, qualityName);
        InventoryItemData.SetComparedQuality(inventoryItemData, RPGManager.GetInnerItemDataQuality(innerItemData));
      } else {
        if IsDefined(itemData) {
          qualityName = UIItemsHelper.QualityEnumToName(RPGManager.GetItemDataQuality(itemData));
          InventoryItemData.SetQuality(inventoryItemData, qualityName);
          InventoryItemData.SetComparedQuality(inventoryItemData, RPGManager.GetItemDataQuality(itemData));
        };
      };
      if IsDefined(itemData) {
        InventoryItemData.SetShape(inventoryItemData, itemData.HasTag(n"inventoryDoubleSlot") ? EInventoryItemShape.DoubleSlot : EInventoryItemShape.SingleSlot);
      };
      if InnerItemData.HasStatData(innerItemData, gamedataStatType.Level) {
        InventoryItemData.SetRequiredLevel(inventoryItemData, RoundMath(InnerItemData.GetStatValueByType(innerItemData, gamedataStatType.Level)));
      } else {
        InventoryItemData.SetRequiredLevel(inventoryItemData, 0);
      };
      if IsDefined(itemData) && itemData.HasStatData(gamedataStatType.ItemLevel) {
        InventoryItemData.SetItemLevel(inventoryItemData, FloorF(itemData.GetStatValueByType(gamedataStatType.ItemLevel)));
      } else {
        InventoryItemData.SetItemLevel(inventoryItemData, 0);
      };
      InventoryItemData.SetIconPath(inventoryItemData, itemRecord.IconPath());
      InventoryItemData.SetIconGender(inventoryItemData, this.m_ItemIconGender);
      if !itemData.HasTag(n"DummyPart") {
        this.FillSpecialAbilities(itemRecord, abilities, itemData, innerItemData);
        InventoryItemData.SetAbilities(inventoryItemData, abilities);
      };
      statsMapName = this.GetStatsUIMapName(itemId);
      if IsStringValid(statsMapName) {
        this.GetStatsList(TDBID.Create(statsMapName), innerItemData, primaryStats, secondaryStats);
        InventoryItemData.SetPrimaryStats(inventoryItemData, primaryStats);
        InventoryItemData.SetSecondaryStats(inventoryItemData, secondaryStats);
      };
      InventoryItemData.SetDamageType(inventoryItemData, InventoryDataManagerV2.GetWeaponDamageType(InventoryItemData.GetSecondaryStats(inventoryItemData)));
      InventoryItemData.SetPrice(inventoryItemData, Cast(RPGManager.CalculateSellPrice(owner.GetGame(), owner, itemId)));
      InventoryItemData.SetBuyPrice(inventoryItemData, Cast(MarketSystem.GetBuyPrice(owner, itemId)));
      InventoryItemData.SetIsPart(inventoryItemData, true);
      InnerItemData.GetStaticData(innerItemData).PlacementSlots(placementSlots);
      i = 0;
      while i < ArraySize(placementSlots) {
        InventoryItemData.AddPlacementSlot(inventoryItemData, placementSlots[i].GetID());
        i += 1;
      };
      this.SetPlayerStats(inventoryItemData);
    };
    return inventoryItemData;
  }

  public final func GetTooltipDataForInventoryItem(tooltipItemData: InventoryItemData, equipped: Bool, iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt vendorItem: Bool, opt overrideRarity: Bool) -> ref<InventoryTooltipData> {
    let result: ref<InventoryTooltipData> = this.GetTooltipDataForInventoryItem(tooltipItemData, equipped, vendorItem, overrideRarity);
    result.DEBUG_iconErrorInfo = iconErrorInfo;
    return result;
  }

  public final func GetTooltipDataForInventoryItem(tooltipItemData: InventoryItemData, equipped: Bool, opt vendorItem: Bool, opt overrideRarity: Bool) -> ref<InventoryTooltipData> {
    let tooltipData: ref<InventoryTooltipData> = InventoryTooltipData.FromInventoryItemData(tooltipItemData);
    if equipped {
      tooltipData.isEquipped = true;
    };
    tooltipData.isVendorItem = vendorItem;
    tooltipData.quickhackData = this.GetQuickhackTooltipData(tooltipItemData);
    tooltipData.grenadeData = this.GetGrenadeTooltipData(tooltipItemData);
    tooltipData.overrideRarity = overrideRarity;
    return tooltipData;
  }

  public final func GetGrenadeTooltipData(tooltipItemData: InventoryItemData) -> ref<InventoryTooltiData_GrenadeData> {
    return this.GetGrenadeTooltipData(ItemID.GetTDBID(InventoryItemData.GetID(tooltipItemData)), InventoryItemData.GetGameItemData(tooltipItemData));
  }

  public final func GetGrenadeTooltipData(itemID: TweakDBID, itemData: wref<gameItemData>) -> ref<InventoryTooltiData_GrenadeData> {
    let continousEffector: wref<ContinuousAttackEffector_Record>;
    let deliveryRecord: wref<GrenadeDeliveryMethod_Record>;
    let result: ref<InventoryTooltiData_GrenadeData>;
    let grenadeRecord: wref<Grenade_Record> = TweakDBInterface.GetGrenadeRecord(itemID);
    if IsDefined(grenadeRecord) {
      result = new InventoryTooltiData_GrenadeData();
      continousEffector = this.GetGrenadeContinousEffector(grenadeRecord.Attack());
      result.range = this.GetGrenadeRange(grenadeRecord);
      deliveryRecord = grenadeRecord.DeliveryMethod();
      result.deliveryMethod = deliveryRecord.Type().Type();
      result.detonationTimer = deliveryRecord.DetonationTimer();
      if IsDefined(continousEffector) {
        result.duration = this.GetGrenadeDuration(grenadeRecord.Attack());
        result.delay = this.GetGrenadeDelay(continousEffector);
        result.damagePerTick = this.GetGrenadeDoTTickDamage(continousEffector);
        result.type = GrenadeDamageType.DoT;
        result.totalDamage = result.damagePerTick * result.duration / result.delay;
      } else {
        result.type = GrenadeDamageType.Normal;
        result.totalDamage = this.GetGrenadeTotalDamageFromStats(itemData);
      };
    };
    return result;
  }

  private final func GetGrenadeContinousEffector(attackRecord: wref<Attack_Record>) -> wref<ContinuousAttackEffector_Record> {
    let continuousAttackEffector: wref<ContinuousAttackEffector_Record>;
    let i: Int32;
    let j: Int32;
    let k: Int32;
    let statusEffectEffectors: array<wref<Effector_Record>>;
    let statusEffectPackages: array<wref<GameplayLogicPackage_Record>>;
    let statusEffects: array<wref<StatusEffectAttackData_Record>>;
    attackRecord.StatusEffects(statusEffects);
    i = 0;
    while i < ArraySize(statusEffects) {
      statusEffects[i].StatusEffect().Packages(statusEffectPackages);
      j = 0;
      while j < ArraySize(statusEffectPackages) {
        statusEffectPackages[j].Effectors(statusEffectEffectors);
        k = 0;
        while k < ArraySize(statusEffectEffectors) {
          if Equals(statusEffectEffectors[k].EffectorClassName(), n"TriggerContinuousAttackEffector") {
            continuousAttackEffector = statusEffectEffectors[k] as ContinuousAttackEffector_Record;
            if IsDefined(continuousAttackEffector) {
              return continuousAttackEffector;
            };
          };
          k += 1;
        };
        j += 1;
      };
      i += 1;
    };
    return null;
  }

  private final func GetGrenadeTotalDamageFromStats(itemData: wref<gameItemData>) -> Float {
    let damageData: array<ref<InventoryTooltiData_GrenadeDamageData>>;
    let i: Int32;
    let result: Float;
    this.GetGrenadeDamageStats(itemData, damageData);
    i = 0;
    while i < ArraySize(damageData) {
      result += damageData[i].value;
      i += 1;
    };
    return result;
  }

  private final func GetGrenadeDamageStats(itemData: wref<gameItemData>, outputArray: script_ref<array<ref<InventoryTooltiData_GrenadeDamageData>>>) -> Void {
    let damageData: ref<InventoryTooltiData_GrenadeDamageData>;
    let value: Float = itemData.GetStatValueByType(gamedataStatType.BaseDamage);
    if value > 0.00 {
      damageData = new InventoryTooltiData_GrenadeDamageData();
      damageData.statType = gamedataStatType.BaseDamage;
      damageData.value = value;
      ArrayPush(Deref(outputArray), damageData);
    };
    value = itemData.GetStatValueByType(gamedataStatType.PhysicalDamage);
    if value > 0.00 {
      damageData = new InventoryTooltiData_GrenadeDamageData();
      damageData.statType = gamedataStatType.PhysicalDamage;
      damageData.value = value;
      ArrayPush(Deref(outputArray), damageData);
    };
    value = itemData.GetStatValueByType(gamedataStatType.ChemicalDamage);
    if value > 0.00 {
      damageData = new InventoryTooltiData_GrenadeDamageData();
      damageData.statType = gamedataStatType.ChemicalDamage;
      damageData.value = value;
      ArrayPush(Deref(outputArray), damageData);
    };
    value = itemData.GetStatValueByType(gamedataStatType.ElectricDamage);
    if value > 0.00 {
      damageData = new InventoryTooltiData_GrenadeDamageData();
      damageData.statType = gamedataStatType.ElectricDamage;
      damageData.value = value;
      ArrayPush(Deref(outputArray), damageData);
    };
    value = itemData.GetStatValueByType(gamedataStatType.ThermalDamage);
    if value > 0.00 {
      damageData = new InventoryTooltiData_GrenadeDamageData();
      damageData.statType = gamedataStatType.ThermalDamage;
      damageData.value = value;
      ArrayPush(Deref(outputArray), damageData);
    };
  }

  private final func GetGrenadeDoTTickDamage(continuousAttackEffector: wref<ContinuousAttackEffector_Record>) -> Float {
    let continuousAttackRecord: wref<Attack_Record>;
    let continuousAttackStatModifiers: array<wref<StatModifier_Record>>;
    if IsDefined(continuousAttackEffector) {
      continuousAttackRecord = continuousAttackEffector.AttackRecord();
      continuousAttackRecord.StatModifiers(continuousAttackStatModifiers);
      return RPGManager.CalculateStatModifiers(continuousAttackStatModifiers, this.m_Player.GetGame(), this.m_Player, Cast(this.m_Player.GetEntityID()));
    };
    return 0.00;
  }

  private final func GetGrenadeRange(grenadeRecord: wref<Grenade_Record>) -> Float {
    let i: Int32;
    let statModifier: array<wref<StatModifier_Record>>;
    let result: Float = grenadeRecord.AttackRadius();
    grenadeRecord.StatModifiers(statModifier);
    i = ArraySize(statModifier) - 1;
    while i > 0 {
      if Equals(statModifier[i].StatType().StatType(), gamedataStatType.Range) {
        if IsDefined(statModifier[i] as CombinedStatModifier_Record) {
          result = (statModifier[i] as CombinedStatModifier_Record).Value();
        };
        if IsDefined(statModifier[i] as ConstantStatModifier_Record) {
          result = (statModifier[i] as ConstantStatModifier_Record).Value();
        };
      };
      i -= 1;
    };
    return result;
  }

  private final func GetGrenadeDuration(attackRecord: wref<Attack_Record>) -> Float {
    let durationModifiersRecord: wref<StatModifierGroup_Record>;
    let durationStatModifiers: array<wref<StatModifier_Record>>;
    let i: Int32;
    let statusEffects: array<wref<StatusEffectAttackData_Record>>;
    attackRecord.StatusEffects(statusEffects);
    i = 0;
    while i < ArraySize(statusEffects) {
      durationModifiersRecord = statusEffects[i].StatusEffect().Duration();
      if IsDefined(durationModifiersRecord) {
        durationModifiersRecord.StatModifiers(durationStatModifiers);
        return RPGManager.CalculateStatModifiers(durationStatModifiers, this.m_Player.GetGame(), this.m_Player, Cast(this.m_Player.GetEntityID()));
      };
      i += 1;
    };
    return 0.00;
  }

  private final func GetGrenadeDelay(continuousAttackEffector: wref<ContinuousAttackEffector_Record>) -> Float {
    if IsDefined(continuousAttackEffector) {
      return continuousAttackEffector.DelayTime();
    };
    return 0.00;
  }

  private final func GetIgnoredDurationStats() -> array<wref<StatusEffect_Record>> {
    let result: array<wref<StatusEffect_Record>>;
    ArrayPush(result, TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.WasQuickHacked"));
    ArrayPush(result, TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.QuickHackUploaded"));
    return result;
  }

  private final func GetQuickhackTooltipData(tooltipItemData: InventoryItemData) -> InventoryTooltipData_QuickhackData {
    return this.GetQuickhackTooltipData(ItemID.GetTDBID(InventoryItemData.GetID(tooltipItemData)));
  }

  public final func GetQuickhackTooltipData(itemID: TweakDBID) -> InventoryTooltipData_QuickhackData {
    let actionRecord: wref<ObjectAction_Record>;
    let actionStartEffects: array<wref<ObjectActionEffect_Record>>;
    let actions: array<wref<ObjectAction_Record>>;
    let baseStatModifiers: array<wref<StatModifier_Record>>;
    let dummyEntityID: EntityID;
    let duration: wref<StatModifierGroup_Record>;
    let durationMods: array<wref<ObjectActionEffect_Record>>;
    let effectToCast: wref<StatusEffect_Record>;
    let effects: array<ref<DamageEffectUIEntry>>;
    let emptyObject: ref<GameObject>;
    let gameInstance: GameInstance;
    let i: Int32;
    let ignoredDurationStats: array<wref<StatusEffect_Record>>;
    let j: Int32;
    let lastMatchingEffect: wref<StatusEffect_Record>;
    let quickhackData: InventoryTooltipData_QuickhackData;
    let shouldHideCooldown: Bool;
    let shouldHideDuration: Bool;
    let statModifiers: array<wref<StatModifier_Record>>;
    let tweakRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(itemID);
    let baseActionRecord: wref<ObjectAction_Record> = this.GetQuickhackBaseObjectActionRecord();
    let baseCooldownRecord: wref<StatModifierGroup_Record> = this.GetBaseQuickhackCooldownRecord();
    if NotEquals(tweakRecord.ItemType().Type(), gamedataItemType.Prt_Program) {
      return quickhackData;
    };
    ignoredDurationStats = this.GetIgnoredDurationStats();
    gameInstance = this.m_Player.GetGame();
    tweakRecord.ObjectActions(actions);
    actionRecord = actions[0];
    shouldHideCooldown = TweakDBInterface.GetBool(actionRecord.GetID() + t".hideCooldownUI", false);
    shouldHideDuration = TweakDBInterface.GetBool(actionRecord.GetID() + t".hideDurationUI", false);
    quickhackData.baseCost = BaseScriptableAction.GetBaseCostStatic(this.m_Player, actionRecord);
    quickhackData.memorycost = quickhackData.baseCost;
    ArrayClear(statModifiers);
    if !shouldHideDuration {
      ArrayClear(durationMods);
      actionRecord.CompletionEffects(durationMods);
      i = 0;
      while i < ArraySize(durationMods) {
        if !InventoryDataManagerV2.ProcessQuickhackEffects(this.m_Player, durationMods[i].StatusEffect(), effects) {
        } else {
          j = 0;
          while j < ArraySize(effects) {
            ArrayPush(quickhackData.attackEffects, effects[j]);
            j += 1;
          };
        };
        i += 1;
      };
      if ArraySize(durationMods) > 0 {
        i = 0;
        while i < ArraySize(durationMods) {
          effectToCast = durationMods[i].StatusEffect();
          if IsDefined(effectToCast) {
            if !ArrayContains(ignoredDurationStats, effectToCast) {
              lastMatchingEffect = effectToCast;
            };
          };
          i += 1;
        };
        effectToCast = lastMatchingEffect;
        duration = effectToCast.Duration();
        duration.StatModifiers(statModifiers);
        quickhackData.duration = RPGManager.CalculateStatModifiers(statModifiers, gameInstance, emptyObject, Cast(dummyEntityID), Cast(this.m_Player.GetEntityID()));
      };
    };
    ArrayClear(statModifiers);
    ArrayClear(baseStatModifiers);
    actionRecord.ActivationTime(statModifiers);
    baseActionRecord.ActivationTime(baseStatModifiers);
    statModifiers = this.StatModifiersExcept(statModifiers, baseStatModifiers);
    quickhackData.uploadTime = RPGManager.CalculateStatModifiers(statModifiers, gameInstance, this.m_Player, Cast(dummyEntityID), Cast(this.m_Player.GetEntityID()));
    if !shouldHideCooldown {
      ArrayClear(actionStartEffects);
      actionRecord.StartEffects(actionStartEffects);
      i = 0;
      while i < ArraySize(actionStartEffects) {
        if Equals(actionStartEffects[i].StatusEffect().StatusEffectType().Type(), gamedataStatusEffectType.PlayerCooldown) {
          ArrayClear(statModifiers);
          ArrayClear(baseStatModifiers);
          actionStartEffects[i].StatusEffect().Duration().StatModifiers(statModifiers);
          baseCooldownRecord.StatModifiers(baseStatModifiers);
          statModifiers = this.StatModifiersExcept(statModifiers, baseStatModifiers);
          quickhackData.cooldown = RPGManager.CalculateStatModifiers(statModifiers, gameInstance, this.m_Player, Cast(dummyEntityID), Cast(this.m_Player.GetEntityID()));
        };
        if quickhackData.cooldown != 0.00 {
        } else {
          i += 1;
        };
      };
    };
    return quickhackData;
  }

  public final func GetQuickhackBaseObjectActionRecord() -> wref<ObjectAction_Record> {
    return TweakDBInterface.GetObjectActionRecord(t"QuickHack.QuickHack");
  }

  public final func GetBaseQuickhackCooldownRecord() -> wref<StatModifierGroup_Record> {
    return TweakDBInterface.GetStatModifierGroupRecord(t"BaseStatusEffect.QuickHackCooldownDuration");
  }

  public final func StatModifiersExcept(statModifiers: array<wref<StatModifier_Record>>, except: array<wref<StatModifier_Record>>) -> array<wref<StatModifier_Record>> {
    let result: array<wref<StatModifier_Record>>;
    let i: Int32 = 0;
    while i < ArraySize(statModifiers) {
      if !ArrayContains(except, statModifiers[i]) {
        ArrayPush(result, statModifiers[i]);
      };
      i += 1;
    };
    return result;
  }

  public final static func ProcessQuickhackEffects(player: ref<GameObject>, statusEffectRecord: wref<StatusEffect_Record>, out result: array<ref<DamageEffectUIEntry>>) -> Bool {
    let attackRecord: wref<Attack_Record>;
    let attackRecordStatModifiers: array<wref<StatModifier_Record>>;
    let durationRecordStatModifiers: array<wref<StatModifier_Record>>;
    let effector: wref<Effector_Record>;
    let effectorAsContinousAttack: wref<ContinuousAttackEffector_Record>;
    let effectorAsTriggerAttack: wref<TriggerAttackEffector_Record>;
    let effectors: array<wref<Effector_Record>>;
    let i: Int32;
    let isContinuous: Bool;
    let j: Int32;
    let mult: Float;
    let resultEntry: ref<DamageEffectUIEntry>;
    let statusEffectPackages: array<wref<GameplayLogicPackage_Record>>;
    if !IsDefined(statusEffectRecord) {
      return false;
    };
    if statusEffectRecord.GetPackagesCount() <= 0 {
      return false;
    };
    if statusEffectRecord.Duration().GetStatModifiersCount() > 0 {
      ArrayClear(durationRecordStatModifiers);
      statusEffectRecord.Duration().StatModifiers(durationRecordStatModifiers);
    };
    ArrayClear(statusEffectPackages);
    statusEffectRecord.Packages(statusEffectPackages);
    i = 0;
    while i < ArraySize(statusEffectPackages) {
      if statusEffectPackages[i].GetEffectorsCount() <= 0 {
      } else {
        ArrayClear(effectors);
        statusEffectPackages[i].Effectors(effectors);
        j = 0;
        while j < ArraySize(effectors) {
          effector = effectors[j];
          effectorAsTriggerAttack = effector as TriggerAttackEffector_Record;
          attackRecord = null;
          if IsDefined(effectorAsTriggerAttack) {
            attackRecord = effectorAsTriggerAttack.AttackRecord();
          } else {
            effectorAsContinousAttack = effector as ContinuousAttackEffector_Record;
            if IsDefined(effectorAsContinousAttack) {
              attackRecord = effectorAsContinousAttack.AttackRecord();
              isContinuous = true;
              mult = effectorAsContinousAttack.DelayTime();
              if mult > 0.00 {
                mult = 1.00 / mult;
              };
            };
          };
          if !IsDefined(attackRecord) {
          } else {
            if attackRecord.GetStatModifiersCount() <= 0 {
            } else {
              ArrayClear(attackRecordStatModifiers);
              attackRecord.StatModifiers(attackRecordStatModifiers);
              resultEntry = new DamageEffectUIEntry();
              resultEntry.valueToDisplay = RPGManager.CalculateStatModifiers(attackRecordStatModifiers, player.GetGame(), player, Cast(player.GetEntityID()), Cast(player.GetEntityID()));
              resultEntry.valueToDisplay = resultEntry.valueToDisplay <= 1.00 ? 1.00 : resultEntry.valueToDisplay;
              if mult > 0.00 {
                resultEntry.valueToDisplay = resultEntry.valueToDisplay * mult;
              };
              resultEntry.valueStat = attackRecordStatModifiers[0].StatType().StatType();
              resultEntry.targetStat = gamedataStatType.Invalid;
              resultEntry.displayType = isContinuous ? DamageEffectDisplayType.Invalid : DamageEffectDisplayType.Flat;
              resultEntry.effectorDuration = RPGManager.CalculateStatModifiers(durationRecordStatModifiers, player.GetGame(), player, Cast(player.GetEntityID()), Cast(player.GetEntityID()));
              resultEntry.effectorDuration = resultEntry.effectorDuration <= 1.00 ? 0.00 : resultEntry.effectorDuration;
              resultEntry.isContinuous = isContinuous;
              if isContinuous {
                ArrayInsert(result, 0, resultEntry);
              } else {
                ArrayPush(result, resultEntry);
              };
            };
          };
          j += 1;
        };
      };
      i += 1;
    };
    if ArraySize(result) > 0 {
      return true;
    };
    return false;
  }

  public final func GetTooltipForEmptySlot(slot: String) -> ref<MessageTooltipData> {
    let toolTipData: ref<MessageTooltipData> = new MessageTooltipData();
    toolTipData.Title = slot;
    return toolTipData;
  }

  public final func GetPlayerItemStats(itemId: ItemID, opt compareItemId: ItemID) -> ItemViewData {
    let compareItemData: wref<gameItemData>;
    let itemData: wref<gameItemData>;
    if ItemID.IsValid(compareItemId) {
      compareItemData = this.m_TransactionSystem.GetItemData(this.m_Player, compareItemId);
    };
    itemData = this.m_TransactionSystem.GetItemData(this.m_Player, itemId);
    return this.GetItemStatsByData(itemData, compareItemData);
  }

  public final func GetItemStatsByData(itemData: wref<gameItemData>, opt compareWithData: wref<gameItemData>) -> ItemViewData {
    let quality: gamedataQuality;
    let statsMapName: String;
    let viewData: ItemViewData;
    let itemId: ItemID = itemData.GetID();
    let itemRecord: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemId));
    let itemCategoryRecord: wref<ItemCategory_Record> = itemRecord.ItemCategory();
    viewData.id = itemId;
    viewData.itemName = LocKeyToString(itemRecord.DisplayName());
    viewData.categoryName = this.m_LocMgr.Localize(itemCategoryRecord.Name());
    viewData.description = LocKeyToString(itemRecord.LocalizedDescription());
    if itemData.HasStatData(gamedataStatType.Quality) {
      quality = RPGManager.GetItemDataQuality(itemData);
      viewData.quality = NameToString(UIItemsHelper.QualityEnumToName(quality));
    } else {
      viewData.quality = itemRecord.Quality().Name();
    };
    statsMapName = this.GetStatsUIMapName(itemId);
    if IsStringValid(statsMapName) {
      this.GetStatsList(TDBID.Create(statsMapName), itemData, viewData.primaryStats, viewData.secondaryStats, compareWithData);
    };
    if compareWithData.HasStatData(gamedataStatType.Quality) {
      viewData.comparedQuality = RPGManager.GetItemDataQuality(compareWithData);
    };
    viewData.isBroken = RPGManager.IsItemBroken(itemData);
    viewData.price = Cast(RPGManager.CalculateSellPrice(this.m_Player.GetGame(), this.m_Player, itemData.GetID()));
    return viewData;
  }

  public final func GetSellPrice(owner: wref<GameObject>, itemID: ItemID) -> Float {
    return Cast(RPGManager.CalculateSellPrice(this.m_Player.GetGame(), this.m_Player, itemID));
  }

  public final func GetSellPrice(owner: wref<GameObject>, itemData: wref<gameItemData>) -> Float {
    return Cast(RPGManager.CalculateSellPriceItemData(this.m_Player.GetGame(), this.m_Player, itemData));
  }

  public final func GetSellPrice(itemID: ItemID) -> Float {
    return this.GetSellPrice(this.m_Player, itemID);
  }

  public final func GetSellPrice(itemData: wref<gameItemData>) -> Float {
    return this.GetSellPrice(this.m_Player, itemData);
  }

  public final func GetBuyPrice(owner: wref<GameObject>, itemID: ItemID) -> Float {
    return Cast(MarketSystem.GetBuyPrice(this.m_Player, itemID));
  }

  public final func GetBuyPrice(itemID: ItemID) -> Float {
    return this.GetBuyPrice(this.m_Player, itemID);
  }

  public final func GetPlayerStats(out statsList: array<StatViewData>) -> Void {
    this.GetPlayerStatsFromMap(statsList, "UIMaps.Player");
  }

  public final func GetPlayerInventoryStats(out statsList: array<StatViewData>) -> Void {
    this.GetPlayerStatsFromMap(statsList, "UIMaps.Player_Inventory");
  }

  public final func GetPlayerDPSStats(out statsList: array<StatViewData>) -> Void {
    this.GetPlayerStatsFromMap(statsList, "UIMaps.Player_Stat_Panel_DPS");
  }

  public final func GetPlayerArmorStats(out statsList: array<StatViewData>) -> Void {
    this.GetPlayerStatsFromMap(statsList, "UIMaps.Player_Stat_Panel_Armor");
  }

  public final func GetPlayerHealthStats(out statsList: array<StatViewData>) -> Void {
    this.GetPlayerStatsFromMap(statsList, "UIMaps.Player_Stat_Panel_Health");
  }

  public final func GetPlayerOtherStats(out statsList: array<StatViewData>) -> Void {
    this.GetPlayerStatsFromMap(statsList, "UIMaps.Player_Stat_Panel_Other");
  }

  private final func GetPlayerStatsFromMap(out statsList: array<StatViewData>, uiMap: String) -> Void {
    let count: Int32;
    let curData: StatViewData;
    let curRecords: wref<Stat_Record>;
    let i: Int32;
    let statRecords: array<wref<Stat_Record>>;
    let val: Int32;
    let playerID: StatsObjectID = Cast(this.m_Player.GetEntityID());
    let statMap: ref<UIStatsMap_Record> = TweakDBInterface.GetUIStatsMapRecord(TDBID.Create(uiMap));
    statMap.PrimaryStats(statRecords);
    count = ArraySize(statRecords);
    i = 0;
    while i < count {
      curRecords = statRecords[i];
      if IsDefined(curRecords) {
        curData.type = curRecords.StatType();
        curData.valueF = this.m_StatsSystem.GetStatValue(playerID, curData.type);
        if TweakDBInterface.GetBool(statRecords[i].GetID() + t".multByHundred", false) {
          val = Cast(this.m_StatsSystem.GetStatValue(playerID, curData.type) * 100.00);
        } else {
          val = RoundMath(this.m_StatsSystem.GetStatValue(playerID, curData.type));
        };
        curData.value = val;
        curData.statName = this.GetLocalizedStatName(curRecords);
        ArrayPush(statsList, curData);
      };
      i += 1;
    };
  }

  private final const func GetLocalizedStatName(statRecord: wref<Stat_Record>) -> String {
    let localizedName: String = statRecord.LocalizedName();
    if !IsStringValid(localizedName) {
      localizedName = this.m_LocMgr.Localize(EnumValueToName(n"gamedataStatType", EnumInt(statRecord.StatType())));
    };
    return localizedName;
  }

  private final func SetActiveWeapon(activeWeapon: ItemID) -> Void {
    this.m_ActiveWeapon = activeWeapon;
  }

  public final func MarkToRebuild() -> Void {
    this.m_ToRebuild = true;
    this.m_ToRebuildItemsWithEquipped = true;
    this.m_ToRebuildEquipment = true;
    this.m_ToRebuildWeapons = true;
    this.m_ToRebuildQuickSlots = true;
    this.m_ToRebuildConsumables = true;
  }

  public final func EquipItem(itemId: ItemID, slot: Int32) -> Void {
    let equipRequest: ref<GameplayEquipRequest>;
    if ItemID.IsValid(itemId) {
      equipRequest = new GameplayEquipRequest();
      equipRequest.itemID = itemId;
      equipRequest.owner = this.m_Player;
      equipRequest.slotIndex = slot;
      equipRequest.forceEquipWeapon = true;
      this.m_EquipmentSystem.QueueRequest(equipRequest);
    };
  }

  public final func UnequipItem(equipArea: gamedataEquipmentArea, slot: Int32) -> Void {
    let unequipRequest: ref<UnequipRequest>;
    if NotEquals(equipArea, gamedataEquipmentArea.Invalid) {
      unequipRequest = new UnequipRequest();
      unequipRequest.areaType = equipArea;
      unequipRequest.owner = this.m_Player;
      unequipRequest.slotIndex = slot;
      this.m_EquipmentSystem.QueueRequest(unequipRequest);
    };
  }

  public final func InstallPart(itemData: InventoryItemData, partID: ItemID, slotID: TweakDBID) -> Void {
    this.InstallPart(InventoryItemData.GetID(itemData), partID, slotID);
  }

  public final func CanInstallPart(itemData: InventoryItemData) -> Bool {
    if InventoryItemData.IsEmpty(itemData) || InventoryItemData.IsEquipped(itemData) {
      return false;
    };
    return true;
  }

  public final func InstallPart(itemId: ItemID, partId: ItemID, slotID: TweakDBID) -> Void {
    let installPartRequest: ref<InstallItemPart> = new InstallItemPart();
    installPartRequest.Set(this.m_Player, itemId, partId, slotID);
    this.m_ItemModificationSystem.QueueRequest(installPartRequest);
  }

  private final func RemovePart(itemId: ItemID, slotId: TweakDBID) -> Void {
    let removeRequest: ref<RemoveItemPart> = new RemoveItemPart();
    removeRequest.Set(this.m_Player, itemId, slotId);
    this.m_ItemModificationSystem.QueueRequest(removeRequest);
  }

  private final func SwapPart(itemId: ItemID, partId: ItemID, slotId: TweakDBID) -> Void {
    let swapRequest: ref<SwapItemPart> = new SwapItemPart();
    swapRequest.Set(this.m_Player, itemId, partId, slotId);
    this.m_ItemModificationSystem.QueueRequest(swapRequest);
  }

  private final func IsAttachmentDedicated(slotID: TweakDBID) -> Bool {
    return slotID == t"AttachmentSlots.SmartWeaponModRare" || slotID == t"AttachmentSlots.TechWeaponModRare" || slotID == t"AttachmentSlots.PowerWeaponModRare" || slotID == t"AttachmentSlots.SmartWeaponModEpic" || slotID == t"AttachmentSlots.TechWeaponModEpic" || slotID == t"AttachmentSlots.PowerWeaponModEpic" || slotID == t"AttachmentSlots.SmartWeaponModLegendary" || slotID == t"AttachmentSlots.TechWeaponModLegendary" || slotID == t"AttachmentSlots.PowerWeaponModLegendary" || slotID == t"AttachmentSlots.IconicMeleeWeaponMod1" || slotID == t"AttachmentSlots.IconicWeaponModLegendary";
  }

  private final func IsFilledWithDummyPart(innerItemData: InnerItemData) -> Bool {
    let result: Bool = InnerItemData.GetStaticData(innerItemData).TagsContains(n"DummyPart");
    return result;
  }

  private final func GetAttachements(owner: wref<GameObject>, itemIData: ref<gameItemData>, out attachments: array<InventoryItemAttachments>, abilities: script_ref<array<InventoryItemAbility>>) -> Void {
    let attachementType: InventoryItemAttachmentType;
    let attachment: InventoryItemAttachments;
    let attachmentItemRecord: wref<Item_Record>;
    let attachmentSlotRecord: wref<AttachmentSlot_Record>;
    let j: Int32;
    let limitJ: Int32;
    let once: Bool;
    let shouldBeAvailable: Bool;
    let itemId: ItemID = itemIData.GetID();
    let itemSlots: array<SPartSlots> = ItemModificationSystem.GetAllSlots(itemIData);
    let inventorySlots: array<TweakDBID> = InventoryDataManagerV2.GetAttachmentSlotsForInventory();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(inventorySlots);
    while i < limit {
      j = 0;
      limitJ = ArraySize(itemSlots);
      while j < limitJ {
        if inventorySlots[i] == itemSlots[j].slotID {
          attachmentSlotRecord = TweakDBInterface.GetAttachmentSlotRecord(itemSlots[j].slotID);
          shouldBeAvailable = RPGManager.ShouldSlotBeAvailable(owner, itemId, attachmentSlotRecord);
          if IsDefined(attachmentSlotRecord) && shouldBeAvailable {
            if this.IsFilledWithDummyPart(itemSlots[j].innerItemData) {
            } else {
              attachementType = this.IsAttachmentDedicated(itemSlots[j].slotID) ? InventoryItemAttachmentType.Dedicated : InventoryItemAttachmentType.Generic;
              attachment = new InventoryItemAttachments(itemSlots[j].slotID, this.GetPartInventoryItemData(owner, itemSlots[j], itemIData), attachmentSlotRecord.LocalizedName(), attachementType);
              ArrayPush(attachments, attachment);
              if once {
                if ItemID.IsValid(itemSlots[j].installedPart) {
                  attachmentItemRecord = InnerItemData.GetStaticData(itemSlots[j].innerItemData);
                  if IsDefined(attachmentItemRecord) {
                    this.FillSpecialAbilities(attachmentItemRecord, abilities, itemIData, itemSlots[j].innerItemData);
                  };
                };
              };
            };
          };
        };
        if once {
          if ItemID.IsValid(itemSlots[j].installedPart) {
            attachmentItemRecord = InnerItemData.GetStaticData(itemSlots[j].innerItemData);
            if IsDefined(attachmentItemRecord) {
              this.FillSpecialAbilities(attachmentItemRecord, abilities, itemIData, itemSlots[j].innerItemData);
            };
          };
        };
        j += 1;
      };
      once = false;
      i += 1;
    };
  }

  public final func GetAttachements(owner: wref<GameObject>, itemId: ItemID, itemData: wref<gameItemData>, out attachments: array<InventoryItemAttachments>, abilities: script_ref<array<InventoryItemAbility>>) -> Void {
    let attachementType: InventoryItemAttachmentType;
    let attachment: InventoryItemAttachments;
    let attachmentItemRecord: wref<Item_Record>;
    let attachmentSlotRecord: wref<AttachmentSlot_Record>;
    let j: Int32;
    let limitJ: Int32;
    let shouldBeAvailable: Bool;
    let once: Bool = true;
    let itemSlots: array<SPartSlots> = ItemModificationSystem.GetAllSlots(owner, itemId);
    let inventorySlots: array<TweakDBID> = InventoryDataManagerV2.GetAttachmentSlotsForInventory();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(inventorySlots);
    while i < limit {
      j = 0;
      limitJ = ArraySize(itemSlots);
      while j < limitJ {
        if inventorySlots[i] == itemSlots[j].slotID {
          attachmentSlotRecord = TweakDBInterface.GetAttachmentSlotRecord(itemSlots[j].slotID);
          shouldBeAvailable = RPGManager.ShouldSlotBeAvailable(owner, itemId, attachmentSlotRecord);
          if IsDefined(attachmentSlotRecord) && shouldBeAvailable {
            if Equals(itemSlots[j].status, ESlotState.Taken) {
              if this.IsFilledWithDummyPart(itemSlots[j].innerItemData) {
              } else {
                attachementType = this.IsAttachmentDedicated(itemSlots[j].slotID) ? InventoryItemAttachmentType.Dedicated : InventoryItemAttachmentType.Generic;
                attachment = new InventoryItemAttachments(itemSlots[j].slotID, this.GetPartInventoryItemData(owner, itemSlots[j], itemData), attachmentSlotRecord.LocalizedName(), attachementType);
                ArrayPush(attachments, attachment);
                if once {
                  if ItemID.IsValid(itemSlots[j].installedPart) {
                    attachmentItemRecord = InnerItemData.GetStaticData(itemSlots[j].innerItemData);
                    if IsDefined(attachmentItemRecord) {
                      this.FillSpecialAbilities(attachmentItemRecord, abilities, itemData, itemSlots[j].innerItemData);
                    };
                  };
                };
              };
            };
            attachementType = this.IsAttachmentDedicated(itemSlots[j].slotID) ? InventoryItemAttachmentType.Dedicated : InventoryItemAttachmentType.Generic;
            attachment = new InventoryItemAttachments(itemSlots[j].slotID, this.GetPartInventoryItemData(owner, itemSlots[j], itemData), attachmentSlotRecord.LocalizedName(), attachementType);
            ArrayPush(attachments, attachment);
          };
        };
        if once {
          if ItemID.IsValid(itemSlots[j].installedPart) {
            attachmentItemRecord = InnerItemData.GetStaticData(itemSlots[j].innerItemData);
            if IsDefined(attachmentItemRecord) {
              this.FillSpecialAbilities(attachmentItemRecord, abilities, itemData, itemSlots[j].innerItemData);
            };
          };
        };
        j += 1;
      };
      once = false;
      i += 1;
    };
  }

  public final func GetAttachements(owner: wref<GameObject>, itemData: wref<gameItemData>, usedSlots: array<TweakDBID>, emptySlots: array<TweakDBID>, out mods: array<ref<MinimalItemTooltipModData>>, out dedicatedMods: array<ref<MinimalItemTooltipModAttachmentData>>) -> Void {
    let attachmentData: ref<MinimalItemTooltipModAttachmentData>;
    let attachmentSlotRecord: wref<AttachmentSlot_Record>;
    let attachmentType: InventoryItemAttachmentType;
    let i: Int32;
    let inventorySlots: array<TweakDBID>;
    let itemId: ItemID;
    let limit: Int32;
    let partData: InnerItemData;
    let slotsData: array<AttachmentSlotCacheData>;
    let staticData: wref<Item_Record>;
    let emptySlotsSize: Int32 = ArraySize(emptySlots);
    let usedSlotsSize: Int32 = ArraySize(usedSlots);
    if emptySlotsSize < 1 && usedSlotsSize < 1 {
      return;
    };
    itemId = itemData.GetID();
    inventorySlots = InventoryDataManagerV2.GetAttachmentSlotsForInventory();
    i = 0;
    limit = ArraySize(inventorySlots);
    while i < limit {
      if emptySlotsSize > 0 && ArrayContains(emptySlots, inventorySlots[i]) {
        attachmentSlotRecord = TweakDBInterface.GetAttachmentSlotRecord(inventorySlots[i]);
        ArrayPush(slotsData, new AttachmentSlotCacheData(true, attachmentSlotRecord, RPGManager.ShouldSlotBeAvailable(owner, itemId, attachmentSlotRecord), inventorySlots[i]));
        emptySlotsSize -= 1;
        ArrayRemove(emptySlots, inventorySlots[i]);
      };
      if usedSlotsSize > 0 && ArrayContains(usedSlots, inventorySlots[i]) {
        attachmentSlotRecord = TweakDBInterface.GetAttachmentSlotRecord(inventorySlots[i]);
        ArrayPush(slotsData, new AttachmentSlotCacheData(false, attachmentSlotRecord, RPGManager.ShouldSlotBeAvailable(owner, itemId, attachmentSlotRecord), inventorySlots[i]));
        usedSlotsSize -= 1;
        ArrayRemove(usedSlots, inventorySlots[i]);
      };
      i += 1;
    };
    i = 0;
    limit = ArraySize(slotsData);
    while i < limit {
      staticData = null;
      if IsDefined(slotsData[i].attachmentSlotRecord) && slotsData[i].shouldBeAvailable {
        if !slotsData[i].empty {
          itemData.GetItemPart(partData, slotsData[i].slotId);
          staticData = InnerItemData.GetStaticData(partData);
          if staticData.TagsContains(n"DummyPart") {
          } else {
            attachmentType = this.IsAttachmentDedicated(slotsData[i].slotId) ? InventoryItemAttachmentType.Dedicated : InventoryItemAttachmentType.Generic;
            if Equals(attachmentType, InventoryItemAttachmentType.Dedicated) && staticData == null {
            } else {
              attachmentData = new MinimalItemTooltipModAttachmentData();
              attachmentData.isEmpty = slotsData[i].empty;
              if staticData != null {
                if InnerItemData.HasStatData(partData, gamedataStatType.Quality) {
                  attachmentData.qualityName = UIItemsHelper.QualityEnumToName(RPGManager.GetInnerItemDataQuality(partData));
                };
                this.FillSpecialAbilities(staticData, attachmentData.abilities, itemData, partData);
                attachmentData.abilitiesSize = ArraySize(attachmentData.abilities);
                attachmentData.slotName = LocKeyToString(staticData.DisplayName());
              } else {
                attachmentData.slotName = GetLocalizedText(UIItemsHelper.GetEmptySlotName(slotsData[i].slotId));
              };
              if Equals(attachmentType, InventoryItemAttachmentType.Dedicated) {
                ArrayPush(dedicatedMods, attachmentData);
              } else {
                ArrayPush(mods, attachmentData);
              };
            };
          };
        };
        attachmentType = this.IsAttachmentDedicated(slotsData[i].slotId) ? InventoryItemAttachmentType.Dedicated : InventoryItemAttachmentType.Generic;
        if Equals(attachmentType, InventoryItemAttachmentType.Dedicated) && staticData == null {
        } else {
          attachmentData = new MinimalItemTooltipModAttachmentData();
          attachmentData.isEmpty = slotsData[i].empty;
          if staticData != null {
            if InnerItemData.HasStatData(partData, gamedataStatType.Quality) {
              attachmentData.qualityName = UIItemsHelper.QualityEnumToName(RPGManager.GetInnerItemDataQuality(partData));
            };
            this.FillSpecialAbilities(staticData, attachmentData.abilities, itemData, partData);
            attachmentData.abilitiesSize = ArraySize(attachmentData.abilities);
            attachmentData.slotName = LocKeyToString(staticData.DisplayName());
          } else {
            attachmentData.slotName = GetLocalizedText(UIItemsHelper.GetEmptySlotName(slotsData[i].slotId));
          };
          if Equals(attachmentType, InventoryItemAttachmentType.Dedicated) {
            ArrayPush(dedicatedMods, attachmentData);
          } else {
            ArrayPush(mods, attachmentData);
          };
        };
      };
      i += 1;
    };
  }

  private final const func FillSpecialAbilities(itemRecord: ref<Item_Record>, abilities: script_ref<array<InventoryItemAbility>>, opt itemData: wref<gameItemData>, opt partItemData: InnerItemData) -> Void {
    let GLPAbilities: array<wref<GameplayLogicPackage_Record>>;
    let ability: InventoryItemAbility;
    let i: Int32;
    let limit: Int32;
    let uiData: wref<GameplayLogicPackageUIData_Record>;
    itemRecord.OnAttach(GLPAbilities);
    i = 0;
    limit = ArraySize(GLPAbilities);
    while i < limit {
      if IsDefined(GLPAbilities[i]) {
        uiData = GLPAbilities[i].UIData();
        if IsDefined(uiData) {
          ability = new InventoryItemAbility(uiData.IconPath(), uiData.LocalizedName(), uiData.LocalizedDescription(), UILocalizationDataPackage.FromLogicUIDataPackage(uiData, partItemData));
          ArrayPush(Deref(abilities), ability);
        };
      };
      i += 1;
    };
    ArrayClear(GLPAbilities);
    itemRecord.OnEquip(GLPAbilities);
    i = 0;
    limit = ArraySize(GLPAbilities);
    while i < limit {
      if IsDefined(GLPAbilities[i]) {
        uiData = GLPAbilities[i].UIData();
        if IsDefined(uiData) {
          ability = new InventoryItemAbility(uiData.IconPath(), uiData.LocalizedName(), uiData.LocalizedDescription(), UILocalizationDataPackage.FromLogicUIDataPackage(uiData));
          ArrayPush(Deref(abilities), ability);
        };
      };
      i += 1;
    };
  }

  private final const func GetStatsUIMapName(itemData: wref<gameItemData>) -> String {
    let statsMapName: String;
    if IsDefined(itemData) {
      statsMapName = this.GetStatsUIMapName(itemData.GetID());
    };
    return statsMapName;
  }

  public final const func GetStatsUIMapName(itemId: ItemID) -> String {
    let itemRecord: wref<Item_Record>;
    let itemType: wref<ItemType_Record>;
    let statsMapName: String;
    if ItemID.IsValid(itemId) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemId));
      if IsDefined(itemRecord) {
        itemType = itemRecord.ItemType();
        if IsDefined(itemType) {
          statsMapName = "UIMaps." + EnumValueToString("gamedataItemType", Cast(EnumInt(itemType.Type())));
        };
      };
    };
    return statsMapName;
  }

  private final const func GetStatsList(mapPath: TweakDBID, itemData: InnerItemData, out primeStatsList: array<StatViewData>, out secondStatsList: array<StatViewData>, opt compareWithData: wref<gameItemData>) -> Void {
    let compareDataProvider: ref<StatProvider>;
    let statProvider: ref<StatProvider> = new StatProvider();
    statProvider.Setup(itemData);
    compareDataProvider = new StatProvider();
    compareDataProvider.Setup(compareWithData);
    this.GetStatsList(mapPath, statProvider, primeStatsList, secondStatsList, compareDataProvider);
  }

  private final const func GetStatsList(mapPath: TweakDBID, itemData: wref<gameItemData>, out primeStatsList: array<StatViewData>, out secondStatsList: array<StatViewData>, opt compareWithData: wref<gameItemData>) -> Void {
    let compareDataProvider: ref<StatProvider>;
    let statProvider: ref<StatProvider> = new StatProvider();
    statProvider.Setup(itemData);
    compareDataProvider = new StatProvider();
    compareDataProvider.Setup(compareWithData);
    this.GetStatsList(mapPath, statProvider, primeStatsList, secondStatsList, compareDataProvider);
  }

  private final const func GetStatsList(mapPath: TweakDBID, itemData: InventoryItemData, out primeStatsList: array<StatViewData>, out secondStatsList: array<StatViewData>, compareWithData: InventoryItemData) -> Void {
    let compareDataProvider: ref<StatProvider>;
    let statProvider: ref<StatProvider> = new StatProvider();
    statProvider.Setup(itemData);
    compareDataProvider = new StatProvider();
    compareDataProvider.Setup(compareWithData);
    this.GetStatsList(mapPath, statProvider, primeStatsList, secondStatsList, compareDataProvider);
  }

  private final const func GetStatsList(mapPath: TweakDBID, statProvider: ref<StatProvider>, out primeStatsList: array<StatViewData>, out secondStatsList: array<StatViewData>, opt compareWithData: ref<StatProvider>) -> Void {
    let compareStatRecords: array<wref<Stat_Record>>;
    let statRecords: array<wref<Stat_Record>>;
    let stats: wref<UIStatsMap_Record> = TweakDBInterface.GetUIStatsMapRecord(mapPath);
    ArrayClear(primeStatsList);
    ArrayClear(secondStatsList);
    if IsDefined(stats) {
      stats.StatsToCompare(compareStatRecords);
      stats.PrimaryStats(statRecords);
      this.FillStatsList(statProvider, statRecords, primeStatsList, compareStatRecords, compareWithData);
      ArrayClear(statRecords);
      stats.SecondaryStats(statRecords);
      this.FillStatsList(statProvider, statRecords, secondStatsList, compareStatRecords, compareWithData);
    };
  }

  private final const func FillStatsList(statProvider: ref<StatProvider>, statRecords: array<wref<Stat_Record>>, out statList: array<StatViewData>, compareStatRecords: array<wref<Stat_Record>>, opt compareWithData: ref<StatProvider>) -> Void {
    let compareValue: Int32;
    let compareValueF: Float;
    let currStatRecord: wref<Stat_Record>;
    let currentStatViewData: StatViewData;
    let currentType: gamedataStatType;
    let maxValue: Int32;
    let count: Int32 = ArraySize(statRecords);
    let i: Int32 = 0;
    while i < count {
      currStatRecord = statRecords[i];
      currentType = currStatRecord.StatType();
      if statProvider.HasStatData(currentType) {
        currentStatViewData.type = currentType;
        currentStatViewData.statName = this.GetLocalizedStatName(currStatRecord);
        currentStatViewData.value = statProvider.GetStatValueByType(currentType);
        currentStatViewData.valueF = statProvider.GetStatValueFByType(currentType);
        currentStatViewData.canBeCompared = ArrayContains(compareStatRecords, currStatRecord);
        currentStatViewData.isCompared = compareWithData.HasStatData(currentType);
        if currentStatViewData.isCompared {
          compareValue = compareWithData.GetStatValueByType(currentType);
          compareValueF = compareWithData.GetStatValueFByType(currentType);
          currentStatViewData.diffValue = currentStatViewData.value - compareValue;
          currentStatViewData.diffValueF = currentStatViewData.valueF - compareValueF;
        } else {
          currentStatViewData.diffValue = 0;
          currentStatViewData.diffValueF = 0.00;
        };
        if currentStatViewData.value > maxValue {
          maxValue = currentStatViewData.value;
        };
        currentStatViewData.statMaxValue = RoundMath(currStatRecord.Max());
        currentStatViewData.statMinValue = RoundMath(currStatRecord.Min());
        currentStatViewData.statMaxValueF = currStatRecord.Max();
        currentStatViewData.statMinValueF = currStatRecord.Min();
        ArrayPush(statList, currentStatViewData);
      };
      i += 1;
    };
  }

  public final func PushComparisonTooltipsData(out tooltipsData: array<ref<ATooltipData>>, equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, opt iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt overrideRarity: Bool) -> Void {
    ArrayPush(tooltipsData, this.GetComparisonTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo, overrideRarity));
    ArrayPush(tooltipsData, this.GetComparisonTooltipsData(inspectedItemData, equippedItem, true, overrideRarity));
  }

  public final func PushIdentifiedComparisonTooltipsData(out tooltipsData: array<ref<ATooltipData>>, name1: CName, name2: CName, equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, opt iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt overrideRarity: Bool) -> Void {
    let identifiedInspectedData: ref<IdentifiedWrappedTooltipData> = new IdentifiedWrappedTooltipData();
    let identifiedEquippedData: ref<IdentifiedWrappedTooltipData> = new IdentifiedWrappedTooltipData();
    identifiedInspectedData.m_identifier = name1;
    identifiedInspectedData.m_data = this.GetComparisonTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo, overrideRarity);
    identifiedEquippedData.m_identifier = name2;
    identifiedEquippedData.m_data = this.GetComparisonTooltipsData(inspectedItemData, equippedItem, true, overrideRarity);
    ArrayPush(tooltipsData, identifiedInspectedData);
    ArrayPush(tooltipsData, identifiedEquippedData);
  }

  public final func PushIdentifiedProgramComparisionTooltipsData(out tooltipsData: array<ref<ATooltipData>>, name1: CName, name2: CName, equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, opt iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt overrideRarity: Bool) -> Void {
    let identifiedInspectedData: ref<IdentifiedWrappedTooltipData> = new IdentifiedWrappedTooltipData();
    let identifiedEquippedData: ref<IdentifiedWrappedTooltipData> = new IdentifiedWrappedTooltipData();
    identifiedInspectedData.m_identifier = name1;
    identifiedInspectedData.m_data = this.GetProgramComparisionTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo, overrideRarity);
    identifiedEquippedData.m_identifier = name2;
    identifiedEquippedData.m_data = this.GetProgramComparisionTooltipsData(inspectedItemData, equippedItem, true, overrideRarity);
    ArrayPush(tooltipsData, identifiedInspectedData);
    ArrayPush(tooltipsData, identifiedEquippedData);
  }

  public final func PushIdentifiedProgramComparisionTooltipsData(out tooltipsData: array<ref<ATooltipData>>, equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, opt iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt overrideRarity: Bool) -> Void {
    let identifiedInspectedData: ref<IdentifiedWrappedTooltipData> = new IdentifiedWrappedTooltipData();
    let identifiedEquippedData: ref<IdentifiedWrappedTooltipData> = new IdentifiedWrappedTooltipData();
    identifiedInspectedData.m_identifier = n"programTooltip";
    identifiedInspectedData.m_data = this.GetProgramComparisionTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo, overrideRarity);
    identifiedEquippedData.m_identifier = n"programTooltipComparision";
    identifiedEquippedData.m_data = this.GetProgramComparisionTooltipsData(inspectedItemData, equippedItem, true, overrideRarity);
    ArrayPush(tooltipsData, identifiedInspectedData);
    ArrayPush(tooltipsData, identifiedEquippedData);
  }

  public final func PushProgramComparisionTooltipsData(out tooltipsData: array<ref<ATooltipData>>, equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, opt iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt overrideRarity: Bool) -> Void {
    ArrayPush(tooltipsData, this.GetProgramComparisionTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo, overrideRarity));
    ArrayPush(tooltipsData, this.GetProgramComparisionTooltipsData(inspectedItemData, equippedItem, true, overrideRarity));
  }

  public final func GetProgramComparisionTooltipsData(equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, opt equipped: Bool, opt iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt overrideRarity: Bool) -> ref<InventoryTooltipData> {
    let comparedQuickhackData: InventoryTooltipData_QuickhackData;
    let result: ref<InventoryTooltipData>;
    let isEquippedEmpty: Bool = InventoryItemData.IsEmpty(equippedItem);
    let tooltipData: InventoryItemData = inspectedItemData;
    if !isEquippedEmpty {
      InventoryItemData.SetComparedQuality(tooltipData, UIItemsHelper.QualityNameToEnum(InventoryItemData.GetQuality(equippedItem)));
    };
    result = this.GetTooltipDataForInventoryItem(tooltipData, equipped, iconErrorInfo, InventoryItemData.IsVendorItem(inspectedItemData), overrideRarity);
    if !isEquippedEmpty {
      comparedQuickhackData = this.GetQuickhackTooltipData(equippedItem);
      result.quickhackData.uploadTimeDiff = result.quickhackData.uploadTime - comparedQuickhackData.uploadTime;
      result.quickhackData.durationDiff = result.quickhackData.duration - comparedQuickhackData.duration;
      result.quickhackData.cooldownDiff = result.quickhackData.cooldown - comparedQuickhackData.cooldown;
    };
    return result;
  }

  public final func GetComparisonTooltipsData(equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, opt equipped: Bool, opt iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt overrideRarity: Bool) -> ref<InventoryTooltipData> {
    let primaryStats: array<StatViewData>;
    let secondaryStats: array<StatViewData>;
    let statsMapName: String;
    let tooltipData: InventoryItemData = inspectedItemData;
    if !InventoryItemData.IsEmpty(equippedItem) {
      statsMapName = this.GetStatsUIMapName(InventoryItemData.GetID(inspectedItemData));
      if IsStringValid(statsMapName) {
        this.GetStatsList(TDBID.Create(statsMapName), inspectedItemData, primaryStats, secondaryStats, equippedItem);
        InventoryItemData.SetPrimaryStats(tooltipData, primaryStats);
        InventoryItemData.SetSecondaryStats(tooltipData, secondaryStats);
      };
      InventoryItemData.SetComparedQuality(tooltipData, UIItemsHelper.QualityNameToEnum(InventoryItemData.GetQuality(equippedItem)));
    };
    return this.GetTooltipDataForInventoryItem(tooltipData, equipped, iconErrorInfo, InventoryItemData.IsVendorItem(inspectedItemData), overrideRarity);
  }

  public final func GetMinimalComparisionLootingData() -> Void;

  public final const func CanCompareItems(itemId: ItemID, compareItemId: ItemID) -> Bool {
    let compareItemRecord: ref<Item_Record>;
    let compareItemType: wref<ItemType_Record>;
    let stats: ref<UIStatsMap_Record>;
    let statsMapName: String;
    let typesToCompare: array<wref<ItemType_Record>>;
    if !ItemID.IsValid(itemId) || !ItemID.IsValid(compareItemId) {
      return false;
    };
    compareItemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(compareItemId));
    compareItemType = compareItemRecord.ItemType();
    statsMapName = this.GetStatsUIMapName(itemId);
    if !IsStringValid(statsMapName) {
      return false;
    };
    stats = TweakDBInterface.GetUIStatsMapRecord(TDBID.Create(statsMapName));
    stats.TypesToCompareWith(typesToCompare);
    return ArrayContains(typesToCompare, compareItemType);
  }

  private func GetDPS(data: InventoryItemData) -> Int32 {
    let i: Int32;
    let limit: Int32;
    let size: Int32;
    let stat: StatViewData;
    if !InventoryItemData.IsEmpty(data) {
      size = InventoryItemData.GetPrimaryStatsSize(data);
      i = 0;
      limit = size;
      while i < limit {
        stat = InventoryItemData.GetPrimaryStat(data, i);
        if Equals(stat.type, gamedataStatType.DPS) {
          return stat.value;
        };
        i += 1;
      };
    };
    return 0;
  }

  public final func GetItemsToCompare(equipmentArea: gamedataEquipmentArea) -> array<InventoryItemData> {
    let comparableItem: InventoryItemData;
    let result: array<InventoryItemData>;
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
      return this.GetEquippedWeapons();
    };
    comparableItem = this.GetItemToCompare(equipmentArea);
    if !InventoryItemData.IsEmpty(comparableItem) {
      ArrayPush(result, comparableItem);
    };
    return result;
  }

  public final func GetItemsIDsToCompare(equipmentArea: gamedataEquipmentArea) -> array<ItemID> {
    let comparableItem: ItemID;
    let result: array<ItemID>;
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
      return this.GetEquippedWeaponsIDs();
    };
    comparableItem = this.GetItemIDToCompare(equipmentArea);
    if ItemID.IsValid(comparableItem) {
      ArrayPush(result, comparableItem);
    };
    return result;
  }

  public final static func IsAreaClothing(equipmentArea: gamedataEquipmentArea) -> Bool {
    return Equals(gamedataEquipmentArea.Face, equipmentArea) || Equals(gamedataEquipmentArea.Feet, equipmentArea) || Equals(gamedataEquipmentArea.Head, equipmentArea) || Equals(gamedataEquipmentArea.InnerChest, equipmentArea) || Equals(gamedataEquipmentArea.Legs, equipmentArea) || Equals(gamedataEquipmentArea.OuterChest, equipmentArea) || Equals(gamedataEquipmentArea.Outfit, equipmentArea);
  }

  public final static func IsAreaSelfComparable(equipmentArea: gamedataEquipmentArea) -> Bool {
    return InventoryDataManagerV2.IsAreaClothing(equipmentArea);
  }

  public final static func IsEquipmentAreaComparable(equipmentArea: gamedataEquipmentArea) -> Bool {
    if InventoryDataManagerV2.IsAreaSelfComparable(equipmentArea) {
      return true;
    };
    return Equals(equipmentArea, gamedataEquipmentArea.Weapon);
  }

  public final func GetItemsToCompare(item: InventoryItemData) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    if !InventoryItemData.IsEmpty(item) {
      return this.GetItemsToCompare(InventoryItemData.GetEquipmentArea(item));
    };
    return result;
  }

  public final func GetItemToCompare(equipmentArea: gamedataEquipmentArea) -> InventoryItemData {
    let emptyItem: InventoryItemData;
    if InventoryDataManagerV2.IsAreaSelfComparable(equipmentArea) {
      return this.GetItemDataEquippedInArea(equipmentArea, 0);
    };
    return emptyItem;
  }

  public final func GetItemIDToCompare(equipmentArea: gamedataEquipmentArea) -> ItemID {
    if InventoryDataManagerV2.IsAreaSelfComparable(equipmentArea) {
      return this.GetEquippedItemIdInArea(equipmentArea, 0);
    };
    return ItemID.undefined();
  }

  public final func GetPrefferedEquipedItemToCompare(item: InventoryItemData) -> Int32 {
    return this.GetPrefferedEquipedItemToCompare(item, this.GetItemsToCompare(item));
  }

  public final func GetPrefferedEquipedItemToCompare(item: InventoryItemData, itemsToCompare: array<InventoryItemData>) -> Int32 {
    return this.GetPrefferedEquipedItemToCompareRef(item, itemsToCompare);
  }

  public final func GetPrefferedEquipedItemToCompareRef(item: InventoryItemData, itemsToCompare: script_ref<array<InventoryItemData>>) -> Int32 {
    let i: Int32;
    let result: Int32;
    if !InventoryItemData.IsEmpty(item) {
      if Equals(InventoryItemData.GetEquipmentArea(item), gamedataEquipmentArea.Weapon) {
        i = 0;
        while i < ArraySize(Deref(itemsToCompare)) {
          if Equals(InventoryItemData.GetName(Deref(itemsToCompare)[i]), InventoryItemData.GetName(item)) {
            return i;
          };
          i += 1;
        };
        i = 0;
        while i < ArraySize(Deref(itemsToCompare)) {
          if Equals(InventoryItemData.GetItemType(Deref(itemsToCompare)[i]), InventoryItemData.GetItemType(item)) {
            return i;
          };
          i += 1;
        };
        i = 0;
        while i < ArraySize(Deref(itemsToCompare)) {
          if this.GetDPS(Deref(itemsToCompare)[i]) > this.GetDPS(Deref(itemsToCompare)[result]) {
            result = i;
          };
          i += 1;
        };
        return result;
      };
      return result;
    };
    return result;
  }

  public final func GetPrefferedEquipedItemIDToCompare(item: InventoryItemData, itemsToCompare: script_ref<array<InventoryItemData>>) -> Int32 {
    let i: Int32;
    let result: Int32;
    if !InventoryItemData.IsEmpty(item) {
      if Equals(InventoryItemData.GetEquipmentArea(item), gamedataEquipmentArea.Weapon) {
        i = 0;
        while i < ArraySize(Deref(itemsToCompare)) {
          if Equals(InventoryItemData.GetName(Deref(itemsToCompare)[i]), InventoryItemData.GetName(item)) {
            return i;
          };
          i += 1;
        };
        i = 0;
        while i < ArraySize(Deref(itemsToCompare)) {
          if Equals(InventoryItemData.GetItemType(Deref(itemsToCompare)[i]), InventoryItemData.GetItemType(item)) {
            return i;
          };
          i += 1;
        };
        i = 0;
        while i < ArraySize(Deref(itemsToCompare)) {
          if this.GetDPS(Deref(itemsToCompare)[i]) > this.GetDPS(Deref(itemsToCompare)[result]) {
            result = i;
          };
          i += 1;
        };
        return result;
      };
      return result;
    };
    return result;
  }

  public final func GetPrefferedEquipedItemIDToCompare(item: wref<gameItemData>, itemRecord: wref<Item_Record>, equipmentArea: gamedataEquipmentArea, idsToCompare: script_ref<array<ItemID>>) -> Int32 {
    let bestDPS: Float;
    let comparedItemData: wref<gameItemData>;
    let comparedRecord: wref<Item_Record>;
    let comparedRecords: array<wref<Item_Record>>;
    let comparedRecordsSize: Int32;
    let i: Int32;
    let localDPS: Float;
    let result: Int32;
    let targetType: gamedataItemType = item.GetItemType();
    if IsDefined(item) {
      if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
        i = 0;
        while i < ArraySize(Deref(idsToCompare)) {
          comparedRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(Deref(idsToCompare)[i]));
          if Equals(comparedRecord.DisplayName(), itemRecord.DisplayName()) {
            return i;
          };
          ArrayPush(comparedRecords, comparedRecord);
          i += 1;
        };
        comparedRecordsSize = ArraySize(comparedRecords);
        i = 0;
        while i < comparedRecordsSize {
          if Equals(comparedRecords[i].ItemType().Type(), targetType) {
            return i;
          };
          i += 1;
        };
        i = 0;
        while i < comparedRecordsSize {
          comparedItemData = this.GetPlayerItemData(Deref(idsToCompare)[i]);
          localDPS = comparedItemData.GetStatValueByType(gamedataStatType.EffectiveDPS);
          if localDPS > bestDPS {
            bestDPS = localDPS;
            result = i;
          };
          i += 1;
        };
        return result;
      };
      return 0;
    };
    return 0;
  }

  public final func GetEquippedCounterpartForInventroyItem(inspectedItemData: InventoryItemData) -> InventoryItemData {
    let equipAreas: array<gamedataEquipmentArea>;
    let equippedItem: InventoryItemData;
    let i: Int32;
    let limit: Int32;
    let weapons: array<InventoryItemData>;
    if !InventoryItemData.IsEmpty(inspectedItemData) {
      if Equals(InventoryItemData.GetEquipmentArea(inspectedItemData), gamedataEquipmentArea.Weapon) {
        weapons = this.GetEquippedWeapons();
        i = 0;
        limit = ArraySize(weapons);
        while i < limit {
          if !InventoryItemData.IsEmpty(weapons[i]) {
            if InventoryItemData.GetID(weapons[i]) == this.m_ActiveWeapon {
              equippedItem = weapons[i];
            };
          } else {
            return weapons[i];
          };
          i += 1;
        };
      } else {
        equipAreas = InventoryDataManagerV2.GetInventoryEquipmentAreas();
        if !ArrayContains(equipAreas, InventoryItemData.GetEquipmentArea(inspectedItemData)) {
          equipAreas = InventoryDataManagerV2.GetInventoryCyberwareAreas();
          if !ArrayContains(equipAreas, InventoryItemData.GetEquipmentArea(inspectedItemData)) {
            return equippedItem;
          };
        };
        return this.GetItemDataEquippedInArea(InventoryItemData.GetEquipmentArea(inspectedItemData));
      };
    };
    return equippedItem;
  }

  public final func GetAmmoForWeaponType(itemData: InventoryItemData) -> Int32 {
    return this.m_TransactionSystem.GetItemQuantity(this.m_Player, ItemID.CreateQuery(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(itemData))).Ammo().GetID()));
  }

  public final func GetPrefferedComparisonItem(item: InventoryItemData, comparableItems: array<InventoryItemData>) -> InventoryItemData {
    let result: InventoryItemData;
    let prefferedItemIndex: Int32 = this.GetPrefferedEquipedItemToCompare(item, comparableItems);
    if prefferedItemIndex < ArraySize(comparableItems) {
      result = comparableItems[prefferedItemIndex];
    };
    return result;
  }

  public final func GetPrefferedComparisonItemID(item: wref<gameItemData>, itemRecord: wref<Item_Record>, equipmentArea: gamedataEquipmentArea, comparableItems: array<ItemID>) -> ItemID {
    let result: ItemID;
    let prefferedItemIndex: Int32 = this.GetPrefferedEquipedItemIDToCompare(item, itemRecord, equipmentArea, comparableItems);
    if prefferedItemIndex < ArraySize(comparableItems) {
      result = comparableItems[prefferedItemIndex];
    };
    return result;
  }

  public final func GetComparisonItems(item: InventoryItemData) -> array<InventoryItemData> {
    let comparableItems: array<InventoryItemData>;
    let inventoryItems: array<InventoryItemData> = this.FilterOutEmptyItems(this.GetItemsToCompare(item));
    if !InventoryDataManagerV2.IsAreaSelfComparable(InventoryItemData.GetEquipmentArea(item)) {
      comparableItems = this.FilterComparableItems(InventoryItemData.GetID(item), inventoryItems);
      return comparableItems;
    };
    return inventoryItems;
  }

  public final func GetComparisonItemsIDs(itemID: ItemID, equipmentArea: gamedataEquipmentArea) -> array<ItemID> {
    let inventoryIDs: array<ItemID> = this.FilterOutInvalidIDs(this.GetItemsIDsToCompare(equipmentArea));
    if !InventoryDataManagerV2.IsAreaSelfComparable(equipmentArea) {
      return this.FilterComparableItemsIDs(itemID, inventoryIDs);
    };
    return inventoryIDs;
  }

  public final func GetAllComparisonItems(equipmentArea: gamedataEquipmentArea) -> array<InventoryItemData> {
    return this.FilterOutEmptyItems(this.GetItemsToCompare(equipmentArea));
  }

  public final func GetPrefferedComparableItem(item: InventoryItemData, comparableItems: array<InventoryItemData>) -> InventoryItemData {
    let prefferedItemIndex: Int32 = this.GetPrefferedEquipedItemToCompare(item, this.FilterComparableItems(InventoryItemData.GetID(item), comparableItems));
    return comparableItems[prefferedItemIndex];
  }

  public final func FilterOutEmptyItems(items: array<InventoryItemData>) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if !InventoryItemData.IsEmpty(items[i]) {
        ArrayPush(result, items[i]);
      };
      i += 1;
    };
    return result;
  }

  public final func FilterOutInvalidIDs(ids: array<ItemID>) -> array<ItemID> {
    let result: array<ItemID>;
    let i: Int32 = 0;
    let idsSize: Int32 = ArraySize(ids);
    while i < idsSize {
      if ItemID.IsValid(ids[i]) {
        ArrayPush(result, ids[i]);
      };
      i += 1;
    };
    return result;
  }

  public final func FilterComparableItems(itemToCompare: ItemID, items: array<InventoryItemData>) -> array<InventoryItemData> {
    let result: array<InventoryItemData>;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if this.CanCompareItems(itemToCompare, InventoryItemData.GetID(items[i])) {
        ArrayPush(result, items[i]);
      };
      i += 1;
    };
    return result;
  }

  public final func FilterComparableItemsIDs(itemToCompare: ItemID, ids: script_ref<array<ItemID>>) -> array<ItemID> {
    let result: array<ItemID>;
    let i: Int32 = 0;
    while i < ArraySize(Deref(ids)) {
      if this.CanCompareItems(itemToCompare, Deref(ids)[i]) {
        ArrayPush(result, Deref(ids)[i]);
      };
      i += 1;
    };
    return result;
  }

  public final func GetAmmoCountForAllAmmoTypes() -> array<InventoryItemData> {
    let ammoList: array<InventoryItemData>;
    ArrayPush(ammoList, this.GetItemFromRecord("Ammo.Standard"));
    ArrayPush(ammoList, this.GetItemFromRecord("Ammo.Handgun"));
    ArrayPush(ammoList, this.GetItemFromRecord("Ammo.Tech_Rifle"));
    ArrayPush(ammoList, this.GetItemFromRecord("Ammo.Smart_Rifle"));
    ArrayPush(ammoList, this.GetItemFromRecord("Ammo.Power_Rifle"));
    ArrayPush(ammoList, this.GetItemFromRecord("Ammo.Shotgun"));
    return ammoList;
  }

  public final func GetCraftingCountForAllCraftingMaterialTypes() -> array<InventoryItemData> {
    let craftingMaterials: array<InventoryItemData>;
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.CommonMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.UncommonMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.QuickHackUncommonMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.RareMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.RareMaterial2"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.EpicMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.EpicMaterial2"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.QuickHackEpicMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.LegendaryMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.LegendaryMaterial2"));
    return craftingMaterials;
  }

  public final func GetCommonsCraftingMaterialTypes() -> array<InventoryItemData> {
    let craftingMaterials: array<InventoryItemData>;
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.CommonMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.UncommonMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.RareMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.RareMaterial2"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.EpicMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.EpicMaterial2"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.LegendaryMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.LegendaryMaterial2"));
    return craftingMaterials;
  }

  public final func GetHackingCraftingMaterialTypes() -> array<InventoryItemData> {
    let craftingMaterials: array<InventoryItemData>;
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.QuickHackUncommonMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.QuickHackRareMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.QuickHackEpicMaterial1"));
    ArrayPush(craftingMaterials, this.GetItemFromRecord("Items.QuickHackLegendaryMaterial1"));
    return craftingMaterials;
  }

  public final func GetItemFromRecord(tweakPath: String) -> InventoryItemData {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(TDBID.Create(tweakPath));
    let inventoryItemData: InventoryItemData = this.GetInventoryItemDataFromItemRecord(record);
    return inventoryItemData;
  }

  public final func GetItemFromRecord(id: TweakDBID) -> InventoryItemData {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(id);
    let inventoryItemData: InventoryItemData = this.GetInventoryItemDataFromItemRecord(record);
    return inventoryItemData;
  }

  public final func GetAllCyberwareAbilities() -> array<AbilityData> {
    let cyberwareAbilities: array<AbilityData>;
    let tempData: SEquipSlot;
    let data: array<SEquipSlot> = this.m_EquipmentSystem.GetAllInstalledCyberwareAbilities(this.m_Player);
    let i: Int32 = 0;
    while i < ArraySize(data) {
      tempData = data[i];
      ArrayPush(cyberwareAbilities, this.GetAbilityData(tempData.itemID));
      i += 1;
    };
    return cyberwareAbilities;
  }

  public final func GetAbilityData(itemId: ItemID) -> AbilityData {
    let abilityData: AbilityData;
    let itemRecord: wref<Item_Record>;
    if ItemID.IsValid(itemId) {
      abilityData.Empty = false;
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemId));
      abilityData.ID = itemId;
      abilityData.Name = LocKeyToString(itemRecord.DisplayName());
      abilityData.Description = LocKeyToString(itemRecord.LocalizedDescription());
    };
    return abilityData;
  }

  public final func GetExternalGameItemData(ownerId: EntityID, externalItemId: ItemID) -> wref<gameItemData> {
    let itemData: wref<gameItemData>;
    if ItemID.IsValid(externalItemId) && IsDefined(this.m_TransactionSystem) {
      itemData = this.m_TransactionSystem.GetItemDataByOwnerEntityId(ownerId, externalItemId);
    };
    return itemData;
  }

  public final func GetExternalGameObject(entityId: EntityID) -> wref<GameObject> {
    if IsDefined(this.m_Player) {
      return GameInstance.FindEntityByID(this.m_Player.GetGame(), entityId) as GameObject;
    };
    return null;
  }

  public final func GetExternalItemData(ownerId: EntityID, externalItemId: ItemID, opt forceShowCurrencyOnHUDTooltip: Bool) -> InventoryItemData {
    let owner: wref<GameObject>;
    let itemData: wref<gameItemData> = this.GetExternalGameItemData(ownerId, externalItemId);
    if IsDefined(this.m_Player) {
      owner = GameInstance.FindEntityByID(this.m_Player.GetGame(), ownerId) as GameObject;
    };
    return this.GetInventoryItemData(owner, itemData, forceShowCurrencyOnHUDTooltip);
  }

  public final func GetExternalItemData(ownerId: EntityID, externalItem: wref<gameItemData>, opt forceShowCurrencyOnHUDTooltip: Bool) -> InventoryItemData {
    let owner: wref<GameObject>;
    if IsDefined(this.m_Player) {
      owner = GameInstance.FindEntityByID(this.m_Player.GetGame(), ownerId) as GameObject;
    };
    return this.GetInventoryItemData(owner, externalItem, forceShowCurrencyOnHUDTooltip);
  }

  private final func GetEquipmentAreaLocalizedName(equipmentArea: gamedataEquipmentArea) -> String {
    let i: Int32;
    let limit: Int32;
    if ArraySize(this.m_EquipRecords) < 1 {
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.Weapon"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.HeadArmor"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.FaceArmor"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.InnerChest"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.ChestArmor"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.LegArmor"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.Feet"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.BrainCW"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.ArmsCW"));
      ArrayPush(this.m_EquipRecords, TweakDBInterface.GetEquipmentAreaRecord(t"EquipmentArea.HandsCW"));
    };
    i = 0;
    limit = ArraySize(this.m_EquipRecords);
    while i < limit {
      if Equals(this.m_EquipRecords[i].Type(), equipmentArea) {
        return this.m_EquipRecords[i].LocalizedName();
      };
      i += 1;
    };
    return "";
  }

  public final func GetNumberOfSlots(equipmentArea: gamedataEquipmentArea) -> Int32 {
    return this.m_EquipmentSystem.GetPlayerData(this.m_Player).GetNumberOfSlots(equipmentArea);
  }

  public final func SortDataByRarity(items: array<InventoryItemData>) -> array<InventoryItemData> {
    let j: Int32;
    let returnedArray: array<InventoryItemData>;
    let tempItem: InventoryItemData;
    let tempRarity: gamedataQuality;
    let rarities: array<gamedataQuality> = InventoryDataManagerV2.GetRarityTypesForSorting();
    let i: Int32 = 0;
    while i < ArraySize(rarities) {
      tempRarity = rarities[i];
      j = 0;
      while j < ArraySize(items) {
        tempItem = items[j];
        if Equals(InventoryItemData.GetQuality(tempItem), UIItemsHelper.QualityEnumToName(tempRarity)) {
          ArrayPush(returnedArray, tempItem);
        };
        j += 1;
      };
      i += 1;
    };
    return returnedArray;
  }

  public final func GetExternalItemStats(ownerId: EntityID, externalItemId: ItemID, opt compareItemId: ItemID) -> ItemViewData {
    let compareItemData: wref<gameItemData>;
    let itemData: wref<gameItemData>;
    if ItemID.IsValid(compareItemId) {
      compareItemData = this.m_TransactionSystem.GetItemData(this.m_Player, compareItemId);
    };
    itemData = this.m_TransactionSystem.GetItemDataByOwnerEntityId(ownerId, externalItemId);
    return this.GetItemStatsByData(itemData, compareItemData);
  }

  public final static func GetInventoryEquipmentAreas() -> array<gamedataEquipmentArea> {
    let areas: array<gamedataEquipmentArea>;
    ArrayPush(areas, gamedataEquipmentArea.Head);
    ArrayPush(areas, gamedataEquipmentArea.Face);
    ArrayPush(areas, gamedataEquipmentArea.InnerChest);
    ArrayPush(areas, gamedataEquipmentArea.OuterChest);
    ArrayPush(areas, gamedataEquipmentArea.Legs);
    ArrayPush(areas, gamedataEquipmentArea.Feet);
    return areas;
  }

  public final static func GetInventoryCyberwareAreas() -> array<gamedataEquipmentArea> {
    let areas: array<gamedataEquipmentArea>;
    ArrayPush(areas, gamedataEquipmentArea.SystemReplacementCW);
    ArrayPush(areas, gamedataEquipmentArea.ArmsCW);
    ArrayPush(areas, gamedataEquipmentArea.HandsCW);
    ArrayPush(areas, gamedataEquipmentArea.EyesCW);
    return areas;
  }

  public final static func GetInventoryWeaponTypes() -> array<gamedataItemType> {
    let areas: array<gamedataItemType>;
    ArrayPush(areas, gamedataItemType.Wea_AssaultRifle);
    ArrayPush(areas, gamedataItemType.Wea_Hammer);
    ArrayPush(areas, gamedataItemType.Wea_Handgun);
    ArrayPush(areas, gamedataItemType.Wea_Katana);
    ArrayPush(areas, gamedataItemType.Wea_Knife);
    ArrayPush(areas, gamedataItemType.Wea_LightMachineGun);
    ArrayPush(areas, gamedataItemType.Wea_LongBlade);
    ArrayPush(areas, gamedataItemType.Wea_Melee);
    ArrayPush(areas, gamedataItemType.Wea_OneHandedClub);
    ArrayPush(areas, gamedataItemType.Wea_PrecisionRifle);
    ArrayPush(areas, gamedataItemType.Wea_Revolver);
    ArrayPush(areas, gamedataItemType.Wea_Rifle);
    ArrayPush(areas, gamedataItemType.Wea_ShortBlade);
    ArrayPush(areas, gamedataItemType.Wea_Shotgun);
    ArrayPush(areas, gamedataItemType.Wea_ShotgunDual);
    ArrayPush(areas, gamedataItemType.Wea_SniperRifle);
    ArrayPush(areas, gamedataItemType.Wea_SubmachineGun);
    ArrayPush(areas, gamedataItemType.Wea_TwoHandedClub);
    return areas;
  }

  public final static func GetAttachmentsTypes() -> array<gamedataItemType> {
    let types: array<gamedataItemType>;
    ArrayPush(types, gamedataItemType.Prt_Capacitor);
    ArrayPush(types, gamedataItemType.Prt_FabricEnhancer);
    ArrayPush(types, gamedataItemType.Prt_Fragment);
    ArrayPush(types, gamedataItemType.Prt_Magazine);
    ArrayPush(types, gamedataItemType.Prt_Mod);
    ArrayPush(types, gamedataItemType.Prt_Muzzle);
    ArrayPush(types, gamedataItemType.Prt_Receiver);
    ArrayPush(types, gamedataItemType.Prt_Scope);
    ArrayPush(types, gamedataItemType.Prt_ScopeRail);
    ArrayPush(types, gamedataItemType.Prt_Stock);
    ArrayPush(types, gamedataItemType.Prt_TargetingSystem);
    return types;
  }

  public final static func IsAttachmentType(type: gamedataItemType) -> Bool {
    return Equals(type, gamedataItemType.Prt_Capacitor) || Equals(type, gamedataItemType.Prt_FabricEnhancer) || Equals(type, gamedataItemType.Prt_Fragment) || Equals(type, gamedataItemType.Prt_Magazine) || Equals(type, gamedataItemType.Prt_Mod) || Equals(type, gamedataItemType.Prt_Muzzle) || Equals(type, gamedataItemType.Prt_Receiver) || Equals(type, gamedataItemType.Prt_Scope) || Equals(type, gamedataItemType.Prt_ScopeRail) || Equals(type, gamedataItemType.Prt_Stock) || Equals(type, gamedataItemType.Prt_TargetingSystem);
  }

  public final static func GetInventoryPocketAreas() -> array<gamedataEquipmentArea> {
    let areas: array<gamedataEquipmentArea>;
    ArrayPush(areas, gamedataEquipmentArea.QuickSlot);
    ArrayPush(areas, gamedataEquipmentArea.ArmsCW);
    return areas;
  }

  public final static func IsEquipmentAreaCyberware(areaType: gamedataEquipmentArea) -> Bool {
    switch areaType {
      case gamedataEquipmentArea.AbilityCW:
      case gamedataEquipmentArea.NervousSystemCW:
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
      case gamedataEquipmentArea.IntegumentarySystemCW:
      case gamedataEquipmentArea.ImmuneSystemCW:
      case gamedataEquipmentArea.LegsCW:
      case gamedataEquipmentArea.EyesCW:
      case gamedataEquipmentArea.CardiovascularSystemCW:
      case gamedataEquipmentArea.HandsCW:
      case gamedataEquipmentArea.ArmsCW:
      case gamedataEquipmentArea.SystemReplacementCW:
        return true;
    };
    return false;
  }

  public final static func IsEquipmentAreaCyberware(areaTypes: array<gamedataEquipmentArea>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(areaTypes) {
      if InventoryDataManagerV2.IsEquipmentAreaCyberware(areaTypes[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final static func GetAllCyberwareAreas() -> array<gamedataEquipmentArea> {
    let areas: array<gamedataEquipmentArea>;
    ArrayPush(areas, gamedataEquipmentArea.SystemReplacementCW);
    ArrayPush(areas, gamedataEquipmentArea.ArmsCW);
    ArrayPush(areas, gamedataEquipmentArea.HandsCW);
    ArrayPush(areas, gamedataEquipmentArea.CardiovascularSystemCW);
    ArrayPush(areas, gamedataEquipmentArea.EyesCW);
    ArrayPush(areas, gamedataEquipmentArea.LegsCW);
    ArrayPush(areas, gamedataEquipmentArea.ImmuneSystemCW);
    ArrayPush(areas, gamedataEquipmentArea.IntegumentarySystemCW);
    ArrayPush(areas, gamedataEquipmentArea.MusculoskeletalSystemCW);
    ArrayPush(areas, gamedataEquipmentArea.NervousSystemCW);
    return areas;
  }

  public final static func GetItemTypesForSorting() -> array<gamedataItemType> {
    let areas: array<gamedataItemType>;
    ArrayPush(areas, gamedataItemType.Wea_AssaultRifle);
    ArrayPush(areas, gamedataItemType.Wea_LightMachineGun);
    ArrayPush(areas, gamedataItemType.Wea_SubmachineGun);
    ArrayPush(areas, gamedataItemType.Wea_Rifle);
    ArrayPush(areas, gamedataItemType.Wea_PrecisionRifle);
    ArrayPush(areas, gamedataItemType.Wea_SniperRifle);
    ArrayPush(areas, gamedataItemType.Wea_Handgun);
    ArrayPush(areas, gamedataItemType.Wea_Revolver);
    ArrayPush(areas, gamedataItemType.Wea_Shotgun);
    ArrayPush(areas, gamedataItemType.Wea_ShotgunDual);
    ArrayPush(areas, gamedataItemType.Wea_Katana);
    ArrayPush(areas, gamedataItemType.Wea_LongBlade);
    ArrayPush(areas, gamedataItemType.Wea_ShortBlade);
    ArrayPush(areas, gamedataItemType.Wea_Knife);
    ArrayPush(areas, gamedataItemType.Wea_Melee);
    ArrayPush(areas, gamedataItemType.Wea_OneHandedClub);
    ArrayPush(areas, gamedataItemType.Wea_TwoHandedClub);
    ArrayPush(areas, gamedataItemType.Wea_Hammer);
    ArrayPush(areas, gamedataItemType.Prt_Magazine);
    ArrayPush(areas, gamedataItemType.Prt_Muzzle);
    ArrayPush(areas, gamedataItemType.Prt_Scope);
    ArrayPush(areas, gamedataItemType.Prt_Stock);
    ArrayPush(areas, gamedataItemType.Prt_Mod);
    ArrayPush(areas, gamedataItemType.Cyb_Launcher);
    ArrayPush(areas, gamedataItemType.Cyb_MantisBlades);
    ArrayPush(areas, gamedataItemType.Cyb_NanoWires);
    ArrayPush(areas, gamedataItemType.Cyb_StrongArms);
    ArrayPush(areas, gamedataItemType.Prt_Fragment);
    ArrayPush(areas, gamedataItemType.Prt_Program);
    ArrayPush(areas, gamedataItemType.Fla_Rifle);
    ArrayPush(areas, gamedataItemType.Fla_Launcher);
    ArrayPush(areas, gamedataItemType.Fla_Shock);
    ArrayPush(areas, gamedataItemType.Fla_Support);
    ArrayPush(areas, gamedataItemType.Clo_Head);
    ArrayPush(areas, gamedataItemType.Clo_Face);
    ArrayPush(areas, gamedataItemType.Clo_OuterChest);
    ArrayPush(areas, gamedataItemType.Clo_InnerChest);
    ArrayPush(areas, gamedataItemType.Clo_Legs);
    ArrayPush(areas, gamedataItemType.Clo_Feet);
    ArrayPush(areas, gamedataItemType.Prt_FabricEnhancer);
    ArrayPush(areas, gamedataItemType.Gad_Grenade);
    ArrayPush(areas, gamedataItemType.Con_Injector);
    ArrayPush(areas, gamedataItemType.Con_Skillbook);
    ArrayPush(areas, gamedataItemType.Con_Inhaler);
    ArrayPush(areas, gamedataItemType.Con_Edible);
    ArrayPush(areas, gamedataItemType.Con_LongLasting);
    ArrayPush(areas, gamedataItemType.Gen_Readable);
    ArrayPush(areas, gamedataItemType.Gen_Junk);
    ArrayPush(areas, gamedataItemType.Gen_Misc);
    ArrayPush(areas, gamedataItemType.Gen_Keycard);
    return areas;
  }

  private final static func GetRarityTypesForSorting() -> array<gamedataQuality> {
    let areas: array<gamedataQuality>;
    ArrayPush(areas, gamedataQuality.Legendary);
    ArrayPush(areas, gamedataQuality.Epic);
    ArrayPush(areas, gamedataQuality.Rare);
    ArrayPush(areas, gamedataQuality.Uncommon);
    ArrayPush(areas, gamedataQuality.Common);
    return areas;
  }

  public final static func GetWeaponSlotsNum() -> Int32 {
    return 3;
  }

  private final static func GetQuickSlotsNum() -> Int32 {
    return 3;
  }

  private final static func GetConsumablesNum() -> Int32 {
    return 3;
  }

  public final static func GetAttachmentSlotsForInventory() -> array<TweakDBID> {
    let slots: array<TweakDBID>;
    ArrayPush(slots, t"AttachmentSlots.Scope");
    ArrayPush(slots, t"AttachmentSlots.PowerModule");
    ArrayPush(slots, t"AttachmentSlots.Gem");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram1");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram2");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram3");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram4");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram5");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram6");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram7");
    ArrayPush(slots, t"AttachmentSlots.CyberdeckProgram8");
    ArrayPush(slots, t"AttachmentSlots.HeadFabricEnhancer1");
    ArrayPush(slots, t"AttachmentSlots.HeadFabricEnhancer2");
    ArrayPush(slots, t"AttachmentSlots.HeadFabricEnhancer3");
    ArrayPush(slots, t"AttachmentSlots.FaceFabricEnhancer1");
    ArrayPush(slots, t"AttachmentSlots.FaceFabricEnhancer2");
    ArrayPush(slots, t"AttachmentSlots.FaceFabricEnhancer3");
    ArrayPush(slots, t"AttachmentSlots.KiroshiOpticsSlot1");
    ArrayPush(slots, t"AttachmentSlots.KiroshiOpticsSlot2");
    ArrayPush(slots, t"AttachmentSlots.KiroshiOpticsSlot3");
    ArrayPush(slots, t"AttachmentSlots.SandevistanSlot1");
    ArrayPush(slots, t"AttachmentSlots.SandevistanSlot2");
    ArrayPush(slots, t"AttachmentSlots.SandevistanSlot3");
    ArrayPush(slots, t"AttachmentSlots.BerserkSlot1");
    ArrayPush(slots, t"AttachmentSlots.BerserkSlot2");
    ArrayPush(slots, t"AttachmentSlots.BerserkSlot3");
    ArrayPush(slots, t"AttachmentSlots.InnerChestFabricEnhancer1");
    ArrayPush(slots, t"AttachmentSlots.InnerChestFabricEnhancer2");
    ArrayPush(slots, t"AttachmentSlots.InnerChestFabricEnhancer3");
    ArrayPush(slots, t"AttachmentSlots.InnerChestFabricEnhancer4");
    ArrayPush(slots, t"AttachmentSlots.OuterChestFabricEnhancer1");
    ArrayPush(slots, t"AttachmentSlots.OuterChestFabricEnhancer2");
    ArrayPush(slots, t"AttachmentSlots.OuterChestFabricEnhancer3");
    ArrayPush(slots, t"AttachmentSlots.OuterChestFabricEnhancer4");
    ArrayPush(slots, t"AttachmentSlots.LegsFabricEnhancer1");
    ArrayPush(slots, t"AttachmentSlots.LegsFabricEnhancer2");
    ArrayPush(slots, t"AttachmentSlots.LegsFabricEnhancer3");
    ArrayPush(slots, t"AttachmentSlots.FootFabricEnhancer1");
    ArrayPush(slots, t"AttachmentSlots.FootFabricEnhancer2");
    ArrayPush(slots, t"AttachmentSlots.FootFabricEnhancer3");
    ArrayPush(slots, t"AttachmentSlots.StrongArmsKnuckles");
    ArrayPush(slots, t"AttachmentSlots.StrongArmsBattery");
    ArrayPush(slots, t"AttachmentSlots.MantisBladesEdge");
    ArrayPush(slots, t"AttachmentSlots.MantisBladesRotor");
    ArrayPush(slots, t"AttachmentSlots.NanoWiresCable");
    ArrayPush(slots, t"AttachmentSlots.NanoWiresBattery");
    ArrayPush(slots, t"AttachmentSlots.ProjectileLauncherRound");
    ArrayPush(slots, t"AttachmentSlots.ProjectileLauncherWiring");
    ArrayPush(slots, t"AttachmentSlots.ArmsCyberwareGeneralSlot");
    ArrayPush(slots, t"AttachmentSlots.GenericWeaponMod1");
    ArrayPush(slots, t"AttachmentSlots.GenericWeaponMod2");
    ArrayPush(slots, t"AttachmentSlots.GenericWeaponMod3");
    ArrayPush(slots, t"AttachmentSlots.GenericWeaponMod4");
    ArrayPush(slots, t"AttachmentSlots.PowerWeaponModRare");
    ArrayPush(slots, t"AttachmentSlots.TechWeaponModRare");
    ArrayPush(slots, t"AttachmentSlots.SmartWeaponModRare");
    ArrayPush(slots, t"AttachmentSlots.PowerWeaponModEpic");
    ArrayPush(slots, t"AttachmentSlots.TechWeaponModEpic");
    ArrayPush(slots, t"AttachmentSlots.SmartWeaponModEpic");
    ArrayPush(slots, t"AttachmentSlots.PowerWeaponModLegendary");
    ArrayPush(slots, t"AttachmentSlots.TechWeaponModLegendary");
    ArrayPush(slots, t"AttachmentSlots.SmartWeaponModLegendary");
    ArrayPush(slots, t"AttachmentSlots.IconicWeaponModLegendary");
    ArrayPush(slots, t"AttachmentSlots.MeleeWeaponMod1");
    ArrayPush(slots, t"AttachmentSlots.MeleeWeaponMod2");
    ArrayPush(slots, t"AttachmentSlots.MeleeWeaponMod3");
    ArrayPush(slots, t"AttachmentSlots.IconicMeleeWeaponMod1");
    return slots;
  }

  public final static func IsProgramSlot(slotID: TweakDBID) -> Bool {
    return slotID == t"AttachmentSlots.CyberdeckProgram1" || slotID == t"AttachmentSlots.CyberdeckProgram2" || slotID == t"AttachmentSlots.CyberdeckProgram3" || slotID == t"AttachmentSlots.CyberdeckProgram4" || slotID == t"AttachmentSlots.CyberdeckProgram5" || slotID == t"AttachmentSlots.CyberdeckProgram6" || slotID == t"AttachmentSlots.CyberdeckProgram7" || slotID == t"AttachmentSlots.CyberdeckProgram8";
  }

  public final func FilterOutWorsePrograms(items: array<ItemID>) -> array<ItemID> {
    let result: array<ItemID>;
    let cyberdeckId: ItemID = this.GetEquippedItemIdInArea(gamedataEquipmentArea.SystemReplacementCW);
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if !ItemModificationSystem.HasBetterShardInstalled(this.m_Player, cyberdeckId, items[i]) {
        ArrayPush(result, items[i]);
      };
      i += 1;
    };
    return result;
  }

  public final func DistinctPrograms(items: array<ItemID>) -> array<ItemID> {
    let alreadyContains: array<CName>;
    let result: array<ItemID>;
    let shardType: CName;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      shardType = TweakDBInterface.GetCName(ItemID.GetTDBID(items[i]) + t".shardType", n"");
      if IsNameValid(shardType) {
        if !ArrayContains(alreadyContains, shardType) {
          ArrayPush(alreadyContains, shardType);
          ArrayPush(result, items[i]);
        };
      };
      i += 1;
    };
    return result;
  }

  public final func FilterHotkeyConsumables(items: array<ItemID>) -> array<ItemID> {
    let itemType: gamedataItemType;
    let j: Int32;
    let result: array<ItemID>;
    let scopesLimit: Int32;
    let scopes: array<gamedataItemType> = Hotkey.GetScope(EHotkey.DPAD_UP);
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      itemType = RPGManager.GetItemType(items[i]);
      if NotEquals(itemType, gamedataItemType.Invalid) {
        j = 0;
        scopesLimit = ArraySize(scopes);
        while j < scopesLimit {
          if Equals(scopes[j], itemType) {
            ArrayPush(result, items[i]);
          } else {
            j += 1;
          };
        };
      };
      i += 1;
    };
    return result;
  }

  public final static func IsItemBlacklisted(itemData: wref<gameItemData>, opt forceShowCurrencyOnHUDTooltip: Bool, opt isRadialQuerying: Bool, opt additionalTags: array<CName>) -> Bool {
    let tagsList: array<CName>;
    let i: Int32 = 0;
    while i < ArraySize(additionalTags) {
      ArrayPush(tagsList, additionalTags[i]);
      i += 1;
    };
    ArrayPush(tagsList, n"TppHead");
    ArrayPush(tagsList, n"HideInUI");
    if IsDefined(itemData) {
      if isRadialQuerying {
        ArrayPush(tagsList, n"Currency");
        ArrayPush(tagsList, n"Ammo");
      } else {
        if !forceShowCurrencyOnHUDTooltip {
          ArrayPush(tagsList, n"Currency");
          ArrayPush(tagsList, n"base_fists");
        } else {
          ArrayPush(tagsList, n"base_fists");
        };
      };
      i = 0;
      while i < ArraySize(tagsList) {
        if itemData.HasTag(tagsList[i]) {
          return true;
        };
        i += 1;
      };
      return false;
    };
    return true;
  }

  private final static func IsItemCraftingMaterial(itemData: wref<gameItemData>) -> Bool {
    if IsDefined(itemData) {
      return itemData.HasTag(n"CraftingPart");
    };
    return true;
  }

  private final static func GetWeaponDamageType(statList: array<StatViewData>) -> gamedataDamageType {
    let type: gamedataDamageType = gamedataDamageType.Invalid;
    let maxValue: Int32 = 0;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(statList);
    while i < limit {
      if Equals(statList[i].type, gamedataStatType.PhysicalDamage) || Equals(statList[i].type, gamedataStatType.ThermalDamage) || Equals(statList[i].type, gamedataStatType.ChemicalDamage) || Equals(statList[i].type, gamedataStatType.ElectricDamage) {
        if statList[i].value > maxValue {
          switch statList[i].type {
            case gamedataStatType.PhysicalDamage:
              type = gamedataDamageType.Physical;
              break;
            case gamedataStatType.ThermalDamage:
              type = gamedataDamageType.Thermal;
              break;
            case gamedataStatType.ChemicalDamage:
              type = gamedataDamageType.Chemical;
              break;
            case gamedataStatType.ElectricDamage:
              type = gamedataDamageType.Electric;
          };
          maxValue = statList[i].value;
        };
      };
      i += 1;
    };
    return type;
  }

  private final func SetPlayerStats(out inventoryItemData: InventoryItemData) -> Void {
    let statsystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_Player.GetGame());
    InventoryItemData.SetHasPlayerSmartGunLink(inventoryItemData, InventoryDataManagerV2.HasPlayerSmartGunLink(this.m_Player, statsystem));
    InventoryItemData.SetPlayerLevel(inventoryItemData, InventoryDataManagerV2.PlayerLevel(this.m_Player, statsystem));
    InventoryItemData.SetPlayerStrenght(inventoryItemData, InventoryDataManagerV2.PlayerStrength(this.m_Player, statsystem));
    InventoryItemData.SetPlayerReflexes(inventoryItemData, InventoryDataManagerV2.PlayerReflexes(this.m_Player, statsystem));
    InventoryItemData.SetPlayerStreetCred(inventoryItemData, InventoryDataManagerV2.PlayerStreetCred(this.m_Player, statsystem));
  }

  public final func HasPlayerSmartGunLink() -> Bool {
    return Cast(this.m_StatsSystem.GetStatValue(Cast(this.m_Player.GetEntityID()), gamedataStatType.HasSmartLink));
  }

  public final func GetPlayerLevel() -> Int32 {
    return RoundF(this.m_StatsSystem.GetStatValue(Cast(this.m_Player.GetEntityID()), gamedataStatType.Level));
  }

  public final func GetPlayerStrength() -> Int32 {
    return RoundF(this.m_StatsSystem.GetStatValue(Cast(this.m_Player.GetEntityID()), gamedataStatType.Strength));
  }

  public final func GetPlayerReflex() -> Int32 {
    return RoundF(this.m_StatsSystem.GetStatValue(Cast(this.m_Player.GetEntityID()), gamedataStatType.Reflexes));
  }

  public final func GetPlayerStreetCred() -> Int32 {
    return RoundF(this.m_StatsSystem.GetStatValue(Cast(this.m_Player.GetEntityID()), gamedataStatType.StreetCred));
  }

  private final static func HasPlayerSmartGunLink(player: wref<PlayerPuppet>, statsystem: ref<StatsSystem>) -> Bool {
    return Cast(statsystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.HasSmartLink));
  }

  private final static func PlayerLevel(player: wref<PlayerPuppet>, statsystem: ref<StatsSystem>) -> Int32 {
    return RoundF(statsystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Level));
  }

  private final static func PlayerStrength(player: wref<PlayerPuppet>, statsystem: ref<StatsSystem>) -> Int32 {
    return RoundF(statsystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Strength));
  }

  private final static func PlayerReflexes(player: wref<PlayerPuppet>, statsystem: ref<StatsSystem>) -> Int32 {
    return RoundF(statsystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Reflexes));
  }

  private final static func PlayerStreetCred(player: wref<PlayerPuppet>, statsSystem: ref<StatsSystem>) -> Int32 {
    return RoundF(statsSystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.StreetCred));
  }

  public final func CanUninstallMod(itemType: gamedataItemType, slot: TweakDBID) -> Bool {
    if Equals(itemType, gamedataItemType.Prt_Scope) || Equals(itemType, gamedataItemType.Prt_Muzzle) || Equals(itemType, gamedataItemType.Prt_Program) {
      return true;
    };
    if Equals(itemType, gamedataItemType.Prt_Fragment) && !this.IsNonModifableSlot(slot) {
      return true;
    };
    return false;
  }

  private final func IsNonModifableSlot(slot: TweakDBID) -> Bool {
    return slot == t"AttachmentSlots.StrongArmsKnuckles" || slot == t"AttachmentSlots.MantisBladesEdge" || slot == t"AttachmentSlots.NanoWiresCable" || slot == t"AttachmentSlots.ProjectileLauncherRound";
  }

  public final func GetGame() -> GameInstance {
    return this.m_Player.GetGame();
  }

  public final static func GetAttachmentSlotByItemID(itemData: InventoryItemData, attachmentID: ItemID) -> TweakDBID {
    let attachments: array<InventoryItemAttachments> = InventoryItemData.GetAttachments(itemData);
    let i: Int32 = 0;
    while i < ArraySize(attachments) {
      if InventoryItemData.GetID(attachments[i].ItemData) == attachmentID {
        return attachments[i].SlotID;
      };
      i += 1;
    };
    return TDBID.undefined();
  }
}

public class StatProvider extends IScriptable {

  private let m_GameItemData: wref<gameItemData>;

  private let m_PartData: InnerItemData;

  private let m_InventoryItemData: InventoryItemData;

  @default(StatProvider, EStatProviderDataSource.Invalid)
  private let dataSource: EStatProviderDataSource;

  public final func Setup(gameItemData: wref<gameItemData>) -> Void {
    this.dataSource = EStatProviderDataSource.gameItemData;
    this.m_GameItemData = gameItemData;
  }

  public final func Setup(inventoryItemData: InventoryItemData) -> Void {
    this.dataSource = EStatProviderDataSource.InventoryItemData;
    this.m_InventoryItemData = inventoryItemData;
  }

  public final func Setup(partData: InnerItemData) -> Void {
    this.dataSource = EStatProviderDataSource.InnerItemData;
    this.m_PartData = partData;
  }

  public final func HasStatData(type: gamedataStatType) -> Bool {
    let i: Int32;
    let limit: Int32;
    let stat: StatViewData;
    switch this.dataSource {
      case EStatProviderDataSource.gameItemData:
        if IsDefined(this.m_GameItemData) {
          return this.m_GameItemData.HasStatData(type);
        };
        break;
      case EStatProviderDataSource.InventoryItemData:
        if !InventoryItemData.IsEmpty(this.m_InventoryItemData) {
          i = 0;
          limit = InventoryItemData.GetPrimaryStatsSize(this.m_InventoryItemData);
          while i < limit {
            stat = InventoryItemData.GetPrimaryStat(this.m_InventoryItemData, i);
            if Equals(stat.type, type) {
              return true;
            };
            i += 1;
          };
          i = 0;
          limit = InventoryItemData.GetSecondaryStatsSize(this.m_InventoryItemData);
          while i < limit {
            stat = InventoryItemData.GetSecondaryStat(this.m_InventoryItemData, i);
            if Equals(stat.type, type) {
              return true;
            };
            i += 1;
          };
        };
        break;
      case EStatProviderDataSource.InnerItemData:
        return InnerItemData.HasStatData(this.m_PartData, type);
    };
    return false;
  }

  public final func GetStatValueByType(type: gamedataStatType) -> Int32 {
    let i: Int32;
    let limit: Int32;
    let stat: StatViewData;
    switch this.dataSource {
      case EStatProviderDataSource.gameItemData:
        if IsDefined(this.m_GameItemData) {
          return RoundMath(this.m_GameItemData.GetStatValueByType(type));
        };
        break;
      case EStatProviderDataSource.InventoryItemData:
        if !InventoryItemData.IsEmpty(this.m_InventoryItemData) {
          i = 0;
          limit = InventoryItemData.GetPrimaryStatsSize(this.m_InventoryItemData);
          while i < limit {
            stat = InventoryItemData.GetPrimaryStat(this.m_InventoryItemData, i);
            if Equals(stat.type, type) {
              return stat.value;
            };
            i += 1;
          };
          i = 0;
          limit = InventoryItemData.GetSecondaryStatsSize(this.m_InventoryItemData);
          while i < limit {
            stat = InventoryItemData.GetSecondaryStat(this.m_InventoryItemData, i);
            if Equals(stat.type, type) {
              return stat.value;
            };
            i += 1;
          };
        };
        break;
      case EStatProviderDataSource.InnerItemData:
        return RoundMath(InnerItemData.GetStatValueByType(this.m_PartData, type));
    };
    return 0;
  }

  public final func GetStatValueFByType(type: gamedataStatType) -> Float {
    let i: Int32;
    let limit: Int32;
    let stat: StatViewData;
    switch this.dataSource {
      case EStatProviderDataSource.gameItemData:
        if IsDefined(this.m_GameItemData) {
          return this.m_GameItemData.GetStatValueByType(type);
        };
        break;
      case EStatProviderDataSource.InventoryItemData:
        if !InventoryItemData.IsEmpty(this.m_InventoryItemData) {
          i = 0;
          limit = InventoryItemData.GetPrimaryStatsSize(this.m_InventoryItemData);
          while i < limit {
            stat = InventoryItemData.GetPrimaryStat(this.m_InventoryItemData, i);
            if Equals(stat.type, type) {
              return stat.valueF;
            };
            i += 1;
          };
          i = 0;
          limit = InventoryItemData.GetSecondaryStatsSize(this.m_InventoryItemData);
          while i < limit {
            stat = InventoryItemData.GetSecondaryStat(this.m_InventoryItemData, i);
            if Equals(stat.type, type) {
              return stat.valueF;
            };
            i += 1;
          };
        };
        break;
      case EStatProviderDataSource.InnerItemData:
        return InnerItemData.GetStatValueByType(this.m_PartData, type);
    };
    return 0.00;
  }
}

public class ItemPreferredComparisonResolver extends IScriptable {

  private let m_cacheadAreaItems: array<ref<ItemPreferredAreaItems>>;

  private let m_cachedComparableTypes: array<ref<ItemComparableTypesCache>>;

  private let m_typeComparableItemsCache: array<ref<TypeComparableItemsCache>>;

  private let m_dataManager: ref<InventoryDataManagerV2>;

  private let m_forcedCompareItem: InventoryItemData;

  private let m_useForceCompare: Bool;

  public final static func Make(inventoryDataManager: ref<InventoryDataManagerV2>) -> ref<ItemPreferredComparisonResolver> {
    let instance: ref<ItemPreferredComparisonResolver> = new ItemPreferredComparisonResolver();
    instance.m_dataManager = inventoryDataManager;
    return instance;
  }

  private final func GetAreaItems(equipmentArea: gamedataEquipmentArea) -> ref<ItemPreferredAreaItems> {
    let areaItems: ref<ItemPreferredAreaItems>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_cacheadAreaItems) {
      if Equals(this.m_cacheadAreaItems[i].equipmentArea, equipmentArea) {
        return this.m_cacheadAreaItems[i];
      };
      i += 1;
    };
    areaItems = new ItemPreferredAreaItems();
    areaItems.equipmentArea = equipmentArea;
    areaItems.items = this.m_dataManager.GetAllComparisonItems(equipmentArea);
    ArrayPush(this.m_cacheadAreaItems, areaItems);
    return areaItems;
  }

  private final func IsAreaSelfComparable(item: InventoryItemData) -> Bool {
    return InventoryDataManagerV2.IsAreaSelfComparable(InventoryItemData.GetEquipmentArea(item));
  }

  private final func CacheComparableType(item: InventoryItemData) -> ref<ItemComparableTypesCache> {
    let comparableTypes: ref<ItemComparableTypesCache>;
    let i: Int32;
    let stats: ref<UIStatsMap_Record>;
    let typesToCompare: array<wref<ItemType_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(item)));
    let statsMapName: String = this.m_dataManager.GetStatsUIMapName(InventoryItemData.GetID(item));
    if !IsStringValid(statsMapName) {
      return null;
    };
    stats = TweakDBInterface.GetUIStatsMapRecord(TDBID.Create(statsMapName));
    stats.TypesToCompareWith(typesToCompare);
    comparableTypes = new ItemComparableTypesCache();
    comparableTypes.itemType = InventoryItemData.GetItemType(item);
    comparableTypes.itemTypeRecord = itemRecord.ItemType();
    comparableTypes.comparableRecordTypes = typesToCompare;
    i = 0;
    while i < ArraySize(typesToCompare) {
      ArrayPush(comparableTypes.comparableTypes, typesToCompare[i].Type());
      i += 1;
    };
    if this.IsAreaSelfComparable(item) {
      if !ArrayContains(comparableTypes.comparableTypes, InventoryItemData.GetItemType(item)) {
        ArrayPush(comparableTypes.comparableRecordTypes, comparableTypes.itemTypeRecord);
        ArrayPush(comparableTypes.comparableTypes, comparableTypes.itemType);
      };
    };
    ArrayPush(this.m_cachedComparableTypes, comparableTypes);
    return comparableTypes;
  }

  private final func GetComparableTypes(item: InventoryItemData) -> ref<ItemComparableTypesCache> {
    let i: Int32;
    if InventoryItemData.IsEmpty(item) {
      return null;
    };
    i = 0;
    while i < ArraySize(this.m_cachedComparableTypes) {
      if Equals(this.m_cachedComparableTypes[i].itemType, InventoryItemData.GetItemType(item)) {
        return this.m_cachedComparableTypes[i];
      };
      i += 1;
    };
    return this.CacheComparableType(item);
  }

  private final func GetTypeComparableItems(item: InventoryItemData) -> ref<TypeComparableItemsCache> {
    let areaItems: array<InventoryItemData>;
    let comparableItemsCache: ref<TypeComparableItemsCache>;
    let comparableTypes: ref<ItemComparableTypesCache>;
    let i: Int32;
    if InventoryItemData.IsEmpty(item) {
      return null;
    };
    i = 0;
    while i < ArraySize(this.m_typeComparableItemsCache) {
      if Equals(this.m_typeComparableItemsCache[i].itemType, InventoryItemData.GetItemType(item)) {
        return this.m_typeComparableItemsCache[i];
      };
      i += 1;
    };
    comparableTypes = this.GetComparableTypes(item);
    if ArraySize(comparableTypes.comparableTypes) == 0 {
      return null;
    };
    areaItems = this.GetAreaItems(InventoryItemData.GetEquipmentArea(item)).items;
    comparableItemsCache = new TypeComparableItemsCache();
    comparableItemsCache.itemType = InventoryItemData.GetItemType(item);
    comparableItemsCache.cache = comparableTypes;
    i = 0;
    while i < ArraySize(areaItems) {
      if ArrayContains(comparableTypes.comparableTypes, InventoryItemData.GetItemType(areaItems[i])) {
        ArrayPush(comparableItemsCache.items, areaItems[i]);
      };
      i += 1;
    };
    ArrayPush(this.m_typeComparableItemsCache, comparableItemsCache);
    return comparableItemsCache;
  }

  public final func GetComparableItems(item: InventoryItemData) -> array<InventoryItemData> {
    return this.GetTypeComparableItems(item).items;
  }

  public final func IsBetterComparableNewItem(uiScriptableSystem: wref<UIScriptableSystem>, item: InventoryItemData) -> Bool {
    let comparedDPS: Float;
    let comparableItemsCache: ref<TypeComparableItemsCache> = this.GetTypeComparableItems(item);
    let i: Int32 = 0;
    while i < ArraySize(comparableItemsCache.items) {
      if uiScriptableSystem.IsInventoryItemNew(InventoryItemData.GetID(comparableItemsCache.items[i])) {
        comparedDPS = InventoryItemData.GetDPSF(comparableItemsCache.items[i]) - InventoryItemData.GetDPSF(item);
        if comparedDPS > 0.01 {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final func GetPreferredComparisonItem(item: InventoryItemData) -> InventoryItemData {
    let emptyResult: InventoryItemData;
    let resultIndex: Int32;
    let comparableItemsCache: ref<TypeComparableItemsCache> = this.GetTypeComparableItems(item);
    let items: array<InventoryItemData> = comparableItemsCache.items;
    if ArraySize(items) == 0 {
      return emptyResult;
    };
    resultIndex = this.m_dataManager.GetPrefferedEquipedItemToCompareRef(item, items);
    if resultIndex >= 0 && resultIndex < ArraySize(items) {
      if InventoryItemData.GetID(items[resultIndex]) != InventoryItemData.GetID(item) {
        return items[resultIndex];
      };
    };
    return emptyResult;
  }

  public final func GetItemComparisonState(item: InventoryItemData) -> ItemComparisonState {
    let itemToCompare: InventoryItemData;
    if this.m_useForceCompare {
      itemToCompare = this.m_forcedCompareItem;
      if !this.IsTypeComparable(item, InventoryItemData.GetItemType(this.m_forcedCompareItem)) {
        return ItemComparisonState.Default;
      };
    } else {
      itemToCompare = this.GetPreferredComparisonItem(item);
    };
    if InventoryItemData.IsEmpty(itemToCompare) {
      return ItemComparisonState.Default;
    };
    return this.CompareItems(itemToCompare, item);
  }

  public final func IsComparable(item: InventoryItemData) -> Bool {
    return Equals(InventoryItemData.GetEquipmentArea(item), gamedataEquipmentArea.Weapon) || this.IsAreaSelfComparable(item);
  }

  public final func IsTypeComparable(baseItem: InventoryItemData, comparedType: gamedataItemType) -> Bool {
    let comparableTypesCache: ref<ItemComparableTypesCache> = this.GetComparableTypes(baseItem);
    return ArrayContains(comparableTypesCache.comparableTypes, comparedType);
  }

  public final func DisableForceComparedItem() -> Void {
    this.m_useForceCompare = false;
  }

  public final func ForceComparedItem(item: InventoryItemData) -> Void {
    this.m_useForceCompare = true;
    this.m_forcedCompareItem = item;
  }

  public final func CompareItems(lhs: InventoryItemData, rhs: InventoryItemData) -> ItemComparisonState {
    let comparedValue: Float;
    let area: gamedataEquipmentArea = InventoryItemData.GetEquipmentArea(lhs);
    if NotEquals(area, InventoryItemData.GetEquipmentArea(rhs)) {
      return ItemComparisonState.Default;
    };
    if Equals(area, gamedataEquipmentArea.Weapon) {
      comparedValue = InventoryItemData.GetDPSF(lhs) - InventoryItemData.GetDPSF(rhs);
    } else {
      if InventoryDataManagerV2.IsAreaClothing(area) {
        comparedValue = InventoryItemData.GetArmorF(lhs) - InventoryItemData.GetArmorF(rhs);
      } else {
        return ItemComparisonState.Default;
      };
    };
    return AbsF(comparedValue) < 0.01 ? ItemComparisonState.NoChange : comparedValue > 0.00 ? ItemComparisonState.Worse : ItemComparisonState.Better;
  }
}
