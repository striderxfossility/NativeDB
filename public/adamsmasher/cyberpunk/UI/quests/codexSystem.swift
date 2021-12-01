
public class CodexSystem extends ScriptableSystem {

  private let m_codex: array<SCodexRecord>;

  private let m_blackboard: wref<IBlackboard>;

  private func OnAttach() -> Void {
    this.m_blackboard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_CodexSystem);
    this.codexInit();
  }

  private final func codexInit() -> Void {
    let i: Int32;
    let initialRecords: array<wref<CodexRecord_Record>>;
    let codex: ref<Codex_Record> = TweakDBInterface.GetCodexRecord(t"Codex.PlayerCodex");
    codex.Entries(initialRecords);
    i = 0;
    while i < ArraySize(initialRecords) {
      this.AddCodexRecord(initialRecords[i]);
      i += 1;
    };
  }

  public final const func IsRecordLocked(recordID: TweakDBID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_codex) {
      if this.m_codex[i].RecordID == recordID && !this.m_codex[i].Unlocked {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetCodexRecordPartContent(recordID: TweakDBID, partName: CName) -> String {
    let content: String;
    let i: Int32;
    let rid: Int32 = this.GetCodexRecordIndex(recordID);
    if rid != -1 {
      i = 0;
      while i < ArraySize(this.m_codex[rid].RecordContent) {
        if Equals(this.m_codex[rid].RecordContent[i].PartName, partName) {
          content = this.m_codex[rid].RecordContent[i].PartContent;
        };
        i += 1;
      };
    };
    return content;
  }

  public final const func IsRecordPartLocked(recordID: TweakDBID, partName: CName) -> Bool {
    let j: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_codex) {
      if this.m_codex[i].RecordID == recordID {
        j = 0;
        while j < ArraySize(this.m_codex[i].RecordContent) {
          if Equals(this.m_codex[i].RecordContent[j].PartName, partName) && !this.m_codex[i].RecordContent[j].Unlocked {
            return true;
          };
          j += 1;
        };
      };
      i += 1;
    };
    return false;
  }

  public final const func GetCodex() -> array<SCodexRecord> {
    return this.m_codex;
  }

  public final const func GetCodexRecordParts(recordTweak: TweakDBID) -> array<SCodexRecordPart> {
    let nullRecordContent: array<SCodexRecordPart>;
    let rid: Int32 = this.GetCodexRecordIndex(recordTweak);
    if rid != -1 {
      return this.m_codex[rid].RecordContent;
    };
    return nullRecordContent;
  }

  public final const func GetCodexRecordIndex(recordTweak: TweakDBID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_codex) {
      if this.m_codex[i].RecordID == recordTweak {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func AddCodexRecord(record: ref<CodexRecord_Record>) -> Void {
    let contentRecords: array<wref<CodexRecordPart_Record>>;
    let i: Int32;
    let newCodexEntry: SCodexRecord;
    let newCodexPartEntry: SCodexRecordPart;
    newCodexEntry.RecordID = record.GetID();
    newCodexEntry.Tags = record.Tags();
    record.RecordContent(contentRecords);
    i = 0;
    while i < ArraySize(contentRecords) {
      newCodexPartEntry.PartName = contentRecords[i].PartName();
      newCodexPartEntry.PartContent = contentRecords[i].PartContent();
      newCodexPartEntry.Unlocked = false;
      ArrayPush(newCodexEntry.RecordContent, newCodexPartEntry);
      i += 1;
    };
    if record.UnlockedFromStart() {
      newCodexEntry.Unlocked = true;
    } else {
      newCodexEntry.Unlocked = false;
    };
    ArrayPush(this.m_codex, newCodexEntry);
  }

  private final func UnlockRecord(recordTweak: TweakDBID) -> Void {
    let rid: Int32 = this.GetCodexRecordIndex(recordTweak);
    if rid != -1 {
      this.m_codex[this.GetCodexRecordIndex(recordTweak)].Unlocked = true;
    };
  }

  private final func UnlockCodexPart(recordTweak: TweakDBID, partName: CName) -> Void {
    let i: Int32;
    let rid: Int32 = this.GetCodexRecordIndex(recordTweak);
    if rid != -1 {
      i = 0;
      while i < ArraySize(this.m_codex[rid].RecordContent) {
        if Equals(this.m_codex[rid].RecordContent[i].PartName, partName) {
          this.m_codex[rid].RecordContent[i].Unlocked = true;
        };
        i += 1;
      };
    };
  }

  private final func LockRecord(recordTweak: TweakDBID) -> Void {
    let rid: Int32 = this.GetCodexRecordIndex(recordTweak);
    if rid != -1 {
      this.m_codex[rid].Unlocked = false;
    };
  }

  private final func SendCallback() -> Void {
    this.m_blackboard.SetVariant(GetAllBlackboardDefs().UI_CodexSystem.CodexUpdated, ToVariant(true));
    this.m_blackboard.SignalVariant(GetAllBlackboardDefs().UI_CodexSystem.CodexUpdated);
  }

  private final func OnCodexUnlockRecordRequest(request: ref<CodexUnlockRecordRequest>) -> Void {
    this.UnlockRecord(request.codexRecordID);
    this.SendCallback();
  }

  private final func OnCodexLockRecordRequest(request: ref<CodexLockRecordRequest>) -> Void {
    this.LockRecord(request.codexRecordID);
    this.SendCallback();
  }

  private final func OnAddCodexRecordRequest(request: ref<CodexAddRecordRequest>) -> Void {
    this.AddCodexRecord(TweakDBInterface.GetCodexRecordRecord(request.codexRecordID));
    this.SendCallback();
  }

  private final func OnUnlockCodexPartRequest(request: ref<UnlockCodexPartRequest>) -> Void {
    this.UnlockCodexPart(request.codexRecordID, request.partName);
    this.SendCallback();
  }
}
