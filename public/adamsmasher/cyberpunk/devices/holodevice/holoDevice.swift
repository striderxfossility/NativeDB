
public class HoloDevice extends InteractiveDevice {

  private let m_questFactName: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as HoloDeviceController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected cb func OnPlay(evt: ref<TogglePlay>) -> Bool {
    this.UpdateDeviceState();
    this.UpdateFactDB();
    this.UpdateUI();
  }

  private final func UpdateFactDB() -> Void {
    let factValue: Int32;
    if NotEquals(this.m_questFactName, n"") {
      factValue = 2;
      if (this.GetDevicePS() as HoloDeviceControllerPS).IsPlaying() {
        factValue = 1;
      };
      AddFact(this.GetGame(), this.m_questFactName);
      SetFactValue(this.GetGame(), this.m_questFactName, factValue);
    };
  }

  private final func UpdateUI() -> Void;

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }
}
