
public class AISquadHelper extends IScriptable {

  public final static func GetSquadName(obj: wref<GameObject>) -> CName {
    let squadInterface: ref<SquadScriptInterface>;
    let squadName: CName;
    if AISquadHelper.GetSquadMemberInterface(obj, squadInterface) {
      squadName = squadInterface.GetName();
    };
    return squadName;
  }

  public final static func GetSquadmates(obj: wref<GameObject>, out membersList: array<wref<Entity>>, opt dontRemoveSelf: Bool) -> Bool {
    let squadInterface: ref<SquadScriptInterface>;
    if AISquadHelper.GetSquadMemberInterface(obj, squadInterface) {
      membersList = squadInterface.ListMembersWeak();
      if !dontRemoveSelf {
        ArrayRemove(membersList, obj);
      };
    };
    return ArraySize(membersList) > 0;
  }

  public final static func GetSquadmatesID(obj: wref<GameObject>, out membersListID: array<EntityID>) -> Bool {
    let i: Int32;
    let membersList: array<wref<Entity>>;
    let squadInterface: ref<SquadScriptInterface>;
    if AISquadHelper.GetSquadMemberInterface(obj, squadInterface) {
      membersList = squadInterface.ListMembersWeak();
      ArrayRemove(membersList, obj);
    };
    i = 0;
    while i < ArraySize(membersList) {
      ArrayPush(membersListID, membersList[i].GetEntityID());
      i += 1;
    };
    return ArraySize(membersListID) > 0;
  }

  public final static func GetSquadMemberInterface(obj: wref<GameObject>, out squadInterface: ref<SquadScriptInterface>) -> Bool {
    if IsDefined(obj) && IsDefined(obj.GetSquadMemberComponent()) {
      squadInterface = obj.GetSquadMemberComponent().MySquad(AISquadType.Combat);
    };
    return squadInterface != null;
  }

  public final static func GetCombatSquadInterface(obj: wref<GameObject>, out squadInterface: ref<CombatSquadScriptInterface>) -> Bool {
    if IsDefined(obj) && IsDefined(obj.GetSquadMemberComponent()) {
      squadInterface = obj.GetSquadMemberComponent().MySquad(AISquadType.Combat) as CombatSquadScriptInterface;
    };
    return squadInterface != null;
  }

  public final static func GetSquadBaseInterface(obj: wref<GameObject>, out squadBaseInterface: ref<PuppetSquadInterface>) -> Bool {
    if IsDefined(obj) && IsDefined(obj.GetSquadMemberComponent()) {
      squadBaseInterface = obj.GetSquadMemberComponent().MySquad(AISquadType.Combat) as PuppetSquadInterface;
    };
    return squadBaseInterface != null;
  }

  public final static func GetPlayerSquadInterface(obj: wref<GameObject>, out playerSquadInterface: ref<PlayerSquadInterface>) -> Bool {
    if IsDefined(obj) && IsDefined(obj.GetSquadMemberComponent()) {
      playerSquadInterface = obj.GetSquadMemberComponent().MySquad(AISquadType.Combat) as PlayerSquadInterface;
    };
    return playerSquadInterface != null;
  }

  public final static func GetAllSquadMemberInterfaces(obj: wref<GameObject>) -> array<ref<SquadScriptInterface>> {
    return obj.GetSquadMemberComponent().MySquads();
  }

  public final static func LeaveSquad(obj: wref<GameObject>, squadType: AISquadType) -> Bool {
    if IsDefined(obj) && IsDefined(obj.GetSquadMemberComponent()) {
      obj.GetSquadMemberComponent().MySquad(squadType).Leave(obj);
      return true;
    };
    return false;
  }

  public final static func LeaveAllSquads(obj: wref<GameObject>) -> Bool {
    let i: Int32;
    let squads: array<ref<SquadScriptInterface>>;
    if IsDefined(obj) && IsDefined(obj.GetSquadMemberComponent()) {
      squads = obj.GetSquadMemberComponent().MySquads();
      i = 0;
      while i < ArraySize(squads) {
        squads[i].Leave(obj);
        i += 1;
      };
      return true;
    };
    return false;
  }

  public final static func PlayerSquadOrderStringToEnum(playerSquadOrderName: String) -> EAIPlayerSquadOrder {
    switch playerSquadOrderName {
      case "OrderTakedown":
        return EAIPlayerSquadOrder.Takedown;
      default:
        return EAIPlayerSquadOrder.Invalid;
    };
  }

