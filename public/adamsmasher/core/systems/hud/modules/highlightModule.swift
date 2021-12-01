
public class HighlightModule extends HUDModule {

  protected func Process(out task: HUDJob, mode: ActiveMode) -> Void {
    let instruction: ref<HighlightInstance>;
    if !IsDefined(task.actor) {
      return;
    };
    instruction = task.instruction.highlightInstructions;
    if Equals(mode, ActiveMode.FOCUS) {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      if task.actor.IsRevealed() {
        instruction.SetContext(HighlightContext.FULL, this.IsActorLookedAt(task.actor), task.actor.IsRevealed());
        return;
      };
      if this.IsActorLookedAt(task.actor) {
        instruction.SetContext(HighlightContext.FULL, true, task.actor.IsRevealed());
        return;
      };
      instruction.SetContext(HighlightContext.FILL, this.IsActorLookedAt(task.actor), task.actor.IsRevealed());
      return;
    };
    if task.actor.IsRevealed() {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      if Equals(mode, ActiveMode.FOCUS) {
        instruction.SetContext(HighlightContext.FULL, this.IsActorLookedAt(task.actor), task.actor.IsRevealed());
        return;
      };
      instruction.SetContext(HighlightContext.FULL, this.IsActorLookedAt(task.actor), task.actor.IsRevealed());
      return;
    };
    if this.m_hud.IsPulseActive() {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(HighlightContext.FILL, this.IsActorLookedAt(task.actor), task.actor.IsRevealed());
      return;
    };
    if this.IsActorLooted(task.actor) {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(HighlightContext.OUTLINE, this.IsActorLookedAt(task.actor), task.actor.IsRevealed());
      return;
    };
    if this.IsActorLookedAt(task.actor) {
      instruction.SetState(InstanceState.HIDDEN, this.DuplicateLastInstance(task.actor));
      instruction.SetContext(HighlightContext.DEFAULT, this.IsActorLookedAt(task.actor), task.actor.IsRevealed());
      return;
    };
    instruction.SetState(InstanceState.DISABLED, this.DuplicateLastInstance(task.actor));
    instruction.SetContext(HighlightContext.DEFAULT, false, task.actor.IsRevealed());
    return;
  }

  protected func Process(out jobs: array<HUDJob>, mode: ActiveMode) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      this.Process(jobs[i], mode);
      i += 1;
    };
  }

  public func Suppress(out jobs: array<HUDJob>) -> Void {
    let instruction: ref<HighlightInstance>;
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      instruction = jobs[i].instruction.highlightInstructions;
      instruction.SetState(InstanceState.DISABLED, this.DuplicateLastInstance(jobs[i].actor));
      instruction.SetContext(HighlightContext.DEFAULT, false, false);
      i += 1;
    };
  }

  protected func DuplicateLastInstance(actor: ref<HUDActor>) -> ref<ModuleInstance> {
    return this.DuplicateLastInstance(actor);
  }
}

public class HighlightInstance extends ModuleInstance {

  public let context: HighlightContext;

  public let instant: Bool;

  public final func SetContext(newContext: HighlightContext, _isLookedAt: Bool, _isRevealed: Bool, opt _instant: Bool) -> Void {
    this.context = newContext;
    this.isLookedAt = _isLookedAt;
    this.isRevealed = _isRevealed;
    this.instant = _instant;
  }

  public final const func IsInstant() -> Bool {
    return this.instant;
  }

  public final const func GetContext() -> HighlightContext {
    return this.context;
  }
}
