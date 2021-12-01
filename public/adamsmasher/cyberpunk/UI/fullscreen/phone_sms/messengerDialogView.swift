
public class MessengerDialogViewController extends inkLogicController {

  private edit let m_messagesList: inkCompoundRef;

  private edit let m_choicesList: inkCompoundRef;

  private edit let m_replayFluff: inkCompoundRef;

  private let m_messagesListController: wref<JournalEntriesListController>;

  private let m_choicesListController: wref<JournalEntriesListController>;

  private let m_scrollController: wref<inkScrollController>;

  private let m_journalManager: wref<JournalManager>;

  private let m_replyOptions: array<wref<JournalEntry>>;

  private let m_messages: array<wref<JournalEntry>>;

  private let m_parentEntry: wref<JournalEntry>;

  private let m_singleThreadMode: Bool;

  private let m_newMessageAninmProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_messagesListController = inkWidgetRef.GetController(this.m_messagesList) as JournalEntriesListController;
    this.m_choicesListController = inkWidgetRef.GetController(this.m_choicesList) as JournalEntriesListController;
    this.m_scrollController = this.GetRootWidget().GetControllerByType(n"inkScrollController") as inkScrollController;
    this.m_choicesListController.RegisterToCallback(n"OnItemActivated", this, n"OnPlayerReplyActivated");
  }

  protected cb func OnUninitialize() -> Bool {
    this.DetachJournalManager();
  }

  public final func AttachJournalManager(journalManager: wref<JournalManager>) -> Void {
    this.m_journalManager = journalManager;
    this.m_journalManager.RegisterScriptCallback(this, n"OnJournalUpdate", gameJournalListenerType.State);
  }

  public final func DetachJournalManager() -> Void {
    if IsDefined(this.m_journalManager) {
      this.m_journalManager.UnregisterScriptCallback(this, n"OnJournalUpdate");
      this.m_journalManager = null;
    };
  }

  public final func ShowDialog(contact: wref<JournalEntry>) -> Void {
    this.m_singleThreadMode = false;
    this.m_parentEntry = contact;
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
    this.UpdateData();
  }

  public final func ShowThread(thread: wref<JournalEntry>) -> Void {
    this.m_singleThreadMode = true;
    this.m_parentEntry = thread;
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
    this.UpdateData();
  }

  public final func UpdateData(opt animateLastMessage: Bool) -> Void {
    let countMessages: Int32;
    let lastMessageWidget: wref<inkWidget>;
    if this.m_singleThreadMode {
      this.m_journalManager.GetMessagesAndChoices(this.m_parentEntry, this.m_messages, this.m_replyOptions);
    } else {
      this.m_journalManager.GetFlattenedMessagesAndChoices(this.m_parentEntry, this.m_messages, this.m_replyOptions);
    };
    inkWidgetRef.SetVisible(this.m_replayFluff, ArraySize(this.m_replyOptions) > 0);
    this.SetVisited(this.m_messages);
    this.m_messagesListController.Clear();
    this.m_messagesListController.PushEntries(this.m_messages);
    this.m_choicesListController.Clear();
    this.m_choicesListController.PushEntries(this.m_replyOptions);
    if ArraySize(this.m_replyOptions) > 0 {
      this.m_choicesListController.SetSelectedIndex(0);
    };
    if IsDefined(this.m_newMessageAninmProxy) {
      this.m_newMessageAninmProxy.Stop();
      this.m_newMessageAninmProxy = null;
    };
    countMessages = this.m_messagesListController.Size();
    if animateLastMessage && countMessages > 0 {
      lastMessageWidget = this.m_messagesListController.GetItemAt(countMessages - 1);
      if IsDefined(lastMessageWidget) {
        this.m_newMessageAninmProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"new_message", lastMessageWidget);
      };
    };
    this.m_scrollController.SetScrollPosition(1.00);
  }

  protected cb func OnJournalUpdate(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let updateEvent: ref<DelayedJournalUpdate>;
    if Equals(className, n"gameJournalPhoneMessage") || Equals(className, n"gameJournalPhoneChoiceGroup") || Equals(className, n"gameJournalPhoneChoiceEntry") {
      updateEvent = new DelayedJournalUpdate();
      updateEvent.m_newMessageSpawned = Equals(className, n"gameJournalPhoneMessage") || Equals(className, n"gameJournalPhoneChoiceEntry");
      this.QueueEvent(updateEvent);
    };
  }

  protected cb func OnDelayedJournalUpdate(evt: ref<DelayedJournalUpdate>) -> Bool {
    this.UpdateData(evt.m_newMessageSpawned);
  }

  protected cb func OnPlayerReplyActivated(index: Int32, target: ref<ListItemController>) -> Bool {
    this.ActivateReply(target);
  }

  public final func ActivateSelectedReplyOption() -> Void {
    let itemWidget: wref<inkWidget>;
    let target: wref<ListItemController>;
    if this.m_choicesListController.Size() > 0 {
      itemWidget = this.m_choicesListController.GetItemAt(this.m_choicesListController.GetSelectedIndex());
      target = itemWidget.GetController() as ListItemController;
      this.ActivateReply(target);
    };
  }

  public final func NavigateReplyOptions(isUp: Bool) -> Void {
    if this.m_choicesListController.Size() > 0 {
      if isUp {
        this.m_choicesListController.Prior();
      } else {
        this.m_choicesListController.Next();
      };
    };
  }

  public final func HasReplyOptions() -> Bool {
    return ArraySize(this.m_replyOptions) > 0;
  }

  private final func ActivateReply(target: ref<ListItemController>) -> Void {
    let i: Int32;
    let data: ref<JournalEntryListItemData> = target.GetData() as JournalEntryListItemData;
    let count: Int32 = ArraySize(this.m_replyOptions);
    inkWidgetRef.SetVisible(this.m_replayFluff, count > 0);
    i = 0;
    while i < count {
      if NotEquals(this.m_replyOptions[i].GetId(), data.m_entry.GetId()) {
        this.m_journalManager.SetEntryVisited(this.m_replyOptions[i], true);
        this.m_journalManager.ChangeEntryStateByHash(Cast(this.m_journalManager.GetEntryHash(this.m_replyOptions[i])), gameJournalEntryState.Inactive, JournalNotifyOption.Notify);
      };
      i += 1;
    };
    this.m_journalManager.SetEntryVisited(data.m_entry, true);
    this.m_journalManager.ChangeEntryStateByHash(Cast(this.m_journalManager.GetEntryHash(data.m_entry)), gameJournalEntryState.Succeeded, JournalNotifyOption.Notify);
  }

  private final func SetVisited(records: array<wref<JournalEntry>>) -> Void {
    let entry: wref<JournalEntry>;
    let needEvent: Bool;
    let threadReadEvent: ref<MessageThreadReadEvent>;
    let count: Int32 = ArraySize(records);
    let i: Int32 = 0;
    while i < count {
      entry = records[i];
      if !this.m_journalManager.IsEntryVisited(entry) {
        this.m_journalManager.SetEntryVisited(entry, true);
        needEvent = true;
      };
      i += 1;
    };
    if needEvent {
      threadReadEvent = new MessageThreadReadEvent();
      threadReadEvent.m_parentHash = this.m_journalManager.GetEntryHash(this.m_parentEntry);
      this.QueueEvent(threadReadEvent);
    };
  }
}
