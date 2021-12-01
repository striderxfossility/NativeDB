
public class ForceIgnoreTargets extends ActionBool {

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties() -> Void {
    this.actionName = n"ForceIgnoreTargets";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ForceIgnoreTargets", true, n"LocKey#2241", n"LocKey#2241");
  }
}

public class SetDeviceTagKillMode extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetDeviceSupprotMode";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#363", n"LocKey#363");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "SetDeviceSupprotMode";
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.Aim");
  }
}

public class SensorDeviceController extends ExplosiveDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }

  public final func OnEditorAttach() -> Void {
    this.RegisterRenderDebug("Components/SensorDeviceController/RenderDebug", n"OnSensorDeviceRenderDebug");
  }

  public final func OnGameAttach() -> Void {
    this.RegisterRenderDebug("Components/SensorDeviceController/RenderDebug", n"OnSensorDeviceRenderDebug");
  }

  protected final const func OnSensorDeviceRenderDebug(debugDrawer: DebugDrawer) -> Void {
    this.SensorDeviceRenderDebug(debugDrawer);
  }

  protected final const func OnRenderSelection(debugDrawer: DebugDrawer) -> Void {
    if DebugDrawer.TestDebugFilterMask(debugDrawer, "Components/SensorDeviceController/RenderSelection") {
      this.SensorDeviceRenderDebug(debugDrawer);
    };
  }

  private final const func SensorDeviceRenderDebug(debugDrawer: script_ref<DebugDrawer>) -> Void {
    let fragmentBuilder: FragmentBuilder;
    let matrix: Matrix;
    let maxRotationAngle: Vector4;
    FragmentBuilder.Construct(fragmentBuilder, debugDrawer);
    FragmentBuilder.PushLocalTransform(fragmentBuilder);
    matrix = EulerAngles.ToMatrix(new EulerAngles(0.00, (this.GetPS() as SensorDeviceControllerPS).GetBehaviourOverrideRootRotation(), 0.00));
    matrix *= WorldTransform.ToMatrix(this.GetEntity().GetWorldTransform());
    FragmentBuilder.BindTransform(fragmentBuilder, matrix);
    FragmentBuilder.SetColor(fragmentBuilder, new Color(230u, 38u, 5u, 255u));
    maxRotationAngle = Vector4.RotateAxis(new Vector4(0.00, 1.00, 0.00, 0.00), new Vector4(1.00, 0.00, 0.00, 0.00), Deg2Rad((this.GetPS() as SensorDeviceControllerPS).GetBehaviourPitchAngle()));
    FragmentBuilder.AddArrow(fragmentBuilder, new Vector4(0.00, 0.00, 0.00, 0.00), maxRotationAngle);
    FragmentBuilder.AddWireAngledRange(fragmentBuilder, Matrix.Identity(), 0.05, 1.00, 2.00 * (this.GetPS() as SensorDeviceControllerPS).GetBehaviourMaxRotationAngle(), true);
    FragmentBuilder.PopLocalTransform(fragmentBuilder);
    FragmentBuilder.Done(fragmentBuilder);
  }
}

public class SensorDeviceControllerPS extends ExplosiveDeviceControllerPS {

  @attrib(category, "Senses")
  @default(SensorDeviceControllerPS, true)
  private persistent let m_isRecognizableBySenses: Bool;

  protected persistent let m_targetingBehaviour: TargetingBehaviour;

  protected persistent let m_detectionParameters: DetectionParameters;

  @attrib(customEditor, "TweakDBGroupInheritance;LookAtPreset")
  @default(SecurityTurretControllerPS, LookatPreset.TurretVertical)
  @default(SurveillanceCameraControllerPS, LookatPreset.CameraVertical)
  protected edit let m_lookAtPresetVert: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;LookAtPreset")
  @default(SecurityTurretControllerPS, LookatPreset.TurretHorizontal)
  @default(SurveillanceCameraControllerPS, LookatPreset.CameraHorizontal)
  protected edit let m_lookAtPresetHor: TweakDBID;

  @attrib(category, "Game effect refs")
  protected edit let m_scanGameEffectRef: EffectRef;

  @attrib(category, "Game effect refs")
  protected edit let m_visionConeEffectRef: EffectRef;

