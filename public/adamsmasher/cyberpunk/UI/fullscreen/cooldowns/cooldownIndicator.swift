
public native class inkCooldownGameController extends inkGameController {

  private edit let m_maxCooldowns: Int32;

  private edit let m_cooldownContainer: inkCompoundRef;

  private edit let m_poolHolder: inkCompoundRef;

  @default(inkCooldownGameController, ECooldownGameControllerMode.COOLDOWNS)
  private edit let m_mode: ECooldownGameControllerMode;

  private let m_effectTypes: array<gamedataStatusEffectType>;

  private let m_cooldownPool: array<wref<SingleCooldownManager>>;

  private let m_matchBuffer: array<wref<SingleCooldownManager>>;

  private let m_buffsCallback: ref<CallbackHandle>;

  private let m_debuffsCallback: ref<CallbackHandle>;

  private let m_blackboardDef: ref<UI_PlayerBioMonitorDef>;

  private let m_blackboard: wref<IBlackboard>;

  protected cb func OnInitialize() -> Bool {
    let i: Int32;
    let tempSingleCooldownManagerRef: wref<SingleCooldownManager>;
    inkWidgetRef.SetVAlign(this.m_poolHolder, inkEVerticalAlign.Top);
    inkWidgetRef.SetHAlign(this.m_poolHolder, inkEHorizontalAlign.Left);
    i = 0;
    while i < this.m_maxCooldowns {
      tempSingleCooldownManagerRef = this.SpawnFromLocal(inkWidgetRef.Get(this.m_poolHolder), n"SingleCooldownBar").GetController() as SingleCooldownManager;
      tempSingleCooldownManagerRef.GetRootWidget().SetVAlign(inkEVerticalAlign.Top);
      tempSingleCooldownManagerRef.GetRootWidget().SetHAlign(inkEHorizontalAlign.Left);
      tempSingleCooldownManagerRef.Init(this.m_poolHolder, this.m_cooldownContainer);
      ArrayPush(this.m_cooldownPool, tempSingleCooldownManagerRef);
      i += 1;
    };
    this.m_blackboardDef = GetAllBlackboardDefs().UI_PlayerBioMonitor;
    this.m_blackboard = this.GetBlackboardSystem().Get(this.m_blackboardDef);
    if Equals(this.m_mode, ECooldownGameControllerMode.COOLDOWNS) {
      this.m_buffsCallback = this.m_blackboard.RegisterDelayedListenerVariant(this.m_blackboardDef.BuffsList, this, n"OnEffectUpdate");
    } else {
      if Equals(this.m_mode, ECooldownGameControllerMode.BUFFS_AND_DEBUFFS) {
        this.m_buffsCallback = this.m_blackboard.RegisterDelayedListenerVariant(this.m_blackboardDef.BuffsList, this, n"OnEffectUpdate");
        this.m_debuffsCallback = this.m_blackboard.RegisterDelayedListenerVariant(this.m_blackboardDef.DebuffsList, this, n"OnEffectUpdate");
      };
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_buffsCallback) {
      this.m_blackboard.UnregisterDelayedListener(this.m_blackboardDef.BuffsList, this.m_buffsCallback);
    };
    if IsDefined(this.m_debuffsCallback) {
      this.m_blackboard.UnregisterDelayedListener(this.m_blackboardDef.DebuffsList, this.m_debuffsCallback);
    };
  }

  private final func ParseBuffList(buffList: array<UIBuffInfo>) -> Void {
    let foundIndex: Int32;
    let i: Int32;
    let j: Int32;
    ArrayGrow(this.m_matchBuffer, this.m_maxCooldowns);
    j = 0;
    i = 0;
    while i < this.m_maxCooldowns {
      if NotEquals(this.m_cooldownPool[i].GetState(), ECooldownIndicatorState.Pooled) {
        this.m_matchBuffer[j] = this.m_cooldownPool[i];
        j += 1;
      };
      i += 1;
    };
    j = 0;
    while j < ArraySize(buffList) {
      foundIndex = -1;
      i = 0;
      while i < ArraySize(this.m_matchBuffer) {
        if IsDefined(this.m_matchBuffer[i]) && this.m_matchBuffer[i].IsIDMatch(buffList[j].buffID) {
          foundIndex = i;
          this.m_matchBuffer[foundIndex].Update(buffList[j].timeRemaining, buffList[j].stackCount);
          ArrayErase(this.m_matchBuffer, foundIndex);
        } else {
          i += 1;
        };
      };
      if foundIndex < 0 {
        this.RequestCooldownVisualization(buffList[j]);
      };
      j += 1;
    };
    i = 0;
    while i < ArraySize(this.m_matchBuffer) {
      if IsDefined(this.m_matchBuffer[i]) && NotEquals(this.m_matchBuffer[i].GetState(), ECooldownIndicatorState.Pooled) {
        this.m_matchBuffer[i].RemoveCooldown();
      };
      i += 1;
    };
    ArrayClear(this.m_matchBuffer);
  }

  private final func GetInstance() -> GameInstance {
    return (this.GetOwnerEntity() as GameObject).GetGame();
  }

  protected cb func OnEffectUpdate(v: Variant) -> Bool {
    let buffs: array<BuffInfo>;
    let debuffs: array<BuffInfo>;
    let effect: UIBuffInfo;
    let effects: array<UIBuffInfo>;
    let i: Int32;
    if !this.GetRootWidget().IsVisible() {
      return false;
    };
    if Equals(this.m_mode, ECooldownGameControllerMode.COOLDOWNS) {
      this.GetBuffs(buffs);
      i = 0;
      while i < ArraySize(buffs) {
        if Equals(TweakDBInterface.GetStatusEffectRecord(buffs[i].buffID).StatusEffectType().Type(), gamedataStatusEffectType.PlayerCooldown) {
          effect.buffID = buffs[i].buffID;
          effect.timeRemaining = buffs[i].timeRemaining;
          effect.isBuff = true;
          ArrayPush(effects, effect);
        };
        i += 1;
      };
    } else {
      this.GetBuffs(buffs);
      this.GetDebuffs(debuffs);
      i = 0;
      while i < ArraySize(buffs) {
        effect.buffID = buffs[i].buffID;
        effect.timeRemaining = buffs[i].timeRemaining;
        effect.isBuff = true;
        effect.stackCount = StatusEffectHelper.GetStatusEffectByID(this.GetPlayerControlledObject(), effect.buffID).GetStackCount();
        ArrayPush(effects, effect);
        i += 1;
      };
      i = 0;
      while i < ArraySize(debuffs) {
        effect.buffID = debuffs[i].buffID;
        effect.timeRemaining = debuffs[i].timeRemaining;
        effect.isBuff = false;
        effect.stackCount = StatusEffectHelper.GetStatusEffectByID(this.GetPlayerControlledObject(), effect.buffID).GetStackCount();
        ArrayPush(effects, effect);
        i += 1;
      };
    };
    if ArraySize(effects) > 0 {
      this.ParseBuffList(effects);
    };
  }

  private final const func GetBuffs(buffs: script_ref<array<BuffInfo>>) -> Void {
    buffs = FromVariant(this.m_blackboard.GetVariant(this.m_blackboardDef.BuffsList));
  }

  private final const func GetDebuffs(debuffs: script_ref<array<BuffInfo>>) -> Void {
    debuffs = FromVariant(this.m_blackboard.GetVariant(this.m_blackboardDef.DebuffsList));
  }

  protected cb func OnCooldownUpdate(buffList: array<BuffInfo>) -> Bool;

  public final func RequestCooldownVisualization(buffData: UIBuffInfo) -> Void {
    let i: Int32;
    if buffData.timeRemaining <= 0.00 {
      return;
    };
    i = 0;
    while i < this.m_maxCooldowns {
      if Equals(this.m_cooldownPool[i].GetState(), ECooldownIndicatorState.Pooled) {
        this.m_cooldownPool[i].ActivateCooldown(buffData);
        return;
      };
      i += 1;
    };
  }
}
