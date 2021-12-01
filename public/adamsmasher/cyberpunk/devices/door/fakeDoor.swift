
public class FakeDoor extends GameObject {

  public let m_interaction: ref<InteractionComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) && evt.activator.IsPlayer() {
      this.CreateFakeDoorChoice();
    } else {
      this.m_interaction.ResetChoices(n"direct", true);
    };
  }

  private final func CreateFakeDoorChoice() -> Void {
    let interactionChoice: InteractionChoice;
    let setChoices: ref<InteractionSetChoicesEvent>;
    interactionChoice.choiceMetaData.tweakDBID = t"Interactions.FakeOpen";
    ChoiceTypeWrapper.SetType(interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
    interactionChoice.caption = interactionChoice.choiceMetaData.tweakDBName;
    setChoices = new InteractionSetChoicesEvent();
    setChoices.layer = n"direct";
    ArrayPush(setChoices.choices, interactionChoice);
    this.QueueEvent(setChoices);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.OpenPath;
  }
}
