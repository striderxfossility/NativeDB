
public class piercingGrenade extends BaseProjectile {

  private edit let m_piercingEffect: EffectRef;

  private edit let m_pierceTime: Float;

  private edit let m_energyLossFactor: Float;

  private edit let m_startVelocity: Float;

  private edit let m_grenadeLifetime: Float;

  private edit let m_gravitySimulation: Float;

  @default(piercingGrenade, trail)
  private let m_trailEffectName: CName;

  @default(piercingGrenade, true)
  private let m_alive: Bool;

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.StartTrailEffect();
    this.m_projectileComponent.SetEnergyLossFactor(this.m_energyLossFactor, 0.05);
  }

  private final func StartTrailEffect() -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = this.m_trailEffectName;
    this.QueueEvent(spawnEffectEvent);
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.StartTrailEffect();
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    if this.m_alive {
      this.Explode(eventData.startPoint);
      this.Release();
      this.m_alive = false;
    };
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool;

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    let evt: ref<gameprojectileShootTargetEvent>;
    let hitInstance: gameprojectileHitInstance = eventData.hitInstances[0];
    let target: ref<GameObject> = hitInstance.hitObject as GameObject;
    if IsDefined(target as gamePuppet) {
      this.Pierce(hitInstance.position);
    } else {
      evt = new gameprojectileShootTargetEvent();
      evt.startPoint = hitInstance.position;
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, this.m_pierceTime);
      this.StopMovement();
    };
  }

  private final func Explode(position: Vector4) -> Void {
    let explosionEffect: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVector(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    explosionEffect.Run();
  }

  private final func Pierce(position: Vector4) -> Void {
    let piercingEffect: ref<EffectInstance> = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffect(this.m_piercingEffect, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject(), this);
    EffectData.SetVector(piercingEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    piercingEffect.Run();
  }

  private final func StopMovement() -> Void {
    this.m_projectileComponent.ClearTrajectories();
  }
}
