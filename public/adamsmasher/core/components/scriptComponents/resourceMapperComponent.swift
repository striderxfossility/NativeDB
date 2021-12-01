
public class AreaEffectData extends IScriptable {

  public inline let action: ref<ScriptableDeviceAction>;

  @attrib(customEditor, "TweakDBGroupInheritance;ObjectAction")
  public inline let actionRecordID: TweakDBID;

  public let areaEffectID: CName;

  @attrib(category, "VFX Data")
  @default(AreaEffectData, focus_10m)
  public let indicatorEffectName: CName;

  @attrib(category, "VFX Data")
  @default(AreaEffectData, false)
  public let useIndicatorEffect: Bool;

  @attrib(rangeMax, "1.f")
  @attrib(category, "VFX Data")
  @attrib(rangeMin, "0.f")
  @default(AreaEffectData, 1.f)
  public let indicatorEffectSize: Float;

  @attrib(category, "Stim Data")
  @default(AreaEffectData, 10.f)
  public let stimRange: Float;

  @attrib(category, "Stim Data")
  @default(AreaEffectData, 3.f)
  public let stimLifetime: Float;

  @attrib(category, "Stim Data")
  @default(AreaEffectData, DeviceStimType.Distract)
  public let stimType: DeviceStimType;

  @attrib(category, "Stim Data")
  public let stimSource: NodeRef;

  @attrib(category, "Stim Data")
  public let additionaStimSources: array<NodeRef>;

  @attrib(category, "Stim Data")
  public let investigateSpot: NodeRef;

  @attrib(category, "Stim Data")
  public let investigateController: Bool;

  @attrib(category, "Stim Data")
  public let controllerSource: NodeRef;

  @attrib(category, "Highlight Data")
  @default(AreaEffectData, true)
  public let highlightTargets: Bool;

  @attrib(category, "Highlight Data")
  @default(AreaEffectData, EFocusForcedHighlightType.INVALID)
  public let highlightType: EFocusForcedHighlightType;

  @attrib(category, "Highlight Data")
  @default(AreaEffectData, EFocusOutlineType.DISTRACTION)
  public let outlineType: EFocusOutlineType;

  @attrib(category, "Highlight Data")
  @default(AreaEffectData, EPriority.High)
  public let highlightPriority: EPriority;

  public let effectInstance: ref<EffectInstance>;

  public let gameEffectOverrideName: CName;

  public final func EffectInstanceClear() -> Void {
    this.effectInstance = null;
  }

  public final func SetEffectInstance(effect: ref<EffectInstance>) -> Void {
    this.effectInstance = effect;
  }

  public final const func GetActionRecord() -> wref<ObjectAction_Record> {
    return TweakDBInterface.GetObjectActionRecord(this.actionRecordID);
  }

  private final const func GetActionNameFromRecord(record: wref<ObjectAction_Record>) -> CName {
    if record != null {
      return record.ActionName();
    };
    return n"";
  }

  public final const func GetActionNameFromRecord() -> CName {
    return this.GetActionNameFromRecord(this.GetActionRecord());
  }

  public final const func IsMatching(_action: ref<BaseScriptableAction>) -> Bool {
    if !IsDefined(_action) {
      return false;
    };
    if TDBID.IsValid(this.actionRecordID) && _action.GetObjectActionID() == this.actionRecordID {
      return true;
    };
    if IsDefined(this.action) && Equals(this.action.GetClassName(), _action.GetClassName()) {
      return true;
    };
    if Equals(this.areaEffectID, _action.GetClassName()) {
      return true;
    };
    if TDBID.IsValid(this.actionRecordID) && Equals(this.areaEffectID, _action.GetObjectActionRecord().ActionName()) {
      return true;
    };
    return false;
  }
}

public class FxResourceMapperComponent extends ScriptableComponent {

  @attrib(category, "Area effects - OBSOLETE USE ONLY TO CORRECT DATA OF EXISTING EFFECTS")
  protected let m_areaEffectsData: array<SAreaEffectData>;

