
public class NameplateVisualsLogicController extends inkLogicController {

  private let m_rootWidget: wref<inkCompoundWidget>;

  private edit let m_bigIconMain: inkWidgetRef;

  private edit let m_bigLevelText: inkTextRef;

  private edit let m_nameTextMain: inkTextRef;

  private edit let m_bigIconArt: inkImageRef;

  private edit let m_preventionIcon: inkWidgetRef;

  private edit let m_levelContainer: inkImageRef;

  private edit let m_nameFrame: inkWidgetRef;

  private edit let m_healthbarWidget: inkWidgetRef;

  private edit let m_healthBarFull: inkWidgetRef;

  private edit let m_healthBarFrame: inkWidgetRef;

  private edit let m_taggedIcon: inkWidgetRef;

  private edit let m_iconBG: inkWidgetRef;

  private edit let m_civilianIcon: inkWidgetRef;

  private edit let m_stealthMappinSlot: inkCompoundRef;

  private edit let m_iconTextWrapper: inkCompoundRef;

  private edit let m_container: inkWidgetRef;

  private edit let m_LevelcontainerAndText: inkCompoundRef;

  private edit let m_rareStars: inkCompoundRef;

  private edit let m_eliteStars: inkCompoundRef;

  private edit let m_hardEnemy: inkImageRef;

  private edit let m_hardEnemyWrapper: inkWidgetRef;

  private edit let m_damagePreviewWrapper: inkWidgetRef;

  private edit let m_damagePreviewWidget: inkWidgetRef;

  private edit let m_damagePreviewArrow: inkWidgetRef;

  private edit let m_buffsList: inkHorizontalPanelRef;

  private let m_buffWidgets: array<wref<inkWidget>>;

  private let m_cachedPuppet: wref<GameObject>;

  private let m_cachedIncomingData: NPCNextToTheCrosshair;

  private let m_isOfficer: Bool;

  private let m_isBoss: Bool;

  private let m_isElite: Bool;

  private let m_isRare: Bool;

  private let m_isPrevention: Bool;

  private let m_canCallReinforcements: Bool;

  private let m_isCivilian: Bool;

  private let m_isBurning: Bool;

  private let m_isPoisoned: Bool;

  private let m_bossColor: Color;

  private let m_npcDefeated: Bool;

  private let m_isStealthMappinVisible: Bool;

  private let m_playerZone: gamePSMZones;

  private let m_npcNamesEnabled: Bool;

  private let m_healthController: wref<NameplateBarLogicController>;

  private let m_hasCenterIcon: Bool;

  private let m_animatingObject: inkWidgetRef;

  private let m_isAnimating: Bool;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_preventionAnimProxy: ref<inkAnimProxy>;

  private let m_damagePreviewAnimProxy: ref<inkAnimProxy>;

  @default(NameplateVisualsLogicController, false)
  private let m_isQuestTarget: Bool;

  @default(NameplateVisualsLogicController, false)
  private let m_forceHide: Bool;

  private let m_isHardEnemy: Bool;

  private let m_npcIsAggressive: Bool;

  private let m_playerAimingDownSights: Bool;

  private let m_playerInCombat: Bool;

  private let m_playerInStealth: Bool;

  private let m_healthNotFull: Bool;

  private let m_healthbarVisible: Bool;

  private let m_levelContainerShouldBeVisible: Bool;

  private let m_currentHealth: Int32;

  private let m_maximumHealth: Int32;

