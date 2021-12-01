
public class BeginFive extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Bool {
    Log("Test plug data BeginFive " + stateMachineInput.counter);
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Void;

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Bool {
    return true;
  }
}

public class MiddleFive extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Bool {
    Log("Test plug data MiddleFive " + stateMachineInput.counter);
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Void;

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Bool {
    return true;
  }
}

public class EndFive extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Bool {
    Log("Test plug data EndFive " + stateMachineInput.counter);
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Void;

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFiveInput>) -> Bool {
    return true;
  }
}
