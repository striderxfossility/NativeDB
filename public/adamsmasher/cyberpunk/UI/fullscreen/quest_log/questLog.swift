
public class questLogGameController extends gameuiMenuGameController {

  private edit let m_virtualList: inkWidgetRef;

  private edit let m_detailsPanel: inkWidgetRef;

  private edit let m_buttonHints: inkWidgetRef;

  private edit let m_buttonTrack: inkWidgetRef;

  private let m_game: GameInstance;

  private let m_journalManager: wref<JournalManager>;

  private let m_quests: array<wref<JournalEntry>>;

  private let m_resolvedQuests: array<wref<JournalEntry>>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_trackedQuest: wref<JournalQuest>;

  private let m_curreentQuest: wref<JournalQuest>;

  private let m_externallyOpenedQuestHash: Int32;

  private let m_playerLevel: Int32;

  private let m_recommendedLevel: Int32;

  private let m_entryAnimProxy: ref<inkAnimProxy>;

  private let m_canUsePhone: Bool;

  public let m_listData: array<ref<VirutalNestedListData>>;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_buttonTrack, n"OnRelease", this, n"OnTrackButtonRelease");
    this.m_game = this.GetPlayerControlledObject().GetGame();
    this.m_journalManager = GameInstance.GetJournalManager(this.m_game);
    this.m_journalManager.RegisterScriptCallback(this, n"OnJournalReady", gameJournalListenerType.State);
    this.m_playerLevel = RoundMath(GameInstance.GetStatsSystem(this.m_game).GetStatValue(Cast(this.GetPlayerControlledObject().GetEntityID()), gamedataStatType.Level));
    this.OnJournalReady(0u, n"", JournalNotifyOption.Notify, JournalChangeType.Undefined);
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHints), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.PlayLibraryAnimation(n"journal_intro");
    this.m_canUsePhone = this.IsPhoneAvailable();
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
    inkWidgetRef.UnregisterFromCallback(this.m_buttonTrack, n"OnRelease", this, n"OnTrackButtonRelease");
  }

  protected cb func OnTrackButtonRelease(e: ref<inkPointerEvent>) -> Bool {
    let trackEvt: ref<RequestChangeTrackedObjective>;
    if e.IsAction(n"click") {
      trackEvt = new RequestChangeTrackedObjective();
      trackEvt.m_quest = this.m_curreentQuest;
      inkWidgetRef.SetVisible(this.m_buttonTrack, false);
      this.PlayLibraryAnimation(n"tracked");
      this.PlaySound(n"MapPin", n"OnCreate");
      this.QueueEvent(trackEvt);
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
    };
  }

  protected cb func OnJournalReady(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let context: JournalRequestContext;
    let contextFilter: JournalRequestStateFilter;
    let i: Int32;
    let resolvedContext: JournalRequestContext;
    let resolvedEntriesBuffer: array<wref<JournalEntry>>;
    contextFilter.active = true;
    contextFilter.inactive = false;
    contextFilter.succeeded = false;
    contextFilter.failed = false;
    context.stateFilter = contextFilter;
    ArrayClear(this.m_quests);
    this.m_journalManager.GetQuests(context, this.m_quests);
    resolvedContext.stateFilter = QuestLogUtils.GetSuccessFilter();
    ArrayClear(this.m_resolvedQuests);
    this.m_journalManager.GetQuests(resolvedContext, resolvedEntriesBuffer);
    i = 0;
    while i < ArraySize(resolvedEntriesBuffer) {
      ArrayPush(this.m_resolvedQuests, resolvedEntriesBuffer[i]);
      i += 1;
    };
    resolvedContext.stateFilter = QuestLogUtils.GetFailedFilter();
    this.m_journalManager.GetQuests(resolvedContext, resolvedEntriesBuffer);
    i = 0;
    while i < ArraySize(resolvedEntriesBuffer) {
      ArrayPush(this.m_resolvedQuests, resolvedEntriesBuffer[i]);
      i += 1;
    };
    this.m_trackedQuest = questLogGameController.GetTopQuestEntry(this.m_journalManager, this.m_journalManager.GetTrackedEntry());
    this.BuildQuestList();
  }

  private final func IsPhoneAvailable() -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = this.GetBlackboardSystem();
    let comDeviceBackboard: wref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_ComDevice);
    let psmBlackboard: wref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().PlayerStateMachine);
    let tier: Int32 = psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    let statusEffectLock: Bool = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"NoPhone");
    let tierLock: Bool = tier >= EnumInt(gamePSMHighLevel.SceneTier3) && tier <= EnumInt(gamePSMHighLevel.SceneTier5);
    let lastCallInformation: PhoneCallInformation = FromVariant(comDeviceBackboard.GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation));
    return !statusEffectLock && !tierLock && NotEquals(lastCallInformation.callPhase, questPhoneCallPhase.IncomingCall) && NotEquals(lastCallInformation.callPhase, questPhoneCallPhase.StartCall);
  }

  private final func GetListedCategories() -> array<gameJournalQuestType> {
    let result: array<gameJournalQuestType>;
    ArrayPush(result, gameJournalQuestType.MainQuest);
    ArrayPush(result, gameJournalQuestType.SideQuest);
    ArrayPush(result, gameJournalQuestType.StreetStory);
    ArrayPush(result, gameJournalQuestType.Contract);
    ArrayPush(result, gameJournalQuestType.VehicleQuest);
    return result;
  }

  private final func GetDisplayedCategory(category: gameJournalQuestType) -> gameJournalQuestType {
    if Equals(category, gameJournalQuestType.MinorQuest) {
      return gameJournalQuestType.SideQuest;
    };
    return category;
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let attachment: ref<MessageMenuAttachmentData> = userData as MessageMenuAttachmentData;
    if IsDefined(attachment) {
      this.m_externallyOpenedQuestHash = attachment.m_entryHash;
    };
  }

  private final func BuildQuestList() -> Void {
    let categoriesWithEntries: array<Int32>;
    let categoryData: ref<VirutalNestedListData>;
    let evt: ref<QuestlListItemClicked>;
    let i: Int32;
    let itemData: ref<VirutalNestedListData>;
    let listController: ref<QuestListVirtualNestedListController>;
    let listedCategories: array<gameJournalQuestType>;
    let questEntry: wref<JournalQuest>;
    let questToOpen: wref<JournalQuest>;
    let resolvedCategoryHeaderData: ref<QuestListHeaderData>;
    let targetQuestEntry: wref<JournalEntry>;
    let trackedQuestPositionInList: Int32;
    let trackedQuestType: Int32;
    ArrayClear(this.m_listData);
    listedCategories = this.GetListedCategories();
    i = 0;
    while i < ArraySize(listedCategories) {
      categoryData = new VirutalNestedListData();
      categoryData.m_collapsable = false;
      categoryData.m_isHeader = true;
      categoryData.m_level = EnumInt(this.GetDisplayedCategory(listedCategories[i]));
      categoryData.m_widgetType = 0u;
      categoryData.m_data = this.GetQuestListHeaderData(this.GetDisplayedCategory(listedCategories[i]));
      ArrayPush(this.m_listData, categoryData);
      i += 1;
    };
    if this.m_externallyOpenedQuestHash != 0 {
      targetQuestEntry = this.m_journalManager.GetEntry(Cast(this.m_externallyOpenedQuestHash));
      if IsDefined(targetQuestEntry as JournalQuestMapPinBase) {
        targetQuestEntry = questLogGameController.GetTopQuestEntry(this.m_journalManager, targetQuestEntry);
        if IsDefined(targetQuestEntry) {
          this.m_externallyOpenedQuestHash = this.m_journalManager.GetEntryHash(targetQuestEntry);
        };
      };
    };
    categoryData = new VirutalNestedListData();
    categoryData.m_collapsable = false;
    categoryData.m_isHeader = true;
    categoryData.m_level = ArraySize(listedCategories) + 1;
    categoryData.m_widgetType = 0u;
    resolvedCategoryHeaderData = new QuestListHeaderData();
    resolvedCategoryHeaderData.m_type = ArraySize(listedCategories) + 1;
    resolvedCategoryHeaderData.m_nameLocKey = n"UI-ResourceExports-Completed";
    categoryData.m_data = resolvedCategoryHeaderData;
    ArrayPush(this.m_listData, categoryData);
    i = 0;
    while i < ArraySize(this.m_quests) {
      questEntry = this.m_quests[i] as JournalQuest;
      itemData = new VirutalNestedListData();
      itemData.m_collapsable = true;
      itemData.m_isHeader = false;
      itemData.m_forceToTopWithinLevel = false;
      itemData.m_level = EnumInt(this.GetDisplayedCategory(questEntry.GetType()));
      itemData.m_widgetType = 1u;
      itemData.m_data = this.GetQuestListItemData(questEntry, this.m_trackedQuest);
      if !ArrayContains(categoriesWithEntries, itemData.m_level) {
        ArrayPush(categoriesWithEntries, itemData.m_level);
      };
      if this.m_externallyOpenedQuestHash != 0 {
        if this.m_journalManager.GetEntryHash(questEntry) == this.m_externallyOpenedQuestHash {
          questToOpen = questEntry;
        };
      } else {
        if questToOpen == null || questEntry == this.m_trackedQuest {
          questToOpen = questEntry;
        };
      };
      if questToOpen == questEntry {
        trackedQuestPositionInList = ArraySize(this.m_listData);
      };
      ArrayPush(this.m_listData, itemData);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_resolvedQuests) {
      questEntry = this.m_resolvedQuests[i] as JournalQuest;
      itemData = new VirutalNestedListData();
      itemData.m_collapsable = true;
      itemData.m_isHeader = false;
      itemData.m_level = ArraySize(listedCategories) + 1;
      itemData.m_widgetType = 1u;
      itemData.m_data = this.GetQuestListItemData(questEntry, this.m_trackedQuest, true, ArraySize(listedCategories) + 1);
      if !ArrayContains(categoriesWithEntries, itemData.m_level) {
        ArrayPush(categoriesWithEntries, itemData.m_level);
      };
      ArrayPush(this.m_listData, itemData);
      i += 1;
    };
    i = ArraySize(this.m_listData) - 1;
    while i >= 0 {
      if this.m_listData[i].m_widgetType == 0u && this.m_listData[i].m_level != EnumInt(gameJournalQuestType.MainQuest) {
        if !ArrayContains(categoriesWithEntries, this.m_listData[i].m_level) {
          ArrayErase(this.m_listData, i);
        };
      };
      i -= 1;
    };
    if IsDefined(questToOpen) {
      trackedQuestType = EnumInt(this.GetDisplayedCategory(questToOpen.GetType()));
      if trackedQuestType != EnumInt(gameJournalQuestType.MainQuest) {
        this.m_listData[trackedQuestPositionInList].m_forceToTopWithinLevel = true;
      };
    };
    listController = inkWidgetRef.GetController(this.m_virtualList) as QuestListVirtualNestedListController;
    listController.SetData(this.m_listData);
    if IsDefined(questToOpen) {
      evt = new QuestlListItemClicked();
      evt.m_questData = questToOpen;
      evt.m_skipAnimation = true;
      this.QueueEvent(evt);
      i = 0;
      while i < ArraySize(categoriesWithEntries) {
        if categoriesWithEntries[i] != trackedQuestType {
          listController.ToggleLevel(categoriesWithEntries[i]);
        };
        i += 1;
      };
    };
  }

  public final static func GetTopQuestEntry(journalManager: ref<JournalManager>, entry: wref<JournalEntry>) -> wref<JournalQuest> {
    let lastValidQuestEntry: wref<JournalQuest>;
    let tempEntry: wref<JournalEntry> = entry;
    while tempEntry != null {
      tempEntry = journalManager.GetParentEntry(tempEntry);
      if IsDefined(tempEntry as JournalQuest) {
        lastValidQuestEntry = tempEntry as JournalQuest;
      };
    };
    return lastValidQuestEntry;
  }

  private final func GetQuestListHeaderData(type: gameJournalQuestType) -> ref<QuestListHeaderData> {
    let result: ref<QuestListHeaderData> = new QuestListHeaderData();
    result.m_type = EnumInt(type);
    switch type {
      case gameJournalQuestType.MainQuest:
        result.m_nameLocKey = n"UI-Quests-Labels-MainQuests";
        break;
      case gameJournalQuestType.SideQuest:
        result.m_nameLocKey = n"UI-Quests-Labels-SideQuests";
        break;
      case gameJournalQuestType.MinorQuest:
        result.m_nameLocKey = n"UI-Quests-Labels-MinorQuests";
        break;
      case gameJournalQuestType.StreetStory:
        result.m_nameLocKey = n"UI-Quests-Labels-StreetStories";
        break;
      case gameJournalQuestType.Contract:
        result.m_nameLocKey = n"UI-Quests-Labels-Contracts";
        break;
      case gameJournalQuestType.VehicleQuest:
        result.m_nameLocKey = n"UI-Quests-Labels-VehicleQuests";
    };
    return result;
  }

  private final func GetQuestListItemData(questEntry: ref<JournalQuest>, opt trackedQuest: ref<JournalQuest>, opt overrideType: Bool, opt forcedType: Int32) -> ref<QuestListItemData> {
    let recommendedLevel: Int32 = GameInstance.GetLevelAssignmentSystem(this.m_game).GetLevelAssignment(this.m_journalManager.GetRecommendedLevelID(questEntry));
    let result: ref<QuestListItemData> = new QuestListItemData();
    result.m_questType = overrideType ? forcedType : EnumInt(this.GetDisplayedCategory(questEntry.GetType()));
    result.m_timestamp = this.m_journalManager.GetEntryTimestamp(questEntry);
    result.m_journalManager = this.m_journalManager;
    result.m_questData = questEntry;
    result.m_playerLevel = this.m_playerLevel;
    result.m_recommendedLevel = recommendedLevel;
    result.m_isResolved = overrideType;
    result.m_State = this.m_journalManager.GetEntryState(questEntry);
    if trackedQuest != null {
      result.m_isTrackedQuest = trackedQuest == questEntry;
    };
    result.m_isVisited = this.m_journalManager.IsEntryVisited(questEntry);
    return result;
  }

  protected cb func OnQuestListHeaderClicked(evt: ref<QuestListHeaderClicked>) -> Bool {
    let listController: ref<VirtualNestedListController> = inkWidgetRef.GetController(this.m_virtualList) as VirtualNestedListController;
    listController.ToggleLevel(evt.m_questType);
  }

  protected cb func OnQuestListItemClicked(e: ref<QuestlListItemClicked>) -> Bool {
    let data: ref<QuestListItemData>;
    let detailsPanel: ref<QuestDetailsPanelController>;
    let i: Int32;
    let updateEvent: ref<UpdateOpenedQuestEvent> = new UpdateOpenedQuestEvent();
    updateEvent.m_openedQuest = e.m_questData;
    this.m_curreentQuest = e.m_questData;
    inkWidgetRef.SetVisible(this.m_buttonTrack, NotEquals(this.m_journalManager.GetEntryState(this.m_curreentQuest), gameJournalEntryState.Failed) && NotEquals(this.m_journalManager.GetEntryState(this.m_curreentQuest), gameJournalEntryState.Succeeded) && this.m_curreentQuest != this.m_trackedQuest);
    this.QueueEvent(updateEvent);
    i = 0;
    while i < ArraySize(this.m_listData) {
      data = this.m_listData[i].m_data as QuestListItemData;
      if IsDefined(data) {
        data.m_isOpenedQuest = updateEvent.m_openedQuest == data.m_questData;
        if !this.m_journalManager.IsEntryVisited(data.m_questData) {
          this.m_journalManager.SetEntryVisited(data.m_questData, true);
        };
      };
      i += 1;
    };
    detailsPanel = inkWidgetRef.GetController(this.m_detailsPanel) as QuestDetailsPanelController;
    detailsPanel.SetPhoneAvailable(this.m_canUsePhone);
    detailsPanel.Setup(e.m_questData, this.m_journalManager, GameInstance.GetScriptableSystemsContainer(this.m_game).Get(n"PhoneSystem") as PhoneSystem, GameInstance.GetMappinSystem(this.m_game), this.m_game, e.m_skipAnimation);
    if this.m_entryAnimProxy.IsPlaying() {
      this.m_entryAnimProxy.Stop();
    };
    this.m_entryAnimProxy = this.PlayLibraryAnimation(n"entry_fade_in");
  }

  private final func GetFirstObjectiveFromQuest(journalQuest: wref<JournalQuest>) -> wref<JournalQuestObjective> {
    let i: Int32;
    let unpackedData: array<wref<JournalEntry>>;
    QuestLogUtils.UnpackRecursive(this.m_journalManager, journalQuest, unpackedData);
    i = 0;
    while i < ArraySize(unpackedData) {
      if IsDefined(unpackedData[i] as JournalQuestObjective) {
        return unpackedData[i] as JournalQuestObjective;
      };
      i += 1;
    };
    return null;
  }

  protected cb func OnRequestChangeTrackedObjective(e: ref<RequestChangeTrackedObjective>) -> Bool {
    let data: ref<QuestListItemData>;
    let i: Int32;
    let updateEvent: ref<UpdateTrackedObjectiveEvent>;
    if NotEquals(this.m_journalManager.GetEntryState(e.m_quest), gameJournalEntryState.Failed) && NotEquals(this.m_journalManager.GetEntryState(e.m_quest), gameJournalEntryState.Succeeded) {
      if e.m_objective == null {
        e.m_objective = this.GetFirstObjectiveFromQuest(e.m_quest);
      };
      this.m_journalManager.TrackEntry(e.m_objective);
      this.PlaySound(n"MapPin", n"OnCreate");
      updateEvent = new UpdateTrackedObjectiveEvent();
      updateEvent.m_trackedObjective = e.m_objective;
      updateEvent.m_trackedQuest = questLogGameController.GetTopQuestEntry(this.m_journalManager, e.m_objective);
      this.m_trackedQuest = updateEvent.m_trackedQuest;
      this.QueueEvent(updateEvent);
      i = 0;
      while i < ArraySize(this.m_listData) {
        data = this.m_listData[i].m_data as QuestListItemData;
        if IsDefined(data) {
          data.m_isTrackedQuest = updateEvent.m_trackedQuest == data.m_questData;
        };
        i += 1;
      };
    };
  }

  protected cb func OnQuestListItemHoverOver(e: ref<QuestListItemHoverOverEvent>) -> Bool {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    if !e.m_isQuestResolved {
      this.m_buttonHintsController.AddButtonHint(n"track", GetLocalizedText("UI-UserActions-TrackObjective"));
    };
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-UserActions-Select"));
  }

  protected cb func OnQuestObjectiveHoverOver(e: ref<QuestObjectiveHoverOverEvent>) -> Bool {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_buttonHintsController.AddButtonHint(n"track", GetLocalizedText("UI-UserActions-TrackObjective"));
  }

  protected cb func OnQuestListItemHoverOut(e: ref<QuestListItemHoverOutEvent>) -> Bool {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
  }

  protected cb func OnQuestObjectiveHoverOut(e: ref<QuestObjectiveHoverOutEvent>) -> Bool {
    this.m_buttonHintsController.ClearButtonHints();
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
  }
}

