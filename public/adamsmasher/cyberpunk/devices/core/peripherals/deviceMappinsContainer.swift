
public class DeviceMappinsContainer extends IScriptable {

  public let m_mappins: array<SDeviceMappinData>;

  public let m_newNewFocusMappin: SDeviceMappinData;

  public let m_useNewFocusMappin: Bool;

  @default(DeviceMappinsContainer, 0.2f)
  private let m_offsetValue: Float;

  public final func Initialize() -> Void {
    let mappin: SDeviceMappinData;
    mappin.mappinType = t"Mappins.DeviceMappinDefinition";
    mappin.enabled = false;
    mappin.active = false;
    mappin.range = 35.00;
    if !this.HasMappin(gamedataMappinVariant.NetrunnerVariant) {
      mappin.mappinVariant = gamedataMappinVariant.NetrunnerVariant;
      ArrayPush(this.m_mappins, mappin);
    };
    if !this.HasMappin(gamedataMappinVariant.NetrunnerAccessPointVariant) {
      mappin.mappinVariant = gamedataMappinVariant.NetrunnerAccessPointVariant;
      ArrayPush(this.m_mappins, mappin);
    };
    if !this.HasMappin(gamedataMappinVariant.TechieVariant) {
      mappin.mappinVariant = gamedataMappinVariant.TechieVariant;
      ArrayPush(this.m_mappins, mappin);
    };
    if !this.HasMappin(gamedataMappinVariant.SoloVariant) {
      mappin.mappinVariant = gamedataMappinVariant.SoloVariant;
      ArrayPush(this.m_mappins, mappin);
    };
    if this.m_useNewFocusMappin {
      mappin.mappinVariant = this.m_newNewFocusMappin.mappinVariant;
      mappin.enabled = true;
      ArrayPush(this.m_mappins, mappin);
    };
  }

  public final func HasNewFocusMappin() -> Bool {
    return this.m_useNewFocusMappin;
  }

  private final func EvaluatePositions(owner: ref<GameObject>) -> Void {
    let currentOffset: Vector4;
    let currentPos: Vector4;
    let i: Int32;
    let offsetValue: Float;
    let transform: WorldTransform;
    let direction: Int32 = 0;
    let rootPos: Vector4 = owner.GetPlaystyleMappinLocalPos();
    WorldTransform.SetPosition(transform, owner.GetWorldPosition());
    WorldTransform.SetOrientation(transform, owner.GetWorldOrientation());
    i = 0;
    while i < ArraySize(this.m_mappins) {
      if !this.m_mappins[i].enabled {
      } else {
        if direction != 0 {
          direction *= -1;
          offsetValue = this.m_offsetValue * Cast(direction);
        } else {
          if direction == 0 {
            offsetValue = 0.00;
            direction = 1;
          };
        };
        currentOffset = rootPos + this.m_mappins[i].offset;
        currentOffset.X = currentOffset.X + offsetValue;
        currentPos = WorldPosition.ToVector4(WorldTransform.TransformPoint(transform, currentOffset));
        this.m_mappins[i].position = currentPos;
        currentOffset = new Vector4(0.00, 0.00, 0.00, 0.00);
        currentPos = new Vector4(0.00, 0.00, 0.00, 0.00);
      };
      i += 1;
    };
  }

  private final func GetNextAxis(currentAxis: EAxisType) -> EAxisType {
    let axisValue: Int32;
    let nextAxis: EAxisType;
    if EnumInt(currentAxis) < 3 {
      axisValue += 1;
      nextAxis = IntEnum(axisValue);
    } else {
      nextAxis = IntEnum(0);
    };
    return nextAxis;
  }

  public final func ShowMappins(owner: ref<GameObject>) -> Void {
    let i: Int32;
    let mappinData: MappinData;
    let system: ref<MappinSystem>;
    this.EvaluatePositions(owner);
    i = 0;
    while i < ArraySize(this.m_mappins) {
      if this.m_mappins[i].enabled && !this.m_mappins[i].active {
        mappinData.mappinType = this.m_mappins[i].mappinType;
        mappinData.variant = this.m_mappins[i].mappinVariant;
        mappinData.active = true;
        mappinData.debugCaption = this.m_mappins[i].caption;
        system = GameInstance.GetMappinSystem(owner.GetGame());
        this.m_mappins[i].id = system.RegisterMappin(mappinData, this.m_mappins[i].position);
        this.m_mappins[i].active = true;
      };
      i += 1;
    };
  }

  public final func HideMappins(owner: ref<GameObject>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if this.m_mappins[i].active {
        this.HideSingleMappin(i, owner);
      };
      i += 1;
    };
  }

  private final func HideSingleMappin(index: Int32, owner: ref<GameObject>) -> Void {
    GameInstance.GetMappinSystem(owner.GetGame()).UnregisterMappin(this.m_mappins[index].id);
    this.m_mappins[index].active = false;
  }

  private final func HasMappin(mappinVariant: gamedataMappinVariant) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, mappinVariant) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func HasMappin(data: SDeviceMappinData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, data.mappinVariant) && this.m_mappins[i].mappinType == data.mappinType && Equals(this.m_mappins[i].caption, data.caption) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func ToggleMappin(owner: ref<GameObject>, mappinVariant: gamedataMappinVariant, enable: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, mappinVariant) {
        this.m_mappins[i].enabled = enable;
        if !enable {
          if this.m_mappins[i].active {
            this.HideSingleMappin(i, owner);
          };
        };
      };
      i += 1;
    };
  }

  public final func AddMappin(data: SDeviceMappinData) -> Void {
    if !this.HasMappin(data) {
      ArrayPush(this.m_mappins, data);
    };
  }
}
