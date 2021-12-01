
public class AIActionHelper extends IScriptable {

  public final static func ActionDebugHelper(entity: wref<Entity>, actionName: String) -> Bool {
    let actionNameCheck: String = (entity as GameObject).GetTracedActionName();
    if IsDefined(entity) || IsStringValid(actionNameCheck) && IsStringValid(actionName) {
      if IsStringValid(actionNameCheck) {
        if StrContains(actionName, actionNameCheck) {
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

  public final static func ActionDebugHelper(actionNameCheck: String, entity: wref<Entity>, actionName: String) -> Bool {
    if IsDefined(entity) || IsStringValid(actionNameCheck) && IsStringValid(actionName) {
      if IsStringValid(actionNameCheck) {
        if StrContains(actionName, actionNameCheck) {
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

  public final static func ActionDebugHelper(actionNameCheck: String, actionName: String) -> Bool {
    if IsStringValid(actionNameCheck) && IsStringValid(actionName) {
      if StrContains(actionName, actionNameCheck) {
        return true;
      };
      return false;
    };
    return false;
  }

  public final static func SetActionExclusivity(owner: ref<GameObject>, active: Bool) -> Void {
    let puppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    puppet.GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.InExclusiveAction, active);
  }

  public final static func HasLostTarget(owner: ref<ScriptedPuppet>, target: ref<GameObject>) -> Bool {
    let targetTrackerComponent: ref<TargetTrackerComponent>;
    let threat: TrackedLocation;
    if IsDefined(owner) && IsDefined(target) && target != owner {
      targetTrackerComponent = owner.GetTargetTrackerComponent();
      if IsDefined(targetTrackerComponent) && target.IsPuppet() {
        return !targetTrackerComponent.ThreatFromEntity(target, threat);
      };
    };
    return false;
  }

  public final static func HasCombatAICommand(owner: wref<ScriptedPuppet>) -> Bool {
    let aiComponent: ref<AIHumanComponent> = owner.GetAIControllerComponent();
    if !IsDefined(aiComponent) {
      return false;
    };
    return aiComponent.IsCommandActive(n"AICombatRelatedCommand");
  }

  public final static func HasWorkspotAICommand(owner: wref<ScriptedPuppet>) -> Bool {
    let aiComponent: ref<AIHumanComponent> = owner.GetAIControllerComponent();
    if !IsDefined(aiComponent) {
      return false;
    };
    return aiComponent.IsCommandActive(n"AIUseWorkspotCommand");
  }

  public final static func HasFollowerCombatAICommand(owner: wref<ScriptedPuppet>) -> Bool {
    let aiComponent: ref<AIHumanComponent> = owner.GetAIControllerComponent();
    if !IsDefined(aiComponent) {
      return false;
    };
    return aiComponent.IsCommandActive(n"AIFollowerCombatCommand");
  }

  public final static func GetActionBlackboard(owner: ref<ScriptedPuppet>) -> ref<IBlackboard> {
    return owner.GetAIControllerComponent().GetActionBlackboard();
  }

  public final static func GetShootingBlackboard(owner: ref<ScriptedPuppet>) -> ref<IBlackboard> {
    return owner.GetAIControllerComponent().GetShootingBlackboard();
  }

  public final static func ShouldShootDirectlyAtTarget(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, targetPosition: Vector4) -> Bool {
    let absAngleToCombatTarget: Float;
    let coneAngle: Float;
    let vecToTarget: Vector4;
    if weapon.IsTargetLocked() {
      return true;
    };
    if Vector4.IsZero(targetPosition) || !weaponOwner.GetTargetTrackerComponent().IsPositionValid(targetPosition) {
      return false;
    };
    vecToTarget = targetPosition - weapon.GetWorldPosition();
    coneAngle = 15.00;
    if Vector4.Length(vecToTarget) > 10.00 {
      coneAngle = 30.00;
    };
    absAngleToCombatTarget = AbsF(Vector4.GetAngleDegAroundAxis(vecToTarget, weapon.GetWorldForward(), weaponOwner.GetWorldUp()));
    if absAngleToCombatTarget >= 0.00 && coneAngle > 0.00 && absAngleToCombatTarget <= coneAngle * 0.50 {
      return true;
    };
    return false;
  }

  public final static func GetTargetSlotPosition(target: wref<GameObject>, slotName: CName, out slotPosition: Vector4) -> Bool {
    let slotTransform: WorldTransform;
    Vector4.Zero(slotPosition);
    if !IsNameValid(slotName) {
      slotName = n"Head";
    };
    if AIActionHelper.GetTargetSlotTransform(target, slotName, slotTransform) {
      slotPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
      return true;
    };
    return false;
  }

  public final static func GetTargetPositionFromPast(target: wref<GameObject>, delay: Float, out position: Vector4) -> Bool {
    let targetSP: wref<ScriptedPuppet> = target as ScriptedPuppet;
    if IsDefined(targetSP) && IsDefined(targetSP.GetTransformHistoryComponent()) {
      position = targetSP.GetTransformHistoryComponent().GetInterpolatedPositionFromHistory(delay);
      return true;
    };
    return false;
  }

  public final static func GetTargetSlotTransform(target: wref<GameObject>, slotName: CName, out slotTransform: WorldTransform) -> Bool {
    let hitRepresentationSlotComponent: ref<SlotComponent>;
    let slotComponent: ref<SlotComponent>;
    let targetMuppet: ref<Muppet>;
    let targetPuppet: ref<ScriptedPuppet> = target as ScriptedPuppet;
    if IsDefined(targetPuppet) {
      hitRepresentationSlotComponent = targetPuppet.GetHitRepresantationSlotComponent();
      slotComponent = targetPuppet.GetSlotComponent();
    } else {
      targetMuppet = target as Muppet;
      if IsDefined(targetMuppet) {
        hitRepresentationSlotComponent = targetMuppet.GetHitRepresantationSlotComponent();
        slotComponent = targetMuppet.GetSlotComponent();
      };
    };
    if IsDefined(hitRepresentationSlotComponent) && hitRepresentationSlotComponent.GetSlotTransform(slotName, slotTransform) {
      return true;
    };
    if IsDefined(slotComponent) && slotComponent.GetSlotTransform(slotName, slotTransform) {
      return true;
    };
    return false;
  }

  public final static func AnimationsLoadedSignal(ownerPuppet: wref<ScriptedPuppet>) -> Void {
    let signalId: Uint16 = ownerPuppet.GetSignalTable().GetOrCreateSignal(n"AnimationsLoaded");
    ownerPuppet.GetSignalTable().Set(signalId, false);
    ownerPuppet.GetSignalTable().Set(signalId, true);
  }

  public final static func CombatQueriesInit(ownerPuppet: wref<ScriptedPuppet>) -> Void {
    let signalTable: ref<gameBoolSignalTable> = ownerPuppet.GetSignalTable();
    let signalId: Uint16 = signalTable.GetOrCreateSignal(n"CombatQueriesRequest");
    signalTable.Set(signalId, false);
    signalTable.Set(signalId, true);
  }

  public final static func TryChangingAttitudeToHostile(owner: ref<ScriptedPuppet>, target: ref<GameObject>) -> Bool {
    let currentAttitude: EAIAttitude;
    let attitudeOwner: ref<AttitudeAgent> = owner.GetAttitudeAgent();
    let attitudeTarget: ref<AttitudeAgent> = target.GetAttitudeAgent();
    if !target.IsPuppet() && !target.IsSensor() {
      return false;
    };
    if !target.IsActive() {
      return false;
    };
    if IsDefined(attitudeOwner) && IsDefined(attitudeTarget) {
      currentAttitude = attitudeOwner.GetAttitudeTowards(attitudeTarget);
      switch currentAttitude {
        case EAIAttitude.AIA_Friendly:
          return false;
        case EAIAttitude.AIA_Hostile:
          return true;
        default:
          if owner.IsAggressive() {
            attitudeOwner.SetAttitudeTowardsAgentGroup(attitudeTarget, attitudeOwner, EAIAttitude.AIA_Hostile);
            return true;
          };
      };
      return false;
    };
    return false;
  }

  public final static func SetCommandCombatTarget(context: ScriptExecutionContext, target: wref<GameObject>, persistenceSource: Uint32) -> Bool {
    if !IsDefined(target) || ScriptExecutionContext.GetOwner(context) == target {
      return false;
    };
    if target.IsPuppet() {
      if !ScriptedPuppet.IsActive(target) {
        return false;
      };
      GameObject.ChangeAttitudeToHostile(ScriptExecutionContext.GetOwner(context), target);
      TargetTrackingExtension.InjectThreat(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, target);
      TargetTrackingExtension.SetThreatPersistence(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, target, true, persistenceSource);
    };
    ScriptExecutionContext.SetArgumentObject(context, n"CommandCombatTarget", target);
    return true;
  }

  public final static func ClearCommandCombatTarget(context: ScriptExecutionContext, persistenceSource: Uint32) -> Void {
    TargetTrackingExtension.SetThreatPersistence(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, ScriptExecutionContext.GetArgumentObject(context, n"CommandCombatTarget"), false, persistenceSource);
    ScriptExecutionContext.SetArgumentObject(context, n"CommandCombatTarget", null);
  }

  public final static func IsCommandCombatTargetValid(context: ScriptExecutionContext, commandName: CName) -> Bool {
    let target: wref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"CommandCombatTarget");
    if !ScriptedPuppet.IsActive(ScriptExecutionContext.GetOwner(context)) {
      ScriptExecutionContext.DebugLog(context, commandName, "Canceling command, owner is Dead, Defeated or Unconscious");
      return false;
    };
    if !IsDefined(target) {
      ScriptExecutionContext.DebugLog(context, commandName, "Canceling command, Target no longer exists");
      return false;
    };
    if target.IsPuppet() {
      if !ScriptedPuppet.IsActive(target) {
        ScriptExecutionContext.DebugLog(context, commandName, "Canceling command, Target no longer active");
        return false;
      };
      if Equals(GameObject.GetAttitudeBetween(ScriptExecutionContext.GetOwner(context), target), EAIAttitude.AIA_Friendly) {
        ScriptExecutionContext.DebugLog(context, commandName, "Canceling command, Target is Friendly");
        return false;
      };
      if AIActionHelper.HasLostTarget(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, target) {
        ScriptExecutionContext.DebugLog(context, commandName, "Canceling command, lost track of target");
        return false;
      };
    };
    return true;
  }

  public final static func TargetAllSquadMembers(owner: wref<GameObject>) -> Void {
    let attitudeTarget: ref<AttitudeAgent>;
    let i: Int32;
    let squadMembers: array<wref<Entity>>;
    let target: wref<GameObject>;
    let targetTrackerComponent: ref<TargetTrackerComponent>;
    let attitudeOwner: ref<AttitudeAgent> = owner.GetAttitudeAgent();
    attitudeOwner.SetAttitudeGroup(n"HostileToEveryone");
    targetTrackerComponent = owner.GetTargetTrackerComponent();
    if !AISquadHelper.GetSquadmates(owner as ScriptedPuppet, squadMembers) {
      return;
    };
    i = 0;
    while i < ArraySize(squadMembers) {
      target = squadMembers[i] as GameObject;
      if !IsDefined(target) || target == owner || !ScriptedPuppet.IsActive(target) {
      } else {
        attitudeTarget = target.GetAttitudeAgent();
        attitudeOwner.SetAttitudeTowards(attitudeTarget, EAIAttitude.AIA_Hostile);
        if IsDefined(targetTrackerComponent) {
          targetTrackerComponent.AddThreat(target, true, target.GetWorldPosition(), 1.00, -1.00, false);
        };
      };
      i += 1;
    };
    return;
  }

  public final static func SetFriendlyTargetAllSquadMembers(owner: wref<GameObject>) -> Void {
    let attitudeTarget: ref<AttitudeAgent>;
    let i: Int32;
    let squadMembers: array<wref<Entity>>;
    let target: wref<GameObject>;
    let targetTrackerComponent: ref<TargetTrackerComponent>;
    let attitudeOwner: ref<AttitudeAgent> = owner.GetAttitudeAgent();
    if !AISquadHelper.GetSquadmates(owner as ScriptedPuppet, squadMembers) {
      return;
    };
    targetTrackerComponent = owner.GetTargetTrackerComponent();
    if IsDefined(targetTrackerComponent) {
      targetTrackerComponent.ClearThreats();
    };
    i = 0;
    while i < ArraySize(squadMembers) {
      target = squadMembers[i] as GameObject;
      if !IsDefined(target) || target == owner || !ScriptedPuppet.IsActive(target) {
      } else {
        attitudeTarget = target.GetAttitudeAgent();
        attitudeOwner.SetAttitudeTowards(attitudeTarget, EAIAttitude.AIA_Hostile);
        if IsDefined(targetTrackerComponent) {
          targetTrackerComponent.AddThreat(target, true, target.GetWorldPosition(), 1.00, -1.00, false);
        };
      };
      i += 1;
    };
    return;
  }

  public final static func ChangeAttitudeToFriendlyAllSquad(owner: wref<GameObject>, squadMembers: array<EntityID>) -> Void {
    let attitudeTarget: ref<AttitudeAgent>;
    let target: wref<GameObject>;
    let attitudeOwner: ref<AttitudeAgent> = owner.GetAttitudeAgent();
    let i: Int32 = 0;
    while i < ArraySize(squadMembers) {
      target = GameInstance.FindEntityByID(owner.GetGame(), squadMembers[i]) as GameObject;
      if !IsDefined(target) || target == owner {
      } else {
        attitudeTarget = target.GetAttitudeAgent();
        attitudeOwner.SetAttitudeTowards(attitudeTarget, EAIAttitude.AIA_Friendly);
      };
      i += 1;
    };
    return;
  }

  public final static func GetActiveTopHostilePuppetThreat(puppet: ref<ScriptedPuppet>, out threat: TrackedLocation) -> Bool {
    let allThreats: array<TrackedLocation>;
    let currentTopThreat: TrackedLocation;
    let i: Int32;
    let newTargetPuppet: ref<ScriptedPuppet>;
    let targetTrackerComponent: ref<TargetTrackerComponent> = puppet.GetTargetTrackerComponent();
    if targetTrackerComponent.GetTopHostileThreat(false, currentTopThreat) {
      threat = currentTopThreat;
      newTargetPuppet = currentTopThreat.entity as ScriptedPuppet;
      if IsDefined(newTargetPuppet) {
        if ScriptedPuppet.IsActive(newTargetPuppet) {
          return true;
        };
        allThreats = targetTrackerComponent.GetHostileThreats(false);
        i = ArraySize(allThreats) - 1;
        while i >= 0 {
          newTargetPuppet = allThreats[i].entity as ScriptedPuppet;
          if ScriptedPuppet.IsActive(newTargetPuppet) {
            threat = allThreats[i];
            return true;
          };
          i -= 1;
        };
      };
    };
    return false;
  }

  public final static func GetAnimWrapperNameBasedOnItemID(itemID: ItemID) -> CName {
    let animWrapperName: CName = TDB.GetCName(ItemID.GetTDBID(itemID) + t".NPCAnimWrapperWeightOverride");
    if !IsNameValid(animWrapperName) {
      animWrapperName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ItemType().Name();
    };
    return animWrapperName;
  }

  public final static func GetAnimWrapperNameBasedOnItemTag(itemID: ItemID) -> CName {
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    if itemRecord.TagsContains(WeaponObject.GetMeleeWeaponTag()) {
      return n"MeleeWeapon";
    };
    if itemRecord.TagsContains(WeaponObject.GetRangedWeaponTag()) {
      return n"RangedWeapon";
    };
    return n"";
  }

  public final static func SendItemHandling(owner: wref<GameObject>, itemRecord: wref<Item_Record>, animFeatureName: CName, equipped: Bool) -> Void {
    let itemHandling: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    itemHandling.itemState = equipped ? 2 : 0;
    itemHandling.itemType = itemRecord.ItemType().AnimFeatureIndex();
    AnimationControllerComponent.ApplyFeatureToReplicate(owner, animFeatureName, itemHandling);
  }

  public final static func GetReactionPresetGroup(puppet: wref<ScriptedPuppet>) -> String {
    let reactionComponent: ref<ReactionManagerComponent>;
    let reactionGroup: String;
    if IsDefined(puppet) {
      reactionComponent = puppet.GetStimReactionComponent();
      if IsDefined(reactionComponent) {
        reactionGroup = reactionComponent.GetReactionPreset().ReactionGroup();
      };
    };
    return reactionGroup;
  }

  public final static func PlayWeaponEffect(weapon: ref<WeaponObject>, effectName: CName) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = effectName;
    weapon.QueueEventToChildItems(spawnEffectEvent);
  }

  public final static func BreakWeaponEffectLoop(weapon: ref<WeaponObject>, effectName: CName) -> Void {
    let evt: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
    evt.effectName = effectName;
    weapon.QueueEventToChildItems(evt);
  }

  public final static func KillWeaponEffect(weapon: ref<WeaponObject>, effectName: CName) -> Void {
    let evt: ref<entKillEffectEvent> = new entKillEffectEvent();
    evt.effectName = effectName;
    weapon.QueueEventToChildItems(evt);
  }

  public final static func CheckFlatheadStatPoolRequirements(game: GameInstance, actionName: String) -> Bool {
    let currentStatPoolValue: Float;
    let statPoolType: gamedataStatPoolType;
    let actionID: TweakDBID = TDBID.Create("SpiderbotArchetype." + actionName);
    let statPoolsAffected: array<CName> = AITweakParams.GetCNameArrayFromTweak(actionID, "statPoolsAffected");
    let statPoolsValueChanges: array<Float> = AITweakParams.GetFloatArrayFromTweak(actionID, "statPoolsValueChanges");
    let flathead: wref<GameObject> = (GameInstance.GetScriptableSystemsContainer(game).Get(n"SubCharacterSystem") as SubCharacterSystem).GetFlathead();
    let i: Int32 = 0;
    while i < ArraySize(statPoolsAffected) {
      statPoolType = IntEnum(Cast(EnumValueFromName(n"gamedataStatPoolType", statPoolsAffected[i])));
      currentStatPoolValue = GameInstance.GetStatPoolsSystem(game).GetStatPoolValue(Cast(flathead.GetEntityID()), statPoolType, false);
      if currentStatPoolValue + statPoolsValueChanges[i] < 0.00 {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func IsCurrentlyCrouching(puppet: ref<ScriptedPuppet>) -> Bool {
    if Equals(puppet.GetStanceStateFromBlackboard(), gamedataNPCStanceState.Crouch) {
      return true;
    };
    if !AICoverHelper.IsCurrentlyInCover(puppet) {
      return false;
    };
    if Equals(AICoverHelper.GetCurrentCoverStance(puppet), n"High") {
      return false;
    };
    if AICoverHelper.GetCoverNPCCurrentlyExposed(puppet) && AICoverHelper.IsStandingExposureMethod(AICoverHelper.GetCoverExposureMethod(puppet)) {
      return false;
    };
    return true;
  }

  public final static func IsCurrentlyExposedInCover(puppet: ref<ScriptedPuppet>) -> Bool {
    if !AICoverHelper.IsCurrentlyInCover(puppet) {
      return false;
    };
    if AICoverHelper.GetCoverNPCCurrentlyExposed(puppet) && AICoverHelper.IsUnsafeExposureMethod(AICoverHelper.GetCoverExposureMethod(puppet)) {
      return true;
    };
    return false;
  }

  public final static func IsCurrentlyInCoverAttackAction(puppet: ref<ScriptedPuppet>) -> Bool {
    if !AICoverHelper.IsCurrentlyInCover(puppet) {
      return false;
    };
    if AICoverHelper.GetCoverNPCCurrentlyExposed(puppet) {
      return true;
    };
    return false;
  }

  public final static func GetItemsFromWeaponSlots(owner: wref<GameObject>, out items: array<wref<ItemObject>>) -> Bool {
    let item: wref<ItemObject> = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponRight");
    if IsDefined(item) {
      ArrayPush(items, item);
    };
    item = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponLeft");
    if IsDefined(item) {
      ArrayPush(items, item);
    };
    return ArraySize(items) > 0;
  }

  public final static func HasEquippedWeaponWithTag(owner: wref<GameObject>, tag: CName) -> Bool {
    let i: Int32;
    let items: array<ref<ItemObject>>;
    let item: ref<ItemObject> = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponRight");
    if IsDefined(item) {
      ArrayPush(items, item);
    };
    item = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponLeft");
    if IsDefined(item) {
      ArrayPush(items, item);
    };
    i = 0;
    while i < ArraySize(items) {
      if item.GetItemData().HasTag(tag) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func IsInWorkspot(owner: wref<GameObject>) -> Bool {
    let res: Bool;
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(owner.GetGame());
    if IsDefined(workspotSystem) {
      res = workspotSystem.IsActorInWorkspot(owner);
    };
    return res;
  }

  public final static func IsPointInRestrictedMovementArea(ownerPuppet: wref<ScriptedPuppet>, point: Vector4) -> Bool {
    if !IsDefined(ownerPuppet) {
      return false;
    };
    return GameInstance.GetRestrictMovementAreaManager(ownerPuppet.GetGame()).IsPointInRestrictMovementArea(ownerPuppet.GetEntityID(), point);
  }

  public final static func IsPointInRMA(ownerPuppet: wref<ScriptedPuppet>, point: Vector4) -> Bool {
    return AIActionHelper.IsPointInRestrictedMovementArea(ownerPuppet, point);
  }

  public final static func GetCurrentStrongArmsTrailEffect(weapon: ref<ItemObject>) -> CName {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(weapon.GetGame());
    let weaponID: StatsObjectID = Cast(weapon.GetEntityID());
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
    switch damageType {
      case gamedataDamageType.Physical:
        return n"trail_physical";
      case gamedataDamageType.Thermal:
        return n"trail_thermal";
      case gamedataDamageType.Chemical:
        return n"trail_chemical";
      case gamedataDamageType.Electric:
        return n"trail_electric";
      default:
        return n"trail_physical";
    };
    return n"trail_physical";
  }

  public final static func StartCooldown(self: ref<GameObject>, record: wref<AIActionCooldown_Record>) -> Int32 {
    let activationCondition: Bool;
    let cdRequest: RegisterNewCooldownRequest;
    let context: ScriptExecutionContext;
    let count: Int32;
    let cs: ref<ICooldownSystem>;
    let i: Int32;
    if !IsDefined(record) {
      return -1;
    };
    if !AIHumanComponent.GetScriptContext(self as ScriptedPuppet, context) {
      LogAIError("To start a cooldown with condition checks puppet must have an AIHumanComponent!");
      return -1;
    };
    if record.Duration() < 0.00 || !IsNameValid(record.Name()) {
      return -1;
    };
    if record.Duration() == 0.00 {
      GameObject.RemoveCooldown(self, record.Name());
      return -1;
    };
    count = record.GetActivationConditionCount();
    if count > 0 {
      activationCondition = false;
      i = 0;
      while i < count {
        if AICondition.CheckActionCondition(context, record.GetActivationConditionItem(i)) {
          activationCondition = true;
        } else {
          i += 1;
        };
      };
    } else {
      activationCondition = true;
    };
    if !activationCondition {
      return -1;
    };
    cs = CSH.GetCooldownSystem(self);
    cdRequest.cooldownName = record.Name();
    cdRequest.duration = record.Duration();
    cdRequest.owner = self;
    return cs.Register(cdRequest);
  }

  public final static func StartCooldown(self: ref<GameObject>, cooldownName: CName, duration: Float) -> Int32 {
    let cdRequest: RegisterNewCooldownRequest;
    let cs: ref<ICooldownSystem>;
    if duration < 0.00 || !IsNameValid(cooldownName) {
      return -1;
    };
    if duration == 0.00 {
      GameObject.RemoveCooldown(self, cooldownName);
      return -1;
    };
    cs = CSH.GetCooldownSystem(self);
    cdRequest.cooldownName = cooldownName;
    cdRequest.duration = duration;
    cdRequest.owner = self;
    return cs.Register(cdRequest);
  }

  public final static func IsCooldownActive(self: ref<GameObject>, record: wref<AIActionCooldown_Record>) -> Bool {
    let context: ScriptExecutionContext;
    let cooldownName: CName;
    if !IsDefined(record) {
      return false;
    };
    if !AIHumanComponent.GetScriptContext(self as ScriptedPuppet, context) {
      LogAIError("To check a cooldown puppet must have an AIHumanComponent!");
      return false;
    };
    cooldownName = record.Name();
    if !IsNameValid(cooldownName) {
      return false;
    };
    return GameObject.IsCooldownActive(self, cooldownName);
  }

  public final static func GetBaseShootingPatternPackages(out patternPackages: array<wref<AIPatternsPackage_Record>>) -> Bool {
    let i: Int32;
    let tweakID: TweakDBID;
    let packageIDNames: array<String> = TDB.GetStringArray(t"AIGeneralSettings.baseShootingPatternPackages");
    let size: Int32 = ArraySize(packageIDNames);
    ArrayResize(patternPackages, size);
    i = 0;
    while i < size {
      tweakID = TDBID.Create(packageIDNames[i]);
      patternPackages[i] = TweakDBInterface.GetAIPatternsPackageRecord(tweakID);
      i += 1;
    };
    return size > 0;
  }

  public final static func ClearWorkspotCommand(puppet: wref<ScriptedPuppet>) -> Bool {
    let aiComponent: ref<AIHumanComponent>;
    let commandID: Int32;
    if !IsDefined(puppet) {
      return false;
    };
    aiComponent = puppet.GetAIControllerComponent();
    if !IsDefined(aiComponent) {
      return false;
    };
    commandID = aiComponent.GetActiveCommandID(n"AIUseWorkspotCommand");
    if commandID == -1 {
      return false;
    };
    if aiComponent.CancelCommandById(Cast(commandID)) {
      return true;
    };
    return false;
  }

  public final static func GetDistanceRangeFromRingType(ringRecord: wref<AIRingType_Record>, out distanceRange: Vector2) -> Bool {
    if ringRecord.Distance() >= 0.00 {
      distanceRange.X = ringRecord.Distance();
      distanceRange.Y = distanceRange.X;
    } else {
      return false;
    };
    if ringRecord.Tolerance() > 0.00 {
      distanceRange.X = ringRecord.Distance() - ringRecord.Tolerance();
      distanceRange.Y = ringRecord.Distance() + ringRecord.Tolerance();
    };
    return distanceRange.Y > 0.00;
  }

  public final static func GetDistanceRangeFromRingType(ringRecord: wref<AIRingType_Record>, condition: wref<AIOptimalDistanceCond_Record>, out distanceRange: Vector2) -> Bool {
    let tolerance: Float;
    if ringRecord.Distance() < 0.00 {
      return false;
    };
    distanceRange.X = ringRecord.Distance();
    if condition.DistanceMult() >= 0.00 {
      distanceRange.X *= condition.DistanceMult();
    };
    if condition.DistanceOffset() != 0.00 {
      distanceRange.X += condition.DistanceOffset();
    };
    distanceRange.Y = distanceRange.X;
    if distanceRange.X < 0.00 {
      return false;
    };
    if ringRecord.Tolerance() >= 0.00 {
      tolerance = ringRecord.Tolerance();
      if condition.ToleranceMult() >= 0.00 {
        tolerance *= condition.ToleranceMult();
      };
      if condition.ToleranceOffset() != 0.00 {
        tolerance += condition.ToleranceOffset();
      };
    };
    if tolerance > 0.00 {
      distanceRange.X = ringRecord.Distance() - tolerance;
      distanceRange.Y = ringRecord.Distance() + tolerance;
    };
    return distanceRange.Y > 0.00;
  }

  public final static func GetDistanceRangeFromRingType(ringRecord: wref<AIRingType_Record>, condition: wref<MovementPolicy_Record>, out distanceRange: Vector2) -> Bool {
    let tolerance: Float;
    if ringRecord.Distance() < 0.00 {
      return false;
    };
    distanceRange.X = ringRecord.Distance();
    if condition.RingDistanceMult() >= 0.00 {
      distanceRange.X *= condition.RingDistanceMult();
    };
    if condition.RingDistanceOffset() != 0.00 {
      distanceRange.X += condition.RingDistanceOffset();
    };
    distanceRange.Y = distanceRange.X;
    if distanceRange.X < 0.00 {
      return false;
    };
    if ringRecord.Tolerance() >= 0.00 {
      tolerance = ringRecord.Tolerance();
      if condition.RingToleranceMult() >= 0.00 {
        tolerance *= condition.RingToleranceMult();
      };
      if condition.RingToleranceOffset() != 0.00 {
        tolerance += condition.RingToleranceOffset();
      };
    };
    if tolerance > 0.00 {
      distanceRange.X = ringRecord.Distance() - tolerance;
      distanceRange.Y = ringRecord.Distance() + tolerance;
    };
    return distanceRange.Y > 0.00;
  }

  public final static func GetDistanceAndToleranceFromRingType(record: wref<MovementPolicy_Record>, out distance: Float, out tolerance: Float) -> Bool {
    if record.Ring().Distance() < 0.00 {
      return false;
    };
    distance = record.Ring().Distance();
    if record.RingDistanceMult() >= 0.00 {
      distance *= record.RingDistanceMult();
    };
    if record.RingDistanceOffset() != 0.00 {
      distance += record.RingDistanceOffset();
    };
    if distance < 0.00 {
      return false;
    };
    if record.Ring().Tolerance() >= 0.00 {
      tolerance = record.Ring().Tolerance();
      if record.RingToleranceMult() >= 0.00 {
        tolerance *= record.RingToleranceMult();
      };
      if record.RingToleranceOffset() != 0.00 {
        tolerance += record.RingToleranceOffset();
      };
    };
    if tolerance < 0.00 {
      tolerance = 0.00;
    };
    return true;
  }

  public final static func GetAdditionalTraceTypeValueFromTweakEnum(value: gamedataAIAdditionalTraceType) -> AdditionalTraceType {
    switch value {
      case gamedataAIAdditionalTraceType.Chest:
        return AdditionalTraceType.Chest;
      case gamedataAIAdditionalTraceType.Hip:
        return AdditionalTraceType.Hip;
      case gamedataAIAdditionalTraceType.Knee:
        return AdditionalTraceType.Knee;
      default:
        return AdditionalTraceType.Chest;
    };
  }

  public final static func GetLatestActiveRingTypeRecord(puppet: wref<ScriptedPuppet>) -> ref<AIRingType_Record> {
    let currentRing: gamedataAIRingType = AISquadHelper.GetCurrentSquadRing(puppet);
    switch currentRing {
      case gamedataAIRingType.Melee:
        return TweakDBInterface.GetAIRingTypeRecord(t"AIRingType.Melee");
      case gamedataAIRingType.Close:
        return TweakDBInterface.GetAIRingTypeRecord(t"AIRingType.Close");
      case gamedataAIRingType.Medium:
        return TweakDBInterface.GetAIRingTypeRecord(t"AIRingType.Medium");
      case gamedataAIRingType.Far:
        return TweakDBInterface.GetAIRingTypeRecord(t"AIRingType.Far");
      case gamedataAIRingType.Extreme:
        return TweakDBInterface.GetAIRingTypeRecord(t"AIRingType.Extreme");
      default:
        return TweakDBInterface.GetAIRingTypeRecord(t"AIRingType.Default");
    };
  }

  public final static func GetLatestActiveRingTypeRecordHelper(object: ref<GameObject>) -> ref<AIRingType_Record> {
    let puppet: ref<ScriptedPuppet> = object as ScriptedPuppet;
    if puppet == null {
      return null;
    };
    return AIActionHelper.GetLatestActiveRingTypeRecord(puppet);
  }

  public final static func WeaponHasTriggerModes(weapon: wref<WeaponObject>, weaponRecord: wref<WeaponItem_Record>, triggerModes: array<wref<TriggerMode_Record>>) -> Bool {
    let i: Int32;
    let j: Int32;
    let triggerModesSize: Int32 = ArraySize(triggerModes);
    if triggerModesSize == 0 {
      return false;
    };
    i = 0;
    while i < triggerModesSize {
      if Equals(triggerModes[i].Type(), gamedataTriggerMode.Charge) {
        if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime) > 0.00 {
          j += 1;
        } else {
        };
      } else {
        if Equals(triggerModes[i].Type(), gamedataTriggerMode.Burst) {
          if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTime_Burst) > 0.00 {
            j += 1;
          } else {
            if triggerModes[i] == weaponRecord.PrimaryTriggerMode() {
              j += 1;
            };
          };
        };
      };
      if triggerModes[i] == weaponRecord.PrimaryTriggerMode() {
        j += 1;
      };
      i += 1;
    };
    return triggerModesSize == j;
  }

  public final static func WeaponHasTriggerMode(weapon: wref<WeaponObject>, weaponRecord: wref<WeaponItem_Record>, triggerMode: wref<TriggerMode_Record>) -> Bool {
    if Equals(triggerMode.Type(), gamedataTriggerMode.Charge) {
      if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime) > 0.00 {
        return true;
      };
    } else {
      if Equals(triggerMode.Type(), gamedataTriggerMode.Burst) {
        if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTime_Burst) > 0.00 {
          return true;
        };
      };
    };
    if triggerMode == weaponRecord.PrimaryTriggerMode() {
      return true;
    };
    return false;
  }

  public final static func WeaponHasTriggerMode(weapon: wref<WeaponObject>, weaponRecord: wref<WeaponItem_Record>, triggerMode: gamedataTriggerMode) -> Bool {
    if Equals(triggerMode, gamedataTriggerMode.Charge) {
      if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime) > 0.00 {
        return true;
      };
    } else {
      if Equals(triggerMode, gamedataTriggerMode.Burst) {
        if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTime_Burst) > 0.00 {
          return true;
        };
      };
    };
    if Equals(triggerMode, weaponRecord.PrimaryTriggerMode().Type()) {
      return true;
    };
    return false;
  }

  public final static func WeaponHasTriggerMode(weapon: wref<WeaponObject>, triggerMode: gamedataTriggerMode) -> Bool {
    let weaponRecord: wref<WeaponItem_Record>;
    if Equals(triggerMode, gamedataTriggerMode.Charge) {
      if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime) > 0.00 {
        return true;
      };
    } else {
      if Equals(triggerMode, gamedataTriggerMode.Burst) {
        if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTime_Burst) > 0.00 {
          return true;
        };
      };
    };
    weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weapon.GetItemID())) as WeaponItem_Record;
    if Equals(triggerMode, weaponRecord.PrimaryTriggerMode().Type()) {
      return true;
    };
    return false;
  }