public class QuestListItemData extends IScriptable {

  public let m_questType: Int32;

  public let m_timestamp: GameTime;

  public let m_isTrackedQuest: Bool;

  public let m_isOpenedQuest: Bool;

  public let m_questData: wref<JournalQuest>;

  public let m_journalManager: wref<JournalManager>;

  public let m_playerLevel: Int32;

  public let m_recommendedLevel: Int32;

  public let m_isVisited: Bool;

  public let m_isResolved: Bool;

  public let m_State: gameJournalEntryState;

  private let m_distancesFetched: Bool;

  private let m_objectivesDistances: array<ref<QuestListDistanceData>>;

  public final func GetDistances() -> array<ref<QuestListDistanceData>> {
    let distanceData: ref<QuestListDistanceData>;
    let i: Int32;
    let unpackedData: array<wref<JournalEntry>>;
    if !this.m_distancesFetched {
      QuestLogUtils.UnpackRecursive(this.m_journalManager, this.m_questData, unpackedData);
      i = 0;
      while i < ArraySize(unpackedData) {
        if IsDefined(unpackedData[i] as JournalQuestObjective) {
          distanceData = new QuestListDistanceData();
          distanceData.m_objective = unpackedData[i] as JournalQuestObjective;
          distanceData.m_distance = this.m_journalManager.GetDistanceToNearestMappin(unpackedData[i] as JournalQuestObjective);
          ArrayPush(this.m_objectivesDistances, distanceData);
        };
        i += 1;
      };
      this.m_distancesFetched = true;
    };
    return this.m_objectivesDistances;
  }

