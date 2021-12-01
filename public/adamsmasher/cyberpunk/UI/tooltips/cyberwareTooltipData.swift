
public class CyberwareTooltipData extends ATooltipData {

  public let label: String;

  public let slotData: array<ref<CyberwareSlotTooltipData>>;

  public final func AddCyberwareSlotItemData(itemData: InventoryItemData) -> Void {
    let data: ref<CyberwareSlotTooltipData> = new CyberwareSlotTooltipData();
    data.Empty = InventoryItemData.IsEmpty(itemData);
    if !data.Empty {
      data.Name = InventoryItemData.GetName(itemData);
      data.Description = InventoryItemData.GetDescription(itemData);
      data.IconPath = InventoryItemData.GetIconPath(itemData);
    };
    ArrayPush(this.slotData, data);
  }
}
