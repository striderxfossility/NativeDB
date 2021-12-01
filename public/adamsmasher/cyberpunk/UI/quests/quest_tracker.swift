
public class QuestTrackerGameController extends inkHUDGameController {

  private edit let m_QuestTitle: inkTextRef;

  private edit let m_ObjectiveContainer: inkCompoundRef;

  private edit let m_TrackedMappinTitle: inkTextRef;

  private edit let m_TrackedMappinContainer: inkWidgetRef;

  private edit let m_TrackedMappinObjectiveContainer: inkCompoundRef;

  private let m_player: wref<GameObject>;

  protected let m_journalManager: wref<JournalManager>;

  protected let m_bufferedEntry: wref<JournalQuestObjective>;

  protected let m_bufferedPhase: wref<JournalQuestPhase>;

  protected let m_bufferedQuest: wref<JournalQuest>;

  private let m_root: wref<inkWidget>;

  private let blackboard: wref<IBlackboard>;

  private let uiSystemBB: ref<UI_SystemDef>;

  private let uiSystemId: ref<CallbackHandle>;

  private let trackedMappinId: ref<CallbackHandle>;

  private let m_trackedMappinSpawnRequest: wref<inkAsyncSpawnRequest>;

  private let m_currentMappin: wref<IMappin>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.m_player = this.GetPlayerControlledObject();
    this.m_player.RegisterInputListener(this, n"VisionPush");
    this.m_player.RegisterInputListener(this, n"UI_DPadDown");
    this.m_journalManager = GameInstance.GetJournalManager(this.m_player.GetGame());
    inkCompoundRef.RemoveAllChildren(this.m_ObjectiveContainer);
    this.UpdateTrackerData();
    this.m_journalManager.RegisterScriptCallback(this, n"OnStateChanges", gameJournalListenerType.State);
    this.m_journalManager.RegisterScriptCallback(this, n"OnTrackedEntryChanges", gameJournalListenerType.Tracked);
    this.m_journalManager.RegisterScriptCallback(this, n"OnCounterChanged", gameJournalListenerType.Counter);
    this.blackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
    this.uiSystemBB = GetAllBlackboardDefs().UI_System;
    this.uiSystemId = this.blackboard.RegisterListenerBool(this.uiSystemBB.IsInMenu, this, n"OnMenuUpdate");
    this.trackedMappinId = this.blackboard.RegisterListenerVariant(this.uiSystemBB.TrackedMappin, this, n"OnTrackedMappinUpdated");
    this.blackboard.SignalBool(this.uiSystemBB.IsInMenu);
    this.blackboard.SignalVariant(this.uiSystemBB.TrackedMappin);
  }

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnStateChanges(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let objectiveController: wref<QuestTrackerObjectiveLogicController>;
    let state: gameJournalEntryState = this.m_journalManager.GetEntryState(this.m_journalManager.GetEntry(hash));
    let j: Int32 = 0;
    while j < inkCompoundRef.GetNumChildren(this.m_ObjectiveContainer) {
      objectiveController = inkCompoundRef.GetWidgetByIndex(this.m_ObjectiveContainer, j).GetController() as QuestTrackerObjectiveLogicController;
      if objectiveController.IsObjectiveEntry() {
        if this.m_journalManager.GetEntry(hash) == objectiveController.GetObjectiveEntry() {
          if NotEquals(state, gameJournalEntryState.Succeeded) && NotEquals(state, gameJournalEntryState.Failed) {
            inkCompoundRef.RemoveChildByIndex(this.m_ObjectiveContainer, j);
            j -= 1;
          };
        };
      };
      j += 1;
    };
    this.UpdateTrackerData();
    state = this.m_journalManager.GetEntryState(this.m_journalManager.GetEntry(hash));
    j = 0;
    while j < inkCompoundRef.GetNumChildren(this.m_ObjectiveContainer) {
      objectiveController = inkCompoundRef.GetWidgetByIndex(this.m_ObjectiveContainer, j).GetController() as QuestTrackerObjectiveLogicController;
      if objectiveController.IsObjectiveEntry() {
        if objectiveController.IsReadyToRemove() {
          inkCompoundRef.RemoveChildByIndex(this.m_ObjectiveContainer, j);
          j -= 1;
        } else {
          if this.m_journalManager.GetEntry(hash) == objectiveController.GetObjectiveEntry() {
            if Equals(state, gameJournalEntryState.Succeeded) {
              objectiveController.SetFinished();
            };
            if Equals(state, gameJournalEntryState.Failed) {
              objectiveController.SetFailed();
            };
          };
        };
      };
      j += 1;
    };
  }

  protected cb func OnTrackedEntryChanges(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let objectiveController: wref<QuestTrackerObjectiveLogicController>;
    let state: gameJournalEntryState = this.m_journalManager.GetEntryState(this.m_journalManager.GetEntry(hash));
    let j: Int32 = 0;
    while j < inkCompoundRef.GetNumChildren(this.m_ObjectiveContainer) {
      objectiveController = inkCompoundRef.GetWidgetByIndex(this.m_ObjectiveContainer, j).GetController() as QuestTrackerObjectiveLogicController;
      if objectiveController.IsObjectiveEntry() {
        if this.m_journalManager.GetEntry(hash) == objectiveController.GetObjectiveEntry() {
          if NotEquals(state, gameJournalEntryState.Succeeded) && NotEquals(state, gameJournalEntryState.Failed) {
            inkCompoundRef.RemoveChildByIndex(this.m_ObjectiveContainer, j);
            j -= 1;
          };
        };
      };
      j += 1;
    };
    this.UpdateTrackerData();
    state = this.m_journalManager.GetEntryState(this.m_journalManager.GetEntry(hash));
    j = 0;
    while j < inkCompoundRef.GetNumChildren(this.m_ObjectiveContainer) {
      objectiveController = inkCompoundRef.GetWidgetByIndex(this.m_ObjectiveContainer, j).GetController() as QuestTrackerObjectiveLogicController;
      if objectiveController.IsObjectiveEntry() {
        if objectiveController.IsReadyToRemove() {
          inkCompoundRef.RemoveChildByIndex(this.m_ObjectiveContainer, j);
          j -= 1;
        } else {
          if this.m_journalManager.GetEntry(hash) == objectiveController.GetObjectiveEntry() {
            if Equals(state, gameJournalEntryState.Succeeded) {
              objectiveController.SetFinished();
            };
            if Equals(state, gameJournalEntryState.Failed) {
              objectiveController.SetFailed();
            };
          };
        };
      };
      j += 1;
    };
  }

  protected cb func OnCounterChanged(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    this.UpdateTrackerData();
  }

  protected cb func OnMenuUpdate(value: Bool) -> Bool {
    this.UpdateTrackerData();
  }

  protected cb func OnTrackedMappinUpdated(value: Variant) -> Bool {
    this.m_currentMappin = FromVariant(value) as IMappin;
    inkCompoundRef.RemoveAllChildren(this.m_TrackedMappinObjectiveContainer);
    inkWidgetRef.SetVisible(this.m_TrackedMappinContainer, IsDefined(this.m_currentMappin));
    if IsDefined(this.m_trackedMappinSpawnRequest) {
      this.m_trackedMappinSpawnRequest.Cancel();
    };
    if IsDefined(this.m_currentMappin) {
      this.m_trackedMappinSpawnRequest = this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_TrackedMappinObjectiveContainer), n"Objective", this, n"OnTrackedMappinSpawned");
    };
  }

  protected cb func OnTrackedMappinSpawned(newItem: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let mappinText: String = NameToString(MappinUIUtils.MappinToString(this.m_currentMappin.GetVariant()));
    let objectiveText: String = NameToString(MappinUIUtils.MappinToObjectiveString(this.m_currentMappin.GetVariant()));
    let objectiveController: ref<QuestTrackerObjectiveLogicController> = newItem.GetController() as QuestTrackerObjectiveLogicController;
    objectiveController.SetData(objectiveText, true, false, 0, 0, null);
    objectiveController.SetState(n"world");
    inkTextRef.SetText(this.m_TrackedMappinTitle, mappinText);
    this.PlayLibraryAnimation(n"TracketMappinIntro");
  }

  private final func SortObjectiveListByTimestamp(out sortedObjectives: array<wref<JournalEntry>>) -> Void {
    let j: Int32;
    let tempVar: wref<JournalEntry>;
    let i: Int32 = 0;
    while i < ArraySize(sortedObjectives) {
      j = 0;
      while j < ArraySize(sortedObjectives) - 1 {
        if this.m_journalManager.GetEntryTimestamp(sortedObjectives[i]) < this.m_journalManager.GetEntryTimestamp(sortedObjectives[j + 1]) {
          tempVar = sortedObjectives[j + 1];
          sortedObjectives[j + 1] = sortedObjectives[i];
          sortedObjectives[i] = tempVar;
        };
        j += 1;
      };
      i += 1;
    };
  }

  private final func UpdateTrackerData() -> Void {
    let allObjectives: array<wref<JournalEntry>>;
    let allPhases: array<wref<JournalEntry>>;
    let count: Int32;
    let createNewEntry: Bool;
    let entryWidget: wref<inkWidget>;
    let filter: JournalRequestStateFilter;
    let i: Int32;
    let ignoreIntroAnimation: Bool;
    let j: Int32;
    let m_objectiveEntry: wref<JournalQuestObjective>;
    let m_trackedEntry: wref<JournalQuestObjective>;
    let m_trackedPhase: wref<JournalQuestPhase>;
    let m_trackedQuest: wref<JournalQuest>;
    let objectiveController: wref<QuestTrackerObjectiveLogicController>;
    let z: Int32;
    filter.active = true;
    this.m_root.SetVisible(false);
    inkTextRef.SetText(this.m_QuestTitle, "");
    m_trackedEntry = this.m_journalManager.GetTrackedEntry() as JournalQuestObjective;
    if m_trackedEntry != null {
      m_trackedPhase = this.m_journalManager.GetParentEntry(m_trackedEntry) as JournalQuestPhase;
      if m_trackedPhase != null {
        m_trackedQuest = this.m_journalManager.GetParentEntry(m_trackedPhase) as JournalQuest;
        if m_trackedQuest != null {
          ignoreIntroAnimation = false;
          if this.m_bufferedQuest != m_trackedQuest || this.m_bufferedPhase != m_trackedPhase {
            inkCompoundRef.RemoveAllChildren(this.m_ObjectiveContainer);
            ignoreIntroAnimation = true;
          };
          this.m_journalManager.GetChildren(m_trackedQuest, filter, allPhases);
          this.m_root.SetVisible(NotEquals(m_trackedQuest.GetTitle(this.m_journalManager), ""));
          inkTextRef.SetText(this.m_QuestTitle, m_trackedQuest.GetTitle(this.m_journalManager));
          z = 0;
          while z < ArraySize(allPhases) {
            this.m_journalManager.GetChildren(allPhases[z], filter, allObjectives);
            this.SortObjectiveListByTimestamp(allObjectives);
            count = ArraySize(allObjectives);
            i = 0;
            while i < count {
              m_objectiveEntry = allObjectives[i] as JournalQuestObjective;
              if m_objectiveEntry != null {
                this.m_bufferedEntry = m_trackedEntry;
                this.m_bufferedPhase = m_trackedPhase;
                this.m_bufferedQuest = m_trackedQuest;
                createNewEntry = true;
                j = 0;
                while j < inkCompoundRef.GetNumChildren(this.m_ObjectiveContainer) {
                  objectiveController = inkCompoundRef.GetWidgetByIndex(this.m_ObjectiveContainer, j).GetController() as QuestTrackerObjectiveLogicController;
                  if objectiveController.GetObjectiveEntry() == m_objectiveEntry {
                    objectiveController.SetData(m_objectiveEntry.GetDescription(), m_objectiveEntry == m_trackedEntry, m_objectiveEntry.IsOptional(), this.m_journalManager.GetObjectiveCurrentCounter(m_objectiveEntry), this.m_journalManager.GetObjectiveTotalCounter(m_objectiveEntry), m_objectiveEntry);
                    createNewEntry = false;
                  };
                  j += 1;
                };
                if createNewEntry && Equals(this.m_journalManager.GetEntryState(m_objectiveEntry), gameJournalEntryState.Active) {
                  entryWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_ObjectiveContainer), n"Objective");
                  objectiveController = entryWidget.GetController() as QuestTrackerObjectiveLogicController;
                  objectiveController.SetData(m_objectiveEntry.GetDescription(), m_objectiveEntry == m_trackedEntry, m_objectiveEntry.IsOptional(), this.m_journalManager.GetObjectiveCurrentCounter(m_objectiveEntry), this.m_journalManager.GetObjectiveTotalCounter(m_objectiveEntry), m_objectiveEntry);
                  if !ignoreIntroAnimation {
                    objectiveController.PlayIntroAnim();
                    this.PlaySound(n"MapPin", n"OnCreate");
                  };
                };
              };
              i += 1;
            };
            z += 1;
          };
        };
      };
    };
  }

  protected cb func OnTrackedQuestPhaseUpdateRequest(evt: ref<TrackedQuestPhaseUpdateRequest>) -> Bool {
    this.UpdateTrackerData();
  }
}

