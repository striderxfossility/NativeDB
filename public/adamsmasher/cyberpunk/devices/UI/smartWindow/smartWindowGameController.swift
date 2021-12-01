
public class SmartWindowInkGameController extends ComputerInkGameController {

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func InitializeMainLayout() -> Void {
    if !TDBID.IsValid(this.m_layoutID) {
      this.m_layoutID = t"DevicesUIDefinitions.SmartWindowLayoutWidget";
    };
    this.InitializeMainLayout();
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    if Equals(state, this.m_cashedState) {
      return;
    };
    this.Refresh(state);
  }

  protected func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.RequestActionWidgetsUpdate();
    this.ShowMails();
    this.ShowNewsfeed();
    this.ShowDevices();
  }

  protected func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
    this.m_devicesMenuInitialized = false;
  }

  public func GetMainLayoutController() -> ref<ComputerMainLayoutWidgetController> {
    return this.m_mainLayout.GetController() as ComputerMainLayoutWidgetController;
  }

  public func UpdateMailsWidgets(widgetsData: array<SDocumentWidgetPackage>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(widgetsData) {
      widgetsData[i].placement = EWidgetPlacementType.FLOATING;
      i += 1;
    };
    this.InitializeMails(widgetsData);
  }

  public func UpdateFilesWidgets(widgetsData: array<SDocumentWidgetPackage>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(widgetsData) {
      widgetsData[i].placement = EWidgetPlacementType.FLOATING;
      i += 1;
    };
    this.InitializeFiles(widgetsData);
  }
}
