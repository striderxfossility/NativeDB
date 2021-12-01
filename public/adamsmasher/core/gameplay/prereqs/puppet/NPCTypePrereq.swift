
public class NPCTypePrereq extends IScriptablePrereq {

  public let m_allowedTypes: array<gamedataNPCType>;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let allowedTypeItem: wref<NPCType_Record>;
    let prereqRecord: ref<NPCTypePrereq_Record> = TweakDBInterface.GetNPCTypePrereqRecord(recordID);
    let i: Int32 = 0;
    while i < prereqRecord.GetAllowedTypesCount() {
      allowedTypeItem = prereqRecord.GetAllowedTypesItem(i);
      ArrayPush(this.m_allowedTypes, allowedTypeItem.Type());
      i += 1;
    };
    this.m_invert = prereqRecord.Invert();
  }

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    state.OnChanged(this.IsFulfilled(game, context));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject> = context as GameObject;
    let targetPuppet: ref<ScriptedPuppet> = owner as ScriptedPuppet;
    let targetType: gamedataNPCType = targetPuppet.GetNPCType();
    if !ArrayContains(this.m_allowedTypes, targetType) {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}

public class NPCIsChildPrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let targetPuppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    let isChild: Bool = targetPuppet.GetRecord().IsChild();
    return this.m_invert ? !isChild : isChild;
  }
}

public class NPCIsCrowdPrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let targetPuppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    let isCrowd: Bool = targetPuppet.GetRecord().IsCrowd();
    return this.m_invert ? !isCrowd : isCrowd;
  }
}
