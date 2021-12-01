
public class SettingsCategoryController extends inkLogicController {

  protected edit let m_label: inkTextRef;

  public final func Setup(label: CName) -> Void {
    let labelString: String = GetLocalizedTextByKey(label);
    if StrLen(labelString) == 0 {
      labelString = "<Not Localized> " + ToString(label);
    };
    inkTextRef.SetText(this.m_label, labelString);
  }
}

public class SettingsVarListener extends ConfigVarListener {

  private let m_ctrl: wref<SettingsMainGameController>;

  public final func RegisterController(ctrl: ref<SettingsMainGameController>) -> Void {
    this.m_ctrl = ctrl;
  }

  public func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    Log("SettingsVarListener::OnVarModified");
    this.m_ctrl.OnVarModified(groupPath, varName, varType, reason);
  }
}

public class SettingsNotificationListener extends ConfigNotificationListener {

  private let m_ctrl: wref<SettingsMainGameController>;

  public final func RegisterController(ctrl: ref<SettingsMainGameController>) -> Void {
    this.m_ctrl = ctrl;
  }

  public func OnNotify(status: ConfigNotificationType) -> Void {
    Log("SettingsNotificationListener::OnNotify");
    this.m_ctrl.OnSettingsNotify(status);
  }
}

public class SettingsMainGameController extends gameuiMenuGameController {

  private edit let m_scrollPanel: inkWidgetRef;

  private edit let m_selectorWidget: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_settingsOptionsList: inkCompoundRef;

  private edit let m_applyButton: inkWidgetRef;

  private edit let m_resetButton: inkWidgetRef;

  private edit let m_defaultButton: inkWidgetRef;

  private edit let m_brightnessButton: inkWidgetRef;

  private edit let m_hdrButton: inkWidgetRef;

  private edit let m_controllerButton: inkWidgetRef;

  private edit let m_descriptionText: inkTextRef;

  private edit let m_previousButtonHint: inkWidgetRef;

  private edit let m_nextButtonHint: inkWidgetRef;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_settingsElements: array<wref<SettingsSelectorController>>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_data: array<SettingsCategory>;

  private let m_menusList: array<CName>;

  private let m_eventsList: array<CName>;

  private let m_settingsListener: ref<SettingsVarListener>;

  private let m_settingsNotificationListener: ref<SettingsNotificationListener>;

  private let m_settings: ref<UserSettings>;

  private let m_isPreGame: Bool;

  private let m_applyButtonEnabled: Bool;

  private let m_resetButtonEnabled: Bool;

  private let m_closeSettingsRequest: Bool;

  private let m_resetSettingsRequest: Bool;

  private let m_isDlcSettings: Bool;

  private let m_selectorCtrl: wref<ListController>;

