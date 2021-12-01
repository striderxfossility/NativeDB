
public class SquadMemberBaseComponent extends SquadMemberComponent {

  private let m_baseSquadRecord: wref<AISquadParams_Record>;

  private final func GetBaseSquadRecord() -> wref<AISquadParams_Record> {
    if !IsDefined(this.m_baseSquadRecord) {
      AIScriptSquad.GetBaseSquadRecord(this.m_baseSquadRecord);
    };
    return this.m_baseSquadRecord;
  }

  public final func OnSquadActionSignalReceived(signal: ref<SquadActionSignal>) -> Void {
    this.PerformSquadVerb(signal.squadActionName, signal.squadVerb);
  }

  protected cb func OnSquadActionEvent(evt: ref<SquadActionEvent>) -> Bool {
    this.PerformSquadVerb(evt.squadActionName, evt.squadVerb);
  }

  public final func PerformSquadVerb(squadActionName: CName, squadVerb: EAISquadVerb) -> Void {
    let squadInterface: wref<SquadScriptInterface>;
    let ticketRecord: ref<AITicket_Record>;
    let ticketTimeout: Float;
    if !this.GetSquadInterface(squadInterface) {
      return;
    };
    switch squadVerb {
      case EAISquadVerb.OpenSquadAction:
        ticketTimeout = -1.00;
        if this.GetTicketType(squadActionName, this.GetEntity(), squadInterface, ticketRecord) {
          ticketTimeout = ticketRecord.Timeout();
        };
        squadInterface.OpenSquadAction(squadActionName, this.GetEntity(), ticketTimeout);
        break;
      case EAISquadVerb.RevokeSquadAction:
        squadInterface.RevokeSquadAction(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.RevokeOrder:
        squadInterface.RevokeOrder(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.EvaluateTicketActivation:
        squadInterface.TriggerActivation(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.EvaluateTicketDeactivation:
        squadInterface.TriggerDeactivation(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.CommitToSquadAction:
        squadInterface.Commit(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.AcknowledgeOrder:
        squadInterface.AckOrder(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.ReportDoneOnSquadAction:
        squadInterface.ReportDone(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.ReportFailureOnSquadAction:
        squadInterface.ReportFail(squadActionName, this.GetEntity());
        break;
      case EAISquadVerb.JoinSquad:
        squadInterface.Join(this.GetEntity());
        break;
      case EAISquadVerb.LeaveSquad:
        squadInterface.Leave(this.GetEntity());
    };
  }

  private final func GetSquadInterface(out interface: wref<SquadScriptInterface>) -> Bool {
    interface = this.MySquad(AISquadType.Combat);
    return interface != null;
  }

  private final func GetTicketType(actionName: CName, entity: ref<Entity>, squadInterface: wref<SquadScriptInterface>, out ticketRecord: ref<AITicket_Record>) -> Bool {
    let squadRecord: ref<AISquadParams_Record>;
    return AIScriptUtils.GetTicketType(actionName, entity as gamePuppet, this.GetBaseSquadRecord(), ticketRecord, squadRecord);
  }

  private final func GetSquadRecord(entity: wref<Entity>, squadInterface: wref<SquadScriptInterface>, out squadRecord: wref<AISquadParams_Record>) -> Bool {
    if !IsDefined(entity) || !AIScriptSquad.GetSquadRecord(entity, squadRecord) {
      LogAIError("No squadParams record found with for squad template: " + NameToString(squadInterface.GetTemplate()));
      return false;
    };
    return true;
  }
}

public class PuppetSquadInterface extends CombatSquadScriptInterface {

  private let m_baseSquadRecord: wref<AISquadParams_Record>;

  private let m_ticketHistory: array<SquadTicketReceipt>;

  private let m_enumValueToNdx: EnumNameToIndexCache;

  private let m_sectorsInitialized: Bool;

  protected cb func OnInitialise() -> Bool {
    AIScriptSquad.GetBaseSquadRecord(this.m_baseSquadRecord);
    this.AllocateTicketHistoryArray();
  }

  protected cb func OnOpenSquadAction(actionName: CName, entity: ref<Entity>) -> Bool {
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID) {
      return false;
    };
    this.RefreshSquadAction(actionName, entity, ticketRecord.Timeout());
  }

  protected cb func OnAckOrder(orderId: Uint32, actionName: CName, entity: ref<Entity>) -> Bool {
    let ticketHistoryID: Int32 = this.GetTicketHistoryID(actionName);
    this.m_ticketHistory[ticketHistoryID].acknowledgedTimeStamp = this.GetAITime(entity);
    this.m_ticketHistory[ticketHistoryID].acknowledgesInQueue -= 1;
  }

  protected cb func OnGiveOrder(orderId: Uint32, actionName: CName, entity: ref<Entity>) -> Bool;

  protected cb func OnCommitToOrder(actionName: CName, orderId: Uint32, entity: ref<Entity>) -> Bool {
    let acknowledgeDelay: Float;
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID) {
      return false;
    };
    this.GetAcknowledgeDelay(entity, ticketRecord, ticketHistoryID, acknowledgeDelay);
    this.AcknowledgeTicket(actionName, entity, ticketRecord, ticketHistoryID, acknowledgeDelay);
  }

  protected cb func OnCloseSquadAction(actionName: CName, entity: ref<Entity>) -> Bool;

  protected cb func OnOrderRevoked(orderId: Uint32, actionName: CName, entity: ref<Entity>) -> Bool {
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID) {
      return false;
    };
    if ticketRecord.ReleaseAll() {
      this.ReleaseSquadMembersTickets(actionName, entity);
    };
    this.UpdateTicketHistory(entity, ticketRecord, ticketHistoryID, EAITicketStatus.OrderRevoked);
  }

  protected cb func OnOrderDone(orderId: Uint32, actionName: CName, entity: ref<Entity>) -> Bool {
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID) {
      return false;
    };
    if ticketRecord.ReleaseAll() {
      this.ReleaseSquadMembersTickets(actionName, entity);
    };
    this.UpdateTicketHistory(entity, ticketRecord, ticketHistoryID, EAITicketStatus.OrderDone);
  }

  protected cb func OnOrderFail(orderId: Uint32, actionName: CName, entity: ref<Entity>) -> Bool {
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID) {
      return false;
    };
    if ticketRecord.ReleaseAll() {
      AISquadHelper.SendStimFromSquadTargetToMember(entity, actionName);
    };
    this.UpdateTicketHistory(entity, ticketRecord, ticketHistoryID, EAITicketStatus.OrderFail);
  }

  protected cb func OnEvaluationActivation(actionName: CName, entity: ref<Entity>) -> Bool {
    let squadRecord: ref<AISquadParams_Record>;
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID, squadRecord) {
      return false;
    };
    if this.EvaluateTicketActivation(actionName, entity, ticketRecord, ticketHistoryID, squadRecord) {
      this.GiveOrder(actionName, entity);
      this.UpdateTicketHistory(entity, ticketRecord, ticketHistoryID, EAITicketStatus.Evaluate);
    } else {
      this.RefreshSquadAction(actionName, entity, ticketRecord.Timeout());
    };
  }

  protected cb func OnEvaluationDeActivation(actionName: CName, entity: ref<Entity>) -> Bool {
    let squadRecord: ref<AISquadParams_Record>;
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID, squadRecord) {
      return false;
    };
    if this.EvaluateTicketDeactivation(actionName, entity, ticketRecord, ticketHistoryID, squadRecord) {
      this.ReportDone(actionName, entity);
    };
  }

