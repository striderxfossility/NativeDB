
public abstract class HUDModule extends IScriptable {

  protected let m_hud: wref<HUDManager>;

  protected let m_state: ModuleState;

  protected let m_instancesList: array<ref<ModuleInstance>>;

  public final const func GetState() -> ModuleState {
    return this.m_state;
  }

  public const func IsModuleOperational() -> Bool {
    return Equals(this.m_state, ModuleState.ON) || Equals(this.m_state, ModuleState.MALFUNCTIONING);
  }

  public final func InitializeModule(hud: wref<HUDManager>, state: ModuleState) -> Void {
    if !IsDefined(hud) {
      return;
    };
    this.m_hud = hud;
    this.m_state = state;
  }

  public func UnregisterActor(actor: ref<HUDActor>) -> Void {
    let i: Int32;
    if !IsDefined(actor) {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_instancesList) {
      if this.m_instancesList[i].GetEntityID() == actor.GetEntityID() {
        ArrayErase(this.m_instancesList, i);
        return;
      };
      i += 1;
    };
  }

  protected final func OverrideInstance(index: Int32, instance: ref<ModuleInstance>) -> Void {
    if this.IsIndexOK(index) {
      this.m_instancesList[index] = instance;
    };
  }

  protected func DuplicateLastInstance(actor: ref<HUDActor>) -> ref<ModuleInstance> {
    let i: Int32;
    let instanceDuplicate: ref<ModuleInstance>;
    return null;
  }

  protected final func IsIndexOK(index: Int32) -> Bool {
    if index < 0 || index > ArraySize(this.m_instancesList) - 1 {
      return false;
    };
    return true;
  }

  public final func Iterate(out jobs: array<HUDJob>, opt forcedMode: ActiveMode) -> Void {
    if this.IsModuleOperational() {
      if Equals(forcedMode, ActiveMode.UNINITIALIZED) {
        forcedMode = this.GetActiveMode();
      };
      this.Process(jobs, forcedMode);
    };
  }

  public final func Iterate(out job: HUDJob, opt forcedMode: ActiveMode) -> Void {
    if this.IsModuleOperational() {
      if Equals(forcedMode, ActiveMode.UNINITIALIZED) {
        forcedMode = this.GetActiveMode();
      };
      this.Process(job, forcedMode);
    };
  }

  public func Suppress(out jobs: array<HUDJob>) -> Void;

  protected func Process(out jobs: array<HUDJob>, mode: ActiveMode) -> Void;

  protected func Process(out task: HUDJob, mode: ActiveMode) -> Void;

  protected final const func GetPlayer() -> ref<GameObject> {
    return this.m_hud.GetPlayer();
  }

  protected func GetActiveMode() -> ActiveMode {
    return this.m_hud.GetActiveMode();
  }

  protected final const func IsActorLookedAt(actor: ref<HUDActor>) -> Bool {
    return this.m_hud.GetCurrentTarget() == actor;
  }

  protected final const func IsActorQuickHackTarget(actor: ref<HUDActor>) -> Bool {
    return this.m_hud.GetQuickHackTargetID() == actor.GetEntityID();
  }

  protected final const func HasCurrentTarget() -> Bool {
    return this.m_hud.HasCurrentTarget();
  }

  protected final const func IsActorLooted(actor: ref<HUDActor>) -> Bool {
    return this.m_hud.GetLootedTargetID() == actor.GetEntityID();
  }
}

public class ModuleInstance extends IScriptable {

  public let isLookedAt: Bool;

  public let isRevealed: Bool;

  public let wasProcessed: Bool;

  protected let entityID: EntityID;

  protected let state: InstanceState;

  protected let previousInstance: ref<ModuleInstance>;

  public final func SetContext(_isLookedAt: Bool, _isRevealed: Bool) -> Void {
    this.isLookedAt = _isLookedAt;
    this.isRevealed = _isRevealed;
  }

  public final static func Construct(self: ref<ModuleInstance>, id: EntityID) -> Void {
    if EntityID.IsDefined(id) {
      self.entityID = id;
      self.wasProcessed = false;
    };
  }

  public final const func GetEntityID() -> EntityID {
    return this.entityID;
  }

  public final const func GetState() -> InstanceState {
    return this.state;
  }

  public final const func IsLookedAt() -> Bool {
    return this.isLookedAt;
  }

  public final const func IsRevealed() -> Bool {
    return this.isRevealed;
  }

  public final const func WasProcessed() -> Bool {
    return this.wasProcessed;
  }

  public func SetState(newState: InstanceState, _previousInstance: ref<ModuleInstance>) -> Void {
    this.state = newState;
    this.previousInstance = _previousInstance;
    this.wasProcessed = true;
  }
}
