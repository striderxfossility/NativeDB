
public class SettingControllerScheme extends inkLogicController {

  private edit let m_tabRootRef: inkWidgetRef;

  private edit let m_inputTab: inkWidgetRef;

  private edit let m_vehiclesTab: inkWidgetRef;

  private edit let m_braindanceTab: inkWidgetRef;

  private let m_tabRoot: wref<TabRadioGroup>;

  protected cb func OnInitialize() -> Bool {
    let labels: array<String>;
    this.m_tabRoot = inkWidgetRef.GetController(this.m_tabRootRef) as TabRadioGroup;
    this.m_tabRoot.RegisterToCallback(n"OnValueChanged", this, n"OnValueChanged");
    ArrayPush(labels, "UI-Settings-GenaralInput");
    ArrayPush(labels, "Story-base-journal-codex-tutorials-Vehicles_title");
    ArrayPush(labels, "LocKey#17197");
    this.m_tabRoot.SetData(3, null, labels);
    this.m_tabRoot.Toggle(0);
  }

  protected cb func OnValueChanged(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    switch selectedIndex {
      case 0:
        inkWidgetRef.SetVisible(this.m_inputTab, true);
        inkWidgetRef.SetVisible(this.m_vehiclesTab, false);
        inkWidgetRef.SetVisible(this.m_braindanceTab, false);
        break;
      case 1:
        inkWidgetRef.SetVisible(this.m_inputTab, false);
        inkWidgetRef.SetVisible(this.m_vehiclesTab, true);
        inkWidgetRef.SetVisible(this.m_braindanceTab, false);
        break;
      case 2:
        inkWidgetRef.SetVisible(this.m_inputTab, false);
        inkWidgetRef.SetVisible(this.m_vehiclesTab, false);
        inkWidgetRef.SetVisible(this.m_braindanceTab, true);
    };
  }
}
