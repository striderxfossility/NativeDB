
public class DialerContactDataView extends ScriptableDataView {

  private let m_compareBuilder: ref<CompareBuilder>;

  public final func Setup() -> Void {
    this.m_compareBuilder = CompareBuilder.Make();
  }

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftData: ref<ContactData> = left as ContactData;
    let rightData: ref<ContactData> = right as ContactData;
    this.m_compareBuilder.Reset();
    return this.m_compareBuilder.BoolTrue(leftData.questRelated, rightData.questRelated).BoolTrue(ArraySize(leftData.unreadMessages) > 0, ArraySize(rightData.unreadMessages) > 0).UnicodeStringAsc(leftData.localizedName, rightData.localizedName).GetBool();
  }

  public func FilterItem(data: ref<IScriptable>) -> Bool {
    return true;
  }
}

public class DialerContactTemplateClassifier extends inkVirtualItemTemplateClassifier {

  public func ClassifyItem(data: Variant) -> Uint32 {
    return 0u;
  }
}
