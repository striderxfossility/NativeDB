
public native class TutorialOverlayLogicController extends inkLogicController {

  private native let hideOnInput: Bool;

  private edit let m_showAnimation: CName;

  private edit let m_hideAnimation: CName;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_tutorialManager: wref<questTutorialManager>;

  protected cb func OnUninitialize() -> Bool {
    if this.hideOnInput {
      this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    };
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    let overlayUserData: ref<TutorialOverlayUserData>;
    if evt.IsAction(n"close_tutorial") {
      overlayUserData = this.GetRootWidget().GetUserData(n"gameTutorialOverlayUserData") as TutorialOverlayUserData;
      this.m_tutorialManager.RequestToCloseOverlay(overlayUserData.overlayId);
      evt.Handle();
    };
  }

  private final func SetupTutorialOverlayLogicController(tutorialManager: ref<questITutorialManager>) -> Void {
    this.m_tutorialManager = tutorialManager as questTutorialManager;
    if this.hideOnInput {
      this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    };
  }

  private final func PlayShowAnimation() -> ref<inkAnimProxy> {
    let anim: ref<inkAnimProxy> = this.PlayLibraryAnimation(this.m_showAnimation);
    if anim != null {
      anim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShowFinished");
    };
    return anim;
  }

  private final func PlayHideAnimation() -> ref<inkAnimProxy> {
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.Stop();
    };
    return this.PlayLibraryAnimation(this.m_hideAnimation);
  }

  protected cb func OnShowFinished(e: ref<inkAnimProxy>) -> Bool {
    let options: inkAnimOptions;
    options.loopType = IntEnum(0l);
    options.loopInfinite = false;
    this.m_animProxy = this.PlayLibraryAnimation(n"BracketLoop", options);
  }
}
