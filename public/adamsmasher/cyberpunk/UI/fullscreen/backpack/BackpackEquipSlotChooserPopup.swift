
public class BackpackEquipSlotChooserPopup extends inkGameController {

  private edit let m_titleText: inkTextRef;

  private edit let m_buttonHintsRoot: inkWidgetRef;

  private edit let m_rairtyBar: inkWidgetRef;

  private edit let m_root: inkWidgetRef;

  private edit let m_background: inkWidgetRef;

  private edit let m_weaponSlotsContainer: inkCompoundRef;

  private edit let m_tooltipsManagerRef: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_gameData: ref<gameItemData>;

  protected edit let m_buttonOk: inkWidgetRef;

  protected edit let m_buttonCancel: inkWidgetRef;

  private let m_data: ref<BackpackEquipSlotChooserData>;

  private let m_selectedSlotIndex: Int32;

  private let m_tooltipsManager: wref<gameuiTooltipsManager>;

  private let m_comparisonResolver: ref<ItemPreferredComparisonResolver>;

  private edit let m_libraryPath: inkWidgetLibraryReference;

  private let m_closeData: ref<BackpackEquipSlotChooserCloseData>;

  protected cb func OnInitialize() -> Bool {
    this.m_tooltipsManager = inkWidgetRef.GetControllerByType(this.m_tooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_tooltipsManager.Setup(ETooltipsStyle.Menus);
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
    this.m_data = this.GetRootWidget().GetUserData(n"BackpackEquipSlotChooserData") as BackpackEquipSlotChooserData;
    inkTextRef.SetText(this.m_titleText, "UI-PopupNotification-ChooseWeaponSlotTitle");
    inkWidgetRef.RegisterToCallback(this.m_buttonOk, n"OnButtonClick", this, n"OnOkClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonCancel, n"OnButtonClick", this, n"OnCancelClick");
    inkWidgetRef.SetVisible(this.m_root, true);
    inkWidgetRef.SetVisible(this.m_background, true);
    this.m_selectedSlotIndex = -1;
    this.m_comparisonResolver = ItemPreferredComparisonResolver.Make(this.m_data.inventoryManager);
    this.SpawnWeaponSlots(this.m_data.inventoryManager);
    this.PlayLibraryAnimation(n"backpack_equip_chooser_intro");
  }

  private final func SpawnWeaponSlots(inventoryManager: ref<InventoryDataManagerV2>) -> Void {
    let controller: ref<InventoryItemDisplayController>;
    let i: Int32;
    inkCompoundRef.RemoveAllChildren(this.m_weaponSlotsContainer);
    i = 0;
    while i < 3 {
      controller = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_weaponSlotsContainer, n"weaponDisplay") as InventoryItemDisplayController;
      controller.RegisterToCallback(n"OnHoverOver", this, n"OnSlotHoverOver");
      controller.RegisterToCallback(n"OnHoverOut", this, n"OnSlotHoverOut");
      controller.RegisterToCallback(n"OnRelease", this, n"OnSlotClick");
      controller.Bind(inventoryManager, gamedataEquipmentArea.Weapon, i, ItemDisplayContext.GearPanel);
      i += 1;
    };
  }

  protected cb func OnSlotHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.m_tooltipsManager.HideTooltips();
  }

  protected cb func OnSlotHoverOver(e: ref<inkPointerEvent>) -> Bool {
    let canCompareItems: Bool;
    let controller: ref<InventoryItemDisplayController>;
    let inspectedItem: InventoryItemData;
    let itemToEquip: InventoryItemData;
    let tooltipsData: array<ref<ATooltipData>>;
    let widget: wref<inkWidget>;
    this.m_tooltipsManager.HideTooltips();
    itemToEquip = this.m_data.item;
    widget = e.GetCurrentTarget();
    controller = widget.GetController() as InventoryItemDisplayController;
    if IsDefined(controller) {
      inspectedItem = controller.GetItemData();
    };
    canCompareItems = this.m_comparisonResolver.IsTypeComparable(inspectedItem, InventoryItemData.GetItemType(itemToEquip));
    if !InventoryItemData.IsEmpty(inspectedItem) && IsDefined(controller) {
      if canCompareItems && !InventoryItemData.IsEmpty(inspectedItem) {
        this.m_data.inventoryManager.PushComparisonTooltipsData(tooltipsData, inspectedItem, itemToEquip, true);
        this.m_tooltipsManager.ShowTooltips(tooltipsData);
      } else {
        this.m_tooltipsManager.ShowTooltip(0, this.m_data.inventoryManager.GetTooltipDataForInventoryItem(inspectedItem, true, true));
      };
    };
  }

  protected cb func OnSlotClick(e: ref<inkPointerEvent>) -> Bool {
    let controller: ref<InventoryItemDisplayController>;
    if e.IsAction(n"click") {
      controller = e.GetCurrentTarget().GetController() as InventoryItemDisplayController;
      if IsDefined(controller) {
        this.m_selectedSlotIndex = controller.GetSlotIndex();
        this.Close(true);
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
  }

  private final func SetButtonHints() -> Void {
    this.AddButtonHints(n"UI_Apply", "UI-ResourceExports-Confirm");
    this.AddButtonHints(n"UI_Cancel", "UI-ResourceExports-Cancel");
  }

  private final func AddButtonHints(actionName: CName, label: String) -> Void {
    let buttonHint: ref<LabelInputDisplayController> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsRoot), inkWidgetLibraryResource.GetPath(this.m_libraryPath.widgetLibrary), this.m_libraryPath.widgetItem).GetController() as LabelInputDisplayController;
    buttonHint.SetInputActionLabel(actionName, label);
  }

  protected cb func OnHandlePressInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"cancel") {
      this.Close(false);
    };
  }

  protected cb func OnOkClick(controller: wref<inkButtonController>) -> Bool {
    this.Close(true);
  }

  protected cb func OnCancelClick(controller: wref<inkButtonController>) -> Bool {
    this.Close(false);
  }

  private final func Close(success: Bool) -> Void {
    this.m_closeData = new BackpackEquipSlotChooserCloseData();
    this.m_closeData.confirm = success;
    this.m_closeData.slotIndex = this.m_selectedSlotIndex;
    this.m_closeData.itemData = this.m_data.item;
    let closeAnimProxy: ref<inkAnimProxy> = this.PlayLibraryAnimation(n"backpack_equip_chooser_outro");
    closeAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnCloseAnimationFinished");
  }

  protected cb func OnCloseAnimationFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_data.token.TriggerCallback(this.m_closeData);
  }
}
