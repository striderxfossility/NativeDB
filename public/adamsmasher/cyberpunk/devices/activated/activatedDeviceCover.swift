
public class ActivatedDeviceCover extends ActivatedDeviceTransfromAnim {

  protected let m_offMeshConnection: ref<OffMeshConnectionComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"offMeshConnection", n"OffMeshConnectionComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_offMeshConnection = EntityResolveComponentsInterface.GetComponent(ri, n"offMeshConnection") as OffMeshConnectionComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ActivatedDeviceController;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    this.RefreshAnimation();
    if this.GetDevicePS().IsON() {
      this.m_offMeshConnection.DisableOffMeshConnection();
    } else {
      this.m_offMeshConnection.EnableOffMeshConnection();
    };
  }
}
