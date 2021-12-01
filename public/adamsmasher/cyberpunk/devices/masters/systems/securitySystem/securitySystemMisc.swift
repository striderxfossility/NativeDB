
public static exec func DebugSS(game: GameInstance, val: String) -> Void {
  let str: String;
  let num: Int32 = StringToInt(val);
  if num == 0 || num == 1 {
    SetFactValue(game, n"debugSS", num);
    return;
  };
  str = StrLower(val);
  if Equals(str, "true") {
    num = 1;
  } else {
    if Equals(str, "false") {
      num = 0;
    };
  };
  SetFactValue(game, n"debugSS", num);
}

public class SecSystemDebugger extends ScriptableSystem {

  @attrib(unsavable, "true")
  private persistent let lastInstruction: EReprimandInstructions;

  @attrib(unsavable, "true")
  private persistent let instructionSet: Bool;

  @attrib(unsavable, "true")
  private persistent let lastInstructionTime: Float;

  @attrib(unsavable, "true")
  private persistent let lastInput: ESecurityNotificationType;

  @attrib(unsavable, "true")
  private persistent let inputSet: Bool;

  @attrib(unsavable, "true")
  private persistent let lastInputTime: Float;

  @attrib(unsavable, "true")
  private persistent let lastUpdateTime: Float;

  @attrib(unsavable, "true")
  private persistent let realTimeCallbackID: DelayID;

  @attrib(unsavable, "true")
  private persistent let realTimeCallback: Bool;

  @attrib(unsavable, "true")
  private persistent let realTime: Float;

  @attrib(unsavable, "true")
  private persistent let callstack: array<CName>;

  @attrib(unsavable, "true")
  private persistent let ids: array<Uint32>;

  @attrib(unsavable, "true")
  private persistent let background: Uint32;

  @attrib(unsavable, "true")
  private persistent let sysName: Uint32;

  @attrib(unsavable, "true")
  private persistent let sysState: Uint32;

  @attrib(unsavable, "true")
  private persistent let mostDangerousArea: Uint32;

  @attrib(unsavable, "true")
  private persistent let blacklistReason: Uint32;

  @attrib(unsavable, "true")
  private persistent let blacklistCount: Uint32;

  @attrib(unsavable, "true")
  private persistent let reprimand: Uint32;

  @attrib(unsavable, "true")
  private persistent let repInstruction: Uint32;

  @attrib(unsavable, "true")
  private persistent let reprimandID: Uint32;

  @attrib(unsavable, "true")
  private persistent let input: Uint32;

  @attrib(unsavable, "true")
  private persistent let regTime: Uint32;

  @attrib(unsavable, "true")
  private persistent let inputTime: Uint32;

  @attrib(unsavable, "true")
  private persistent let instructionTime: Uint32;

  @attrib(unsavable, "true")
  private persistent let actualTime: Uint32;

  private let system: ref<SecuritySystemControllerPS>;

  @default(SecSystemDebugger, 60.f)
  private let refreshTime: Float;

  private final func OnRealTimeUpdate(req: ref<RealTimeUpdateRequest>) -> Void {
    this.RealTimeUpdate(req.m_evt, req.m_time);
  }

  private final func OnUpdateDebuggerRequest(req: ref<UpdateDebuggerRequest>) -> Void {
    this.Update(req.m_system, req.m_time, req.m_instructionAttached, req.m_inputAttached, req.m_callstack, req.m_instruction, req.m_recentInput);
  }

  private final func RealTimeUpdate(evt: ref<TickableEvent>, time: Float) -> Void {
    let color: Color;
    let dvs: ref<DebugVisualizerSystem>;
    let threshold: Float;
    let tickableEvent: ref<SysDebuggerEvent>;
    if !IsDefined(this.system) {
      return;
    };
    dvs = GameInstance.GetDebugVisualizerSystem(this.system.GetGameInstance());
    dvs.ClearLayer(this.regTime);
    dvs.ClearLayer(this.inputTime);
    dvs.ClearLayer(this.instructionTime);
    dvs.ClearLayer(this.actualTime);
    this.realTime = time;
    if this.realTime - this.lastUpdateTime > this.refreshTime - 10.00 {
      this.actualTime = dvs.DrawText(new Vector4(500.00, 630.00, 0.00, 0.00), "REAL TIME: " + FloatToString(this.realTime), gameDebugViewETextAlignment.Left, SColor.Red());
    } else {
      this.actualTime = dvs.DrawText(new Vector4(500.00, 630.00, 0.00, 0.00), "REAL TIME: " + FloatToString(this.realTime), gameDebugViewETextAlignment.Left, SColor.White());
    };
    threshold = this.realTime - this.lastUpdateTime;
    if threshold < 1.00 {
      color = SColor.Green();
    } else {
      if threshold < 3.00 {
        color = SColor.Yellow();
      } else {
        color = SColor.Red();
      };
    };
    this.regTime = dvs.DrawText(new Vector4(500.00, 650.00, 0.00, 0.00), "LAST UPDATE: " + FloatToString(threshold) + " sec ago", gameDebugViewETextAlignment.Left, color);
    threshold = this.realTime - this.lastInputTime;
    if threshold < 1.00 {
      color = SColor.Green();
    } else {
      if threshold < 3.00 {
        color = SColor.Yellow();
      } else {
        color = SColor.Red();
      };
    };
    this.inputTime = dvs.DrawText(new Vector4(500.00, 670.00, 0.00, 0.00), "LAST INPUT: " + FloatToString(threshold) + " sec ago", gameDebugViewETextAlignment.Left, color);
    threshold = this.realTime - this.lastInstructionTime;
    if threshold < 1.00 {
      color = SColor.Green();
    } else {
      if threshold < 3.00 {
        color = SColor.Yellow();
      } else {
        color = SColor.Red();
      };
    };
    this.instructionTime = dvs.DrawText(new Vector4(500.00, 690.00, 0.00, 0.00), "LAST INSTRUCTION: " + FloatToString(threshold) + " sec ago", gameDebugViewETextAlignment.Left, color);
    ArrayPush(this.ids, dvs.DrawText(new Vector4(500.00, 720.00, 0.00, 0.00), "INPUTS: " + this.system.DebugGetInputsCount(), gameDebugViewETextAlignment.Left, SColor.White()));
    ArrayPush(this.ids, dvs.DrawText(new Vector4(600.00, 720.00, 0.00, 0.00), "OUTPUTS: " + this.system.DebugGetOutputsCount(), gameDebugViewETextAlignment.Left, SColor.White()));
    if Equals(evt.GetState(), gameTickableEventState.LastTick) {
      if this.realTime - this.lastUpdateTime < this.refreshTime {
        GameInstance.GetDelaySystem(this.system.GetGameInstance()).CancelTick(this.realTimeCallbackID);
        tickableEvent = new SysDebuggerEvent();
        this.realTimeCallbackID = GameInstance.GetDelaySystem(this.system.GetGameInstance()).TickOnEvent(GameInstance.GetPlayerSystem(this.system.GetGameInstance()).GetLocalPlayerControlledGameObject(), tickableEvent, this.refreshTime);
      } else {
        this.Clean(dvs);
      };
    };
  }

