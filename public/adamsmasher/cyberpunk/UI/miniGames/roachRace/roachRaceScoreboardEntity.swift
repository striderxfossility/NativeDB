
public class ScoreboardEntityLogicController extends inkLogicController {

  private edit let m_label: inkTextRef;

  public final func SetText(text: String) -> Void {
    if inkWidgetRef.IsValid(this.m_label) {
      inkTextRef.SetText(this.m_label, text);
    };
  }
}
