
public native class RoachRaceLogicController extends MinigameLogicController {

  private edit let m_damageAnimation: CName;

  private edit let m_healAnimation: CName;

  private edit let m_healthText: inkTextRef;

  private edit let m_scoreText: inkTextRef;

  private edit let m_scoreMultiplierText: inkTextRef;

  @default(RoachRaceLogicController, 0)
  private let m_previousHealth: Int32;

  protected func OnGameStateUpdateLogic(gameStateUpdateEvent: ref<MiniGameStateUpdateEvent>) -> Void {
    let gameState: ref<RoachRaceGameState> = gameStateUpdateEvent.gameState as RoachRaceGameState;
    if inkWidgetRef.IsValid(this.m_healthText) {
      inkTextRef.SetText(this.m_healthText, IntToString(gameState.currentLives));
    };
    if inkWidgetRef.IsValid(this.m_scoreText) {
      inkTextRef.SetText(this.m_scoreText, IntToString(gameState.currentScore));
    };
    inkTextRef.SetText(this.m_scoreMultiplierText, gameState.pointsBonusTime > 0.00 ? "x2" : "x1");
    if gameState.currentLives < this.m_previousHealth {
      this.PlayLibraryAnimationOnTargets(this.m_damageAnimation, SelectWidgets(inkWidgetRef.Get(this.m_healthText)));
    } else {
      if gameState.currentLives > this.m_previousHealth {
        this.PlayLibraryAnimationOnTargets(this.m_healAnimation, SelectWidgets(inkWidgetRef.Get(this.m_healthText)));
      };
    };
    if gameState.currentLives == 0 {
      this.FinishGameLogic();
    };
    this.m_previousHealth = gameState.currentLives;
  }
}
