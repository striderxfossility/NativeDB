
public abstract class BaseScriptableAction extends DeviceAction {

  protected let m_requesterID: EntityID;

  protected let m_executor: wref<GameObject>;

  protected let m_objectActionID: TweakDBID;

  protected let m_objectActionRecord: wref<ObjectAction_Record>;

  protected let m_inkWidgetID: TweakDBID;

  protected let interactionChoice: InteractionChoice;

  protected let m_interactionLayer: CName;

  protected let m_isActionRPGCheckDissabled: Bool;

  protected func GetOwnerPS(game: GameInstance) -> ref<PersistentState> {
    let psID: PersistentID = this.GetPersistentID();
    if PersistentID.IsDefined(psID) {
      return GameInstance.GetPersistencySystem(game).GetConstAccessToPSObject(psID, this.GetDeviceClassName());
    };
    return null;
  }

  public final func RegisterAsRequester(id: EntityID) -> Void {
    this.m_requesterID = id;
  }

  public final func GetRequesterID() -> EntityID {
    return this.m_requesterID;
  }

  public final func SetExecutor(executor: wref<GameObject>) -> Void {
    this.m_executor = executor;
  }

  public final const func GetExecutor() -> wref<GameObject> {
    return this.m_executor;
  }

  public final const func GetActionID() -> CName {
    let id: CName;
    if TDBID.IsValid(this.GetObjectActionID()) {
      id = this.GetObjectActionRecord().ActionName();
    } else {
      if NotEquals(this.GetClassName(), this.actionName) {
        id = this.actionName;
      } else {
        id = this.GetClassName();
      };
    };
    return id;
  }

  public const func GetObjectActionRecord() -> wref<ObjectAction_Record> {
    if IsDefined(this.m_objectActionRecord) {
      return this.m_objectActionRecord;
    };
    return TweakDBInterface.GetObjectActionRecord(this.m_objectActionID);
  }

  public const func GetObjectActionID() -> TweakDBID {
    let tweakDBID: TweakDBID;
    let record: wref<ObjectAction_Record> = this.GetObjectActionRecord();
    if IsDefined(record) {
      tweakDBID = record.GetID();
    };
    return tweakDBID;
  }

  public final const func GetGameplayCategoryID() -> TweakDBID {
    let returnValue: TweakDBID;
    let record: wref<ObjectAction_Record> = this.GetObjectActionRecord();
    if IsDefined(record) && IsDefined(this.GetObjectActionRecord().GameplayCategory()) {
      returnValue = this.GetObjectActionRecord().GameplayCategory().GetID();
    };
    return returnValue;
  }

  public final const func GetGameplayCategoryRecord() -> wref<ObjectActionGameplayCategory_Record> {
    let returnValue: wref<ObjectActionGameplayCategory_Record>;
    let record: wref<ObjectAction_Record> = this.GetObjectActionRecord();
    if IsDefined(record) {
      returnValue = this.GetObjectActionRecord().GameplayCategory();
    };
    return returnValue;
  }

  public func SetObjectActionID(id: TweakDBID) -> Void {
    this.m_objectActionID = id;
    this.m_objectActionRecord = null;
    this.m_objectActionRecord = this.GetObjectActionRecord();
    if IsDefined(this.m_objectActionRecord) {
      this.actionName = this.m_objectActionRecord.ActionName();
    };
    this.ProduceInteractionPart();
  }

  public func GetTweakDBChoiceRecord() -> String {
    let recordName: String;
    if IsDefined(this.GetObjectActionRecord()) && IsDefined(this.GetObjectActionRecord().ObjectActionUI()) && TDBID.IsValid(this.m_objectActionID) {
      recordName = this.GetObjectActionRecord().ObjectActionUI().Name();
    };
    if IsStringValid(recordName) {
      return recordName;
    };
    return NameToString(this.actionName);
  }

  public func GetTweakDBChoiceID() -> TweakDBID {
    let id: TweakDBID;
    return id;
  }

  public final func SetIsActionRPGCheckDissabled(value: Bool) -> Void {
    if value && this.IsInactive() {
      this.SetActive();
    };
    this.m_isActionRPGCheckDissabled = value;
  }

  public final const func GetIsActionRPGCheckDissabled() -> Bool {
    return this.m_isActionRPGCheckDissabled;
  }

  public final func SetInactive() -> Void {
    if !this.GetIsActionRPGCheckDissabled() {
      ChoiceTypeWrapper.SetType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
    };
  }

  public final func SetActive() -> Void {
    ChoiceTypeWrapper.ClearType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
  }

  public final const func IsInactive() -> Bool {
    return ChoiceTypeWrapper.IsType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
  }

  public final const func IsInteractionChoiceValid() -> Bool {
    if !IsStringValid(this.interactionChoice.choiceMetaData.tweakDBName) && !TDBID.IsValid(this.interactionChoice.choiceMetaData.tweakDBID) {
      return false;
    };
    return true;
  }

