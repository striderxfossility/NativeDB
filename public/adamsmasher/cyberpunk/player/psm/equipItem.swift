
public class EquipItemLeftDecisions extends DefaultTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"ItemLeft") > 0.00;
  }
}

public class EquipItemRightDecisions extends DefaultTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"ItemRight") > 0.00;
  }
}
