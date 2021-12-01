
public class ComputerMenuButtonController extends DeviceButtonLogicControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_counterWidget: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_notificationidget: inkWidgetRef;

  private let m_menuID: String;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.SetSelectable(true);
  }

  public func Initialize(gameController: ref<ComputerInkGameController>, widgetData: SComputerMenuButtonWidgetPackage) -> Void {
    let currentManuID: String;
    this.m_menuID = widgetData.widgetName;
    inkTextRef.SetText(this.m_displayNameWidget, widgetData.displayName);
    if widgetData.counter <= 0 {
      inkWidgetRef.SetVisible(this.m_notificationidget, false);
    } else {
      inkWidgetRef.SetVisible(this.m_notificationidget, true);
      inkTextRef.SetText(this.m_counterWidget, ToString(widgetData.counter));
    };
    if inkWidgetRef.Get(this.m_iconWidget) != null {
      inkImageRef.SetTexturePart(this.m_iconWidget, widgetData.iconID);
    };
    this.RegisterMenuCallback(gameController);
    currentManuID = gameController.GetCurrentBreadcrumbElementName();
    if IsStringValid(currentManuID) && Equals(currentManuID, this.m_menuID) {
      this.ToggleSelection(true);
    };
    this.m_isInitialized = true;
  }

  protected final func RegisterMenuCallback(gameController: ref<ComputerInkGameController>) -> Void {
    if !this.m_isInitialized {
      this.m_targetWidget.RegisterToCallback(n"OnRelease", gameController, n"OnMenuButtonCallback");
      this.RegisterAudioCallbacks(gameController);
    };
  }

  public final func GetMenuID() -> String {
    return this.m_menuID;
  }
}
