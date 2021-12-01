
public class DisposalDevice extends InteractiveDevice {

  protected let m_additionalMeshComponent: ref<MeshComponent>;

  protected let m_npcBody: wref<NPCPuppet>;

  protected let m_playerStateMachineBlackboard: wref<IBlackboard>;

  protected edit const let m_sideTriggerNames: array<CName>;

  protected let m_triggerComponents: array<ref<TriggerComponent>>;

  @default(DisposalDevice, disposalSyncSide1)
  protected let m_currentDisposalSyncName: CName;

  @default(DisposalDevice, killSyncSide1)
  protected let m_currentKillSyncName: CName;

  protected let m_isNonlethal: Bool;

  protected const let m_physicalMeshNames: array<CName>;

  protected let m_physicalMeshes: array<ref<PhysicalMeshComponent>>;

  @default(DisposalDevice, 0.2f)
  protected let m_lethalTakedownKillDelay: Float;

  protected const let m_lethalTakedownComponentNames: array<CName>;

  protected let m_lethalTakedownComponents: array<ref<IPlacedComponent>>;

  protected let m_isReactToHit: Bool;

  @default(DisposalDevice, v_car_thorton_galena_horn)
  protected let m_distractionSoundName: CName;

  @default(DisposalDevice, 0.01f)
  protected let m_workspotDuration: Float;

  private let m_OnTakedownChangedCallback: ref<CallbackHandle>;

