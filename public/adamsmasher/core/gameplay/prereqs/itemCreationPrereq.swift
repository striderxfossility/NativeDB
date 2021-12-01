
public class ItemCreationPrereq extends IScriptablePrereq {

  public let m_fireAndForget: Bool;

  public edit let m_statType: gamedataStatType;

  public edit let m_valueToCheck: Float;

  public edit let m_comparisonType: EComparisonType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let record: ref<ItemCreationPrereq_Record> = TweakDBInterface.GetItemCreationPrereqRecord(recordID);
    this.m_statType = IntEnum(Cast(EnumValueFromName(n"gamedataStatType", record.StatType())));
    this.m_valueToCheck = record.ValueToCheck();
    this.m_comparisonType = IntEnum(Cast(EnumValueFromName(n"EComparisonType", record.ComparisonType())));
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let itemCreationPrereqDataWrapper: ref<ItemCreationPrereqDataWrapper> = context as ItemCreationPrereqDataWrapper;
    let itemData: ref<gameItemData> = itemCreationPrereqDataWrapper.GetItemData();
    let currentValue: Float = itemData.GetStatValueByType(this.m_statType);
    return ProcessCompare(this.m_comparisonType, currentValue, this.m_valueToCheck);
  }
}
