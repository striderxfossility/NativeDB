
public class GodModeStatListener extends ScriptStatsListener {

  public let m_healthbar: wref<healthbarWidgetGameController>;

  public func OnGodModeChanged(ownerID: EntityID, newType: gameGodModeType) -> Void {
    if this.m_healthbar != null {
      this.m_healthbar.UpdateGodModeVisibility();
    };
  }
}

public class healthbarWidgetGameController extends inkHUDGameController {

  private let m_bbPlayerStats: wref<IBlackboard>;

  private let m_bbPlayerEventId: ref<CallbackHandle>;

  private let m_bbRightWeaponInfo: wref<IBlackboard>;

  private let m_bbRightWeaponEventId: ref<CallbackHandle>;

  private let m_bbLeftWeaponInfo: wref<IBlackboard>;

  private let m_bbLeftWeaponEventId: ref<CallbackHandle>;

  private let m_bbPSceneTierEventId: ref<CallbackHandle>;

  private let m_visionStateBlackboardId: ref<CallbackHandle>;

  private let m_combatModeBlackboardId: ref<CallbackHandle>;

  private let m_bbQuickhacksMemeoryEventId: ref<CallbackHandle>;

  private edit let m_healthPath: inkWidgetPath;

  private edit let m_healthBarPath: inkWidgetPath;

  private edit let m_armorPath: inkWidgetPath;

  private edit let m_armorBarPath: inkWidgetPath;

  private edit let m_expBar: inkWidgetRef;

  private edit let m_expBarSpacer: inkWidgetRef;

  private edit let m_levelUpArrow: inkWidgetRef;

  private edit let m_levelUpFrame: inkWidgetRef;

  private edit let m_barsLayoutPath: inkCompoundRef;

  private edit let m_buffsHolder: inkCompoundRef;

  private edit let m_invulnerableTextPath: inkTextRef;

  private edit let m_levelTextPath: inkTextRef;

  private edit let m_nextLevelTextPath: inkTextRef;

  private edit let m_healthTextPath: inkTextRef;

  private edit let m_maxHealthTextPath: inkTextRef;

  private edit let m_quickhacksContainer: inkCompoundRef;

  private edit let m_expText: inkTextRef;

  private edit let m_expTextLabel: inkTextRef;

  private edit let m_lostHealthAggregationBar: inkWidgetRef;

  private edit let m_levelUpRectangle: inkWidgetRef;

  private let m_healthController: wref<NameplateBarLogicController>;

  private let m_armorController: wref<ProgressBarSimpleWidgetLogicController>;

  private let m_RootWidget: wref<inkWidget>;

  private let m_buffWidget: wref<inkWidget>;

  private let m_HPBar: wref<inkWidget>;

  private let m_armorBar: wref<inkWidget>;

  private let m_invulnerableText: wref<inkText>;

  private let m_animHideTemp: ref<inkAnimDef>;

  private let m_animShortFade: ref<inkAnimDef>;

  private let m_animLongFade: ref<inkAnimDef>;

  private let m_animHideHPProxy: ref<inkAnimProxy>;

  public let delayAnimation: ref<inkAnimDef>;

  public let animCreated: Bool;

  public let aggregatingActive: Bool;

  public let countingStartHealth: Int32;

  private let m_currentHealth: Int32;

  private let m_previousHealth: Int32;

  private let m_maximumHealth: Int32;

  private let m_quickhacksMemoryPercent: Float;

  @default(healthbarWidgetGameController, 0)
  private let m_currentArmor: Int32;

  @default(healthbarWidgetGameController, 0)
  private let m_maximumArmor: Int32;

  private let m_quickhackBarArray: array<wref<inkWidget>>;

  private let m_spawnedMemoryCells: Int32;

  private let m_usedQuickhacks: Int32;

  private let m_buffsVisible: Bool;

  @default(healthbarWidgetGameController, true)
  private let m_isUnarmedRightHand: Bool;

  @default(healthbarWidgetGameController, true)
  private let m_isUnarmedLeftHand: Bool;

  private let m_currentVisionPSM: gamePSMVision;

  private let m_combatModePSM: gamePSMCombat;

  private let m_sceneTier: GameplayTier;

  private let m_godModeStatListener: ref<GodModeStatListener>;

  private let m_playerStatsBlackboard: wref<IBlackboard>;

  private let characterCurrentXPListener: ref<CallbackHandle>;