  public final static func WeaponHasTriggerMode(weapon: wref<WeaponObject>, triggerMode: wref<TriggerMode_Record>) -> Bool {
    let weaponRecord: wref<WeaponItem_Record>;
    if Equals(triggerMode.Type(), gamedataTriggerMode.Charge) {
      if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.ChargeTime) > 0.00 {
        return true;
      };
    } else {
      if Equals(triggerMode.Type(), gamedataTriggerMode.Burst) {
        if GameInstance.GetStatsSystem(weapon.GetGame()).GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CycleTime_Burst) > 0.00 {
          return true;
        };
      };
    };
    weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weapon.GetItemID())) as WeaponItem_Record;
    if triggerMode == weaponRecord.PrimaryTriggerMode() {
      return true;
    };
    return false;
  }

  public final static func GetLastRequestedTriggerMode(weapon: wref<WeaponObject>) -> gamedataTriggerMode {
    return IntEnum(weapon.GetAIBlackboard().GetInt(GetAllBlackboardDefs().AIShooting.requestedTriggerMode));
  }

  public final static func UpdateLinkedStatusEffects(owner: wref<GameObject>, out linkedStatusEffect: LinkedStatusEffect) -> Void {
    let hackLocomotionT1: TweakDBID;
    let hackLocomotionT2: TweakDBID;
    let hackLocomotionT3: TweakDBID;
    let hackMalfunctionT2: TweakDBID;
    let hackMalfunctionT3: TweakDBID;
    let hackMalfunctiontT1: TweakDBID;
    let i: Int32;
    let overheatT1: TweakDBID;
    let overheatT2: TweakDBID;
    let overheatT3: TweakDBID;
    if EntityID.IsDefined(linkedStatusEffect.targetID) {
      overheatT1 = t"AIQuickHackStatusEffect.HackOverheat";
      overheatT2 = t"AIQuickHackStatusEffect.HackOverheatTier2";
      overheatT3 = t"AIQuickHackStatusEffect.HackOverheatTier3";
      hackMalfunctiontT1 = t"AIQuickHackStatusEffect.HackWeaponMalfunction";
      hackMalfunctionT2 = t"AIQuickHackStatusEffect.HackWeaponMalfunctionTier2";
      hackMalfunctionT3 = t"AIQuickHackStatusEffect.HackWeaponMalfunctionTier3";
      hackLocomotionT1 = t"AIQuickHackStatusEffect.HackLocomotion";
      hackLocomotionT2 = t"AIQuickHackStatusEffect.HackLocomotionTier2";
      hackLocomotionT3 = t"AIQuickHackStatusEffect.HackLocomotionTier3";
    };
    i = 0;
    while i < ArraySize(linkedStatusEffect.statusEffectList) {
      if ArraySize(linkedStatusEffect.netrunnerIDs) > 0 {
        if linkedStatusEffect.statusEffectList[i] == overheatT1 || linkedStatusEffect.statusEffectList[i] == overheatT2 || linkedStatusEffect.statusEffectList[i] == overheatT3 {
          StatusEffectHelper.RemoveStatusEffect(owner, linkedStatusEffect.statusEffectList[i]);
          switch ArraySize(linkedStatusEffect.netrunnerIDs) {
            case 1:
              linkedStatusEffect.statusEffectList[i] = overheatT1;
              StatusEffectHelper.ApplyStatusEffect(owner, overheatT1, linkedStatusEffect.netrunnerIDs[0]);
              break;
            case 2:
              linkedStatusEffect.statusEffectList[i] = overheatT2;
              StatusEffectHelper.ApplyStatusEffect(owner, overheatT2, linkedStatusEffect.netrunnerIDs[0]);
              break;
            case 3:
              linkedStatusEffect.statusEffectList[i] = overheatT3;
              StatusEffectHelper.ApplyStatusEffect(owner, overheatT3, linkedStatusEffect.netrunnerIDs[0]);
              break;
            default:
          };
        };
        if linkedStatusEffect.statusEffectList[i] == hackMalfunctiontT1 || linkedStatusEffect.statusEffectList[i] == hackMalfunctionT2 || linkedStatusEffect.statusEffectList[i] == hackMalfunctionT3 {
          StatusEffectHelper.RemoveStatusEffect(owner, linkedStatusEffect.statusEffectList[i]);
          switch ArraySize(linkedStatusEffect.netrunnerIDs) {
            case 1:
              linkedStatusEffect.statusEffectList[i] = hackMalfunctiontT1;
              StatusEffectHelper.ApplyStatusEffect(owner, hackMalfunctiontT1, linkedStatusEffect.netrunnerIDs[0]);
              break;
            case 2:
              linkedStatusEffect.statusEffectList[i] = hackMalfunctionT2;
              StatusEffectHelper.ApplyStatusEffect(owner, hackMalfunctionT2, linkedStatusEffect.netrunnerIDs[0]);
              break;
            case 3:
              linkedStatusEffect.statusEffectList[i] = hackMalfunctionT3;
              StatusEffectHelper.ApplyStatusEffect(owner, hackMalfunctionT3, linkedStatusEffect.netrunnerIDs[0]);
              break;
            default:
          };
        };
        if linkedStatusEffect.statusEffectList[i] == hackLocomotionT1 || linkedStatusEffect.statusEffectList[i] == hackLocomotionT2 || linkedStatusEffect.statusEffectList[i] == hackLocomotionT3 {
          StatusEffectHelper.RemoveStatusEffect(owner, linkedStatusEffect.statusEffectList[i]);
          switch ArraySize(linkedStatusEffect.netrunnerIDs) {
            case 1:
              linkedStatusEffect.statusEffectList[i] = hackLocomotionT1;
              StatusEffectHelper.ApplyStatusEffect(owner, hackLocomotionT1, linkedStatusEffect.netrunnerIDs[0]);
              break;
            case 2:
              linkedStatusEffect.statusEffectList[i] = hackLocomotionT2;
              StatusEffectHelper.ApplyStatusEffect(owner, hackLocomotionT2, linkedStatusEffect.netrunnerIDs[0]);
              break;
            case 3:
              linkedStatusEffect.statusEffectList[i] = hackLocomotionT3;
              StatusEffectHelper.ApplyStatusEffect(owner, hackLocomotionT3, linkedStatusEffect.netrunnerIDs[0]);
              break;
            default:
          };
        };
      } else {
        StatusEffectHelper.RemoveStatusEffect(owner, linkedStatusEffect.statusEffectList[i]);
      };
      i += 1;
    };
  }

  public final static func QueuePullSquadSync(owner: wref<GameObject>) -> Void {
    let pullSquadSyncRequest: ref<PullSquadSyncRequest> = new PullSquadSyncRequest();
    pullSquadSyncRequest.squadType = AISquadType.Combat;
    GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, pullSquadSyncRequest, TweakDBInterface.GetFloat(t"AIGeneralSettings.callingAlliesToCombatDelay", 2.50));
  }

  public final static func QueueSecuritySystemCombatNotification(owner: wref<GameObject>) -> Void {
    let notificationEvent: ref<NotifySecuritySystemCombatEvent> = new NotifySecuritySystemCombatEvent();
    GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, notificationEvent, TweakDBInterface.GetFloat(t"AIGeneralSettings.callingAlliesToCombatDelay", 2.50));
  }

  public final static func PreloadBaseAnimations(puppet: wref<ScriptedPuppet>, opt melee: Bool) -> Bool {
    let result1: Bool;
    let result2: Bool;
    if melee {
      result1 = AIActionHelper.PreloadAnimations(puppet, n"melee", true);
    } else {
      result1 = AIActionHelper.PreloadAnimations(puppet, n"ranged_base", true);
    };
    result2 = AIActionHelper.PreloadAnimations(puppet, n"hit_reaction_base", true);
    return result1 && result2;
  }

  public final static func PreloadCoreAnimations(puppet: wref<ScriptedPuppet>, opt melee: Bool) -> Bool {
    let result1: Bool;
    let result2: Bool;
    if melee {
      result1 = AIActionHelper.PreloadAnimations(puppet, n"melee", true);
    } else {
      result1 = AIActionHelper.PreloadAnimations(puppet, n"ranged_core", true);
    };
    result2 = AIActionHelper.PreloadAnimations(puppet, n"hit_reaction_core", true);
    return result1 && result2;
  }

  public final static func PreloadAllBaseAnimations(puppet: wref<ScriptedPuppet>) -> Void {
    AIActionHelper.PreloadAnimations(puppet, n"melee", true);
    AIActionHelper.PreloadAnimations(puppet, n"ranged_core", true);
    AIActionHelper.PreloadAnimations(puppet, n"ranged_base", true);
    AIActionHelper.PreloadAnimations(puppet, n"hit_reaction_core", true);
    AIActionHelper.PreloadAnimations(puppet, n"hit_reaction_base", true);
  }

  public final static func PreloadAnimations(puppet: wref<ScriptedPuppet>, streamingContextName: CName, highPriority: Bool) -> Bool {
    let animComponent: ref<AnimationControllerComponent>;
    if !IsDefined(puppet) {
      return false;
    };
    animComponent = puppet.GetAnimationControllerComponent();
    if !IsDefined(animComponent) {
      return false;
    };
    if !animComponent.PreloadAnimations(streamingContextName, highPriority) {
      return false;
    };
    return true;
  }

  public final static func QueuePreloadCoreAnimationsEvent(puppet: wref<ScriptedPuppet>) -> Void {
    let evt: ref<PreloadAnimationsEvent>;
    if !IsDefined(puppet) {
      return;
    };
    evt = new PreloadAnimationsEvent();
    evt.m_streamingContextName = n"ranged_core";
    evt.m_highPriority = true;
    puppet.QueueEvent(evt);
  }

  public final static func QueuePreloadBaseAnimationsEvent(puppet: wref<ScriptedPuppet>) -> Void {
    let evt: ref<PreloadAnimationsEvent>;
    if !IsDefined(puppet) {
      return;
    };
    evt = new PreloadAnimationsEvent();
    evt.m_streamingContextName = n"ranged_base";
    evt.m_highPriority = true;
    puppet.QueueEvent(evt);
  }

  public final static func CheckAbility(const object: wref<GameObject>, ability: wref<GameplayAbility_Record>) -> Bool {
    let record: ref<IPrereq_Record>;
    let count: Int32 = ability.GetPrereqsForUseCount();
    let i: Int32 = 0;
    while i < count {
      record = ability.GetPrereqsForUseItem(i);
      if !IPrereq.CreatePrereq(record.GetID()).IsFulfilled(object.GetGame(), object) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func SetItemsEquipData(puppet: wref<ScriptedPuppet>, itemsToEquip: array<NPCItemToEquip>) -> Void {
    let BBoard: ref<IBlackboard>;
    let actionDuration: Float;
    let animDuration: Float;
    let itemData: ref<gameItemData>;
    if !IsDefined(puppet) {
      return;
    };
    BBoard = puppet.GetAIControllerComponent().GetActionBlackboard();
    if !IsDefined(BBoard) {
      return;
    };
    BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip, ToVariant(itemsToEquip));
    itemData = GameInstance.GetTransactionSystem(puppet.GetGame()).GetItemData(puppet, itemsToEquip[0].itemID);
    if puppet.IsCharacterGanger() {
      BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipItemTime, itemData.GetStatValueByType(gamedataStatType.EquipItemTime_Gang));
      actionDuration = itemData.GetStatValueByType(gamedataStatType.EquipActionDuration_Gang);
      animDuration = itemData.GetStatValueByType(gamedataStatType.EquipAnimationDuration_Gang);
      if animDuration == 0.00 {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, actionDuration);
      } else {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, animDuration);
      };
    } else {
      BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipItemTime, itemData.GetStatValueByType(gamedataStatType.EquipItemTime_Corpo));
      actionDuration = itemData.GetStatValueByType(gamedataStatType.EquipActionDuration_Corpo);
      animDuration = itemData.GetStatValueByType(gamedataStatType.EquipAnimationDuration_Corpo);
      if animDuration == 0.00 {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, actionDuration);
      } else {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, animDuration);
      };
    };
  }

  public final static func SetItemsUnequipData(puppet: wref<ScriptedPuppet>, itemsToUnequip: array<NPCItemToEquip>, dropItem: Bool) -> Void {
    let BBoard: ref<IBlackboard>;
    let actionDuration: Float;
    let animDuration: Float;
    let itemData: ref<gameItemData>;
    if !IsDefined(puppet) {
      return;
    };
    BBoard = puppet.GetAIControllerComponent().GetActionBlackboard();
    if !IsDefined(BBoard) {
      return;
    };
    BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip, ToVariant(itemsToUnequip));
    itemData = GameInstance.GetTransactionSystem(puppet.GetGame()).GetItemData(puppet, itemsToUnequip[0].itemID);
    if puppet.IsCharacterGanger() {
      BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipItemTime, itemData.GetStatValueByType(gamedataStatType.UnequipItemTime_Gang));
      actionDuration = itemData.GetStatValueByType(gamedataStatType.UnequipDuration_Gang);
      animDuration = itemData.GetStatValueByType(gamedataStatType.UnequipAnimationDuration_Gang);
      if animDuration == 0.00 {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, actionDuration);
      } else {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, animDuration);
      };
    } else {
      BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipItemTime, itemData.GetStatValueByType(gamedataStatType.UnequipItemTime_Corpo));
      actionDuration = itemData.GetStatValueByType(gamedataStatType.UnequipDuration_Corpo);
      animDuration = itemData.GetStatValueByType(gamedataStatType.UnequipAnimationDuration_Corpo);
      if animDuration == 0.00 {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, actionDuration);
      } else {
        BBoard.SetFloat(GetAllBlackboardDefs().AIAction.ownerEquipDuration, animDuration);
      };
    };
    BBoard.SetBool(GetAllBlackboardDefs().AIAction.dropItemOnUnequip, dropItem);
  }

  public final static func ClearItemsToEquip(puppet: wref<ScriptedPuppet>) -> Void {
    let BBoard: ref<IBlackboard>;
    let itemsToEquip: array<NPCItemToEquip>;
    if !IsDefined(puppet) {
      return;
    };
    BBoard = puppet.GetAIControllerComponent().GetActionBlackboard();
    if !IsDefined(BBoard) {
      return;
    };
    BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip, ToVariant(itemsToEquip));
  }

  public final static func ClearItemsToUnequip(puppet: wref<ScriptedPuppet>) -> Void {
    let BBoard: ref<IBlackboard>;
    let itemsToUnequip: array<NPCItemToEquip>;
    if !IsDefined(puppet) {
      return;
    };
    BBoard = puppet.GetAIControllerComponent().GetActionBlackboard();
    if !IsDefined(BBoard) {
      return;
    };
    BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsToEquip, ToVariant(itemsToUnequip));
  }

  public final static func ClearItemsUnequipped(puppet: wref<ScriptedPuppet>) -> Void {
    let BBoard: ref<IBlackboard>;
    let itemsToUnequipped: array<NPCItemToEquip>;
    if !IsDefined(puppet) {
      return;
    };
    BBoard = puppet.GetAIControllerComponent().GetActionBlackboard();
    if !IsDefined(BBoard) {
      return;
    };
    BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsUnequipped, ToVariant(itemsToUnequipped));
  }

  public final static func ClearItemsForceUnequipped(puppet: wref<ScriptedPuppet>) -> Void {
    let BBoard: ref<IBlackboard>;
    let itemsToUnequipped: array<NPCItemToEquip>;
    if !IsDefined(puppet) {
      return;
    };
    BBoard = puppet.GetAIControllerComponent().GetActionBlackboard();
    if !IsDefined(BBoard) {
      return;
    };
    BBoard.SetVariant(GetAllBlackboardDefs().AIAction.ownerItemsForceUnequipped, ToVariant(itemsToUnequipped));
  }
}

