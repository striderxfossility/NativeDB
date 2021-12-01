
public class QuestForceAttitude extends ActionName {

  public final func SetProperties(atttitudeName: CName) -> Void {
    this.actionName = n"QuestForceAttitude";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Name(n"atttitudeName", atttitudeName);
  }
}

public class TargetedObjectDeathListener extends CustomValueStatPoolsListener {

  public let m_lsitener: wref<SensorDevice>;

  public let m_lsitenTarget: wref<GameObject>;

  protected cb func OnStatPoolMinValueReached(value: Float) -> Bool {
    if IsDefined(this.m_lsitenTarget) {
      this.m_lsitener.UnregisterListenerOnTargetHP(this.m_lsitener, this);
    };
  }
}

public class SensorDevice extends ExplosiveDevice {

  protected let m_attitudeAgent: ref<AttitudeAgent>;

  protected let m_senseComponent: ref<SenseComponent>;

  protected let m_visibleObjectComponent: ref<VisibleObjectComponent>;

  private let m_forwardFaceSlotComponent: ref<SlotComponent>;

  private let m_targetingComponent: ref<TargetingComponent>;

  private let m_targetTrackerComponent: ref<TargetTrackerComponent>;

  protected let m_cameraComponentInverted: ref<CameraComponent>;

  private let m_targets: array<ref<Target>>;

  private let m_currentlyFollowedTarget: wref<GameObject>;

  protected let m_currentLookAtEventVert: ref<LookAtAddEvent>;

  protected let m_currentLookAtEventHor: ref<LookAtAddEvent>;

  private let m_HPListenersList: array<ref<TargetedObjectDeathListener>>;

  @default(SensorDevice, ESensorDeviceStates.IDLE)
  private let m_sensorDeviceState: ESensorDeviceStates;

  @default(SensorDevice, ESensorDeviceWakeState.NONE)
  private let m_sensorWakeState: ESensorDeviceWakeState;

  private let m_sensorWakeStatePrevious: ESensorDeviceWakeState;

  private let m_targetingDelayEventID: DelayID;

  private let hack_isTargetingDelayEventFilled: Bool;

  private let m_currentResolveDelayEventID: DelayID;

  private let hack_isResolveDelayEventFilled: Bool;

  private let m_animFeatureData: ref<AnimFeature_SensorDevice>;

  private let m_animFeatureDataName: CName;

  private let m_targetLostBySensesDelayEventID: DelayID;

  private let hack_isTargetLostBySensesDelEvtFilled: Bool;

  private let m_initialAttitude: CName;

  private let m_detectionFactorMultiplier: Float;

  private let m_taggedListenerCallback: ref<CallbackHandle>;

  protected let m_lightScanRefs: array<ref<gameLightComponent>>;

  protected let m_lightAttitudeRefs: array<ref<gameLightComponent>>;

  protected let m_lightInfoRefs: array<ref<gameLightComponent>>;

  protected let m_lightColors: LedColors_SensorDevice;

  protected let m_deviceFXRecord: ref<DeviceFX_Record>;

  protected let m_scanGameEffect: ref<EffectInstance>;

  @default(SensorDevice, laser)
  protected let m_scanFXSlotName: CName;

  protected let m_visionConeEffectInstance: ref<EffectInstance>;

  protected let m_idleGameEffectInstance: ref<EffectInstance>;

  private let m_targetForcedFormTagKill: Bool;

  private let m_hasSupport: Bool;

  @default(SecurityTurret, Senses.BasicTurret)
  @default(SensorDevice, Senses.BasicCamera)
  protected let m_defaultSensePreset: TweakDBID;

  @attrib(category, "Sensor entity specific data")
  protected edit const let m_elementsToHideOnTCS: array<CName>;

  protected let m_elementsToHideOnTCSRefs: array<ref<IPlacedComponent>>;

  public let m_previoustagKillList: array<wref<GameObject>>;

  @attrib(category, "Sensor entity specific data")
  @default(SensorDevice, true)
  protected edit let m_playIdleSoundOnIdle: Bool;

  @attrib(category, "Sensor entity specific data")
  @attrib(customEditor, "AudioEvent")
  @default(SecurityTurret, idleStart)
  @default(SurveillanceCamera, dev_surveillance_camera_rotating)
  protected edit let m_idleSound: CName;

  @attrib(category, "Sensor entity specific data")
  @attrib(customEditor, "AudioEvent")
  @default(SecurityTurret, idleStop)
  @default(SurveillanceCamera, dev_surveillance_camera_rotating_stop)
  protected edit let m_idleSoundStop: CName;

  @attrib(category, "Sensor entity specific data")
  @attrib(customEditor, "AudioEvent")
  @default(SecurityTurret, activated)
  protected edit let m_soundDeviceON: CName;

  @attrib(category, "Sensor entity specific data")
  @attrib(customEditor, "AudioEvent")
  @default(SecurityTurret, deactivated)
  protected edit let m_soundDeviceOFF: CName;

  private let m_idleSoundIsPlaying: Bool;

  @default(SecurityTurret, destroyed)
  protected let m_soundDeviceDestroyed: CName;

  @default(SurveillanceCamera, dev_surveillance_camera_detection_loop_start)
  protected let m_soundDetectionLoop: CName;

  @default(SurveillanceCamera, dev_surveillance_camera_detection_loop_stop)
  protected let m_soundDetectionLoopStop: CName;

  private let m_isPLAYERSAFETargetLock: Bool;

  private let m_playerDetected: Bool;

  @default(SensorDevice, false)
  private let m_clientForceSetAnimFeature: Bool;

  private let m_playerControlData: PlayerControlDeviceData;

  private let engineTimeInSec: Float;

  private let TCExitEngineTime: Float;

  private let hack_wasTargetReevaluated: Bool;

  private let hack_wasSSOutupFromSelf: Bool;

  private let degbu_SS_inputsSend: Int32;

  private let debug_SS_inputsSendTargetLock: Int32;

  private let debug_SS_inputsSendIntresting: Int32;

  private let debug_SS_inputsSendLoseTarget: Int32;

  private let debug_SS_outputRecieved: Int32;

  private let debug_SS_outputFormSelfRecieved: Int32;

  private let debug_SS_outputFromElseRecieved: Int32;

  private let debug_SS_reevaluatesDone: Int32;

  private let debug_SS_trespassingRecieved: Int32;

  private let debug_SS_TargetAssessmentRequest: Int32;

  @attrib(category, "Sensor entity specific data")
  @default(SensorDevice, -70)
  protected edit let m_minPitch: Float;

  @attrib(category, "Sensor entity specific data")
  @default(SensorDevice, 70)
  protected edit let m_maxPitch: Float;

  @attrib(category, "Sensor entity specific data")
  @default(SensorDevice, 0)
  protected edit let m_minYaw: Float;

  @attrib(category, "Sensor entity specific data")
  @default(SensorDevice, 0)
  protected edit let m_maxYaw: Float;

