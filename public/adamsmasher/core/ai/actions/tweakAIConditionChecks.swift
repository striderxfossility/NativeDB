
public abstract class AICondition extends IScriptable {

  public final static func ActivationCheck(const context: ScriptExecutionContext, actionRecord: wref<AIAction_Record>) -> Bool {
    let debugActionName: String;
    let minLOD: Int32;
    if !IsDefined(actionRecord) {
      return false;
    };
    if actionRecord.DisableAction() || IsMultiplayer() && actionRecord.DisableActionInMultiplayer() {
      return false;
    };
    minLOD = actionRecord.MinLOD();
    if minLOD >= 0 && minLOD < ScriptExecutionContext.GetLOD(context) {
      return false;
    };
    if !IsFinal() {
      debugActionName = TDBID.ToStringDEBUG(actionRecord.GetID());
      if AIActionHelper.ActionDebugHelper("", ScriptExecutionContext.GetOwner(context), debugActionName) {
        LogAI("AICondition Debug Breakpoint");
      };
      if AIActionHelper.ActionDebugHelper(ScriptExecutionContext.GetOwner(context), debugActionName) {
        if IsDefined(actionRecord.ActivationCondition()) {
          if AICondition.CheckActionCondition(context, actionRecord.ActivationCondition()) {
            LogAI("AICondition Debug Breakpoint");
          } else {
            LogAI("AICondition Debug Breakpoint");
          };
        };
      };
    };
    if !AICondition.AnimationStreamedInCheck(context, actionRecord) {
      return false;
    };
    if !AIScriptUtils.CheckActionCooldowns(context, actionRecord) {
      return false;
    };
    if IsDefined(actionRecord.ActivationCondition()) && !AICondition.CheckActionCondition(context, actionRecord.ActivationCondition()) {
      AIScriptSquad.CloseTickets(context, actionRecord);
      return false;
    };
    AIScriptSquad.RequestTickets(context, actionRecord);
    if !AIScriptSquad.CheckTickets(context, actionRecord) {
      AIScriptSquad.RevokeTickets(context, actionRecord);
      return false;
    };
    return true;
  }

  public final static func NextPhaseCheck(const context: ScriptExecutionContext, phase: ref<AIActionPhase_Record>, actionRecord: ref<AIAction_Record>, repeatCheck: Bool) -> Bool {
    let count: Int32;
    let debugActionName: String;
    let i: Int32;
    if !IsFinal() {
      debugActionName = TDBID.ToStringDEBUG(actionRecord.GetID());
      if AIActionHelper.ActionDebugHelper("", ScriptExecutionContext.GetOwner(context), debugActionName) {
        LogAI("AICondition Debug Breakpoint");
      };
      if AIActionHelper.ActionDebugHelper(ScriptExecutionContext.GetOwner(context), debugActionName) {
        LogAI("AICondition Debug Breakpoint");
      };
    };
    AIScriptSquad.EvaluateTicketsDeactivation(context, actionRecord);
    if actionRecord.RevokingTicketCompletesAction() && !AIScriptSquad.CheckTickets(context, actionRecord) {
      return true;
    };
    if repeatCheck {
      count = phase.GetNotRepeatPhaseConditionCount();
      i = 0;
      while i < count {
        if AICondition.CheckActionCondition(context, phase.GetNotRepeatPhaseConditionItem(i)) {
          return true;
        };
        i += 1;
      };
    } else {
      count = phase.GetToNextPhaseConditionCount();
      i = 0;
      while i < count {
        if AICondition.CheckActionCondition(context, phase.GetToNextPhaseConditionItem(i)) {
          if !IsFinal() {
            debugActionName = TDBID.ToStringDEBUG(actionRecord.GetID());
            if AIActionHelper.ActionDebugHelper("", ScriptExecutionContext.GetOwner(context), debugActionName) {
              LogAI("AICondition Debug Breakpoint");
            };
            if AIActionHelper.ActionDebugHelper(ScriptExecutionContext.GetOwner(context), debugActionName) {
              LogAI("AICondition Debug Breakpoint");
            };
          };
          return true;
        };
        i += 1;
      };
    };
    return count == 0;
  }

  public final static func AnimationStreamedInCheck(const context: ScriptExecutionContext, actionRecord: ref<AIAction_Record>) -> Bool {
    let animVariation: Int32;
    let phaseToCheck: Int32;
    let variationSubAction: ref<AISubAction_Record>;
    let animData: ref<AIActionAnimData_Record> = actionRecord.AnimData();
    if !IsDefined(animData) {
      return true;
    };
    if !IsDefined(animData.AnimSlot()) {
      return true;
    };
    if !IsNameValid(animData.AnimFeature()) {
      return true;
    };
    phaseToCheck = 0;
    if IsDefined(actionRecord.Startup()) {
      phaseToCheck = 1;
    } else {
      if IsDefined(actionRecord.Loop()) {
        phaseToCheck = 2;
      } else {
        if IsDefined(actionRecord.Recovery()) {
          phaseToCheck = 3;
        };
      };
    };
    if animData.AnimSlot().UsePoseMatching() {
      animVariation = -1;
    } else {
      variationSubAction = animData.AnimVariationSubAction();
      if IsDefined(variationSubAction) {
        animVariation = AIScriptUtils.CallGetAnimVariation(context, variationSubAction);
      } else {
        animVariation = animData.AnimVariation();
      };
    };
    if !AIScriptUtils.CheckAnimation(context, animData.AnimFeature(), animVariation, phaseToCheck, true) {
      return !actionRecord.FailIfAnimationNotStreamedIn();
    };
    return true;
  }

