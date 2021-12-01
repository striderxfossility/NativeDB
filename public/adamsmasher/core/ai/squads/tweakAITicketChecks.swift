
public abstract class AITicketCondition extends IScriptable {

  public final static func PerformChecking(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, conditions: script_ref<array<wref<AITicketCondition_Record>>>, ticketRecord: wref<AITicket_Record>, squadRecord: wref<AISquadParams_Record>) -> Bool {
    if AIScriptSquad.TicketDebugHelper("", entity, ticketRecord) {
      LogAI("AITicketCondition Debug Breakpoint");
    };
    if IsDefined(squadRecord) && squadRecord.ProhibitedTicketsContains(ticketRecord.TicketType()) {
      return false;
    };
    if !AITicketCondition.CheckNumberOfTickets(entity, interface, ticketRecord) {
      return false;
    };
    return AITicketCondition.PerformChecking(entity, interface, conditions, ticketRecord);
  }

  public final static func PerformChecking(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, conditions: script_ref<array<wref<AITicketCondition_Record>>>, ticketRecord: wref<AITicket_Record>) -> Bool {
    let check: ref<AITicketCheck_Record>;
    let filter: ref<AITicketFilter_Record>;
    let i: Int32;
    let ticketName: CName;
    let validSquadMembers: array<wref<Entity>>;
    let willingSquadMembers: array<wref<Entity>>;
    if ArraySize(Deref(conditions)) == 0 {
      return true;
    };
    willingSquadMembers = interface.ListMembersWeak();
    ticketName = ticketRecord.TicketType().EnumName();
    i = ArraySize(willingSquadMembers) - 1;
    while i >= 0 {
      if willingSquadMembers[i] != entity && (!interface.IsSquadActionOpen(ticketName, willingSquadMembers[i]) || interface.HasOrderBySquadAction(ticketName, willingSquadMembers[i])) {
        ArrayRemove(willingSquadMembers, willingSquadMembers[i]);
      };
      i -= 1;
    };
    validSquadMembers = willingSquadMembers;
    i = 0;
    while i < ArraySize(Deref(conditions)) {
      filter = Deref(conditions)[i] as AITicketFilter_Record;
      check = null;
      if IsDefined(filter) {
        if filter.ResetMembersIncludingUnwillings() {
          validSquadMembers = interface.ListMembersWeak();
        } else {
          if filter.ResetMembers() {
            validSquadMembers = willingSquadMembers;
          };
        };
        if filter.SkipSelfOnce() {
          ArrayRemove(validSquadMembers, entity);
        };
        AITicketCondition.FilterOut(entity, interface, Deref(conditions)[i] as AITicketFilter_Record, ticketRecord, validSquadMembers);
        if filter.SkipSelfOnce() {
          ArrayPush(validSquadMembers, entity);
        };
      } else {
        check = Deref(conditions)[i] as AITicketCheck_Record;
        if AITicketCondition.Check(entity, interface, check, ticketRecord, validSquadMembers) {
          if check.OptionalFastExit() {
            return true;
          };
        } else {
          if !check.OptionalFastExit() {
            return false;
          };
        };
      };
      i += 1;
    };
    if check == null || check.OptionalFastExit() {
      LogAIError("Last condition should be check!");
      return false;
    };
    return true;
  }

  public final static func Check(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, check: wref<AITicketCheck_Record>, ticketRecord: wref<AITicket_Record>, out squadMembers: array<wref<Entity>>) -> Bool {
    let result: Bool = false;
    if check.IsA(n"gamedataAISquadORCondition_Record") {
      result = AITicketCondition.CheckOR(entity, interface, check as AISquadORCondition_Record, ticketRecord, squadMembers);
    } else {
      if check.IsA(n"gamedataAISquadANDCondition_Record") {
        result = AITicketCondition.CheckAND(entity, interface, check as AISquadANDCondition_Record, ticketRecord, squadMembers);
      } else {
        if check.IsA(n"gamedataAISquadMembersAmountCheck_Record") {
          result = AITicketCondition.CheckMembersAmount(entity, interface, check as AISquadMembersAmountCheck_Record, squadMembers);
        } else {
          if check.IsA(n"gamedataAISquadContainsSelfCheck_Record") {
            result = AITicketCondition.CheckContainsSelf(entity, interface, check as AISquadContainsSelfCheck_Record, squadMembers);
          } else {
            if check.IsA(n"gamedataAISquadDistanceRelationToTargetCheck_Record") {
              return AITicketCondition.CheckDistanceRelationToTarget(entity, interface, check as AISquadDistanceRelationToTargetCheck_Record, check.IsA(n"gamedataAISquadClosestToTargetCheck_Record"), squadMembers);
            };
            if check.IsA(n"gamedataAISquadDistanceRelationToSectorCheck_Record") {
              return AITicketCondition.CheckDistanceRelationToSector(entity, interface, check as AISquadDistanceRelationToSectorCheck_Record, check.IsA(n"gamedataAISquadClosestToSectorCheck_Record"), ticketRecord, squadMembers);
            };
            return false;
          };
        };
      };
    };
    if check.Invert() {
      result = !result;
    };
    return result;
  }

