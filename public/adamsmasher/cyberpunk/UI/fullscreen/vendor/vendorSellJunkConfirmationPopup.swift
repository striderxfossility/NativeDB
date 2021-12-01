
public class VendorSellJunkPopup extends inkGameController {

  private edit let m_itemNameText: inkTextRef;

  private edit let m_buttonHintsRoot: inkWidgetRef;

  private edit let m_itemDisplayRef: inkWidgetRef;

  private edit let m_rairtyBar: inkWidgetRef;

  private edit let m_eqippedItemContainer: inkWidgetRef;

  private edit let m_itemPriceContainer: inkWidgetRef;

  private edit let m_itemPriceText: inkTextRef;

  private edit let m_root: inkWidgetRef;

  private edit let m_background: inkWidgetRef;

  private edit let m_sellItemsFullQuantity: inkTextRef;

  private edit let m_sellItemsLimitedQuantity: inkTextRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_gameData: ref<gameItemData>;

  protected edit let m_buttonOk: inkWidgetRef;

  protected edit let m_buttonCancel: inkWidgetRef;

  private let m_closeAnimProxy: ref<inkAnimProxy>;

  private let m_data: ref<VendorSellJunkPopupData>;

  private edit let m_libraryPath: inkWidgetLibraryReference;

  private let m_closeData: ref<VendorSellJunkPopupCloseData>;

  protected cb func OnInitialize() -> Bool {
    let fullQuantityParams: ref<inkTextParams>;
    let limitedQuantityParams: ref<inkTextParams>;
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
    this.m_data = this.GetRootWidget().GetUserData(n"VendorSellJunkPopupData") as VendorSellJunkPopupData;
    inkTextRef.SetText(this.m_itemNameText, "UI-PopupNotification-confirm_sell");
    inkWidgetRef.RegisterToCallback(this.m_buttonOk, n"OnButtonClick", this, n"OnOkClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonCancel, n"OnButtonClick", this, n"OnCancelClick");
    inkWidgetRef.SetVisible(this.m_root, true);
    inkWidgetRef.SetVisible(this.m_background, true);
    fullQuantityParams = new inkTextParams();
    limitedQuantityParams = new inkTextParams();
    fullQuantityParams.AddNumber("quantity", this.m_data.itemsQuantity);
    fullQuantityParams.AddNumber("value", RoundF(this.m_data.totalPrice));
    limitedQuantityParams.AddNumber("quantity", this.m_data.limitedItemsQuantity);
    limitedQuantityParams.AddNumber("value", this.m_data.limitedTotalPrice);
    inkTextRef.SetTextParameters(this.m_sellItemsFullQuantity, fullQuantityParams);
    inkTextRef.SetTextParameters(this.m_sellItemsLimitedQuantity, limitedQuantityParams);
    inkWidgetRef.SetVisible(this.m_sellItemsLimitedQuantity, this.m_data.itemsQuantity != this.m_data.limitedItemsQuantity);
    this.PlayLibraryAnimation(n"vendor_popup_sell_junk_intro");
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
    if evt.IsAction(n"proceed") {
      this.Close(true);
    } else {
      if evt.IsAction(n"cancel") {
        this.Close(false);
      };
    };
  }

  protected cb func OnOkClick(controller: wref<inkButtonController>) -> Bool {
    this.Close(true);
  }

  protected cb func OnCancelClick(controller: wref<inkButtonController>) -> Bool {
    this.Close(false);
  }

  private final func Close(success: Bool) -> Void {
    this.m_closeData = new VendorSellJunkPopupCloseData();
    this.m_closeData.confirm = success;
    this.m_closeData.items = this.m_data.items;
    this.m_closeData.limitedItems = this.m_data.limitedItems;
    if this.m_closeAnimProxy.IsPlaying() {
      this.m_closeAnimProxy.Stop();
    };
    this.m_closeAnimProxy = this.PlayLibraryAnimation(n"vendor_popup_sell_junk_outro");
    if this.m_closeAnimProxy.IsValid() {
      this.m_closeAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnCloseAnimationFinished");
    } else {
      this.OnCloseAnimationFinished(this.m_closeAnimProxy);
    };
  }

  protected cb func OnCloseAnimationFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_data.token.TriggerCallback(this.m_closeData);
  }
}
