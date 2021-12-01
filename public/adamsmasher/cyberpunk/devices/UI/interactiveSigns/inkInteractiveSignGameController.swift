
public class InteractiveSignCustomData extends WidgetCustomData {

  private let m_messege: String;

  private let m_signShape: SignShape;

  public final func SetMessege(text: String) -> Void {
    this.m_messege = text;
  }

  public final func GetMessege() -> String {
    return this.m_messege;
  }

  public final func SetShape(shape: SignShape) -> Void {
    this.m_signShape = shape;
  }

  public final func GetShape() -> SignShape {
    return this.m_signShape;
  }
}

public class InteractiveSignInkGameController extends DeviceInkGameControllerBase {

  public func UpdateDeviceWidgets(widgetsData: array<SDeviceWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.UpdateDeviceWidgets(widgetsData);
    i = 0;
    while i < ArraySize(widgetsData) {
      widget = this.GetDeviceWidget(widgetsData[i]);
      if widget == null {
        this.CreateDeviceWidgetAsync(this.GetRootWidget(), widgetsData[i]);
      } else {
        this.InitializeDeviceWidget(widget, widgetsData[i]);
      };
      i += 1;
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    if Equals(state, this.m_cashedState) {
      return;
    };
    if Equals(state, EDeviceStatus.ON) {
      this.TurnON();
    } else {
      this.TurnOFF();
    };
    this.Refresh(state);
  }

  private final func TurnON() -> Void {
    this.RequestDeviceWidgetsUpdate();
    this.GetRootWidget().SetVisible(true);
  }

  private final func TurnOFF() -> Void {
    this.GetRootWidget().SetVisible(false);
  }
}
