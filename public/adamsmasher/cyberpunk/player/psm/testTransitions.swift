
public class DefaultTest extends StateFunctor {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"Jump");
  }
}

public class BeginOne extends DefaultTest {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("BeginOne::OneEnter");
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("BeginOne::OneEnter");
  }
}

public class MiddleOne extends DefaultTest {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("MiddleOne::OneEnter");
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("MiddleOne::OneEnter");
  }
}

public class EndOne extends DefaultTest {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("EndOne::OneEnter");
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("EndOne::OneEnter");
  }
}

public class BeginTwo extends DefaultTest {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("BeginTwo::OneEnter");
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("BeginTwo::OneEnter");
  }
}

public class EndTwo extends DefaultTest {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("EndTwo::OneEnter");
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    Log("EndTwo::OneEnter");
  }
}
