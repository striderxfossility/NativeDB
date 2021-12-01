
public class ShardsNestedListDataView extends VirtualNestedListDataView {

  protected func SortItems(compareBuilder: ref<CompareBuilder>, left: ref<VirutalNestedListData>, right: ref<VirutalNestedListData>) -> Void {
    let leftData: ref<ShardEntryData> = left.m_data as ShardEntryData;
    let rightData: ref<ShardEntryData> = right.m_data as ShardEntryData;
    if IsDefined(leftData) && IsDefined(rightData) {
      compareBuilder.BoolTrue(leftData.m_isNew, rightData.m_isNew).GameTimeDesc(leftData.m_timeStamp, rightData.m_timeStamp);
    };
  }
}

public class ShardsVirtualNestedListController extends VirtualNestedListController {

  private let m_currentDataView: wref<ShardsNestedListDataView>;

  protected func GetDataView() -> ref<VirtualNestedListDataView> {
    let view: ref<ShardsNestedListDataView> = new ShardsNestedListDataView();
    this.m_currentDataView = view;
    return view;
  }
}

public class CodexUtils extends IScriptable {

  public final static func GetShardsDataArray(journal: ref<JournalManager>, activeDataSync: wref<CodexListSyncData>) -> array<ref<VirutalNestedListData>> {
    let context: JournalRequestContext;
    let curGroup: wref<JournalOnscreensStructuredGroup>;
    let curShard: wref<JournalOnscreen>;
    let groupData: ref<ShardEntryData>;
    let groupVirtualListData: ref<VirutalNestedListData>;
    let groups: array<ref<JournalOnscreensStructuredGroup>>;
    let hasNewEntries: Bool;
    let i: Int32;
    let j: Int32;
    let newEntries: array<Int32>;
    let shardData: ref<ShardEntryData>;
    let shardVirtualListData: ref<VirutalNestedListData>;
    let shards: array<wref<JournalOnscreen>>;
    let virtualDataList: array<ref<VirutalNestedListData>>;
    context.stateFilter.active = true;
    journal.GetOnscreens(context, groups);
    i = 0;
    while i < ArraySize(groups) {
      curGroup = groups[i];
      shards = curGroup.GetEntries();
      hasNewEntries = false;
      ArrayClear(newEntries);
      j = 0;
      while j < ArraySize(shards) {
        curShard = shards[j];
        shardData = new ShardEntryData();
        shardData.m_title = curShard.GetTitle();
        shardData.m_description = curShard.GetDescription();
        shardData.m_imageId = curShard.GetIconID();
        shardData.m_hash = journal.GetEntryHash(curShard);
        shardData.m_timeStamp = journal.GetEntryTimestamp(curShard);
        shardData.m_activeDataSync = activeDataSync;
        shardData.m_isNew = !journal.IsEntryVisited(curShard);
        if shardData.m_isNew {
          ArrayPush(newEntries, shardData.m_hash);
          ArrayPush(shardData.m_newEntries, shardData.m_hash);
        };
        shardVirtualListData = new VirutalNestedListData();
        shardVirtualListData.m_level = i;
        shardVirtualListData.m_widgetType = 0u;
        shardVirtualListData.m_isHeader = false;
        shardVirtualListData.m_data = shardData;
        ArrayPush(virtualDataList, shardVirtualListData);
        if shardData.m_isNew {
          hasNewEntries = true;
        };
        j += 1;
      };
      groupData = new ShardEntryData();
      groupData.m_title = CodexUtils.GetLocalizedTag(curGroup.GetTag());
      groupData.m_activeDataSync = activeDataSync;
      groupData.m_counter = ArraySize(shards);
      groupData.m_isNew = hasNewEntries;
      groupData.m_newEntries = newEntries;
      groupVirtualListData = new VirutalNestedListData();
      groupVirtualListData.m_level = i;
      groupVirtualListData.m_widgetType = 1u;
      groupVirtualListData.m_isHeader = true;
      groupVirtualListData.m_data = groupData;
      ArrayPush(virtualDataList, groupVirtualListData);
      i += 1;
    };
    return virtualDataList;
  }

