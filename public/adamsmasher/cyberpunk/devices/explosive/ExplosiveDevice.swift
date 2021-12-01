
public class ExplosiveDevice extends BasicDistractionDevice {

  @default(ExplosiveDevice, 0)
  protected edit let m_numberOfComponentsToON: Int32;

  @default(ExplosiveDevice, 0)
  protected edit let m_numberOfComponentsToOFF: Int32;

  protected edit const let m_indexesOfComponentsToOFF: array<Int32>;

  protected edit let m_shouldDistractionEnableCollider: Bool;

  protected edit let m_shouldDistractionVFXstay: Bool;

  @attrib(customEditor, "AudioEvent")
  protected edit let m_loopAudioEvent: CName;

  protected let m_spawnedFxInstancesToKill: array<ref<FxInstance>>;

  public let m_mesh: ref<MeshComponent>;

  public let m_collider: ref<IPlacedComponent>;

  public let m_distractionCollider: ref<IPlacedComponent>;

  private let m_numberOfReceivedHits: Int32;

  private let m_devicePenetrationHealth: Float;

  private let m_killedByExplosion: Bool;

  private let m_distractionTimeStart: Float;

  private let m_isBroadcastingEnvironmentalHazardStim: Bool;

  private let m_componentsON: array<ref<IPlacedComponent>>;

  private let m_componentsOFF: array<ref<IPlacedComponent>>;

  protected cb func OnPostInitialize(evt: ref<entPostInitializeEvent>) -> Bool {
    let dataArray: array<ExplosiveDeviceResourceDefinition>;
    let effectSystem: ref<EffectSystem>;
    let i: Int32;
    super.OnPostInitialize(evt);
    effectSystem = GameInstance.GetGameEffectSystem(this.GetGame());
    dataArray = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
    i = 0;
    while i < ArraySize(dataArray) {
      PreloadGameEffectAttackResources(TweakDBInterface.GetAttackRecord(dataArray[i].damageType) as Attack_GameEffect_Record, effectSystem);
      i += 1;
    };
  }

