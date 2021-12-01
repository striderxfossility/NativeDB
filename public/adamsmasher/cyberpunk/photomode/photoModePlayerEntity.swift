
public class PhotoModePlayerEntityComponent extends ScriptableComponent {

  private let usedWeaponItemId: ItemID;

  private let currentWeaponInSlot: ItemID;

  private let availableItemTypesList: array<gamedataItemType>;

  private let availableItemsList: array<wref<gameItemData>>;

  private let swapMeeleWeaponItemId: ItemID;

  private let swapHangunWeaponItemId: ItemID;

  private let swapRifleWeaponItemId: ItemID;

  private let swapShootgunWeaponItemId: ItemID;

  private let fakePuppet: wref<gamePuppet>;

  private let playerPuppet: wref<PlayerPuppet>;

  private let TS: ref<TransactionSystem>;

  private let loadingItems: array<ItemID>;

  private let itemsLoadingTimeout: Float;

  private let muzzleEffectEnabled: Bool;

  private final func OnGameAttach() -> Void;

  private final func OnGameDetach() -> Void;

  private final func HasAllItemsFinishedLoading() -> Bool {
    let time: Float = EngineTime.ToFloat(this.GetEngineTime()) - this.itemsLoadingTimeout;
    if time > 5.00 {
      ArrayClear(this.loadingItems);
    };
    return ArraySize(this.loadingItems) == 0;
  }

  private final func PutOnFakeItem(itemToAdd: ItemID) -> Void {
    let currSlot: TweakDBID;
    let equipAreaType: gamedataEquipmentArea;
    let item: ItemID;
    let itemData: wref<gameItemData>;
    if EquipmentSystem.GetData(this.playerPuppet).IsItemHidden(itemToAdd) {
      return;
    };
    equipAreaType = EquipmentSystem.GetEquipAreaType(itemToAdd);
    currSlot = EquipmentSystem.GetPlacementSlot(itemToAdd);
    if Equals(equipAreaType, gamedataEquipmentArea.RightArm) {
      item = ItemID.FromTDBID(ItemID.GetTDBID(itemToAdd));
      this.TS.GiveItem(this.fakePuppet, item, 1);
      if this.TS.CanPlaceItemInSlot(this.fakePuppet, currSlot, item) {
        if this.TS.AddItemToSlot(this.fakePuppet, currSlot, item, true) {
          if this.TS.HasItemInSlot(this.playerPuppet, currSlot, itemToAdd) {
            ArrayPush(this.loadingItems, item);
          };
          this.itemsLoadingTimeout = EngineTime.ToFloat(this.GetEngineTime());
        };
      };
    } else {
      itemData = this.TS.GetItemData(this.playerPuppet, itemToAdd);
      item = itemData.GetID();
      this.TS.GivePreviewItemByItemData(this.fakePuppet, itemData);
      if this.TS.CanPlaceItemInSlot(this.fakePuppet, currSlot, item) {
        if this.TS.AddItemToSlot(this.fakePuppet, currSlot, item, true) {
          if this.TS.HasItemInSlot(this.playerPuppet, currSlot, itemToAdd) {
            ArrayPush(this.loadingItems, item);
          };
          this.itemsLoadingTimeout = EngineTime.ToFloat(this.GetEngineTime());
        };
      };
    };
  }

  private final func RemoveAllItems(areas: array<SEquipArea>) -> Void {
    let currentPlayerItem: ItemID;
    let i: Int32 = 0;
    while i < ArraySize(areas) {
      currentPlayerItem = EquipmentSystem.GetData(this.fakePuppet).GetActiveItem(areas[i].areaType);
      if ItemID.IsValid(currentPlayerItem) {
        this.TS.RemoveItem(this.fakePuppet, currentPlayerItem, 1);
      };
      i += 1;
    };
  }

