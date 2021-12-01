
public class ScannerChunk extends IScriptable {

  public func GetType() -> ScannerDataType {
    return IntEnum(0l);
  }

  public const func IsValid() -> Bool {
    return true;
  }
}

public struct BountyUI {

  public let issuedBy: String;

  public let moneyReward: Int32;

  public let streetCredReward: Int32;

  public let transgressions: array<String>;

  public let hasAccess: Bool;

  public let level: Int32;

  public final static func AddTransgression(self: BountyUI, transgression: String) -> Void {
    ArrayPush(self.transgressions, transgression);
  }
}

public class ScannerBountySystem extends ScannerChunk {

  private let bounty: BountyUI;

  public final const func GetBounty() -> BountyUI {
    return this.bounty;
  }

  public final func Set(b: BountyUI) -> Void {
    this.bounty = b;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.BountySystem;
  }
}

public class ScannerName extends ScannerChunk {

  @default(ScannerName, LocKey#42211)
  private let displayName: String;

  private let hasArchetype: Bool;

  private let textParams: ref<inkTextParams>;

  public final const func GetDisplayName() -> String {
    return this.displayName;
  }

  public final const func GetTextParams() -> ref<inkTextParams> {
    return this.textParams;
  }

  public final func Set(_displayName: String) -> Void {
    this.displayName = _displayName;
  }

  public final func SetTextParams(_params: ref<inkTextParams>) -> Void {
    this.textParams = _params;
  }

  public final func SetArchetype(has: Bool) -> Void {
    this.hasArchetype = has;
  }

  public final func HasArchetype() -> Bool {
    return this.hasArchetype;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Name;
  }
}

public class ScannerLevel extends ScannerChunk {

  private let level: Int32;

  private let isHard: Bool;

  public final const func GetLevel() -> Int32 {
    return this.level;
  }

  public final const func GetIndicator() -> Bool {
    return this.isHard;
  }

  public final func Set(value: Int32) -> Void {
    this.level = value;
  }

  public final func SetIndicator(value: Bool) -> Void {
    this.isHard = value;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Level;
  }
}

public class ScannerRarity extends ScannerChunk {

  private let rarity: gamedataNPCRarity;

  private let isCivilian: Bool;

  public final const func GetRarity() -> gamedataNPCRarity {
    return this.rarity;
  }

  public final const func IsCivilian() -> Bool {
    return this.isCivilian;
  }

  public final func Set(r: gamedataNPCRarity, civilian: Bool) -> Void {
    this.rarity = r;
    this.isCivilian = civilian;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Rarity;
  }
}

public class ScannerArchetype extends ScannerChunk {

  private let archetype: gamedataArchetypeType;

  public final const func GetArchtype() -> gamedataArchetypeType {
    return this.archetype;
  }

  public final func Set(a: gamedataArchetypeType) -> Void {
    this.archetype = a;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Rarity;
  }
}

public class ScannerWeaponBasic extends ScannerChunk {

  protected let weapon: CName;

  public final const func GetWeapon() -> CName {
    return this.weapon;
  }

  public final func Set(displayName: CName) -> Void {
    this.weapon = displayName;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.WeaponBasic;
  }
}

public class ScannerWeaponDetailed extends ScannerWeaponBasic {

  private let damage: CName;

  public final const func GetDamage() -> CName {
    return this.damage;
  }

  public final func Set(displayName: CName, displayDamage: CName) -> Void {
    this.weapon = displayName;
    this.damage = displayDamage;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.WeaponDetailed;
  }
}

public class ScannerHealth extends ScannerChunk {

  private let currentHealth: Int32;

  private let totalHealth: Int32;

  public final const func GetCurrentHealth() -> Int32 {
    return this.currentHealth;
  }

  public final const func GetTotalHealth() -> Int32 {
    return this.totalHealth;
  }

  public final func Set(current: Int32, total: Int32) -> Void {
    this.currentHealth = current;
    this.totalHealth = total;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Health;
  }
}

public class ScannerVulnerabilities extends ScannerChunk {

  private let vulnerabilities: array<Vulnerability>;

  public final const func GetVulnerabilities() -> array<Vulnerability> {
    return this.vulnerabilities;
  }

  public const func IsValid() -> Bool {
    return ArraySize(this.vulnerabilities) > 0;
  }

