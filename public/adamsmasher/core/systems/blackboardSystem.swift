
public class BlackBoardRequestEvent extends Event {

  protected let m_blackBoard: wref<IBlackboard>;

  protected let m_storageClass: gameScriptedBlackboardStorage;

  protected let m_entryTag: CName;

  public final func PassBlackBoardReference(newBlackbord: wref<IBlackboard>, blackBoardName: CName) -> Void {
    this.m_blackBoard = newBlackbord;
    this.m_entryTag = blackBoardName;
  }

  public final func GetBlackboardReference() -> wref<IBlackboard> {
    return this.m_blackBoard;
  }

  public final func SetStorageType(storageType: gameScriptedBlackboardStorage) -> Void {
    this.m_storageClass = storageType;
  }

  public final func GetStorageType() -> gameScriptedBlackboardStorage {
    return this.m_storageClass;
  }

  public final func GetEntryTag() -> CName {
    return this.m_entryTag;
  }
}