  private final func Clean(dvs: ref<DebugVisualizerSystem>) -> Void {
    let i: Int32;
    this.instructionSet = false;
    this.inputSet = false;
    GameInstance.GetDelaySystem(this.system.GetGameInstance()).CancelTick(this.realTimeCallbackID);
    this.realTimeCallback = false;
    dvs.ClearLayer(this.regTime);
    dvs.ClearLayer(this.inputTime);
    dvs.ClearLayer(this.instructionTime);
    dvs.ClearLayer(this.actualTime);
    i = 0;
    while i < ArraySize(this.ids) {
      dvs.ClearLayer(this.ids[i]);
      i += 1;
    };
    ArrayClear(this.ids);
    ArrayClear(this.callstack);
    this.system = null;
  }

  private final func Update(const sys: ref<SecuritySystemControllerPS>, time: Float, instructionsAttached: Bool, inputAttached: Bool, trace: CName, opt instruction: EReprimandInstructions, opt recentInput: ref<SecuritySystemInput>) -> Void {
    let area: ref<SecurityAreaControllerPS>;
    let blackReason: BlacklistReason;
    let color: Color;
    let extraTag: String;
    let i: Int32;
    let j: Int32;
    let repOngoing: Bool;
    let tickableEvent: ref<SysDebuggerEvent>;
    let vPos: Float;
    let warningCount: Int32;
    let dvs: ref<DebugVisualizerSystem> = GameInstance.GetDebugVisualizerSystem(sys.GetGameInstance());
    if !IsDefined(this.system) {
      this.system = sys;
    };
    if sys != this.system {
      this.Clean(dvs);
      this.system = sys;
    };
    if ArraySize(this.callstack) > 10 {
      ArrayErase(this.callstack, 0);
    };
    ArrayPush(this.callstack, trace);
    if !this.realTimeCallback {
      tickableEvent = new SysDebuggerEvent();
      this.realTimeCallbackID = GameInstance.GetDelaySystem(sys.GetGameInstance()).TickOnEvent(GameInstance.GetPlayerSystem(sys.GetGameInstance()).GetLocalPlayerControlledGameObject(), tickableEvent, this.refreshTime);
      this.realTimeCallback = true;
    };
    this.lastUpdateTime = time;
    if instructionsAttached {
      this.lastInstruction = instruction;
      this.instructionSet = true;
      this.lastInstructionTime = time;
    };
    if inputAttached {
      this.lastInput = recentInput.GetNotificationType();
      this.inputSet = true;
      this.lastInputTime = time;
    };
    i = 0;
    while i < ArraySize(this.ids) {
      dvs.ClearLayer(this.ids[i]);
      i += 1;
    };
    ArrayClear(this.ids);
    ArrayPush(this.ids, this.background = dvs.DrawRect(new Vector4(490.00, 480.00, 0.00, 0.00), new Vector4(500.00, 620.00, 0.00, 0.00), SColor.Black()));
    ArrayPush(this.ids, this.background = dvs.DrawRect(new Vector4(490.00, 480.00, 0.00, 0.00), new Vector4(500.00, 620.00, 0.00, 0.00), SColor.Black()));
    ArrayPush(this.ids, this.sysName = dvs.DrawText(new Vector4(500.00, 500.00, 0.00, 0.00), NameToString(sys.GetDebugPath()), gameDebugViewETextAlignment.Left, SColor.White()));
    switch sys.GetSecurityState() {
      case ESecuritySystemState.SAFE:
        color = SColor.Green();
        break;
      case ESecuritySystemState.ALERTED:
        color = SColor.Yellow();
        break;
      case ESecuritySystemState.COMBAT:
        color = SColor.Red();
        break;
      default:
        color = SColor.White();
    };
    ArrayPush(this.ids, this.sysState = dvs.DrawText(new Vector4(500.00, 520.00, 0.00, 0.00), "STATE: " + EnumValueToString("ESecuritySystemState", Cast(EnumInt(sys.GetSecurityState()))), gameDebugViewETextAlignment.Left, color));
    area = sys.GetMostDangerousSecurityAreaForEntityID(sys.GetPlayerEntityID());
    if IsDefined(area) {
      switch area.GetSecurityAreaType() {
        case ESecurityAreaType.SAFE:
          color = SColor.Green();
          break;
        case ESecurityAreaType.RESTRICTED:
          color = SColor.Yellow();
          break;
        case ESecurityAreaType.DANGEROUS:
          color = SColor.Red();
          break;
        default:
          color = SColor.White();
      };
      ArrayPush(this.ids, this.mostDangerousArea = dvs.DrawText(new Vector4(500.00, 540.00, 0.00, 0.00), "AREA: " + EnumValueToString("ESecurityAreaType", Cast(EnumInt(area.GetSecurityAreaType()))), gameDebugViewETextAlignment.Left, color));
    } else {
      ArrayPush(this.ids, this.mostDangerousArea = dvs.DrawText(new Vector4(500.00, 540.00, 0.00, 0.00), "NOT IN ANY AREA", gameDebugViewETextAlignment.Left, SColor.Green()));
    };
    blackReason = sys.Debug_GetPlayerBlacklistReason();
    switch blackReason {
      case BlacklistReason.TRESPASSING:
        color = SColor.Yellow();
        break;
      case BlacklistReason.REPRIMAND:
        color = SColor.Orange();
        break;
      case BlacklistReason.COMBAT:
        color = SColor.Red();
        break;
      default:
        color = SColor.Green();
    };
    if NotEquals(blackReason, BlacklistReason.UNINITIALIZED) {
      ArrayPush(this.ids, this.blacklistReason = dvs.DrawText(new Vector4(500.00, 560.00, 0.00, 0.00), "BLACKLISTED FOR: " + EnumValueToString("BlacklistReason", Cast(EnumInt(blackReason))), gameDebugViewETextAlignment.Left, color));
    } else {
      ArrayPush(this.ids, this.blacklistReason = dvs.DrawText(new Vector4(500.00, 560.00, 0.00, 0.00), "NOT BLACKLISTED", gameDebugViewETextAlignment.Left, color));
    };
    warningCount = sys.Debug_GetPlayerWarningCount();
    switch warningCount {
      case 0:
        color = SColor.Green();
        break;
      case 1:
        color = SColor.Yellow();
        break;
      case 2:
        color = SColor.Orange();
        break;
      default:
        color = SColor.Red();
    };
    ArrayPush(this.ids, this.blacklistCount = dvs.DrawText(new Vector4(750.00, 560.00, 0.00, 0.00), "WARNINGS: " + IntToString(warningCount), gameDebugViewETextAlignment.Left, color));
    repOngoing = sys.IsReprimandOngoing();
    if repOngoing {
      ArrayPush(this.ids, this.reprimand = dvs.DrawText(new Vector4(500.00, 580.00, 0.00, 0.00), "REPRIMAND: " + BoolToString(repOngoing), gameDebugViewETextAlignment.Left, SColor.Orange()));
    } else {
      ArrayPush(this.ids, this.reprimand = dvs.DrawText(new Vector4(500.00, 580.00, 0.00, 0.00), "REPRIMAND: " + BoolToString(repOngoing), gameDebugViewETextAlignment.Left, SColor.Green()));
    };
    if this.instructionSet {
      if instructionsAttached && time - this.lastInstructionTime < 5.00 {
        extraTag = "[ ! ] ";
      };
      ArrayPush(this.ids, this.repInstruction = dvs.DrawText(new Vector4(650.00, 580.00, 0.00, 0.00), extraTag + "INSTRUCTION: " + EnumValueToString("EReprimandInstructions", Cast(EnumInt(this.lastInstruction))), gameDebugViewETextAlignment.Left, SColor.Yellow()));
    };
    ArrayPush(this.ids, this.reprimandID = dvs.DrawText(new Vector4(925.00, 580.00, 0.00, 0.00), "ID: " + IntToString(sys.Debug_GetReprimandID()), gameDebugViewETextAlignment.Left, SColor.Yellow()));
    if this.inputSet {
      if inputAttached && time - this.lastInputTime < 5.00 {
        extraTag = "[ ! ] ";
      };
      ArrayPush(this.ids, this.input = dvs.DrawText(new Vector4(500.00, 600.00, 0.00, 0.00), extraTag + "LAST INPUT: " + EnumValueToString("ESecurityNotificationType", Cast(EnumInt(this.lastInput))), gameDebugViewETextAlignment.Left, SColor.Yellow()));
    };
    ArrayPush(this.ids, this.input = dvs.DrawText(new Vector4(500.00, 740.00, 0.00, 0.00), "CALLSTACK:", gameDebugViewETextAlignment.Left, SColor.Yellow()));
    vPos = 740.00;
    j = 0;
    i = ArraySize(this.callstack) - 1;
    while i >= 0 {
      vPos += 20.00;
      extraTag = "[ " + j + " ] ";
      if i == ArraySize(this.callstack) - 1 {
        ArrayPush(this.ids, dvs.DrawText(new Vector4(500.00, vPos, 0.00, 0.00), extraTag + NameToString(this.callstack[i]), gameDebugViewETextAlignment.Left, SColor.Green()));
      } else {
        if i == ArraySize(this.callstack) - 2 {
          ArrayPush(this.ids, dvs.DrawText(new Vector4(500.00, vPos, 0.00, 0.00), extraTag + NameToString(this.callstack[i]), gameDebugViewETextAlignment.Left, SColor.Yellow()));
        } else {
          ArrayPush(this.ids, dvs.DrawText(new Vector4(500.00, vPos, 0.00, 0.00), extraTag + NameToString(this.callstack[i]), gameDebugViewETextAlignment.Left, SColor.White()));
        };
      };
      j += 1;
      i -= 1;
    };
  }
}

