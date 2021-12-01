
public class InteractiveSign extends Device {

  private edit let m_signShape: SignShape;

  private let m_type: SignType;

  private let m_message: String;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as InteractiveSignController;
    super.OnTakeControl(ri);
  }
}
