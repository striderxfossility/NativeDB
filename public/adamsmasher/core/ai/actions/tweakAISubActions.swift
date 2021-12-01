
public abstract class TweakAISubAction extends IScriptable {

  public final static func OnCantFindProperActivateMethod(const className: CName) -> Void {
    LogAI("Cant find activate method for class " + NameToString(className));
  }

  public final static func OnCantFindProperUpdateMethod(const className: CName) -> Void {
    LogAI("Cant find update method for class " + NameToString(className));
  }

  public final static func OnCantFindProperDeactivateMethod(const className: CName) -> Void {
    LogAI("Cant find deactivate method for class " + NameToString(className));
  }

  public final static func OnCantFindProperGetAnimVariationMethod(const className: CName) -> Void {
    LogAI("Cant find deactivate method for class " + NameToString(className));
  }

  public final static func OnCantFindProperGetPhaseDurationnMethod(const className: CName) -> Void {
    LogAI("Cant find deactivate method for class " + NameToString(className));
  }

  public final static func Activate(context: ScriptExecutionContext, subActionRecord: wref<AISubAction_Record>) -> Bool {
    if !IsDefined(subActionRecord) {
      return false;
    };
    AIScriptUtils.CallActivateSubAction(context, subActionRecord);
    return true;
  }

  public final static func Update(context: ScriptExecutionContext, subActionRecord: wref<AISubAction_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if !IsDefined(subActionRecord) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    return AIScriptUtils.CallUpdateSubAction(context, subActionRecord, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, subActionRecord: wref<AISubAction_Record>, const duration: Float, interrupted: Bool) -> Void {
    if !IsDefined(subActionRecord) {
      return;
    };
    AIScriptUtils.CallDeactivateSubAction(context, subActionRecord, duration, interrupted);
  }

  public final static func GetAnimVariation(context: ScriptExecutionContext, subActionRecord: wref<AISubAction_Record>, out animVariation: Int32) -> Bool {
    if !IsDefined(subActionRecord) {
      return false;
    };
    animVariation = AIScriptUtils.CallGetAnimVariation(context, subActionRecord);
    return animVariation >= 0;
  }

  public final static func GetPhaseDuration(context: ScriptExecutionContext, subActionRecord: wref<AISubAction_Record>, actionPhase: EAIActionPhase, baseDuration: Float, out duration: Float) -> Bool {
    if !IsDefined(subActionRecord) {
      return false;
    };
    duration = AIScriptUtils.CallGetPhaseDuration(context, subActionRecord, EnumInt(actionPhase), baseDuration);
    return duration >= 0.00;
  }
}

public abstract class AISubActionPlayVoiceOver_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>) -> Void {
    if record.Delay() == 0.00 && AISubActionPlayVoiceOver_Record_Implementation.IsConditionFulfilled(context, record) {
      AISubActionPlayVoiceOver_Record_Implementation.SendVoiceOverEvent(context, record, n"Scripts:AISubActionPlayVoiceOver:Activate");
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if AISubActionPlayVoiceOver_Record_Implementation.IsDelayConditionFulfilled(context, record, duration) && AISubActionPlayVoiceOver_Record_Implementation.IsConditionFulfilled(context, record) {
      AISubActionPlayVoiceOver_Record_Implementation.SendVoiceOverEvent(context, record, n"Scripts:AISubActionPlayVoiceOver:Delayed");
      if !record.Repeat() {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>, const duration: Float, interrupted: Bool) -> Void {
    if !record.Repeat() && record.Delay() < 0.00 && AISubActionPlayVoiceOver_Record_Implementation.IsConditionFulfilled(context, record) {
      AISubActionPlayVoiceOver_Record_Implementation.SendVoiceOverEvent(context, record, n"Scripts:AISubActionPlayVoiceOver:Deactivate");
    };
  }

  public final static func IsSquadmateConditionFulfilled(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>) -> Bool {
    let squadmates: array<wref<Entity>>;
    return !record.SendEventToSquadmates() || AISquadHelper.GetSquadmates(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, squadmates);
  }

  public final static func IsCooldownConditionFulfilled(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>) -> Bool {
    return !IsDefined(record.Cooldown()) || !AIActionHelper.IsCooldownActive(ScriptExecutionContext.GetOwner(context), record.Cooldown());
  }

  public final static func IsConditionFulfilled(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>) -> Bool {
    return AISubActionPlayVoiceOver_Record_Implementation.IsSquadmateConditionFulfilled(context, record) && AISubActionPlayVoiceOver_Record_Implementation.IsCooldownConditionFulfilled(context, record) && (!IsDefined(record.Condition()) || AICondition.CheckActionCondition(context, record.Condition()));
  }

  public final static func SendVoiceOverEvent(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>, debugInitContext: CName) -> Void {
    let ownerPuppet: ref<gamePuppet> = ScriptExecutionContext.GetOwner(context);
    if record.SendEventToSquadmates() {
      ReactionManagerComponent.SendVOEventToSquad(ownerPuppet, record.Name(), record.SetSelfAsAnsweringEntity());
    } else {
      GameObject.PlayVoiceOver(ownerPuppet, record.Name(), debugInitContext);
    };
    if IsDefined(record.Cooldown()) {
      AIActionHelper.StartCooldown(ownerPuppet, record.Cooldown());
    };
  }

  public final static func IsDelayConditionFulfilled(context: ScriptExecutionContext, record: wref<AISubActionPlayVoiceOver_Record>, const duration: Float) -> Bool {
    return record.Delay() > 0.00 && duration >= record.Delay() || record.Repeat() && record.Delay() == 0.00;
  }
}

public abstract class AISubActionDisableCollider_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionDisableCollider_Record>) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    if record.Disable() && record.Delay() == 0.00 {
      AIHumanComponent.Get(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, aiComponent);
      aiComponent.DisableCollider();
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionDisableCollider_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let aiComponent: ref<AIHumanComponent>;
    if record.Disable() && record.Delay() > 0.00 && AISubActionDisableCollider_Record_Implementation.IsDelayConditionFulfilled(context, record, duration) {
      AIHumanComponent.Get(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, aiComponent);
      aiComponent.DisableCollider();
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionDisableCollider_Record>, const duration: Float, interrupted: Bool) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    if record.EnableOnDeactivate() {
      AIHumanComponent.Get(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, aiComponent);
      aiComponent.EnableCollider();
    };
  }

  public final static func IsDelayConditionFulfilled(context: ScriptExecutionContext, record: wref<AISubActionDisableCollider_Record>, const duration: Float) -> Bool {
    return record.Delay() > 0.00 && duration >= record.Delay();
  }
}

public abstract class AISubActionAddFact_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionAddFact_Record>) -> Void {
    if record.Delay() == 0.00 {
      AddFact(ScriptExecutionContext.GetOwner(context).GetGame(), record.Name());
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionAddFact_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AddFact(ScriptExecutionContext.GetOwner(context).GetGame(), record.Name());
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionAddFact_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AddFact(ScriptExecutionContext.GetOwner(context).GetGame(), record.Name());
    } else {
      if record.ResetValue() {
        SetFactValue(ScriptExecutionContext.GetOwner(context).GetGame(), record.Name(), 0);
      };
    };
  }
}

public abstract class AISubActionQueueAIEvent_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionQueueAIEvent_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionQueueAIEvent_Record_Implementation.QueueAIEvent(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionQueueAIEvent_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionQueueAIEvent_Record_Implementation.QueueAIEvent(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionQueueAIEvent_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionQueueAIEvent_Record_Implementation.QueueAIEvent(context, record);
    };
  }

  public final static func QueueAIEvent(context: ScriptExecutionContext, record: wref<AISubActionQueueAIEvent_Record>) -> Void {
    let aiEvent: ref<AIEvent>;
    if Equals(record.Name(), n"") {
      return;
    };
    aiEvent = new AIEvent();
    aiEvent.name = record.Name();
    ScriptExecutionContext.GetOwner(context).QueueEvent(aiEvent);
  }
}

public abstract class AISubActionQueueCommunicationEvent_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionQueueCommunicationEvent_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionQueueCommunicationEvent_Record_Implementation.QueueCommunicationEvent(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionQueueCommunicationEvent_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionQueueCommunicationEvent_Record_Implementation.QueueCommunicationEvent(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionQueueCommunicationEvent_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionQueueCommunicationEvent_Record_Implementation.QueueCommunicationEvent(context, record);
    };
  }

  public final static func QueueCommunicationEvent(context: ScriptExecutionContext, record: wref<AISubActionQueueCommunicationEvent_Record>) -> Void {
    let communicationEvent: ref<CommunicationEvent>;
    let listener: wref<GameObject>;
    if Equals(record.Name(), n"") {
      return;
    };
    if !AIActionTarget.GetObject(context, record.TargetListener(), listener) {
      return;
    };
    communicationEvent = new CommunicationEvent();
    communicationEvent.name = record.Name();
    communicationEvent.sender = ScriptExecutionContext.GetOwner(context).GetEntityID();
    listener.QueueEvent(communicationEvent);
    ScriptExecutionContext.GetOwner(context).QueueEvent(communicationEvent);
  }
}

public abstract class AISubActionSpawnFX_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSpawnFX_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionSpawnFX_Record_Implementation.SpawnFX(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSpawnFX_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionSpawnFX_Record_Implementation.SpawnFX(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSpawnFX_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionSpawnFX_Record_Implementation.SpawnFX(context, record);
    } else {
      AISubActionSpawnFX_Record_Implementation.DespawnFX(context, record);
    };
  }

  public final static func SpawnFX(context: ScriptExecutionContext, record: wref<AISubActionSpawnFX_Record>) -> Void {
    let item: ref<ItemObject>;
    if IsDefined(record.AttachmentSlot()) {
      item = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.AttachmentSlot().GetID());
      if !IsDefined(item) {
        return;
      };
      GameObject.StartReplicatedEffectEvent(item, record.Name());
    } else {
      GameObject.StartReplicatedEffectEvent(ScriptExecutionContext.GetOwner(context), record.Name());
    };
  }

  public final static func DespawnFX(context: ScriptExecutionContext, record: wref<AISubActionSpawnFX_Record>) -> Void {
    let item: ref<ItemObject>;
    if IsDefined(record.AttachmentSlot()) {
      item = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.AttachmentSlot().GetID());
      if !IsDefined(item) {
        return;
      };
      GameObject.BreakReplicatedEffectLoopEvent(item, record.Name());
    } else {
      GameObject.BreakReplicatedEffectLoopEvent(ScriptExecutionContext.GetOwner(context), record.Name());
    };
  }
}

public abstract class AISubActionPlaySound_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionPlaySound_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionPlaySound_Record_Implementation.PlaySound(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionPlaySound_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionPlaySound_Record_Implementation.PlaySound(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionPlaySound_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionPlaySound_Record_Implementation.PlaySound(context, record);
    };
  }

  public final static func PlaySound(context: ScriptExecutionContext, record: wref<AISubActionPlaySound_Record>) -> Void {
    let item: ref<ItemObject>;
    if IsDefined(record.AttachmentSlot()) {
      item = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.AttachmentSlot().GetID());
      if !IsDefined(item) {
        return;
      };
      GameObject.PlaySound(item, record.Name());
    } else {
      GameObject.PlaySound(ScriptExecutionContext.GetOwner(context), record.Name());
    };
  }
}

public abstract class AISubActionSetEquipWeaponsUtils extends IScriptable {

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCharacterRecordEquip_Record>, itemsToEquip: array<NPCItemToEquip>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let puppet: ref<ScriptedPuppet>;
    if ArraySize(itemsToEquip) == 0 {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    puppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    AIActionHelper.SetItemsEquipData(puppet, itemsToEquip);
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public abstract class AISubActionSetEquipPrimaryWeapons_Record_Implementation extends IScriptable {

  public final static func GetItemsToEquip(context: ScriptExecutionContext, record: wref<AISubActionCharacterRecordEquip_Record>, out itemsToEquip: array<NPCItemToEquip>) -> Bool {
    return AIActionTransactionSystem.GetEquipmentWithCondition(context, true, false, itemsToEquip);
  }

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetEquipPrimaryWeapons_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetEquipPrimaryWeapons_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let itemsToEquip: array<NPCItemToEquip>;
    AISubActionSetEquipPrimaryWeapons_Record_Implementation.GetItemsToEquip(context, record, itemsToEquip);
    return AISubActionSetEquipWeaponsUtils.Update(context, record, itemsToEquip, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetEquipPrimaryWeapons_Record>, const duration: Float, interrupted: Bool) -> Void;
}

public abstract class AISubActionSetEquipSecondaryWeapons_Record_Implementation extends IScriptable {

  public final static func GetItemsToEquip(context: ScriptExecutionContext, record: wref<AISubActionCharacterRecordEquip_Record>, out itemsToEquip: array<NPCItemToEquip>) -> Bool {
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context).GetRecordID());
    if !AIActionTransactionSystem.GetEquipmentWithCondition(context, false, false, itemsToEquip) {
      return AIActionTransactionSystem.GetDefaultEquipment(context, characterRecord, false, itemsToEquip);
    };
    return true;
  }

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetEquipSecondaryWeapons_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetEquipSecondaryWeapons_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let itemsToEquip: array<NPCItemToEquip>;
    AISubActionSetEquipSecondaryWeapons_Record_Implementation.GetItemsToEquip(context, record, itemsToEquip);
    return AISubActionSetEquipWeaponsUtils.Update(context, record, itemsToEquip, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetEquipSecondaryWeapons_Record>, const duration: Float, interrupted: Bool) -> Void;
}

public abstract class AISubActionEquipOnSlot_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionEquipOnSlot_Record>) -> Void {
    let i: Int32;
    let itemToRemove: ref<ItemObject>;
    let itemsToEquip: array<NPCItemToEquip>;
    let transactionSystem: ref<TransactionSystem>;
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(BBoard) {
      itemsToEquip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip));
      if ArraySize(itemsToEquip) != 0 {
        transactionSystem = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame());
        if IsDefined(transactionSystem) {
          i = 0;
          while i < ArraySize(itemsToEquip) {
            if !transactionSystem.IsSlotEmpty(ScriptExecutionContext.GetOwner(context), itemsToEquip[i].slotID) && !transactionSystem.IsSlotEmptySpawningItem(ScriptExecutionContext.GetOwner(context), itemsToEquip[i].slotID) {
              itemToRemove = transactionSystem.GetItemInSlot(ScriptExecutionContext.GetOwner(context), itemsToEquip[i].slotID);
              if transactionSystem.RemoveItemFromSlot(ScriptExecutionContext.GetOwner(context), itemsToEquip[i].slotID, true) {
                NPCPuppet.SetAnimWrapperBasedOnEquippedItem(ScriptExecutionContext.GetOwner(context) as NPCPuppet, itemsToEquip[i].slotID, itemToRemove.GetItemID(), 0.00);
              };
            };
            i += 1;
          };
        };
        if BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration) > 0.00 {
          AISubActionEquipOnSlot_Record_Implementation.ApplyAnimFeature(context, itemsToEquip, record.UseItemSpawnDelayFromWeapon());
        };
        if !record.UseItemSpawnDelayFromWeapon() || BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipItemTime) == 0.00 {
          AISubActionEquipOnSlot_Record_Implementation.Equip(context, itemsToEquip);
        };
      };
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionEquipOnSlot_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let equipTime: Float;
    let itemsToEquip: array<NPCItemToEquip>;
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(BBoard) {
      if duration < BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration) {
        if record.UseItemSpawnDelayFromWeapon() {
          itemsToEquip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip));
          if ArraySize(itemsToEquip) != 0 {
            equipTime = BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipItemTime);
            if equipTime > 0.00 && duration > equipTime {
              AISubActionEquipOnSlot_Record_Implementation.Equip(context, itemsToEquip);
            };
          };
        };
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.FAILURE;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionEquipOnSlot_Record>, const duration: Float, interrupted: Bool) -> Void {
    let itemsToEquip: array<NPCItemToEquip>;
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(BBoard) {
      itemsToEquip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip));
      if ArraySize(itemsToEquip) != 0 && GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).IsSlotEmpty(ScriptExecutionContext.GetOwner(context), itemsToEquip[0].slotID) {
        AISubActionEquipOnSlot_Record_Implementation.Equip(context, itemsToEquip);
      };
      if BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration) > 0.00 {
        AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Equip", new AnimFeature_AIAction());
      };
      BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, 0.00);
    };
  }

  public final static func ApplyAnimFeature(context: ScriptExecutionContext, itemsToEquip: array<NPCItemToEquip>, sendAnimFeature: Bool) -> Void {
    let i: Int32;
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = 1;
    animFeature.stateDuration = -1.00;
    if ArraySize(itemsToEquip) > 1 {
      animFeature.animVariation = 2;
    } else {
      if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasTag(ScriptExecutionContext.GetOwner(context), WeaponObject.GetMeleeWeaponTag(), itemsToEquip[0].itemID) {
        animFeature.animVariation = 1;
      } else {
        animFeature.animVariation = 0;
      };
    };
    if sendAnimFeature {
      i = 0;
      while i < ArraySize(itemsToEquip) {
        NPCPuppet.SetAnimWrapperBasedOnEquippedItem(ScriptExecutionContext.GetOwner(context) as NPCPuppet, itemsToEquip[i].slotID, itemsToEquip[i].itemID, 1.00);
        i += 1;
      };
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Equip", animFeature);
  }

  public final static func Equip(context: ScriptExecutionContext, itemsToEquip: array<NPCItemToEquip>) -> Bool {
    let i: Int32;
    let reservedEquipSlotIDs: array<TweakDBID>;
    let result: Bool;
    let transactionSystem: ref<TransactionSystem>;
    let equipOnBody: Bool = TweakDBInterface.GetBool(t"AIGeneralSettings.displayWeaponsOnBody", equipOnBody);
    let highPriority: Bool = false;
    let owner: ref<gamePuppet> = ScriptExecutionContext.GetOwner(context);
    if Equals(ScriptedPuppet.IsActive(owner), false) {
      return false;
    };
    transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    if !IsDefined(transactionSystem) {
      return false;
    };
    i = 0;
    while i < ArraySize(itemsToEquip) {
      if ArrayContains(reservedEquipSlotIDs, itemsToEquip[i].slotID) {
      } else {
        if transactionSystem.IsSlotEmpty(owner, itemsToEquip[i].slotID) {
          if equipOnBody && transactionSystem.HasItemInSlot(owner, itemsToEquip[i].bodySlotID, itemsToEquip[i].itemID) {
            result = transactionSystem.ChangeItemToSlot(owner, itemsToEquip[i].slotID, itemsToEquip[i].itemID);
            if result {
              ArrayPush(reservedEquipSlotIDs, itemsToEquip[i].slotID);
            };
          } else {
            highPriority = NotEquals(WeaponObject.GetWeaponType(itemsToEquip[i].itemID), gamedataItemType.Invalid);
            result = transactionSystem.AddItemToSlot(owner, itemsToEquip[i].slotID, itemsToEquip[i].itemID, highPriority);
            if result && (!IsFinal() || UseProfiler()) {
              GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet.DEBUG_Visualizer.ShowEquipStartText(owner, itemsToEquip[i].slotID, itemsToEquip[i].itemID);
            };
            if result {
              ArrayPush(reservedEquipSlotIDs, itemsToEquip[i].slotID);
            };
          };
        };
      };
      i += 1;
    };
    if result {
      AIActionHelper.ClearItemsToEquip(owner as ScriptedPuppet);
    };
    return result;
  }
}

public abstract class AISubActionEquipOnBody_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionEquipOnBody_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionEquipOnBody_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let itemsToEquip: array<NPCItemToEquip>;
    AISubActionEquipOnBody_Record_Implementation.GetItemsToEquip(context, record, itemsToEquip);
    if AISubActionEquipOnBody_Record_Implementation.EquipOnBody(context, itemsToEquip) {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.FAILURE;
  }

  public final static func GetItemsToEquip(context: ScriptExecutionContext, record: wref<AISubActionCharacterRecordEquip_Record>, out itemsToEquip: array<NPCItemToEquip>) -> Bool {
    return AIActionTransactionSystem.GetOnBodyEquipment(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, itemsToEquip);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionEquipOnBody_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func EquipOnBody(context: ScriptExecutionContext, itemsToEquip: array<NPCItemToEquip>) -> Bool {
    let highPriority: Bool;
    let i: Int32;
    let result: Bool;
    let transactionSystem: ref<TransactionSystem>;
    let equipOnBody: Bool = TweakDBInterface.GetBool(t"AIGeneralSettings.displayWeaponsOnBody", equipOnBody);
    let owner: ref<gamePuppet> = ScriptExecutionContext.GetOwner(context);
    if Equals(ScriptedPuppet.IsActive(owner), false) {
      return false;
    };
    transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    if !IsDefined(transactionSystem) {
      return false;
    };
    if equipOnBody {
      i = 0;
      while i < ArraySize(itemsToEquip) {
        if !transactionSystem.HasItem(owner, itemsToEquip[i].itemID) {
          transactionSystem.GiveItem(owner, itemsToEquip[i].itemID, 1);
        };
        if !transactionSystem.HasItemInSlot(owner, itemsToEquip[i].bodySlotID, itemsToEquip[i].itemID) {
          highPriority = NotEquals(WeaponObject.GetWeaponType(itemsToEquip[i].itemID), gamedataItemType.Invalid);
          if transactionSystem.AddItemToSlot(owner, itemsToEquip[i].bodySlotID, itemsToEquip[i].itemID, highPriority) {
            result = true;
          };
          if result && (!IsFinal() || UseProfiler()) {
            GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet.DEBUG_Visualizer.ShowEquipStartText(owner, itemsToEquip[i].bodySlotID, itemsToEquip[i].itemID);
          };
        };
        i += 1;
      };
    };
    if result {
      AIActionHelper.ClearItemsToEquip(owner as ScriptedPuppet);
    };
    return result;
  }
}

public abstract class AISubActionForceEquip_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionForceEquip_Record>) -> Void {
    let itemID: ItemID;
    let itemToEquip: NPCItemToEquip;
    let itemsToEquip: array<NPCItemToEquip>;
    if AISubActionForceEquip_Record_Implementation.GetItemID(context, record, itemID) && IsDefined(record.AttachmentSlot()) {
      itemToEquip.itemID = itemID;
      itemToEquip.slotID = record.AttachmentSlot().GetID();
      ArrayPush(itemsToEquip, itemToEquip);
      AIActionHelper.SetItemsEquipData(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, itemsToEquip);
      if record.AnimationTime() > 0.00 {
        AISubActionForceEquip_Record_Implementation.ApplyAnimFeature(context, itemsToEquip, record);
      };
      if record.Delay() == 0.00 {
        AISubActionForceEquip_Record_Implementation.Equip(context, record);
      };
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionForceEquip_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      if IsDefined(record.AttachmentSlot()) {
        AISubActionForceEquip_Record_Implementation.Equip(context, record);
      };
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionForceEquip_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.EquipDespiteInterruption() || record.Delay() < 0.00 {
      if IsDefined(record.AttachmentSlot()) {
        AISubActionForceEquip_Record_Implementation.Equip(context, record);
      };
    };
    if record.AnimationTime() > 0.00 {
      AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Equip", new AnimFeature_AIAction());
    };
  }

