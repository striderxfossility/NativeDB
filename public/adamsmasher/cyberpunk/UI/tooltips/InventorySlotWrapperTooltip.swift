
public class InventorySlotWrapperTooltip extends AGenericTooltipController {

  protected let itemDisplayController: wref<InventoryItemDisplayController>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if !IsDefined(this.itemDisplayController) {
      this.itemDisplayController = ItemDisplayUtils.SpawnCommonSlotController(this, this.GetRootWidget(), n"lootSlot") as InventoryItemDisplayController;
      if IsDefined(this.itemDisplayController) && IsDefined(this.itemDisplayController.GetRootWidget()) {
        this.itemDisplayController.GetRootWidget().SetVAlign(inkEVerticalAlign.Top);
        this.itemDisplayController.GetRootWidget().SetHAlign(inkEHorizontalAlign.Left);
      };
    };
  }

  public final func SetData(itemData: InventoryItemData, isSelected: Bool) -> Void {
    this.SetData(InventoryTooltipData.FromInventoryItemData(itemData));
    this.itemDisplayController.SetHighlighted(isSelected);
  }

  public final func SetData(tooltipData: ref<ATooltipData>, isSelected: Bool) -> Void {
    this.SetData(tooltipData);
    this.itemDisplayController.SetHighlighted(isSelected);
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    let data: ref<InventoryTooltipData> = tooltipData as InventoryTooltipData;
    this.itemDisplayController.SetHUDMode(true);
    this.itemDisplayController.Setup(data);
  }
}
