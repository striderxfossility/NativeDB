
public class QuestUpdateGameController extends inkHUDGameController {

  private edit let m_header: inkTextRef;

  private edit let m_label: inkTextRef;

  private edit let m_icon: inkImageRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_data: ref<QuestUpdateUserData>;

  private let m_owner: wref<GameObject>;

  private let m_journalMgr: wref<JournalManager>;

  protected cb func OnInitialize() -> Bool {
    this.m_owner = this.GetOwnerEntity() as GameObject;
    this.m_journalMgr = GameInstance.GetJournalManager(this.m_owner.GetGame());
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.m_data = this.GetRootWidget().GetUserData(n"QuestUpdateUserData") as QuestUpdateUserData;
    this.Setup();
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  }

  private final func Setup() -> Void {
    let questEntry: ref<JournalQuest> = this.m_data.data;
    let questEntryState: gameJournalEntryState = this.m_journalMgr.GetEntryState(questEntry);
    if Equals(questEntryState, gameJournalEntryState.Active) {
      inkTextRef.SetText(this.m_header, "UI-Cyberpunk-QUEST_ADDED");
      inkTextRef.SetText(this.m_label, questEntry.GetTitle(this.m_journalMgr));
      this.PlayAnimation(n"quest_added");
    } else {
      if Equals(questEntryState, gameJournalEntryState.Succeeded) {
        inkTextRef.SetText(this.m_header, "UI-Cyberpunk-QUEST_COMPLETED");
        inkTextRef.SetText(this.m_label, questEntry.GetTitle(this.m_journalMgr));
        this.PlayAnimation(n"quest_success");
      };
    };
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"ToggleHubMenu") {
    };
  }

  private final func OpenQuestMenu() -> Void {
    let menuEvent: ref<inkMenuInstance_SpawnEvent> = new inkMenuInstance_SpawnEvent();
    menuEvent.Init(n"OnSwitchToQuestLog");
    this.QueueEvent(menuEvent);
  }

  private final func PlayAnimation(animName: CName) -> Void {
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    let fakeData: ref<inkGameNotificationData>;
    this.m_data.token.TriggerCallback(fakeData);
  }
}