  @attrib(category, "Game effect refs")
  protected edit let m_visionConeFriendlyEffectRef: EffectRef;

  @attrib(category, "Game effect refs")
  protected edit let m_idleActiveRef: EffectRef;

  @attrib(category, "Game effect refs")
  protected edit let m_idleFriendlyRef: EffectRef;

  protected persistent let m_canTagEnemies: Bool;

  protected let m_tagLockFromSystem: Bool;

  private let m_netrunnerID: EntityID;

  private let m_netrunnerProxyID: EntityID;

  private let m_netrunnerTargetID: EntityID;

  private let m_linkedStatusEffect: LinkedStatusEffect;

  private persistent let m_questForcedTargetID: EntityID;

  private persistent let m_isInFollowMode: Bool;

  private persistent let m_isAttitudeChanged: Bool;

  private persistent let m_isInTagKillMode: Bool;

  private persistent let m_isIdleForced: Bool;

  private persistent let m_questTargetToSpot: EntityID;

  private let m_questTargetSpotted: Bool;

  private let m_isAnyTargetIsLocked: Bool;

  protected edit let m_isPartOfPrevention: Bool;

  public final const func GetBehaviourCanRotate() -> Bool {
    return this.m_targetingBehaviour.m_canRotate;
  }

  public final const func GetBehaviourLastTargetLookAtTime() -> Float {
    return this.m_targetingBehaviour.m_lostTargetLookAtTime;
  }

  public final const func GetBehaviourLostTargetSearchTime() -> Float {
    return this.m_targetingBehaviour.m_lostTargetSearchTime;
  }

  public final const func CanTagEnemies() -> Bool {
    return this.m_canTagEnemies && !this.m_tagLockFromSystem;
  }

  public final const func GetInitialWakeState() -> ESensorDeviceWakeState {
    return this.m_targetingBehaviour.m_initialWakeState;
  }

  public final const func GetLookAtPresetVert() -> TweakDBID {
    return this.m_lookAtPresetVert;
  }

  public final const func GetLookAtPresetHor() -> TweakDBID {
    return this.m_lookAtPresetHor;
  }

  public final const func GetBehaviourCanDetectIntruders() -> Bool {
    if this.IsDistracting() || !this.m_detectionParameters.m_canDetectIntruders {
      return false;
    };
    return true;
  }

  public final const func GetBehaviourOverrideRootRotation() -> Float {
    return this.m_detectionParameters.m_overrideRootRotation;
  }

  public final const func GetBehaviourMaxRotationAngle() -> Float {
    return this.m_detectionParameters.m_maxRotationAngle;
  }

  public final const func GetBehaviourPitchAngle() -> Float {
    return this.m_detectionParameters.m_pitchAngle;
  }

  public final const func GetBehaviourRotationSpeed() -> Float {
    return this.m_detectionParameters.m_rotationSpeed;
  }

  public final const func GetBehaviourtimeToTakeAction() -> Float {
    if this.IsPartOfPrevention() {
      return 0.00;
    };
    return this.m_detectionParameters.m_timeToActionAfterSpot;
  }

  public final const func GetForcedTargetID() -> EntityID {
    return this.m_questForcedTargetID;
  }

  public final const func IsInFollowMode() -> Bool {
    return this.m_isInFollowMode;
  }

  public final const func IsAttitudeChanged() -> Bool {
    return this.m_isAttitudeChanged;
  }

  public final const func IsInTagKillMode() -> Bool {
    return this.m_isInTagKillMode;
  }

  public final const func IsIdleForced() -> Bool {
    return this.m_isIdleForced;
  }

  public final const func IsPartOfPrevention() -> Bool {
    return this.m_isPartOfPrevention;
  }

  public final const quest func IsQuestTargetSpotted() -> Bool {
    return this.m_questTargetSpotted;
  }

  public final const quest func IsAnyTargetLocked() -> Bool {
    return this.m_isAnyTargetIsLocked;
  }

  public final const quest func IsNoTargetLocked() -> Bool {
    if !this.m_isAnyTargetIsLocked {
      return true;
    };
    return false;
  }

  public final const func GetQuestSpotTargetID() -> EntityID {
    return this.m_questTargetToSpot;
  }

