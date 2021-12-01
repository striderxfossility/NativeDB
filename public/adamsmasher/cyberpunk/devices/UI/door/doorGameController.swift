
public class DoorInkGameController extends DeviceInkGameControllerBase {

  private let m_doorStaturTextWidget: wref<inkText>;

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_doorStaturTextWidget = this.GetWidget(n"statusTextPanel\\status_text") as inkText;
    };
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void;

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.m_doorStaturTextWidget.SetText(this.GetOwner().GetDevicePS().GetDeviceStatus());
    this.Refresh(state);
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }
}