  public final func GetNearestDistance() -> ref<QuestListDistanceData> {
    let result: ref<QuestListDistanceData>;
    let distances: array<ref<QuestListDistanceData>> = this.GetDistances();
    let i: Int32 = 0;
    while i < ArraySize(distances) {
      if result == null {
        result = distances[i];
      } else {
        if distances[i].m_distance < result.m_distance {
          result = distances[i];
        };
      };
      i += 1;
    };
    return result;
  }

  public final func GetTrackedOrNearest() -> ref<QuestListDistanceData> {
    let i: Int32;
    let result: ref<QuestListDistanceData>;
    let unpackedData: array<wref<JournalEntry>>;
    let trackedObjective: wref<JournalEntry> = this.m_journalManager.GetTrackedEntry();
    if this.m_isTrackedQuest {
      QuestLogUtils.UnpackRecursive(this.m_journalManager, this.m_questData, unpackedData);
      i = 0;
      while i < ArraySize(unpackedData) {
        if IsDefined(unpackedData[i] as JournalQuestObjective) {
          if unpackedData[i] == trackedObjective {
            result = new QuestListDistanceData();
            result.m_objective = unpackedData[i] as JournalQuestObjective;
            result.m_distance = this.m_journalManager.GetDistanceToNearestMappin(unpackedData[i] as JournalQuestObjective);
            return result;
          };
        };
        i += 1;
      };
    } else {
      return this.GetNearestDistance();
    };
    return null;
  }
}

