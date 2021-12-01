
public class KeypadButtonSpawnData extends IScriptable {

  public let m_widgetName: CName;

  public let m_locKey: String;

  public let m_isActionButton: Bool;

  public let m_widgetData: SDeviceWidgetPackage;

  public final func Initialize(widgetName: CName, locKey: String, isActionButton: Bool, widgetData: SDeviceWidgetPackage) -> Void {
    this.m_widgetName = widgetName;
    this.m_locKey = locKey;
    this.m_isActionButton = isActionButton;
    this.m_widgetData = widgetData;
  }
}

public class KeypadDeviceController extends DeviceWidgetControllerBase {

  private let m_enteredPasswordWidget: wref<inkText>;

  private let m_passwordStatusWidget: wref<inkText>;

  private let m_actionButton: wref<inkWidget>;

  private let m_ActionText: wref<inkText>;

  private let m_passwordsList: array<CName>;

  private let m_cardName: String;

  private let m_isPasswordKnown: Bool;

  private let m_row1: wref<inkHorizontalPanel>;

  private let m_row2: wref<inkHorizontalPanel>;

  private let m_row3: wref<inkHorizontalPanel>;

  private let m_row4: wref<inkHorizontalPanel>;

  protected cb func OnInitialize() -> Bool {
    this.m_enteredPasswordWidget = this.GetWidget(n"safeArea/enteredPassword") as inkText;
    this.m_passwordStatusWidget = this.GetWidget(n"safeArea/passwordStatus") as inkText;
    this.m_row1 = this.GetWidget(n"safeArea/keypadButtonsVert/row1") as inkHorizontalPanel;
    this.m_row2 = this.GetWidget(n"safeArea/keypadButtonsVert/row2") as inkHorizontalPanel;
    this.m_row3 = this.GetWidget(n"safeArea/keypadButtonsVert/row3") as inkHorizontalPanel;
    this.m_row4 = this.GetWidget(n"safeArea/keypadButtonsVert/row4") as inkHorizontalPanel;
    this.m_enteredPasswordWidget.SetText("");
    this.m_passwordStatusWidget.SetLocalizedTextScript("LocKey#42212");
  }

  public func Initialize(gameController: ref<DeviceInkGameControllerBase>, widgetData: SDeviceWidgetPackage) -> Void {
    this.HideActionWidgets();
    inkTextRef.SetLocalizedTextScript(this.m_statusNameWidget, widgetData.deviceStatus, widgetData.textData);
    inkTextRef.SetLocalizedTextScript(this.m_displayNameWidget, widgetData.displayName);
    this.m_cardName = ToString((widgetData.customData as DoorWidgetCustomData).GetCardName());
    this.m_isPasswordKnown = (widgetData.customData as DoorWidgetCustomData).IsPasswordKnown();
    if !this.m_isInitialized {
      this.AddKeypadButtons(this.m_row1, 1, widgetData, gameController);
      this.AddKeypadButtons(this.m_row2, 2, widgetData, gameController);
      this.AddKeypadButtons(this.m_row3, 3, widgetData, gameController);
      this.AddKeypadButtons(this.m_row4, 4, widgetData, gameController);
    };
    if IsDefined(this.m_actionButton) && !this.CheckPassword() {
      this.m_passwordStatusWidget.SetState(n"Locked");
      inkWidgetRef.SetState(this.m_statusNameWidget, n"Locked");
    } else {
      if Equals(widgetData.widgetState, EWidgetState.ALLOWED) {
        this.m_passwordStatusWidget.SetState(n"Allowed");
        inkWidgetRef.SetState(this.m_statusNameWidget, n"Allowed");
      } else {
        if Equals(widgetData.widgetState, EWidgetState.LOCKED) {
          this.m_passwordStatusWidget.SetState(n"Locked");
          inkWidgetRef.SetState(this.m_statusNameWidget, n"Locked");
        } else {
          if Equals(widgetData.widgetState, EWidgetState.SEALED) {
            this.m_passwordStatusWidget.SetState(n"Sealed");
            inkWidgetRef.SetState(this.m_statusNameWidget, n"Sealed");
          } else {
            this.m_passwordStatusWidget.SetState(n"Allowed");
            inkWidgetRef.SetState(this.m_statusNameWidget, n"Allowed");
          };
        };
      };
    };
    this.m_isInitialized = true;
    if gameController != null {
      gameController.SetUICameraZoomState(true);
    };
  }