  protected final func ResolveConnectionWithSecuritySystemByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"ResolveConnectionWithSecuritySystemTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func ResolveConnectionWithSecuritySystemTask(data: ref<ScriptTaskData>) -> Void {
    this.ResolveConnectionWithSecuritySystem();
  }

  protected final func ResolveConnectionWithSecuritySystem() -> Void {
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if IsDefined(secSys) {
      secSys.RequestLatestOutput(Cast(this.GetEntityID()));
      if !(this.GetDevicePS() as SensorDeviceControllerPS).IsAttitudeChanged() {
        if IsDefined(this.m_attitudeAgent) {
          this.m_attitudeAgent.SetAttitudeGroup(secSys.GetSecuritySystemAttitudeGroupName());
        };
      };
    };
  }

  protected final func HandleSecuritySystemOutputByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"HandleSecuritySystemOutputTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func HandleSecuritySystemOutputTask(data: ref<ScriptTaskData>) -> Void {
    this.HandleSecuritySystemOutput();
  }

  protected final func HandleSecuritySystemOutput() -> Void {
    if this.GetDevicePS().IsControlledByPlayer() || this.GetDevicePS().IsSecurityWakeUpBlocked() || (this.GetDevicePS() as SensorDeviceControllerPS).IsAttitudeChanged() {
      return;
    };
    this.SetSensePresetBasedOnSSState();
    this.BlinkSecurityLight(2);
    this.DetermineLightInfoRefs(this.m_lightColors.blue);
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32;
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"AttitudeAgent", n"AttitudeAgent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"detectionAreaIndicator", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"senseComponent", n"SenseComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"slot", n"SlotComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"TargetTracker", n"TargetTrackerComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"cameraComponentInvert", n"CameraComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"senseVisibleObject", n"VisibleObjectComponent", false);
    i = 0;
    while i < ArraySize(this.m_elementsToHideOnTCS) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_elementsToHideOnTCS[i], n"IPlacedComponent", false);
      i += 1;
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let component: ref<IPlacedComponent>;
    let i: Int32;
    this.m_attitudeAgent = EntityResolveComponentsInterface.GetComponent(ri, n"AttitudeAgent") as AttitudeAgent;
    this.m_senseComponent = EntityResolveComponentsInterface.GetComponent(ri, n"senseComponent") as SenseComponent;
    this.m_visibleObjectComponent = EntityResolveComponentsInterface.GetComponent(ri, n"senseVisibleObject") as VisibleObjectComponent;
    this.m_forwardFaceSlotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"slot") as SlotComponent;
    this.m_targetingComponent = EntityResolveComponentsInterface.GetComponent(ri, n"targeting") as TargetingComponent;
    this.m_targetTrackerComponent = EntityResolveComponentsInterface.GetComponent(ri, n"TargetTracker") as TargetTrackerComponent;
    this.m_cameraComponentInverted = EntityResolveComponentsInterface.GetComponent(ri, n"cameraComponentInvert") as CameraComponent;
    this.m_cameraComponentInverted.SetIsHighPriority(true);
    i = 0;
    while i < ArraySize(this.m_elementsToHideOnTCS) {
      component = EntityResolveComponentsInterface.GetComponent(ri, this.m_elementsToHideOnTCS[i]) as IPlacedComponent;
      if IsDefined(component) {
        ArrayPush(this.m_elementsToHideOnTCSRefs, component);
      };
      i += 1;
    };
    this.m_animFeatureData = new AnimFeature_SensorDevice();
    this.m_animFeatureDataName = n"SensorDeviceData";
    super.OnTakeControl(ri);
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void {
    let i: Int32;
    let targetVisible: String;
    let targets: array<ref<Target>>;
    this.OnMaraudersMapDeviceDebug(sink);
    sink.BeginCategory("sensorDevice specific");
    sink.BeginCategory("Targets");
    targets = this.GetCurrentTargets();
    i = 0;
    while i < ArraySize(targets) {
      if targets[i].IsVisible() {
        targetVisible = "|V| ";
      } else {
        targetVisible = "|N| ";
      };
      sink.PushString("Target " + i, targetVisible + EntityID.ToDebugString(targets[i].GetTarget().GetEntityID()));
      i += 1;
    };
    sink.EndCategory();
    sink.PushBool("Is Part of Prevention", this.IsPrevention());
    sink.PushString("Sensor Device State", EnumValueToString("ESensorDeviceStates", Cast(EnumInt(this.GetSensorDeviceState()))));
    sink.PushString("Currnet Target", EntityID.ToDebugString(this.GetCurrentlyFollowedTarget().GetEntityID()));
    sink.PushBool("HasSupport", this.m_hasSupport);
    sink.PushBool("PlayerSafeTargeLock", this.IsPlayerSafeTargetLock());
    sink.PushBool("Is Quest Target Spotted", (this.GetDevicePS() as SensorDeviceControllerPS).IsQuestTargetSpotted());
    sink.PushString("Quest Target to Spot", EntityID.ToDebugString((this.GetDevicePS() as SensorDeviceControllerPS).GetQuestSpotTargetID()));
    sink.PushString("Quest Forced TargetID", EntityID.ToDebugString((this.GetDevicePS() as SensorDeviceControllerPS).GetForcedTargetID()));
    sink.PushString("Attitude", NameToString(this.GetAttitudeAgent().GetAttitudeGroup()));
    sink.PushBool("Is Attitude Changed", (this.GetDevicePS() as SensorDeviceControllerPS).IsAttitudeChanged());
    sink.PushBool("Is Temporary Attitude Changed", this.IsTemporaryAttitudeChanged());
    sink.PushBool("Is in follow mode", (this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode());
    sink.PushBool("Is in Tag Kill Mode", (this.GetDevicePS() as SensorDeviceControllerPS).IsInTagKillMode());
    sink.PushBool("Is Target Forced Tag Kill", this.IsTargetForcedFromTagKill());
    sink.PushBool("Is Idle Forced", (this.GetDevicePS() as SensorDeviceControllerPS).IsIdleForced());
    sink.PushBool("Is Detecting", (this.GetDevicePS() as SensorDeviceControllerPS).IsDetectingDebug());
    sink.PushBool("Can Rotate", (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourCanRotate());
    sink.BeginCategory("Anim Feature");
    sink.PushBool("Is Turned On", this.m_animFeatureData.isTurnedOn);
    sink.PushBool("Is Destroyed", this.m_animFeatureData.isDestroyed);
    sink.PushBool("Was Hit", this.m_animFeatureData.wasHit);
    sink.PushInt32("State", this.m_animFeatureData.state);
    sink.PushBool("Is Controlled", this.m_animFeatureData.isControlled);
    sink.PushFloat("Override Root Rotation", this.m_animFeatureData.overrideRootRotation);
    sink.PushFloat("Max Rotation Angle", this.m_animFeatureData.maxRotationAngle);
    sink.EndCategory();
    sink.EndCategory();
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.InitializeDeviceFXRecord();
    this.InitializeLights();
    this.ToggleActiveEffect(true);
  }

  protected cb func OnPostInitialize(evt: ref<entPostInitializeEvent>) -> Bool {
    super.OnPostInitialize(evt);
    this.m_senseComponent.Toggle(false);
    this.m_defaultSensePreset = this.m_senseComponent.GetCurrentPreset();
    if IsDefined(this.m_visibleObjectComponent) {
      this.m_visibleObjectComponent.Toggle(false);
    };
    this.ResolveConnectionWithSecuritySystem();
  }

  protected cb func OnPreUninitialize(evt: ref<entPreUninitializeEvent>) -> Bool {
    super.OnPreUninitialize(evt);
    if this.IsPrevention() {
      PreventionSystem.UnRegisterToPreventionSystem(this.GetGame(), this);
    };
    this.TerminateGameEffect(this.m_scanGameEffect);
    this.TerminateGameEffect(this.m_visionConeEffectInstance);
    this.TerminateGameEffect(this.m_idleGameEffectInstance);
    this.ClearAllHPListeners();
    (this.GetDevicePS() as SensorDeviceControllerPS).NotifyAboutSpottingPlayer(false);
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if this.IsPrevention() {
      PreventionSystem.RegisterToPreventionSystem(this.GetGame(), this);
    };
    if IsClient() {
      this.m_clientForceSetAnimFeature = true;
    };
    this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
    if IsClient() {
      this.m_clientForceSetAnimFeature = false;
    };
    this.CreateLightSettings();
  }

  protected cb func OnDetach() -> Bool {
    let tcsEvt: ref<TCSTakeOverControlDeactivate>;
    super.OnDetach();
    this.ForceCancelAllForcedBehaviours();
    if EntityID.IsDynamic(this.GetEntityID()) {
      if this.GetDevicePS().IsControlledByPlayer() {
        (this.GetDevicePS() as SensorDeviceControllerPS).QuestReleaseCurrentObject();
        tcsEvt = new TCSTakeOverControlDeactivate();
        this.OnTCSTakeOverControlDeactivate(tcsEvt);
      };
    };
  }

  public const func IsSensor() -> Bool {
    return true;
  }

  public const func IsPrevention() -> Bool {
    return (this.GetDevicePS() as SensorDeviceControllerPS).IsPartOfPrevention();
  }

  public final const func GetDeviceFXRecord() -> ref<DeviceFX_Record> {
    return this.m_deviceFXRecord;
  }

  public const func IsSurveillanceCamera() -> Bool {
    return false;
  }

  public final const func HasSupport() -> Bool {
    return this.m_hasSupport;
  }

  protected final func SetHasSupport(value: Bool) -> Void {
    this.m_hasSupport = value;
  }

  protected final func CreateLightSettings() -> Void {
    this.m_lightColors.off.strength = 0.00;
    this.m_lightColors.off.color = new Color(0u, 0u, 0u, 0u);
    this.m_lightColors.red.strength = 1.00;
    this.m_lightColors.red.color = new Color(251u, 147u, 46u, 0u);
    this.m_lightColors.green.strength = 1.00;
    this.m_lightColors.green.color = new Color(28u, 236u, 130u, 0u);
    this.m_lightColors.off.strength = 1.00;
    this.m_lightColors.blue.strength = 1.00;
    this.m_lightColors.blue.color = new Color(40u, 40u, 130u, 0u);
    this.m_lightColors.yellow.strength = 1.00;
    this.m_lightColors.yellow.color = new Color(50u, 50u, 0u, 0u);
    this.m_lightColors.white.strength = 1.00;
    this.m_lightColors.white.color = new Color(255u, 255u, 255u, 0u);
  }

  public const func GetAttitudeAgent() -> ref<AttitudeAgent> {
    return this.m_attitudeAgent;
  }

  public const func GetTargetTrackerComponent() -> ref<TargetTrackerComponent> {
    return this.m_targetTrackerComponent;
  }

  public const func GetSensesComponent() -> ref<SenseComponent> {
    return this.m_senseComponent;
  }

  public final const func GetVisibleObjectComponent() -> ref<VisibleObjectComponent> {
    return this.m_visibleObjectComponent;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public final const func GetAnimFeatureInCurrentState() -> ref<AnimFeature_SensorDevice> {
    return this.m_animFeatureData;
  }

  public final const func IsPlayerSafeTargetLock() -> Bool {
    return this.m_isPLAYERSAFETargetLock;
  }

  public final const func IsTargetForcedFromTagKill() -> Bool {
    return this.m_targetForcedFormTagKill;
  }

  public final const func GetCurrentTargets() -> array<ref<Target>> {
    return this.m_targets;
  }

  public final const func GetSensorDeviceState() -> ESensorDeviceStates {
    return this.m_sensorDeviceState;
  }

  public final const func GetRotationData() -> CameraRotationData {
    let res: CameraRotationData;
    res.m_pitch = this.m_playerControlData.m_currentPitchModifier;
    res.m_minPitch = this.m_minPitch;
    res.m_maxPitch = this.m_maxPitch;
    res.m_yaw = this.m_playerControlData.m_currentYawModifier;
    res.m_minYaw = this.m_minYaw;
    res.m_maxYaw = this.m_maxYaw;
    return res;
  }

  private final func UpdateAnimFeatureWakeState() -> Void {
    this.m_animFeatureData.wakeState = EnumInt(this.m_sensorWakeState);
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }

  public func ApplyAnimFeatureToReplicate(obj: ref<GameObject>, inputName: CName, value: ref<AnimFeature>) -> Void {
    if this.m_clientForceSetAnimFeature {
      AnimationControllerComponent.ApplyFeature(obj, inputName, value);
    } else {
      this.ApplyAnimFeatureToReplicate(obj, inputName, value);
    };
  }

  public final const func GetCurrentlyFollowedTarget() -> wref<GameObject> {
    return this.m_currentlyFollowedTarget;
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.RemoveAllTargets();
    this.TerminateGameEffect(this.m_scanGameEffect);
    GameObject.StopSoundEvent(this, this.m_soundDetectionLoop);
    this.ToggleActiveEffect(false);
    this.BreakTargeting();
    this.BreakBehaviourResolve();
    this.LookAtStop();
    this.OnAllValidTargetsDisappears();
    this.CancelLosetargetFalsePositiveDelay();
    this.TurnOffSenseComponent();
    if IsDefined(this.m_visibleObjectComponent) {
      this.m_visibleObjectComponent.Toggle(false);
    };
    this.ToggleAreaIndicator(false);
    this.m_isPLAYERSAFETargetLock = false;
    this.m_animFeatureData.isTurnedOn = false;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    GameObject.StopSoundEvent(this, this.m_idleSound);
    this.m_idleSoundIsPlaying = false;
    GameObject.PlaySoundEvent(this, this.m_soundDeviceOFF);
    gameLightComponent.ChangeAllLightsSettings(this, this.m_lightColors.off, 0.50, n"glitch");
    this.m_targetTrackerComponent.ClearThreats();
  }

  private final func TurnOffSenseComponent() -> Void {
    this.m_senseComponent.ToggleComponent(false);
    (this.GetDevicePS() as SensorDeviceControllerPS).NotifyAboutSpottingPlayer(false);
  }

  protected cb func OnTurnOnVisibilitySenseComponent(evt: ref<TurnOnVisibilitySenseComponent>) -> Bool {
    if IsDefined(this.m_visibleObjectComponent) {
      this.m_visibleObjectComponent.Toggle(true);
    };
  }

  protected func TurnOnDevice() -> Void {
    if Equals(this.GetDevicePS().GetDurabilityState(), EDeviceDurabilityState.BROKEN) {
      return;
    };
    if !this.GetDevicePS().IsControlledByPlayer() {
      this.m_senseComponent.ToggleComponent(true);
    };
    if !this.GetDevicePS().IsControlledByPlayer() && !(this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode() && !this.HasSupport() {
      this.ForceStartBehaviorResolve(ESensorDeviceStates.IDLE);
    };
    this.InitializeLights();
    this.ToggleActiveEffect(true);
    GameObject.PlaySoundEvent(this, this.m_soundDeviceON);
    this.m_animFeatureData.isTurnedOn = true;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }

  protected cb func OnHit(hit: ref<gameHitEvent>) -> Bool {
    hit.attackData.AddFlag(hitFlag.FriendlyFire, n"sensorDevice");
    super.OnHit(hit);
    if this.GetDevicePS().IsON() {
      if this.m_animFeatureData.wasHit {
        this.m_animFeatureData.wasHit = false;
      } else {
        this.m_animFeatureData.wasHit = true;
      };
      this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
      this.OneShotLookAtPosition(hit.attackData.GetInstigator().GetWorldPosition());
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    super.OnDeath(evt);
    this.DestroySensor();
    if this.GetDevicePS().IsControlledByPlayer() {
      TakeOverControlSystem.ReleaseControl(this.GetGame());
    };
  }

  protected final func DestroySensor() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"broken");
    this.m_animFeatureData.isDestroyed = true;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    this.FindAndRewardKiller(gameKillType.Normal);
    this.GetDevicePS().SetDurabilityState(EDeviceDurabilityState.BROKEN);
    this.m_senseComponent.RemoveSenseMappin();
    if IsDefined(this.m_visibleObjectComponent) {
      this.m_visibleObjectComponent.Toggle(false);
    };
    GameObject.PlaySoundEvent(this, this.m_soundDeviceDestroyed);
    (this.GetDevicePS() as SensorDeviceControllerPS).NotifyAboutSpottingPlayer(false);
    this.RequestHUDRefresh();
  }

  protected func GetHitSourcePosition(hitSourceEntityID: EntityID) -> Vector4 {
    return this.GetPotentialHitSourcePosition(hitSourceEntityID);
  }

  private final func GetPotentialHitSourcePosition(hitSourceEntityID: EntityID) -> Vector4 {
    let target: ref<Target>;
    if this.m_playerDetected {
      target = SimpleTargetManager.GetSpecificTarget(this.m_targets, hitSourceEntityID);
      if IsDefined(target) {
        return target.GetTarget().GetWorldPosition();
      };
    };
    return this.GetWorldPosition();
  }

  private final func RegisterListenerOnTargetHP(target: ref<GameObject>) -> Void {
    let HPStatListener: ref<TargetedObjectDeathListener>;
    let targetID: EntityID = target.GetEntityID();
    let i: Int32 = 0;
    while i < ArraySize(this.m_HPListenersList) {
      if this.m_HPListenersList[i].m_lsitenTarget == target {
        return;
      };
      i += 1;
    };
    HPStatListener = new TargetedObjectDeathListener();
    HPStatListener.m_lsitener = this;
    HPStatListener.m_lsitenTarget = target;
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestRegisteringListener(Cast(targetID), gamedataStatPoolType.Health, HPStatListener);
    ArrayPush(this.m_HPListenersList, HPStatListener);
  }

  public final const func UnregisterListenerOnTargetHP(listeningObject: wref<GameObject>, listener: ref<TargetedObjectDeathListener>) -> Void {
    let evt: ref<UnregisterListenerOnTargetHPEvent> = new UnregisterListenerOnTargetHPEvent();
    evt.listener = listener;
    evt.isFromListenerEvent = true;
    listeningObject.QueueEvent(evt);
  }

  protected final func UnregisterListenerOnTargetHP(listeningObject: wref<GameObject>, lostObject: wref<GameObject>) -> Void {
    let listener: ref<TargetedObjectDeathListener>;
    let evt: ref<UnregisterListenerOnTargetHPEvent> = new UnregisterListenerOnTargetHPEvent();
    let i: Int32 = 0;
    while i < ArraySize(this.m_HPListenersList) {
      if this.m_HPListenersList[i].m_lsitenTarget == lostObject {
        listener = this.m_HPListenersList[i];
      } else {
        i += 1;
      };
    };
    if IsDefined(listener) {
      evt.listener = listener;
      this.OnUnregisterListenerOnTargetHPEvent(evt);
    } else {
      if !IsFinal() {
        LogDevices(this, " [HPEvent] Target was not found on HP listeners list ");
      };
    };
  }

  protected cb func OnUnregisterListenerOnTargetHPEvent(evt: ref<UnregisterListenerOnTargetHPEvent>) -> Bool {
    if this.m_targetForcedFormTagKill && evt.listener.m_lsitenTarget == this.m_currentlyFollowedTarget {
      this.RevertTepmoraryAttitude();
      this.m_targetForcedFormTagKill = false;
    };
    if !IsFinal() {
      LogDevices(this, " [HPEvent] Target " + NameToString(evt.listener.m_lsitenTarget.GetClassName()) + EntityID.ToDebugString(evt.listener.m_lsitenTarget.GetEntityID()) + " was killed ");
    };
    ArrayRemove(this.m_HPListenersList, evt.listener);
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(evt.listener.m_lsitenTarget.GetEntityID()), gamedataStatPoolType.Health, evt.listener);
    if evt.isFromListenerEvent {
      this.LoseTarget(evt.listener.m_lsitenTarget, true);
    };
  }

  private final func ClearAllHPListeners() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_HPListenersList) {
      GameInstance.GetStatPoolsSystem(this.GetGame()).RequestUnregisteringListener(Cast(this.m_HPListenersList[i].m_lsitenTarget.GetEntityID()), gamedataStatPoolType.Health, this.m_HPListenersList[i]);
      i += 1;
    };
    ArrayClear(this.m_HPListenersList);
  }

  protected cb func OnSetJammedEvent(evt: ref<SetJammedEvent>) -> Bool {
    if evt.newJammedState && NotEquals(this.m_sensorDeviceState, ESensorDeviceStates.JAMMER) {
      this.BreakTargeting();
      this.BreakBehaviourResolve();
      this.OnAllValidTargetsDisappears();
      this.TurnOffSenseComponent();
      this.ForceStartBehaviorResolve(ESensorDeviceStates.JAMMER);
      this.RemoveAllTargets();
    } else {
      this.TurnOnDevice();
      this.ForceStartBehaviorResolve(ESensorDeviceStates.IDLE);
    };
  }

  public func SetAsIntrestingTarget(target: wref<GameObject>) -> Bool {
    let isIntresting: Bool;
    if this.GetDevicePS().IsConnectedToSecuritySystem() && !(this.GetDevicePS() as SensorDeviceControllerPS).IsAttitudeChanged() {
      isIntresting = this.GetDevicePS().GetSecuritySystem().ShouldReactToTarget(target.GetEntityID(), this.GetEntityID());
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget][SetIntresting] Target was set as: " + BoolToString(isIntresting) + " By security system ");
      };
      return isIntresting;
    };
    isIntresting = Equals(GameObject.GetAttitudeTowards(this, target), EAIAttitude.AIA_Hostile);
    if !IsFinal() {
      LogDevices(this, " [RecognizeTarget][SetIntresting] Target was set as: " + BoolToString(isIntresting) + "  By security device attitude ");
    };
    return isIntresting;
  }

  public func OnValidTargetAppears(target: wref<GameObject>) -> Void;

  public func OnCurrentTargetAppears(target: wref<GameObject>) -> Void {
    let securityState: ESecuritySystemState;
    if this.GetDevicePS().IsControlledByPlayer() {
      return;
    };
    this.DetermineLightScanRefs(this.m_lightColors.red);
    if this.m_targetForcedFormTagKill || (this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode() {
      if !IsFinal() {
        LogDevices(this, " [CurrentTargetApperas] Forced target. StartLockingTarget called ");
      };
      this.ChangeTemporaryAttitude();
      this.StartBehaviourResolve(ESensorDeviceStates.TARGETLOCK);
      this.StartLockingTarget(0.00);
      return;
    };
    if this.GetDevicePS().IsConnectedToSecuritySystem() && !(this.GetDevicePS() as SensorDeviceControllerPS).IsAttitudeChanged() {
      securityState = this.GetDevicePS().GetSecuritySystem().GetSecurityState();
      if Equals(securityState, ESecuritySystemState.SAFE) {
        return;
      };
      if Equals(securityState, ESecuritySystemState.ALERTED) {
        this.StartBehaviourResolve(ESensorDeviceStates.TARGETLOCK);
        return;
      };
      if Equals(securityState, ESecuritySystemState.COMBAT) {
        this.StartBehaviourResolve(ESensorDeviceStates.TARGETLOCK);
        this.StartLockingTarget(0.00);
        return;
      };
    } else {
      this.StartBehaviourResolve(ESensorDeviceStates.TARGETLOCK);
      this.StartLockingTarget((this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourtimeToTakeAction());
    };
  }

  protected final func ChangeTemporaryAttitude() -> Void {
    let groupName: CName;
    let puppetAttitudeAgent: ref<AttitudeAgent>;
    if this.m_targetForcedFormTagKill || this.GetDevicePS().IsControlledByPlayer() {
      this.CacheInitialAttitude();
      puppetAttitudeAgent = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject().GetAttitudeAgent();
      groupName = puppetAttitudeAgent.GetAttitudeGroup();
      this.GetAttitudeAgent().SetAttitudeGroup(groupName);
      if !IsFinal() {
        LogDevices(this, " [TemporaryAttitude] attitude changet to player group: " + NameToString(groupName));
      };
    } else {
      if (this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode() {
        this.GetAttitudeAgent().SetAttitudeTowards(this.GetForcedTargetObject().GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
      };
    };
    this.DetermineLightAttitudeRefs();
  }

  private final func CacheInitialAttitude() -> Void {
    if Equals(this.m_initialAttitude, n"") {
      this.m_initialAttitude = this.GetAttitudeAgent().GetAttitudeGroup();
      if !IsFinal() {
        LogDevices(this, " [TemporaryAttitude] attitude catched as " + NameToString(this.m_initialAttitude));
      };
    };
  }

  private final func ClearInitialAttitude() -> Void {
    if !this.m_targetForcedFormTagKill {
      this.m_initialAttitude = n"";
    } else {
      if !IsFinal() {
        LogDevices(this, " [TemporaryAttitude] There was a try to clear m_initialAttitude when sensor is in m_targetForcedFormTagKill. Attempt rejected DEBUG IT! -- initial attitude: " + NameToString(this.m_initialAttitude) + " current attitude: " + NameToString(this.GetAttitudeAgent().GetAttitudeGroup()));
      };
    };
  }

  public final const func IsTemporaryAttitudeChanged() -> Bool {
    return Equals(this.m_initialAttitude, n"");
  }

  private final func RevertTepmoraryAttitude() -> Void {
    if NotEquals(this.m_initialAttitude, n"") {
      if !IsFinal() {
        LogDevices(this, " [TemporaryAttitude] attitude reverted to previous " + NameToString(this.m_initialAttitude));
      };
      this.GetAttitudeAgent().SetAttitudeGroup(this.m_initialAttitude);
      this.DetermineLightAttitudeRefs();
    };
  }

  protected cb func OnQhackExecuted(evt: ref<QhackExecuted>) -> Bool {
    this.ChangeTemporaryAttitude();
  }

  public func OnValidTargetDisappears(target: wref<GameObject>) -> Void {
    if target == this.m_currentlyFollowedTarget {
      if Equals(this.m_sensorDeviceState, ESensorDeviceStates.REPRIMAND) {
        this.degbu_SS_inputsSend += 1;
        this.debug_SS_inputsSendLoseTarget += 1;
        this.SendDefaultSSNotification(target, true);
      };
      this.BreakTargeting();
    };
  }

  public func OnAllValidTargetsDisappears() -> Void {
    this.RevertTepmoraryAttitude();
    (this.GetDevicePS() as SensorDeviceControllerPS).SetTargetIsLocked(false);
    this.DetermineLightScanRefs(this.m_lightColors.yellow);
  }

  protected func ToggleAreaIndicator(turnOn: Bool) -> Void {
    this.ToggleAreaIndicator(turnOn);
    if turnOn && this.GetDevicePS().IsON() {
      if !IsDefined(this.m_visionConeEffectInstance) {
        this.RunVisionConeGameEffect();
      };
      if this.m_disableAreaIndicatorDelayActive {
        GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_disableAreaIndicatorID);
        GameInstance.GetDelaySystem(this.GetGame()).CancelCallback(this.m_disableAreaIndicatorID);
        this.m_disableAreaIndicatorDelayActive = false;
      };
    } else {
      if !this.IsTaggedinFocusMode() {
        this.TerminateGameEffect(this.m_visionConeEffectInstance);
        this.m_visionConeEffectInstance = null;
      } else {
        if this.GetDevicePS().IsBroken() || !this.GetDevicePS().IsON() {
          this.TerminateGameEffect(this.m_visionConeEffectInstance);
          this.m_visionConeEffectInstance = null;
        };
      };
    };
  }

  protected func SendDisableAreaIndicatorEvent() -> Void {
    let disableAreaEvent: ref<DisableAreaIndicatorEvent> = new DisableAreaIndicatorEvent();
    this.m_disableAreaIndicatorID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, disableAreaEvent, 5.00);
    this.m_disableAreaIndicatorDelayActive = true;
  }

  protected func StartLockingTarget(lockingTime: Float) -> Void {
    let evt: ref<TargetLockedEvent> = new TargetLockedEvent();
    if !IsFinal() {
      LogDevices(this, " [TargetLocked] Locking with " + FloatToString(lockingTime) + " delay ");
    };
    if lockingTime <= 0.00 {
      this.OnTargetLocked(evt);
    } else {
      this.m_targetingDelayEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, lockingTime);
      this.hack_isTargetingDelayEventFilled = true;
    };
  }

  private final func BreakTargeting() -> Void {
    if this.hack_isTargetingDelayEventFilled {
      if !IsFinal() {
        LogDevices(this, " [TargetLocked] Targetting Break! ");
      };
      GameInstance.GetDelaySystem(this.GetGame()).CancelCallback(this.m_targetingDelayEventID);
      this.hack_isTargetingDelayEventFilled = false;
    };
  }

  private final func BreakBehaviourResolve() -> Void {
    if this.hack_isResolveDelayEventFilled {
      if !IsFinal() {
        LogDevices(this, " [Behaviour] Behaviour Break! ");
      };
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_currentResolveDelayEventID);
      this.hack_isResolveDelayEventFilled = false;
    };
  }

  protected cb func OnTargetLocked(evt: ref<TargetLockedEvent>) -> Bool {
    if !IsFinal() {
      LogDevices(this, " [TargetLocked] LOCKED actions are taken against target ( " + NameToString(this.m_currentlyFollowedTarget.GetClassName()) + EntityID.ToDebugString(this.m_currentlyFollowedTarget.GetEntityID()) + " ) ");
    };
    if EntityID.IsDefined((this.GetDevicePS() as SensorDeviceControllerPS).GetQuestSpotTargetID()) {
      if (this.GetDevicePS() as SensorDeviceControllerPS).GetQuestSpotTargetID() == this.m_currentlyFollowedTarget.GetEntityID() {
        (this.GetDevicePS() as SensorDeviceControllerPS).SetQuestTargetSpotted(true);
      };
    };
    (this.GetDevicePS() as SensorDeviceControllerPS).SetTargetIsLocked(true);
    if this.GetDevicePS().IsConnectedToSecuritySystem() {
      if !this.hack_wasTargetReevaluated {
        this.degbu_SS_inputsSend += 1;
        this.debug_SS_inputsSendTargetLock += 1;
        this.GetDevicePS().TriggerSecuritySystemNotification(this.m_currentlyFollowedTarget, this.m_currentlyFollowedTarget.GetWorldPosition(), ESecurityNotificationType.COMBAT);
      };
      this.BreakReprimand();
    };
  }

  protected cb func OnDetectionRiseEvent(evt: ref<DetectionRiseEvent>) -> Bool {
    let fakeDetectedEvent: ref<OnDetectedEvent>;
    let detection: Float = this.GetSensesComponent().GetDetection(evt.target.GetEntityID());
    if evt.isVisible && (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourCanDetectIntruders() {
      if evt.target.IsPlayer() && !this.m_isPLAYERSAFETargetLock && this.GetDetectionFactor() >= 0.00 {
        if !IsDefined(this.m_currentlyFollowedTarget) && !(this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode() {
          this.m_isPLAYERSAFETargetLock = true;
          if !IsFinal() {
            LogDevices(this, " [Detection] Detection rise to plyer. PLAYERSAFETargetLock is true ");
          };
          this.ForcedLookAtEntityWithoutTargetMODE(evt.target);
          GameObject.StopSoundEvent(this, this.m_idleSound);
          this.m_idleSoundIsPlaying = false;
          GameObject.PlaySoundEvent(this, this.m_idleSoundStop);
          if this.IsPrevention() {
            GameObject.PlaySoundEvent(this, n"gmp_turret_prevention_aim_on");
            PreventionSystem.ShowMessage(this.GetGame(), GetLocalizedText("LocKey#53103"), 5.00);
          } else {
            GameObject.PlaySoundEvent(this, n"dev_surveillance_camera_detect");
          };
          this.ToggleActiveEffect(false);
          this.RunGameEffect(this.m_scanGameEffect, (this.GetDevicePS() as SensorDeviceControllerPS).GetScanGameEffectRef(), this.m_scanFXSlotName, this.GetDeviceFXRecord().ScanGameEffectLength());
          GameObject.PlaySoundEvent(this, this.m_soundDetectionLoop);
          this.DetermineLightScanRefs(this.m_lightColors.blue);
          this.RecognizeTarget(evt.target, true);
          if detection >= 100.00 {
            fakeDetectedEvent = new OnDetectedEvent();
            fakeDetectedEvent.target = evt.target;
            fakeDetectedEvent.isVisible = evt.isVisible;
            fakeDetectedEvent.shapeId = evt.shapeId;
            fakeDetectedEvent.description = evt.description;
            this.OnOnDetectedEvent(fakeDetectedEvent);
          };
        };
      } else {
        if !IsFinal() {
          LogDevices(this, " [Detection] Detection rise to NOT plyer");
        };
        this.RecognizeTarget(evt.target);
      };
    };
  }

  protected cb func OnOnDetectedEvent(evt: ref<OnDetectedEvent>) -> Bool {
    if evt.isVisible {
      if evt.target.IsPlayer() {
        this.m_playerDetected = true;
        (this.GetDevicePS() as SensorDeviceControllerPS).NotifyAboutSpottingPlayer(true);
      };
      if evt.target == this.m_currentlyFollowedTarget {
        if !IsFinal() {
          LogDevices(this, " [Detection] Target: " + NameToString(evt.target.GetClassName()) + EntityID.ToDebugString(evt.target.GetEntityID()) + " fully detected ");
        };
        this.m_isPLAYERSAFETargetLock = false;
        this.TerminateGameEffect(this.m_scanGameEffect);
        this.ToggleActiveEffect(true);
        GameObject.StopSoundEvent(this, this.m_soundDetectionLoop);
        GameObject.PlaySoundEvent(this, this.m_soundDetectionLoopStop);
        this.SendDefaultSSNotification(evt.target, true);
        this.OnCurrentTargetAppears(evt.target);
      };
    } else {
      if evt.target.IsPlayer() {
        this.m_playerDetected = false;
      };
    };
  }

  protected cb func OnOnRemoveDetection(evt: ref<OnRemoveDetection>) -> Bool {
    this.SenseLoseTarget(evt.target);
  }

  protected final func SenseLoseTarget(target: ref<GameObject>) -> Void {
    if target.IsPlayer() {
      this.m_isPLAYERSAFETargetLock = false;
      (this.GetDevicePS() as SensorDeviceControllerPS).NotifyAboutSpottingPlayer(false);
      this.TerminateGameEffect(this.m_scanGameEffect);
      this.ToggleActiveEffect(true);
      GameObject.StopSoundEvent(this, this.m_soundDetectionLoop);
      GameObject.PlaySoundEvent(this, this.m_soundDetectionLoopStop);
      this.DetermineLightScanRefs(this.m_lightColors.yellow);
      this.CancelPLAYERSAFEDelayEvent();
    };
    this.LoseTarget(target);
  }

  protected cb func OnLostTargetDelayFalsePositivesDelay(evt: ref<LostTargetDelayFalsePositivesDelay>) -> Bool {
    this.SenseLoseTarget(evt.target);
  }

  protected cb func OnEnterShapeEvent(evt: ref<EnterShapeEvent>) -> Bool {
    let cameraDeadBodyData: ref<CameraDeadBodyData> = new CameraDeadBodyData();
    cameraDeadBodyData.ownerID = this.GetEntityID();
    cameraDeadBodyData.bodyID = evt.target.GetEntityID();
    if !evt.target.IsActive() && !GameSessionDataSystem.CheckDataRequest(this.GetGame(), EGameSessionDataType.CameraDeadBody, ToVariant(cameraDeadBodyData)) {
      GameSessionDataSystem.AddDataEntryRequest(this.GetGame(), EGameSessionDataType.CameraDeadBody, ToVariant(cameraDeadBodyData));
      this.GetDevicePS().TriggerSecuritySystemNotification(evt.target, evt.target.GetWorldPosition(), ESecurityNotificationType.ALARM);
    };
    if (this.GetDevicePS() as SensorDeviceControllerPS).CanTagEnemies() && evt.target.IsActive() {
      GameObject.TagObject(evt.target);
    };
  }

  protected cb func OnSenseVisibilityEvent(evt: ref<SenseVisibilityEvent>) -> Bool {
    if evt.isVisible && evt.target == this.m_currentlyFollowedTarget {
      this.CancelLosetargetFalsePositiveDelay();
      return true;
    };
    if !evt.isVisible && IsDefined(evt.target) && IsDefined(this.m_currentlyFollowedTarget) && evt.target == this.m_currentlyFollowedTarget {
      if this.IsCurrentTargetOutOfSenseRange(evt.target) {
        this.SenseLoseTarget(evt.target);
        return true;
      };
      this.LoseTargetFalsePositiveDelay(evt.target);
      return true;
    };
  }

  private final func IsCurrentTargetOutOfSenseRange(lostTarget: ref<GameObject>) -> Bool {
    if Vector4.Distance(lostTarget.GetWorldPosition(), this.GetWorldPosition()) >= this.GetSenseRange() {
      return true;
    };
    return false;
  }

  private final func GetSenseRange() -> Float {
    let coneShape: ref<SenseCone>;
    let senseShapes: array<ref<ISenseShape>> = this.m_senseComponent.GetSenseShapes();
    let i: Int32 = 0;
    while i < ArraySize(senseShapes) {
      coneShape = senseShapes[i] as SenseCone;
      i += 1;
    };
    if coneShape.position1.Z != 0.00 {
      return coneShape.position1.Z;
    };
    return coneShape.position2.Z;
  }

  private final func LoseTargetFalsePositiveDelay(target: wref<GameObject>) -> Void {
    let delayEvt: ref<LostTargetDelayFalsePositivesDelay>;
    let dropFactor: Float;
    let dropTime: Float;
    let presetDB: TweakDBID;
    if this.hack_isTargetLostBySensesDelEvtFilled {
      return;
    };
    presetDB = this.m_senseComponent.GetCurrentPreset();
    dropTime = TweakDBInterface.GetSensePresetRecord(presetDB).DetectionCoolDownTime();
    dropFactor = TweakDBInterface.GetSensePresetRecord(presetDB).DetectionDropFactor();
    if dropFactor <= 0.00 {
      return;
    };
    delayEvt = new LostTargetDelayFalsePositivesDelay();
    delayEvt.target = target;
    this.m_targetLostBySensesDelayEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delayEvt, dropTime + 1.00);
    this.hack_isTargetLostBySensesDelEvtFilled = true;
  }

  private final func GetDetectionFactor() -> Float {
    let presetDB: TweakDBID = this.m_senseComponent.GetCurrentPreset();
    let riseFactor: Float = TweakDBInterface.GetSensePresetRecord(presetDB).DetectionFactor();
    return riseFactor;
  }

  protected cb func OnSetDetectionMultiplier(evt: ref<SetDetectionMultiplier>) -> Bool {
    this.SetDetectionMultiplier(evt.multiplier);
  }

  public final func SetDetectionMultiplier(multiplier: Float) -> Void {
    if this.m_senseComponent.GetDetectionMultiplier(this.GetEntityID()) == 0.00 {
      this.m_senseComponent.SetDetectionMultiplier(GetPlayer(this.GetGame()).GetEntityID(), multiplier);
    } else {
      this.m_senseComponent.SetDetectionMultiplier(GetPlayer(this.GetGame()).GetEntityID(), this.m_senseComponent.GetDetectionMultiplier(this.GetEntityID()) * multiplier);
    };
  }

  private final func CancelLosetargetFalsePositiveDelay() -> Void {
    if this.hack_isTargetLostBySensesDelEvtFilled {
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_targetLostBySensesDelayEventID);
      this.hack_isTargetLostBySensesDelEvtFilled = false;
    };
  }

  private final func CancelPLAYERSAFEDelayEvent() -> Void {
    if this.m_isPLAYERSAFETargetLock {
      this.m_isPLAYERSAFETargetLock = false;
      this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
    };
  }

  private final func ForceCancelAllForcedBehaviours() -> Void {
    this.CancelPLAYERSAFEDelayEvent();
    this.CancelLosetargetFalsePositiveDelay();
    this.BreakTargeting();
    this.BreakBehaviourResolve();
  }

  private final func RecognizeTarget(newObject: wref<GameObject>, opt questForcedIntresting: Bool) -> Void {
    let isIntresting: Bool;
    if !(this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourCanDetectIntruders() {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] sensor cannot react to targets. RETURN");
      };
      return;
    };
    if this.GetDevicePS().IsControlledByPlayer() {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] Device is controlled by player. RETURN");
      };
      return;
    };
    if !IsDefined(newObject.GetAttitudeAgent()) {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] Target has no attitude agent. RETURN");
      };
      return;
    };
    if GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(newObject.GetEntityID()), gamedataStatPoolType.Health, true) <= 1.00 {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] Target has no HP. RETURN");
      };
      return;
    };
    if IsDefined(newObject as ScriptedPuppet) && ScriptedPuppet.IsDefeated(newObject) {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] Target is puppet and is unconscious. RETURN");
      };
      return;
    };
    isIntresting = this.SetAsIntrestingTarget(newObject);
    if questForcedIntresting || this.CheckIfTargetIsTaggedByPlayer(newObject) {
      isIntresting = true;
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] Target was set as: " + BoolToString(isIntresting) + " By forced intresting ");
      };
      SimpleTargetManager.AddTarget(this.m_targets, newObject, isIntresting, true);
      if this.m_currentlyFollowedTarget != this.GetForcedTargetObject() {
        this.LookAtStop();
      };
    } else {
      SimpleTargetManager.AddTarget(this.m_targets, newObject, isIntresting, true);
    };
    this.SendDefaultSSNotification(newObject, isIntresting);
    this.RegisterListenerOnTargetHP(newObject);
    this.OnValidTargetAppears(newObject);
    if !SimpleTargetManager.HasInterestingTargets(this.m_targets) || !isIntresting {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] sensor has no intresting targets and new is not intresting. RETURN");
      };
      return;
    };
    if (this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode() && this.m_currentlyFollowedTarget == this.GetForcedTargetObject() {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] sensor is in fallow mode and current target is same as new target. RETURN");
      };
      return;
    };
    this.m_currentlyFollowedTarget = SimpleTargetManager.GetFirstInterestingTargetObject(this.m_targets);
    this.BreakBehaviourResolve();
    if !this.m_isPLAYERSAFETargetLock {
      this.OnCurrentTargetAppears(newObject);
    } else {
      if !IsFinal() {
        LogDevices(this, " [RecognizeTarget] Target: " + NameToString(newObject.GetClassName()) + EntityID.ToDebugString(newObject.GetEntityID()) + " RETURN! sensor is in PLAYERSAFETargetLock");
      };
    };
  }

  public final func LoseTarget(lostObject: wref<GameObject>, opt forceRemoveTarget: Bool) -> Void {
    if !IsDefined(lostObject.GetAttitudeAgent()) {
      return;
    };
    if lostObject == this.GetForcedTargetObject() && (this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode() {
      if !IsFinal() {
        LogDevices(this, " [LoseTarget] target is same as forced target and device is in follow mode. RETURN");
      };
      return;
    };
    if this.GetDevicePS().IsConnectedToSecuritySystem() && this.HasSupport() && !forceRemoveTarget {
      if !SimpleTargetManager.SetTargetVisible(this.m_targets, lostObject, false) {
        return;
      };
    } else {
      if !SimpleTargetManager.RemoveTarget(this.m_targets, lostObject) {
        return;
      };
      this.UnregisterListenerOnTargetHP(this, lostObject);
    };
    if !IsFinal() {
      LogDevices(this, " [LoseTarget] target " + NameToString(lostObject.GetClassName()) + EntityID.ToDebugString(lostObject.GetEntityID()) + " was removed from target list ");
    };
    this.OnValidTargetDisappears(lostObject);
    if lostObject != this.m_currentlyFollowedTarget && this.m_currentlyFollowedTarget != null {
      if !IsFinal() {
        LogDevices(this, " [LoseTarget] target " + NameToString(lostObject.GetClassName()) + EntityID.ToDebugString(lostObject.GetEntityID()) + " is different than current target " + NameToString(this.m_currentlyFollowedTarget.GetClassName()) + EntityID.ToDebugString(this.m_currentlyFollowedTarget.GetEntityID()) + " so no additional action is taken. RETURN");
      };
      return;
    };
    if (this.GetDevicePS() as SensorDeviceControllerPS).IsInFollowMode() {
      if !IsFinal() {
        LogDevices(this, " [LoseTarget] Device is in follow mode RETURN");
      };
      return;
    };
    if !IsFinal() {
      LogDevices(this, " [LoseTarget] lost target is same as current target");
    };
    this.BreakReprimand();
    if SimpleTargetManager.HasInterestingTargets(this.m_targets) && !this.GetDevicePS().IsControlledByPlayer() {
      this.m_currentlyFollowedTarget = SimpleTargetManager.GetFirstInterestingTargetObject(this.m_targets);
      if !IsFinal() {
        LogDevices(this, " [LoseTarget] new intresting target found as: " + NameToString(this.m_currentlyFollowedTarget.GetClassName()) + EntityID.ToDebugString(this.m_currentlyFollowedTarget.GetEntityID()));
      };
      this.StartBehaviourResolve(ESensorDeviceStates.TARGETLOCK);
      return;
    };
    if !IsFinal() {
      LogDevices(this, " [LoseTarget] No intresting targets on target list");
    };
    this.OnAllValidTargetsDisappears();
    if !this.HasSupport() {
      if IsDefined(this.m_currentlyFollowedTarget) {
        this.StartBehaviourResolve(ESensorDeviceStates.TARGETLOSE);
      } else {
        this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
      };
    };
    this.m_currentlyFollowedTarget = null;
    this.CancelLosetargetFalsePositiveDelay();
  }

  protected cb func OnSecuritySystemEnabled(evt: ref<SecuritySystemEnabled>) -> Bool {
    if IsDefined(this.m_attitudeAgent) {
      this.m_attitudeAgent.SetAttitudeGroup(this.GetSecuritySystem().GetSecuritySystemAttitudeGroupName());
    };
  }

  protected cb func OnSecuritySystemSupport(evt: ref<SecuritySystemSupport>) -> Bool {
    let player: ref<GameObject>;
    if (this.GetDevicePS() as SensorDeviceControllerPS).IsControlledByPlayer() || this.GetDevicePS().IsSecurityWakeUpBlocked() || (this.GetDevicePS() as SensorDeviceControllerPS).IsAttitudeChanged() {
      return false;
    };
    player = GetPlayer(this.GetGame());
    if evt.supportGranted {
      this.SetHasSupport(true);
      player = GetPlayer(this.GetGame());
      if SimpleTargetManager.IsTargetAlreadyAdded(this.m_targets, player) >= 0 {
        if SimpleTargetManager.IsTargetVisible(this.m_targets, player) {
          this.RecognizeTarget(player);
        };
      } else {
        SimpleTargetManager.AddTarget(this.m_targets, player, true, false);
        this.ForcedLookAtEntityWithoutTargetMODE(player);
      };
    } else {
      this.SetHasSupport(false);
      if this.GetCurrentlyFollowedTarget() == null {
        this.LoseTarget(player, true);
      };
    };
  }

  protected cb func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> Bool {
    this.HandleSecuritySystemOutputByTask();
  }

  protected cb func OnSecuritySystemForceAttitudeChange(evt: ref<SecuritySystemForceAttitudeChange>) -> Bool {
    this.m_attitudeAgent.SetAttitudeGroup(evt.newAttitude);
  }

  private final func BlinkSecurityLight(howManyTimes: Int32) -> Void;

  protected cb func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> Bool {
    if (this.GetDevicePS() as SensorDeviceControllerPS).IsControlledByPlayer() || this.GetDevicePS().IsSecurityWakeUpBlocked() || (this.GetDevicePS() as SensorDeviceControllerPS).IsAttitudeChanged() {
      return false;
    };
    if !IsFinal() {
      LogDevices(this, " [SSRequests] Target assesment request ");
    };
    this.debug_SS_TargetAssessmentRequest += 1;
    this.SetSensePresetBasedOnSSState();
    this.DetermineLightAttitudeRefs();
    this.ReevaluateTargets();
  }

  protected cb func OnReprimandUpdate(evt: ref<ReprimandUpdate>) -> Bool {
    if Equals(evt.reprimandInstructions, EReprimandInstructions.INITIATE_FIRST) || Equals(evt.reprimandInstructions, EReprimandInstructions.INITIATE_SUCCESSIVE) {
      if !IsFinal() {
        LogDevices(this, " [Reprimand] StartReprimand ");
      };
      this.StartReprimand();
    } else {
      if Equals(evt.reprimandInstructions, EReprimandInstructions.RELEASE_TO_ANOTHER_ENTITY) {
        if !IsFinal() {
          LogDevices(this, " [Reprimand] BreakReprimand  coz of:  RELEASE_TO_ANOTHER_ENTITY");
        };
        this.BreakReprimand();
        this.StartBehaviourResolve(ESensorDeviceStates.TARGETLOCK);
      } else {
        if Equals(evt.reprimandInstructions, EReprimandInstructions.CONCLUDE_SUCCESSFUL) {
          if !IsFinal() {
            LogDevices(this, " [Reprimand] BreakReprimand  coz of:  CONCLUDE_SUCCESSFUL");
          };
          this.BreakReprimand();
          this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
        } else {
          if Equals(evt.reprimandInstructions, EReprimandInstructions.CONCLUDE_FAILED) {
            this.GetDevicePS().TriggerSecuritySystemNotification(GameInstance.FindEntityByID(this.GetGame(), evt.target) as GameObject, evt.targetPos, ESecurityNotificationType.COMBAT);
          };
        };
      };
    };
  }

  private final func StartReprimand() -> Void {
    this.StartBehaviourResolve(ESensorDeviceStates.REPRIMAND);
    GameObject.PlaySoundEvent(this, n"q003_sc_03_ui_deal_virus");
    this.StartLockingTarget(6.00);
  }

  private final func BreakReprimand(opt wasSucesfull: Bool) -> Void {
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.REPRIMAND) {
      if !IsFinal() {
        LogDevices(this, " [BreakReprimand] was sucesfull(optional): " + BoolToString(wasSucesfull));
      };
      this.BreakTargeting();
      this.m_sensorDeviceState = ESensorDeviceStates.NONE;
      GameObject.StopSoundEvent(this, n"q003_sc_03_ui_deal_virus");
    };
  }

  private final func SendDefaultSSNotification(target: wref<GameObject>, securityIntresting: Bool) -> Void {
    if this.GetDevicePS().IsConnectedToSecuritySystem() && !this.m_isPLAYERSAFETargetLock && !this.m_targetForcedFormTagKill {
      if !this.hack_wasTargetReevaluated && securityIntresting || SimpleTargetManager.IsTargetAlreadyAdded(this.m_targets, target as ScriptedPuppet) < 0 {
        this.degbu_SS_inputsSend += 1;
        this.debug_SS_inputsSendIntresting += 1;
        if !IsFinal() {
          LogDevices(this, " [SSNotyfication] Send defaultSSNotification about: " + NameToString(target.GetClassName()) + EntityID.ToDebugString(target.GetEntityID()));
        };
        this.DetermineLightInfoRefs(this.m_lightColors.white);
        if securityIntresting {
          this.GetDevicePS().TriggerSecuritySystemNotification(target, target.GetWorldPosition(), ESecurityNotificationType.DEFAULT);
        };
      };
    };
  }

  private final func SetSensePresetBasedOnSSState() -> Void {
    if this.m_defaultSensePreset == t"Senses.BasicTurret" || this.m_defaultSensePreset == t"Senses.BasicCamera" {
      if Equals(this.GetDevicePS().GetSecuritySystem().GetSecurityState(), ESecuritySystemState.COMBAT) {
        SenseComponent.RequestPresetChange(this, t"Senses.DeviceSecuritySystemCombat", true);
        this.m_senseComponent.SetDetectionMultiplier(GetPlayer(this.GetGame()).GetEntityID(), 100.00);
      };
      if Equals(this.GetDevicePS().GetSecuritySystem().GetSecurityState(), ESecuritySystemState.ALERTED) {
        this.m_senseComponent.SetDetectionMultiplier(GetPlayer(this.GetGame()).GetEntityID(), 2.00);
        SenseComponent.RequestPresetChange(this, this.m_defaultSensePreset, true);
      };
      if Equals(this.GetDevicePS().GetSecuritySystem().GetSecurityState(), ESecuritySystemState.SAFE) {
        this.m_senseComponent.SetDetectionMultiplier(GetPlayer(this.GetGame()).GetEntityID(), 1.00);
        SenseComponent.RequestPresetChange(this, this.m_defaultSensePreset, true);
      };
    };
  }

  private final func GetForcedTargetObject() -> wref<GameObject> {
    let entID: EntityID = (this.GetDevicePS() as SensorDeviceControllerPS).GetForcedTargetID();
    return GameInstance.FindEntityByID(this.GetGame(), entID) as GameObject;
  }

  protected cb func OnStartFollowingForcedTarget(evt: ref<QuestFollowTarget>) -> Bool {
    this.CancelLosetargetFalsePositiveDelay();
    this.CancelPLAYERSAFEDelayEvent();
    this.TerminateGameEffect(this.m_scanGameEffect);
    this.ToggleActiveEffect(true);
    GameObject.StopSoundEvent(this, this.m_soundDetectionLoop);
    GameObject.PlaySoundEvent(this, this.m_soundDetectionLoopStop);
    this.RemoveAllTargets();
    this.OnAllValidTargetsDisappears();
    if !IsFinal() {
      LogDevices(this, " [Quest][Target] Forced target follow: " + NameToString(this.GetForcedTargetObject().GetClassName()) + EntityID.ToDebugString(this.GetForcedTargetObject().GetEntityID()));
    };
    if IsDefined(this.GetForcedTargetObject()) {
      this.GetSensesComponent().SetDetectionMultiplier(this.GetForcedTargetObject().GetEntityID(), 100.00);
      this.GetSensesComponent().SetDetectionDropFactor(0.00);
    };
    this.RecognizeTarget(this.GetForcedTargetObject(), true);
  }

  protected cb func OnStopFollowingForcedTarget(evt: ref<QuestStopFollowingTarget>) -> Bool {
    if !IsFinal() {
      LogDevices(this, " [Quest][Target] Stop forced target follow ");
    };
    if EntityID.IsDefined(evt.targetEntityID) {
      this.GetSensesComponent().SetDetectionMultiplier(evt.targetEntityID, 1.00);
      this.GetSensesComponent().SetDetectionDropFactor(TweakDBInterface.GetSensePresetRecord(this.m_senseComponent.GetCurrentPreset()).DetectionDropFactor());
    };
    this.LoseTarget(this.m_currentlyFollowedTarget);
  }

  protected cb func OnStartQuestLookAtTarget(evt: ref<QuestLookAtTarget>) -> Bool {
    this.CancelLosetargetFalsePositiveDelay();
    this.CancelPLAYERSAFEDelayEvent();
    this.TerminateGameEffect(this.m_scanGameEffect);
    GameObject.StopSoundEvent(this, this.m_soundDetectionLoop);
    GameObject.PlaySoundEvent(this, this.m_soundDetectionLoopStop);
    this.RemoveAllTargets();
    this.OnAllValidTargetsDisappears();
    if !IsFinal() {
      LogDevices(this, " [Quest][Target] Forced target lookAt: " + NameToString(this.GetForcedTargetObject().GetClassName()) + EntityID.ToDebugString(this.GetForcedTargetObject().GetEntityID()));
    };
    this.ForceLookAtQuestTarget();
  }

  protected cb func OnStopQuestStopLookAtTarget(evt: ref<QuestStopLookAtTarget>) -> Bool {
    if !IsFinal() {
      LogDevices(this, " [Quest][Target] Stop forced target lookAt ");
    };
    this.LoseTarget(this.m_currentlyFollowedTarget);
  }

  protected cb func OnQuestSetDetectionToTrue(evt: ref<QuestSetDetectionToTrue>) -> Bool {
    if !IsFinal() {
      LogDevices(this, " [Quest][Targgeting] Detection forced to TRUE ");
    };
  }

  protected cb func OnQuestSetDetectionToFalse(evt: ref<QuestSetDetectionToFalse>) -> Bool {
    if !IsFinal() {
      LogDevices(this, " [Quest][Targgeting] Detection forced to FALSE ");
    };
    this.RemoveAllTargets();
    this.CancelPLAYERSAFEDelayEvent();
    this.CancelLosetargetFalsePositiveDelay();
    this.BreakTargeting();
    this.BreakBehaviourResolve();
    this.BreakReprimand();
    this.OnAllValidTargetsDisappears();
  }

  protected cb func OnQuestForceScanEffect(evt: ref<QuestForceScanEffect>) -> Bool {
    this.RunGameEffect(this.m_scanGameEffect, (this.GetDevicePS() as SensorDeviceControllerPS).GetScanGameEffectRef(), this.m_scanFXSlotName, this.GetDeviceFXRecord().ScanGameEffectLength());
    GameObject.PlaySoundEvent(this, this.m_soundDetectionLoop);
  }

  protected cb func OnQuestForceScanEffectStop(evt: ref<QuestForceScanEffectStop>) -> Bool {
    this.TerminateGameEffect(this.m_scanGameEffect);
    GameObject.StopSoundEvent(this, this.m_soundDetectionLoop);
    GameObject.PlaySoundEvent(this, this.m_soundDetectionLoopStop);
  }

  protected cb func OnQuestForceAttitude(evt: ref<QuestForceAttitude>) -> Bool {
    let groupName: CName;
    this.ClearInitialAttitude();
    groupName = FromVariant(evt.prop.first);
    this.m_attitudeAgent.SetAttitudeGroup(groupName);
    if !IsFinal() {
      LogDevices(this, " [Quest][Attitude] Force attitude set to: " + NameToString(groupName));
    };
    (this.GetDevicePS() as SensorDeviceControllerPS).SetIsAttitudeChanged(true);
    this.ReevaluateTargets();
    this.UpdateDeviceState();
  }

  private final func StartBehaviourResolve(newState: ESensorDeviceStates) -> Void {
    let behaviourEvent: ref<ResolveSensorDeviceBehaviour> = new ResolveSensorDeviceBehaviour();
    newState = this.CanResolveStateChange(newState);
    this.m_sensorDeviceState = newState;
    this.OnResolveSensorDeviceBehaviour(behaviourEvent);
  }

  private final func ForceStartBehaviorResolve(newState: ESensorDeviceStates) -> Void {
    let behaviourEvent: ref<ResolveSensorDeviceBehaviour> = new ResolveSensorDeviceBehaviour();
    this.BreakBehaviourResolve();
    if !IsFinal() {
      LogDevices(this, " [Behaviour] State resolve FORCED from: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(this.m_sensorDeviceState))) + "to: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(newState))));
    };
    this.m_sensorDeviceState = newState;
    this.OnResolveSensorDeviceBehaviour(behaviourEvent);
  }

  private final func CanResolveStateChange(newState: ESensorDeviceStates) -> ESensorDeviceStates {
    if (this.GetDevicePS() as SensorDeviceControllerPS).IsIdleForced() {
      if !IsFinal() {
        LogDevices(this, " [Behaviour] State resolve FAILED from: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(this.m_sensorDeviceState))) + "to: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(newState))) + " | reason: Idle forced ");
      };
      return ESensorDeviceStates.IDLEFORCED;
    };
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.JAMMER) {
      if !IsFinal() {
        LogDevices(this, " [Behaviour] State resolve FAILED from: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(this.m_sensorDeviceState))) + "to: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(newState))) + " | reason: Jammed ");
      };
      return ESensorDeviceStates.JAMMER;
    };
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.REPRIMAND) {
      if !IsFinal() {
        LogDevices(this, " [Behaviour] State resolve FAILED from: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(this.m_sensorDeviceState))) + "to: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(newState))) + " | reason: Reprimand ");
      };
      return ESensorDeviceStates.REPRIMAND;
    };
    this.BreakBehaviourResolve();
    if !IsFinal() {
      LogDevices(this, " [Behaviour] State resolve SUCCESS from: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(this.m_sensorDeviceState))) + "to: " + EnumValueToString("ESensorDeviceStates", Cast(EnumInt(newState))));
    };
    return newState;
  }

  protected cb func OnResolveSensorDeviceBehaviour(evt: ref<ResolveSensorDeviceBehaviour>) -> Bool {
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.IDLE) || Equals(this.m_sensorDeviceState, ESensorDeviceStates.IDLEFORCED) {
      this.ResolveLogicIDLE();
    };
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.TARGETLOSE) {
      this.ResolveLogicLOSETARGET(evt.iteration);
    };
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.TARGETLOCK) {
      this.ResolveLogicTARGETLOCK();
    };
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.TARGETRECEIVED) {
      this.ResolveLogicTARGETRECEIVED(evt.iteration);
    };
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.REPRIMAND) {
      this.ResolveLogicREPRIMEND();
    };
    if Equals(this.m_sensorDeviceState, ESensorDeviceStates.JAMMER) {
      this.m_currentlyFollowedTarget = GetPlayer(this.GetGame());
      this.ResolveLogicJAMMER();
    };
  }

  private final func ResolveLogicIDLE() -> Void {
    if (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourCanRotate() {
      this.ModeSearch(1.00);
    } else {
      this.ModeIdleNoTarget();
    };
  }

  private final func ResolveLogicLOSETARGET(iterator: Int32) -> Void {
    let coroutine: ref<ResolveSensorDeviceBehaviour>;
    let delayTime: Float;
    let endCoroutine: Bool;
    switch iterator {
      case 0:
        this.ModeStopMovementAtTargetPos(this.m_currentlyFollowedTarget.GetWorldPosition());
        delayTime = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourLastTargetLookAtTime();
        break;
      case 1:
        this.ModeSearch(1.00);
        delayTime = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourLostTargetSearchTime();
        break;
      case 2:
        this.ModeIdleNoTarget();
        endCoroutine = true;
        break;
      default:
        endCoroutine = true;
    };
    if !endCoroutine {
      coroutine = new ResolveSensorDeviceBehaviour();
      coroutine.iteration = iterator + 1;
      this.m_currentResolveDelayEventID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, coroutine, delayTime);
      this.hack_isResolveDelayEventFilled = true;
    } else {
      this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
    };
  }

  private final func ResolveLogicTARGETLOCK() -> Void {
    this.ModeLookAtCurrentTarget();
  }

  private final func ResolveLogicJAMMER() -> Void {
    if !IsDefined(this.m_currentlyFollowedTarget) {
      return;
    };
    this.m_animFeatureData.state = EnumInt(ETargetManagerAnimGraphState.JAMMED);
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    this.CreateLookAt();
  }

  private final func CreateLookAt(opt position: Vector4, opt otherTarget: ref<GameObject>) -> Void {
    let lookAtEntityEventHor: ref<LookAtAddEvent>;
    let lookAtEntityEventVert: ref<LookAtAddEvent>;
    this.LookAtStop();
    lookAtEntityEventVert = this.SetupLookAtProperties((this.GetDevicePS() as SensorDeviceControllerPS).GetLookAtPresetVert(), position, otherTarget);
    this.OverrideLookAtSetupVert(lookAtEntityEventVert);
    lookAtEntityEventHor = this.SetupLookAtProperties((this.GetDevicePS() as SensorDeviceControllerPS).GetLookAtPresetHor(), position, otherTarget);
    this.OverrideLookAtSetupHor(lookAtEntityEventHor);
    this.QueueEvent(lookAtEntityEventVert);
    this.QueueEvent(lookAtEntityEventHor);
    this.m_currentLookAtEventVert = lookAtEntityEventVert;
    this.m_currentLookAtEventHor = lookAtEntityEventHor;
  }

  private final func SetupLookAtProperties(recordID: TweakDBID, opt position: Vector4, opt otherTarget: ref<GameObject>) -> ref<LookAtAddEvent> {
    let lookatPointFix: Vector4;
    let lookatPreset: wref<LookAtPreset_Record>;
    let lookAtEntityEvent: ref<LookAtAddEvent> = new LookAtAddEvent();
    if Vector4.IsZero(position) {
      if IsDefined(otherTarget) {
        this.SetLookAtPositionProviderOnFollowedTarget(lookAtEntityEvent, otherTarget);
      } else {
        this.SetLookAtPositionProviderOnFollowedTarget(lookAtEntityEvent);
      };
    } else {
      lookatPointFix.Z = 1.00;
      lookAtEntityEvent.SetStaticTarget(position + lookatPointFix);
    };
    lookAtEntityEvent.SetStyle(animLookAtStyle.Normal);
    lookAtEntityEvent.SetLimits(IntEnum(3l), IntEnum(3l), IntEnum(3l), IntEnum(3l));
    if !IsFinal() {
      lookAtEntityEvent.SetDebugInfo("ScriptSensorDevice");
    };
    lookatPreset = TweakDBInterface.GetLookAtPresetRecord(recordID);
    lookAtEntityEvent.bodyPart = lookatPreset.BodyPart();
    lookAtEntityEvent.request.transitionSpeed = lookatPreset.TransitionSpeed();
    lookAtEntityEvent.request.hasOutTransition = lookatPreset.HasOutTransition();
    lookAtEntityEvent.request.outTransitionSpeed = lookatPreset.OutTransitionSpeed();
    lookAtEntityEvent.request.limits.softLimitDegrees = lookatPreset.SoftLimitDegrees();
    lookAtEntityEvent.request.limits.hardLimitDegrees = lookatPreset.HardLimitDegrees();
    lookAtEntityEvent.request.limits.hardLimitDistance = lookatPreset.HardLimitDistance();
    lookAtEntityEvent.request.limits.backLimitDegrees = lookatPreset.BackLimitDegrees();
    lookAtEntityEvent.request.calculatePositionInParentSpace = lookatPreset.CalculatePositionInParentSpace();
    return lookAtEntityEvent;
  }

  protected func OverrideLookAtSetupVert(out lookAtEntityEvent: ref<LookAtAddEvent>) -> Void;

  protected func OverrideLookAtSetupHor(out lookAtEntityEvent: ref<LookAtAddEvent>) -> Void;

  private final func ResolveLogicTARGETRECEIVED(iterator: Int32) -> Void {
    let coroutine: ref<ResolveSensorDeviceBehaviour>;
    let delayTime: Float;
    switch iterator {
      case 0:
        delayTime = 3.00;
        break;
      case 1:
        this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
        return;
      default:
        this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
    };
    return;
  }

  private final func ResolveLogicREPRIMEND() -> Void {
    this.ModeLookAtCurrentTarget();
  }

  protected func SetLookAtPositionProviderOnFollowedTarget(evt: ref<LookAtAddEvent>, opt otherTarget: ref<GameObject>) -> Void {
    if IsDefined(otherTarget) {
      evt.SetEntityTarget(otherTarget, n"Chest", Vector4.EmptyVector());
    } else {
      evt.SetEntityTarget(this.m_currentlyFollowedTarget, n"Chest", Vector4.EmptyVector());
    };
  }

  private final func ModeLookAtCurrentTarget() -> Void {
    this.LookAtStop();
    this.m_animFeatureData.state = EnumInt(ETargetManagerAnimGraphState.MODELOOKAT);
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    this.CreateLookAt();
  }

  private final func ModeSearch(opt speedMultipler: Float) -> Void {
    this.LookAtStop();
    this.m_animFeatureData.state = EnumInt(ETargetManagerAnimGraphState.IDLE);
    this.m_animFeatureData.overrideRootRotation = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourOverrideRootRotation();
    this.m_animFeatureData.pitchAngle = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourPitchAngle();
    this.m_animFeatureData.maxRotationAngle = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourMaxRotationAngle();
    this.m_animFeatureData.rotationSpeed = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourRotationSpeed() * speedMultipler;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    if !this.m_idleSoundIsPlaying && this.GetDevicePS().IsON() && this.m_playIdleSoundOnIdle {
      GameObject.PlaySoundEvent(this, this.m_idleSound);
      this.m_idleSoundIsPlaying = true;
    };
  }

  private final func ModeIdleNoTarget() -> Void {
    this.LookAtStop();
    this.m_animFeatureData.state = EnumInt(ETargetManagerAnimGraphState.IDLE);
    this.m_animFeatureData.overrideRootRotation = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourOverrideRootRotation();
    this.m_animFeatureData.pitchAngle = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourPitchAngle();
    this.m_animFeatureData.maxRotationAngle = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourMaxRotationAngle();
    if (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourCanRotate() {
      this.m_animFeatureData.rotationSpeed = (this.GetDevicePS() as SensorDeviceControllerPS).GetBehaviourRotationSpeed();
      if !this.m_idleSoundIsPlaying && this.GetDevicePS().IsON() && this.m_playIdleSoundOnIdle {
        GameObject.PlaySoundEvent(this, this.m_idleSound);
        this.m_idleSoundIsPlaying = true;
      };
    } else {
      this.m_animFeatureData.rotationSpeed = 0.00;
    };
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }

  private final func ModeStopMovementAtTargetPos(targetPosition: Vector4) -> Void {
    this.LookAtStop();
    this.CreateLookAt(targetPosition);
    this.m_animFeatureData.state = EnumInt(ETargetManagerAnimGraphState.MODELOOKAT);
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }

  private final func LookAtStop() -> Void {
    if IsDefined(this.m_currentLookAtEventHor) {
      LookAtRemoveEvent.QueueRemoveLookatEvent(this, this.m_currentLookAtEventHor);
      this.m_currentLookAtEventHor = null;
    };
    if IsDefined(this.m_currentLookAtEventVert) {
      LookAtRemoveEvent.QueueRemoveLookatEvent(this, this.m_currentLookAtEventVert);
      this.m_currentLookAtEventVert = null;
    };
  }

  private final func OneShotLookAtPosition(targetPos: Vector4, opt forcedLook: Bool) -> Void {
    if !IsDefined(this.m_currentlyFollowedTarget) || forcedLook {
      this.ModeStopMovementAtTargetPos(targetPos);
      this.StartBehaviourResolve(ESensorDeviceStates.TARGETRECEIVED);
    };
  }

  private final func ForcedLookAtEntityWithoutTargetMODE(target: ref<GameObject>) -> Void {
    if !IsDefined(this.m_currentlyFollowedTarget) {
      this.CreateLookAt(target);
      this.m_animFeatureData.state = EnumInt(ETargetManagerAnimGraphState.MODELOOKAT);
      this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    };
  }

  protected cb func OnSetDeviceTagKillMode(evt: ref<SetDeviceTagKillMode>) -> Bool {
    this.AddTaggedListener(this, n"OnKillTaggedTarget");
  }

  private final func AddTaggedListener(object: ref<GameObject>, funcName: CName) -> Void {
    let BBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().TaggedObjectsList);
    let callback: ref<CallbackHandle> = BBoard.RegisterListenerVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList, object, funcName);
    BBoard.Signal(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList);
    this.m_taggedListenerCallback = callback;
  }

  protected cb func OnKillTaggedTarget(value: Variant) -> Bool {
    let i: Int32;
    let listOfObjects: array<wref<GameObject>>;
    if this.GetDevicePS().IsControlledByPlayer() {
      return false;
    };
    listOfObjects = FromVariant(value);
    this.ChangeAttiudetowardsTag(listOfObjects);
    i = 0;
    while i < ArraySize(listOfObjects) {
      if listOfObjects[i] == this {
      } else {
        if IsDefined(listOfObjects[i].GetAttitudeAgent()) {
          this.RemoveAllTargets();
          this.OnAllValidTargetsDisappears();
          this.ForceCancelAllForcedBehaviours();
          if SimpleTargetManager.IsTargetAlreadyAdded(this.m_targets, listOfObjects[i]) > -1 {
            this.RecognizeTarget(listOfObjects[i], true);
            return false;
          };
          this.OneShotLookAtPosition(listOfObjects[i].GetWorldPosition(), true);
          return false;
        };
      };
      i += 1;
    };
  }

  private final func CheckIfTargetIsTaggedByPlayer(object: wref<GameObject>) -> Bool {
    let BBoard: ref<IBlackboard>;
    let listOfObjects: array<wref<GameObject>>;
    if (this.GetDevicePS() as SensorDeviceControllerPS).IsInTagKillMode() {
      BBoard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().TaggedObjectsList);
      listOfObjects = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList));
      if ArrayFindFirst(listOfObjects, object) > -1 {
        if !IsFinal() {
          LogDevices(this, " [TagKill] Target: " + NameToString(object.GetClassName()) + EntityID.ToDebugString(object.GetEntityID()) + " was found on list of targets so its gonna be killed (:");
        };
        this.RemoveAllTargets();
        this.m_targetForcedFormTagKill = true;
        return true;
      };
    };
    return false;
  }

  private final func ChangeAttiudetowardsTag(currentList: array<wref<GameObject>>) -> Void {
    let attitudeBetweenGroups: EAIAttitude;
    let i: Int32 = ArraySize(this.m_previoustagKillList) - 1;
    while i >= 0 {
      if ArrayContains(currentList, this.m_previoustagKillList[i]) {
        ArrayErase(this.m_previoustagKillList, i);
      };
      i -= 1;
    };
    i = 0;
    while i < ArraySize(currentList) {
      this.GetAttitudeAgent().SetAttitudeTowards(currentList[i].GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_previoustagKillList) {
      attitudeBetweenGroups = GameInstance.GetAttitudeSystem(this.GetGame()).GetAttitudeRelation(this.GetAttitudeAgent().GetAttitudeGroup(), this.m_previoustagKillList[i].GetAttitudeAgent().GetAttitudeGroup());
      this.GetAttitudeAgent().SetAttitudeTowards(this.m_previoustagKillList[i].GetAttitudeAgent(), attitudeBetweenGroups);
      i += 1;
    };
    this.m_previoustagKillList = currentList;
  }

  protected cb func OnSetDeviceAttitude(evt: ref<SetDeviceAttitude>) -> Bool {
    let groupName: CName;
    let puppetAttitudeAgent: ref<AttitudeAgent>;
    let disableAimAssist: ref<DisableAimAssist> = new DisableAimAssist();
    this.SetHasSupport(false);
    if !this.IsSurveillanceCamera() {
      SenseComponent.RequestPresetChange(this, t"Senses.FriendlyTurret", true);
    } else {
      SenseComponent.RequestPresetChange(this, this.m_defaultSensePreset, true);
    };
    this.QueueEvent(disableAimAssist);
    this.SendReprimandInstructionToSecuritySystem();
    this.ClearInitialAttitude();
    puppetAttitudeAgent = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject().GetAttitudeAgent();
    groupName = puppetAttitudeAgent.GetAttitudeGroup();
    this.GetAttitudeAgent().SetAttitudeTowards(puppetAttitudeAgent, EAIAttitude.AIA_Friendly);
    this.GetSensesComponent().SetDetectionOverwrite(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID());
    this.DetermineLightAttitudeRefs();
    this.DetermineLightScanRefs(this.m_lightColors.green);
    this.ToggleActiveEffect(true);
    this.m_attitudeAgent.SetAttitudeGroup(groupName);
    this.m_senseComponent.ReevaluateDetectionOverwrite(evt.GetExecutor());
    this.m_senseComponent.RequestRemovingSenseMappin();
    this.SetHostileTowardsPlayerHostiles();
    (this.GetDevicePS() as SensorDeviceControllerPS).SetIsAttitudeChanged(true);
    this.ReevaluateTargets();
    this.UpdateDeviceState();
    this.SendReactivateHighlightEvent();
    if this.IsTaggedinFocusMode() {
      this.RunVisionConeGameEffect();
    };
    this.GetDevicePS().SendDeviceNotOperationalEvent();
  }

  protected final func SetHostileTowardsPlayerHostiles() -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let playerTargets: array<TrackedLocation> = player.GetTargetTrackerComponent().GetHostileThreats(false);
    let i: Int32 = 0;
    while i < ArraySize(playerTargets) {
      this.GetAttitudeAgent().SetAttitudeTowardsAgentGroup((playerTargets[i].entity as GameObject).GetAttitudeAgent(), this.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
      i += 1;
    };
  }

  protected cb func OnForcePlayerIgnore(evt: ref<ForceIgnoreTargets>) -> Bool {
    this.ReevaluateTargets();
  }

  protected final func SendReprimandInstructionToSecuritySystem() -> Void {
    let evt: ref<ReprimandAgentDisconnectEvent> = new ReprimandAgentDisconnectEvent();
    evt.agentID = this.GetEntityID();
    if this.GetDevicePS().IsConnectedToSecuritySystem() {
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetSecuritySystem().GetID(), this.GetDevicePS().GetSecuritySystem().GetClassName(), evt);
    };
  }

  public final func ReevaluateTargets() -> Void {
    let firstObject: wref<GameObject>;
    let i: Int32;
    this.debug_SS_reevaluatesDone += 1;
    i = 0;
    while i < ArraySize(this.m_targets) {
      if IsDefined(this.m_targets[i].GetTarget()) {
        this.m_targets[i].SetIsInteresting(this.SetAsIntrestingTarget(this.m_targets[i].GetTarget()));
      };
      i += 1;
    };
    if this.GetDevicePS().IsConnectedToSecuritySystem() {
      this.hack_wasTargetReevaluated = true;
    };
    firstObject = SimpleTargetManager.GetFirstInterestingTargetObject(this.m_targets);
    if IsDefined(firstObject) {
      if firstObject != this.m_currentlyFollowedTarget {
        this.LookAtStop();
      };
      this.RecognizeTarget(firstObject);
    } else {
      if IsDefined(this.m_currentlyFollowedTarget) {
        this.LoseTarget(this.m_currentlyFollowedTarget);
      };
    };
    this.hack_wasTargetReevaluated = false;
  }

  public final func RemoveAllTargets() -> Void {
    SimpleTargetManager.RemoveAllTargets(this.m_targets);
    this.m_currentlyFollowedTarget = null;
    this.RevertTepmoraryAttitude();
    this.ClearAllHPListeners();
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
        if Equals(outline, EFocusOutlineType.HACKABLE) {
          highlight.highlightType = EFocusForcedHighlightType.HACKABLE;
        } else {
          if Equals(outline, EFocusOutlineType.IMPORTANT_INTERACTION) {
            highlight.highlightType = EFocusForcedHighlightType.IMPORTANT_INTERACTION;
          } else {
            if Equals(outline, EFocusOutlineType.INTERACTION) {
              highlight.highlightType = EFocusForcedHighlightType.INTERACTION;
            } else {
              if Equals(highlight.outlineType, EFocusOutlineType.NEUTRAL) {
                highlight.highlightType = EFocusForcedHighlightType.NEUTRAL;
              } else {
                highlight = null;
              };
            };
          };
        };
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

  public const func GetCurrentOutline() -> EFocusOutlineType {
    let oultineType: EFocusOutlineType;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let attitude: EAIAttitude = this.GetAttitudeTowards(playerPuppet);
    if Equals(this.GetAttitudeTowards(playerPuppet), EAIAttitude.AIA_Friendly) {
      oultineType = EFocusOutlineType.FRIENDLY;
    } else {
      if this.GetDevicePS().IsBroken() {
        oultineType = EFocusOutlineType.NEUTRAL;
      } else {
        if Equals(attitude, EAIAttitude.AIA_Hostile) || NotEquals(attitude, EAIAttitude.AIA_Friendly) && !this.GetDevicePS().IsUserAuthorized(playerPuppet.GetEntityID()) {
          oultineType = EFocusOutlineType.HOSTILE;
        } else {
          oultineType = this.GetCurrentOutline();
        };
      };
    };
    return oultineType;
  }

  protected cb func OnRevealStateChanged(evt: ref<RevealStateChangedEvent>) -> Bool {
    super.OnRevealStateChanged(evt);
    if Equals(evt.state, ERevealState.STARTED) {
      this.ToggleForcedVisibilityInAnimSystem(n"RevealStateChangedEvent", true, 0.00);
    } else {
      if Equals(evt.state, ERevealState.STOPPED) {
        this.ToggleForcedVisibilityInAnimSystem(n"RevealStateChangedEvent", false, evt.transitionTime);
      };
    };
  }

  protected final func TCSMeshToggle(isVisible: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_elementsToHideOnTCSRefs) {
      this.m_elementsToHideOnTCSRefs[i].Toggle(isVisible);
      i += 1;
    };
  }

  protected cb func OnTCSTakeOverControlActivate(evt: ref<TCSTakeOverControlActivate>) -> Bool {
    let objectUp: Vector4;
    if !this.m_wasVisible {
      this.m_wasVisible = true;
      this.ResolveGameplayState();
    };
    objectUp = WorldTransform.GetUp(this.GetWorldTransform());
    if objectUp.Z <= 0.00 {
      if IsDefined(this.m_cameraComponentInverted) {
        this.m_cameraComponent = this.m_cameraComponentInverted;
        this.m_animFeatureData.isCeiling = true;
      };
    };
    super.OnTCSTakeOverControlActivate(evt);
    this.ToggleAreaIndicator(false);
    this.TurnOffSenseComponent();
    this.ForceCancelAllForcedBehaviours();
    this.LookAtStop();
    this.m_animFeatureData.state = EnumInt(ETargetManagerAnimGraphState.MODELOOKAT);
    this.m_animFeatureData.isControlled = this.GetDevicePS().IsControlledByPlayer();
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    if this.IsTaggedinFocusMode() {
      this.TerminateGameEffect(this.m_visionConeEffectInstance);
    };
    this.TerminateGameEffect(this.m_scanGameEffect);
    this.ToggleActiveEffect(false);
    GameObject.StopSoundEvent(this, this.m_soundDetectionLoop);
    this.SyncRotationWithAnimGraph();
    this.RemoveAllTargets();
    this.OnAllValidTargetsDisappears();
    this.TCSMeshToggle(false);
  }

  protected cb func OnTCSTakeOverControlDeactivate(evt: ref<TCSTakeOverControlDeactivate>) -> Bool {
    super.OnTCSTakeOverControlDeactivate(evt);
    this.m_senseComponent.ToggleComponent(true);
    this.m_animFeatureData.isControlled = this.GetDevicePS().IsControlledByPlayer();
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
    this.StartBehaviourResolve(ESensorDeviceStates.IDLE);
    this.RevertTepmoraryAttitude();
    this.TCSMeshToggle(true);
    this.ToggleActiveEffect(true);
    if this.IsTaggedinFocusMode() {
      this.RunVisionConeGameEffect();
    };
    if EntityID.IsDynamic(this.GetEntityID()) {
      GameObject.PlaySoundEvent(this, this.m_soundDeviceOFF);
    };
  }

  public final func SyncRotationWithAnimGraph() -> Void {
    let eulerAngle: EulerAngles = this.GetRotationFromSlotRotation();
    this.m_playerControlData.m_currentYawModifier = eulerAngle.Yaw;
    this.m_playerControlData.m_currentPitchModifier = -eulerAngle.Pitch;
    this.m_animFeatureData.currentRotation.X = this.m_playerControlData.m_currentYawModifier;
    this.m_animFeatureData.currentRotation.Y = this.m_playerControlData.m_currentPitchModifier;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }

  public final func ResetRotation() -> Void {
    this.m_animFeatureData.currentRotation.X = 0.00;
    this.m_animFeatureData.currentRotation.Y = 0.00;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }

  public final const func GetRotationFromSlotRotation() -> EulerAngles {
    let ForwardEulerToTarget: EulerAngles;
    let directionTowardsTarget: Vector4;
    let forwardLocalToWorldAngle: Float;
    let localLookAtDirection: Vector4;
    let slotWorldTransform: WorldTransform;
    this.m_forwardFaceSlotComponent.GetSlotTransform(n"TargetFacing", slotWorldTransform);
    directionTowardsTarget = WorldTransform.GetForward(slotWorldTransform);
    forwardLocalToWorldAngle = Vector4.Heading(this.GetWorldForward());
    localLookAtDirection = Vector4.RotByAngleXY(directionTowardsTarget, forwardLocalToWorldAngle);
    ForwardEulerToTarget = Vector4.ToRotation(localLookAtDirection);
    return ForwardEulerToTarget;
  }

  protected cb func OnTCSInputXYAxisEvent(evt: ref<TCSInputXYAxisEvent>) -> Bool {
    super.OnTCSInputXYAxisEvent(evt);
    if evt.isAnyInput {
      if !this.m_idleSoundIsPlaying {
        GameObject.PlaySoundEvent(this, this.m_idleSound);
        this.m_idleSoundIsPlaying = true;
      };
    } else {
      if this.m_idleSoundIsPlaying {
        GameObject.StopSoundEvent(this, this.m_idleSound);
        GameObject.PlaySoundEvent(this, this.m_idleSoundStop);
        this.m_idleSoundIsPlaying = false;
      };
    };
  }

  private final func ForceLookAtQuestTarget() -> Void {
    this.LookAtStop();
    SimpleTargetManager.AddTarget(this.m_targets, this.GetForcedTargetObject(), true, true);
    this.m_currentlyFollowedTarget = SimpleTargetManager.GetFirstInterestingTargetObject(this.m_targets);
    this.ModeLookAtCurrentTarget();
  }

  protected final func InitializeDeviceFXRecord() -> Void {
    let fxRecord: ref<DeviceFX_Record>;
    if this.IsSurveillanceCamera() && !this.GetDevicePS().IsConnectedToSecuritySystem() {
      return;
    };
    fxRecord = TweakDBInterface.GetDeviceFXRecord(t"DeviceFXPackage.Default");
    if IsDefined(fxRecord) {
      this.m_deviceFXRecord = fxRecord;
    };
  }

  protected final func InitializeLights() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"InitializeLightsTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func InitializeLightsTask(data: ref<ScriptTaskData>) -> Void {
    this.DetermineLightAttitudeRefs();
    this.DetermineLightScanRefs(this.m_lightColors.yellow);
    this.DetermineLightInfoRefs(this.m_lightColors.blue);
  }

  protected final func DetermineLightAttitudeRefs() -> Void {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let attitude: EAIAttitude = this.GetAttitudeTowards(playerPuppet);
    if Equals(attitude, EAIAttitude.AIA_Hostile) {
      gameLightComponent.ChangeLightSettingByRefs(this.m_lightAttitudeRefs, this.m_lightColors.red);
    } else {
      if Equals(attitude, EAIAttitude.AIA_Friendly) || this.GetDevicePS().IsUserAuthorized(playerPuppet.GetEntityID()) {
        gameLightComponent.ChangeLightSettingByRefs(this.m_lightAttitudeRefs, this.m_lightColors.green);
      } else {
        gameLightComponent.ChangeLightSettingByRefs(this.m_lightAttitudeRefs, this.m_lightColors.yellow);
      };
    };
  }

  protected final func RunGameEffect(out effectInstance: ref<EffectInstance>, effectRef: EffectRef, slotName: CName, range: Float) -> Void {
    this.TerminateGameEffect(effectInstance);
    effectInstance = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffect(effectRef, this);
    EffectData.SetVector(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, this.GetWorldPosition());
    EffectData.SetVector(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, this.GetWorldForward());
    EffectData.SetFloat(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, range);
    effectInstance.AttachToSlot(this, slotName, GetAllBlackboardDefs().EffectSharedData.position, GetAllBlackboardDefs().EffectSharedData.forward);
    effectInstance.Run();
  }

  protected final func TerminateGameEffect(out effectInstance: ref<EffectInstance>) -> Void {
    if IsDefined(effectInstance) {
      effectInstance.Terminate();
      effectInstance = null;
    };
  }

  protected final func DetermineLightScanRefs(desiredColor: ScriptLightSettings) -> Void {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let attitude: EAIAttitude = this.GetAttitudeTowards(playerPuppet);
    if Equals(attitude, EAIAttitude.AIA_Hostile) {
      gameLightComponent.ChangeLightSettingByRefs(this.m_lightScanRefs, desiredColor, 0.50);
    } else {
      if Equals(attitude, EAIAttitude.AIA_Friendly) || this.GetDevicePS().IsUserAuthorized(playerPuppet.GetEntityID()) {
        gameLightComponent.ChangeLightSettingByRefs(this.m_lightScanRefs, this.m_lightColors.green, 0.50);
      } else {
        gameLightComponent.ChangeLightSettingByRefs(this.m_lightScanRefs, desiredColor, 0.50);
      };
    };
  }

  protected final func DetermineLightInfoRefs(desiredColor: ScriptLightSettings) -> Void {
    if this.GetDevicePS().IsConnectedToSecuritySystem() {
      gameLightComponent.ChangeLightSettingByRefs(this.m_lightInfoRefs, desiredColor, 0.20, n"glitch", true);
    };
  }

  protected final func ToggleActiveEffect(active: Bool) -> Void {
    let attitude: EAIAttitude;
    let playerPuppet: ref<PlayerPuppet>;
    if this.IsSurveillanceCamera() && !this.GetDevicePS().IsConnectedToSecuritySystem() {
      return;
    };
    playerPuppet = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    attitude = this.GetAttitudeTowards(playerPuppet);
    if active && !this.GetDevicePS().IsControlledByPlayer() && this.GetDevicePS().IsON() {
      if Equals(attitude, EAIAttitude.AIA_Friendly) {
        this.TerminateGameEffect(this.m_idleGameEffectInstance);
        this.RunGameEffect(this.m_idleGameEffectInstance, (this.GetDevicePS() as SensorDeviceControllerPS).GetIdleFriendlyRef(), this.m_scanFXSlotName, this.GetDeviceFXRecord().IdleEffectLength());
        GameObjectEffectHelper.StopEffectEvent(this, n"active");
        GameObjectEffectHelper.StartEffectEvent(this, n"friendly");
      } else {
        this.TerminateGameEffect(this.m_idleGameEffectInstance);
        this.RunGameEffect(this.m_idleGameEffectInstance, (this.GetDevicePS() as SensorDeviceControllerPS).GetIdleActiveRef(), this.m_scanFXSlotName, this.GetDeviceFXRecord().IdleEffectLength());
        GameObjectEffectHelper.StartEffectEvent(this, n"active");
        GameObjectEffectHelper.StopEffectEvent(this, n"friendly");
      };
    } else {
      this.TerminateGameEffect(this.m_idleGameEffectInstance);
      GameObjectEffectHelper.StopEffectEvent(this, n"active");
      GameObjectEffectHelper.StopEffectEvent(this, n"friendly");
    };
  }

  protected cb func OnReactoToPreventionSystem(evt: ref<ReactoToPreventionSystem>) -> Bool {
    if !evt.wakeUp {
      this.m_senseComponent.RemoveSenseMappin();
    };
    this.ForceReEvaluateGameplayRole();
  }

  protected final func HasEntityPlayerAttitudeGroup() -> Bool {
    return Equals(GetPlayer(this.GetGame()).GetAttitudeAgent().GetAttitudeGroup(), this.GetAttitudeAgent().GetAttitudeGroup());
  }

  protected cb func OnProgramSetDeviceAttitude(evt: ref<ProgramSetDeviceAttitude>) -> Bool {
    if evt.IsStarted() {
      this.CacheInitialAttitude();
    } else {
      this.RevertTepmoraryAttitude();
      this.ClearInitialAttitude();
    };
  }

  public const func IsGameplayRelevant() -> Bool {
    return true;
  }

  public const func IsExplosive() -> Bool {
    return false;
  }

  protected cb func OnNetworkLinkQuickhackEvent(evt: ref<NetworkLinkQuickhackEvent>) -> Bool {
    let ps: ref<SensorDeviceControllerPS> = this.GetDevicePS() as SensorDeviceControllerPS;
    if !IsDefined(ps) {
      return false;
    };
    ps.SetNetrunnerID(evt.netrunnerID);
    ps.SetNetrunnerProxyID(evt.proxyID);
    ps.SetNetrunnerTargetID(evt.targetID);
    (this.GetDevicePS() as SensorDeviceControllerPS).DrawBetweenEntities(true, true, this.GetFxResourceByKey(n"pingNetworkLink"), evt.to, evt.from, false, false, false, false);
    this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", true, 0.00, evt.from);
    if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(evt.targetID), gamedataStatType.RevealNetrunnerWhenHacked) == 1.00 {
      SensorDevice.ForceVisionAppearanceNetrunner(GameInstance.FindEntityByID(this.GetGame(), evt.netrunnerID) as GameObject, evt.netrunnerID, n"EnemyNetrunner", true);
      if EntityID.IsDefined(evt.proxyID) {
        SensorDevice.ForceVisionAppearanceNetrunner(GameInstance.FindEntityByID(this.GetGame(), evt.proxyID) as GameObject, evt.netrunnerID, n"EnemyNetrunner", true);
      };
    };
  }

  public final static func ForceVisionAppearanceNetrunner(target: ref<GameObject>, sourceID: EntityID, sourceName: CName, toggle: Bool) -> Void {
    let visionEvt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    let data: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    data.sourceID = sourceID;
    data.sourceName = sourceName;
    data.outlineType = EFocusOutlineType.ENEMY_NETRUNNER;
    data.highlightType = EFocusForcedHighlightType.ENEMY_NETRUNNER;
    data.priority = EPriority.High;
    data.isRevealed = true;
    data.patternType = VisionModePatternType.Netrunner;
    visionEvt.forcedHighlight = data;
    visionEvt.apply = toggle;
    target.QueueEvent(visionEvt);
  }

  public final func RemoveLinkedStatusEffects() -> Bool {
    let linkedStatusEffect: LinkedStatusEffect;
    let targetPuppet: wref<ScriptedPuppet>;
    let ps: ref<SensorDeviceControllerPS> = this.GetDevicePS() as SensorDeviceControllerPS;
    if !IsDefined(ps) {
      return false;
    };
    linkedStatusEffect = ps.GetLinkedStatusEffect();
    if EntityID.IsDefined(linkedStatusEffect.targetID) {
      targetPuppet = GameInstance.FindEntityByID(this.GetGame(), linkedStatusEffect.targetID) as ScriptedPuppet;
      if IsDefined(targetPuppet) {
        targetPuppet.RemoveLinkedStatusEffectsFromTarget(this.GetEntityID());
        ps.ClearLinkedStatusEffect();
      };
    };
    this.RemoveLink();
    return true;
  }

  public final func RemoveLinkedStatusEffectsFromTarget(sourceID: EntityID) -> Bool {
    let i: Int32;
    let linkedStatusEffect: LinkedStatusEffect;
    let ps: ref<SensorDeviceControllerPS> = this.GetDevicePS() as SensorDeviceControllerPS;
    if !IsDefined(ps) {
      return false;
    };
    linkedStatusEffect = ps.GetLinkedStatusEffect();
    if ArrayContains(linkedStatusEffect.netrunnerIDs, sourceID) && linkedStatusEffect.targetID == this.GetEntityID() {
      if ArraySize(linkedStatusEffect.netrunnerIDs) == 1 {
        i = 0;
        while i < ArraySize(linkedStatusEffect.statusEffectList) {
          StatusEffectHelper.RemoveStatusEffect(this, linkedStatusEffect.statusEffectList[i]);
          i += 1;
        };
        ps.ClearLinkedStatusEffect();
        StatusEffectHelper.RemoveStatusEffect(this, t"AIQuickHackStatusEffect.BeingHacked");
      } else {
        ArrayRemove(linkedStatusEffect.netrunnerIDs, sourceID);
        AIActionHelper.UpdateLinkedStatusEffects(this, linkedStatusEffect);
        ps.SetLinkedStatusEffect(linkedStatusEffect);
      };
    };
    return true;
  }

  public final func RemoveLink() -> Void {
    let attackAttemptEvent: ref<AIAttackAttemptEvent>;
    let netrunner: ref<GameObject>;
    let netrunnerID: EntityID;
    let proxy: ref<GameObject>;
    let proxyID: EntityID;
    let target: ref<GameObject>;
    let targetID: EntityID;
    let ps: ref<SensorDeviceControllerPS> = this.GetDevicePS() as SensorDeviceControllerPS;
    if !IsDefined(ps) {
      return;
    };
    netrunnerID = ps.GetNetrunnerID();
    if !EntityID.IsDefined(netrunnerID) {
      return;
    };
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestRemovingStatPool(Cast(netrunnerID), gamedataStatPoolType.QuickHackUpload);
    targetID = ps.GetNetrunnerTargetID();
    if !EntityID.IsDefined(targetID) {
      return;
    };
    proxyID = ps.GetNetrunnerProxyID();
    if EntityID.IsDefined(proxyID) {
      (this.GetDevicePS() as SensorDeviceControllerPS).DrawBetweenEntities(false, true, this.GetFxResourceByKey(n"pingNetworkLink"), netrunnerID, proxyID, false, false);
      (this.GetDevicePS() as SensorDeviceControllerPS).DrawBetweenEntities(false, true, this.GetFxResourceByKey(n"pingNetworkLink"), proxyID, targetID, false, false);
      this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", false, 0.00, netrunnerID);
      this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", false, 0.00, proxyID);
      proxy = GameInstance.FindEntityByID(this.GetGame(), proxyID) as GameObject;
    } else {
      (this.GetDevicePS() as SensorDeviceControllerPS).DrawBetweenEntities(false, true, this.GetFxResourceByKey(n"pingNetworkLink"), netrunnerID, targetID, false, false);
      this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", false, 0.00, netrunnerID);
    };
    netrunner = GameInstance.FindEntityByID(this.GetGame(), netrunnerID) as GameObject;
    target = GameInstance.FindEntityByID(this.GetGame(), targetID) as GameObject;
    if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(targetID), gamedataStatType.RevealNetrunnerWhenHacked) == 1.00 {
      SensorDevice.ForceVisionAppearanceNetrunner(netrunner, netrunnerID, n"EnemyNetrunner", false);
      if IsDefined(proxy) {
        SensorDevice.ForceVisionAppearanceNetrunner(proxy, netrunnerID, n"EnemyNetrunner", false);
      };
    };
    attackAttemptEvent = new AIAttackAttemptEvent();
    attackAttemptEvent.instigator = netrunner;
    attackAttemptEvent.continuousMode = gameEContinuousMode.Stop;
    if IsDefined(target) {
      attackAttemptEvent.target = target;
      target.QueueEvent(attackAttemptEvent);
      if IsDefined(netrunner) {
        netrunner.QueueEvent(attackAttemptEvent);
      };
      StatusEffectHelper.RemoveStatusEffect(target, t"AIQuickHackStatusEffect.BeingHacked");
    } else {
      if IsDefined(netrunner) {
        attackAttemptEvent.target = netrunner;
        netrunner.QueueEvent(attackAttemptEvent);
      };
    };
  }

  public final const func GetTargets() -> array<ref<Target>> {
    return this.m_targets;
  }

  public final func SetSenseObjectType(type: gamedataSenseObjectType) -> Void {
    let objectTypeEvent: ref<VisibleObjectTypeEvent>;
    if IsDefined(this.GetSensesComponent()) {
      this.GetSensesComponent().SetVisibleObjectType(type);
      this.GetSensesComponent().SetSensorObjectType(type);
    };
    if IsDefined(this.GetVisibleObjectComponent()) {
      objectTypeEvent = new VisibleObjectTypeEvent();
      objectTypeEvent.type = type;
      this.QueueEvent(objectTypeEvent);
    };
  }

  private final func RunVisionConeGameEffect() -> Void {
    let attitude: EAIAttitude;
    let playerPuppet: ref<PlayerPuppet>;
    if this.IsSurveillanceCamera() && !this.GetDevicePS().IsConnectedToSecuritySystem() {
      return;
    };
    playerPuppet = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    attitude = this.GetAttitudeTowards(playerPuppet);
    if IsDefined(this.m_visionConeEffectInstance) {
      this.TerminateGameEffect(this.m_visionConeEffectInstance);
    };
    if Equals(attitude, EAIAttitude.AIA_Friendly) || this.GetDevicePS().IsDeviceSecured() && this.GetDevicePS().IsUserAuthorized(playerPuppet.GetEntityID()) {
      this.RunGameEffect(this.m_visionConeEffectInstance, (this.GetDevicePS() as SensorDeviceControllerPS).GetVisionConeFriendlyEffectRef(), this.m_scanFXSlotName, this.GetDeviceFXRecord().VisionConeEffectLength());
    } else {
      this.RunGameEffect(this.m_visionConeEffectInstance, (this.GetDevicePS() as SensorDeviceControllerPS).GetVisionConeEffectRef(), this.m_scanFXSlotName, this.GetDeviceFXRecord().VisionConeEffectLength());
    };
  }
}
