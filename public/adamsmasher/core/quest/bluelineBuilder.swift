
public final native class BluelineObject extends IScriptable {

  private final func ProcessScriptCondition(description: ref<BluelineDescription>, scriptCondition: ref<IScriptable>, playerObject: ref<GameObject>) -> Void {
    let bluelineCondition: ref<BluelineConditionTypeBase> = scriptCondition as BluelineConditionTypeBase;
    if IsDefined(bluelineCondition) {
      ArrayPush(description.parts, bluelineCondition.GetBluelinePart(playerObject));
    };
  }

  private final func AsConjunction(description: ref<BluelineDescription>) -> Void {
    description.m_logicOperator = ELogicOperator.AND;
  }

  private final func AsDisjunction(description: ref<BluelineDescription>) -> Void {
    description.m_logicOperator = ELogicOperator.OR;
  }
}
