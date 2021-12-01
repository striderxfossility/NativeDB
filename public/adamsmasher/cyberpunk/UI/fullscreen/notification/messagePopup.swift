
public class PhoneMessagePopupGameController extends inkGameController {

  private edit let m_content: inkWidgetRef;

  private edit let m_title: inkTextRef;

  private edit let m_avatarImage: inkImageRef;

  private edit let m_menuBackgrouns: inkWidgetRef;

  private edit let m_hintTrack: inkWidgetRef;

  private edit let m_hintClose: inkWidgetRef;

  private edit let m_hintReply: inkWidgetRef;

  private edit let m_hintMessenger: inkWidgetRef;

  private let m_blackboard: wref<IBlackboard>;

  private let m_blackboardDef: ref<UI_ComDeviceDef>;

  private let m_uiSystem: ref<UISystem>;

  private let m_player: wref<GameObject>;

  private let m_journalMgr: wref<JournalManager>;

  private let m_data: ref<JournalNotificationData>;

  private let m_entry: wref<JournalPhoneMessage>;

  private let m_contactEntry: wref<JournalContact>;

  private let m_attachment: wref<JournalEntry>;

  private let m_attachmentHash: Uint32;

  private let m_activeEntry: wref<JournalEntry>;

  private let m_dialogViewController: wref<MessengerDialogViewController>;