  public final static func ConvertToCodexData(journal: ref<JournalManager>, currentEntry: wref<JournalCodexEntry>, currentGroupIndex: Int32, stateFilter: JournalRequestStateFilter, out newEntries: array<Int32>, opt activeDataSync: wref<CodexListSyncData>, opt useFallbackImages: Bool) -> ref<CodexEntryData> {
    let descriptionEntry: wref<JournalCodexDescription>;
    let innerEntries: array<wref<JournalEntry>>;
    let l: Int32;
    let entryData: ref<CodexEntryData> = new CodexEntryData();
    entryData.m_category = currentGroupIndex;
    entryData.m_title = currentEntry.GetTitle();
    entryData.m_hash = journal.GetEntryHash(currentEntry);
    entryData.m_timeStamp = journal.GetEntryTimestamp(currentEntry);
    entryData.m_isNew = !journal.IsEntryVisited(currentEntry);
    entryData.m_activeDataSync = activeDataSync;
    entryData.m_imageId = currentEntry.GetImageID();
    entryData.m_imageType = currentGroupIndex != EnumInt(CodexCategoryType.Characters) ? CodexImageType.Default : CodexImageType.Character;
    if !TDBID.IsValid(entryData.m_imageId) && useFallbackImages {
      entryData.m_imageId = Equals(entryData.m_imageType, CodexImageType.Default) ? t"UIJournalIcons.PlaceholderCodexImage" : t"UIJournalIcons.PlaceholderCodexCharacterImage";
    };
    ArrayClear(innerEntries);
    journal.GetChildren(currentEntry, stateFilter, innerEntries);
    l = 0;
    while l < ArraySize(innerEntries) {
      descriptionEntry = innerEntries[l] as JournalCodexDescription;
      if IsDefined(descriptionEntry) {
        entryData.m_description = descriptionEntry.GetTextContent();
      };
      l += 1;
    };
    if entryData.m_isNew {
      ArrayPush(newEntries, entryData.m_hash);
      ArrayPush(entryData.m_newEntries, entryData.m_hash);
    };
    return entryData;
  }

  public final static func GetCodexDataArray(journal: ref<JournalManager>, activeDataSync: wref<CodexListSyncData>, opt useFallbackImages: Bool) -> array<ref<VirutalNestedListData>> {
    let categories: array<wref<JournalEntry>>;
    let context: JournalRequestContext;
    let currentCategory: wref<JournalCodexCategory>;
    let currentEntry: wref<JournalCodexEntry>;
    let currentGroup: wref<JournalCodexGroup>;
    let currentGroupIndex: Int32;
    let entries: array<wref<JournalEntry>>;
    let entryData: ref<CodexEntryData>;
    let entryVirtualListData: ref<VirutalNestedListData>;
    let groupData: ref<CodexEntryData>;
    let groupVirtualListData: ref<VirutalNestedListData>;
    let groups: array<wref<JournalEntry>>;
    let groupsCounter: Int32;
    let hasNewEntries: Bool;
    let i: Int32;
    let j: Int32;
    let k: Int32;
    let newEntries: array<Int32>;
    let stateFilter: JournalRequestStateFilter;
    let virtualDataList: array<ref<VirutalNestedListData>>;
    context.stateFilter.inactive = false;
    context.stateFilter.failed = false;
    context.stateFilter.succeeded = false;
    context.stateFilter.active = true;
    stateFilter.inactive = false;
    stateFilter.failed = false;
    stateFilter.succeeded = false;
    stateFilter.active = true;
    journal.GetCodexCategories(context, categories);
    CodexUtils.SetCodexData(journal, categories);
    i = 0;
    while i < ArraySize(categories) {
      ArrayClear(groups);
      currentCategory = categories[i] as JournalCodexCategory;
      journal.GetChildren(currentCategory, stateFilter, groups);
      hasNewEntries = false;
      ArrayClear(newEntries);
      currentGroupIndex = EnumInt(CodexUtils.GetCategoryTypeFromId(currentCategory.GetId()));
      j = 0;
      while j < ArraySize(groups) {
        currentGroup = groups[j] as JournalCodexGroup;
        ArrayClear(entries);
        journal.GetChildren(currentGroup, stateFilter, entries);
        k = 0;
        while k < ArraySize(entries) {
          currentEntry = entries[k] as JournalCodexEntry;
          entryData = CodexUtils.ConvertToCodexData(journal, currentEntry, currentGroupIndex, stateFilter, newEntries, activeDataSync, useFallbackImages);
          entryVirtualListData = new VirutalNestedListData();
          entryVirtualListData.m_level = groupsCounter;
          entryVirtualListData.m_widgetType = 0u;
          entryVirtualListData.m_isHeader = false;
          entryVirtualListData.m_data = entryData;
          ArrayPush(virtualDataList, entryVirtualListData);
          if entryData.m_isNew {
            hasNewEntries = true;
          };
          k += 1;
        };
        groupData = new CodexEntryData();
        groupData.m_title = currentGroup.GetGroupName();
        groupData.m_isNew = hasNewEntries;
        groupData.m_newEntries = newEntries;
        groupData.m_activeDataSync = activeDataSync;
        groupData.m_category = currentGroupIndex;
        groupVirtualListData = new VirutalNestedListData();
        groupVirtualListData.m_level = groupsCounter;
        groupVirtualListData.m_widgetType = 1u;
        groupVirtualListData.m_isHeader = true;
        groupVirtualListData.m_collapsable = true;
        groupVirtualListData.m_data = groupData;
        ArrayPush(virtualDataList, groupVirtualListData);
        groupsCounter += 1;
        j += 1;
      };
      i += 1;
    };
    return virtualDataList;
  }

