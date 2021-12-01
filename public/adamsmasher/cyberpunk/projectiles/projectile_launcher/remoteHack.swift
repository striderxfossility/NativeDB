
public class NanoWireProjectile extends BaseProjectile {

  @default(NanoWireProjectile, 0.f)
  public let m_maxAttackRange: Float;

  protected let m_launchMode: ELaunchMode;

  protected final func SetNanoWireProjectileLaunchMode() -> Void {
    let isPrimary: Bool = true;
    if isPrimary {
      this.m_launchMode = ELaunchMode.Primary;
    } else {
      if !isPrimary {
        this.m_launchMode = ELaunchMode.Secondary;
      } else {
        this.m_launchMode = IntEnum(2l);
      };
    };
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    super.OnProjectileInitialize(eventData);
    this.SetNanoWireProjectileLaunchMode();
    this.m_projectileComponent.SetCollisionEvaluator(new NanoWireProjectileCollisionEvaluator());
    this.m_maxAttackRange = GameInstance.GetStatsSystem(this.m_user.GetGame()).GetStatValue(Cast(this.m_user.GetEntityID()), gamedataStatType.Range);
    this.m_maxAttackRange *= 2.00;
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.GeneralLaunchSetup(eventData);
    this.LinearLaunch(eventData, this.GetProjectileTweakDBFloatParameter("startVelocity"));
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    let targetComponent: ref<IPlacedComponent>;
    this.GeneralLaunchSetup(eventData);
    targetComponent = eventData.params.trackedTargetComponent;
    if IsDefined(targetComponent) {
      this.m_initialLaunchVelocity = this.GetProjectileTweakDBFloatParameter("startVelocity");
      this.CurvedLaunchToTarget(eventData, targetComponent);
    } else {
      this.LinearLaunch(eventData, this.GetProjectileTweakDBFloatParameter("startVelocity"));
    };
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    let attackRadius: Float;
    let attackRecord: ref<Attack_Record>;
    let hitInstance: gameprojectileHitInstance;
    let puppet: ref<NPCPuppet>;
    super.OnCollision(eventData);
    hitInstance = eventData.hitInstances[0];
    puppet = hitInstance.hitObject as NPCPuppet;
    if !IsDefined(puppet) || !ScriptedPuppet.IsActive(puppet) {
      return false;
    };
    if Equals(this.m_launchMode, ELaunchMode.Primary) {
      attackRecord = TweakDBInterface.GetAttackRecord(t"Attacks.NanoWireNonLethalGrapple");
    } else {
      if Equals(this.m_launchMode, ELaunchMode.Secondary) {
        attackRecord = TweakDBInterface.GetAttackRecord(t"Attacks.NanoWireLethalGrapple");
      } else {
        attackRecord = TweakDBInterface.GetAttackRecord(t"Attacks.NanoWireNonLethalGrapple");
      };
    };
    attackRadius = attackRecord.Range();
    this.ProjectileHitAoE(hitInstance, attackRadius, attackRecord);
  }
}

public class NanoWireProjectileCollisionEvaluator extends gameprojectileScriptCollisionEvaluator {

  protected func EvaluateCollision(defaultOnCollisionAction: gameprojectileOnCollisionAction, params: ref<CollisionEvaluatorParams>) -> gameprojectileOnCollisionAction {
    if params.target.IsNPC() {
      return gameprojectileOnCollisionAction.StopAndStick;
    };
    return gameprojectileOnCollisionAction.Bounce;
  }
}
