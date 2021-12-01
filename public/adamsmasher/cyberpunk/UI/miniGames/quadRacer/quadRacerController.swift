
public class QuadRacerGameController extends MinigameController {

  private edit let m_gameMenu: inkWidgetRef;

  private edit let m_scoreboardMenu: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    this.OpenMenu();
  }

  private final func OpenScoreboard(playerScore: Int32) -> Void {
    let scoreboardLogic: ref<ScoreboardLogicController> = inkWidgetRef.GetController(this.m_scoreboardMenu) as ScoreboardLogicController;
    scoreboardLogic.CleanGrid();
    this.SetEnableComponent(this.m_scoreboardMenu, true);
    this.SetEnableComponent(this.m_gameMenu, false);
    this.SetEnableComponent(this.gameplayCanvas, false);
    this.RegisterToCallback(n"OnRelease", this, n"OnOpenMenuClick");
    scoreboardLogic.FillGrid(playerScore);
  }

  private final func OpenMenu() -> Void {
    this.SetEnableComponent(this.m_gameMenu, true);
    this.SetEnableComponent(this.m_scoreboardMenu, false);
    this.SetEnableComponent(this.gameplayCanvas, false);
    this.UnregisterFromCallback(n"OnRelease", this, n"OnOpenMenuClick");
    this.RegisterToCallback(n"OnRelease", this, n"OnStartGameClick");
  }

  public final func OnStartGameClick(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      this.GameStart();
    };
  }

  protected func OnGameFinishLogic(gameFinishEvent: ref<GameFinishEvent>) -> Void {
    let lastMaxRecord: Int32;
    let gameState: ref<MinigameState> = gameFinishEvent.gameState;
    let scoreSystem: ref<SideScrollerMiniGameScoreSystem> = GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"SideScrollerMiniGameScoreSystem") as SideScrollerMiniGameScoreSystem;
    let scoreRequest: ref<SendScoreRequest> = new SendScoreRequest();
    scoreRequest.m_score = gameState.currentScore;
    scoreRequest.m_gameName = "QuadRacer";
    scoreSystem.QueueRequest(scoreRequest);
    lastMaxRecord = scoreSystem.GetMaxScore("QuadRacer");
    this.OpenScoreboard(lastMaxRecord > gameState.currentScore ? lastMaxRecord : gameState.currentScore);
  }

  private final func SetEnableComponent(component: inkWidgetRef, isEnabled: Bool) -> Void {
    inkWidgetRef.SetVisible(component, isEnabled);
    inkWidgetRef.SetInteractive(component, isEnabled);
  }

  private final func OpenGameplay() -> Void {
    this.SetEnableComponent(this.gameplayCanvas, true);
    this.SetEnableComponent(this.m_gameMenu, false);
    this.SetEnableComponent(this.m_scoreboardMenu, false);
    this.UnregisterFromCallback(n"OnRelease", this, n"OnStartGameClick");
  }

  public final func OnOpenMenuClick(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") {
      this.OpenMenu();
    };
  }

  public final func GameStart() -> Void {
    this.OpenGameplay();
    this.StartGame();
  }
}