public class QuestListHeaderController extends inkLogicController {

  private edit let m_title: inkTextRef;

  private edit let m_arrow: inkWidgetRef;

  private edit let m_root: inkWidgetRef;

  private let m_questType: Int32;

  private let m_hovered: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<QuestListHeaderClicked>;
    if e.IsAction(n"click") {
      evt = new QuestListHeaderClicked();
      evt.m_questType = this.m_questType;
      this.QueueEvent(evt);
    };
  }

  public final func Setup(titleLocKey: CName, questType: Int32) -> Void {
    this.m_questType = questType;
    inkTextRef.SetText(this.m_title, NameToString(titleLocKey));
    this.m_hovered = false;
    this.UpdateState();
  }

  public final func ToggleArrow(open: Bool) -> Void {
    inkWidgetRef.SetRotation(this.m_arrow, open ? 0.00 : 180.00);
  }

  public final func UpdateState() -> Void {
    let targetState: CName = n"Default";
    if this.m_hovered {
      targetState = n"Hover";
    };
    inkWidgetRef.SetState(this.m_root, targetState);
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = true;
    this.UpdateState();
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.m_hovered = false;
    this.UpdateState();
  }
}

public class QuestListItemController extends inkLogicController {

  private edit let m_title: inkTextRef;

  private edit let m_level: inkTextRef;

  private edit let m_trackedMarker: inkWidgetRef;

  private edit let m_districtIcon: inkImageRef;

  private edit let m_stateIcon: inkImageRef;

  private edit let m_distance: inkTextRef;

  private edit let m_root: inkWidgetRef;

  private edit let m_newIcon: inkWidgetRef;

  private let m_data: ref<QuestListItemData>;

  private let m_closestObjective: ref<QuestListDistanceData>;

  private let m_hovered: Bool;

  private let animProxy: ref<inkAnimProxy>;

