
public class BonusCollisionLogic extends MinigameCollisionLogic {

  protected let hasTriggered: Bool;

  protected cb func OnInitialize() -> Bool {
    this.Reset();
  }

  protected cb func OnHitPlayer(hitEvent: ref<HitPlayerEvent>) -> Bool {
    let gameState: ref<RoachRaceGameState> = hitEvent.gameState as RoachRaceGameState;
    if IsDefined(hitEvent) && !this.hasTriggered {
      this.ChangeGameState(gameState);
      this.UpdateGameState(gameState);
      this.hasTriggered = true;
      this.GetRootWidget().SetVisible(false);
    };
  }

  protected func ChangeGameState(gameState: ref<RoachRaceGameState>) -> Void;

  protected cb func OnRecycle() -> Bool {
    this.Reset();
  }

  private final func Reset() -> Void {
    this.hasTriggered = false;
    this.GetRootWidget().SetVisible(true);
  }
}

public class HealthCollisionLogic extends BonusCollisionLogic {

  protected func ChangeGameState(gameState: ref<RoachRaceGameState>) -> Void {
    gameState.currentLives += 1;
  }
}

public class DoublePointsCollisionLogic extends BonusCollisionLogic {

  protected func ChangeGameState(gameState: ref<RoachRaceGameState>) -> Void {
    gameState.pointsBonusTime += 10.00;
  }
}

public class InvincibilityCollisionLogic extends BonusCollisionLogic {

  protected func ChangeGameState(gameState: ref<RoachRaceGameState>) -> Void {
    gameState.invincibleTime += 5.00;
  }
}
