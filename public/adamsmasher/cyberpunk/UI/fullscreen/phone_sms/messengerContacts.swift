
public class MessengerContactDataView extends VirtualNestedListDataView {

  protected func SortItems(compareBuilder: ref<CompareBuilder>, left: ref<VirutalNestedListData>, right: ref<VirutalNestedListData>) -> Void {
    let leftData: ref<ContactData> = left.m_data as ContactData;
    let rightData: ref<ContactData> = right.m_data as ContactData;
    if IsDefined(leftData) && IsDefined(rightData) {
      compareBuilder.BoolTrue(ArraySize(leftData.unreadMessages) > 0, ArraySize(rightData.unreadMessages) > 0).GameTimeDesc(leftData.timeStamp, rightData.timeStamp);
    };
  }
}

public class MessengerContactItemVirtualController extends inkVirtualCompoundItemController {

  private edit let m_label: inkTextRef;

  private edit let m_msgPreview: inkTextRef;

  private edit let m_msgCounter: inkTextRef;

  private edit let m_msgIndicator: inkWidgetRef;

  private edit let m_replyAlertIcon: inkWidgetRef;

  private edit let m_collapseIcon: inkWidgetRef;

  private edit let m_image: inkImageRef;

  private let m_contactData: ref<ContactData>;

  private let m_nestedListData: ref<VirutalNestedListData>;

  private let m_type: MessengerContactType;

  private let m_activeItemSync: wref<MessengerContactSyncData>;

  private let m_isContactActive: Bool;

  private let m_isItemHovered: Bool;

  private let m_isItemToggled: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnToggledOn", this, n"OnToggledOn");
    this.RegisterToCallback(n"OnToggledOff", this, n"OnToggledOff");
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
  }

  public final func OnDataChanged(value: Variant) -> Void {
    this.m_nestedListData = FromVariant(value) as VirutalNestedListData;
    this.m_contactData = this.m_nestedListData.m_data as ContactData;
    this.m_activeItemSync = this.m_contactData.activeDataSync;
    if this.m_nestedListData.m_collapsable {
      this.m_type = MessengerContactType.Group;
    } else {
      if this.m_nestedListData.m_widgetType == 1u {
        this.m_type = MessengerContactType.Thread;
      } else {
        this.m_type = MessengerContactType.Contact;
      };
    };
    if ArraySize(this.m_contactData.unreadMessages) > 0 {
      inkWidgetRef.SetVisible(this.m_msgCounter, true);
      inkTextRef.SetText(this.m_msgCounter, ToString(ArraySize(this.m_contactData.unreadMessages)));
    } else {
      inkWidgetRef.SetVisible(this.m_msgCounter, false);
    };
    if this.m_contactData.playerIsLastSender {
      inkTextRef.SetText(this.m_msgPreview, GetLocalizedTextByKey(n"UI-Phone-LabelYou") + this.m_contactData.lastMesssagePreview);
    } else {
      inkTextRef.SetText(this.m_msgPreview, this.m_contactData.lastMesssagePreview);
    };
    inkWidgetRef.SetVisible(this.m_replyAlertIcon, this.m_contactData.playerCanReply && NotEquals(this.m_type, MessengerContactType.Group));
    inkTextRef.SetText(this.m_label, this.m_contactData.localizedName);
    if TDBID.IsValid(this.m_contactData.avatarID) {
      inkWidgetRef.SetVisible(this.m_image, true);
      InkImageUtils.RequestSetImage(this, this.m_image, this.m_contactData.avatarID);
    };
    if inkWidgetRef.IsValid(this.m_collapseIcon) {
      inkWidgetRef.SetVisible(this.m_collapseIcon, this.m_nestedListData.m_collapsable);
    };
    this.UpdateState();
  }

  protected cb func OnContactSyncData(evt: ref<MessengerContactSyncBackEvent>) -> Bool {
    this.UpdateState();
  }

  protected cb func OnMessengerThreadSelectedEvent(evt: ref<MessengerThreadSelectedEvent>) -> Bool {
    ArrayRemove(this.m_contactData.unreadMessages, Cast(evt.m_hash));
    if ArraySize(this.m_contactData.unreadMessages) > 0 {
      inkWidgetRef.SetVisible(this.m_msgCounter, true);
      inkTextRef.SetText(this.m_msgCounter, ToString(ArraySize(this.m_contactData.unreadMessages)));
    } else {
      inkWidgetRef.SetVisible(this.m_msgCounter, false);
    };
  }

  protected cb func OnToggledOn(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    let evt: ref<MessengerContactSelectedEvent> = new MessengerContactSelectedEvent();
    evt.m_entryHash = this.m_contactData.hash;
    evt.m_level = this.m_nestedListData.m_level;
    evt.m_type = this.m_type;
    this.QueueEvent(evt);
    this.m_isItemToggled = true;
  }

  protected cb func OnToggledOff(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.m_isItemToggled = false;
    this.UpdateState();
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    this.m_isItemHovered = true;
    this.UpdateState();
    if discreteNav {
      this.SetCursorOverWidget(this.GetRootWidget());
    };
  }

  protected cb func OnDeselected(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.m_isItemHovered = false;
    this.UpdateState();
  }

  private final func UpdateState() -> Void {
    if this.m_activeItemSync.m_entryHash == this.m_contactData.hash {
      this.GetRootWidget().SetState(n"Active");
    } else {
      if this.m_activeItemSync.m_level == this.m_nestedListData.m_level && Equals(this.m_type, MessengerContactType.Group) {
        this.GetRootWidget().SetState(n"SubActive");
      } else {
        if this.m_isItemHovered {
          this.GetRootWidget().SetState(n"Hover");
        } else {
          this.GetRootWidget().SetState(n"Default");
        };
      };
    };
  }
}