  protected final func ProduceInteractionPart() -> Void {
    let cost: Int32;
    let costPart: ref<InteractionChoiceCaptionQuickhackCostPart>;
    this.interactionChoice.choiceMetaData.tweakDBName = this.GetTweakDBChoiceRecord();
    if !this.IsInteractionChoiceValid() {
      return;
    };
    InteractionChoiceCaption.Clear(this.interactionChoice.captionParts);
    if IsDefined(this.GetObjectActionRecord()) && IsDefined(this.GetObjectActionRecord().ObjectActionUI()) {
      InteractionChoiceCaption.AddPartFromRecord(this.interactionChoice.captionParts, this.GetObjectActionRecord().ObjectActionUI().CaptionIcon());
    };
    cost = this.GetCost();
    if cost > 0 {
      costPart = new InteractionChoiceCaptionQuickhackCostPart();
      costPart.cost = cost;
      InteractionChoiceCaption.AddScriptPart(this.interactionChoice.captionParts, costPart);
    };
    ChoiceTypeWrapper.SetType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.CheckSuccess);
  }

  public func IsPossible(target: wref<GameObject>, opt actionRecord: wref<ObjectAction_Record>, opt objectActionsCallbackController: wref<gameObjectActionsCallbackController>) -> Bool {
    let targetPrereqs: array<wref<IPrereq_Record>>;
    if !IsDefined(actionRecord) {
      actionRecord = this.GetObjectActionRecord();
    };
    if IsDefined(objectActionsCallbackController) && objectActionsCallbackController.HasObjectAction(actionRecord) {
      return objectActionsCallbackController.IsObjectActionTargetPrereqFulfilled(actionRecord);
    };
    actionRecord.TargetPrereqs(targetPrereqs);
    return RPGManager.CheckPrereqs(targetPrereqs, target);
  }

  public func IsVisible(context: GetActionsContext, opt objectActionsCallbackController: wref<gameObjectActionsCallbackController>) -> Bool {
    let actionRecord: wref<ObjectAction_Record>;
    let instigatorPrereqs: array<wref<IPrereq_Record>>;
    if !IsNameValid(context.interactionLayerTag) {
      return false;
    };
    actionRecord = this.GetObjectActionRecord();
    if Equals(actionRecord.InteractionLayer(), n"any") || Equals(context.interactionLayerTag, actionRecord.InteractionLayer()) {
      if IsDefined(objectActionsCallbackController) && objectActionsCallbackController.HasObjectAction(actionRecord) {
        return objectActionsCallbackController.IsObjectActionInstigatorPrereqFulfilled(actionRecord);
      };
      actionRecord.InstigatorPrereqs(instigatorPrereqs);
      return RPGManager.CheckPrereqs(instigatorPrereqs, context.processInitiatorObject);
    };
    return false;
  }

  public func IsVisible(player: wref<GameObject>, opt objectActionsCallbackController: wref<gameObjectActionsCallbackController>) -> Bool {
    let instigatorPrereqs: array<wref<IPrereq_Record>>;
    let actionRecord: wref<ObjectAction_Record> = this.GetObjectActionRecord();
    if IsDefined(objectActionsCallbackController) && objectActionsCallbackController.HasObjectAction(actionRecord) {
      return objectActionsCallbackController.IsObjectActionInstigatorPrereqFulfilled(actionRecord);
    };
    actionRecord.InstigatorPrereqs(instigatorPrereqs);
    return RPGManager.CheckPrereqs(instigatorPrereqs, player);
  }

  public func ProcessRPGAction(gameInstance: GameInstance) -> Void {
    if this.PayCost() {
      this.StartAction(gameInstance);
      if this.GetActivationTime() > 0.00 {
        this.StartUpload(gameInstance);
      } else {
        this.CompleteAction(gameInstance);
      };
    };
  }

  public func StartAction(gameInstance: GameInstance) -> Void {
    let actionEffects: array<wref<ObjectActionEffect_Record>>;
    let player: ref<PlayerPuppet>;
    let objectActionRecord: ref<ObjectAction_Record> = this.GetObjectActionRecord();
    if IsDefined(objectActionRecord) {
      objectActionRecord.StartEffects(actionEffects);
    };
    this.ProcessStatusEffects(actionEffects, gameInstance);
    this.ProcessEffectors(actionEffects, gameInstance);
    if IsDefined(objectActionRecord) && IsDefined(objectActionRecord.Cooldown()) && IsDefined(this.GetExecutor()) {
      if TDBID.IsValid(objectActionRecord.Cooldown().GetID()) && this.GetExecutor().IsPlayer() {
        player = this.GetExecutor() as PlayerPuppet;
        if IsDefined(player) {
          player.GetCooldownStorage().StartSimpleCooldown(this);
        };
      };
    };
  }

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let actionEffects: array<wref<ObjectActionEffect_Record>>;
    let i: Int32;
    let rewards: array<wref<RewardBase_Record>>;
    let actionRecord: ref<ObjectAction_Record> = this.GetObjectActionRecord();
    if IsDefined(actionRecord) {
      actionRecord.Rewards(rewards);
    };
    i = 0;
    while i < ArraySize(rewards) {
      RPGManager.GiveReward(gameInstance, rewards[i].GetID(), Cast(this.GetRequesterID()));
      i += 1;
    };
    if IsDefined(actionRecord) {
      actionRecord.CompletionEffects(actionEffects);
    };
    this.ProcessStatusEffects(actionEffects, gameInstance);
    this.ProcessEffectors(actionEffects, gameInstance);
  }

  private func StartUpload(gameInstance: GameInstance) -> Void {
    return;
  }

  protected func ProcessStatusEffects(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
    let instigator: ref<GameObject> = this.GetExecutor();
    let i: Int32 = 0;
    while i < ArraySize(actionEffects) {
      switch actionEffects[i].Recipient().Type() {
        case gamedataObjectActionReference.Instigator:
          StatusEffectHelper.ApplyStatusEffect(this.GetExecutor(), actionEffects[i].StatusEffect().GetID(), instigator.GetEntityID());
          break;
        case gamedataObjectActionReference.Target:
          GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(this.m_requesterID, actionEffects[i].StatusEffect().GetID(), GameObject.GetTDBID(instigator), instigator.GetEntityID());
          break;
        case gamedataObjectActionReference.Source:
      };
      i += 1;
    };
  }

  protected final func ProcessEffectors(actionEffects: array<wref<ObjectActionEffect_Record>>, gameInstance: GameInstance) -> Void {
    let instigator: ref<GameObject> = this.GetExecutor();
    let i: Int32 = 0;
    while i < ArraySize(actionEffects) {
      switch actionEffects[i].Recipient().Type() {
        case gamedataObjectActionReference.Instigator:
          GameInstance.GetEffectorSystem(gameInstance).ApplyEffector(this.GetExecutor().GetEntityID(), instigator, actionEffects[i].EffectorToTrigger().GetID());
          break;
        case gamedataObjectActionReference.Target:
          GameInstance.GetEffectorSystem(gameInstance).ApplyEffector(this.m_requesterID, instigator, actionEffects[i].EffectorToTrigger().GetID());
          break;
        case gamedataObjectActionReference.Source:
      };
      i += 1;
    };
  }

  public func GetActivationTime() -> Float {
    let executor: ref<GameObject>;
    let timeMods: array<wref<StatModifier_Record>>;
    let uploadTime: Float;
    if IsDefined(this.GetObjectActionRecord()) {
      this.GetObjectActionRecord().ActivationTime(timeMods);
    };
    executor = this.GetExecutor();
    if IsDefined(executor) && ArraySize(timeMods) > 0 {
      if executor.IsPlayer() && ArraySize(timeMods) > 1 {
        uploadTime = RPGManager.CalculateStatModifiers(GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetPowerLevelDiff(), n"pl_diff_to_upload_time_modifier"), 1.00, 0.00, timeMods, executor.GetGame(), executor, Cast(this.GetRequesterID()), Cast(executor.GetEntityID()));
      } else {
        uploadTime = RPGManager.CalculateStatModifiers(timeMods, executor.GetGame(), executor, Cast(this.GetRequesterID()), Cast(executor.GetEntityID()));
      };
    };
    return uploadTime;
  }

  public final func GetCooldownDuration() -> Float {
    if IsDefined(this.GetObjectActionRecord()) {
      return this.GetObjectActionRecord().Cooldown().Duration();
    };
    return 0.00;
  }

  public final func CanPayCost(opt user: ref<GameObject>) -> Bool {
    let costs: array<wref<ObjectActionCost_Record>>;
    let executor: ref<GameObject>;
    let executorQuantity: Int32;
    let i: Int32;
    let itemCost: wref<ItemCost_Record>;
    let quantity: Int32;
    let statPoolCost: wref<StatPoolCost_Record>;
    let statPoolSys: ref<StatPoolsSystem>;
    let statPoolType: gamedataStatPoolType;
    let transactionSys: ref<TransactionSystem>;
    if IsDefined(user) {
      executor = user;
    } else {
      executor = this.GetExecutor();
    };
    this.GetObjectActionRecord().Costs(costs);
    i = 0;
    while i < ArraySize(costs) {
      quantity = this.GetCost();
      itemCost = costs[i] as ItemCost_Record;
      statPoolCost = costs[i] as StatPoolCost_Record;
      if IsDefined(itemCost) {
        transactionSys = GameInstance.GetTransactionSystem(executor.GetGame());
        executorQuantity = transactionSys.GetItemQuantity(executor, ItemID.CreateQuery(itemCost.Item().GetID()));
      } else {
        if IsDefined(statPoolCost) {
          statPoolSys = GameInstance.GetStatPoolsSystem(executor.GetGame());
          statPoolType = statPoolCost.StatPool().StatPoolType();
          executorQuantity = FloorF(statPoolSys.GetStatPoolValue(Cast(executor.GetEntityID()), statPoolType, false));
        };
      };
      if executorQuantity < quantity {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public func PayCost() -> Bool {
    let costs: array<wref<ObjectActionCost_Record>>;
    let currValue: Float;
    let executorQuantity: Int32;
    let itemCost: wref<ItemCost_Record>;
    let newValue: Float;
    let quantity: Int32;
    let statPoolCost: wref<StatPoolCost_Record>;
    let statPoolSys: ref<StatPoolsSystem>;
    let statPoolType: gamedataStatPoolType;
    let transactionSys: ref<TransactionSystem>;
    if IsDefined(this.GetObjectActionRecord()) {
      this.GetObjectActionRecord().Costs(costs);
    };
    if IsDefined(costs[0]) {
      quantity = this.GetCost();
      itemCost = costs[0] as ItemCost_Record;
      statPoolCost = costs[0] as StatPoolCost_Record;
      if IsDefined(itemCost) {
        transactionSys = GameInstance.GetTransactionSystem(this.GetExecutor().GetGame());
        executorQuantity = transactionSys.GetItemQuantity(this.GetExecutor(), ItemID.CreateQuery(itemCost.Item().GetID()));
        if executorQuantity < quantity {
          return false;
        };
        transactionSys.RemoveItem(this.GetExecutor(), ItemID.CreateQuery(itemCost.Item().GetID()), quantity);
      } else {
        if IsDefined(statPoolCost) {
          statPoolSys = GameInstance.GetStatPoolsSystem(this.GetExecutor().GetGame());
          statPoolType = statPoolCost.StatPool().StatPoolType();
          currValue = statPoolSys.GetStatPoolValue(Cast(this.GetExecutor().GetEntityID()), statPoolType, false);
          newValue = currValue - Cast(quantity);
          if newValue < 0.00 {
            return false;
          };
          statPoolSys.RequestSettingStatPoolValue(Cast(this.GetExecutor().GetEntityID()), statPoolType, newValue, this.GetExecutor(), false);
        };
      };
      return true;
    };
    return true;
  }

  public func GetCost() -> Int32 {
    let cost: Float;
    let costComponents: array<wref<ObjectActionCost_Record>>;
    let costMods: array<wref<StatModifier_Record>>;
    let device: ref<ScriptableDeviceComponentPS>;
    let extraCost: Float;
    let hackCategory: wref<HackCategory_Record>;
    let statPoolCost: wref<StatPoolCost_Record>;
    let targetID: EntityID;
    if IsDefined(this.GetExecutor()) && this.GetObjectActionRecord().GetCostsCount() > 0 {
      device = this.GetOwnerPS(this.GetExecutor().GetGame()) as ScriptableDeviceComponentPS;
      if IsDefined(device) && this.GetObjectActionID() == t"DeviceAction.TakeControlCameraClassHack" && device.WasActionPerformed(this.GetActionID(), EActionContext.QHack) {
        return 0;
      };
      this.GetObjectActionRecord().Costs(costComponents);
      if IsDefined(costComponents[0]) {
        BaseScriptableAction.GetCostMods(costComponents, costMods);
        if EntityID.IsDefined(this.GetRequesterID()) {
          targetID = this.GetRequesterID();
        } else {
          targetID = PersistentID.ExtractEntityID(this.GetPersistentID());
        };
        cost = RPGManager.CalculateStatModifiers(costMods, this.GetExecutor().GetGame(), this.GetExecutor(), Cast(targetID), Cast(this.GetExecutor().GetEntityID()));
        statPoolCost = costComponents[0] as StatPoolCost_Record;
        if Equals(statPoolCost.StatPool().StatPoolType(), gamedataStatPoolType.Memory) {
          hackCategory = this.GetObjectActionRecord().HackCategory();
          extraCost = GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetPowerLevelDiff(), n"pl_diff_to_memory_cost_modifier");
          cost += extraCost;
          if IsDefined(hackCategory) && Equals(hackCategory.EnumName(), n"UltimateHack") {
            cost += extraCost;
          };
        };
        if ArraySize(costMods) > 0 {
          return Max(1, CeilF(cost));
        };
        return Max(0, CeilF(cost));
      };
    };
    return 0;
  }

  public func GetBaseCost() -> Int32 {
    let constantCostMods: array<wref<StatModifier_Record>>;
    let cost: Float;
    let costComponents: array<wref<ObjectActionCost_Record>>;
    let costMods: array<wref<StatModifier_Record>>;
    let extraCost: Float;
    let hackCategory: wref<HackCategory_Record>;
    let i: Int32;
    let statPoolCost: wref<StatPoolCost_Record>;
    let targetID: EntityID;
    if IsDefined(this.GetExecutor()) && this.GetObjectActionRecord().GetCostsCount() > 0 {
      this.GetObjectActionRecord().Costs(costComponents);
      BaseScriptableAction.GetCostMods(costComponents, costMods);
      if IsDefined(costComponents[0]) {
        if EntityID.IsDefined(this.GetRequesterID()) {
          targetID = this.GetRequesterID();
        } else {
          targetID = PersistentID.ExtractEntityID(this.GetPersistentID());
        };
        i = 0;
        while i < ArraySize(costMods) {
          if IsDefined(costMods[i] as ConstantStatModifier_Record) {
            ArrayPush(constantCostMods, costMods[i]);
          };
          i += 1;
        };
        cost = RPGManager.CalculateStatModifiers(constantCostMods, this.GetExecutor().GetGame(), this.GetExecutor(), Cast(targetID), Cast(this.GetExecutor().GetEntityID()));
        statPoolCost = costComponents[0] as StatPoolCost_Record;
        if Equals(statPoolCost.StatPool().StatPoolType(), gamedataStatPoolType.Memory) {
          hackCategory = this.GetObjectActionRecord().HackCategory();
          extraCost = GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetPowerLevelDiff(), n"pl_diff_to_memory_cost_modifier");
          cost += extraCost;
          if IsDefined(hackCategory) && Equals(hackCategory.EnumName(), n"UltimateHack") {
            cost += extraCost;
          };
        };
        if ArraySize(costMods) > 0 {
          return Max(1, CeilF(cost));
        };
        return Max(0, CeilF(cost));
      };
    };
    return 0;
  }

  public final static func GetBaseCostStatic(executor: wref<GameObject>, actionRecord: wref<ObjectAction_Record>) -> Int32 {
    let constantCostMods: array<wref<StatModifier_Record>>;
    let cost: Float;
    let costComponents: array<wref<ObjectActionCost_Record>>;
    let costMods: array<wref<StatModifier_Record>>;
    let i: Int32;
    let targetID: EntityID;
    if IsDefined(executor) && actionRecord.GetCostsCount() > 0 {
      actionRecord.Costs(costComponents);
      BaseScriptableAction.GetCostMods(costComponents, costMods);
      if IsDefined(costComponents[0]) {
        i = 0;
        while i < ArraySize(costMods) {
          if IsDefined(costMods[i] as ConstantStatModifier_Record) {
            ArrayPush(constantCostMods, costMods[i]);
          };
          i += 1;
        };
        cost += RPGManager.CalculateStatModifiers(constantCostMods, executor.GetGame(), executor, Cast(targetID), Cast(executor.GetEntityID()));
        if ArraySize(costMods) > 0 {
          return Max(1, CeilF(cost));
        };
        return Max(0, CeilF(cost));
      };
    };
    return 0;
  }

  public final static func GetCostMods(costComponents: script_ref<array<wref<ObjectActionCost_Record>>>, out costMods: array<wref<StatModifier_Record>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(Deref(costComponents)) {
      Deref(costComponents)[i].CostMods(costMods);
      i += 1;
    };
  }

  private final func GetPowerLevelDiff() -> Float {
    let executorLevel: Float;
    let powerLevelDiff: Float;
    let statsSystem: ref<StatsSystem>;
    let targetID: EntityID;
    let targetLevel: Float;
    if !IsDefined(this.GetExecutor()) {
      return 0.00;
    };
    targetID = this.GetRequesterID();
    if !EntityID.IsDefined(targetID) {
      targetID = PersistentID.ExtractEntityID(this.GetPersistentID());
    };
    if !EntityID.IsDefined(targetID) {
      return 0.00;
    };
    statsSystem = GameInstance.GetStatsSystem(this.GetExecutor().GetGame());
    executorLevel = statsSystem.GetStatValue(Cast(this.GetExecutor().GetEntityID()), gamedataStatType.PowerLevel);
    targetLevel = statsSystem.GetStatValue(Cast(targetID), gamedataStatType.PowerLevel);
    powerLevelDiff = Cast(RoundMath(executorLevel) - RoundF(targetLevel));
    return powerLevelDiff;
  }
}

public abstract class ScriptableDeviceAction extends BaseScriptableAction {

  public let prop: ref<DeviceActionProperty>;

  protected let m_actionWidgetPackage: SActionWidgetPackage;

  protected let m_spiderbotActionLocationOverride: NodeRef;

