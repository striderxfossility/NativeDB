
public class BeginFour extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>) -> Bool {
    Log("Test plug data BeginFour " + stateMachineInput.counter);
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>, stateMachineOutput: ref<PlayerStateMachineTestFourOutput>) -> Void {
    stateMachineOutput.counter = 10;
  }

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>) -> Bool {
    return true;
  }
}

public class MiddleFour extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>) -> Bool {
    Log("Test plug data MiddleFour " + stateMachineInput.counter);
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>, stateMachineOutput: ref<PlayerStateMachineTestFourOutput>) -> Void {
    stateMachineOutput.counter = 20;
  }

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>) -> Bool {
    return true;
  }
}

public class EndFour extends DefaultTransition {

  public final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>) -> Bool {
    Log("Test plug data EndFour " + stateMachineInput.counter);
    return true;
  }

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>, stateMachineOutput: ref<PlayerStateMachineTestFourOutput>) -> Void {
    stateMachineOutput.counter = 30;
  }

  public final const func ToNext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, const stateMachineInput: ref<PlayerStateMachineTestFourInput>) -> Bool {
    return true;
  }
}
