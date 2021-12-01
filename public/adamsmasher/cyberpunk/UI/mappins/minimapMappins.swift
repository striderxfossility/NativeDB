
public native class BaseMinimapMappinController extends BaseMappinBaseController {

  protected let m_mappin: wref<IMappin>;

  protected let m_root: wref<inkWidget>;

  protected let m_aboveWidget: wref<inkWidget>;

  protected let m_belowWidget: wref<inkWidget>;

  protected edit native let clampArrowWidget: inkWidgetRef;

  protected final native func SetForceShow(value: Bool) -> Void;

  protected final native func SetForceHide(value: Bool) -> Void;

  protected cb func OnInitialize() -> Bool {
    this.Initialize();
  }

  protected cb func OnIntro() -> Bool {
    this.Intro();
  }

  protected cb func OnUpdate() -> Bool {
    this.Update();
  }

  protected func Initialize() -> Void {
    this.m_root = this.GetRootWidget();
    this.m_root.SetAnchorPoint(new Vector2(0.50, 0.50));
    this.m_root.SetAnchor(inkEAnchor.Centered);
    this.m_aboveWidget = this.GetWidget(n"Canvas/above");
    this.m_belowWidget = this.GetWidget(n"Canvas/below");
  }

  protected func Intro() -> Void {
    this.m_mappin = this.GetMappin();
    this.OnUpdate();
  }

  protected func Update() -> Void {
    this.UpdateClamping();
    this.UpdateRootState();
    this.UpdateTrackedState();
    this.UpdateAboveBelowVerticalRelation();
  }

  protected func KeepIconOnClamping() -> Bool {
    return false;
  }

  protected func UpdateClamping() -> Void {
    let isClamped: Bool = this.IsClamped();
    if inkWidgetRef.IsValid(this.clampArrowWidget) && !this.KeepIconOnClamping() {
      inkWidgetRef.SetVisible(this.iconWidget, !isClamped);
      inkWidgetRef.SetVisible(this.clampArrowWidget, isClamped);
    };
  }

  protected func UpdateAboveBelowVerticalRelation() -> Void {
    let animPlayer: ref<animationPlayer>;
    let isAbove: Bool;
    let isBelow: Bool;
    let shouldShowVertRelation: Bool;
    let vertRelation: gamemappinsVerticalPositioning;
    if this.m_aboveWidget == null && this.m_belowWidget == null {
      return;
    };
    vertRelation = this.GetVerticalRelationToPlayer();
    shouldShowVertRelation = this.GetRootWidget().IsVisible() && !this.IsClamped();
    isAbove = shouldShowVertRelation && Equals(vertRelation, gamemappinsVerticalPositioning.Above);
    isBelow = shouldShowVertRelation && Equals(vertRelation, gamemappinsVerticalPositioning.Below);
    this.m_aboveWidget.SetVisible(isAbove);
    this.m_belowWidget.SetVisible(isBelow);
    animPlayer = this.GetAnimPlayer_AboveBelow();
    if animPlayer != null {
      animPlayer.PlayOrStop(isAbove || isBelow);
    };
  }
}

