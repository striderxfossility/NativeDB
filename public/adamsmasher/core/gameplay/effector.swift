
public native class Effector extends IScriptable {

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void;

  protected func Uninitialize(game: GameInstance) -> Void;

  protected func ActionOn(owner: ref<GameObject>) -> Void;

  protected func ActionOff(owner: ref<GameObject>) -> Void;

  protected func RepeatedAction(owner: ref<GameObject>) -> Void;

  protected final native const func GetPrereqState() -> ref<PrereqState>;

  protected final native const func GetRecord() -> TweakDBID;

  protected final native const func GetParentRecord() -> TweakDBID;

  protected final func GetApplicationTargetAsStatsObjectID(effectorOwner: ref<GameObject>, applicationTarget: String, out targetID: StatsObjectID) -> Bool {
    let hitPrereqState: ref<GenericHitPrereqState>;
    let item: ItemID;
    let weapon: ref<WeaponObject>;
    switch applicationTarget {
      case "Weapon":
        weapon = ScriptedPuppet.GetActiveWeapon(effectorOwner);
        if !IsDefined(weapon) {
          return false;
        };
        targetID = weapon.GetItemData().GetStatsObjectID();
        break;
      case "Fists":
        if effectorOwner.IsPlayer() {
          item = EquipmentSystem.GetData(effectorOwner).GetActiveItem(gamedataEquipmentArea.BaseFists);
          if !ItemID.IsValid(item) {
            return false;
          };
          targetID = GameInstance.GetTransactionSystem(effectorOwner.GetGame()).GetItemData(effectorOwner, item).GetStatsObjectID();
        };
        break;
      case "Target":
        hitPrereqState = this.GetPrereqState() as GenericHitPrereqState;
        if IsDefined(hitPrereqState) {
          targetID = Cast(hitPrereqState.GetHitEvent().target.GetEntityID());
        };
        break;
      case "DamageSource":
        hitPrereqState = this.GetPrereqState() as GenericHitPrereqState;
        if IsDefined(hitPrereqState) {
          targetID = Cast(hitPrereqState.GetHitEvent().attackData.GetInstigator().GetEntityID());
        };
        break;
      default:
        targetID = Cast(effectorOwner.GetEntityID());
    };
    return StatsObjectID.IsDefined(targetID);
  }

  protected final func GetApplicationTarget(effectorOwner: ref<GameObject>, applicationTarget: String, out targetID: EntityID) -> Bool {
    let hitPrereqState: ref<GenericHitPrereqState>;
    let weapon: ref<WeaponObject>;
    switch applicationTarget {
      case "Weapon":
        weapon = ScriptedPuppet.GetActiveWeapon(effectorOwner);
        if !IsDefined(weapon) {
          return false;
        };
        targetID = weapon.GetEntityID();
        break;
      case "Target":
        hitPrereqState = this.GetPrereqState() as GenericHitPrereqState;
        if IsDefined(hitPrereqState) {
          targetID = hitPrereqState.GetHitEvent().target.GetEntityID();
        };
        break;
      case "DamageSource":
        hitPrereqState = this.GetPrereqState() as GenericHitPrereqState;
        if IsDefined(hitPrereqState) {
          targetID = hitPrereqState.GetHitEvent().attackData.GetInstigator().GetEntityID();
        };
        break;
      default:
        targetID = effectorOwner.GetEntityID();
    };
    return EntityID.IsDefined(targetID);
  }

  protected final func GetApplicationTarget(effectorOwner: ref<GameObject>, applicationTarget: String, out target: wref<GameObject>) -> Bool {
    let hitPrereqState: ref<GenericHitPrereqState>;
    let weapon: ref<WeaponObject>;
    switch applicationTarget {
      case "Weapon":
        weapon = ScriptedPuppet.GetActiveWeapon(effectorOwner);
        if !IsDefined(weapon) {
          return false;
        };
        target = weapon;
        break;
      case "Target":
        hitPrereqState = this.GetPrereqState() as GenericHitPrereqState;
        if IsDefined(hitPrereqState) {
          target = hitPrereqState.GetHitEvent().target;
        };
        break;
      case "DamageSource":
        hitPrereqState = this.GetPrereqState() as GenericHitPrereqState;
        if IsDefined(hitPrereqState) {
          target = hitPrereqState.GetHitEvent().attackData.GetInstigator();
        };
        break;
      case "QuickHackSource":
        target = GameInstance.FindEntityByID(effectorOwner.GetGame(), StatusEffectHelper.GetStatusEffectWithTag(effectorOwner, n"Quickhack").GetInstigatorEntityID()) as GameObject;
        break;
      default:
        target = effectorOwner;
    };
    return target != null;
  }
}

