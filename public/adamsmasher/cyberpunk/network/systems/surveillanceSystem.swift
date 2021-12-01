
public class SurveillanceSystem extends DeviceSystemBase {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SurveillanceSystemController;
    super.OnTakeControl(ri);
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }
}
