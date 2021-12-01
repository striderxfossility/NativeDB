
public class HubExperienceBarController extends inkLogicController {

  protected edit let m_foregroundContainer: inkWidgetRef;

  public final func SetValue(value: Int32, maxValue: Int32) -> Void {
    this.SetValueF(Cast(value), Cast(maxValue));
  }

  public final func SetValueF(value: Float, maxValue: Float) -> Void {
    inkWidgetRef.SetScale(this.m_foregroundContainer, new Vector2(value / maxValue, 1.00));
  }
}
