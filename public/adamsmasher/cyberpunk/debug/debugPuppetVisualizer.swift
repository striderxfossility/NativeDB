
public class DEBUG_VisualizerComponent extends ScriptableComponent {

  private let records: array<DEBUG_VisualRecord>;

  @default(DEBUG_VisualizerComponent, 0)
  private let offsetCounter: Int32;

  private let timeToNextUpdate: Float;

  private let processedRecordIndex: Int32;

  private let showWeaponsStreaming: Bool;

  @default(DEBUG_VisualizerComponent, 0.01f)
  private const let TICK_TIME_DELTA: Float;

  @default(DEBUG_VisualizerComponent, 3.f)
  private const let TEXT_SCALE_NAME: Float;

  @default(DEBUG_VisualizerComponent, 2.f)
  private const let TEXT_SCALE_ATTITUDE: Float;

  @default(DEBUG_VisualizerComponent, 1.f)
  private const let TEXT_SCALE_IMMORTALITY_MODE: Float;

  @default(DEBUG_VisualizerComponent, 2.3f)
  private const let TEXT_TOP: Float;

  @default(DEBUG_VisualizerComponent, 0.2f)
  private const let TEXT_OFFSET: Float;

  public final func VisualizePuppets(const pups: array<ref<ScriptedPuppet>>, infDuration: Bool, duration: Float) -> Void {
    let alreadyExists: Bool;
    let i: Int32;
    let j: Int32;
    let rec: DEBUG_VisualRecord;
    if ArraySize(pups) == 0 || !infDuration && duration <= 0.00 {
      return;
    };
    i = 0;
    while i < ArraySize(pups) {
      alreadyExists = false;
      j = 0;
      while j < ArraySize(this.records) {
        if this.records[j].puppet == pups[i] {
          this.records[j].infiniteDuration = infDuration;
          this.records[j].showDuration = duration;
          alreadyExists = true;
        } else {
          j += 1;
        };
      };
      if !alreadyExists {
        rec.puppet = pups[i];
        rec.infiniteDuration = infDuration;
        rec.showDuration = duration;
        ArrayPush(this.records, rec);
      };
      i += 1;
    };
    if !this.IsEnabled() {
      this.Toggle(true);
    };
  }

  private final func VisualizePuppetInternal(index: Int32) -> Void {
    this.offsetCounter = 0;
    this.processedRecordIndex = index;
    this.VisualizeDisplayName(this.TEXT_SCALE_NAME);
    this.VisualizeAttitude(this.TEXT_SCALE_ATTITUDE);
    this.VisualizeImmortality(this.TEXT_SCALE_IMMORTALITY_MODE);
  }

  public final func ClearPuppetVisualization() -> Void {
    let i: Int32 = ArraySize(this.records) - 1;
    while i >= 0 {
      this.ClearPuppet(i);
      i -= 1;
    };
  }

  private final func ClearPuppet(index: Int32) -> Void {
    let dvs: ref<DebugVisualizerSystem>;
    let i: Int32;
    if ArraySize(this.records) == 1 {
      this.Toggle(false);
    };
    dvs = GameInstance.GetDebugVisualizerSystem(this.GetOwner().GetGame());
    i = 0;
    while i < ArraySize(this.records[index].layerIDs) {
      dvs.ClearLayer(this.records[index].layerIDs[i]);
      i += 1;
    };
    ArrayErase(this.records, index);
  }

  private final func GetNextOffset() -> Vector4 {
    let offset: Vector4 = new Vector4(0.00, 0.00, this.TEXT_TOP - this.TEXT_OFFSET * Cast(this.offsetCounter), 0.00);
    this.offsetCounter += 1;
    return offset;
  }

  private final func VisualizeDisplayName(scale: Float) -> Void {
    this.ShowText(this.GetNextOffset(), this.records[this.processedRecordIndex].puppet.GetDisplayName(), new Color(255u, 255u, 0u, 255u), scale);
  }

  private final func VisualizeImmortality(scale: Float) -> Void {
    let color: Color;
    let str: String;
    let type: gameGodModeType;
    let hasImmortality: Bool = GetImmortality(this.records[this.processedRecordIndex].puppet, type);
    if !hasImmortality {
      str = StrUpper("No Immortality");
      color = new Color(255u, 0u, 0u, 255u);
    } else {
      str = "" + type;
      switch type {
        case gameGodModeType.Immortal:
          color = new Color(0u, 128u, 0u, 255u);
          break;
        case gameGodModeType.Invulnerable:
          color = new Color(0u, 255u, 0u, 255u);
          break;
        default:
      };
    };
    this.ShowText(this.GetNextOffset(), str, color, scale);
  }