  @default(TogglePersonalLink, 2.733)
  private let m_duration: Float;

  @default(ScriptableDeviceAction, true)
  private let m_canTriggerStim: Bool;

  private let m_wasPerformedOnOwner: Bool;

  private let m_shouldActivateDevice: Bool;

  @default(QuickHackToggleOpen, true)
  protected let m_isQuickHack: Bool;

  protected let m_isSpiderbotAction: Bool;

  protected let m_attachedProgram: TweakDBID;

  protected let m_activeStatusEffect: TweakDBID;

  protected let m_interactionIconType: TweakDBID;

  protected let m_hasInteraction: Bool;

  protected let m_inactiveReason: String;

  protected func GetOwnerPS(game: GameInstance) -> ref<PersistentState> {
    let psID: PersistentID = this.GetPersistentID();
    if PersistentID.IsDefined(psID) {
      return GameInstance.GetPersistencySystem(game).GetConstAccessToPSObject(psID, this.GetDeviceClassName());
    };
    return null;
  }

  public func ResolveAction(data: ref<ResolveActionData>) -> Bool {
    return true;
  }

  public final const func ShouldActivateDevice() -> Bool {
    return this.m_shouldActivateDevice;
  }

  public final func SetShouldActivateDevice(value: Bool) -> Void {
    this.m_shouldActivateDevice = value;
  }

  public final const func CanTriggerStim() -> Bool {
    return this.m_canTriggerStim;
  }

  public final func SetCanTriggerStim(canTrigger: Bool) -> Void {
    this.m_canTriggerStim = canTrigger;
  }

  public final const func GetDurationValue() -> Float {
    return this.m_duration;
  }

  public final func SetCompleted() -> Void {
    this.m_duration = 0.00;
  }

  public final const func IsCompleted() -> Bool {
    return this.m_duration <= 0.00;
  }

  public final const func IsStarted() -> Bool {
    return this.m_duration > 0.00;
  }

  public final func SetDurationValue(duration: Float) -> Void {
    this.m_duration = duration;
  }

  public final func GetActionName() -> CName {
    if IsNameValid(this.actionName) {
      return this.actionName;
    };
    return this.GetDefaultActionName();
  }

  protected func GetDefaultActionName() -> CName {
    return n"ScriptableDeviceAction";
  }

  public const func GetObjectActionRecord() -> wref<ObjectAction_Record> {
    if IsDefined(this.m_objectActionRecord) {
      return this.m_objectActionRecord;
    };
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetObjectActionRecord();
    };
    return TweakDBInterface.GetObjectActionRecord(TDBID.Create("DeviceAction." + NameToString(this.GetClassName())));
  }

  public const func CanSpiderbotCompleteThisAction(const device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    return true;
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ScriptableDeviceAction.IsAvailable(device) && ScriptableDeviceAction.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return true;
  }

  public final func AddDeviceName(deviceName: String) -> Void {
    this.localizedObjectName = deviceName;
  }

  public final func GetDeviceName() -> String {
    return this.localizedObjectName;
  }

  public func GetInkWidgetLibraryPath() -> ResRef {
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  public func GetInkWidgetLibraryID() -> CName {
    return n"";
  }

  public func SetInkWidgetTweakDBID(id: TweakDBID) -> Void {
    this.m_inkWidgetID = id;
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    if TDBID.IsValid(this.m_inkWidgetID) {
      return this.m_inkWidgetID;
    };
    return t"DevicesUIDefinitions.GenericDeviceActionWidget";
  }

  public func SetActiveStatusEffectTweakDBID(effectID: TweakDBID) -> Void {
    this.m_activeStatusEffect = effectID;
  }

  public func GetActiveStatusEffectTweakDBID() -> TweakDBID {
    return this.m_activeStatusEffect;
  }

  public func SetAttachedProgramTweakDBID(programID: TweakDBID) -> Void {
    this.m_attachedProgram = programID;
  }

  public func GetAttachedProgramTweakDBID() -> TweakDBID {
    return this.m_attachedProgram;
  }

  public final func SetIllegal(isIllegal: Bool) -> Void {
    if isIllegal {
      ChoiceTypeWrapper.SetType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Illegal);
    };
  }

  public final func ClearIllegal() -> Void {
    ChoiceTypeWrapper.ClearType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Illegal);
  }

  public final func IsIllegal() -> Bool {
    return ChoiceTypeWrapper.IsType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.Illegal);
  }

  public final func GetInteractionLayer() -> CName {
    return this.m_interactionLayer;
  }

  public final func SetInteractionLayer(layer: CName) -> Void {
    this.m_interactionLayer = layer;
  }

  public final func GetRequestType() -> gamedeviceRequestType {
    if Equals(this.m_interactionLayer, n"direct") {
      return gamedeviceRequestType.Direct;
    };
    if Equals(this.m_interactionLayer, n"remote") {
      return gamedeviceRequestType.Remote;
    };
    return IntEnum(0l);
  }

  public func SetObjectActionID(id: TweakDBID) -> Void {
    this.m_objectActionID = id;
    this.m_objectActionRecord = TweakDBInterface.GetObjectActionRecord(id);
    if IsDefined(this.m_objectActionRecord) {
      this.actionName = this.m_objectActionRecord.ActionName();
    };
    this.ProduceInteractionPart();
  }

  public final func SetAsQuickHack(opt wasExecutedAtLeastOnce: Bool) -> Void {
    this.m_isQuickHack = true;
    this.m_wasPerformedOnOwner = wasExecutedAtLeastOnce;
    this.ProduceInteractionParts();
  }

  private final func ProduceInteractionParts() -> Void {
    let costPart: ref<InteractionChoiceCaptionQuickhackCostPart>;
    let iconRecord: wref<ChoiceCaptionIconPart_Record>;
    if !this.IsInteractionChoiceValid() {
      return;
    };
    InteractionChoiceCaption.Clear(this.interactionChoice.captionParts);
    iconRecord = this.GetInteractionIcon();
    if IsDefined(iconRecord) {
      InteractionChoiceCaption.AddPartFromRecord(this.interactionChoice.captionParts, iconRecord);
    };
    if this.m_isQuickHack && this.GetCost() >= 0 || this.GetCost() > 0 {
      costPart = new InteractionChoiceCaptionQuickhackCostPart();
      costPart.cost = this.GetCost();
      InteractionChoiceCaption.AddScriptPart(this.interactionChoice.captionParts, costPart);
    };
    InteractionChoiceCaption.AddTextPart(this.interactionChoice.captionParts, LocKeyToString(TweakDBInterface.GetInteractionBaseRecord(TDBID.Create("Interactions." + this.interactionChoice.choiceMetaData.tweakDBName)).Caption()));
  }

  private func StartUpload(gameInstance: GameInstance) -> Void {
    let actionUploadListener: ref<QuickHackUploadListener>;
    let setQuickHackAttempt: ref<SetQuickHackAttemptEvent>;
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(gameInstance);
    let statMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.QuickHackUpload, gameStatModifierType.Additive, 1.00);
    GameInstance.GetStatsSystem(gameInstance).RemoveAllModifiers(Cast(this.m_requesterID), gamedataStatType.QuickHackUpload);
    GameInstance.GetStatsSystem(gameInstance).AddModifier(Cast(this.m_requesterID), statMod);
    actionUploadListener = new QuickHackUploadListener();
    actionUploadListener.m_action = this;
    actionUploadListener.m_gameInstance = gameInstance;
    statPoolSys.RequestRegisteringListener(Cast(this.m_requesterID), gamedataStatPoolType.QuickHackUpload, actionUploadListener);
    statPoolSys.RequestAddingStatPool(Cast(this.m_requesterID), t"BaseStatPools.BaseQuickHackUpload", true);
    if this.IsQuickHack() {
      setQuickHackAttempt = new SetQuickHackAttemptEvent();
      setQuickHackAttempt.wasQuickHackAttempt = true;
      GameInstance.GetPersistencySystem(gameInstance).QueuePSEvent(this.GetPersistentID(), this.GetDeviceClassName(), setQuickHackAttempt);
    };
  }

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let setQuickHack: ref<SetQuickHackEvent>;
    GameInstance.GetPersistencySystem(gameInstance).QueuePSDeviceEvent(this);
    this.CompleteAction(gameInstance);
    if this.IsQuickHack() {
      setQuickHack = new SetQuickHackEvent();
      setQuickHack.wasQuickHacked = true;
      setQuickHack.quickHackName = this.GetActionName();
      GameInstance.GetPersistencySystem(gameInstance).QueuePSEvent(this.GetPersistentID(), this.GetDeviceClassName(), setQuickHack);
      QuickhackModule.RequestRefreshQuickhackMenu(gameInstance, this.GetRequesterID());
      RPGManager.HealPuppetAfterQuickhack(gameInstance, this.m_executor);
    };
  }

  public func GetCost() -> Int32 {
    return this.GetCost();
  }

  public func SetInteractionIcon(iconType: TweakDBID) -> Void {
    this.m_interactionIconType = iconType;
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    let iconType: wref<ChoiceCaptionIconPart_Record>;
    if TDBID.IsValid(this.m_objectActionID) {
      iconType = this.GetObjectActionRecord().ObjectActionUI().CaptionIcon();
    };
    if IsDefined(iconType) {
      return iconType;
    };
    if TDBID.IsValid(this.m_interactionIconType) {
      iconType = TweakDBInterface.GetChoiceCaptionIconPartRecord(this.m_interactionIconType);
    } else {
      iconType = InteractionChoiceMetaData.GetTweakData(this.interactionChoice.choiceMetaData).CaptionIcon();
    };
    return iconType;
  }

  public final func SetAsSpiderbotAction() -> Void {
    this.m_isSpiderbotAction = true;
  }

  public final const func IsQuickHack() -> Bool {
    let actionRecord: wref<ObjectAction_Record>;
    let actionType: gamedataObjectActionType;
    let typeRecord: wref<ObjectActionType_Record>;
    if this.m_isQuickHack {
      return true;
    };
    actionRecord = this.GetObjectActionRecord();
    if IsDefined(actionRecord) {
      typeRecord = actionRecord.ObjectActionType();
    };
    if IsDefined(typeRecord) {
      actionType = typeRecord.Type();
      return Equals(actionType, gamedataObjectActionType.DeviceQuickHack) || Equals(actionType, gamedataObjectActionType.PuppetQuickHack);
    };
    return false;
  }

  public func GetActivationTime() -> Float {
    return this.GetActivationTime();
  }

  public final const func IsSpiderbotAction() -> Bool {
    return this.m_isSpiderbotAction;
  }

  public final func SetSpiderbotLocationOverrideReference(targetLocationReference: NodeRef) -> Void {
    this.m_spiderbotActionLocationOverride = targetLocationReference;
  }

  public final func GetSpiderbotLocationOverrideReference() -> NodeRef {
    return this.m_spiderbotActionLocationOverride;
  }

  public final func GetInteractionChoice() -> InteractionChoice {
    let choice: InteractionChoice;
    let i: Int32;
    if this.m_hasInteraction {
      ArrayInsert(choice.data, 0, ToVariant(this));
      choice.caption = this.interactionChoice.caption;
      choice.captionParts = this.interactionChoice.captionParts;
      choice.choiceMetaData.tweakDBID = this.interactionChoice.choiceMetaData.tweakDBID;
      choice.choiceMetaData.type = this.interactionChoice.choiceMetaData.type;
      if !TDBID.IsValid(this.interactionChoice.choiceMetaData.tweakDBID) {
        choice.choiceMetaData.tweakDBID = this.GetTweakDBChoiceID();
      };
      if Equals(StringToName(this.interactionChoice.choiceMetaData.tweakDBName), this.GetActionName()) {
        choice.choiceMetaData.tweakDBName = this.GetTweakDBChoiceRecord();
      } else {
        choice.choiceMetaData.tweakDBName = this.interactionChoice.choiceMetaData.tweakDBName;
      };
      i = 0;
      while i < ArraySize(this.interactionChoice.data) {
        ArrayPush(choice.data, ToVariant(FromVariant(this.interactionChoice.data[i])));
        i += 1;
      };
      if ArraySize(choice.captionParts.parts) == 0 {
        this.ProduceInteractionParts();
        choice.captionParts = this.interactionChoice.captionParts;
      };
    };
    return choice;
  }

  public final func GetActionWidgetPackage() -> SActionWidgetPackage {
    let actionWidgetPackage: SActionWidgetPackage;
    actionWidgetPackage.action = this;
    if !TDBID.IsValid(this.m_actionWidgetPackage.widgetTweakDBID) {
      actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
      this.ResolveActionWidgetTweakDBData();
    } else {
      actionWidgetPackage.widgetTweakDBID = this.m_actionWidgetPackage.widgetTweakDBID;
    };
    actionWidgetPackage.wasInitalized = this.m_actionWidgetPackage.wasInitalized;
    actionWidgetPackage.dependendActions = this.m_actionWidgetPackage.dependendActions;
    actionWidgetPackage.libraryPath = this.m_actionWidgetPackage.libraryPath;
    actionWidgetPackage.libraryID = this.m_actionWidgetPackage.libraryID;
    actionWidgetPackage.widgetName = this.m_actionWidgetPackage.widgetName;
    actionWidgetPackage.displayName = this.m_actionWidgetPackage.displayName;
    actionWidgetPackage.iconID = this.m_actionWidgetPackage.iconID;
    actionWidgetPackage.isWidgetInactive = this.m_actionWidgetPackage.isWidgetInactive;
    actionWidgetPackage.widgetState = this.m_actionWidgetPackage.widgetState;
    actionWidgetPackage.isValid = ResRef.IsValid(actionWidgetPackage.libraryPath) || IsNameValid(actionWidgetPackage.libraryID) || TDBID.IsValid(actionWidgetPackage.widgetTweakDBID);
    return actionWidgetPackage;
  }

  public final func CreateInteraction(opt actions: array<ref<DeviceAction>>, opt alternativeMainChoiceRecord: String, opt alternativeMainChoiceTweakDBID: TweakDBID) -> Void {
    let defaultChoiceID: TweakDBID;
    this.m_hasInteraction = true;
    if TDBID.IsValid(alternativeMainChoiceTweakDBID) {
      this.interactionChoice.choiceMetaData.tweakDBID = alternativeMainChoiceTweakDBID;
    } else {
      if IsStringValid(alternativeMainChoiceRecord) {
        this.interactionChoice.choiceMetaData.tweakDBName = alternativeMainChoiceRecord;
      } else {
        defaultChoiceID = this.GetTweakDBChoiceID();
        if TDBID.IsValid(defaultChoiceID) {
          this.interactionChoice.choiceMetaData.tweakDBID = defaultChoiceID;
        } else {
          if IsStringValid(alternativeMainChoiceRecord) {
            this.interactionChoice.choiceMetaData.tweakDBName = alternativeMainChoiceRecord;
          } else {
            this.interactionChoice.choiceMetaData.tweakDBName = this.GetTweakDBChoiceRecord();
          };
        };
      };
    };
    DeviceHelper.PushActionsIntoInteractionChoice(this.interactionChoice, actions);
  }

  public func HasUI() -> Bool {
    return Equals(this.m_actionWidgetPackage.wasInitalized, true) && IsStringValid(this.m_actionWidgetPackage.widgetName);
  }

  public func CreateActionWidgetPackage(opt actions: array<ref<DeviceAction>>) -> Void {
    this.m_actionWidgetPackage.wasInitalized = true;
    this.m_actionWidgetPackage.dependendActions = actions;
    this.m_actionWidgetPackage.libraryPath = this.GetInkWidgetLibraryPath();
    this.m_actionWidgetPackage.libraryID = this.GetInkWidgetLibraryID();
    this.m_actionWidgetPackage.widgetName = ToString(this.GetActionName());
    this.m_actionWidgetPackage.displayName = this.GetCurrentDisplayString();
    this.m_actionWidgetPackage.iconID = this.GetActionName();
    this.m_actionWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
    this.ResolveActionWidgetTweakDBData();
  }

  public func CreateActionWidgetPackage(widgetTweakDBID: TweakDBID, opt actions: array<ref<DeviceAction>>) -> Void {
    this.CreateActionWidgetPackage(actions);
    if TDBID.IsValid(widgetTweakDBID) {
      this.m_actionWidgetPackage.widgetTweakDBID = widgetTweakDBID;
      this.ResolveActionWidgetTweakDBData();
    };
  }

  protected final func ResolveActionWidgetTweakDBData() -> Void {
    let record: ref<WidgetDefinition_Record>;
    if TDBID.IsValid(this.m_actionWidgetPackage.widgetTweakDBID) {
      record = TweakDBInterface.GetWidgetDefinitionRecord(this.m_actionWidgetPackage.widgetTweakDBID);
      if record != null {
        this.m_actionWidgetPackage.libraryPath = record.LibraryPath();
        this.m_actionWidgetPackage.libraryID = StringToName(record.LibraryID());
      };
    };
  }

  public func CreateCustomInteraction(opt actions: array<ref<DeviceAction>>, customName1: String, customName2: String, opt customID1: TweakDBID, opt customID2: TweakDBID) -> Void;

  public final func SetInactiveWithReason(isActiveIf: Bool, reason: String) -> Void {
    if !isActiveIf {
      this.SetInactive();
      this.SetInactiveReason(reason);
    };
  }

  public final func SetInactiveReason(reasonStr: String) -> Void {
    if NotEquals(reasonStr, "") {
      this.m_inactiveReason = reasonStr;
    };
  }

  public final const func GetInactiveReason() -> String {
    return this.m_inactiveReason;
  }

  public final func SetInactiveReasonAsCaption() -> Void {
    if this.IsInactive() {
      this.interactionChoice.caption = this.m_inactiveReason;
    };
  }

  public final const func GetDurationFromTDBRecord(record: TweakDBID) -> Float {
    let minigameActionRecord: ref<MinigameAction_Record> = TweakDBInterface.GetMinigameActionRecord(record);
    let duration: Float = minigameActionRecord.Duration();
    return duration;
  }
}

