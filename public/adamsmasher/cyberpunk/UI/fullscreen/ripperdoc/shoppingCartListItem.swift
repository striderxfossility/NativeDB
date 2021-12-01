
public class ShoppingCartListItem extends inkLogicController {

  private edit let m_label: inkTextRef;

  private edit let m_quantity: inkTextRef;

  private edit let m_value: inkTextRef;

  private edit let m_removeBtn: inkWidgetRef;

  private let m_data: InventoryItemData;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_removeBtn, false);
  }

  protected cb func OnUninitialize() -> Bool;

  public final func SetupData(data: InventoryItemData) -> Void {
    this.m_data = data;
    inkTextRef.SetText(this.m_label, InventoryItemData.GetName(data));
    inkTextRef.SetText(this.m_quantity, ToString(InventoryItemData.GetQuantity(data)));
  }

  public final func OnHoverOver() -> Void {
    inkWidgetRef.SetVisible(this.m_removeBtn, true);
  }

  public final func OnHoverOut() -> Void {
    inkWidgetRef.SetVisible(this.m_removeBtn, false);
  }

  public final func GetData() -> InventoryItemData {
    return this.m_data;
  }
}
