
public class RoachRaceGameController extends MinigameController {

  private edit let m_gameMenu: inkWidgetRef;

  private edit let m_scoreboardMenu: inkWidgetRef;

  private let m_isCutsceneInProgress: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_isCutsceneInProgress = false;
    this.OpenMenu();
  }

  protected func OnGameFinishLogic(gameFinishEvent: ref<GameFinishEvent>) -> Void {
    let lastMaxRecord: Int32;
    let gameState: ref<MinigameState> = gameFinishEvent.gameState;
    let scoreSystem: ref<SideScrollerMiniGameScoreSystem> = GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"SideScrollerMiniGameScoreSystem") as SideScrollerMiniGameScoreSystem;
    let scoreRequest: ref<SendScoreRequest> = new SendScoreRequest();
    scoreRequest.m_score = gameState.currentScore;
    scoreRequest.m_gameName = "RoachRace";
    scoreSystem.QueueRequest(scoreRequest);
    lastMaxRecord = scoreSystem.GetMaxScore("RoachRace");
    this.OpenScoreboard(lastMaxRecord > gameState.currentScore ? lastMaxRecord : gameState.currentScore);
  }

  private final func OpenMenu() -> Void {
    this.m_isCutsceneInProgress = true;
    let animation: ref<inkAnimProxy> = this.PlayLibraryAnimation(n"MenuIntro");
    animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"FinishCutscene");
    this.SetEnableComponent(this.m_gameMenu, true);
    this.SetEnableComponent(this.gameplayCanvas, false);
    this.SetEnableComponent(this.m_scoreboardMenu, false);
    this.UnregisterFromCallback(n"OnRelease", this, n"OnOpenMenuClick");
    this.RegisterToCallback(n"OnRelease", this, n"OnStartGameClick");
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

  private final func OpenGameplay() -> Void {
    this.SetEnableComponent(this.gameplayCanvas, true);
    this.SetEnableComponent(this.m_gameMenu, false);
    this.SetEnableComponent(this.m_scoreboardMenu, false);
    this.UnregisterFromCallback(n"OnRelease", this, n"OnStartGameClick");
  }

  private final func SetEnableComponent(component: inkWidgetRef, isEnabled: Bool) -> Void {
    inkWidgetRef.SetVisible(component, isEnabled);
    inkWidgetRef.SetInteractive(component, isEnabled);
  }

  public final func OnOpenMenuClick(e: ref<inkPointerEvent>) -> Void {
    if e.IsAction(n"click") && !this.m_isCutsceneInProgress {
      this.OpenMenu();
    };
  }

  public final func OnStartGameClick(e: ref<inkPointerEvent>) -> Void {
    let outroAnimation: ref<inkAnimProxy>;
    if e.IsAction(n"click") && !this.m_isCutsceneInProgress {
      this.m_isCutsceneInProgress = true;
      outroAnimation = this.PlayLibraryAnimation(n"MenuOutro");
      outroAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"FinishCutscene");
      outroAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"GameStart");
    };
  }

  public final func FinishCutscene(e: ref<inkAnimProxy>) -> Void {
    this.m_isCutsceneInProgress = false;
  }

  public final func GameStart(e: ref<inkAnimProxy>) -> Void {
    this.OpenGameplay();
    this.StartGame();
  }
}
