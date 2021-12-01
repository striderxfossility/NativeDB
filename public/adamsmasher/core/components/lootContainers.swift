
public class SetContainerStateEvent extends Event {

  @default(SetContainerStateEvent, true)
  public edit let isDisabled: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Disable or enable loot container";
  }
}

public class ToggleContainerLockEvent extends Event {

  @default(ToggleContainerLockEvent, true)
  public edit let isLocked: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle container lock";
  }
}

public class gameLootContainerBasePS extends GameObjectPS {

  @attrib(category, "Quest")
  @default(ShardCaseContainerPS, true)
  protected persistent let m_markAsQuest: Bool;

  @attrib(category, "Quest")
  protected persistent let m_isDisabled: Bool;

  @attrib(category, "Quest")
  protected persistent let m_isLocked: Bool;

  public final func SetIsMarkedAsQuest(isQuest: Bool) -> Void {
    this.m_markAsQuest = isQuest;
  }

  public final const func IsMarkedAsQuest() -> Bool {
    return this.m_markAsQuest;
  }

  public final const func IsDisabled() -> Bool {
    return this.m_isDisabled;
  }

  public final const func IsLocked() -> Bool {
    return this.m_isLocked;
  }

  private final func OnSetContainerStateEventEvent(evt: ref<SetContainerStateEvent>) -> EntityNotificationType {
    let shouldSendToEntity: Bool = NotEquals(this.m_isDisabled, evt.isDisabled);
    this.m_isDisabled = evt.isDisabled;
    if shouldSendToEntity {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func OnToggleContainerLockEvent(evt: ref<ToggleContainerLockEvent>) -> EntityNotificationType {
    let shouldSendToEntity: Bool = NotEquals(this.m_isLocked, evt.isLocked);
    this.m_isLocked = evt.isLocked;
    if shouldSendToEntity {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }
}

public native class gameLootContainerBase extends GameObject {

  private native let wasLootInitalized: Bool;

  @default(gameLootContainerBase, gamedataQuality.Common)
  protected let m_lootQuality: gamedataQuality;

  private let m_hasQuestItems: Bool;

  protected let m_isInIconForcedVisibilityRange: Bool;

  private let m_isIconic: Bool;

  protected let m_activeQualityRangeInteraction: CName;

  public final native const func IsLogicReady() -> Bool;

  protected func EvaluateLootQualityByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"EvaluateLootQualityTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func EvaluateLootQualityTask(data: ref<ScriptTaskData>) -> Void {
    this.EvaluateLootQuality();
  }

  protected cb func OnGameAttached() -> Bool {
    let scanningBlockedEvt: ref<SetScanningBlockedEvent>;
    super.OnGameAttached();
    if IsDefined(this.m_scanningComponent) {
      scanningBlockedEvt = new SetScanningBlockedEvent();
      scanningBlockedEvt.isBlocked = false;
      this.QueueEvent(scanningBlockedEvt);
    };
    if this.IsEmpty() || this.IsDisabled() {
      this.ToggleLootHighlight(false);
    } else {
      if this.IsQuest() {
        this.ToggleLootHighlight(true);
      };
    };
  }

  protected const func GetPS() -> ref<GameObjectPS> {
    return this.GetBasePS();
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    let outline: EFocusOutlineType;
    if this.IsEmpty() || this.IsDisabled() || this.IsAnyClueEnabled() {
      return null;
    };
    if this.m_scanningComponent.IsBraindanceBlocked() || this.m_scanningComponent.IsPhotoModeBlocked() {
      return null;
    };
    outline = this.GetCurrentOutline();
    highlight = new FocusForcedHighlightData();
    highlight.sourceID = this.GetEntityID();
    highlight.sourceName = this.GetClassName();
    highlight.priority = EPriority.Low;
    highlight.outlineType = outline;
    if Equals(outline, EFocusOutlineType.QUEST) {
      highlight.highlightType = EFocusForcedHighlightType.QUEST;
    } else {
      if Equals(outline, EFocusOutlineType.ITEM) {
        highlight.highlightType = EFocusForcedHighlightType.ITEM;
      } else {
        highlight = null;
      };
    };
    return highlight;
  }

  public const func GetCurrentOutline() -> EFocusOutlineType {
    let outlineType: EFocusOutlineType;
    if !this.IsEmpty() && !this.IsDisabled() {
      if this.IsQuest() {
        outlineType = EFocusOutlineType.QUEST;
      } else {
        outlineType = EFocusOutlineType.ITEM;
      };
    } else {
      outlineType = EFocusOutlineType.INVALID;
    };
    return outlineType;
  }

  protected const func ShouldRegisterToHUD() -> Bool {
    if IsDefined(this.m_visionComponent) || this.m_forceRegisterInHudManager {
      return true;
    };
    return false;
  }

  public const func IsContainer() -> Bool {
    return !this.IsEmpty() && !this.IsDisabled();
  }

  public final const func HasValidLootQuality() -> Bool {
    return NotEquals(this.m_lootQuality, gamedataQuality.Invalid) && NotEquals(this.m_lootQuality, gamedataQuality.Random);
  }

  public const func IsInIconForcedVisibilityRange() -> Bool {
    return this.m_isInIconForcedVisibilityRange;
  }

  protected cb func OnInventoryEmptyEvent(evt: ref<OnInventoryEmptyEvent>) -> Bool {
    GameObjectEffectHelper.StartEffectEvent(this, n"fx_empty");
    this.m_lootQuality = gamedataQuality.Invalid;
    GameObject.UntagObject(this);
    this.RegisterToHUDManagerByTask(false);
    if this.IsQuest() {
      this.ToggleLootHighlight(false);
      this.MarkAsQuest(false);
      this.m_hasQuestItems = false;
      this.ResolveQualityRangeInteractionLayer();
    };
  }

  protected cb func OnInventoryChangedEvent(evt: ref<InventoryChangedEvent>) -> Bool {
    if this.HasValidLootQuality() {
      if this.EvaluateLootQuality() {
        this.RequestHUDRefresh();
      };
    };
  }

  protected cb func OnItemRemoveddEvent(evt: ref<ItemBeingRemovedEvent>) -> Bool {
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
      this.EvaluateLootQuality();
      if this.EvaluateLootQuality() {
        this.RequestHUDRefresh();
      };
    };
  }

  protected cb func OnInventoryFilledEvent(evt: ref<ContainerFilledEvent>) -> Bool {
    this.wasLootInitalized = true;
    this.EvaluateLootQualityByTask();
  }

  protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    RPGManager.ProcessReadAction(choiceEvent);
    GameObjectEffectHelper.StartEffectEvent(this, n"fx_checked");
    this.RequestHUDRefresh();
  }