  public final static func SendStimFromSquadTargetToMember(member: ref<Entity>, actionName: CName) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let i: Int32;
    let smi: ref<SquadScriptInterface>;
    let squadMember: ref<ScriptedPuppet>;
    let squadMembers: array<wref<Entity>>;
    let target: ref<GameObject>;
    let puppet: ref<ScriptedPuppet> = member as ScriptedPuppet;
    if !AISquadHelper.GetSquadmates(puppet, squadMembers) {
      return;
    };
    i = 0;
    while i < ArraySize(squadMembers) {
      squadMember = squadMembers[i] as ScriptedPuppet;
      target = squadMember.GetStimReactionComponent().GetActiveReactionData().stimTarget;
      if IsDefined(target) {
        AISquadHelper.GetSquadMemberInterface(squadMember, smi);
        broadcaster = squadMember.GetStimBroadcasterComponent();
        if smi.HasOrderBySquadAction(actionName, EntityGameInterface.GetEntity(squadMember.GetEntity())) && IsDefined(broadcaster) {
          broadcaster.SendDrirectStimuliToTarget(puppet, gamedataStimType.Combat, target);
        };
      };
      i += 1;
    };
  }

  public final static func GetCurrentSquadRing(puppet: wref<ScriptedPuppet>) -> gamedataAIRingType {
    let ring: gamedataAIRingType;
    if !IsDefined(puppet) {
      return gamedataAIRingType.Invalid;
    };
    ring = FromVariant(AICoverHelper.GetCoverBlackboard(puppet).GetVariant(GetAllBlackboardDefs().AICover.currentRing));
    if NotEquals(ring, gamedataAIRingType.Invalid) {
      return ring;
    };
    ring = FromVariant(AICoverHelper.GetCoverBlackboard(puppet).GetVariant(GetAllBlackboardDefs().AICover.lastCoverRing));
    return ring;
  }

  public final static func SquadRingTypeToTicketName(type: gamedataAIRingType) -> CName {
    switch type {
      case gamedataAIRingType.Melee:
        return n"MeleeRing";
      case gamedataAIRingType.Close:
        return n"CloseRing";
      case gamedataAIRingType.Medium:
        return n"MediumRing";
      case gamedataAIRingType.Far:
        return n"FarRing";
      case gamedataAIRingType.Extreme:
        return n"ExtremeRing";
      case gamedataAIRingType.Default:
        return n"DefaultRing";
      default:
        return n"DefaultRing";
    };
  }

  public final static func SquadRingTypeToTicketString(type: gamedataAIRingType) -> String {
    switch type {
      case gamedataAIRingType.Melee:
        return "MeleeRing";
      case gamedataAIRingType.Close:
        return "CloseRing";
      case gamedataAIRingType.Medium:
        return "MediumRing";
      case gamedataAIRingType.Far:
        return "FarRing";
      case gamedataAIRingType.Extreme:
        return "ExtremeRing";
      case gamedataAIRingType.Default:
        return "DefaultRing";
      default:
        return "DefaultRing";
    };
  }

  public final static func NotifySquadOnIncapacitated(puppet: wref<ScriptedPuppet>) -> Void {
    let i: Int32;
    let squadmate: wref<ScriptedPuppet>;
    let squadmates: array<wref<Entity>>;
    if AISquadHelper.GetSquadmates(puppet, squadmates, true) {
      i = 0;
      while i < ArraySize(squadmates) {
        squadmate = squadmates[i] as ScriptedPuppet;
        if IsDefined(squadmate) {
          ScriptedPuppet.SendActionSignal(squadmate, n"RecentIncapacitationInSquad", 15.00);
        };
        i += 1;
      };
    };
  }

  public final static func RemoveThreatFromSquad(puppet: wref<ScriptedPuppet>, threat: TrackedLocation) -> Void {
    let i: Int32;
    let squadmate: wref<ScriptedPuppet>;
    let squadmates: array<wref<Entity>>;
    if !IsDefined(puppet) {
      return;
    };
    if AISquadHelper.GetSquadmates(puppet, squadmates, true) {
      i = 0;
      while i < ArraySize(squadmates) {
        squadmate = squadmates[i] as ScriptedPuppet;
        if IsDefined(squadmate) {
          AISquadHelper.RemoveThreatOnSquadmate(puppet.GetGame(), squadmate, threat);
        };
        i += 1;
      };
    };
  }

  public final static func RemoveThreatOnSquadmate(game: GameInstance, squadmate: wref<ScriptedPuppet>, threat: TrackedLocation) -> Void {
    let tte: ref<TargetTrackingExtension>;
    if !IsDefined(squadmate) || !GameInstance.IsValid(game) {
      return;
    };
    tte = squadmate.GetTargetTrackerComponent() as TargetTrackingExtension;
    if IsDefined(tte) {
      tte.RemoveThreat(tte.MapThreat(threat.entity));
      tte.SetRecentlyDroppedThreat(game, threat.entity, threat.sharedLocation.position, 10.00);
    };
  }

  public final static func GetThreatLocationFromSquad(puppet: wref<ScriptedPuppet>, threat: wref<Entity>, out threatLocation: TrackedLocation) -> Bool {
    let i: Int32;
    let squadmate: wref<ScriptedPuppet>;
    let squadmates: array<wref<Entity>>;
    if !IsDefined(puppet) || !IsDefined(threat) {
      return false;
    };
    if AISquadHelper.GetSquadmates(puppet, squadmates) {
      i = 0;
      while i < ArraySize(squadmates) {
        squadmate = squadmates[i] as ScriptedPuppet;
        if IsDefined(squadmate) {
          if AISquadHelper.GeThreatLocationFromSquadmate(squadmate, threat, threatLocation) {
            return true;
          };
        };
        i += 1;
      };
    };
    return false;
  }

  public final static func GeThreatLocationFromSquadmate(squadmate: wref<ScriptedPuppet>, threat: wref<Entity>, out threatLocation: TrackedLocation) -> Bool {
    let allThreats: array<TrackedLocation>;
    let i: Int32;
    let tte: ref<TargetTrackingExtension>;
    if !IsDefined(squadmate) || !IsDefined(threat) {
      return false;
    };
    tte = squadmate.GetTargetTrackerComponent() as TargetTrackingExtension;
    if IsDefined(tte) {
      allThreats = tte.GetThreats(false);
      i = 0;
      while i < ArraySize(allThreats) {
        if allThreats[i].entity == threat {
          threatLocation = allThreats[i];
          return true;
        };
        i += 1;
      };
    };
    return false;
  }

  public final static func PullSquadSync(puppet: wref<ScriptedPuppet>, squadType: AISquadType) -> Void {
    let currentTopThreat: TrackedLocation;
    let i: Int32;
    let squadmate: wref<ScriptedPuppet>;
    let squadmates: array<wref<Entity>>;
    let targetTrackerComponent: ref<TargetTrackerComponent>;
    if !IsDefined(puppet) {
      return;
    };
    targetTrackerComponent = puppet.GetTargetTrackerComponent();
    if IsDefined(targetTrackerComponent) {
      targetTrackerComponent.GetTopHostileThreat(false, currentTopThreat);
    };
    if AISquadHelper.GetSquadmates(puppet, squadmates, true) {
      i = 0;
      while i < ArraySize(squadmates) {
        squadmate = squadmates[i] as ScriptedPuppet;
        if IsDefined(squadmate) {
          AISquadHelper.PullSquadSyncOnSquadmate(puppet.GetGame(), squadmate, squadType, currentTopThreat.entity);
        };
        i += 1;
      };
    };
  }

  public final static func PullSquadSyncOnSquadmate(game: GameInstance, squadmate: wref<ScriptedPuppet>, squadType: AISquadType, currentTopThreat: wref<Entity>) -> Void {
    let threatData: DroppedThreatData;
    let tte: ref<TargetTrackingExtension>;
    if !IsDefined(squadmate) || !GameInstance.IsValid(game) {
      return;
    };
    tte = squadmate.GetTargetTrackerComponent() as TargetTrackingExtension;
    if IsDefined(tte) {
      if tte.GetDroppedThreat(game, threatData) {
        if threatData.threat == currentTopThreat {
          return;
        };
      };
      tte.PullSquadSync(squadType);
    };
  }

  public final static func IsSignalActive(owner: wref<ScriptedPuppet>, signalName: CName) -> Bool {
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    if !IsNameValid(signalName) {
      return false;
    };
    signalTable = owner.GetSignalTable();
    if !IsDefined(signalTable) {
      return false;
    };
    signalId = signalTable.GetOrCreateSignal(signalName);
    if !signalTable.GetCurrentValue(signalId) {
      return false;
    };
    return true;
  }

  public final static func EnterAlerted(owner: wref<ScriptedPuppet>) -> Void {
    let i: Int32;
    let membersList: array<wref<Entity>>;
    let puppet: wref<ScriptedPuppet>;
    if owner.IsCharacterCivilian() || owner.IsCrowd() {
      return;
    };
    if !AISquadHelper.GetSquadmates(owner, membersList) {
      return;
    };
    i = 0;
    while i < ArraySize(membersList) {
      puppet = membersList[i] as ScriptedPuppet;
      if !IsDefined(puppet) {
      } else {
        if puppet.IsCharacterCivilian() || puppet.IsCrowd() {
          return;
        };
        if Equals(puppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Relaxed) {
          NPCPuppet.ChangeHighLevelState(puppet, gamedataNPCHighLevelState.Alerted);
        };
      };
      i += 1;
    };
  }
}

