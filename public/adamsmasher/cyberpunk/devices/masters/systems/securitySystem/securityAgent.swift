
public struct Agent {

  @attrib(unsavable, "true")
  public persistent let link: DeviceLink;

  @attrib(unsavable, "true")
  public persistent let reprimands: array<ReprimandData>;

  @attrib(unsavable, "true")
  public persistent let supportingAgents: array<PersistentID>;

  @attrib(unsavable, "true")
  public persistent let areas: array<DeviceLink>;

  @attrib(unsavable, "true")
  public persistent let incomingFilter: EFilterType;

  @attrib(unsavable, "true")
  public persistent let cachedDelayDuration: Float;

  public final static func Construct(link: DeviceLink, areas: array<ref<SecurityAreaControllerPS>>) -> Agent {
    let agent: Agent;
    let i: Int32;
    if !DeviceLink.IsValid(link) || ArraySize(areas) == 0 {
      return agent;
    };
    agent.link = link;
    Agent.SetIncomingFilter(agent, areas);
    if Equals(DeviceLink.GetLinkClassName(link), n"PuppetDeviceLinkPS") {
      agent.cachedDelayDuration = RandRangeF(0.10, 1.00);
    };
    i = 0;
    while i < ArraySize(areas) {
      ArrayPush(agent.areas, DeviceLink.Construct(areas[i]));
      i += 1;
    };
    return agent;
  }

  public final static func AddArea(self: script_ref<Agent>, area: ref<SecurityAreaControllerPS>) -> Void {
    Agent.SetIncomingFilter(self, area);
    ArrayPush(Deref(self).areas, DeviceLink.Construct(area));
  }

  public final static func RemoveArea(self: script_ref<Agent>, remainingAreas: array<ref<SecurityAreaControllerPS>>) -> Void {
    let i: Int32;
    Agent.SetIncomingFilter(self, remainingAreas);
    ArrayClear(Deref(self).areas);
    i = 0;
    while i < ArraySize(remainingAreas) {
      ArrayPush(Deref(self).areas, DeviceLink.Construct(remainingAreas[i]));
      i += 1;
    };
  }

  public final static func SetIncomingFilter(self: script_ref<Agent>, areas: array<ref<SecurityAreaControllerPS>>) -> Void {
    Deref(self).incomingFilter = EFilterType.ALLOW_ALL;
    let i: Int32 = 0;
    while i < ArraySize(areas) {
      Agent.SetIncomingFilter(self, areas[i]);
      i += 1;
    };
  }

  public final static func SetIncomingFilter(self: script_ref<Agent>, area: ref<SecurityAreaControllerPS>) -> Void {
    if EnumInt(Deref(self).incomingFilter) < EnumInt(area.GetIncomingFilter()) {
      Deref(self).incomingFilter = area.GetIncomingFilter();
    };
  }

  public final static func IsValid(self: Agent) -> Bool {
    if DeviceLink.IsValid(self.link) && ArraySize(self.areas) != 0 {
      return true;
    };
    return false;
  }

  public final static func GetAreas(self: Agent, out areas: array<DeviceLink>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(self.areas) {
      ArrayPush(areas, self.areas[i]);
      i += 1;
    };
  }

  public final static func IsEligible(self: Agent, state: ESecuritySystemState, breachedAreas: array<ref<SecurityAreaControllerPS>>, inputsOutgoingFilter: EFilterType, out breachOrigin: EBreachOrigin) -> Bool {
    let k: Int32;
    breachOrigin = EBreachOrigin.EXTERNAL;
    let i: Int32 = 0;
    while i < ArraySize(breachedAreas) {
      k = 0;
      while k < ArraySize(self.areas) {
        if breachedAreas[i] == self.areas[k] {
          breachOrigin = EBreachOrigin.LOCAL;
          return true;
        };
        k += 1;
      };
      i += 1;
    };
    if Equals(inputsOutgoingFilter, EFilterType.ALLOW_ALL) {
      if Equals(self.incomingFilter, EFilterType.ALLOW_ALL) {
        return true;
      };
      if Equals(self.incomingFilter, EFilterType.ALLOW_COMBAT_ONLY) && Equals(state, ESecuritySystemState.COMBAT) {
        return true;
      };
      return false;
    };
    if Equals(inputsOutgoingFilter, EFilterType.ALLOW_COMBAT_ONLY) {
      if Equals(self.incomingFilter, EFilterType.ALLOW_ALL) {
        return true;
      };
      if Equals(self.incomingFilter, EFilterType.ALLOW_COMBAT_ONLY) && Equals(state, ESecuritySystemState.COMBAT) {
        return true;
      };
      return false;
    };
    return false;
  }

