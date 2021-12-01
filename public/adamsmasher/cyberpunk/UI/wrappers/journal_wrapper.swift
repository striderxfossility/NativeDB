
public class JournalWrapper extends ABaseWrapper {

  private let m_journalManager: wref<JournalManager>;

  private let m_journalContext: JournalRequestContext;

  private let m_journalSubQuestContext: JournalRequestContext;

  private let m_listOfJournalEntries: array<wref<JournalEntry>>;

  private let m_gameInstance: GameInstance;

  public final func Init(gameInstance: GameInstance) -> Void {
    this.m_gameInstance = gameInstance;
    this.m_journalManager = GameInstance.GetJournalManager(gameInstance);
    this.m_journalContext.stateFilter.active = true;
    this.m_journalContext.stateFilter.succeeded = true;
    this.m_journalContext.stateFilter.failed = true;
    this.m_journalSubQuestContext.stateFilter.inactive = true;
    this.m_journalSubQuestContext.stateFilter.active = true;
    this.m_journalSubQuestContext.stateFilter.succeeded = true;
    this.m_journalSubQuestContext.stateFilter.failed = true;
  }

  public final func GetJournalManager() -> wref<JournalManager> {
    return this.m_journalManager;
  }

  public final func GetQuests(out entries: array<wref<JournalEntry>>) -> Void {
    this.m_journalManager.GetQuests(this.m_journalContext, entries);
  }

  private final func BuildQuestData_Recursive(currEntity: wref<JournalEntry>, out description: String, out questObjectives: array<ref<QuestObjectiveWrapper>>, out links: array<wref<JournalEntry>>, foundTracked: Bool) -> Void {
    let currEntry: wref<JournalEntry>;
    let currQuestObjectiveWrapper: ref<QuestObjectiveWrapper>;
    let descriptionEntry: wref<JournalQuestDescription>;
    let i: Int32;
    let isTrackedEntry: Bool;
    let linkEntry: wref<JournalQuestCodexLink>;
    let linkPathHash: Uint32;
    let listEntries: array<wref<JournalEntry>>;
    let questObjective: wref<JournalQuestObjective> = currEntity as JournalQuestObjective;
    let questSubObjective: wref<JournalQuestSubObjective> = currEntity as JournalQuestSubObjective;
    if IsDefined(questObjective) {
      this.m_journalManager.GetChildren(currEntity, this.m_journalSubQuestContext.stateFilter, listEntries);
    } else {
      if IsDefined(questSubObjective) {
        this.m_journalManager.GetChildren(currEntity, this.m_journalSubQuestContext.stateFilter, listEntries);
      } else {
        this.m_journalManager.GetChildren(currEntity, this.m_journalContext.stateFilter, listEntries);
      };
    };
    i = 0;
    while i < ArraySize(listEntries) {
      currEntry = listEntries[i];
      if !IsDefined(currEntry) {
      } else {
        if !foundTracked {
          isTrackedEntry = this.GetTrackingStatus(currEntry);
        } else {
          isTrackedEntry = false;
        };
        descriptionEntry = currEntry as JournalQuestDescription;
        linkEntry = currEntry as JournalQuestCodexLink;
        questObjective = currEntry as JournalQuestObjective;
        questSubObjective = currEntry as JournalQuestSubObjective;
        if IsDefined(descriptionEntry) {
          description += descriptionEntry.GetDescription() + "\\n";
        };
        if IsDefined(linkEntry) {
          linkPathHash = linkEntry.GetLinkPathHash();
          ArrayPush(links, this.m_journalManager.GetEntry(linkPathHash));
        } else {
          if IsDefined(questObjective) {
            currQuestObjectiveWrapper = new QuestObjectiveWrapper();
            currQuestObjectiveWrapper.Init(questObjective, this.m_journalManager.GetEntryState(questObjective), isTrackedEntry, this.m_journalManager.GetEntryHash(questObjective), this.m_journalManager.GetObjectiveCurrentCounter(questObjective), this.m_journalManager.GetObjectiveTotalCounter(questObjective));
            ArrayPush(questObjectives, currQuestObjectiveWrapper);
          } else {
            if IsDefined(questSubObjective) {
              currQuestObjectiveWrapper = ArrayLast(questObjectives);
              currQuestObjectiveWrapper.AddSubObjective(questSubObjective, this.m_journalManager.GetEntryState(questSubObjective), isTrackedEntry, this.m_journalManager.GetEntryHash(questSubObjective));
            };
          };
        };
        this.BuildQuestData_Recursive(currEntry, description, questObjectives, links, isTrackedEntry || foundTracked);
      };
      i += 1;
    };
  }

