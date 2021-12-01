
public native class MinigameControllerAdvanced extends inkGameController {

  public edit native let gameplayCanvas: inkWidgetRef;

  public final native func StartGame() -> Void;

  protected func OnGameFinishLogic(gameFinishEvent: ref<GameFinishEventAdvanced>) -> Void;

  protected cb func OnGameFinish(gameFinishEvent: ref<GameFinishEventAdvanced>) -> Bool {
    this.OnGameFinishLogic(gameFinishEvent);
  }
}
