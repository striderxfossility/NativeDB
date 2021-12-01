
public class IceMachineInkGameController extends DeviceInkGameControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_buttonContainer: inkWidgetRef;

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.HideActionWidgets();
    inkWidgetRef.SetVisible(this.m_buttonContainer, true);
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetActionWidget(widgetsData[i]);
      if widget == null {
        this.CreateActionWidgetAsync(inkWidgetRef.Get(this.m_buttonContainer), widgetsData[i]);
      } else {
        this.InitializeActionWidget(widget, widgetsData[i]);
      };
      i += 1;
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.Refresh(state);
    this.HideActionWidgets();
    this.RequestActionWidgetsUpdate();
  }
}