  public final func BuildQuestData(currQuest: wref<JournalQuest>) -> ref<QuestDataWrapper> {
    let foundTracked: Bool;
    let links: array<wref<JournalEntry>>;
    let questData: ref<QuestDataWrapper>;
    let questObjectives: array<ref<QuestObjectiveWrapper>>;
    let recommendedLevel: Int32;
    let title: String;
    let descriptionString: String = "";
    if IsDefined(currQuest) {
      foundTracked = this.GetTrackingStatus(currQuest);
      this.BuildQuestData_Recursive(currQuest, descriptionString, questObjectives, links, foundTracked);
    };
    title = currQuest.GetTitle(this.m_journalManager);
    questData = new QuestDataWrapper();
    recommendedLevel = GameInstance.GetLevelAssignmentSystem(this.m_gameInstance).GetLevelAssignment(currQuest.GetRecommendedLevelID());
    questData.Init(currQuest, title, descriptionString, links, questObjectives, this.m_journalManager.GetEntryState(currQuest), foundTracked, this.m_journalManager.GetEntryHash(currQuest), recommendedLevel, !this.IsVisited(currQuest), this.m_journalManager.GetDistrict(currQuest));
    return questData;
  }

  public final func GetTrackedEntry() -> wref<JournalEntry> {
    return this.m_journalManager.GetTrackedEntry();
  }

  public final func GetTrackingStatus(entry: wref<JournalEntry>) -> Bool {
    let trackedEntry: wref<JournalEntry> = this.GetTrackedEntry();
    return IsDefined(trackedEntry) && this.m_journalManager.GetEntryHash(trackedEntry) == this.m_journalManager.GetEntryHash(entry);
  }

  public final func SetTracking(entry: wref<JournalEntry>) -> Void {
    if IsDefined(entry) && Equals(this.m_journalManager.GetEntryState(entry), gameJournalEntryState.Active) {
      this.m_journalManager.TrackEntry(entry);
    };
  }

  public final func SetVisited(entry: wref<JournalEntry>) -> Void {
    if IsDefined(entry) && !this.m_journalManager.IsEntryVisited(entry) {
      this.m_journalManager.SetEntryVisited(entry, true);
    };
  }

  public final func IsVisited(entry: wref<JournalEntry>) -> Bool {
    if IsDefined(entry) {
      return this.m_journalManager.IsEntryVisited(entry);
    };
    return true;
  }

  public final func UpdateQuestData(toUpdate: ref<QuestDataWrapper>) -> ref<QuestDataWrapper> {
    let i: Int32;
    let limit: Int32;
    let questEntries: array<wref<JournalEntry>>;
    let questEntry: wref<JournalQuest>;
    this.GetQuests(questEntries);
    i = 0;
    limit = ArraySize(questEntries);
    while i < limit {
      questEntry = questEntries[i] as JournalQuest;
      if IsDefined(questEntry) && toUpdate.Equals(this.m_journalManager.GetEntryHash(questEntry)) {
        return this.BuildQuestData(questEntry);
      };
      i += 1;
    };
    return null;
  }

  public final func GetDescriptionForCodexEntry(entry: wref<JournalCodexEntry>, out result: array<wref<JournalEntry>>) -> Void {
    this.m_journalManager.GetChildren(entry, this.m_journalContext.stateFilter, result);
  }

  public final func GetEntryHash(entry: wref<JournalEntry>) -> Int32 {
    return this.m_journalManager.GetEntryHash(entry);
  }
}

public class QuestDataWrapper extends AJournalEntryWrapper {

  private let m_isNew: Bool;

  private let m_quest: wref<JournalQuest>;

  private let m_title: String;

  private let m_description: String;

  private let m_questObjectives: array<ref<QuestObjectiveWrapper>>;

  private let m_links: array<wref<JournalEntry>>;

  private let m_questStatus: gameJournalEntryState;

  private let m_isTracked: Bool;

  private let m_isChildTracked: Bool;

  private let m_recommendedLevel: Int32;

  private let m_district: ref<District_Record>;

  public final func Init(currQuest: wref<JournalQuest>, title: String, description: String, links: array<wref<JournalEntry>>, questObjectives: array<ref<QuestObjectiveWrapper>>, questStatus: gameJournalEntryState, isTracked: Bool, uniqueId: Int32, recommendedLevel: Int32, isNew: Bool, district: ref<District_Record>) -> Void {
    this.SetUniqueId(uniqueId);
    this.m_quest = currQuest;
    this.m_title = title;
    this.m_description = description;
    this.m_links = links;
    this.m_questObjectives = questObjectives;
    this.m_questStatus = questStatus;
    this.m_isTracked = isTracked;
    this.m_recommendedLevel = recommendedLevel;
    this.m_isNew = isNew;
    this.m_district = district;
  }

  public final func GetDistrict() -> gamedataDistrict {
    return this.m_district.Type();
  }

  public final func GetType() -> gameJournalQuestType {
    return this.m_quest.GetType();
  }

  public final func GetId() -> String {
    return this.m_quest.GetId();
  }

  public final func GetQuest() -> wref<JournalQuest> {
    return this.m_quest;
  }

  public final func GetStatus() -> gameJournalEntryState {
    return this.m_questStatus;
  }

  public final func GetDescription() -> String {
    return this.m_description;
  }

  public final func GetLinks() -> array<wref<JournalEntry>> {
    return this.m_links;
  }

