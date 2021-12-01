
public struct GameTimeUtils {

  public final static func CanPlayerTimeSkip(playerPuppet: ref<PlayerPuppet>) -> Bool {
    let timeSystem: ref<TimeSystem>;
    let blockTimeSkip: Bool = false;
    let tier: Int32 = playerPuppet.GetPlayerStateMachineBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    let psmBlackboard: ref<IBlackboard> = playerPuppet.GetPlayerStateMachineBlackboard();
    blockTimeSkip = psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) || StatusEffectSystem.ObjectHasStatusEffectWithTag(playerPuppet, n"NoTimeSkip") || timeSystem.IsPausedState() || playerPuppet.IsMovingVertically() || psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Swimming) == EnumInt(gamePSMSwimming.Diving) || tier >= EnumInt(gamePSMHighLevel.SceneTier3) && tier <= EnumInt(gamePSMHighLevel.SceneTier5);
    return !blockTimeSkip;
  }

  public final static func IsTimeDisplayGlitched(playerPuppet: ref<PlayerPuppet>) -> Bool {
    let blockTimeSkip: Bool = false;
    blockTimeSkip = StatusEffectSystem.ObjectHasStatusEffectWithTag(playerPuppet, n"NoTimeDisplay");
    return blockTimeSkip;
  }

  public final static func UpdateGameTimeText(timeSystem: ref<TimeSystem>, textWidgetRef: inkTextRef, textParamsRef: ref<inkTextParams>) -> Void {
    let gameTime: GameTime;
    if timeSystem == null {
      return;
    };
    gameTime = timeSystem.GetGameTime();
    if textParamsRef == null {
      textParamsRef = new inkTextParams();
      textParamsRef.AddNCGameTime("VALUE", gameTime);
      inkTextRef.SetText(textWidgetRef, "{VALUE,time,short}", textParamsRef);
    } else {
      textParamsRef.UpdateTime("VALUE", gameTime);
    };
  }
}

public class TimeMenuGameController extends inkGameController {

  private edit let m_selectTimeText: inkWidgetRef;

  private edit let m_selectorRef: inkWidgetRef;

  private edit let m_currentTime: inkTextRef;

  private edit let m_applyBtn: inkWidgetRef;

  private edit let m_backBtn: inkWidgetRef;

  private edit let m_combatWarning: inkTextRef;

  private let m_data: ref<TimeSkipPopupData>;

  private let m_gameInstance: GameInstance;

  @default(TimeMenuGameController, true)
  private let m_inputEnabled: Bool;

  @default(TimeMenuGameController, false)
  private let m_timeChanged: Bool;

  private let m_selectorCtrl: wref<SelectorController>;

  private let m_timeSystem: ref<TimeSystem>;

  private let m_hoursToSkip: Int32;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_currentTimeTextParams: ref<inkTextParams>;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_playerSpawnedCallbackID: Uint32;

  protected cb func OnInitialize() -> Bool {
    let canSkipTime: Bool;
    let playerPuppet: ref<PlayerPuppet>;
    this.m_data = this.GetRootWidget().GetUserData(n"TimeSkipPopupData") as TimeSkipPopupData;
    this.m_gameInstance = (this.GetOwnerEntity() as GameObject).GetGame();
    this.m_timeSystem = GameInstance.GetTimeSystem(this.m_gameInstance);
    this.UpdateTimeText();
    this.SetupSelector();
    this.m_selectorCtrl.RegisterToCallback(n"OnSelectionChanged", this, n"OnHoursChanged");
    inkWidgetRef.RegisterToCallback(this.m_applyBtn, n"OnPress", this, n"OnPressApply");
    inkWidgetRef.RegisterToCallback(this.m_backBtn, n"OnPress", this, n"OnPressBack");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalInput");
    this.PlayIntroAnim();
    playerPuppet = this.GetOwnerEntity() as PlayerPuppet;
    canSkipTime = GameTimeUtils.CanPlayerTimeSkip(playerPuppet);
    if !canSkipTime {
      this.ToggleTimeSkip(canSkipTime);
    };
  }

