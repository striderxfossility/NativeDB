
public class OdaEmergencyListener extends CustomValueStatPoolsListener {

  public let m_owner: wref<NPCPuppet>;

  public let m_healNumber: Int32;

  @default(OdaEmergencyListener, 70.f)
  private let m_heal1HealthPercentage: Float;

  @default(OdaEmergencyListener, 55.f)
  private let m_heal2HealthPercentage: Float;

  @default(OdaEmergencyListener, 40.f)
  private let m_heal3HealthPercentage: Float;

  @default(OdaEmergencyListener, 25.f)
  private let m_heal4HealthPercentage: Float;

  @default(OdaEmergencyListener, 10.f)
  private let m_heal5HealthPercentage: Float;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.CheckHPValue(oldValue, newValue, percToPoints);
  }

  public final func CheckHPValue(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if oldValue > this.m_heal1HealthPercentage && newValue <= this.m_heal1HealthPercentage && this.m_healNumber == 0 {
      this.SetRoamingBehaviorAuthorization();
    } else {
      if oldValue > this.m_heal2HealthPercentage && newValue <= this.m_heal2HealthPercentage && this.m_healNumber == 1 {
        this.SetRoamingBehaviorAuthorization();
      };
    };
    if oldValue > this.m_heal3HealthPercentage && newValue <= this.m_heal3HealthPercentage && this.m_healNumber == 2 {
      this.SetRoamingBehaviorAuthorization();
    } else {
      if oldValue > this.m_heal4HealthPercentage && newValue <= this.m_heal4HealthPercentage && this.m_healNumber == 3 {
        this.SetRoamingBehaviorAuthorization();
      };
    };
    if oldValue > this.m_heal5HealthPercentage && newValue <= this.m_heal5HealthPercentage && this.m_healNumber == 4 {
      this.SetRoamingBehaviorAuthorization();
    };
  }

  public final func SetRoamingBehaviorAuthorization() -> Void {
    this.m_healNumber += 1;
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Oda.Emergency", this.m_owner.GetEntityID());
  }
}

public class OdaComponent extends ScriptableComponent {

  private let m_owner: wref<NPCPuppet>;

  private let m_owner_id: EntityID;

  private let m_odaAIComponent: ref<AIHumanComponent>;

  private let m_actionBlackBoard: wref<IBlackboard>;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  private let m_statPoolType: gamedataStatPoolType;

  private let m_healthListener: ref<OdaEmergencyListener>;

  private let m_statusEffect_emergency: TweakDBID;

  private let m_targetTrackerComponent: ref<TargetTrackerComponent>;

  private final func OnGameAttach() -> Void {
    this.m_owner = this.GetOwner() as NPCPuppet;
    this.m_owner_id = this.m_owner.GetEntityID();
    this.m_odaAIComponent = this.m_owner.GetAIControllerComponent();
    this.m_actionBlackBoard = this.m_odaAIComponent.GetActionBlackboard();
    this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
    this.m_healthListener = new OdaEmergencyListener();
    this.m_healthListener.SetValue(70.00);
    this.m_healthListener.m_owner = this.m_owner;
    this.m_statPoolSystem.RequestRegisteringListener(Cast(this.m_owner_id), gamedataStatPoolType.Health, this.m_healthListener);
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Oda.Masked", this.m_owner_id);
    this.m_targetTrackerComponent = this.m_owner.GetTargetTrackerComponent();
  }

  public final func OnGameDetach() -> Void {
    this.m_statPoolSystem.RequestUnregisteringListener(Cast(this.m_owner_id), gamedataStatPoolType.Health, this.m_healthListener);
    this.m_healthListener = null;
  }

  public final func GetCombatTarget() -> wref<NPCPuppet> {
    return FromVariant(this.m_odaAIComponent.GetBehaviorArgument(n"CombatTarget"));
  }

