
public class DisarmComponent extends ScriptableComponent {

  @default(DisarmComponent, false)
  public let m_isDisarmingOngoing: Bool;

  public let m_owner: wref<GameObject>;

  public let m_requester: wref<GameObject>;

  public final func OnGameAttach() -> Void {
    this.m_owner = this.GetOwner();
  }

  protected cb func OnDisarm(evt: ref<Disarm>) -> Bool {
    if !IsDefined(evt.requester) {
      return false;
    };
    this.m_isDisarmingOngoing = true;
    this.m_requester = evt.requester;
    if this.UnequipWeapons() {
      return false;
    };
    this.DisarmOwner();
  }

  protected cb func OnArm(evt: ref<Arm>) -> Bool {
    this.ArmOwner(evt.requester);
  }

  protected cb func OnUnequipEnded(evt: ref<UnequipEnd>) -> Bool {
    if !this.m_isDisarmingOngoing {
      return false;
    };
    if evt.GetSlotID() == t"AttachmentSlots.WeaponLeft" || evt.GetSlotID() == t"AttachmentSlots.WeaponRight" {
      this.DisarmOwner();
    };
  }

  protected final func UnequipWeapons() -> Bool {
    let leftHandItem: ref<ItemObject>;
    let rightHandItem: ref<ItemObject>;
    let ts: ref<TransactionSystem> = this.GetTransactionSystem();
    if IsDefined(ts) && IsDefined(this.m_owner) {
      leftHandItem = ts.GetItemInSlot(this.m_owner, t"AttachmentSlots.WeaponLeft");
      rightHandItem = ts.GetItemInSlot(this.m_owner, t"AttachmentSlots.WeaponRight");
      if IsDefined(leftHandItem) || IsDefined(rightHandItem) {
        this.SendEquipmentSystemWeaponManipulationRequest(EquipmentManipulationAction.UnequipAll);
        return true;
      };
    };
    return false;
  }

  protected final func DisarmOwner() -> Void {
    let evt: ref<Disarm>;
    let i: Int32;
    let notification: SimpleScreenMessage;
    let weapons: array<wref<gameItemData>>;
    let ts: ref<TransactionSystem> = this.GetTransactionSystem();
    if !IsDefined(ts) {
      return;
    };
    weapons = this.GetWeapons();
    evt = new Disarm();
    evt.requester = this.m_owner;
    this.m_requester.QueueEvent(evt);
    if ArraySize(weapons) > 0 {
      i = 0;
      while i < ArraySize(weapons) {
        ts.TransferItem(this.m_owner, this.m_requester, weapons[i].GetID(), weapons[i].GetQuantity());
        i += 1;
      };
      notification.isShown = true;
      notification.duration = 3.00;
      notification.message = "LocKey#78051";
      GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(notification), true);
      this.SendEquipmentSystemClearAllWeaponSlotsRequest();
    };
    this.CleanUp();
    GameInstance.GetAutoSaveSystem(this.m_owner.GetGame()).RequestCheckpoint();
  }

  protected final func ArmOwner(requester: wref<GameObject>) -> Void {
    let notification: SimpleScreenMessage;
    let ts: ref<TransactionSystem> = this.GetTransactionSystem();
    if !IsDefined(ts) {
      return;
    };
    ts.TransferAllItems(requester, this.m_owner);
    notification.isShown = true;
    notification.duration = 3.00;
    notification.message = "LocKey#78050";
    GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(notification), true);
    GameInstance.GetAutoSaveSystem(this.m_owner.GetGame()).RequestCheckpoint();
    this.m_isDisarmingOngoing = false;
  }

  protected final func GetWeapons() -> array<wref<gameItemData>> {
    let allItems: array<wref<gameItemData>>;
    let weapons: array<wref<gameItemData>>;
    let ts: ref<TransactionSystem> = this.GetTransactionSystem();
    if IsDefined(ts) && IsDefined(this.m_owner) {
      ts.GetItemList(this.m_owner, allItems);
      RPGManager.ExtractItemsOfEquipArea(gamedataEquipmentArea.Weapon, allItems, weapons);
      RPGManager.ExtractItemsOfEquipArea(gamedataEquipmentArea.QuickSlot, allItems, weapons);
    };
    return weapons;
  }

  protected final func CleanUp() -> Void {
    this.m_requester = null;
    this.m_isDisarmingOngoing = false;
  }

  private final func GetEquipmentSystem() -> ref<EquipmentSystem> {
    let owner: ref<GameObject>;
    if this.m_owner == null {
      owner = this.GetOwner();
    } else {
      owner = this.m_owner;
    };
    return GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
  }

  private final func SendEquipmentSystemWeaponManipulationRequest(requestType: EquipmentManipulationAction, opt equipAnimType: gameEquipAnimationType) -> Void {
    let request: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    request.owner = this.m_owner;
    request.requestType = requestType;
    if NotEquals(equipAnimType, gameEquipAnimationType.Default) {
      request.equipAnimType = equipAnimType;
    };
    this.GetEquipmentSystem().QueueRequest(request);
  }

  private final func SendEquipmentSystemClearAllWeaponSlotsRequest() -> Void {
    let request: ref<ClearAllWeaponSlotsRequest> = new ClearAllWeaponSlotsRequest();
    request.owner = this.m_owner;
    this.GetEquipmentSystem().QueueRequest(request);
  }
}
