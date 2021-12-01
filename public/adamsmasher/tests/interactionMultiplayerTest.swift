
public class muliplayerInteractionTest extends GameObject {

  public let counter: Int32;

  protected cb func OnGameAttached() -> Bool {
    this.counter = 0;
  }

  protected cb func OnInteractionChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    this.counter = this.counter + 1;
    FTLog("Interaction triggered");
    FTLog(choiceEvent.choice.caption);
    FTLog(ToString(this.counter));
  }
}
