
public class ThrowableWeaponObject extends WeaponObject {

  protected let m_projectileComponent: ref<ProjectileComponent>;

  protected let m_weaponOwner: wref<GameObject>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"projectileComponent", n"ProjectileComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_projectileComponent = EntityResolveComponentsInterface.GetComponent(ri, n"projectileComponent") as ProjectileComponent;
    if IsDefined(this.m_projectileComponent) {
      this.m_projectileComponent.SetEnergyLossFactor(0.00, 0.00);
      this.m_projectileComponent.SetCollisionEvaluator(new WeaponCollisionEvaluator());
    };
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.m_weaponOwner = eventData.owner;
    AnimationControllerComponent.PushEventToReplicate(this, n"Throw");
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.OnThrow(eventData);
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    this.OnThrow(eventData);
  }

  private final func OnThrow(eventData: ref<gameprojectileShootEvent>) -> Void {
    let throwDirectionOnGround: Vector4;
    let worldTransform: WorldTransform;
    let fxResource: FxResource = this.GetFxPackage().GetVfxGroundThrow();
    if FxResource.IsValid(fxResource) {
      WorldTransform.SetPosition(worldTransform, eventData.startPoint);
      throwDirectionOnGround = eventData.startVelocity;
      throwDirectionOnGround.Z = 0.00;
      WorldTransform.SetOrientationFromDir(worldTransform, throwDirectionOnGround);
      GameInstance.GetFxSystem(this.GetGame()).SpawnEffectOnGround(fxResource, worldTransform, 10.00);
    };
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    let attackRecord: ref<Attack_Record>;
    AnimationControllerComponent.PushEventToReplicate(this, n"Reset");
    if !IsDefined(this.m_weaponOwner) {
      return false;
    };
    if IsDefined(eventData.hitInstances[0].hitObject) {
      attackRecord = TweakDBInterface.GetAttackRecord(t"NPCAttacks.StrongThrowImpact");
      ProjectileGameEffectHelper.RunEffectFromAttack(this.m_weaponOwner, this.m_weaponOwner, this, attackRecord, eventData);
    } else {
      GameObjectEffectHelper.StartEffectEvent(this, n"imp_concrete");
    };
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool;
}

public class WeaponCollisionEvaluator extends gameprojectileScriptCollisionEvaluator {

  protected func EvaluateCollision(defaultOnCollisionAction: gameprojectileOnCollisionAction, params: ref<CollisionEvaluatorParams>) -> gameprojectileOnCollisionAction {
    if !IsDefined(params.target) {
      return gameprojectileOnCollisionAction.Stop;
    };
    return IntEnum(0l);
  }
}