  public final static func ApplyAnimFeature(context: ScriptExecutionContext, itemsToEquip: array<NPCItemToEquip>, record: wref<AISubActionForceEquip_Record>) -> Void {
    let i: Int32;
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = 1;
    if record.AnimationTime() >= 0.00 {
      animFeature.stateDuration = record.AnimationTime();
    } else {
      animFeature.stateDuration = -1.00;
    };
    if ArraySize(itemsToEquip) > 1 {
      animFeature.animVariation = 2;
    } else {
      if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasTag(ScriptExecutionContext.GetOwner(context), WeaponObject.GetMeleeWeaponTag(), itemsToEquip[0].itemID) {
        animFeature.animVariation = 1;
      } else {
        animFeature.animVariation = 0;
      };
    };
    i = 0;
    while i < ArraySize(itemsToEquip) {
      NPCPuppet.SetAnimWrapperBasedOnEquippedItem(ScriptExecutionContext.GetOwner(context) as NPCPuppet, itemsToEquip[i].slotID, itemsToEquip[i].itemID, 1.00);
      i += 1;
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Equip", animFeature);
  }

  public final static func Equip(context: ScriptExecutionContext, record: wref<AISubActionForceEquip_Record>) -> Bool {
    let gameObj: wref<GameObject>;
    let item: wref<ItemObject>;
    let itemID: ItemID;
    let result: Bool;
    let transactionSystem: ref<TransactionSystem>;
    let highPriority: Bool = false;
    let owner: ref<gamePuppet> = ScriptExecutionContext.GetOwner(context);
    if Equals(ScriptedPuppet.IsActive(owner), false) {
      return false;
    };
    transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    if !IsDefined(transactionSystem) {
      return false;
    };
    if IsDefined(record.ItemObject()) {
      if !AIActionTarget.GetObject(context, record.ItemObject(), gameObj) {
        return false;
      };
      item = gameObj as gameItemDropObject.GetItemObject();
      if !IsDefined(item) {
        return false;
      };
      if transactionSystem.TakeItem(owner, item) {
        highPriority = NotEquals(WeaponObject.GetWeaponType(item.GetItemID()), gamedataItemType.Invalid);
        result = transactionSystem.AddItemToSlot(owner, record.AttachmentSlot().GetID(), item.GetItemID(), highPriority, item);
        if result && (!IsFinal() || UseProfiler()) {
          GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet.DEBUG_Visualizer.ShowEquipStartText(owner, record.AttachmentSlot().GetID(), item.GetItemID());
        };
      };
      return result;
    };
    if !AISubActionForceEquip_Record_Implementation.GetItemID(context, record, itemID) {
      return false;
    };
    if transactionSystem.HasItemInAnySlot(owner, itemID) {
      if IsDefined(record.ItemID()) && !transactionSystem.HasItem(owner, itemID) {
        transactionSystem.GiveItem(owner, itemID, 1);
      };
      result = transactionSystem.ChangeItemToSlot(owner, record.AttachmentSlot().GetID(), itemID);
    } else {
      if IsDefined(record.ItemID()) && !transactionSystem.HasItem(owner, itemID) {
        transactionSystem.GiveItem(owner, itemID, 1);
      };
      highPriority = NotEquals(WeaponObject.GetWeaponType(itemID), gamedataItemType.Invalid);
      result = transactionSystem.AddItemToSlot(owner, record.AttachmentSlot().GetID(), itemID, highPriority);
      if result && (!IsFinal() || UseProfiler()) {
        GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet.DEBUG_Visualizer.ShowEquipStartText(owner, record.AttachmentSlot().GetID(), itemID);
      };
    };
    if result {
      AIActionHelper.ClearItemsToEquip(owner as ScriptedPuppet);
    };
    return result;
  }

  public final static func GetItemID(context: ScriptExecutionContext, record: wref<AISubActionForceEquip_Record>, out itemID: ItemID) -> Bool {
    if IsDefined(record.ItemID()) {
      itemID = ItemID.CreateQuery(record.ItemID().GetID());
      return true;
    };
    if IsDefined(record.ItemType()) {
      return AIActionTransactionSystem.GetFirstItemID(ScriptExecutionContext.GetOwner(context), record.ItemType(), record.ItemTag(), itemID);
    };
    if IsDefined(record.ItemCategory()) {
      return AIActionTransactionSystem.GetFirstItemID(ScriptExecutionContext.GetOwner(context), record.ItemCategory(), record.ItemTag(), itemID);
    };
    if AIActionTransactionSystem.GetFirstItemID(ScriptExecutionContext.GetOwner(context), record.ItemTag(), itemID) {
      return true;
    };
    return false;
  }
}

public abstract class AISubActionSetUnequipWeaponsUtils extends IScriptable {

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCharacterRecordUnequip_Record>, itemsToUnequip: array<NPCItemToEquip>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let puppet: ref<ScriptedPuppet>;
    if ArraySize(itemsToUnequip) == 0 {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    puppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    AIActionHelper.SetItemsUnequipData(puppet, itemsToUnequip, record.DropItem());
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}

public abstract class AISubActionSetUnequipPrimaryWeapons_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetUnequipPrimaryWeapons_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetUnequipPrimaryWeapons_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let itemsToUnequip: array<NPCItemToEquip>;
    AISubActionSetUnequipPrimaryWeapons_Record_Implementation.GetItemsToUnequip(context, record, itemsToUnequip);
    return AISubActionSetUnequipWeaponsUtils.Update(context, record, itemsToUnequip, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetUnequipPrimaryWeapons_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func GetItemsToUnequip(context: ScriptExecutionContext, record: wref<AISubActionCharacterRecordUnequip_Record>, out itemsToUnequip: array<NPCItemToEquip>) -> Bool {
    return AIActionTransactionSystem.GetEquipmentWithCondition(context, true, true, itemsToUnequip);
  }
}

public abstract class AISubActionSetUnequipSecondaryWeapons_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetUnequipSecondaryWeapons_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetUnequipSecondaryWeapons_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let itemsToUnequip: array<NPCItemToEquip>;
    AISubActionSetUnequipSecondaryWeapons_Record_Implementation.GetItemsToUnequip(context, record, itemsToUnequip);
    return AISubActionSetUnequipWeaponsUtils.Update(context, record, itemsToUnequip, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetUnequipSecondaryWeapons_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func GetItemsToUnequip(context: ScriptExecutionContext, record: wref<AISubActionCharacterRecordUnequip_Record>, out itemsToUnequip: array<NPCItemToEquip>) -> Bool {
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context).GetRecordID());
    if !AIActionTransactionSystem.GetEquipmentWithCondition(context, false, true, itemsToUnequip) {
      return AIActionTransactionSystem.GetDefaultEquipment(context, characterRecord, true, itemsToUnequip);
    };
    return true;
  }
}

public abstract class AISubActionUnequipOnSlot_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionUnequipOnSlot_Record>) -> Void {
    let itemsToUnequip: array<NPCItemToEquip>;
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(BBoard) {
      itemsToUnequip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip));
      if ArraySize(itemsToUnequip) != 0 && BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration) > 0.00 {
        AISubActionUnequipOnSlot_Record_Implementation.ApplyAnimFeature(context, itemsToUnequip);
      };
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionUnequipOnSlot_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let equipTime: Float;
    let itemsToUnequip: array<NPCItemToEquip>;
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(BBoard) {
      if record.UseItemSpawnDelayFromWeapon() {
        itemsToUnequip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip));
        if ArraySize(itemsToUnequip) != 0 {
          equipTime = BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipItemTime);
          if equipTime > 0.00 && duration > equipTime {
            AISubActionUnequipOnSlot_Record_Implementation.Unequip(context, BBoard.GetBool(GetAllBlackboardDefs().AIAction.dropItemOnUnequip), itemsToUnequip);
          };
        };
      };
      if duration < BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration) {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionUnequipOnSlot_Record>, const duration: Float, interrupted: Bool) -> Void {
    let i: Int32;
    let itemsToUnequip: array<NPCItemToEquip>;
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(BBoard) {
      itemsToUnequip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip));
      if ArraySize(itemsToUnequip) > 0 {
        AISubActionUnequipOnSlot_Record_Implementation.Unequip(context, BBoard.GetBool(GetAllBlackboardDefs().AIAction.dropItemOnUnequip), itemsToUnequip);
      };
      ArrayClear(itemsToUnequip);
      itemsToUnequip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsUnequipped));
      i = 0;
      while i < ArraySize(itemsToUnequip) {
        NPCPuppet.SetAnimWrapperBasedOnEquippedItem(ScriptExecutionContext.GetOwner(context) as NPCPuppet, itemsToUnequip[i].slotID, itemsToUnequip[i].itemID, 0.00);
        i += 1;
      };
      AIActionHelper.ClearItemsUnequipped(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet);
      if BBoard.GetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration) > 0.00 {
        AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Unequip", new AnimFeature_AIAction());
      };
    };
  }

  public final static func Unequip(context: ScriptExecutionContext, dropItem: Bool, itemsToUnequip: array<NPCItemToEquip>) -> Bool {
    let BBoard: ref<IBlackboard>;
    let i: Int32;
    let itemsUnequipped: array<ItemID>;
    let equipOnBody: Bool = TweakDBInterface.GetBool(t"AIGeneralSettings.displayWeaponsOnBody", equipOnBody);
    if ArraySize(itemsToUnequip) > 0 {
      BBoard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
      if IsDefined(BBoard) {
        i = 0;
        while i < ArraySize(itemsToUnequip) {
          if dropItem {
            if AISubActionUnequipOnSlot_Record_Implementation.Drop(context, itemsToUnequip[i]) {
              ArrayPush(itemsUnequipped, itemsToUnequip[i].itemID);
            };
          } else {
            if TDBID.IsValid(itemsToUnequip[i].bodySlotID) && equipOnBody {
              if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).ChangeItemToSlot(ScriptExecutionContext.GetOwner(context), itemsToUnequip[i].bodySlotID, itemsToUnequip[i].itemID) {
                ArrayPush(itemsUnequipped, itemsToUnequip[i].itemID);
              };
            } else {
              if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RemoveItemFromSlot(ScriptExecutionContext.GetOwner(context), itemsToUnequip[i].slotID, true) {
                ArrayPush(itemsUnequipped, itemsToUnequip[i].itemID);
              };
            };
          };
          i += 1;
        };
        if ArraySize(itemsUnequipped) > 0 {
          BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerLastEquippedItems, ToVariant(itemsUnequipped));
          BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsUnequipped, ToVariant(itemsToUnequip));
          BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerLastUnequipTimestamp, EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())));
          AIActionHelper.ClearItemsToUnequip(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet);
          return true;
        };
      };
    };
    return false;
  }

  public final static func Drop(context: ScriptExecutionContext, itemToUnequip: NPCItemToEquip) -> Bool {
    ScriptedPuppet.DropItemFromSlot(ScriptExecutionContext.GetOwner(context), itemToUnequip.slotID);
    if !GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RemoveItem(ScriptExecutionContext.GetOwner(context), itemToUnequip.itemID, 1) {
      return false;
    };
    return true;
  }

  public final static func ApplyAnimFeature(context: ScriptExecutionContext, itemsToUnequip: array<NPCItemToEquip>) -> Void {
    let itemID: ItemID;
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = 1;
    animFeature.stateDuration = -1.00;
    let i: Int32 = 0;
    while i < ArraySize(itemsToUnequip) {
      itemID = itemsToUnequip[i].itemID;
      animFeature.animVariation = 0;
      if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasTag(ScriptExecutionContext.GetOwner(context), WeaponObject.GetMeleeWeaponTag(), itemID) {
        animFeature.animVariation = 1;
      };
      AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Unequip", animFeature);
      i += 1;
    };
  }
}

public abstract class AISubActionForceUnequip_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionForceUnequip_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionForceUnequip_Record_Implementation.Unequip(context, record);
    };
    if IsDefined(record.AttachmentSlot()) && record.AnimationTime() > 0.00 {
      AISubActionForceUnequip_Record_Implementation.ApplyAnimFeature(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionForceUnequip_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() >= 0.00 && duration >= record.Delay() {
      AISubActionForceUnequip_Record_Implementation.Unequip(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionForceUnequip_Record>, const duration: Float, interrupted: Bool) -> Void {
    let BBoard: ref<IBlackboard>;
    let i: Int32;
    let itemsToUnequip: array<NPCItemToEquip>;
    if record.UnequipDespiteInterruption() || record.Delay() < 0.00 {
      AISubActionForceUnequip_Record_Implementation.Unequip(context, record);
    };
    BBoard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(BBoard) {
      itemsToUnequip = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIAction.ownerItemsForceUnequipped));
      if ArraySize(itemsToUnequip) > 0 {
        i = 0;
        while i < ArraySize(itemsToUnequip) {
          NPCPuppet.SetAnimWrapperBasedOnEquippedItem(ScriptExecutionContext.GetOwner(context) as NPCPuppet, itemsToUnequip[i].slotID, itemsToUnequip[i].itemID, 0.00);
          i += 1;
        };
        AIActionHelper.ClearItemsForceUnequipped(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet);
      };
    };
    if record.AnimationTime() > 0.00 {
      AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Unequip", new AnimFeature_AIAction());
    };
  }

  public final static func ApplyAnimFeature(context: ScriptExecutionContext, record: wref<AISubActionForceUnequip_Record>) -> Void {
    let itemID: ItemID;
    let itemObj: ref<ItemObject>;
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    animFeature.state = 1;
    if record.AnimationTime() >= 0.00 {
      animFeature.stateDuration = record.AnimationTime();
    } else {
      animFeature.stateDuration = -1.00;
    };
    itemObj = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.AttachmentSlot().GetID());
    if IsDefined(itemObj) {
      itemID = itemObj.GetItemID();
    };
    if GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).HasTag(ScriptExecutionContext.GetOwner(context), WeaponObject.GetMeleeWeaponTag(), itemID) {
      animFeature.animVariation = 1;
    } else {
      animFeature.animVariation = 0;
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"Unequip", animFeature);
  }

  public final static func Unequip(context: ScriptExecutionContext, record: wref<AISubActionForceUnequip_Record>) -> Bool {
    let BBoard: ref<IBlackboard>;
    let bodySlotID: TweakDBID;
    let itemID: ItemID;
    let itemObj: ref<ItemObject>;
    let itemToUnequip: NPCItemToEquip;
    let itemsToUnequip: array<NPCItemToEquip>;
    let result: Bool;
    let equipOnBody: Bool = TweakDBInterface.GetBool(t"AIGeneralSettings.displayWeaponsOnBody", equipOnBody);
    if IsDefined(record.AttachmentSlot()) {
      if record.DropItem() {
        result = AISubActionForceUnequip_Record_Implementation.Drop(context, record);
      } else {
        itemObj = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.AttachmentSlot().GetID());
        if IsDefined(itemObj) {
          itemID = itemObj.GetItemID();
          if equipOnBody && AIActionTransactionSystem.GetItemsBodySlot(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, itemID, bodySlotID) {
            result = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).ChangeItemToSlot(ScriptExecutionContext.GetOwner(context), bodySlotID, itemID);
          } else {
            result = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RemoveItemFromAnySlot(ScriptExecutionContext.GetOwner(context), itemID);
          };
        };
      };
    };
    if result {
      itemToUnequip.itemID = itemID;
      itemToUnequip.slotID = record.AttachmentSlot().GetID();
      ArrayPush(itemsToUnequip, itemToUnequip);
      BBoard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
      if IsDefined(BBoard) {
        BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsForceUnequipped, ToVariant(itemsToUnequip));
      };
      return true;
    };
    return false;
  }

  public final static func Drop(context: ScriptExecutionContext, record: wref<AISubActionForceUnequip_Record>) -> Bool {
    let weapon: ref<ItemObject> = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.AttachmentSlot().GetID());
    ScriptedPuppet.DropItemFromSlot(ScriptExecutionContext.GetOwner(context), record.AttachmentSlot().GetID());
    if IsDefined(weapon) {
      GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RemoveItem(ScriptExecutionContext.GetOwner(context), weapon.GetItemID(), 1);
    };
    return true;
  }
}

public abstract class AISubActionDisableAimAssist_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionDisableAimAssist_Record>) -> Void {
    if record.Delay() <= 0.00 {
      AISubActionDisableAimAssist_Record_Implementation.EnableAimAssist(false, context);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionDisableAimAssist_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionDisableAimAssist_Record_Implementation.EnableAimAssist(false, context);
    };
    if record.Duration() >= 0.00 && duration >= record.Duration() {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionDisableAimAssist_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionDisableAimAssist_Record_Implementation.EnableAimAssist(true, context);
  }

  public final static func EnableAimAssist(enable: Bool, context: ScriptExecutionContext) -> Void {
    let puppet: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    if enable {
      puppet.QueueEvent(new EnableAimAssist());
    } else {
      puppet.QueueEvent(new DisableAimAssist());
    };
  }
}

public abstract class AISubActionApplyTimeDilation_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionApplyTimeDilation_Record>) -> Void {
    if AISubActionApplyTimeDilation_Record_Implementation.SetTimeDilation(context, record) {
      switch record.Type() {
        case n"Sandevistan":
          GameObject.StartReplicatedEffectEvent(ScriptExecutionContext.GetOwner(context), TimeDilationHelper.GetSandevistanKey());
          break;
        case n"Kerenzikov":
          GameObject.StartReplicatedEffectEvent(ScriptExecutionContext.GetOwner(context), TimeDilationHelper.GetSandevistanKey());
          break;
        default:
      };
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionApplyTimeDilation_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    AISubActionApplyTimeDilation_Record_Implementation.SetTimeDilation(context, record);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionApplyTimeDilation_Record>, const duration: Float, interrupted: Bool) -> Void {
    let blackboard: ref<IBlackboard>;
    if record.Multiplier() != 1.00 {
      ScriptExecutionContext.GetOwner(context).UnsetIndividualTimeDilation(record.EaseOut());
      blackboard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
      if IsDefined(blackboard) {
        blackboard.SetFloat(GetAllBlackboardDefs().AIAction.ownerTimeDilation, -1.00);
      };
    };
    switch record.Type() {
      case n"Sandevistan":
        GameObject.StopReplicatedEffectEvent(ScriptExecutionContext.GetOwner(context), TimeDilationHelper.GetSandevistanKey());
        break;
      case n"Kerenzikov":
        GameObject.StopReplicatedEffectEvent(ScriptExecutionContext.GetOwner(context), TimeDilationHelper.GetSandevistanKey());
        break;
      default:
    };
  }

  public final static func SetTimeDilation(context: ScriptExecutionContext, record: wref<AISubActionApplyTimeDilation_Record>) -> Bool {
    let blackboard: ref<IBlackboard>;
    let dilation: Float;
    let player: ref<PlayerPuppet>;
    let playerDilationActive: Bool;
    let reason: CName;
    let scaledDuration: Float;
    if record.Multiplier() != 1.00 && record.Duration() != 0.00 {
      if record.OverrideMultiplerWhenPlayerInTimeDilation() >= 0.00 {
        player = GameInstance.GetPlayerSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(player) {
          playerDilationActive = GameInstance.GetTimeSystem(player.GetGame()).IsTimeDilationActive();
        };
      };
      if playerDilationActive {
        dilation = record.OverrideMultiplerWhenPlayerInTimeDilation();
      } else {
        dilation = record.Multiplier();
      };
      blackboard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
      if IsDefined(blackboard) && blackboard.GetFloat(GetAllBlackboardDefs().AIAction.ownerTimeDilation) == dilation {
        return false;
      };
      blackboard.SetFloat(GetAllBlackboardDefs().AIAction.ownerTimeDilation, dilation);
      if record.Duration() < 0.00 {
        scaledDuration = 600.00;
      } else {
        scaledDuration = record.Duration() * dilation;
      };
      if GameInstance.GetTimeSystem(ScriptExecutionContext.GetOwner(context).GetGame()).IsTimeDilationActive() {
        ScriptExecutionContext.GetOwner(context).UnsetIndividualTimeDilation();
      };
      switch record.Type() {
        case n"Sandevistan":
          reason = TimeDilationHelper.GetSandevistanKey();
          break;
        case n"Kerenzikov":
          reason = TimeDilationHelper.GetKerenzikovKey();
          break;
        default:
          reason = record.Type();
      };
      ScriptExecutionContext.GetOwner(context).SetIndividualTimeDilation(reason, dilation, scaledDuration, record.EaseIn(), record.EaseOut());
      return true;
    };
    return false;
  }
}

public abstract class AISubActionModifyStatPool_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionModifyStatPool_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionModifyStatPool_Record_Implementation.ModifyStatPool(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionModifyStatPool_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionModifyStatPool_Record_Implementation.ModifyStatPool(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionModifyStatPool_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionModifyStatPool_Record_Implementation.ModifyStatPool(context, record);
    };
  }

  public final static func ModifyStatPool(context: ScriptExecutionContext, record: wref<AISubActionModifyStatPool_Record>) -> Void {
    if IsDefined(record.StatPool()) && record.Amount() != 0.00 {
      GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RequestChangingStatPoolValue(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), record.StatPool().StatPoolType(), record.Amount(), null, false, record.Perc());
    };
  }
}

public abstract class AISubActionForceDeath_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionForceDeath_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionForceDeath_Record_Implementation.ForceDeath(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionForceDeath_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionForceDeath_Record_Implementation.ForceDeath(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionForceDeath_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionForceDeath_Record_Implementation.ForceDeath(context, record);
    };
  }

  public final static func ForceDeath(context: ScriptExecutionContext, record: wref<AISubActionForceDeath_Record>) -> Void {
    let forcedDeathEvent: ref<ForcedDeathEvent> = new ForcedDeathEvent();
    forcedDeathEvent.hitIntensity = record.HitIntensity();
    forcedDeathEvent.hitSource = record.HitSource();
    forcedDeathEvent.hitBodyPart = record.HitBodyPart();
    forcedDeathEvent.hitDirection = record.HitDirection();
    ScriptExecutionContext.GetOwner(context).QueueEvent(forcedDeathEvent);
  }
}

public abstract class AISubActionStatusEffect_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionStatusEffect_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionStatusEffect_Record_Implementation.ApplyRemoveStatusEffect(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionStatusEffect_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionStatusEffect_Record_Implementation.ApplyRemoveStatusEffect(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionStatusEffect_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionStatusEffect_Record_Implementation.ApplyRemoveStatusEffect(context, record);
    } else {
      if record.Remove() {
        AISubActionStatusEffect_Record_Implementation.RemoveStatusEffect(context, record);
      };
    };
  }

  public final static func ApplyRemoveStatusEffect(context: ScriptExecutionContext, record: wref<AISubActionStatusEffect_Record>) -> Void {
    if record.Apply() {
      AISubActionStatusEffect_Record_Implementation.ApplyStatusEffect(context, record);
    } else {
      if record.Remove() {
        AISubActionStatusEffect_Record_Implementation.RemoveStatusEffect(context, record);
      };
    };
  }

  public final static func ApplyStatusEffect(context: ScriptExecutionContext, record: wref<AISubActionStatusEffect_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let target: wref<GameObject>;
    if !AIActionTarget.GetObject(context, record.Target(), target) {
      return;
    };
    count = record.GetStatusEffectsCount();
    i = 0;
    while i < count {
      GameInstance.GetStatusEffectSystem(ScriptExecutionContext.GetOwner(context).GetGame()).ApplyStatusEffect(target.GetEntityID(), record.GetStatusEffectsItem(i).GetID());
      i += 1;
    };
  }

  public final static func RemoveStatusEffect(context: ScriptExecutionContext, record: wref<AISubActionStatusEffect_Record>) -> Void {
    let count: Int32;
    let i: Int32;
    let target: wref<GameObject>;
    if !AIActionTarget.GetObject(context, record.Target(), target) {
      return;
    };
    count = record.GetStatusEffectsCount();
    i = 0;
    while i < count {
      GameInstance.GetStatusEffectSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RemoveStatusEffect(target.GetEntityID(), record.GetStatusEffectsItem(i).GetID());
      i += 1;
    };
  }
}

public abstract class AISubActionGameplayLogicPackage_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionGameplayLogicPackage_Record>) -> Void {
    AISubActionGameplayLogicPackage_Record_Implementation.ApplyGameplayLogicPackage(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionGameplayLogicPackage_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionGameplayLogicPackage_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionGameplayLogicPackage_Record_Implementation.RemoveGameplayLogicPackage(context, record);
  }

  public final static func ApplyGameplayLogicPackage(context: ScriptExecutionContext, record: wref<AISubActionGameplayLogicPackage_Record>) -> Void {
    let count: Int32 = record.GetPackagesCount();
    let i: Int32 = 0;
    while i < count {
      GameInstance.GetGameplayLogicPackageSystem(ScriptExecutionContext.GetOwner(context).GetGame()).ApplyPackage(ScriptExecutionContext.GetOwner(context), ScriptExecutionContext.GetOwner(context), record.GetPackagesItem(i).GetID());
      i += 1;
    };
  }

  public final static func RemoveGameplayLogicPackage(context: ScriptExecutionContext, record: wref<AISubActionGameplayLogicPackage_Record>) -> Void {
    let count: Int32 = record.GetPackagesCount();
    let i: Int32 = 0;
    while i < count {
      GameInstance.GetGameplayLogicPackageSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RemovePackage(ScriptExecutionContext.GetOwner(context), record.GetPackagesItem(i).GetID());
      i += 1;
    };
  }
}

public abstract class AISubActionSetInt_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetInt_Record>) -> Void {
    if record.Delay() == 0.00 {
      ScriptExecutionContext.SetArgumentInt(context, record.Name(), record.Value());
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetInt_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      ScriptExecutionContext.SetArgumentInt(context, record.Name(), record.Value());
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetInt_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      ScriptExecutionContext.SetArgumentInt(context, record.Name(), record.Value());
    };
  }
}