public native class MinimapStealthMappinController extends BaseMinimapMappinController {

  protected native let visionConeWidget: inkImageRef;

  protected edit let m_pulseWidget: inkWidgetRef;

  private let m_stealthMappin: wref<StealthMappin>;

  private let m_fadeOutAnim: ref<inkAnimProxy>;

  private let m_isTagged: Bool;

  private let m_wasVisible: Bool;

  private let m_attitudeState: CName;

  private let m_preventionState: CName;

  private let m_pulsing: Bool;

  private let m_hasBeenLooted: Bool;

  private let m_isAggressive: Bool;

  private let m_detectionAboveZero: Bool;

  private let m_isAlive: Bool;

  private let m_wasAlive: Bool;

  private let m_wasCompanion: Bool;

  private let m_couldSeePlayer: Bool;

  private let m_isPrevention: Bool;

  private let m_isCrowdNPC: Bool;

  private let m_cautious: Bool;

  private let m_shouldShowVisionCone: Bool;

  private let m_isDevice: Bool;

  private let m_isCamera: Bool;

  private let m_isTurret: Bool;

  private let m_isNetrunner: Bool;

  private let m_isHacking: Bool;

  private let m_isSquadInCombat: Bool;

  private let m_wasSquadInCombat: Bool;

  private let m_clampingAvailable: Bool;

  private let m_defaultOpacity: Float;

  private let m_adjustedOpacity: Float;

  private let m_defaultConeOpacity: Float;

  private let m_detectingConeOpacity: Float;

  private let m_numberOfShotAttempts: Uint32;

  private let m_highestLootQuality: Uint32;

  private let m_lockLootQuality: Bool;

  private let m_highLevelState: gamedataNPCHighLevelState;

  private let m_iconWidgetGlitch: wref<inkWidget>;

  private let m_visionConeWidgetGlitch: wref<inkWidget>;

  private let m_clampArrowWidgetGlitch: wref<inkWidget>;

  private let m_showAnim: ref<inkAnimProxy>;

  private let m_alertedAnim: ref<inkAnimProxy>;

  private let m_preventionAnimProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.Initialize();
  }

  protected cb func OnIntro() -> Bool {
    this.Intro();
  }

  protected cb func OnUpdate() -> Bool {
    this.Update();
  }

  protected func Intro() -> Void {
    this.m_stealthMappin = this.GetMappin() as StealthMappin;
    let gameObject: wref<GameObject> = this.m_stealthMappin.GetGameObject();
    this.m_iconWidgetGlitch = inkWidgetRef.Get(this.iconWidget);
    this.m_visionConeWidgetGlitch = inkWidgetRef.Get(this.visionConeWidget);
    this.m_clampArrowWidgetGlitch = inkWidgetRef.Get(this.clampArrowWidget);
    if gameObject != null {
      this.m_isPrevention = gameObject.IsPrevention();
      this.m_isDevice = gameObject.IsDevice();
      this.m_isCamera = gameObject.IsDevice() && gameObject.IsSensor() && !gameObject.IsTurret();
      this.m_isTurret = gameObject.IsTurret();
      this.m_isNetrunner = this.m_stealthMappin.IsNetrunner();
    };
    this.m_isCrowdNPC = this.m_stealthMappin.IsCrowdNPC();
    if this.m_isCrowdNPC || gameObject != null && !gameObject.IsDevice() && !this.m_stealthMappin.IsAggressive() && NotEquals(this.m_stealthMappin.GetAttitudeTowardsPlayer(), EAIAttitude.AIA_Friendly) {
      this.m_defaultOpacity = 0.50;
    } else {
      this.m_defaultOpacity = 1.00;
    };
    this.m_root.SetOpacity(this.m_defaultOpacity);
    this.m_defaultConeOpacity = 0.80;
    this.m_detectingConeOpacity = 1.00;
    this.m_wasCompanion = ScriptedPuppet.IsPlayerCompanion(gameObject);
    if this.m_wasCompanion {
      inkImageRef.SetTexturePart(this.iconWidget, n"friendly_ally15");
    } else {
      if this.m_isCamera {
        inkImageRef.SetTexturePart(this.iconWidget, n"cameraMappin");
        inkImageRef.SetTexturePart(this.visionConeWidget, n"camera_cone");
      };
    };
    inkWidgetRef.SetOpacity(this.visionConeWidget, this.m_defaultConeOpacity);
    if this.m_isNetrunner {
      this.m_iconWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", true);
      this.m_visionConeWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", true);
      this.m_clampArrowWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", true);
    };
    this.m_wasAlive = true;
    this.m_cautious = false;
    this.m_lockLootQuality = false;
    this.Intro();
  }

  protected func Update() -> Void {
    let gameDevice: wref<Device>;
    let hasItems: Bool;
    let isOnSameFloor: Bool;
    let shouldShowMappin: Bool;
    let shouldShowVisionCone: Bool;
    let gameObject: wref<GameObject> = this.m_stealthMappin.GetGameObject();
    this.m_isAlive = this.m_stealthMappin.IsAlive();
    let isTagged: Bool = this.m_stealthMappin.IsTagged();
    let hasBeenSeen: Bool = this.m_stealthMappin.HasBeenSeen();
    let isCompanion: Bool = gameObject != null && ScriptedPuppet.IsPlayerCompanion(gameObject);
    let attitude: EAIAttitude = this.m_stealthMappin.GetAttitudeTowardsPlayer();
    let vertRelation: gamemappinsVerticalPositioning = this.GetVerticalRelationToPlayer();
    let shotAttempts: Uint32 = this.m_stealthMappin.GetNumberOfShotAttempts();
    this.m_highLevelState = this.m_stealthMappin.GetHighLevelState();
    let isHighlighted: Bool = this.m_stealthMappin.IsHighlighted();
    this.m_isSquadInCombat = this.m_stealthMappin.IsSquadInCombat();
    let canSeePlayer: Bool = this.m_stealthMappin.CanSeePlayer();
    this.m_detectionAboveZero = this.m_stealthMappin.GetDetectionProgress() > 0.00;
    let wasDetectionAboveZero: Bool = this.m_stealthMappin.WasDetectionAboveZero();
    let numberOfCombatantsAboveZero: Bool = this.m_stealthMappin.GetNumberOfCombatants() > 0u;
    let isUsingSenseCone: Bool = this.m_stealthMappin.IsUsingSenseCone();
    this.m_isHacking = this.m_stealthMappin.HasHackingStatusEffect();
    if this.m_isDevice {
      this.m_isAggressive = NotEquals(attitude, EAIAttitude.AIA_Friendly);
      if this.m_isAggressive {
        gameDevice = gameObject as Device;
        if IsDefined(gameDevice) {
          isUsingSenseCone = gameDevice.GetDevicePS().IsON();
        };
        if this.m_isCamera && numberOfCombatantsAboveZero {
          canSeePlayer = false;
          isUsingSenseCone = false;
        } else {
          if this.m_isTurret {
            isUsingSenseCone = isUsingSenseCone && (Equals(attitude, EAIAttitude.AIA_Hostile) || !this.m_isPrevention);
            if !isUsingSenseCone {
              this.m_isSquadInCombat = false;
            };
          };
        };
        if Equals(this.m_stealthMappin.GetStealthAwarenessState(), gameEnemyStealthAwarenessState.Combat) {
          this.m_isSquadInCombat = true;
        };
      };
    } else {
      this.m_isAggressive = this.m_stealthMappin.IsAggressive() && NotEquals(attitude, EAIAttitude.AIA_Friendly);
    };
    if !this.m_cautious {
      if !this.m_isDevice && NotEquals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) && NotEquals(this.m_highLevelState, gamedataNPCHighLevelState.Any) && !this.m_isSquadInCombat && this.m_isAlive && this.m_isAggressive {
        this.m_cautious = true;
        this.PulseContinuous(true);
      };
    } else {
      if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) || Equals(this.m_highLevelState, gamedataNPCHighLevelState.Any) || this.m_isSquadInCombat || !this.m_isAlive {
        this.m_cautious = false;
        this.PulseContinuous(false);
      };
    };
    if this.m_hasBeenLooted || this.m_stealthMappin.IsHiddenByQuestOnMinimap() {
      shouldShowMappin = false;
    } else {
      if this.m_isDevice && !this.m_isAggressive {
        shouldShowMappin = false;
      } else {
        if !IsMultiplayer() {
          shouldShowMappin = hasBeenSeen || !this.m_isAlive || isCompanion || wasDetectionAboveZero || isHighlighted || isTagged;
        } else {
          shouldShowMappin = (isCompanion || wasDetectionAboveZero || isHighlighted) && this.m_isAlive;
        };
      };
    };
    this.SetForceHide(!shouldShowMappin);
    if shouldShowMappin {
      if !this.m_isAlive {
        if this.m_wasAlive {
          if !this.m_isCamera {
            inkImageRef.SetTexturePart(this.iconWidget, n"enemy_icon_4");
            inkWidgetRef.SetScale(this.iconWidget, new Vector2(0.75, 0.75));
          };
          this.m_defaultOpacity = MinF(this.m_defaultOpacity, 0.50);
          this.m_wasAlive = false;
        };
        hasItems = this.m_stealthMappin.HasItems();
        if !hasItems || this.m_isDevice {
          this.FadeOut();
        };
      } else {
        if isCompanion && !this.m_wasCompanion {
          inkImageRef.SetTexturePart(this.iconWidget, n"friendly_ally15");
        } else {
          if NotEquals(this.m_isTagged, isTagged) && !this.m_isCamera {
            if isTagged {
              inkImageRef.SetTexturePart(this.iconWidget, n"enemyMappinTagged");
            } else {
              inkImageRef.SetTexturePart(this.iconWidget, n"enemyMappin");
            };
          };
        };
      };
      this.m_isTagged = isTagged;
      if this.m_isSquadInCombat && !this.m_wasSquadInCombat || this.m_numberOfShotAttempts != shotAttempts {
        this.m_numberOfShotAttempts = shotAttempts;
        this.Pulse(2);
      };
      isOnSameFloor = Equals(vertRelation, gamemappinsVerticalPositioning.Same);
      this.m_adjustedOpacity = isOnSameFloor ? this.m_defaultOpacity : 0.30 * this.m_defaultOpacity;
      shouldShowVisionCone = this.m_isAlive && isUsingSenseCone && this.m_isAggressive;
      if NotEquals(this.m_shouldShowVisionCone, shouldShowVisionCone) {
        this.m_shouldShowVisionCone = shouldShowVisionCone;
        this.m_stealthMappin.UpdateSenseConeAvailable(this.m_shouldShowVisionCone);
        if this.m_shouldShowVisionCone {
          this.m_stealthMappin.UpdateSenseCone();
        };
      };
      if this.m_shouldShowVisionCone {
        if NotEquals(canSeePlayer, this.m_couldSeePlayer) || this.m_isSquadInCombat && !this.m_wasSquadInCombat {
          if canSeePlayer && !this.m_isSquadInCombat {
            inkWidgetRef.SetOpacity(this.visionConeWidget, this.m_detectingConeOpacity);
            inkWidgetRef.SetScale(this.visionConeWidget, new Vector2(1.50, 1.50));
          } else {
            inkWidgetRef.SetOpacity(this.visionConeWidget, this.m_defaultConeOpacity);
            inkWidgetRef.SetScale(this.visionConeWidget, new Vector2(1.00, 1.00));
          };
          this.m_couldSeePlayer = canSeePlayer;
        };
      };
      inkWidgetRef.SetVisible(this.visionConeWidget, this.m_shouldShowVisionCone);
      if !this.m_wasVisible {
        if IsDefined(this.m_showAnim) {
          this.m_showAnim.Stop();
        };
        this.m_showAnim = this.PlayLibraryAnimation(n"Show");
      };
    };
    if this.m_isNetrunner {
      if !this.m_isAlive {
        this.m_iconWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", false);
        this.m_visionConeWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", false);
        this.m_clampArrowWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", false);
      } else {
        if this.m_isHacking {
          this.m_iconWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.70);
          this.m_visionConeWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.80);
          this.m_clampArrowWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.20);
        } else {
          this.m_iconWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.05);
          this.m_visionConeWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.05);
          this.m_clampArrowWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.05);
        };
      };
    };
    if !this.m_lockLootQuality {
      this.m_highestLootQuality = this.m_stealthMappin.GetHighestLootQuality();
    };
    this.m_attitudeState = this.GetStateForAttitude(attitude, canSeePlayer);
    this.m_stealthMappin.SetVisibleOnMinimap(shouldShowMappin);
    this.m_stealthMappin.SetIsPulsing(this.m_pulsing);
    this.m_clampingAvailable = this.m_isTagged || this.m_isAggressive && (this.m_isSquadInCombat || this.m_detectionAboveZero);
    this.OverrideClamp(this.m_clampingAvailable);
    this.m_wasCompanion = isCompanion;
    this.m_wasSquadInCombat = this.m_isSquadInCombat;
    this.m_wasVisible = shouldShowMappin;
    this.Update();
  }

  protected func UpdateClamping() -> Void {
    if this.IsClamped() {
      this.m_root.SetOpacity(1.00);
      inkWidgetRef.SetVisible(this.iconWidget, false);
      inkWidgetRef.SetVisible(this.m_pulseWidget, false);
      inkWidgetRef.SetVisible(this.visionConeWidget, false);
      inkWidgetRef.SetVisible(this.clampArrowWidget, this.m_clampingAvailable);
    } else {
      this.m_root.SetOpacity(this.m_adjustedOpacity);
      inkWidgetRef.SetVisible(this.iconWidget, true);
      inkWidgetRef.SetVisible(this.m_pulseWidget, this.m_pulsing);
      inkWidgetRef.SetVisible(this.visionConeWidget, this.m_shouldShowVisionCone);
      inkWidgetRef.SetVisible(this.clampArrowWidget, false);
    };
  }

  protected func UpdateAboveBelowVerticalRelation() -> Void {
    let vertRelation: gamemappinsVerticalPositioning = this.GetVerticalRelationToPlayer();
    if this.IsClamped() {
      this.m_aboveWidget.SetVisible(false);
      this.m_belowWidget.SetVisible(false);
    } else {
      this.m_aboveWidget.SetVisible(Equals(vertRelation, gamemappinsVerticalPositioning.Above));
      this.m_belowWidget.SetVisible(Equals(vertRelation, gamemappinsVerticalPositioning.Below));
    };
  }

  protected final func Pulse(count: Int32) -> Void {
    let animOptions: inkAnimOptions;
    if !IsDefined(this.m_alertedAnim) || !this.m_alertedAnim.IsPlaying() {
      this.m_pulsing = true;
      inkWidgetRef.SetVisible(this.m_pulseWidget, true);
      inkWidgetRef.SetOpacity(this.m_pulseWidget, 1.00);
      animOptions.loopType = inkanimLoopType.Cycle;
      animOptions.loopCounter = Cast(count);
      this.m_alertedAnim = this.PlayLibraryAnimation(n"Alerted", animOptions);
      this.m_alertedAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnPulsingAnimFinished");
    };
  }

  protected final func PulseContinuous(enabled: Bool) -> Void {
    let animOptions: inkAnimOptions;
    if IsDefined(this.m_alertedAnim) && this.m_alertedAnim.IsPlaying() {
      this.m_alertedAnim.Stop();
    };
    if enabled {
      this.m_pulsing = true;
      inkWidgetRef.SetVisible(this.m_pulseWidget, true);
      inkWidgetRef.SetOpacity(this.m_pulseWidget, 0.50);
      animOptions.loopType = inkanimLoopType.Cycle;
      animOptions.loopInfinite = true;
      this.m_alertedAnim = this.PlayLibraryAnimation(n"Alerted", animOptions);
    } else {
      this.m_pulsing = false;
      inkWidgetRef.SetVisible(this.m_pulseWidget, false);
    };
  }

  protected func ComputeRootState() -> CName {
    return this.m_attitudeState;
  }

  protected final func FadeOut() -> Void {
    let options: inkAnimOptions;
    if !IsDefined(this.m_fadeOutAnim) || !this.m_fadeOutAnim.IsPlaying() {
      this.m_lockLootQuality = true;
      options.executionDelay = 0.50;
      this.m_fadeOutAnim = this.PlayLibraryAnimation(n"FadeOut", options);
      this.m_fadeOutAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnFadeOutAnimFinished");
    };
  }

  protected final func GetStateForAttitude(attitude: EAIAttitude, canSeePlayer: Bool) -> CName {
    if !this.m_isAlive && this.m_highestLootQuality > 0u {
      switch this.m_highestLootQuality {
        case 0u:
          return n"Quality_Common";
        case 1u:
          return n"Quality_Uncommon";
        case 2u:
          return n"Quality_Rare";
        case 3u:
          return n"Quality_Epic";
        case 4u:
          return n"Quality_Legendary";
        case 5u:
          return n"Quality_Iconic";
        default:
          return n"Quality_Common";
      };
    } else {
      switch attitude {
        case EAIAttitude.AIA_Neutral:
        case EAIAttitude.AIA_Hostile:
          if this.m_isSquadInCombat {
            return n"Hostile";
          };
          if canSeePlayer {
            return n"Detecting";
          };
          if this.m_isAggressive {
            return n"Neutral_Aggressive";
          };
          return n"Neutral";
        case EAIAttitude.AIA_Friendly:
          return n"Friendly";
        default:
          return n"Civilian";
      };
    };
  }

  private final func PlayPreventionAnim() -> Void {
    let initialState: CName;
    this.StopPreventionAnim();
    this.m_preventionAnimProxy = MappinUIUtils.PlayPreventionBlinkAnimation(this.GetRootWidget(), initialState);
    if IsDefined(this.m_preventionAnimProxy) {
      this.m_preventionState = initialState;
      this.m_preventionAnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnPreventionAnimLoop");
    };
  }

  private final func StopPreventionAnim() -> Void {
    if IsDefined(this.m_preventionAnimProxy) {
      this.m_preventionAnimProxy.Stop();
      this.m_preventionAnimProxy = null;
    };
  }

  protected cb func OnPreventionAnimLoop(anim: ref<inkAnimProxy>) -> Bool {
    MappinUIUtils.CyclePreventionState(this.m_preventionState);
    this.UpdateRootState();
  }

  protected cb func OnPulsingAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_alertedAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnPulsingAnimFinished");
    inkWidgetRef.SetVisible(this.m_pulseWidget, false);
    this.m_pulsing = false;
    this.Update();
  }

  protected cb func OnFadeOutAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_fadeOutAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeOutAnimFinished");
    this.m_hasBeenLooted = true;
    this.Update();
    this.m_stealthMappin.UnregisterMappin();
  }
}

