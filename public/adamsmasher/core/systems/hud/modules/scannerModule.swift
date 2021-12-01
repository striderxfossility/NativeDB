
public class ScannerModule extends HUDModule {

  private let m_activeScans: array<ref<ScanInstance>>;

  private final func InitiateFreshScan() -> Void;

  protected func Process(out task: HUDJob, mode: ActiveMode) -> Void {
    let instruction: ref<ScanInstance>;
    let isScanningCluesBlocked: Bool;
    let lockedClueID: EntityID;
    if IsDefined(task.actor) && task.actor.IsClue() {
      lockedClueID = this.m_hud.GetLockedClueID();
      if EntityID.IsDefined(lockedClueID) && lockedClueID != task.actor.GetEntityID() {
        isScanningCluesBlocked = true;
      };
    };
    instruction = task.instruction.scannerInstructions;
    if IsDefined(instruction) && IsDefined(task.actor) {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(this.IsActorLookedAt(task.actor), task.actor.IsRevealed(), isScanningCluesBlocked);
    };
  }

  protected func Process(out jobs: array<HUDJob>, mode: ActiveMode) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      this.Process(jobs[i], mode);
      i += 1;
    };
  }

  public func Suppress(out jobs: array<HUDJob>) -> Void {
    let instruction: ref<ScanInstance>;
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      instruction = jobs[i].instruction.scannerInstructions;
      instruction.SetState(InstanceState.DISABLED, this.DuplicateLastInstance(jobs[i].actor));
      instruction.SetContext(false, false, false);
      i += 1;
    };
  }

  protected func DuplicateLastInstance(actor: ref<HUDActor>) -> ref<ModuleInstance> {
    return this.DuplicateLastInstance(actor);
  }
}

public class ScanInstance extends ModuleInstance {

  public let isScanningCluesBlocked: Bool;

  public final func SetContext(_isLookedAt: Bool, _isRevealed: Bool, _isScanningCluesBlocked: Bool) -> Void {
    this.isLookedAt = _isLookedAt;
    this.isRevealed = _isRevealed;
    this.isScanningCluesBlocked = _isScanningCluesBlocked;
  }
}
