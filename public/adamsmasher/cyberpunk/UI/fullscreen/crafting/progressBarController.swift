
public class ProgressBarsController extends inkLogicController {

  protected edit let m_mask: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    this.SetBarProgress(0.00);
  }

  public final func SetBarProgress(progress: Float) -> Void {
    inkWidgetRef.SetScale(this.m_mask, new Vector2(progress, 1.00));
  }
}
