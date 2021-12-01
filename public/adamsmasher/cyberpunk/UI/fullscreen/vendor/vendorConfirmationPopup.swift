
public class VendorConfirmationPopup extends inkGameController {

  private edit let m_itemNameText: inkTextRef;

  private edit let m_buttonHintsRoot: inkWidgetRef;

  private edit let m_itemDisplayRef: inkWidgetRef;

  private edit let m_rairtyBar: inkWidgetRef;

  private edit let m_eqippedItemContainer: inkWidgetRef;

  private edit let m_itemPriceContainer: inkWidgetRef;

  private edit let m_itemPriceText: inkTextRef;

  private edit let m_root: inkWidgetRef;

  private edit let m_background: inkWidgetRef;

  private let m_closeData: ref<VendorConfirmationPopupCloseData>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_gameData: ref<gameItemData>;

  protected edit let m_buttonOk: inkWidgetRef;

  protected edit let m_buttonCancel: inkWidgetRef;

  private let m_data: ref<VendorConfirmationPopupData>;

  private let m_itemDisplayController: wref<InventoryItemDisplayController>;

  private edit let m_libraryPath: inkWidgetLibraryReference;

  protected cb func OnInitialize() -> Bool {
    let headerText: String;
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
    this.m_data = this.GetRootWidget().GetUserData(n"VendorConfirmationPopupData") as VendorConfirmationPopupData;
    this.m_itemDisplayController = inkWidgetRef.GetController(this.m_itemDisplayRef) as InventoryItemDisplayController;
    this.m_itemDisplayController.Setup(this.m_data.itemData);
    switch this.m_data.type {
      case VendorConfirmationPopupType.BuyAndEquipCyberware:
        headerText = "UI-PopupNotification-BuyAndEquipeCyberware";
        break;
      case VendorConfirmationPopupType.BuyNotEquipableCyberware:
        headerText = "UI-PopupNotification-BuyNotEqupableCyberware";
        break;
      case VendorConfirmationPopupType.DisassembeIconic:
        headerText = "UI-PopupNotification-dissembling_iconic";
        break;
      default:
        headerText = "UI-PopupNotification-confirm_sell";
    };
    inkTextRef.SetText(this.m_itemNameText, headerText);
    inkWidgetRef.RegisterToCallback(this.m_buttonOk, n"OnRelease", this, n"OnOkClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonCancel, n"OnRelease", this, n"OnCancelClick");
    inkWidgetRef.SetVisible(this.m_root, true);
    inkWidgetRef.SetVisible(this.m_background, true);
    if !InventoryItemData.IsEmpty(this.m_data.itemData) {
      inkWidgetRef.SetState(this.m_rairtyBar, InventoryItemData.GetQuality(this.m_data.itemData));
    } else {
      inkWidgetRef.SetState(this.m_rairtyBar, n"Common");
    };
    inkWidgetRef.SetVisible(this.m_eqippedItemContainer, Equals(this.m_data.type, VendorConfirmationPopupType.EquippedItem));
    if this.m_data.price > 0 {
      inkWidgetRef.SetVisible(this.m_itemPriceContainer, true);
      inkTextRef.SetText(this.m_itemPriceText, IntToString(this.m_data.price));
    } else {
      inkWidgetRef.SetVisible(this.m_itemPriceContainer, false);
    };
    this.PlayLibraryAnimation(n"vendor_popup_confirmation_intro");
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
    if evt.IsAction(n"one_click_confirm") {
      this.Close(true);
    } else {
      if evt.IsAction(n"cancel") {
        this.Close(false);
      };
    };
  }

  protected cb func OnOkClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.Close(true);
    };
  }

  protected cb func OnCancelClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.Close(false);
    };
  }

  private final func Close(success: Bool) -> Void {
    this.m_closeData = new VendorConfirmationPopupCloseData();
    this.m_closeData.confirm = success;
    this.m_closeData.itemData = this.m_data.itemData;
    this.m_closeData.quantity = this.m_data.quantity;
    let closeAnimProxy: ref<inkAnimProxy> = this.PlayLibraryAnimation(n"vendr_popup_confirmation_outro");
    closeAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnCloseAnimationFinished");
  }

  protected cb func OnCloseAnimationFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_data.token.TriggerCallback(this.m_closeData);
  }
}