  private final func AddKeypadButtons(parentWidget: wref<inkWidget>, rowNumber: Int32, widgetData: SDeviceWidgetPackage, gameController: ref<DeviceInkGameControllerBase>) -> Void {
    let asyncSpawnData: ref<AsyncSpawnData>;
    let buttonSpawnData: ref<KeypadButtonSpawnData>;
    let i: Int32 = (rowNumber - 1) * 3 + 1;
    while i < (rowNumber - 1) * 3 + 4 {
      buttonSpawnData = new KeypadButtonSpawnData();
      switch i {
        case 1:
          buttonSpawnData.Initialize(n"1", "LocKey#910", false, widgetData);
          break;
        case 2:
          buttonSpawnData.Initialize(n"2", "LocKey#911", false, widgetData);
          break;
        case 3:
          buttonSpawnData.Initialize(n"3", "LocKey#912", false, widgetData);
          break;
        case 4:
          buttonSpawnData.Initialize(n"4", "LocKey#913", false, widgetData);
          break;
        case 5:
          buttonSpawnData.Initialize(n"5", "LocKey#914", false, widgetData);
          break;
        case 6:
          buttonSpawnData.Initialize(n"6", "LocKey#915", false, widgetData);
          break;
        case 7:
          buttonSpawnData.Initialize(n"7", "LocKey#916", false, widgetData);
          break;
        case 8:
          buttonSpawnData.Initialize(n"8", "LocKey#917", false, widgetData);
          break;
        case 9:
          buttonSpawnData.Initialize(n"9", "LocKey#918", false, widgetData);
          break;
        case 10:
          buttonSpawnData.Initialize(n"Cancel", "LocKey#920", false, widgetData);
          break;
        case 11:
          buttonSpawnData.Initialize(n"0", "LocKey#890", false, widgetData);
          break;
        case 12:
          buttonSpawnData.Initialize(n"ToggleAuthorization", "LocKey#53646", true, widgetData);
      };
      asyncSpawnData = new AsyncSpawnData();
      asyncSpawnData.Initialize(this, n"OnKeypadButtonWidgetSpawned", ToVariant(buttonSpawnData), gameController);
      this.CreateWidgetAsync(parentWidget, n"keypad_button", asyncSpawnData);
      i += 1;
    };
  }

