
public class PhotoModeToggle extends inkToggleController {

  private edit let m_SelectedWidget: inkWidgetRef;

  private edit let m_FrameWidget: inkWidgetRef;

  private edit let m_IconWidget: inkImageRef;

  private edit let m_LabelWidget: inkTextRef;

  public let m_photoModeGroupController: wref<PhotoModeTopBarController>;

  private let m_fadeAnim: ref<inkAnimProxy>;

  private let m_fade2Anim: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_SelectedWidget, false);
    inkWidgetRef.SetOpacity(this.m_FrameWidget, 0.10);
    inkWidgetRef.Get(this.m_IconWidget).BindProperty(n"tintColor", n"MainColors.Red");
    inkWidgetRef.Get(this.m_LabelWidget).BindProperty(n"tintColor", n"MainColors.Red");
    this.RegisterToCallback(n"OnToggleChanged", this, n"OnToggleChanged");
    this.RegisterToCallback(n"OnRelease", this, n"OnToggleClick");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnToggleChanged", this, n"OnToggleChanged");
    this.UnregisterFromCallback(n"OnRelease", this, n"OnToggleClick");
  }

  private final func PlayFadeAnimation(widget: inkWidgetRef, opacity: Float) -> ref<inkAnimProxy> {
    let animDef: ref<inkAnimDef>;
    let animInterp: ref<inkAnimTransparency>;
    if inkWidgetRef.GetOpacity(widget) == opacity {
      return null;
    };
    animDef = new inkAnimDef();
    animInterp = new inkAnimTransparency();
    animInterp.SetStartTransparency(inkWidgetRef.GetOpacity(widget));
    animInterp.SetEndTransparency(opacity);
    animInterp.SetDuration(0.25);
    animInterp.SetDirection(inkanimInterpolationDirection.To);
    animInterp.SetUseRelativeDuration(true);
    animDef.AddInterpolator(animInterp);
    return inkWidgetRef.PlayAnimation(widget, animDef);
  }

  protected cb func OnToggleChanged(controller: wref<inkToggleController>, isToggled: Bool) -> Bool {
    inkWidgetRef.SetVisible(this.m_SelectedWidget, true);
    if isToggled {
      if this.m_fadeAnim != null {
        this.m_fadeAnim.Stop();
      };
      this.m_fadeAnim = this.PlayFadeAnimation(this.m_SelectedWidget, 0.10);
      if this.m_fade2Anim != null {
        this.m_fade2Anim.Stop();
      };
      inkWidgetRef.StopAllAnimations(this.m_FrameWidget);
      this.m_fade2Anim = this.PlayFadeAnimation(this.m_FrameWidget, 1.00);
      inkWidgetRef.Get(this.m_FrameWidget).BindProperty(n"tintColor", n"MainColors.Red");
      inkWidgetRef.Get(this.m_IconWidget).BindProperty(n"tintColor", n"MainColors.Blue");
      inkWidgetRef.Get(this.m_LabelWidget).BindProperty(n"tintColor", n"MainColors.Blue");
    } else {
      if this.m_fadeAnim != null {
        this.m_fadeAnim.Stop();
      };
      this.m_fadeAnim = this.PlayFadeAnimation(this.m_SelectedWidget, 0.00);
      if this.m_fade2Anim != null {
        this.m_fade2Anim.Stop();
      };
      inkWidgetRef.StopAllAnimations(this.m_FrameWidget);
      this.m_fade2Anim = this.PlayFadeAnimation(this.m_FrameWidget, 0.10);
      inkWidgetRef.Get(this.m_FrameWidget).BindProperty(n"tintColor", n"MainColors.Red");
      inkWidgetRef.Get(this.m_IconWidget).BindProperty(n"tintColor", n"MainColors.Red");
      inkWidgetRef.Get(this.m_LabelWidget).BindProperty(n"tintColor", n"MainColors.Red");
    };
  }

  protected cb func OnToggleClick(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_photoModeGroupController.SelectToggle(this);
    };
  }

  public final func SetEnabledOnTopBar(enabled: Bool) -> Void {
    this.GetRootWidget().SetVisible(enabled);
  }

  public final func GetEnabledOnTopBar() -> Bool {
    return this.GetRootWidget().IsVisible();
  }
}
