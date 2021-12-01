
public class CodexGameController extends gameuiMenuGameController {

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_entryViewRef: inkCompoundRef;

  private edit let m_characterEntryViewRef: inkCompoundRef;

  private edit let m_noEntrySelectedWidget: inkWidgetRef;

  private edit let m_virtualList: inkWidgetRef;

  private edit let m_emptyPlaceholderRef: inkWidgetRef;

  private edit let m_leftBlockControllerRef: inkWidgetRef;

  private edit let m_filtersContainer: inkCompoundRef;

  private let m_journalManager: wref<JournalManager>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_listController: wref<CodexListVirtualNestedListController>;

  private let m_entryViewController: wref<CodexEntryViewController>;

  private let m_characterEntryViewController: wref<CodexEntryViewController>;

  private let m_player: wref<PlayerPuppet>;

  private let m_activeData: ref<CodexListSyncData>;

  private let m_selectedData: ref<CodexEntryData>;

  private let m_userDataEntry: Int32;

  private let m_doubleInputPreventionFlag: Bool;

  private let m_filtersControllers: array<wref<CodexFilterButtonController>>;

  protected cb func OnInitialize() -> Bool {
    let hintsWidget: ref<inkWidget> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root");
    this.m_buttonHintsController = hintsWidget.GetController() as ButtonHints;
    this.RefreshButtonHints();
    this.m_entryViewController = inkWidgetRef.GetController(this.m_entryViewRef) as CodexEntryViewController;
    this.m_characterEntryViewController = inkWidgetRef.GetController(this.m_characterEntryViewRef) as CodexEntryViewController;
    this.m_listController = inkWidgetRef.GetController(this.m_virtualList) as CodexListVirtualNestedListController;
    this.m_activeData = new CodexListSyncData();
    inkWidgetRef.SetVisible(this.m_entryViewRef, true);
    inkWidgetRef.SetVisible(this.m_characterEntryViewRef, false);
    this.SetupFilterButtons();
    this.PlayLibraryAnimation(n"codex_intro");
  }

  private final func SetupFilterButtons() -> Void {
    let controller: ref<CodexFilterButtonController>;
    let i: Int32;
    let widget: wref<inkWidget>;
    ArrayClear(this.m_filtersControllers);
    i = 1;
    while i < EnumInt(CodexCategoryType.Count) {
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_filtersContainer), n"CodexFilterButton");
      controller = widget.GetController() as CodexFilterButtonController;
      controller.Setup(IntEnum(i));
      ArrayPush(this.m_filtersControllers, controller);
      i += 1;
    };
  }

  private final func RefreshButtonHints() -> Void {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_journalManager = GameInstance.GetJournalManager(playerPuppet.GetGame());
    this.m_journalManager.RegisterScriptCallback(this, n"OnEntryVisitedUpdate", gameJournalListenerType.Visited);
    this.m_player = playerPuppet as PlayerPuppet;
    this.PopulateData();
    this.SelectEntry();
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_journalManager.UnregisterScriptCallback(this, n"OnJournalUpdate");
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    this.m_userDataEntry = userData as ShardForceSelectionEvent.m_hash;
    this.SelectEntry();
  }

  private final func SelectEntry() -> Void {
    let itemIndex: Int32;
    if this.m_userDataEntry != 0 && this.m_listController.GetDataSize() != 0 {
      itemIndex = this.FindItem(this.m_userDataEntry);
      if itemIndex >= 0 {
        this.ForceSelectIndex(Cast(itemIndex));
      };
    };
  }

  public func FindItem(hash: Int32) -> Int32 {
    let entryData: ref<CodexEntryData>;
    let i: Int32 = 0;
    while i < this.m_listController.GetDataSize() {
      entryData = FromVariant(this.m_listController.GetItem(Cast(i)));
      if entryData.m_hash == hash {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
    this.m_menuEventDispatcher.RegisterToEvent(n"OnAccept", this, n"OnAccept");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
    };
  }

  protected cb func OnEntryVisitedUpdate(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let selectedEvent: ref<CodexEntrySelectedEvent>;
    if Equals(className, n"gameJournalCodexEntry") || Equals(className, n"gameJournalOnscreen") {
      this.ForceSelectIndex(this.m_listController.GetSelectedIndex());
      selectedEvent = new CodexEntrySelectedEvent();
      selectedEvent.m_hash = entryHash;
      this.QueueEvent(selectedEvent);
    };
  }

  protected cb func OnEntryActivated(evt: ref<CodexSelectedEvent>) -> Bool {
    let selectedEntry: wref<JournalEntry>;
    let syncEvent: ref<CodexSyncBackEvent>;
    if evt.m_group {
      this.m_listController.ToggleLevel(evt.m_level);
    } else {
      if NotEquals(evt.m_data.m_imageType, CodexImageType.Character) {
        inkWidgetRef.SetVisible(this.m_entryViewRef, true);
        inkWidgetRef.SetVisible(this.m_characterEntryViewRef, false);
        this.m_entryViewController.ShowEntry(evt.m_data);
      } else {
        inkWidgetRef.SetVisible(this.m_entryViewRef, false);
        inkWidgetRef.SetVisible(this.m_characterEntryViewRef, true);
        this.m_characterEntryViewController.ShowEntry(evt.m_data);
      };
      this.m_selectedData = evt.m_data;
      this.RefreshButtonHints();
    };
    this.m_activeData.m_entryHash = evt.m_entryHash;
    this.m_activeData.m_level = evt.m_level;
    selectedEntry = this.m_journalManager.GetEntry(Cast(this.m_activeData.m_entryHash));
    if !this.m_journalManager.IsEntryVisited(selectedEntry) {
      this.m_journalManager.SetEntryVisited(selectedEntry, true);
    };
    syncEvent = new CodexSyncBackEvent();
    this.QueueEvent(syncEvent);
  }

  protected cb func OnCodexForceSelectionEvent(evt: ref<CodexForceSelectionEvent>) -> Bool {
    if evt.m_selectionIndex != -1 {
      this.m_listController.SelectItem(Cast(evt.m_selectionIndex));
      this.m_listController.ToggleItem(Cast(evt.m_selectionIndex));
    };
  }

  private final func ForceSelectIndex(idx: Uint32) -> Void {
    let initEvent: ref<CodexForceSelectionEvent> = new CodexForceSelectionEvent();
    initEvent.m_selectionIndex = Cast(idx);
    this.QueueEvent(initEvent);
  }

  private final func PopulateData() -> Void {
    let data: array<ref<VirutalNestedListData>> = CodexUtils.GetCodexDataArray(this.m_journalManager, this.m_activeData);
    if ArraySize(data) <= 0 {
      this.ShowNodataWarning();
    } else {
      this.HideNodataWarning();
      this.m_listController.SetData(data);
    };
  }

  private final func ShowNodataWarning() -> Void {
    inkWidgetRef.SetVisible(this.m_emptyPlaceholderRef, true);
    inkWidgetRef.SetVisible(this.m_entryViewRef, false);
    inkWidgetRef.SetVisible(this.m_characterEntryViewRef, false);
    inkWidgetRef.SetVisible(this.m_leftBlockControllerRef, false);
  }

  private final func HideNodataWarning() -> Void {
    inkWidgetRef.SetVisible(this.m_emptyPlaceholderRef, false);
    inkWidgetRef.SetVisible(this.m_leftBlockControllerRef, true);
  }

  protected cb func OnCodexFilterButtonClicked(e: ref<CodexFilterButtonClicked>) -> Bool {
    let i: Int32;
    let targetCategory: CodexCategoryType = e.toggled ? e.category : CodexCategoryType.All;
    this.m_listController.SetFilter(targetCategory);
    i = 0;
    while i < ArraySize(this.m_filtersControllers) {
      this.m_filtersControllers[i].UpdateSelectedCategory(targetCategory);
      i += 1;
    };
  }
}

