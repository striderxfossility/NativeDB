
public class ForceUIRefreshEvent extends Event {

  public let m_ownerID: EntityID;

  public final func GetFriendlyDescription() -> String {
    return "Force UI Refresh";
  }
}

public class ToggleUIInteractivity extends Event {

  public edit let m_isInteractive: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle UI Interactivity";
  }
}

public class DisableRPGRequirementsForDeviceActions extends Event {

  @attrib(customEditor, "TweakDBGroupInheritance;ObjectAction")
  public edit let m_action: TweakDBID;

  @default(DisableRPGRequirementsForDeviceActions, true)
  public edit let m_disable: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Disable RPG Requirements For Device Actions";
  }
}

public static func OperatorEqual(action1: ref<DeviceAction>, action2: ref<DeviceAction>) -> Bool {
  if Equals(action1.GetCurrentDisplayString(), action2.GetCurrentDisplayString()) {
    if Equals(action1.GetPersistentID(), action2.GetPersistentID()) {
      return true;
    };
  };
  return false;
}

public static func OperatorEqual(action1: ref<PuppetAction>, action2: ref<PuppetAction>) -> Bool {
  if Equals(action1.GetCurrentDisplayString(), action2.GetCurrentDisplayString()) {
    if Equals(action1.GetPersistentID(), action2.GetPersistentID()) {
      return true;
    };
  };
  return false;
}

public native class DeviceBase extends GameObject {

  protected native let isLogicReady: Bool;

  protected native func GetServerState() -> ref<DeviceReplicatedState>;

  protected native const func GetClientState() -> ref<DeviceReplicatedState>;

  public final native const func IsLogicReady() -> Bool;

  protected func ApplyReplicatedState(const state: ref<DeviceReplicatedState>) -> Void;

  public const func GetDeviceStateClass() -> CName {
    return n"";
  }

  public func ApplyAnimFeatureToReplicate(obj: ref<GameObject>, inputName: CName, value: ref<AnimFeature>) -> Void {
    if IsHost() {
      AnimationControllerComponent.ApplyFeatureToReplicate(obj, inputName, value);
    };
  }

  protected func IsDeviceMovableScript() -> Bool {
    return false;
  }

  protected func IncludeLightsInVisibilityBoundsScript() -> Bool {
    return false;
  }
}

public class Device extends DeviceBase {

  protected let m_controller: ref<ScriptableDC>;

  protected let m_wasVisible: Bool;

  protected let m_isVisible: Bool;

  @default(AOEArea, AOEAreaController)
  @default(AccessPoint, AccessPointController)
  @default(ActionsSequencer, ActionsSequencerController)
  @default(ActivatedDeviceIndustrialArm, ActivatedDeviceController)
  @default(ActivatedDeviceNPC, ActivatedDeviceNPCController)
  @default(ActivatedDeviceTrap, ActivatedDeviceController)
  @default(ActivatedDeviceTrapDestruction, ActivatedDeviceController)
  @default(Activator, ActivatorController)
  @default(AlarmLight, AlarmLightController)
  @default(ApartmentScreen, ApartmentScreenController)
  @default(ArcadeMachine, ArcadeMachineController)
  @default(BarbedWire, BarbedWireController)
  @default(BaseAnimatedDevice, BaseAnimatedDeviceController)
  @default(BaseDestructibleDevice, BaseDestructibleController)
  @default(BasicDistractionDevice, BasicDistractionDeviceController)
  @default(BillboardDevice, BillboardDeviceController)
  @default(BlindingLight, BlindingLightController)
  @default(C4, C4Controller)
  @default(ChestPress, ChestPressController)
  @default(CleaningMachine, CleaningMachineController)
  @default(Coder, CoderController)
  @default(Computer, ComputerController)
  @default(ConfessionBooth, ConfessionBoothController)
  @default(CrossingLight, CrossingLightController)
  @default(DataTerm, DataTermController)
  @default(DestructibleMasterDevice, DestructibleMasterDeviceController)
  @default(DestructibleMasterLight, DestructibleMasterLightController)
  @default(Device, ScriptableDC)
  @default(DeviceSystemBase, DeviceSystemBaseController)
  @default(DisassemblableEntitySimple, GenericDeviceController)
  @default(DisplayGlass, DisplayGlassController)
  @default(DisposalDevice, DisposalDeviceController)
  @default(Door, DoorController)
  @default(DoorProximityDetector, DoorProximityDetectorController)
  @default(DoorSystem, DoorSystemController)
  @default(DropPoint, DropPointController)
  @default(ElectricBox, ElectricBoxController)
  @default(ElectricLight, ElectricLightController)
  @default(ElevatorFloorTerminal, ElevatorFloorTerminalController)
  @default(ExitLight, ExitLightController)
  @default(ExplosiveDevice, ExplosiveDeviceController)
  @default(Fan, FanController)
  @default(Fridge, FridgeController)
  @default(Fuse, FuseController)
  @default(FuseBox, FuseBoxController)
  @default(GameplayLight, GameplayLightController)
  @default(GenericDevice, GenericDeviceController)
  @default(GlitchedTurret, GlitchedTurretController)
  @default(HoloDevice, HoloDeviceController)
  @default(HoloFeeder, HoloFeederController)
  @default(IceMachine, IceMachineController)
  @default(InteractiveAd, InteractiveAdController)
  @default(InteractiveSign, InteractiveSignController)
  @default(Intercom, IntercomController)
  @default(InvisibleSceneStash, InvisibleSceneStashController)
  @default(Jukebox, JukeboxController)
  @default(Ladder, LadderController)
  @default(LaserDetector, LaserDetectorController)
  @default(LcdScreen, LcdScreenController)
  @default(LiftDevice, LiftController)
  @default(Mainframe, MainframeController)
  @default(MaintenancePanel, MaintenancePanelController)
  @default(MovableDevice, MovableDeviceController)
  @default(MovableWallScreen, MovableWallScreenController)
  @default(NcartTimetable, NcartTimetableController)
  @default(NetrunnerChair, NetrunnerChairController)
  @default(NetrunnerControlPanel, NetrunnerControlPanelController)
  @default(NetworkArea, NetworkAreaController)
  @default(OdaCementBag, OdaCementBagController)
  @default(PersonnelSystem, PersonnelSystemController)
  @default(ProximityDetector, ProximityDetectorController)
  @default(Radio, RadioController)
  @default(Reflector, ReflectorController)
  @default(RetractableAd, RetractableAdController)
  @default(RoadBlock, RoadBlockController)
  @default(RoadBlockTrap, RoadBlockTrapController)
  @default(SecurityAlarm, SecurityAlarmController)
  @default(SecurityArea, SecurityAreaController)
  @default(SecurityGate, SecurityGateController)
  @default(SecurityGateLock, SecurityGateLockController)
  @default(SecurityLocker, SecurityLockerController)
  @default(SecuritySystem, SecuritySystemController)
  @default(SecurityTurret, SecurityTurretController)
  @default(SimpleSwitch, SimpleSwitchController)
  @default(SlidingLadder, SlidingLadderController)
  @default(SmartHouse, SmartHouseController)
  @default(SmartWindow, SmartWindowController)
  @default(SmokeMachine, SmokeMachineController)
  @default(SoundSystem, SoundSystemController)
  @default(Speaker, SpeakerController)
  @default(Stash, StashController)
  @default(Stillage, StillageController)
  @default(SurveillanceCamera, SurveillanceCameraController)
  @default(SurveillanceSystem, SurveillanceSystemController)
  @default(TV, TVController)
  @default(Terminal, TerminalController)
  @default(Toilet, ToiletController)
  @default(TrafficLight, TrafficLightController)
  @default(TrafficZebra, TrafficZebraController)
  @default(UnstablePlatform, BaseAnimatedDeviceController)
  @default(VendingMachine, VendingMachineController)
  @default(VendingTerminal, VendingTerminalController)
  @default(VentilationArea, VentilationAreaController)
  @default(WallScreen, WallScreenController)
  @default(WeaponVendingMachine, WeaponVendingMachineController)
  @default(Window, WindowController)
  @default(WindowBlinders, WindowBlindersController)
  protected let m_controllerTypeName: CName;

  @default(SimpleSwitch, EDeviceStatus.ON)
  protected let m_deviceState: EDeviceStatus;

  protected let m_uiComponent: wref<IWorldWidgetComponent>;

  protected let m_screenDefinition: SUIScreenDefinition;

  @default(Device, true)
  protected let m_isUIdirty: Bool;

  protected let m_personalLinkComponent: ref<WorkspotResourceComponent>;

  protected let m_durabilityType: EDeviceDurabilityType;

  protected let m_disassemblableComponent: ref<DisassemblableComponent>;

  protected let m_localization: ref<LocalizationStringComponent>;

  protected let m_IKslotComponent: ref<SlotComponent>;

  protected let m_ToggleZoomInteractionWorkspot: ref<WorkspotResourceComponent>;

  protected let m_cameraZoomComponent: ref<CameraComponent>;

  private let m_slotComponent: ref<SlotComponent>;

  private let m_isInitialized: Bool;

  protected let m_isInsideLogicArea: Bool;

  protected let m_cameraComponent: ref<CameraComponent>;

  protected let m_ZoomUIListenerID: ref<CallbackHandle>;

  protected let m_ZoomStateMachineListenerID: ref<CallbackHandle>;

  protected let m_activeStatusEffect: TweakDBID;

  protected let m_activeProgramToUploadOnNPC: TweakDBID;

  protected let m_isQhackUploadInProgerss: Bool;

  protected let m_scanningTweakDBRecord: TweakDBID;

  private let m_updateRunning: Bool;

  private let m_updateID: DelayID;

  protected let m_delayedUpdateDeviceStateID: DelayID;

  protected let m_blackboard: ref<IBlackboard>;

  private let m_currentPlayerTargetCallbackID: ref<CallbackHandle>;

  private let m_wasLookedAtLast: Bool;

  private let m_lastPingSourceID: EntityID;

  protected let m_networkGridBeamFX: FxResource;

  protected let m_fxResourceMapper: ref<FxResourceMapperComponent>;

  protected let m_effectVisualization: ref<AreaEffectVisualizationComponent>;

  protected let m_resourceLibraryComponent: ref<ResourceLibraryComponent>;

  protected let m_gameplayRoleComponent: ref<GameplayRoleComponent>;

  protected let m_personalLinkHackSend: Bool;

  protected let m_personalLinkFailsafeID: DelayID;

  protected let m_wasAnimationFastForwarded: Bool;

  @attrib(category, "RPG")
  @attrib(customEditor, "TweakDBGroupInheritance;DeviceContentAssignment")
  protected let m_contentScale: TweakDBID;

  @attrib(category, "Network Visualisation")
  protected edit let m_networkGridBeamOffset: Vector4;

  @attrib(category, "Area effects - OBSOLETE USE ONLY TO CORRECT DATA OF EXISTING EFFECTS")
  public let m_areaEffectsData: array<SAreaEffectData>;

  @attrib(category, "Area effects - OBSOLETE USE ONLY TO CORRECT DATA OF EXISTING EFFECTS")
  public let m_areaEffectsInFocusMode: array<SAreaEffectTargetData>;

  protected let m_debugOptions: DebuggerProperties;

  protected let m_workspotActivator: wref<GameObject>;

