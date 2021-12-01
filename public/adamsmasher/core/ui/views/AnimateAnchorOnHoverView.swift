
public class AnimateAnchorOnHoverView extends inkLogicController {

  private edit let m_Raycaster: inkWidgetRef;

  private let m_AnimProxy: ref<inkAnimProxy>;

  private edit let m_HoverAnchor: Vector2;

  private edit let m_NormalAnchor: Vector2;

  @default(AnimateAnchorOnHoverView, 0.1f)
  private edit let m_AnimTime: Float;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_Raycaster, n"OnHoverOver", this, n"OnHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_Raycaster, n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.m_Raycaster, n"OnHoverOver", this, n"OnHoverOver");
    inkWidgetRef.UnregisterFromCallback(this.m_Raycaster, n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.OnHoverChanged(true);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.OnHoverChanged(false);
  }

  protected final func OnHoverChanged(isHovered: Bool) -> Void {
    let anchorInterp: ref<inkAnimAnchor>;
    let animDef: ref<inkAnimDef>;
    if isHovered {
      this.StopAnimation();
      animDef = new inkAnimDef();
      anchorInterp = new inkAnimAnchor();
      anchorInterp.SetDirection(inkanimInterpolationDirection.To);
      anchorInterp.SetEndAnchor(this.m_HoverAnchor);
      anchorInterp.SetDuration(this.m_AnimTime);
      animDef.AddInterpolator(anchorInterp);
      this.m_AnimProxy = this.GetRootWidget().PlayAnimation(animDef);
    } else {
      if !isHovered {
        this.StopAnimation();
        animDef = new inkAnimDef();
        anchorInterp = new inkAnimAnchor();
        anchorInterp.SetDirection(inkanimInterpolationDirection.To);
        anchorInterp.SetEndAnchor(this.m_NormalAnchor);
        anchorInterp.SetDuration(this.m_AnimTime);
        animDef.AddInterpolator(anchorInterp);
        this.m_AnimProxy = this.GetRootWidget().PlayAnimation(animDef);
      };
    };
  }

  protected final func StopAnimation() -> Void {
    if IsDefined(this.m_AnimProxy) && this.m_AnimProxy.IsPlaying() {
      this.m_AnimProxy.Stop();
    };
  }
}
