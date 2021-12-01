
public static exec func SpawnEffect(gameInstance: GameInstance, effectName: CName) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
  ev.effectName = effectName;
  ev.effectInstanceName = n"_ExecSpawnEffect";
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gameInstance).GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
  if IsDefined(target) {
    target.QueueEvent(ev);
  };
}

public static exec func KillEffect(gameInstance: GameInstance) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<entKillEffectEvent> = new entKillEffectEvent();
  ev.effectName = n"_ExecSpawnEffect";
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gameInstance).GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
  if IsDefined(target) {
    target.QueueEvent(ev);
  };
}

public static exec func BreakEffectLoop(gameInstance: GameInstance) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
  ev.effectName = n"_ExecSpawnEffect";
  let target: ref<GameObject> = GameInstance.GetTargetingSystem(gameInstance).GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
  if IsDefined(target) {
    target.QueueEvent(ev);
  };
}