public native class MinimapQuestMappinController extends BaseMinimapMappinController {

  private let m_questMappin: wref<QuestMappin>;

  protected func ComputeRootState() -> CName {
    return n"Quest";
  }

  protected func Intro() -> Void {
    this.m_questMappin = this.GetMappin() as QuestMappin;
    this.Intro();
  }

  protected func Update() -> Void {
    let isPlayerInArea: Bool = this.m_questMappin.IsInsideTrigger();
    let shouldHide: Bool = !this.IsTracked() || isPlayerInArea;
    this.SetForceHide(shouldHide);
    this.Update();
  }
}

public native class MinimapQuestAreaMappinController extends BaseMinimapMappinController {

  protected native let areaShapeWidget: inkShapeRef;

  protected func ComputeRootState() -> CName {
    return n"Quest";
  }

  protected func Update() -> Void {
    let isPlayerInArea: Bool = MappinUIUtils.IsPlayerInArea(this.GetMappin());
    let shouldHide: Bool = !this.IsTracked() || !isPlayerInArea;
    this.SetForceHide(shouldHide);
    this.Update();
  }
}

public native class MinimapDeviceMappinController extends BaseMinimapMappinController {

  protected native let effectAreaWidget: inkCircleRef;

  protected final native func SetEffectAreaRadius(radius: Float) -> Void;

  protected func Update() -> Void {
    let gameplayRoleData: ref<GameplayRoleMappinData>;
    let iconID: TweakDBID;
    let isIconIDValid: Bool;
    let shouldShowEffectArea: Bool;
    let shouldShowMappin: Bool;
    let texturePart: CName;
    this.Update();
    gameplayRoleData = this.GetVisualData();
    if IsDefined(gameplayRoleData) && gameplayRoleData.m_showOnMiniMap {
      iconID = gameplayRoleData.m_textureID;
      isIconIDValid = TDBID.IsValid(iconID);
      if isIconIDValid {
        this.SetTexture(this.iconWidget, iconID);
      } else {
        texturePart = this.GetTexturePartForDeviceEffect(gameplayRoleData.m_gameplayRole);
        inkImageRef.SetTexturePart(this.iconWidget, texturePart);
        isIconIDValid = NotEquals(texturePart, n"");
      };
      shouldShowMappin = isIconIDValid;
    } else {
      shouldShowMappin = false;
    };
    shouldShowEffectArea = shouldShowMappin && (gameplayRoleData.m_isCurrentTarget || gameplayRoleData.m_isTagged);
    this.SetEffectAreaRadius(shouldShowEffectArea ? gameplayRoleData.m_range : 0.00);
    this.SetForceHide(!shouldShowMappin);
  }

  private func ComputeRootState() -> CName {
    let quality: gamedataQuality;
    let returnValue: CName;
    let visualState: EMappinVisualState;
    let gameplayRoleData: ref<GameplayRoleMappinData> = this.GetVisualData();
    if IsDefined(gameplayRoleData) {
      visualState = gameplayRoleData.m_mappinVisualState;
      quality = gameplayRoleData.m_quality;
      if gameplayRoleData.m_isQuest {
        returnValue = n"Quest";
      } else {
        if Equals(gameplayRoleData.m_gameplayRole, EGameplayRole.ExplodeLethal) {
          returnValue = n"Explosion";
        } else {
          if NotEquals(quality, gamedataQuality.Invalid) && NotEquals(quality, gamedataQuality.Random) {
            switch quality {
              case gamedataQuality.Common:
                returnValue = n"Common";
                break;
              case gamedataQuality.Epic:
                returnValue = n"Epic";
                break;
              case gamedataQuality.Legendary:
                returnValue = n"Legendary";
                break;
              case gamedataQuality.Rare:
                returnValue = n"Rare";
                break;
              case gamedataQuality.Uncommon:
                returnValue = n"Uncommon";
                break;
              default:
                returnValue = n"Default";
            };
          } else {
            switch visualState {
              case EMappinVisualState.Inactive:
                returnValue = n"Inactive";
                break;
              case EMappinVisualState.Available:
                returnValue = n"Available";
                break;
              case EMappinVisualState.Unavailable:
                returnValue = n"Unavailable";
                break;
              case EMappinVisualState.Default:
                returnValue = n"Default";
            };
          };
        };
      };
    };
    return returnValue;
  }

  public const func GetVisualData() -> ref<GameplayRoleMappinData> {
    return IsDefined(this.m_mappin) ? this.m_mappin.GetScriptData() : null as GameplayRoleMappinData;
  }

  private final func GetTexturePartForDeviceEffect(gameplayRole: EGameplayRole) -> CName {
    switch gameplayRole {
      case EGameplayRole.Alarm:
        return n"trigger_alarm1";
      case EGameplayRole.ControlNetwork:
        return n"control_network_device1";
      case EGameplayRole.ControlOtherDevice:
        return n"control_network_device2";
      case EGameplayRole.ControlSelf:
        return n"control_network_device3";
      case EGameplayRole.CutPower:
        return n"cut_power1";
      case EGameplayRole.Distract:
        return n"distract_enemy3";
      case EGameplayRole.DropPoint:
        return n"drop_point1";
      case EGameplayRole.ExplodeLethal:
        return n"explosive_lethal1";
      case EGameplayRole.ExplodeNoneLethal:
        return n"explosive_non-lethal1";
      case EGameplayRole.Fall:
        return n"fall2";
      case EGameplayRole.GrantInformation:
        return n"grants_information1";
      case EGameplayRole.Clue:
        return n"clue";
      case EGameplayRole.HideBody:
        return n"dispose_body1";
      case EGameplayRole.Loot:
        return n"loot1";
      case EGameplayRole.OpenPath:
        return n"open_path1";
      case EGameplayRole.ClearPath:
        return n"movable1";
      case EGameplayRole.ServicePoint:
        return n"use_servicepoint1";
      case EGameplayRole.Shoot:
        return n"shoots2";
      case EGameplayRole.SpreadGas:
        return n"gas_spread1";
      case EGameplayRole.StoreItems:
        return n"storage1";
      case EGameplayRole.GenericRole:
        return n"";
    };
    return n"";
  }
}