public abstract class ActionBool extends ScriptableDeviceAction {

  public func GetProperties() -> array<ref<DeviceActionProperty>> {
    let arr: array<ref<DeviceActionProperty>>;
    ArrayPush(arr, this.prop);
    return arr;
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String;
    if !FromVariant(this.prop.first) {
      str = NameToString(FromVariant(this.prop.second));
    } else {
      str = NameToString(FromVariant(this.prop.third));
    };
    return str;
  }

  public final func GetValue() -> Bool {
    return FromVariant(this.prop.first);
  }

  public final func OverrideInteractionRecord(newRecordforTrue: TweakDBID, newRecordForFalse: TweakDBID) -> Void {
    let isTrue: Bool;
    let newRecord: TweakDBID;
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, isTrue);
    if isTrue {
      newRecord = newRecordforTrue;
    } else {
      newRecord = newRecordForFalse;
    };
    if TDBID.IsValid(newRecord) {
      this.m_hasInteraction = true;
      this.interactionChoice.choiceMetaData.tweakDBID = newRecord;
    };
  }

  public func CreateCustomInteraction(opt actions: array<ref<DeviceAction>>, customName1: String, customName2: String, opt customID1: TweakDBID, opt customID2: TweakDBID) -> Void {
    let value: Bool;
    let useTweakDB: Bool = TDBID.IsValid(customID1) && TDBID.IsValid(customID2);
    if IsStringValid(customName1) && IsStringValid(customName2) || useTweakDB {
      this.m_hasInteraction = true;
      DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, value);
      if !value {
        if useTweakDB {
          this.interactionChoice.choiceMetaData.tweakDBID = customID1;
        } else {
          this.interactionChoice.choiceMetaData.tweakDBName = customName1;
        };
      } else {
        if useTweakDB {
          this.interactionChoice.choiceMetaData.tweakDBID = customID2;
        } else {
          this.interactionChoice.choiceMetaData.tweakDBName = customName2;
        };
      };
      DeviceHelper.PushActionsIntoInteractionChoice(this.interactionChoice, actions);
    } else {
      this.CreateInteraction(actions);
    };
  }

  public func CreateActionWidgetPackage(opt actions: array<ref<DeviceAction>>) -> Void {
    let value: Bool;
    this.CreateActionWidgetPackage(actions);
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, value);
    if !value {
      this.m_actionWidgetPackage.widgetState = EWidgetState.OFF;
    } else {
      this.m_actionWidgetPackage.widgetState = EWidgetState.ON;
    };
  }
}

public abstract class ActionInt extends ScriptableDeviceAction {

  public func GetProperties() -> array<ref<DeviceActionProperty>> {
    let arr: array<ref<DeviceActionProperty>>;
    ArrayPush(arr, this.prop);
    return arr;
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String = NameToString(this.prop.name) + " " + IntToString(FromVariant(this.prop.first));
    return str;
  }
}

public abstract class ActionFloat extends ScriptableDeviceAction {

  public func GetProperties() -> array<ref<DeviceActionProperty>> {
    let arr: array<ref<DeviceActionProperty>>;
    ArrayPush(arr, this.prop);
    return arr;
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String = NameToString(this.prop.name) + " " + FloatToString(FromVariant(this.prop.first));
    return str;
  }
}

public abstract class ActionName extends ScriptableDeviceAction {

  public func GetProperties() -> array<ref<DeviceActionProperty>> {
    let arr: array<ref<DeviceActionProperty>>;
    ArrayPush(arr, this.prop);
    return arr;
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String = NameToString(this.prop.name) + " " + NameToString(FromVariant(this.prop.first));
    return str;
  }
}

public abstract class ActionNodeRef extends ScriptableDeviceAction {

  public func GetProperties() -> array<ref<DeviceActionProperty>> {
    let arr: array<ref<DeviceActionProperty>>;
    ArrayPush(arr, this.prop);
    return arr;
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String = NameToString(this.prop.name) + " NodeRef (conversion to string not supported yet)";
    return str;
  }
}

public abstract class ActionEntityReference extends ScriptableDeviceAction {

  public func GetProperties() -> array<ref<DeviceActionProperty>> {
    let arr: array<ref<DeviceActionProperty>>;
    ArrayPush(arr, this.prop);
    return arr;
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String = NameToString(this.prop.name) + " EntityReference (conversion to string not supported yet)";
    return str;
  }
}

public abstract class ActionWorkSpot extends ActionBool {

  private let m_workspotTarget: wref<gamePuppet>;

  public final func SetUp(owner: ref<DeviceComponentPS>, workspotTarget: wref<gamePuppet>) -> Void {
    this.SetUp(owner);
    this.m_workspotTarget = workspotTarget;
  }

  public final func GetWorkspotTarget() -> wref<gamePuppet> {
    return this.m_workspotTarget;
  }
}

public abstract class ActionSkillCheck extends ActionBool {

  protected let m_skillCheck: ref<SkillCheckBase>;

  @default(ActionDemolition, EDeviceChallengeSkill.Athletics)
  @default(ActionEngineering, EDeviceChallengeSkill.Engineering)
  @default(ActionHacking, EDeviceChallengeSkill.Hacking)
  protected let m_skillCheckName: EDeviceChallengeSkill;