public abstract class AISubActionReloadWeapon_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionReloadWeapon_Record>) -> Void {
    let weapon: wref<WeaponObject>;
    if !AISubActionReloadWeapon_Record_Implementation.GetWeapon(context, record, weapon) {
      return;
    };
    weapon.StartReload(record.Duration());
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.EnterReload);
    AnimationControllerComponent.PushEventToReplicate(weapon, n"Reload");
    AnimationControllerComponent.PushEventToReplicate(ScriptExecutionContext.GetOwner(context), n"Reload");
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionReloadWeapon_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let i: Int32;
    let weapon: wref<WeaponObject>;
    let count: Int32 = record.GetPauseConditionCount();
    if count > 0 {
      i = 0;
      while i < count {
        if AICondition.CheckActionCondition(context, record.GetPauseConditionItem(i)) {
        } else {
          i += 1;
        };
      };
      if i < count {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
    };
    if !AISubActionReloadWeapon_Record_Implementation.GetWeapon(context, record, weapon) {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    if duration >= record.Duration() {
      weapon.StopReload(gameweaponReloadStatus.Standard);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionReloadWeapon_Record>, const duration: Float, interrupted: Bool) -> Void {
    let weapon: wref<WeaponObject>;
    if duration < record.Duration() && AISubActionReloadWeapon_Record_Implementation.GetWeapon(context, record, weapon) {
      weapon.StopReload(gameweaponReloadStatus.Interrupted);
      WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.ExitReload);
      WeaponObject.SendAmmoUpdateEvent(ScriptExecutionContext.GetOwner(context), weapon);
      AnimationControllerComponent.PushEventToReplicate(weapon, n"InterruptReload");
      AnimationControllerComponent.PushEventToReplicate(ScriptExecutionContext.GetOwner(context), n"InterruptReload");
    };
  }

  public final static func GetWeapon(context: ScriptExecutionContext, record: wref<AISubActionReloadWeapon_Record>, out weapon: wref<WeaponObject>) -> Bool {
    weapon = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.WeaponSlot().GetID()) as WeaponObject;
    return weapon != null;
  }
}

public abstract class AISubActionTriggerStim_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionTriggerStim_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionTriggerStim_Record_Implementation.TriggerStim(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionTriggerStim_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionTriggerStim_Record_Implementation.TriggerStim(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionTriggerStim_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionTriggerStim_Record_Implementation.TriggerStim(context, record);
    };
  }

  public final static func TriggerStim(context: ScriptExecutionContext, record: wref<AISubActionTriggerStim_Record>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let directTarget: wref<GameObject>;
    let sourceObj: wref<GameObject>;
    if AIActionTarget.GetObject(context, record.StimSource(), sourceObj) {
      broadcaster = sourceObj.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        if record.Direct() {
          if AIActionTarget.GetObject(context, record.Target(), directTarget) {
            broadcaster.SendDrirectStimuliToTarget(ScriptExecutionContext.GetOwner(context), record.StimType().Type(), directTarget);
          };
        } else {
          broadcaster.TriggerSingleBroadcast(ScriptExecutionContext.GetOwner(context), record.StimType().Type(), record.Radius());
        };
      };
    };
  }
}

public abstract class AISubActionChangeAttitude_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionChangeAttitude_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionChangeAttitude_Record_Implementation.ChangeAttitude(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionChangeAttitude_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionChangeAttitude_Record_Implementation.ChangeAttitude(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionChangeAttitude_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionChangeAttitude_Record_Implementation.ChangeAttitude(context, record);
    };
  }

  public final static func ChangeAttitude(context: ScriptExecutionContext, record: wref<AISubActionChangeAttitude_Record>) -> Void {
    let attitudeOwner: ref<AttitudeAgent>;
    let attitudeTarget: ref<AttitudeAgent>;
    let desiredAttitude: EAIAttitude;
    let target: wref<GameObject>;
    if !AIActionTarget.GetObject(context, record.Target(), target) {
      return;
    };
    desiredAttitude = IntEnum(Cast(EnumValueFromName(n"EAIAttitude", record.Attitude())));
    if Equals(desiredAttitude, EAIAttitude.AIA_Hostile) {
      AIActionHelper.TryChangingAttitudeToHostile(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, target);
      return;
    };
    attitudeOwner = ScriptExecutionContext.GetOwner(context).GetAttitudeAgent();
    attitudeTarget = target.GetAttitudeAgent();
    if IsDefined(attitudeOwner) && IsDefined(attitudeTarget) && NotEquals(attitudeOwner.GetAttitudeTowards(attitudeTarget), desiredAttitude) {
      attitudeOwner.SetAttitudeTowardsAgentGroup(attitudeTarget, attitudeOwner, desiredAttitude);
    };
  }
}