public native class MinimapSecurityAreaMappinController extends BaseMinimapMappinController {

  protected native let areaShapeWidget: inkShapeRef;

  protected native let area: ref<IArea>;

  protected native const let playerInArea: Bool;

  protected func Update() -> Void {
    let shouldShowMappin: Bool;
    let typeState: CName;
    if this.area == null {
      return;
    };
    typeState = this.AreaTypeToState(this.area.GetType());
    shouldShowMappin = NotEquals(typeState, n"");
    this.SetForceHide(!shouldShowMappin);
    if shouldShowMappin {
      inkWidgetRef.SetState(this.areaShapeWidget, typeState);
    };
  }

  protected cb func OnPlayerEnterArea() -> Bool {
    this.PlayLibraryAnimation(n"FadeOut");
  }

  protected cb func OnPlayerExitArea() -> Bool {
    this.PlayLibraryAnimation(n"FadeIn");
  }

  private final func AreaTypeToState(type: CName) -> CName {
    if Equals(type, n"SAFE") {
      return n"Safe";
    };
    if Equals(type, n"RESTRICTED") {
      return n"Restricted";
    };
    if Equals(type, n"DANGEROUS") {
      return n"Dangerous";
    };
    return n"";
  }
}

public native class MinimapRemotePlayerMappinController extends BaseMinimapMappinController {

  protected native let dataWidget: inkWidgetRef;

  protected native let shapeWidget: inkWidgetRef;

  protected let m_playerMappin: wref<RemotePlayerMappin>;

  protected cb func OnInitialize() -> Bool {
    this.Initialize();
  }

  protected cb func OnUpdate() -> Bool {
    this.Update();
  }

  protected func Intro() -> Void {
    this.m_playerMappin = this.GetMappin() as RemotePlayerMappin;
    this.Intro();
  }

  protected func Update() -> Void {
    let inAreaStr: String;
    let isAliveStr: String;
    let newStateName: CName;
    this.Update();
    if inkWidgetRef.IsValid(this.shapeWidget) {
      if this.m_playerMappin.vitals == EnumInt(gamePSMVitals.Alive) {
        isAliveStr = "Alive";
      } else {
        isAliveStr = "Dead";
      };
      if !this.IsClamped() {
        inAreaStr = "";
      } else {
        inAreaStr = "OutsideArea";
      };
      newStateName = StringToName(isAliveStr + inAreaStr);
      if NotEquals(inkWidgetRef.GetState(this.shapeWidget), newStateName) {
        inkWidgetRef.SetState(this.shapeWidget, newStateName);
      };
    };
    if inkWidgetRef.IsValid(this.dataWidget) {
      inkWidgetRef.SetVisible(this.dataWidget, this.m_playerMappin.hasMissionData);
    };
  }
}

