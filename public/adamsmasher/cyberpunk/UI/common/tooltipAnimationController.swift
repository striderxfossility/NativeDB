
public class TooltipAnimationController extends inkLogicController {

  @default(TooltipAnimationController, show_tooltip)
  private edit let m_showAnimationName: CName;

  @default(TooltipAnimationController, hide_tooltip)
  private edit let m_hideAnimationName: CName;

  private let m_tooltipAnimHide: ref<inkAnimProxy>;

  private let m_tooltipDelayedShow: ref<inkAnimProxy>;

  @default(TooltipAnimationController, 0.4)
  private let m_axisDataThreshold: Float;

  private let m_isHidden: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
  }

  protected cb func OnAxisInput(evt: ref<inkPointerEvent>) -> Bool {
    let axisData: Float = evt.GetAxisData();
    if AbsF(axisData) < this.m_axisDataThreshold {
      return false;
    };
    if evt.IsAction(n"left_stick_x") || evt.IsAction(n"left_stick_y") {
      if IsDefined(this.m_tooltipAnimHide) && this.m_tooltipAnimHide.IsPlaying() {
      } else {
        if IsDefined(this.m_tooltipDelayedShow) && this.m_tooltipDelayedShow.IsPlaying() {
          this.m_tooltipDelayedShow.Stop(true);
          this.m_tooltipDelayedShow = this.PlayLibraryAnimation(this.m_showAnimationName);
          this.m_tooltipDelayedShow.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShown");
        } else {
          if IsDefined(this.m_tooltipAnimHide) {
            this.m_tooltipAnimHide.Stop(true);
            this.m_tooltipAnimHide = null;
          };
          this.m_tooltipAnimHide = this.PlayLibraryAnimation(this.m_hideAnimationName);
          this.m_tooltipAnimHide.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHidden");
        };
      };
    };
  }

  protected cb func OnHidden(proxy: ref<inkAnimProxy>) -> Bool {
    if IsDefined(this.m_tooltipDelayedShow) {
      this.m_tooltipDelayedShow.Stop(true);
      this.m_tooltipDelayedShow = null;
    };
    this.m_tooltipDelayedShow = this.PlayLibraryAnimation(this.m_showAnimationName);
    this.m_tooltipDelayedShow.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShown");
    this.m_isHidden = true;
  }

  protected cb func OnShown(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_isHidden = false;
  }
}
