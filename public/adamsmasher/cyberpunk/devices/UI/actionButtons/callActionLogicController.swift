
public class CallActionWidgetController extends DeviceActionWidgetControllerBase {

  @attrib(category, "Widget Refs")
  protected edit let m_statusText: inkTextRef;

  @attrib(category, "Animations")
  @default(CallActionWidgetController, calling_animation_maelstrom)
  protected edit let m_callingAnimName: CName;

  @attrib(category, "Animations")
  @default(CallActionWidgetController, talking_animation_maelstrom)
  protected edit let m_talkingAnimName: CName;

  protected let m_status: IntercomStatus;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SActionWidgetPackage) -> Void {
    this.Initialize(gameController, widgetData);
    inkTextRef.SetLocalizedTextScript(this.m_statusText, "LocKey#279");
  }

  public func FinalizeActionExecution(executor: ref<GameObject>, action: ref<DeviceAction>) -> Void {
    let contextAction: ref<StartCall> = action as StartCall;
    if IsDefined(contextAction) {
      this.CallStarted();
    };
  }

  public final func CallStarted() -> Void {
    this.m_status = IntercomStatus.CALLING;
    this.m_targetWidget.SetInteractive(false);
    this.m_targetWidget.SetState(n"Calling");
    inkTextRef.SetLocalizedTextScript(this.m_statusText, "LocKey#2142");
    this.PlayLibraryAnimation(this.m_callingAnimName);
  }

  public final func CallPickedUp() -> Void {
    this.m_status = IntercomStatus.TALKING;
    this.m_targetWidget.SetState(n"Talking");
    inkTextRef.SetLocalizedTextScript(this.m_statusText, "LocKey#312");
    this.PlayLibraryAnimation(this.m_talkingAnimName);
  }

  public final func CallEnded() -> Void {
    this.m_status = IntercomStatus.CALL_ENDED;
    inkTextRef.SetLocalizedTextScript(this.m_statusText, "LocKey#2143");
  }

  public final func CallMissed() -> Void {
    this.m_status = IntercomStatus.CALL_MISSED;
    inkTextRef.SetLocalizedTextScript(this.m_statusText, "LocKey#2145");
  }

  public final func ResetIntercom() -> Void {
    this.m_status = IntercomStatus.DEFAULT;
    this.m_targetWidget.SetInteractive(true);
    this.m_targetWidget.SetState(n"Default");
    inkTextRef.SetLocalizedTextScript(this.m_statusText, "LocKey#279");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    if Equals(this.m_status, IntercomStatus.DEFAULT) {
      this.m_targetWidget.SetState(n"Hover");
    };
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    if Equals(this.m_status, IntercomStatus.DEFAULT) {
      this.m_targetWidget.SetState(n"Default");
    };
  }
}