public native class MinimapPingSystemMappinController extends BaseMinimapMappinController {

  protected func Intro() -> Void {
    let stateName: String;
    let pingMappin: wref<PingSystemMappin> = this.GetMappin() as PingSystemMappin;
    let pingType: gamedataPingType = pingMappin.pingType;
    let pingString: String = EnumValueToString("gamedataPingType", Cast(EnumInt(pingType)));
    let pingTDBID: TweakDBID = TDBID.Create("PingTypes." + pingString);
    let pingRecord: ref<Ping_Record> = TweakDBInterface.GetPingRecord(pingTDBID);
    inkImageRef.SetTexturePart(this.iconWidget, pingRecord.MinimapIconName());
    stateName = pingMappin.ResolveIconState();
    inkWidgetRef.SetState(this.iconWidget, StringToName(stateName));
    this.Intro();
  }
}

public class MinimapPOIMappinController extends BaseMinimapMappinController {

  private edit let m_pulseWidget: inkWidgetRef;

  private edit let m_pingAnimationOnStateChange: Bool;

  private let m_poiMappin: wref<PointOfInterestMappin>;

  @default(MinimapPOIMappinController, false)
  private let m_isCompletedPhase: Bool;

  private let m_mappinPhase: gamedataMappinPhase;

  private let m_pingAnim: ref<inkAnimProxy>;

