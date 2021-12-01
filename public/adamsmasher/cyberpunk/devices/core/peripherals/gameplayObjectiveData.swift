
public class GemplayObjectiveData extends IScriptable {

  @default(BackDoorObjectiveData, NETWORK)
  @default(ControlPanelObjectiveData, TECHNICAL_GRID)
  protected let m_questUniqueId: String;

  @default(BackDoorObjectiveData, NETWORK)
  @default(ControlPanelObjectiveData, TECHNICAL GRID)
  protected let m_questTitle: String;

  @default(BackDoorObjectiveData, Hack backdoor in order to get access to the network)
  @default(ControlPanelObjectiveData, Gain access to control panel in order to manipulate devices)
  protected let m_objectiveDescription: String;

  private let m_uniqueId: String;

  private let m_ownerID: EntityID;

  private let m_objectiveEntryID: String;

  @default(BackDoorObjectiveData, backdoor)
  @default(ControlPanelObjectiveData, controlPanel)
  private let m_uniqueIdPrefix: String;

  @default(GemplayObjectiveData, gameJournalEntryState.Undefined)
  private persistent let m_objectiveState: gameJournalEntryState;

  public final const func GetObjectiveEntryID() -> String {
    return this.m_objectiveEntryID;
  }

  public final func SetObjectiveEntryID(objectiveEntryID: String) -> Void {
    this.m_objectiveEntryID = objectiveEntryID;
  }

  public final const func GetOwnerID() -> EntityID {
    return this.m_ownerID;
  }

  public final func SetOwnerID(requesterID: EntityID) -> Void {
    this.m_ownerID = requesterID;
  }

  public final const func GetQuestTitle() -> String {
    return this.m_questTitle;
  }

  public final const func GetObjectiveDescription() -> String {
    return this.m_objectiveDescription;
  }

  public final func GetUniqueID() -> String {
    if !IsStringValid(this.m_uniqueId) {
      this.CreateUniqueID(this.m_ownerID);
    };
    return this.m_uniqueId;
  }

  protected final func CreateUniqueID(entityID: EntityID) -> Void {
    if IsStringValid(this.m_questUniqueId) {
      this.m_uniqueId = this.m_questUniqueId;
    } else {
      this.m_uniqueId = this.m_uniqueIdPrefix += EntityID.ToDebugStringDecimal(entityID);
    };
  }

  public final const func IsCreated() -> Bool {
    return NotEquals(this.m_objectiveState, gameJournalEntryState.Undefined);
  }

  public final func SetObjectiveState(state: gameJournalEntryState) -> Void {
    this.m_objectiveState = state;
  }

  public final const func GetObjectiveState() -> gameJournalEntryState {
    return this.m_objectiveState;
  }
}