  protected cb func OnAIEvent(aiEvent: ref<AIEvent>) -> Bool {
    if Equals(aiEvent.name, n"BladesOn") {
      GameObject.StartReplicatedEffectEvent(this.m_owner, n"blade_light_on");
      GameObject.BreakReplicatedEffectLoopEvent(this.m_owner, n"screen_swipe");
    };
    if Equals(aiEvent.name, n"BladesOff") {
      GameObject.BreakReplicatedEffectLoopEvent(this.m_owner, n"blade_light_on");
      GameObject.StartReplicatedEffectEvent(this.m_owner, n"screen_swipe");
    };
    if Equals(aiEvent.name, n"StealthMode") {
      GameObject.BreakReplicatedEffectLoopEvent(this.m_owner, n"screen_swipe");
    };
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let tags: array<CName> = evt.staticData.GameplayTags();
    if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.Defeated") {
      GameObject.BreakReplicatedEffectLoopEvent(this.m_owner, n"blade_light_on");
    };
    if ArrayContains(tags, n"Overload") {
      StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"Oda.CloakedOda");
      StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"Oda.Cloaked");
    };
    if ArrayContains(tags, n"OdaStatusEffect") {
      this.EvaluateAppearance();
    };
    if ArrayContains(tags, n"Cloak") {
      this.ApplyBlockStaggerStatusEffect();
    };
    if ArrayContains(tags, n"Heal") {
      this.RemoveBlockStaggerStatusEffect();
      this.ApplyForceStaggerStatusEffect();
    };
    if ArrayContains(tags, n"OdaStealthWrappers") {
      AnimationControllerComponent.SetAnimWrapperWeight(this.m_owner, n"OdaSearchingCustom", 1.00);
    };
  }

  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let tags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(tags, n"OdaStatusEffect") {
      this.EvaluateAppearance();
    };
    if ArrayContains(tags, n"Cloak") {
      this.RemoveForceStaggerStatusEffect();
    };
    if evt.staticData.GetID() == t"Oda.Masked" {
      SetFactValue(this.m_owner.GetGame(), n"q112_oda_mask_destroyed", 1);
    };
    if ArrayContains(tags, n"OdaStealthWrappers") {
      AnimationControllerComponent.SetAnimWrapperWeight(this.m_owner, n"OdaSearchingCustom", 0.00);
    };
  }

  protected cb func OnNonStealthQuickHackVictimEvent(evt: ref<NonStealthQuickHackVictimEvent>) -> Bool {
    NPCStatesComponent.AlertPuppet(this.m_owner);
  }

  public final func ApplyForceStaggerStatusEffect() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Oda.ForceStaggerOda", this.m_owner.GetEntityID());
  }

  public final func ApplyBlockStaggerStatusEffect() -> Void {
    StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Oda.BlockStaggerOda", this.m_owner.GetEntityID());
  }

  public final func RemoveForceStaggerStatusEffect() -> Void {
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"Oda.ForceStaggerOda");
  }

  public final func RemoveBlockStaggerStatusEffect() -> Void {
    StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"Oda.BlockStaggerOda");
  }

  public final func EvaluateAppearance() -> Void {
    if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.CloakedOda") && StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"Oda.Cemented") {
      this.m_owner.ScheduleAppearanceChange(n"oda_oda_cloak_concrete");
    } else {
      if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.CloakedOda") {
        this.m_owner.ScheduleAppearanceChange(n"oda_oda_cloak");
      } else {
        if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.CloakedOda") && !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"Oda.Masked") {
          this.m_owner.ScheduleAppearanceChange(n"oda_oda_mask_damage_concrete");
        } else {
          if !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"Oda.Masked") {
            this.m_owner.ScheduleAppearanceChange(n"oda_oda_mask_damage");
          } else {
            if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"Oda.Cemented") {
              this.m_owner.ScheduleAppearanceChange(n"oda_oda_concrete");
            } else {
              this.m_owner.ScheduleAppearanceChange(n"oda_oda");
            };
          };
        };
      };
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool;

  protected cb func OnSmartBulletDeflectedEvent(evt: ref<SmartBulletDeflectedEvent>) -> Bool {
    SetFactValue(this.m_owner.GetGame(), n"q112_oda_mask_deflected_bullet", 1);
  }

  protected cb func OnLookedAtEvent(evt: ref<LookedAtEvent>) -> Bool;

  protected final func OnDeactivate() -> Void;

  protected cb func OnDamageDealt(evt: ref<gameTargetDamageEvent>) -> Bool {
    let weapon: wref<WeaponObject> = ScriptedPuppet.GetActiveWeapon(this.m_owner);
    if IsDefined(weapon) && WeaponObject.IsOfType(weapon.GetItemID(), gamedataItemType.Cyb_MantisBlades) {
      SetFactValue(this.m_owner.GetGame(), n"q112_oda_dealt_damage_with_mantis", 1);
    };
  }
}
