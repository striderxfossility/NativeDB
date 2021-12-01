
public class AnimationLogicController extends inkLogicController {

  private edit let m_imageView: inkImageRef;

  protected cb func OnChangeState(state: String) -> Bool {
    if inkWidgetRef.IsValid(this.m_imageView) {
      inkImageRef.SetTexturePart(this.m_imageView, StringToName(state));
    };
  }
}
