
public class inkHoverResizeController extends inkLogicController {

  private let m_root: wref<inkWidget>;

  private let m_animToNew: ref<inkAnimDef>;

  private let m_animToOld: ref<inkAnimDef>;

  public edit let m_vectorNewSize: Vector2;

  public edit let m_vectorOldSize: Vector2;

  @default(inkHoverResizeController, 0.10f)
  public edit let m_animationDuration: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.m_root.RegisterToCallback(n"OnHoverOver", this, n"OnRootHoverOver");
    this.m_root.RegisterToCallback(n"OnHoverOut", this, n"OnRootHoverOut");
    if this.m_vectorNewSize.X == 0.00 && this.m_vectorNewSize.Y == 0.00 {
      this.m_vectorNewSize = this.m_root.GetSize();
    };
    if this.m_vectorOldSize.X == 0.00 && this.m_vectorOldSize.Y == 0.00 {
      this.m_vectorOldSize = this.m_root.GetSize();
    };
    this.InitializeAnimations();
  }

  protected cb func OnRootHoverOver(e: ref<inkPointerEvent>) -> Bool {
    if e.GetTarget() == this.m_root {
      this.m_root.StopAllAnimations();
      this.m_root.PlayAnimation(this.m_animToNew);
    };
  }

  protected cb func OnRootHoverOut(e: ref<inkPointerEvent>) -> Bool {
    if e.GetTarget() == this.m_root {
      this.m_root.StopAllAnimations();
      this.m_root.PlayAnimation(this.m_animToOld);
    };
  }

  private final func InitializeAnimations() -> Void {
    this.m_animToNew = new inkAnimDef();
    let resizeInterp: ref<inkAnimSize> = new inkAnimSize();
    resizeInterp.SetDirection(inkanimInterpolationDirection.To);
    resizeInterp.SetEndSize(this.m_vectorNewSize);
    resizeInterp.SetDuration(this.m_animationDuration);
    this.m_animToNew.AddInterpolator(resizeInterp);
    this.m_animToOld = new inkAnimDef();
    resizeInterp = new inkAnimSize();
    resizeInterp.SetDirection(inkanimInterpolationDirection.To);
    resizeInterp.SetEndSize(this.m_vectorOldSize);
    resizeInterp.SetDuration(this.m_animationDuration);
    this.m_animToOld.AddInterpolator(resizeInterp);
  }
}