public class AIActionChecks extends IScriptable {

  public final static func CheckOwnerState(puppet: ref<ScriptedPuppet>, npcStates: AIActionNPCStates, checkAll: Bool) -> Bool {
    if !IsDefined(puppet) {
      return true;
    };
    if checkAll {
      return AIActionChecks.CheckAllNPCStateTypes(puppet, npcStates);
    };
    return AIActionChecks.CheckNPCState(puppet, npcStates);
  }

  public final static func CheckTargetState(target: ref<ScriptedPuppet>, targetStates: AIActionTargetStates, checkAll: Bool) -> Bool {
    if !IsDefined(target) {
      return true;
    };
    if target.IsPlayer() {
      if checkAll {
        return AIActionChecks.CheckAllPlayerStateTypes(target, targetStates.playerStates);
      };
      return AIActionChecks.CheckPlayerState(target, targetStates.playerStates);
    };
    if target.IsNPC() {
      if checkAll {
        return AIActionChecks.CheckAllNPCStateTypes(target, targetStates.npcStates);
      };
      return AIActionChecks.CheckNPCState(target, targetStates.npcStates);
    };
    return true;
  }

  public final static func CheckAllNPCStateTypes(puppet: ref<ScriptedPuppet>, npcStates: AIActionNPCStates) -> Bool {
    if ArraySize(npcStates.highLevelStates) == 0 && ArraySize(npcStates.upperBodyStates) == 0 && ArraySize(npcStates.stanceStates) == 0 && ArraySize(npcStates.behaviorStates) == 0 && ArraySize(npcStates.defenseMode) == 0 && ArraySize(npcStates.locomotionMode) == 0 {
      return true;
    };
    if ArraySize(npcStates.highLevelStates) > 0 && !AIActionChecks.CheckHighLevelState(puppet, npcStates.highLevelStates) {
      return false;
    };
    if ArraySize(npcStates.upperBodyStates) > 0 && !AIActionChecks.CheckUpperBodyState(puppet, npcStates.upperBodyStates) {
      return false;
    };
    if ArraySize(npcStates.stanceStates) > 0 && !AIActionChecks.CheckStanceState(puppet, npcStates.stanceStates) {
      return false;
    };
    if ArraySize(npcStates.behaviorStates) > 0 && !AIActionChecks.CheckBehaviorState(puppet, npcStates.behaviorStates) {
      return false;
    };
    if ArraySize(npcStates.locomotionMode) > 0 && !AIActionChecks.CheckLocomotionMode(puppet, npcStates.locomotionMode) {
      return false;
    };
    if ArraySize(npcStates.defenseMode) > 0 && !AIActionChecks.CheckDefenseMode(puppet, npcStates.defenseMode) {
      return false;
    };
    return true;
  }