  public final func GetObjectives() -> array<ref<QuestObjectiveWrapper>> {
    return this.m_questObjectives;
  }

  public final func GetTitle() -> String {
    return this.m_title;
  }

  public final func GetLevel() -> Int32 {
    return this.m_recommendedLevel;
  }

  public final func HasBriefing() -> Bool {
    return false;
  }

  public func ToString() -> String {
    return "[QuestDataWrapper] Id: " + this.GetId();
  }

  public final func Equals(questData: ref<QuestDataWrapper>) -> Bool {
    return this.Equals(questData.GetUniqueId());
  }

  public final func Equals(questUniqueId: Int32) -> Bool {
    return this.GetUniqueId() == questUniqueId;
  }

  public final func IsTracked() -> Bool {
    return this.m_isTracked;
  }

  public final func IsTrackedInHierarchy() -> Bool {
    let currObjective: ref<QuestObjectiveWrapper>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_questObjectives);
    while i < limit {
      currObjective = this.m_questObjectives[i];
      if currObjective.IsTracked() || currObjective.IsTrackedInHierarchy() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func IsOptional() -> Bool {
    let currObjective: ref<QuestObjectiveWrapper>;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_questObjectives);
    while i < limit {
      currObjective = this.m_questObjectives[i];
      if currObjective.IsOptional() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func IsNew() -> Bool {
    return this.m_isNew;
  }

  public final func UpdateIsNew(value: Bool) -> Void {
    this.m_isNew = value;
  }
}

public abstract class ABaseQuestObjectiveWrapper extends AJournalEntryWrapper {

  protected let m_questObjective: wref<JournalQuestObjectiveBase>;

  protected let m_objectiveStatus: gameJournalEntryState;

  protected let m_isTracked: Bool;

  protected let m_currentCounter: Int32;

  protected let m_totalCounter: Int32;

  public final func Init(questObjective: wref<JournalQuestObjectiveBase>, objectiveStatus: gameJournalEntryState, isTracked: Bool, uniqueId: Int32, currentCounter: Int32, totalCounter: Int32) -> Void {
    this.SetUniqueId(uniqueId);
    this.m_questObjective = questObjective;
    this.m_objectiveStatus = objectiveStatus;
    this.m_isTracked = isTracked;
    this.m_currentCounter = currentCounter;
    this.m_totalCounter = totalCounter;
  }

  public final func GetDescription() -> String {
    return this.m_questObjective.GetDescription();
  }

  public final func GetIsOptional() -> Bool {
    return this.m_questObjective.IsOptional();
  }

  public final func GetStatus() -> gameJournalEntryState {
    return this.m_objectiveStatus;
  }

  public final func IsActive() -> Bool {
    return Equals(this.GetStatus(), gameJournalEntryState.Active);
  }

  public final func GetQuestObjective() -> wref<JournalQuestObjectiveBase> {
    return this.m_questObjective;
  }

  public final func IsTracked() -> Bool {
    return this.m_isTracked;
  }

  public func IsTrackedInHierarchy() -> Bool {
    return false;
  }

  public final func GetCounterText() -> String {
    let counterText: String;
    if this.m_totalCounter > 0 {
      counterText = " [" + ToString(this.m_currentCounter) + "/" + ToString(this.m_totalCounter) + "]";
    };
    return counterText;
  }
}

public class QuestObjectiveWrapper extends ABaseQuestObjectiveWrapper {

  private let m_questSubObjectives: array<ref<QuestSubObjectiveWrapper>>;

  public final func AddSubObjective(questSubObjective: wref<JournalQuestSubObjective>, subObjectiveStatus: gameJournalEntryState, isTracked: Bool, uniqueId: Int32) -> Void {
    let currQuestSubObjectiveWrapper: ref<QuestSubObjectiveWrapper> = new QuestSubObjectiveWrapper();
    currQuestSubObjectiveWrapper.Init(questSubObjective, subObjectiveStatus, isTracked, uniqueId, 0, 0);
    ArrayPush(this.m_questSubObjectives, currQuestSubObjectiveWrapper);
  }

  public final func GetSubObjectives() -> array<ref<QuestSubObjectiveWrapper>> {
    return this.m_questSubObjectives;
  }

  public func IsTrackedInHierarchy() -> Bool {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_questSubObjectives);
    while i < limit {
      if this.m_questSubObjectives[i].IsTracked() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func IsOptional() -> Bool {
    return this.GetIsOptional();
  }
}

public class QuestSubObjectiveWrapper extends ABaseQuestObjectiveWrapper {

  public func ToString() -> String {
    return "[QuestSubObjectiveWrapper] Description: " + this.GetDescription();
  }
}

public abstract class AJournalEntryWrapper extends ABaseWrapper {

  private let m_UniqueId: Int32;

  public final func SetUniqueId(uniqueId: Int32) -> Void {
    this.m_UniqueId = uniqueId;
  }

  public final func GetUniqueId() -> Int32 {
    return this.m_UniqueId;
  }
}

public abstract class ABaseWrapper extends IScriptable {

  public func ToString() -> String {
    return "";
  }
}
