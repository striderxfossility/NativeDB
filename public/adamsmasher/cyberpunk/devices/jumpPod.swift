
public class JumpPod extends GameObject {

  private let m_activationLight: ref<IVisualComponent>;

  private let m_activationTrigger: ref<IComponent>;

  public edit let impulseForward: Float;

  public edit let impulseRight: Float;

  public edit let impulseUp: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"activationLight", n"entLightComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"activator", n"gameStaticTriggerAreaComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_activationLight = EntityResolveComponentsInterface.GetComponent(ri, n"activationLight") as IVisualComponent;
    this.m_activationTrigger = EntityResolveComponentsInterface.GetComponent(ri, n"activator");
    this.m_activationLight.Toggle(false);
  }

  protected cb func OnAreaEnter(trigger: ref<AreaEnteredEvent>) -> Bool {
    this.ApplyImpulse(trigger.activator);
  }

  protected cb func OnAreaExit(trigger: ref<AreaExitedEvent>) -> Bool;

  private final func ApplyImpulse(activator: EntityGameInterface) -> Void {
    let ev: ref<PSMImpulse> = new PSMImpulse();
    ev.id = n"impulse";
    let impulseInLocalSpace: Vector4 = this.GetWorldForward() * this.impulseForward;
    impulseInLocalSpace += this.GetWorldRight() * this.impulseRight;
    impulseInLocalSpace += this.GetWorldUp() * this.impulseUp;
    ev.impulse = impulseInLocalSpace;
    EntityGameInterface.GetEntity(activator).QueueEvent(ev);
  }
}