  @default(MinimapPOIMappinController, 3)
  private const let c_pingAnimCount: Uint32;

  private let m_vehicleMinimapMappinComponent: ref<VehicleMinimapMappinComponent>;

  @default(MinimapPOIMappinController, false)
  private let m_keepIconOnClamping: Bool;

  protected func Initialize() -> Void {
    this.Initialize();
    inkWidgetRef.SetVisible(this.m_pulseWidget, false);
  }

  protected func Intro() -> Void {
    let vehicleMappin: wref<VehicleMappin> = this.GetMappin() as VehicleMappin;
    if IsDefined(vehicleMappin) {
      this.m_keepIconOnClamping = true;
      this.m_vehicleMinimapMappinComponent = new VehicleMinimapMappinComponent();
      this.m_vehicleMinimapMappinComponent.OnInitialize(this, vehicleMappin);
    };
    this.m_poiMappin = this.GetMappin() as PointOfInterestMappin;
    this.UpdateIcon();
    this.Intro();
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_vehicleMinimapMappinComponent) {
      this.m_vehicleMinimapMappinComponent.OnUninitialize();
    };
  }

  protected func Update() -> Void {
    let newMappinPhase: gamedataMappinPhase = this.m_mappin.GetPhase();
    if NotEquals(this.m_mappinPhase, newMappinPhase) {
      this.m_mappinPhase = newMappinPhase;
      if Equals(this.m_mappinPhase, gamedataMappinPhase.DiscoveredPhase) && this.m_pingAnimationOnStateChange {
        this.PlayPingAnimation();
      };
    };
    this.UpdateVisibility();
    this.UpdateIcon();
    this.Update();
  }

  public final func PlayPingAnimation() -> Void {
    let animOptions: inkAnimOptions;
    if IsDefined(this.m_pingAnim) {
      this.m_pingAnim.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnPulseAnimLoop");
      this.m_pingAnim.Stop();
      this.m_pingAnim = null;
    };
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = false;
    animOptions.loopCounter = this.c_pingAnimCount;
    this.m_pingAnim = this.PlayLibraryAnimation(n"Pulse", animOptions);
    this.m_pingAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnPulseAnimLoop");
    inkWidgetRef.SetVisible(this.m_pulseWidget, true);
  }

  protected cb func OnQuestMappinHighlight(evt: ref<QuestMappinHighlightEvent>) -> Bool {
    let poiMappin: ref<PointOfInterestMappin> = this.m_mappin as PointOfInterestMappin;
    if IsDefined(poiMappin) && poiMappin.GetJournalQuestPathHash() == evt.m_hash {
      this.PlayPingAnimation();
    };
  }

  protected cb func OnPulseAnimLoop(anim: ref<inkAnimProxy>) -> Bool {
    inkWidgetRef.SetVisible(this.m_pulseWidget, false);
  }

  protected final func UpdateVisibility() -> Void {
    let isInArea: Bool;
    let shouldHide: Bool;
    this.m_isCompletedPhase = Equals(this.m_mappinPhase, gamedataMappinPhase.CompletedPhase);
    if this.m_poiMappin != null {
      isInArea = this.m_poiMappin.IsInsideSecurityAreaTrigger();
      if !this.IsPlayerTracked() {
        shouldHide = isInArea || this.m_poiMappin.IsQuestPath();
      };
      shouldHide = shouldHide || this.m_isCompletedPhase;
      this.SetForceHide(shouldHide);
    };
  }

  protected final func UpdateIcon() -> Void {
    let iconID: TweakDBID;
    let mappinVariant: gamedataMappinVariant;
    let roleMappinData: ref<GameplayRoleMappinData>;
    let texturePart: CName;
    if IsDefined(this.m_mappin) {
      roleMappinData = this.m_mappin.GetScriptData() as GameplayRoleMappinData;
      mappinVariant = this.m_mappin.GetVariant();
    };
    if IsDefined(roleMappinData) {
      iconID = roleMappinData.m_textureID;
    };
    if !TDBID.IsValid(iconID) {
      texturePart = MappinUIUtils.MappinToTexturePart(mappinVariant, this.m_mappinPhase);
      inkImageRef.SetTexturePart(this.iconWidget, texturePart);
    } else {
      this.SetTexture(this.iconWidget, iconID);
    };
    inkWidgetRef.SetOpacity(this.iconWidget, this.m_isCompletedPhase ? MappinUIUtils.GetGlobalProfile().CompletedPOIOpacity() : 1.00);
  }

  protected func ComputeRootState() -> CName {
    let filterGroup: wref<MappinUIFilterGroup_Record>;
    let stateName: CName;
    if this.m_isCompletedPhase {
      stateName = n"QuestComplete";
    } else {
      if this.m_mappin != null {
        if this.m_mappin.IsQuestMappin() {
          stateName = n"Quest";
        } else {
          filterGroup = MappinUIUtils.GetFilterGroup(this.m_mappin.GetVariant());
          if IsDefined(filterGroup) {
            stateName = filterGroup.WidgetState();
          };
        };
      };
    };
    return stateName;
  }

  protected func KeepIconOnClamping() -> Bool {
    return this.m_keepIconOnClamping;
  }
}