public native class ContinuousEffector extends Effector {

  protected func ContinuousAction(owner: ref<GameObject>, instigator: ref<GameObject>) -> Void;
}

public class TestEffector extends Effector {

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    Log("TestEffector Initialize!");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    Log("TestActionOn!");
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    Log("TestActionOff");
  }
}

public class StatPoolEffector extends Effector {

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    Log("StatPoolEffector ActionOffTest!");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    Log("StatPoolEffector ActionOnTest!");
  }
}

public class SenseSwitchEffector extends Effector {

  public final static func SenseSwitch(senseComponent: ref<SenseComponent>, condition: Bool) -> Void {
    if condition {
      senseComponent.RemoveHearingMappin();
    } else {
      senseComponent.CreateHearingMappin();
    };
    senseComponent.Toggle(condition);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    let senseComponent: ref<SenseComponent> = ownerPuppet.GetSensesComponent();
    SenseSwitchEffector.SenseSwitch(senseComponent, false);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    let ownerPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    let senseComponent: ref<SenseComponent> = ownerPuppet.GetSensesComponent();
    SenseSwitchEffector.SenseSwitch(senseComponent, true);
  }
}

public class SpawnSubCharacterEffector extends Effector {

  public let m_owner: wref<GameObject>;

  public let m_subCharacterTDBID: TweakDBID;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(record + t".subCharacterRecord", "");
    this.m_subCharacterTDBID = TDBID.Create(str);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.ActionOff(this.m_owner);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let request: ref<SpawnUniqueSubCharacterRequest>;
    this.m_owner = owner;
    let scs: ref<SubCharacterSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"SubCharacterSystem") as SubCharacterSystem;
    if IsDefined(scs) {
      request = new SpawnUniqueSubCharacterRequest();
      request.subCharacterID = this.m_subCharacterTDBID;
      GameInstance.GetDelaySystem(owner.GetGame()).DelayScriptableSystemRequest(n"SubCharacterSystem", request, 3.00);
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    let request: ref<DespawnUniqueSubCharacterRequest>;
    let scs: ref<SubCharacterSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"SubCharacterSystem") as SubCharacterSystem;
    if IsDefined(scs) {
      request = new DespawnUniqueSubCharacterRequest();
      request.subCharacterID = this.m_subCharacterTDBID;
      scs.QueueRequest(request);
    };
  }
}

public class DOTContinuousEffector extends ContinuousEffector {

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    Log("DOTContinuousEffector Initialize!");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    Log("DOTContinuousEffector ActionOnTest!");
  }

  protected func ContinuousAction(owner: ref<GameObject>, instigator: ref<GameObject>) -> Void {
    Log("DelayedContinuousEffector ContinuousActionTest!");
  }
}

public class ForceDismembermentEffector extends Effector {

  public let m_bodyPart: gameDismBodyPart;

  public let m_woundType: gameDismWoundType;

  public let m_isCritical: Bool;

  public let m_skipDeathAnim: Bool;

  public let m_shouldKillNPC: Bool;

  public let m_dismembermentChance: Float;

  public let m_effectorRecord: ref<ForceDismembermentEffector_Record>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_effectorRecord = TweakDBInterface.GetForceDismembermentEffectorRecord(record);
    let str: String = this.m_effectorRecord.BodyPart();
    this.m_bodyPart = IntEnum(Cast(EnumValueFromString("gameDismBodyPart", str)));
    str = this.m_effectorRecord.WoundType();
    this.m_woundType = IntEnum(Cast(EnumValueFromString("gameDismWoundType", str)));
    this.m_isCritical = this.m_effectorRecord.IsCritical();
    this.m_skipDeathAnim = this.m_effectorRecord.SkipDeathAnim();
    this.m_shouldKillNPC = this.m_effectorRecord.ShouldKillNPC();
    this.m_dismembermentChance = this.m_effectorRecord.DismembermentChance();
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let rand: Float;
    let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let puppet: wref<ScriptedPuppet> = owner as ScriptedPuppet;
    if !IsDefined(puppet) || !IsDefined(player) {
      return;
    };
    rand = RandF();
    if rand <= this.m_dismembermentChance {
      DismembermentComponent.RequestDismemberment(puppet, this.m_bodyPart, this.m_woundType, Vector4.EmptyVector(), this.m_isCritical);
    };
    if this.m_shouldKillNPC || Equals(this.m_bodyPart, gameDismBodyPart.HEAD) {
      StatusEffectHelper.ApplyStatusEffect(puppet, t"BaseStatusEffect.ForceKill", player.GetEntityID());
    };
  }
}
