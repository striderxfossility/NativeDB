
public class ConfessionalInkGameController extends DeviceInkGameControllerBase {

  private let m_defaultUI: wref<inkCanvas>;

  private let m_mainDisplayWidget: wref<inkVideo>;

  private let m_messegeWidget: wref<inkText>;

  private let m_defaultTextWidget: wref<inkText>;

  private let m_actionsList: wref<inkWidget>;

  private let m_RunningAnimation: ref<inkAnimProxy>;

  private let m_isConfessing: Bool;

  private let m_onGlitchingStateChangedListener: ref<CallbackHandle>;

  private let m_onConfessListener: ref<CallbackHandle>;

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.m_mainDisplayWidget.Stop();
  }

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_defaultUI = this.GetWidget(n"default_ui") as inkCanvas;
      this.m_messegeWidget = this.GetWidget(n"default_ui/messege_text") as inkText;
      this.m_defaultTextWidget = this.GetWidget(n"default_ui/default_text") as inkText;
      this.m_mainDisplayWidget = this.GetWidget(n"main_display") as inkVideo;
      this.m_actionsList = this.GetWidget(n"default_ui/actions_list");
      this.m_rootWidget.SetVisible(false);
      this.m_rootWidget.SetAnchor(inkEAnchor.Fill);
      this.m_messegeWidget.SetVisible(false);
    };
  }

  public func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void {
    let i: Int32;
    let widget: ref<inkWidget>;
    this.UpdateActionWidgets(widgetsData);
    i = 0;
    while i < ArraySize(widgetsData) {
      if Equals(widgetsData[i].wasInitalized, true) {
        widget = this.GetActionWidget(widgetsData[i]);
        if widget == null {
          this.CreateActionWidgetAsync(this.m_actionsList, widgetsData[i]);
        } else {
          this.InitializeActionWidget(widget, widgetsData[i]);
        };
      };
      i += 1;
    };
  }

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
      this.m_onConfessListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef() as ConfessionalBlackboardDef.IsConfessing, this, n"OnConfess");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingStateChangedListener);
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef() as ConfessionalBlackboardDef.IsConfessing, this.m_onConfessListener);
    };
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  private func StartGlitchingScreen(glitchData: GlitchData) -> Void {
    if Equals(glitchData.state, EGlitchState.DEFAULT) {
    } else {
      this.ResetConfessionState();
      this.StopVideo();
      this.m_defaultUI.SetVisible(false);
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

  private final func ResetConfessionState() -> Void {
    if IsDefined(this.m_RunningAnimation) && this.m_RunningAnimation.IsPlaying() {
      this.m_RunningAnimation.Stop();
      this.m_actionsList.SetVisible(true);
      if this.m_isConfessing {
        this.StopVideo();
      };
    };
  }

  private final func PlayConfessMessegeAnimation() -> Void {
    if IsDefined(this.m_RunningAnimation) && this.m_RunningAnimation.IsPlaying() {
      this.m_RunningAnimation.Stop();
    };
    this.m_RunningAnimation = this.PlayLibraryAnimation(n"messegeIn");
    this.m_RunningAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnMessegeAnimFinished");
    this.m_actionsList.SetVisible(false);
    this.m_defaultTextWidget.SetVisible(false);
  }

  protected cb func OnVideoFinished(target: wref<inkVideo>) -> Bool {
    if this.m_isConfessing {
      this.StopConfessing();
    };
  }

  protected cb func OnMessegeAnimFinished(e: ref<inkAnimProxy>) -> Bool {
    let evt: ref<ConfessionCompletedEvent>;
    if IsDefined(this.m_RunningAnimation) {
      this.m_RunningAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnMessegeAnimFinished");
    };
    this.m_actionsList.SetVisible(true);
    this.m_defaultTextWidget.SetVisible(true);
    evt = new ConfessionCompletedEvent();
    this.GetOwner().QueueEvent(evt);
  }

  public final func StopVideo() -> Void {
    this.m_mainDisplayWidget.Stop();
  }

  public final func TurnOff() -> Void {
    this.m_rootWidget.SetVisible(false);
    this.ResetConfessionState();
  }

  public final func TurnOn() -> Void {
    this.m_rootWidget.SetVisible(true);
    this.RequestActionWidgetsUpdate();
  }

  protected cb func OnConfess(value: Bool) -> Bool {
    if value {
      this.StartConfessing();
    } else {
      this.StopConfessing();
    };
  }

  private final func StartConfessing() -> Void {
    if this.m_isConfessing {
      return;
    };
    this.m_isConfessing = true;
    this.m_defaultUI.SetVisible(false);
    if this.m_mainDisplayWidget != null {
      this.m_mainDisplayWidget.RegisterToCallback(n"OnVideoFinished", this, n"OnVideoFinished");
    };
    this.PlayVideo(r"base\\movies\\misc\\confessional_booth\\confessional_s.bk2", false, n"");
  }

  private final func StopConfessing() -> Void {
    if this.m_isConfessing {
      this.m_isConfessing = false;
      this.GetBlackboard().SetBool(this.GetOwner().GetBlackboardDef() as ConfessionalBlackboardDef.IsConfessing, false);
      this.StopVideo();
      this.m_defaultUI.SetVisible(true);
      this.PlayConfessMessegeAnimation();
      if this.m_mainDisplayWidget != null {
        this.m_mainDisplayWidget.UnregisterFromCallback(n"OnVideoFinished", this, n"OnVideoFinished");
      };
    };
  }
}