  @attrib(category, "Area effects - OBSOLETE USE ONLY TO CORRECT DATA OF EXISTING EFFECTS")
  protected let m_areaEffectsInFocusMode: array<SAreaEffectTargetData>;

  @attrib(category, "Area effects - DEFINE NEW EFFECTS HERE")
  protected inline let m_areaEffectData: array<ref<AreaEffectData>>;

  @attrib(category, "Area effects - DEFINE NEW EFFECTS HERE")
  @default(FxResourceMapperComponent, 1.0f)
  protected inline let m_investigationSlotOffsetMultiplier: Float;

  @attrib(category, "Area effects - DEFINE NEW EFFECTS HERE")
  protected inline let m_areaEffectInFocusMode: array<ref<AreaEffectTargetData>>;

  private let DEBUG_copiedDataFromEntity: Bool;

  private let DEBUG_copiedDataFromFXStruct: Bool;

  public final func CopyDataToFxMapClass(areaEffectsData: array<SAreaEffectData>, DEBUG_entityCopy: Bool, DEBUG_fxCopy: Bool) -> Void {
    let areaEffectDataClass: ref<AreaEffectData>;
    let i: Int32;
    let i2: Int32;
    if ArraySize(this.m_areaEffectData) > 0 {
      return;
    };
    i = 0;
    while i < ArraySize(areaEffectsData) {
      areaEffectDataClass = new AreaEffectData();
      areaEffectDataClass.action = areaEffectsData[i].action;
      areaEffectDataClass.areaEffectID = areaEffectsData[i].areaEffectID;
      areaEffectDataClass.indicatorEffectName = areaEffectsData[i].indicatorEffectName;
      areaEffectDataClass.useIndicatorEffect = areaEffectsData[i].useIndicatorEffect;
      areaEffectDataClass.indicatorEffectSize = areaEffectsData[i].indicatorEffectSize;
      areaEffectDataClass.stimRange = areaEffectsData[i].stimRange;
      areaEffectDataClass.stimLifetime = areaEffectsData[i].stimLifetime;
      areaEffectDataClass.stimType = areaEffectsData[i].stimType;
      areaEffectDataClass.stimSource = areaEffectsData[i].stimSource;
      i2 = 0;
      while i < ArraySize(areaEffectsData[i].additionaStimSources) {
        ArrayPush(areaEffectDataClass.additionaStimSources, areaEffectsData[i].additionaStimSources[i2]);
        i2 += 1;
      };
      areaEffectDataClass.investigateSpot = areaEffectsData[i].investigateSpot;
      areaEffectDataClass.investigateController = areaEffectsData[i].investigateController;
      areaEffectDataClass.controllerSource = areaEffectsData[i].controllerSource;
      areaEffectDataClass.highlightTargets = areaEffectsData[i].highlightTargets;
      areaEffectDataClass.highlightType = areaEffectsData[i].highlightType;
      areaEffectDataClass.highlightPriority = areaEffectsData[i].highlightPriority;
      areaEffectDataClass.effectInstance = areaEffectsData[i].effectInstance;
      ArrayPush(this.m_areaEffectData, areaEffectDataClass);
      if DEBUG_entityCopy {
        this.DEBUG_copiedDataFromEntity = DEBUG_entityCopy;
      };
      if DEBUG_fxCopy {
        this.DEBUG_copiedDataFromFXStruct = DEBUG_fxCopy;
      };
      i += 1;
    };
  }