public native class MinimapDynamicEventMappinController extends BaseMinimapMappinController {

  private native let pulseWidget: inkWidgetRef;

  private native let pulseEnabled: Bool;

  private let m_pulseAnim: ref<inkAnimProxy>;

  private final func PlayPulseAnimation() -> Void {
    let animOptions: inkAnimOptions;
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = true;
    this.m_pulseAnim = this.PlayLibraryAnimation(n"Pulse", animOptions);
    if this.m_pulseAnim != null {
      this.m_pulseAnim.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnPulseAnimLoop");
    };
  }

  private final func StopPulseAnimation() -> Void {
    if this.m_pulseAnim != null {
      this.m_pulseAnim.Stop();
      this.m_pulseAnim = null;
    };
  }

  protected cb func OnPulseAnimLoop(anim: ref<inkAnimProxy>) -> Bool {
    if !this.pulseEnabled {
      this.StopPulseAnimation();
    };
  }

  protected cb func OnPulseEnabledChanged(enabled: Bool) -> Bool {
    if enabled {
      this.PlayPulseAnimation();
    };
  }
}

public class VehicleMinimapMappinComponent extends IScriptable {

  private let m_minimapPOIMappinController: wref<MinimapPOIMappinController>;

  @default(VehicleMinimapMappinComponent, false)
  private let m_vehicleIsLatestSummoned: Bool;

