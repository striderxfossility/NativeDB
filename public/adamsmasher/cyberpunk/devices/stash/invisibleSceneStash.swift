
public class InvisibleSceneStash extends Device {

  public let m_itemSlots: array<gamedataEquipmentArea>;

  public let m_equipmentData: ref<EquipmentSystemPlayerData>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as InvisibleSceneStashController;
  }

  protected cb func OnGameAttached() -> Bool {
    ArrayPush(this.m_itemSlots, gamedataEquipmentArea.Face);
    ArrayPush(this.m_itemSlots, gamedataEquipmentArea.Head);
    ArrayPush(this.m_itemSlots, gamedataEquipmentArea.Feet);
    ArrayPush(this.m_itemSlots, gamedataEquipmentArea.Legs);
    ArrayPush(this.m_itemSlots, gamedataEquipmentArea.InnerChest);
    ArrayPush(this.m_itemSlots, gamedataEquipmentArea.OuterChest);
    ArrayPush(this.m_itemSlots, gamedataEquipmentArea.Outfit);
  }

  protected cb func OnQuestUndressPlayer(evt: ref<UndressPlayer>) -> Bool {
    let i: Int32;
    let id: ItemID;
    let itemList: array<ItemID>;
    let unequipRequest: ref<UnequipRequest>;
    if !evt.isCensored {
      ArrayPush(this.m_itemSlots, gamedataEquipmentArea.UnderwearBottom);
      ArrayPush(this.m_itemSlots, gamedataEquipmentArea.UnderwearTop);
    } else {
      ArrayRemove(this.m_itemSlots, gamedataEquipmentArea.UnderwearBottom);
      ArrayRemove(this.m_itemSlots, gamedataEquipmentArea.UnderwearTop);
    };
    this.m_equipmentData = EquipmentSystem.GetData(GetPlayer(this.GetGame()));
    unequipRequest = new UnequipRequest();
    unequipRequest.slotIndex = 0;
    i = 0;
    while i < ArraySize(this.m_itemSlots) {
      id = this.m_equipmentData.GetActiveItem(this.m_itemSlots[i]);
      if ItemID.IsValid(id) {
        ArrayPush(itemList, id);
        unequipRequest.areaType = this.m_itemSlots[i];
        this.m_equipmentData.OnUnequipRequest(unequipRequest);
      };
      i += 1;
    };
    (this.GetDevicePS() as InvisibleSceneStashControllerPS).StoreItems(itemList);
  }

  protected cb func OnQuestDressPlayer(evt: ref<DressPlayer>) -> Bool {
    let equipRequest: ref<EquipRequest>;
    let i: Int32;
    let itemList: array<ItemID>;
    if !IsDefined(this.m_equipmentData) {
      this.m_equipmentData = EquipmentSystem.GetData(GetPlayer(this.GetGame()));
    };
    itemList = (this.GetDevicePS() as InvisibleSceneStashControllerPS).GetItems();
    equipRequest = new EquipRequest();
    i = 0;
    while i < ArraySize(itemList) {
      equipRequest.itemID = itemList[i];
      equipRequest.owner = GetPlayer(this.GetGame());
      this.m_equipmentData.OnEquipRequest(equipRequest);
      i += 1;
    };
    (this.GetDevicePS() as InvisibleSceneStashControllerPS).ClearStoredItems();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }
}

public class UndressPlayer extends Event {

  public edit let isCensored: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Undress Player";
  }
}

public class DressPlayer extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Dress Player Up";
  }
}