  protected cb func OnInitialize() -> Bool {
    this.m_settings = this.GetSystemRequestsHandler().GetUserSettings();
    this.m_isPreGame = this.GetSystemRequestsHandler().IsPreGame();
    this.m_settingsListener = new SettingsVarListener();
    this.m_settingsListener.RegisterController(this);
    this.m_settingsNotificationListener = new SettingsNotificationListener();
    this.m_settingsNotificationListener.RegisterController(this);
    this.m_settingsNotificationListener.Register();
    if !this.m_isDlcSettings {
      this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
      inkWidgetRef.GetControllerByType(this.m_applyButton, n"inkButtonController").RegisterToCallback(n"OnButtonClick", this, n"OnApplyButtonReleased");
      inkWidgetRef.GetControllerByType(this.m_resetButton, n"inkButtonController").RegisterToCallback(n"OnButtonClick", this, n"OnResetButtonReleased");
      inkWidgetRef.GetControllerByType(this.m_brightnessButton, n"inkButtonController").RegisterToCallback(n"OnButtonClick", this, n"OnBrightnessButtonReleased");
      inkWidgetRef.GetControllerByType(this.m_hdrButton, n"inkButtonController").RegisterToCallback(n"OnButtonClick", this, n"OnHDRButtonReleased");
      inkWidgetRef.GetControllerByType(this.m_controllerButton, n"inkButtonController").RegisterToCallback(n"OnButtonClick", this, n"OnControllerButtonReleased");
      inkWidgetRef.GetControllerByType(this.m_defaultButton, n"inkButtonController").RegisterToCallback(n"OnButtonClick", this, n"OnDefaultButtonReleased");
    } else {
      inkWidgetRef.SetVisible(this.m_defaultButton, false);
      inkWidgetRef.SetVisible(this.m_controllerButton, false);
      inkWidgetRef.SetVisible(this.m_previousButtonHint, false);
      inkWidgetRef.SetVisible(this.m_nextButtonHint, false);
    };
    this.m_selectorCtrl = inkWidgetRef.GetController(this.m_selectorWidget) as ListController;
    this.m_selectorCtrl.RegisterToCallback(n"OnItemActivated", this, n"OnMenuChanged");
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.PopulateHints();
    this.PopulateSettingsData();
    this.PopulateCategories(this.m_settings.GetMenuIndex());
    this.DisableApplyButton();
    this.DisableResetButton();
    this.CheckHDRSettingVisibility();
    this.PlayLibraryAnimation(n"intro");
    this.m_closeSettingsRequest = false;
    this.m_resetSettingsRequest = false;
    if this.m_isPreGame {
      this.GetSystemRequestsHandler().RequestTelemetryConsent(true);
    };
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let settingsUserData: ref<SettingsMenuUserData> = userData as SettingsMenuUserData;
    if IsDefined(settingsUserData) {
      this.m_isDlcSettings = settingsUserData.m_isDlcSettings;
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
    this.m_selectorCtrl.UnregisterFromCallback(n"OnItemActivated", this, n"OnMenuChanged");
    inkWidgetRef.GetControllerByType(this.m_applyButton, n"inkButtonController").UnregisterFromCallback(n"OnButtonClick", this, n"OnApplyButtonReleased");
    inkWidgetRef.GetControllerByType(this.m_resetButton, n"inkButtonController").UnregisterFromCallback(n"OnButtonClick", this, n"OnResetButtonReleased");
    inkWidgetRef.GetControllerByType(this.m_brightnessButton, n"inkButtonController").UnregisterFromCallback(n"OnButtonClick", this, n"OnBrightnessButtonReleased");
    inkWidgetRef.GetControllerByType(this.m_controllerButton, n"inkButtonController").UnregisterFromCallback(n"OnButtonClick", this, n"OnControllerButtonReleased");
    inkWidgetRef.GetControllerByType(this.m_defaultButton, n"inkButtonController").RegisterToCallback(n"OnButtonClick", this, n"OnDefaultButtonReleased");
  }

  public final func EnableApplyButton() -> Void {
    inkWidgetRef.SetVisible(this.m_applyButton, true);
    this.m_applyButtonEnabled = true;
  }

  public final func DisableApplyButton() -> Void {
    this.m_applyButtonEnabled = false;
    inkWidgetRef.SetVisible(this.m_applyButton, false);
  }

  public final func IsApplyButtonEnabled() -> Bool {
    return this.m_applyButtonEnabled;
  }

  public final func EnableResetButton() -> Void {
    this.m_resetButtonEnabled = true;
    inkWidgetRef.SetVisible(this.m_resetButton, true);
  }

  public final func DisableResetButton() -> Void {
    this.m_resetButtonEnabled = false;
    inkWidgetRef.SetVisible(this.m_resetButton, false);
  }

  public final func IsResetButtonEnabled() -> Bool {
    return this.m_resetButtonEnabled;
  }

  public final func CheckButtons() -> Void {
    if !this.m_isDlcSettings && (this.m_settings.NeedsConfirmation() || this.m_settings.NeedsRestartToApply() || this.m_settings.NeedsLoadLastCheckpoint()) {
      this.EnableApplyButton();
      this.EnableResetButton();
    } else {
      this.DisableApplyButton();
      this.DisableResetButton();
    };
    this.CheckHDRSettingVisibility();
  }

  public final func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    let i: Int32;
    let item: ref<SettingsSelectorController>;
    let size: Int32;
    Log("[VAR] modified groupPath: " + NameToString(groupPath) + " varName: " + NameToString(varName));
    size = ArraySize(this.m_settingsElements);
    this.CheckButtons();
    i = 0;
    while i < size {
      item = this.m_settingsElements[i];
      if Equals(item.GetGroupPath(), groupPath) && Equals(item.GetVarName(), varName) {
        item.Refresh();
      };
      i += 1;
    };
  }