  public final const func GetNetrunnerID() -> EntityID {
    return this.m_netrunnerID;
  }

  public final const func GetNetrunnerProxyID() -> EntityID {
    return this.m_netrunnerProxyID;
  }

  public final const func GetNetrunnerTargetID() -> EntityID {
    return this.m_netrunnerTargetID;
  }

  public final const func GetLinkedStatusEffect() -> LinkedStatusEffect {
    return this.m_linkedStatusEffect;
  }

  public final const func GetScanGameEffectRef() -> EffectRef {
    return this.m_scanGameEffectRef;
  }

  public final const func GetVisionConeEffectRef() -> EffectRef {
    return this.m_visionConeEffectRef;
  }

  public final const func GetVisionConeFriendlyEffectRef() -> EffectRef {
    return this.m_visionConeFriendlyEffectRef;
  }

  public final const func GetIdleActiveRef() -> EffectRef {
    return this.m_idleActiveRef;
  }

  public final const func GetIdleFriendlyRef() -> EffectRef {
    return this.m_idleFriendlyRef;
  }

  public final func SetIsAttitudeChanged(isChanged: Bool) -> Void {
    this.m_isAttitudeChanged = isChanged;
  }

  public final func SetIsInTagKillMode(value: Bool) -> Void {
    this.m_isInTagKillMode = value;
  }

  public final func SetIsIdleForced(value: Bool) -> Void {
    this.m_isIdleForced = value;
  }

  public final func SetCanDetectIntruders(value: Bool) -> Void {
    this.m_detectionParameters.m_canDetectIntruders = value;
  }

  public final func SetNetrunnerID(value: EntityID) -> Void {
    this.m_netrunnerID = value;
  }

  public final func SetNetrunnerProxyID(value: EntityID) -> Void {
    this.m_netrunnerProxyID = value;
  }

  public final func SetNetrunnerTargetID(value: EntityID) -> Void {
    this.m_netrunnerTargetID = value;
  }

  public final func SetLinkedStatusEffect(value: LinkedStatusEffect) -> Void {
    this.m_linkedStatusEffect = value;
  }

  public final func SetTagLockFromSystem(value: Bool) -> Void {
    this.m_tagLockFromSystem = value;
  }

  public final func SetQuestTargetSpotted(value: Bool) -> Void {
    let evt: ref<SetQuestTargetWasSeen> = new SetQuestTargetWasSeen();
    evt.wasSeen = value;
    this.QueuePSEvent(this, evt);
  }

