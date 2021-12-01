
public class MinotaurOnStatusEffectAppliedListener extends ScriptStatusEffectListener {

  public let m_owner: wref<NPCPuppet>;

  private let m_minotaurMechComponent: ref<MinotaurMechComponent>;

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if statusEffect.GetID() == t"Minotaur.LeftArmDestroyed" {
      this.DisableLeftArmMesh();
    } else {
      if statusEffect.GetID() == t"Minotaur.RightArmDestroyed" {
        this.DisableRightArmMesh();
      };
    };
  }

  public final func DisableLeftArmMesh() -> Void {
    if IsDefined(this.m_owner) {
      AnimationControllerComponent.SetInputBoolToReplicate(this.m_owner, n"disable_left_weak_spot_visibility", false);
    };
  }

  public final func DisableRightArmMesh() -> Void {
    if IsDefined(this.m_owner) {
      AnimationControllerComponent.SetInputBoolToReplicate(this.m_owner, n"disable_right_weak_spot_visibility", false);
    };
  }
}

public class MinotaurMechComponent extends ScriptableComponent {

  public edit let m_deathAttackRecordID: TweakDBID;

  private let m_owner: wref<NPCPuppet>;

  private let m_statusEffectListener: ref<MinotaurOnStatusEffectAppliedListener>;

  private let m_npcCollisionComponent: ref<SimpleColliderComponent>;

  private let m_npcDeathCollisionComponent: ref<SimpleColliderComponent>;

  private let m_npcSystemCollapseCollisionComponent: ref<SimpleColliderComponent>;

  private let m_currentScanType: MechanicalScanType;

  private let m_currentScanAnimation: CName;

  public final func OnGameAttach() -> Void {
    this.m_owner = this.GetOwner() as NPCPuppet;
    this.m_statusEffectListener = new MinotaurOnStatusEffectAppliedListener();
    this.m_statusEffectListener.m_owner = this.m_owner;
    this.m_currentScanType = IntEnum(0l);
    GameInstance.GetStatusEffectSystem(this.GetOwner().GetGame()).RegisterListener(this.m_owner.GetEntityID(), this.m_statusEffectListener);
  }

  public final func OnGameDetach() -> Void {
    this.m_statusEffectListener = null;
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let tags: array<CName> = evt.staticData.GameplayTags();
    if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"Minotaur.DefeatedMinotaur") {
      if IsDefined(this.m_npcCollisionComponent) {
        this.m_npcDeathCollisionComponent.Toggle(true);
      };
    };
    if ArrayContains(tags, n"JamWeapon") {
      this.DisableWeapons();
    };
    if ArrayContains(tags, n"SystemCollapse") {
      this.EnableSystemCollapse();
    };
  }

  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let tags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(tags, n"JamWeapon") {
      this.EnableWeapons();
    };
  }

  public final func DisableWeapons() -> Void {
    if IsDefined(this.m_owner) {
      AnimationControllerComponent.SetInputBoolToReplicate(this.m_owner, n"weapon_off", true);
    };
  }

  public final func EnableWeapons() -> Void {
    if IsDefined(this.m_owner) {
      AnimationControllerComponent.SetInputBoolToReplicate(this.m_owner, n"weapon_off", false);
    };
  }

  public final func EnableSystemCollapse() -> Void {
    if IsDefined(this.m_owner) {
      AnimationControllerComponent.SetInputBoolToReplicate(this.m_owner, n"system_collapse", true);
    };
  }

  protected cb func OnEnableColliderDelayEvent(enableColliderEvent: ref<EnableColliderDelayEvent>) -> Bool {
    this.m_npcCollisionComponent.Toggle(true);
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"npcCollision", n"SimpleColliderComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"deathCollision", n"SimpleColliderComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"systemCollapseCollision", n"SimpleColliderComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_npcCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"npcCollision") as SimpleColliderComponent;
    this.m_npcDeathCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"deathCollision") as SimpleColliderComponent;
    this.m_npcSystemCollapseCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"systemCollapseCollision") as SimpleColliderComponent;
    this.m_npcDeathCollisionComponent.Toggle(false);
    this.m_npcSystemCollapseCollisionComponent.Toggle(false);
  }

  protected cb func OnAudioEvent(evt: ref<AudioEvent>) -> Bool {
    let evtFootstep: ref<HeavyFootstepEvent> = new HeavyFootstepEvent();
    let player: wref<PlayerPuppet> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) {
      return false;
    };
    if Equals(evt.eventName, n"enm_mech_minotaur_loco_fs_heavy") {
      evtFootstep.instigator = this.m_owner;
      evtFootstep.audioEventName = evt.eventName;
      player.QueueEvent(evtFootstep);
    };
  }

  protected cb func OnMinotaurDeath(evt: ref<gameDeathEvent>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.SystemCollapse") {
      GameObject.StartReplicatedEffectEvent(this.m_owner, n"explode_death");
      if IsDefined(this.m_npcCollisionComponent) {
        this.m_npcDeathCollisionComponent.Toggle(true);
      };
    } else {
      this.m_npcSystemCollapseCollisionComponent.Toggle(true);
    };
  }

  public final func FireAttack() -> Void {
    let attack: ref<Attack_GameEffect>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    flag.flag = hitFlag.FriendlyFire;
    flag.source = n"Attack";
    ArrayPush(hitFlags, flag);
    attack = RPGManager.PrepareGameEffectAttack(this.m_owner.GetGame(), this.m_owner, this.m_owner, this.m_deathAttackRecordID, hitFlags);
    attack.StartAttack();
  }
}
