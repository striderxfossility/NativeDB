
public native class inkHUDGameController extends inkGameController {

  protected let m_showAnimDef: ref<inkAnimDef>;

  protected let m_hideAnimDef: ref<inkAnimDef>;

  @default(inkHUDGameController, unfold)
  private let m_showAnimationName: CName;

  @default(inkHUDGameController, fold)
  private let m_hideAnimationName: CName;

  private let m_moduleShown: Bool;

  private let m_showAnimProxy: ref<inkAnimProxy>;

  private let m_hideAnimProxy: ref<inkAnimProxy>;

  protected final func ShowRequest() -> Void {
    if !this.m_moduleShown {
      this.m_moduleShown = true;
      this.GetRootWidget().SetVisible(true);
      if IsDefined(this.m_hideAnimProxy) {
        this.m_hideAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHideAnimationFinished");
        this.m_hideAnimProxy.Stop();
        this.m_hideAnimProxy = null;
      };
      if NotEquals(this.m_showAnimationName, n"") {
        this.m_showAnimProxy = this.PlayLibraryAnimation(this.m_showAnimationName);
      };
    };
  }

  protected final func HideRequest() -> Void {
    if this.m_moduleShown {
      this.m_moduleShown = false;
      if IsDefined(this.m_showAnimProxy) {
        this.m_showAnimProxy.Stop();
        this.m_showAnimProxy = null;
      };
      if NotEquals(this.m_hideAnimationName, n"") {
        this.m_hideAnimProxy = this.PlayLibraryAnimation(this.m_hideAnimationName);
        this.m_hideAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHideAnimationFinished");
      } else {
        this.GetRootWidget().SetVisible(false);
      };
    };
  }

  protected final func PlayInitFoldingAnim() -> Void {
    this.GetRootWidget().SetVisible(false);
    if IsDefined(this.m_showAnimProxy) {
      this.m_showAnimProxy.Stop();
      this.m_showAnimProxy = null;
    };
    if NotEquals(this.m_hideAnimationName, n"") {
      this.m_hideAnimProxy = this.PlayLibraryAnimation(this.m_hideAnimationName);
      this.m_hideAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnPlayInitFoldingAnimFinished");
    };
  }

  protected cb func OnPlayInitFoldingAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.GetRootWidget().SetVisible(true);
  }

  public func UpdateRequired() -> Void;

  protected cb func OnHideAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.GetRootWidget().SetVisible(false);
  }

  private final func CreateContextChangeAnimations() -> Void {
    this.m_showAnimDef = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(0.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetDuration(0.50);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_showAnimDef.AddInterpolator(alphaInterpolator);
    this.m_hideAnimDef = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(0.50);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_hideAnimDef.AddInterpolator(alphaInterpolator);
  }

  public func GetIntroAnimation() -> ref<inkAnimDef> {
    if this.m_showAnimDef == null {
      this.CreateContextChangeAnimations();
    };
    return this.m_showAnimDef;
  }

  public func GetOutroAnimation() -> ref<inkAnimDef> {
    if this.m_hideAnimDef == null {
      this.CreateContextChangeAnimations();
    };
    return this.m_hideAnimDef;
  }
}
