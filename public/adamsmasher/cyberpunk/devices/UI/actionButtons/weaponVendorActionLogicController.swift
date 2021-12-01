
public class WeaponVendorActionWidgetController extends DeviceActionWidgetControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_buttonText: inkTextRef;

  @attrib(category, "Widget Refs")
  protected edit let m_standardButtonContainer: inkWidgetRef;

  @attrib(category, "Widget Refs")
  protected edit let m_hoveredButtonContainer: inkWidgetRef;

  private let m_buttonState: ButtonStatus;

  private let m_hoverState: HoverStatus;

  private let m_isBusy: Bool;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SActionWidgetPackage) -> Void {
    let action: ref<DispenceItemFromVendor>;
    this.Initialize(gameController, widgetData);
    action = widgetData.action as DispenceItemFromVendor;
    inkWidgetRef.SetVisible(this.m_hoveredButtonContainer, false);
    if IsDefined(action) {
      inkTextRef.SetLocalizedTextScript(this.m_buttonText, "LocKey#48362");
    };
  }

  public func FinalizeActionExecution(executor: ref<GameObject>, action: ref<DeviceAction>) -> Void {
    let contextAction: ref<DispenceItemFromVendor> = action as DispenceItemFromVendor;
    if IsDefined(contextAction) {
      this.m_isBusy = true;
    };
  }

  public final func Processing() -> Void {
    this.m_buttonState = ButtonStatus.PROCESSING;
    this.m_targetWidget.SetInteractive(true);
    inkTextRef.SetLocalizedTextScript(this.m_buttonText, "LocKey#49630");
    if Equals(this.m_hoverState, HoverStatus.DEFAULT) {
      this.m_targetWidget.SetState(n"Processing");
    } else {
      this.m_targetWidget.SetState(n"ProcessingHover");
    };
  }

  public final func NoMoney() -> Void {
    this.m_buttonState = ButtonStatus.DISABLED;
    inkTextRef.SetLocalizedTextScript(this.m_buttonText, "LocKey#48361");
    if Equals(this.m_hoverState, HoverStatus.DEFAULT) {
      this.m_targetWidget.SetState(n"Disabled");
    } else {
      this.m_targetWidget.SetState(n"DisabledHover");
    };
  }

  public final func IsProcessing() -> Bool {
    return this.m_isBusy;
  }

  public final func ResetToDefault() -> Void {
    this.m_buttonState = ButtonStatus.DEFAULT;
    this.m_targetWidget.SetInteractive(true);
    inkTextRef.SetLocalizedTextScript(this.m_buttonText, "LocKey#48362");
    this.m_isBusy = false;
    if Equals(this.m_hoverState, HoverStatus.DEFAULT) {
      this.m_targetWidget.SetState(n"Default");
    } else {
      this.m_targetWidget.SetState(n"Hover");
    };
  }

  protected cb func OnProcessed(e: ref<inkAnimProxy>) -> Bool {
    e.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnProcessed");
    this.ResetToDefault();
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_standardButtonContainer, false);
    inkWidgetRef.SetVisible(this.m_hoveredButtonContainer, true);
    this.m_hoverState = HoverStatus.HOVER;
    if Equals(this.m_buttonState, ButtonStatus.DEFAULT) {
      this.m_targetWidget.SetState(n"Hover");
    } else {
      if Equals(this.m_buttonState, ButtonStatus.PROCESSING) {
        this.m_targetWidget.SetState(n"ProcessingHover");
      } else {
        this.m_targetWidget.SetState(n"DisabledHover");
      };
    };
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_standardButtonContainer, true);
    inkWidgetRef.SetVisible(this.m_hoveredButtonContainer, false);
    this.m_hoverState = HoverStatus.DEFAULT;
    if Equals(this.m_buttonState, ButtonStatus.DEFAULT) {
      this.m_targetWidget.SetState(n"Default");
    } else {
      if Equals(this.m_buttonState, ButtonStatus.PROCESSING) {
        this.m_targetWidget.SetState(n"Processing");
      } else {
        this.m_targetWidget.SetState(n"Disabled");
      };
    };
  }
}