  public final func Setup(data: ref<QuestListItemData>) -> Void {
    let districtRecord: wref<District_Record>;
    let iconRecord: ref<UIIcon_Record>;
    this.m_data = data;
    inkTextRef.SetText(this.m_title, data.m_questData.GetTitle(data.m_journalManager));
    districtRecord = data.m_journalManager.GetDistrict(data.m_questData);
    iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + ToString(districtRecord.Type())));
    inkImageRef.SetAtlasResource(this.m_districtIcon, iconRecord.AtlasResourcePath());
    inkImageRef.SetTexturePart(this.m_districtIcon, iconRecord.AtlasPartName());
    if Equals(data.m_State, gameJournalEntryState.Succeeded) {
      inkWidgetRef.SetState(this.m_level, n"ThreatVeryLow");
      inkTextRef.SetText(this.m_level, GetLocalizedText("UI-Notifications-QuestCompleted"));
      inkWidgetRef.SetVisible(this.m_newIcon, false);
    } else {
      if Equals(data.m_State, gameJournalEntryState.Failed) {
        inkWidgetRef.SetState(this.m_level, n"ThreatVeryLow");
        inkTextRef.SetText(this.m_level, GetLocalizedText("UI-Notifications-Failed"));
        inkWidgetRef.SetVisible(this.m_newIcon, false);
      } else {
        inkWidgetRef.SetState(this.m_level, QuestLogUtils.GetLevelState(data.m_playerLevel, data.m_recommendedLevel));
        inkTextRef.SetText(this.m_level, QuestLogUtils.GetThreatText(data.m_playerLevel, data.m_recommendedLevel));
        inkWidgetRef.SetVisible(this.m_newIcon, !data.m_isVisited);
      };
    };
    inkWidgetRef.SetState(this.m_trackedMarker, data.m_isTrackedQuest ? n"Tracked" : n"Default");
    this.m_hovered = false;
    this.UpdateState();
    this.UpdateDistance();
  }

  private final func UpdateDistance() -> Void {
    this.m_closestObjective = this.m_data.GetTrackedOrNearest();
    let unitName: CName = MeasurementUtils.GetUnitLocalizationKey(UILocalizationHelper.GetSystemBaseUnit());
    if this.m_closestObjective == null || this.m_closestObjective.m_distance < 0.00 {
      inkWidgetRef.SetVisible(this.m_distance, false);
    } else {
      inkWidgetRef.SetVisible(this.m_distance, true);
      inkTextRef.SetText(this.m_distance, IntToString(RoundF(this.m_closestObjective.m_distance)) + GetLocalizedText(NameToString(unitName)));
    };
  }

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<QuestlListItemClicked>;
    let trackEvt: ref<RequestChangeTrackedObjective>;
    if e.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      evt = new QuestlListItemClicked();
      evt.m_questData = this.m_data.m_questData;
      this.QueueEvent(evt);
    } else {
      if e.IsAction(n"track") {
        if !this.m_data.m_isResolved {
          this.PlaySound(n"Button", n"OnPress");
          evt = new QuestlListItemClicked();
          evt.m_questData = this.m_data.m_questData;
          this.QueueEvent(evt);
          trackEvt = new RequestChangeTrackedObjective();
          trackEvt.m_quest = this.m_data.m_questData;
          this.QueueEvent(trackEvt);
        };
      };
    };
  }

  protected cb func OnUpdateTrackedObjectiveEvent(e: ref<UpdateTrackedObjectiveEvent>) -> Bool {
    this.m_data.m_isTrackedQuest = this.m_data.m_questData == e.m_trackedQuest;
    inkWidgetRef.SetState(this.m_trackedMarker, this.m_data.m_isTrackedQuest ? n"Tracked" : n"Default");
    this.UpdateDistance();
  }

  protected cb func OnUpdateOpenedQuestEvent(e: ref<UpdateOpenedQuestEvent>) -> Bool {
    this.UpdateState(this.m_data.m_isOpenedQuest);
  }

  public final func UpdateState(opt forceActive: Bool) -> Void {
    let animOptions: inkAnimOptions;
    let targetState: CName;
    let shouldBePlaying: Bool = this.m_data.m_isOpenedQuest || forceActive;
    let isPlaying: Bool = this.animProxy != null;
    if shouldBePlaying {
      if !isPlaying {
        animOptions.loopType = inkanimLoopType.Cycle;
        animOptions.loopInfinite = true;
        this.animProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"disk_anim", this.GetRootWidget(), animOptions);
      };
    } else {
      this.animProxy.Stop();
      this.animProxy = null;
      this.PlayLibraryAnimationOnAutoSelectedTargets(n"clear_disk_anim", this.GetRootWidget());
    };
    if forceActive {
      inkWidgetRef.SetState(this.m_root, n"Active");
      return;
    };
    targetState = this.m_data.m_isOpenedQuest ? n"Active" : n"Default";
    if this.m_hovered {
      targetState = n"Hover";
    };
    inkWidgetRef.SetState(this.m_root, targetState);
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<QuestListItemHoverOverEvent> = new QuestListItemHoverOverEvent();
    evt.m_isQuestResolved = this.m_data.m_isResolved;
    this.QueueEvent(evt);
    this.m_hovered = true;
    this.UpdateState();
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<QuestListItemHoverOutEvent> = new QuestListItemHoverOutEvent();
    this.QueueEvent(evt);
    this.m_hovered = false;
    this.UpdateState();
  }
}

public class QuestListVirtualNestedDataView extends VirtualNestedListDataView {

  protected func SortItems(compareBuilder: ref<CompareBuilder>, left: ref<VirutalNestedListData>, right: ref<VirutalNestedListData>) -> Void {
    let leftData: ref<QuestListItemData> = left.m_data as QuestListItemData;
    let rightData: ref<QuestListItemData> = right.m_data as QuestListItemData;
    if IsDefined(leftData) && IsDefined(rightData) {
      compareBuilder.GameTimeDesc(leftData.m_timestamp, rightData.m_timestamp);
    };
  }
}

public class QuestListVirtualNestedListController extends VirtualNestedListController {

  protected func GetDataView() -> ref<VirtualNestedListDataView> {
    let result: ref<QuestListVirtualNestedDataView> = new QuestListVirtualNestedDataView();
    return result;
  }
}

public class VirtualQuestListController extends inkVirtualCompoundItemController {

  protected edit let m_questList: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVAlign(inkEVerticalAlign.Top);
    this.GetRootWidget().SetHAlign(inkEHorizontalAlign.Left);
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
  }

  public final func GetWidget() -> inkWidgetRef {
    return this.m_questList;
  }

  public final func GetListController() -> ref<QuestListHeaderController> {
    return inkWidgetRef.GetController(this.GetWidget()) as QuestListHeaderController;
  }

  protected cb func OnDataChanged(value: Variant) -> Bool {
    let data: ref<QuestListHeaderData>;
    let listEntryData: ref<VirutalNestedListData> = FromVariant(value) as VirutalNestedListData;
    if !IsDefined(listEntryData) {
      return false;
    };
    data = listEntryData.m_data as QuestListHeaderData;
    this.GetListController().Setup(data.m_nameLocKey, data.m_type);
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    if discreteNav {
      this.SetCursorOverWidget(this.GetRootWidget());
    };
  }
}