  public final static func IsEligibleToShareData(self: Agent, state: ESecuritySystemState, breachedAreas: array<ref<SecurityAreaControllerPS>>, inputsOutgoingFilter: EFilterType) -> Bool {
    let i: Int32;
    let k: Int32;
    if Equals(inputsOutgoingFilter, EFilterType.ALLOW_ALL) {
      if Equals(self.incomingFilter, EFilterType.ALLOW_ALL) {
        return true;
      };
      if Equals(self.incomingFilter, EFilterType.ALLOW_COMBAT_ONLY) && Equals(state, ESecuritySystemState.COMBAT) {
        return true;
      };
    };
    if Equals(inputsOutgoingFilter, EFilterType.ALLOW_COMBAT_ONLY) {
      if Equals(self.incomingFilter, EFilterType.ALLOW_ALL) {
        return true;
      };
      if Equals(self.incomingFilter, EFilterType.ALLOW_COMBAT_ONLY) && Equals(state, ESecuritySystemState.COMBAT) {
        return true;
      };
    };
    i = 0;
    while i < ArraySize(breachedAreas) {
      k = 0;
      while k < ArraySize(self.areas) {
        if breachedAreas[i] == self.areas[k] {
          return true;
        };
        k += 1;
      };
      i += 1;
    };
    return false;
  }

  public final static func AddSupport(self: script_ref<Agent>, id: PersistentID, shouldAdd: Bool) -> Bool {
    let i: Int32;
    if shouldAdd {
      i = 0;
      while i < ArraySize(Deref(self).supportingAgents) {
        if Equals(Deref(self).supportingAgents[i], id) {
          return false;
        };
        i += 1;
      };
      ArrayPush(Deref(self).supportingAgents, id);
      if ArraySize(Deref(self).supportingAgents) == 1 {
        return true;
      };
      return false;
    };
    i = 0;
    while i < ArraySize(Deref(self).supportingAgents) {
      if Equals(Deref(self).supportingAgents[i], id) {
        ArrayErase(Deref(self).supportingAgents, i);
        if ArraySize(Deref(self).supportingAgents) == 0 {
          return true;
        };
        return false;
      };
      i += 1;
    };
    return false;
  }

  public final static func HasSupport(self: Agent) -> Bool {
    return ArraySize(self.supportingAgents) > 0;
  }

  public final static func ClearSupport(self: script_ref<Agent>) -> Void {
    ArrayClear(Deref(self).supportingAgents);
  }

  public final static func IsPerformingReprimand(self: Agent) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(self.reprimands) {
      if self.reprimands[i].isActive {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func IsPerformingReprimandAgainst(self: Agent, target: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(self.reprimands) {
      if self.reprimands[i].receiver == target && self.reprimands[i].isActive {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func GetReprimandReceiver(self: Agent) -> EntityID {
    let i: Int32 = 0;
    while i < ArraySize(self.reprimands) {
      if self.reprimands[i].isActive {
        return self.reprimands[i].receiver;
      };
      i += 1;
    };
    return EMPTY_ENTITY_ID();
  }

  public final static func GetReprimandsCount(self: Agent, target: EntityID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(self.reprimands) {
      if self.reprimands[i].receiver == target {
        return self.reprimands[i].count;
      };
      i += 1;
    };
    return 0;
  }

  public final static func ReleaseFromReprimand(self: script_ref<Agent>, target: EntityID) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(Deref(self).reprimands) {
      if Deref(self).reprimands[i].receiver == target {
        Deref(self).reprimands[i].isActive = false;
      };
      i += 1;
    };
  }

  public final static func ForceRelaseReprimands(self: script_ref<Agent>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(Deref(self).reprimands) {
      Deref(self).reprimands[i].isActive = false;
      i += 1;
    };
  }

  public final static func StoreReprimand(self: script_ref<Agent>, reprimandData: ReprimandData) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(Deref(self).reprimands) {
      if Deref(self).reprimands[i].receiver == reprimandData.receiver && Deref(self).reprimands[i].reprimandID != reprimandData.reprimandID {
        Deref(self).reprimands[i].count += 1;
        Deref(self).reprimands[i].reprimandID = reprimandData.reprimandID;
        Deref(self).reprimands[i].isActive = true;
        return;
      };
      i += 1;
    };
    reprimandData.count = 1;
    ArrayPush(Deref(self).reprimands, reprimandData);
    return;
  }

  public final static func WipeReprimand(self: script_ref<Agent>, target: EntityID) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(Deref(self).reprimands) {
      if Deref(self).reprimands[i].receiver == target {
        ArrayErase(Deref(self).reprimands, i);
        return;
      };
      i += 1;
    };
  }

  public final static func WipeReprimand(self: script_ref<Agent>, attGroup: CName, attSystem: ref<AttitudeSystem>) -> Void {
    let i: Int32 = ArraySize(Deref(self).reprimands) - 1;
    while i >= 0 {
      if Equals(attSystem.GetAttitudeRelation(attGroup, Deref(self).reprimands[i].receiverAttitudeGroup), EAIAttitude.AIA_Friendly) {
        ArrayErase(Deref(self).reprimands, i);
      };
      i -= 1;
    };
  }
}