  public const func DeterminGameplayRoleMappinVisuaState(data: SDeviceMappinData) -> EMappinVisualState {
    if this.IsEmpty() || this.IsDisabled() {
      return EMappinVisualState.Inactive;
    };
    return EMappinVisualState.Default;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Loot;
  }

  public const func IsQuest() -> Bool {
    let ps: ref<gameLootContainerBasePS> = this.GetPS() as gameLootContainerBasePS;
    if IsDefined(ps) {
      return !ps.IsDisabled() && (ps.IsMarkedAsQuest() || this.m_hasQuestItems);
    };
    return this.m_hasQuestItems;
  }

  protected func MarkAsQuest(isQuest: Bool) -> Void {
    let ps: ref<gameLootContainerBasePS> = this.GetPS() as gameLootContainerBasePS;
    if IsDefined(ps) {
      ps.SetIsMarkedAsQuest(isQuest);
    };
  }

  public final const func IsDisabled() -> Bool {
    let ps: ref<gameLootContainerBasePS> = this.GetPS() as gameLootContainerBasePS;
    return ps.IsDisabled();
  }

  public final native const func IsEmpty() -> Bool;

  public final native const func IsIllegal() -> Bool;

  public final native const func GetContentAssignment() -> TweakDBID;

  protected final func EvaluateLootQualityEvent() -> Void {
    let evt: ref<EvaluateLootQualityEvent> = new EvaluateLootQualityEvent();
    this.QueueEvent(evt);
  }

  protected cb func OnEvaluateLootQuality(evt: ref<EvaluateLootQualityEvent>) -> Bool {
    this.EvaluateLootQuality();
    this.RequestHUDRefresh();
  }

