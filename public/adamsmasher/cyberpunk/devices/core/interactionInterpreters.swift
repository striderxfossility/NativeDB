
public class BasicInteractionInterpreter extends IScriptable {

  public final static func Evaluate(isSecured: Bool, actions: array<ref<DeviceAction>>, out allApplicableChoices: array<InteractionChoice>, out onlyInteractableChoices: array<InteractionChoice>) -> Void {
    let choices: array<InteractionChoice>;
    let currentChoiceMetaData: ChoiceTypeWrapper;
    let i: Int32 = 0;
    while i < ArraySize(actions) {
      if IsDefined(actions[i] as TogglePersonalLink) {
        ArrayPush(choices, (actions[i] as TogglePersonalLink).GetInteractionChoice());
        ArrayErase(actions, i);
      } else {
        i += 1;
      };
    };
    i = 0;
    while i < ArraySize(actions) {
      if (actions[i] as ScriptableDeviceAction).IsQuickHack() || !(actions[i] as ScriptableDeviceAction).IsInteractionChoiceValid() {
      } else {
        ArrayPush(choices, (actions[i] as ScriptableDeviceAction).GetInteractionChoice());
      };
      i += 1;
    };
    allApplicableChoices = choices;
    i = 0;
    while i < ArraySize(allApplicableChoices) {
      currentChoiceMetaData = allApplicableChoices[i].choiceMetaData.type;
      if ChoiceTypeWrapper.IsType(currentChoiceMetaData, gameinteractionsChoiceType.Inactive) || ArraySize(allApplicableChoices[i].data) == 0 {
      } else {
        if NotEquals(allApplicableChoices[i].choiceMetaData.tweakDBName, "") || TDBID.IsValid(allApplicableChoices[i].choiceMetaData.tweakDBID) {
          ArrayPush(onlyInteractableChoices, allApplicableChoices[i]);
        };
      };
      i += 1;
    };
  }
}
