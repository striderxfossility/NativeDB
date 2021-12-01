
public class WeakspotOnDestroyEffector extends Effector {

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    Log("WeakspotOnDestroyEffector Initialize!");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    Log("WeakspotOnDestroyEffectorOn!");
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    Log("WeakspotOnDestroyEffectorOff");
  }
}

public class WeakspotHealthChangeListener extends CustomValueStatPoolsListener {

  public let m_self: wref<GameObject>;

  private let m_statPoolType: gamedataStatPoolType;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.CheckProgressiveEffect(oldValue, newValue, percToPoints);
  }

  public final func CheckProgressiveEffect(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if oldValue > 70.00 && newValue <= 70.00 {
      GameObject.StartReplicatedEffectEvent(this.m_self.GetOwner(), n"weakspot_damage_stage_01");
    };
    if oldValue > 35.00 && newValue <= 35.00 {
      GameObject.StartReplicatedEffectEvent(this.m_self.GetOwner(), n"weakspot_damage_stage_02");
    };
  }
}

public class ScriptedWeakspotObject extends WeakspotObject {

  protected edit let m_weakspotOnDestroyProperties: WeakspotOnDestroyProperties;

  protected let m_mesh: ref<MeshComponent>;

  protected let m_interaction: ref<InteractionComponent>;

  protected let m_collider: ref<IPlacedComponent>;

  protected let m_instigator: wref<GameObject>;

  protected let m_weakspotRecordData: WeakspotRecordData;

  @default(ScriptedWeakspotObject, true)
  protected let m_alive: Bool;

  @default(ScriptedWeakspotObject, false)
  protected let m_hasBeenScanned: Bool;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  private let m_statPoolType: gamedataStatPoolType;