public class VirtualQuestItemController extends inkVirtualCompoundItemController {

  protected edit let m_questItem: inkWidgetRef;

  protected let m_data: ref<VirutalNestedListData>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVAlign(inkEVerticalAlign.Top);
    this.GetRootWidget().SetHAlign(inkEHorizontalAlign.Left);
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
  }

  public final func GetWidget() -> inkWidgetRef {
    return this.m_questItem;
  }

  public final func GetItemController() -> ref<QuestListItemController> {
    return inkWidgetRef.GetController(this.GetWidget()) as QuestListItemController;
  }

  protected cb func OnDataChanged(value: Variant) -> Bool {
    let data: ref<QuestListItemData>;
    let listEntryData: ref<VirutalNestedListData> = FromVariant(value) as VirutalNestedListData;
    if !IsDefined(listEntryData) {
      return false;
    };
    data = listEntryData.m_data as QuestListItemData;
    this.GetItemController().Setup(data);
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    if discreteNav {
      this.SetCursorOverWidget(this.GetRootWidget());
    };
  }
}

public class QuestDetailsObjectiveController extends inkLogicController {

  private edit let m_objectiveName: inkTextRef;

  private edit let m_trackingMarker: inkWidgetRef;

  private edit let m_root: inkWidgetRef;

  private let m_objective: wref<JournalQuestObjective>;

  private let m_hovered: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  public final func Setup(objective: wref<JournalQuestObjective>, currentCounter: Int32, totalCounter: Int32, opt isTracked: Bool) -> Void {
    this.m_objective = objective;
    let finalTitle: String = objective.GetDescription();
    if totalCounter > 0 {
      finalTitle = GetLocalizedText(finalTitle) + " [" + IntToString(currentCounter) + "/" + IntToString(totalCounter) + "]";
    };
    if this.m_objective.IsOptional() {
      finalTitle = GetLocalizedText(finalTitle) + " [" + GetLocalizedText("UI-ScriptExports-Optional0") + "]";
    };
    inkTextRef.SetText(this.m_objectiveName, finalTitle);
    inkWidgetRef.SetState(this.m_trackingMarker, isTracked ? n"Tracked" : n"Default");
    this.m_hovered = false;
    this.UpdateState();
  }

  protected cb func OnUpdateTrackedObjectiveEvent(e: ref<UpdateTrackedObjectiveEvent>) -> Bool {
    inkWidgetRef.SetState(this.m_trackingMarker, this.m_objective == e.m_trackedObjective ? n"Tracked" : n"Default");
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<RequestChangeTrackedObjective>;
    if e.IsAction(n"click") || e.IsAction(n"track") {
      evt = new RequestChangeTrackedObjective();
      evt.m_objective = this.m_objective;
      this.QueueEvent(evt);
      this.PlayLibraryAnimationOnAutoSelectedTargets(n"quest_tracking_set", this.GetRootWidget());
    };
  }

  public final func UpdateState() -> Void {
    let targetState: CName = n"Default";
    if this.m_hovered {
      targetState = n"Hover";
    };
    inkWidgetRef.SetState(this.m_root, targetState);
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<QuestObjectiveHoverOverEvent> = new QuestObjectiveHoverOverEvent();
    this.QueueEvent(evt);
    this.m_hovered = true;
    this.UpdateState();
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<QuestObjectiveHoverOutEvent> = new QuestObjectiveHoverOutEvent();
    this.QueueEvent(evt);
    this.m_hovered = false;
    this.UpdateState();
  }
}

public class QuestDetailsPanelController extends inkLogicController {

  private edit let m_questTitle: inkTextRef;

  private edit let m_questDescription: inkTextRef;

  private edit let m_questLevel: inkTextRef;

  private edit let m_activeObjectives: inkCompoundRef;

  private edit let m_optionalObjectives: inkCompoundRef;

  private edit let m_completedObjectives: inkCompoundRef;

  private edit let m_codexLinksContainer: inkCompoundRef;

  private edit let m_contentContainer: inkWidgetRef;

  private edit let m_noSelectedQuestContainer: inkWidgetRef;

  private let m_currentQuestData: wref<JournalQuest>;

  private let m_journalManager: wref<JournalManager>;

  private let m_phoneSystem: wref<PhoneSystem>;

  private let m_mappinSystem: wref<MappinSystem>;

  private let m_trackedObjective: wref<JournalQuestObjective>;

