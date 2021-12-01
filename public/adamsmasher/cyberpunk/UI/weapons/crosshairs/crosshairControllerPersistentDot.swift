
public class PersistentDotSettingsListener extends ConfigVarListener {

  private let m_ctrl: wref<CrosshairGameControllerPersistentDot>;

  public final func RegisterController(ctrl: ref<CrosshairGameControllerPersistentDot>) -> Void {
    this.m_ctrl = ctrl;
  }

  public func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    this.m_ctrl.OnVarModified(groupPath, varName, varType, reason);
  }
}

public class CrosshairGameControllerPersistentDot extends inkHUDGameController {

  private let m_settings: ref<UserSettings>;

  private let m_settingsListener: ref<PersistentDotSettingsListener>;

  @default(CrosshairGameControllerPersistentDot, /interface)
  private let m_groupPath: CName;

  protected cb func OnInitialize() -> Bool {
    this.m_settings = this.GetSystemRequestsHandler().GetUserSettings();
    this.m_settingsListener = new PersistentDotSettingsListener();
    this.m_settingsListener.RegisterController(this);
    this.m_settingsListener.Register(this.m_groupPath);
    this.UpdateRootVisibility();
  }

  private final func UpdateRootVisibility() -> Void {
    let configVar: ref<ConfigVarBool> = this.m_settings.GetVar(this.m_groupPath, n"PersistentCenterDot") as ConfigVarBool;
    let newVisibility: Bool = configVar.GetValue();
    if NotEquals(this.GetRootWidget().IsVisible(), newVisibility) {
      this.GetRootWidget().SetVisible(newVisibility);
    };
  }

  public final func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    if Equals(varName, n"PersistentCenterDot") {
      this.UpdateRootVisibility();
    };
  }
}
