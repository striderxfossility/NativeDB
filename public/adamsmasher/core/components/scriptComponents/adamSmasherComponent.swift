
public class AdamSmasherHealthChangeListener extends CustomValueStatPoolsListener {

  public let m_owner: wref<NPCPuppet>;

  public let m_player: wref<PlayerPuppet>;

  private let m_adamSmasherComponent: ref<AdamSmasherComponent>;

  private let m_statPoolType: gamedataStatPoolType;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.CheckPhase(oldValue, newValue, percToPoints);
  }

  public final func CheckPhase(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if oldValue > AdamSmasherComponent.GetRemovePlateHealthValue() && newValue <= AdamSmasherComponent.GetRemovePlateHealthValue() && StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Phase1") && !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.DestroyedPlate") {
      if !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Destroyed_Plate") {
        this.ApplySmashed();
      };
      this.DisableFrontPlate();
      this.EnableTorsoWeakspot();
    };
    if oldValue > AdamSmasherComponent.GetPhase2HealthValue() && newValue <= AdamSmasherComponent.GetPhase2HealthValue() && StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Phase1") {
      this.ApplyPhase2();
      this.DisableTorsoWeakspot();
      this.DisableRightArm();
      this.EnableLauncherWeakspot();
    };
    if oldValue > AdamSmasherComponent.GetEmergencyPhaseHealthValue() && newValue <= AdamSmasherComponent.GetEmergencyPhaseHealthValue() && !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Invulnerable") {
      this.ApplyEmergency();
    };
    if oldValue > AdamSmasherComponent.GetPhase3HealthValue() && newValue <= AdamSmasherComponent.GetPhase3HealthValue() && StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Phase2") {
      this.ApplyPhase3();
      this.DisableLauncherWeakspot();
      this.EnableHeadWeakspot();
    };
  }

  public final func ApplySmashed() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Smashed", this.m_owner.GetEntityID());
  }

  public final func ApplyPhase2() -> Void {
    this.DestroyWeakspotGenerator();
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.Phase1");
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.Destroyed_Plate");
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Phase2", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Destroyed_Stage1", this.m_owner.GetEntityID());
    GameObject.StartReplicatedEffectEvent(this.m_owner, n"arm_destroyed");
    DismembermentComponent.RequestDismemberment(this.m_owner, gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE, Vector4.EmptyVector());
  }

  public final func ApplyPhase3() -> Void {
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.Phase2");
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.Destroyed_Stage1");
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Phase3", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Wounded", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Destroyed_Stage2", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.AdamSmasherStealthDot", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"BaseStatusEffect.BossNoTakeDown", this.m_owner.GetEntityID());
    this.RemoveEmergency();
  }

  public final func ApplyEmergency() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Invulnerable", this.m_owner.GetEntityID());
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Emergency", this.m_owner.GetEntityID());
  }

  public final func RemoveEmergency() -> Void {
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.Invulnerable");
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.Emergency");
  }

  private final func EnableTorsoWeakspot() -> Void {
    if !IsDefined(this.m_owner) {
      return;
    };
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightShoulder", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"TorsoWeakspot", false);
  }

  private final func DisableTorsoWeakspot() -> Void {
    if !IsDefined(this.m_owner) {
      return;
    };
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"RightShoulder", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"TorsoWeakspot", false);
  }

  private final func EnableHeadWeakspot() -> Void {
    if !IsDefined(this.m_owner) {
      return;
    };
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"HeadReinforced", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"Head", false);
  }

  private final func DisableRightArm() -> Void {
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightArm", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightForeArm", false);
    if !IsDefined(this.m_owner) {
      return;
    };
  }

  private final func DisableFrontPlate() -> Void {
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"FrontPlate", false);
    if !IsDefined(this.m_owner) {
      return;
    };
  }

  private final func EnableLauncherWeakspot() -> Void {
    if !IsDefined(this.m_owner) {
      return;
    };
  }

  private final func DisableLauncherWeakspot() -> Void {
    if !IsDefined(this.m_owner) {
      return;
    };
  }

  private final func DestroyWeakspotGenerator() -> Void {
    let i: Int32;
    let scriptWeakspot: ref<ScriptedWeakspotObject>;
    let weakspots: array<wref<WeakspotObject>>;
    this.m_owner.GetWeakspotComponent().GetWeakspots(weakspots);
    if ArraySize(weakspots) > 0 {
      i = 0;
      while i < ArraySize(weakspots) {
        scriptWeakspot = weakspots[i] as ScriptedWeakspotObject;
        scriptWeakspot.DestroyWeakspot(this.m_owner);
        ScriptedWeakspotObject.Kill(weakspots[i]);
        i += 1;
      };
    };
  }
}

