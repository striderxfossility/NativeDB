
public class BraindanceModule extends HUDModule {

  protected func Process(out task: HUDJob, mode: ActiveMode) -> Void {
    let instruction: ref<BraindanceInstance> = task.instruction.braindanceInstructions;
    if !IsDefined(instruction) {
      return;
    };
    if this.m_hud.IsBraindanceActive() {
      instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
    } else {
      instruction.SetState(InstanceState.DISABLED, this.DuplicateLastInstance(task.actor));
    };
  }

  protected func DuplicateLastInstance(actor: ref<HUDActor>) -> ref<ModuleInstance> {
    return this.DuplicateLastInstance(actor);
  }

  protected func Process(out jobs: array<HUDJob>, mode: ActiveMode) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      this.Process(jobs[i], mode);
      i += 1;
    };
  }
}
