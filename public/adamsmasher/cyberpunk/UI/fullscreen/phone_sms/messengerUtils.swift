
public class MessengerUtils extends IScriptable {

  public final static func GetContactDataArray(journal: ref<JournalManager>, includeUnknown: Bool, skipEmpty: Bool, activeDataSync: wref<MessengerContactSyncData>) -> array<ref<VirutalNestedListData>> {
    let contactData: ref<ContactData>;
    let contactEntry: wref<JournalContact>;
    let contactVirtualListData: ref<VirutalNestedListData>;
    let context: JournalRequestContext;
    let conversationEntry: wref<JournalPhoneConversation>;
    let conversations: array<wref<JournalEntry>>;
    let conversationsCount: Int32;
    let entries: array<wref<JournalEntry>>;
    let i: Int32;
    let j: Int32;
    let messagesReceived: array<wref<JournalEntry>>;
    let playerReplies: array<wref<JournalEntry>>;
    let threadData: ref<ContactData>;
    let threadVirtualListData: ref<VirutalNestedListData>;
    let virtualDataList: array<ref<VirutalNestedListData>>;
    context.stateFilter.active = true;
    journal.GetContacts(context, entries);
    i = 0;
    while i < ArraySize(entries) {
      contactEntry = entries[i] as JournalContact;
      if includeUnknown || contactEntry.IsKnown(journal) {
        ArrayClear(messagesReceived);
        ArrayClear(playerReplies);
        journal.GetConversations(contactEntry, conversations);
        journal.GetFlattenedMessagesAndChoices(contactEntry, messagesReceived, playerReplies);
        if skipEmpty && ArraySize(messagesReceived) <= 0 && ArraySize(playerReplies) <= 0 {
        } else {
          contactData = new ContactData();
          contactData.id = contactEntry.GetId();
          contactData.hash = journal.GetEntryHash(contactEntry);
          contactData.localizedName = contactEntry.GetLocalizedName(journal);
          contactData.avatarID = contactEntry.GetAvatarID(journal);
          contactData.timeStamp = journal.GetEntryTimestamp(contactEntry);
          contactData.activeDataSync = activeDataSync;
          MessengerUtils.GetContactMessageData(contactData, journal, messagesReceived, playerReplies);
          contactVirtualListData = new VirutalNestedListData();
          contactVirtualListData.m_level = contactData.hash;
          contactVirtualListData.m_widgetType = 0u;
          contactVirtualListData.m_isHeader = true;
          contactVirtualListData.m_data = contactData;
          conversationsCount = ArraySize(conversations);
          if conversationsCount > 1 {
            contactVirtualListData.m_collapsable = true;
            j = 0;
            while j < conversationsCount {
              ArrayClear(messagesReceived);
              ArrayClear(playerReplies);
              conversationEntry = conversations[j] as JournalPhoneConversation;
              journal.GetMessagesAndChoices(conversationEntry, messagesReceived, playerReplies);
              threadData = new ContactData();
              threadData.id = conversationEntry.GetId();
              threadData.hash = journal.GetEntryHash(conversationEntry);
              threadData.localizedName = conversationEntry.GetTitle();
              threadData.timeStamp = journal.GetEntryTimestamp(conversationEntry);
              threadData.activeDataSync = activeDataSync;
              MessengerUtils.GetContactMessageData(threadData, journal, messagesReceived, playerReplies);
              threadVirtualListData = new VirutalNestedListData();
              threadVirtualListData.m_collapsable = false;
              threadVirtualListData.m_isHeader = false;
              threadVirtualListData.m_level = contactData.hash;
              threadVirtualListData.m_widgetType = 1u;
              threadVirtualListData.m_data = threadData;
              ArrayPush(virtualDataList, threadVirtualListData);
              j += 1;
            };
          } else {
            contactVirtualListData.m_collapsable = false;
          };
          ArrayPush(virtualDataList, contactVirtualListData);
        };
      };
      i += 1;
    };
    return virtualDataList;
  }

  public final static func GetContactMessageData(out contactData: ref<ContactData>, journal: ref<JournalManager>, messagesReceived: array<wref<JournalEntry>>, playerReplies: array<wref<JournalEntry>>) -> Void {
    let lastMessegeRecived: wref<JournalPhoneMessage>;
    let lastMessegeSent: wref<JournalPhoneChoiceEntry>;
    contactData.playerCanReply = ArraySize(playerReplies) > 0;
    let j: Int32 = 0;
    while j < ArraySize(messagesReceived) {
      if !journal.IsEntryVisited(messagesReceived[j]) {
        ArrayPush(contactData.unreadMessages, journal.GetEntryHash(messagesReceived[j]));
      };
      j += 1;
    };
    if ArraySize(messagesReceived) > 0 {
      lastMessegeRecived = ArrayLast(messagesReceived) as JournalPhoneMessage;
      if IsDefined(lastMessegeRecived) {
        contactData.lastMesssagePreview = lastMessegeRecived.GetText();
        contactData.playerIsLastSender = false;
      } else {
        lastMessegeSent = ArrayLast(messagesReceived) as JournalPhoneChoiceEntry;
        contactData.lastMesssagePreview = lastMessegeSent.GetText();
        contactData.playerIsLastSender = true;
      };
    };
  }

  public final static func HasPhoneObjective(journal: ref<JournalManager>) -> Bool {
    return false;
  }

  public final static func GetUnreadMessagesCount(journal: ref<JournalManager>, contactEntry: wref<JournalContact>) -> Int32 {
    let messagesReceived: array<wref<JournalEntry>>;
    let playerReplies: array<wref<JournalEntry>>;
    journal.GetFlattenedMessagesAndChoices(contactEntry, messagesReceived, playerReplies);
    return ArraySize(messagesReceived);
  }
}