  private let m_canUsePhone: Bool;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_noSelectedQuestContainer, true);
    inkWidgetRef.SetVisible(this.m_contentContainer, false);
  }

  public final func Setup(questData: wref<JournalQuest>, journalManager: wref<JournalManager>, phoneSystem: wref<PhoneSystem>, mappinSystem: wref<MappinSystem>, game: GameInstance, opt skipAnimation: Bool) -> Void {
    let playerLevel: Float = GameInstance.GetStatsSystem(game).GetStatValue(Cast(GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject().GetEntityID()), gamedataStatType.Level);
    let recommendedLevel: Int32 = GameInstance.GetLevelAssignmentSystem(game).GetLevelAssignment(questData.GetRecommendedLevelID());
    this.m_currentQuestData = questData;
    this.m_journalManager = journalManager;
    this.m_phoneSystem = phoneSystem;
    this.m_mappinSystem = mappinSystem;
    inkWidgetRef.SetVisible(this.m_noSelectedQuestContainer, false);
    inkWidgetRef.SetVisible(this.m_contentContainer, true);
    inkTextRef.SetText(this.m_questTitle, questData.GetTitle(journalManager));
    inkWidgetRef.SetState(this.m_questLevel, QuestLogUtils.GetLevelState(RoundMath(playerLevel), recommendedLevel));
    inkTextRef.SetText(this.m_questLevel, QuestLogUtils.GetThreatText(RoundMath(playerLevel), recommendedLevel));
    inkTextRef.SetText(this.m_questDescription, "");
    this.m_trackedObjective = journalManager.GetTrackedEntry() as JournalQuestObjective;
    inkCompoundRef.RemoveAllChildren(this.m_codexLinksContainer);
    this.PopulateObjectives();
  }

  public final func SetPhoneAvailable(value: Bool) -> Void {
    this.m_canUsePhone = value;
  }

  private final func PopulateObjectives() -> Void {
    let childEntries: array<wref<JournalEntry>>;
    let codexLinksObjectiveEntry: wref<JournalQuestObjective>;
    let controller: ref<QuestDetailsObjectiveController>;
    let currentCounter: Int32;
    let description: String;
    let descriptionEntries: array<wref<JournalQuestDescription>>;
    let i: Int32;
    let isObjectiveTracked: Bool;
    let objectiveEntry: wref<JournalQuestObjective>;
    let totalCounter: Int32;
    let widget: wref<inkWidget>;
    QuestLogUtils.UnpackRecursive(this.m_journalManager, this.m_currentQuestData, childEntries);
    inkCompoundRef.RemoveAllChildren(this.m_activeObjectives);
    inkCompoundRef.RemoveAllChildren(this.m_optionalObjectives);
    i = 0;
    while i < ArraySize(childEntries) {
      objectiveEntry = childEntries[i] as JournalQuestObjective;
      if IsDefined(objectiveEntry) {
        isObjectiveTracked = this.m_trackedObjective == objectiveEntry;
        widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_activeObjectives), n"questObjective");
        widget.SetHAlign(inkEHorizontalAlign.Left);
        widget.SetVAlign(inkEVerticalAlign.Top);
        currentCounter = this.m_journalManager.GetObjectiveCurrentCounter(objectiveEntry);
        totalCounter = this.m_journalManager.GetObjectiveTotalCounter(objectiveEntry);
        controller = widget.GetController() as QuestDetailsObjectiveController;
        controller.Setup(objectiveEntry, currentCounter, totalCounter, isObjectiveTracked);
        if isObjectiveTracked || !IsDefined(codexLinksObjectiveEntry) {
          codexLinksObjectiveEntry = objectiveEntry;
        };
      };
      i += 1;
    };
    if IsDefined(codexLinksObjectiveEntry) {
      this.PopulateCodexLinks(codexLinksObjectiveEntry);
    };
    descriptionEntries = QuestLogUtils.GetDescriptions(this.m_journalManager, this.m_currentQuestData);
    description = "";
    i = 0;
    while i < ArraySize(descriptionEntries) {
      description = description + GetLocalizedText(descriptionEntries[i].GetDescription()) + "\\n";
      i += 1;
    };
    inkTextRef.SetText(this.m_questDescription, description);
  }

  protected cb func OnUpdateTrackedObjectiveEvent(e: ref<UpdateTrackedObjectiveEvent>) -> Bool {
    this.PopulateCodexLinks(e.m_trackedObjective);
  }

  private final func PopulateCodexLinks(trackedObjective: ref<JournalQuestObjective>) -> Void {
    let childEntries: array<wref<JournalEntry>>;
    let childEntriesSorted: array<wref<JournalEntry>>;
    let childEntry: wref<JournalEntry>;
    let childEntryHash: Int32;
    let childEntryState: gameJournalEntryState;
    let codexLink: wref<JournalQuestCodexLink>;
    let i: Int32;
    let mappinLinkAdded: Bool;
    let mappinPosition: Vector3;
    let unpackFilter: JournalRequestStateFilter;
    unpackFilter.active = true;
    unpackFilter.inactive = true;
    QuestLogUtils.UnpackRecursiveWithFilter(this.m_journalManager, trackedObjective, unpackFilter, childEntries, true);
    inkCompoundRef.RemoveAllChildren(this.m_codexLinksContainer);
    i = 0;
    while i < ArraySize(childEntries) {
      if IsDefined(childEntries[i] as JournalQuestMapPinBase) {
        if !mappinLinkAdded {
          ArrayInsert(childEntriesSorted, 0, childEntries[i]);
          mappinLinkAdded = true;
        };
      } else {
        childEntry = this.m_journalManager.GetEntry(codexLink.GetLinkPathHash());
        if IsDefined(childEntry as JournalContact) {
          ArrayInsert(childEntriesSorted, mappinLinkAdded ? 1 : 0, childEntries[i]);
        } else {
          ArrayPush(childEntriesSorted, childEntries[i]);
        };
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(childEntriesSorted) && i < 4 {
      codexLink = childEntriesSorted[i] as JournalQuestCodexLink;
      if IsDefined(codexLink) {
        childEntry = this.m_journalManager.GetEntry(codexLink.GetLinkPathHash());
        childEntryState = this.m_journalManager.GetEntryState(childEntry);
        if Equals(childEntryState, gameJournalEntryState.Inactive) {
          childEntryHash = this.m_journalManager.GetEntryHash(childEntry);
          this.m_journalManager.ChangeEntryStateByHash(Cast(childEntryHash), gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        };
        if IsDefined(childEntry as JournalCodexEntry) {
          this.SpawnCodexLink(childEntry);
        } else {
          if IsDefined(childEntry as JournalContact) && this.m_canUsePhone {
            this.SpawnContactLink(childEntry as JournalContact);
          };
        };
      } else {
        if IsDefined(childEntriesSorted[i] as JournalImageEntry) {
          this.SpawnCodexLink(childEntriesSorted[i]);
        } else {
          if IsDefined(childEntriesSorted[i] as JournalQuestMapPinBase) {
            this.m_mappinSystem.GetQuestMappinPosition(Cast(this.m_journalManager.GetEntryHash(childEntriesSorted[i])), mappinPosition);
            this.SpawnMappinLink(childEntriesSorted[i] as JournalQuestMapPinBase, mappinPosition);
          };
        };
      };
      i += 1;
    };
  }

  private final func SpawnMappinLink(mappinEntry: ref<JournalQuestMapPinBase>, jumpTo: Vector3) -> Void {
    let widget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_codexLinksContainer), n"linkMappin");
    let controller: ref<QuestMappinLinkController> = widget.GetController() as QuestMappinLinkController;
    controller.Setup(mappinEntry, jumpTo);
  }

  private final func SpawnCodexLink(journalEntry: ref<JournalEntry>) -> Void {
    let widget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_codexLinksContainer), n"linkCodex");
    let controller: ref<QuestCodexLinkController> = widget.GetController() as QuestCodexLinkController;
    controller.Setup(journalEntry);
  }

  private final func SpawnContactLink(contactEntry: ref<JournalContact>) -> Void {
    let widget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_codexLinksContainer), n"linkPhoneContact");
    let controller: ref<QuestContactLinkController> = widget.GetController() as QuestContactLinkController;
    controller.Setup(contactEntry, this.m_journalManager, this.m_phoneSystem);
  }
}