  private let m_proxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_player = this.GetPlayerControlledObject();
    this.m_journalMgr = GameInstance.GetJournalManager(this.m_player.GetGame());
    this.m_uiSystem = GameInstance.GetUISystem(this.m_player.GetGame());
    this.m_blackboardDef = GetAllBlackboardDefs().UI_ComDevice;
    this.m_blackboard = this.GetBlackboardSystem().Get(this.m_blackboardDef);
    this.m_blackboard.SetBool(this.m_blackboardDef.isDisplayingMessage, true, true);
    this.PlayLibraryAnimation(n"Intro");
    this.SetupData();
  }

  private final func SetupData() -> Void {
    let attachmentState: gameJournalEntryState;
    let conversationEntry: wref<JournalEntry>;
    let conversations: array<wref<JournalEntry>>;
    let messageHash: Uint32;
    let messageState: gameJournalEntryState;
    this.m_data = this.GetRootWidget().GetUserData(n"JournalNotificationData") as JournalNotificationData;
    this.m_contactEntry = this.m_data.journalEntry as JournalContact;
    if this.m_contactEntry == null {
      this.m_entry = this.m_data.journalEntry as JournalPhoneMessage;
      conversationEntry = this.m_journalMgr.GetParentEntry(this.m_entry);
      this.m_contactEntry = this.m_journalMgr.GetParentEntry(conversationEntry) as JournalContact;
    };
    this.m_attachmentHash = this.m_entry.GetAttachmentPathHash();
    this.m_attachment = this.m_journalMgr.GetEntry(this.m_attachmentHash);
    inkWidgetRef.SetVisible(this.m_hintTrack, this.m_attachment != null);
    inkWidgetRef.SetVisible(this.m_menuBackgrouns, this.m_data.menuMode);
    messageState = this.m_journalMgr.GetEntryState(this.m_entry);
    if NotEquals(messageState, gameJournalEntryState.Active) {
      messageHash = Cast(this.m_journalMgr.GetEntryHash(this.m_entry));
      this.m_journalMgr.ChangeEntryStateByHash(messageHash, gameJournalEntryState.Active, JournalNotifyOption.Notify);
    };
    attachmentState = this.m_journalMgr.GetEntryState(this.m_attachment);
    if NotEquals(attachmentState, gameJournalEntryState.Active) {
      this.m_journalMgr.ChangeEntryStateByHash(this.m_attachmentHash, gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
    };
    this.m_dialogViewController = inkWidgetRef.GetController(this.m_content) as MessengerDialogViewController;
    this.m_dialogViewController.AttachJournalManager(this.m_journalMgr);
    if TDBID.IsValid(this.m_contactEntry.GetAvatarID(this.m_journalMgr)) {
      InkImageUtils.RequestSetImage(this, this.m_avatarImage, this.m_contactEntry.GetAvatarID(this.m_journalMgr));
    };
    this.m_journalMgr.GetConversations(this.m_contactEntry, conversations);
    if IsDefined(conversationEntry) {
      this.m_activeEntry = conversationEntry;
      this.m_dialogViewController.ShowThread(this.m_activeEntry);
    } else {
      this.m_activeEntry = this.m_contactEntry;
      this.m_dialogViewController.ShowDialog(this.m_activeEntry);
    };
    inkWidgetRef.SetVisible(this.m_hintReply, this.m_dialogViewController.HasReplyOptions());
    inkTextRef.SetText(this.m_title, this.m_contactEntry.GetLocalizedName(this.m_journalMgr));
    if this.m_data.menuMode {
      this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleMenuInput");
      inkWidgetRef.SetVisible(this.m_hintMessenger, false);
    } else {
      PopupStateUtils.SetBackgroundBlurBlendTime(this, 0.10);
      this.m_uiSystem.PushGameContext(UIGameContext.ModalPopup);
      this.m_uiSystem.RequestNewVisualState(n"inkModalPopupState");
      this.SetTimeDilatation(true);
      inkWidgetRef.SetVisible(this.m_hintMessenger, true);
      this.m_player.RegisterInputListener(this, n"cancel");
      this.m_player.RegisterInputListener(this, n"popup_goto_messenger");
      this.m_player.RegisterInputListener(this, n"track_quest");
      this.m_player.RegisterInputListener(this, n"one_click_confirm");
      this.m_player.RegisterInputListener(this, n"popup_moveUp");
      this.m_player.RegisterInputListener(this, n"popup_moveDown");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_blackboard.SetBool(this.m_blackboardDef.isDisplayingMessage, false, true);
    this.m_journalMgr.SetEntryVisited(this.m_entry, true);
    if this.m_data.menuMode {
      this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleMenuInput");
    } else {
      this.m_uiSystem.PopGameContext(UIGameContext.ModalPopup);
      this.m_uiSystem.RestorePreviousVisualState(n"inkModalPopupState");
      this.SetTimeDilatation(false);
    };
  }

  protected cb func OnDelayedJournalUpdate(evt: ref<DelayedJournalUpdate>) -> Bool {
    inkWidgetRef.SetVisible(this.m_hintReply, this.m_dialogViewController.HasReplyOptions());
  }

  protected cb func OnPopupHidden(evt: ref<inkAnimProxy>) -> Bool {
    this.m_data.token.TriggerCallback(this.m_data);
  }

  protected cb func OnHandleMenuInput(evt: ref<inkPointerEvent>) -> Bool {
    let inputHandled: Bool;
    if evt.IsAction(n"cancel") {
      inputHandled = this.HandleCommonInputActions(n"cancel");
    } else {
      if evt.IsAction(n"track_quest") {
        inputHandled = this.HandleCommonInputActions(n"track_quest");
      } else {
        if evt.IsAction(n"up_button") {
          this.NavigateChoices(true);
        } else {
          if evt.IsAction(n"down_button") {
            this.NavigateChoices(false);
          } else {
            if evt.IsAction(n"one_click_confirm") {
              this.ActivateChoice();
            };
          };
        };
      };
    };
    if !inputHandled {
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let actionName: CName;
    let isPressed: Bool = Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED);
    let isAxis: Bool = Equals(ListenerAction.GetType(action), gameinputActionType.AXIS_CHANGE);
    if isPressed || isAxis {
      actionName = ListenerAction.GetName(action);
      if !this.HandleCommonInputActions(actionName) {
        switch actionName {
          case n"one_click_confirm":
            this.ActivateChoice();
            break;
          case n"popup_moveUp":
            this.NavigateChoices(true);
            break;
          case n"popup_moveDown":
            this.NavigateChoices(false);
        };
      };
    };
  }

  private final func HandleCommonInputActions(actionName: CName) -> Bool {
    switch actionName {
      case n"cancel":
        this.ClosePopup();
        return true;
      case n"popup_goto_messenger":
        this.GotoMessengerMenu();
        this.m_data.token.TriggerCallback(this.m_data);
        return true;
      case n"track_quest":
        if IsDefined(this.m_attachment) {
          this.TrackQuest();
          this.m_data.token.TriggerCallback(this.m_data);
        };
        return true;
    };
    return false;
  }

  private final func ClosePopup() -> Void {
    if this.m_proxy == null || !this.m_proxy.IsPlaying() {
      this.m_proxy = this.PlayLibraryAnimation(n"Outro");
      this.m_proxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnPopupHidden");
    };
  }

  private final func TrackQuest() -> Void {
    let objective: wref<JournalQuestObjective> = this.m_attachment as JournalQuestObjective;
    if IsDefined(objective) {
      this.m_journalMgr.TrackEntry(objective);
    } else {
      objective = this.GetFirstObjectiveFromQuest(this.m_attachment as JournalQuest);
      this.m_journalMgr.TrackEntry(objective);
    };
  }

  private final func GetFirstObjectiveFromQuest(journalQuest: wref<JournalQuest>) -> wref<JournalQuestObjective> {
    let i: Int32;
    let unpackedData: array<wref<JournalEntry>>;
    QuestLogUtils.UnpackRecursive(this.m_journalMgr, journalQuest, unpackedData);
    i = 0;
    while i < ArraySize(unpackedData) {
      if IsDefined(unpackedData[i] as JournalQuestObjective) {
        return unpackedData[i] as JournalQuestObjective;
      };
      i += 1;
    };
    return null;
  }

  private final func GotoJournalMenu() -> Void {
    let userData: ref<MessageMenuAttachmentData> = new MessageMenuAttachmentData();
    userData.m_entryHash = this.m_journalMgr.GetEntryHash(this.m_attachment);
    this.GotoHubMenu(n"quest_log", userData);
  }

  private final func GotoMessengerMenu() -> Void {
    let userData: ref<MessageMenuAttachmentData> = new MessageMenuAttachmentData();
    userData.m_entryHash = this.m_journalMgr.GetEntryHash(this.m_activeEntry);
    this.GotoHubMenu(n"phone", userData);
  }

  private final func GotoHubMenu(menuName: CName, opt userData: ref<IScriptable>) -> Void {
    let evt: ref<StartHubMenuEvent> = new StartHubMenuEvent();
    evt.SetStartMenu(menuName, userData);
    this.QueueBroadcastEvent(evt);
  }

  private final func NavigateChoices(isUp: Bool) -> Void {
    this.m_dialogViewController.NavigateReplyOptions(isUp);
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_menu_hover");
  }

  private final func ActivateChoice() -> Void {
    this.m_dialogViewController.ActivateSelectedReplyOption();
  }

  protected final func SetTimeDilatation(enable: Bool) -> Void {
    let timeDilationReason: CName = n"MessengerPopup";
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(this.m_player.GetGame());
    if enable {
      timeSystem.SetTimeDilation(timeDilationReason, 0.01, n"Linear", n"Linear");
      timeSystem.SetTimeDilationOnLocalPlayerZero(timeDilationReason, 0.01, n"Linear", n"Linear");
      PopupStateUtils.SetBackgroundBlur(this, true);
    } else {
      timeSystem.UnsetTimeDilation(timeDilationReason);
      timeSystem.UnsetTimeDilationOnLocalPlayerZero();
      PopupStateUtils.SetBackgroundBlur(this, false);
    };
  }
}
