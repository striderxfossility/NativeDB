
public native class RoachRacePlayerController extends MinigamePlayerController {

  private edit let m_runAnimation: CName;

  private edit let m_jumpAnimation: CName;

  private let m_currentAnimation: ref<inkAnimProxy>;

  private final func Run() -> Void {
    let animationOptions: inkAnimOptions = new inkAnimOptions();
    animationOptions.loopInfinite = true;
    animationOptions.loopType = inkanimLoopType.Cycle;
    if this.m_currentAnimation.IsValid() {
      this.m_currentAnimation.Stop();
    };
    this.m_currentAnimation = this.PlayLibraryAnimationOnTargets(this.m_runAnimation, SelectWidgets(this.GetRootWidget()), animationOptions);
  }

  private final func Jump() -> Void {
    let animationOptions: inkAnimOptions = new inkAnimOptions();
    if this.m_currentAnimation.IsValid() {
      this.m_currentAnimation.Stop();
    };
    this.m_currentAnimation = this.PlayLibraryAnimationOnTargets(this.m_jumpAnimation, SelectWidgets(this.GetRootWidget()), animationOptions);
  }

  protected cb func OnJumpStart() -> Bool {
    this.Jump();
  }

  protected cb func OnDie() -> Bool {
    if this.m_currentAnimation.IsValid() {
      this.m_currentAnimation.Stop();
    };
  }

  protected cb func OnJumpEnd() -> Bool {
    this.Run();
  }

  protected cb func OnRun() -> Bool {
    this.Run();
  }
}