  public final func OnSettingsNotify(status: ConfigNotificationType) -> Void {
    switch status {
      case ConfigNotificationType.RestartRequiredConfirmed:
      case ConfigNotificationType.ChangesApplied:
      case ConfigNotificationType.Saved:
        this.CheckSettings();
        this.PopulateSettingsData();
        this.PopulateCategorySettingsOptions(-1);
        this.RefreshInputIcons();
        break;
      case ConfigNotificationType.ChangesLoadLastCheckpointApplied:
        this.CheckSettings();
        this.PopulateSettingsData();
        this.PopulateCategorySettingsOptions(-1);
        GameInstance.GetTelemetrySystem(this.GetPlayerControlledObject().GetGame()).LogLastCheckpointLoaded();
        this.GetSystemRequestsHandler().LoadLastCheckpoint(true);
        this.RefreshInputIcons();
        break;
      case ConfigNotificationType.ChangesLoadLastCheckpointRejected:
      case ConfigNotificationType.RestartRequiredRejected:
      case ConfigNotificationType.ChangesRejected:
        this.m_closeSettingsRequest = false;
        this.CheckSettings();
        this.PopulateSettingsData();
        this.PopulateCategorySettingsOptions(-1);
        this.RefreshInputIcons();
        break;
      case ConfigNotificationType.ErrorSaving:
        this.RequestClose();
        break;
      case ConfigNotificationType.Refresh:
        this.PopulateSettingsData();
        this.PopulateCategorySettingsOptions(-1);
        this.RefreshInputIcons();
    };
  }

  private final func CheckHDRSettingVisibility() -> Void {
    let option: ref<ConfigVarListString> = this.m_settings.GetVar(n"/video/display", n"HDRModes") as ConfigVarListString;
    if this.m_isDlcSettings {
      inkWidgetRef.SetVisible(this.m_hdrButton, false);
      inkWidgetRef.SetVisible(this.m_brightnessButton, false);
    } else {
      if option.GetIndex() > 0 {
        inkWidgetRef.SetVisible(this.m_hdrButton, true);
        inkWidgetRef.SetVisible(this.m_brightnessButton, false);
      } else {
        inkWidgetRef.SetVisible(this.m_hdrButton, false);
        inkWidgetRef.SetVisible(this.m_brightnessButton, true);
      };
    };
  }

  private final func AddSettingsGroup(settingsGroup: ref<ConfigGroup>) -> Void {
    let category: SettingsCategory;
    let currentSettingsGroup: ref<ConfigGroup>;
    let currentSubcategory: SettingsCategory;
    let i: Int32;
    let settingsGroups: array<ref<ConfigGroup>>;
    category.label = settingsGroup.GetDisplayName();
    category.groupPath = settingsGroup.GetPath();
    if settingsGroup.HasVars(this.m_isPreGame) {
      category.options = settingsGroup.GetVars(this.m_isPreGame);
      category.isEmpty = false;
    };
    settingsGroups = settingsGroup.GetGroups(this.m_isPreGame);
    i = 0;
    while i < ArraySize(settingsGroups) {
      currentSettingsGroup = settingsGroups[i];
      if currentSettingsGroup.IsEmpty(this.m_isPreGame) {
      } else {
        if currentSettingsGroup.HasVars(this.m_isPreGame) {
          currentSubcategory.label = currentSettingsGroup.GetDisplayName();
          currentSubcategory.options = currentSettingsGroup.GetVars(this.m_isPreGame);
          currentSubcategory.isEmpty = false;
          ArrayPush(category.subcategories, currentSubcategory);
          category.isEmpty = false;
          this.m_settingsListener.Register(currentSettingsGroup.GetPath());
        };
      };
      i += 1;
    };
    if !category.isEmpty {
      ArrayPush(this.m_data, category);
      this.m_settingsListener.Register(settingsGroup.GetPath());
    };
  }

  private final func PopulateSettingsData() -> Void {
    let i: Int32;
    let rootGroup: ref<ConfigGroup> = this.m_settings.GetRootGroup();
    let allgroups: array<ref<ConfigGroup>> = rootGroup.GetGroups(this.m_isPreGame);
    ArrayClear(this.m_data);
    i = 0;
    while i < ArraySize(allgroups) {
      this.AddSettingsGroup(allgroups[i]);
      i += 1;
    };
  }