  protected cb func OnKeypadButtonWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let actionWidget: ref<inkWidget>;
    let actionWidgetName: String;
    let buttonSpawnData: ref<KeypadButtonSpawnData>;
    let gameController: ref<DeviceInkGameControllerBase>;
    let i: Int32;
    let textWidget: ref<inkText>;
    let asyncSpawnData: ref<AsyncSpawnData> = userData as AsyncSpawnData;
    if !IsDefined(asyncSpawnData) {
      return false;
    };
    buttonSpawnData = FromVariant(asyncSpawnData.m_widgetData);
    if !IsDefined(buttonSpawnData) {
      return false;
    };
    widget.SetSizeRule(inkESizeRule.Stretch);
    textWidget = widget.GetController().GetWidget(n"displayName") as inkText;
    widget.RegisterToCallback(n"OnRelease", this, n"OnMouseButtonReleased");
    widget.SetName(buttonSpawnData.m_widgetName);
    textWidget.SetLocalizedTextScript(buttonSpawnData.m_locKey);
    if buttonSpawnData.m_isActionButton {
      gameController = asyncSpawnData.m_controller as DeviceInkGameControllerBase;
      if IsDefined(gameController) {
        this.m_actionButton = widget;
        i = 0;
        while i < ArraySize(buttonSpawnData.m_widgetData.actionWidgets) {
          actionWidgetName = buttonSpawnData.m_widgetData.actionWidgets[i].widgetName;
          if NotEquals(actionWidgetName, "AuthorizeUser") {
          } else {
            actionWidget = this.GetActionWidget(buttonSpawnData.m_widgetData.actionWidgets[i], gameController);
            this.m_passwordsList = (buttonSpawnData.m_widgetData.actionWidgets[i].action as AuthorizeUser).GetValidPasswords();
            if actionWidget == null {
              actionWidget = this.m_actionButton;
              this.AddActionWidget(actionWidget, buttonSpawnData.m_widgetData.actionWidgets[i], gameController);
            };
            this.ResolveAction(buttonSpawnData.m_widgetData.actionWidgets[i]);
            this.InitializeActionWidget(gameController, actionWidget, buttonSpawnData.m_widgetData.actionWidgets[i]);
            if !this.CheckPassword() {
              this.m_passwordStatusWidget.SetState(n"Locked");
              inkWidgetRef.SetState(this.m_statusNameWidget, n"Locked");
            };
            goto 1269;
          };
          i += 1;
        };
      };
    };
  }

  protected cb func OnMouseButtonReleased(e: ref<inkPointerEvent>) -> Bool {
    let button: wref<inkWidget>;
    if e.IsAction(n"click") {
      button = e.GetTarget();
      this.HandleButtonClicked(button);
    };
  }

  private final func HandleButtonClicked(button: wref<inkWidget>) -> Void {
    let buttonName: CName = button.GetName();
    let enteredPassword: String = this.m_enteredPasswordWidget.GetText();
    this.m_passwordStatusWidget.SetLocalizedTextString("LocKey#42212");
    if Equals(buttonName, n"ToggleAuthorization") && !this.CheckPassword() {
      this.m_passwordStatusWidget.SetLocalizedTextScript("LocKey#42213");
      this.m_passwordStatusWidget.SetState(n"Locked");
      inkWidgetRef.SetState(this.m_statusNameWidget, n"Locked");
      enteredPassword = "";
      this.m_enteredPasswordWidget.SetText(enteredPassword);
    } else {
      if Equals(buttonName, n"Cancel") {
        if NotEquals(this.m_enteredPasswordWidget.GetText(), "") {
          this.m_enteredPasswordWidget.SetText("");
        };
      } else {
        if (Equals(buttonName, n"1") || Equals(buttonName, n"2") || Equals(buttonName, n"3") || Equals(buttonName, n"4") || Equals(buttonName, n"5") || Equals(buttonName, n"6") || Equals(buttonName, n"0") || Equals(buttonName, n"7") || Equals(buttonName, n"8") || Equals(buttonName, n"9")) && StrLen(this.m_enteredPasswordWidget.GetText()) < 6 {
          enteredPassword = this.m_enteredPasswordWidget.GetText() + ToString(buttonName);
          this.m_enteredPasswordWidget.SetText(enteredPassword);
        };
      };
    };
    this.RefreshActionButtons();
  }

  private final func CheckPassword() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_passwordsList) {
      if Equals(StringToName(this.m_enteredPasswordWidget.GetText()), this.m_passwordsList[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func RefreshActionButtons() -> Void {
    let i: Int32;
    if this.CheckPassword() {
      i = 0;
      while i < ArraySize(this.m_actionWidgetsData) {
        this.ResolveAction(this.m_actionWidgetsData[i]);
        this.m_actionButton.CallCustomCallback(n"OnExecuteButtonAction");
        i += 1;
      };
      this.m_passwordStatusWidget.SetLocalizedTextScript("LocKey#42214");
      this.m_passwordStatusWidget.SetState(n"Allowed");
      inkWidgetRef.SetState(this.m_statusNameWidget, n"Allowed");
      this.m_actionButton.SetState(n"Press");
    } else {
      this.m_actionButton.SetState(n"Default");
      this.m_passwordStatusWidget.SetState(n"Locked");
      inkWidgetRef.SetState(this.m_statusNameWidget, n"Locked");
    };
  }

  protected func ResolveAction(widgetData: SActionWidgetPackage) -> Void {
    let data: ref<ResolveActionData> = new ResolveActionData();
    data.m_password = this.m_enteredPasswordWidget.GetText();
    let actions: array<wref<DeviceAction>> = (widgetData.widget.GetController() as DeviceActionWidgetControllerBase).GetActions();
    let action: ref<ScriptableDeviceAction> = actions[0] as ScriptableDeviceAction;
    action.ResolveAction(data);
  }
}