  public final func CopyEffectToFxMapClass(areaEffectsInFocusMode: array<SAreaEffectTargetData>) -> Void {
    let effctDataClass: ref<AreaEffectTargetData>;
    let i: Int32;
    if ArraySize(this.m_areaEffectInFocusMode) > 0 {
      return;
    };
    i = 0;
    while i < ArraySize(areaEffectsInFocusMode) {
      effctDataClass = new AreaEffectTargetData();
      effctDataClass.areaEffectID = areaEffectsInFocusMode[i].areaEffectID;
      effctDataClass.onSelf = areaEffectsInFocusMode[i].onSelf;
      effctDataClass.onSlaves = areaEffectsInFocusMode[i].onSlaves;
      ArrayPush(this.m_areaEffectInFocusMode, effctDataClass);
      i += 1;
    };
  }

  public final const func GetInvestigationSlotOffset() -> Float {
    return this.m_investigationSlotOffsetMultiplier;
  }

  public final const func GetAreaEffectData() -> array<ref<AreaEffectData>> {
    return this.m_areaEffectData;
  }

  public final const func GetAreaEffectDataByIndex(index: Int32) -> ref<AreaEffectData> {
    return this.m_areaEffectData[index];
  }

  public final const func GetAreaEffectDataSize() -> Int32 {
    return ArraySize(this.m_areaEffectData);
  }

  public final const func GetAreaEffectInFocusMode() -> array<ref<AreaEffectTargetData>> {
    return this.m_areaEffectInFocusMode;
  }

  public final const func GetAreaEffectInFocusModeByIndex(index: Int32) -> ref<AreaEffectTargetData> {
    return this.m_areaEffectInFocusMode[index];
  }

  public final const func GetAreaEffectInFocusSize() -> Int32 {
    return ArraySize(this.m_areaEffectInFocusMode);
  }