  private final func ToggleTimeSkip(enableTimeSkip: Bool) -> Void {
    if enableTimeSkip {
      inkWidgetRef.SetVisible(this.m_selectorRef, true);
      inkWidgetRef.SetVisible(this.m_currentTime, true);
      inkWidgetRef.SetVisible(this.m_applyBtn, true);
      inkWidgetRef.SetVisible(this.m_selectTimeText, true);
      inkWidgetRef.SetVisible(this.m_combatWarning, false);
    } else {
      inkWidgetRef.SetVisible(this.m_selectorRef, false);
      inkWidgetRef.SetVisible(this.m_currentTime, false);
      inkWidgetRef.SetVisible(this.m_applyBtn, false);
      inkWidgetRef.SetVisible(this.m_selectTimeText, false);
      inkWidgetRef.SetVisible(this.m_combatWarning, true);
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_selectorCtrl.UnregisterFromCallback(n"OnSelectionChanged", this, n"OnHoursChanged");
    inkWidgetRef.UnregisterFromCallback(this.m_applyBtn, n"OnPress", this, n"OnPressApply");
    inkWidgetRef.UnregisterFromCallback(this.m_backBtn, n"OnPress", this, n"OnPressBack");
  }

  private final func SetupSelector() -> Void {
    this.m_selectorCtrl = inkWidgetRef.GetController(this.m_selectorRef) as SelectorController;
    this.m_selectorCtrl.AddValue("1:00");
    this.m_selectorCtrl.AddValue("2:00");
    this.m_selectorCtrl.AddValue("3:00");
    this.m_selectorCtrl.AddValue("4:00");
    this.m_selectorCtrl.AddValue("5:00");
    this.m_selectorCtrl.AddValue("6:00");
    this.m_selectorCtrl.AddValue("7:00");
    this.m_selectorCtrl.AddValue("8:00");
    this.m_selectorCtrl.AddValue("9:00");
    this.m_selectorCtrl.AddValue("10:00");
    this.m_selectorCtrl.AddValue("11:00");
    this.m_selectorCtrl.AddValue("12:00");
    this.m_selectorCtrl.AddValue("13:00");
    this.m_selectorCtrl.AddValue("14:00");
    this.m_selectorCtrl.AddValue("15:00");
    this.m_selectorCtrl.AddValue("16:00");
    this.m_selectorCtrl.AddValue("17:00");
    this.m_selectorCtrl.AddValue("18:00");
    this.m_selectorCtrl.AddValue("19:00");
    this.m_selectorCtrl.AddValue("20:00");
    this.m_selectorCtrl.AddValue("21:00");
    this.m_selectorCtrl.AddValue("22:00");
    this.m_selectorCtrl.AddValue("23:00");
    this.m_selectorCtrl.AddValue("24:00");
    this.m_selectorCtrl.SetCurrIndex(0);
    this.m_hoursToSkip = 1;
  }

  protected cb func OnHoursChanged(index: Int32, value: String) -> Bool {
    GameInstance.GetAudioSystem(this.m_gameInstance).Play(n"ui_menu_onpress");
    this.m_hoursToSkip = index + 1;
  }

  protected cb func OnPressApply(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      e.Handle();
      this.Apply();
    };
  }