  public final static func CheckOR(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, check: wref<AISquadORCondition_Record>, ticketRecord: wref<AITicket_Record>, out squadMembers: array<wref<Entity>>) -> Bool {
    let count: Int32 = check.GetORCount();
    let i: Int32 = 0;
    while i < count {
      if AITicketCondition.Check(entity, interface, check.GetORItem(i), ticketRecord, squadMembers) {
        return true;
      };
      i += 1;
    };
    return count == 0;
  }

  public final static func CheckContainsSelf(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, check: wref<AISquadContainsSelfCheck_Record>, squadMembers: array<wref<Entity>>) -> Bool {
    return ArrayContains(squadMembers, entity);
  }

  public final static func CheckMembersAmount(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, check: wref<AISquadMembersAmountCheck_Record>, squadMembers: array<wref<Entity>>) -> Bool {
    let amount: Int32 = ArraySize(squadMembers);
    if !check.CountSelf() {
      amount -= 1;
    };
    if check.MinAmount() > 0 && check.MinAmount() > amount {
      return false;
    };
    if check.MaxAmount() > 0 && amount > check.MaxAmount() {
      return false;
    };
    return true;
  }

  public final static func CheckAND(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, check: wref<AISquadANDCondition_Record>, ticketRecord: wref<AITicket_Record>, out squadMembers: array<wref<Entity>>) -> Bool {
    let count: Int32 = check.GetANDCount();
    let i: Int32 = 0;
    while i < count {
      if !AITicketCondition.Check(entity, interface, check.GetANDItem(i), ticketRecord, squadMembers) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func FilterOut(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, filter: wref<AITicketFilter_Record>, ticketRecord: wref<AITicket_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    if filter.IsA(n"AISquadAvoidLastFilter_Record") {
      AITicketCondition.FilterAgainstChoosingPreviouslySelected(entity, interface, filter as AISquadAvoidLastFilter_Record, squadMembers);
    } else {
      if filter.IsA(n"gamedataAISquadFilterByAICondition_Record") {
        AITicketCondition.FilterAICondition(filter as AISquadFilterByAICondition_Record, squadMembers);
      } else {
        if filter.IsA(n"gamedataAISquadInSectorFilter_Record") {
          AITicketCondition.FilterInSector(interface, filter as AISquadInSectorFilter_Record, ticketRecord, squadMembers);
        } else {
          if filter.IsA(n"gamedataAISquadJustSelfFilter_Record") {
            AITicketCondition.FilterJustSelf(entity, filter as AISquadJustSelfFilter_Record, squadMembers);
          } else {
            if filter.IsA(n"gamedataAISquadSpatialForOwnTarget_Record") {
              AITicketCondition.FilterSpatialForOwnTarget(entity, filter as AISquadSpatialForOwnTarget_Record, squadMembers);
            } else {
              if filter.IsA(n"gamedataAISquadFilterOwnTargetSpotted_Record") {
                AITicketCondition.FilterTargetSpotted(entity, filter as AISquadFilterOwnTargetSpotted_Record, squadMembers);
              } else {
                if filter.IsA(n"gamedataAISquadItemPriorityFilter_Record") {
                  AITicketCondition.FilterItemPriority(filter as AISquadItemPriorityFilter_Record, squadMembers);
                };
              };
            };
          };
        };
      };
    };
  }

  public final static func CheckNumberOfTickets(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, ticketRecord: wref<AITicket_Record>) -> Bool {
    let ticketCap: Int32;
    let ticketCount: Int32;
    let workspotObject: wref<GameObject>;
    let squadMembers: array<wref<Entity>> = interface.ListMembersWeak();
    let i: Int32 = 0;
    while i < ArraySize(squadMembers) {
      if interface.HasOrderBySquadAction(ticketRecord.TicketType().EnumName(), squadMembers[i]) {
        ticketCount += 1;
      };
      i += 1;
    };
    if ticketRecord.ScaleNumberOfTicketsFromWorkspots() {
      workspotObject = FromVariant((entity as ScriptedPuppet).GetAIControllerComponent().GetBehaviorArgument(n"StimTarget"));
      ticketCap = workspotObject.GetNumberOfWorkpotsForAIAction(gamedataWorkspotActionType.DeviceInvestigation);
    };
    if ticketCap > 0 {
      if ticketCount + 1 > ticketCap {
        return false;
      };
      return true;
    };
    ticketCap = ticketRecord.MaxNumberOfTickets();
    if ticketRecord.PercentageNumberOfTickets() >= 0.00 {
      ticketCap = FloorF(Cast(ArraySize(squadMembers)) * ticketRecord.PercentageNumberOfTickets());
      if ticketCap == 0 && ticketRecord.MinNumberOfTickets() <= 0 {
        ticketCap = 1;
      };
    };
    if ticketRecord.MinNumberOfTickets() >= 0 && ticketCap < ticketRecord.MinNumberOfTickets() {
      ticketCap = ticketRecord.MinNumberOfTickets();
    };
    if ticketRecord.MaxNumberOfTickets() >= 0 && ticketCap > ticketRecord.MaxNumberOfTickets() {
      ticketCap = ticketRecord.MaxNumberOfTickets();
    };
    if ticketCap >= 0 && ticketCount + 1 > ticketCap {
      return false;
    };
    return true;
  }

  public final static func FilterAgainstChoosingPreviouslySelected(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, condition: wref<AISquadAvoidLastFilter_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    let canditate: wref<Entity>;
    let gameObject: wref<GameObject>;
    let ticketName: CName;
    if ArraySize(squadMembers) <= 1 {
      return;
    };
    gameObject = entity as GameObject;
    canditate = GameInstance.FindEntityByID(gameObject.GetGame(), interface.GetLastTicketRecipient(ticketName));
    if condition.Invert() {
      ArrayClear(squadMembers);
      ArrayPush(squadMembers, canditate);
    } else {
      ArrayRemove(squadMembers, canditate);
    };
  }

  public final static func CheckDistanceRelationToTarget(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, condition: wref<AISquadDistanceRelationToTargetCheck_Record>, closest: Bool, out squadMembers: array<wref<Entity>>) -> Bool {
    let candidate: wref<Entity>;
    let compareDistance: Float;
    let context: ScriptExecutionContext;
    let distance: Float;
    let result: Bool;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let i: Int32 = 0;
    while i < ArraySize(squadMembers) {
      if !AIHumanComponent.GetScriptContext(squadMembers[i] as ScriptedPuppet, context) {
        LogAIError("SquadMember must have AIHumanComponent!");
      } else {
        if !AIActionTarget.Get(context, condition.Target(), false, target, targetPosition) {
        } else {
          distance = AbsF(Vector4.Distance(squadMembers[i].GetWorldPosition(), targetPosition) - condition.RingRadius());
          if compareDistance == 0.00 || Equals(closest, compareDistance > distance) {
            compareDistance = distance;
            candidate = squadMembers[i];
          };
        };
      };
      i += 1;
    };
    if candidate == null {
      return false;
    };
    result = candidate == entity;
    return condition.Invert() ? !result : result;
  }

  public final static func FilterSpatialForOwnTarget(entity: wref<Entity>, condition: wref<AISquadSpatialForOwnTarget_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    let candidates: array<wref<Entity>>;
    let i: Int32;
    let ownerContext: ScriptExecutionContext;
    let squadMemberContext: ScriptExecutionContext;
    if !AIHumanComponent.GetScriptContext(entity as ScriptedPuppet, ownerContext) {
      LogAIError("Owner must have AIHumanComponent");
      return;
    };
    i = ArraySize(squadMembers) - 1;
    while i >= 0 {
      if !AIHumanComponent.GetScriptContext(squadMembers[i] as ScriptedPuppet, squadMemberContext) {
        LogAIError("SquadMember must have AIHumanComponent");
        return;
      };
      if !AICondition.CheckSpatial(ownerContext, squadMemberContext, condition.Spatial()) {
        if condition.Invert() {
          ArrayPush(candidates, squadMembers[i]);
        } else {
          ArrayRemove(squadMembers, squadMembers[i]);
        };
      };
      i -= 1;
    };
    if condition.Invert() {
      squadMembers = candidates;
    };
  }

  public final static func FilterAICondition(condition: wref<AISquadFilterByAICondition_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    let candidates: array<wref<Entity>>;
    let context: ScriptExecutionContext;
    let i: Int32;
    if !IsDefined(condition.Condition()) {
      LogAIError("NULL condition in FilterAICondition");
      return;
    };
    i = ArraySize(squadMembers) - 1;
    while i >= 0 {
      if !AIHumanComponent.GetScriptContext(squadMembers[i] as ScriptedPuppet, context) {
        LogAIError("SquadMember must have AIHumanComponent");
        return;
      };
      if !AICondition.CheckActionCondition(context, condition.Condition()) {
        if condition.Invert() {
          ArrayPush(candidates, squadMembers[i]);
        } else {
          ArrayRemove(squadMembers, squadMembers[i]);
        };
      };
      i -= 1;
    };
    if condition.Invert() {
      squadMembers = candidates;
    };
  }

  public final static func CheckDistanceRelationToSector(entity: wref<Entity>, interface: wref<PuppetSquadInterface>, condition: wref<AISquadDistanceRelationToSectorCheck_Record>, closest: Bool, ticketRecord: wref<AITicket_Record>, out squadMembers: array<wref<Entity>>) -> Bool {
    let candidate: wref<Entity>;
    let compareDistance: Float;
    let distance: Float;
    let i: Int32;
    let j: Int32;
    let result: Bool;
    let sectorInt: Int32;
    let sectors: array<wref<AISectorType_Record>>;
    let combatAlley: ref<CombatAlley> = interface.GetDefensiveCombatAlley();
    condition.Sectors(sectors);
    if ArraySize(sectors) == 0 {
      (ticketRecord as AITacticTicket_Record).Sectors(sectors);
    };
    i = 0;
    while i < ArraySize(sectors) {
      sectorInt = Cast(EnumValueFromName(n"AICombatSectorType", sectors[i].EnumName()));
      j = 0;
      while j < ArraySize(squadMembers) {
        distance = combatAlley.GetDistanceFromSector(IntEnum(sectorInt), squadMembers[j].GetWorldPosition());
        if compareDistance == 0.00 || Equals(closest, compareDistance > distance) {
          compareDistance = distance;
          candidate = squadMembers[j];
        };
        j += 1;
      };
      i += 1;
    };
    if candidate == null {
      return false;
    };
    result = candidate == entity;
    return condition.Invert() ? !result : result;
  }

  public final static func FilterJustSelf(entity: wref<Entity>, condition: wref<AISquadJustSelfFilter_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    if condition.Invert() {
      ArrayRemove(squadMembers, entity);
    } else {
      ArrayClear(squadMembers);
      ArrayPush(squadMembers, entity);
    };
  }

  public final static func FilterInSector(interface: wref<PuppetSquadInterface>, condition: wref<AISquadInSectorFilter_Record>, ticketRecord: wref<AITicket_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    let candidates: array<wref<Entity>>;
    let combatAlley: ref<CombatAlley>;
    let i: Int32;
    let isInAnySector: Bool;
    let j: Int32;
    let sectorInt: Int32;
    let sectors: array<wref<AISectorType_Record>>;
    condition.Sectors(sectors);
    if ArraySize(sectors) == 0 {
      (ticketRecord as AITacticTicket_Record).Sectors(sectors);
    };
    combatAlley = interface.GetDefensiveCombatAlley();
    j = ArraySize(squadMembers) - 1;
    while j >= 0 {
      isInAnySector = false;
      i = 0;
      while i < ArraySize(sectors) {
        sectorInt = Cast(EnumValueFromName(n"AICombatSectorType", sectors[i].EnumName()));
        isInAnySector = NotEquals(combatAlley.GetSector(squadMembers[i].GetWorldPosition()), IntEnum(sectorInt));
        if isInAnySector {
        } else {
          i += 1;
        };
      };
      if !isInAnySector {
        if condition.Invert() {
          ArrayPush(candidates, squadMembers[i]);
        } else {
          ArrayRemove(squadMembers, squadMembers[i]);
        };
      };
      j -= 1;
    };
    if condition.Invert() {
      squadMembers = candidates;
    };
  }

  public final static func FilterTargetSpotted(entity: wref<Entity>, condition: wref<AISquadFilterOwnTargetSpotted_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    let candidates: array<wref<Entity>>;
    let i: Int32;
    let ownerContext: ScriptExecutionContext;
    let squadMemberContext: ScriptExecutionContext;
    let target: wref<GameObject>;
    if !AIHumanComponent.GetScriptContext(entity as ScriptedPuppet, ownerContext) {
      LogAIError("Owner must have AIHumanComponent");
      ArrayClear(squadMembers);
      return;
    };
    if !AIActionTarget.GetObject(ownerContext, condition.Target(), target) {
      ArrayClear(squadMembers);
      return;
    };
    i = ArraySize(squadMembers) - 1;
    while i >= 0 {
      if !AIHumanComponent.GetScriptContext(squadMembers[i] as ScriptedPuppet, squadMemberContext) {
        LogAIError("SquadMember must have AIHumanComponent");
        return;
      };
      if !AITicketCondition.IsTargetSpotted(squadMemberContext, target) {
        if condition.Invert() {
          ArrayPush(candidates, squadMembers[i]);
        } else {
          ArrayRemove(squadMembers, squadMembers[i]);
        };
      };
      i -= 1;
    };
    if condition.Invert() {
      squadMembers = candidates;
    };
  }

  public final static func IsTargetSpotted(const context: ScriptExecutionContext, target: wref<GameObject>) -> Bool {
    let i: Int32;
    let threats: array<TrackedLocation>;
    let ownerAsPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let ttc: ref<TargetTrackerComponent> = ownerAsPuppet.GetTargetTrackerComponent();
    if IsDefined(ttc) {
      threats = ttc.GetHostileThreats(false);
      i = ArraySize(threats) - 1;
      while i >= 0 {
        if threats[i].entity == target {
          return true;
        };
        i -= 1;
      };
    };
    return false;
  }

  private final static func GetItem(entity: wref<Entity>) -> wref<ItemObject> {
    let go: wref<GameObject> = entity as GameObject;
    let item: wref<ItemObject> = GameInstance.GetTransactionSystem(go.GetGame()).GetItemInSlot(go, t"AttachmentSlots.WeaponRight");
    if !IsDefined(item) {
      item = GameInstance.GetTransactionSystem(go.GetGame()).GetItemInSlot(go, t"AttachmentSlots.WeaponLeft");
    };
    return item;
  }

  private final static func FilterItemTypePredicate(itemRecord: wref<Item_Record>, condition: wref<AISquadItemTypePriorityFilter_Record>, index: Int32) -> Bool {
    return itemRecord.ItemType() == condition.GetTypesItem(index);
  }

  private final static func FilterItemTypePredicate(itemRecord: wref<Item_Record>, condition: wref<AISquadItemCategoryPriorityFilter_Record>, index: Int32) -> Bool {
    return itemRecord.ItemCategory() == condition.GetCategoriesItem(index);
  }

  public final static func FilterItemPriority(condition: wref<AISquadItemPriorityFilter_Record>, out squadMembers: array<wref<Entity>>) -> Void {
    let backupMembers: array<wref<Entity>>;
    let candidates: array<wref<Entity>>;
    let foundMatch: Bool;
    let i: Int32;
    let itemRecord: wref<Item_Record>;
    let j: Int32;
    let prioritiesAmount: Int32;
    let itemTypeFilter: wref<AISquadItemTypePriorityFilter_Record> = condition as AISquadItemTypePriorityFilter_Record;
    let itemCategoryFilter: wref<AISquadItemCategoryPriorityFilter_Record> = condition as AISquadItemCategoryPriorityFilter_Record;
    if !IsDefined(itemTypeFilter) && !IsDefined(itemCategoryFilter) {
      ArrayClear(squadMembers);
      return;
    };
    backupMembers = squadMembers;
    prioritiesAmount = IsDefined(itemTypeFilter) ? itemTypeFilter.GetTypesCount() : itemCategoryFilter.GetCategoriesCount();
    foundMatch = false;
    j = 0;
    while j < prioritiesAmount && !foundMatch {
      i = 0;
      while i < ArraySize(squadMembers) {
        itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(AITicketCondition.GetItem(squadMembers[i]).GetItemID()));
        if IsDefined(itemTypeFilter) ? AITicketCondition.FilterItemTypePredicate(itemRecord, itemTypeFilter, j) : AITicketCondition.FilterItemTypePredicate(itemRecord, itemCategoryFilter, j) {
          if condition.Invert() {
            ArrayRemove(squadMembers, squadMembers[i]);
          } else {
            ArrayPush(candidates, squadMembers[i]);
          };
          foundMatch = true;
        };
        i += 1;
      };
      j += 1;
    };
    if !foundMatch && condition.RestoreOnFail() {
      squadMembers = backupMembers;
      return;
    };
    if !condition.Invert() {
      squadMembers = candidates;
    };
  }
}
