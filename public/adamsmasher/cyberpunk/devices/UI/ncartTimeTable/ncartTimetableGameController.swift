
public class NcartTimetableInkGameController extends DeviceInkGameControllerBase {

  private let m_defaultUI: wref<inkCanvas>;

  private let m_mainDisplayWidget: wref<inkVideo>;

  private let m_counterWidget: wref<inkText>;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  private let m_onTimeToDepartChangedListener: ref<CallbackHandle>;

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.m_mainDisplayWidget.Stop();
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_defaultUI = this.GetWidget(n"default_ui") as inkCanvas;
      this.m_counterWidget = this.GetWidget(n"default_ui/counter_text") as inkText;
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_rootWidget.SetVisible(false);
    };
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void;

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.RequestActionWidgetsUpdate();
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
      this.m_onTimeToDepartChangedListener = blackboard.RegisterListenerInt(this.GetOwner().GetBlackboardDef() as NcartTimetableBlackboardDef.TimeToDepart, this, n"OnTimeToDepartChanged");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
      blackboard.UnregisterListenerInt(this.GetOwner().GetBlackboardDef() as NcartTimetableBlackboardDef.TimeToDepart, this.m_onTimeToDepartChangedListener);
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected cb func OnActionWidgetsUpdate(value: Variant) -> Bool {
    let widgets: array<SActionWidgetPackage> = FromVariant(value);
    this.UpdateActionWidgets(widgets);
  }

  protected cb func OnTimeToDepartChanged(value: Int32) -> Bool {
    let textParams: ref<inkTextParams>;
    if this.m_counterWidget != null {
      textParams = new inkTextParams();
      textParams.AddTime("TIMER", value);
      this.m_counterWidget.SetLocalizedTextScript("LocKey#48343", textParams);
    };
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    this.StopVideo();
    this.m_defaultUI.SetVisible(false);
    if Equals(glitchData.state, EGlitchState.DEFAULT) {
      this.PlayVideo(r"base\\movies\\misc\\generic_noise_white.bk2", true, n"");
    } else {
      this.PlayVideo(r"base\\movies\\misc\\distraction_generic.bk2", true, n"");
    };
  }

  private func StopGlitchingScreen() -> Void {
    this.StopVideo();
    this.m_defaultUI.SetVisible(true);
  }

  public final func PlayVideo(videoPath: ResRef, looped: Bool, audioEvent: CName) -> Void {
    this.m_mainDisplayWidget.SetVideoPath(videoPath);
    this.m_mainDisplayWidget.SetLoop(looped);
    if IsNameValid(audioEvent) {
      this.m_mainDisplayWidget.SetAudioEvent(audioEvent);
    };
    this.m_mainDisplayWidget.Play();
  }

  public final func StopVideo() -> Void {
    this.m_mainDisplayWidget.Stop();
  }

  public final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
    this.m_mainDisplayWidget.UnregisterFromCallback(n"OnVideoFinished", this, n"OnVideoFinished");
  }

  public final func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
  }
}
