
public class CentaurShieldController extends AICustomComponents {

  @default(CentaurShieldController, true)
  private edit let m_startWithShieldActive: Bool;

  @default(CentaurShieldController, ShieldState)
  private const let m_animFeatureName: CName;

  @default(CentaurShieldController, Shield_ControllerDestroyed)
  private const let m_shieldDestroyedModifierName: CName;

  private let m_shieldState: ECentaurShieldState;

  private let m_centaurBlackboard: ref<IBlackboard>;

  private final func OnGameAttach() -> Void {
    this.m_centaurBlackboard = IBlackboard.Create(GetAllBlackboardDefs().CustomCentaurBlackboard);
    ScriptedPuppet.CreateCustomBlackboard(this.GetOwner(), this.m_centaurBlackboard);
    this.m_centaurBlackboard.SetFloat(GetAllBlackboardDefs().CustomCentaurBlackboard.WoundedStateHPThreshold, -1.00);
    if this.m_startWithShieldActive {
      this.ChangeShieldState(ECentaurShieldState.Active);
    };
  }

  public final static func ChangeShieldState(obj: ref<GameObject>, newState: ECentaurShieldState) -> Void {
    let changeStateEvent: ref<CentaurShieldStateChangeEvent> = new CentaurShieldStateChangeEvent();
    changeStateEvent.newState = newState;
    obj.QueueEvent(changeStateEvent);
  }

  protected cb func OnShieldStateChange(stateChangeEvent: ref<CentaurShieldStateChangeEvent>) -> Bool {
    this.ChangeShieldState(stateChangeEvent.newState);
  }

  private final func ChangeShieldState(newState: ECentaurShieldState) -> Void {
    if Equals(this.m_shieldState, newState) {
      return;
    };
    this.m_shieldState = newState;
    this.UpdateAnimFeature();
    this.UpdateBlackbaord();
    switch this.m_shieldState {
      case ECentaurShieldState.Destroyed:
        this.TriggerShieldControllerExplosion();
        this.ApplyShieldDestroyedStats();
        this.PlayShieldDestroyedVoiceOver();
        break;
      default:
    };
  }

  private final func UpdateAnimFeature() -> Void {
    let shieldAnimFeature: ref<AnimFeatureShieldState> = new AnimFeatureShieldState();
    shieldAnimFeature.state = EnumInt(this.m_shieldState);
    AnimationControllerComponent.ApplyFeature(this.GetOwner(), this.m_animFeatureName, shieldAnimFeature);
  }

  private final func UpdateBlackbaord() -> Void {
    this.m_centaurBlackboard.SetInt(GetAllBlackboardDefs().CustomCentaurBlackboard.ShieldState, EnumInt(this.m_shieldState));
  }

  private final func ApplyShieldDestroyedStats() -> Void {
    let ownerID: StatsObjectID = Cast(this.GetOwner().GetEntityID());
    let desiredStaggerThreshold: Float = this.GetFloatFromCharacterTweak("shieldControllerDestroyed_staggerThreshold");
    let currentStaggerThreshold: Float = GameInstance.GetStatsSystem(this.GetOwner().GetGame()).GetStatValue(ownerID, gamedataStatType.StaggerDamageThreshold);
    let statFlag: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.StaggerDamageThreshold, gameStatModifierType.Additive, desiredStaggerThreshold - currentStaggerThreshold);
    GameInstance.GetStatsSystem(this.GetOwner().GetGame()).AddModifier(ownerID, statFlag);
  }

  private final func PlayShieldDestroyedVoiceOver() -> Void {
    let voName: CName = StringToName(this.GetStringFromCharacterTweak("shieldControllerDestroyed_voiceOver"));
    GameObject.PlayVoiceOver(this.GetOwner(), voName, n"Scripts:PlayShieldDestroyedVoiceOver");
  }

  private final func GetFloatFromCharacterTweak(varName: String, opt defaultValue: Float) -> Float {
    return (this.GetOwner() as ScriptedPuppet).GetFloatFromCharacterTweak(varName, defaultValue);
  }

  private final func GetStringFromCharacterTweak(varName: String, opt defaultValue: String) -> String {
    return (this.GetOwner() as ScriptedPuppet).GetStringFromCharacterTweak(varName, defaultValue);
  }

  private final func TriggerShieldControllerExplosion() -> Void {
    let attackContext: AttackInitContext;
    let explosionAttack: ref<Attack_GameEffect>;
    let explosionEffect: ref<EffectInstance>;
    let hitFlags: array<hitFlag>;
    let statMods: array<ref<gameStatModifierData>>;
    GameObjectEffectHelper.StartEffectEvent(this.GetOwner(), n"weakspot_explode");
    GameObjectEffectHelper.StartEffectEvent(this.GetOwner(), n"weakspot_overload");
    attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.Explosion");
    attackContext.instigator = attackContext.source;
    attackContext.source = this.GetOwner();
    explosionAttack = IAttack.Create(attackContext) as Attack_GameEffect;
    explosionEffect = explosionAttack.PrepareAttack(this.GetOwner());
    explosionAttack.GetStatModList(statMods);
    ArrayPush(hitFlags, hitFlag.FriendlyFire);
    EffectData.SetFloat(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, 3.50);
    EffectData.SetVector(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, this.GetOwner().GetWorldPosition());
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.flags, ToVariant(hitFlags));
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    explosionAttack.StartAttack();
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let tags: array<CName> = evt.staticData.GameplayTags();
    let i: Int32 = 0;
    while i < ArraySize(tags) {
      if Equals(tags[i], n"E3_BossWeakSpotDestroyed") {
        this.ChangeShieldState(ECentaurShieldState.Destroyed);
      } else {
        i += 1;
      };
    };
  }

  protected cb func OnEventReceived(stimEvent: ref<StimuliEvent>) -> Bool {
    let shieldTarget: wref<GameObject>;
    if Equals(this.m_shieldState, ECentaurShieldState.Active) && Equals(stimEvent.GetStimType(), gamedataStimType.GrenadeLanded) {
      shieldTarget = stimEvent.sourceObject;
      if shieldTarget != null {
        this.m_centaurBlackboard.SetEntityID(GetAllBlackboardDefs().CustomCentaurBlackboard.ShieldTarget, shieldTarget.GetEntityID());
      };
    };
  }

  protected cb func OnHitShield(evt: ref<HitShieldEvent>) -> Bool {
    GameObjectEffectHelper.StartEffectEvent(this.GetOwner(), n"weakspot_compensating");
  }
}
