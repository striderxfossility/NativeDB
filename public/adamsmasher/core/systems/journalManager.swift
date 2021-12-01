
public final native class JournalManager extends IJournalManager {

  public final native const func GetQuests(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetMetaQuests(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetContacts(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetFlattenedMessagesAndChoices(contactEntry: wref<JournalEntry>, out messages: array<wref<JournalEntry>>, out choiceEntries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetMessagesAndChoices(conversationEntry: wref<JournalEntry>, out messages: array<wref<JournalEntry>>, out choiceEntries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetConversations(contactEntry: wref<JournalEntry>, out conversations: array<wref<JournalEntry>>) -> Void;

  public final native const func GetTarots(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetInternetSites(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetInternetPages(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetMainInternetPage(siteEntry: wref<JournalInternetSite>) -> wref<JournalInternetPage>;

  public final native const func GetCodexCategories(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetOnscreens(context: JournalRequestContext, out entries: array<ref<JournalOnscreensStructuredGroup>>) -> Void;

  public final native const func GetBriefings(context: JournalRequestContext, out entries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetChildren(parentEntry: wref<JournalEntry>, filter: JournalRequestStateFilter, out childEntries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetRandomChildren(parentEntry: wref<JournalEntry>, filter: JournalRequestStateFilter, childCount: Int32, out childEntries: array<wref<JournalEntry>>) -> Void;

  public final native const func GetParentEntry(childEntry: wref<JournalEntry>) -> wref<JournalEntry>;

  public final native const func GetEntry(hash: Uint32) -> wref<JournalEntry>;

  public final native const func GetEntryByString(uniquePath: String, className: String) -> wref<JournalEntry>;

  public final native const func GetEntryState(entry: wref<JournalEntry>) -> gameJournalEntryState;

  public final native const func GetEntryTimestamp(entry: wref<JournalEntry>) -> GameTime;

  public final native const func IsEntryVisited(entry: wref<JournalEntry>) -> Bool;

  public final native func SetEntryVisited(entry: wref<JournalEntry>, value: Bool) -> Void;

  public final native const func GetEntryHash(entry: wref<JournalEntry>) -> Int32;

  public final native const func GetTrackedEntry() -> wref<JournalEntry>;

  public final native const func IsEntryTracked(entry: wref<JournalEntry>) -> Bool;

  public final native func TrackEntry(entry: wref<JournalEntry>) -> Void;

  public final native func TrackPrevNextEntry(next: Bool) -> Void;

  public final native func ChangeEntryState(uniquePath: String, className: String, state: gameJournalEntryState, notifyOption: JournalNotifyOption) -> Bool;

  public final native func ChangeEntryStateByHash(hash: Uint32, state: gameJournalEntryState, notifyOption: JournalNotifyOption) -> Void;

  public final native const func HasAnyDelayedStateChanges() -> Bool;

  public final native const func GetObjectiveCurrentCounter(entry: wref<JournalQuestObjective>) -> Int32;

  public final native const func GetObjectiveTotalCounter(entry: wref<JournalQuestObjective>) -> Int32;

  public final native const func GetMetaQuestData(metaQuestId: gamedataMetaQuest) -> JournalMetaQuestScriptedData;

  public final native const func GetDistrict(entry: wref<JournalEntry>) -> wref<District_Record>;

  public final native const func GetRecommendedLevel(entry: wref<JournalEntry>) -> Uint32;

  public final native const func GetRecommendedLevelID(entry: wref<JournalEntry>) -> TweakDBID;

  public final native const func GetDistanceToNearestMappin(entry: wref<JournalQuestObjective>) -> Float;

  public final native const func GetPointOfInterestMappinHashFromQuestHash(hash: Uint32) -> Uint32;

  public final native func RegisterScriptCallback(obj: ref<IScriptable>, functionName: CName, type: gameJournalListenerType) -> Void;

  public final native func UnregisterScriptCallback(obj: ref<IScriptable>, functionName: CName) -> Void;

  public final native func DebugShowAllPoiMappins() -> Void;

  public final func CreateScriptedQuestFromTemplate(templateQuestEntryId: String, uniqueId: String, title: String) -> Bool {
    return false;
  }

  public final func DeleteScriptedQuest(templateQuestEntryId: String, uniqueId: String) -> Bool {
    return false;
  }

  public final func SetScriptedQuestEntryState(templateQuestEntryId: String, uniqueId: String, templatePhaseAndObjectivePath: String, state: gameJournalEntryState, notifyOption: JournalNotifyOption, track: Bool) -> Void;

  public final func SetScriptedQuestObjectiveDescription(templateQuestEntryId: String, uniqueId: String, templatePhaseAndObjectivePath: String, description: String) -> Bool {
    return false;
  }

  public final func SetScriptedQuestMappinEntityID(templateQuestEntryId: String, uniqueId: String, templatePhaseObjectiveAndMappinPath: String, entityID: EntityID) -> Bool {
    return false;
  }

  public final func SetScriptedQuestMappinSlotName(templateQuestEntryId: String, uniqueId: String, templatePhaseObjectiveAndMappinPath: String, recordID: TweakDBID) -> Bool {
    return false;
  }

  public final func SetScriptedQuestMappinData(templateQuestEntryId: String, uniqueId: String, templatePhaseObjectiveAndMappinPath: String, mappinData: MappinData) -> Bool {
    return false;
  }

  protected final cb func OnQuestEntryTracked(entry: wref<JournalEntry>) -> Bool {
    if entry == null {
      Log("No entry is being tracked");
    } else {
      if IsDefined(entry as JournalQuest) {
        Log("Quest entry is being tracked");
      } else {
        if IsDefined(entry as JournalQuestObjective) {
          Log("Quest objective entry is being tracked");
        };
      };
    };
  }

  protected final cb func OnQuestEntryUntracked(entry: wref<JournalEntry>) -> Bool {
    if entry == null {
      Log("No entry is being untracked");
    } else {
      if IsDefined(entry as JournalQuest) {
        Log("Quest entry is being untracked");
      } else {
        if IsDefined(entry as JournalQuestObjective) {
          Log("Quest objective entry is being untracked");
        };
      };
    };
  }

  public final func GetContactDataArray(includeUnknown: Bool) -> array<ref<IScriptable>> {
    let contactData: ref<ContactData>;
    let contactDataArray: array<ref<IScriptable>>;
    let contactEntry: wref<JournalContact>;
    let context: JournalRequestContext;
    let emptyContactData: ref<ContactData>;
    let entries: array<wref<JournalEntry>>;
    let i: Int32;
    let j: Int32;
    let lastMessegeRecived: wref<JournalPhoneMessage>;
    let lastMessegeSent: wref<JournalPhoneChoiceEntry>;
    let messagesReceived: array<wref<JournalEntry>>;
    let playerReplies: array<wref<JournalEntry>>;
    let trackedChildEntriesCount: Int32;
    let trackedChildEntriesHashList: array<Int32>;
    let trackedChildEntriesList: array<wref<JournalEntry>>;
    let trackedChildEntry: wref<JournalQuestCodexLink>;
    let trackedObjective: ref<JournalQuestObjective>;
    context.stateFilter.active = true;
    this.GetContacts(context, entries);
    trackedChildEntriesCount = 0;
    trackedObjective = this.GetTrackedEntry() as JournalQuestObjective;
    if trackedObjective != null {
      this.GetChildren(trackedObjective, context.stateFilter, trackedChildEntriesList);
      trackedChildEntriesCount = ArraySize(trackedChildEntriesList);
      j = 0;
      while j < trackedChildEntriesCount {
        trackedChildEntry = trackedChildEntriesList[j] as JournalQuestCodexLink;
        if IsDefined(trackedChildEntry) {
          ArrayPush(trackedChildEntriesHashList, Cast(trackedChildEntry.GetLinkPathHash()));
        };
        j = j + 1;
      };
    };
    i = 0;
    while i < ArraySize(entries) {
      contactEntry = entries[i] as JournalContact;
      if IsDefined(contactEntry) {
        if includeUnknown || contactEntry.IsKnown(this) {
          contactData = new ContactData();
          contactData.id = contactEntry.GetId();
          contactData.hash = this.GetEntryHash(contactEntry);
          contactData.localizedName = contactEntry.GetLocalizedName(this);
          contactData.avatarID = contactEntry.GetAvatarID(this);
          contactData.questRelated = ArrayContains(trackedChildEntriesHashList, contactData.hash);
          ArrayClear(messagesReceived);
          ArrayClear(playerReplies);
          this.GetFlattenedMessagesAndChoices(contactEntry, messagesReceived, playerReplies);
          j = 0;
          while j < ArraySize(messagesReceived) {
            if !this.IsEntryVisited(messagesReceived[j]) {
              ArrayPush(contactData.unreadMessages, this.GetEntryHash(messagesReceived[j]));
            };
            j += 1;
          };
          contactData.playerCanReply = ArraySize(playerReplies) > 0;
          if ArraySize(messagesReceived) > 0 {
            contactData.hasMessages = true;
            lastMessegeRecived = ArrayLast(messagesReceived) as JournalPhoneMessage;
            if IsDefined(lastMessegeRecived) {
              contactData.lastMesssagePreview = lastMessegeRecived.GetText();
              contactData.playerIsLastSender = false;
            } else {
              lastMessegeSent = ArrayLast(messagesReceived) as JournalPhoneChoiceEntry;
              contactData.lastMesssagePreview = lastMessegeSent.GetText();
              contactData.playerIsLastSender = true;
            };
          } else {
            contactData.lastMesssagePreview = "You are now connected.";
          };
          ArrayPush(contactDataArray, contactData);
        };
      } else {
        ArrayPush(contactDataArray, emptyContactData);
      };
      i += 1;
    };
    return contactDataArray;
  }

  public final func IsAttachedToAnyActiveQuest(hash: Int32) -> Bool {
    let childEntries: array<wref<JournalEntry>>;
    let codexLinkEntry: ref<JournalQuestCodexLink>;
    let context: JournalRequestContext;
    let count: Int32;
    let filter: JournalRequestStateFilter;
    let i: Int32;
    let quests: array<wref<JournalEntry>>;
    filter.active = true;
    context.stateFilter = filter;
    this.GetQuests(context, quests);
    count = ArraySize(quests);
    i = 0;
    while i < count {
      QuestLogUtils.UnpackRecursiveWithFilter(this, quests[i] as JournalContainerEntry, filter, childEntries, true);
      i += 1;
    };
    count = ArraySize(childEntries);
    i = 0;
    while i < count {
      codexLinkEntry = childEntries[i] as JournalQuestCodexLink;
      if IsDefined(codexLinkEntry) && Cast(codexLinkEntry.GetLinkPathHash()) == hash {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func IsAttachedToTrackedObjective(hash: Int32) -> Bool {
    let childEntries: array<wref<JournalEntry>>;
    let count: Int32;
    let filter: JournalRequestStateFilter;
    let i: Int32;
    let trackedChildEntry: ref<JournalQuestCodexLink>;
    filter.active = true;
    let objective: ref<JournalQuestObjective> = this.GetTrackedEntry() as JournalQuestObjective;
    if objective != null {
      this.GetChildren(objective, filter, childEntries);
      count = ArraySize(childEntries);
      i = 0;
      while i < count {
        trackedChildEntry = childEntries[i] as JournalQuestCodexLink;
        if IsDefined(trackedChildEntry) && Cast(trackedChildEntry.GetLinkPathHash()) == hash {
          return true;
        };
        i = i + 1;
      };
    };
    return false;
  }
}

public static exec func trackPrev(instance: GameInstance) -> Void {
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  journal.TrackPrevNextEntry(false);
}

public static exec func trackNext(instance: GameInstance) -> Void {
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  journal.TrackPrevNextEntry(true);
}

public static exec func untrack(instance: GameInstance) -> Void {
  let dummy: wref<JournalEntry>;
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  journal.TrackEntry(dummy);
}

public static exec func printTracked(instance: GameInstance) -> Void {
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  let entry: wref<JournalEntry> = journal.GetTrackedEntry();
  if IsDefined(entry) {
    Log("Tracked entry [" + entry.GetId() + "] [" + entry.GetEditorName() + "]");
  } else {
    Log("No tracked entry");
  };
}

public static exec func printJ(instance: GameInstance) -> Void {
  let context: JournalRequestContext;
  let descriptionAndMappinEntries: array<wref<JournalEntry>>;
  let descriptionEntry: wref<JournalQuestDescription>;
  let i: Int32;
  let j: Int32;
  let k: Int32;
  let l: Int32;
  let m: Int32;
  let mappinEntry: wref<JournalQuestMapPin>;
  let objectiveEntries: array<wref<JournalEntry>>;
  let objectiveEntry: wref<JournalQuestObjective>;
  let phaseEntries: array<wref<JournalEntry>>;
  let phaseEntry: wref<JournalQuestPhase>;
  let questEntries: array<wref<JournalEntry>>;
  let questEntry: wref<JournalQuest>;
  let subobjectiveDescriptionAndMappinEntries: array<wref<JournalEntry>>;
  let subobjectiveEntry: wref<JournalQuestSubObjective>;
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  Log("=========================================================================================");
  context.stateFilter.active = true;
  context.stateFilter.succeeded = true;
  journal.GetQuests(context, questEntries);
  i = 0;
  while i < ArraySize(questEntries) {
    questEntry = questEntries[i] as JournalQuest;
    if !IsDefined(questEntry) {
      Log("Q" + i + " ???");
    } else {
      Log("Q" + i + " [" + EnumInt(journal.GetEntryState(questEntry)) + "] [" + questEntry.GetId() + "] [" + questEntry.GetEditorName() + "] [" + questEntry.GetTitle(journal) + "] " + " [" + EnumInt(questEntry.GetType()) + "]");
      journal.GetChildren(questEntry, context.stateFilter, phaseEntries);
      j = 0;
      while j < ArraySize(phaseEntries) {
        phaseEntry = phaseEntries[j] as JournalQuestPhase;
        if !IsDefined(phaseEntry) {
          Log("    P" + j + " ???");
        } else {
          Log("    P" + j + " [" + EnumInt(journal.GetEntryState(phaseEntry)) + "] [" + phaseEntry.GetId() + "] [" + phaseEntry.GetEditorName() + "]");
          journal.GetChildren(phaseEntry, context.stateFilter, objectiveEntries);
          k = 0;
          while k < ArraySize(objectiveEntries) {
            objectiveEntry = objectiveEntries[k] as JournalQuestObjective;
            if !IsDefined(objectiveEntry) {
              Log("        O" + k + " ???");
            } else {
              Log("        O" + k + " [" + EnumInt(journal.GetEntryState(objectiveEntry)) + "] [" + objectiveEntry.GetId() + "] [" + objectiveEntry.GetEditorName() + "]");
              Log("        DISTANCE " + journal.GetDistanceToNearestMappin(objectiveEntry));
              journal.GetChildren(objectiveEntry, context.stateFilter, subobjectiveDescriptionAndMappinEntries);
              l = 0;
              while l < ArraySize(subobjectiveDescriptionAndMappinEntries) {
                subobjectiveEntry = subobjectiveDescriptionAndMappinEntries[l] as JournalQuestSubObjective;
                mappinEntry = subobjectiveDescriptionAndMappinEntries[l] as JournalQuestMapPin;
                descriptionEntry = subobjectiveDescriptionAndMappinEntries[l] as JournalQuestDescription;
                if IsDefined(subobjectiveEntry) {
                  Log("            S" + l + " [" + EnumInt(journal.GetEntryState(subobjectiveEntry)) + "] [" + subobjectiveEntry.GetId() + "] [" + subobjectiveEntry.GetEditorName() + "]");
                  journal.GetChildren(subobjectiveEntry, context.stateFilter, descriptionAndMappinEntries);
                  m = 0;
                  while m < ArraySize(descriptionAndMappinEntries) {
                    mappinEntry = descriptionAndMappinEntries[m] as JournalQuestMapPin;
                    descriptionEntry = descriptionAndMappinEntries[m] as JournalQuestDescription;
                    if IsDefined(mappinEntry) {
                      Log("                M" + m + " [" + EnumInt(journal.GetEntryState(mappinEntry)) + "] [" + mappinEntry.GetId() + "] [" + mappinEntry.GetEditorName() + "]");
                    } else {
                      if IsDefined(descriptionEntry) {
                        Log("                D" + m + " [" + EnumInt(journal.GetEntryState(descriptionEntry)) + "] [" + descriptionEntry.GetId() + "] [" + descriptionEntry.GetEditorName() + "]");
                      } else {
                        Log("                MD " + m + " ???");
                      };
                    };
                    m += 1;
                  };
                } else {
                  if IsDefined(mappinEntry) {
                    Log("            M" + l + " [" + EnumInt(journal.GetEntryState(mappinEntry)) + "] [" + mappinEntry.GetId() + "] [" + mappinEntry.GetEditorName() + "]");
                  } else {
                    if IsDefined(descriptionEntry) {
                      Log("            D" + l + " [" + EnumInt(journal.GetEntryState(descriptionEntry)) + "] [" + descriptionEntry.GetId() + "] [" + descriptionEntry.GetEditorName() + "]");
                    } else {
                      Log("            SMD " + l + " ???");
                    };
                  };
                };
                l += 1;
              };
            };
            k += 1;
          };
        };
        j += 1;
      };
    };
    i += 1;
  };
}

public static exec func printJ2(instance: GameInstance) -> Void {
  let context: JournalRequestContext;
  let i: Int32;
  let journal: ref<JournalManager>;
  let questEntries: array<wref<JournalEntry>>;
  let questEntry: wref<JournalQuest>;
  context.stateFilter.inactive = true;
  context.stateFilter.active = true;
  context.stateFilter.failed = true;
  context.stateFilter.succeeded = true;
  JournalRequestContext.CreateQuestDistanceRequestFilter(context, instance, 50.00);
  journal = GameInstance.GetJournalManager(instance);
  journal.GetQuests(context, questEntries);
  Log(">>>>>>>>>>>>>>>>>> Q");
  i = 0;
  while i < ArraySize(questEntries) {
    questEntry = questEntries[i] as JournalQuest;
    Log("Q" + i + " [" + EnumInt(journal.GetEntryState(questEntry)) + "] [" + questEntry.GetId() + "] [" + questEntry.GetEditorName() + "] [" + questEntry.GetTitle(journal) + "] " + " [" + EnumInt(questEntry.GetType()) + "]");
    i += 1;
  };
  Log("<<<<<<<<<<<<<<<<<< Q");
}

public static exec func cset(instance: GameInstance) -> Void {
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  journal.ChangeEntryState("points_of_interest/minor_activities/ma_bls_ina_se1_09", "gameJournalPointOfInterestMappin", gameJournalEntryState.Active, JournalNotifyOption.Notify);
}

public static exec func gebs(instance: GameInstance) -> Void {
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  let entry: wref<JournalEntry> = journal.GetEntryByString("points_of_interest/minor_activities/ma_bls_ina_se1_09", "gameJournalPointOfInterestMappin");
  if entry != null {
    Log("Entry exists: " + entry.GetEditorName());
  } else {
    Log("Entry does not exist");
  };
}

public static exec func tconv(instance: GameInstance) -> Void {
  let conversations: array<wref<JournalEntry>>;
  let flattenedMessages: array<wref<JournalEntry>>;
  let flattenedReplies: array<wref<JournalEntry>>;
  let i: Int32;
  let messages: array<wref<JournalEntry>>;
  let replies: array<wref<JournalEntry>>;
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  let contact: wref<JournalEntry> = journal.GetEntryByString("contacts/administration", "gameJournalContact");
  if contact == null {
    Log("contact null");
    return;
  };
  journal.GetFlattenedMessagesAndChoices(contact, flattenedMessages, flattenedReplies);
  journal.GetConversations(contact, conversations);
  i = 0;
  while i < ArraySize(conversations) {
    journal.GetMessagesAndChoices(conversations[i], messages, replies);
    Log("test");
    i += 1;
  };
  Log("contact");
}

public static exec func tmq(instance: GameInstance) -> Void {
  let journal: ref<JournalManager> = GameInstance.GetJournalManager(instance);
  let data: JournalMetaQuestScriptedData = journal.GetMetaQuestData(gamedataMetaQuest.MetaQuest1);
  Log(">>>>> " + data.hidden + " " + Cast(data.percent) + " " + data.text);
  data = journal.GetMetaQuestData(gamedataMetaQuest.MetaQuest2);
  Log(">>>>> " + data.hidden + " " + Cast(data.percent) + " " + data.text);
  data = journal.GetMetaQuestData(gamedataMetaQuest.MetaQuest3);
  Log(">>>>> " + data.hidden + " " + Cast(data.percent) + " " + data.text);
}
