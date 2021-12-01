
public class MessengerContactsVirtualNestedListController extends VirtualNestedListController {

  private let m_currentDataView: wref<MessengerContactDataView>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.m_defaultCollapsed = false;
  }

  protected func GetDataView() -> ref<VirtualNestedListDataView> {
    let view: ref<MessengerContactDataView> = new MessengerContactDataView();
    this.m_currentDataView = view;
    return view;
  }

  public final func GetIndexByJournalHash(hash: Int32) -> Int32 {
    let currentContactData: wref<ContactData>;
    let dataSize: Int32;
    let i: Int32;
    let listData: wref<VirutalNestedListData>;
    if this.m_currentDataView == null {
      return -1;
    };
    dataSize = Cast(this.m_currentDataView.Size());
    i = 0;
    while i < dataSize {
      listData = this.m_currentDataView.GetItem(Cast(i)) as VirutalNestedListData;
      currentContactData = listData.m_data as ContactData;
      if currentContactData.hash == hash {
        return i;
      };
      i = i + 1;
    };
    return -1;
  }
}

public class MessengerGameController extends gameuiMenuGameController {

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_contactsRef: inkWidgetRef;

  private edit let m_dialogRef: inkWidgetRef;

  private edit let m_virtualList: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_dialogController: wref<MessengerDialogViewController>;

  private let m_listController: wref<MessengerContactsVirtualNestedListController>;

  private let m_journalManager: wref<JournalManager>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_activeData: ref<MessengerContactSyncData>;

  protected cb func OnInitialize() -> Bool {
    let hintsWidget: wref<inkWidget> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root");
    this.m_buttonHintsController = hintsWidget.GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_dialogController = inkWidgetRef.GetController(this.m_dialogRef) as MessengerDialogViewController;
    this.m_listController = inkWidgetRef.GetController(this.m_contactsRef) as MessengerContactsVirtualNestedListController;
    this.m_activeData = new MessengerContactSyncData();
    this.PlayLibraryAnimation(n"contacts_intro");
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_journalManager = GameInstance.GetJournalManager(this.GetPlayerControlledObject().GetGame());
    this.m_dialogController.AttachJournalManager(this.m_journalManager);
    this.PopulateData();
    this.m_journalManager.RegisterScriptCallback(this, n"OnJournalUpdate", gameJournalListenerType.Visited);
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_dialogController.DetachJournalManager();
    this.m_journalManager.UnregisterScriptCallback(this, n"OnJournalUpdate");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnJournalUpdate(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let cashSelectedIdx: Uint32;
    let selectedEvent: ref<MessengerThreadSelectedEvent>;
    if Equals(className, n"gameJournalPhoneMessage") || Equals(className, n"gameJournalPhoneChoiceGroup") || Equals(className, n"gameJournalPhoneChoiceEntry") {
      cashSelectedIdx = this.m_listController.GetToggledIndex();
      this.m_listController.SelectItem(cashSelectedIdx);
      this.m_listController.ToggleItem(cashSelectedIdx);
      this.ForceSelectIndex(cashSelectedIdx);
      selectedEvent = new MessengerThreadSelectedEvent();
      selectedEvent.m_hash = entryHash;
      this.QueueEvent(selectedEvent);
    };
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
    };
  }

  protected cb func OnMessengerGameControllerDelayInit(evt: ref<MessengerForceSelectionEvent>) -> Bool {
    let contactEntry: wref<JournalContact>;
    let contactHash: Int32;
    let entry: wref<JournalEntry>;
    let locatedIndex: Int32;
    let newIndex: Uint32;
    let threadEntry: wref<JournalPhoneConversation>;
    if evt.m_selectionIndex != -1 {
      newIndex = Cast(evt.m_selectionIndex);
    } else {
      entry = this.m_journalManager.GetEntry(Cast(evt.m_hash));
      threadEntry = entry as JournalPhoneConversation;
      if threadEntry != null {
        contactEntry = this.m_journalManager.GetParentEntry(threadEntry) as JournalContact;
        contactHash = this.m_journalManager.GetEntryHash(contactEntry);
        if !this.m_listController.IsLevelToggled(contactHash) {
          this.m_listController.ToggleLevel(contactHash);
        };
      };
      locatedIndex = this.m_listController.GetIndexByJournalHash(evt.m_hash);
      if locatedIndex != -1 {
        newIndex = Cast(locatedIndex);
      } else {
        newIndex = 0u;
      };
    };
    this.m_listController.SelectItem(newIndex);
    this.m_listController.ToggleItem(newIndex);
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let linkData: ref<MessageMenuAttachmentData> = userData as MessageMenuAttachmentData;
    if IsDefined(linkData) {
      this.ForceSelectEntry(linkData.m_entryHash);
    } else {
      this.ForceSelectIndex(0u);
    };
  }

  private final func ForceSelectIndex(idx: Uint32) -> Void {
    let initEvent: ref<MessengerForceSelectionEvent> = new MessengerForceSelectionEvent();
    initEvent.m_selectionIndex = Cast(idx);
    this.QueueEvent(initEvent);
  }

  private final func ForceSelectEntry(hash: Int32) -> Void {
    let initEvent: ref<MessengerForceSelectionEvent> = new MessengerForceSelectionEvent();
    initEvent.m_selectionIndex = -1;
    initEvent.m_hash = hash;
    this.QueueEvent(initEvent);
  }

  private final func PopulateData() -> Void {
    let data: array<ref<VirutalNestedListData>> = MessengerUtils.GetContactDataArray(this.m_journalManager, true, true, this.m_activeData);
    this.m_listController.SetData(data, true);
  }

  protected cb func OnContactActivated(evt: ref<MessengerContactSelectedEvent>) -> Bool {
    switch evt.m_type {
      case MessengerContactType.Group:
        this.m_listController.ToggleLevel(evt.m_level);
        break;
      case MessengerContactType.Contact:
        this.SyncActiveData(evt);
        this.m_dialogController.ShowDialog(this.m_journalManager.GetEntry(Cast(evt.m_entryHash)));
        break;
      case MessengerContactType.Thread:
        this.SyncActiveData(evt);
        this.m_dialogController.ShowThread(this.m_journalManager.GetEntry(Cast(evt.m_entryHash)));
        break;
      default:
    };
  }

  private final func SyncActiveData(evt: ref<MessengerContactSelectedEvent>) -> Void {
    this.m_activeData.m_type = evt.m_type;
    this.m_activeData.m_entryHash = evt.m_entryHash;
    this.m_activeData.m_level = evt.m_level;
    let syncEvent: ref<MessengerContactSyncBackEvent> = new MessengerContactSyncBackEvent();
    this.QueueEvent(syncEvent);
  }
}