  public final const func HasAnyDistractions() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaEffectData) {
      if Equals(this.m_areaEffectData[i].stimType, DeviceStimType.Distract) || Equals(this.m_areaEffectData[i].stimType, DeviceStimType.VisualDistract) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func CreateEffectStructDataFromAttack(attackTDBID: TweakDBID, index: Int32, opt gameEffectNameOverride: CName, opt dontHighlightOnLookat: Bool) -> Void {
    this.CreateData(attackTDBID, index, gameEffectNameOverride, dontHighlightOnLookat);
  }

  private final func CreateData(attackTDBID: TweakDBID, index: Int32, opt gameEffectNameOverride: CName, opt dontHighlightOnLookat: Bool) -> Void {
    let effectData: ref<AreaEffectData> = new AreaEffectData();
    let distractForEffectData: ref<AreaEffectData> = new AreaEffectData();
    let effectRange: Float = TweakDBInterface.GetAttackRecord(attackTDBID).Range();
    effectData.areaEffectID = StringToName("hardCodeDoNotRemove" + index);
    effectData.stimRange = effectRange;
    effectData.highlightTargets = true;
    effectData.highlightType = EFocusForcedHighlightType.INVALID;
    effectData.outlineType = EFocusOutlineType.AOE;
    effectData.highlightPriority = EPriority.Medium;
    effectData.stimType = IntEnum(4l);
    effectData.indicatorEffectName = n"";
    effectData.gameEffectOverrideName = gameEffectNameOverride;
    ArrayPush(this.m_areaEffectData, effectData);
    if !dontHighlightOnLookat {
      this.CreateAreaEffectTargetData(effectData);
    };
    distractForEffectData.areaEffectID = StringToName("hardCodeDoNotRemoveExplosion" + index);
    this.CalculateRangeSphere(effectRange * 3.00, distractForEffectData.indicatorEffectName, distractForEffectData.indicatorEffectSize);
    distractForEffectData.stimRange = effectRange * 3.00;
    distractForEffectData.highlightTargets = false;
    distractForEffectData.stimType = DeviceStimType.Explosion;
    ArrayPush(this.m_areaEffectData, distractForEffectData);
    if !dontHighlightOnLookat {
      this.CreateAreaEffectTargetData(distractForEffectData);
    };
  }

  private final func CalculateRangeSphere(desiredRange: Float, out effectName: CName, out effectSize: Float) -> Void {
    if desiredRange <= 5.00 {
      effectName = n"focus_5m";
      effectSize = desiredRange / 5.00;
    } else {
      if desiredRange <= 10.00 {
        effectName = n"focus_10m";
        effectSize = desiredRange / 10.00;
      } else {
        if desiredRange <= 20.00 {
          effectName = n"focus_20m";
          effectSize = desiredRange / 20.00;
        } else {
          if desiredRange <= 30.00 {
            effectName = n"focus_30m";
            effectSize = desiredRange / 30.00;
          };
        };
      };
    };
  }

  protected final func CreateAreaEffectTargetData(mainEffect: ref<AreaEffectData>) -> Void {
    let data: ref<AreaEffectTargetData> = new AreaEffectTargetData();
    data.areaEffectID = mainEffect.areaEffectID;
    data.onSelf = true;
    ArrayPush(this.m_areaEffectInFocusMode, data);
  }

  public final const func GetAreaEffectDataIndexByName(effectName: CName) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaEffectData) {
      if this.m_areaEffectData[i].action != null && Equals(this.m_areaEffectData[i].action.GetClassName(), effectName) {
        return i;
      };
      if IsNameValid(effectName) && Equals(this.m_areaEffectData[i].areaEffectID, effectName) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final const func GetAreaEffectDataIndexByAction(action: ref<BaseScriptableAction>) -> Int32 {
    let i: Int32;
    if !IsDefined(action) {
      return -1;
    };
    i = 0;
    while i < ArraySize(this.m_areaEffectData) {
      if this.m_areaEffectData[i].IsMatching(action) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final const func GetAreaEffectDataNameByIndex(effectIndex: Int32) -> CName {
    if effectIndex < 0 || effectIndex >= ArraySize(this.m_areaEffectData) {
      return n"";
    };
    if TDBID.IsValid(this.m_areaEffectData[effectIndex].actionRecordID) {
      return this.m_areaEffectData[effectIndex].GetActionNameFromRecord();
    };
    if this.m_areaEffectData[effectIndex].action != null {
      return this.m_areaEffectData[effectIndex].action.GetClassName();
    };
    return this.m_areaEffectData[effectIndex].areaEffectID;
  }

  public final const func GetDistractionRange(type: DeviceStimType) -> Float {
    let currentRange: Float;
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaEffectData) {
      if Equals(type, DeviceStimType.Distract) || Equals(type, DeviceStimType.VisualDistract) {
        if Equals(this.m_areaEffectData[i].stimType, DeviceStimType.Distract) || Equals(this.m_areaEffectData[i].stimType, DeviceStimType.VisualDistract) {
          if this.m_areaEffectData[i].stimRange > currentRange {
            currentRange = this.m_areaEffectData[i].stimRange;
          };
        };
      } else {
        if Equals(type, this.m_areaEffectData[i].stimType) {
          if this.m_areaEffectData[i].stimRange > currentRange {
            currentRange = this.m_areaEffectData[i].stimRange;
          };
        };
      };
      i += 1;
    };
    return currentRange;
  }

  public final const func GetSmallestDistractionRange(type: DeviceStimType) -> Float {
    let currentRange: Float;
    let i: Int32 = 0;
    while i < ArraySize(this.m_areaEffectData) {
      if Equals(type, DeviceStimType.Distract) || Equals(type, DeviceStimType.VisualDistract) {
        if Equals(this.m_areaEffectData[i].stimType, DeviceStimType.Distract) || Equals(this.m_areaEffectData[i].stimType, DeviceStimType.VisualDistract) {
          if this.m_areaEffectData[i].stimRange < currentRange {
            currentRange = this.m_areaEffectData[i].stimRange;
          };
        };
      } else {
        if Equals(type, this.m_areaEffectData[i].stimType) {
          if this.m_areaEffectData[i].stimRange < currentRange {
            currentRange = this.m_areaEffectData[i].stimRange;
          };
        };
      };
      i += 1;
    };
    return currentRange;
  }
}
