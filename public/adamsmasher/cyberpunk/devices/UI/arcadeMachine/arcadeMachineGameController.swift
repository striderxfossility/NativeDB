
public class ArcadeMachineInkGameController extends DeviceInkGameControllerBase {

  private let m_defaultUI: wref<inkCanvas>;

  private let m_mainDisplayWidget: wref<inkVideo>;

  private let m_counterWidget: wref<inkText>;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    if IsDefined(this.m_mainDisplayWidget) {
      this.m_mainDisplayWidget.Stop();
    };
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_defaultUI = this.GetWidget(n"default_ui") as inkCanvas;
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_rootWidget.SetVisible(false);
    };
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void;

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    switch state {
      case EDeviceStatus.ON:
        this.TurnOn();
        break;
      case EDeviceStatus.OFF:
        this.TurnOff();
        break;
      case EDeviceStatus.UNPOWERED:
        break;
      case EDeviceStatus.DISABLED:
        break;
      default:
    };
    this.Refresh(state);
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onGlitchingStateChangedListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this, n"OnGlitchingStateChanged");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected cb func OnTimeToDepartChanged(value: String) -> Bool {
    this.m_counterWidget.SetTextDirect(value);
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    this.m_defaultUI.SetVisible(false);
    if Equals(glitchData.state, EGlitchState.DEFAULT) {
    } else {
      this.StopVideo();
      this.PlayVideo(r"base\\movies\\misc\\distraction_generic.bk2", true, n"");
    };
  }

  private func StopGlitchingScreen() -> Void {
    this.StopVideo();
    this.m_defaultUI.SetVisible(true);
    this.Refresh(this.GetOwner().GetDeviceState());
  }

  public final func PlayVideo(videoPath: ResRef, looped: Bool, audioEvent: CName) -> Void {
    if IsDefined(this.m_mainDisplayWidget) {
      this.m_mainDisplayWidget.SetVideoPath(videoPath);
      this.m_mainDisplayWidget.SetLoop(looped);
      if IsNameValid(audioEvent) {
        this.m_mainDisplayWidget.SetAudioEvent(audioEvent);
      };
      this.m_mainDisplayWidget.Play();
    };
  }

  public final func StopVideo() -> Void {
    if IsDefined(this.m_mainDisplayWidget) {
      this.m_mainDisplayWidget.Stop();
    };
  }

  public final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  public final func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.PlayVideo((this.GetOwner() as ArcadeMachine).GetArcadeGame(), true, n"");
  }
}
