
public class PerksLevelBarController extends inkLogicController {

  protected edit let m_foregroundImage: inkWidgetRef;

  protected edit let m_backgroundImage: inkWidgetRef;

  public final func SetProgress(progress: Float) -> Void {
    inkWidgetRef.SetScale(this.m_foregroundImage, new Vector2(1.00, progress));
  }
}