public abstract class AISubActionThrowItem_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionThrowItem_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionThrowItem_Record_Implementation.ThrowItem(context, record);
    };
    if record.Delay() > 0.00 {
      AISubActionThrowItem_Record_Implementation.ThrowInit(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionThrowItem_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      if !AISubActionThrowItem_Record_Implementation.ThrowItem(context, record) {
        return AIbehaviorUpdateOutcome.FAILURE;
      };
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionThrowItem_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionThrowItem_Record_Implementation.ThrowItem(context, record);
    };
    if record.Delay() > 0.00 && ScriptExecutionContext.GetOwner(context).IsNPC() {
      (ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetAIControllerComponent().NULLCachedThrowGrenadeAtTargetQuery();
    };
    if record.DropItemOnInterruption() {
      AISubActionThrowItem_Record_Implementation.DropItem(context, record);
    };
  }

  public final static func ThrowInit(context: ScriptExecutionContext, record: wref<AISubActionThrowItem_Record>) -> Void {
    let target: wref<GameObject>;
    if IsDefined(record.Target()) && !AIActionTarget.GetObject(context, record.Target(), target) {
      return;
    };
    if IsDefined(target) && ScriptExecutionContext.GetOwner(context).IsNPC() {
      (ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetAIControllerComponent().CacheThrowGrenadeAtTargetQuery(target);
    };
  }

  public final static func GetCachedGrenadeQuery(context: ScriptExecutionContext, out targetPosition: Vector4, out throwAngle: Float, outStartType: gameGrenadeThrowStartType) -> Bool {
    if !ScriptExecutionContext.GetOwner(context).IsNPC() {
      return false;
    };
    throwAngle = (ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetAIControllerComponent().GetCombatGadgetBlackboard().GetFloat(GetAllBlackboardDefs().CombatGadget.lastThrowAngle);
    if throwAngle == 0.00 {
      return false;
    };
    outStartType = FromVariant((ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetAIControllerComponent().GetCombatGadgetBlackboard().GetVariant(GetAllBlackboardDefs().CombatGadget.lastThrowStartType));
    if Equals(outStartType, gameGrenadeThrowStartType.Invalid) {
      return false;
    };
    targetPosition = (ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetAIControllerComponent().GetCombatGadgetBlackboard().GetVector4(GetAllBlackboardDefs().CombatGadget.lastThrowPosition);
    return true;
  }

  public final static func ThrowItem(context: ScriptExecutionContext, record: wref<AISubActionThrowItem_Record>) -> Bool {
    let angleToTarget: Float;
    let isGrenade: Bool;
    let item: wref<ItemObject>;
    let launchEvent: ref<gameprojectileSetUpAndLaunchEvent>;
    let ownerPuppet: ref<gamePuppet>;
    let startType: gameGrenadeThrowStartType;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let targetVelocity: Vector4;
    let throwAngle: Float;
    if !IsDefined(record.AttachmentSlot()) || !IsDefined(record.Target()) {
      return false;
    };
    ownerPuppet = ScriptExecutionContext.GetOwner(context);
    item = GameInstance.GetTransactionSystem(ownerPuppet.GetGame()).GetItemInSlot(ownerPuppet, record.AttachmentSlot().GetID());
    if !IsDefined(item) {
      return false;
    };
    if IsDefined(record.Target()) && !AIActionTarget.Get(context, record.Target(), false, target, targetPosition) {
      return false;
    };
    isGrenade = (item as BaseGrenade) != null;
    if isGrenade {
      if !AISubActionThrowItem_Record_Implementation.GetCachedGrenadeQuery(context, targetPosition, throwAngle, startType) && IsDefined(target) && ownerPuppet.IsNPC() {
        if record.CheckThrowQuery() && !(ownerPuppet as NPCPuppet).GetAIControllerComponent().CanThrowGrenadeAtTarget(target, targetPosition, throwAngle, startType) {
          return false;
        };
      };
      if !IsDefined(target) {
        throwAngle = record.ThrowAngle();
      };
      AISubActionThrowItem_Record_Implementation.SetNPCThrowingGrenade(context);
    } else {
      ScriptExecutionContext.SetArgumentObject(context, n"TargetItem", item);
      throwAngle = record.ThrowAngle();
      targetPosition = ownerPuppet.GetWorldPosition() + ownerPuppet.GetWorldForward() * 15.00;
      if IsDefined(target) {
        angleToTarget = Vector4.GetAngleDegAroundAxis(target.GetWorldPosition() - ownerPuppet.GetWorldPosition(), ownerPuppet.GetWorldForward(), ownerPuppet.GetWorldUp());
        if AbsF(angleToTarget) <= 70.00 {
          AIActionHelper.GetTargetSlotPosition(target, n"Chest", targetPosition);
          if record.PositionPredictionTime() > 0.00 && IsDefined(target as gamePuppet) {
            targetVelocity = (target as gamePuppet).GetVelocity();
            targetVelocity.Z = 0.00;
            targetPosition += Vector4.ClampLength(targetVelocity, 0.00, 4.50) * record.PositionPredictionTime();
          };
        };
      };
      targetPosition = ownerPuppet.GetWorldPosition() + Vector4.ClampLength(targetPosition - ownerPuppet.GetWorldPosition(), 7.50, 20.00);
    };
    launchEvent = new gameprojectileSetUpAndLaunchEvent();
    launchEvent.launchParams.launchMode = gameprojectileELaunchMode.FromVisuals;
    launchEvent.launchParams.logicalPositionProvider = IPositionProvider.CreateEntityPositionProvider(item);
    launchEvent.launchParams.logicalOrientationProvider = IOrientationProvider.CreateEntityOrientationProvider(null, n"", ownerPuppet);
    launchEvent.launchParams.visualPositionProvider = IPositionProvider.CreateEntityPositionProvider(item);
    launchEvent.launchParams.visualOrientationProvider = IOrientationProvider.CreateEntityOrientationProvider(null, n"", item);
    launchEvent.launchParams.ownerVelocityProvider = MoveComponentVelocityProvider.CreateMoveComponentVelocityProvider(ownerPuppet);
    launchEvent.lerpMultiplier = 15.00;
    launchEvent.owner = ownerPuppet;
    launchEvent.trajectoryParams = ParabolicTrajectoryParams.GetAccelTargetAngleParabolicParams(new Vector4(0.00, 0.00, record.TrajectoryGravity(), 0.00), targetPosition, throwAngle);
    launchEvent.projectileParams.shootingOffset = 2.00;
    if isGrenade {
      item.QueueEvent(launchEvent);
      GameInstance.GetTransactionSystem(ownerPuppet.GetGame()).RemoveItemFromSlot(ownerPuppet, record.AttachmentSlot().GetID(), false);
    } else {
      GameInstance.GetTransactionSystem(ownerPuppet.GetGame()).ThrowItem(ownerPuppet, item, launchEvent);
    };
    return true;
  }

  public final static func DropItem(context: ScriptExecutionContext, record: wref<AISubActionThrowItem_Record>) -> Void {
    let dir: Vector4;
    let item: wref<ItemObject>;
    let launchEvent: ref<gameprojectileSetUpAndLaunchEvent>;
    let orientation: Quaternion;
    let ownerPuppet: ref<gamePuppet>;
    let rot: EulerAngles;
    if !IsDefined(record.AttachmentSlot()) {
      return;
    };
    ownerPuppet = ScriptExecutionContext.GetOwner(context);
    item = GameInstance.GetTransactionSystem(ownerPuppet.GetGame()).GetItemInSlot(ownerPuppet, record.AttachmentSlot().GetID());
    if !IsDefined(item) {
      return;
    };
    launchEvent = new gameprojectileSetUpAndLaunchEvent();
    dir = ownerPuppet.GetWorldUp() * -1.00;
    rot = Vector4.ToRotation(dir);
    orientation = EulerAngles.ToQuat(rot);
    launchEvent.launchParams.logicalPositionProvider = IPositionProvider.CreateEntityPositionProvider(item);
    launchEvent.launchParams.logicalOrientationProvider = IOrientationProvider.CreateStaticOrientationProvider(orientation);
    Quaternion.SetIdentity(orientation);
    launchEvent.launchParams.visualPositionProvider = IPositionProvider.CreateEntityPositionProvider(item);
    launchEvent.launchParams.visualOrientationProvider = IOrientationProvider.CreateStaticOrientationProvider(orientation);
    launchEvent.launchParams.ownerVelocityProvider = MoveComponentVelocityProvider.CreateMoveComponentVelocityProvider(ownerPuppet);
    launchEvent.owner = ownerPuppet;
    launchEvent.trajectoryParams = ParabolicTrajectoryParams.GetAccelVelParabolicParams(new Vector4(0.00, 0.00, -9.80, 0.00), 0.10);
    item.QueueEvent(launchEvent);
    GameInstance.GetTransactionSystem(ownerPuppet.GetGame()).RemoveItemFromSlot(ownerPuppet, record.AttachmentSlot().GetID(), false);
  }

  protected final static func SetNPCThrowingGrenade(context: ScriptExecutionContext) -> Void {
    let combatTarget: wref<GameObject>;
    let throwingGrenadeEvent: ref<NPCThrowingGrenadeEvent>;
    let achievement: gamedataAchievement = gamedataAchievement.Denied;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(ScriptExecutionContext.GetOwner(context).GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) {
      return;
    };
    combatTarget = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
    if IsDefined(combatTarget) {
      throwingGrenadeEvent = new NPCThrowingGrenadeEvent();
      throwingGrenadeEvent.target = combatTarget;
      ScriptExecutionContext.GetOwner(context).QueueEvent(throwingGrenadeEvent);
    };
  }
}

public abstract class AISubActionTriggerItemActivation_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionTriggerItemActivation_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionTriggerItemActivation_Record_Implementation.TriggerActivation(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionTriggerItemActivation_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionTriggerItemActivation_Record_Implementation.TriggerActivation(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionTriggerItemActivation_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionTriggerItemActivation_Record_Implementation.TriggerActivation(context, record);
    };
  }

  public final static func TriggerActivation(context: ScriptExecutionContext, record: wref<AISubActionTriggerItemActivation_Record>) -> Void {
    let forceActivationEvent: ref<gameprojectileForceActivationEvent>;
    let item: wref<ItemObject>;
    let launchEvent: ref<gameprojectileSetUpAndLaunchEvent>;
    let orientation: Quaternion;
    let ownerPuppet: ref<gamePuppet>;
    if !IsDefined(record.AttachmentSlot()) {
      return;
    };
    ownerPuppet = ScriptExecutionContext.GetOwner(context);
    item = GameInstance.GetTransactionSystem(ownerPuppet.GetGame()).GetItemInSlot(ownerPuppet, record.AttachmentSlot().GetID());
    if !IsDefined(item) {
      return;
    };
    launchEvent = new gameprojectileSetUpAndLaunchEvent();
    forceActivationEvent = new gameprojectileForceActivationEvent();
    GameInstance.GetTransactionSystem(ownerPuppet.GetGame()).RemoveItemFromSlot(ownerPuppet, record.AttachmentSlot().GetID(), false);
    launchEvent.launchParams.logicalPositionProvider = IPositionProvider.CreateEntityPositionProvider(item);
    launchEvent.launchParams.logicalOrientationProvider = IOrientationProvider.CreateEntityOrientationProvider(null, n"", ownerPuppet);
    launchEvent.launchParams.visualPositionProvider = IPositionProvider.CreateEntityPositionProvider(item);
    Quaternion.SetIdentity(orientation);
    launchEvent.launchParams.visualOrientationProvider = IOrientationProvider.CreateStaticOrientationProvider(orientation);
    launchEvent.launchParams.ownerVelocityProvider = MoveComponentVelocityProvider.CreateMoveComponentVelocityProvider(ownerPuppet);
    launchEvent.owner = ownerPuppet;
    item.QueueEvent(launchEvent);
    item.QueueEvent(forceActivationEvent);
    return;
  }
}

public abstract class AISubActionAttackWithWeapon_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionAttackWithWeapon_Record>) -> Void {
    if record.AttackTime() == 0.00 {
      AISubActionAttackWithWeapon_Record_Implementation.AttackWithWeapon(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionAttackWithWeapon_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let weapon: wref<WeaponObject>;
    if AISubActionAttackWithWeapon_Record_Implementation.GetWeapon(context, record, weapon) && weapon.IsContinuousAttackStarted() {
      if duration >= record.AttackTime() + record.AttackDuration() {
        if weapon.IsContinuousAttackStarted() {
          GameObject.ToggleForcedVisibilityInAnimSystemEvent(ScriptExecutionContext.GetOwner(context), n"ContinuousAttack", false);
          GameObject.ToggleForcedVisibilityInAnimSystemEvent(weapon, n"ContinuousAttack", false);
        };
        weapon.StopContinuousAttack();
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
    } else {
      if record.AttackTime() > 0.00 && duration >= record.AttackTime() {
        return AISubActionAttackWithWeapon_Record_Implementation.AttackWithWeapon(context, record);
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionAttackWithWeapon_Record>, const duration: Float, interrupted: Bool) -> Void {
    let weapon: wref<WeaponObject>;
    if record.AttackTime() < 0.00 {
      AISubActionAttackWithWeapon_Record_Implementation.AttackWithWeapon(context, record);
    };
    if AISubActionAttackWithWeapon_Record_Implementation.GetWeapon(context, record, weapon) && weapon.IsContinuousAttackStarted() {
      weapon.StopContinuousAttack();
      GameObject.ToggleForcedVisibilityInAnimSystemEvent(ScriptExecutionContext.GetOwner(context), n"ContinuousAttack", false);
      GameObject.ToggleForcedVisibilityInAnimSystemEvent(weapon, n"ContinuousAttack", false);
    };
  }

  public final static func AttackWithWeapon(context: ScriptExecutionContext, record: wref<AISubActionAttackWithWeapon_Record>) -> AIbehaviorUpdateOutcome {
    let attack: wref<Attack_GameEffect>;
    let effect: wref<EffectInstance>;
    let isQuickMelee: Bool;
    let weapon: wref<WeaponObject>;
    let weaponType: gamedataItemType;
    if !AISubActionAttackWithWeapon_Record_Implementation.GetWeapon(context, record, weapon) {
      LogAIError("AISubActionAttackWithWeapon:::No Weapon found in slot!");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    weapon.QueueEventForEntityID(weapon.GetEntityID(), new SetWeaponOwnerEvent());
    if IsDefined(record.Attack()) && !weapon.SetAttack(record.Attack().GetID()) {
      LogAIError("AISubActionAttackWithWeapon:::Failed to set Attack: " + record.Attack().AttackName());
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    attack = weapon.GetCurrentAttack() as Attack_GameEffect;
    if !IsDefined(attack) {
      LogAIError("AISubActionAttackWithWeapon::: Attack_GameEffect for current attack is null! Aborting melee attack initiation.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if IsDefined(attack as Attack_Continuous) {
      AISubActionAttackWithWeapon_Record_Implementation.StartContinuousAttack(context, weapon);
      AISubActionAttackWithWeapon_Record_Implementation.SetAttackNameInBlackBoard(context, record.AttackName());
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    effect = attack.PrepareAttack(ScriptExecutionContext.GetOwner(context));
    if weapon.IsMelee() {
      weapon.AI_SetAttackData(attack);
    };
    if !IsDefined(effect) {
      LogAIError("AISubActionAttackWithWeapon:::GameEffect is null! Aborting melee attack initiation.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    AISubActionAttackWithWeapon_Record_Implementation.StartAttack(context, record, weapon, attack, effect);
    AISubActionAttackWithWeapon_Record_Implementation.SetAttackNameInBlackBoard(context, record.AttackName());
    weaponType = WeaponObject.GetWeaponType(weapon.GetItemID());
    switch weaponType {
      case gamedataItemType.Wea_TwoHandedClub:
      case gamedataItemType.Wea_ShortBlade:
      case gamedataItemType.Wea_OneHandedClub:
      case gamedataItemType.Wea_LongBlade:
      case gamedataItemType.Wea_Katana:
      case gamedataItemType.Wea_Hammer:
      case gamedataItemType.Wea_Melee:
      case gamedataItemType.Wea_Knife:
      case gamedataItemType.Wea_Fists:
        isQuickMelee = false;
        break;
      default:
        isQuickMelee = true;
    };
    weapon.AI_PlayMeleeAttackSound(isQuickMelee);
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  public final static func StartContinuousAttack(context: ScriptExecutionContext, weapon: wref<WeaponObject>) -> Void {
    weapon.StartContinuousAttack(weapon.GetWorldPosition(), weapon.GetWorldForward());
    GameObject.ToggleForcedVisibilityInAnimSystemEvent(weapon, n"ContinuousAttack", true);
    GameObject.ToggleForcedVisibilityInAnimSystemEvent(ScriptExecutionContext.GetOwner(context), n"ContinuousAttack", true);
  }

  public final static func StartAttack(context: ScriptExecutionContext, record: wref<AISubActionAttackWithWeapon_Record>, weapon: wref<WeaponObject>, attack: wref<Attack_GameEffect>, effect: wref<EffectInstance>) -> Void {
    let attackDirection: gamedataMeleeAttackDirection;
    let attackDirectionWorld: Vector4;
    let attackEndPositionWorld: Vector4;
    let attackStartPositionWorld: Vector4;
    let attackTransform: Transform;
    let colliderBoxSizeV3: Vector3;
    let colliderBoxSizeV4: Vector4;
    let direction: Vector4;
    let duration: Float;
    let endPosition: Vector4;
    let position: Vector4;
    let rotation: Quaternion;
    let startPosition: Vector4;
    let yOffset: Float;
    let range: Float = record.AttackRange();
    if range < 0.00 {
      range = attack.GetRecord().Range();
    };
    colliderBoxSizeV3 = record.ColliderBoxSize();
    if colliderBoxSizeV3.Y <= 0.00 {
      colliderBoxSizeV4 = new Vector4(colliderBoxSizeV3.X, range * 0.50, colliderBoxSizeV3.Z, 0.00);
    } else {
      colliderBoxSizeV4 = new Vector4(colliderBoxSizeV3.X, colliderBoxSizeV3.Y, colliderBoxSizeV3.Z, 0.00);
    };
    duration = record.AttackDuration();
    yOffset = colliderBoxSizeV4.Y * 0.50 + 0.10;
    Transform.SetPosition(attackTransform, ScriptExecutionContext.GetOwner(context).GetWorldPosition());
    attackTransform.position.Z += 1.50;
    Transform.SetOrientationFromDir(attackTransform, ScriptExecutionContext.GetOwner(context).GetWorldForward());
    attackDirection = (record.Attack() as Attack_Melee_Record).AttackDirection().Direction().Type();
    if Equals(attackDirection, gamedataMeleeAttackDirection.Center) {
      startPosition = new Vector4(0.00, yOffset, 0.00, 0.00);
      endPosition = new Vector4(0.00, 0.00, 0.00, 0.00);
    } else {
      if Equals(attackDirection, gamedataMeleeAttackDirection.DownToUp) {
        startPosition = new Vector4(0.00, yOffset, -0.50, 0.00);
        endPosition = new Vector4(0.00, 0.00, 0.30, 0.00);
      } else {
        if Equals(attackDirection, gamedataMeleeAttackDirection.LeftDownToRightUp) {
          startPosition = new Vector4(-0.50, yOffset, -0.50, 0.00);
          endPosition = new Vector4(0.50, 0.00, 0.30, 0.00);
        } else {
          if Equals(attackDirection, gamedataMeleeAttackDirection.LeftToRight) {
            startPosition = new Vector4(-0.50, yOffset, 0.00, 0.00);
            endPosition = new Vector4(0.50, 0.00, 0.00, 0.00);
          } else {
            if Equals(attackDirection, gamedataMeleeAttackDirection.LeftUpToRightDown) {
              startPosition = new Vector4(-0.50, yOffset, 0.30, 0.00);
              endPosition = new Vector4(0.50, 0.00, -0.50, 0.00);
            } else {
              if Equals(attackDirection, gamedataMeleeAttackDirection.RightDownToLeftUp) {
                startPosition = new Vector4(0.50, yOffset, -0.50, 0.00);
                endPosition = new Vector4(-0.50, 0.00, 0.30, 0.00);
              } else {
                if Equals(attackDirection, gamedataMeleeAttackDirection.RightToLeft) {
                  startPosition = new Vector4(0.50, yOffset, 0.00, 0.00);
                  endPosition = new Vector4(-0.50, 0.00, 0.00, 0.00);
                } else {
                  if Equals(attackDirection, gamedataMeleeAttackDirection.RightUpToLeftDown) {
                    startPosition = new Vector4(0.50, yOffset, 0.30, 0.00);
                    endPosition = new Vector4(-0.50, 0.00, -0.50, 0.00);
                  } else {
                    if Equals(attackDirection, gamedataMeleeAttackDirection.UpToDown) {
                      startPosition = new Vector4(0.00, yOffset, 0.30, 0.00);
                      endPosition = new Vector4(0.00, 0.00, -0.50, 0.00);
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    endPosition.Y = range - colliderBoxSizeV4.Y * 0.50;
    attackStartPositionWorld = Transform.TransformPoint(attackTransform, startPosition);
    attackEndPositionWorld = Transform.TransformPoint(attackTransform, endPosition);
    attackDirectionWorld = attackEndPositionWorld - attackStartPositionWorld;
    position = attackStartPositionWorld;
    rotation = attackTransform.orientation;
    direction = Vector4.Normalize(attackDirectionWorld);
    range = Vector4.Length(attackDirectionWorld);
    EffectDataHelper.FillMeleeEffectData(effect.GetSharedData(), colliderBoxSizeV4, duration, position, rotation, direction, range);
    attack.StartAttack();
  }

  public final static func GetWeapon(context: ScriptExecutionContext, record: wref<AISubActionAttackWithWeapon_Record>, out weapon: wref<WeaponObject>) -> Bool {
    let count: Int32 = record.GetWeaponSlotsCount();
    let i: Int32 = 0;
    while i < count {
      weapon = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.GetWeaponSlotsItem(i).GetID()) as WeaponObject;
      if IsDefined(weapon) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func SetAttackNameInBlackBoard(context: ScriptExecutionContext, const attackName: CName) -> Void {
    let blackBoard: ref<IBlackboard>;
    if NotEquals(attackName, n"") {
      blackBoard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
      blackBoard.SetName(GetAllBlackboardDefs().AIAction.ownerLastAttackName, attackName);
    };
    blackBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerLastAttackTimeStamp, EngineTime.ToFloat(GameInstance.GetSimTime(ScriptExecutionContext.GetOwner(context).GetGame())));
  }
}

public abstract class AISubActionRegisterActionName_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionRegisterActionName_Record>) -> Void {
    AISubActionAttackWithWeapon_Record_Implementation.SetAttackNameInBlackBoard(context, record.ActionName());
  }
}

public abstract class AISubActionMeleeAttackManager_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionMeleeAttackManager_Record>) -> Void {
    let blackBoard: ref<IBlackboard>;
    let weapons: array<wref<ItemObject>>;
    if record.SpawnTrail() && record.TrailDelay() <= 0.00 {
      blackBoard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
      AIActionHelper.GetItemsFromWeaponSlots(ScriptExecutionContext.GetOwner(context), weapons);
      blackBoard.SetBool(GetAllBlackboardDefs().AIAction.weaponTrailInitialised, true);
      AISubActionMeleeAttackManager_Record_Implementation.startWeaponTrailEffect(context, weapons);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionMeleeAttackManager_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let weapons: array<wref<ItemObject>>;
    let blackBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if record.SpawnTrail() {
      if record.TrailDelay() > 0.00 && duration >= record.TrailDelay() && !blackBoard.GetBool(GetAllBlackboardDefs().AIAction.weaponTrailInitialised) {
        blackBoard.SetBool(GetAllBlackboardDefs().AIAction.weaponTrailInitialised, true);
        AIActionHelper.GetItemsFromWeaponSlots(ScriptExecutionContext.GetOwner(context), weapons);
        AISubActionMeleeAttackManager_Record_Implementation.startWeaponTrailEffect(context, weapons);
      };
      if record.TrailDuration() >= 0.00 && !blackBoard.GetBool(GetAllBlackboardDefs().AIAction.weaponTrailAborted) {
        if record.TrailDelay() >= 0.00 && duration >= record.TrailDelay() + record.TrailDuration() {
          blackBoard.SetBool(GetAllBlackboardDefs().AIAction.weaponTrailAborted, true);
          AIActionHelper.GetItemsFromWeaponSlots(ScriptExecutionContext.GetOwner(context), weapons);
          AISubActionMeleeAttackManager_Record_Implementation.stopWeaponTrailEffect(context, weapons);
        } else {
          if duration >= record.TrailDuration() {
            blackBoard.SetBool(GetAllBlackboardDefs().AIAction.weaponTrailAborted, true);
            AIActionHelper.GetItemsFromWeaponSlots(ScriptExecutionContext.GetOwner(context), weapons);
            AISubActionMeleeAttackManager_Record_Implementation.stopWeaponTrailEffect(context, weapons);
          };
        };
      };
    };
    if record.SpawnTrail() && !blackBoard.GetBool(GetAllBlackboardDefs().AIAction.weaponTrailAborted) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionMeleeAttackManager_Record>, const duration: Float, interrupted: Bool) -> Void {
    let weapons: array<wref<ItemObject>>;
    let blackBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if record.SpawnTrail() {
      if blackBoard.GetBool(GetAllBlackboardDefs().AIAction.weaponTrailInitialised) && !blackBoard.GetBool(GetAllBlackboardDefs().AIAction.weaponTrailAborted) {
        AIActionHelper.GetItemsFromWeaponSlots(ScriptExecutionContext.GetOwner(context), weapons);
        AISubActionMeleeAttackManager_Record_Implementation.stopWeaponTrailEffect(context, weapons);
      };
      blackBoard.SetBool(GetAllBlackboardDefs().AIAction.weaponTrailInitialised, false);
      blackBoard.SetBool(GetAllBlackboardDefs().AIAction.weaponTrailAborted, false);
    };
  }

  public final static func startWeaponTrailEffect(context: ScriptExecutionContext, weapons: array<wref<ItemObject>>) -> Void {
    let weaponRecord: ref<WeaponItem_Record>;
    let i: Int32 = 0;
    while i < ArraySize(weapons) {
      weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weapons[i].GetItemID())) as WeaponItem_Record;
      if Equals(weaponRecord.ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
        AISubActionMeleeAttackManager_Record_Implementation.startStrongArmsTrailEffect(ScriptExecutionContext.GetOwner(context), weapons[i]);
      } else {
        (weapons[i] as WeaponObject).StartCurrentMeleeTrailEffect();
      };
      i += 1;
    };
  }

  public final static func startStrongArmsTrailEffect(owner: ref<GameObject>, weapon: ref<ItemObject>) -> Void {
    let trailName: CName = AIActionHelper.GetCurrentStrongArmsTrailEffect(weapon);
    GameObjectEffectHelper.StartEffectEvent(owner, trailName);
  }

  public final static func stopWeaponTrailEffect(context: ScriptExecutionContext, weapons: array<wref<ItemObject>>) -> Void {
    let weaponRecord: ref<WeaponItem_Record>;
    let i: Int32 = 0;
    while i < ArraySize(weapons) {
      weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weapons[i].GetItemID())) as WeaponItem_Record;
      if Equals(weaponRecord.ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
        AISubActionMeleeAttackManager_Record_Implementation.stopStrongArmsTrailEffect(ScriptExecutionContext.GetOwner(context), weapons[i]);
      } else {
        (weapons[i] as WeaponObject).StopCurrentMeleeTrailEffect();
      };
      i += 1;
    };
  }

  public final static func stopStrongArmsTrailEffect(owner: ref<GameObject>, weapon: ref<ItemObject>) -> Void {
    let trailName: CName = AIActionHelper.GetCurrentStrongArmsTrailEffect(weapon);
    GameObjectEffectHelper.BreakEffectLoopEvent(owner, trailName);
  }
}

public abstract class AISubActionShootToPoint_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionShootToPoint_Record>) -> Void {
    AISubActionShootWithWeapon_Record_Implementation.Activate(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionShootToPoint_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AISubActionShootWithWeapon_Record_Implementation.Update(context, record, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionShootToPoint_Record>, const duration: Float, interrupted: Bool) -> Void {
    return AISubActionShootWithWeapon_Record_Implementation.Deactivate(context, record, duration, interrupted);
  }
}

public abstract class AISubActionMissileRainGrid_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionMissileRainGrid_Record>) -> Void {
    AISubActionShootWithWeapon_Record_Implementation.Activate(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionMissileRainGrid_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AISubActionShootWithWeapon_Record_Implementation.Update(context, record, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionMissileRainGrid_Record>, const duration: Float, interrupted: Bool) -> Void {
    return AISubActionShootWithWeapon_Record_Implementation.Deactivate(context, record, duration, interrupted);
  }
}

public abstract class AISubActionMissileRainCircular_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionMissileRainCircular_Record>) -> Void {
    AISubActionShootWithWeapon_Record_Implementation.Activate(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionMissileRainCircular_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AISubActionShootWithWeapon_Record_Implementation.Update(context, record, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionMissileRainCircular_Record>, const duration: Float, interrupted: Bool) -> Void {
    return AISubActionShootWithWeapon_Record_Implementation.Deactivate(context, record, duration, interrupted);
  }
}

public abstract class AISubActionShootWithWeapon_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionShootWithWeapon_Record>) -> Void {
    let desiredNumberOfShots: Int32;
    let i: Int32;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let weaponRecord: wref<WeaponItem_Record>;
    let weapons: array<wref<WeaponObject>>;
    if !AISubActionShootWithWeapon_Record_Implementation.GetWeapon(context, record, weapons) {
      return;
    };
    i = 0;
    while i < ArraySize(weapons) {
      if IsDefined(record.TriggerMode()) {
        WeaponObject.ChangeTriggerMode(weapons[i], record.TriggerMode().Type());
        weapons[i].GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.requestedTriggerMode, EnumInt(record.TriggerMode().Type()));
      } else {
        weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weapons[i].GetItemID())) as WeaponItem_Record;
        if AIActionHelper.WeaponHasTriggerMode(weapons[i], weaponRecord, gamedataTriggerMode.Burst) {
          weapons[i].GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.requestedTriggerMode, EnumInt(gamedataTriggerMode.Burst));
        } else {
          if Equals(weaponRecord.PrimaryTriggerMode().Type(), gamedataTriggerMode.Charge) {
            weapons[i].GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.requestedTriggerMode, EnumInt(gamedataTriggerMode.SemiAuto));
          } else {
            weapons[i].GetAIBlackboard().SetInt(GetAllBlackboardDefs().AIShooting.requestedTriggerMode, EnumInt(weaponRecord.PrimaryTriggerMode().Type()));
          };
        };
      };
      AIActionTarget.Get(context, record.Target(), false, target, targetPosition);
      AIWeapon.SelectShootingPattern(record, weapons[i], ScriptExecutionContext.GetOwner(context), true);
      if record.MaxNumberOfShots() > record.NumberOfShots() {
        desiredNumberOfShots = RandRange(record.NumberOfShots(), record.MaxNumberOfShots());
      } else {
        desiredNumberOfShots = record.NumberOfShots();
      };
      AIWeapon.OnStartShooting(weapons[i], desiredNumberOfShots);
      AISubActionShootWithWeapon_Record_Implementation.QueueFirstShot(weapons[i]);
      i += 1;
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionShootWithWeapon_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let chargeLevel: Float;
    let count: Int32;
    let didShoot: Bool;
    let i: Int32;
    let j: Int32;
    let numberOfShots: Int32;
    let requestedTriggerMode: gamedataTriggerMode;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let vehicle: wref<VehicleObject>;
    let weapons: array<wref<WeaponObject>>;
    if !AISubActionShootWithWeapon_Record_Implementation.GetWeapon(context, record, weapons) {
      LogAIError("AISubActionShootWithWeapon:::No Weapon found in slot!");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if record.Delay() > 0.00 && duration < record.Delay() {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    count = record.GetPauseConditionCount();
    if count > 0 {
      i = 0;
      while i < count {
        if AICondition.CheckActionCondition(context, record.GetPauseConditionItem(i)) {
        } else {
          i += 1;
        };
      };
      if i < count {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
    };
    i = 0;
    if ArraySize(weapons) > 1 && Equals(record.DualWieldShootingStyle(), n"Sequence") {
      j = 0;
      while j < ArraySize(weapons) {
        numberOfShots += AIWeapon.GetTotalNumberOfShots(weapons[j]);
        j += 1;
      };
      if numberOfShots % 2 != 0 {
        i = 1;
      };
    };
    while i < ArraySize(weapons) {
      if !weapons[i].IsAttached() {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
      if AIWeapon.HasExceededDesiredNumberOfShots(weapons[i]) {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
      GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).RequestSettingStatPoolValue(Cast(weapons[i].GetEntityID()), gamedataStatPoolType.WeaponCharge, chargeLevel, ScriptExecutionContext.GetOwner(context));
      if duration < AIWeapon.GetNextShotTimeStamp(weapons[i]) {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
      requestedTriggerMode = AIActionHelper.GetLastRequestedTriggerMode(weapons[i]);
      if Equals(requestedTriggerMode, gamedataTriggerMode.Charge) && AIWeapon.UpdateCharging(weapons[i], duration, ScriptExecutionContext.GetOwner(context), chargeLevel) {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
      AIActionTarget.Get(context, record.Target(), false, target, targetPosition);
      didShoot = false;
      if record.IsA(n"gamedataAISubActionShootToPoint_Record") {
        didShoot = AISubActionShootWithWeapon_Record_Implementation.ShootToPoints(context, record as AISubActionShootToPoint_Record, weapons[i], requestedTriggerMode, duration);
      } else {
        if record.IsA(n"gamedataAISubActionMissileRainGrid_Record") {
          didShoot = AISubActionShootWithWeapon_Record_Implementation.ShootMissileRainGrid(context, record as AISubActionMissileRainGrid_Record, weapons[i], requestedTriggerMode, target, targetPosition, duration);
        } else {
          if record.IsA(n"gamedataAISubActionMissileRainCircular_Record") {
            didShoot = AISubActionShootWithWeapon_Record_Implementation.ShootMissileRainCircular(context, record as AISubActionMissileRainCircular_Record, weapons[i], requestedTriggerMode, target, targetPosition, duration);
          };
        };
      };
      if !didShoot {
        if target.IsPlayer() {
          if VehicleComponent.GetVehicle(target.GetGame(), target.GetEntityID(), vehicle) {
            if IsDefined(vehicle as TankObject) {
              target = vehicle;
            };
          };
        };
        AISubActionShootWithWeapon_Record_Implementation.Shoot(context, record, duration, weapons[i], requestedTriggerMode, targetPosition, target, record.PredictionTime());
      };
      AISubActionShootWithWeapon_Record_Implementation.QueueNextShot(weapons[i], requestedTriggerMode, duration);
      if Equals(record.DualWieldShootingStyle(), n"Sequence") {
        j = 0;
        while j < ArraySize(weapons) {
          weapons[j].GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp, weapons[i].GetAIBlackboard().GetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp));
          j += 1;
        };
      } else {
        i += 1;
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionShootWithWeapon_Record>, const duration: Float, interrupted: Bool) -> Void {
    let i: Int32;
    let weapons: array<wref<WeaponObject>>;
    if !AISubActionShootWithWeapon_Record_Implementation.GetWeapon(context, record, weapons) {
      return;
    };
    i = 0;
    while i < ArraySize(weapons) {
      AIWeapon.OnStopShooting(weapons[i], duration);
      WeaponObject.ChangeTriggerMode(weapons[i], weapons[i].GetWeaponRecord().PrimaryTriggerMode().Type());
      i += 1;
    };
  }

  public final static func Shoot(context: ScriptExecutionContext, record: wref<AISubActionShootWithWeapon_Record>, const duration: Float, weapon: wref<WeaponObject>, requestedTriggerMode: gamedataTriggerMode, targetPosition: Vector4, target: wref<GameObject>, opt offset: Vector4, opt predictionTime: Float) -> Void {
    let rangedAttack: TweakDBID;
    if IsDefined(record.RangedAttack()) {
      rangedAttack = record.RangedAttack().GetID();
    };
    AIWeapon.Fire(ScriptExecutionContext.GetOwner(context), weapon, duration, record.TbhCoefficient(), requestedTriggerMode, targetPosition, target, rangedAttack, 0.00, record.AimingDelay(), Vector4.Vector3To4(record.TargetOffset()) + offset, AISubActionShootWithWeapon_Record_Implementation.ShouldTrackTarget(ScriptExecutionContext.GetOwner(context), record, weapon), predictionTime);
  }

  private final static func ShouldTrackTarget(owner: wref<gamePuppet>, record: wref<AISubActionShootWithWeapon_Record>, weapon: wref<WeaponObject>) -> Bool {
    if IsDefined(record as AISubActionMissileRainGrid_Record) || IsDefined(record as AISubActionMissileRainCircular_Record) {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"WeaponJam") {
      return false;
    };
    return Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID())).Evolution().Type(), gamedataWeaponEvolution.Smart) && weapon.IsTargetLocked();
  }

  public final static func QueueNextShot(weapon: wref<WeaponObject>, requestedTriggerMode: gamedataTriggerMode, const duration: Float) -> Void {
    let delayFromPattern: Float;
    let pattern: wref<AIPattern_Record> = AIWeapon.GetShootingPattern(weapon);
    if IsDefined(pattern) {
      delayFromPattern = AIWeapon.GetShootingPatternDelayBetweenShots(AIWeapon.GetTotalNumberOfShots(weapon), pattern);
    };
    AIWeapon.QueueNextShot(weapon, requestedTriggerMode, duration, delayFromPattern);
  }

  public final static func QueueFirstShot(weapon: wref<WeaponObject>) -> Void {
    let delayFromPattern: Float;
    let pattern: wref<AIPattern_Record> = AIWeapon.GetShootingPattern(weapon);
    if IsDefined(pattern) {
      delayFromPattern = AIWeapon.GetShootingPatternDelayBetweenShots(0, pattern);
    };
    weapon.GetAIBlackboard().SetFloat(GetAllBlackboardDefs().AIShooting.nextShotTimeStamp, delayFromPattern);
  }

  public final static func ShootToPoints(context: ScriptExecutionContext, record: wref<AISubActionShootToPoint_Record>, weapon: wref<WeaponObject>, requestedTriggerMode: gamedataTriggerMode, duration: Float) -> Bool {
    let coordinateArray: array<Vector4>;
    let coordinateArrayV3: array<Vector3>;
    let i: Int32;
    let scriptedPuppet: ref<ScriptedPuppet>;
    let shootPointPosition: array<Vector4>;
    let target: wref<GameObject>;
    let targetPositionObj: wref<GameObject>;
    let waypointTag: array<CName>;
    if !IsDefined(record) {
      return false;
    };
    coordinateArrayV3 = record.PointPosition();
    waypointTag = record.WaypointTag();
    if ArraySize(coordinateArrayV3) > 0 {
      AIActionTarget.GetObject(context, record.TargetPositionObj(), targetPositionObj);
      coordinateArray = AISubActionShootWithWeapon_Record_Implementation.ConvertVector3ArrayToVector4Array(coordinateArrayV3);
      AISubActionShootWithWeapon_Record_Implementation.SetShootPointsByCoordinate(context, targetPositionObj, coordinateArray, shootPointPosition);
    } else {
      if ArraySize(waypointTag) > 0 {
        AISubActionShootWithWeapon_Record_Implementation.SetShootPointsBytag(context, waypointTag, shootPointPosition);
      } else {
        return false;
      };
    };
    if ArraySize(shootPointPosition) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(shootPointPosition) {
      AISubActionShootWithWeapon_Record_Implementation.Shoot(context, record, duration, weapon, requestedTriggerMode, shootPointPosition[i], target);
      i += 1;
    };
    scriptedPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if scriptedPuppet.IsBoss() {
      GameObject.StartReplicatedEffectEvent(scriptedPuppet, n"rocket_flaps_heat");
    };
    return true;
  }

  private final static func ShootMissileRainGrid(context: ScriptExecutionContext, record: wref<AISubActionMissileRainGrid_Record>, weapon: wref<WeaponObject>, requestedTriggerMode: gamedataTriggerMode, target: wref<GameObject>, targetPosition: Vector4, duration: Float) -> Bool {
    let i: Int32;
    let missileOffsets: array<Vector3>;
    let numMissiles: Int32;
    let scriptedPuppet: ref<ScriptedPuppet>;
    if !IsDefined(record) {
      return false;
    };
    missileOffsets = record.MissileOffsets();
    numMissiles = ArraySize(missileOffsets);
    if numMissiles == 0 {
      return false;
    };
    i = 0;
    while i < numMissiles {
      AISubActionShootWithWeapon_Record_Implementation.Shoot(context, record, duration, weapon, requestedTriggerMode, targetPosition, target, Vector4.Vector3To4(missileOffsets[i]));
      i += 1;
    };
    scriptedPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if scriptedPuppet.IsBoss() {
      GameObject.StartReplicatedEffectEvent(scriptedPuppet, n"rocket_flaps_heat");
    };
    return true;
  }

  private final static func ShootMissileRainCircular(context: ScriptExecutionContext, record: wref<AISubActionMissileRainCircular_Record>, weapon: wref<WeaponObject>, requestedTriggerMode: gamedataTriggerMode, target: wref<GameObject>, targetPosition: Vector4, duration: Float) -> Bool {
    let i: Int32;
    let maxRadius: Float;
    let minRadius: Float;
    let missilesPerLaunch: Int32;
    let scriptedPuppet: ref<ScriptedPuppet>;
    if !IsDefined(record) {
      return false;
    };
    minRadius = record.MinRadius();
    maxRadius = record.MaxRadius();
    missilesPerLaunch = record.MissilesPerLaunch();
    if minRadius > maxRadius || missilesPerLaunch < 1 {
      return false;
    };
    scriptedPuppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    i = 0;
    while i < missilesPerLaunch {
      AISubActionShootWithWeapon_Record_Implementation.Shoot(context, record, duration, weapon, requestedTriggerMode, targetPosition, target, Vector4.RandRing(minRadius, maxRadius));
      i += 1;
    };
    if scriptedPuppet.IsBoss() {
      GameObject.StartReplicatedEffectEvent(scriptedPuppet, n"rocket_flaps_heat");
    };
    return true;
  }

  public final static func SetShootPointsBytag(context: ScriptExecutionContext, tags: array<CName>, out shootPointPosition: array<Vector4>) -> Bool {
    let targetsPosition: array<Vector4>;
    if ArraySize(tags) <= 0 {
      return false;
    };
    GameInstance.FindWaypointsByTag(ScriptExecutionContext.GetOwner(context).GetGame(), tags[0], targetsPosition);
    shootPointPosition = targetsPosition;
    return true;
  }

  public final static func ConvertVector3ArrayToVector4Array(v3: array<Vector3>) -> array<Vector4> {
    let tempVector4: Vector4;
    let tempVector4Array: array<Vector4>;
    let i: Int32 = 0;
    while i < ArraySize(v3) {
      tempVector4.X = v3[i].X;
      tempVector4.Y = v3[i].Y;
      tempVector4.Z = v3[i].Z;
      ArrayPush(tempVector4Array, tempVector4);
      i += 1;
    };
    return tempVector4Array;
  }

  public final static func SetShootPointsByCoordinate(context: ScriptExecutionContext, target: wref<GameObject>, coordinateArray: array<Vector4>, out shootPointPosition: array<Vector4>) -> Bool {
    let tempVector: Vector4;
    let targetPosition: Vector4 = target.GetWorldPosition();
    let i: Int32 = 0;
    while i < ArraySize(coordinateArray) {
      tempVector = targetPosition + coordinateArray[i];
      ArrayPush(shootPointPosition, tempVector);
      i += 1;
    };
    return true;
  }

  public final static func GetWeapon(context: ScriptExecutionContext, record: wref<AISubActionShootWithWeapon_Record>, out weaponsList: array<wref<WeaponObject>>) -> Bool {
    let weapon: wref<WeaponObject>;
    let count: Int32 = record.GetWeaponSlotsCount();
    let i: Int32 = 0;
    while i < count {
      weapon = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), record.GetWeaponSlotsItem(i).GetID()) as WeaponObject;
      if IsDefined(weapon) {
        ArrayPush(weaponsList, weapon);
      };
      i += 1;
    };
    return ArraySize(weaponsList) > 0;
  }
}

public abstract class AISubActionCreateGameEffect_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionCreateGameEffect_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionCreateGameEffect_Record_Implementation.CreateGameEffect(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCreateGameEffect_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionCreateGameEffect_Record_Implementation.CreateGameEffect(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionCreateGameEffect_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionCreateGameEffect_Record_Implementation.CreateGameEffect(context, record);
    };
  }

  public final static func CreateGameEffect(context: ScriptExecutionContext, record: wref<AISubActionCreateGameEffect_Record>) -> Void {
    let colliderBoxSize: Vector3;
    let positionObj: wref<GameObject>;
    let rotationObj: wref<GameObject>;
    let target: wref<GameObject>;
    let targetPositionObj: wref<GameObject>;
    let vecToTarget: Vector4;
    let effect: ref<EffectInstance> = GameInstance.GetGameEffectSystem(ScriptExecutionContext.GetOwner(context).GetGame()).CreateEffectStatic(record.EffectName(), record.EffectTag(), ScriptExecutionContext.GetOwner(context));
    if !IsDefined(effect) {
      return;
    };
    if AIActionTarget.GetObject(context, record.Target(), target) {
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, target.GetWorldPosition());
      EffectData.SetEntity(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, target);
      effect.Run();
      return;
    };
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, record.Duration());
    if AIActionTarget.GetObject(context, record.PositionObj(), positionObj) {
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, positionObj.GetWorldPosition());
    };
    if !IsDefined(positionObj) {
      LogAIError("CreateGameEffect:::No object provided to take the position from!!!");
      return;
    };
    if IsDefined(positionObj) && AIActionTarget.GetObject(context, record.TargetPositionObj(), targetPositionObj) {
      vecToTarget = targetPositionObj.GetWorldPosition() - positionObj.GetWorldPosition();
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, Vector4.Length(vecToTarget));
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, Vector4.Length(vecToTarget));
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, Vector4.Normalize(vecToTarget));
      EffectData.SetQuat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Quaternion.BuildFromDirectionVector(vecToTarget, positionObj.GetWorldUp()));
    } else {
      if AIActionTarget.GetObject(context, record.RotationObj(), rotationObj) {
        EffectData.SetQuat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, rotationObj.GetWorldOrientation());
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, rotationObj.GetWorldForward());
      } else {
        EffectData.SetQuat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, positionObj.GetWorldOrientation());
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, positionObj.GetWorldForward());
      };
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, record.Range());
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, record.Range());
    };
    colliderBoxSize = record.ColliderBoxSize();
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.box, new Vector4(colliderBoxSize.X, colliderBoxSize.Y, colliderBoxSize.Z, 0.00));
    effect.Run();
  }
}

