
public class ItemQuantityPickerController extends inkGameController {

  protected edit let m_quantityTextMin: inkTextRef;

  protected edit let m_quantityTextMax: inkTextRef;

  protected edit let m_quantityTextChoosen: inkTextRef;

  protected edit let m_priceText: inkTextRef;

  protected edit let m_priceWrapper: inkWidgetRef;

  protected edit let m_weightText: inkTextRef;

  protected edit let m_itemNameText: inkTextRef;

  protected edit let m_itemQuantityText: inkTextRef;

  protected edit let m_rairtyBar: inkWidgetRef;

  protected edit let m_root: inkWidgetRef;

  protected edit let m_background: inkWidgetRef;

  private edit let m_buttonHintsRoot: inkWidgetRef;

  protected edit let m_slider: inkWidgetRef;

  protected edit let m_buttonOk: inkWidgetRef;

  protected edit let m_buttonCancel: inkWidgetRef;

  protected edit let m_buttonOkText: inkTextRef;

  protected edit let m_buttonLess: inkWidgetRef;

  protected edit let m_buttonMore: inkWidgetRef;

  private edit let m_libraryPath: inkWidgetLibraryReference;

  protected let m_maxValue: Int32;

  protected let m_gameData: InventoryItemData;

  protected let m_actionType: QuantityPickerActionType;

  protected let m_sliderController: wref<inkSliderController>;

  protected let m_choosenQuantity: Int32;

  protected let m_itemPrice: Int32;

  protected let m_itemWeight: Float;

  protected let m_isBuyback: Bool;

  protected let m_sendQuantityChangedEvent: Bool;

  private let m_data: ref<QuantityPickerPopupData>;

  private let m_isNegativeHovered: Bool;

  private let m_quantityChangedEvent: ref<PickerChoosenQuantityChangedEvent>;

  private let m_closeData: ref<QuantityPickerPopupCloseData>;

  protected cb func OnInitialize() -> Bool {
    this.m_sliderController = inkWidgetRef.GetController(this.m_slider) as inkSliderController;
    inkWidgetRef.GetController(this.m_buttonOk).RegisterToCallback(n"OnButtonClick", this, n"OnOkClick");
    inkWidgetRef.GetController(this.m_buttonCancel).RegisterToCallback(n"OnButtonClick", this, n"OnCancelClick");
    inkWidgetRef.GetController(this.m_buttonCancel).RegisterToCallback(n"OnHoverOver", this, n"OnNegativeHoverOver");
    inkWidgetRef.GetController(this.m_buttonCancel).RegisterToCallback(n"OnHoverOut", this, n"OnNegativeHoverOut");
    inkWidgetRef.GetController(this.m_buttonLess).RegisterToCallback(n"OnButtonClick", this, n"OnLessClick");
    inkWidgetRef.GetController(this.m_buttonMore).RegisterToCallback(n"OnButtonClick", this, n"OnMoreClick");
    this.m_sliderController.GetController().RegisterToCallback(n"OnSliderValueChanged", this, n"OnSliderValueChanged");
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
    this.RegisterToGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
    this.RegisterToGlobalInputCallback(n"OnPostOnRepeat", this, n"OnHandleRepeatInput");
    this.m_data = this.GetRootWidget().GetUserData(n"QuantityPickerPopupData") as QuantityPickerPopupData;
    inkWidgetRef.SetVisible(this.m_root, true);
    inkWidgetRef.SetVisible(this.m_background, true);
    this.SetData();
    this.SetButtonHints();
    this.PlayLibraryAnimation(n"vendor_quantity_popup_intro");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
  }

  private final func SetButtonHints() -> Void {
    this.AddButtonHints(n"UI_MoveLeft", "UI-PopupNotification-decrease_quantity");
    this.AddButtonHints(n"UI_MoveRight", "UI-PopupNotification-increase_quantity");
    this.AddButtonHints(n"popup_maxQuantity", "UI-PopupNotification-maximize_quantity");
    this.AddButtonHints(n"popup_halveQuantity", "UI-PopupNotification-halve_quantity");
  }