public abstract class AIScriptSquad extends IScriptable {

  public final static func GetBaseSquadRecord(out squadRecord: wref<AISquadParams_Record>) -> Bool {
    let tweakID: TweakDBID;
    if !IsDefined(squadRecord) {
      tweakID = TDBID.Create(TDB.GetString(t"AIGeneralSettings.baseSquadParamsID"));
      squadRecord = TweakDBInterface.GetAISquadParamsRecord(tweakID);
    };
    return squadRecord != null;
  }

  public final static func GetSquadRecord(entity: wref<Entity>, out squadRecord: wref<AISquadParams_Record>) -> Bool {
    let chr: wref<Character_Record>;
    let puppet: wref<ScriptedPuppet> = entity as ScriptedPuppet;
    if IsDefined(puppet) {
      chr = TweakDBInterface.GetCharacterRecord(puppet.GetRecordID());
      if IsDefined(chr) {
        squadRecord = chr.SquadParamsID();
      };
    };
    return squadRecord != null;
  }

  public final static func GetTicketRecord(ticketName: CName, squadRecord: wref<AISquadParams_Record>, out ticketRecord: wref<AITicket_Record>) -> Bool {
    let ticket: ref<AITicket_Record>;
    let count: Int32 = squadRecord.GetOverridenTicketsCount();
    let i: Int32 = 0;
    while i < count {
      ticket = squadRecord.GetOverridenTicketsItem(i);
      if Equals(ticketName, ticket.TicketType().EnumName()) {
        ticketRecord = ticket;
        return true;
      };
      i += 1;
    };
    count = squadRecord.GetAllTicketsCount();
    i = 0;
    while i < count {
      ticket = squadRecord.GetAllTicketsItem(i);
      if Equals(ticketName, ticket.TicketType().EnumName()) {
        ticketRecord = ticket;
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func TicketDebugHelper(ticketNameCheck: String, entity: wref<Entity>, ticketRecord: wref<AITicket_Record>) -> Bool {
    let ticketName: String;
    if IsFinal() {
      return false;
    };
    if IsDefined(entity) || IsStringValid(ticketNameCheck) {
      if IsStringValid(ticketNameCheck) {
        ticketName = NameToString(ticketRecord.TicketType().EnumName());
        if StrContains(ticketName, ticketNameCheck) {
          if IsDefined(entity as GameObject) {
            if (entity as GameObject).IsSelectedForDebugging() {
              return true;
            };
            return false;
          };
          return true;
        };
        return false;
      };
      if IsDefined(entity as GameObject) {
        if (entity as GameObject).IsSelectedForDebugging() {
          return true;
        };
        return false;
      };
    };
    return false;
  }

  public final static func CanPerformTicket(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Bool {
    if AIScriptSquad.HasOrder(context, actionType.EnumName()) {
      return true;
    };
    return false;
  }

  public final static func OpenTicket(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.OpenSquadAction);
  }

  public final static func CommitToTicket(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.CommitToSquadAction);
  }

  public final static func CompleteTicket(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.ReportDoneOnSquadAction);
  }

  public final static func FailTicket(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.ReportFailureOnSquadAction);
  }

