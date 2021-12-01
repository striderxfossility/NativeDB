
public class nanowireGrenade extends BaseProjectile {

  private let m_countTime: Float;

  private edit let m_timeToActivation: Float;

  private edit let m_energyLossFactor: Float;

  private edit let m_startVelocity: Float;

  private edit let m_grenadeLifetime: Float;

  private edit let m_gravitySimulation: Float;

  @default(nanowireGrenade, trail)
  private let m_trailEffectName: CName;

  @default(nanowireGrenade, true)
  private let m_alive: Bool;

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.m_projectileComponent.SetEnergyLossFactor(this.m_energyLossFactor, 0.05);
  }

  private final func StartTrailEffect() -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = this.m_trailEffectName;
    this.QueueEvent(spawnEffectEvent);
  }

  private final func Reset() -> Void {
    this.m_countTime = 0.00;
    this.m_alive = true;
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool;

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    if this.m_alive {
      this.Explode(eventData.startPoint);
      this.Release();
      this.m_alive = false;
    };
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool;

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    let evt: ref<gameprojectileShootTargetEvent> = new gameprojectileShootTargetEvent();
    evt.startPoint = eventData.hitInstances[0].position;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, this.m_timeToActivation);
    this.StopMovement();
  }

  private final func Explode(position: Vector4) -> Void {
    let explosionEffect: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVector(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    explosionEffect.Run();
  }

  private final func StopMovement() -> Void {
    this.m_projectileComponent.ClearTrajectories();
  }
}

public class EffectExecutor_NanowireGrenadePull extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    this.PullTarget(EffectExecutionScriptContext.GetTarget(applierCtx) as GameObject, (EffectScriptContext.GetSource(ctx) as GameEntity).GetWorldPosition());
    return true;
  }

  protected final func PullTarget(target: ref<GameObject>, impactPosition: Vector4) -> Void {
    let stimuliEffectEvent: ref<StimuliEffectEvent>;
    if IsDefined(target) {
      stimuliEffectEvent = new StimuliEffectEvent();
      stimuliEffectEvent.stimuliEventName = n"GetOverHere";
      stimuliEffectEvent.targetPoint = impactPosition;
      target.QueueEvent(stimuliEffectEvent);
    };
  }
}
