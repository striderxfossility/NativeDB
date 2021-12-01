
public class SystemDeviceWidgetController extends DeviceWidgetControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_slavesConnectedCount: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_connectedDevicesHolder: inkWidgetRef;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SDeviceWidgetPackage) -> Void {
    let systemWidgetData: ref<TerminalSystemCustomData> = widgetData.customData as TerminalSystemCustomData;
    if IsDefined(systemWidgetData) {
      inkTextRef.SetText(this.m_slavesConnectedCount, IntToString(systemWidgetData.connectedDevices));
    };
    if Equals(widgetData.widgetState, EWidgetState.ALLOWED) {
      inkWidgetRef.SetState(this.m_connectedDevicesHolder, n"Allowed");
    } else {
      if Equals(widgetData.widgetState, EWidgetState.LOCKED) {
        inkWidgetRef.SetState(this.m_connectedDevicesHolder, n"Locked");
      } else {
        if Equals(widgetData.widgetState, EWidgetState.SEALED) {
          inkWidgetRef.SetState(this.m_connectedDevicesHolder, n"Sealed");
        };
      };
    };
    this.Initialize(gameController, widgetData);
  }
}
