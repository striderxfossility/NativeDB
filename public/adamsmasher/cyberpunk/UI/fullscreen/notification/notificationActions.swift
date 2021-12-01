
public class GenericNotificationBaseAction extends IScriptable {

  public func Execute(data: ref<IScriptable>) -> Bool {
    return false;
  }

  public func GetLabel() -> String {
    return "";
  }
}

public class TrackQuestNotificationAction extends GenericNotificationBaseAction {

  public let m_questEntry: wref<JournalQuest>;

  public let m_journalMgr: wref<JournalManager>;

  public func Execute(data: ref<IScriptable>) -> Bool {
    this.m_journalMgr.TrackEntry(this.m_questEntry);
    this.TrackFirstObjective(this.m_questEntry);
    return true;
  }

  public func GetLabel() -> String {
    return "LocKey#42567";
  }

  private final func TrackFirstObjective(questEntry: wref<JournalEntry>) -> Bool {
    let filter: JournalRequestStateFilter;
    let i: Int32;
    let objectiveEntries: array<wref<JournalEntry>>;
    let phaseEntries: array<wref<JournalEntry>>;
    filter.active = true;
    this.m_journalMgr.GetChildren(questEntry, filter, phaseEntries);
    i = 0;
    while i < ArraySize(phaseEntries) {
      this.m_journalMgr.GetChildren(phaseEntries[i], filter, objectiveEntries);
      if ArraySize(objectiveEntries) > 0 {
        this.m_journalMgr.TrackEntry(objectiveEntries[0]);
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class OpenMessengerNotificationAction extends GenericNotificationBaseAction {

  public let m_eventDispatcher: wref<worlduiIGameController>;

  public let m_journalEntry: wref<JournalEntry>;

  public func Execute(data: ref<IScriptable>) -> Bool {
    this.ShowMessenger();
    return true;
  }

  public func GetLabel() -> String {
    return "Open Messenger";
  }

  private final func ShowMessenger() -> Void {
    let evt: ref<PhoneMessagePopupEvent> = new PhoneMessagePopupEvent();
    evt.m_data = new JournalNotificationData();
    evt.m_data.journalEntry = this.m_journalEntry;
    evt.m_data.queueName = n"modal_popup";
    evt.m_data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\phone_message_popup.inkwidget";
    evt.m_data.isBlocking = true;
    this.m_eventDispatcher.QueueBroadcastEvent(evt);
  }
}

public class ItemNotificationAction extends GenericNotificationBaseAction {

  public let m_eventDispatcher: wref<worlduiIGameController>;

  public func Execute(data: ref<IScriptable>) -> Bool {
    this.ShowInventory();
    return true;
  }

  public func GetLabel() -> String {
    return GetLocalizedText("UI-Notifications-OpenInventory");
  }

  private final func ShowInventory() -> Void {
    let evt: ref<StartHubMenuEvent> = new StartHubMenuEvent();
    evt.SetStartMenu(n"inventory_screen");
    this.m_eventDispatcher.QueueBroadcastEvent(evt);
  }
}

public class OpenPerksNotificationAction extends GenericNotificationBaseAction {

  public let m_eventDispatcher: wref<worlduiIGameController>;

  public func Execute(data: ref<IScriptable>) -> Bool {
    this.ShowPerks();
    return true;
  }

  public func GetLabel() -> String {
    return GetLocalizedText("UI-Notifications-OpenPerks");
  }

  private final func ShowPerks() -> Void {
    let evt: ref<StartHubMenuEvent> = new StartHubMenuEvent();
    evt.SetStartMenu(n"perks_main");
    this.m_eventDispatcher.QueueBroadcastEvent(evt);
  }
}

public class OpenShardNotificationAction extends GenericNotificationBaseAction {

  public let m_eventDispatcher: ref<UISystem>;

  public func Execute(data: ref<IScriptable>) -> Bool {
    let userData: ref<ShardCollectedNotificationViewData> = data as ShardCollectedNotificationViewData;
    let evt: ref<NotifyShardRead> = new NotifyShardRead();
    evt.title = userData.shardTitle;
    evt.text = userData.text;
    evt.entry = userData.entry;
    evt.isCrypted = userData.isCrypted;
    evt.itemID = userData.itemID;
    this.m_eventDispatcher.QueueEvent(evt);
    return true;
  }

  public func GetLabel() -> String {
    return GetLocalizedText("Gameplay-Devices-Interactions-ReadMessage");
  }
}

public class OpenWorldMapNotificationAction extends GenericNotificationBaseAction {

  public let m_eventDispatcher: wref<worlduiIGameController>;

  public func Execute(data: ref<IScriptable>) -> Bool {
    this.ShowWorldMap();
    return true;
  }

  public func GetLabel() -> String {
    return "LocKey#52348";
  }

  private final func ShowWorldMap() -> Void {
    let evt: ref<StartHubMenuEvent> = new StartHubMenuEvent();
    evt.SetStartMenu(n"world_map");
    this.m_eventDispatcher.QueueBroadcastEvent(evt);
  }
}

public class OpenTarotCollectionNotificationAction extends GenericNotificationBaseAction {

  public let m_eventDispatcher: wref<worlduiIGameController>;

  public func Execute(data: ref<IScriptable>) -> Bool {
    this.ShowTarotCollection();
    return true;
  }

  public func GetLabel() -> String {
    return "LocKey#77676";
  }

  private final func ShowTarotCollection() -> Void {
    let evt: ref<StartHubMenuEvent> = new StartHubMenuEvent();
    evt.SetStartMenu(n"tarot_main");
    this.m_eventDispatcher.QueueBroadcastEvent(evt);
  }
}
