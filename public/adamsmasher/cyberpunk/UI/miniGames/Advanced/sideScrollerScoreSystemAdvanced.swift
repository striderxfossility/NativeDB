
public class SideScrollerMiniGameScoreSystemAdvanced extends ScriptableSystem {

  private let scoreData: array<Int32; 3>;

  private let gameNames: array<String; 3>;

  private func OnAttach() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.scoreData) {
      this.scoreData[i] = 0;
      i = i + 1;
    };
    this.gameNames[0] = "RoachRace";
    this.gameNames[1] = "Panzer";
    this.gameNames[2] = "QuadRacer";
  }

  private final const func GetGameId(gameName: String) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.gameNames) {
      if Equals(this.gameNames[i], gameName) {
        return i;
      };
      i = i + 1;
    };
    return -1;
  }

  private final func OnSendScore(request: ref<SendScoreRequestAdvanced>) -> Void {
    let score: Int32;
    let id: Int32 = this.GetGameId(request.m_gameName);
    if id >= 0 {
      score = Cast(request.m_gameState.GetScore());
      if this.scoreData[id] < score {
        this.scoreData[id] = score;
      };
      request.m_gameState.SetMaxScore(Cast(this.scoreData[id]));
    } else {
      request.m_gameState.SetMaxScore(0u);
    };
  }

  public final const func GetMaxScore(gameName: String) -> Int32 {
    let id: Int32 = this.GetGameId(gameName);
    if id >= 0 {
      return this.scoreData[id];
    };
    return -1;
  }
}
