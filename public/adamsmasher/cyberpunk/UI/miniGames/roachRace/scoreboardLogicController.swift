
public class ScoreboardLogicController extends inkLogicController {

  private edit let m_gridItem: CName;

  private edit let m_namesWidget: inkCompoundRef;

  private edit let m_scoresWidget: inkCompoundRef;

  private const let m_highScores: array<ScoreboardPlayer>;

  public final func CleanGrid() -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_namesWidget);
    inkCompoundRef.RemoveAllChildren(this.m_scoresWidget);
  }

  public final func FillGrid(playerScore: Int32) -> Void {
    let j: Int32;
    let nameController: ref<ScoreboardEntityLogicController>;
    let scoreController: ref<ScoreboardEntityLogicController>;
    let scoreboardPlayers: array<ScoreboardPlayer>;
    let tempPlayer: ScoreboardPlayer;
    let i: Int32 = 0;
    while i < ArraySize(this.m_highScores) {
      ArrayPush(scoreboardPlayers, this.m_highScores[i]);
      i += 1;
    };
    ArrayPush(scoreboardPlayers, new ScoreboardPlayer("V.", playerScore));
    i = 0;
    while i < ArraySize(scoreboardPlayers) - 1 {
      j = i + 1;
      while j < ArraySize(scoreboardPlayers) {
        if scoreboardPlayers[i].m_playerScore < scoreboardPlayers[j].m_playerScore {
          tempPlayer = scoreboardPlayers[i];
          scoreboardPlayers[i] = scoreboardPlayers[j];
          scoreboardPlayers[j] = tempPlayer;
        };
        j += 1;
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(scoreboardPlayers) {
      nameController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_namesWidget), this.m_gridItem).GetController() as ScoreboardEntityLogicController;
      scoreController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_scoresWidget), this.m_gridItem).GetController() as ScoreboardEntityLogicController;
      nameController.SetText(scoreboardPlayers[i].m_playerName);
      scoreController.SetText(IntToString(scoreboardPlayers[i].m_playerScore));
      i += 1;
    };
  }
}