  private final func EvaluateTicketActivation(actionName: CName, entity: wref<Entity>, ticketRecord: wref<AITicket_Record>, ticketHistoryID: Int32, squadRecord: wref<AISquadParams_Record>) -> Bool {
    let acknowledgeDelay: Float;
    let ticketConditions: array<wref<AITicketCondition_Record>>;
    if this.HasOrderBySquadAction(actionName, entity) {
      return false;
    };
    if !this.CheckCooldown(entity, ticketRecord, ticketHistoryID) {
      return false;
    };
    if !this.GetAcknowledgeDelay(entity, ticketRecord, ticketHistoryID, acknowledgeDelay) {
      return false;
    };
    ticketRecord.ActivationCondition(ticketConditions);
    if !AITicketCondition.PerformChecking(entity, this, ticketConditions, ticketRecord, squadRecord) {
      return false;
    };
    this.RandomizeDeactivationConditionCheckInterval(ticketRecord, ticketHistoryID);
    return true;
  }

  private final func RandomizeDeactivationConditionCheckInterval(ticketRecord: wref<AITicket_Record>, ticketHistoryID: Int32) -> Void {
    let randomCheckIntervalMods: array<Float>;
    this.m_ticketHistory[ticketHistoryID].conditionCheckRandomizedInterval = 0.00;
    if ticketRecord.GetDeactivationConditionCount() > 0 && ticketRecord.DeactivationConditionCheckInterval() > 0.00 {
      ArrayResize(randomCheckIntervalMods, 3);
      randomCheckIntervalMods[0] = 0.00;
      randomCheckIntervalMods[1] = 0.03;
      randomCheckIntervalMods[2] = 0.07;
      this.m_ticketHistory[ticketHistoryID].conditionCheckRandomizedInterval = ticketRecord.DeactivationConditionCheckInterval();
      this.m_ticketHistory[ticketHistoryID].conditionCheckRandomizedInterval += randomCheckIntervalMods[RandRange(0, 3)];
    };
  }

