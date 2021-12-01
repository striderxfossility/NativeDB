
public native class TweakDBIDSelector extends IScriptable {

  public native let baseTweakID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.baseTweakID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.baseTweakID = recordID;
  }
}

public abstract class LCDScreenSelector extends TweakDBIDSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;ScreenMessageData")
  protected persistent let m_customMessageID: TweakDBID;

  @default(NumberPlateSelector, true)
  protected let m_replaceTextWithCustomNumber: Bool;

  protected let m_customNumber: Int32;

  public final const func GetCustomMessageID() -> TweakDBID {
    return this.m_customMessageID;
  }

  public final const func HasCustomNumber() -> Bool {
    return this.m_replaceTextWithCustomNumber;
  }

  public final const func GetCustomNumber() -> Int32 {
    return this.m_customNumber;
  }
}

public class CityFluffScreenSelector extends LCDScreenSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;LCDScreen")
  private let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public class NumberPlateSelector extends LCDScreenSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;NumberPlate")
  private let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public class GenericStreetSignSelector extends StreetSignSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;StreetSign")
  private let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public class StreetNameSelector extends StreetSignSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;GenericStreetNameSign")
  private let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public class MetroSignSelector extends StreetSignSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;GenericMetroSign")
  private let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public class HighwaySignSelector extends StreetSignSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;GenericHighwaySign")
  private let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public class RaceCheckpointSelector extends StreetSignSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;RaceCheckpoint")
  private let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public abstract class ScreenMessageSelector extends TweakDBIDSelector {

  protected let m_replaceTextWithCustomNumber: Bool;

  protected let m_customNumber: Int32;

  public final const func HasCustomNumber() -> Bool {
    return this.m_replaceTextWithCustomNumber;
  }

  public final const func GetCustomNumber() -> Int32 {
    return this.m_customNumber;
  }

  public final func SetCustomNumber(value: Int32) -> Void {
    this.m_customNumber = value;
  }

  public final func SetReplaceTextWithCustomNumber(value: Bool) -> Void {
    this.m_replaceTextWithCustomNumber = value;
  }
}

public class CityFluffMessageSelector extends ScreenMessageSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;CityFluffScreenMessages.ScreenMessageData")
  private persistent let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}

public class QuestMessageSelector extends ScreenMessageSelector {

  @attrib(customEditor, "TweakDBGroupInheritance;QuestScreenMessages.ScreenMessageData")
  private persistent let m_recordID: TweakDBID;

  public const func GetRecordID() -> TweakDBID {
    return this.m_recordID;
  }

  public func SetRecordID(recordID: TweakDBID) -> Void {
    this.m_recordID = recordID;
  }
}
