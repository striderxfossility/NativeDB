
public class GameSessionDataSystem extends ScriptableSystem {

  private let m_gameSessionDataModules: array<ref<GameSessionDataModule>>;

  private final const func GetModule(dataType: EGameSessionDataType) -> ref<GameSessionDataModule> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_gameSessionDataModules) {
      if Equals(this.m_gameSessionDataModules[i].GetModuleType(), dataType) {
        return this.m_gameSessionDataModules[i];
      };
      i += 1;
    };
    return null;
  }

  private func OnAttach() -> Void {
    this.Initialize();
  }

  private func OnDetach() -> Void {
    this.Uninitialize();
  }

  private final func Initialize() -> Void {
    let cameraTagLimitModule: ref<CameraTagEnemyLimitDataModule>;
    let cameraDeadBodyModule: ref<CameraDeadBodySessionDataModule> = new CameraDeadBodySessionDataModule();
    cameraDeadBodyModule.Initialize();
    ArrayPush(this.m_gameSessionDataModules, cameraDeadBodyModule);
    cameraTagLimitModule = new CameraTagEnemyLimitDataModule();
    cameraTagLimitModule.Initialize();
    ArrayPush(this.m_gameSessionDataModules, cameraTagLimitModule);
  }

  private final func Uninitialize() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_gameSessionDataModules) {
      this.m_gameSessionDataModules[i].Uninitialize();
      i += 1;
    };
  }

  public final static func AddDataEntryRequest(context: GameInstance, dataType: EGameSessionDataType, data: Variant) -> Void {
    let dataEntryRequest: ref<DataEntryRequest>;
    let gameSessionDataSystem: ref<GameSessionDataSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"GameSessionDataSystem") as GameSessionDataSystem;
    if IsDefined(gameSessionDataSystem) {
      dataEntryRequest = new DataEntryRequest();
      dataEntryRequest.dataType = dataType;
      dataEntryRequest.data = data;
      gameSessionDataSystem.QueueRequest(dataEntryRequest);
    };
  }

  private final func OnDataEntryRequest(request: ref<DataEntryRequest>) -> Void {
    if this.IsDataValid(request.dataType, request.data) {
      this.GetModule(request.dataType).AddEntry(request.data);
    };
    if !IsFinal() {
      this.RefreshDebug();
    };
  }

  public final static func CheckDataRequest(context: GameInstance, dataType: EGameSessionDataType, dataHelper: Variant) -> Bool {
    let module: ref<GameSessionDataModule>;
    let gameSessionDataSystem: ref<GameSessionDataSystem> = GameInstance.GetScriptableSystemsContainer(context).Get(n"GameSessionDataSystem") as GameSessionDataSystem;
    if IsDefined(gameSessionDataSystem) {
      module = gameSessionDataSystem.GetModule(dataType);
      if IsDefined(module) {
        return module.CheckData(dataHelper);
      };
      return false;
    };
    return false;
  }

  protected final func IsDataValid(dataType: EGameSessionDataType, data: Variant) -> Bool {
    let module: ref<GameSessionDataModule> = this.GetModule(dataType);
    if IsDefined(module) {
      return module.IsDataValid(data);
    };
    return false;
  }

  private final func RefreshDebug() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_gameSessionDataModules) {
      this.m_gameSessionDataModules[i].RefreshDebug(this.GetGameInstance());
      i += 1;
    };
  }
}

public class GameSessionDataModule extends IScriptable {

  protected let m_moduleType: EGameSessionDataType;

  public func Initialize() -> Void;

  public func Uninitialize() -> Void;

  public final const func GetModuleType() -> EGameSessionDataType {
    return this.m_moduleType;
  }

  public const func IsDataValid(data: Variant) -> Bool {
    return false;
  }

  public func AddEntry(data: Variant) -> Void;

  public const func CheckData(data: Variant) -> Bool {
    return false;
  }

  public func RefreshDebug(context: GameInstance) -> Void;
}

public class CameraDeadBodySessionDataModule extends GameSessionDataModule {

  public let m_cameraDeadBodyData: array<ref<CameraDeadBodyInternalData>>;

  public func Initialize() -> Void {
    this.m_moduleType = EGameSessionDataType.CameraDeadBody;
  }

  public const func IsDataValid(data: Variant) -> Bool {
    let castedData: ref<CameraDeadBodyData> = FromVariant(data);
    if !IsDefined(castedData) {
      return false;
    };
    if EntityID.IsDefined(castedData.ownerID) && EntityID.IsDefined(castedData.bodyID) {
      return true;
    };
    return false;
  }