  public final static func GetTutorialsData(journal: ref<JournalManager>, activeDataSync: wref<CodexListSyncData>, offset: Int32) -> array<ref<VirutalNestedListData>> {
    let currentEntry: wref<JournalOnscreen>;
    let entries: array<wref<JournalEntry>>;
    let entryData: ref<CodexEntryData>;
    let entryVirtualListData: ref<VirutalNestedListData>;
    let groupData: ref<CodexEntryData>;
    let groupVirtualListData: ref<VirutalNestedListData>;
    let hasNewEntries: Bool;
    let i: Int32;
    let newEntries: array<Int32>;
    let result: array<ref<VirutalNestedListData>>;
    CodexUtils.AppendTutorialEntries(journal, "onscreens/tutorials", entries);
    CodexUtils.AppendTutorialEntries(journal, "onscreens/tutorials_new", entries);
    CodexUtils.AppendTutorialEntries(journal, "onscreens/tutorial_vr", entries);
    i = 0;
    while i < ArraySize(entries) {
      currentEntry = entries[i] as JournalOnscreen;
      entryData = new CodexEntryData();
      entryData.m_title = currentEntry.GetTitle();
      entryData.m_description = currentEntry.GetDescription();
      entryData.m_imageId = currentEntry.GetIconID();
      entryData.m_hash = journal.GetEntryHash(currentEntry);
      entryData.m_timeStamp = journal.GetEntryTimestamp(currentEntry);
      entryData.m_activeDataSync = activeDataSync;
      entryData.m_isNew = !journal.IsEntryVisited(currentEntry);
      if entryData.m_isNew {
        ArrayPush(newEntries, entryData.m_hash);
        ArrayPush(entryData.m_newEntries, entryData.m_hash);
      };
      if !TDBID.IsValid(entryData.m_imageId) {
        entryData.m_imageId = t"UIJournalIcons.PlaceholderCodexImage";
      };
      entryVirtualListData = new VirutalNestedListData();
      entryVirtualListData.m_level = EnumInt(CodexCategoryType.Tutorials);
      entryVirtualListData.m_widgetType = 0u;
      entryVirtualListData.m_isHeader = false;
      entryVirtualListData.m_data = entryData;
      ArrayPush(result, entryVirtualListData);
      if entryData.m_isNew {
        hasNewEntries = true;
      };
      i += 1;
    };
    groupData = new CodexEntryData();
    groupData.m_title = "Tutorials";
    groupData.m_activeDataSync = activeDataSync;
    groupData.m_counter = ArraySize(entries);
    groupData.m_isNew = hasNewEntries;
    groupData.m_newEntries = newEntries;
    groupVirtualListData = new VirutalNestedListData();
    groupVirtualListData.m_level = EnumInt(CodexCategoryType.Tutorials);
    groupVirtualListData.m_widgetType = 1u;
    groupVirtualListData.m_isHeader = true;
    groupVirtualListData.m_data = groupData;
    ArrayPush(result, groupVirtualListData);
    return result;
  }

