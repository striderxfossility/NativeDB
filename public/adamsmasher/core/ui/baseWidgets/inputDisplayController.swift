
public class LabelInputDisplayController extends inkInputDisplayController {

  private edit let m_inputLabel: inkTextRef;

  public final func SetInputActionLabel(actionName: CName, label: String) -> Void {
    inkTextRef.SetText(this.m_inputLabel, label);
    this.SetInputAction(actionName);
  }
}