public class CodexUserData extends IScriptable {

  public let DataSource: CodexDataSource;

  public final static func Make(dataSource: CodexDataSource) -> ref<CodexUserData> {
    let instance: ref<CodexUserData> = new CodexUserData();
    instance.DataSource = dataSource;
    return instance;
  }
}

public class OnscreenDisplayManager extends inkLogicController {

  protected edit let m_contentText: inkTextRef;

  public func ShowEntry(entry: wref<JournalOnscreen>) -> Void {
    inkTextRef.SetText(this.m_contentText, entry.GetDescription());
  }
}

public class CodexFilterButtonController extends inkLogicController {

  protected edit let m_root: inkWidgetRef;

  protected edit let m_image: inkImageRef;

  protected let m_category: CodexCategoryType;

  protected let m_toggled: Bool;

  protected let m_hovered: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnRelease", this, n"OnClicked");
  }

  public final func Setup(category: CodexCategoryType) -> Void {
    this.m_category = category;
    InkImageUtils.RequestSetImage(this, this.m_image, CodexUtils.GetCodexFilterIcon(category));
  }

  public final func UpdateSelectedCategory(selectedCategory: CodexCategoryType) -> Void {
    if NotEquals(this.m_category, selectedCategory) {
      this.m_toggled = false;
    };
    this.UpdateState();
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = false;
    this.UpdateState();
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = true;
    this.UpdateState();
  }

  protected cb func OnClicked(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<CodexFilterButtonClicked>;
    if e.IsAction(n"click") {
      this.m_toggled = !this.m_toggled;
      evt = new CodexFilterButtonClicked();
      evt.category = this.m_category;
      evt.toggled = this.m_toggled;
      this.QueueEvent(evt);
      this.UpdateState();
    };
  }

  protected final func UpdateState() -> Void {
    if this.m_hovered {
      inkWidgetRef.SetState(this.m_root, n"Hover");
    } else {
      if this.m_toggled {
        inkWidgetRef.SetState(this.m_root, n"Active");
      } else {
        inkWidgetRef.SetState(this.m_root, n"Default");
      };
    };
  }
}
