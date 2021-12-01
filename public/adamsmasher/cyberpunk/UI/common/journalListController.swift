
public class JournalEntryListItemController extends ListItemController {

  protected cb func OnDataChanged(value: ref<IScriptable>) -> Bool {
    let data: ref<JournalEntryListItemData> = value as JournalEntryListItemData;
    if IsDefined(data) {
      this.OnJournalEntryUpdated(data.m_entry, data.m_extraData);
    };
  }

  protected func OnJournalEntryUpdated(entry: wref<JournalEntry>, extraData: ref<IScriptable>) -> Void;
}

public class JournalEntriesListController extends ListController {

  public final func PushEntries(data: array<wref<JournalEntry>>) -> Void {
    let scriptableList: array<ref<IScriptable>>;
    let scriptableObj: ref<JournalEntryListItemData>;
    let count: Int32 = ArraySize(data);
    let i: Int32 = 0;
    while i < count {
      scriptableObj = new JournalEntryListItemData();
      scriptableObj.m_entry = data[i];
      ArrayPush(scriptableList, scriptableObj);
      i += 1;
    };
    this.PushDataList(scriptableList, true);
  }

  public final func PushEntriesEx(data: array<wref<JournalEntry>>, extraData: array<ref<IScriptable>>) -> Void {
    let scriptableList: array<ref<IScriptable>>;
    let scriptableObj: ref<JournalEntryListItemData>;
    let count: Int32 = ArraySize(data);
    let i: Int32 = 0;
    while i < count {
      scriptableObj = new JournalEntryListItemData();
      scriptableObj.m_entry = data[i];
      scriptableObj.m_extraData = extraData[i];
      ArrayPush(scriptableList, scriptableObj);
      i += 1;
    };
    this.PushDataList(scriptableList, true);
  }
}
