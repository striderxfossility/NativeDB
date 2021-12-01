
public class SettingsCategoryItem extends ListItemController {

  private edit let m_labelHighlight: inkTextRef;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.RegisterToCallback(n"OnToggledOn", this, n"OnToggledOn");
    this.RegisterToCallback(n"OnToggledOff", this, n"OnToggledOff");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnToggledOn", this, n"OnToggledOn");
    this.UnregisterFromCallback(n"OnToggledOff", this, n"OnToggledOff");
  }

  protected cb func OnToggledOn(itemController: wref<ListItemController>) -> Bool {
    this.GetRootWidget().SetState(n"Selected");
  }

  protected cb func OnToggledOff(itemController: wref<ListItemController>) -> Bool {
    this.GetRootWidget().SetState(n"Default");
  }

  protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
    let data: ref<ListItemData> = value as ListItemData;
    if inkWidgetRef.IsValid(this.m_labelHighlight) {
      inkTextRef.SetText(this.m_labelHighlight, data.label);
    };
    super.OnDataChanged(value);
  }
}