public abstract class AISubActionSetWaypointByTag_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetWaypointByTag_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetWaypointByTag_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AISubActionSetTargetByTag_Record_Implementation.Update(context, record, duration);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetWaypointByTag_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionSetTargetByTag_Record_Implementation.Deactivate(context, record, duration, interrupted);
  }
}

public abstract class AISubActionSetTargetByTag_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetTargetByTag_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetTargetByTag_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() >= 0.00 && duration >= record.Delay() {
      if AISubActionSetTargetByTag_Record_Implementation.SetTargetByTag(context, record) {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetTargetByTag_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionSetTargetByTag_Record_Implementation.SetTargetByTag(context, record);
    };
  }

  public final static func SetTargetByTag(context: ScriptExecutionContext, record: wref<AISubActionSetTargetByTag_Record>) -> Bool {
    let BBoard: ref<IBlackboard>;
    let allowedOffMeshTags: array<CName>;
    let desiredDistance: Vector2;
    let desiredDistanceFromObj: Vector2;
    let excludedWaypoints: array<Vector4>;
    let i: Int32;
    let index: Int32;
    let lineOfSightTargetPosition: Vector4;
    let positions: array<Vector4>;
    let target: wref<Entity>;
    let targetPosition: Vector4;
    let targets: array<ref<Entity>>;
    let targetsObject: array<ref<Entity>>;
    let toOwnerDistances: array<Float>;
    let toTargetsDistances: array<Float>;
    if !IsNameValid(record.Tag()) {
      return false;
    };
    AIActionTarget.GetPosition(context, record.RangeObj(), targetPosition, false);
    desiredDistance = record.RangeFromOwner();
    desiredDistanceFromObj = record.RangeFromObj();
    allowedOffMeshTags = record.AllowedOffMeshTags();
    BBoard = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(record.LineOfSightTarget()) {
      AIActionTarget.GetPosition(context, record.RangeObj(), lineOfSightTargetPosition, false);
    };
    if IsDefined(record as AISubActionSetWaypointByTag_Record) {
      GameInstance.FindWaypointsByTag(ScriptExecutionContext.GetOwner(context).GetGame(), record.Tag(), positions);
      if record.AvoidSelectingSameTargetMethod() == 1 && record.Target().IsPosition() {
        if !Vector4.IsZero(targetPosition) {
          index = ArrayFindFirst(positions, targetPosition);
          if index >= 0 {
            ArrayErase(positions, index);
          };
          targetPosition = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
          index = -1;
        };
      };
      if record.AvoidSelectingSameTargetMethod() == 2 && record.Target().IsPosition() {
        if !Vector4.IsZero(targetPosition) {
          excludedWaypoints = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().AIActionBossData.excludedWaypointPosition));
          if ArraySize(excludedWaypoints) > 0 {
            i = 0;
            while i < ArraySize(positions) {
              if ArrayContains(excludedWaypoints, positions[i]) {
                ArrayErase(positions, i);
                i -= 1;
              };
              i += 1;
            };
          };
        };
      };
    } else {
      GameInstance.GetGameTagSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetAllMatchingEntities(record.Tag(), targetsObject);
      AISubActionSetTargetByTag_Record_Implementation.GetPositionsFromEntity(context, targetsObject, positions);
    };
    AISubActionSetTargetByTag_Record_Implementation.GetDistancesFromPosition(context, positions, toOwnerDistances);
    AISubActionSetTargetByTag_Record_Implementation.GetDistancesFromPosition(context, positions, toTargetsDistances);
    index = AISubActionSetTargetByTag_Record_Implementation.SelectIndex(context, record.SelectionMethod(), desiredDistance.X, desiredDistance.Y, toOwnerDistances, desiredDistanceFromObj.X, desiredDistanceFromObj.Y, toTargetsDistances, positions, allowedOffMeshTags, lineOfSightTargetPosition);
    if index >= 0 {
      if ArraySize(targets) > 0 {
        target = targets[index];
        if IsDefined(target) {
          targetPosition = target.GetWorldPosition();
        };
      } else {
        if ArraySize(positions) > 0 {
          targetPosition = positions[index];
        };
      };
    } else {
      targetPosition = Vector4.EmptyVector();
    };
    if !Vector4.IsZero(targetPosition) {
      if record.AvoidSelectingSameTargetMethod() == 2 {
        ArrayPush(excludedWaypoints, targetPosition);
        BBoard.SetVariant(GetAllBlackboardDefs().AIActionBossData.excludedWaypointPosition, ToVariant(excludedWaypoints));
      };
      if (targetsObject[index] as ItemObject) == null || (targetsObject[index] as ItemObject).IsConnectedWithDrop() {
        AIActionTarget.Set(context, record.Target(), (targetsObject[index] as ItemObject).GetConnectedItemDrop(), targetPosition);
      };
      return true;
    };
    return false;
  }

  public final static func GetDistancesFromPosition(context: ScriptExecutionContext, const targets: array<Vector4>, out distances: array<Float>) -> Bool {
    let i: Int32;
    let ownerRefVector: Vector4;
    if ArraySize(targets) <= 0 {
      return false;
    };
    ownerRefVector = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    ArrayClear(distances);
    ArrayResize(distances, ArraySize(targets));
    i = 0;
    while i < ArraySize(targets) {
      distances[i] = Vector4.Distance(ownerRefVector, targets[i]);
      i += 1;
    };
    return ArraySize(distances) > 0;
  }

  public final static func GetDistancesFromEntity(context: ScriptExecutionContext, const targets: array<ref<Entity>>, out distances: array<Float>) -> Bool {
    let i: Int32;
    let ownerRefVector: Vector4;
    if ArraySize(targets) <= 0 {
      return false;
    };
    ownerRefVector = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    ArrayClear(distances);
    ArrayResize(distances, ArraySize(targets));
    i = 0;
    while i < ArraySize(targets) {
      distances[i] = Vector4.Distance(ownerRefVector, targets[i].GetWorldPosition());
      i += 1;
    };
    return ArraySize(distances) > 0;
  }

  public final static func GetPositionsFromEntity(context: ScriptExecutionContext, const targets: array<ref<Entity>>, out positions: array<Vector4>) -> Bool {
    let i: Int32;
    if ArraySize(targets) <= 0 {
      return false;
    };
    ArrayClear(positions);
    ArrayResize(positions, ArraySize(targets));
    i = 0;
    while i < ArraySize(targets) {
      positions[i] = targets[i].GetWorldPosition();
      i += 1;
    };
    return ArraySize(positions) > 0;
  }

  public final static func SelectIndex(context: ScriptExecutionContext, selectionPreference: CName, minDistance: Float, maxDistance: Float, distances: array<Float>, minDistanceObj: Float, maxDistanceObj: Float, distancesObj: array<Float>, opt targetsPosition: array<Vector4>, allowedOffMeshTags: array<CName>, lineOfSightTarget: Vector4) -> Int32 {
    if ArraySize(distances) == 0 {
      return -1;
    };
    if Equals(selectionPreference, n"Farthest") {
      return AISubActionSetTargetByTag_Record_Implementation.GetFarthestIndexInRange(context, minDistance, maxDistance, distances, minDistanceObj, maxDistanceObj, distancesObj, targetsPosition, allowedOffMeshTags, lineOfSightTarget);
    };
    if Equals(selectionPreference, n"Closest") {
      return AISubActionSetTargetByTag_Record_Implementation.GetClosestIndexInRange(context, minDistance, maxDistance, distances, minDistanceObj, maxDistanceObj, distancesObj, targetsPosition, allowedOffMeshTags, lineOfSightTarget);
    };
    return AISubActionSetTargetByTag_Record_Implementation.GetRandomIndexInRange(context, minDistance, maxDistance, distances, minDistanceObj, maxDistanceObj, distancesObj, allowedOffMeshTags, targetsPosition, lineOfSightTarget);
  }

  public final static func CheckPath(context: ScriptExecutionContext, startPosition: Vector4, endPosition: Vector4, opt offMeshTags: array<CName>) -> Bool {
    let end: AIPositionSpec;
    let endWP: WorldPosition;
    let navigationSystem: ref<AINavigationSystem>;
    let pathfindingResult: Bool;
    let query: AINavigationSystemQuery;
    let requestID: Uint32;
    let result: AINavigationSystemResult;
    let start: AIPositionSpec;
    let startWP: WorldPosition;
    WorldPosition.SetVector4(startWP, startPosition);
    WorldPosition.SetVector4(endWP, endPosition);
    AIPositionSpec.SetWorldPosition(start, startWP);
    AIPositionSpec.SetWorldPosition(end, endWP);
    if ArraySize(offMeshTags) > 0 {
      query.allowedTags = offMeshTags;
    };
    query.source = start;
    query.target = end;
    navigationSystem = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    requestID = navigationSystem.StartPathfinding(query);
    pathfindingResult = navigationSystem.GetResult(requestID, result);
    navigationSystem.StopPathfinding(requestID);
    if pathfindingResult {
      if !result.hasFailed {
        return true;
      };
    };
    return false;
  }

  public final static func GetClosestIndexInRange(context: ScriptExecutionContext, minDistance: Float, maxDistance: Float, distances: array<Float>, minDistanceObj: Float, maxDistanceObj: Float, distancesObj: array<Float>, opt targetsPosition: array<Vector4>, allowedOffMeshTags: array<CName>, lineOfSightTarget: Vector4) -> Int32 {
    let Offset: Vector4;
    let distance: Float;
    let distanceObj: Float;
    let i: Int32;
    let k: Int32;
    if maxDistanceObj < 0.00 {
      maxDistanceObj = 9999.00;
    };
    if !AISubActionSetTargetByTag_Record_Implementation.CheckPath(context, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), lineOfSightTarget, allowedOffMeshTags) {
      lineOfSightTarget = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    };
    distance = maxDistance;
    distanceObj = maxDistanceObj;
    i = 0;
    k = -1;
    Offset.Z = 2.00;
    i = 0;
    while i < ArraySize(distances) {
      if GameInstance.GetSenseManager(ScriptExecutionContext.GetOwner(context).GetGame()).IsPositionVisible(lineOfSightTarget + Offset, targetsPosition[i] + Offset) || Vector4.IsZero(lineOfSightTarget) {
        if distances[i] >= minDistance && distancesObj[i] >= minDistanceObj || minDistance < 0.00 && minDistanceObj < 0.00 {
          if distances[i] <= maxDistance && distancesObj[i] <= maxDistanceObj || maxDistance < 0.00 && maxDistanceObj == 9999.00 {
            if distances[i] < distance && distancesObj[i] < distanceObj && distance >= 0.00 {
              if ArraySize(targetsPosition) != 0 {
                if AISubActionSetTargetByTag_Record_Implementation.CheckPath(context, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), targetsPosition[i], allowedOffMeshTags) {
                  distance = distances[i];
                  distanceObj = distancesObj[i];
                  k = i;
                };
              };
            };
          };
        };
      };
      i += 1;
    };
    return k;
  }

  public final static func GetFarthestIndexInRange(context: ScriptExecutionContext, minDistance: Float, maxDistance: Float, distances: array<Float>, minDistanceObj: Float, maxDistanceObj: Float, distancesObj: array<Float>, opt targetsPosition: array<Vector4>, allowedOffMeshTags: array<CName>, lineOfSightTarget: Vector4) -> Int32 {
    let Offset: Vector4;
    let distance: Float;
    let distanceObj: Float;
    let i: Int32;
    let k: Int32;
    if maxDistanceObj < 0.00 {
      maxDistanceObj = 9999.00;
    };
    if !AISubActionSetTargetByTag_Record_Implementation.CheckPath(context, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), lineOfSightTarget, allowedOffMeshTags) {
      lineOfSightTarget = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    };
    distance = minDistance;
    distanceObj = minDistanceObj;
    k = -1;
    Offset.Z = 2.00;
    i = 0;
    while i < ArraySize(distances) {
      if GameInstance.GetSenseManager(ScriptExecutionContext.GetOwner(context).GetGame()).IsPositionVisible(lineOfSightTarget + Offset, targetsPosition[i] + Offset) || Vector4.IsZero(lineOfSightTarget) {
        if distances[i] >= minDistance && distancesObj[i] >= minDistanceObj || minDistance < 0.00 && minDistanceObj < 0.00 || Vector4.IsZero(lineOfSightTarget) {
          if distances[i] <= maxDistance && distancesObj[i] <= maxDistanceObj || maxDistance < 0.00 && maxDistanceObj == 9999.00 {
            if distances[i] > distance && distance >= 0.00 && distancesObj[i] > distanceObj {
              if ArraySize(targetsPosition) != 0 {
                if AISubActionSetTargetByTag_Record_Implementation.CheckPath(context, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), targetsPosition[i], allowedOffMeshTags) {
                  distance = distances[i];
                  distanceObj = distancesObj[i];
                  k = i;
                };
              };
            };
          };
        };
      };
      i += 1;
    };
    return k;
  }

  public final static func GetRandomIndexInRange(context: ScriptExecutionContext, minDistance: Float, maxDistance: Float, distances: array<Float>, minDistanceObj: Float, maxDistanceObj: Float, distancesObj: array<Float>, allowedOffMeshTags: array<CName>, opt targetsPosition: array<Vector4>, lineOfSightTarget: Vector4) -> Int32 {
    let Offset: Vector4;
    let filteredIndexes: array<Int32>;
    let i: Int32;
    let k: Int32;
    if maxDistanceObj < 0.00 {
      maxDistanceObj = 9999.00;
    };
    if !AISubActionSetTargetByTag_Record_Implementation.CheckPath(context, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), lineOfSightTarget, allowedOffMeshTags) {
      lineOfSightTarget = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    };
    k = -1;
    Offset.Z = 2.00;
    i = 0;
    while i < ArraySize(distances) {
      if GameInstance.GetSenseManager(ScriptExecutionContext.GetOwner(context).GetGame()).IsPositionVisible(lineOfSightTarget + Offset, targetsPosition[i] + Offset) || Vector4.IsZero(lineOfSightTarget) {
        if distances[i] >= minDistance && distancesObj[i] >= minDistanceObj || minDistance < 0.00 && minDistanceObj < 0.00 {
          if distances[i] <= maxDistance && distancesObj[i] <= maxDistanceObj || maxDistance < 0.00 && maxDistanceObj == 9999.00 {
            if ArraySize(targetsPosition) != 0 {
              if AISubActionSetTargetByTag_Record_Implementation.CheckPath(context, ScriptExecutionContext.GetOwner(context).GetWorldPosition(), targetsPosition[i], allowedOffMeshTags) {
                ArrayPush(filteredIndexes, i);
              };
            };
          };
        };
      };
      i += 1;
    };
    if ArraySize(filteredIndexes) > 0 {
      k = filteredIndexes[RandRange(0, ArraySize(filteredIndexes))];
    };
    return k;
  }
}

public abstract class AISubActionSetInfluenceMap_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetInfluenceMap_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionSetInfluenceMap_Record_Implementation.SetInfluenceMap(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetInfluenceMap_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionSetInfluenceMap_Record_Implementation.SetInfluenceMap(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetInfluenceMap_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionSetInfluenceMap_Record_Implementation.SetInfluenceMap(context, record);
    };
  }

  public final static func SetInfluenceMap(context: ScriptExecutionContext, record: wref<AISubActionSetInfluenceMap_Record>) -> Void {
    let lerp: Vector2;
    let object: wref<GameObject>;
    if AIActionTarget.GetObject(context, record.PositionObj(), object) {
      lerp = record.Lerp();
      if !record.Threat() {
        if lerp.X >= 0.00 && lerp.Y >= 0.00 {
          GameInstance.GetInfluenceMapSystem(ScriptExecutionContext.GetOwner(context).GetGame()).SetSearchValueLerp(object.GetWorldPosition(), record.Radius(), lerp.X, lerp.Y);
        } else {
          GameInstance.GetInfluenceMapSystem(ScriptExecutionContext.GetOwner(context).GetGame()).SetSearchValue(object.GetWorldPosition(), record.Radius());
        };
      };
    };
  }
}

public abstract class AISubActionSetStimSource_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetStimSource_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionSetStimSource_Record_Implementation.SetStimSource(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSetStimSource_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionSetStimSource_Record_Implementation.SetStimSource(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSetStimSource_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionSetStimSource_Record_Implementation.SetStimSource(context, record);
    };
  }

  public final static func SetStimSource(context: ScriptExecutionContext, record: wref<AISubActionSetStimSource_Record>) -> Void {
    let closestDistance: Float;
    let distance: Float;
    let i: Int32;
    let investigateData: stimInvestigateData;
    let investigationPositions: array<Vector4>;
    let object: wref<GameObject>;
    let position: Vector4;
    let puppet: wref<ScriptedPuppet>;
    let reactionData: ref<AIReactionData>;
    if record.UseInvestigateData() {
      puppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
      investigateData = puppet.GetStimReactionComponent().GetActiveReactionData().stimInvestigateData;
      investigationPositions = (investigateData.controllerEntity as Device).GetNodePosition();
      i = 0;
      while i < ArraySize(investigationPositions) {
        distance = Vector4.Distance(investigationPositions[i], ScriptExecutionContext.GetOwner(context).GetWorldPosition());
        if distance < closestDistance || closestDistance == 0.00 {
          closestDistance = distance;
          position = investigationPositions[i];
        };
        i += 1;
      };
      if !Vector4.IsZero(position) {
        ScriptExecutionContext.SetArgumentVector(context, n"StimSource", position);
      } else {
        ScriptExecutionContext.SetArgumentVector(context, n"StimSource", investigateData.controllerEntity.GetWorldPosition());
      };
      ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", investigateData.controllerEntity as GameObject);
    } else {
      if record.StimTarget().IsObject() {
        if AIActionTarget.GetObject(context, record.StimTarget(), object) {
          ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", object);
          ScriptExecutionContext.SetArgumentVector(context, n"StimSource", object.GetWorldPosition());
        };
      } else {
        if record.StimTarget().IsPosition() {
          if AIActionTarget.GetPosition(context, record.StimTarget(), position, false) {
            ScriptExecutionContext.SetArgumentVector(context, n"StimSource", position);
          };
        } else {
          puppet = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
          reactionData = puppet.GetStimReactionComponent().GetDesiredReactionData();
          ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", reactionData.stimTarget);
          ScriptExecutionContext.SetArgumentVector(context, n"StimSource", reactionData.stimSource);
        };
      };
    };
  }
}

public abstract class AISubActionWorkspot_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionWorkspot_Record>) -> Void {
    AISubActionWorkspot_Record_Implementation.ReserveWorkspot(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionWorkspot_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionWorkspot_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionWorkspot_Record_Implementation.ReleaseWorkspot(context, record);
  }

  public final static func ReserveWorkspot(context: ScriptExecutionContext, record: wref<AISubActionWorkspot_Record>) -> Void {
    let object: wref<GameObject>;
    let reserveWorkspotEvent: ref<OnReserveWorkspotEvent>;
    let workspotData: ref<WorkspotEntryData>;
    if AIActionTarget.GetObject(context, record.WorkspotObject(), object) {
      reserveWorkspotEvent = new OnReserveWorkspotEvent();
      workspotData = object.GetFreeWorkspotDataForAIAction(gamedataWorkspotActionType.DeviceInvestigation);
      workspotData.isAvailable = false;
      ScriptExecutionContext.SetArgumentNodeRef(context, n"WorkspotNode", workspotData.workspotRef);
      reserveWorkspotEvent.workspotRef = workspotData.workspotRef;
      object.QueueEvent(reserveWorkspotEvent);
    };
  }

  public final static func ReleaseWorkspot(context: ScriptExecutionContext, record: wref<AISubActionWorkspot_Record>) -> Void {
    let object: wref<GameObject>;
    let releaseWorkspotEvent: ref<OnReleaseWorkspotEvent>;
    let workspotRef: NodeRef;
    if AIActionTarget.GetObject(context, record.WorkspotObject(), object) {
      releaseWorkspotEvent = new OnReleaseWorkspotEvent();
      workspotRef = ScriptExecutionContext.GetArgumentNodeRef(context, n"WorkspotNode");
      releaseWorkspotEvent.workspotRef = workspotRef;
      object.QueueEvent(releaseWorkspotEvent);
    };
  }
}

public abstract class AISubActionChangeCoverSelectionPreset_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionChangeCoverSelectionPreset_Record>) -> Void {
    let object: wref<GameObject>;
    let presetName: CName;
    let presetThreshold: Float;
    if IsNameValid(record.Preset()) {
      ScriptExecutionContext.SetArgumentName(context, n"CoverSelectionPreset", record.Preset());
      AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetName(GetAllBlackboardDefs().AICover.lastCoverPreset, record.Preset());
    } else {
      if record.FallbackToLastSelectedPreset() {
        presetName = AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetName(GetAllBlackboardDefs().AICover.lastCoverPreset);
        if IsNameValid(presetName) {
          AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetName(GetAllBlackboardDefs().AICover.lastCoverPreset, presetName);
        };
      };
    };
    AIActionTarget.GetObject(context, record.GatheringObjectCenter(), object);
    ScriptExecutionContext.SetArgumentObject(context, n"CoverGatheringCenterObject", object);
    ScriptExecutionContext.SetArgumentFloat(context, n"CoverDisablingDuration", record.CoverDisablingDuration());
    if IsNameValid(record.InitialPreset()) {
      ScriptExecutionContext.SetArgumentName(context, n"CoverSelectionInitialPreset", record.InitialPreset());
      AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetName(GetAllBlackboardDefs().AICover.lastInitialCoverPreset, record.Preset());
    } else {
      if record.FallbackToLastSelectedPreset() {
        presetName = AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetName(GetAllBlackboardDefs().AICover.lastInitialCoverPreset);
        if IsNameValid(presetName) {
          AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetName(GetAllBlackboardDefs().AICover.lastInitialCoverPreset, presetName);
        };
      };
    };
    if record.ChangeThreshold() >= 0.00 {
      ScriptExecutionContext.SetArgumentFloat(context, n"CoverSelectionChangeThreshold", record.ChangeThreshold());
      AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetFloat(GetAllBlackboardDefs().AICover.lastCoverChangeThreshold, record.ChangeThreshold());
    } else {
      if record.FallbackToLastSelectedPreset() {
        presetThreshold = AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetFloat(GetAllBlackboardDefs().AICover.lastCoverChangeThreshold);
        if presetThreshold >= 0.00 {
          AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetFloat(GetAllBlackboardDefs().AICover.lastCoverChangeThreshold, presetThreshold);
        };
      };
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionChangeCoverSelectionPreset_Record>, duration: Float) -> AIbehaviorUpdateOutcome {
    let object: wref<GameObject>;
    if !IsNameValid(ScriptExecutionContext.GetArgumentName(context, n"CoverSelectionPreset")) && !IsNameValid(ScriptExecutionContext.GetArgumentName(context, n"CoverSelectionInitialPreset")) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    AIActionTarget.GetObject(context, record.GatheringObjectCenter(), object);
    ScriptExecutionContext.SetArgumentObject(context, n"CoverGatheringCenterObject", object);
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionChangeCoverSelectionPreset_Record>, const duration: Float, interrupted: Bool) -> Void;
}

public abstract class AISubActionStartCooldown_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionStartCooldown_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionStartCooldown_Record_Implementation.StartCooldowns(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionStartCooldown_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionStartCooldown_Record_Implementation.StartCooldowns(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionStartCooldown_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionStartCooldown_Record_Implementation.StartCooldowns(context, record);
    };
  }

  public final static func StartCooldowns(context: ScriptExecutionContext, record: ref<AISubActionStartCooldown_Record>) -> Void {
    let i: Int32;
    let puppet: ref<gamePuppet>;
    let count: Int32 = record.GetCooldownsCount();
    if count > 0 {
      puppet = ScriptExecutionContext.GetOwner(context);
      i = 0;
      while i < count {
        AIActionHelper.StartCooldown(puppet, record.GetCooldownsItem(i));
        i += 1;
      };
    };
  }
}