public class PlayerSpotted extends Event {

  private let comesFromNPC: Bool;

  private let ownerID: PersistentID;

  private let doesSee: Bool;

  private let agentAreas: array<ref<SecurityAreaControllerPS>>;

  public final static func Construct(isReporterNPC: Bool, owner: PersistentID, doSee: Bool, areas: array<ref<SecurityAreaControllerPS>>) -> ref<PlayerSpotted> {
    let ps: ref<PlayerSpotted>;
    if !PersistentID.IsDefined(owner) {
      return null;
    };
    ps = new PlayerSpotted();
    ps.comesFromNPC = isReporterNPC;
    ps.ownerID = owner;
    ps.doesSee = doSee;
    ps.agentAreas = areas;
    return ps;
  }

  public final const func GetComesFromNPC() -> Bool {
    return this.comesFromNPC;
  }

  public final const func GetOwnerID() -> PersistentID {
    return this.ownerID;
  }

  public final const func DoesSee() -> Bool {
    return this.doesSee;
  }

  public final const func GetAgentAreas() -> array<ref<SecurityAreaControllerPS>> {
    return this.agentAreas;
  }
}

public struct NPCReference {

  public edit let communitySpawner: NodeRef;

  public edit let entryName: CName;

  public final static func IsValid(self: NPCReference) -> Bool {
    return GlobalNodeRef.IsDefined(ResolveNodeRef(self.communitySpawner, Cast(GlobalNodeID.GetRoot()))) && IsNameValid(self.entryName);
  }

