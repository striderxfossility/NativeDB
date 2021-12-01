
public class SecurityAgentSpawnedEvent extends Event {

  public let spawnedAgent: DeviceLink;

  public let eventType: gameEntitySpawnerEventType;

  public let securityAreas: array<ref<SecurityAreaControllerPS>>;

  public final static func Construct(agentLink: DeviceLink, type: gameEntitySpawnerEventType, areas: array<ref<SecurityAreaControllerPS>>) -> ref<SecurityAgentSpawnedEvent> {
    let spawnEvent: ref<SecurityAgentSpawnedEvent> = new SecurityAgentSpawnedEvent();
    spawnEvent.spawnedAgent = agentLink;
    spawnEvent.eventType = type;
    spawnEvent.securityAreas = areas;
    return spawnEvent;
  }
}

public class AgentRegistry extends IScriptable {

  @attrib(unsavable, "true")
  protected persistent let m_isInitialized: Bool;

  @attrib(unsavable, "true")
  protected persistent let m_agents: array<Agent>;

  public let m_agentsLock: RWLock;

  @default(AgentRegistry, 2)
  public let m_maxReprimandsPerNPC: Int32;

  @default(AgentRegistry, 1)
  public let m_maxReprimandsPerDEVICE: Int32;

  public final static func Construct() -> ref<AgentRegistry> {
    let registry: ref<AgentRegistry> = new AgentRegistry();
    registry.m_isInitialized = true;
    return registry;
  }

  private final const func IsInitialized() -> Bool {
    return this.m_isInitialized;
  }

