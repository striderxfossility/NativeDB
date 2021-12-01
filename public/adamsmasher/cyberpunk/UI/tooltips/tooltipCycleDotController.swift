
public class TooltipCycleDotController extends inkLogicController {

  private edit let m_slotBorder: inkWidgetRef;

  private edit let m_slotBackground: inkWidgetRef;

  public final func Toggle(active: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_slotBackground, active);
  }
}