  private final func EvaluateLootQuality() -> Bool {
    let i: Int32;
    let isQuest: Bool;
    let items: array<wref<gameItemData>>;
    let iteratedQuality: gamedataQuality;
    let lastValue: Int32;
    let newValue: Int32;
    let qualityToSet: gamedataQuality;
    let wasChanged: Bool;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
    let cachedQuality: gamedataQuality = this.m_lootQuality;
    let isCurrentlyQuest: Bool = this.IsQuest();
    let isCurrentlyIconic: Bool = this.GetIsIconic();
    this.m_isIconic = false;
    if transactionSystem.GetItemList(this, items) {
      if ArraySize(items) > 0 {
        qualityToSet = gamedataQuality.Common;
      };
      i = 0;
      while i < ArraySize(items) {
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
        i += 1;
      };
      this.m_lootQuality = qualityToSet;
    };
    isQuest = this.IsQuest();
    if NotEquals(isCurrentlyQuest, isQuest) {
      this.ToggleLootHighlight(isQuest);
      if !isQuest {
        this.MarkAsQuest(false);
      };
    };
    wasChanged = NotEquals(this.m_lootQuality, cachedQuality) || NotEquals(isCurrentlyQuest, this.IsQuest()) || NotEquals(isCurrentlyIconic, this.m_isIconic);
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

  private final func ToggleLootHighlight(enable: Bool) -> Void {
    let effectInstance: ref<EffectInstance> = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(n"loot_highlight", n"container_highlight", this);
    EffectData.SetEntity(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this);
    EffectData.SetBool(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.renderMaterialOverride, false);
    EffectData.SetBool(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, enable);
    effectInstance.Run();
  }

  protected cb func OnSetContainerStateEventEvent(evt: ref<SetContainerStateEvent>) -> Bool {
    this.RequestHUDRefresh();
    this.ToggleLootHighlight(this.IsQuest());
  }

  protected func ResolveQualityRangeInteractionLayer() -> Void {
    this.m_activeQualityRangeInteraction = n"Invalid";
  }
}

public native class gameContainerObjectBase extends gameLootContainerBase {

  @attrib(customEditor, "TweakDBGroupInheritance;Keycards.Keycard")
  protected let m_lockedByKey: TweakDBID;

  protected cb func OnToggleContainerLockEvent(evt: ref<ToggleContainerLockEvent>) -> Bool {
    this.RefereshInteraction(GetPlayer(this.GetGame()), true);
  }

  public final const func IsLocked(activator: ref<GameObject>) -> Bool {
    let isLocked: Bool;
    let ts: ref<TransactionSystem>;
    if (this.GetPS() as gameLootContainerBasePS).IsLocked() {
      return true;
    };
    ts = GameInstance.GetTransactionSystem(this.GetGame());
    if !IsDefined(ts) {
      return false;
    };
    if TDBID.IsValid(this.m_lockedByKey) {
      if !ts.HasItem(activator, ItemID.FromTDBID(this.m_lockedByKey)) {
        isLocked = true;
      } else {
        isLocked = false;
      };
    };
    return isLocked;
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    let actorUpdateData: ref<HUDActorUpdateData>;
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      if evt.activator.IsPlayer() {
        this.RefereshInteraction(evt.activator);
        if this.IsQualityRangeInteractionLayer(evt.layerData.tag) {
          this.m_isInIconForcedVisibilityRange = true;
          actorUpdateData = new HUDActorUpdateData();
          actorUpdateData.updateIsInIconForcedVisibilityRange = true;
          actorUpdateData.isInIconForcedVisibilityRangeValue = true;
          this.RequestHUDRefresh(actorUpdateData);
        };
      };
    } else {
      if this.IsQualityRangeInteractionLayer(evt.layerData.tag) && evt.activator.IsPlayer() {
        this.m_isInIconForcedVisibilityRange = false;
        actorUpdateData = new HUDActorUpdateData();
        actorUpdateData.updateIsInIconForcedVisibilityRange = true;
        actorUpdateData.isInIconForcedVisibilityRangeValue = false;
        this.RequestHUDRefresh(actorUpdateData);
      };
    };
  }

  protected func ResolveQualityRangeInteractionLayer() -> Void {
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

  private final func RefereshInteraction(activator: ref<GameObject>, opt force: Bool) -> Void {
    let controlWrapper: LootVisualiserControlWrapper;
    let isLocked: Bool;
    let setChoices: ref<InteractionSetChoicesEvent>;
    let ts: ref<TransactionSystem>;
    if activator == null {
      return;
    };
    if this.IsDisabled() {
      return;
    };
    ts = GameInstance.GetTransactionSystem(this.GetGame());
    if !IsDefined(ts) {
      return;
    };
    isLocked = this.IsLocked(activator);
    if TDBID.IsValid(this.m_lockedByKey) || force || isLocked {
      LootVisualiserControlWrapper.AddOperation(controlWrapper, gameinteractionsELootVisualiserControlOperation.Locked, isLocked);
      setChoices = LootVisualiserControlWrapper.Wrap(controlWrapper);
      this.QueueEvent(setChoices);
    };
  }

  private final func IsQualityRangeInteractionLayer(layerTag: CName) -> Bool {
    return Equals(layerTag, n"QualityRange_Short") || Equals(layerTag, n"QualityRange_Medium") || Equals(layerTag, n"QualityRange_Max");
  }

  protected final func OpenContainerWithTransformAnimation() -> Void {
    let evtTransformAnimation: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    evtTransformAnimation.animationName = n"Open";
    evtTransformAnimation.looping = false;
    evtTransformAnimation.timeScale = 1.00;
    evtTransformAnimation.timesPlayed = 1u;
    this.QueueEventForEntityID(this.GetEntityID(), evtTransformAnimation);
  }

  public const func ShouldShowScanner() -> Bool {
    if GameInstance.GetSceneSystem(this.GetGame()).GetScriptInterface().IsRewindableSectionActive() {
      return false;
    };
    return this.ShouldShowScanner();
  }
}

public class LootContainerObjectAnimatedByTransform extends gameContainerObjectBase {

  protected let wasOpened: Bool;

  protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    super.OnInteraction(choiceEvent);
    if !this.wasOpened {
      this.OpenContainerWithTransformAnimation();
      this.wasOpened = true;
    };
  }
}
