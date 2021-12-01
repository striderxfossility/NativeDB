
public class SetCustomPersonalLinkReason extends ScriptableDeviceAction {

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.None")
  @attrib(tooltip, "Default == Disable the feature. Other options enables: Disable Personal Link Auto Disconnect and Personal Link Forced flags")
  public edit let reason: TweakDBID;

  public final func GetFriendlyDescription() -> String {
    return "Set Custom Personal Link Reason";
  }
}

public class ResolveAllSkillchecksEvent extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Resolve All Skillchecks";
  }
}

public class SetSkillcheckEvent extends Event {

  @attrib(tooltip, "If you use it to set a wrong skillcheck, I'm going to find you and I'm going to kill you. Slowly.")
  public inline edit let skillcheckContainer: ref<BaseSkillCheckContainer>;

  public final func GetFriendlyDescription() -> String {
    return "Set Skillcheck";
  }
}

public class ChangeLoopCurveEvent extends Event {

  public edit let loopTime: Float;

  public edit let loopCurve: CName;

  public final func GetFriendlyDescription() -> String {
    return "Change Loop Curve";
  }
}

public struct AuthorizationData {

  @default(AuthorizationData, true)
  public persistent let m_isAuthorizationModuleOn: Bool;

  public persistent let m_alwaysExposeActions: Bool;

  public persistent let m_authorizationDataEntry: SecurityAccessLevelEntryClient;

  public final static func IsAuthorizationValid(self: AuthorizationData) -> Bool {
    if self.m_isAuthorizationModuleOn {
      return SecurityAccessLevelEntryClient.IsDataValid(self.m_authorizationDataEntry);
    };
    return false;
  }
}

public struct SPerformedActions {

  public persistent let ID: CName;

  public persistent let ActionContext: array<EActionContext>;

  public final static func ContainsActionContext(self: SPerformedActions, actionContext: EActionContext) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(self.ActionContext) {
      if Equals(self.ActionContext[i], actionContext) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func GetContextFromAction(selfPSID: PersistentID, actionToResolve: ref<ScriptableDeviceAction>) -> EActionContext {
    if actionToResolve.IsQuickHack() {
      return EActionContext.QHack;
    };
    if actionToResolve.IsSpiderbotAction() {
      return EActionContext.Spiderbot;
    };
    if PersistentID.ExtractEntityID(selfPSID) == actionToResolve.GetRequesterID() {
      return EActionContext.Direct;
    };
    if PersistentID.ExtractEntityID(selfPSID) != actionToResolve.GetRequesterID() {
      return EActionContext.Master;
    };
    return IntEnum(-1l);
  }
}

public class ScriptableDeviceComponentPS extends SharedGameplayPS {

  protected persistent let m_isInitialized: Bool;

  @attrib(category, "Initialization overrides")
  protected let m_forceResolveStateOnAttach: Bool;

  @attrib(category, "Initialization overrides")
  protected let m_forceVisibilityInAnimSystemOnLogicReady: Bool;

  protected let m_masters: array<ref<DeviceComponentPS>>;

  @default(ScriptableDeviceComponentPS, false)
  protected let m_mastersCached: Bool;