  private final func ListAllItems() -> Void {
    let i: Int32;
    let itemType: gamedataItemType;
    this.TS.GetItemList(this.playerPuppet, this.availableItemsList);
    i = 0;
    while i < ArraySize(this.availableItemsList) {
      itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.availableItemsList[i].GetID())).ItemType().Type();
      if !ArrayContains(this.availableItemTypesList, itemType) {
        ArrayPush(this.availableItemTypesList, itemType);
      };
      i += 1;
    };
  }

  private final func GetAllAvailableItemTypes() -> array<gamedataItemType> {
    return this.availableItemTypesList;
  }

  private final func GetWeaponInHands() -> gamedataItemType {
    let itemType: gamedataItemType;
    if !ItemID.IsValid(this.usedWeaponItemId) {
      return gamedataItemType.Invalid;
    };
    itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.usedWeaponItemId)).ItemType().Type();
    return itemType;
  }

  private final func IsItemOfThisType(item: ItemID, typesList: array<gamedataItemType>) -> Bool {
    let itemType: gamedataItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().Type();
    let i: Int32 = 0;
    while i < ArraySize(typesList) {
      if Equals(itemType, typesList[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func AddAmmoForWeapon(weaponID: ItemID) -> Void {
    let ammoID: ItemID = WeaponObject.GetAmmoType(weaponID);
    if ItemID.IsValid(ammoID) {
      this.TS.GiveItem(this.fakePuppet, ammoID, 1);
    };
  }

  private final func EquipWeaponOfThisType(typesList: array<gamedataItemType>) -> Void {
    let currSlot: TweakDBID;
    let i: Int32;
    if ItemID.IsValid(this.currentWeaponInSlot) && this.IsItemOfThisType(this.currentWeaponInSlot, typesList) {
      return;
    };
    if ItemID.IsValid(this.usedWeaponItemId) && this.IsItemOfThisType(this.usedWeaponItemId, typesList) {
      this.AddAmmoForWeapon(this.usedWeaponItemId);
      this.PutOnFakeItem(this.usedWeaponItemId);
      this.currentWeaponInSlot = this.usedWeaponItemId;
      return;
    };
    i = 0;
    while i < ArraySize(this.availableItemsList) {
      if ItemID.IsValid(this.availableItemsList[i].GetID()) && this.IsItemOfThisType(this.availableItemsList[i].GetID(), typesList) {
        this.AddAmmoForWeapon(this.availableItemsList[i].GetID());
        this.PutOnFakeItem(this.availableItemsList[i].GetID());
        this.currentWeaponInSlot = this.availableItemsList[i].GetID();
        return;
      };
      i += 1;
    };
    if ItemID.IsValid(this.currentWeaponInSlot) {
      currSlot = EquipmentSystem.GetPlacementSlot(this.currentWeaponInSlot);
      this.TS.RemoveItemFromSlot(this.fakePuppet, currSlot);
      this.currentWeaponInSlot = ItemID.undefined();
    };
  }

  protected cb func OnItemAddedToSlot(evt: ref<ItemAddedToSlot>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.loadingItems) {
      if this.loadingItems[i] == evt.GetItemID() {
        ArrayErase(this.loadingItems, i);
      } else {
        i += 1;
      };
    };
    if EquipmentSystem.GetData(this.playerPuppet).IsItemHidden(evt.GetItemID()) {
      this.TS.RemoveItem(this.fakePuppet, evt.GetItemID(), 1);
    } else {
      if this.currentWeaponInSlot == evt.GetItemID() {
        if this.muzzleEffectEnabled {
          this.SetMuzzleEffectEnabled(true);
        };
      };
    };
  }

  public final func StopWeaponShootEffects() -> Void {
    let weaponInHands: ref<WeaponObject> = GameObject.GetActiveWeapon(this.playerPuppet);
    if IsDefined(weaponInHands) {
      WeaponObject.StopWeaponEffects(this.playerPuppet, weaponInHands, gamedataFxAction.Shoot);
    };
  }

  public final func SetMuzzleEffectEnabled(enabled: Bool) -> Void {
    let weaponInHands: ref<WeaponObject> = GameObject.GetActiveWeapon(this.fakePuppet);
    this.muzzleEffectEnabled = enabled;
    if IsDefined(weaponInHands) {
      if enabled {
        GameObjectEffectHelper.StartEffectEvent(weaponInHands, n"muzzle_flash_photo_mode", false, null);
      } else {
        GameObjectEffectHelper.StopEffectEvent(weaponInHands, n"muzzle_flash_photo_mode");
      };
    };
  }

  public final func IsMuzzleFireSupported() -> Bool {
    let itemType: gamedataItemType;
    if ItemID.IsValid(this.currentWeaponInSlot) {
      itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.currentWeaponInSlot)).ItemType().Type();
      return Equals(itemType, gamedataItemType.Wea_AssaultRifle) || Equals(itemType, gamedataItemType.Wea_Handgun) || Equals(itemType, gamedataItemType.Wea_HeavyMachineGun) || Equals(itemType, gamedataItemType.Wea_LightMachineGun) || Equals(itemType, gamedataItemType.Wea_PrecisionRifle) || Equals(itemType, gamedataItemType.Wea_Revolver) || Equals(itemType, gamedataItemType.Wea_Rifle) || Equals(itemType, gamedataItemType.Wea_Shotgun) || Equals(itemType, gamedataItemType.Wea_ShotgunDual) || Equals(itemType, gamedataItemType.Wea_SniperRifle) || Equals(itemType, gamedataItemType.Wea_SubmachineGun);
    };
    return false;
  }

  private final func ClearInventory() -> Void {
    let equipmentData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(this.fakePuppet);
    let areas: array<SEquipArea> = this.GetPhotoModeEquipAreas(equipmentData, true);
    this.RemoveAllItems(areas);
  }

  private final func SetupUnderwear() -> Void;

  private final func SetupInventory(isCurrentPlayerObjectCustomizable: Bool) -> Void {
    let currentPlayerItem: ItemID;
    let head: ItemID;
    let i: Int32;
    let weaponInHands: ref<WeaponObject>;
    this.muzzleEffectEnabled = false;
    this.fakePuppet = this.GetEntity() as gamePuppet;
    this.playerPuppet = GameInstance.GetPlayerSystem(this.fakePuppet.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let gender: CName = this.fakePuppet.GetResolvedGenderName();
    this.TS = GameInstance.GetTransactionSystem(this.fakePuppet.GetGame());
    let equipmentData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(this.playerPuppet);
    let areas: array<SEquipArea> = this.GetPhotoModeEquipAreas(equipmentData, isCurrentPlayerObjectCustomizable);
    this.ListAllItems();
    weaponInHands = GameObject.GetActiveWeapon(this.playerPuppet);
    if IsDefined(weaponInHands) {
      this.usedWeaponItemId = weaponInHands.GetItemID();
    };
    i = 0;
    while i < ArraySize(areas) {
      currentPlayerItem = EquipmentSystem.GetData(this.playerPuppet).GetActiveItem(areas[i].areaType);
      if ItemID.IsValid(currentPlayerItem) {
        this.PutOnFakeItem(currentPlayerItem);
      };
      i += 1;
    };
    if isCurrentPlayerObjectCustomizable {
      if Equals(gender, n"Male") {
        head = ItemID.FromTDBID(t"Items.PlayerMaPhotomodeHead");
      } else {
        if Equals(gender, n"Female") {
          head = ItemID.FromTDBID(t"Items.PlayerWaPhotomodeHead");
        };
      };
      ArrayPush(this.loadingItems, head);
      this.TS.GiveItem(this.fakePuppet, head, 1);
      this.TS.AddItemToSlot(this.fakePuppet, EquipmentSystem.GetPlacementSlot(head), head, true);
    };
  }

  public final const func GetPhotoModeEquipAreas(equipmentData: ref<EquipmentSystemPlayerData>, withUnderwear: Bool) -> array<SEquipArea> {
    let areas: array<SEquipArea>;
    let slots: array<gamedataEquipmentArea> = this.GetPhotoModeSlots(withUnderwear);
    let i: Int32 = 0;
    while i < ArraySize(slots) {
      ArrayPush(areas, this.GetEquipArea(equipmentData, slots[i]));
      i += 1;
    };
    return areas;
  }

  public final const func GetPhotoModeSlots(withUnderwear: Bool) -> array<gamedataEquipmentArea> {
    let slots: array<gamedataEquipmentArea>;
    if withUnderwear {
      ArrayPush(slots, gamedataEquipmentArea.UnderwearTop);
      ArrayPush(slots, gamedataEquipmentArea.UnderwearBottom);
    };
    ArrayPush(slots, gamedataEquipmentArea.Outfit);
    ArrayPush(slots, gamedataEquipmentArea.OuterChest);
    ArrayPush(slots, gamedataEquipmentArea.InnerChest);
    ArrayPush(slots, gamedataEquipmentArea.Head);
    ArrayPush(slots, gamedataEquipmentArea.Face);
    ArrayPush(slots, gamedataEquipmentArea.Legs);
    ArrayPush(slots, gamedataEquipmentArea.Feet);
    ArrayPush(slots, gamedataEquipmentArea.HandsCW);
    ArrayPush(slots, gamedataEquipmentArea.RightArm);
    ArrayPush(slots, gamedataEquipmentArea.LeftArm);
    return slots;
  }

  private final const func GetEquipArea(equipmentData: ref<EquipmentSystemPlayerData>, areaType: gamedataEquipmentArea) -> SEquipArea {
    let emptyArea: SEquipArea;
    let equipment: SLoadout = equipmentData.GetEquipment();
    let i: Int32 = 0;
    while i < ArraySize(equipment.equipAreas) {
      if Equals(equipment.equipAreas[i].areaType, areaType) {
        return equipment.equipAreas[i];
      };
      i += 1;
    };
    return emptyArea;
  }
}
