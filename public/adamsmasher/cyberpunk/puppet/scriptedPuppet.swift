
public class RevealRequestEvent extends Event {

  private let shouldReveal: Bool;

  private let requester: EntityID;

  private let oneFrame: Bool;

  public final func CreateRequest(doReveal: Bool, whoWantsToReveal: EntityID) -> Void {
    this.shouldReveal = doReveal;
    this.requester = whoWantsToReveal;
  }

  public final func GetShouldReveal() -> Bool {
    return this.shouldReveal;
  }

  public final func GetRequester() -> EntityID {
    return this.requester;
  }

  public final func SetOneFrame() -> Void {
    this.oneFrame = true;
  }

  public final func IsOneFrame() -> Bool {
    return this.oneFrame;
  }
}

public class RevealRequestsStorage extends IScriptable {

  private let currentRequestersAmount: Int32;

  private let requestersList: array<EntityID>;

  public final func IsRequesterLegal(requester: EntityID, addsRequest: Bool) -> Bool {
    if addsRequest {
      if this.IsRequesterOnTheList(requester) {
        return false;
      };
      return true;
    };
    if this.IsRequesterOnTheList(requester) {
      return true;
    };
    return false;
  }

  public final func RegisterLegalRequest(requester: EntityID, shouldAdd: Bool) -> Void {
    if shouldAdd {
      this.LegalRequestAdd(requester);
    } else {
      this.LegalRequestRemove(requester);
    };
  }

  public final func ShouldReveal() -> Bool {
    return Cast(this.currentRequestersAmount);
  }

  public final func ClearAllRequests() -> Void {
    ArrayClear(this.requestersList);
    this.currentRequestersAmount = 0;
  }

  private final func IsRequesterOnTheList(requester: EntityID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.requestersList) {
      if this.requestersList[i] == requester {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func LegalRequestAdd(requester: EntityID) -> Void {
    ArrayPush(this.requestersList, requester);
    this.currentRequestersAmount += 1;
  }

  private final func LegalRequestRemove(requester: EntityID) -> Void {
    ArrayRemove(this.requestersList, requester);
    this.currentRequestersAmount -= 1;
  }
}

public class PuppetListener extends IScriptable {

  public let prereqOwner: ref<PrereqState>;

  public final func RegisterOwner(owner: ref<PrereqState>) -> Bool {
    if !IsDefined(this.prereqOwner) {
      this.prereqOwner = owner;
      return true;
    };
    return false;
  }

  public final func ModifyOwner(owner: ref<PrereqState>) -> Void {
    this.prereqOwner = owner;
  }

  public final func OnRevealedStateChanged(isRevealed: Bool) -> Void {
    let castedOwner: ref<NPCRevealedPrereqState> = this.prereqOwner as NPCRevealedPrereqState;
    if IsDefined(castedOwner) {
      castedOwner.OnChanged(isRevealed);
    };
  }

  public final func OnHitReactionTypeChanged(hitType: Int32) -> Void {
    let castedPrereq: ref<NPCHitReactionTypePrereq> = this.prereqOwner.GetPrereq() as NPCHitReactionTypePrereq;
    if IsDefined(castedPrereq) {
      this.prereqOwner.OnChanged(castedPrereq.EvaluateCondition(hitType));
    };
  }

  public final func OnHitReactionSourceChanged(hitSource: Int32) -> Void {
    let castedPrereq: ref<NPCHitSourcePrereq> = this.prereqOwner.GetPrereq() as NPCHitSourcePrereq;
    if IsDefined(castedPrereq) {
      this.prereqOwner.OnChanged(castedPrereq.EvaluateCondition(hitSource));
    };
  }

  public final func OnIsTrackingPlayerChanged(isTrackingPlayer: Bool) -> Void {
    let castedPrereq: ref<NPCTrackingPlayerPrereq> = this.prereqOwner.GetPrereq() as NPCTrackingPlayerPrereq;
    if IsDefined(castedPrereq) {
      this.prereqOwner.OnChanged(castedPrereq.EvaluateCondition(isTrackingPlayer));
    };
  }
}

public class ScriptedPuppet extends gamePuppet {

  private let m_aiController: ref<AIHumanComponent>;

  private let m_movePolicies: ref<MovePoliciesComponent>;

  private let m_aiStateHandlerComponent: ref<AIPhaseStateEventHandlerComponent>;

  protected let m_hitReactionComponent: ref<HitReactionComponent>;

  private let m_signalHandlerComponent: ref<AISignalHandlerComponent>;

  private let m_reactionComponent: ref<ReactionManagerComponent>;

  private let m_dismembermentComponent: ref<DismembermentComponent>;

  private let m_hitRepresantation: ref<SlotComponent>;

  private let m_interactionComponent: ref<InteractionComponent>;

  private let m_slotComponent: ref<SlotComponent>;

  private let m_sensesComponent: ref<SenseComponent>;

  protected let m_visibleObjectComponent: ref<VisibleObjectComponent>;

  private let m_sensorObjectComponent: ref<SensorObjectComponent>;

  private let m_targetTrackerComponent: ref<TargetTrackerComponent>;

  private let m_targetingComponentsArray: array<ref<TargetingComponent>>;

  private let m_statesComponent: ref<NPCStatesComponent>;

  private let m_fxResourceMapper: ref<FxResourceMapperComponent>;

  private let m_linkedStatusEffect: LinkedStatusEffect;

  protected let m_resourceLibraryComponent: ref<ResourceLibraryComponent>;

  protected let m_crowdMemberComponent: ref<CrowdMemberBaseComponent>;

  private let m_inventoryComponent: ref<Inventory>;

  private let m_objectSelectionComponent: ref<ObjectSelectionComponent>;

  private let m_transformHistoryComponent: ref<TransformHistoryComponent>;

  private let m_animationControllerComponent: ref<AnimationControllerComponent>;

  private let m_bumpComponent: ref<BumpComponent>;

  private let m_isCrowd: Bool;

  private let m_incapacitatedOnAttach: Bool;

  private let m_isIconic: Bool;

  private let m_combatHUDManager: ref<CombatHUDManager>;

  private let m_exposePosition: Bool;

  private let m_puppetStateBlackboard: ref<IBlackboard>;

  private let m_customBlackboard: ref<IBlackboard>;

  private let m_securityAreaCallbackID: Uint32;

  private let m_customAIComponents: array<ref<AICustomComponents>>;

  protected let m_listeners: array<ref<PuppetListener>>;

  protected let m_securitySupportListener: ref<SecuritySupportListener>;

  private let m_shouldBeRevealedStorage: ref<RevealRequestsStorage>;

  private let m_inputProcessed: Bool;

  @default(ScriptedPuppet, true)
  private let m_shouldSpawnBloodPuddle: Bool;

  @default(ScriptedPuppet, false)
  private let m_bloodPuddleSpawned: Bool;

  @default(ScriptedPuppet, false)
  private let m_skipDeathAnimation: Bool;

  private let m_hitHistory: ref<HitHistory>;

  private let m_currentWorkspotTags: array<CName>;

  @default(ScriptedPuppet, gamedataQuality.Invalid)
  private let m_lootQuality: gamedataQuality;

  private let m_hasQuestItems: Bool;

  private let m_activeQualityRangeInteraction: CName;

  private let m_weakspotComponent: ref<WeakspotComponent>;

  private let m_highlightData: ref<FocusForcedHighlightData>;

  private let m_killer: wref<Entity>;

  private let m_objectActionsCallbackCtrl: ref<gameObjectActionsCallbackController>;

  private let m_isActiveCached: CachedBoolValue;

  private let m_isCyberpsycho: Bool;

  private let m_isCivilian: Bool;

  private let m_isPolice: Bool;

  private let m_isGanger: Bool;

  private persistent let m_attemptedShards: array<ItemID>;

  protected final func HandleDeathByTask(instigator: wref<GameObject>) -> Void {
    let data: ref<DeathTaskData> = new DeathTaskData();
    data.instigator = instigator;
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, data, n"HandleDeathTask", gameScriptTaskExecutionStage.PostPhysics);
  }

  protected final func HandleDeathTask(data: ref<ScriptTaskData>) -> Void {
    let deathData: ref<DeathTaskData> = data as DeathTaskData;
    if IsDefined(deathData) {
      this.HandleDeath(deathData.instigator);
    };
  }

  protected final func HandleDeath(instigator: wref<GameObject>) -> Void {
    let mod: StatPoolModifier;
    GameInstance.GetStatPoolsSystem(this.GetGame()).GetModifier(Cast(this.GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration, mod);
    mod.enabled = false;
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingModifier(Cast(this.GetEntityID()), gamedataStatPoolType.Health, gameStatPoolModificationTypes.Regeneration, mod);
    this.FindAndRewardKiller(gameKillType.Normal, instigator);
    this.OnDied();
  }

  protected final func HandleDefeatedByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"HandleDefeatedTask", gameScriptTaskExecutionStage.PostPhysics);
  }

  protected final func HandleDefeatedTask(data: ref<ScriptTaskData>) -> Void {
    this.HandleDefeated();
  }

  protected final func HandleDefeated() -> Void {
    this.FindAndRewardKiller(gameKillType.Defeat);
    this.OnIncapacitated();
    if !IsFinal() {
      LogDamage("ScriptedPuppet.OnDefeated(): " + IsDefined(this) + " is defeated.");
    };
    this.SquadUpdate(true, AISquadType.Combat);
    this.m_hitReactionComponent.UpdateDefeated();
  }

  public final static func EvaluateLootQualityByTask(self: wref<GameObject>) -> Void {
    if self != null {
      GameInstance.GetDelaySystem(self.GetGame()).QueueTask(self, null, n"EvaluateLootQualityTask", gameScriptTaskExecutionStage.Any);
    };
  }

