
public class VirtualItem_TEMP extends GameObject {

  public edit let m_item: String;

  public let m_interaction: ref<InteractionComponent>;

  public let m_mesh: ref<PhysicalMeshComponent>;

  public let m_mesh1: ref<PhysicalMeshComponent>;

  public let m_mesh2: ref<PhysicalMeshComponent>;

  public let m_mesh3: ref<PhysicalMeshComponent>;

  public let m_mesh4: ref<PhysicalMeshComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh", n"PhysicalMeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh1", n"PhysicalMeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh2", n"PhysicalMeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh3", n"PhysicalMeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh4", n"PhysicalMeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"visionMode", n"gameVisionModeComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;
    this.m_mesh = EntityResolveComponentsInterface.GetComponent(ri, n"mesh") as PhysicalMeshComponent;
    this.m_mesh1 = EntityResolveComponentsInterface.GetComponent(ri, n"mesh1") as PhysicalMeshComponent;
    this.m_mesh2 = EntityResolveComponentsInterface.GetComponent(ri, n"mesh2") as PhysicalMeshComponent;
    this.m_mesh3 = EntityResolveComponentsInterface.GetComponent(ri, n"mesh3") as PhysicalMeshComponent;
    this.m_mesh4 = EntityResolveComponentsInterface.GetComponent(ri, n"mesh4") as PhysicalMeshComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    let choice: InteractionChoice;
    choice.choiceMetaData.tweakDBName = "Loot";
    this.m_interaction.SetSingleChoice(choice);
  }

  protected cb func OnInteractionChoice(choice: ref<InteractionChoiceEvent>) -> Bool {
    this.HideVirtualItem();
    this.TransferItem(choice.activator);
  }

  private final func TransferItem(activator: ref<GameObject>) -> Void {
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    transSystem.GiveItem(activator, ItemID.FromTDBID(TDBID.Create(this.m_item)), 1);
  }

  private final func HideVirtualItem() -> Void {
    let state: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    state.enable = false;
    this.QueueEvent(state);
    this.m_mesh.CreatePhysicalBodyInterface().SetIsQueryable(false);
    this.m_mesh.Toggle(false);
    this.m_mesh1.CreatePhysicalBodyInterface().SetIsQueryable(false);
    this.m_mesh1.Toggle(false);
    this.m_mesh2.CreatePhysicalBodyInterface().SetIsQueryable(false);
    this.m_mesh2.Toggle(false);
    this.m_mesh3.CreatePhysicalBodyInterface().SetIsQueryable(false);
    this.m_mesh3.Toggle(false);
    this.m_mesh4.CreatePhysicalBodyInterface().SetIsQueryable(false);
    this.m_mesh4.Toggle(false);
  }
}
