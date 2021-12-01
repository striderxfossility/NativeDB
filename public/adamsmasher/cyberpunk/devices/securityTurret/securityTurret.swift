
public class SecurityTurret extends SensorDevice {

  private let m_animFeature: ref<AnimFeature_SecurityTurretData>;

  @default(SecurityTurret, SecurityTurretData)
  private let m_animFeatureName: CName;

  private let m_lookAtSlot: ref<SlotComponent>;

  private let m_laserMesh: ref<MeshComponent>;

  private let m_targetingComp: ref<TargetingComponent>;

  protected let m_triggerSideOne: ref<TriggerComponent>;

  protected let m_triggerSideTwo: ref<TriggerComponent>;

  protected let m_weapon: wref<WeaponObject>;

  protected let itemID: ItemID;

  protected let m_laserGameEffect: ref<EffectInstance>;

  @default(SecurityTurret, laser)
  protected let m_laserFXSlotName: CName;

  private let m_burstDelayEvtID: DelayID;

  private let m_isBurstDelayOngoing: Bool;

  private let m_nextShootCycleDelayEvtID: DelayID;

  private let m_isShootingOngoing: Bool;

  private let m_timeToNextShot: Float;

  private let optim_CheckTargetParametersShots: Int32;

  private let m_netClientCurrentlyAppliedState: ref<SecurityTurretReplicatedState>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"updateComponent", n"UpdateComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"slot", n"SlotComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"laserMesh", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"targeting", n"gameTargetingComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"SideOne", n"gameStaticTriggerAreaComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"SideTwo", n"gameStaticTriggerAreaComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"light_guns", n"gameLightComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"light_arm", n"gameLightComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"light_cam", n"gameLightComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_lookAtSlot = EntityResolveComponentsInterface.GetComponent(ri, n"slot") as SlotComponent;
    this.m_laserMesh = EntityResolveComponentsInterface.GetComponent(ri, n"laserMesh") as MeshComponent;
    this.m_targetingComp = EntityResolveComponentsInterface.GetComponent(ri, n"targeting") as TargetingComponent;
    this.m_triggerSideOne = EntityResolveComponentsInterface.GetComponent(ri, n"SideOne") as TriggerComponent;
    this.m_triggerSideTwo = EntityResolveComponentsInterface.GetComponent(ri, n"SideTwo") as TriggerComponent;
    ArrayPush(this.m_lightScanRefs, EntityResolveComponentsInterface.GetComponent(ri, n"light_guns") as gameLightComponent);
    ArrayPush(this.m_lightScanRefs, EntityResolveComponentsInterface.GetComponent(ri, n"light_arm") as gameLightComponent);
    ArrayPush(this.m_lightScanRefs, EntityResolveComponentsInterface.GetComponent(ri, n"light_cam") as gameLightComponent);
    this.m_animFeature = new AnimFeature_SecurityTurretData();
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SecurityTurretController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if IsClient() {
      this.m_netClientCurrentlyAppliedState = new SecurityTurretReplicatedState();
    };
    this.GiveWeaponToTurret();
    this.SetSenseObjectType(gamedataSenseObjectType.Turret);
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.TerminateGameEffect(this.m_laserGameEffect);
    GameInstance.GetTransactionSystem(this.GetGame()).RemoveItemFromSlot(this, t"AttachmentSlots.WeaponRight");
  }

  public const func IsTurret() -> Bool {
    return true;
  }

  protected const func GetScannerName() -> String {
    return "LocKey#2056";
  }

  protected func PushPersistentData() -> Void {
    (this.GetDevicePS() as SecurityTurretControllerPS).PushPersistentData();
    this.PushPersistentData();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func SetLookAtPositionProviderOnFollowedTarget(evt: ref<LookAtAddEvent>, opt otherTarget: ref<GameObject>) -> Void {
    let collisionPositionProvider: ref<IPositionProvider>;
    let ownerPositionProvider: ref<IPositionProvider>;
    let targetPositionProvider: ref<IPositionProvider>;
    let targetVelocityProvider: ref<IVelocityProvider>;
    if (this.GetCurrentlyFollowedTarget() as ScriptedPuppet) == null && (otherTarget as ScriptedPuppet) == null {
      this.SetLookAtPositionProviderOnFollowedTarget(evt, otherTarget);
      return;
    };
    if IsDefined(otherTarget) {
      evt.SetEntityTarget(otherTarget, n"Chest", Vector4.EmptyVector());
      targetVelocityProvider = MoveComponentVelocityProvider.CreateMoveComponentVelocityProvider(otherTarget as ScriptedPuppet);
    } else {
      evt.SetEntityTarget(this.GetCurrentlyFollowedTarget(), n"Chest", Vector4.EmptyVector());
      targetVelocityProvider = MoveComponentVelocityProvider.CreateMoveComponentVelocityProvider(this.GetCurrentlyFollowedTarget() as ScriptedPuppet);
    };
    targetPositionProvider = evt.targetPositionProvider;
    evt.targetPositionProvider = null;
    ownerPositionProvider = IPositionProvider.CreateSlotPositionProvider(this.GetWeapon(), n"Muzzle");
    collisionPositionProvider = IPositionProvider.CreateCollisionPredictionPositionProvider(targetPositionProvider, ownerPositionProvider, targetVelocityProvider, 140.00);
    evt.SetPositionProvider(collisionPositionProvider);
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.ShootStop();
    this.m_animFeature.Shoot = false;
    this.ToggleAreaIndicator(false);
    this.m_targetingComp.Toggle(false);
    this.TerminateGameEffect(this.m_laserGameEffect);
    this.ApplyAnimFeatureToReplicate(this, n"SecurityTurretData", this.m_animFeature);
    this.ReplicateIsOn(false);
  }

  protected func CutPower() -> Void {
    this.TurnOffDevice();
    if this.GetDevicePS().IsBroken() {
      this.DestroySensor();
    };
  }

  protected func TurnOnDevice() -> Void {
    if Equals(this.GetDevicePS().GetDurabilityState(), EDeviceDurabilityState.BROKEN) {
      return;
    };
    this.ReplicateIsOn(true);
    this.TurnOnDevice();
    this.RunGameEffect(this.m_laserGameEffect, (this.GetDevicePS() as SecurityTurretControllerPS).GetLaserGameEffectRef(), this.m_laserFXSlotName, 10.00);
    this.m_targetingComp.Toggle(true);
    this.m_animFeature.isRippedOff = false;
    this.ApplyAnimFeatureToReplicate(this, n"SecurityTurretData", this.m_animFeature);
  }

  protected cb func OnTCSTakeOverControlActivate(evt: ref<TCSTakeOverControlActivate>) -> Bool {
    super.OnTCSTakeOverControlActivate(evt);
    if this.IsTaggedinFocusMode() {
      this.TerminateGameEffect(this.m_laserGameEffect);
    };
  }

  protected cb func OnTCSTakeOverControlDeactivate(evt: ref<TCSTakeOverControlDeactivate>) -> Bool {
    super.OnTCSTakeOverControlDeactivate(evt);
    this.ShootStop();
    if this.IsTaggedinFocusMode() {
      this.RunGameEffect(this.m_laserGameEffect, (this.GetDevicePS() as SecurityTurretControllerPS).GetLaserGameEffectRef(), this.m_laserFXSlotName, 10.00);
    };
  }

  protected final func GetWeapon() -> wref<WeaponObject> {
    this.GrabReferenceToWeapon();
    return this.m_weapon;
  }

  protected final func GiveWeaponToTurret() -> Void {
    let grabWeaponEvent: ref<GrabReferenceToWeaponEvent>;
    let slotsIDs: array<TweakDBID>;
    let transactionSystem: ref<TransactionSystem>;
    if !IsDefined(this.m_weapon) {
      transactionSystem = GameInstance.GetTransactionSystem(this.GetGame());
      if Equals((this.GetDevicePS() as SecurityTurretControllerPS).GetWeaponItemRecordString(), "") {
        this.itemID = ItemID.FromTDBID(t"Items.w_special_flak");
      } else {
        this.itemID = ItemID.FromTDBID(TDBID.Create("Items." + (this.GetDevicePS() as SecurityTurretControllerPS).GetWeaponItemRecordString()));
      };
      if transactionSystem.GiveItem(this, this.itemID, 1) {
        ArrayPush(slotsIDs, t"AttachmentSlots.WeaponRight");
        transactionSystem.InitializeSlots(this, slotsIDs);
        if transactionSystem.CanPlaceItemInSlot(this, slotsIDs[0], this.itemID) {
          transactionSystem.AddItemToSlot(this, slotsIDs[0], this.itemID);
          grabWeaponEvent = new GrabReferenceToWeaponEvent();
          GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, grabWeaponEvent, 0.50);
        };
      };
    };
  }

  protected cb func OnGrabReferenceToWeaponEvent(evt: ref<GrabReferenceToWeaponEvent>) -> Bool {
    this.GrabReferenceToWeapon();
  }

  protected final func GrabReferenceToWeapon() -> Void {
    if !IsDefined(this.m_weapon) {
      this.m_weapon = GameInstance.GetTransactionSystem(this.GetGame()).GetItemInSlot(this, t"AttachmentSlots.WeaponRight") as WeaponObject;
      if IsClient() && this.m_netClientCurrentlyAppliedState.m_isShooting {
        this.ShootStart();
      };
    };
  }

  public func SetAsIntrestingTarget(target: wref<GameObject>) -> Bool {
    return this.SetAsIntrestingTarget(target);
  }

  public func OnCurrentTargetAppears(target: wref<GameObject>) -> Void {
    if !this.m_animFeature.Shoot {
      this.m_laserMesh.Toggle(true);
      this.OnCurrentTargetAppears(target);
      if (this.GetDevicePS() as SecurityTurretControllerPS).IsPartOfPrevention() {
        GameObject.PlaySoundEvent(this, n"gmp_ui_prevention_turret_aim");
        PreventionSystem.CombatStartedRequestToPreventionSystem(this.GetGame(), this);
      };
    };
  }

  protected cb func OnTargetLocked(evt: ref<TargetLockedEvent>) -> Bool {
    if IsHost() {
      if this.GetDevicePS().IsBroken() {
        return false;
      };
      super.OnTargetLocked(evt);
      this.SelectShootingPattern(this.GetWeapon(), this, true);
      this.ShootStart();
    };
  }

  public func OnAllValidTargetsDisappears() -> Void {
    if IsHost() {
      this.OnAllValidTargetsDisappears();
      if (this.GetDevicePS() as SecurityTurretControllerPS).IsPartOfPrevention() {
        GameObject.PlaySoundEvent(this, n"gmp_turret_prevention_aim_off");
      };
      this.ShootStop();
      if IsDefined(this.m_laserMesh) {
        this.m_laserMesh.Toggle(false);
      };
    };
  }

  public func ControlledDeviceInputAction(isPressed: Bool) -> Void {
    if isPressed {
      this.ShootStart();
      if this.IsTemporaryAttitudeChanged() {
        this.ChangeTemporaryAttitude();
      };
    } else {
      this.ShootStop();
    };
  }

  protected final func SelectShootingPattern(weapon: wref<WeaponObject>, weaponOwner: wref<GameObject>, opt forceReselection: Bool) -> Void {
    let chosenPackage: wref<AIPatternsPackage_Record>;
    let patternsList: array<wref<AIPattern_Record>>;
    let selectedPattern: wref<AIPattern_Record>;
    if (this.GetDevicePS() as SecurityTurretControllerPS).IsPartOfPrevention() || this.GetDevicePS().IsControlledByPlayer() {
      return;
    };
    chosenPackage = TweakDBInterface.GetAIPatternsPackageRecord(t"ShootingPatterns.TurretShootingPackage");
    if AIWeapon.GetShootingPatternsList(weaponOwner, weapon, chosenPackage, patternsList) || forceReselection {
      if ArraySize(patternsList) > 0 {
        AIWeapon.SelectShootingPatternFromList(weapon, patternsList, selectedPattern);
      };
    };
    if IsDefined(selectedPattern) {
      AIWeapon.SetShootingPattern(weapon, selectedPattern);
      AIWeapon.SetShootingPatternPackage(weapon, chosenPackage);
      AIWeapon.SetPatternRange(weapon, patternsList);
    };
  }

  private final func ShootStart() -> Void {
    if this.m_isBurstDelayOngoing {
      return;
    };
    if !IsDefined(this.GetWeapon()) {
      return;
    };
    this.ReplicateIsShooting(true);
    this.m_animFeature.Shoot = true;
    this.ApplyAnimFeatureToReplicate(this, n"SecurityTurretData", this.m_animFeature);
    this.ShootAttachedWeapon(true);
  }

  private final func ShootStop() -> Void {
    this.ReplicateIsShooting(false);
    this.m_animFeature.Shoot = false;
    this.ApplyAnimFeatureToReplicate(this, n"SecurityTurretData", this.m_animFeature);
    if this.m_isBurstDelayOngoing {
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_burstDelayEvtID);
      this.m_isBurstDelayOngoing = false;
    };
    if this.m_isShootingOngoing {
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_nextShootCycleDelayEvtID);
      this.m_isShootingOngoing = false;
    };
  }

  protected final func GetFirerate() -> Float {
    return this.m_timeToNextShot;
  }

  private final func SetFirerate(value: Float) -> Void {
    this.m_timeToNextShot = value;
  }

  private final func MultiplyBaseAIRecoil() -> Float {
    return GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetWeapon().GetEntityID()), gamedataStatType.SpreadMaxAI) * 0.10;
  }

  private final func ShootAttachedWeapon(opt shootStart: Bool) -> Void {
    let shootObject: wref<GameObject>;
    let shouldTrackTarget: Bool;
    let simTime: Float;
    let timeToNextShot: Float;
    let vehicle: wref<VehicleObject>;
    let weaponRecord: wref<WeaponItem_Record>;
    if !this.m_animFeature.Shoot {
      return;
    };
    simTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
    if shootStart {
      timeToNextShot = AIWeapon.GetNextShotTimeStamp(this.GetWeapon()) - simTime;
      if timeToNextShot > 0.00 {
        this.QueueNextShot(timeToNextShot);
        return;
      };
    };
    weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.GetWeapon().GetItemID())) as WeaponItem_Record;
    this.SelectShootingPattern(this.GetWeapon(), this);
    if (this.GetDevicePS() as SecurityTurretControllerPS).IsPartOfPrevention() {
      AIWeapon.Fire(this, this.GetWeapon(), simTime, 1.00, weaponRecord.PrimaryTriggerMode().Type(), this.GetCurrentlyFollowedTarget().GetWorldPosition(), this.GetCurrentlyFollowedTarget(), 1.50, this.m_currentLookAtEventHor.targetPositionProvider);
    } else {
      if this.GetDevicePS().IsControlledByPlayer() {
        AIWeapon.Fire(GetPlayer(this.GetGame()), this.GetWeapon(), simTime, 1.00, weaponRecord.PrimaryTriggerMode().Type());
      } else {
        shouldTrackTarget = this.GetCurrentlyFollowedTarget().GetEntityID() == (this.GetDevicePS() as SecurityTurretControllerPS).GetForcedTargetID() && (this.GetDevicePS() as SecurityTurretControllerPS).IsInFollowMode();
        shootObject = this.GetCurrentlyFollowedTarget();
        if shootObject.IsPlayer() {
          if VehicleComponent.GetVehicle(this.GetCurrentlyFollowedTarget().GetGame(), this.GetCurrentlyFollowedTarget().GetEntityID(), vehicle) {
            if IsDefined(vehicle as TankObject) {
              shootObject = vehicle;
            };
          };
        };
        AIWeapon.Fire(this, this.GetWeapon(), simTime, 1.00, weaponRecord.PrimaryTriggerMode().Type(), shootObject.GetWorldPosition(), shootObject, shouldTrackTarget, this.m_currentLookAtEventHor.targetPositionProvider);
      };
    };
    AnimationControllerComponent.PushEvent(this, n"Shoot");
    AIWeapon.QueueNextShot(this.GetWeapon(), weaponRecord.PrimaryTriggerMode().Type(), simTime);
    this.SetFirerate(AIWeapon.GetNextShotTimeStamp(this.GetWeapon()) - simTime);
    this.ApplyShootingInterval();
    this.optim_CheckTargetParametersShots += 1;
    this.CheckTargetParameters();
    GameObjectEffectHelper.StartEffectEvent(this, StringToName((this.GetDevicePS() as SecurityTurretControllerPS).GetVfxNameOnShoot()));
  }

  private final func ProcessShootingPattern() -> Void;

  private final func ApplyShootingInterval() -> Void {
    let intervalDelay: ref<TurretBurstShootingDelayEvent>;
    let pattern: wref<AIPattern_Record> = AIWeapon.GetShootingPattern(this.GetWeapon());
    let delay: Float = AIWeapon.GetShootingPatternDelayBetweenShots(AIWeapon.GetTotalNumberOfShots(this.GetWeapon()), pattern);
    if delay > 0.00 {
      this.ShootStop();
      intervalDelay = new TurretBurstShootingDelayEvent();
      this.m_burstDelayEvtID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, intervalDelay, delay);
      this.m_isBurstDelayOngoing = true;
    } else {
      this.QueueNextShot(this.GetFirerate());
    };
  }

  private final func QueueNextShot(delay: Float) -> Void {
    let interval: ref<TurretShootingIntervalEvent> = new TurretShootingIntervalEvent();
    this.m_nextShootCycleDelayEvtID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, interval, this.GetFirerate());
    this.m_isShootingOngoing = true;
  }

  protected cb func OnTurretShootingIntervalEvent(evt: ref<TurretShootingIntervalEvent>) -> Bool {
    this.ShootAttachedWeapon();
  }

  protected cb func OnTurretBurstShootingDelayEvent(evt: ref<TurretBurstShootingDelayEvent>) -> Bool {
    this.m_isBurstDelayOngoing = false;
    this.ShootStart();
  }

  protected final func CheckTargetParameters() -> Void {
    if this.optim_CheckTargetParametersShots > 5 {
      if Equals(GameObject.GetAttitudeBetween(this, this.GetCurrentlyFollowedTarget()), EAIAttitude.AIA_Friendly) {
        this.ReevaluateTargets();
        this.optim_CheckTargetParametersShots = 0;
      };
    };
  }

  protected cb func OnRipOff(evt: ref<RipOff>) -> Bool {
    this.RipOffTurret();
    this.GrabReferenceToWeapon();
    this.UpdateDeviceState();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new AutoKillDelayEvent(), 3.00);
    this.m_animFeature.isRippedOff = true;
    if Equals(this.GetRipOffTriggerSide(evt.GetExecutor()), EDoorTriggerSide.ONE) {
      this.m_animFeature.ripOffSide = true;
    };
    this.ApplyAnimFeatureToReplicate(this, n"SecurityTurretData", this.m_animFeature);
    this.m_senseComponent.RequestRemovingSenseMappin();
    this.GetDevicePS().TriggerSecuritySystemNotification(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), this.GetWorldPosition(), ESecurityNotificationType.COMBAT, true);
  }

  protected cb func OnAutoKillDelayEvent(evt: ref<AutoKillDelayEvent>) -> Bool {
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolMinValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, null);
  }

  protected cb func OnQuestResetDeviceToInitialState(evt: ref<QuestResetDeviceToInitialState>) -> Bool {
    let determineForcedRole: ref<EvaluateGameplayRoleEvent> = new EvaluateGameplayRoleEvent();
    determineForcedRole.force = true;
    this.GiveWeaponToTurret();
    this.ToggleTurretVisuals(true);
    this.m_interaction.Toggle(true);
    this.QueueEvent(determineForcedRole);
    this.m_animFeature.isRippedOff = false;
    this.ApplyAnimFeatureToReplicate(this, n"SecurityTurretData", this.m_animFeature);
  }

  private final func RipOffTurret() -> Void {
    this.ToggleTurretVisuals(false);
  }

  protected final func ToggleTurretVisuals(toggle: Bool) -> Void {
    GameObjectEffectHelper.StopEffectEvent(this, n"broken");
  }

  protected cb func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> Bool {
    let player: ref<PlayerPuppet>;
    let playerStateMachineBlackboard: ref<IBlackboard>;
    super.OnDisassembleDevice(evt);
    player = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    this.EnterWorkspot(player, true, n"disassemblePlayerWorkspot");
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    this.m_targetingComp.Toggle(false);
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName) -> Void {
    this.EnterWorkspot(activator, freeCamera, componentName, deviceData);
    this.m_interaction.Toggle(false);
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    this.m_targetingComp.Toggle(false);
    if Equals(componentName, n"disassemblePlayerWorkspot") {
      this.GetDevicePS().UnpowerDevice();
      this.CutPower();
      GameInstance.GetActivityLogSystem(this.GetGame()).AddLog("Extracted weapon frame from the turret  ");
      this.m_interaction.Toggle(false);
      this.m_laserMesh.Toggle(false);
      this.UpdateDeviceState();
    };
    GameInstance.GetTransactionSystem(this.GetGame()).RemoveItemFromSlot(this, t"AttachmentSlots.WeaponRight");
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    let dissableEvent: ref<QuestForceUnpower>;
    let weapon: wref<WeaponObject>;
    if this.GetDevicePS().IsControlledByPlayer() {
      TakeOverControlSystem.ReleaseControl(this.GetGame());
    };
    this.ReplicateIsDead(true);
    this.GetDevicePS().SetDurabilityState(EDeviceDurabilityState.BROKEN);
    if IsDefined(this.m_visibleObjectComponent) {
      this.m_visibleObjectComponent.Toggle(false);
    };
    this.m_senseComponent.RemoveSenseMappin();
    this.m_laserMesh.Toggle(false);
    this.m_targetingComp.Toggle(false);
    dissableEvent = new QuestForceUnpower();
    this.SendEventToDefaultPS(dissableEvent);
    weapon = this.GetWeapon();
    if IsDefined(weapon) {
      weapon.QueueEvent(evt);
    };
    GameObject.UntagObject(this);
  }

  protected cb func OnActionEngineering(evt: ref<ActionEngineering>) -> Bool {
    this.ApplyAnimFeatureToReplicate(this, n"SecurityTurretData", this.m_animFeature);
    this.OnAllValidTargetsDisappears();
    this.RestoreDeviceState();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceReload(evt: ref<QuestForceReload>) -> Bool {
    let intervalDelay: ref<TurretBurstShootingDelayEvent>;
    if this.m_isBurstDelayOngoing {
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_burstDelayEvtID);
    };
    this.ShootStop();
    intervalDelay = new TurretBurstShootingDelayEvent();
    this.m_burstDelayEvtID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, intervalDelay, 4.00);
    this.m_isBurstDelayOngoing = true;
  }

  protected cb func OnQuestForceOverheat(evt: ref<QuestForceOverheat>) -> Bool {
    this.ShootStop();
    AIWeapon.ForceWeaponOverheat(this.GetWeapon(), this);
  }

  protected cb func OnQuestRemoveWeapon(evt: ref<QuestRemoveWeapon>) -> Bool {
    this.ShootStop();
    if !IsDefined(this.m_weapon) {
      GameInstance.GetTransactionSystem(this.GetGame()).RemoveItemFromSlot(this, t"AttachmentSlots.WeaponRight");
    };
  }

  public const func GetDeviceStateClass() -> CName {
    return n"SecurityTurretReplicatedState";
  }

  protected cb func OnDamageReceived(evt: ref<gameDamageReceivedEvent>) -> Bool {
    this.ProcessDamageReceived(evt);
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let serverState: ref<SecurityTurretReplicatedState>;
    super.OnHit(evt);
    serverState = this.GetServerState() as SecurityTurretReplicatedState;
    if IsDefined(serverState) {
      serverState.m_health = this.GetCurrentHealth();
    };
  }

  public const func ShouldShowDamageNumber() -> Bool {
    return true;
  }

  protected func ApplyReplicatedState(const state: ref<DeviceReplicatedState>) -> Void {
    let turretState: ref<SecurityTurretReplicatedState>;
    this.ApplyReplicatedState(state);
    turretState = state as SecurityTurretReplicatedState;
    if NotEquals(this.m_netClientCurrentlyAppliedState.m_isOn, turretState.m_isOn) {
      if turretState.m_isOn {
        this.TurnOnDevice();
      } else {
        this.TurnOffDevice();
      };
    };
    if NotEquals(this.m_netClientCurrentlyAppliedState.m_isShooting, turretState.m_isShooting) {
      if turretState.m_isShooting {
        this.ShootStart();
      } else {
        this.ShootStop();
      };
    };
    if this.m_netClientCurrentlyAppliedState.m_health != turretState.m_health {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, turretState.m_health, null, true);
      this.m_netClientCurrentlyAppliedState.m_health = turretState.m_health;
    };
    if NotEquals(this.m_netClientCurrentlyAppliedState.m_isDead, turretState.m_isDead) {
      if turretState.m_isDead {
        this.OnDeath(null);
      };
    };
  }

  public final static func CreateInputHint(context: GameInstance, isVisible: Bool) -> Void {
    let data: InputHintData;
    data.action = n"DeviceAttack";
    data.source = n"SecurityTurret";
    data.localizedLabel = "LocKey#36197";
    SendInputHintData(context, isVisible, data);
  }

  private final func GetReplicationStateToUpdate() -> ref<SecurityTurretReplicatedState> {
    if IsServer() {
      return this.GetServerState() as SecurityTurretReplicatedState;
    };
    if IsClient() {
      return this.m_netClientCurrentlyAppliedState;
    };
    return null;
  }

  private final func ReplicateIsShooting(isShooting: Bool) -> Void {
    let stateToUpdate: ref<SecurityTurretReplicatedState> = this.GetReplicationStateToUpdate();
    if IsDefined(stateToUpdate) {
      stateToUpdate.m_isShooting = isShooting;
    };
  }

  private final func ReplicateHealth(health: Float) -> Void {
    let stateToUpdate: ref<SecurityTurretReplicatedState> = this.GetReplicationStateToUpdate();
    if IsDefined(stateToUpdate) {
      stateToUpdate.m_health = health;
    };
  }

  private final func ReplicateIsOn(isOn: Bool) -> Void {
    let stateToUpdate: ref<SecurityTurretReplicatedState> = this.GetReplicationStateToUpdate();
    if IsDefined(stateToUpdate) {
      stateToUpdate.m_isOn = isOn;
    };
  }

  private final func ReplicateIsDead(isDead: Bool) -> Void {
    let stateToUpdate: ref<SecurityTurretReplicatedState> = this.GetReplicationStateToUpdate();
    if IsDefined(stateToUpdate) {
      stateToUpdate.m_isDead = isDead;
    };
  }

  public final func GetRipOffTriggerSide(forEntity: ref<Entity>) -> EDoorTriggerSide {
    if !IsDefined(forEntity) || !IsDefined(this.m_triggerSideOne) || !IsDefined(this.m_triggerSideOne) {
      return EDoorTriggerSide.OUTSIDE;
    };
    if this.m_triggerSideOne.IsEntityOverlapping(forEntity) {
      return EDoorTriggerSide.ONE;
    };
    if this.m_triggerSideTwo.IsEntityOverlapping(forEntity) {
      return EDoorTriggerSide.TWO;
    };
    return EDoorTriggerSide.OUTSIDE;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    if (this.GetDevicePS() as SecurityTurretControllerPS).IsPartOfPrevention() {
      if this.GetDevicePS().IsON() {
        return EGameplayRole.Shoot;
      };
      return IntEnum(1l);
    };
    return EGameplayRole.Shoot;
  }

  public const func DeterminGameplayRoleMappinRange(data: SDeviceMappinData) -> Float {
    return this.GetDistractionRange(DeviceStimType.Distract);
  }

  public final const func GetTurretWeapon() -> wref<WeaponObject> {
    return this.m_weapon;
  }

  public const func GetObjectToForwardHighlight() -> array<wref<GameObject>> {
    let weapons: array<wref<GameObject>>;
    let weapon: wref<WeaponObject> = this.GetTurretWeapon();
    if IsDefined(weapon) {
      ArrayPush(weapons, weapon);
    };
    return weapons;
  }
}
