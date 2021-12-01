
public class QuadRacerObstacleCollisionLogic extends MinigameCollisionLogic {

  protected cb func OnHitPlayer(hitEvent: ref<HitPlayerEvent>) -> Bool {
    let gameState: ref<QuadRacerGameState>;
    if IsDefined(hitEvent) {
      gameState = hitEvent.gameState as QuadRacerGameState;
      gameState.shouldPushBackPlayer = true;
      this.UpdateGameState(gameState);
    };
  }
}

public class QuadRacerBonusCollisionLogic extends MinigameCollisionLogic {

  private let hasTriggered: Bool;

  protected cb func OnInitialize() -> Bool {
    this.hasTriggered = false;
  }

  protected cb func OnHitPlayer(hitEvent: ref<HitPlayerEvent>) -> Bool {
    let gameState: ref<QuadRacerGameState>;
    if IsDefined(hitEvent) {
      gameState = hitEvent.gameState as QuadRacerGameState;
      if !this.hasTriggered {
        this.ChangeGameState(gameState);
        this.hasTriggered = true;
        this.GetRootWidget().SetVisible(false);
      };
      this.UpdateGameState(gameState);
    };
  }

  protected cb func OnRecycle() -> Bool {
    this.hasTriggered = false;
  }

  protected func ChangeGameState(gameState: ref<QuadRacerGameState>) -> Void;
}

public class NitroCollisionLogic extends QuadRacerBonusCollisionLogic {

  protected func ChangeGameState(gameState: ref<QuadRacerGameState>) -> Void {
    gameState.boostTime += 5.00;
  }
}

public class OneTimeCollisionLogic extends QuadRacerBonusCollisionLogic {

  protected func ChangeGameState(gameState: ref<QuadRacerGameState>) -> Void {
    gameState.shouldPushBackPlayer = true;
  }
}