public class QuestTrackerObjectiveLogicController extends inkLogicController {

  private edit let m_objectiveTitle: inkTextRef;

  private edit let m_trackingIcon: inkWidgetRef;

  private edit let m_trackingFrame: inkWidgetRef;

  private let m_objectiveEntry: wref<JournalQuestObjective>;

  private let m_AnimProxy: ref<inkAnimProxy>;

  private let m_IntroAnimProxy: ref<inkAnimProxy>;

  private let m_AnimOptions: inkAnimOptions;

  private let readyToRemove: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_AnimOptions.playReversed = false;
    this.m_AnimOptions.executionDelay = 0.00;
    this.m_AnimOptions.loopType = IntEnum(0l);
    this.m_AnimOptions.loopInfinite = false;
  }

  protected cb func OnUninitialize() -> Bool;

  private final func SetObjectiveState(state: CName) -> Void {
    inkWidgetRef.SetState(this.m_objectiveTitle, state);
    inkWidgetRef.SetState(this.m_trackingFrame, state);
    inkWidgetRef.SetState(this.m_trackingIcon, state);
  }

  public final func PlayIntroAnim() -> Void {
    this.m_IntroAnimProxy = this.PlayLibraryAnimation(n"ObjectiveIntro");
    this.m_IntroAnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnIntroAnimEnd");
  }

  public final func IsReadyToRemove() -> Bool {
    return this.readyToRemove;
  }

  public final func IsObjectiveEntry() -> Bool {
    return true;
  }

  public final func GetObjectiveEntry() -> wref<JournalQuestObjective> {
    return this.m_objectiveEntry;
  }

  public final func SetData(objectiveTitle: String, isTracked: Bool, isOptional: Bool, currentCounter: Int32, totalCounter: Int32, objectiveEntry: wref<JournalQuestObjective>) -> Void {
    let itemID: TweakDBID;
    let itemRecord: ref<Item_Record>;
    let state: CName;
    this.m_objectiveEntry = objectiveEntry;
    let finalTitle: String = objectiveTitle;
    if totalCounter > 0 {
      finalTitle = GetLocalizedText(finalTitle) + " [" + IntToString(currentCounter) + "/" + IntToString(totalCounter) + "]";
    };
    if isOptional {
      finalTitle = GetLocalizedText(finalTitle) + " [" + GetLocalizedText("UI-ScriptExports-Optional0") + "]";
    };
    itemID = this.m_objectiveEntry.GetItemID();
    if TDBID.IsValid(itemID) {
      itemRecord = TweakDBInterface.GetItemRecord(itemID);
      finalTitle += GetLocalizedText("Common-Characters-Semicolon") + " " + GetLocalizedText(NameToString(itemRecord.DisplayName()));
    };
    inkTextRef.SetText(this.m_objectiveTitle, finalTitle);
    inkWidgetRef.SetVisible(this.m_trackingIcon, isTracked);
    if isTracked {
      state = n"tracked";
    } else {
      state = n"untracked";
    };
    this.SetObjectiveState(state);
  }

  public final func SetState(state: CName) -> Void {
    this.SetObjectiveState(state);
  }

  protected cb func OnIntroAnimEnd(proxy: ref<inkAnimProxy>) -> Bool {
    this.GetRootWidget().SetVisible(true);
    this.m_IntroAnimProxy.Stop();
    this.m_IntroAnimProxy.UnregisterFromCallback(inkanimEventType.OnEndLoop, this, n"OnIntroAnimEnd");
  }

  protected cb func OnAnimEnd(proxy: ref<inkAnimProxy>) -> Bool {
    let evt: ref<TrackedQuestPhaseUpdateRequest> = new TrackedQuestPhaseUpdateRequest();
    this.GetRootWidget().SetVisible(false);
    this.m_AnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAnimEnd");
    this.readyToRemove = true;
    this.QueueEvent(evt);
  }

  public final func SetFinished() -> Void {
    if !this.readyToRemove {
      this.SetObjectiveState(n"succeeded");
      inkWidgetRef.SetVisible(this.m_trackingIcon, true);
      this.m_AnimProxy = this.PlayLibraryAnimation(n"ObjectiveSucceeded");
      this.m_AnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimEnd");
    };
  }

  public final func SetFailed() -> Void {
    if !this.readyToRemove {
      this.SetObjectiveState(n"failed");
      inkWidgetRef.SetVisible(this.m_trackingIcon, true);
      this.m_AnimProxy = this.PlayLibraryAnimation(n"ObjectiveFailed");
      this.m_AnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimEnd");
    };
  }
}
