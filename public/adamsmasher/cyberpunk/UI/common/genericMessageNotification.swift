
public class GenericMessageNotification extends inkGameController {

  private edit let m_title: inkTextRef;

  private edit let m_message: inkTextRef;

  private edit let m_buttonConfirm: inkWidgetRef;

  private edit let m_buttonCancel: inkWidgetRef;

  private edit let m_buttonOk: inkWidgetRef;

  private edit let m_buttonYes: inkWidgetRef;

  private edit let m_buttonNo: inkWidgetRef;

  private edit let m_root: inkWidgetRef;

  private edit let m_background: inkWidgetRef;

  private edit let m_buttonHintsRoot: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_data: ref<GenericMessageNotificationData>;

  private let m_isNegativeHovered: Bool;

  private let m_isPositiveHovered: Bool;

  private edit let m_libraryPath: inkWidgetLibraryReference;

  private let m_closeData: ref<GenericMessageNotificationCloseData>;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_root, true);
    inkWidgetRef.SetVisible(this.m_background, true);
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
    this.m_data = this.GetRootWidget().GetUserData(n"GenericMessageNotificationData") as GenericMessageNotificationData;
    inkWidgetRef.RegisterToCallback(this.m_buttonConfirm, n"OnRelease", this, n"OnConfirmClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonCancel, n"OnRelease", this, n"OnCancelClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonOk, n"OnRelease", this, n"OnOkClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonYes, n"OnRelease", this, n"OnYesClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonNo, n"OnRelease", this, n"OnNoClick");
    inkWidgetRef.RegisterToCallback(this.m_buttonConfirm, n"OnHoverOver", this, n"OnPositiveHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_buttonCancel, n"OnHoverOver", this, n"OnNegativeHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_buttonOk, n"OnHoverOver", this, n"OnPositiveHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_buttonYes, n"OnHoverOver", this, n"OnPositiveHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_buttonNo, n"OnHoverOver", this, n"OnNegativeHoverOver");
    inkWidgetRef.RegisterToCallback(this.m_buttonConfirm, n"OnHoverOut", this, n"OnPositiveHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_buttonCancel, n"OnHoverOut", this, n"OnNegativeHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_buttonOk, n"OnHoverOut", this, n"OnPositiveHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_buttonYes, n"OnHoverOut", this, n"OnPositiveHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_buttonNo, n"OnHoverOut", this, n"OnNegativeHoverOut");
    inkTextRef.SetText(this.m_title, this.m_data.title);
    inkTextRef.SetText(this.m_message, this.m_data.message);
    inkWidgetRef.SetVisible(this.m_buttonConfirm, false);
    inkWidgetRef.SetVisible(this.m_buttonCancel, false);
    inkWidgetRef.SetVisible(this.m_buttonOk, false);
    inkWidgetRef.SetVisible(this.m_buttonYes, false);
    inkWidgetRef.SetVisible(this.m_buttonNo, false);
    switch this.m_data.type {
      case GenericMessageNotificationType.OK:
        inkWidgetRef.SetVisible(this.m_buttonOk, true);
        break;
      case GenericMessageNotificationType.Confirm:
        inkWidgetRef.SetVisible(this.m_buttonConfirm, true);
        break;
      case GenericMessageNotificationType.Cancel:
        inkWidgetRef.SetVisible(this.m_buttonCancel, true);
        break;
      case GenericMessageNotificationType.ConfirmCancel:
        inkWidgetRef.SetVisible(this.m_buttonConfirm, true);
        inkWidgetRef.SetVisible(this.m_buttonCancel, true);
        break;
      case GenericMessageNotificationType.YesNo:
        inkWidgetRef.SetVisible(this.m_buttonYes, true);
        inkWidgetRef.SetVisible(this.m_buttonNo, true);
    };
    this.PlayLibraryAnimation(n"vendor_popup_sell_junk_intro");
    this.PlayLibraryAnimation(n"intro");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");
  }

  private final func AddButtonHints(actionName: CName, label: String) -> Void {
    let buttonHint: ref<LabelInputDisplayController> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsRoot), inkWidgetLibraryResource.GetPath(this.m_libraryPath.widgetLibrary), this.m_libraryPath.widgetItem).GetController() as LabelInputDisplayController;
    buttonHint.SetInputActionLabel(actionName, label);
  }

  protected cb func OnHandlePressInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"popup_goto") && !this.m_isNegativeHovered {
      if Equals(this.m_data.type, GenericMessageNotificationType.OK) {
        this.Close(GenericMessageNotificationResult.OK);
      } else {
        if Equals(this.m_data.type, GenericMessageNotificationType.Confirm) {
          this.Close(GenericMessageNotificationResult.Confirm);
        } else {
          if Equals(this.m_data.type, GenericMessageNotificationType.ConfirmCancel) {
            this.Close(GenericMessageNotificationResult.Confirm);
          } else {
            if Equals(this.m_data.type, GenericMessageNotificationType.YesNo) {
              this.Close(GenericMessageNotificationResult.Yes);
            };
          };
        };
      };
    } else {
      if evt.IsAction(n"cancel") || evt.IsAction(n"proceed") && this.m_isNegativeHovered {
        if Equals(this.m_data.type, GenericMessageNotificationType.Cancel) {
          this.Close(GenericMessageNotificationResult.Cancel);
        } else {
          if Equals(this.m_data.type, GenericMessageNotificationType.ConfirmCancel) {
            this.Close(GenericMessageNotificationResult.Cancel);
          } else {
            if Equals(this.m_data.type, GenericMessageNotificationType.YesNo) {
              this.Close(GenericMessageNotificationResult.No);
            };
          };
        };
      };
    };
  }

  protected cb func OnConfirmClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.Close(GenericMessageNotificationResult.Cancel);
    };
  }

  protected cb func OnCancelClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.Close(GenericMessageNotificationResult.Confirm);
    };
  }

  protected cb func OnOkClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.Close(GenericMessageNotificationResult.OK);
    };
  }

  protected cb func OnYesClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.Close(GenericMessageNotificationResult.Yes);
    };
  }

  protected cb func OnNoClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.Close(GenericMessageNotificationResult.No);
    };
  }

  protected cb func OnPositiveHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.m_isPositiveHovered = true;
  }

  protected cb func OnNegativeHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.m_isNegativeHovered = true;
  }

  protected cb func OnPositiveHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_isPositiveHovered = false;
  }

  protected cb func OnNegativeHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_isNegativeHovered = false;
  }

  private final func Close(result: GenericMessageNotificationResult) -> Void {
    this.m_closeData = new GenericMessageNotificationCloseData();
    this.m_closeData.identifier = this.m_data.identifier;
    this.m_closeData.result = result;
    this.PlayLibraryAnimation(n"outro");
    this.m_data.token.TriggerCallback(this.m_closeData);
  }

  protected cb func OnCloseAnimationFinished(proxy: ref<inkAnimProxy>) -> Bool;

  private final static func GetBaseData() -> ref<GenericMessageNotificationData> {
    let data: ref<GenericMessageNotificationData> = new GenericMessageNotificationData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\generic_fullscreen_message_notification.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    return data;
  }

  public final static func Show(controller: ref<worlduiIGameController>, title: String, message: String) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.title = title;
    data.message = message;
    return controller.ShowGameNotification(data);
  }

  public final static func Show(controller: ref<worlduiIGameController>, identifier: Int32, title: String, message: String) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.title = title;
    data.message = message;
    data.identifier = identifier;
    return controller.ShowGameNotification(data);
  }

  public final static func Show(controller: ref<worlduiIGameController>, message: String) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.message = message;
    return controller.ShowGameNotification(data);
  }

  public final static func Show(controller: ref<worlduiIGameController>, identifier: Int32, message: String) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.message = message;
    data.identifier = identifier;
    return controller.ShowGameNotification(data);
  }

  public final static func Show(controller: ref<worlduiIGameController>, title: String, message: String, type: GenericMessageNotificationType) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.title = title;
    data.message = message;
    data.type = type;
    return controller.ShowGameNotification(data);
  }

  public final static func Show(controller: ref<worlduiIGameController>, identifier: Int32, title: String, message: String, type: GenericMessageNotificationType) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.title = title;
    data.message = message;
    data.identifier = identifier;
    data.type = type;
    return controller.ShowGameNotification(data);
  }

  public final static func Show(controller: ref<worlduiIGameController>, message: String, type: GenericMessageNotificationType) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.message = message;
    data.type = type;
    return controller.ShowGameNotification(data);
  }

  public final static func Show(controller: ref<worlduiIGameController>, identifier: Int32, message: String, type: GenericMessageNotificationType) -> ref<inkGameNotificationToken> {
    let data: ref<GenericMessageNotificationData> = GenericMessageNotification.GetBaseData();
    data.message = message;
    data.identifier = identifier;
    data.type = type;
    return controller.ShowGameNotification(data);
  }
}
