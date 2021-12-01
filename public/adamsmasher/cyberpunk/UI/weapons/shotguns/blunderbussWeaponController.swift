
public class blunderbussWeaponController extends inkGameController {

  private let m_chargeWidgetInitialY: Float;

  private let m_chargeWidgetSize: Vector2;

  private let m_semiAutoModeInfo: wref<inkWidget>;

  private let m_chargeModeInfo: wref<inkWidget>;

  private let m_semiAutoModeIndicator: wref<inkWidget>;

  private let m_chargeModeIndicator: wref<inkWidget>;

  private let m_shots: array<wref<inkWidget>>;

  private let m_charge: wref<inkWidget>;

  private let m_onCharge: ref<CallbackHandle>;

  private let m_onTriggerMode: ref<CallbackHandle>;

  private let m_onMagazineAmmoCount: ref<CallbackHandle>;

  private let m_blackboard: wref<IBlackboard>;

  protected cb func OnInitialize() -> Bool {
    let canvas: ref<inkCanvas>;
    let count: Int32;
    let i: Int32;
    let panel: ref<inkVerticalPanel>;
    let item: ref<ItemObject> = this.GetOwnerEntity() as ItemObject;
    let game: GameInstance = item.GetGame();
    let player: ref<PlayerPuppet> = GetPlayer(game);
    let id: TweakDBID = t"AttachmentSlots.WeaponRight";
    let weapon: ref<WeaponObject> = GameInstance.GetTransactionSystem(game).GetItemInSlot(player, id) as WeaponObject;
    this.m_blackboard = weapon.GetSharedData();
    this.m_onCharge = this.m_blackboard.RegisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this, n"OnCharge");
    this.m_onTriggerMode = this.m_blackboard.RegisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this, n"OnTriggerMode");
    this.m_onMagazineAmmoCount = this.m_blackboard.RegisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount, this, n"OnMagazineAmmoCount");
    this.m_semiAutoModeInfo = this.GetWidget(n"Panel/TriggerModeInfoCanvas/SemiAutoModeInfo");
    this.m_chargeModeInfo = this.GetWidget(n"Panel/TriggerModeInfoCanvas/ChargeModeInfo");
    this.m_semiAutoModeIndicator = this.GetWidget(n"Panel/TriggerModeIndicatorsCanvas/SemiAutoModeOn");
    this.m_chargeModeIndicator = this.GetWidget(n"Panel/TriggerModeIndicatorsCanvas/ChargeModeOn");
    this.OnTriggerMode(ToVariant(weapon.GetCurrentTriggerMode()));
    panel = this.m_semiAutoModeInfo as inkVerticalPanel;
    count = panel.GetNumChildren();
    i = 0;
    while i < count {
      canvas = panel.GetWidget(i) as inkCanvas;
      ArrayPush(this.m_shots, canvas.GetWidget(n"Value"));
      i += 1;
    };
    this.OnMagazineAmmoCount(this.m_blackboard.GetUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount));
    this.m_charge = this.GetWidget(n"Panel/TriggerModeInfoCanvas/ChargeModeInfo/Value") as inkRectangle;
    this.m_chargeWidgetSize = this.m_charge.GetSize();
    this.m_chargeWidgetInitialY = this.m_chargeWidgetSize.Y;
    this.OnCharge(this.m_blackboard.GetFloat(GetAllBlackboardDefs().Weapon.Charge));
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_blackboard.UnregisterListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this.m_onCharge);
    this.m_blackboard.UnregisterListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this.m_onTriggerMode);
    this.m_blackboard.UnregisterListenerUint(GetAllBlackboardDefs().Weapon.MagazineAmmoCount, this.m_onMagazineAmmoCount);
    ArrayClear(this.m_shots);
    this.OnCharge(1.00);
  }

  protected cb func OnCharge(value: Float) -> Bool {
    this.m_chargeWidgetSize.Y = this.m_chargeWidgetInitialY * value;
    this.m_charge.SetSize(this.m_chargeWidgetSize);
  }

  protected cb func OnTriggerMode(value: Variant) -> Bool {
    let isChargeMode: Bool = Equals(FromVariant(value).Type(), gamedataTriggerMode.Charge);
    this.m_semiAutoModeInfo.SetVisible(!isChargeMode);
    this.m_chargeModeInfo.SetVisible(isChargeMode);
    this.m_semiAutoModeIndicator.SetVisible(!isChargeMode);
    this.m_chargeModeIndicator.SetVisible(isChargeMode);
  }

  protected cb func OnMagazineAmmoCount(value: Uint32) -> Bool {
    let count: Int32 = ArraySize(this.m_shots);
    let i: Int32 = 0;
    while i < count {
      this.m_shots[i].SetVisible(i < Cast(value));
      i += 1;
    };
  }
}
