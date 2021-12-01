
public class InteractiveAdInkGameController extends DeviceInkGameControllerBase {

  @attrib(category, "Widget Refs")
  private edit let m_ProcessingVideo: inkVideoRef;

  @attrib(category, "Widget Refs")
  private edit let m_PersonalAd: inkVideoRef;

  @attrib(category, "Widget Refs")
  private edit let m_CommonAd: inkVideoRef;

  @default(InteractiveAdInkGameController, 0.5f)
  protected edit let m_fadeDuration: Float;

  private let m_animFade: ref<inkAnimDef>;

  private let m_animOptions: inkAnimOptions;

  private let m_showAd: Bool;

  private let m_onShowAdListener: ref<CallbackHandle>;

  private let m_onShowVendorListener: ref<CallbackHandle>;

  protected func SetupWidgets() -> Void {
    if !this.m_isInitialized {
      this.m_showAd = false;
      this.StartAdVideo();
    };
  }

  protected final func CreateAnimation() -> Void {
    this.m_animFade = new inkAnimDef();
    let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(0.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(this.m_fadeDuration);
    this.m_animFade.AddInterpolator(fadeInterp);
    this.m_animOptions.loopType = IntEnum(0l);
  }

  protected func UpdateActionWidgets(widgetsData: array<SActionWidgetPackage>) -> Void;

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onShowAdListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef() as InteractiveDeviceBlackboardDef.showAd, this, n"OnShowAd");
      this.m_onShowVendorListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef() as InteractiveDeviceBlackboardDef.showVendor, this, n"OnShowVendor");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef() as InteractiveDeviceBlackboardDef.showAd, this.m_onShowAdListener);
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef() as InteractiveDeviceBlackboardDef.showVendor, this.m_onShowVendorListener);
    };
  }

  protected cb func OnShowAd(flag: Bool) -> Bool {
    if flag {
      inkWidgetRef.SetVisible(this.m_PersonalAd, true);
      inkVideoRef.Play(this.m_PersonalAd);
    } else {
      inkWidgetRef.SetVisible(this.m_PersonalAd, false);
      this.StopProcessingVideo();
    };
  }

  protected cb func OnShowVendor(flag: Bool) -> Bool {
    this.StartProcessingVideo();
  }

  protected final func StartAdVideo() -> Void {
    inkVideoRef.Stop(this.m_CommonAd);
    inkWidgetRef.SetVisible(this.m_CommonAd, true);
    inkVideoRef.Play(this.m_CommonAd);
  }

  protected final func StartProcessingVideo() -> Void {
    inkVideoRef.Stop(this.m_ProcessingVideo);
    inkWidgetRef.SetVisible(this.m_ProcessingVideo, true);
    inkVideoRef.Play(this.m_ProcessingVideo);
  }

  protected final func StopProcessingVideo() -> Void {
    inkVideoRef.Stop(this.m_ProcessingVideo);
    inkWidgetRef.SetVisible(this.m_ProcessingVideo, false);
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }

  protected func Refresh(state: EDeviceStatus) -> Void {
    this.SetupWidgets();
    this.Refresh(state);
    this.HideActionWidgets();
    this.RequestActionWidgetsUpdate();
  }
}
