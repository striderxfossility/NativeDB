
public class DamagePreviewController extends inkLogicController {

  public edit let m_fullBar: inkWidgetRef;

  public edit let m_stippedBar: inkWidgetRef;

  public edit let m_rootCanvas: inkWidgetRef;

  private let m_width: Float;

  private let m_height: Float;

  private let m_heightStripped: Float;

  private let m_heightRoot: Float;

  private let m_animProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let tempSize: Vector2 = inkWidgetRef.GetSize(this.m_fullBar);
    this.m_width = tempSize.X;
    this.m_height = tempSize.Y;
    tempSize = inkWidgetRef.GetSize(this.m_stippedBar);
    this.m_heightStripped = tempSize.Y;
    tempSize = inkWidgetRef.GetSize(this.m_rootCanvas);
    this.m_heightRoot = tempSize.Y;
  }

  public final func SetPreview(damageScale: Float, positionOffset: Float) -> Void {
    inkWidgetRef.SetSize(this.m_rootCanvas, new Vector2(damageScale * this.m_width, this.m_heightRoot));
    inkWidgetRef.SetSize(this.m_fullBar, new Vector2(damageScale * this.m_width, this.m_height));
    inkWidgetRef.SetSize(this.m_stippedBar, new Vector2(damageScale * this.m_width, this.m_heightStripped));
    this.GetRootWidget().SetMargin((positionOffset - damageScale) * this.m_width, 0.00, 0.00, 0.00);
    inkWidgetRef.SetVisible(this.m_rootCanvas, true);
    this.m_animProxy = this.PlayLibraryAnimation(n"damage_preview");
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationEnd");
  }

  protected cb func OnAnimationEnd(e: ref<inkAnimProxy>) -> Bool {
    inkWidgetRef.SetVisible(this.m_rootCanvas, false);
  }
}