  protected final func ResolveGameplayStateByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"ResolveGameplayStateTask", gameScriptTaskExecutionStage.PostPhysics);
  }

  protected final func ResolveGameplayStateTask(data: ref<ScriptTaskData>) -> Void {
    this.ResolveGameplayState();
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"controller", this.m_controllerTypeName, false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"gameVisionModeComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scanning", n"gameScanningComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"targeting", n"gameTargetingComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"localization", n"LocalizationStringComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"StimBroadcaster", n"StimBroadcasterComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"disassemblableComponent", n"DisassemblableComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"statsComponent", n"gameStatsComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"IKslots", n"SlotComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"FxResourceMapper", n"FxResourceMapperComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"AreaEffectVisualization", n"AreaEffectVisualizationComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ResourceLibrary", n"ResourceLibraryComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"GameplayRole", n"GameplayRoleComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"personalLinkPlayerWorkspot", n"workWorkspotResourceComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ToggleZoomInteraction", n"workWorkspotResourceComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"cameraZoomComponent", n"CameraComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"main_slot", n"SlotComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"cameraComponent", n"CameraComponent", false);
    super.OnRequestComponents(ri);
  }

  public func OnMaraudersMapDeviceDebug(sink: ref<MaraudersMapDevicesSink>) -> Void {
    let contentAssigmentRecord: wref<DeviceContentAssignment_Record>;
    let context: array<gamedeviceRequestType>;
    let i: Int32;
    let playstyle: array<EPlaystyle>;
    let powerLevelMod: String;
    let vulnerabilities: array<TweakDBID>;
    let vulnerabilityRecord: wref<ObjectActionGameplayCategory_Record>;
    sink.PushString("Basic Device Parameters", "");
    sink.PushString("Name", GetLocalizedText(this.GetDevicePS().GetDeviceName()));
    sink.PushString("Gameplay Role", EnumValueToString("EGameplayRole", Cast(EnumInt(this.m_gameplayRoleComponent.GetCurrentGameplayRole()))));
    sink.PushString("State", EnumValueToString("EDeviceStatus", Cast(EnumInt(this.GetDevicePS().GetDeviceState()))));
    sink.PushString("Durability Type", EnumValueToString("EDeviceDurabilityType", Cast(EnumInt(this.GetDevicePS().GetDurabilityType()))));
    sink.PushString("Durability State", EnumValueToString("EDeviceDurabilityState", Cast(EnumInt(this.GetDevicePS().GetDurabilityState()))));
    sink.PushBool("Exposed Quick Hack", this.GetDevicePS().IsQuickHacksExposed());
    sink.PushBool("Has personal link slot", this.GetDevicePS().HasPersonalLinkSlot());
    sink.PushBool("Has Backdoor", this.GetDevicePS().HasNetworkBackdoor());
    playstyle = this.GetDevicePS().GetPlaystyles();
    i = 0;
    while i < ArraySize(playstyle) {
      sink.PushString("Playstyle " + i, EnumValueToString("EPlaystyle", Cast(EnumInt(playstyle[i]))));
      i += 1;
    };
    context = this.GetDevicePS().GetActiveContexts();
    i = 0;
    while i < ArraySize(context) {
      sink.PushString("Context " + i, EnumValueToString("gamedeviceRequestType", Cast(EnumInt(context[i]))));
      i += 1;
    };
    vulnerabilities = this.GetDevicePS().GetActiveQuickHackVulnerabilities();
    i = 0;
    while i < ArraySize(vulnerabilities) {
      vulnerabilityRecord = TweakDBInterface.GetObjectActionGameplayCategoryRecord(vulnerabilities[i]);
      sink.PushString("Vulnerability " + i, vulnerabilityRecord.FriendlyName());
      i += 1;
    };
    if this.GetDevicePS().GetSkillCheckContainer().GetHackingSlot().IsActive() || this.GetDevicePS().GetSkillCheckContainer().GetEngineeringSlot().IsActive() || this.GetDevicePS().GetSkillCheckContainer().GetDemolitionSlot().IsActive() {
      if this.GetDevicePS().GetSkillCheckContainer().GetHackingSlot().IsActive() {
        sink.PushBool("Hacking Skillcheck", this.GetDevicePS().GetSkillCheckContainer().GetHackingSlot().IsActive());
        sink.PushString("Hacking Skillcheck Diff", EnumValueToString("EGameplayChallengeLevel", Cast(EnumInt(this.GetDevicePS().GetSkillCheckContainer().GetHackingSlot().GetDifficulty()))));
      };
      if this.GetDevicePS().GetSkillCheckContainer().GetEngineeringSlot().IsActive() {
        sink.PushBool("Engeneering Skillcheck", this.GetDevicePS().GetSkillCheckContainer().GetEngineeringSlot().IsActive());
        sink.PushString("Engeneering Skillcheck Diff", EnumValueToString("EGameplayChallengeLevel", Cast(EnumInt(this.GetDevicePS().GetSkillCheckContainer().GetEngineeringSlot().GetDifficulty()))));
      };
      if this.GetDevicePS().GetSkillCheckContainer().GetDemolitionSlot().IsActive() {
        sink.PushBool("Demolitions Skillcheck", this.GetDevicePS().GetSkillCheckContainer().GetDemolitionSlot().IsActive());
        sink.PushString("Demolitions Skillcheck Diff", EnumValueToString("EGameplayChallengeLevel", Cast(EnumInt(this.GetDevicePS().GetSkillCheckContainer().GetDemolitionSlot().GetDifficulty()))));
      };
    } else {
      if this.GetDevicePS().GetSkillCheckContainer().GetHackingSlot().WasPerformed() {
        sink.PushBool("Hacking skillcheck passed", this.GetDevicePS().GetSkillCheckContainer().GetHackingSlot().WasPerformed());
      };
      if this.GetDevicePS().GetSkillCheckContainer().GetEngineeringSlot().WasPerformed() {
        sink.PushBool("Engineering skillcheck passed", this.GetDevicePS().GetSkillCheckContainer().GetEngineeringSlot().WasPerformed());
      };
      if this.GetDevicePS().GetSkillCheckContainer().GetDemolitionSlot().WasPerformed() {
        sink.PushBool("Demolitions skillcheck passed", this.GetDevicePS().GetSkillCheckContainer().GetDemolitionSlot().WasPerformed());
      };
    };
    contentAssigmentRecord = TweakDBInterface.GetDeviceContentAssignmentRecord(this.GetDevicePS().GetContentAssignmentID());
    if contentAssigmentRecord != null {
      powerLevelMod = TDBID.ToStringDEBUG(contentAssigmentRecord.PowerLevelMod().GetID());
      sink.PushString("powerLevelMod", powerLevelMod);
      sink.PushFloat("Content Scale", TweakDBInterface.GetConstantStatModifierRecord(contentAssigmentRecord.PowerLevelMod().GetID()).Value());
    } else {
      sink.PushString("powerLevelMod Unassigned", "Content Scale is not set, Please Bug it");
    };
    sink.PushString("TweakDBRecord ", TDBID.ToStringDEBUG(this.GetTweakDBRecord()));
    sink.PushBool("Has any slave", this.GetDevicePS().HasAnySlave());
    sink.PushBool("Should reveal grid", this.GetDevicePS().ShouldRevealDevicesGrid());
    sink.PushBool("Connected to CLS", this.GetDevicePS().IsConnectedToCLS());
    sink.PushBool("Connected to security system", this.GetDevicePS().IsConnectedToSecuritySystem());
    sink.PushString("Security Access Level", EnumValueToString("ESecurityAccessLevel", Cast(EnumInt(this.GetDevicePS().GetSecurityAccessLevel()))));
    if EnumInt(this.GetDevicePS().GetSecurityAccessLevel()) > 0 {
      if this.GetDevicePS().IsPlayerAuthorized() {
        sink.PushBool("Is Player Authorized", this.GetDevicePS().IsPlayerAuthorized());
      };
      if this.GetDevicePS().IsPlayerAuthorized() {
        sink.PushBool("Have Password", this.GetDevicePS().IsDeviceSecuredWithPassword());
      };
      if this.GetDevicePS().IsPlayerAuthorized() {
        sink.PushBool("Require Keycard", this.GetDevicePS().IsDeviceSecuredWithKeycard());
      };
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_personalLinkComponent = EntityResolveComponentsInterface.GetComponent(ri, n"personalLinkPlayerWorkspot") as WorkspotResourceComponent;
    this.m_localization = EntityResolveComponentsInterface.GetComponent(ri, n"localization") as LocalizationStringComponent;
    this.m_disassemblableComponent = EntityResolveComponentsInterface.GetComponent(ri, n"disassemblableComponent") as DisassemblableComponent;
    this.m_IKslotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"IKslots") as SlotComponent;
    this.m_fxResourceMapper = EntityResolveComponentsInterface.GetComponent(ri, n"FxResourceMapper") as FxResourceMapperComponent;
    this.m_effectVisualization = EntityResolveComponentsInterface.GetComponent(ri, n"AreaEffectVisualization") as AreaEffectVisualizationComponent;
    this.m_resourceLibraryComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ResourceLibrary") as ResourceLibraryComponent;
    this.m_scanningComponent = EntityResolveComponentsInterface.GetComponent(ri, n"scanning") as ScanningComponent;
    this.m_gameplayRoleComponent = EntityResolveComponentsInterface.GetComponent(ri, n"GameplayRole") as GameplayRoleComponent;
    this.m_slotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"main_slot") as SlotComponent;
    this.m_ToggleZoomInteractionWorkspot = EntityResolveComponentsInterface.GetComponent(ri, n"ToggleZoomInteraction") as WorkspotResourceComponent;
    this.m_cameraZoomComponent = EntityResolveComponentsInterface.GetComponent(ri, n"cameraZoomComponent") as CameraComponent;
    this.m_cameraZoomComponent.SetIsHighPriority(true);
    this.m_cameraComponent = EntityResolveComponentsInterface.GetComponent(ri, n"cameraComponent") as CameraComponent;
    this.m_cameraComponent.SetIsHighPriority(true);
    this.CreateBlackboard();
    super.OnTakeControl(ri);
  }

  protected cb func OnDeviceVisible(evt: ref<gameDeviceVisibilityChangedEvent>) -> Bool {
    if evt.isVisible == 1u {
      this.m_isVisible = true;
      if !this.m_wasVisible {
        this.m_wasVisible = true;
        this.ResolveGameplayStateByTask();
      };
    } else {
      this.m_isVisible = false;
    };
    this.OnVisibilityChanged();
  }

  public final const func WasVisible() -> Bool {
    return this.m_wasVisible;
  }

  public final const func IsVisible() -> Bool {
    return this.m_isVisible;
  }

  protected func OnVisibilityChanged() -> Void;

  protected cb func OnGameAttached() -> Bool {
    let ps: ref<ScriptableDeviceComponentPS>;
    super.OnGameAttached();
    ps = this.GetDevicePS();
    ps.PassBlackboard(this.GetBlackboard());
    if ps.ForceResolveGameplayStateOnAttach() {
      this.ResolveGameplayStateByTask();
    };
    if IsDefined(this.m_personalLinkComponent) && IsNameValid(this.GetSlotTag()) {
      ps.SetHasPersonalLinkSlot(true);
    };
  }

  protected func ResolveGameplayState() -> Void {
    this.GetDevicePS().InitializeQuestDBCallbacksForQuestmark();
    this.RestoreDeviceState();
    if IsDefined(this.m_scanningComponent) {
      this.InitializeScanningData();
    };
    if this.GetDevicePS().GetDeviceOperationsContainer() != null {
      this.GetDevicePS().GetDeviceOperationsContainer().Initialize(this);
    };
    this.ResolveQuestMarkOnFact();
    this.InitializeScreenDefinition();
    this.InitializeGameplayObjectives();
    if IsDefined(this.m_cameraComponent) {
      this.GetDevicePS().SetPlayerTakeOverControl(true);
    };
    if this.GetDevicePS().ForceVisibilityInAnimSystemOnLogicReady() {
      this.ToggleForcedVisibilityInAnimSystem(n"LogicReady", true, 0.00);
    };
    this.SetLogicReady();
  }

  protected final func SetLogicReady() -> Void {
    let logicReadyEvt: ref<SetLogicReadyEvent> = new SetLogicReadyEvent();
    logicReadyEvt.isReady = true;
    this.SendEventToDefaultPS(logicReadyEvt);
  }

  protected cb func OnDetach() -> Bool {
    let devicePS: ref<ScriptableDeviceComponentPS>;
    super.OnDetach();
    devicePS = this.GetDevicePS();
    if IsDefined(devicePS) {
      if devicePS.GetDeviceOperationsContainer() != null {
        devicePS.GetDeviceOperationsContainer().UnInitialize(this);
      };
      devicePS.UnInitializeQuestDBCallbacksForQuestmark();
      devicePS.ClearWillingInvestigators();
      if devicePS.ForceVisibilityInAnimSystemOnLogicReady() {
        this.ToggleForcedVisibilityInAnimSystem(n"LogicReady", false, 0.00);
      };
    };
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    this.m_isInitialized = true;
    this.PushData();
  }

  protected cb func OnLogicReady(evt: ref<SetLogicReadyEvent>) -> Bool {
    this.isLogicReady = evt.isReady;
    this.m_isInitialized = true;
  }

  public const func IsInitialized() -> Bool {
    return this.m_isInitialized;
  }

  public const func IsDevice() -> Bool {
    return true;
  }

  protected func SetClearance() -> Void;

  protected final func InitializeScanningData() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"InitializeScanningDataTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func InitializeScanningDataTask(data: ref<ScriptTaskData>) -> Void {
    let description: String;
    let descriptionTweak: TweakDBID;
    let deviceScanningDescription: ref<DeviceScanningDescription>;
    let setScannerTime: ref<SetScanningTimeEvent> = new SetScanningTimeEvent();
    setScannerTime.time = 0.50;
    this.QueueEvent(setScannerTime);
    deviceScanningDescription = this.m_scanningComponent.GetObjectDescription() as DeviceScanningDescription;
    if IsDefined(deviceScanningDescription) {
      if !TDBID.IsValid(deviceScanningDescription.GetGameplayDesription()) {
        this.m_scanningTweakDBRecord = this.GetDevicePS().GetTweakDBDescriptionRecord();
        descriptionTweak = this.m_scanningTweakDBRecord;
        TDBID.Append(descriptionTweak, t".localizedName");
        description = TweakDBInterface.GetString(descriptionTweak, "no_description");
        if Equals(description, "no_description") {
          this.m_scanningTweakDBRecord = t"device_descriptions.no_descrtiption";
        };
      } else {
        this.m_scanningTweakDBRecord = deviceScanningDescription.GetGameplayDesription();
      };
    };
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    let baseData: BaseDeviceData;
    let resaveData: BaseResaveData;
    baseData.m_deviceState = this.m_deviceState;
    baseData.m_durabilityType = this.m_durabilityType;
    baseData.m_deviceName = this.GetDisplayName();
    resaveData.m_baseDeviceData = baseData;
    let psDevice: ref<ScriptableDeviceComponentPS> = ps as ScriptableDeviceComponentPS;
    psDevice.PushResaveData(resaveData);
    return true;
  }

  protected func PushData() -> Void;

  protected func PushPersistentData() -> Void {
    let baseData: BaseDeviceData;
    baseData.m_deviceState = this.m_deviceState;
    baseData.m_hackOwner = this;
    baseData.m_durabilityType = this.m_durabilityType;
    this.GetDevicePS().PushPersistentData(baseData);
    this.GetDevicePS().PassDeviceName(this.GetDisplayName(), this.m_debugOptions.m_debugName);
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    this.GetDevicePS().ForceDisableDevice();
  }

  protected cb func OnQuickSlotCommandUsed(evt: ref<QuickSlotCommandUsed>) -> Bool {
    this.ExecuteAction(evt.action, GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject());
  }

  protected final const func ExecuteAction(choice: InteractionChoice, executor: wref<GameObject>, layerTag: CName) -> Void {
    let action: ref<DeviceAction>;
    let sAction: ref<ScriptableDeviceAction>;
    let i: Int32 = 0;
    while i < ArraySize(choice.data) {
      action = FromVariant(choice.data[i]);
      if IsDefined(action) {
        if ChoiceTypeWrapper.IsType(choice.choiceMetaData.type, gameinteractionsChoiceType.CheckFailed) {
          return;
        };
        this.ExecuteAction(action, executor);
      };
      sAction = action as ScriptableDeviceAction;
      if IsDefined(sAction) {
        sAction.SetInteractionLayer(layerTag);
      };
      i += 1;
    };
  }

  protected final const func ExecuteAction(action: ref<DeviceAction>, opt executor: wref<GameObject>) -> Bool {
    let sAction: ref<ScriptableDeviceAction> = action as ScriptableDeviceAction;
    if sAction != null {
      sAction.RegisterAsRequester(this.GetEntityID());
      if executor != null {
        sAction.SetExecutor(executor);
      };
      sAction.ProcessRPGAction(this.GetGame());
      return true;
    };
    return false;
  }

  public final const func GetTweakDBRecord() -> TweakDBID {
    return this.GetDevicePS().GetTweakDBRecord();
  }

  protected final func EnableUpdate(shouldEnable: Bool, opt time: Float) -> Void {
    let cancelUpdateEvent: ref<CancelDeviceUpdateEvent>;
    if time != 0.00 {
      cancelUpdateEvent = new CancelDeviceUpdateEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, cancelUpdateEvent, time);
    };
    if shouldEnable {
      this.m_updateRunning = true;
      this.FireSingleTick();
    } else {
      this.m_updateRunning = false;
      GameInstance.GetDelaySystem(this.GetGame()).CancelTick(this.m_updateID);
    };
  }

  private final func FireSingleTick() -> Void {
    let deviceUpdate: ref<DeviceUpdateEvent> = new DeviceUpdateEvent();
    this.m_updateID = GameInstance.GetDelaySystem(this.GetGame()).TickOnEvent(this, deviceUpdate, -1.00);
  }

  protected cb func OnCancelUpdateEvent(evt: ref<CancelDeviceUpdateEvent>) -> Bool {
    this.m_updateRunning = false;
  }

  protected cb func OnDeviceUpdate(evt: ref<DeviceUpdateEvent>) -> Bool {
    if this.m_updateRunning {
      this.FireSingleTick();
      this.DeviceUpdate();
    };
  }

  protected func DeviceUpdate() -> Void;

  protected func RestoreDeviceState() -> Void {
    let ps: ref<ScriptableDeviceComponentPS>;
    if !IsFinal() {
      this.GetDevicePS().PassDeviceName(this.GetDisplayName(), this.m_debugOptions.m_debugName);
    };
    ps = this.GetDevicePS();
    if ps == null {
      return;
    };
    if !ps.IsSecurityWakeUpBlocked() && Equals(ps.GetDurabilityState(), EDeviceDurabilityState.NOMINAL) {
      ps.EvaluateDeviceState();
    };
    switch ps.GetDeviceState() {
      case EDeviceStatus.DISABLED:
        this.DeactivateDevice();
        break;
      case EDeviceStatus.UNPOWERED:
        this.CutPower();
        break;
      case EDeviceStatus.ON:
        this.TurnOnDevice();
        break;
      case EDeviceStatus.OFF:
        this.TurnOffDevice();
        break;
      default:
        Log("RestoreDeviceState / Unsupported EDeviceState - DEBUG");
    };
    this.ExecuteDeviceStateOperation();
    this.RestoreBaseActionOperations();
  }

  protected func UpdateDeviceState(opt isDelayed: Bool) -> Bool {
    let evt: ref<DelayedUpdateDeviceStateEvent>;
    if this.m_delayedUpdateDeviceStateID != GetInvalidDelayID() {
      return false;
    };
    if isDelayed {
      evt = new DelayedUpdateDeviceStateEvent();
      this.m_delayedUpdateDeviceStateID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.10, false);
      return false;
    };
    this.ExecuteDeviceStateOperation();
    this.ReEvaluateGameplayRole();
    return true;
  }

  protected cb func OnDelayedUpdateDeviceStateEvent(evt: ref<DelayedUpdateDeviceStateEvent>) -> Bool {
    this.m_delayedUpdateDeviceStateID = GetInvalidDelayID();
    this.UpdateDeviceState(false);
  }

  protected cb func OnSlaveStateChanged(evt: ref<PSDeviceChangedEvent>) -> Bool {
    this.UpdateDeviceState(true);
  }

  protected cb func OnPSChangedEvent(evt: ref<PSChangedEvent>) -> Bool {
    this.UpdateDeviceState(true);
  }

  public const func GetDeviceLink() -> ref<DeviceLinkComponentPS> {
    return this.GetDeviceLink();
  }

  public const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected final const func GetControllerPersistentState() -> ref<DeviceComponentPS> {
    return this.GetController().GetDeviceComponentPS();
  }

  protected func SendEventToDefaultPS(evt: ref<Event>) -> Void {
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    let ps: ref<DeviceComponentPS> = this.GetControllerPersistentState();
    return ps as ScriptableDeviceComponentPS;
  }

  protected final const func GetPSName() -> CName {
    return this.GetController().GetPSName();
  }

  public const func GetPSClassName() -> CName {
    return this.GetPSName();
  }

  protected final func NotifyParents() -> Void {
    let evt: ref<NotifyParentsEvent> = new NotifyParentsEvent();
    this.QueueEvent(evt);
  }

  protected cb func OnNotifyParents(evt: ref<NotifyParentsEvent>) -> Bool {
    this.GetDevicePS().NotifyParents();
  }

  public const func GetContext(opt processInitiator: ref<GameObject>, opt requestType: gamedeviceRequestType) -> GetActionsContext {
    let currentContext: GetActionsContext;
    let emptyObject: wref<GameObject>;
    currentContext.clearance = this.GetDevicePS().GetClearance();
    currentContext.requestorID = this.GetEntityID();
    currentContext.requestType = requestType;
    if IsDefined(processInitiator) {
      currentContext.processInitiatorObject = processInitiator;
    } else {
      currentContext.processInitiatorObject = emptyObject = new GameObject();
    };
    currentContext.ignoresAuthorization = false;
    return currentContext;
  }

  public final static func GetInteractionClearance() -> ref<Clearance> {
    let clearance: ref<Clearance> = Clearance.CreateClearance(2, 5);
    return clearance;
  }

  public const func IsPlayerAround() -> Bool {
    return true;
  }

  public const func GetInputContextName() -> CName {
    return n"DeviceBase";
  }

  public final const func GetDeviceName() -> String {
    return this.GetDevicePS().GetDeviceName();
  }

  public final const func GetDeviceStatusString() -> String {
    return this.GetDevicePS().GetDeviceStatus();
  }

  public final const func GetDeviceState() -> EDeviceStatus {
    return this.GetDevicePS().GetDeviceState();
  }

  public final const func IsDeviceSecured() -> Bool {
    return this.GetDevicePS().IsDeviceSecured();
  }

  protected final func GetLocalization() -> ref<LocalizationStringComponent> {
    return this.m_localization;
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  public const func GetBlackboard() -> ref<IBlackboard> {
    return this.m_blackboard;
  }

  protected func GetGameController() -> ref<DeviceInkGameControllerBase> {
    if this.m_uiComponent != null {
      return this.m_uiComponent.GetGameController() as DeviceInkGameControllerBase;
    };
    return null;
  }

  public final const func GetScreenDefinition() -> ScreenDefinitionPackage {
    let screen: ScreenDefinitionPackage;
    if IsDefined(this.m_uiComponent) && this.m_uiComponent.IsScreenDefinitionValid() {
      screen = this.m_uiComponent.GetScreenDefinition();
    } else {
      screen.style = TweakDBInterface.GetWidgetStyleRecord(this.m_screenDefinition.style);
      screen.screenDefinition = TweakDBInterface.GetDeviceUIDefinitionRecord(this.m_screenDefinition.screenDefinition);
    };
    return screen;
  }

  public final const func IsUIdirty() -> Bool {
    return this.m_isUIdirty;
  }

  public const func IsReadyForUI() -> Bool {
    return this.m_isVisible || this.GetDevicePS().ForceResolveGameplayStateOnAttach();
  }

  public final const func GetDebuggerProperties() -> DebuggerProperties {
    return this.m_debugOptions;
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().DeviceBaseBlackboard);
  }

  public const func ShouldEnableRemoteLayer() -> Bool {
    return this.IsTechie() || this.GetDevicePS().IsQuickHacksExposed() && this.IsNetrunner();
  }

  public const func IsConnectedToBackdoorDevice() -> Bool {
    return this.GetDevicePS().IsConnectedToBackdoorDevice();
  }

  public const func IsBackdoor() -> Bool {
    return this.GetDevicePS().HasNetworkBackdoor();
  }

  public const func IsActiveBackdoor() -> Bool {
    let ps: ref<ScriptableDeviceComponentPS> = this.GetDevicePS();
    if this.IsCyberdeckEquippedOnPlayer() && ps.HasNetworkBackdoor() && ps.HasPersonalLinkSlot() {
      return !ps.WasHackingMinigameSucceeded();
    };
    return false;
  }

  public const func IsQuickHackAble() -> Bool {
    if !this.GetDevicePS().HasPlaystyle(EPlaystyle.NETRUNNER) || this.IsPrevention() {
      return false;
    };
    if QuickhackModule.IsQuickhackBlockedByScene(this.GetPlayerMainObject()) {
      return false;
    };
    if !EquipmentSystem.IsCyberdeckEquipped(Device.GetPlayerMainObjectStatic(this.GetGame())) {
      return false;
    };
    return true;
  }

  public final const func IsPotentiallyQuickHackable() -> Bool {
    return this.GetDevicePS().IsPotentiallyQuickHackable();
  }

  public const func IsQuickHacksExposed() -> Bool {
    return this.GetDevicePS().IsQuickHacksExposed();
  }

  public const func IsBreached() -> Bool {
    return this.GetDevicePS().IsBreached();
  }

  public final const func GetNetworkSecurityLevel() -> String {
    let returnVal: String;
    let difficulty: EGameplayChallengeLevel = this.GetDevicePS().GetBackdoorAccessPoint().GetSkillCheckContainer().GetHackingSlot().GetDifficulty();
    switch difficulty {
      case EGameplayChallengeLevel.EASY:
        returnVal = "LocKey#10978";
        break;
      case EGameplayChallengeLevel.MEDIUM:
        returnVal = "LocKey#10979";
        break;
      case EGameplayChallengeLevel.HARD:
        returnVal = "LocKey#10980";
        break;
      case EGameplayChallengeLevel.IMPOSSIBLE:
        returnVal = "LocKey#10981";
      default:
    };
    return returnVal;
  }

  public const func IsControllingDevices() -> Bool {
    return this.GetDevicePS().HasAnySlave();
  }

  public const func HasAnySlaveDevices() -> Bool {
    return this.GetDevicePS().HasAnySlave();
  }

  public const func HasImportantInteraction() -> Bool {
    return this.IsSolo() || this.IsNetrunner() || this.IsTechie();
  }

  public final const func ShouldRevealDevicesGrid() -> Bool {
    return this.GetDevicePS().ShouldRevealDevicesGrid();
  }

  public const func GetSecuritySystem() -> ref<SecuritySystemControllerPS> {
    return this.GetDevicePS().GetSecuritySystem();
  }

  public const func IsConnectedToSecuritySystem() -> Bool {
    return this.GetDevicePS().IsConnectedToSecuritySystem();
  }

  protected final const func IsConnectedToActionsSequencer() -> Bool {
    return this.GetDevicePS().IsConnectedToActionsSequencer();
  }

  protected final const func IsLockedViaSequencer() -> Bool {
    return this.GetDevicePS().IsLockedViaSequencer();
  }

  public const func IsTargetTresspassingMyZone(target: ref<GameObject>) -> Bool {
    if !this.IsConnectedToSecuritySystem() {
      return false;
    };
    if this.GetDevicePS().GetSecuritySystem().ShouldReactToTarget(target.GetEntityID(), this.GetEntityID()) {
      return true;
    };
    return false;
  }

  public final const func GetFxResourceMapper() -> ref<FxResourceMapperComponent> {
    return this.m_fxResourceMapper;
  }

  public final const func GetResourceLibrary() -> ref<ResourceLibraryComponent> {
    return this.m_resourceLibraryComponent;
  }

  protected cb func OnDurabilityLimitReach(evt: ref<DurabilityLimitReach>) -> Bool {
    this.BreakDevice();
  }

  protected cb func OnChangeJuryrigTrapState(evt: ref<ChangeJuryrigTrapState>) -> Bool {
    this.SetJuryrigTrapState(evt.newState);
  }

  protected cb func OnPerformedAction(evt: ref<PerformedAction>) -> Bool {
    let action: ref<ScriptableDeviceAction>;
    let sequenceQuickHacks: ref<ForwardAction>;
    this.SetScannerDirty(true);
    action = evt.m_action as ScriptableDeviceAction;
    this.ExecuteBaseActionOperation(evt.m_action.GetClassName());
    if action.CanTriggerStim() {
      this.TriggerAreaEffectDistractionByAction(action);
    };
    if IsDefined(action) && action.IsIllegal() && !action.IsQuickHack() {
      this.ResolveIllegalAction(action.GetExecutor(), action.GetDurationValue());
    };
    if this.IsConnectedToActionsSequencer() && !this.IsLockedViaSequencer() {
      sequenceQuickHacks = new ForwardAction();
      sequenceQuickHacks.requester = this.GetDevicePS().GetID();
      sequenceQuickHacks.actionToForward = action;
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetActionsSequencer().GetID(), this.GetDevicePS().GetActionsSequencer().GetClassName(), sequenceQuickHacks);
    };
    this.ResolveQuestImportanceOnPerformedAction(action);
  }

  protected func ResolveIllegalAction(executor: ref<GameObject>, duration: Float) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let stimData: stimInvestigateData;
    if IsDefined(executor) {
      broadcaster = executor.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        stimData.fearPhase = -1;
        broadcaster.TriggerSingleBroadcast(this, gamedataStimType.IllegalAction, 15.00, stimData);
      };
    };
  }

  public final func FastForwardAnimations() -> Void {
    let evt: ref<AnimFastForwardEvent> = new AnimFastForwardEvent();
    this.QueueEvent(evt);
    this.m_wasAnimationFastForwarded = true;
  }

  protected cb func OnToggleON(evt: ref<ToggleON>) -> Bool {
    this.m_isUIdirty = true;
    if this.GetDevicePS().IsON() {
      this.TurnOnDevice();
    } else {
      this.TurnOffDevice();
    };
    if !this.GetDevicePS().IsON() && this.GetDevicePS().IsAdvancedInteractionModeOn() {
      this.SetZoomBlackboardValues(false);
      this.GetDevicePS().SetAdvancedInteractionModeOn(false);
      this.RegisterPlayerInputListener(false);
    };
    this.UpdateDeviceState();
  }

  protected cb func OnToggleActivation(evt: ref<ToggleActivation>) -> Bool {
    this.m_isUIdirty = true;
    if this.GetDevicePS().IsDisabled() {
      this.DeactivateDevice();
    } else {
      this.ActivateDevice();
    };
    this.RestoreDeviceState();
    this.UpdateDeviceState();
  }

  protected cb func OnTogglePower(evt: ref<TogglePower>) -> Bool {
    this.m_isUIdirty = true;
    if this.GetDevicePS().IsUnpowered() {
      this.CutPower();
    } else {
      this.RestorePower();
    };
    this.UpdateDeviceState();
  }

  protected cb func OnSetDeviceUnpowered(evt: ref<SetDeviceUnpowered>) -> Bool {
    this.m_isUIdirty = true;
    this.CutPower();
    this.UpdateDeviceState();
  }

  protected cb func OnSetDevicePowered(evt: ref<SetDevicePowered>) -> Bool {
    this.m_isUIdirty = true;
    this.RestorePower();
    this.UpdateDeviceState();
  }

  protected cb func OnSetON(evt: ref<SetDeviceON>) -> Bool {
    this.m_isUIdirty = true;
    this.TurnOnDevice();
    this.UpdateDeviceState();
  }

  protected cb func OnSetOFF(evt: ref<SetDeviceOFF>) -> Bool {
    this.m_isUIdirty = true;
    this.TurnOffDevice();
    this.UpdateDeviceState();
  }

  protected cb func OnAuthorizeUser(evt: ref<AuthorizeUser>) -> Bool {
    this.m_isUIdirty = true;
    this.UpdateDeviceState();
  }

  protected cb func OnSetAuthorizationModuleON(evt: ref<SetAuthorizationModuleON>) -> Bool {
    this.m_isUIdirty = true;
  }

  protected cb func OnSetAuthorizationModuleOFF(evt: ref<SetAuthorizationModuleOFF>) -> Bool {
    this.m_isUIdirty = true;
  }

  protected cb func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> Bool {
    this.m_disassemblableComponent.ObtainParts();
    this.UpdateDeviceState();
  }

  protected cb func OnToggleJuryrigTrap(evt: ref<ToggleJuryrigTrap>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    Equals(this.GetDevicePS().GetJuryrigTrapState(), EJuryrigTrapState.ARMED) ? this.DeactivateJuryrigTrap() : this.ArmJuryrigTrap();
    broadcaster = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(this, gamedataStimType.Distract);
    };
    this.UpdateDeviceState();
  }

  protected cb func OnTogglePersonalLink(evt: ref<TogglePersonalLink>) -> Bool {
    let executor: ref<GameObject> = evt.GetExecutor();
    if Equals(this.GetDevicePS().GetPersonalLinkStatus(), EPersonalLinkConnectionStatus.NOT_CONNECTED) {
      if !IsDefined(executor) {
        return false;
      };
      this.TogglePersonalLink(false, executor);
    } else {
      if Equals(this.GetDevicePS().GetPersonalLinkStatus(), EPersonalLinkConnectionStatus.CONNECTING) {
        if !IsDefined(executor) {
          executor = this.GetPlayerMainObject();
        };
        this.TogglePersonalLink(true, executor);
      };
    };
    this.UpdateDeviceState();
  }

  protected func TogglePersonalLink(toggle: Bool, puppet: ref<GameObject>) -> Void {
    let debug_leftSlot: WorldTransform;
    let debug_slotPosition: WorldTransform;
    let personalLinkEvent: ref<ManagePersonalLinkChangeEvent>;
    if toggle {
      if puppet.IsPlayer() {
        this.m_personalLinkFailsafeID = GetInvalidDelayID();
        RPGManager.ForceEquipPersonalLink(puppet as PlayerPuppet);
        personalLinkEvent = new ManagePersonalLinkChangeEvent();
        personalLinkEvent.shouldEquip = true;
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(puppet, personalLinkEvent, 0.50);
      };
      if TweakDBInterface.GetBool(t"Items.personal_link.isIKEnabled", false) {
        this.InitiatePersonalLinkWorkspot(puppet);
      } else {
        this.m_IKslotComponent.GetSlotTransform(n"leftSlot", debug_leftSlot);
        this.m_IKslotComponent.GetSlotTransform(n"personalLinkSlot", debug_slotPosition);
        this.EnterWorkspotWithIK(puppet, this.m_personalLinkComponent.shouldCrouch, n"unlockedCamera", n"personalLinkPlayerWorkspot", WorldPosition.ToVector4(WorldTransform.GetWorldPosition(debug_slotPosition)), WorldPosition.ToVector4(WorldTransform.GetWorldPosition(debug_leftSlot)));
      };
    } else {
      this.LeaveWorkspot(puppet);
    };
  }

  protected func InitiatePersonalLinkWorkspot(puppet: ref<GameObject>) -> Void {
    let personalLinkSlot: WorldTransform;
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let resendAnimFeaturesHACK: ref<RepeatPersonalLinkAnimFeaturesHACK>;
    let ikFeature: ref<animAnimFeature_IK> = new animAnimFeature_IK();
    let workspotFeature: ref<AnimFeature_WorkspotIK> = new AnimFeature_WorkspotIK();
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGame());
    if !IsDefined(workspotSystem) {
      return;
    };
    this.m_IKslotComponent.GetSlotTransform(this.GetSlotTag(), personalLinkSlot);
    if puppet.IsPlayer() {
      playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(puppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    };
    ikFeature.point = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(personalLinkSlot));
    workspotFeature.isInteractingWithDevice = true;
    workspotFeature.rightHandRotation = WorldTransform.GetOrientation(personalLinkSlot);
    this.ApplyAnimFeatureToReplicate(puppet, n"playerIK", ikFeature);
    this.ApplyAnimFeatureToReplicate(puppet, n"WorkspotIK", workspotFeature);
    workspotSystem.PlayInDevice(this, puppet, n"unlockedCamera", n"personalLinkPlayerWorkspot");
    if !this.m_personalLinkHackSend {
      workspotSystem.SendJumpToTagCommandEnt(puppet, this.GetSlotTag(), true);
      resendAnimFeaturesHACK = new RepeatPersonalLinkAnimFeaturesHACK();
      resendAnimFeaturesHACK.activator = puppet;
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, resendAnimFeaturesHACK, 0.80);
    };
  }

  protected final const func GetSlotTag() -> CName {
    let options: CName[3];
    let slotPos: WorldTransform;
    options[0] = n"personalLinkSlotRight";
    options[1] = n"personalLinkSlot";
    options[2] = n"personalLinkSlotBottom";
    let i: Int32 = 0;
    while i < ArraySize(options) {
      if this.m_IKslotComponent.GetSlotTransform(options[i], slotPos) {
        return options[i];
      };
      i += 1;
    };
    return n"";
  }

  protected cb func OnRepeatApplyAnimFeatureHACK(evt: ref<RepeatPersonalLinkAnimFeaturesHACK>) -> Bool {
    this.m_personalLinkHackSend = true;
    this.InitiatePersonalLinkWorkspot(evt.activator);
  }

  protected cb func OnToggleZoomInteraction(evt: ref<ToggleZoomInteraction>) -> Bool {
    this.EvaluateCameraZoomState(evt.GetExecutor());
  }

  protected cb func OnQuestForceCameraZoom(evt: ref<QuestForceCameraZoom>) -> Bool {
    this.EvaluateCameraZoomState(GetPlayer(this.GetGame()));
  }

  protected final func EvaluateCameraZoomState(executor: ref<GameObject>) -> Void {
    if executor == null {
      return;
    };
    if !this.GetDevicePS().IsAdvancedInteractionModeOn() {
      this.RegisterPlayerInputListener(false);
      this.SetZoomBlackboardValues(false);
    } else {
      this.ShowAdvanceInteractionInputHints();
      this.RegisterPlayerInputListener(true);
      this.SetZoomBlackboardValues(true);
      this.ToggleCameraZoom(true);
    };
    this.UpdateDeviceState();
  }

  protected func ShouldExitZoomOnAuthorization() -> Bool {
    return false;
  }

  protected func ShowAdvanceInteractionInputHints() -> Void {
    let data: InputHintData;
    data.action = n"click";
    data.source = n"AdvanceInteractionMode";
    data.localizedLabel = "LocKey#49383";
    data.sortingPriority = 4;
    this.SendGameplayInputHintEvent(true, data);
    data.action = n"UI_FakeCursor";
    data.source = n"AdvanceInteractionMode";
    data.localizedLabel = "LocKey#49377";
    data.sortingPriority = 3;
    data.action = n"UI_MoveCursorVertically";
    data.source = n"AdvanceInteractionMode";
    data.localizedLabel = "LocKey#49380";
    data.sortingPriority = 2;
    data.action = n"right_stick_y";
    data.source = n"AdvanceInteractionMode";
    data.localizedLabel = "LocKey#49382";
    data.sortingPriority = 1;
    this.SendGameplayInputHintEvent(true, data);
    data.action = n"UI_Exit";
    data.source = n"AdvanceInteractionMode";
    data.localizedLabel = "LocKey#49376";
    data.sortingPriority = 0;
    this.SendGameplayInputHintEvent(true, data);
  }

  protected func HideAdvanceInteractionInputHints() -> Void {
    this.SendRemoveGameplayInputHintsBySourceEvent(n"AdvanceInteractionMode");
  }

  protected final func SendGameplayInputHintEvent(show: Bool, data: InputHintData) -> Void {
    let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = show;
    evt.targetHintContainer = n"GameplayInputHelper";
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(evt);
  }

  private final func SendRemoveGameplayInputHintsBySourceEvent(sourceName: CName) -> Void {
    let evt: ref<DeleteInputHintBySourceEvent> = new DeleteInputHintBySourceEvent();
    evt.source = sourceName;
    evt.targetHintContainer = n"GameplayInputHelper";
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(evt);
  }

  protected final func ToggleCameraZoom(toggle: Bool) -> Void {
    let blackboard: ref<IBlackboard>;
    if !IsDefined(this.m_cameraZoomComponent) {
      return;
    };
    blackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if toggle {
      this.m_cameraZoomComponent.Activate(1.00);
      if IsDefined(blackboard) {
        this.m_ZoomUIListenerID = blackboard.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice, this, n"OnIsUIZoomDeviceChange");
      };
      GameInstance.GetUISystem(this.GetGame()).PushGameContext(UIGameContext.DeviceZoom);
    } else {
      this.m_cameraZoomComponent.Deactivate(1.00);
      GameInstance.GetUISystem(this.GetGame()).PopGameContext(UIGameContext.DeviceZoom);
    };
  }

  protected cb func OnIsUIZoomDeviceChange(value: Bool) -> Bool {
    let evt: ref<UnregisterFromZoomBlackboardEvent>;
    if !value {
      evt = new UnregisterFromZoomBlackboardEvent();
      this.QueueEvent(evt);
      this.HideAdvanceInteractionInputHints();
      this.GetDevicePS().SetAdvancedInteractionModeOn(false);
      this.RegisterPlayerInputListener(false);
      this.ToggleCameraZoom(false);
    };
  }

  protected cb func OnUnregisterFromZoomBlackboardEvent(evt: ref<UnregisterFromZoomBlackboardEvent>) -> Bool {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(blackboard) && IsDefined(this.m_ZoomUIListenerID) {
      blackboard.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice, this.m_ZoomUIListenerID);
    };
    this.SetZoomBlackboardValues(false);
  }

  protected cb func OnOpenFullscreenUI(evt: ref<OpenFullscreenUI>) -> Bool {
    let executor: ref<GameObject> = evt.GetExecutor();
    if executor == null {
      return false;
    };
    if !this.GetDevicePS().IsAdvancedInteractionModeOn() {
      this.SetZoomBlackboardValues(false);
    } else {
      this.SetZoomBlackboardValues(true);
      this.RegisterPlayerInputListener(true);
    };
    this.UpdateDeviceState();
  }

  protected final func RegisterPlayerInputListener(shouldRegister: Bool) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(player) {
      if shouldRegister {
        player.RegisterInputListener(this);
      } else {
        if !shouldRegister {
          player.UnregisterInputListener(this);
        };
      };
    };
  }

  protected cb func OnQuestForceEnabled(evt: ref<QuestForceEnabled>) -> Bool {
    this.RestoreDeviceState();
    this.ActivateDevice();
  }

  protected cb func OnQuestForceDisabled(evt: ref<QuestForceDisabled>) -> Bool {
    this.DeactivateDevice();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForcePower(evt: ref<QuestForcePower>) -> Bool {
    if evt.ShouldActivateDevice() {
      this.ActivateDevice();
    };
    this.RestorePower();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceUnpower(evt: ref<QuestForceUnpower>) -> Bool {
    if evt.ShouldActivateDevice() {
      this.ActivateDevice();
    };
    this.CutPower();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceEnableAuthorization(evt: ref<QuestForceAuthorizationEnabled>) -> Bool {
    this.TurnAuthorizationModuleON();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceDisableAuthorization(evt: ref<QuestForceAuthorizationDisabled>) -> Bool {
    this.TurnAuthorizationModuleOFF();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceArmJuryrigTrap(evt: ref<QuestForceJuryrigTrapArmed>) -> Bool {
    this.ArmJuryrigTrap();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceDeactivateJuryrigTrap(evt: ref<QuestForceJuryrigTrapDeactivated>) -> Bool {
    this.DeactivateJuryrigTrap();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceON(evt: ref<QuestForceON>) -> Bool {
    if evt.ShouldActivateDevice() {
      this.ActivateDevice();
    };
    this.TurnOnDevice();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceOFF(evt: ref<QuestForceOFF>) -> Bool {
    if evt.ShouldActivateDevice() {
      this.ActivateDevice();
    };
    this.TurnOffDevice();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceSecuritySystemSafe(evt: ref<QuestForceSecuritySystemSafe>) -> Bool {
    this.SetStateSafe();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceSecuritySystemAlarmed(evt: ref<QuestForceSecuritySystemAlarmed>) -> Bool {
    this.SetStateAlarmed();
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceSecuritySystemArmed(evt: ref<QuestForceSecuritySystemArmed>) -> Bool {
    this.SetStateArmed();
    this.UpdateDeviceState();
  }

  protected cb func OnAttitudeChanged(evt: ref<AttitudeChangedEvent>) -> Bool {
    super.OnAttitudeChanged(evt);
  }

  protected cb func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> Bool;

  protected cb func OnSecuritySystemForceAttitudeChange(evt: ref<SecuritySystemForceAttitudeChange>) -> Bool;

  protected cb func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> Bool;

  private func InitializeScreenDefinition() -> Void;

  protected func ShouldAlwasyRefreshUIInLogicAra() -> Bool {
    return false;
  }

  protected func RefreshUI(opt isDelayed: Bool) -> Void;

  protected cb func OnToggleUIInteractivity(evt: ref<ToggleUIInteractivity>) -> Bool {
    this.GetBlackboard().SetBool(this.GetBlackboardDef().UI_InteractivityBlocked, !evt.m_isInteractive);
    this.GetDevicePS().ToggleInteractivity(evt.m_isInteractive);
  }

  protected cb func OnUIAction(evt: ref<UIActionEvent>) -> Bool {
    this.ExecuteAction(evt.action, evt.executor);
  }

  protected cb func OnRequestUiRefresh(evt: ref<RequestUIRefreshEvent>) -> Bool {
    this.GetDevicePS().RefreshUI(this.GetBlackboard());
  }

  protected cb func OnRequesBreadCrumbBarUpdate(evt: ref<RequestBreadCrumbBarUpdateEvent>) -> Bool {
    this.GetDevicePS().RequestBreadCrumbUpdate(this.GetBlackboard(), evt.breadCrumbData);
  }

  protected cb func OnRequestActionWidgetsUpdate(evt: ref<RequestActionWidgetsUpdateEvent>) -> Bool {
    this.RequestActionWidgetsUpdate(this.GetBlackboard());
  }

  protected cb func OnDeviceWidgetUpdate(evt: ref<RequestDeviceWidgetUpdateEvent>) -> Bool {
    this.RequestDeviceWidgetsUpdate(this.GetBlackboard());
  }

  protected final func RequestActionWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    this.GetDevicePS().RequestActionWidgetsUpdate(blackboard);
  }

  protected final func RequestDeviceWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    this.GetDevicePS().RequestDeviceWidgetsUpdate(blackboard);
  }

  protected func RequestThumbnailWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void;

  protected final func SetZoomBlackboardValues(newState: Bool) -> Void {
    let playerObject: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerObject.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, newState);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice, newState);
    playerStateMachineBlackboard.FireCallbacks();
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    if activator.IsPlayer() {
      this.m_workspotActivator = activator;
      workspotSystem.PlayInDeviceSimple(this, activator, freeCamera, componentName, deviceData, n"", 0.50, WorkspotSlidingBehaviour.DontPlayAtResourcePosition, this);
    };
  }

  protected cb func OnPlayInDeviceCallbackEvent(evt: ref<PlayInDeviceCallbackEvent>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    if evt.wasPlayInDeviceSuccessful {
      playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.m_workspotActivator.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    };
  }

  protected func EnterWorkspotWithIK(activator: ref<GameObject>, shouldCrouch: Bool, opt cameraFlavour: CName, opt componentName: CName, opt cameraPosition: Vector4, opt cameraRotation: Quaternion, opt rightHandPosition: Vector4, opt rightHandRotation: Quaternion, opt leftHandPosition: Vector4, opt leftHandRotation: Quaternion) -> Void {
    let animFeature: ref<AnimFeature_WorkspotIK>;
    let workspotSystem: ref<WorkspotGameSystem>;
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(activator.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    animFeature = new AnimFeature_WorkspotIK();
    animFeature.rightHandPosition = rightHandPosition;
    animFeature.leftHandPosition = leftHandPosition;
    animFeature.cameraPosition = cameraPosition;
    animFeature.rightHandRotation = rightHandRotation;
    animFeature.leftHandRotation = leftHandRotation;
    animFeature.cameraRotation = cameraRotation;
    animFeature.shouldCrouch = shouldCrouch;
    this.ApplyAnimFeatureToReplicate(activator, n"WorkspotIK", animFeature);
    workspotSystem = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDevice(this, activator, cameraFlavour, componentName);
  }

  protected func LeaveWorkspot(activator: ref<GameObject>) -> Void {
    let direction: Vector4;
    let failsafe: ref<MissingWorkspotComponentFailsafeEvent>;
    let orientation: Quaternion;
    let workspotSystem: ref<WorkspotGameSystem>;
    let animFeature: ref<AnimFeature_WorkspotIK> = new AnimFeature_WorkspotIK();
    animFeature.isInteractingWithDevice = false;
    this.ApplyAnimFeatureToReplicate(activator, n"WorkspotIK", animFeature);
    Quaternion.SetIdentity(orientation);
    direction = new Vector4(0.00, 0.00, 0.00, 1.00);
    workspotSystem = GameInstance.GetWorkspotSystem(this.GetGame());
    if activator.IsPlayer() {
      failsafe = new MissingWorkspotComponentFailsafeEvent();
      failsafe.playerEntityID = activator.GetEntityID();
      this.m_personalLinkFailsafeID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, failsafe, 1.80);
      workspotSystem.SendJumpToTagCommandEnt(activator, this.GetSlotTag() + n".end", true);
    } else {
      workspotSystem.StopInDevice(activator, direction, orientation);
    };
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    let delaySystem: ref<DelaySystem>;
    let personalLinkEvent: ref<ManagePersonalLinkChangeEvent>;
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerPuppet: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if playerPuppet == null {
      return false;
    };
    if Equals(componentName, n"personalLinkPlayerWorkspot") {
      delaySystem = GameInstance.GetDelaySystem(this.GetGame());
      if IsDefined(delaySystem) {
        if this.m_personalLinkFailsafeID != GetInvalidDelayID() {
          delaySystem.CancelDelay(this.m_personalLinkFailsafeID);
          delaySystem.CancelCallback(this.m_personalLinkFailsafeID);
          this.m_personalLinkFailsafeID = GetInvalidDelayID();
        };
        delaySystem.DelayEvent(playerPuppet, personalLinkEvent, 0.03);
      };
      RPGManager.ForceUnequipPersonalLink(playerPuppet);
      this.m_personalLinkHackSend = false;
      personalLinkEvent = new ManagePersonalLinkChangeEvent();
      personalLinkEvent.shouldEquip = false;
      this.GetDevicePS().DisconnectPersonalLink(playerPuppet, n"direct");
    };
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, false);
  }

  protected cb func OnMissingWorkspotComponentFailsafeEvent(evt: ref<MissingWorkspotComponentFailsafeEvent>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    if this.m_personalLinkFailsafeID == GetInvalidDelayID() {
      return false;
    };
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(evt.playerEntityID, GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, false);
    this.m_personalLinkFailsafeID = GetInvalidDelayID();
  }

  protected func DetermineInteractionState(opt context: GetActionsContext) -> Void;

  protected func ResetChoicesByEvent() -> Void;

  protected func AdjustInteractionComponent() -> Void;

  public const func IsDirectInteractionCondition() -> Bool {
    return true;
  }

  protected func ExecuteDeviceStateOperation() -> Void {
    let ps: ref<ScriptableDeviceComponentPS> = this.GetDevicePS();
    let state: EDeviceStatus = ps.GetDeviceState();
    if ps.GetDeviceOperationsContainer() != null {
      ps.GetDeviceOperationsContainer().EvaluateBaseStateTriggers(state, this);
    };
  }

  protected func ExecuteBaseActionOperation(actionClassName: CName) -> Void {
    let ps: ref<ScriptableDeviceComponentPS> = this.GetDevicePS();
    if ps.GetDeviceOperationsContainer() != null {
      ps.GetDeviceOperationsContainer().EvaluateDeviceActionTriggers(actionClassName, this);
    };
  }

  protected final func RestoreBaseActionOperations() -> Void {
    let ps: ref<ScriptableDeviceComponentPS> = this.GetDevicePS();
    let actionsIDs: array<CName> = ps.GetPerformedActionsIDs();
    let i: Int32 = 0;
    while i < ArraySize(actionsIDs) {
      if ps.GetDeviceOperationsContainer() != null {
        ps.GetDeviceOperationsContainer().RestoreDeviceActionOperations(actionsIDs[i], this);
      };
      i += 1;
    };
  }

  protected final func SetJuryrigTrapComponentState(newState: Bool) -> Void {
    this.GetDevicePS().SetJuryrigTrapActiveState(newState);
  }

  private final func SetJuryrigTrapState(newState: EJuryrigTrapState) -> Void {
    this.GetDevicePS().SetJuryrigTrapArmedState(newState);
  }

  public const func ShouldShowScanner() -> Bool {
    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked() {
      return false;
    };
    if NotEquals(this.GetCurrentGameplayRole(), IntEnum(1l)) {
      return true;
    };
    return this.ShouldShowScanner();
  }

  protected func FillObjectDescription(out arr: array<ScanningTooltipElementDef>) -> Void {
    if !this.GetDevicePS().IsDisabled() {
      this.FillObjectDescription(arr);
    };
  }

  public const func CompileScannerChunks() -> Bool {
    let aps: array<ref<AccessPointControllerPS>>;
    let attitudeChunk: ref<ScannerAttitude>;
    let authorizationChunk: ref<ScannerAuthorization>;
    let connectionsChunk: ref<ScannerConnections>;
    let deviceStatusChunk: ref<ScannerDeviceStatus>;
    let healthChunk: ref<ScannerHealth>;
    let i: Int32;
    let keycards: array<TweakDBID>;
    let nameChunk: ref<ScannerName>;
    let networkLevelChunk: ref<ScannerNetworkLevel>;
    let networkStatusChunk: ref<ScannerNetworkStatus>;
    let passwords: array<CName>;
    let record: ref<ScannableData_Record>;
    let skillchecks: array<UIInteractionSkillCheck>;
    let skillchecksChunk: ref<ScannerSkillchecks>;
    let vulnerabilities: array<TweakDBID>;
    let vulnerabilitiesChunk: ref<ScannerVulnerabilities>;
    let vulnerability: Vulnerability;
    let devicePS: ref<ScriptableDeviceComponentPS> = this.GetDevicePS();
    let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_ScannerModules);
    if !IsDefined(devicePS) || !IsDefined(scannerBlackboard) {
      return false;
    };
    if devicePS.IsDisabled() {
      return false;
    };
    scannerBlackboard.SetInt(GetAllBlackboardDefs().UI_ScannerModules.ObjectType, EnumInt(ScannerObjectType.DEVICE), true);
    aps = devicePS.GetAccessPoints();
    nameChunk = new ScannerName();
    nameChunk.Set(this.GetScannerName());
    scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerName, ToVariant(nameChunk));
    keycards = devicePS.GetKeycards();
    passwords = devicePS.GetPasswords();
    if ArraySize(keycards) > 0 || ArraySize(passwords) > 0 {
      authorizationChunk = new ScannerAuthorization();
      authorizationChunk.Set(ArraySize(keycards) > 0, ArraySize(passwords) > 0);
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerAuthorization, ToVariant(authorizationChunk));
    };
    if devicePS.ShouldScannerShowNetwork() {
      networkStatusChunk = new ScannerNetworkStatus();
      if ArraySize(aps) > 0 {
        networkLevelChunk = new ScannerNetworkLevel();
        networkLevelChunk.Set(aps[0].GetSkillCheckContainer().GetHackingSlot().GetBaseSkill().GetRequiredLevel(this.GetGame()));
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerNetworkLevel, ToVariant(networkLevelChunk));
        if aps[0].IsBreached() {
          networkStatusChunk.Set(ScannerNetworkState.BREACHED);
        } else {
          networkStatusChunk.Set(ScannerNetworkState.NOT_BREACHED);
        };
      } else {
        networkStatusChunk.Set(ScannerNetworkState.NOT_CONNECTED);
      };
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerNetworkStatus, ToVariant(networkStatusChunk));
    };
    if devicePS.ShouldScannerShowAttitude() {
      attitudeChunk = new ScannerAttitude();
      attitudeChunk.Set(this.GetAttitudeTowards(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerAttitude, ToVariant(attitudeChunk));
    };
    if devicePS.ShouldScannerShowStatus() {
      deviceStatusChunk = new ScannerDeviceStatus();
      deviceStatusChunk.Set(LocKeyToString(TweakDBInterface.GetScannableDataRecord(devicePS.GetScannerStatusRecord()).LocalizedDescription()));
      deviceStatusChunk.SetFriendlyName(TweakDBInterface.GetScannableDataRecord(devicePS.GetScannerStatusRecord()).FriendlyName());
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerDeviceStatus, ToVariant(deviceStatusChunk));
    };
    if devicePS.ShouldScannerShowHealth() {
      healthChunk = new ScannerHealth();
      healthChunk.Set(Cast(this.GetCurrentHealth()), Cast(this.GetTotalHealth()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerHealth, ToVariant(healthChunk));
    };
    vulnerabilities = devicePS.GetAllQuickHackVulnerabilities();
    if ArraySize(vulnerabilities) > 0 {
      vulnerabilitiesChunk = new ScannerVulnerabilities();
      i = 0;
      while i < ArraySize(vulnerabilities) {
        record = TweakDBInterface.GetScannableDataRecord(vulnerabilities[i]);
        if IsDefined(record) {
          vulnerability.vulnerabilityName = record.LocalizedDescription();
          vulnerability.icon = record.IconName();
          vulnerability.isActive = this.CanPlayerUseQuickHackVulnerability(vulnerabilities[i]);
          vulnerabilitiesChunk.PushBack(vulnerability);
        };
        i += 1;
      };
      if vulnerabilitiesChunk.IsValid() {
        scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerVulnerabilities, ToVariant(vulnerabilitiesChunk));
      };
    };
    connectionsChunk = new ScannerConnections();
    connectionsChunk.Set(devicePS.GetUniqueConnectionTypes());
    if connectionsChunk.IsValid() {
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerConnections, ToVariant(connectionsChunk));
    };
    skillchecks = devicePS.CreateSkillcheckInfo(devicePS.GenerateContext(gamedeviceRequestType.Direct, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID()));
    if ArraySize(skillchecks) > 0 && this.IsActive() {
      skillchecksChunk = new ScannerSkillchecks();
      skillchecksChunk.Set(skillchecks);
      skillchecksChunk.SetAuthorization(devicePS.IsDeviceSecured());
      skillchecksChunk.SetPlayerAuthorization(devicePS.IsUserAuthorized(GetPlayerObject(this.GetGame()).GetEntityID()));
      scannerBlackboard.SetVariant(GetAllBlackboardDefs().UI_ScannerModules.ScannerSkillChecks, ToVariant(skillchecksChunk));
    };
    return true;
  }

  protected const func GetScannerName() -> String {
    if IsStringValid(this.GetDisplayName()) {
      return this.GetDisplayName();
    };
    return this.GetDeviceName();
  }

  public const func GetScannerAttitudeTweak() -> TweakDBID {
    let recordID: TweakDBID;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let attitude: EAIAttitude = this.GetAttitudeTowards(playerPuppet);
    switch attitude {
      case EAIAttitude.AIA_Friendly:
        recordID = t"scanning_devices.attitude_friendly";
        break;
      case EAIAttitude.AIA_Neutral:
        recordID = t"scanning_devices.attitude_neutral";
        break;
      case EAIAttitude.AIA_Hostile:
        recordID = t"scanning_devices.attitude_hostile";
    };
    return recordID;
  }

  protected final func SetScanningProgressBarText() -> Void {
    let UI_Blackboard: ref<IBlackboard>;
    let text: String;
    let tweak: TweakDBID = this.m_scanningComponent.GetScanningBarTextTweak();
    TDBID.Append(tweak, t".localizedName");
    text = TweakDBInterface.GetString(tweak, "");
    UI_Blackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    UI_Blackboard.SetString(GetAllBlackboardDefs().UI_Scanner.ProgressBarText, text);
  }

  public const func ShouldShowDamageNumber() -> Bool {
    return false;
  }

  protected func ReactToHit(hit: ref<gameHitEvent>) -> Void;

  protected func GetHitSourcePosition(hitSourceEntityID: EntityID) -> Vector4 {
    return this.GetWorldPosition();
  }

  public func ControlledDeviceInputAction(isPressed: Bool) -> Void;

  protected final func PlayEffect(effectEventName: CName, effectEventTag: CName) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = effectEventName;
    spawnEffectEvent.effectInstanceName = effectEventTag;
    this.QueueEvent(spawnEffectEvent);
  }

  protected final func SetMeshAppearance(appearance: CName) -> Void {
    let evt: ref<entAppearanceEvent> = new entAppearanceEvent();
    evt.appearanceName = appearance;
    this.QueueEvent(evt);
  }

  protected final const func GetPlayerMainObject() -> ref<GameObject> {
    return Device.GetPlayerMainObjectStatic(this.GetGame());
  }

  public final static func GetPlayerMainObjectStatic(context: GameInstance) -> ref<GameObject> {
    return GameInstance.GetPlayerSystem(context).GetLocalPlayerMainGameObject();
  }

  protected final const func ExtractEntityID(evt: ref<TriggerEvent>) -> EntityID {
    let entityID: EntityID = EntityGameInterface.GetEntity(evt.activator).GetEntityID();
    return entityID;
  }

  protected final const func IsPlayer(entityID: EntityID) -> Bool {
    let isPlayer: Bool = this.GetPlayerMainObject().GetEntityID() == entityID;
    return isPlayer;
  }

  protected func ActivateDevice() -> Void {
    this.ForceReEvaluateGameplayRole();
  }

  protected func DeactivateDevice() -> Void {
    this.CutPower();
    this.RevealNetworkGrid(false);
    this.RevealDevicesGrid(false);
    this.SetGameplayRoleToNone();
    GameObject.UntagObject(this);
  }

  protected func RestorePower() -> Void {
    if this.IsCurrentlyScanned() {
      this.RevealNetworkGrid(true);
      this.RevealDevicesGrid(true);
    };
    this.RestoreDeviceState();
  }

  protected func CutPower() -> Void {
    this.TurnOffDevice();
    if !this.GetDevicePS().CanRevealDevicesGridWhenUnpowered() {
      this.RevealNetworkGrid(false);
      this.RevealDevicesGrid(false);
    };
  }

  protected func TurnAuthorizationModuleON() -> Void;

  protected func TurnAuthorizationModuleOFF() -> Void;

  protected func ArmJuryrigTrap() -> Void;

  protected func DeactivateJuryrigTrap() -> Void;

  protected func TurnOnDevice() -> Void;

  protected func TurnOffDevice() -> Void;

  protected func BreakDevice() -> Void;

  protected func SetStateSafe() -> Void;

  protected func SetStateAlarmed() -> Void;

  protected func SetStateArmed() -> Void;

  public final const func GetActionsDebug(context: GetActionsContext, debugger: ref<DeviceDebuggerComponent>, out outActions: array<ref<DeviceAction>>) -> Bool {
    if !IsDefined(debugger) {
      return false;
    };
    this.GetDevicePS().GetActions(outActions, context);
    return true;
  }

  public final const func ShouldInitiateDebug() -> Bool {
    return this.GetDevicePS().ShouldDebug();
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    super.OnHUDInstruction(evt);
    if Equals(evt.highlightInstructions.GetState(), InstanceState.ON) {
      this.GetDevicePS().SetFocusModeData(true);
      this.ResolveDeviceOperationOnFocusMode(gameVisionModeType.Focus, true);
    } else {
      if evt.highlightInstructions.WasProcessed() {
        this.GetDevicePS().SetFocusModeData(false);
        this.ToggleAreaIndicator(false);
        this.ResolveDeviceOperationOnFocusMode(gameVisionModeType.Default, false);
        this.NotifyConnectionHighlightSystem(false, false);
      };
    };
    if evt.quickhackInstruction.ShouldProcess() {
      this.TryOpenQuickhackMenu(evt.quickhackInstruction.ShouldOpen());
    };
  }

  protected cb func OnScanningActionFinishedEvent(evt: ref<ScanningActionFinishedEvent>) -> Bool {
    if this.ShouldRevealDevicesGrid() {
      this.RevealDevicesGrid(true);
    };
    this.GetDevicePS().SetIsScanComplete(true);
    this.ToggleAreaIndicator(true);
  }

  public const func CanRevealRemoteActionsWheel() -> Bool {
    if this.ShouldRegisterToHUD() && !this.GetDevicePS().IsDisabled() {
      if this.GetNetworkSystem().QuickHacksExposedByDefault() {
        if !this.GetDevicePS().HasPlaystyle(EPlaystyle.NETRUNNER) {
          return false;
        };
      } else {
        if !this.GetDevicePS().HasPlaystyle(EPlaystyle.NETRUNNER) || !this.IsConnectedToBackdoorDevice() {
          return false;
        };
      };
      return true;
    };
    return false;
  }

  protected cb func OnQuickHackPanelStateChanged(evt: ref<QuickHackPanelStateEvent>) -> Bool {
    this.DetermineInteractionState();
  }

  public const func HasDirectActionsActive() -> Bool {
    if this.GetDevicePS().HasActiveContext(gamedeviceRequestType.Direct) && (this.GetDevicePS().IsSkillCheckActive() || this.GetDevicePS().HasUICameraZoom()) {
      return true;
    };
    return false;
  }

  private final const func GetBlackboardIntVariable(id: BlackboardID_Int) -> Int32 {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(GetPlayer(this.GetGame()).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetInt(id);
  }

  protected func SendQuickhackCommands(shouldOpen: Bool) -> Void {
    let actions: array<ref<DeviceAction>>;
    let commands: array<ref<QuickhackData>>;
    let context: GetActionsContext;
    let quickSlotsManagerNotification: ref<RevealInteractionWheel> = new RevealInteractionWheel();
    quickSlotsManagerNotification.lookAtObject = this;
    quickSlotsManagerNotification.shouldReveal = shouldOpen;
    if shouldOpen {
      context = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
      this.GetDevicePS().GetRemoteActions(actions, context);
      if this.m_isQhackUploadInProgerss {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7020");
      };
      this.TranslateActionsIntoQuickSlotCommands(actions, commands);
      quickSlotsManagerNotification.commands = commands;
    };
    HUDManager.SetQHDescriptionVisibility(this.GetGame(), shouldOpen);
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(quickSlotsManagerNotification);
  }

  private final func TranslateActionsIntoQuickSlotCommands(actions: array<ref<DeviceAction>>, out commands: array<ref<QuickhackData>>) -> Void {
    let actionCompletionEffects: array<wref<ObjectActionEffect_Record>>;
    let actionMatchDeck: Bool;
    let actionRecord: wref<ObjectAction_Record>;
    let actionStartEffects: array<wref<ObjectActionEffect_Record>>;
    let choice: InteractionChoice;
    let emptyChoice: InteractionChoice;
    let i: Int32;
    let i1: Int32;
    let newCommand: ref<QuickhackData>;
    let sAction: ref<ScriptableDeviceAction>;
    let statModifiers: array<wref<StatModifier_Record>>;
    let playerRef: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    let iceLVL: Float = this.GetICELevel();
    let actionOwnerName: CName = StringToName(this.GetDisplayName());
    let playerQHacksList: array<PlayerQuickhackData> = RPGManager.GetPlayerQuickHackListWithQuality(playerRef);
    if ArraySize(playerQHacksList) == 0 {
      newCommand = new QuickhackData();
      newCommand.m_title = "LocKey#42171";
      newCommand.m_isLocked = true;
      newCommand.m_actionState = EActionInactivityReson.Invalid;
      newCommand.m_actionOwnerName = StringToName(this.GetDisplayName());
      newCommand.m_description = "LocKey#42172";
      ArrayPush(commands, newCommand);
    } else {
      i = 0;
      while i < ArraySize(playerQHacksList) {
        newCommand = new QuickhackData();
        sAction = null;
        ArrayClear(actionStartEffects);
        actionRecord = playerQHacksList[i].actionRecord;
        if NotEquals(actionRecord.ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) {
        } else {
          actionMatchDeck = false;
          i1 = 0;
          while i1 < ArraySize(actions) {
            sAction = actions[i1] as ScriptableDeviceAction;
            if Equals(actionRecord.ActionName(), sAction.GetObjectActionRecord().ActionName()) {
              actionMatchDeck = true;
              if actionRecord.Priority() >= sAction.GetObjectActionRecord().Priority() {
                sAction.SetObjectActionID(playerQHacksList[i].actionRecord.GetID());
              } else {
                actionRecord = sAction.GetObjectActionRecord();
              };
              newCommand.m_uploadTime = sAction.GetActivationTime();
              newCommand.m_duration = this.GetDevicePS().GetDistractionDuration(sAction);
            } else {
              i1 += 1;
            };
          };
          newCommand.m_actionOwnerName = actionOwnerName;
          newCommand.m_title = LocKeyToString(actionRecord.ObjectActionUI().Caption());
          newCommand.m_description = LocKeyToString(actionRecord.ObjectActionUI().Description());
          newCommand.m_icon = actionRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID();
          newCommand.m_iconCategory = actionRecord.GameplayCategory().IconName();
          newCommand.m_type = actionRecord.ObjectActionType().Type();
          newCommand.m_actionOwner = this.GetEntityID();
          newCommand.m_isInstant = false;
          newCommand.m_ICELevel = iceLVL;
          newCommand.m_ICELevelVisible = false;
          newCommand.m_vulnerabilities = this.GetDevicePS().GetActiveQuickHackVulnerabilities();
          newCommand.m_actionState = EActionInactivityReson.Locked;
          newCommand.m_quality = playerQHacksList[i].quality;
          newCommand.m_costRaw = BaseScriptableAction.GetBaseCostStatic(playerRef, actionRecord);
          newCommand.m_category = actionRecord.HackCategory();
          ArrayClear(actionCompletionEffects);
          actionRecord.CompletionEffects(actionCompletionEffects);
          newCommand.m_actionCompletionEffects = actionCompletionEffects;
          actionRecord.StartEffects(actionStartEffects);
          i1 = 0;
          while i1 < ArraySize(actionStartEffects) {
            if Equals(actionStartEffects[i1].StatusEffect().StatusEffectType().Type(), gamedataStatusEffectType.PlayerCooldown) {
              actionStartEffects[i1].StatusEffect().Duration().StatModifiers(statModifiers);
              newCommand.m_cooldown = RPGManager.CalculateStatModifiers(statModifiers, this.GetGame(), playerRef, Cast(playerRef.GetEntityID()), Cast(playerRef.GetEntityID()));
              newCommand.m_cooldownTweak = actionStartEffects[i1].StatusEffect().GetID();
              ArrayClear(statModifiers);
            };
            if newCommand.m_cooldown != 0.00 {
            } else {
              i1 += 1;
            };
          };
          if actionMatchDeck {
            if !IsDefined(this as GenericDevice) {
              choice = emptyChoice;
              choice = sAction.GetInteractionChoice();
              if TDBID.IsValid(choice.choiceMetaData.tweakDBID) {
                newCommand.m_titleAlternative = LocKeyToString(TweakDBInterface.GetInteractionBaseRecord(choice.choiceMetaData.tweakDBID).Caption());
              };
            };
            newCommand.m_cost = sAction.GetCost();
            if sAction.IsInactive() {
              newCommand.m_isLocked = true;
              newCommand.m_inactiveReason = sAction.GetInactiveReason();
              if this.HasActiveQuickHackUpload() {
                newCommand.m_action = sAction;
              };
            } else {
              if !sAction.CanPayCost() {
                newCommand.m_actionState = EActionInactivityReson.OutOfMemory;
                newCommand.m_isLocked = true;
                newCommand.m_inactiveReason = "LocKey#27398";
              };
              if GameInstance.GetStatPoolsSystem(this.GetGame()).HasActiveStatPool(Cast(this.GetEntityID()), gamedataStatPoolType.QuickHackUpload) {
                newCommand.m_isLocked = true;
                newCommand.m_inactiveReason = "LocKey#27398";
              };
              if !sAction.IsInactive() || this.HasActiveQuickHackUpload() {
                newCommand.m_action = sAction;
              };
            };
          } else {
            newCommand.m_isLocked = true;
            newCommand.m_inactiveReason = "LocKey#10943";
          };
          newCommand.m_actionMatchesTarget = actionMatchDeck;
          if !newCommand.m_isLocked {
            newCommand.m_actionState = EActionInactivityReson.Ready;
          };
          ArrayPush(commands, newCommand);
        };
        i += 1;
      };
    };
    i = 0;
    while i < ArraySize(commands) {
      if commands[i].m_isLocked && IsDefined(commands[i].m_action) {
        (commands[i].m_action as ScriptableDeviceAction).SetInactiveWithReason(false, commands[i].m_inactiveReason);
      };
      i += 1;
    };
    QuickhackModule.SortCommandPriority(commands, this.GetGame());
  }

  private final const func GetICELevel() -> Float {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let playerLevel: Float = statsSystem.GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.Level);
    let targetLevel: Float = statsSystem.GetStatValue(Cast(this.GetEntityID()), gamedataStatType.PowerLevel);
    let resistance: Float = statsSystem.GetStatValue(Cast(this.GetEntityID()), gamedataStatType.HackingResistance);
    return resistance + 0.50 * (targetLevel - playerLevel);
  }

  private final const func GetPlayerCyberDeck() -> array<String> {
    let abilityName: String;
    let currentCard: SPartSlots;
    let deckInfo: array<String>;
    let i1: Int32;
    let i2: Int32;
    let onEquipStats: array<wref<GameplayLogicPackage_Record>>;
    let statModifiOnEquip: array<wref<StatModifier_Record>>;
    let statType: wref<Stat_Record>;
    let player: ref<GameObject> = this.GetPlayerMainObject();
    let cyberDeckID: ItemID = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    let deckCards: array<SPartSlots> = ItemModificationSystem.GetAllSlots(player, cyberDeckID);
    let i: Int32 = 0;
    while i < ArraySize(deckCards) {
      ArrayClear(onEquipStats);
      abilityName = "";
      currentCard = deckCards[i];
      if Equals(currentCard.status, ESlotState.Taken) {
        InnerItemData.GetStaticData(currentCard.innerItemData).OnEquip(onEquipStats);
        i1 = 0;
        while i1 < ArraySize(onEquipStats) {
          ArrayClear(statModifiOnEquip);
          onEquipStats[i1].Stats(statModifiOnEquip);
          i2 = 0;
          while i2 < ArraySize(statModifiOnEquip) {
            statType = statModifiOnEquip[i2].StatType();
            abilityName = statType.EnumName();
            ArrayPush(deckInfo, abilityName);
            i2 += 1;
          };
          i1 += 1;
        };
      } else {
        ArrayPush(deckInfo, abilityName);
      };
      i += 1;
    };
    return deckInfo;
  }

  private final func GetMatchingActionProgramName(actions: array<ref<DeviceAction>>, searchWord: String) -> Int32 {
    let actionRecord: wref<ObjectAction_Record>;
    let flagInfo: array<Int32>;
    let i1: Int32;
    let instigatorPrereqs: array<wref<IPrereq_Record>>;
    let statName: CName;
    let returnIndex: Int32 = -1;
    let searchedWordAsName: CName = StringToName(searchWord);
    let i: Int32 = 0;
    while i < ArraySize(actions) {
      ArrayClear(instigatorPrereqs);
      actionRecord = (actions[i] as BaseScriptableAction).GetObjectActionRecord();
      actionRecord.InstigatorPrereqs(instigatorPrereqs);
      i1 = 0;
      while i1 < ArraySize(instigatorPrereqs) {
        statName = TweakDBInterface.GetCName(instigatorPrereqs[i1].GetID() + t".statType", n"");
        if NotEquals(statName, n"HasCyberdeck") {
          if Equals(searchedWordAsName, statName) {
            ArrayPush(flagInfo, i);
          };
        };
        i1 += 1;
      };
      i += 1;
    };
    if ArraySize(flagInfo) > 0 {
      returnIndex = flagInfo[0];
    };
    return returnIndex;
  }

  protected cb func OnUploadProgressStateChanged(evt: ref<UploadProgramProgressEvent>) -> Bool {
    if Equals(evt.progressBarContext, EProgressBarContext.QuickHack) {
      if Equals(evt.progressBarType, EProgressBarType.UPLOAD) {
        if Equals(evt.state, EUploadProgramState.STARTED) {
          this.m_isQhackUploadInProgerss = true;
        } else {
          if Equals(evt.state, EUploadProgramState.COMPLETED) {
            this.m_isQhackUploadInProgerss = false;
          };
        };
      };
    };
  }

  private final func ShowQuickHackDuration(action: ref<ScriptableDeviceAction>) -> Void {
    let actionDurationListener: ref<QuickHackDurationListener>;
    let statMod: ref<gameStatModifierData>;
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    GameInstance.GetStatsSystem(this.GetGame()).RemoveAllModifiers(Cast(this.GetEntityID()), gamedataStatType.QuickHackDuration, true);
    statMod = RPGManager.CreateStatModifier(gamedataStatType.QuickHackDuration, gameStatModifierType.Additive, 1.00);
    GameInstance.GetStatsSystem(this.GetGame()).RemoveAllModifiers(Cast(this.GetEntityID()), gamedataStatType.QuickHackDuration);
    GameInstance.GetStatsSystem(this.GetGame()).AddModifier(Cast(this.GetEntityID()), statMod);
    actionDurationListener = new QuickHackDurationListener();
    actionDurationListener.m_action = action;
    actionDurationListener.m_gameInstance = this.GetGame();
    statPoolSys.RequestRegisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.QuickHackDuration, actionDurationListener);
    statPoolSys.RequestAddingStatPool(Cast(this.GetEntityID()), t"BaseStatPools.QuickHackDuration", true);
  }

  public const func CanPlayerUseQuickHackVulnerability(data: TweakDBID) -> Bool {
    return this.GetDevicePS().CanPlayerUseQuickHackVulnerability(data);
  }

  private final func ResolveRemoteActions(state: Bool) -> Void {
    let context: GetActionsContext = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
    if state {
      this.GetDevicePS().AddActiveContext(gamedeviceRequestType.Remote);
      this.NotifyConnectionHighlightSystem(true, false);
    } else {
      if !this.IsCurrentTarget() && !this.IsCurrentlyScanned() {
        this.GetDevicePS().RemoveActiveContext(gamedeviceRequestType.Remote);
      } else {
        return;
      };
    };
    this.DetermineInteractionState(context);
  }

  protected final func RefreshInteraction() -> Void {
    let context: GetActionsContext = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
    if this.IsCurrentTarget() || this.IsCurrentlyScanned() {
      this.DetermineInteractionState(context);
    };
  }

  protected cb func OnScanningLookedAt(evt: ref<ScanningLookAtEvent>) -> Bool {
    super.OnScanningLookedAt(evt);
    this.ResolveDeviceOperationOnFocusMode(gameVisionModeType.Focus, evt.state);
    if !evt.state && this.m_scanningComponent.IsScanned() {
      this.SendDisableAreaIndicatorEvent();
      this.SendSkillCheckInfo(false);
    };
    if this.GetNetworkSystem().SuppressPingIfBackdoorsFound() {
      if evt.state && this.IsNetworkKnownToPlayer() {
        if this.IsConnectedToBackdoorDevice() && !this.GetDevicePS().IsQuickHacksExposed() {
          this.RevealNetworkGrid(true);
        };
      } else {
        if evt.state && this.ShouldPulseNetwork() {
          this.PulseNetwork(true);
        };
      };
    };
    if this.IsScanned() {
      if evt.state {
        if this.ShouldRevealDevicesGrid() {
          this.RevealDevicesGrid(true);
        };
        this.SendSkillCheckInfo(true);
        this.ToggleAreaIndicator(evt.state);
      };
    };
  }

  private final func ShouldPulseNetwork() -> Bool {
    return !this.GetNetworkSystem().ShouldShowLinksOnMaster() && !this.IsBackdoor() && this.IsConnectedToBackdoorDevice() && !this.IsNetworkKnownToPlayer() && NotEquals(this.GetCurrentGameplayRole(), IntEnum(1l));
  }

  public const func CanOverrideNetworkContext() -> Bool {
    return NotEquals(this.GetCurrentGameplayRole(), IntEnum(1l)) && this.GetDevicePS().HasAnyDeviceConnection() && (this.ShouldRevealDevicesGrid() || this.IsConnectedToBackdoorDevice());
  }

  public const func IsNetworkKnownToPlayer() -> Bool {
    if this.GetDevicePS().WasRevealedInNetworkPing() {
      return true;
    };
    if this.GetDevicePS().HasNetworkBackdoor() {
      return this.GetDevicePS().IsBreached();
    };
    if this.IsConnectedToBackdoorDevice() {
      if this.GetDevicePS().IsQuickHacksExposed() || this.GetDevicePS().CheckIfMyBackdoorsWereRevealedInNetworkPing() {
        return true;
      };
    };
    return false;
  }

  protected cb func OnPulseEvent(evt: ref<gameVisionModeUpdateVisuals>) -> Bool {
    if evt.pulse {
      if !this.GetDevicePS().WasRevealedInNetworkPing() {
        this.PulseNetwork(false);
      };
    };
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    let outline: EFocusOutlineType;
    if this.GetDevicePS().IsDisabled() {
      return null;
    };
    if Equals(this.GetCurrentGameplayRole(), IntEnum(1l)) || Equals(this.GetCurrentGameplayRole(), EGameplayRole.Clue) || this.IsAnyClueEnabled() {
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
      if Equals(outline, EFocusOutlineType.BACKDOOR) {
        highlight.highlightType = EFocusForcedHighlightType.BACKDOOR;
      } else {
        if Equals(outline, EFocusOutlineType.WEAKSPOT) {
          highlight.highlightType = EFocusForcedHighlightType.WEAKSPOT;
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
                highlight = null;
              };
            };
          };
        };
      };
    };
    if highlight != null {
      if this.IsNetrunner() {
        highlight.patternType = VisionModePatternType.Netrunner;
      } else {
        highlight.patternType = VisionModePatternType.Default;
      };
    };
    return highlight;
  }

  public const func GetCurrentOutline() -> EFocusOutlineType {
    let outlineType: EFocusOutlineType;
    if this.IsQuest() {
      outlineType = EFocusOutlineType.QUEST;
    } else {
      if !this.IsPotentiallyQuickHackable() && this.IsActiveBackdoor() {
        outlineType = EFocusOutlineType.BACKDOOR;
      } else {
        if this.IsNetrunner() {
          outlineType = EFocusOutlineType.HACKABLE;
        } else {
          if this.HasAnySkillCheckActive() || this.IsTaggedinFocusMode() || this.HasAnyPlaystyle() {
            outlineType = EFocusOutlineType.IMPORTANT_INTERACTION;
          } else {
            if this.HasAnyDirectInteractionActive() || this.IsObjectRevealed() {
              outlineType = EFocusOutlineType.INTERACTION;
            } else {
              outlineType = EFocusOutlineType.INVALID;
            };
          };
        };
      };
    };
    return outlineType;
  }

  private final func GetDeviceConnectionsHighlightSystem() -> ref<DeviceConnectionsHighlightSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DeviceConnectionsHighlightSystem") as DeviceConnectionsHighlightSystem;
  }

  protected cb func OnNotifyHighlightedDevice(evt: ref<NotifyHighlightedDevice>) -> Bool {
    this.NotifyConnectionHighlightSystem(evt.IsDeviceHighlighted, evt.IsNotifiedByMasterDevice);
  }

  protected func NotifyConnectionHighlightSystem(IsHighlightON: Bool, IsNotifiedByMasterDevice: Bool) -> Bool {
    let hightlightSystemRequest: ref<HighlightConnectionsRequest>;
    let highlightTargets: array<NodeRef> = this.GetDevicePS().GetConnectionHighlightObjects();
    if ArraySize(highlightTargets) <= 0 {
      return false;
    };
    hightlightSystemRequest = new HighlightConnectionsRequest();
    hightlightSystemRequest.shouldHighlight = IsHighlightON;
    hightlightSystemRequest.isTriggeredByMasterDevice = IsNotifiedByMasterDevice;
    hightlightSystemRequest.highlightTargets = highlightTargets;
    hightlightSystemRequest.requestingDevice = this.GetEntityID();
    this.GetDeviceConnectionsHighlightSystem().QueueRequest(hightlightSystemRequest);
    return true;
  }

  protected final func SendSkillCheckInfo(display: Bool) -> Void {
    let info: array<UIInteractionSkillCheck>;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    let context: GetActionsContext = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
    if display {
      info = this.GetDevicePS().CreateSkillcheckInfo(context);
    };
    if IsDefined(bb) {
      bb.SetVariant(GetAllBlackboardDefs().UI_Scanner.skillCheckInfo, ToVariant(info), true);
    };
  }

  protected func SendDisableAreaIndicatorEvent() -> Void;

  protected cb func OnDisableAreaIndicator(evt: ref<DisableAreaIndicatorEvent>) -> Bool {
    this.ToggleAreaIndicator(false);
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: wref<GameObject> = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if this.GetDevicePS().GetDeviceOperationsContainer() != null {
      this.GetDevicePS().GetDeviceOperationsContainer().EvaluateTriggerVolumeTriggers(evt.componentName, this, activator, ETriggerOperationType.ENTER);
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    let activator: wref<GameObject> = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if this.GetDevicePS().GetDeviceOperationsContainer() != null {
      this.GetDevicePS().GetDeviceOperationsContainer().EvaluateTriggerVolumeTriggers(evt.componentName, this, activator, ETriggerOperationType.EXIT);
    };
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    let potentialHitSourcePos: Vector4;
    let source: wref<GameObject>;
    this.SetScannerDirty(true);
    source = hit.attackData.GetInstigator();
    if this.GetDevicePS().GetDeviceOperationsContainer() != null {
      this.GetDevicePS().GetDeviceOperationsContainer().EvaluateHitTriggers(this, source, hit.attackData);
    };
    if this.IsConnectedToSecuritySystem() {
      potentialHitSourcePos = this.GetHitSourcePosition(source.GetEntityID());
      if Equals(potentialHitSourcePos, this.GetWorldPosition()) {
        this.GetDevicePS().TriggerSecuritySystemNotification(this, this.GetWorldPosition(), ESecurityNotificationType.DEVICE_DESTROYED);
      } else {
        this.GetDevicePS().TriggerSecuritySystemNotification(source, potentialHitSourcePos, ESecurityNotificationType.COMBAT);
      };
    };
  }

  protected cb func OnProjectileBreachEvent(evt: ref<ProjectileBreachEvent>) -> Bool {
    this.ProjectileExposeQuickHacks();
  }

  private final func ProjectileExposeQuickHacks() -> Void {
    this.GetDevicePS().SetIsScanComplete(true);
  }

  protected cb func OnDelayedDeviceOperation(evt: ref<DelayedOperationEvent>) -> Bool {
    evt.operation.delay = 0.00;
    evt.operationHandler.Execute(evt.operation, this);
  }

  protected cb func OndDeviceOperationTriggerDelayed(evt: ref<DelayedDeviceOperationTriggerEvent>) -> Bool {
    evt.namedOperation.isDelayActive = false;
    this.GetDevicePS().GetDeviceOperationsContainer().Execute(evt.namedOperation.operationName, this);
  }

  protected cb func OnPlayerDetectedVisibleEvent(evt: ref<OnDetectedEvent>) -> Bool {
    let operationType: ETriggerOperationType;
    if evt.isVisible {
      operationType = ETriggerOperationType.ENTER;
    } else {
      operationType = ETriggerOperationType.EXIT;
    };
    if this.GetDevicePS().GetDeviceOperationsContainer() != null {
      this.GetDevicePS().GetDeviceOperationsContainer().EvaluateSenseTriggers(this, evt.target, operationType);
    };
  }

  private final func ResolveDeviceOperationOnFocusMode(visionType: gameVisionModeType, activated: Bool) -> Void {
    let operationType: ETriggerOperationType;
    if Equals(visionType, gameVisionModeType.Focus) {
      if activated {
        operationType = ETriggerOperationType.ENTER;
      } else {
        operationType = ETriggerOperationType.EXIT;
      };
      if this.GetDevicePS().GetDeviceOperationsContainer() != null {
        this.GetDevicePS().GetDeviceOperationsContainer().EvaluateFocusModeTriggers(this, operationType);
      };
    };
  }

  protected final func RegisterPlayerTargetCallback() -> Void {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_TargetingInfo);
    if !IsDefined(this.m_currentPlayerTargetCallbackID) {
      this.m_currentPlayerTargetCallbackID = blackBoard.RegisterListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this, n"OnPlayerTargetChanged");
    };
  }

  protected final func UnRegisterPlayerTargetCallback() -> Void {
    let blackBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_TargetingInfo);
    if IsDefined(this.m_currentPlayerTargetCallbackID) {
      blackBoard.UnregisterListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this.m_currentPlayerTargetCallbackID);
    };
  }

  public const func GetCurrentHealth() -> Float {
    let value: Float = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health, true);
    return value;
  }

  public const func GetTotalHealth() -> Float {
    let value: Float = GameInstance.GetStatPoolsSystem(this.GetGame()).GetStatPoolMaxPointValue(Cast(this.GetEntityID()), gamedataStatPoolType.Health);
    return value;
  }

  protected func ProcessDamagePipeline(evt: ref<gameHitEvent>) -> Void {
    if Equals(this.GetDevicePS().GetDurabilityType(), EDeviceDurabilityType.DESTRUCTIBLE) && NotEquals(this.GetDevicePS().GetDeviceState(), EDeviceStatus.DISABLED) {
      this.ProcessDamagePipeline(evt);
    };
  }

  protected func ApplyDamage(attackData: ref<AttackData>) -> Void;

  public const func IsHighlightedInFocusMode() -> Bool {
    return this.GetDevicePS().IsHighlightedInFocusMode();
  }

  protected final func TriggerAreaEffectDistractionByName(effectName: CName) -> Void {
    let effectData: ref<AreaEffectData>;
    let quickHackIndex: Int32 = this.GetFxResourceMapper().GetAreaEffectDataIndexByName(effectName);
    if quickHackIndex >= 0 {
      effectData = this.GetFxResourceMapper().GetAreaEffectDataByIndex(quickHackIndex);
      this.TriggerArreaEffectDistraction(effectData);
    };
  }

  protected final func TriggerAreaEffectDistractionByAction(action: ref<ScriptableDeviceAction>) -> Void {
    let effectData: ref<AreaEffectData>;
    let quickHackIndex: Int32;
    if IsDefined(this.GetFxResourceMapper()) {
      quickHackIndex = this.GetFxResourceMapper().GetAreaEffectDataIndexByAction(action);
      if quickHackIndex >= 0 {
        effectData = this.GetFxResourceMapper().GetAreaEffectDataByIndex(quickHackIndex);
        effectData.stimLifetime = action.GetDurationValue();
        this.TriggerArreaEffectDistraction(effectData);
      };
    };
  }

  public final const func GetAreaEffectLifetimeByName(effectName: CName) -> Float {
    let effectData: ref<AreaEffectData>;
    let lifetime: Float;
    let quickHackIndex: Int32;
    if IsDefined(this.GetFxResourceMapper()) {
      quickHackIndex = this.GetFxResourceMapper().GetAreaEffectDataIndexByName(effectName);
      if quickHackIndex >= 0 {
        effectData = this.GetFxResourceMapper().GetAreaEffectDataByIndex(quickHackIndex);
        lifetime = effectData.stimLifetime;
      };
    };
    return lifetime;
  }

  public final const func GetAreaEffectLifetimeByAction(action: ref<ScriptableDeviceAction>) -> Float {
    let effectData: ref<AreaEffectData>;
    let lifetime: Float;
    let quickHackIndex: Int32;
    if IsDefined(this.GetFxResourceMapper()) {
      quickHackIndex = this.GetFxResourceMapper().GetAreaEffectDataIndexByAction(action);
      if quickHackIndex >= 0 {
        effectData = this.GetFxResourceMapper().GetAreaEffectDataByIndex(quickHackIndex);
        lifetime = effectData.stimLifetime;
      };
    };
    return lifetime;
  }

  public final static func MapStimType(stim: DeviceStimType) -> gamedataStimType {
    let stimType: gamedataStimType;
    switch stim {
      case DeviceStimType.Distract:
        stimType = gamedataStimType.Distract;
        break;
      case DeviceStimType.Explosion:
        stimType = gamedataStimType.DeviceExplosion;
        break;
      case DeviceStimType.VisualDistract:
        stimType = gamedataStimType.VisualDistract;
        break;
      case DeviceStimType.VentilationAreaEffect:
        stimType = gamedataStimType.AreaEffect;
        break;
      default:
        stimType = gamedataStimType.Invalid;
    };
    return stimType;
  }

  protected final func GetDefaultDistractionAreaEffectData() -> ref<AreaEffectData> {
    let effectData: ref<AreaEffectData> = new AreaEffectData();
    effectData.stimType = DeviceStimType.Distract;
    effectData.stimRange = this.GetSmallestDistractionRange(DeviceStimType.Distract);
    effectData.stimLifetime = 1.00;
    return effectData;
  }

  protected final func TriggerArreaEffectDistraction(effectData: ref<AreaEffectData>, opt executor: ref<GameObject>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let districtStimMultiplier: Float;
    let i: Int32;
    let investigateData: stimInvestigateData;
    let stimType: gamedataStimType = Device.MapStimType(effectData.stimType);
    let stimLifetime: Float = this.GetDistractionStimLifetime(effectData.stimLifetime);
    let target: ref<GameObject> = this.GetEntityFromNode(effectData.stimSource) as GameObject;
    if target == null {
      target = this.GetStimTarget();
    } else {
      investigateData.mainDeviceEntity = this.GetStimTarget();
    };
    if effectData.investigateController {
      investigateData.controllerEntity = this.GetDistractionControllerSource(effectData);
      if IsDefined(investigateData.controllerEntity) {
        investigateData.investigateController = true;
      };
    };
    investigateData.distrationPoint = this.GetDistractionPointPosition(target);
    investigateData.investigationSpots = this.GetNodePosition(effectData.investigateSpot);
    if IsDefined(executor) {
      investigateData.attackInstigator = executor;
    } else {
      if IsDefined(effectData.action.GetExecutor()) {
        investigateData.attackInstigator = effectData.action.GetExecutor();
      };
    };
    broadcaster = target.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      if Equals(stimType, gamedataStimType.DeviceExplosion) {
        districtStimMultiplier = (GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet).GetExplosionRange();
        broadcaster.SetSingleActiveStimuli(this, stimType, stimLifetime, effectData.stimRange * districtStimMultiplier, investigateData);
      } else {
        broadcaster.SetSingleActiveStimuli(this, stimType, stimLifetime, effectData.stimRange, investigateData);
      };
    };
    if ArraySize(effectData.additionaStimSources) > 0 {
      i = 0;
      while i < ArraySize(effectData.additionaStimSources) {
        target = this.GetEntityFromNode(effectData.additionaStimSources[i]) as GameObject;
        if IsDefined(target) {
          broadcaster = target.GetStimBroadcasterComponent();
          if IsDefined(broadcaster) {
            broadcaster.SetSingleActiveStimuli(this, stimType, stimLifetime, effectData.stimRange);
          };
        };
        i += 1;
      };
    };
  }

  public final const func GetNodePosition(opt nodeRef: NodeRef) -> array<Vector4> {
    let globalRef: GlobalNodeRef;
    let i: Int32;
    let navQuerryForward: Vector4;
    let nodeTransform: Transform;
    let pointResults: NavigationFindPointResult;
    let position: Vector4;
    let positionsArray: array<Vector4>;
    let setPositionsEvt: ref<SetInvestigationPositionsArrayEvent>;
    let slotName: CName;
    let slotOffsetMult: Float;
    let slotPosition: Vector4;
    let sourcePos: Vector4;
    let transform: WorldTransform;
    if this.HasInvestigationPositionsArrayCached() {
      return this.GetCachedInvestigationPositionsArray();
    };
    globalRef = ResolveNodeRefWithEntityID(nodeRef, this.GetEntityID());
    if GlobalNodeRef.IsDefined(globalRef) {
      GameInstance.GetNodeTransform(this.GetGame(), globalRef, nodeTransform);
      position = Transform.GetPosition(nodeTransform);
      if !Vector4.IsZero(position) {
        pointResults = GameInstance.GetNavigationSystem(this.GetGame()).FindPointInSphereOnlyHumanNavmesh(position, 0.50, NavGenAgentSize.Human, false);
      } else {
        pointResults.status = worldNavigationRequestStatus.OtherError;
      };
    };
    if Equals(pointResults.status, worldNavigationRequestStatus.OK) {
      position = pointResults.point;
      ArrayPush(positionsArray, position);
    } else {
      if this.GetSlotComponent().GetSlotTransform(n"navQuery", transform) {
        slotName = n"navQuery";
      } else {
        slotName = n"navQuery0";
      };
      slotOffsetMult = this.GetFxResourceMapper().GetInvestigationSlotOffset();
      if slotOffsetMult <= 0.00 {
        slotOffsetMult = 1.00;
      };
      sourcePos = this.GetWorldPosition();
      while this.GetSlotComponent().GetSlotTransform(slotName, transform) {
        slotPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform));
        slotPosition.Z = sourcePos.Z;
        navQuerryForward = slotPosition - sourcePos;
        navQuerryForward = Transform.TransformVector(WorldTransform._ToXForm(WorldTransform.GetInverse(this.GetWorldTransform())), navQuerryForward);
        if AbsF(navQuerryForward.X) > AbsF(navQuerryForward.Y) {
          navQuerryForward.Y = 0.00;
        } else {
          navQuerryForward.X = 0.00;
        };
        navQuerryForward = Vector4.Normalize(navQuerryForward) * slotOffsetMult;
        navQuerryForward = Transform.TransformVector(WorldTransform._ToXForm(this.GetWorldTransform()), navQuerryForward);
        slotPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform)) + navQuerryForward;
        WorldTransform.SetPosition(transform, slotPosition);
        position = GameInstance.GetNavigationSystem(this.GetGame()).GetNearestNavmeshPointBelowOnlyHumanNavmesh(this.CheckQueryStartPoint(transform), 1.00, 5);
        if !Vector4.IsZero(position) {
          ArrayPush(positionsArray, position);
        };
        i += 1;
        slotName = StringToName("navQuery" + i);
      };
    };
    if ArraySize(positionsArray) > 0 {
      setPositionsEvt = new SetInvestigationPositionsArrayEvent();
      setPositionsEvt.investigationPositionsArray = positionsArray;
      GameInstance.GetPersistencySystem(this.GetGame()).QueueEntityEvent(this.GetEntityID(), setPositionsEvt);
    };
    return positionsArray;
  }

  protected cb func OnSetInvestigationPositionsArray(evt: ref<SetInvestigationPositionsArrayEvent>) -> Bool {
    this.SetInvestigationPositionsArray(evt.investigationPositionsArray);
  }

  protected const func GetCachedInvestigationPositionsArray() -> array<Vector4> {
    let arr: array<Vector4>;
    return arr;
  }

  protected func SetInvestigationPositionsArray(arr: array<Vector4>) -> Void;

  protected const func HasInvestigationPositionsArrayCached() -> Bool {
    return false;
  }

  public final func GetDistractionPointPosition(device: wref<GameObject>) -> Vector4 {
    let objectTransform: WorldTransform;
    if this.GetUISlotComponent().GetSlotTransform(n"distractionPoint", objectTransform) {
      return WorldPosition.ToVector4(WorldTransform.GetWorldPosition(objectTransform));
    };
    if this.GetUISlotComponent().GetSlotTransform(n"roleMappin", objectTransform) {
      return WorldPosition.ToVector4(WorldTransform.GetWorldPosition(objectTransform));
    };
    return device.GetWorldPosition();
  }

  public const func CanBeInvestigated() -> Bool {
    let worskpotData: ref<WorkspotEntryData> = this.GetFreeWorkspotDataForAIAction(gamedataWorkspotActionType.DeviceInvestigation);
    return !this.IsInvestigated() || worskpotData != null;
  }

  public final const func IsInvestigated() -> Bool {
    let value: Bool = this.GetBlackboard().GetBool(this.GetBlackboardDef().IsInvestigated);
    return value;
  }

  public final const func GetWillingInvestigators() -> array<EntityID> {
    return this.GetDevicePS().GetWillingInvestigators();
  }

  protected cb func OnUpdateWillingInvestigators(evt: ref<UpdateWillingInvestigators>) -> Bool {
    this.GetDevicePS().AddWillingInvestigator(evt.investigator);
  }

  public const func CheckQueryStartPoint(transform: WorldTransform) -> Vector4 {
    let point: Vector4 = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform));
    if Vector4.IsZero(point) {
      point = this.GetWorldPosition();
    };
    return point;
  }

  public final func GetEntityFromNode(nodeRef: NodeRef) -> ref<Entity> {
    let id: EntityID = Cast(ResolveNodeRefWithEntityID(nodeRef, this.GetEntityID()));
    return GameInstance.FindEntityByID(this.GetGame(), id);
  }

  public func GetStimTarget() -> ref<GameObject> {
    return this;
  }

  public func GetDistractionControllerSource(opt effectData: ref<AreaEffectData>) -> ref<Entity> {
    return this.GetEntityFromNode(effectData.controllerSource);
  }

  public func GetDistractionStimLifetime(defaultValue: Float) -> Float {
    return defaultValue;
  }

  private final const func GetNetworkBlackboardDef() -> ref<NetworkBlackboardDef> {
    return GetAllBlackboardDefs().NetworkBlackboard;
  }

  private final const func GetNetworkBlackboard() -> ref<IBlackboard> {
    return GameInstance.GetBlackboardSystem(this.GetGame()).Get(this.GetNetworkBlackboardDef());
  }

  protected cb func OnToggleNetrunnerDive(evt: ref<ToggleNetrunnerDive>) -> Bool {
    if evt.ShouldTerminate() {
      this.TerminateConnection();
    } else {
      this.GetNetworkBlackboard().SetBool(this.GetNetworkBlackboardDef().RemoteBreach, evt.m_isRemote);
      this.PerformDive(evt.m_attempt, evt.m_isRemote);
    };
  }

  protected func PerformDive(attempt: Int32, isRemote: Bool) -> Void {
    if !isRemote && !this.GetDevicePS().IsPersonalLinkConnected() {
      return;
    };
    this.DisplayConnectionWindowOnPlayerHUD(true, attempt);
  }

  protected func TerminateConnection() -> Void {
    if !this.GetDevicePS().IsPersonalLinkConnected() {
      return;
    };
    this.DisplayConnectionWindowOnPlayerHUD(false, 0);
  }

  private final func DisplayConnectionWindowOnPlayerHUD(shouldDisplay: Bool, attempt: Int32) -> Void {
    let connectionsCount: Int32;
    let invalidID: EntityID;
    let networkName: String;
    if shouldDisplay {
      networkName = this.GetDevicePS().GetNetworkName();
      connectionsCount = this.GetDevicePS().GetNetworkSizeCount();
      this.GetNetworkBlackboard().SetInt(this.GetNetworkBlackboardDef().DevicesCount, connectionsCount);
      this.GetNetworkBlackboard().SetBool(this.GetNetworkBlackboardDef().OfficerBreach, false);
      this.GetNetworkBlackboard().SetString(this.GetNetworkBlackboardDef().NetworkName, networkName, true);
      this.GetNetworkBlackboard().SetVariant(this.GetNetworkBlackboardDef().MinigameDef, ToVariant(this.GetDevicePS().GetMinigameDefinition()));
      this.GetNetworkBlackboard().SetInt(this.GetNetworkBlackboardDef().Attempt, attempt);
      this.GetNetworkBlackboard().SetEntityID(this.GetNetworkBlackboardDef().DeviceID, this.GetEntityID());
    } else {
      this.GetNetworkBlackboard().SetString(this.GetNetworkBlackboardDef().NetworkName, "");
      this.GetNetworkBlackboard().SetEntityID(this.GetNetworkBlackboardDef().DeviceID, invalidID);
    };
  }

  public final const func OnQuestMinigameRequest() -> Void {
    let minigameID: TweakDBID = this.GetDevicePS().GetMinigameDefinition();
    if !TDBID.IsValid(minigameID) {
      minigameID = t"minigame_v2.DefaultItemMinigame";
    };
    this.GetNetworkBlackboard().SetVariant(this.GetNetworkBlackboardDef().MinigameDef, ToVariant(minigameID));
  }

  protected cb func OnAccessPointMiniGameStatus(evt: ref<AccessPointMiniGameStatus>) -> Bool {
    this.GetDevicePS().HackingMinigameEnded(evt.minigameState);
    if Equals(evt.minigameState, HackingMinigameState.Succeeded) {
      this.SucceedGameplayObjective(this.GetDevicePS().GetBackdoorObjectiveData());
      this.EvaluateProximityMappinInteractionLayerState();
      this.EvaluateProximityRevealInteractionLayerState();
    } else {
      if Equals(evt.minigameState, HackingMinigameState.Failed) {
        this.GetDevicePS().TriggerSecuritySystemNotification(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), this.GetWorldPosition(), ESecurityNotificationType.ALARM);
      };
    };
    QuickhackModule.RequestRefreshQuickhackMenu(this.GetGame(), this.GetEntityID());
  }

  protected cb func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> Bool {
    let request: ref<UnregisterNetworkLinksByIdAndTypeRequest>;
    this.SetScannerDirty(true);
    this.SucceedGameplayObjective(this.GetDevicePS().GetBackdoorObjectiveData());
    request = new UnregisterNetworkLinksByIdAndTypeRequest();
    request.type = ELinkType.NETWORK;
    request.ID = this.GetEntityID();
    this.GetNetworkSystem().QueueRequest(request);
    this.RequestHUDRefresh();
  }

  protected final func IsLookedAt() -> Bool {
    let lookedAtObect: ref<GameObject> = GameInstance.GetTargetingSystem(this.GetGame()).GetLookAtObject(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet);
    return lookedAtObect == this;
  }

  protected const func GetNetworkBeamOffset() -> Vector4 {
    return this.m_networkGridBeamOffset;
  }

  public const func GetNetworkLinkSlotName() -> CName {
    let worldTransform: WorldTransform;
    if this.GetUISlotComponent().GetSlotTransform(n"NetworkLink", worldTransform) {
      return n"NetworkLink";
    };
    return n"";
  }

  public const func GetNetworkLinkSlotName(out transform: WorldTransform) -> CName {
    if this.GetUISlotComponent().GetSlotTransform(n"NetworkLink", transform) {
      return n"NetworkLink";
    };
    return n"";
  }

  protected final const func GetDefaultDevicesBeamResource() -> FxResource {
    let resource: FxResource = this.GetFxResourceByKey(n"deviceLinkDefault");
    if !FxResource.IsValid(resource) {
      resource = this.m_networkGridBeamFX;
    };
    return resource;
  }

  protected final const func GetDefaultNetworkBeamResource() -> FxResource {
    let resource: FxResource = this.GetFxResourceByKey(n"networkLinkDefault");
    if !FxResource.IsValid(resource) {
      resource = this.m_networkGridBeamFX;
    };
    return resource;
  }

  protected final const func GetBreachedNetworkBeamResource() -> FxResource {
    let resource: FxResource = this.GetFxResourceByKey(n"networkLinkBreached");
    if !FxResource.IsValid(resource) {
      resource = this.m_networkGridBeamFX;
    };
    return resource;
  }

  public const func IsNetworkLinkDynamic() -> Bool {
    return this.GetDevicePS().IsLinkDynamic();
  }

  public final func RevealNetworkGrid_Event(shouldDraw: Bool, opt ownerEntityPosition: Vector4, opt fxDefault: FxResource, opt fxBreached: FxResource) -> Void {
    let evt: ref<RevealNetworkGridEvent> = new RevealNetworkGridEvent();
    evt.shouldDraw = shouldDraw;
    evt.ownerEntityPosition = ownerEntityPosition;
    evt.fxDefault = fxDefault;
    evt.fxBreached = fxBreached;
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  public final func RevealDevicesGrid_Event(shouldDraw: Bool, opt ownerEntityPosition: Vector4, opt fxDefault: FxResource) -> Void {
    let evt: ref<RevealDevicesGridEvent> = new RevealDevicesGridEvent();
    evt.shouldDraw = shouldDraw;
    evt.ownerEntityPosition = ownerEntityPosition;
    evt.fxDefault = fxDefault;
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  public final func PingNetworkGrid_Event(ownerEntityPosition: Vector4, fxResource: FxResource, lifetime: Float, pingType: EPingType, revealSlave: Bool, revealMaster: Bool, ignoreRevealed: Bool) -> Void {
    let evt: ref<PingNetworkGridEvent> = new PingNetworkGridEvent();
    evt.ownerEntityPosition = ownerEntityPosition;
    evt.fxResource = fxResource;
    evt.lifetime = lifetime;
    evt.pingType = pingType;
    evt.revealSlave = revealSlave;
    evt.revealMaster = revealMaster;
    evt.ignoreRevealed = ignoreRevealed;
    if !IsFinal() {
      LogDevices(IsDefined(this) + "PingNetworkGrid_Event");
    };
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  protected final func RevealNetworkGrid(shouldDraw: Bool) -> Void {
    if shouldDraw {
      this.RevealNetworkGrid_Event(shouldDraw, this.GetNetworkBeamEndpoint(), this.GetDefaultNetworkBeamResource(), this.GetBreachedNetworkBeamResource());
    } else {
      this.RevealNetworkGrid_Event(shouldDraw);
    };
  }

  protected final func PingNetworkGrid(lifetime: Float, pingType: EPingType, revealSlave: Bool, revealMaster: Bool, ignoreRevealed: Bool) -> Void {
    let resource: FxResource = this.GetFxResourceByKey(n"pingNetworkLink");
    this.PingNetworkGrid_Event(this.GetNetworkBeamEndpoint(), resource, lifetime, pingType, revealSlave, revealMaster, ignoreRevealed);
  }

  protected final func PingNetworkGrid(lifetime: Float, pingType: EPingType, resource: FxResource, revealSlave: Bool, revealMaster: Bool, ignoreRevealed: Bool) -> Void {
    this.PingNetworkGrid_Event(this.GetNetworkBeamEndpoint(), resource, lifetime, pingType, revealSlave, revealMaster, ignoreRevealed);
  }

  public const func GetNetworkBeamEndpoint() -> Vector4 {
    let beamPos: Vector4;
    let transform: WorldTransform;
    this.GetUISlotComponent().GetSlotTransform(n"NetworkLink", transform);
    beamPos = WorldPosition.ToVector4(WorldTransform.TransformPoint(transform, this.GetNetworkBeamOffset()));
    if Vector4.IsZero(beamPos) {
      beamPos = this.GetWorldPosition();
    };
    return beamPos;
  }

  protected final func RevealDevicesGrid(shouldDraw: Bool) -> Void {
    if shouldDraw {
      this.RevealDevicesGrid_Event(shouldDraw, this.GetNetworkBeamEndpoint(), this.GetDefaultDevicesBeamResource());
    } else {
      this.RevealDevicesGrid_Event(shouldDraw);
    };
  }

  protected cb func OnReavealDevicesGrid(evt: ref<RevealDevicesGridOnEntityEvent>) -> Bool {
    this.RevealDevicesGrid(evt.shouldDraw);
  }

  private final func ShouldBeHighlightedLongerOnPing() -> Bool {
    return this.IsQuickHackAble() && this.CanScanThroughWalls();
  }

  protected cb func OnRevealDeviceRequest(evt: ref<RevealDeviceRequest>) -> Bool {
    let invalidID: EntityID;
    let isActiveBackdoor: Bool;
    let isPing: Bool;
    let newPingSourceID: EntityID;
    let shouldUpdate: Bool;
    let revealEvent: ref<RevealObjectEvent> = new RevealObjectEvent();
    revealEvent.reveal = evt.shouldReveal;
    revealEvent.reason.reason = n"network";
    revealEvent.reason.sourceEntityId = evt.sourceID;
    this.ResolveGameplayObjectives(true);
    isActiveBackdoor = this.IsActiveBackdoor();
    isPing = evt.linkData.isPing && Equals(evt.linkData.linkType, ELinkType.NETWORK);
    if !evt.shouldReveal && isPing && (isActiveBackdoor || this.ShouldBeHighlightedLongerOnPing()) && this.GetNetworkSystem().ShouldNetworkElementsPersistAfterFocus() {
      revealEvent.lifetime = this.GetNetworkSystem().GetRevealMasterAfterLeavingFocusDuration();
    };
    if isPing && evt.shouldReveal {
      if this.GetNetworkSystem().SuppressPingIfBackdoorsFound() {
        this.GetDevicePS().SetRevealedInNetworkPing(true);
      };
    };
    if evt.shouldReveal {
      newPingSourceID = this.GetNetworkSystem().GetLastPingSourceID();
    } else {
      newPingSourceID = invalidID;
    };
    if isPing && evt.shouldReveal && isActiveBackdoor && this.m_lastPingSourceID == newPingSourceID {
      shouldUpdate = false;
    } else {
      shouldUpdate = true;
    };
    if shouldUpdate {
      this.QueueEvent(revealEvent);
    };
    this.m_lastPingSourceID = newPingSourceID;
    if !IsFinal() {
      LogDevices(IsDefined(this) + "OnRevealDeviceRequest");
    };
  }

  protected cb func OnRevealNetworkGridRequestFromNetworkSystem(evt: ref<RevealNetworkGridNetworkRequest>) -> Bool {
    if this.IsHighlightedInFocusMode() {
      this.RevealNetworkGrid(true);
    };
    this.ResolveGameplayObjectives(true);
    this.GetDevicePS().SetRevealedInNetworkPing(true);
  }

  protected cb func OnRevealNetworkGridOnPulse(evt: ref<RevealNetworkGridOnPulse>) -> Bool {
    let resource: FxResource = this.GetFxResourceByKey(n"revealNetworkLink");
    if this.GetNetworkSystem().ShouldRevealNetworkAfterPulse() {
      this.GetDevicePS().SetRevealedInNetworkPing(true);
    };
    this.PingNetworkGrid(evt.duration, EPingType.SPACE, resource, evt.revealSlave, evt.revealMaster, false);
  }

  protected cb func OnRevealStateChanged(evt: ref<RevealStateChangedEvent>) -> Bool {
    if Equals(evt.state, ERevealState.STARTED) {
      if !this.m_wasVisible || !this.IsLogicReady() {
        this.ResolveGameplayStateByTask();
      };
    };
  }

  protected func StartPingingNetwork() -> Void {
    let duration: Float;
    let invalidID: EntityID;
    let request: ref<StartPingingNetworkRequest> = new StartPingingNetworkRequest();
    request.source = this;
    request.fxResource = this.GetFxResourceByKey(n"pingNetworkLink");
    this.m_lastPingSourceID = invalidID;
    if this.GetNetworkSystem().AllowSimultanousPinging() {
      duration = this.GetNetworkSystem().GetNetworkReavealDuration();
    } else {
      duration = this.m_scanningComponent.GetTimeNeeded();
    };
    request.duration = duration;
    request.pingType = EPingType.DIRECT;
    request.fakeLinkType = ELinkType.FREE;
    request.revealNetworkAtEnd = true;
    this.GetNetworkSystem().QueueRequest(request);
    this.PingNetworkGrid(duration, EPingType.DIRECT, false, false, true);
  }

  protected func StopPingingNetwork() -> Void {
    let request: ref<StopPingingNetworkRequest> = new StopPingingNetworkRequest();
    request.source = this;
    this.GetNetworkSystem().QueueRequest(request);
  }

  protected cb func OnActionPing(evt: ref<PingDevice>) -> Bool {
    let pingEvt: ref<ForwardPingToSquadEvent>;
    this.PulseNetwork(true);
    if evt.ShouldForward() {
      pingEvt = new ForwardPingToSquadEvent();
      this.SendEventToDefaultPS(pingEvt);
    };
  }

  protected func PulseNetwork(revealNetworkAtEnd: Bool) -> Void {
    let duration: Float;
    let invalidID: EntityID;
    let request: ref<StartPingingNetworkRequest>;
    if GameInstance.GetQuestsSystem(this.GetGame()).GetFact(n"pingingNetworkDisabled") > 0 {
      return;
    };
    this.m_lastPingSourceID = invalidID;
    request = new StartPingingNetworkRequest();
    duration = this.GetNetworkSystem().GetSpacePingDuration();
    request.source = this;
    request.fxResource = this.GetFxResourceByKey(n"pingNetworkLink");
    request.duration = duration;
    request.pingType = EPingType.SPACE;
    request.fakeLinkType = ELinkType.FREE;
    request.revealNetworkAtEnd = revealNetworkAtEnd;
    request.virtualNetworkShapeID = this.GetDevicePS().GetVirtualNetworkShapeID();
    this.PingNetworkGrid(duration, EPingType.SPACE, false, false, false);
    this.GetNetworkSystem().QueueRequest(request);
  }

  protected func ToggleAreaIndicator(turnOn: Bool) -> Void;

  protected cb func OnTimetableEntryTriggered(evt: ref<DeviceTimetableEvent>) -> Bool {
    let action: ref<DeviceAction>;
    if Equals(evt.state, EDeviceStatus.OFF) {
      action = this.GetDevicePS().ActionSetDeviceOFF();
    } else {
      if Equals(evt.state, EDeviceStatus.ON) {
        if evt.restorePower {
          this.ExecuteAction(this.GetDevicePS().ActionSetDevicePowered());
        };
        action = this.GetDevicePS().ActionSetDeviceON();
      } else {
        if Equals(evt.state, EDeviceStatus.UNPOWERED) {
          action = this.GetDevicePS().ActionSetDeviceUnpowered();
        };
      };
    };
    if action != null {
      this.ExecuteAction(action);
    };
  }

  protected cb func OnToggleComponents(evt: ref<ToggleComponentsEvent>) -> Bool {
    this.ResolveComponents(evt.componentsData);
  }

  private final func ResolveComponents(componentsData: array<SComponentOperationData>) -> Void {
    let toggle: Bool;
    let i: Int32 = 0;
    while i < ArraySize(componentsData) {
      toggle = Equals(componentsData[i].operationType, EComponentOperation.Enable);
      this.ToggleComponentByName(componentsData[i].componentName, toggle);
      i += 1;
    };
  }

  protected final func ToggleComponentByName(componentName: CName, toggle: Bool) -> Void {
    let component: ref<IComponent> = this.FindComponentByName(componentName);
    if component != null {
      if NotEquals(component.IsEnabled(), toggle) {
        component.Toggle(toggle);
      };
    };
  }

  protected cb func OnPlayBink(evt: ref<PlayBinkEvent>) -> Bool {
    let component: ref<BinkComponent> = this.FindComponentByName(evt.data.componentName) as BinkComponent;
    if component != null {
      if Equals(evt.data.operationType, EBinkOperationType.STOP) {
        component.Stop();
      } else {
        if Equals(evt.data.operationType, EBinkOperationType.PAUSE) {
          component.Pause(true);
        } else {
          if Equals(evt.data.operationType, EBinkOperationType.RESUME) {
            component.Pause(false);
          } else {
            if Equals(evt.data.operationType, EBinkOperationType.PLAY) {
              component.SetVideoPath(evt.data.binkPath);
              component.SetIsLooped(evt.data.loop);
              component.Play();
            };
          };
        };
      };
    };
  }

  public const func GetFxResourceByKey(key: CName) -> FxResource {
    let resource: FxResource;
    if IsDefined(this.m_resourceLibraryComponent) {
      resource = this.m_resourceLibraryComponent.GetResource(key);
    };
    return resource;
  }

  protected final func AddHudButtonHelper(argText: String, argIcon: CName) -> Void {
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetString(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Text, argText);
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetName(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Icon, argIcon);
  }

  protected final func RemoveHudButtonHelper() -> Void {
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetString(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Text, "");
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudButtonHelp).SetName(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Icon, n"");
  }

  protected cb func OnFactChanged(evt: ref<FactChangedEvent>) -> Bool {
    if Equals(this.GetDevicePS().GetFactToDisableQuestMarkName(), evt.GetFactName()) {
      this.ResolveQuestMarkOnFact();
    };
    if this.GetDevicePS().GetDeviceOperationsContainer() != null {
      this.GetDevicePS().GetDeviceOperationsContainer().EvaluateFactTriggers(this, evt.GetFactName());
    };
  }

  public const func IsTechie() -> Bool {
    return this.GetDevicePS().IsEngineeringSkillCheckActive() || this.GetDevicePS().HasPlaystyle(EPlaystyle.TECHIE);
  }

  public const func IsSolo() -> Bool {
    return this.GetDevicePS().IsDemolitionSkillCheckActive();
  }

  public const func IsNetrunner() -> Bool {
    if !this.IsCyberdeckEquippedOnPlayer() {
      return false;
    };
    return this.GetDevicePS().IsHackingSkillCheckActive() || (this.IsQuickHacksExposed() || this.IsConnectedToBackdoorDevice()) && this.GetDevicePS().HasPlaystyle(EPlaystyle.NETRUNNER) || this.IsActiveBackdoor();
  }

  protected final const func IsCyberdeckEquippedOnPlayer() -> Bool {
    let systemReplacementID: ItemID = EquipmentSystem.GetData(GetPlayer(this.GetGame())).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    let itemRecord: wref<Item_Record> = RPGManager.GetItemRecord(systemReplacementID);
    let itemTags: array<CName> = itemRecord.Tags();
    return ArrayContains(itemTags, n"Cyberdeck");
  }

  public final const func HasAnyPlaystyle() -> Bool {
    return this.GetDevicePS().HasAnyPlaystyle();
  }

  public final const func HasActiveStaticHackingSkillcheck() -> Bool {
    return this.GetDevicePS().HasActiveStaticHackingSkillcheck();
  }

  public final const func HasAnySkillCheckActive() -> Bool {
    return this.GetDevicePS().IsHackingSkillCheckActive() || this.GetDevicePS().IsDemolitionSkillCheckActive() || this.GetDevicePS().IsEngineeringSkillCheckActive();
  }

  protected final const func CanPassAnySkillCheck() -> Bool {
    return this.CanPassEngineeringSkillCheck() || this.CanPassDemolitionSkillCheck() || this.CanPassHackingSkillCheck();
  }

  protected final const func CanPassAnySkillCheckOnMaster() -> Bool {
    let requester: ref<GameObject> = EntityGameInterface.GetEntity(this.GetEntity()) as GameObject;
    return this.GetDevicePS().CanPassAnySkillCheckOnMaster(requester);
  }

  public const func IsHackingSkillCheckActive() -> Bool {
    return this.GetDevicePS().IsHackingSkillCheckActive();
  }

  public const func IsDemolitionSkillCheckActive() -> Bool {
    return this.GetDevicePS().IsDemolitionSkillCheckActive();
  }

  public const func IsEngineeringSkillCheckActive() -> Bool {
    return this.GetDevicePS().IsEngineeringSkillCheckActive();
  }

  public const func CanPassEngineeringSkillCheck() -> Bool {
    let requester: ref<GameObject> = EntityGameInterface.GetEntity(this.GetEntity()) as GameObject;
    return this.GetDevicePS().CanPassEngineeringSkillCheck(requester);
  }

  public const func CanPassDemolitionSkillCheck() -> Bool {
    let requester: ref<GameObject> = EntityGameInterface.GetEntity(this.GetEntity()) as GameObject;
    return this.GetDevicePS().CanPassDemolitionSkillCheck(requester);
  }

  public const func CanPassHackingSkillCheck() -> Bool {
    let requester: ref<GameObject> = EntityGameInterface.GetEntity(this.GetEntity()) as GameObject;
    return this.GetDevicePS().CanPassHackingSkillCheck(requester);
  }

  protected final const func HasAnyQuickHackActive() -> Bool {
    return this.GetDevicePS().HasAnyAvailableQuickHack();
  }

  protected final const func HasAnyActiveQuickHackVulnerabilities() -> Bool {
    return this.GetDevicePS().HasAnyActiveQuickHackVulnerabilities();
  }

  protected final const func HasAnySpiderBotOrdersActive() -> Bool {
    return this.GetDevicePS().HasAnyAvailableSpiderbotActions();
  }

  protected const func HasAnyDistractions() -> Bool {
    return IsDefined(this.GetFxResourceMapper()) && this.GetFxResourceMapper().HasAnyDistractions();
  }

  protected const func GetDistractionRange(type: DeviceStimType) -> Float {
    if IsDefined(this.GetFxResourceMapper()) {
      return this.GetFxResourceMapper().GetDistractionRange(type);
    };
    return 0.00;
  }

  protected const func GetSmallestDistractionRange(type: DeviceStimType) -> Float {
    if IsDefined(this.GetFxResourceMapper()) {
      return this.GetFxResourceMapper().GetSmallestDistractionRange(type);
    };
    return 0.00;
  }

  public const func IsQuest() -> Bool {
    return this.GetDevicePS().IsMarkedAsQuest();
  }

  protected func MarkAsQuest(isQuest: Bool) -> Void {
    this.GetDevicePS().SetIsMarkedAsQuest(isQuest);
  }

  private final func ResolveQuestMarkOnFact() -> Void {
    let factName: CName = this.GetDevicePS().GetFactToDisableQuestMarkName();
    if !IsNameValid(factName) {
      return;
    };
    if GameInstance.GetQuestsSystem(this.GetGame()).GetFact(factName) > 0 {
      this.ToggleQuestImportance(false);
    };
  }

  private final func ResolveQuestImportanceOnPerformedAction(action: ref<ScriptableDeviceAction>) -> Void {
    let authOffAction: ref<SetAuthorizationModuleOFF>;
    let skillcheckAction: ref<ActionSkillCheck>;
    if !this.GetDevicePS().IsAutoTogglingQuestMark() {
      return;
    };
    skillcheckAction = action as ActionSkillCheck;
    authOffAction = action as SetAuthorizationModuleOFF;
    if IsDefined(authOffAction) {
      this.ToggleQuestImportance(false);
    } else {
      if !this.HasAnySkillCheckActive() {
        if Equals(action.GetRequestType(), gamedeviceRequestType.Remote) || Equals(action.GetRequestType(), gamedeviceRequestType.Direct) {
          this.ToggleQuestImportance(false);
        };
      } else {
        if IsDefined(skillcheckAction) {
          if skillcheckAction.IsCompleted() {
            this.ToggleQuestImportance(false);
          };
        };
      };
    };
  }

  protected final const func HasAnyNetworkLink() -> Bool {
    return this.GetNetworkSystem().HasNetworkLink(this.GetEntityID());
  }

  protected final const func HasAnyNetworkLink(ignorePingLinks: Bool) -> Bool {
    return this.GetNetworkSystem().HasNetworkLink(this.GetEntityID(), ignorePingLinks);
  }

  public const func IsGameplayRoleValid(role: EGameplayRole) -> Bool {
    if this.GetDevicePS().IsDisabled() || this.GetDevicePS().IsUnpowered() {
      return false;
    };
    return true;
  }

  public const func IsActive() -> Bool {
    if this.GetDevicePS().IsDisabled() || this.GetDevicePS().IsUnpowered() {
      return false;
    };
    if TDBID.IsValid(this.GetDevicePS().GetTweakDBRecord()) && this.IsDead() {
      return false;
    };
    return true;
  }

  public const func IsGameplayRelevant() -> Bool {
    let role: EGameplayRole = this.GetCurrentGameplayRole();
    return NotEquals(role, IntEnum(1l)) && NotEquals(role, EGameplayRole.UnAssigned);
  }

  public const func GetContentScale() -> TweakDBID {
    if TDBID.IsValid(this.m_contentScale) {
      return this.m_contentScale;
    };
    return this.GetDevicePS().GetContentAssignmentID();
  }

  public const func GetCurrentGameplayRole() -> EGameplayRole {
    if IsDefined(this.m_gameplayRoleComponent) {
      return this.m_gameplayRoleComponent.GetCurrentGameplayRole();
    };
    return IntEnum(1l);
  }

  public final const func IsGameplayRoleStatic() -> Bool {
    if IsDefined(this.m_gameplayRoleComponent) {
      return this.m_gameplayRoleComponent.IsGameplayRoleStatic();
    };
    return false;
  }

  protected final func ReEvaluateGameplayRole() -> Void {
    let evt: ref<EvaluateGameplayRoleEvent>;
    if !this.IsGameplayRoleStatic() && NotEquals(this.GetCurrentGameplayRole(), this.DeterminGameplayRole()) {
      evt = new EvaluateGameplayRoleEvent();
      this.QueueEvent(evt);
    };
  }

  protected final func ForceReEvaluateGameplayRole() -> Void {
    let evt: ref<EvaluateGameplayRoleEvent>;
    if NotEquals(this.GetCurrentGameplayRole(), this.DeterminGameplayRole()) {
      evt = new EvaluateGameplayRoleEvent();
      evt.force = true;
      this.QueueEvent(evt);
    };
  }

  public const func DeterminGameplayRoleMappinVisuaState(data: SDeviceMappinData) -> EMappinVisualState {
    let hasAnyQuickHacksVoulnerabilities: Bool;
    let hasQuickHacksExposed: Bool;
    if this.GetDevicePS().IsDisabled() {
      return EMappinVisualState.Inactive;
    };
    if this.IsActiveBackdoor() {
      if !this.IsHackingSkillCheckActive() || this.IsHackingSkillCheckActive() && this.CanPassHackingSkillCheck() {
        return EMappinVisualState.Available;
      };
      return EMappinVisualState.Unavailable;
    };
    if this.HasAnySkillCheckActive() && this.CanPassAnySkillCheck() {
      return EMappinVisualState.Available;
    };
    hasQuickHacksExposed = this.GetNetworkSystem().QuickHacksExposedByDefault() || this.IsConnectedToBackdoorDevice() && this.GetDevicePS().IsQuickHacksExposed();
    if hasQuickHacksExposed {
      hasAnyQuickHacksVoulnerabilities = this.HasAnyActiveQuickHackVulnerabilities();
    };
    if hasQuickHacksExposed && hasAnyQuickHacksVoulnerabilities {
      return EMappinVisualState.Available;
    };
    if this.HasAnySkillCheckActive() && !this.CanPassAnySkillCheck() {
      return EMappinVisualState.Unavailable;
    };
    if !this.HasAnySkillCheckActive() && !hasQuickHacksExposed {
      return EMappinVisualState.Unavailable;
    };
    if hasQuickHacksExposed && !hasAnyQuickHacksVoulnerabilities {
      return EMappinVisualState.Unavailable;
    };
    return this.DeterminGameplayRoleMappinVisuaState(data);
  }

  public const func DeterminGameplayRoleMappinRange(data: SDeviceMappinData) -> Float {
    let range: Float;
    if NotEquals(data.gameplayRole, IntEnum(1l)) {
      switch data.gameplayRole {
        case EGameplayRole.Distract:
          if this.IsAnyPlaystyleValid() {
            range = this.GetDistractionRange(DeviceStimType.Distract);
          };
          break;
        case EGameplayRole.DistractVendingMachine:
          if this.IsAnyPlaystyleValid() {
            range = this.GetDistractionRange(DeviceStimType.Distract);
          };
          break;
        case EGameplayRole.ExplodeLethal:
          range = this.GetDistractionRange(DeviceStimType.Explosion);
          break;
        case EGameplayRole.ExplodeNoneLethal:
          range = this.GetDistractionRange(DeviceStimType.Explosion);
          break;
        case EGameplayRole.SpreadGas:
          range = this.GetDistractionRange(DeviceStimType.VentilationAreaEffect);
          break;
        default:
          if this.IsNetrunner() {
            range = range = this.GetDistractionRange(DeviceStimType.Distract);
          } else {
            range = 0.00;
          };
      };
    };
    return range;
  }

  protected cb func OnQuickHackDistraction(evt: ref<QuickHackDistraction>) -> Bool {
    if evt.IsCompleted() {
      this.StopGlitching();
    } else {
      this.StartGlitching(EGlitchState.DEFAULT, 1.00);
      this.ShowQuickHackDuration(evt);
    };
  }

  protected cb func OnQuestStartGlitch(evt: ref<QuestStartGlitch>) -> Bool {
    this.StartGlitching(EGlitchState.DEFAULT);
  }

  protected cb func OnQuestStopGlitch(evt: ref<QuestStopGlitch>) -> Bool {
    this.StopGlitching();
  }

  protected cb func OnGlitchScreen(evt: ref<GlitchScreen>) -> Bool {
    let action: ref<ScriptableDeviceAction> = evt;
    if evt.IsCompleted() {
      this.StopGlitching();
      this.ClearActiveStatusEffect();
      this.ClearActiveProgramToUploadOnNPC();
    } else {
      if IsDefined(action) {
        this.SetActiveStatusEffect(action.GetActiveStatusEffectTweakDBID());
        this.SetActiveProgramToUploadOnNPC(action.GetAttachedProgramTweakDBID());
      };
      this.StartGlitching(EGlitchState.SUBLIMINAL_MESSAGE, 1.00);
      this.ShowQuickHackDuration(evt);
    };
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void;

  protected func StopGlitching() -> Void;

  public const func HasActiveDistraction() -> Bool {
    return this.GetDevicePS().IsDistracting() || this.GetDevicePS().IsGlitching();
  }

  public const func HasActiveQuickHackUpload() -> Bool {
    if IsDefined(this.m_gameplayRoleComponent) {
      return this.m_gameplayRoleComponent.HasActiveMappin(gamedataMappinVariant.QuickHackVariant);
    };
    return false;
  }

  protected final func SetGameplayRoleToNone() -> Void {
    let disableRoleEvent: ref<SetCurrentGameplayRoleEvent> = new SetCurrentGameplayRoleEvent();
    disableRoleEvent.gameplayRole = IntEnum(1l);
    this.QueueEvent(disableRoleEvent);
  }

  protected final func SetGameplayRole(role: EGameplayRole) -> Void {
    let evt: ref<SetCurrentGameplayRoleEvent> = new SetCurrentGameplayRoleEvent();
    evt.gameplayRole = role;
    this.QueueEvent(evt);
  }

  public const func GetPlaystyleMappinSlotWorldPos() -> Vector4 {
    let pos: Vector4;
    let transform: WorldTransform;
    this.GetUISlotComponent().GetSlotTransform(n"roleMappin", transform);
    pos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform));
    return pos;
  }

  public const func GetPlaystyleMappinSlotWorldTransform() -> WorldTransform {
    let transform: WorldTransform;
    this.GetUISlotComponent().GetSlotTransform(n"roleMappin", transform);
    return transform;
  }

  public const func GetPlaystyleMappinLocalPos() -> Vector4 {
    let pos: Vector4 = this.GetUISlotComponent().GetLocalPosition();
    return pos;
  }

  protected cb func OnSpiderbotOrderCompletedEvent(evt: ref<SpiderbotOrderCompletedEvent>) -> Bool {
    this.SendSetIsSpiderbotInteractionOrderedEvent(false);
    if this.ShouldAllowSpiderbotToPerformAction() {
      this.GetDevicePS().ExecuteCurrentSpiderbotActionPerformed();
    };
  }

  protected final func OrderSpiderbot() -> Void {
    let spiderbotOrderDeviceEvent: ref<SpiderbotOrderDeviceEvent> = new SpiderbotOrderDeviceEvent();
    spiderbotOrderDeviceEvent.target = this;
    this.SendSetIsSpiderbotInteractionOrderedEvent(true);
    this.GetPlayerMainObject().QueueEvent(spiderbotOrderDeviceEvent);
  }

  protected final func ShouldAllowSpiderbotToPerformAction() -> Bool {
    return this.GetDevicePS().GetCurrentlyQueuedSpiderbotAction().CanSpiderbotCompleteThisAction(this.GetDevicePS());
  }

  protected cb func OnSendSpiderbotToPerformActionEvent(evt: ref<SendSpiderbotToPerformActionEvent>) -> Bool {
    let spiderbotOrderDeviceEvent: ref<SpiderbotOrderDeviceEvent> = new SpiderbotOrderDeviceEvent();
    spiderbotOrderDeviceEvent.target = this;
    this.SendSetIsSpiderbotInteractionOrderedEvent(true);
    evt.executor.QueueEvent(spiderbotOrderDeviceEvent);
  }

  protected final func SendSetIsSpiderbotInteractionOrderedEvent(value: Bool) -> Void {
    let evt: ref<SetIsSpiderbotInteractionOrderedEvent> = new SetIsSpiderbotInteractionOrderedEvent();
    evt.value = value;
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  public final const func GetSlotComponent() -> ref<SlotComponent> {
    return this.m_slotComponent;
  }

  private final func InitializeGameplayObjectives() -> Void {
    this.GetDevicePS().InitializeGameplayObjectives();
  }

  protected final const func GetGameplayQuestSystem() -> ref<GameplayQuestSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"GameplayQuestSystem") as GameplayQuestSystem;
  }

  protected final func ShowGameplayObjective(data: ref<GemplayObjectiveData>) -> Void {
    this.CreateGameplayObjective(data);
  }

  protected final func CreateGameplayObjective(data: ref<GemplayObjectiveData>) -> Void {
    let request: ref<RegisterGameplayObjectiveRequest>;
    if data == null {
      return;
    };
    request = new RegisterGameplayObjectiveRequest();
    request.objectiveData = data;
    this.GetGameplayQuestSystem().QueueRequest(request);
  }

  protected final func SucceedGameplayObjective(data: ref<GemplayObjectiveData>) -> Void {
    let request: ref<SetGameplayObjectiveStateRequest>;
    if data == null {
      return;
    };
    request = new SetGameplayObjectiveStateRequest();
    request.objectiveData = data;
    request.objectiveState = gameJournalEntryState.Succeeded;
    this.GetGameplayQuestSystem().QueueRequest(request);
  }

  protected final func RemoveGameplayObjective(data: ref<GemplayObjectiveData>) -> Void {
    let request: ref<SetGameplayObjectiveStateRequest>;
    if data == null {
      return;
    };
    request = new SetGameplayObjectiveStateRequest();
    request.objectiveData = data;
    request.objectiveState = gameJournalEntryState.Inactive;
    this.GetGameplayQuestSystem().QueueRequest(request);
  }

  protected final func ResolveGameplayObjectives(show: Bool) -> Void {
    let backdoorObjective: ref<GemplayObjectiveData>;
    let controlPanelObjective: ref<GemplayObjectiveData>;
    if show {
      if this.GetDevicePS().HasNetworkBackdoor() && this.HasAnySkillCheckActive() {
        this.ShowGameplayObjective(this.GetDevicePS().GetBackdoorObjectiveData());
      } else {
        if this.GetDevicePS().HasAnySlave() && this.HasAnySkillCheckActive() {
          this.ShowGameplayObjective(this.GetDevicePS().GetControlPanelObjectiveData());
        };
      };
    } else {
      backdoorObjective = this.GetDevicePS().GetBackdoorObjectiveData();
      controlPanelObjective = this.GetDevicePS().GetControlPanelObjectiveData();
      if IsDefined(backdoorObjective) && Equals(backdoorObjective.GetObjectiveState(), gameJournalEntryState.Succeeded) {
        this.RemoveGameplayObjective(backdoorObjective);
      };
      if IsDefined(controlPanelObjective) && Equals(controlPanelObjective.GetObjectiveState(), gameJournalEntryState.Succeeded) {
        this.RemoveGameplayObjective(controlPanelObjective);
      };
    };
  }

  protected cb func OnCommunicationEvent(evt: ref<CommunicationEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    if Equals(evt.name, n"InvestigationEnded") {
      this.ApplyActiveStatusEffect(evt.sender, this.m_activeStatusEffect);
    } else {
      if Equals(evt.name, n"InvestigationStarted") {
        this.CheckDistractionAchievemnt();
        this.UploadActiveProgramOnNPC(evt.sender);
        GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(evt.sender, t"BaseStatusEffect.DistractionDuration");
      } else {
        if Equals(evt.name, n"npcDistracted") {
          broadcaster = this.GetStimBroadcasterComponent();
          if IsDefined(broadcaster) {
            broadcaster.RemoveActiveStimuliByName(this, gamedataStimType.Distract);
          };
        } else {
          if Equals(evt.name, n"ResetInvestigators") {
            this.GetDevicePS().ClearWillingInvestigators();
          } else {
            if Equals(evt.name, n"TaskDeactivated") {
              this.GetDevicePS().FinishDistraction();
              GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveStatusEffect(evt.sender, t"BaseStatusEffect.DistractionDuration");
            };
          };
        };
      };
    };
  }

  public final const func HasWillingInvestigator(id: EntityID) -> Bool {
    return this.GetDevicePS().HasWillingInvestigator(id);
  }

  protected final func CheckDistractionAchievemnt() -> Void {
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    let request: ref<ModifyTelemetryVariable> = new ModifyTelemetryVariable();
    request.dataTrackingFact = ETelemetryData.QuickHacksMade;
    dataTrackingSystem.QueueRequest(request);
  }

  protected func ApplyActiveStatusEffect(target: EntityID, statusEffect: TweakDBID) -> Void {
    if this.IsActiveStatusEffectValid() {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(target, statusEffect);
    };
  }

  protected final const func GetActiveStatusEffect() -> TweakDBID {
    return this.m_activeStatusEffect;
  }

  protected final func SetActiveStatusEffect(effect: TweakDBID) -> Void {
    if TDBID.IsValid(effect) {
      this.m_activeStatusEffect = effect;
    };
  }

  protected final func ClearActiveStatusEffect() -> Void {
    let invalidID: TweakDBID;
    this.m_activeStatusEffect = invalidID;
  }

  protected final const func IsActiveStatusEffectValid() -> Bool {
    return TDBID.IsValid(this.m_activeStatusEffect);
  }

  protected final func SetActiveProgramToUploadOnNPC(program: TweakDBID) -> Void {
    if TDBID.IsValid(program) {
      this.m_activeProgramToUploadOnNPC = program;
    };
  }

  protected final const func GetActiveProgramToUploadOnNPC() -> TweakDBID {
    return this.m_activeProgramToUploadOnNPC;
  }

  protected final func ClearActiveProgramToUploadOnNPC() -> Void {
    let invalidID: TweakDBID;
    this.m_activeProgramToUploadOnNPC = invalidID;
  }

  protected final const func IsActiveProgramToUploadOnNPCValid() -> Bool {
    return TDBID.IsValid(this.m_activeProgramToUploadOnNPC);
  }

  protected func UploadActiveProgramOnNPC(targetID: EntityID) -> Void {
    let evt: ref<ExecutePuppetActionEvent>;
    if this.IsActiveProgramToUploadOnNPCValid() {
      evt = new ExecutePuppetActionEvent();
      evt.actionID = this.GetActiveProgramToUploadOnNPC();
      this.QueueEventForEntityID(targetID, evt);
    };
  }

  protected cb func OnQuestResolveSkillchecks(evt: ref<ResolveAllSkillchecksEvent>) -> Bool {
    this.GetDevicePS().QuestResolveSkillchecks();
    this.UpdateDeviceState();
    this.DetermineInteractionState();
  }

  protected cb func OnQuestSetSkillchecks(evt: ref<SetSkillcheckEvent>) -> Bool {
    this.GetDevicePS().QuestSetSkillchecks(evt.skillcheckContainer);
    this.UpdateDeviceState();
    this.DetermineInteractionState();
  }

  protected cb func OnChangeLoopCurveEvent(evt: ref<ChangeLoopCurveEvent>) -> Bool {
    let changeLight: ref<ChangeCurveEvent> = new ChangeCurveEvent();
    changeLight.loop = true;
    changeLight.curve = evt.loopCurve;
    changeLight.time = evt.loopTime;
    this.QueueEvent(changeLight);
  }

  protected cb func OnActionCooldownEvent(evt: ref<ActionCooldownEvent>) -> Bool {
    let context: GetActionsContext;
    let requestType: gamedeviceRequestType;
    if this.GetDevicePS().HasActiveContext(gamedeviceRequestType.Direct) {
      requestType = gamedeviceRequestType.Direct;
    } else {
      if this.GetDevicePS().HasActiveContext(gamedeviceRequestType.Remote) {
        requestType = gamedeviceRequestType.Remote;
      } else {
        requestType = IntEnum(0l);
      };
    };
    if NotEquals(requestType, IntEnum(0l)) {
      context = this.GetDevicePS().GenerateContext(requestType, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
      this.DetermineInteractionState(context);
    };
  }

  protected cb func OnDisableRPGRequirementsForQucikHackActions(evt: ref<DisableRPGRequirementsForDeviceActions>) -> Bool {
    let context: GetActionsContext;
    if evt.m_disable {
      this.GetDevicePS().DisbaleRPGChecksForAction(evt.m_action);
    } else {
      this.GetDevicePS().EnableRPGChecksForAction(evt.m_action);
    };
    context = this.GetDevicePS().GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), this.GetPlayerMainObject(), this.GetEntityID());
    this.DetermineInteractionState(context);
  }

  public const func GetAcousticQuerryStartPoint() -> Vector4 {
    let transform: WorldTransform;
    let slotFound: Bool = this.GetUISlotComponent().GetSlotTransform(n"roleMappin", transform);
    let point: Vector4 = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(transform));
    if Vector4.IsZero(point) || !slotFound {
      this.GetAcousticQuerryStartPoint();
    };
    return point;
  }

  protected cb func OnToggleTakeOverControl(evt: ref<ToggleTakeOverControl>) -> Bool {
    TakeOverControlSystem.RequestTakeControl(this, evt);
    return true;
  }

  protected cb func OnTCSTakeOverControlActivate(evt: ref<TCSTakeOverControlActivate>) -> Bool {
    this.TakeControlOverCamera(false);
    if evt.IsQuickhack {
      this.ExecuteAction(this.GetDevicePS().ActionSetDeviceAttitude());
    };
    this.ToggleForcedVisibilityInAnimSystem(n"TCSTakeOverControlActivate", true, 0.00);
  }

  protected cb func OnTCSTakeOverControlDeactivate(evt: ref<TCSTakeOverControlDeactivate>) -> Bool {
    this.TakeControlOverCamera(true);
    this.ToggleForcedVisibilityInAnimSystem(n"TCSTakeOverControlActivate", false, 0.00);
  }

  protected final func TakeControlOverCamera(isOn: Bool) -> Void {
    let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if isOn {
      targetingSystem.RemoveIgnoredCollisionEntities(this);
      targetingSystem.RemoveIgnoredLookAtEntity(GetPlayer(this.GetGame()), this.GetEntityID());
      if IsDefined(blackboard) && IsDefined(this.m_ZoomStateMachineListenerID) {
        blackboard.UnregisterListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_ZoomStateMachineListenerID);
      };
      this.m_cameraComponent.Deactivate(0.00, true);
    } else {
      if IsDefined(blackboard) {
        this.m_ZoomStateMachineListenerID = blackboard.RegisterListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnPlayerStateMachineZoom");
      };
      targetingSystem.AddIgnoredCollisionEntities(this);
      targetingSystem.AddIgnoredLookAtEntity(GetPlayer(this.GetGame()), this.GetEntityID());
      this.m_cameraComponent.Activate(0.00, true);
    };
  }

  protected cb func OnPlayerStateMachineZoom(value: Float) -> Bool {
    this.m_cameraComponent.SetZoom(value);
  }

  protected cb func OnTCSInputXAxisEvent(evt: ref<TCSInputXAxisEvent>) -> Bool;

  protected cb func OnTCSInputYAxisEvent(evt: ref<TCSInputYAxisEvent>) -> Bool;

  protected cb func OnTCSInputXYAxisEvent(evt: ref<TCSInputXYAxisEvent>) -> Bool;

  protected cb func OnTCSInputDeviceAttack(evt: ref<TCSInputDeviceAttack>) -> Bool {
    if evt.value {
      this.ControlledDeviceInputAction(true);
    } else {
      this.ControlledDeviceInputAction(false);
    };
  }

  protected cb func OnTCSInputCameraZoom(evt: ref<TCSInputCameraZoom>) -> Bool {
    let psmBlackboard: ref<IBlackboard>;
    let zoomLevel: Float;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(player) {
      psmBlackboard = player.GetPlayerStateMachineBlackboard();
      zoomLevel = psmBlackboard.GetFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel);
    };
    this.m_cameraComponent.SetZoom(zoomLevel);
  }

  protected const func ShouldRegisterToHUD() -> Bool {
    let returnValue: Bool;
    if this.m_forceRegisterInHudManager {
      return true;
    };
    if this.HasAnyClue() {
      returnValue = true;
    } else {
      if Equals(this.GetCurrentGameplayRole(), IntEnum(1l)) || Equals(this.GetCurrentGameplayRole(), EGameplayRole.UnAssigned) {
        returnValue = false;
      } else {
        if IsDefined(this.m_scanningComponent) || IsDefined(this.m_gameplayRoleComponent) || IsDefined(this.m_visionComponent) {
          returnValue = true;
        } else {
          returnValue = false;
        };
      };
    };
    return returnValue;
  }

  protected cb func OnOverloadDevice(evt: ref<OverloadDevice>) -> Bool {
    if evt.IsStarted() {
      this.StartOverload();
    } else {
      this.StopOverload(evt.GetKillDelay());
    };
  }

  protected func StartOverload() -> Void;

  protected func StopOverload(killDelay: Float) -> Void {
    this.KillNPCWorkspotUser(killDelay);
  }

  protected final func KillNPCWorkspotUser(killDelay: Float) -> Void {
    let killEvent: ref<NPCKillDelayEvent>;
    let npc: ref<GameObject>;
    if !this.GetDevicePS().IsSomeoneUsingNPCWorkspot() {
      return;
    };
    npc = GameInstance.GetWorkspotSystem(this.GetGame()).GetDeviceUser(this.GetEntityID());
    GameInstance.GetWorkspotSystem(this.GetGame()).SendJumpToTagCommandEnt(npc, n"kill", !this.GetDevicePS().ShouldNPCWorkspotFinishLoop());
    killEvent = new NPCKillDelayEvent();
    killEvent.target = npc;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, killEvent, killDelay);
  }

  protected cb func OnNPCKillDelayEvent(evt: ref<NPCKillDelayEvent>) -> Bool {
    let npc: ref<NPCPuppet> = evt.target as NPCPuppet;
    if IsDefined(npc) {
      npc.Kill(null, true);
    };
  }

  protected final func CreateEMPGameEffect(range: Float) -> Void {
    let position: Vector4 = this.GetAcousticQuerryStartPoint();
    let empEffect: ref<EffectInstance> = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(n"emp", n"emp", this);
    EffectData.SetVector(empEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetFloat(empEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, range);
    empEffect.Run();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"emp");
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"smoke");
    this.StartGlitching(EGlitchState.DEFAULT, 1.00);
  }

  protected final func StopEMPGameEffect() -> Void {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"smoke");
  }

  protected final func AddActiveContext(context: gamedeviceRequestType) -> Void {
    let evt: ref<AddActiveContextEvent> = new AddActiveContextEvent();
    evt.context = context;
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  protected final func RemoveActiveContext(context: gamedeviceRequestType) -> Void {
    let evt: ref<RemoveActiveContextEvent> = new RemoveActiveContextEvent();
    evt.context = context;
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), evt);
  }

  protected final func EvaluateProximityMappinInteractionLayerState() -> Void {
    if this.IsActiveBackdoor() {
      this.EnableProximityMappinInteractionLayer(true);
    } else {
      this.EnableProximityMappinInteractionLayer(false);
      this.HideMappinOnProximity();
    };
  }

  protected final func EnableProximityMappinInteractionLayer(enable: Bool) -> Void {
    let evt: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    evt.enable = enable;
    evt.layer = n"ForceShowIcon";
    this.QueueEvent(evt);
  }

  protected func ShowMappinOnProximity() -> Void {
    let actorUpdateData: ref<HUDActorUpdateData>;
    let statValue: Float = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.HasCyberdeck);
    if statValue > 0.00 {
      actorUpdateData = new HUDActorUpdateData();
      actorUpdateData.updateIsInIconForcedVisibilityRange = true;
      actorUpdateData.isInIconForcedVisibilityRangeValue = true;
      actorUpdateData.updateIsIconForcedVisibleThroughWalls = true;
      actorUpdateData.isIconForcedVisibleThroughWallsValue = true;
      this.RequestHUDRefresh(actorUpdateData);
    };
  }

  protected func HideMappinOnProximity() -> Void {
    let actorUpdateData: ref<HUDActorUpdateData> = new HUDActorUpdateData();
    actorUpdateData.updateIsInIconForcedVisibilityRange = true;
    actorUpdateData.isInIconForcedVisibilityRangeValue = false;
    actorUpdateData.updateIsIconForcedVisibleThroughWalls = true;
    actorUpdateData.isIconForcedVisibleThroughWallsValue = false;
    this.RequestHUDRefresh(actorUpdateData);
  }

  protected final func EvaluateProximityRevealInteractionLayerState() -> Void {
    if this.IsActiveBackdoor() {
      this.EnableProximityRevealInteractionLayer(true);
    } else {
      this.EnableProximityRevealInteractionLayer(false);
      this.StopRevealingOnProximity(0.00);
    };
  }

  protected final func EnableProximityRevealInteractionLayer(enable: Bool) -> Void {
    let evt: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    evt.enable = enable;
    evt.layer = n"ForceReveal";
    this.QueueEvent(evt);
  }

  protected func StartRevealingOnProximity() -> Void {
    let statValue: Float = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.HighlightAccessPoint);
    if statValue > 0.00 {
      this.SendForceRevealObjectEvent(true, n"ForceRevealOnProximity", this.GetEntityID());
    };
  }

  protected func StopRevealingOnProximity(lifetime: Float) -> Void {
    this.SendForceRevealObjectEvent(false, n"ForceRevealOnProximity", this.GetEntityID(), lifetime);
  }

  protected func GetRevealOnProximityStopLifetimeValue() -> Float {
    return 7.00;
  }
}
