
public class hudTurretController extends inkHUDGameController {

  private edit let m_Date: inkTextRef;

  private edit let m_Timer: inkTextRef;

  private edit let m_CameraID: inkTextRef;

  private edit let healthStatus: inkTextRef;

  private edit let m_MessageText: inkTextRef;

  private edit let m_pitchFluff: inkTextRef;

  private edit let m_yawFluff: inkTextRef;

  private edit let m_leftPart: inkWidgetRef;

  private edit let m_rightPart: inkWidgetRef;

  @default(hudTurretController, -838.0f)
  private let offsetLeft: Float;

  @default(hudTurretController, 1495.0f)
  private let offsetRight: Float;

  private let currentTime: GameTime;

  private let m_bbPlayerStats: wref<IBlackboard>;

  private let m_bbPlayerEventId: ref<CallbackHandle>;

  private let m_currentHealth: Int32;

  private let m_previousHealth: Int32;

  private let m_maximumHealth: Int32;

  private let m_playerObject: wref<GameObject>;

  private let m_playerPuppet: wref<GameObject>;

  private let m_gameInstance: GameInstance;

  private let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let delayInitialize: ref<DelayedHUDInitializeEvent>;
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    this.currentTime = GameInstance.GetTimeSystem(ownerObject.GetGame()).GetGameTime();
    inkTextRef.SetText(this.m_Date, "XX-XX-XXXX");
    inkTextRef.SetText(this.m_CameraID, GetLocalizedText("Story-base-gameplay-gui-widgets-turret_hud-turret_hud-_localizationString7"));
    inkTextRef.SetText(this.m_Timer, ToString(GameTime.Hours(this.currentTime)) + ":" + ToString(GameTime.Minutes(this.currentTime)) + ":" + ToString(GameTime.Seconds(this.currentTime)));
    delayInitialize = new DelayedHUDInitializeEvent();
    GameInstance.GetDelaySystem(this.GetPlayerControlledObject().GetGame()).DelayEvent(this.GetPlayerControlledObject(), delayInitialize, 0.10);
    this.GetPlayerControlledObject().RegisterInputListener(this);
  }

  protected cb func OnUninitialize() -> Bool {
    TakeOverControlSystem.CreateInputHint(this.GetPlayerControlledObject().GetGame(), false);
    SecurityTurret.CreateInputHint(this.GetPlayerControlledObject().GetGame(), false);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let optionIntro: inkAnimOptions;
    this.m_bbPlayerStats = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    this.m_bbPlayerEventId = this.m_bbPlayerStats.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.PlayerStatsInfo, this, n"OnStatsChanged");
    this.m_playerObject = playerPuppet;
    this.m_playerPuppet = playerPuppet;
    this.m_gameInstance = this.GetPlayerControlledObject().GetGame();
    this.PlayLibraryAnimation(n"Malfunction");
    optionIntro.executionDelay = 1.50;
    this.PlaySound(n"MiniGame", n"AccessGranted");
    this.PlayLibraryAnimation(n"intro", optionIntro);
    this.PlayAnim(n"intro2", n"OnIntroComplete");
    optionIntro.executionDelay = 2.00;
    this.PlayLibraryAnimation(n"Malfunction_off", optionIntro);
    this.PlayAnim(n"Malfunction_timed", n"OnMalfunction");
    this.UpdateJohnnyThemeOverride(true);
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    if IsDefined(this.m_bbPlayerStats) {
      this.m_bbPlayerStats.UnregisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.PlayerStatsInfo, this.m_bbPlayerEventId);
    };
    this.PlayLibraryAnimation(n"outro");
    this.UpdateJohnnyThemeOverride(false);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let yaw: Float = ClampF(this.m_playerPuppet.GetWorldYaw(), -300.00, 300.00);
    inkTextRef.SetText(this.m_yawFluff, ToString(yaw));
    inkTextRef.SetText(this.m_pitchFluff, ToString(yaw * 1.50));
    inkWidgetRef.SetMargin(this.m_leftPart, new inkMargin(yaw, this.offsetLeft, 0.00, 0.00));
    inkWidgetRef.SetMargin(this.m_rightPart, new inkMargin(this.offsetRight, yaw, 0.00, 0.00));
  }

  protected cb func OnMalfunction(anim: ref<inkAnimProxy>) -> Bool {
    let optionIntro: inkAnimOptions;
    let optionMalfunction: inkAnimOptions;
    if GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q104_turret_broken") == 1 && GameInstance.GetQuestsSystem(this.m_gameInstance).GetFact(n"q104_turret_fixed") == 0 {
      this.PlaySound(n"MiniGame", n"AccessDenied");
      inkTextRef.SetText(this.m_MessageText, "LocKey#11338");
      optionMalfunction.fromMarker = n"intro";
      optionMalfunction.toMarker = n"loop_start";
      this.PlayAnim(n"Malfunction", n"OnMalfunctionLoop", optionMalfunction);
      optionIntro.executionDelay = 28.00;
      this.PlayLibraryAnimation(n"Malfunction_off", optionIntro);
    };
  }

  protected cb func OnMalfunctionLoop(anim: ref<inkAnimProxy>) -> Bool {
    let optionMalfunctionLoop: inkAnimOptions;
    optionMalfunctionLoop.loopInfinite = false;
    optionMalfunctionLoop.loopType = inkanimLoopType.Cycle;
    optionMalfunctionLoop.loopCounter = 65u;
    optionMalfunctionLoop.fromMarker = n"loop_start";
    optionMalfunctionLoop.toMarker = n"loop_end";
    this.PlayAnim(n"Malfunction", n"OnMalfunctionLoopEnd", optionMalfunctionLoop);
  }

  protected cb func OnMalfunctionLoopEnd(anim: ref<inkAnimProxy>) -> Bool {
    let optionMalfunctionLoopEnd: inkAnimOptions;
    optionMalfunctionLoopEnd.fromMarker = n"loop_end";
    this.PlayAnim(n"Malfunction", n"", optionMalfunctionLoopEnd);
  }

  protected cb func OnIntroComplete(anim: ref<inkAnimProxy>) -> Bool {
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_main_menu_cc_loading");
  }

  protected cb func OnStatsChanged(value: Variant) -> Bool {
    let incomingData: PlayerBioMonitor = FromVariant(value);
    this.m_previousHealth = this.m_currentHealth;
    this.m_maximumHealth = incomingData.maximumHealth;
    this.m_currentHealth = CeilF(GameInstance.GetStatPoolsSystem(this.m_playerObject.GetGame()).GetStatPoolValue(Cast(GetPlayer(this.m_playerObject.GetGame()).GetEntityID()), gamedataStatPoolType.Health, false));
    this.m_currentHealth = Clamp(this.m_currentHealth, 0, this.m_maximumHealth);
    inkTextRef.SetText(this.healthStatus, IntToString(RoundF(Cast(this.m_currentHealth))) + "/" + IntToString(RoundF(Cast(this.m_maximumHealth))));
  }

  protected cb func OnDelayedHUDInitializeEvent(evt: ref<DelayedHUDInitializeEvent>) -> Bool {
    TakeOverControlSystem.CreateInputHint(this.GetPlayerControlledObject().GetGame(), true);
    SecurityTurret.CreateInputHint(this.GetPlayerControlledObject().GetGame(), true);
  }

  public final func PlayAnim(animName: CName, opt callBack: CName, opt animOptions: inkAnimOptions) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop(true);
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName, animOptions);
    if NotEquals(callBack, n"") {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }

  private final func UpdateJohnnyThemeOverride(value: Bool) -> Void {
    let uiSystem: ref<UISystem>;
    let controlledPuppet: wref<gamePuppetBase> = GetPlayer(this.m_gameInstance);
    if IsDefined(controlledPuppet) && controlledPuppet.IsJohnnyReplacer() {
      uiSystem = GameInstance.GetUISystem(this.m_gameInstance);
      if IsDefined(uiSystem) {
        if value {
          uiSystem.SetGlobalThemeOverride(n"Johnny");
        } else {
          uiSystem.ClearGlobalThemeOverride();
        };
      };
    };
  }
}
