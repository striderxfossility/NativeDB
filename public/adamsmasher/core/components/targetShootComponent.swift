
public native class TargetShootComponent extends IComponent {

  private final native const func IsTimeBetweenHitsEnabled() -> Bool;

  private final native const func GetLastHitTime() -> Float;

  private final native func SetLastHitTime(value: Float) -> Void;

  private final const func GetValueFromCurve(curveName: CName, lookupValue: Float) -> Float {
    let statsDataSystem: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.GetGameObject().GetGame());
    return statsDataSystem.GetValueFromCurve(n"time_between_hits", lookupValue, curveName);
  }

  private final const func GetDistanceCoefficientFromCurve(curveName: CName, lookupValue: Float) -> Float {
    let statsDataSystem: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.GetGameObject().GetGame());
    return statsDataSystem.GetValueFromCurve(n"tbh_weapon_type_distance_mults", lookupValue, curveName);
  }

  private final const func GetVisibilityCoefficientFromCurve(curveName: CName, lookupValue: Float) -> Float {
    let statsDataSystem: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.GetGameObject().GetGame());
    return statsDataSystem.GetValueFromCurve(n"tbh_weapon_type_visibility_mults", lookupValue, curveName);
  }

  private final native const func IsDebugEnabled() -> Bool;

  private final const func GetGameObject() -> ref<GameObject> {
    return this.GetEntity() as GameObject;
  }

  public final func HandleWeaponShoot(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, shootAtPoint: Vector4, maxSpread: Float, coefficientMultiplier: Float, out miss: Bool) -> Vector4 {
    let characterRecord: ref<Character_Record>;
    let weaponRecord: ref<WeaponItem_Record>;
    let gameInstance: GameInstance = this.GetGameObject().GetGame();
    let result: Vector4 = new Vector4(0.00, 0.00, 0.00, 0.00);
    let useForcedMissZOffset: Bool = false;
    let forcedMissZOffset: Float = 0.00;
    if !this.IsTimeBetweenHitsEnabled() {
      return result;
    };
    miss = false;
    if this.ShouldBeHit(weaponOwner, weapon, coefficientMultiplier) {
      this.SetLastHitTime(EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance)));
      if this.IsDebugEnabled() {
        GameInstance.GetDebugVisualizerSystem(gameInstance).DrawWireSphere(shootAtPoint + result, 0.04, new Color(252u, 3u, 3u, 255u), 3.00);
      };
    } else {
      if (weaponOwner as ScriptedPuppet) != null {
        weaponRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID()));
        characterRecord = TweakDBInterface.GetCharacterRecord((weaponOwner as ScriptedPuppet).GetRecordID());
        useForcedMissZOffset = weaponRecord.UseForcedTBHZOffset() && characterRecord.UseForcedTBHZOffset();
        forcedMissZOffset = characterRecord.ForcedTBHZOffset();
      };
      result = this.CalculateMissOffset(weaponOwner, weapon, shootAtPoint, maxSpread, useForcedMissZOffset, forcedMissZOffset);
      miss = true;
      if this.IsDebugEnabled() {
        GameInstance.GetDebugVisualizerSystem(gameInstance).DrawWireSphere(shootAtPoint + result, 0.04, new Color(50u, 168u, 82u, 255u), 3.00);
      };
    };
    return result;
  }

  public final func HandleWeaponShoot(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, shootAtPoint: Vector4, maxSpread: Float, coefficientMultiplier: Float) -> Vector4 {
    let tmp: Bool;
    return this.HandleWeaponShoot(weaponOwner, weapon, shootAtPoint, maxSpread, coefficientMultiplier, tmp);
  }

  private final native const func CalculateMissOffset(weaponOwner: wref<GameObject>, weapon: wref<WeaponObject>, shootAtPointWS: Vector4, maxSpread: Float, useForcedMissZOffset: Bool, forcedMissZOffset: Float) -> Vector4;

  public final native const func GetPackageName() -> String;

  private final const func GetDifficultyLevelCoefficient() -> Float {
    let fieldName: String;
    let statsDataSys: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.GetGameObject().GetGame());
    let difficulty: gameDifficulty = statsDataSys.GetDifficulty();
    switch difficulty {
      case gameDifficulty.Story:
        fieldName = ".storyModeMultiplier";
        break;
      case gameDifficulty.Easy:
        fieldName = ".easyModeMultiplier";
        break;
      case gameDifficulty.Hard:
        fieldName = ".normalModeMultiplier";
        break;
      case gameDifficulty.VeryHard:
        fieldName = ".hardModeMultiplier";
        break;
      default:
        fieldName = ".normalModeMultiplier";
    };
    return TweakDBInterface.GetFloat(TDBID.Create(this.GetPackageName() + fieldName), 1.00);
  }

  private final const func GetGroupCoefficient(weaponOwner: ref<GameObject>) -> Float {
    let squad: ref<SquadScriptInterface>;
    let defaultValue: Float = 0.00;
    let squadMember: ref<SquadMemberBaseComponent> = weaponOwner.GetSquadMemberComponent();
    if !IsDefined(squadMember) {
      return defaultValue;
    };
    squad = squadMember.MySquad(AISquadType.Community);
    if !IsDefined(squad) {
      return defaultValue;
    };
    return this.GetValueFromCurve(n"group_coefficient", Cast(Cast(squad.GetMembersCount()) - 1));
  }

  private final const func GetPlayersNumCoefficient(weaponOwner: ref<GameObject>) -> Float {
    let outPlayerGameObjects: array<ref<GameObject>>;
    let playersCount: Uint32 = 1u;
    if IsMultiplayer() && (IsDefined(this.GetGameObject() as Muppet) || IsDefined(this.GetGameObject() as PlayerPuppet)) {
      playersCount = GameInstance.GetPlayerSystem(weaponOwner.GetGame()).FindPlayerControlledObjects(weaponOwner.GetWorldPosition(), 0.00, true, true, outPlayerGameObjects);
      return this.GetValueFromCurve(n"players_count_coefficient", Cast(playersCount));
    };
    return 1.00;
  }

  private final const func GetDistanceCoefficient(weapon: wref<WeaponObject>, targetPosition: Vector4) -> Float {
    let distance: Float = Vector4.Distance(weapon.GetWorldPosition(), targetPosition);
    let heldItemType: gamedataItemType = RPGManager.GetItemType(weapon.GetItemID());
    switch heldItemType {
      case gamedataItemType.Wea_AssaultRifle:
        return this.GetDistanceCoefficientFromCurve(n"assault_rifle_distance_coefficient", distance);
      case gamedataItemType.Wea_ShotgunDual:
        return this.GetDistanceCoefficientFromCurve(n"dual_shotgun_distance_coefficient", distance);
      case gamedataItemType.Wea_Handgun:
        return this.GetDistanceCoefficientFromCurve(n"handgun_distance_coefficient", distance);
      case gamedataItemType.Wea_HeavyMachineGun:
        return this.GetDistanceCoefficientFromCurve(n"hmg_distance_coefficient", distance);
      case gamedataItemType.Wea_LightMachineGun:
        return this.GetDistanceCoefficientFromCurve(n"lmg_distance_coefficient", distance);
      case gamedataItemType.Wea_PrecisionRifle:
        return this.GetDistanceCoefficientFromCurve(n"precision_rifle_distance_coefficient", distance);
      case gamedataItemType.Wea_Revolver:
        return this.GetDistanceCoefficientFromCurve(n"revolver_distance_coefficient", distance);
      case gamedataItemType.Wea_Shotgun:
        return this.GetDistanceCoefficientFromCurve(n"shotgun_distance_coefficient", distance);
      case gamedataItemType.Wea_SubmachineGun:
        return this.GetDistanceCoefficientFromCurve(n"smg_distance_coefficient", distance);
      case gamedataItemType.Wea_SniperRifle:
        return this.GetDistanceCoefficientFromCurve(n"sniper_rifle_distance_coefficient", distance);
      default:
        return this.GetDistanceCoefficientFromCurve(n"assault_rifle_distance_coefficient", distance);
    };
  }

  private final const func GetVisibilityCoefficient(weaponOwner: ref<GameObject>, weapon: ref<WeaponObject>, target: ref<GameObject>, visibilityThresholdCoefficient: Float) -> Float {
    let heldItemType: gamedataItemType;
    let continuousLineOfSight: Float = 0.00;
    weaponOwner.GetSourceShootComponent().GetContinuousLineOfSightToTarget(target, continuousLineOfSight);
    if continuousLineOfSight == 0.00 {
      return 0.00;
    };
    continuousLineOfSight *= visibilityThresholdCoefficient;
    heldItemType = RPGManager.GetItemType(weapon.GetItemID());
    switch heldItemType {
      case gamedataItemType.Wea_AssaultRifle:
        return this.GetVisibilityCoefficientFromCurve(n"assault_rifle_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_ShotgunDual:
        return this.GetVisibilityCoefficientFromCurve(n"dual_shotgun_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_Handgun:
        return this.GetVisibilityCoefficientFromCurve(n"handgun_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_HeavyMachineGun:
        return this.GetVisibilityCoefficientFromCurve(n"hmg_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_LightMachineGun:
        return this.GetVisibilityCoefficientFromCurve(n"lmg_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_PrecisionRifle:
        return this.GetVisibilityCoefficientFromCurve(n"precision_rifle_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_Revolver:
        return this.GetVisibilityCoefficientFromCurve(n"revolver_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_Shotgun:
        return this.GetVisibilityCoefficientFromCurve(n"shotgun_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_SubmachineGun:
        return this.GetVisibilityCoefficientFromCurve(n"smg_visibility_coefficient", continuousLineOfSight);
      case gamedataItemType.Wea_SniperRifle:
        return this.GetVisibilityCoefficientFromCurve(n"sniper_rifle_visibility_coefficient", continuousLineOfSight);
      default:
        return this.GetVisibilityCoefficientFromCurve(n"assault_rifle_visibility_coefficient", continuousLineOfSight);
    };
  }

  private final func CalculateTimeBetweenHits(params: TimeBetweenHitsParameters) -> Float {
    return params.difficultyLevelCoefficient * params.accuracyCoefficient * params.baseCoefficient * params.baseSourceCoefficient * params.distanceCoefficient * params.visibilityCoefficient * params.playersCountCoefficient;
  }

  private final func ShouldBeHit(weaponOwner: ref<GameObject>, weapon: wref<WeaponObject>, visibilityThresholdCoefficient: Float) -> Bool {
    let params: TimeBetweenHitsParameters;
    let shouldBeHit: Bool;
    let timeBetweenHits: Float;
    let visibilityCollisionToTargetDist: Float;
    let target: ref<GameObject> = this.GetGameObject();
    let gameInstance: GameInstance = target.GetGame();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
    if !IsDefined(weaponOwner.GetSourceShootComponent()) {
      return true;
    };
    if target.IsPlayer() && RPGManager.IsTechPierceEnabled(weaponOwner.GetGame(), weaponOwner, weapon.GetItemID()) {
      visibilityCollisionToTargetDist = (weaponOwner as ScriptedPuppet).GetSenses().GetVisibilityTraceEndToAgentDist(target);
      if visibilityCollisionToTargetDist > 0.00 && visibilityCollisionToTargetDist < 1000000000.00 {
        return false;
      };
    };
    params.visibilityCoefficient = this.GetVisibilityCoefficient(weaponOwner, weapon, target, visibilityThresholdCoefficient);
    if visibilityThresholdCoefficient > 0.00 && params.visibilityCoefficient <= 0.00 {
      if this.IsDebugEnabled() {
        GameInstance.GetDebugVisualizerSystem(gameInstance).DrawText3D(weapon.GetWorldPosition(), FloatToString(-1.00), new Color(41u, 191u, 31u, 255u), 0.70);
      };
      return false;
    };
    if visibilityThresholdCoefficient == 0.00 {
      params.visibilityCoefficient = visibilityThresholdCoefficient;
    };
    params.baseCoefficient = statsSystem.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.TBHsBaseCoefficient);
    params.baseSourceCoefficient = statsSystem.GetStatValue(Cast(weaponOwner.GetEntityID()), gamedataStatType.TBHsBaseSourceMultiplierCoefficient);
    params.accuracyCoefficient = 1.00 / statsSystem.GetStatValue(Cast(weaponOwner.GetEntityID()), gamedataStatType.Accuracy);
    params.difficultyLevelCoefficient = this.GetDifficultyLevelCoefficient();
    params.distanceCoefficient = this.GetDistanceCoefficient(weapon, target.GetWorldPosition());
    if params.distanceCoefficient == 0.00 {
      return false;
    };
    params.groupCoefficient = this.GetGroupCoefficient(weaponOwner);
    params.playersCountCoefficient = this.GetPlayersNumCoefficient(weaponOwner);
    params.coefficientMultiplier = visibilityThresholdCoefficient;
    timeBetweenHits = this.CalculateTimeBetweenHits(params);
    if !IsFinal() {
      weaponOwner.GetSourceShootComponent().SetDebugParameters(params);
    };
    shouldBeHit = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance)) >= this.GetLastHitTime() + timeBetweenHits;
    if this.IsDebugEnabled() {
      if shouldBeHit {
        GameInstance.GetDebugVisualizerSystem(gameInstance).DrawText3D(weapon.GetWorldPosition(), FloatToString(timeBetweenHits), new Color(245u, 22u, 49u, 255u), 0.70);
      } else {
        GameInstance.GetDebugVisualizerSystem(gameInstance).DrawText3D(weapon.GetWorldPosition(), FloatToString(timeBetweenHits), new Color(41u, 191u, 31u, 255u), 0.70);
      };
    };
    return shouldBeHit;
  }
}