public abstract class AISubActionSquadSync_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSquadSync_Record>) -> Void {
    AISubActionSquadSync_Record_Implementation.SquadSync(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSquadSync_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSquadSync_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionSquadSync_Record_Implementation.SquadSync(context, record);
  }

  public final static func SquadSync(context: ScriptExecutionContext, record: wref<AISubActionSquadSync_Record>) -> Void {
    let squadType: AISquadType;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    squadType = AISquadType.Combat;
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(ScriptExecutionContext.GetOwner(context), n"ResetSquadSync") {
      if record.Pull() {
        AISquadHelper.PullSquadSync(puppet, squadType);
      } else {
        puppet.GetTargetTrackerComponent().PushSquadSync(squadType);
      };
    };
  }
}

public abstract class AISubActionSecuritySystemNotification_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSecuritySystemNotification_Record>) -> Void {
    AISubActionSecuritySystemNotification_Record_Implementation.NotifySecuritySystem(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSecuritySystemNotification_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSecuritySystemNotification_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func NotifySecuritySystem(context: ScriptExecutionContext, record: wref<AISubActionSecuritySystemNotification_Record>) -> Void {
    let notificationType: ESecurityNotificationType;
    let pos: Vector4;
    let threat: wref<GameObject>;
    let threatLocation: TrackedLocation;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !AIActionTarget.GetObject(context, record.Threat(), threat) {
      AIActionHelper.GetActiveTopHostilePuppetThreat(puppet, threatLocation);
      threat = threatLocation.entity as GameObject;
    };
    notificationType = IntEnum(Cast(EnumValueFromName(n"ESecurityNotificationType", record.NotificationType().EnumName())));
    if IsDefined(threat) {
      pos = threatLocation.sharedLocation.position;
      if Vector4.IsZero(pos) {
        pos = threatLocation.location.position;
      };
      puppet.TriggerSecuritySystemNotification(pos, threat, notificationType);
    };
  }
}

public abstract class AISubActionCallSquadSearchBackUp_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionCallSquadSearchBackUp_Record>) -> Void {
    AISubActionCallSquadSearchBackUp_Record_Implementation.CallBackup(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCallSquadSearchBackUp_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionCallSquadSearchBackUp_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionCallSquadSearchBackUp_Record_Implementation.CallBackup(context, record);
  }

  public final static func CallBackup(context: ScriptExecutionContext, record: wref<AISubActionCallSquadSearchBackUp_Record>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let i: Int32;
    let members: array<wref<Entity>>;
    let psi: ref<PuppetSquadInterface>;
    AISquadHelper.GetSquadBaseInterface(ScriptExecutionContext.GetOwner(context), psi);
    members = psi.ListMembersWeak();
    ArrayRemove(members, ScriptExecutionContext.GetOwner(context));
    i = 0;
    while i < ArraySize(members) {
      broadcaster = ScriptExecutionContext.GetOwner(context).GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.SendDrirectStimuliToTarget(ScriptExecutionContext.GetOwner(context), gamedataStimType.Call, members[i] as GameObject);
      };
      i += 1;
    };
  }
}

public abstract class AISubActionQuickHack_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionQuickHack_Record>) -> Void {
    AISubActionQuickHack_Record_Implementation.VisualiseConnection(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionQuickHack_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let i: Int32;
    let count: Int32 = record.GetPauseUploadConditionCount();
    if count > 0 {
      i = 0;
      while i < count {
        if AICondition.CheckActionCondition(context, record.GetPauseUploadConditionItem(i)) {
        } else {
          i += 1;
        };
      };
      if i < count {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
    };
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionQuickHack_Record_Implementation.Hack(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionQuickHack_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionQuickHack_Record_Implementation.CancelConnection(context, record);
  }

  public final static func VisualiseConnection(context: ScriptExecutionContext, record: wref<AISubActionQuickHack_Record>) -> Void {
    let linkedStatusEffect: LinkedStatusEffect;
    let proxy: wref<GameObject>;
    let target: wref<GameObject>;
    if !AIActionTarget.GetObject(context, record.Target(), target) {
      return;
    };
    if target == ScriptExecutionContext.GetOwner(context) {
      return;
    };
    linkedStatusEffect = (target as ScriptedPuppet).GetLinkedStatusEffect();
    if !ArrayContains(linkedStatusEffect.netrunnerIDs, ScriptExecutionContext.GetOwner(context).GetEntityID()) && GameInstance.GetPlayerSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetLocalPlayerMainGameObject() == target {
      GameObjectEffectHelper.StartEffectEvent(target, n"disabling_connectivity_glitch");
    };
    proxy = AIActionTarget.GetNetrunnerProxy(context);
    if IsDefined(proxy) {
      ScriptExecutionContext.SetArgumentObject(context, n"NetrunnerProxy", proxy);
      AISubActionQuickHack_Record_Implementation.SendNetworkLinkEvent(ScriptExecutionContext.GetOwner(context), proxy, target, ScriptExecutionContext.GetOwner(context), proxy);
      AISubActionQuickHack_Record_Implementation.SendNetworkLinkEvent(ScriptExecutionContext.GetOwner(context), proxy, target, proxy, target);
    } else {
      ScriptExecutionContext.SetArgumentObject(context, n"NetrunnerProxy", null);
      AISubActionQuickHack_Record_Implementation.SendNetworkLinkEvent(ScriptExecutionContext.GetOwner(context), proxy, target, ScriptExecutionContext.GetOwner(context), target);
    };
  }

  public final static func CancelConnection(context: ScriptExecutionContext, record: wref<AISubActionQuickHack_Record>) -> Void {
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetSignalTable();
    if IsDefined(signalTable) {
      signalId = signalTable.GetOrCreateSignal(n"HackingCompleted");
      if !signalTable.GetCurrentValue(signalId) {
        StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"AIQuickHackStatusEffect.HackingInterrupted", ScriptExecutionContext.GetOwner(context).GetEntityID());
      };
    };
    ScriptExecutionContext.SetArgumentObject(context, n"NetrunnerProxy", null);
  }

  public final static func Hack(context: ScriptExecutionContext, record: wref<AISubActionQuickHack_Record>) -> Void {
    let evt: ref<HackPlayerEvent>;
    let target: wref<GameObject>;
    if !AIActionTarget.GetObject(context, record.Target(), target) {
      return;
    };
    evt = new HackPlayerEvent();
    evt.targetID = target.GetEntityID();
    evt.netrunnerID = ScriptExecutionContext.GetOwner(context).GetEntityID();
    evt.objectRecord = record.ActionResult();
    target.QueueEvent(evt);
  }

  public final static func SendNetworkLinkEvent(netrunner: wref<GameObject>, proxy: wref<GameObject>, target: wref<GameObject>, from: wref<GameObject>, to: wref<GameObject>) -> Void {
    let evt: ref<NetworkLinkQuickhackEvent> = new NetworkLinkQuickhackEvent();
    evt.netrunnerID = netrunner.GetEntityID();
    evt.proxyID = proxy.GetEntityID();
    evt.targetID = target.GetEntityID();
    evt.from = from.GetEntityID();
    evt.to = to.GetEntityID();
    from.QueueEvent(evt);
  }
}

public abstract class AISubActionForceHitReaction_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionForceHitReaction_Record>) -> Void {
    let directTarget: wref<GameObject>;
    if record.Delay() == 0.00 {
      AIActionTarget.GetObject(context, record.Target(), directTarget);
      if record.HitType() == 0 {
        AISubActionForceHitReaction_Record_Implementation.SendForcedTwitchDataToAnimationGraph(directTarget, record.HitDirection(), record.HitIntensity(), record.HitType(), record.HitBodyPart(), record.Stance(), record.AnimVariation(), record.HitSource());
      } else {
        AISubActionForceHitReaction_Record_Implementation.SendForcedHitDataToAIBehavior(directTarget, record.HitDirection(), record.HitIntensity(), record.HitType(), record.HitBodyPart(), record.Stance(), record.AnimVariation(), record.HitSource());
      };
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionForceHitReaction_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let directTarget: wref<GameObject>;
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AIActionTarget.GetObject(context, record.Target(), directTarget);
      if record.HitType() == 1 {
        AISubActionForceHitReaction_Record_Implementation.SendForcedTwitchDataToAnimationGraph(directTarget, record.HitDirection(), record.HitIntensity(), record.HitType(), record.HitBodyPart(), record.Stance(), record.AnimVariation(), record.HitSource());
      } else {
        AISubActionForceHitReaction_Record_Implementation.SendForcedHitDataToAIBehavior(directTarget, record.HitDirection(), record.HitIntensity(), record.HitType(), record.HitBodyPart(), record.Stance(), record.AnimVariation(), record.HitSource());
      };
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionForceHitReaction_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func SendForcedTwitchDataToAnimationGraph(target: ref<GameObject>, hitDirection: Int32, hitIntensity: Int32, hitType: Int32, hitBodyPart: Int32, stance: Int32, animVariation: Int32, hitSource: Int32) -> Void {
    let animHitReaction: ref<AnimFeature_HitReactionsData> = new AnimFeature_HitReactionsData();
    animHitReaction.hitDirection = hitDirection;
    animHitReaction.hitIntensity = hitIntensity;
    animHitReaction.hitType = 0;
    animHitReaction.hitBodyPart = hitBodyPart;
    animHitReaction.stance = stance;
    animHitReaction.animVariation = animVariation;
    animHitReaction.hitSource = hitSource;
    AnimationControllerComponent.ApplyFeatureToReplicate(target, n"hit", animHitReaction);
    AnimationControllerComponent.PushEventToReplicate(target, n"hit");
  }

  public final static func SendForcedHitDataToAIBehavior(target: ref<GameObject>, hitDirection: Int32, hitIntensity: Int32, hitType: Int32, hitBodyPart: Int32, stance: Int32, animVariation: Int32, hitSource: Int32) -> Void {
    let hitAIEvent: ref<StimuliEvent> = new StimuliEvent();
    hitAIEvent.id = (target as ScriptedPuppet).GetHitReactionComponent().UpdateLastStimID();
    let hitDataEvent: ref<NewHitDataEvent> = new NewHitDataEvent();
    hitDataEvent.hitIntensity = hitIntensity;
    hitDataEvent.hitDirection = hitDirection;
    hitDataEvent.hitSource = hitSource;
    hitDataEvent.hitType = hitType;
    hitDataEvent.hitBodyPart = hitBodyPart;
    hitDataEvent.stance = stance;
    hitDataEvent.animVariation = animVariation;
    switch hitType {
      case 1:
        hitAIEvent.name = n"Twitch";
        break;
      case 2:
        hitAIEvent.name = n"Impact";
        break;
      case 3:
        hitAIEvent.name = n"Stagger";
        break;
      case 4:
        hitAIEvent.name = n"Knockdown";
        break;
      case 9:
        hitAIEvent.name = n"GuardBreak";
        break;
      default:
        return;
    };
    (target as ScriptedPuppet).GetHitReactionComponent().SetLastStimName(hitAIEvent.name);
    target.QueueEvent(hitDataEvent);
    target.QueueEvent(hitAIEvent);
  }
}

public abstract class AISubActionActivateStrongArmsFX_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionActivateStrongArmsFX_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionActivateStrongArmsFX_Record_Implementation.SpawnStrongArmsFX(context);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionActivateStrongArmsFX_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionActivateStrongArmsFX_Record_Implementation.SpawnStrongArmsFX(context);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionActivateStrongArmsFX_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionActivateStrongArmsFX_Record_Implementation.SpawnStrongArmsFX(context);
    };
  }

  public final static func SpawnStrongArmsFX(context: ScriptExecutionContext) -> Void {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(ScriptedPuppet.GetWeaponRight(ScriptExecutionContext.GetOwner(context)).GetGame());
    let weaponID: StatsObjectID = Cast(ScriptedPuppet.GetWeaponRight(ScriptExecutionContext.GetOwner(context)).GetEntityID());
    let cachedThreshold: Float = statSystem.GetStatValue(weaponID, gamedataStatType.PhysicalDamage);
    let damageType: gamedataDamageType = gamedataDamageType.Physical;
    if statSystem.GetStatValue(weaponID, gamedataStatType.ThermalDamage) > cachedThreshold {
      cachedThreshold = statSystem.GetStatValue(weaponID, gamedataStatType.ThermalDamage);
      damageType = gamedataDamageType.Thermal;
    };
    if statSystem.GetStatValue(weaponID, gamedataStatType.ElectricDamage) > cachedThreshold {
      cachedThreshold = statSystem.GetStatValue(weaponID, gamedataStatType.ElectricDamage);
      damageType = gamedataDamageType.Electric;
    };
    if statSystem.GetStatValue(weaponID, gamedataStatType.ChemicalDamage) > cachedThreshold {
      cachedThreshold = statSystem.GetStatValue(weaponID, gamedataStatType.ChemicalDamage);
      damageType = gamedataDamageType.Chemical;
    };
    if Equals(damageType, gamedataDamageType.Physical) {
      StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.StrongArmsPhysicalActive", ScriptExecutionContext.GetOwner(context).GetEntityID());
    } else {
      if Equals(damageType, gamedataDamageType.Thermal) {
        StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.StrongArmsThermalActive", ScriptExecutionContext.GetOwner(context).GetEntityID());
      } else {
        if Equals(damageType, gamedataDamageType.Chemical) {
          StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.StrongArmsChemicalActive", ScriptExecutionContext.GetOwner(context).GetEntityID());
        } else {
          if Equals(damageType, gamedataDamageType.Electric) {
            StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.StrongArmsElecricActive", ScriptExecutionContext.GetOwner(context).GetEntityID());
          };
        };
      };
    };
  }
}

public abstract class AISubActionMountVehicle_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionMountVehicle_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionMountVehicle_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if AISubActionMountVehicle_Record_Implementation.MountVehicle(context, record) {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.FAILURE;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionMountVehicle_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func MountVehicle(context: ScriptExecutionContext, record: wref<AISubActionMountVehicle_Record>) -> Bool {
    let evt: ref<MountAIEvent>;
    let mountData: ref<MountEventData>;
    let slotName: CName;
    let vehicle: wref<VehicleObject>;
    if !AIActionTarget.GetVehicleObject(context, record.Vehicle(), vehicle) {
      return false;
    };
    slotName = record.Slot().SeatName();
    if IsNameValid(slotName) {
      if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName) {
        return false;
      };
    } else {
      if !AIHumanComponent.GetLastUsedVehicleSlot(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, slotName) {
        slotName = n"";
      };
      if !IsNameValid(slotName) || !VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName) {
        if !VehicleComponent.GetFirstAvailableSlot(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName) {
          return false;
        };
      };
    };
    if vehicle.IsDestroyed() {
      return false;
    };
    mountData = new MountEventData();
    mountData.slotName = slotName;
    mountData.mountParentEntityId = vehicle.GetEntityID();
    mountData.isInstant = record.MountInstantly();
    mountData.ignoreHLS = true;
    evt = new MountAIEvent();
    evt.name = n"Mount";
    evt.data = mountData;
    ScriptExecutionContext.GetOwner(context).QueueEvent(evt);
    return true;
  }
}

public abstract class AISubActionUseSensePreset_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionUseSensePreset_Record>) -> Void {
    if record.Delay() == 0.00 {
      SenseComponent.RequestSecondaryPresetChange(ScriptExecutionContext.GetOwner(context), record.SensePreset().GetID());
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionUseSensePreset_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      SenseComponent.RequestSecondaryPresetChange(ScriptExecutionContext.GetOwner(context), record.SensePreset().GetID());
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionUseSensePreset_Record>, const duration: Float, interrupted: Bool) -> Void {
    SenseComponent.ResetPreset(ScriptExecutionContext.GetOwner(context));
  }
}

public abstract class AISubActionConditionalFailure_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionConditionalFailure_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionConditionalFailure_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let count: Int32;
    let i: Int32;
    if record.Delay() > 0.00 && duration < record.Delay() {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    count = record.GetConditionCount();
    i = 0;
    while i < count {
      if AICondition.CheckActionCondition(context, record.GetConditionItem(i)) {
      } else {
        i += 1;
      };
    };
    if count == 0 || i < count {
      AISubActionConditionalFailure_Record_Implementation.StartCooldowns(context, record);
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionConditionalFailure_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func StartCooldowns(context: ScriptExecutionContext, record: wref<AISubActionConditionalFailure_Record>) -> Void {
    let i: Int32;
    let puppet: ref<gamePuppet>;
    let count: Int32 = record.GetCooldownsCount();
    if count > 0 {
      puppet = ScriptExecutionContext.GetOwner(context);
      i = 0;
      while i < count {
        AIActionHelper.StartCooldown(puppet, record.GetCooldownsItem(i));
        i += 1;
      };
    };
  }
}

public abstract class AISubActionCompleteCommand_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionCompleteCommand_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionCompleteCommand_Record_Implementation.CompleteCommand(context);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCompleteCommand_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionCompleteCommand_Record_Implementation.CompleteCommand(context);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionCompleteCommand_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionCompleteCommand_Record_Implementation.CompleteCommand(context);
    };
  }

  public final static func CompleteCommand(context: ScriptExecutionContext) -> Void;
}

public abstract class AISubActionLeaveCover_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionLeaveCover_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionLeaveCover_Record_Implementation.LeaveCover(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionLeaveCover_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      if AISubActionLeaveCover_Record_Implementation.LeaveCover(context, record) {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionLeaveCover_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionLeaveCover_Record_Implementation.LeaveCover(context, record);
    };
  }

  public final static func LeaveCover(context: ScriptExecutionContext, record: wref<AISubActionLeaveCover_Record>) -> Bool {
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return false;
    };
    if record.CheckExposure() != -1 {
      if record.CheckExposure() == 0 {
        if AICoverHelper.GetCoverNPCCurrentlyExposed(puppet) {
          return false;
        };
      } else {
        if record.CheckExposure() == 1 {
          if !AICoverHelper.GetCoverNPCCurrentlyExposed(puppet) {
            return false;
          };
        } else {
          if !AIActionHelper.IsCurrentlyCrouching(puppet) {
            return false;
          };
        };
      };
    };
    return AICoverHelper.LeaveCoverImmediately(puppet);
  }
}

public abstract class AISubActionCustomEffectors_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionCustomEffectors_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionCustomEffectors_Record_Implementation.ApplyRemoveEffectors(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCustomEffectors_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionCustomEffectors_Record_Implementation.ApplyRemoveEffectors(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionCustomEffectors_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionCustomEffectors_Record_Implementation.ApplyRemoveEffectors(context, record);
    } else {
      if record.Remove() {
        AISubActionCustomEffectors_Record_Implementation.RemoveEffectors(context, record);
      };
    };
  }

  public final static func ApplyRemoveEffectors(context: ScriptExecutionContext, record: wref<AISubActionCustomEffectors_Record>) -> Void {
    if record.Apply() {
      AISubActionCustomEffectors_Record_Implementation.ApplyEffectors(context, record);
    } else {
      if record.Remove() {
        AISubActionCustomEffectors_Record_Implementation.RemoveEffectors(context, record);
      };
    };
  }

  public final static func ApplyEffectors(const context: ScriptExecutionContext, record: wref<AISubActionCustomEffectors_Record>) -> Void {
    let count: Int32;
    let effector: wref<Effector_Record>;
    let es: ref<EffectorSystem>;
    let i: Int32;
    let obj: wref<GameObject>;
    if !IsDefined(record.Target()) || !AIActionTarget.GetObject(context, record.Target(), obj) {
      return;
    };
    es = GameInstance.GetEffectorSystem(obj.GetGame());
    if !IsDefined(es) {
      return;
    };
    count = record.GetEffectorsCount();
    i = 0;
    while i < count {
      effector = record.GetEffectorsItem(i);
      es.ApplyEffector(obj.GetEntityID(), ScriptExecutionContext.GetOwner(context), effector.GetID());
      i += 1;
    };
  }

  public final static func RemoveEffectors(const context: ScriptExecutionContext, record: wref<AISubActionCustomEffectors_Record>) -> Void {
    let count: Int32;
    let effector: wref<Effector_Record>;
    let es: ref<EffectorSystem>;
    let i: Int32;
    let obj: wref<GameObject>;
    if !IsDefined(record.Target()) || !AIActionTarget.GetObject(context, record.Target(), obj) {
      return;
    };
    es = GameInstance.GetEffectorSystem(obj.GetGame());
    if !IsDefined(es) {
      return;
    };
    count = record.GetEffectorsCount();
    i = 0;
    while i < count {
      effector = record.GetEffectorsItem(i);
      es.RemoveEffector(obj.GetEntityID(), effector.GetID());
      i += 1;
    };
  }
}

public abstract class AISubActionActivateLightPreset_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionActivateLightPreset_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionActivateLightPreset_Record_Implementation.ActivateLightPreset(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionActivateLightPreset_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionActivateLightPreset_Record_Implementation.ActivateLightPreset(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionActivateLightPreset_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionActivateLightPreset_Record_Implementation.ActivateLightPreset(context, record);
    };
  }

  protected final static func ActivateLightPreset(context: ScriptExecutionContext, record: wref<AISubActionActivateLightPreset_Record>) -> Void {
    let preset: DiodeLightPreset;
    let recordPreset: wref<LightPreset_Record> = record.LightPreset();
    preset.state = recordPreset.On();
    preset.colorMax = recordPreset.ColorMax();
    preset.colorMin = recordPreset.ColorMin();
    preset.overrideColorMin = recordPreset.OverrideColorMin();
    preset.strength = recordPreset.Strength();
    preset.curve = recordPreset.Curve();
    preset.time = recordPreset.Time();
    preset.loop = recordPreset.Loop();
    preset.duration = recordPreset.Duration();
    preset.force = recordPreset.Force();
    let applyPresetEvent: ref<ApplyDiodeLightPresetEvent> = new ApplyDiodeLightPresetEvent();
    applyPresetEvent.preset = preset;
    ScriptExecutionContext.GetOwner(context).QueueEvent(applyPresetEvent);
  }
}

public abstract class AISubActionFailIfFriendlyFire_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionFailIfFriendlyFire_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionFailIfFriendlyFire_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if record.CheckOnlyFirstFrame() && !BBoard.GetBool(GetAllBlackboardDefs().AIAction.operationHasBeenProcessed) {
      BBoard.SetBool(GetAllBlackboardDefs().AIAction.operationHasBeenProcessed, true);
      if (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().IsFriendlyFiring() {
        return AIbehaviorUpdateOutcome.FAILURE;
      };
    } else {
      if !record.CheckOnlyFirstFrame() && (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().IsFriendlyFiring() {
        return AIbehaviorUpdateOutcome.FAILURE;
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionFailIfFriendlyFire_Record>, const duration: Float, interrupted: Bool) -> Void {
    let BBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    BBoard.SetBool(GetAllBlackboardDefs().AIAction.operationHasBeenProcessed, false);
  }
}

public abstract class AISubActionUpdateFriendlyFireParams_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionUpdateFriendlyFireParams_Record>) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    let equippedItemType: gamedataItemType;
    let weaponItem: ref<ItemObject>;
    if !record.UpdateOnDeactivate() && AIHumanComponent.Get(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, aiComponent) {
      if !GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).IsSlotEmpty(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponRight") {
        weaponItem = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponRight");
        equippedItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponItem.GetItemID())).ItemType().Type();
        AISubActionUpdateFriendlyFireParams_Record_Implementation.SetFriendlyFireGeometry(equippedItemType, aiComponent.GetFriendlyFireSystem());
      };
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionUpdateFriendlyFireParams_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.UpdateOnDeactivate() {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionUpdateFriendlyFireParams_Record>, const duration: Float, interrupted: Bool) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    let equippedItemType: gamedataItemType;
    let weaponItem: ref<ItemObject>;
    if record.UpdateOnDeactivate() && AIHumanComponent.Get(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, aiComponent) {
      if !GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).IsSlotEmpty(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponRight") {
        weaponItem = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponRight");
        equippedItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponItem.GetItemID())).ItemType().Type();
        AISubActionUpdateFriendlyFireParams_Record_Implementation.SetFriendlyFireGeometry(equippedItemType, aiComponent.GetFriendlyFireSystem());
      };
    };
  }

  protected final static func SetFriendlyFireGeometry(equippedItemType: gamedataItemType, ffs: ref<IFriendlyFireSystem>) -> Void {
    let ffp: ref<FriendlyFireParams> = new FriendlyFireParams();
    switch equippedItemType {
      case gamedataItemType.Wea_Melee:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_Fists:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_Katana:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_Knife:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_LongBlade:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_OneHandedClub:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_TwoHandedClub:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_ShortBlade:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_Hammer:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Cyb_MantisBlades:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Cyb_NanoWires:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Cyb_StrongArms:
        ffp.SetGeometry(180.00, 2.00);
        break;
      case gamedataItemType.Wea_Rifle:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_AssaultRifle:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_Handgun:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_HeavyMachineGun:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_LightMachineGun:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_PrecisionRifle:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_Revolver:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_Shotgun:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_ShotgunDual:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_SniperRifle:
        ffp.SetGeometry(0.20, 50.00);
        break;
      case gamedataItemType.Wea_SubmachineGun:
        ffp.SetGeometry(0.20, 50.00);
        break;
      default:
    };
    ffs.StartChecking(ffp);
  }
}

