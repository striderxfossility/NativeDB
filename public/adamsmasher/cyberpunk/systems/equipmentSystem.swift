
public static func Cast(hotkey: EHotkey) -> Int32 {
  return EnumInt(hotkey);
}

public class AssignHotkeyIfEmptySlot extends PlayerScriptableSystemRequest {

  private let itemID: ItemID;

  public final static func Construct(itemID: ItemID, owner: wref<GameObject>) -> ref<AssignHotkeyIfEmptySlot> {
    let self: ref<AssignHotkeyIfEmptySlot> = new AssignHotkeyIfEmptySlot();
    self.owner = owner;
    self.itemID = itemID;
    return self;
  }

  public final const func ItemID() -> ItemID {
    return this.itemID;
  }

  public final const func Owner() -> ref<GameObject> {
    return this.owner;
  }

  public final const func IsValid() -> Bool {
    if IsDefined(this.owner) && ItemID.IsValid(this.itemID) {
      return true;
    };
    return false;
  }
}

public class HotkeyAssignmentRequest extends PlayerScriptableSystemRequest {

  protected let itemID: ItemID;

  private let hotkey: EHotkey;

  protected let requestType: EHotkeyRequestType;

  public final const func ItemID() -> ItemID {
    return this.itemID;
  }

  public final const func GetHotkey() -> EHotkey {
    return this.hotkey;
  }

  public final const func Owner() -> ref<GameObject> {
    return this.owner;
  }

  public final const func GetRequestType() -> EHotkeyRequestType {
    return this.requestType;
  }

  public final static func Construct(itemID: ItemID, hotkey: EHotkey, owner: wref<GameObject>, requestType: EHotkeyRequestType) -> ref<HotkeyAssignmentRequest> {
    let self: ref<HotkeyAssignmentRequest> = new HotkeyAssignmentRequest();
    self.owner = owner;
    self.itemID = itemID;
    self.hotkey = hotkey;
    self.requestType = requestType;
    return self;
  }

  public final const func IsValid() -> Bool {
    if IsDefined(this.owner) && NotEquals(this.hotkey, EHotkey.INVALID) {
      return true;
    };
    return false;
  }
}

public class Hotkey extends IScriptable {

  private persistent let hotkey: EHotkey;

  private persistent let itemID: ItemID;

  private persistent let scope: array<gamedataItemType>;

  public final static func Construct(hotk: EHotkey, opt id: ItemID) -> ref<Hotkey> {
    let h: ref<Hotkey> = new Hotkey();
    h.hotkey = hotk;
    if ItemID.IsValid(id) {
      h.itemID = id;
    };
    h.SetScope(Hotkey.GetScope(hotk));
    return h;
  }

  public final func StoreItem(id: ItemID) -> Void {
    this.itemID = id;
  }

  public final const func IsEmpty() -> Bool {
    return this.itemID == ItemID.undefined();
  }

  public final const func GetItemID() -> ItemID {
    return this.itemID;
  }

  public final const func GetHotkey() -> EHotkey {
    return this.hotkey;
  }

  public final const func GetScope() -> array<gamedataItemType> {
    if ArraySize(this.scope) > 0 {
      return this.scope;
    };
    return Hotkey.GetScope(this.GetHotkey());
  }

  public final const func IsCompatible(type: gamedataItemType) -> Bool {
    let range: array<gamedataItemType> = this.GetScope();
    let i: Int32 = 0;
    while i < ArraySize(range) {
      if Equals(range[i], type) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func SetScope(itemTypes: array<gamedataItemType>) -> Void {
    this.scope = itemTypes;
  }

  public final static func IsCompatible(hotkey: EHotkey, type: gamedataItemType) -> Bool {
    let scope: array<gamedataItemType> = Hotkey.GetScope(hotkey);
    return ArrayContains(scope, type);
  }

  public final static func GetScope(hotkey: EHotkey) -> array<gamedataItemType> {
    let scope: array<gamedataItemType>;
    if Equals(hotkey, EHotkey.DPAD_UP) {
      ArrayPush(scope, gamedataItemType.Con_Inhaler);
      ArrayPush(scope, gamedataItemType.Con_Injector);
    } else {
      if Equals(hotkey, EHotkey.RB) {
        ArrayPush(scope, gamedataItemType.Cyb_Ability);
        ArrayPush(scope, gamedataItemType.Cyb_Launcher);
        ArrayPush(scope, gamedataItemType.Gad_Grenade);
      };
    };
    return scope;
  }
}

public struct HotkeyManager {

  public final static func InitializeHotkeys(hotkeys: script_ref<array<ref<Hotkey>>>) -> Void {
    let freshHotkey: ref<Hotkey>;
    let hotkeyIndex: Int32;
    let hotkeysCount: Int32;
    ArrayClear(Deref(hotkeys));
    hotkeysCount = Cast(EnumGetMax(n"EHotkey"));
    hotkeysCount += 1;
    hotkeyIndex = 0;
    while hotkeyIndex < hotkeysCount {
      freshHotkey = Hotkey.Construct(IntEnum(hotkeyIndex));
      ArrayPush(Deref(hotkeys), freshHotkey);
      hotkeyIndex += 1;
    };
  }

  public final static func IsItemInHotkey(hotkeys: script_ref<array<ref<Hotkey>>>, itemID: ItemID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(Deref(hotkeys)) {
      if Deref(hotkeys)[i].GetItemID() == itemID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func GetHotkeyTypeForItemID(owner: wref<GameObject>, hotkeys: script_ref<array<ref<Hotkey>>>, itemID: ItemID) -> EHotkey {
    let itemData: wref<gameItemData> = RPGManager.GetItemData(owner.GetGame(), owner, itemID);
    let i: Int32 = 0;
    while i < ArraySize(Deref(hotkeys)) {
      if Deref(hotkeys)[i].IsCompatible(itemData.GetItemType()) {
        return Deref(hotkeys)[i].GetHotkey();
      };
      i += 1;
    };
    return EHotkey.INVALID;
  }

  public final static func GetHotkeyTypeFromItemID(hotkeys: script_ref<array<ref<Hotkey>>>, itemID: ItemID) -> EHotkey {
    let i: Int32 = 0;
    while i < ArraySize(Deref(hotkeys)) {
      if Deref(hotkeys)[i].GetItemID() == itemID {
        return Deref(hotkeys)[i].GetHotkey();
      };
      i += 1;
    };
    return EHotkey.INVALID;
  }

  public final static func GetItemIDFromHotkey(hotkeys: script_ref<array<ref<Hotkey>>>, hotkey: EHotkey) -> ItemID {
    return Deref(hotkeys)[EnumInt(hotkey)].GetItemID();
  }
}

public class EquipmentSystemPlayerData extends IScriptable {

  public let m_owner: wref<ScriptedPuppet>;

  private persistent let m_ownerID: EntityID;

  private persistent let m_equipment: SLoadout;

  private persistent let m_lastUsedStruct: SLastUsedWeapon;

  private persistent let m_slotActiveItemsInHands: SSlotActiveItems;

  private let m_hiddenItems: array<ItemID>;

  private persistent let m_clothingSlotsInfo: array<SSlotInfo>;

  private persistent let m_isPartialVisualTagActive: Bool;

  private let m_visualTagProcessingInfo: array<SVisualTagProcessing>;

  private let m_eventsSent: Int32;

  private persistent let m_hotkeys: array<ref<Hotkey>>;

  private let m_inventoryManager: ref<InventoryDataManagerV2>;

  public final func OnAttach() -> Void {
    if IsDefined(this.m_owner as PlayerPuppet) {
      if ArraySize(this.m_hotkeys) == 0 {
        HotkeyManager.InitializeHotkeys(this.m_hotkeys);
      };
      this.m_inventoryManager = new InventoryDataManagerV2();
      this.m_inventoryManager.Initialize(this.m_owner as PlayerPuppet);
    };
  }

  public final func OnDetach() -> Void;

  public final func OnInitialize() -> Void {
    this.InitializeEquipment();
    this.InitializeClothingSlotsInfo();
  }

  public final func OnRestored() -> Void {
    let audioEventFoley: ref<AudioEvent>;
    let currentEquipmentArea: gamedataEquipmentArea;
    let currentItem: ItemID;
    let i: Int32;
    let itemRecord: ref<Item_Record>;
    let j: Int32;
    let paperdollEquipData: SPaperdollEquipData;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(this.m_owner.GetGame()).GetLocalPlayerControlledGameObject();
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    ArrayClear(this.m_hiddenItems);
    if transSystem == null {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      currentEquipmentArea = this.m_equipment.equipAreas[i].areaType;
      j = 0;
      while j < ArraySize(this.m_equipment.equipAreas[i].equipSlots) {
        currentItem = this.m_equipment.equipAreas[i].equipSlots[j].itemID;
        if ItemID.IsValid(currentItem) {
          itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(currentItem));
          if itemRecord == null {
          } else {
            this.ApplyEquipGLPs(currentItem);
            if Equals(itemRecord.EquipArea().Type(), gamedataEquipmentArea.SystemReplacementCW) {
              transSystem.AddItemToSlot(this.m_owner, this.GetPlacementSlot(i, j), currentItem);
            };
            if Equals(itemRecord.ItemCategory().Type(), gamedataItemCategory.Clothing) {
              transSystem.AddItemToSlot(this.m_owner, this.GetPlacementSlot(i, j), currentItem);
              audioEventFoley = new AudioEvent();
              audioEventFoley.eventName = n"equipItem";
              audioEventFoley.nameData = itemRecord.AppearanceName();
              this.m_owner.QueueEvent(audioEventFoley);
            };
            if this.m_owner == playerControlledObject {
              transSystem.OnItemAddedToEquipmentSlot(this.m_owner, currentItem);
              if Equals(currentEquipmentArea, gamedataEquipmentArea.Weapon) || Equals(currentEquipmentArea, gamedataEquipmentArea.WeaponHeavy) {
                this.SendPSMWeaponManipulationRequest(EquipmentManipulationRequestType.Equip, EquipmentManipulationRequestSlot.Right, gameEquipAnimationType.Default);
              };
            };
            paperdollEquipData.equipArea = this.m_equipment.equipAreas[i];
            paperdollEquipData.equipped = this.IsItemHidden(currentItem) ? false : true;
            paperdollEquipData.placementSlot = this.GetPlacementSlot(i, j);
            if TDBID.IsValid(paperdollEquipData.placementSlot) {
              this.UpdateEquipmentUIBB(paperdollEquipData, true);
            };
          };
        };
        j += 1;
      };
      i += 1;
    };
    this.HotkeysOnRestore();
  }

  public final func HotkeysOnRestore() -> Void {
    let item: ItemID;
    let i: Int32 = 0;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    i;
    while i < ArraySize(this.m_hotkeys) {
      item = this.m_hotkeys[i].GetItemID();
      if ItemID.IsValid(item) {
        transactionSystem.OnItemAddedToEquipmentSlot(this.m_owner, item);
      };
      i += 1;
    };
  }

  public final func SetOwner(owner: ref<ScriptedPuppet>) -> Void {
    this.m_owner = owner;
    this.m_ownerID = owner.GetEntityID();
  }

  public final func GetOwner() -> wref<ScriptedPuppet> {
    return this.m_owner;
  }

  public final func GetOwnerID() -> EntityID {
    return this.m_ownerID;
  }

  public final func GetEquipment() -> SLoadout {
    return this.m_equipment;
  }

  public final func GetLastUsedStruct() -> SLastUsedWeapon {
    return this.m_lastUsedStruct;
  }

  public final func ClearLastUsedStruct() -> Void {
    let emptyLastUsedStruct: SLastUsedWeapon;
    this.m_lastUsedStruct = emptyLastUsedStruct;
  }

  public final func GetSlotActiveItemStruct() -> SSlotActiveItems {
    return this.m_slotActiveItemsInHands;
  }

  private final func InitializeEquipment() -> Void {
    let equipAreas: array<wref<EquipmentArea_Record>>;
    let i: Int32;
    let ownerRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(this.m_owner.GetRecordID());
    ownerRecord.EquipmentAreas(equipAreas);
    i = 0;
    while i < ArraySize(equipAreas) {
      this.InitializeEquipmentArea(equipAreas[i]);
      i += 1;
    };
  }

  private final func InitializeEquipmentArea(equipAreaRecord: ref<EquipmentArea_Record>) -> Void {
    let equipArea: SEquipArea;
    let equipSlot: SEquipSlot;
    equipArea.areaType = equipAreaRecord.Type();
    equipArea.activeIndex = 0;
    let i: Int32 = 0;
    while i < equipAreaRecord.NumberOfEquipSlots() {
      ArrayPush(equipArea.equipSlots, equipSlot);
      i += 1;
    };
    ArrayPush(this.m_equipment.equipAreas, equipArea);
  }

  private final func InitializeClothingSlotsInfo() -> Void {
    ArrayClear(this.m_clothingSlotsInfo);
    ArrayPush(this.m_clothingSlotsInfo, this.CreateSlotInfo(gamedataEquipmentArea.OuterChest, "AttachmentSlots.Torso", n"hide_T2"));
    ArrayPush(this.m_clothingSlotsInfo, this.CreateSlotInfo(gamedataEquipmentArea.InnerChest, "AttachmentSlots.Chest", n"hide_T1"));
    ArrayPush(this.m_clothingSlotsInfo, this.CreateSlotInfo(gamedataEquipmentArea.Legs, "AttachmentSlots.Legs", n"hide_L1"));
    ArrayPush(this.m_clothingSlotsInfo, this.CreateSlotInfo(gamedataEquipmentArea.Feet, "AttachmentSlots.Feet", n"hide_S1"));
    ArrayPush(this.m_clothingSlotsInfo, this.CreateSlotInfo(gamedataEquipmentArea.Head, "AttachmentSlots.Head", n"hide_H1"));
    ArrayPush(this.m_clothingSlotsInfo, this.CreateSlotInfo(gamedataEquipmentArea.Face, "AttachmentSlots.Eyes", n"hide_F1"));
    ArrayPush(this.m_clothingSlotsInfo, this.CreateSlotInfo(gamedataEquipmentArea.UnderwearBottom, "AttachmentSlots.UnderwearBottom", n"hide_Genitals"));
  }

  private final func CreateSlotInfo(area: gamedataEquipmentArea, slot: String, visualTag: CName) -> SSlotInfo {
    let slotInfo: SSlotInfo;
    slotInfo.areaType = area;
    slotInfo.equipSlot = TDBID.Create(slot);
    slotInfo.visualTag = visualTag;
    return slotInfo;
  }

  public final func EquipItem(itemID: ItemID, opt addToInventory: Bool, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    let equipArea: SEquipArea;
    let equipAreaIndex: Int32;
    let equipAreaType: gamedataEquipmentArea;
    let equipAtIndex: Int32;
    let i: Int32;
    if ItemID.IsValid(itemID) && !this.IsEquipped(itemID) {
      equipAreaType = EquipmentSystem.GetEquipAreaType(itemID);
      equipAreaIndex = this.GetEquipAreaIndex(equipAreaType);
      equipArea = this.m_equipment.equipAreas[equipAreaIndex];
      i = 0;
      while i < ArraySize(equipArea.equipSlots) {
        if !ItemID.IsValid(equipArea.equipSlots[i].itemID) {
          this.EquipItem(itemID, i, addToInventory, blockActiveSlotsUpdate, forceEquipWeapon);
          return;
        };
        i += 1;
      };
      this.EquipItem(itemID, equipArea.activeIndex, addToInventory, blockActiveSlotsUpdate, forceEquipWeapon);
    } else {
      if ItemID.IsValid(itemID) && this.IsEquipped(itemID) {
        equipAtIndex = this.GetSlotIndex(itemID);
        if equipAtIndex >= 0 {
          this.EquipItem(itemID, equipAtIndex, false, blockActiveSlotsUpdate, forceEquipWeapon);
        };
      };
    };
  }

  private final func EquipItem(itemID: ItemID, slotIndex: Int32, opt addToInventory: Bool, opt blockActiveSlotsUpdate: Bool, opt forceEquipWeapon: Bool) -> Void {
    let audioEventFoley: ref<AudioEvent>;
    let audioEventFootwear: ref<AudioEvent>;
    let currentItem: ItemID;
    let currentItemData: wref<gameItemData>;
    let cyberwareType: CName;
    let equipArea: SEquipArea;
    let equipAreaIndex: Int32;
    let i: Int32;
    let paperdollEquipData: SPaperdollEquipData;
    let placementSlot: TweakDBID;
    let transactionSystem: ref<TransactionSystem>;
    let weaponRecord: ref<WeaponItem_Record>;
    let itemData: wref<gameItemData> = RPGManager.GetItemData(this.m_owner.GetGame(), this.m_owner, itemID);
    if !this.IsEquippable(itemData) {
      return;
    };
    if Equals(RPGManager.GetItemRecord(itemID).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
      this.HandleStrongArmsEquip(itemID);
    };
    equipAreaIndex = this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaType(itemID));
    equipArea = this.m_equipment.equipAreas[equipAreaIndex];
    currentItem = this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
    currentItemData = RPGManager.GetItemData(this.m_owner.GetGame(), this.m_owner, currentItem);
    if IsDefined(currentItemData) && currentItemData.HasTag(n"UnequipBlocked") {
      return;
    };
    if this.IsItemOfCategory(itemID, gamedataItemCategory.Weapon) && equipArea.activeIndex == slotIndex && this.CheckWeaponAgainstGameplayRestrictions(itemID) && !blockActiveSlotsUpdate {
      this.SetSlotActiveItem(EquipmentManipulationRequestSlot.Right, itemID);
      this.SetLastUsedItem(itemID);
    } else {
      if this.IsItemOfCategory(itemID, gamedataItemCategory.Weapon) && forceEquipWeapon && this.CheckWeaponAgainstGameplayRestrictions(itemID) {
        this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID = itemID;
        this.SetSlotActiveItem(EquipmentManipulationRequestSlot.Right, itemID);
        this.UpdateEquipAreaActiveIndex(itemID);
        this.SetLastUsedItem(itemID);
      } else {
        this.UnequipItem(equipAreaIndex, slotIndex);
        cyberwareType = TweakDBInterface.GetCName(ItemID.GetTDBID(itemID) + t".cyberwareType", n"");
        i = 0;
        while i < ArraySize(this.m_equipment.equipAreas[equipAreaIndex].equipSlots) {
          if Equals(cyberwareType, TweakDBInterface.GetCName(ItemID.GetTDBID(this.m_equipment.equipAreas[equipAreaIndex].equipSlots[i].itemID) + t".cyberwareType", n"type")) {
            this.UnequipItem(equipAreaIndex, i);
          };
          i += 1;
        };
      };
    };
    if Equals(equipArea.areaType, gamedataEquipmentArea.ArmsCW) {
      this.UnequipItem(equipAreaIndex, slotIndex);
    };
    this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID = itemID;
    transactionSystem = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    placementSlot = this.GetPlacementSlot(equipAreaIndex, slotIndex);
    if placementSlot == t"AttachmentSlots.WeaponRight" || placementSlot == t"AttachmentSlots.WeaponLeft" {
      weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(itemID));
      if IsDefined(weaponRecord) && IsDefined(weaponRecord.HolsteredItem()) {
        EquipmentSystemPlayerData.UpdateArmSlot(this.m_owner as PlayerPuppet, itemID, true);
      };
    };
    if placementSlot != t"AttachmentSlots.WeaponRight" && placementSlot != t"AttachmentSlots.WeaponLeft" && placementSlot != t"AttachmentSlots.Consumable" {
      if !transactionSystem.HasItemInSlot(this.m_owner, placementSlot, itemID) {
        transactionSystem.RemoveItemFromSlot(this.m_owner, placementSlot);
        transactionSystem.AddItemToSlot(this.m_owner, placementSlot, itemID);
      };
    };
    if Equals(RPGManager.GetItemRecord(itemID).ItemType().Type(), gamedataItemType.Clo_Feet) {
      audioEventFootwear = new AudioEvent();
      audioEventFootwear.eventName = n"equipFootwear";
      audioEventFootwear.nameData = RPGManager.GetItemRecord(itemID).MovementSound().AudioMovementName();
      this.m_owner.QueueEvent(audioEventFootwear);
    };
    audioEventFoley = new AudioEvent();
    audioEventFoley.eventName = n"equipItem";
    audioEventFoley.nameData = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).AppearanceName();
    this.m_owner.QueueEvent(audioEventFoley);
    paperdollEquipData.equipArea = this.m_equipment.equipAreas[equipAreaIndex];
    paperdollEquipData.equipped = true;
    paperdollEquipData.placementSlot = placementSlot;
    paperdollEquipData.slotIndex = slotIndex;
    this.ApplyEquipGLPs(itemID);
    this.UpdateWeaponWheel();
    this.UpdateQuickWheel();
    this.UpdateEquipmentUIBB(paperdollEquipData);
    i = 0;
    while i < ArraySize(this.m_hotkeys) {
      if this.m_hotkeys[i].IsCompatible(itemData.GetItemType()) {
        this.AssignItemToHotkey(itemData.GetID(), this.m_hotkeys[i].GetHotkey());
      };
      i += 1;
    };
    EquipmentSystem.GetInstance(this.m_owner).Debug_FillESSlotData(slotIndex, this.m_equipment.equipAreas[equipAreaIndex].areaType, itemID, this.m_owner);
    if ItemID.IsValid(currentItem) && currentItem != itemID {
      transactionSystem.OnItemRemovedFromEquipmentSlot(this.m_owner, currentItem);
    };
    transactionSystem.OnItemAddedToEquipmentSlot(this.m_owner, itemID);
    if this.IsItemOfCategory(itemID, gamedataItemCategory.Cyberware) || Equals(equipArea.areaType, gamedataEquipmentArea.ArmsCW) {
      this.CheckCyberjunkieAchievement();
    };
    if EquipmentSystem.IsItemCyberdeck(itemID) {
      PlayerPuppet.ChacheQuickHackListCleanup(this.m_owner);
    };
  }

