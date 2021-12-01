
public class BrightnessSettingsVarListener extends ConfigVarListener {

  private let m_ctrl: wref<BrightnessSettingsGameController>;

  public final func RegisterController(ctrl: ref<BrightnessSettingsGameController>) -> Void {
    this.m_ctrl = ctrl;
  }

  public func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    Log("BrightnessSettingsVarListener::OnVarModified");
    this.m_ctrl.OnVarModified(groupPath, varName, varType, reason);
  }
}

public class BrightnessSettingsGameController extends gameuiMenuGameController {

  private let s_brightnessGroup: CName;

  private edit let m_settingsOptionsList: inkCompoundRef;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_settings: ref<UserSettings>;

  private let m_settingsListener: ref<BrightnessSettingsVarListener>;

  private let m_SettingsElements: array<wref<SettingsSelectorController>>;

  private let m_isPreGame: Bool;

  protected cb func OnInitialize() -> Bool {
    this.s_brightnessGroup = n"/video/display";
    this.m_settings = this.GetSystemRequestsHandler().GetUserSettings();
    this.m_isPreGame = this.GetSystemRequestsHandler().IsPreGame();
    this.m_settingsListener = new BrightnessSettingsVarListener();
    this.m_settingsListener.RegisterController(this);
    this.m_settingsListener.Register(this.s_brightnessGroup);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.PopulateSettings();
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  private final func PopulateSettings() -> Void {
    let option: ref<ConfigVar>;
    let selector: wref<SettingsSelectorController>;
    ArrayClear(this.m_SettingsElements);
    inkCompoundRef.RemoveAllChildren(this.m_settingsOptionsList);
    option = this.m_settings.GetVar(this.s_brightnessGroup, n"Gamma");
    if this.m_isPreGame ? option.IsInPreGame() : option.IsInGame() {
      selector = this.SpawnFromExternal(inkWidgetRef.Get(this.m_settingsOptionsList), r"base\\gameplay\\gui\\fullscreen\\settings\\settings_main.inkwidget", n"settingsSelectorFloat").GetController() as SettingsSelectorController;
      if IsDefined(selector) {
        selector.Setup(option, this.m_isPreGame);
        ArrayPush(this.m_SettingsElements, selector);
      };
    };
  }

  public final func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    let i: Int32;
    let item: ref<SettingsSelectorController>;
    let size: Int32;
    Log("[VAR] modified groupPath: " + NameToString(groupPath) + " varName: " + NameToString(varName));
    size = ArraySize(this.m_SettingsElements);
    i = 0;
    while i < size {
      item = this.m_SettingsElements[i];
      if Equals(item.GetGroupPath(), groupPath) && Equals(item.GetVarName(), varName) {
        this.m_SettingsElements[i].Refresh();
      };
      i += 1;
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }
}
