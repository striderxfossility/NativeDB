
public class MenuScenario_FinalBoards extends MenuScenario_BaseMenu {

  protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
    let data: ref<CreditsData> = new CreditsData();
    data.isFinalBoards = true;
    data.showRewardPrompt = userData as CreditsData.showRewardPrompt;
    this.SwitchMenu(n"finalboards_credits", data);
  }

  protected cb func OnLeaveScenario(nextScenario: CName) -> Bool;

  protected cb func OnBack() -> Bool {
    let evt: ref<gameuiFinalBoardsGoToMainMenu> = new gameuiFinalBoardsGoToMainMenu();
    this.QueueEvent(evt);
  }
}
