
public class ShardsMenuGameController extends gameuiMenuGameController {

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_entryViewRef: inkCompoundRef;

  private edit let m_virtualList: inkWidgetRef;

  private edit let m_emptyPlaceholderRef: inkWidgetRef;

  private edit let m_leftBlockControllerRef: inkWidgetRef;

  private edit let m_crackHint: inkWidgetRef;

  private let m_journalManager: wref<JournalManager>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_entryViewController: wref<CodexEntryViewController>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_listController: wref<ShardsVirtualNestedListController>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_player: wref<PlayerPuppet>;

  private let m_activeData: ref<CodexListSyncData>;

  private let m_hasNewCryptedEntries: Bool;

  private let m_isEncryptedEntrySelected: Bool;

  private let m_selectedData: ref<ShardEntryData>;

  private let m_mingameBB: wref<IBlackboard>;

  private let m_userDataEntry: Int32;

  private let m_doubleInputPreventionFlag: Bool;

  private let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let hintsWidget: ref<inkWidget> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root");
    this.m_buttonHintsController = hintsWidget.GetController() as ButtonHints;
    this.RefreshButtonHints();
    this.m_entryViewController = inkWidgetRef.GetController(this.m_entryViewRef) as CodexEntryViewController;
    this.m_listController = inkWidgetRef.GetController(this.m_virtualList) as ShardsVirtualNestedListController;
    this.m_activeData = new CodexListSyncData();
    inkWidgetRef.SetVisible(this.m_entryViewRef, false);
    this.PlayLibraryAnimation(n"shards_intro");
  }

  private final func RefreshButtonHints() -> Void {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    if this.m_isEncryptedEntrySelected {
      this.PlaySound(n"MapPin", n"OnDisable");
      inkWidgetRef.SetVisible(this.m_crackHint, true);
      this.PlayAnim(n"hint_show");
    } else {
      inkWidgetRef.SetVisible(this.m_crackHint, false);
      this.PlayAnim(n"hint_hide");
    };
  }

  public final func PlayAnim(animName: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_journalManager = GameInstance.GetJournalManager(playerPuppet.GetGame());
    this.m_journalManager.RegisterScriptCallback(this, n"OnEntryVisitedUpdate", gameJournalListenerType.Visited);
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_player = playerPuppet as PlayerPuppet;
    this.m_InventoryManager.Initialize(this.m_player);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.PopulateData();
    this.SelectEntry();
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_journalManager.UnregisterScriptCallback(this, n"OnJournalUpdate");
  }

  protected cb func OnButtonRelease(e: ref<inkPointerEvent>) -> Bool {
    if !e.IsHandled() {
      if e.IsAction(n"world_map_menu_open_quest") && this.m_isEncryptedEntrySelected && !this.m_doubleInputPreventionFlag {
        this.PlaySound(n"Button", n"OnPress");
        this.m_mingameBB = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().HackingMinigame);
        this.m_mingameBB.SetBool(GetAllBlackboardDefs().HackingMinigame.IsJournalTarget, false);
        ItemActionsHelper.PerformItemAction(this.m_player, this.m_selectedData.m_itemID);
        this.m_doubleInputPreventionFlag = true;
      };
      e.Handle();
    };
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
    let entryData: ref<ShardEntryData>;
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
    let selectedEvent: ref<ShardEntrySelectedEvent>;
    if Equals(className, n"gameJournalOnscreen") {
      this.ForceSelectIndex(this.m_listController.GetSelectedIndex());
      selectedEvent = new ShardEntrySelectedEvent();
      selectedEvent.m_hash = entryHash;
      this.QueueEvent(selectedEvent);
    };
  }

  protected cb func OnContactActivated(evt: ref<ShardSelectedEvent>) -> Bool {
    let selectedEntry: wref<JournalEntry>;
    let syncEvent: ref<ShardSyncBackEvent>;
    if evt.m_group {
      this.m_listController.ToggleLevel(evt.m_level);
    } else {
      this.PlaySound(n"Button", n"OnPress");
      inkWidgetRef.SetVisible(this.m_entryViewRef, true);
      this.m_entryViewController.ShowEntry(evt.m_data);
      this.m_isEncryptedEntrySelected = evt.m_data.m_isCrypted;
      this.m_selectedData = evt.m_data;
      this.RefreshButtonHints();
    };
    this.m_activeData.m_entryHash = evt.m_entryHash;
    this.m_activeData.m_level = evt.m_level;
    selectedEntry = this.m_journalManager.GetEntry(Cast(this.m_activeData.m_entryHash));
    if !this.m_journalManager.IsEntryVisited(selectedEntry) {
      this.m_journalManager.SetEntryVisited(selectedEntry, true);
    };
    syncEvent = new ShardSyncBackEvent();
    this.QueueEvent(syncEvent);
  }

  protected cb func OnShardForceSelectionEvent(evt: ref<ShardForceSelectionEvent>) -> Bool {
    if evt.m_selectionIndex != -1 {
      this.m_listController.SelectItem(Cast(evt.m_selectionIndex));
      this.m_listController.ToggleItem(Cast(evt.m_selectionIndex));
    };
  }

  private final func ForceSelectIndex(idx: Uint32) -> Void {
    let initEvent: ref<ShardForceSelectionEvent> = new ShardForceSelectionEvent();
    initEvent.m_selectionIndex = Cast(idx);
    this.QueueEvent(initEvent);
  }

  private final func PopulateData() -> Void {
    let counter: Int32;
    let groupData: ref<ShardEntryData>;
    let groupVirtualListData: ref<VirutalNestedListData>;
    let i: Int32;
    let items: array<InventoryItemData>;
    let level: Int32;
    let newEntries: array<Int32>;
    let tagsFilter: array<CName>;
    let data: array<ref<VirutalNestedListData>> = CodexUtils.GetShardsDataArray(this.m_journalManager, this.m_activeData);
    ArrayPush(tagsFilter, n"HideInBackpackUI");
    items = this.m_InventoryManager.GetPlayerItemsByType(gamedataItemType.Gen_Misc, tagsFilter);
    counter = 0;
    level = ArraySize(data);
    this.m_hasNewCryptedEntries = false;
    i = 0;
    while i < ArraySize(items) {
      if this.ProcessItem(items[i], data, level, newEntries) {
        counter += 1;
      };
      i += 1;
    };
    if counter >= 1 {
      groupData = new ShardEntryData();
      groupData.m_title = GetLocalizedText("Story-base-gameplay-static_data-database-scanning-scanning-quest_clue_template_04_localizedDescription");
      groupData.m_activeDataSync = this.m_activeData;
      groupData.m_counter = counter;
      groupData.m_isNew = this.m_hasNewCryptedEntries;
      groupData.m_newEntries = newEntries;
      groupVirtualListData = new VirutalNestedListData();
      groupVirtualListData.m_level = level;
      groupVirtualListData.m_widgetType = 1u;
      groupVirtualListData.m_isHeader = true;
      groupVirtualListData.m_data = groupData;
      ArrayPush(data, groupVirtualListData);
    };
    if ArraySize(data) <= 0 {
      this.ShowNodataWarning();
    } else {
      this.HideNodataWarning();
      this.m_listController.SetData(data, true, true);
    };
    this.RefreshButtonHints();
  }

  private final func ProcessItem(item: InventoryItemData, out data: array<ref<VirutalNestedListData>>, level: Int32, opt newEntries: script_ref<array<Int32>>) -> Bool {
    let effect: wref<TriggerHackingMinigameEffector_Record>;
    let entryString: String;
    let journalEntry: wref<JournalOnscreen>;
    if ItemActionsHelper.GetCrackAction(InventoryItemData.GetID(item)) == null {
      return false;
    };
    effect = (ItemActionsHelper.GetCrackAction(InventoryItemData.GetID(item)) as CrackAction_Record).Effector() as TriggerHackingMinigameEffector_Record;
    if effect == null {
      return false;
    };
    entryString = effect.JournalEntry();
    if !IsStringValid(entryString) {
      return false;
    };
    journalEntry = this.m_journalManager.GetEntryByString(entryString, "gameJournalOnscreen") as JournalOnscreen;
    if NotEquals(this.m_journalManager.GetEntryState(journalEntry), gameJournalEntryState.Inactive) {
      return false;
    };
    ArrayPush(data, this.GetVirtualDataForCrypted(item, journalEntry, level, newEntries));
    return true;
  }

  private final func GetVirtualDataForCrypted(item: InventoryItemData, curShard: wref<JournalOnscreen>, level: Int32, opt newEntries: script_ref<array<Int32>>) -> ref<VirutalNestedListData> {
    let shardVirtualListData: ref<VirutalNestedListData>;
    let shardData: ref<ShardEntryData> = new ShardEntryData();
    shardData.m_title = CodexUtils.GetShardTitleString(true, curShard.GetTitle());
    shardData.m_description = CodexUtils.GetShardTextString(true, curShard.GetDescription());
    shardData.m_imageId = curShard.GetIconID();
    shardData.m_hash = this.m_journalManager.GetEntryHash(curShard);
    shardData.m_timeStamp = this.m_journalManager.GetEntryTimestamp(curShard);
    shardData.m_activeDataSync = this.m_activeData;
    shardData.m_isNew = !this.m_journalManager.IsEntryVisited(curShard);
    shardData.m_isCrypted = true;
    shardData.m_itemID = InventoryItemData.GetID(item);
    if shardData.m_isNew {
      this.m_hasNewCryptedEntries = true;
      ArrayPush(shardData.m_newEntries, shardData.m_hash);
      ArrayPush(Deref(newEntries), shardData.m_hash);
    };
    shardVirtualListData = new VirutalNestedListData();
    shardVirtualListData.m_level = level;
    shardVirtualListData.m_widgetType = 0u;
    shardVirtualListData.m_isHeader = false;
    shardVirtualListData.m_data = shardData;
    return shardVirtualListData;
  }

  private final func ShowNodataWarning() -> Void {
    inkWidgetRef.SetVisible(this.m_emptyPlaceholderRef, true);
    inkWidgetRef.SetVisible(this.m_entryViewRef, false);
    inkWidgetRef.SetVisible(this.m_leftBlockControllerRef, false);
  }

  private final func HideNodataWarning() -> Void {
    inkWidgetRef.SetVisible(this.m_emptyPlaceholderRef, false);
    inkWidgetRef.SetVisible(this.m_entryViewRef, true);
    inkWidgetRef.SetVisible(this.m_leftBlockControllerRef, true);
  }
}
