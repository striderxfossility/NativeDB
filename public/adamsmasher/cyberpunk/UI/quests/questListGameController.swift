
public struct QuestUIUtils {

  public final static func GetJournalStateName(state: gameJournalEntryState, isTracked: Bool) -> CName {
    switch state {
      case gameJournalEntryState.Active:
        if isTracked {
          return n"tracked";
        };
        return n"untracked";
      case gameJournalEntryState.Succeeded:
        return n"succeeded";
      case gameJournalEntryState.Failed:
        return n"failed";
    };
    return n"Default";
  }

  public final static func GetEntryTypeFromName(entryTypeName: CName) -> UIObjectiveEntryType {
    switch entryTypeName {
      case n"gameJournalQuest":
        return UIObjectiveEntryType.Quest;
      case n"gameJournalQuestObjective":
        return UIObjectiveEntryType.Objective;
      case n"gameJournalQuestSubObjective":
        return UIObjectiveEntryType.SubObjective;
      default:
        return UIObjectiveEntryType.Invalid;
    };
  }

  public final static func GetLibraryIDForEntryType(entryType: UIObjectiveEntryType) -> CName {
    switch entryType {
      case UIObjectiveEntryType.Quest:
        return n"QuestEntry";
      case UIObjectiveEntryType.Objective:
        return n"ObjectiveEntry";
      case UIObjectiveEntryType.SubObjective:
        return n"SubObjectiveEntry";
      default:
        return n"";
    };
  }
}

public class QuestListGameController extends inkHUDGameController {

  private edit let m_entryList: inkVerticalPanelRef;

  private edit let m_scanPulse: inkCompoundRef;

  private edit let m_optionalHeader: inkWidgetRef;

  private edit let m_toDoHeader: inkWidgetRef;

  private edit let m_optionalList: inkVerticalPanelRef;

  private edit let m_nonOptionalList: inkVerticalPanelRef;

  private let m_entryControllers: ref<inkArray>;

  private let m_scanPulseAnimProxy: ref<inkAnimProxy>;

  private let m_stateChangesBlackboardId: Uint32;

  private let m_trackedChangesBlackboardId: Uint32;

  private let m_JournalWrapper: ref<JournalWrapper>;

  private let m_player: wref<GameObject>;

  private let m_optionalHeaderController: wref<QuestListHeaderLogicController>;

  private let m_toDoHeaderController: wref<QuestListHeaderLogicController>;

  private let m_lastNonOptionalObjective: ref<QuestObjectiveWrapper>;

