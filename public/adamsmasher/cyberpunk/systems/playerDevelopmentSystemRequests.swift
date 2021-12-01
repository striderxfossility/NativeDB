
public class RequestStatsBB extends PlayerScriptableSystemRequest {

  public final func Set(_owner: wref<GameObject>) -> Void {
    this.owner = _owner;
  }
}

public class AddExperience extends PlayerScriptableSystemRequest {

  public let m_amount: Int32;

  public let m_experienceType: gamedataProficiencyType;

  public let m_debug: Bool;

  public final func Set(_owner: wref<GameObject>, expAmount: Int32, type: gamedataProficiencyType, isDebug: Bool) -> Void {
    this.owner = _owner;
    this.m_amount = expAmount;
    this.m_experienceType = type;
    this.m_debug = isDebug;
  }
}

public class ProcessQueuedCombatExperience extends PlayerScriptableSystemRequest {

  public let m_entity: EntityID;

  public final func Set(_owner: wref<GameObject>, entity: EntityID) -> Void {
    this.owner = _owner;
    this.m_entity = entity;
  }
}

public class SetProficiencyLevel extends PlayerScriptableSystemRequest {

  public let m_newLevel: Int32;

  public let m_proficiencyType: gamedataProficiencyType;

  public let m_telemetryLevelGainReason: telemetryLevelGainReason;

  public final func Set(_owner: wref<GameObject>, level: Int32, type: gamedataProficiencyType, telemetryGainReason: telemetryLevelGainReason) -> Void {
    this.owner = _owner;
    this.m_newLevel = level;
    this.m_proficiencyType = type;
    this.m_telemetryLevelGainReason = telemetryGainReason;
  }
}

public class BuyPerk extends PlayerScriptableSystemRequest {

  public let m_perkType: gamedataPerkType;

  public final func Set(_owner: wref<GameObject>, type: gamedataPerkType) -> Void {
    this.owner = _owner;
    this.m_perkType = type;
  }
}

public class RemovePerk extends PlayerScriptableSystemRequest {

  public let m_perkType: gamedataPerkType;

  public final func Set(_owner: wref<GameObject>, type: gamedataPerkType) -> Void {
    this.owner = _owner;
    this.m_perkType = type;
  }
}

public class RemoveAllPerks extends PlayerScriptableSystemRequest {

  public final func Set(_owner: wref<GameObject>) -> Void {
    this.owner = _owner;
  }
}

public class UnlockPerkArea extends PlayerScriptableSystemRequest {

  public let m_perkArea: gamedataPerkArea;

  public final func Set(_owner: wref<GameObject>, areaType: gamedataPerkArea) -> Void {
    this.owner = _owner;
    this.m_perkArea = areaType;
  }
}

public class LockPerkArea extends PlayerScriptableSystemRequest {

  public let m_perkArea: gamedataPerkArea;

  public final func Set(_owner: wref<GameObject>, areaType: gamedataPerkArea) -> Void {
    this.owner = _owner;
    this.m_perkArea = areaType;
  }
}

public class IncreaseTraitLevel extends PlayerScriptableSystemRequest {

  public let m_trait: gamedataTraitType;

  public final func Set(_owner: wref<GameObject>, traitType: gamedataTraitType) -> Void {
    this.owner = _owner;
    this.m_trait = traitType;
  }
}

public class SetAttribute extends PlayerScriptableSystemRequest {

  public let m_statLevel: Float;

  public let m_attributeType: gamedataStatType;

  public final func Set(_owner: wref<GameObject>, level: Float, type: gamedataStatType) -> Void {
    this.owner = _owner;
    this.m_statLevel = level;
    this.m_attributeType = type;
  }
}

public class BuyAttribute extends PlayerScriptableSystemRequest {

  public let m_attributeType: gamedataStatType;

  public let m_grantAttributePoint: Bool;

  public final func Set(_owner: wref<GameObject>, type: gamedataStatType, opt grantAttributePoint: Bool) -> Void {
    this.owner = _owner;
    this.m_attributeType = type;
    this.m_grantAttributePoint = grantAttributePoint;
  }
}

public class AddDevelopmentPoints extends PlayerScriptableSystemRequest {

  public let m_amountOfPoints: Int32;

  public let m_developmentPointType: gamedataDevelopmentPointType;

  public final func Set(_owner: wref<GameObject>, amount: Int32, type: gamedataDevelopmentPointType) -> Void {
    this.owner = _owner;
    this.m_amountOfPoints = amount;
    this.m_developmentPointType = type;
  }
}

public class ModifyStatCheckPrereq extends PlayerScriptableSystemRequest {

  public let m_register: Bool;

  public let m_statCheckState: ref<StatCheckPrereqState>;

  public final func Set(_owner: wref<GameObject>, reg: Bool, statToCheck: ref<StatCheckPrereqState>) -> Void {
    this.owner = _owner;
    this.m_register = reg;
    this.m_statCheckState = statToCheck;
  }
}

public class ModifySkillCheckPrereq extends PlayerScriptableSystemRequest {

  public let m_register: Bool;

  public let m_skillCheckState: ref<SkillCheckPrereqState>;

  public final func Set(_owner: wref<GameObject>, reg: Bool, checkState: ref<SkillCheckPrereqState>) -> Void {
    this.owner = _owner;
    this.m_register = reg;
    this.m_skillCheckState = checkState;
  }
}

public class UpdatePlayerDevelopment extends PlayerScriptableSystemRequest {

  public final func Set(_owner: wref<GameObject>) -> Void {
    this.owner = _owner;
  }
}

public class SetProgressionBuild extends PlayerScriptableSystemRequest {

  public let m_buildType: gamedataBuildType;

  public final func Set(_owner: wref<GameObject>, build: gamedataBuildType) -> Void {
    this.m_buildType = build;
    this.owner = _owner;
  }
}

public class BumpNetrunnerMinigameLevel extends PlayerScriptableSystemRequest {

  public let completedMinigameLevel: Int32;

  public final func Set(_owner: wref<GameObject>, value: Int32) -> Void {
    this.owner = _owner;
    this.completedMinigameLevel = value;
  }
}

public class RefreshPerkAreas extends PlayerScriptableSystemRequest {

  public final func Set(_owner: wref<GameObject>) -> Void {
    this.owner = _owner;
  }
}