  private final func ProcessGadgetsTutorials(item: ItemID) -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_owner.GetGame());
    if Equals(RPGManager.GetItemCategory(item), gamedataItemCategory.Gadget) && questSystem.GetFact(n"grenade_use_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"grenade_use_tutorial", 1);
    };
    if (Equals(RPGManager.GetItemType(item), gamedataItemType.Con_Inhaler) || Equals(RPGManager.GetItemType(item), gamedataItemType.Con_Injector)) && questSystem.GetFact(n"consumable_use_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"consumable_use_tutorial", 1);
    };
  }

  public final func OnEquipProcessVisualTags(itemID: ItemID) -> Void {
    let i: Int32;
    let isUnderwearHidden: Bool;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let itemEntity: wref<GameObject> = transactionSystem.GetItemInSlotByItemID(this.m_owner, itemID);
    let areaType: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(itemID);
    let tag: CName = this.GetVisualTagByAreaType(areaType);
    if NotEquals(tag, n"") && this.IsVisualTagActive(tag) {
      this.ClearItemAppearanceEvent(areaType);
    } else {
      if IsDefined(itemEntity) {
        i = 0;
        while i < ArraySize(this.m_clothingSlotsInfo) {
          if transactionSystem.MatchVisualTag(itemEntity, this.m_clothingSlotsInfo[i].visualTag, true) && !transactionSystem.IsSlotEmpty(this.m_owner, this.m_clothingSlotsInfo[i].equipSlot) {
            this.ClearItemAppearanceEvent(this.m_clothingSlotsInfo[i].areaType);
          };
          i += 1;
        };
        if Equals(areaType, gamedataEquipmentArea.OuterChest) && this.IsPartialVisualTagActive(itemID, transactionSystem) {
          this.m_isPartialVisualTagActive = true;
          this.UpdateInnerChest(transactionSystem);
        };
        if (!this.IsUnderwearHidden() || Equals(areaType, gamedataEquipmentArea.UnderwearBottom)) && (ItemID.IsValid(this.GetActiveItem(gamedataEquipmentArea.Legs)) || this.IsVisualTagActive(n"hide_L1")) {
          this.ClearItemAppearanceEvent(gamedataEquipmentArea.UnderwearBottom);
        };
        isUnderwearHidden = this.EvaluateUnderwearTopHiddenState();
        if (!isUnderwearHidden || Equals(areaType, gamedataEquipmentArea.UnderwearTop)) && this.IsBuildCensored() && (ItemID.IsValid(this.GetActiveItem(gamedataEquipmentArea.InnerChest)) || this.IsVisualTagActive(n"hide_T1")) {
          this.ClearItemAppearanceEvent(gamedataEquipmentArea.UnderwearTop);
        };
      };
    };
  }

  private final func ClearItemAppearanceEvent(areaType: gamedataEquipmentArea) -> Void {
    let evt: ref<ClearItemAppearanceEvent>;
    let resetItemID: ItemID = this.GetActiveItem(areaType);
    this.AddHiddenItem(resetItemID);
    evt = new ClearItemAppearanceEvent();
    evt.itemID = resetItemID;
    this.m_eventsSent += 1;
    this.UpdateVisualTagProcessingInfo(areaType, false);
    this.m_owner.QueueEvent(evt);
  }

  public final func OnClearItemAppearance(resetItemID: ItemID) -> Void {
    this.OnUnequipProcessVisualTags(resetItemID, false);
    this.m_eventsSent -= 1;
    this.FinalizeVisualTagProcessing();
  }

  public final func ClearItemAppearance(transactionSystem: ref<TransactionSystem>, area: gamedataEquipmentArea) -> Void {
    let paperdollEquipData: SPaperdollEquipData;
    let currentID: ItemID = this.GetActiveItem(area);
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(area);
    paperdollEquipData.equipArea = this.m_equipment.equipAreas[equipAreaIndex];
    paperdollEquipData.equipped = false;
    paperdollEquipData.placementSlot = this.GetPlacementSlot(equipAreaIndex, this.GetSlotIndex(currentID));
    this.UpdateEquipmentUIBB(paperdollEquipData);
    transactionSystem.ChangeItemAppearance(this.m_owner, currentID, n"empty_appearance_default", false);
  }

  private final func OnUnequipProcessVisualTags(currentItem: ItemID, isUnequipping: Bool) -> Void {
    let i: Int32;
    let isUnderwearHidden: Bool;
    let itemEntity: ref<GameObject>;
    let ts: ref<TransactionSystem>;
    let area: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(currentItem);
    this.AddHiddenItem(currentItem);
    ts = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    itemEntity = ts.GetItemInSlotByItemID(this.m_owner, currentItem);
    i = 0;
    while i < ArraySize(this.m_clothingSlotsInfo) {
      if ts.MatchVisualTag(itemEntity, this.m_clothingSlotsInfo[i].visualTag) && !ts.IsSlotEmpty(this.m_owner, this.m_clothingSlotsInfo[i].equipSlot) {
        this.ResetItemAppearanceEvent(this.m_clothingSlotsInfo[i].areaType);
      };
      i += 1;
    };
    if this.m_isPartialVisualTagActive && ts.HasItemInSlot(this.m_owner, t"AttachmentSlots.Torso", currentItem) {
      this.m_isPartialVisualTagActive = false;
      this.UpdateInnerChest(ts);
    };
    if this.IsUnderwearHidden() && this.EvaluateUnderwearVisibility(currentItem) {
      this.ResetItemAppearanceEvent(gamedataEquipmentArea.UnderwearBottom);
    };
    if NotEquals(area, gamedataEquipmentArea.UnderwearTop) {
      isUnderwearHidden = this.EvaluateUnderwearTopHiddenState();
      if isUnderwearHidden && this.IsBuildCensored() && this.EvaluateUnderwearTopVisibility(currentItem) {
        this.ResetItemAppearanceEvent(gamedataEquipmentArea.UnderwearTop);
      };
    };
    if isUnequipping {
      this.RemoveHiddenItem(currentItem);
    };
  }

  private final func ResetItemAppearanceEvent(area: gamedataEquipmentArea) -> Void {
    let evt: ref<ResetItemAppearanceEvent>;
    let resetItemID: ItemID = this.GetActiveItem(area);
    this.RemoveHiddenItem(resetItemID);
    evt = new ResetItemAppearanceEvent();
    evt.itemID = resetItemID;
    this.m_eventsSent += 1;
    this.UpdateVisualTagProcessingInfo(area, true);
    this.m_owner.QueueEvent(evt);
  }

  public final func OnResetItemAppearance(resetItemID: ItemID) -> Void {
    this.OnEquipProcessVisualTags(resetItemID);
    this.m_eventsSent -= 1;
    this.FinalizeVisualTagProcessing();
  }

  private final func ResetItemAppearance(transactionSystem: ref<TransactionSystem>, area: gamedataEquipmentArea, opt force: Bool) -> Void {
    let paperdollEquipData: SPaperdollEquipData;
    let resetItemID: ItemID = this.GetActiveItem(area);
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(area);
    let slotIndex: Int32 = this.GetSlotIndex(resetItemID);
    paperdollEquipData.equipArea = this.m_equipment.equipAreas[equipAreaIndex];
    paperdollEquipData.equipped = true;
    paperdollEquipData.placementSlot = this.GetPlacementSlot(equipAreaIndex, slotIndex);
    paperdollEquipData.slotIndex = slotIndex;
    this.UpdateEquipmentUIBB(paperdollEquipData, force);
    transactionSystem.ResetItemAppearance(this.m_owner, resetItemID);
  }

  private final func UpdateInnerChest(ts: ref<TransactionSystem>) -> Void {
    let itemID: ItemID = this.GetActiveItem(gamedataEquipmentArea.InnerChest);
    if ItemID.IsValid(itemID) && !this.IsItemHidden(itemID) {
      this.ResetItemAppearance(ts, gamedataEquipmentArea.InnerChest, true);
    };
  }

  private final func UpdateVisualTagProcessingInfo(area: gamedataEquipmentArea, show: Bool) -> Void {
    let info: SVisualTagProcessing;
    let updated: Bool;
    info.areaType = area;
    info.showItem = show;
    let i: Int32 = 0;
    while i < ArraySize(this.m_visualTagProcessingInfo) {
      if Equals(this.m_visualTagProcessingInfo[i].areaType, area) {
        this.m_visualTagProcessingInfo[i].showItem = show;
        updated = true;
      };
      i += 1;
    };
    if !updated {
      ArrayPush(this.m_visualTagProcessingInfo, info);
    };
  }

  private final func FinalizeVisualTagProcessing() -> Void {
    let i: Int32;
    let transactionSystem: ref<TransactionSystem>;
    if this.m_eventsSent == 0 {
      transactionSystem = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
      i = 0;
      while i < ArraySize(this.m_visualTagProcessingInfo) {
        if this.m_visualTagProcessingInfo[i].showItem {
          this.ResetItemAppearance(transactionSystem, this.m_visualTagProcessingInfo[i].areaType);
        } else {
          this.ClearItemAppearance(transactionSystem, this.m_visualTagProcessingInfo[i].areaType);
        };
        i += 1;
      };
      ArrayClear(this.m_visualTagProcessingInfo);
    };
  }

  public final func IsItemHidden(id: ItemID) -> Bool {
    return ArrayContains(this.m_hiddenItems, id);
  }

  public final func IsUnderwearHidden() -> Bool {
    let item: ItemID = this.GetActiveItem(gamedataEquipmentArea.UnderwearBottom);
    if ItemID.IsValid(item) {
      return ArrayContains(this.m_hiddenItems, item);
    };
    this.UnderwearEquipFailsafe();
    return true;
  }

  public final func EvaluateUnderwearTopHiddenState() -> Bool {
    let ts: ref<TransactionSystem>;
    let item: ItemID = this.GetActiveItem(gamedataEquipmentArea.UnderwearTop);
    if this.IsBuildCensored() {
      if ItemID.IsValid(item) {
        return ArrayContains(this.m_hiddenItems, item);
      };
      this.UnderwearTopEquipFailsafe();
    } else {
      if ItemID.IsValid(item) {
        this.UnequipItem(item);
        ts = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
        ts.RemoveItem(this.m_owner, item, 1);
      };
    };
    return true;
  }

  private final func RemoveHiddenItem(id: ItemID) -> Void {
    let i: Int32;
    if this.IsItemHidden(id) {
      i = ArraySize(this.m_hiddenItems) - 1;
      while i >= 0 {
        if this.m_hiddenItems[i] == id {
          ArrayErase(this.m_hiddenItems, i);
        };
        i -= 1;
      };
    };
  }

  private final func AddHiddenItem(id: ItemID) -> Void {
    if ItemID.IsValid(id) && !this.IsItemHidden(id) {
      ArrayPush(this.m_hiddenItems, id);
    };
  }

  private final func GetVisualTagByAreaType(area: gamedataEquipmentArea) -> CName {
    let i: Int32 = 0;
    while i < ArraySize(this.m_clothingSlotsInfo) {
      if Equals(this.m_clothingSlotsInfo[i].areaType, area) {
        return this.m_clothingSlotsInfo[i].visualTag;
      };
      i += 1;
    };
    return n"";
  }

  private final func IsVisualTagActive(tag: CName) -> Bool {
    let equipArea: SEquipArea;
    let i: Int32;
    let itemID: ItemID;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let activeItem: wref<GameObject> = transactionSystem.GetItemInSlot(this.m_owner, t"AttachmentSlots.Outfit");
    if transactionSystem.MatchVisualTag(activeItem, tag) {
      return true;
    };
    i = 0;
    while i < ArraySize(this.m_clothingSlotsInfo) {
      activeItem = transactionSystem.GetItemInSlot(this.m_owner, this.m_clothingSlotsInfo[i].equipSlot);
      equipArea = this.GetEquipArea(this.m_clothingSlotsInfo[i].areaType);
      itemID = equipArea.equipSlots[0].itemID;
      if transactionSystem.MatchVisualTag(activeItem, tag, true) && !this.IsItemHidden(itemID) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsPartialVisualTagActive(itemID: ItemID, ts: ref<TransactionSystem>) -> Bool {
    let activeItem: wref<GameObject> = ts.GetItemInSlotByItemID(this.m_owner, itemID);
    if ts.MatchVisualTag(activeItem, n"hide_T1part") && !this.IsItemHidden(itemID) {
      return true;
    };
    return false;
  }

  public final const func IsPartialVisualTagActive() -> Bool {
    return this.m_isPartialVisualTagActive;
  }

  private final func GetVisualTagsByItem(activeItem: wref<GameObject>, out tags: array<SSlotInfo>) -> Bool {
    let result: Bool;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(this.m_clothingSlotsInfo) {
      if transactionSystem.MatchVisualTag(activeItem, this.m_clothingSlotsInfo[i].visualTag) {
        ArrayPush(tags, this.m_clothingSlotsInfo[i]);
        if !result {
          result = true;
        };
      };
      i += 1;
    };
    return result;
  }

  private final func EvaluateUnderwearVisibility(unequippedItem: ItemID) -> Bool {
    let i: Int32;
    let tagCounter: Int32;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let activeItem: ref<ItemObject> = transactionSystem.GetItemInSlotByItemID(this.m_owner, unequippedItem);
    if transactionSystem.MatchVisualTag(activeItem, n"hide_L1") || transactionSystem.MatchVisualTag(activeItem, n"hide_Genitals") || transactionSystem.HasItemInSlot(this.m_owner, t"AttachmentSlots.Legs", unequippedItem) {
      i = 0;
      while i < ArraySize(this.m_clothingSlotsInfo) {
        activeItem = transactionSystem.GetItemInSlot(this.m_owner, this.m_clothingSlotsInfo[i].equipSlot);
        if ItemID.IsValid(activeItem.GetItemID()) && (transactionSystem.MatchVisualTag(activeItem, n"hide_L1", true) || transactionSystem.MatchVisualTag(activeItem, n"hide_genitals") || this.m_clothingSlotsInfo[i].equipSlot == t"AttachmentSlots.Legs") {
          tagCounter += 1;
        };
        i += 1;
      };
      activeItem = transactionSystem.GetItemInSlot(this.m_owner, t"AttachmentSlots.Outfit");
      if transactionSystem.MatchVisualTag(activeItem, n"hide_L1", true) || transactionSystem.MatchVisualTag(activeItem, n"hide_Genitals") {
        tagCounter += 1;
      };
      if tagCounter == 1 {
        return true;
      };
      return false;
    };
    return false;
  }

  private final func EvaluateUnderwearTopVisibility(unequippedItem: ItemID) -> Bool {
    let i: Int32;
    let tagCounter: Int32;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let activeItem: ref<ItemObject> = transactionSystem.GetItemInSlotByItemID(this.m_owner, unequippedItem);
    if transactionSystem.MatchVisualTag(activeItem, n"hide_T1") || transactionSystem.HasItemInSlot(this.m_owner, t"AttachmentSlots.Chest", unequippedItem) {
      i = 0;
      while i < ArraySize(this.m_clothingSlotsInfo) {
        activeItem = transactionSystem.GetItemInSlot(this.m_owner, this.m_clothingSlotsInfo[i].equipSlot);
        if ItemID.IsValid(activeItem.GetItemID()) && (transactionSystem.MatchVisualTag(activeItem, n"hide_T1", true) || this.m_clothingSlotsInfo[i].equipSlot == t"AttachmentSlots.Chest") {
          tagCounter += 1;
        };
        i += 1;
      };
      activeItem = transactionSystem.GetItemInSlot(this.m_owner, t"AttachmentSlots.Outfit");
      if transactionSystem.MatchVisualTag(activeItem, n"hide_T1", true) {
        tagCounter += 1;
      };
      if tagCounter == 1 {
        return true;
      };
      return false;
    };
    return false;
  }

  private final func UnderwearEquipFailsafe() -> Void {
    let underwear: ItemID = ItemID.CreateQuery(t"Items.Underwear_Basic_01_Bottom");
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    if !ts.HasItem(this.m_owner, underwear) {
      ts.GiveItem(this.m_owner, underwear, 1);
    };
    if !ts.HasItemInSlot(this.m_owner, t"AttachmentSlots.UnderwearBottom", underwear) {
      this.EquipItem(underwear, false, false, false);
    };
  }

  private final func UnderwearTopEquipFailsafe() -> Void {
    let underwear: ItemID = ItemID.CreateQuery(t"Items.Underwear_Basic_01_Top");
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    if !ts.HasItem(this.m_owner, underwear) {
      ts.GiveItem(this.m_owner, underwear, 1);
    };
    if !ts.HasItemInSlot(this.m_owner, t"AttachmentSlots.UnderwearTop", underwear) {
      this.EquipItem(underwear, false, false, false);
    };
  }

  private final func GetHighestPriorityMovementAudio() -> CName {
    let j: Int32;
    let maxPriority: Float;
    let priority: Float;
    let soundName: CName;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      j = 0;
      while j < ArraySize(this.m_equipment.equipAreas[i].equipSlots) {
        priority = RPGManager.GetItemRecord(this.m_equipment.equipAreas[i].equipSlots[j].itemID).MovementSound().Priority();
        if priority > maxPriority {
          maxPriority = priority;
          soundName = RPGManager.GetItemRecord(this.m_equipment.equipAreas[i].equipSlots[j].itemID).MovementSound().AudioMovementName();
        };
        j += 1;
      };
      i += 1;
    };
    return soundName;
  }

  private final const func IsItemAWeapon(item: ItemID) -> Bool {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    return Equals(record.ItemCategory().Type(), gamedataItemCategory.Weapon);
  }

  private final const func IsItemOfCategory(item: ItemID, category: gamedataItemCategory) -> Bool {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    if IsDefined(record) && IsDefined(record.ItemCategory()) {
      return Equals(record.ItemCategory().Type(), category);
    };
    return false;
  }

  private final const func IsItemConstructed(item: ItemID) -> Bool {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    let blueprint: ref<ItemBlueprint_Record> = record.Blueprint();
    return TDBID.IsValid(blueprint.GetID());
  }

  public final const func IsEquippable(itemData: wref<gameItemData>) -> Bool {
    let itemLevel: Float;
    let ownerLevel: Float;
    let statsSys: ref<StatsSystem>;
    if itemData == null {
      return false;
    };
    statsSys = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    ownerLevel = statsSys.GetStatValue(Cast(this.m_owner.GetEntityID()), gamedataStatType.Level);
    itemLevel = Cast(FloorF(itemData.GetStatValueByType(gamedataStatType.Level)));
    if !this.CheckEquipPrereqs(itemData.GetID()) {
      return false;
    };
    if RPGManager.IsItemBroken(itemData) {
      return false;
    };
    return ownerLevel >= itemLevel;
  }

  public final const func IsItemInHotkey(itemID: ItemID) -> Bool {
    return HotkeyManager.IsItemInHotkey(this.m_hotkeys, itemID);
  }

  public final const func GetHotkeyTypeForItemID(itemID: ItemID) -> EHotkey {
    return HotkeyManager.GetHotkeyTypeForItemID(this.m_owner, this.m_hotkeys, itemID);
  }

  public final const func GetHotkeyTypeFromItemID(itemID: ItemID) -> EHotkey {
    return HotkeyManager.GetHotkeyTypeFromItemID(this.m_hotkeys, itemID);
  }

  public final const func GetItemIDFromHotkey(hotkey: EHotkey) -> ItemID {
    return HotkeyManager.GetItemIDFromHotkey(this.m_hotkeys, hotkey);
  }

  private final const func CheckEquipPrereqs(itemID: ItemID) -> Bool {
    let i: Int32;
    let prereqs: array<wref<IPrereq_Record>>;
    let result: Bool;
    RPGManager.GetItemRecord(itemID).EquipPrereqs(prereqs);
    i = 0;
    while i < ArraySize(prereqs) {
      result = RPGManager.CheckPrereq(prereqs[i], this.m_owner);
      if !result {
        return false;
      };
      i += 1;
    };
    return true;
  }

  private final func AssignNextValidItemToHotkey(currentItem: ItemID) -> Bool {
    let i: Int32;
    let newHotkeyItem: ItemID;
    let sameTypeItems: array<ItemID>;
    let hotkey: EHotkey = this.GetHotkeyTypeFromItemID(currentItem);
    let currentItemType: gamedataItemType = RPGManager.GetItemType(currentItem);
    if Equals(currentItemType, gamedataItemType.Cyb_Launcher) {
      currentItemType = gamedataItemType.Gad_Grenade;
    };
    this.m_inventoryManager.GetPlayerItemsIDsByType(currentItemType, sameTypeItems);
    if ArraySize(sameTypeItems) > 0 {
      i = 0;
      while i < ArraySize(sameTypeItems) {
        if sameTypeItems[i] == currentItem {
          newHotkeyItem = this.GetNextItemInList(sameTypeItems, i);
          if ItemID.IsValid(newHotkeyItem) {
            this.AssignItemToHotkey(newHotkeyItem, hotkey);
            return true;
          };
        };
        i += 1;
      };
      this.AssignItemToHotkey(sameTypeItems[0], hotkey);
    } else {
      this.ClearItemFromHotkey(hotkey);
    };
    return false;
  }

  public final func OnHotkeyRefreshRequest(requst: ref<HotkeyRefreshRequest>) -> Void {
    let i: Int32;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    if !IsDefined(ts) {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_hotkeys) {
      if Equals(this.m_hotkeys[i].GetHotkey(), EHotkey.RB) || Equals(this.m_hotkeys[i].GetHotkey(), EHotkey.DPAD_UP) {
        if ts.HasItem(this.m_owner, this.m_hotkeys[i].GetItemID()) {
          this.SyncHotkeyData(this.m_hotkeys[i].GetHotkey());
        } else {
          this.AssignNextValidItemToHotkey(this.m_hotkeys[i].GetItemID());
        };
      };
      i += 1;
    };
  }

  public final func OnHotkeyAssignmentRequest(request: ref<HotkeyAssignmentRequest>) -> Void {
    this.AssignItemToHotkey(request.ItemID(), request.GetHotkey());
    if Equals(request.GetRequestType(), EHotkeyRequestType.Assign) {
      this.ProcessGadgetsTutorials(request.ItemID());
    };
  }

  public final func OnAssignHotkeyIfEmptySlot(request: ref<AssignHotkeyIfEmptySlot>) -> Void {
    let hotkey: EHotkey;
    if this.ShouldPickedUpItemBeAddedToHotkey(request.ItemID(), hotkey) {
      this.AssignItemToHotkey(request.ItemID(), hotkey);
    };
  }

  public final func AssignItemToHotkey(newID: ItemID, hotkey: EHotkey) -> Void {
    let transactionSystem: ref<TransactionSystem>;
    if NotEquals(hotkey, EHotkey.INVALID) {
      if newID != this.m_hotkeys[EnumInt(hotkey)].GetItemID() {
        transactionSystem = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
        transactionSystem.OnItemRemovedFromEquipmentSlot(this.m_owner, this.m_hotkeys[EnumInt(hotkey)].GetItemID());
        transactionSystem.OnItemAddedToEquipmentSlot(this.m_owner, newID);
        this.m_hotkeys[EnumInt(hotkey)].StoreItem(newID);
        this.SyncHotkeyData(hotkey);
      };
    };
  }

  public final func ClearItemFromHotkey(hotkey: EHotkey) -> Void {
    if NotEquals(hotkey, EHotkey.INVALID) {
      this.m_hotkeys[EnumInt(hotkey)].StoreItem(ItemID.undefined());
      this.SyncHotkeyData(hotkey);
    };
  }

  private final func SyncHotkeyData(hotkey: EHotkey) -> Void {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_Hotkeys);
    if !IsDefined(blackboard) {
      return;
    };
    blackboard.SetVariant(GetAllBlackboardDefs().UI_Hotkeys.ModifiedHotkey, ToVariant(hotkey), true);
  }

  private final const func ShouldPickedUpItemBeAddedToHotkey(itemID: ItemID, out hotkey: EHotkey) -> Bool {
    let type: gamedataItemType = RPGManager.GetItemType(itemID);
    let i: Int32 = 0;
    while i < ArraySize(this.m_hotkeys) {
      if this.m_hotkeys[i].IsEmpty() && this.m_hotkeys[i].IsCompatible(type) {
        hotkey = this.m_hotkeys[i].GetHotkey();
        return true;
      };
      i += 1;
    };
    hotkey = EHotkey.INVALID;
    return false;
  }

  private final func GetNextItemInList(arr: array<ItemID>, fromIndex: Int32) -> ItemID {
    if fromIndex > ArraySize(arr) - 1 || fromIndex < 0 {
      return ItemID.undefined();
    };
    if fromIndex == ArraySize(arr) - 1 {
      return arr[0];
    };
    return arr[fromIndex + 1];
  }

  private final func UnequipItem(itemID: ItemID) -> Void {
    let audioEventFoley: ref<AudioEvent>;
    let equipAreaIndex: Int32;
    Log(" UnequipItem " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)));
    if this.IsEquipped(itemID) {
      equipAreaIndex = this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaType(itemID));
      this.UnequipItem(equipAreaIndex, this.GetSlotIndex(itemID));
      audioEventFoley = new AudioEvent();
      audioEventFoley.eventName = n"unequipItem";
      audioEventFoley.nameData = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).AppearanceName();
      this.m_owner.QueueEvent(audioEventFoley);
    };
  }

  private final func UnequipItem(equipAreaIndex: Int32, opt slotIndex: Int32) -> Void {
    let audioEventFoley: ref<AudioEvent>;
    let audioEventFootwear: ref<AudioEvent>;
    let currentItem: ItemID;
    let currentItemRecord: ref<Item_Record>;
    let equipArea: SEquipArea;
    let itemData: ref<gameItemData>;
    let paperdollEquipData: SPaperdollEquipData;
    let placementSlot: TweakDBID;
    let transactionSystem: ref<TransactionSystem>;
    let unequipNotifyEvent: ref<AudioNotifyItemUnequippedEvent>;
    Log(" UnequipItem " + IntToString(equipAreaIndex) + " " + IntToString(slotIndex));
    currentItem = this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
    equipArea = this.GetEquipAreaFromItemID(currentItem);
    currentItemRecord = RPGManager.GetItemRecord(currentItem);
    transactionSystem = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    itemData = RPGManager.GetItemData(this.m_owner.GetGame(), this.m_owner, currentItem);
    if IsDefined(itemData) && itemData.HasTag(n"UnequipBlocked") {
      return;
    };
    if this.IsItemOfCategory(currentItem, gamedataItemCategory.Weapon) && equipArea.activeIndex == slotIndex {
      if currentItem != this.GetActiveHeavyWeapon() {
        this.CreateUnequipWeaponManipulationRequest();
      };
      placementSlot = this.GetPlacementSlot(equipAreaIndex, slotIndex);
      this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID = ItemID.undefined();
    } else {
      if (this.IsItemOfCategory(currentItem, gamedataItemCategory.Gadget) || Equals(RPGManager.GetItemType(currentItem), gamedataItemType.Cyb_Launcher)) && equipArea.activeIndex == slotIndex {
        this.CreateUnequipGadgetWeaponManipulationRequest();
        this.AssignNextValidItemToHotkey(this.GetItemIDFromHotkey(EHotkey.RB));
      } else {
        if this.IsItemOfCategory(currentItem, gamedataItemCategory.Consumable) && equipArea.activeIndex == slotIndex {
          this.CreateUnequipConsumableWeaponManipulationRequest();
          this.AssignNextValidItemToHotkey(this.GetItemIDFromHotkey(EHotkey.DPAD_UP));
        } else {
          if ItemID.IsValid(currentItem) {
            placementSlot = this.GetPlacementSlot(equipAreaIndex, slotIndex);
            this.OnUnequipProcessVisualTags(currentItem, true);
            if transactionSystem.HasItemInSlot(this.m_owner, placementSlot, currentItem) {
              unequipNotifyEvent = new AudioNotifyItemUnequippedEvent();
              unequipNotifyEvent.itemName = currentItemRecord.EntityName();
              this.m_owner.QueueEvent(unequipNotifyEvent);
              transactionSystem.RemoveItemFromSlot(this.m_owner, placementSlot);
            };
            this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID = ItemID.undefined();
            this.RemoveEquipGLPs(currentItem);
            audioEventFoley = new AudioEvent();
            audioEventFoley.eventName = n"unequipItem";
            audioEventFoley.nameData = currentItemRecord.AppearanceName();
            this.m_owner.QueueEvent(audioEventFoley);
            if Equals(currentItemRecord.ItemType().Type(), gamedataItemType.Clo_Feet) {
              audioEventFootwear = new AudioEvent();
              audioEventFootwear.eventName = n"equipFootwear";
              audioEventFootwear.nameData = n"";
              this.m_owner.QueueEvent(audioEventFootwear);
            };
            if this.IsItemOfCategory(currentItem, gamedataItemCategory.Cyberware) && this.IsItemConstructed(currentItem) {
              this.ManageCyberwareFragments(currentItem);
            };
          };
        };
      };
    };
    if ItemID.IsValid(currentItem) && Equals(RPGManager.GetItemRecord(currentItem).ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
      this.HandleStrongArmsUnequip();
    };
    paperdollEquipData.equipArea = this.m_equipment.equipAreas[equipAreaIndex];
    paperdollEquipData.equipped = false;
    paperdollEquipData.placementSlot = placementSlot;
    paperdollEquipData.slotIndex = slotIndex;
    this.UpdateWeaponWheel();
    this.UpdateQuickWheel();
    this.UpdateEquipmentUIBB(paperdollEquipData);
    transactionSystem.OnItemRemovedFromEquipmentSlot(this.m_owner, currentItem);
  }

  private final func ClearEquipment() -> Void {
    let equipArea: SEquipArea;
    let j: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      equipArea = this.m_equipment.equipAreas[i];
      if NotEquals(equipArea.areaType, gamedataEquipmentArea.BaseFists) && NotEquals(equipArea.areaType, gamedataEquipmentArea.VDefaultHandgun) {
        j = 0;
        while j < ArraySize(equipArea.equipSlots) {
          this.UnequipItem(i, j);
          j += 1;
        };
      };
      i += 1;
    };
  }

  private final func HandleStrongArmsEquip(strongArmsID: ItemID) -> Void {
    this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.BaseFists)].equipSlots[0].itemID = strongArmsID;
    GameInstance.GetTransactionSystem(this.m_owner.GetGame()).RemoveItem(this.m_owner, this.GetBaseFistsItemID(), 1);
  }

  private final func ManageCyberwareFragments(itemID: ItemID) -> Void {
    let i: Int32;
    let usedSlots: array<TweakDBID>;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    TS.GetUsedSlotsOnItem(this.m_owner, itemID, usedSlots);
    i = 0;
    while i < ArraySize(usedSlots) {
      TS.RemovePart(this.m_owner, itemID, usedSlots[i]);
      i += 1;
    };
  }

  private final func HandleStrongArmsUnequip() -> Void {
    this.EquipBaseFists();
  }

  private final func EquipBaseFists() -> ItemID {
    let baseFistsID: ItemID = this.GetBaseFistsItemID();
    let fistsData: wref<gameItemData> = GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemData(this.m_owner, baseFistsID);
    if IsDefined(fistsData) {
      baseFistsID = fistsData.GetID();
    } else {
      GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GiveItem(this.m_owner, baseFistsID, 1);
    };
    this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.BaseFists)].equipSlots[0].itemID = baseFistsID;
    return baseFistsID;
  }

  private final func ApplyEquipGLPs(itemID: ItemID) -> Void {
    let glpSys: ref<GameplayLogicPackageSystem>;
    let i: Int32;
    let itemData: wref<gameItemData>;
    let itemParts: array<InnerItemData>;
    let j: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    itemRecord.OnEquip(packages);
    glpSys = GameInstance.GetGameplayLogicPackageSystem(this.m_owner.GetGame());
    itemData = GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemData(this.m_owner, itemID);
    i = 0;
    while i < ArraySize(packages) {
      glpSys.ApplyPackage(this.m_owner, this.m_owner, packages[i].GetID());
      i += 1;
    };
    ArrayClear(packages);
    itemData.GetItemParts(itemParts);
    i = 0;
    while i < ArraySize(itemParts) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InnerItemData.GetItemID(itemParts[i])));
      itemRecord.OnEquip(packages);
      j = 0;
      while j < ArraySize(packages) {
        glpSys.ApplyPackage(this.m_owner, this.m_owner, packages[j].GetID());
        j += 1;
      };
      ArrayClear(packages);
      i += 1;
    };
  }

  private final func RemoveEquipGLPs(itemID: ItemID) -> Void {
    let glpSys: ref<GameplayLogicPackageSystem>;
    let i: Int32;
    let itemData: wref<gameItemData>;
    let itemParts: array<InnerItemData>;
    let j: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    itemRecord.OnEquip(packages);
    glpSys = GameInstance.GetGameplayLogicPackageSystem(this.m_owner.GetGame());
    i = 0;
    while i < ArraySize(packages) {
      glpSys.RemovePackage(this.m_owner, packages[i].GetID());
      i += 1;
    };
    itemData = GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemData(this.m_owner, itemID);
    if IsDefined(itemData) {
      itemData.GetItemParts(itemParts);
    };
    i = 0;
    while i < ArraySize(itemParts) {
      ArrayClear(packages);
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InnerItemData.GetItemID(itemParts[i])));
      if IsDefined(itemRecord) {
        itemRecord.OnEquip(packages);
      };
      j = 0;
      while j < ArraySize(packages) {
        glpSys.RemovePackage(this.m_owner, packages[j].GetID());
        j += 1;
      };
      i += 1;
    };
  }

  public final func GetLastUsedItemID(type: ELastUsed) -> ItemID {
    let lastUsedStruct: SLastUsedWeapon = this.GetLastUsedStruct();
    switch type {
      case ELastUsed.Melee:
        return lastUsedStruct.lastUsedMelee;
      case ELastUsed.Ranged:
        return lastUsedStruct.lastUsedRanged;
      case ELastUsed.Weapon:
        return lastUsedStruct.lastUsedWeapon;
      case ELastUsed.Heavy:
        return lastUsedStruct.lastUsedHeavy;
      default:
        return ItemID.undefined();
    };
  }

  private final func SetLastUsedItem(item: ItemID) -> Void {
    let lastUsedStruct: SLastUsedWeapon = this.GetLastUsedStruct();
    let tags: array<CName> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).Tags();
    if ArrayContains(tags, WeaponObject.GetRangedWeaponTag()) {
      if ArrayContains(tags, n"HeavyWeapon") {
        lastUsedStruct.lastUsedHeavy = item;
      } else {
        lastUsedStruct.lastUsedRanged = item;
        lastUsedStruct.lastUsedWeapon = item;
        lastUsedStruct.lastUsedHeavy = ItemID.undefined();
      };
    } else {
      if ArrayContains(tags, WeaponObject.GetMeleeWeaponTag()) {
        lastUsedStruct.lastUsedMelee = item;
        lastUsedStruct.lastUsedWeapon = item;
        lastUsedStruct.lastUsedHeavy = ItemID.undefined();
      } else {
        return;
      };
    };
    this.m_lastUsedStruct = lastUsedStruct;
  }

  private final func SetSlotActiveItem(slot: EquipmentManipulationRequestSlot, item: ItemID) -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.m_owner.GetGame()).CreateSink();
    let slotItems: SSlotActiveItems = this.GetSlotActiveItemStruct();
    switch slot {
      case EquipmentManipulationRequestSlot.Left:
        this.m_slotActiveItemsInHands.leftHandItem = item;
        break;
      case EquipmentManipulationRequestSlot.Right:
        this.m_slotActiveItemsInHands.rightHandItem = item;
        break;
      case EquipmentManipulationRequestSlot.Both:
        this.m_slotActiveItemsInHands.leftHandItem = item;
        this.m_slotActiveItemsInHands.rightHandItem = item;
    };
    SDOSink.SetRoot(sink, EquipmentSystem.ComposeSDORootPath(this.GetOwner(), "Slot active items"));
    SDOSink.PushString(sink, "Left hand", ToString(slotItems.leftHandItem));
    SDOSink.PushString(sink, "Right hand", ToString(slotItems.rightHandItem));
  }

  public final func GetSlotActiveItem(slot: EquipmentManipulationRequestSlot) -> ItemID {
    let slotsStruct: SSlotActiveItems = this.GetSlotActiveItemStruct();
    switch slot {
      case EquipmentManipulationRequestSlot.Left:
        return slotsStruct.leftHandItem;
      case EquipmentManipulationRequestSlot.Right:
        return slotsStruct.rightHandItem;
      default:
        return ItemID.undefined();
    };
  }

  public final func RemoveItemFromSlotActiveItem(item: ItemID) -> Void {
    let slotsStruct: SSlotActiveItems = this.GetSlotActiveItemStruct();
    if ItemID.GetTDBID(slotsStruct.rightHandItem) == ItemID.GetTDBID(item) {
      this.m_slotActiveItemsInHands.rightHandItem = ItemID.undefined();
    };
    if ItemID.GetTDBID(slotsStruct.leftHandItem) == ItemID.GetTDBID(item) {
      this.m_slotActiveItemsInHands.leftHandItem = ItemID.undefined();
    };
  }

  private final func DrawItem(itemToDraw: ItemID, drawAnimationType: gameEquipAnimationType) -> Void {
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaType(itemToDraw));
    let slotIndex: Int32 = this.GetSlotIndex(itemToDraw);
    let request: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    let equipArea: SEquipArea = this.m_equipment.equipAreas[equipAreaIndex];
    request.requestType = EquipmentManipulationAction.Undefined;
    request.equipAnimType = drawAnimationType;
    if slotIndex == -1 {
      this.EquipItem(itemToDraw, false, false, false);
      slotIndex = this.GetSlotIndex(itemToDraw);
    };
    if slotIndex >= 0 && slotIndex < ArraySize(equipArea.equipSlots) {
      this.m_equipment.equipAreas[equipAreaIndex].activeIndex = slotIndex;
      this.UpdateActiveWheelItem(this.GetItemInEquipSlot(equipAreaIndex, slotIndex));
      switch equipArea.areaType {
        case gamedataEquipmentArea.VDefaultHandgun:
        case gamedataEquipmentArea.ArmsCW:
        case gamedataEquipmentArea.BaseFists:
        case gamedataEquipmentArea.Weapon:
          request.requestType = EquipmentManipulationAction.RequestSlotActiveWeapon;
          if this.CheckWeaponAgainstGameplayRestrictions(itemToDraw) {
            this.SetSlotActiveItem(EquipmentManipulationRequestSlot.Right, itemToDraw);
          };
          this.UpdateEquipAreaActiveIndex(itemToDraw);
          this.SetLastUsedItem(itemToDraw);
          break;
        case gamedataEquipmentArea.WeaponHeavy:
          if this.CheckWeaponAgainstGameplayRestrictions(itemToDraw) {
            this.SetSlotActiveItem(EquipmentManipulationRequestSlot.Right, itemToDraw);
          };
          this.UpdateEquipAreaActiveIndex(itemToDraw);
          this.SetLastUsedItem(itemToDraw);
          request.requestType = EquipmentManipulationAction.RequestHeavyWeapon;
      };
      if NotEquals(request.requestType, EquipmentManipulationAction.Undefined) {
        this.OnEquipmentSystemWeaponManipulationRequest(request);
      };
    };
  }

  public final static func UpdateArmSlot(owner: wref<PlayerPuppet>, itemToDraw: ItemID, opt unequip: Bool) -> Void {
    let TS: ref<TransactionSystem>;
    let equipmentSystemData: ref<EquipmentSystemPlayerData>;
    let holsteredArms: ItemID;
    let itemTags: array<CName>;
    let record: ref<WeaponItem_Record>;
    let slotID: TweakDBID;
    if !IsDefined(owner) {
      return;
    };
    record = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(itemToDraw));
    if !IsDefined(record) {
      return;
    };
    if !IsDefined(record.HolsteredItem()) {
      return;
    };
    equipmentSystemData = EquipmentSystem.GetData(owner);
    if !IsDefined(equipmentSystemData) {
      return;
    };
    holsteredArms = ItemID.CreateQuery(record.HolsteredItem().GetID());
    if !ItemID.IsValid(holsteredArms) {
      return;
    };
    TS = GameInstance.GetTransactionSystem(owner.GetGame());
    itemTags = record.Tags();
    slotID = t"AttachmentSlots.RightArm";
    if ArrayContains(itemTags, n"base_fists") {
      if EquipmentSystem.HasItemInArea(owner, gamedataEquipmentArea.ArmsCW) {
        if !unequip && TS.IsSlotEmpty(owner, slotID) {
          if !TS.HasItem(owner, holsteredArms) {
            TS.GiveItem(owner, holsteredArms, 1);
          };
          equipmentSystemData.EquipItem(holsteredArms, false, false, false);
        };
      } else {
        if !TS.HasItem(owner, holsteredArms) {
          TS.GiveItem(owner, holsteredArms, 1);
        };
        if !TS.HasItemInSlot(owner, slotID, holsteredArms) {
          equipmentSystemData.EquipItem(holsteredArms, false, false, false);
        };
      };
    } else {
      if unequip {
        if itemToDraw == equipmentSystemData.GetActiveItem(gamedataEquipmentArea.ArmsCW) {
          if !TS.HasItem(owner, holsteredArms) {
            TS.GiveItem(owner, holsteredArms, 1);
          };
          if !TS.HasItemInSlot(owner, slotID, holsteredArms) {
            equipmentSystemData.EquipItem(holsteredArms, false, false, false);
          };
        };
      } else {
        TS.RemoveItemFromSlot(owner, slotID);
      };
    };
  }

  private final func SaveEquipmentSet(setName: String, setType: EEquipmentSetType) -> Void {
    let areasToSave: array<gamedataEquipmentArea>;
    let equipmentSet: SEquipmentSet;
    let i: Int32;
    let itemInfo: SItemInfo;
    let j: Int32;
    equipmentSet.setName = StringToName(setName);
    switch setType {
      case EEquipmentSetType.Offensive:
        ArrayPush(areasToSave, gamedataEquipmentArea.Weapon);
        ArrayPush(areasToSave, gamedataEquipmentArea.QuickSlot);
        ArrayPush(areasToSave, gamedataEquipmentArea.Consumable);
        ArrayPush(areasToSave, gamedataEquipmentArea.Gadget);
        break;
      case EEquipmentSetType.Defensive:
        break;
      case EEquipmentSetType.Cyberware:
        ArrayPush(areasToSave, gamedataEquipmentArea.ArmsCW);
      default:
    };
    i = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      if ArrayContains(areasToSave, this.m_equipment.equipAreas[i].areaType) {
        j = 0;
        while j < ArraySize(this.m_equipment.equipAreas[i].equipSlots) {
          itemInfo.itemID = this.m_equipment.equipAreas[i].equipSlots[j].itemID;
          itemInfo.slotIndex = j;
          ArrayPush(equipmentSet.setItems, itemInfo);
          j += 1;
        };
      };
      i += 1;
    };
    if ArraySize(equipmentSet.setItems) > 0 {
      ArrayPush(this.m_equipment.equipmentSets, equipmentSet);
    };
  }

  private final func LoadEquipmentSet(setName: String) -> Void {
    let equipmentSet: SEquipmentSet;
    let itemToEquip: ItemID;
    let j: Int32;
    let slotIndex: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipmentSets) {
      equipmentSet = this.m_equipment.equipmentSets[i];
      if Equals(equipmentSet.setName, StringToName(setName)) {
        j = 0;
        while j < ArraySize(equipmentSet.setItems) {
          itemToEquip = equipmentSet.setItems[j].itemID;
          slotIndex = equipmentSet.setItems[j].slotIndex;
          if GameInstance.GetTransactionSystem(this.m_owner.GetGame()).HasItem(this.m_owner, itemToEquip) {
            this.EquipItem(itemToEquip, slotIndex, false);
          };
          j += 1;
        };
        return;
      };
      i += 1;
    };
    this.ClearLastUsedStruct();
  }

  private final func DeleteEquipmentSet(setName: String) -> Void {
    let equipmentSet: SEquipmentSet;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipmentSets) {
      equipmentSet = this.m_equipment.equipmentSets[i];
      if Equals(equipmentSet.setName, StringToName(setName)) {
        ArrayErase(this.m_equipment.equipmentSets, i);
      };
      i += 1;
    };
  }

  private final const func GetEquipAreaIndex(equipAreaID: TweakDBID) -> Int32 {
    let areaType: gamedataEquipmentArea;
    let i: Int32;
    if TDBID.IsValid(equipAreaID) {
      areaType = TweakDBInterface.GetEquipmentAreaRecord(equipAreaID).Type();
      i = 0;
      while i < ArraySize(this.m_equipment.equipAreas) {
        if Equals(this.m_equipment.equipAreas[i].areaType, areaType) {
          return i;
        };
        i += 1;
      };
    };
    return -1;
  }

  private final const func GetEquipAreaIndex(areaType: gamedataEquipmentArea) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      if Equals(this.m_equipment.equipAreas[i].areaType, areaType) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetEquipArea(areaType: gamedataEquipmentArea) -> SEquipArea {
    let emptyArea: SEquipArea;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      if Equals(this.m_equipment.equipAreas[i].areaType, areaType) {
        return this.m_equipment.equipAreas[i];
      };
      i += 1;
    };
    return emptyArea;
  }

  public final const func GetActiveItemID(equipAreaIndex: Int32) -> ItemID {
    let activeIndex: Int32 = this.m_equipment.equipAreas[equipAreaIndex].activeIndex;
    let activeItem: ItemID = this.GetItemInEquipSlot(equipAreaIndex, activeIndex);
    if activeItem == ItemID.undefined() {
      activeIndex = this.GetNextActiveItemIndex(equipAreaIndex);
      this.m_equipment.equipAreas[equipAreaIndex].activeIndex = activeIndex;
      activeItem = this.GetItemInEquipSlot(equipAreaIndex, activeIndex);
    };
    return activeItem;
  }

  public final const func GetEquipAreaFromItemID(item: ItemID) -> SEquipArea {
    let voidEmptyArea: SEquipArea;
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaType(item));
    if equipAreaIndex != -1 {
      return this.m_equipment.equipAreas[equipAreaIndex];
    };
    return voidEmptyArea;
  }

  private final const func GetItemInEquipSlot(equipAreaIndex: Int32, slotIndex: Int32) -> ItemID {
    return this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
  }

  private final const func GetNextActiveItemIndex(equipAreaIndex: Int32) -> Int32 {
    let requiredTags: array<CName>;
    return this.GetNextActiveItemIndex(equipAreaIndex, requiredTags);
  }

  private final const func GetNextActiveItemIndex(equipAreaIndex: Int32, requiredTags: array<CName>) -> Int32 {
    let checkIndex: Int32;
    let equipArea: SEquipArea = this.m_equipment.equipAreas[equipAreaIndex];
    let numSlots: Int32 = ArraySize(equipArea.equipSlots);
    let nextIndex: Int32 = (this.m_equipment.equipAreas[equipAreaIndex].activeIndex + 1) % numSlots;
    let i: Int32 = 0;
    while i < numSlots {
      checkIndex = (nextIndex + i) % numSlots;
      if ItemID.IsValid(equipArea.equipSlots[checkIndex].itemID) && this.CheckTagsInItem(equipArea.equipSlots[checkIndex].itemID, requiredTags) {
        return checkIndex;
      };
      i += 1;
    };
    return 0;
  }

  private final const func CheckTagsInItem(itemID: ItemID, requiredTags: array<CName>) -> Bool {
    let itemTags: array<CName>;
    let tagNo: Int32;
    if ArraySize(requiredTags) > 0 {
      itemTags = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).Tags();
      tagNo = 0;
      while tagNo < ArraySize(requiredTags) {
        if !ArrayContains(itemTags, requiredTags[tagNo]) {
          return false;
        };
        tagNo += 1;
      };
    };
    return true;
  }

  private final const func GetPlacementSlot(equipAreaIndex: Int32, slotIndex: Int32) -> TweakDBID {
    return EquipmentSystem.GetPlacementSlot(this.GetItemInEquipSlot(equipAreaIndex, slotIndex));
  }

  private final const func HasItemInInventory(item: ItemID) -> Bool {
    return GameInstance.GetTransactionSystem(this.m_owner.GetGame()).HasItem(this.m_owner, item);
  }

  private final const func HasItemEquipped(equipAreaIndex: Int32, opt slotIndex: Int32) -> Bool {
    return ItemID.IsValid(this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID);
  }

  public final const func GetSlotIndex(itemID: ItemID) -> Int32 {
    let equipAreaType: gamedataEquipmentArea;
    let equipSlots: array<SEquipSlot>;
    let i: Int32;
    let j: Int32;
    if ItemID.IsValid(itemID) {
      equipAreaType = EquipmentSystem.GetEquipAreaType(itemID);
      i = this.GetEquipAreaIndex(equipAreaType);
      if i >= 0 {
        equipSlots = this.m_equipment.equipAreas[i].equipSlots;
        j = 0;
        while j < ArraySize(equipSlots) {
          if equipSlots[j].itemID == itemID {
            Log(" GetSlotIndex " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)) + " result " + j);
            return j;
          };
          j += 1;
        };
      };
    };
    Log(" GetSlotIndex " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)) + " result not found");
    return -1;
  }

  public final const func GetSlotIndex(itemID: ItemID, equipAreaType: gamedataEquipmentArea) -> Int32 {
    let equipSlots: array<SEquipSlot>;
    let i: Int32;
    let j: Int32;
    if ItemID.IsValid(itemID) {
      i = this.GetEquipAreaIndex(equipAreaType);
      if i >= 0 {
        equipSlots = this.m_equipment.equipAreas[i].equipSlots;
        j = 0;
        while j < ArraySize(equipSlots) {
          if equipSlots[j].itemID == itemID {
            Log(" GetSlotIndex " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)) + " result " + j);
            return j;
          };
          j += 1;
        };
      };
    };
    Log(" GetSlotIndex " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)) + " result not found");
    return -1;
  }

  private final const func GetOwnerGender() -> CName {
    return this.m_owner.GetResolvedGenderName();
  }

  private final const func GetItemAppearanceForGender(itemID: ItemID) -> CName {
    let appearanceName: CName;
    let gender: CName = this.GetOwnerGender();
    if Equals(gender, n"Female") {
      appearanceName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).AppearanceName();
    } else {
      appearanceName = TweakDBInterface.GetCName(ItemID.GetTDBID(itemID) + t".appearanceNameMale", n"");
    };
    return appearanceName;
  }

  public final const func GetItemInEquipSlot(areaType: gamedataEquipmentArea, slotIndex: Int32) -> ItemID {
    return this.m_equipment.equipAreas[this.GetEquipAreaIndex(areaType)].equipSlots[slotIndex].itemID;
  }

  public final const func GetNumberOfSlots(areaType: gamedataEquipmentArea) -> Int32 {
    return ArraySize(this.m_equipment.equipAreas[this.GetEquipAreaIndex(areaType)].equipSlots);
  }

  public final const func GetNumberOfItemsInEquipmentArea(areaType: gamedataEquipmentArea) -> Int32 {
    let items: Int32;
    let equipArea: SEquipArea = this.m_equipment.equipAreas[this.GetEquipAreaIndex(areaType)];
    let i: Int32 = 0;
    while i < ArraySize(equipArea.equipSlots) {
      if ItemID.IsValid(equipArea.equipSlots[i].itemID) {
        items += 1;
      };
      i += 1;
    };
    return items;
  }

  public final const func GetNumberEquippedWeapons() -> Int32 {
    let numWeaponsEquipped: Int32 = 0;
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(gamedataEquipmentArea.WeaponWheel);
    let equipArea: SEquipArea = this.m_equipment.equipAreas[equipAreaIndex];
    let i: Int32 = 0;
    while i < ArraySize(equipArea.equipSlots) {
      if this.HasItemEquipped(equipAreaIndex, i) {
        numWeaponsEquipped += 1;
      };
      i += 1;
    };
    return numWeaponsEquipped;
  }

  public final const func GetEquippedQuestItems() -> array<ItemID> {
    let itemData: wref<gameItemData>;
    let itemID: ItemID;
    let j: Int32;
    let questItems: array<ItemID>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      j = 0;
      while j < ArraySize(this.m_equipment.equipAreas[i].equipSlots) {
        itemID = this.m_equipment.equipAreas[i].equipSlots[j].itemID;
        if ItemID.IsValid(itemID) {
          itemData = GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemData(this.m_owner, itemID);
          if itemData.HasTag(n"Quest") {
            ArrayPush(questItems, itemID);
          };
        };
        j += 1;
      };
      i += 1;
    };
    return questItems;
  }

  public final const func GetActiveItem(equipArea: gamedataEquipmentArea) -> ItemID {
    return this.GetActiveItemID(this.GetEquipAreaIndex(equipArea));
  }

  public final const func GetActiveWeaponObject(equipArea: gamedataEquipmentArea) -> ref<ItemObject> {
    let itemID: ItemID = this.GetActiveItem(equipArea);
    return GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemInSlotByItemID(this.m_owner, itemID);
  }

  public final const func GetNextActiveItem(equipArea: gamedataEquipmentArea) -> ItemID {
    return this.GetItemInEquipSlot(equipArea, this.GetNextActiveItemIndex(this.GetEquipAreaIndex(equipArea)));
  }

  public final const func GetActiveConsumable() -> ItemID {
    let consumable: ItemID;
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    let containerConsumable: ItemID = FromVariant(blackboard.GetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.containerConsumable));
    if ItemID.IsValid(containerConsumable) {
      return containerConsumable;
    };
    consumable = this.GetItemIDFromHotkey(EHotkey.DPAD_UP);
    if ItemID.IsValid(consumable) {
      return consumable;
    };
    return ItemID.undefined();
  }

  public final const func GetNextWeaponWheelItem() -> ItemID {
    let requiredTags: array<CName>;
    let weaponWheelEquipArea: gamedataEquipmentArea = gamedataEquipmentArea.WeaponWheel;
    if IsMultiplayer() || GameInstance.GetPlayerSystem(this.m_owner.GetGame()).IsCPOControlSchemeForced() {
      ArrayPush(requiredTags, WeaponObject.GetRangedWeaponTag());
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"OneHandedFirearms") {
      ArrayPush(requiredTags, WeaponObject.GetOneHandedRangedWeaponTag());
    };
    return this.GetItemInEquipSlot(weaponWheelEquipArea, this.GetNextActiveItemIndex(this.GetEquipAreaIndex(weaponWheelEquipArea), requiredTags));
  }

  public final const func GetActiveHeavyWeapon() -> ItemID {
    return this.GetActiveItem(gamedataEquipmentArea.WeaponHeavy);
  }

  public final const func GetActiveGadget() -> ItemID {
    let gadget: ItemID = this.GetItemIDFromHotkey(EHotkey.RB);
    if ItemID.IsValid(gadget) {
      return gadget;
    };
    return ItemID.undefined();
  }

  public final const func GetActiveCyberware() -> ItemID {
    let equipArea: SEquipArea;
    let i: Int32;
    let moduleID: ItemID;
    let moduleRecord: ref<Item_Record>;
    if Equals(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.GetItemIDFromHotkey(EHotkey.RB))).ItemType().Type(), gamedataItemType.Cyb_Launcher) {
      return this.GetItemIDFromHotkey(EHotkey.RB);
    };
    equipArea = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.ArmsCW)];
    i = 0;
    while i < this.GetNumberOfSlots(gamedataEquipmentArea.ArmsCW) {
      moduleID = equipArea.equipSlots[i].itemID;
      if ItemID.IsValid(moduleID) {
        moduleRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(moduleID));
        if Equals(moduleRecord.ItemType().Type(), gamedataItemType.Cyb_Launcher) {
          return moduleID;
        };
      } else {
        moduleID = this.GetActiveGadget();
        if ItemID.IsValid(moduleID) {
          moduleRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(moduleID));
          if Equals(moduleRecord.ItemType().Type(), gamedataItemType.Cyb_Ability) {
            return moduleID;
          };
        };
      };
      i += 1;
    };
    return ItemID.undefined();
  }

  public final const func GetAllAbilityCyberwareSlots() -> array<SEquipSlot> {
    let CyberwareID: ItemID;
    let CyberwareList: array<SEquipSlot>;
    let CyberwareRecord: ref<Item_Record>;
    let equipArea: SEquipArea = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.ArmsCW)];
    let i: Int32 = 0;
    while i < this.GetNumberOfSlots(gamedataEquipmentArea.ArmsCW) {
      CyberwareID = equipArea.equipSlots[i].itemID;
      if ItemID.IsValid(CyberwareID) {
        CyberwareRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(CyberwareID));
        if Equals(CyberwareRecord.ItemType().Type(), gamedataItemType.Cyb_Launcher) {
          ArrayPush(CyberwareList, equipArea.equipSlots[i]);
        };
      };
      i += 1;
    };
    equipArea = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.AbilityCW)];
    i = 0;
    while i < this.GetNumberOfSlots(gamedataEquipmentArea.AbilityCW) {
      CyberwareID = equipArea.equipSlots[i].itemID;
      if ItemID.IsValid(CyberwareID) {
        CyberwareRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(CyberwareID));
        if Equals(CyberwareRecord.ItemType().Type(), gamedataItemType.Cyb_Launcher) {
          ArrayPush(CyberwareList, equipArea.equipSlots[i]);
        };
      };
      i += 1;
    };
    return CyberwareList;
  }

  public final const func GetActiveMeleeWare() -> ItemID {
    let moduleID: ItemID;
    let moduleRecord: ref<Item_Record>;
    let equipArea: SEquipArea = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.ArmsCW)];
    let i: Int32 = 0;
    while i < this.GetNumberOfSlots(gamedataEquipmentArea.ArmsCW) {
      moduleID = equipArea.equipSlots[i].itemID;
      if ItemID.IsValid(moduleID) {
        moduleRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(moduleID));
        if Equals(moduleRecord.ItemCategory().Type(), gamedataItemCategory.Weapon) {
          return moduleID;
        };
      };
      i += 1;
    };
    return ItemID.undefined();
  }

  public final const func IsEquipped(item: ItemID) -> Bool {
    Log(" IsEquipped " + TDBID.ToStringDEBUG(ItemID.GetTDBID(item)));
    return this.GetSlotIndex(item) >= 0;
  }

  public final const func IsEquipped(item: ItemID, equipmentArea: gamedataEquipmentArea) -> Bool {
    Log(" IsEquipped " + TDBID.ToStringDEBUG(ItemID.GetTDBID(item)));
    return this.GetSlotIndex(item, equipmentArea) >= 0;
  }

  public final const func PrintEquipment() -> Void {
    let activeString: String;
    let areaString: String;
    let equipArea: SEquipArea;
    let equipSlot: SEquipSlot;
    let itemRecord: ref<Item_Record>;
    let itemString: String;
    let j: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipment.equipAreas) {
      equipArea = this.m_equipment.equipAreas[i];
      areaString = EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(equipArea.areaType)));
      Log("\t" + areaString);
      j = 0;
      while j < ArraySize(equipArea.equipSlots) {
        activeString = "";
        if equipArea.activeIndex == j {
          activeString = " -- ACTIVE";
        };
        equipSlot = equipArea.equipSlots[j];
        if ItemID.IsValid(equipSlot.itemID) {
          itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(equipSlot.itemID));
          itemString = itemRecord.FriendlyName();
        } else {
          itemString = "EMPTY";
        };
        Log("\t\tSlot " + IntToString(j) + ": " + itemString + activeString);
        j += 1;
      };
      i += 1;
    };
  }

  public final func GetLastUsedWeaponItemID() -> ItemID {
    let item: ItemID = ItemID.undefined();
    let lastUsedWeaponID: ItemID = ItemID.undefined();
    item = this.FindItemInEqArea(this.GetLastUsedItemID(ELastUsed.Heavy), gamedataEquipmentArea.WeaponHeavy);
    if ItemID.IsValid(item) {
      return item;
    };
    lastUsedWeaponID = this.GetLastUsedItemID(ELastUsed.Weapon);
    item = this.FindItemInEqArea(lastUsedWeaponID, gamedataEquipmentArea.WeaponWheel);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqArea(lastUsedWeaponID, gamedataEquipmentArea.Weapon);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqArea(lastUsedWeaponID, gamedataEquipmentArea.ArmsCW);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqArea(lastUsedWeaponID, gamedataEquipmentArea.BaseFists);
    if ItemID.IsValid(item) {
      return item;
    };
    return item;
  }

  public final func GetActiveWeaponToUnequip() -> ItemID {
    let eqArea: SEquipArea = this.GetEquipAreaFromItemID(this.GetSlotActiveItem(EquipmentManipulationRequestSlot.Right));
    if Equals(eqArea.areaType, gamedataEquipmentArea.BaseFists) {
      return this.GetFistsItemID();
    };
    return this.GetActiveItem(eqArea.areaType);
  }

  public final func GetActiveWeapon() -> ItemID {
    return this.GetActiveItem(gamedataEquipmentArea.WeaponWheel);
  }

  public final func GetSlotActiveWeapon() -> ItemID {
    return this.GetSlotActiveItem(EquipmentManipulationRequestSlot.Right);
  }

  public final func GetFirstMeleeWeaponItemID() -> ItemID {
    let item: ItemID = ItemID.undefined();
    item = this.GetActiveMeleeWare();
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqAreaByTag(WeaponObject.GetMeleeWeaponTag(), gamedataEquipmentArea.Weapon);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.GetFistsItemID();
    if ItemID.IsValid(item) {
      return item;
    };
    return item;
  }

  public final func GetLastUsedMeleeWeaponItemID() -> ItemID {
    let item: ItemID = ItemID.undefined();
    let lastUsedWeaponID: ItemID = ItemID.undefined();
    lastUsedWeaponID = this.GetLastUsedItemID(ELastUsed.Melee);
    item = this.FindItemInEqArea(lastUsedWeaponID, gamedataEquipmentArea.WeaponWheel);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqArea(lastUsedWeaponID, gamedataEquipmentArea.ArmsCW);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqArea(lastUsedWeaponID, gamedataEquipmentArea.BaseFists);
    if ItemID.IsValid(item) {
      return item;
    };
    return item;
  }

  public final func GetLastUsedOrFirstAvailableWeapon() -> ItemID {
    let item: ItemID = ItemID.undefined();
    item = this.FindItemInEqArea(this.GetLastUsedItemID(ELastUsed.Weapon), gamedataEquipmentArea.WeaponWheel);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqArea(this.GetLastUsedItemID(ELastUsed.Heavy), gamedataEquipmentArea.WeaponHeavy);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqArea(this.GetLastUsedItemID(ELastUsed.Weapon), gamedataEquipmentArea.BaseFists);
    if ItemID.IsValid(item) {
      return item;
    };
    item = EquipmentSystem.GetFirstAvailableWeapon(this.m_owner);
    if ItemID.IsValid(item) {
      return item;
    };
    return item;
  }

  public final func GetLastUsedOrFirstAvailableRangedWeapon() -> ItemID {
    let item: ItemID = ItemID.undefined();
    item = this.FindItemInEqArea(this.GetLastUsedItemID(ELastUsed.Ranged), gamedataEquipmentArea.WeaponWheel);
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.FindItemInEqAreaByTag(WeaponObject.GetRangedWeaponTag(), gamedataEquipmentArea.Weapon);
    if ItemID.IsValid(item) {
      return item;
    };
    return item;
  }

  public final func GetLastUsedOrFirstAvailableMeleeWeapon() -> ItemID {
    let item: ItemID = ItemID.undefined();
    item = this.GetLastUsedMeleeWeaponItemID();
    if ItemID.IsValid(item) {
      return item;
    };
    item = this.GetFirstMeleeWeaponItemID();
    if ItemID.IsValid(item) {
      return item;
    };
    return item;
  }

  public final func GetLastUsedOrFirstAvailableOneHandedRangedWeapon() -> ItemID {
    let itemTags: array<CName>;
    let item: ItemID = ItemID.undefined();
    item = this.FindItemInEqArea(this.GetLastUsedItemID(ELastUsed.Ranged), gamedataEquipmentArea.WeaponWheel);
    if ItemID.IsValid(item) {
      itemTags = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).Tags();
      if ArrayContains(itemTags, WeaponObject.GetOneHandedRangedWeaponTag()) {
        return item;
      };
    };
    item = this.FindItemInEqAreaByTag(WeaponObject.GetOneHandedRangedWeaponTag(), gamedataEquipmentArea.Weapon);
    return item;
  }

  public final func GetWeaponSlotItem(weaponSlot: Int32) -> ItemID {
    let activeItem: ItemID;
    let requestedWeapon: ItemID;
    let equipArea: SEquipArea = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.WeaponWheel)];
    let item: ref<ItemObject> = GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemInSlot(this.m_owner, t"AttachmentSlots.WeaponRight");
    if IsDefined(item) {
      activeItem = item.GetItemID();
    };
    if weaponSlot == 4 {
      requestedWeapon = this.GetMeleewareOrFistsItemID();
    } else {
      requestedWeapon = equipArea.equipSlots[weaponSlot - 1].itemID;
    };
    if ItemID.IsValid(requestedWeapon) && requestedWeapon != activeItem && this.CheckWeaponAgainstGameplayRestrictions(requestedWeapon) {
      return requestedWeapon;
    };
    return ItemID.undefined();
  }

  public final func CycleWeapon(cycleNext: Bool, onlyCheck: Bool) -> ItemID {
    let i: Int32;
    let nextItem: ItemID;
    let x: Int32;
    let equipArea: SEquipArea = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.WeaponWheel)];
    let eqAreaSize: Int32 = ArraySize(equipArea.equipSlots);
    let activeItem: ItemID = this.GetLastUsedWeaponItemID();
    let currentItemSlot: Int32 = equipArea.activeIndex;
    let nextItemSlot: Int32 = currentItemSlot;
    let barebonesWeapon: ItemID = this.GetMeleewareOrFistsItemID();
    let direction: Int32 = cycleNext ? 1 : -1;
    if Equals(EquipmentSystem.GetEquipAreaType(activeItem), gamedataEquipmentArea.WeaponHeavy) {
      nextItem = this.GetActiveWeapon();
      if ItemID.IsValid(nextItem) {
        return nextItem;
      };
    };
    i = 0;
    while i < eqAreaSize {
      x = nextItemSlot + direction;
      nextItemSlot = (x % eqAreaSize + eqAreaSize) % eqAreaSize;
      nextItem = equipArea.equipSlots[nextItemSlot].itemID;
      if ItemID.IsValid(nextItem) && nextItem != activeItem && this.CheckWeaponAgainstGameplayRestrictions(nextItem) {
        return nextItem;
      };
      if !ItemID.IsValid(nextItem) && activeItem != barebonesWeapon && nextItemSlot + direction != eqAreaSize && this.CheckWeaponAgainstGameplayRestrictions(barebonesWeapon) {
        if !WeaponObject.IsCyberwareWeapon(barebonesWeapon) && nextItemSlot == eqAreaSize - 1 {
        } else {
          if WeaponObject.IsCyberwareWeapon(barebonesWeapon) && nextItemSlot != eqAreaSize - 1 {
          } else {
            if !onlyCheck {
              this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.WeaponWheel)].activeIndex = nextItemSlot;
            };
            return barebonesWeapon;
          };
        };
      };
      i += 1;
    };
    return ItemID.undefined();
  }

  public final func CheckWeaponAgainstGameplayRestrictions(weaponItem: ItemID) -> Bool {
    let itemTags: array<CName> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponItem)).Tags();
    let notificationEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
    notificationEvent.m_notificationType = UIInGameNotificationType.ActionRestriction;
    if ArrayContains(itemTags, WeaponObject.GetRangedWeaponTag()) {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"Melee") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"Fists") {
        GameInstance.GetUISystem((this.m_owner as PlayerPuppet).GetGame()).QueueEvent(notificationEvent);
        return false;
      };
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"OneHandedFirearms") && !ArrayContains(itemTags, WeaponObject.GetOneHandedRangedWeaponTag()) {
        GameInstance.GetUISystem((this.m_owner as PlayerPuppet).GetGame()).QueueEvent(notificationEvent);
        return false;
      };
      return true;
    };
    if ArrayContains(itemTags, WeaponObject.GetMeleeWeaponTag()) {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"Firearms") || StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"OneHandedFirearms") {
        GameInstance.GetUISystem((this.m_owner as PlayerPuppet).GetGame()).QueueEvent(notificationEvent);
        return false;
      };
      if !WeaponObject.IsFists(weaponItem) && StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_owner, n"Fists") {
        GameInstance.GetUISystem((this.m_owner as PlayerPuppet).GetGame()).QueueEvent(notificationEvent);
        return false;
      };
      return true;
    };
    GameInstance.GetUISystem((this.m_owner as PlayerPuppet).GetGame()).QueueEvent(notificationEvent);
    return false;
  }

  private final func RequestEquipmentStateMachine(reqType: EquipmentManipulationRequestType, reqSlot: EquipmentManipulationRequestSlot, equipAnim: gameEquipAnimationType, referenceName: CName, requestName: CName) -> Void {
    let instanceData: StateMachineInstanceData;
    let equipmentInitData: ref<EquipmentInitData> = new EquipmentInitData();
    let psmAdd: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    let psmRequest: ref<PSMPostponedParameterScriptable> = new PSMPostponedParameterScriptable();
    let weaRequest: ref<EquipmentManipulationRequest> = new EquipmentManipulationRequest();
    instanceData.referenceName = referenceName;
    weaRequest.requestType = reqType;
    weaRequest.requestSlot = reqSlot;
    weaRequest.equipAnim = equipAnim;
    psmRequest.value = weaRequest;
    psmRequest.id = requestName;
    psmRequest.aspect = gamestateMachineParameterAspect.Permanent;
    this.m_owner.QueueEvent(psmRequest);
    equipmentInitData.eqManipulationVarName = requestName;
    psmAdd.stateMachineName = n"Equipment";
    psmAdd.instanceData = instanceData;
    psmAdd.instanceData.initData = equipmentInitData;
    psmAdd.owner = this.m_owner;
    this.m_owner.QueueEvent(psmAdd);
  }

  public final func SendPSMWeaponManipulationRequest(reqType: EquipmentManipulationRequestType, reqSlot: EquipmentManipulationRequestSlot, equipAnim: gameEquipAnimationType) -> Void {
    if Equals(reqSlot, EquipmentManipulationRequestSlot.Right) || Equals(reqSlot, EquipmentManipulationRequestSlot.Both) {
      this.RequestEquipmentStateMachine(reqType, reqSlot, equipAnim, n"RightHand", n"EqManipulationRight");
    };
    if Equals(reqSlot, EquipmentManipulationRequestSlot.Left) || Equals(reqSlot, EquipmentManipulationRequestSlot.Both) {
      this.RequestEquipmentStateMachine(reqType, reqSlot, equipAnim, n"LeftHand", n"EqManipulationLeft");
    };
  }

  public final func FindItemInEqArea(item: ItemID, area: gamedataEquipmentArea) -> ItemID {
    let items: array<ItemID> = EquipmentSystem.GetItemsInArea(this.m_owner, area);
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if item == items[i] {
        return items[i];
      };
      i += 1;
    };
    return ItemID.undefined();
  }

  public final func FindItemInEqAreaByTag(tag: CName, area: gamedataEquipmentArea) -> ItemID {
    let itemTags: array<CName>;
    let items: array<ItemID> = EquipmentSystem.GetItemsInArea(this.m_owner, area);
    let i: Int32 = 0;
    while i < ArraySize(items) {
      itemTags = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(items[i])).Tags();
      if ArrayContains(itemTags, tag) {
        return items[i];
      };
      i += 1;
    };
    return ItemID.undefined();
  }

  public final func RemoveItemFromEquipSlot(item: ItemID) -> Void {
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaType(item));
    let slotIndex: Int32 = this.GetSlotIndex(item);
    this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID = ItemID.undefined();
  }

  private final const func UpdateWeaponWheel() -> Void {
    let meleeWare: SEquipSlot;
    let weaponWheelItems: array<SEquipSlot> = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.Weapon)].equipSlots;
    meleeWare.itemID = this.GetActiveMeleeWare();
    ArrayPush(weaponWheelItems, meleeWare);
    this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.WeaponWheel)].equipSlots = weaponWheelItems;
  }

  public final func ClearAllWeaponSlots() -> Void {
    let index: Int32 = this.GetEquipAreaIndex(gamedataEquipmentArea.Weapon);
    let i: Int32 = 0;
    while i < 3 {
      this.m_equipment.equipAreas[index].equipSlots[i].itemID = ItemID.undefined();
      i += 1;
    };
    this.UpdateWeaponWheel();
  }

  private final const func UpdateQuickWheel() -> Void {
    let record: ref<Item_Record>;
    let returnArray: array<SEquipSlot>;
    let quickWheelItems: array<SEquipSlot> = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.QuickSlot)].equipSlots;
    let i: Int32 = 0;
    while i < ArraySize(quickWheelItems) {
      if ItemID.IsValid(quickWheelItems[i].itemID) {
        ArrayPush(returnArray, quickWheelItems[i]);
      };
      i += 1;
    };
    quickWheelItems = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.IntegumentarySystemCW)].equipSlots;
    i = 0;
    while i < ArraySize(quickWheelItems) {
      if ItemID.IsValid(quickWheelItems[i].itemID) {
        ArrayPush(returnArray, quickWheelItems[i]);
      };
      i += 1;
    };
    quickWheelItems = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.ArmsCW)].equipSlots;
    i = 0;
    while i < ArraySize(quickWheelItems) {
      if ItemID.IsValid(quickWheelItems[i].itemID) {
        record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(quickWheelItems[i].itemID));
        if Equals(record.ItemType().Type(), gamedataItemType.Cyb_Launcher) {
          ArrayPush(returnArray, quickWheelItems[i]);
        };
      };
      i += 1;
    };
    quickWheelItems = this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.SystemReplacementCW)].equipSlots;
    i = 0;
    while i < ArraySize(quickWheelItems) {
      if ItemID.IsValid(quickWheelItems[i].itemID) {
        record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(quickWheelItems[i].itemID));
        if Equals(record.ItemType().Type(), gamedataItemType.Cyb_Ability) {
          ArrayPush(returnArray, quickWheelItems[i]);
        };
      };
      i += 1;
    };
    this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.QuickWheel)].equipSlots = returnArray;
  }

  private final func GetFistsItemID() -> ItemID {
    let items: array<ItemID> = EquipmentSystem.GetItemsInArea(this.m_owner, gamedataEquipmentArea.BaseFists);
    if ArraySize(items) > 0 {
      if ItemID.IsValid(items[0]) {
        return items[0];
      };
      return this.EquipBaseFists();
    };
    return ItemID.undefined();
  }

  private final func GetBaseFistsItemID() -> ItemID {
    return ItemID.CreateQuery(t"Items.w_melee_004__fists_a");
  }

  private final func GetMeleewareOrFistsItemID() -> ItemID {
    let item: ItemID = ItemID.undefined();
    item = this.GetActiveMeleeWare();
    if ItemID.IsValid(item) {
      return item;
    };
    return this.GetFistsItemID();
  }

  private final const func UpdateActiveWheelItem(itemID: ItemID) -> Void {
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(gamedataEquipmentArea.WeaponWheel);
    let i: Int32 = 0;
    while i < this.GetNumberOfSlots(gamedataEquipmentArea.WeaponWheel) {
      if this.m_equipment.equipAreas[equipAreaIndex].equipSlots[i].itemID == itemID {
        this.m_equipment.equipAreas[equipAreaIndex].activeIndex = i;
        return;
      };
      i += 1;
    };
    equipAreaIndex = this.GetEquipAreaIndex(gamedataEquipmentArea.QuickWheel);
    i = 0;
    while i < this.GetNumberOfSlots(gamedataEquipmentArea.QuickWheel) {
      if this.m_equipment.equipAreas[equipAreaIndex].equipSlots[i].itemID == itemID {
        this.m_equipment.equipAreas[equipAreaIndex].activeIndex = i;
        return;
      };
      i += 1;
    };
  }

  private final const func UpdateEquipAreaActiveIndex(newCurrentItem: ItemID) -> Void {
    let areaType: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(newCurrentItem);
    let areaIndex: Int32 = this.GetEquipAreaIndex(areaType);
    let i: Int32 = 0;
    while i < this.GetNumberOfSlots(areaType) {
      if this.m_equipment.equipAreas[areaIndex].equipSlots[i].itemID == newCurrentItem {
        this.m_equipment.equipAreas[areaIndex].activeIndex = i;
      } else {
        i += 1;
      };
    };
    this.UpdateActiveWheelItem(newCurrentItem);
  }

  private final const func UpdateEquipmentUIBB(paperDollEqData: SPaperdollEquipData, opt restored: Bool, opt forceFire: Bool) -> Void {
    let paperdollAreas: array<gamedataEquipmentArea>;
    let equipmentBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_Equipment);
    if IsDefined(equipmentBB) {
      equipmentBB.SetVariant(GetAllBlackboardDefs().UI_Equipment.itemEquipped, ToVariant(paperDollEqData.equipArea.equipSlots[paperDollEqData.slotIndex].itemID), true);
      paperdollAreas = this.GetPaperDollSlots();
      ArrayPush(paperdollAreas, gamedataEquipmentArea.Weapon);
      if ArrayContains(paperdollAreas, paperDollEqData.equipArea.areaType) {
        equipmentBB.SetVariant(GetAllBlackboardDefs().UI_Equipment.lastModifiedArea, ToVariant(paperDollEqData), forceFire);
        equipmentBB.FireCallbacks();
      };
    };
  }

  public final const func GetPaperDollEquipAreas() -> array<SEquipArea> {
    let areas: array<SEquipArea>;
    let slots: array<gamedataEquipmentArea> = this.GetPaperDollSlots();
    let i: Int32 = 0;
    while i < ArraySize(slots) {
      ArrayPush(areas, this.GetEquipArea(slots[i]));
      i += 1;
    };
    return areas;
  }

  public final const func GetPaperDollItems() -> array<ItemID> {
    let item: ItemID;
    let items: array<ItemID>;
    let slots: array<gamedataEquipmentArea> = this.GetPaperDollSlots();
    let i: Int32 = 0;
    while i < ArraySize(slots) {
      item = this.GetActiveItem(slots[i]);
      if ItemID.IsValid(item) {
        ArrayPush(items, item);
      };
      i += 1;
    };
    return items;
  }

  public final const func GetPaperDollSlots() -> array<gamedataEquipmentArea> {
    let slots: array<gamedataEquipmentArea>;
    ArrayPush(slots, gamedataEquipmentArea.Outfit);
    ArrayPush(slots, gamedataEquipmentArea.OuterChest);
    ArrayPush(slots, gamedataEquipmentArea.InnerChest);
    ArrayPush(slots, gamedataEquipmentArea.Head);
    ArrayPush(slots, gamedataEquipmentArea.Face);
    ArrayPush(slots, gamedataEquipmentArea.Legs);
    ArrayPush(slots, gamedataEquipmentArea.Feet);
    ArrayPush(slots, gamedataEquipmentArea.HandsCW);
    ArrayPush(slots, gamedataEquipmentArea.RightArm);
    if this.IsBuildCensored() {
      ArrayPush(slots, gamedataEquipmentArea.UnderwearTop);
    };
    if !this.ShouldShowGenitals() || this.IsBuildCensored() {
      ArrayPush(slots, gamedataEquipmentArea.UnderwearBottom);
    };
    return slots;
  }

  public final const func ShouldShowGenitals() -> Bool {
    let charCustomization: ref<gameuiICharacterCustomizationState> = GameInstance.GetCharacterCustomizationSystem(this.m_owner.GetGame()).GetState();
    if charCustomization != null {
      return charCustomization.HasOption(n"genitals", n"genitals_01", false) || charCustomization.HasOption(n"genitals", n"genitals_02", false) || charCustomization.HasOption(n"genitals", n"genitals_03", false);
    };
    return false;
  }

  public final const func IsBuildCensored() -> Bool {
    let charCustomization: ref<gameuiICharacterCustomizationSystem> = GameInstance.GetCharacterCustomizationSystem(this.m_owner.GetGame());
    if charCustomization != null {
      return !charCustomization.IsNudityAllowed();
    };
    return false;
  }

  public final func OnEquipRequest(request: ref<EquipRequest>) -> Void {
    this.ProcessEquipRequest(request.owner, request.slotIndex, request.addToInventory, request.itemID, request.equipToCurrentActiveSlot, false, true);
  }

  public final func OnGameplayEquipRequest(request: ref<GameplayEquipRequest>) -> Void {
    this.ProcessEquipRequest(request.owner, request.slotIndex, request.addToInventory, request.itemID, request.equipToCurrentActiveSlot, request.blockUpdateWeaponActiveSlots, request.forceEquipWeapon);
  }

  private final func ProcessEquipRequest(owner: wref<GameObject>, slotIndex: Int32, addToInventory: Bool, itemID: ItemID, equipToCurrentActiveSlot: Bool, opt blockUpdateWeaponActiveSlots: Bool, opt forceEquipWeapon: Bool) -> Void {
    if IsMultiplayer() && equipToCurrentActiveSlot {
      slotIndex = this.m_equipment.equipAreas[this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaType(itemID))].activeIndex;
    };
    if addToInventory {
      if !GameInstance.GetTransactionSystem(owner.GetGame()).HasItem(owner, itemID) {
        itemID = ItemID.FromTDBID(ItemID.GetTDBID(itemID));
        GameInstance.GetTransactionSystem(owner.GetGame()).GiveItem(owner, itemID, 1);
      } else {
        itemID = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemData(owner, itemID).GetID();
      };
    };
    if slotIndex == -1 {
      this.EquipItem(itemID, addToInventory, blockUpdateWeaponActiveSlots, forceEquipWeapon);
    } else {
      this.EquipItem(itemID, slotIndex, addToInventory, blockUpdateWeaponActiveSlots, forceEquipWeapon);
    };
  }

  public final func OnAssignToCyberwareWheelRequest(request: ref<AssignToCyberwareWheelRequest>) -> Void {
    let cyberwareBB: ref<IBlackboard>;
    if ArraySize(this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.CyberwareWheel)].equipSlots) <= request.slotIndex {
      return;
    };
    this.m_equipment.equipAreas[this.GetEquipAreaIndex(gamedataEquipmentArea.CyberwareWheel)].equipSlots[request.slotIndex].itemID = request.itemID;
    this.UpdateQuickWheel();
    cyberwareBB = GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    cyberwareBB.SetBool(GetAllBlackboardDefs().UI_QuickSlotsData.CyberwareAssignmentComplete, true, true);
  }

  public final func OnUnequipRequest(request: ref<UnequipRequest>) -> Void {
    this.UnequipItem(this.GetEquipAreaIndex(request.areaType), request.slotIndex);
  }

  public final func OnUnequipItemsRequest(request: ref<UnequipItemsRequest>) -> Void {
    let hotkey: EHotkey;
    let itemID: ItemID;
    let i: Int32 = 0;
    while i < ArraySize(request.items) {
      itemID = request.items[i];
      this.UnequipItem(itemID);
      hotkey = this.GetHotkeyTypeFromItemID(itemID);
      if NotEquals(hotkey, EHotkey.INVALID) {
        if this.AssignNextValidItemToHotkey(itemID) {
          return;
        };
        this.AssignItemToHotkey(ItemID.undefined(), hotkey);
      };
      i += 1;
    };
  }

  public final func OnUnequipByTDBIDRequest(request: ref<UnequipByTDBIDRequest>) -> Void {
    let eqRequest: ref<EquipmentSystemWeaponManipulationRequest>;
    let itemQuery: ItemID = ItemID.CreateQuery(request.itemTDBID);
    if Equals(RPGManager.GetItemCategory(itemQuery), gamedataItemCategory.Weapon) {
      eqRequest = new EquipmentSystemWeaponManipulationRequest();
      eqRequest.requestType = EquipmentManipulationAction.UnequipWeapon;
      this.OnEquipmentSystemWeaponManipulationRequest(eqRequest);
    } else {
      this.UnequipItem(itemQuery);
    };
  }

  public final func OnThrowEquipmentRequest(request: ref<ThrowEquipmentRequest>) -> Void {
    this.UnequipItem(request.itemObject.GetItemID());
  }

  public final func OnInstallCyberwareRequest(request: ref<InstallCyberwareRequest>) -> Void {
    if request.slotIndex == -1 {
      this.EquipItem(request.itemID, false);
    } else {
      this.EquipItem(request.itemID, request.slotIndex, false);
    };
  }

  public final func OnUninstallCyberwareRequest(request: ref<UninstallCyberwareRequest>) -> Void {
    this.UnequipItem(this.GetEquipAreaIndex(request.areaType), request.slotIndex);
  }

  public final func OnDrawItemRequest(request: ref<DrawItemRequest>) -> Void {
    this.DrawItem(request.itemID, request.equipAnimationType);
  }

  public final func OnPartInstallRequest(request: ref<PartInstallRequest>) -> Void {
    if this.IsEquipped(request.itemID) {
      this.ApplyEquipGLPs(request.partID);
    };
  }

  public final func OnPartUninstallRequest(request: ref<PartUninstallRequest>) -> Void {
    if this.IsEquipped(request.itemID) {
      this.RemoveEquipGLPs(request.partID);
    };
  }

  public final func OnClearEquipmentRequest(request: ref<ClearEquipmentRequest>) -> Void {
    this.ClearEquipment();
  }

  public final func OnSaveEquipmentSetRequest(request: ref<SaveEquipmentSetRequest>) -> Void {
    this.SaveEquipmentSet(request.setName, request.setType);
  }

  public final func OnLoadEquipmentSetRequest(request: ref<LoadEquipmentSetRequest>) -> Void {
    this.LoadEquipmentSet(request.setName);
  }

  public final func OnDeleteEquipmentSetRequest(request: ref<DeleteEquipmentSetRequest>) -> Void {
    this.DeleteEquipmentSet(request.setName);
  }

  public final func OnEquipmentUIBBRequest(request: ref<EquipmentUIBBRequest>) -> Void {
    let equipData: SPaperdollEquipData;
    this.UpdateEquipmentUIBB(equipData);
  }

  public final func OnCheckRemovedItemWithSlotActiveItem(request: ref<CheckRemovedItemWithSlotActiveItem>) -> Void {
    let activeItems: SSlotActiveItems = this.GetSlotActiveItemStruct();
    if ItemID.GetTDBID(activeItems.rightHandItem) == ItemID.GetTDBID(request.itemID) || ItemID.GetTDBID(activeItems.leftHandItem) == ItemID.GetTDBID(request.itemID) {
      this.RemoveItemFromSlotActiveItem(request.itemID);
    };
  }

  public final func OnSynchronizeAttachmentSlotRequest(request: ref<SynchronizeAttachmentSlotRequest>) -> Void {
    let activeItemID: ItemID = GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetActiveItemInSlot(request.owner, request.slotID);
    if !ItemID.IsValid(activeItemID) {
      return;
    };
    if this.IsEquipped(activeItemID) {
      this.m_equipment.equipAreas[this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaType(activeItemID))].activeIndex = this.GetSlotIndex(activeItemID);
    };
  }

  public final func OnEquipmentSystemWeaponManipulationRequest(request: ref<EquipmentSystemWeaponManipulationRequest>) -> Void {
    let actions: array<wref<ObjectAction_Record>>;
    let isActivatedCyberware: Bool;
    let requestSlot: EquipmentManipulationRequestSlot;
    let isUnequip: Bool = this.IsEquipmentManipulationAnUnequipRequest(request.requestType);
    let item: ItemID = this.GetItemIDfromEquipmentManipulationAction(request.requestType);
    if !isUnequip {
      if this.GetItemIDFromHotkey(EHotkey.RB) == item {
        if PlayerGameplayRestrictions.IsHotkeyRestricted(this.m_owner.GetGame(), EHotkey.RB) {
          return;
        };
      } else {
        if this.GetItemIDFromHotkey(EHotkey.DPAD_UP) == item {
          if PlayerGameplayRestrictions.IsHotkeyRestricted(this.m_owner.GetGame(), EHotkey.DPAD_UP) {
            return;
          };
        };
      };
    };
    if Equals(request.requestType, EquipmentManipulationAction.UnequipAll) {
      requestSlot = EquipmentManipulationRequestSlot.Both;
    };
    if !ItemID.IsValid(item) && NotEquals(requestSlot, EquipmentManipulationRequestSlot.Both) && NotEquals(request.requestType, EquipmentManipulationAction.UnequipConsumable) && NotEquals(request.requestType, EquipmentManipulationAction.UnequipGadget) {
      return;
    };
    isActivatedCyberware = this.CheckCyberwareItemForActivatedAction(item);
    if isActivatedCyberware {
      TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ObjectActions(actions);
      ItemActionsHelper.UseItem(this.m_owner, item);
      return;
    };
    if !isUnequip {
      if !this.HasItemInInventory(item) {
        return;
      };
      requestSlot = this.GetRequestSlotFromItemID(item);
      this.SetSlotActiveItem(requestSlot, item);
      this.UpdateEquipAreaActiveIndex(item);
      this.SetLastUsedItem(item);
      this.SendPSMWeaponManipulationRequest(EquipmentManipulationRequestType.Equip, requestSlot, request.equipAnimType);
    } else {
      if NotEquals(requestSlot, EquipmentManipulationRequestSlot.Both) {
        if ItemID.IsValid(item) {
          requestSlot = this.GetRequestSlotFromItemID(item);
        } else {
          if Equals(request.requestType, EquipmentManipulationAction.UnequipConsumable) || Equals(request.requestType, EquipmentManipulationAction.UnequipGadget) {
            requestSlot = EquipmentManipulationRequestSlot.Left;
          };
        };
      };
      this.SetSlotActiveItem(requestSlot, ItemID.undefined());
      this.SendPSMWeaponManipulationRequest(EquipmentManipulationRequestType.Unequip, requestSlot, request.equipAnimType);
      if request.removeItemFromEquipSlot {
        this.RemoveItemFromEquipSlot(item);
      };
    };
  }

  public final func OnClearAllWeaponSlotsRequest(request: ref<ClearAllWeaponSlotsRequest>) -> Void {
    this.ClearAllWeaponSlots();
  }

  private final func CreateUnequipWeaponManipulationRequest() -> Void {
    let request: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    request.requestType = EquipmentManipulationAction.UnequipWeapon;
    this.OnEquipmentSystemWeaponManipulationRequest(request);
  }

  private final func CreateUnequipGadgetWeaponManipulationRequest() -> Void {
    let request: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    request.requestType = EquipmentManipulationAction.UnequipGadget;
    request.removeItemFromEquipSlot = true;
    this.OnEquipmentSystemWeaponManipulationRequest(request);
  }

  private final func CreateUnequipConsumableWeaponManipulationRequest() -> Void {
    let request: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    request.requestType = EquipmentManipulationAction.UnequipConsumable;
    request.removeItemFromEquipSlot = true;
    this.OnEquipmentSystemWeaponManipulationRequest(request);
  }

  public final func IsEquipmentManipulationAnUnequipRequest(eqManipulationAction: EquipmentManipulationAction) -> Bool {
    return Equals(eqManipulationAction, EquipmentManipulationAction.UnequipWeapon) || Equals(eqManipulationAction, EquipmentManipulationAction.UnequipConsumable) || Equals(eqManipulationAction, EquipmentManipulationAction.UnequipGadget) || Equals(eqManipulationAction, EquipmentManipulationAction.UnequipLeftHandCyberware) || Equals(eqManipulationAction, EquipmentManipulationAction.UnequipAll);
  }

  public final func GetRequestSlotFromEquipmentManipulationAction(eqManipulationAction: EquipmentManipulationAction) -> EquipmentManipulationRequestSlot {
    if Equals(eqManipulationAction, EquipmentManipulationAction.Undefined) {
      return EquipmentManipulationRequestSlot.Undefined;
    };
    if Equals(eqManipulationAction, EquipmentManipulationAction.UnequipConsumable) || Equals(eqManipulationAction, EquipmentManipulationAction.UnequipGadget) || Equals(eqManipulationAction, EquipmentManipulationAction.UnequipLeftHandCyberware) || Equals(eqManipulationAction, EquipmentManipulationAction.RequestGadget) || Equals(eqManipulationAction, EquipmentManipulationAction.RequestLeftHandCyberware) || Equals(eqManipulationAction, EquipmentManipulationAction.RequestConsumable) {
      return EquipmentManipulationRequestSlot.Left;
    };
    if Equals(eqManipulationAction, EquipmentManipulationAction.UnequipAll) {
      return EquipmentManipulationRequestSlot.Both;
    };
    return EquipmentManipulationRequestSlot.Right;
  }

  public final func GetRequestSlotFromItemID(item: ItemID) -> EquipmentManipulationRequestSlot {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    switch record.ItemCategory().Type() {
      case gamedataItemCategory.Weapon:
        if Equals(record.ItemType().Type(), gamedataItemType.Cyb_Launcher) {
          return EquipmentManipulationRequestSlot.Left;
        };
        return EquipmentManipulationRequestSlot.Right;
      case gamedataItemCategory.Consumable:
        return EquipmentManipulationRequestSlot.Left;
      case gamedataItemCategory.Gadget:
        return EquipmentManipulationRequestSlot.Left;
      case gamedataItemCategory.Cyberware:
        return EquipmentManipulationRequestSlot.Left;
    };
  }

  public final func GetItemIDfromEquipmentManipulationAction(eqManipulationAction: EquipmentManipulationAction) -> ItemID {
    switch eqManipulationAction {
      case EquipmentManipulationAction.RequestActiveMeleeware:
        return this.GetActiveMeleeWare();
      case EquipmentManipulationAction.RequestSlotActiveWeapon:
        return this.GetSlotActiveWeapon();
      case EquipmentManipulationAction.RequestActiveWeapon:
        return this.GetActiveWeapon();
      case EquipmentManipulationAction.RequestLastUsedWeapon:
        return this.GetLastUsedWeaponItemID();
      case EquipmentManipulationAction.RequestFirstMeleeWeapon:
        return this.GetFirstMeleeWeaponItemID();
      case EquipmentManipulationAction.RequestLastUsedMeleeWeapon:
        return this.GetLastUsedMeleeWeaponItemID();
      case EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon:
        return this.GetLastUsedOrFirstAvailableWeapon();
      case EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon:
        return this.GetLastUsedOrFirstAvailableRangedWeapon();
      case EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon:
        return this.GetLastUsedOrFirstAvailableMeleeWeapon();
      case EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon:
        return this.GetLastUsedOrFirstAvailableOneHandedRangedWeapon();
      case EquipmentManipulationAction.RequestHeavyWeapon:
        return this.GetActiveHeavyWeapon();
      case EquipmentManipulationAction.RequestConsumable:
        return this.GetActiveConsumable();
      case EquipmentManipulationAction.RequestGadget:
        return this.GetActiveGadget();
      case EquipmentManipulationAction.RequestLeftHandCyberware:
        return this.GetActiveCyberware();
      case EquipmentManipulationAction.RequestFists:
        return this.GetFistsItemID();
      case EquipmentManipulationAction.UnequipGadget:
        return this.GetActiveGadget();
      case EquipmentManipulationAction.UnequipLeftHandCyberware:
        return this.GetActiveCyberware();
      case EquipmentManipulationAction.UnequipConsumable:
        return this.GetActiveConsumable();
      case EquipmentManipulationAction.UnequipWeapon:
        return this.GetActiveWeaponToUnequip();
      case EquipmentManipulationAction.CycleWeaponWheelItem:
        return this.GetNextWeaponWheelItem();
      case EquipmentManipulationAction.CycleNextWeaponWheelItem:
        return this.CycleWeapon(true, false);
      case EquipmentManipulationAction.CyclePreviousWeaponWheelItem:
        return this.CycleWeapon(false, false);
      case EquipmentManipulationAction.ReequipWeapon:
        return this.GetLastUsedWeaponItemID();
      case EquipmentManipulationAction.RequestWeaponSlot1:
        return this.GetWeaponSlotItem(1);
      case EquipmentManipulationAction.RequestWeaponSlot2:
        return this.GetWeaponSlotItem(2);
      case EquipmentManipulationAction.RequestWeaponSlot3:
        return this.GetWeaponSlotItem(3);
      case EquipmentManipulationAction.RequestWeaponSlot4:
        return this.GetWeaponSlotItem(4);
      default:
        return ItemID.undefined();
    };
  }

  public final func CheckCyberwareItemForActivatedAction(item: ItemID) -> Bool {
    let actions: array<wref<ObjectAction_Record>>;
    let record: wref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    if IsDefined(record) && (NotEquals(record.ItemCategory().Type(), gamedataItemCategory.Cyberware) || Equals(record.ItemType().Type(), gamedataItemType.Cyb_Launcher)) {
      return false;
    };
    if IsDefined(record) {
      record.ObjectActions(actions);
    };
    return ArraySize(actions) > 0;
  }

  public final func OnSetActiveItemInEquipmentArea(request: ref<SetActiveItemInEquipmentArea>) -> Void {
    let slotIndex: Int32 = this.GetSlotIndex(request.itemID);
    let equipAreaIndex: Int32 = this.GetEquipAreaIndex(EquipmentSystem.GetEquipAreaTypeForDpad(request.itemID));
    let equipArea: SEquipArea = this.m_equipment.equipAreas[equipAreaIndex];
    if slotIndex >= 0 && slotIndex < ArraySize(equipArea.equipSlots) {
      this.m_equipment.equipAreas[equipAreaIndex].activeIndex = slotIndex;
      this.UpdateActiveWheelItem(this.GetItemInEquipSlot(equipAreaIndex, slotIndex));
    };
  }

  public final func CheckCyberjunkieAchievement() -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let equipmentAreas: array<gamedataEquipmentArea>;
    let i: Int32;
    let progress: Int32;
    let progressionRequest: ref<SetAchievementProgressRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.Cyberjunkie;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) {
      return;
    };
    ArrayPush(equipmentAreas, gamedataEquipmentArea.SystemReplacementCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.FrontalCortexCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.EyesCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.MusculoskeletalSystemCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.NervousSystemCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.CardiovascularSystemCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.ImmuneSystemCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.IntegumentarySystemCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.ArmsCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.LegsCW);
    ArrayPush(equipmentAreas, gamedataEquipmentArea.HandsCW);
    i = 0;
    while i < ArraySize(equipmentAreas) {
      if this.GetNumberOfItemsInEquipmentArea(equipmentAreas[i]) > 0 {
        progress += 1;
      };
      i += 1;
    };
    progressionRequest = new SetAchievementProgressRequest();
    progressionRequest.achievement = achievement;
    progressionRequest.currentValue = progress;
    progressionRequest.maxValue = ArraySize(equipmentAreas);
    dataTrackingSystem.QueueRequest(progressionRequest);
    i = 0;
    while i < ArraySize(equipmentAreas) {
      if this.GetNumberOfItemsInEquipmentArea(equipmentAreas[i]) == 0 {
        return;
      };
      i += 1;
    };
    achievementRequest = new AddAchievementRequest();
    achievementRequest.achievement = achievement;
    dataTrackingSystem.QueueRequest(achievementRequest);
  }

  public final func GetInventoryManager() -> wref<InventoryDataManagerV2> {
    return this.m_inventoryManager;
  }
}