  private final func PopulateCategories(idx: Int32) -> Void {
    let curCategoty: SettingsCategory;
    let i: Int32;
    let newData: ref<ListItemData>;
    this.m_selectorCtrl.Clear();
    i = 0;
    while i < ArraySize(this.m_data) {
      curCategoty = this.m_data[i];
      if !curCategoty.isEmpty {
        newData = new ListItemData();
        newData.label = GetLocalizedTextByKey(curCategoty.label);
        if StrLen(newData.label) == 0 {
          newData.label = "<Not Localized> " + ToString(curCategoty.label);
        };
        this.m_selectorCtrl.PushData(newData);
      };
      i += 1;
    };
    this.m_selectorCtrl.Refresh();
    if idx >= 0 && idx < ArraySize(this.m_data) {
      this.m_selectorCtrl.SetToggledIndex(idx);
    } else {
      this.m_selectorCtrl.SetToggledIndex(0);
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_closeSettingsRequest = true;
      this.CheckSettings();
    };
  }

  private final func RequestClose() -> Void {
    this.m_menuEventDispatcher.SpawnEvent(n"OnCloseSettingsScreen");
  }

  private final func RequestRestoreDefaults() -> Void {
    let index: Int32 = this.m_selectorCtrl.GetToggledIndex();
    let groupPath: CName = this.m_data[index].groupPath;
    this.m_settings.RequestRestoreDefaultDialog(this.m_isPreGame, false, groupPath);
  }

  private final func CheckSettings() -> Void {
    if this.m_resetSettingsRequest {
      this.CheckRejectSettings();
    } else {
      this.CheckAcceptSettings();
    };
  }

  private final func CheckRejectSettings() -> Void {
    if this.m_settings.NeedsConfirmation() {
      this.m_settings.RejectChanges();
    } else {
      if this.m_settings.NeedsRestartToApply() {
        this.m_settings.RejectRestartToApply();
      } else {
        if this.m_settings.NeedsLoadLastCheckpoint() {
          this.m_settings.RejectLoadLastCheckpointChanges();
        } else {
          this.m_resetSettingsRequest = false;
          if this.m_closeSettingsRequest {
            this.m_closeSettingsRequest = false;
            this.RequestClose();
          };
        };
      };
    };
  }

  private final func CheckAcceptSettings() -> Void {
    if this.m_settings.WasModifiedSinceLastSave() {
      if this.m_settings.NeedsConfirmation() {
        this.m_settings.RequestConfirmationDialog();
      } else {
        if this.m_settings.NeedsRestartToApply() {
          this.m_settings.RequestNeedsRestartDialog();
        } else {
          if this.m_settings.NeedsLoadLastCheckpoint() {
            this.m_settings.RequestLoadLastCheckpointDialog();
          } else {
            this.GetSystemRequestsHandler().RequestSaveUserSettings();
            GameInstance.GetTelemetrySystem(this.GetPlayerControlledObject().GetGame()).OnSettingsSave();
            if this.m_closeSettingsRequest {
              this.m_closeSettingsRequest = false;
              this.RequestClose();
            };
          };
        };
      };
    } else {
      if this.m_closeSettingsRequest {
        this.m_closeSettingsRequest = false;
        this.RequestClose();
      };
    };
  }

  protected cb func OnMenuChanged(index: Int32, target: ref<ListItemController>) -> Bool {
    this.PlaySound(n"Button", n"OnPress");
    this.PopulateCategorySettingsOptions(index);
    (inkWidgetRef.GetController(this.m_scrollPanel) as inkScrollController).SetScrollPosition(0.00);
    this.m_settings.SetMenuIndex(index);
  }

  protected cb func OnApplyButtonReleased(controller: wref<inkButtonController>) -> Bool {
    this.OnApplyButton();
  }

  protected cb func OnResetButtonReleased(controller: wref<inkButtonController>) -> Bool {
    this.OnResetButton();
  }

  protected cb func OnBrightnessButtonReleased(controller: wref<inkButtonController>) -> Bool {
    this.ShowBrightnessScreen();
  }

  protected cb func OnHDRButtonReleased(controller: wref<inkButtonController>) -> Bool {
    this.ShowHDRScreen();
  }

  protected cb func OnControllerButtonReleased(controller: wref<inkButtonController>) -> Bool {
    this.ShowControllerScreen();
  }

