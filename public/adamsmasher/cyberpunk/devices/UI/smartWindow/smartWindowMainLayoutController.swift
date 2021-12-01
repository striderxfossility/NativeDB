
public class SmartWindowMainLayoutWidgetController extends ComputerMainLayoutWidgetController {

  @attrib(category, "Widget Refs")
  private edit let m_menuMailsSlot: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_menuFilesSlot: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_menuNewsFeedSlot: inkWidgetRef;

  @attrib(category, "Widget Refs")
  private edit let m_menuDevicesSlot: inkWidgetRef;

  public func Initialize(gameController: ref<ComputerInkGameController>) -> Void {
    this.m_mainMenu.SetVisible(false);
    this.m_isInitialized = true;
  }

  public func GetDevicesMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuDevicesSlot);
  }

  public func GetNewsfeedMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuNewsFeedSlot);
  }

  public func GetMailsMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuMailsSlot);
  }

  public func GetFilesMenuContainer() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_menuFilesSlot);
  }

  public func SetMailsMenu(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    this.SetMailsMenu(gameController, parentWidget);
    if this.m_mailsMenu != null {
      this.m_mailsMenu.SetSizeRule(inkESizeRule.Stretch);
    };
  }

  public func SetFilesMenu(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    this.SetFilesMenu(gameController, parentWidget);
    if this.m_filesMenu != null {
      this.m_filesMenu.SetSizeRule(inkESizeRule.Stretch);
    };
  }

  public func SetDevicesMenu(widget: ref<inkWidget>) -> Void {
    this.m_devicesMenu = widget;
  }

  public func SetNewsFeedMenu(gameController: ref<ComputerInkGameController>, parentWidget: wref<inkWidget>) -> Void {
    this.SetNewsFeedMenu(gameController, parentWidget);
    if this.m_newsFeedMenu != null {
      this.m_newsFeedMenu.SetSizeRule(inkESizeRule.Stretch);
    };
  }

  public func ShowNewsfeed() -> Void {
    this.m_newsFeedMenu.SetVisible(true);
  }

  public func ShowMails() -> Void {
    this.m_mailsMenu.SetVisible(true);
  }

  public func ShowFiles() -> Void {
    this.m_filesMenu.SetVisible(true);
  }

  public func ShowDevices() -> Void {
    this.m_devicesMenu.SetVisible(true);
  }
}
