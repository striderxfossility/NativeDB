
public class NetworkMinigameEndScreenController extends inkLogicController {

  protected edit let m_outcomeText: inkTextRef;

  protected edit let m_finishBarContainer: wref<NetworkMinigameProgramController>;

  protected edit let m_programsListContainer: inkWidgetRef;

  protected edit let m_programLibraryName: CName;

  protected let m_slotList: array<wref<NetworkMinigameProgramController>>;

  protected let m_endData: EndScreenData;

  protected edit let m_closeButton: inkWidgetRef;

  protected edit let header_bg: inkWidgetRef;

  protected edit let m_completionColor: Color;

  protected edit let m_failureColor: Color;

  public final func SetUp(endData: EndScreenData) -> Void {
    let i: Int32;
    let slot: wref<inkWidget>;
    let slotLogic: wref<NetworkMinigameProgramController>;
    this.m_endData = endData;
    if Equals(endData.outcome, OutcomeMessage.Success) {
      inkWidgetRef.SetTintColor(this.header_bg, this.m_completionColor);
      inkTextRef.SetText(this.m_outcomeText, "UI-Cyberpunk-Fullscreen-HackingMiniGame-AccessGranted");
    } else {
      inkTextRef.SetText(this.m_outcomeText, "UI-Cyberpunk-Fullscreen-HackingMiniGame-AccessDenied");
      inkWidgetRef.SetTintColor(this.header_bg, this.m_failureColor);
    };
    i = 0;
    while i < ArraySize(endData.unlockedPrograms) {
      slot = this.SpawnFromLocal(inkWidgetRef.Get(this.m_programsListContainer), this.m_programLibraryName);
      slotLogic = slot.GetController() as NetworkMinigameProgramController;
      slotLogic.Spawn(endData.unlockedPrograms[i]);
      ArrayPush(this.m_slotList, slotLogic);
      i += 1;
    };
  }

  public final func GetCloseButtonRef() -> inkWidgetRef {
    return this.m_closeButton;
  }
}
