
public class HealthConsumable extends gameCpoPickableItem {

  private let m_interactionComponent: ref<InteractionComponent>;

  private let m_meshComponent: ref<MeshComponent>;

  @default(HealthConsumable, true)
  private let m_disappearAfterEquip: Bool;

  @default(HealthConsumable, -1.f)
  private let m_respawnTime: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"interactions", n"gameinteractionsComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh", n"entMeshComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_interactionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"interactions") as InteractionComponent;
    this.m_meshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"mesh") as MeshComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    let choice: InteractionChoice;
    super.OnGameAttached();
    choice.choiceMetaData.tweakDBName = "PickUp";
    this.m_interactionComponent.SetSingleChoice(choice);
  }

  protected cb func OnInteractionChoiceEvent(evt: ref<InteractionChoiceEvent>) -> Bool {
    let muppetPtr: wref<Muppet>;
    if Equals(evt.actionType, gameinputActionType.BUTTON_PRESSED) {
      muppetPtr = evt.activator as Muppet;
      if !(IsDefined(muppetPtr) && muppetPtr.GetItemQuantity(this.GetItemIDToEquip()) <= 0) && GameInstance.GetTransactionSystem(this.GetGame()).GetItemQuantity(evt.activator, this.GetItemIDToEquip()) >= 1 {
        return false;
      };
      this.EquipItem(evt.activator);
      if this.m_disappearAfterEquip {
        this.m_interactionComponent.Toggle(false);
        this.m_meshComponent.Toggle(false);
        if this.m_respawnTime > 0.00 {
          GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new RespawnHealthConsumable(), this.m_respawnTime);
        };
      };
    };
  }

  protected cb func OnTurnOn(evt: ref<RespawnHealthConsumable>) -> Bool {
    this.m_interactionComponent.Toggle(true);
    this.m_meshComponent.Toggle(true);
  }
}