  public final static func CloseTicket(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.RevokeSquadAction);
  }

  public final static func RevokeTicket(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.RevokeOrder);
  }

  public final static func EvaluateTicketActivation(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.EvaluateTicketActivation);
  }

  public final static func EvaluateTicketDeactivation(const context: ScriptExecutionContext, actionType: wref<AITicketType_Record>) -> Void {
    AIScriptSquad.SignalSquad(context, actionType.EnumName(), EAISquadVerb.EvaluateTicketDeactivation);
  }

  public final static func HasOrder(const context: ScriptExecutionContext, ticketName: CName) -> Bool {
    let smi: ref<SquadScriptInterface>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !AISquadHelper.GetSquadMemberInterface(puppet, smi) {
      return true;
    };
    if smi.HasOrderBySquadAction(ticketName, puppet) {
      return true;
    };
    return false;
  }

  public final static func HasOrder(puppet: wref<ScriptedPuppet>, ticketName: CName) -> Bool {
    let smi: ref<SquadScriptInterface>;
    if !AISquadHelper.GetSquadMemberInterface(puppet, smi) {
      return true;
    };
    if smi.HasOrderBySquadAction(ticketName, puppet) {
      return true;
    };
    return false;
  }

  public final static func SignalSquad(const context: ScriptExecutionContext, actionName: CName, verb: EAISquadVerb) -> Void {
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if IsDefined(puppet) {
      puppet.HandleSquadAction(actionName, verb);
    };
  }

  public final static func CheckTickets(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Bool {
    let count: Int32;
    let i: Int32;
    let smi: ref<SquadScriptInterface>;
    let scriptedOwner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !AISquadHelper.GetSquadMemberInterface(scriptedOwner, smi) {
      return true;
    };
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      if !smi.HasOrderBySquadAction(actionRecord.GetTicketsItem(i).EnumName(), scriptedOwner) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CloseTickets(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let squadMemberComp: ref<SquadMemberBaseComponent>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadMemberComp = puppet.GetSquadMemberComponent();
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      squadMemberComp.PerformSquadVerb(actionRecord.GetTicketsItem(i).EnumName(), EAISquadVerb.RevokeSquadAction);
      i += 1;
    };
  }

  public final static func RevokeTickets(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let squadMemberComp: ref<SquadMemberBaseComponent>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadMemberComp = puppet.GetSquadMemberComponent();
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      squadMemberComp.PerformSquadVerb(actionRecord.GetTicketsItem(i).EnumName(), EAISquadVerb.RevokeOrder);
      i += 1;
    };
  }

  public final static func RequestTickets(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let squadMemberComp: ref<SquadMemberBaseComponent>;
    let ticketName: CName;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadMemberComp = puppet.GetSquadMemberComponent();
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      ticketName = actionRecord.GetTicketsItem(i).EnumName();
      squadMemberComp.PerformSquadVerb(ticketName, EAISquadVerb.OpenSquadAction);
      squadMemberComp.PerformSquadVerb(ticketName, EAISquadVerb.EvaluateTicketActivation);
      i += 1;
    };
  }

  public final static func EvaluateTicketsActivation(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let squadMemberComp: ref<SquadMemberBaseComponent>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadMemberComp = puppet.GetSquadMemberComponent();
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      squadMemberComp.PerformSquadVerb(actionRecord.GetTicketsItem(i).EnumName(), EAISquadVerb.EvaluateTicketActivation);
      i += 1;
    };
  }

  public final static func EvaluateTicketsDeactivation(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let squadMemberComp: ref<SquadMemberBaseComponent>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadMemberComp = puppet.GetSquadMemberComponent();
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      squadMemberComp.PerformSquadVerb(actionRecord.GetTicketsItem(i).EnumName(), EAISquadVerb.EvaluateTicketDeactivation);
      i += 1;
    };
  }

  public final static func CommitToTickets(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let squadMemberComp: ref<SquadMemberBaseComponent>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadMemberComp = puppet.GetSquadMemberComponent();
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      squadMemberComp.PerformSquadVerb(actionRecord.GetTicketsItem(i).EnumName(), EAISquadVerb.CommitToSquadAction);
      i += 1;
    };
  }

  public final static func CompleteTickets(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>, succeed: Bool) -> Void {
    let count: Int32;
    let i: Int32;
    let squadMemberComp: ref<SquadMemberBaseComponent>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadMemberComp = puppet.GetSquadMemberComponent();
    count = actionRecord.GetTicketsCount();
    i = 0;
    while i < count {
      if succeed {
        squadMemberComp.PerformSquadVerb(actionRecord.GetTicketsItem(i).EnumName(), EAISquadVerb.ReportDoneOnSquadAction);
      } else {
        squadMemberComp.PerformSquadVerb(actionRecord.GetTicketsItem(i).EnumName(), EAISquadVerb.ReportFailureOnSquadAction);
      };
      i += 1;
    };
  }

  public final static func WaitForTicketsAcknowledgement(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Bool {
    let i: Int32;
    let puppet: ref<ScriptedPuppet>;
    let smi: ref<SquadScriptInterface>;
    let ticketName: CName;
    let count: Int32 = actionRecord.GetTicketsCount();
    if count > 0 {
      puppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
      if !AISquadHelper.GetSquadMemberInterface(puppet, smi) {
        return true;
      };
      i = 0;
      while i < count {
        ticketName = actionRecord.GetTicketsItem(i).EnumName();
        if !smi.HasOrderBySquadAction(ticketName, puppet) {
        } else {
          if !smi.HasAcknowledgedOrderBySquadAction(ticketName, puppet) {
            return true;
          };
        };
        i += 1;
      };
    };
    return false;
  }
}