  protected cb func OnPressBack(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      e.Handle();
      this.Cancel();
    };
  }

  protected cb func OnGlobalInput(e: ref<inkPointerEvent>) -> Bool {
    if e.IsHandled() {
      return false;
    };
    if e.IsAction(n"one_click_confirm") {
      e.Handle();
      this.Apply();
    };
    if e.IsAction(n"back") || e.IsAction(n"cancel") {
      e.Handle();
      this.Cancel();
    };
    if e.IsAction(n"option_switch_prev") {
      this.PlaySound(n"Button", n"OnPress");
      this.m_selectorCtrl.Prior();
      e.Handle();
    };
    if e.IsAction(n"option_switch_next") {
      this.PlaySound(n"Button", n"OnPress");
      this.m_selectorCtrl.Next();
      e.Handle();
    };
  }

  private final func Apply() -> Void {
    let currentTime: GameTime;
    let hours: Int32;
    let minutes: Int32;
    let seconds: Int32;
    if !this.m_inputEnabled {
      return;
    };
    this.m_inputEnabled = false;
    if this.m_hoursToSkip > 0 {
      currentTime = this.m_timeSystem.GetGameTime();
      hours = GameTime.Hours(currentTime) + this.m_hoursToSkip;
      minutes = GameTime.Minutes(currentTime);
      seconds = GameTime.Seconds(currentTime);
      this.m_timeSystem.SetGameTimeByHMS(hours, minutes, seconds);
      this.FastForwardPlayerState();
      this.UpdateTimeText();
      this.m_timeChanged = true;
    };
    this.PlayLibraryAnimation(n"change");
    GameInstance.GetAudioSystem(this.m_gameInstance).Play(n"ui_menu_map_timeskip");
    this.PlayOutroAnim();
  }

  private final func Cancel() -> Void {
    if !this.m_inputEnabled {
      return;
    };
    this.m_inputEnabled = false;
    GameInstance.GetAudioSystem(this.m_gameInstance).Play(n"ui_menu_onpress");
    this.PlayOutroAnim();
  }

  public final func FastForwardPlayerState() -> Void {
    let effects: array<ref<StatusEffect>>;
    let i: Int32;
    let maxPassiveRegenValue: Float;
    let remainingTime: Float;
    let statPoolsSys: ref<StatPoolsSystem>;
    let statusEffectSys: ref<StatusEffectSystem>;
    let player: ref<GameObject> = this.GetPlayerControlledObject();
    if IsDefined(player) {
      statPoolsSys = GameInstance.GetStatPoolsSystem(player.GetGame());
      if IsDefined(statPoolsSys) {
        maxPassiveRegenValue = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.HealthOutOfCombatRegenEndThreshold);
        if statPoolsSys.GetStatPoolValue(Cast(player.GetEntityID()), gamedataStatPoolType.Health) < maxPassiveRegenValue {
          statPoolsSys.RequestSettingStatPoolValue(Cast(player.GetEntityID()), gamedataStatPoolType.Health, maxPassiveRegenValue, player);
        };
        statPoolsSys.RequestSettingStatPoolValue(Cast(player.GetEntityID()), gamedataStatPoolType.Stamina, 100.00, player);
      };
      statusEffectSys = GameInstance.GetStatusEffectSystem(player.GetGame());
      statusEffectSys.GetAppliedEffects(player.GetEntityID(), effects);
      i = 0;
      while i < ArraySize(effects) {
        remainingTime = effects[i].GetRemainingDuration();
        if remainingTime > 0.00 {
          statusEffectSys.RemoveStatusEffect(player.GetEntityID(), effects[i].GetRecord().GetID(), effects[i].GetStackCount());
        };
        i += 1;
      };
    };
  }

  private final func StopAnim() -> Void {
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
      this.m_animProxy.Stop();
      this.m_animProxy = null;
    };
  }

  private final func PlayIntroAnim() -> Void {
    this.StopAnim();
    this.m_animProxy = this.PlayLibraryAnimation(n"intro");
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnIntroAnimEnd");
  }

  private final func PlayLoopAnim() -> Void {
    let options: inkAnimOptions;
    this.StopAnim();
    options.loopType = inkanimLoopType.Cycle;
    options.loopInfinite = true;
    this.m_animProxy = this.PlayLibraryAnimation(n"loop", options);
  }

  private final func PlayOutroAnim() -> Void {
    this.StopAnim();
    this.m_animProxy = this.PlayLibraryAnimation(n"outro");
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimEnd");
  }

  protected cb func OnIntroAnimEnd(proxy: ref<inkAnimProxy>) -> Bool {
    this.PlayLoopAnim();
  }

  protected cb func OnOutroAnimEnd(proxy: ref<inkAnimProxy>) -> Bool {
    this.StopAnim();
    this.Close();
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
  }

  protected final func Close() -> Void {
    let data: ref<TimeSkipPopupCloseData> = new TimeSkipPopupCloseData();
    data.timeChanged = this.m_timeChanged;
    this.m_data.token.TriggerCallback(data);
  }

  private final func UpdateTimeText() -> Void {
    if inkWidgetRef.IsValid(this.m_currentTime) {
      GameTimeUtils.UpdateGameTimeText(this.m_timeSystem, this.m_currentTime, this.m_currentTimeTextParams);
    };
  }
}
