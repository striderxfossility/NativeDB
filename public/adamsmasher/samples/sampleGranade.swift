
public class sampleGranade extends BaseProjectile {

  private let m_countTime: Float;

  private edit let m_energyLossFactor: Float;

  private edit let m_startVelocity: Float;

  private edit let m_grenadeLifetime: Float;

  private edit let m_gravitySimulation: Float;

  @default(sampleGranade, trail)
  private let m_trailEffectName: CName;

  @default(sampleGranade, true)
  private let m_alive: Bool;

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.m_projectileComponent.SetEnergyLossFactor(this.m_energyLossFactor, this.m_energyLossFactor);
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

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.Reset();
    this.StartTrailEffect();
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    let accel: Vector4;
    let angle: Float;
    let parabolicParams: ref<ParabolicTrajectoryParams>;
    let target: Vector4;
    this.Reset();
    this.m_projectileComponent.ClearTrajectories();
    angle = 45.00;
    accel = new Vector4(0.00, 0.00, -this.m_gravitySimulation, 0.00);
    target = eventData.params.targetPosition;
    parabolicParams = ParabolicTrajectoryParams.GetAccelTargetAngleParabolicParams(accel, target, angle);
    this.m_projectileComponent.AddParabolic(parabolicParams);
    this.StartTrailEffect();
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    let explosion: ref<EffectInstance>;
    this.m_countTime += eventData.deltaTime;
    if this.m_alive {
      if this.m_countTime > this.m_grenadeLifetime {
        explosion = this.m_projectileComponent.GetGameEffectInstance();
        EffectData.SetVector(explosion.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, eventData.position);
        EffectData.SetFloat(explosion.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, 3.00);
        explosion.Run();
        this.PlayExplosionSound();
        this.m_alive = false;
        this.m_countTime = 0.00;
      };
    } else {
      if this.m_countTime > 0.50 {
        this.Release();
      };
    };
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool;

  private final func PlayExplosionSound() -> Void {
    let audioEvent: ref<SoundPlayEvent> = new SoundPlayEvent();
    audioEvent.soundName = n"Play_grenade";
    this.QueueEvent(audioEvent);
  }
}
