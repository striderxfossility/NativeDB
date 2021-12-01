
public class panzerGameController extends PanzerMiniGameController {

  protected func OnGameFinishLogic(gameFinishEvent: ref<GameFinishEventAdvanced>) -> Void {
    let gameState: ref<MinigameStateAdvanced> = gameFinishEvent.gameState;
    let scoreSystem: ref<SideScrollerMiniGameScoreSystemAdvanced> = GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"SideScrollerMiniGameScoreSystemAdvanced") as SideScrollerMiniGameScoreSystemAdvanced;
    let scoreRequest: ref<SendScoreRequestAdvanced> = new SendScoreRequestAdvanced();
    scoreRequest.m_gameState = gameState;
    scoreRequest.m_gameName = "Panzer";
    scoreSystem.QueueRequest(scoreRequest);
  }
}