  public final static func CheckNPCState(puppet: ref<ScriptedPuppet>, npcStates: AIActionNPCStates) -> Bool {
    if ArraySize(npcStates.highLevelStates) == 0 && ArraySize(npcStates.upperBodyStates) == 0 && ArraySize(npcStates.stanceStates) == 0 && ArraySize(npcStates.behaviorStates) == 0 && ArraySize(npcStates.defenseMode) == 0 && ArraySize(npcStates.locomotionMode) == 0 {
      return true;
    };
    if ArraySize(npcStates.highLevelStates) > 0 && AIActionChecks.CheckHighLevelState(puppet, npcStates.highLevelStates) {
      return true;
    };
    if ArraySize(npcStates.upperBodyStates) > 0 && AIActionChecks.CheckUpperBodyState(puppet, npcStates.upperBodyStates) {
      return true;
    };
    if ArraySize(npcStates.stanceStates) > 0 && AIActionChecks.CheckStanceState(puppet, npcStates.stanceStates) {
      return true;
    };
    if ArraySize(npcStates.behaviorStates) > 0 && AIActionChecks.CheckBehaviorState(puppet, npcStates.behaviorStates) {
      return true;
    };
    if ArraySize(npcStates.locomotionMode) > 0 && AIActionChecks.CheckLocomotionMode(puppet, npcStates.locomotionMode) {
      return true;
    };
    if ArraySize(npcStates.defenseMode) > 0 && AIActionChecks.CheckDefenseMode(puppet, npcStates.defenseMode) {
      return true;
    };
    return false;
  }