public class AdamSmasherComponent extends ScriptableComponent {

  private let m_owner: wref<NPCPuppet>;

  private let m_owner_id: EntityID;

  private let m_statusEffect_armor1_id: TweakDBID;

  private let m_statusEffect_armor2_id: TweakDBID;

  private let m_statusEffect_armor3_id: TweakDBID;

  private let m_statusEffect_smashed_id: TweakDBID;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  private let m_statPoolType: gamedataStatPoolType;

  private let m_healthListener: ref<AdamSmasherHealthChangeListener>;

  private let m_phase2Threshold: Float;

  private let m_phase3Threshold: Float;

  private let m_npcCollisionComponent: ref<SimpleColliderComponent>;

  private let m_targetTrackerComponent: ref<TargetTrackerComponent>;

  public final func OnGameAttach() -> Void {
    let evt2: ref<DisableWeakspotDelayedEvent> = new DisableWeakspotDelayedEvent();
    let evt: ref<gameDeathParamsEvent> = new gameDeathParamsEvent();
    let selfGameObject: ref<GameObject> = this.m_owner;
    selfGameObject.QueueEvent(evt);
    this.m_owner = this.GetOwner() as NPCPuppet;
    this.m_owner_id = this.m_owner.GetEntityID();
    this.m_owner.SetDisableRagdoll(true);
    this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
    this.m_healthListener = new AdamSmasherHealthChangeListener();
    this.m_healthListener.SetValue(80.00);
    this.m_healthListener.m_owner = this.m_owner;
    this.m_healthListener.m_player = this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
    this.m_statusEffect_armor1_id = t"AdamSmasher.Phase1";
    this.m_statusEffect_armor2_id = t"AdamSmasher.Phase2";
    this.m_statusEffect_armor3_id = t"AdamSmasher.Phase3";
    this.m_statusEffect_smashed_id = t"AdamSmasher.Smashed";
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, this.m_statusEffect_armor1_id, this.m_owner_id);
    this.m_statPoolSystem.RequestRegisteringListener(Cast(this.m_owner_id), gamedataStatPoolType.Health, this.m_healthListener);
    GameInstance.GetDelaySystem(this.m_owner.GetGame()).DelayEvent(this.m_owner, evt2, 0.10);
    this.m_targetTrackerComponent = this.m_owner.GetTargetTrackerComponent();
  }

  public final func OnGameDetach() -> Void {
    this.m_statPoolSystem.RequestUnregisteringListener(Cast(this.m_owner_id), gamedataStatPoolType.Health, this.m_healthListener);
    this.m_healthListener = null;
  }

  protected cb func OnEnableColliderDelayEvent(enableColliderEvent: ref<EnableColliderDelayEvent>) -> Bool {
    this.m_npcCollisionComponent.Toggle(true);
  }

  protected cb func OnDeathAfterDefeatedSmasher(evt: ref<gameDeathEvent>) -> Bool {
    GameObject.BreakReplicatedEffectLoopEvent(this.m_owner, n"broken");
    GameObject.BreakReplicatedEffectLoopEvent(this.m_owner, n"exp_launcher");
    GameObject.BreakReplicatedEffectLoopEvent(this.m_owner, n"arm_destroyed");
    if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.SmasherAnimationActivator") {
      GameObject.ToggleForcedVisibilityInAnimSystemEvent(this.GetOwner(), n"SmasherCustomDisabler", false);
      StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.SmasherAnimationActivator");
    };
    this.m_npcCollisionComponent.Toggle(false);
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"npcCollision", n"SimpleColliderComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_npcCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"npcCollision") as SimpleColliderComponent;
  }

  public final func ApplySmashed() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"AdamSmasher.Smashed", this.m_owner.GetEntityID());
  }

  private final func DisableFrontPlate() -> Void {
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"FrontPlate", false);
    if !IsDefined(this.m_owner) {
      return;
    };
  }

  private final func EnableTorsoWeakspot() -> Void {
    if !IsDefined(this.m_owner) {
      return;
    };
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightShoulder", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"TorsoWeakspot", false);
  }

  public final static func GetRemovePlateHealthValue() -> Float {
    return 80.00;
  }

  public final static func GetPhase2HealthValue() -> Float {
    return 60.00;
  }

  public final static func GetEmergencyPhaseHealthValue() -> Float {
    return 25.00;
  }

  public final static func GetPhase3HealthValue() -> Float {
    return 15.00;
  }

  public final func SetPercentLifeForPhase(value: Float) -> Void {
    this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
    this.m_statPoolSystem.RequestChangingStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, 100.00, this.m_owner, true);
    value = 100.00 - value;
    this.m_statPoolSystem.RequestChangingStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, -value, this.m_owner, true);
  }

  private final func EnableRipInteractionLayer() -> Void {
    let puppet: wref<ScriptedPuppet> = this.m_owner;
    puppet.EnableInteraction(n"AdamSmasherRipInteraction", true);
  }

  private final func DisableRipInteractionLayer() -> Void {
    let puppet: wref<ScriptedPuppet> = this.m_owner;
    puppet.EnableInteraction(n"AdamSmasherRipInteraction", false);
  }

  private final func DisableWeakspots() -> Void {
    if !IsDefined(this.m_owner) {
      return;
    };
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"Head", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"TorsoWeakspot", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"HeadReinforced", false);
  }

  protected final func DisableAllHitShapes() -> Void {
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"Head", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"Belly", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftTorso", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftArm", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftForeArm", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightShoulder", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightArm", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightForeArm", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftLeg", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftUpLeg", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftFoot", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightLeg", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightUpLeg", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightFoot", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"HeadReinforced", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"TorsoWeakspot", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"Launcher", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"Chest", false);
  }

  protected final func DisableAllDefeatedHitShapes() -> Void {
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"HeadDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"BellyDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftTorsoDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftArmDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftForeArmDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightShoulderDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightArmDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightForeArmDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftLegDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftUpLegDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"LeftFootDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightLegDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightUpLegDefeated", false);
    HitShapeUserDataBase.DisableHitShape(this.m_owner, n"RightFootDefeated", false);
  }

  protected final func EnableDefeatedHitShapes() -> Void {
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"Head", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"HeadDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"BellyDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"LeftTorsoDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"LeftArmDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"LeftForeArmDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"RightShoulderDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"RightArmDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"LeftLegDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"LeftUpLegDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"LeftFootDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"RightLegDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"RightUpLegDefeated", false);
    HitShapeUserDataBase.EnableHitShape(this.m_owner, n"RightFootDefeated", false);
  }

  protected final func OnDeactivate() -> Void {
    this.DisableRipInteractionLayer();
  }

  protected cb func OnDisableWeakspotDelayedEvent(evt: ref<DisableWeakspotDelayedEvent>) -> Bool {
    this.DisableAllDefeatedHitShapes();
    this.DisableWeakspots();
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let enableColliderEvent: ref<EnableColliderDelayEvent> = new EnableColliderDelayEvent();
    let tags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(tags, n"SmasherAnimationActivator") {
      GameObject.ToggleForcedVisibilityInAnimSystemEvent(this.GetOwner(), n"SmasherCustomDisabler", true);
    };
    if ArrayContains(tags, n"SmasherCustomHackTakedown") {
      if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Phase1") {
        this.ApplyNoInterrupt();
        this.SetPercentLifeForPhase(AdamSmasherComponent.GetPhase2HealthValue());
      } else {
        if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Phase2") {
          this.SetPercentLifeForPhase(AdamSmasherComponent.GetPhase3HealthValue());
        };
      };
    } else {
      if ArrayContains(tags, n"SmasherCustomHack") {
        if this.m_statPoolSystem.GetStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, true) > AdamSmasherComponent.GetPhase2HealthValue() {
          this.ApplyNoInterrupt();
          this.SetPercentLifeForPhase(AdamSmasherComponent.GetPhase2HealthValue());
        } else {
          if this.m_statPoolSystem.GetStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, true) <= AdamSmasherComponent.GetPhase2HealthValue() && this.m_statPoolSystem.GetStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, true) > AdamSmasherComponent.GetEmergencyPhaseHealthValue() {
            this.SetPercentLifeForPhase(AdamSmasherComponent.GetEmergencyPhaseHealthValue());
          } else {
            if this.m_statPoolSystem.GetStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, true) > AdamSmasherComponent.GetPhase3HealthValue() {
              this.SetPercentLifeForPhase(AdamSmasherComponent.GetPhase3HealthValue());
            } else {
              if this.m_statPoolSystem.GetStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, true) <= AdamSmasherComponent.GetEmergencyPhaseHealthValue() && !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Invulnerable") {
                GameObject.StartReplicatedEffectEvent(this.m_owner, n"panel_rip");
                this.SetPercentLifeForPhase(0.00);
              };
            };
          };
        };
      };
    };
    if ArrayContains(tags, n"SmasherCustomStatusEffect") {
      if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Destroyed_Plate") {
        this.SetHealth(this.m_owner, AdamSmasherComponent.GetRemovePlateHealthValue());
      };
    };
    if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.Defeated") {
      this.DisableAllHitShapes();
      this.EnableDefeatedHitShapes();
      StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"AdamSmasher.AdamSmasherStealthDot");
      if IsDefined(this.m_npcCollisionComponent) {
        GameInstance.GetDelaySystem(this.m_owner.GetGame()).DelayEvent(this.m_owner, enableColliderEvent, 0.10);
      };
    };
  }

  public final func ApplyNoInterrupt() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"BaseStatusEffect.BossNoInterrupt", this.m_owner.GetEntityID());
  }

  private final func SetHealth(target: ref<NPCPuppet>, valueToSet: Float) -> Void {
    let currentHealth: Float;
    let finalValue: Float;
    if valueToSet < 0.00 {
      valueToSet = 0.00;
    };
    currentHealth = GameInstance.GetStatPoolsSystem(target.GetGame()).GetStatPoolValue(Cast(target.GetEntityID()), gamedataStatPoolType.Health, true);
    finalValue = valueToSet - currentHealth;
    GameInstance.GetStatPoolsSystem(target.GetGame()).RequestChangingStatPoolValue(Cast(target.GetEntityID()), gamedataStatPoolType.Health, finalValue, null, true);
  }

  protected cb func OnAudioEvent(evt: ref<AudioEvent>) -> Bool {
    let evtFootstep: ref<HeavyFootstepEvent> = new HeavyFootstepEvent();
    let player: wref<PlayerPuppet> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) {
      return false;
    };
    if Equals(evt.eventName, n"nme_boss_smasher_lcm_walk") || Equals(evt.eventName, n"nme_boss_smasher_lcm_sprint") {
      evtFootstep.instigator = this.m_owner;
      evtFootstep.audioEventName = evt.eventName;
      player.QueueEvent(evtFootstep);
    };
  }
}