public abstract class QuestLogUtils extends IScriptable {

  public final static func GetDefaultFilter() -> JournalRequestStateFilter {
    let contextFilter: JournalRequestStateFilter;
    contextFilter.active = true;
    contextFilter.inactive = true;
    contextFilter.succeeded = false;
    contextFilter.failed = false;
    return contextFilter;
  }

  public final static func GetObjectiveFilter() -> JournalRequestStateFilter {
    let contextFilter: JournalRequestStateFilter;
    contextFilter.active = false;
    contextFilter.inactive = true;
    contextFilter.succeeded = false;
    contextFilter.failed = false;
    return contextFilter;
  }

  public final static func GetSuccessFilter() -> JournalRequestStateFilter {
    let contextFilter: JournalRequestStateFilter;
    contextFilter.active = false;
    contextFilter.inactive = false;
    contextFilter.succeeded = true;
    contextFilter.failed = false;
    return contextFilter;
  }

  public final static func GetFailedFilter() -> JournalRequestStateFilter {
    let contextFilter: JournalRequestStateFilter;
    contextFilter.active = false;
    contextFilter.inactive = false;
    contextFilter.succeeded = false;
    contextFilter.failed = true;
    return contextFilter;
  }

  public final static func UnpackRecursiveWithFilter(journalManager: ref<JournalManager>, entry: wref<JournalContainerEntry>, filter: JournalRequestStateFilter, result: script_ref<array<wref<JournalEntry>>>, opt includeInactive: Bool) -> Void {
    let containerEntry: ref<JournalContainerEntry>;
    let currentEntry: wref<JournalEntry>;
    let childEntries: array<wref<JournalEntry>> = QuestLogUtils.Unpack(journalManager, entry, filter);
    let i: Int32 = 0;
    while i < ArraySize(childEntries) {
      currentEntry = childEntries[i];
      if !includeInactive && Equals(journalManager.GetEntryState(currentEntry), gameJournalEntryState.Inactive) && (currentEntry as JournalQuestMapPinBase) == null {
      } else {
        ArrayPush(Deref(result), currentEntry);
        containerEntry = currentEntry as JournalContainerEntry;
        if IsDefined(containerEntry) {
          if IsDefined(containerEntry as JournalQuestObjective) {
            QuestLogUtils.UnpackRecursiveWithFilter(journalManager, containerEntry, QuestLogUtils.GetDefaultFilter(), result, includeInactive);
            QuestLogUtils.UnpackRecursiveWithFilter(journalManager, containerEntry, QuestLogUtils.GetObjectiveFilter(), result, includeInactive);
          } else {
            QuestLogUtils.UnpackRecursiveWithFilter(journalManager, containerEntry, filter, result, includeInactive);
          };
        };
      };
      i += 1;
    };
  }

  public final static func UnpackRecursive(journalManager: ref<JournalManager>, entry: wref<JournalContainerEntry>, result: script_ref<array<wref<JournalEntry>>>) -> Void {
    QuestLogUtils.UnpackRecursiveWithFilter(journalManager, entry, QuestLogUtils.GetDefaultFilter(), result);
  }

  public final static func Unpack(journalManager: ref<JournalManager>, entry: wref<JournalContainerEntry>, filter: JournalRequestStateFilter) -> array<wref<JournalEntry>> {
    let childEntries: array<wref<JournalEntry>>;
    journalManager.GetChildren(entry, filter, childEntries);
    return childEntries;
  }

  public final static func GetDescriptions(journalManager: ref<JournalManager>, entry: wref<JournalContainerEntry>) -> array<wref<JournalQuestDescription>> {
    let contextFilter: JournalRequestStateFilter;
    let i: Int32;
    let objects: array<wref<JournalEntry>>;
    let results: array<wref<JournalQuestDescription>>;
    contextFilter.active = true;
    contextFilter.inactive = false;
    contextFilter.succeeded = true;
    contextFilter.failed = true;
    QuestLogUtils.UnpackRecursiveWithFilter(journalManager, entry, contextFilter, objects);
    i = 0;
    while i < ArraySize(objects) {
      if IsDefined(objects[i] as JournalQuestDescription) {
        ArrayPush(results, objects[i] as JournalQuestDescription);
      };
      i += 1;
    };
    return results;
  }

  public final static func GetLevelState(playerLevel: Int32, targetLevel: Int32) -> CName {
    let difference: Int32 = playerLevel - targetLevel;
    if difference <= EnumInt(EPowerDifferential.IMPOSSIBLE) {
      return n"ThreatVeryHigh";
    };
    if difference <= EnumInt(EPowerDifferential.HARD) {
      return n"ThreatHigh";
    };
    if difference <= EnumInt(EPowerDifferential.NORMAL) {
      return n"ThreatMedium";
    };
    if difference <= EnumInt(EPowerDifferential.EASY) {
      return n"ThreatLow";
    };
    if difference <= EnumInt(EPowerDifferential.TRASH) {
      return n"ThreatVeryLow";
    };
    return n"ThreatVeryLow";
  }

  public final static func GetThreatText(playerLevel: Int32, targetLevel: Int32) -> String {
    let result: String = GetLocalizedText("UI-ResourceExports-Threat") + ": ";
    switch QuestLogUtils.GetLevelState(playerLevel, targetLevel) {
      case n"ThreatVeryLow":
        result += GetLocalizedText("UI-Tooltips-ThreatVeryLow");
        break;
      case n"ThreatLow":
        result += GetLocalizedText("UI-Tooltips-Low");
        break;
      case n"ThreatMedium":
        result += GetLocalizedText("UI-Tooltips-ThreatMedium");
        break;
      case n"ThreatHigh":
        result += GetLocalizedText("UI-Tooltips-ThreatHigh");
        break;
      case n"ThreatVeryHigh":
        result += GetLocalizedText("UI-Tooltips-ThreatVeryHigh");
    };
    return result;
  }
}
