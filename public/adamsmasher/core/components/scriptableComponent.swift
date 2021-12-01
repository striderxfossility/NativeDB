
public class TestScriptableComponent extends ScriptableComponent {

  private final func OnGameAttach() -> Void {
    Log("TestScriptableComponent: GameAttach");
  }

  private final func OnGameDetach() -> Void {
    Log("TestScriptableComponent: GameDetach");
  }

  private final func OnEditorAttach() -> Void {
    Log("TestScriptableComponent: EditorAttach");
  }

  private final func OnEditorDetach() -> Void {
    Log("TestScriptableComponent: EditorDetach");
  }

  private final func OnUpdate(deltaTime: Float) -> Void {
    Log("TestScriptableComponent: Update with deltaTime = " + FloatToString(deltaTime));
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    Log("TestScriptableComponent: Got hit event");
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    Log("TestScriptableComponent: OnTakeControl");
  }
}
