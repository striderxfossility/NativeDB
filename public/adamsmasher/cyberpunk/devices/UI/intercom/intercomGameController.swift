
public class IntercomInkGameController extends DeviceInkGameControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_actionsList: inkWidgetRef;

  private let m_mainDisplayWidget: wref<inkVideo>;

  private let m_buttonRef: wref<CallActionWidgetController>;

  private let m_state: IntercomStatus;

  private let m_onUpdateStatusListener: ref<CallbackHandle>;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.m_mainDisplayWidget.Stop();
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_rootWidget.SetVisible(false);
    };
  }

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onUpdateStatusListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef() as IntercomBlackboardDef.Status, this, n"OnUpdateStatus");
      this.m_onGlitchingStateChangedListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this, n"OnGlitchingStateChanged");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef() as IntercomBlackboardDef.Status, this.m_onUpdateStatusListener);
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
    };
  }

  protected cb func OnUpdateStatus(value: Variant) -> Bool {
    this.m_state = FromVariant(value);
    switch this.m_state {
      case IntercomStatus.CALLING:
        this.m_buttonRef.CallStarted();
        break;
      case IntercomStatus.TALKING:
        this.m_buttonRef.CallPickedUp();
        break;
      case IntercomStatus.CALL_ENDED:
        this.m_buttonRef.CallEnded();
        break;
      case IntercomStatus.CALL_MISSED:
        this.m_buttonRef.CallMissed();
        break;
      default:
        this.m_buttonRef.ResetIntercom();
    };
    this.Refresh(this.GetOwner().GetDeviceState());
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    if Equals(this.m_state, IntercomStatus.DEFAULT) {
      this.RequestActionWidgetsUpdate();
    };
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

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    if Equals(this.m_state, IntercomStatus.DEFAULT) {
      this.UpdateActionWidgets(widgetsData);
      inkWidgetRef.SetVisible(this.m_actionsList, true);
      i = 0;
      while i < ArraySize(widgetsData) {
        if Equals(widgetsData[i].wasInitalized, true) {
          widget = this.GetActionWidget(widgetsData[i]);
          if widget == null {
            this.CreateActionWidgetAsync(inkWidgetRef.Get(this.m_actionsList), widgetsData[i]);
          } else {
            this.InitializeActionWidget(widget, widgetsData[i]);
          };
        };
        i += 1;
      };
    };
  }

  protected cb func OnActionWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    widget.SetAnchor(inkEAnchor.Centered);
    super.OnActionWidgetSpawned(widget, userData);
    this.m_buttonRef = widget.GetController() as CallActionWidgetController;
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    this.StopVideo();
    if Equals(glitchData.state, EGlitchState.DEFAULT) {
      this.PlayVideo(r"base\\movies\\misc\\generic_noise_white.bk2", true, n"");
    } else {
      this.PlayVideo(r"base\\movies\\misc\\distraction_generic.bk2", true, n"");
    };
  }

  private func StopGlitchingScreen() -> Void {
    this.StopVideo();
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

  private final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
  }

  private final func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }
}
