
public class InspectionObject extends GameObject {

  public let m_interaction: ref<InteractionComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;
  }

  protected cb func OnInteractionChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let choicesArr: array<InteractionChoice>;
    if Equals(choiceEvent.choice.choiceMetaData.tweakDBName, "Inspect") {
      this.m_interaction.ResetChoices();
      ArrayPush(choicesArr, this.CreateChoice("Inspected", 1));
      this.m_interaction.SetChoices(choicesArr);
      Log("SuccessfulInspection");
    } else {
      if Equals(choiceEvent.choice.choiceMetaData.tweakDBName, "Inspected") {
        this.m_interaction.ResetChoices();
        ArrayPush(choicesArr, this.CreateChoice("Inspect", 2));
        this.m_interaction.SetChoices(choicesArr);
      };
    };
  }

  private final func CreateChoice(choiceName: String, data: Int32) -> InteractionChoice {
    let choice: InteractionChoice;
    choice.choiceMetaData.tweakDBName = choiceName;
    choice.caption = choice.choiceMetaData.tweakDBName;
    ArrayPush(choice.data, ToVariant(data));
    return choice;
  }
}