  public final const func IsReady() -> Bool {
    let i: Int32;
    if !this.IsInitialized() {
      return false;
    };
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      if !Agent.IsValid(this.m_agents[i]) {
        RWLock.ReleaseShared(this.m_agentsLock);
        return false;
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return true;
  }

  public final func RegisterAgent(agentPS: DeviceLink, areas: array<ref<SecurityAreaControllerPS>>) -> Void {
    let agent: Agent;
    let index: Int32;
    RWLock.Acquire(this.m_agentsLock);
    if !this.GetAgentIndex_NoLock(DeviceLink.GetLinkID(agentPS), index) {
      agent = Agent.Construct(agentPS, areas);
      this.SaveAgent_NoLock(agent);
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final func UnregisterAgent(agentID: PersistentID) -> Void {
    let index: Int32;
    RWLock.Acquire(this.m_agentsLock);
    if this.GetAgentIndex_NoLock(agentID, index) {
      ArrayErase(this.m_agents, index);
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final const func IsAgent(id: PersistentID) -> Bool {
    let ix: Int32;
    return this.GetAgentIndex(id, ix);
  }

  public final const func GetAgent(id: PersistentID, out recordCopy: Agent) -> Bool {
    let index: Int32;
    let found: Bool = false;
    RWLock.AcquireShared(this.m_agentsLock);
    if this.GetAgentIndex_NoLock(id, index) {
      recordCopy = this.m_agents[index];
      found = true;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return found;
  }

  public final const func GetAgentsIDs() -> array<PersistentID> {
    let i: Int32;
    let ids: array<PersistentID>;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      ArrayPush(ids, DeviceLink.GetLinkID(this.m_agents[i].link));
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return ids;
  }

  public final const func GetAgents() -> array<Agent> {
    let data: array<Agent>;
    let i: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      ArrayPush(data, this.m_agents[i]);
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return data;
  }

  public final const func GetAgents(filter: array<ref<SecurityAreaControllerPS>>) -> array<Agent> {
    let agents: array<Agent>;
    let i: Int32;
    let k: Int32;
    let y: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      k = 0;
      while k < ArraySize(this.m_agents[i].areas) {
        y = 0;
        while y < ArraySize(filter) {
          if Equals(DeviceLink.GetLinkID(this.m_agents[i].areas[k]), filter[y].GetID()) {
            ArrayPush(agents, this.m_agents[i]);
          };
          y += 1;
        };
        k += 1;
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return agents;
  }

  public final const func GetAgentsIDs(filter: array<ref<SecurityAreaControllerPS>>) -> array<PersistentID> {
    let agentIDs: array<PersistentID>;
    let i: Int32;
    let k: Int32;
    let y: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      k = 0;
      while k < ArraySize(this.m_agents[i].areas) {
        y = 0;
        while y < ArraySize(filter) {
          if Equals(DeviceLink.GetLinkID(this.m_agents[i].areas[k]), filter[y].GetID()) {
            ArrayPush(agentIDs, DeviceLink.GetLinkID(this.m_agents[i].link));
          };
          y += 1;
        };
        k += 1;
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return agentIDs;
  }

  public final func AddArea(area: ref<SecurityAreaControllerPS>, agents: array<ref<DeviceComponentPS>>) -> Void {
    let i: Int32;
    let index: Int32;
    RWLock.Acquire(this.m_agentsLock);
    i = 0;
    while i < ArraySize(agents) {
      if this.GetAgentIndex_NoLock(agents[i].GetID(), index) {
        Agent.AddArea(this.m_agents[index], area);
      };
      i += 1;
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final func RemoveArea(data: array<OnDisableAreaData>) -> Void {
    let i: Int32;
    let index: Int32;
    RWLock.Acquire(this.m_agentsLock);
    i = 0;
    while i < ArraySize(data) {
      if this.GetAgentIndex_NoLock(data[i].agent, index) {
        Agent.RemoveArea(this.m_agents[index], data[i].remainingAreas);
      };
      i += 1;
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final const func GetTurrets() -> array<Agent> {
    let agentClassName: CName;
    let i: Int32;
    let matchingAgents: array<Agent>;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      agentClassName = DeviceLink.GetLinkClassName(this.m_agents[i].link);
      if Equals(agentClassName, n"SecurityTurretControllerPS") {
        ArrayPush(matchingAgents, this.m_agents[i]);
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return matchingAgents;
  }

  public final const func GetSensors() -> array<Agent> {
    let agentClassName: CName;
    let i: Int32;
    let matchingAgents: array<Agent>;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      agentClassName = DeviceLink.GetLinkClassName(this.m_agents[i].link);
      if Equals(agentClassName, n"SurveillanceCameraControllerPS") || Equals(agentClassName, n"SecurityTurretControllerPS") {
        ArrayPush(matchingAgents, this.m_agents[i]);
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return matchingAgents;
  }

  public final const func HowManyTimesEntityReprimandedByThisAgentAlready(target: EntityID, agentID: PersistentID) -> Int32 {
    let index: Int32;
    let result: Int32 = 0;
    RWLock.AcquireShared(this.m_agentsLock);
    if this.GetAgentIndex_NoLock(agentID, index) {
      result = Agent.GetReprimandsCount(this.m_agents[index], target);
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return result;
  }

  public final const func HowManyTimesEntityReprimandedByThisAgentAlready(tresspasser: ref<GameObject>, agent: PersistentID) -> Int32 {
    if IsDefined(tresspasser) {
      return this.HowManyTimesEntityReprimandedByThisAgentAlready(tresspasser.GetEntityID(), agent);
    };
    return 0;
  }

  public final const func HasEntityBeenSpottedTooManyTimes(agent: PersistentID, target: EntityID) -> Bool {
    let count: Int32;
    let index: Int32;
    let maxCount: Int32;
    let isTooManyTimes: Bool = false;
    RWLock.AcquireShared(this.m_agentsLock);
    if this.GetAgentIndex_NoLock(agent, index) {
      if Equals(DeviceLink.GetLinkClassName(this.m_agents[index].link), n"PuppetDeviceLinkPS") {
        maxCount = this.m_maxReprimandsPerNPC;
      } else {
        maxCount = this.m_maxReprimandsPerDEVICE;
      };
      count = Agent.GetReprimandsCount(this.m_agents[index], target);
      isTooManyTimes = count > maxCount;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return isTooManyTimes;
  }

  public final func StoreReprimand(agentID: PersistentID, target: EntityID, reprimandID: Int32, targetAttitude: CName) -> Void {
    let index: Int32;
    let reprimandData: ReprimandData;
    reprimandData.isActive = true;
    reprimandData.receiver = target;
    reprimandData.reprimandID = reprimandID;
    reprimandData.receiverAttitudeGroup = targetAttitude;
    RWLock.Acquire(this.m_agentsLock);
    if this.GetAgentIndex_NoLock(agentID, index) {
      Agent.StoreReprimand(this.m_agents[index], reprimandData);
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final func WipeReprimandData(target: EntityID) -> Void {
    let i: Int32;
    RWLock.Acquire(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      Agent.WipeReprimand(this.m_agents[i], target);
      i += 1;
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final const func IsReprimandOngoing() -> Bool {
    let i: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      if Agent.IsPerformingReprimand(this.m_agents[i]) {
        RWLock.ReleaseShared(this.m_agentsLock);
        return true;
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return false;
  }

  public final const func GetReprimandReceiver(agentID: PersistentID) -> EntityID {
    let index: Int32;
    let receiver: EntityID;
    RWLock.AcquireShared(this.m_agentsLock);
    if this.GetAgentIndex_NoLock(agentID, index) {
      receiver = Agent.GetReprimandReceiver(this.m_agents[index]);
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return receiver;
  }

  public final const func IsReprimandOngoingAgainst(suspect: EntityID) -> Bool {
    let i: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      if Agent.IsPerformingReprimandAgainst(this.m_agents[i], suspect) {
        RWLock.ReleaseShared(this.m_agentsLock);
        return true;
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return false;
  }

  public final const func GetReprimandPerformer(target: EntityID, out agent: Agent) -> Bool {
    let i: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      if Agent.IsPerformingReprimandAgainst(this.m_agents[i], target) {
        agent = this.m_agents[i];
        RWLock.ReleaseShared(this.m_agentsLock);
        return true;
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return false;
  }

  public final func ReleaseFromReprimandAgainst(target: EntityID, opt agent: PersistentID) -> Void {
    let i: Int32;
    let index: Int32;
    if PersistentID.IsDefined(agent) {
      RWLock.Acquire(this.m_agentsLock);
      if this.GetAgentIndex_NoLock(agent, index) {
        Agent.ReleaseFromReprimand(this.m_agents[index], target);
      };
      RWLock.Release(this.m_agentsLock);
      return;
    };
    RWLock.Acquire(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      Agent.ReleaseFromReprimand(this.m_agents[i], target);
      i += 1;
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final func ReleaseAllReprimands(out agents: array<Agent>) -> Void {
    let i: Int32;
    RWLock.Acquire(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      if Agent.IsPerformingReprimand(this.m_agents[i]) {
        ArrayPush(agents, this.m_agents[i]);
        Agent.ForceRelaseReprimands(this.m_agents[i]);
      };
      i += 1;
    };
    RWLock.Release(this.m_agentsLock);
  }

  public final func CleanUpOnNewAttitudeGroup(gameInstance: GameInstance, newGroup: CName) -> Void {
    let i: Int32;
    let attSystem: ref<AttitudeSystem> = GameInstance.GetAttitudeSystem(gameInstance);
    if !IsDefined(attSystem) {
      return;
    };
    RWLock.Acquire(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      Agent.WipeReprimand(this.m_agents[i], newGroup, attSystem);
      i += 1;
    };
    RWLock.Release(this.m_agentsLock);
  }

  protected final func SaveAgent_NoLock(agent: Agent) -> Void {
    if !Agent.IsValid(agent) {
      return;
    };
    ArrayPush(this.m_agents, agent);
  }

  protected final const func GetAgentIndex(id: PersistentID, out index: Int32) -> Bool {
    let found: Bool = false;
    RWLock.AcquireShared(this.m_agentsLock);
    found = this.GetAgentIndex_NoLock(id, index);
    RWLock.ReleaseShared(this.m_agentsLock);
    return found;
  }

  protected final const func GetAgentIndex_NoLock(id: PersistentID, out index: Int32) -> Bool {
    index = -1;
    let i: Int32 = 0;
    while i < ArraySize(this.m_agents) {
      if PersistentID.ExtractEntityID(DeviceLink.GetLinkID(this.m_agents[i].link)) == PersistentID.ExtractEntityID(id) || Equals(DeviceLink.GetLinkID(this.m_agents[i].link), id) {
        index = i;
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetValidAgents(state: ESecuritySystemState, breachedAreas: array<ref<SecurityAreaControllerPS>>) -> array<SecuritySystemOutputData> {
    let breachOrigin: EBreachOrigin;
    let outgoingFilterType: EFilterType;
    let validAgent: SecuritySystemOutputData;
    let validAgents: array<SecuritySystemOutputData>;
    let i: Int32 = 0;
    while i < ArraySize(breachedAreas) {
      if EnumInt(breachedAreas[i].GetOutgoingFilter()) > EnumInt(outgoingFilterType) {
        outgoingFilterType = breachedAreas[i].GetOutgoingFilter();
      };
      i += 1;
    };
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      if Agent.IsEligible(this.m_agents[i], state, breachedAreas, outgoingFilterType, breachOrigin) {
        validAgent.link = this.m_agents[i].link;
        validAgent.delayDuration = this.m_agents[i].cachedDelayDuration;
        validAgent.breachOrigin = breachOrigin;
        ArrayPush(validAgents, validAgent);
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return validAgents;
  }

  public final const func GetAgentAreas(id: PersistentID) -> array<DeviceLink> {
    let areas: array<DeviceLink>;
    let index: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    if this.GetAgentIndex_NoLock(id, index) {
      Agent.GetAreas(this.m_agents[index], areas);
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return areas;
  }

  public final const func GetSupportedAgents() -> array<Agent> {
    let i: Int32;
    let supportedAgents: array<Agent>;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      if Agent.HasSupport(this.m_agents[i]) {
        ArrayPush(supportedAgents, this.m_agents[i]);
      };
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return supportedAgents;
  }

  public final func ClearSupport() -> Void {
    let i: Int32;
    RWLock.AcquireShared(this.m_agentsLock);
    i = 0;
    while i < ArraySize(this.m_agents) {
      Agent.ClearSupport(this.m_agents[i]);
      i += 1;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
  }

  public final func ProcessOnPlayerSpotted(evt: ref<PlayerSpotted>, modifiedAgents: script_ref<array<Agent>>, out hasAnySupport: Bool) -> Bool {
    let i: Int32;
    let outgoingFilterType: EFilterType;
    let spottee: PersistentID = evt.GetOwnerID();
    let isNPC: Bool = evt.GetComesFromNPC();
    let isSpotted: Bool = evt.DoesSee();
    let agentAreas: array<ref<SecurityAreaControllerPS>> = evt.GetAgentAreas();
    hasAnySupport = false;
    if isSpotted {
      i = 0;
      while i < ArraySize(agentAreas) {
        if EnumInt(agentAreas[i].GetOutgoingFilter()) > EnumInt(outgoingFilterType) {
          outgoingFilterType = agentAreas[i].GetOutgoingFilter();
          if Equals(outgoingFilterType, EFilterType.ALLOW_ALL) {
          } else {
            i += 1;
          };
        } else {
        };
        i += 1;
      };
      RWLock.Acquire(this.m_agentsLock);
      i = 0;
      while i < ArraySize(this.m_agents) {
        if isNPC && Equals(DeviceLink.GetLinkClassName(this.m_agents[i].link), n"PuppetDeviceLinkPS") || Equals(spottee, DeviceLink.GetLinkID(this.m_agents[i].link)) {
        } else {
          if Agent.IsEligibleToShareData(this.m_agents[i], ESecuritySystemState.COMBAT, agentAreas, outgoingFilterType) {
            if Agent.AddSupport(this.m_agents[i], spottee, true) {
              ArrayPush(Deref(modifiedAgents), this.m_agents[i]);
            };
          };
          if !hasAnySupport && Agent.HasSupport(this.m_agents[i]) {
            hasAnySupport = true;
          };
        };
        i += 1;
      };
      RWLock.Release(this.m_agentsLock);
    } else {
      RWLock.Acquire(this.m_agentsLock);
      i = 0;
      while i < ArraySize(this.m_agents) {
        if Agent.AddSupport(this.m_agents[i], spottee, false) {
          ArrayPush(Deref(modifiedAgents), this.m_agents[i]);
        };
        i += 1;
      };
      if !hasAnySupport && Agent.HasSupport(this.m_agents[i]) {
        hasAnySupport = true;
      };
      RWLock.Release(this.m_agentsLock);
    };
    return ArraySize(Deref(modifiedAgents)) > 0;
  }

  private final const func IsIndexOutOfBound(index: Int32) -> Bool {
    RWLock.AcquireShared(this.m_agentsLock);
    if index < 0 || index > ArraySize(this.m_agents) - 1 {
      RWLock.ReleaseShared(this.m_agentsLock);
      return true;
    };
    RWLock.ReleaseShared(this.m_agentsLock);
    return false;
  }
}
