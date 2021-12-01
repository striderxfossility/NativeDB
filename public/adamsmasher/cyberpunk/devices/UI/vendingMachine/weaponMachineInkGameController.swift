
public class WeaponMachineInkGameController extends VendingMachineInkGameController {

  private let m_buttonRef: wref<WeaponVendorActionWidgetController>;

  protected cb func OnUpdateStatus(value: Variant) -> Bool {
    this.m_state = FromVariant(value);
    switch this.m_state {
      case PaymentStatus.IN_PROGRESS:
        this.m_buttonRef.Processing();
        this.Processing();
        break;
      case PaymentStatus.NO_MONEY:
        this.m_buttonRef.NoMoney();
        this.NoMoney();
        break;
      default:
        this.m_buttonRef.ResetToDefault();
    };
    this.Refresh(this.GetOwner().GetDeviceState());
  }

  private final func Processing() -> Void {
    inkTextRef.SetLocalizedTextScript(this.m_priceText, "LocKey#45353");
    this.m_rootWidget.SetState(n"Processing");
  }

  private final func NoMoney() -> Void {
    this.m_rootWidget.SetState(n"Disabled");
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let action: ref<DispenceItemFromVendor>;
    let textParams: ref<inkTextParams>;
    let widget: ref<inkWidget>;
    if !IsDefined(this.m_buttonRef) || IsDefined(this.m_buttonRef) && !this.m_buttonRef.IsProcessing() {
      this.HideActionWidgets();
      this.m_rootWidget.SetState(n"Default");
      inkWidgetRef.SetVisible(this.m_ActionsPanel, true);
      if ArraySize(widgetsData) > 0 {
        widget = this.GetActionWidget(widgetsData[0]);
        action = widgetsData[0].action as DispenceItemFromVendor;
        if IsDefined(action) {
          textParams = new inkTextParams();
          textParams.AddNumber("COST", action.GetPrice());
          textParams.AddLocalizedString("ED", "LocKey#884");
          inkTextRef.SetLocalizedTextScript(this.m_priceText, "LocKey#45350", textParams);
        };
        if widget == null {
          this.CreateActionWidgetAsync(inkWidgetRef.Get(this.m_ActionsPanel), widgetsData[0]);
        } else {
          this.InitializeActionWidget(widget, widgetsData[0]);
        };
      };
    };
  }

  protected cb func OnActionWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    super.OnActionWidgetSpawned(widget, userData);
    this.m_buttonRef = widget.GetController() as WeaponVendorActionWidgetController;
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.Refresh(state);
    this.HideActionWidgets();
    this.RequestActionWidgetsUpdate();
  }
}