  protected cb func OnDefaultButtonReleased(controller: wref<inkButtonController>) -> Bool {
    this.RequestRestoreDefaults();
  }

  protected cb func OnLocalizationChanged(evt: ref<inkLocalizationChangedEvent>) -> Bool {
    let idx: Int32 = this.m_selectorCtrl.GetToggledIndex();
    this.PopulateCategories(idx);
    this.PopulateCategorySettingsOptions(idx);
    this.PopulateHints();
  }

  private final func PopulateHints() -> Void {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"select", "UI-UserActions-Select");
    this.m_buttonHintsController.AddButtonHint(n"back", "Common-Access-Close");
    if !this.m_isDlcSettings {
      this.m_buttonHintsController.AddButtonHint(n"restore_default_settings", "UI-UserActions-RestoreDefaults");
    };
  }

  private final func OnApplyButton() -> Void {
    if !this.IsApplyButtonEnabled() {
      return;
    };
    Log("OnApplyButton");
    if this.m_settings.NeedsConfirmation() {
      this.m_settings.ConfirmChanges();
    } else {
      this.CheckSettings();
    };
  }

  private final func OnResetButton() -> Void {
    if !this.IsResetButtonEnabled() {
      return;
    };
    Log("OnResetButton");
    this.m_resetSettingsRequest = true;
    this.CheckSettings();
  }

  private final func ShowBrightnessScreen() -> Void {
    Log("ShowBrightnessScreen");
    this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToBrightnessSettings");
  }

  private final func ShowHDRScreen() -> Void {
    Log("ShowHDRScreen");
    this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToHDRSettings");
  }

  private final func ShowControllerScreen() -> Void {
    Log("ShowControllerScreen");
    this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToControllerPanel");
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    let currentToggledIndex: Int32;
    let listSize: Int32 = this.m_selectorCtrl.Size();
    if evt.IsAction(n"prior_menu") {
      currentToggledIndex = this.m_selectorCtrl.GetToggledIndex();
      if currentToggledIndex < 1 {
        this.m_selectorCtrl.SetToggledIndex(listSize - 1);
      } else {
        this.m_selectorCtrl.SetToggledIndex(currentToggledIndex - 1);
      };
    } else {
      if evt.IsAction(n"next_menu") {
        currentToggledIndex = this.m_selectorCtrl.GetToggledIndex();
        if currentToggledIndex >= this.m_selectorCtrl.Size() - 1 {
          this.m_selectorCtrl.SetToggledIndex(0);
        } else {
          this.m_selectorCtrl.SetToggledIndex(currentToggledIndex + 1);
        };
      } else {
        if evt.IsAction(n"brightness_settings") {
          if inkWidgetRef.IsVisible(this.m_hdrButton) {
            this.ShowHDRScreen();
          } else {
            this.ShowBrightnessScreen();
          };
        } else {
          if evt.IsAction(n"controller_settings") {
            this.ShowControllerScreen();
          } else {
            if evt.IsAction(n"restore_default_settings") {
              this.RequestRestoreDefaults();
            } else {
              return false;
            };
          };
        };
      };
    };
  }

  protected cb func OnSettingHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let descriptionName: CName;
    let params: ref<inkTextParams>;
    let updatePolicy: ConfigVarUpdatePolicy;
    let currentItem: wref<SettingsSelectorController> = evt.GetCurrentTarget().GetController() as SettingsSelectorController;
    if IsDefined(currentItem) {
      descriptionName = currentItem.GetDescription();
      updatePolicy = currentItem.GetVarUpdatePolicy();
      if Equals(updatePolicy, ConfigVarUpdatePolicy.ConfirmationRequired) {
        params = new inkTextParams();
        params.AddLocalizedName("description", descriptionName);
        params.AddLocalizedString("additional_text", "LocKey#76947");
        inkTextRef.SetLocalizedTextScript(this.m_descriptionText, "LocKey#76949", params);
      } else {
        if Equals(updatePolicy, ConfigVarUpdatePolicy.RestartRequired) {
          params = new inkTextParams();
          params.AddLocalizedName("description", descriptionName);
          params.AddLocalizedString("additional_text", "LocKey#76948");
          inkTextRef.SetLocalizedTextScript(this.m_descriptionText, "LocKey#76949", params);
        } else {
          inkTextRef.SetLocalizedTextScript(this.m_descriptionText, descriptionName);
        };
      };
      inkWidgetRef.SetVisible(this.m_descriptionText, true);
    };
  }

  protected cb func OnSettingHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_descriptionText, false);
  }

  private final func PopulateOptions(options: array<ref<ConfigVar>>) -> Void {
    let currentItem: wref<SettingsSelectorController>;
    let currentSettingsGroup: ref<ConfigGroup>;
    let currentSettingsItem: ref<ConfigVar>;
    let currentSettingsItemType: ConfigVarType;
    let currentVoItem: wref<SettingsSelectorControllerLanguagesList>;
    let isKeyBinding: Bool;
    let isVoiceOver: Bool;
    let size: Int32 = ArraySize(options);
    let i: Int32 = 0;
    while i < size {
      currentSettingsItem = options[i];
      if !IsDefined(currentSettingsItem) {
      } else {
        if !currentSettingsItem.IsVisible() {
        } else {
          currentSettingsItemType = currentSettingsItem.GetType();
          currentSettingsGroup = currentSettingsItem.GetGroup();
          isVoiceOver = Equals(currentSettingsItem.GetName(), n"VoiceOver");
          isKeyBinding = Equals(currentSettingsGroup.GetParentPath(), n"/key_bindings");
          switch currentSettingsItemType {
            case ConfigVarType.Bool:
              currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorBool").GetController() as SettingsSelectorController;
              break;
            case ConfigVarType.Int:
              currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorInt").GetController() as SettingsSelectorController;
              break;
            case ConfigVarType.Float:
              currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorFloat").GetController() as SettingsSelectorController;
              break;
            case ConfigVarType.Name:
              if isKeyBinding {
                currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorKeyBinding").GetController() as SettingsSelectorController;
              };
              break;
            case ConfigVarType.IntList:
              currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorIntList").GetController() as SettingsSelectorController;
              break;
            case ConfigVarType.FloatList:
              currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorFloatList").GetController() as SettingsSelectorController;
              break;
            case ConfigVarType.StringList:
              currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorStringList").GetController() as SettingsSelectorController;
              break;
            case ConfigVarType.NameList:
              if !isVoiceOver {
                currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorNameList").GetController() as SettingsSelectorController;
              } else {
                currentItem = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsSelectorLanguagesList").GetController() as SettingsSelectorController;
              };
              break;
            default:
              LogUIWarning("Cannot create UI settings drawer for " + NameToString(currentSettingsItem.GetDisplayName()));
          };
          if IsDefined(currentItem) {
            currentItem.Setup(currentSettingsItem, this.m_isPreGame);
            currentItem.RegisterToCallback(n"OnHoverOver", this, n"OnSettingHoverOver");
            currentItem.RegisterToCallback(n"OnHoverOut", this, n"OnSettingHoverOut");
            if isVoiceOver {
              currentVoItem = currentItem as SettingsSelectorControllerLanguagesList;
              currentVoItem.RegisterDownloadButtonHovers(this.m_descriptionText);
            };
            ArrayPush(this.m_settingsElements, currentItem);
          };
        };
      };
      i += 1;
    };
  }

  private final func PopulateCategorySettingsOptions(idx: Int32) -> Void {
    let categoryController: ref<SettingsCategoryController>;
    let i: Int32;
    let settingsCategory: SettingsCategory;
    let settingsSubCategory: SettingsCategory;
    ArrayClear(this.m_settingsElements);
    inkCompoundRef.RemoveAllChildren(this.m_settingsOptionsList);
    inkWidgetRef.SetVisible(this.m_descriptionText, false);
    if idx < 0 {
      idx = this.m_selectorCtrl.GetToggledIndex();
    };
    settingsCategory = this.m_data[idx];
    this.PopulateOptions(settingsCategory.options);
    i = 0;
    while i < ArraySize(settingsCategory.subcategories) {
      settingsSubCategory = settingsCategory.subcategories[i];
      categoryController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_settingsOptionsList), n"settingsCategory").GetController() as SettingsCategoryController;
      if IsDefined(categoryController) {
        categoryController.Setup(settingsSubCategory.label);
      };
      this.PopulateOptions(settingsSubCategory.options);
      i += 1;
    };
    this.m_selectorCtrl.SetSelectedIndex(idx);
  }
}