public abstract class AISubActionSendSignal_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSendSignal_Record>) -> Void {
    if record.Delay() == 0.00 {
      ScriptedPuppet.SendActionSignal(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, record.Name(), record.Duration());
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionSendSignal_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      ScriptedPuppet.SendActionSignal(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, record.Name(), record.Duration());
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionSendSignal_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      ScriptedPuppet.SendActionSignal(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, record.Name(), record.Duration());
    } else {
      if record.Duration() < 0.00 {
        ScriptedPuppet.ResetActionSignal(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, record.Name());
      };
    };
  }
}

public abstract class AISubActionFastExitWorkspot_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionFastExitWorkspot_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionFastExitWorkspot_Record_Implementation.ExitWorkspot(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionFastExitWorkspot_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionFastExitWorkspot_Record_Implementation.ExitWorkspot(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionFastExitWorkspot_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionFastExitWorkspot_Record_Implementation.ExitWorkspot(context, record);
    };
  }

  protected final static func ExitWorkspot(context: ScriptExecutionContext, record: wref<AISubActionFastExitWorkspot_Record>) -> Void {
    let destinationObj: wref<GameObject>;
    let destinationPosition: Vector4;
    let source: wref<GameObject>;
    let sourcePosition: Vector4;
    let vecToTarget: Vector4;
    let workspotSystem: ref<WorkspotGameSystem>;
    if !AIActionTarget.Get(context, record.Target(), false, source, sourcePosition) {
      return;
    };
    if !AIActionTarget.Get(context, record.DestinationObj(), false, destinationObj, destinationPosition) {
      return;
    };
    workspotSystem = GameInstance.GetWorkspotSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if !IsDefined(workspotSystem) {
      return;
    };
    vecToTarget = destinationPosition - sourcePosition;
    workspotSystem.SendFastExitSignal(source, Vector4.Vector4To3(vecToTarget), record.StayInWorkspotIfFailed(), record.PlaySlowExitIfFailed());
  }
}

public abstract class AISubActionMeleeAttackAttemptEvent_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionMeleeAttackAttemptEvent_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionMeleeAttackAttemptEvent_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let attackAttemptEvent: ref<AIAttackAttemptEvent>;
    let target: wref<GameObject>;
    if AIActionTarget.GetObject(context, record.Target(), target) {
      attackAttemptEvent = new AIAttackAttemptEvent();
      attackAttemptEvent.instigator = ScriptExecutionContext.GetOwner(context);
      attackAttemptEvent.target = target;
      attackAttemptEvent.isWindUp = record.IsWindUp();
      target.QueueEvent(attackAttemptEvent);
      ScriptExecutionContext.GetOwner(context).QueueEvent(attackAttemptEvent);
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionMeleeAttackAttemptEvent_Record>, const duration: Float, interrupted: Bool) -> Void;
}

public abstract class AISubActionSetWorldPosition_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionSetWorldPosition_Record>) -> Void {
    let finalWorldPosition: Vector4;
    if !IsDefined(record.CustomPositionTarget()) || !record.CustomPositionTarget().IsPosition() {
      return;
    };
    finalWorldPosition = AISubActionSetWorldPosition_Record_Implementation.CalculateWorldPosition(context, record);
    AIActionTarget.Set(context, record.CustomPositionTarget(), null, finalWorldPosition);
  }

  protected final static func CalculateWorldPosition(context: ScriptExecutionContext, record: wref<AISubActionSetWorldPosition_Record>) -> Vector4 {
    let calculatedPosition: Vector4;
    let i: Int32;
    let navmeshPositionValid: Bool;
    if record.ReferenceTarget() == null {
      calculatedPosition = Vector4.Vector3To4(record.MinOffsetFromTarget());
      return calculatedPosition;
    };
    if !record.RandomizePoint() {
      calculatedPosition = AISubActionSetWorldPosition_Record_Implementation.GetWorldPositionWithOffset(context, record.ReferenceTarget(), record.MinOffsetFromTarget(), record.UseLocalSpace());
      if record.CheckForNavmesh() && !AISubActionSetWorldPosition_Record_Implementation.GetNavmeshPosition(context, calculatedPosition) {
        Vector4.Zero(calculatedPosition);
      };
    } else {
      i = 0;
      while i < 10 {
        calculatedPosition = AISubActionSetWorldPosition_Record_Implementation.GetWorldPositionWithOffset(context, record.ReferenceTarget(), AISubActionSetWorldPosition_Record_Implementation.GetRandomOffset(record.MinOffsetFromTarget(), record.MaxOffsetFromTarget()), record.UseLocalSpace());
        if !record.CheckForNavmesh() {
        } else {
          navmeshPositionValid = AISubActionSetWorldPosition_Record_Implementation.GetNavmeshPosition(context, calculatedPosition);
          if navmeshPositionValid {
          } else {
            if i == 9 && !navmeshPositionValid {
              Vector4.Zero(calculatedPosition);
            };
            i += 1;
          };
        };
      };
    };
    return calculatedPosition;
  }

  protected final static func GetNavmeshPosition(context: ScriptExecutionContext, out checkPosition: Vector4) -> Bool {
    let closestNavmeshPoint: Vector4;
    if GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame()).IsPointOnNavmesh(ScriptExecutionContext.GetOwner(context), checkPosition, new Vector4(0.20, 0.20, 1.20, 1.00), closestNavmeshPoint) {
      checkPosition = closestNavmeshPoint;
      return true;
    };
    return false;
  }

  protected final static func GetWorldPositionWithOffset(context: ScriptExecutionContext, referenceTarget: ref<AIActionTarget_Record>, offset: Vector3, useLocalSpace: Bool) -> Vector4 {
    let positionWithOffset: Vector4;
    let referenceTargetObject: wref<GameObject>;
    let referenceTargetPosition: Vector4;
    AIActionTarget.Get(context, referenceTarget, false, referenceTargetObject, referenceTargetPosition);
    if referenceTarget.IsPosition() {
      positionWithOffset = referenceTargetPosition + Vector4.Vector3To4(offset);
    } else {
      if useLocalSpace {
        positionWithOffset = referenceTargetObject.GetWorldPosition() + Vector4.RotByAngleXY(Vector4.Vector3To4(offset), -1.00 * Vector4.Heading(referenceTargetObject.GetWorldForward()));
      } else {
        positionWithOffset = referenceTargetObject.GetWorldPosition() + Vector4.Vector3To4(offset);
      };
    };
    return positionWithOffset;
  }

  protected final static func GetRandomOffset(minOffset: Vector3, maxOffset: Vector3) -> Vector3 {
    let randomOffset: Vector3;
    randomOffset.X = RandRangeF(minOffset.X, maxOffset.X);
    randomOffset.Y = RandRangeF(minOffset.Y, maxOffset.Y);
    randomOffset.Z = RandRangeF(minOffset.Z, maxOffset.Z);
    return randomOffset;
  }
}

public abstract class AISubActionCover_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionCover_Record>) -> Void {
    if record.SetDesiredCover() != -1 {
      AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetFloat(GetAllBlackboardDefs().AICover.startCoverEvaluationTimeStamp, EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context)));
    };
    if record.SetCurrentCover() {
      AISubActionCover_Record_Implementation.SetCurrentCover(context);
    };
    if record.ExposedInCover() == 0 {
      AICoverHelper.SetCoverNPCCurrentlyExposed(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, false);
    } else {
      if record.ExposedInCover() == 1 {
        AICoverHelper.SetCoverNPCCurrentlyExposed(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, true);
      };
    };
    AISubActionCover_Record_Implementation.SetCoverData(context, record);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCover_Record>, duration: Float) -> AIbehaviorUpdateOutcome {
    if record.SetDesiredCover() != -1 {
      AISubActionCover_Record_Implementation.SetDesiredCover(context, record);
    };
    if record.SetCurrentCover() {
      AISubActionCover_Record_Implementation.SetCurrentCover(context);
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionCover_Record>, const duration: Float, interrupted: Bool) -> Void {
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    if record.ExposedInCover() != -1 && AICoverHelper.GetCoverNPCCurrentlyExposed(puppet) {
      AICoverHelper.SetCoverNPCCurrentlyExposed(puppet, false);
    };
  }

  public final static func GetAnimVariation(context: ScriptExecutionContext, record: wref<AISubActionCover_Record>) -> Int32 {
    let coverExposureMethod: AICoverExposureMethod;
    let animVariation: Int32 = -1;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return -1;
    };
    AICoverHelper.GetCoverExposureMethod(puppet, coverExposureMethod);
    if Equals(coverExposureMethod, AICoverExposureMethod.Count) {
      if record.UseLastAvailableExposureMethodsIfNoneAvailable() {
        AICoverHelper.GetFallbackCoverExposureMethod(puppet, coverExposureMethod);
        if NotEquals(coverExposureMethod, AICoverExposureMethod.Count) {
          return EnumInt(coverExposureMethod);
        };
      };
      return -1;
    };
    animVariation = EnumInt(coverExposureMethod);
    return animVariation;
  }

  public final static func GetInvalidCoverID() -> Uint64 {
    return 999999999u;
  }

  public final static func SetDesiredCover(context: ScriptExecutionContext, record: wref<AISubActionCover_Record>) -> Void {
    let checkedCoverID: Uint64;
    let cm: ref<CoverManager>;
    let conditionCount: Int32;
    let currentCoverValid: Bool;
    let currentRing: gamedataAIRingType;
    let exposureMethods: array<AICoverExposureMethod>;
    let i: Int32;
    let msc: wref<MultiSelectCovers>;
    let objectSelectionComponent: ref<ObjectSelectionComponent>;
    let ringName: CName;
    let selectedCoversSize: Int32;
    let setCoverID: Uint64;
    let squadInterface: ref<PuppetSquadInterface>;
    let target: wref<GameObject>;
    let targetVisible: Bool;
    let tmpID: Uint64;
    let trackedLocation: TrackedLocation;
    let debugCoverPresetNum: Int32 = -1;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    objectSelectionComponent = puppet.GetObjectSelectionComponent();
    if IsDefined(objectSelectionComponent) && objectSelectionComponent.IsCoversProcessingPaused() {
      return;
    };
    cm = GameInstance.GetCoverManager(puppet.GetGame());
    setCoverID = AISubActionCover_Record_Implementation.GetInvalidCoverID();
    checkedCoverID = ScriptExecutionContext.GetArgumentUint64(context, n"CommandCoverID");
    if checkedCoverID > 0u {
      conditionCount = record.GetCommandCoverConditionsCount();
      if conditionCount > 0 {
        i = 0;
        while i < conditionCount {
          if AICondition.CheckActionCondition(context, record.GetCommandCoverConditionsItem(i)) {
            AIActionHelper.StartCooldown(puppet, record.InsideCoverReselectionCooldown());
            tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"DesiredCoverID");
            if tmpID != checkedCoverID {
              ScriptExecutionContext.SetArgumentUint64(context, n"DesiredCoverID", checkedCoverID);
              cm.NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"DesiredCoverID", tmpID, checkedCoverID);
            };
            if !IsFinal() && IsDefined(objectSelectionComponent) {
              objectSelectionComponent.SetCurrentCoverDebugPresetNumber(-1);
              AICoverHelper.GetCoverBlackboard(puppet).SetInt(GetAllBlackboardDefs().AICover.lastDebugCoverPreset, -1);
            };
            AICoverHelper.GetCoverBlackboard(puppet).SetBool(GetAllBlackboardDefs().AICover.firstCoverEvaluationDone, true);
            return;
          };
          i += 1;
        };
      } else {
        AIActionHelper.StartCooldown(puppet, record.InsideCoverReselectionCooldown());
        tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"DesiredCoverID");
        if tmpID != checkedCoverID {
          ScriptExecutionContext.SetArgumentUint64(context, n"DesiredCoverID", checkedCoverID);
          cm.NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"DesiredCoverID", tmpID, checkedCoverID);
        };
        if !IsFinal() && IsDefined(objectSelectionComponent) {
          objectSelectionComponent.SetCurrentCoverDebugPresetNumber(-1);
          AICoverHelper.GetCoverBlackboard(puppet).SetInt(GetAllBlackboardDefs().AICover.lastDebugCoverPreset, -1);
        };
        AICoverHelper.GetCoverBlackboard(puppet).SetBool(GetAllBlackboardDefs().AICover.firstCoverEvaluationDone, true);
        return;
      };
    };
    if IsDefined(cm) {
      checkedCoverID = cm.GetCurrentCover(puppet);
    };
    currentRing = AISquadHelper.GetCurrentSquadRing(puppet);
    currentCoverValid = objectSelectionComponent.IsCoverPositiveScored(checkedCoverID, currentRing);
    if checkedCoverID > 0u && currentCoverValid && GameObject.IsCooldownActive(puppet, record.InsideCoverReselectionCooldown().Name()) {
      return;
    };
    msc = ScriptExecutionContext.GetArgumentScriptable(context, n"MultiCoverID") as MultiSelectCovers;
    if !IsDefined(msc) {
      return;
    };
    AIActionTarget.GetObject(context, record.Target(), target);
    selectedCoversSize = ArraySize(msc.selectedCovers);
    if checkedCoverID > 0u && IsDefined(target) && AISquadHelper.GetSquadBaseInterface(puppet, squadInterface) {
      exposureMethods = AICoverHelper.GetAvailableExposureSpots(puppet, checkedCoverID, target, exposureMethods, record.ClearLOSDistanceTolerance());
      if record.SetDesiredCover() == 1 || record.SetDesiredCover() == 3 || record.SetDesiredCover() == 5 {
        if ArraySize(exposureMethods) == 0 {
          i = 0;
          while i < selectedCoversSize {
            if !msc.coversUseLOS[i] {
            } else {
              if !squadInterface.CheckTicketConditions(AISquadHelper.SquadRingTypeToTicketName(msc.coverRingTypes[i]), puppet) {
              } else {
                ringName = StringToName(AISquadHelper.SquadRingTypeToTicketString(msc.coverRingTypes[i]) + Equals(msc.coverRingTypes[i], gamedataAIRingType.Default) ? "" : "2ndFilter");
                if !squadInterface.CheckTicketConditions(ringName, puppet) {
                } else {
                  if AISubActionCover_Record_Implementation.SelectCover(context, record.InsideCoverReselectionCooldown(), msc.selectedCovers[i], msc.coverRingTypes[i], currentRing, false) {
                    setCoverID = msc.selectedCovers[i];
                    debugCoverPresetNum = i;
                  } else {
                    i += 1;
                  };
                };
              };
            };
          };
        };
      };
    } else {
      if checkedCoverID == 0u {
        if IsDefined(target) {
          if TargetTrackingExtension.GetTrackedLocation(context, target, trackedLocation) {
            targetVisible = trackedLocation.accuracy > 0.90;
            if !targetVisible && ScriptedPuppet.IsPlayerCompanion(puppet) {
              targetVisible = trackedLocation.sharedAccuracy > 0.90;
            };
          };
        };
        if record.SetDesiredCover() == 1 || record.SetDesiredCover() == 3 || record.SetDesiredCover() == 5 {
          i = 0;
          while i < selectedCoversSize {
            if record.SetDesiredCover() == 5 {
              if !msc.coversUseLOS[i] {
              } else {
              };
            } else {
              if record.SetDesiredCover() == 3 && selectedCoversSize > 1 && IsDefined(target) && targetVisible && !msc.coversUseLOS[i] {
              } else {
                if AISubActionCover_Record_Implementation.SelectCover(context, record.InsideCoverReselectionCooldown(), msc.selectedCovers[i], msc.coverRingTypes[i], currentRing, selectedCoversSize > 1) {
                  setCoverID = msc.selectedCovers[i];
                  debugCoverPresetNum = i;
                } else {
                  i += 1;
                };
              };
            };
          };
        } else {
          i = selectedCoversSize - 1;
          while i >= 0 {
            if record.SetDesiredCover() == 4 {
              if msc.coversUseLOS[i] {
              } else {
                if record.SetDesiredCover() == 2 && selectedCoversSize > 1 && IsDefined(target) && !targetVisible && msc.coversUseLOS[i] {
                } else {
                  if AISubActionCover_Record_Implementation.SelectCover(context, record.InsideCoverReselectionCooldown(), msc.selectedCovers[i], msc.coverRingTypes[i], currentRing, selectedCoversSize > 1) {
                    setCoverID = msc.selectedCovers[i];
                    debugCoverPresetNum = i;
                  } else {
                    i -= 1;
                  };
                };
              };
            } else {
            };
            if record.SetDesiredCover() == 2 && selectedCoversSize > 1 && IsDefined(target) && !targetVisible && msc.coversUseLOS[i] {
            } else {
              if AISubActionCover_Record_Implementation.SelectCover(context, record.InsideCoverReselectionCooldown(), msc.selectedCovers[i], msc.coverRingTypes[i], currentRing, selectedCoversSize > 1) {
                setCoverID = msc.selectedCovers[i];
                debugCoverPresetNum = i;
              } else {
                i -= 1;
              };
            };
          };
        };
      };
    };
    if setCoverID == AISubActionCover_Record_Implementation.GetInvalidCoverID() {
      if !AICoverHelper.GetCoverBlackboard(puppet).GetBool(GetAllBlackboardDefs().AICover.firstCoverEvaluationDone) {
        if EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context)) > AICoverHelper.GetCoverBlackboard(puppet).GetFloat(GetAllBlackboardDefs().AICover.startCoverEvaluationTimeStamp) + 1.00 {
          AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetBool(GetAllBlackboardDefs().AICover.firstCoverEvaluationDone, true);
        };
      };
      if currentCoverValid {
        tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"DesiredCoverID");
        if tmpID != checkedCoverID {
          ScriptExecutionContext.SetArgumentUint64(context, n"DesiredCoverID", checkedCoverID);
          cm.NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"DesiredCoverID", tmpID, checkedCoverID);
        };
        AIActionHelper.StartCooldown(ScriptExecutionContext.GetOwner(context), record.InsideCoverReselectionCooldown());
        if !IsFinal() && objectSelectionComponent.GetCurrentCoverDebugPresetNumber() < 0 {
          debugCoverPresetNum = AICoverHelper.GetCoverBlackboard(puppet).GetInt(GetAllBlackboardDefs().AICover.lastDebugCoverPreset);
          objectSelectionComponent.SetCurrentCoverDebugPresetNumber(debugCoverPresetNum);
        };
      } else {
        tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"DesiredCoverID");
        if tmpID != 0u {
          ScriptExecutionContext.SetArgumentUint64(context, n"DesiredCoverID", 0u);
          cm.NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"DesiredCoverID", tmpID, 0u);
        };
        if !IsFinal() && IsDefined(objectSelectionComponent) {
          objectSelectionComponent.SetCurrentCoverDebugPresetNumber(debugCoverPresetNum);
          AICoverHelper.GetCoverBlackboard(puppet).SetInt(GetAllBlackboardDefs().AICover.lastDebugCoverPreset, debugCoverPresetNum);
        };
      };
    } else {
      if !IsFinal() && IsDefined(objectSelectionComponent) {
        objectSelectionComponent.SetCurrentCoverDebugPresetNumber(debugCoverPresetNum);
        AICoverHelper.GetCoverBlackboard(puppet).SetInt(GetAllBlackboardDefs().AICover.lastDebugCoverPreset, debugCoverPresetNum);
      };
    };
  }

  public final static func SelectCover(context: ScriptExecutionContext, cooldown: ref<AIActionCooldown_Record>, consideredCoverID: Uint64, consideredRing: gamedataAIRingType, currentRing: gamedataAIRingType, compareRings: Bool) -> Bool {
    let tmpID: Uint64;
    if compareRings {
      if Equals(currentRing, gamedataAIRingType.Invalid) {
        if NotEquals(consideredRing, gamedataAIRingType.Undefined) && NotEquals(consideredRing, gamedataAIRingType.Default) {
          return false;
        };
      } else {
        if NotEquals(currentRing, consideredRing) {
          return false;
        };
      };
    };
    AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetBool(GetAllBlackboardDefs().AICover.firstCoverEvaluationDone, true);
    if consideredCoverID > 0u {
      tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"DesiredCoverID");
      if tmpID != consideredCoverID {
        ScriptExecutionContext.SetArgumentUint64(context, n"DesiredCoverID", consideredCoverID);
        GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame()).NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"DesiredCoverID", tmpID, consideredCoverID);
      };
      AIActionHelper.StartCooldown(ScriptExecutionContext.GetOwner(context), cooldown);
      AICoverHelper.GetCoverBlackboard(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).SetVariant(GetAllBlackboardDefs().AICover.lastCoverRing, ToVariant(consideredRing));
      return true;
    };
    return false;
  }

  public final static func SetCurrentCover(context: ScriptExecutionContext) -> Void {
    let coverID: Uint64 = ScriptExecutionContext.GetArgumentUint64(context, n"DesiredCoverID");
    let tmpID: Uint64 = ScriptExecutionContext.GetArgumentUint64(context, n"CoverID");
    if tmpID != coverID {
      ScriptExecutionContext.SetArgumentUint64(context, n"CoverID", coverID);
      GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame()).NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"CoverID", tmpID, coverID);
      AICoverHelper.SetCoverLastAvailableExposureMethod(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet);
    };
  }

  public final static func SetCoverData(context: ScriptExecutionContext, record: wref<AISubActionCover_Record>) -> Void {
    let coverID: Uint64;
    let target: wref<GameObject>;
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    if record.SetInitialCoverData() {
      coverID = GameInstance.GetCoverManager(puppet.GetGame()).GetCurrentCover(puppet);
      if coverID == 0u {
        coverID = ScriptExecutionContext.GetArgumentUint64(context, n"CoverID");
        if coverID == 0u {
          return;
        };
      };
      AISubActionCover_Record_Implementation.SetInitialCoverData(puppet, coverID);
    };
    if record.SetCoverExposureAnim() {
      coverID = GameInstance.GetCoverManager(puppet.GetGame()).GetCurrentCover(puppet);
      if coverID == 0u {
        return;
      };
      AIActionTarget.GetObject(context, record.Target(), target);
      AISubActionCover_Record_Implementation.SetCoverExposureAnim(context, puppet, coverID, record, target, record.ClearLOSDistanceTolerance());
    };
  }

  public final static func SetInitialCoverData(puppet: wref<ScriptedPuppet>, const coverID: Uint64) -> Void {
    let coverFeature: ref<AnimFeature_NPCCoverStanceState>;
    let shootingSpot: Bool;
    let coverStance: gameCoverHeight = AICoverHelper.GetCoverType(puppet, coverID, shootingSpot);
    AICoverHelper.SetCurrentCoverStance(puppet, coverStance);
    coverFeature = new AnimFeature_NPCCoverStanceState();
    if shootingSpot {
      coverFeature.state = 3;
    } else {
      coverFeature.state = EnumInt(coverStance);
    };
    AnimationControllerComponent.ApplyFeatureToReplicate(puppet, n"CoverStance", coverFeature);
    AnimationControllerComponent.ApplyFeatureToReplicateOnHeldItems(puppet, n"CoverStance", coverFeature);
  }

  public final static func SetCoverExposureAnim(context: ScriptExecutionContext, puppet: wref<ScriptedPuppet>, const coverID: Uint64, record: wref<AISubActionCover_Record>, target: wref<GameObject>, lineOfSightTolerance: Float) -> Void {
    let coverExposureMethod: AICoverExposureMethod;
    let coverStance: gameCoverHeight;
    let exposureMethods: array<AICoverExposureMethod>;
    let trackedLocation: TrackedLocation;
    TargetTrackingExtension.GetTrackedLocation(context, target, trackedLocation);
    coverExposureMethod = AISubActionCover_Record_Implementation.CalculateCoverExposureMethod(puppet, coverID, record, target, lineOfSightTolerance, trackedLocation, exposureMethods);
    coverStance = AICoverHelper.GetCoverStanceFromExposureSpot(puppet, coverExposureMethod);
    AICoverHelper.SetCoverExposureMethod(puppet, coverExposureMethod);
    AICoverHelper.SetDesiredCoverStance(puppet, coverStance);
    if ArraySize(exposureMethods) > 0 {
      AICoverHelper.SetCoverLastAvailableExposureMethod(puppet, exposureMethods);
    };
    AICoverHelper.GetRandomCoverLastAvailableExposureMethod(puppet, coverExposureMethod);
    AICoverHelper.SetFallbackCoverExposureMethod(puppet, coverExposureMethod);
  }

  public final static func CalculateCoverExposureMethod(puppet: wref<ScriptedPuppet>, const coverID: Uint64, record: wref<AISubActionCover_Record>, const target: wref<GameObject>, lineOfSightTolerance: Float, trackedLocation: TrackedLocation, out exposureMethods: array<AICoverExposureMethod>) -> AICoverExposureMethod {
    let coverExposureMethod: AICoverExposureMethod = AICoverHelper.CalculateCoverExposureMethod(puppet, target, coverID, record, lineOfSightTolerance, trackedLocation, exposureMethods);
    return coverExposureMethod;
  }
}

