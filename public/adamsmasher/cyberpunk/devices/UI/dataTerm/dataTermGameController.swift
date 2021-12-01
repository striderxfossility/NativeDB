
public class DataTermInkGameController extends DeviceInkGameControllerBase {

  private let m_fcPointsPanel: wref<inkHorizontalPanel>;

  private let m_districtText: wref<inkText>;

  private let m_pointText: wref<inkText>;

  private let m_point: wref<FastTravelPointData>;

  private let m_onFastTravelPointUpdateListener: ref<CallbackHandle>;

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_fcPointsPanel = this.GetWidget(n"safeArea\\PointsButtonsPanel") as inkHorizontalPanel;
      this.m_districtText = this.GetWidget(n"safeArea\\district_name_holder\\district_name") as inkText;
      this.m_pointText = this.GetWidget(n"safeArea\\point_name_holder\\point_name") as inkText;
    };
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.UpdateActionWidgets(widgetsData);
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetActionWidget(widgetsData[i]);
      if widget == null {
        this.CreateActionWidgetAsync(this.m_fcPointsPanel, widgetsData[i]);
      } else {
        this.InitializeActionWidget(widget, widgetsData[i]);
      };
      i += 1;
    };
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onFastTravelPointUpdateListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as DataTermDeviceBlackboardDef.fastTravelPoint, this, n"OnFastTravelPointUpdate");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as DataTermDeviceBlackboardDef.fastTravelPoint, this.m_onFastTravelPointUpdateListener);
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    switch state {
      case EDeviceStatus.ON:
        this.TurnOn();
        break;
      case EDeviceStatus.OFF:
        this.TurnOff();
        break;
      case EDeviceStatus.UNPOWERED:
        this.TurnOff();
        break;
      case EDeviceStatus.DISABLED:
        this.TurnOff();
        break;
      default:
    };
    this.Refresh(state);
  }

  protected final func TurnOn() -> Void {
    this.GetRootWidget().SetVisible(true);
    this.RequestActionWidgetsUpdate();
    if this.m_point == null {
      this.m_point = (this.GetOwner() as DataTerm).GetFastravelPointData();
    };
    this.UpdatePointText();
  }

  protected final func TurnOff() -> Void {
    this.GetRootWidget().SetVisible(false);
  }

  protected cb func OnFastTravelPointUpdate(value: Variant) -> Bool {
    let point: ref<FastTravelPointData> = FromVariant(value);
    this.m_point = point;
    this.UpdatePointText();
  }

  private final func UpdatePointText() -> Void {
    let districtName: String;
    let pointName: String;
    if !this.GetFastTravelSystem().IsFastTravelEnabled() {
      pointName = "LocKey#20482";
    } else {
      if this.m_point != null {
        pointName = this.m_point.GetPointDisplayName();
      };
    };
    if this.m_point != null {
      districtName = this.m_point.GetDistrictDisplayName();
    };
    this.m_districtText.SetLocalizedTextScript(districtName);
    this.m_pointText.SetLocalizedTextScript(pointName);
  }

  protected cb func OnActionWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    widget.SetInteractive(true);
    super.OnActionWidgetSpawned(widget, userData);
  }

  private final func GetFastTravelSystem() -> ref<FastTravelSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetOwner().GetGame()).Get(n"FastTravelSystem") as FastTravelSystem;
  }
}
