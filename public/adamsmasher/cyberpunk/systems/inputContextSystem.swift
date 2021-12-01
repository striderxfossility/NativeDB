
public class InputContextSystem extends ScriptableSystem {

  private let activeContext: inputContextType;

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    this.activeContext = inputContextType.RPG;
  }

  public final const func GetActiveContext() -> inputContextType {
    return this.activeContext;
  }

  public final const func IsActiveContextAction() -> Bool {
    return Equals(this.activeContext, inputContextType.Action);
  }

  public final const func IsActiveContextRPG() -> Bool {
    return Equals(this.activeContext, inputContextType.RPG);
  }

  private final func OnChangeActiveContextRequest(request: ref<ChangeActiveContextRequest>) -> Void {
    this.activeContext = request.newContext;
  }
}

public static exec func SetActionContext(gameInstance: GameInstance) -> Void {
  let ContextRequest: ref<ChangeActiveContextRequest> = new ChangeActiveContextRequest();
  ContextRequest.newContext = inputContextType.Action;
  let setProgressionBuildReq: ref<SetProgressionBuild> = new SetProgressionBuild();
  setProgressionBuildReq.Set(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), gamedataBuildType.StartingBuild);
  GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"InputContextSystem").QueueRequest(ContextRequest);
  GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PlayerDevelopmentSystem").QueueRequest(setProgressionBuildReq);
}

public static exec func SetRpgContext(gameInstance: GameInstance) -> Void {
  let ContextRequest: ref<ChangeActiveContextRequest> = new ChangeActiveContextRequest();
  ContextRequest.newContext = inputContextType.RPG;
  let setProgressionBuildReq: ref<SetProgressionBuild> = new SetProgressionBuild();
  setProgressionBuildReq.Set(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), gamedataBuildType.StartingBuild);
  GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"InputContextSystem").QueueRequest(ContextRequest);
  GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PlayerDevelopmentSystem").QueueRequest(setProgressionBuildReq);
}
