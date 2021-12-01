
public native class ItemObject extends TimeDilatable {

  private let m_lootQuality: gamedataQuality;

  private let m_isIconic: Bool;

  public final native func GetItemID() -> ItemID;

  public final native const func GetItemData() -> wref<gameItemData>;

  public final native func QueueEventToChildItems(evt: ref<Event>) -> Void;

  public final native func GetAnimationParameters() -> array<CName>;

  public final native func IsClientSideOnlyGadget() -> Bool;

  public final native const func IsConnectedWithDrop() -> Bool;

  public final native const func GetConnectedItemDrop() -> wref<gameItemDropObject>;

  protected func EvaluateLootQualityByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"EvaluateLootQualityTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func EvaluateLootQualityTask(data: ref<ScriptTaskData>) -> Void {
    this.EvaluateLootQuality();
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.m_isIconic = RPGManager.IsItemIconic(this.GetItemData());
    if this.IsContainer() {
      this.ToggleLootHighlight(this.IsQuest());
      this.EvaluateLootQualityByTask();
    };
  }

  protected cb func OnItemLooted(evt: ref<ItemLootedEvent>) -> Bool {
    let evtToSend: ref<UnregisterAllMappinsEvent> = new UnregisterAllMappinsEvent();
    this.QueueEvent(evtToSend);
    if this.IsQuest() {
      this.ToggleLootHighlight(false);
    };
  }

  protected cb func OnEvaluateLootQuality(evt: ref<EvaluateLootQualityEvent>) -> Bool {
    this.EvaluateLootQuality();
  }

  private final func EvaluateLootQuality() -> Void {
    this.m_lootQuality = RPGManager.GetItemDataQuality(this.GetItemData());
    this.ToggleLootHighlight(this.IsQuest());
  }

  protected final const func HasValidLootQuality() -> Bool {
    return NotEquals(this.m_lootQuality, gamedataQuality.Invalid) && NotEquals(this.m_lootQuality, gamedataQuality.Random);
  }

  public const func IsContainer() -> Bool {
    if this.GetItemData().HasTag(n"NoLootMappin") {
      return false;
    };
    return this.IsConnectedWithDrop();
  }

  public const func GetDefaultHighlight() -> ref<FocusForcedHighlightData> {
    let highlight: ref<FocusForcedHighlightData>;
    let outline: EFocusOutlineType;
    if !this.IsConnectedWithDrop() {
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
    if this.IsConnectedWithDrop() {
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
    if this.m_forceRegisterInHudManager {
      return true;
    };
    return false;
  }

  public const func IsQuest() -> Bool {
    return this.IsQuest() || this.GetItemData().HasTag(n"Quest");
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    if this.IsContainer() {
      return EGameplayRole.Loot;
    };
    return IntEnum(1l);
  }

  public const func GetIsIconic() -> Bool {
    return this.m_isIconic;
  }

  public const func GetLootQuality() -> gamedataQuality {
    return this.m_lootQuality;
  }

  private final func ToggleLootHighlight(enable: Bool) -> Void {
    let effectInstance: ref<EffectInstance> = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(n"loot_highlight", n"item_highlight", this);
    EffectData.SetEntity(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this);
    EffectData.SetBool(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.renderMaterialOverride, false);
    EffectData.SetBool(effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, enable);
    effectInstance.Run();
  }
}