  private let m_vehicleEntityID: EntityID;

  private let m_vehicleSummonDataDef: ref<VehicleSummonDataDef>;

  private let m_vehicleSummonDataBB: wref<IBlackboard>;

  private let m_vehicleSummonStateCallback: ref<CallbackHandle>;

  public final func OnInitialize(minimapPOIMappinController: wref<MinimapPOIMappinController>, vehicleMappin: wref<VehicleMappin>) -> Void {
    this.m_minimapPOIMappinController = minimapPOIMappinController;
    let vehicle: wref<VehicleObject> = vehicleMappin.GetVehicle();
    this.m_vehicleEntityID = vehicle.GetEntityID();
    this.m_vehicleSummonDataDef = GetAllBlackboardDefs().VehicleSummonData;
    this.m_vehicleSummonDataBB = GameInstance.GetBlackboardSystem(vehicle.GetGame()).Get(this.m_vehicleSummonDataDef);
    this.m_vehicleSummonStateCallback = this.m_vehicleSummonDataBB.RegisterListenerUint(this.m_vehicleSummonDataDef.SummonState, this, n"OnVehicleSummonStateChanged");
  }

  public final func OnUninitialize() -> Void {
    this.m_vehicleSummonDataBB.UnregisterListenerUint(this.m_vehicleSummonDataDef.SummonState, this.m_vehicleSummonStateCallback);
  }

  private final func VehicleIsLatestSummoned() -> Bool {
    return this.m_vehicleEntityID == this.m_vehicleSummonDataBB.GetEntityID(this.m_vehicleSummonDataDef.SummonedVehicleEntityID);
  }

  protected cb func OnVehicleSummonStateChanged(value: Uint32) -> Bool {
    if this.VehicleIsLatestSummoned() && Equals(IntEnum(value), vehicleSummonState.AlreadySummoned) {
      this.m_minimapPOIMappinController.PlayPingAnimation();
    };
  }
}
