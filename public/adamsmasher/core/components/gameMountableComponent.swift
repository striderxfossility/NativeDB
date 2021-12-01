
public abstract native class MountableComponent extends IComponent {

  public final static func IsInteractionAcceptable(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let result: Bool;
    let record: wref<InteractionMountBase_Record> = InteractionChoiceMetaData.GetTweakData(choiceEvent.choice.choiceMetaData) as InteractionMountBase_Record;
    if Equals(record.Tag(), n"mount") {
      result = true;
    };
    return result;
  }
}
