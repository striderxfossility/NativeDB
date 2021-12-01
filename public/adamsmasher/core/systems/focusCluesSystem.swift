
public class FocusCluesSystem extends ScriptableSystem {

  private persistent let m_linkedClues: array<LinkedFocusClueData>;

  private persistent let m_disabledGroupes: array<CName>;

  private let m_activeLinkedClue: LinkedFocusClueData;

  private final func EnableGroup(groupID: CName) -> Void {
    ArrayRemove(this.m_disabledGroupes, groupID);
  }

  private final func DisableGroup(groupID: CName) -> Void {
    if !ArrayContains(this.m_disabledGroupes, groupID) {
      ArrayPush(this.m_disabledGroupes, groupID);
    };
  }

  private final func AddLinkedClue(clue: LinkedFocusClueData) -> Void {
    ArrayPush(this.m_linkedClues, clue);
  }

  private final func RemoveLinkedClue(clue: LinkedFocusClueData) -> Void {
    let i: Int32 = ArraySize(this.m_linkedClues) - 1;
    while i >= 0 {
      if clue.ownerID == this.m_linkedClues[i].ownerID && Equals(clue.clueGroupID, this.m_linkedClues[i].clueGroupID) {
        ArrayErase(this.m_linkedClues, i);
        i -= 1;
      };
      i -= 1;
    };
  }

  private final func RemoveLinkedClueByIndex(clueID: Int32) -> Void {
    if clueID >= ArraySize(this.m_linkedClues) || clueID < 0 {
      return;
    };
    ArrayErase(this.m_linkedClues, clueID);
  }