  private final func AddButtonHints(actionName: CName, label: String) -> Void {
    let buttonHint: ref<LabelInputDisplayController> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsRoot), inkWidgetLibraryResource.GetPath(this.m_libraryPath.widgetLibrary), this.m_libraryPath.widgetItem).GetController() as LabelInputDisplayController;
    buttonHint.SetInputActionLabel(actionName, label);
  }

  private final func SetData() -> Void {
    let itemRecord: ref<Item_Record>;
    this.m_maxValue = this.m_data.maxValue;
    this.m_gameData = this.m_data.gameItemData;
    this.m_actionType = this.m_data.actionType;
    this.m_isBuyback = this.m_data.isBuyback;
    this.m_sendQuantityChangedEvent = this.m_data.sendQuantityChangedEvent;
    if this.m_sendQuantityChangedEvent {
      this.m_quantityChangedEvent = new PickerChoosenQuantityChangedEvent();
    };
    this.m_choosenQuantity = 1;
    this.m_sliderController.Setup(1.00, Cast(this.m_maxValue), Cast(this.m_choosenQuantity), 1.00);
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_gameData)));
    inkTextRef.SetText(this.m_itemNameText, UIItemsHelper.GetItemName(itemRecord, InventoryItemData.GetGameItemData(this.m_gameData)));
    inkTextRef.SetText(this.m_quantityTextMax, IntToString(this.m_maxValue));
    inkTextRef.SetText(this.m_quantityTextMin, "1");
    inkTextRef.SetText(this.m_quantityTextChoosen, IntToString(this.m_choosenQuantity));
    inkWidgetRef.SetVisible(this.m_priceText, IsDefined(this.m_data.vendor));
    if IsDefined(this.m_data.vendor) {
      this.m_itemPrice = Equals(this.m_actionType, QuantityPickerActionType.Buy) ? MarketSystem.GetBuyPrice(this.m_data.vendor, InventoryItemData.GetGameItemData(this.m_gameData).GetID()) : RPGManager.CalculateSellPrice(this.m_data.vendor.GetGame(), this.m_data.vendor, InventoryItemData.GetGameItemData(this.m_gameData).GetID());
    };
    this.m_itemWeight = InventoryItemData.GetGameItemData(this.m_gameData).GetStatValueByType(gamedataStatType.Weight);
    switch this.m_actionType {
      case QuantityPickerActionType.Drop:
        inkTextRef.SetText(this.m_buttonOkText, "UI-ScriptExports-Drop0");
        inkWidgetRef.SetVisible(this.m_priceWrapper, false);
        break;
      case QuantityPickerActionType.Disassembly:
        inkTextRef.SetText(this.m_buttonOkText, "Gameplay-Devices-DisplayNames-DisassemblableItem");
        inkWidgetRef.SetVisible(this.m_priceWrapper, false);
        break;
      case QuantityPickerActionType.Craft:
        inkTextRef.SetText(this.m_buttonOkText, "UI-Crafting-CraftItem");
        inkWidgetRef.SetVisible(this.m_priceWrapper, false);
        break;
      case QuantityPickerActionType.TransferToStorage:
      case QuantityPickerActionType.TransferToPlayer:
        inkWidgetRef.SetVisible(this.m_priceWrapper, false);
        break;
      default:
        inkTextRef.SetText(this.m_buttonOkText, "LocKey#22269");
    };
    inkWidgetRef.SetVisible(this.m_priceWrapper, true);
    if !InventoryItemData.IsEmpty(this.m_gameData) {
      inkWidgetRef.SetState(this.m_rairtyBar, InventoryItemData.GetQuality(this.m_gameData));
    } else {
      inkWidgetRef.SetState(this.m_rairtyBar, n"Common");
    };
    this.UpdatePriceText();
    this.UpdateWeight();
    this.GetRootWidget().SetVisible(true);
  }

  protected final func UpdatePriceText() -> Void {
    if inkWidgetRef.IsVisible(this.m_priceText) {
      inkTextRef.SetText(this.m_priceText, IntToString(this.m_itemPrice * this.m_choosenQuantity));
    };
  }

  protected final func UpdateWeight() -> Void {
    let weight: Float = this.m_itemWeight * Cast(this.m_choosenQuantity);
    inkTextRef.SetText(this.m_weightText, FloatToStringPrec(weight, 0));
  }

  protected cb func OnLessClick(controller: wref<inkButtonController>) -> Bool {
    if this.m_choosenQuantity > 1 {
      this.m_choosenQuantity -= 1;
      this.UpdateProgress();
    };
  }

  protected cb func OnMoreClick(controller: wref<inkButtonController>) -> Bool {
    if this.m_choosenQuantity < this.m_maxValue {
      this.m_choosenQuantity += 1;
      this.UpdateProgress();
    };
  }

  protected cb func OnHandlePressInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"popup_moveRight") && this.m_choosenQuantity < this.m_maxValue {
      this.m_choosenQuantity += 1;
      this.UpdateProgress();
    } else {
      if evt.IsAction(n"popup_moveLeft") && this.m_choosenQuantity > 1 {
        this.m_choosenQuantity -= 1;
        this.UpdateProgress();
      } else {
        if evt.IsAction(n"popup_maxQuantity") && this.m_choosenQuantity < this.m_maxValue {
          this.m_choosenQuantity = this.m_maxValue;
          this.UpdateProgress();
        } else {
          if evt.IsAction(n"popup_halveQuantity") && this.m_choosenQuantity > 1 {
            this.m_choosenQuantity = this.m_choosenQuantity / 2;
            this.UpdateProgress();
          } else {
            if evt.IsAction(n"one_click_confirm") && !this.m_isNegativeHovered {
              this.Close(true);
            } else {
              if evt.IsAction(n"cancel") {
                this.Close(false);
              };
            };
          };
        };
      };
    };
  }

  protected cb func OnNegativeHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.m_isNegativeHovered = true;
  }

  protected cb func OnNegativeHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_isNegativeHovered = false;
  }

  protected cb func OnHandleRepeatInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"popup_moveRight") && this.m_choosenQuantity < this.m_maxValue {
      this.m_choosenQuantity += 1;
      this.UpdateProgress();
    } else {
      if evt.IsAction(n"popup_moveLeft") && this.m_choosenQuantity > 1 {
        this.m_choosenQuantity -= 1;
        this.UpdateProgress();
      };
    };
  }

  protected cb func OnAxisInput(evt: ref<inkPointerEvent>) -> Bool {
    let delta: Float = evt.GetAxisData() * MaxF(0.03, 1.30 / MaxF(Cast(this.m_maxValue), 1.00));
    if evt.IsAction(n"popup_axisX_right") {
      this.m_sliderController.ChangeProgress(this.m_sliderController.GetProgress() + delta);
    };
  }

  protected final func UpdateProgress() -> Void {
    this.m_sliderController.ChangeProgress(Cast(this.m_choosenQuantity - 1) / Cast(this.m_maxValue - 1));
    inkTextRef.SetText(this.m_quantityTextChoosen, IntToString(this.m_choosenQuantity));
    this.UpdatePriceText();
    this.UpdateWeight();
    if this.m_sendQuantityChangedEvent {
      this.m_quantityChangedEvent.choosenQuantity = this.m_choosenQuantity;
      this.m_data.token.TriggerCallback(this.m_quantityChangedEvent);
    };
  }

  protected cb func OnOkClick(controller: wref<inkButtonController>) -> Bool {
    this.Close(true);
  }

  protected cb func OnCancelClick(controller: wref<inkButtonController>) -> Bool {
    this.Close(false);
  }

  protected cb func OnSliderValueChanged(controller: wref<inkSliderController>, progress: Float, value: Float) -> Bool {
    this.m_choosenQuantity = RoundF(Cast(this.m_maxValue - 1) * progress) + 1;
    inkTextRef.SetText(this.m_quantityTextChoosen, IntToString(this.m_choosenQuantity));
    this.UpdatePriceText();
    this.UpdateWeight();
    if this.m_sendQuantityChangedEvent {
      this.m_quantityChangedEvent.choosenQuantity = this.m_choosenQuantity;
      this.m_data.token.TriggerCallback(this.m_quantityChangedEvent);
    };
  }

  private final func Close(success: Bool) -> Void {
    this.m_closeData = new QuantityPickerPopupCloseData();
    this.m_closeData.choosenQuantity = success ? this.m_choosenQuantity : -1;
    this.m_closeData.itemData = this.m_gameData;
    this.m_closeData.actionType = this.m_actionType;
    this.m_closeData.isBuyback = this.m_isBuyback;
    let closeAnimProxy: ref<inkAnimProxy> = this.PlayLibraryAnimation(n"vendor_quantity_popup_outro");
    closeAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnCloseAnimationFinished");
  }

  protected cb func OnCloseAnimationFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_data.token.TriggerCallback(this.m_closeData);
  }
}