  public final func OnSetQuestTargetWasSeen(evt: ref<SetQuestTargetWasSeen>) -> EntityNotificationType {
    this.m_questTargetSpotted = evt.wasSeen;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func SetTargetIsLocked(value: Bool) -> Void {
    let evt: ref<SetAnyTargetIsLocked> = new SetAnyTargetIsLocked();
    evt.wasSeen = value;
    this.QueuePSEvent(this, evt);
  }

  public final func OnSetAnyTargetIsLocked(evt: ref<SetAnyTargetIsLocked>) -> EntityNotificationType {
    this.m_isAnyTargetIsLocked = evt.wasSeen;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public const func IsDetectingDebug() -> Bool {
    return false;
  }

  public final const func GetCurrentTarget() -> ref<GameObject> {
    return (this.GetOwnerEntityWeak() as SensorDevice).GetCurrentlyFollowedTarget();
  }

  protected func ActionQuickHackToggleON() -> ref<QuickHackToggleON> {
    let action: ref<QuickHackToggleON> = this.ActionQuickHackToggleON();
    if this.IsON() {
      action.CreateInteraction(t"Interactions.Off");
    } else {
      action.CreateInteraction(t"Interactions.On");
    };
    return action;
  }

  protected final func ActionQuestFollowTarget() -> ref<QuestFollowTarget> {
    let action: ref<QuestFollowTarget> = new QuestFollowTarget();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestStopFollowingTarget() -> ref<QuestStopFollowingTarget> {
    let action: ref<QuestStopFollowingTarget> = new QuestStopFollowingTarget();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestLookAtTarget() -> ref<QuestLookAtTarget> {
    let action: ref<QuestLookAtTarget> = new QuestLookAtTarget();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestStopLookAtTarget() -> ref<QuestStopLookAtTarget> {
    let action: ref<QuestStopLookAtTarget> = new QuestStopLookAtTarget();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestForceAttitude() -> ref<QuestForceAttitude> {
    let action: ref<QuestForceAttitude> = new QuestForceAttitude();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(n"attitudeNotProvied");
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestSetDetectionToTrue() -> ref<QuestSetDetectionToTrue> {
    let action: ref<QuestSetDetectionToTrue> = new QuestSetDetectionToTrue();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestSetDetectionToFalse() -> ref<QuestSetDetectionToFalse> {
    let action: ref<QuestSetDetectionToFalse> = new QuestSetDetectionToFalse();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func ActionForceIgnoreTargets() -> ref<ForceIgnoreTargets> {
    let action: ref<ForceIgnoreTargets> = new ForceIgnoreTargets();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected func ActionSetDeviceTagKillMode() -> ref<SetDeviceTagKillMode> {
    let action: ref<SetDeviceTagKillMode> = new SetDeviceTagKillMode();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected final func ActionQuestSpotTargetReference() -> ref<QuestSpotTargetReference> {
    let action: ref<QuestSpotTargetReference> = new QuestSpotTargetReference();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestForceScanEffect() -> ref<QuestForceScanEffect> {
    let action: ref<QuestForceScanEffect> = new QuestForceScanEffect();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestForceScanEffectStop() -> ref<QuestForceScanEffectStop> {
    let action: ref<QuestForceScanEffectStop> = new QuestForceScanEffectStop();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func PerformRestart() -> Void {
    this.PerformRestart();
    this.ExecutePSAction(this.ActionSetDeviceUnpowered());
  }

  protected final func OnSecuritySystemEnabled(evt: ref<SecuritySystemEnabled>) -> EntityNotificationType {
    this.SetIsAttitudeChanged(false);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSecuritySystemDisabled(evt: ref<SecuritySystemDisabled>) -> EntityNotificationType {
    this.ExecutePSAction(this.ActionSetDeviceAttitude());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    this.OnSecuritySystemOutput(evt);
    if NotEquals(evt.GetBreachOrigin(), EBreachOrigin.EXTERNAL) {
      notifier.SetInternalOnly();
      this.Notify(notifier, evt);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> EntityNotificationType {
    this.OnSecurityAreaCrossingPerimeter(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnReprimandUpdate(evt: ref<ReprimandUpdate>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestForceScanEffect(evt: ref<QuestForceScanEffect>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuestForceScanEffectStop(evt: ref<QuestForceScanEffectStop>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnQuestSpotTargetReference(evt: ref<QuestSpotTargetReference>) -> EntityNotificationType {
    let followedTargetIds: array<EntityID>;
    if EntityID.IsDefined(evt.m_ForcedTarget) {
      this.m_questTargetToSpot = evt.m_ForcedTarget;
    } else {
      GetFixedEntityIdsFromEntityReference(FromVariant(evt.prop.first), this.GetGameInstance(), followedTargetIds);
      if Cast(ArraySize(followedTargetIds)) {
        this.m_questTargetToSpot = followedTargetIds[0];
      } else {
        this.m_questTargetToSpot = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject().GetEntityID();
      };
    };
    if !EntityID.IsDefined(this.m_questTargetToSpot) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnQuestFollowTarget(evt: ref<QuestFollowTarget>) -> EntityNotificationType {
    let followedTargetIds: array<EntityID>;
    if this.IsBroken() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if EntityID.IsDefined(evt.m_ForcedTarget) {
      this.m_questForcedTargetID = evt.m_ForcedTarget;
    } else {
      GetFixedEntityIdsFromEntityReference(FromVariant(evt.prop.first), this.GetGameInstance(), followedTargetIds);
      if Cast(ArraySize(followedTargetIds)) {
        this.m_questForcedTargetID = followedTargetIds[0];
      } else {
        this.m_questForcedTargetID = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject().GetEntityID();
      };
    };
    if !EntityID.IsDefined(this.m_questForcedTargetID) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_isInFollowMode = true;
    if this.IsOFF() && !this.IsBroken() {
      this.ExecutePSAction(this.ActionToggleON());
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnQuestStopFollowingTarget(evt: ref<QuestStopFollowingTarget>) -> EntityNotificationType {
    evt.targetEntityID = this.m_questForcedTargetID;
    this.m_questForcedTargetID = new EntityID();
    this.m_isInFollowMode = false;
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnQuestLookAtTarget(evt: ref<QuestLookAtTarget>) -> EntityNotificationType {
    let followedTargetIds: array<EntityID>;
    if this.IsOFF() {
      this.ForceDeviceON();
    };
    GetFixedEntityIdsFromEntityReference(FromVariant(evt.prop.first), this.GetGameInstance(), followedTargetIds);
    if Cast(ArraySize(followedTargetIds)) {
      this.m_questForcedTargetID = followedTargetIds[0];
    } else {
      this.m_questForcedTargetID = this.GetPlayerEntityID();
    };
    if !EntityID.IsDefined(this.m_questForcedTargetID) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_isInFollowMode = true;
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnQuestStopLookAtTarget(evt: ref<QuestStopLookAtTarget>) -> EntityNotificationType {
    this.m_questForcedTargetID = new EntityID();
    this.m_isInFollowMode = false;
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnQuestForceTakeControlOverCamera(evt: ref<QuestForceTakeControlOverCamera>) -> EntityNotificationType {
    this.SendQuestTakeOverControlRequest(false);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnQuestForceTakeControlOverCameraWithChain(evt: ref<QuestForceTakeControlOverCameraWithChain>) -> EntityNotificationType {
    this.SendQuestTakeOverControlRequest(true);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func SendQuestTakeOverControlRequest(shouldCreateChain: Bool) -> Void {
    let inputLockRequest: ref<RequestQuestTakeControlInputLock> = new RequestQuestTakeControlInputLock();
    inputLockRequest.isLocked = true;
    inputLockRequest.isChainForced = shouldCreateChain;
    (GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"TakeOverControlSystem") as TakeOverControlSystem).QueueRequest(inputLockRequest);
    this.ExecutePSAction(this.ActionToggleTakeOverControl());
  }

  protected final func OnQuestForceStopTakeControlOverCamera(evt: ref<QuestForceStopTakeControlOverCamera>) -> EntityNotificationType {
    this.QuestReleaseCurrentObject();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func QuestReleaseCurrentObject() -> Void {
    let inputLockRequest: ref<RequestQuestTakeControlInputLock> = new RequestQuestTakeControlInputLock();
    inputLockRequest.isLocked = false;
    inputLockRequest.isChainForced = false;
    (GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"TakeOverControlSystem") as TakeOverControlSystem).QueueRequest(inputLockRequest);
    TakeOverControlSystem.ReleaseControl(this.GetGameInstance());
  }

  protected final func OnQuestSetDetectionToTrue(evt: ref<QuestSetDetectionToTrue>) -> EntityNotificationType {
    this.SetCanDetectIntruders(true);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnQuestSetDetectionToFalse(evt: ref<QuestSetDetectionToFalse>) -> EntityNotificationType {
    this.SetCanDetectIntruders(false);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnSetDeviceAttitude(evt: ref<SetDeviceAttitude>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnQuestForceAttitude(evt: ref<QuestForceAttitude>) -> EntityNotificationType {
    if IsNameValid(FromVariant(evt.prop.first)) {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnRevealEnemiesProgram(evt: ref<RevealEnemiesProgram>) -> EntityNotificationType {
    this.m_canTagEnemies = true;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func IsAttitudeFromContextHostile() -> Bool {
    let playerAttitude: ref<AttitudeAgent> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetAttitudeAgent();
    let myAttitude: ref<AttitudeAgent> = (GameInstance.FindEntityByID(this.GetGameInstance(), this.GetMyEntityID()) as SensorDevice).GetAttitudeAgent();
    return NotEquals(playerAttitude.GetAttitudeTowards(myAttitude), EAIAttitude.AIA_Friendly);
  }

  public final func OnForceIgnoreTargets(evt: ref<ForceIgnoreTargets>) -> EntityNotificationType {
    this.ExecutePSAction(this.ActionSetDeviceAttitude());
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func NotifyAboutSpottingPlayer(doSee: Bool) -> Void {
    let playerSpotted: ref<PlayerSpotted>;
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if !IsDefined(secSys) {
      return;
    };
    playerSpotted = PlayerSpotted.Construct(false, this.GetID(), doSee, this.GetSecurityAreas());
    this.QueuePSEvent(secSys, playerSpotted);
  }

  protected final func OnSecuritySystemSupport(evt: ref<SecuritySystemSupport>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSecuritySystemSupport(evt: ref<ReactoToPreventionSystem>) -> EntityNotificationType {
    if evt.wakeUp {
      this.ExecutePSAction(this.ActionQuestForceON());
    } else {
      this.ExecutePSAction(this.ActionQuestForceOFF());
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSetDeviceTagKillMode(evt: ref<SetDeviceTagKillMode>) -> EntityNotificationType {
    this.SetIsInTagKillMode(true);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func DrawBetweenEntities(shouldDraw: Bool, focusModeOnly: Bool, fxResource: FxResource, masterID: EntityID, slaveID: EntityID, revealMaster: Bool, revealSlave: Bool, opt onlyRemoveWeakLink: Bool, opt isEyeContact: Bool) -> Void {
    let currentID: EntityID;
    let masterPuppet: ref<ScriptedPuppet>;
    let newLink: SNetworkLinkData;
    let registerLinkRequest: ref<RegisterNetworkLinkRequest>;
    let slavePuppet: ref<ScriptedPuppet>;
    let unregisterLinkRequest: ref<UnregisterNetworkLinkBetweenTwoEntitiesRequest>;
    let unregisterLinkRequestByID: ref<UnregisterNetworkLinksByIDRequest>;
    newLink.slaveID = slaveID;
    newLink.masterID = masterID;
    if shouldDraw {
      masterPuppet = GameInstance.FindEntityByID(this.GetGameInstance(), masterID) as ScriptedPuppet;
      slavePuppet = GameInstance.FindEntityByID(this.GetGameInstance(), slaveID) as ScriptedPuppet;
      newLink.weakLink = isEyeContact;
      if masterPuppet != null {
        newLink.masterPos = masterPuppet.GetWorldPosition();
      };
      if slavePuppet != null {
        newLink.slavePos = slavePuppet.GetWorldPosition();
      };
      newLink.linkType = ELinkType.NETWORK;
      newLink.isDynamic = true;
      newLink.fxResource = fxResource;
      newLink.revealMaster = revealMaster;
      newLink.revealSlave = revealSlave;
      newLink.drawLink = true;
      if focusModeOnly {
        newLink.isNetrunner = true;
      } else {
        newLink.isPing = true;
      };
      registerLinkRequest = new RegisterNetworkLinkRequest();
      ArrayPush(registerLinkRequest.linksData, newLink);
      this.GetNetworkSystem().QueueRequest(registerLinkRequest);
    } else {
      if EntityID.IsDefined(masterID) && EntityID.IsDefined(slaveID) {
        unregisterLinkRequest = new UnregisterNetworkLinkBetweenTwoEntitiesRequest();
        unregisterLinkRequest.firstID = slaveID;
        unregisterLinkRequest.secondID = masterID;
        unregisterLinkRequest.onlyRemoveWeakLink = onlyRemoveWeakLink;
        this.GetNetworkSystem().QueueRequest(unregisterLinkRequest);
      } else {
        if EntityID.IsDefined(masterID) {
          currentID = masterID;
        } else {
          if EntityID.IsDefined(slaveID) {
            currentID = slaveID;
          };
        };
        unregisterLinkRequestByID = new UnregisterNetworkLinksByIDRequest();
        unregisterLinkRequestByID.ID = currentID;
        this.GetNetworkSystem().QueueRequest(unregisterLinkRequestByID);
      };
    };
  }

  public final func ClearLinkedStatusEffect() -> Void {
    let emptyID: EntityID;
    ArrayClear(this.m_linkedStatusEffect.netrunnerIDs);
    ArrayClear(this.m_linkedStatusEffect.statusEffectList);
    this.m_linkedStatusEffect.targetID = emptyID;
  }
}
