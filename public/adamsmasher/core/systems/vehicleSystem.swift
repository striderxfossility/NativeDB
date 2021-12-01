
public native class VehicleSystem extends IVehicleSystem {

  private let m_restrictionTags: array<CName>;

  public final native func SpawnPlayerVehicle(opt vehicleType: gamedataVehicleType) -> Void;

  public final native func ToggleSummonMode() -> Void;

  public final native func DespawnPlayerVehicle(vehicleID: GarageVehicleID) -> Void;

  public final native func EnablePlayerVehicle(vehicle: String, enable: Bool, opt despawnIfDisabling: Bool) -> Bool;

  public final native func EnableAllPlayerVehicles() -> Void;

  public final native func GetPlayerVehicles(out vehicles: array<PlayerVehicle>) -> Void;

  public final native func GetPlayerUnlockedVehicles(out unlockedVehicles: array<PlayerVehicle>) -> Void;

  public final native func TogglePlayerActiveVehicle(vehicleID: GarageVehicleID, vehicleType: gamedataVehicleType, enable: Bool) -> Void;

  public final native func EnablePlayerVehicleCollision() -> Void;

  public final const func GetVehicleRestrictions() -> array<CName> {
    return this.m_restrictionTags;
  }

  protected final func OnVehicleSystemAttach() -> Void {
    PlayerGameplayRestrictions.AcquireHotkeyRestrictionTags(EHotkey.DPAD_RIGHT, this.m_restrictionTags);
  }

  public final static func IsSummoningVehiclesRestricted(game: GameInstance) -> Bool {
    let blackboard: ref<IBlackboard>;
    let gameplayRestricted: Bool;
    let garageReady: Bool;
    let garageState: Uint32;
    let isPlayerInVehicle: Bool;
    let questRestricted: Bool;
    let restrictions: array<CName>;
    let unlockedVehicles: array<PlayerVehicle>;
    let player: ref<PlayerPuppet> = GetPlayer(game);
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(player, n"CustomVehicleSummon") {
      return false;
    };
    questRestricted = GameInstance.GetQuestsSystem(game).GetFact(n"unlock_car_hud_dpad") == 0;
    if questRestricted {
      return true;
    };
    blackboard = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().VehicleSummonData);
    garageState = blackboard.GetUint(GetAllBlackboardDefs().VehicleSummonData.GarageState);
    garageReady = Equals(IntEnum(garageState), vehicleGarageState.SummonAvailable);
    isPlayerInVehicle = player.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle);
    GameInstance.GetVehicleSystem(game).GetPlayerUnlockedVehicles(unlockedVehicles);
    if !garageReady || ArraySize(unlockedVehicles) == 0 || isPlayerInVehicle {
      return true;
    };
    restrictions = GameInstance.GetVehicleSystem(game).GetVehicleRestrictions();
    if ArraySize(restrictions) > 0 {
      gameplayRestricted = StatusEffectSystem.ObjectHasStatusEffectWithTags(player, restrictions);
    } else {
      gameplayRestricted = PlayerGameplayRestrictions.IsHotkeyRestricted(game, EHotkey.DPAD_RIGHT);
    };
    return gameplayRestricted;
  }
}

public static exec func DespawnPlayerVehicle(inst: GameInstance, vehicleID: String) -> Void {
  GameInstance.GetVehicleSystem(inst).DespawnPlayerVehicle(GarageVehicleID.Resolve(vehicleID));
}

public static exec func EnableAllPlayerVehicles(inst: GameInstance) -> Void {
  GameInstance.GetVehicleSystem(inst).EnableAllPlayerVehicles();
}