  @default(AOEAreaControllerPS, LocKey#188)
  @default(AccessPointControllerPS, LocKey#138)
  @default(ActivatedDeviceControllerPS, ActivatedDevice)
  @default(ActivatorControllerPS, LocKey#42164)
  @default(ApartmentScreenControllerPS, LocKey#193)
  @default(ArcadeMachineControllerPS, LocKey#1635)
  @default(BaseAnimatedDeviceControllerPS, Gameplay-Devices-DisplayNames-RoadBlock)
  @default(BaseDestructibleControllerPS, LocKey#127)
  @default(BasicDistractionDeviceControllerPS, LocKey#42164)
  @default(BillboardDeviceControllerPS, LocKey#153)
  @default(BlindingLightControllerPS, LocKey#168)
  @default(CandleControllerPS, LocKey#45725)
  @default(ChestPressControllerPS, LocKey#601)
  @default(CleaningMachineControllerPS, LocKey#2033)
  @default(ComputerControllerPS, LocKey#48)
  @default(ConfessionBoothControllerPS, LocKey#1942)
  @default(ConveyorControllerPS, LocKey#45661)
  @default(CrossingLightControllerPS, LocKey#125)
  @default(DestructibleMasterLightControllerPS, LocKey#42165)
  @default(DeviceSystemBaseControllerPS, BaseDeviceSystemControllerPS)
  @default(DisassembleMasterControllerPS, Disassemble Master)
  @default(DisplayGlassControllerPS, LocKey#2069)
  @default(DisposalDeviceControllerPS, LocKey#102)
  @default(DoorControllerPS, LocKey#69)
  @default(DoorProximityDetectorControllerPS, Gameplay-Devices-DisplayNames-LaserDetector)
  @default(ElectricLightControllerPS, LocKey#42165)
  @default(ElevatorFloorTerminalControllerPS, LocKey#88)
  @default(ExitLightControllerPS, Exit Light)
  @default(ExplosiveDeviceControllerPS, LocKey#42163)
  @default(ExplosiveTriggerDeviceControllerPS, LocKey#42163)
  @default(FanControllerPS, LocKey#94)
  @default(ForkliftControllerPS, LocKey#1639)
  @default(FridgeControllerPS, LocKey#79)
  @default(FuseBoxControllerPS, LocKey#2013)
  @default(FuseControllerPS, LocKey#116)
  @default(GlitchedTurretControllerPS, LocKey#121)
  @default(HoloFeederControllerPS, LocKey#95)
  @default(HoloTableControllerPS, LocKey#17851)
  @default(IceMachineControllerPS, LocKey#1637)
  @default(InteractiveAdControllerPS, LocKey#197)
  @default(IntercomControllerPS, LocKey#163)
  @default(JukeboxControllerPS, LocKey#165)
  @default(LadderControllerPS, LocKey#2226)
  @default(LaserDetectorControllerPS, Gameplay-Devices-DisplayNames-LaserDetector)
  @default(LcdScreenControllerPS, LocKey#193)
  @default(LiftControllerPS, LocKey#101)
  @default(MaintenancePanelControllerPS, Gameplay-Devices-DisplayNames-MaintenancePanel)
  @default(MovableDeviceControllerPS, MovableDevice)
  @default(NcartTimetableControllerPS, LocKey#1653)
  @default(NetrunnerChairControllerPS, LocKey#17884)
  @default(NetworkAreaControllerPS, DBGNetworkName)
  @default(OdaCementBagControllerPS, LocKey#17265)
  @default(PachinkoMachineControllerPS, LocKey#172)
  @default(ProximityDetectorControllerPS, Gameplay-Devices-DisplayNames-LaserDetector)
  @default(RadioControllerPS, LocKey#96)
  @default(RetractableAdControllerPS, LocKey#196)
  @default(RoadBlockControllerPS, LocKey#126)
  @default(SecurityAlarmControllerPS, LocKey#109)
  @default(SecurityGateControllerPS, Gameplay-Devices-DisplayNames-Terminal)
  @default(SecurityLockerControllerPS, LocKey#122)
  @default(SecuritySystemControllerPS, LocKey#50988)
  @default(SecuritySystemUIPS, LocKey#50988)
  @default(SecurityTurretControllerPS, LocKey#121)
  @default(SensorDeviceControllerPS, Sensor Device)
  @default(SimpleSwitchControllerPS, LocKey#115)
  @default(SlidingLadderControllerPS, LocKey#2128)
  @default(SmartHouseControllerPS, LocKey#15648)
  @default(SmartWindowControllerPS, LocKey#110)
  @default(SmokeMachineControllerPS, LocKey#146)
  @default(SpeakerControllerPS, LocKey#166)
  @default(SurveillanceCameraControllerPS, LocKey#100)
  @default(SurveillanceSystemControllerPS, LocKey#50770)
  @default(SurveillanceSystemUIPS, LocKey#50770)
  @default(TVControllerPS, LocKey#97)
  @default(TerminalControllerPS, LocKey#112)
  @default(TrafficIntersectionManagerControllerPS, Traffic Intersection Manager)
  @default(TrafficLightControllerPS, LocKey#127)
  @default(TrafficZebraControllerPS, Gameplay-Devices-DisplayNames-Zebra)
  @default(VendingMachineControllerPS, LocKey#176)
  @default(VentilationAreaControllerPS, VentilationArea)
  @default(VirtualSystemPS, SYSTEM)
  @default(WeakFenceControllerPS, LocKey#189)
  @default(WeaponVendingMachineControllerPS, LocKey#17883)
  @default(WindowBlindersControllerPS, LocKey#104)
  @default(WindowControllerPS, LocKey#78)
  protected let m_deviceName: String;

  protected persistent let m_activationState: EActivationState;

  @attrib(category, "Devices Grid")
  @default(AOEAreaControllerPS, false)
  @default(AOEEffectorControllerPS, false)
  @default(AccessPointControllerPS, false)
  @default(ActionsSequencerControllerPS, false)
  @default(ActivatorControllerPS, false)
  @default(CommunityProxyPS, false)
  @default(FuseControllerPS, false)
  @default(NetworkAreaControllerPS, false)
  @default(ScriptableDeviceComponentPS, false)
  @default(SecurityAreaControllerPS, false)
  @default(SecuritySystemControllerPS, false)
  @default(VentilationAreaControllerPS, false)
  @default(VentilationEffectorControllerPS, false)
  protected persistent let m_drawGridLink: Bool;

  @attrib(category, "Devices Grid")
  protected let m_isLinkDynamic: Bool;

  @attrib(category, "Devices Grid")
  @default(ScriptableDeviceComponentPS, true)
  protected let m_fullDepth: Bool;

  @attrib(category, "Devices Grid")
  @attrib(customEditor, "TweakDBGroupInheritance;VirtualNetwork")
  public let m_virtualNetworkShapeID: TweakDBID;

  @attrib(unsavable, "true")
  @attrib(customEditor, "TweakDBGroupInheritance;Device")
  @default(AOEAreaControllerPS, Devices.AOE_Area)
  @default(AOEEffectorControllerPS, Devices.AOE_Effector)
  @default(AccessPointControllerPS, Devices.AccessPoint)
  @default(ActivatedDeviceControllerPS, Devices.ActivatedDeviceTrap)
  @default(ActivatorControllerPS, Devices.Activator)
  @default(ApartmentScreenControllerPS, Devices.LcdScreen)
  @default(ArcadeMachineControllerPS, Devices.ArcadeMachine)
  @default(BaseDestructibleControllerPS, Devices.TrafficLight)
  @default(BasicDistractionDeviceControllerPS, Devices.BaseDistractor)
  @default(BillboardDeviceControllerPS, Devices.Billboard)
  @default(BlindingLightControllerPS, Devices.MetroLights)
  @default(C4ControllerPS, Devices.C4)
  @default(CandleControllerPS, Devices.Candle)
  @default(ChestPressControllerPS, Devices.ChestPress)
  @default(CleaningMachineControllerPS, Devices.CleaningMachine)
  @default(ComputerControllerPS, Devices.Computer)
  @default(ConfessionBoothControllerPS, Devices.ConfessionBooth)
  @default(CrossingLightControllerPS, Devices.CrossingLight)
  @default(DataTermControllerPS, Devices.DataTerm)
  @default(DestructibleMasterLightControllerPS, Devices.ElectricLight)
  @default(DisplayGlassControllerPS, Devices.DisplayGlass)
  @default(DisposalDeviceControllerPS, Devices.DisposalDevice)
  @default(DoorControllerPS, Devices.Door)
  @default(DoorSystemControllerPS, Devices.DoorSystem)
  @default(ElectricLightControllerPS, Devices.ElectricLight)
  @default(ElevatorFloorTerminalControllerPS, Devices.ElevatorFloorTerminal)
  @default(ExplosiveDeviceControllerPS, Devices.ExplosiveDevice)
  @default(ExplosiveTriggerDeviceControllerPS, Devices.ExplosiveDevice)
  @default(FanControllerPS, Devices.Fan)
  @default(ForkliftControllerPS, Devices.Forklift)
  @default(FridgeControllerPS, Devices.Fridge)
  @default(FuseBoxControllerPS, Devices.FuseBox)
  @default(FuseControllerPS, Devices.Fuse)
  @default(GenericDeviceControllerPS, Devices.GenericDevice)
  @default(GlitchedTurretControllerPS, Devices.SecurityTurret)
  @default(HoloDeviceControllerPS, Devices.HoloDevice)
  @default(HoloFeederControllerPS, Devices.HoloFeeder)
  @default(HoloTableControllerPS, Devices.HoloTable)
  @default(IceMachineControllerPS, Devices.IceMachine)
  @default(InteractiveAdControllerPS, Devices.InteractiveAd)
  @default(IntercomControllerPS, Devices.Intercom)
  @default(JukeboxControllerPS, Devices.Jukebox)
  @default(LadderControllerPS, Devices.Ladder)
  @default(LcdScreenControllerPS, Devices.LcdScreen)
  @default(LiftControllerPS, Devices.LiftDevice)
  @default(MovableDeviceControllerPS, Devices.MovableDevice)
  @default(MovableWallScreenControllerPS, Devices.HoloFeeder)
  @default(NcartTimetableControllerPS, Devices.NcartTimetable)
  @default(NetrunnerChairControllerPS, Devices.NetrunnerChair)
  @default(OdaCementBagControllerPS, Devices.CementContainer)
  @default(PachinkoMachineControllerPS, Devices.PachinkoMachine)
  @default(PersonnelSystemControllerPS, Devices.PersonnelSystem)
  @default(RadioControllerPS, Devices.Radio)
  @default(RetractableAdControllerPS, Devices.RoadBlock)
  @default(RoadBlockControllerPS, Devices.RoadBlock)
  @default(ScriptableDeviceComponentPS, Devices.GenericDevice)
  @default(SecurityAlarmControllerPS, Devices.SecurityAlarm)
  @default(SecurityAreaControllerPS, Devices.SecurityArea)
  @default(SecuritySystemControllerPS, Devices.SecuritySystem)
  @default(SecurityTurretControllerPS, Devices.SecurityTurret)
  @default(SimpleSwitchControllerPS, Devices.SimpleSwitch)
  @default(SlidingLadderControllerPS, Devices.SlidingLadder)
  @default(SmartHouseControllerPS, Devices.SmartHouse)
  @default(SmartWindowControllerPS, Devices.SmartWindow)
  @default(SmokeMachineControllerPS, Devices.SmokeMachine)
  @default(SpeakerControllerPS, Devices.Speaker)
  @default(SurveillanceCameraControllerPS, Devices.SurveillanceCamera)
  @default(SurveillanceSystemControllerPS, Devices.SurveillanceSystem)
  @default(TVControllerPS, Devices.TV)
  @default(TerminalControllerPS, Devices.Terminal)
  @default(TrafficIntersectionManagerControllerPS, Devices.TrafficIntersectionManager)
  @default(TrafficLightControllerPS, Devices.TrafficLight)
  @default(VendingMachineControllerPS, Devices.VendingMachine)
  @default(VendingTerminalControllerPS, Devices.VendingTerminal)
  @default(VentilationAreaControllerPS, Devices.VentilationArea)
  @default(VentilationEffectorControllerPS, Devices.VentilationEffector)
  @default(WallScreenControllerPS, Devices.WallScreen)
  @default(WeakFenceControllerPS, Devices.WeakFence)
  @default(WeaponVendingMachineControllerPS, Devices.WeaponVendingMachine)
  @default(WindowBlindersControllerPS, Devices.WindowBlinders)
  @default(WindowControllerPS, Devices.Window)
  protected persistent let m_tweakDBRecord: TweakDBID;

  @default(AOEAreaControllerPS, device_descriptions.AOE_Area)
  @default(AOEEffectorControllerPS, device_descriptions.AOE_Effector)
  @default(AccessPointControllerPS, device_descriptions.AccessPoint)
  @default(ActivatedDeviceControllerPS, device_descriptions.ActivatedDeviceTrap)
  @default(ActivatorControllerPS, device_descriptions.Activator)
  @default(ApartmentScreenControllerPS, device_descriptions.LcdScreen)
  @default(ArcadeMachineControllerPS, device_descriptions.ArcadeMachine)
  @default(BaseDestructibleControllerPS, device_descriptions.TrafficLight)
  @default(BasicDistractionDeviceControllerPS, device_descriptions.BaseDistractor)
  @default(BillboardDeviceControllerPS, device_descriptions.Billboard)
  @default(BlindingLightControllerPS, device_descriptions.MetroLights)
  @default(C4ControllerPS, device_descriptions.C4)
  @default(CandleControllerPS, device_descriptions.Candle)
  @default(ChestPressControllerPS, device_descriptions.ChestPress)
  @default(CleaningMachineControllerPS, device_descriptions.CleaningMachine)
  @default(ComputerControllerPS, device_descriptions.Computer)
  @default(ConfessionBoothControllerPS, device_descriptions.ConfessionBooth)
  @default(CrossingLightControllerPS, device_descriptions.CrossingLight)
  @default(DataTermControllerPS, device_descriptions.DataTerm)
  @default(DestructibleMasterLightControllerPS, device_descriptions.ElectricLight)
  @default(DisplayGlassControllerPS, device_descriptions.DisplayGlass)
  @default(DisposalDeviceControllerPS, device_descriptions.DisposalDevice)
  @default(DoorControllerPS, device_descriptions.Door)
  @default(DoorSystemControllerPS, device_descriptions.DoorSystem)
  @default(ElectricLightControllerPS, device_descriptions.ElectricLight)
  @default(ElevatorFloorTerminalControllerPS, device_descriptions.ElevatorFloorTerminal)
  @default(ExplosiveDeviceControllerPS, device_descriptions.ExplosiveDevice)
  @default(ExplosiveTriggerDeviceControllerPS, device_descriptions.ExplosiveDevice)
  @default(FanControllerPS, device_descriptions.Fan)
  @default(ForkliftControllerPS, device_descriptions.Forklift)
  @default(FridgeControllerPS, device_descriptions.Fridge)
  @default(FuseBoxControllerPS, device_descriptions.FuseBox)
  @default(FuseControllerPS, device_descriptions.Fuse)
  @default(GenericDeviceControllerPS, device_descriptions.GenericDevice)
  @default(GlitchedTurretControllerPS, device_descriptions.SecurityTurret)
  @default(HoloDeviceControllerPS, device_descriptions.HoloDevice)
  @default(HoloFeederControllerPS, device_descriptions.HoloFeeder)
  @default(HoloTableControllerPS, device_descriptions.HoloTable)
  @default(IceMachineControllerPS, device_descriptions.IceMachine)
  @default(InteractiveAdControllerPS, device_descriptions.InteractiveAd)
  @default(IntercomControllerPS, device_descriptions.Intercom)
  @default(JukeboxControllerPS, device_descriptions.Jukebox)
  @default(LadderControllerPS, device_descriptions.Ladder)
  @default(LcdScreenControllerPS, device_descriptions.LcdScreen)
  @default(LiftControllerPS, device_descriptions.LiftDevice)
  @default(MovableDeviceControllerPS, device_descriptions.MovableDevice)
  @default(MovableWallScreenControllerPS, device_descriptions.HoloFeeder)
  @default(NcartTimetableControllerPS, device_descriptions.NcartTimetable)
  @default(NetrunnerChairControllerPS, device_descriptions.NetrunnerChair)
  @default(OdaCementBagControllerPS, device_descriptions.CementContainer)
  @default(PachinkoMachineControllerPS, device_descriptions.PachinkoMachine)
  @default(PersonnelSystemControllerPS, device_descriptions.PersonnelSystem)
  @default(RadioControllerPS, device_descriptions.Radio)
  @default(RetractableAdControllerPS, device_descriptions.RoadBlock)
  @default(RoadBlockControllerPS, device_descriptions.RoadBlock)
  @default(SecurityAlarmControllerPS, device_descriptions.SecurityAlarm)
  @default(SecurityAreaControllerPS, device_descriptions.SecurityArea)
  @default(SecuritySystemControllerPS, device_descriptions.SecuritySystem)
  @default(SecurityTurretControllerPS, device_descriptions.SecurityTurret)
  @default(SimpleSwitchControllerPS, device_descriptions.SimpleSwitch)
  @default(SlidingLadderControllerPS, device_descriptions.SlidingLadder)
  @default(SmartHouseControllerPS, device_descriptions.SmartHouse)
  @default(SmartWindowControllerPS, device_descriptions.SmartWindow)
  @default(SmokeMachineControllerPS, device_descriptions.SmokeMachine)
  @default(SpeakerControllerPS, device_descriptions.Speaker)
  @default(SurveillanceCameraControllerPS, device_descriptions.SurveillanceCamera)
  @default(SurveillanceSystemControllerPS, device_descriptions.SurveillanceSystem)
  @default(TVControllerPS, device_descriptions.TV)
  @default(TerminalControllerPS, device_descriptions.Terminal)
  @default(TrafficIntersectionManagerControllerPS, device_descriptions.TrafficIntersectionManager)
  @default(TrafficLightControllerPS, device_descriptions.TrafficLight)
  @default(VendingMachineControllerPS, device_descriptions.VendingMachine)
  @default(VendingTerminalControllerPS, device_descriptions.VendingTerminal)
  @default(VentilationAreaControllerPS, device_descriptions.VentilationArea)
  @default(VentilationEffectorControllerPS, device_descriptions.VentilationEffector)
  @default(WallScreenControllerPS, device_descriptions.WallScreen)
  @default(WeakFenceControllerPS, device_descriptions.WeakFence)
  @default(WeaponVendingMachineControllerPS, device_descriptions.WeaponVendingMachine)
  @default(WindowBlindersControllerPS, device_descriptions.WindowBlinders)
  @default(WindowControllerPS, device_descriptions.Window)
  protected let m_tweakDBDescriptionRecord: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;DeviceContentAssignment")
  protected let m_contentScale: TweakDBID;

  protected persistent let m_skillCheckContainer: ref<BaseSkillCheckContainer>;

  @attrib(category, "UI Zoom / Fullscreen")
  @default(ComputerControllerPS, true)
  @default(TerminalControllerPS, false)
  protected edit let m_hasUICameraZoom: Bool;

  @attrib(category, "UI Zoom / Fullscreen")
  protected edit let m_allowUICameraZoomDynamicSwitch: Bool;

  @attrib(category, "UI Zoom / Fullscreen")
  protected edit let m_hasFullScreenUI: Bool;

  @default(ApartmentScreenControllerPS, true)
  @default(ArcadeMachineControllerPS, true)
  @default(ComputerControllerPS, true)
  @default(ConfessionBoothControllerPS, true)
  @default(LcdScreenControllerPS, true)
  @default(NcartTimetableControllerPS, true)
  @default(ScriptableDeviceComponentPS, true)
  @default(TVControllerPS, true)
  @default(TerminalControllerPS, true)
  protected let m_hasAuthorizationModule: Bool;

  @default(AccessPointControllerPS, true)
  @default(ScriptableDeviceComponentPS, false)
  protected let m_hasPersonalLinkSlot: Bool;

  @attrib(category, "Backdoor Properties")
  @default(ScriptableDeviceComponentPS, EGameplayChallengeLevel.EASY)
  protected let m_backdoorBreachDifficulty: EGameplayChallengeLevel;

  @attrib(category, "Backdoor Properties")
  protected let m_shouldSkipNetrunnerMinigame: Bool;

  @attrib(unsavable, "true")
  @attrib(category, "Backdoor Properties")
  @attrib(customEditor, "TweakDBGroupInheritance;Minigame_Def")
  @attrib(tooltip, "Specifies what kind of minigame will be forced on the player")
  protected persistent let m_minigameDefinition: TweakDBID;

  @default(ScriptableDeviceComponentPS, 1)
  protected persistent let m_minigameAttempt: Int32;

  protected persistent let m_hackingMinigameState: HackingMinigameState;

  @attrib(category, "Quest")
  @attrib(tooltip, "IMPORTANT!: If this is set to true. Player will not be disconnected from the personal link automatically. Make sure if QuestForcePersonalLinkDisconnect action is necessary or not ")
  protected let m_disablePersonalLinkAutoDisconnect: Bool;

  @default(ScriptableDeviceComponentPS, false)
  protected let m_canHandleAdvancedInteraction: Bool;

  @default(ScriptableDeviceComponentPS, false)
  protected let m_canBeTrapped: Bool;

  protected persistent let m_disassembleProperties: DisassembleOptions;

  protected persistent let m_flatheadScavengeProperties: SpiderbotScavengeOptions;

  protected persistent let m_destructionProperties: DestructionData;

  @default(ScriptableDeviceComponentPS, false)
  @default(SecurityTurretControllerPS, true)
  @default(SensorDeviceControllerPS, true)
  @default(SurveillanceCameraControllerPS, true)
  protected let m_canPlayerTakeOverControl: Bool;

  @default(ScriptableDeviceComponentPS, false)
  @default(SurveillanceCameraControllerPS, true)
  protected let m_canBeInDeviceChain: Bool;

  @attrib(category, "Quest")
  @attrib(tooltip, "IMPORTANT!: IF TRUE > Connect Personal Link interaction will show up regardless of whether it's viable or sensible from gameplay POV. Use cautiously.")
  protected persistent let m_personalLinkForced: Bool;

  @attrib(category, "Quest")
  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.None")
  @attrib(tooltip, "IMPORTANT!: IF SET UP > This device is treated as if Personal Link Forced was set to true as well.")
  protected persistent let m_personalLinkCustomInteraction: TweakDBID;

  @default(ScriptableDeviceComponentPS, EPersonalLinkConnectionStatus.NOT_CONNECTED)
  protected let m_personalLinkStatus: EPersonalLinkConnectionStatus;

  @default(ScriptableDeviceComponentPS, false)
  protected let m_isAdvancedInteractionModeOn: Bool;

  protected persistent let m_juryrigTrapState: EJuryrigTrapState;

  protected persistent let m_isControlledByThePlayer: Bool;

  private let m_isHighlightedInFocusMode: Bool;

  protected persistent let m_wasQuickHacked: Bool;

  protected let m_wasQuickHackAttempt: Bool;

  protected let m_lastPerformedQuickHack: CName;

  protected let m_isGlitching: Bool;

  protected persistent let m_isRestarting: Bool;

  protected persistent let m_blockSecurityWakeUp: Bool;

  protected let m_isLockedViaSequencer: Bool;

  protected let m_distractExecuted: Bool;

  protected let m_distractionTimeCompleted: Bool;

  @attrib(category, "NPC workspot")
  protected edit let m_hasNPCWorkspotKillInteraction: Bool;

  @attrib(category, "NPC workspot")
  protected edit let m_shouldNPCWorkspotFinishLoop: Bool;

  protected persistent let m_durabilityState: EDeviceDurabilityState;

  protected persistent let m_hasBeenScavenged: Bool;

  protected persistent let m_currentlyAuthorizedUsers: array<SecuritySystemClearanceEntry>;

  protected persistent let m_performedActions: array<SPerformedActions>;

  protected persistent let m_isInitialStateOperationPerformed: Bool;

  protected persistent let m_illegalActions: IllegalActionTypes;

  @attrib(category, "Quest")
  @default(LcdScreenControllerPS, true)
  @default(LiftControllerPS, true)
  protected persistent let m_disableQuickHacks: Bool;

  private let m_availableQuickHacks: array<CName>;

  protected let m_isKeyloggerInstalled: Bool;

  private let m_actionsWithDisabledRPGChecks: array<TweakDBID>;

  private let m_availableSpiderbotActions: array<CName>;

  protected let m_currentSpiderbotActionPerformed: ref<ScriptableDeviceAction>;

  protected persistent let m_isSpiderbotInteractionOrdered: Bool;

  @attrib(category, "Device Scanner Options")
  @default(DisposalDeviceControllerPS, false)
  @default(ExplosiveDeviceControllerPS, false)
  @default(LadderControllerPS, false)
  @default(MovableDeviceControllerPS, false)
  @default(ScriptableDeviceComponentPS, true)
  @default(SensorDeviceControllerPS, true)
  @default(SlidingLadderControllerPS, false)
  @default(StashControllerPS, false)
  @default(WeakFenceControllerPS, false)
  protected let m_shouldScannerShowStatus: Bool;

  @attrib(category, "Device Scanner Options")
  @default(AccessPointControllerPS, false)
  @default(DisposalDeviceControllerPS, false)
  @default(ExplosiveDeviceControllerPS, false)
  @default(MovableDeviceControllerPS, false)
  @default(ScriptableDeviceComponentPS, true)
  @default(StashControllerPS, false)
  @default(WeakFenceControllerPS, false)
  protected let m_shouldScannerShowNetwork: Bool;

  @attrib(category, "Device Scanner Options")
  @default(SensorDeviceControllerPS, true)
  @default(StashControllerPS, false)
  protected let m_shouldScannerShowAttitude: Bool;

  @attrib(category, "Device Scanner Options")
  @default(ActivatedDeviceControllerPS, true)
  @default(DisposalDeviceControllerPS, true)
  @default(MovableDeviceControllerPS, true)
  @default(WeakFenceControllerPS, true)
  protected let m_shouldScannerShowRole: Bool;

  @attrib(category, "Device Scanner Options")
  @default(ExplosiveDeviceControllerPS, true)
  @default(SensorDeviceControllerPS, true)
  @default(StashControllerPS, false)
  protected let m_shouldScannerShowHealth: Bool;

  @attrib(category, "Device Debug Properties")
  @attrib(tooltip, "If this is on and someone used DebugDevices console command, only logs from this device will be shown")
  protected persistent let m_debugDevice: Bool;

  @attrib(category, "Device Debug Properties")
  protected persistent let m_debugName: CName;

  @attrib(category, "Device Debug Properties")
  protected let m_debugExposeQuickHacks: Bool;

  @attrib(unsavable, "true")
  protected persistent let m_debugPath: CName;

  @attrib(unsavable, "true")
  protected persistent let m_debugID: Uint32;

  @attrib(category, "Device Operations")
  protected inline persistent let m_deviceOperationsSetup: ref<DeviceOperationsContainer>;

  @attrib(category, "Connection Highlight Obejcts")
  protected persistent const let m_connectionHighlightObjects: array<NodeRef>;

  private let m_activeContexts: array<gamedeviceRequestType>;

  private let m_playstyles: array<EPlaystyle>;

  private let m_quickHackVulnerabilties: array<TweakDBID>;

  private let m_quickHackVulnerabiltiesInitialized: Bool;

  private let m_willingInvestigators: array<EntityID>;

  @default(ScriptableDeviceComponentPS, true)
  protected persistent let m_isInteractive: Bool;

  protected cb func OnInstantiated() -> Bool {
    if !IsFinal() {
      this.m_debugPath = StringToName(StrAfterLast(EntityID.ToDebugString(PersistentID.ExtractEntityID(this.GetID())), "/"));
      this.m_debugID = EntityID.GetHash(PersistentID.ExtractEntityID(this.GetID()));
    };
    if !this.IsInitialized() {
      this.Initialize();
    };
  }

  public const func GetParents(out outDevices: array<ref<DeviceComponentPS>>) -> Void {
    let i: Int32;
    if this.m_mastersCached {
      i = 0;
      while i < ArraySize(this.m_masters) {
        ArrayPush(outDevices, this.m_masters[i]);
        i += 1;
      };
      return;
    };
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetParents(this.GetMyEntityID(), outDevices);
  }

  public const func GetImmediateParents() -> array<ref<DeviceComponentPS>> {
    let masters: array<ref<DeviceComponentPS>>;
    if this.m_mastersCached {
      return this.m_masters;
    };
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetParents(this.GetMyEntityID(), masters);
    return masters;
  }

  protected func Initialize() -> Void {
    this.m_isInitialized = true;
    if !IsFinal() {
      this.m_debugPath = StringToName(StrAfterLast(EntityID.ToDebugString(PersistentID.ExtractEntityID(this.GetID())), "/"));
      this.m_debugID = EntityID.GetHash(PersistentID.ExtractEntityID(this.GetID()));
    };
  }

  public final func OnGameAttached(evt: ref<GameAttachedEvent>) -> EntityNotificationType {
    let defaultTDBID: TweakDBID;
    this.CacheDevices();
    if !this.IsInitialized() {
      this.Initialize();
    };
    if TDBID.IsValid(this.m_personalLinkCustomInteraction) {
      defaultTDBID = t"Interactions.None";
      if this.m_personalLinkCustomInteraction != defaultTDBID {
        this.m_personalLinkForced = true;
        this.m_disablePersonalLinkAutoDisconnect = true;
      };
    };
    this.m_isAttachedToGame = true;
    if IsStringValid(evt.displayName) {
      this.m_deviceName = evt.displayName;
    };
    if evt.isGameplayRelevant {
      if TDBID.IsValid(evt.contentScale) {
        this.m_contentScale = evt.contentScale;
      };
      this.InitializeRPGParams();
      this.DetermineInitialPlaystyle();
    };
    this.GameAttached();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnLogicReady(evt: ref<SetLogicReadyEvent>) -> EntityNotificationType {
    this.m_isLogicReady = evt.isReady;
    this.LogicReady();
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void;

  protected func SetDeviceState(state: EDeviceStatus) -> Void {
    let removeFromChain: ref<RemoveFromChainRequest>;
    if this.CanBeInDeviceChain() && EnumInt(state) <= EnumInt(EDeviceStatus.UNPOWERED) {
      removeFromChain = new RemoveFromChainRequest();
      removeFromChain.requestSource = this.GetMyEntityID();
      this.GetTakeOverControlSystem().QueueRequest(removeFromChain);
    };
    this.SetDeviceState(state);
  }

  protected func OnDeviceDynamicConnectionChange(evt: ref<DeviceDynamicConnectionChange>) -> EntityNotificationType {
    this.m_mastersCached = false;
    this.CacheDevices();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func CacheDevices() -> Void {
    if !this.m_mastersCached {
      GameInstance.GetDeviceSystem(this.GetGameInstance()).GetParents(this.GetMyEntityID(), this.m_masters);
      this.m_mastersCached = true;
    };
  }

  protected final func InitializeRPGParams() -> Void {
    this.InitializeContentScale();
    this.InitializeStats();
    this.InitializeStatPools();
  }

  protected final func InitializeContentScale() -> Void {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let powerLevelMod: ref<gameConstantStatModifierData> = new gameConstantStatModifierData();
    powerLevelMod.modifierType = gameStatModifierType.Additive;
    powerLevelMod.statType = gamedataStatType.PowerLevel;
    powerLevelMod.value = Cast(GameInstance.GetLevelAssignmentSystem(this.GetGameInstance()).GetLevelAssignment(this.m_contentScale));
    statSystem.AddModifier(Cast(this.GetMyEntityID()), powerLevelMod);
  }

  protected final func InitializeStats() -> Void {
    let i: Int32;
    let statList: array<wref<StatModifier_Record>>;
    let statModifiers: array<ref<gameStatModifierData>>;
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let record: ref<Device_Record> = TweakDBInterface.GetDeviceRecord(this.GetTweakDBRecord());
    if IsDefined(record) {
      record.StatModifiers(statList);
      ArrayResize(statModifiers, ArraySize(statList));
      i = 0;
      while i < ArraySize(statList) {
        statModifiers[i] = RPGManager.StatRecordToModifier(statList[i]);
        i += 1;
      };
      statSystem.AddModifiers(Cast(this.GetMyEntityID()), statModifiers);
    };
  }

  protected final func InitializeStatPools() -> Void {
    let i: Int32;
    let statPools: array<wref<StatPool_Record>>;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGameInstance());
    let record: ref<Device_Record> = TweakDBInterface.GetDeviceRecord(this.GetTweakDBRecord());
    if IsDefined(record) {
      record.StatPools(statPools);
      i = 0;
      while i < ArraySize(statPools) {
        statPoolsSystem.RequestAddingStatPool(Cast(this.GetMyEntityID()), statPools[i].GetID());
        i += 1;
      };
    };
  }

  protected final func InitializeSkillChecks(container: ref<BaseSkillCheckContainer>) -> Void {
    if this.m_skillCheckContainer == null {
      this.m_skillCheckContainer = container;
    };
    if IsDefined(this.m_skillCheckContainer) {
      this.m_skillCheckContainer.Initialize(container);
      if IsDefined(this.m_skillCheckContainer.GetHackingSlot()) {
        this.m_skillCheckContainer.GetHackingSlot().SetDuration(1.00);
      };
    };
    this.InitializeBackdoorSkillcheck();
  }

  public final const func IsInitialized() -> Bool {
    return this.m_isInitialized;
  }

  public final const func ForceResolveGameplayStateOnAttach() -> Bool {
    return this.m_forceResolveStateOnAttach;
  }

  public final const func ForceVisibilityInAnimSystemOnLogicReady() -> Bool {
    return this.m_forceVisibilityInAnimSystemOnLogicReady;
  }

  public const func GetDeviceName() -> String {
    return this.m_deviceName;
  }

  public final const func GetTweakDBRecord() -> TweakDBID {
    return this.m_tweakDBRecord;
  }

  public final const func GetTweakDBDescriptionRecord() -> TweakDBID {
    return this.m_tweakDBDescriptionRecord;
  }

  public final const func GetContentAssignmentID() -> TweakDBID {
    return this.m_contentScale;
  }

  public const func IsConnectedToSystem() -> Bool {
    let ancestors: array<ref<DeviceComponentPS>>;
    let i: Int32;
    this.GetAncestors(ancestors);
    i = 0;
    while i < ArraySize(ancestors) {
      if IsDefined(ancestors[i] as DeviceSystemBaseControllerPS) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public const func IsPartOfSystem(systemType: ESystems) -> Bool {
    switch systemType {
      case ESystems.SecuritySystem:
        return this.IsConnectedToSecuritySystem();
      case ESystems.MaintenanceSystem:
        return this.IsConnectedToMaintenanceSystem();
      case ESystems.AccessPoints:
        return this.IsConnectedToBackdoorDevice();
    };
  }

  public final const func GetDurabilityState() -> EDeviceDurabilityState {
    return this.m_durabilityState;
  }

  public final const func GetActivationState() -> EActivationState {
    return this.m_activationState;
  }

  public final const func HasAdvancedInteractions() -> Bool {
    return this.m_canHandleAdvancedInteraction;
  }

  public final const func CanBeTrapped() -> Bool {
    return this.m_canBeTrapped;
  }

  public final const quest func CanBeDisassembled() -> Bool {
    return this.m_disassembleProperties.m_canBeDisassembled;
  }

  public final const quest func CanBeFixed() -> Bool {
    return this.m_destructionProperties.m_canBeFixed;
  }

  public final const func GetDurabilityType() -> EDeviceDurabilityType {
    return this.m_destructionProperties.m_durabilityType;
  }

  public final const func HasPersonalLinkSlot() -> Bool {
    return this.m_hasPersonalLinkSlot;
  }

  public final const func CanBeScavengedBySpiderbot() -> Bool {
    return this.m_flatheadScavengeProperties.m_scavengableBySpiderbot;
  }

  public final const func HasQuickHacksDisabled() -> Bool {
    return this.m_disableQuickHacks;
  }

  public const func GetMinigameDefinition() -> TweakDBID {
    let ap: ref<AccessPointControllerPS>;
    if TDBID.IsValid(this.m_minigameDefinition) {
      return this.m_minigameDefinition;
    };
    ap = this.GetBackdoorAccessPoint();
    if IsDefined(ap) {
      return ap.GetMinigameDefinition();
    };
    return this.m_minigameDefinition;
  }

  public final const func OnQuestMinigameRequest() -> Void {
    let minigameID: TweakDBID = this.GetMinigameDefinition();
    if !TDBID.IsValid(minigameID) {
      minigameID = t"minigame_v2.DefaultItemMinigame";
    };
    this.GetNetworkBlackboard().SetVariant(this.GetNetworkBlackboardDef().MinigameDef, ToVariant(minigameID));
  }

  protected const func ShouldExposePersonalLinkAction() -> Bool {
    if TDBID.IsValid(this.m_personalLinkCustomInteraction) && (this.IsPersonalLinkConnected() || this.IsPersonalLinkConnecting()) {
      return false;
    };
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED) || Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING) || this.m_personalLinkForced {
      return true;
    };
    if this.IsHackingSkillCheckActive() {
      return false;
    };
    if this.IsGlitching() || this.IsDistracting() {
      return false;
    };
    if this.HasNetworkBackdoor() {
      return !this.WasHackingMinigameSucceeded();
    };
    return false;
  }

  public final func SetHasPersonalLinkSlot(isPersonalLinkSlotPresent: Bool) -> Void {
    this.m_hasPersonalLinkSlot = isPersonalLinkSlotPresent;
  }

  public final func SetHasUICameraZoom(hasUICameraZoom: Bool) -> Void {
    this.m_hasUICameraZoom = hasUICameraZoom;
  }

  public final func ToggleInteractivity(isInteractive: Bool) -> Void {
    this.m_isInteractive = isInteractive;
  }

  public const func IsInteractive() -> Bool {
    return this.m_isInteractive;
  }

  public final const quest func IsAdvancedInteractionModeOn() -> Bool {
    return this.m_isAdvancedInteractionModeOn;
  }

  public final const quest func IsAdvancedInteractionModeOff() -> Bool {
    return !this.IsAdvancedInteractionModeOn();
  }

  public final const func GetPersonalLinkStatus() -> EPersonalLinkConnectionStatus {
    return this.m_personalLinkStatus;
  }

  public final const quest func IsPersonalLinkConnected() -> Bool {
    return Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED);
  }

  public final const quest func IsPersonalLinkConnecting() -> Bool {
    return Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING);
  }

  public final const quest func IsPersonalLinkDisconnected() -> Bool {
    return Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) || Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING);
  }

  public final const func IsSecurityWakeUpBlocked() -> Bool {
    return this.m_blockSecurityWakeUp;
  }

  public final const func HasUICameraZoom() -> Bool {
    return this.m_hasUICameraZoom;
  }

  public final const func AllowsUICameraZoomDynamicSwitch() -> Bool {
    return this.m_allowUICameraZoomDynamicSwitch;
  }

  public final const func HasFullScreenUI() -> Bool {
    return this.m_hasFullScreenUI;
  }

  public final const func IsHighlightedInFocusMode() -> Bool {
    return this.m_isHighlightedInFocusMode;
  }

  public final const func IsControlledByPlayer() -> Bool {
    return this.m_isControlledByThePlayer;
  }

  public final const func CanPlayerTakeOverControl() -> Bool {
    return this.m_canPlayerTakeOverControl;
  }

  public final const quest func IsRestarting() -> Bool {
    return this.m_isRestarting;
  }

  public final const func IsGlitching() -> Bool {
    return this.m_isGlitching;
  }

  public final const func IsDistracting() -> Bool {
    return this.m_distractExecuted;
  }

  public final const func IsActivated() -> Bool {
    if Equals(this.m_activationState, EActivationState.ACTIVATED) {
      return true;
    };
    return false;
  }

  public final const func GetActiveContexts() -> array<gamedeviceRequestType> {
    return this.m_activeContexts;
  }

  public final const func GetMinigameAttempt() -> Int32 {
    return this.m_minigameAttempt;
  }

  public final const func ShouldScannerShowStatus() -> Bool {
    return this.m_shouldScannerShowStatus;
  }

  public final const func ShouldScannerShowNetwork() -> Bool {
    return this.m_shouldScannerShowNetwork;
  }

  public final const func ShouldScannerShowAttitude() -> Bool {
    return this.m_shouldScannerShowAttitude;
  }

  public final const func ShouldScannerShowRole() -> Bool {
    return this.m_shouldScannerShowRole;
  }

  public final const func ShouldScannerShowHealth() -> Bool {
    return this.m_shouldScannerShowHealth;
  }

  public final const func CanBeInDeviceChain() -> Bool {
    return this.m_canBeInDeviceChain && this.IsPowered() && Equals(this.GetDurabilityState(), EDeviceDurabilityState.NOMINAL);
  }

  public const func ShouldShowExamineIntaraction() -> Bool {
    return this.HasUICameraZoom() && !this.m_isAdvancedInteractionModeOn && this.IsON() && !this.IsPersonalLinkConnected() && !this.IsPersonalLinkConnecting();
  }

  public final const quest func IsSpiderbotInteractionOrdered() -> Bool {
    return this.m_isSpiderbotInteractionOrdered;
  }

  protected final func OnSetIsSpiderbotInteractionOrderedEvent(evt: ref<SetIsSpiderbotInteractionOrderedEvent>) -> EntityNotificationType {
    this.m_isSpiderbotInteractionOrdered = evt.value;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const quest func IsInDirectInteractionRange() -> Bool {
    return this.HasActiveContext(gamedeviceRequestType.Direct);
  }

  public final const func HasActiveContext(context: gamedeviceRequestType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeContexts) {
      if Equals(this.m_activeContexts[i], context) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func HasPlaystyle(playstyle: EPlaystyle) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_playstyles) {
      if Equals(this.m_playstyles[i], playstyle) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetPlaystyles() -> array<EPlaystyle> {
    return this.m_playstyles;
  }

  public final const func HasAnyPlaystyle() -> Bool {
    return ArraySize(this.m_playstyles) > 0;
  }

  public final func PassDeviceName(deviceName: String, opt dbgDeviceName: CName) -> Void {
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = deviceName;
    };
  }

  public final func DisbaleRPGChecksForAction(actionID: TweakDBID) -> Void {
    if !this.IsActionRPGRequirementDisabled(actionID) {
      ArrayPush(this.m_actionsWithDisabledRPGChecks, actionID);
    };
  }

  public final func EnableRPGChecksForAction(actionID: TweakDBID) -> Void {
    let i: Int32 = ArraySize(this.m_actionsWithDisabledRPGChecks) - 1;
    while i >= 0 {
      if actionID == this.m_actionsWithDisabledRPGChecks[i] {
        ArrayErase(this.m_actionsWithDisabledRPGChecks, i);
      };
      i -= 1;
    };
  }

  public final const func HasAnyActionsWithDisabledRPGChecks() -> Bool {
    return ArraySize(this.m_actionsWithDisabledRPGChecks) > 0;
  }

  private final const func IsActionRPGRequirementDisabled(actionID: TweakDBID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_actionsWithDisabledRPGChecks) {
      if actionID == this.m_actionsWithDisabledRPGChecks[i] {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func SetGlitchingState(isGlitching: Bool) -> Void {
    this.m_isGlitching = isGlitching;
  }

  public final func AddActiveContext(context: gamedeviceRequestType) -> Void {
    if !this.HasActiveContext(context) {
      ArrayPush(this.m_activeContexts, context);
      this.RefreshPS();
    };
  }

  public final func OnAddActiveContext(evt: ref<AddActiveContextEvent>) -> EntityNotificationType {
    this.AddActiveContext(evt.context);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func RemoveActiveContext(context: gamedeviceRequestType) -> Void {
    let i: Int32 = ArraySize(this.m_activeContexts) - 1;
    while i >= 0 {
      if Equals(this.m_activeContexts[i], context) {
        ArrayErase(this.m_activeContexts, i);
        this.RefreshPS();
      } else {
        i -= 1;
      };
    };
  }

  public final func OnRemoveActiveContext(evt: ref<RemoveActiveContextEvent>) -> EntityNotificationType {
    this.RemoveActiveContext(evt.context);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func RefreshPS() -> Void {
    let evt: ref<PSRefreshEvent> = new PSRefreshEvent();
    this.QueuePSEvent(this, evt);
  }

  public final func OnPSRefreshEvent(evt: ref<PSRefreshEvent>) -> EntityNotificationType {
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func AddPlaystyle(playstyle: EPlaystyle) -> Void {
    if !this.HasPlaystyle(playstyle) {
      ArrayPush(this.m_playstyles, playstyle);
    };
  }

  public final func RemovePlaystyle(playstyle: EPlaystyle) -> Void {
    let i: Int32 = ArraySize(this.m_playstyles) - 1;
    while i >= 0 {
      if Equals(this.m_playstyles[i], playstyle) {
        ArrayErase(this.m_playstyles, i);
      } else {
        i -= 1;
      };
    };
  }

  public final func DetermineInitialPlaystyle() -> Void {
    if !this.m_disableQuickHacks && this.CanCreateAnyQuickHackActions() && (this.IsQuickHacksExposed() || this.IsConnectedToBackdoorDevice() || this.HasNetworkBackdoor()) {
      this.AddPlaystyle(EPlaystyle.NETRUNNER);
      this.UpdateQuickHackableState(true);
    } else {
      this.RemovePlaystyle(EPlaystyle.NETRUNNER);
      this.UpdateQuickHackableState(false);
    };
    if this.CanCreateAnySpiderbotActions() {
      this.AddPlaystyle(EPlaystyle.TECHIE);
    } else {
      this.RemovePlaystyle(EPlaystyle.TECHIE);
    };
    this.m_quickHackVulnerabiltiesInitialized = false;
  }

  protected func OnActionOverride(evt: ref<ActionOverride>) -> EntityNotificationType {
    this.QueuePSEvent(this, this.ActionSetDeviceOFF());
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func GetAllQuickHackVulnerabilities() -> array<TweakDBID> {
    this.InitializeQuickHackVulnerabilities();
    return this.m_quickHackVulnerabilties;
  }

  public final func GetActiveQuickHackVulnerabilities() -> array<TweakDBID> {
    let i: Int32;
    let returnValue: array<TweakDBID>;
    this.InitializeQuickHackVulnerabilities();
    i = 0;
    while i < ArraySize(this.m_quickHackVulnerabilties) {
      if this.CanPlayerUseQuickHackVulnerability(this.m_quickHackVulnerabilties[i]) {
        ArrayPush(returnValue, this.m_quickHackVulnerabilties[i]);
      };
      i += 1;
    };
    return returnValue;
  }

  public final func HasAnyActiveQuickHackVulnerabilities() -> Bool {
    let list: array<TweakDBID>;
    if !this.HasPlaystyle(EPlaystyle.NETRUNNER) {
      return false;
    };
    list = this.GetActiveQuickHackVulnerabilities();
    return ArraySize(list) > 0;
  }

  public final const func CanPlayerUseQuickHackVulnerability(data: TweakDBID) -> Bool {
    let objectActionRecord: ref<ObjectAction_Record>;
    let playerQhackList: array<TweakDBID> = RPGManager.GetPlayerQuickHackList(GetPlayer(this.GetGameInstance()));
    let i: Int32 = 0;
    while i < ArraySize(playerQhackList) {
      objectActionRecord = TweakDBInterface.GetObjectActionRecord(playerQhackList[i]);
      if IsDefined(objectActionRecord) && IsDefined(objectActionRecord.GameplayCategory()) && objectActionRecord.GameplayCategory().GetID() == data {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func InitializeQuickHackVulnerabilities() -> Void {
    let action: ref<ScriptableDeviceAction>;
    let actions: array<ref<DeviceAction>>;
    let categoryID: TweakDBID;
    let context: GetActionsContext;
    let i: Int32;
    if this.m_quickHackVulnerabiltiesInitialized {
      return;
    };
    ArrayClear(this.m_quickHackVulnerabilties);
    context = this.GenerateContext(gamedeviceRequestType.Remote, this.GetClearance(), this.GetPlayerMainObject(), PersistentID.ExtractEntityID(this.GetID()));
    context.ignoresRPG = true;
    this.GetQuickHackActions(actions, context);
    i = 0;
    while i < ArraySize(actions) {
      action = actions[i] as ScriptableDeviceAction;
      if IsDefined(action) {
        categoryID = action.GetGameplayCategoryID();
        if TDBID.IsValid(categoryID) {
          this.AddQuickHackVulnerability(categoryID);
        };
      };
      i += 1;
    };
    this.m_quickHackVulnerabiltiesInitialized = true;
  }

  public final const func HasQuickHackVulnerability(data: TweakDBID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_quickHackVulnerabilties) {
      if this.m_quickHackVulnerabilties[i] == data {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final const func HasHasQuickHackVulnerabilitiesInitialized() -> Bool {
    return this.m_quickHackVulnerabiltiesInitialized;
  }

  public final func AddQuickHackVulnerability(data: TweakDBID) -> Void {
    if !this.HasQuickHackVulnerability(data) {
      ArrayPush(this.m_quickHackVulnerabilties, data);
    };
  }

  public final func RemoveQuickHackVoulnerability(data: TweakDBID) -> Void {
    let i: Int32 = ArraySize(this.m_quickHackVulnerabilties) - 1;
    while i >= 0 {
      if this.m_quickHackVulnerabilties[i] == data {
        ArrayErase(this.m_quickHackVulnerabilties, i);
      } else {
        i -= 1;
      };
    };
  }

  private final func UpdateQuickHackableState(isQuickHackable: Bool) -> Void {
    let quickHackableEvent: ref<SetQuickHackableMask> = new SetQuickHackableMask();
    quickHackableEvent.isQuickHackable = isQuickHackable;
    this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), quickHackableEvent);
  }

  public final func SetPlayerTakeOverControl(canBeControlled: Bool) -> Void {
    this.m_canPlayerTakeOverControl = canBeControlled;
  }

  public final const func GetJuryrigTrapState() -> EJuryrigTrapState {
    return this.m_juryrigTrapState;
  }

  public final const quest func IsJuryrigTrapArmed() -> Bool {
    return Equals(this.m_juryrigTrapState, EJuryrigTrapState.ARMED);
  }

  public final const quest func IsJuryrigTrapUnarmed() -> Bool {
    return Equals(this.m_juryrigTrapState, EJuryrigTrapState.UNARMED);
  }

  public final const quest func IsJuryrigTrapTriggered() -> Bool {
    return Equals(this.m_juryrigTrapState, EJuryrigTrapState.TRIGGERED);
  }

  public final const quest func IsON() -> Bool {
    if Equals(this.m_deviceState, EDeviceStatus.ON) {
      return true;
    };
    return false;
  }

  public final const quest func IsOFF() -> Bool {
    if Equals(this.m_deviceState, EDeviceStatus.OFF) {
      return true;
    };
    return false;
  }

  public final const quest func IsEnabled() -> Bool {
    return !this.IsDisabled();
  }

  public final const quest func IsDisabled() -> Bool {
    if Equals(this.m_deviceState, EDeviceStatus.DISABLED) {
      return true;
    };
    return false;
  }

  public final const quest func IsPowered() -> Bool {
    if Equals(this.m_deviceState, EDeviceStatus.UNPOWERED) || Equals(this.m_deviceState, EDeviceStatus.DISABLED) {
      return false;
    };
    return true;
  }

  public final const quest func IsUnpowered() -> Bool {
    if !this.IsInitialized() {
      return false;
    };
    if Equals(this.m_deviceState, EDeviceStatus.UNPOWERED) {
      return true;
    };
    return false;
  }

  public const func GetDeviceStatus() -> String {
    return this.GetDeviceStatusAction().GetCurrentDisplayString();
  }

  public const func GetDeviceStatusAction() -> ref<BaseDeviceStatus> {
    return this.ActionDeviceStatus();
  }

  public final const func GetScannerStatusRecord() -> TweakDBID {
    return this.GetDeviceStatusAction().GetScannerStatusRecord();
  }

  public const func GetDeviceStatusTextData() -> ref<inkTextParams> {
    let textData: ref<inkTextParams> = new inkTextParams();
    textData.AddLocalizedString("TEXT_PRIMARY", this.GetDeviceStatus());
    return textData;
  }

  public final func GetActionByName(actionName: CName, opt entityID: EntityID) -> ref<DeviceAction> {
    let actions: array<ref<DeviceAction>>;
    let foundAction: ref<DeviceAction>;
    let i: Int32;
    this.GetActions(actions, this.GetTotalClearance(entityID));
    i = 0;
    while i < ArraySize(actions) {
      if Equals(actions[i].actionName, actionName) {
        foundAction = actions[i];
      } else {
        i += 1;
      };
    };
    return foundAction;
  }

  public final func GetActionByName(actionName: CName, context: GetActionsContext) -> ref<DeviceAction> {
    let actions: array<ref<DeviceAction>>;
    let foundAction: ref<DeviceAction>;
    let i: Int32;
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      if this.IsPowered() {
        this.GetQuickHackActions(actions, context);
      };
      this.GetSpiderbotActions(actions, context);
    } else {
      this.GetActions(actions, context);
    };
    i = 0;
    while i < ArraySize(actions) {
      if Equals(actions[i].actionName, actionName) {
        foundAction = actions[i];
      } else {
        i += 1;
      };
    };
    return foundAction;
  }

  public final func GetMinigameActionByName(actionName: CName, context: GetActionsContext) -> ref<DeviceAction> {
    let actions: array<ref<DeviceAction>>;
    let foundAction: ref<DeviceAction>;
    let i: Int32;
    this.GetMinigameActions(actions, context);
    i = 0;
    while i < ArraySize(actions) {
      if Equals(actions[i].actionName, actionName) {
        foundAction = actions[i];
      } else {
        i += 1;
      };
    };
    return foundAction;
  }

  protected final func GetTotalClearance(opt entityID: EntityID) -> GetActionsContext {
    let context: GetActionsContext;
    let emptyID: EntityID = new EntityID();
    context.clearance = Clearance.CreateClearance(0, 100);
    if EntityID.IsDefined(entityID) {
      context.requestorID = entityID;
    } else {
      context.requestorID = emptyID;
    };
    return context;
  }

  public final func GetTotalClearanceValue() -> ref<Clearance> {
    return Clearance.CreateClearance(0, 100);
  }

  protected final func GetCustomClearance(min: Int32, max: Int32) -> ref<Clearance> {
    let context: GetActionsContext;
    context.clearance = Clearance.CreateClearance(min, max);
    return context.clearance;
  }

  public const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(2, 5);
  }

  public final const func IsPlayerPerformingTakedown() -> Bool {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(GetPlayer(this.GetGameInstance()).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let playerStateDefault: Bool = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Default);
    return !playerStateDefault;
  }

  public final const func IsDisruptivePlayerStatusEffectPresent() -> Bool {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    return StatusEffectSystem.ObjectHasStatusEffectOfType(player, gamedataStatusEffectType.Stunned) || StatusEffectSystem.ObjectHasStatusEffectOfType(player, gamedataStatusEffectType.Knockdown) || StatusEffectSystem.ObjectHasStatusEffectOfType(player, gamedataStatusEffectType.Electrocuted);
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let isPerformingTakedown: Bool = this.IsPlayerPerformingTakedown();
    let game: GameInstance = this.GetGameInstance();
    if ToggleActivation.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionToggleActivation());
    };
    if this.IsDisabled() {
      return false;
    };
    if SetDeviceUnpowered.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionTogglePower());
      ArrayPush(outActions, this.ActionSetDeviceUnpowered());
      ArrayPush(outActions, this.ActionSetDevicePowered());
    };
    if this.IsPersonalLinkConnecting() {
      if TDBID.IsValid(this.m_personalLinkCustomInteraction) && this.m_personalLinkCustomInteraction != t"Interactions.None" {
        return false;
      };
      ArrayPush(outActions, this.ActionTogglePersonalLink(context.processInitiatorObject));
      return false;
    };
    if DisassembleDevice.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionDisassembleDevice());
    };
    if this.CanBeFixed() {
      ArrayPush(outActions, this.ActionFixDevice());
    };
    if ToggleJuryrigTrap.IsDefaultConditionMet(this, context) && GameInstance.GetTransactionSystem(game).HasItem(GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject(), ItemID.CreateQuery(t"Items.grenadeFrag")) {
      ArrayPush(outActions, this.ActionToggleJuryrigTrap());
    };
    if ActionScavenge.IsDefaultConditionMet(this) {
      ArrayPush(outActions, this.ActionScavenge(context));
    };
    if SetAuthorizationModuleON.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionSetAuthorizationModuleON());
    };
    if SetAuthorizationModuleOFF.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionSetAuthorizationModuleOFF());
    };
    if this.ShouldShowExamineIntaraction() {
      if !isPerformingTakedown {
        ArrayPush(outActions, this.ActionToggleZoomInteraction());
      };
    };
    if this.HasFullScreenUI() && !this.m_isAdvancedInteractionModeOn && this.IsPersonalLinkDisconnected() {
      if !isPerformingTakedown {
        ArrayPush(outActions, this.ActionOpenFullscreenUI());
      };
    };
    if this.HasPersonalLinkSlot() {
      if !isPerformingTakedown {
        if Equals(context.requestType, gamedeviceRequestType.Direct) && this.IsPowered() && this.ShouldExposePersonalLinkAction() {
          if this.m_disablePersonalLinkAutoDisconnect && NotEquals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) {
          } else {
            if this.m_skillCheckContainer.GetHackingSlot().IsActive() {
            } else {
              ArrayPush(outActions, this.ActionTogglePersonalLink(context.processInitiatorObject));
            };
          };
        };
      };
    };
    if SetDeviceON.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionSetDeviceON());
      ArrayPush(outActions, this.ActionSetDeviceOFF());
    };
    if isPerformingTakedown {
      return false;
    };
    if this.PushReturnActions(outActions, context) {
      return false;
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  public final const func IsPotentiallyQuickHackable() -> Bool {
    return !this.m_disableQuickHacks && this.CanCreateAnyQuickHackActions();
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return false;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  protected func GetMinigameActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void;

  protected final func FinalizeGetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if this.m_disableQuickHacks {
      if ArraySize(outActions) > 0 {
        ArrayClear(outActions);
      };
      return;
    };
    if !context.ignoresRPG {
      if this.IsConnectedToBackdoorDevice() {
        currentAction = this.ActionRemoteBreach();
        currentAction.SetInactiveWithReason(!this.IsBreached(), "LocKey#27728");
        ArrayPush(outActions, currentAction);
        currentAction = this.ActionPing();
        currentAction.SetInactiveWithReason(!this.GetNetworkSystem().HasActivePing(this.GetMyEntityID()), "LocKey#49279");
        ArrayPush(outActions, currentAction);
      } else {
        if this.HasNetworkBackdoor() {
          currentAction = this.ActionPing();
          currentAction.SetInactiveWithReason(!this.GetNetworkSystem().HasActivePing(this.GetMyEntityID()), "LocKey#49279");
          ArrayPush(outActions, currentAction);
        };
      };
      if this.IsUnpowered() {
        ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7013");
      };
      this.EvaluateActionsRPGAvailabilty(outActions, context);
      this.SetActionIllegality(outActions, this.m_illegalActions.quickHacks);
      this.MarkActionsAsQuickHacks(outActions);
      this.SetActionsQuickHacksExecutioner(outActions);
    };
  }

  protected final func FinalizeGetActions(out outActions: array<ref<DeviceAction>>) -> Void {
    this.SetInactiveActionsWithExceptions(outActions);
  }

  public func GetQuickHackActionsExternal(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void;

  protected func CanCreateAnySpiderbotActions() -> Bool {
    return false;
  }

  protected func GetSpiderbotActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void;

  protected func SetInactiveActionsWithExceptions(out outActions: array<ref<DeviceAction>>) -> Void {
    let actionAllowedClassNames: array<String>;
    let actionDisallowedClassNames: array<String>;
    let i: Int32;
    let inactiveReason: String;
    let sAction: ref<ScriptableDeviceAction>;
    if this.GetActionsRestrictionData(actionAllowedClassNames, actionDisallowedClassNames, inactiveReason) {
      i = 0;
      while i < ArraySize(outActions) {
        sAction = outActions[i] as ScriptableDeviceAction;
        if this.FindActionInTweakList(sAction.GetActionID(), actionAllowedClassNames) {
        } else {
          if ArraySize(actionAllowedClassNames) > 0 {
            (outActions[i] as ScriptableDeviceAction).SetInactiveWithReason(false, inactiveReason);
          } else {
            if this.FindActionInTweakList(sAction.GetActionID(), actionDisallowedClassNames) {
              (outActions[i] as ScriptableDeviceAction).SetInactiveWithReason(false, inactiveReason);
            };
          };
        };
        i += 1;
      };
    };
  }

  protected final func GetActionsRestrictionData(out allowedNames: array<String>, out disallowedNames: array<String>, out inactiveReason: String) -> Bool {
    let actionRestrictions: array<TweakDBID>;
    let arrSize: Int32;
    let i: Int32;
    let i1: Int32;
    let psmBB: ref<IBlackboard>;
    let record: wref<ActionRestrictionGroup_Record>;
    let tmpVariant: Variant;
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if !IsDefined(player) {
      return false;
    };
    psmBB = player.GetPlayerStateMachineBlackboard();
    if !IsDefined(psmBB) {
      return false;
    };
    tmpVariant = psmBB.GetVariant(GetAllBlackboardDefs().PlayerStateMachine.ActionRestriction);
    if VariantIsValid(tmpVariant) {
      actionRestrictions = FromVariant(tmpVariant);
    };
    i = 0;
    while i < ArraySize(actionRestrictions) {
      if TDBID.IsValid(actionRestrictions[i]) {
        record = TweakDBInterface.GetActionRestrictionGroupRecord(actionRestrictions[i]);
        if !IsDefined(record) {
          return false;
        };
        arrSize = record.GetAllowedActionNamesCount();
        if arrSize > 0 {
          i1 = 0;
          while i1 < arrSize {
            if !ArrayContains(allowedNames, record.GetAllowedActionNamesItem(i1)) {
              ArrayPush(allowedNames, record.GetAllowedActionNamesItem(i1));
            };
            i1 += 1;
          };
          if ArraySize(allowedNames) > 0 {
            inactiveReason = record.InactiveReason();
            return true;
          };
        };
        arrSize = record.GetDisallowedActionNamesCount();
        if arrSize > 0 {
          i1 = 0;
          while i1 < arrSize {
            if !ArrayContains(disallowedNames, record.GetDisallowedActionNamesItem(i1)) {
              ArrayPush(disallowedNames, record.GetDisallowedActionNamesItem(i1));
            };
            i1 += 1;
          };
          if ArraySize(disallowedNames) > 0 {
            inactiveReason = record.InactiveReason();
            return true;
          };
        };
      };
      i += 1;
    };
    return false;
  }

  protected final func FindActionInTweakList(actionName: CName, allowedNames: array<String>) -> Bool {
    let i: Int32;
    if ArraySize(allowedNames) <= 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(allowedNames) {
      if Equals(NameToString(actionName), allowedNames[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected final const func GetLocalPassword() -> CName {
    return this.m_authorizationProperties.m_authorizationDataEntry.m_password;
  }

  public final const func HasAuthorizationModule() -> Bool {
    return this.m_hasAuthorizationModule;
  }

  public final const quest func IsAuthorizationModuleOn() -> Bool {
    return this.HasAuthorizationModule() && this.m_authorizationProperties.m_isAuthorizationModuleOn;
  }

  public final const quest func IsAuthorizationModuleOff() -> Bool {
    return !this.IsAuthorizationModuleOn();
  }

  protected final func SetBlockSecurityWakeUp(value: Bool) -> Void {
    this.m_blockSecurityWakeUp = value;
    this.SendDeviceNotOperationalEvent();
  }

  public final const func GetMySecurityAccessLevel() -> ESecurityAccessLevel {
    let securityLevel: ESecurityAccessLevel;
    if this.IsConnectedToSecuritySystem(securityLevel) {
      return securityLevel;
    };
    return this.m_authorizationProperties.m_authorizationDataEntry.m_level;
  }

  public const func GetSecurityAlarm() -> ref<SecurityAlarmControllerPS> {
    let ancestors: array<ref<DeviceComponentPS>>;
    let i: Int32;
    this.GetAncestors(ancestors);
    i = 0;
    while i < ArraySize(ancestors) {
      if IsDefined(ancestors[i] as SecurityAlarmControllerPS) {
        return ancestors[i] as SecurityAlarmControllerPS;
      };
      i += 1;
    };
    return null;
  }

  public final const func GetDropPointSystem() -> ref<DropPointSystem> {
    let dps: ref<DropPointSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"DropPointSystem") as DropPointSystem;
    if IsDefined(dps) {
      return dps;
    };
    return null;
  }

  public final const func GetSecurityAreasWithUsersInside(out uniqueUsers: array<AreaEntry>) -> array<ref<SecurityAreaControllerPS>> {
    let areaUsers: array<AreaEntry>;
    let j: Int32;
    let nonEmptyAreas: array<ref<SecurityAreaControllerPS>>;
    let secAreas: array<ref<SecurityAreaControllerPS>> = this.GetSecurityAreas();
    let i: Int32 = 0;
    while i < ArraySize(secAreas) {
      areaUsers = secAreas[i].GetUsersInPerimeter();
      if ArraySize(areaUsers) > 0 {
        ArrayPush(nonEmptyAreas, secAreas[i]);
      };
      j = 0;
      while j < ArraySize(areaUsers) {
        if !ArrayContains(uniqueUsers, areaUsers[j]) {
          ArrayPush(uniqueUsers, areaUsers[j]);
        };
        j += 1;
      };
      i += 1;
    };
    return nonEmptyAreas;
  }

  public final const func GetSecurityAreasWithUsersInside() -> array<ref<SecurityAreaControllerPS>> {
    let trash: array<AreaEntry>;
    return this.GetSecurityAreasWithUsersInside(trash);
  }

  public final const func GetSecurityAreasWithUserInside(whoToCheck: EntityID) -> array<ref<SecurityAreaControllerPS>> {
    let i: Int32;
    let secAreasWithUser: array<ref<SecurityAreaControllerPS>>;
    let secSys: ref<SecuritySystemControllerPS>;
    let secAreas: array<ref<SecurityAreaControllerPS>> = this.GetSecurityAreas();
    if ArraySize(secAreas) > 0 {
      i = 0;
      while i < ArraySize(secAreas) {
        if secAreas[i].IsUserInside(whoToCheck) {
          ArrayPush(secAreasWithUser, secAreas[i]);
        };
        i += 1;
      };
      return secAreasWithUser;
    };
    secSys = this.GetSecuritySystem();
    if IsDefined(secSys) {
      return secSys.GetSecurityAreasWithUserInside(whoToCheck);
    };
    return secAreas;
  }

  public final const func GetSecurityAreasWithUserInside(whoToCheck: ref<GameObject>) -> array<ref<SecurityAreaControllerPS>> {
    let emptyArr: array<ref<SecurityAreaControllerPS>>;
    if IsDefined(whoToCheck) {
      return this.GetSecurityAreasWithUserInside(whoToCheck.GetEntityID());
    };
    return emptyArr;
  }

  protected final func SetCurrentSpiderbotActionPerformed(action: ref<ScriptableDeviceAction>) -> Void {
    this.m_currentSpiderbotActionPerformed = action;
  }

  public final const func GetCurrentlyQueuedSpiderbotAction() -> ref<ScriptableDeviceAction> {
    return this.m_currentSpiderbotActionPerformed;
  }

  public final const quest func IsDeviceSecured() -> Bool {
    let i: Int32;
    let securityData: array<SecurityAccessLevelEntryClient>;
    if !this.IsAuthorizationModuleOn() || this.m_authorizationProperties.m_alwaysExposeActions {
      return false;
    };
    securityData = this.GetFullAuthorizationData();
    i = 0;
    while i < ArraySize(securityData) {
      if SecurityAccessLevelEntryClient.IsDataValid(securityData[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsDeviceSecuredWithPassword() -> Bool {
    let passwords: array<CName> = this.GetPasswords();
    if ArraySize(passwords) > 0 {
      return true;
    };
    return false;
  }

  public final const func IsDeviceSecuredWithKeycard() -> Bool {
    let keycards: array<TweakDBID> = this.GetKeycards();
    if ArraySize(keycards) > 0 {
      return true;
    };
    return false;
  }

  public final const func HasActiveStaticHackingSkillcheck() -> Bool {
    let hackingSkillcheck: ref<HackingSkillCheck>;
    if IsDefined(this.GetSkillCheckContainer()) {
      hackingSkillcheck = this.GetSkillCheckContainer().GetHackingSlot();
    };
    if IsDefined(hackingSkillcheck) && hackingSkillcheck.IsActive() && !hackingSkillcheck.IsDynamic() {
      return true;
    };
    return false;
  }

  public const func IsPlayerAuthorized() -> Bool {
    let player: ref<GameObject> = this.GetPlayerMainObject();
    return this.IsUserAuthorized(player.GetEntityID());
  }

  public const func CanPayToAuthorize() -> Bool {
    return false;
  }

  public const func IsUserAuthorized(user: EntityID) -> Bool {
    let deviceLevel: ESecurityAccessLevel;
    let i: Int32;
    if !this.IsDeviceSecured() {
      return true;
    };
    if this.IsConnectedToSecuritySystem(deviceLevel) {
      if this.GetSecuritySystem().IsUserAuthorized(user, deviceLevel) {
        return true;
      };
    };
    i = 0;
    while i < ArraySize(this.m_currentlyAuthorizedUsers) {
      if this.m_currentlyAuthorizedUsers[i].user == user {
        if EnumInt(this.m_currentlyAuthorizedUsers[i].level) >= EnumInt(this.GetMySecurityAccessLevel()) {
          return true;
        };
      };
      i += 1;
    };
    if this.UserAuthorizationAttempt(user) {
      return true;
    };
    return false;
  }

  public const func GetUserAuthorizationLevel(user: EntityID) -> ESecurityAccessLevel {
    let i: Int32;
    let secAuthLevel: ESecurityAccessLevel;
    let secSys: ref<SecuritySystemControllerPS> = this.GetSecuritySystem();
    if IsDefined(secSys) {
      secAuthLevel = secSys.GetUserAuthorizationLevel(user);
      if secAuthLevel > ESecurityAccessLevel.ESL_NONE {
        return secAuthLevel;
      };
    };
    i = 0;
    while i < ArraySize(this.m_currentlyAuthorizedUsers) {
      if this.m_currentlyAuthorizedUsers[i].user == user {
        return this.m_currentlyAuthorizedUsers[i].level;
      };
      i += 1;
    };
    return ESecurityAccessLevel.ESL_NONE;
  }

  public final const func CurrentlyAuthorizedUsers() -> array<SecuritySystemClearanceEntry> {
    return this.m_currentlyAuthorizedUsers;
  }

  public final const func UserAuthorizationAttempt(userToAuthorize: EntityID, opt password: CName) -> Bool {
    let i: Int32;
    let keycards: array<TweakDBID>;
    let passwords: array<CName>;
    this.GetFullAuthorizationDataSegregated(passwords, keycards);
    if IsNameValid(password) {
      i = 0;
      while i < ArraySize(passwords) {
        if Equals(password, passwords[i]) {
          SetFactValue(this.GetGameInstance(), password, 1);
          this.AddUser(userToAuthorize, this.GetMySecurityAccessLevel());
          return true;
        };
        i += 1;
      };
    };
    i = 0;
    while i < ArraySize(keycards) {
      if GameInstance.GetTransactionSystem(this.GetGameInstance()).HasItem(GameInstance.FindEntityByID(this.GetGameInstance(), userToAuthorize) as GameObject, ItemID.CreateQuery(keycards[i])) {
        this.AddUser(userToAuthorize, this.GetMySecurityAccessLevel());
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func MasterUserAuthorizationAttempt(userToAuthorize: EntityID, opt password: CName) -> Bool {
    this.AddUser(userToAuthorize, this.GetMySecurityAccessLevel());
    return true;
  }

  protected func ActionAuthorizeUser() -> ref<AuthorizeUser> {
    let action: ref<AuthorizeUser> = new AuthorizeUser();
    action.clearanceLevel = DefaultActionsParametersHolder.GetAuthorizeUserClearance();
    action.SetUp(this);
    action.SetProperties(this.GetPasswords());
    action.AddDeviceName(this.GetDeviceName());
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnAuthorizeUser(evt: ref<AuthorizeUser>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if evt.GetRequesterID() != this.GetMyEntityID() {
      if this.MasterUserAuthorizationAttempt(evt.GetExecutor().GetEntityID(), evt.GetEnteredPassword()) {
        this.Notify(notifier, evt);
        return EntityNotificationType.SendThisEventToEntity;
      };
    } else {
      if this.UserAuthorizationAttempt(evt.GetExecutor().GetEntityID(), evt.GetEnteredPassword()) {
        this.Notify(notifier, evt);
        return EntityNotificationType.SendThisEventToEntity;
      };
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func ActionSetAuthorizationModuleON() -> ref<SetAuthorizationModuleON> {
    let action: ref<SetAuthorizationModuleON> = new SetAuthorizationModuleON();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    return action;
  }

  public func OnSetAuthorizationModuleON(evt: ref<SetAuthorizationModuleON>) -> EntityNotificationType {
    this.TurnAuthorizationModuleON();
    this.UseNotifier(evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func ActionSetAuthorizationModuleOFF() -> ref<SetAuthorizationModuleOFF> {
    let action: ref<SetAuthorizationModuleOFF> = new SetAuthorizationModuleOFF();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    return action;
  }

  public func OnSetAuthorizationModuleOFF(evt: ref<SetAuthorizationModuleOFF>) -> EntityNotificationType {
    this.TurnAuthorizationModuleOFF();
    this.UseNotifier(evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func ActionPay(context: GetActionsContext) -> ref<Pay> {
    let action: ref<Pay> = new Pay();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleLockClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func TriggerSecuritySystemNotification(whoBreached: ref<GameObject>, lastKnownPosition: Vector4, type: ESecurityNotificationType, opt forceNotification: Bool) -> Void {
    let secSys: ref<SecuritySystemControllerPS>;
    if this.IsON() || this.IsOFF() || forceNotification {
      secSys = this.GetSecuritySystem();
      if !IsDefined(secSys) {
        return;
      };
      secSys.ReportPotentialSituation(this.ActionSecurityBreachNotification(lastKnownPosition, whoBreached, type));
      return;
    };
  }

  public const func ActionSecurityBreachNotification(lastKnownPosition: Vector4, whoBreached: ref<GameObject>, type: ESecurityNotificationType) -> ref<SecuritySystemInput> {
    let action: ref<SecuritySystemInput> = new SecuritySystemInput();
    action.SetUp(this);
    action.SetProperties(lastKnownPosition, whoBreached, this, type, this.CanPerformReprimand(), false);
    action.AddDeviceName(this.GetDeviceName());
    return action;
  }

  public final const quest func WasQuickHacked() -> Bool {
    return this.m_wasQuickHacked;
  }

  public final const quest func WasQuickHackAttempt() -> Bool {
    return this.m_wasQuickHackAttempt;
  }

  public final const quest func WasQuickHackJustPerformed(quickHackName: CName) -> Bool {
    return Equals(this.m_lastPerformedQuickHack, quickHackName);
  }

  public final func OnSetWasQuickHacked(evt: ref<SetQuickHackEvent>) -> EntityNotificationType {
    this.m_wasQuickHacked = evt.wasQuickHacked;
    this.m_lastPerformedQuickHack = evt.quickHackName;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnSetWasQuickHackedAtempt(evt: ref<SetQuickHackAttemptEvent>) -> EntityNotificationType {
    this.m_wasQuickHackAttempt = evt.wasQuickHackAttempt;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final const func IsConnectedToAccessPoint() -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as AccessPointControllerPS) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public const func GetNetworkSizeCount() -> Int32 {
    let aps: array<ref<AccessPointControllerPS>> = this.GetAccessPoints();
    if ArraySize(aps) == 0 {
      if !IsFinal() {
        LogDevices(this, "Illegal callback", ELogType.ERROR);
      };
      return -1;
    };
    return aps[0].GetNetworkSizeCount() - 1;
  }

  public final const func GetBackdoorDevices() -> array<ref<ScriptableDeviceComponentPS>> {
    let backdoor: ref<ScriptableDeviceComponentPS>;
    let backdoorDevices: array<ref<ScriptableDeviceComponentPS>>;
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if (parents[i] as ScriptableDeviceComponentPS).HasNetworkBackdoor() {
        backdoor = parents[i] as ScriptableDeviceComponentPS;
        ArrayPush(backdoorDevices, backdoor);
      };
      i += 1;
    };
    return backdoorDevices;
  }

  public const func IsMainframe() -> Bool {
    let aps: array<ref<AccessPointControllerPS>>;
    if !this.HasNetworkBackdoor() {
      return false;
    };
    aps = this.GetAccessPoints();
    if ArraySize(aps) == 1 {
      return aps[0].IsMainframe();
    };
    if !IsFinal() {
      LogDevices(this, "UNSUPPORTED AMOUNT OF ACCESS POINTS FOR THIS BACKDOOR DEVICE!", ELogType.ERROR);
    };
    return false;
  }

  protected const func GetNetworkArea() -> wref<NetworkAreaControllerPS> {
    let ancestors: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let networkArea: wref<NetworkAreaControllerPS>;
    this.GetAncestors(ancestors);
    i = 0;
    while i < ArraySize(ancestors) {
      if IsDefined(ancestors[i] as NetworkAreaControllerPS) {
        networkArea = ancestors[i] as NetworkAreaControllerPS;
        return networkArea;
      };
      i += 1;
    };
    return null;
  }

  public final const quest func HackingPerformed() -> Bool {
    if !IsDefined(this.m_skillCheckContainer) || !IsDefined(this.m_skillCheckContainer.GetHackingSlot()) {
      return false;
    };
    return this.m_skillCheckContainer.GetHackingSlot().WasPerformed();
  }

  public final const quest func EngineeringPerformed() -> Bool {
    if !IsDefined(this.m_skillCheckContainer) || !IsDefined(this.m_skillCheckContainer.GetEngineeringSlot()) {
      return false;
    };
    return this.m_skillCheckContainer.GetEngineeringSlot().WasPerformed();
  }

  public final const quest func DemolitionPerformed() -> Bool {
    if !IsDefined(this.m_skillCheckContainer) || !IsDefined(this.m_skillCheckContainer.GetDemolitionSlot()) {
      return false;
    };
    return this.m_skillCheckContainer.GetDemolitionSlot().WasPerformed();
  }

  protected func ActionHacking(context: GetActionsContext) -> ref<ActionHacking> {
    let action: ref<ActionHacking> = new ActionHacking();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_skillCheckContainer.GetHackingSlot());
    action.AddDeviceName(this.m_deviceName);
    action.SetIllegal(this.m_illegalActions.skillChecks);
    action.RegisterAsRequester(context.requestorID);
    if TDBID.IsValid(this.m_personalLinkCustomInteraction) && this.m_personalLinkCustomInteraction != t"Interactions.None" && !this.IsPersonalLinkConnecting() {
      action.CreateInteraction(this.m_personalLinkCustomInteraction);
    } else {
      action.CreateInteraction(context.processInitiatorObject);
    };
    action.SetDurationValue(this.m_skillCheckContainer.GetHackingSlot().GetDuration());
    return action;
  }

  public final func OnActionHacking(evt: ref<ActionHacking>) -> EntityNotificationType {
    let togglePersonalLink: ref<TogglePersonalLink>;
    if evt.WasPassed() {
      if evt.IsCompleted() {
        if this.HasNetworkBackdoor() {
        } else {
          this.DisconnectPersonalLink(evt);
        };
      } else {
        togglePersonalLink = this.ActionTogglePersonalLink(evt.GetExecutor());
        this.ExecutePSAction(togglePersonalLink, evt.GetInteractionLayer());
        this.ExecutePSActionWithDelay(evt, this, 4.20);
      };
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ResolveActionHackingCompleted(evt: ref<ActionHacking>) -> Void {
    this.ResolveOtherSkillchecks();
  }

  protected final func InitializeBackdoorSkillcheck() -> Void {
    if this.HasNetworkBackdoor() && !IsDefined(this as AccessPointControllerPS) && this.HasPersonalLinkSlot() {
      if !IsDefined(this.m_skillCheckContainer) {
        this.m_skillCheckContainer = new HackingContainer();
      };
      this.m_skillCheckContainer.InitializeBackdoor(this.m_backdoorBreachDifficulty);
      this.m_skillCheckContainer.GetHackingSlot().SetDynamic(true);
    };
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let action: ref<ActionEngineering> = new ActionEngineering();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_skillCheckContainer.GetEngineeringSlot());
    action.AddDeviceName(this.m_deviceName);
    action.SetIllegal(this.m_illegalActions.skillChecks);
    action.RegisterAsRequester(context.requestorID);
    action.CreateInteraction(context.processInitiatorObject);
    action.SetDurationValue(this.m_skillCheckContainer.GetEngineeringSlot().GetDuration());
    return action;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if evt.WasPassed() {
      this.m_skillCheckContainer.GetEngineeringSlot().SetIsActive(false);
      this.m_skillCheckContainer.GetEngineeringSlot().SetIsPassed(true);
      this.m_skillCheckContainer.GetEngineeringSlot().CheckPerformed();
      if evt.IsCompleted() {
        this.TurnAuthorizationModuleOFF();
      } else {
        this.ExecutePSActionWithDelay(evt, this);
      };
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ActionDemolition(context: GetActionsContext) -> ref<ActionDemolition> {
    let action: ref<ActionDemolition> = new ActionDemolition();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_skillCheckContainer.GetDemolitionSlot());
    action.AddDeviceName(this.m_deviceName);
    action.SetIllegal(this.m_illegalActions.skillChecks);
    action.RegisterAsRequester(context.requestorID);
    action.CreateInteraction(context.processInitiatorObject);
    action.SetDurationValue(this.m_skillCheckContainer.GetDemolitionSlot().GetDuration());
    return action;
  }

  public func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    if evt.WasPassed() {
      this.m_skillCheckContainer.GetDemolitionSlot().SetIsActive(false);
      this.m_skillCheckContainer.GetDemolitionSlot().SetIsPassed(true);
      this.m_skillCheckContainer.GetDemolitionSlot().CheckPerformed();
      if !evt.IsCompleted() {
        this.ExecutePSActionWithDelay(evt, this);
      };
    };
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnResolveSkillchecksEvent(evt: ref<ResolveSkillchecksEvent>) -> EntityNotificationType {
    this.ResolveOtherSkillchecks();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ResolveOtherSkillchecks() -> Void;

  public final const func GetSkillCheckContainer() -> ref<BaseSkillCheckContainer> {
    return this.m_skillCheckContainer;
  }

  public final const func HasAnySkillCheckActive() -> Bool {
    return this.IsHackingSkillCheckActive() || this.IsDemolitionSkillCheckActive() || this.IsEngineeringSkillCheckActive();
  }

  public final const func IsHackingSkillCheckActive() -> Bool {
    if this.m_skillCheckContainer == null || !IsDefined(this.m_skillCheckContainer.GetHackingSlot()) {
      return false;
    };
    return this.m_skillCheckContainer.GetHackingSlot().IsActive();
  }

  public final const func IsDemolitionSkillCheckActive() -> Bool {
    if this.m_skillCheckContainer == null || !IsDefined(this.m_skillCheckContainer.GetDemolitionSlot()) {
      return false;
    };
    return this.m_skillCheckContainer.GetDemolitionSlot().IsActive();
  }

  public final const func IsEngineeringSkillCheckActive() -> Bool {
    if this.m_skillCheckContainer == null || !IsDefined(this.m_skillCheckContainer.GetEngineeringSlot()) {
      return false;
    };
    return this.m_skillCheckContainer.GetEngineeringSlot().IsActive();
  }

  public final const func CanPassEngineeringSkillCheck(requester: ref<GameObject>) -> Bool {
    if this.m_skillCheckContainer == null || !IsDefined(this.m_skillCheckContainer.GetEngineeringSlot()) || !this.m_skillCheckContainer.GetEngineeringSlot().IsActive() {
      return false;
    };
    return this.m_skillCheckContainer.GetEngineeringSlot().Evaluate(requester);
  }

  public final const func CanPassDemolitionSkillCheck(requester: ref<GameObject>) -> Bool {
    if this.m_skillCheckContainer == null || !IsDefined(this.m_skillCheckContainer.GetDemolitionSlot()) || !this.m_skillCheckContainer.GetDemolitionSlot().IsActive() {
      return false;
    };
    return this.m_skillCheckContainer.GetDemolitionSlot().Evaluate(requester);
  }

  public final const func CanPassHackingSkillCheck(requester: ref<GameObject>) -> Bool {
    if this.m_skillCheckContainer == null || !IsDefined(this.m_skillCheckContainer.GetHackingSlot()) || !this.m_skillCheckContainer.GetHackingSlot().IsActive() {
      return false;
    };
    return this.m_skillCheckContainer.GetHackingSlot().Evaluate(requester);
  }

  public final const func CanPassAnySkillCheck(requester: ref<GameObject>) -> Bool {
    if this.m_skillCheckContainer == null {
      return false;
    };
    return this.CanPassEngineeringSkillCheck(requester) || this.CanPassDemolitionSkillCheck(requester) || this.CanPassHackingSkillCheck(requester);
  }

  public const func CanPassAnySkillCheckOnMaster(requester: ref<GameObject>) -> Bool {
    let i: Int32;
    let parent: ref<ScriptableDeviceComponentPS>;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      parent = parents[i] as ScriptableDeviceComponentPS;
      if parent == null {
      } else {
        if parent.IsSkillCheckActive() && parent.CanPassAnySkillCheck(requester) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final const func IsSkillCheckActive() -> Bool {
    if this.IsHackingSkillCheckActive() || this.IsDemolitionSkillCheckActive() || this.IsEngineeringSkillCheckActive() {
      return true;
    };
    return false;
  }

  public final const func WasHackingSkillCheckActive() -> Bool {
    if IsDefined(this.m_skillCheckContainer.GetHackingSlot()) && (this.m_skillCheckContainer.GetHackingSlot().IsActive() || this.m_skillCheckContainer.GetHackingSlot().IsPassed()) {
      return true;
    };
    return false;
  }

  public final const func WasDemolitionSkillCheckActive() -> Bool {
    if IsDefined(this.m_skillCheckContainer.GetDemolitionSlot()) && (this.m_skillCheckContainer.GetDemolitionSlot().IsActive() || this.m_skillCheckContainer.GetDemolitionSlot().IsPassed()) {
      return true;
    };
    return false;
  }

  public final const func WasEngineeringSkillCheckActive() -> Bool {
    if IsDefined(this.m_skillCheckContainer.GetEngineeringSlot()) && (this.m_skillCheckContainer.GetEngineeringSlot().IsActive() || this.m_skillCheckContainer.GetEngineeringSlot().IsPassed()) {
      return true;
    };
    return false;
  }

  protected func PushSkillCheckActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let skillCheckAction: ref<ActionSkillCheck>;
    let skillCheckAdded: Bool;
    if this.m_skillCheckContainer == null {
      return false;
    };
    if IsDefined(this.m_skillCheckContainer.GetHackingSlot()) && this.m_skillCheckContainer.GetHackingSlot().IsActive() && this.IsON() && this.HasCyberdeck() && this.HasPersonalLinkSlot() {
      skillCheckAction = this.ActionHacking(context);
      skillCheckAction.RegisterAsRequester(context.requestorID);
      skillCheckAction.SetDurationValue(this.m_skillCheckContainer.GetHackingSlot().GetDuration());
      ArrayPush(outActions, skillCheckAction);
      if this.ShouldPersonalLinkBlockActions() {
        skillCheckAdded = true;
      };
    };
    if IsDefined(this.m_skillCheckContainer.GetEngineeringSlot()) && this.m_skillCheckContainer.GetEngineeringSlot().IsActive() {
      skillCheckAction = this.ActionEngineering(context);
      if ActionSkillCheck.IsDefaultConditionMet(this, context, skillCheckAction.AvailableOnUnpowered()) {
        skillCheckAction.RegisterAsRequester(context.requestorID);
        skillCheckAction.SetDurationValue(this.m_skillCheckContainer.GetEngineeringSlot().GetDuration());
        ArrayPush(outActions, skillCheckAction);
        skillCheckAdded = true;
      };
    };
    if IsDefined(this.m_skillCheckContainer.GetDemolitionSlot()) && this.m_skillCheckContainer.GetDemolitionSlot().IsActive() {
      skillCheckAction = this.ActionDemolition(context);
      if ActionSkillCheck.IsDefaultConditionMet(this, context, skillCheckAction.AvailableOnUnpowered()) {
        skillCheckAction.RegisterAsRequester(context.requestorID);
        skillCheckAction.SetDurationValue(this.m_skillCheckContainer.GetDemolitionSlot().GetDuration());
        ArrayPush(outActions, skillCheckAction);
        skillCheckAdded = true;
      };
    };
    return skillCheckAdded;
  }

  protected final func HasCyberdeck() -> Bool {
    return GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatBoolValue(Cast(this.GetPlayerEntityID()), gamedataStatType.HasCyberdeck);
  }

  protected func ShouldPersonalLinkBlockActions() -> Bool {
    return false;
  }

  public final func CreateSkillcheckInfo(context: GetActionsContext) -> array<UIInteractionSkillCheck> {
    let blackboardDescription: array<UIInteractionSkillCheck>;
    let skillcheckDescription: UIInteractionSkillCheck;
    if this.m_skillCheckContainer.GetHackingSlot().IsActive() && this.IsON() {
      skillcheckDescription = this.ActionHacking(context).CreateSkillcheckInfo(context.processInitiatorObject);
      ArrayPush(blackboardDescription, skillcheckDescription);
    };
    if this.m_skillCheckContainer.GetEngineeringSlot().IsActive() {
      skillcheckDescription = this.ActionEngineering(context).CreateSkillcheckInfo(context.processInitiatorObject);
      ArrayPush(blackboardDescription, skillcheckDescription);
    };
    if this.m_skillCheckContainer.GetDemolitionSlot().IsActive() {
      skillcheckDescription = this.ActionDemolition(context).CreateSkillcheckInfo(context.processInitiatorObject);
      ArrayPush(blackboardDescription, skillcheckDescription);
    };
    return blackboardDescription;
  }

  protected final func IsSpiderbotActionsConditionsFulfilled() -> Bool {
    if GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatBoolValue(Cast(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetEntityID()), gamedataStatType.HasSpiderBotControl) {
      if AIActionHelper.CheckFlatheadStatPoolRequirements(this.GetGameInstance(), "DeviceAction") {
        if !IsDefined(this.m_currentSpiderbotActionPerformed) {
          return true;
        };
      };
    };
    return false;
  }

  protected func ActionSpiderbotDistraction() -> ref<SpiderbotDistraction> {
    let action: ref<SpiderbotDistraction> = new SpiderbotDistraction();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected func ActionQuickHackDistraction() -> ref<QuickHackDistraction> {
    let action: ref<QuickHackDistraction> = new QuickHackDistraction();
    action.SetUp(this);
    action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final const func IsInvestigated() -> Bool {
    let value: Bool = this.GetBlackboard().GetBool(this.GetBlackboardDef().IsInvestigated);
    return value;
  }

  public final func FinishDistraction() -> Void {
    let distract: ref<QuickHackDistraction>;
    if !this.m_distractionTimeCompleted {
      return;
    };
    distract = this.ActionQuickHackDistraction();
    distract.SetCompleted();
    this.QueuePSEvent(this, distract);
  }

  public func OnQuickHackDistraction(evt: ref<QuickHackDistraction>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if evt.IsStarted() {
      this.m_distractExecuted = true;
      this.m_isGlitching = true;
      this.m_distractionTimeCompleted = false;
      evt.SetCanTriggerStim(true);
      evt.SetObjectActionID(t"DeviceAction.EndMalfunction");
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      this.m_distractionTimeCompleted = true;
      if this.IsInvestigated() {
        return EntityNotificationType.DoNotNotifyEntity;
      };
      this.m_distractExecuted = false;
      this.m_isGlitching = false;
      evt.SetCanTriggerStim(false);
    };
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuickHackAuthorization(evt: ref<QuickHackAuthorization>) -> EntityNotificationType {
    if this.IsConnectedToSecuritySystem() {
      this.GetSecuritySystem().AuthorizeUser(evt.GetExecutor().GetEntityID(), ESecurityAccessLevel.ESL_4);
    } else {
      this.AddUser(evt.GetExecutor().GetEntityID(), ESecurityAccessLevel.ESL_4);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func GetConnectionHighlightObjects() -> array<NodeRef> {
    return this.m_connectionHighlightObjects;
  }

  public final const func ShouldDrawGridLink() -> Bool {
    return this.m_drawGridLink;
  }

  public final const func IsLinkDynamic() -> Bool {
    return this.m_isLinkDynamic;
  }

  public const func ShouldRevealDevicesGrid() -> Bool {
    return this.m_revealDevicesGrid;
  }

  public const func CanRevealDevicesGridWhenUnpowered() -> Bool {
    return this.m_revealDevicesGridWhenUnpowered;
  }

  public final const func GetVirtualNetworkShapeID() -> TweakDBID {
    return this.m_virtualNetworkShapeID;
  }

  protected final const func GetCityLightSystem() -> ref<CityLightSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"CityLightSystem") as CityLightSystem;
  }

  protected final const func GetEquipmentSystem() -> ref<EquipmentSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"EquipmentSystem") as EquipmentSystem;
  }

  public final const func CheckIfMyBackdoorsWereRevealedInNetworkPing() -> Bool {
    let backdoors: array<ref<ScriptableDeviceComponentPS>> = this.GetBackdoorDevices();
    let i: Int32 = 0;
    while i < ArraySize(backdoors) {
      if backdoors[i].WasRevealedInNetworkPing() {
      } else {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public const func ShouldRevealNetworkGrid() -> Bool {
    if this.HasNetworkBackdoor() {
      return true;
    };
    return false;
  }

  public final func SetFocusModeData(isHighlighted: Bool) -> Void {
    this.m_isHighlightedInFocusMode = isHighlighted;
  }

  public final func OnForceUpdateDefaultHighlightEvent(evt: ref<ForceUpdateDefaultHighlightEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func RevealNetworkGrid(shouldDraw: Bool, opt ownerEntityPosition: Vector4, opt fxDefault: FxResource, opt fxBreached: FxResource, opt isPing: Bool, opt lifetime: Float, opt revealSlave: Bool, opt revealMaster: Bool, opt ignoreRevealed: Bool) -> Void {
    let accessPoints: array<ref<AccessPointControllerPS>>;
    let backdoorAP: ref<AccessPointControllerPS>;
    let finalizeRegistrationAsMaster: Bool;
    let i: Int32;
    let k: Int32;
    let nonVirtualBackdoorDevice: ref<ScriptableDeviceComponentPS>;
    let nonVirtualBackdoorDevices: array<ref<ScriptableDeviceComponentPS>>;
    let relevantDevices: array<ref<DeviceComponentPS>>;
    let revDevicesEvt: ref<ProcessRelevantDevicesForNetworkGridEvent>;
    let unregisterLinkRequest: ref<UnregisterNetworkLinksByIDRequest>;
    let networkSystem: ref<NetworkSystem> = this.GetNetworkSystem();
    if !shouldDraw {
      if networkSystem.HasNetworkLink(PersistentID.ExtractEntityID(this.GetID())) {
        unregisterLinkRequest = new UnregisterNetworkLinksByIDRequest();
        unregisterLinkRequest.ID = PersistentID.ExtractEntityID(this.GetID());
        networkSystem.QueueRequest(unregisterLinkRequest);
      };
      return;
    };
    if this.IsUnpowered() && !this.CanRevealDevicesGridWhenUnpowered() || this.IsDisabled() {
      return;
    };
    if this.HasNetworkBackdoor() {
      backdoorAP = this.GetBackdoorAccessPoint();
      if !IsDefined(backdoorAP) {
        if !IsFinal() {
          LogDevices(this, "No backdoorAP", ELogType.ERROR);
        };
        return;
      };
      revDevicesEvt = new ProcessRelevantDevicesForNetworkGridEvent();
      revDevicesEvt.ignoreRevealed = ignoreRevealed;
      revDevicesEvt.finalizeRegistrationAsMaster = true;
      revDevicesEvt.breachedResource = fxBreached;
      revDevicesEvt.defaultResource = fxDefault;
      revDevicesEvt.isPing = isPing;
      revDevicesEvt.lifetime = lifetime;
      revDevicesEvt.revealSlave = revealSlave;
      revDevicesEvt.revealMaster = revealMaster;
      this.ProcessDevicesLazy(backdoorAP.GetLazySlaves(), revDevicesEvt);
      return;
    };
    accessPoints = this.GetAccessPoints();
    i = 0;
    while i < ArraySize(accessPoints) {
      if accessPoints[i].ShouldRevealNetworkGrid() {
        if ignoreRevealed && accessPoints[i].WasRevealedInNetworkPing() || accessPoints[i].IsUnpowered() && !accessPoints[i].CanRevealDevicesGridWhenUnpowered() {
        } else {
          ArrayPush(relevantDevices, accessPoints[i]);
        };
      };
      nonVirtualBackdoorDevices = accessPoints[i].GetDevicesThatPlayerCanBreach();
      k = 0;
      while k < ArraySize(nonVirtualBackdoorDevices) {
        nonVirtualBackdoorDevice = nonVirtualBackdoorDevices[k];
        if !nonVirtualBackdoorDevice.ShouldRevealDevicesGrid() {
        } else {
          ArrayPush(relevantDevices, nonVirtualBackdoorDevice);
        };
        k += 1;
      };
      i += 1;
    };
    finalizeRegistrationAsMaster = false;
    this.FinalizeNetworkLinkRegistration(finalizeRegistrationAsMaster, relevantDevices, fxBreached, fxDefault, isPing, lifetime, revealSlave, revealMaster);
  }

  private final func OnProcessRelevantDevicesForNetworkGridEvent(evt: ref<ProcessRelevantDevicesForNetworkGridEvent>) -> EntityNotificationType {
    let relevantDevice: ref<ScriptableDeviceComponentPS>;
    let i: Int32 = ArraySize(evt.devices) - 1;
    while i >= 0 {
      relevantDevice = evt.devices[i] as ScriptableDeviceComponentPS;
      if relevantDevice == null {
        ArrayErase(evt.devices, i);
      } else {
        if evt.ignoreRevealed && relevantDevice.WasRevealedInNetworkPing() {
          ArrayErase(evt.devices, i);
        } else {
          if relevantDevice == this || !relevantDevice.ShouldRevealDevicesGrid() {
            ArrayErase(evt.devices, i);
          } else {
            if relevantDevice.IsUnpowered() && !relevantDevice.CanRevealDevicesGridWhenUnpowered() {
              ArrayErase(evt.devices, i);
            };
          };
        };
      };
      i -= 1;
    };
    this.FinalizeNetworkLinkRegistration(evt.finalizeRegistrationAsMaster, evt.devices, evt.breachedResource, evt.defaultResource, evt.isPing, evt.lifetime, evt.revealSlave, evt.revealMaster);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final const func FinalizeNetworkLinkRegistration(registerAsMaster: Bool, relevantDevices: array<ref<DeviceComponentPS>>, breachedResource: FxResource, defaultResource: FxResource, isPing: Bool, lifetime: Float, opt revealSlave: Bool, opt revealMaster: Bool) -> Void {
    let i: Int32;
    let linkData: SNetworkLinkData;
    let links: array<SNetworkLinkData>;
    let myDevice: wref<Device>;
    let myPosition: Vector4;
    let otherDevice: wref<Device>;
    let otherDevicePosition: Vector4;
    let registerLinkRequest: ref<RegisterNetworkLinkRequest>;
    let resourceToUse: FxResource;
    if ArraySize(relevantDevices) == 0 {
      return;
    };
    if this.IsAttachedToGame() {
      myDevice = this.GetOwnerEntityWeak() as Device;
      if !IsDefined(myDevice) {
        return;
      };
      myPosition = myDevice.GetNetworkBeamEndpoint();
      if Vector4.IsZero(myPosition) {
        return;
      };
    } else {
      return;
    };
    i = 0;
    while i < ArraySize(relevantDevices) {
      if relevantDevices[i].IsAttachedToGame() {
        otherDevice = relevantDevices[i].GetOwnerEntityWeak() as Device;
        if !IsDefined(otherDevice) {
        } else {
          otherDevicePosition = otherDevice.GetNetworkBeamEndpoint();
          if Vector4.IsZero(otherDevicePosition) {
          } else {
            goto 490;
          };
        };
      } else {
        goto 1435;
      };
      if registerAsMaster {
        linkData.masterID = PersistentID.ExtractEntityID(this.GetID());
        linkData.masterPos = myPosition;
        linkData.slaveID = PersistentID.ExtractEntityID(relevantDevices[i].GetID());
        linkData.slavePos = otherDevicePosition;
        if this.IsBreached() {
          resourceToUse = breachedResource;
        } else {
          resourceToUse = defaultResource;
        };
      } else {
        linkData.slaveID = PersistentID.ExtractEntityID(this.GetID());
        linkData.slavePos = myPosition;
        linkData.masterID = PersistentID.ExtractEntityID(relevantDevices[i].GetID());
        linkData.masterPos = otherDevicePosition;
        if (relevantDevices[i] as ScriptableDeviceComponentPS).IsBreached() {
          resourceToUse = breachedResource;
        } else {
          resourceToUse = defaultResource;
        };
      };
      linkData.isDynamic = this.IsLinkDynamic() || (relevantDevices[i] as ScriptableDeviceComponentPS).IsLinkDynamic();
      linkData.fxResource = resourceToUse;
      linkData.linkType = ELinkType.NETWORK;
      linkData.isPing = isPing;
      linkData.revealMaster = revealMaster;
      linkData.revealSlave = revealSlave;
      linkData.drawLink = true;
      linkData.lifetime = lifetime;
      if isPing {
        linkData.permanent = lifetime > 0.00;
      };
      ArrayPush(links, linkData);
      i += 1;
    };
    if ArraySize(links) == 0 {
      if !IsFinal() {
        LogDevices(this, "No links to be registered", ELogType.WARNING);
      };
      return;
    };
    registerLinkRequest = new RegisterNetworkLinkRequest();
    registerLinkRequest.linksData = links;
    this.GetNetworkSystem().QueueRequest(registerLinkRequest);
  }

  public func RevealDevicesGrid(shouldDraw: Bool, opt ownerEntityPosition: Vector4, opt fxDefault: FxResource, opt isPing: Bool, opt lifetime: Float, opt revealSlave: Bool, opt revealMaster: Bool, opt ignoreRevealed: Bool) -> Void {
    let ancestor: ref<ScriptableDeviceComponentPS>;
    let ancestors: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let linkData: SNetworkLinkData;
    let linksData: array<SNetworkLinkData>;
    let networkSystem: ref<NetworkSystem>;
    let parentEntity: ref<Device>;
    let parentPosition: Vector4;
    let registerLinkRequest: ref<RegisterNetworkLinkRequest>;
    let unregisterLinkRequest: ref<UnregisterNetworkLinksByIDRequest>;
    if !this.ShouldRevealDevicesGrid() {
      return;
    };
    networkSystem = this.GetNetworkSystem();
    if !shouldDraw {
      if networkSystem.HasNetworkLink(PersistentID.ExtractEntityID(this.GetID())) {
        unregisterLinkRequest = new UnregisterNetworkLinksByIDRequest();
        unregisterLinkRequest.ID = PersistentID.ExtractEntityID(this.GetID());
        networkSystem.QueueRequest(unregisterLinkRequest);
      };
      return;
    };
    if Vector4.IsZero(ownerEntityPosition) {
      return;
    };
    if this.IsUnpowered() && !this.CanRevealDevicesGridWhenUnpowered() || this.IsDisabled() || ignoreRevealed && this.WasRevealedInNetworkPing() {
      return;
    };
    if this.m_fullDepth {
      this.GetAncestors(ancestors);
    } else {
      this.GetParents(ancestors);
    };
    if ArraySize(ancestors) == 0 {
      return;
    };
    linkData.slaveID = PersistentID.ExtractEntityID(this.GetID());
    linkData.slavePos = ownerEntityPosition;
    linkData.linkType = ELinkType.GRID;
    linkData.isPing = isPing;
    linkData.lifetime = lifetime;
    linkData.revealMaster = revealMaster;
    linkData.revealSlave = revealMaster;
    if isPing {
      linkData.permanent = lifetime > 0.00;
    };
    linkData.fxResource = fxDefault;
    i = 0;
    while i < ArraySize(ancestors) {
      ancestor = ancestors[i] as ScriptableDeviceComponentPS;
      if ancestor == null || !ancestor.ShouldRevealDevicesGrid() || ignoreRevealed && ancestor.WasRevealedInNetworkPing() || ancestor.IsUnpowered() && !ancestor.CanRevealDevicesGridWhenUnpowered() {
      } else {
        parentEntity = ancestors[i].GetOwnerEntityWeak() as Device;
        if !IsDefined(parentEntity) {
          GameInstance.GetDeviceSystem(this.GetGameInstance()).GetNodePosition(PersistentID.ExtractEntityID(ancestors[i].GetID()), parentPosition);
        } else {
          parentPosition = parentEntity.GetNetworkBeamEndpoint();
        };
        if Vector4.IsZero(parentPosition) {
        } else {
          linkData.masterID = PersistentID.ExtractEntityID(ancestors[i].GetID());
          linkData.masterPos = parentPosition;
          linkData.drawLink = this.m_drawGridLink && ancestor.ShouldDrawGridLink();
          linkData.isDynamic = this.IsLinkDynamic() || ancestor.IsLinkDynamic();
          if isPing && !linkData.drawLink {
          } else {
            ArrayPush(linksData, linkData);
          };
        };
      };
      i += 1;
    };
    if ArraySize(linksData) > 0 {
      registerLinkRequest = new RegisterNetworkLinkRequest();
      registerLinkRequest.linksData = linksData;
      networkSystem.QueueRequest(registerLinkRequest);
    };
  }

  protected final func RevealDevicesGridOnEntity_Event(shouldDraw: Bool, target: EntityID) -> Void {
    let evt: ref<RevealDevicesGridOnEntityEvent> = new RevealDevicesGridOnEntityEvent();
    evt.shouldDraw = shouldDraw;
    this.GetPersistencySystem().QueueEntityEvent(target, evt);
  }

  protected func OnRevealNetworkGridEvent(evt: ref<RevealNetworkGridEvent>) -> EntityNotificationType {
    this.RevealNetworkGrid(evt.shouldDraw, evt.ownerEntityPosition, evt.fxDefault, evt.fxBreached, false, 0.00, evt.revealSlave, evt.revealMaster);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnRevealDevicesGridEvent(evt: ref<RevealDevicesGridEvent>) -> EntityNotificationType {
    this.RevealDevicesGrid(evt.shouldDraw, evt.ownerEntityPosition, evt.fxDefault, false, 0.00, evt.revealSlave, evt.revealMaster);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnPingNetworkGridEvent(evt: ref<PingNetworkGridEvent>) -> EntityNotificationType {
    this.RevealNetworkGrid(true, evt.ownerEntityPosition, evt.fxResource, evt.fxResource, true, evt.lifetime, evt.revealSlave, evt.revealMaster, evt.ignoreRevealed);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func ShouldDebug() -> Bool {
    return this.m_debugDevice;
  }

  public final const func GetDebugName() -> String {
    return NameToString(this.m_debugName);
  }

  public final const func GetDebugPath() -> CName {
    return this.m_debugPath;
  }

  public const func GetDebugTags() -> String {
    let tags: String = "PL";
    if this.HasPersonalLinkSlot() {
      tags += "+";
    } else {
      tags += "-";
    };
    return tags;
  }

  protected func LogActionDetails(action: ref<ScriptableDeviceAction>, opt cachedStatus: ref<BaseDeviceStatus>, opt context: String, opt status: String, opt overrideStatus: Bool) -> Void {
    let actionName: String;
    let boolValue: Bool;
    let deviceName: String;
    let preStatusString: String;
    let prop: ref<DeviceActionProperty>;
    let properties: array<ref<DeviceActionProperty>>;
    if this.IsLogInExclusiveMode() && !this.ShouldDebug() {
      return;
    };
    if !overrideStatus {
      status = this.GetDeviceStatusAction().GetCurrentDisplayString();
    };
    properties = action.GetProperties();
    prop = properties[0];
    if Equals(prop.typeName, n"Bool") {
      boolValue = FromVariant(prop.first);
    };
    if Equals(context, "") {
      context = "OnActionEvent - No context provided";
    };
    actionName = NameToString(action.actionName);
    deviceName = action.GetDeviceName();
    if !IsDefined(cachedStatus) {
      preStatusString = "No cached status";
    } else {
      preStatusString = cachedStatus.GetCurrentDisplayString();
    };
    Log(" ");
    Log("ACTION................ " + actionName);
    Log("PRE  - Action STATUS.. " + preStatusString);
    Log("POST - Action STATUS.. " + status);
    Log("Context............... " + context);
    Log("event received at..... " + this.GetDeviceName());
    Log("created by............ " + deviceName);
    Log("PersID DebugString.... " + PersistentID.ToDebugString(action.GetPersistentID()));
    Log("is device secured..... " + BoolToString(this.IsDeviceSecured()));
    Log("change requested by... " + EntityID.ToDebugStringDecimal(action.GetRequesterID()));
    Log("value................. " + BoolToString(boolValue));
  }

  public func GetWidgetTypeName() -> CName {
    return n"GenericDeviceWidget";
  }

  public func GetDeviceIconPath() -> String {
    return "";
  }

  public func GetDeviceIconID() -> CName {
    return n"device";
  }

  public func OnRequestActionWidgetsUpdate(evt: ref<RequestActionWidgetsUpdateEvent>) -> Void {
    this.RequestActionWidgetsUpdate(this.GetBlackboard());
  }

  public func OnRequestUIRefresh(evt: ref<RequestUIRefreshEvent>) -> Void {
    this.RefreshUI(this.GetBlackboard());
  }

  public func ResloveUIOnAction(action: ref<ScriptableDeviceAction>) -> Void {
    let deviceWidgetEvent: ref<RequestDeviceWidgetUpdateEvent>;
    let entityID: EntityID;
    if IsDefined(action) {
      if !action.HasUI() {
        return;
      };
      entityID = PersistentID.ExtractEntityID(this.GetID());
      this.RequestActionWidgetsUpdate(this.GetBlackboard());
      if action.GetRequesterID() != entityID {
        deviceWidgetEvent = new RequestDeviceWidgetUpdateEvent();
        deviceWidgetEvent.requester = this.GetID();
        this.GetPersistencySystem().QueueEntityEvent(action.GetRequesterID(), deviceWidgetEvent);
      };
    };
  }

  public const func GetVirtualSystem(out vs: ref<VirtualSystemPS>) -> Bool {
    let i: Int32;
    let masters: array<ref<DeviceComponentPS>>;
    this.GetParents(masters);
    i = 0;
    while i < ArraySize(masters) {
      if IsDefined(masters[i] as TerminalControllerPS) {
        if masters[i].GetVirtualSystem(this, vs) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) && !context.ignoresAuthorization {
      if this.IsDeviceSecuredWithPassword() {
        return t"DevicesUIDefinitions.GenericKeypadWidget";
      };
      return t"DevicesUIDefinitions.GenericKeypadWidget";
    };
    return this.GetInkWidgetTweakDBID(context);
  }

  public func OnThumbnailUI(evt: ref<ThumbnailUI>) -> EntityNotificationType {
    let deviceWidgetEvent: ref<RequestDeviceWidgetUpdateEvent>;
    let sAction: ref<ScriptableDeviceAction> = evt;
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    deviceWidgetEvent = new RequestDeviceWidgetUpdateEvent();
    deviceWidgetEvent.requester = this.GetID();
    this.GetPersistencySystem().QueueEntityEvent(sAction.GetRequesterID(), deviceWidgetEvent);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func RefreshUI(blackboard: ref<IBlackboard>) -> Void {
    let update: Bool;
    if IsDefined(blackboard) {
      update = blackboard.GetBool(this.GetBlackboardDef().UIupdate);
      blackboard.SetBool(this.GetBlackboardDef().UIupdate, !update);
      blackboard.FireCallbacks();
    };
  }

  public func RequestBreadCrumbUpdate(blackboard: ref<IBlackboard>, data: SBreadCrumbUpdateData) -> Void {
    if IsDefined(blackboard) {
      blackboard.SetVariant(this.GetBlackboardDef().BreadCrumbElement, ToVariant(data), true);
      blackboard.FireCallbacks();
    };
  }

  private final func ResolveDeviceWidgetTweakDBData(data: SDeviceWidgetPackage) -> SDeviceWidgetPackage {
    let record: ref<WidgetDefinition_Record>;
    if TDBID.IsValid(data.widgetTweakDBID) {
      record = TweakDBInterface.GetWidgetDefinitionRecord(data.widgetTweakDBID);
      if record != null {
        data.libraryPath = record.LibraryPath();
        data.libraryID = StringToName(record.LibraryID());
      };
    };
    return data;
  }

  protected func GetWidgetVisualState() -> EWidgetState {
    let widgetState: EWidgetState;
    if this.IsOFF() || this.IsUnpowered() {
      widgetState = EWidgetState.LOCKED;
    } else {
      widgetState = EWidgetState.ALLOWED;
    };
    return widgetState;
  }

  public func GetDeviceWidget(context: GetActionsContext) -> SDeviceWidgetPackage {
    let libraryID: CName;
    let libraryPath: ResRef;
    let widgetData: SDeviceWidgetPackage;
    if this.IsDisabled() {
      widgetData.isValid = false;
      return widgetData;
    };
    widgetData.widgetTweakDBID = this.GetInkWidgetTweakDBID(context);
    if SWidgetPackageBase.ResolveWidgetTweakDBData(widgetData.widgetTweakDBID, libraryID, libraryPath) {
      widgetData.libraryID = libraryID;
      widgetData.libraryPath = libraryPath;
    } else {
      widgetData.libraryPath = this.GetInkWidgetLibraryPath();
      widgetData.libraryID = this.GetInkWidgetLibraryID(context);
    };
    widgetData.isValid = ResRef.IsValid(widgetData.libraryPath) || IsNameValid(widgetData.libraryID);
    if !widgetData.isValid {
      return widgetData;
    };
    widgetData.widgetState = this.GetWidgetVisualState();
    widgetData.ownerID = this.GetID();
    widgetData.widgetName = this.GetDeviceName();
    widgetData.displayName = this.GetDeviceName();
    widgetData.actionWidgets = this.GetActionWidgets(context);
    widgetData.deviceStatus = "LocKey#42210";
    widgetData.bckgroundTextureID = this.GetBackgroundTextureTweakDBID();
    widgetData.deviceState = this.GetDeviceState();
    widgetData.textData = this.GetDeviceStatusTextData();
    return widgetData;
  }

  public func GetThumbnailWidget() -> SThumbnailWidgetPackage {
    let action: ref<ThumbnailUI>;
    let widgetData: SThumbnailWidgetPackage;
    if this.IsDisabled() {
      widgetData.isValid = false;
      return widgetData;
    };
    action = this.GetThumbnailAction();
    widgetData = action.GetThumbnailWidgetPackage();
    if !widgetData.isValid {
      return widgetData;
    };
    widgetData.ownerID = this.GetID();
    widgetData.iconID = this.GetDeviceIconID();
    widgetData.iconTextureID = this.GetDeviceIconTweakDBID();
    widgetData.textData = this.GetDeviceStatusTextData();
    widgetData.widgetState = this.GetWidgetVisualState();
    return widgetData;
  }

  protected func GetActionWidgets(context: GetActionsContext) -> array<SActionWidgetPackage> {
    let action: ref<ScriptableDeviceAction>;
    let actions: array<ref<DeviceAction>>;
    let i: Int32;
    let widgetData: SActionWidgetPackage;
    let widgetsData: array<SActionWidgetPackage>;
    this.GetActions(actions, context);
    this.FinalizeGetActions(actions);
    i = 0;
    while i < ArraySize(actions) {
      action = actions[i] as ScriptableDeviceAction;
      if action.HasUI() {
        widgetData = action.GetActionWidgetPackage();
        widgetData.ownerID = this.GetID();
        if widgetData.isValid {
          ArrayPush(widgetsData, widgetData);
        };
      };
      i += 1;
    };
    return widgetsData;
  }

  public func RequestActionWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SActionWidgetPackage> = this.GetActionWidgets(this.GenerateContext(gamedeviceRequestType.Internal, this.GetClearance()));
    if IsDefined(blackboard) {
      blackboard.SetVariant(this.GetBlackboardDef().ActionWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef().ActionWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  public func RequestDeviceWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    let widgetsData: array<SDeviceWidgetPackage>;
    ArrayPush(widgetsData, this.GetDeviceWidget(this.GenerateContext(gamedeviceRequestType.Internal, this.GetClearance())));
    if IsDefined(blackboard) && ArraySize(widgetsData) > 0 {
      blackboard.SetVariant(this.GetBlackboardDef().DeviceWidgetsData, ToVariant(widgetsData));
      blackboard.SignalVariant(this.GetBlackboardDef().DeviceWidgetsData);
      blackboard.FireCallbacks();
    };
  }

  protected func ResolveBaseActionOperation(action: ref<ScriptableDeviceAction>) -> Void {
    let evt: ref<PerformedAction> = new PerformedAction();
    evt.m_action = action;
    this.StorePerformedActionID(action);
    this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), evt);
    if action.GetRequesterID() != PersistentID.ExtractEntityID(this.GetID()) {
      evt = new PerformedAction();
      evt.m_action = action;
      this.GetPersistencySystem().QueueEntityEvent(action.GetRequesterID(), evt);
    };
  }

  public final const func GetDeviceOperationsContainer() -> ref<DeviceOperationsContainer> {
    return this.m_deviceOperationsSetup;
  }

  public final func StorePerformedActionID(oryginalAction: ref<ScriptableDeviceAction>) -> Void {
    let context: EActionContext;
    let newStructure: SPerformedActions;
    let actionID: CName = oryginalAction.GetActionID();
    let index: Int32 = this.WasActionPerformed(actionID);
    if index > -1 {
      newStructure = this.m_performedActions[index];
      ArrayRemove(this.m_performedActions, this.m_performedActions[index]);
    } else {
      newStructure.ID = actionID;
    };
    context = SPerformedActions.GetContextFromAction(this.GetID(), oryginalAction);
    if !SPerformedActions.ContainsActionContext(newStructure, context) {
      ArrayPush(newStructure.ActionContext, context);
    };
    ArrayPush(this.m_performedActions, newStructure);
  }

  public final func ResetPerformedActionsStorage() -> Void {
    ArrayClear(this.m_performedActions);
  }

  public final const func GetPerformedActionsIDs() -> array<CName> {
    let IDs: array<CName>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_performedActions) {
      ArrayPush(IDs, this.m_performedActions[i].ID);
      i += 1;
    };
    return IDs;
  }

  public final const func GetPerformedActions() -> array<SPerformedActions> {
    return this.m_performedActions;
  }

  public final const func WasActionPerformed(actionID: CName) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_performedActions) {
      if Equals(this.m_performedActions[i].ID, actionID) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final const quest func WasDeviceActionPerformed(actionID: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_performedActions) {
      if Equals(this.m_performedActions[i].ID, actionID) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func WasActionPerformed(actionID: CName, context: EActionContext) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_performedActions) {
      if Equals(this.m_performedActions[i].ID, actionID) {
        if SPerformedActions.ContainsActionContext(this.m_performedActions[i], context) {
          return true;
        };
        return false;
      };
      i += 1;
    };
    return false;
  }

  public final const func IsIniatialStateOperationPerformed() -> Bool {
    return this.m_isInitialStateOperationPerformed;
  }

  public final func SetInitialStateOperataionPerformed(value: Bool) -> Void {
    this.m_isInitialStateOperationPerformed = value;
  }

  public func DetermineInteractionState(interactionComponent: ref<InteractionComponent>, context: GetActionsContext) -> Void {
    let actions: array<ref<DeviceAction>>;
    let activeChoices: array<InteractionChoice>;
    let allChoices: array<InteractionChoice>;
    if this.m_isLockedViaSequencer {
      return;
    };
    if !(Equals(context.requestType, gamedeviceRequestType.Direct) || Equals(context.requestType, gamedeviceRequestType.Remote)) {
      return;
    };
    if this.m_isInteractive && !this.GetHudManager().IsQuickHackPanelOpened() {
      if this.HasActiveContext(gamedeviceRequestType.Remote) {
        if !this.m_disableQuickHacks && (this.IsQuickHacksExposed() || this.m_debugExposeQuickHacks) {
          if this.IsPowered() {
            this.GetQuickHackActions(actions, context);
            this.UpdateAvailAbleQuickHacks(actions);
          };
        };
        if this.IsSpiderbotActionsConditionsFulfilled() {
          this.GetSpiderbotActions(actions, context);
          this.UpdateAvailableSpiderbotActions(actions);
        };
      };
      if this.HasActiveContext(gamedeviceRequestType.Direct) {
        if !this.GetTakeOverControlSystem().IsDeviceControlled() {
          this.GetActions(actions, context);
          this.FinalizeGetActions(actions);
        };
      };
      BasicInteractionInterpreter.Evaluate(this.IsDeviceSecured(), actions, allChoices, activeChoices);
      if ArraySize(activeChoices) == 0 && NotEquals(context.requestType, gamedeviceRequestType.Remote) {
        this.PushInactiveInteractionChoice(context, allChoices);
      };
    };
    this.PushChoicesToInteractionComponent(interactionComponent, context, allChoices);
  }

  public final static func SetActionsInactiveAll(actions: script_ref<array<ref<DeviceAction>>>, opt reason: String, opt exludedAction: CName) -> Void {
    let sAction: ref<ScriptableDeviceAction>;
    let i: Int32 = 0;
    while i < ArraySize(Deref(actions)) {
      sAction = Deref(actions)[i] as ScriptableDeviceAction;
      if IsNameValid(exludedAction) && Equals(sAction.GetClassName(), exludedAction) {
      } else {
        sAction.SetInactive();
        sAction.SetInactiveReason(reason);
      };
      i += 1;
    };
  }

  protected func PushInactiveInteractionChoice(context: GetActionsContext, out choices: array<InteractionChoice>) -> Void {
    let inactiveChoice: InteractionChoice;
    let baseAction: ref<DisassembleDevice> = this.ActionDisassembleDevice();
    inactiveChoice.choiceMetaData.tweakDBName = baseAction.GetTweakDBChoiceRecord();
    inactiveChoice.caption = "DEBUG: Reason Unhandled";
    ChoiceTypeWrapper.SetType(inactiveChoice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
  }

  protected final func DetermineAreaHintIndicatorState(context: GetActionsContext) -> Void {
    let actions: array<ref<DeviceAction>>;
    let activeChoices: array<InteractionChoice>;
    let allChoices: array<InteractionChoice>;
    context.requestType = gamedeviceRequestType.Direct;
    this.GetActions(actions, context);
    if this.IsQuickHacksExposed() && this.m_isScanned {
      context.requestType = gamedeviceRequestType.Remote;
      this.GetActions(actions, context);
    };
    BasicInteractionInterpreter.Evaluate(this.IsDeviceSecured(), actions, allChoices, activeChoices);
  }

  private final func PushChoicesToInteractionComponent(interactionComponent: ref<InteractionComponent>, context: GetActionsContext, choices: script_ref<array<InteractionChoice>>) -> Void {
    let layerName: CName;
    let requestType: gamedeviceRequestType;
    let shouldPushChoices: Bool;
    if this.HasActiveContext(gamedeviceRequestType.Direct) {
      requestType = gamedeviceRequestType.Direct;
    } else {
      requestType = gamedeviceRequestType.Remote;
    };
    switch requestType {
      case gamedeviceRequestType.Direct:
        layerName = n"direct";
        shouldPushChoices = true;
    };
    if IsDefined(interactionComponent) {
      interactionComponent.ResetChoices(layerName);
    };
    if ArraySize(Deref(choices)) == 0 {
      return;
    };
    if shouldPushChoices {
      if this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
        this.TutorialProcessSkillcheck(Deref(choices));
      };
      if IsDefined(interactionComponent) {
        interactionComponent.SetChoices(Deref(choices), layerName);
      };
    };
  }

  private final func TutorialProcessSkillcheck(choices: array<InteractionChoice>) -> Void {
    let i: Int32;
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
    if questSystem.GetFact(n"skillcheck_tutorial") > 0 || questSystem.GetFact(n"disable_tutorials") != 0 {
      return;
    };
    i = 0;
    while i < ArraySize(choices) {
      if ChoiceTypeWrapper.IsType(choices[i].choiceMetaData.type, gameinteractionsChoiceType.CheckFailed) {
        questSystem.SetFact(n"skillcheck_tutorial", 1);
        return;
      };
      i += 1;
    };
  }

  public const func GenerateContext(requestType: gamedeviceRequestType, providedClearance: ref<Clearance>, opt providedProcessInitiator: ref<GameObject>, opt providedRequestor: EntityID) -> GetActionsContext {
    let device: ref<Device>;
    let generatedContext: GetActionsContext;
    generatedContext.clearance = providedClearance;
    if EntityID.IsDefined(providedRequestor) {
      generatedContext.requestorID = providedRequestor;
    } else {
      generatedContext.requestorID = this.GetMyEntityID();
    };
    generatedContext.requestType = requestType;
    if Equals(requestType, gamedeviceRequestType.Remote) {
      generatedContext.interactionLayerTag = n"remote";
    } else {
      if Equals(requestType, gamedeviceRequestType.Direct) {
        generatedContext.interactionLayerTag = n"direct";
      } else {
        if Equals(requestType, gamedeviceRequestType.Internal) {
          generatedContext.interactionLayerTag = n"any";
        } else {
          if Equals(requestType, gamedeviceRequestType.External) {
            generatedContext.interactionLayerTag = n"any";
          };
        };
      };
    };
    if IsDefined(providedProcessInitiator) {
      generatedContext.processInitiatorObject = providedProcessInitiator;
    } else {
      device = this.GetOwnerEntityWeak() as Device;
      if IsDefined(device) && device.IsPlayerAround() {
        generatedContext.processInitiatorObject = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
      };
    };
    return generatedContext;
  }

  protected func DetermineGameplayViability(context: GetActionsContext, hasActiveActions: Bool) -> Bool {
    let decision: EViabilityDecision = BasicViabilityInterpreter.Evaluate(this, hasActiveActions);
    if Equals(decision, EViabilityDecision.NONVIABLE) {
      return false;
    };
    return true;
  }

  protected func PushReturnActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let shouldReturn: Bool;
    if this.IsUnpowered() {
      shouldReturn = true;
      if Equals(context.requestType, gamedeviceRequestType.Direct) {
        this.PushSkillCheckActions(outActions, context);
      };
    } else {
      if Equals(context.requestType, gamedeviceRequestType.Direct) {
        if this.PushSkillCheckActions(outActions, context) {
          shouldReturn = true;
        };
      };
      if IsDefined(context.processInitiatorObject) {
        if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) && !context.ignoresAuthorization && !this.CanPayToAuthorize() {
          shouldReturn = true;
          if this.IsDeviceSecuredWithPassword() {
            ArrayPush(outActions, this.ActionAuthorizeUser());
          } else {
            ArrayPush(outActions, this.ActionAuthorizeUser());
          };
        };
      };
    };
    return shouldReturn;
  }

  protected final const func SetActionIllegality(out outActions: array<ref<DeviceAction>>, isIllegal: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(outActions) {
      if IsDefined(outActions[i] as ScriptableDeviceAction) {
        (outActions[i] as ScriptableDeviceAction).SetIllegal(isIllegal);
      };
      i += 1;
    };
  }

  public final func GetRemoteActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    if this.m_disableQuickHacks || this.IsDisabled() {
      return;
    };
    this.GetQuickHackActions(outActions, context);
    if !this.IsQuickHacksExposed() || this.IsLockedViaSequencer() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7021", n"RemoteBreach");
    };
  }

  protected final const func EvaluateActionsRPGAvailabilty(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let i: Int32;
    if context.ignoresRPG {
      return;
    };
    i = ArraySize(outActions) - 1;
    while i >= 0 {
      action = outActions[i] as ScriptableDeviceAction;
      if this.IsActionRPGRequirementDisabled(action.GetObjectActionID()) {
        action.SetIsActionRPGCheckDissabled(true);
      };
      if !this.IsActionRPGRequirementDisabled(action.GetObjectActionID()) && !action.IsVisible(context) {
        if IsDefined(action as RemoteBreach) && IsStringValid(action.GetInactiveReason()) {
          action.SetInactiveWithReason(false, action.GetInactiveReason());
        } else {
          action.SetInactiveWithReason(false, "LocKey#53826");
        };
      };
      i -= 1;
    };
  }

  protected final func SetActionsQuickHacksExecutioner(out outActions: array<ref<DeviceAction>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(outActions) {
      if IsDefined(outActions[i] as ScriptableDeviceAction) {
        (outActions[i] as ScriptableDeviceAction).SetExecutor(this.GetLocalPlayerControlledGameObject());
      };
      i += 1;
    };
  }

  protected final func MarkActionsAsQuickHacks(out actionsToMark: array<ref<DeviceAction>>) -> Void {
    let acion: ref<ScriptableDeviceAction>;
    let i: Int32 = 0;
    while i < ArraySize(actionsToMark) {
      acion = actionsToMark[i] as ScriptableDeviceAction;
      if IsDefined(acion) {
        acion.SetAsQuickHack(this.WasActionPerformed(acion.GetActionID(), EActionContext.QHack));
      };
      i += 1;
    };
  }

  protected final func MarkActionsAsSpiderbotActions(out actionsToMark: array<ref<DeviceAction>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(actionsToMark) {
      if IsDefined(actionsToMark[i] as ScriptableDeviceAction) {
        (actionsToMark[i] as ScriptableDeviceAction).SetAsSpiderbotAction();
      };
      i += 1;
    };
  }

  protected final func ExtractActions(actionNames: array<CName>) -> array<ref<DeviceAction>> {
    let extractedActions: array<ref<DeviceAction>>;
    let i: Int32 = 0;
    while i < ArraySize(actionNames) {
      ArrayPush(extractedActions, this.GetActionByName(actionNames[i]));
      (extractedActions[i] as ScriptableDeviceAction).RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
      i += 1;
    };
    return extractedActions;
  }

  public func GetQuestActionByName(actionName: CName) -> ref<DeviceAction> {
    let action: ref<DeviceAction>;
    switch actionName {
      case n"ForceEnabled":
        action = this.ActionQuestForceEnabled();
        break;
      case n"ForceDisabled":
        action = this.ActionQuestForceDisabled();
        break;
      case n"ForcePower":
        action = this.ActionQuestForcePower();
        break;
      case n"ForceUnpower":
        action = this.ActionQuestForceUnpower();
        break;
      case n"ForceON":
        action = this.ActionQuestForceON();
        break;
      case n"ForceOFF":
        action = this.ActionQuestForceOFF();
        break;
      case n"QuestResetDeviceToInitialState":
        action = this.ActionQuestResetDeviceToInitialState();
        break;
      case n"ForceDestructible":
        action = this.ActionQuestForceDestructible();
        break;
      case n"QuestForceIndestructible":
        action = this.ActionQuestForceIndestructible();
        break;
      case n"QuestForceInvulnerable":
        action = this.ActionQuestForceInvulnerable();
        break;
      case n"AuthorizationEnable":
        action = this.ActionQuestForceAuthorizationEnabled();
        break;
      case n"AuthorizationDisable":
        action = this.ActionQuestForceAuthorizationDisabled();
        break;
      case n"EnableFixing":
        action = this.ActionQuestEnableFixing();
        break;
      case n"DisableFixing":
        action = this.ActionQuestDisableFixing();
        break;
      case n"QuestRemoveQuickHacks":
        action = this.ActionQuestRemoveQuickHacks();
        break;
      case n"QuestForceDisconnectPersonalLink":
        action = this.ActionQuestForceDisconnectPersonalLink();
        break;
      case n"QuestForcePersonalLinkUnderStrictQuestControl":
        action = this.ActionQuestForcePersonalLinkUnderStrictQuestControl();
        break;
      case n"QuestStartGlitch":
        action = this.ActionQuestStartGlitch();
        break;
      case n"QuestStopGlitch":
        action = this.ActionQuestStopGlitch();
        break;
      case n"QuestResetPerformedActionsStorage":
        action = this.ActionQuestResetPerfomedActionsStorage();
        break;
      case n"JuryrigTrapArmed":
        action = this.ActionQuestForceJuryrigTrapArmed();
        break;
      case n"JuryrigTrapDeactivate":
        action = this.ActionQuestForceJuryrigTrapDeactivated();
        break;
      case n"QuestForceEnableCameraZoom":
        action = this.ActionQuestForceCameraZoom(true);
        break;
      case n"QuestForceDisableCameraZoom":
        action = this.ActionQuestForceCameraZoom(false);
    };
    return action;
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    if Clearance.IsInRange(context.clearance, DefaultActionsParametersHolder.GetQuestClearance()) {
      ArrayPush(outActions, this.ActionQuestForceEnabled());
      ArrayPush(outActions, this.ActionQuestForceDisabled());
      ArrayPush(outActions, this.ActionQuestForcePower());
      ArrayPush(outActions, this.ActionQuestForceUnpower());
      ArrayPush(outActions, this.ActionQuestForceON());
      ArrayPush(outActions, this.ActionQuestForceOFF());
      ArrayPush(outActions, this.ActionQuestResetDeviceToInitialState());
      ArrayPush(outActions, this.ActionQuestForceDestructible());
      ArrayPush(outActions, this.ActionQuestForceIndestructible());
      ArrayPush(outActions, this.ActionQuestForceInvulnerable());
      ArrayPush(outActions, this.ActionQuestForceAuthorizationEnabled());
      ArrayPush(outActions, this.ActionQuestForceAuthorizationDisabled());
      ArrayPush(outActions, this.ActionQuestEnableFixing());
      ArrayPush(outActions, this.ActionQuestDisableFixing());
      ArrayPush(outActions, this.ActionQuestRemoveQuickHacks());
      ArrayPush(outActions, this.ActionQuestForceDisconnectPersonalLink());
      ArrayPush(outActions, this.ActionQuestForcePersonalLinkUnderStrictQuestControl());
      ArrayPush(outActions, this.ActionQuestStartGlitch());
      ArrayPush(outActions, this.ActionQuestStopGlitch());
      ArrayPush(outActions, this.ActionQuestResetPerfomedActionsStorage());
      if this.m_canBeTrapped {
        ArrayPush(outActions, this.ActionQuestForceJuryrigTrapArmed());
        ArrayPush(outActions, this.ActionQuestForceJuryrigTrapDeactivated());
      };
      ArrayPush(outActions, this.ActionQuestForceCameraZoom(true));
      ArrayPush(outActions, this.ActionQuestForceCameraZoom(false));
    };
    return;
  }

  protected const func ActionDeviceStatus() -> ref<BaseDeviceStatus> {
    let action: ref<BaseDeviceStatus> = new BaseDeviceStatus();
    action.clearanceLevel = DefaultActionsParametersHolder.GetStatusClearance();
    action.SetUp(this);
    action.SetProperties(this);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionToggleActivation() -> ref<ToggleActivation> {
    let action: ref<ToggleActivation> = new ToggleActivation();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleActivationClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnToggleActivation(evt: ref<ToggleActivation>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    let value: Bool = FromVariant(evt.prop.first);
    if !value {
      this.DisableDevice();
    } else {
      this.EnableDevice();
    };
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionToggleActivate() -> ref<ToggleActivate> {
    let action: ref<ToggleActivate> = new ToggleActivate();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties(this.m_activationState);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnToggleActivate(evt: ref<ToggleActivate>) -> EntityNotificationType {
    if Equals(this.m_activationState, EActivationState.DEACTIVATED) {
      this.ExecutePSAction(this.ActionActivateDevice());
    } else {
      this.ExecutePSAction(this.ActionDeactivateDevice());
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionActivateDevice() -> ref<ActivateDevice> {
    let action: ref<ActivateDevice> = new ActivateDevice();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties(n"LocKey#233");
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.m_activationState = EActivationState.ACTIVATED;
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionDeactivateDevice() -> ref<DeactivateDevice> {
    let action: ref<DeactivateDevice> = new DeactivateDevice();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties(n"Deactivate");
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  protected func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> EntityNotificationType {
    this.m_activationState = EActivationState.DEACTIVATED;
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionTogglePower() -> ref<TogglePower> {
    let action: ref<TogglePower> = new TogglePower();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnTogglePower(evt: ref<TogglePower>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let value: Bool;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    value = FromVariant(evt.prop.first);
    if !value {
      this.UnpowerDevice();
    } else {
      this.PowerDevice();
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionToggleON() -> ref<ToggleON> {
    let action: ref<ToggleON> = new ToggleON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnToggleON(evt: ref<ToggleON>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let player: ref<GameObject>;
    let value: Bool;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    value = FromVariant(evt.prop.first);
    if !value {
      this.SetDeviceState(EDeviceStatus.ON);
    } else {
      this.SetDeviceState(EDeviceStatus.OFF);
      player = this.GetLocalPlayer();
      if player == evt.GetExecutor() {
        this.SetBlockSecurityWakeUp(true);
      };
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionSetDeviceON() -> ref<SetDeviceON> {
    let action: ref<SetDeviceON> = new SetDeviceON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnSetDeviceON(evt: ref<SetDeviceON>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.ON);
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionSetDeviceOFF() -> ref<SetDeviceOFF> {
    let action: ref<SetDeviceOFF> = new SetDeviceOFF();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnSetDeviceOFF(evt: ref<SetDeviceOFF>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.OFF);
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionSetDevicePowered() -> ref<SetDevicePowered> {
    let action: ref<SetDevicePowered> = new SetDevicePowered();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSetOnSetOffActions();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnSetDevicePowered(evt: ref<SetDevicePowered>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier>;
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled");
    };
    this.PowerDevice();
    this.Notify(notifier, evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func ActionSetDeviceUnpowered() -> ref<SetDeviceUnpowered> {
    let action: ref<SetDeviceUnpowered> = new SetDeviceUnpowered();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSetOnSetOffActions();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnSetDeviceUnpowered(evt: ref<SetDeviceUnpowered>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus>;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction();
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled");
    };
    this.UnpowerDevice();
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionTogglePersonalLink(executor: wref<GameObject>, opt questForcesDisconnection: Bool, opt skipMinigame: Bool) -> ref<TogglePersonalLink> {
    let action: ref<TogglePersonalLink> = new TogglePersonalLink();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    if questForcesDisconnection && Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) {
      this.m_personalLinkStatus = EPersonalLinkConnectionStatus.CONNECTED;
    };
    action.SetProperties(this.m_personalLinkStatus, skipMinigame);
    action.AddDeviceName(this.m_deviceName);
    action.SetExecutor(executor);
    if TDBID.IsValid(this.m_personalLinkCustomInteraction) && this.m_personalLinkCustomInteraction != t"Interactions.None" && !this.IsPersonalLinkConnected() {
      action.CreateInteraction(this.m_personalLinkCustomInteraction);
    } else {
      action.CreateInteraction();
    };
    action.SetIllegal(true);
    return action;
  }

  public final func OnTogglePersonalLink(evt: ref<TogglePersonalLink>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsPlayerPerformingTakedown() || this.IsDisruptivePlayerStatusEffectPresent() {
      this.m_personalLinkStatus = EPersonalLinkConnectionStatus.NOT_CONNECTED;
      return EntityNotificationType.SendThisEventToEntity;
    };
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) && evt.GetDurationValue() == 0.00 {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED) {
      this.m_personalLinkStatus = EPersonalLinkConnectionStatus.NOT_CONNECTED;
      this.ResolvePersonalLinkConnection(evt, true);
      this.UseNotifier(evt);
      return EntityNotificationType.SendThisEventToEntity;
    };
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING) {
      if !evt.IsCompleted() {
        this.m_personalLinkStatus = EPersonalLinkConnectionStatus.NOT_CONNECTED;
        this.ResolvePersonalLinkConnection(evt, true);
        this.UseNotifier(evt);
        return EntityNotificationType.SendThisEventToEntity;
      };
    };
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) {
      this.m_personalLinkStatus = EPersonalLinkConnectionStatus.CONNECTING;
    };
    if evt.IsCompleted() && Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING) {
      this.m_personalLinkStatus = EPersonalLinkConnectionStatus.CONNECTED;
      if this.IsUnpowered() || this.IsDisabled() {
        return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered, Disabled");
      };
      this.ResolvePersonalLinkConnection(evt, false);
    } else {
      if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING) {
        this.ExecutePSActionWithDelay(evt, this);
      };
    };
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ResolvePersonalLinkConnection(evt: ref<TogglePersonalLink>, abortOperations: Bool) -> Void {
    let hasNetworkBackdoor: Bool;
    let toggleNetrunnerDive: ref<ToggleNetrunnerDive>;
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING) {
      if !IsFinal() {
        LogDevices(this, "Unhandled case. This function should be called when personal link is connected or disconnected. Only. Debug", ELogType.ERROR);
      };
      return;
    };
    hasNetworkBackdoor = this.HasNetworkBackdoor();
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED) {
      if this.m_shouldSkipNetrunnerMinigame || !hasNetworkBackdoor {
        this.SetMinigameState(HackingMinigameState.Succeeded);
      };
      if hasNetworkBackdoor && !this.WasHackingMinigameSucceeded() {
        toggleNetrunnerDive = this.ActionToggleNetrunnerDive(abortOperations, evt.m_shouldSkipMiniGame);
        toggleNetrunnerDive.SetExecutor(evt.GetExecutor());
        this.ExecutePSAction(toggleNetrunnerDive, evt.GetInteractionLayer());
      } else {
        this.ResolveOtherSkillchecks();
      };
    } else {
      if this.HasNetworkBackdoor() {
        toggleNetrunnerDive = this.ActionToggleNetrunnerDive(true);
        toggleNetrunnerDive.SetExecutor(evt.GetExecutor());
        this.ExecutePSAction(toggleNetrunnerDive, evt.GetInteractionLayer());
      };
    };
  }

  public final func DisconnectPersonalLink(executor: ref<GameObject>, layer: CName, opt isForcedByQuest: Bool) -> Void {
    let emptyTweak: TweakDBID;
    let togglePersonalLink: ref<TogglePersonalLink>;
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) {
      return;
    };
    if this.m_disablePersonalLinkAutoDisconnect && !isForcedByQuest {
      return;
    };
    this.m_personalLinkForced = false;
    if this.m_disablePersonalLinkAutoDisconnect {
      this.m_disablePersonalLinkAutoDisconnect = false;
      if isForcedByQuest {
        togglePersonalLink = this.ActionTogglePersonalLink(this.GetPlayerMainObject(), isForcedByQuest);
        this.ExecutePSAction(togglePersonalLink, layer);
        this.m_personalLinkCustomInteraction = emptyTweak;
      };
      return;
    };
    togglePersonalLink = this.ActionTogglePersonalLink(executor);
    this.ExecutePSAction(togglePersonalLink, layer);
  }

  public final func DisconnectPersonalLink(evt: ref<ScriptableDeviceAction>, opt isForcedByQuest: Bool) -> Void {
    this.DisconnectPersonalLink(evt.GetExecutor(), evt.GetInteractionLayer(), isForcedByQuest);
  }

  private final const func ActionRemoteBreach() -> ref<RemoteBreach> {
    let action: ref<RemoteBreach> = new RemoteBreach();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.SetObjectActionID(t"DeviceAction.RemoteBreach");
    return action;
  }

  private final func OnActionRemoteBreach(evt: ref<RemoteBreach>) -> EntityNotificationType {
    this.GetNetworkBlackboard().SetBool(this.GetNetworkBlackboardDef().RemoteBreach, true);
    this.ExecutePSAction(this.ActionToggleNetrunnerDive(false, false, true), this);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final const func ActionPing() -> ref<PingDevice> {
    let action: ref<PingDevice> = new PingDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.SetObjectActionID(t"DeviceAction.PingDevice");
    return action;
  }

  private final func OnActionPing(evt: ref<PingDevice>) -> EntityNotificationType {
    let ap: ref<AccessPointControllerPS>;
    let slave: ref<DeviceComponentPS>;
    if this.m_hasNetworkBackdoor {
      ap = this.GetBackdoorAccessPoint();
    };
    if IsDefined(ap) {
      slave = this.GetAttachedSlaveForPing(ap);
    } else {
      if !this.IsAttachedToGame() {
        slave = this.GetAttachedSlaveForPing();
      };
    };
    if IsDefined(slave) {
      this.QueuePSEvent(slave, evt);
      return EntityNotificationType.DoNotNotifyEntity;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final const func GetNetworkBlackboardDef() -> ref<NetworkBlackboardDef> {
    return GetAllBlackboardDefs().NetworkBlackboard;
  }

  private final const func GetNetworkBlackboard() -> ref<IBlackboard> {
    return GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(this.GetNetworkBlackboardDef());
  }

  private final func OnPingSquadEvent(evt: ref<ForwardPingToSquadEvent>) -> EntityNotificationType {
    this.PingSquad();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private func PingSquad() -> Void {
    let evt: ref<ForwardPingToSquadEvent>;
    let aps: array<ref<AccessPointControllerPS>> = this.GetAccessPoints();
    let i: Int32 = 0;
    while i < ArraySize(aps) {
      evt = new ForwardPingToSquadEvent();
      this.QueuePSEvent(aps[i], evt);
      i += 1;
    };
  }

  protected final const func ActionToggleNetrunnerDive(abortDive: Bool, opt skipMinigame: Bool, opt isRemote: Bool) -> ref<ToggleNetrunnerDive> {
    let action: ref<ToggleNetrunnerDive> = new ToggleNetrunnerDive();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleAuthorizationClearance();
    action.SetUp(this);
    action.SetProperties(abortDive, skipMinigame, this.m_minigameAttempt, isRemote);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnToggleNetrunnerDive(evt: ref<ToggleNetrunnerDive>) -> EntityNotificationType {
    if evt.ShouldTerminate() {
      this.DisconnectPersonalLink(evt);
      return EntityNotificationType.SendThisEventToEntity;
    };
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED) || evt.m_isRemote {
      if this.m_shouldSkipNetrunnerMinigame || evt.m_skipMinigame {
        this.ResolveDive(false);
        this.DisconnectPersonalLink(evt);
      } else {
        return EntityNotificationType.SendThisEventToEntity;
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected const func ResolveDive(isBackdoor: Bool) -> Void {
    let ap: ref<AccessPointControllerPS>;
    let aps: array<ref<AccessPointControllerPS>>;
    let i: Int32;
    let isRemoteBreach: Bool = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().NetworkBlackboard).GetBool(GetAllBlackboardDefs().NetworkBlackboard.RemoteBreach);
    let exposeQuickHacks: ref<SetExposeQuickHacks> = new SetExposeQuickHacks();
    exposeQuickHacks.isRemote = isRemoteBreach;
    let bumpMinigameLevel: ref<BumpNetrunnerMinigameLevel> = new BumpNetrunnerMinigameLevel();
    bumpMinigameLevel.Set(this.GetPlayerMainObject(), this.m_skillCheckContainer.GetHackingSlot().GetBaseSkill().GetRequiredLevel(this.GetGameInstance()));
    (GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem).QueueRequest(bumpMinigameLevel);
    if isBackdoor && isRemoteBreach {
      aps = this.GetAccessPoints();
      i = 0;
      while i < ArraySize(aps) {
        this.ExecutePSAction(exposeQuickHacks, aps[i]);
        i += 1;
      };
      return;
    };
    if !this.HasNetworkBackdoor() {
      if !IsFinal() {
        LogDevices(this, "ResolveDive called on device that does not have a backdoor", ELogType.ERROR);
      };
      return;
    };
    ap = this.GetBackdoorAccessPoint();
    if IsDefined(ap) {
      this.ExecutePSAction(exposeQuickHacks, ap);
      return;
    };
    if !IsFinal() {
      LogDevices(this, "NO ACCESS POINT FOUND FOR BACKDOOR DEVICE. DEBUG", ELogType.ERROR);
    };
    return;
  }

  public final func HackingMinigameEnded(state: HackingMinigameState) -> Void {
    this.SetMinigameState(state);
    this.FinalizeNetrunnerDive(state);
  }

  protected final func SetMinigameState(state: HackingMinigameState) -> Void {
    this.m_hackingMinigameState = state;
    if this.IsPersonalLinkConnected() && Equals(state, HackingMinigameState.Succeeded) {
      this.TurnAuthorizationModuleOFF();
      this.m_skillCheckContainer.GetHackingSlot().SetIsActive(false);
      this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(true);
      this.m_skillCheckContainer.GetHackingSlot().CheckPerformed();
      this.ResolveOtherSkillchecks();
    };
  }

  public final const quest func WasHackingMinigameSucceeded() -> Bool {
    return Equals(this.m_hackingMinigameState, HackingMinigameState.Succeeded);
  }

  public final const quest func WashackingMinigameFailed() -> Bool {
    return Equals(this.m_hackingMinigameState, HackingMinigameState.Failed);
  }

  public func FinalizeNetrunnerDive(state: HackingMinigameState) -> Void {
    let player: ref<GameObject>;
    let toggleNetrunnerDive: ref<ToggleNetrunnerDive>;
    if Equals(state, HackingMinigameState.Succeeded) {
      this.ResolveDive(!this.HasNetworkBackdoor());
    } else {
      if Equals(state, HackingMinigameState.Failed) {
        this.m_minigameAttempt += 1;
      };
    };
    player = this.GetPlayerMainObject();
    toggleNetrunnerDive = this.ActionToggleNetrunnerDive(true);
    toggleNetrunnerDive.SetExecutor(player);
    this.ExecutePSAction(toggleNetrunnerDive);
  }

  public final func ActionToggleZoomInteraction() -> ref<ToggleZoomInteraction> {
    let action: ref<ToggleZoomInteraction> = new ToggleZoomInteraction();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isAdvancedInteractionModeOn);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected final func ActionQuestForceCameraZoom(value: Bool) -> ref<QuestForceCameraZoom> {
    let action: ref<QuestForceCameraZoom> = new QuestForceCameraZoom();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(value);
    action.AddDeviceName(this.m_deviceName);
    action.SetUseWorkspot(true);
    return action;
  }

  protected final func ActionQuestForceCameraZoomNoWorkspot(value: Bool) -> ref<QuestForceCameraZoom> {
    let action: ref<QuestForceCameraZoom> = new QuestForceCameraZoom();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties(value);
    action.AddDeviceName(this.m_deviceName);
    action.SetUseWorkspot(false);
    return action;
  }

  protected final func ActionOpenFullscreenUI() -> ref<OpenFullscreenUI> {
    let action: ref<OpenFullscreenUI> = new OpenFullscreenUI();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isAdvancedInteractionModeOn);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public func OnToggleZoomInteraction(evt: ref<ToggleZoomInteraction>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.UseNotifier(evt);
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled (or both)");
    };
    this.m_isAdvancedInteractionModeOn = !this.m_isAdvancedInteractionModeOn;
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestForceCameraZoom(evt: ref<QuestForceCameraZoom>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.UseNotifier(evt);
    this.m_isAdvancedInteractionModeOn = FromVariant(evt.prop.first);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnSetCustomPersonalLinkReason(evt: ref<SetCustomPersonalLinkReason>) -> EntityNotificationType {
    if evt.reason == t"Interactions.None" {
      this.m_personalLinkForced = false;
      this.m_disablePersonalLinkAutoDisconnect = false;
    } else {
      this.m_personalLinkForced = true;
      this.m_disablePersonalLinkAutoDisconnect = true;
    };
    this.m_personalLinkCustomInteraction = evt.reason;
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnOpenFullscreenUI(evt: ref<OpenFullscreenUI>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.UseNotifier(evt);
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled (or both)");
    };
    this.m_isAdvancedInteractionModeOn = !this.m_isAdvancedInteractionModeOn;
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionDisassembleDevice() -> ref<DisassembleDevice> {
    let action: ref<DisassembleDevice> = new DisassembleDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetDisassembleClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected func ActionFixDevice() -> ref<FixDevice> {
    let action: ref<FixDevice> = new FixDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetFixingClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public func OnFixDevice(evt: ref<FixDevice>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_destructionProperties.m_canBeFixed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.TurnAuthorizationModuleOFF();
    this.m_disassembleProperties.m_canBeDisassembled = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionToggleJuryrigTrap() -> ref<ToggleJuryrigTrap> {
    let action: ref<ToggleJuryrigTrap> = new ToggleJuryrigTrap();
    action.SetUp(this);
    action.SetProperties(this.m_juryrigTrapState);
    action.AddDeviceName(this.m_deviceName);
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.CreateInteraction();
    return action;
  }

  public final func OnToggleJuryrigTrap(evt: ref<ToggleJuryrigTrap>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsJuryrigTrapTriggered() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Trap Triggered");
    };
    this.IsJuryrigTrapArmed() ? this.SetJuryrigTrapArmedState(EJuryrigTrapState.UNARMED) : this.SetJuryrigTrapArmedState(EJuryrigTrapState.ARMED);
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionScavenge(context: GetActionsContext) -> ref<ActionScavenge> {
    let action: ref<ActionScavenge> = new ActionScavenge();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(10);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func OnActionScavenge(evt: ref<ActionScavenge>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_hasBeenScavenged = true;
    GameInstance.GetActivityLogSystem(this.GetGameInstance()).AddLog("Scraps looted: " + IntToString(FromVariant(evt.prop.first)));
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionSetExposeQuickHacks() -> ref<SetExposeQuickHacks> {
    let action: ref<SetExposeQuickHacks> = new SetExposeQuickHacks();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> EntityNotificationType {
    let backdoors: array<ref<ScriptableDeviceComponentPS>>;
    let i: Int32;
    let validate: ref<Validate>;
    if this.IsQuickHacksExposed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.ExposeQuickHacks(true);
    this.UseNotifier(evt);
    backdoors = this.GetBackdoorDevices();
    i = 0;
    while i < ArraySize(backdoors) {
      if !backdoors[i].IsBreached() {
        validate = new Validate();
        this.QueuePSEvent(backdoors[i].GetBackdoorAccessPoint(), validate);
      };
      i += 1;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected cb func OnRevokeQuickHackAccess(evt: ref<RevokeQuickHackAccess>) -> Bool {
    this.ExposeQuickHacks(false);
  }

  protected func ActionQuickHackToggleON() -> ref<QuickHackToggleON> {
    let action: ref<QuickHackToggleON> = new QuickHackToggleON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    action.CreateInteraction();
    return action;
  }

  public func OnQuickHackToggleOn(evt: ref<QuickHackToggleON>) -> EntityNotificationType {
    let action: ref<ToggleON>;
    this.SetBlockSecurityWakeUp(FromVariant(evt.prop.first));
    action = this.ActionToggleON();
    action.SetExecutor(evt.GetExecutor());
    this.ExecutePSAction(this.ActionToggleON(), n"remote");
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ActionGlitchScreen(actionID: TweakDBID, programID: TweakDBID, opt timeout: Float) -> ref<GlitchScreen> {
    let action: ref<GlitchScreen> = new GlitchScreen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isGlitching, actionID, programID);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    action.SetDurationValue(timeout);
    return action;
  }

  public final func OnGlitchScreen(evt: ref<GlitchScreen>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !this.IsON() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled or Unpowered");
    };
    if evt.IsStarted() {
      this.m_isGlitching = true;
      evt.SetCanTriggerStim(true);
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      this.m_isGlitching = false;
      evt.SetCanTriggerStim(false);
    };
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceEnabled() -> ref<QuestForceEnabled> {
    let action: ref<QuestForceEnabled> = new QuestForceEnabled();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceEnabled(evt: ref<QuestForceEnabled>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !this.IsDisabled() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if this.m_wasStateCached && NotEquals(this.m_cachedDeviceState, EDeviceStatus.DISABLED) {
      this.SetDeviceState(this.m_cachedDeviceState);
    } else {
      this.SetDeviceState(EDeviceStatus.OFF);
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.InitializeBackdoorSkillcheck();
    this.DetermineInitialPlaystyle();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceDisabled() -> ref<QuestForceDisabled> {
    let action: ref<QuestForceDisabled> = new QuestForceDisabled();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceDisabled(evt: ref<QuestForceDisabled>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.DisableDevice();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForcePower() -> ref<QuestForcePower> {
    let action: ref<QuestForcePower> = new QuestForcePower();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnQuestForcePower(evt: ref<QuestForcePower>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsPowered() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if Equals(this.GetDeviceState(), EDeviceStatus.DISABLED) {
      evt.SetShouldActivateDevice(true);
    };
    this.PowerDevice();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceUnpower() -> ref<QuestForceUnpower> {
    let action: ref<QuestForceUnpower> = new QuestForceUnpower();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnQuestForceUnpower(evt: ref<QuestForceUnpower>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if Equals(this.GetDeviceState(), EDeviceStatus.DISABLED) {
      evt.SetShouldActivateDevice(true);
    };
    this.UnpowerDevice();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func ActionQuestForceON() -> ref<QuestForceON> {
    let action: ref<QuestForceON> = new QuestForceON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnQuestForceON(evt: ref<QuestForceON>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsON() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if Equals(this.GetDeviceState(), EDeviceStatus.DISABLED) {
      evt.SetShouldActivateDevice(true);
    };
    this.SetDeviceState(EDeviceStatus.ON);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func ActionQuestForceOFF() -> ref<QuestForceOFF> {
    let action: ref<QuestForceOFF> = new QuestForceOFF();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func OnQuestForceOFF(evt: ref<QuestForceOFF>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsOFF() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if Equals(this.GetDeviceState(), EDeviceStatus.DISABLED) {
      evt.SetShouldActivateDevice(true);
    };
    this.SetDeviceState(EDeviceStatus.OFF);
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceDestructible() -> ref<QuestForceDestructible> {
    let action: ref<QuestForceDestructible> = new QuestForceDestructible();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceDestructible(evt: ref<QuestForceDestructible>) -> EntityNotificationType {
    this.SetDurabilityType(EDeviceDurabilityType.DESTRUCTIBLE);
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestForceIndestructible() -> ref<QuestForceIndestructible> {
    let action: ref<QuestForceIndestructible> = new QuestForceIndestructible();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceIndestructible(evt: ref<QuestForceIndestructible>) -> EntityNotificationType {
    this.SetDurabilityType(EDeviceDurabilityType.INDESTRUCTIBLE);
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestForceInvulnerable() -> ref<QuestForceInvulnerable> {
    let action: ref<QuestForceInvulnerable> = new QuestForceInvulnerable();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceInvulnerable(evt: ref<QuestForceInvulnerable>) -> EntityNotificationType {
    this.SetDurabilityType(EDeviceDurabilityType.INVULNERABLE);
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestForceAuthorizationEnabled() -> ref<QuestForceAuthorizationEnabled> {
    let action: ref<QuestForceAuthorizationEnabled> = new QuestForceAuthorizationEnabled();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceAuthorizationEnabled(evt: ref<QuestForceAuthorizationEnabled>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsAuthorizationModuleOn() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_hasAuthorizationModule = true;
    this.TurnAuthorizationModuleON();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestEnableFixing() -> ref<QuestEnableFixing> {
    let action: ref<QuestEnableFixing> = new QuestEnableFixing();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestDisableFixing() -> ref<QuestDisableFixing> {
    let action: ref<QuestDisableFixing> = new QuestDisableFixing();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestEnableFixing(evt: ref<QuestEnableFixing>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_destructionProperties.m_canBeFixed = true;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestDisableFixing(evt: ref<QuestDisableFixing>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    this.m_destructionProperties.m_canBeFixed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestRemoveQuickHacks() -> ref<QuestRemoveQuickHacks> {
    let action: ref<QuestRemoveQuickHacks> = new QuestRemoveQuickHacks();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestRemoveQuickHacks(evt: ref<QuestRemoveQuickHacks>) -> EntityNotificationType {
    this.ExposeQuickHacks(false);
    this.m_disableQuickHacks = true;
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestResetPerfomedActionsStorage() -> ref<QuestResetPerformedActionsStorage> {
    let action: ref<QuestResetPerformedActionsStorage> = new QuestResetPerformedActionsStorage();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestResetPerfomedActionsStorage(evt: ref<QuestResetPerformedActionsStorage>) -> EntityNotificationType {
    this.ResetPerformedActionsStorage();
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestBreachAccessPoint() -> ref<QuestBreachAccessPoint> {
    let action: ref<QuestBreachAccessPoint> = new QuestBreachAccessPoint();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestBreachAccessPoint(evt: ref<QuestBreachAccessPoint>) -> EntityNotificationType {
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestForceAuthorizationDisabled() -> ref<QuestForceAuthorizationDisabled> {
    let action: ref<QuestForceAuthorizationDisabled> = new QuestForceAuthorizationDisabled();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceAuthorizationDisabled(evt: ref<QuestForceAuthorizationDisabled>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if !this.IsAuthorizationModuleOn() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.TurnAuthorizationModuleOFF();
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceDisconnectPersonalLink() -> ref<QuestForceDisconnectPersonalLink> {
    let action: ref<QuestForceDisconnectPersonalLink> = new QuestForceDisconnectPersonalLink();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  private final func OnQuestForceDisconnectPersonalLink(evt: ref<QuestForceDisconnectPersonalLink>) -> EntityNotificationType {
    evt.SetExecutor(this.GetPlayerMainObject());
    this.DisconnectPersonalLink(evt, true);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestForcePersonalLinkUnderStrictQuestControl() -> ref<QuestForcePersonalLinkUnderStrictQuestControl> {
    let action: ref<QuestForcePersonalLinkUnderStrictQuestControl> = new QuestForcePersonalLinkUnderStrictQuestControl();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  private final func OnQuestForcePersonalLinkUnderStrictQuestControl(evt: ref<QuestForcePersonalLinkUnderStrictQuestControl>) -> EntityNotificationType {
    this.m_personalLinkForced = true;
    this.m_disablePersonalLinkAutoDisconnect = true;
    this.UseNotifier(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestForceJuryrigTrapArmed() -> ref<QuestForceJuryrigTrapArmed> {
    let action: ref<QuestForceJuryrigTrapArmed> = new QuestForceJuryrigTrapArmed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceJuryrigTrapArmed(evt: ref<QuestForceJuryrigTrapArmed>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if Equals(this.GetJuryrigTrapState(), EJuryrigTrapState.ARMED) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.SetJuryrigTrapArmedState(EJuryrigTrapState.ARMED);
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceJuryrigTrapDeactivated() -> ref<QuestForceJuryrigTrapDeactivated> {
    let action: ref<QuestForceJuryrigTrapDeactivated> = new QuestForceJuryrigTrapDeactivated();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceJuryrigTrapDeactivated(evt: ref<QuestForceJuryrigTrapDeactivated>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if Equals(this.GetJuryrigTrapState(), EJuryrigTrapState.UNARMED) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.SetJuryrigTrapArmedState(EJuryrigTrapState.UNARMED);
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionQuestResetDeviceToInitialState() -> ref<QuestResetDeviceToInitialState> {
    let action: ref<QuestResetDeviceToInitialState> = new QuestResetDeviceToInitialState();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestResetDeviceToInitialState(evt: ref<QuestResetDeviceToInitialState>) -> EntityNotificationType {
    this.ExecutePSAction(this.ActionQuestForceEnabled());
    GameInstance.GetStatPoolsSystem(this.GetGameInstance()).RequestSettingStatPoolMaxValue(Cast(this.GetMyEntityID()), gamedataStatPoolType.Health, null);
    this.SetBlockSecurityWakeUp(false);
    if this.IsBroken() {
      this.SetDurabilityState(EDeviceDurabilityState.NOMINAL);
    };
    if !this.IsON() {
      this.ExecutePSAction(this.ActionToggleON());
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestStartGlitch() -> ref<QuestStartGlitch> {
    let action: ref<QuestStartGlitch> = new QuestStartGlitch();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func OnQuestStartGlitch(evt: ref<QuestStartGlitch>) -> EntityNotificationType {
    this.SetGlitchingState(true);
    this.UseNotifier(evt);
    this.m_distractExecuted = true;
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestStopGlitch() -> ref<QuestStopGlitch> {
    let action: ref<QuestStopGlitch> = new QuestStopGlitch();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func OnQuestStopGlitch(evt: ref<QuestStopGlitch>) -> EntityNotificationType {
    this.SetGlitchingState(false);
    this.m_distractExecuted = false;
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnSetAsQuestImportantEvent(evt: ref<SetAsQuestImportantEvent>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceSecuritySystemSafe() -> ref<QuestForceSecuritySystemSafe> {
    let action: ref<QuestForceSecuritySystemSafe> = new QuestForceSecuritySystemSafe();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceSecuritySystemSafe(evt: ref<QuestForceSecuritySystemSafe>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceSecuritySystemAlarmed() -> ref<QuestForceSecuritySystemAlarmed> {
    let action: ref<QuestForceSecuritySystemAlarmed> = new QuestForceSecuritySystemAlarmed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceSecuritySystemAlarmed(evt: ref<QuestForceSecuritySystemAlarmed>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceSecuritySystemArmed() -> ref<QuestForceSecuritySystemArmed> {
    let action: ref<QuestForceSecuritySystemArmed> = new QuestForceSecuritySystemArmed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceSecuritySystemArmed(evt: ref<QuestForceSecuritySystemArmed>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestForceTakeControlOverCamera() -> ref<QuestForceTakeControlOverCamera> {
    let action: ref<QuestForceTakeControlOverCamera> = new QuestForceTakeControlOverCamera();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestForceTakeControlOverCameraWithChain() -> ref<QuestForceTakeControlOverCameraWithChain> {
    let action: ref<QuestForceTakeControlOverCameraWithChain> = new QuestForceTakeControlOverCameraWithChain();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestForceStopTakeControlOverCamera() -> ref<QuestForceStopTakeControlOverCamera> {
    let action: ref<QuestForceStopTakeControlOverCamera> = new QuestForceStopTakeControlOverCamera();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestForceActivate() -> ref<QuestForceActivate> {
    let action: ref<QuestForceActivate> = new QuestForceActivate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceActivate(evt: ref<QuestForceActivate>) -> EntityNotificationType {
    this.QueuePSEvent(this.GetID(), this.GetClassName(), this.ActionActivateDevice());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ActionQuestForceDeactivate() -> ref<QuestForceDeactivate> {
    let action: ref<QuestForceDeactivate> = new QuestForceDeactivate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func OnQuestForceDeactivate(evt: ref<QuestForceDeactivate>) -> EntityNotificationType {
    this.QueuePSEvent(this.GetID(), this.GetClassName(), this.ActionDeactivateDevice());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final const func ActionTakeOverSecuritySystem(executor: ref<GameObject>) -> ref<TakeOverSecuritySystem> {
    let action: ref<TakeOverSecuritySystem> = new TakeOverSecuritySystem();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSystemCompatibleClearance();
    action.SetProperties();
    action.SetUp(this);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateActionWidgetPackage();
    action.SetExecutor(executor);
    return action;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    if Equals(evt.GetCachedSecurityState(), ESecuritySystemState.COMBAT) {
      this.WakeUpDevice();
    };
    if Equals(evt.GetCachedSecurityState(), ESecuritySystemState.ALERTED) {
      if Equals(evt.GetBreachOrigin(), EBreachOrigin.LOCAL) {
        this.WakeUpDevice();
      };
    };
    if Equals(evt.GetCachedSecurityState(), ESecuritySystemState.SAFE) {
      this.NotifyParents_Event();
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecuritySystemForceAttitudeChange(evt: ref<SecuritySystemForceAttitudeChange>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnSecurityAlarmBreachResponse(evt: ref<SecurityAlarmBreachResponse>) -> EntityNotificationType {
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> EntityNotificationType {
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnActionForceResetDevice(evt: ref<ActionForceResetDevice>) -> EntityNotificationType {
    this.PerformRestart();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnFullSystemRestart(evt: ref<FullSystemRestart>) -> EntityNotificationType {
    this.m_isRestarting = true;
    this.PerformRestart();
    if !IsFinal() {
      LogDevices(this, "Device reboots... Time till reboot: " + IntToString(evt.m_restartDuration) + ".");
    };
    this.TriggerWakeUpDelayedEvent(evt.m_restartDuration);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func PerformRestart() -> Void;

  protected final func TriggerWakeUpDelayedEvent(duration: Int32) -> Void {
    let wakeUpEvent: ref<WakeUpFromRestartEvent> = new WakeUpFromRestartEvent();
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEvent(this.GetID(), this.GetClassName(), wakeUpEvent, Cast(duration));
  }

  public final func OnWakeUpEvent(evt: ref<WakeUpFromRestartEvent>) -> EntityNotificationType {
    this.m_isRestarting = false;
    this.WakeUpDevice();
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected const func CanPerformReprimand() -> Bool {
    return false;
  }

  public func ActionSetDeviceAttitude() -> ref<SetDeviceAttitude> {
    let action: ref<SetDeviceAttitude> = new SetDeviceAttitude();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected func Notify(notifier: ref<ActionNotifier>, action: ref<ScriptableDeviceAction>) -> Void {
    let deviceChangedEvent: ref<PSDeviceChangedEvent> = new PSDeviceChangedEvent();
    deviceChangedEvent.persistentID = this.GetID();
    deviceChangedEvent.className = this.GetClassName();
    if IsDefined(notifier) {
      if notifier.IsFailed() {
        this.SendActionFailedEvent(action, action.GetRequesterID(), "Failed Toggle");
        return;
      };
      if notifier.IsInternalOnly() {
        this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), action);
        this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), deviceChangedEvent);
      } else {
        if notifier.IsExternalOnly() {
          this.GetPersistencySystem().QueueEntityEvent(action.GetRequesterID(), deviceChangedEvent);
        } else {
          if notifier.IsAll() {
            this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), action);
            this.GetPersistencySystem().QueueEntityEvent(action.GetRequesterID(), deviceChangedEvent);
            this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(this.GetID()), deviceChangedEvent);
          };
        };
      };
    };
    this.ResloveUIOnAction(action);
    this.ResolveBaseActionOperation(action);
  }

  protected final func SendPSChangedEvent() -> Void {
    let evt: ref<PSChangedEvent> = new PSChangedEvent();
    this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), evt);
  }

  public final const func NotifyParents() -> Void {
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let deviceChangedEvent: ref<PSDeviceChangedEvent> = new PSDeviceChangedEvent();
    deviceChangedEvent.persistentID = this.GetID();
    deviceChangedEvent.className = this.GetClassName();
    this.GetParents(devices);
    i = 0;
    while i < ArraySize(devices) {
      if Equals(this.GetID(), devices[i].GetID()) {
      } else {
        this.GetPersistencySystem().QueueEntityEvent(PersistentID.ExtractEntityID(devices[i].GetID()), deviceChangedEvent);
      };
      i += 1;
    };
  }

  protected final func NotifyParents_Event() -> Void {
    let evt: ref<NotifyParentsEvent> = new NotifyParentsEvent();
    this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), evt);
  }

  private final func OnNotifyParents(evt: ref<NotifyParentsEvent>) -> EntityNotificationType {
    this.NotifyParents();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func UseNotifier(action: ref<ScriptableDeviceAction>) -> Void {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.Notify(notifier, action);
  }

  protected func SendActionFailedEvent(failedAction: ref<ScriptableDeviceAction>, whereToSend: EntityID, opt context: String) -> EntityNotificationType {
    let failedActionEvent: ref<FailedActionEvent> = new FailedActionEvent();
    failedActionEvent.action = failedAction;
    failedActionEvent.whoFailed = this.GetID();
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueueEntityEvent(whereToSend, failedActionEvent);
    context += " FAILED ACTION EVENT";
    if !IsFinal() {
      this.LogActionDetails(failedAction, context);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func WakeUpDevice() -> Bool {
    if (this.IsOFF() || this.IsUnpowered()) && !this.IsSecurityWakeUpBlocked() && !this.IsBroken() {
      this.ExecutePSAction(this.ActionQuestForceON());
      return true;
    };
    return false;
  }

  protected func PowerDevice() -> Void {
    if this.m_wasStateCached {
      if Equals(this.m_cachedDeviceState, EDeviceStatus.UNPOWERED) {
        this.SetDeviceState(EDeviceStatus.OFF);
      } else {
        this.SetDeviceState(this.m_cachedDeviceState);
      };
    } else {
      this.SetDeviceState(EDeviceStatus.ON);
    };
  }

  public func UnpowerDevice() -> Void {
    if !this.IsUnpowered() && !this.IsDisabled() {
      this.CacheDeviceState(this.m_deviceState);
    };
    this.SetDeviceState(EDeviceStatus.UNPOWERED);
    if !this.IsAttachedToGame() {
      this.RevealNetworkGrid(false);
      this.RevealDevicesGrid(false);
    };
  }

  protected func DisableDevice() -> Void {
    if !this.IsUnpowered() && !this.IsDisabled() {
      this.CacheDeviceState(this.m_deviceState);
    };
    this.DetermineInitialPlaystyle();
    this.SetDeviceState(EDeviceStatus.DISABLED);
    if !this.IsAttachedToGame() {
      this.RevealNetworkGrid(false);
      this.RevealDevicesGrid(false);
    };
  }

  public final func ForceDisableDevice() -> Void {
    let action: ref<QuestForceDisabled> = this.ActionQuestForceDisabled();
    this.GetPersistencySystem().QueuePSDeviceEvent(action);
  }

  public final func ForceEnableDevice() -> Void {
    let action: ref<QuestForceEnabled> = this.ActionQuestForceEnabled();
    this.GetPersistencySystem().QueuePSDeviceEvent(action);
  }

  public final func ForceDeviceON() -> Void {
    let action: ref<QuestForceON> = this.ActionQuestForceON();
    this.GetPersistencySystem().QueuePSDeviceEvent(action);
  }

  public func BreakDevice() -> Void;

  protected final func EnableDevice() -> Void {
    if NotEquals(this.m_cachedDeviceState, EDeviceStatus.DISABLED) || NotEquals(this.m_cachedDeviceState, EDeviceStatus.UNPOWERED) {
      this.CacheDeviceState(this.m_deviceState);
    } else {
      this.SetDeviceState(EDeviceStatus.DISABLED);
    };
    this.DetermineInitialPlaystyle();
  }

  protected final const func GetFullAuthorizationData() -> array<SecurityAccessLevelEntryClient> {
    let data: array<SecurityAccessLevelEntryClient>;
    let externalData: array<SecurityAccessLevelEntry>;
    let externalDataEntry: SecurityAccessLevelEntryClient;
    let i: Int32;
    let securityLevel: ESecurityAccessLevel;
    if AuthorizationData.IsAuthorizationValid(this.m_authorizationProperties) {
      ArrayPush(data, this.m_authorizationProperties.m_authorizationDataEntry);
    };
    if this.IsConnectedToSecuritySystem(securityLevel) {
      externalData = this.GetSecuritySystem().GetSecurityAccessData(securityLevel);
      i = 0;
      while i < ArraySize(externalData) {
        externalDataEntry.m_keycard = externalData[i].m_keycard;
        externalDataEntry.m_password = externalData[i].m_password;
        externalDataEntry.m_level = securityLevel;
        ArrayPush(data, externalDataEntry);
        i += 1;
      };
    };
    return data;
  }

  public final const func IsAuthorizationValid() -> Bool {
    if AuthorizationData.IsAuthorizationValid(this.m_authorizationProperties) {
      return true;
    };
    return false;
  }

  private final const func GetFullAuthorizationDataSegregated(out passwords: array<CName>, out keycards: array<TweakDBID>) -> Void {
    passwords = this.GetPasswords();
    keycards = this.GetKeycards();
  }

  public final const func GetPasswords() -> array<CName> {
    let securityData: array<SecurityAccessLevelEntryClient> = this.GetFullAuthorizationData();
    let passwords: array<CName> = this.ExtractPasswordsFromAuthorizationData(securityData);
    return passwords;
  }

  public final const func GetKeycards() -> array<TweakDBID> {
    let securityData: array<SecurityAccessLevelEntryClient> = this.GetFullAuthorizationData();
    let keycards: array<TweakDBID> = this.ExtractKeycardsFromAuthorizationData(securityData);
    return keycards;
  }

  protected final const func ExtractKeycardsFromAuthorizationData(data: array<SecurityAccessLevelEntryClient>) -> array<TweakDBID> {
    let keycards: array<TweakDBID>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      if SecurityAccessLevelEntryClient.IsKeycardValid(data[i]) {
        ArrayPush(keycards, data[i].m_keycard);
      };
      i += 1;
    };
    return keycards;
  }

  protected final const func ExtractPasswordsFromAuthorizationData(data: array<SecurityAccessLevelEntryClient>) -> array<CName> {
    let passwords: array<CName>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      if SecurityAccessLevelEntryClient.IsPasswordValid(data[i]) {
        ArrayPush(passwords, data[i].m_password);
      };
      i += 1;
    };
    return passwords;
  }

  protected final const func ExtractKeycardsFromAuthorizationData(data: array<SecurityAccessLevelEntry>) -> array<TweakDBID> {
    let keycards: array<TweakDBID>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      if SecurityAccessLevelEntry.IsKeycardValid(data[i]) {
        ArrayPush(keycards, data[i].m_keycard);
      };
      i += 1;
    };
    return keycards;
  }

  protected final const func ExtractPasswordsFromAuthorizationData(data: array<SecurityAccessLevelEntry>) -> array<CName> {
    let passwords: array<CName>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      if SecurityAccessLevelEntry.IsPasswordValid(data[i]) {
        ArrayPush(passwords, data[i].m_password);
      };
      i += 1;
    };
    return passwords;
  }

  protected final const func FindCurrentAuthorizationLevelForUser(user: EntityID) -> ESecurityAccessLevel {
    let i: Int32 = 0;
    while i < ArraySize(this.m_currentlyAuthorizedUsers) {
      if this.m_currentlyAuthorizedUsers[i].user == user {
        return this.m_currentlyAuthorizedUsers[i].level;
      };
      i += 1;
    };
    return ESecurityAccessLevel.ESL_NONE;
  }

  protected final const func AddUser(user: EntityID, level: ESecurityAccessLevel) -> Bool {
    let addUserEvent: ref<AddUserEvent>;
    let index: Int32;
    let newUserEntry: SecuritySystemClearanceEntry;
    if Equals(level, ESecurityAccessLevel.ESL_NONE) {
      level = ESecurityAccessLevel.ESL_0;
    };
    index = this.IsUserAlreadyOnTheList(user);
    if index >= 0 && EnumInt(this.m_currentlyAuthorizedUsers[index].level) >= EnumInt(level) {
      return false;
    };
    newUserEntry.user = user;
    newUserEntry.level = level;
    addUserEvent = new AddUserEvent();
    addUserEvent.userEntry = newUserEntry;
    this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), addUserEvent);
    return true;
  }

  public func OnAddUserEvent(evt: ref<AddUserEvent>) -> EntityNotificationType {
    let index: Int32;
    DeviceHelper.DebugLog(this.GetGameInstance(), "SecSys: User authorized");
    DeviceHelper.DebugLog(this.GetGameInstance(), "SecSys: User Authorized on: " + this.GetDeviceName());
    DeviceHelper.DebugLog(this.GetGameInstance(), "SecSys: User authorized on level: " + EnumValueToString("ESecurityAccessLevel", EnumInt(evt.userEntry.level)));
    if !IsFinal() {
      LogDevices(this, "User: " + EntityID.ToDebugString(evt.userEntry.user) + " authorized on level: " + EnumValueToString("ESecurityAccessLevel", EnumInt(evt.userEntry.level)));
    };
    index = this.IsUserAlreadyOnTheList(evt.userEntry.user);
    if index >= 0 {
      ArrayErase(this.m_currentlyAuthorizedUsers, index);
    };
    ArrayPush(this.m_currentlyAuthorizedUsers, evt.userEntry);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final const func IsUserAlreadyOnTheList(entityID: EntityID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_currentlyAuthorizedUsers) {
      if this.m_currentlyAuthorizedUsers[i].user == entityID {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  protected func RemoveUser(user: EntityID) -> Bool {
    let index: Int32 = this.IsUserAlreadyOnTheList(user);
    if index >= 0 {
      if !IsFinal() {
        LogDevices(this, "Authorization removed from user: " + EntityID.ToDebugString(user));
      };
      ArrayErase(this.m_currentlyAuthorizedUsers, index);
      return true;
    };
    return false;
  }

  protected final const func GetKeycardRecord(record: TweakDBID) -> ref<Item_Record> {
    return TweakDBInterface.GetItemRecord(record);
  }

  protected final const func GetKeycardLocalizedString(record: TweakDBID) -> String {
    return NameToString(this.GetKeycardRecord(record).DisplayName());
  }

  public final func TurnAuthorizationModuleON() -> Bool {
    if this.HasAuthorizationModule() {
      this.m_authorizationProperties.m_isAuthorizationModuleOn = true;
      return true;
    };
    return false;
  }

  public func TurnAuthorizationModuleOFF() -> Void {
    this.m_authorizationProperties.m_isAuthorizationModuleOn = false;
  }

  public final const func ExecutePSAction(action: ref<ScriptableDeviceAction>, opt layerTag: CName) -> Void {
    if !EntityID.IsDefined(action.GetRequesterID()) {
      action.RegisterAsRequester(this.GetMyEntityID());
    };
    if NotEquals(layerTag, n"") {
      action.SetInteractionLayer(layerTag);
    };
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSDeviceEvent(action);
  }

  public final const func ExecutePSAction(action: ref<ScriptableDeviceAction>, const persistentState: ref<PersistentState>) -> Void {
    if !EntityID.IsDefined(action.GetRequesterID()) {
      action.RegisterAsRequester(this.GetMyEntityID());
    };
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(persistentState.GetID(), persistentState.GetClassName(), action);
  }

  protected final const func ExecutePSActionWithDelay(action: ref<ScriptableDeviceAction>, persistentState: ref<PersistentState>, opt forcedDelay: Float) -> Void {
    let delay: Float;
    let evt: ref<DelayedDeviceActionEvent>;
    if !IsDefined(persistentState) {
      return;
    };
    evt = new DelayedDeviceActionEvent();
    if forcedDelay == 0.00 {
      delay = action.GetDurationValue();
    } else {
      delay = forcedDelay;
    };
    evt.action = action;
    this.QueuePSEventWithDelay(persistentState.GetID(), persistentState.GetClassName(), evt, delay);
  }

  public final func OnDelayedActionEvent(evt: ref<DelayedDeviceActionEvent>) -> EntityNotificationType {
    let action: ref<ScriptableDeviceAction> = evt.action;
    if action != null {
      action.SetDurationValue(0.00);
      this.ExecutePSAction(action);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func ExecuteCurrentSpiderbotActionPerformed() -> Void {
    this.ExecutePSAction(this.m_currentSpiderbotActionPerformed);
    this.m_currentSpiderbotActionPerformed = null;
  }

  public final const func ExtractIDs(persistentStates: array<ref<PersistentState>>, out persistentIDs: array<PersistentID>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(persistentStates) {
      ArrayPush(persistentIDs, persistentStates[i].GetID());
      i += 1;
    };
  }

  protected final const func ExtractEntityID(evt: ref<TriggerEvent>) -> EntityID {
    let entityID: EntityID = EntityGameInterface.GetEntity(evt.activator).GetEntityID();
    return entityID;
  }

  public final const func GetAvailableQuickHacks() -> array<CName> {
    return this.m_availableQuickHacks;
  }

  public final const func HasAnyAvailableQuickHack() -> Bool {
    return ArraySize(this.m_availableQuickHacks) > 0;
  }

  public final func HasAnyQuickHack() -> Bool {
    let actions: array<ref<DeviceAction>>;
    let context: GetActionsContext = this.GenerateContext(gamedeviceRequestType.Remote, this.GetClearance(), this.GetPlayerMainObject(), PersistentID.ExtractEntityID(this.GetID()));
    context.ignoresRPG = true;
    this.GetQuickHackActions(actions, context);
    return ArraySize(actions) > 0;
  }

  protected final func UpdateAvailAbleQuickHacks(actions: array<ref<DeviceAction>>) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let i: Int32;
    this.ClearAvailableQuickHacks();
    i = 0;
    while i < ArraySize(actions) {
      action = actions[i] as ScriptableDeviceAction;
      if IsDefined(action) {
        this.AddAvailableQuickHack(action.GetActionID());
      };
      i += 1;
    };
  }

  public final func AddAvailableQuickHack(quickHackName: CName) -> Void {
    if !ArrayContains(this.m_availableQuickHacks, quickHackName) {
      ArrayPush(this.m_availableQuickHacks, quickHackName);
    };
  }

  protected final func RemoveAvailableQuickHack(quickHackName: CName) -> Void {
    if ArrayContains(this.m_availableQuickHacks, quickHackName) {
      ArrayRemove(this.m_availableQuickHacks, quickHackName);
    };
  }

  public final func ClearAvailableQuickHacks() -> Void {
    ArrayClear(this.m_availableQuickHacks);
  }

  public final const func GetAvailableSpiderbotActions() -> array<CName> {
    return this.m_availableSpiderbotActions;
  }

  public final const func HasAnyAvailableSpiderbotActions() -> Bool {
    return ArraySize(this.m_availableSpiderbotActions) > 0;
  }

  public final func HasAnySpiderbotAction() -> Bool {
    let actions: array<ref<DeviceAction>>;
    let context: GetActionsContext = this.GenerateContext(gamedeviceRequestType.Remote, this.GetClearance(), this.GetPlayerMainObject(), PersistentID.ExtractEntityID(this.GetID()));
    context.ignoresRPG = true;
    this.GetSpiderbotActions(actions, context);
    return ArraySize(actions) > 0;
  }

  protected final func UpdateAvailableSpiderbotActions(actions: array<ref<DeviceAction>>) -> Void {
    let i: Int32;
    this.ClearAvailableSpiderbotActions();
    i = 0;
    while i < ArraySize(actions) {
      this.AddAvailableSpiderbotActions(actions[i].actionName);
      i += 1;
    };
  }

  protected final func AddAvailableSpiderbotActions(SpiderbotActionName: CName) -> Void {
    if !ArrayContains(this.m_availableSpiderbotActions, SpiderbotActionName) {
      ArrayPush(this.m_availableSpiderbotActions, SpiderbotActionName);
    };
  }

  protected final func RemoveAvailableSpiderbotActions(SpiderbotActionName: CName) -> Void {
    if ArrayContains(this.m_availableSpiderbotActions, SpiderbotActionName) {
      ArrayRemove(this.m_availableSpiderbotActions, SpiderbotActionName);
    };
  }

  protected final func ClearAvailableSpiderbotActions() -> Void {
    ArrayClear(this.m_availableSpiderbotActions);
  }

  public final const func GetPlayerEntityID() -> EntityID {
    return this.GetLocalPlayerControlledGameObject().GetEntityID();
  }

  protected final const func GetPlayerMainObject() -> ref<GameObject> {
    return GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
  }

  protected final const func GetLocalPlayerControlledGameObject() -> ref<GameObject> {
    return GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject();
  }

  protected final const func GetLocalPlayer() -> ref<GameObject> {
    return this.GetLocalPlayerControlledGameObject();
  }

  private final func RegisterDebugEnableQuickHacksListener() -> Void {
    GameInstance.GetQuestsSystem(this.GetGameInstance()).RegisterListener(n"DebugEnableQuickHacks", this, n"EnableDebugQuickHacks");
  }

  public final func EnableDebugQuickHacks(val: Int32) -> Void {
    this.m_debugExposeQuickHacks = Cast(val);
    if val > 0 {
      this.m_isScanned = true;
    };
  }

  public final const func GetMasterDevicesTweaks() -> array<TweakDBID> {
    let MastersTweaks: array<TweakDBID>;
    let i: Int32;
    let parent: ref<ScriptableDeviceComponentPS>;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      parent = parents[i] as ScriptableDeviceComponentPS;
      if !IsDefined(parent) {
      } else {
        if !parent.ShouldRevealDevicesGrid() {
        } else {
          ArrayPush(MastersTweaks, parent.GetTweakDBRecord());
        };
      };
      i += 1;
    };
    return MastersTweaks;
  }

  protected final func IsLogInExclusiveMode() -> Bool {
    let isOverride: Int32 = GetFact(this.GetGameInstance(), n"dbgDevices");
    return Cast(isOverride);
  }

  public func OnNotifyHighlightedDevice(evt: ref<NotifyHighlightedDevice>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func SetDurabilityType(durabilityType: EDeviceDurabilityType) -> Void {
    this.m_destructionProperties.m_durabilityType = durabilityType;
  }

  public final func SetJuryrigTrapActiveState(newState: Bool) -> Void {
    this.m_canBeTrapped = newState;
  }

  public final func SetJuryrigTrapArmedState(newState: EJuryrigTrapState) -> Void {
    this.m_juryrigTrapState = newState;
  }

  public final func SetDurabilityState(newState: EDeviceDurabilityState) -> Void {
    let removeFromChain: ref<RemoveFromChainRequest>;
    if EnumInt(newState) >= EnumInt(EDeviceDurabilityState.BROKEN) && this.CanBeInDeviceChain() {
      removeFromChain = new RemoveFromChainRequest();
      removeFromChain.requestSource = this.GetMyEntityID();
      this.GetTakeOverControlSystem().QueueRequest(removeFromChain);
    };
    this.m_durabilityState = newState;
  }

  protected final const func GetDistractionDuration(effectName: CName) -> Float {
    let duration: Float;
    let device: wref<Device> = this.GetOwnerEntityWeak() as Device;
    if IsDefined(device) {
      duration = device.GetAreaEffectLifetimeByName(effectName);
    };
    return duration;
  }

  public final const func GetUniqueConnectionTypes() -> array<DeviceConnectionScannerData> {
    let categoryName: String;
    let connection: DeviceConnectionScannerData;
    let deviceRole: ref<ScannableData_Record>;
    let i: Int32;
    let isRepetition: Bool;
    let k: Int32;
    let parent: ref<ScriptableDeviceComponentPS>;
    let parentRecord: TweakDBID;
    let parents: array<ref<DeviceComponentPS>>;
    let uniqueConnections: array<DeviceConnectionScannerData>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      parent = parents[i] as ScriptableDeviceComponentPS;
      if !IsDefined(parent) {
      } else {
        isRepetition = false;
        if !parent.ShouldRevealDevicesGrid() && !parent.ShouldRevealNetworkGrid() {
        } else {
          if IsDefined(parent as ComputerControllerPS) {
            parentRecord = (parent as TerminalControllerPS).GetTweakDBRecord();
          } else {
            parentRecord = parent.GetTweakDBRecord();
          };
          TDBID.Append(parentRecord, t".deviceType");
          categoryName = TweakDBInterface.GetString(parentRecord, "Default");
          deviceRole = TweakDBInterface.GetScannableDataRecord(TDBID.Create("device_role_actions." + categoryName));
          if !IsDefined(deviceRole) {
          } else {
            connection.connectionType = LocKeyToString(deviceRole.LocalizedDescription());
            connection.icon = deviceRole.IconName();
            connection.amount = 1;
            k = 0;
            while k < ArraySize(uniqueConnections) {
              if Equals(uniqueConnections[k].connectionType, connection.connectionType) {
                uniqueConnections[k].amount += 1;
                isRepetition = true;
              };
              k += 1;
            };
            if isRepetition {
            } else {
              ArrayPush(uniqueConnections, connection);
            };
          };
        };
      };
      i += 1;
    };
    return uniqueConnections;
  }

  public final const func GetDistractionDuration(action: ref<ScriptableDeviceAction>) -> Float {
    let duration: Float;
    let device: wref<Device> = this.GetOwnerEntityWeak() as Device;
    if IsDefined(device) {
      duration = device.GetAreaEffectLifetimeByAction(action);
    };
    return duration;
  }

  public final const func IsConnectedToActionsSequencer() -> Bool {
    let sequencer: ref<ActionsSequencerControllerPS> = this.GetActionsSequencer();
    if IsDefined(sequencer) {
      return true;
    };
    return false;
  }

  public final const func GetActionsSequencer() -> ref<ActionsSequencerControllerPS> {
    let i: Int32;
    let masters: array<ref<DeviceComponentPS>>;
    this.GetParents(masters);
    i = 0;
    while i < ArraySize(masters) {
      if IsDefined(masters[i] as ActionsSequencerControllerPS) {
        return masters[i] as ActionsSequencerControllerPS;
      };
      i += 1;
    };
    return null;
  }

  protected final func OnSequencerLock(evt: ref<SequencerLock>) -> EntityNotificationType {
    this.m_isLockedViaSequencer = evt.shouldLock;
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final const func IsLockedViaSequencer() -> Bool {
    return this.m_isLockedViaSequencer;
  }

  public final const quest func IsControlledByThePlayer() -> Bool {
    return this.m_isControlledByThePlayer;
  }

  public final const func IsBroken() -> Bool {
    if Equals(this.GetDurabilityState(), EDeviceDurabilityState.BROKEN) {
      return true;
    };
    return false;
  }

  public final func SetAdvancedInteractionModeOn(value: Bool) -> Void {
    this.m_isAdvancedInteractionModeOn = value;
    this.ForcePersistentStateChanged();
  }

  public final const func CanBeScavenged() -> Bool {
    if Equals(this.m_durabilityState, EDeviceDurabilityState.DESTROYED) && !this.m_hasBeenScavenged && !this.CanBeDisassembled() {
      return true;
    };
    return false;
  }

  public final const func IsConnectedToMaintenanceSystem() -> Bool {
    return false;
  }

  public final func PushPersistentData(data: BaseDeviceData) -> Void {
    let defaultState: EDeviceStatus;
    if !this.m_wasStateSet {
      this.SetDeviceState(NotEquals(data.m_deviceState, defaultState) ? data.m_deviceState : defaultState);
      this.CacheDeviceState(NotEquals(this.m_deviceState, defaultState) ? this.m_deviceState : defaultState);
    };
    this.m_destructionProperties.m_durabilityType = data.m_durabilityType;
  }

  public final func PushResaveData(data: BaseResaveData) -> Void {
    LogError(" -- ");
    LogError(" -- ");
    LogError("PRE RESAVE Started For:");
    this.LogResaveInfo();
    LogError("m_deviceState = " + EnumValueToString("EDeviceStatus", EnumInt(this.m_deviceState)));
    LogError("game object m_deviceState = " + EnumValueToString("EDeviceStatus", EnumInt(data.m_baseDeviceData.m_deviceState)));
    LogError("ATTEMPTING RESAVE");
  }

  protected func LogResaveInfo() -> Void {
    LogError("Class Name: " + NameToString(this.GetClassName()));
    LogError("Device Name: " + this.GetDeviceName());
    LogError("EntityID: " + EntityID.ToDebugString(this.GetMyEntityID()));
    LogError("PS ID: " + PersistentID.ToDebugString(this.GetID()));
    DumpClassHierarchy(this.GetClassName());
  }

  protected final func SendSpiderbotToPerformAction(action: ref<ScriptableDeviceAction>, oryginalExecutor: wref<GameObject>) -> Void {
    let evt: ref<SendSpiderbotToPerformActionEvent>;
    this.SetCurrentSpiderbotActionPerformed(action);
    evt = new SendSpiderbotToPerformActionEvent();
    evt.executor = oryginalExecutor;
    this.QueueEntityEvent(this.GetMyEntityID(), evt);
  }

  public final func QuestResolveSkillchecks() -> Void {
    if this.m_skillCheckContainer.GetDemolitionSlot().IsActive() {
      this.m_skillCheckContainer.GetDemolitionSlot().SetIsActive(false);
      this.m_skillCheckContainer.GetDemolitionSlot().SetIsPassed(true);
    };
    if this.m_skillCheckContainer.GetEngineeringSlot().IsActive() {
      this.m_skillCheckContainer.GetEngineeringSlot().SetIsActive(false);
      this.m_skillCheckContainer.GetEngineeringSlot().SetIsPassed(true);
    };
    if this.m_skillCheckContainer.GetHackingSlot().IsActive() {
      this.m_skillCheckContainer.GetHackingSlot().SetIsActive(false);
      this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(true);
    };
    this.NotifyParents();
  }

  public final func QuestSetSkillchecks(container: ref<BaseSkillCheckContainer>) -> Void {
    this.ErasePassedSkillchecks();
    this.InitializeSkillChecks(container);
    this.NotifyParents();
  }

  protected final func ErasePassedSkillchecks() -> Void {
    if this.m_skillCheckContainer.GetDemolitionSlot().IsPassed() {
      this.m_skillCheckContainer.GetDemolitionSlot().SetIsPassed(false);
    };
    if this.m_skillCheckContainer.GetEngineeringSlot().IsPassed() {
      this.m_skillCheckContainer.GetEngineeringSlot().SetIsPassed(false);
    };
    if this.m_skillCheckContainer.GetHackingSlot().IsPassed() {
      this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(false);
    };
  }

  public final func OnActionCooldownEvent(evt: ref<ActionCooldownEvent>) -> EntityNotificationType {
    let player: ref<PlayerPuppet> = this.GetPlayerMainObject() as PlayerPuppet;
    if IsDefined(player) {
      player.GetCooldownStorage().ResolveCooldownEvent(evt);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final const func GetHudManager() -> ref<HUDManager> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"HUDManager") as HUDManager;
  }

  protected final const func GetTakeOverControlSystem() -> ref<TakeOverControlSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"TakeOverControlSystem") as TakeOverControlSystem;
  }

  public const func IsConnectedToCLS() -> Bool {
    let parent: ref<ScriptableDeviceComponentPS>;
    let parents: array<ref<DeviceComponentPS>> = this.GetImmediateParents();
    let i: Int32 = 0;
    while i < ArraySize(parents) {
      parent = parents[i] as ScriptableDeviceComponentPS;
      if IsDefined(parent) && parent.IsConnectedToCLS() {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected func OnToggleTakeOverControl(evt: ref<ToggleTakeOverControl>) -> EntityNotificationType {
    this.UseNotifier(evt);
    if this.CanPlayerTakeOverControl() {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ActionToggleTakeOverControl() -> ref<ToggleTakeOverControl> {
    let action: ref<ToggleTakeOverControl> = new ToggleTakeOverControl();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties(this.m_isControlledByThePlayer);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  protected final func OnTCSTakeOverControlActivate(evt: ref<TCSTakeOverControlActivate>) -> EntityNotificationType {
    let chainBlackBoard: ref<IBlackboard>;
    let toggleOn: ref<SetDeviceON>;
    if this.IsControlledByPlayer() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    chainBlackBoard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().DeviceTakeControl);
    chainBlackBoard.SetBool(GetAllBlackboardDefs().DeviceTakeControl.IsDeviceWorking, true, true);
    this.m_isControlledByThePlayer = true;
    if !this.IsDisabled() {
      if !this.IsON() {
        this.CacheDeviceState(this.GetDeviceState());
        toggleOn = this.ActionSetDeviceON();
        toggleOn.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
        this.GetPersistencySystem().QueuePSDeviceEvent(toggleOn);
      };
    } else {
      chainBlackBoard.SetBool(GetAllBlackboardDefs().DeviceTakeControl.IsDeviceWorking, false, true);
    };
    this.SendDeviceNotOperationalEvent();
    this.SetPSMPostpondedParameterBool(this.m_isControlledByThePlayer);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func SendDeviceNotOperationalEvent() -> Void;

  protected func OnTCSTakeOverControlDeactivate(evt: ref<TCSTakeOverControlDeactivate>) -> EntityNotificationType {
    this.m_isControlledByThePlayer = false;
    this.SetPSMPostpondedParameterBool(this.m_isControlledByThePlayer);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func SetPSMPostpondedParameterBool(value: Bool) -> Void {
    let player: ref<GameObject> = this.GetPlayerMainObject();
    let stateChangeEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    if value {
      stateChangeEvent.id = n"DeviceControlStart";
    } else {
      stateChangeEvent.id = n"DeviceControlStop";
    };
    stateChangeEvent.value = value;
    this.GetOwnerEntityWeak().QueueEventForEntityID(player.GetEntityID(), stateChangeEvent);
  }

  public func ActionProgramSetDeviceOff() -> ref<ProgramSetDeviceOff> {
    let multiplier: Float;
    let action: ref<ProgramSetDeviceOff> = new ProgramSetDeviceOff();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTogglePowerClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    multiplier = GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(GetPlayer(this.GetGameInstance()).GetEntityID()), gamedataStatType.CameraShutdownExtension);
    action.SetDurationValue(action.GetDurationFromTDBRecord(t"MinigameAction.NetworkCameraShutdown") * multiplier);
    return action;
  }

  protected func OnProgramSetDeviceOff(evt: ref<ProgramSetDeviceOff>) -> EntityNotificationType {
    if evt.IsStarted() {
      this.QueuePSEvent(this, this.ActionSetDeviceOFF());
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      this.QueuePSEvent(this, this.ActionSetDeviceON());
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func ActionProgramSetDeviceAttitude() -> ref<ProgramSetDeviceAttitude> {
    let action: ref<ProgramSetDeviceAttitude> = new ProgramSetDeviceAttitude();
    action.clearanceLevel = DefaultActionsParametersHolder.GetTakeOverControl();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetDurationValue(action.GetDurationFromTDBRecord(t"MinigameAction.NetworkCameraFriendly"));
    return action;
  }

  protected func OnProgramSetDeviceAttitude(evt: ref<ProgramSetDeviceAttitude>) -> EntityNotificationType {
    if evt.IsStarted() {
      this.QueuePSEvent(this, this.ActionSetDeviceAttitude());
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      this.QueuePSEvent(this, this.ActionSetDeviceON());
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func AddWillingInvestigator(id: EntityID) -> Void {
    if !this.HasWillingInvestigator(id) {
      ArrayPush(this.m_willingInvestigators, id);
    };
  }

  public final const func HasWillingInvestigator(id: EntityID) -> Bool {
    return ArrayContains(this.m_willingInvestigators, id);
  }

  public final const func GetWillingInvestigators() -> array<EntityID> {
    return this.m_willingInvestigators;
  }

  public final func ClearWillingInvestigators() -> Void {
    ArrayClear(this.m_willingInvestigators);
  }

  public final func IsSomeoneUsingNPCWorkspot() -> Bool {
    let npc: ref<GameObject> = GameInstance.GetWorkspotSystem(this.GetGameInstance()).GetDeviceUser(PersistentID.ExtractEntityID(this.GetID()));
    if IsDefined(npc) && !npc.IsDead() {
      return true;
    };
    return false;
  }

  protected func ActionOverloadDevice() -> ref<OverloadDevice> {
    let action: ref<OverloadDevice> = new OverloadDevice();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected func OnOverloadDevice(evt: ref<OverloadDevice>) -> EntityNotificationType {
    this.m_wasQuickHacked = true;
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final const func ShouldNPCWorkspotFinishLoop() -> Bool {
    return this.m_shouldNPCWorkspotFinishLoop;
  }

  public final const func HasNPCWorkspotKillInteraction() -> Bool {
    return this.m_hasNPCWorkspotKillInteraction;
  }
}

public static func OperatorXor(a: Bool, b: Bool) -> Bool {
  return NotEquals(a, b) ? true : false;
}
