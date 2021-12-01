
public class InventoryRipperdocDisplayController extends InventoryItemDisplayController {

  private edit let m_ownedBackground: inkWidgetRef;

  private edit let m_ownedSign: inkWidgetRef;

  protected func RefreshUI() -> Void {
    this.RefreshUI();
    if InventoryItemData.IsEmpty(this.m_itemData) || InventoryItemData.IsPart(this.m_itemData) {
      inkWidgetRef.SetVisible(this.m_ownedBackground, false);
      inkWidgetRef.SetVisible(this.m_ownedSign, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_ownedBackground, !InventoryItemData.IsVendorItem(this.m_itemData));
    inkWidgetRef.SetVisible(this.m_ownedSign, !InventoryItemData.IsVendorItem(this.m_itemData));
  }

  protected func UpdatePrice() -> Void {
    if IsDefined(inkWidgetRef.Get(this.m_itemPrice)) {
      if InventoryItemData.IsVendorItem(this.m_itemData) {
        inkWidgetRef.SetVisible(this.m_itemPrice, true);
        inkWidgetRef.SetVisible(this.m_ownedSign, false);
        inkTextRef.SetText(this.m_itemPrice, this.GetPriceText());
      } else {
        inkWidgetRef.SetVisible(this.m_itemPrice, false);
        inkWidgetRef.SetVisible(this.m_ownedSign, true);
      };
    };
  }
}