  public final static func CheckAllPlayerStateTypes(playerPuppet: ref<ScriptedPuppet>, playerStates: AIActionPlayerStates) -> Bool {
    if ArraySize(playerStates.locomotionStates) == 0 && ArraySize(playerStates.upperBodyStates) == 0 && ArraySize(playerStates.meleeStates) == 0 && ArraySize(playerStates.zoneStates) == 0 && ArraySize(playerStates.bodyCarryStates) == 0 && ArraySize(playerStates.combatStates) == 0 {
      return true;
    };
    if ArraySize(playerStates.locomotionStates) > 0 && !AIActionChecks.CheckPSMLocomotionState(playerPuppet, playerStates.locomotionStates) {
      return false;
    };
    if ArraySize(playerStates.upperBodyStates) > 0 && !AIActionChecks.CheckPSMUpperBodyState(playerPuppet, playerStates.upperBodyStates) {
      return false;
    };
    if ArraySize(playerStates.meleeStates) > 0 && !AIActionChecks.CheckPSMMeleeState(playerPuppet, playerStates.meleeStates) {
      return false;
    };
    if ArraySize(playerStates.zoneStates) > 0 && !AIActionChecks.CheckPSMZoneState(playerPuppet, playerStates.zoneStates) {
      return false;
    };
    if ArraySize(playerStates.bodyCarryStates) > 0 && !AIActionChecks.CheckPSMBodyCarryState(playerPuppet, playerStates.bodyCarryStates) {
      return false;
    };
    if ArraySize(playerStates.combatStates) > 0 && !AIActionChecks.CheckPSMCombatState(playerPuppet, playerStates.combatStates) {
      return false;
    };
    return true;
  }

