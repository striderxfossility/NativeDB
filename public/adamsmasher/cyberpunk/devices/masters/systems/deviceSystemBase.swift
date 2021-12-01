
public abstract class DeviceSystemBase extends InteractiveMasterDevice {

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as DeviceSystemBaseController;
  }

  protected func AdjustInteractionComponent() -> Void {
    this.m_interaction.Toggle(false);
  }
}