  private final func HasLinkedClue(clue: LinkedFocusClueData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_linkedClues) {
      if clue.ownerID == this.m_linkedClues[i].ownerID && Equals(clue.clueGroupID, this.m_linkedClues[i].clueGroupID) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func GetLinkedClueGroupData(groupID: CName, out clue: LinkedFocusClueData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_linkedClues) {
      if Equals(groupID, this.m_linkedClues[i].clueGroupID) {
        clue = this.m_linkedClues[i];
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsRegistered(ownerID: EntityID, groupID: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_linkedClues) {
      if this.m_linkedClues[i].ownerID == ownerID && Equals(groupID, this.m_linkedClues[i].clueGroupID) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsGroupped(ownerID: EntityID, out groupID: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_linkedClues) {
      if this.m_linkedClues[i].ownerID == ownerID {
        groupID = this.m_linkedClues[i].clueGroupID;
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsGroupDisabled(groupID: CName) -> Bool {
    return ArrayContains(this.m_disabledGroupes, groupID);
  }

  public final const func GetClueGroupData(groupID: CName, out clue: FocusClueDefinition) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_linkedClues) {
      if Equals(groupID, this.m_linkedClues[i].clueGroupID) {
        clue.isEnabled = this.m_linkedClues[i].isEnabled;
        clue.wasInspected = this.m_linkedClues[i].wasInspected;
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsGroupTagged(clue: LinkedFocusClueData) -> Bool {
    let clueObject: ref<GameObject>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_linkedClues) {
      if Equals(clue.clueGroupID, this.m_linkedClues[i].clueGroupID) {
        clueObject = GameInstance.FindEntityByID(this.GetGameInstance(), this.m_linkedClues[i].ownerID) as GameObject;
        if this.IsTagged(clueObject) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  private final const func IsTagged(owner: ref<GameObject>) -> Bool {
    if owner != null {
      return GameInstance.GetVisionModeSystem(owner.GetGame()).GetScanningController().IsTagged(owner);
    };
    return false;
  }

  private final func UpdateLinkedClues(clue: LinkedFocusClueData) -> Void {
    let currentClue: LinkedFocusClueData;
    let disableGroup: Bool;
    this.m_activeLinkedClue = clue;
    let i: Int32 = ArraySize(this.m_linkedClues) - 1;
    while i >= 0 {
      currentClue = this.m_linkedClues[i];
      if Equals(clue.clueGroupID, currentClue.clueGroupID) {
        currentClue.wasInspected = clue.wasInspected;
        currentClue.isScanned = clue.isScanned;
        currentClue.isEnabled = clue.isEnabled;
        if this.m_linkedClues[i].ownerID != clue.ownerID {
          if NotEquals(this.m_linkedClues[i].wasInspected, currentClue.wasInspected) || NotEquals(this.m_linkedClues[i].isScanned, currentClue.isScanned) || NotEquals(this.m_linkedClues[i].isEnabled, currentClue.isEnabled) {
            this.SendlinkedClueUpdateEvent(currentClue, clue.ownerID);
          };
        };
        this.m_linkedClues[i] = currentClue;
        if !this.m_linkedClues[i].isEnabled && this.m_linkedClues[i].wasInspected {
          ArrayErase(this.m_linkedClues, i);
          disableGroup = true;
        } else {
          disableGroup = false;
        };
      };
      i -= 1;
    };
    if disableGroup {
      this.DisableGroup(clue.clueGroupID);
    } else {
      this.EnableGroup(clue.clueGroupID);
    };
  }

  private final func UpdateSingleLinkedClue(clue: LinkedFocusClueData) -> Void {
    let currentClue: LinkedFocusClueData;
    if this.GetLinkedClueGroupData(clue.clueGroupID, currentClue) {
      if NotEquals(clue.wasInspected, currentClue.wasInspected) || NotEquals(clue.isScanned, currentClue.isScanned) || NotEquals(clue.isEnabled, currentClue.isEnabled) {
        clue.wasInspected = currentClue.wasInspected;
        clue.isScanned = currentClue.isScanned;
        clue.isEnabled = currentClue.isEnabled;
        this.SendlinkedClueUpdateEvent(clue, clue.ownerID);
      };
    } else {
      this.EnableGroup(clue.clueGroupID);
    };
  }

  private final func SendlinkedClueUpdateEvent(linkedClue: LinkedFocusClueData, requester: EntityID) -> Void {
    let clueEvent: ref<linkedClueUpdateEvent>;
    if !EntityID.IsDefined(linkedClue.ownerID) {
      return;
    };
    clueEvent = new linkedClueUpdateEvent();
    clueEvent.linkedCluekData = linkedClue;
    clueEvent.requesterID = requester;
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(linkedClue.psData.id, linkedClue.psData.className, clueEvent);
  }

  private final func ResolveLinkedCluesTagging(clue: LinkedFocusClueData, tag: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_linkedClues) {
      if Equals(clue.clueGroupID, this.m_linkedClues[i].clueGroupID) {
        if this.m_linkedClues[i].ownerID != clue.ownerID {
          this.SendlinkedClueTagEvent(this.m_linkedClues[i], clue.ownerID, tag);
        };
      };
      i += 1;
    };
  }

  private final func SendlinkedClueTagEvent(linkedClue: LinkedFocusClueData, requester: EntityID, tag: Bool) -> Void {
    let clueEvent: ref<linkedClueTagEvent> = new linkedClueTagEvent();
    clueEvent.requesterID = requester;
    clueEvent.tag = tag;
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(linkedClue.ownerID, clueEvent);
  }

  private final func OnTagLinkedClueRequest(request: ref<TagLinkedCluekRequest>) -> Void {
    this.ResolveLinkedCluesTagging(request.linkedCluekData, request.tag);
  }

  private final func OnRegisterLinkedClueRequest(request: ref<RegisterLinkedCluekRequest>) -> Void {
    if !this.HasLinkedClue(request.linkedCluekData) {
      this.AddLinkedClue(request.linkedCluekData);
      this.UpdateSingleLinkedClue(request.linkedCluekData);
      if this.IsGroupTagged(request.linkedCluekData) {
        this.SendlinkedClueTagEvent(request.linkedCluekData, request.linkedCluekData.ownerID, true);
      };
    };
  }

  private final func OnUnregisterLinkedClueRequest(request: ref<UnregisterLinkedCluekRequest>) -> Void {
    this.RemoveLinkedClue(request.linkedCluekData);
  }

  private final func OnUpdateLinkedCluesRequest(request: ref<UpdateLinkedClueskRequest>) -> Void {
    this.UpdateLinkedClues(request.linkedCluekData);
  }

  public final const func GetActiveLinkedClue() -> LinkedFocusClueData {
    return this.m_activeLinkedClue;
  }

  public final const func GetActiveLinkedClueScannableData() -> array<ScanningTooltipElementDef> {
    let arr: array<ScanningTooltipElementDef>;
    let objectData: ScanningTooltipElementDef;
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeLinkedClue.extendedClueRecords) {
      objectData.recordID = this.m_activeLinkedClue.extendedClueRecords[i].clueRecord;
      objectData.timePct = this.m_activeLinkedClue.extendedClueRecords[i].percentage;
      if TDBID.IsValid(objectData.recordID) {
        ArrayPush(arr, objectData);
      };
      i += 1;
    };
    if this.m_activeLinkedClue.isScanned && TDBID.IsValid(this.m_activeLinkedClue.clueRecord) {
      objectData.recordID = this.m_activeLinkedClue.clueRecord;
      objectData.timePct = 0.00;
      ArrayPush(arr, objectData);
    };
    return arr;
  }
}