  @default(ActionDemolition, LocKey#22271)
  @default(ActionEngineering, LocKey#22276)
  @default(ActionHacking, LocKey#22278)
  protected let m_localizedName: String;

  protected let m_skillcheckDescription: UIInteractionSkillCheck;

  protected let m_wasPassed: Bool;

  protected let m_availableUnpowered: Bool;

  protected func GetDefaultActionName() -> CName {
    return n"ActionSkillCheck";
  }

  public final func SetProperties(skillCheck: ref<SkillCheckBase>) -> Void {
    this.actionName = this.GetDefaultActionName();
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
    this.m_skillCheck = skillCheck;
  }

  public final func CreateInteraction(requester: ref<GameObject>, opt actions: array<ref<DeviceAction>>, opt alternativeMainChoiceRecord: String, opt alternativeMainChoiceRecordID: TweakDBID) -> Void {
    let choiceType: gameinteractionsChoiceType;
    this.m_hasInteraction = true;
    if IsStringValid(alternativeMainChoiceRecord) {
      this.interactionChoice.choiceMetaData.tweakDBName = alternativeMainChoiceRecord;
    } else {
      if TDBID.IsValid(alternativeMainChoiceRecordID) {
        this.interactionChoice.choiceMetaData.tweakDBID = alternativeMainChoiceRecordID;
      } else {
        if TDBID.IsValid(this.m_skillCheck.GetAlternativeName()) {
          this.interactionChoice.choiceMetaData.tweakDBID = this.m_skillCheck.GetAlternativeName();
        } else {
          this.interactionChoice.choiceMetaData.tweakDBName = this.GetTweakDBChoiceRecord();
        };
      };
    };
    this.m_skillCheck.GetBaseSkill().SetEntityID(this.GetRequesterID());
    this.m_skillcheckDescription = this.CreateSkillcheckInfo(requester);
    choiceType = this.m_wasPassed ? gameinteractionsChoiceType.CheckSuccess : gameinteractionsChoiceType.CheckFailed;
    ChoiceTypeWrapper.SetType(this.interactionChoice.choiceMetaData.type, choiceType);
    if this.m_wasPassed {
      DeviceHelper.PushActionsIntoInteractionChoice(this.interactionChoice, actions);
    };
  }

  public final func CreateSkillcheckInfo(requester: ref<GameObject>) -> UIInteractionSkillCheck {
    this.m_wasPassed = this.m_skillCheck.Evaluate(requester);
    this.m_skillcheckDescription.isValid = true;
    this.m_skillcheckDescription.skillCheck = this.m_skillCheckName;
    this.m_skillcheckDescription.skillName = this.m_localizedName;
    this.m_skillcheckDescription.requiredSkill = this.m_skillCheck.GetBaseSkill().GetRequiredLevel(requester.GetGame());
    this.m_skillcheckDescription.playerSkill = this.m_skillCheck.GetBaseSkill().GetPlayerSkill(requester);
    this.m_skillcheckDescription.actionDisplayName = this.interactionChoice.caption;
    this.m_skillcheckDescription.isPassed = this.m_wasPassed;
    this.m_skillcheckDescription.ownerID = this.GetRequesterID();
    if this.m_skillCheck.m_additionalRequirements.HasAdditionalRequirements() {
      this.m_skillcheckDescription.hasAdditionalRequirements = true;
      this.m_skillcheckDescription.additionalReqOperator = this.m_skillCheck.m_additionalRequirements.GetOperator();
      this.m_skillcheckDescription.additionalRequirements = this.m_skillCheck.m_additionalRequirements.CreateDescription(requester, this.GetRequesterID());
    };
    return this.m_skillcheckDescription;
  }

  public final const func GetPlayerStateMachine(requester: ref<GameObject>) -> ref<IBlackboard> {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(requester.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(requester.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return playerStateMachineBlackboard;
  }

  public final const func GetSkillcheckInfo() -> UIInteractionSkillCheck {
    return this.m_skillcheckDescription;
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext, availableUnpowered: Bool) -> Bool {
    if ActionSkillCheck.IsAvailable(device, availableUnpowered) && ScriptableDeviceAction.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>, availableUnpowered: Bool) -> Bool {
    if device.IsDisabled() || device.IsUnpowered() && !availableUnpowered || device.IsBroken() {
      return false;
    };
    return true;
  }

  public func GetTweakDBChoiceRecord() -> String {
    let str: String = NameToString(this.GetDefaultActionName());
    return str;
  }

  public final func WasPassed() -> Bool {
    return this.m_wasPassed;
  }

  public final func AvailableOnUnpowered() -> Bool {
    return this.m_availableUnpowered;
  }

  public final func SetAvailableOnUnpowered() -> Void {
    this.m_availableUnpowered = true;
  }

  public func GetAttributeCheckType() -> EDeviceChallengeSkill {
    return this.m_skillCheckName;
  }

  public final func ResetCaption() -> Void {
    this.interactionChoice.caption = "";
  }
}

public class RemoteBreach extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"RemoteBreach";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class PingDevice extends ActionBool {

  @default(PingDevice, true)
  private let m_shouldForward: Bool;

  public final func SetProperties() -> Void {
    this.actionName = n"Ping";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }

  public final const func ShouldForward() -> Bool {
    return this.m_shouldForward;
  }

  public final func SetShouldForward(shouldForward: Bool) -> Void {
    this.m_shouldForward = shouldForward;
  }

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    this.CompleteAction(gameInstance);
    if this.m_shouldForward {
      this.GetExecutor().GetDeviceLink().PingDevicesNetwork();
    };
  }
}

public class ActionHacking extends ActionSkillCheck {

  protected func GetDefaultActionName() -> CName {
    return n"ActionHacking";
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.JackInIcon");
  }
}

public class ActionEngineering extends ActionSkillCheck {

  protected func GetDefaultActionName() -> CName {
    return n"ActionEngineering";
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.UseIcon");
  }
}

public class ActionDemolition extends ActionSkillCheck {

  protected func GetDefaultActionName() -> CName {
    return n"ActionDemolition";
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.UseIcon");
  }
}

public class ActionScavenge extends ActionInt {

  public final func SetProperties(amoutOfScraps: Int32) -> Void {
    this.actionName = n"ActionScavenge";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(this.actionName, amoutOfScraps);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if ActionScavenge.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.CanBeScavenged() {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "ActionScavenge";
  }
}

public class BaseDeviceStatus extends ActionEnum {

  public let m_isRestarting: Bool;

  public func SetProperties(const deviceRef: ref<ScriptableDeviceComponentPS>) -> Void {
    this.m_isRestarting = deviceRef.IsRestarting();
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"STATUS", EnumInt(deviceRef.GetDeviceState()));
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String;
    let baseStateValue: Int32 = 0;
    if VariantIsValid(this.prop.first) {
      baseStateValue = FromVariant(this.prop.first);
    };
    if this.m_isRestarting {
      return "LocKey#17797";
    };
    switch baseStateValue {
      case -2:
        Log("BaseDeviceStatus / Wrong prop.value this should never happen");
        str = "LocKey#17796";
        break;
      case -1:
        str = "LocKey#17793";
        break;
      case 0:
        str = "LocKey#17794";
        break;
      case 1:
        str = "LocKey#17795";
        break;
      default:
        str = "Unknown Status - DEBUG";
    };
    Log("BaseDeviceStatus / Device State unhandled");
    return str;
  }

  public final const func GetScannerStatusRecord() -> TweakDBID {
    let ending: String;
    let recordID: TweakDBID;
    let recordbase: String = "scanning_devices.";
    let baseStateValue: Int32 = FromVariant(this.prop.first);
    if this.m_isRestarting {
      ending = "booting";
    } else {
      switch baseStateValue {
        case -2:
          ending = "disabled";
          Log("BaseDeviceStatus / Wrong prop.value this should never happen");
          break;
        case -1:
          ending = "unpowered";
          break;
        case 0:
          ending = "off";
          break;
        case 1:
          ending = "on";
          break;
        default:
          Log("BaseDeviceStatus / Device State unhandled");
      };
    };
    recordID = TDBID.Create(recordbase + ending);
    return recordID;
  }

  public const func GetStatusValue() -> Int32 {
    return FromVariant(this.prop.first);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if BaseDeviceStatus.IsAvailable(device) && BaseDeviceStatus.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(requesterClearancer: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(requesterClearancer, DefaultActionsParametersHolder.GetStatusClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.External) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "wrong_action";
  }
}

public class QuestForceDestructible extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceDestructible";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceDestructible", true, n"QuestForceDestructible", n"QuestForceDestructible");
  }
}

public class QuestForceIndestructible extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceIndestructible";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class QuestForceInvulnerable extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceInvulnerable";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class QuestForceEnabled extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceEnabled";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceEnabled", true, n"QuestForceEnabled", n"QuestForceEnabled");
  }
}

public class QuestForceDisabled extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceDisabled";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceDisabled", true, n"QuestForceDisabled", n"QuestForceDisabled");
  }
}

public class QuestForcePower extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForcePower";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForcePower", true, n"QuestForcePower", n"QuestForcePower");
  }
}

public class QuestForceUnpower extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceUnpower";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceUnpower", true, n"QuestForceUnpower", n"QuestForceUnpower");
  }
}

public class QuestForceON extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceON";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceON", true, n"QuestForceON", n"QuestForceON");
  }
}

public class QuestForceOFF extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceOFF";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceOFF", true, n"QuestForceOFF", n"QuestForceOFF");
  }
}

public class QuestForceAuthorizationEnabled extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"AuthorizationEnable";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceAuthorizationEnabled", true, n"QuestForceAuthorizationEnabled", n"QuestForceAuthorizationEnabled");
  }
}

public class QuestForceAuthorizationDisabled extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"AuthorizationDisable";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceAuthorizationDisabled", true, n"QuestForceAuthorizationDisabled", n"QuestForceAuthorizationDisabled");
  }
}

public class QuestForceDisconnectPersonalLink extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceDisconnectPersonalLink";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceDisconnectPersonalLink", true, n"QuestForceDisconnectPersonalLink", n"QuestForceDisconnectPersonalLink");
  }
}

public class QuestForcePersonalLinkUnderStrictQuestControl extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForcePersonalLinkUnderStrictQuestControl";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class QuestEnableFixing extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"EnableFixing";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestEnableFixing", true, n"QuestEnableFixing", n"QuestEnableFixing");
  }
}

public class QuestDisableFixing extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"DisableFixing";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestDisableFixing", true, n"QuestDisableFixing", n"QuestDisableFixing");
  }
}

public class QuestForceJuryrigTrapArmed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"JuryrigTrapArmed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceJuryrigTrapArmed", true, n"QuestForceJuryrigTrapArmed", n"QuestForceJuryrigTrapArmed");
  }
}

public class QuestForceJuryrigTrapDeactivated extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"JuryrigTrapDeactivate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceJuryrigTrapDeactivated", true, n"QuestForceJuryrigTrapDeactivated", n"QuestForceJuryrigTrapDeactivated");
  }
}

public class QuestForceSecuritySystemSafe extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceSecuritySystemSafe";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceSecuritySystemSafe", true, n"QuestForceSecuritySystemSafe", n"QuestForceSecuritySystemSafe");
  }
}

public class QuestForceSecuritySystemAlarmed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceSecuritySystemAlarmed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceSecuritySystemAlarmed", true, n"QuestForceSecuritySystemAlarmed", n"QuestForceSecuritySystemAlarmed");
  }
}

public class QuestForceSecuritySystemArmed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceSecuritySystemArmed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceSecuritySystemArmed", true, n"QuestForceSecuritySystemArmed", n"QuestForceSecuritySystemArmed");
  }
}

public class QuestStartGlitch extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestStartGlitch";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestStartGlitch", true, n"QuestStartGlitch", n"QuestStartGlitch");
  }
}

public class QuestStopGlitch extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestStopGlitch";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestStopGlitch", true, n"QuestStopGlitch", n"QuestStopGlitch");
  }
}

