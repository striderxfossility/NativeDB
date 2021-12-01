
public class Ground extends DefaultTransition {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let onGround: Bool = scriptInterface.IsOnGround();
    return onGround;
  }
}

public class Air extends DefaultTransition {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let onGround: Bool = scriptInterface.IsOnGround();
    return !onGround;
  }
}
