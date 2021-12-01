
public class BeginThree extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, stateMachineOuptut: ref<PlayerStateMachineTestThreeOutput>) -> Void {
    stateMachineOuptut.counter = 1;
    Log("Test plug data BeginThree " + stateMachineOuptut.counter);
  }

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class MiddleThree extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, stateMachineOuptut: ref<PlayerStateMachineTestThreeOutput>) -> Void {
    stateMachineOuptut.counter = 2;
    Log("Test plug data MiddleThree " + stateMachineOuptut.counter);
  }

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class EndThree extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, stateMachineOuptut: ref<PlayerStateMachineTestThreeOutput>) -> Void {
    stateMachineOuptut.counter = 3;
    Log("Test plug data EndThree " + stateMachineOuptut.counter);
  }

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}
