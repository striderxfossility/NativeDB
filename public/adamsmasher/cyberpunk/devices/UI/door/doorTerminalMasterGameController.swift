
public class DoorTerminalMasterInkGameControllerBase extends MasterDeviceInkGameControllerBase {

  protected let m_currentlyActiveDevices: array<PersistentID>;

  protected func UpdateThumbnailWidgets(widgetsData: array<SThumbnailWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    if ArraySize(widgetsData) == 1 {
      ArrayPush(this.m_currentlyActiveDevices, widgetsData[i].ownerID);
      this.RequestDeviceWidgetsUpdate(this.m_currentlyActiveDevices);
    } else {
      i = 0;
      while i < ArraySize(widgetsData) {
        widget = this.GetThumbnailWidget(widgetsData[i]);
        if widget == null {
          this.CreateThumbnailWidgetAsync(this.GetRootWidget(), widgetsData[i]);
        } else {
          this.InitializeThumbnailWidget(widget, widgetsData[i]);
        };
        i += 1;
      };
      this.GoUp();
    };
  }

  protected func UpdateDeviceWidgets(widgetsData: array<SDeviceWidgetPackage>) -> Void {
    let element: SBreadcrumbElementData;
    let i: Int32;
    let widget: ref<inkWidget>;
    this.UpdateDeviceWidgets(widgetsData);
    ArrayClear(this.m_currentlyActiveDevices);
    i = 0;
    while i < ArraySize(widgetsData) {
      if !this.IsOwner(widgetsData[i].ownerID) {
        ArrayPush(this.m_currentlyActiveDevices, widgetsData[i].ownerID);
      };
      widget = this.GetDeviceWidget(widgetsData[i]);
      if widget == null {
        this.CreateDeviceWidgetAsync(this.GetRootWidget(), widgetsData[i]);
      } else {
        this.InitializeDeviceWidget(widget, widgetsData[i]);
      };
      i += 1;
    };
    element = this.GetCurrentBreadcrumbElement();
    if NotEquals(element.elementName, "device") {
      element.elementName = "device";
      this.GoDown(element);
    };
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.RequestDeviceWidgetsUpdate(this.m_currentlyActiveDevices);
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

  protected func ResolveBreadcrumbLevel() -> Void {
    let element: SBreadcrumbElementData = this.GetCurrentBreadcrumbElement();
    if !IsStringValid(element.elementName) {
      this.RequestThumbnailWidgetsUpdate();
    } else {
      if Equals(element.elementName, "device") {
        this.RequestDeviceWidgetsUpdate(this.m_currentlyActiveDevices);
      };
    };
  }

  protected final func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.ResolveBreadcrumbLevel();
  }

  protected final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
  }
}