  public func AddEntry(data: Variant) -> Void {
    let i: Int32;
    let newEntry: ref<CameraDeadBodyInternalData>;
    let castedData: ref<CameraDeadBodyData> = FromVariant(data);
    if !IsDefined(castedData) {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_cameraDeadBodyData) {
      if this.m_cameraDeadBodyData[i].m_ownerID == castedData.ownerID {
        this.m_cameraDeadBodyData[i].AddEntry(castedData.bodyID);
        return;
      };
      i += 1;
    };
    newEntry = new CameraDeadBodyInternalData();
    newEntry.m_ownerID = castedData.ownerID;
    newEntry.AddEntry(castedData.bodyID);
    ArrayPush(this.m_cameraDeadBodyData, newEntry);
  }

  public const func CheckData(data: Variant) -> Bool {
    let castedData: ref<CameraDeadBodyData> = FromVariant(data);
    let i: Int32 = 0;
    while i < ArraySize(this.m_cameraDeadBodyData) {
      if this.m_cameraDeadBodyData[i].m_ownerID == castedData.ownerID {
        return this.m_cameraDeadBodyData[i].ContainsEntry(castedData.bodyID);
      };
      i += 1;
    };
    return false;
  }

  public func RefreshDebug(context: GameInstance) -> Void {
    let i: Int32;
    let i1: Int32;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(context).CreateSink();
    SDOSink.SetRoot(sink, "GameSessionData/CameraDeadBody");
    i = 0;
    while i < ArraySize(this.m_cameraDeadBodyData) {
      i1 = 0;
      while i1 < ArraySize(this.m_cameraDeadBodyData[i].m_bodyIDs) {
        SDOSink.PushString(sink, EntityID.ToDebugString(this.m_cameraDeadBodyData[i].m_ownerID) + "/" + i1, EntityID.ToDebugString(this.m_cameraDeadBodyData[i].m_bodyIDs[i1]));
        i1 += 1;
      };
      i += 1;
    };
  }
}

public class CameraDeadBodyInternalData extends IScriptable {

  public let m_ownerID: EntityID;

  public let m_bodyIDs: array<EntityID>;

  public final func AddEntry(entryID: EntityID) -> Void {
    if !ArrayContains(this.m_bodyIDs, entryID) {
      ArrayPush(this.m_bodyIDs, entryID);
    };
  }

  public final func ContainsEntry(entryID: EntityID) -> Bool {
    return ArrayContains(this.m_bodyIDs, entryID);
  }
}

public class CameraTagEnemyLimitDataModule extends GameSessionDataModule {

  @default(CameraTagEnemyLimitDataModule, 5)
  public let m_cameraLimit: Int32;

  public let m_cameraList: array<wref<SurveillanceCamera>>;

  public func Initialize() -> Void {
    this.m_moduleType = EGameSessionDataType.CameraTagLimit;
  }

  public func Uninitialize() -> Void;

  public const func IsDataValid(data: Variant) -> Bool {
    let castedData: ref<CameraTagLimitData> = FromVariant(data);
    if !IsDefined(castedData) {
      return false;
    };
    if IsDefined(castedData.object) {
      return true;
    };
    return false;
  }

  public func AddEntry(data: Variant) -> Void {
    let castedData: ref<CameraTagLimitData> = FromVariant(data);
    this.CleanupNulls();
    if castedData.add {
      if !ArrayContains(this.m_cameraList, castedData.object) {
        if ArraySize(this.m_cameraList) == this.m_cameraLimit {
          this.SendCameraTagLockEvent(0);
          ArrayErase(this.m_cameraList, 0);
        };
        ArrayPush(this.m_cameraList, castedData.object);
      };
    } else {
      if ArrayRemove(this.m_cameraList, castedData.object) {
      };
    };
  }

  private final func CleanupNulls() -> Void {
    let i: Int32 = ArraySize(this.m_cameraList) - 1;
    while i >= 0 {
      if this.m_cameraList[i] == null {
        ArrayErase(this.m_cameraList, i);
      };
      i -= 1;
    };
  }

  private final func SendCameraTagLockEvent(index: Int32) -> Void {
    let evt: ref<CameraTagLockEvent> = new CameraTagLockEvent();
    evt.isLocked = true;
    this.m_cameraList[index].QueueEvent(evt);
  }

  public const func CheckData(data: Variant) -> Bool {
    if IsDefined(FromVariant(data)) {
      return ArrayContains(this.m_cameraList, FromVariant(data));
    };
    return false;
  }

  public func RefreshDebug(context: GameInstance) -> Void {
    let i: Int32;
    let sink: SDOSink = GameInstance.GetScriptsDebugOverlaySystem(context).CreateSink();
    SDOSink.SetRoot(sink, "GameSessionData/CameraTagLimit");
    SDOSink.PushInt32(sink, "Limit", this.m_cameraLimit);
    i = 0;
    while i < this.m_cameraLimit {
      if i < ArraySize(this.m_cameraList) {
        SDOSink.PushString(sink, "-" + i, EntityID.ToDebugString(this.m_cameraList[i].GetEntityID()));
      } else {
        SDOSink.PushString(sink, "-" + i, "NONE");
      };
      i += 1;
    };
  }
}
