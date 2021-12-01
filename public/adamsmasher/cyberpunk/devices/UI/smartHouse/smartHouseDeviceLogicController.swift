
public class SmartHouseDeviceWidgetController extends DeviceWidgetControllerBase {

  private let m_interiorManagerSlot: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_interiorManagerSlot = this.GetWidget(n"device_main_panel/actions_canvas/mainActionPanel/interiorManager");
  }

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SDeviceWidgetPackage) -> Void {
    let actionWidget: ref<inkWidget>;
    let widgetPackage: SActionWidgetPackage;
    let i: Int32 = ArraySize(widgetData.actionWidgets) - 1;
    while i >= 0 {
      if IsDefined(widgetData.actionWidgets[i].action as OpenInteriorManager) {
        widgetPackage = widgetData.actionWidgets[i];
        ArrayErase(widgetData.actionWidgets, i);
      };
      i -= 1;
    };
    this.Initialize(gameController, widgetData);
    if IsDefined(widgetPackage.action) && IsDefined(this.m_interiorManagerSlot) {
      actionWidget = this.GetActionWidget(widgetPackage, gameController);
      if actionWidget == null {
        this.CreateActionWidgetAsync(gameController, this.m_interiorManagerSlot, widgetPackage);
      } else {
        this.InitializeActionWidget(gameController, actionWidget, widgetPackage);
      };
    };
  }
}