  private final func EvaluateTicketDeactivation(actionName: CName, entity: wref<Entity>, ticketRecord: wref<AITicket_Record>, ticketHistoryID: Int32, squadRecord: wref<AISquadParams_Record>) -> Bool {
    let conditionSuccessDuration: Float;
    let ticketConditions: array<wref<AITicketCondition_Record>>;
    if ticketRecord.GetDeactivationConditionCount() == 0 {
      return false;
    };
    if this.m_ticketHistory[ticketHistoryID].conditionCheckRandomizedInterval <= 0.00 || this.m_ticketHistory[ticketHistoryID].conditionCheckRandomizedInterval > 0.00 && this.GetAITime(entity) >= this.m_ticketHistory[ticketHistoryID].conditionDeactivationCheckTimeStamp + this.m_ticketHistory[ticketHistoryID].conditionCheckRandomizedInterval {
      if this.HasOrderBySquadAction(actionName, entity) {
        ticketRecord.DeactivationCondition(ticketConditions);
        if AITicketCondition.PerformChecking(entity, this, ticketConditions, ticketRecord) {
          conditionSuccessDuration = ticketRecord.ConditionSuccessDuration();
          if conditionSuccessDuration > 0.00 && this.m_ticketHistory[ticketHistoryID].conditionDeactivationSuccessfulCheckTimeStamp < 0.00 {
            this.m_ticketHistory[ticketHistoryID].conditionDeactivationSuccessfulCheckTimeStamp = this.GetAITime(entity);
          };
          if conditionSuccessDuration <= 0.00 || conditionSuccessDuration > 0.00 && this.GetAITime(entity) >= this.m_ticketHistory[ticketHistoryID].conditionDeactivationSuccessfulCheckTimeStamp + conditionSuccessDuration {
            return true;
          };
        } else {
          this.m_ticketHistory[ticketHistoryID].conditionDeactivationSuccessfulCheckTimeStamp = -1.00;
        };
      };
      this.m_ticketHistory[ticketHistoryID].conditionDeactivationCheckTimeStamp = this.GetAITime(entity);
    };
    return false;
  }

  private final func ReleaseSquadMembersTickets(actionName: CName, entity: wref<Entity>) -> Void {
    let i: Int32;
    let squadMembers: array<wref<Entity>> = this.ListMembersWeak();
    ArrayRemove(squadMembers, entity);
    i = 0;
    while i < ArraySize(squadMembers) {
      if this.HasOrderBySquadAction(actionName, squadMembers[i]) {
        this.ReportDone(actionName, squadMembers[i]);
      };
      i += 1;
    };
  }

  private final func GetAcknowledgeDelay(entity: wref<Entity>, ticketRecord: wref<AITicket_Record>, ticketHistoryID: Int32, out acknowledgeDelay: Float) -> Bool {
    let ticketHistory: SquadTicketReceipt = this.m_ticketHistory[ticketHistoryID];
    if ticketHistory.numberOfOrders == 0 {
      return true;
    };
    if ticketRecord.MinTicketDesyncTime() > 0.00 {
      if this.GetAITime(entity) > ticketRecord.MinTicketDesyncTime() + ticketHistory.acknowledgedTimeStamp {
        return true;
      };
      acknowledgeDelay = ticketRecord.MinTicketDesyncTime() + ticketHistory.acknowledgedTimeStamp - this.GetAITime(entity);
      acknowledgeDelay *= Cast(ticketHistory.acknowledgesInQueue) + 1.00;
      return false;
    };
    return true;
  }

  private final func AcknowledgeTicket(actionName: CName, entity: wref<Entity>, ticketRecord: wref<AITicket_Record>, ticketHistoryID: Int32, delay: Float) -> Bool {
    let evt: ref<SquadActionEvent>;
    let object: wref<GameObject>;
    if delay > 0.00 {
      object = entity as GameObject;
      if !IsDefined(object) {
        return false;
      };
      evt = new SquadActionEvent();
      evt.squadActionName = actionName;
      evt.squadVerb = EAISquadVerb.AcknowledgeOrder;
      this.m_ticketHistory[ticketHistoryID].acknowledgesInQueue += 1;
      GameInstance.GetDelaySystem(object.GetGame()).DelayEvent(object, evt, delay);
      return true;
    };
    if this.AckOrder(actionName, entity) {
      this.ProcessRingTicket(entity, ticketRecord);
      this.m_ticketHistory[ticketHistoryID].acknowledgesInQueue += 1;
      return true;
    };
    return false;
  }