  protected func EvaluateLootQualityByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"EvaluateLootQualityTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func EvaluateLootQualityTask(data: ref<ScriptTaskData>) -> Void {
    this.EvaluateLootQuality();
  }

  protected final func ResolveConnectionWithDeviceSystem() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"ResolveConnectionWithDeviceSystemTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func ResolveConnectionWithDeviceSystemTask(data: ref<ScriptTaskData>) -> Void {
    let link: ref<PuppetDeviceLinkPS> = this.GetDeviceLink() as PuppetDeviceLinkPS;
    if IsDefined(link) {
      link.GetSecuritySystem().RequestLatestOutput(Cast(this.GetEntityID()));
    };
  }

  private final func EquipSavedLoadout() -> Void {
    if this.IsPlayer() {
      return;
    };
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"EquipSavedLoadoutTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func EquipSavedLoadoutTask(data: ref<ScriptTaskData>) -> Void {
    let consumableCategory: CName;
    let consumableCategoryId: TweakDBID;
    let leftCategory: CName;
    let leftIsConsumable: Bool;
    let leftHandLoadout: ItemID = (this.GetPS() as ScriptedPuppetPS).GetLeftHandLoadout();
    let rightHandLoadout: ItemID = (this.GetPS() as ScriptedPuppetPS).GetRightHandLoadout();
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    let leftItemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(leftHandLoadout));
    if IsDefined(leftItemRecord) {
      leftCategory = leftItemRecord.ItemCategory().Name();
    };
    consumableCategoryId = t"ItemCategory.Consumable";
    consumableCategory = TweakDBInterface.GetItemCategoryRecord(consumableCategoryId).Name();
    leftIsConsumable = Equals(leftCategory, consumableCategory);
    if ItemID.IsValid(leftHandLoadout) && !leftIsConsumable {
      if Equals(transactionSystem.HasItem(this, leftHandLoadout), false) {
        transactionSystem.GiveItem(this, leftHandLoadout, 1);
      };
      transactionSystem.AddItemToSlot(this, t"AttachmentSlots.WeaponLeft", leftHandLoadout);
    };
    if ItemID.IsValid(rightHandLoadout) {
      if Equals(transactionSystem.HasItem(this, rightHandLoadout), false) {
        transactionSystem.GiveItem(this, rightHandLoadout, 1);
      };
      transactionSystem.AddItemToSlot(this, t"AttachmentSlots.WeaponRight", rightHandLoadout);
    };
  }

  public final func GetKiller() -> wref<Entity> {
    return this.m_killer;
  }

  public final func SetKiller(killer: wref<Entity>) -> Void {
    this.m_killer = killer;
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"AIComponent", n"AIHumanComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"movePoliciesComponent", n"MovePoliciesComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"SignalHandler", n"SignalHandlerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"HitReaction", n"HitReactionComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"HitReactionOverride", n"HitReactionComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ReactionManager", n"ReactionManagerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Dismemberment0701", n"DismembermentComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"HitRepresentation", n"SlotComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Interaction", n"InteractionComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Item_Attachment_Slot", n"SlotComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Senses", n"SenseComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"senseVisibleObject", n"VisibleObjectComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"senseSensorObject", n"SensorObjectComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"TargetTracker", n"AITargetTrackerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"NPCStates", n"NPCStatesComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"FxResourceMapper", n"FxResourceMapperComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ResourceLibrary", n"ResourceLibraryComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"CrowdMember", n"CrowdMemberBaseComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"BumpComponent", n"gameinfluenceBumpComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Targeting_LegLeft", n"gameTargetingComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Targeting_Head_Shooting", n"gameTargetingComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Targeting_Chest", n"gameTargetingComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"Targeting_LegRight", n"gameTargetingComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ObjectSelector", n"AIObjectSelectionComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"TransformHistoryComponent", n"entTransformHistoryComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"AnimationControllerComponent", n"entAnimationControllerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"WeakspotComponent", n"gameWeakspotComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"CombatHUDManager", n"CombatHUDManager", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    ArrayClear(this.m_targetingComponentsArray);
    this.m_signalHandlerComponent = EntityResolveComponentsInterface.GetComponent(ri, n"SignalHandler") as AISignalHandlerComponent;
    this.m_hitReactionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"HitReactionOverride") as HitReactionComponent;
    if !IsDefined(this.m_hitReactionComponent) {
      this.m_hitReactionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"HitReaction") as HitReactionComponent;
    };
    this.m_aiController = EntityResolveComponentsInterface.GetComponent(ri, n"AIComponent") as AIHumanComponent;
    this.m_movePolicies = EntityResolveComponentsInterface.GetComponent(ri, n"movePoliciesComponent") as MovePoliciesComponent;
    this.m_reactionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ReactionManager") as ReactionManagerComponent;
    this.m_dismembermentComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Dismemberment0701") as DismembermentComponent;
    this.m_hitRepresantation = EntityResolveComponentsInterface.GetComponent(ri, n"HitRepresentation") as SlotComponent;
    this.m_interactionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Interaction") as InteractionComponent;
    this.m_slotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Item_Attachment_Slot") as SlotComponent;
    this.m_sensesComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Senses") as SenseComponent;
    this.m_visibleObjectComponent = EntityResolveComponentsInterface.GetComponent(ri, n"senseVisibleObject") as VisibleObjectComponent;
    this.m_sensorObjectComponent = EntityResolveComponentsInterface.GetComponent(ri, n"senseSensorObject") as SensorObjectComponent;
    this.m_targetTrackerComponent = EntityResolveComponentsInterface.GetComponent(ri, n"TargetTracker") as TargetTrackerComponent;
    this.m_statesComponent = EntityResolveComponentsInterface.GetComponent(ri, n"NPCStates") as NPCStatesComponent;
    this.m_fxResourceMapper = EntityResolveComponentsInterface.GetComponent(ri, n"FxResourceMapper") as FxResourceMapperComponent;
    this.m_resourceLibraryComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ResourceLibrary") as ResourceLibraryComponent;
    this.m_crowdMemberComponent = EntityResolveComponentsInterface.GetComponent(ri, n"CrowdMember") as CrowdMemberBaseComponent;
    this.m_inventoryComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Inventory") as Inventory;
    this.m_objectSelectionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ObjectSelector") as ObjectSelectionComponent;
    this.m_transformHistoryComponent = EntityResolveComponentsInterface.GetComponent(ri, n"TransformHistoryComponent") as TransformHistoryComponent;
    this.m_animationControllerComponent = EntityResolveComponentsInterface.GetComponent(ri, n"AnimationControllerComponent") as AnimationControllerComponent;
    this.m_bumpComponent = EntityResolveComponentsInterface.GetComponent(ri, n"BumpComponent") as BumpComponent;
    this.m_puppetStateBlackboard = IBlackboard.Create(GetAllBlackboardDefs().PuppetState);
    ArrayPush(this.m_targetingComponentsArray, EntityResolveComponentsInterface.GetComponent(ri, n"Targeting_LegLeft") as TargetingComponent);
    ArrayPush(this.m_targetingComponentsArray, EntityResolveComponentsInterface.GetComponent(ri, n"Targeting_Head_Shooting") as TargetingComponent);
    ArrayPush(this.m_targetingComponentsArray, EntityResolveComponentsInterface.GetComponent(ri, n"Targeting_Chest") as TargetingComponent);
    ArrayPush(this.m_targetingComponentsArray, EntityResolveComponentsInterface.GetComponent(ri, n"Targeting_LegRight") as TargetingComponent);
    this.m_combatHUDManager = EntityResolveComponentsInterface.GetComponent(ri, n"CombatHUDManager") as CombatHUDManager;
    this.m_weakspotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"WeakspotComponent") as WeakspotComponent;
    super.OnTakeControl(ri);
  }

  protected cb func OnGameAttached() -> Bool {
    let aiComponent: ref<AIHumanComponent>;
    let reevaluatePresetEvt: ref<ReevaluatePresetEvent>;
    this.m_isCrowd = this.GetCrowd();
    if !(this.GetPS() as ScriptedPuppetPS).GetWasIncapacitated() {
      aiComponent = this.GetAIControllerComponent();
      if IsDefined(aiComponent) {
        aiComponent.SetBehaviorArgument(n"SpawnPosition", ToVariant(this.GetWorldPosition()));
      };
      this.m_hitHistory = new HitHistory();
      if !this.m_isCrowd {
        this.CreateListeners();
        this.RegisterSubCharacter();
        this.UpdateQuickHackableState(true);
        this.ResolveConnectionWithDeviceSystem();
      };
      reevaluatePresetEvt = new ReevaluatePresetEvent();
      this.QueueEvent(reevaluatePresetEvt);
      this.InitializeBaseInventory();
      this.EquipSavedLoadout();
    };
    this.RefreshCachedDataCharacterTags();
    this.ToggleInteractionLayers();
    if !this.m_isCrowd {
      this.UpdateLootInteraction();
    };
    super.OnGameAttached();
  }

  protected cb func OnDetach() -> Bool {
    let deviceLink: ref<PuppetDeviceLinkPS>;
    this.m_hitHistory = null;
    if !this.IsCrowd() {
      this.UnregisterSubCharacter();
      this.RemoveListeners();
      this.RemoveLink();
      deviceLink = this.GetDeviceLink() as PuppetDeviceLinkPS;
      if IsDefined(deviceLink) {
        deviceLink.NotifyAboutSpottingPlayer(false);
      };
    };
    this.DestroyObjectActionsCallbackController();
    super.OnDetach();
  }

  protected cb func OnEvaluateMinigame(evt: ref<EvaluateMinigame>) -> Bool {
    let entry: wref<JournalOnscreen>;
    let entryUserData: ref<ShardForceSelectionEvent>;
    let fact: CName;
    let factValue: Int32;
    let i: Int32;
    let journalEntry: String;
    let minigameRecord: ref<MinigameAction_Record>;
    let reward: TweakDBID;
    let shardFullscreenJournalEvent: ref<StartHubMenuEvent>;
    let shardUIevent: ref<NotifyShardRead>;
    let shouldLoot: Bool;
    let lootAllID: TweakDBID = t"MinigameAction.NetworkDataMineLootAll";
    let lootAllAdvancedID: TweakDBID = t"MinigameAction.NetworkDataMineLootAllAdvanced";
    let lootAllMasterID: TweakDBID = t"MinigameAction.NetworkDataMineLootAllMaster";
    let baseMoney: Float = 0.00;
    let baseUncommonMaterials: Float = 0.00;
    let baseRareMaterials: Float = 0.00;
    let baseEpicMaterials: Float = 0.00;
    let baseLegendaryMaterials: Float = 0.00;
    let baseShardDropChance: Float = 0.00;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    let minigamePrograms: array<TweakDBID> = FromVariant(evt.minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms));
    if ArraySize(minigamePrograms) > 0 {
      if TDBID.IsValid(evt.reward) {
        RPGManager.GiveReward(this.GetGame(), evt.reward);
      };
      if IsStringValid(evt.journalEntry) {
        GameInstance.GetJournalManager(this.GetGame()).ChangeEntryState(evt.journalEntry, "gameJournalOnscreen", gameJournalEntryState.Active, JournalNotifyOption.Notify);
      };
      if IsNameValid(evt.fact) {
        SetFactValue(this.GetGame(), evt.fact, evt.factValue);
      };
      if evt.showPopup && IsStringValid(evt.journalEntry) {
        entry = GameInstance.GetJournalManager(this.GetGame()).GetEntryByString(evt.journalEntry, "gameJournalOnscreen") as JournalOnscreen;
        if evt.returnToJournal {
          shardFullscreenJournalEvent = new StartHubMenuEvent();
          entryUserData = new ShardForceSelectionEvent();
          entryUserData.m_hash = GameInstance.GetJournalManager(this.GetGame()).GetEntryHash(entry);
          shardFullscreenJournalEvent.SetStartMenu(n"codex", n"shards", entryUserData);
          GameInstance.GetUISystem(this.GetGame()).QueueEvent(shardFullscreenJournalEvent);
        } else {
          GameInstance.GetJournalManager(this.GetGame()).ChangeEntryState(evt.journalEntry, "gameJournalOnscreen", gameJournalEntryState.Active, JournalNotifyOption.Notify);
          shardUIevent = new NotifyShardRead();
          shardUIevent.title = entry.GetTitle();
          shardUIevent.text = entry.GetDescription();
          GameInstance.GetUISystem(this.GetGame()).QueueEvent(shardUIevent);
        };
      };
      i = 0;
      while i < ArraySize(minigamePrograms) {
        if !this.GetItemMinigameAttempted(evt.item) {
          RPGManager.GiveReward(this.GetGame(), t"RPGActionRewards.Hacking", Cast(this.GetEntityID()));
        };
        minigameRecord = TweakDBInterface.GetMinigameActionRecord(minigamePrograms[i]);
        reward = minigameRecord.Reward().GetID();
        if TDBID.IsValid(reward) {
          RPGManager.GiveReward(this.GetGame(), reward);
        };
        journalEntry = minigameRecord.JournalEntry();
        if IsStringValid(journalEntry) {
          GameInstance.GetJournalManager(this.GetGame()).ChangeEntryState(journalEntry, "gameJournalOnscreen", gameJournalEntryState.Active, JournalNotifyOption.Notify);
        };
        fact = minigameRecord.FactName();
        factValue = minigameRecord.FactValue();
        if IsNameValid(fact) {
          SetFactValue(this.GetGame(), fact, factValue);
        };
        if minigameRecord.ShowPopup() && IsStringValid(journalEntry) {
          entry = GameInstance.GetJournalManager(this.GetGame()).GetEntryByString(journalEntry, "gameJournalOnscreen") as JournalOnscreen;
          GameInstance.GetJournalManager(this.GetGame()).ChangeEntryState(journalEntry, "gameJournalOnscreen", gameJournalEntryState.Active, JournalNotifyOption.Notify);
          shardUIevent = new NotifyShardRead();
          shardUIevent.title = entry.GetTitle();
          shardUIevent.text = entry.GetDescription();
          GameInstance.GetUISystem(this.GetGame()).QueueEvent(shardUIevent);
        };
        if minigamePrograms[i] == t"MinigameAction.NetworkLootQ003" {
          TS.GiveItemByTDBID(this, t"Items.BrainMeltLvl2Program", 1);
          GameInstance.GetTelemetrySystem(this.GetGame()).LogItemAcquired(t"Items.BrainMeltLvl2Program", "minigame");
        } else {
          if minigamePrograms[i] == t"MinigameAction.NetworkLootMQ024" {
            TS.GiveItemByTDBID(this, t"Items.MemoryWipeLvl2Program", 1);
            GameInstance.GetTelemetrySystem(this.GetGame()).LogItemAcquired(t"Items.MemoryWipeLvl2Program", "minigame");
          } else {
            if minigamePrograms[i] == t"MinigameAction.NetworkLootMQ015" {
              TS.GiveItemByTDBID(this, t"Items.WeaponMalfunctionLvl3Program", 1);
              GameInstance.GetTelemetrySystem(this.GetGame()).LogItemAcquired(t"Items.WeaponMalfunctionLvl3Program", "minigame");
            } else {
              if minigamePrograms[i] == t"MinigameAction.NetworkLootMQ015Recipe" {
                TS.GiveItemByTDBID(this, t"Items.Recipe_SystemCollapseLvl4Program", 1);
                GameInstance.GetTelemetrySystem(this.GetGame()).LogItemAcquired(t"Items.Recipe_SystemCollapseLvl4Program", "minigame");
              } else {
                if (minigamePrograms[i] == lootAllID || minigamePrograms[i] == lootAllAdvancedID || minigamePrograms[i] == lootAllMasterID) && ItemID.IsValid(evt.item) {
                  if minigamePrograms[i] == lootAllID {
                    baseMoney += 1.00;
                    baseUncommonMaterials += 6.00;
                    baseRareMaterials += 3.00;
                    baseEpicMaterials += 1.00;
                    baseLegendaryMaterials += 0.00;
                  } else {
                    if minigamePrograms[i] == lootAllAdvancedID {
                      baseMoney += 2.00;
                      baseUncommonMaterials += 9.00;
                      baseRareMaterials += 5.00;
                      baseEpicMaterials += 2.00;
                      baseLegendaryMaterials += 1.00;
                      baseShardDropChance += 0.16;
                    } else {
                      if minigamePrograms[i] == lootAllMasterID {
                        baseMoney += 3.00;
                        baseUncommonMaterials += 12.00;
                        baseRareMaterials += 8.00;
                        baseEpicMaterials += 3.00;
                        baseLegendaryMaterials += 2.00;
                        baseShardDropChance += 0.33;
                      };
                    };
                  };
                  shouldLoot = true;
                };
              };
            };
          };
        };
        i += 1;
      };
    };
    if shouldLoot && this.IsPlayer() {
      this.ProcessLootMinigame(baseMoney, baseUncommonMaterials, baseRareMaterials, baseEpicMaterials, baseLegendaryMaterials, baseShardDropChance, TS);
    };
    if ItemID.IsValid(evt.item) {
      GameInstance.GetTransactionSystem(this.GetGame()).RemoveItem(this, evt.item, 1);
    };
  }

  private final func ProcessLootMinigame(baseMoney: Float, baseUncommonMaterials: Float, baseRareMaterials: Float, baseEpicMaterials: Float, baseLegendaryMaterials: Float, baseShardDropChance: Float, TS: ref<TransactionSystem>) -> Void {
    let dataTrackingEvent: ref<UpdateShardFailedDropsRequest>;
    let dropChance: Float;
    let queryID: TweakDBID;
    let moneyModifier: Float = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.MinigameMoneyMultiplier);
    let shardDropChanceModifier: Float = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.MinigameShardChanceMultiplier);
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    let powerLevel: Float = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.PowerLevel);
    let maxLevel: Float = TweakDBInterface.GetStatRecord(t"BaseStats.PowerLevel").Max();
    if powerLevel <= 0.17 * maxLevel {
      queryID = t"Query.Tier1SoftwareShard";
    } else {
      if powerLevel > 0.17 * maxLevel && powerLevel <= 0.33 * maxLevel {
        queryID = t"Query.Tier2SoftwareShard";
      } else {
        if powerLevel > 0.33 * maxLevel && powerLevel <= 0.67 * maxLevel {
          queryID = t"Query.Tier3SoftwareShard";
        } else {
          queryID = t"Query.Tier4SoftwareShard";
        };
      };
    };
    dropChance = RandRangeF(0.00, 1.00);
    dataTrackingEvent = new UpdateShardFailedDropsRequest();
    dropChance -= dataTrackingSystem.GetFailedShardDrops() * 0.10;
    if dropChance > 0.00 && dropChance < baseShardDropChance * shardDropChanceModifier {
      TS.GiveItemByItemQuery(this, queryID, 1u, 18446744073709551615u, "minigame");
      dataTrackingEvent.resetCounter = true;
    } else {
      dataTrackingEvent.newFailedAttempts = 1.00;
    };
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem").QueueRequest(dataTrackingEvent);
    this.GenerateMaterialDrops(baseUncommonMaterials, baseRareMaterials, baseEpicMaterials, baseLegendaryMaterials, TS);
    if baseMoney >= 1.00 {
      RPGManager.GiveReward(this.GetGame(), t"QuestRewards.MinigameMoneyVeryLow", Cast(this.GetEntityID()), baseMoney * moneyModifier);
    };
  }

  private final func GenerateMaterialDrops(baseUncommonMaterials: Float, baseRareMaterials: Float, baseEpicMaterials: Float, baseLegendaryMaterials: Float, TS: ref<TransactionSystem>) -> Void {
    let dropChanceMaterial: Float;
    let materialsAmmountEpic: Int32;
    let materialsAmmountLeg: Int32;
    let materialsAmmountRare: Int32;
    let materialsMultiplier: Float = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.MinigameMaterialsEarned);
    let materialsAmmountUnc: Int32 = RandRange(Cast(baseUncommonMaterials) / 3, Cast(baseUncommonMaterials) + 1);
    TS.GiveItemByItemQuery(this, t"Query.QuickHackUncommonMaterial", Cast(RoundMath(Cast(materialsAmmountUnc) * materialsMultiplier)));
    materialsAmmountRare = RandRange(Cast(baseRareMaterials) / 3, Cast(baseRareMaterials) + 1);
    TS.GiveItemByItemQuery(this, t"Query.QuickHackRareMaterial", Cast(RoundMath(Cast(materialsAmmountRare) * materialsMultiplier)));
    materialsAmmountEpic = RandRange(Cast(baseEpicMaterials) / 2, Cast(baseEpicMaterials) + 1);
    TS.GiveItemByItemQuery(this, t"Query.QuickHackEpicMaterial", Cast(RoundMath(Cast(materialsAmmountEpic) * materialsMultiplier)));
    dropChanceMaterial = RandF() * materialsMultiplier;
    if dropChanceMaterial > 0.33 - 0.05 * baseLegendaryMaterials {
      materialsAmmountLeg = RandRange(Cast(baseLegendaryMaterials) / 2, Cast(baseLegendaryMaterials) + 1);
      TS.GiveItemByItemQuery(this, t"Query.QuickHackLegendaryMaterial", Cast(RoundMath(Cast(materialsAmmountLeg) * materialsMultiplier)));
    };
  }

  public final const func GetWeakspotComponent() -> ref<WeakspotComponent> {
    return this.m_weakspotComponent;
  }

  protected func Update(dt: Float) -> Void;

  private final func UpdateQuickHackableState(isQuickHackable: Bool) -> Void {
    let evt: ref<SetQuickHackableMask> = new SetQuickHackableMask();
    evt.isQuickHackable = isQuickHackable;
    this.QueueEvent(evt);
  }

  public final func GetCooldownStorage() -> ref<CooldownStorage> {
    return (this.GetPS() as ScriptedPuppetPS).GetCooldownStorage();
  }

  public final func GetItemMinigameAttempted(itemID: ItemID) -> Bool {
    return ArrayContains(this.m_attemptedShards, itemID);
  }

  public final func SetItemMinigameAttempted(itemID: ItemID) -> Void {
    ArrayPush(this.m_attemptedShards, itemID);
  }

  public final func GetLinkedStatusEffect() -> LinkedStatusEffect {
    return this.m_linkedStatusEffect;
  }

  public final func AddLinkedStatusEffect(netrunner: EntityID, target: EntityID, opt actionEffects: array<wref<ObjectActionEffect_Record>>) -> Void {
    let i: Int32;
    ArrayPush(this.m_linkedStatusEffect.netrunnerIDs, netrunner);
    this.m_linkedStatusEffect.targetID = target;
    i = 0;
    while i < ArraySize(actionEffects) {
      ArrayPush(this.m_linkedStatusEffect.statusEffectList, actionEffects[i].StatusEffect().GetID());
      i += 1;
    };
  }

  public final func RemoveLinkedStatusEffects(opt ssAction: Bool) -> Bool {
    let targetPuppet: wref<ScriptedPuppet>;
    if EntityID.IsDefined(this.m_linkedStatusEffect.targetID) {
      targetPuppet = GameInstance.FindEntityByID(this.GetGame(), this.m_linkedStatusEffect.targetID) as ScriptedPuppet;
      if IsDefined(targetPuppet) {
        targetPuppet.RemoveLinkedStatusEffectsFromTarget(this.GetEntityID(), ssAction);
        this.ClearLinkedStatusEffect();
      };
    };
    this.RemoveLink();
    return true;
  }

  private final func ClearLinkedStatusEffect() -> Void {
    let emptyID: EntityID;
    ArrayClear(this.m_linkedStatusEffect.netrunnerIDs);
    ArrayClear(this.m_linkedStatusEffect.statusEffectList);
    this.m_linkedStatusEffect.targetID = emptyID;
  }

  public final func RemoveLinkedStatusEffectsFromTarget(sourceID: EntityID, opt ssAction: Bool) -> Bool {
    let i: Int32;
    if (ArrayContains(this.m_linkedStatusEffect.netrunnerIDs, sourceID) || ssAction) && this.m_linkedStatusEffect.targetID == this.GetEntityID() {
      if ArraySize(this.m_linkedStatusEffect.netrunnerIDs) == 1 {
        i = 0;
        while i < ArraySize(this.m_linkedStatusEffect.statusEffectList) {
          StatusEffectHelper.RemoveStatusEffect(this, this.m_linkedStatusEffect.statusEffectList[i]);
          i += 1;
        };
        this.ClearLinkedStatusEffect();
        StatusEffectHelper.RemoveStatusEffect(this, t"AIQuickHackStatusEffect.BeingHacked");
      } else {
        ArrayRemove(this.m_linkedStatusEffect.netrunnerIDs, sourceID);
        AIActionHelper.UpdateLinkedStatusEffects(this, this.m_linkedStatusEffect);
      };
    };
    return true;
  }

  public final func RemoveLink() -> Void {
    let attackAttemptEvent: ref<AIAttackAttemptEvent>;
    let netrunner: ref<GameObject>;
    let netrunnerID: EntityID;
    let proxy: ref<GameObject>;
    let proxyID: EntityID;
    let target: ref<GameObject>;
    let targetID: EntityID;
    let bb: ref<IBlackboard> = this.GetAIControllerComponent().GetActionBlackboard();
    if !IsDefined(bb) {
      return;
    };
    netrunnerID = FromVariant(bb.GetVariant(GetAllBlackboardDefs().AIAction.netrunner));
    if !EntityID.IsDefined(netrunnerID) {
      return;
    };
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestRemovingStatPool(Cast(netrunnerID), gamedataStatPoolType.QuickHackUpload);
    targetID = FromVariant(bb.GetVariant(GetAllBlackboardDefs().AIAction.netrunnerTarget));
    if !EntityID.IsDefined(targetID) {
      return;
    };
    proxyID = FromVariant(bb.GetVariant(GetAllBlackboardDefs().AIAction.netrunnerProxy));
    if EntityID.IsDefined(proxyID) {
      (this.GetPS() as ScriptedPuppetPS).DrawBetweenEntities(false, true, this.GetFxResourceByKey(n"pingNetworkLink"), netrunnerID, proxyID, false, false);
      (this.GetPS() as ScriptedPuppetPS).DrawBetweenEntities(false, true, this.GetFxResourceByKey(n"pingNetworkLink"), proxyID, targetID, false, false);
      this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", false, 0.00, netrunnerID);
      this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", false, 0.00, proxyID);
      proxy = GameInstance.FindEntityByID(this.GetGame(), proxyID) as GameObject;
    } else {
      (this.GetPS() as ScriptedPuppetPS).DrawBetweenEntities(false, true, this.GetFxResourceByKey(n"pingNetworkLink"), netrunnerID, targetID, false, false);
      this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", false, 0.00, netrunnerID);
    };
    netrunner = GameInstance.FindEntityByID(this.GetGame(), netrunnerID) as GameObject;
    target = GameInstance.FindEntityByID(this.GetGame(), targetID) as GameObject;
    if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(targetID), gamedataStatType.RevealNetrunnerWhenHacked) == 1.00 {
      ScriptedPuppet.ForceVisionAppearanceNetrunner(netrunner, netrunnerID, n"EnemyNetrunner", false);
      if IsDefined(proxy) {
        ScriptedPuppet.ForceVisionAppearanceNetrunner(proxy, netrunnerID, n"EnemyNetrunner", false);
      };
    };
    attackAttemptEvent = new AIAttackAttemptEvent();
    attackAttemptEvent.instigator = netrunner;
    attackAttemptEvent.continuousMode = gameEContinuousMode.Stop;
    if IsDefined(target) {
      attackAttemptEvent.target = target;
      target.QueueEvent(attackAttemptEvent);
      if IsDefined(netrunner) {
        netrunner.QueueEvent(attackAttemptEvent);
      };
      StatusEffectHelper.RemoveStatusEffect(target, t"AIQuickHackStatusEffect.BeingHacked");
    } else {
      if IsDefined(netrunner) {
        attackAttemptEvent.target = netrunner;
        netrunner.QueueEvent(attackAttemptEvent);
      };
    };
  }

  protected cb func OnExitShapeEvent(evt: ref<ExitShapeEvent>) -> Bool {
    let distanceToTarget: Float;
    if evt.shapeId == t"Senses.NetrunnerConnectionShape" && evt.target.IsPlayer() {
      distanceToTarget = Vector4.Distance(this.GetWorldPosition(), evt.target.GetWorldPosition());
      if distanceToTarget > 60.00 {
        this.RemoveLinkedStatusEffects();
        StatusEffectHelper.ApplyStatusEffect(this, t"AIQuickHackStatusEffect.HackingInterrupted", this.GetEntityID());
      };
    };
  }

  private final func ToggleInteractionLayers() -> Void {
    let canGrappleCivilian: Bool = TweakDBInterface.GetBool(t"player.grapple.canGrappleCivilian", true);
    if this.IsCrowd() {
      if this.GetRecord().CanHaveGenericTalk() {
        this.EnableInteraction(n"GenericTalk", true);
      };
      this.EnableInteraction(n"Grapple", false);
      this.EnableInteraction(n"TakedownLayer", false);
      this.EnableInteraction(n"AerialTakedown", false);
    } else {
      if this.IsCharacterCivilian() && !canGrappleCivilian {
        this.EnableInteraction(n"Grapple", false);
        this.EnableInteraction(n"TakedownLayer", false);
        this.EnableInteraction(n"AerialTakedown", false);
      } else {
        if this.IsBoss() {
          if !this.IsCharacterCyberpsycho() {
            this.EnableInteraction(n"BossTakedownLayer", true);
            this.EnableInteraction(n"Grapple", false);
            this.EnableInteraction(n"TakedownLayer", false);
            this.EnableInteraction(n"AerialTakedown", false);
          };
        } else {
          if this.IsMassive() {
            this.EnableInteraction(n"MassiveTargetTakedownLayer", true);
            this.EnableInteraction(n"Grapple", false);
            this.EnableInteraction(n"TakedownLayer", false);
            this.EnableInteraction(n"AerialTakedown", false);
          } else {
            if this.GetRecord().ForceCanHaveGenericTalk() {
              this.EnableInteraction(n"GenericTalk", true);
            } else {
              if this.IsVendor() {
                this.EnableInteraction(n"Grapple", false);
                this.EnableInteraction(n"TakedownLayer", false);
                this.EnableInteraction(n"AerialTakedown", false);
              };
            };
          };
        };
      };
    };
  }

  protected func CreateListeners() -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(GetGameInstance());
    blackboardSystem.RegisterLocalBlackboard(this.m_puppetStateBlackboard);
    blackboardSystem.RegisterLocalBlackboardForDebugRender(this.m_puppetStateBlackboard, "PuppetState: " + EntityID.ToDebugString(this.GetEntityID()));
  }

  protected func RemoveListeners() -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(GetGameInstance());
    blackboardSystem.UnregisterLocalBlackboard(this.m_puppetStateBlackboard);
  }

  public final static func CreateCustomBlackboard(obj: ref<GameObject>, blackboard: ref<IBlackboard>) -> Void {
    let evt: ref<CreateCustomBlackboardEvent> = new CreateCustomBlackboardEvent();
    evt.m_blackboard = blackboard;
    obj.QueueEvent(evt);
  }

  public final static func CreateCustomBlackboardFromDef(obj: ref<GameObject>, blackboardDef: ref<CustomBlackboardDef>) -> Void {
    let evt: ref<CreateCustomBlackboardEvent> = new CreateCustomBlackboardEvent();
    evt.m_blackboardDef = blackboardDef;
    obj.QueueEvent(evt);
  }

  public final func GetMasterConnectedClassTypes() -> ConnectedClassTypes {
    return (this.GetPS() as ScriptedPuppetPS).CheckMasterConnectedClassTypes();
  }

  protected cb func OnCreateCustomBlackboard(evt: ref<CreateCustomBlackboardEvent>) -> Bool {
    if IsDefined(this.m_customBlackboard) {
      LogPuppet("ERORR: Trying to create cusotmBlackboard when it already exists!");
    };
    if IsDefined(evt.m_blackboard) {
      this.m_customBlackboard = evt.m_blackboard;
    } else {
      this.m_customBlackboard = IBlackboard.Create(evt.m_blackboardDef);
    };
  }

  public final const func GetCustomBlackboard() -> ref<IBlackboard> {
    return this.m_customBlackboard;
  }

  public final static func AddListener(obj: ref<GameObject>, listener: ref<PuppetListener>) -> Void {
    let evt: ref<AddOrRemoveListenerEvent> = new AddOrRemoveListenerEvent();
    evt.listener = listener;
    evt.add = true;
    obj.QueueEvent(evt);
  }

  public final static func RemoveListener(obj: ref<GameObject>, listener: ref<PuppetListener>) -> Void {
    let evt: ref<AddOrRemoveListenerEvent> = new AddOrRemoveListenerEvent();
    evt.listener = listener;
    obj.QueueEvent(evt);
  }

  protected cb func OnAddOrRemoveListener(evt: ref<AddOrRemoveListenerEvent>) -> Bool {
    if evt.add {
      ArrayPush(this.m_listeners, evt.listener);
    } else {
      ArrayRemove(this.m_listeners, evt.listener);
    };
  }

  public final func NotifyHitReactionTypeChanged(hitType: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_listeners) {
      this.m_listeners[i].OnHitReactionTypeChanged(hitType);
      i += 1;
    };
  }

  public final func NotifyHitReactionSourceChanged(hitSource: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_listeners) {
      this.m_listeners[i].OnHitReactionSourceChanged(hitSource);
      i += 1;
    };
  }

  public final const func GetAIControllerComponent() -> ref<AIHumanComponent> {
    return this.m_aiController;
  }

  public final const func GetMovePolicesComponent() -> ref<MovePoliciesComponent> {
    return this.m_movePolicies;
  }

  public final const func GetSignalHandlerComponent() -> ref<AISignalHandlerComponent> {
    return this.m_signalHandlerComponent;
  }

  public final const func GetHitReactionComponent() -> ref<HitReactionComponent> {
    return this.m_hitReactionComponent;
  }

  public final const func GetStimReactionComponent() -> ref<ReactionManagerComponent> {
    return this.m_reactionComponent;
  }

  public final const func GetDismembermentComponent() -> ref<DismembermentComponent> {
    return this.m_dismembermentComponent;
  }

  public final const func GetCrowdMemberComponent() -> ref<CrowdMemberBaseComponent> {
    return this.m_crowdMemberComponent;
  }

  public const func GetTargetTrackerComponent() -> ref<TargetTrackerComponent> {
    return this.m_targetTrackerComponent;
  }

  public final const func GetTargetTrackingExension() -> ref<TargetTrackingExtension> {
    return this.m_targetTrackerComponent as TargetTrackingExtension;
  }

  public final const func GetObjectSelectionComponent() -> ref<ObjectSelectionComponent> {
    return this.m_objectSelectionComponent;
  }

  public final const func GetPuppetStateBlackboard() -> ref<IBlackboard> {
    return this.m_puppetStateBlackboard;
  }

  public final const func GetHitRepresantationSlotComponent() -> ref<SlotComponent> {
    return this.m_hitRepresantation;
  }

  public final const func GetSlotComponent() -> ref<SlotComponent> {
    return this.m_slotComponent;
  }

  public final const func GetCombatHUDManagerComponent() -> ref<CombatHUDManager> {
    return this.m_combatHUDManager;
  }

  public const func GetSensesComponent() -> ref<SenseComponent> {
    return this.m_sensesComponent;
  }

  public final const func GetVisibleObjectComponent() -> ref<VisibleObjectComponent> {
    return this.m_visibleObjectComponent;
  }

  public final const func GetSensorObjectComponent() -> ref<SensorObjectComponent> {
    return this.m_sensorObjectComponent;
  }

  public const func GetAttitudeAgent() -> ref<AttitudeAgent> {
    return this.GetAttitude();
  }

  public final const func GetStatesComponent() -> ref<NPCStatesComponent> {
    return this.m_statesComponent;
  }

  public final const func GetBumpComponent() -> ref<BumpComponent> {
    return this.m_bumpComponent;
  }

  public final const func GetSignalTable() -> ref<gameBoolSignalTable> {
    return this.GetAIControllerComponent().GetSignals();
  }

  public final const func GetTransformHistoryComponent() -> ref<TransformHistoryComponent> {
    return this.m_transformHistoryComponent;
  }

  public final const func GetAnimationControllerComponent() -> ref<AnimationControllerComponent> {
    return this.m_animationControllerComponent;
  }

  public final const func GetAreIncomingSecuritySystemEventsSuppressed() -> Bool {
    return (this.GetDeviceLink() as PuppetDeviceLinkPS).AreIncomingEventsSuppressed();
  }

  public final const func GetRecord() -> ref<Character_Record> {
    return TweakDBInterface.GetCharacterRecord(this.GetRecordID());
  }

  public final const func GetNPCType() -> gamedataNPCType {
    return this.GetRecord().CharacterType().Type();
  }

  public final const func IsAndroid() -> Bool {
    return Equals(this.GetRecord().CharacterType().Type(), gamedataNPCType.Android);
  }

  public final const func IsHuman() -> Bool {
    return Equals(this.GetRecord().CharacterType().Type(), gamedataNPCType.Human);
  }

  public final const func IsHumanoid() -> Bool {
    let npcType: gamedataNPCType = this.GetRecord().CharacterType().Type();
    return Equals(npcType, gamedataNPCType.Human) || Equals(npcType, gamedataNPCType.Android);
  }

  public final const func IsMechanical() -> Bool {
    let npcType: gamedataNPCType = this.GetRecord().CharacterType().Type();
    return Equals(npcType, gamedataNPCType.Android) || Equals(npcType, gamedataNPCType.Drone) || Equals(npcType, gamedataNPCType.Mech);
  }

  public final static func IsMechanical(self: wref<ScriptedPuppet>) -> Bool {
    let npcType: gamedataNPCType = self.GetRecord().CharacterType().Type();
    return Equals(npcType, gamedataNPCType.Android) || Equals(npcType, gamedataNPCType.Drone) || Equals(npcType, gamedataNPCType.Mech);
  }

  public final const func GetNPCRarity() -> gamedataNPCRarity {
    return this.GetRecord().Rarity().Type();
  }

  protected const func GetPS() -> ref<GameObjectPS> {
    return this.GetBasePS();
  }

  public final const func GetPuppetPS() -> ref<ScriptedPuppetPS> {
    return this.GetBasePS() as ScriptedPuppetPS;
  }

  public final const func GetHighLevelStateFromBlackboard() -> gamedataNPCHighLevelState {
    return IntEnum(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
  }

  public final const func GetUpperBodyStateFromBlackboard() -> gamedataNPCUpperBodyState {
    return IntEnum(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.UpperBody));
  }

  public final const func GetDefenseModeStateFromBlackboard() -> gamedataDefenseMode {
    return IntEnum(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.DefenseMode));
  }

  public final const func GetStanceStateFromBlackboard() -> gamedataNPCStanceState {
    return IntEnum(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.Stance));
  }

  public final const func GetHitReactionModeFromBlackboard() -> EHitReactionMode {
    return IntEnum(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.HitReactionMode));
  }

  public final const func GetCurrentWorkspotTags() -> array<CName> {
    return this.m_currentWorkspotTags;
  }

  public final const func HasWorkspotTag(tag: CName) -> Bool {
    return ArrayContains(this.m_currentWorkspotTags, tag);
  }

  public const func IsPuppet() -> Bool {
    return true;
  }

  public final const func IsOfficer() -> Bool {
    return Equals(this.GetPuppetRarity().Type(), gamedataNPCRarity.Officer);
  }

  private final func RegisterSubCharacter() -> Void {
    let addSubCharacterRequest: ref<AddSubCharacterRequest>;
    let scs: ref<SubCharacterSystem>;
    if IsDefined(TweakDBInterface.GetSubCharacterRecord(this.GetRecordID())) {
      scs = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"SubCharacterSystem") as SubCharacterSystem;
      if IsDefined(scs) {
        addSubCharacterRequest = new AddSubCharacterRequest();
        addSubCharacterRequest.subCharObject = this;
        scs.QueueRequest(addSubCharacterRequest);
      };
    };
  }

  private final func UnregisterSubCharacter() -> Void {
    let removeSubCharacterRequest: ref<RemoveSubCharacterRequest>;
    let scs: ref<SubCharacterSystem>;
    if IsDefined(TweakDBInterface.GetSubCharacterRecord(this.GetRecordID())) {
      scs = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"SubCharacterSystem") as SubCharacterSystem;
      if IsDefined(scs) {
        removeSubCharacterRequest = new RemoveSubCharacterRequest();
        removeSubCharacterRequest.subCharType = TweakDBInterface.GetSubCharacterRecord(this.GetRecordID()).Type();
        scs.QueueRequest(removeSubCharacterRequest);
      };
    };
  }

  public final static func CanRagdoll(obj: wref<GameObject>) -> Bool {
    let puppet: wref<ScriptedPuppet>;
    if !IsDefined(obj) || !obj.IsPuppet() {
      return false;
    };
    puppet = obj as ScriptedPuppet;
    if !puppet.CanRagdoll() {
      return false;
    };
    if puppet.IsBoss() && !(puppet.GetPS() as ScriptedPuppetPS).GetWasIncapacitated() {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(puppet, t"WorkspotStatus.Death") {
      return false;
    };
    if puppet.HasWorkspotTag(n"FinisherWorkspot") {
      return false;
    };
    if NotEquals(puppet.GetNPCType(), gamedataNPCType.Drone) && VehicleComponent.IsMountedToVehicle(puppet.GetGame(), puppet) {
      return false;
    };
    return true;
  }

  public final static func CanTripOverRagdolls(obj: wref<GameObject>) -> Bool {
    let puppet: wref<ScriptedPuppet>;
    if !IsDefined(obj) || !obj.IsPuppet() {
      return false;
    };
    puppet = obj as ScriptedPuppet;
    if !puppet.CanRagdoll() {
      return false;
    };
    if NotEquals(puppet.GetNPCType(), gamedataNPCType.Human) {
      return false;
    };
    if VehicleComponent.IsMountedToVehicle(puppet.GetGame(), puppet) {
      return false;
    };
    if puppet.IsBoss() || puppet.IsMassive() || Equals(puppet.GetPuppetRarity().Type(), gamedataNPCRarity.Elite) {
      return false;
    };
    if NPCPuppet.IsUnstoppable(puppet) {
      return false;
    };
    return true;
  }

  public final static func IsBoss(obj: wref<GameObject>) -> Bool {
    if !IsDefined(obj) || !obj.IsPuppet() {
      return false;
    };
    return (obj as ScriptedPuppet).IsBoss();
  }

  public final const func IsBoss() -> Bool {
    return Equals(this.GetPuppetRarity().Type(), gamedataNPCRarity.Boss);
  }

  public final const func IsMassive() -> Bool {
    if NPCManager.HasVisualTag(this, n"Sumo") {
      return true;
    };
    if NPCManager.HasVisualTag(this, n"ManMassive") {
      return true;
    };
    return false;
  }

  public const func IsDrone() -> Bool {
    return Equals(this.GetNPCType(), gamedataNPCType.Drone);
  }

  public final const func IsVendor() -> Bool {
    let character: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
    if IsDefined(character) && IsDefined(character.VendorID()) {
      return TDBID.IsValid(character.VendorID().GetID());
    };
    return false;
  }

  public final const func GetVendorType() -> gamedataVendorType {
    if this.IsVendor() {
      return TweakDBInterface.GetCharacterRecord(this.GetRecordID()).VendorID().VendorType().Type();
    };
    return gamedataVendorType.Invalid;
  }

  public final func RefreshCachedReactionPresetData() -> Void {
    let reactionPresetGroup: String = AIActionHelper.GetReactionPresetGroup(this);
    this.m_isCivilian = Equals(reactionPresetGroup, "Civilian");
    this.m_isPolice = Equals(reactionPresetGroup, "Police");
    this.m_isGanger = Equals(reactionPresetGroup, "Ganger");
  }

  public final func RefreshCachedDataCharacterTags() -> Void {
    let characterRecordId: TweakDBID = this.GetRecordID();
    if this.IsCrowd() {
      this.m_isCyberpsycho = false;
    } else {
      this.m_isCyberpsycho = NPCManager.HasTag(characterRecordId, n"Cyberpsycho");
    };
  }

  public final const func IsCharacterCyberpsycho() -> Bool {
    return this.m_isCyberpsycho;
  }

  public final const func IsCharacterCivilian() -> Bool {
    return this.m_isCivilian;
  }

  public final const func IsCharacterPolice() -> Bool {
    return this.m_isPolice;
  }

  public final const func IsCharacterGanger() -> Bool {
    return this.m_isGanger;
  }

  public final const func IsCharacterChildren() -> Bool {
    if !IsDefined(this.GetStimReactionComponent()) || !IsDefined(this.GetStimReactionComponent().GetReactionPreset()) {
      return false;
    };
    return Equals(this.GetStimReactionComponent().GetReactionPreset().Type(), gamedataReactionPresetType.Child);
  }

  private final const func GetCrowd() -> Bool {
    return this.GetRecord().IsCrowd() || this.GetBlackboard().GetBool(GetAllBlackboardDefs().Puppet.IsCrowd);
  }

  public final const func IsCrowd() -> Bool {
    return this.m_isCrowd;
  }

  private final func SetWasIncapacitatedOnAttach(value: Bool) -> Void {
    this.m_incapacitatedOnAttach = value;
  }

  public final const func WasIncapacitatedOnAttach() -> Bool {
    return this.m_incapacitatedOnAttach;
  }

  public final const func AwardsExperience() -> Bool {
    return !this.IsCrowd() && !this.IsPrevention();
  }

  public final static func IsAlive(const obj: ref<GameObject>) -> Bool {
    if !IsDefined(obj) || !obj.IsAttached() {
      return false;
    };
    return !obj.IsDeadNoStatPool();
  }

  public final static func IsDefeated(const obj: ref<GameObject>) -> Bool {
    if !IsDefined(obj) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(obj, gamedataStatusEffectType.Defeated) {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(obj, gamedataStatusEffectType.DefeatedWithRecover) {
      return true;
    };
    return false;
  }

  public final static func IsUnconscious(const obj: ref<GameObject>) -> Bool {
    if !IsDefined(obj) {
      return false;
    };
    return StatusEffectSystem.ObjectHasStatusEffectOfType(obj, gamedataStatusEffectType.Unconscious);
  }

  public final static func EvaluateApplyingStatusEffectsFromMountedObjectToPlayer(npc: wref<GameObject>, player: wref<GameObject>) -> Void {
    let appliedEffects: array<ref<StatusEffect>>;
    let effectID: TweakDBID;
    let effectType: gamedataStatusEffectType;
    let i: Int32;
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(npc.GetGame()).GetMountingInfoSingleWithObjects(npc);
    if !EntityID.IsDefined(mountingInfo.childId) {
      return;
    };
    appliedEffects = StatusEffectHelper.GetAppliedEffects(npc);
    i = 0;
    while i < ArraySize(appliedEffects) {
      effectType = appliedEffects[i].GetRecord().StatusEffectType().Type();
      if Equals(effectType, gamedataStatusEffectType.Burning) {
        effectID = t"BaseStatusEffect.PlayerBurning";
        StatusEffectHelper.ApplyStatusEffect(player, effectID, npc.GetEntityID());
      } else {
        if Equals(effectType, gamedataStatusEffectType.Electrocuted) {
          effectID = t"BaseStatusEffect.PlayerElectrocuted";
          StatusEffectHelper.ApplyStatusEffect(player, effectID, npc.GetEntityID());
        };
      };
      i += 1;
    };
  }

  public final static func IsNanoWireHacked(const obj: ref<GameObject>) -> Bool {
    let objID: EntityID = obj.GetEntityID();
    return GameInstance.GetStatusEffectSystem(obj.GetGame()).HasStatusEffect(objID, t"BaseStatusEffect.MonowireGrapple");
  }

  public final static func IsActive(obj: ref<GameObject>) -> Bool {
    let puppet: ref<ScriptedPuppet> = obj as ScriptedPuppet;
    if IsDefined(puppet) {
      return puppet.IsActive();
    };
    return ScriptedPuppet.IsAlive(obj) && !ScriptedPuppet.IsDefeated(obj) && !ScriptedPuppet.IsTurnedOff(obj);
  }

  public final static func IsTurnedOff(obj: ref<GameObject>) -> Bool {
    let objID: EntityID;
    if !IsDefined(obj) {
      return false;
    };
    objID = obj.GetEntityID();
    if !EntityID.IsDefined(objID) {
      return false;
    };
    return GameInstance.GetStatusEffectSystem(obj.GetGame()).HasStatusEffect(objID, t"BaseStatusEffect.AndroidTurnOff");
  }

  public final const func IsTurnedOffNoStatusEffect() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).GetIsAndroidTurnedOff();
  }

  private final const func IsActiveInternal() -> Bool {
    return !this.IsDeadNoStatPool() && !this.IsIncapacitated() && !this.IsTurnedOffNoStatusEffect() && !ScriptedPuppet.IsDefeated(this);
  }

  public const func IsActive() -> Bool {
    let isActive: Bool;
    let puppet: ref<ScriptedPuppet>;
    if CachedBoolValue.GetIfNotDirty(this.m_isActiveCached, isActive) {
      return isActive;
    };
    puppet = EntityGameInterface.GetEntity(this.GetEntity()) as ScriptedPuppet;
    if puppet != null {
      isActive = puppet.IsActiveInternal();
    } else {
      isActive = false;
    };
    CachedBoolValue.Set(this.m_isActiveCached, isActive);
    return isActive;
  }

  public const func IsPrevention() -> Bool {
    return this.IsCharacterPolice();
  }

  public const func IsDead() -> Bool {
    let objectID: StatsObjectID = Cast(this.GetEntityID());
    return GameInstance.GetStatPoolsSystem(this.GetGame()).HasStatPoolValueReachedMin(objectID, gamedataStatPoolType.Health);
  }

  public const func IsDeadNoStatPool() -> Bool {
    return this.GetPuppetPS().GetIsDead();
  }

  public final const func GetReactionPresetID() -> TweakDBID {
    return (this.GetPS() as ScriptedPuppetPS).GetReactionPresetID();
  }

  public final func SetReactionPresetID(presetID: TweakDBID) -> Void {
    (this.GetPS() as ScriptedPuppetPS).SetReactionPresetID(presetID);
  }

  public final const func IsAggressive() -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffect(this, t"GameplayRestriction.FistFight") {
      return true;
    };
    if !IsDefined(this.m_reactionComponent) {
      return false;
    };
    if IsDefined(this.m_reactionComponent.GetReactionPreset()) {
      if this.m_reactionComponent.GetReactionPreset().IsAggressive() {
        return true;
      };
    };
    return false;
  }

  public final const func IsOnAutonomousAI() -> Bool {
    let returnValue: Bool;
    if IsDefined(this.m_aiController) {
      returnValue = Equals(this.m_aiController.GetStoryTier(), gameStoryTier.Gameplay);
    } else {
      returnValue = false;
    };
    return returnValue;
  }

  public final static func IsDeaf(obj: wref<GameObject>) -> Bool {
    if !IsDefined(obj) {
      return false;
    };
    if GameInstance.GetStatusEffectSystem(obj.GetGame()).HasStatusEffectWithTag(obj.GetEntityID(), n"Deaf") {
      return true;
    };
    return false;
  }

  public final static func IsBlinded(obj: wref<GameObject>) -> Bool {
    if !IsDefined(obj) {
      return false;
    };
    if GameInstance.GetStatusEffectSystem(obj.GetGame()).HasStatusEffectWithTag(obj.GetEntityID(), n"Blind") {
      return true;
    };
    return false;
  }

  public final static func IsBeingGrappled(obj: wref<GameObject>) -> Bool {
    let mountingInfo: MountingInfo;
    if !IsDefined(obj) {
      return false;
    };
    if GameInstance.GetStatusEffectSystem(obj.GetGame()).HasStatusEffect(obj.GetEntityID(), t"BaseStatusEffect.Grappled") {
      return true;
    };
    mountingInfo = GameInstance.GetMountingFacility(obj.GetGame()).GetMountingInfoSingleWithObjects(obj);
    if !EntityID.IsDefined(mountingInfo.childId) {
      return false;
    };
    if NotEquals(mountingInfo.slotId.id, n"grapple") {
      return false;
    };
    return true;
  }

  public final static func GetGrappleParent(obj: wref<GameObject>) -> wref<GameObject> {
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(obj.GetGame()).GetMountingInfoSingleWithObjects(obj);
    let parentObj: wref<GameObject> = GameInstance.FindEntityByID(obj.GetGame(), mountingInfo.parentId) as GameObject;
    return parentObj;
  }

  public final static func GetGrappleChild(obj: wref<GameObject>) -> wref<GameObject> {
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(obj.GetGame()).GetMountingInfoSingleWithObjects(obj);
    let childObj: wref<GameObject> = GameInstance.FindEntityByID(obj.GetGame(), mountingInfo.childId) as GameObject;
    return childObj;
  }

  public final static func IsOnOffMeshLink(obj: wref<GameObject>) -> Bool {
    return (obj as ScriptedPuppet).GetMovePolicesComponent().IsOnOffMeshLink();
  }

  public const func CanBeTagged() -> Bool {
    if this.IsCrowd() || this.IsCharacterCivilian() {
      return false;
    };
    if !this.IsActive() && !this.IsContainer() {
      return false;
    };
    if GameObject.IsFriendlyTowardsPlayer(this) {
      return false;
    };
    return true;
  }

  public const func IsPlayerCompanion() -> Bool {
    if IsDefined(this.GetAIControllerComponent()) {
      return this.GetAIControllerComponent().IsPlayerCompanion();
    };
    return false;
  }

  public final static func IsPlayerCompanion(obj: wref<GameObject>) -> Bool {
    let scriptedPuppet: ref<ScriptedPuppet> = obj as ScriptedPuppet;
    if IsDefined(scriptedPuppet) {
      return scriptedPuppet.IsPlayerCompanion();
    };
    return false;
  }

  public final static func IsPlayerCompanion(obj: wref<GameObject>, out companion: wref<GameObject>) -> Bool {
    let scriptedPuppet: ref<ScriptedPuppet> = obj as ScriptedPuppet;
    if IsDefined(scriptedPuppet) && IsDefined(scriptedPuppet.GetAIControllerComponent()) {
      if scriptedPuppet.GetAIControllerComponent().GetFriendlyTarget(companion) {
        return true;
      };
    };
    return false;
  }

  public final static func SendActionSignal(puppet: wref<ScriptedPuppet>, signalName: CName, opt duration: Float) -> Bool {
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    if !IsDefined(puppet) || !IsNameValid(signalName) {
      return false;
    };
    signalTable = puppet.GetSignalTable();
    if !IsDefined(signalTable) {
      return false;
    };
    signalId = signalTable.GetOrCreateSignal(signalName);
    signalTable.Set(signalId, false);
    signalTable.SetTimed(signalId, duration);
    return true;
  }

  public final static func ResetActionSignal(puppet: wref<ScriptedPuppet>, signalName: CName) -> Bool {
    let signalId: Uint16;
    let signalTable: ref<gameBoolSignalTable>;
    if !IsDefined(puppet) || !IsNameValid(signalName) {
      return false;
    };
    signalTable = puppet.GetSignalTable();
    if !IsDefined(signalTable) {
      return false;
    };
    signalId = signalTable.GetOrCreateSignal(signalName);
    signalTable.Set(signalId, false);
    return true;
  }

  public func Kill(opt instigator: wref<GameObject>, opt skipNPCDeathAnim: Bool, opt disableNPCRagdoll: Bool) -> Void {
    GameInstance.GetStatPoolsSystem(this.GetGame()).RequestSettingStatPoolValueIgnoreChangeMode(Cast(this.GetEntityID()), gamedataStatPoolType.Health, 0.00, instigator);
  }

  public final static func GetActiveWeapon(obj: ref<GameObject>) -> wref<WeaponObject> {
    let weapon: wref<WeaponObject> = ScriptedPuppet.GetWeaponRight(obj);
    if !IsDefined(weapon) {
      weapon = ScriptedPuppet.GetWeaponLeft(obj);
    };
    return weapon;
  }

  public final static func GetWeaponRight(obj: ref<GameObject>) -> wref<WeaponObject> {
    return GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, t"AttachmentSlots.WeaponRight") as WeaponObject;
  }

  public final static func GetWeaponLeft(obj: ref<GameObject>) -> wref<WeaponObject> {
    return GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, t"AttachmentSlots.WeaponLeft") as WeaponObject;
  }

  public const func HasHeadUnderwater() -> Bool {
    let checkPosition: Vector4;
    let headTransform: WorldTransform;
    let waterLevel: Float;
    let slotComponent: ref<SlotComponent> = this.GetHitRepresantationSlotComponent();
    if IsDefined(slotComponent) && slotComponent.GetSlotTransform(n"Head", headTransform) {
      checkPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(headTransform));
    } else {
      return false;
    };
    if AIScriptUtils.GetWaterLevel(this.GetGame(), Vector4.Vector4To3(checkPosition), waterLevel) {
      return true;
    };
    return false;
  }

  public final const func IsUnderwater(opt howDeep: Float) -> Bool {
    let waterLevel: Float;
    let position: Vector4 = this.GetWorldPosition();
    if AIScriptUtils.GetWaterLevel(this.GetGame(), Vector4.Vector4To3(position), waterLevel) {
      if howDeep > 0.00 && position.Z - waterLevel > howDeep {
        return false;
      };
      return true;
    };
    return false;
  }

  public final static func ReevaluateOxygenConsumption(puppet: wref<ScriptedPuppet>) -> Void {
    if !IsDefined(puppet) {
      return;
    };
    puppet.QueueEvent(new ReevaluateOxygenEvent());
  }

  protected cb func OnReevaluateOxygenEvent(evt: ref<ReevaluateOxygenEvent>) -> Bool {
    let canBreathUnderwater: Bool;
    let isOnSurface: Bool;
    let psmBlackboard: ref<IBlackboard>;
    if IsDefined(this as PlayerPuppet) {
      isOnSurface = false;
      psmBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      if IsDefined(psmBlackboard) {
        if psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming) == EnumInt(gamePSMSwimming.Surface) {
          isOnSurface = true;
        };
      };
    };
    if this.HasHeadUnderwater() {
      this.PuppetSubmergedRequestRemovingStatusEffects(this);
    };
    canBreathUnderwater = RPGManager.HasStatFlag(this, gamedataStatType.CanBreatheUnderwater);
    if !canBreathUnderwater && this.HasHeadUnderwater() && !isOnSurface {
      this.StartOxygenDecay();
    } else {
      this.StopOxygenDecay();
    };
  }

  public final const func PuppetSubmergedRequestRemovingStatusEffects(obj: wref<GameObject>) -> Void {
    StatusEffectHelper.RemoveAllStatusEffectsByType(obj, gamedataStatusEffectType.Burning);
  }

  protected final func StartOxygenDecay() -> Void {
    let mod: StatPoolModifier;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: StatsObjectID = Cast(this.GetEntityID());
    statPoolsSystem.GetModifier(entityID, gamedataStatPoolType.Oxygen, gameStatPoolModificationTypes.Decay, mod);
    mod.enabled = true;
    statPoolsSystem.RequestSettingModifier(entityID, gamedataStatPoolType.Oxygen, gameStatPoolModificationTypes.Decay, mod);
    statPoolsSystem.RequestResetingModifier(entityID, gamedataStatPoolType.Oxygen, gameStatPoolModificationTypes.Regeneration);
  }

  protected final func StopOxygenDecay() -> Void {
    let mod: StatPoolModifier;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let entityID: StatsObjectID = Cast(this.GetEntityID());
    statPoolsSystem.GetModifier(entityID, gamedataStatPoolType.Oxygen, gameStatPoolModificationTypes.Regeneration, mod);
    mod.enabled = true;
    statPoolsSystem.RequestSettingModifier(entityID, gamedataStatPoolType.Oxygen, gameStatPoolModificationTypes.Regeneration, mod);
    statPoolsSystem.RequestResetingModifier(entityID, gamedataStatPoolType.Oxygen, gameStatPoolModificationTypes.Decay);
  }

  protected cb func OnRequestDismemberment(evt: ref<RequestDismembermentEvent>) -> Bool {
    DismembermentComponent.RequestDismemberment(EntityGameInterface.GetEntity(this.GetEntity()) as GameObject, evt.bodyPart, evt.dismembermentType, evt.hitPosition, evt.isCritical);
  }

  protected cb func OnResetSignalAIEventReceived(evt: ref<ResetSignal>) -> Bool {
    let signalTable: ref<gameBoolSignalTable> = evt.signalTable;
    let signalId: Uint16 = signalTable.GetOrCreateSignal(evt.signalName);
    signalTable.Set(signalId, false);
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let data: ref<FocusForcedHighlightData>;
    let highlightEvt: ref<ForceVisionApperanceEvent>;
    let tags: array<CName>;
    super.OnStatusEffectApplied(evt);
    tags = evt.staticData.GameplayTags();
    switch evt.staticData.StatusEffectType().Type() {
      case gamedataStatusEffectType.Kill:
        if EntityID.IsDefined(evt.instigatorEntityID) {
          this.Kill(GameInstance.FindEntityByID(this.GetGame(), evt.instigatorEntityID) as GameObject);
        } else {
          this.Kill();
          goto 945;
        };
      case gamedataStatusEffectType.Defeated:
        if !evt.isNewApplication {
        } else {
          this.SetWasIncapacitatedOnAttach(evt.isAppliedOnSpawn);
          ScriptedPuppet.SendDefeatedEvent(this);
          CachedBoolValue.SetDirty(this.m_isActiveCached);
          goto 945;
        };
      case gamedataStatusEffectType.DefeatedWithRecover:
        CachedBoolValue.SetDirty(this.m_isActiveCached);
        break;
      case gamedataStatusEffectType.AndroidTurnOff:
        ScriptedPuppet.SendAndroidTurnOffEvent(this);
        this.GetPuppetPS().SetIsAndroidTurnedOff(true);
        this.GetSensesComponent().ToggleSenses(false);
        this.SquadUpdate(true, AISquadType.Combat);
        CachedBoolValue.SetDirty(this.m_isActiveCached);
        break;
      case gamedataStatusEffectType.AndroidTurnOn:
        ScriptedPuppet.SendAndroidTurnOnEvent(this);
        this.GetPuppetPS().SetIsAndroidTurnedOff(false);
        this.GetSensesComponent().ToggleSenses(true);
        this.SquadUpdate(false, AISquadType.Combat);
        CachedBoolValue.SetDirty(this.m_isActiveCached);
        break;
      case gamedataStatusEffectType.Cloaked:
        ScriptedPuppet.SendNameplateVisibleEvent(this, false);
        break;
      default:
    };
    if ArrayContains(tags, n"Braindance") || ArrayContains(tags, n"Sleep") {
      this.GetSensesComponent().ToggleSenses(false);
    };
    if ArrayContains(tags, n"Deaf") {
      this.GetSensesComponent().SetHearingEnabled(false);
    };
    if ArrayContains(tags, n"DropHeldItems") {
      ScriptedPuppet.DropHeldItems(this);
    };
    if ArrayContains(tags, n"HackInterrupt") {
      this.RemoveLinkedStatusEffects();
      StatusEffectHelper.ApplyStatusEffect(this, t"AIQuickHackStatusEffect.HackingInterrupted", this.GetEntityID());
    };
    if ArrayContains(tags, n"Death") {
      this.SetSkipDeathAnimation(true);
      this.SendAIDeathSignal();
    };
    if ArrayContains(tags, n"Ping") {
      if Cast(GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.CanQuickhack)) {
        highlightEvt = new ForceVisionApperanceEvent();
        data = new FocusForcedHighlightData();
        data.sourceID = GetPlayer(this.GetGame()).GetEntityID();
        data.sourceName = GetPlayer(this.GetGame()).GetClassName();
        data.highlightType = EFocusForcedHighlightType.ENEMY_NETRUNNER;
        data.outlineType = EFocusOutlineType.ENEMY_NETRUNNER;
        data.priority = EPriority.High;
        data.isRevealed = true;
        this.m_highlightData = data;
        highlightEvt.forcedHighlight = data;
        highlightEvt.apply = true;
        this.QueueEvent(highlightEvt);
      } else {
        GameObject.SendForceRevealObjectEvent(this, true, n"PingQuickhack");
      };
    };
    this.DetermineInteractionState();
  }

  private final func SendAIDeathSignal() -> Void {
    let signal: AIGateSignal;
    signal.priority = 9.00;
    signal.lifeTime = RPGManager.GetStatRecord(gamedataStatType.MaxDuration).Max();
    AIGateSignal.AddTag(signal, n"downed");
    AIGateSignal.AddTag(signal, n"death");
    this.GetSignalHandlerComponent().AddSignal(signal, false);
    if VehicleComponent.IsMountedToVehicle(this.GetGame(), this) {
      GameInstance.GetWorkspotSystem(this.GetGame()).HardResetPlaybackToStart(this);
    };
  }

  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let effectType: gamedataStatusEffectType;
    let highlightEvt: ref<ForceVisionApperanceEvent>;
    let tags: array<CName>;
    super.OnStatusEffectRemoved(evt);
    tags = evt.staticData.GameplayTags();
    if ArrayContains(tags, n"Braindance") || ArrayContains(tags, n"Sleep") {
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Braindance") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Sleep") {
        this.GetSensesComponent().ToggleSenses(true);
      };
    };
    if ArrayContains(tags, n"Deaf") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Deaf") {
      this.GetSensesComponent().SetHearingEnabled(true);
    };
    effectType = evt.staticData.StatusEffectType().Type();
    if ScriptedPuppet.IsAlive(this) && Equals(effectType, gamedataStatusEffectType.Defeated) {
      ScriptedPuppet.SendResurrectEvent(this);
    } else {
      if Equals(effectType, gamedataStatusEffectType.Cloaked) && evt.isFinalRemoval {
        ScriptedPuppet.SendNameplateVisibleEvent(this, true);
      };
    };
    if ArrayContains(tags, n"Ping") {
      highlightEvt = new ForceVisionApperanceEvent();
      highlightEvt.forcedHighlight = this.m_highlightData;
      highlightEvt.apply = false;
      this.QueueEvent(highlightEvt);
      GameObject.SendForceRevealObjectEvent(this, false, n"PingQuickhack");
    };
    this.DetermineInteractionState();
    if Equals(effectType, gamedataStatusEffectType.Defeated) || Equals(effectType, gamedataStatusEffectType.DefeatedWithRecover) || Equals(effectType, gamedataStatusEffectType.AndroidTurnOff) || Equals(effectType, gamedataStatusEffectType.AndroidTurnOn) {
      CachedBoolValue.SetDirty(this.m_isActiveCached);
    };
  }

  protected cb func OnSetLootInteractionAccessEvent(evt: ref<SetLootInteractionAccessibilityEvent>) -> Bool {
    this.UpdateLootInteraction();
  }

  public final static func SendResurrectEvent(obj: wref<GameObject>) -> Void {
    let evt: ref<ResurrectEvent>;
    if !IsDefined(obj) {
      return;
    };
    evt = new ResurrectEvent();
    obj.QueueEvent(evt);
  }

  public final static func SendDefeatedEvent(obj: wref<GameObject>) -> Void {
    let evt: ref<DefeatedEvent>;
    if !IsDefined(obj) {
      return;
    };
    evt = new DefeatedEvent();
    obj.QueueEvent(evt);
  }

  public final static func SendAndroidTurnOnEvent(obj: wref<GameObject>) -> Void {
    let evt: ref<AndroidTurnOn>;
    if !IsDefined(obj) {
      return;
    };
    evt = new AndroidTurnOn();
    obj.QueueEvent(evt);
  }

  public final static func SendAndroidTurnOffEvent(obj: wref<GameObject>) -> Void {
    let evt: ref<AndroidTurnOff>;
    if !IsDefined(obj) {
      return;
    };
    evt = new AndroidTurnOff();
    obj.QueueEvent(evt);
  }

  public final static func SendNameplateVisibleEvent(obj: wref<GameObject>, visible: Bool) -> Void {
    let evt: ref<NameplateVisibleEvent>;
    if !IsDefined(obj) {
      return;
    };
    evt = new NameplateVisibleEvent();
    evt.isNameplateVisible = visible;
    evt.entityID = obj.GetEntityID();
    obj.QueueEvent(evt);
  }

  protected cb func OnDefeated(evt: ref<DefeatedEvent>) -> Bool {
    this.HandleDefeatedByTask();
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    this.HandleDeathByTask(evt.instigator);
  }

  protected func OnDied() -> Void {
    StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.Defeated");
    this.GetPuppetPS().SetIsDead(true);
    this.OnIncapacitated();
    CachedBoolValue.SetDirty(this.m_isActiveCached);
    if !IsFinal() {
      LogDamage("ScriptedPuppet.OnDeath(): " + IsDefined(this) + " died.");
    };
  }

  private final func SquadUpdate(leaveSquad: Bool, squadType: AISquadType) -> Void {
    let ssi: ref<SquadScriptInterface>;
    if IsMultiplayer() {
      return;
    };
    if leaveSquad {
      if IsDefined(ssi = this.GetSquadMemberComponent().MySquad(squadType)) {
        ssi.Leave(this);
      };
    } else {
      if IsDefined(ssi = this.GetSquadMemberComponent().FindSquad(this.GetSquadMemberComponent().MySquadNameCurrentOrRecent(squadType))) {
        ssi.Join(this);
      };
    };
  }

  protected func OnIncapacitated() -> Void {
    let deadBodyEvent: ref<DeadBodyEvent>;
    let link: ref<PuppetDeviceLinkPS>;
    if this.IsIncapacitated() {
      return;
    };
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"CommsNoiseIgnore") {
      deadBodyEvent = new DeadBodyEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, deadBodyEvent, 1.00);
    };
    this.m_securitySupportListener = null;
    this.RemoveLink();
    this.EnableLootInteractionWithDelay(this);
    this.EnableInteraction(n"Grapple", false);
    this.EnableInteraction(n"TakedownLayer", false);
    this.EnableInteraction(n"AerialTakedown", false);
    StatusEffectHelper.RemoveAllStatusEffectsByType(this, gamedataStatusEffectType.Cloaked);
    if this.IsBoss() {
      this.EnableInteraction(n"BossTakedownLayer", false);
    } else {
      if this.IsMassive() {
        this.EnableInteraction(n"MassiveTargetTakedownLayer", false);
      };
    };
    this.RevokeAllTickets();
    this.GetSensesComponent().ToggleComponent(false);
    this.GetBumpComponent().Toggle(false);
    this.UpdateQuickHackableState(false);
    if this.IsPerformingCallReinforcements() {
      this.HidePhoneCallDuration(gamedataStatPoolType.CallReinforcementProgress);
    };
    this.GetPuppetPS().SetWasIncapacitated(true);
    link = this.GetDeviceLink() as PuppetDeviceLinkPS;
    if IsDefined(link) {
      link.NotifyAboutSpottingPlayer(false);
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(link.GetID(), link.GetClassName(), new DestroyLink());
    };
    CachedBoolValue.SetDirty(this.m_isActiveCached);
  }

  protected cb func OnResurrect(evt: ref<ResurrectEvent>) -> Bool {
    this.OnResurrected();
  }

  protected func OnResurrected() -> Void {
    this.EnableInteraction(n"Grapple", true);
    this.EnableInteraction(n"TakedownLayer", true);
    this.EnableInteraction(n"AerialTakedown", true);
    this.GetSensesComponent().ToggleComponent(true);
    this.GetPuppetPS().SetIsDead(false);
    this.GetPuppetPS().SetWasIncapacitated(false);
    CachedBoolValue.SetDirty(this.m_isActiveCached);
  }

  protected func RewardKiller(killer: wref<GameObject>, killType: gameKillType, isAnyDamageNonlethal: Bool) -> Void {
    let neutralizeType: ENeutralizeType;
    let neutralizedEvt: ref<TargetNeutraliziedEvent>;
    if this.m_killRewardDisabled {
      return;
    };
    this.RewardKiller(killer, killType, isAnyDamageNonlethal);
    this.SetKiller(killer);
    if IsDefined(killer as PlayerPuppet) {
      if Equals(killType, gameKillType.Defeat) || this.m_forceDefeatReward {
        if isAnyDamageNonlethal {
          neutralizeType = ENeutralizeType.Unconscious;
        } else {
          neutralizeType = ENeutralizeType.Defeated;
        };
      } else {
        neutralizeType = ENeutralizeType.Killed;
      };
      neutralizedEvt = new TargetNeutraliziedEvent();
      neutralizedEvt.type = neutralizeType;
      neutralizedEvt.targetID = this.GetEntityID();
      killer.QueueEvent(neutralizedEvt);
    };
  }

  protected cb func OnDamageReceived(evt: ref<gameDamageReceivedEvent>) -> Bool {
    let instigator: ref<GameObject>;
    let npcPuppetInstig: wref<NPCPuppet>;
    super.OnDamageReceived(evt);
    if evt.totalDamageReceived <= 0.00 {
      return false;
    };
    instigator = evt.hitEvent.attackData.GetInstigator();
    if instigator != null {
      if this.IsPlayer() {
        this.LogDamageReceived(evt, instigator, gameTelemetryDamageSituation.EnemyToPlayer);
        npcPuppetInstig = instigator as NPCPuppet;
        if npcPuppetInstig != null {
          npcPuppetInstig.OnHittingPlayer(this, evt.totalDamageReceived);
        };
      } else {
        if ScriptedPuppet.IsPlayerCompanion(this) {
          this.LogDamageReceived(evt, instigator, gameTelemetryDamageSituation.EnemyToCompanion);
        } else {
          if instigator.IsPlayer() && PreventionSystem.ShouldPreventionSystemReactToDamageDealt(this) {
            PreventionSystem.CombatStartedRequestToPreventionSystem(this.GetGame(), this);
          };
        };
      };
    };
  }

  protected final func LogDamageReceived(evt: ref<gameDamageReceivedEvent>, instigator: ref<GameObject>, dmgSituation: gameTelemetryDamageSituation) -> Void {
    let distance: Float = IsDefined(instigator) && instigator != this ? Vector4.Distance(this.GetWorldPosition(), instigator.GetWorldPosition()) : -1.00;
    let time: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetGame()));
    GameInstance.GetTelemetrySystem(this.GetGame()).LogDamageDealt(ToTelemetryDamageDealt(evt, dmgSituation, distance, time));
  }

  protected cb func OnDamageDealt(evt: ref<gameTargetDamageEvent>) -> Bool {
    let distance: Float;
    let dmgSituation: gameTelemetryDamageSituation;
    let time: Float;
    if evt.target == null || evt.damage <= 0.00 {
      return false;
    };
    dmgSituation = gameTelemetryDamageSituation.Irrelevant;
    if IsDefined(this as PlayerPuppet) {
      dmgSituation = gameTelemetryDamageSituation.PlayerToEnemy;
    } else {
      if ScriptedPuppet.IsPlayerCompanion(this) {
        dmgSituation = gameTelemetryDamageSituation.CompanionToEnemy;
      };
    };
    if NotEquals(dmgSituation, gameTelemetryDamageSituation.Irrelevant) {
      distance = IsDefined(evt.target) ? Vector4.Distance(this.GetWorldPosition(), evt.target.GetWorldPosition()) : -1.00;
      time = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetGame()));
      GameInstance.GetTelemetrySystem(this.GetGame()).LogDamageDealt(ToTelemetryDamageDealt(evt, dmgSituation, distance, time));
    };
  }

  protected cb func OnKillRewardEvent(evt: ref<KillRewardEvent>) -> Bool {
    if evt.victim == null {
      return false;
    };
    if IsDefined(this as PlayerPuppet) {
      this.LogEnemyDown(evt, gameTelemetryDamageSituation.PlayerToEnemy);
    } else {
      if ScriptedPuppet.IsPlayerCompanion(this) {
        this.LogEnemyDown(evt, gameTelemetryDamageSituation.CompanionToEnemy);
      };
    };
  }

  private final func LogEnemyDown(evt: ref<KillRewardEvent>, dmgSituation: gameTelemetryDamageSituation) -> Void {
    let telemetryDown: TelemetryEnemyDown;
    telemetryDown.situation = dmgSituation;
    telemetryDown.enemy = ToTelemetryEnemy(evt.victim);
    telemetryDown.killType = evt.killType;
    GameInstance.GetTelemetrySystem(this.GetGame()).LogEnemyDown(telemetryDown);
  }

  private final func HasCalculatedEquipment(equipmentPriority: EquipmentPriority, characterRecord: ref<Character_Record>) -> Bool {
    let equipmentGroup: ref<NPCEquipmentGroup_Record>;
    let i: Int32;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let result: Bool = true;
    switch equipmentPriority {
      case EquipmentPriority.Primary:
        equipmentGroup = characterRecord.PrimaryEquipment();
        break;
      case EquipmentPriority.Secondary:
        equipmentGroup = characterRecord.SecondaryEquipment();
    };
    AIActionTransactionSystem.CalculateEquipmentItems(this, equipmentGroup, items, -1);
    i = 0;
    while i < ArraySize(items) {
      result = result && GameInstance.GetTransactionSystem(this.GetGame()).HasItem(this, ItemID.CreateQuery(items[i].Item().GetID()));
      i += 1;
    };
    return result;
  }

  public final func HasEquipment(equipmentPriority: EquipmentPriority) -> Bool {
    let result: Bool = false;
    let characterRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
    switch equipmentPriority {
      case EquipmentPriority.Primary:
        result = this.HasCalculatedEquipment(EquipmentPriority.Primary, characterRecord);
        break;
      case EquipmentPriority.Secondary:
        result = this.HasCalculatedEquipment(EquipmentPriority.Secondary, characterRecord);
        break;
      case EquipmentPriority.All:
        result = this.HasCalculatedEquipment(EquipmentPriority.Primary, characterRecord);
        result = result && this.HasCalculatedEquipment(EquipmentPriority.Secondary, characterRecord);
    };
    return result;
  }

  private final func GiveEquipment(equipmentPriority: EquipmentPriority, characterRecord: ref<Character_Record>, powerLevel: Int32) -> Void {
    let equipmentGroup: ref<NPCEquipmentGroup_Record>;
    let i: Int32;
    let items: array<wref<NPCEquipmentItem_Record>>;
    switch equipmentPriority {
      case EquipmentPriority.Primary:
        equipmentGroup = characterRecord.PrimaryEquipment();
        break;
      case EquipmentPriority.Secondary:
        equipmentGroup = characterRecord.SecondaryEquipment();
    };
    AIActionTransactionSystem.CalculateEquipmentItems(this, equipmentGroup, items, powerLevel);
    i = 0;
    while i < ArraySize(items) {
      GameInstance.GetTransactionSystem(this.GetGame()).GiveItem(this, ItemID.FromTDBID(items[i].Item().GetID()), 1);
      i += 1;
    };
  }

  public func AddRecordEquipment(equipmentPriority: EquipmentPriority, opt powerLevel: Int32) -> Void {
    let characterRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
    switch equipmentPriority {
      case EquipmentPriority.Primary:
        this.GiveEquipment(EquipmentPriority.Primary, characterRecord, powerLevel);
        break;
      case EquipmentPriority.Secondary:
        this.GiveEquipment(EquipmentPriority.Secondary, characterRecord, powerLevel);
        break;
      case EquipmentPriority.All:
        this.GiveEquipment(EquipmentPriority.Primary, characterRecord, powerLevel);
        this.GiveEquipment(EquipmentPriority.Secondary, characterRecord, powerLevel);
    };
  }

  public final static func GetEquipment(self: wref<ScriptedPuppet>) -> array<ref<gameItemData>> {
    let canItemDrop: Bool;
    let equipmentItems: array<ref<gameItemData>>;
    let foundItem: wref<gameItemData>;
    let itemQuery: ItemID;
    let items: array<wref<NPCEquipmentItem_Record>>;
    let weaponDropped: Bool;
    AIActionTransactionSystem.CalculateEquipmentItems(self, TweakDBInterface.GetCharacterRecord(self.GetRecordID()).PrimaryEquipment(), items, -1);
    itemQuery = ItemID.CreateQuery(items[0].Item().GetID());
    foundItem = GameInstance.GetTransactionSystem(self.GetGame()).GetItemData(self, itemQuery);
    canItemDrop = IsNameValid(TweakDBInterface.GetItemRecord(items[0].Item().GetID()).DropObject());
    if !IsMultiplayer() {
      weaponDropped = ScriptedPuppet.DropHeldItems(self);
    };
    if IsDefined(foundItem) && canItemDrop && !weaponDropped {
      ArrayPush(equipmentItems, foundItem);
    };
    return equipmentItems;
  }

  private final static func GenerateLootModifiers(self: ref<ScriptedPuppet>, out lootModifiers: array<ref<gameStatModifierData>>) -> Void {
    let itemLevel: Int32;
    let modifier: ref<gameConstantStatModifierData>;
    let playerExpPercent: Int32;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(self.GetGame());
    let powerLevel: Float = statsSystem.GetStatValue(Cast(self.GetEntityID()), gamedataStatType.PowerLevel);
    let playerPowerLevel: Float = statsSystem.GetStatValue(Cast(GetPlayer(self.GetGame()).GetEntityID()), gamedataStatType.PowerLevel);
    let powerDiff: EPowerDifferential = RPGManager.CalculatePowerDifferential(self);
    if playerPowerLevel <= powerLevel && NotEquals(powerDiff, EPowerDifferential.IMPOSSIBLE) {
      powerLevel = playerPowerLevel;
      playerExpPercent = RPGManager.GetLevelPercentage(GetPlayer(self.GetGame())) / 10;
      itemLevel = RandRange(playerExpPercent - 4, playerExpPercent + 3);
    };
    modifier = new gameConstantStatModifierData();
    modifier.modifierType = gameStatModifierType.Additive;
    modifier.statType = gamedataStatType.PowerLevel;
    modifier.value = powerLevel;
    ArrayPush(lootModifiers, modifier);
    modifier = new gameConstantStatModifierData();
    modifier.modifierType = gameStatModifierType.Additive;
    modifier.statType = gamedataStatType.ItemLevel;
    modifier.value = Cast(itemLevel);
    ArrayPush(lootModifiers, modifier);
  }

  public final static func ProcessLoot(self: wref<ScriptedPuppet>) -> Void {
    let ammoAmount: Int32;
    let ammoToDrop: array<TweakDBID>;
    let blockRequest: ref<BlockAmmoDrop>;
    let i: Int32;
    let isBroken: Bool;
    let itemTDBID: TweakDBID;
    let lootModifiers: array<ref<gameStatModifierData>>;
    let rand: Float;
    let randQuery: Float;
    let tempPlayerLevel: Float;
    let tempStat: Float;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(self.GetGame());
    let record: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(self.GetRecordID());
    let canDropWeapon: Bool = record.DropsWeaponOnDeath();
    let canDropAmmo: Bool = record.DropsAmmoOnDeath();
    let dropMoney: Bool = record.DropsMoneyOnDeath();
    let foundEquipment: array<ref<gameItemData>> = ScriptedPuppet.GetEquipment(self);
    let heldMoney: Int32 = TS.GetItemQuantity(self, MarketSystem.Money());
    ScriptedPuppet.GenerateLootModifiers(self, lootModifiers);
    self.GenerateLootWithStats(lootModifiers);
    if self.IsLooted() {
      return;
    };
    if self.IsCrowd() {
      return;
    };
    if dropMoney {
      TS.GiveItem(self, MarketSystem.Money(), heldMoney);
    };
    if canDropWeapon {
      i = 0;
      while i < ArraySize(foundEquipment) {
        RPGManager.SetDroppedWeaponQuality(self, foundEquipment[i]);
        isBroken = RPGManager.BreakItem(self.GetGame(), self, foundEquipment[i].GetID());
        if !isBroken {
          ScriptedPuppet.ScaleDroppedItem(foundEquipment[i], self);
          TS.GiveItemByItemData(self, foundEquipment[i]);
        };
        i += 1;
      };
    };
    if canDropAmmo {
      ammoToDrop = PlayerHandicapSystem.GetInstance(self).GetHandicapAmmo();
      if ArraySize(ammoToDrop) > 0 {
        blockRequest = new BlockAmmoDrop();
        PlayerHandicapSystem.GetInstance(self).QueueRequest(blockRequest);
      };
      i = 0;
      while i < ArraySize(foundEquipment) {
        itemTDBID = RPGManager.GetWeaponAmmoTDBID(foundEquipment[i].GetID());
        if TDBID.IsValid(itemTDBID) {
          ArrayPush(ammoToDrop, itemTDBID);
        };
        i += 1;
      };
      i = 0;
      while i < ArraySize(ammoToDrop) {
        switch ammoToDrop[i] {
          case t"Ammo.SniperRifleAmmo":
            ammoAmount = RandRange(5, 20);
            break;
          case t"Ammo.HandgunAmmo":
            ammoAmount = RandRange(20, 40);
            break;
          case t"Ammo.RifleAmmo":
            ammoAmount = RandRange(30, 60);
            break;
          case t"Ammo.ShotgunAmmo":
            ammoAmount = RandRange(10, 25);
            break;
          default:
            ammoAmount = 0;
        };
        if ammoAmount > 0 {
          TS.GiveItemByTDBID(self, ammoToDrop[i], ammoAmount);
          self.DropAmmo();
        };
        i += 1;
      };
    };
    if Equals(record.CharacterType().Type(), gamedataNPCType.Human) && self.IsHostile() {
      ScriptedPuppet.ProcessSupportiveItems(self);
    };
    if ScriptedPuppet.IsMechanical(self) {
      rand = RandF();
      randQuery = RandF();
      tempStat = GameInstance.GetStatsSystem(self.GetGame()).GetStatValue(Cast(GetPlayer(self.GetGame()).GetEntityID()), gamedataStatType.ScrapItemChance);
      tempPlayerLevel = GameInstance.GetStatsSystem(self.GetGame()).GetStatValue(Cast(GetPlayer(self.GetGame()).GetEntityID()), gamedataStatType.Level);
      if tempStat >= rand {
        if tempPlayerLevel < 20.00 {
          if randQuery <= 0.33 {
            GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.EarlyGameWeaponMods", 1u, 1u);
          } else {
            if randQuery > 0.33 && randQuery <= 0.66 {
              GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.EarlyGameWeaponScopes", 1u, 1u);
            } else {
              if randQuery > 0.66 {
                GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.EarlyGameWeaponSilencers", 1u, 1u);
              };
            };
          };
        } else {
          if tempPlayerLevel >= 20.00 && tempPlayerLevel < 35.00 {
            if randQuery <= 0.33 {
              GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.MidGameWeaponMods", 1u, 1u);
            } else {
              if randQuery > 0.33 && randQuery <= 0.66 {
                GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.MidGameWeaponScopes", 1u, 1u);
              } else {
                if randQuery > 0.66 {
                  GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.MidGameWeaponSilencers", 1u, 1u);
                };
              };
            };
          } else {
            if tempPlayerLevel >= 35.00 {
              if randQuery <= 0.33 {
                GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.EndGameWeaponMods", 1u, 1u);
              } else {
                if randQuery > 0.33 && randQuery <= 0.66 {
                  GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.EndGameWeaponScopes", 1u, 1u);
                } else {
                  if randQuery > 0.66 {
                    GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByItemQuery(self, t"Query.EndGameWeaponSilencers", 1u, 1u);
                  };
                };
              };
            };
          };
        };
      };
    };
    if ScriptedPuppet.HasLootableItems(self) {
      ScriptedPuppet.EvaluateLootQuality(self);
    };
    self.CacheLootForDroping();
  }

  public final static func DropHeldItems(self: wref<ScriptedPuppet>) -> Bool {
    let canDrop: Bool;
    let canLeftItemDrop: Bool;
    let canRightItemDrop: Bool;
    let leftItem: wref<ItemObject>;
    let rightItem: wref<ItemObject>;
    let slot: TweakDBID;
    if !IsDefined(self) {
      return false;
    };
    canDrop = TweakDBInterface.GetCharacterRecord(self.GetRecordID()).DropsWeaponOnDeath();
    if canDrop {
      slot = t"AttachmentSlots.WeaponRight";
      rightItem = GameInstance.GetTransactionSystem(self.GetGame()).GetItemInSlot(self, slot);
      canRightItemDrop = IsDefined(rightItem) && IsNameValid(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(rightItem.GetItemID())).DropObject());
      slot = t"AttachmentSlots.WeaponLeft";
      leftItem = GameInstance.GetTransactionSystem(self.GetGame()).GetItemInSlot(self, slot);
      canLeftItemDrop = IsDefined(leftItem) && IsNameValid(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(leftItem.GetItemID())).DropObject());
      if canLeftItemDrop || canRightItemDrop {
        self.DropWeapons();
        if IsDefined(rightItem) {
          ScriptedPuppet.ScaleDroppedItem(rightItem.GetItemData(), self);
        };
        if IsDefined(leftItem) {
          ScriptedPuppet.ScaleDroppedItem(leftItem.GetItemData(), self);
        };
        return true;
      };
      return false;
    };
    return false;
  }

  public final static func ScaleDroppedItem(itemData: wref<gameItemData>, owner: wref<ScriptedPuppet>) -> Void {
    let itemLevel: Int32;
    let modifier: ref<gameConstantStatModifierData>;
    let playerExpPercent: Int32;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(owner.GetGame());
    let powerLevel: Float = statsSystem.GetStatValue(Cast(owner.GetEntityID()), gamedataStatType.PowerLevel);
    let playerPowerLevel: Float = statsSystem.GetStatValue(Cast(GetPlayer(owner.GetGame()).GetEntityID()), gamedataStatType.PowerLevel);
    let powerDiff: EPowerDifferential = RPGManager.CalculatePowerDifferential(owner);
    if playerPowerLevel <= powerLevel && NotEquals(powerDiff, EPowerDifferential.IMPOSSIBLE) {
      powerLevel = playerPowerLevel;
      playerExpPercent = RPGManager.GetLevelPercentage(GetPlayer(owner.GetGame())) / 10;
      itemLevel = RandRange(playerExpPercent - 4, playerExpPercent + 3);
    };
    statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel);
    modifier = new gameConstantStatModifierData();
    modifier.modifierType = gameStatModifierType.Additive;
    modifier.statType = gamedataStatType.PowerLevel;
    modifier.value = powerLevel;
    statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), modifier);
    modifier = new gameConstantStatModifierData();
    modifier.modifierType = gameStatModifierType.Additive;
    modifier.statType = gamedataStatType.ItemLevel;
    modifier.value = Cast(itemLevel);
    statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), modifier);
  }

  public final static func DropItemFromSlot(obj: wref<GameObject>, slot: TweakDBID) -> Void {
    let item: wref<ItemObject>;
    let itemInSlotID: ItemID;
    if !IsDefined(obj) {
      return;
    };
    item = GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, slot);
    if IsDefined(item) {
      itemInSlotID = item.GetItemData().GetID();
    };
    if IsDefined(item) && NotEquals(RPGManager.GetItemType(itemInSlotID), gamedataItemType.Wea_Fists) && NotEquals(RPGManager.GetItemType(itemInSlotID), gamedataItemType.Cyb_StrongArms) && NotEquals(RPGManager.GetItemType(itemInSlotID), gamedataItemType.Cyb_MantisBlades) && NotEquals(RPGManager.GetItemType(itemInSlotID), gamedataItemType.Cyb_NanoWires) {
      (obj as ScriptedPuppet).DropWeapons();
    };
  }

  public final static func DropWeaponFromSlot(obj: wref<GameObject>, slot: TweakDBID) -> Void {
    let isBroken: Bool;
    let item: wref<ItemObject>;
    if !IsDefined(obj) {
      return;
    };
    item = GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, slot);
    if IsDefined(item) {
      isBroken = RPGManager.BreakItem(obj.GetGame(), obj, item.GetItemID());
      if !isBroken {
        (obj as ScriptedPuppet).DropWeapons();
      };
    };
  }

  private final static func ProcessSupportiveItems(self: wref<ScriptedPuppet>) -> Void {
    let itemTDBID: TweakDBID;
    let playerHealth: Float;
    let request: ref<BlockHealingConsumableDrop>;
    if PlayerHandicapSystem.GetInstance(self).CanDropHealingConsumable() {
      playerHealth = RPGManager.GetPlayerCurrentHealthPercent(self.GetGame());
      if playerHealth > 0.00 && playerHealth <= TweakDBInterface.GetFloat(t"GlobalStats.PlayerHealthThresholdForDroppingAdditionalConsumables.value", 50.00) {
        itemTDBID = RPGManager.GetRandomizedHealingConsumable(self);
        GameInstance.GetTransactionSystem(self.GetGame()).GiveItemByTDBID(self, itemTDBID, 1);
        request = new BlockHealingConsumableDrop();
        PlayerHandicapSystem.GetInstance(self).QueueRequest(request);
      };
    };
  }

  private final static func HasLootableItems(self: wref<ScriptedPuppet>) -> Bool {
    let i: Int32;
    let items: array<wref<gameItemData>>;
    let type: gamedataItemType;
    let sum: Int32 = 0;
    GameInstance.GetTransactionSystem(self.GetGame()).GetItemList(self, items);
    i = 0;
    while i < ArraySize(items) {
      type = items[i].GetItemType();
      if NotEquals(type, gamedataItemType.Con_Ammo) {
        sum += 1;
      };
      i += 1;
    };
    return sum > 0;
  }

  protected cb func OnAttitudeChanged(evt: ref<AttitudeChangedEvent>) -> Bool;

  protected final func RevokeAllTickets() -> Void {
    let i: Int32;
    let ticket: SquadOrder;
    let tickets: array<Uint32>;
    let ssi: ref<SquadScriptInterface> = this.GetSquadMemberComponent().MySquad(AISquadType.Community);
    if !IsDefined(ssi) {
      return;
    };
    tickets = ssi.GetAllOrders(this);
    i = 0;
    while i < ArraySize(tickets) {
      ticket = ssi.GetOrderById(tickets[i]);
      ssi.ReportFail(ticket.squadAction, this);
      ssi.RevokeSquadAction(ticket.squadAction, this);
      i += 1;
    };
  }

  protected cb func OnHackPlayerEvent(evt: ref<HackPlayerEvent>) -> Bool {
    let action: ref<AIQuickHackAction>;
    let attackAttemptEvent: ref<AIAttackAttemptEvent>;
    let isBeingHacked: Bool;
    let netrunner: wref<ScriptedPuppet>;
    let target: wref<GameObject> = GameInstance.FindEntityByID(this.GetGame(), evt.targetID) as GameObject;
    if !IsDefined(target) {
      return false;
    };
    netrunner = GameInstance.FindEntityByID(this.GetGame(), evt.netrunnerID) as ScriptedPuppet;
    if !IsDefined(netrunner) {
      return false;
    };
    isBeingHacked = GameInstance.GetStatusEffectSystem(this.GetGame()).HasStatusEffect(evt.targetID, t"AIQuickHackStatusEffect.BeingHacked");
    if !isBeingHacked && !EntityID.IsDefined(this.m_linkedStatusEffect.targetID) {
      action = new AIQuickHackAction();
      action.RegisterAsRequester(evt.targetID);
      action.SetExecutor(netrunner);
      action.SetObjectActionID(evt.objectRecord.GetID());
      action.m_target = target;
      action.SetUp(target.GetPS());
      if !action.IsPossible(target) {
        return false;
      };
      action.ProcessRPGAction(this.GetGame());
      if evt.showDirectionalIndicator {
        attackAttemptEvent = new AIAttackAttemptEvent();
        attackAttemptEvent.instigator = netrunner;
        attackAttemptEvent.target = target;
        attackAttemptEvent.isWindUp = false;
        attackAttemptEvent.continuousMode = gameEContinuousMode.Start;
        attackAttemptEvent.minimumOpacity = 0.50;
        target.QueueEvent(attackAttemptEvent);
        this.GetOwner().QueueEvent(attackAttemptEvent);
      };
      StatusEffectHelper.ApplyStatusEffect(this, t"AIQuickHackStatusEffect.BeingHacked", evt.netrunnerID);
      this.ProcessEnemyNetrunnerTutorialFact();
    } else {
      if !isBeingHacked && EntityID.IsDefined(this.m_linkedStatusEffect.targetID) {
        if !ArrayContains(this.m_linkedStatusEffect.netrunnerIDs, evt.netrunnerID) {
          ArrayPush(this.m_linkedStatusEffect.netrunnerIDs, evt.netrunnerID);
          AIActionHelper.UpdateLinkedStatusEffects(this, this.m_linkedStatusEffect);
          netrunner.AddLinkedStatusEffect(evt.netrunnerID, evt.targetID);
        };
      } else {
        if !evt.revealPositionAction {
          GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(GameInstance.FindEntityByID(this.GetGame(), evt.targetID), evt, 2.00);
        };
      };
    };
  }

  private final func ProcessEnemyNetrunnerTutorialFact() -> Void {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
    if questSystem.GetFact(n"enemy_netrunner_tutorial") == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(n"enemy_netrunner_tutorial", 1);
    };
  }

  protected cb func OnRemoveLinkEvent(evt: ref<RemoveLinkEvent>) -> Bool {
    this.RemoveLink();
  }

  protected cb func OnRemoveLinkedStatusEffectsEvent(evt: ref<RemoveLinkedStatusEffectsEvent>) -> Bool {
    this.RemoveLinkedStatusEffects(evt.ssAction);
  }

  protected cb func OnNetworkLinkQuickhackEvent(evt: ref<NetworkLinkQuickhackEvent>) -> Bool {
    let bb: ref<IBlackboard> = this.GetAIControllerComponent().GetActionBlackboard();
    if IsDefined(bb) {
      bb.SetVariant(GetAllBlackboardDefs().AIAction.netrunner, ToVariant(evt.netrunnerID));
      bb.SetVariant(GetAllBlackboardDefs().AIAction.netrunnerProxy, ToVariant(evt.proxyID));
      bb.SetVariant(GetAllBlackboardDefs().AIAction.netrunnerTarget, ToVariant(evt.targetID));
    };
    this.ToggleForcedVisibilityInAnimSystem(n"pingNetworkLink", true, 0.00, evt.from);
    (this.GetPS() as ScriptedPuppetPS).DrawBetweenEntities(true, true, this.GetFxResourceByKey(n"pingNetworkLink"), evt.to, evt.from, false, false, false, false);
    if GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(evt.targetID), gamedataStatType.RevealNetrunnerWhenHacked) == 1.00 {
      ScriptedPuppet.ForceVisionAppearanceNetrunner(GameInstance.FindEntityByID(this.GetGame(), evt.netrunnerID) as GameObject, evt.netrunnerID, n"EnemyNetrunner", true);
      if EntityID.IsDefined(evt.proxyID) {
        ScriptedPuppet.ForceVisionAppearanceNetrunner(GameInstance.FindEntityByID(this.GetGame(), evt.proxyID) as GameObject, evt.netrunnerID, n"EnemyNetrunner", true);
      };
    };
  }

  protected final func EnableLootInteractionWithDelay(puppet: ref<gamePuppet>) -> Void {
    let evt: ref<LootPickupDelayEvent> = new LootPickupDelayEvent();
    evt.m_enableLootInteraction = true;
    let delay: Float = TweakDBInterface.GetFloat(t"items.dropSettings.delayBeforeEnablingLootPickUp", 2.00);
    GameInstance.GetDelaySystem(puppet.GetGame()).DelayEvent(puppet, evt, delay);
  }

  protected cb func OnLootPickupDelayEvent(evt: ref<LootPickupDelayEvent>) -> Bool {
    this.UpdateLootInteraction();
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    let actorUpdateData: ref<HUDActorUpdateData>;
    let context: GetActionsContext;
    let requestType: gamedeviceRequestType;
    let canGrappleCivilian: Bool = TweakDBInterface.GetBool(t"player.grapple.canGrappleCivilian", true);
    let civilianConnectedToSecurityRequired: Bool = TweakDBInterface.GetBool(t"player.grapple.civilianConnectedToSecurityRequired", true);
    let playerPuppet: ref<PlayerPuppet> = evt.activator as PlayerPuppet;
    if !IsDefined(playerPuppet) {
      return false;
    };
    (this.GetPS() as ScriptedPuppetPS).SetHasDirectInteractionChoicesActive(false);
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      if this.IsQualityRangeInteractionLayer(evt.layerData.tag) {
        actorUpdateData = new HUDActorUpdateData();
        actorUpdateData.updateIsInIconForcedVisibilityRange = true;
        actorUpdateData.isInIconForcedVisibilityRangeValue = true;
        this.RequestHUDRefresh(actorUpdateData);
      };
      if this.IsCharacterCivilian() && !this.GetRecord().IsCrowd() {
        if canGrappleCivilian && civilianConnectedToSecurityRequired && !this.IsConnectedToSecuritySystem() {
          return false;
        };
      };
      if Equals(evt.layerData.tag, n"Grapple") || Equals(evt.layerData.tag, n"TakedownLayer") || Equals(evt.layerData.tag, n"AerialTakedown") || Equals(evt.layerData.tag, n"Loot") || Equals(evt.layerData.tag, n"GenericTalk") || Equals(evt.layerData.tag, n"ReturnTalk") || Equals(evt.layerData.tag, n"BossTakedownLayer") || Equals(evt.layerData.tag, n"MassiveTargetTakedownLayer") {
        this.CreateObjectActionsCallbackController(evt.activator);
        (this.GetPS() as ScriptedPuppetPS).AddActiveContext(gamedeviceRequestType.Direct);
        requestType = gamedeviceRequestType.Direct;
      };
      if NotEquals(requestType, IntEnum(0l)) {
        context.requestType = requestType;
        context.processInitiatorObject = playerPuppet;
        context.interactionLayerTag = evt.layerData.tag;
        (this.GetPS() as ScriptedPuppetPS).DetermineInteractionState(this.m_interactionComponent, context, this.m_objectActionsCallbackCtrl);
      };
    } else {
      if this.IsQualityRangeInteractionLayer(evt.layerData.tag) && evt.activator.IsPlayer() {
        actorUpdateData = new HUDActorUpdateData();
        actorUpdateData.updateIsInIconForcedVisibilityRange = true;
        actorUpdateData.isInIconForcedVisibilityRangeValue = false;
        this.RequestHUDRefresh(actorUpdateData);
      };
      this.m_interactionComponent.ResetChoices(evt.layerData.tag);
      if Equals(evt.layerData.tag, n"Grapple") || Equals(evt.layerData.tag, n"TakedownLayer") || Equals(evt.layerData.tag, n"AerialTakedown") || Equals(evt.layerData.tag, n"Loot") || Equals(evt.layerData.tag, n"GenericTalk") || Equals(evt.layerData.tag, n"ReturnTalk") || Equals(evt.layerData.tag, n"BossTakedownLayer") || Equals(evt.layerData.tag, n"MassiveTargetTakedownLayer") {
        (this.GetPS() as ScriptedPuppetPS).RemoveActiveContext(gamedeviceRequestType.Direct);
        this.DestroyObjectActionsCallbackController();
      };
    };
  }

  protected cb func OnInteractionUsed(evt: ref<InteractionChoiceEvent>) -> Bool {
    this.ExecuteAction(evt.choice);
    this.ProcessSyncedAnimationPuppetActions(evt);
    if NotEquals(evt.layerData.tag, n"Loot") {
      this.m_interactionComponent.ResetChoices();
    };
  }

  protected final func ExecuteAction(choice: InteractionChoice) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let i: Int32;
    if ChoiceTypeWrapper.IsType(choice.choiceMetaData.type, gameinteractionsChoiceType.CheckFailed) {
      return;
    };
    i = 0;
    while i < ArraySize(choice.data) {
      action = FromVariant(choice.data[i]);
      if IsDefined(action) {
        this.ExecuteAction(action);
      };
      i += 1;
    };
  }

  protected cb func OnExecutePuppetAction(evt: ref<ExecutePuppetActionEvent>) -> Bool {
    let action: ref<PuppetAction>;
    if evt.action == null {
      action = new PuppetAction();
    } else {
      action = evt.action;
    };
    action.SetObjectActionID(evt.actionID);
    action.SetUp(this.GetPS());
    action.SetExecutor(GetPlayer(this.GetGame()));
    this.ExecuteAction(action);
  }

  protected cb func OnCommunicationEvent(evt: ref<CommunicationEvent>) -> Bool {
    if evt.sender == this.GetEntityID() {
      return false;
    };
    switch evt.name {
      case n"InvestigationStarted":
        break;
      case n"HeavyReload":
        if this.IsPlayer() {
          ReactionManagerComponent.SendVOEventToSquad(this, n"heavy_reloading");
        } else {
          if ScriptedPuppet.IsPlayerCompanion(this) {
            GameObject.PlayVoiceOver(this, n"heavy_reloading", n"Scripts:HeavyReloadCommunicationEvent");
          };
        };
        break;
      case n"HeavyShooting":
        if this.IsPlayer() {
          ReactionManagerComponent.SendVOEventToSquad(this, n"heavy_warning");
        } else {
          if ScriptedPuppet.IsPlayerCompanion(this) {
            GameObject.PlayVoiceOver(this, n"heavy_warning", n"Scripts:HeavyReloadCommunicationEvent");
          };
        };
        break;
      case n"SniperShooting":
        if this.IsPlayer() {
          ReactionManagerComponent.SendVOEventToSquad(this, n"sniper_warning");
        } else {
          if ScriptedPuppet.IsPlayerCompanion(this) {
            GameObject.PlayVoiceOver(this, n"sniper_warning", n"Scripts:HeavyReloadCommunicationEvent");
          };
        };
        break;
      case n"NetrunnerHacking":
        if this.IsPlayer() {
          ReactionManagerComponent.SendVOEventToSquad(this, n"netrunner_warning");
        } else {
          if ScriptedPuppet.IsPlayerCompanion(this) {
            GameObject.PlayVoiceOver(this, n"netrunner_warning", n"Scripts:HeavyReloadCommunicationEvent");
          };
        };
        break;
      default:
    };
  }

  private final func ShowQuickHackDuration(action: ref<ScriptableDeviceAction>) -> Void {
    let actionDurationListener: ref<QuickHackDurationListener>;
    let statMod: ref<gameStatModifierData>;
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    GameInstance.GetStatsSystem(this.GetGame()).RemoveAllModifiers(Cast(this.GetEntityID()), gamedataStatType.QuickHackUpload, true);
    statMod = RPGManager.CreateStatModifier(gamedataStatType.QuickHackUpload, gameStatModifierType.Additive, 1.00);
    GameInstance.GetStatsSystem(this.GetGame()).RemoveAllModifiers(Cast(this.GetEntityID()), gamedataStatType.QuickHackUpload);
    GameInstance.GetStatsSystem(this.GetGame()).AddModifier(Cast(this.GetEntityID()), statMod);
    actionDurationListener = new QuickHackDurationListener();
    actionDurationListener.m_action = action;
    actionDurationListener.m_gameInstance = this.GetGame();
    statPoolSys.RequestRegisteringListener(Cast(this.GetEntityID()), gamedataStatPoolType.QuickHackUpload, actionDurationListener);
    statPoolSys.RequestAddingStatPool(Cast(this.GetEntityID()), t"BaseStatPools.BaseQuickHackUpload");
  }

  protected final func ExecuteAction(action: ref<ScriptableDeviceAction>) -> Void {
    action.RegisterAsRequester(this.GetEntityID());
    action.ProcessRPGAction(this.GetGame());
  }

  protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let hotspotPlayer: ref<PlayerPuppet>;
    let resurrect: ref<ResurrectEvent>;
    let choice: String = choiceEvent.choice.choiceMetaData.tweakDBName;
    if Equals(choice, "Loot") {
      this.LootAllItems(choiceEvent);
    } else {
      if Equals(choice, "Revive") {
        hotspotPlayer = choiceEvent.hotspot as PlayerPuppet;
        if IsDefined(hotspotPlayer) {
          resurrect = new ResurrectEvent();
          hotspotPlayer.QueueEvent(resurrect);
        };
      };
    };
    if Equals(choiceEvent.layerData.tag, n"Loot") {
      RPGManager.ToggleLootHighlight(this, false);
    };
    RPGManager.ProcessReadAction(choiceEvent);
    this.OrderChoice(choiceEvent);
  }

  private final func LootAllItems(choiceEvent: ref<InteractionChoiceEvent>) -> Void {
    GameInstance.GetTransactionSystem(this.GetGame()).TransferAllItems(this, choiceEvent.activator);
  }

  protected cb func OnWorkspotStartedEvent(evt: ref<WorkspotStartedEvent>) -> Bool {
    this.m_currentWorkspotTags = evt.tags;
    if VehicleComponent.IsMountedToVehicle(this.GetGame(), this) {
      VehicleComponent.SetAnimsetOverrideForPassenger(this, 1.00);
    };
    if ArrayContains(evt.tags, n"Grappled") {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(this.GetEntityID(), t"BaseStatusEffect.Grappled");
    };
    if ArrayContains(evt.tags, n"BlockGrapple") {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(this.GetEntityID(), t"BaseStatusEffect.BlockGrapple");
    };
  }

  protected cb func OnWorkspotFinishedEvent(evt: ref<WorkspotFinishedEvent>) -> Bool {
    ArrayClear(this.m_currentWorkspotTags);
    if ArrayContains(evt.tags, n"Grappled") {
      GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveStatusEffect(this.GetEntityID(), t"BaseStatusEffect.Grappled");
    };
    if ArrayContains(evt.tags, n"BlockGrapple") {
      GameInstance.GetStatusEffectSystem(this.GetGame()).RemoveStatusEffect(this.GetEntityID(), t"BaseStatusEffect.BlockGrapple");
    };
  }

  private final func ProcessSyncedAnimationPuppetActions(evt: ref<InteractionChoiceEvent>) -> Void {
    let interactionLayer: CName = evt.layerData.tag;
    if Equals(interactionLayer, n"Grapple") || Equals(interactionLayer, n"TakedownLayer") || Equals(interactionLayer, n"BossTakedownLayer") || Equals(interactionLayer, n"MassiveTargetTakedownLayer") {
      this.PushTakedownActionEventToPSM(evt);
      this.EnableInteraction(n"AerialTakedown", false);
    };
  }

  private final func PushTakedownActionEventToPSM(evt: ref<InteractionChoiceEvent>) -> Void {
    let takedownEvent: ref<StartTakedownEvent> = new StartTakedownEvent();
    takedownEvent.slideTime = 0.80;
    takedownEvent.target = evt.hotspot;
    takedownEvent.actionName = StringToName(evt.choice.choiceMetaData.tweakDBName);
    evt.activator.QueueEvent(takedownEvent);
  }

  private final func CreateTakedownEventOnLayerActivation(evt: ref<InteractionActivationEvent>) -> Void {
    let takedownEvent: ref<StartTakedownEvent> = new StartTakedownEvent();
    takedownEvent.slideTime = 0.30;
    takedownEvent.target = evt.hotspot;
    takedownEvent.actionName = evt.layerData.tag;
    this.EnableInteraction(evt.layerData.tag, false);
    evt.activator.QueueEvent(takedownEvent);
  }

  private final func OrderChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Void {
    let orderTakedownEvent: ref<OrderTakedownEvent>;
    let choice: String = choiceEvent.choice.choiceMetaData.tweakDBName;
    if Equals(AISquadHelper.PlayerSquadOrderStringToEnum(choice), EAIPlayerSquadOrder.Takedown) {
      orderTakedownEvent = new OrderTakedownEvent();
      orderTakedownEvent.target = this;
      choiceEvent.activator.QueueEvent(orderTakedownEvent);
    };
  }

  protected cb func OnDelayedTakedownGameEffectEvent(evt: ref<DelayedGameEffectEvent>) -> Bool {
    TakedownGameEffectHelper.FillTakedownData(this, evt.m_activator, evt.m_target, evt.m_effectName, evt.m_effectTag, evt.m_statusEffect);
  }

  private final func SendInteractionChoiceToPSM(choiceEvent: ref<InteractionChoiceEvent>, id: CName, isChoiceActive: Bool) -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = id;
    psmEvent.value = isChoiceActive;
    choiceEvent.activator.QueueEvent(psmEvent);
  }

  public final func EnableSensesComponent(b: Bool) -> Void {
    this.m_sensesComponent.Toggle(b);
  }

  public final func EnableInteraction(layer: CName, b: Bool) -> Void {
    let interactionEvent: ref<InteractionSetEnableEvent> = new InteractionSetEnableEvent();
    interactionEvent.enable = b;
    interactionEvent.layer = layer;
    this.QueueEvent(interactionEvent);
  }

  public const func IsQuest() -> Bool {
    return this.IsQuest() || this.m_hasQuestItems;
  }

  protected cb func OnRegisterPostion(evt: ref<RegisterPostionEvent>) -> Bool {
    this.m_exposePosition = evt.start;
  }

  public final static func RequestRevealOutline(obj: ref<GameObject>, doReveal: Bool, whoWantsToReveal: EntityID) -> Void {
    let evt: ref<RevealRequestEvent>;
    if !IsDefined(obj) {
      return;
    };
    evt = new RevealRequestEvent();
    evt.CreateRequest(doReveal, whoWantsToReveal);
    obj.QueueEvent(evt);
  }

  protected cb func OnRevealRequest(evt: ref<RevealRequestEvent>) -> Bool {
    let toggleEvt: ref<RevealRequestEvent>;
    this.RequestRevealOutline(evt.GetShouldReveal(), evt.GetRequester());
    if Equals(evt.GetShouldReveal(), true) && evt.IsOneFrame() {
      toggleEvt = new RevealRequestEvent();
      toggleEvt.CreateRequest(false, evt.GetRequester());
      this.QueueEvent(toggleEvt);
    };
  }

  private final func RequestRevealOutline(shouldIncreaseCounter: Bool, requester: EntityID) -> Void {
    let i: Int32;
    if !EntityID.IsDefined(requester) {
      LogPuppet("RequestRevealOutline \\ Illegal requester. Request rejected. Requester to string = " + EntityID.ToDebugString(requester));
      return;
    };
    if !ScriptedPuppet.IsAlive(this) && !ScriptedPuppet.IsDefeated(this) {
      return;
    };
    if !IsDefined(this.m_shouldBeRevealedStorage) {
      this.m_shouldBeRevealedStorage = new RevealRequestsStorage();
    };
    if this.m_shouldBeRevealedStorage.IsRequesterLegal(requester, shouldIncreaseCounter) {
      this.m_shouldBeRevealedStorage.RegisterLegalRequest(requester, shouldIncreaseCounter);
    };
    i = 0;
    while i < ArraySize(this.m_listeners) {
      this.m_listeners[i].OnRevealedStateChanged(this.m_shouldBeRevealedStorage.ShouldReveal());
      i += 1;
    };
  }

  public final static func ForceVisionAppearanceNetrunner(target: ref<GameObject>, sourceID: EntityID, sourceName: CName, toggle: Bool) -> Void {
    let visionEvt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    let data: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    data.sourceID = sourceID;
    data.sourceName = sourceName;
    data.outlineType = EFocusOutlineType.ENEMY_NETRUNNER;
    data.highlightType = EFocusForcedHighlightType.ENEMY_NETRUNNER;
    data.priority = EPriority.High;
    data.isRevealed = true;
    data.patternType = VisionModePatternType.Netrunner;
    visionEvt.forcedHighlight = data;
    visionEvt.apply = toggle;
    target.QueueEvent(visionEvt);
  }

  public final const func HasQuestItems() -> Bool {
    return this.m_hasQuestItems;
  }

  public final const func IsRevealed() -> Bool {
    return this.m_shouldBeRevealedStorage.ShouldReveal();
  }

  public final const func GetPuppetRarity() -> ref<NPCRarity_Record> {
    return TweakDBInterface.GetCharacterRecord(this.GetRecordID()).Rarity();
  }

  public final const func GetPuppetRarityEnum() -> gamedataNPCRarity {
    return TweakDBInterface.GetCharacterRecord(this.GetRecordID()).Rarity().Type();
  }

  public final const func GetPuppetReactionPresetType() -> gamedataReactionPresetType {
    return TweakDBInterface.GetCharacterRecord(this.GetRecordID()).ReactionPreset().Type();
  }

  private final func CreateClearOutlinesRequest() -> Void {
    let request: ref<ClearOutlinesRequestEvent> = new ClearOutlinesRequestEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, request, 4.20);
  }

  private final func OnClearOutlinesRequest(evt: ref<ClearOutlinesRequestEvent>) -> Void {
    let i: Int32;
    this.m_shouldBeRevealedStorage.ClearAllRequests();
    i = 0;
    while i < ArraySize(this.m_listeners) {
      this.m_listeners[i].OnRevealedStateChanged(false);
      i += 1;
    };
  }

  protected cb func OnOutlineRequestEvent(evt: ref<OutlineRequestEvent>) -> Bool {
    Log("ScriptedPuppet \\ OutlineRequestEvent " + EntityID.ToDebugString(this.GetEntityID()));
    if !ScriptedPuppet.IsAlive(this) && !ScriptedPuppet.IsDefeated(this) {
      return false;
    };
    super.OnOutlineRequestEvent(evt);
    this.PropagateOutlineToCurrentlyUsedItems(evt);
  }

  private final func PropagateOutlineToCurrentlyUsedItems(evt: ref<OutlineRequestEvent>) -> Void {
    let heldObjects: array<ref<ItemObject>>;
    let i: Int32;
    if this.GetCurrentlyEquippedItems(heldObjects) {
      i = 0;
      while i < ArraySize(heldObjects) {
        this.QueueEventForEntityID(heldObjects[i].GetEntityID(), evt);
        i += 1;
      };
    };
  }

  private final func PropagateFadeOutlinesRequestToItems() -> Void {
    let fadeOutlineEvent: ref<ForceFadeOutlineEventForWeapon>;
    let heldObjects: array<ref<ItemObject>>;
    let i: Int32;
    if this.GetCurrentlyEquippedItems(heldObjects) {
      fadeOutlineEvent = new ForceFadeOutlineEventForWeapon();
      i = 0;
      while i < ArraySize(heldObjects) {
        this.QueueEventForEntityID(heldObjects[i].GetEntityID(), fadeOutlineEvent);
        i += 1;
      };
    };
  }

  private final func GetCurrentlyEquippedItems(out heldObjects: array<ref<ItemObject>>) -> Bool {
    let rightHandID: TweakDBID = t"AttachmentSlots.WeaponRight";
    let leftHandID: TweakDBID = t"AttachmentSlots.WeaponLeft";
    let rightHandItem: ref<ItemObject> = GameInstance.GetTransactionSystem(this.GetGame()).GetItemInSlot(this, rightHandID);
    let leftHandItem: ref<ItemObject> = GameInstance.GetTransactionSystem(this.GetGame()).GetItemInSlot(this, leftHandID);
    if IsDefined(rightHandItem) {
      ArrayPush(heldObjects, rightHandItem);
    };
    if IsDefined(leftHandItem) {
      ArrayPush(heldObjects, leftHandItem);
    };
    if ArraySize(heldObjects) > 0 {
      return true;
    };
    return false;
  }

  protected cb func OnToggleTargetingComponentsEvent(evt: ref<ToggleTargetingComponentsEvent>) -> Bool {
    let component: ref<TargetingComponent>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_targetingComponentsArray) {
      component = this.m_targetingComponentsArray[i];
      component.Toggle(evt.toggle);
      i += 1;
    };
  }

  protected cb func OnPulseEvent(evt: ref<gameVisionModeUpdateVisuals>) -> Bool;

  protected cb func OnScanningEvent(evt: ref<ScanningEvent>) -> Bool {
    if Equals(evt.state, gameScanningState.Complete) {
    } else {
      if Equals(evt.state, gameScanningState.Stopped) {
      } else {
        if Equals(evt.state, gameScanningState.Started) {
        };
      };
    };
  }

  protected cb func OnScanningLookAtEvent(evt: ref<ScanningLookAtEvent>) -> Bool {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.FindEntityByID(this.GetGame(), evt.ownerID) as PlayerPuppet;
    if IsDefined(playerPuppet) && evt.state {
      if this.IsDead() {
        return IsDefined(null);
      };
      this.UpdateScannerLookAtBB(true);
      if this.ShouldPulseNetwork() && !this.IsNetworkKnownToPlayer() {
        this.PulseNetwork(true);
      };
    } else {
      this.UpdateScannerLookAtBB(false);
    };
  }

  private final func UpdateScannerLookAtBB(b: Bool) -> Void {
    let scannerBlackboard: wref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Scanner);
    scannerBlackboard.SetBool(GetAllBlackboardDefs().UI_Scanner.ScannerLookAt, b);
  }

  private final func ShouldPulseNetwork() -> Bool {
    return !this.GetNetworkSystem().ShouldShowLinksOnMaster() && !this.IsBackdoor() && (this.GetPS() as ScriptedPuppetPS).IsConnectedToAccessPoint() && !this.IsNetworkKnownToPlayer();
  }

  public const func IsBackdoor() -> Bool {
    return this.IsOfficer() && (this.GetPS() as ScriptedPuppetPS).IsConnectedToAccessPoint();
  }

  public const func IsActiveBackdoor() -> Bool {
    return !(this.GetPS() as ScriptedPuppetPS).IsQuickHacksExposed() && this.IsOfficer() && (this.GetPS() as ScriptedPuppetPS).IsConnectedToAccessPoint();
  }

  public const func IsConnectedToBackdoorDevice() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).IsConnectedToAccessPoint();
  }

  public const func IsNetworkKnownToPlayer() -> Bool {
    if (this.GetPS() as ScriptedPuppetPS).IsConnectedToAccessPoint() {
      return (this.GetPS() as ScriptedPuppetPS).WasRevealedInNetworkPing() || (this.GetPS() as ScriptedPuppetPS).IsQuickHacksExposed();
    };
    return (this.GetPS() as ScriptedPuppetPS).WasRevealedInNetworkPing();
  }

  public const func IsHackingPlayer() -> Bool {
    return this.HasOutlineOrFill(EFocusForcedHighlightType.ENEMY_NETRUNNER, EFocusOutlineType.ENEMY_NETRUNNER);
  }

  public const func IsQuickHackAble() -> Bool {
    let actionRecords: array<wref<ObjectAction_Record>>;
    let i: Int32;
    if !this.IsActive() {
      return false;
    };
    if this.IsCrowd() {
      return false;
    };
    if this.IsPrevention() {
      return false;
    };
    if !this.IsAggressive() {
      return false;
    };
    if QuickhackModule.IsQuickhackBlockedByScene(Device.GetPlayerMainObjectStatic(this.GetGame())) {
      return false;
    };
    if this.GetRecord().GetObjectActionsCount() <= 0 {
      return false;
    };
    if !EquipmentSystem.IsCyberdeckEquipped(Device.GetPlayerMainObjectStatic(this.GetGame())) {
      return false;
    };
    this.GetRecord().ObjectActions(actionRecords);
    i = 0;
    while i < ArraySize(actionRecords) {
      if Equals(actionRecords[i].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public const func IsQuickHacksExposed() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).IsQuickHacksExposed();
  }

  public const func IsBreached() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).IsBreached();
  }

  public const func GetNetworkLinkSlotName() -> CName {
    let worldTransform: WorldTransform;
    if this.GetSlotComponent().GetSlotTransform(n"Chest", worldTransform) {
      return n"Chest";
    };
    return n"NetworkLink";
  }

  public const func GetNetworkLinkSlotName(out transform: WorldTransform) -> CName {
    if this.GetSlotComponent().GetSlotTransform(n"Chest", transform) {
      return n"Chest";
    };
    return n"NetworkLink";
  }

  public const func IsNetworkLinkDynamic() -> Bool {
    return true;
  }

  public const func ShouldShowScanner() -> Bool {
    if !IsDefined(this.m_scanningComponent) {
      return false;
    };
    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked() {
      return false;
    };
    return true;
  }

  protected func StartPingingNetwork() -> Void {
    let request: ref<StartPingingNetworkRequest> = new StartPingingNetworkRequest();
    request.source = this;
    request.fxResource = this.GetFxResourceByKey(n"pingNetworkLink");
    request.duration = this.m_scanningComponent.GetTimeNeeded();
    this.GetNetworkSystem().QueueRequest(request);
  }

  protected func PulseNetwork(revealNetworkAtEnd: Bool) -> Void {
    let duration: Float;
    let request: ref<StartPingingNetworkRequest>;
    if GameInstance.GetQuestsSystem(this.GetGame()).GetFact(n"pingingNetworkDisabled") > 0 {
      return;
    };
    request = new StartPingingNetworkRequest();
    duration = this.GetNetworkSystem().GetSpacePingDuration();
    request.source = this;
    request.fxResource = this.GetFxResourceByKey(n"pingNetworkLink");
    request.duration = duration;
    request.pingType = EPingType.SPACE;
    request.fakeLinkType = ELinkType.FREE;
    request.revealNetworkAtEnd = revealNetworkAtEnd;
    this.GetNetworkSystem().QueueRequest(request);
  }

  protected cb func OnRevealNetworkGridOnPulse(evt: ref<RevealNetworkGridOnPulse>) -> Bool {
    if this.GetNetworkSystem().ShouldRevealNetworkAfterPulse() {
      (this.GetPS() as ScriptedPuppetPS).SetRevealedInNetworkPing(true);
    };
    if this.IsCurrentlyScanned() {
    };
  }

  public const func CanOverrideNetworkContext() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).IsConnectedToAccessPoint();
  }

  protected func StopPingingNetwork() -> Void {
    let request: ref<StopPingingNetworkRequest> = new StopPingingNetworkRequest();
    this.GetNetworkSystem().QueueRequest(request);
  }

  public const func GetFxResourceByKey(key: CName) -> FxResource {
    let resource: FxResource;
    if IsDefined(this.m_resourceLibraryComponent) {
      resource = this.m_resourceLibraryComponent.GetResource(key);
    };
    return resource;
  }

  protected cb func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> Bool {
    this.RequestHUDRefresh();
  }

  public const func GetDeviceLink() -> ref<DeviceLinkComponentPS> {
    return PuppetDeviceLinkPS.AcquirePuppetDeviceLink(this.GetGame(), this.GetEntityID());
  }

  protected cb func OnAccessPointMiniGameStatus(evt: ref<AccessPointMiniGameStatus>) -> Bool {
    let easeOutCurve: CName;
    let emptyID: EntityID;
    let deviceLink: ref<PuppetDeviceLinkPS> = this.GetDeviceLink() as PuppetDeviceLinkPS;
    if IsDefined(deviceLink) {
      deviceLink.PerformNPCBreach(evt.minigameState);
      if Equals(evt.minigameState, HackingMinigameState.Failed) {
        deviceLink.TriggerSecuritySystemNotification(this.GetWorldPosition(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet, ESecurityNotificationType.ALARM);
      };
    };
    this.GetNetworkBlackboard().SetString(this.GetNetworkBlackboardDef().NetworkName, "");
    this.GetNetworkBlackboard().SetEntityID(this.GetNetworkBlackboardDef().DeviceID, emptyID);
    easeOutCurve = TweakDBInterface.GetCName(t"timeSystem.nanoWireBreach.easeOutCurve", n"DiveEaseOut");
    GameInstance.GetTimeSystem(this.GetGame()).UnsetTimeDilation(n"NetworkBreach", easeOutCurve);
    QuickhackModule.RequestRefreshQuickhackMenu(this.GetGame(), this.GetEntityID());
  }

  public final func OnDiveFinished(reason: CName) -> Void;

  private final func GetNetworkBlackboard() -> ref<IBlackboard> {
    return GameInstance.GetBlackboardSystem(this.GetGame()).Get(this.GetNetworkBlackboardDef());
  }

  private final func GetNetworkBlackboardDef() -> ref<NetworkBlackboardDef> {
    return GetAllBlackboardDefs().NetworkBlackboard;
  }

  protected cb func OnRevealDeviceRequest(evt: ref<RevealDeviceRequest>) -> Bool {
    let revealEvent: ref<RevealObjectEvent> = new RevealObjectEvent();
    revealEvent.reveal = evt.shouldReveal;
    revealEvent.reason.reason = n"network";
    revealEvent.reason.sourceEntityId = evt.sourceID;
    if this.GetNetworkSystem().SuppressPingIfBackdoorsFound() {
      if evt.linkData.isPing && Equals(evt.linkData.linkType, ELinkType.NETWORK) {
        (this.GetPS() as ScriptedPuppetPS).SetRevealedInNetworkPing(true);
      };
    };
    this.QueueEvent(revealEvent);
  }

  public final static func RequestDeviceDebug(obj: ref<GameObject>, device: wref<Device>) -> Void {
    let evt: ref<RegisterDebuggerCanditateEvent> = new RegisterDebuggerCanditateEvent();
    evt.m_device = device;
    obj.QueueEvent(evt);
  }

  public final static func SetBloodPuddleSettings(puppet: ref<GameObject>, shouldSpawnBloodPuddle: Bool) -> Void {
    let settingsEvent: ref<SetBloodPuddleSettingsEvent> = new SetBloodPuddleSettingsEvent();
    settingsEvent.shouldSpawnBloodPuddle = shouldSpawnBloodPuddle;
    if IsDefined(puppet) {
      puppet.QueueEvent(settingsEvent);
    };
  }

  protected cb func OnSetBloodPuddleSettingsEvent(evt: ref<SetBloodPuddleSettingsEvent>) -> Bool {
    this.m_shouldSpawnBloodPuddle = evt.shouldSpawnBloodPuddle;
  }

  public final const func ShouldSpawnBloodPuddle() -> Bool {
    return this.m_shouldSpawnBloodPuddle;
  }

  protected cb func OnBloodPuddleEvent(evt: ref<BloodPuddleEvent>) -> Bool {
    let dismemberedLimbCount: DismemberedLimbCount;
    let downVector: Vector4;
    let effect: ref<EffectInstance>;
    let position: Vector4;
    let slotExists: Bool;
    let slotTransform: WorldTransform;
    if !this.m_bloodPuddleSpawned {
      downVector.X = 0.00;
      downVector.Y = 0.00;
      downVector.Z = -1.00;
      dismemberedLimbCount = this.m_dismembermentComponent.GetDismemberedLimbCount();
      if dismemberedLimbCount.cyberDismemberments != 0u || dismemberedLimbCount.fleshDismemberments != 0u {
        evt.cyberBlood = dismemberedLimbCount.cyberDismemberments > dismemberedLimbCount.fleshDismemberments;
      };
      slotExists = this.m_slotComponent.GetSlotTransform(evt.m_slotName, slotTransform);
      if slotExists {
        position = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
      } else {
        position = this.GetWorldPosition();
      };
      if evt.cyberBlood {
        effect = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(n"npcBloodPuddle", n"cyber", this);
      } else {
        effect = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(n"npcBloodPuddle", n"blood", this);
      };
      if !IsDefined(effect) {
        return false;
      };
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, downVector);
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 1.50);
      effect.Run();
      this.m_bloodPuddleSpawned = true;
    };
  }

  public final const func ShouldSkipDeathAnimation() -> Bool {
    return this.m_skipDeathAnimation;
  }

  public final func SetSkipDeathAnimation(value: Bool) -> Void {
    this.m_skipDeathAnimation = value;
  }

  public const func IsConnectedToSecuritySystem() -> Bool {
    return (this.GetPS() as ScriptedPuppetPS).IsConnectedToSecuritySystem();
  }

  public const func IsTargetTresspassingMyZone(target: ref<GameObject>) -> Bool {
    if !this.IsConnectedToSecuritySystem() {
      return false;
    };
    if (this.GetPS() as ScriptedPuppetPS).GetSecuritySystem().IsTargetTresspassingMyZone(target.GetEntityID(), this.GetEntityID()) {
      return true;
    };
    return false;
  }

  public final const func GetDeterminatedSecurityAreaType() -> ESecurityAreaType {
    return (this.GetPS() as ScriptedPuppetPS).DetermineSecurityAreaTypeForEntityID(this.GetEntityID());
  }

  public final const func MySecuritySystemState() -> ESecuritySystemState {
    return (this.GetPS() as ScriptedPuppetPS).GetSecuritySystem().GetSecurityState();
  }

  public const func GetSecuritySystem() -> ref<SecuritySystemControllerPS> {
    let secSys: ref<SecuritySystemControllerPS> = (this.GetPS() as ScriptedPuppetPS).GetSecuritySystem();
    if IsDefined(secSys) && !secSys.IsDisabled() {
      return secSys;
    };
    return null;
  }

  protected cb func OnSuppressNPCInSecuritySystem(evt: ref<SuppressNPCInSecuritySystem>) -> Bool {
    let link: ref<PuppetDeviceLinkPS> = this.GetDeviceLink() as PuppetDeviceLinkPS;
    if IsDefined(link) {
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(link.GetID(), link.GetClassName(), evt);
    };
  }

  public final const func TriggerSecuritySystemNotification(lastKnownPosition: Vector4, threat: wref<GameObject>, type: ESecurityNotificationType, opt stimType: gamedataStimType) -> Void {
    if IsDefined(threat) {
      if IsDefined(threat as ScriptedPuppet) {
        if NotEquals(type, ESecurityNotificationType.ALARM) && ((threat as ScriptedPuppet).IsCharacterCivilian() || Equals(this.GetAttitudeTowards(threat), EAIAttitude.AIA_Friendly)) {
          return;
        };
      };
      if IsDefined(this.GetDeviceLink()) {
        this.GetDeviceLink().TriggerSecuritySystemNotification(lastKnownPosition, threat, type, stimType);
      };
    };
  }

  public final func OnSecuritySupportThreshold(above: Bool) -> Void {
    if !above {
      (this.GetDeviceLink() as PuppetDeviceLinkPS).NotifyAboutSpottingPlayer(false);
    };
  }

  protected cb func OnSecurityAreaCrossingPerimeter(evt: ref<SecurityAreaCrossingPerimeter>) -> Bool;

  protected cb func OnItemAddedToSlot(evt: ref<ItemAddedToSlot>) -> Bool {
    let cacheItemPSEvt: ref<CacheItemEquippedToHandsEvent>;
    let handEquipSlot: EHandEquipSlot;
    let i: Int32;
    let isInWorkspot: Bool;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let workspotSystem: ref<WorkspotGameSystem>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.GetItemID()));
    itemRecord.OnAttach(packages);
    i = 0;
    while i < ArraySize(packages) {
      RPGManager.ApplyGLP(this, packages[i]);
      i += 1;
    };
    if !this.IsPlayer() {
      handEquipSlot = IntEnum(0l);
      if evt.GetSlotID() == t"AttachmentSlots.WeaponLeft" {
        handEquipSlot = EHandEquipSlot.Left;
      } else {
        if evt.GetSlotID() == t"AttachmentSlots.WeaponRight" {
          handEquipSlot = EHandEquipSlot.Right;
        };
      };
      workspotSystem = GameInstance.GetWorkspotSystem(this.GetGame());
      isInWorkspot = workspotSystem.IsActorInWorkspot(this);
      if NotEquals(handEquipSlot, IntEnum(0l)) && !isInWorkspot {
        cacheItemPSEvt = new CacheItemEquippedToHandsEvent();
        cacheItemPSEvt.m_itemID = evt.GetItemID();
        cacheItemPSEvt.m_slot = handEquipSlot;
        this.SendEventToDefaultPS(cacheItemPSEvt);
      };
    };
  }

  protected cb func OnItemRemovedFromSlot(evt: ref<ItemRemovedFromSlot>) -> Bool {
    let cacheItemPSEvt: ref<CacheItemEquippedToHandsEvent>;
    let handEquipSlot: EHandEquipSlot;
    let i: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.GetItemID()));
    itemRecord.OnAttach(packages);
    i = 0;
    while i < ArraySize(packages) {
      RPGManager.RemoveGLP(this, packages[i]);
      i += 1;
    };
    if !this.IsPlayer() {
      handEquipSlot = IntEnum(0l);
      if evt.GetSlotID() == t"AttachmentSlots.WeaponLeft" {
        handEquipSlot = EHandEquipSlot.Left;
      } else {
        if evt.GetSlotID() == t"AttachmentSlots.WeaponRight" {
          handEquipSlot = EHandEquipSlot.Right;
        };
      };
      if NotEquals(handEquipSlot, IntEnum(0l)) {
        cacheItemPSEvt = new CacheItemEquippedToHandsEvent();
        cacheItemPSEvt.m_itemID = new ItemID();
        cacheItemPSEvt.m_slot = handEquipSlot;
        this.SendEventToDefaultPS(cacheItemPSEvt);
      };
    };
  }

  public final func HandleSquadAction(actionName: CName, verb: EAISquadVerb) -> Void {
    this.GetSquadMemberComponent().PerformSquadVerb(actionName, verb);
  }

  public final func OnSignalSquadActionSignal(signalId: Uint16, newValue: Bool) -> Void {
    let signalTable: ref<gameBoolSignalTable>;
    if newValue {
      signalTable = this.GetAIControllerComponent().GetSignals();
      this.GetSquadMemberComponent().OnSquadActionSignalReceived(signalTable.GetCurrentData(signalId) as SquadActionSignal);
    };
  }

  public final func OnSignalNPCStateChangeSignal(signalId: Uint16, newValue: Bool, userData: ref<NPCStateChangeSignal>) -> Void {
    if newValue {
      this.GetStatesComponent().OnNPCStateChangeSignalReceived(userData);
    };
  }

  public final func OnSignalForcedRagdollDeathSignal(signalId: Uint16, newValue: Bool, userData: ref<ForcedRagdollDeathSignal>) -> Void {
    let signalTable: ref<gameBoolSignalTable>;
    if newValue {
      signalTable = this.GetAIControllerComponent().GetSignals();
      this.GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.ForceRagdollOnDeath, signalTable.GetCurrentData(signalId) as ForcedRagdollDeathSignal.m_value);
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    if this.IsContainer() {
      return EGameplayRole.Loot;
    };
    if !this.IsCrowd() || (this.GetPS() as ScriptedPuppetPS).IsConnectedToAccessPoint() || (this.GetPS() as ScriptedPuppetPS).IsQuickHacksExposed() {
      return EGameplayRole.NPC;
    };
    return this.DeterminGameplayRole();
  }

  private final func ResolveQualityRangeInteractionLayer() -> Void {
    let currentLayer: CName;
    let evt: ref<InteractionSetEnableEvent>;
    if IsNameValid(this.m_activeQualityRangeInteraction) {
      evt = new InteractionSetEnableEvent();
      evt.enable = false;
      evt.layer = this.m_activeQualityRangeInteraction;
      this.QueueEvent(evt);
      this.m_activeQualityRangeInteraction = n"";
    };
    if NotEquals(this.m_lootQuality, gamedataQuality.Invalid) && NotEquals(this.m_lootQuality, gamedataQuality.Random) {
      evt = new InteractionSetEnableEvent();
      evt.enable = true;
      if this.IsQuest() {
        currentLayer = n"QualityRange_Max";
      } else {
        if Equals(this.m_lootQuality, gamedataQuality.Common) {
          currentLayer = n"QualityRange_Short";
        } else {
          if Equals(this.m_lootQuality, gamedataQuality.Uncommon) {
            currentLayer = n"QualityRange_Medium";
          } else {
            if Equals(this.m_lootQuality, gamedataQuality.Rare) {
              currentLayer = n"QualityRange_Medium";
            } else {
              if Equals(this.m_lootQuality, gamedataQuality.Epic) {
                currentLayer = n"QualityRange_Max";
              } else {
                if Equals(this.m_lootQuality, gamedataQuality.Legendary) {
                  currentLayer = n"QualityRange_Max";
                } else {
                  if Equals(this.m_lootQuality, gamedataQuality.Iconic) {
                    currentLayer = n"QualityRange_Max";
                  };
                };
              };
            };
          };
        };
      };
      evt.layer = currentLayer;
      this.m_activeQualityRangeInteraction = currentLayer;
      this.QueueEvent(evt);
    };
  }

  private final func IsQualityRangeInteractionLayer(layerTag: CName) -> Bool {
    return Equals(layerTag, n"QualityRange_Short") || Equals(layerTag, n"QualityRange_Medium") || Equals(layerTag, n"QualityRange_Max");
  }

  protected final func UpdateLootInteraction() -> Void {
    this.EnableInteraction(n"Loot", !this.IsActive() && this.m_inventoryComponent.IsAccessible());
  }

  public final const func EvaluateLootQualityEvent() -> Void {
    let evt: ref<EvaluateLootQualityEvent> = new EvaluateLootQualityEvent();
    GameInstance.GetPersistencySystem(this.GetGame()).QueueEntityEvent(this.GetEntityID(), evt);
  }

  public final static func EvaluateLootQuality(self: wref<GameObject>) -> Void {
    let evt: ref<EvaluateLootQualityEvent>;
    if self != null {
      evt = new EvaluateLootQualityEvent();
      self.QueueEvent(evt);
    };
  }

  protected cb func OnEvaluateLootQuality(evt: ref<EvaluateLootQualityEvent>) -> Bool {
    if this.EvaluateLootQuality() {
      this.RequestHUDRefresh();
    };
  }

  private final func EvaluateLootQuality() -> Bool {
    let i: Int32;
    let items: array<wref<gameItemData>>;
    let iteratedQuality: gamedataQuality;
    let lastValue: Int32;
    let newValue: Int32;
    let qualityToSet: gamedataQuality;
    let type: gamedataItemType;
    let wasChanged: Bool;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    let currentQuality: gamedataQuality = this.m_lootQuality;
    let isCurrentlyQuest: Bool = this.IsQuest();
    let isCurrentlyIconic: Bool = this.GetIsIconic();
    this.m_isIconic = false;
    if transactionSystem.GetItemList(this, items) {
      if ArraySize(items) > 0 {
        qualityToSet = gamedataQuality.Common;
      };
      i = 0;
      while i < ArraySize(items) {
        type = items[i].GetItemType();
        if Equals(type, gamedataItemType.Con_Ammo) {
        } else {
          if !this.m_hasQuestItems && items[i].HasTag(n"Quest") {
            this.m_hasQuestItems = true;
          };
          iteratedQuality = RPGManager.GetItemDataQuality(items[i]);
          newValue = UIItemsHelper.QualityEnumToInt(iteratedQuality);
          if newValue > lastValue {
            lastValue = newValue;
            qualityToSet = iteratedQuality;
          };
          this.m_isIconic = this.m_isIconic || RPGManager.IsItemIconic(items[i]);
        };
        i += 1;
      };
      this.m_lootQuality = qualityToSet;
    };
    if NotEquals(isCurrentlyQuest, this.IsQuest()) {
      RPGManager.ToggleLootHighlight(this, this.IsQuest());
    };
    wasChanged = NotEquals(this.m_lootQuality, currentQuality) || NotEquals(isCurrentlyQuest, this.IsQuest()) || NotEquals(isCurrentlyIconic, this.m_isIconic);
    if wasChanged || !IsNameValid(this.m_activeQualityRangeInteraction) {
      this.ResolveQualityRangeInteractionLayer();
    };
    return wasChanged;
  }

  public const func GetLootQuality() -> gamedataQuality {
    return this.m_lootQuality;
  }

  public const func GetIsIconic() -> Bool {
    return this.m_isIconic;
  }

  public const func IsContainer() -> Bool {
    if NotEquals(this.m_lootQuality, gamedataQuality.Invalid) && NotEquals(this.m_lootQuality, gamedataQuality.Random) {
      return true;
    };
    return false;
  }

  protected final const func HasLoot() -> Bool {
    let itemList: array<wref<gameItemData>>;
    let object: ref<GameObject> = EntityGameInterface.GetEntity(this.GetEntity()) as GameObject;
    GameInstance.GetTransactionSystem(this.GetGame()).GetItemList(object, itemList);
    return ArraySize(itemList) > 0;
  }

  protected final const func HasValidLootQuality() -> Bool {
    return NotEquals(this.m_lootQuality, gamedataQuality.Invalid) && NotEquals(this.m_lootQuality, gamedataQuality.Random);
  }

  protected cb func OnInventoryEmptyEvent(evt: ref<OnInventoryEmptyEvent>) -> Bool {
    if this.HasValidLootQuality() {
      this.m_lootQuality = gamedataQuality.Invalid;
      GameObject.UntagObject(this);
      if !this.ShouldRegisterToHUD() {
        this.RegisterToHUDManagerByTask(false);
      } else {
        this.RequestHUDRefresh();
      };
      this.ResolveQualityRangeInteractionLayer();
    };
    if this.IsQuest() {
      RPGManager.ToggleLootHighlight(this, false);
    };
  }

  protected cb func OnItemRemovedEvent(evt: ref<ItemBeingRemovedEvent>) -> Bool {
    let quality: gamedataQuality;
    if this.HasValidLootQuality() {
      quality = RPGManager.GetItemDataQuality(evt.itemData);
      if Equals(quality, this.m_lootQuality) {
        if this.EvaluateLootQuality() {
          this.RequestHUDRefresh();
        };
      };
    };
  }

  protected cb func OnItemAddedEvent(evt: ref<ItemAddedEvent>) -> Bool {
    if this.HasValidLootQuality() {
      if this.EvaluateLootQuality() {
        this.RequestHUDRefresh();
      };
    };
  }

  protected cb func OnInventoryChangedEvent(evt: ref<InventoryChangedEvent>) -> Bool {
    if this.HasValidLootQuality() {
      if this.EvaluateLootQuality() {
        this.RequestHUDRefresh();
      };
    };
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    if !this.IsActive() && !ScriptedPuppet.HasLootableItems(EntityGameInterface.GetEntity(this.GetEntity()) as ScriptedPuppet) {
      return null;
    };
    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked() {
      return null;
    };
    highlight = new FocusForcedHighlightData();
    highlight.outlineType = this.GetCurrentOutline();
    switch highlight.outlineType {
      case EFocusOutlineType.QUEST:
        highlight.highlightType = EFocusForcedHighlightType.QUEST;
        break;
      case EFocusOutlineType.ITEM:
        highlight.highlightType = EFocusForcedHighlightType.ITEM;
        break;
      case EFocusOutlineType.HOSTILE:
        highlight.highlightType = EFocusForcedHighlightType.HOSTILE;
        break;
      case EFocusOutlineType.FRIENDLY:
        highlight.highlightType = EFocusForcedHighlightType.FRIENDLY;
        break;
      case EFocusOutlineType.NEUTRAL:
        highlight.highlightType = EFocusForcedHighlightType.NEUTRAL;
        break;
      default:
        return null;
    };
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();
    if this.IsQuickHackAble() {
      highlight.patternType = VisionModePatternType.Netrunner;
    } else {
      highlight.patternType = VisionModePatternType.Default;
    };
    return highlight;
  }

  public const func GetCurrentOutline() -> EFocusOutlineType {
    let attitude: EAIAttitude;
    let outlineType: EFocusOutlineType;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if this.IsQuest() {
      return EFocusOutlineType.QUEST;
    };
    if !this.IsActive() {
      return EFocusOutlineType.ITEM;
    };
    attitude = GameObject.GetAttitudeTowards(this, playerPuppet);
    if this.IsAggressive() || this.IsBoss() {
      if Equals(attitude, EAIAttitude.AIA_Friendly) {
        outlineType = EFocusOutlineType.FRIENDLY;
      } else {
        if this.IsPrevention() && Equals(attitude, EAIAttitude.AIA_Neutral) {
          outlineType = EFocusOutlineType.NEUTRAL;
        } else {
          outlineType = EFocusOutlineType.HOSTILE;
        };
      };
    } else {
      if this.IsTaggedinFocusMode() {
        outlineType = EFocusOutlineType.NEUTRAL;
      } else {
        outlineType = EFocusOutlineType.INVALID;
      };
    };
    return outlineType;
  }

  protected cb func OnRevealStateChanged(evt: ref<RevealStateChangedEvent>) -> Bool {
    if Equals(evt.state, ERevealState.STARTED) {
      this.ToggleForcedVisibilityInAnimSystem(n"RevealStateChangedEvent", true, 0.00, true);
    } else {
      if Equals(evt.state, ERevealState.STOPPED) {
        this.ToggleForcedVisibilityInAnimSystem(n"RevealStateChangedEvent", false, evt.transitionTime, true);
      };
    };
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    super.OnHUDInstruction(evt);
    if evt.quickhackInstruction.ShouldProcess() {
      this.TryOpenQuickhackMenu(evt.quickhackInstruction.ShouldOpen());
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let attackData: stimInvestigateData;
    let broadcaster: ref<StimBroadcasterComponent>;
    let reactionCmp: ref<ReactionManagerComponent>;
    super.OnHit(evt);
    this.m_hitHistory.AddHit(evt);
    if ScriptedPuppet.IsAlive(this) {
      GameObject.PlayVoiceOver(this, n"vo_any_damage_hit", n"Scripts:OnHit");
      TargetTrackingExtension.OnHit(this, evt);
    };
    if this.IsCharacterCivilian() || this.IsCrowd() {
      broadcaster = evt.attackData.GetInstigator().GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        if !evt.attackData.HasFlag(hitFlag.DealNoDamage) {
          broadcaster.SendDrirectStimuliToTarget(this, gamedataStimType.CombatHit, this);
        };
      };
    };
    if AttackData.IsMelee(evt.attackData.GetAttackType()) {
      attackData.attackInstigator = evt.attackData.GetInstigator();
      reactionCmp = (attackData.attackInstigator as ScriptedPuppet).GetStimReactionComponent();
      if evt.attackData.GetInstigator().IsPlayer() || IsDefined(reactionCmp) && NotEquals(reactionCmp.GetReactionPreset().Type(), gamedataReactionPresetType.NoReaction) {
        broadcaster = this.GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          if this.IsCharacterCivilian() || this.IsCrowd() {
            broadcaster = evt.attackData.GetInstigator().GetStimBroadcasterComponent();
            if IsDefined(broadcaster) {
              broadcaster.TriggerSingleBroadcast(this, gamedataStimType.CrimeWitness, 20.00);
            };
          };
          broadcaster.TriggerSingleBroadcast(this, gamedataStimType.MeleeHit, attackData);
        };
      };
    };
  }

  public final func GetLastDamageTimeFrom(threat: ref<GameObject>, out isMelee: Bool) -> Float {
    if threat == null {
      return -1.00;
    };
    return this.m_hitHistory.GetLastDamageTime(threat, isMelee);
  }

  public final const func GetGender() -> CName {
    return (this.GetPS() as ScriptedPuppetPS).GetGender();
  }

  protected const func ShouldRegisterToHUD() -> Bool {
    if !IsDefined(this.m_scanningComponent) && !IsDefined(this.m_visionComponent) {
      return false;
    };
    if this.m_forceRegisterInHudManager {
      return true;
    };
    if this.IsAnyClueEnabled() || this.IsQuest() {
      return true;
    };
    if !this.IsCrowd() && (this.IsActive() || this.IsContainer()) {
      return true;
    };
    return false;
  }

  public const func CanRevealRemoteActionsWheel() -> Bool {
    if !this.ShouldRegisterToHUD() {
      return false;
    };
    if !this.IsQuickHackAble() {
      return false;
    };
    return true;
  }

  public const func HasDirectActionsActive() -> Bool {
    let actionRecords: array<wref<ObjectAction_Record>>;
    let choices: array<InteractionChoice>;
    let context: GetActionsContext = (this.GetPS() as ScriptedPuppetPS).GenerateContext(gamedeviceRequestType.Direct, Device.GetInteractionClearance(), Device.GetPlayerMainObjectStatic(this.GetGame()), this.GetEntityID());
    (this.GetPS() as ScriptedPuppetPS).GetValidChoices(actionRecords, context, this.m_objectActionsCallbackCtrl, true, choices);
    if (this.GetPS() as ScriptedPuppetPS).HasDirectInteractionChoicesActive() {
      return true;
    };
    if (this.GetPS() as ScriptedPuppetPS).HasActiveContext(gamedeviceRequestType.Direct) && ArraySize(choices) > 0 {
      return true;
    };
    return false;
  }

  private final const func GetBlackboardIntVariable(id: BlackboardID_Int) -> Int32 {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(GetPlayer(this.GetGame()).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetInt(id);
  }

  protected func SendQuickhackCommands(shouldOpen: Bool) -> Void {
    let actionRecords: array<wref<ObjectAction_Record>>;
    let commands: array<ref<QuickhackData>>;
    let context: GetActionsContext;
    let puppatActions: array<ref<PuppetAction>>;
    let quickSlotsManagerNotification: ref<RevealInteractionWheel> = new RevealInteractionWheel();
    quickSlotsManagerNotification.lookAtObject = this;
    quickSlotsManagerNotification.shouldReveal = shouldOpen;
    if shouldOpen {
      context = (this.GetPS() as ScriptedPuppetPS).GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), this.GetEntityID());
      this.GetRecord().ObjectActions(actionRecords);
      (this.GetPS() as ScriptedPuppetPS).GetAllChoices(actionRecords, context, puppatActions);
      this.TranslateChoicesIntoQuickSlotCommands(puppatActions, commands);
      quickSlotsManagerNotification.commands = commands;
    };
    GameInstance.GetUISystem(this.GetGame()).QueueEvent(quickSlotsManagerNotification);
  }

  public final const func GetPingDuration() -> Float {
    let actionName: CName;
    let actionRecord: wref<ObjectAction_Record>;
    let actionRecords: array<wref<ObjectAction_Record>>;
    let i: Int32;
    let i1: Int32;
    let playerQHacksList: array<PlayerQuickhackData>;
    let puppatActions: array<ref<PuppetAction>>;
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    let context: GetActionsContext = (this.GetPS() as ScriptedPuppetPS).GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), this.GetEntityID());
    (this.GetPS() as ScriptedPuppetPS).GetAllChoices(actionRecords, context, puppatActions);
    playerQHacksList = RPGManager.GetPlayerQuickHackListWithQuality(player);
    i = 0;
    while i < ArraySize(playerQHacksList) {
      actionRecord = playerQHacksList[i].actionRecord;
      actionName = actionRecord.ActionName();
      if Equals(actionName, n"Ping") {
        i1 = 0;
        while i1 < ArraySize(actionRecords) {
          if Equals(actionRecord.ActionName(), actionRecords[i1].ActionName()) {
            if actionRecord.Priority() < actionRecords[i1].Priority() {
              actionRecord = actionRecords[i1];
            };
          };
          i += 1;
        };
        return this.GetQuickHackDuration(actionRecord, this, Cast(this.GetEntityID()), player.GetEntityID());
      };
      i += 1;
    };
    return 0.00;
  }

  private final const func GetQuickHackDuration(quickHackRecord: wref<ObjectAction_Record>, rootObject: wref<GameObject>, targetID: StatsObjectID, instigatorID: EntityID) -> Float {
    let durationMods: array<wref<ObjectActionEffect_Record>>;
    if !IsDefined(quickHackRecord) {
      return 0.00;
    };
    quickHackRecord.CompletionEffects(durationMods);
    return this.GetObjectActionEffectDurationValue(durationMods, rootObject, targetID, instigatorID);
  }

  private final const func GetQuickHackDuration(quickHackID: TweakDBID, rootObject: wref<GameObject>, targetID: StatsObjectID, instigatorID: EntityID) -> Float {
    let durationMods: array<wref<ObjectActionEffect_Record>>;
    let actionRecord: wref<ObjectAction_Record> = TweakDBInterface.GetObjectActionRecord(quickHackID);
    if !IsDefined(actionRecord) {
      return 0.00;
    };
    actionRecord.CompletionEffects(durationMods);
    return this.GetObjectActionEffectDurationValue(durationMods, rootObject, targetID, instigatorID);
  }

  private final const func GetObjectActionEffectDurationValue(durationMods: array<wref<ObjectActionEffect_Record>>, rootObject: wref<GameObject>, targetID: StatsObjectID, instigatorID: EntityID) -> Float {
    let duration: wref<StatModifierGroup_Record>;
    let durationValue: Float;
    let effectToCast: wref<StatusEffect_Record>;
    let i: Int32;
    let ignoredDurationStats: array<wref<StatusEffect_Record>>;
    let lastMatchingEffect: wref<StatusEffect_Record>;
    let statModifiers: array<wref<StatModifier_Record>>;
    if ArraySize(durationMods) > 0 {
      ignoredDurationStats = this.GetIgnoredDurationStats();
      i = 0;
      while i < ArraySize(durationMods) {
        effectToCast = durationMods[i].StatusEffect();
        if IsDefined(effectToCast) {
          if !ArrayContains(ignoredDurationStats, effectToCast) {
            lastMatchingEffect = effectToCast;
          };
        };
        i += 1;
      };
      effectToCast = lastMatchingEffect;
      duration = effectToCast.Duration();
      duration.StatModifiers(statModifiers);
      durationValue = RPGManager.CalculateStatModifiers(statModifiers, this.GetGame(), rootObject, targetID, Cast(instigatorID));
    };
    return durationValue;
  }

  private final func TranslateChoicesIntoQuickSlotCommands(puppetActions: array<ref<PuppetAction>>, out commands: array<ref<QuickhackData>>) -> Void {
    let actionCompletionEffects: array<wref<ObjectActionEffect_Record>>;
    let actionMatchDeck: Bool;
    let actionRecord: wref<ObjectAction_Record>;
    let actionStartEffects: array<wref<ObjectActionEffect_Record>>;
    let i: Int32;
    let i1: Int32;
    let i2: Int32;
    let interactionChoice: InteractionChoice;
    let newCommand: ref<QuickhackData>;
    let prereqsToCheck: array<wref<IPrereq_Record>>;
    let statModifiers: array<wref<StatModifier_Record>>;
    let targetActivePrereqs: array<wref<ObjectActionPrereq_Record>>;
    let playerRef: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    let isOngoingUpload: Bool = GameInstance.GetStatPoolsSystem(this.GetGame()).IsStatPoolAdded(Cast(this.GetEntityID()), gamedataStatPoolType.QuickHackUpload);
    let iceLVL: Float = this.GetICELevel();
    let actionOwnerName: CName = StringToName(this.GetTweakDBFullDisplayName(true));
    let isBreached: Bool = this.IsBreached();
    let playerQHacksList: array<PlayerQuickhackData> = RPGManager.GetPlayerQuickHackListWithQuality(playerRef);
    if ArraySize(playerQHacksList) == 0 {
      newCommand = new QuickhackData();
      newCommand.m_title = "LocKey#42171";
      newCommand.m_isLocked = true;
      newCommand.m_actionOwnerName = actionOwnerName;
      newCommand.m_actionState = EActionInactivityReson.Invalid;
      newCommand.m_description = "LocKey#42172";
      ArrayPush(commands, newCommand);
    } else {
      i = 0;
      while i < ArraySize(playerQHacksList) {
        newCommand = new QuickhackData();
        ArrayClear(actionStartEffects);
        actionRecord = playerQHacksList[i].actionRecord;
        if NotEquals(actionRecord.ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) {
        } else {
          newCommand.m_actionOwnerName = actionOwnerName;
          newCommand.m_title = LocKeyToString(actionRecord.ObjectActionUI().Caption());
          newCommand.m_description = LocKeyToString(actionRecord.ObjectActionUI().Description());
          newCommand.m_icon = actionRecord.ObjectActionUI().CaptionIcon().TexturePartID().GetID();
          newCommand.m_iconCategory = actionRecord.GameplayCategory().IconName();
          newCommand.m_type = actionRecord.ObjectActionType().Type();
          newCommand.m_actionOwner = this.GetEntityID();
          newCommand.m_isInstant = false;
          newCommand.m_ICELevel = iceLVL;
          newCommand.m_ICELevelVisible = true;
          newCommand.m_actionState = EActionInactivityReson.Locked;
          newCommand.m_quality = playerQHacksList[i].quality;
          newCommand.m_costRaw = BaseScriptableAction.GetBaseCostStatic(playerRef, actionRecord);
          newCommand.m_networkBreached = isBreached;
          newCommand.m_category = actionRecord.HackCategory();
          ArrayClear(actionCompletionEffects);
          actionRecord.CompletionEffects(actionCompletionEffects);
          newCommand.m_actionCompletionEffects = actionCompletionEffects;
          actionRecord.StartEffects(actionStartEffects);
          i1 = 0;
          while i1 < ArraySize(actionStartEffects) {
            if Equals(actionStartEffects[i1].StatusEffect().StatusEffectType().Type(), gamedataStatusEffectType.PlayerCooldown) {
              actionStartEffects[i1].StatusEffect().Duration().StatModifiers(statModifiers);
              newCommand.m_cooldown = RPGManager.CalculateStatModifiers(statModifiers, this.GetGame(), playerRef, Cast(playerRef.GetEntityID()), Cast(playerRef.GetEntityID()));
              newCommand.m_cooldownTweak = actionStartEffects[i1].StatusEffect().GetID();
              ArrayClear(statModifiers);
            };
            if newCommand.m_cooldown != 0.00 {
            } else {
              i1 += 1;
            };
          };
          ArrayClear(statModifiers);
          newCommand.m_duration = this.GetQuickHackDuration(playerQHacksList[i].actionRecord, EntityGameInterface.GetEntity(this.GetEntity()) as GameObject, Cast(this.GetEntityID()), playerRef.GetEntityID());
          actionMatchDeck = false;
          i1 = 0;
          while i1 < ArraySize(puppetActions) {
            if Equals(actionRecord.ActionName(), puppetActions[i1].GetObjectActionRecord().ActionName()) {
              actionMatchDeck = true;
              if actionRecord.Priority() >= puppetActions[i1].GetObjectActionRecord().Priority() {
                puppetActions[i1].SetObjectActionID(actionRecord.GetID());
              };
              if !puppetActions[i1].IsPossible(this) || !puppetActions[i1].IsVisible(playerRef) {
                puppetActions[i1].SetInactiveWithReason(false, "LocKey#7019");
              } else {
                newCommand.m_uploadTime = puppetActions[i1].GetActivationTime();
                newCommand.m_costRaw = puppetActions[i1].GetBaseCost();
                newCommand.m_cost = puppetActions[i1].GetCost();
                interactionChoice = puppetActions[i1].GetInteractionChoice();
                i2 = 0;
                while i2 < ArraySize(interactionChoice.captionParts.parts) {
                  if IsDefined(interactionChoice.captionParts.parts[i2] as InteractionChoiceCaptionStringPart) {
                    newCommand.m_title = GetLocalizedText(interactionChoice.captionParts.parts[i2] as InteractionChoiceCaptionStringPart.content);
                  };
                  i2 += 1;
                };
                if puppetActions[i1].IsInactive() {
                } else {
                  if !puppetActions[i1].CanPayCost() {
                    newCommand.m_actionState = EActionInactivityReson.OutOfMemory;
                    puppetActions[i1].SetInactiveWithReason(false, "LocKey#27398");
                  };
                  if actionRecord.GetTargetActivePrereqsCount() > 0 {
                    ArrayClear(targetActivePrereqs);
                    actionRecord.TargetActivePrereqs(targetActivePrereqs);
                    i2 = 0;
                    while i2 < ArraySize(targetActivePrereqs) {
                      ArrayClear(prereqsToCheck);
                      targetActivePrereqs[i2].FailureConditionPrereq(prereqsToCheck);
                      if !RPGManager.CheckPrereqs(prereqsToCheck, this) {
                        puppetActions[i1].SetInactiveWithReason(false, targetActivePrereqs[i2].FailureExplanation());
                      } else {
                        i2 += 1;
                      };
                    };
                  };
                  if isOngoingUpload {
                    puppetActions[i1].SetInactiveWithReason(false, "LocKey#7020");
                  };
                  goto 4338;
                };
                i1 += 1;
              };
            } else {
            };
            i1 += 1;
          };
          if !actionMatchDeck {
            newCommand.m_isLocked = true;
            newCommand.m_inactiveReason = "LocKey#10943";
          } else {
            if puppetActions[i1].IsInactive() {
              newCommand.m_isLocked = true;
              newCommand.m_inactiveReason = puppetActions[i1].GetInactiveReason();
            } else {
              newCommand.m_actionState = EActionInactivityReson.Ready;
              newCommand.m_action = puppetActions[i1];
            };
          };
          newCommand.m_actionMatchesTarget = actionMatchDeck;
          ArrayPush(commands, newCommand);
        };
        i += 1;
      };
    };
    i = 0;
    while i < ArraySize(commands) {
      if commands[i].m_isLocked && IsDefined(commands[i].m_action) {
        (commands[i].m_action as PuppetAction).SetInactiveWithReason(false, commands[i].m_inactiveReason);
      };
      i += 1;
    };
    QuickhackModule.SortCommandPriority(commands, this.GetGame());
  }

  private final const func GetIgnoredDurationStats() -> array<wref<StatusEffect_Record>> {
    let result: array<wref<StatusEffect_Record>>;
    ArrayPush(result, TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.WasQuickHacked"));
    ArrayPush(result, TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.QuickHackUploaded"));
    return result;
  }

  private final const func GetICELevel() -> Float {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let playerLevel: Float = statsSystem.GetStatValue(Cast(GetPlayer(this.GetGame()).GetEntityID()), gamedataStatType.Level);
    let targetLevel: Float = statsSystem.GetStatValue(Cast(this.GetEntityID()), gamedataStatType.Level);
    let resistance: Float = statsSystem.GetStatValue(Cast(this.GetEntityID()), gamedataStatType.HackingResistance);
    return resistance + 0.50 * (targetLevel - playerLevel);
  }

  protected cb func OnQuickSlotCommandUsed(evt: ref<QuickSlotCommandUsed>) -> Bool {
    this.ExecuteAction(evt.action as PuppetAction);
  }

  protected cb func OnQuickHackPanelStateChanged(evt: ref<QuickHackPanelStateEvent>) -> Bool {
    this.DetermineInteractionState();
  }

  public const func HasActiveQuickHackUpload() -> Bool {
    return GameInstance.GetStatPoolsSystem(this.GetGame()).IsStatPoolAdded(Cast(this.GetEntityID()), gamedataStatPoolType.QuickHackUpload);
  }

  public const func IsInvestigating() -> Bool {
    return IsDefined(this.GetStimReactionComponent().GetActiveReactionData()) && Equals(this.GetStimReactionComponent().GetActiveReactionData().reactionBehaviorName, gamedataOutput.DeviceInvestigate);
  }

  public const func IsInvestigatingObject(object: ref<GameObject>) -> Bool {
    return this.GetStimReactionComponent().GetActiveReactionData().stimTarget == object;
  }

  protected final func DetermineInteractionState() -> Void {
    let context: GetActionsContext;
    let requestType: gamedeviceRequestType;
    if (this.GetPS() as ScriptedPuppetPS).HasActiveContext(gamedeviceRequestType.Direct) {
      requestType = gamedeviceRequestType.Direct;
    } else {
      if (this.GetPS() as ScriptedPuppetPS).HasActiveContext(gamedeviceRequestType.Remote) {
        requestType = gamedeviceRequestType.Remote;
      };
    };
    if Equals(requestType, gamedeviceRequestType.Direct) || Equals(requestType, gamedeviceRequestType.Remote) {
      context.requestorID = this.GetEntityID();
      context.requestType = requestType;
      context.processInitiatorObject = GetPlayer(this.GetGame());
      (this.GetPS() as ScriptedPuppetPS).DetermineInteractionState(this.m_interactionComponent, context, this.m_objectActionsCallbackCtrl);
    };
  }

  public final const func IsPlayerAround() -> Bool {
    return true;
  }

  public const func ShouldEnableRemoteLayer() -> Bool {
    let context: GetActionsContext = (this.GetPS() as ScriptedPuppetPS).GenerateContext(gamedeviceRequestType.Remote, Device.GetInteractionClearance(), Device.GetPlayerMainObjectStatic(this.GetGame()), this.GetEntityID());
    return (this.GetPS() as ScriptedPuppetPS).IsQuickHacksExposed() || (this.GetPS() as ScriptedPuppetPS).CheckFlatheadTakedownAvailability(context);
  }

  public const func GetObjectToForwardHighlight() -> array<wref<GameObject>> {
    let weapons: array<wref<GameObject>>;
    let weapon: wref<WeaponObject> = ScriptedPuppet.GetWeaponRight(EntityGameInterface.GetEntity(this.GetEntity()) as GameObject);
    if IsDefined(weapon) {
      ArrayPush(weapons, weapon);
    };
    weapon = null;
    weapon = ScriptedPuppet.GetWeaponLeft(EntityGameInterface.GetEntity(this.GetEntity()) as GameObject);
    if IsDefined(weapon) {
      ArrayPush(weapons, weapon);
    };
    return weapons;
  }

  public func SetSenseObjectType(type: gamedataSenseObjectType) -> Void {
    let objectTypeEvent: ref<VisibleObjectTypeEvent>;
    if IsDefined(this.GetSensesComponent()) {
      this.GetSensesComponent().SetVisibleObjectType(type);
      this.GetSensesComponent().SetSensorObjectType(type);
    };
    if IsDefined(this.GetVisibleObjectComponent()) {
      objectTypeEvent = new VisibleObjectTypeEvent();
      objectTypeEvent.type = type;
      this.QueueEvent(objectTypeEvent);
    };
    if IsDefined(this.GetSensorObjectComponent()) {
      this.GetSensorObjectComponent().SetSensorObjectType(type);
    };
  }

  public func HasPrimaryOrSecondaryEquipment() -> Bool {
    let eq: wref<NPCEquipmentGroup_Record>;
    let characterRecord: wref<Character_Record> = TweakDBInterface.GetCharacterRecord(this.GetRecordID());
    if IsDefined(characterRecord) {
      eq = characterRecord.PrimaryEquipment();
      if eq.GetEquipmentItemsCount() > 0 {
        return true;
      };
      eq = characterRecord.SecondaryEquipment();
      if eq.GetEquipmentItemsCount() > 0 {
        return true;
      };
    };
    return false;
  }

  public final func SetMainTrackedObject(target: ref<GameObject>) -> Void {
    let sensorObjectComponent: ref<SensorObjectComponent>;
    let senseComponent: ref<SenseComponent> = this.GetSensesComponent();
    if IsDefined(senseComponent) {
      senseComponent.SetMainTrackedObject(target);
    };
    sensorObjectComponent = this.GetSensorObjectComponent();
    if IsDefined(sensorObjectComponent) {
      sensorObjectComponent.SetMainTrackedObject(target);
    };
  }

  public final func GetDistToTraceEndFromPosToMainTrackedObject(traceSource: AdditionalTraceType) -> Float {
    let sensorObjectComponent: ref<SensorObjectComponent>;
    let senseComponent: ref<SenseComponent> = this.GetSensesComponent();
    if IsDefined(senseComponent) {
      return senseComponent.GetDistToTraceEndFromPosToMainTrackedObject(traceSource);
    };
    sensorObjectComponent = this.GetSensorObjectComponent();
    if IsDefined(sensorObjectComponent) {
      return sensorObjectComponent.GetDistToTraceEndFromPosToMainTrackedObject(traceSource);
    };
    return 999999.00;
  }

  protected cb func OnStartEndPhoneCallEvent(evt: ref<StartEndPhoneCallEvent>) -> Bool {
    if evt.startCall {
      this.ShowPhoneCallDuration(evt.callDuration, evt.statType, evt.statPoolType, TDBID.Create(evt.statPoolName));
    };
  }

  protected cb func OnPauseResumePhoneCallEvent(evt: ref<PauseResumePhoneCallEvent>) -> Bool {
    if evt.pauseCall {
      this.PausePhoneCallDuration(evt.statPoolType);
    } else {
      this.ResumePhoneCallDuration(evt.statPoolType, evt.callDuration);
    };
  }

  private final func ShowPhoneCallDuration(duration: Float, statType: gamedataStatType, statPoolType: gamedataStatPoolType, statPoolID: TweakDBID) -> Void {
    let actionDurationListener: ref<PhoneCallUploadDurationListener>;
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let statMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(statType, gameStatModifierType.Additive, 1.00);
    GameInstance.GetStatsSystem(this.GetGame()).AddModifier(Cast(this.GetEntityID()), statMod);
    actionDurationListener = new PhoneCallUploadDurationListener();
    actionDurationListener.m_duration = duration;
    actionDurationListener.m_requesterPuppet = this;
    actionDurationListener.m_requesterID = this.GetEntityID();
    actionDurationListener.m_gameInstance = this.GetGame();
    actionDurationListener.m_statPoolType = statPoolType;
    statPoolSys.RequestRegisteringListener(Cast(this.GetEntityID()), statPoolType, actionDurationListener);
    statPoolSys.RequestAddingStatPool(Cast(this.GetEntityID()), statPoolID);
  }

  private final func PausePhoneCallDuration(statPoolType: gamedataStatPoolType) -> Void {
    let statPoolMod: StatPoolModifier;
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    statPoolSys.RequestSettingModifier(Cast(this.GetEntityID()), statPoolType, gameStatPoolModificationTypes.Regeneration, statPoolMod);
  }

  private final func ResumePhoneCallDuration(statPoolType: gamedataStatPoolType, initialDuration: Float) -> Void {
    let statPoolMod: StatPoolModifier;
    statPoolMod.enabled = true;
    statPoolMod.valuePerSec = 100.00 / initialDuration;
    statPoolMod.rangeEnd = 100.00;
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    statPoolSys.RequestSettingModifier(Cast(this.GetEntityID()), statPoolType, gameStatPoolModificationTypes.Regeneration, statPoolMod);
  }

  private final func HidePhoneCallDuration(statPoolType: gamedataStatPoolType) -> Void {
    let statPoolSys: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    statPoolSys.RequestRemovingStatPool(Cast(this.GetEntityID()), statPoolType);
  }

  protected cb func OnUploadProgressStateChanged(evt: ref<UploadProgramProgressEvent>) -> Bool;

  public const func GetPhoneCallIndicatorSlotName() -> CName {
    return n"phoneCall";
  }

  private final func IsPerformingCallReinforcements() -> Bool {
    let statPoolValue: Float;
    let statPoolSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    if statSystem.GetStatValue(Cast(this.GetEntityID()), gamedataStatType.CanCallReinforcements) == 0.00 {
      return false;
    };
    statPoolValue = statPoolSystem.GetStatPoolValue(Cast(this.GetEntityID()), gamedataStatPoolType.CallReinforcementProgress);
    if statPoolValue == 100.00 {
      return false;
    };
    return true;
  }

  protected cb func OnMinigameFailEvent(evt: ref<MinigameFailEvent>) -> Bool {
    StimBroadcasterComponent.SendStimDirectly(GetPlayer(this.GetGame()), gamedataStimType.ProjectileDistraction, this);
    NPCStatesComponent.AlertPuppet(this);
  }

  private final func CreateObjectActionsCallbackController(instigator: wref<Entity>) -> Void {
    this.m_objectActionsCallbackCtrl = gameObjectActionsCallbackController.Create(EntityGameInterface.GetEntity(this.GetEntity()), instigator, this.GetGame());
  }

  private final func DestroyObjectActionsCallbackController() -> Void {
    this.m_objectActionsCallbackCtrl = null;
  }

  protected cb func OnObjectActionRefreshEvent(evt: ref<gameObjectActionRefreshEvent>) -> Bool {
    if IsDefined(this.m_objectActionsCallbackCtrl) {
      this.m_objectActionsCallbackCtrl.UnlockNotifications();
      this.DetermineInteractionState();
    };
  }
}

public static exec func LogGender(gameInstance: GameInstance) -> Void {
  let playerPuppet: ref<ScriptedPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as ScriptedPuppet;
  Log("*** Player Gender: " + NameToString(playerPuppet.GetResolvedGenderName()));
}
