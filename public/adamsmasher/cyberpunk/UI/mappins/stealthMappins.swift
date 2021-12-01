
public class StealthMappinGameController extends inkGameController {

  private let m_controller: wref<StealthMappinController>;

  private let m_ownerNPC: wref<NPCPuppet>;

  protected cb func OnInitialize() -> Bool {
    this.m_controller = this.GetRootWidget().GetController() as StealthMappinController;
    let ownerObject: wref<GameObject> = this.GetOwnerEntity() as GameObject;
    let gameInstance: GameInstance = ownerObject.GetGame();
    this.m_ownerNPC = GameInstance.FindEntityByID(gameInstance, this.m_controller.GetMappin().GetEntityID()) as NPCPuppet;
    this.m_controller.SetGameInstance(gameInstance);
  }
}

public native class StealthMappinController extends BaseInteractionMappinController {

  private edit let m_animImage: inkImageRef;

  private edit let m_arrow: inkImageRef;

  private edit let m_fill: inkWidgetRef;

  private edit let m_eyeFillWhite: inkWidgetRef;

  private edit let m_eyeFillBlack: inkWidgetRef;

  private edit let m_markExclamation: inkTextRef;

  private edit let m_distance: inkTextRef;

  private edit let m_mainArt: inkWidgetRef;

  private edit let m_frame: inkImageRef;

  private edit let m_eliteFrameName: CName;

  private edit let m_eliteFrameSize: Vector2;

  private edit let m_objectMarker: inkWidgetRef;

  private edit let m_levelIcon: inkImageRef;

  private edit let m_statusEffectHolder: inkWidgetRef;

  private edit let m_statusEffectIcon: inkImageRef;

  private edit let m_statusEffectTimer: inkTextRef;

  private edit let m_taggedContainer: inkWidgetRef;

  private let m_ownerObject: wref<GameObject>;

  private let m_ownerNPC: wref<NPCPuppet>;

  private let m_ownerDevice: wref<Device>;

  private let m_mappin: wref<StealthMappin>;

  private let m_root: wref<inkWidget>;

  private let m_canvas: wref<inkWidget>;

  private let m_nameplateController: wref<NpcNameplateGameController>;

  private let m_isFriendly: Bool;

  private let m_isFriendlyFromHack: Bool;

  private let m_isHostile: Bool;

  private let m_isAggressive: Bool;

  private let m_isDevice: Bool;

  private let m_isDrone: Bool;

  private let m_isMech: Bool;

  private let m_isCamera: Bool;

  private let m_isTurret: Bool;

  private let m_isHiddenByQuest: Bool;

  private let m_NPCRarity: gamedataNPCRarity;

  private let m_puppetStateBlackboard: wref<IBlackboard>;

  private let m_highLevelState: gamedataNPCHighLevelState;

  private let m_numberOfCombatants: Int32;

  private let m_waitingToExitCombat: Bool;

  private let m_reaction: gamedataOutput;

  private let m_lastState: gamedataNPCHighLevelState;

  private let m_lastReaction: gamedataOutput;

  private let m_lastPercent: Float;

  private let m_canSeePlayer: Bool;

  private let m_squadInCombat: Bool;

  private let m_archetypeTextureName: CName;

  private let m_isTagged: Bool;

  private let m_canHaveObjectMarker: Bool;

  private let m_canShowObjectMarker: Bool;

  private let m_objectMarkerVisible: Bool;

  private let m_nameplateVisible: Bool;

  private let m_detectionVisible: Bool;

  private let m_inNameplateMode: Bool;

  @default(StealthMappinController, true)
  private let m_objectMarkerFirstShowing: Bool;

  private let m_statusEffectShowing: Bool;

  private let m_statusEffectCurrentPriority: Float;

  private let m_animationIsPlaying: Bool;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_nameplateAnimationProxy: ref<inkAnimProxy>;

  private let m_nameplateAnimationIsPlaying: Bool;

  private let m_reprimandAnimationProxy: ref<inkAnimProxy>;

  private let m_reprimandAnimationIsPlaying: Bool;

  @default(StealthMappinController, gameReprimandMappinAnimationState.None)
  private let m_reprimandAnimationState: gameReprimandMappinAnimationState;

  @default(StealthMappinController, gameEnemyStealthAwarenessState.Relaxed)
  private let m_currentAnimState: gameEnemyStealthAwarenessState;

  @default(StealthMappinController, 0.0f)
  private const let c_emptyThreshold: Float;

  @default(StealthMappinController, 1.0f)
  private const let c_awareToCombatThreshold: Float;

  @default(StealthMappinController, 99.9f)
  private const let c_combatToAwareThreshold: Float;

  @default(StealthMappinController, 35.0f)
  private const let c_deviceCombatToAwareThreshold: Float;

  @default(StealthMappinController, 50.0f)
  private const let c_objectMarkerMaxDistance: Float;

  @default(StealthMappinController, 30.0f)
  private const let c_objectMarkerMaxCameraDistance: Float;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.m_canvas = this.GetWidget(n"Canvas");
    inkWidgetRef.SetOpacity(this.m_markExclamation, 0.00);
    this.m_canShowObjectMarker = false;
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_puppetStateBlackboard = null;
  }

  protected cb func OnIntro() -> Bool {
    this.m_mappin = this.GetMappin() as StealthMappin;
    this.OnUpdate();
  }

  public final func SetGameInstance(gameInstance: GameInstance) -> Void {
    let blackboard: ref<IBlackboard>;
    let npcType: gamedataNPCType;
    this.m_mappin = this.GetMappin() as StealthMappin;
    this.m_mappin.EnableVisibilityThroughWalls(true);
    this.OverrideClamp(true);
    if GameInstance.IsValid(gameInstance) {
      this.m_ownerObject = GameInstance.FindEntityByID(gameInstance, this.m_mappin.GetEntityID()) as GameObject;
      this.m_ownerNPC = this.m_ownerObject as NPCPuppet;
      if IsDefined(this.m_ownerNPC) {
        npcType = this.m_ownerNPC.GetNPCType();
        if Equals(npcType, gamedataNPCType.Drone) {
          this.m_isDrone = true;
        } else {
          if Equals(npcType, gamedataNPCType.Mech) {
            this.m_isMech = true;
          };
        };
      } else {
        this.m_ownerDevice = this.m_ownerObject as Device;
      };
      this.m_isDevice = this.m_ownerObject.IsDevice();
      this.m_isCamera = this.m_isDevice && this.m_ownerObject.IsSensor() && !this.m_ownerObject.IsTurret();
      this.m_isTurret = this.m_ownerObject.IsTurret();
      this.m_NPCRarity = this.m_mappin.GetRarity();
      this.m_mappin.UpdateObjectMarkerThreshold(this.m_isCamera ? this.c_objectMarkerMaxCameraDistance : this.c_objectMarkerMaxDistance);
      this.m_mappin.UpdateCombatToAwareThreshold(this.m_isDevice ? this.c_deviceCombatToAwareThreshold : this.c_combatToAwareThreshold);
      this.UpdateArchetypeTexture();
      if IsDefined(this.m_ownerNPC) {
        blackboard = GameInstance.GetBlackboardSystem(this.m_ownerNPC.GetGame()).Get(GetAllBlackboardDefs().UI_Stealth);
        this.m_puppetStateBlackboard = this.m_ownerNPC.GetPuppetStateBlackboard();
        this.m_highLevelState = IntEnum(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
        this.m_reaction = IntEnum(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.ReactionBehavior));
        this.m_numberOfCombatants = Cast(blackboard.GetUint(GetAllBlackboardDefs().UI_Stealth.numberOfCombatants));
        this.OnUpdate();
      };
    };
  }

  protected cb func OnUpdate() -> Bool {
    let distance: Float;
    let percent: Float;
    let shouldShow: Bool;
    let attitude: EAIAttitude = this.m_mappin.GetAttitudeTowardsPlayer();
    this.m_isFriendly = Equals(attitude, EAIAttitude.AIA_Friendly);
    this.m_isFriendlyFromHack = this.m_mappin.IsFriendlyFromHack();
    this.m_isHostile = Equals(attitude, EAIAttitude.AIA_Hostile);
    this.m_isAggressive = this.m_mappin.IsAggressive();
    this.m_isHiddenByQuest = this.m_mappin.IsHiddenByQuestIn3D();
    if this.ShouldDisableMappin() {
      inkWidgetRef.SetVisible(this.m_mainArt, false);
      inkWidgetRef.SetVisible(this.m_arrow, false);
      if this.m_isFriendlyFromHack && ScriptedPuppet.IsActive(this.m_ownerObject) {
        this.UpdateObjectMarkerAndTagging();
        this.m_root.SetState(n"Friendly");
        this.m_mappin.SetVisibleIn3D(this.m_objectMarkerVisible);
        this.SetRootVisible(this.m_objectMarkerVisible);
      } else {
        this.UpdateObjectMarkerVisibility(false, false);
        this.m_mappin.SetVisibleIn3D(false);
        this.SetRootVisible(false);
      };
      return true;
    };
    percent = this.m_mappin.GetDetectionProgress();
    this.m_canSeePlayer = this.m_mappin.CanSeePlayer();
    this.m_squadInCombat = this.m_mappin.IsSquadInCombat();
    this.m_numberOfCombatants = Cast(this.m_mappin.GetNumberOfCombatants());
    if IsDefined(this.m_ownerNPC) {
      this.UpdateNPCDetection(percent);
    } else {
      this.UpdateDeviceDetection(percent);
    };
    if !this.m_canSeePlayer && NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) && this.m_numberOfCombatants >= 1 {
      this.m_detectionVisible = false;
    } else {
      this.m_detectionVisible = NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) && NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) || this.m_animationIsPlaying;
    };
    this.OverrideClamp(this.m_detectionVisible);
    this.UpdateNameplatePart();
    this.UpdateStatusEffectIcon();
    this.UpdateCanvasOpacity();
    shouldShow = (this.m_detectionVisible || this.m_inNameplateMode || this.m_nameplateAnimationIsPlaying) && !this.m_isHiddenByQuest;
    inkWidgetRef.SetVisible(this.m_mainArt, shouldShow);
    this.UpdateObjectMarkerAndTagging();
    this.UpdateDetectionMeter(percent);
    inkWidgetRef.SetVisible(this.m_arrow, this.isCurrentlyClamped && shouldShow);
    if this.ShouldShowDistance() {
      distance = this.GetDistanceToPlayer();
      inkTextRef.SetText(this.m_distance, UnitsLocalizationHelper.LocalizeDistance(distance));
      inkWidgetRef.SetVisible(this.m_distance, distance >= 10.00);
    };
    this.m_mappin.SetStealthAwarenessState(this.m_currentAnimState);
    this.m_mappin.SetVisibleIn3D(shouldShow || this.m_objectMarkerVisible);
    this.SetRootVisible(shouldShow || this.m_objectMarkerVisible);
    this.SetIgnorePriority(!this.m_detectionVisible);
    this.m_lastPercent = percent;
  }

  private final func NotifyDroneAboutStartingDetection() -> Void {
    let startingToDetectEvent: ref<NPCStartingDetectionEvent> = new NPCStartingDetectionEvent();
    this.m_ownerNPC.QueueEvent(startingToDetectEvent);
  }

  private final func NotifyDroneAboutStoppingDetection() -> Void {
    let startingToDetectEvent: ref<NPCStoppingDetectionEvent> = new NPCStoppingDetectionEvent();
    this.m_ownerNPC.QueueEvent(startingToDetectEvent);
  }

  private final func ShouldDisableMappin() -> Bool {
    if !IsDefined(this.m_ownerObject) {
      return true;
    };
    if this.m_isFriendly {
      return true;
    };
    if !IsDefined(this.m_ownerNPC) {
      return false;
    };
    if ScriptedPuppet.IsDefeated(this.m_ownerNPC) || this.m_ownerNPC.IsAboutToBeDefeated() || this.m_ownerNPC.IsDead() || this.m_ownerNPC.IsAboutToDie() {
      return true;
    };
    return false;
  }

  private final func UpdateNameplatePart() -> Void {
    if !this.m_detectionVisible {
      if this.m_nameplateVisible {
        if !this.m_inNameplateMode {
          this.m_inNameplateMode = true;
          this.UpdateNameplateIcon();
          this.PlayNameplateAnim(n"nameplate_intro", n"OnNameplateAnimFinished");
        };
      } else {
        if this.m_inNameplateMode {
          this.m_inNameplateMode = false;
          this.PlayNameplateAnim(n"nameplate_outro", n"OnNameplateAnimFinished");
        };
      };
    };
  }

  private final func UpdateNameplateIcon() -> Void {
    let enemyDifficulty: EPowerDifferential;
    if this.m_isTurret {
      inkWidgetRef.SetState(this.m_levelIcon, n"ThreatMedium");
      inkImageRef.SetTexturePart(this.m_levelIcon, this.m_archetypeTextureName);
    } else {
      enemyDifficulty = RPGManager.CalculatePowerDifferential(this.m_ownerObject);
      switch enemyDifficulty {
        case EPowerDifferential.TRASH:
          inkWidgetRef.SetState(this.m_levelIcon, n"ThreatVeryLow");
          inkImageRef.SetTexturePart(this.m_levelIcon, this.m_archetypeTextureName);
          break;
        case EPowerDifferential.EASY:
          inkWidgetRef.SetState(this.m_levelIcon, n"ThreatLow");
          inkImageRef.SetTexturePart(this.m_levelIcon, this.m_archetypeTextureName);
          break;
        case EPowerDifferential.NORMAL:
          inkWidgetRef.SetState(this.m_levelIcon, n"ThreatMedium");
          inkImageRef.SetTexturePart(this.m_levelIcon, this.m_archetypeTextureName);
          break;
        case EPowerDifferential.HARD:
          inkWidgetRef.SetState(this.m_levelIcon, n"ThreatHigh");
          inkImageRef.SetTexturePart(this.m_levelIcon, this.m_archetypeTextureName);
          break;
        case EPowerDifferential.IMPOSSIBLE:
          inkWidgetRef.SetState(this.m_levelIcon, n"ThreatVeryHigh");
          inkImageRef.SetTexturePart(this.m_levelIcon, n"threat_level_4");
          break;
        default:
          inkWidgetRef.SetState(this.m_levelIcon, n"ThreatMedium");
      };
      inkImageRef.SetTexturePart(this.m_levelIcon, this.m_archetypeTextureName);
    };
  }

  private final func UpdateArchetypeTexture() -> Void {
    let archetype: gamedataArchetypeType;
    if !this.m_isDevice && (Equals(this.m_NPCRarity, gamedataNPCRarity.Elite) || Equals(this.m_NPCRarity, gamedataNPCRarity.Boss)) && NotEquals(this.m_eliteFrameName, n"") {
      inkImageRef.SetTexturePart(this.m_frame, this.m_eliteFrameName);
      inkWidgetRef.SetSize(this.m_frame, this.m_eliteFrameSize);
    };
    if this.m_isDrone {
      if Equals(this.m_NPCRarity, gamedataNPCRarity.Elite) || Equals(this.m_NPCRarity, gamedataNPCRarity.Boss) {
        this.m_archetypeTextureName = n"archetype_heavy_drone";
      } else {
        this.m_archetypeTextureName = n"archetype_drone";
      };
    } else {
      if this.m_isMech {
        this.m_archetypeTextureName = n"archetype_mech";
      } else {
        if this.m_isTurret {
          this.m_archetypeTextureName = n"archetype_ranged";
        } else {
          archetype = this.m_mappin.GetArchetype();
          switch archetype {
            case gamedataArchetypeType.FastMeleeT3:
            case gamedataArchetypeType.FastMeleeT2:
            case gamedataArchetypeType.HeavyMeleeT3:
            case gamedataArchetypeType.HeavyMeleeT2:
            case gamedataArchetypeType.GenericMeleeT2:
            case gamedataArchetypeType.GenericMeleeT1:
            case gamedataArchetypeType.AndroidMeleeT2:
            case gamedataArchetypeType.AndroidMeleeT1:
              this.m_archetypeTextureName = n"archetype_melee";
              break;
            case gamedataArchetypeType.FastRangedT3:
            case gamedataArchetypeType.FastRangedT2:
            case gamedataArchetypeType.GenericRangedT3:
            case gamedataArchetypeType.GenericRangedT2:
            case gamedataArchetypeType.GenericRangedT1:
            case gamedataArchetypeType.FriendlyGenericRangedT3:
            case gamedataArchetypeType.AndroidRangedT2:
              this.m_archetypeTextureName = n"archetype_ranged";
              break;
            case gamedataArchetypeType.FastShotgunnerT3:
            case gamedataArchetypeType.FastShotgunnerT2:
            case gamedataArchetypeType.ShotgunnerT3:
            case gamedataArchetypeType.ShotgunnerT2:
              this.m_archetypeTextureName = n"archetype_shotgun";
              break;
            case gamedataArchetypeType.FastSniperT3:
            case gamedataArchetypeType.SniperT2:
              this.m_archetypeTextureName = n"archetype_sniper";
              break;
            case gamedataArchetypeType.HeavyRangedT3:
            case gamedataArchetypeType.HeavyRangedT2:
              this.m_archetypeTextureName = n"archetype_heavy";
              break;
            case gamedataArchetypeType.TechieT3:
            case gamedataArchetypeType.TechieT2:
            case gamedataArchetypeType.NetrunnerT3:
            case gamedataArchetypeType.NetrunnerT2:
            case gamedataArchetypeType.NetrunnerT1:
              this.m_archetypeTextureName = n"archetype_netrunner";
              break;
            default:
              if Equals(this.m_NPCRarity, gamedataNPCRarity.Boss) {
                this.m_archetypeTextureName = n"threat_level_4";
              } else {
                this.m_archetypeTextureName = n"enemy_npc";
              };
          };
        };
      };
    };
  }

  private final func UpdateStatusEffectIcon() -> Void {
    let statusEffectTime: Float;
    let textureName: String;
    this.m_statusEffectCurrentPriority = this.m_mappin.GetStatusEffectCurrentPriority();
    if this.m_statusEffectCurrentPriority == 0.00 {
      this.ShowStatusEffect(false);
      return;
    };
    statusEffectTime = this.m_mappin.GetStatusEffectTimeRemaining();
    if statusEffectTime == 0.00 {
      this.ShowStatusEffect(false);
      return;
    };
    textureName = this.m_mappin.GetStatusEffectIconPath();
    if Equals(textureName, "") {
      this.ShowStatusEffect(false);
      return;
    };
    inkImageRef.SetTexturePart(this.m_statusEffectIcon, StringToName(textureName));
    if statusEffectTime > 0.00 {
      inkTextRef.SetText(this.m_statusEffectTimer, FloatToStringPrec(statusEffectTime, 1));
      inkWidgetRef.SetVisible(this.m_statusEffectTimer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_statusEffectTimer, false);
    };
    this.ShowStatusEffect(true);
  }

  private final func ShowStatusEffect(show: Bool) -> Void {
    if show {
      if this.m_statusEffectShowing && this.m_detectionVisible && this.m_statusEffectCurrentPriority < 0.00 {
        inkWidgetRef.SetVisible(this.m_levelIcon, true);
        inkWidgetRef.SetVisible(this.m_eyeFillWhite, true);
        inkWidgetRef.SetVisible(this.m_eyeFillBlack, true);
        inkWidgetRef.SetVisible(this.m_markExclamation, true);
        inkWidgetRef.SetVisible(this.m_statusEffectHolder, false);
        this.m_statusEffectShowing = false;
      } else {
        if !this.m_statusEffectShowing && (this.m_statusEffectCurrentPriority > 0.00 || !this.m_detectionVisible) {
          inkWidgetRef.SetVisible(this.m_levelIcon, false);
          inkWidgetRef.SetVisible(this.m_eyeFillWhite, false);
          inkWidgetRef.SetVisible(this.m_eyeFillBlack, false);
          inkWidgetRef.SetVisible(this.m_markExclamation, false);
          inkWidgetRef.SetVisible(this.m_statusEffectHolder, true);
          this.m_statusEffectShowing = true;
        };
      };
    } else {
      if !show && this.m_statusEffectShowing {
        inkWidgetRef.SetVisible(this.m_levelIcon, true);
        inkWidgetRef.SetVisible(this.m_eyeFillWhite, true);
        inkWidgetRef.SetVisible(this.m_eyeFillBlack, true);
        inkWidgetRef.SetVisible(this.m_markExclamation, true);
        inkWidgetRef.SetVisible(this.m_statusEffectHolder, false);
        this.m_statusEffectShowing = false;
      };
    };
  }

  private final func UpdateObjectMarkerAndTagging() -> Void {
    let canShowObjectMarker: Bool;
    let isTagged: Bool;
    let objectMarkerVisible: Bool;
    let distance: Float = this.GetDistanceToPlayer();
    let objectMarkersEnabled: Bool = this.m_mappin.GetObjectMarkersEnabled();
    let canHaveObjectMarker: Bool = (this.m_isHostile || this.m_isAggressive || this.m_isFriendlyFromHack || this.m_isDevice) && !this.m_isHiddenByQuest;
    let playerAwareOfObject: Bool = this.m_mappin.HasBeenSeen() || NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) || this.m_nameplateVisible || !this.m_objectMarkerFirstShowing;
    if this.m_isCamera {
      canShowObjectMarker = canHaveObjectMarker && playerAwareOfObject && distance <= this.c_objectMarkerMaxCameraDistance && this.m_numberOfCombatants == 0;
    } else {
      canShowObjectMarker = canHaveObjectMarker && playerAwareOfObject && distance <= this.c_objectMarkerMaxDistance;
    };
    if canShowObjectMarker && this.m_isDevice && IsDefined(this.m_ownerDevice) {
      canShowObjectMarker = this.m_ownerDevice.GetDevicePS().IsON();
    };
    isTagged = this.m_mappin.IsTagged();
    if NotEquals(this.m_canShowObjectMarker, canShowObjectMarker) || NotEquals(this.m_isTagged, isTagged) {
      this.m_canShowObjectMarker = canShowObjectMarker;
      this.m_isTagged = isTagged;
      this.m_mappin.EnableVisibilityThroughWalls(!this.m_canShowObjectMarker || this.m_isTagged);
    };
    objectMarkerVisible = !this.isCurrentlyClamped && (canHaveObjectMarker && isTagged || canShowObjectMarker && (this.m_mappin.IsVisible() && objectMarkersEnabled || this.m_nameplateVisible));
    this.UpdateObjectMarkerVisibility(canHaveObjectMarker, objectMarkerVisible);
    if this.m_objectMarkerFirstShowing && this.m_objectMarkerVisible && objectMarkersEnabled {
      this.PlayLibraryAnimation(n"intro");
      this.m_objectMarkerFirstShowing = false;
    };
    inkWidgetRef.SetVisible(this.m_taggedContainer, isTagged);
  }

  private final func UpdateObjectMarkerVisibility(canHaveObjectMarker: Bool, objectMarkerVisible: Bool) -> Void {
    let objectMarkerVisibilityUpdateNeeded: Bool = false;
    if NotEquals(this.m_canHaveObjectMarker, canHaveObjectMarker) {
      this.m_canHaveObjectMarker = canHaveObjectMarker;
      objectMarkerVisibilityUpdateNeeded = true;
    };
    if NotEquals(this.m_objectMarkerVisible, objectMarkerVisible) {
      this.m_objectMarkerVisible = objectMarkerVisible;
      inkWidgetRef.SetVisible(this.m_objectMarker, this.m_objectMarkerVisible);
      objectMarkerVisibilityUpdateNeeded = true;
    };
    if objectMarkerVisibilityUpdateNeeded {
      this.m_mappin.UpdateObjectMarkerVisibility(this.m_canHaveObjectMarker, this.m_objectMarkerVisible);
    };
  }

  private final func UpdateDetectionMeter(percent: Float) -> Void {
    if this.m_inNameplateMode || this.m_nameplateAnimationIsPlaying {
      inkWidgetRef.SetScale(this.m_fill, new Vector2(1.00, 0.00));
      inkWidgetRef.SetScale(this.m_eyeFillBlack, new Vector2(1.00, 0.00));
      inkWidgetRef.SetScale(this.m_eyeFillWhite, new Vector2(1.00, 1.00));
    } else {
      if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) || Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Alerted) {
        inkWidgetRef.SetScale(this.m_fill, new Vector2(1.00, 1.00));
        inkWidgetRef.SetScale(this.m_eyeFillBlack, new Vector2(1.00, 1.00));
        inkWidgetRef.SetScale(this.m_eyeFillWhite, new Vector2(1.00, 0.00));
      } else {
        inkWidgetRef.SetScale(this.m_fill, new Vector2(1.00, percent * 0.01));
        inkWidgetRef.SetScale(this.m_eyeFillBlack, new Vector2(1.00, percent * 0.01));
        inkWidgetRef.SetScale(this.m_eyeFillWhite, new Vector2(1.00, 1.00 - percent * 0.01));
      };
    };
  }

  private final func UpdateDeviceDetection(percent: Float) -> Void {
    if !this.m_animationIsPlaying {
      if this.m_isCamera && this.m_numberOfCombatants >= 1 {
        if NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
          if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Aware) {
            if this.m_nameplateVisible {
              this.PlayAnim(n"aware_to_nameplate", n"OnBasicAnimFinished");
              this.m_inNameplateMode = true;
              this.UpdateNameplateIcon();
            } else {
              this.PlayAnim(n"aware_to_relaxed", n"OnBasicAnimFinished");
            };
          };
          this.m_currentAnimState = gameEnemyStealthAwarenessState.Relaxed;
        };
      } else {
        if percent == 100.00 && NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) {
          if this.m_inNameplateMode {
            this.PlayAnim(n"nameplate_to_alert", n"OnPotentialCombatAnimFinished");
            this.m_inNameplateMode = false;
          } else {
            if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
              this.PlayAnim(n"relaxed_to_alert", n"OnPotentialCombatAnimFinished");
            } else {
              this.PlayAnim(n"aware_to_alert", n"OnPotentialCombatAnimFinished");
            };
          };
          this.m_currentAnimState = gameEnemyStealthAwarenessState.Combat;
        } else {
          if percent < this.c_deviceCombatToAwareThreshold && Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) {
            this.PlayAnim(n"alert_to_aware", n"OnBasicAnimFinished");
            this.m_currentAnimState = gameEnemyStealthAwarenessState.Aware;
          } else {
            if percent > this.c_emptyThreshold && Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
              if this.m_inNameplateMode {
                this.PlayAnim(n"nameplate_to_aware", n"OnBasicAnimFinished");
                this.m_inNameplateMode = false;
              } else {
                this.PlayAnim(n"relaxed_to_aware", n"OnBasicAnimFinished");
              };
              this.m_currentAnimState = gameEnemyStealthAwarenessState.Aware;
            } else {
              if percent <= this.c_emptyThreshold && NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
                if this.m_nameplateVisible {
                  this.PlayAnim(n"aware_to_nameplate", n"OnBasicAnimFinished");
                  this.m_inNameplateMode = true;
                  this.UpdateNameplateIcon();
                } else {
                  this.PlayAnim(n"aware_to_relaxed", n"OnBasicAnimFinished");
                };
                this.m_currentAnimState = gameEnemyStealthAwarenessState.Relaxed;
              };
            };
          };
        };
      };
    };
    if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) {
      this.m_root.SetState(n"Combat");
    } else {
      if percent > 0.00 || this.m_animationIsPlaying {
        this.m_root.SetState(n"Increasing");
      } else {
        this.m_root.SetState(n"");
      };
    };
  }

  private final func UpdateNPCDetection(percent: Float) -> Void {
    if !this.m_animationIsPlaying && !this.m_nameplateAnimationIsPlaying {
      this.m_highLevelState = this.m_mappin.GetHighLevelState();
      if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Combat) && NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) && percent > this.c_awareToCombatThreshold {
        if this.m_inNameplateMode {
          this.PlayAnim(n"nameplate_to_alert", n"OnPotentialCombatAnimFinished");
          this.m_inNameplateMode = false;
        } else {
          if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
            if !this.m_squadInCombat || this.isCurrentlyClamped && this.IsObjectOffScreen() {
              this.PlayAnim(n"relaxed_to_alert", n"OnPotentialCombatAnimFinished");
            };
          } else {
            if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Aware) {
              this.PlayAnim(n"aware_to_alert", n"OnPotentialCombatAnimFinished");
            } else {
              this.PlayAnim(n"enter_combat", n"OnBasicAnimFinished");
            };
          };
        };
        this.m_currentAnimState = gameEnemyStealthAwarenessState.Combat;
        this.m_mappin.UpdateCombatantState(true);
      } else {
        if percent > this.c_emptyThreshold && Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
          if !this.m_squadInCombat {
            if this.m_inNameplateMode {
              this.PlayAnim(n"nameplate_to_aware", n"OnBasicAnimFinished");
              this.m_inNameplateMode = false;
            } else {
              this.PlayAnim(n"relaxed_to_aware", n"OnBasicAnimFinished");
            };
            this.m_currentAnimState = gameEnemyStealthAwarenessState.Aware;
          };
          if this.m_isDrone {
            this.NotifyDroneAboutStartingDetection();
          };
        } else {
          if percent >= 100.00 && Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Aware) {
            this.PlayAnim(n"aware_to_alert", n"OnBasicAnimFinished");
            this.m_currentAnimState = gameEnemyStealthAwarenessState.Alerted;
          } else {
            if percent < this.c_combatToAwareThreshold && Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) {
              if !this.m_squadInCombat && this.m_numberOfCombatants <= 0 {
                this.PlayAnim(n"alert_to_aware", n"OnBasicAnimFinished");
                this.m_currentAnimState = gameEnemyStealthAwarenessState.Aware;
              };
              if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) || Equals(this.m_highLevelState, gamedataNPCHighLevelState.Alerted) {
                this.m_mappin.UpdateCombatantState(false);
              };
            } else {
              if percent > this.c_emptyThreshold && percent < 100.00 && Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Alerted) {
                if this.m_squadInCombat {
                  this.PlayAnim(n"alert_to_aware_nointro", n"OnPotentialRelaxedAnimFinished");
                  this.m_currentAnimState = gameEnemyStealthAwarenessState.Relaxed;
                } else {
                  this.PlayAnim(n"alert_to_aware_nointro", n"OnBasicAnimFinished");
                  this.m_currentAnimState = gameEnemyStealthAwarenessState.Aware;
                };
                if this.m_isDrone {
                  this.NotifyDroneAboutStoppingDetection();
                };
              } else {
                if percent <= this.c_emptyThreshold && NotEquals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
                  if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Alerted) {
                    this.PlayAnim(n"alert_to_aware_nointro", n"OnPotentialRelaxedAnimFinished");
                  } else {
                    if this.m_nameplateVisible {
                      this.PlayAnim(n"aware_to_nameplate", n"OnBasicAnimFinished");
                      this.m_inNameplateMode = true;
                      this.UpdateNameplateIcon();
                    } else {
                      this.PlayAnim(n"aware_to_relaxed", n"OnBasicAnimFinished");
                    };
                  };
                  this.m_currentAnimState = gameEnemyStealthAwarenessState.Relaxed;
                  if this.m_isDrone {
                    this.NotifyDroneAboutStoppingDetection();
                  };
                } else {
                  if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Aware) && this.m_squadInCombat && this.m_numberOfCombatants >= 1 {
                    if this.m_nameplateVisible {
                      this.PlayAnim(n"aware_to_nameplate", n"OnBasicAnimFinished");
                      this.m_inNameplateMode = true;
                      this.UpdateNameplateIcon();
                    } else {
                      this.PlayAnim(n"aware_to_relaxed", n"OnBasicAnimFinished");
                    };
                    this.m_currentAnimState = gameEnemyStealthAwarenessState.Relaxed;
                  };
                };
              };
            };
          };
        };
      };
    };
    if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) {
      this.UpdateReprimandAnimation(0.00, true);
      this.UpdateNameplateColor(true);
      this.m_root.SetState(n"Combat");
    } else {
      if percent > 0.00 || this.m_animationIsPlaying {
        if this.m_mappin.WillReprimand() {
          this.UpdateReprimandAnimation(percent, false);
          this.UpdateNameplateColor(false);
          this.m_root.SetState(n"Increasing_Reprimand");
        } else {
          this.UpdateReprimandAnimation(0.00, true);
          this.UpdateNameplateColor(true);
          this.m_root.SetState(n"Increasing");
        };
      } else {
        this.UpdateReprimandAnimation(0.00, false);
        this.UpdateNameplateColor(false);
        this.m_root.SetState(n"");
      };
    };
    this.m_lastState = this.m_highLevelState;
    this.m_lastReaction = this.m_reaction;
  }

  private final func UpdateCanvasOpacity() -> Void {
    if this.m_inNameplateMode || Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) || this.m_canSeePlayer || this.m_statusEffectShowing {
      this.m_canvas.SetOpacity(1.00);
    } else {
      this.m_canvas.SetOpacity(0.30);
    };
  }

  private final func UpdateReprimandAnimation(percent: Float, forceStop: Bool) -> Void {
    let animOptions: inkAnimOptions;
    let animState: gameReprimandMappinAnimationState;
    let playing: Bool = percent >= 100.00 && !forceStop;
    if playing {
      animState = this.m_mappin.GetReprimandAnimationState();
    } else {
      animState = this.m_reprimandAnimationState;
    };
    if NotEquals(this.m_reprimandAnimationIsPlaying, playing) || NotEquals(this.m_reprimandAnimationState, animState) {
      if IsDefined(this.m_reprimandAnimationProxy) && this.m_reprimandAnimationProxy.IsPlaying() {
        this.m_reprimandAnimationProxy.Stop();
      };
      if playing {
        animOptions.loopType = inkanimLoopType.Cycle;
        animOptions.loopInfinite = true;
        if Equals(animState, IntEnum(0l)) {
          this.m_reprimandAnimationProxy = this.PlayLibraryAnimation(n"reprimand_blinking");
        } else {
          if Equals(animState, gameReprimandMappinAnimationState.Normal) {
            this.m_reprimandAnimationProxy = this.PlayLibraryAnimation(n"reprimand_blinking", animOptions);
          } else {
            this.m_reprimandAnimationProxy = this.PlayLibraryAnimation(n"reprimand_blinking2", animOptions);
          };
        };
      } else {
        if !forceStop && this.m_reprimandAnimationIsPlaying && NotEquals(this.m_reprimandAnimationState, IntEnum(0l)) {
          this.m_reprimandAnimationProxy = this.PlayLibraryAnimation(n"reprimand_blinking");
        };
      };
      this.m_reprimandAnimationIsPlaying = playing;
      this.m_reprimandAnimationState = animState;
    };
  }

  private final func UpdateNameplateColor(isHostile: Bool) -> Void {
    if this.m_nameplateVisible {
      if IsDefined(this.m_nameplateController) {
        this.m_nameplateController.UpdateHealthbarColor(isHostile);
      };
    };
  }

  private final func IsObjectOffScreen() -> Bool {
    let dot: Float;
    let enemyDirection: Vector4;
    let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.m_ownerObject.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) {
      enemyDirection = this.m_ownerObject.GetWorldPosition() - player.GetWorldPosition();
      dot = Vector4.Dot(Vector4.Normalize(enemyDirection), Matrix.GetDirectionVector(player.GetFPPCameraComponent().GetLocalToWorld()));
      if dot <= 0.70 {
        return true;
      };
      return false;
    };
    return true;
  }

  private final func PlayAnim(animName: CName, callBack: CName) -> Void {
    if this.m_animationIsPlaying {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    this.m_animationIsPlaying = true;
  }

  private final func PlayNameplateAnim(animName: CName, callBack: CName) -> Void {
    if this.m_nameplateAnimationIsPlaying {
      this.m_nameplateAnimationProxy.Stop();
    };
    this.m_nameplateAnimationProxy = this.PlayLibraryAnimation(animName);
    this.m_nameplateAnimationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    this.m_nameplateAnimationIsPlaying = true;
  }

  protected cb func OnBasicAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_animationProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnBasicAnimFinished");
    this.m_animationIsPlaying = false;
    this.OnUpdate();
  }

  protected cb func OnPotentialRelaxedAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_animationProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnPotentialRelaxedAnimFinished");
    this.m_animationIsPlaying = false;
    if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Relaxed) {
      if this.m_nameplateVisible {
        this.PlayAnim(n"aware_to_nameplate", n"OnBasicAnimFinished");
        this.m_inNameplateMode = true;
        this.UpdateNameplateIcon();
      } else {
        this.PlayAnim(n"aware_to_relaxed", n"OnBasicAnimFinished");
      };
    } else {
      this.OnUpdate();
    };
  }

  protected cb func OnPotentialCombatAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_animationProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnPotentialCombatAnimFinished");
    this.m_animationIsPlaying = false;
    if Equals(this.m_currentAnimState, gameEnemyStealthAwarenessState.Combat) {
      this.PlayAnim(n"enter_combat", n"OnBasicAnimFinished");
    } else {
      this.OnUpdate();
    };
  }

  protected cb func OnNameplateAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_nameplateAnimationProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnNameplateAnimFinished");
    this.m_nameplateAnimationIsPlaying = false;
    this.OnUpdate();
  }

  public func GetWidgetForNameplateSlot() -> wref<inkWidget> {
    return this.GetRootWidget();
  }

  protected cb func OnNameplate(isNameplateVisible: Bool, nameplateController: wref<NpcNameplateGameController>) -> Bool {
    if (this.m_isAggressive || this.m_isHostile) && (!this.m_isDevice || this.m_isTurret) {
      this.m_nameplateVisible = isNameplateVisible;
      if isNameplateVisible {
        this.OverrideScaleByDistance(false);
        this.SetProjectToScreenSpace(false);
        this.m_canvas.SetAnchorPoint(new Vector2(0.50, 0.00));
        this.m_canvas.SetMargin(0.00, 66.00, 0.00, 0.00);
        inkWidgetRef.SetMargin(this.m_objectMarker, 0.00, 121.00, 0.00, 0.00);
        this.m_nameplateController = nameplateController;
        if IsDefined(this.m_nameplateController) {
          this.m_nameplateController.UpdateMappinSlotMargin(62.00);
        };
      } else {
        this.OverrideScaleByDistance(true);
        this.SetProjectToScreenSpace(true);
        this.m_canvas.SetAnchorPoint(new Vector2(0.50, 0.50));
        this.m_canvas.SetMargin(0.00, 0.00, 0.00, 0.00);
        inkWidgetRef.SetMargin(this.m_objectMarker, 0.00, 22.00, 0.00, 0.00);
        if IsDefined(this.m_nameplateController) {
          this.m_nameplateController.UpdateMappinSlotMargin(2.00);
        };
      };
      this.OnUpdate();
    };
  }
}