  public final static func GetSpawnerEntityID(self: NPCReference) -> EntityID {
    return Cast(ResolveNodeRef(self.communitySpawner, Cast(GlobalNodeID.GetRoot())));
  }
}

public class SetSecuritySystemState extends Event {

  public edit let state: ESecuritySystemState;

  public final func GetFriendlyDescription() -> String {
    return "Set Security System State";
  }
}

public class SuppressSecuritySystemStateChange extends Event {

  @attrib(tooltip, "From now on security system can be changed ONLY via quest blocks. ALL gameplay events will be discarded until this flag is set to false.")
  public edit let forceSecuritySystemIntoStrictQuestControl: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Suppress Security System State Change";
  }
}

public class AuthorizePlayerInSecuritySystem extends Event {

  @attrib(tooltip, "Should this event authorize player, or remove him from the list of authorized users. ESL is ingored if authorize == FALSE")
  @default(AuthorizePlayerInSecuritySystem, true)
  public edit let authorize: Bool;

  @attrib(tooltip, "If this is turned to FALSE player will be able to use devices in given SecuritySystem (doors/computers etc) however if he is blacklisted he will still be attacked by turrets and NPCs. We support case where player is both blacklisted and authorized at the same time")
  @default(AuthorizePlayerInSecuritySystem, true)
  public edit let forceRemoveFromBlacklist: Bool;

  @attrib(tooltip, "how strong should the authorization be. If you have two areas with different ESL (i.e ESL_1 and ESL_2) with this property you can give player authorization in one area but not the other. ESL_4 == TOTAL AUTHORIZATION EVERYWHERE")
  @default(AuthorizePlayerInSecuritySystem, ESecurityAccessLevel.ESL_4)
  public edit let ESL: ESecurityAccessLevel;

  public final func GetFriendlyDescription() -> String {
    return "Authorize Player in Security System";
  }
}

public class BlacklistPlayer extends Event {

  @attrib(tooltip, "Should this event blacklist player, or removing him from the blacklist. Reason is ingored if blacklist == FALSE")
  @default(BlacklistPlayer, true)
  public edit let blacklist: Bool;

  @attrib(tooltip, "Determine why target is blacklisted. It will influence how Security System resolves response against player in the future. Trespasser will be treated differently than someone blacklisted for starting a combat.")
  @default(BlacklistPlayer, BlacklistReason.COMBAT)
  public edit let reason: BlacklistReason;

  @attrib(tooltip, "Player's authorization will be void. Keep in mind this may remove authorization that player has granted himself via gameplay if it was possible")
  public edit let forceRemoveAuthorization: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Blacklist player";
  }
}

public class SuppressNPCInSecuritySystem extends Event {

  @attrib(tooltip, "This NPC will NO LONGER receive events FROM security system")
  public edit let suppressIncomingEvents: Bool;

