
public class Mainframe extends BaseAnimatedDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as MainframeController;
  }

  protected cb func OnSetQuestFact(evt: ref<FactQuickHack>) -> Bool {
    let properties: ComputerQuickHackData = evt.GetFactProperties();
    if Equals(properties.operationType, EMathOperationType.Set) {
      SetFactValue(this.GetGame(), properties.factName, properties.factValue);
    } else {
      AddFact(this.GetGame(), properties.factName, properties.factValue);
    };
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }
}