  protected cb func OnPreUninitialize(evt: ref<entPreUninitializeEvent>) -> Bool {
    let dataArray: array<ExplosiveDeviceResourceDefinition>;
    let effectSystem: ref<EffectSystem>;
    let i: Int32;
    super.OnPreUninitialize(evt);
    effectSystem = GameInstance.GetGameEffectSystem(this.GetGame());
    dataArray = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
    i = 0;
    while i < ArraySize(dataArray) {
      ReleaseGameEffectAttackResources(TweakDBInterface.GetAttackRecord(dataArray[i].damageType) as Attack_GameEffect_Record, effectSystem);
      i += 1;
    };
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let componentName: String;
    let i: Int32;
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"collider", n"IPlacedComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"distractionCollider", n"IPlacedComponent", false);
    i = 0;
    while i < this.m_numberOfComponentsToON {
      componentName = "componentON_" + i;
      EntityRequestComponentsInterface.RequestComponent(ri, StringToName(componentName), n"IPlacedComponent", true);
      i += 1;
    };
    i = 0;
    while i < this.m_numberOfComponentsToOFF {
      componentName = "componentOFF_" + i;
      EntityRequestComponentsInterface.RequestComponent(ri, StringToName(componentName), n"IPlacedComponent", true);
      i += 1;
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let componentName: String;
    this.m_mesh = EntityResolveComponentsInterface.GetComponent(ri, n"mesh") as MeshComponent;
    this.m_collider = EntityResolveComponentsInterface.GetComponent(ri, n"collider") as IPlacedComponent;
    this.m_distractionCollider = EntityResolveComponentsInterface.GetComponent(ri, n"distractionCollider") as IPlacedComponent;
    let i: Int32 = 0;
    while i < this.m_numberOfComponentsToON {
      componentName = "componentON_" + i;
      ArrayPush(this.m_componentsON, EntityResolveComponentsInterface.GetComponent(ri, StringToName(componentName)) as IPlacedComponent);
      i += 1;
    };
    i = 0;
    while i < this.m_numberOfComponentsToOFF {
      componentName = "componentOFF_" + i;
      ArrayPush(this.m_componentsOFF, EntityResolveComponentsInterface.GetComponent(ri, StringToName(componentName)) as IPlacedComponent);
      i += 1;
    };
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ExplosiveDeviceController;
  }

  protected func ResolveGameplayState() -> Void {
    let dataArray: array<ExplosiveDeviceResourceDefinition>;
    let i: Int32;
    let lightEvent: ref<ChangeLightEvent>;
    if (this.GetDevicePS() as ExplosiveDeviceControllerPS).DoExplosiveResolveGameplayLogic() {
      if !(this.GetDevicePS() as ExplosiveDeviceControllerPS).IsExploded() {
        lightEvent = new ChangeLightEvent();
        lightEvent.settings.strength = 1.00;
        lightEvent.settings.color = new Color(255u, 0u, 0u, 0u);
        dataArray = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
        i = 0;
        while i < ArraySize(dataArray) {
          this.m_fxResourceMapper.CreateEffectStructDataFromAttack(dataArray[i].damageType, i, n"inRange_explosive_device", dataArray[i].dontHighlightOnLookat);
          i += 1;
        };
        this.m_devicePenetrationHealth = GameInstance.GetStatsSystem(this.GetDevicePS().GetGameInstance()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.PenetrationHealth);
        this.QueueEvent(lightEvent);
      } else {
        this.ToggleVisibility(false);
      };
    };
    this.ResolveGameplayState();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    super.OnDeath(evt);
    this.EffectsOnStartStop();
    if IsDefined(this.m_distractionCollider) {
      this.m_distractionCollider.Toggle(false);
    };
    if this.m_killedByExplosion {
      this.StartExplosionPipeline(evt.instigator, 0.05);
    } else {
      this.StartExplosionPipeline(evt.instigator);
    };
    this.RemoveEnvironmentalHazardStimuli();
  }

  protected final const func GetAttackRange(attackTDBID: TweakDBID) -> Float {
    return TweakDBInterface.GetAttackRecord(attackTDBID).Range();
  }

  protected final func StartExplosionPipeline(instigator: wref<GameObject>, opt additionalDelays: Float) -> Void {
    let dataArray: array<ExplosiveDeviceResourceDefinition>;
    let evt: ref<ExplosiveDeviceDelayedEvent>;
    let hideEvt: ref<ExplosiveDeviceHideDeviceEvent>;
    let i: Int32;
    let largestDelayTime: Float;
    let lightEvent: ref<ChangeLightEvent>;
    if (this.GetDevicePS() as ExplosiveDeviceControllerPS).IsExploded() {
      return;
    };
    lightEvent = new ChangeLightEvent();
    lightEvent.settings.strength = 0.00;
    lightEvent.settings.color = new Color(0u, 0u, 0u, 0u);
    dataArray = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
    i = 0;
    while i < ArraySize(dataArray) {
      if dataArray[i].executionDelay + additionalDelays > 0.00 {
        evt = new ExplosiveDeviceDelayedEvent();
        evt.arrayIndex = i;
        evt.instigator = instigator;
        if dataArray[i].executionDelay + additionalDelays > largestDelayTime {
          largestDelayTime = dataArray[i].executionDelay + additionalDelays;
        };
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, dataArray[i].executionDelay + additionalDelays);
      } else {
        this.Explode(i, instigator);
      };
      i += 1;
    };
    if largestDelayTime > 0.00 {
      hideEvt = new ExplosiveDeviceHideDeviceEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, hideEvt, largestDelayTime);
    } else {
      this.SendSwapMeshDelayedEvent((this.GetDevicePS() as ExplosiveDeviceControllerPS).GetTimeToMeshSwap());
    };
    this.QueueEvent(lightEvent);
  }

  protected cb func OnExplosiveDeviceDelayedEvent(evt: ref<ExplosiveDeviceDelayedEvent>) -> Bool {
    this.Explode(evt.arrayIndex, evt.instigator);
  }

  private final func Explode(index: Int32, instigator: wref<GameObject>) -> Void {
    let dataArray: array<ExplosiveDeviceResourceDefinition> = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
    this.DoAttack(dataArray[index].damageType, instigator);
    this.DoPhysicsPulse(dataArray[index].damageType);
    this.KillAllFxInstances();
    this.EffectsOnStartStop(true);
    if !this.SpawnVFXs(dataArray[index].vfxEventNamesOnExplosion) {
      this.SpawnVFXs(dataArray[index].vfxResource);
    };
    if NotEquals(this.m_loopAudioEvent, n"") {
      GameObject.StopSoundEvent(this, this.m_loopAudioEvent);
    };
    this.Explosion(index);
    this.DoAdditionalGameEffect(dataArray[index].additionalGameEffectType);
    (this.GetDevicePS() as ExplosiveDeviceControllerPS).SetExplodedState(true);
  }

  private final func DoPhysicsPulse(damageType: TweakDBID) -> Void {
    let impulseRadius: Float = this.GetAttackRange(damageType);
    CombatGadgetHelper.SpawnPhysicalImpulse(this, impulseRadius);
  }

  private final func Explosion(index: Int32) -> Void {
    let distractionName: CName = StringToName("hardCodeDoNotRemoveExplosion" + index);
    let i: Int32 = 0;
    while i < this.GetFxResourceMapper().GetAreaEffectDataSize() {
      if Equals(this.GetFxResourceMapper().GetAreaEffectDataByIndex(i).areaEffectID, distractionName) {
        this.TriggerArreaEffectDistraction(this.GetFxResourceMapper().GetAreaEffectDataByIndex(i));
      } else {
        i += 1;
      };
    };
  }

  protected cb func OnExplosiveDeviceHideDeviceEvent(evt: ref<ExplosiveDeviceHideDeviceEvent>) -> Bool {
    this.SendSwapMeshDelayedEvent((this.GetDevicePS() as ExplosiveDeviceControllerPS).GetTimeToMeshSwap());
  }

  private final func DoAttack(damageType: TweakDBID, opt instigator: wref<GameObject>) -> Void {
    let attack: ref<Attack_GameEffect>;
    let attackPosition: Vector4;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let quickhackFlag: SHitFlag;
    let roleMappinTransform: WorldTransform;
    flag.source = n"ExplosiveDevice";
    if !instigator.IsPlayer() {
      flag.flag = hitFlag.FriendlyFire;
    } else {
      quickhackFlag.source = n"ExplosiveDevice";
      quickhackFlag.flag = hitFlag.QuickHack;
      ArrayPush(hitFlags, quickhackFlag);
    };
    ArrayPush(hitFlags, flag);
    if IsDefined(this.GetUISlotComponent()) && this.GetUISlotComponent().GetSlotTransform(n"roleMappin", roleMappinTransform) {
      attackPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(roleMappinTransform));
    } else {
      attackPosition = this.GetWorldPosition();
    };
    attack = RPGManager.PrepareGameEffectAttack(this.GetGame(), IsDefined(instigator) ? instigator : this, this, damageType, attackPosition, hitFlags);
    if IsDefined(attack) {
      attack.StartAttack();
    };
  }

  private final func DoAdditionalGameEffect(additionalGameEffect: EExplosiveAdditionalGameEffectType) -> Void {
    switch additionalGameEffect {
      case EExplosiveAdditionalGameEffectType.EMP:
        this.CreateEMPGameEffect(10.00);
        this.KillNPCWorkspotUser(1.00);
        break;
      default:
    };
  }

  protected func ToggleVisibility(visible: Bool) -> Void {
    let i: Int32;
    this.m_mesh.Toggle(visible);
    this.m_collider.Toggle(visible);
    i = 0;
    while i < this.m_numberOfComponentsToON {
      this.m_componentsON[i].Toggle(!visible);
      i += 1;
    };
    i = 0;
    while i < this.m_numberOfComponentsToOFF {
      this.m_componentsOFF[i].Toggle(visible);
      i += 1;
    };
    this.SetGameplayRoleToNone();
    this.GetDevicePS().ForceDisableDevice();
  }

  protected final func SendSwapMeshDelayedEvent(delay: Float) -> Void {
    let evt: ref<SwapMeshDelayedEvent> = new SwapMeshDelayedEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, delay);
  }

  protected cb func OnSwapMeshDelayedEvent(evt: ref<SwapMeshDelayedEvent>) -> Bool {
    this.ToggleVisibility(false);
  }

  protected final func KillAllFxInstances() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_spawnedFxInstancesToKill) {
      this.m_spawnedFxInstancesToKill[i].Kill();
      i += 1;
    };
  }

  private final func SpawnVFXs(fxEventName: array<CName>) -> Bool {
    let i: Int32;
    if ArraySize(fxEventName) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(fxEventName) {
      GameObjectEffectHelper.StartEffectEvent(this, fxEventName[i]);
      i += 1;
    };
    return true;
  }

  private final func SpawnVFXs(fx: FxResource, opt newPosition: Vector4, opt hitDirection: Vector4) -> Void {
    let angle: EulerAngles;
    let fxInstance: ref<FxInstance>;
    let position: WorldPosition;
    let transform: WorldTransform;
    if FxResource.IsValid(fx) {
      if !Vector4.IsZero(newPosition) {
        WorldPosition.SetVector4(position, newPosition);
      } else {
        WorldPosition.SetVector4(position, this.GetWorldPosition());
      };
      WorldTransform.SetWorldPosition(transform, position);
      if !Vector4.IsZero(newPosition) {
        WorldTransform.SetOrientationFromDir(transform, hitDirection);
        angle = Quaternion.ToEulerAngles(WorldTransform.GetOrientation(transform));
        angle.Yaw = angle.Yaw - 90.00;
        WorldTransform.SetOrientationEuler(transform, angle);
      };
      fxInstance = this.CreateFxInstance(fx, transform);
      ArrayPush(this.m_spawnedFxInstancesToKill, fxInstance);
    };
  }

  private final func CreateFxInstance(resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(this.GetGame());
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }

  protected cb func OnSpiderbotExplodeExplosiveDevicePerformed(evt: ref<SpiderbotExplodeExplosiveDevicePerformed>) -> Bool {
    this.StartExplosionPipeline(this, 4.00);
  }

  protected cb func OnSpiderbotDistractExplosiveDevicePerformed(evt: ref<SpiderbotDistractExplosiveDevicePerformed>) -> Bool {
    this.Explosion(0);
  }

  protected cb func OnQuestForceDetonate(evt: ref<QuestForceDetonate>) -> Bool {
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, 0.00, this, false);
    this.StartExplosionPipeline(this);
  }

  protected cb func OnForceDetonate(evt: ref<ForceDetonate>) -> Bool {
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, 0.00, this, false);
    this.StartExplosionPipeline(this);
  }

  protected cb func OnQuickHackExplodeExplosive(evt: ref<QuickHackExplodeExplosive>) -> Bool {
    this.StartExplosionPipeline(this.GetPlayerMainObject());
  }

  protected cb func OnQuickHackDistractExplosive(evt: ref<QuickHackDistractExplosive>) -> Bool {
    this.Explosion(0);
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.ToggleLightsON_OFF(false);
    this.ToggleComponentsON_OFF(false);
    if NotEquals(this.m_loopAudioEvent, n"") {
      GameObject.StopSoundEvent(this, this.m_loopAudioEvent);
    };
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.ToggleLightsON_OFF(true);
    this.ToggleComponentsON_OFF(true);
    if NotEquals(this.m_loopAudioEvent, n"") {
      GameObject.PlaySoundEvent(this, this.m_loopAudioEvent);
    };
  }

  protected final func ToggleComponentsON_OFF(visible: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_indexesOfComponentsToOFF) {
      this.m_componentsOFF[this.m_indexesOfComponentsToOFF[i]].Toggle(visible);
      i += 1;
    };
  }

  protected final func ToggleLightsON_OFF(on: Bool) -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = on;
    this.QueueEvent(evt);
  }

  protected func StartDistraction(opt loopAnimation: Bool) -> Void {
    this.StartDistraction(loopAnimation);
    if IsDefined(this.m_distractionCollider) {
      this.m_distractionCollider.Toggle(true);
    };
    this.m_distractionTimeStart = GameInstance.GetTimeSystem(this.GetGame()).GetGameTimeStamp();
  }

  protected func StopDistraction() -> Void {
    if !this.m_shouldDistractionVFXstay {
      this.StopDistraction();
    } else {
      this.StopDistractAnimation();
      this.MeshSwapOnDistraction(false);
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ExplodeLethal;
  }

  public const func DeterminGameplayRoleMappinRange(data: SDeviceMappinData) -> Float {
    let biggestRange: Float;
    let currentResolve: Float;
    let dataArray: array<ExplosiveDeviceResourceDefinition> = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
    let i: Int32 = 0;
    while i < ArraySize(dataArray) {
      currentResolve = this.GetAttackRange(dataArray[i].damageType);
      if currentResolve > biggestRange {
        biggestRange = currentResolve;
      };
      i += 1;
    };
    return biggestRange;
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let dataArray: array<ExplosiveDeviceResourceDefinition> = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
    let devicePosition: Vector4 = this.GetWorldPosition();
    let oilGrowthRatePerSecond: Float = 0.04;
    let curTime: Float = GameInstance.GetTimeSystem(this.GetGame()).GetGameTimeStamp();
    let endRadius: Float = 1.80;
    let curRadius: Float = oilGrowthRatePerSecond * (curTime - this.m_distractionTimeStart);
    if Equals(evt.attackData.GetAttackType(), gamedataAttackType.QuickMelee) {
      return true;
    };
    if this.m_distractionCollider != evt.hitComponent || Equals(evt.attackData.GetAttackType(), gamedataAttackType.Explosion) {
      super.OnHit(evt);
    } else {
      if this.m_distractionCollider == evt.hitComponent && ArraySize(dataArray) > 0 {
        if curRadius < endRadius && Vector4.Length2D(evt.hitPosition - devicePosition) < curRadius || curRadius >= endRadius {
          if (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetHealthDecay() > 0.00 {
            this.InitializeHealthDecay((this.GetDevicePS() as ExplosiveDeviceControllerPS).GetHealthDecay(), 0.00);
            if (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetDistractionHitVFXIgnoreHitPosition() {
              this.SpawnVFXs(dataArray[0].vfxResourceOnFirstHit[1]);
            } else {
              this.SpawnVFXs(dataArray[0].vfxResourceOnFirstHit[1], evt.hitPosition, evt.hitDirection);
            };
            this.BroadcastEnvironmentalHazardStimuli();
          };
        };
      };
    };
  }

  protected cb func OnDamageReceived(evt: ref<gameDamageReceivedEvent>) -> Bool {
    let attackPenetration: Float;
    let dataArray: array<ExplosiveDeviceResourceDefinition> = (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetExplosionDefinitionArray();
    let weaponObject: ref<WeaponObject> = evt.hitEvent.attackData.GetWeapon();
    let deviceID: EntityID = this.GetEntityID();
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    if IsDefined(weaponObject) {
      attackPenetration = GameInstance.GetStatsSystem(weaponObject.GetGame()).GetStatValue(Cast(weaponObject.GetEntityID()), gamedataStatType.AttackPenetration) + 1.00;
    };
    if ArraySize(dataArray) > 0 {
      if AttackData.IsMelee(evt.hitEvent.attackData.GetAttackType()) && !evt.hitEvent.attackData.GetInstigator().IsPlayer() {
        return false;
      };
      this.m_devicePenetrationHealth = MaxF(this.m_devicePenetrationHealth - attackPenetration, 0.00);
      if AttackData.IsExplosion(evt.hitEvent.attackData.GetAttackType()) {
        statPoolsSystem.RequestSettingStatPoolValue(Cast(deviceID), gamedataStatPoolType.Health, 0.00, evt.hitEvent.attackData.GetInstigator());
        this.m_killedByExplosion = true;
        this.StopDistraction();
        super.OnDamageReceived(evt);
      } else {
        if this.m_devicePenetrationHealth <= 0.00 {
          statPoolsSystem.RequestSettingStatPoolValue(Cast(deviceID), gamedataStatPoolType.Health, 0.00, evt.hitEvent.attackData.GetInstigator());
          this.StopDistraction();
          super.OnDamageReceived(evt);
        };
      };
      if (this.GetDevicePS() as ExplosiveDeviceControllerPS).GetHealthDecay() > 0.00 {
        this.SpawnVFXs(dataArray[0].vfxResourceOnFirstHit[0], evt.hitEvent.hitPosition, evt.hitEvent.hitDirection);
        this.InitializeHealthDecay((this.GetDevicePS() as ExplosiveDeviceControllerPS).GetHealthDecay(), 0.00);
        super.OnDamageReceived(evt);
        this.BroadcastEnvironmentalHazardStimuli();
      };
    };
  }

  private final func InitializeHealthDecay(health: Float, delay: Float) -> Void {
    let modifier: StatPoolModifier;
    modifier.enabled = true;
    modifier.rangeBegin = 0.00;
    modifier.rangeEnd = 100.00;
    modifier.startDelay = delay;
    modifier.valuePerSec = health;
    modifier.delayOnChange = false;
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingModifier(Cast(this.GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Decay, modifier);
  }

  private final func BroadcastEnvironmentalHazardStimuli() -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if !this.m_isBroadcastingEnvironmentalHazardStim {
      broadcaster.AddActiveStimuli(this, gamedataStimType.EnvironmentalHazard, 2.00);
      this.m_isBroadcastingEnvironmentalHazardStim = true;
    };
  }

  private final func RemoveEnvironmentalHazardStimuli() -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if this.m_isBroadcastingEnvironmentalHazardStim {
      broadcaster.RemoveActiveStimuliByName(this, gamedataStimType.EnvironmentalHazard);
      this.m_isBroadcastingEnvironmentalHazardStim = false;
    };
  }

  public const func IsExplosive() -> Bool {
    return true;
  }

  public const func CanOverrideNetworkContext() -> Bool {
    if (this.GetDevicePS() as ExplosiveDeviceControllerPS).IsExplosiveWithQhacks() {
      return this.CanOverrideNetworkContext();
    };
    return NotEquals(this.GetCurrentGameplayRole(), IntEnum(1l));
  }

  public const func HasImportantInteraction() -> Bool {
    return this.HasImportantInteraction();
  }

  protected const func HasAnyDirectInteractionActive() -> Bool {
    if this.IsDead() {
      return false;
    };
    return true;
  }

  public const func GetCurrentOutline() -> EFocusOutlineType {
    let outlineType: EFocusOutlineType;
    if this.IsQuest() {
      outlineType = EFocusOutlineType.QUEST;
    } else {
      if !(this.GetDevicePS() as ExplosiveDeviceControllerPS).IsExploded() {
        outlineType = EFocusOutlineType.HOSTILE;
      } else {
        outlineType = EFocusOutlineType.INVALID;
      };
    };
    return outlineType;
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    let outline: EFocusOutlineType;
    if this.GetDevicePS().IsDisabled() {
      return null;
    };
    if Equals(this.GetCurrentGameplayRole(), IntEnum(1l)) || Equals(this.GetCurrentGameplayRole(), EGameplayRole.Clue) {
      return null;
    };
    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked() {
      return null;
    };
    outline = this.GetCurrentOutline();
    highlight = new FocusForcedHighlightData();
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();
    highlight.priority = EPriority.Low;
    highlight.outlineType = outline;
    if Equals(outline, EFocusOutlineType.QUEST) {
      highlight.highlightType = EFocusForcedHighlightType.QUEST;
    } else {
      if Equals(outline, EFocusOutlineType.HOSTILE) {
        highlight.highlightType = EFocusForcedHighlightType.HOSTILE;
      } else {
        highlight = null;
      };
    };
    if highlight != null {
      if this.IsNetrunner() && NotEquals(highlight.outlineType, EFocusOutlineType.NEUTRAL) {
        highlight.patternType = VisionModePatternType.Netrunner;
      } else {
        highlight.patternType = VisionModePatternType.Default;
      };
    };
    return highlight;
  }
}
