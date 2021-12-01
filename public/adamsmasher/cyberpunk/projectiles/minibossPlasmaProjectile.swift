
public class minibossPlasmaProjectile extends BaseProjectile {

  private let m_countTime: Float;

  private edit let m_startVelocity: Float;

  private edit let m_lifetime: Float;

  private edit let m_effectName: CName;

  private edit let m_hitEffectName: CName;

  @default(minibossPlasmaProjectile, false)
  private edit let m_followTarget: Bool;

  private edit let m_bendFactor: Float;

  private edit let m_bendRatio: Float;

  private edit let m_shouldRotate: Bool;

  public edit let m_attackRecordID: TweakDBID;

  protected let m_instigator: wref<GameObject>;

  @default(minibossPlasmaProjectile, false)
  private edit let m_spawnGameEffectOnCollision: Bool;

  private edit let m_collisionAttackRecord: ref<Attack_Record>;

  @default(minibossPlasmaProjectile, true)
  private let m_alive: Bool;

  private let m_owner: wref<ScriptedPuppet>;

  private let m_target: wref<GameObject>;

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.m_owner = eventData.owner as ScriptedPuppet;
  }

  private final func StartEffect() -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = this.m_effectName;
    this.QueueEvent(spawnEffectEvent);
  }

  private final func StopEffect() -> Void {
    let killEffectEvent: ref<entKillEffectEvent> = new entKillEffectEvent();
    killEffectEvent.effectName = this.m_effectName;
    this.QueueEvent(killEffectEvent);
  }

  private final func Reset() -> Void {
    this.m_countTime = 0.00;
    this.m_alive = true;
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.m_instigator = eventData.owner;
    this.OnShootTarget(eventData as gameprojectileShootTargetEvent);
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    let followParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    let linearParams: ref<LinearTrajectoryParams> = new LinearTrajectoryParams();
    let targetPosition: Vector4 = eventData.params.targetPosition;
    if !IsDefined(this.m_instigator) {
      this.m_instigator = eventData.owner;
    };
    this.Reset();
    this.StartEffect();
    if !this.m_followTarget {
      if IsDefined(this.m_owner) {
        if Equals(this.m_owner.GetUpperBodyStateFromBlackboard(), gamedataNPCUpperBodyState.Defend) {
          linearParams.startVel = this.m_owner.GetFloatFromCharacterTweak("stance_turtle_projectileSpeed", -1.00);
        } else {
          linearParams.startVel = this.m_owner.GetFloatFromCharacterTweak("attack_pulse_projectileSpeed", -1.00);
        };
      };
      if linearParams.startVel <= 0.00 {
        linearParams.startVel = this.m_startVelocity;
      };
      this.m_projectileComponent.AddLinear(linearParams);
    } else {
      this.m_projectileComponent.ClearTrajectories();
      followParams.startVelocity = this.m_startVelocity;
      followParams.targetPosition = targetPosition;
      followParams.bendFactor = this.m_bendFactor;
      followParams.bendTimeRatio = this.m_bendRatio;
      followParams.angleInHitPlane = 0.00;
      followParams.shouldRotate = this.m_shouldRotate;
      followParams.accuracy = 1.00;
      this.m_projectileComponent.AddFollowCurve(followParams);
    };
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    this.m_countTime += eventData.deltaTime;
    if this.m_countTime > this.m_lifetime {
      this.Release();
    };
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    if this.m_alive && eventData.hitInstances[0].hitObject != this.m_owner {
      GameObject.PlaySoundEvent(this, n"w_gun_special_plasma_cutter_exploding_projectile_3D");
      if this.m_spawnGameEffectOnCollision {
        this.Explode(this.m_attackRecordID);
      };
      this.DealDamage(eventData);
      this.Release();
      this.StopEffect();
      GameObjectEffectHelper.StartEffectEvent(this, this.m_hitEffectName);
      this.m_alive = false;
    };
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    if this.m_alive {
      GameObject.PlaySoundEvent(this, n"w_gun_special_plasma_cutter_exploding_projectile_3D");
      this.StopEffect();
      GameObjectEffectHelper.StartEffectEvent(this, this.m_hitEffectName);
      if this.m_spawnGameEffectOnCollision {
        this.Explode(this.m_attackRecordID);
      };
      this.m_alive = false;
      this.Release();
    };
  }

  private final func DealDamage(eventData: ref<gameprojectileHitEvent>) -> Void {
    let damageEffect: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    damageEffect.Run();
    this.m_countTime = 0.00;
    this.m_alive = false;
    this.m_projectileComponent.ClearTrajectories();
  }

  private final func Explode(record: TweakDBID) -> Void {
    if TDBID.IsValid(record) {
      this.FireAttack();
    };
  }

  public final func FireAttack() -> Void {
    let Attack: ref<Attack_GameEffect>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    flag.flag = hitFlag.SuccessfulAttack;
    flag.source = n"Attack";
    ArrayPush(hitFlags, flag);
    Attack = RPGManager.PrepareGameEffectAttack(this.GetGame(), this.m_instigator, this, this.m_attackRecordID, hitFlags);
    Attack.StartAttack();
  }
}
