
public abstract class TriggerModeLogicController extends inkLogicController {

  public func OnTriggerModeChanged(value: ref<TriggerMode_Record>) -> Void;
}

public abstract class AmmoLogicController extends inkLogicController {

  protected let m_count: Uint32;

  protected let m_capacity: Uint32;

  public func OnMagazineAmmoCountChanged(value: Uint32) -> Void {
    this.m_count = value;
  }

  public func OnMagazineAmmoCapacityChanged(value: Uint32) -> Void {
    this.m_capacity = value;
  }
}

public abstract class ChargeLogicController extends inkLogicController {

  public func OnChargeChanged(value: Float) -> Void;
}

public class weaponIndicatorController extends inkHUDGameController {

  public edit const let m_triggerModeControllers: array<CName>;

  public edit const let m_ammoLogicControllers: array<CName>;

  public edit const let m_chargeLogicControllers: array<CName>;

  private let m_triggerModeInstances: array<wref<TriggerModeLogicController>>;

  private let m_ammoLogicInstances: array<wref<AmmoLogicController>>;

  private let m_chargeLogicInstances: array<wref<ChargeLogicController>>;

  private let bb: wref<IBlackboard>;

  private let m_blackboard: wref<IBlackboard>;

  private let m_onCharge: ref<CallbackHandle>;

  private let m_onTriggerMode: ref<CallbackHandle>;

  private let m_onMagazineAmmoCount: ref<CallbackHandle>;

  private let m_onMagazineAmmoCapacity: ref<CallbackHandle>;

  private let m_BufferedRosterData: ref<SlotDataHolder>;

  private let m_ActiveWeapon: SlotWeaponData;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let ammoLogicInstance: wref<AmmoLogicController>;
    let chargeLogicInstance: wref<ChargeLogicController>;
    let count: Int32;
    let game: GameInstance;
    let i: Int32;
    let id: TweakDBID;
    let item: ref<ItemObject>;
    let triggerModeInstance: wref<TriggerModeLogicController>;
    let weapon: ref<WeaponObject>;
    let player: ref<PlayerPuppet> = playerPuppet as PlayerPuppet;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(playerPuppet as PlayerPuppet);
    item = this.GetOwnerEntity() as ItemObject;
    game = item.GetGame();
    player = GetPlayer(game);
    id = t"AttachmentSlots.WeaponRight";
    weapon = GameInstance.GetTransactionSystem(game).GetItemInSlot(player, id) as WeaponObject;
    this.m_blackboard = weapon.GetSharedData();
    this.bb = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_EquipmentData);
    count = ArraySize(this.m_triggerModeControllers);
    i = 0;
    while i < count {
      triggerModeInstance = this.GetController(this.m_triggerModeControllers[i]) as TriggerModeLogicController;
      if IsDefined(triggerModeInstance) {
        ArrayPush(this.m_triggerModeInstances, triggerModeInstance);
      };
      i += 1;
    };
    count = ArraySize(this.m_ammoLogicControllers);
    i = 0;
    while i < count {
      ammoLogicInstance = this.GetController(this.m_ammoLogicControllers[i]) as AmmoLogicController;
      if IsDefined(ammoLogicInstance) {
        ArrayPush(this.m_ammoLogicInstances, ammoLogicInstance);
      };
      i += 1;
    };
    count = ArraySize(this.m_chargeLogicControllers);
    i = 0;
    while i < count {
      chargeLogicInstance = this.GetController(this.m_chargeLogicControllers[i]) as ChargeLogicController;
      if IsDefined(chargeLogicInstance) {
        ArrayPush(this.m_chargeLogicInstances, chargeLogicInstance);
      };
      i += 1;
    };
    if Cast(ArraySize(this.m_triggerModeInstances)) {
      this.m_onTriggerMode = this.m_blackboard.RegisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this, n"OnTriggerMode");
      this.OnTriggerMode(ToVariant(weapon.GetCurrentTriggerMode()));
    };
    if Cast(ArraySize(this.m_ammoLogicInstances)) {
      this.m_onMagazineAmmoCount = this.bb.RegisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this, n"OnMagazineAmmoCapacity");
      this.bb.SignalVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData);
    };
    if Cast(ArraySize(this.m_chargeLogicInstances)) {
      this.m_onCharge = this.m_blackboard.RegisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this, n"OnCharge");
      this.m_blackboard.SignalFloat(GetAllBlackboardDefs().Weapon.Charge);
    };
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    if Cast(ArraySize(this.m_triggerModeInstances)) && IsDefined(this.m_onTriggerMode) {
      this.m_blackboard.UnregisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this.m_onTriggerMode);
    };
    if Cast(ArraySize(this.m_ammoLogicInstances)) && IsDefined(this.m_onMagazineAmmoCount) {
      this.bb.UnregisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this.m_onMagazineAmmoCount);
    };
    if Cast(ArraySize(this.m_chargeLogicInstances)) && IsDefined(this.m_onCharge) {
      this.m_blackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this.m_onCharge);
    };
  }

  protected cb func OnInitialize() -> Bool;

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnCharge(value: Float) -> Bool {
    let count: Int32 = ArraySize(this.m_chargeLogicInstances);
    let i: Int32 = 0;
    while i < count {
      this.m_chargeLogicInstances[i].OnChargeChanged(value);
      i += 1;
    };
  }

  protected cb func OnTriggerMode(value: Variant) -> Bool {
    let count: Int32 = ArraySize(this.m_triggerModeInstances);
    let i: Int32 = 0;
    while i < count {
      this.m_triggerModeInstances[i].OnTriggerModeChanged(FromVariant(value));
      i += 1;
    };
  }

  protected cb func OnMagazineAmmoCount(value: Uint32) -> Bool {
    let count: Int32 = ArraySize(this.m_ammoLogicInstances);
    let i: Int32 = 0;
    while i < count {
      this.m_ammoLogicInstances[i].OnMagazineAmmoCountChanged(value);
      i += 1;
    };
  }

  protected cb func OnMagazineAmmoCapacity(value: Variant) -> Bool {
    let count: Int32;
    let i: Int32;
    this.m_BufferedRosterData = FromVariant(value);
    let currentData: SlotWeaponData = this.m_BufferedRosterData.weapon;
    if ItemID.IsValid(currentData.weaponID) {
      this.m_ActiveWeapon = currentData;
      count = ArraySize(this.m_ammoLogicInstances);
      i = 0;
      while i < count {
        this.m_ammoLogicInstances[i].OnMagazineAmmoCapacityChanged(Cast(this.m_ActiveWeapon.ammoCurrent));
        i += 1;
      };
    };
  }
}
