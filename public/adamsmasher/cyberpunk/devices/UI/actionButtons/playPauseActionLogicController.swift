
public class PlayPauseActionWidgetController extends NextPreviousActionWidgetController {

  @attrib(category, "Widget Refs")
  protected edit let m_playContainer: inkWidgetRef;

  @default(PlayPauseActionWidgetController, true)
  private let m_isPlaying: Bool;

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SActionWidgetPackage) -> Void {
    this.Initialize(gameController, widgetData);
    this.DetermineState();
  }

  public func FinalizeActionExecution(executor: ref<GameObject>, action: ref<DeviceAction>) -> Void {
    let contextAction: ref<TogglePlay> = action as TogglePlay;
    if !contextAction.CanPayCost(executor) {
      this.Decline();
    } else {
      this.m_isPlaying = FromVariant(contextAction.prop.first);
      this.DetermineState();
    };
  }

  public func Reset() -> Void {
    this.Reset();
    this.DetermineState();
  }

  protected final func DetermineState() -> Void {
    if this.m_isPlaying {
      inkWidgetRef.SetVisible(this.m_playContainer, false);
      inkWidgetRef.SetVisible(this.m_defaultContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_playContainer, true);
      inkWidgetRef.SetVisible(this.m_defaultContainer, false);
    };
  }
}