  public final static func CheckActionConditions(const context: ScriptExecutionContext, conditions: script_ref<array<wref<AIActionCondition_Record>>>) -> Bool {
    let i: Int32;
    if ArraySize(Deref(conditions)) == 0 {
      return true;
    };
    i = 0;
    while i < ArraySize(Deref(conditions)) {
      if AICondition.CheckActionCondition(context, Deref(conditions)[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckActionCondition(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    return AIScriptUtils.CheckActionCondition(context, condition);
  }

  public final static func CheckActionCondition(puppet: wref<ScriptedPuppet>, condition: wref<AIActionCondition_Record>) -> Bool {
    let context: ScriptExecutionContext;
    if AIHumanComponent.GetScriptContext(puppet, context) {
      return AIScriptUtils.CheckActionCondition(context, condition);
    };
    LogAIError("Owner must have AIHumanComponent");
    return false;
  }

  public final static func CheckSlots(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AISlotCond_Record>;
    let count: Int32 = condition.GetSlotANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetSlotANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetSlotORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetSlotORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckItems(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIItemCond_Record>;
    let count: Int32 = condition.GetInventoryANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetInventoryANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetInventoryORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetInventoryORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckAbilities(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIAbilityCond_Record>;
    let count: Int32 = condition.GetAbilityCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetAbilityItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckStatusEffects(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIStatusEffectCond_Record>;
    let count: Int32 = condition.GetStatusEffectANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetStatusEffectANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetStatusEffectORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetStatusEffectORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckSignals(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AISignalCond_Record>;
    let count: Int32 = condition.GetSignalANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetSignalANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetSignalORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetSignalORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckSpatials(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AISpatialCond_Record>;
    let count: Int32 = condition.GetSpatialANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetSpatialANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetSpatialORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetSpatialORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckMovements(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIMovementCond_Record>;
    let count: Int32 = condition.GetMovementANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetMovementANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetMovementORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetMovementORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckCommands(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AICommandCond_Record>;
    let count: Int32 = condition.GetCommandANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetCommandANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetCommandORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetCommandORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckTickets(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AISquadCond_Record>;
    let count: Int32 = condition.GetSquadANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetSquadANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetSquadORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetSquadORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckStatPools(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIStatPoolCond_Record>;
    let count: Int32 = condition.GetStatPoolANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetStatPoolANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetStatPoolORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetStatPoolORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckAmmoCounts(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIAmmoCountCond_Record>;
    let count: Int32 = condition.GetAmmoCountANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetAmmoCountANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetAmmoCountORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetAmmoCountORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckWeakSpots(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIWeakSpotCond_Record>;
    let count: Int32 = condition.GetWeakSpotANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetWeakSpotANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetWeakSpotORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetWeakSpotORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckVehicles(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIVehicleCond_Record>;
    let count: Int32 = condition.GetVehicleANDCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetVehicleANDItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    count = condition.GetVehicleORCount();
    if count == 0 {
      return true;
    };
    i = 0;
    while i < count {
      record = condition.GetVehicleORItem(i);
      if AICondition.Check(context, record) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CheckTresspassings(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AITresspassingCond_Record>;
    let count: Int32 = condition.GetTresspassingCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetTresspassingItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckRestrictedMovementAreas(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIRestrictedMovementAreaCond_Record>;
    let count: Int32 = condition.GetRestrictedMovementAreaCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetRestrictedMovementAreaItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckCalculatePaths(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AICalculatePathCond_Record>;
    let count: Int32 = condition.GetCalculatePathCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetCalculatePathItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckCalculateLineOfSightVector(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AICalculateLineOfSightVector_Record>;
    let count: Int32 = condition.GetCalculateLineOfSightVectorCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetCalculateLineOfSightVectorItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckReactions(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIReactionCond_Record>;
    let count: Int32 = condition.GetReactionCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetReactionItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckLookats(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AILookAtCond_Record>;
    let count: Int32 = condition.GetLookatCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetLookatItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckStates(const context: ScriptExecutionContext, condition: wref<AIActionCondition_Record>) -> Bool {
    let record: wref<AIStateCond_Record>;
    let count: Int32 = condition.GetStateCount();
    let i: Int32 = 0;
    while i < count {
      record = condition.GetStateItem(i);
      if !AICondition.Check(context, record) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AISlotCond_Record>) -> Bool {
    let item: wref<ItemObject>;
    let itemRecord: wref<Item_Record>;
    let object: wref<GameObject>;
    let triggerModes: array<wref<TriggerMode_Record>>;
    let weaponRecord: wref<WeaponItem_Record>;
    if !AIActionTarget.GetObject(context, condition.Target(), object) {
      return false;
    };
    if AIActionTransactionSystem.ShouldPerformEquipmentCheck(object as ScriptedPuppet, condition.EquipmentGroup()) {
      if !AIActionTransactionSystem.CheckSlotsForEquipment(context, condition.EquipmentGroup()) {
        return condition.Invert() ? true : false;
      };
      return condition.Invert() ? false : true;
    };
    if !IsDefined(condition.Slot()) || !TDBID.IsValid(condition.Slot().GetID()) {
      return false;
    };
    if condition.CheckIfEmptySlotIsSpawningItem() != -1 {
      if condition.CheckIfEmptySlotIsSpawningItem() == 1 {
        if AIActionTransactionSystem.IsSlotEmptySpawningItem(ScriptExecutionContext.GetOwner(context), condition.Slot().GetID()) {
          return condition.Invert() ? false : true;
        };
      } else {
        if !AIActionTransactionSystem.IsSlotEmptySpawningItem(ScriptExecutionContext.GetOwner(context), condition.Slot().GetID()) {
          return condition.Invert() ? false : true;
        };
      };
    };
    item = GameInstance.GetTransactionSystem(object.GetGame()).GetItemInSlot(object, condition.Slot().GetID());
    if !IsDefined(item) {
      return condition.Invert() ? true : false;
    };
    if IsDefined(condition.ItemID()) && ItemID.GetTDBID(item.GetItemID()) != condition.ItemID().GetID() {
      return condition.Invert() ? true : false;
    };
    if NotEquals(condition.ItemTag(), n"") && !item.GetItemData().HasTag(condition.ItemTag()) {
      return condition.Invert() ? true : false;
    };
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item.GetItemID()));
    if IsDefined(condition.ItemType()) && condition.ItemType() != itemRecord.ItemType() {
      return condition.Invert() ? true : false;
    };
    if IsDefined(condition.ItemCategory()) && condition.ItemCategory() != itemRecord.ItemCategory() {
      return condition.Invert() ? true : false;
    };
    if IsDefined(condition.RequestedTriggerModes()) && NotEquals(condition.RequestedTriggerModes().Type(), AIActionHelper.GetLastRequestedTriggerMode(item as WeaponObject)) {
      return condition.Invert() ? true : false;
    };
    weaponRecord = itemRecord as WeaponItem_Record;
    if IsDefined(condition.Evolution()) && (!IsDefined(weaponRecord) || weaponRecord.Evolution() != condition.Evolution()) {
      return condition.Invert() ? true : false;
    };
    if condition.GetTriggerModesCount() > 0 {
      condition.TriggerModes(triggerModes);
      if !IsDefined(weaponRecord) || !AIActionHelper.WeaponHasTriggerModes(item as WeaponObject, weaponRecord, triggerModes) {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIItemCond_Record>) -> Bool {
    let itemID: ItemID;
    if AIActionTransactionSystem.ShouldPerformEquipmentCheck(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, condition.EquipmentGroup()) {
      if !AIActionTransactionSystem.CheckEquipmentGroupForEquipment(context, condition) {
        return condition.Invert() ? true : false;
      };
      return condition.Invert() ? false : true;
    };
    if IsDefined(condition.ItemID()) {
      itemID = ItemID.CreateQuery(condition.ItemID().GetID());
    } else {
      if IsDefined(condition.ItemCategory()) {
        if !AIActionTransactionSystem.GetFirstItemID(ScriptExecutionContext.GetOwner(context), condition.ItemCategory(), condition.ItemTag(), itemID) {
          return condition.Invert() ? true : false;
        };
      } else {
        if IsDefined(condition.ItemType()) {
          if !AIActionTransactionSystem.GetFirstItemID(ScriptExecutionContext.GetOwner(context), condition.ItemType(), condition.ItemTag(), itemID) {
            return condition.Invert() ? true : false;
          };
        } else {
          if !AIActionTransactionSystem.GetFirstItemID(ScriptExecutionContext.GetOwner(context), condition.ItemTag(), itemID) {
            return condition.Invert() ? true : false;
          };
        };
      };
    };
    if ItemID.IsValid(itemID) {
      if condition.Invert() {
        return !AIActionTransactionSystem.DoesItemMeetRequirements(itemID, condition, condition.Evolution());
      };
      return AIActionTransactionSystem.DoesItemMeetRequirements(itemID, condition, condition.Evolution());
    };
    return condition.Invert() ? true : false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIIsOnNavmeshCond_Record>) -> Bool {
    let navigationSystem: ref<AINavigationSystem>;
    let obj: wref<GameObject>;
    let radius: Float;
    let result: Bool;
    let tolerance: Vector4 = new Vector4(0.10, 0.10, 1.00, 1.00);
    if !AIActionTarget.GetObject(context, condition.Target(), obj) {
      return false;
    };
    navigationSystem = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if !IsDefined(navigationSystem) {
      return false;
    };
    result = navigationSystem.IsPointOnNavmesh(obj, obj.GetWorldPosition(), tolerance);
    if result {
      radius = condition.Radius();
      if radius > 0.00 {
        result = navigationSystem.IsPointOnNavmesh(obj, obj.GetWorldPosition() - obj.GetWorldForward() * radius, tolerance);
        if result {
          result = navigationSystem.IsPointOnNavmesh(obj, obj.GetWorldPosition() + obj.GetWorldRight() * radius, tolerance);
          if result {
            result = navigationSystem.IsPointOnNavmesh(obj, obj.GetWorldPosition() - obj.GetWorldRight() * radius, tolerance);
          };
        };
      };
    };
    return condition.Invert() ? !result : result;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIStatusEffectCond_Record>) -> Bool {
    let hasGameplayTag: Bool;
    let hasStatusEffect: Bool;
    let hasStatusEffectType: Bool;
    let obj: wref<GameObject>;
    let statusEffectGameplayTag: CName;
    let statusEffectID: TweakDBID;
    let statusEffectTypeID: TweakDBID;
    if !AIActionTarget.GetObject(context, condition.Target(), obj) {
      return false;
    };
    if IsDefined(condition.StatusEffect()) {
      statusEffectID = condition.StatusEffect().GetID();
    };
    if TDBID.IsValid(statusEffectID) {
      hasStatusEffect = StatusEffectSystem.ObjectHasStatusEffect(obj, statusEffectID);
      if condition.Invert() {
        if hasStatusEffect {
          return false;
        };
      } else {
        if !hasStatusEffect {
          return false;
        };
      };
    };
    if IsDefined(condition.StatusEffectType()) {
      statusEffectTypeID = condition.StatusEffectType().GetID();
    };
    if TDBID.IsValid(statusEffectTypeID) {
      hasStatusEffectType = StatusEffectSystem.ObjectHasStatusEffectOfType(obj, condition.StatusEffectType().Type());
      if condition.Invert() {
        if hasStatusEffectType {
          return false;
        };
      } else {
        if !hasStatusEffectType {
          return false;
        };
      };
    };
    statusEffectGameplayTag = condition.GameplayTag();
    if NotEquals(statusEffectGameplayTag, n"") {
      hasGameplayTag = StatusEffectSystem.ObjectHasStatusEffectWithTag(obj, statusEffectGameplayTag);
      if condition.Invert() {
        if hasGameplayTag {
          return false;
        };
      } else {
        if !hasGameplayTag {
          return false;
        };
      };
    };
    return true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AISignalCond_Record>) -> Bool {
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    let signalName: CName = condition.Name();
    if !IsNameValid(signalName) {
      return false;
    };
    signalTable = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetSignalTable();
    if !IsDefined(signalTable) {
      return false;
    };
    signalId = signalTable.GetOrCreateSignal(signalName);
    if !signalTable.GetCurrentValue(signalId) {
      if condition.Invert() {
        return true;
      };
      return false;
    };
    if condition.Invert() {
      return false;
    };
    return true;
  }

  private final static func CheckDistanceInternal(owner: ref<gamePuppet>, sourcePosition: Vector4, targetPosition: Vector4, distanceRange: Vector2, condition: wref<AISpatialCond_Record>, out returnVal: Bool) -> Bool {
    let distanceSquared: Float;
    let vecToTarget: Vector4;
    let distanceMul: Float = 1.00;
    if distanceRange.X > 0.00 || distanceRange.Y > 0.00 {
      vecToTarget = targetPosition - sourcePosition;
      distanceSquared = Vector4.LengthSquared(vecToTarget);
      distanceMul = CombatSpaceHelper.GetDistanceMultiplier(owner, condition.SpatialHintMults());
      if distanceRange.X > 0.00 {
        distanceRange.X *= distanceMul;
      };
      if distanceRange.Y > 0.00 {
        distanceRange.Y *= distanceMul;
      };
      if distanceRange.X > 0.00 && distanceSquared < distanceRange.X * distanceRange.X {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
      if distanceRange.Y > 0.00 && distanceSquared > distanceRange.Y * distanceRange.Y {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
    };
    return false;
  }

  private final static func CheckAngle2ObjInternal(owner: wref<gamePuppet>, source: wref<GameObject>, sourcePosition: Vector4, sourceCoverID: Uint64, target: wref<GameObject>, targetPosition: Vector4, targetCoverID: Uint64, coneAngleRange: Vector2, condition: wref<AISpatialCond_Record>, out returnVal: Bool) -> Bool {
    let angleToTarget: Float;
    let cm: ref<CoverManager>;
    let direction: Vector4;
    let rotationAxis: Vector4;
    let vecToTarget: Vector4;
    if coneAngleRange.X > 0.00 || coneAngleRange.Y > 0.00 || condition.AngleDirection() != 0 {
      if condition.UseTargetPOV() {
        vecToTarget = sourcePosition - targetPosition;
        if !IsDefined(target) && targetCoverID == 0u {
          LogAIError("AISpatialCond_Record UseTargetPOV cannot be executed if target is NULL!!!!!");
          returnVal = false;
          return true;
        };
        if IsDefined(target) {
          direction = target.GetWorldForward();
          rotationAxis = target.GetWorldUp();
        } else {
          cm = GameInstance.GetCoverManager(owner.GetGame());
          if !IsDefined(cm) {
            returnVal = false;
            return true;
          };
          direction = cm.GetCoverWorldForward(targetCoverID);
          rotationAxis = cm.GetCoverWorldUp(targetCoverID);
        };
      } else {
        vecToTarget = targetPosition - sourcePosition;
        if !IsDefined(source) && sourceCoverID == 0u {
          LogAIError("AISpatialCond_Record cannot be executed if source is NULL!!!!!");
          returnVal = false;
          return true;
        };
        if IsDefined(source) {
          direction = source.GetWorldForward();
          rotationAxis = source.GetWorldUp();
        } else {
          cm = GameInstance.GetCoverManager(owner.GetGame());
          if !IsDefined(cm) {
            returnVal = false;
            return true;
          };
          direction = cm.GetCoverWorldForward(sourceCoverID);
          rotationAxis = cm.GetCoverWorldUp(sourceCoverID);
        };
      };
      angleToTarget = Vector4.GetAngleDegAroundAxis(vecToTarget, direction, rotationAxis);
      if coneAngleRange.X > 0.00 && AbsF(angleToTarget) < coneAngleRange.X * 0.50 {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
      if coneAngleRange.Y > 0.00 && AbsF(angleToTarget) > coneAngleRange.Y * 0.50 {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
      if angleToTarget * Cast(condition.AngleDirection()) < 0.00 {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
    };
    return false;
  }

  private final static func CheckAngle3ObjInternal(owner: wref<gamePuppet>, source: wref<GameObject>, sourcePosition: Vector4, sourceCoverID: Uint64, target: wref<GameObject>, targetPosition: Vector4, targetCoverID: Uint64, targetOpt: wref<GameObject>, targetPositionOpt: Vector4, targetCoverIDOpt: Uint64, coneAngleRange: Vector2, condition: wref<AISpatialCond_Record>, out returnVal: Bool) -> Bool {
    let angleToTarget: Float;
    let cm: ref<CoverManager>;
    let direction1: Vector4;
    let direction2: Vector4;
    let rotationAxis: Vector4;
    if coneAngleRange.X > 0.00 || coneAngleRange.Y > 0.00 || condition.AngleDirection() != 0 {
      if condition.UseTargetPOV() {
        direction1 = sourcePosition - targetPosition;
        direction2 = targetPositionOpt - targetPosition;
        if !IsDefined(target) && targetCoverID == 0u {
          LogAIError("AISpatialCond_Record UseTargetPOV cannot be executed if target is NULL!!!!!");
          returnVal = false;
          return true;
        };
        if IsDefined(target) {
          rotationAxis = target.GetWorldUp();
        } else {
          cm = GameInstance.GetCoverManager(owner.GetGame());
          if !IsDefined(cm) {
            returnVal = false;
            return true;
          };
          rotationAxis = cm.GetCoverWorldUp(targetCoverID);
        };
      } else {
        direction1 = targetPosition - sourcePosition;
        direction2 = targetPositionOpt - sourcePosition;
        if !IsDefined(source) && sourceCoverID == 0u {
          LogAIError("AISpatialCond_Record UseTargetPOV cannot be executed if source is NULL!!!!!");
          returnVal = false;
          return true;
        };
        if IsDefined(source) {
          rotationAxis = source.GetWorldUp();
        } else {
          rotationAxis = cm.GetCoverWorldUp(sourceCoverID);
        };
      };
      angleToTarget = Vector4.GetAngleDegAroundAxis(direction1, direction2, rotationAxis);
      if coneAngleRange.X > 0.00 && AbsF(angleToTarget) < coneAngleRange.X * 0.50 {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
      if coneAngleRange.Y > 0.00 && AbsF(angleToTarget) > coneAngleRange.Y * 0.50 {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
      if angleToTarget * Cast(condition.AngleDirection()) < 0.00 {
        returnVal = condition.Invert() ? true : false;
        return true;
      };
    };
    return false;
  }

  private final static func CheckZDiffInternal(sourcePosition: Vector4, targetPosition: Vector4, ZDiffRange: Vector2, condition: wref<AISpatialCond_Record>, out returnVal: Bool) -> Bool {
    let vecToTarget: Vector4 = sourcePosition - targetPosition;
    if ZDiffRange.X > 0.00 && AbsF(vecToTarget.Z) < ZDiffRange.X {
      returnVal = condition.Invert() ? true : false;
      return true;
    };
    if ZDiffRange.Y > 0.00 && AbsF(vecToTarget.Z) > ZDiffRange.Y {
      returnVal = condition.Invert() ? true : false;
      return true;
    };
    return false;
  }

  public final static func CheckSpatial(const ownerContext: ScriptExecutionContext, const targetContext: ScriptExecutionContext, condition: wref<AISpatialCond_Record>) -> Bool {
    let ZDiffRange: Vector2;
    let coneAngleRange: Vector2;
    let distanceRange: Vector2;
    let source: wref<GameObject>;
    let sourceCoverID: Uint64;
    let sourcePosition: Vector4;
    let target: wref<GameObject>;
    let targetCoverID: Uint64;
    let targetCoverIDOpt: Uint64;
    let targetOpt: wref<GameObject>;
    let targetPosition: Vector4;
    let targetPositionOpt: Vector4;
    let targetOptPresent: Bool = false;
    let returnVal: Bool = false;
    if !AIActionTarget.Get(ownerContext, condition.Source(), false, source, sourcePosition, sourceCoverID, condition.PredictionTime()) {
      return false;
    };
    if !AIActionTarget.Get(targetContext, condition.Target(), false, target, targetPosition, targetCoverID, condition.PredictionTime()) {
      return false;
    };
    targetOptPresent = AIActionTarget.Get(ownerContext, condition.TargetOpt(), false, targetOpt, targetPositionOpt, targetCoverIDOpt, condition.PredictionTime());
    distanceRange = condition.Distance();
    if AICondition.CheckDistanceInternal(ScriptExecutionContext.GetOwner(ownerContext), sourcePosition, targetPosition, distanceRange, condition, returnVal) {
      return returnVal;
    };
    ZDiffRange = condition.ZDiff();
    if AICondition.CheckZDiffInternal(sourcePosition, targetPosition, ZDiffRange, condition, returnVal) {
      return returnVal;
    };
    coneAngleRange = condition.ConeAngle();
    if !targetOptPresent {
      if AICondition.CheckAngle2ObjInternal(ScriptExecutionContext.GetOwner(ownerContext), source, sourcePosition, sourceCoverID, target, targetPosition, targetCoverID, coneAngleRange, condition, returnVal) {
        return returnVal;
      };
    } else {
      if AICondition.CheckDistanceInternal(ScriptExecutionContext.GetOwner(ownerContext), sourcePosition, targetPositionOpt, distanceRange, condition, returnVal) {
        return returnVal;
      };
      if AICondition.CheckZDiffInternal(sourcePosition, targetPositionOpt, ZDiffRange, condition, returnVal) {
        return returnVal;
      };
      if AICondition.CheckAngle3ObjInternal(ScriptExecutionContext.GetOwner(ownerContext), source, sourcePosition, sourceCoverID, target, targetPosition, targetCoverID, targetOpt, targetPositionOpt, targetCoverIDOpt, coneAngleRange, condition, returnVal) {
        return returnVal;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AISpatialCond_Record>) -> Bool {
    return AICondition.CheckSpatial(context, context, condition);
  }

  public final static func OnCantFindProperCheck(const conditionName: CName) -> Void {
    LogAI("Cant find check for class " + NameToString(conditionName));
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIExtendTargetCirclingCond_Record>) -> Bool {
    let angle: Float;
    let angleMax: Float;
    let angleMin: Float;
    let circledTgt: wref<GameObject>;
    let circledTgtPos: Vector4;
    let circledTgtToOwnerDir: Vector4;
    let coverId: Uint64;
    let destTgt: wref<GameObject>;
    let destTgtPos: Vector4;
    let direction: Vector4;
    let i: Int32;
    let ownerPos: Vector4;
    let spreadIncreaseAngle: Float;
    let squadmate: wref<ScriptedPuppet>;
    let squadmateContext: ScriptExecutionContext;
    let squadmateTgt: wref<GameObject>;
    let squadmates: array<wref<Entity>>;
    if !AISquadHelper.GetSquadmates(ScriptExecutionContext.GetOwner(context), squadmates) {
      return condition.Invert();
    };
    if !AIActionTarget.Get(context, condition.Target(), false, circledTgt, circledTgtPos, coverId) {
      return condition.Invert();
    };
    if !AIActionTarget.Get(context, condition.DestinationTarget(), false, destTgt, destTgtPos, coverId) {
      return condition.Invert();
    };
    ownerPos = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    circledTgtToOwnerDir = ownerPos - circledTgtPos;
    spreadIncreaseAngle = condition.SpreadIncreaseAngle();
    angleMax = 0.00;
    angleMin = 0.00;
    i = 0;
    while i < ArraySize(squadmates) {
      squadmate = squadmates[i] as ScriptedPuppet;
      if ScriptedPuppet.IsActive(squadmate) && AIHumanComponent.GetScriptContext(squadmate, squadmateContext) && AIActionTarget.GetObject(squadmateContext, condition.Target(), squadmateTgt) && squadmateTgt == circledTgt {
        direction = squadmate.GetWorldPosition() - circledTgtPos;
        angle = Vector4.GetAngleDegAroundAxis(circledTgtToOwnerDir, direction, circledTgt.GetWorldUp());
        if angle > angleMax {
          angleMax = angle;
        };
        if angle < angleMin {
          angleMin = angle;
        };
      };
      i += 1;
    };
    direction = destTgtPos - circledTgtPos;
    angle = Vector4.GetAngleDegAroundAxis(circledTgtToOwnerDir, direction, circledTgt.GetWorldUp());
    return NotEquals(condition.Invert(), angle - spreadIncreaseAngle >= angleMax || angle + spreadIncreaseAngle <= angleMin);
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIMovementCond_Record>) -> Bool {
    let constrainedByRestrictedArea: Bool;
    let constrainedByRestrictedAreaCond: Int32;
    let destination: wref<GameObject>;
    let destinationCalculated: Bool;
    let destinationCalculatedCond: Int32;
    let destinationChanged: Bool;
    let destinationChangedCond: Int32;
    let destinationPosition: Vector4;
    let distance: Float;
    let distanceRange: Vector2;
    let incline: Float;
    let isEvaluated: Int32;
    let isInIdle: Bool;
    let isMovingCond: Int32;
    let isPausedByDynamicCollision: Bool;
    let isPausedByDynamicCollisionCond: Int32;
    let isPolicyEvaluated: Bool;
    let isUsingOffMeshLink: Int32;
    let lineOfSightCond: Int32;
    let lineOfSightFailed: Bool;
    let movePoliciesComponent: ref<MovePoliciesComponent>;
    let movementTypeCond: moveMovementType;
    let offMeshConnectionType: worldOffMeshConnectionType;
    let offMeshExplorationType: moveExplorationType;
    let pathFindingCond: Int32;
    let pathFindingFailed: Bool;
    let slopeCond: Vector2;
    let distanceMul: Float = 1.00;
    if !ScriptExecutionContext.GetOwner(context).IsPuppet() {
      return false;
    };
    movePoliciesComponent = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetMovePolicesComponent();
    if !IsDefined(movePoliciesComponent) {
      return false;
    };
    isEvaluated = condition.IsEvaluated();
    if isEvaluated >= 0 {
      isPolicyEvaluated = movePoliciesComponent.IsTopPolicyEvaluated();
      if isEvaluated == 0 {
        if isPolicyEvaluated {
          return condition.Invert() ? true : false;
        };
      } else {
        if !isPolicyEvaluated {
          return condition.Invert() ? true : false;
        };
      };
    };
    isMovingCond = condition.IsMoving();
    if isMovingCond >= 0 {
      isInIdle = movePoliciesComponent.IsInIdle();
      if isMovingCond == 0 {
        if !isInIdle {
          return condition.Invert() ? true : false;
        };
      } else {
        if isInIdle {
          return condition.Invert() ? true : false;
        };
      };
    };
    lineOfSightCond = condition.LineOfSightFailed();
    if lineOfSightCond >= 0 {
      lineOfSightFailed = movePoliciesComponent.HasLineOfSightFailed();
      if lineOfSightCond == 0 {
        if lineOfSightFailed {
          return condition.Invert() ? true : false;
        };
      } else {
        if !lineOfSightFailed {
          return condition.Invert() ? true : false;
        };
      };
    };
    pathFindingCond = condition.PathFindingFailed();
    if pathFindingCond >= 0 {
      pathFindingFailed = movePoliciesComponent.IsPathfindingFailed();
      if pathFindingCond == 0 {
        if pathFindingFailed {
          return condition.Invert() ? true : false;
        };
      } else {
        if !pathFindingFailed {
          return condition.Invert() ? true : false;
        };
      };
    };
    destinationChangedCond = condition.IsDestinationChanged();
    if destinationChangedCond >= 0 {
      destinationChanged = movePoliciesComponent.IsDestinationChanged();
      if destinationChangedCond == 0 {
        if destinationChanged {
          return condition.Invert() ? true : false;
        };
      } else {
        if !destinationChanged {
          return condition.Invert() ? true : false;
        };
      };
    };
    destinationCalculatedCond = condition.IsDestinationCalculated();
    if destinationCalculatedCond >= 0 {
      destinationCalculated = movePoliciesComponent.IsDestinationCalculated();
      if destinationCalculatedCond == 0 {
        if destinationCalculated {
          return condition.Invert() ? true : false;
        };
      } else {
        if !destinationCalculated {
          return condition.Invert() ? true : false;
        };
      };
    };
    constrainedByRestrictedAreaCond = condition.ConstrainedByRestrictedArea();
    if constrainedByRestrictedAreaCond >= 0 {
      constrainedByRestrictedArea = movePoliciesComponent.IsConstrainedByRestrictedArea();
      if constrainedByRestrictedAreaCond == 0 {
        if constrainedByRestrictedArea {
          return condition.Invert() ? true : false;
        };
      } else {
        if !constrainedByRestrictedArea {
          return condition.Invert() ? true : false;
        };
      };
    };
    isPausedByDynamicCollisionCond = condition.IsPauseByDynamicCollision();
    if isPausedByDynamicCollisionCond >= 0 {
      isPausedByDynamicCollision = movePoliciesComponent.IsPausedByDynamicCollision();
      if isPausedByDynamicCollisionCond == 0 {
        if isPausedByDynamicCollision {
          return condition.Invert() ? true : false;
        };
      } else {
        if !isPausedByDynamicCollision {
          return condition.Invert() ? true : false;
        };
      };
    };
    slopeCond = condition.Slope();
    if slopeCond.X != -1.00 || slopeCond.Y != -1.00 {
      incline = movePoliciesComponent.GetInclineAngle();
      if slopeCond.X != -1.00 && incline < slopeCond.X {
        return condition.Invert() ? true : false;
      };
      if slopeCond.Y != -1.00 && incline > slopeCond.Y {
        return condition.Invert() ? true : false;
      };
    };
    distanceRange = condition.DistanceToDestination();
    if distanceRange.X > 0.00 || distanceRange.Y > 0.00 {
      distanceMul = CombatSpaceHelper.GetDistanceMultiplier(ScriptExecutionContext.GetOwner(context), condition.SpatialHintMults());
      if distanceRange.X > 0.00 {
        distanceRange.X *= distanceMul;
      };
      if distanceRange.Y > 0.00 {
        distanceRange.Y *= distanceMul;
      };
    };
    if AIActionTarget.Get(context, condition.Destination(), false, destination, destinationPosition) {
      distance = movePoliciesComponent.GetDistanceToDestination();
      distance = distance - movePoliciesComponent.GetDistanceToDestinationFrom(destinationPosition);
      if distance < distanceRange.X {
        return condition.Invert() ? true : false;
      };
      if distance > distanceRange.Y {
        return condition.Invert() ? true : false;
      };
    } else {
      if distanceRange.X > 0.00 || distanceRange.Y > 0.00 {
        distance = movePoliciesComponent.GetDistanceToDestination();
        if distanceRange.X > 0.00 && distance < distanceRange.X {
          return condition.Invert() ? true : false;
        };
        if distanceRange.Y > 0.00 && distance > distanceRange.Y {
          return condition.Invert() ? true : false;
        };
      };
    };
    isUsingOffMeshLink = condition.IsUsingOffMeshLink();
    if isUsingOffMeshLink >= 0 {
      if isUsingOffMeshLink == 0 {
        if movePoliciesComponent.IsOnOffMeshLink() {
          return condition.Invert() ? true : false;
        };
      } else {
        if !movePoliciesComponent.IsOnOffMeshLink() {
          return condition.Invert() ? true : false;
        };
      };
    };
    if NotEquals(condition.OffMeshLinkType(), n"") {
      offMeshExplorationType = movePoliciesComponent.GetExplorationOffMeshLinkType();
      if NotEquals(condition.OffMeshLinkType(), EnumValueToName(n"moveExplorationType", Cast(EnumInt(offMeshExplorationType)))) {
        movePoliciesComponent.GetOffMeshLinkType(offMeshConnectionType);
        if NotEquals(condition.OffMeshLinkType(), EnumValueToName(n"worldOffMeshConnectionType", Cast(EnumInt(offMeshConnectionType)))) {
          return condition.Invert() ? true : false;
        };
      };
    };
    if NotEquals(condition.MovementType(), n"") {
      movementTypeCond = IntEnum(Cast(EnumValueFromName(n"moveMovementType", condition.MovementType())));
      if !IsDefined(movePoliciesComponent.GetTopPolicies()) {
        return condition.Invert() ? true : false;
      };
      if NotEquals(movementTypeCond, movePoliciesComponent.GetTopPolicies().GetMovementType()) {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIStatPoolCond_Record>) -> Bool {
    let isIncreasing: Int32;
    let obj: wref<GameObject>;
    let percRange: Vector2;
    let statPercValue: Float;
    let statPoolMod: StatPoolModifier;
    if !IsDefined(condition.StatPool()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Target(), obj) {
      return false;
    };
    percRange = condition.Percentage();
    if percRange.X >= 0.00 || percRange.Y >= 0.00 {
      statPercValue = GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetStatPoolValue(Cast(obj.GetEntityID()), condition.StatPool().StatPoolType(), true);
      if percRange.X >= 0.00 && statPercValue < percRange.X {
        return condition.Invert() ? true : false;
      };
      if percRange.Y >= 0.00 && statPercValue > percRange.Y {
        return condition.Invert() ? true : false;
      };
    };
    isIncreasing = condition.IsIncreasing();
    if isIncreasing >= 0 {
      if isIncreasing == 1 {
        GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetModifier(Cast(obj.GetEntityID()), condition.StatPool().StatPoolType(), gameStatPoolModificationTypes.Regeneration, statPoolMod);
      } else {
        if isIncreasing == 0 {
          GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetModifier(Cast(obj.GetEntityID()), condition.StatPool().StatPoolType(), gameStatPoolModificationTypes.Decay, statPoolMod);
        };
      };
      if statPoolMod.valuePerSec <= 0.00 {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIAmmoCountCond_Record>) -> Bool {
    let ammoCount: Uint32;
    let ammoPercentage: Float;
    let percRange: Vector2;
    let weapon: wref<WeaponObject>;
    if !IsDefined(condition.WeaponSlot()) {
      return false;
    };
    weapon = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), condition.WeaponSlot().GetID()) as WeaponObject;
    if !IsDefined(weapon) {
      return false;
    };
    ammoCount = WeaponObject.GetMagazineAmmoCount(weapon);
    if condition.Min() >= 0 && ammoCount < Cast(condition.Min()) {
      return condition.Invert() ? true : false;
    };
    if condition.Max() >= 0 && ammoCount > Cast(condition.Max()) {
      return condition.Invert() ? true : false;
    };
    percRange = condition.Percentage();
    ammoPercentage = WeaponObject.GetMagazinePercentage(weapon);
    if percRange.X >= 0.00 && ammoPercentage < percRange.X {
      return condition.Invert() ? true : false;
    };
    if percRange.Y >= 0.00 && ammoPercentage > percRange.Y {
      return condition.Invert() ? true : false;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIWeakSpotCond_Record>) -> Bool {
    let i: Int32;
    let weakspots: array<wref<WeakspotObject>>;
    if !ScriptExecutionContext.GetOwner(context).IsNPC() {
      return false;
    };
    (ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetWeakspotComponent().GetWeakspots(weakspots);
    if ArraySize(weakspots) > 0 && !IsDefined(condition.Weakspot()) {
      return condition.Invert() ? false : true;
    };
    i = 0;
    while i < ArraySize(weakspots) {
      if weakspots[i].GetRecord() == condition.Weakspot() && (condition.IncludeDestroyed() || !weakspots[i].IsDead()) {
        return condition.Invert() ? false : true;
      };
      i += 1;
    };
    return condition.Invert() ? true : false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AITresspassingCond_Record>) -> Bool {
    let position: Vector4;
    let target: wref<GameObject>;
    if !AIActionTarget.GetObject(context, condition.Target(), target) {
      return condition.Invert() ? true : false;
    };
    if condition.CheckSafeArea() {
      if !IsDefined(condition.Target()) || !AIActionTarget.GetPosition(context, condition.Target(), position, false) {
        return condition.Invert() ? true : false;
      };
      if GameInstance.GetSafeAreaManager(ScriptExecutionContext.GetOwner(context).GetGame()).IsPointInSafeArea(position) {
        return condition.Invert() ? false : true;
      };
      return condition.Invert() ? true : false;
    };
    if condition.Invert() {
      return !ScriptExecutionContext.GetOwner(context).IsTargetTresspassingMyZone(target);
    };
    return ScriptExecutionContext.GetOwner(context).IsTargetTresspassingMyZone(target);
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIRestrictedMovementAreaCond_Record>) -> Bool {
    let position: Vector4;
    if !IsDefined(condition.Target()) || !AIActionTarget.GetPosition(context, condition.Target(), position, false) {
      return false;
    };
    if !GameInstance.GetRestrictMovementAreaManager(ScriptExecutionContext.GetOwner(context).GetGame()).HasAssignedRestrictMovementArea(ScriptExecutionContext.GetOwner(context).GetEntityID()) {
      return condition.Invert() ? false : true;
    };
    if condition.Invert() {
      return !GameInstance.GetRestrictMovementAreaManager(ScriptExecutionContext.GetOwner(context).GetGame()).IsPointInRestrictMovementArea(ScriptExecutionContext.GetOwner(context).GetEntityID(), position);
    };
    return GameInstance.GetRestrictMovementAreaManager(ScriptExecutionContext.GetOwner(context).GetGame()).IsPointInRestrictMovementArea(ScriptExecutionContext.GetOwner(context).GetEntityID(), position);
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AICalculatePathCond_Record>) -> Bool {
    let end: AIPositionSpec;
    let endPosition: Vector4;
    let endWorldPosition: WorldPosition;
    let navigationPath: ref<NavigationPath>;
    let navigationResult: ref<NavigationFindWallResult>;
    let navigationSystem: ref<AINavigationSystem>;
    let ownerPuppet: ref<NPCPuppet>;
    let pathfindingResult: Bool;
    let query: AINavigationSystemQuery;
    let requestID: Uint32;
    let result: AINavigationSystemResult;
    let start: AIPositionSpec;
    let startPosition: Vector4;
    let startPositionOffset: Vector4;
    let startWorldPosition: WorldPosition;
    let target: wref<GameObject>;
    let offMeshTags: array<CName> = condition.AllowedOffMeshTags();
    if condition.Distance() <= 0.00 && !IsDefined(condition.Target()) {
      condition.Invert() ? true : false;
    };
    startPosition = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    startPositionOffset = Vector4.Vector3To4(condition.StartPositionOffset());
    if !Vector4.IsZero(startPositionOffset) {
      startPosition += Vector4.RotByAngleXY(ScriptExecutionContext.GetOwner(context).GetWorldForward(), 90.00) * startPositionOffset.X;
      startPosition += ScriptExecutionContext.GetOwner(context).GetWorldForward() * startPositionOffset.Y;
      startPosition.Z += startPositionOffset.Z;
    };
    if IsDefined(condition.Target()) {
      AIActionTarget.GetObject(context, condition.Target(), target);
      if !AIActionTarget.GetPosition(context, condition.Target(), endPosition, false) {
        return condition.Invert() ? true : false;
      };
      WorldPosition.SetVector4(startWorldPosition, ScriptExecutionContext.GetOwner(context).GetWorldPosition());
      WorldPosition.SetVector4(endWorldPosition, endPosition);
      AIPositionSpec.SetWorldPosition(start, startWorldPosition);
      AIPositionSpec.SetWorldPosition(end, endWorldPosition);
      if ArraySize(offMeshTags) > 0 {
        query.allowedTags = offMeshTags;
      };
      query.source = start;
      query.target = end;
      navigationSystem = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame());
      requestID = navigationSystem.StartPathfinding(query);
      pathfindingResult = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetResult(requestID, result);
      navigationSystem.StopPathfinding(requestID);
      if !pathfindingResult {
        return condition.Invert() ? true : false;
      };
      if !result.hasPath {
        return condition.Invert() ? true : false;
      };
      if condition.CheckDynamicObstacle() {
        ownerPuppet = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
        if Equals(ownerPuppet.GetInfluenceComponent().IsLineEmpty(startPosition, endPosition, target), gameinfluenceTestLineResult.Fail) {
          return condition.Invert() ? true : false;
        };
      };
      if condition.CheckStraightPath() {
        navigationResult = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame()).FindWallInLineForCharacter(startPosition, endPosition, condition.Tolerance(), ScriptExecutionContext.GetOwner(context));
        if navigationResult.isHit {
          return condition.Invert() ? true : false;
        };
      };
    } else {
      endPosition = startPosition + Vector4.RotByAngleXY(ScriptExecutionContext.GetOwner(context).GetWorldForward(), condition.DirectionAngle()) * condition.Distance();
      navigationPath = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame()).CalculatePathForCharacter(startPosition, endPosition, condition.Tolerance(), ScriptExecutionContext.GetOwner(context));
      if !IsDefined(navigationPath) || ArraySize(navigationPath.path) == 0 {
        return condition.Invert() ? true : false;
      };
      if condition.CheckDynamicObstacle() {
        ownerPuppet = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
        if Equals(ownerPuppet.GetInfluenceComponent().IsLineEmpty(startPosition, endPosition), gameinfluenceTestLineResult.Fail) {
          return condition.Invert() ? true : false;
        };
      };
      if condition.CheckStraightPath() {
        ownerPuppet = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
        startPosition.Z += 0.50;
        endPosition.Z += 0.50;
        navigationResult = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame()).FindWallInLineForCharacter(startPosition, endPosition, condition.Tolerance(), ScriptExecutionContext.GetOwner(context));
        if navigationResult.isHit {
          return condition.Invert() ? true : false;
        };
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AICalculateLineOfSightVector_Record>) -> Bool {
    let endOffset: Vector4;
    let endPosition: Vector4;
    let startOffset: Vector4;
    let startPosition: Vector4;
    AIActionTarget.GetPosition(context, condition.StartPosition(), startPosition, false);
    AIActionTarget.GetPosition(context, condition.EndPosition(), endPosition, false);
    if Vector4.IsZero(startPosition) || Vector4.IsZero(endPosition) || Equals(startPosition, Vector4.EmptyVector()) || Equals(endPosition, Vector4.EmptyVector()) {
      return condition.Invert() ? true : false;
    };
    if GameInstance.GetSenseManager(ScriptExecutionContext.GetOwner(context).GetGame()).IsPositionVisible(startPosition + startOffset, endPosition + endOffset) {
      return condition.Invert() ? true : false;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIReactionCond_Record>) -> Bool {
    let activeReactionData: ref<AIReactionData>;
    let behavior: String;
    let currentStat: Float;
    let i: Int32;
    let investigateData: stimInvestigateData;
    let stimPosition: Vector4;
    let stimType: ref<StimType_Record>;
    let stimTypeCount: Int32;
    let threshold: Float;
    let ownerPuppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let characterRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(ownerPuppet.GetRecordID());
    if IsDefined(condition.Preset()) {
      if NotEquals(characterRecord.ReactionPreset().ReactionGroup(), condition.Preset().ReactionGroup()) {
        return condition.Invert() ? true : false;
      };
    };
    activeReactionData = ownerPuppet.GetStimReactionComponent().GetActiveReactionData();
    if !IsDefined(activeReactionData) {
      activeReactionData = ownerPuppet.GetStimReactionComponent().GetDesiredReactionData();
    };
    if condition.InvestigateController() {
      investigateData = activeReactionData.stimInvestigateData;
      if !investigateData.investigateController {
        return condition.Invert() ? true : false;
      };
    };
    if NotEquals(condition.ReactionBehaviorName(), n"") {
      behavior = EnumValueToString("gamedataOutput", Cast(EnumInt(activeReactionData.reactionBehaviorName)));
      if !StrContains(behavior, NameToString(condition.ReactionBehaviorName())) {
        return condition.Invert() ? true : false;
      };
    };
    if condition.ValidStimPosition() {
      stimPosition = activeReactionData.stimSource;
      if Vector4.IsZero(stimPosition) {
        return condition.Invert() ? true : false;
      };
    };
    stimTypeCount = condition.GetStimTypeCount();
    if stimTypeCount > 0 {
      i = 0;
      while i < stimTypeCount {
        stimType = condition.GetStimTypeItem(i);
        if NotEquals(stimType.Type(), activeReactionData.stimType) {
          return condition.Invert() ? true : false;
        };
        i += 1;
      };
    };
    if IsDefined(condition.ThresholdValue()) {
      switch condition.ThresholdValue().StatPoolType() {
        case gamedataStatPoolType.Fear:
          currentStat = GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetStatPoolValue(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.Fear, false);
          threshold = characterRecord.ReactionPreset().FearThreshold();
          break;
        default:
          return false;
      };
      if currentStat < threshold || threshold == 0.00 {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AILookAtCond_Record>) -> Bool {
    let shootingBlackboard: ref<IBlackboard>;
    let target: wref<GameObject>;
    let value: Int32;
    if !AIActionTarget.GetObject(context, condition.Target(), target) {
      return false;
    };
    if condition.RightArmLookAtActive() != -1 {
      shootingBlackboard = (target as ScriptedPuppet).GetAIControllerComponent().GetShootingBlackboard();
      if !IsDefined(shootingBlackboard) {
        return false;
      };
      value = shootingBlackboard.GetInt(GetAllBlackboardDefs().AIShooting.rightArmLookAtLimitReached);
      if value != condition.RightArmLookAtActive() {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIPreviousAttackCond_Record>) -> Bool {
    let i: Int32;
    let previousAttackDelay: Float;
    let ownerPuppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let attacksToCheck: array<CName> = condition.PreviousAttackName();
    if !ScriptExecutionContext.GetOwner(context).IsPuppet() {
      return false;
    };
    if ArraySize(attacksToCheck) == 0 {
      return false;
    };
    previousAttackDelay = EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) - ownerPuppet.GetAIControllerComponent().GetActionBlackboard().GetFloat(GetAllBlackboardDefs().AIAction.ownerLastAttackTimeStamp);
    if condition.TimeWindow() >= 0.00 && previousAttackDelay > condition.TimeWindow() {
      return condition.Invert() ? true : false;
    };
    i = 0;
    while i < ArraySize(attacksToCheck) {
      if Equals(attacksToCheck[i], ownerPuppet.GetAIControllerComponent().GetActionBlackboard().GetName(GetAllBlackboardDefs().AIAction.ownerLastAttackName)) {
        return condition.Invert() ? false : true;
      };
      i += 1;
    };
    return condition.Invert() ? true : false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIBlockCountCond_Record>) -> Bool {
    let attacksBlocked: Int32;
    let attacksParried: Int32;
    let ownerPuppet: wref<ScriptedPuppet>;
    if !ScriptExecutionContext.GetOwner(context).IsPuppet() {
      return false;
    };
    ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    attacksBlocked = ownerPuppet.GetHitReactionComponent().GetBlockCount();
    if condition.MinBlockCount() >= 0 && attacksBlocked < condition.MinBlockCount() {
      return condition.Invert() ? true : false;
    };
    if condition.MaxBlockCount() >= 0 && attacksBlocked > condition.MaxBlockCount() {
      return condition.Invert() ? true : false;
    };
    attacksParried = ownerPuppet.GetHitReactionComponent().GetParryCount();
    if condition.MinParryCount() >= 0 && attacksParried < condition.MinParryCount() {
      return condition.Invert() ? true : false;
    };
    if condition.MaxParryCount() >= 0 && attacksParried > condition.MaxParryCount() {
      return condition.Invert() ? true : false;
    };
    if condition.OwnerAttackBlockedCount() >= 0 && ownerPuppet.GetAIControllerComponent().GetActionBlackboard().GetInt(GetAllBlackboardDefs().AIAction.ownerMeleeAttackBlockedCount) < condition.OwnerAttackBlockedCount() {
      return condition.Invert() ? true : false;
    };
    if condition.OwnerAttackParriedCount() >= 0 && ownerPuppet.GetAIControllerComponent().GetActionBlackboard().GetInt(GetAllBlackboardDefs().AIAction.ownerMeleeAttackParriedCount) < condition.OwnerAttackParriedCount() {
      return condition.Invert() ? true : false;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIOptimalDistanceCond_Record>) -> Bool {
    let count: Int32;
    let distanceRange: Vector2;
    let distanceSquared: Float;
    let i: Int32;
    let ringRecord: wref<AIRingType_Record>;
    let source: wref<GameObject>;
    let sourcePosition: Vector4;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let validCheck: Bool;
    let vecToTarget: Vector4;
    if !AIActionTarget.Get(context, condition.Source(), false, source, sourcePosition, condition.PredictionTime()) {
      return false;
    };
    if !AIActionTarget.Get(context, condition.Target(), false, target, targetPosition, condition.PredictionTime()) {
      return false;
    };
    count = condition.GetCheckRingsCount();
    if count > 0 {
      i = 0;
      while i < count {
        ringRecord = condition.GetCheckRingsItem(i);
        if AIActionHelper.GetDistanceRangeFromRingType(ringRecord, condition, distanceRange) {
          validCheck = true;
        } else {
          i += 1;
        };
      };
    };
    if !validCheck {
      ringRecord = AIActionHelper.GetLatestActiveRingTypeRecord(source as ScriptedPuppet);
      if AIActionHelper.GetDistanceRangeFromRingType(ringRecord, condition, distanceRange) {
        validCheck = true;
      };
    };
    if validCheck {
      vecToTarget = targetPosition - sourcePosition;
      distanceSquared = Vector4.LengthSquared(vecToTarget);
      if distanceRange.X > 0.00 && distanceSquared < distanceRange.X * distanceRange.X {
        if condition.FailWhenCloserThanCurrentRing() {
          return condition.Invert() ? false : true;
        };
        return condition.Invert() ? true : false;
      };
      if distanceRange.Y > 0.00 && distanceSquared > distanceRange.Y * distanceRange.Y {
        if condition.FailWhenFurtherThantCurrentRing() {
          return condition.Invert() ? false : true;
        };
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIDodgeCountCond_Record>) -> Bool {
    let attacksDodged: Int32;
    let ownerPuppet: wref<ScriptedPuppet>;
    if !ScriptExecutionContext.GetOwner(context).IsPuppet() {
      return false;
    };
    ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    attacksDodged = ownerPuppet.GetHitReactionComponent().GetDodgeCount();
    if condition.MinDodgeCount() >= 0 && attacksDodged < condition.MinDodgeCount() {
      return condition.Invert() ? true : false;
    };
    if condition.MaxDodgeCount() >= 0 && attacksDodged > condition.MaxDodgeCount() {
      return condition.Invert() ? true : false;
    };
    if condition.OwnerAttackDodgedCount() >= 0 && ownerPuppet.GetAIControllerComponent().GetActionBlackboard().GetInt(GetAllBlackboardDefs().AIAction.ownerMeleeAttackDodgedCount) < condition.OwnerAttackDodgedCount() {
      return condition.Invert() ? true : false;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIIsInActiveCameraCond_Record>) -> Bool {
    let coverId: Uint64;
    let target: wref<GameObject>;
    let targetPos: Vector4;
    if !AIActionTarget.Get(context, condition.Target(), target, targetPos, coverId) {
      return false;
    };
    if CameraSystemHelper.IsInCameraFrustum(target, condition.Height(), condition.Radius()) {
      return condition.Invert() ? false : true;
    };
    return condition.Invert() ? true : false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIThrowCond_Record>) -> Bool {
    let canThrowGrenade: Bool;
    let cm: ref<CoverManager>;
    let currentCoverID: Uint64;
    let exposureMethods: array<AICoverExposureMethod>;
    let grenadeExposureMethods: array<AICoverExposureMethod>;
    let ownerPuppet: wref<ScriptedPuppet>;
    let target: wref<GameObject>;
    let throwAngle: Float;
    let throwPositions: Vector4;
    let throwStartType: gameGrenadeThrowStartType;
    let weapon: wref<ThrowableWeaponObject>;
    if !ScriptExecutionContext.GetOwner(context).IsPuppet() || !IsDefined(condition.Target()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Target(), target) {
      condition.Invert() ? true : false;
    };
    if IsDefined(condition.WeaponSlot()) {
      weapon = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), condition.WeaponSlot().GetID()) as ThrowableWeaponObject;
      if IsDefined(weapon) {
        return condition.Invert() ? false : true;
      };
    };
    ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if IsDefined(ownerPuppet) {
      canThrowGrenade = ownerPuppet.GetAIControllerComponent().CanThrowGrenadeAtTarget(target, throwPositions, throwAngle, throwStartType);
      if canThrowGrenade {
        cm = GameInstance.GetCoverManager(ownerPuppet.GetGame());
        if IsDefined(cm) {
          currentCoverID = cm.GetCurrentCover(ownerPuppet);
          if currentCoverID > 0u {
            if Equals(throwStartType, gameGrenadeThrowStartType.LeftSide) {
              ArrayResize(exposureMethods, 6);
              exposureMethods[0] = AICoverExposureMethod.Standing_Step_Left;
              exposureMethods[1] = AICoverExposureMethod.Standing_Lean_Left;
              exposureMethods[2] = AICoverExposureMethod.Crouching_Step_Left;
              exposureMethods[3] = AICoverExposureMethod.Crouching_Lean_Left;
              exposureMethods[4] = AICoverExposureMethod.Standing_Blind_Left;
              exposureMethods[5] = AICoverExposureMethod.Crouching_Blind_Left;
            } else {
              if Equals(throwStartType, gameGrenadeThrowStartType.RightSide) {
                ArrayResize(exposureMethods, 6);
                exposureMethods[0] = AICoverExposureMethod.Standing_Step_Right;
                exposureMethods[1] = AICoverExposureMethod.Standing_Lean_Right;
                exposureMethods[2] = AICoverExposureMethod.Crouching_Step_Right;
                exposureMethods[3] = AICoverExposureMethod.Crouching_Lean_Right;
                exposureMethods[4] = AICoverExposureMethod.Standing_Blind_Right;
                exposureMethods[5] = AICoverExposureMethod.Crouching_Blind_Right;
              } else {
                if Equals(throwStartType, gameGrenadeThrowStartType.Top) {
                  ArrayResize(exposureMethods, 3);
                  exposureMethods[0] = AICoverExposureMethod.Lean_Over;
                  exposureMethods[1] = AICoverExposureMethod.Stand_Up;
                  exposureMethods[2] = AICoverExposureMethod.Crouching_Blind_Top;
                };
              };
            };
            grenadeExposureMethods = AICoverHelper.GetAvailableExposureSpots(ownerPuppet, currentCoverID, target, exposureMethods, condition.ClearLOSDistanceTolerance());
            if ArraySize(grenadeExposureMethods) == 0 {
              canThrowGrenade = false;
            };
          } else {
            if Equals(throwStartType, gameGrenadeThrowStartType.Invalid) {
              canThrowGrenade = false;
            };
          };
        };
      };
    };
    if condition.Invert() {
      return !canThrowGrenade;
    };
    return canThrowGrenade;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIFriendlyFireCond_Record>) -> Bool {
    let friendlyHostage: Bool;
    let ownerPuppet: wref<ScriptedPuppet>;
    let secondaryTarget: wref<ScriptedPuppet>;
    let target: wref<GameObject>;
    if !ScriptExecutionContext.GetOwner(context).IsPuppet() {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.DoNotBlockShootingOnFriendlyFire") {
      return condition.Invert();
    };
    ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    target = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
    if IsDefined(target) {
      if ScriptedPuppet.IsBeingGrappled(target) {
        secondaryTarget = ScriptedPuppet.GetGrappleParent(target) as ScriptedPuppet;
        if IsDefined(secondaryTarget) && Equals(GameObject.GetAttitudeTowards(ownerPuppet, secondaryTarget), EAIAttitude.AIA_Friendly) {
          friendlyHostage = true;
        };
      } else {
        if GameInstance.GetStatsSystem(ownerPuppet.GetGame()).GetStatValue(Cast(ownerPuppet.GetEntityID()), gamedataStatType.IsAggressive) <= 0.00 && GameInstance.GetStatsSystem(ownerPuppet.GetGame()).GetStatValue(Cast(ownerPuppet.GetEntityID()), gamedataStatType.IsReckless) <= 0.00 {
          secondaryTarget = ScriptedPuppet.GetGrappleChild(target) as ScriptedPuppet;
          if IsDefined(secondaryTarget) && ScriptedPuppet.IsActive(secondaryTarget) && Equals(GameObject.GetAttitudeTowards(ownerPuppet, secondaryTarget), EAIAttitude.AIA_Friendly) {
            friendlyHostage = true;
          };
        };
      };
    };
    if condition.Invert() {
      return !ownerPuppet.GetAIControllerComponent().IsFriendlyFiring() && !friendlyHostage;
    };
    return ownerPuppet.GetAIControllerComponent().IsFriendlyFiring() || friendlyHostage;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIWeaponLockedOnTargetCond_Record>) -> Bool {
    let weapon: ref<WeaponObject>;
    if !IsDefined(condition.WeaponSlot()) {
      return false;
    };
    weapon = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), condition.WeaponSlot().GetID()) as WeaponObject;
    if !IsDefined(weapon) {
      return false;
    };
    if weapon.IsTargetLocked() {
      return condition.Invert() ? false : true;
    };
    return condition.Invert() ? true : false;
  }

  private final static func IsAwareOfBeingFlankedByThreat(ownerPuppet: wref<ScriptedPuppet>, threat: TrackedLocation) -> Bool {
    let threatAsPuppet: ref<ScriptedPuppet>;
    let trackedLocation: TrackedLocation;
    if threat.accuracy > 0.00 {
      return true;
    };
    threatAsPuppet = threat.entity as ScriptedPuppet;
    if IsDefined(threatAsPuppet) {
      if threatAsPuppet.IsPlayer() && TargetTrackingExtension.GetTrackedLocation(threatAsPuppet, ownerPuppet, trackedLocation) {
        if trackedLocation.accuracy > 0.50 {
          return true;
        };
      };
      if IsDefined(threatAsPuppet.GetSensesComponent()) && threatAsPuppet.GetSensesComponent().IsAgentVisible(ownerPuppet) {
        return true;
      };
    };
    return false;
  }

  private final static func IsAwareOfBeingFlankedByAnyThreat(ownerPuppet: wref<ScriptedPuppet>, threats: array<TrackedLocation>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(threats) {
      if AICondition.IsAwareOfBeingFlankedByThreat(ownerPuppet, threats[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AICoverCond_Record>) -> Bool {
    let coverExposureMethod: CName;
    let coverID: Uint64;
    let currentCoverID: Uint64;
    let exposureMethods: array<CName>;
    let owner: wref<GameObject>;
    let ownerPuppet: wref<ScriptedPuppet>;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let threats: array<TrackedLocation>;
    if !IsDefined(condition.Cover()) {
      return false;
    };
    if !ScriptExecutionContext.GetOwner(context).IsPuppet() {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Owner(), owner) {
      return false;
    };
    ownerPuppet = owner as ScriptedPuppet;
    if !AIActionTarget.GetCoverID(context, condition.Cover(), currentCoverID, targetPosition) {
      return condition.Invert() ? true : false;
    };
    if condition.DesiredCoverChanged() != -1 {
      AIActionTarget.GetCoverID(context, condition.DesiredCover(), coverID);
      if condition.DesiredCoverChanged() == 1 {
        if currentCoverID == coverID {
          return condition.Invert() ? true : false;
        };
      } else {
        if currentCoverID != coverID {
          return condition.Invert() ? true : false;
        };
      };
    };
    if !GameInstance.GetCoverManager(ownerPuppet.GetGame()).IsCoverAvailable(currentCoverID, owner) {
      return condition.Invert() ? true : false;
    };
    if IsDefined(condition.Target()) && AIActionTarget.Get(context, condition.Target(), false, target, targetPosition) {
      if condition.MaxCoverToTargetAngle() > 0.00 && AICoverHelper.GetAbsAngleFromCoverToTargetPosition(ownerPuppet, currentCoverID, targetPosition) > condition.MaxCoverToTargetAngle() {
        return condition.Invert() ? true : false;
      };
      if Equals(condition.Cover().Type(), gamedataAIActionTarget.CurrentCover) && !AICoverHelper.HasCoverExposureMethods(ownerPuppet, currentCoverID, target, condition.CoverExposureMethods()) {
        return condition.Invert() ? true : false;
      };
    };
    if condition.IsProtectingHorizontallyAgainstTarget() != -1 {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(ownerPuppet, n"Blind") {
        threats = GameInstance.GetCoverManager(ownerPuppet.GetGame()).GetThreatsNotProtectedFrom(currentCoverID, ownerPuppet, 1.00, condition.PredictionTime(), gamedataTrackingMode.BeliefPosition);
      } else {
        threats = GameInstance.GetCoverManager(ownerPuppet.GetGame()).GetThreatsNotProtectedFrom(currentCoverID, ownerPuppet, 1.00, condition.PredictionTime(), gamedataTrackingMode.RealPosition);
      };
      if condition.IsProtectingHorizontallyAgainstTarget() == 0 {
        if !AICondition.IsAwareOfBeingFlankedByAnyThreat(ownerPuppet, threats) {
          return condition.Invert() ? true : false;
        };
      } else {
        if AICondition.IsAwareOfBeingFlankedByAnyThreat(ownerPuppet, threats) {
          return condition.Invert() ? true : false;
        };
      };
    };
    if GameInstance.GetCoverManager(ownerPuppet.GetGame()).GetCoverRemainingHealthPercentage(currentCoverID) < condition.MinCoverHealth() {
      return condition.Invert() ? true : false;
    };
    if condition.CoverType() == 0 && !GameInstance.GetCoverManager(ownerPuppet.GetGame()).IsShootingSpot(currentCoverID) {
      return condition.Invert() ? true : false;
    };
    if condition.CoverType() == 1 && !GameInstance.GetCoverManager(ownerPuppet.GetGame()).IsCoverRegular(currentCoverID) {
      return condition.Invert() ? true : false;
    };
    if condition.CoverType() == 2 && (!GameInstance.GetCoverManager(ownerPuppet.GetGame()).IsCoverRegular(currentCoverID) || NotEquals(GameInstance.GetCoverManager(ownerPuppet.GetGame()).GetCoverHeight(currentCoverID), gameCoverHeight.Low)) {
      return condition.Invert() ? true : false;
    };
    if condition.CoverType() == 3 && (!GameInstance.GetCoverManager(ownerPuppet.GetGame()).IsCoverRegular(currentCoverID) || NotEquals(GameInstance.GetCoverManager(ownerPuppet.GetGame()).GetCoverHeight(currentCoverID), gameCoverHeight.High)) {
      return condition.Invert() ? true : false;
    };
    if condition.IsOwnerExposed() != -1 {
      if condition.IsOwnerExposed() == 1 {
        if !AIActionHelper.IsCurrentlyExposedInCover(ownerPuppet) {
          return condition.Invert() ? true : false;
        };
      } else {
        if AIActionHelper.IsCurrentlyExposedInCover(ownerPuppet) {
          return condition.Invert() ? true : false;
        };
      };
    };
    if condition.IsOwnerCrouching() != -1 {
      if condition.IsOwnerCrouching() == 1 {
        if !AIActionHelper.IsCurrentlyCrouching(ownerPuppet) {
          return condition.Invert() ? true : false;
        };
      } else {
        if AIActionHelper.IsCurrentlyCrouching(ownerPuppet) {
          return condition.Invert() ? true : false;
        };
      };
    };
    if condition.HasAnyLastAvailableExposureMethods() != -1 {
      if condition.HasAnyLastAvailableExposureMethods() == 1 {
        if !AICoverHelper.HasAnyCoverLastAvailableExposureMethod(ownerPuppet) {
          return condition.Invert() ? true : false;
        };
      } else {
        if AICoverHelper.HasAnyCoverLastAvailableExposureMethod(ownerPuppet) {
          return condition.Invert() ? true : false;
        };
      };
    };
    coverExposureMethod = AICoverHelper.GetCoverExposureMethod(ownerPuppet);
    if IsNameValid(coverExposureMethod) && Equals(condition.Cover().Type(), gamedataAIActionTarget.CurrentCover) {
      exposureMethods = condition.CheckChosenExposureMethod();
      if ArraySize(exposureMethods) == 0 {
        return condition.Invert() ? false : true;
      };
      if !ArrayContains(exposureMethods, coverExposureMethod) {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIGoToCoverCond_Record>) -> Bool {
    let coverManager: ref<CoverManager>;
    let currentCoverID: Uint64;
    let desiredCoverID: Uint64;
    let target: wref<GameObject>;
    if !IsDefined(condition.Target()) || !AIActionTarget.GetObject(context, condition.Target(), target) {
      return false;
    };
    if condition.DesiredCoverChanged() != -1 {
      AIActionTarget.GetCoverID(context, condition.Cover(), currentCoverID);
      AIActionTarget.GetCoverID(context, condition.DesiredCover(), desiredCoverID);
      if condition.DesiredCoverChanged() == 1 {
        if currentCoverID == desiredCoverID {
          return condition.Invert() ? true : false;
        };
      } else {
        if currentCoverID != desiredCoverID {
          return condition.Invert() ? true : false;
        };
      };
    };
    coverManager = GameInstance.GetCoverManager(target.GetGame());
    if condition.IsCoverSelected() != -1 {
      if condition.DesiredCoverChanged() == -1 {
        AIActionTarget.GetCoverID(context, condition.DesiredCover(), desiredCoverID);
      };
      if condition.IsCoverSelected() == 1 {
        if desiredCoverID == 0u || !coverManager.IsCoverAvailable(desiredCoverID, target) {
          return condition.Invert() ? true : false;
        };
      } else {
        if desiredCoverID > 0u {
          return condition.Invert() ? true : false;
        };
      };
    };
    if condition.IsEnteringOrLeavingCover() >= 0 {
      if condition.IsEnteringOrLeavingCover() == 0 {
        if condition.Invert() {
          return coverManager.IsEnteringOrLeavingCover(target);
        };
        return !coverManager.IsEnteringOrLeavingCover(target);
      };
      if condition.IsEnteringOrLeavingCover() == 1 {
        if condition.Invert() {
          return !coverManager.IsEnteringOrLeavingCover(target);
        };
        return coverManager.IsEnteringOrLeavingCover(target);
      };
      if condition.IsEnteringOrLeavingCover() == 2 {
        if condition.Invert() {
          return NotEquals(coverManager.GetCoverActionType(target), AIUninterruptibleActionType.EnteringCover);
        };
        return Equals(coverManager.GetCoverActionType(target), AIUninterruptibleActionType.EnteringCover);
      };
      if condition.Invert() {
        return NotEquals(coverManager.GetCoverActionType(target), AIUninterruptibleActionType.LeavingCover);
      };
      return Equals(coverManager.GetCoverActionType(target), AIUninterruptibleActionType.LeavingCover);
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIValidCoversCond_Record>) -> Bool {
    let currentRing: gamedataAIRingType;
    let i: Int32;
    let j: Int32;
    let limitCoverCount: Int32;
    let limitToRing: wref<AIRingType_Record>;
    let msc: wref<MultiSelectCovers>;
    let res: Bool;
    let target: wref<GameObject>;
    if !IsDefined(condition.Target()) || !AIActionTarget.GetObject(context, condition.Target(), target) {
      return false;
    };
    msc = ScriptExecutionContext.GetArgumentScriptable(context, n"MultiCoverID") as MultiSelectCovers;
    if !IsDefined(msc) {
      return false;
    };
    currentRing = AISquadHelper.GetCurrentSquadRing(target as ScriptedPuppet);
    limitCoverCount = condition.GetLimitToRingsCount();
    if limitCoverCount > 0 && condition.CheckCurrentlyActiveRing() {
      i = 0;
      while i < limitCoverCount {
        limitToRing = condition.GetLimitToRingsItem(i);
        if Equals(limitToRing.Type(), currentRing) {
          res = true;
        } else {
          i += 1;
        };
      };
      if !res {
        return false;
      };
    };
    i = 0;
    while i < ArraySize(msc.selectedCovers) {
      if condition.CoversWithLOS() == 0 && msc.coversUseLOS[i] {
        if msc.coversUseLOS[i] {
        } else {
        };
      } else {
        if condition.CoversWithLOS() == 1 && !msc.coversUseLOS[i] {
        } else {
          if condition.CheckCurrentlyActiveRing() && NotEquals(currentRing, msc.coverRingTypes[i]) {
          } else {
            if limitCoverCount > 0 {
              res = false;
              j = 0;
              while j < limitCoverCount {
                limitToRing = condition.GetLimitToRingsItem(j);
                if Equals(limitToRing.Type(), msc.coverRingTypes[i]) {
                  res = true;
                };
                j += 1;
              };
              if !res {
              } else {
                if msc.selectedCovers[i] > 0u {
                  return condition.Invert() ? false : true;
                };
              };
            };
            if msc.selectedCovers[i] > 0u {
              return condition.Invert() ? false : true;
            };
          };
        };
      };
      i += 1;
    };
    return condition.Invert() ? true : false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIHitCond_Record>) -> Bool {
    let attackTag: CName;
    let cumulatedDamge: Float;
    let hitReactionComponent: ref<HitReactionComponent>;
    let lastHitType: Int32;
    let previousHitDelay: Float;
    let target: wref<GameObject>;
    let targetHitCount: Int32;
    let targetPuppet: wref<ScriptedPuppet>;
    if !IsDefined(condition.Target()) || !AIActionTarget.GetObject(context, condition.Target(), target) {
      return false;
    };
    targetPuppet = target as ScriptedPuppet;
    if !IsDefined(targetPuppet) {
      return false;
    };
    hitReactionComponent = targetPuppet.GetHitReactionComponent();
    previousHitDelay = EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())) - hitReactionComponent.GetLastHitTimeStamp();
    targetHitCount = condition.TargetHitCount();
    if targetHitCount > 0 {
      if hitReactionComponent.GetHitCountData(targetHitCount) < EngineTime.ToFloat(GameInstance.GetSimTime(targetPuppet.GetGame())) - condition.HitTimeout() {
        return condition.Invert() ? true : false;
      };
    } else {
      if hitReactionComponent.GetLastHitTimeStamp() <= 0.00 || previousHitDelay > condition.HitTimeout() {
        return condition.Invert() ? true : false;
      };
    };
    lastHitType = hitReactionComponent.GetHitReactionType();
    if condition.MinHitSeverity() > 0 && lastHitType < condition.MinHitSeverity() {
      return condition.Invert() ? true : false;
    };
    if condition.MaxHitSeverity() > 0 && lastHitType > condition.MaxHitSeverity() {
      return condition.Invert() ? true : false;
    };
    attackTag = hitReactionComponent.GetAttackTag();
    if NotEquals(condition.AttackTag(), n"") && NotEquals(condition.AttackTag(), attackTag) {
      return condition.Invert() ? true : false;
    };
    if condition.CumulatedDamageThreshold() > 0 {
      cumulatedDamge = targetPuppet.GetHitReactionComponent().GetCumulatedDamage();
      if cumulatedDamge <= Cast(condition.CumulatedDamageThreshold()) {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AITargetCond_Record>) -> Bool {
    let currentDetection: Float;
    let minDetection: Float;
    let target: wref<GameObject>;
    let trackedLocation: TrackedLocation;
    let trackedLocationSuccess: Bool;
    let visibilityCollisionToTargetDist: Float;
    if !IsDefined(condition.Target()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Target(), target) {
      return condition.Invert() ? true : false;
    };
    if condition.IsAlive() >= 0 {
      if condition.IsAlive() == 0 {
        if ScriptedPuppet.IsAlive(target) {
          return condition.Invert() ? true : false;
        };
      } else {
        if !ScriptedPuppet.IsAlive(target) {
          return condition.Invert() ? true : false;
        };
      };
    };
    if condition.IsActive() >= 0 {
      if condition.IsActive() == 0 {
        if ScriptedPuppet.IsActive(target) {
          return condition.Invert() ? true : false;
        };
      } else {
        if !ScriptedPuppet.IsActive(target) {
          return condition.Invert() ? true : false;
        };
      };
    };
    minDetection = condition.MinDetectionValue();
    if minDetection >= 0.00 {
      currentDetection = ScriptExecutionContext.GetOwner(context).GetSenses().GetDetection(target.GetEntityID());
      if currentDetection < minDetection * 100.00 {
        return condition.Invert() ? true : false;
      };
    };
    trackedLocationSuccess = TargetTrackingExtension.GetTrackedLocation(context, target, trackedLocation);
    if condition.MinAccuracyValue() >= 0.00 {
      if condition.MinAccuracyValue() == 0.00 && !trackedLocationSuccess || trackedLocation.accuracy < condition.MinAccuracyValue() {
        return condition.Invert() ? true : false;
      };
    };
    if condition.MinAccuracySharedValue() >= 0.00 {
      if condition.MinAccuracySharedValue() == 0.00 && !trackedLocationSuccess || trackedLocation.sharedAccuracy < condition.MinAccuracySharedValue() {
        return condition.Invert() ? true : false;
      };
    };
    if condition.IsVisible() >= 0 {
      if ScriptExecutionContext.GetOwner(context).GetSenses().IsAgentVisible(target) {
        if condition.IsVisible() == 0 {
          return condition.Invert() ? true : false;
        };
      } else {
        if condition.IsVisible() > 0 {
          return condition.Invert() ? true : false;
        };
      };
    };
    if condition.MaxVisibilityToTargetDistance() > 0.00 {
      if NotEquals(condition.IsCombatTargetVisibleFrom().Type(), gamedataAIAdditionalTraceType.Undefined) && (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).IsHumanoid() {
        visibilityCollisionToTargetDist = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetDistToTraceEndFromPosToMainTrackedObject(AIActionHelper.GetAdditionalTraceTypeValueFromTweakEnum(condition.IsCombatTargetVisibleFrom().Type()));
        if visibilityCollisionToTargetDist > condition.MaxVisibilityToTargetDistance() && visibilityCollisionToTargetDist < 1000000000.00 {
          return condition.Invert() ? true : false;
        };
      } else {
        visibilityCollisionToTargetDist = ScriptExecutionContext.GetOwner(context).GetSenses().GetVisibilityTraceEndToAgentDist(target);
        if visibilityCollisionToTargetDist > condition.MaxVisibilityToTargetDistance() && visibilityCollisionToTargetDist < 1000000000.00 {
          return condition.Invert() ? true : false;
        };
      };
    };
    if condition.InvalidExpectation() >= 0 {
      if !trackedLocationSuccess {
        return condition.Invert() ? true : false;
      };
      if condition.InvalidExpectation() == 0 {
        if trackedLocation.invalidExpectation {
          return condition.Invert() ? true : false;
        };
      } else {
        if !trackedLocation.invalidExpectation {
          return condition.Invert() ? true : false;
        };
      };
    };
    if condition.IsMoving() >= 0 {
      if !trackedLocationSuccess {
        return condition.Invert() ? true : false;
      };
      if condition.IsMoving() == 0 {
        if !Vector4.IsXYZFloatZero(trackedLocation.speed) {
          return condition.Invert() ? true : false;
        };
      } else {
        if Vector4.IsXYZFloatZero(trackedLocation.speed) {
          return condition.Invert() ? true : false;
        };
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIStateCond_Record>) -> Bool {
    let object: wref<GameObject>;
    if !IsDefined(condition.Target()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Target(), object) {
      return false;
    };
    if object == ScriptExecutionContext.GetOwner(context) {
      if AIActionChecks.CheckOwnerState(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, AIActionParams.GetOwnerStatesFromArray(condition.InStates()), condition.CheckAllTypes()) {
        return condition.Invert() ? false : true;
      };
      return condition.Invert() ? true : false;
    };
    if AIActionChecks.CheckTargetState(object as ScriptedPuppet, AIActionParams.GetTargetStatesFromArray(condition.InStates(), object), condition.CheckAllTypes()) {
      return condition.Invert() ? false : true;
    };
    return condition.Invert() ? true : false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIVehicleCond_Record>) -> Bool {
    let activeDriver: Bool;
    let activePassangers: Int32;
    let activePassangersRange: Vector2;
    let currentSpeed: Float;
    let desiredTags: array<CName>;
    let freeSlot: ref<VehicleSeat_Record>;
    let freeSlotCount: Int32;
    let i: Int32;
    let speedRange: Vector2;
    let vehicle: wref<VehicleObject>;
    let vehicleRecord: ref<Vehicle_Record>;
    let vehicleTags: array<CName>;
    if !IsDefined(condition.Vehicle()) {
      return false;
    };
    if !AIActionTarget.GetVehicleObject(context, condition.Vehicle(), vehicle) {
      return condition.Invert() ? true : false;
    };
    if vehicle.IsDestroyed() {
      return condition.Invert() ? true : false;
    };
    vehicleRecord = vehicle.GetRecord();
    if !IsDefined(vehicleRecord) {
      return false;
    };
    desiredTags = condition.HasTags();
    vehicleTags = vehicleRecord.Tags();
    i = 0;
    while i < ArraySize(desiredTags) {
      if !ArrayContains(vehicleTags, desiredTags[i]) {
        return condition.Invert() ? true : false;
      };
      i += 1;
    };
    freeSlotCount = condition.GetFreeSlotsCount();
    i = 0;
    while i < freeSlotCount {
      freeSlot = condition.GetFreeSlotsItem(i);
      if !VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, freeSlot.SeatName()) {
        return condition.Invert() ? true : false;
      };
      i += 1;
    };
    if condition.DriverCheck() >= 0 {
      activeDriver = VehicleComponent.HasActiveDriver(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle.GetEntityID());
      if condition.DriverCheck() == 0 && activeDriver {
        return condition.Invert() ? true : false;
      };
      if condition.DriverCheck() == 1 && !activeDriver {
        return condition.Invert() ? true : false;
      };
    };
    activePassangersRange = condition.ActivePassangers();
    if activePassangersRange.X > 0.00 || activePassangersRange.Y > 0.00 {
      if !VehicleComponent.GetNumberOfActivePassengers(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle.GetEntityID(), activePassangers) {
        return condition.Invert() ? true : false;
      };
      if activePassangersRange.X > 0.00 && Cast(activePassangers) < activePassangersRange.X {
        return condition.Invert() ? true : false;
      };
      if activePassangersRange.Y > 0.00 && Cast(activePassangers) > activePassangersRange.Y {
        return condition.Invert() ? true : false;
      };
    };
    speedRange = condition.CurrentSpeed();
    if speedRange.X > 0.00 || speedRange.Y > 0.00 {
      currentSpeed = vehicle.GetBlackboard().GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue);
      if speedRange.X > 0.00 && currentSpeed < speedRange.X {
        return condition.Invert() ? true : false;
      };
      if speedRange.Y > 0.00 && currentSpeed > speedRange.Y {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIDriverCond_Record>) -> Bool {
    if VehicleComponent.IsDriver(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context).GetEntityID()) {
      return condition.Invert() ? false : true;
    };
    return condition.Invert() ? true : false;
  }

  public final static func CheckAbility(const context: ScriptExecutionContext, ability: wref<GameplayAbility_Record>) -> Bool {
    let record: ref<IPrereq_Record>;
    let count: Int32 = ability.GetPrereqsForUseCount();
    let i: Int32 = 0;
    while i < count {
      record = ability.GetPrereqsForUseItem(i);
      if !IPrereq.CreatePrereq(record.GetID()).IsFulfilled(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIAbilityCond_Record>) -> Bool {
    let ability: wref<GameplayAbility_Record>;
    let j: Int32;
    let prereq: wref<IPrereq_Record>;
    let prereqCount: Int32;
    let abilitiesCount: Int32 = condition.GetAbilitiesCount();
    let i: Int32 = 0;
    while i < abilitiesCount {
      ability = condition.GetAbilitiesItem(i);
      prereqCount = ability.GetPrereqsForUseCount();
      j = 0;
      while j < prereqCount {
        prereq = ability.GetPrereqsForUseItem(j);
        if !IPrereq.CreatePrereq(prereq.GetID()).IsFulfilled(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
          return condition.Invert() ? true : false;
        };
        j += 1;
      };
      i += 1;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIInTacticPositionCond_Record>) -> Bool {
    return false;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIWorkspotCond_Record>) -> Bool {
    let coverID: Uint64;
    let coverManager: ref<CoverManager>;
    let globalRef: GlobalNodeRef;
    let inWorkspot: Bool;
    let workspotData: ref<WorkspotEntryData>;
    let workspotObject: wref<GameObject>;
    if IsDefined(condition.WorkspotObj()) {
      if !AIActionTarget.GetObject(context, condition.WorkspotObj(), workspotObject) {
        return false;
      };
      workspotData = workspotObject.GetFreeWorkspotDataForAIAction(gamedataWorkspotActionType.DeviceInvestigation);
      globalRef = ResolveNodeRef(workspotData.workspotRef, Cast(GlobalNodeID.GetRoot()));
      if !GlobalNodeRef.IsDefined(globalRef) {
        return condition.Invert() ? true : false;
      };
    };
    if condition.IsInWorkspot() != -1 {
      coverManager = GameInstance.GetCoverManager((ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetGame());
      if AIActionHelper.IsInWorkspot(ScriptExecutionContext.GetOwner(context)) && !AIActionTarget.GetCurrentCoverID(context, coverID) && !coverManager.IsEnteringOrLeavingCover(ScriptExecutionContext.GetOwner(context)) {
        inWorkspot = true;
      };
      if condition.IsInWorkspot() == 0 {
        if inWorkspot {
          return condition.Invert() ? true : false;
        };
      } else {
        if !inWorkspot {
          return condition.Invert() ? true : false;
        };
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AISecurityCond_Record>) -> Bool {
    let ownerPuppet: wref<ScriptedPuppet>;
    let securityAreaType: ESecurityAreaType;
    if condition.IsConnected() >= 0 {
      if condition.IsConnected() == 0 {
        if ScriptExecutionContext.GetOwner(context).IsConnectedToSecuritySystem() {
          return condition.Invert() ? true : false;
        };
      } else {
        if !ScriptExecutionContext.GetOwner(context).IsConnectedToSecuritySystem() {
          return condition.Invert() ? true : false;
        };
      };
    };
    if IsDefined(condition.AreaType()) {
      ownerPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
      securityAreaType = IntEnum(Cast(EnumValueFromName(n"ESecurityAreaType", condition.AreaType().EnumName())));
      if NotEquals(securityAreaType, ownerPuppet.GetDeterminatedSecurityAreaType()) {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIHasWeapon_Record>) -> Bool {
    let categoryCount: Int32;
    let itemRecord: wref<Item_Record>;
    let typeCount: Int32;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let item: wref<ItemObject> = GameInstance.GetTransactionSystem(puppet.GetGame()).GetItemInSlot(puppet, t"AttachmentSlots.WeaponRight");
    if NotEquals(condition.ItemTag(), n"") && !item.GetItemData().HasTag(condition.ItemTag()) {
      return condition.Invert() ? true : false;
    };
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item.GetItemID()));
    typeCount = condition.GetItemTypeCount();
    if typeCount > 0 {
      if !condition.ItemTypeContains(itemRecord.ItemType()) {
        return condition.Invert() ? true : false;
      };
    };
    categoryCount = condition.GetItemCategoryCount();
    if categoryCount > 0 {
      if !condition.ItemCategoryContains(itemRecord.ItemCategory()) {
        return condition.Invert() ? true : false;
      };
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AISquadCond_Record>) -> Bool {
    let count: Int32;
    let i: Int32;
    let squadInterface: ref<PuppetSquadInterface>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !AISquadHelper.GetSquadBaseInterface(puppet, squadInterface) {
      ScriptExecutionContext.DebugLog(context, n"tweakAI", "AISquadCond_Record: squad interface not found, most likely because gameplay component is overriden by custom in entity!!");
      return false;
    };
    count = condition.GetHasTicketsCount();
    i = 0;
    while i < count {
      if !squadInterface.HasOrderBySquadAction(condition.GetHasTicketsItem(i).EnumName(), puppet) {
        return condition.Invert() ? true : false;
      };
      i += 1;
    };
    count = condition.GetTicketsConditionCheckCount();
    i = 0;
    while i < count {
      if !squadInterface.CheckTicketConditions(condition.GetTicketsConditionCheckItem(i).EnumName(), puppet) {
        return condition.Invert() ? true : false;
      };
      i += 1;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AICommandCond_Record>) -> Bool {
    let aiComponent: ref<AIHumanComponent>;
    let count: Int32;
    let i: Int32;
    let object: wref<GameObject>;
    if !IsDefined(condition.Target()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Target(), object) {
      return false;
    };
    aiComponent = (object as ScriptedPuppet).GetAIControllerComponent();
    if !IsDefined(aiComponent) {
      return false;
    };
    count = condition.GetHasCommandsCount();
    i = 0;
    while i < count {
      if !aiComponent.IsCommandActive(condition.GetHasCommandsItem(i)) {
        return condition.Invert() ? true : false;
      };
      i += 1;
    };
    count = condition.GetHasNewOrOverridenCommandsCount();
    i = 0;
    while i < count {
      if !aiComponent.IsCommandReceivedOrOverriden(condition.GetHasNewOrOverridenCommandsItem(i)) {
        return condition.Invert() ? true : false;
      };
      i += 1;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AINPCTypeCond_Record>) -> Bool {
    let allowedNPCType: ref<NPCType_Record>;
    let count: Int32;
    let i: Int32;
    let object: wref<GameObject>;
    let targetPuppet: wref<ScriptedPuppet>;
    if !IsDefined(condition.Target()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Target(), object) {
      return false;
    };
    targetPuppet = object as ScriptedPuppet;
    if IsDefined(targetPuppet as PlayerPuppet) {
      return condition.Invert() ? true : false;
    };
    if condition.IsFollower() >= 0 {
      if Equals(targetPuppet.GetAIControllerComponent().GetAIRole().GetRoleEnum(), EAIRole.Follower) {
        if condition.IsFollower() == 0 {
          return condition.Invert() ? true : false;
        };
      } else {
        if condition.IsFollower() == 1 {
          return condition.Invert() ? true : false;
        };
      };
    };
    count = condition.GetAllowedNPCTypesCount();
    i = 0;
    while i < count {
      allowedNPCType = condition.GetAllowedNPCTypesItem(i);
      if Equals(allowedNPCType.Type(), gamedataNPCType.Any) || Equals(allowedNPCType.Type(), targetPuppet.GetNPCType()) {
        return condition.Invert() ? false : true;
      };
      i += 1;
    };
    return condition.Invert() ? true : false;
  }

  private final static func GetPuppetVelocity(puppet: wref<ScriptedPuppet>, timePeriod: Float) -> Vector4 {
    if timePeriod > 0.00 {
      return puppet.GetTransformHistoryComponent().GetVelocity(timePeriod);
    };
    return puppet.GetVelocity();
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIVelocityCond_Record>) -> Bool {
    let object: wref<GameObject>;
    let range: Vector2;
    let sqrRange: Vector2;
    let targetPuppet: wref<ScriptedPuppet>;
    let velocity: Vector4;
    let velocitySqrMag: Float;
    if !IsDefined(condition.Target()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.Target(), object) {
      return false;
    };
    targetPuppet = object as ScriptedPuppet;
    if !IsDefined(targetPuppet) {
      return false;
    };
    range = condition.Range();
    sqrRange.X = range.X * range.X;
    sqrRange.Y = range.Y * range.Y;
    velocity = AICondition.GetPuppetVelocity(targetPuppet, condition.TimePeriod());
    velocity.Z = 0.00;
    velocitySqrMag = Vector4.LengthSquared(velocity);
    if range.X >= 0.00 && velocitySqrMag < sqrRange.X || range.Y >= 0.00 && velocitySqrMag > sqrRange.Y {
      return condition.Invert() ? true : false;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIVelocityDotCond_Record>) -> Bool {
    let dot: Float;
    let dotRange: Vector2;
    let positionObject: wref<GameObject>;
    let velocity: Vector4;
    let velocityObject: wref<GameObject>;
    let velocityPuppet: wref<ScriptedPuppet>;
    if !IsDefined(condition.VelocityTarget()) || !IsDefined(condition.PositionTarget()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.VelocityTarget(), velocityObject) {
      return false;
    };
    velocityPuppet = velocityObject as ScriptedPuppet;
    if !IsDefined(velocityPuppet) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.PositionTarget(), positionObject) {
      return false;
    };
    dotRange = condition.DotRange();
    velocity = AICondition.GetPuppetVelocity(velocityPuppet, condition.TimePeriod());
    velocity = Vector4.Normalize2D(velocity);
    dot = Vector4.Dot2D(velocity, Vector4.Normalize(positionObject.GetWorldPosition() - velocityObject.GetWorldPosition()));
    if dot < dotRange.X || dot > dotRange.Y {
      return condition.Invert() ? true : false;
    };
    return condition.Invert() ? false : true;
  }

  public final static func Check(const context: ScriptExecutionContext, condition: wref<AIVelocitiesDotCond_Record>) -> Bool {
    let dot: Float;
    let dotRange: Vector2;
    let firstObject: wref<GameObject>;
    let firstPuppet: wref<ScriptedPuppet>;
    let firstTimePeriod: Float;
    let firstVelocity: Vector4;
    let secondObject: wref<GameObject>;
    let secondPuppet: wref<ScriptedPuppet>;
    let secondTimePeriod: Float;
    let secondVelocity: Vector4;
    if !IsDefined(condition.FirstTarget()) || !IsDefined(condition.SecondTarget()) {
      return false;
    };
    if !AIActionTarget.GetObject(context, condition.FirstTarget(), firstObject) {
      return false;
    };
    firstPuppet = firstObject as ScriptedPuppet;
    if !IsDefined(firstPuppet) {
      return false;
    };
    firstTimePeriod = condition.FirstTimePeriod();
    if firstTimePeriod >= 0.00 {
      firstVelocity = AICondition.GetPuppetVelocity(firstPuppet, condition.FirstTimePeriod());
      firstVelocity = Vector4.Normalize2D(firstVelocity);
    } else {
      firstVelocity = firstPuppet.GetWorldForward();
    };
    if !AIActionTarget.GetObject(context, condition.SecondTarget(), secondObject) {
      return false;
    };
    secondPuppet = secondObject as ScriptedPuppet;
    if !IsDefined(secondPuppet) {
      return false;
    };
    secondTimePeriod = condition.SecondTimePeriod();
    if secondTimePeriod >= 0.00 {
      secondVelocity = AICondition.GetPuppetVelocity(secondPuppet, condition.SecondTimePeriod());
      secondVelocity = Vector4.Normalize2D(secondVelocity);
    } else {
      secondVelocity = secondPuppet.GetWorldForward();
    };
    dotRange = condition.DotRange();
    dot = Vector4.Dot2D(firstVelocity, secondVelocity);
    if dot < dotRange.X || dot > dotRange.Y {
      return condition.Invert() ? true : false;
    };
    return condition.Invert() ? false : true;
  }
}
