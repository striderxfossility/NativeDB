
public class InventoryCyberwareDisplayController extends InventoryItemDisplayController {

  protected edit let m_ownedFrame: inkWidgetRef;

  protected edit let m_selectedFrame: inkWidgetRef;

  protected edit let m_amountPanel: inkWidgetRef;

  protected edit let m_amount: inkTextRef;

  public func Unselect() -> Void {
    inkWidgetRef.SetVisible(this.m_selectedFrame, false);
  }

  public func Select() -> Void {
    inkWidgetRef.SetVisible(this.m_selectedFrame, true);
  }

  public final func SetAmountOfNewItem(amount: Int32) -> Void {
    if amount <= 0 {
      inkWidgetRef.SetVisible(this.m_amountPanel, false);
    } else {
      inkWidgetRef.SetVisible(this.m_amountPanel, true);
      inkTextRef.SetText(this.m_amount, IntToString(amount));
    };
  }
}