  @attrib(tooltip, "This NPC will NO LONGER send events TO security system")
  public edit let suppressOutgoingEvents: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Suppress Communication Between Security System & NPC";
  }
}

public class QuestChangeSecuritySystemAttitudeGroup extends Event {

  @attrib(customEditor, "TweakDBGroupInheritance;AttitudeGroup")
  @attrib(tooltip, "Security System and all of its DEVICES (not NPCs) will change attitude group to this one")
  public edit let newAttitudeGroup: TweakDBID;

  public final func GetFriendlyDescription() -> String {
    return "Change Security System Attitude Group";
  }
}

public struct SpawnerData {

  public let spawnerID: EntityID;

  public let entryNames: array<CName>;

  public final static func Construct(id: EntityID, entry: CName) -> SpawnerData {
    let s: SpawnerData;
    s.spawnerID = id;
    ArrayPush(s.entryNames, entry);
    return s;
  }
}

public class QuestIllegalActionNotification extends QuestSecuritySystemInput {

  public final func GetFriendlyDescription() -> String {
    return "Illegal Action Notification [ SYSTEM ]";
  }
}

public class QuestCombatActionNotification extends QuestSecuritySystemInput {

  public final func GetFriendlyDescription() -> String {
    return "Combat Action Notification [ SYSTEM ]";
  }
}

public class QuestAddTransition extends Event {

  @attrib(tooltip, "This transition will be added to  the list of already exisitng transtions. It will not be executed immediately.")
  public edit let transition: AreaTypeTransition;

  public final func GetFriendlyDescription() -> String {
    return "Add permanent transtion";
  }
}

public class QuestRemoveTransition extends Event {

  @attrib(rangeMax, "23")
  @attrib(rangeMin, "0")
  @attrib(tooltip, "Pick hour. If any transition will be found at this hour it will be removed.")
  public edit let removeTransitionFrom: Int32;

  public final func GetFriendlyDescription() -> String {
    return "Remove permanent transtion";
  }
}

public class QuestExecuteTransition extends Event {

  @attrib(tooltip, "Perform transition immediately. Transition Hour property is ignored in this event")
  public edit let transition: AreaTypeTransition;

  public final func GetFriendlyDescription() -> String {
    return "Immediately Execute Single Transtion";
  }
}

public class QuestCombatActionAreaNotification extends Event {

  public edit let revealPlayerSettings: RevealPlayerSettings;

  public final func GetFriendlyDescription() -> String {
    return "[ Area ] Combat Action Notification";
  }
}

public class QuestIllegalActionAreaNotification extends Event {

  public edit let revealPlayerSettings: RevealPlayerSettings;

  public final func GetFriendlyDescription() -> String {
    return "[ Area ] Illegal Action Notification";
  }
}

public class ReprimandUpdate extends Event {

  public let reprimandInstructions: EReprimandInstructions;

  public let target: EntityID;

  public let targetPos: Vector4;

  public let currentPerformer: wref<GameObject>;

  public final static func Construct(performer: ref<GameObject>, target: EntityID, instructions: EReprimandInstructions, opt pos: Vector4) -> ref<ReprimandUpdate> {
    let update: ref<ReprimandUpdate> = new ReprimandUpdate();
    update.currentPerformer = performer;
    update.target = target;
    update.reprimandInstructions = instructions;
    update.targetPos = pos;
    return update;
  }
}

public class TakeOverSecuritySystem extends ActionBool {

  public final func SetProperties() -> Void {
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#17835", n"LocKey#17835");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if TakeOverSecuritySystem.IsAvailable(device) && TakeOverSecuritySystem.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsUnpowered() || device.IsOFF() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(requesterClearancer: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(requesterClearancer, DefaultActionsParametersHolder.GetSystemCompatibleClearance()) {
      return true;
    };
    return false;
  }
}

public class FullSystemRestart extends ActionBool {

  @default(FullSystemRestart, 10)
  public let m_restartDuration: Int32;

  public final func SetProperties(isRestarting: Bool, duration: Int32) -> Void {
    this.actionName = n"FullSystemRestart";
    this.m_restartDuration = duration;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isRestarting, n"LocKey#17836", n"LocKey#17837");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if FullSystemRestart.IsAvailable(device) && FullSystemRestart.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsUnpowered() || device.IsOFF() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(requesterClearancer: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(requesterClearancer, DefaultActionsParametersHolder.GetSystemCompatibleClearance()) {
      return true;
    };
    return false;
  }
}

public class SecuritySystemStatus extends BaseDeviceStatus {

  public func SetProperties(const deviceRef: ref<ScriptableDeviceComponentPS>) -> Void {
    this.SetProperties(deviceRef);
    this.actionName = n"SecuritySystemStatus";
    this.prop.second = ToVariant(EnumInt((deviceRef as SecuritySystemControllerPS).GetSecurityState()));
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String;
    if this.m_isRestarting {
      return "LocKey#17797";
    };
    if FromVariant(this.prop.first) > 0 {
      switch this.prop.second {
        case ToVariant(1):
          str = "LocKey#17798";
          break;
        case ToVariant(2):
          str = "LocKey#17799";
          break;
        case ToVariant(3):
          str = "LocKey#17800";
          break;
        default:
          if !IsFinal() {
            LogDevices(this, "GetCurrentDisplayString / Unhandled sec sys state", ELogType.WARNING);
          };
      };
    } else {
      return this.GetCurrentDisplayString();
    };
    return str;
  }