  private final func ProcessRingTicket(entity: wref<Entity>, ticketRecord: wref<AITicket_Record>) -> Void {
    let ringTicket: wref<AIRingTicket_Record>;
    let puppet: wref<ScriptedPuppet> = entity as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    ringTicket = ticketRecord as AIRingTicket_Record;
    if IsDefined(ringTicket) {
      AICoverHelper.GetCoverBlackboard(puppet).SetVariant(GetAllBlackboardDefs().AICover.currentRing, ToVariant(ringTicket.RingType().Type()));
    };
  }

  private final func GetTicketType(actionName: CName, entity: ref<Entity>, out ticketRecord: ref<AITicket_Record>, out ticketHistoryID: Int32, out squadRecord: ref<AISquadParams_Record>) -> Bool {
    if !AIScriptUtils.GetTicketType(actionName, entity as gamePuppet, this.m_baseSquadRecord, ticketRecord, squadRecord) {
      return false;
    };
    ticketHistoryID = this.GetTicketHistoryID(actionName);
    return true;
  }

  private final func GetTicketType(actionName: CName, entity: ref<Entity>, out ticketRecord: ref<AITicket_Record>, out ticketHistoryID: Int32) -> Bool {
    let squadRecord: ref<AISquadParams_Record>;
    return this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID, squadRecord);
  }

  private final func GetTicketHistoryID(actionName: CName) -> Int32 {
    let i: Int32;
    if EnumNameToIndexCache.GetIndex(this.m_enumValueToNdx, actionName, i) {
      return i;
    };
    return -1;
  }

  private final func GetSquadRecord(entity: wref<Entity>, out squadRecord: wref<AISquadParams_Record>) -> Bool {
    if !IsDefined(entity) || !AIScriptSquad.GetSquadRecord(entity, squadRecord) {
      LogAIError("No squadParams record found with for squad template: " + NameToString(this.GetTemplate()));
      return false;
    };
    return true;
  }

  private final func GetAITime(entity: wref<Entity>) -> Float {
    return EngineTime.ToFloat(GameInstance.GetSimTime((entity as GameObject).GetGame()));
  }

  private final func CheckCooldown(entity: wref<Entity>, ticketRecord: wref<AITicket_Record>, ticketHistoryID: Int32) -> Bool {
    let conditionsCount: Int32;
    let i: Int32;
    let j: Int32;
    let record: wref<AIActionCooldown_Record>;
    let cooldownsCount: Int32 = ticketRecord.GetCooldownsCount();
    if cooldownsCount == 0 {
      return true;
    };
    i = 0;
    while i < cooldownsCount {
      record = ticketRecord.GetCooldownsItem(i);
      conditionsCount = record.GetActivationConditionCount();
      if this.m_ticketHistory[ticketHistoryID].numberOfOrders > 0 {
        if conditionsCount > 0 {
          j = 0;
          while j < conditionsCount {
            if AICondition.CheckActionCondition(entity as ScriptedPuppet, record.GetActivationConditionItem(j)) {
              return false;
            };
            j += 1;
          };
        } else {
          return false;
        };
      };
      if IsDefined(record) && GameObject.IsCooldownActive(entity as GameObject, record.Name(), this.m_ticketHistory[ticketHistoryID].cooldownID) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  private final func UpdateTicketHistory(entity: wref<Entity>, ticketRecord: wref<AITicket_Record>, ticketHistoryID: Int32, ticketStatus: EAITicketStatus) -> Void {
    let count: Int32;
    let i: Int32;
    let record: wref<AIActionCooldown_Record>;
    if Equals(ticketStatus, EAITicketStatus.Evaluate) {
      this.m_ticketHistory[ticketHistoryID].lastRecipient = entity.GetEntityID();
      this.m_ticketHistory[ticketHistoryID].numberOfOrders += 1;
    } else {
      if IsDefined(entity as GameObject) && Equals(ticketStatus, EAITicketStatus.OrderDone) || ticketRecord.StartCooldownOnFailure() && Equals(ticketStatus, EAITicketStatus.OrderFail) {
        count = ticketRecord.GetCooldownsCount();
        i = 0;
        while i < count {
          record = ticketRecord.GetCooldownsItem(i);
          if IsDefined(record) {
            this.m_ticketHistory[ticketHistoryID].cooldownID = AIActionHelper.StartCooldown(entity as GameObject, record);
          };
          i += 1;
        };
      };
      this.m_ticketHistory[ticketHistoryID].numberOfOrders -= 1;
    };
  }

  private final func AllocateTicketHistoryArray() -> Void {
    let ticketEnumSize: Int32;
    if ArraySize(this.m_ticketHistory) == 0 {
      ticketEnumSize = EnumInt(gamedataAITicketType.Count);
      ArrayResize(this.m_ticketHistory, ticketEnumSize);
      EnumNameToIndexCache.Rebuild(this.m_enumValueToNdx, n"gamedataAITicketType");
    };
  }

  private final func AllocateTacticsSectors() -> Void {
    let alley: ref<CombatAlley>;
    let i: Int32;
    let j: Int32;
    let sectorEnumValue: Int32;
    let sectors: array<AICombatSectorType>;
    let sectorsRecord: array<wref<AISectorType_Record>>;
    let tacticRecord: wref<AITacticTicket_Record>;
    let ticketEnumSize: Int32;
    let ticketRecord: wref<AITicket_Record>;
    if !IsDefined(this.m_baseSquadRecord) || this.m_sectorsInitialized {
      return;
    };
    ticketEnumSize = EnumInt(gamedataAITicketType.Count);
    i = 0;
    while i < ticketEnumSize {
      AIScriptSquad.GetTicketRecord(EnumValueToName(n"gamedataAITicketType", Cast(i)), this.m_baseSquadRecord, ticketRecord);
      tacticRecord = ticketRecord as AITacticTicket_Record;
      if IsDefined(tacticRecord) {
        if tacticRecord.OffensiveTactic() {
          alley = this.GetOffensiveCombatAlley();
        } else {
          alley = this.GetDefensiveCombatAlley();
        };
        ArrayClear(sectorsRecord);
        tacticRecord.Sectors(sectorsRecord);
        if ArraySize(sectorsRecord) == 0 {
        } else {
          j = 0;
          while j < ArraySize(sectorsRecord) {
            sectorEnumValue = Cast(EnumValueFromName(n"AICombatSectorType", sectorsRecord[j].EnumName()));
            ArrayPush(sectors, IntEnum(sectorEnumValue));
            j += 1;
          };
          this.RegisterTactic(EnumValueToName(n"gamedataAITicketType", Cast(i)), sectors, alley, tacticRecord.TacticTimeout());
        };
      };
      i += 1;
    };
    this.m_sectorsInitialized = true;
  }

  public final func CheckTicketConditions(actionName: CName, entity: wref<Entity>) -> Bool {
    let squadRecord: ref<AISquadParams_Record>;
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if this.HasOrderBySquadAction(actionName, entity) {
      return true;
    };
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID, squadRecord) {
      return false;
    };
    return this.EvaluateTicketActivation(actionName, entity, ticketRecord, ticketHistoryID, squadRecord);
  }

  public final func SimpleTicketConditionsCheck(actionName: CName, entity: wref<Entity>) -> Bool {
    let ticketConditions: array<wref<AITicketCondition_Record>>;
    let ticketHistoryID: Int32;
    let ticketRecord: ref<AITicket_Record>;
    if !this.GetTicketType(actionName, entity, ticketRecord, ticketHistoryID) {
      return false;
    };
    ticketRecord.ActivationCondition(ticketConditions);
    return AITicketCondition.PerformChecking(entity, this, ticketConditions, ticketRecord);
  }

  public final func GetLastTicketRecipient(actionName: CName) -> EntityID {
    let i: Int32;
    let invalidEntityId: EntityID;
    if EnumNameToIndexCache.GetIndex(this.m_enumValueToNdx, actionName, i) {
      return this.m_ticketHistory[i].lastRecipient;
    };
    return invalidEntityId;
  }
}

public class PlayerSquadInterface extends PuppetSquadInterface {

  public final func BroadcastCommand(command: ref<AICommand>) -> Void {
    let members: array<wref<Entity>> = this.ListMembersWeak();
    let i: Int32 = 0;
    while i < ArraySize(members) {
      this.GiveCommandToSquadMember(members[i], command.Copy());
      i += 1;
    };
  }

  private final func GiveCommandToSquadMember(member: wref<Entity>, command: ref<AICommand>) -> Void {
    let aiComponent: ref<AIComponent>;
    let executeCommandEvent: ref<StimuliEvent>;
    let puppet: ref<ScriptedPuppet> = member as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    aiComponent = puppet.GetAIControllerComponent();
    aiComponent.SendCommand(command);
    executeCommandEvent = new StimuliEvent();
    executeCommandEvent.name = n"FollowerExecuteCommand";
    puppet.QueueEvent(executeCommandEvent);
  }
}
