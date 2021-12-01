
public native class StateGameScriptInterface extends StateScriptInterface {

  public final native const func GetStateVectorParameter(stateVectorParameter: physicsStateValue) -> Variant;

  public final native func SetStateVectorParameter(stateVectorParameter: physicsStateValue, value: Variant) -> Bool;

  public final native const func Overlap(primitiveDimension: Vector4, position: Vector4, rotation: EulerAngles, opt collisionGroup: CName, out result: TraceResult) -> Bool;

  public final native const func OverlapWithCollisionFilter(primitiveDimension: Vector4, position: Vector4, rotation: EulerAngles, opt collisionGroup: QueryFilter, out result: TraceResult) -> Bool;

  public final native const func OverlapMultiple(primitiveDimension: Vector4, position: Vector4, rotation: EulerAngles, opt collisionGroup: CName) -> array<TraceResult>;

  public final native const func RayCast(start: Vector4, end: Vector4, opt collisionGroup: CName) -> TraceResult;

  public final native const func RayCastWithCollisionFilter(start: Vector4, end: Vector4, opt collisionGroup: QueryFilter) -> TraceResult;

  public final native const func RayCastMultiple(start: Vector4, end: Vector4, opt collisionGroup: CName) -> array<TraceResult>;

  public final native const func Sweep(primitiveDimension: Vector4, position: Vector4, rotation: EulerAngles, direction: Vector4, distance: Float, opt collisionGroup: CName, opt assumeInitialPositionClear: Bool, out result: TraceResult) -> Bool;

  public final native const func SweepWithCollisionFilter(primitiveDimension: Vector4, position: Vector4, rotation: EulerAngles, direction: Vector4, distance: Float, opt collisionGroup: QueryFilter, opt assumeInitialPositionClear: Bool, out result: TraceResult) -> Bool;

  public final native const func SweepMultiple(primitiveDimension: Vector4, position: Vector4, rotation: EulerAngles, direction: Vector4, distance: Float, opt collisionGroup: CName) -> array<TraceResult>;

  public final native const func GetCollisionReport() -> array<ControllerHit>;

  public final native const func IsOnGround() -> Bool;

  public final native const func IsOnMovingPlatform() -> Bool;

  public final native const func CanCapsuleFit(capsuleHeight: Float, capsuleRadius: Float) -> Bool;

  public final native const func HasSecureFooting() -> SecureFootingResult;

  public final native const func GetActionPrevStateTime(actionName: CName) -> Float;

  public final native const func GetActionStateTime(actionName: CName) -> Float;

  public final native const func GetActionValue(actionName: CName) -> Float;

  public final native const func IsActionJustPressed(actionName: CName) -> Bool;

  public final native const func IsActionJustReleased(actionName: CName) -> Bool;

  public final native const func IsActionJustHeld(actionName: CName) -> Bool;

  public final native const func IsAxisChangeAction(actionName: CName) -> Bool;

  public final native const func IsRelativeChangeAction(actionName: CName) -> Bool;

  public final native const func GetActionPressCount(actionName: CName) -> Uint32;

  public final const func IsActionJustTapped(actionName: CName) -> Bool {
    if !this.IsActionJustReleased(actionName) {
      return false;
    };
    if this.GetActionPrevStateTime(actionName) > 0.20 {
      return false;
    };
    return true;
  }

  public final native func SetComponentVisibility(actionName: CName, visibility: Bool) -> Bool;

  public final native func GetObjectFromComponent(targetingComponent: ref<IPlacedComponent>) -> ref<GameObject>;

  public final native const func TransformInvPointFromObject(point: Vector4, opt object: ref<GameObject>) -> Vector4;

  public final native func ActivateCameraSetting(settingId: CName) -> Bool;

  public final native func SetCameraTimeDilationCurve(curveName: CName) -> Bool;

  public final native const func GetCameraWorldTransform() -> Transform;

  public final native func TEMP_WeaponStopFiring() -> Bool;

  public final native const func IsTriggerModeActive(const triggerMode: gamedataTriggerMode) -> Bool;

  public final native func SetAnimationParameterInt(key: CName, value: Int32) -> Bool;

  public final native func SetAnimationParameterFloat(key: CName, value: Float) -> Bool;

  public final native func SetAnimationParameterBool(key: CName, value: Bool) -> Bool;

  public final native func SetAnimationParameterVector(key: CName, value: Vector4) -> Bool;

  public final native func SetAnimationParameterQuaternion(key: CName, value: Quaternion) -> Bool;

  public final native func SetAnimationParameterFeature(key: CName, value: ref<AnimFeature>, opt owner: ref<GameObject>) -> Bool;

  public final native func PushAnimationEvent(eventName: CName) -> Bool;

  public final native const func IsSceneAnimationActive() -> Bool;

  public final native const func IsMoveInputConsiderable() -> Bool;

  public final native const func GetInputHeading() -> Float;

  public final native const func GetOwnerStateVectorParameterFloat(parameterType: physicsStateValue) -> Float;

  public final native const func GetOwnerStateVectorParameterVector(parameterType: physicsStateValue) -> Vector4;

  public final native const func GetOwnerMovingDirection() -> Vector4;

  public final native const func GetOwnerForward() -> Vector4;

  public final native const func GetOwnerTransform() -> Transform;

  public final native const func RayCastNotPlayer(start: Vector4, end: Vector4) -> Bool;

  public final native const func MeetsPrerequisites(prereqName: TweakDBID) -> Bool;

  public final native const func GetItemIdInSlot(slotName: TweakDBID) -> ItemID;

  public final native const func CanEquipItem(const stateContext: ref<StateContext>) -> Bool;

  public final native const func IsMountedToObject(opt object: ref<GameObject>) -> Bool;

  public final native const func IsDriverInVehicle(opt child: ref<GameObject>, opt parent: ref<GameObject>) -> Bool;

  public final native const func IsPassengerInVehicle(opt child: ref<GameObject>, opt parent: ref<GameObject>) -> Bool;

  public final native const func GetMountingInfo(child: ref<GameObject>) -> MountingInfo;

  public final native const func GetRoleForSlot(slot: MountingSlotId, parent: ref<GameObject>, opt occupantSlotComponentName: CName) -> gameMountingSlotRole;

  public final native const func GetWaterLevel(puppetPosition: Vector4, referencePosition: Vector4, out waterLevel: Float) -> Bool;

  public final native const func IsEntityInCombat(opt objectId: EntityID) -> Bool;

  public final native const func CanEnterInteraction(const stateContext: ref<StateContext>) -> Bool;

  public final native const func RequestWeaponEquipOnServer(slotName: TweakDBID, itemId: ItemID) -> Void;

  public final native const func HasStatFlag(flag: gamedataStatType) -> Bool;

  public final native const func HasStatFlagOwner(flag: gamedataStatType, owner: ref<GameObject>) -> Bool;

  public final native const func IsPlayerInBraindance() -> Bool;

  public final native const func GetScriptableSystem(name: CName) -> ref<ScriptableSystem>;

  public final native const func GetGame() -> GameInstance;

  public final native const func GetActivityLogSystem() -> ref<ActivityLogSystem>;

  public final native const func GetAttitudeSystem() -> ref<AttitudeSystem>;

  public final native const func GetAudioSystem() -> ref<AudioSystem>;

  public final native const func GetBlackboardSystem() -> ref<BlackboardSystem>;

  public final native const func GetCameraSystem() -> ref<CameraSystem>;

  public final native const func GetCommunitySystem() -> ref<CommunitySystem>;

  public final native const func GetCompanionSystem() -> ref<CompanionSystem>;

  public final native const func GetCoverManager() -> ref<CoverManager>;

  public final native const func GetDebugVisualizerSystem() -> ref<DebugVisualizerSystem>;

  public final native const func GetDebugDrawHistorySystem() -> ref<IDebugDrawHistorySystem>;

  public final native const func GetDelaySystem() -> ref<DelaySystem>;

  public final native const func GetDeviceSystem() -> ref<DeviceSystem>;

  public final native const func GetEntitySpawnerEventsBroadcaster() -> ref<EntitySpawnerEventsBroadcaster>;

  public final native const func GetGameEffectSystem() -> ref<EffectSystem>;

  public final native const func GetSpatialQueriesSystem() -> ref<SpatialQueriesSystem>;

  public final native const func GetLootManager() -> ref<LootManager>;

  public final native const func GetLocationManager() -> ref<LocationManager>;

  public final native const func GetMappinSystem() -> ref<MappinSystem>;

  public final native const func GetObjectPoolSystem() -> ref<ObjectPoolSystem>;

  public final native const func GetPersistencySystem() -> ref<GamePersistencySystem>;

  public final native const func GetPlayerSystem() -> ref<PlayerSystem>;

  public final native const func GetPrereqManager() -> ref<PrereqManager>;

  public final native const func GetPreventionSpawnSystem() -> ref<PreventionSpawnSystem>;

  public final native const func GetQuestsSystem() -> ref<QuestsSystem>;

  public final native const func GetSceneSystem() -> ref<SceneSystem>;

  public final native const func GetScriptableSystemsContainer() -> ref<ScriptableSystemsContainer>;

  public final native const func GetStatPoolsSystem() -> ref<StatPoolsSystem>;

  public final native const func GetStatsSystem() -> ref<StatsSystem>;

  public final native const func GetStatsDataSystem() -> ref<StatsDataSystem>;

  public final native const func GetStatusEffectSystem() -> ref<StatusEffectSystem>;

  public final native const func GetGodModeSystem() -> ref<GodModeSystem>;

  public final native const func GetEffectorSystem() -> ref<EffectorSystem>;

  public final native const func GetDamageSystem() -> ref<DamageSystem>;

  public final native const func GetTargetingSystem() -> ref<TargetingSystem>;

  public final native const func GetTimeSystem() -> ref<TimeSystem>;

  public final native const func GetTransactionSystem() -> ref<TransactionSystem>;

  public final native const func GetVisionModeSystem() -> ref<VisionModeSystem>;

  public final native const func GetVehicleSystem() -> ref<VehicleSystem>;

  public final native const func GetWorkspotSystem() -> ref<WorkspotGameSystem>;

  public final native const func GetInventoryManager() -> ref<InventoryManager>;

  public final native const func GetTeleportationFacility() -> ref<TeleportationFacility>;

  public final native const func GetInfluenceMapSystem() -> ref<InfluenceMapSystem>;

  public final native const func GetFxSystem() -> ref<FxSystem>;

  public final native const func GetMountingFacility() -> ref<IMountingFacility>;

  public final native const func GetRestrictMovementAreaManager() -> ref<RestrictMovementAreaManager>;

  public final native const func GetSafeAreaManager() -> ref<SafeAreaManager>;

  public final native const func GetGameplayLogicPackageSystem() -> ref<GameplayLogicPackageSystem>;

  public final native const func GetJournalManager() -> ref<JournalManager>;

  public final native const func GetDebugCheatsSystem() -> ref<DebugCheatsSystem>;

  public final native const func GetCombatQueriesSystem() -> ref<gameICombatQueriesSystem>;

  public final native const func GetTelemetrySystem() -> ref<TelemetrySystem>;

  public final native const func GetGameRulesSystem() -> ref<gameIGameRulesSystem>;

  public final native const func GetGameTagSystem() -> ref<GameTagSystem>;

  public final native const func GetPingSystem() -> ref<PingSystem>;

  public final native const func GetPlayerManagerSystem() -> ref<gameIPlayerManager>;

  public final native const func GetScriptsDebugOverlaySystem() -> ref<ScriptsDebugOverlaySystem>;

  public final native const func GetCooldownSystem() -> ref<ICooldownSystem>;

  public final native const func GetDebugPlayerBreadcrumbs() -> ref<DebugPlayerBreadcrumbs>;

  public final native const func GetInteractionManager() -> ref<InteractionManager>;

  public final native const func GetSubtitleHandlerSystem() -> ref<SubtitleHandlerSystem>;

  public final native const func GetAINavigationSystem() -> ref<AINavigationSystem>;

  public final native const func GetSenseManager() -> ref<SenseManager>;

  public final native const func GetUISystem() -> ref<UISystem>;

  public final native const func GetAchievementSystem() -> ref<AchievementSystem>;

  public final native const func GetWatchdogSystem() -> ref<IWatchdogSystem>;

  public final native const func GetLevelAssignmentSystem() -> ref<LevelAssignmentSystem>;

  public final native const func GetPhotoModeSystem() -> ref<PhotoModeSystem>;

  public final native const func GetCharacterCustomizationSystem() -> ref<gameuiICharacterCustomizationSystem>;
}

public native class MountEventData extends IScriptable {

  public native let slotName: CName;

  public native let mountParentEntityId: EntityID;

  public native let isInstant: Bool;

  public native let entryAnimName: CName;

  public native let initialTransformLS: Transform;

  public native let mountEventOptions: ref<MountEventOptions>;

  public native let ignoreHLS: Bool;

  public final func IsTransitionForced() -> Bool {
    if Equals(this.slotName, n"trunk_body") {
      return true;
    };
    return false;
  }
}