public abstract class AISubActionHitData_Record_Implementation extends IScriptable {

  public final static func GetAnimVariation(context: ScriptExecutionContext, record: wref<AISubActionHitData_Record>) -> Int32 {
    let animVariation: Int32 = -1;
    let hitData: ref<AnimFeature_HitReactionsData> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetHitReactionComponent().GetHitReactionData();
    if !IsDefined(hitData) {
      return -1;
    };
    if hitData.stance == 0 {
      switch hitData.hitBodyPart {
        case 1:
          switch hitData.hitDirection {
            case 1:
              animVariation = 0;
              break;
            case 2:
              animVariation = 1;
              break;
            case 3:
              animVariation = 2;
              break;
            case 4:
              animVariation = 3;
              break;
            default:
              return -1;
          };
          break;
        case 2:
          switch hitData.hitDirection {
            case 1:
              animVariation = 4;
              break;
            case 2:
              animVariation = 5;
              break;
            case 3:
              animVariation = 6;
              break;
            case 4:
              animVariation = 7;
              break;
            default:
              return -1;
          };
          break;
        case 3:
          switch hitData.hitDirection {
            case 1:
              animVariation = 8;
              break;
            case 2:
              animVariation = 9;
              break;
            case 3:
              animVariation = 10;
              break;
            case 4:
              animVariation = 11;
              break;
            default:
              return -1;
          };
          break;
        case 4:
          switch hitData.hitDirection {
            case 1:
              animVariation = 12;
              break;
            case 2:
              animVariation = 13;
              break;
            case 3:
              animVariation = 14;
              break;
            case 4:
              animVariation = 15;
              break;
            default:
              return -1;
          };
          break;
        case 5:
          switch hitData.hitDirection {
            case 1:
              animVariation = 16;
              break;
            case 2:
              animVariation = 17;
              break;
            case 3:
              animVariation = 18;
              break;
            case 4:
              animVariation = 19;
              break;
            default:
              return -1;
          };
          break;
        case 6:
          switch hitData.hitDirection {
            case 1:
              animVariation = 20;
              break;
            case 2:
              animVariation = 21;
              break;
            case 3:
              animVariation = 22;
              break;
            case 4:
              animVariation = 23;
              break;
            default:
              return -1;
          };
          break;
        default:
          return -1;
      };
    } else {
      switch hitData.hitBodyPart {
        case 1:
          switch hitData.hitDirection {
            case 1:
              animVariation = 24;
              break;
            case 2:
              animVariation = 25;
              break;
            case 3:
              animVariation = 26;
              break;
            case 4:
              animVariation = 27;
              break;
            default:
              return -1;
          };
          break;
        case 2:
          switch hitData.hitDirection {
            case 1:
              animVariation = 28;
              break;
            case 2:
              animVariation = 29;
              break;
            case 3:
              animVariation = 30;
              break;
            case 4:
              animVariation = 31;
              break;
            default:
              return -1;
          };
          break;
        case 3:
          switch hitData.hitDirection {
            case 1:
              animVariation = 32;
              break;
            case 2:
              animVariation = 33;
              break;
            case 3:
              animVariation = 34;
              break;
            case 4:
              animVariation = 35;
              break;
            default:
              return -1;
          };
          break;
        case 4:
          switch hitData.hitDirection {
            case 1:
              animVariation = 36;
              break;
            case 2:
              animVariation = 37;
              break;
            case 3:
              animVariation = 38;
              break;
            case 4:
              animVariation = 39;
              break;
            default:
              return -1;
          };
          break;
        case 5:
          switch hitData.hitDirection {
            case 1:
              animVariation = 40;
              break;
            case 2:
              animVariation = 41;
              break;
            case 3:
              animVariation = 42;
              break;
            case 4:
              animVariation = 43;
              break;
            default:
              return -1;
          };
          break;
        case 6:
          switch hitData.hitDirection {
            case 1:
              animVariation = 44;
              break;
            case 2:
              animVariation = 45;
              break;
            case 3:
              animVariation = 46;
              break;
            case 4:
              animVariation = 47;
              break;
            default:
              return -1;
          };
          break;
        default:
          return -1;
      };
    };
    return animVariation;
  }
}

public abstract class AISubActionFail_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionFail_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionFail_Record>, duration: Float) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.FAILURE;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionFail_Record>, const duration: Float, interrupted: Bool) -> Void;
}

public abstract class AISubActionInitialReactionParams_Record_Implementation extends IScriptable {

  public final static func GetAnimVariation(context: ScriptExecutionContext, record: wref<AISubActionInitialReaction_Record>) -> Int32 {
    let direction: Float;
    if IsDefined(record.DirectionObj()) {
      direction = AISubActionInitialReactionParams_Record_Implementation.GetAnimDirection(context, record);
    };
    if MathHelper.IsFloatInRange(direction, -45.00, 45.00, true, true) {
      return 0;
    };
    if MathHelper.IsFloatInRange(direction, 45.00, 135.00, true, true) {
      return 1;
    };
    if MathHelper.IsFloatInRange(direction, 135.00, 180.00, true, true) {
      return 2;
    };
    if MathHelper.IsFloatInRange(direction, -180.00, -135.00, true, true) {
      return 3;
    };
    if MathHelper.IsFloatInRange(direction, -135.00, -45.00, true, true) {
      return 4;
    };
    return -1;
  }

  public final static func GetAnimDirection(const context: ScriptExecutionContext, record: wref<AISubActionInitialReaction_Record>) -> Float {
    let targetPos: Vector4;
    let vecToTarget: Vector4;
    if AIActionTarget.GetPosition(context, record.DirectionObj(), targetPos, false) {
      vecToTarget = targetPos - ScriptExecutionContext.GetOwner(context).GetWorldPosition();
      return AngleNormalize180(Vector4.GetAngleDegAroundAxis(ScriptExecutionContext.GetOwner(context).GetWorldForward(), vecToTarget, ScriptExecutionContext.GetOwner(context).GetWorldUp()));
    };
    return 0.00;
  }
}

public abstract class AISubActionRandomize_Record_Implementation extends IScriptable {

  public final static func GetAnimVariation(context: ScriptExecutionContext, record: wref<AISubActionRandomize_Record>) -> Int32 {
    let animVariationList: array<Int32>;
    let previousAnimVariation: Int32;
    let animVariation: Int32 = -1;
    let blackBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    if !blackBoard.GetBool(GetAllBlackboardDefs().AIAction.ownerCurrentAnimVariationSet) {
      animVariationList = record.AnimVariationRandomize();
      if ArraySize(animVariationList) > 1 {
        previousAnimVariation = AISubActionRandomize_Record_Implementation.GetAnimVariationInBlackBoard(context);
        animVariation = RandDifferent(previousAnimVariation, ArraySize(animVariationList));
      } else {
        animVariation = animVariationList[0];
      };
      AISubActionRandomize_Record_Implementation.SetAnimVariationInBlackBoard(context, animVariation);
    } else {
      return AISubActionRandomize_Record_Implementation.GetAnimVariationInBlackBoard(context);
    };
    return animVariation;
  }

  public final static func SetAnimVariationInBlackBoard(context: ScriptExecutionContext, const animVariation: Int32) -> Void {
    let blackBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    blackBoard.SetInt(GetAllBlackboardDefs().AIAction.ownerLastAnimVariation, animVariation);
    blackBoard.SetBool(GetAllBlackboardDefs().AIAction.ownerCurrentAnimVariationSet, true);
  }

  public final static func GetAnimVariationInBlackBoard(context: ScriptExecutionContext) -> Int32 {
    let blackBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    return blackBoard.GetInt(GetAllBlackboardDefs().AIAction.ownerLastAnimVariation);
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionRandomize_Record>, const duration: Float, interrupted: Bool) -> Void {
    let blackBoard: ref<IBlackboard> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetAIControllerComponent().GetActionBlackboard();
    blackBoard.SetBool(GetAllBlackboardDefs().AIAction.ownerCurrentAnimVariationSet, false);
  }
}

public abstract class AISubActionCallReinforcements_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionCallReinforcements_Record>) -> Void {
    if record.Delay() == 0.00 {
      AISubActionCallReinforcements_Record_Implementation.StartCallReinforcement(context, record);
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionCallReinforcements_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionCallReinforcements_Record_Implementation.StartCallReinforcement(context, record);
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionCallReinforcements_Record>, const duration: Float, interrupted: Bool) -> Void {
    if record.Delay() < 0.00 {
      AISubActionCallReinforcements_Record_Implementation.StartCallReinforcement(context, record);
    };
  }

  public final static func StartCallReinforcement(context: ScriptExecutionContext, record: wref<AISubActionCallReinforcements_Record>) -> Void {
    let m_pauseResumePhoneCallEvent: ref<PauseResumePhoneCallEvent>;
    let m_startPhoneCallEvent: ref<StartEndPhoneCallEvent>;
    let m_statPoolType: gamedataStatPoolType = gamedataStatPoolType.CallReinforcementProgress;
    let m_puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let m_statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame());
    if !m_statPoolsSystem.IsStatPoolAdded(Cast(m_puppet.GetEntityID()), m_statPoolType) {
      m_startPhoneCallEvent = new StartEndPhoneCallEvent();
      m_startPhoneCallEvent.callDuration = record.Duration();
      m_startPhoneCallEvent.startCall = true;
      m_startPhoneCallEvent.statType = gamedataStatType.CallReinforcement;
      m_startPhoneCallEvent.statPoolType = gamedataStatPoolType.CallReinforcementProgress;
      m_startPhoneCallEvent.statPoolName = "BaseStatPools.CallReinforcementProgress";
      m_puppet.QueueEvent(m_startPhoneCallEvent);
    } else {
      m_pauseResumePhoneCallEvent = new PauseResumePhoneCallEvent();
      m_pauseResumePhoneCallEvent.callDuration = record.Duration();
      m_pauseResumePhoneCallEvent.pauseCall = false;
      m_pauseResumePhoneCallEvent.statPoolType = m_statPoolType;
      m_puppet.QueueEvent(m_pauseResumePhoneCallEvent);
    };
  }
}

public abstract class AISubActionGeneratePointOfInterestTarget_Record_Implementation extends IScriptable {

  private final static func SetPointOfInterest(context: ScriptExecutionContext, record: wref<AISubActionGeneratePointOfInterestTarget_Record>) -> Void {
    let direction: Vector4 = ScriptExecutionContext.GetOwner(context).GetWorldForward();
    let angleRange: Vector2 = record.RandomPointZRotationAngleRange();
    angleRange.X = Deg2Rad(angleRange.X);
    angleRange.Y = Deg2Rad(angleRange.Y);
    direction = Vector4.RotateAxis(direction, new Vector4(0.00, 0.00, 1.00, 0.00), RandRangeF(angleRange.X, angleRange.Y));
    angleRange = record.RandomPointYRotationAngleRange();
    angleRange.X = Deg2Rad(angleRange.X);
    angleRange.Y = Deg2Rad(angleRange.Y);
    direction = Vector4.RotateAxis(direction, new Vector4(0.00, 1.00, 0.00, 0.00), RandRangeF(angleRange.X, angleRange.Y));
    direction = Vector4.Normalize(direction);
    direction *= 100.00;
    direction.Z += 2.00;
    ScriptExecutionContext.SetArgumentVector(context, n"PointOfInterest", ScriptExecutionContext.GetOwner(context).GetWorldPosition() + direction);
  }

  private final static func GetSquadMate(context: ScriptExecutionContext, record: wref<AISubActionGeneratePointOfInterestTarget_Record>) -> ref<GameObject> {
    let chosenObjectOfInterest: ref<GameObject>;
    let prevObjectOfInterest: ref<GameObject>;
    let squadMembers: array<wref<Entity>>;
    let tmpDot: Float;
    if AISquadHelper.GetSquadmates(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, squadMembers) {
      ArrayRemove(squadMembers, ScriptExecutionContext.GetArgumentObject(context, n"FriendlyTarget"));
      if ArraySize(squadMembers) > 0 {
        chosenObjectOfInterest = squadMembers[RandRange(0, ArraySize(squadMembers))] as GameObject;
        prevObjectOfInterest = ScriptExecutionContext.GetArgumentObject(context, n"ObjectOfInterest");
        while ArraySize(squadMembers) > 0 {
          chosenObjectOfInterest = squadMembers[RandRange(0, ArraySize(squadMembers))] as GameObject;
          if chosenObjectOfInterest != prevObjectOfInterest {
            tmpDot = Vector4.Dot(ScriptExecutionContext.GetOwner(context).GetWorldForward(), Vector4.Normalize(chosenObjectOfInterest.GetWorldPosition() - ScriptExecutionContext.GetOwner(context).GetWorldPosition()));
            if tmpDot > CosF(Deg2Rad(record.SquadMateWatchingMaxAngle())) {
              return chosenObjectOfInterest;
            };
          };
          ArrayRemove(squadMembers, chosenObjectOfInterest);
        };
      };
    };
    return null;
  }

  private final static func GetFriendlyTarget(context: ScriptExecutionContext, record: wref<AISubActionGeneratePointOfInterestTarget_Record>) -> ref<GameObject> {
    let tmpDot: Float;
    let friendlyTarget: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"FriendlyTarget");
    if IsDefined(friendlyTarget) && friendlyTarget != ScriptExecutionContext.GetArgumentObject(context, n"ObjectOfInterest") {
      tmpDot = Vector4.Dot(ScriptExecutionContext.GetOwner(context).GetWorldForward(), Vector4.Normalize(friendlyTarget.GetWorldPosition() - ScriptExecutionContext.GetOwner(context).GetWorldPosition()));
      if tmpDot > CosF(Deg2Rad(record.FriendlyTargetWatchingMaxAngle())) {
        return friendlyTarget;
      };
    };
    return null;
  }

  private final static func GetClosestThreat(context: ScriptExecutionContext, record: wref<AISubActionGeneratePointOfInterestTarget_Record>) -> ref<GameObject> {
    let i: Int32;
    let minSqrDist: Float;
    let target: ref<Entity>;
    let tmpDot: Float;
    let tmpSqrDist: Float;
    let threats: array<TrackedLocation> = (ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetTargetTrackerComponent().GetThreats(true);
    let ownerPos: Vector4 = ScriptExecutionContext.GetOwner(context).GetWorldPosition();
    if ArraySize(threats) > 0 {
      minSqrDist = Vector4.DistanceSquared(ownerPos, threats[0].entity.GetWorldPosition());
      target = threats[0].entity;
    };
    i = 1;
    while i < ArraySize(threats) {
      tmpSqrDist = Vector4.DistanceSquared(ownerPos, threats[i].entity.GetWorldPosition());
      if tmpSqrDist < minSqrDist {
        target = threats[i].entity;
        minSqrDist = tmpSqrDist;
      };
      i += 1;
    };
    if IsDefined(target) && target != ScriptExecutionContext.GetArgumentObject(context, n"ObjectOfInterest") {
      tmpDot = Vector4.Dot(ScriptExecutionContext.GetOwner(context).GetWorldForward(), Vector4.Normalize(target.GetWorldPosition() - ScriptExecutionContext.GetOwner(context).GetWorldPosition()));
      if tmpDot > CosF(Deg2Rad(record.ClosestThreatWatchingMaxAngle())) {
        return target as GameObject;
      };
    };
    return null;
  }

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionGeneratePointOfInterestTarget_Record>) -> Void {
    let chosenObjectOfInterest: ref<GameObject>;
    let randomVal: Float;
    let triedOptions: Bool[3];
    let prevObjectOfInterest: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"ObjectOfInterest");
    let weightsSum: Float = record.ChoosingRandomPointChanceWeight() + record.ChoosingSquadMateChanceWeight() + record.ChoosingFriendlyTargetChanceWeight() + record.ChoosingClosestThreatChanceWeight();
    AISubActionGeneratePointOfInterestTarget_Record_Implementation.SetPointOfInterest(context, record);
    if prevObjectOfInterest == null {
      weightsSum -= record.ChoosingRandomPointChanceWeight();
    };
    while chosenObjectOfInterest == null {
      randomVal = RandRangeF(0.00, weightsSum);
      if !triedOptions[0] {
        if randomVal < record.ChoosingSquadMateChanceWeight() {
          chosenObjectOfInterest = AISubActionGeneratePointOfInterestTarget_Record_Implementation.GetSquadMate(context, record);
          if chosenObjectOfInterest == null {
            weightsSum -= record.ChoosingSquadMateChanceWeight();
            triedOptions[0] = true;
          } else {
          };
        } else {
          randomVal -= record.ChoosingSquadMateChanceWeight();
          if !triedOptions[1] {
            if randomVal < record.ChoosingFriendlyTargetChanceWeight() {
              chosenObjectOfInterest = AISubActionGeneratePointOfInterestTarget_Record_Implementation.GetFriendlyTarget(context, record);
              if chosenObjectOfInterest == null {
                weightsSum -= record.ChoosingFriendlyTargetChanceWeight();
                triedOptions[1] = true;
              } else {
              };
            } else {
              randomVal -= record.ChoosingFriendlyTargetChanceWeight();
              if !triedOptions[2] {
                if randomVal < record.ChoosingClosestThreatChanceWeight() {
                  chosenObjectOfInterest = AISubActionGeneratePointOfInterestTarget_Record_Implementation.GetClosestThreat(context, record);
                  if chosenObjectOfInterest == null {
                    weightsSum -= record.ChoosingClosestThreatChanceWeight();
                    triedOptions[2] = true;
                  } else {
                  };
                } else {
                };
              } else {
                goto 1274;
              };
            };
          } else {
          };
          if !triedOptions[2] {
            if randomVal < record.ChoosingClosestThreatChanceWeight() {
              chosenObjectOfInterest = AISubActionGeneratePointOfInterestTarget_Record_Implementation.GetClosestThreat(context, record);
              if chosenObjectOfInterest == null {
                weightsSum -= record.ChoosingClosestThreatChanceWeight();
                triedOptions[2] = true;
              } else {
              };
            } else {
            };
          } else {
            goto 1274;
          };
        };
      } else {
      };
      if !triedOptions[1] {
        if randomVal < record.ChoosingFriendlyTargetChanceWeight() {
          chosenObjectOfInterest = AISubActionGeneratePointOfInterestTarget_Record_Implementation.GetFriendlyTarget(context, record);
          if chosenObjectOfInterest == null {
            weightsSum -= record.ChoosingFriendlyTargetChanceWeight();
            triedOptions[1] = true;
          } else {
          };
        } else {
          randomVal -= record.ChoosingFriendlyTargetChanceWeight();
          if !triedOptions[2] {
            if randomVal < record.ChoosingClosestThreatChanceWeight() {
              chosenObjectOfInterest = AISubActionGeneratePointOfInterestTarget_Record_Implementation.GetClosestThreat(context, record);
              if chosenObjectOfInterest == null {
                weightsSum -= record.ChoosingClosestThreatChanceWeight();
                triedOptions[2] = true;
              } else {
              };
            } else {
            };
          } else {
            goto 1274;
          };
        };
      } else {
      };
      if !triedOptions[2] {
        if randomVal < record.ChoosingClosestThreatChanceWeight() {
          chosenObjectOfInterest = AISubActionGeneratePointOfInterestTarget_Record_Implementation.GetClosestThreat(context, record);
          if chosenObjectOfInterest == null {
            weightsSum -= record.ChoosingClosestThreatChanceWeight();
            triedOptions[2] = true;
          } else {
          };
        } else {
        };
      } else {
        goto 1274;
      };
    };
    ScriptExecutionContext.SetArgumentObject(context, n"ObjectOfInterest", chosenObjectOfInterest);
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionGeneratePointOfInterestTarget_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    let durationRange: Vector2;
    let randomDuration: Float;
    let seed: Int32;
    let tmpDot: Float;
    let currentObjectOfInterest: ref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"ObjectOfInterest");
    let currentPointOfInterest: Vector4 = ScriptExecutionContext.GetArgumentVector(context, n"PointOfInterest");
    if currentObjectOfInterest == null {
      durationRange = record.RandomPointDurationRange();
    } else {
      tmpDot = Vector4.Dot(ScriptExecutionContext.GetOwner(context).GetWorldForward(), Vector4.Normalize(currentObjectOfInterest.GetWorldPosition() - ScriptExecutionContext.GetOwner(context).GetWorldPosition()));
      if currentObjectOfInterest == ScriptExecutionContext.GetArgumentObject(context, n"FriendlyTarget") {
        if tmpDot < CosF(Deg2Rad(record.FriendlyTargetWatchingMaxAngle())) {
          return AIbehaviorUpdateOutcome.SUCCESS;
        };
        durationRange = record.FriendlyTargetDurationRange();
      } else {
        if TargetTrackingExtension.IsThreatInThreatList(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, currentObjectOfInterest, true, true) {
          if tmpDot < CosF(Deg2Rad(record.ClosestThreatWatchingMaxAngle())) {
            return AIbehaviorUpdateOutcome.SUCCESS;
          };
          durationRange = record.SquadMateDurationRange();
        } else {
          if tmpDot < CosF(Deg2Rad(record.SquadMateWatchingMaxAngle())) {
            return AIbehaviorUpdateOutcome.SUCCESS;
          };
          durationRange = record.ClosestThreatDurationRange();
        };
      };
    };
    seed = Cast(100.00 * (currentPointOfInterest.Y + currentPointOfInterest.Z));
    randomDuration = RandNoiseF(seed, durationRange.Y, durationRange.X);
    if duration > randomDuration {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionGeneratePointOfInterestTarget_Record>, const duration: Float, interrupted: Bool) -> Void;
}

public abstract class AISubActionDroneModifyAltitude_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionDroneModifyAltitude_Record>) -> Void {
    if record.Delay() <= 0.00 {
      AISubActionDroneModifyAltitude_Record_Implementation.SetDesiredAltitudeOffset(context, record.AltitudeOffset());
    };
  }

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionDroneModifyAltitude_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    if record.Delay() > 0.00 && duration >= record.Delay() {
      AISubActionDroneModifyAltitude_Record_Implementation.SetDesiredAltitudeOffset(context, record.AltitudeOffset());
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionDroneModifyAltitude_Record>, const duration: Float, interrupted: Bool) -> Void {
    AISubActionDroneModifyAltitude_Record_Implementation.SetDesiredAltitudeOffset(context, 0.00);
  }

  public final static func SetDesiredAltitudeOffset(context: ScriptExecutionContext, desiredOffset: Float) -> Void {
    let altitudeOffsetAnimFeature: ref<AnimFeature_DroneActionAltitudeOffset> = new AnimFeature_DroneActionAltitudeOffset();
    altitudeOffsetAnimFeature.desiredOffset = desiredOffset;
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"ActionAltitudeOffset", altitudeOffsetAnimFeature);
  }
}

public abstract class AISubActionScaleDurationWithDistance_Record_Implementation extends IScriptable {

  public final static func Activate(context: ScriptExecutionContext, record: wref<AISubActionScaleDurationWithDistance_Record>) -> Void;

  public final static func Update(context: ScriptExecutionContext, record: wref<AISubActionScaleDurationWithDistance_Record>, const duration: Float) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public final static func Deactivate(context: ScriptExecutionContext, record: wref<AISubActionScaleDurationWithDistance_Record>, const duration: Float, interrupted: Bool) -> Void;

  public final static func GetPhaseDuration(context: ScriptExecutionContext, record: wref<AISubActionScaleDurationWithDistance_Record>, actionPhase: Int32, baseDuration: Float) -> Float {
    let distance: Float;
    let distanceRange: Vector2;
    let source: wref<GameObject>;
    let sourcePosition: Vector4;
    let target: wref<GameObject>;
    let targetPosition: Vector4;
    let timeRange: Vector2;
    if !AIActionTarget.Get(context, record.Source(), false, source, sourcePosition) {
      return -1.00;
    };
    if !AIActionTarget.Get(context, record.Target(), false, target, targetPosition) {
      return -1.00;
    };
    distance = Vector4.Distance(targetPosition, sourcePosition);
    distanceRange = record.DistanceRange();
    distanceRange.X = MaxF(0.00, distanceRange.X);
    distanceRange.Y = MaxF(0.00, distanceRange.Y);
    if distanceRange.Y < distanceRange.X {
      distanceRange.Y = distanceRange.X;
    };
    timeRange = record.ScaleDistanceToTime();
    timeRange.X = MaxF(0.00, timeRange.X);
    timeRange.Y = MaxF(0.00, timeRange.Y);
    if timeRange.Y < timeRange.X {
      timeRange.Y = timeRange.X;
    };
    if distanceRange.Y >= 0.00 && distance > distanceRange.Y {
      distance = distanceRange.Y;
    };
    if distanceRange.X >= 0.00 && distance < distanceRange.X {
      distance = distanceRange.X;
    };
    return ProportionalClampF(distanceRange.X, distanceRange.Y, distance, timeRange.X, timeRange.Y);
  }
}
