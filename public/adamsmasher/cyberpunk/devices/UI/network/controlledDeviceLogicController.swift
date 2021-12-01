
public class ControlledDeviceLogicController extends inkLogicController {

  private let m_deviceIcon: wref<inkImage>;

  private let m_activeBg: wref<inkRectangle>;

  protected cb func OnInitialize() -> Bool {
    this.m_deviceIcon = this.GetWidget(n"device_icon") as inkImage;
    this.m_activeBg = this.GetWidget(n"activeBg") as inkRectangle;
    this.m_deviceIcon.SetVisible(true);
    this.m_activeBg.SetVisible(true);
  }

  public func Initialize(gameController: ref<ControlledDevicesInkGameController>, widgetData: SWidgetPackage) -> Void {
    let customData: ref<ControlledDeviceData> = widgetData.customData as ControlledDeviceData;
    if IsDefined(customData) && customData.m_isActive {
      this.m_deviceIcon.SetState(n"Active");
      this.m_activeBg.SetState(n"Active");
    } else {
      this.m_deviceIcon.SetState(n"Default");
      this.m_activeBg.SetState(n"Default");
    };
  }
}