  private let m_levelUpBlackboard: wref<IBlackboard>;

  private let playerLevelUpListener: ref<CallbackHandle>;

  private let m_currentLevel: Int32;

  private let m_playerObject: wref<GameObject>;

  private let m_playerDevelopmentSystem: ref<PlayerDevelopmentSystem>;

  private let m_gameInstance: GameInstance;

  private let m_foldingAnimProxy: ref<inkAnimProxy>;

  private let m_memoryFillCells: Float;

  private let m_memoryMaxCells: Int32;

  private let m_pendingRequests: Int32;

  private let m_spawnTokens: array<wref<inkAsyncSpawnRequest>>;

  protected cb func OnInitialize() -> Bool {
    let requestStatsEvent: ref<RequestStatsBB>;
    this.m_playerObject = this.GetOwnerEntity() as GameObject;
    this.m_RootWidget = this.GetRootWidget();
    this.m_buffWidget = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buffsHolder), r"base\\gameplay\\gui\\widgets\\healthbar\\playerbuffbar.inkwidget", n"VertRoot");
    this.m_currentHealth = CeilF(GameInstance.GetStatPoolsSystem(this.m_playerObject.GetGame()).GetStatPoolValue(Cast(GetPlayer(this.m_playerObject.GetGame()).GetEntityID()), gamedataStatPoolType.Health, false));
    this.m_playerDevelopmentSystem = GameInstance.GetScriptableSystemsContainer(this.m_playerObject.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    this.m_HPBar = this.GetWidget(this.m_healthPath);
    this.m_armorBar = this.GetWidget(this.m_armorPath);
    this.m_healthController = this.GetController(this.m_healthBarPath) as NameplateBarLogicController;
    this.m_armorController = this.GetController(this.m_armorBarPath) as ProgressBarSimpleWidgetLogicController;
    this.m_bbPlayerStats = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    this.m_bbPlayerEventId = this.m_bbPlayerStats.RegisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.PlayerStatsInfo, this, n"OnStatsChanged");
    this.m_bbPlayerStats.SignalVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.PlayerStatsInfo);
    this.m_bbQuickhacksMemeoryEventId = this.m_bbPlayerStats.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_PlayerBioMonitor.MemoryPercent, this, n"OnQuickhacksMemoryPercentUpdate");
    this.m_bbRightWeaponInfo = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    this.m_bbRightWeaponEventId = this.m_bbRightWeaponInfo.RegisterListenerVariant(GetAllBlackboardDefs().UIGameData.RightWeaponRecordID, this, n"OnRightWeaponSwap");
    this.m_bbLeftWeaponInfo = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    this.m_bbLeftWeaponEventId = this.m_bbLeftWeaponInfo.RegisterListenerVariant(GetAllBlackboardDefs().UIGameData.LeftWeaponRecordID, this, n"OnLeftWeaponSwap");
    this.m_playerStatsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerStats);
    this.characterCurrentXPListener = this.m_playerStatsBlackboard.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP, this, n"OnCharacterLevelCurrentXPUpdated");
    this.m_playerStatsBlackboard.SignalInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP);
    this.AnimateCharacterLevelUpdated(this.m_playerStatsBlackboard.GetInt(GetAllBlackboardDefs().UI_PlayerStats.Level), true);
    this.m_levelUpBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerStats);
    this.playerLevelUpListener = this.m_levelUpBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_PlayerStats.Level, this, n"OnCharacterLevelUpdated");
    this.m_levelUpBlackboard.SignalInt(GetAllBlackboardDefs().UI_PlayerStats.Level);
    this.CreateAnimations();
    this.ComputeHealthBarVisibility();
    this.SetupQuickhacksMemoryBar();
    requestStatsEvent = new RequestStatsBB();
    requestStatsEvent.Set(this.m_playerObject);
    this.m_playerDevelopmentSystem.QueueRequest(requestStatsEvent);
    this.m_gameInstance = this.GetPlayerControlledObject().GetGame();
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_bbPlayerStats) {
      this.m_bbPlayerStats.UnregisterListenerVariant(GetAllBlackboardDefs().UI_PlayerBioMonitor.PlayerStatsInfo, this.m_bbPlayerEventId);
      this.m_bbPlayerStats.UnregisterDelayedListener(GetAllBlackboardDefs().UI_PlayerBioMonitor.MemoryPercent, this.m_bbQuickhacksMemeoryEventId);
    };
    if IsDefined(this.m_bbRightWeaponInfo) {
      this.m_bbRightWeaponInfo.UnregisterListenerVariant(GetAllBlackboardDefs().UIGameData.RightWeaponRecordID, this.m_bbRightWeaponEventId);
    };
    if IsDefined(this.m_bbLeftWeaponInfo) {
      this.m_bbLeftWeaponInfo.UnregisterListenerVariant(GetAllBlackboardDefs().UIGameData.LeftWeaponRecordID, this.m_bbLeftWeaponEventId);
    };
    if IsDefined(this.m_playerStatsBlackboard) {
      this.m_playerStatsBlackboard.UnregisterListenerInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP, this.characterCurrentXPListener);
    };
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    let controlledPuppet: wref<gamePuppetBase>;
    let controlledPuppetRecordID: TweakDBID;
    this.RegisterPSMListeners(playerGameObject);
    if IsDefined(this.m_foldingAnimProxy) {
      this.m_foldingAnimProxy.Stop();
    };
    this.m_foldingAnimProxy = this.PlayLibraryAnimation(n"unfold");
    controlledPuppet = GetPlayer(this.m_gameInstance);
    if controlledPuppet != null {
      controlledPuppetRecordID = controlledPuppet.GetRecordID();
      if controlledPuppetRecordID == t"Character.johnny_replacer" {
        inkWidgetRef.SetVisible(this.m_levelUpRectangle, false);
      } else {
        inkWidgetRef.SetVisible(this.m_levelUpRectangle, true);
      };
    } else {
      inkWidgetRef.SetVisible(this.m_levelUpRectangle, true);
    };
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(playerGameObject);
    if IsDefined(this.m_foldingAnimProxy) {
      this.m_foldingAnimProxy.Stop();
    };
    this.m_foldingAnimProxy = this.PlayLibraryAnimation(n"fold");
  }

  protected final func RegisterPSMListeners(playerObject: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerObject);
      if IsDefined(playerStateMachineBlackboard) {
        this.m_visionStateBlackboardId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.Vision, this, n"OnPSMVisionStateChanged");
        this.m_bbPSceneTierEventId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.SceneTier, this, n"OnSceneTierChange");
        this.m_combatModeBlackboardId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.Combat, this, n"OnCombatStateChanged");
      };
      this.m_godModeStatListener = new GodModeStatListener();
      this.m_godModeStatListener.m_healthbar = this;
      GameInstance.GetStatsSystem(playerObject.GetGame()).RegisterListener(Cast(playerObject.GetEntityID()), this.m_godModeStatListener);
    };
  }

  protected final func UnregisterPSMListeners(playerObject: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerObject);
      if IsDefined(playerStateMachineBlackboard) {
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.Vision, this.m_visionStateBlackboardId);
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.SceneTier, this.m_bbPSceneTierEventId);
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.Combat, this.m_combatModeBlackboardId);
        GameInstance.GetStatsSystem(playerObject.GetGame()).UnregisterListener(Cast(playerObject.GetEntityID()), this.m_godModeStatListener);
        this.m_godModeStatListener = null;
      };
    };
  }

  private final func StartDamageFallDelay() -> Void {
    let delayInterpolator: ref<inkAnimScale>;
    let delayProxy: ref<inkAnimProxy>;
    let selfSize: Vector2;
    let size: Vector2;
    let width: Float;
    if !IsDefined(this.delayAnimation) {
      this.delayAnimation = new inkAnimDef();
      delayInterpolator = new inkAnimScale();
      delayInterpolator.SetStartDelay(1.00);
      delayInterpolator.SetDuration(0.00);
      delayInterpolator.SetDirection(inkanimInterpolationDirection.From);
      delayInterpolator.SetType(inkanimInterpolationType.Linear);
      delayInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      delayInterpolator.SetStartScale(new Vector2(1.00, 1.00));
      this.delayAnimation.AddInterpolator(delayInterpolator);
    };
    if !this.aggregatingActive {
      delayProxy = inkWidgetRef.PlayAnimation(this.m_expText, this.delayAnimation);
      delayProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnDamageAggregationFinished");
      this.aggregatingActive = true;
      this.countingStartHealth = this.m_previousHealth;
      inkWidgetRef.SetScale(this.m_lostHealthAggregationBar, new Vector2(1.00, 1.00));
    };
    size = this.m_healthController.GetFullSize();
    selfSize = inkWidgetRef.GetSize(this.m_lostHealthAggregationBar);
    width = Cast(this.countingStartHealth - this.m_currentHealth) / Cast(this.m_maximumHealth) * size.X;
    inkWidgetRef.SetSize(this.m_lostHealthAggregationBar, new Vector2(width, selfSize.Y));
  }

  protected cb func OnDamageAggregationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.aggregatingActive = false;
    this.PlayLibraryAnimation(n"hide_delay_bar");
  }

  private final func SetHealthProgress(value: Float) -> Void {
    value = ClampF(value, 0.01, 1.00);
    let percentHP: Float = 100.00 * Cast(this.m_currentHealth) / Cast(this.m_maximumHealth);
    percentHP = ClampF(percentHP, 1.00, 100.00);
    this.m_healthController.SetNameplateBarProgress(value, this.m_previousHealth == this.m_currentHealth);
    inkTextRef.SetText(this.m_healthTextPath, IntToString(this.m_currentHealth));
    inkTextRef.SetText(this.m_maxHealthTextPath, IntToString(this.m_maximumHealth));
    if this.m_previousHealth > this.m_currentHealth {
      this.StartDamageFallDelay();
    };
  }

  protected cb func OnCharacterLevelUpdated(value: Int32) -> Bool {
    this.AnimateCharacterLevelUpdated(value);
  }

  private final func AnimateCharacterLevelUpdated(value: Int32, opt skipAnimation: Bool) -> Void {
    let levelUpProxy: ref<inkAnimProxy>;
    if this.m_currentLevel != value {
      this.m_currentLevel = value;
      inkTextRef.SetText(this.m_nextLevelTextPath, IntToString(this.m_currentLevel));
      if !skipAnimation {
        levelUpProxy = this.PlayLibraryAnimation(n"levelup_animation");
        levelUpProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnLevelUpAnimationFinished");
      } else {
        inkWidgetRef.SetOpacity(this.m_levelUpArrow, 0.00);
        inkWidgetRef.SetOpacity(this.m_levelUpFrame, 0.00);
        this.OnLevelUpAnimationFinished(levelUpProxy);
      };
      this.ComputeHealthBarVisibility();
    };
  }

  protected cb func OnLevelUpAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    inkTextRef.SetText(this.m_levelTextPath, IntToString(this.m_currentLevel));
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnCharacterLevelCurrentXPUpdated(value: Int32) -> Bool {
    let remainingXP: Int32 = this.m_playerDevelopmentSystem.GetRemainingExpForLevelUp(this.m_playerObject, gamedataProficiencyType.Level);
    let expSum: Int32 = remainingXP + value;
    let progressFloat: Float = Cast(value) / Cast(expSum);
    inkTextRef.SetText(this.m_expText, IntToString(value));
    inkTextRef.SetText(this.m_expTextLabel, "LocKey#23263");
    inkWidgetRef.SetSizeCoefficient(this.m_expBar, progressFloat);
    inkWidgetRef.SetSizeCoefficient(this.m_expBarSpacer, 1.00 - progressFloat);
  }

  private final func AdjustRequest() -> Void;

  private final func SetupQuickhacksMemoryBar() -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_quickhacksContainer);
    this.m_spawnedMemoryCells = 0;
    this.m_memoryMaxCells = FloorF(GameInstance.GetStatsSystem((this.GetOwnerEntity() as PlayerPuppet).GetGame()).GetStatValue(Cast(this.GetPlayerControlledObject().GetEntityID()), gamedataStatType.Memory));
    this.m_memoryFillCells = Cast(this.m_memoryMaxCells);
    this.UpdateQuickhacksMemoryBarSize(this.m_memoryMaxCells);
  }

  private final func UpdateQuickhacksMemoryBarSize(size: Int32) -> Void {
    let i: Int32;
    let requestToken: wref<inkAsyncSpawnRequest>;
    if size > this.m_spawnedMemoryCells {
      i = this.m_spawnedMemoryCells + this.m_pendingRequests;
      while i < size {
        requestToken = this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_quickhacksContainer), n"quickhackBar", this, n"OnMemoryBarSpawned");
        ArrayPush(this.m_spawnTokens, requestToken);
        this.m_pendingRequests += 1;
        i += 1;
      };
    } else {
      this.UpdateMemoryBarData();
    };
  }

  protected cb func OnMemoryBarSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_spawnedMemoryCells += 1;
    this.m_pendingRequests -= 1;
    ArrayPush(this.m_quickhackBarArray, widget);
    if this.m_pendingRequests <= 0 {
      ArrayClear(this.m_spawnTokens);
      this.UpdateMemoryBarData();
    };
  }

  private final func UpdateMemoryBarData() -> Void {
    let quickhackBar: wref<inkWidget>;
    let quickhackBarController: wref<QuickhackBarController>;
    let fillCellsInt: Int32 = FloorF(this.m_memoryFillCells);
    let i: Int32 = 0;
    while i < ArraySize(this.m_quickhackBarArray) {
      if i >= this.m_memoryMaxCells {
        this.m_quickhackBarArray[i].SetVisible(false);
      } else {
        quickhackBar = this.m_quickhackBarArray[i];
        quickhackBarController = quickhackBar.GetController() as QuickhackBarController;
        if fillCellsInt < this.m_memoryMaxCells {
          if i < fillCellsInt {
            quickhackBarController.SetStatus(1.00);
          } else {
            if i == fillCellsInt {
              quickhackBarController.SetStatus(this.m_memoryFillCells - Cast(fillCellsInt));
            } else {
              quickhackBarController.SetStatus(0.00);
            };
          };
        } else {
          quickhackBarController.SetStatus(1.00);
        };
        quickhackBar.SetVisible(true);
      };
      i += 1;
    };
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnQuickhacksMemoryPercentUpdate(value: Float) -> Bool {
    this.m_memoryMaxCells = FloorF(GameInstance.GetStatsSystem((this.GetOwnerEntity() as PlayerPuppet).GetGame()).GetStatValue(Cast(this.GetPlayerControlledObject().GetEntityID()), gamedataStatType.Memory));
    this.m_memoryFillCells = Cast(this.m_memoryMaxCells) * value * 0.01;
    this.m_usedQuickhacks = this.m_memoryMaxCells - FloorF(this.m_memoryFillCells);
    this.m_quickhacksMemoryPercent = value;
    this.UpdateQuickhacksMemoryBarSize(this.m_memoryMaxCells);
  }

  private final func IsCyberdeckEquipped() -> Bool {
    let itemTags: array<CName>;
    let systemReplacementID: ItemID = EquipmentSystem.GetData(this.GetPlayerControlledObject()).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    let itemRecord: wref<Item_Record> = RPGManager.GetItemRecord(systemReplacementID);
    if IsDefined(itemRecord) {
      itemTags = itemRecord.Tags();
    };
    return ArrayContains(itemTags, n"Cyberdeck");
  }

  private final func SetArmorProgress(normalizedValue: Float, silent: Bool) -> Void;

  protected cb func OnStatsChanged(value: Variant) -> Bool {
    let incomingData: PlayerBioMonitor = FromVariant(value);
    this.m_previousHealth = this.m_currentHealth;
    if this.m_playerObject != null {
      this.m_maximumHealth = CeilF(GameInstance.GetStatsSystem(this.m_playerObject.GetGame()).GetStatValue(Cast(GetPlayer(this.m_playerObject.GetGame()).GetEntityID()), gamedataStatType.Health));
      this.m_currentHealth = CeilF(GameInstance.GetStatPoolsSystem(this.m_playerObject.GetGame()).GetStatPoolValue(Cast(GetPlayer(this.m_playerObject.GetGame()).GetEntityID()), gamedataStatPoolType.Health, false));
      this.m_currentHealth = Clamp(this.m_currentHealth, 0, this.m_maximumHealth);
    } else {
      this.m_maximumHealth = incomingData.maximumHealth;
      this.m_currentHealth = incomingData.currentHealth;
    };
    this.m_currentArmor = incomingData.currentArmor;
    this.m_maximumArmor = incomingData.maximumArmor;
    this.SetHealthProgress(Cast(this.m_currentHealth) / Cast(this.m_maximumHealth));
    this.SetArmorProgress(Cast(this.m_currentArmor) / Cast(this.m_maximumArmor), false);
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnRightWeaponSwap(value: Variant) -> Bool {
    this.m_isUnarmedRightHand = FromVariant(value) == TDBID.undefined();
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnLeftWeaponSwap(value: Variant) -> Bool {
    this.m_isUnarmedLeftHand = FromVariant(value) == TDBID.undefined();
    this.ComputeHealthBarVisibility();
  }

  private final const func IsUnarmed() -> Bool {
    return this.m_isUnarmedRightHand && this.m_isUnarmedLeftHand;
  }

  public final func UpdateGodModeVisibility() -> Void {
    inkWidgetRef.SetVisible(this.m_invulnerableTextPath, this.HelperHasGodMode());
  }

  private final func ComputeHealthBarVisibility() -> Void {
    let isMaxHP: Bool = this.m_currentHealth == this.m_maximumHealth;
    let isMultiplayer: Bool = this.IsPlayingMultiplayer();
    let areQuickhacksUsed: Bool = this.m_usedQuickhacks > 0;
    this.m_armorBar.SetVisible(isMultiplayer);
    this.UpdateGodModeVisibility();
    inkWidgetRef.SetVisible(this.m_quickhacksContainer, this.IsCyberdeckEquipped());
    if NotEquals(this.m_currentVisionPSM, gamePSMVision.Default) {
      this.HideRequest();
      return;
    };
    if !isMaxHP || areQuickhacksUsed || isMultiplayer || Equals(this.m_combatModePSM, gamePSMCombat.InCombat) || this.m_quickhacksMemoryPercent < 100.00 || this.m_buffsVisible {
      this.ShowRequest();
    } else {
      this.HideRequest();
    };
  }

  protected cb func OnHPHideAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_HPBar.SetVisible(false);
    inkWidgetRef.SetVisible(this.m_healthTextPath, false);
    inkWidgetRef.SetVisible(this.m_buffsHolder, false);
  }

  private final func IsPlayingMultiplayer() -> Bool {
    let playerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    return IsDefined(playerObject) && GameInstance.GetRuntimeInfo(playerObject.GetGame()).IsMultiplayer();
  }

  private final func HelperHasGodMode() -> Bool {
    let playerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    let godMode: ref<GodModeSystem> = GameInstance.GetGodModeSystem(playerObject.GetGame());
    return godMode.HasGodMode(playerObject.GetEntityID(), gameGodModeType.Invulnerable);
  }

  private final func CreateAnimations() -> Void {
    let animStartDelay: Float = 1.00;
    this.m_animShortFade = new inkAnimDef();
    let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInterp.SetStartDelay(2.00);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.35);
    this.m_animShortFade.AddInterpolator(fadeInterp);
    this.m_animLongFade = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(10.00);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.35);
    this.m_animLongFade.AddInterpolator(fadeInterp);
    this.m_animHideTemp = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(animStartDelay + 0.26);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.22);
    this.m_animHideTemp.AddInterpolator(fadeInterp);
  }

  protected cb func OnCombatStateChanged(value: Int32) -> Bool {
    this.m_combatModePSM = IntEnum(value);
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnPSMVisionStateChanged(value: Int32) -> Bool {
    this.m_currentVisionPSM = IntEnum(value);
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnSceneTierChange(argTier: Int32) -> Bool {
    this.m_sceneTier = IntEnum(argTier);
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnBuffListVisibilityChanged(evt: ref<BuffListVisibilityChangedEvent>) -> Bool {
    this.m_buffsVisible = evt.m_hasBuffs;
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnForceHide() -> Bool {
    this.ComputeHealthBarVisibility();
  }

  protected cb func OnForceTierVisibility(tierVisibility: Bool) -> Bool {
    this.ComputeHealthBarVisibility();
  }
}

public class QuickhackBarController extends inkLogicController {

  private edit let m_emptyMask: inkWidgetRef;

  private edit let m_empty: inkWidgetRef;

  private edit let m_full: inkWidgetRef;

  public final func SetStatus(value: Float) -> Void {
    if value <= 0.00 {
      inkWidgetRef.SetVisible(this.m_full, false);
      inkWidgetRef.SetVisible(this.m_empty, true);
      inkWidgetRef.SetScale(this.m_emptyMask, new Vector2(1.00, 1.00));
    } else {
      if value >= 1.00 {
        inkWidgetRef.SetVisible(this.m_empty, false);
        inkWidgetRef.SetVisible(this.m_full, true);
      } else {
        inkWidgetRef.SetVisible(this.m_full, true);
        inkWidgetRef.SetVisible(this.m_empty, true);
        inkWidgetRef.SetScale(this.m_emptyMask, new Vector2(1.00, 1.00 - value));
      };
    };
  }
}
