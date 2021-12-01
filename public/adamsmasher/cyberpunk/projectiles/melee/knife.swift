
public class Knife extends BaseProjectile {

  @default(Knife, false)
  public let m_collided: Bool;

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    super.OnProjectileInitialize(eventData);
    this.m_projectileComponent.SetCollisionEvaluator(new KnifeCollisionEvaluator());
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    let gravitySimulation: Float = this.GetProjectileTweakDBFloatParameter("gravitySimulation");
    let startVelocity: Float = this.GetProjectileTweakDBFloatParameter("startVelocity");
    let energyLossFactorAfterCollision: Float = this.GetProjectileTweakDBFloatParameter("energyLossFactorAfterCollision");
    this.GeneralLaunchSetup(eventData);
    this.ParabolicLaunch(eventData, gravitySimulation, startVelocity, energyLossFactorAfterCollision);
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    let hitInstance: gameprojectileHitInstance;
    let isObjectNPC: Bool;
    super.OnCollision(eventData);
    hitInstance = eventData.hitInstances[0];
    isObjectNPC = this.GetObject(hitInstance).IsNPC();
    if !this.m_collided {
      this.m_collided = true;
      this.ProjectileHit(eventData);
    };
    if !isObjectNPC {
      this.TriggerSingleStimuli(hitInstance, gamedataStimType.SoundDistraction);
    };
  }
}

public class KnifeCollisionEvaluator extends gameprojectileScriptCollisionEvaluator {

  protected func EvaluateCollision(defaultOnCollisionAction: gameprojectileOnCollisionAction, params: ref<CollisionEvaluatorParams>) -> gameprojectileOnCollisionAction {
    if !IsDefined(params.target) {
      return gameprojectileOnCollisionAction.Bounce;
    };
    return gameprojectileOnCollisionAction.StopAndStick;
  }
}
