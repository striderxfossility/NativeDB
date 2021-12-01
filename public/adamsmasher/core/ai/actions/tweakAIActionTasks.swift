
public abstract class TweakAIActionRecord extends IScriptable {

  public final static func GetFriendlyName(record: TweakDBID, nodeName: String) -> String {
    let actionName: String;
    if IsFinal() {
      actionName = "NoStringDebugInFinal =(";
    } else {
      if TweakAIActionRecord.GetDebugActionNameFromRecord(record, actionName) {
        return "Archetype" + nodeName + ":  \'\'" + actionName + "\'\' ";
      };
    };
    return nodeName + ":  \'\'" + actionName + "\'\' ";
  }

  public final static func GetDebugActionNameFromRecord(record: TweakDBID, out debugStringName: String) -> Bool {
    let actionName: TweakDBID;
    if AIScriptUtils.GetActionNameFromRecord(record, actionName) {
      debugStringName = TDBID.ToStringDEBUG(actionName);
      return true;
    };
    debugStringName = TDBID.ToStringDEBUG(record);
    return false;
  }

  public final static func GetHeldItemType(const context: ScriptExecutionContext, out heldItemType: gamedataItemType) -> Bool {
    let item: wref<ItemObject>;
    let owner: ref<gamePuppet> = ScriptExecutionContext.GetOwner(context);
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(owner.GetGame());
    if !IsDefined(ts) {
      return false;
    };
    item = ts.GetItemInSlot(owner, t"AttachmentSlots.WeaponRight");
    if !IsDefined(item) {
      item = ts.GetItemInSlot(owner, t"AttachmentSlots.WeaponLeft");
    };
    if !IsDefined(item) {
      return false;
    };
    heldItemType = item.GetItemData().GetItemType();
    return true;
  }

  public final static func IsArchetypeAction(record: TweakDBID) -> Bool {
    return AIScriptUtils.IsArchetypeAction(record);
  }

  public final static func GetActionRecord(const context: ScriptExecutionContext, actionID: TweakDBID, out actionDebugName: String, out actionRecord: wref<AIAction_Record>) -> Bool {
    let record: ref<AIRecord_Record>;
    if !ScriptExecutionContext.GetOverriddenNode(context, actionID, record, true) {
      return false;
    };
    if IsDefined(record) {
      actionID = record.GetID();
    };
    if !IsFinal() {
      actionDebugName = TDBID.ToStringDEBUG(actionID);
    };
    actionRecord = record as AIAction_Record;
    return actionRecord != null;
  }

  public final static func GetSelectorRecord(const context: ScriptExecutionContext, selectorID: TweakDBID, out selectorDebugName: String, out selectorRecord: wref<AIActionSelector_Record>) -> Bool {
    let record: ref<AIRecord_Record>;
    if !ScriptExecutionContext.GetOverriddenNode(context, selectorID, record, true) {
      return false;
    };
    selectorID = record.GetID();
    if !IsFinal() {
      selectorDebugName = TDBID.ToStringDEBUG(selectorID);
    };
    selectorRecord = record as AIActionSelector_Record;
    return selectorRecord != null;
  }

  public final static func GetSequenceRecord(const context: ScriptExecutionContext, sequenceID: TweakDBID, out sequenceDebugName: String, out sequenceRecord: wref<AIActionSequence_Record>) -> Bool {
    let record: ref<AIRecord_Record>;
    if !ScriptExecutionContext.GetOverriddenNode(context, sequenceID, record, true) {
      return false;
    };
    sequenceID = record.GetID();
    if !IsFinal() {
      sequenceDebugName = TDBID.ToStringDEBUG(sequenceID);
    };
    sequenceRecord = record as AIActionSequence_Record;
    return sequenceRecord != null;
  }

  public final static func GetSmartCompositeRecord(const context: ScriptExecutionContext, smartCompositeID: TweakDBID, out smartCompositeDebugName: String, out smartCompositeRecord: wref<AIActionSmartComposite_Record>) -> Bool {
    let record: ref<AIRecord_Record>;
    if !ScriptExecutionContext.GetOverriddenNode(context, smartCompositeID, record, true) {
      return false;
    };
    smartCompositeID = record.GetID();
    if !IsFinal() {
      smartCompositeDebugName = TDBID.ToStringDEBUG(smartCompositeID);
    };
    smartCompositeRecord = record as AIActionSmartComposite_Record;
    return smartCompositeRecord != null;
  }

