
public class BackdoorInkGameController extends MasterDeviceInkGameControllerBase {

  private edit let m_IdleGroup: inkWidgetRef;

  private edit let m_ConnectedGroup: inkWidgetRef;

  private edit let m_IntroAnimationName: CName;

  private edit let m_IdleAnimationName: CName;

  private edit let m_GlitchAnimationName: CName;

  private let m_RunningAnimation: ref<inkAnimProxy>;

  private let m_onGlitchingListener: ref<CallbackHandle>;

  private let m_onIsInDefaultStateListener: ref<CallbackHandle>;

  private let m_onShutdownModuleListener: ref<CallbackHandle>;

  private let m_onBootModuleListener: ref<CallbackHandle>;

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onGlitchingListener = blackboard.RegisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this, n"OnGlitching");
      this.m_onIsInDefaultStateListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef() as BackDoorDeviceBlackboardDef.isInDefaultState, this, n"OnIsInDefaultState");
      this.m_onShutdownModuleListener = blackboard.RegisterListenerInt(this.GetOwner().GetBlackboardDef() as BackDoorDeviceBlackboardDef.shutdownModule, this, n"OnShutdownModule");
      this.m_onBootModuleListener = blackboard.RegisterListenerInt(this.GetOwner().GetBlackboardDef() as BackDoorDeviceBlackboardDef.bootModule, this, n"OnBootModule");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerVariant(this.GetOwner().GetBlackboardDef().GlitchData, this.m_onGlitchingListener);
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef() as BackDoorDeviceBlackboardDef.isInDefaultState, this.m_onIsInDefaultStateListener);
      blackboard.UnregisterListenerInt(this.GetOwner().GetBlackboardDef() as BackDoorDeviceBlackboardDef.shutdownModule, this.m_onShutdownModuleListener);
      blackboard.UnregisterListenerInt(this.GetOwner().GetBlackboardDef() as BackDoorDeviceBlackboardDef.bootModule, this.m_onBootModuleListener);
    };
  }

  protected func UpdateThumbnailWidgets(widgetsData: array<SThumbnailWidgetPackage>) -> Void {
    this.UpdateThumbnailWidgets(widgetsData);
  }

  protected func UpdateDeviceWidgets(widgetsData: array<SDeviceWidgetPackage>) -> Void {
    this.UpdateDeviceWidgets(widgetsData);
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    switch state {
      case EDeviceStatus.ON:
        this.TurnOn();
        break;
      case EDeviceStatus.OFF:
        this.TurnOff();
        break;
      case EDeviceStatus.UNPOWERED:
        this.TurnOff();
        break;
      case EDeviceStatus.DISABLED:
        this.TurnOff();
        break;
      default:
    };
    this.Refresh(state);
  }

  protected final func TurnOn() -> Void {
    this.GetRootWidget().SetVisible(true);
    inkWidgetRef.SetVisible(this.m_IdleGroup, true);
    inkWidgetRef.SetVisible(this.m_ConnectedGroup, false);
    this.PlayIntroAnimation();
  }

  protected final func TurnOff() -> Void {
    this.GetRootWidget().SetVisible(false);
    this.PlayAnimation(n"");
  }

  private final func PlayIntroAnimation() -> Void {
    if IsDefined(this.m_RunningAnimation) && this.m_RunningAnimation.IsPlaying() {
      this.m_RunningAnimation.Stop();
    };
    this.m_RunningAnimation = this.PlayLibraryAnimation(this.m_IntroAnimationName);
    this.m_RunningAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnIntroFinished");
  }

  protected cb func OnIntroFinished(e: ref<inkAnimProxy>) -> Bool {
    if IsDefined(this.m_RunningAnimation) {
      this.m_RunningAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnIntroFinished");
    };
    this.PlayAnimation(this.m_IdleAnimationName);
  }

  protected final func PlayAnimation(animName: CName) -> Void {
    let playbackOptions: inkAnimOptions;
    if IsDefined(this.m_RunningAnimation) && this.m_RunningAnimation.IsPlaying() {
      this.m_RunningAnimation.Stop();
    };
    if IsNameValid(animName) {
      playbackOptions.loopType = inkanimLoopType.Cycle;
      playbackOptions.loopInfinite = true;
      this.m_RunningAnimation = this.PlayLibraryAnimation(animName, playbackOptions);
    };
  }

  protected func StartGlitching() -> Void {
    this.PlayAnimation(this.m_GlitchAnimationName);
    inkWidgetRef.SetVisible(this.m_IdleGroup, false);
    inkWidgetRef.SetVisible(this.m_ConnectedGroup, true);
  }

  private final func StopGlitching() -> Void {
    this.PlayAnimation(this.m_IdleAnimationName);
    inkWidgetRef.SetVisible(this.m_IdleGroup, true);
    inkWidgetRef.SetVisible(this.m_ConnectedGroup, false);
  }

  protected cb func OnGlitching(value: Bool) -> Bool {
    if value {
      this.StartGlitching();
    } else {
      this.StopGlitching();
    };
  }

  protected cb func OnIsInDefaultState(value: Bool) -> Bool {
    if value {
    } else {
      this.EnableHackedGroup();
    };
  }

  protected cb func OnShutdownModule(value: Int32) -> Bool {
    this.ShutdownModule(value);
  }

  protected cb func OnBootModule(value: Int32) -> Bool {
    this.BootModule(value);
  }

  protected func ShutdownModule(module: Int32) -> Void;

  protected func BootModule(module: Int32) -> Void;

  protected func EnableHackedGroup() -> Void;
}