public class QuestEnableInteraction extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"EnableInteraction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestEnableInteraction", true, n"QuestEnableInteraction", n"QuestEnableInteraction");
  }
}

public class QuestDisableInteraction extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"DisableInteraction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestDisableInteraction", true, n"QuestDisableInteraction", n"QuestDisableInteraction");
  }
}

public class SetDeviceON extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetDeviceON";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"SetDeviceON", true, n"LocKey#255", n"LocKey#255");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SetDeviceON.IsAvailable(device) && SetDeviceON.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsUnpowered() || device.IsDisabled() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetSetOnSetOffActions()) {
      return true;
    };
    return false;
  }
}

public class SetDeviceOFF extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetDeviceOFF";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"SetDeviceOFF", true, n"LocKey#256", n"LocKey#256");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SetDeviceOFF.IsAvailable(device) && SetDeviceOFF.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsUnpowered() || device.IsDisabled() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetSetOnSetOffActions()) {
      return true;
    };
    return false;
  }
}

public class SetDeviceUnpowered extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetDeviceUnpowered";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"SetDeviceUnpowered", true, n"LocKey#258", n"LocKey#258");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SetDeviceUnpowered.IsAvailable(device) && SetDeviceUnpowered.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.GetDeviceStatusAction().GetStatusValue() == EnumInt(EDeviceStatus.DISABLED) {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetSetOnSetOffActions()) {
      return true;
    };
    return false;
  }
}

public class SetDevicePowered extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetDevicePowered";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"SetDevicePowered", true, n"LocKey#257", n"LocKey#257");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SetDevicePowered.IsAvailable(device) && SetDevicePowered.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.GetDeviceStatusAction().GetStatusValue() == EnumInt(EDeviceStatus.DISABLED) {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetSetOnSetOffActions()) {
      return true;
    };
    return false;
  }
}

public class DisassembleDevice extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"DisassembleDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"DisassembleDevice", true, n"LocKey#264", n"LocKey#264");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if device.CanBeDisassembled() {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.CanBeDisassembled() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetDisassembleClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "ExtractParts";
  }
}

public class FixDevice extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"FixDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"FixDevice", true, n"LocKey#266", n"LocKey#266");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if device.CanBeFixed() {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.CanBeFixed() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetDisassembleClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "FixDevice";
  }
}

public class ToggleJuryrigTrap extends ActionBool {

  public final func SetProperties(state: EJuryrigTrapState) -> Void {
    this.actionName = n"ToggleJuryrigTrap";
    let isArmed: Bool = Equals(state, EJuryrigTrapState.ARMED);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleJuryrigTrap", isArmed, n"LocKey#270", n"LocKey#270");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return ToggleJuryrigTrap.IsAvailable(device) && ToggleJuryrigTrap.IsContextValid(context);
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return device.CanBeTrapped() && Equals(device.GetJuryrigTrapState(), EJuryrigTrapState.UNARMED);
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return NotEquals(context.requestType, gamedeviceRequestType.External);
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "JuryrigTrap";
    };
    return "DisableJuryrigTrap";
  }
}

public class ToggleActivation extends ActionBool {

  public final func SetProperties(status: EDeviceStatus) -> Void {
    this.actionName = n"ToggleActivation";
    let disabled: Bool = false;
    if Equals(status, EDeviceStatus.DISABLED) {
      disabled = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleActivation", disabled, n"LocKey#247", n"LocKey#245");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ToggleActivation.IsAvailable(device) && ToggleActivation.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleActivationClearance()) {
      return true;
    };
    return false;
  }
}

public class TogglePower extends ActionBool {

  @default(TogglePower, Power)
  protected let m_TrueRecordName: String;

  @default(TogglePower, Unpower)
  protected let m_FalseRecordName: String;

  public final func SetProperties(status: EDeviceStatus) -> Void {
    let unpowered: Bool;
    this.actionName = n"TogglePower";
    if Equals(status, EDeviceStatus.UNPOWERED) {
      unpowered = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"TogglePower", unpowered, n"LocKey#258", n"LocKey#257");
  }

  public final func SetProperties(status: EDeviceStatus, nameOnTrue: TweakDBID, nameOnFalse: TweakDBID) -> Void {
    let displayNameOnFalse: CName;
    let displayNameOnTrue: CName;
    let record: wref<InteractionBase_Record>;
    let unpowered: Bool;
    if Equals(status, EDeviceStatus.UNPOWERED) {
      unpowered = true;
    };
    this.actionName = n"TogglePower";
    if !TDBID.IsValid(nameOnTrue) {
      displayNameOnTrue = n"LocKey#258";
    } else {
      record = TweakDBInterface.GetInteractionBaseRecord(nameOnTrue);
      if IsDefined(record) {
        this.m_TrueRecordName = record.Name();
        displayNameOnTrue = StringToName(LocKeyToString(record.Caption()));
      };
    };
    if !TDBID.IsValid(nameOnFalse) {
      displayNameOnFalse = n"LocKey#257";
    } else {
      record = TweakDBInterface.GetInteractionBaseRecord(nameOnFalse);
      if IsDefined(record) {
        this.m_FalseRecordName = record.Name();
        displayNameOnFalse = StringToName(LocKeyToString(record.Caption()));
      };
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, unpowered, displayNameOnTrue, displayNameOnFalse);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if TogglePower.IsAvailable(device) && TogglePower.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.GetDeviceStatusAction().GetStatusValue() == EnumInt(EDeviceStatus.DISABLED) {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetTogglePowerClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "Unpower";
    };
    return "Power";
  }
}

public class ToggleON extends ActionBool {

  @default(ToggleON, On)
  protected let m_TrueRecordName: String;

  @default(ToggleON, Off)
  protected let m_FalseRecordName: String;

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties(status: EDeviceStatus) -> Void {
    let isOn: Bool;
    this.actionName = n"ToggleON";
    if Equals(status, EDeviceStatus.ON) {
      isOn = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleOn", isOn, n"LocKey#255", n"LocKey#256");
  }

  public final func SetProperties(status: EDeviceStatus, nameOnTrue: TweakDBID, nameOnFalse: TweakDBID) -> Void {
    let displayNameOnFalse: CName;
    let displayNameOnTrue: CName;
    let isOn: Bool;
    let record: wref<InteractionBase_Record>;
    this.actionName = n"ToggleON";
    if Equals(status, EDeviceStatus.ON) {
      isOn = true;
    };
    if !TDBID.IsValid(nameOnTrue) {
      displayNameOnTrue = n"LocKey#255";
    } else {
      record = TweakDBInterface.GetInteractionBaseRecord(nameOnTrue);
      if IsDefined(record) {
        this.m_TrueRecordName = record.Name();
        displayNameOnTrue = StringToName(LocKeyToString(record.Caption()));
      };
    };
    if !TDBID.IsValid(nameOnFalse) {
      displayNameOnFalse = n"LocKey#256";
    } else {
      record = TweakDBInterface.GetInteractionBaseRecord(nameOnFalse);
      if IsDefined(record) {
        this.m_FalseRecordName = record.Name();
        displayNameOnFalse = StringToName(LocKeyToString(record.Caption()));
      };
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleOn", isOn, displayNameOnTrue, displayNameOnFalse);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ToggleON.IsAvailable(device) && ToggleON.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsDisabled() || device.IsUnpowered() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOnClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return this.m_TrueRecordName;
    };
    return this.m_FalseRecordName;
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.ToggleDeviceActionWidget";
  }

  public func GetActivationTime() -> Float {
    if this.IsQuickHack() {
      return this.GetActivationTime();
    };
    return 0.00;
  }
}

public class QuickHackToggleON extends ActionBool {

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.OnOff");
  }

  public final func SetProperties(status: EDeviceStatus) -> Void {
    let isOn: Bool;
    this.actionName = n"QuickHackToggleON";
    if Equals(status, EDeviceStatus.ON) {
      isOn = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleOn", isOn, n"LocKey#256", n"LocKey#256");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    if !FromVariant(this.prop.first) {
      return "On";
    };
    return "Off";
  }
}

public class ToggleBlockade extends ActionBool {

  @default(ToggleBlockade, Raise)
  protected let m_TrueRecordName: String;

  @default(ToggleBlockade, Lower)
  protected let m_FalseRecordName: String;

  public final func SetProperties(isActive: Bool, nameOnTrue: TweakDBID, nameOnFalse: TweakDBID) -> Void {
    let displayNameOnFalse: CName;
    let displayNameOnTrue: CName;
    let record: wref<InteractionBase_Record>;
    this.actionName = n"ToggleBlockade";
    if !TDBID.IsValid(nameOnTrue) {
      nameOnTrue = t"Interactions.Raise";
    };
    if !TDBID.IsValid(nameOnFalse) {
      nameOnFalse = nameOnTrue = t"Interactions.Lower";
    };
    record = TweakDBInterface.GetInteractionBaseRecord(nameOnTrue);
    this.m_FalseRecordName = record.Name();
    displayNameOnTrue = StringToName(LocKeyToString(record.Caption()));
    record = TweakDBInterface.GetInteractionBaseRecord(nameOnFalse);
    this.m_TrueRecordName = record.Name();
    displayNameOnFalse = StringToName(LocKeyToString(record.Caption()));
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleBlockade", isActive, displayNameOnTrue, displayNameOnFalse);
  }

  public final static func IsDefaultConditionMet(device: ref<RoadBlockControllerPS>, context: GetActionsContext) -> Bool {
    if ToggleBlockade.IsAvailable(device) && ToggleBlockade.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<RoadBlockControllerPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return this.m_TrueRecordName;
    };
    return this.m_FalseRecordName;
  }
}

public class QuickHackToggleBlockade extends ToggleBlockade {

  public func GetTweakDBChoiceRecord() -> String {
    let recordName: String;
    if TDBID.IsValid(this.m_objectActionID) {
      recordName = this.GetObjectActionRecord().ObjectActionUI().Name();
    };
    if IsStringValid(recordName) {
      return recordName;
    };
    return this.GetTweakDBChoiceRecord();
  }
}

public class QuestForceRoadBlockadeActivate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceRoadBlockadeActivate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceRoadBlockadeActivate", true, n"QuestForceRoadBlockadeActivate", n"QuestForceRoadBlockadeActivate");
  }
}

public class QuestForceRoadBlockadeDeactivate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceRoadBlockadeDeactivate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceRoadBlockadeDeactivate", true, n"QuestForceRoadBlockadeDeactivate", n"QuestForceRoadBlockadeDeactivate");
  }
}

public class QuestForceActivate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceActivate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceActivate", true, n"QuestForceActivate", n"QuestForceActivate");
  }
}

public class QuestForceDeactivate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceDeactivate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceDeactivate", true, n"QuestForceDeactivate", n"QuestForceDeactivate");
  }
}

public class QuestPickUpCall extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"PickUpCall";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestPickUpCall", true, n"QuestPickUpCall", n"QuestPickUpCall");
  }
}

public class QuestHangUpCall extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"HangUpCall";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestHangUpCall", true, n"QuestHangUpCall", n"QuestHangUpCall");
  }
}

public class ToggleActivate extends ActionBool {

  protected let m_TrueRecordName: String;

  protected let m_FalseRecordName: String;