  public final static func CheckPlayerState(playerPuppet: ref<ScriptedPuppet>, playerStates: AIActionPlayerStates) -> Bool {
    if ArraySize(playerStates.locomotionStates) == 0 && ArraySize(playerStates.upperBodyStates) == 0 && ArraySize(playerStates.meleeStates) == 0 && ArraySize(playerStates.zoneStates) == 0 && ArraySize(playerStates.bodyCarryStates) == 0 && ArraySize(playerStates.combatStates) == 0 {
      return true;
    };
    if ArraySize(playerStates.locomotionStates) > 0 && AIActionChecks.CheckPSMLocomotionState(playerPuppet, playerStates.locomotionStates) {
      return true;
    };
    if ArraySize(playerStates.upperBodyStates) > 0 && AIActionChecks.CheckPSMUpperBodyState(playerPuppet, playerStates.upperBodyStates) {
      return true;
    };
    if ArraySize(playerStates.meleeStates) > 0 && AIActionChecks.CheckPSMMeleeState(playerPuppet, playerStates.meleeStates) {
      return true;
    };
    if ArraySize(playerStates.zoneStates) > 0 && AIActionChecks.CheckPSMZoneState(playerPuppet, playerStates.zoneStates) {
      return true;
    };
    if ArraySize(playerStates.bodyCarryStates) > 0 && AIActionChecks.CheckPSMBodyCarryState(playerPuppet, playerStates.bodyCarryStates) {
      return true;
    };
    if ArraySize(playerStates.combatStates) > 0 && AIActionChecks.CheckPSMCombatState(playerPuppet, playerStates.combatStates) {
      return true;
    };
    return false;
  }