  private let m_currentDamagePreviewValue: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget() as inkCompoundWidget;
    this.m_healthController = inkWidgetRef.GetController(this.m_healthbarWidget) as NameplateBarLogicController;
    this.m_npcDefeated = false;
    this.m_playerAimingDownSights = false;
    this.m_playerInCombat = false;
    this.m_playerInStealth = false;
    this.m_healthNotFull = false;
    this.m_healthbarVisible = false;
    inkWidgetRef.SetVisible(this.m_buffsList, false);
    inkWidgetRef.SetVisible(this.m_healthbarWidget, false);
  }

  public final func SetVisualData(puppet: ref<GameObject>, incomingData: NPCNextToTheCrosshair, opt isNewNpc: Bool) -> Void {
    this.m_cachedPuppet = puppet;
    this.m_cachedIncomingData = incomingData;
    let npc: ref<NPCPuppet> = incomingData.npc as NPCPuppet;
    if IsDefined(npc) {
      if Equals(incomingData.attitude, EAIAttitude.AIA_Hostile) {
        this.m_npcIsAggressive = true;
      } else {
        if npc.IsAggressive() && NotEquals(incomingData.attitude, EAIAttitude.AIA_Friendly) {
          this.m_npcIsAggressive = true;
        } else {
          this.m_npcIsAggressive = false;
        };
      };
    } else {
      if IsDefined(incomingData.npc) && incomingData.npc.IsTurret() {
        if NotEquals(incomingData.attitude, EAIAttitude.AIA_Friendly) {
          this.m_npcIsAggressive = true;
        } else {
          this.m_npcIsAggressive = false;
        };
      } else {
        this.m_npcIsAggressive = false;
      };
    };
    this.m_currentHealth = incomingData.currentHealth;
    this.m_maximumHealth = incomingData.maximumHealth;
    this.m_healthNotFull = incomingData.currentHealth < incomingData.maximumHealth;
    this.m_npcDefeated = !ScriptedPuppet.IsActive(incomingData.npc);
    if IsDefined(npc) && !this.m_npcDefeated {
      this.m_npcDefeated = npc.IsAboutToBeDefeated() || npc.IsAboutToDie();
    };
    this.SetNPCType(puppet as ScriptedPuppet);
    this.SetAttitudeColors(puppet as ScriptedPuppet, incomingData);
    this.SetElementVisibility(incomingData);
    if !IsDefined(incomingData.npc) || incomingData.level == 0 && !incomingData.npc.IsTurret() {
      this.m_levelContainerShouldBeVisible = false;
    };
    this.UpdateHealthbarVisibility();
    if incomingData.maximumHealth == 0 {
      this.m_healthController.SetNameplateBarProgress(0.00, isNewNpc);
    } else {
      this.m_healthController.SetNameplateBarProgress(Cast(incomingData.currentHealth) / Cast(incomingData.maximumHealth), isNewNpc);
    };
    if this.m_currentDamagePreviewValue > 0 {
      this.PreviewDamage(this.m_currentDamagePreviewValue);
    };
  }

  public final func PreviewDamage(value: Int32) -> Void {
    let animOptions: inkAnimOptions;
    let currentHealthPercentage: Float;
    let damagePercentage: Float;
    let offset: Float;
    let renderTransformXPivot: Float;
    this.m_currentDamagePreviewValue = value;
    if value <= 0 {
      if IsDefined(this.m_damagePreviewAnimProxy) && this.m_damagePreviewAnimProxy.IsPlaying() {
        this.m_damagePreviewAnimProxy.Stop();
      };
      inkWidgetRef.SetVisible(this.m_damagePreviewWrapper, false);
    } else {
      if this.m_maximumHealth > 0 {
        currentHealthPercentage = Cast(this.m_currentHealth) / Cast(this.m_maximumHealth);
        damagePercentage = Cast(value) / Cast(this.m_maximumHealth);
        damagePercentage = MinF(damagePercentage, currentHealthPercentage);
        renderTransformXPivot = damagePercentage < 1.00 ? (currentHealthPercentage - damagePercentage) / (1.00 - damagePercentage) : 1.00;
        offset = 100.00 + 150.00 * damagePercentage - 150.00 * currentHealthPercentage;
        inkWidgetRef.SetRenderTransformPivot(this.m_damagePreviewWidget, new Vector2(renderTransformXPivot, 1.00));
        inkWidgetRef.SetScale(this.m_damagePreviewWidget, new Vector2(damagePercentage, 1.00));
        inkWidgetRef.SetMargin(this.m_damagePreviewArrow, 0.00, -22.00, offset, 0.00);
        if !IsDefined(this.m_damagePreviewAnimProxy) || !this.m_damagePreviewAnimProxy.IsPlaying() {
          animOptions.loopType = inkanimLoopType.Cycle;
          animOptions.loopInfinite = true;
          this.m_damagePreviewAnimProxy = this.PlayLibraryAnimation(n"damage_preview_looping", animOptions);
        };
        inkWidgetRef.SetVisible(this.m_damagePreviewWrapper, true);
      };
    };
  }

  public final func GetHeightOffser() -> Float {
    let size: Vector2 = inkWidgetRef.GetDesiredSize(this.m_container);
    return size.Y;
  }

  public final func UpdateBecauseOfMapPin() -> Void {
    this.SetVisualData(this.m_cachedPuppet, this.m_cachedIncomingData);
  }

  public final func UpdatePlayerZone(zone: gamePSMZones, opt onlySetValue: Bool) -> Void {
    this.m_playerZone = zone;
    if IsDefined(this.m_cachedPuppet) && !onlySetValue {
      this.SetVisualData(this.m_cachedPuppet, this.m_cachedIncomingData);
    };
  }

  public final func UpdatePlayerAimStatus(state: gamePSMUpperBodyStates, opt onlySetValue: Bool) -> Void {
    this.m_playerAimingDownSights = Equals(state, gamePSMUpperBodyStates.Aim);
    if IsDefined(this.m_cachedPuppet) && !onlySetValue {
      this.UpdateHealthbarVisibility();
    };
  }

  public final func UpdatePlayerCombat(state: gamePSMCombat, opt onlySetValue: Bool) -> Void {
    this.m_playerInCombat = Equals(state, gamePSMCombat.InCombat);
    this.m_playerInStealth = Equals(state, gamePSMCombat.Stealth);
    if IsDefined(this.m_cachedPuppet) && !onlySetValue {
      this.UpdateHealthbarVisibility();
    };
  }

  public final func UpdateNPCNamesEnabled(value: Bool, opt onlySetValue: Bool) -> Void {
    this.m_npcNamesEnabled = value;
    if IsDefined(this.m_cachedPuppet) && !onlySetValue {
      this.SetVisualData(this.m_cachedPuppet, this.m_cachedIncomingData);
    };
  }

  public final func UpdateHealthbarColor(isHostile: Bool) -> Void {
    if isHostile {
      inkWidgetRef.SetState(this.m_healthbarWidget, n"Hostile");
      inkWidgetRef.SetState(this.m_healthBarFull, n"Hostile");
    } else {
      inkWidgetRef.SetState(this.m_healthbarWidget, n"Neutral_Enemy");
      inkWidgetRef.SetState(this.m_healthBarFull, n"Neutral_Enemy");
    };
  }

  private final func UpdateHealthbarVisibility() -> Void {
    let hpVisible: Bool = this.m_npcIsAggressive && !this.m_isBoss && (this.m_healthNotFull || this.m_playerAimingDownSights || this.m_playerInCombat || this.m_playerInStealth);
    if NotEquals(this.m_healthbarVisible, hpVisible) {
      this.m_healthbarVisible = hpVisible;
      inkWidgetRef.SetVisible(this.m_healthbarWidget, this.m_healthbarVisible);
    };
  }

  private final func SetNPCType(puppet: wref<ScriptedPuppet>) -> Void {
    let puppetRarity: gamedataNPCRarity;
    this.m_isOfficer = false;
    this.m_isBoss = false;
    this.m_isCivilian = false;
    this.m_canCallReinforcements = false;
    this.m_isElite = false;
    this.m_isRare = false;
    this.m_isPrevention = false;
    if IsDefined(puppet) {
      this.m_isPrevention = puppet.IsPrevention();
      puppetRarity = puppet.GetPuppetRarity().Type();
      switch puppetRarity {
        case gamedataNPCRarity.Officer:
          this.m_isOfficer = true;
          break;
        case gamedataNPCRarity.Boss:
          this.m_isBoss = true;
          break;
        case gamedataNPCRarity.Elite:
          this.m_isElite = true;
          break;
        case gamedataNPCRarity.Rare:
          this.m_isRare = true;
      };
      this.m_canCallReinforcements = GameInstance.GetStatsSystem(puppet.GetGame()).GetStatBoolValue(Cast(puppet.GetEntityID()), gamedataStatType.CanCallReinforcements);
    };
  }

  private final func UpdateCenterIcon(texture: CName) -> Void {
    if Equals(texture, n"") {
      inkWidgetRef.SetVisible(this.m_bigIconArt, false);
    } else {
      inkWidgetRef.SetVisible(this.m_bigIconArt, true);
      inkImageRef.SetTexturePart(this.m_bigIconArt, texture);
    };
  }

  private final func SetAttitudeColors(puppet: wref<gamePuppetBase>, incomingData: NPCNextToTheCrosshair) -> Void {
    let attitudeColor: CName;
    inkTextRef.SetLetterCase(this.m_nameTextMain, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_nameTextMain, incomingData.name);
    inkTextRef.SetText(this.m_bigLevelText, "");
    switch incomingData.attitude {
      case EAIAttitude.AIA_Hostile:
        attitudeColor = n"Hostile";
        break;
      case EAIAttitude.AIA_Friendly:
        attitudeColor = n"Friendly";
        break;
      case EAIAttitude.AIA_Neutral:
        attitudeColor = n"Neutral";
        break;
      default:
        attitudeColor = n"Civilian";
    };
    if this.m_npcIsAggressive {
      inkWidgetRef.SetState(this.m_bigLevelText, attitudeColor);
      inkWidgetRef.SetState(this.m_bigIconArt, this.m_isQuestTarget ? n"Quest" : n"Hostile");
      inkWidgetRef.SetState(this.m_civilianIcon, this.m_isQuestTarget ? n"Quest" : n"Hostile");
      inkWidgetRef.SetState(this.m_rareStars, n"Hostile");
      inkWidgetRef.SetState(this.m_eliteStars, n"Hostile");
      inkWidgetRef.SetState(this.m_nameTextMain, this.m_isQuestTarget ? n"Quest" : n"Hostile");
    } else {
      inkWidgetRef.SetState(this.m_bigLevelText, attitudeColor);
      inkWidgetRef.SetState(this.m_bigIconArt, this.m_isQuestTarget ? n"Quest" : attitudeColor);
      inkWidgetRef.SetState(this.m_civilianIcon, this.m_isQuestTarget ? n"Quest" : attitudeColor);
      inkWidgetRef.SetState(this.m_rareStars, attitudeColor);
      inkWidgetRef.SetState(this.m_eliteStars, attitudeColor);
      inkWidgetRef.SetState(this.m_nameTextMain, this.m_isQuestTarget ? n"Quest" : attitudeColor);
      inkWidgetRef.SetState(this.m_hardEnemy, attitudeColor);
    };
    if this.m_isBoss {
      attitudeColor = n"Boss";
    };
    if puppet != null && puppet.IsPlayer() {
      inkWidgetRef.SetState(this.m_nameTextMain, n"CPO_Player");
    };
    if this.m_isPrevention {
      this.PlayPreventionAnim();
    } else {
      this.StopPreventionAnim();
    };
  }

  private final func SetElementVisibility(incomingData: NPCNextToTheCrosshair) -> Void {
    let enemyDifficulty: EPowerDifferential;
    let isTurret: Bool;
    let npc: ref<NPCPuppet>;
    inkWidgetRef.SetVisible(this.m_bigIconArt, false);
    inkWidgetRef.SetVisible(this.m_nameTextMain, false);
    inkWidgetRef.SetVisible(this.m_eliteStars, false);
    inkWidgetRef.SetVisible(this.m_rareStars, false);
    inkWidgetRef.SetVisible(this.m_civilianIcon, false);
    inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, false);
    inkWidgetRef.SetVisible(this.m_preventionIcon, false);
    this.m_levelContainerShouldBeVisible = false;
    this.m_isHardEnemy = false;
    isTurret = IsDefined(incomingData.npc) && incomingData.npc.IsTurret();
    npc = incomingData.npc as NPCPuppet;
    if IsDefined(npc) || isTurret {
      this.m_rootWidget.SetVisible(!this.m_forceHide && (incomingData.npc.IsPlayer() || !this.m_npcDefeated));
    };
    if this.m_npcIsAggressive {
      if isTurret {
        enemyDifficulty = EPowerDifferential.NORMAL;
      } else {
        enemyDifficulty = RPGManager.CalculatePowerDifferential(npc);
      };
      if !isTurret && (Equals(enemyDifficulty, EPowerDifferential.IMPOSSIBLE) || NPCManager.HasVisualTag(npc, n"Sumo")) {
        this.m_isHardEnemy = true;
        inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, true);
      } else {
        this.m_isHardEnemy = false;
        this.m_isAnimating = false;
        if IsDefined(this.m_animProxy) {
          this.m_animProxy.Stop();
          this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeInComplete");
          this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeOutComplete");
          this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnScreenDelayComplete");
        };
      };
      this.m_levelContainerShouldBeVisible = true;
      inkWidgetRef.SetVisible(this.m_bigLevelText, true);
      if this.m_isPrevention {
        this.UpdateCenterIcon(n"");
        inkWidgetRef.SetVisible(this.m_preventionIcon, true);
        inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, false);
      } else {
        if this.m_isElite {
          inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, true);
        } else {
          if this.m_isBoss {
            inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, true);
          };
        };
      };
    };
    if IsDefined(npc) && npc.IsVendor() {
      inkWidgetRef.SetVisible(this.m_nameTextMain, this.m_npcNamesEnabled);
      this.m_levelContainerShouldBeVisible = false;
    };
    if Equals(incomingData.attitude, EAIAttitude.AIA_Friendly) && !isTurret {
      inkWidgetRef.SetVisible(this.m_nameTextMain, this.m_npcNamesEnabled);
      this.m_levelContainerShouldBeVisible = false;
    };
    if inkWidgetRef.IsVisible(this.m_nameTextMain) && inkWidgetRef.IsVisible(this.m_nameFrame) {
      inkWidgetRef.SetVisible(this.m_civilianIcon, false);
    };
  }

  public final func IsAnyElementVisible() -> Bool {
    return inkWidgetRef.IsVisible(this.m_nameTextMain) || this.m_levelContainerShouldBeVisible;
  }

  private final func SetCycleAnimation(isNewNPC: Bool, incomingData: NPCNextToTheCrosshair) -> Void {
    if isNewNPC {
      this.m_animProxy.Stop();
      this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeInComplete");
      this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeOutComplete");
      this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnScreenDelayComplete");
      this.m_isAnimating = false;
      inkWidgetRef.SetOpacity(this.m_LevelcontainerAndText, 1.00);
    };
    if !this.m_isAnimating {
      this.m_animatingObject = this.m_hardEnemyWrapper;
      inkWidgetRef.SetOpacity(this.m_LevelcontainerAndText, 0.00);
      this.OnScreenDelay();
      this.m_isAnimating = true;
    };
  }

  private final func PlayPreventionAnim() -> Void {
    let initialState: CName;
    this.StopPreventionAnim();
    this.m_preventionAnimProxy = MappinUIUtils.PlayPreventionBlinkAnimation(this.GetRootWidget(), initialState);
    if IsDefined(this.m_preventionAnimProxy) {
      inkWidgetRef.SetState(this.m_preventionIcon, initialState);
      this.m_preventionAnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnPreventionAnimLoop");
    };
  }

  private final func StopPreventionAnim() -> Void {
    if IsDefined(this.m_preventionAnimProxy) {
      this.m_preventionAnimProxy.Stop();
      this.m_preventionAnimProxy = null;
    };
  }

  public final func OnPreventionAnimLoop(anim: ref<inkAnimProxy>) -> Void {
    let preventionState: CName = inkWidgetRef.GetState(this.m_preventionIcon);
    MappinUIUtils.CyclePreventionState(preventionState);
    inkWidgetRef.SetState(this.m_preventionIcon, preventionState);
  }

  public final func UpdateBuffDebuffList(argData: Variant, argIsBuffList: Bool) -> Void {
    let buffList: array<BuffInfo>;
    let buffTimeRemaining: Float;
    let currBuffLoc: wref<buffListItemLogicController>;
    let currBuffWidget: wref<inkWidget>;
    let data: ref<StatusEffect_Record>;
    let i: Int32;
    let iconPath: String;
    let incomingBuffsCount: Int32;
    let onScreenBuffsCount: Int32;
    if VariantIsValid(argData) {
      buffList = FromVariant(argData);
    };
    incomingBuffsCount = ArraySize(buffList);
    onScreenBuffsCount = inkCompoundRef.GetNumChildren(this.m_buffsList);
    inkWidgetRef.SetVisible(this.m_buffsList, incomingBuffsCount > 0);
    if incomingBuffsCount != 0 {
      if onScreenBuffsCount > incomingBuffsCount {
        i = incomingBuffsCount - 1;
        while i < onScreenBuffsCount {
          currBuffWidget = this.m_buffWidgets[i];
          currBuffWidget.SetVisible(false);
          i = i + 1;
        };
      } else {
        if onScreenBuffsCount < incomingBuffsCount {
          while onScreenBuffsCount < incomingBuffsCount {
            currBuffWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_buffsList), n"Buff");
            currBuffWidget.SetVisible(false);
            ArrayPush(this.m_buffWidgets, currBuffWidget);
            onScreenBuffsCount = onScreenBuffsCount + 1;
          };
        };
      };
    } else {
      i = 0;
      while i < onScreenBuffsCount {
        currBuffWidget = this.m_buffWidgets[i];
        currBuffWidget.SetVisible(false);
        i += 1;
      };
    };
    i = 0;
    while i < incomingBuffsCount {
      data = TweakDBInterface.GetStatusEffectRecord(buffList[i].buffID);
      buffTimeRemaining = buffList[i].timeRemaining;
      iconPath = data.UiData().IconPath();
      if Equals(iconPath, "") {
      } else {
        currBuffWidget = this.m_buffWidgets[i];
        currBuffWidget.SetVisible(true);
        currBuffLoc = currBuffWidget.GetController() as buffListItemLogicController;
        currBuffLoc.SetData(StringToName(iconPath), buffTimeRemaining);
      };
      i = i + 1;
    };
    this.SetVisualData(this.m_cachedPuppet, this.m_cachedIncomingData);
  }

  public final func CheckStealthMappinVisibility() -> Void {
    let stealthMappinRef: ref<inkWidget>;
    if inkCompoundRef.GetNumChildren(this.m_stealthMappinSlot) > 0 {
      stealthMappinRef = inkCompoundRef.GetWidgetByIndex(this.m_stealthMappinSlot, 0);
      this.m_isStealthMappinVisible = stealthMappinRef.IsVisible();
      if this.m_hasCenterIcon || inkWidgetRef.IsVisible(this.m_bigLevelText) {
        inkWidgetRef.SetVisible(this.m_iconTextWrapper, true);
      };
    };
  }

  public final func IsQuestTarget() -> Bool {
    return this.m_isQuestTarget;
  }

  public final func SetQuestTarget(value: Bool) -> Void {
    this.m_isQuestTarget = value;
  }

  public final func SetForceHide(value: Bool) -> Void {
    this.m_forceHide = value;
  }

  private final func OnFadeIn() -> Void {
    this.m_alpha_fadein = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetDuration(0.25);
    alphaInterpolator.SetStartTransparency(0.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_animProxy = inkWidgetRef.PlayAnimation(this.m_animatingObject, this.m_alpha_fadein);
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnFadeInComplete");
  }

  protected cb func OnFadeInComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeInComplete");
    this.OnScreenDelay();
  }

  private final func OnScreenDelay() -> Void {
    this.m_alpha_fadein = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetDuration(2.00);
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(1.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_animProxy = inkWidgetRef.PlayAnimation(this.m_animatingObject, this.m_alpha_fadein);
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnScreenDelayComplete");
  }

  protected cb func OnScreenDelayComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnScreenDelayComplete");
    this.OnFadeOut();
  }

  private final func OnFadeOut() -> Void {
    this.m_alpha_fadein = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetDuration(0.25);
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_animProxy = inkWidgetRef.PlayAnimation(this.m_animatingObject, this.m_alpha_fadein);
    this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnFadeOutComplete");
  }

  protected cb func OnFadeOutComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeOutComplete");
    if this.m_animatingObject == this.m_LevelcontainerAndText {
      this.m_animatingObject = this.m_hardEnemyWrapper;
    } else {
      if this.m_animatingObject == this.m_hardEnemyWrapper {
        this.m_animatingObject = this.m_LevelcontainerAndText;
      };
    };
    this.OnFadeIn();
  }
}