  protected cb func OnInitialize() -> Bool {
    let ownerEntity: wref<GameObject> = this.GetOwnerEntity() as GameObject;
    let gameInstance: GameInstance = ownerEntity.GetGame();
    this.m_JournalWrapper = new JournalWrapper();
    this.m_JournalWrapper.Init(gameInstance);
    this.m_JournalWrapper.GetJournalManager().RegisterScriptCallback(this, n"OnStateChanges", gameJournalListenerType.State);
    this.m_JournalWrapper.GetJournalManager().RegisterScriptCallback(this, n"OnTrackedEntryChanges", gameJournalListenerType.Tracked);
    this.m_JournalWrapper.GetJournalManager().RegisterScriptCallback(this, n"OnCounterChanged", gameJournalListenerType.Counter);
    this.m_entryControllers = new inkArray();
    this.m_player = this.GetOwnerEntity() as GameObject;
    this.m_player.RegisterInputListener(this, n"VisionPush");
    this.m_player.RegisterInputListener(this, n"UI_DPadDown");
    this.m_optionalHeaderController = inkWidgetRef.GetController(this.m_optionalHeader) as QuestListHeaderLogicController;
    this.m_optionalHeaderController.SetLabel("UI-Cyberpunk-HUD-QuestList-optional");
    inkWidgetRef.SetVisible(this.m_optionalHeader, false);
    this.m_toDoHeaderController = inkWidgetRef.GetController(this.m_toDoHeader) as QuestListHeaderLogicController;
    this.m_toDoHeaderController.SetLabel("UI-Cyberpunk-HUD-QuestList-toDo");
    inkWidgetRef.SetVisible(this.m_toDoHeader, false);
    this.UpdateEntries();
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_JournalWrapper.GetJournalManager()) {
      this.m_JournalWrapper.GetJournalManager().UnregisterScriptCallback(this, n"OnStateChanges");
      this.m_JournalWrapper.GetJournalManager().UnregisterScriptCallback(this, n"OnTrackedEntryChanges");
      this.m_JournalWrapper.GetJournalManager().UnregisterScriptCallback(this, n"OnCounterChanged");
    };
  }

  protected cb func OnStateChanges(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    this.UpdateEntries();
  }

  protected cb func OnTrackedEntryChanges(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    this.UpdateEntries();
  }

  protected cb func OnCounterChanged(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    this.UpdateEntries();
  }

  private final func UpdateEntries() -> Void {
    let entryController: ref<ObjectiveEntryLogicController>;
    let limit: Int32;
    let listQuests: array<wref<JournalEntry>>;
    let entryControllers: array<wref<IScriptable>> = this.m_entryControllers.Get();
    let i: Int32 = 0;
    let oldEntriesNum: Int32 = ArraySize(entryControllers);
    while i < oldEntriesNum {
      entryController = entryControllers[i] as ObjectiveEntryLogicController;
      entryController.SetUpdated(false);
      i += 1;
    };
    this.m_JournalWrapper.GetQuests(listQuests);
    i = 0;
    limit = ArraySize(listQuests);
    while i < limit {
      this.UpdateQuest(this.m_JournalWrapper.BuildQuestData(listQuests[i] as JournalQuest));
      i += 1;
    };
    entryControllers = this.m_entryControllers.Get();
    i = 0;
    limit = ArraySize(entryControllers);
    while i < limit {
      entryController = entryControllers[i] as ObjectiveEntryLogicController;
      if !entryController.IsUpdated() {
        entryController.Hide();
      };
      i += 1;
    };
  }

  private final func UpdateQuest(questData: ref<QuestDataWrapper>) -> Bool {
    let entryController: wref<ObjectiveEntryLogicController>;
    let hasOptionalObjectives: Bool;
    let isOptional: Bool;
    let trackedQuest: Bool = questData.IsTracked() || questData.IsTrackedInHierarchy();
    if trackedQuest {
      entryController = this.GetOrCreateEntry(questData.GetUniqueId(), UIObjectiveEntryType.Quest, null);
      if IsDefined(entryController) {
        entryController.SetEntryData(this.BuildEntryData(questData));
        isOptional = this.UpdateObjectives(questData, entryController, trackedQuest);
        if !hasOptionalObjectives && isOptional {
          hasOptionalObjectives = true;
        };
      };
    } else {
      entryController = this.FindEntry(questData.GetUniqueId());
      if IsDefined(entryController) {
        entryController.SetEntryData(this.BuildEntryData(questData));
        isOptional = this.UpdateObjectives(questData, entryController, trackedQuest);
        if !hasOptionalObjectives && isOptional {
          hasOptionalObjectives = true;
        };
      };
      if NotEquals(entryController.GetEntryState(), gameJournalEntryState.Succeeded) && NotEquals(entryController.GetEntryState(), gameJournalEntryState.Failed) {
        entryController.Hide();
      };
    };
    return hasOptionalObjectives;
  }

  private final func UpdateObjectives(questData: ref<QuestDataWrapper>, parent: wref<ObjectiveEntryLogicController>, isParentTracked: Bool) -> Bool {
    let hasOptionalObjectives: Bool = false;
    let isOptional: Bool = false;
    let questObjectives: array<ref<QuestObjectiveWrapper>> = questData.GetObjectives();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(questObjectives);
    while i < limit {
      this.UpdateObjective(questObjectives[i], parent, isParentTracked);
      isOptional = questObjectives[i].IsOptional();
      if !hasOptionalObjectives && isOptional {
        hasOptionalObjectives = true;
      };
      i += 1;
    };
    return hasOptionalObjectives;
  }

  private final func UpdateObjective(objectiveData: ref<QuestObjectiveWrapper>, parent: wref<ObjectiveEntryLogicController>, isParentTracked: Bool) -> Void {
    let entryController: wref<ObjectiveEntryLogicController>;
    let entryState: gameJournalEntryState;
    if isParentTracked && Equals(objectiveData.GetStatus(), gameJournalEntryState.Active) {
      entryController = this.GetOrCreateEntry(objectiveData.GetUniqueId(), UIObjectiveEntryType.Objective, parent, objectiveData.IsOptional());
    } else {
      entryController = this.FindEntry(objectiveData.GetUniqueId());
    };
    if IsDefined(entryController) {
      entryController.SetEntryData(this.BuildEntryData(objectiveData));
      this.UpdateSubObjectives(objectiveData, entryController, objectiveData.IsTracked() || objectiveData.IsTrackedInHierarchy());
      entryState = entryController.GetEntryState();
      if !isParentTracked && NotEquals(entryState, gameJournalEntryState.Succeeded) && NotEquals(entryState, gameJournalEntryState.Failed) {
        entryController.Hide();
      };
    };
  }

  private final func UpdateSubObjectives(questData: ref<QuestObjectiveWrapper>, parent: wref<ObjectiveEntryLogicController>, isParentTracked: Bool) -> Void {
    let questSubObjectives: array<ref<QuestSubObjectiveWrapper>> = questData.GetSubObjectives();
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(questSubObjectives);
    while i < limit {
      this.UpdateSubObjective(questSubObjectives[i], parent, isParentTracked);
      i += 1;
    };
  }

  private final func UpdateSubObjective(subObjectiveData: ref<QuestSubObjectiveWrapper>, parent: wref<ObjectiveEntryLogicController>, isParentTracked: Bool) -> Void {
    let entryController: wref<ObjectiveEntryLogicController>;
    if isParentTracked && Equals(subObjectiveData.GetStatus(), gameJournalEntryState.Active) {
      entryController = this.GetOrCreateEntry(subObjectiveData.GetUniqueId(), UIObjectiveEntryType.SubObjective, parent);
    } else {
      entryController = this.FindEntry(subObjectiveData.GetUniqueId());
    };
    if IsDefined(entryController) {
      entryController.SetEntryData(this.BuildEntryData(subObjectiveData));
      if !isParentTracked && NotEquals(entryController.GetEntryState(), gameJournalEntryState.Succeeded) && NotEquals(entryController.GetEntryState(), gameJournalEntryState.Failed) {
        entryController.Hide();
      };
    };
  }

  private final func FindEntry(entryId: Int32) -> wref<ObjectiveEntryLogicController> {
    let entryController: wref<ObjectiveEntryLogicController>;
    let entryControllers: array<wref<IScriptable>> = this.m_entryControllers.Get();
    let totalControllers: Int32 = ArraySize(entryControllers);
    let i: Int32 = 0;
    while i < totalControllers {
      entryController = entryControllers[i] as ObjectiveEntryLogicController;
      if entryController.GetEntryId() == entryId {
        return entryController;
      };
      i += 1;
    };
    return null;
  }

  private final func GetOrCreateEntry(id: Int32, entryType: UIObjectiveEntryType, parent: wref<ObjectiveEntryLogicController>, opt isOptional: Bool) -> wref<ObjectiveEntryLogicController> {
    let entryIndex: Int32;
    let entryWidget: wref<inkWidget>;
    let list: inkVerticalPanelRef;
    let libraryID: CName = QuestUIUtils.GetLibraryIDForEntryType(entryType);
    let entryController: wref<ObjectiveEntryLogicController> = this.FindEntry(id);
    if entryController == null {
      if isOptional {
        list = this.m_optionalList;
      } else {
        list = this.m_nonOptionalList;
      };
      entryWidget = this.SpawnFromLocal(inkWidgetRef.Get(list), libraryID);
      entryWidget.SetHAlign(inkEHorizontalAlign.Right);
      entryController = entryWidget.GetController() as ObjectiveEntryLogicController;
      entryController.SetEntryId(id);
      entryController.RegisterToCallback(n"OnReadyToRemove", this, n"OnRemoveEntry");
      if NotEquals(entryType, UIObjectiveEntryType.SubObjective) || parent == null {
        this.m_entryControllers.PushBack(entryController);
      } else {
        entryIndex = this.FindNewEntryIndex(entryType, parent);
        if entryIndex > -1 {
          inkCompoundRef.ReorderChild(list, entryWidget, entryIndex);
          this.m_entryControllers.InsertAt(Cast(entryIndex), entryController);
        } else {
          this.m_entryControllers.PushBack(entryController);
        };
        entryController.AttachToParent(parent);
      };
    };
    return entryController;
  }

  private final func FindNewEntryIndex(entryType: UIObjectiveEntryType, parent: ref<ObjectiveEntryLogicController>) -> Int32 {
    let currEntryController: wref<ObjectiveEntryLogicController>;
    let foundParent: Bool = false;
    let entryControllers: array<wref<IScriptable>> = this.m_entryControllers.Get();
    let totalControllers: Int32 = ArraySize(entryControllers);
    let i: Int32 = 0;
    while i < totalControllers {
      currEntryController = entryControllers[i] as ObjectiveEntryLogicController;
      if !foundParent {
        foundParent = currEntryController.GetEntryId() == parent.GetEntryId();
      } else {
        if NotEquals(currEntryController.GetEntryType(), entryType) {
          return i;
        };
      };
      i += 1;
    };
    return -1;
  }

  protected cb func OnRemoveEntry(entryWidget: wref<inkWidget>) -> Bool {
    let entryController: wref<ObjectiveEntryLogicController> = entryWidget.GetController() as ObjectiveEntryLogicController;
    if entryController.IsReadyToRemove() {
      entryController.DetachFromParent();
      this.RemoveEntry(entryWidget);
      this.m_entryControllers.Remove(entryController);
    };
  }

  private final func RemoveEntry(entryWidget: wref<inkWidget>) -> Void {
    let tempController: wref<ObjectiveEntryLogicController>;
    let tempInkWidget: wref<inkWidget>;
    let entryController: wref<ObjectiveEntryLogicController> = entryWidget.GetController() as ObjectiveEntryLogicController;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_optionalList) {
      tempInkWidget = inkCompoundRef.GetWidgetByIndex(this.m_optionalList, i);
      tempController = tempInkWidget.GetController() as ObjectiveEntryLogicController;
      if tempController == entryController {
        inkCompoundRef.RemoveChild(this.m_optionalList, entryWidget);
      } else {
        i += 1;
      };
    };
    i = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_nonOptionalList) {
      tempInkWidget = inkCompoundRef.GetWidgetByIndex(this.m_nonOptionalList, i);
      tempController = tempInkWidget.GetController() as ObjectiveEntryLogicController;
      if tempController == entryController {
        inkCompoundRef.RemoveChild(this.m_nonOptionalList, entryWidget);
      } else {
        i += 1;
      };
    };
  }

  private final func BuildEntryData(inData: ref<ABaseWrapper>) -> UIObjectiveEntryData {
    let objectiveData: ref<QuestObjectiveWrapper>;
    let outData: UIObjectiveEntryData;
    let subObjectiveData: ref<QuestSubObjectiveWrapper>;
    let questData: ref<QuestDataWrapper> = inData as QuestDataWrapper;
    if IsDefined(questData) {
      outData.m_name = questData.GetTitle();
      outData.m_counter = "";
      outData.m_isTracked = questData.IsTracked();
      outData.m_type = UIObjectiveEntryType.Quest;
      outData.m_state = questData.GetStatus();
      outData.m_isOptional = questData.IsOptional();
    } else {
      objectiveData = inData as QuestObjectiveWrapper;
      if IsDefined(objectiveData) {
        outData.m_name = objectiveData.GetDescription();
        outData.m_counter = objectiveData.GetCounterText();
        outData.m_isTracked = objectiveData.IsTracked();
        outData.m_type = UIObjectiveEntryType.Objective;
        outData.m_state = objectiveData.GetStatus();
        outData.m_isOptional = questData.IsOptional() || objectiveData.IsOptional();
      } else {
        subObjectiveData = inData as QuestSubObjectiveWrapper;
        if IsDefined(subObjectiveData) {
          outData.m_name = subObjectiveData.GetDescription();
          outData.m_isTracked = subObjectiveData.IsTracked();
          outData.m_isTracked = subObjectiveData.IsTracked();
          outData.m_type = UIObjectiveEntryType.SubObjective;
          outData.m_state = subObjectiveData.GetStatus();
          outData.m_isOptional = questData.IsOptional();
        };
      };
    };
    return outData;
  }

  private final func ShouldDisplayEntry(entryType: UIObjectiveEntryType) -> Bool {
    return NotEquals(entryType, UIObjectiveEntryType.Invalid);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let actionName: CName = ListenerAction.GetName(action);
    let actionType: gameinputActionType = ListenerAction.GetType(action);
    if Equals(actionName, n"VisionPush") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
      if this.m_scanPulseAnimProxy.IsPlaying() {
        this.m_scanPulseAnimProxy.Stop();
      };
      this.m_scanPulseAnimProxy = this.PlayLibraryAnimation(n"ScanPulseAnimation");
    };
  }
}

public class QuestListHeaderLogicController extends inkLogicController {

  private edit let m_label: inkTextRef;

  public final func SetLabel(text: String) -> Void {
    inkTextRef.SetText(this.m_label, text);
  }
}