  private final static func AppendTutorialEntries(journal: ref<JournalManager>, path: String, output: script_ref<array<wref<JournalEntry>>>) -> Bool {
    let i: Int32;
    let result: array<wref<JournalEntry>>;
    let stateFilter: JournalRequestStateFilter;
    stateFilter.inactive = false;
    stateFilter.failed = false;
    stateFilter.succeeded = false;
    stateFilter.active = true;
    let group: wref<JournalOnscreenGroup> = journal.GetEntryByString(path, "gameJournalOnscreenGroup") as JournalOnscreenGroup;
    journal.GetChildren(group, stateFilter, result);
    i = 0;
    while i < ArraySize(result) {
      ArrayPush(Deref(output), result[i]);
      i += 1;
    };
    return ArraySize(result) > 0;
  }

  public final static func SetCodexData(journal: ref<JournalManager>, codexList: array<wref<JournalEntry>>) -> Void;

  public final static func JournalToRepresentationArray(journal: ref<JournalManager>, entries: array<wref<JournalEntry>>) -> array<ref<JournalRepresentationData>> {
    let codexCategoryData: array<ref<JournalRepresentationData>>;
    let codexEntry: ref<JournalRepresentationData>;
    let i: Int32 = 0;
    while i < ArraySize(entries) {
      codexEntry = new JournalRepresentationData();
      codexEntry.Data = entries[i];
      codexEntry.IsNew = journal.IsEntryVisited(entries[i]);
      ArrayPush(codexCategoryData, codexEntry);
      i += 1;
    };
    return codexCategoryData;
  }

  private final static func GetLocalizedTag(tag: CName) -> String {
    let res: String;
    switch tag {
      case n"literature_fiction":
        res = GetLocalizedText("UI-Shards-LiteratureFiction");
        break;
      case n"night_city_people":
        res = GetLocalizedText("UI-Shards-NightCityPeople");
        break;
      case n"world":
        res = GetLocalizedText("UI-Shards-World");
        break;
      case n"technology":
        res = GetLocalizedText("UI-Shards-Technology");
        break;
      case n"notes":
        res = GetLocalizedText("UI-Shards-Notes");
        break;
      case n"articles":
        res = GetLocalizedText("UI-Shards-Articles");
        break;
      case n"leaflets":
        res = GetLocalizedText("UI-Shards-Leaflets");
        break;
      case n"cyberpsycho":
        res = GetLocalizedText("LocKey#31788");
        break;
      default:
        res = GetLocalizedText("UI-Shards-Others");
    };
    return res;
  }

  public final static func GetShardTitleString(isCrypted: Bool, titleString: String) -> String {
    if isCrypted {
      return GetLocalizedText(titleString) + " (" + GetLocalizedText("Story-base-gameplay-static_data-database-scanning-scanning-quest_clue_template_04_localizedDescription") + ")";
    };
    return GetLocalizedText(titleString);
  }

  public final static func GetShardTextString(isCrypted: Bool, textString: String) -> String {
    let lineLenght: Uint32 = 24u;
    if isCrypted {
      return StringToHex(GetLocalizedText(textString), lineLenght);
    };
    return GetLocalizedText(textString);
  }

  public final static func GetCategoryTypeFromId(id: String) -> CodexCategoryType {
    switch id {
      case "characters":
        return CodexCategoryType.Characters;
      case "glossary":
        return CodexCategoryType.Database;
      case "locations":
        return CodexCategoryType.Locations;
      case "tutorials_new":
      case "tutorial_vr":
      case "tutorials":
        return CodexCategoryType.Tutorials;
    };
    return CodexCategoryType.Invalid;
  }

  public final static func GetCodexFilterIcon(category: CodexCategoryType) -> String {
    switch category {
      case CodexCategoryType.Database:
        return "UIIcon.Filter_Codex_Database";
      case CodexCategoryType.Characters:
        return "UIIcon.Filter_Codex_Characters";
      case CodexCategoryType.Locations:
        return "UIIcon.Filter_Codex_Locations";
      case CodexCategoryType.Tutorials:
        return "UIIcon.Filter_Codex_Tutorials";
    };
    return "UIIcon.Filter_Codex_Default";
  }
}
