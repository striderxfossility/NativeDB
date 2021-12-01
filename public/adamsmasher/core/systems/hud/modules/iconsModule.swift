
public class IconsModule extends HUDModule {

  protected func Process(out task: HUDJob, mode: ActiveMode) -> Void {
    let instruction: ref<IconsInstance> = task.instruction.iconsInstruction;
    if !task.actor.IsGrouppedClue() && (Equals(mode, ActiveMode.FOCUS) || this.m_hud.IsPulseActive() || task.actor.IsRevealed() || task.actor.IsTagged()) {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(this.IsActorLookedAt(task.actor), task.actor.IsRevealed(), task.actor.IsIconForcedVisibileThroughWalls());
      return;
    };
    if this.ShouldDisplayBodyDisposal(task.actor) {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(this.IsActorLookedAt(task.actor), task.actor.IsRevealed(), task.actor.IsIconForcedVisibileThroughWalls());
      return;
    };
    if Equals(mode, ActiveMode.SEMI) && task.actor.IsInIconForcedVisibilityRange() {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(this.IsActorLookedAt(task.actor), task.actor.IsRevealed(), task.actor.IsIconForcedVisibileThroughWalls());
      return;
    };
    if this.IsActorLookedAt(task.actor) && (NotEquals(task.actor.GetType(), HUDActorType.DEVICE) && NotEquals(task.actor.GetType(), HUDActorType.BODY_DISPOSAL_DEVICE) || task.actor.IsClue()) {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(this.IsActorLookedAt(task.actor), task.actor.IsRevealed(), task.actor.IsIconForcedVisibileThroughWalls());
      return;
    };
    instruction.SetState(InstanceState.DISABLED, this.DuplicateLastInstance(task.actor));
    instruction.SetContext(this.IsActorLookedAt(task.actor), task.actor.IsRevealed(), task.actor.IsIconForcedVisibileThroughWalls());
    return;
  }

  protected final func ShouldDisplayBodyDisposal(actor: ref<HUDActor>) -> Bool {
    if Equals(actor.GetType(), HUDActorType.BODY_DISPOSAL_DEVICE) {
      if this.IsPlayerCarrying() || this.IsEnemyGrappled() {
        return true;
      };
    };
    return false;
  }

  private final const func IsPlayerCarrying() -> Bool {
    return this.m_hud.GetPlayerSMBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
  }

  private final const func IsEnemyGrappled() -> Bool {
    return this.m_hud.GetPlayerSMBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Grapple);
  }

  protected func Process(out jobs: array<HUDJob>, mode: ActiveMode) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      this.Process(jobs[i], mode);
      i += 1;
    };
  }

  public func Suppress(out jobs: array<HUDJob>) -> Void {
    let instruction: ref<IconsInstance>;
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      instruction = jobs[i].instruction.iconsInstruction;
      instruction.SetState(InstanceState.DISABLED, this.DuplicateLastInstance(jobs[i].actor));
      instruction.SetContext(false, false, false);
      i += 1;
    };
  }

  protected func DuplicateLastInstance(actor: ref<HUDActor>) -> ref<ModuleInstance> {
    return this.DuplicateLastInstance(actor);
  }
}

public class IconsInstance extends ModuleInstance {

  public let isForcedVisibleThroughWalls: Bool;

  public final func SetContext(_isLookedAt: Bool, _isRevealed: Bool, _isForcedVisibleThroughWalls: Bool) -> Void {
    this.isForcedVisibleThroughWalls = _isForcedVisibleThroughWalls;
    this.isRevealed = _isRevealed;
    this.isLookedAt = _isLookedAt;
  }
}