  public final func SetProperties(activationStatus: EActivationState) -> Void {
    let isActivated: Bool;
    if Equals(activationStatus, EActivationState.DEACTIVATED) {
      isActivated = false;
    } else {
      isActivated = true;
    };
    this.actionName = n"ToggleActivate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleActivate", isActivated, n"LocKey#233", n"LocKey#234");
  }

  public final func SetProperties(isActive: Bool, nameOnTrue: TweakDBID, nameOnFalse: TweakDBID) -> Void {
    let displayNameOnFalse: CName;
    let displayNameOnTrue: CName;
    let record: wref<InteractionBase_Record>;
    this.actionName = n"ToggleActivate";
    if !TDBID.IsValid(nameOnTrue) {
      nameOnTrue = t"Interactions.Activate";
    };
    if !TDBID.IsValid(nameOnFalse) {
      nameOnFalse = t"Interactions.Deactivate";
    };
    record = TweakDBInterface.GetInteractionBaseRecord(nameOnTrue);
    this.m_FalseRecordName = record.Name();
    displayNameOnTrue = StringToName(LocKeyToString(record.Caption()));
    record = TweakDBInterface.GetInteractionBaseRecord(nameOnFalse);
    this.m_TrueRecordName = record.Name();
    displayNameOnFalse = StringToName(LocKeyToString(record.Caption()));
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleActivate", isActive, displayNameOnTrue, displayNameOnFalse);
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    if !FromVariant(this.prop.first) {
      return this.m_TrueRecordName;
    };
    return this.m_FalseRecordName;
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class ActivateDevice extends ActionBool {

  public let m_tweakDBChoiceName: String;

  public final func SetProperties(opt action_name: CName) -> Void {
    let displayName: CName;
    this.actionName = n"ActivateDevice";
    if IsNameValid(action_name) {
      displayName = action_name;
    } else {
      displayName = n"LocKey#233";
    };
    this.m_tweakDBChoiceName = NameToString(action_name);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ActivateDevice", true, displayName, displayName);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return this.m_tweakDBChoiceName;
  }
}

public class DeactivateDevice extends ActionBool {

  public final func SetProperties(opt action_name: CName) -> Void {
    if NotEquals(action_name, n"") {
      this.actionName = action_name;
    } else {
      this.actionName = n"LocKey#234";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"DeactivateDevice", true, this.actionName, this.actionName);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class AuthorizeUser extends ActionBool {

  private let m_enteredPassword: CName;

  private let m_validPasswords: array<CName>;

  private let m_libraryName: CName;

  public final func SetProperties(validPasswords: array<CName>) -> Void {
    this.actionName = n"AuthorizeUser";
    this.m_validPasswords = validPasswords;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#53646", n"LocKey#53646");
  }

  public final func GetEnteredPassword() -> CName {
    return this.m_enteredPassword;
  }

  public func ResolveAction(data: ref<ResolveActionData>) -> Bool {
    this.m_enteredPassword = StringToName(data.m_password);
    return true;
  }

  public final func GetValidPasswords() -> array<CName> {
    return this.m_validPasswords;
  }

  public final func CreateActionWidgetPackage(authorizationWidgetName: CName, authorizationDisplayNameOverride: String) -> Void {
    this.m_libraryName = authorizationWidgetName;
    this.CreateActionWidgetPackage();
    if NotEquals(authorizationDisplayNameOverride, "") {
      this.m_actionWidgetPackage.displayName = authorizationDisplayNameOverride;
    } else {
      this.m_actionWidgetPackage.displayName = "LocKey#210";
    };
  }

  public final func CreateActionWidgetPackage(authorizationDisplayNameOverride: String) -> Void {
    this.CreateActionWidgetPackage();
    if IsStringValid(authorizationDisplayNameOverride) {
      this.m_actionWidgetPackage.displayName = authorizationDisplayNameOverride;
    };
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    if Equals(this.m_libraryName, n"elevator") {
      return t"DevicesUIDefinitions.AuthorizationBlockedActionWidget";
    };
    return this.GetInkWidgetTweakDBID();
  }
}

public class FactQuickHack extends ActionBool {

  private let m_factProperties: ComputerQuickHackData;

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "DownloadCPOMissionData";
  }

  public func GetTweakDBChoiceID() -> TweakDBID {
    let id: TweakDBID = this.m_factProperties.alternativeName;
    return id;
  }

  public final func GetFactProperties() -> ComputerQuickHackData {
    return this.m_factProperties;
  }

  public final func SetProperties(properties: ComputerQuickHackData) -> Void {
    this.m_factProperties = properties;
  }
}

public class QuickHackAuthorization extends ActionBool {

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "QuickHackAuthorization";
  }
}

public class SetAuthorizationModuleON extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetAuthorizationModuleON";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#262", n"LocKey#262");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SetAuthorizationModuleON.IsAvailable(device) && SetAuthorizationModuleON.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.HasAuthorizationModule() && !device.IsAuthorizationModuleOn() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetControlPanelCompatibleClearance()) {
      return true;
    };
    return false;
  }
}

public class SetAuthorizationModuleOFF extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetAuthorizationModuleOFF";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#263", n"LocKey#263");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SetAuthorizationModuleOFF.IsAvailable(device) && SetAuthorizationModuleOFF.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.HasAuthorizationModule() && device.IsAuthorizationModuleOn() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetControlPanelCompatibleClearance()) {
      return true;
    };
    return false;
  }
}

public class InstallKeylogger extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"InstallKeylogger";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#376", n"LocKey#376");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if InstallKeylogger.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }
}

public class SetExposeQuickHacks extends ActionBool {

  @default(SetExposeQuickHacks, true)
  public let isRemote: Bool;

  public final func SetProperties() -> Void {
    this.actionName = n"SetExposeQuickHacks";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"SetExposeQuickHacks", n"SetExposeQuickHacks");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SetExposeQuickHacks";
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return device.IsPowered();
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Direct) {
      return true;
    };
    return false;
  }
}

public class TogglePersonalLink extends ActionBool {

  public let m_cachedStatus: EPersonalLinkConnectionStatus;

  public let m_shouldSkipMiniGame: Bool;

  public final func SetProperties(personalLinkStatus: EPersonalLinkConnectionStatus, shouldSkipMinigame: Bool) -> Void {
    let isPersonalLinkConnected: Bool;
    this.m_cachedStatus = personalLinkStatus;
    this.m_shouldSkipMiniGame = shouldSkipMinigame;
    if Equals(this.m_cachedStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) {
      isPersonalLinkConnected = false;
    } else {
      isPersonalLinkConnected = true;
    };
    this.actionName = n"TogglePersonalLink";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Personal Link", isPersonalLinkConnected, n"LocKey#284", n"LocKey#285");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if TogglePersonalLink.IsAvailable(device) && TogglePersonalLink.IsClearanceValid(context.clearance) && TogglePersonalLink.IsContextValid(context) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return device.IsON() && device.HasPersonalLinkSlot();
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Direct) {
      return true;
    };
    return false;
  }

  public final func ShouldConnect() -> Bool {
    let value: Bool;
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, value);
    return value;
  }

  public func GetTweakDBChoiceRecord() -> String {
    let value: Bool;
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, value);
    if Equals(this.m_cachedStatus, EPersonalLinkConnectionStatus.NOT_CONNECTED) {
      if this.m_shouldSkipMiniGame {
        return "ConnectPersonalLinkNoMinigame";
      };
      return "ConnectPersonalLink";
    };
    return "DisconnectPersonalLink";
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.JackInIcon");
  }
}

public class OpenFullscreenUI extends ActionBool {

  public final func SetProperties(isZoomInteraction: Bool) -> Void {
    this.actionName = n"OpenFullscreenUI";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Zoom Interaction", isZoomInteraction, n"LocKey#288", n"LocKey#289");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return OpenFullscreenUI.IsAvailable(device) && OpenFullscreenUI.IsClearanceValid(context.clearance) && OpenFullscreenUI.IsContextValid(context);
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return device.IsPowered();
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance());
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return Equals(context.requestType, gamedeviceRequestType.Direct);
  }

  public final func ShouldConnect() -> Bool {
    let value: Bool;
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, value);
    return !value;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "OpenFullscreenUI";
  }
}

public class SpiderbotDistraction extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotDistraction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#596", n"LocKey#596");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SpiderbotDistraction";
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if !AIActionHelper.CheckFlatheadStatPoolRequirements(device.GetGameInstance(), "DeviceAction") {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return true;
    };
    return false;
  }
}

public class SpiderbotBoolAction extends ActionBool {

  @default(SpiderbotBoolAction, SpiderbotToggleOn)
  protected let m_TrueRecord: String;

  @default(SpiderbotBoolAction, SpiderbotToggleOff)
  protected let m_FalseRecord: String;

  public final func SetProperties(status: EDeviceStatus) -> Void {
    let isOn: Bool;
    this.actionName = n"SpiderbotToggleON";
    if Equals(status, EDeviceStatus.ON) {
      isOn = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isOn, n"LocKey#255", n"LocKey#256");
  }

  public final func SetProperties(status: EDeviceStatus, nameOnTrue: CName, nameOnFalse: CName) -> Void {
    let isOn: Bool;
    this.actionName = n"SpiderbotToggleON";
    if Equals(status, EDeviceStatus.ON) {
      isOn = true;
    };
    if !IsNameValid(nameOnTrue) {
      nameOnTrue = n"LocKey#255";
    } else {
      this.m_TrueRecord = NameToString(nameOnTrue);
    };
    if !IsNameValid(nameOnFalse) {
      nameOnFalse = n"LocKey#256";
    } else {
      this.m_FalseRecord = NameToString(nameOnFalse);
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isOn, nameOnTrue, nameOnFalse);
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return this.m_TrueRecord;
    };
    return this.m_FalseRecord;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if !AIActionHelper.CheckFlatheadStatPoolRequirements(device.GetGameInstance(), "DeviceAction") {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return true;
    };
    return false;
  }
}

public class ToggleZoomInteraction extends ActionBool {

  public final func SetProperties(isZoomInteraction: Bool) -> Void {
    this.actionName = n"ToggleZoomInteraction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Zoom Interaction", isZoomInteraction, n"LocKey#288", n"LocKey#289");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return ToggleZoomInteraction.IsAvailable(device) && ToggleZoomInteraction.IsClearanceValid(context.clearance) && ToggleZoomInteraction.IsContextValid(context);
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return device.IsPowered();
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance());
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return Equals(context.requestType, gamedeviceRequestType.Direct);
  }

  public final func ShouldConnect() -> Bool {
    let value: Bool;
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, value);
    return !value;
  }

  public func GetTweakDBChoiceRecord() -> String {
    let value: Bool;
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, value);
    if !value {
      return "EnterZoomInteraction";
    };
    return "ExitZoomInteraction";
  }
}

public class SetDeviceAttitude extends ActionBool {

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties() -> Void {
    this.actionName = n"SetDeviceAttitude";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#362", n"LocKey#362");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "SetDeviceAttitude";
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.ChangeToFriendlyIcon");
  }
}

public class ThumbnailUI extends ActionBool {

  protected let m_thumbnailWidgetPackage: SThumbnailWidgetPackage;

  public final func SetProperties() -> Void {
    this.actionName = n"ThumbnailUI";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ThumbnailUI", true, n"ThumbnailUI", n"ThumbnailUI");
  }

  public func CreateThumbnailWidgetPackage(opt status: String) -> Void {
    this.m_thumbnailWidgetPackage.libraryPath = this.GetInkWidgetLibraryPath();
    this.m_thumbnailWidgetPackage.libraryID = this.GetInkWidgetLibraryID();
    this.m_thumbnailWidgetPackage.widgetName = ToString(this.GetActionName());
    this.m_thumbnailWidgetPackage.displayName = this.GetDeviceName();
    this.m_thumbnailWidgetPackage.deviceStatus = status;
    this.m_thumbnailWidgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
    this.ResolveThumbnailWidgetTweakDBData();
  }

  public func CreateThumbnailWidgetPackage(widgetTweakDBID: TweakDBID, opt status: String) -> Void {
    this.CreateThumbnailWidgetPackage(status);
    if TDBID.IsValid(widgetTweakDBID) {
      this.m_thumbnailWidgetPackage.widgetTweakDBID = widgetTweakDBID;
      this.ResolveThumbnailWidgetTweakDBData();
    };
  }

