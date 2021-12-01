
public native class ScriptableSystem extends IScriptableSystem {

  public final native const func QueueRequest(request: ref<ScriptableSystemRequest>) -> Void;

  protected final native const func GetGameInstance() -> GameInstance;

  public final native func WasRestored() -> Bool;

  private func OnAttach() -> Void;

  private func OnDetach() -> Void;

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void;

  private func IsSavingLocked() -> Bool {
    return false;
  }
}