  private final func VisualizeAttitude(scale: Float) -> Void {
    let attitudeColor: Color;
    let player: ref<PlayerPuppet> = GetPlayer(this.records[this.processedRecordIndex].puppet.GetGame());
    let attitude: EAIAttitude = GameObject.GetAttitudeBetween(player, this.records[this.processedRecordIndex].puppet);
    let attitudeStr: String = EnumValueToString("EAIAttitude", EnumInt(attitude));
    attitudeStr = StrUpper(StrReplace(attitudeStr, "AIA_", ""));
    switch attitude {
      case EAIAttitude.AIA_Hostile:
        attitudeColor = new Color(255u, 0u, 0u, 255u);
        break;
      case EAIAttitude.AIA_Neutral:
        attitudeColor = new Color(190u, 190u, 190u, 255u);
        break;
      case EAIAttitude.AIA_Friendly:
        attitudeColor = new Color(0u, 255u, 0u, 255u);
        break;
      default:
    };
    this.ShowText(this.GetNextOffset(), attitudeStr, attitudeColor, scale);
  }

  private final func ShowText(offset: Vector4, str: String, color: Color, scale: Float) -> Void {
    let dvs: ref<DebugVisualizerSystem> = GameInstance.GetDebugVisualizerSystem(this.records[this.processedRecordIndex].puppet.GetGame());
    let layerID: Uint32 = dvs.DrawText3D(this.records[this.processedRecordIndex].puppet.GetWorldPosition() + offset, str, color, MaxF(this.TICK_TIME_DELTA, 0.05));
    dvs.SetScale(layerID, new Vector4(scale, scale, scale, 0.00));
    ArrayPush(this.records[this.processedRecordIndex].layerIDs, layerID);
  }

  public final func OnGameAttach() -> Void {
    this.Toggle(false);
  }

  public final func OnUpdate(dt: Float) -> Void {
    let i: Int32;
    if this.timeToNextUpdate <= 0.00 {
      this.timeToNextUpdate = this.TICK_TIME_DELTA;
      i = ArraySize(this.records) - 1;
      while i >= 0 {
        if !this.records[i].infiniteDuration && this.records[i].showDuration <= 0.00 {
          this.ClearPuppet(i);
        } else {
          if !this.records[i].infiniteDuration {
            this.records[i].showDuration -= dt;
          };
          this.VisualizePuppetInternal(i);
        };
        i -= 1;
      };
    } else {
      this.timeToNextUpdate -= dt;
    };
  }

  public final func ToggleShowWeaponsStreaming() -> Void {
    this.showWeaponsStreaming = !this.showWeaponsStreaming;
  }

  public final func ShowEquipStartText(puppet: ref<gamePuppet>, slotID: TweakDBID, itemID: ItemID) -> Void {
    let itemRecord: ref<Item_Record>;
    let position: Vector4;
    if !this.showWeaponsStreaming || IsFinal() && !UseProfiler() {
      return;
    };
    if slotID != t"AttachmentSlots.WeaponRight" {
      return;
    };
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    position = puppet.GetWorldPosition();
    position.Z += 2.00;
    GameInstance.GetDebugVisualizerSystem(puppet.GetGame()).DrawText3D(position, itemRecord.FriendlyName(), new Color(255u, 0u, 0u, 255u), 5.00);
  }

  public final func ShowEquipEndText(puppet: ref<gamePuppet>, slotID: TweakDBID, itemID: ItemID) -> Void {
    let itemRecord: ref<Item_Record>;
    let position: Vector4;
    if !this.showWeaponsStreaming || IsFinal() && !UseProfiler() {
      return;
    };
    if slotID != t"AttachmentSlots.WeaponRight" {
      return;
    };
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    position = puppet.GetWorldPosition();
    position.Z += 2.50;
    GameInstance.GetDebugVisualizerSystem(puppet.GetGame()).DrawText3D(position, itemRecord.FriendlyName(), new Color(0u, 255u, 0u, 255u), 2.00);
  }
}