  public const func GetStatusValue() -> Int32 {
    if FromVariant(this.prop.first) > 0 {
      return FromVariant(this.prop.second);
    };
    return FromVariant(this.prop.first);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SecuritySystemStatus.IsAvailable(device) && SecuritySystemStatus.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return BaseDeviceStatus.IsAvailable(device);
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return BaseDeviceStatus.IsClearanceValid(clearance);
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "wrong_action";
  }
}

public class SecuritySystemInput extends SecurityAreaEvent {

  private let m_lastKnownPosition: Vector4;

  private let m_notifier: ref<SharedGameplayPS>;

  private let m_type: ESecurityNotificationType;

  private let m_objectOfInterest: wref<GameObject>;

  private let m_canPerformReprimand: Bool;

  private let m_shouldLeadReprimend: Bool;

  @default(SecuritySystemInput, -1)
  private let m_id: Int32;

  private let m_customRecipientsList: array<EntityID>;

  private let m_isSharingRestricted: Bool;

  private let m_debugReporterCharRecord: ref<Character_Record>;

  private let m_stimTypeTriggeredAlarm: gamedataStimType;

  public final func Initialize(initialEvent: ref<SecuritySystemInput>) -> Void {
    this.SetProperties(initialEvent.GetLastKnownPosition(), initialEvent.GetWhoBreached(), initialEvent.GetNotifierHandle(), initialEvent.GetNotificationType(), initialEvent.CanPerformReprimand(), initialEvent.ShouldLeadReprimend(), initialEvent.GetID(), initialEvent.GetCustomRecipientsList(), initialEvent.IsSharingRestricted());
  }

  public final func SetProperties(lkp: Vector4, whoBreached: ref<GameObject>, reporter: wref<SharedGameplayPS>, type: ESecurityNotificationType, canDoReprimand: Bool, shouldLeadReprimand: Bool, opt stimType: gamedataStimType) -> Void {
    this.m_lastKnownPosition = lkp;
    if Equals(type, ESecurityNotificationType.ALARM) || Equals(type, ESecurityNotificationType.DEVICE_DESTROYED) {
      this.m_objectOfInterest = whoBreached;
    } else {
      this.SetWhoBreached(whoBreached);
    };
    this.m_notifier = reporter;
    this.m_type = type;
    this.m_canPerformReprimand = canDoReprimand;
    this.m_shouldLeadReprimend = shouldLeadReprimand;
    this.m_stimTypeTriggeredAlarm = stimType;
  }

  public final func SetProperties(lkp: Vector4, whoBreached: ref<GameObject>, reporter: wref<SharedGameplayPS>, type: ESecurityNotificationType, canDoReprimand: Bool, shouldLeadReprimand: Bool, id: Int32, customRecipients: array<EntityID>, isSharingRestricted: Bool) -> Void {
    this.SetProperties(lkp, whoBreached, reporter, type, canDoReprimand, shouldLeadReprimand);
    this.m_id = id;
    this.m_customRecipientsList = customRecipients;
    this.m_isSharingRestricted = isSharingRestricted;
  }

  public final const func GetNotifierHandle() -> wref<SharedGameplayPS> {
    return this.m_notifier;
  }

  public final const func GetNotificationType() -> ESecurityNotificationType {
    return this.m_type;
  }

  public final const func GetObjectOfInterest() -> ref<GameObject> {
    return this.m_objectOfInterest;
  }

  public final const func CanPerformReprimand() -> Bool {
    return this.m_canPerformReprimand;
  }

  public final const func ShouldLeadReprimend() -> Bool {
    return this.m_shouldLeadReprimend;
  }

  public final const func GetLastKnownPosition() -> Vector4 {
    return this.m_lastKnownPosition;
  }

  public final const func GetID() -> Int32 {
    return this.m_id;
  }

  public final const func HasCustomRecipients() -> Bool {
    return ArraySize(this.m_customRecipientsList) > 0;
  }

  public final const func GetCustomRecipientsList() -> array<EntityID> {
    return this.m_customRecipientsList;
  }

  public final const func IsSharingRestricted() -> Bool {
    return this.m_isSharingRestricted;
  }

  public final const func GetStimTypeTriggeredAlarm() -> gamedataStimType {
    return this.m_stimTypeTriggeredAlarm;
  }

  public final const func GetPuppetCharRecord() -> ref<Character_Record> {
    return this.m_debugReporterCharRecord;
  }

  public final const func GetPuppetDisplayName() -> String {
    return LocKeyToString(this.m_debugReporterCharRecord.DisplayName());
  }

  public final func SetAsReprimendLeader(isLeader: Bool) -> Void {
    this.m_shouldLeadReprimend = isLeader;
  }

  public final func SetID(id: Int32) -> Void {
    this.m_id = id;
  }

  public final func AttachCustomRecipientsList(list: array<EntityID>) -> Void {
    this.m_customRecipientsList = list;
  }

  public final func ModifyNotificationType(newEventType: ESecurityNotificationType) -> Void {
    this.m_type = newEventType;
  }

  public final func RestrictSharing() -> Void {
    this.m_isSharingRestricted = true;
  }

  public final func SetLastKnownPosition(lkp: Vector4) -> Void {
    this.m_lastKnownPosition = lkp;
  }

