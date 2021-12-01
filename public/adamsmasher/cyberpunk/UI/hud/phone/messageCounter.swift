
public class MessageCounterController extends inkGameController {

  protected edit let m_messageCounter: inkTextRef;

  private let m_rootWidget: wref<inkWidget>;

  private let m_CallInformationBBID: ref<CallbackHandle>;

  private let m_journalManager: wref<JournalManager>;

  private let m_Owner: wref<GameObject>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
    this.m_Owner = this.GetPlayerControlledObject();
    this.m_journalManager = GameInstance.GetJournalManager(this.m_Owner.GetGame());
    this.m_journalManager.RegisterScriptCallback(this, n"OnJournalUpdate", gameJournalListenerType.State);
    this.UpdateData();
  }

  protected cb func OnUnitialize() -> Bool {
    this.m_journalManager.UnregisterScriptCallback(this, n"OnJournalUpdate");
  }

  public final func UpdateData() -> Void {
    let contacts: array<wref<JournalEntry>>;
    let context: JournalRequestContext;
    let i: Int32;
    let unreadedMessages: Int32 = 0;
    context.stateFilter.active = true;
    this.m_journalManager.GetContacts(context, contacts);
    i = 0;
    while i < ArraySize(contacts) {
      if IsDefined(contacts[i]) {
        if !this.m_journalManager.IsEntryVisited(contacts[i]) {
          unreadedMessages = unreadedMessages + 1;
        };
      };
      i += 1;
    };
    inkTextRef.SetText(this.m_messageCounter, IntToString(unreadedMessages));
    this.m_rootWidget.SetVisible(unreadedMessages != 0);
  }

  protected cb func OnJournalUpdate(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    this.UpdateData();
  }
}
