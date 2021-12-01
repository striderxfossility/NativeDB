
public class GamplayQuestData extends IScriptable {

  public let m_questUniqueID: String;

  public let m_objectives: array<ref<GemplayObjectiveData>>;

  public final const func GetFreeObjectivePath() -> String {
    return this.GetPhaseEntryID() + "/" + this.GetFreeObjectiveEntryID();
  }

  public final const func GetbjectivePath(objectiveData: ref<GemplayObjectiveData>) -> String {
    return this.GetPhaseEntryID() + "/" + objectiveData.GetObjectiveEntryID();
  }

  public final const func GetFreeObjectiveEntryID() -> String {
    let sufix: String;
    if ArraySize(this.m_objectives) > 0 {
      sufix = ToString(ArraySize(this.m_objectives));
    };
    return this.GetBaseObjectiveEntryID() + sufix;
  }

  public final func AddObjective(objectiveData: ref<GemplayObjectiveData>, journal: ref<JournalManager>) -> Void {
    if this.HasObjective(objectiveData) {
      return;
    };
    if this.CreateObjective(objectiveData, journal) {
      ArrayPush(this.m_objectives, objectiveData);
      this.SetObjectiveState(objectiveData, journal, gameJournalEntryState.Active);
    };
  }

  public final const func HasObjective(objectiveData: ref<GemplayObjectiveData>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_objectives) {
      if this.m_objectives[i].GetOwnerID() == objectiveData.GetOwnerID() && Equals(this.m_objectives[i].GetClassName(), objectiveData.GetClassName()) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetObjective(objectiveData: ref<GemplayObjectiveData>) -> ref<GemplayObjectiveData> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_objectives) {
      if this.m_objectives[i].GetOwnerID() == objectiveData.GetOwnerID() && Equals(this.m_objectives[i].GetClassName(), objectiveData.GetClassName()) {
        return this.m_objectives[i];
      };
      i += 1;
    };
    return null;
  }

  private final func CreateObjective(objectiveData: ref<GemplayObjectiveData>, journal: ref<JournalManager>) -> Bool {
    let mappinData: MappinData;
    let mappinPath: String;
    let objectivePath: String = this.GetFreeObjectivePath();
    let isValid: Bool = journal.SetScriptedQuestObjectiveDescription(this.GetQuestEntryID(), objectiveData.GetUniqueID(), objectivePath, objectiveData.GetObjectiveDescription());
    if !isValid {
      return false;
    };
    mappinPath = this.GetFreeQuestMappinPath();
    isValid = journal.SetScriptedQuestMappinEntityID(this.GetQuestEntryID(), objectiveData.GetUniqueID(), mappinPath, objectiveData.GetOwnerID());
    if !isValid {
      return false;
    };
    mappinData.mappinType = t"Mappins.QuestStaticMappinDefinition";
    mappinData.variant = gamedataMappinVariant.DefaultQuestVariant;
    objectiveData.SetObjectiveEntryID(this.GetFreeObjectiveEntryID());
    journal.SetScriptedQuestMappinSlotName(this.GetQuestEntryID(), objectiveData.GetUniqueID(), mappinPath, t"AttachmentSlots.QuestDeviceMappin");
    journal.SetScriptedQuestMappinData(this.GetQuestEntryID(), objectiveData.GetUniqueID(), this.GetFreeQuestMappinPath(), mappinData);
    return true;
  }

  public final func SetObjectiveState(objectiveData: ref<GemplayObjectiveData>, journal: ref<JournalManager>, state: gameJournalEntryState) -> Void {
    let track: Bool;
    let objective: ref<GemplayObjectiveData> = this.GetObjective(objectiveData);
    if objective == null {
      return;
    };
    if Equals(state, gameJournalEntryState.Active) {
      track = true;
    };
    journal.SetScriptedQuestEntryState(this.GetQuestEntryID(), objectiveData.GetUniqueID(), this.GetbjectivePath(objectiveData), state, JournalNotifyOption.Notify, track);
    objective.SetObjectiveState(state);
  }

  public final const func IsCompleted() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_objectives) {
      if NotEquals(this.m_objectives[i].GetObjectiveState(), gameJournalEntryState.Inactive) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final const func GetQuestEntryID() -> String {
    return "generic_gameplay_quest";
  }

  public final const func GetPhaseEntryID() -> String {
    return "generic_gameplay_phase";
  }

  public final const func GetBaseObjectiveEntryID() -> String {
    return "generic_gameplay_objective";
  }

  public final const func GetMappinEntryID() -> String {
    return "generic_gameplay_mappin";
  }

  public final const func GetFreeQuestMappinPath() -> String {
    return this.GetPhaseEntryID() + "/" + this.GetFreeObjectiveEntryID() + "/" + this.GetMappinEntryID();
  }
}

public class GameplayQuestSystem extends ScriptableSystem {

  private let m_quests: array<ref<GamplayQuestData>>;

  private final func OnRegisterObjective(request: ref<RegisterGameplayObjectiveRequest>) -> Void {
    this.AddObjective(request.objectiveData);
  }

  private final func OnSetObjectiveState(request: ref<SetGameplayObjectiveStateRequest>) -> Void {
    this.SetObjectiveState(request.objectiveData, request.objectiveState);
  }

  private final func AddObjective(objectiveData: ref<GemplayObjectiveData>) -> Void {
    let questData: ref<GamplayQuestData> = this.GetQuestData(objectiveData);
    questData.AddObjective(objectiveData, this.GetJournal());
  }

  private final func SetObjectiveState(objectiveData: ref<GemplayObjectiveData>, objectiveState: gameJournalEntryState) -> Void {
    let questData: ref<GamplayQuestData> = this.GetQuestData(objectiveData);
    questData.SetObjectiveState(objectiveData, this.GetJournal(), objectiveState);
    this.EvaluateQuest(questData);
  }

  private final func HasQuest(questUniqueId: String) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_quests) {
      if Equals(this.m_quests[i].m_questUniqueID, questUniqueId) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func GetQuestData(objectiveData: ref<GemplayObjectiveData>) -> ref<GamplayQuestData> {
    let questData: ref<GamplayQuestData>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_quests) {
      if Equals(this.m_quests[i].m_questUniqueID, objectiveData.GetUniqueID()) {
        questData = this.m_quests[i];
      };
      i += 1;
    };
    if questData == null {
      questData = this.CreateQuest(objectiveData);
    };
    return questData;
  }

  private final func CreateQuest(objectiveData: ref<GemplayObjectiveData>) -> ref<GamplayQuestData> {
    let questData: ref<GamplayQuestData> = new GamplayQuestData();
    let isValid: Bool = this.GetJournal().CreateScriptedQuestFromTemplate(questData.GetQuestEntryID(), objectiveData.GetUniqueID(), objectiveData.GetQuestTitle());
    if isValid {
      questData.m_questUniqueID = objectiveData.GetUniqueID();
      ArrayPush(this.m_quests, questData);
      return questData;
    };
    return null;
  }

  private final func EvaluateQuest(questData: ref<GamplayQuestData>) -> Void {
    if questData.IsCompleted() {
      if this.RemoveQuest(questData) {
        ArrayRemove(this.m_quests, questData);
        questData = null;
      };
    };
  }

  private final func RemoveQuest(questData: ref<GamplayQuestData>) -> Bool {
    return this.GetJournal().DeleteScriptedQuest(questData.GetQuestEntryID(), questData.m_questUniqueID);
  }

  private final const func GetJournal() -> ref<JournalManager> {
    return GameInstance.GetJournalManager(this.GetGameInstance());
  }
}