  public final static func GetActionRecordFromSelector(const context: ScriptExecutionContext, selectorRecord: wref<AIActionSelector_Record>, out actionDebugName: String, out actionRecord: wref<AIAction_Record>, out nodeIterator: Int32, out shouldCallAgain: Bool) -> Bool {
    let alternativesLimit: Uint32;
    let alternativesLimitEnabled: Bool;
    let count: Int32;
    let player: ref<PlayerPuppet>;
    let playerInCombat: Bool;
    let limitCount: Uint32 = 0u;
    if !IsDefined(selectorRecord) {
      return false;
    };
    player = GetPlayer(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(player) {
      playerInCombat = player.IsInCombat();
    };
    alternativesLimitEnabled = ScriptExecutionContext.GetTweakActionSystem(context).IsTweakCompositeAlternativesLimitEnabled(context, playerInCombat);
    alternativesLimit = ScriptExecutionContext.GetTweakActionSystem(context).GetTweakCompositeAlternativesLimit(context);
    count = selectorRecord.GetActionsCount();
    if nodeIterator >= count {
      nodeIterator = 0;
    };
    while nodeIterator < count {
      if !selectorRecord.DisableActionsLimit() && alternativesLimitEnabled && limitCount >= alternativesLimit {
        shouldCallAgain = true;
        return false;
      };
      actionRecord = selectorRecord.GetActionsItem(nodeIterator);
      if !IsDefined(actionRecord) {
        nodeIterator += 1;
        limitCount += 1u;
      } else {
        if !TweakAIActionRecord.GetActionRecord(context, actionRecord.GetID(), actionDebugName, actionRecord) {
          return false;
        };
        if AICondition.ActivationCheck(context, actionRecord) {
          return true;
        };
        nodeIterator += 1;
        limitCount += 1u;
      };
    };
    actionRecord = selectorRecord.DefaultAction();
    if IsDefined(actionRecord) {
      nodeIterator = -1;
      if !TweakAIActionRecord.GetActionRecord(context, actionRecord.GetID(), actionDebugName, actionRecord) {
        return false;
      };
      return true;
    };
    return false;
  }

  public final static func IsThisLastActionInSelector(selectorRecord: wref<AIActionSelector_Record>, const nodeIterator: Int32) -> Bool {
    let count: Int32;
    if !IsDefined(selectorRecord) {
      return false;
    };
    if nodeIterator < 0 {
      return true;
    };
    count = selectorRecord.GetActionsCount();
    return nodeIterator >= count - 1;
  }

  public final static func GetActionRecordFromSequence(const context: ScriptExecutionContext, sequenceRecord: wref<AIActionSequence_Record>, out actionDebugName: String, out actionRecord: wref<AIAction_Record>, out sequenceIterator: Int32, out shouldCallAgain: Bool) -> Bool {
    let alternativesLimit: Uint32;
    let alternativesLimitEnabled: Bool;
    let count: Int32;
    let player: ref<PlayerPuppet>;
    let playerInCombat: Bool;
    let limitCount: Uint32 = 0u;
    if !IsDefined(sequenceRecord) {
      return false;
    };
    player = GetPlayer(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(player) {
      playerInCombat = player.IsInCombat();
    };
    alternativesLimitEnabled = ScriptExecutionContext.GetTweakActionSystem(context).IsTweakCompositeAlternativesLimitEnabled(context, playerInCombat);
    alternativesLimit = ScriptExecutionContext.GetTweakActionSystem(context).GetTweakCompositeAlternativesLimit(context);
    count = sequenceRecord.GetActionsCount();
    if sequenceIterator >= count {
      sequenceIterator = 0;
    };
    while sequenceIterator < count {
      if !sequenceRecord.DisableActionsLimit() && alternativesLimitEnabled && limitCount >= alternativesLimit {
        shouldCallAgain = true;
        return false;
      };
      actionRecord = sequenceRecord.GetActionsItem(sequenceIterator);
      if !IsDefined(actionRecord) {
        sequenceIterator += 1;
        limitCount += 1u;
      } else {
        if !TweakAIActionRecord.GetActionRecord(context, actionRecord.GetID(), actionDebugName, actionRecord) {
          return false;
        };
        if AICondition.ActivationCheck(context, actionRecord) {
          return true;
        };
        sequenceIterator += 1;
        limitCount += 1u;
      };
    };
    actionRecord = null;
    return false;
  }

  public final static func IsThisLastActionInSequence(sequenceRecord: wref<AIActionSequence_Record>, const sequenceIterator: Int32) -> Bool {
    let count: Int32;
    if !IsDefined(sequenceRecord) {
      return false;
    };
    count = sequenceRecord.GetActionsCount();
    return sequenceIterator >= count - 1;
  }

  public final static func IsThisLastActionInSmartComposite(smartCompositeRecord: wref<AIActionSmartComposite_Record>, const iterator: Int32) -> Bool {
    let count: Int32;
    if !IsDefined(smartCompositeRecord) {
      return false;
    };
    count = smartCompositeRecord.GetNodesCount();
    return iterator >= count - 1;
  }

  public final static func IsSmartCompositeASequence(smartCompositeRecord: wref<AIActionSmartComposite_Record>) -> Bool {
    let type: gamedataAISmartCompositeType = gamedataAISmartCompositeType.Invalid;
    type = smartCompositeRecord.Type().Type();
    if Equals(type, gamedataAISmartCompositeType.Sequence) {
      return true;
    };
    if Equals(type, gamedataAISmartCompositeType.SequenceWithMemory) {
      return true;
    };
    if Equals(type, gamedataAISmartCompositeType.SequenceWithSmartMemory) {
      return true;
    };
    return false;
  }

  public final static func IsSmartCompositeASelector(smartCompositeRecord: wref<AIActionSmartComposite_Record>) -> Bool {
    let type: gamedataAISmartCompositeType = gamedataAISmartCompositeType.Invalid;
    type = smartCompositeRecord.Type().Type();
    if Equals(type, gamedataAISmartCompositeType.Selector) {
      return true;
    };
    if Equals(type, gamedataAISmartCompositeType.SelectorWithMemory) {
      return true;
    };
    if Equals(type, gamedataAISmartCompositeType.SelectorWithSmartMemory) {
      return true;
    };
    return false;
  }
}

public class TweakAIAction extends TweakAIActionAbstract {

  @attrib(customEditor, "TweakDBGroupInheritance;AIAction")
  public edit let m_record: TweakDBID;

  private func GetActionRecord(const context: ScriptExecutionContext, out actionDebugName: String, out actionRecord: wref<AIAction_Record>, out shouldCallAgain: Bool) -> Bool {
    return TweakAIActionRecord.GetActionRecord(context, this.m_record, actionDebugName, actionRecord);
  }

  public final func GetFriendlyName() -> String {
    if IsDefined(TweakDBInterface.GetAIActionRecord(this.m_record)) {
      return TweakAIActionRecord.GetFriendlyName(this.m_record, "Action");
    };
    return TweakAIActionRecord.GetFriendlyName(this.m_record, " [INVALID] Action");
  }
}

public class TweakAIActionCondition extends TweakAIActionConditionAbstract {

  @attrib(customEditor, "TweakDBGroupInheritance;AIAction")
  public edit let m_record: TweakDBID;

  private func GetActionRecord(const context: ScriptExecutionContext, out actionDebugName: String, out actionRecord: wref<AIAction_Record>) -> Bool {
    return TweakAIActionRecord.GetActionRecord(context, this.m_record, actionDebugName, actionRecord);
  }

  public final func GetFriendlyName() -> String {
    if IsDefined(TweakDBInterface.GetAIActionRecord(this.m_record)) {
      return TweakAIActionRecord.GetFriendlyName(this.m_record, "Condition");
    };
    return TweakAIActionRecord.GetFriendlyName(this.m_record, " [INVALID] Condition");
  }
}

public class TweakAIActionSelector extends TweakAIActionAbstract {

  @attrib(customEditor, "TweakDBGroupInheritance;AIActionSelector")
  public edit let m_selector: TweakDBID;

  public let m_selectorRecord: wref<AIActionSelector_Record>;

  public let m_nodeIterator: Int32;

  private func GetActionRecord(const context: ScriptExecutionContext, out actionDebugName: String, out actionRecord: wref<AIAction_Record>, out shouldCallAgain: Bool) -> Bool {
    let selectorRecord: wref<AIActionSelector_Record>;
    if !TweakAIActionRecord.GetSelectorRecord(context, this.m_selector, actionDebugName, selectorRecord) {
      LogAIError("No SelectorRecord found with ID: " + actionDebugName);
      return false;
    };
    if selectorRecord != this.m_selectorRecord {
      this.m_nodeIterator = 0;
      this.m_selectorRecord = selectorRecord;
    };
    return TweakAIActionRecord.GetActionRecordFromSelector(context, this.m_selectorRecord, actionDebugName, actionRecord, this.m_nodeIterator, shouldCallAgain);
  }

  public final func GetFriendlyName() -> String {
    if IsDefined(TweakDBInterface.GetAIActionSelectorRecord(this.m_selector)) {
      return TweakAIActionRecord.GetFriendlyName(this.m_selector, "Selector");
    };
    return TweakAIActionRecord.GetFriendlyName(this.m_selector, " [INVALID] Selector");
  }

  private func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let result: AIbehaviorUpdateOutcome;
    if !this.RetryGetActionRecord(context) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    switch this.Update(context) {
      case AIbehaviorUpdateOutcome.FAILURE:
        result = this.RunNextAction(context);
        if Equals(result, AIbehaviorUpdateOutcome.SUCCESS) {
          return AIbehaviorUpdateOutcome.IN_PROGRESS;
        };
        return result;
      case AIbehaviorUpdateOutcome.SUCCESS:
        return AIbehaviorUpdateOutcome.SUCCESS;
      default:
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void {
    this.Deactivate(context);
    this.m_nodeIterator = 0;
  }

  private final func RunNextAction(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    if TweakAIActionRecord.IsThisLastActionInSelector(this.m_selectorRecord, this.m_nodeIterator) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    this.m_nodeIterator += 1;
    this.Deactivate(context);
    this.Activate(context);
    if this.VerifyActionRecord() {
      return this.Update(context);
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class TweakAIActionSequence extends TweakAIActionAbstract {

  @attrib(customEditor, "TweakDBGroupInheritance;AIActionSequence")
  public edit let m_sequence: TweakDBID;

  private let m_sequenceRecord: wref<AIActionSequence_Record>;

  private let m_sequenceIterator: Int32;

  private func GetActionRecord(const context: ScriptExecutionContext, out actionDebugName: String, out actionRecord: wref<AIAction_Record>, out shouldCallAgain: Bool) -> Bool {
    let sequenceRecord: wref<AIActionSequence_Record>;
    if !TweakAIActionRecord.GetSequenceRecord(context, this.m_sequence, actionDebugName, sequenceRecord) {
      LogAIError("No SequenceRecord found with ID: " + actionDebugName);
      this.ResetSequence();
      return false;
    };
    if sequenceRecord != this.m_sequenceRecord {
      this.ResetSequence();
      this.m_sequenceRecord = sequenceRecord;
    };
    return TweakAIActionRecord.GetActionRecordFromSequence(context, this.m_sequenceRecord, actionDebugName, actionRecord, this.m_sequenceIterator, shouldCallAgain);
  }

  public final func GetFriendlyName() -> String {
    if IsDefined(TweakDBInterface.GetAIActionSequenceRecord(this.m_sequence)) {
      return TweakAIActionRecord.GetFriendlyName(this.m_sequence, "Sequence");
    };
    return TweakAIActionRecord.GetFriendlyName(this.m_sequence, " [INVALID] Sequence");
  }

  private func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let result: AIbehaviorUpdateOutcome;
    if !this.RetryGetActionRecord(context) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    switch this.Update(context) {
      case AIbehaviorUpdateOutcome.FAILURE:
        this.ResetSequence();
        return AIbehaviorUpdateOutcome.FAILURE;
      case AIbehaviorUpdateOutcome.SUCCESS:
        result = this.RunNextAction(context);
        if Equals(result, AIbehaviorUpdateOutcome.FAILURE) {
          return AIbehaviorUpdateOutcome.IN_PROGRESS;
        };
        return result;
      default:
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void {
    this.Deactivate(context);
    if !IsDefined(this.m_sequenceRecord) || !this.m_sequenceRecord.HasMemory() {
      this.ResetSequence();
    };
  }

  private final func ResetSequence() -> Void {
    this.m_sequenceIterator = 0;
  }

  private final func RunNextAction(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    if TweakAIActionRecord.IsThisLastActionInSequence(this.m_sequenceRecord, this.m_sequenceIterator) {
      this.ResetSequence();
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    this.m_sequenceIterator += 1;
    this.Deactivate(context);
    this.Activate(context);
    if this.VerifyActionRecord() {
      return this.Update(context);
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class TweakAIActionSmartComposite extends TweakAIActionAbstract {

  @attrib(customEditor, "TweakDBGroupInheritance;AIActionSmartComposite")
  public edit let m_smartComposite: TweakDBID;

  private let m_smartCompositeRecord: wref<AIActionSmartComposite_Record>;

  private let m_interruptionRequested: Bool;

  private let m_conditionSuccessfulCheckTimeStamp: Float;

  private let m_conditionCheckTimeStamp: Float;

  private let m_conditionCheckRandomizedInterval: Float;

  private let m_iteration: Uint32;

  private let m_nodeIterator: Int32;

  private let m_currentNodeIterator: Int32;

  private let m_currentNodeType: ETweakAINodeType;

  private let m_currentNode: wref<AINode_Record>;

  private final func ResetComposite() -> Void {
    this.ResetNodeIterator();
    this.m_interruptionRequested = false;
    this.m_gracefullyInterrupted = false;
    this.m_iteration = 0u;
    this.m_conditionSuccessfulCheckTimeStamp = 0.00;
    this.m_currentNode = null;
  }

  public func GetSmartCompositeRecord(const context: ScriptExecutionContext, smartCompositeID: TweakDBID, out smartCompositeStringName: String, out smartCompositeRecord: wref<AIActionSmartComposite_Record>) -> Bool {
    return TweakAIActionRecord.GetSmartCompositeRecord(context, smartCompositeID, smartCompositeStringName, smartCompositeRecord);
  }

  private func GetActionRecord(const context: ScriptExecutionContext, out actionDebugName: String, out actionRecord: wref<AIAction_Record>, out shouldCallAgain: Bool) -> Bool {
    let alternativesLimit: Uint32;
    let alternativesLimitEnabled: Bool;
    let debugName: String;
    let nodeCount: Int32;
    let owner: ref<gamePuppet>;
    let player: ref<PlayerPuppet>;
    let playerInCombat: Bool;
    let selectorRecord: wref<AIActionSelector_Record>;
    let sequenceRecord: wref<AIActionSequence_Record>;
    let smartCompositeRecord: wref<AIActionSmartComposite_Record>;
    let limitCounter: Uint32 = 0u;
    let tempBool: Bool = false;
    if !this.GetSmartCompositeRecord(context, this.m_smartComposite, actionDebugName, smartCompositeRecord) {
      LogAIError("No SmartCompositeRecord found with ID: " + actionDebugName);
      return false;
    };
    owner = ScriptExecutionContext.GetOwner(context);
    player = GetPlayer(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(player) {
      playerInCombat = player.IsInCombat();
    };
    alternativesLimitEnabled = ScriptExecutionContext.GetTweakActionSystem(context).IsTweakCompositeAlternativesLimitEnabled(context, playerInCombat);
    alternativesLimit = ScriptExecutionContext.GetTweakActionSystem(context).GetTweakCompositeAlternativesLimit(context);
    if smartCompositeRecord != this.m_smartCompositeRecord {
      this.m_smartCompositeRecord = smartCompositeRecord;
      this.ResetComposite();
    };
    nodeCount = this.m_smartCompositeRecord.GetNodesCount();
    if nodeCount == 0 {
      LogAIError("SmartCompositeRecord with ID: " + actionDebugName + " has no nodes!!!");
      return false;
    };
    while this.m_nodeIterator < nodeCount {
      if !smartCompositeRecord.DisableActionsLimit() && alternativesLimitEnabled && limitCounter >= alternativesLimit {
        shouldCallAgain = true;
        return false;
      };
      this.m_currentNode = this.m_smartCompositeRecord.GetNodesItem(this.m_nodeIterator);
      actionRecord = this.m_currentNode as AIAction_Record;
      if IsDefined(actionRecord) {
        if !TweakAIActionRecord.GetActionRecord(context, actionRecord.GetID(), actionDebugName, actionRecord) {
          return false;
        };
        this.m_currentNodeType = ETweakAINodeType.Action;
        if AICondition.ActivationCheck(context, actionRecord) {
          return true;
        };
        this.IncrementNodeIterator();
        limitCounter += 1u;
      } else {
        if !IsFinal() {
          debugName = TDBID.ToStringDEBUG(this.m_smartCompositeRecord.GetID());
          if AIActionHelper.ActionDebugHelper("", owner, debugName) {
            LogAI("SmartComposite GetActionRecord Debug Breakpoint");
          };
        };
        selectorRecord = this.m_currentNode as AIActionSelector_Record;
        if IsDefined(selectorRecord) {
          if !TweakAIActionRecord.GetSelectorRecord(context, selectorRecord.GetID(), actionDebugName, selectorRecord) {
            return false;
          };
          if !IsFinal() {
            debugName = TDBID.ToStringDEBUG(selectorRecord.GetID());
            if AIActionHelper.ActionDebugHelper("", owner, debugName) {
              LogAI("SmartComposite GetActionRecord Debug Breakpoint");
            };
          };
          if !IsDefined(selectorRecord.ActivationCondition()) || AICondition.CheckActionCondition(context, selectorRecord.ActivationCondition()) {
            this.m_currentNodeType = ETweakAINodeType.Selector;
            tempBool = TweakAIActionRecord.GetActionRecordFromSelector(context, selectorRecord, actionDebugName, actionRecord, this.m_currentNodeIterator, shouldCallAgain);
            if shouldCallAgain {
              return false;
            };
            if !tempBool {
              if TweakAIActionRecord.IsSmartCompositeASelector(this.m_smartCompositeRecord) {
                this.IncrementNodeIterator();
                limitCounter += 1u;
              } else {
                return false;
              };
            };
          } else {
            if this.m_smartCompositeRecord.FailOnNodeActivationConditionFailure() || selectorRecord.FailOnNodeActivationConditionFailure() {
              return false;
            };
            this.IncrementNodeIterator();
            limitCounter += 1u;
          };
        } else {
          sequenceRecord = this.m_currentNode as AIActionSequence_Record;
          if IsDefined(sequenceRecord) {
            if !TweakAIActionRecord.GetSequenceRecord(context, sequenceRecord.GetID(), actionDebugName, sequenceRecord) {
              return false;
            };
            if !IsFinal() {
              debugName = TDBID.ToStringDEBUG(sequenceRecord.GetID());
              if AIActionHelper.ActionDebugHelper("", owner, debugName) {
                LogAI("SmartComposite GetActionRecord Debug Breakpoint");
              };
              if AIActionHelper.ActionDebugHelper(owner, debugName) {
                LogAI("AICondition Debug Breakpoint");
              };
            };
            if Equals(this.m_currentNodeType, ETweakAINodeType.Sequence) && this.m_currentNodeIterator > 0 {
              tempBool = TweakAIActionRecord.GetActionRecordFromSequence(context, sequenceRecord, actionDebugName, actionRecord, this.m_currentNodeIterator, shouldCallAgain);
              if shouldCallAgain {
                return false;
              };
              if !tempBool {
                if TweakAIActionRecord.IsSmartCompositeASequence(this.m_smartCompositeRecord) {
                  this.IncrementNodeIterator();
                  limitCounter += 1u;
                } else {
                  return false;
                };
              };
            } else {
              if !IsDefined(sequenceRecord.ActivationCondition()) || AICondition.CheckActionCondition(context, sequenceRecord.ActivationCondition()) {
                this.m_currentNodeType = ETweakAINodeType.Sequence;
                tempBool = TweakAIActionRecord.GetActionRecordFromSequence(context, sequenceRecord, actionDebugName, actionRecord, this.m_currentNodeIterator, shouldCallAgain);
                if shouldCallAgain {
                  return false;
                };
                if !tempBool {
                  if TweakAIActionRecord.IsSmartCompositeASelector(this.m_smartCompositeRecord) {
                    this.IncrementNodeIterator();
                    limitCounter += 1u;
                  } else {
                    return false;
                  };
                };
              } else {
                if this.m_smartCompositeRecord.FailOnNodeActivationConditionFailure() || sequenceRecord.FailOnNodeActivationConditionFailure() {
                  return false;
                };
                this.IncrementNodeIterator();
                limitCounter += 1u;
              };
            };
          } else {
            return actionRecord != null;
          };
        };
      };
    };
    return false;
  }

  private final func RandomizeGracefulInterruptionConditionCheckInterval() -> Void {
    let randomCheckIntervalMods: array<Float>;
    this.m_conditionCheckRandomizedInterval = 0.00;
    if this.m_smartCompositeRecord.GetGracefulInterruptionConditionCount() > 0 && this.m_smartCompositeRecord.GracefulInterruptionConditionCheckInterval() > 0.00 {
      ArrayResize(randomCheckIntervalMods, 3);
      randomCheckIntervalMods[0] = 0.00;
      randomCheckIntervalMods[1] = 0.03;
      randomCheckIntervalMods[2] = 0.07;
      this.m_conditionCheckRandomizedInterval = this.m_smartCompositeRecord.GracefulInterruptionConditionCheckInterval();
      this.m_conditionCheckRandomizedInterval += randomCheckIntervalMods[RandRange(0, 3)];
    };
  }

  public func GetFriendlyName() -> String {
    if IsDefined(TweakDBInterface.GetAIActionSmartCompositeRecord(this.m_smartComposite)) {
      return TweakAIActionRecord.GetFriendlyName(this.m_smartComposite, "SmartComposite");
    };
    return TweakAIActionRecord.GetFriendlyName(this.m_smartComposite, " [INVALID] SmartComposite");
  }

  protected final func CheckGracefulInterruptionConditions(const context: ScriptExecutionContext) -> Bool {
    let count: Int32 = this.m_smartCompositeRecord.GetGracefulInterruptionConditionCount();
    let i: Int32 = 0;
    while i < count {
      if AICondition.CheckActionCondition(context, this.m_smartCompositeRecord.GetGracefulInterruptionConditionItem(i)) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    if !this.RetryGetActionRecord(context) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if !IsDefined(this.m_smartCompositeRecord) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !this.m_interruptionRequested {
      if this.m_conditionCheckRandomizedInterval <= 0.00 || this.m_conditionCheckRandomizedInterval > 0.00 && AIBehaviorScriptBase.GetAITime(context) >= this.m_conditionCheckTimeStamp + this.m_conditionCheckRandomizedInterval {
        if this.CheckGracefulInterruptionConditions(context) {
          if this.m_smartCompositeRecord.ConditionSuccessDuration() > 0.00 && this.m_conditionSuccessfulCheckTimeStamp < 0.00 {
            this.m_conditionSuccessfulCheckTimeStamp = AIBehaviorScriptBase.GetAITime(context);
          };
          if this.m_smartCompositeRecord.ConditionSuccessDuration() <= 0.00 || this.m_smartCompositeRecord.ConditionSuccessDuration() > 0.00 && AIBehaviorScriptBase.GetAITime(context) >= this.m_conditionSuccessfulCheckTimeStamp + this.m_smartCompositeRecord.ConditionSuccessDuration() {
            this.m_interruptionRequested = this.RequestGracefulInterruption(context);
            if this.m_interruptionRequested {
              this.m_gracefullyInterrupted = true;
            };
          };
        } else {
          this.m_conditionSuccessfulCheckTimeStamp = -1.00;
        };
        this.m_conditionCheckTimeStamp = AIBehaviorScriptBase.GetAITime(context);
      };
    };
    switch this.Update(context) {
      case AIbehaviorUpdateOutcome.FAILURE:
        if Equals(this.m_currentNodeType, ETweakAINodeType.Selector) {
          if this.RunCurrentNodeNextAction(context) {
            return AIbehaviorUpdateOutcome.IN_PROGRESS;
          };
        };
        if TweakAIActionRecord.IsSmartCompositeASelector(this.m_smartCompositeRecord) && this.RunNextNode(context) {
          return AIbehaviorUpdateOutcome.IN_PROGRESS;
        };
        this.ResetNodeIterator();
        return AIbehaviorUpdateOutcome.FAILURE;
      case AIbehaviorUpdateOutcome.SUCCESS:
        if this.m_interruptionRequested {
          return AIbehaviorUpdateOutcome.SUCCESS;
        };
        if Equals(this.m_currentNodeType, ETweakAINodeType.Sequence) && this.RunCurrentNodeNextAction(context) {
          return AIbehaviorUpdateOutcome.IN_PROGRESS;
        };
        if TweakAIActionRecord.IsSmartCompositeASequence(this.m_smartCompositeRecord) && this.RunNextNode(context) {
          return AIbehaviorUpdateOutcome.IN_PROGRESS;
        };
        return this.RepeatComposite(context);
      default:
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private func Deactivate(context: ScriptExecutionContext) -> Void {
    this.m_interruptionRequested = false;
    this.m_iteration = 0u;
    this.m_currentNodeIterator = 0;
    if !IsDefined(this.m_smartCompositeRecord) || !this.m_smartCompositeRecord.Type().HasMemory() {
      this.ResetNodeIterator();
    } else {
      if this.m_smartCompositeRecord.Type().IncrementIteratorOnDeactivation() {
        if TweakAIActionRecord.IsThisLastActionInSmartComposite(this.m_smartCompositeRecord, this.m_nodeIterator) {
          this.ResetNodeIterator();
        } else {
          this.IncrementNodeIterator();
        };
      };
    };
    this.Deactivate(context);
    this.m_gracefullyInterrupted = false;
  }

  private final func RepeatComposite(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    this.m_iteration += 1u;
    if this.m_smartCompositeRecord.Repeat() < 0 || this.m_iteration == Cast(this.m_smartCompositeRecord.Repeat()) {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    this.Deactivate(context);
    this.ResetNodeIterator();
    this.Activate(context);
    if this.VerifyActionRecord() {
      switch this.Update(context) {
        case AIbehaviorUpdateOutcome.FAILURE:
          if Equals(this.m_currentNodeType, ETweakAINodeType.Selector) {
            if this.RunCurrentNodeNextAction(context) {
              return AIbehaviorUpdateOutcome.IN_PROGRESS;
            };
          };
          if TweakAIActionRecord.IsSmartCompositeASelector(this.m_smartCompositeRecord) && this.RunNextNode(context) {
            return AIbehaviorUpdateOutcome.IN_PROGRESS;
          };
          this.ResetNodeIterator();
          return AIbehaviorUpdateOutcome.FAILURE;
        case AIbehaviorUpdateOutcome.SUCCESS:
          if this.m_interruptionRequested {
            return AIbehaviorUpdateOutcome.SUCCESS;
          };
          if Equals(this.m_currentNodeType, ETweakAINodeType.Sequence) && this.RunCurrentNodeNextAction(context) {
            return AIbehaviorUpdateOutcome.IN_PROGRESS;
          };
          if TweakAIActionRecord.IsSmartCompositeASequence(this.m_smartCompositeRecord) && this.RunNextNode(context) {
            return AIbehaviorUpdateOutcome.IN_PROGRESS;
          };
          return AIbehaviorUpdateOutcome.IN_PROGRESS;
        default:
      };
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    return AIbehaviorUpdateOutcome.FAILURE;
  }

  private final func RunNextNode(context: ScriptExecutionContext) -> Bool {
    if TweakAIActionRecord.IsThisLastActionInSmartComposite(this.m_smartCompositeRecord, this.m_nodeIterator) {
      return false;
    };
    this.Deactivate(context);
    this.IncrementNodeIterator();
    this.Activate(context);
    if this.VerifyActionRecord() {
      this.Update(context);
    };
    return true;
  }

  private final func RunCurrentNodeNextAction(context: ScriptExecutionContext) -> Bool {
    if Equals(this.m_currentNodeType, ETweakAINodeType.Sequence) && TweakAIActionRecord.IsThisLastActionInSequence(this.m_currentNode as AIActionSequence_Record, this.m_currentNodeIterator) {
      return false;
    };
    if Equals(this.m_currentNodeType, ETweakAINodeType.Selector) && TweakAIActionRecord.IsThisLastActionInSelector(this.m_currentNode as AIActionSelector_Record, this.m_currentNodeIterator) {
      return false;
    };
    this.m_currentNodeIterator += 1;
    this.Deactivate(context);
    this.m_gracefullyInterrupted = false;
    this.Activate(context);
    if this.VerifyActionRecord() {
      this.Update(context);
    };
    return true;
  }

  private final func ResetNodeIterator() -> Void {
    if IsDefined(this.m_smartCompositeRecord) && this.m_smartCompositeRecord.Type().RandomizeIteratorOnReset() {
      this.m_nodeIterator = RandRange(0, this.m_smartCompositeRecord.GetNodesCount());
      this.m_currentNodeIterator = this.m_nodeIterator;
    } else {
      this.m_nodeIterator = 0;
      this.m_currentNodeIterator = 0;
    };
  }

  private final func IncrementNodeIterator() -> Void {
    this.m_nodeIterator += 1;
    this.m_currentNodeIterator = 0;
    this.m_gracefullyInterrupted = false;
  }
}

public class IdleActionsCondition extends AIbehaviorconditionScript {

  private final func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context).GetRecordID());
    if !IsDefined(characterRecord) {
      return Cast(false);
    };
    if !IsDefined(characterRecord.IdleActions()) {
      return Cast(false);
    };
    return Cast(true);
  }

  public final func GetFriendlyName() -> String {
    return "IdleActionsCondition";
  }
}

public class IdleActions extends TweakAIActionSmartComposite {

  public func GetSmartCompositeRecord(const context: ScriptExecutionContext, smartCompositeID: TweakDBID, out smartCompositeDebugName: String, out smartCompositeRecord: wref<AIActionSmartComposite_Record>) -> Bool {
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context).GetRecordID());
    if !IsDefined(characterRecord) {
      return false;
    };
    smartCompositeRecord = characterRecord.IdleActions();
    smartCompositeDebugName = "IdleActions";
    return IsDefined(smartCompositeRecord) ? true : false;
  }

  public func GetFriendlyName() -> String {
    return "IdleActions";
  }
}

public class PatrolAction extends TweakAIActionSmartComposite {

  public func GetSmartCompositeRecord(const context: ScriptExecutionContext, smartCompositeID: TweakDBID, out smartCompositeDebugName: String, out smartCompositeRecord: wref<AIActionSmartComposite_Record>) -> Bool {
    let record: ref<AIRecord_Record>;
    let patrolActionID: TweakDBID = FromVariant(AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetAIPatrolBlackboard().GetVariant(GetAllBlackboardDefs().AIPatrol.patrolAction));
    if !TDBID.IsValid(patrolActionID) {
      return false;
    };
    if !ScriptExecutionContext.GetOverriddenNode(context, patrolActionID, record, true) {
      return false;
    };
    smartCompositeID = record.GetID();
    if !IsFinal() {
      smartCompositeDebugName = TDBID.ToStringDEBUG(smartCompositeID);
    };
    smartCompositeRecord = record as AIActionSmartComposite_Record;
    return smartCompositeRecord != null;
  }

  public func GetFriendlyName() -> String {
    return "PatrolAction";
  }
}

public class PatrolSpotAction extends TweakAIActionSmartComposite {

  public inline edit let m_patrolAction: ref<AIArgumentMapping>;

  public func GetSmartCompositeRecord(const context: ScriptExecutionContext, smartCompositeID: TweakDBID, out smartCompositeDebugName: String, out smartCompositeRecord: wref<AIActionSmartComposite_Record>) -> Bool {
    let patrolCompositeRecord: wref<AIActionSmartComposite_Record>;
    let patrolActionName: CName = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_patrolAction));
    let patrolCompositeID: TweakDBID = TDBID.Create(ToString(patrolActionName));
    if !TDBID.IsValid(patrolCompositeID) {
      return false;
    };
    patrolCompositeRecord = TweakDBInterface.GetAIActionSmartCompositeRecord(patrolCompositeID);
    if !IsDefined(patrolCompositeRecord) {
      return false;
    };
    smartCompositeRecord = patrolCompositeRecord;
    smartCompositeDebugName = "PatrolSpotAction";
    return IsDefined(smartCompositeRecord) ? true : false;
  }

  public func GetFriendlyName() -> String {
    return "PatrolSpotAction";
  }
}