  public final func Set(vuln: array<Vulnerability>) -> Void {
    this.vulnerabilities = vuln;
  }

  public final func PushBack(vuln: Vulnerability) -> Void {
    ArrayPush(this.vulnerabilities, vuln);
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Vulnerabilities;
  }
}

public class ScannerFaction extends ScannerChunk {

  public let faction: String;

  public final const func GetFaction() -> String {
    return this.faction;
  }

  public final func Set(f: String) -> Void {
    this.faction = f;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Faction;
  }
}

public class ScannerSquadInfo extends ScannerChunk {

  public let numberOfSquadMembers: Int32;

  public func GetType() -> ScannerDataType {
    return ScannerDataType.SquadInfo;
  }
}

public class ScannerResistances extends ScannerChunk {

  public let resists: array<ScannerStatDetails>;

  public final const func GetResistances() -> array<ScannerStatDetails> {
    return this.resists;
  }

  public final func Set(r: array<ScannerStatDetails>) -> Void {
    this.resists = r;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Resistances;
  }
}

public class ScannerAbilities extends ScannerChunk {

  public let abilities: array<wref<GameplayAbility_Record>>;

  public final const func GetAbilities() -> array<wref<GameplayAbility_Record>> {
    return this.abilities;
  }

  public final func Set(a: array<wref<GameplayAbility_Record>>) -> Void {
    this.abilities = a;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Abilities;
  }
}

public class ScannerAttitude extends ScannerChunk {

  private let attitude: EAIAttitude;

  public final const func GetAttitude() -> EAIAttitude {
    return this.attitude;
  }

  public final func Set(att: EAIAttitude) -> Void {
    this.attitude = att;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Attitude;
  }
}

public class ScannerDeviceStatus extends ScannerChunk {

  private let deviceStatus: String;

  private let deviceStatusFriendlyName: String;

  public final const func GetDeviceStatus() -> String {
    return this.deviceStatus;
  }

  public final const func GetDeviceStatusFriendlyName() -> String {
    return this.deviceStatusFriendlyName;
  }

  public final func Set(status: String) -> Void {
    this.deviceStatus = status;
  }

  public final func SetFriendlyName(status: String) -> Void {
    this.deviceStatusFriendlyName = status;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.DeviceStatus;
  }
}

public class ScannerNetworkLevel extends ScannerChunk {

  private let networkLevel: Int32;

  public final const func GetNetworkLevel() -> Int32 {
    return this.networkLevel;
  }

  public final func Set(level: Int32) -> Void {
    this.networkLevel = level;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.NetworkLevel;
  }
}

public class ScannerNetworkStatus extends ScannerChunk {

  private let networkStatus: ScannerNetworkState;

  public final const func GetNetworkStatus() -> ScannerNetworkState {
    return this.networkStatus;
  }

  public final func Set(status: ScannerNetworkState) -> Void {
    this.networkStatus = status;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.NetworkStatus;
  }
}

public class ScannerAuthorization extends ScannerChunk {

  private let keycard: Bool;

  private let password: Bool;

  public final const func ProtectedByKeycard() -> Bool {
    return this.keycard;
  }

  public final const func ProtectedByPassword() -> Bool {
    return this.password;
  }

  public final func Set(key: Bool, pass: Bool) -> Void {
    this.keycard = key;
    this.password = pass;
  }
}

public class ScannerDescription extends ScannerChunk {

  private let defaultFluffDescription: String;

  private let customDescriptions: array<String>;

  public final const func GetDefaultDescription() -> String {
    return this.defaultFluffDescription;
  }

  public final const func GetCustomDescriptions() -> array<String> {
    return this.customDescriptions;
  }

  public final func Set(defaultDesc: String, opt customDesc: array<String>) -> Void {
    this.defaultFluffDescription = defaultDesc;
    if ArraySize(customDesc) > 0 {
      this.customDescriptions = customDesc;
    };
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Description;
  }
}

public class ScannerSkillchecks extends ScannerChunk {

  private let skillchecks: array<UIInteractionSkillCheck>;

  private let authorizationRequired: Bool;

  private let isPlayerAuthorized: Bool;

  public final const func GetSkillchecks() -> array<UIInteractionSkillCheck> {
    return this.skillchecks;
  }