  public func GetInkWidgetLibraryPath() -> ResRef {
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  public func GetInkWidgetLibraryID() -> CName {
    return n"";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.GenericDeviceThumnbnailWidget";
  }

  public final func GetThumbnailWidgetPackage() -> SThumbnailWidgetPackage {
    let widgetPackage: SThumbnailWidgetPackage;
    widgetPackage.thumbnailAction = this;
    if !TDBID.IsValid(this.m_thumbnailWidgetPackage.widgetTweakDBID) {
      widgetPackage.widgetTweakDBID = this.GetInkWidgetTweakDBID();
      this.ResolveThumbnailWidgetTweakDBData();
    } else {
      widgetPackage.widgetTweakDBID = this.m_thumbnailWidgetPackage.widgetTweakDBID;
    };
    widgetPackage.libraryID = this.m_thumbnailWidgetPackage.libraryID;
    widgetPackage.widgetName = this.m_thumbnailWidgetPackage.widgetName;
    widgetPackage.displayName = this.m_thumbnailWidgetPackage.displayName;
    widgetPackage.deviceStatus = this.m_thumbnailWidgetPackage.deviceStatus;
    widgetPackage.widgetTweakDBID = this.m_thumbnailWidgetPackage.widgetTweakDBID;
    widgetPackage.libraryPath = this.m_thumbnailWidgetPackage.libraryPath;
    widgetPackage.isValid = ResRef.IsValid(widgetPackage.libraryPath) || IsNameValid(widgetPackage.libraryID);
    return widgetPackage;
  }

  private final func ResolveThumbnailWidgetTweakDBData() -> Void {
    let record: ref<WidgetDefinition_Record>;
    if TDBID.IsValid(this.m_thumbnailWidgetPackage.widgetTweakDBID) {
      record = TweakDBInterface.GetWidgetDefinitionRecord(this.m_thumbnailWidgetPackage.widgetTweakDBID);
      if record != null {
        this.m_thumbnailWidgetPackage.libraryPath = record.LibraryPath();
        this.m_thumbnailWidgetPackage.libraryID = StringToName(record.LibraryID());
      };
    };
  }
}

public class QuestResetDeviceToInitialState extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestResetDeviceToInitialState";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"QuestResetDeviceToInitialState", n"QuestResetDeviceToInitialState");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "QuestResetDeviceToInitialState";
  }
}

public class QuestForceCameraZoom extends ActionBool {

  @default(QuestForceCameraZoom, true)
  private let m_useWorkspot: Bool;

  public final func SetProperties(value: Bool) -> Void {
    if value {
      this.actionName = n"QuestForceEnableCameraZoom";
    } else {
      this.actionName = n"QuestForceDisableCameraZoom";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, value, n"QuestForceEnableCameraZoom", n"QuestForceDisableCameraZoom");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "QuestForceCameraZoom";
  }

  public final const func UseWorkspot() -> Bool {
    return this.m_useWorkspot;
  }

  public final func SetUseWorkspot(useWorkspot: Bool) -> Void {
    this.m_useWorkspot = useWorkspot;
  }
}

public class PlayDeafeningMusic extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"HackVolume";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if PlayDeafeningMusic.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() || device.IsOFF() {
      return true;
    };
    return false;
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.DistractIcon");
  }
}

public class ChangeMusicAction extends ActionBool {

  @default(ChangeMusicAction, NextStation)
  protected let m_interactionRecordName: String;

  public let m_settings: ref<MusicSettings>;

  public final func SetProperties(settings: ref<MusicSettings>) -> Void {
    this.actionName = n"NextStation";
    this.m_settings = settings;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Next Station", true, n"LocKey#252", n"LocKey#252");
  }

  public final func SetProperties(settings: ref<MusicSettings>, nameOnTrue: TweakDBID) -> Void {
    let displayName: CName;
    let record: wref<InteractionBase_Record>;
    this.m_settings = settings;
    if !TDBID.IsValid(nameOnTrue) {
      displayName = n"LocKey#252";
      this.actionName = n"NextStation";
    } else {
      record = TweakDBInterface.GetInteractionBaseRecord(nameOnTrue);
      this.m_interactionRecordName = record.Name();
      this.actionName = StringToName(this.m_interactionRecordName);
      displayName = StringToName(LocKeyToString(record.Caption()));
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, displayName, displayName);
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return this.m_interactionRecordName;
  }

  public final func GetMusicSettings() -> ref<MusicSettings> {
    return this.m_settings;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if !AIActionHelper.CheckFlatheadStatPoolRequirements(device.GetGameInstance(), "DeviceAction") {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return true;
    };
    return false;
  }
}

public class StartCall extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"StartCall";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"StartCall", true, n"LocKey#279", n"LocKey#279");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Call";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.IntercomCallActionWidget";
  }
}

public class Flush extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"Flush";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Flush", true, n"LocKey#50672", n"LocKey#50672");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Flush";
  }
}

public class ToggleGlassTint extends ActionBool {

  @default(ToggleGlassTint, TintGlass)
  protected let m_TrueRecord: String;

  @default(ToggleGlassTint, ClearGlass)
  protected let m_FalseRecord: String;

  public final func SetProperties(isActive: Bool) -> Void {
    let record: TweakDBID = TDBID.Create("Interactions." + this.m_TrueRecord);
    let nameOnTrue: CName = StringToName(TweakDBInterface.GetInteractionBaseRecord(record).Name());
    record = TDBID.Create("Interactions." + this.m_FalseRecord);
    let nameOnFalse: CName = StringToName(TweakDBInterface.GetInteractionBaseRecord(record).Name());
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isActive, nameOnTrue, nameOnFalse);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ToggleGlassTint.IsAvailable(device) && ToggleGlassTint.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    if !FromVariant(this.prop.first) {
      return this.m_TrueRecord;
    };
    return this.m_FalseRecord;
  }
}

public class QuestForceTintGlass extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceTintGlass";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"QuestForceTintGlass", n"QuestForceTintGlass");
  }
}

public class QuestForceClearGlass extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceClearGlass";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"QuestForceClearGlass", n"QuestForceClearGlass");
  }
}

public class PresetAction extends ActionBool {

  protected let m_preset: ref<SmartHousePreset>;

  public final func SetProperties(preset: ref<SmartHousePreset>) -> Void {
    this.actionName = preset.GetClassName();
    this.m_preset = preset;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"SmartHousePreset", true, this.GetDisplayName(), this.GetDisplayName());
  }

  public final func GetPreset() -> ref<SmartHousePreset> {
    return this.m_preset;
  }

  protected final func GetDisplayName() -> CName {
    return this.m_preset.GetPresetName();
  }

  public func CreateActionWidgetPackage(opt actions: array<ref<DeviceAction>>) -> Void {
    this.CreateActionWidgetPackage(actions);
    this.m_actionWidgetPackage.iconID = this.m_preset.GetIconName();
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if PresetAction.IsAvailable(device) && PresetAction.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if !device.IsON() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetQuestClearance()) {
      return true;
    };
    return false;
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.SmartHousePresetWidget";
  }
}

public class ToggleAlarm extends ActionBool {

  public final func SetProperties(status: ESecuritySystemState) -> Void {
    let isOn: Bool;
    this.actionName = n"ToggleAlarm";
    if NotEquals(status, ESecuritySystemState.SAFE) {
      isOn = true;
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleAlarm", isOn, n"LocKey#346", n"LocKey#345");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ToggleAlarm.IsAvailable(device) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    if !FromVariant(this.prop.first) {
      return "TurnOnCarAlarm";
    };
    return "TurnOffCarAlarm";
  }
}

public class SecurityAlarmBreachResponse extends ActionBool {

  private let m_currentSecurityState: ESecuritySystemState;

  public final func SetProperties(currentSecuritySystemState: ESecuritySystemState) -> Void {
    this.actionName = n"SecurityAlarmBreachResponse";
    this.m_currentSecurityState = currentSecuritySystemState;
  }

  public final const func GetSecurityState() -> ESecuritySystemState {
    return this.m_currentSecurityState;
  }
}

public class SecurityAlarmEscalate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"StartAlarm";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"StartAlarm", true, n"LocKey#340", n"LocKey#344");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "StartAlarm";
  }
}

public class MasterDeviceDestroyed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"MasterDeviceDestroyed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"MasterDeviceDestroyed", true, n"MasterDeviceDestroyed", n"MasterDeviceDestroyed");
  }
}

public class DelayEvent extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"DelayEvent";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"DelayEvent", true, n"DelayEvent", n"DelayEvent");
  }
}

public class Distraction extends ActionBool {

  public final func SetProperties(action_name: CName) -> Void {
    this.actionName = n"Distraction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(action_name, true, action_name, action_name);
  }

  public final func SetProperties() -> Void {
    this.actionName = n"Distraction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"LocKey#336", true, n"LocKey#336", n"LocKey#336");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if device.IsPowered() {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Distract";
  }
}

public class TogglePlay extends ActionBool {

  public final func SetProperties(isPlaying: Bool) -> Void {
    this.actionName = n"TogglePlay";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Play", isPlaying, n"LocKey#280", n"LocKey#281");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if TogglePlay.IsAvailable(device) && TogglePlay.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsUnpowered() {
      return false;
    };
    if device.IsDeviceSecured() {
      return false;
    };
    if !device.IsON() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.JukeboxPlayActionWidget";
  }
}

public class OpenInteriorManager extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"OpenInteriorManager";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"OpenInteriorManager", true, n"LocKey#27969", n"LocKey#27969");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "InteriorManager";
  }
}

public class EnterLadder extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"EnterLadder";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"EnterLadder", true, n"EnterLadder", n"EnterLadder");
  }

  public final static func IsPlayerInAcceptableState(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    let playerSMBlackboard: ref<IBlackboard> = EnterLadder.GetPlayerStateMachine(context.processInitiatorObject);
    let isUsingLadder: Bool = playerSMBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed) == EnumInt(gamePSMDetailedLocomotionStates.Ladder) || playerSMBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed) == EnumInt(gamePSMDetailedLocomotionStates.LadderSprint) || playerSMBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed) == EnumInt(gamePSMDetailedLocomotionStates.LadderSlide) || playerSMBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed) == EnumInt(gamePSMDetailedLocomotionStates.LadderJump);
    if isUsingLadder {
      return false;
    };
    if playerSMBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) != EnumInt(gamePSMHighLevel.SceneTier1) {
      return false;
    };
    if playerSMBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying) {
      return false;
    };
    if playerSMBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) != EnumInt(gamePSMTakedown.Default) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(context.processInitiatorObject, n"NoWorldInteractions") {
      return false;
    };
    return true;
  }

  public final static func PushOnEnterLadderEventToPSM(requester: ref<GameObject>) -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"actionEnterLadder";
    psmEvent.value = true;
    requester.QueueEvent(psmEvent);
  }

  public final static func GetPlayerStateMachine(requester: ref<GameObject>) -> ref<IBlackboard> {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(requester.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(requester.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return playerStateMachineBlackboard;
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "EnterLadder";
  }
}

public class ProgramSetDeviceOff extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ProgramSetDeviceOff";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ProgramSetDeviceOff", true, n"LocKey#256", n"LocKey#256");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class ProgramSetDeviceAttitude extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ProgramSetDeviceAttitude";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ProgramSetDeviceAttitude", true, n"LocKey#362", n"LocKey#362");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class QuestResetPerformedActionsStorage extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestResetPerformedActionsStorage";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestResetPerformedActionsStorage", true, n"QuestResetPerformedActionsStorage", n"QuestResetPerformedActionsStorage");
  }
}
