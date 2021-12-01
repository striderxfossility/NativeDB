
public native class TutorialBracketLogicController extends inkLogicController {

  private let m_loopAnim: ref<inkAnimProxy>;

  private final func PlayShowAnimation() -> ref<inkAnimProxy> {
    let anim: ref<inkAnimProxy> = this.PlayLibraryAnimation(n"BracketShow");
    if anim != null {
      anim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShowFinished");
    };
    return anim;
  }

  private final func PlayHideAnimation() -> ref<inkAnimProxy> {
    if IsDefined(this.m_loopAnim) {
      this.m_loopAnim.Stop();
    };
    return this.PlayLibraryAnimation(n"BracketHide");
  }

  protected cb func OnShowFinished(e: ref<inkAnimProxy>) -> Bool {
    let options: inkAnimOptions;
    options.loopType = inkanimLoopType.Cycle;
    options.loopInfinite = true;
    this.m_loopAnim = this.PlayLibraryAnimation(n"BracketLoop", options);
  }
}
