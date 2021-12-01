
public native class MinigameLogicController extends inkLogicController {

  protected native let gameName: CName;

  protected let m_isGameRunning: Bool;

  public final native func FinishGame() -> Void;

  protected func OnInitializeGameLogic() -> Void;

  protected func OnGameStateUpdateLogic(gameStateUpdateEvent: ref<MiniGameStateUpdateEvent>) -> Void;

  protected func FinishGameLogic() -> Void {
    this.m_isGameRunning = false;
    this.FinishGame();
  }

  protected cb func OnInitializeGame() -> Bool {
    this.m_isGameRunning = true;
    this.OnInitializeGameLogic();
  }

  protected cb func OnGameStateUpdate(gameStateUpdateEvent: ref<MiniGameStateUpdateEvent>) -> Bool {
    if Equals(gameStateUpdateEvent.gameName, this.gameName) && this.m_isGameRunning {
      this.OnGameStateUpdateLogic(gameStateUpdateEvent);
    };
  }
}
