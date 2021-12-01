
public class CraftingPopupController extends inkGameController {

  private edit let m_tooltipContainer: inkWidgetRef;

  private edit let m_craftIcon: inkImageRef;

  private edit let m_itemName: inkTextRef;

  private edit let m_itemTopName: inkTextRef;

  private edit let m_itemQuality: inkTextRef;

  private edit let m_headerText: inkTextRef;

  private edit let m_closeButton: inkWidgetRef;

  private edit let m_buttonHintsRoot: inkWidgetRef;

  private edit let m_libraryPath: inkWidgetLibraryReference;

  private let m_itemTooltip: wref<AGenericTooltipController>;

  private let m_closeButtonController: wref<inkButtonController>;

  private let m_data: ref<CraftingPopupData>;

  protected cb func OnInitialize() -> Bool {
    this.m_closeButtonController = inkWidgetRef.GetController(this.m_closeButton) as inkButtonController;
    this.m_closeButtonController.RegisterToCallback(n"OnButtonClick", this, n"OnOkClick");
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
    this.m_data = this.GetRootWidget().GetUserData(n"CraftingPopupData") as CraftingPopupData;
    this.SetPopupData(this.m_data.itemTooltipData, this.m_data.craftingCommand);
    this.AddButtonHint();
  }

  private final func AddButtonHint() -> Void {
    let buttonHint: ref<LabelInputDisplayController> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsRoot), inkWidgetLibraryResource.GetPath(this.m_libraryPath.widgetLibrary), this.m_libraryPath.widgetItem).GetController() as LabelInputDisplayController;
    buttonHint.SetInputActionLabel(n"UI_Cancel", "UI-ResourceExports-Confirm");
  }

  protected cb func OnHandlePressInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"cancel") {
      this.m_data.token.TriggerCallback(null);
    };
  }

  private final func SetPopupData(tooltipsData: ref<InventoryTooltipData>, command: CraftingCommands) -> Void {
    let stateName: CName;
    let stateNameLoc: String;
    let previewEvent: ref<CraftingItemPreviewEvent> = new CraftingItemPreviewEvent();
    if this.m_itemTooltip == null {
      this.m_itemTooltip = this.SpawnFromExternal(inkWidgetRef.Get(this.m_tooltipContainer), r"base\\gameplay\\gui\\common\\tooltip\\tooltipslibrary_4k.inkwidget", n"itemTooltip").GetController() as AGenericTooltipController;
    };
    previewEvent.itemID = tooltipsData.itemID;
    this.QueueEvent(previewEvent);
    stateName = InventoryItemData.GetQuality(tooltipsData.inventoryItemData);
    stateNameLoc = UIItemsHelper.QualityToLocalizationKey(UIItemsHelper.QualityNameToEnum(stateName));
    inkTextRef.SetText(this.m_itemName, tooltipsData.itemName);
    inkWidgetRef.SetState(this.m_itemName, stateName);
    inkTextRef.SetText(this.m_itemQuality, stateNameLoc);
    inkTextRef.SetText(this.m_itemTopName, tooltipsData.itemName);
    this.m_itemTooltip.SetData(tooltipsData);
    switch command {
      case CraftingCommands.CraftingFinished:
        inkTextRef.SetText(this.m_headerText, "UI-Crafting-CraftingFinishedNotification");
        inkImageRef.SetTexturePart(this.m_craftIcon, n"ico_cafting_crafting");
        break;
      case CraftingCommands.UpgradingFinished:
        inkTextRef.SetText(this.m_headerText, "UI-Crafting-UpgradingFinishedNotification");
        inkImageRef.SetTexturePart(this.m_craftIcon, n"ico_cafting_upgrading");
    };
  }

  protected cb func OnOkClick(controller: wref<inkButtonController>) -> Bool {
    this.m_data.token.TriggerCallback(null);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_closeButtonController.UnregisterFromCallback(n"OnButtonClick", this, n"OnOkClick");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
  }
}
