
public class hudJohnnyController extends inkHUDGameController {

  private edit let m_tourHeader: inkTextRef;

  private edit let m_leftDates: inkTextRef;

  private edit let m_rightDates: inkTextRef;

  private edit let m_cancelled: inkWidgetRef;

  private let m_gameInstance: GameInstance;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_gameInstance = this.GetPlayerControlledObject().GetGame();
    this.GetRootWidget().SetVisible(false);
    if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q108_active") == 1 {
      inkTextRef.SetText(this.m_tourHeader, "LocKey#54096");
      inkTextRef.SetText(this.m_leftDates, "LocKey#54092");
      inkTextRef.SetText(this.m_rightDates, "LocKey#54094");
      inkWidgetRef.SetVisible(this.m_cancelled, false);
      this.GetRootWidget().SetVisible(true);
    } else {
      if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q101_active") == 1 {
        inkTextRef.SetText(this.m_tourHeader, "LocKey#54097");
        inkTextRef.SetText(this.m_leftDates, "LocKey#54100");
        inkTextRef.SetText(this.m_rightDates, "LocKey#54101");
        inkWidgetRef.SetVisible(this.m_cancelled, false);
        this.GetRootWidget().SetVisible(true);
      } else {
        if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q101_johnny_tour_cancelled") == 1 {
          inkTextRef.SetText(this.m_tourHeader, "LocKey#54102");
          inkTextRef.SetText(this.m_leftDates, "LocKey#54100");
          inkTextRef.SetText(this.m_rightDates, "LocKey#54101");
          inkWidgetRef.SetVisible(this.m_cancelled, true);
          this.GetRootWidget().SetVisible(true);
        };
      };
    };
  }
}
