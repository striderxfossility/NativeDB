
public class DebugInteractionObject extends GameObject {

  private const let m_choices: array<SDebugChoice>;

  private let m_interaction: ref<InteractionComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    this.InitializeChoices();
  }

  protected cb func OnInteractionChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    this.ResolveFact(choiceEvent.choice.caption);
  }

  private final func InitializeChoices() -> Void {
    let choicesArr: array<InteractionChoice>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_choices) {
      if Equals(this.m_choices[i].choiceName, n"") {
      } else {
        ArrayPush(choicesArr, this.CreateChoice(NameToString(this.m_choices[i].choiceName), this.m_choices[i].factValue));
      };
      i += 1;
    };
    this.m_interaction.SetChoices(choicesArr);
  }

  private final func CreateChoice(choiceName: String, data: Int32) -> InteractionChoice {
    let choice: InteractionChoice;
    choice.choiceMetaData.tweakDBName = choiceName;
    choice.caption = choice.choiceMetaData.tweakDBName;
    ArrayPush(choice.data, ToVariant(data));
    return choice;
  }

  private final func ResolveFact(factName: String) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_choices) {
      if Equals(factName, "") {
      } else {
        if Equals(factName, NameToString(this.m_choices[i].choiceName)) {
          if Equals(this.m_choices[i].factmode, EVarDBMode.Add) {
            AddFact(this.GetGame(), this.m_choices[i].choiceName, this.m_choices[i].factValue);
          } else {
            if Equals(this.m_choices[i].factmode, EVarDBMode.Set) {
              SetFactValue(this.GetGame(), this.m_choices[i].choiceName, this.m_choices[i].factValue);
            };
          };
        };
      };
      i += 1;
    };
  }
}