  public final func SetObjectOfInterest(object: wref<GameObject>) -> Void {
    this.m_objectOfInterest = object;
  }

  public final func SetPuppetCharacterRecord(record: TweakDBID) -> Void {
    this.m_debugReporterCharRecord = TweakDBInterface.GetCharacterRecord(record);
  }
}

public class SecuritySystemOutput extends ActionBool {

  private let m_currentSecurityState: ESecuritySystemState;

  private let m_breachOrigin: EBreachOrigin;

  private let m_originalInputEvent: ref<SecuritySystemInput>;

  private let m_securityStateChanged: Bool;

  public final func Initialize(originalEvent: ref<SecuritySystemOutput>) -> Void {
    let inputCopy: ref<SecuritySystemInput> = new SecuritySystemInput();
    inputCopy.Initialize(originalEvent.GetOriginalInputEvent());
    this.m_currentSecurityState = originalEvent.GetCachedSecurityState();
    this.m_breachOrigin = originalEvent.GetBreachOrigin();
    this.m_securityStateChanged = originalEvent.GetSecurityStateChanged();
    this.m_originalInputEvent = inputCopy;
  }

  public final func SetProperties(currentSecuritySystemState: ESecuritySystemState, notificationEvent: ref<SecuritySystemInput>) -> Void {
    this.actionName = n"SecuritySystemOutput";
    this.m_currentSecurityState = currentSecuritySystemState;
    this.m_originalInputEvent = notificationEvent;
  }

  public final const func GetCachedSecurityState() -> ESecuritySystemState {
    return this.m_currentSecurityState;
  }

  public final const func GetOriginalInputEvent() -> ref<SecuritySystemInput> {
    return this.m_originalInputEvent;
  }

  public final const func GetSecurityStateChanged() -> Bool {
    return this.m_securityStateChanged;
  }

  public final const func GetBreachOrigin() -> EBreachOrigin {
    return this.m_breachOrigin;
  }

  public final func SetSecurityStateChanged(changed: Bool) -> Void {
    this.m_securityStateChanged = changed;
  }

  public final func SetBreachOrigin(breachType: EBreachOrigin) -> Void {
    this.m_breachOrigin = breachType;
  }

  public final func SetCachedSecuritySystemState(state: ESecuritySystemState) -> Void {
    this.m_currentSecurityState = state;
  }
}

public struct SecurityAccessLevelEntry {

  @attrib(unsavable, "true")
  @attrib(customEditor, "TweakDBGroupInheritance;Keycards.Keycard")
  public persistent let m_keycard: TweakDBID;

  @attrib(unsavable, "true")
  public persistent let m_password: CName;

  public final static func IsDataValid(self: SecurityAccessLevelEntry) -> Bool {
    if SecurityAccessLevelEntry.IsKeycardValid(self) || SecurityAccessLevelEntry.IsPasswordValid(self) {
      return true;
    };
    return false;
  }

  public final static func IsPasswordValid(self: SecurityAccessLevelEntry) -> Bool {
    return IsNameValid(self.m_password);
  }

  public final static func IsKeycardValid(self: SecurityAccessLevelEntry) -> Bool {
    return TDBID.IsValid(self.m_keycard) && self.m_keycard != t"Keycards.None";
  }
}

public struct SecurityAccessLevelEntryClient extends SecurityAccessLevelEntry {

  @attrib(unsavable, "true")
  public persistent let m_level: ESecurityAccessLevel;

  public final static func IsDataValid(self: SecurityAccessLevelEntryClient) -> Bool {
    let base: SecurityAccessLevelEntry;
    base.m_keycard = self.m_keycard;
    base.m_password = self.m_password;
    return SecurityAccessLevelEntry.IsDataValid(base);
  }

  public final static func IsPasswordValid(self: SecurityAccessLevelEntryClient) -> Bool {
    return IsNameValid(self.m_password);
  }

  public final static func IsKeycardValid(self: SecurityAccessLevelEntryClient) -> Bool {
    return TDBID.IsValid(self.m_keycard);
  }
}

public class BlacklistEntry extends IScriptable {

  @attrib(unsavable, "true")
  private persistent let entryID: EntityID;

  @attrib(unsavable, "true")
  private persistent let entryReason: BlacklistReason;

  @attrib(unsavable, "true")
  private persistent let warningsCount: Int32;

  @attrib(unsavable, "true")
  private persistent let reprimandID: Int32;

  public final func Initialize(entityID: EntityID, reason: BlacklistReason, id: Int32) -> Void {
    this.entryID = entityID;
    this.entryReason = reason;
    if Equals(reason, BlacklistReason.REPRIMAND) {
      this.reprimandID = id;
      this.warningsCount = 1;
    };
  }

  public final const func GetEntityID() -> EntityID {
    return this.entryID;
  }

  public final const func GetReason() -> BlacklistReason {
    return this.entryReason;
  }

  public final const func GetWarningsCount() -> Int32 {
    return this.warningsCount;
  }

  private final func AddWarning() -> Void {
    this.warningsCount += 1;
  }

  private final func ResetWarnings() -> Void {
    this.warningsCount = 0;
  }