  private let m_OnCarryingChangedCallback: ref<CallbackHandle>;

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32;
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"additionalMesh", n"MeshComponent", false);
    i = 0;
    while i < ArraySize(this.m_physicalMeshNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_physicalMeshNames[i], n"PhysicalMeshComponent", true);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_lethalTakedownComponentNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_lethalTakedownComponentNames[i], n"IPlacedComponent", true);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_sideTriggerNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_sideTriggerNames[i], n"TriggerComponent", true);
      i += 1;
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let i: Int32;
    super.OnTakeControl(ri);
    this.m_additionalMeshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"additionalMesh") as MeshComponent;
    i = 0;
    while i < ArraySize(this.m_physicalMeshNames) {
      ArrayPush(this.m_physicalMeshes, EntityResolveComponentsInterface.GetComponent(ri, this.m_physicalMeshNames[i]) as PhysicalMeshComponent);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_lethalTakedownComponentNames) {
      ArrayPush(this.m_lethalTakedownComponents, EntityResolveComponentsInterface.GetComponent(ri, this.m_lethalTakedownComponentNames[i]) as IPlacedComponent);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_sideTriggerNames) {
      ArrayPush(this.m_triggerComponents, EntityResolveComponentsInterface.GetComponent(ri, this.m_sideTriggerNames[i]) as TriggerComponent);
      i += 1;
    };
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as DisposalDeviceController;
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void {
    this.OnMaraudersMapDeviceDebug(sink);
    sink.PushInt32("Number of uses", (this.GetDevicePS() as DisposalDeviceControllerPS).GetNumberOfUses());
    sink.PushBool("Was Activated", (this.GetDevicePS() as DisposalDeviceControllerPS).WasActivated());
    sink.PushBool("Has Distract", (this.GetDevicePS() as DisposalDeviceControllerPS).HasQuickHackDistraction());
    sink.PushFloat("Distract Range", (this.GetDevicePS() as DisposalDeviceControllerPS).GetStimuliRange());
  }

  protected func ResolveGameplayState() -> Void {
    let playerPuppet: ref<PlayerPuppet>;
    this.ResolveGameplayState();
    playerPuppet = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    this.m_playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(this.m_playerStateMachineBlackboard) {
      this.m_OnTakedownChangedCallback = this.m_playerStateMachineBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown, this, n"OnTakedownChanged");
      this.m_OnCarryingChangedCallback = this.m_playerStateMachineBlackboard.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying, this, n"OnCarryingChanged");
    };
    if (this.GetDevicePS() as DisposalDeviceControllerPS).GetNumberOfUses() <= 0 && !(this.GetDevicePS() as DisposalDeviceControllerPS).HasQuickHackDistraction() {
      this.InitializeAlreadyUsedDevice();
    };
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if (this.GetDevicePS() as DisposalDeviceControllerPS).WasLethalTakedownPerformed() {
      this.EnableLethalTakedownComponents();
    };
    this.UpdateLightAppearance();
  }

  protected cb func OnTakedownChanged(value: Int32) -> Bool {
    this.SendRefreshInteractionEvent();
  }

  protected cb func OnCarryingChanged(value: Bool) -> Bool {
    this.SendRefreshInteractionEvent();
  }

  protected cb func OnDistraction(evt: ref<Distraction>) -> Bool;

  protected cb func OnSpiderbotDistractionPerformed(evt: ref<SpiderbotDistractionPerformed>) -> Bool;

  protected cb func OnDisposeBody(evt: ref<DisposeBody>) -> Bool {
    let workspotSystem: ref<WorkspotGameSystem>;
    let unmountEvent: ref<UnmountingRequest> = new UnmountingRequest();
    let killEvent: ref<NPCKillDelayEvent> = new NPCKillDelayEvent();
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(this.GetGame()).GetMountingInfoSingleWithObjects(playerPuppet);
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    this.m_npcBody = GameInstance.FindEntityByID(this.GetGame(), mountingInfo.childId) as NPCPuppet;
    this.m_playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.CarryingDisposal, true);
    this.m_playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    this.m_playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyDisposalDetailed, EnumInt(gamePSMDetailedBodyDisposal.Dispose));
    GameInstance.GetMountingFacility(this.GetGame()).Unmount(unmountEvent);
    workspotSystem = GameInstance.GetWorkspotSystem(this.GetGame());
    this.CheckCurrentSide();
    workspotSystem.PlayInDevice(this, playerPuppet, n"lockedCamera", n"playerWorkspot", n"deviceWorkspot", this.m_currentDisposalSyncName, this.m_workspotDuration);
    workspotSystem.PlayNpcInWorkspot(this.m_npcBody, playerPuppet, this, n"npcWorkspot", this.m_currentDisposalSyncName, this.m_workspotDuration);
    if Equals(this.m_currentDisposalSyncName, n"disposalSyncSide2") {
      workspotSystem.SendJumpToTagCommandEnt(playerPuppet, n"disposalSyncSide2", true);
    };
    killEvent.disableKillReward = true;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, killEvent, 0.10);
    this.SetNpcIsDisposedBlackboard();
    this.m_npcBody.GenerateLoot();
    if !RPGManager.IsInventoryEmpty(this.m_npcBody) {
      this.m_npcBody.DropLootBag();
    };
    this.m_npcBody.GetVisibleObjectComponent().SetVisibleObjectTypeInvalid();
  }

  protected cb func OnTakedownAndDisposeBody(evt: ref<TakedownAndDisposeBody>) -> Bool {
    this.m_playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyDisposalDetailed, EnumInt(gamePSMDetailedBodyDisposal.Lethal));
    this.TakedownAndDispose(false);
  }

  protected cb func OnNonlethalTakedownAndDisposeBody(evt: ref<NonlethalTakedownAndDisposeBody>) -> Bool {
    this.m_playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyDisposalDetailed, EnumInt(gamePSMDetailedBodyDisposal.NonLethal));
    this.TakedownAndDispose(true);
  }

  private final func TakedownAndDispose(isNonlethal: Bool) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let record1HitDamage: ref<Record1DamageInHistoryEvent>;
    let takedownAction: ETakedownActionType;
    let workspotSystem: ref<WorkspotGameSystem>;
    let unmountEvent: ref<UnmountingRequest> = new UnmountingRequest();
    let killEvent: ref<NPCKillDelayEvent> = new NPCKillDelayEvent();
    killEvent.disableKillReward = false;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(this.GetGame()).GetMountingInfoSingleWithObjects(playerPuppet);
    this.m_npcBody = GameInstance.FindEntityByID(this.GetGame(), mountingInfo.childId) as NPCPuppet;
    this.m_isNonlethal = isNonlethal;
    this.m_playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown, 5);
    this.m_playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    unmountEvent.lowLevelMountingInfo = mountingInfo;
    GameInstance.GetMountingFacility(this.GetGame()).Unmount(unmountEvent);
    this.SetNpcIsDisposedBlackboard();
    workspotSystem = GameInstance.GetWorkspotSystem(this.GetGame());
    this.CheckCurrentSide();
    if isNonlethal {
      workspotSystem.PlayInDevice(this, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), n"lockedCamera", n"playerNonlethalTakedownWorkspot", n"deviceNonlethalTakedownWorkspot", this.m_currentKillSyncName, this.m_workspotDuration);
      workspotSystem.PlayNpcInWorkspot(this.m_npcBody, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), this, n"npcNonlethalTakedownWorkspot", this.m_currentKillSyncName, this.m_workspotDuration, n"deviceNonlethalTakedownWorkspot");
    } else {
      workspotSystem.PlayInDevice(this, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), n"lockedCamera", n"playerTakedownWorkspot", n"deviceTakedownWorkspot", this.m_currentKillSyncName, this.m_workspotDuration);
      workspotSystem.PlayNpcInWorkspot(this.m_npcBody, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), this, n"npcTakedownWorkspot", this.m_currentKillSyncName, this.m_workspotDuration, n"deviceTakedownWorkspot");
    };
    if Equals(this.m_currentKillSyncName, n"killSyncSide2") {
      workspotSystem.SendJumpToTagCommandEnt(playerPuppet, n"killSyncSide2", true);
    };
    if this.m_isNonlethal {
      record1HitDamage = new Record1DamageInHistoryEvent();
      record1HitDamage.source = playerPuppet;
      this.m_npcBody.QueueEvent(record1HitDamage);
      killEvent.isLethalTakedown = false;
      takedownAction = ETakedownActionType.DisposalTakedownNonLethal;
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, killEvent, this.m_lethalTakedownKillDelay);
    } else {
      killEvent.isLethalTakedown = true;
      takedownAction = ETakedownActionType.DisposalTakedown;
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, killEvent, this.m_lethalTakedownKillDelay);
    };
    GameInstance.GetTelemetrySystem(this.GetGame()).LogTakedown(EnumValueToName(n"ETakedownActionType", Cast(EnumInt(takedownAction))), this.m_npcBody);
    if !GameInstance.GetStatsSystem(playerPuppet.GetGame()).GetStatBoolValue(Cast(playerPuppet.GetEntityID()), gamedataStatType.CanTakedownSilently) {
      broadcaster = playerPuppet.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerNoiseStim(playerPuppet, takedownAction);
      };
    };
    this.m_npcBody.GenerateLoot();
    if !RPGManager.IsInventoryEmpty(this.m_npcBody) {
      this.m_npcBody.DropLootBag();
    };
  }

  private final func SetNpcIsDisposedBlackboard() -> Void {
    let bb: ref<IBlackboard> = this.m_npcBody.GetPuppetStateBlackboard();
    bb.SetBool(GetAllBlackboardDefs().PuppetState.IsBodyDisposed, true, true);
  }

  private final func HideNPCPermanently() -> Void {
    let HidePuppetDelayEvt: ref<HidePuppetDelayEvent> = new HidePuppetDelayEvent();
    HidePuppetDelayEvt.m_target = this.m_npcBody;
    this.m_npcBody.QueueEvent(HidePuppetDelayEvt);
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    this.m_npcBody.Kill(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, true);
    this.PlayTransformAnim(n"close");
    this.m_playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.CarryingDisposal, false);
    this.m_playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyDisposalDetailed, EnumInt(gamePSMDetailedBodyDisposal.Default));
    NPCPuppet.SetNPCDisposedFact(this.m_npcBody);
    this.HideNPCPermanently();
    this.PlayEffect(n"freeze", n"fridge");
    this.SetTakedownCameraAnimFeature(0);
    (this.GetDevicePS() as DisposalDeviceControllerPS).SetIsPlayerCurrentlyPerformingDisposal(false);
    this.UpdateLightAppearance();
  }

  protected cb func OnNPCKillDelayEvent(evt: ref<NPCKillDelayEvent>) -> Bool {
    let rewardSettingsEvent: ref<ChangeRewardSettingsEvent>;
    let toggleRagdollEvent: ref<RagdollToggleDelayEvent> = new RagdollToggleDelayEvent();
    toggleRagdollEvent.target = this.m_npcBody;
    toggleRagdollEvent.enable = false;
    this.m_npcBody.QueueEvent(toggleRagdollEvent);
    rewardSettingsEvent = new ChangeRewardSettingsEvent();
    rewardSettingsEvent.forceDefeatReward = !evt.isLethalTakedown;
    rewardSettingsEvent.disableKillReward = evt.disableKillReward;
    this.m_npcBody.QueueEvent(rewardSettingsEvent);
    if evt.isLethalTakedown {
      this.EnableLethalTakedownComponents();
    };
  }

  protected final func EnableLethalTakedownComponents() -> Void {
    let i: Int32;
    (this.GetDevicePS() as DisposalDeviceControllerPS).SetWasLethalTakedownPerformed(true);
    i = 0;
    while i < ArraySize(this.m_lethalTakedownComponents) {
      this.m_lethalTakedownComponents[i].Toggle(true);
      i += 1;
    };
  }

  protected final func SetTakedownCameraAnimFeature(value: Int32) -> Void {
    let animFeature: ref<AnimFeature_AerialTakedown> = new AnimFeature_AerialTakedown();
    animFeature.state = value;
    this.ApplyAnimFeatureToReplicate(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), n"AerialTakedown", animFeature);
  }

  protected final func PlayTransformAnim(animationName: CName) -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.animationName = animationName;
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    playEvent.timeScale = 1.00;
    this.QueueEvent(playEvent);
  }

  protected final func InitializeAlreadyUsedDevice() -> Void {
    this.PlayTransformAnim(n"closed_pose");
    this.PlayEffect(n"freeze", n"fridge");
  }

  protected final func SendRefreshInteractionEvent() -> Void {
    let evt: ref<TimerEvent> = new TimerEvent();
    this.QueueEvent(evt);
  }

  protected cb func OnTimerEvent(evt: ref<TimerEvent>) -> Bool {
    this.RefreshInteraction(gamedeviceRequestType.Direct, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject());
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    GameObject.PlaySoundEvent(this, this.m_distractionSoundName);
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"hacked");
  }

  protected func StopGlitching() -> Void {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"hacked");
  }

  protected cb func OnToggleActivation(evt: ref<ToggleActivation>) -> Bool {
    GameObject.PlaySoundEvent(this, this.m_distractionSoundName);
  }

  protected final func ActivatePhysicalMeshes() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_physicalMeshes) {
      this.m_physicalMeshes[i].CreatePhysicalBodyInterface().SetIsKinematic(false);
      this.m_physicalMeshes[i].CreatePhysicalBodyInterface().AddLinearImpulse(new Vector4(0.00, -100.00, 0.00, 0.00), false);
      i += 1;
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let activateAction: ref<ToggleActivation> = new ToggleActivation();
    if this.m_isReactToHit {
      if !this.GetDevicePS().IsDisabled() && !(this.GetDevicePS() as DisposalDeviceControllerPS).WasActivated() {
        GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), activateAction);
      };
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.HideBody;
  }

  public const func DeterminGameplayRoleMappinRange(data: SDeviceMappinData) -> Float {
    let range: Float;
    if NotEquals(data.gameplayRole, IntEnum(1l)) {
      if (this.GetDevicePS() as DisposalDeviceControllerPS).HasQuickHackDistraction() {
        range = this.GetDistractionRange(DeviceStimType.Distract);
      };
    };
    return range;
  }

  public const func IsBodyDisposalPossible() -> Bool {
    if (this.GetDevicePS() as DisposalDeviceControllerPS).IsEnemyGrappled() || (this.GetDevicePS() as DisposalDeviceControllerPS).IsPlayerCarrying() {
      return true;
    };
    return false;
  }

  protected cb func OnSpiderbotExplodeExplosiveDevicePerformed(evt: ref<SpiderbotExplodeExplosiveDevicePerformed>) -> Bool {
    this.StartExplosionPipeline(this, 1.00);
  }

  protected final func StartExplosionPipeline(instigator: wref<GameObject>, opt additionalDelays: Float) -> Void {
    let evt: ref<ExplosiveDeviceDelayedEvent>;
    let hideEvt: ref<ExplosiveDeviceHideDeviceEvent>;
    let largestDelayTime: Float;
    let dataArray: array<ExplosiveDeviceResourceDefinition> = (this.GetDevicePS() as DisposalDeviceControllerPS).GetExplosionDeinitionArray();
    let i: Int32 = 0;
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
    };
  }

  protected cb func OnExplosiveDeviceDelayedEvent(evt: ref<ExplosiveDeviceDelayedEvent>) -> Bool {
    this.Explode(evt.arrayIndex, evt.instigator);
  }

  private final func Explode(index: Int32, instigator: wref<GameObject>) -> Void {
    let dataArray: array<ExplosiveDeviceResourceDefinition> = (this.GetDevicePS() as DisposalDeviceControllerPS).GetExplosionDeinitionArray();
    this.DoAttack(dataArray[index].damageType);
    this.SpawnVFXs(dataArray[index].vfxResource);
    this.Distract(index);
    this.m_additionalMeshComponent.Toggle(true);
  }

  protected cb func OnOverChargeDevice(evt: ref<OverchargeDevice>) -> Bool {
    this.StartExplosionPipeline(this, 1.00);
  }

  protected final const func GetAttackRange(attackTDBID: TweakDBID) -> Float {
    return TweakDBInterface.GetAttackRecord(attackTDBID).Range();
  }

  private final func Distract(index: Int32) -> Void {
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

  private final func DoAttack(damageType: TweakDBID) -> Void {
    let attack: ref<Attack_GameEffect>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    flag.flag = hitFlag.FriendlyFire;
    flag.source = n"DisposalDevice";
    ArrayPush(hitFlags, flag);
    attack = RPGManager.PrepareGameEffectAttack(this.GetGame(), this, this, damageType, hitFlags);
    if IsDefined(attack) {
      attack.StartAttack();
    };
  }

  private final func SpawnVFXs(fx: FxResource) -> Void {
    let position: WorldPosition;
    let transform: WorldTransform;
    if FxResource.IsValid(fx) {
      WorldPosition.SetVector4(position, this.GetWorldPosition());
      WorldTransform.SetWorldPosition(transform, position);
      this.CreateFxInstance(fx, transform);
    };
  }

  private final func CreateFxInstance(resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(this.GetGame());
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }

  protected final func CheckCurrentSide() -> Void {
    let finalName: String;
    let j: Int32;
    let overlappingEntities: array<ref<Entity>>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_triggerComponents) {
      overlappingEntities = this.m_triggerComponents[i].GetOverlappingEntities();
      j = 0;
      while j < ArraySize(overlappingEntities) {
        if (overlappingEntities[j] as GameObject).IsPlayer() {
          finalName = "disposalSyncSide" + ToString(i + 1);
          this.m_currentDisposalSyncName = StringToName(finalName);
          finalName = "killSyncSide" + ToString(i + 1);
          this.m_currentKillSyncName = StringToName(finalName);
        };
        j += 1;
      };
      i += 1;
    };
  }

  public const func HasImportantInteraction() -> Bool {
    return (this.GetDevicePS() as DisposalDeviceControllerPS).GetNumberOfUses() > 0 || this.HasImportantInteraction();
  }

  protected const func HasAnyDirectInteractionActive() -> Bool {
    if this.IsDead() {
      return false;
    };
    return true;
  }

  private final func UpdateLightAppearance() -> Void {
    let lightSettings: ScriptLightSettings;
    let evt: ref<ChangeLightEvent> = new ChangeLightEvent();
    if (this.GetDevicePS() as DisposalDeviceControllerPS).GetNumberOfUses() <= 0 || this.GetDevicePS().IsDisabled() {
      lightSettings.color = new Color(130u, 0u, 0u, 0u);
    } else {
      lightSettings.color = new Color(25u, 200u, 0u, 255u);
    };
    lightSettings.strength = 1.00;
    evt.settings = lightSettings;
    this.QueueEvent(evt);
  }

  public const func DeterminGameplayRoleMappinVisuaState(data: SDeviceMappinData) -> EMappinVisualState {
    if this.IsBodyDisposalPossible() || !(this.GetDevicePS() as DisposalDeviceControllerPS).HasQuickHackDistraction() || !this.IsQuickHackAble() {
      if (this.GetDevicePS() as DisposalDeviceControllerPS).GetNumberOfUses() > 0 {
        return EMappinVisualState.Available;
      };
      return EMappinVisualState.Unavailable;
    };
    return this.DeterminGameplayRoleMappinVisuaState(data);
  }
}