  public final const func GetAuthorization() -> Bool {
    return this.authorizationRequired;
  }

  public final const func GetPlayerAuthorization() -> Bool {
    return this.isPlayerAuthorized;
  }

  public final func Set(sklchs: array<UIInteractionSkillCheck>) -> Void {
    this.skillchecks = sklchs;
  }

  public final func SetAuthorization(auth: Bool) -> Void {
    this.authorizationRequired = auth;
  }

  public final func SetPlayerAuthorization(auth: Bool) -> Void {
    this.isPlayerAuthorized = auth;
  }

  public const func IsValid() -> Bool {
    return ArraySize(this.skillchecks) > 0;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.Requirements;
  }
}

public class ScannerConnections extends ScannerChunk {

  private let deviceConnections: array<DeviceConnectionScannerData>;

  public final const func GetConnections() -> array<DeviceConnectionScannerData> {
    return this.deviceConnections;
  }

  public const func IsValid() -> Bool {
    return ArraySize(this.deviceConnections) > 0;
  }

  public final func Set(connections: array<DeviceConnectionScannerData>) -> Void {
    this.deviceConnections = connections;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.DeviceConnections;
  }
}

public class ScannerVehicleName extends ScannerChunk {

  private let vehicleName: String;

  public final const func GetDisplayName() -> String {
    return this.vehicleName;
  }

  public final func Set(vehName: String) -> Void {
    this.vehicleName = vehName;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleName;
  }
}

public class ScannerVehicleManufacturer extends ScannerChunk {

  private let vehicleManufacturer: String;

  public final const func GetVehicleManufacturer() -> String {
    return this.vehicleManufacturer;
  }

  public final func Set(vehManName: String) -> Void {
    this.vehicleManufacturer = vehManName;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleManufacturer;
  }
}

public class ScannerVehicleProdYears extends ScannerChunk {

  private let vehicleProdYears: String;

  public final const func GetProdYears() -> String {
    return this.vehicleProdYears;
  }

  public final func Set(vehProdYears: String) -> Void {
    this.vehicleProdYears = vehProdYears;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleProductionYears;
  }
}

public class ScannerVehicleDriveLayout extends ScannerChunk {

  private let vehicleDriveLayout: String;

  public final const func GetDriveLayout() -> String {
    return this.vehicleDriveLayout;
  }

  public final func Set(vehDriveLayout: String) -> Void {
    this.vehicleDriveLayout = vehDriveLayout;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleDriveLayout;
  }
}

public class ScannerVehicleHorsepower extends ScannerChunk {

  private let horsepower: Int32;

  public final const func GetHorsepower() -> Int32 {
    return this.horsepower;
  }

  public const func IsValid() -> Bool {
    return this.horsepower > 0;
  }

  public final func Set(hp: Int32) -> Void {
    this.horsepower = hp;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleHorsepower;
  }
}

public class ScannerVehicleMass extends ScannerChunk {

  private let mass: Int32;

  public final const func GetMass() -> Int32 {
    return this.mass;
  }

  public const func IsValid() -> Bool {
    return this.mass > 0;
  }

  public final func Set(vehMass: Int32) -> Void {
    this.mass = vehMass;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleMass;
  }
}

public class ScannerVehicleState extends ScannerChunk {

  private let vehicleState: String;

  public final const func GetVehicleState() -> String {
    return this.vehicleState;
  }

  public final func Set(vehState: String) -> Void {
    this.vehicleState = vehState;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleState;
  }
}

public class ScannerVehicleInfo extends ScannerChunk {

  private let vehicleInfo: String;

  public final const func GetVehicleInfo() -> String {
    return this.vehicleInfo;
  }

  public final func Set(vehInfo: String) -> Void {
    this.vehicleInfo = vehInfo;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.VehicleInfo;
  }
}

public class ScannerQuickHackDescription extends ScannerChunk {

  private let QuickHackDescription: ref<QuickhackData>;

  public final const func GetCurrrentQuickHackData() -> ref<QuickhackData> {
    return this.QuickHackDescription;
  }

  public final func Set(vehInfo: ref<QuickhackData>) -> Void {
    this.QuickHackDescription = vehInfo;
  }

  public func GetType() -> ScannerDataType {
    return ScannerDataType.QuickHackDescription;
  }
}
