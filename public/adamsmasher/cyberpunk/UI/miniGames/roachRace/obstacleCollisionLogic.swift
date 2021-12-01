
public class ObstacleCollisionLogic extends MinigameCollisionLogic {

  private let hasTriggered: Bool;

  @default(ObstacleCollisionLogic, 0.8)
  private edit let invincibityBonusTime: Float;

  protected cb func OnInitialize() -> Bool {
    this.hasTriggered = false;
  }

  protected cb func OnHitPlayer(hitEvent: ref<HitPlayerEvent>) -> Bool {
    let gameState: ref<RoachRaceGameState> = hitEvent.gameState as RoachRaceGameState;
    if IsDefined(hitEvent) && !this.hasTriggered {
      gameState.currentLives -= 1;
      gameState.invincibleTime += this.invincibityBonusTime;
      this.hasTriggered = true;
      this.UpdateGameState(gameState);
    };
  }

  protected cb func OnRecycle() -> Bool {
    this.hasTriggered = false;
  }
}