  public final func UpdateBlacklistEntry(reason: BlacklistReason, id: Int32) -> Bool {
    if EnumInt(reason) < EnumInt(this.GetReason()) {
      return false;
    };
    if Equals(reason, BlacklistReason.COMBAT) {
      this.ResetWarnings();
    } else {
      if Equals(reason, BlacklistReason.REPRIMAND) && this.reprimandID != id {
        this.AddWarning();
      };
    };
    if NotEquals(reason, this.GetReason()) {
      this.entryReason = reason;
      return true;
    };
    return false;
  }

  public final func ForgetReason() -> Void {
    this.entryReason = BlacklistReason.UNINITIALIZED;
  }
}

public struct OutputValidationDataStruct {

  public let targetID: EntityID;

  public let agentID: PersistentID;

  public let reprimenderID: EntityID;

  public let eventReportedFromArea: PersistentID;

  public let eventType: ESecurityNotificationType;

  public let breachedAreas: array<PersistentID>;

  public final static func Construct(evt: ref<SecuritySystemInput>, currentReprimender: EntityID, breachedAreas: array<PersistentID>) -> OutputValidationDataStruct {
    let ovd: OutputValidationDataStruct;
    ovd.targetID = evt.GetWhoBreached().GetEntityID();
    if IsDefined(evt.GetNotifierHandle()) {
      ovd.agentID = evt.GetNotifierHandle().GetID();
    };
    ovd.reprimenderID = currentReprimender;
    ovd.eventType = evt.GetNotificationType();
    ovd.breachedAreas = breachedAreas;
    return ovd;
  }

  public final static func IsDuplicated(self: OutputValidationDataStruct, evt: ref<SecuritySystemInput>, currentReprimender: EntityID, currentlyBreachedAreas: array<PersistentID>) -> Bool {
    let i: Int32;
    let k: Int32;
    let securityArea: SecurityAreaData;
    if evt.GetWhoBreached().GetEntityID() != self.targetID {
      return false;
    };
    if NotEquals(evt.GetNotifierHandle().GetID(), self.agentID) {
      return false;
    };
    if currentReprimender != self.reprimenderID {
      return false;
    };
    if NotEquals(evt.GetNotificationType(), self.eventType) {
      return false;
    };
    if NotEquals(securityArea.id, self.eventReportedFromArea) {
      return false;
    };
    if ArraySize(self.breachedAreas) != ArraySize(currentlyBreachedAreas) {
      return false;
    };
    i = 0;
    while i < ArraySize(self.breachedAreas) {
      k = 0;
      while k < ArraySize(currentlyBreachedAreas) {
        if NotEquals(self.breachedAreas[i], currentlyBreachedAreas[i]) {
          return false;
        };
        k += 1;
      };
      i += 1;
    };
    return true;
  }
}

public struct NPCDebugInfo {

  public let spawnerID: EntityID;

  public let communityName: CName;

  public let characterRecord: ref<Character_Record>;

  public final static func IsValid(self: NPCDebugInfo) -> Bool {
    if EntityID.IsDefined(self.spawnerID) && IsNameValid(self.communityName) {
      return true;
    };
    return false;
  }
}

public static func OperatorGreater(enum1: gameCityAreaType, enum2: gameCityAreaType) -> Bool {
  if EnumInt(enum1) > EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorLogicOr(att: EAIAttitude, match: Bool) -> Bool {
  return true;
}

public static func OperatorGreater(enum1: ESecurityAccessLevel, enum2: ESecurityAccessLevel) -> Bool {
  if EnumInt(enum1) > EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorLess(enum1: ESecurityAccessLevel, enum2: ESecurityAccessLevel) -> Bool {
  if EnumInt(enum1) < EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorSubtract(level1: ESecurityAccessLevel, value: Int32) -> ESecurityAccessLevel {
  let outcome: ESecurityAccessLevel;
  let outcomeInt: Int32 = EnumInt(level1) - value;
  if outcomeInt < 0 {
    outcomeInt = 0;
  };
  if outcomeInt > Cast(EnumGetMax(n"ESecurityAccessLevel")) {
    outcomeInt = Cast(EnumGetMax(n"ESecurityAccessLevel"));
  };
  outcome = IntEnum(outcomeInt);
  return outcome;
}

public static func OperatorGreater(enum1: ESecuritySystemState, enum2: ESecuritySystemState) -> Bool {
  if EnumInt(enum1) > EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorLess(enum1: ESecuritySystemState, enum2: ESecuritySystemState) -> Bool {
  if EnumInt(enum1) < EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorGreater(enum1: ESecurityNotificationType, enum2: ESecurityNotificationType) -> Bool {
  if EnumInt(enum1) > EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorLess(enum1: ESecurityNotificationType, enum2: ESecurityNotificationType) -> Bool {
  if EnumInt(enum1) < EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorGreaterEqual(enum1: ESecurityNotificationType, enum2: ESecurityNotificationType) -> Bool {
  if EnumInt(enum1) >= EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorLessEqual(enum1: ESecurityNotificationType, enum2: ESecurityNotificationType) -> Bool {
  if EnumInt(enum1) <= EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorGreater(enum1: ESecurityAreaType, enum2: ESecurityAreaType) -> Bool {
  if EnumInt(enum1) > EnumInt(enum2) {
    return true;
  };
  return false;
}

public static func OperatorLess(enum1: ESecurityAreaType, enum2: ESecurityAreaType) -> Bool {
  if EnumInt(enum1) < EnumInt(enum2) {
    return true;
  };
  return false;
}
