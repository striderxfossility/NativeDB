
public class WireRepairable extends GameObject {

  public let isBroken: Bool;

  private const let m_dependableEntities: array<NodeRef>;

  private let m_interaction: ref<InteractionComponent>;

  private let m_brokenmesh: ref<IVisualComponent>;

  private let m_fixedmesh: ref<IVisualComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"MeshCompBroken", n"entMeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"MeshCompFixed", n"entMeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"InteractionComp", n"gameinteractionsComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_brokenmesh = EntityResolveComponentsInterface.GetComponent(ri, n"MeshCompBroken") as IVisualComponent;
    this.m_fixedmesh = EntityResolveComponentsInterface.GetComponent(ri, n"MeshCompFixed") as IVisualComponent;
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"InteractionComp") as InteractionComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_fixedmesh.TemporaryHide(true);
    this.ChangeWiringBrokenOnConnectedPanels(true);
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool;

  protected cb func OnBasicInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    this.ChangeState(!this.isBroken);
    this.ChangeWiringBrokenOnConnectedPanels(false);
  }

  protected cb func OnVisionModeVisual(evt: ref<gameVisionModeVisualEvent>) -> Bool {
    if !this.isBroken {
    };
  }

  private final func ChangeState(newstate: Bool) -> Bool {
    if Equals(this.isBroken, newstate) {
      return false;
    };
    this.isBroken = newstate;
    this.m_brokenmesh.TemporaryHide(newstate);
    this.m_fixedmesh.TemporaryHide(!newstate);
    return true;
  }

  private final func ChangeWiringBrokenOnConnectedPanels(newWiringBroken: Bool) -> Void;
}
