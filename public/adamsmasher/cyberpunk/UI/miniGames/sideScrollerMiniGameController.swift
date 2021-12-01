
public native class MinigameController extends inkGameController {

  public edit native let gameplayCanvas: inkWidgetRef;

  protected native let gameName: CName;

  public final native func StartGame() -> Void;

  protected func OnGameFinishLogic(gameFinishEvent: ref<GameFinishEvent>) -> Void;

  protected cb func OnGameFinish(gameFinishEvent: ref<GameFinishEvent>) -> Bool {
    if Equals(gameFinishEvent.gameName, this.gameName) {
      this.OnGameFinishLogic(gameFinishEvent);
    };
  }
}
