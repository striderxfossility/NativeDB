
public class WorkspotFunctionalTestsDebugListener extends IScriptable {

  private let m_entityId: EntityID;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_instancesCreated: Int32;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_instancesRemoved: Int32;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_workspotsSetup: Int32;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_workspotsStarted: Int32;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_workspotsFinished: Int32;

  private let m_animationsStack: array<String>;

  private let m_animationsSkippedStack: array<String>;

  private let m_animationsMissingStack: array<String>;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_skipOverflows: Int32;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_teleportRequests: Int32;

  @default(WorkspotFunctionalTestsDebugListener, 0)
  private let m_movementRequests: Int32;

  public final func GetEntityID() -> EntityID {
    return this.m_entityId;
  }

  public final func SetEntityID(entID: EntityID) -> Void {
    this.m_entityId = entID;
  }

  public final func GetInstancesCreatedCount() -> Int32 {
    return this.m_instancesCreated;
  }

  public final func GetInstancesRemovedCount() -> Int32 {
    return this.m_instancesRemoved;
  }

  public final func GetWorkspotsSetupCount() -> Int32 {
    return this.m_workspotsSetup;
  }

  public final func GetWorkspotsStartedCount() -> Int32 {
    if this.m_workspotsStarted == 0 && GameInstance.GetWorkspotSystem(GetGameInstance()).IsActorInWorkspot(GameInstance.FindEntityByID(GetGameInstance(), this.m_entityId) as GameObject) {
      this.m_workspotsStarted += 1;
    };
    return this.m_workspotsStarted;
  }

  public final func GetWorkspotsFinishedCount() -> Int32 {
    return this.m_workspotsFinished;
  }

  public final func GetAnimationStack() -> array<String> {
    return this.m_animationsStack;
  }

  public final func GetLastPlayedAnimation() -> String {
    return ArrayLast(this.m_animationsStack);
  }

  public final func GetAnimationPlayCount(animationName: String) -> Int32 {
    let count: Int32 = 0;
    let i: Int32 = 0;
    while i < ArraySize(this.m_animationsStack) {
      if Equals(this.m_animationsStack[i], animationName) {
        count += 1;
      };
      i += 1;
    };
    return count;
  }

  public final func GetSkippedAnimationStack() -> array<String> {
    return this.m_animationsSkippedStack;
  }

  public final func GetLastSkippedAnimation() -> String {
    return ArrayLast(this.m_animationsSkippedStack);
  }

  public final func GetMissingAnimationStack() -> array<String> {
    return this.m_animationsMissingStack;
  }

  public final func GetLastMissingAnimation() -> String {
    return ArrayLast(this.m_animationsMissingStack);
  }

  public final func GetSkipOverflowsCount() -> Int32 {
    return this.m_skipOverflows;
  }

  public final func GetTeleportRequestsCount() -> Int32 {
    return this.m_teleportRequests;
  }

  public final func GetMovementRequestsCount() -> Int32 {
    return this.m_movementRequests;
  }

  protected cb func OnInstanceCreated() -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnInstanceCreated] EntityID: " + EntityID.ToDebugString(this.m_entityId));
    this.m_instancesCreated += 1;
  }

  protected cb func OnInstanceRemoved() -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnInstanceRemoved] EntityID: " + EntityID.ToDebugString(this.m_entityId));
    this.m_instancesRemoved += 1;
  }

  protected cb func OnWorkspotSetup(path: String) -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnWorkspotSetup] EntityID: " + EntityID.ToDebugString(this.m_entityId) + " path: " + path);
    this.m_workspotsSetup += 1;
  }

  protected cb func OnWorkspotStarted() -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnWorkspotStarted] EntityID: " + EntityID.ToDebugString(this.m_entityId));
    this.m_workspotsStarted += 1;
  }

  protected cb func OnWorkspotFinished() -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnWorkspotFinished] EntityID: " + EntityID.ToDebugString(this.m_entityId));
    this.m_workspotsFinished += 1;
  }

  protected cb func OnAnimationChanged(animName: CName, workEntryID: WorkEntryId) -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnAnimationChanged] EntityID: " + EntityID.ToDebugString(this.m_entityId) + " animName: " + NameToString(animName));
    ArrayPush(this.m_animationsStack, NameToString(animName));
  }

  protected cb func OnAnimationSkipped(animName: CName, workEntryID: WorkEntryId) -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnAnimationSkipped] EntityID: " + EntityID.ToDebugString(this.m_entityId) + " animName: " + NameToString(animName));
    ArrayPush(this.m_animationsSkippedStack, NameToString(animName));
  }

  protected cb func OnAnimationMissing(animName: CName, workEntryID: WorkEntryId) -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnAnimationMissing] EntityID: " + EntityID.ToDebugString(this.m_entityId) + " animName: " + NameToString(animName));
    ArrayPush(this.m_animationsMissingStack, NameToString(animName));
  }

  protected cb func OnSkipOverflow() -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnSkipOverflow] EntityID: " + EntityID.ToDebugString(this.m_entityId));
    this.m_skipOverflows += 1;
  }

  protected cb func OnTeleportRequest() -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnTeleportRequest] EntityID: " + EntityID.ToDebugString(this.m_entityId));
    this.m_teleportRequests += 1;
  }

  protected cb func OnMovementRequest() -> Bool {
    FTLog("[WorkspotFunctionalTestsDebugListener:OnMovementRequest] EntityID: " + EntityID.ToDebugString(this.m_entityId));
    this.m_movementRequests += 1;
  }
}