  public final static func CheckHighLevelState(puppet: ref<ScriptedPuppet>, highLevelStates: array<gamedataNPCHighLevelState>) -> Bool {
    let currentHighLevelState: gamedataNPCHighLevelState = IntEnum(puppet.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
    if !ArrayContains(highLevelStates, currentHighLevelState) {
      return false;
    };
    return true;
  }

  public final static func CheckUpperBodyState(puppet: ref<ScriptedPuppet>, upperBodyStates: array<gamedataNPCUpperBodyState>) -> Bool {
    let currentUpperBodyState: gamedataNPCUpperBodyState = IntEnum(puppet.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.UpperBody));
    if !IsDefined(puppet) || !ArrayContains(upperBodyStates, currentUpperBodyState) {
      return false;
    };
    return true;
  }

  public final static func CheckStanceState(puppet: ref<ScriptedPuppet>, stanceStates: array<gamedataNPCStanceState>) -> Bool {
    let currentStanceState: gamedataNPCStanceState = IntEnum(puppet.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.Stance));
    if !ArrayContains(stanceStates, currentStanceState) {
      return false;
    };
    return true;
  }

  public final static func CheckBehaviorState(puppet: ref<ScriptedPuppet>, behaviorStates: array<gamedataNPCBehaviorState>) -> Bool {
    let currentBehaviorState: gamedataNPCBehaviorState = IntEnum(puppet.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.BehaviorState));
    if !ArrayContains(behaviorStates, currentBehaviorState) {
      return false;
    };
    return true;
  }

  public final static func CheckDefenseMode(puppet: ref<ScriptedPuppet>, defenseMode: array<gamedataDefenseMode>) -> Bool {
    let currentDefenseMode: gamedataDefenseMode = IntEnum(puppet.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.DefenseMode));
    if !ArrayContains(defenseMode, currentDefenseMode) {
      return false;
    };
    return true;
  }

  public final static func CheckLocomotionMode(puppet: ref<ScriptedPuppet>, locomotionMode: array<gamedataLocomotionMode>) -> Bool {
    let currentlocomotionMode: gamedataLocomotionMode = IntEnum(puppet.GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.LocomotionMode));
    if !ArrayContains(locomotionMode, currentlocomotionMode) {
      return false;
    };
    return true;
  }

  public final static func GetPSMBlackbordInt(playerPuppet: ref<ScriptedPuppet>, id: BlackboardID_Int) -> Int32 {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(playerPuppet.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetInt(id);
  }

  public final static func CheckPSMLocomotionState(playerPuppet: ref<ScriptedPuppet>, locomotionStates: array<gamePSMLocomotionStates>) -> Bool {
    let currentState: gamePSMLocomotionStates = IntEnum(AIActionChecks.GetPSMBlackbordInt(playerPuppet, GetAllBlackboardDefs().PlayerStateMachine.Locomotion));
    if !ArrayContains(locomotionStates, currentState) {
      return false;
    };
    return true;
  }

  public final static func CheckPSMUpperBodyState(playerPuppet: ref<ScriptedPuppet>, upperBodyStates: array<gamePSMUpperBodyStates>) -> Bool {
    let currentState: gamePSMUpperBodyStates = IntEnum(AIActionChecks.GetPSMBlackbordInt(playerPuppet, GetAllBlackboardDefs().PlayerStateMachine.UpperBody));
    if !ArrayContains(upperBodyStates, currentState) {
      return false;
    };
    return true;
  }

  public final static func CheckPSMMeleeState(playerPuppet: ref<ScriptedPuppet>, meleeStates: array<gamePSMMelee>) -> Bool {
    let currentState: gamePSMMelee = IntEnum(AIActionChecks.GetPSMBlackbordInt(playerPuppet, GetAllBlackboardDefs().PlayerStateMachine.Melee));
    if !ArrayContains(meleeStates, currentState) {
      return false;
    };
    return true;
  }

  public final static func CheckPSMZoneState(playerPuppet: ref<ScriptedPuppet>, zoneStates: array<gamePSMZones>) -> Bool {
    let currentState: gamePSMZones = IntEnum(AIActionChecks.GetPSMBlackbordInt(playerPuppet, GetAllBlackboardDefs().PlayerStateMachine.Zones));
    if !ArrayContains(zoneStates, currentState) {
      return false;
    };
    return true;
  }

  public final static func CheckPSMBodyCarryState(playerPuppet: ref<ScriptedPuppet>, bodyCarryStates: array<gamePSMBodyCarrying>) -> Bool {
    let currentState: gamePSMBodyCarrying = IntEnum(AIActionChecks.GetPSMBlackbordInt(playerPuppet, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying));
    if !ArrayContains(bodyCarryStates, currentState) {
      return false;
    };
    return true;
  }

  public final static func CheckPSMCombatState(playerPuppet: ref<ScriptedPuppet>, combatStates: array<gamePSMCombat>) -> Bool {
    let currentState: gamePSMCombat = IntEnum(AIActionChecks.GetPSMBlackbordInt(playerPuppet, GetAllBlackboardDefs().PlayerStateMachine.Combat));
    if !ArrayContains(combatStates, currentState) {
      return false;
    };
    return true;
  }

  public final static func CheckMountedVehicleDesiredTags(puppet: ref<ScriptedPuppet>, desiredTags: array<CName>) -> Bool {
    let i: Int32;
    let tags: array<CName>;
    let vehicleRecord: ref<Vehicle_Record>;
    if ArraySize(desiredTags) <= 0 {
      return true;
    };
    if !VehicleComponent.GetVehicleRecord(puppet.GetGame(), puppet.GetEntityID(), vehicleRecord) {
      return false;
    };
    tags = vehicleRecord.Tags();
    i = 0;
    while i < ArraySize(desiredTags) {
      if ArrayContains(tags, desiredTags[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }
}
