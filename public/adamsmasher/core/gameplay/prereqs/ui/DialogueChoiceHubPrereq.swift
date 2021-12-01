
public class DialogueChoiceHubPrereq extends IScriptablePrereq {

  private let m_isChoiceHubActive: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_isChoiceHubActive = TweakDBInterface.GetBool(recordID + t".isChoiceHubActive", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: wref<GameObject> = context as GameObject;
    let interactonsBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(owner.GetGame()).Get(GetAllBlackboardDefs().UIInteractions);
    let interactionData: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
    let data: DialogChoiceHubs = FromVariant(interactonsBlackboard.GetVariant(interactionData.DialogChoiceHubs));
    if this.m_isChoiceHubActive {
      if ArraySize(data.choiceHubs) > 0 {
        return true;
      };
    } else {
      if ArraySize(data.choiceHubs) <= 0 {
        return true;
      };
    };
    return false;
  }
}
