
public native class QuadRacerLogicController extends MinigameLogicController {

  private edit let m_timeLeftText: inkTextRef;

  private edit let m_scoreText: inkTextRef;

  private edit let m_speedText: inkTextRef;

  private edit let m_notificationText: inkTextRef;

  private edit let m_notificationAnimationName: CName;

  private edit let m_speedCoeficient: Float;

  private let m_currentNotificationAnimation: ref<inkAnimProxy>;

  private let m_lastTime: Int32;

  protected func OnInitializeGameLogic() -> Void {
    if inkWidgetRef.IsValid(this.m_notificationText) {
      inkWidgetRef.SetVisible(this.m_notificationText, false);
    };
  }

  protected func OnGameStateUpdateLogic(gameStateUpdateEvent: ref<MiniGameStateUpdateEvent>) -> Void {
    let gameState: ref<QuadRacerGameState> = gameStateUpdateEvent.gameState as QuadRacerGameState;
    let secondsLeft: Int32 = Cast(gameState.timeLeft);
    if inkWidgetRef.IsValid(this.m_timeLeftText) {
      inkTextRef.SetText(this.m_timeLeftText, IntToString(secondsLeft));
    };
    if inkWidgetRef.IsValid(this.m_scoreText) {
      inkTextRef.SetText(this.m_scoreText, IntToString(gameState.currentScore));
    };
    if inkWidgetRef.IsValid(this.m_speedText) {
      inkTextRef.SetText(this.m_speedText, IntToString(Cast(gameState.speed / this.m_speedCoeficient)) + " MpH");
    };
    if secondsLeft <= 0 {
      this.PlayNotificationAnimation("Out of time!");
      this.FinishGameLogic();
    } else {
      if gameState.lapsPassed > 0 {
        this.PlayNotificationAnimation("Finish!");
        this.FinishGameLogic();
      } else {
        if inkWidgetRef.IsValid(this.m_notificationText) {
          if secondsLeft <= 5 && this.m_lastTime > secondsLeft {
            this.PlayNotificationAnimation(IntToString(secondsLeft));
          };
          if gameState.hasPassedCheckpoint {
            this.PlayNotificationAnimation("Checkpoint");
            gameState.hasPassedCheckpoint = false;
          };
        };
        this.m_lastTime = secondsLeft;
      };
    };
  }

  private final func PlayNotificationAnimation(text: String) -> Void {
    this.StopCurrentNotificationAnimation();
    this.m_currentNotificationAnimation = this.PlayLibraryAnimationOnTargets(this.m_notificationAnimationName, SelectWidgets(inkWidgetRef.Get(this.m_notificationText)));
    inkTextRef.SetText(this.m_notificationText, text);
  }

  private final func StopCurrentNotificationAnimation() -> Void {
    if this.m_currentNotificationAnimation.IsValid() {
      this.m_currentNotificationAnimation.Stop();
    };
  }
}