public class EquipmentSystem extends ScriptableSystem {

  private persistent let m_ownerData: array<ref<EquipmentSystemPlayerData>>;

  public final static func GetInstance(owner: ref<GameObject>) -> ref<EquipmentSystem> {
    let ES: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    return ES;
  }

  private final const func CalculateSuffix(itemId: ItemID, owner: wref<GameObject>, suffixRecord: ref<ItemsFactoryAppearanceSuffixBase_Record>) -> String {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(owner);
    if !IsDefined(playerData) {
      playerData = this.m_ownerData[0];
    };
    if playerData.IsPartialVisualTagActive() {
      return "Part";
    };
    return "Full";
  }

  private final const func GetHairSuffix(itemId: ItemID, owner: wref<GameObject>, suffixRecord: ref<ItemsFactoryAppearanceSuffixBase_Record>) -> String {
    let customizationState: ref<gameuiICharacterCustomizationState>;
    let characterCustomizationSystem: ref<gameuiICharacterCustomizationSystem> = GameInstance.GetCharacterCustomizationSystem(owner.GetGame());
    if (owner as PlayerPuppet) == null && !characterCustomizationSystem.HasCharacterCustomizationComponent(owner) {
      return "Bald";
    };
    customizationState = characterCustomizationSystem.GetState();
    if customizationState != null {
      if customizationState.HasTag(n"Short") {
        return "Short";
      };
      if customizationState.HasTag(n"Long") {
        return "Long";
      };
      if customizationState.HasTag(n"Dreads") {
        return "Dreads";
      };
      if customizationState.HasTag(n"Buzz") {
        return "Buzz";
      };
      return "Bald";
    };
    return "Error";
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let data: ref<EquipmentSystemPlayerData>;
    LogAssert(this.GetPlayerData(request.owner) == null, "[EquipmentSystem::OnPlayerAttach] Player already attached!");
    if !IsDefined(this.GetPlayerData(request.owner)) {
      data = new EquipmentSystemPlayerData();
      data.SetOwner(request.owner as ScriptedPuppet);
      ArrayPush(this.m_ownerData, data);
      data.OnInitialize();
    } else {
      data = this.GetPlayerData(request.owner);
    };
    data.OnAttach();
    this.Debug_SetupEquipmentSystemOverlay(request.owner);
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_ownerData) {
      if this.m_ownerData[i].GetOwner() == request.owner {
        this.m_ownerData[i].OnDetach();
        ArrayErase(this.m_ownerData, i);
        return;
      };
      i += 1;
    };
    LogAssert(false, "[EquipmentSystem::OnPlayerDetach] Can\'t find player!");
  }

  public final const func GetPlayerData(const owner: ref<GameObject>) -> ref<EquipmentSystemPlayerData> {
    let i: Int32;
    LogAssert(owner != null, "[EquipmentSystem::GetPlayerData] Owner not defined!");
    i = 0;
    while i < ArraySize(this.m_ownerData) {
      if this.m_ownerData[i].GetOwner() == owner {
        return this.m_ownerData[i];
      };
      i += 1;
    };
    LogAssert(false, "[EquipmentSystem::GetPlayerData] Unable to find player data!");
    return null;
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    let owner: ref<ScriptedPuppet>;
    let ownerID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(this.m_ownerData) {
      ownerID = this.m_ownerData[i].GetOwnerID();
      owner = GameInstance.FindEntityByID(this.GetGameInstance(), ownerID) as ScriptedPuppet;
      if IsDefined(owner) {
        this.m_ownerData[i].SetOwner(owner);
        this.m_ownerData[i].OnRestored();
      };
      i += 1;
    };
  }

  public final const func PrintEquipment() -> Void {
    let equipmentId: Int32;
    Log("Player Equipments:");
    equipmentId = 0;
    while equipmentId < ArraySize(this.m_ownerData) {
      Log("Player Equipment #" + IntToString(equipmentId));
      this.m_ownerData[equipmentId].PrintEquipment();
      equipmentId += 1;
    };
  }

  public final const func GetItemInEquipSlot(owner: ref<GameObject>, equipArea: gamedataEquipmentArea, slotIndex: Int32) -> ItemID {
    return this.GetPlayerData(owner).GetItemInEquipSlot(equipArea, slotIndex);
  }

  public final const func IsEquipped(owner: ref<GameObject>, item: ItemID) -> Bool {
    return this.GetPlayerData(owner).IsEquipped(item);
  }

  public final const func IsEquipped(owner: ref<GameObject>, item: ItemID, equipmentArea: gamedataEquipmentArea) -> Bool {
    return this.GetPlayerData(owner).IsEquipped(item, equipmentArea);
  }

  public final const func GetActiveItem(owner: ref<GameObject>, area: gamedataEquipmentArea) -> ItemID {
    return this.GetPlayerData(owner).GetActiveItem(area);
  }

  public final const func GetActiveWeaponObject(owner: ref<GameObject>, area: gamedataEquipmentArea) -> ref<ItemObject> {
    return this.GetPlayerData(owner).GetActiveWeaponObject(area);
  }

  public final const func GetAllInstalledCyberwareAbilities(owner: ref<GameObject>) -> array<SEquipSlot> {
    return this.GetPlayerData(owner).GetAllAbilityCyberwareSlots();
  }

  public final static func GetLastUsedItemByType(owner: ref<GameObject>, type: ELastUsed) -> ItemID {
    return EquipmentSystem.GetData(owner).GetLastUsedItemID(type);
  }

  public final const func GetItemSlotIndex(owner: ref<GameObject>, item: ItemID) -> Int32 {
    if !IsDefined(EquipmentSystem.GetData(owner)) {
      return -1;
    };
    return EquipmentSystem.GetData(owner).GetSlotIndex(item);
  }

  public final static func IsCyberdeckEquipped(owner: ref<GameObject>) -> Bool {
    let systemReplacementID: ItemID = EquipmentSystem.GetData(owner).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    let itemRecord: wref<Item_Record> = RPGManager.GetItemRecord(systemReplacementID);
    let itemTags: array<CName> = itemRecord.Tags();
    return ArrayContains(itemTags, n"Cyberdeck");
  }

  public final static func IsItemCyberdeck(itemID: ItemID) -> Bool {
    let itemRecord: wref<Item_Record> = RPGManager.GetItemRecord(itemID);
    let itemTags: array<CName> = itemRecord.Tags();
    return ArrayContains(itemTags, n"Cyberdeck");
  }

  public final static func GetPlacementSlot(item: ItemID) -> TweakDBID {
    let placementSlots: array<wref<AttachmentSlot_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    if IsDefined(itemRecord) {
      itemRecord.PlacementSlots(placementSlots);
    };
    if ArraySize(placementSlots) > 0 {
      return placementSlots[0].GetID();
    };
    return TDBID.undefined();
  }

  public final static func GetEquipAreaType(item: ItemID) -> gamedataEquipmentArea {
    let equipAreaRecord: ref<EquipmentArea_Record>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    if IsDefined(itemRecord) {
      equipAreaRecord = itemRecord.EquipArea();
      if IsDefined(equipAreaRecord) && TDBID.IsValid(equipAreaRecord.GetID()) {
        return equipAreaRecord.Type();
      };
    };
    return gamedataEquipmentArea.Invalid;
  }

  public final static func GetEquipAreaTypeForDpad(item: ItemID) -> gamedataEquipmentArea {
    let equipAreaRecord: ref<EquipmentArea_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).EquipArea();
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    if TDBID.IsValid(equipAreaRecord.GetID()) {
      if Equals(itemRecord.ItemType().Type(), gamedataItemType.Cyb_Launcher) {
        return gamedataEquipmentArea.ArmsCW;
      };
      return equipAreaRecord.Type();
    };
    return gamedataEquipmentArea.Invalid;
  }

  public final const func IsItemInHotkey(const owner: wref<GameObject>, itemID: ItemID) -> Bool {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(owner);
    if IsDefined(playerData) {
      return playerData.IsItemInHotkey(itemID);
    };
    return false;
  }

  public final const func GetHotkeyTypeForItemID(owner: wref<GameObject>, itemID: ItemID) -> EHotkey {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(owner);
    if IsDefined(playerData) {
      return playerData.GetHotkeyTypeForItemID(itemID);
    };
    return EHotkey.INVALID;
  }

  public final const func GetHotkeyTypeFromItemID(owner: wref<GameObject>, itemID: ItemID) -> EHotkey {
    return this.GetPlayerData(owner).GetHotkeyTypeFromItemID(itemID);
  }

  public final const func GetItemIDFromHotkey(owner: wref<GameObject>, hotkey: EHotkey) -> ItemID {
    return this.GetPlayerData(owner).GetItemIDFromHotkey(hotkey);
  }

  public final static func GetData(owner: ref<GameObject>) -> ref<EquipmentSystemPlayerData> {
    let equipmentSystem: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    return equipmentSystem.GetPlayerData(owner);
  }

  public final static func GetSlotActiveItem(owner: ref<GameObject>, requestSlot: EquipmentManipulationRequestSlot) -> ItemID {
    let playerData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(owner);
    if IsDefined(playerData) {
      return playerData.GetSlotActiveItem(requestSlot);
    };
    return ItemID.undefined();
  }

  public final static func GetItemsInArea(owner: ref<GameObject>, area: gamedataEquipmentArea) -> array<ItemID> {
    let i: Int32;
    let returnArray: array<ItemID>;
    let equipment: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(owner);
    if IsDefined(equipment) {
      i = 0;
      while i < equipment.GetNumberOfSlots(area) {
        ArrayPush(returnArray, equipment.GetItemInEquipSlot(area, i));
        i += 1;
      };
    };
    return returnArray;
  }

  public final static func HasItemInArea(owner: ref<GameObject>, area: gamedataEquipmentArea) -> Bool {
    let itemsInArea: array<ItemID> = EquipmentSystem.GetItemsInArea(owner, area);
    let i: Int32 = 0;
    while i < ArraySize(itemsInArea) {
      if ItemID.IsValid(itemsInArea[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func FindItemInWeaponEqArea(owner: ref<GameObject>, item: ItemID) -> ItemID {
    let items: array<ItemID> = EquipmentSystem.GetItemsInArea(owner, gamedataEquipmentArea.WeaponWheel);
    let id: Int32 = ArrayFindFirst(items, item);
    if !ItemID.IsValid(item) {
      return ItemID.undefined();
    };
    if id != -1 {
      return items[id];
    };
    return ItemID.undefined();
  }

  public final static func GetFirstMeleeWeapon(owner: ref<GameObject>) -> ItemID {
    let i: Int32;
    let itemTags: array<CName>;
    let items: array<ItemID>;
    if ItemID.IsValid(EquipmentSystem.GetData(owner).GetActiveMeleeWare()) {
      return EquipmentSystem.GetData(owner).GetActiveMeleeWare();
    };
    items = EquipmentSystem.GetItemsInArea(owner, gamedataEquipmentArea.Weapon);
    i = 0;
    while i < ArraySize(items) {
      itemTags = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(items[i])).Tags();
      if ArrayContains(itemTags, WeaponObject.GetMeleeWeaponTag()) {
        return items[i];
      };
      i += 1;
    };
    items = EquipmentSystem.GetItemsInArea(owner, gamedataEquipmentArea.BaseFists);
    if ArraySize(items) > 0 {
      return items[0];
    };
    return ItemID.undefined();
  }

  public final static func GetFirstRangedWeapon(owner: ref<GameObject>) -> ItemID {
    let itemTags: array<CName>;
    let items: array<ItemID> = EquipmentSystem.GetItemsInArea(owner, gamedataEquipmentArea.Weapon);
    let i: Int32 = 0;
    while i < ArraySize(items) {
      itemTags = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(items[i])).Tags();
      if ArrayContains(itemTags, WeaponObject.GetRangedWeaponTag()) {
        return items[i];
      };
      i += 1;
    };
    return ItemID.undefined();
  }

  public final static func GetFirstAvailableWeapon(owner: ref<GameObject>) -> ItemID {
    let item: ItemID;
    let playerData: ref<EquipmentSystemPlayerData>;
    let items: array<ItemID> = EquipmentSystem.GetItemsInArea(owner, gamedataEquipmentArea.WeaponWheel);
    let i: Int32 = 0;
    while i < ArraySize(items) {
      if ItemID.IsValid(items[i]) {
        return items[i];
      };
      i += 1;
    };
    playerData = EquipmentSystem.GetData(owner);
    if IsDefined(playerData) {
      item = playerData.GetActiveMeleeWare();
    };
    if ItemID.IsValid(item) {
      return item;
    };
    items = EquipmentSystem.GetItemsInArea(owner, gamedataEquipmentArea.BaseFists);
    if ArraySize(items) > 0 {
      return items[0];
    };
    return ItemID.undefined();
  }

  public final static func HasTag(item: ref<ItemObject>, tag: CName) -> Bool {
    let tags: array<CName> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item.GetItemID())).Tags();
    let i: Int32 = 0;
    while i < ArraySize(tags) {
      if Equals(tags[i], tag) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func IsClothing(item: ItemID) -> Bool {
    let type: gamedataEquipmentArea = EquipmentSystem.GetEquipAreaType(item);
    return Equals(type, gamedataEquipmentArea.InnerChest) || Equals(type, gamedataEquipmentArea.OuterChest) || Equals(type, gamedataEquipmentArea.Legs) || Equals(type, gamedataEquipmentArea.Feet) || Equals(type, gamedataEquipmentArea.Head);
  }

  public final static func GetClothingEquipmentAreas() -> array<gamedataEquipmentArea> {
    let slots: array<gamedataEquipmentArea>;
    ArrayPush(slots, gamedataEquipmentArea.OuterChest);
    ArrayPush(slots, gamedataEquipmentArea.InnerChest);
    ArrayPush(slots, gamedataEquipmentArea.Head);
    ArrayPush(slots, gamedataEquipmentArea.Legs);
    ArrayPush(slots, gamedataEquipmentArea.Feet);
    ArrayPush(slots, gamedataEquipmentArea.Face);
    return slots;
  }

  public final const func GetEquipAreaFromItemID(owner: ref<GameObject>, item: ItemID) -> SEquipArea {
    let voidEquipArea: SEquipArea;
    let playerData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(owner);
    if IsDefined(playerData) {
      return playerData.GetEquipAreaFromItemID(item);
    };
    return voidEquipArea;
  }

  private final func OnEquipRequest(request: ref<EquipRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnEquipRequest(request);
  }

  private final func OnGameplayEquipRequest(request: ref<GameplayEquipRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnGameplayEquipRequest(request);
  }

  private final func OnClearAllWeaponSlotsRequest(request: ref<ClearAllWeaponSlotsRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnClearAllWeaponSlotsRequest(request);
  }

  private final func OnUnequipRequest(request: ref<UnequipRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnUnequipRequest(request);
  }

  private final func OnUnequipItemsRequest(request: ref<UnequipItemsRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnUnequipItemsRequest(request);
  }

  private final func OnHotkeyRefreshRequest(request: ref<HotkeyRefreshRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnHotkeyRefreshRequest(request);
  }

  private final func OnHotkeyAssignmentRequest(request: ref<HotkeyAssignmentRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.Owner());
    playerData.OnHotkeyAssignmentRequest(request);
  }

  private final func OnAssignHotkeyIfEmptySlot(request: ref<AssignHotkeyIfEmptySlot>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.Owner());
    playerData.OnAssignHotkeyIfEmptySlot(request);
  }

  private final func OnThrowEquipmentRequest(request: ref<ThrowEquipmentRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnThrowEquipmentRequest(request);
  }

  private final func OnInstallCyberwareRequest(request: ref<InstallCyberwareRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnInstallCyberwareRequest(request);
  }

  private final func OnUninstallCyberwareRequest(request: ref<UninstallCyberwareRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnUninstallCyberwareRequest(request);
  }

  private final func OnDrawItemRequest(request: ref<DrawItemRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnDrawItemRequest(request);
  }

  private final func OnPartInstallRequest(request: ref<PartInstallRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnPartInstallRequest(request);
  }

  private final func OnPartUninstallRequest(request: ref<PartUninstallRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnPartUninstallRequest(request);
  }

  private final func OnClearEquipmentRequest(request: ref<ClearEquipmentRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnClearEquipmentRequest(request);
  }

  private final func OnSaveEquipmentSetRequest(request: ref<SaveEquipmentSetRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnSaveEquipmentSetRequest(request);
  }

  private final func OnLoadEquipmentSetRequest(request: ref<LoadEquipmentSetRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnLoadEquipmentSetRequest(request);
  }

  private final func OnDeleteEquipmentSetRequest(request: ref<DeleteEquipmentSetRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnDeleteEquipmentSetRequest(request);
  }

  private final func OnAssignToCyberwareWheelRequest(request: ref<AssignToCyberwareWheelRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnAssignToCyberwareWheelRequest(request);
  }

  private final func OnEquipmentUIBBRequest(request: ref<EquipmentUIBBRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnEquipmentUIBBRequest(request);
  }

  private final func OnCheckRemovedItemWithSlotActiveItem(request: ref<CheckRemovedItemWithSlotActiveItem>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnCheckRemovedItemWithSlotActiveItem(request);
  }

  private final func OnSynchronizeAttachmentSlotRequest(request: ref<SynchronizeAttachmentSlotRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnSynchronizeAttachmentSlotRequest(request);
  }

  private final func OnDrawItemByContextRequest(request: ref<DrawItemByContextRequest>) -> Void {
    let eqRequest: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    let equipData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(request.owner);
    switch request.itemEquipContext {
      case gameItemEquipContexts.LastWeaponEquipped:
        eqRequest.requestType = EquipmentManipulationAction.RequestLastUsedWeapon;
        break;
      case gameItemEquipContexts.LastUsedMeleeWeapon:
        eqRequest.requestType = EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon;
        break;
      case gameItemEquipContexts.LastUsedRangedWeapon:
        eqRequest.requestType = EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon;
        break;
      case gameItemEquipContexts.Gadget:
        eqRequest.requestType = EquipmentManipulationAction.RequestGadget;
        break;
      case gameItemEquipContexts.MeleeCyberware:
        eqRequest.requestType = EquipmentManipulationAction.RequestActiveMeleeware;
        break;
      case gameItemEquipContexts.LauncherCyberware:
        break;
      case gameItemEquipContexts.Fists:
        eqRequest.requestType = EquipmentManipulationAction.RequestFists;
    };
    eqRequest.equipAnimType = request.equipAnimationType;
    equipData.OnEquipmentSystemWeaponManipulationRequest(eqRequest);
  }

  private final func OnUnequipByTDBIDRequest(request: ref<UnequipByTDBIDRequest>) -> Void {
    let equipData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(request.owner);
    equipData.OnUnequipByTDBIDRequest(request);
  }

  private final func OnUnequipByContextRequest(request: ref<UnequipByContextRequest>) -> Void {
    let clearRequest: ref<ClearEquipmentRequest>;
    let unequipItemsRequest: ref<UnequipItemsRequest>;
    let eqRequest: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    let equipData: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(request.owner);
    let unequipRequest: ref<UnequipRequest> = new UnequipRequest();
    unequipRequest.slotIndex = 0;
    switch request.itemUnequipContext {
      case gameItemUnequipContexts.AllItems:
        clearRequest = new ClearEquipmentRequest();
        equipData.OnClearEquipmentRequest(clearRequest);
        break;
      case gameItemUnequipContexts.HeadClothing:
        unequipRequest.areaType = gamedataEquipmentArea.Head;
        equipData.OnUnequipRequest(unequipRequest);
        break;
      case gameItemUnequipContexts.FaceClothing:
        unequipRequest.areaType = gamedataEquipmentArea.Face;
        equipData.OnUnequipRequest(unequipRequest);
        break;
      case gameItemUnequipContexts.OuterChestClothing:
        unequipRequest.areaType = gamedataEquipmentArea.OuterChest;
        equipData.OnUnequipRequest(unequipRequest);
        break;
      case gameItemUnequipContexts.InnerChestClothing:
        unequipRequest.areaType = gamedataEquipmentArea.InnerChest;
        equipData.OnUnequipRequest(unequipRequest);
        break;
      case gameItemUnequipContexts.LegClothing:
        unequipRequest.areaType = gamedataEquipmentArea.Legs;
        equipData.OnUnequipRequest(unequipRequest);
        break;
      case gameItemUnequipContexts.FootClothing:
        unequipRequest.areaType = gamedataEquipmentArea.Feet;
        equipData.OnUnequipRequest(unequipRequest);
        break;
      case gameItemUnequipContexts.AllClothing:
        unequipRequest.areaType = gamedataEquipmentArea.Head;
        equipData.OnUnequipRequest(unequipRequest);
        unequipRequest.areaType = gamedataEquipmentArea.Face;
        equipData.OnUnequipRequest(unequipRequest);
        unequipRequest.areaType = gamedataEquipmentArea.OuterChest;
        equipData.OnUnequipRequest(unequipRequest);
        unequipRequest.areaType = gamedataEquipmentArea.InnerChest;
        equipData.OnUnequipRequest(unequipRequest);
        unequipRequest.areaType = gamedataEquipmentArea.Legs;
        equipData.OnUnequipRequest(unequipRequest);
        unequipRequest.areaType = gamedataEquipmentArea.Feet;
        equipData.OnUnequipRequest(unequipRequest);
        unequipRequest.areaType = gamedataEquipmentArea.Outfit;
        equipData.OnUnequipRequest(unequipRequest);
        break;
      case gameItemUnequipContexts.RightHandWeapon:
        eqRequest.requestType = EquipmentManipulationAction.UnequipWeapon;
        equipData.OnEquipmentSystemWeaponManipulationRequest(eqRequest);
        break;
      case gameItemUnequipContexts.LeftHandWeapon:
        eqRequest.requestType = EquipmentManipulationAction.UnequipConsumable;
        equipData.OnEquipmentSystemWeaponManipulationRequest(eqRequest);
        break;
      case gameItemUnequipContexts.AllWeapons:
        eqRequest.requestType = EquipmentManipulationAction.UnequipAll;
        equipData.OnEquipmentSystemWeaponManipulationRequest(eqRequest);
        break;
      case gameItemUnequipContexts.AllQuestItems:
        unequipItemsRequest = new UnequipItemsRequest();
        unequipItemsRequest.items = equipData.GetEquippedQuestItems();
        equipData.OnUnequipItemsRequest(unequipItemsRequest);
    };
  }

  private final func Debug_SetupEquipmentSystemOverlay(dataOwner: wref<GameObject>) -> Void {
    let areas: array<SEquipArea>;
    let i: Int32;
    let loadout: SLoadout;
    let data: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(dataOwner);
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, "Equipment");
    loadout = data.GetEquipment();
    areas = loadout.equipAreas;
    i = 0;
    while i < ArraySize(areas) {
      this.Debug_SetupESAreaButton(areas[i], dataOwner);
      i += 1;
    };
  }

  public final static func ComposeSDORootPath(ownerGameObject: wref<GameObject>, opt suffix: String) -> String {
    let path: String = "Equipment/[Player: " + ToString(ownerGameObject.GetControllingPeerID()) + "]";
    if StrLen(suffix) > 0 {
      path = path + "/" + suffix;
    };
    return path;
  }

  public final const func Debug_SetupESAreaButton(equipArea: SEquipArea, ownerGameObject: wref<GameObject>) -> Void {
    let area: String;
    let i: Int32;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, EquipmentSystem.ComposeSDORootPath(ownerGameObject));
    area = EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(equipArea.areaType)));
    SDOSink.PushString(sink, area, "");
    i = 0;
    while i < ArraySize(equipArea.equipSlots) {
      this.Debug_SetupESSlotButton(i, area, ownerGameObject);
      i += 1;
    };
  }

  public final const func Debug_SetupESSlotButton(slotIndex: Int32, areaStr: String, ownerGameObject: wref<GameObject>) -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, EquipmentSystem.ComposeSDORootPath(ownerGameObject, areaStr));
    SDOSink.PushString(sink, "Slot " + slotIndex, "EMPTY");
    this.Debug_SetESSlotData(slotIndex, areaStr, ownerGameObject);
  }

  public final const func Debug_SetESSlotData(slotIndex: Int32, areaStr: String, ownerGameObject: wref<GameObject>) -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, EquipmentSystem.ComposeSDORootPath(ownerGameObject, areaStr + "/Slot " + slotIndex));
  }

  public final const func Debug_FillESSlotData(slotIndex: Int32, area: gamedataEquipmentArea, itemID: ItemID, ownerGameObject: wref<GameObject>) -> Void {
    this.Debug_FillESSlotData(slotIndex, EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(area))), itemID, ownerGameObject);
  }

  public final const func Debug_FillESSlotData(slotIndex: Int32, areaStr: String, itemID: ItemID, ownerGameObject: wref<GameObject>) -> Void {
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(this.GetGameInstance()).CreateSink();
    SDOSink.SetRoot(sink, EquipmentSystem.ComposeSDORootPath(ownerGameObject, areaStr));
    SDOSink.PushString(sink, "Slot " + slotIndex, TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)));
    SDOSink.SetRoot(sink, EquipmentSystem.ComposeSDORootPath(ownerGameObject, areaStr + "/Slot " + slotIndex));
    SDOSink.PushString(sink, "Item: ", TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)));
  }

  private final func OnEquipmentSystemWeaponManipulationRequest(request: ref<EquipmentSystemWeaponManipulationRequest>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnEquipmentSystemWeaponManipulationRequest(request);
  }

  private final func OnSetActiveItemInEquipmentArea(request: ref<SetActiveItemInEquipmentArea>) -> Void {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(request.owner);
    playerData.OnSetActiveItemInEquipmentArea(request);
  }

  public final const func GetInventoryManager(owner: wref<GameObject>) -> wref<InventoryDataManagerV2> {
    let playerData: ref<EquipmentSystemPlayerData> = this.GetPlayerData(owner);
    return playerData.GetInventoryManager();
  }
}
