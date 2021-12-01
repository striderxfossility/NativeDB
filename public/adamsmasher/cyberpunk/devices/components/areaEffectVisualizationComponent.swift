
public class AreaEffectVisualizationComponent extends ScriptableComponent {

  protected let m_fxResourceMapper: ref<FxResourceMapperComponent>;

  private let m_forceHighlightTargetBuckets: array<ref<GameEffectTargetVisualizationData>>;

  private let m_availableQuickHacks: array<CName>;

  private let m_availablespiderbotActions: array<CName>;

  private let m_activeAction: ref<BaseScriptableAction>;

  @default(AreaEffectVisualizationComponent, -1)
  private let m_activeEffectIndex: Int32;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"FxResourceMapper", n"FxResourceMapperComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_fxResourceMapper = EntityResolveComponentsInterface.GetComponent(ri, n"FxResourceMapper") as FxResourceMapperComponent;
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    if this.GetOwner().GetHudManager().IsQuickHackPanelOpened() {
      return false;
    };
    if (Equals(evt.highlightInstructions.GetState(), InstanceState.ON) || Equals(evt.highlightInstructions.GetState(), InstanceState.HIDDEN)) && evt.highlightInstructions.isLookedAt {
      this.ResolveAreaEffectVisualisations(true);
    } else {
      if evt.highlightInstructions.WasProcessed() {
        this.ResolveAreaEffectVisualisations(false);
      };
    };
  }

  protected final func GetFxMapper() -> ref<FxResourceMapperComponent> {
    return (this.GetOwner() as Device).GetFxResourceMapper();
  }

  public final func ResolveAreaEffectVisualisations(activated: Bool) -> Void {
    if this.GetFxMapper().GetAreaEffectDataSize() <= 0 && this.GetFxMapper().GetAreaEffectInFocusSize() <= 0 {
      return;
    };
    this.ResolveAreaEffectsVisibility(activated);
  }

  protected cb func OnAreaEffectVisualisationRequest(evt: ref<AreaEffectVisualisationRequest>) -> Bool {
    let areaEffectIndex: Int32 = this.GetFxMapper().GetAreaEffectDataIndexByName(evt.areaEffectID);
    if areaEffectIndex != -1 {
      this.ToggleAreaEffectVisibility(areaEffectIndex, evt.show);
    };
  }

  protected func ResolveAreaEffectsVisibility(show: Bool) -> Void {
    this.ResolveAreaSpiderbotVisibility(show);
    this.ResolveAreaEffectsInFocusModeVisibility(show);
  }

  protected func ResolveAreaEffectsInFocusModeVisibility(show: Bool) -> Void {
    let effectIndex: Int32;
    let i: Int32 = 0;
    while i < this.GetFxMapper().GetAreaEffectInFocusSize() {
      if !this.GetFxMapper().GetAreaEffectInFocusModeByIndex(i).onSelf {
      } else {
        effectIndex = this.GetFxMapper().GetAreaEffectDataIndexByName(this.GetFxMapper().GetAreaEffectInFocusModeByIndex(i).areaEffectID);
        if effectIndex >= 0 {
          this.ToggleAreaEffectVisibility(effectIndex, show);
        };
      };
      i += 1;
    };
  }

  protected func ResolveAreaQuickHacksVisibility(show: Bool) -> Void {
    let availableQuickHacks: array<CName>;
    let i: Int32;
    let quickHackIndex: Int32;
    if show {
      availableQuickHacks = (this.GetOwner() as Device).GetDevicePS().GetAvailableQuickHacks();
      if ArraySize(availableQuickHacks) > 0 {
        this.m_availableQuickHacks = availableQuickHacks;
      };
    };
    i = 0;
    while i < ArraySize(this.m_availableQuickHacks) {
      quickHackIndex = this.GetFxMapper().GetAreaEffectDataIndexByName(this.m_availableQuickHacks[i]);
      if quickHackIndex >= 0 {
        this.ToggleAreaEffectVisibility(quickHackIndex, show);
      };
      i += 1;
    };
  }

  protected func ResolveAreaQuickHacksVisibility(show: Bool, action: ref<BaseScriptableAction>) -> Void {
    let quickHackIndex: Int32;
    if action == null {
      return;
    };
    quickHackIndex = this.GetFxMapper().GetAreaEffectDataIndexByAction(action);
    if show && quickHackIndex == this.m_activeEffectIndex || !show && this.m_activeEffectIndex == -1 {
      return;
    };
    if quickHackIndex >= 0 {
      if show && this.m_activeEffectIndex >= 0 {
        this.ToggleAreaEffectVisibility(this.m_activeEffectIndex, false, action);
        this.m_activeAction = null;
        this.m_activeEffectIndex = -1;
        return;
      };
      this.ToggleAreaEffectVisibility(quickHackIndex, show);
    } else {
      if this.m_activeEffectIndex >= 0 {
        this.ToggleAreaEffectVisibility(this.m_activeEffectIndex, false);
        show = false;
      };
    };
    if show {
      this.m_activeAction = action;
      this.m_activeEffectIndex = quickHackIndex;
    } else {
      this.m_activeAction = null;
      this.m_activeEffectIndex = -1;
    };
  }

  protected func ResolveAreaSpiderbotVisibility(show: Bool) -> Void {
    let actionIndex: Int32;
    let availablespiderbotActions: array<CName>;
    let i: Int32;
    if show {
      availablespiderbotActions = (this.GetOwner() as Device).GetDevicePS().GetAvailableSpiderbotActions();
      if ArraySize(availablespiderbotActions) > 0 {
        this.m_availablespiderbotActions = availablespiderbotActions;
      };
    };
    i = 0;
    while i < ArraySize(this.m_availablespiderbotActions) {
      actionIndex = this.GetFxMapper().GetAreaEffectDataIndexByName(this.m_availablespiderbotActions[i]);
      if actionIndex >= 0 {
        this.ToggleAreaEffectVisibility(actionIndex, show);
      };
      i += 1;
    };
  }

  protected final func ToggleAreaEffectVisibility(effectDataIDX: Int32, show: Bool, opt responseData: ref<IScriptable>) -> Void {
    if show {
      this.StartDrawingAreaEffectRange(this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX));
      if this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).highlightTargets {
        this.StartHighlightingTargets(effectDataIDX, responseData);
      };
    } else {
      this.StopDrawingAreaEffectRange(this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX));
      this.StopHighlightingTargets(effectDataIDX, responseData);
    };
  }

  protected final func StartDrawingAreaEffectRange(effectData: ref<AreaEffectData>) -> Void {
    let effectBlackboard: ref<worldEffectBlackboard>;
    if !effectData.useIndicatorEffect || !IsNameValid(effectData.indicatorEffectName) {
      return;
    };
    effectBlackboard = new worldEffectBlackboard();
    effectBlackboard.SetValue(n"change_size", effectData.indicatorEffectSize);
    GameObjectEffectHelper.StartEffectEvent(this.GetOwner(), effectData.indicatorEffectName, false, effectBlackboard);
  }

  protected final func StopDrawingAreaEffectRange(effectData: ref<AreaEffectData>) -> Void {
    if !effectData.useIndicatorEffect || !IsNameValid(effectData.indicatorEffectName) {
      return;
    };
    GameObjectEffectHelper.StopEffectEvent(this.GetOwner(), effectData.indicatorEffectName);
  }

  protected final func StartHighlightingTargets(effectDataIDX: Int32, opt responseData: ref<IScriptable>) -> Void {
    let bbData: ref<PuppetForceVisionAppearanceData>;
    let device: ref<Device>;
    let effect: ref<EffectInstance>;
    let position: Vector4;
    let stimID: TweakDBID;
    let stimType: gamedataStimType;
    if this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).effectInstance == null {
      device = this.GetOwner() as Device;
      position = this.GetOwner().GetAcousticQuerryStartPoint();
      if IsNameValid(this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).gameEffectOverrideName) {
        effect = GameInstance.GetGameEffectSystem(this.GetOwner().GetGame()).CreateEffectStatic(n"forceVisionAppearanceOnNPC", this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).gameEffectOverrideName, this.GetOwner());
      } else {
        effect = GameInstance.GetGameEffectSystem(this.GetOwner().GetGame()).CreateEffectStatic(n"forceVisionAppearanceOnNPC", n"inRange", this.GetOwner());
      };
      bbData = new PuppetForceVisionAppearanceData();
      bbData.m_highlightType = this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).highlightType;
      bbData.m_outlineType = this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).outlineType;
      bbData.m_effectName = NameToString(this.GetFxMapper().GetAreaEffectDataNameByIndex(effectDataIDX));
      bbData.m_priority = this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).highlightPriority;
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.maxPathLength, this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).stimRange * 1.50);
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).stimRange);
      if IsDefined(device) {
        bbData.m_investigationSlots = device.GetTotalCountOfInvestigationSlots();
        stimType = Device.MapStimType(this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).stimType);
        EffectData.SetInt(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.stimType, EnumInt(stimType));
        stimID = TDBID.Create("stims." + EnumValueToString("gamedataStimType", Cast(EnumInt(stimType))) + "Stimuli");
        if TDBID.IsValid(stimID) {
          bbData.m_stimRecord = TweakDBInterface.GetStimRecord(stimID);
        };
      };
      EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forceVisionAppearanceData, ToVariant(bbData));
      effect.Run();
      this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).SetEffectInstance(effect);
    };
  }

  protected final func StopHighlightingTargets(effectDataIDX: Int32, opt responseData: ref<IScriptable>) -> Void {
    let evt: ref<ForceVisionApperanceEvent>;
    let highlight: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlight.sourceID = this.GetOwner().GetEntityID();
    highlight.sourceName = this.GetFxMapper().GetAreaEffectDataNameByIndex(effectDataIDX);
    highlight.highlightType = this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).highlightType;
    highlight.outlineType = this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).outlineType;
    highlight.priority = this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).highlightPriority;
    highlight.isRevealed = true;
    let effectInstance: ref<EffectInstance> = this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).effectInstance;
    if IsDefined(effectInstance) {
      effectInstance.Terminate();
    };
    this.GetFxMapper().GetAreaEffectDataByIndex(effectDataIDX).EffectInstanceClear();
    this.CancelForcedVisionAppearance(highlight);
    evt = new ForceVisionApperanceEvent();
    evt.apply = false;
    evt.forcedHighlight = highlight;
    evt.responseData = responseData;
    this.SendEventToBucket(highlight.sourceName, evt);
    this.RemoveBucket(highlight.sourceName);
  }

  protected final func ForceVisionAppearance(data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = true;
    GameInstance.GetPersistencySystem(this.GetOwner().GetGame()).QueueEntityEvent(this.GetOwner().GetEntityID(), evt);
  }

  protected final func CancelForcedVisionAppearance(data: ref<FocusForcedHighlightData>) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    evt.forcedHighlight = data;
    evt.apply = false;
    if this.GetOwner().HasHighlight(data.highlightType, data.outlineType, this.GetOwner().GetEntityID(), data.sourceName) {
      GameInstance.GetPersistencySystem(this.GetOwner().GetGame()).QueueEntityEvent(this.GetOwner().GetEntityID(), evt);
    };
  }

  protected cb func OnAddForceHighlightTarget(evt: ref<AddForceHighlightTargetEvent>) -> Bool {
    this.AddTargetToBucket(evt.effecName, evt.targetID);
  }

  protected cb func OnQHackWheelItemChanged(evt: ref<QHackWheelItemChangedEvent>) -> Bool {
    if !evt.currentEmpty {
      this.ResolveAreaQuickHacksVisibility(true, evt.commandData.m_action);
    } else {
      this.ResolveAreaQuickHacksVisibility(false, this.m_activeAction);
    };
  }

  protected cb func OnResponse(evt: ref<ResponseEvent>) -> Bool {
    let action: ref<BaseScriptableAction> = evt.responseData as BaseScriptableAction;
    if IsDefined(action) {
      this.ResolveAreaQuickHacksVisibility(true, action);
    };
  }

  protected final func AddTargetToBucket(bucketName: CName, entityID: EntityID) -> Void {
    let newBucket: ref<GameEffectTargetVisualizationData>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_forceHighlightTargetBuckets) {
      if Equals(this.m_forceHighlightTargetBuckets[i].GetBucketName(), bucketName) {
        this.m_forceHighlightTargetBuckets[i].AddTargetToBucket(entityID);
        return;
      };
      i += 1;
    };
    newBucket = new GameEffectTargetVisualizationData();
    newBucket.SetBucketName(bucketName);
    newBucket.AddTargetToBucket(entityID);
    ArrayPush(this.m_forceHighlightTargetBuckets, newBucket);
    1 + 1;
  }

  protected final func SendEventToBucket(bucketName: CName, evt: ref<Event>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forceHighlightTargetBuckets) {
      if Equals(this.m_forceHighlightTargetBuckets[i].GetBucketName(), bucketName) {
        this.m_forceHighlightTargetBuckets[i].SendEventToAll(this.GetOwner().GetGame(), evt);
        return;
      };
      i += 1;
    };
  }

  protected final func RemoveBucket(bucketName: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forceHighlightTargetBuckets) {
      if Equals(this.m_forceHighlightTargetBuckets[i].GetBucketName(), bucketName) {
        ArrayErase(this.m_forceHighlightTargetBuckets, i);
        return;
      };
      i += 1;
    };
  }
}

public class GameEffectTargetVisualizationData extends IScriptable {

  private let bucketName: CName;

  private let m_forceHighlightTargets: array<EntityID>;

  public final const func GetBucketName() -> CName {
    return this.bucketName;
  }

  public final func SetBucketName(_bucketName: CName) -> Void {
    this.bucketName = _bucketName;
  }

  public final func AddTargetToBucket(entityID: EntityID) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forceHighlightTargets) {
      if this.m_forceHighlightTargets[i] == entityID {
        return;
      };
      i += 1;
    };
    ArrayPush(this.m_forceHighlightTargets, entityID);
  }

  public final func ClearBucket() -> Void {
    ArrayClear(this.m_forceHighlightTargets);
  }

  public final func SendEventToAll(instance: GameInstance, evt: ref<Event>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_forceHighlightTargets) {
      GameInstance.GetPersistencySystem(instance).QueueEntityEvent(this.m_forceHighlightTargets[i], evt);
      i += 1;
    };
  }
}
