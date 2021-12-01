
public class SettingsListItem extends ListItemController {

  private edit let m_Selector: inkWidgetRef;

  protected let m_settingsSelector: wref<SettingsSelectorController>;

  protected cb func OnInitialize() -> Bool {
    this.m_settingsSelector = inkWidgetRef.GetController(this.m_Selector) as SettingsSelectorController;
  }

  protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
    let entry: ref<ConfigVar>;
    if IsDefined(this.m_settingsSelector) {
      entry = value as ConfigVar;
      this.m_settingsSelector.BindSettings(entry);
    };
  }

  protected cb func OnSelected(target: wref<ListItemController>) -> Bool;
}