  private let m_healthListener: ref<WeakspotHealthChangeListener>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"choice", n"InteractionComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ColliderComponent", n"IPlacedComponent", true);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"choice") as InteractionComponent;
    this.m_collider = EntityResolveComponentsInterface.GetComponent(ri, n"ColliderComponent") as IPlacedComponent;
    this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.GetGame());
    let selfGameObject: ref<GameObject> = this;
    if this.m_weakspotOnDestroyProperties.m_useWeakspotDestroyStageVFX {
      this.m_healthListener = new WeakspotHealthChangeListener();
      this.m_healthListener.SetValue(100.00);
      this.m_healthListener.m_self = selfGameObject;
      this.m_statPoolSystem.RequestRegisteringListener(Cast(selfGameObject.GetEntityID()), gamedataStatPoolType.WeakspotHealth, this.m_healthListener);
    };
    super.OnTakeControl(ri);
  }

  protected final func WeakspotInitialized() -> Void {
    this.ResolveWeakspotOnLoad();
  }

  public const func IsDead() -> Bool {
    return GameInstance.GetStatPoolsSystem(this.GetGame()).HasStatPoolValueReachedMin(Cast(this.GetEntityID()), gamedataStatPoolType.WeakspotHealth);
  }

  public final func GetWeakspotRecordData() -> WeakspotRecordData {
    return this.m_weakspotRecordData;
  }

  protected final func ReadTweakData() -> Void {
    this.m_weakspotRecordData.m_slotID = this.GetRecord().SlotToAttach().GetID();
    let tags: array<CName> = this.GetRecord().GameplayTags();
    let i: Int32 = 0;
    while i < ArraySize(tags) {
      if Equals(tags[i], n"Invulnerable") {
        this.m_weakspotRecordData.m_isInvulnerable = true;
      };
      if Equals(tags[i], n"MeleeReduction") {
        this.m_weakspotRecordData.m_reducedMeleeDamage = true;
      };
      i += 1;
    };
  }

  protected cb func OnInteractionChoice(evt: ref<InteractionChoiceEvent>) -> Bool {
    let choiceName: String = evt.choice.choiceMetaData.tweakDBName;
    if !GameInstance.GetRuntimeInfo(this.GetGame()).IsMultiplayer() {
      this.m_instigator = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    } else {
      this.m_instigator = evt.activator;
    };
    if Equals(choiceName, "DestroyWeakspot") && !GameInstance.GetRuntimeInfo(this.GetGame()).IsClient() {
      if GameInstance.GetRuntimeInfo(this.GetGame()).IsMultiplayer() {
        this.SetReplicationInstigator(this.m_instigator);
      };
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestChangingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.WeakspotHealth, 0.00, null, true);
    };
  }

  protected cb func OnScanninOwner(evt: ref<ScanningLookAtEvent>) -> Bool {
    this.OnScanningLookedAt(evt);
    if !this.m_hasBeenScanned {
      this.m_hasBeenScanned = true;
    };
    if !this.IsDead() && Equals(this.m_alive, true) {
      this.SetHighlight();
    };
  }

  protected cb func OnWeakspotPinged(evt: ref<RevealStateChangedEvent>) -> Bool {
    if Equals(evt.state, ERevealState.STARTED) {
      if !this.IsDead() && Equals(this.m_alive, true) {
        this.SetHighlight();
      };
    } else {
      if Equals(evt.state, ERevealState.STOPPED) {
        if !this.IsDead() && Equals(this.m_alive, true) && !this.m_hasBeenScanned {
          this.UnSetHighlight();
        };
      };
    };
  }

  protected cb func OnWeakspotDestroy(evt: ref<WeakspotDestroyedEvent>) -> Bool {
    let weakspotDestroyedDelayEvent: ref<DestroyWeakspotDelayedEvent> = new DestroyWeakspotDelayedEvent();
    if NotEquals(this.m_weakspotOnDestroyProperties.m_addFact, n"") {
      AddFact(this.GetOwner().GetGame(), this.m_weakspotOnDestroyProperties.m_addFact);
    };
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, weakspotDestroyedDelayEvent, this.m_weakspotOnDestroyProperties.m_destroyDelay);
  }

  protected cb func OnWeakspotDestroyDelay(evt: ref<DestroyWeakspotDelayedEvent>) -> Bool {
    this.DestroyWeakspot(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject());
  }

  private final func ResolveWeakspotOnLoad() -> Void {
    let puppetOwner: ref<ScriptedPuppet> = this.GetOwner() as ScriptedPuppet;
    if IsDefined(puppetOwner) && puppetOwner.IsIncapacitated() {
      this.DestroyWeakspotOnLoad(GetPlayer(this.GetGame()));
    } else {
      this.ScheduleAppearanceChange(n"whole");
      HitShapeUserDataBase.EnableHitShape(this, n"body", false);
      HitShapeUserDataBase.DisableHitShape(this, n"body_destroyed", false);
    };
  }

  public final func DestroyWeakspot(opt instigator: wref<GameObject>) -> Void {
    let player: ref<GameObject>;
    let weakspotDestroyed: ref<WeakspotOnDestroyEvent>;
    if IsDefined(instigator) {
      this.m_instigator = instigator;
    };
    if this.m_weakspotOnDestroyProperties.m_disableCollider {
      this.DisableCollider();
    };
    if this.m_weakspotOnDestroyProperties.m_destroyMesh {
      this.ChangeAppearance(n"destroyed");
    };
    if this.m_weakspotOnDestroyProperties.m_disableInteraction {
      this.m_interaction.Toggle(false);
    };
    if NotEquals(this.m_weakspotOnDestroyProperties.m_hideMeshParameterValue, n"") {
      this.SendHideMeshParameterValue(this.m_weakspotOnDestroyProperties.m_hideMeshParameterValue);
    };
    if NotEquals(this.m_weakspotOnDestroyProperties.m_sendAIActionAnimFeatureName, n"") {
      this.SendAIActionAnimFeature(this.m_weakspotOnDestroyProperties.m_sendAIActionAnimFeatureName, this.m_weakspotOnDestroyProperties.m_sendAIActionAnimFeatureState);
    };
    if TDBID.IsValid(this.m_weakspotOnDestroyProperties.m_attackRecordID) {
      this.FireAttack();
    };
    if TDBID.IsValid(this.m_weakspotOnDestroyProperties.m_StatusEffectOnDestroyID) {
      StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), this.m_weakspotOnDestroyProperties.m_StatusEffectOnDestroyID, this.GetOwner().GetEntityID());
    };
    HitShapeUserDataBase.DisableHitShape(this, n"body", false);
    HitShapeUserDataBase.EnableHitShape(this, n"body_destroyed", false);
    if this.m_weakspotOnDestroyProperties.m_useWeakspotDestroyStageVFX {
      GameObject.BreakReplicatedEffectLoopEvent(this.GetOwner(), n"weakspot_damage_stage_01");
      GameObject.BreakReplicatedEffectLoopEvent(this.GetOwner(), n"weakspot_damage_stage_02");
    };
    if !this.m_weakspotOnDestroyProperties.m_playDestroyedFxFromOwnerEntity {
      GameObjectEffectHelper.StartEffectEvent(this, n"weakspot_destroyed");
    } else {
      GameObjectEffectHelper.StartEffectEvent(this.GetOwner(), n"weakspot_destroyed");
    };
    if !this.m_weakspotOnDestroyProperties.m_playBrokenFxFromOwnerEntity {
      GameObjectEffectHelper.StartEffectEvent(this, n"weakspot_broken");
    } else {
      GameObjectEffectHelper.StartEffectEvent(this.GetOwner(), n"weakspot_broken");
    };
    GameObjectEffectHelper.BreakEffectLoopEvent(this.GetOwner(), n"weakspot_indicator");
    weakspotDestroyed = new WeakspotOnDestroyEvent();
    weakspotDestroyed.weakspotRecordData = this.m_weakspotRecordData;
    this.GetOwner().QueueEvent(weakspotDestroyed);
    this.UnSetHighlight();
    player = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    TargetTrackingExtension.InjectThreat(this.GetOwner() as ScriptedPuppet, player);
    this.m_alive = false;
  }

  public final func DestroyWeakspotOnLoad(opt instigator: wref<GameObject>) -> Void {
    let player: ref<GameObject>;
    let weakspotDestroyed: ref<WeakspotOnDestroyEvent>;
    if IsDefined(instigator) {
      this.m_instigator = instigator;
    };
    if this.m_weakspotOnDestroyProperties.m_disableCollider {
      this.DisableCollider();
    };
    if this.m_weakspotOnDestroyProperties.m_destroyMesh {
      this.ChangeAppearance(n"destroyed");
    };
    if this.m_weakspotOnDestroyProperties.m_disableInteraction {
      this.m_interaction.Toggle(false);
    };
    if NotEquals(this.m_weakspotOnDestroyProperties.m_hideMeshParameterValue, n"") {
      this.SendHideMeshParameterValue(this.m_weakspotOnDestroyProperties.m_hideMeshParameterValue);
    };
    if NotEquals(this.m_weakspotOnDestroyProperties.m_sendAIActionAnimFeatureName, n"") {
      this.SendAIActionAnimFeature(this.m_weakspotOnDestroyProperties.m_sendAIActionAnimFeatureName, this.m_weakspotOnDestroyProperties.m_sendAIActionAnimFeatureState);
    };
    if TDBID.IsValid(this.m_weakspotOnDestroyProperties.m_StatusEffectOnDestroyID) {
      StatusEffectHelper.ApplyStatusEffect(this.GetOwner(), this.m_weakspotOnDestroyProperties.m_StatusEffectOnDestroyID, this.GetOwner().GetEntityID());
    };
    HitShapeUserDataBase.DisableHitShape(this, n"body", false);
    HitShapeUserDataBase.EnableHitShape(this, n"body_destroyed", false);
    GameObjectEffectHelper.BreakEffectLoopEvent(this.GetOwner(), n"weakspot_indicator");
    weakspotDestroyed = new WeakspotOnDestroyEvent();
    weakspotDestroyed.weakspotRecordData = this.m_weakspotRecordData;
    this.GetOwner().QueueEvent(weakspotDestroyed);
    this.UnSetHighlight();
    player = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    TargetTrackingExtension.InjectThreat(this.GetOwner() as ScriptedPuppet, player);
    if NotEquals(this.m_weakspotOnDestroyProperties.m_addFact, n"") {
      AddFact(this.GetOwner().GetGame(), this.m_weakspotOnDestroyProperties.m_addFact);
    };
    this.m_alive = false;
  }

  protected final func SendHideMeshParameterValue(parameterName: CName) -> Void {
    let evt: ref<AnimParamsEvent> = new AnimParamsEvent();
    evt.PushParameterValue(parameterName, 0.00);
    this.GetOwner().QueueEvent(evt);
  }

  public final static func Kill(weakspot: wref<GameObject>, opt instigator: wref<GameObject>) -> Void {
    if !IsDefined(weakspot) {
      return;
    };
    GameInstance.GetStatPoolsSystem(weakspot.GetGame()).RequestSettingStatPoolValue(Cast(weakspot.GetEntityID()), gamedataStatPoolType.WeakspotHealth, 0.00, instigator, true);
  }

  protected final func ChangeAppearance(appName: CName) -> Void {
    this.ScheduleAppearanceChange(appName);
  }

  protected final func DisableCollider() -> Void {
    this.m_collider.Toggle(false);
  }

  protected final func SendAIActionAnimFeature(animFeatureName: CName, value: Int32) -> Void {
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = value;
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), animFeatureName, animFeature);
  }

  public final func FireAttack() -> Void {
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let weakspotAttack: ref<Attack_GameEffect>;
    flag.flag = hitFlag.FriendlyFire;
    flag.source = n"WeakspotAttack";
    ArrayPush(hitFlags, flag);
    if GameInstance.GetRuntimeInfo(this.GetGame()).IsMultiplayer() && !IsDefined(this.m_instigator) {
      this.m_instigator = this.GetReplicationInstigator();
    };
    weakspotAttack = RPGManager.PrepareGameEffectAttack(this.GetGame(), this.m_instigator, this, this.m_weakspotOnDestroyProperties.m_attackRecordID, hitFlags);
    weakspotAttack.StartAttack();
  }

  public final func SetHighlight() -> Void {
    let highlightData: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlightData.sourceID = this.GetOwner().GetEntityID();
    highlightData.sourceName = this.GetOwner().GetClassName();
    highlightData.outlineType = EFocusOutlineType.WEAKSPOT;
    highlightData.highlightType = EFocusForcedHighlightType.WEAKSPOT;
    highlightData.priority = EPriority.VeryHigh;
    highlightData.inTransitionTime = 0.20;
    highlightData.outTransitionTime = 0.20;
    highlightData.patternType = VisionModePatternType.Netrunner;
    GameObject.ForceVisionAppearance(this, highlightData);
  }

  public final func UnSetHighlight() -> Void {
    let highlightData: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlightData.sourceID = this.GetOwner().GetEntityID();
    highlightData.sourceName = this.GetOwner().GetClassName();
    highlightData.outlineType = EFocusOutlineType.WEAKSPOT;
    highlightData.highlightType = EFocusForcedHighlightType.WEAKSPOT;
    highlightData.priority = EPriority.VeryHigh;
    highlightData.inTransitionTime = 0.20;
    highlightData.outTransitionTime = 0.20;
    highlightData.patternType = VisionModePatternType.Netrunner;
    this.CancelForcedVisionAppearance(highlightData);
  }

  protected func ProcessDamagePipeline(evt: ref<gameHitEvent>) -> Void {
    this.ReadTweakData();
    this.m_instigator = evt.attackData.GetInstigator();
    if !this.IsDead() {
      if !this.m_weakspotOnDestroyProperties.m_playHitFxFromOwnerEntity {
        GameObjectEffectHelper.StartEffectEvent(this, n"weakspot_hit");
      } else {
        GameObjectEffectHelper.StartEffectEvent(this.GetOwner(), n"weakspot_hit");
      };
    };
    if this.m_weakspotRecordData.m_isInvulnerable || this.m_instigator == this.GetOwner() {
      evt.attackData.AddFlag(hitFlag.DealNoDamage, n"invulnerable");
    };
    if this.m_weakspotOnDestroyProperties.m_isInternal {
      evt.target = this.GetOwner();
    };
    if AttackData.IsMelee(evt.attackData.GetAttackType()) && this.m_weakspotRecordData.m_reducedMeleeDamage {
      evt.attackData.AddFlag(hitFlag.ReduceDamage, n"MeleeAttack");
    };
    this.ProcessDamagePipeline(evt);
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let owner: wref<GameObject> = this.GetOwner();
    if IsDefined(owner) && NotEquals(GameObject.GetAttitudeTowards(owner, evt.attackData.GetInstigator()), EAIAttitude.AIA_Friendly) {
      super.OnHit(evt);
    };
  }
}
